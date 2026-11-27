-- [ts]: xiaoman3d.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Camera3D = ____Dora.Camera3D -- 1
local Color = ____Dora.Color -- 1
local Color3 = ____Dora.Color3 -- 1
local Director = ____Dora.Director -- 1
local DirectionalLight3D = ____Dora.DirectionalLight3D -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Model3D = ____Dora.Model3D -- 1
local Node = ____Dora.Node -- 1
local Node3D = ____Dora.Node3D -- 1
local Size = ____Dora.Size -- 1
local Surface3D = ____Dora.Surface3D -- 1
local Vec2 = ____Dora.Vec2 -- 1
local Vec3 = ____Dora.Vec3 -- 1
local View = ____Dora.View -- 1
local ____play = require("Script.watch.play") -- 2
local GRAVITY = ____play.GRAVITY -- 2
local ____depth = require("Script.watch.depth") -- 3
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 3
local ____assets = require("Script.watch.fe.assets") -- 5
local AssetSlotHost = ____assets.AssetSlotHost -- 5
local ____camera = require("Script.watch.fe.camera") -- 6
local CameraDirector = ____camera.CameraDirector -- 6
local ROOM_MODELS = {outside = "assets/xiaoman3d/outside.glb", village = "assets/xiaoman3d/village.glb", forest = "assets/xiaoman3d/forest.glb", tower = "assets/xiaoman3d/tower.glb"} -- 9
--- GLB coordinates stay Y-up. Collision and interaction authority stays in rooms.ts/Play.
____exports.Xiaoman3DScene = __TS__Class() -- 17
local Xiaoman3DScene = ____exports.Xiaoman3DScene -- 17
Xiaoman3DScene.name = "Xiaoman3DScene" -- 17
function Xiaoman3DScene.prototype.____constructor(self, host) -- 43
	self.root = Node3D() -- 18
	self.camera = Camera3D("xiaoman-follow") -- 19
	self.room = "" -- 21
	self.active = false -- 22
	self.surfaces = {} -- 23
	self.shadows = {} -- 24
	self.localCam = __TS__New(CameraDirector) -- 26
	self.scratch = DrawNode() -- 27
	self.glow = DrawNode() -- 28
	self.depths = {} -- 30
	self.focal = 1 -- 31
	self.stageX = 0 -- 32
	self.stageY = 0 -- 33
	self.fullW = 1280 -- 34
	self.fullH = 720 -- 35
	self.pitchSin = 0 -- 36
	self.pitchCos = 1 -- 37
	self.cameraX = 0 -- 38
	self.cameraY = 0 -- 39
	self.cameraZ = 0 -- 40
	self.time = 0 -- 41
	Director.entry:addChild(self.root) -- 44
	self.root.visible = false -- 45
	local sun = DirectionalLight3D() -- 46
	sun.color = Color3(229, 233, 242) -- 47
	sun.intensity = 2.2 -- 48
	sun.angles = Vec3(-48, -25, 0) -- 49
	self.root:addChild(sun) -- 50
	local fill = DirectionalLight3D() -- 51
	fill.color = Color3(210, 216, 226) -- 52
	fill.intensity = 0.8 -- 53
	fill.angles = Vec3(35, 150, 0) -- 54
	self.root:addChild(fill) -- 55
	local effects = Surface3D( -- 56
		self.glow, -- 56
		Size(20, 5), -- 56
		Size(2000, 500) -- 56
	) -- 56
	if effects == nil then -- 56
		error("Surface3D effects creation failed") -- 57
	end -- 57
	effects.scaleX = -1 -- 58
	effects.position = Vec3(0, 0, 0.015) -- 59
	self.root:addChild(effects) -- 60
	self.assets = __TS__New( -- 61
		AssetSlotHost, -- 61
		Node(), -- 61
		0, -- 61
		function(sprite, key, instance, x, y) return self:placeSprite( -- 61
			sprite, -- 61
			key, -- 61
			instance, -- 61
			x, -- 61
			y -- 61
		) end -- 61
	) -- 61
	self.localCam.x = 0 -- 63
	self.localCam.y = 82 -- 64
	self.localCam.viewW = 0 -- 65
	self.localCam.ppu = 1 -- 66
	self.localCam.groundScreenY = 0 -- 67
	host:onCleanup(function() -- 68
		self:hide() -- 69
		self.root:removeFromParent() -- 70
	end) -- 68
end -- 43
function Xiaoman3DScene.prototype.supports(self, p, visualMode) -- 74
	return visualMode == "lowpoly" and ROOM_MODELS[p.room.key] ~= nil -- 75
end -- 74
function Xiaoman3DScene.prototype.hide(self) -- 78
	self.root.visible = false -- 79
	if self.active then -- 79
		Director:removeCamera(self.camera) -- 81
		self.active = false -- 82
	end -- 82
end -- 78
function Xiaoman3DScene.prototype.render(self, p, cam, actors, dt, w, h, vp) -- 86
	self.p = p -- 87
	self.time = self.time + dt -- 88
	if self.room ~= p.room.key then -- 88
		if self.model ~= nil then -- 88
			self.root:removeChild(self.model) -- 90
		end -- 90
		self.model = Model3D(ROOM_MODELS[p.room.key]) -- 91
		self.root:addChild(self.model) -- 92
		self.room = p.room.key -- 93
	end -- 93
	if self.model ~= nil then -- 93
		self.model.position = Vec3(p.ox / 100, 0, 0) -- 96
	end -- 96
	if not self.active then -- 96
		Director:pushCamera(self.camera) -- 98
		self.active = true -- 99
	end -- 99
	self.root.visible = true -- 101
	self:updateCamera(cam, w, h, vp) -- 102
	cam.projection = self -- 103
	self.depths = {actor_child = p.player.depth, actor_scav = 0, actor_dog = 0} -- 104
	self.assets:beginFrame() -- 105
	self.scratch:clear() -- 106
	self.glow:clear() -- 107
	for key in pairs(self.shadows) do -- 108
		self.shadows[key].visible = false -- 108
	end -- 108
	local a = p.player -- 109
	if a.alive then -- 109
		local ground = actors:supportGroundY(p, a) -- 111
		self:placeShadow( -- 112
			"child", -- 112
			a.x, -- 112
			ground, -- 112
			a.depth, -- 112
			a.w * 0.48, -- 112
			7, -- 112
			math.max(0.2, 1 - (a.y - ground) / 180) -- 113
		) -- 113
	end -- 113
	if p.room.scavenger ~= nil then -- 113
		self:placeShadow( -- 116
			"scavenger", -- 116
			p.scavX, -- 116
			p.room.scavenger.y, -- 116
			0, -- 116
			15, -- 116
			8 -- 116
		) -- 116
	end -- 116
	if p.room.key == "forest" then -- 116
		self:placeShadow( -- 118
			"dog", -- 118
			p.dogX, -- 118
			0, -- 118
			0, -- 118
			19, -- 118
			7 -- 118
		) -- 118
	end -- 118
	actors:drawAll( -- 119
		self.scratch, -- 119
		self.glow, -- 119
		self.assets, -- 119
		p, -- 119
		self.localCam -- 119
	) -- 119
	self:drawProps(p) -- 120
	self.assets:endFrame() -- 121
end -- 86
function Xiaoman3DScene.prototype.placeSprite(self, sprite, key, instance, x, y) -- 124
	local surface = self.surfaces[key] -- 125
	if surface == nil then -- 125
		local content = Node() -- 127
		local created = Surface3D( -- 128
			content, -- 128
			Size(4, 4), -- 128
			Size(400, 400) -- 128
		) -- 128
		if created == nil then -- 128
			error("Surface3D creation failed for " .. key) -- 129
		end -- 129
		surface = created -- 130
		surface.scaleX = -1 -- 132
		sprite:removeFromParent(false) -- 133
		content:addChild(sprite) -- 134
		self.root:addChild(surface) -- 135
		self.surfaces[key] = surface -- 136
	end -- 136
	local depth = self.depths[instance] or 0 -- 138
	surface.position = Vec3(x / 100, (y - depth * DEPTH_Y_SCALE) / 100, -depth / 100) -- 139
	sprite.position = Vec2(0, 0) -- 140
end -- 124
function Xiaoman3DScene.prototype.placeShadow(self, key, x, y, depth, rx, rz, opacity) -- 143
	if opacity == nil then -- 143
		opacity = 1 -- 143
	end -- 143
	local surface = self.shadows[key] -- 144
	if surface == nil then -- 144
		local content = DrawNode() -- 146
		content:drawCircle( -- 147
			Vec2(0, 0), -- 147
			50, -- 147
			Color(16, 17, 20, 100) -- 147
		) -- 147
		local created = Surface3D( -- 148
			content, -- 148
			Size(1, 1), -- 148
			Size(100, 100) -- 148
		) -- 148
		if created == nil then -- 148
			error("Surface3D shadow creation failed") -- 149
		end -- 149
		surface = created -- 150
		surface.angles = Vec3(90, 0, 0) -- 151
		self.root:addChild(surface) -- 152
		self.shadows[key] = surface -- 153
	end -- 153
	surface.visible = true -- 155
	surface.content.opacity = opacity -- 156
	surface.scale = Vec3(rx / 50, rz / 50, 1) -- 157
	surface.position = Vec3(x / 100, (y + 0.6) / 100, -depth / 100) -- 158
end -- 143
function Xiaoman3DScene.prototype.drawProps(self, p) -- 161
	local c = p.room.cart -- 162
	if c.bodyW > 0 then -- 162
		local d = c.depth or 0 -- 164
		self.depths.cart = d -- 165
		self.depths.cart_cloth = d - 1 -- 166
		self.assets:tryPlace( -- 167
			"prop_cart", -- 167
			"cart", -- 167
			p.cartAxle, -- 167
			c.baseY + d * DEPTH_Y_SCALE, -- 167
			c.bodyW * 1.38, -- 168
			(c.wheelR * 2 + c.bodyH) * 0.94 -- 168
		) -- 168
		self.assets:tryPlace( -- 169
			"fe_red_cloth", -- 169
			"cart_cloth", -- 169
			p.cartAxle - c.bodyW / 2 + 2, -- 169
			c.baseY + c.wheelR + c.bodyH - 2 + (d - 1) * DEPTH_Y_SCALE, -- 170
			24, -- 170
			24, -- 170
			{frame = math.floor(self.time * 6) % 3} -- 171
		) -- 171
	end -- 171
	for ____, box in ipairs(p.boxes) do -- 173
		if box.id == "outside_red_cart" and not box.broken then -- 173
			self.assets:tryPlace( -- 175
				"prop_cart", -- 175
				"red_cart", -- 175
				(box.x0 + box.x1) / 2, -- 175
				box.y0, -- 175
				box.x1 - box.x0, -- 175
				box.y1 - box.y0 -- 175
			) -- 175
			self.assets:tryPlace( -- 176
				"fe_red_cloth", -- 176
				"red_cart_cloth", -- 176
				box.x0 + 4, -- 176
				box.y1 - 3, -- 176
				22, -- 176
				22, -- 176
				{frame = math.floor(self.time * 6) % 3} -- 177
			) -- 177
		end -- 177
	end -- 177
	if p.room.key == "village" then -- 177
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 and p.room.bottle ~= nil then -- 177
			self.assets:tryPlace( -- 182
				"prop_bottle", -- 182
				"bottle_shelf", -- 182
				p.room.bottle.x, -- 182
				p.room.bottle.y, -- 182
				14, -- 182
				14 -- 182
			) -- 182
		end -- 182
		if p.hasBottle and p.aimHold <= 0 then -- 182
			local a = p.player -- 185
			self.depths.bottle_held = a.depth - 1 -- 186
			self.assets:tryPlace( -- 187
				"prop_bottle", -- 187
				"bottle_held", -- 187
				a.x + a.facing * 10, -- 187
				a.y + a.h * 0.52 + (a.depth - 1) * DEPTH_Y_SCALE, -- 188
				14, -- 188
				14 -- 188
			) -- 188
		end -- 188
		if p.bottleFly ~= nil then -- 188
			self.assets:tryPlace( -- 191
				"prop_bottle", -- 191
				"bottle_air", -- 191
				p.bottleFly.x, -- 191
				p.bottleFly.y, -- 191
				14, -- 191
				14, -- 191
				{angle = self.time * 360} -- 192
			) -- 192
		end -- 192
	end -- 192
	if p.hasBottle and p.aimHold > 0 and p.bottleAimX >= 0 then -- 192
		local endX = p.bottleAimX -- 196
		local endY = p.bottleAimY -- 197
		local x0 = p.player.x + (endX >= p.player.x and 10 or -10) -- 198
		local y0 = p.player.y + p.player.h * 0.7 -- 199
		local duration = 0.62 -- 200
		local vx = (endX - x0) / duration -- 201
		local vy = (endY - y0 + 0.5 * GRAVITY * duration * duration) / duration -- 202
		do -- 202
			local i = 1 -- 203
			while i <= 18 do -- 203
				local t = i / 18 * duration -- 204
				self.glow:drawDot( -- 205
					Vec2(x0 + vx * t, y0 + vy * t - 0.5 * GRAVITY * t * t), -- 205
					1.2, -- 205
					Color(229, 206, 148, 210) -- 206
				) -- 206
				i = i + 1 -- 203
			end -- 203
		end -- 203
		self.glow:drawEllipse( -- 208
			Vec2(endX, endY + 1), -- 208
			8, -- 208
			2, -- 208
			Color(229, 206, 148, 170) -- 208
		) -- 208
	end -- 208
	if p.room.key == "tower" then -- 208
		if not p.towerDoorOpen then -- 208
			self.assets:tryPlace( -- 212
				"prop_tower_door", -- 212
				"tower_door", -- 212
				p.ox + 450, -- 212
				0, -- 212
				40, -- 212
				110 -- 212
			) -- 212
		else -- 212
			self.depths.tower_guard = 38 -- 214
			local writing = p.deskHold >= 24 or p.towerHanded -- 215
			self.assets:tryPlacePath( -- 216
				writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern", -- 216
				"tower_guard", -- 217
				p.ox + 626, -- 218
				38 * DEPTH_Y_SCALE, -- 218
				54, -- 218
				82, -- 218
				{anchorX = 0.44, anchorY = 0, preserveAspect = true, facing = -1} -- 219
			) -- 219
			self.depths.desk_lamp = 22 -- 220
			self.assets:tryPlace( -- 221
				"prop_lantern", -- 221
				"desk_lamp", -- 221
				p.ox + 639, -- 221
				35 + 22 * DEPTH_Y_SCALE, -- 221
				18, -- 221
				30 -- 221
			) -- 221
		end -- 221
	end -- 221
end -- 161
function Xiaoman3DScene.prototype.updateCamera(self, cam, w, h, vp) -- 226
	self.fullW = View.size.width -- 227
	self.fullH = View.size.height -- 228
	self.stageX = vp.stageX -- 229
	self.stageY = vp.stageY -- 230
	self.focal = self.fullH / (2 * math.tan(View.fieldOfView * math.pi / 360)) -- 231
	local distance = 4.25 / cam.zoom * self.fullH / h -- 232
	local rise = distance * 0.19 -- 233
	local length = math.sqrt(distance * distance + rise * rise) -- 234
	self.pitchSin = rise / length -- 235
	self.pitchCos = distance / length -- 236
	local offsetX = (vp.stageX + w / 2 - self.fullW / 2) * length / self.focal -- 237
	local offsetY = (vp.stageY + h / 2 - self.fullH / 2) * length / self.focal -- 238
	local tx = cam.x / 100 - offsetX -- 239
	local ty = 0.85 + (cam.y - 82) * 0.0045 - offsetY * self.pitchCos -- 240
	local tz = offsetY * self.pitchSin -- 241
	self.cameraX = tx -- 242
	self.cameraY = ty + rise -- 243
	self.cameraZ = tz + distance -- 244
	self.camera:lookAt( -- 245
		Vec3(self.cameraX, self.cameraY, self.cameraZ), -- 245
		Vec3(tx, ty, tz) -- 245
	) -- 245
end -- 226
function Xiaoman3DScene.prototype.worldToScreen(self, x, y, depth) -- 248
	if depth == nil then -- 248
		depth = 0 -- 248
	end -- 248
	local dx = x / 100 - self.cameraX -- 249
	local dy = y / 100 - self.cameraY -- 250
	local dz = -depth / 100 - self.cameraZ -- 251
	local forward = -dy * self.pitchSin - dz * self.pitchCos -- 252
	return {x = self.fullW / 2 + dx * self.focal / forward - self.stageX, y = self.fullH / 2 + (dy * self.pitchCos - dz * self.pitchSin) * self.focal / forward - self.stageY} -- 253
end -- 248
function Xiaoman3DScene.prototype.screenToWorld(self, x, y) -- 259
	local u = (x + self.stageX - self.fullW / 2) / self.focal -- 260
	local v = (y + self.stageY - self.fullH / 2) / self.focal -- 261
	local rayY = v * self.pitchCos - self.pitchSin -- 262
	local rayZ = -v * self.pitchSin - self.pitchCos -- 263
	local ____opt_0 = self.p -- 263
	local z = -(____opt_0 and ____opt_0.player.depth or 0) / 100 -- 265
	local t = (z - self.cameraZ) / rayZ -- 266
	return {x = (self.cameraX + u * t) * 100, y = (self.cameraY + rayY * t) * 100} -- 267
end -- 259
return ____exports -- 259