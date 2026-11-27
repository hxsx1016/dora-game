-- [ts]: actors.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
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
local ____theme = require("Script.watch.fe.theme") -- 11
local PALETTE = ____theme.PALETTE -- 11
local drawDiamond = ____theme.drawDiamond -- 11
local fillRadialGlow = ____theme.fillRadialGlow -- 11
local toColor = ____theme.toColor -- 11
local function strideAt(actor) -- 29
	return { -- 30
		actor = actor, -- 30
		x = actor.x, -- 30
		depth = actor.depth, -- 30
		speed = 0, -- 30
		cycle = 0, -- 30
		effort = 0 -- 30
	} -- 30
end -- 29
local RUN_START_T = 0.1 -- 33
local RUN_STOP_T = 0.13 -- 34
local function advanceStride(stride, steps, dt) -- 36
	local a = stride.actor -- 37
	if steps > 0 then -- 37
		local dx = a.x - stride.x -- 39
		local depth = a.depth - stride.depth -- 40
		local speed = math.sqrt(dx * dx + depth * depth) / (steps * STEP) -- 41
		stride.speed = speed <= 380 and speed or 0 -- 42
		stride.x = a.x -- 43
		stride.depth = a.depth -- 44
	end -- 44
	if not a.alive or not a.onGround or a.crouch or a.covered or a.rollT > 0 then -- 44
		stride.effort = 0 -- 47
		return -- 48
	end -- 48
	if stride.speed > 8 then -- 48
		stride.effort = math.min(1, stride.effort + dt / RUN_START_T) -- 51
		local strideLength = a.h * (a.w <= 28 and 1.4 or 1.32) -- 52
		stride.cycle = (stride.cycle + stride.speed * dt / strideLength) % 1 -- 53
	else -- 53
		stride.effort = math.max(0, stride.effort - dt / RUN_STOP_T) -- 55
	end -- 55
end -- 36
local DUST_LIFE = 0.23 -- 59
____exports.ActorsRenderer = __TS__Class() -- 61
local ActorsRenderer = ____exports.ActorsRenderer -- 61
ActorsRenderer.name = "ActorsRenderer" -- 61
function ActorsRenderer.prototype.____constructor(self) -- 61
	self.slideDust = {} -- 62
	self.dustCooldown = 0 -- 63
	self.slideDuration = 0 -- 64
	self.slideRemainder = 0 -- 65
	self.strideTick = 0 -- 66
	self.animTime = 0 -- 69
	self.previousHp = 3 -- 70
	self.previousAxle = 0 -- 71
	self.cartMoving = false -- 72
	self.previousBottle = false -- 73
	self.hitUntil = -1 -- 75
	self.throwUntil = -1 -- 76
	self.shotUntil = -1 -- 77
end -- 61
function ActorsRenderer.prototype.reset(self, p) -- 79
	self.slideDust = {} -- 80
	self.dustCooldown = 0 -- 81
	self.slideDuration = 0 -- 82
	self.slideRemainder = 0 -- 83
	self.strideTick = p.ticks -- 84
	self.playerStride = strideAt(p.player) -- 85
	self.partnerStride = strideAt(p.partner) -- 86
	self.animTime = 0 -- 87
	self.previousHp = p.hp -- 88
	self.previousAxle = p.cartAxle -- 89
	self.cartMoving = false -- 90
	self.previousBottle = p.hasBottle -- 91
	self.previousTrace = p.trace -- 92
	self.hitUntil = -1 -- 93
	self.throwUntil = -1 -- 94
	self.shotUntil = -1 -- 95
end -- 79
function ActorsRenderer.prototype.update(self, dt, p) -- 99
	self.animTime = self.animTime + dt -- 100
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 100
		self.hitUntil = p.ticks + 14 -- 102
	end -- 102
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 102
		self.throwUntil = p.ticks + 12 -- 105
	end -- 105
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 105
		self.shotUntil = p.ticks + 7 -- 108
	end -- 108
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 110
	self.previousAxle = p.cartAxle -- 111
	self.previousHp = p.hp -- 112
	self.previousBottle = p.hasBottle -- 113
	self.previousTrace = p.trace -- 114
	local ____opt_0 = self.playerStride -- 114
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 114
		self.playerStride = strideAt(p.player) -- 116
	end -- 116
	local ____opt_2 = self.partnerStride -- 116
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 116
		self.partnerStride = strideAt(p.partner) -- 119
	end -- 119
	local steps = math.max(0, p.ticks - self.strideTick) -- 121
	advanceStride(self.playerStride, steps, dt) -- 122
	advanceStride(self.partnerStride, steps, dt) -- 123
	self.strideTick = p.ticks -- 124
	self:updateSlide(dt, steps, p, self.playerStride.speed) -- 125
end -- 99
function ActorsRenderer.prototype.slidePhase(self, a) -- 128
	local remaining = math.max(0, a.rollT - self.slideRemainder) -- 129
	return self.slideDuration > 0 and 1 - remaining / self.slideDuration or 0 -- 130
end -- 128
function ActorsRenderer.prototype.updateSlide(self, dt, steps, p, speed) -- 133
	local a = p.player -- 134
	if not p.childMode and a.rollT > 0 then -- 134
		self.slideRemainder = self.slideDuration == 0 and 0 or math.max( -- 137
			0, -- 138
			math.min(STEP, self.slideRemainder + dt - steps * STEP) -- 138
		) -- 138
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 139
		local progress = self:slidePhase(a) -- 140
		self.dustCooldown = self.dustCooldown - dt -- 141
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 141
			local ____self_slideDust_4 = self.slideDust -- 141
			____self_slideDust_4[#____self_slideDust_4 + 1] = {x = a.x + a.facing * a.h * 0.34, y = a.y + a.depth, facing = a.facing, life = DUST_LIFE} -- 143
			self.dustCooldown = 0.038 -- 149
		end -- 149
	else -- 149
		self.slideDuration = 0 -- 152
		self.slideRemainder = 0 -- 153
		self.dustCooldown = 0 -- 154
	end -- 154
	local write = 0 -- 156
	for ____, dust in ipairs(self.slideDust) do -- 157
		dust.life = dust.life - dt -- 158
		if dust.life > 0 then -- 158
			self.slideDust[write + 1] = dust -- 160
			write = write + 1 -- 161
		end -- 161
	end -- 161
	__TS__ArraySetLength(self.slideDust, write) -- 161
end -- 133
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 167
	if suppressPartner == nil then -- 167
		suppressPartner = false -- 173
	end -- 173
	self:drawSlideDust(fgGlow, cam) -- 175
	local i = 0 -- 178
	do -- 178
		i = 0 -- 179
		while i < #p.enemies do -- 179
			self:drawEnemy( -- 180
				fgDraw, -- 180
				fgGlow, -- 180
				assets, -- 180
				p.enemies[i + 1], -- 180
				i, -- 180
				p, -- 180
				cam -- 180
			) -- 180
			i = i + 1 -- 179
		end -- 179
	end -- 179
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 179
		self:drawScavenger( -- 185
			fgDraw, -- 185
			fgGlow, -- 185
			assets, -- 185
			p, -- 185
			cam -- 185
		) -- 185
	end -- 185
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 185
		self:drawDog( -- 190
			fgDraw, -- 190
			fgGlow, -- 190
			assets, -- 190
			p, -- 190
			cam -- 190
		) -- 190
	end -- 190
	if p.partner.alive and not suppressPartner then -- 190
		local partnerIsChild = p.partner.w <= 28 -- 195
		if partnerIsChild then -- 195
			self:drawXiaoman( -- 197
				fgDraw, -- 197
				fgGlow, -- 197
				assets, -- 197
				p.partner, -- 197
				p, -- 197
				cam, -- 197
				false -- 197
			) -- 197
		else -- 197
			self:drawZhouShu( -- 199
				fgDraw, -- 199
				fgGlow, -- 199
				assets, -- 199
				p.partner, -- 199
				p, -- 199
				cam, -- 199
				false -- 199
			) -- 199
		end -- 199
	end -- 199
	if p.player.alive then -- 199
		if p.childMode then -- 199
			self:drawXiaoman( -- 206
				fgDraw, -- 206
				fgGlow, -- 206
				assets, -- 206
				p.player, -- 206
				p, -- 206
				cam, -- 206
				true -- 206
			) -- 206
		else -- 206
			self:drawZhouShu( -- 208
				fgDraw, -- 208
				fgGlow, -- 208
				assets, -- 208
				p.player, -- 208
				p, -- 208
				cam, -- 208
				true -- 208
			) -- 208
		end -- 208
	end -- 208
end -- 167
function ActorsRenderer.prototype.drawSlideDust(self, draw, cam) -- 213
	for ____, dust in ipairs(self.slideDust) do -- 214
		local alpha = dust.life / DUST_LIFE -- 215
		local spread = 1 - alpha -- 216
		local x = cam:sx(dust.x - dust.facing * spread * 17) -- 217
		local y = cam:sy(dust.y + 1.5 + spread * 2) -- 218
		draw:drawEllipse( -- 219
			Vec2(x, y), -- 219
			cam:len(5 + spread * 7), -- 219
			cam:len(1.5 + spread * 2), -- 219
			Color(166, 147, 124, 170 * alpha) -- 220
		) -- 220
		draw:drawDot( -- 221
			Vec2( -- 221
				x - dust.facing * cam:len(3), -- 221
				y + cam:len(4) -- 221
			), -- 221
			cam:len(1.1), -- 222
			Color(195, 174, 148, 135 * alpha) -- 222
		) -- 222
	end -- 222
end -- 213
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 227
	local cx = cam:sx(a.x) -- 236
	local by = cam:sy(a.y, a.depth) -- 237
	local depthEnabled = p.room.depth ~= nil -- 238
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 239
	local H = cam:len(a.h) -- 240
	local W = cam:len(a.w) -- 241
	local f = a.facing -- 242
	local speed = math.max( -- 243
		math.abs(a.vx), -- 243
		math.abs(a.depthSpeed) -- 243
	) -- 243
	local slot = "soldier_idle" -- 245
	local height = H -- 246
	local frame = 0 -- 247
	local facing = f -- 248
	local step = math.floor(self.animTime * 10) -- 249
	local ____isControlled_5 -- 250
	if isControlled then -- 250
		____isControlled_5 = self.playerStride -- 250
	else -- 250
		____isControlled_5 = self.partnerStride -- 250
	end -- 250
	local gait = ____isControlled_5 -- 250
	if isControlled and p.ticks < self.hitUntil then -- 250
		slot = "soldier_hit" -- 252
	elseif a.rollT > 0 then -- 252
		slot = "soldier_slide" -- 254
		local progress = self:slidePhase(a) -- 255
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 256
	elseif p.phase == "prologue-give" then -- 256
		slot = "soldier_offer" -- 258
		height = height * 0.75 -- 259
		facing = p.partner.x >= a.x and 1 or -1 -- 260
	elseif isControlled and p.gripping then -- 260
		slot = "soldier_push" -- 262
		frame = self.cartMoving and step or 0 -- 263
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 264
		height = height * 0.91 -- 265
	elseif isControlled and p.escort.state == "calming" then -- 265
		slot = "soldier_knock" -- 267
		local calm = p.escort.calmTick -- 268
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 269
		height = height * 0.76 -- 270
	else -- 270
		local ____temp_8 = p.phase == "gate-send" -- 271
		if ____temp_8 then -- 271
			local ____opt_6 = p.room.story -- 271
			____temp_8 = (____opt_6 and ____opt_6.gate) ~= nil -- 271
		end -- 271
		if ____temp_8 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 271
			slot = "soldier_hold" -- 273
			height = height * 1.11 -- 274
		elseif isControlled and p.ticks < self.shotUntil then -- 274
			local running = speed > 8 -- 276
			slot = running and "soldier_fire_move" or "soldier_fire" -- 277
			frame = running and step or 0 -- 278
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 279
		elseif a.covered or isControlled and p.coverHug then -- 279
			slot = "soldier_cover" -- 281
			height = height * 0.77 -- 282
		elseif (gait and gait.speed or 0) > 8 then -- 282
			slot = "soldier_run" -- 284
			frame = step -- 285
		end -- 285
	end -- 285
	local pose = { -- 287
		facing = facing, -- 288
		frame = frame, -- 288
		layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 288
	} -- 288
	local sliding = slot == "soldier_slide" and assets:tryPlaceSlide( -- 290
		"actor_soldier", -- 291
		cx, -- 291
		by, -- 291
		W, -- 291
		height, -- 291
		self:slidePhase(a), -- 291
		pose -- 291
	) -- 291
	local running = (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 292
		"soldier", -- 294
		"actor_soldier", -- 294
		cx, -- 294
		by, -- 294
		W, -- 294
		height, -- 294
		gait.cycle, -- 294
		pose, -- 294
		gait.effort -- 294
	) -- 294
	if sliding or running or assets:tryPlace( -- 294
		slot, -- 295
		"actor_soldier", -- 295
		cx, -- 295
		by, -- 295
		W, -- 295
		height, -- 295
		pose -- 295
	) then -- 295
		fgDraw:drawEllipse( -- 296
			Vec2(cx, shadowY + 1), -- 296
			W * 0.54, -- 296
			4, -- 296
			Color(12, 11, 13, 145) -- 296
		) -- 296
		return -- 297
	end -- 297
	fgDraw:drawEllipse( -- 301
		Vec2(cx, shadowY + 1), -- 301
		H * 0.24, -- 301
		4.5, -- 301
		Color(3, 5, 10, 175) -- 301
	) -- 301
	local walking = speed > 10 and a.onGround -- 303
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 304
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 305
	local calming = not p.childMode and p.escort.state == "calming" -- 306
	local rolling = a.rollT > 0 -- 307
	local crouching = a.covered or calming or rolling -- 308
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 311
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 312
	local sw = H * 0.115 -- 313
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 316
	local kneeY = by + bodyH * 0.23 -- 317
	local stepX = stride * H * 0.15 -- 318
	local legDark = Color(14, 21, 34, 255) -- 319
	local legFront = Color(26, 38, 58, 255) -- 320
	local bkX = cx - f * 4 - stepX * 0.5 -- 322
	local bfX = cx - f * 8 - stepX -- 323
	fgDraw:drawSegment( -- 324
		Vec2(cx - f * 3, hipY), -- 324
		Vec2(bkX, kneeY), -- 324
		H * 0.044, -- 324
		legDark -- 324
	) -- 324
	fgDraw:drawSegment( -- 325
		Vec2(bkX, kneeY), -- 325
		Vec2(bfX, by + 3), -- 325
		H * 0.038, -- 325
		legDark -- 325
	) -- 325
	local fkX = cx + f * 6 + stepX * 0.55 -- 327
	local ffX = cx + f * 7 + stepX -- 328
	fgDraw:drawSegment( -- 329
		Vec2(cx + f * 3, hipY), -- 329
		Vec2(fkX, kneeY), -- 329
		H * 0.048, -- 329
		legFront -- 329
	) -- 329
	fgDraw:drawSegment( -- 330
		Vec2(fkX, kneeY), -- 330
		Vec2(ffX, by + 3), -- 330
		H * 0.042, -- 330
		legFront -- 330
	) -- 330
	fgDraw:drawSegment( -- 332
		Vec2(ffX - f * 2, by + 3), -- 332
		Vec2(ffX + f * 9, by + 3), -- 332
		3.4, -- 332
		Color(42, 60, 86, 255) -- 332
	) -- 332
	local shY = by + bodyH * 0.8 + bob -- 335
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 336
	fgDraw:drawPolygon( -- 337
		{ -- 337
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 338
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 339
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 340
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 341
		}, -- 341
		Color(16, 26, 42, 248), -- 342
		1.2, -- 342
		Color(64, 118, 164, 195) -- 342
	) -- 342
	fgDraw:drawPolygon( -- 345
		{ -- 345
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 346
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 347
			Vec2(cx + sw * 1.05 + lean, shY), -- 348
			Vec2(cx - sw * 0.98 + lean, shY) -- 349
		}, -- 349
		Color(24, 38, 60, 255), -- 350
		1.3, -- 350
		toColor(PALETTE.rimSilver, 190) -- 350
	) -- 350
	fgDraw:drawSegment( -- 352
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 353
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 354
		2.4, -- 355
		Color(173, 155, 125, 225) -- 356
	) -- 356
	fgDraw:drawPolygon( -- 358
		{ -- 358
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 359
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 360
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 361
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 362
		}, -- 362
		Color(99, 105, 103, 248) -- 363
	) -- 363
	local headR = H * 0.088 -- 366
	local headX = cx + lean + f * 3 -- 367
	local headY = shY + headR * 1.35 -- 368
	fgDraw:drawCircle( -- 369
		Vec2(headX, headY - headR * 0.12), -- 369
		headR * 0.86, -- 369
		Color(181, 139, 106, 255) -- 369
	) -- 369
	fgDraw:drawEllipse( -- 370
		Vec2(headX, headY + headR * 0.5), -- 370
		headR * 1.12, -- 370
		headR * 0.72, -- 370
		Color(66, 73, 76, 255) -- 370
	) -- 370
	fgDraw:drawSegment( -- 371
		Vec2(headX - headR, headY + 1), -- 371
		Vec2(headX + headR, headY + 1), -- 371
		1.6, -- 372
		Color(97, 103, 101, 255) -- 372
	) -- 372
	fgDraw:drawSegment( -- 373
		Vec2(headX, headY + headR), -- 373
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 373
		1.6, -- 374
		Color(177, 78, 51, 255) -- 374
	) -- 374
	if isControlled and not calming and not rolling and not p.gripping then -- 374
		local gunPivotX = cx + lean + f * sw * 0.35 -- 378
		local gunPivotY = shY - bodyH * 0.1 -- 379
		local aimDx = f -- 380
		local aimDy = 0 -- 381
		if p.aimX > 0 or p.aimY > 0 then -- 381
			aimDx = p.aimX - gunPivotX -- 383
			aimDy = p.aimY - gunPivotY -- 384
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 385
			if dLen > 4 then -- 385
				aimDx = aimDx / dLen -- 387
				aimDy = aimDy / dLen -- 388
			end -- 388
		end -- 388
		local barrelLen = H * 0.34 -- 391
		local tipX = gunPivotX + aimDx * barrelLen -- 392
		local tipY = gunPivotY + aimDy * barrelLen -- 393
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 394
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 395
		fgDraw:drawSegment( -- 397
			Vec2(cx + lean, shY - 5), -- 397
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 397
			3.6, -- 397
			Color(26, 40, 62, 255) -- 397
		) -- 397
		fgDraw:drawSegment( -- 398
			Vec2(stockX, stockY), -- 398
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 398
			3.8, -- 398
			Color(105, 71, 50, 255) -- 398
		) -- 398
		fgDraw:drawSegment( -- 399
			Vec2(gunPivotX, gunPivotY), -- 399
			Vec2(tipX, tipY), -- 399
			1.8, -- 399
			Color(145, 140, 128, 245) -- 399
		) -- 399
	elseif calming then -- 399
		fgDraw:drawSegment( -- 401
			Vec2(cx + lean, shY - 6), -- 401
			Vec2(cx + f * sw * 2.1, shY - 14), -- 401
			3, -- 401
			Color(196, 222, 240, 235) -- 401
		) -- 401
		fgGlow:drawDot( -- 402
			Vec2(cx + f * sw * 2.15, shY - 14), -- 402
			3.6, -- 402
			toColor(PALETTE.amber, 225) -- 402
		) -- 402
	end -- 402
end -- 227
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 408
	local cx = cam:sx(a.x) -- 417
	local by = cam:sy(a.y, a.depth) -- 418
	local depthEnabled = p.room.depth ~= nil -- 419
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 420
	local H = cam:len(a.h) -- 421
	local W = cam:len(a.w) -- 422
	local f = a.facing -- 423
	local speed = math.max( -- 424
		math.abs(a.vx), -- 424
		math.abs(a.depthSpeed) -- 424
	) -- 424
	local ____isControlled_11 -- 425
	if isControlled then -- 425
		____isControlled_11 = self.playerStride -- 425
	else -- 425
		____isControlled_11 = self.partnerStride -- 425
	end -- 425
	local gait = ____isControlled_11 -- 425
	local afraid = not isControlled and p.escort.fear > 0 -- 427
	local slot = "child_idle" -- 428
	local height = H -- 429
	local frame = 0 -- 430
	local step = math.floor(self.animTime * 10) -- 431
	local nearCover = __TS__ArraySome( -- 432
		p.room.solids, -- 432
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 432
			math.abs(a.x - solid.x), -- 435
			math.abs(a.x - solid.x - solid.w) -- 435
		) <= 30 end -- 435
	) -- 435
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 435
		slot = "child_knock" -- 438
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 438
		slot = "child_offer" -- 441
	elseif isControlled and p.ticks < self.throwUntil then -- 441
		slot = "child_throw" -- 443
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 443
		slot = "child_aim" -- 445
	elseif isControlled and p.gripping then -- 445
		slot = "child_pull" -- 447
		frame = self.cartMoving and step or 0 -- 448
	elseif afraid and p.escort.state == "frozen" then -- 448
		slot = "child_fear" -- 450
		height = height * 0.74 -- 451
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 451
		slot = "child_peek" -- 454
		height = height * 0.83 -- 455
	elseif a.crouch then -- 455
		slot = "child_crouch" -- 457
		frame = speed > 8 and step or 0 -- 458
	elseif (gait and gait.speed or 0) > 8 then -- 458
		slot = "child_run" -- 460
		frame = step -- 461
	end -- 461
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 463
	local pose = { -- 464
		facing = facing, -- 465
		frame = frame, -- 465
		layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 465
	} -- 465
	local running = (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 467
		"child", -- 469
		"actor_child", -- 469
		cx, -- 469
		by, -- 469
		W, -- 469
		height, -- 469
		gait.cycle, -- 469
		pose, -- 469
		gait.effort -- 469
	) -- 469
	if running or assets:tryPlace( -- 469
		slot, -- 470
		"actor_child", -- 470
		cx, -- 470
		by, -- 470
		W, -- 470
		height, -- 470
		pose -- 470
	) then -- 470
		fgDraw:drawEllipse( -- 471
			Vec2(cx, shadowY + 1), -- 471
			W * 0.48, -- 471
			3, -- 471
			Color(12, 11, 13, 125) -- 471
		) -- 471
		if afraid then -- 471
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 473
		end -- 473
		return -- 475
	end -- 475
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 478
	local x = cx + jitter -- 479
	local fullRef = a.crouch and H * 1.35 or H -- 481
	local cw = fullRef * 0.16 -- 482
	fgDraw:drawEllipse( -- 485
		Vec2(x, shadowY + 1), -- 485
		cw * 1.15, -- 485
		3.6, -- 485
		Color(4, 6, 10, 155) -- 485
	) -- 485
	local walking = speed > 6 and a.onGround -- 487
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 488
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 489
	local hipY = by + H * 0.3 -- 492
	local legSwing = stride * cw * 0.85 -- 493
	fgDraw:drawSegment( -- 494
		Vec2(x - 2, hipY), -- 494
		Vec2(x - legSwing, by + 2), -- 494
		math.max(2.6, cw * 0.22), -- 494
		Color(34, 30, 38, 255) -- 494
	) -- 494
	fgDraw:drawSegment( -- 495
		Vec2(x + 2, hipY), -- 495
		Vec2(x + legSwing, by + 2), -- 495
		math.max(2.8, cw * 0.24), -- 495
		Color(52, 46, 56, 255) -- 495
	) -- 495
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 498
	local cloakBotY = by + H * 0.2 -- 499
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 500
	fgDraw:drawPolygon( -- 501
		{ -- 501
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 502
			Vec2(x + cw * 0.92, cloakBotY), -- 503
			Vec2(x + cw * 0.62, cloakTopY), -- 504
			Vec2(x - cw * 0.68, cloakTopY) -- 505
		}, -- 505
		Color(214, 166, 94, 255), -- 506
		1.3, -- 506
		Color(252, 232, 192, 225) -- 506
	) -- 506
	fgDraw:drawPolygon( -- 507
		{ -- 507
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 508
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 509
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 510
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 511
		}, -- 511
		Color(148, 108, 56, 215) -- 512
	) -- 512
	fgDraw:drawSegment( -- 513
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 513
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 513
		1.8, -- 513
		toColor(PALETTE.amberCore, 200) -- 513
	) -- 513
	local scarfY = cloakTopY - 2 -- 516
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 517
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 518
	local sendX = x - f * cw * 1.65 + cloakDrag -- 519
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 520
	fgDraw:drawQuadraticBezier( -- 521
		Vec2(x - f * cw * 0.3, scarfY), -- 521
		Vec2(smidX, smidY), -- 521
		Vec2(sendX, sendY), -- 521
		2.8, -- 521
		toColor(PALETTE.amberCore, 235) -- 521
	) -- 521
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 524
	local headX = x + f * (a.crouch and 5 or 2) -- 525
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 526
	fgDraw:drawCircle( -- 527
		Vec2(headX, headY), -- 527
		headR, -- 527
		Color(240, 222, 198, 255) -- 527
	) -- 527
	fgDraw:drawPolygon( -- 529
		{ -- 529
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 530
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 531
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 532
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 533
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 534
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 535
		}, -- 535
		Color(156, 114, 62, 248), -- 536
		1.1, -- 536
		Color(244, 214, 162, 200) -- 536
	) -- 536
	fgGlow:drawDot( -- 538
		Vec2(headX + f * headR * 0.45, headY + 1), -- 538
		2.2, -- 538
		toColor(PALETTE.amberCore) -- 538
	) -- 538
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 541
	if hasCompass then -- 541
		local compX = x + f * cw * 0.65 -- 543
		local compY = by + H * 0.48 -- 544
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 545
		fgGlow:drawDot( -- 546
			Vec2(compX, compY), -- 546
			2.6, -- 546
			toColor(PALETTE.amberCore, 250) -- 546
		) -- 546
		fillRadialGlow( -- 547
			fgGlow, -- 547
			compX, -- 547
			compY, -- 547
			26 * glowPulse, -- 547
			26 * glowPulse, -- 547
			Color(248, 206, 120, 78 * glowPulse), -- 547
			Color(248, 180, 72, 0), -- 547
			14 -- 547
		) -- 547
	end -- 547
	if afraid then -- 547
		self:drawFear(fgGlow, p, x, by + H + 16) -- 551
	end -- 551
	if isControlled and walking and not a.crouch and speed > 100 then -- 551
		local r = 10 + self.animTime * 32 % 24 -- 556
		fgGlow:drawRing( -- 557
			Vec2(x, by + 3), -- 557
			r, -- 557
			r + 1.5, -- 557
			Color(0, 0, 0, 0), -- 557
			1.1, -- 557
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 557
		) -- 557
	end -- 557
end -- 408
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 561
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 562
	do -- 562
		local i = 0 -- 563
		while i < FEAR_MAX do -- 563
			local lit = i < p.escort.fear -- 564
			drawDiamond( -- 565
				fgGlow, -- 565
				x + (i - 1) * 13, -- 565
				y, -- 565
				4, -- 565
				5, -- 565
				toColor(lit and tint or PALETTE.steelDark, 215), -- 566
				1, -- 566
				toColor(tint, lit and 235 or 100) -- 566
			) -- 566
			i = i + 1 -- 563
		end -- 563
	end -- 563
end -- 561
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 570
	local x = cam:sx(e.x + f * 20) -- 571
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 572
	local dx = cam:sx(p.player.x) - x -- 573
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 574
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 575
	do -- 575
		local i = 0 -- 576
		while i < 8 do -- 576
			local a = length * i / 8 -- 577
			local b = length * (i + 1) / 8 -- 578
			fgGlow:drawSegment( -- 579
				Vec2(x + dx * a, y + dy * a), -- 579
				Vec2(x + dx * b, y + dy * b), -- 579
				1.3, -- 580
				Color(220, 120, 88, 210) -- 580
			) -- 580
			i = i + 2 -- 576
		end -- 576
	end -- 576
end -- 570
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 585
	local cx = cam:sx(e.x) -- 594
	local depth = e.depth or 0 -- 595
	local by = cam:sy(e.y, depth) -- 596
	local H = cam:len(e.h) -- 597
	local W = cam:len(e.w) -- 598
	local f = p.player.x >= e.x and 1 or -1 -- 599
	local slot = "enemy_idle" -- 601
	if not e.alive then -- 601
		slot = "enemy_down" -- 603
	elseif e.hitT > 0 then -- 603
		slot = "enemy_hit" -- 605
	elseif e.warnT > 0 then -- 605
		slot = "enemy_aim" -- 607
	end -- 607
	local height = e.alive and H or H * 0.24 -- 609
	if assets:tryPlace( -- 609
		slot, -- 610
		"actor_enemy_" .. tostring(index), -- 610
		cx, -- 610
		by, -- 610
		W, -- 610
		height, -- 610
		{ -- 610
			facing = f, -- 611
			opacity = e.alive and 1 or 0.78, -- 611
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 611
		} -- 611
	) then -- 611
		if e.alive and e.warnT > 0 then -- 611
			self:drawEnemyWarning( -- 614
				fgGlow, -- 614
				e, -- 614
				p, -- 614
				cam, -- 614
				f -- 614
			) -- 614
		end -- 614
		return -- 616
	end -- 616
	if not e.alive then -- 616
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 620
		fgDraw:drawPolygon( -- 621
			{ -- 621
				Vec2(cx - H * 0.3, by), -- 622
				Vec2(cx + H * 0.28, by), -- 623
				Vec2(cx + H * 0.2, by + H * 0.14), -- 624
				Vec2(cx - H * 0.24, by + H * 0.11) -- 625
			}, -- 625
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 626
		) -- 626
		if flash > 0 then -- 626
			fillRadialGlow( -- 628
				fgGlow, -- 628
				cx, -- 628
				by + 12, -- 628
				34 * flash, -- 628
				18 * flash, -- 628
				toColor(PALETTE.crimson, 180 * flash), -- 628
				Color(255, 48, 82, 0), -- 628
				12 -- 628
			) -- 628
		end -- 628
		return -- 630
	end -- 630
	local sw = H * 0.112 -- 633
	fgDraw:drawEllipse( -- 634
		Vec2(cx, by + 1), -- 634
		sw * 1.9, -- 634
		4, -- 634
		Color(4, 6, 10, 165) -- 634
	) -- 634
	local hipY = by + H * 0.44 -- 637
	local kneeY = by + H * 0.23 -- 638
	local shY = by + H * 0.79 -- 639
	fgDraw:drawSegment( -- 640
		Vec2(cx - 5, hipY), -- 640
		Vec2(cx - 7, kneeY), -- 640
		H * 0.044, -- 640
		Color(20, 16, 26, 255) -- 640
	) -- 640
	fgDraw:drawSegment( -- 641
		Vec2(cx - 7, kneeY), -- 641
		Vec2(cx - 8, by + 2), -- 641
		H * 0.038, -- 641
		Color(20, 16, 26, 255) -- 641
	) -- 641
	fgDraw:drawSegment( -- 642
		Vec2(cx + 5, hipY), -- 642
		Vec2(cx + 7, kneeY), -- 642
		H * 0.046, -- 642
		Color(28, 22, 36, 255) -- 642
	) -- 642
	fgDraw:drawSegment( -- 643
		Vec2(cx + 7, kneeY), -- 643
		Vec2(cx + 8, by + 2), -- 643
		H * 0.04, -- 643
		Color(28, 22, 36, 255) -- 643
	) -- 643
	fgDraw:drawPolygon( -- 645
		{ -- 645
			Vec2(cx - sw * 0.68, hipY), -- 646
			Vec2(cx + sw * 0.68, hipY), -- 647
			Vec2(cx + sw * 1.12, shY), -- 648
			Vec2(cx - sw * 1.12, shY) -- 649
		}, -- 649
		Color(111, 68, 55, 255), -- 650
		1.3, -- 650
		Color(143, 101, 66, 220) -- 650
	) -- 650
	fgDraw:drawPolygon( -- 651
		{ -- 651
			Vec2(cx - sw * 1.26, shY - 6), -- 652
			Vec2(cx + sw * 1.26, shY - 6), -- 653
			Vec2(cx + sw * 0.96, shY + 5), -- 654
			Vec2(cx - sw * 0.96, shY + 5) -- 655
		}, -- 655
		Color(98, 82, 62, 255) -- 656
	) -- 656
	local headR = H * 0.086 -- 658
	local headY = shY + headR * 1.32 -- 659
	fgDraw:drawCircle( -- 660
		Vec2(cx, headY), -- 660
		headR * 0.82, -- 660
		Color(187, 142, 103, 255) -- 660
	) -- 660
	fgDraw:drawPolygon( -- 661
		{ -- 661
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 662
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 663
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 664
		}, -- 664
		Color(136, 105, 65, 255), -- 665
		1.1, -- 665
		Color(177, 145, 91, 220) -- 665
	) -- 665
	local gunX = cx + f * H * 0.34 -- 667
	local gunY = by + H * 0.69 -- 668
	fgDraw:drawSegment( -- 669
		Vec2(cx - f * 6, gunY - 2), -- 669
		Vec2(gunX, gunY), -- 669
		2.8, -- 669
		Color(118, 87, 61, 255) -- 669
	) -- 669
	if e.warnT > 0 then -- 669
		self:drawEnemyWarning( -- 671
			fgGlow, -- 671
			e, -- 671
			p, -- 671
			cam, -- 671
			f -- 671
		) -- 671
	end -- 671
end -- 585
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 676
	local s = p.room.scavenger -- 683
	if s == nil then -- 683
		return -- 685
	end -- 685
	local cx = cam:sx(p.scavX) -- 687
	local by = cam:sy(s.y) -- 688
	local H = cam:len(s.h) -- 689
	local W = cam:len(26) -- 690
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 691
	local alert = p.scavChase or p.scavSee > 0 -- 694
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 695
	local eyeY = by + H * 0.8 -- 696
	local coneLen = cam:len(alert and 155 or 115) -- 697
	fgGlow:drawVertices({ -- 698
		{ -- 699
			Vec2(cx + f * 6, eyeY), -- 699
			toColor(coneCol, alert and 78 or 34) -- 699
		}, -- 699
		{ -- 700
			Vec2(cx + f * coneLen, by + H * 1.05), -- 700
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 700
		}, -- 700
		{ -- 701
			Vec2(cx + f * coneLen, by + 4), -- 701
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 701
		} -- 701
	}) -- 701
	local frame = 0 -- 704
	if p.scavState == "turn" then -- 704
		frame = 2 -- 706
	elseif p.scavState == "chase" then -- 706
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 708
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 708
		frame = math.floor(self.animTime * 8) % 2 -- 710
	end -- 710
	if assets:tryPlace( -- 710
		"scavenger", -- 712
		"actor_scav", -- 712
		cx, -- 712
		by, -- 712
		W, -- 712
		H, -- 712
		{facing = f, frame = frame, layer = 3} -- 712
	) then -- 712
		return -- 713
	end -- 713
	fgDraw:drawEllipse( -- 716
		Vec2(cx, by + 1), -- 716
		W * 0.62, -- 716
		4, -- 716
		Color(4, 6, 10, 155) -- 716
	) -- 716
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 717
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 718
	fgDraw:drawSegment( -- 720
		Vec2(cx - 4, by + H * 0.4), -- 720
		Vec2(cx - stride, by + 2), -- 720
		W * 0.16, -- 720
		Color(32, 30, 28, 255) -- 720
	) -- 720
	fgDraw:drawSegment( -- 721
		Vec2(cx + 4, by + H * 0.4), -- 721
		Vec2(cx + stride, by + 2), -- 721
		W * 0.16, -- 721
		Color(44, 40, 36, 255) -- 721
	) -- 721
	fgDraw:drawPolygon( -- 723
		{ -- 723
			Vec2(cx - W * 0.45, by + H * 0.25), -- 724
			Vec2(cx + W * 0.42, by + H * 0.25), -- 725
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 726
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 727
		}, -- 727
		Color(56, 52, 46, 255), -- 728
		1.2, -- 728
		Color(128, 118, 100, 180) -- 728
	) -- 728
	local headX = cx + f * 5 -- 730
	local headY = by + H * 0.88 -- 731
	fgDraw:drawCircle( -- 732
		Vec2(headX, headY), -- 732
		W * 0.3, -- 732
		Color(42, 38, 34, 255) -- 732
	) -- 732
	fgGlow:drawDot( -- 733
		Vec2(headX + f * 6, headY), -- 733
		3, -- 733
		toColor(coneCol, 245) -- 733
	) -- 733
	local indY = by + H + 18 -- 736
	if p.scavChase then -- 736
		drawDiamond( -- 738
			fgGlow, -- 738
			cx, -- 738
			indY, -- 738
			9, -- 738
			12, -- 738
			toColor(PALETTE.crimson, 240), -- 738
			1.5, -- 738
			toColor(PALETTE.crimsonCore) -- 738
		) -- 738
	elseif p.scavSee > 0 then -- 738
		local frac = math.min(1, p.scavSee / 24) -- 740
		fgGlow:drawArc( -- 741
			Vec2(cx, indY), -- 741
			11, -- 741
			90, -- 741
			90 - 360 * frac, -- 741
			2.4, -- 741
			toColor(PALETTE.crimson, 235) -- 741
		) -- 741
		fgGlow:drawDot( -- 742
			Vec2(cx, indY), -- 742
			3, -- 742
			toColor(PALETTE.amber) -- 742
		) -- 742
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 742
		drawDiamond( -- 744
			fgGlow, -- 744
			cx, -- 744
			indY, -- 744
			6, -- 744
			8, -- 744
			toColor(PALETTE.amber, 220) -- 744
		) -- 744
	end -- 744
end -- 676
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 749
	local cx = cam:sx(p.dogX) -- 756
	local by = cam:sy(0) -- 757
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 758
	local W = cam:len(34) -- 759
	local H = cam:len(28) -- 760
	local frame = 0 -- 762
	if p.dogState == "ear" then -- 762
		frame = 1 -- 764
	elseif p.dogState == "sniff" then -- 764
		frame = 3 -- 766
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 766
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 768
	end -- 768
	if assets:tryPlace( -- 768
		"dog", -- 770
		"actor_dog", -- 770
		cx, -- 770
		by, -- 770
		W, -- 770
		H, -- 770
		{facing = f, frame = frame, layer = 3} -- 770
	) then -- 770
		return -- 771
	end -- 771
	fgDraw:drawEllipse( -- 774
		Vec2(cx, by + 1), -- 774
		W * 0.56, -- 774
		3.5, -- 774
		Color(4, 8, 10, 155) -- 774
	) -- 774
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 775
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 776
	fgDraw:drawSegment( -- 779
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 779
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 779
		2.8, -- 779
		Color(26, 30, 34, 255) -- 779
	) -- 779
	fgDraw:drawSegment( -- 780
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 780
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 780
		2.8, -- 780
		Color(36, 40, 44, 255) -- 780
	) -- 780
	fgDraw:drawPolygon( -- 782
		{ -- 782
			Vec2(cx - W * 0.42, by + H * 0.36), -- 783
			Vec2(cx + W * 0.38, by + H * 0.42), -- 784
			Vec2(cx + W * 0.34, by + H * 0.78), -- 785
			Vec2(cx - W * 0.38, by + H * 0.72) -- 786
		}, -- 786
		Color(38, 42, 48, 255), -- 787
		1.2, -- 787
		Color(102, 118, 126, 175) -- 787
	) -- 787
	local hx = cx + f * W * 0.42 -- 788
	local hy = by + H * 0.84 -- 789
	fgDraw:drawPolygon( -- 790
		{ -- 790
			Vec2(hx - f * 8, hy - 6), -- 791
			Vec2(hx + f * 12, hy - 2), -- 792
			Vec2(hx + f * 4, hy + 8), -- 793
			Vec2(hx - f * 6, hy + 14) -- 794
		}, -- 794
		Color(44, 48, 54, 255) -- 795
	) -- 795
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 797
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 798
	fgGlow:drawDot( -- 799
		Vec2(hx + f * 4, hy + 2), -- 799
		2.8, -- 799
		toColor(eyeCol, 250) -- 799
	) -- 799
	fillRadialGlow( -- 800
		fgGlow, -- 800
		hx + f * 4, -- 800
		hy + 2, -- 800
		16, -- 800
		16, -- 800
		toColor(eyeCol, alert and 135 or 70), -- 800
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 800
		12 -- 800
	) -- 800
	if alert then -- 800
		local r = 12 + self.animTime * 42 % 24 -- 803
		fgGlow:drawArc( -- 804
			Vec2(hx, hy + 12), -- 804
			r, -- 804
			35, -- 804
			145, -- 804
			1.8, -- 804
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 804
		) -- 804
	end -- 804
end -- 749
return ____exports -- 749