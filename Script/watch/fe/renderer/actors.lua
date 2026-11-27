-- [ts]: actors.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____escort = require("Script.watch.escort") -- 5
local FEAR_MAX = ____escort.FEAR_MAX -- 5
local ____clock = require("Script.watch.clock") -- 6
local STEP = ____clock.STEP -- 6
local ____depth = require("Script.watch.depth") -- 7
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 7
local overlapsDepth = ____depth.overlapsDepth -- 7
local ____occlusion = require("Script.watch.fe.occlusion") -- 8
local depthOrder = ____occlusion.depthOrder -- 8
local ____theme = require("Script.watch.fe.theme") -- 12
local PALETTE = ____theme.PALETTE -- 12
local drawDiamond = ____theme.drawDiamond -- 12
local fillRadialGlow = ____theme.fillRadialGlow -- 12
local toColor = ____theme.toColor -- 12
local function strideAt(actor) -- 33
	return { -- 34
		actor = actor, -- 34
		x = actor.x, -- 34
		depth = actor.depth, -- 34
		speed = 0, -- 34
		cycle = 0, -- 34
		sampledCycle = 0, -- 34
		sinceSample = 0, -- 34
		effort = 0 -- 34
	} -- 34
end -- 33
local RUN_START_T = 0.1 -- 37
local RUN_STOP_T = 0.13 -- 38
local function advanceStride(stride, steps, dt) -- 40
	local a = stride.actor -- 41
	local distance = 0 -- 42
	if steps > 0 then -- 42
		local dx = a.x - stride.x -- 44
		local depth = a.depth - stride.depth -- 45
		distance = math.sqrt(dx * dx + depth * depth) -- 46
		local speed = distance / (steps * STEP) -- 47
		stride.speed = speed <= 380 and speed or 0 -- 48
		stride.x = a.x -- 49
		stride.depth = a.depth -- 50
		stride.sinceSample = 0 -- 51
	else -- 51
		stride.sinceSample = math.min(STEP, stride.sinceSample + dt) -- 53
	end -- 53
	if not a.alive or not a.onGround or a.crouch or a.covered or a.rollT > 0 then -- 53
		stride.effort = 0 -- 56
		return -- 57
	end -- 57
	if stride.speed > 8 then -- 57
		stride.effort = math.min(1, stride.effort + dt / RUN_START_T) -- 60
		local strideLength = a.h * (a.w <= 28 and 1.4 or 1.32) -- 61
		stride.sampledCycle = (stride.sampledCycle + distance / strideLength) % 1 -- 62
		stride.cycle = (stride.sampledCycle + stride.speed * stride.sinceSample / strideLength) % 1 -- 64
	else -- 64
		stride.effort = math.max(0, stride.effort - dt / RUN_STOP_T) -- 66
	end -- 66
end -- 40
local DUST_LIFE = 0.23 -- 70
____exports.ActorsRenderer = __TS__Class() -- 72
local ActorsRenderer = ____exports.ActorsRenderer -- 72
ActorsRenderer.name = "ActorsRenderer" -- 72
function ActorsRenderer.prototype.____constructor(self) -- 72
	self.slideDust = {} -- 73
	self.dustCooldown = 0 -- 74
	self.slideDuration = 0 -- 75
	self.slideRemainder = 0 -- 76
	self.strideTick = 0 -- 77
	self.animTime = 0 -- 80
	self.previousHp = 3 -- 81
	self.previousAxle = 0 -- 82
	self.cartMoving = false -- 83
	self.previousBottle = false -- 84
	self.hitUntil = -1 -- 86
	self.throwUntil = -1 -- 87
	self.shotUntil = -1 -- 88
end -- 72
function ActorsRenderer.prototype.reset(self, p) -- 90
	self.slideDust = {} -- 91
	self.dustCooldown = 0 -- 92
	self.slideDuration = 0 -- 93
	self.slideRemainder = 0 -- 94
	self.strideTick = p.ticks -- 95
	self.playerStride = strideAt(p.player) -- 96
	self.partnerStride = strideAt(p.partner) -- 97
	self.animTime = 0 -- 98
	self.previousHp = p.hp -- 99
	self.previousAxle = p.cartAxle -- 100
	self.cartMoving = false -- 101
	self.previousBottle = p.hasBottle -- 102
	self.previousTrace = p.trace -- 103
	self.hitUntil = -1 -- 104
	self.throwUntil = -1 -- 105
	self.shotUntil = -1 -- 106
end -- 90
function ActorsRenderer.prototype.update(self, dt, p) -- 110
	self.animTime = self.animTime + dt -- 111
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 111
		self.hitUntil = p.ticks + 14 -- 113
	end -- 113
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 113
		self.throwUntil = p.ticks + 12 -- 116
	end -- 116
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 116
		self.shotUntil = p.ticks + 7 -- 119
	end -- 119
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 121
	self.previousAxle = p.cartAxle -- 122
	self.previousHp = p.hp -- 123
	self.previousBottle = p.hasBottle -- 124
	self.previousTrace = p.trace -- 125
	local ____opt_0 = self.playerStride -- 125
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 125
		self.playerStride = strideAt(p.player) -- 127
	end -- 127
	local ____opt_2 = self.partnerStride -- 127
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 127
		self.partnerStride = strideAt(p.partner) -- 130
	end -- 130
	local steps = math.max(0, p.ticks - self.strideTick) -- 132
	advanceStride(self.playerStride, steps, dt) -- 133
	advanceStride(self.partnerStride, steps, dt) -- 134
	self.strideTick = p.ticks -- 135
	self:updateSlide(dt, steps, p, self.playerStride.speed) -- 136
end -- 110
function ActorsRenderer.prototype.slidePhase(self, a) -- 139
	local remaining = math.max(0, a.rollT - self.slideRemainder) -- 140
	return self.slideDuration > 0 and 1 - remaining / self.slideDuration or 0 -- 141
end -- 139
function ActorsRenderer.prototype.updateSlide(self, dt, steps, p, speed) -- 144
	local a = p.player -- 145
	if not p.childMode and a.rollT > 0 then -- 145
		self.slideRemainder = self.slideDuration == 0 and 0 or math.max( -- 148
			0, -- 149
			math.min(STEP, self.slideRemainder + dt - steps * STEP) -- 149
		) -- 149
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 150
		local progress = self:slidePhase(a) -- 151
		self.dustCooldown = self.dustCooldown - dt -- 152
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 152
			local ____self_slideDust_4 = self.slideDust -- 152
			____self_slideDust_4[#____self_slideDust_4 + 1] = { -- 154
				x = a.x + a.facing * a.h * 0.34, -- 155
				y = a.y, -- 156
				depth = a.depth, -- 157
				facing = a.facing, -- 158
				life = DUST_LIFE -- 159
			} -- 159
			self.dustCooldown = 0.038 -- 161
		end -- 161
	else -- 161
		self.slideDuration = 0 -- 164
		self.slideRemainder = 0 -- 165
		self.dustCooldown = 0 -- 166
	end -- 166
	local write = 0 -- 168
	for ____, dust in ipairs(self.slideDust) do -- 169
		dust.life = dust.life - dt -- 170
		if dust.life > 0 then -- 170
			self.slideDust[write + 1] = dust -- 172
			write = write + 1 -- 173
		end -- 173
	end -- 173
	__TS__ArraySetLength(self.slideDust, write) -- 173
end -- 144
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, pose) -- 179
	self:drawSlideDust(fgGlow, cam) -- 187
	local i = 0 -- 190
	do -- 190
		i = 0 -- 191
		while i < #p.enemies do -- 191
			self:drawEnemy( -- 192
				fgDraw, -- 192
				fgGlow, -- 192
				assets, -- 192
				p.enemies[i + 1], -- 192
				i, -- 192
				p, -- 192
				cam -- 192
			) -- 192
			i = i + 1 -- 191
		end -- 191
	end -- 191
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 191
		self:drawScavenger( -- 197
			fgDraw, -- 197
			fgGlow, -- 197
			assets, -- 197
			p, -- 197
			cam -- 197
		) -- 197
	end -- 197
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 197
		self:drawDog( -- 202
			fgDraw, -- 202
			fgGlow, -- 202
			assets, -- 202
			p, -- 202
			cam -- 202
		) -- 202
	end -- 202
	if p.partner.alive and not (pose and pose.partner) then -- 202
		local partnerIsChild = p.partner.w <= 28 -- 207
		if partnerIsChild then -- 207
			self:drawXiaoman( -- 209
				fgDraw, -- 209
				fgGlow, -- 209
				assets, -- 209
				p.partner, -- 209
				p, -- 209
				cam, -- 209
				false -- 209
			) -- 209
		else -- 209
			self:drawZhouShu( -- 211
				fgDraw, -- 211
				fgGlow, -- 211
				assets, -- 211
				p.partner, -- 211
				p, -- 211
				cam, -- 211
				false -- 211
			) -- 211
		end -- 211
	end -- 211
	if p.player.alive then -- 211
		if p.childMode then -- 211
			self:drawXiaoman( -- 218
				fgDraw, -- 218
				fgGlow, -- 218
				assets, -- 218
				p.player, -- 218
				p, -- 218
				cam, -- 218
				true -- 218
			) -- 218
		else -- 218
			self:drawZhouShu( -- 220
				fgDraw, -- 220
				fgGlow, -- 220
				assets, -- 220
				p.player, -- 220
				p, -- 220
				cam, -- 220
				true, -- 220
				pose and pose.player -- 220
			) -- 220
		end -- 220
	end -- 220
end -- 179
function ActorsRenderer.prototype.drawSlideDust(self, draw, cam) -- 225
	for ____, dust in ipairs(self.slideDust) do -- 226
		local alpha = dust.life / DUST_LIFE -- 227
		local spread = 1 - alpha -- 228
		local x = cam:sx(dust.x - dust.facing * spread * 17) -- 229
		local y = cam:sy(dust.y + 1.5 + spread * 2, dust.depth) -- 230
		draw:drawEllipse( -- 231
			Vec2(x, y), -- 231
			cam:len(5 + spread * 7), -- 231
			cam:len(1.5 + spread * 2), -- 231
			Color(166, 147, 124, 170 * alpha) -- 232
		) -- 232
		draw:drawDot( -- 233
			Vec2( -- 233
				x - dust.facing * cam:len(3), -- 233
				y + cam:len(4) -- 233
			), -- 233
			cam:len(1.1), -- 234
			Color(195, 174, 148, 135 * alpha) -- 234
		) -- 234
	end -- 234
end -- 225
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 239
	local half = a.w * 0.5 -- 240
	local g = 0 -- 241
	local i = 0 -- 242
	do -- 242
		i = 0 -- 243
		while i < #p.room.floors do -- 243
			local f = p.room.floors[i + 1] -- 244
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 244
				g = f.y -- 246
			end -- 246
			i = i + 1 -- 243
		end -- 243
	end -- 243
	do -- 243
		i = 0 -- 249
		while i < #p.boxes do -- 249
			do -- 249
				local b = p.boxes[i + 1] -- 250
				if b.broken == true or b.hidden == true or b.soft == true then -- 250
					goto __continue44 -- 252
				end -- 252
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 252
					g = b.y1 -- 256
				end -- 256
			end -- 256
			::__continue44:: -- 256
			i = i + 1 -- 249
		end -- 249
	end -- 249
	return g -- 259
end -- 239
function ActorsRenderer.prototype.drawGroundedShadow(self, overlayDraw, assets, shadowKey, cx, by, shadowY, wPx, airHeightWorld, actorLayer, depthScale, isControlled) -- 263
	local airborne = airHeightWorld > 1.5 -- 276
	local heightShrink = airborne and math.max(0.54, 1 / (1 + airHeightWorld / 82)) or 1 -- 277
	local shW = math.max(16, wPx * 1.48 * heightShrink) -- 278
	local shH = math.max(6, wPx * 0.42 * heightShrink) -- 279
	assets:tryPlace( -- 280
		airborne and "dp_shadow_air" or "dp_shadow_contact", -- 280
		shadowKey, -- 280
		cx, -- 280
		shadowY + 1, -- 280
		shW, -- 280
		shH, -- 280
		{layer = actorLayer - 1, opacity = airborne and 0.88 or (isControlled and 0.92 or 0.82)} -- 280
	) -- 280
	if airborne then -- 280
		local tickTop = math.min( -- 286
			by - 2, -- 286
			shadowY + math.max(6, (by - shadowY) * 0.35) -- 286
		) -- 286
		if tickTop > shadowY + 3 then -- 286
			overlayDraw:drawSegment( -- 288
				Vec2(cx, shadowY + 2), -- 288
				Vec2(cx, tickTop), -- 288
				1.1, -- 288
				Color(148, 178, 202, 118) -- 288
			) -- 288
		end -- 288
	elseif isControlled then -- 288
		local rx = shW * 0.38 -- 292
		local ry = math.max(2.2, shH * 0.32) -- 293
		local ring = {} -- 294
		do -- 294
			local i = 0 -- 295
			while i < 12 do -- 295
				local ang = i / 12 * math.pi * 2 -- 296
				ring[#ring + 1] = Vec2( -- 297
					cx + math.cos(ang) * rx, -- 297
					shadowY + 1 + math.sin(ang) * ry -- 297
				) -- 297
				i = i + 1 -- 295
			end -- 295
		end -- 295
		overlayDraw:drawPolygon( -- 299
			ring, -- 299
			Color(0, 0, 0, 0), -- 299
			0.9, -- 299
			Color( -- 299
				146, -- 299
				178, -- 299
				200, -- 299
				math.floor(74 * depthScale + 0.5) -- 299
			) -- 299
		) -- 299
	end -- 299
end -- 263
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled, bodyPlaced) -- 304
	if bodyPlaced == nil then -- 304
		bodyPlaced = false -- 312
	end -- 312
	local cx = cam:sx(a.x) -- 314
	local by = cam:sy(a.y, a.depth) -- 315
	local depthEnabled = p.room.depth ~= nil -- 316
	local groundY = depthEnabled and not a.onGround and self:supportGroundY(p, a) or a.y -- 317
	local shadowY = depthEnabled and not a.onGround and cam:sy(groundY, a.depth) or by -- 318
	local airH = math.max(0, a.y - groundY) -- 319
	local dScale = cam:depthScale(a.depth, depthEnabled) -- 320
	local H = cam:len(a.h) * dScale -- 321
	local W = cam:len(a.w) * dScale -- 322
	local f = a.facing -- 323
	local speed = math.max( -- 324
		math.abs(a.vx), -- 324
		math.abs(a.depthSpeed) -- 324
	) -- 324
	local slot = "soldier_idle" -- 326
	local height = H -- 327
	local frame = 0 -- 328
	local facing = f -- 329
	local step = math.floor(self.animTime * 10) -- 330
	local ____isControlled_9 -- 331
	if isControlled then -- 331
		____isControlled_9 = self.playerStride -- 331
	else -- 331
		____isControlled_9 = self.partnerStride -- 331
	end -- 331
	local gait = ____isControlled_9 -- 331
	if isControlled and p.ticks < self.hitUntil then -- 331
		slot = "soldier_hit" -- 333
	elseif a.rollT > 0 then -- 333
		slot = "soldier_slide" -- 335
		local progress = self:slidePhase(a) -- 336
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 337
	elseif p.phase == "prologue-give" then -- 337
		slot = "soldier_offer" -- 339
		height = height * 0.75 -- 340
		facing = p.partner.x >= a.x and 1 or -1 -- 341
	elseif isControlled and p.gripping then -- 341
		slot = "soldier_push" -- 343
		frame = self.cartMoving and step or 0 -- 344
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 345
		height = height * 0.91 -- 346
	elseif isControlled and p.escort.state == "calming" then -- 346
		slot = "soldier_knock" -- 348
		local calm = p.escort.calmTick -- 349
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 350
		height = height * 0.76 -- 351
	else -- 351
		local ____temp_12 = p.phase == "gate-send" -- 352
		if ____temp_12 then -- 352
			local ____opt_10 = p.room.story -- 352
			____temp_12 = (____opt_10 and ____opt_10.gate) ~= nil -- 352
		end -- 352
		if ____temp_12 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 352
			slot = "soldier_hold" -- 354
			height = height * 1.11 -- 355
		elseif isControlled and p.ticks < self.shotUntil then -- 355
			local running = speed > 8 -- 357
			slot = running and "soldier_fire_move" or "soldier_fire" -- 358
			frame = running and step or 0 -- 359
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 360
		elseif a.covered or isControlled and p.coverHug then -- 360
			slot = "soldier_cover" -- 362
			height = height * 0.77 -- 363
		elseif (gait and gait.speed or 0) > 8 then -- 363
			slot = "soldier_run" -- 365
			frame = step -- 366
		end -- 366
	end -- 366
	local actorLayer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 368
	local dShade = cam:depthShade(a.depth, depthEnabled) -- 369
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 370
	local pose = { -- 371
		facing = facing, -- 372
		frame = frame, -- 372
		layer = actorLayer, -- 372
		color = depthEnabled and a.depth > 6 and Color( -- 373
			tone, -- 373
			tone, -- 373
			math.min(255, tone + 8), -- 373
			255 -- 373
		) or nil -- 373
	} -- 373
	self:drawGroundedShadow( -- 375
		fgDraw, -- 375
		assets, -- 375
		"shadow_soldier", -- 375
		cx, -- 375
		by, -- 375
		shadowY, -- 375
		W, -- 375
		airH, -- 375
		actorLayer, -- 375
		dScale, -- 375
		isControlled -- 375
	) -- 375
	local sliding = not bodyPlaced and slot == "soldier_slide" and assets:tryPlaceSlide( -- 376
		"actor_soldier", -- 377
		cx, -- 377
		by, -- 377
		W, -- 377
		height, -- 377
		self:slidePhase(a), -- 377
		pose -- 377
	) -- 377
	local running = not bodyPlaced and (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 378
		"soldier", -- 380
		"actor_soldier", -- 380
		cx, -- 380
		by, -- 380
		W, -- 380
		height, -- 380
		gait.cycle, -- 380
		pose, -- 380
		gait.effort -- 380
	) -- 380
	if bodyPlaced or sliding or running or assets:tryPlace( -- 380
		slot, -- 381
		"actor_soldier", -- 381
		cx, -- 381
		by, -- 381
		W, -- 381
		height, -- 381
		pose -- 381
	) then -- 381
		return -- 382
	end -- 382
	fgDraw:drawRect( -- 385
		Rect(cx - W * 0.4, by, W * 0.8, height), -- 385
		Color(32, 46, 66, 220) -- 385
	) -- 385
end -- 304
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 389
	local cx = cam:sx(a.x) -- 398
	local by = cam:sy(a.y, a.depth) -- 399
	local depthEnabled = p.room.depth ~= nil -- 400
	local groundY = depthEnabled and not a.onGround and self:supportGroundY(p, a) or a.y -- 401
	local shadowY = depthEnabled and not a.onGround and cam:sy(groundY, a.depth) or by -- 402
	local airH = math.max(0, a.y - groundY) -- 403
	local dScale = cam:depthScale(a.depth, depthEnabled) -- 404
	local H = cam:len(a.h) * dScale -- 405
	local W = cam:len(a.w) * dScale -- 406
	local f = a.facing -- 407
	local speed = math.max( -- 408
		math.abs(a.vx), -- 408
		math.abs(a.depthSpeed) -- 408
	) -- 408
	local ____isControlled_15 -- 409
	if isControlled then -- 409
		____isControlled_15 = self.playerStride -- 409
	else -- 409
		____isControlled_15 = self.partnerStride -- 409
	end -- 409
	local gait = ____isControlled_15 -- 409
	local afraid = not isControlled and p.escort.fear > 0 -- 411
	local slot = "child_idle" -- 412
	local height = H -- 413
	local frame = 0 -- 414
	local step = math.floor(self.animTime * 10) -- 415
	local nearCover = __TS__ArraySome( -- 416
		p.room.solids, -- 416
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 416
			math.abs(a.x - solid.x), -- 419
			math.abs(a.x - solid.x - solid.w) -- 419
		) <= 30 end -- 419
	) -- 419
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 419
		slot = "child_knock" -- 422
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 422
		slot = "child_offer" -- 425
	elseif isControlled and p.ticks < self.throwUntil then -- 425
		slot = "child_throw" -- 427
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 427
		slot = "child_aim" -- 429
	elseif isControlled and p.gripping then -- 429
		slot = "child_pull" -- 431
		frame = self.cartMoving and step or 0 -- 432
	elseif afraid and p.escort.state == "frozen" then -- 432
		slot = "child_fear" -- 434
		height = height * 0.74 -- 435
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 435
		slot = "child_peek" -- 438
		height = height * 0.83 -- 439
	elseif a.crouch then -- 439
		slot = "child_crouch" -- 441
		frame = speed > 8 and step or 0 -- 442
	elseif (gait and gait.speed or 0) > 8 then -- 442
		slot = "child_run" -- 444
		frame = step -- 445
	end -- 445
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 447
	local actorLayer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 448
	local dShade = cam:depthShade(a.depth, depthEnabled) -- 449
	local tone = math.floor(255 * math.min(1, dShade + 0.06) + 0.5) -- 450
	local pose = { -- 451
		facing = facing, -- 452
		frame = frame, -- 452
		layer = actorLayer, -- 452
		color = depthEnabled and a.depth > 6 and Color( -- 453
			tone, -- 453
			tone, -- 453
			math.min(255, tone + 6), -- 453
			255 -- 453
		) or nil -- 453
	} -- 453
	self:drawGroundedShadow( -- 455
		fgDraw, -- 455
		assets, -- 455
		"shadow_child", -- 455
		cx, -- 455
		by, -- 455
		shadowY, -- 455
		W, -- 455
		airH, -- 455
		actorLayer, -- 455
		dScale, -- 455
		isControlled -- 455
	) -- 455
	local running = (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 456
		"child", -- 458
		"actor_child", -- 458
		cx, -- 458
		by, -- 458
		W, -- 458
		height, -- 458
		gait.cycle, -- 458
		pose, -- 458
		gait.effort -- 458
	) -- 458
	if running or assets:tryPlace( -- 458
		slot, -- 459
		"actor_child", -- 459
		cx, -- 459
		by, -- 459
		W, -- 459
		height, -- 459
		pose -- 459
	) then -- 459
		if afraid then -- 459
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 461
		end -- 461
		return -- 463
	end -- 463
	fgDraw:drawRect( -- 465
		Rect(cx - W * 0.4, by, W * 0.8, height), -- 465
		Color(168, 126, 72, 220) -- 465
	) -- 465
	if afraid then -- 465
		self:drawFear(fgGlow, p, cx, by + H + 16) -- 467
	end -- 467
end -- 389
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 471
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 472
	do -- 472
		local i = 0 -- 473
		while i < FEAR_MAX do -- 473
			local lit = i < p.escort.fear -- 474
			drawDiamond( -- 475
				fgGlow, -- 475
				x + (i - 1) * 13, -- 475
				y, -- 475
				4, -- 475
				5, -- 475
				toColor(lit and tint or PALETTE.steelDark, 215), -- 476
				1, -- 476
				toColor(tint, lit and 235 or 100) -- 476
			) -- 476
			i = i + 1 -- 473
		end -- 473
	end -- 473
end -- 471
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 480
	local x = cam:sx(e.x + f * 20) -- 481
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 482
	local dx = cam:sx(p.player.x) - x -- 483
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 484
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 485
	do -- 485
		local i = 0 -- 486
		while i < 8 do -- 486
			local a = length * i / 8 -- 487
			local b = length * (i + 1) / 8 -- 488
			fgGlow:drawSegment( -- 489
				Vec2(x + dx * a, y + dy * a), -- 489
				Vec2(x + dx * b, y + dy * b), -- 489
				1.3, -- 490
				Color(220, 120, 88, 210) -- 490
			) -- 490
			i = i + 2 -- 486
		end -- 486
	end -- 486
end -- 480
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 495
	local cx = cam:sx(e.x) -- 504
	local depth = e.depth or 0 -- 505
	local depthEnabled = p.room.depth ~= nil -- 506
	local dScale = cam:depthScale(depth, depthEnabled) -- 507
	local by = cam:sy(e.y, depth) -- 508
	local H = cam:len(e.h) * dScale -- 509
	local W = cam:len(e.w) * dScale -- 510
	local f = p.player.x >= e.x and 1 or -1 -- 511
	if e.kind == "target" then -- 511
		local targetLayer = depthEnabled and depthOrder(depth, 3) or 3 -- 515
		self:drawGroundedShadow( -- 516
			fgDraw, -- 516
			assets, -- 516
			"shadow_target_" .. tostring(index), -- 516
			cx, -- 516
			by, -- 516
			by, -- 516
			W * 1.1, -- 516
			0, -- 516
			targetLayer, -- 516
			dScale, -- 516
			false -- 516
		) -- 516
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 517
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 518
		assets:tryPlacePath( -- 519
			"assets/art/props_ming.clip|target_dummy", -- 519
			"actor_target_" .. tostring(index), -- 519
			cx, -- 519
			by, -- 519
			H * 0.82, -- 519
			H * 0.96, -- 519
			{ -- 519
				anchorX = 0.5, -- 520
				anchorY = 0, -- 521
				preserveAspect = true, -- 522
				angle = angle, -- 523
				color = tint, -- 524
				opacity = e.alive and 1 or 0.76, -- 525
				layer = targetLayer -- 526
			} -- 526
		) -- 526
		return -- 528
	end -- 528
	local enemyLayer = depthEnabled and depthOrder(depth, 3) or 3 -- 531
	if e.alive then -- 531
		self:drawGroundedShadow( -- 533
			fgDraw, -- 533
			assets, -- 533
			"shadow_enemy_" .. tostring(index), -- 533
			cx, -- 533
			by, -- 533
			by, -- 533
			W * 1.05, -- 533
			0, -- 533
			enemyLayer, -- 533
			dScale, -- 533
			false -- 533
		) -- 533
	end -- 533
	if e.alive and e.hitT <= 0 then -- 533
		local extraClip = "" -- 537
		local extraAnchorX = 0.5 -- 538
		local extraHeight = H * 0.96 -- 539
		local extraTint = Color(255, 255, 255, 255) -- 540
		if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 540
			extraClip = e.warnT > 0 and "enemy_shield_aim" or "enemy_shield_idle" -- 542
			extraAnchorX = e.warnT > 0 and 0.45 or 0.5 -- 543
			extraHeight = H * 0.94 -- 544
			if (e.shieldHp or 2) <= 1 then -- 544
				extraTint = Color(234, 198, 178, 255) -- 546
			end -- 546
		elseif e.kind == "breaker" then -- 546
			local swing = (e.swingT or 0) > 0 or e.warnT > 0 -- 549
			extraClip = swing and "enemy_breaker_aim" or "enemy_breaker_idle" -- 550
			extraAnchorX = swing and 0.52 or 0.38 -- 551
			extraHeight = H * (swing and 0.98 or 0.94) -- 552
		elseif e.kind == "leader" then -- 552
			extraClip = e.warnT > 0 and "enemy_leader_aim" or "enemy_leader_idle" -- 554
			extraAnchorX = e.warnT > 0 and 0.38 or 0.44 -- 555
			extraHeight = H * 1 -- 556
		end -- 556
		if extraClip ~= "" and assets:tryPlacePath( -- 556
			"assets/art/actors_extra.clip|" .. extraClip, -- 559
			"actor_enemy_" .. tostring(index), -- 560
			cx, -- 561
			by, -- 562
			W * 1.8, -- 563
			extraHeight, -- 564
			{ -- 565
				anchorX = extraAnchorX, -- 566
				anchorY = 0, -- 567
				preserveAspect = true, -- 568
				facing = f, -- 569
				color = extraTint, -- 570
				layer = enemyLayer -- 571
			} -- 571
		) then -- 571
			if e.kind == "breaker" and (e.swingT or 0) > 0 then -- 571
				fgGlow:drawArc( -- 575
					Vec2( -- 575
						cx + f * cam:len(10), -- 575
						by + H * 0.56 -- 575
					), -- 575
					cam:len(18), -- 575
					f > 0 and -40 or 140, -- 575
					f > 0 and 50 or 230, -- 575
					1.8, -- 575
					toColor(PALETTE.rouge, 195) -- 575
				) -- 575
			end -- 575
			if e.warnT > 0 then -- 575
				self:drawEnemyWarning( -- 578
					fgGlow, -- 578
					e, -- 578
					p, -- 578
					cam, -- 578
					f -- 578
				) -- 578
			end -- 578
			return -- 580
		end -- 580
	end -- 580
	local slot = "enemy_idle" -- 584
	if not e.alive then -- 584
		slot = "enemy_down" -- 586
	elseif e.hitT > 0 then -- 586
		slot = "enemy_hit" -- 588
	elseif e.warnT > 0 then -- 588
		slot = "enemy_aim" -- 590
	end -- 590
	local height = e.alive and H or H * 0.24 -- 592
	if assets:tryPlace( -- 592
		slot, -- 593
		"actor_enemy_" .. tostring(index), -- 593
		cx, -- 593
		by, -- 593
		W, -- 593
		height, -- 593
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 593
	) then -- 593
		if e.alive then -- 593
			self:drawEnemyArchetypeGear( -- 597
				fgDraw, -- 597
				fgGlow, -- 597
				assets, -- 597
				e, -- 597
				index, -- 597
				cx, -- 597
				by, -- 597
				H, -- 597
				f, -- 597
				cam, -- 597
				enemyLayer + 1 -- 597
			) -- 597
			if e.warnT > 0 then -- 597
				self:drawEnemyWarning( -- 599
					fgGlow, -- 599
					e, -- 599
					p, -- 599
					cam, -- 599
					f -- 599
				) -- 599
			end -- 599
		end -- 599
		return -- 602
	end -- 602
	if e.alive then -- 602
		fgDraw:drawRect( -- 605
			Rect(cx - W * 0.4, by, W * 0.8, height), -- 605
			Color(96, 56, 48, 220) -- 605
		) -- 605
	end -- 605
end -- 495
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 610
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 610
		local shX = cx + f * cam:len(13) -- 624
		local cracked = (e.shieldHp or 2) <= 1 -- 625
		if not assets:tryPlace( -- 625
			"fe_gear_rattan_shield", -- 626
			"enemy_shield_" .. tostring(index), -- 626
			shX, -- 626
			by + H * 0.44, -- 626
			cam:len(22), -- 626
			H * 0.64, -- 626
			{ -- 626
				facing = f, -- 627
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 628
				layer = layer -- 629
			} -- 629
		) then -- 629
			local shW = math.max( -- 631
				5, -- 631
				cam:len(8) -- 631
			) -- 631
			fgDraw:drawRect( -- 632
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 632
				Color(96, 66, 42, 250), -- 632
				1.3, -- 632
				Color(168, 174, 180, 230) -- 632
			) -- 632
		end -- 632
		if cracked then -- 632
			fgDraw:drawSegment( -- 635
				Vec2( -- 635
					shX - cam:len(4), -- 635
					by + H * 0.3 -- 635
				), -- 635
				Vec2( -- 635
					shX + cam:len(4), -- 635
					by + H * 0.56 -- 635
				), -- 635
				1.4, -- 635
				Color(24, 18, 16, 235) -- 635
			) -- 635
		end -- 635
	elseif e.kind == "breaker" then -- 635
		local swing = (e.swingT or 0) > 0 -- 638
		local handleX0 = cx - f * cam:len(4) -- 639
		local handleY0 = by + H * 0.44 -- 640
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 641
		local tipY = by + H * (swing and 0.46 or 0.78) -- 642
		fgDraw:drawSegment( -- 643
			Vec2(handleX0, handleY0), -- 643
			Vec2(tipX, tipY), -- 643
			math.max( -- 643
				2.2, -- 643
				cam:len(3) -- 643
			), -- 643
			Color(98, 66, 44, 255) -- 643
		) -- 643
		fgDraw:drawPolygon( -- 644
			{ -- 644
				Vec2( -- 645
					tipX - f * cam:len(3), -- 645
					tipY - cam:len(4) -- 645
				), -- 645
				Vec2( -- 646
					tipX + f * cam:len(9), -- 646
					tipY - cam:len(1) -- 646
				), -- 646
				Vec2( -- 647
					tipX + f * cam:len(7), -- 647
					tipY + cam:len(9) -- 647
				), -- 647
				Vec2( -- 648
					tipX - f * cam:len(2), -- 648
					tipY + cam:len(6) -- 648
				) -- 648
			}, -- 648
			Color(148, 154, 162, 250), -- 649
			1, -- 649
			Color(224, 228, 232, 220) -- 649
		) -- 649
		if swing then -- 649
			fgGlow:drawArc( -- 651
				Vec2( -- 651
					cx + f * cam:len(10), -- 651
					by + H * 0.56 -- 651
				), -- 651
				cam:len(18), -- 651
				f > 0 and -40 or 140, -- 651
				f > 0 and 50 or 230, -- 651
				1.8, -- 651
				toColor(PALETTE.rouge, 195) -- 651
			) -- 651
		end -- 651
	elseif e.kind == "leader" then -- 651
		local topY = by + H * 1.02 -- 655
		fgDraw:drawSegment( -- 656
			Vec2(cx, topY), -- 656
			Vec2( -- 656
				cx - f * cam:len(10), -- 656
				topY + cam:len(9) -- 656
			), -- 656
			2.2, -- 656
			toColor(PALETTE.rouge, 240) -- 656
		) -- 656
		fgDraw:drawDot( -- 657
			Vec2( -- 657
				cx - f * cam:len(10), -- 657
				topY + cam:len(9) -- 657
			), -- 657
			2.6, -- 657
			toColor(PALETTE.crimsonCore, 235) -- 657
		) -- 657
	end -- 657
end -- 610
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 662
	local s = p.room.scavenger -- 669
	if s == nil then -- 669
		return -- 671
	end -- 671
	local cx = cam:sx(p.scavX) -- 673
	local by = cam:sy(s.y) -- 674
	local H = cam:len(s.h) -- 675
	local W = cam:len(26) -- 676
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 677
	local alert = p.scavChase or p.scavSee > 0 -- 680
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 681
	local eyeY = by + H * 0.8 -- 682
	local coneLen = cam:len(alert and 155 or 115) -- 683
	fgGlow:drawVertices({ -- 684
		{ -- 685
			Vec2(cx + f * 6, eyeY), -- 685
			toColor(coneCol, alert and 78 or 34) -- 685
		}, -- 685
		{ -- 686
			Vec2(cx + f * coneLen, by + H * 1.05), -- 686
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 686
		}, -- 686
		{ -- 687
			Vec2(cx + f * coneLen, by + 4), -- 687
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 687
		} -- 687
	}) -- 687
	local frame = 0 -- 690
	if p.scavState == "turn" then -- 690
		frame = 2 -- 692
	elseif p.scavState == "chase" then -- 692
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 694
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 694
		frame = math.floor(self.animTime * 8) % 2 -- 696
	end -- 696
	if assets:tryPlace( -- 696
		"scavenger", -- 698
		"actor_scav", -- 698
		cx, -- 698
		by, -- 698
		W, -- 698
		H, -- 698
		{facing = f, frame = frame, layer = 3} -- 698
	) then -- 698
		return -- 699
	end -- 699
	fgDraw:drawEllipse( -- 702
		Vec2(cx, by + 1), -- 702
		W * 0.62, -- 702
		4, -- 702
		Color(4, 6, 10, 155) -- 702
	) -- 702
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 703
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 704
	fgDraw:drawSegment( -- 706
		Vec2(cx - 4, by + H * 0.4), -- 706
		Vec2(cx - stride, by + 2), -- 706
		W * 0.16, -- 706
		Color(32, 30, 28, 255) -- 706
	) -- 706
	fgDraw:drawSegment( -- 707
		Vec2(cx + 4, by + H * 0.4), -- 707
		Vec2(cx + stride, by + 2), -- 707
		W * 0.16, -- 707
		Color(44, 40, 36, 255) -- 707
	) -- 707
	fgDraw:drawPolygon( -- 709
		{ -- 709
			Vec2(cx - W * 0.45, by + H * 0.25), -- 710
			Vec2(cx + W * 0.42, by + H * 0.25), -- 711
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 712
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 713
		}, -- 713
		Color(56, 52, 46, 255), -- 714
		1.2, -- 714
		Color(128, 118, 100, 180) -- 714
	) -- 714
	local headX = cx + f * 5 -- 716
	local headY = by + H * 0.88 -- 717
	fgDraw:drawCircle( -- 718
		Vec2(headX, headY), -- 718
		W * 0.3, -- 718
		Color(42, 38, 34, 255) -- 718
	) -- 718
	fgGlow:drawDot( -- 719
		Vec2(headX + f * 6, headY), -- 719
		3, -- 719
		toColor(coneCol, 245) -- 719
	) -- 719
	local indY = by + H + 18 -- 722
	if p.scavChase then -- 722
		drawDiamond( -- 724
			fgGlow, -- 724
			cx, -- 724
			indY, -- 724
			9, -- 724
			12, -- 724
			toColor(PALETTE.crimson, 240), -- 724
			1.5, -- 724
			toColor(PALETTE.crimsonCore) -- 724
		) -- 724
	elseif p.scavSee > 0 then -- 724
		local frac = math.min(1, p.scavSee / 24) -- 726
		fgGlow:drawArc( -- 727
			Vec2(cx, indY), -- 727
			11, -- 727
			90, -- 727
			90 - 360 * frac, -- 727
			2.4, -- 727
			toColor(PALETTE.crimson, 235) -- 727
		) -- 727
		fgGlow:drawDot( -- 728
			Vec2(cx, indY), -- 728
			3, -- 728
			toColor(PALETTE.amber) -- 728
		) -- 728
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 728
		drawDiamond( -- 730
			fgGlow, -- 730
			cx, -- 730
			indY, -- 730
			6, -- 730
			8, -- 730
			toColor(PALETTE.amber, 220) -- 730
		) -- 730
	end -- 730
end -- 662
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 735
	local cx = cam:sx(p.dogX) -- 742
	local by = cam:sy(0) -- 743
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 744
	local W = cam:len(34) -- 745
	local H = cam:len(28) -- 746
	local frame = 0 -- 748
	if p.dogState == "ear" then -- 748
		frame = 1 -- 750
	elseif p.dogState == "sniff" then -- 750
		frame = 3 -- 752
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 752
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 754
	end -- 754
	if assets:tryPlace( -- 754
		"dog", -- 756
		"actor_dog", -- 756
		cx, -- 756
		by, -- 756
		W, -- 756
		H, -- 756
		{facing = f, frame = frame, layer = 3} -- 756
	) then -- 756
		return -- 757
	end -- 757
	fgDraw:drawEllipse( -- 760
		Vec2(cx, by + 1), -- 760
		W * 0.56, -- 760
		3.5, -- 760
		Color(4, 8, 10, 155) -- 760
	) -- 760
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 761
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 762
	fgDraw:drawSegment( -- 765
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 765
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 765
		2.8, -- 765
		Color(26, 30, 34, 255) -- 765
	) -- 765
	fgDraw:drawSegment( -- 766
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 766
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 766
		2.8, -- 766
		Color(36, 40, 44, 255) -- 766
	) -- 766
	fgDraw:drawPolygon( -- 768
		{ -- 768
			Vec2(cx - W * 0.42, by + H * 0.36), -- 769
			Vec2(cx + W * 0.38, by + H * 0.42), -- 770
			Vec2(cx + W * 0.34, by + H * 0.78), -- 771
			Vec2(cx - W * 0.38, by + H * 0.72) -- 772
		}, -- 772
		Color(38, 42, 48, 255), -- 773
		1.2, -- 773
		Color(102, 118, 126, 175) -- 773
	) -- 773
	local hx = cx + f * W * 0.42 -- 774
	local hy = by + H * 0.84 -- 775
	fgDraw:drawPolygon( -- 776
		{ -- 776
			Vec2(hx - f * 8, hy - 6), -- 777
			Vec2(hx + f * 12, hy - 2), -- 778
			Vec2(hx + f * 4, hy + 8), -- 779
			Vec2(hx - f * 6, hy + 14) -- 780
		}, -- 780
		Color(44, 48, 54, 255) -- 781
	) -- 781
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 783
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 784
	fgGlow:drawDot( -- 785
		Vec2(hx + f * 4, hy + 2), -- 785
		2.8, -- 785
		toColor(eyeCol, 250) -- 785
	) -- 785
	fillRadialGlow( -- 786
		fgGlow, -- 786
		hx + f * 4, -- 786
		hy + 2, -- 786
		16, -- 786
		16, -- 786
		toColor(eyeCol, alert and 135 or 70), -- 786
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 786
		12 -- 786
	) -- 786
	if alert then -- 786
		local r = 12 + self.animTime * 42 % 24 -- 789
		fgGlow:drawArc( -- 790
			Vec2(hx, hy + 12), -- 790
			r, -- 790
			35, -- 790
			145, -- 790
			1.8, -- 790
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 790
		) -- 790
	end -- 790
end -- 735
return ____exports -- 735