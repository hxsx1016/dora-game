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
____exports.CameraDirector = __TS__Class() -- 35
local CameraDirector = ____exports.CameraDirector -- 35
CameraDirector.name = "CameraDirector" -- 35
function CameraDirector.prototype.____constructor(self) -- 35
	self.x = 0 -- 38
	self.y = 85 -- 39
	self.zoom = 1 -- 41
	self.shakeAmp = 0 -- 43
	self.shakeX = 0 -- 44
	self.shakeY = 0 -- 45
	self.shakePhase = 0 -- 46
	self.viewW = 1280 -- 51
	self.viewH = 720 -- 52
	self.ppu = 2.37 -- 53
	self.groundScreenY = 162 -- 54
end -- 35
function CameraDirector.prototype.setAnchorLock(self, lock) -- 57
	self.anchorLock = lock -- 58
end -- 57
function CameraDirector.prototype.getAnchorLock(self) -- 61
	return self.anchorLock -- 62
end -- 61
function CameraDirector.prototype.snap(self, p, w, h) -- 66
	self.anchorLock = nil -- 67
	local theme = themeOf(p.room.key) -- 68
	self.zoom = theme.defaultZoom -- 69
	self.shakeAmp = 0 -- 70
	self.shakeX = 0 -- 71
	self.shakeY = 0 -- 72
	self.x = p.player.x + p.player.facing * 42 -- 73
	self.y = self:targetCamY(p) -- 74
	self:recomputeMetrics(p, w, h) -- 75
end -- 66
function CameraDirector.prototype.addShake(self, amount) -- 79
	if amount > self.shakeAmp then -- 79
		self.shakeAmp = math.min(18, amount) -- 81
	else -- 81
		self.shakeAmp = math.min(18, self.shakeAmp + amount * 0.45) -- 83
	end -- 83
end -- 79
function CameraDirector.prototype.update(self, dt, p, w, h) -- 88
	if self.anchorLock ~= nil then -- 88
		self.shakeAmp = 0 -- 90
		self.shakeX = 0 -- 91
		self.shakeY = 0 -- 92
		self:recomputeMetrics(p, w, h) -- 93
		return -- 94
	end -- 94
	local theme = themeOf(p.room.key) -- 96
	local desiredZoom = theme.defaultZoom -- 97
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 97
		desiredZoom = 1.24 -- 101
	elseif not p.childMode and p.escort.state == "calming" then -- 101
		desiredZoom = 1.2 -- 103
	elseif p.room.key == "gate" then -- 103
		if p.phase == "gate-hold" then -- 103
			desiredZoom = 0.88 -- 106
		elseif p.phase == "gate-count" then -- 106
			desiredZoom = 1.15 -- 108
		elseif p.phase == "gate-wait" then -- 108
			desiredZoom = 1.12 -- 111
		elseif p.phase == "gate-hand" then -- 111
			desiredZoom = 1.22 -- 113
		elseif p.phase == "gate-send" or p.phase == "gate-farewell" then -- 113
			desiredZoom = 1.06 -- 115
		end -- 115
	elseif p.room.key == "museum" then -- 115
		desiredZoom = p.phase == "museum-cabinet" and 1.14 or 1.06 -- 119
	elseif p.room.key == "outside" then -- 119
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 122
	elseif p.room.key == "forest" and p.player.x >= p.ox + 1160 and p.player.x <= p.ox + 1350 then -- 122
		desiredZoom = p.player.x < p.ox + 1280 and 1.12 or 0.98 -- 125
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 125
		desiredZoom = 1.22 -- 127
	end -- 127
	local zk = math.min(1, dt * 3.8) -- 130
	if p.reloadOpen then -- 130
		desiredZoom = math.max(desiredZoom, 1.16) -- 133
	end -- 133
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 135
	local lookAhead = p.player.facing * 48 -- 138
	if not p.childMode and p.aimX > 0 and w > 0 then -- 138
		local normMouse = (p.aimX / w - 0.5) * 2 -- 140
		lookAhead = lookAhead + normMouse * 36 -- 141
	end -- 141
	if p.room.key == "outside" and p.player.x < 520 then -- 141
		lookAhead = p.player.x < 280 and 96 or 18 -- 145
	end -- 145
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 145
		lookAhead = 120 -- 148
	end -- 148
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 148
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 151
	end -- 151
	local tx = p.player.x + lookAhead -- 154
	local ty = self:targetCamY(p) -- 155
	local followK = math.min(1, dt * 6.5) -- 156
	self.x = self.x + (tx - self.x) * followK -- 157
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 158
	if self.shakeAmp > 0.08 then -- 158
		self.shakePhase = self.shakePhase + dt * 68 -- 162
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 163
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 164
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 165
	else -- 165
		self.shakeAmp = 0 -- 167
		self.shakeX = 0 -- 168
		self.shakeY = 0 -- 169
	end -- 169
	self:recomputeMetrics(p, w, h) -- 172
end -- 88
function CameraDirector.prototype.targetCamY(self, p) -- 175
	if p.room.key == "outside" and p.player.y >= 60 then -- 175
		return 102 -- 177
	end -- 177
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 179
end -- 175
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 182
	self.viewW = math.max(320, w) -- 183
	self.viewH = math.max(180, h) -- 184
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 185
	local lock = self.anchorLock -- 187
	if lock ~= nil then -- 187
		local basePpu = self.viewH / BASE_VIEW_UNITS_H -- 189
		local worldSpan = lock.thresholdWorldX - lock.footWorldX -- 190
		if lock.screenThresholdFracX ~= nil and math.abs(worldSpan) > 0.0001 then -- 190
			local screenSpan = (lock.screenThresholdFracX - lock.screenFootFracX) * self.viewW -- 192
			local solvedPpu = screenSpan / worldSpan -- 193
			if solvedPpu > 0.05 then -- 193
				self.ppu = solvedPpu -- 195
				self.zoom = solvedPpu / basePpu -- 196
			else -- 196
				if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 196
					self.zoom = lock.zoomOverride -- 199
				end -- 199
				self.ppu = basePpu * self.zoom -- 201
			end -- 201
		else -- 201
			if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 201
				self.zoom = lock.zoomOverride -- 205
			end -- 205
			self.ppu = basePpu * self.zoom -- 207
		end -- 207
		local footDepth = lock.footDepth or 0 -- 209
		self.x = lock.footWorldX - (lock.screenFootFracX - 0.5) * self.viewW / self.ppu -- 210
		local desiredYOffset = lock.footWorldY + footDepth * DEPTH_Y_SCALE - (lock.screenFootFracY * self.viewH - self.groundScreenY) / self.ppu -- 211
		self.y = 82 + desiredYOffset / 0.45 -- 212
		return -- 213
	end -- 213
	local aspect = self.viewW / self.viewH -- 218
	local aspectComp = aspect < 16 / 9 and math.max( -- 219
		0.82, -- 220
		math.min(1, aspect / (16 / 9)) -- 220
	) or 1 -- 220
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom * aspectComp -- 222
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 225
	local spanX = p.room.maxX - p.room.minX -- 226
	if spanX <= halfWorldW * 2 then -- 226
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 228
	else -- 228
		local minCam = p.room.minX + halfWorldW -- 230
		local maxCam = p.room.maxX - halfWorldW -- 231
		if self.x < minCam then -- 231
			self.x = minCam -- 233
		end -- 233
		if self.x > maxCam then -- 233
			self.x = maxCam -- 236
		end -- 236
	end -- 236
end -- 182
function CameraDirector.prototype.sx(self, wx) -- 242
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 243
end -- 242
function CameraDirector.prototype.sy(self, wy, depth) -- 247
	if depth == nil then -- 247
		depth = 0 -- 247
	end -- 247
	local yOffset = (self.y - 82) * 0.45 -- 248
	return self.groundScreenY + (wy + depth * DEPTH_Y_SCALE - yOffset) * self.ppu + self.shakeY -- 249
end -- 247
function CameraDirector.prototype.len(self, worldLen) -- 253
	return worldLen * self.ppu -- 254
end -- 253
function CameraDirector.prototype.worldToScreen(self, wx, wy, depth) -- 258
	if depth == nil then -- 258
		depth = 0 -- 258
	end -- 258
	if self.projection ~= nil then -- 258
		return self.projection:worldToScreen(wx, wy, depth) -- 260
	end -- 260
	return { -- 262
		x = self:sx(wx), -- 263
		y = self:sy(wy, depth) -- 264
	} -- 264
end -- 258
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 269
	if self.projection ~= nil then -- 269
		return self.projection:screenToWorld(screenX, screenY) -- 271
	end -- 271
	local yOffset = (self.y - 82) * 0.45 -- 273
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 274
end -- 269
return ____exports -- 269