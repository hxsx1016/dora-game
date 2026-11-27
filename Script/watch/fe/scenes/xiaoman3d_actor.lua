-- [ts]: xiaoman3d_actor.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local Color3 = ____Dora.Color3 -- 12
local Model3D = ____Dora.Model3D -- 12
local Node3D = ____Dora.Node3D -- 12
local PointLight3D = ____Dora.PointLight3D -- 12
local Vec3 = ____Dora.Vec3 -- 12
local XIAOMAN_MODEL_PATH = "assets/xiaoman3d/xiaoman.glb" -- 15
local BOTTLE_MODEL_PATH = "assets/xiaoman3d/bottle.glb" -- 16
local TWIG_OFFSETS = {235, 455, 865, 1115} -- 17
--- 朝向符号（glTF +Z 正面，绕 +Y 逆时针旋转 +90° 朝 +X 右侧）。
local YAW_SIGN = 1 -- 20
local function mountModel(parent, path) -- 36
	local m = Model3D(path) -- 37
	if m.parent ~= nil then -- 37
		m:removeFromParent(false) -- 39
	end -- 39
	parent:addChild(m) -- 41
	return m -- 42
end -- 36
local function wrapAngleDeg(deg) -- 45
	local a = deg % 360 -- 46
	if a > 180 then -- 46
		a = a - 360 -- 48
	elseif a < -180 then -- 48
		a = a + 360 -- 50
	end -- 50
	return a -- 52
end -- 45
local function shortestDeltaDeg(fromDeg, toDeg) -- 55
	return wrapAngleDeg(toDeg - fromDeg) -- 56
end -- 55
____exports.Xiaoman3DActor = __TS__Class() -- 59
local Xiaoman3DActor = ____exports.Xiaoman3DActor -- 59
Xiaoman3DActor.name = "Xiaoman3DActor" -- 59
function Xiaoman3DActor.prototype.____constructor(self, root) -- 79
	self.pivot = Node3D() -- 60
	self.personalLight = PointLight3D() -- 63
	self.hasSocket = false -- 64
	self.yawDeg = 58 -- 66
	self.targetYawDeg = 58 -- 67
	self.currentAnim = "" -- 68
	self.animLoop = true -- 69
	self.lastRoomKey = "" -- 70
	self.throwTimer = 0 -- 72
	self.listenTimer = 0 -- 73
	self.prevBottleFly = false -- 74
	self.prevDogState = "" -- 75
	self.prevCartAxle = 0 -- 76
	self.lastTwigIdx = -1 -- 77
	root:addChild(self.pivot) -- 80
	self.pivot.visible = false -- 81
	self.personalLight.color = Color3(255, 232, 196) -- 84
	self.personalLight.intensity = 0.92 -- 85
	self.personalLight.range = 1.25 -- 86
	self.personalLight.position = Vec3(0, 0.42, 0.36) -- 87
	self.pivot:addChild(self.personalLight) -- 88
end -- 79
function Xiaoman3DActor.prototype.ensureLoaded(self) -- 91
	if self.model ~= nil then -- 91
		return -- 93
	end -- 93
	local m = mountModel(self.pivot, XIAOMAN_MODEL_PATH) -- 95
	self.model = m -- 96
	self.hasSocket = m:hasNode("hand_R_socket") -- 97
	if self.hasSocket then -- 97
		local bottle = Model3D(BOTTLE_MODEL_PATH) -- 100
		if bottle.parent ~= nil then -- 100
			bottle:removeFromParent(false) -- 102
		end -- 102
		bottle.position = Vec3(0, -0.02, 0.025) -- 104
		bottle.scale = Vec3(0.92, 0.92, 0.92) -- 105
		bottle.visible = false -- 106
		m:attachToNode("hand_R_socket", bottle) -- 107
		self.heldBottle = bottle -- 108
	end -- 108
	self:playAnim("idle", true, 1) -- 110
end -- 91
function Xiaoman3DActor.prototype.hide(self) -- 113
	self.pivot.visible = false -- 114
	if self.model ~= nil and not self.model.paused then -- 114
		self.model:pause() -- 116
	end -- 116
end -- 113
function Xiaoman3DActor.prototype.update(self, p, dt) -- 120
	self:ensureLoaded() -- 121
	local a = p.player -- 122
	if not a.alive then -- 122
		self.pivot.visible = false -- 124
		return -- 125
	end -- 125
	self.pivot.visible = true -- 127
	if self.lastRoomKey ~= p.room.key then -- 127
		self.lastRoomKey = p.room.key -- 131
		self.throwTimer = 0 -- 132
		self.listenTimer = 0 -- 133
		self.prevBottleFly = p.bottleFly ~= nil -- 134
		self.prevDogState = p.dogState -- 135
		self.prevCartAxle = p.cartAxle -- 136
		self.lastTwigIdx = -1 -- 137
		self.yawDeg = a.facing >= 0 and 58 or -58 -- 139
		self.targetYawDeg = self.yawDeg -- 140
	end -- 140
	local paused = p.paused or dt <= 0 -- 143
	local safeDt = paused and 0 or math.min(0.05, dt) -- 144
	if self.model ~= nil then -- 144
		if paused then -- 144
			if not self.model.paused then -- 144
				self.model:pause() -- 149
			end -- 149
		elseif self.model.paused then -- 149
			self.model:resume() -- 152
		end -- 152
	end -- 152
	local flying = p.bottleFly ~= nil -- 157
	if flying and not self.prevBottleFly then -- 157
		self.throwTimer = 0.44 -- 159
	end -- 159
	self.prevBottleFly = flying -- 161
	if not paused then -- 161
		if self.throwTimer > 0 then -- 161
			self.throwTimer = math.max(0, self.throwTimer - safeDt) -- 165
		end -- 165
		if self.listenTimer > 0 then -- 165
			self.listenTimer = math.max(0, self.listenTimer - safeDt) -- 168
		end -- 168
	end -- 168
	local horizSpeed = math.sqrt(a.vx * a.vx + a.depthSpeed * a.depthSpeed) -- 172
	if p.room.key == "forest" then -- 172
		if p.dogState == "ear" and self.prevDogState ~= "ear" then -- 172
			self.listenTimer = 0.72 -- 175
		end -- 175
		local curTwig = -1 -- 177
		if not a.crouch and a.y <= 8 and horizSpeed > 12 then -- 177
			local i = 0 -- 179
			do -- 179
				i = 0 -- 180
				while i < #TWIG_OFFSETS do -- 180
					if math.abs(a.x - (p.ox + TWIG_OFFSETS[i + 1])) <= 18 then -- 180
						curTwig = i -- 182
						break -- 183
					end -- 183
					i = i + 1 -- 180
				end -- 180
			end -- 180
		end -- 180
		if curTwig >= 0 and curTwig ~= self.lastTwigIdx then -- 180
			self.listenTimer = 0.65 -- 188
		end -- 188
		self.lastTwigIdx = curTwig -- 190
	end -- 190
	self.prevDogState = p.dogState -- 192
	self.targetYawDeg = self:computeTargetYaw(p, horizSpeed) -- 195
	if not paused then -- 195
		local diff = shortestDeltaDeg(self.yawDeg, self.targetYawDeg) -- 197
		local turnRate = math.min(1, safeDt * 13.5) -- 198
		self.yawDeg = wrapAngleDeg(self.yawDeg + diff * turnRate) -- 199
	end -- 199
	self.pivot.position = Vec3(a.x / 100, a.y / 100, -a.depth / 100) -- 203
	if self.model ~= nil then -- 203
		self.model.angles = Vec3(0, self.yawDeg * YAW_SIGN, 0) -- 205
	end -- 205
	local inShadowCover = a.crouch or p.room.key == "village" and a.x >= p.ox + 290 and a.x <= p.ox + 430 or p.room.key == "outside" and a.y < 60 and a.x >= p.ox + 250 and a.x <= p.ox + 400 -- 209
	self.personalLight.intensity = inShadowCover and 1.18 or 0.9 -- 212
	self.personalLight.position = Vec3(0, a.crouch and 0.28 or 0.42, 0.34) -- 213
	if self.heldBottle ~= nil then -- 213
		self.heldBottle.visible = p.room.key == "village" and p.hasBottle and not flying -- 217
	end -- 217
	local cartDelta = math.abs(p.cartAxle - self.prevCartAxle) -- 221
	if not paused then -- 221
		self.prevCartAxle = p.cartAxle -- 223
	end -- 223
	self:selectAnimation(p, horizSpeed, cartDelta) -- 225
end -- 120
function Xiaoman3DActor.prototype.computeTargetYaw(self, p, horizSpeed) -- 228
	local a = p.player -- 229
	if p.room.key == "tower" then -- 229
		if p.phase == "tower-knock" or p.phase == "tower-open" then -- 229
			return 162 -- 233
		end -- 233
		if p.deskHold > 0 or p.phase == "tower-given" then -- 233
			return 118 -- 236
		end -- 236
	end -- 236
	if p.gripping then -- 236
		local axleX = p.cartAxle -- 240
		return axleX <= a.x and -76 or 76 -- 241
	end -- 241
	if p.hasBottle and p.aimHold > 0 and p.bottleAimX >= 0 then -- 241
		local dx = p.bottleAimX - a.x -- 244
		local dz = a.depth -- 245
		return wrapAngleDeg(math.atan(dx, dz) * (180 / math.pi)) -- 246
	end -- 246
	if self.throwTimer > 0 and p.bottleFly ~= nil then -- 246
		local dx = p.bottleFly.vx -- 249
		return dx >= 0 and 82 or -82 -- 250
	end -- 250
	if horizSpeed > 2.5 then -- 250
		local velX = a.vx -- 256
		local velZ = -a.depthSpeed -- 257
		return wrapAngleDeg(math.atan(velX, velZ) * (180 / math.pi)) -- 258
	end -- 258
	return self.targetYawDeg -- 261
end -- 228
function Xiaoman3DActor.prototype.selectAnimation(self, p, horizSpeed, cartDelta) -- 264
	local a = p.player -- 265
	local next = "idle" -- 266
	local loop = true -- 267
	local speed = 1 -- 268
	if p.room.key == "tower" and p.phase == "tower-knock" then -- 268
		next = "knock" -- 271
		loop = true -- 272
		speed = 1.05 -- 273
	elseif p.room.key == "tower" and (p.deskHold > 0 or p.phase == "tower-given") then -- 273
		next = "offer" -- 275
		loop = true -- 276
		speed = 0.95 -- 277
	elseif self.throwTimer > 0 then -- 277
		next = "throw" -- 279
		loop = false -- 280
		speed = 1.15 -- 281
	elseif p.hasBottle and p.aimHold > 0 then -- 281
		next = "aim" -- 283
		loop = true -- 284
		speed = 1 -- 285
	elseif p.gripping then -- 285
		next = cartDelta > 0.05 and "pull_walk" or "pull_idle" -- 287
		loop = true -- 288
		speed = cartDelta > 0.05 and 1.05 or 0.9 -- 289
	elseif not a.onGround then -- 289
		next = "jump" -- 291
		loop = true -- 292
		speed = 1 -- 293
	elseif a.crouch then -- 293
		next = horizSpeed > 8 and "crouch_walk" or "crouch_idle" -- 295
		loop = true -- 296
		speed = horizSpeed > 8 and math.max( -- 297
			0.75, -- 297
			math.min(1.25, horizSpeed / 78) -- 297
		) or 1 -- 297
	elseif self.listenTimer > 0 and horizSpeed <= 8 then -- 297
		next = "listen" -- 299
		loop = true -- 300
		speed = 1 -- 301
	elseif horizSpeed > 135 then -- 301
		next = "run" -- 303
		loop = true -- 304
		speed = math.max( -- 305
			0.95, -- 305
			math.min(1.3, horizSpeed / 160) -- 305
		) -- 305
	elseif horizSpeed > 8 then -- 305
		next = "walk" -- 307
		loop = true -- 308
		speed = math.max( -- 309
			0.72, -- 309
			math.min(1.18, horizSpeed / 112) -- 309
		) -- 309
	else -- 309
		next = "idle" -- 311
		loop = true -- 312
		speed = 1 -- 313
	end -- 313
	self:playAnim(next, loop, speed) -- 316
end -- 264
function Xiaoman3DActor.prototype.playAnim(self, name, loop, speed) -- 319
	local m = self.model -- 320
	if m == nil then -- 320
		return -- 322
	end -- 322
	m.speed = speed -- 324
	if self.currentAnim ~= name or self.animLoop ~= loop then -- 324
		self.currentAnim = name -- 326
		self.animLoop = loop -- 327
		m:play(name, loop) -- 328
	end -- 328
end -- 319
function Xiaoman3DActor.prototype.getDebugState(self, p) -- 332
	local pos = self.pivot.position -- 333
	return { -- 334
		loaded = self.model ~= nil, -- 335
		visible = self.pivot.visible, -- 336
		yawDeg = self.yawDeg, -- 337
		targetYawDeg = self.targetYawDeg, -- 338
		animName = self.currentAnim, -- 339
		animCount = self.model ~= nil and self.model.animationCount or 0, -- 340
		hasHandSocket = self.hasSocket, -- 341
		bottleInHand = self.heldBottle ~= nil and self.heldBottle.visible, -- 342
		worldX = p ~= nil and p.player.x or pos.x * 100, -- 343
		worldY = p ~= nil and p.player.y or pos.y * 100, -- 344
		worldZ = p ~= nil and -p.player.depth or pos.z * 100 -- 345
	} -- 345
end -- 332
return ____exports -- 332