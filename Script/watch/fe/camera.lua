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
		elseif p.phase == "gate-send" or p.phase == "gate-farewell" then -- 107
			desiredZoom = 1.06 -- 109
		end -- 109
	elseif p.room.key == "museum" then -- 109
		desiredZoom = p.phase == "museum-cabinet" and 1.14 or 1.06 -- 113
	elseif p.room.key == "outside" then -- 113
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 116
	elseif p.room.key == "forest" and p.player.x >= p.ox + 1160 and p.player.x <= p.ox + 1350 then -- 116
		desiredZoom = p.player.x < p.ox + 1280 and 1.12 or 0.98 -- 119
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 119
		desiredZoom = 1.22 -- 121
	end -- 121
	local zk = math.min(1, dt * 3.8) -- 124
	if p.reloadOpen then -- 124
		desiredZoom = math.max(desiredZoom, 1.16) -- 127
	end -- 127
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 129
	local lookAhead = p.player.facing * 48 -- 132
	if not p.childMode and p.aimX > 0 and w > 0 then -- 132
		local normMouse = (p.aimX / w - 0.5) * 2 -- 134
		lookAhead = lookAhead + normMouse * 36 -- 135
	end -- 135
	if p.room.key == "outside" and p.player.x < 520 then -- 135
		lookAhead = p.player.x < 280 and 96 or 18 -- 139
	end -- 139
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 139
		lookAhead = 120 -- 142
	end -- 142
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 142
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 145
	end -- 145
	local tx = p.player.x + lookAhead -- 148
	local ty = self:targetCamY(p) -- 149
	local followK = math.min(1, dt * 6.5) -- 150
	self.x = self.x + (tx - self.x) * followK -- 151
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 152
	if self.shakeAmp > 0.08 then -- 152
		self.shakePhase = self.shakePhase + dt * 68 -- 156
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 157
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 158
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 159
	else -- 159
		self.shakeAmp = 0 -- 161
		self.shakeX = 0 -- 162
		self.shakeY = 0 -- 163
	end -- 163
	self:recomputeMetrics(p, w, h) -- 166
end -- 82
function CameraDirector.prototype.targetCamY(self, p) -- 169
	if p.room.key == "outside" and p.player.y >= 60 then -- 169
		return 102 -- 171
	end -- 171
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 173
end -- 169
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 176
	self.viewW = math.max(320, w) -- 177
	self.viewH = math.max(180, h) -- 178
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 179
	local lock = self.anchorLock -- 181
	if lock ~= nil then -- 181
		local basePpu = self.viewH / BASE_VIEW_UNITS_H -- 183
		local worldSpan = lock.thresholdWorldX - lock.footWorldX -- 184
		if lock.screenThresholdFracX ~= nil and math.abs(worldSpan) > 0.0001 then -- 184
			local screenSpan = (lock.screenThresholdFracX - lock.screenFootFracX) * self.viewW -- 186
			local solvedPpu = screenSpan / worldSpan -- 187
			if solvedPpu > 0.05 then -- 187
				self.ppu = solvedPpu -- 189
				self.zoom = solvedPpu / basePpu -- 190
			else -- 190
				if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 190
					self.zoom = lock.zoomOverride -- 193
				end -- 193
				self.ppu = basePpu * self.zoom -- 195
			end -- 195
		else -- 195
			if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 195
				self.zoom = lock.zoomOverride -- 199
			end -- 199
			self.ppu = basePpu * self.zoom -- 201
		end -- 201
		local footDepth = lock.footDepth or 0 -- 203
		self.x = lock.footWorldX - (lock.screenFootFracX - 0.5) * self.viewW / self.ppu -- 204
		local desiredYOffset = lock.footWorldY + footDepth * DEPTH_Y_SCALE - (lock.screenFootFracY * self.viewH - self.groundScreenY) / self.ppu -- 205
		self.y = 82 + desiredYOffset / 0.45 -- 206
		return -- 207
	end -- 207
	local aspect = self.viewW / self.viewH -- 212
	local aspectComp = aspect < 16 / 9 and math.max( -- 213
		0.82, -- 214
		math.min(1, aspect / (16 / 9)) -- 214
	) or 1 -- 214
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom * aspectComp -- 216
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 219
	local spanX = p.room.maxX - p.room.minX -- 220
	if spanX <= halfWorldW * 2 then -- 220
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 222
	else -- 222
		local minCam = p.room.minX + halfWorldW -- 224
		local maxCam = p.room.maxX - halfWorldW -- 225
		if self.x < minCam then -- 225
			self.x = minCam -- 227
		end -- 227
		if self.x > maxCam then -- 227
			self.x = maxCam -- 230
		end -- 230
	end -- 230
end -- 176
function CameraDirector.prototype.sx(self, wx) -- 236
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 237
end -- 236
function CameraDirector.prototype.sy(self, wy, depth) -- 241
	if depth == nil then -- 241
		depth = 0 -- 241
	end -- 241
	local yOffset = (self.y - 82) * 0.45 -- 242
	return self.groundScreenY + (wy + depth * DEPTH_Y_SCALE - yOffset) * self.ppu + self.shakeY -- 243
end -- 241
function CameraDirector.prototype.len(self, worldLen) -- 247
	return worldLen * self.ppu -- 248
end -- 247
function CameraDirector.prototype.depthScale(self, depth, enabled) -- 256
	if enabled == nil then -- 256
		enabled = true -- 256
	end -- 256
	if not enabled then -- 256
		return 1 -- 258
	end -- 258
	local s = 1 - depth / 44 * 0.08 -- 260
	return math.max( -- 261
		0.88, -- 261
		math.min(1.08, s) -- 261
	) -- 261
end -- 256
function CameraDirector.prototype.depthShade(self, depth, enabled) -- 268
	if enabled == nil then -- 268
		enabled = true -- 268
	end -- 268
	if not enabled then -- 268
		return 1 -- 270
	end -- 270
	local t = math.max( -- 272
		0, -- 272
		math.min(1, (depth + 44) / 88) -- 272
	) -- 272
	return 1 - t * 0.19 -- 273
end -- 268
function CameraDirector.prototype.perspectiveX(self, screenX, depth, enabled) -- 280
	if enabled == nil then -- 280
		enabled = true -- 280
	end -- 280
	if not enabled then -- 280
		return screenX -- 282
	end -- 282
	local cx = self.viewW * 0.5 -- 284
	local scale = self:depthScale(depth, true) -- 285
	return cx + (screenX - cx) * scale -- 286
end -- 280
function CameraDirector.prototype.worldToScreen(self, wx, wy, depth) -- 290
	if depth == nil then -- 290
		depth = 0 -- 290
	end -- 290
	return { -- 291
		x = self:sx(wx), -- 292
		y = self:sy(wy, depth) -- 293
	} -- 293
end -- 290
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 298
	local yOffset = (self.y - 82) * 0.45 -- 299
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 300
end -- 298
return ____exports -- 298