-- [ts]: xiaoman3d.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Camera3D = ____Dora.Camera3D -- 10
local Color = ____Dora.Color -- 10
local Director = ____Dora.Director -- 10
local DrawNode = ____Dora.DrawNode -- 10
local Model3D = ____Dora.Model3D -- 10
local Node = ____Dora.Node -- 10
local Node3D = ____Dora.Node3D -- 10
local Size = ____Dora.Size -- 10
local Surface3D = ____Dora.Surface3D -- 10
local Vec2 = ____Dora.Vec2 -- 10
local Vec3 = ____Dora.Vec3 -- 10
local View = ____Dora.View -- 10
local ____play = require("Script.watch.play") -- 11
local GRAVITY = ____play.GRAVITY -- 11
local ____xiaoman3d_actor = require("Script.watch.fe.scenes.xiaoman3d_actor") -- 15
local Xiaoman3DActor = ____xiaoman3d_actor.Xiaoman3DActor -- 15
local ____xiaoman3d_entities = require("Script.watch.fe.scenes.xiaoman3d_entities") -- 16
local Xiaoman3DEntities = ____xiaoman3d_entities.Xiaoman3DEntities -- 16
local ROOM_MODELS = {outside = "assets/xiaoman3d/outside.glb", village = "assets/xiaoman3d/village.glb", forest = "assets/xiaoman3d/forest.glb", tower = "assets/xiaoman3d/tower.glb"} -- 18
local function getView3D() -- 42
	return Director.entry -- 43
end -- 42
--- GLB coordinates stay Y-up. Collision and interaction authority stays in rooms.ts/Play.
____exports.Xiaoman3DScene = __TS__Class() -- 47
local Xiaoman3DScene = ____exports.Xiaoman3DScene -- 47
Xiaoman3DScene.name = "Xiaoman3DScene" -- 47
function Xiaoman3DScene.prototype.____constructor(self, host) -- 77
	self.root = Node3D() -- 48
	self.camera = Camera3D("xiaoman-follow") -- 49
	self.room = "" -- 51
	self.active = false -- 52
	self.envConfigured = false -- 53
	self.glow = DrawNode() -- 58
	self.groundFx = DrawNode() -- 60
	self.shadows = {} -- 62
	self.focal = 1 -- 65
	self.stageX = 0 -- 66
	self.stageY = 0 -- 67
	self.fullW = 1280 -- 68
	self.fullH = 720 -- 69
	self.pitchSin = 0 -- 70
	self.pitchCos = 1 -- 71
	self.cameraX = 0 -- 72
	self.cameraY = 0 -- 73
	self.cameraZ = 0 -- 74
	self.time = 0 -- 75
	Director.entry:addChild(self.root) -- 78
	self.root.visible = false -- 79
	self.actor = __TS__New(Xiaoman3DActor, self.root) -- 81
	self.entities = __TS__New(Xiaoman3DEntities, self.root) -- 82
	local content = Node() -- 85
	content:addChild(self.glow) -- 86
	local effects = Surface3D( -- 87
		content, -- 87
		Size(20, 5), -- 87
		Size(2000, 500) -- 87
	) -- 87
	if effects == nil then -- 87
		error("Surface3D effects creation failed") -- 88
	end -- 88
	effects.scaleX = -1 -- 89
	self.effects = effects -- 90
	self.root:addChild(effects) -- 91
	local gContent = Node() -- 94
	gContent:addChild(self.groundFx) -- 95
	local gSurf = Surface3D( -- 96
		gContent, -- 96
		Size(20, 4), -- 96
		Size(2000, 400) -- 96
	) -- 96
	if gSurf == nil then -- 96
		error("Surface3D groundFx creation failed") -- 97
	end -- 97
	gSurf.angles = Vec3(90, 0, 0) -- 98
	gSurf.scaleX = -1 -- 99
	self.groundSurface = gSurf -- 100
	self.root:addChild(gSurf) -- 101
	host:onCleanup(function() -- 103
		self:hide() -- 104
		self.root:removeFromParent() -- 105
	end) -- 103
end -- 77
function Xiaoman3DScene.prototype.supports(self, p, visualMode) -- 109
	return visualMode == "lowpoly" and ROOM_MODELS[p.room.key] ~= nil -- 110
end -- 109
function Xiaoman3DScene.prototype.configureEnvironment(self) -- 113
	if self.envConfigured then -- 113
		return -- 115
	end -- 115
	local v3 = getView3D() -- 117
	if v3.setEnvironmentMap ~= nil then -- 117
		v3:setEnvironmentMap("") -- 119
	end -- 119
	if v3.setEnvironmentIntensity ~= nil then -- 119
		v3:setEnvironmentIntensity(0.24, 0.18, 1.02) -- 123
	end -- 123
	v3.shadowMapSize = 1024 -- 125
	self.envConfigured = true -- 126
end -- 113
function Xiaoman3DScene.prototype.restoreEnvironment(self) -- 129
	if not self.envConfigured then -- 129
		return -- 131
	end -- 131
	local v3 = getView3D() -- 133
	if v3.setEnvironmentIntensity ~= nil then -- 133
		v3:setEnvironmentIntensity(1, 1, 1) -- 135
	end -- 135
	self.envConfigured = false -- 137
end -- 129
function Xiaoman3DScene.prototype.hide(self) -- 140
	self.root.visible = false -- 141
	self.actor:hide() -- 142
	self.entities:hide() -- 143
	self:restoreEnvironment() -- 144
	if self.active then -- 144
		Director:removeCamera(self.camera) -- 146
		self.active = false -- 147
	end -- 147
end -- 140
function Xiaoman3DScene.prototype.render(self, p, cam, actors, dt, w, h, vp) -- 151
	self.p = p -- 152
	local safeDt = p.paused and 0 or dt -- 153
	self.time = self.time + safeDt -- 154
	if self.room ~= p.room.key then -- 154
		if self.model ~= nil then -- 154
			self.root:removeChild(self.model) -- 158
			self.model = nil -- 159
		end -- 159
		local loaded = Model3D(ROOM_MODELS[p.room.key]) -- 161
		if loaded.parent ~= nil then -- 161
			loaded:removeFromParent(false) -- 163
		end -- 163
		self.model = loaded -- 165
		self.root:addChild(loaded) -- 166
		self.room = p.room.key -- 167
	end -- 167
	local centerX = (p.room.minX + p.room.maxX) / 2 -- 171
	self.glow.x = -centerX -- 172
	self.effects.position = Vec3(centerX / 100, 0, -p.player.depth / 100 + 0.02) -- 173
	self.groundFx.x = -centerX -- 174
	self.groundFx.y = 0 -- 175
	self.groundSurface.position = Vec3(centerX / 100, 0.015, 0) -- 176
	if self.model ~= nil then -- 176
		self.model.position = Vec3(p.ox / 100, 0, 0) -- 179
	end -- 179
	self:configureEnvironment() -- 182
	if not self.active then -- 182
		Director:pushCamera(self.camera) -- 184
		self.active = true -- 185
	end -- 185
	self.root.visible = true -- 187
	self:updateCamera( -- 189
		p, -- 189
		cam, -- 189
		w, -- 189
		h, -- 189
		vp -- 189
	) -- 189
	cam.projection = self -- 190
	self.glow:clear() -- 192
	self.groundFx:clear() -- 193
	for key in pairs(self.shadows) do -- 196
		self.shadows[key].visible = false -- 197
	end -- 197
	local a = p.player -- 199
	if a.alive then -- 199
		local ground = actors:supportGroundY(p, a) -- 201
		self:placeShadow( -- 202
			"child", -- 202
			a.x, -- 202
			ground, -- 202
			a.depth, -- 202
			a.w * 0.56, -- 202
			10, -- 202
			math.max(0.24, 0.92 - (a.y - ground) / 170) -- 203
		) -- 203
	end -- 203
	if p.room.scavenger ~= nil then -- 203
		self:placeShadow( -- 206
			"scavenger", -- 206
			p.scavX, -- 206
			p.room.scavenger.y, -- 206
			0, -- 206
			17, -- 206
			10, -- 206
			0.85 -- 206
		) -- 206
	end -- 206
	if p.room.key == "forest" then -- 206
		self:placeShadow( -- 209
			"dog", -- 209
			p.dogX, -- 209
			0, -- 209
			6, -- 209
			20, -- 209
			9, -- 209
			0.82 -- 209
		) -- 209
	end -- 209
	self.actor:update(p, safeDt) -- 213
	self.entities:update( -- 214
		p, -- 214
		safeDt, -- 214
		cam.x, -- 214
		self.glow, -- 214
		self.groundFx -- 214
	) -- 214
	self:drawBottleAimPreview(p) -- 217
end -- 151
function Xiaoman3DScene.prototype.drawBottleAimPreview(self, p) -- 220
	if not p.hasBottle or p.aimHold <= 0 or p.bottleAimX < 0 then -- 220
		return -- 222
	end -- 222
	local endX = p.bottleAimX -- 224
	local endY = p.bottleAimY -- 225
	local x0 = p.player.x + (endX >= p.player.x and 10 or -10) -- 226
	local y0 = p.player.y + p.player.h * 0.7 -- 227
	local duration = 0.62 -- 228
	local vx = (endX - x0) / duration -- 229
	local vy = (endY - y0 + 0.5 * GRAVITY * duration * duration) / duration -- 230
	local i = 1 -- 231
	do -- 231
		i = 1 -- 232
		while i <= 18 do -- 232
			local t = i / 18 * duration -- 233
			self.glow:drawDot( -- 234
				Vec2(x0 + vx * t, y0 + vy * t - 0.5 * GRAVITY * t * t), -- 235
				1.4, -- 236
				Color(246, 220, 152, 224) -- 237
			) -- 237
			i = i + 1 -- 232
		end -- 232
	end -- 232
	self.glow:drawEllipse( -- 240
		Vec2(endX, endY + 1.5), -- 240
		9, -- 240
		2.4, -- 240
		Color(246, 220, 152, 190) -- 240
	) -- 240
end -- 220
function Xiaoman3DScene.prototype.placeShadow(self, key, x, y, depth, rx, rz, opacity) -- 243
	if opacity == nil then -- 243
		opacity = 1 -- 243
	end -- 243
	local surface = self.shadows[key] -- 244
	if surface == nil then -- 244
		local content = DrawNode() -- 246
		content:drawCircle( -- 247
			Vec2(0, 0), -- 247
			50, -- 247
			Color(8, 10, 14, 138) -- 247
		) -- 247
		local created = Surface3D( -- 248
			content, -- 248
			Size(1, 1), -- 248
			Size(100, 100) -- 248
		) -- 248
		if created == nil then -- 248
			error("Surface3D shadow creation failed") -- 249
		end -- 249
		surface = created -- 250
		surface.angles = Vec3(90, 0, 0) -- 251
		self.root:addChild(surface) -- 252
		self.shadows[key] = surface -- 253
	end -- 253
	surface.visible = true -- 255
	surface.content.opacity = opacity -- 256
	surface.scale = Vec3(rx / 50, rz / 50, 1) -- 257
	surface.position = Vec3(x / 100, (y + 0.7) / 100, -depth / 100) -- 258
end -- 243
function Xiaoman3DScene.prototype.updateCamera(self, p, cam, w, h, vp) -- 261
	self.fullW = View.size.width -- 262
	self.fullH = View.size.height -- 263
	self.stageX = vp.stageX -- 264
	self.stageY = vp.stageY -- 265
	self.focal = self.fullH / (2 * math.tan(View.fieldOfView * math.pi / 360)) -- 266
	local baseDist = p.room.key == "village" and 3.9 or (p.room.key == "tower" and 4.1 or 4.25) -- 269
	local riseRatio = p.room.key == "village" and 0.16 or 0.21 -- 270
	local baseTargetY = p.room.key == "village" and 0.68 or 0.82 -- 271
	local distance = baseDist / cam.zoom * self.fullH / h -- 273
	local rise = distance * riseRatio -- 274
	local length = math.sqrt(distance * distance + rise * rise) -- 275
	self.pitchSin = rise / length -- 276
	self.pitchCos = distance / length -- 277
	local offsetX = (vp.stageX + w / 2 - self.fullW / 2) * length / self.focal -- 279
	local offsetY = (vp.stageY + h / 2 - self.fullH / 2) * length / self.focal -- 280
	local focusWorldX = p.room.key == "tower" and (p.towerDoorOpen and math.max(5.35, (p.ox + 490) / 100 + (p.player.x - (p.ox + 490)) * 0.0045) or math.max(4.85, p.player.x / 100 + 0.55)) or cam.x / 100 -- 281
	local tx = focusWorldX - offsetX -- 284
	local ty = baseTargetY + (cam.y - 82) * 0.0045 - offsetY * self.pitchCos -- 285
	local tz = -p.player.depth * 0.0035 + offsetY * self.pitchSin -- 287
	self.cameraX = tx -- 289
	self.cameraY = ty + rise -- 290
	self.cameraZ = tz + distance -- 291
	self.camera:lookAt( -- 292
		Vec3(self.cameraX, self.cameraY, self.cameraZ), -- 292
		Vec3(tx, ty, tz) -- 292
	) -- 292
end -- 261
function Xiaoman3DScene.prototype.worldToScreen(self, x, y, depth) -- 295
	if depth == nil then -- 295
		depth = 0 -- 295
	end -- 295
	local dx = x / 100 - self.cameraX -- 296
	local dy = y / 100 - self.cameraY -- 297
	local dz = -depth / 100 - self.cameraZ -- 298
	local forward = -dy * self.pitchSin - dz * self.pitchCos -- 299
	return {x = self.fullW / 2 + dx * self.focal / forward - self.stageX, y = self.fullH / 2 + (dy * self.pitchCos - dz * self.pitchSin) * self.focal / forward - self.stageY} -- 300
end -- 295
function Xiaoman3DScene.prototype.screenToWorld(self, x, y) -- 306
	local u = (x + self.stageX - self.fullW / 2) / self.focal -- 307
	local v = (y + self.stageY - self.fullH / 2) / self.focal -- 308
	local rayY = v * self.pitchCos - self.pitchSin -- 309
	local rayZ = -v * self.pitchSin - self.pitchCos -- 310
	local ____opt_0 = self.p -- 310
	local z = -(____opt_0 and ____opt_0.player.depth or 0) / 100 -- 312
	local t = (z - self.cameraZ) / rayZ -- 313
	return {x = (self.cameraX + u * t) * 100, y = (self.cameraY + rayY * t) * 100} -- 314
end -- 306
function Xiaoman3DScene.prototype.getDebugState(self) -- 317
	local v3 = getView3D() -- 318
	local stats = v3.stats -- 319
	return { -- 320
		active = self.active, -- 321
		room = self.room, -- 322
		actor = self.actor:getDebugState(self.p), -- 323
		entities = self.entities:getDebugState(), -- 324
		cameraPos = {x = self.cameraX, y = self.cameraY, z = self.cameraZ}, -- 325
		drawCalls = stats ~= nil and stats.drawCalls or 0, -- 326
		visibleModels = stats ~= nil and stats.visibleModels or 0 -- 327
	} -- 327
end -- 317
return ____exports -- 317