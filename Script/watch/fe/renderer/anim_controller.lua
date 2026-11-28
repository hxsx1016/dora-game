-- [ts]: anim_controller.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
____exports.IDENTITY_JUICE = { -- 34
	offsetX = 0, -- 35
	offsetY = 0, -- 36
	scaleXMul = 1, -- 37
	scaleYMul = 1, -- 38
	angleOffset = 0, -- 39
	hitFlash = 0 -- 40
} -- 40
local TURN_DURATION = 0.085 -- 43
local JUMP_DURATION = 0.12 -- 44
local LAND_DURATION = 0.14 -- 45
local RECOIL_DURATION = 0.17 -- 46
local HIT_DURATION = 0.24 -- 47
local function clamp01(v) -- 49
	return v <= 0 and 0 or (v >= 1 and 1 or v) -- 50
end -- 49
____exports.ActorMotionState = __TS__Class() -- 53
local ActorMotionState = ____exports.ActorMotionState -- 53
ActorMotionState.name = "ActorMotionState" -- 53
function ActorMotionState.prototype.____constructor(self) -- 53
	self.facing = 1 -- 54
	self.turnTimer = 0 -- 55
	self.wasOnGround = true -- 56
	self.prevVy = 0 -- 57
	self.jumpTimer = 0 -- 58
	self.landTimer = 0 -- 59
	self.landStrength = 1 -- 60
	self.recoilTimer = 0 -- 61
	self.recoilDir = 1 -- 62
	self.hitTimer = 0 -- 63
	self.hitDir = 1 -- 64
	self.idleTime = 0 -- 66
	self.coverTime = 0 -- 67
	self.stateKey = "" -- 68
	self.stateTime = 0 -- 69
	self.lastStrideHalf = -1 -- 71
	self.wasMoving = false -- 72
	self.crouchCycle = 0 -- 73
	self.pushCycle = 0 -- 74
	self.prevX = 0 -- 75
	self.prevDepth = 0 -- 76
end -- 53
function ActorMotionState.prototype.reset(self, a) -- 78
	self.facing = a.facing >= 0 and 1 or -1 -- 79
	self.turnTimer = 0 -- 80
	self.wasOnGround = a.onGround -- 81
	self.prevVy = a.vy -- 82
	self.jumpTimer = 0 -- 83
	self.landTimer = 0 -- 84
	self.landStrength = 1 -- 85
	self.recoilTimer = 0 -- 86
	self.recoilDir = self.facing -- 87
	self.hitTimer = 0 -- 88
	self.hitDir = self.facing -- 89
	self.idleTime = 0 -- 90
	self.coverTime = 0 -- 91
	self.stateKey = "" -- 92
	self.stateTime = 0 -- 93
	self.lastStrideHalf = -1 -- 94
	self.wasMoving = false -- 95
	self.crouchCycle = 0 -- 96
	self.pushCycle = 0 -- 97
	self.prevX = a.x -- 98
	self.prevDepth = a.depth -- 99
end -- 78
function ActorMotionState.prototype.triggerRecoil(self, dir) -- 102
	self.recoilTimer = RECOIL_DURATION -- 103
	self.recoilDir = dir >= 0 and 1 or -1 -- 104
end -- 102
function ActorMotionState.prototype.triggerHit(self, dir) -- 107
	self.hitTimer = HIT_DURATION -- 108
	self.hitDir = dir >= 0 and 1 or -1 -- 109
end -- 107
function ActorMotionState.prototype.update(self, dt, a, strideCycle, strideSpeed, strideEffort, isCovering, outCues) -- 112
	if dt <= 0 then -- 112
		return -- 122
	end -- 122
	local f = a.facing >= 0 and 1 or -1 -- 124
	if f ~= self.facing then -- 124
		self.facing = f -- 126
		self.turnTimer = TURN_DURATION -- 127
	end -- 127
	local dx = a.x - self.prevX -- 130
	local dd = a.depth - self.prevDepth -- 131
	local stepDist = math.sqrt(dx * dx + dd * dd) -- 132
	self.prevX = a.x -- 133
	self.prevDepth = a.depth -- 134
	if a.crouch and a.onGround and stepDist > 0.05 then -- 134
		self.crouchCycle = (self.crouchCycle + stepDist / math.max(24, a.h * 1.15)) % 1 -- 137
	end -- 137
	if a.onGround and stepDist > 0.05 then -- 137
		self.pushCycle = (self.pushCycle + stepDist / math.max(30, a.h * 0.92)) % 1 -- 140
	end -- 140
	if self.wasOnGround and not a.onGround then -- 140
		if a.vy > 30 then -- 140
			self.jumpTimer = JUMP_DURATION -- 146
			outCues[#outCues + 1] = { -- 147
				x = a.x, -- 148
				y = a.y, -- 149
				depth = a.depth, -- 150
				facing = f, -- 151
				kind = "jump", -- 152
				strength = 0.9 -- 153
			} -- 153
		end -- 153
	elseif not self.wasOnGround and a.onGround then -- 153
		self.landTimer = LAND_DURATION -- 157
		self.landStrength = clamp01(math.abs(self.prevVy) / 360) -- 158
		if self.landStrength < 0.35 then -- 158
			self.landStrength = 0.35 -- 160
		end -- 160
		outCues[#outCues + 1] = { -- 162
			x = a.x, -- 163
			y = a.y, -- 164
			depth = a.depth, -- 165
			facing = f, -- 166
			kind = "land", -- 167
			strength = self.landStrength -- 168
		} -- 168
	end -- 168
	self.wasOnGround = a.onGround -- 171
	self.prevVy = a.vy -- 172
	local movingFast = a.alive and a.onGround and not a.crouch and not a.covered and a.rollT <= 0 and strideSpeed > 18 -- 175
	if movingFast and strideEffort > 0.35 then -- 175
		local half = strideCycle < 0.5 and 0 or 1 -- 177
		if self.lastStrideHalf ~= -1 and half ~= self.lastStrideHalf then -- 177
			outCues[#outCues + 1] = { -- 179
				x = a.x - f * a.w * 0.18, -- 180
				y = a.y, -- 181
				depth = a.depth, -- 182
				facing = f, -- 183
				kind = "step", -- 184
				strength = clamp01(strideSpeed / 240) -- 185
			} -- 185
		end -- 185
		self.lastStrideHalf = half -- 188
	else -- 188
		if self.wasMoving and a.onGround and a.rollT <= 0 and strideSpeed <= 12 then -- 188
			outCues[#outCues + 1] = { -- 191
				x = a.x + f * a.w * 0.22, -- 192
				y = a.y, -- 193
				depth = a.depth, -- 194
				facing = f, -- 195
				kind = "brake", -- 196
				strength = 0.85 -- 197
			} -- 197
		end -- 197
		self.lastStrideHalf = -1 -- 200
	end -- 200
	self.wasMoving = movingFast and strideEffort > 0.5 -- 202
	if a.alive and a.onGround and not a.crouch and not isCovering and a.rollT <= 0 and strideSpeed <= 8 and strideEffort <= 0.001 then -- 202
		self.idleTime = self.idleTime + dt -- 206
	else -- 206
		self.idleTime = 0 -- 208
	end -- 208
	if isCovering and a.alive then -- 208
		self.coverTime = self.coverTime + dt -- 212
	else -- 212
		self.coverTime = 0 -- 214
	end -- 214
	if self.turnTimer > 0 then -- 214
		self.turnTimer = math.max(0, self.turnTimer - dt) -- 218
	end -- 218
	if self.jumpTimer > 0 then -- 218
		self.jumpTimer = math.max(0, self.jumpTimer - dt) -- 221
	end -- 221
	if self.landTimer > 0 then -- 221
		self.landTimer = math.max(0, self.landTimer - dt) -- 224
	end -- 224
	if self.recoilTimer > 0 then -- 224
		self.recoilTimer = math.max(0, self.recoilTimer - dt) -- 227
	end -- 227
	if self.hitTimer > 0 then -- 227
		self.hitTimer = math.max(0, self.hitTimer - dt) -- 230
	end -- 230
end -- 112
function ActorMotionState.prototype.trackState(self, key, dt) -- 235
	if self.stateKey ~= key then -- 235
		self.stateKey = key -- 237
		self.stateTime = 0 -- 238
	else -- 238
		self.stateTime = self.stateTime + dt -- 240
	end -- 240
	return self.stateTime -- 242
end -- 235
function ActorMotionState.prototype.sampleJuice(self, ppu) -- 246
	local offsetX = 0 -- 247
	local offsetY = 0 -- 248
	local scaleXMul = 1 -- 249
	local scaleYMul = 1 -- 250
	local angleOffset = 0 -- 251
	local hitFlash = 0 -- 252
	if self.turnTimer > 0 then -- 252
		local k = self.turnTimer / TURN_DURATION -- 255
		local s = math.sin(k * math.pi * 0.5) -- 256
		scaleXMul = scaleXMul * (1 - 0.2 * s) -- 257
		scaleYMul = scaleYMul * (1 + 0.04 * s) -- 258
	end -- 258
	if self.jumpTimer > 0 then -- 258
		local k = self.jumpTimer / JUMP_DURATION -- 261
		local s = math.sin(k * math.pi) -- 262
		scaleXMul = scaleXMul * (1 - 0.08 * s) -- 263
		scaleYMul = scaleYMul * (1 + 0.09 * s) -- 264
	end -- 264
	if self.landTimer > 0 then -- 264
		local k = self.landTimer / LAND_DURATION -- 267
		local s = math.sin(k * math.pi) -- 268
		local str = self.landStrength -- 269
		scaleXMul = scaleXMul * (1 + 0.12 * s * str) -- 270
		scaleYMul = scaleYMul * (1 - 0.11 * s * str) -- 271
	end -- 271
	if self.recoilTimer > 0 then -- 271
		local k = self.recoilTimer / RECOIL_DURATION -- 274
		local punch = k * k -- 275
		offsetX = offsetX - self.recoilDir * 4.2 * punch * ppu -- 276
		angleOffset = angleOffset - self.recoilDir * 3.2 * punch -- 277
		scaleXMul = scaleXMul * (1 - 0.04 * punch) -- 278
		scaleYMul = scaleYMul * (1 + 0.03 * punch) -- 279
	end -- 279
	if self.hitTimer > 0 then -- 279
		local k = self.hitTimer / HIT_DURATION -- 282
		hitFlash = k > 0.55 and 1 or k / 0.55 -- 283
		offsetX = offsetX - self.hitDir * 3.6 * k * ppu -- 284
		angleOffset = angleOffset - self.hitDir * 6.5 * math.sin(k * math.pi) -- 285
	end -- 285
	return { -- 287
		offsetX = offsetX, -- 287
		offsetY = offsetY, -- 287
		scaleXMul = scaleXMul, -- 287
		scaleYMul = scaleYMul, -- 287
		angleOffset = angleOffset, -- 287
		hitFlash = hitFlash -- 287
	} -- 287
end -- 246
____exports.EnemyAnimState = __TS__Class() -- 291
local EnemyAnimState = ____exports.EnemyAnimState -- 291
EnemyAnimState.name = "EnemyAnimState" -- 291
function EnemyAnimState.prototype.____constructor(self, e, index) -- 306
	self.prevX = 0 -- 292
	self.prevDepth = 0 -- 293
	self.speed = 0 -- 294
	self.walkCycle = 0 -- 295
	self.alive = true -- 296
	self.deathTime = 0 -- 297
	self.warnTime = 0 -- 298
	self.wasWarn = false -- 299
	self.swingTime = 0 -- 300
	self.wasSwing = false -- 301
	self.hitTime = 0 -- 302
	self.hitFlash = 0 -- 303
	self.idlePhase = 0 -- 304
	self.prevX = e.x -- 307
	self.prevDepth = e.depth or 0 -- 308
	self.alive = e.alive -- 309
	self.idlePhase = index * 1.37 % 6.283 -- 310
end -- 306
function EnemyAnimState.prototype.update(self, dt, e) -- 313
	if dt <= 0 then -- 313
		return -- 315
	end -- 315
	local depth = e.depth or 0 -- 317
	local dx = e.x - self.prevX -- 318
	local dd = depth - self.prevDepth -- 319
	local dist = math.sqrt(dx * dx + dd * dd) -- 320
	self.speed = dist / math.max(0.001, dt) -- 321
	self.prevX = e.x -- 322
	self.prevDepth = depth -- 323
	if e.alive and self.speed > 6 then -- 323
		self.walkCycle = (self.walkCycle + dist / math.max(34, e.h * 1.1)) % 1 -- 326
	end -- 326
	if not e.alive then -- 326
		if self.alive then -- 326
			self.alive = false -- 331
			self.deathTime = 0 -- 332
			self.hitFlash = 1 -- 333
		else -- 333
			self.deathTime = self.deathTime + dt -- 335
		end -- 335
	else -- 335
		self.alive = true -- 338
		self.deathTime = 0 -- 339
	end -- 339
	if e.warnT > 0 then -- 339
		if not self.wasWarn then -- 339
			self.warnTime = 0 -- 344
			self.wasWarn = true -- 345
		else -- 345
			self.warnTime = self.warnTime + dt -- 347
		end -- 347
	else -- 347
		self.wasWarn = false -- 350
		self.warnTime = 0 -- 351
	end -- 351
	local swinging = (e.swingT or 0) > 0 -- 354
	if swinging then -- 354
		if not self.wasSwing then -- 354
			self.swingTime = 0 -- 357
			self.wasSwing = true -- 358
		else -- 358
			self.swingTime = self.swingTime + dt -- 360
		end -- 360
	else -- 360
		self.wasSwing = false -- 363
		self.swingTime = 0 -- 364
	end -- 364
	if e.hitT > 0 then -- 364
		self.hitTime = self.hitTime + dt -- 368
		self.hitFlash = math.min(1, e.hitT * 2.5) -- 369
	else -- 369
		self.hitTime = 0 -- 371
		self.hitFlash = math.max(0, self.hitFlash - dt * 5) -- 372
	end -- 372
end -- 313
____exports.ActorAnimController = __TS__Class() -- 377
local ActorAnimController = ____exports.ActorAnimController -- 377
ActorAnimController.name = "ActorAnimController" -- 377
function ActorAnimController.prototype.____constructor(self) -- 377
	self.player = __TS__New(____exports.ActorMotionState) -- 378
	self.partner = __TS__New(____exports.ActorMotionState) -- 379
	self.enemies = {} -- 380
	self.footstepCues = {} -- 381
	self.scavCycle = 0 -- 382
	self.prevScavX = 0 -- 383
	self.dogCycle = 0 -- 384
	self.prevDogX = 0 -- 385
end -- 377
function ActorAnimController.prototype.reset(self, p) -- 387
	self.player:reset(p.player) -- 388
	self.partner:reset(p.partner) -- 389
	self.enemies = {} -- 390
	do -- 390
		local i = 0 -- 391
		while i < #p.enemies do -- 391
			local ____self_enemies_0 = self.enemies -- 391
			____self_enemies_0[#____self_enemies_0 + 1] = __TS__New(____exports.EnemyAnimState, p.enemies[i + 1], i) -- 392
			i = i + 1 -- 391
		end -- 391
	end -- 391
	self.footstepCues = {} -- 394
	self.scavCycle = 0 -- 395
	self.prevScavX = p.scavX -- 396
	self.dogCycle = 0 -- 397
	self.prevDogX = p.dogX -- 398
end -- 387
function ActorAnimController.prototype.drainFootsteps(self) -- 401
	local out = self.footstepCues -- 402
	self.footstepCues = {} -- 403
	return out -- 404
end -- 401
function ActorAnimController.prototype.updateEnemiesAndNpcs(self, dt, p) -- 407
	if dt <= 0 then -- 407
		return -- 409
	end -- 409
	if #self.enemies ~= #p.enemies then -- 409
		self.enemies = {} -- 412
		do -- 412
			local i = 0 -- 413
			while i < #p.enemies do -- 413
				local ____self_enemies_1 = self.enemies -- 413
				____self_enemies_1[#____self_enemies_1 + 1] = __TS__New(____exports.EnemyAnimState, p.enemies[i + 1], i) -- 414
				i = i + 1 -- 413
			end -- 413
		end -- 413
	end -- 413
	do -- 413
		local i = 0 -- 417
		while i < #p.enemies do -- 417
			self.enemies[i + 1]:update(dt, p.enemies[i + 1]) -- 418
			i = i + 1 -- 417
		end -- 417
	end -- 417
	local scavDist = math.abs(p.scavX - self.prevScavX) -- 422
	self.prevScavX = p.scavX -- 423
	if scavDist > 0.05 then -- 423
		local stride = p.scavState == "chase" and 56 or 44 -- 425
		self.scavCycle = (self.scavCycle + scavDist / stride) % 1 -- 426
	end -- 426
	local dogDist = math.abs(p.dogX - self.prevDogX) -- 430
	self.prevDogX = p.dogX -- 431
	if dogDist > 0.05 then -- 431
		local stride = p.dogState == "chase" and 48 or 34 -- 433
		self.dogCycle = (self.dogCycle + dogDist / stride) % 1 -- 434
	end -- 434
end -- 407
return ____exports -- 407