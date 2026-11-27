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
local Rect = ____Dora.Rect -- 1
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
function Xiaoman3DScene.prototype.____constructor(self, host) -- 44
	self.root = Node3D() -- 18
	self.camera = Camera3D("xiaoman-follow") -- 19
	self.room = "" -- 21
	self.active = false -- 22
	self.surfaces = {} -- 23
	self.shadows = {} -- 24
	self.localCam = __TS__New(CameraDirector) -- 26
	self.scratch = DrawNode() -- 27
	self.glow = DrawNode() -- 28
	self.depths = {} -- 31
	self.focal = 1 -- 32
	self.stageX = 0 -- 33
	self.stageY = 0 -- 34
	self.fullW = 1280 -- 35
	self.fullH = 720 -- 36
	self.pitchSin = 0 -- 37
	self.pitchCos = 1 -- 38
	self.cameraX = 0 -- 39
	self.cameraY = 0 -- 40
	self.cameraZ = 0 -- 41
	self.time = 0 -- 42
	Director.entry:addChild(self.root) -- 45
	self.root.visible = false -- 46
	local sun = DirectionalLight3D() -- 47
	sun.color = Color3(229, 233, 242) -- 48
	sun.intensity = 2.2 -- 49
	sun.angles = Vec3(-48, -25, 0) -- 50
	self.root:addChild(sun) -- 51
	local fill = DirectionalLight3D() -- 52
	fill.color = Color3(210, 216, 226) -- 53
	fill.intensity = 0.8 -- 54
	fill.angles = Vec3(35, 150, 0) -- 55
	self.root:addChild(fill) -- 56
	local content = Node() -- 57
	content:addChild(self.glow) -- 58
	local effects = Surface3D( -- 59
		content, -- 59
		Size(20, 5), -- 59
		Size(2000, 500) -- 59
	) -- 59
	if effects == nil then -- 59
		error("Surface3D effects creation failed") -- 60
	end -- 60
	effects.scaleX = -1 -- 61
	self.effects = effects -- 62
	self.root:addChild(effects) -- 63
	self.assets = __TS__New( -- 64
		AssetSlotHost, -- 64
		Node(), -- 64
		0, -- 64
		function(sprite, key, instance, x, y) return self:placeSprite( -- 64
			sprite, -- 64
			key, -- 64
			instance, -- 64
			x, -- 64
			y -- 64
		) end -- 64
	) -- 64
	self.localCam.x = 0 -- 66
	self.localCam.y = 82 -- 67
	self.localCam.viewW = 0 -- 68
	self.localCam.ppu = 1 -- 69
	self.localCam.groundScreenY = 0 -- 70
	host:onCleanup(function() -- 71
		self:hide() -- 72
		self.root:removeFromParent() -- 73
	end) -- 71
end -- 44
function Xiaoman3DScene.prototype.supports(self, p, visualMode) -- 77
	return visualMode == "lowpoly" and ROOM_MODELS[p.room.key] ~= nil -- 78
end -- 77
function Xiaoman3DScene.prototype.hide(self) -- 81
	self.root.visible = false -- 82
	if self.active then -- 82
		Director:removeCamera(self.camera) -- 84
		self.active = false -- 85
	end -- 85
end -- 81
function Xiaoman3DScene.prototype.render(self, p, cam, actors, dt, w, h, vp) -- 89
	self.p = p -- 90
	self.time = self.time + dt -- 91
	if self.room ~= p.room.key then -- 91
		if self.model ~= nil then -- 91
			self.root:removeChild(self.model) -- 93
		end -- 93
		self.model = Model3D(ROOM_MODELS[p.room.key]) -- 94
		self.root:addChild(self.model) -- 95
		self.room = p.room.key -- 96
	end -- 96
	local centerX = (p.room.minX + p.room.maxX) / 2 -- 100
	self.glow.x = -centerX -- 101
	self.effects.position = Vec3(centerX / 100, 0, 0.015) -- 102
	if self.model ~= nil then -- 102
		self.model.position = Vec3(p.ox / 100, 0, 0) -- 103
	end -- 103
	if not self.active then -- 103
		Director:pushCamera(self.camera) -- 105
		self.active = true -- 106
	end -- 106
	self.root.visible = true -- 108
	self:updateCamera(cam, w, h, vp) -- 109
	cam.projection = self -- 110
	self.depths = {actor_child = p.player.depth, actor_scav = 0, actor_dog = 0} -- 111
	self.assets:beginFrame() -- 112
	self.scratch:clear() -- 113
	self.glow:clear() -- 114
	for key in pairs(self.shadows) do -- 115
		self.shadows[key].visible = false -- 115
	end -- 115
	local a = p.player -- 116
	if a.alive then -- 116
		local ground = actors:supportGroundY(p, a) -- 118
		self:placeShadow( -- 119
			"child", -- 119
			a.x, -- 119
			ground, -- 119
			a.depth, -- 119
			a.w * 0.48, -- 119
			7, -- 119
			math.max(0.2, 1 - (a.y - ground) / 180) -- 120
		) -- 120
	end -- 120
	if p.room.scavenger ~= nil then -- 120
		self:placeShadow( -- 123
			"scavenger", -- 123
			p.scavX, -- 123
			p.room.scavenger.y, -- 123
			0, -- 123
			15, -- 123
			8 -- 123
		) -- 123
	end -- 123
	if p.room.key == "forest" then -- 123
		self:placeShadow( -- 125
			"dog", -- 125
			p.dogX, -- 125
			0, -- 125
			0, -- 125
			19, -- 125
			7 -- 125
		) -- 125
	end -- 125
	actors:drawAll( -- 126
		self.scratch, -- 126
		self.glow, -- 126
		self.assets, -- 126
		p, -- 126
		self.localCam -- 126
	) -- 126
	self:drawProps(p) -- 127
	self.assets:endFrame() -- 128
end -- 89
function Xiaoman3DScene.prototype.placeSprite(self, sprite, key, instance, x, y) -- 131
	local surface = self.surfaces[key] -- 132
	if surface == nil then -- 132
		local content = Node() -- 134
		local created = Surface3D( -- 135
			content, -- 135
			Size(4, 4), -- 135
			Size(400, 400) -- 135
		) -- 135
		if created == nil then -- 135
			error("Surface3D creation failed for " .. key) -- 136
		end -- 136
		surface = created -- 137
		surface.scaleX = -1 -- 139
		sprite:removeFromParent(false) -- 140
		content:addChild(sprite) -- 141
		self.root:addChild(surface) -- 142
		self.surfaces[key] = surface -- 143
	end -- 143
	local depth = self.depths[instance] or 0 -- 145
	surface.position = Vec3(x / 100, (y - depth * DEPTH_Y_SCALE) / 100, -depth / 100) -- 146
	sprite.position = Vec2(0, 0) -- 147
end -- 131
function Xiaoman3DScene.prototype.placeShadow(self, key, x, y, depth, rx, rz, opacity) -- 150
	if opacity == nil then -- 150
		opacity = 1 -- 150
	end -- 150
	local surface = self.shadows[key] -- 151
	if surface == nil then -- 151
		local content = DrawNode() -- 153
		content:drawCircle( -- 154
			Vec2(0, 0), -- 154
			50, -- 154
			Color(16, 17, 20, 100) -- 154
		) -- 154
		local created = Surface3D( -- 155
			content, -- 155
			Size(1, 1), -- 155
			Size(100, 100) -- 155
		) -- 155
		if created == nil then -- 155
			error("Surface3D shadow creation failed") -- 156
		end -- 156
		surface = created -- 157
		surface.angles = Vec3(90, 0, 0) -- 158
		self.root:addChild(surface) -- 159
		self.shadows[key] = surface -- 160
	end -- 160
	surface.visible = true -- 162
	surface.content.opacity = opacity -- 163
	surface.scale = Vec3(rx / 50, rz / 50, 1) -- 164
	surface.position = Vec3(x / 100, (y + 0.6) / 100, -depth / 100) -- 165
end -- 150
function Xiaoman3DScene.prototype.drawProps(self, p) -- 168
	local c = p.room.cart -- 169
	if c.bodyW > 0 then -- 169
		local d = c.depth or 0 -- 171
		self.depths.cart = d -- 172
		self.depths.cart_cloth = d - 1 -- 173
		self.assets:tryPlace( -- 174
			"prop_cart", -- 174
			"cart", -- 174
			p.cartAxle, -- 174
			c.baseY + d * DEPTH_Y_SCALE, -- 174
			c.bodyW * 1.38, -- 175
			(c.wheelR * 2 + c.bodyH) * 0.94 -- 175
		) -- 175
		self.assets:tryPlace( -- 176
			"fe_red_cloth", -- 176
			"cart_cloth", -- 176
			p.cartAxle - c.bodyW / 2 + 2, -- 176
			c.baseY + c.wheelR + c.bodyH - 2 + (d - 1) * DEPTH_Y_SCALE, -- 177
			24, -- 177
			24, -- 177
			{frame = math.floor(self.time * 6) % 3} -- 178
		) -- 178
	end -- 178
	for ____, box in ipairs(p.boxes) do -- 180
		if box.id == "outside_red_cart" and not box.broken then -- 180
			self.assets:tryPlace( -- 182
				"prop_cart", -- 182
				"red_cart", -- 182
				(box.x0 + box.x1) / 2, -- 182
				box.y0, -- 182
				box.x1 - box.x0, -- 182
				box.y1 - box.y0 -- 182
			) -- 182
			self.assets:tryPlace( -- 183
				"fe_red_cloth", -- 183
				"red_cart_cloth", -- 183
				box.x0 + 4, -- 183
				box.y1 - 3, -- 183
				22, -- 183
				22, -- 183
				{frame = math.floor(self.time * 6) % 3} -- 184
			) -- 184
		end -- 184
	end -- 184
	if p.room.key == "village" then -- 184
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 and p.room.bottle ~= nil then -- 184
			self.assets:tryPlace( -- 189
				"prop_bottle", -- 189
				"bottle_shelf", -- 189
				p.room.bottle.x, -- 189
				p.room.bottle.y, -- 189
				14, -- 189
				14 -- 189
			) -- 189
		end -- 189
		if p.hasBottle and p.aimHold <= 0 then -- 189
			local a = p.player -- 192
			self.depths.bottle_held = a.depth - 1 -- 193
			self.assets:tryPlace( -- 194
				"prop_bottle", -- 194
				"bottle_held", -- 194
				a.x + a.facing * 10, -- 194
				a.y + a.h * 0.52 + (a.depth - 1) * DEPTH_Y_SCALE, -- 195
				14, -- 195
				14 -- 195
			) -- 195
		end -- 195
		if p.bottleFly ~= nil then -- 195
			self.assets:tryPlace( -- 198
				"prop_bottle", -- 198
				"bottle_air", -- 198
				p.bottleFly.x, -- 198
				p.bottleFly.y, -- 198
				14, -- 198
				14, -- 198
				{angle = self.time * 360} -- 199
			) -- 199
		end -- 199
	end -- 199
	if p.hasBottle and p.aimHold > 0 and p.bottleAimX >= 0 then -- 199
		local endX = p.bottleAimX -- 203
		local endY = p.bottleAimY -- 204
		local x0 = p.player.x + (endX >= p.player.x and 10 or -10) -- 205
		local y0 = p.player.y + p.player.h * 0.7 -- 206
		local duration = 0.62 -- 207
		local vx = (endX - x0) / duration -- 208
		local vy = (endY - y0 + 0.5 * GRAVITY * duration * duration) / duration -- 209
		do -- 209
			local i = 1 -- 210
			while i <= 18 do -- 210
				local t = i / 18 * duration -- 211
				self.glow:drawDot( -- 212
					Vec2(x0 + vx * t, y0 + vy * t - 0.5 * GRAVITY * t * t), -- 212
					1.2, -- 212
					Color(229, 206, 148, 210) -- 213
				) -- 213
				i = i + 1 -- 210
			end -- 210
		end -- 210
		self.glow:drawEllipse( -- 215
			Vec2(endX, endY + 1), -- 215
			8, -- 215
			2, -- 215
			Color(229, 206, 148, 170) -- 215
		) -- 215
	end -- 215
	local latch = p:cartLatchBounds() -- 217
	if latch ~= nil then -- 217
		local iron = Color(122, 103, 78, 255) -- 219
		local top = latch.y + latch.height -- 220
		local post = math.min(3, latch.width) -- 221
		self.glow:drawRect( -- 222
			Rect(latch.x, top - 5, latch.width, 5), -- 222
			iron -- 222
		) -- 222
		self.glow:drawRect( -- 223
			Rect(latch.x, latch.y, post, latch.height), -- 223
			iron -- 223
		) -- 223
		self.glow:drawRect( -- 224
			Rect(latch.x + latch.width - post, latch.y, post, latch.height), -- 224
			iron -- 224
		) -- 224
		self.glow:drawRect( -- 225
			Rect(latch.x, top - 2, latch.width, 2), -- 225
			Color(194, 171, 132, 255) -- 225
		) -- 225
	end -- 225
	if p.room.key == "forest" then -- 225
		local lampX = p.ox + 1224 -- 229
		local sway = math.sin(self.time * 1.7) * 3 -- 230
		self.glow:drawRect( -- 231
			Rect(p.ox + 700, -3, 90, 3), -- 231
			Color(94, 116, 120, 120) -- 231
		) -- 231
		self.glow:drawRect( -- 232
			Rect(p.ox + 1150, -3, 110, 3), -- 232
			Color(98, 124, 126, 132) -- 232
		) -- 232
		self.glow:drawEllipse( -- 233
			Vec2(lampX + sway, 1), -- 233
			26, -- 233
			3, -- 233
			Color(229, 206, 148, 118) -- 233
		) -- 233
		self.glow:drawEllipse( -- 234
			Vec2(lampX + sway * 0.6, 1), -- 234
			12, -- 234
			2, -- 234
			Color(246, 232, 186, 172) -- 234
		) -- 234
		self.depths.water_lamp = 40 -- 235
		self.assets:tryPlace( -- 236
			"prop_lantern", -- 236
			"water_lamp", -- 236
			lampX, -- 236
			34 + 40 * DEPTH_Y_SCALE, -- 236
			16, -- 236
			26 -- 236
		) -- 236
	end -- 236
	if p.room.key == "tower" then -- 236
		if not p.towerDoorOpen then -- 236
			self.assets:tryPlace( -- 240
				"prop_tower_door", -- 240
				"tower_door", -- 240
				p.ox + 450, -- 240
				0, -- 240
				40, -- 240
				110 -- 240
			) -- 240
		else -- 240
			self.depths.tower_guard = 38 -- 242
			local writing = p.deskHold >= 24 or p.towerHanded -- 243
			self.assets:tryPlacePath( -- 244
				writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern", -- 244
				"tower_guard", -- 245
				p.ox + 626, -- 246
				38 * DEPTH_Y_SCALE, -- 246
				54, -- 246
				82, -- 246
				{anchorX = 0.44, anchorY = 0, preserveAspect = true, facing = -1} -- 247
			) -- 247
			self.depths.desk_lamp = 22 -- 248
			self.assets:tryPlace( -- 249
				"prop_lantern", -- 249
				"desk_lamp", -- 249
				p.ox + 639, -- 249
				35 + 22 * DEPTH_Y_SCALE, -- 249
				18, -- 249
				30 -- 249
			) -- 249
		end -- 249
	end -- 249
end -- 168
function Xiaoman3DScene.prototype.updateCamera(self, cam, w, h, vp) -- 254
	self.fullW = View.size.width -- 255
	self.fullH = View.size.height -- 256
	self.stageX = vp.stageX -- 257
	self.stageY = vp.stageY -- 258
	self.focal = self.fullH / (2 * math.tan(View.fieldOfView * math.pi / 360)) -- 259
	local distance = 4.25 / cam.zoom * self.fullH / h -- 260
	local rise = distance * 0.19 -- 261
	local length = math.sqrt(distance * distance + rise * rise) -- 262
	self.pitchSin = rise / length -- 263
	self.pitchCos = distance / length -- 264
	local offsetX = (vp.stageX + w / 2 - self.fullW / 2) * length / self.focal -- 265
	local offsetY = (vp.stageY + h / 2 - self.fullH / 2) * length / self.focal -- 266
	local tx = cam.x / 100 - offsetX -- 267
	local ty = 0.85 + (cam.y - 82) * 0.0045 - offsetY * self.pitchCos -- 268
	local tz = offsetY * self.pitchSin -- 269
	self.cameraX = tx -- 270
	self.cameraY = ty + rise -- 271
	self.cameraZ = tz + distance -- 272
	self.camera:lookAt( -- 273
		Vec3(self.cameraX, self.cameraY, self.cameraZ), -- 273
		Vec3(tx, ty, tz) -- 273
	) -- 273
end -- 254
function Xiaoman3DScene.prototype.worldToScreen(self, x, y, depth) -- 276
	if depth == nil then -- 276
		depth = 0 -- 276
	end -- 276
	local dx = x / 100 - self.cameraX -- 277
	local dy = y / 100 - self.cameraY -- 278
	local dz = -depth / 100 - self.cameraZ -- 279
	local forward = -dy * self.pitchSin - dz * self.pitchCos -- 280
	return {x = self.fullW / 2 + dx * self.focal / forward - self.stageX, y = self.fullH / 2 + (dy * self.pitchCos - dz * self.pitchSin) * self.focal / forward - self.stageY} -- 281
end -- 276
function Xiaoman3DScene.prototype.screenToWorld(self, x, y) -- 287
	local u = (x + self.stageX - self.fullW / 2) / self.focal -- 288
	local v = (y + self.stageY - self.fullH / 2) / self.focal -- 289
	local rayY = v * self.pitchCos - self.pitchSin -- 290
	local rayZ = -v * self.pitchSin - self.pitchCos -- 291
	local ____opt_0 = self.p -- 291
	local z = -(____opt_0 and ____opt_0.player.depth or 0) / 100 -- 293
	local t = (z - self.cameraZ) / rayZ -- 294
	return {x = (self.cameraX + u * t) * 100, y = (self.cameraY + rayY * t) * 100} -- 295
end -- 287
return ____exports -- 287