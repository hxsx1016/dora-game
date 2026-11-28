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
local BOTTLE_FLY_TIME = ____play.BOTTLE_FLY_TIME -- 11
local GRAVITY = ____play.GRAVITY -- 11
local ____xiaoman3d_actor = require("Script.watch.fe.scenes.xiaoman3d_actor") -- 15
local Xiaoman3DActor = ____xiaoman3d_actor.Xiaoman3DActor -- 15
local ____xiaoman3d_entities = require("Script.watch.fe.scenes.xiaoman3d_entities") -- 16
local BASIN_DEPTH = ____xiaoman3d_entities.BASIN_DEPTH -- 16
local BASIN_BASE_HEIGHT = ____xiaoman3d_entities.BASIN_BASE_HEIGHT -- 16
local Xiaoman3DEntities = ____xiaoman3d_entities.Xiaoman3DEntities -- 16
local ROOM_MODELS = {outside = "assets/xiaoman3d/outside.glb", village = "assets/xiaoman3d/village.glb", forest = "assets/xiaoman3d/forest.glb", tower = "assets/xiaoman3d/tower.glb"} -- 18
local function getView3D() -- 42
	return Director.entry -- 43
end -- 42
local function rayInterval(origin, slope, low, high) -- 46
	if math.abs(slope) < 0.000001 then -- 46
		return {min = origin >= low and origin <= high and -math.huge or math.huge, max = math.huge} -- 48
	end -- 48
	local first = (low - origin) / slope -- 50
	local last = (high - origin) / slope -- 51
	return { -- 52
		min = math.min(first, last), -- 52
		max = math.max(first, last) -- 52
	} -- 52
end -- 46
--- GLB coordinates stay Y-up. Collision and interaction authority stays in rooms.ts/Play.
____exports.Xiaoman3DScene = __TS__Class() -- 56
local Xiaoman3DScene = ____exports.Xiaoman3DScene -- 56
Xiaoman3DScene.name = "Xiaoman3DScene" -- 56
function Xiaoman3DScene.prototype.____constructor(self, host) -- 86
	self.root = Node3D() -- 57
	self.camera = Camera3D("xiaoman-follow") -- 58
	self.room = "" -- 60
	self.active = false -- 61
	self.envConfigured = false -- 62
	self.glow = DrawNode() -- 67
	self.groundFx = DrawNode() -- 69
	self.shadows = {} -- 71
	self.focal = 1 -- 74
	self.stageX = 0 -- 75
	self.stageY = 0 -- 76
	self.fullW = 1280 -- 77
	self.fullH = 720 -- 78
	self.pitchSin = 0 -- 79
	self.pitchCos = 1 -- 80
	self.cameraX = 0 -- 81
	self.cameraY = 0 -- 82
	self.cameraZ = 0 -- 83
	self.time = 0 -- 84
	self.villageBottlePoint = function(____, sx, sy) -- 335
		local p = self.p -- 336
		local mid = self:screenToWorld(sx, sy, 0) -- 337
		local far = self:screenToWorld(sx, sy, 100) -- 338
		local dx = (far.x - mid.x) / 100 -- 339
		local dy = (far.y - mid.y) / 100 -- 340
		local depth = dy < -0.000001 and math.max( -- 342
			-200, -- 342
			math.min(200, -mid.y / dy) -- 342
		) or 200 -- 342
		local height = 0 -- 343
		local hitBasin = false -- 344
		local brickX = p.room.brickX -- 345
		if brickX ~= nil then -- 345
			local xs = rayInterval(mid.x, dx, brickX, p.room.maxX) -- 348
			local ys = rayInterval(mid.y, dy, 0, 2) -- 349
			local near = math.max(-90, xs.min, ys.min) -- 350
			if near <= math.min(90, xs.max, ys.max, depth) + 0.000001 then -- 350
				depth = near -- 352
				height = math.max( -- 353
					0, -- 353
					math.min(2, mid.y + dy * depth) -- 353
				) -- 353
			end -- 353
		end -- 353
		local bx = p.room.basinX -- 356
		if bx ~= nil then -- 356
			local ox = mid.x - bx -- 359
			local a = dx * dx + 1 -- 360
			local b = ox * dx - BASIN_DEPTH -- 361
			local function intersectBasin(radius, bottom, top) -- 362
				local disc = b * b - a * (ox * ox + BASIN_DEPTH * BASIN_DEPTH - radius * radius) -- 363
				if disc < 0 then -- 363
					return -- 364
				end -- 364
				local span = math.sqrt(disc) -- 365
				local ys = rayInterval(mid.y, dy, bottom, top) -- 366
				local near = math.max((-b - span) / a, ys.min) -- 367
				if near <= math.min((-b + span) / a, ys.max, depth) + 0.000001 then -- 367
					depth = near -- 369
					height = math.max( -- 370
						bottom, -- 370
						math.min(top, mid.y + dy * depth) -- 370
					) -- 370
					hitBasin = true -- 371
				end -- 371
			end -- 362
			intersectBasin(19, 0, 10) -- 374
			intersectBasin(16.8, BASIN_BASE_HEIGHT, BASIN_BASE_HEIGHT + 11.2) -- 375
		end -- 375
		return {x = mid.x + dx * depth, y = height, depth = depth, hitBasin = hitBasin} -- 377
	end -- 335
	Director.entry:addChild(self.root) -- 87
	self.root.visible = false -- 88
	self.actor = __TS__New(Xiaoman3DActor, self.root) -- 90
	self.entities = __TS__New(Xiaoman3DEntities, self.root) -- 91
	local content = Node() -- 94
	content:addChild(self.glow) -- 95
	local effects = Surface3D( -- 96
		content, -- 96
		Size(20, 5), -- 96
		Size(2000, 500) -- 96
	) -- 96
	if effects == nil then -- 96
		error("Surface3D effects creation failed") -- 97
	end -- 97
	effects.scaleX = -1 -- 98
	self.effects = effects -- 99
	self.root:addChild(effects) -- 100
	local gContent = Node() -- 103
	gContent:addChild(self.groundFx) -- 104
	local gSurf = Surface3D( -- 105
		gContent, -- 105
		Size(20, 4), -- 105
		Size(2000, 400) -- 105
	) -- 105
	if gSurf == nil then -- 105
		error("Surface3D groundFx creation failed") -- 106
	end -- 106
	gSurf.angles = Vec3(90, 0, 0) -- 107
	gSurf.scaleX = -1 -- 108
	self.groundSurface = gSurf -- 109
	self.root:addChild(gSurf) -- 110
	host:onCleanup(function() -- 112
		self:hide() -- 113
		self.root:removeFromParent() -- 114
	end) -- 112
end -- 86
function Xiaoman3DScene.prototype.supports(self, p, visualMode) -- 118
	return visualMode == "lowpoly" and ROOM_MODELS[p.room.key] ~= nil -- 119
end -- 118
function Xiaoman3DScene.prototype.configureEnvironment(self) -- 122
	if self.envConfigured then -- 122
		return -- 124
	end -- 124
	local v3 = getView3D() -- 126
	if v3.setEnvironmentMap ~= nil then -- 126
		v3:setEnvironmentMap("") -- 128
	end -- 128
	if v3.setEnvironmentIntensity ~= nil then -- 128
		v3:setEnvironmentIntensity(0.24, 0.18, 1.02) -- 132
	end -- 132
	v3.shadowMapSize = 1024 -- 134
	self.envConfigured = true -- 135
end -- 122
function Xiaoman3DScene.prototype.restoreEnvironment(self) -- 138
	if not self.envConfigured then -- 138
		return -- 140
	end -- 140
	local v3 = getView3D() -- 142
	if v3.setEnvironmentIntensity ~= nil then -- 142
		v3:setEnvironmentIntensity(1, 1, 1) -- 144
	end -- 144
	self.envConfigured = false -- 146
end -- 138
function Xiaoman3DScene.prototype.hide(self) -- 149
	if self.p ~= nil then -- 149
		self.p.bottleMapper = nil -- 150
	end -- 150
	self.root.visible = false -- 151
	self.actor:hide() -- 152
	self.entities:hide() -- 153
	self:restoreEnvironment() -- 154
	if self.active then -- 154
		Director:removeCamera(self.camera) -- 156
		self.active = false -- 157
	end -- 157
end -- 149
function Xiaoman3DScene.prototype.render(self, p, cam, actors, dt, w, h, vp, overlay) -- 161
	self.p = p -- 162
	local safeDt = p.paused and 0 or dt -- 163
	self.time = self.time + safeDt -- 164
	if self.room ~= p.room.key then -- 164
		if self.model ~= nil then -- 164
			self.root:removeChild(self.model) -- 168
			self.model = nil -- 169
		end -- 169
		local loaded = Model3D(ROOM_MODELS[p.room.key]) -- 171
		if loaded.parent ~= nil then -- 171
			loaded:removeFromParent(false) -- 173
		end -- 173
		self.model = loaded -- 175
		self.root:addChild(loaded) -- 176
		self.room = p.room.key -- 177
	end -- 177
	local centerX = (p.room.minX + p.room.maxX) / 2 -- 181
	self.glow.x = -centerX -- 182
	self.effects.position = Vec3(centerX / 100, 0, -p.player.depth / 100 + 0.02) -- 183
	self.groundFx.x = -centerX -- 184
	self.groundFx.y = 0 -- 185
	self.groundSurface.position = Vec3(centerX / 100, 0.015, 0) -- 186
	if self.model ~= nil then -- 186
		self.model.position = Vec3(p.ox / 100, 0, 0) -- 189
	end -- 189
	self:configureEnvironment() -- 192
	if not self.active then -- 192
		Director:pushCamera(self.camera) -- 194
		self.active = true -- 195
	end -- 195
	self.root.visible = true -- 197
	self:updateCamera( -- 199
		p, -- 199
		cam, -- 199
		w, -- 199
		h, -- 199
		vp -- 199
	) -- 199
	cam.projection = self -- 200
	if p.room.key == "village" then -- 200
		p.bottleMapper = self.villageBottlePoint -- 201
	end -- 201
	self.glow:clear() -- 203
	self.groundFx:clear() -- 204
	for key in pairs(self.shadows) do -- 207
		self.shadows[key].visible = false -- 208
	end -- 208
	local a = p.player -- 210
	if a.alive then -- 210
		local ground = actors:supportGroundY(p, a) -- 212
		self:placeShadow( -- 213
			"child", -- 213
			a.x, -- 213
			ground, -- 213
			a.depth, -- 213
			a.w * 0.56, -- 213
			10, -- 213
			math.max(0.24, 0.92 - (a.y - ground) / 170) -- 214
		) -- 214
	end -- 214
	if p.room.scavenger ~= nil then -- 214
		self:placeShadow( -- 217
			"scavenger", -- 217
			p.scavX, -- 217
			p.room.scavenger.y, -- 217
			0, -- 217
			17, -- 217
			10, -- 217
			0.85 -- 217
		) -- 217
	end -- 217
	if p.room.key == "forest" then -- 217
		self:placeShadow( -- 220
			"dog", -- 220
			p.dogX, -- 220
			0, -- 220
			6, -- 220
			20, -- 220
			9, -- 220
			0.82 -- 220
		) -- 220
	end -- 220
	self.actor:update(p, safeDt) -- 224
	self.entities:update( -- 225
		p, -- 225
		safeDt, -- 225
		cam.x, -- 225
		self.glow, -- 225
		self.groundFx, -- 225
		overlay, -- 225
		self -- 225
	) -- 225
	self:drawBottleAimPreview(p, overlay) -- 227
end -- 161
function Xiaoman3DScene.prototype.drawBottleAimPreview(self, p, overlay) -- 230
	if not p.hasBottle or p.aimHold <= 0 or p.bottleAimX < 0 then -- 230
		return -- 232
	end -- 232
	local endX = p.bottleAimX -- 234
	local endY = p.bottleAimY -- 235
	local x0 = p.player.x + (endX >= p.player.x and 10 or -10) -- 236
	local y0 = p.player.y + p.player.h * 0.7 -- 237
	local duration = BOTTLE_FLY_TIME -- 238
	local vx = (endX - x0) / duration -- 239
	local vy = (endY - y0 + 0.5 * GRAVITY * duration * duration) / duration -- 240
	local i = 1 -- 241
	do -- 241
		i = 1 -- 242
		while i <= 18 do -- 242
			local t = i / 18 * duration -- 243
			local depth = p.player.depth + (p.bottleAimDepth - p.player.depth) * (t / duration) -- 244
			local x = x0 + vx * t -- 245
			local y = y0 + vy * t - 0.5 * GRAVITY * t * t -- 246
			local pt = self:worldToScreen(x, y, depth) -- 247
			local edge = self:worldToScreen(x + 1.4, y, depth) -- 248
			overlay:drawDot( -- 249
				Vec2(pt.x, pt.y), -- 249
				edge.x - pt.x, -- 249
				Color(246, 220, 152, 224) -- 249
			) -- 249
			i = i + 1 -- 242
		end -- 242
	end -- 242
	local ____end = self:worldToScreen(endX, endY, p.bottleAimDepth) -- 251
	local radius = self:worldToScreen(endX + 9, endY, p.bottleAimDepth).x - ____end.x -- 252
	overlay:drawEllipse( -- 253
		Vec2(____end.x, ____end.y), -- 253
		radius, -- 253
		radius * 0.27, -- 253
		Color(246, 220, 152, 190) -- 253
	) -- 253
end -- 230
function Xiaoman3DScene.prototype.placeShadow(self, key, x, y, depth, rx, rz, opacity) -- 256
	if opacity == nil then -- 256
		opacity = 1 -- 256
	end -- 256
	local surface = self.shadows[key] -- 257
	if surface == nil then -- 257
		local content = DrawNode() -- 259
		content:drawCircle( -- 260
			Vec2(0, 0), -- 260
			50, -- 260
			Color(8, 10, 14, 138) -- 260
		) -- 260
		local created = Surface3D( -- 261
			content, -- 261
			Size(1, 1), -- 261
			Size(100, 100) -- 261
		) -- 261
		if created == nil then -- 261
			error("Surface3D shadow creation failed") -- 262
		end -- 262
		surface = created -- 263
		surface.angles = Vec3(90, 0, 0) -- 264
		self.root:addChild(surface) -- 265
		self.shadows[key] = surface -- 266
	end -- 266
	surface.visible = true -- 268
	surface.content.opacity = opacity -- 269
	surface.scale = Vec3(rx / 50, rz / 50, 1) -- 270
	surface.position = Vec3(x / 100, (y + 0.7) / 100, -depth / 100) -- 271
end -- 256
function Xiaoman3DScene.prototype.updateCamera(self, p, cam, w, h, vp) -- 274
	self.fullW = View.size.width -- 275
	self.fullH = View.size.height -- 276
	self.stageX = vp.stageX -- 277
	self.stageY = vp.stageY -- 278
	self.focal = self.fullH / (2 * math.tan(View.fieldOfView * math.pi / 360)) -- 279
	local baseDist = p.room.key == "village" and 3.9 or (p.room.key == "tower" and 4.1 or 4.25) -- 282
	local riseRatio = p.room.key == "village" and 0.16 or 0.21 -- 283
	local baseTargetY = p.room.key == "village" and 0.68 or 0.82 -- 284
	local distance = baseDist / cam.zoom * self.fullH / h -- 286
	local rise = distance * riseRatio -- 287
	local length = math.sqrt(distance * distance + rise * rise) -- 288
	self.pitchSin = rise / length -- 289
	self.pitchCos = distance / length -- 290
	local offsetX = (vp.stageX + w / 2 - self.fullW / 2) * length / self.focal -- 292
	local offsetY = (vp.stageY + h / 2 - self.fullH / 2) * length / self.focal -- 293
	local ____opt_0 = p.room.story -- 293
	local towerDoor = ____opt_0 and ____opt_0.tower -- 294
	local focusWorldX = cam.x / 100 -- 295
	if towerDoor ~= nil then -- 295
		local doorX = towerDoor.doorX -- 297
		local across = math.max( -- 299
			0, -- 299
			math.min(1, (p.player.x - doorX) / 95) -- 299
		) -- 299
		focusWorldX = (p.player.x + doorX) / 200 + 0.74 * across -- 300
	end -- 300
	local tx = focusWorldX - offsetX -- 302
	local ty = baseTargetY + (cam.y - 82) * 0.0045 - offsetY * self.pitchCos -- 303
	local tz = -p.player.depth * 0.0035 + offsetY * self.pitchSin -- 305
	self.cameraX = tx -- 307
	self.cameraY = ty + rise -- 308
	self.cameraZ = tz + distance -- 309
	self.camera:lookAt( -- 310
		Vec3(self.cameraX, self.cameraY, self.cameraZ), -- 310
		Vec3(tx, ty, tz) -- 310
	) -- 310
end -- 274
function Xiaoman3DScene.prototype.worldToScreen(self, x, y, depth) -- 313
	if depth == nil then -- 313
		depth = 0 -- 313
	end -- 313
	local dx = x / 100 - self.cameraX -- 314
	local dy = y / 100 - self.cameraY -- 315
	local dz = -depth / 100 - self.cameraZ -- 316
	local forward = -dy * self.pitchSin - dz * self.pitchCos -- 317
	return {x = self.fullW / 2 + dx * self.focal / forward - self.stageX, y = self.fullH / 2 + (dy * self.pitchCos - dz * self.pitchSin) * self.focal / forward - self.stageY} -- 318
end -- 313
function Xiaoman3DScene.prototype.screenToWorld(self, x, y, depth) -- 324
	if depth == nil then -- 324
		local ____opt_2 = self.p -- 324
		depth = ____opt_2 and ____opt_2.player.depth or 0 -- 324
	end -- 324
	local u = (x + self.stageX - self.fullW / 2) / self.focal -- 325
	local v = (y + self.stageY - self.fullH / 2) / self.focal -- 326
	local rayY = v * self.pitchCos - self.pitchSin -- 327
	local rayZ = -v * self.pitchSin - self.pitchCos -- 328
	local z = -depth / 100 -- 329
	local t = (z - self.cameraZ) / rayZ -- 330
	return {x = (self.cameraX + u * t) * 100, y = (self.cameraY + rayY * t) * 100} -- 331
end -- 324
function Xiaoman3DScene.prototype.getDebugState(self) -- 380
	local v3 = getView3D() -- 381
	local stats = v3.stats -- 382
	return { -- 383
		active = self.active, -- 384
		room = self.room, -- 385
		actor = self.actor:getDebugState(self.p), -- 386
		entities = self.entities:getDebugState(), -- 387
		cameraPos = {x = self.cameraX, y = self.cameraY, z = self.cameraZ}, -- 388
		drawCalls = stats ~= nil and stats.drawCalls or 0, -- 389
		visibleModels = stats ~= nil and stats.visibleModels or 0 -- 390
	} -- 390
end -- 380
return ____exports -- 380