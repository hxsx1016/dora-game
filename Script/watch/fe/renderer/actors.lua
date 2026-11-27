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
local function strideAt(actor) -- 32
	return { -- 33
		actor = actor, -- 33
		x = actor.x, -- 33
		depth = actor.depth, -- 33
		speed = 0, -- 33
		cycle = 0, -- 33
		sampledCycle = 0, -- 33
		sinceSample = 0, -- 33
		effort = 0 -- 33
	} -- 33
end -- 32
local RUN_START_T = 0.1 -- 36
local RUN_STOP_T = 0.13 -- 37
local function advanceStride(stride, steps, dt) -- 39
	local a = stride.actor -- 40
	local distance = 0 -- 41
	if steps > 0 then -- 41
		local dx = a.x - stride.x -- 43
		local depth = a.depth - stride.depth -- 44
		distance = math.sqrt(dx * dx + depth * depth) -- 45
		local speed = distance / (steps * STEP) -- 46
		stride.speed = speed <= 380 and speed or 0 -- 47
		stride.x = a.x -- 48
		stride.depth = a.depth -- 49
		stride.sinceSample = 0 -- 50
	else -- 50
		stride.sinceSample = math.min(STEP, stride.sinceSample + dt) -- 52
	end -- 52
	if not a.alive or not a.onGround or a.crouch or a.covered or a.rollT > 0 then -- 52
		stride.effort = 0 -- 55
		return -- 56
	end -- 56
	if stride.speed > 8 then -- 56
		stride.effort = math.min(1, stride.effort + dt / RUN_START_T) -- 59
		local strideLength = a.h * (a.w <= 28 and 1.4 or 1.32) -- 60
		stride.sampledCycle = (stride.sampledCycle + distance / strideLength) % 1 -- 61
		stride.cycle = (stride.sampledCycle + stride.speed * stride.sinceSample / strideLength) % 1 -- 63
	else -- 63
		stride.effort = math.max(0, stride.effort - dt / RUN_STOP_T) -- 65
	end -- 65
end -- 39
local DUST_LIFE = 0.23 -- 69
____exports.ActorsRenderer = __TS__Class() -- 71
local ActorsRenderer = ____exports.ActorsRenderer -- 71
ActorsRenderer.name = "ActorsRenderer" -- 71
function ActorsRenderer.prototype.____constructor(self) -- 71
	self.slideDust = {} -- 72
	self.dustCooldown = 0 -- 73
	self.slideDuration = 0 -- 74
	self.slideRemainder = 0 -- 75
	self.strideTick = 0 -- 76
	self.animTime = 0 -- 79
	self.previousHp = 3 -- 80
	self.previousAxle = 0 -- 81
	self.cartMoving = false -- 82
	self.previousBottle = false -- 83
	self.hitUntil = -1 -- 85
	self.throwUntil = -1 -- 86
	self.shotUntil = -1 -- 87
end -- 71
function ActorsRenderer.prototype.reset(self, p) -- 89
	self.slideDust = {} -- 90
	self.dustCooldown = 0 -- 91
	self.slideDuration = 0 -- 92
	self.slideRemainder = 0 -- 93
	self.strideTick = p.ticks -- 94
	self.playerStride = strideAt(p.player) -- 95
	self.partnerStride = strideAt(p.partner) -- 96
	self.animTime = 0 -- 97
	self.previousHp = p.hp -- 98
	self.previousAxle = p.cartAxle -- 99
	self.cartMoving = false -- 100
	self.previousBottle = p.hasBottle -- 101
	self.previousTrace = p.trace -- 102
	self.hitUntil = -1 -- 103
	self.throwUntil = -1 -- 104
	self.shotUntil = -1 -- 105
end -- 89
function ActorsRenderer.prototype.update(self, dt, p) -- 109
	self.animTime = self.animTime + dt -- 110
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 110
		self.hitUntil = p.ticks + 14 -- 112
	end -- 112
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 112
		self.throwUntil = p.ticks + 12 -- 115
	end -- 115
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 115
		self.shotUntil = p.ticks + 7 -- 118
	end -- 118
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 120
	self.previousAxle = p.cartAxle -- 121
	self.previousHp = p.hp -- 122
	self.previousBottle = p.hasBottle -- 123
	self.previousTrace = p.trace -- 124
	local ____opt_0 = self.playerStride -- 124
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 124
		self.playerStride = strideAt(p.player) -- 126
	end -- 126
	local ____opt_2 = self.partnerStride -- 126
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 126
		self.partnerStride = strideAt(p.partner) -- 129
	end -- 129
	local steps = math.max(0, p.ticks - self.strideTick) -- 131
	advanceStride(self.playerStride, steps, dt) -- 132
	advanceStride(self.partnerStride, steps, dt) -- 133
	self.strideTick = p.ticks -- 134
	self:updateSlide(dt, steps, p, self.playerStride.speed) -- 135
end -- 109
function ActorsRenderer.prototype.slidePhase(self, a) -- 138
	local remaining = math.max(0, a.rollT - self.slideRemainder) -- 139
	return self.slideDuration > 0 and 1 - remaining / self.slideDuration or 0 -- 140
end -- 138
function ActorsRenderer.prototype.updateSlide(self, dt, steps, p, speed) -- 143
	local a = p.player -- 144
	if not p.childMode and a.rollT > 0 then -- 144
		self.slideRemainder = self.slideDuration == 0 and 0 or math.max( -- 147
			0, -- 148
			math.min(STEP, self.slideRemainder + dt - steps * STEP) -- 148
		) -- 148
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 149
		local progress = self:slidePhase(a) -- 150
		self.dustCooldown = self.dustCooldown - dt -- 151
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 151
			local ____self_slideDust_4 = self.slideDust -- 151
			____self_slideDust_4[#____self_slideDust_4 + 1] = { -- 153
				x = a.x + a.facing * a.h * 0.34, -- 154
				y = a.y, -- 155
				depth = a.depth, -- 156
				facing = a.facing, -- 157
				life = DUST_LIFE -- 158
			} -- 158
			self.dustCooldown = 0.038 -- 160
		end -- 160
	else -- 160
		self.slideDuration = 0 -- 163
		self.slideRemainder = 0 -- 164
		self.dustCooldown = 0 -- 165
	end -- 165
	local write = 0 -- 167
	for ____, dust in ipairs(self.slideDust) do -- 168
		dust.life = dust.life - dt -- 169
		if dust.life > 0 then -- 169
			self.slideDust[write + 1] = dust -- 171
			write = write + 1 -- 172
		end -- 172
	end -- 172
	__TS__ArraySetLength(self.slideDust, write) -- 172
end -- 143
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 178
	if suppressPartner == nil then -- 178
		suppressPartner = false -- 184
	end -- 184
	self:drawSlideDust(fgGlow, cam) -- 186
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < #p.enemies do -- 190
			self:drawEnemy( -- 191
				fgDraw, -- 191
				fgGlow, -- 191
				assets, -- 191
				p.enemies[i + 1], -- 191
				i, -- 191
				p, -- 191
				cam -- 191
			) -- 191
			i = i + 1 -- 190
		end -- 190
	end -- 190
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 190
		self:drawScavenger( -- 196
			fgDraw, -- 196
			fgGlow, -- 196
			assets, -- 196
			p, -- 196
			cam -- 196
		) -- 196
	end -- 196
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 196
		self:drawDog( -- 201
			fgDraw, -- 201
			fgGlow, -- 201
			assets, -- 201
			p, -- 201
			cam -- 201
		) -- 201
	end -- 201
	if p.partner.alive and not suppressPartner then -- 201
		local partnerIsChild = p.partner.w <= 28 -- 206
		if partnerIsChild then -- 206
			self:drawXiaoman( -- 208
				fgDraw, -- 208
				fgGlow, -- 208
				assets, -- 208
				p.partner, -- 208
				p, -- 208
				cam, -- 208
				false -- 208
			) -- 208
		else -- 208
			self:drawZhouShu( -- 210
				fgDraw, -- 210
				fgGlow, -- 210
				assets, -- 210
				p.partner, -- 210
				p, -- 210
				cam, -- 210
				false -- 210
			) -- 210
		end -- 210
	end -- 210
	if p.player.alive then -- 210
		if p.childMode then -- 210
			self:drawXiaoman( -- 217
				fgDraw, -- 217
				fgGlow, -- 217
				assets, -- 217
				p.player, -- 217
				p, -- 217
				cam, -- 217
				true -- 217
			) -- 217
		else -- 217
			self:drawZhouShu( -- 219
				fgDraw, -- 219
				fgGlow, -- 219
				assets, -- 219
				p.player, -- 219
				p, -- 219
				cam, -- 219
				true -- 219
			) -- 219
		end -- 219
	end -- 219
end -- 178
function ActorsRenderer.prototype.drawSlideDust(self, draw, cam) -- 224
	for ____, dust in ipairs(self.slideDust) do -- 225
		local alpha = dust.life / DUST_LIFE -- 226
		local spread = 1 - alpha -- 227
		local x = cam:sx(dust.x - dust.facing * spread * 17) -- 228
		local y = cam:sy(dust.y + 1.5 + spread * 2, dust.depth) -- 229
		draw:drawEllipse( -- 230
			Vec2(x, y), -- 230
			cam:len(5 + spread * 7), -- 230
			cam:len(1.5 + spread * 2), -- 230
			Color(166, 147, 124, 170 * alpha) -- 231
		) -- 231
		draw:drawDot( -- 232
			Vec2( -- 232
				x - dust.facing * cam:len(3), -- 232
				y + cam:len(4) -- 232
			), -- 232
			cam:len(1.1), -- 233
			Color(195, 174, 148, 135 * alpha) -- 233
		) -- 233
	end -- 233
end -- 224
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 238
	local cx = cam:sx(a.x) -- 247
	local by = cam:sy(a.y, a.depth) -- 248
	local depthEnabled = p.room.depth ~= nil -- 249
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 250
	local H = cam:len(a.h) -- 251
	local W = cam:len(a.w) -- 252
	local f = a.facing -- 253
	local speed = math.max( -- 254
		math.abs(a.vx), -- 254
		math.abs(a.depthSpeed) -- 254
	) -- 254
	local slot = "soldier_idle" -- 256
	local height = H -- 257
	local frame = 0 -- 258
	local facing = f -- 259
	local step = math.floor(self.animTime * 10) -- 260
	local ____isControlled_5 -- 261
	if isControlled then -- 261
		____isControlled_5 = self.playerStride -- 261
	else -- 261
		____isControlled_5 = self.partnerStride -- 261
	end -- 261
	local gait = ____isControlled_5 -- 261
	if isControlled and p.ticks < self.hitUntil then -- 261
		slot = "soldier_hit" -- 263
	elseif a.rollT > 0 then -- 263
		slot = "soldier_slide" -- 265
		local progress = self:slidePhase(a) -- 266
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 267
	elseif p.phase == "prologue-give" then -- 267
		slot = "soldier_offer" -- 269
		height = height * 0.75 -- 270
		facing = p.partner.x >= a.x and 1 or -1 -- 271
	elseif isControlled and p.gripping then -- 271
		slot = "soldier_push" -- 273
		frame = self.cartMoving and step or 0 -- 274
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 275
		height = height * 0.91 -- 276
	elseif isControlled and p.escort.state == "calming" then -- 276
		slot = "soldier_knock" -- 278
		local calm = p.escort.calmTick -- 279
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 280
		height = height * 0.76 -- 281
	else -- 281
		local ____temp_8 = p.phase == "gate-send" -- 282
		if ____temp_8 then -- 282
			local ____opt_6 = p.room.story -- 282
			____temp_8 = (____opt_6 and ____opt_6.gate) ~= nil -- 282
		end -- 282
		if ____temp_8 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 282
			slot = "soldier_hold" -- 284
			height = height * 1.11 -- 285
		elseif isControlled and p.ticks < self.shotUntil then -- 285
			local running = speed > 8 -- 287
			slot = running and "soldier_fire_move" or "soldier_fire" -- 288
			frame = running and step or 0 -- 289
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 290
		elseif a.covered or isControlled and p.coverHug then -- 290
			slot = "soldier_cover" -- 292
			height = height * 0.77 -- 293
		elseif (gait and gait.speed or 0) > 8 then -- 293
			slot = "soldier_run" -- 295
			frame = step -- 296
		end -- 296
	end -- 296
	local pose = { -- 298
		facing = facing, -- 299
		frame = frame, -- 299
		layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 299
	} -- 299
	local sliding = slot == "soldier_slide" and assets:tryPlaceSlide( -- 301
		"actor_soldier", -- 302
		cx, -- 302
		by, -- 302
		W, -- 302
		height, -- 302
		self:slidePhase(a), -- 302
		pose -- 302
	) -- 302
	local running = (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 303
		"soldier", -- 305
		"actor_soldier", -- 305
		cx, -- 305
		by, -- 305
		W, -- 305
		height, -- 305
		gait.cycle, -- 305
		pose, -- 305
		gait.effort -- 305
	) -- 305
	if sliding or running or assets:tryPlace( -- 305
		slot, -- 306
		"actor_soldier", -- 306
		cx, -- 306
		by, -- 306
		W, -- 306
		height, -- 306
		pose -- 306
	) then -- 306
		fgDraw:drawEllipse( -- 307
			Vec2(cx, shadowY + 1), -- 307
			W * 0.54, -- 307
			4, -- 307
			Color(12, 11, 13, 145) -- 307
		) -- 307
		return -- 308
	end -- 308
	fgDraw:drawEllipse( -- 312
		Vec2(cx, shadowY + 1), -- 312
		H * 0.24, -- 312
		4.5, -- 312
		Color(3, 5, 10, 175) -- 312
	) -- 312
	local walking = speed > 10 and a.onGround -- 314
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 315
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 316
	local calming = not p.childMode and p.escort.state == "calming" -- 317
	local rolling = a.rollT > 0 -- 318
	local crouching = a.covered or calming or rolling -- 319
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 322
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 323
	local sw = H * 0.115 -- 324
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 327
	local kneeY = by + bodyH * 0.23 -- 328
	local stepX = stride * H * 0.15 -- 329
	local legDark = Color(14, 21, 34, 255) -- 330
	local legFront = Color(26, 38, 58, 255) -- 331
	local bkX = cx - f * 4 - stepX * 0.5 -- 333
	local bfX = cx - f * 8 - stepX -- 334
	fgDraw:drawSegment( -- 335
		Vec2(cx - f * 3, hipY), -- 335
		Vec2(bkX, kneeY), -- 335
		H * 0.044, -- 335
		legDark -- 335
	) -- 335
	fgDraw:drawSegment( -- 336
		Vec2(bkX, kneeY), -- 336
		Vec2(bfX, by + 3), -- 336
		H * 0.038, -- 336
		legDark -- 336
	) -- 336
	local fkX = cx + f * 6 + stepX * 0.55 -- 338
	local ffX = cx + f * 7 + stepX -- 339
	fgDraw:drawSegment( -- 340
		Vec2(cx + f * 3, hipY), -- 340
		Vec2(fkX, kneeY), -- 340
		H * 0.048, -- 340
		legFront -- 340
	) -- 340
	fgDraw:drawSegment( -- 341
		Vec2(fkX, kneeY), -- 341
		Vec2(ffX, by + 3), -- 341
		H * 0.042, -- 341
		legFront -- 341
	) -- 341
	fgDraw:drawSegment( -- 343
		Vec2(ffX - f * 2, by + 3), -- 343
		Vec2(ffX + f * 9, by + 3), -- 343
		3.4, -- 343
		Color(42, 60, 86, 255) -- 343
	) -- 343
	local shY = by + bodyH * 0.8 + bob -- 346
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 347
	fgDraw:drawPolygon( -- 348
		{ -- 348
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 349
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 350
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 351
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 352
		}, -- 352
		Color(16, 26, 42, 248), -- 353
		1.2, -- 353
		Color(64, 118, 164, 195) -- 353
	) -- 353
	fgDraw:drawPolygon( -- 356
		{ -- 356
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 357
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 358
			Vec2(cx + sw * 1.05 + lean, shY), -- 359
			Vec2(cx - sw * 0.98 + lean, shY) -- 360
		}, -- 360
		Color(24, 38, 60, 255), -- 361
		1.3, -- 361
		toColor(PALETTE.rimSilver, 190) -- 361
	) -- 361
	fgDraw:drawSegment( -- 363
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 364
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 365
		2.4, -- 366
		Color(173, 155, 125, 225) -- 367
	) -- 367
	fgDraw:drawPolygon( -- 369
		{ -- 369
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 370
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 371
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 372
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 373
		}, -- 373
		Color(99, 105, 103, 248) -- 374
	) -- 374
	local headR = H * 0.088 -- 377
	local headX = cx + lean + f * 3 -- 378
	local headY = shY + headR * 1.35 -- 379
	fgDraw:drawCircle( -- 380
		Vec2(headX, headY - headR * 0.12), -- 380
		headR * 0.86, -- 380
		Color(181, 139, 106, 255) -- 380
	) -- 380
	fgDraw:drawEllipse( -- 381
		Vec2(headX, headY + headR * 0.5), -- 381
		headR * 1.12, -- 381
		headR * 0.72, -- 381
		Color(66, 73, 76, 255) -- 381
	) -- 381
	fgDraw:drawSegment( -- 382
		Vec2(headX - headR, headY + 1), -- 382
		Vec2(headX + headR, headY + 1), -- 382
		1.6, -- 383
		Color(97, 103, 101, 255) -- 383
	) -- 383
	fgDraw:drawSegment( -- 384
		Vec2(headX, headY + headR), -- 384
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 384
		1.6, -- 385
		Color(177, 78, 51, 255) -- 385
	) -- 385
	if isControlled and not calming and not rolling and not p.gripping then -- 385
		local gunPivotX = cx + lean + f * sw * 0.35 -- 389
		local gunPivotY = shY - bodyH * 0.1 -- 390
		local aimDx = f -- 391
		local aimDy = 0 -- 392
		if p.aimX > 0 or p.aimY > 0 then -- 392
			aimDx = p.aimX - gunPivotX -- 394
			aimDy = p.aimY - gunPivotY -- 395
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 396
			if dLen > 4 then -- 396
				aimDx = aimDx / dLen -- 398
				aimDy = aimDy / dLen -- 399
			end -- 399
		end -- 399
		local barrelLen = H * 0.34 -- 402
		local tipX = gunPivotX + aimDx * barrelLen -- 403
		local tipY = gunPivotY + aimDy * barrelLen -- 404
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 405
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 406
		fgDraw:drawSegment( -- 408
			Vec2(cx + lean, shY - 5), -- 408
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 408
			3.6, -- 408
			Color(26, 40, 62, 255) -- 408
		) -- 408
		fgDraw:drawSegment( -- 409
			Vec2(stockX, stockY), -- 409
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 409
			3.8, -- 409
			Color(105, 71, 50, 255) -- 409
		) -- 409
		fgDraw:drawSegment( -- 410
			Vec2(gunPivotX, gunPivotY), -- 410
			Vec2(tipX, tipY), -- 410
			1.8, -- 410
			Color(145, 140, 128, 245) -- 410
		) -- 410
	elseif calming then -- 410
		fgDraw:drawSegment( -- 412
			Vec2(cx + lean, shY - 6), -- 412
			Vec2(cx + f * sw * 2.1, shY - 14), -- 412
			3, -- 412
			Color(196, 222, 240, 235) -- 412
		) -- 412
		fgGlow:drawDot( -- 413
			Vec2(cx + f * sw * 2.15, shY - 14), -- 413
			3.6, -- 413
			toColor(PALETTE.amber, 225) -- 413
		) -- 413
	end -- 413
end -- 238
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 419
	local cx = cam:sx(a.x) -- 428
	local by = cam:sy(a.y, a.depth) -- 429
	local depthEnabled = p.room.depth ~= nil -- 430
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 431
	local H = cam:len(a.h) -- 432
	local W = cam:len(a.w) -- 433
	local f = a.facing -- 434
	local speed = math.max( -- 435
		math.abs(a.vx), -- 435
		math.abs(a.depthSpeed) -- 435
	) -- 435
	local ____isControlled_11 -- 436
	if isControlled then -- 436
		____isControlled_11 = self.playerStride -- 436
	else -- 436
		____isControlled_11 = self.partnerStride -- 436
	end -- 436
	local gait = ____isControlled_11 -- 436
	local afraid = not isControlled and p.escort.fear > 0 -- 438
	local slot = "child_idle" -- 439
	local height = H -- 440
	local frame = 0 -- 441
	local step = math.floor(self.animTime * 10) -- 442
	local nearCover = __TS__ArraySome( -- 443
		p.room.solids, -- 443
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 443
			math.abs(a.x - solid.x), -- 446
			math.abs(a.x - solid.x - solid.w) -- 446
		) <= 30 end -- 446
	) -- 446
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 446
		slot = "child_knock" -- 449
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 449
		slot = "child_offer" -- 452
	elseif isControlled and p.ticks < self.throwUntil then -- 452
		slot = "child_throw" -- 454
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 454
		slot = "child_aim" -- 456
	elseif isControlled and p.gripping then -- 456
		slot = "child_pull" -- 458
		frame = self.cartMoving and step or 0 -- 459
	elseif afraid and p.escort.state == "frozen" then -- 459
		slot = "child_fear" -- 461
		height = height * 0.74 -- 462
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 462
		slot = "child_peek" -- 465
		height = height * 0.83 -- 466
	elseif a.crouch then -- 466
		slot = "child_crouch" -- 468
		frame = speed > 8 and step or 0 -- 469
	elseif (gait and gait.speed or 0) > 8 then -- 469
		slot = "child_run" -- 471
		frame = step -- 472
	end -- 472
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 474
	local pose = { -- 475
		facing = facing, -- 476
		frame = frame, -- 476
		layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 476
	} -- 476
	local running = (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 478
		"child", -- 480
		"actor_child", -- 480
		cx, -- 480
		by, -- 480
		W, -- 480
		height, -- 480
		gait.cycle, -- 480
		pose, -- 480
		gait.effort -- 480
	) -- 480
	if running or assets:tryPlace( -- 480
		slot, -- 481
		"actor_child", -- 481
		cx, -- 481
		by, -- 481
		W, -- 481
		height, -- 481
		pose -- 481
	) then -- 481
		fgDraw:drawEllipse( -- 482
			Vec2(cx, shadowY + 1), -- 482
			W * 0.48, -- 482
			3, -- 482
			Color(12, 11, 13, 125) -- 482
		) -- 482
		if afraid then -- 482
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 484
		end -- 484
		return -- 486
	end -- 486
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 489
	local x = cx + jitter -- 490
	local fullRef = a.crouch and H * 1.35 or H -- 492
	local cw = fullRef * 0.16 -- 493
	fgDraw:drawEllipse( -- 496
		Vec2(x, shadowY + 1), -- 496
		cw * 1.15, -- 496
		3.6, -- 496
		Color(4, 6, 10, 155) -- 496
	) -- 496
	local walking = speed > 6 and a.onGround -- 498
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 499
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 500
	local hipY = by + H * 0.3 -- 503
	local legSwing = stride * cw * 0.85 -- 504
	fgDraw:drawSegment( -- 505
		Vec2(x - 2, hipY), -- 505
		Vec2(x - legSwing, by + 2), -- 505
		math.max(2.6, cw * 0.22), -- 505
		Color(34, 30, 38, 255) -- 505
	) -- 505
	fgDraw:drawSegment( -- 506
		Vec2(x + 2, hipY), -- 506
		Vec2(x + legSwing, by + 2), -- 506
		math.max(2.8, cw * 0.24), -- 506
		Color(52, 46, 56, 255) -- 506
	) -- 506
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 509
	local cloakBotY = by + H * 0.2 -- 510
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 511
	fgDraw:drawPolygon( -- 512
		{ -- 512
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 513
			Vec2(x + cw * 0.92, cloakBotY), -- 514
			Vec2(x + cw * 0.62, cloakTopY), -- 515
			Vec2(x - cw * 0.68, cloakTopY) -- 516
		}, -- 516
		Color(214, 166, 94, 255), -- 517
		1.3, -- 517
		Color(252, 232, 192, 225) -- 517
	) -- 517
	fgDraw:drawPolygon( -- 518
		{ -- 518
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 519
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 520
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 521
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 522
		}, -- 522
		Color(148, 108, 56, 215) -- 523
	) -- 523
	fgDraw:drawSegment( -- 524
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 524
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 524
		1.8, -- 524
		toColor(PALETTE.amberCore, 200) -- 524
	) -- 524
	local scarfY = cloakTopY - 2 -- 527
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 528
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 529
	local sendX = x - f * cw * 1.65 + cloakDrag -- 530
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 531
	fgDraw:drawQuadraticBezier( -- 532
		Vec2(x - f * cw * 0.3, scarfY), -- 532
		Vec2(smidX, smidY), -- 532
		Vec2(sendX, sendY), -- 532
		2.8, -- 532
		toColor(PALETTE.amberCore, 235) -- 532
	) -- 532
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 535
	local headX = x + f * (a.crouch and 5 or 2) -- 536
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 537
	fgDraw:drawCircle( -- 538
		Vec2(headX, headY), -- 538
		headR, -- 538
		Color(240, 222, 198, 255) -- 538
	) -- 538
	fgDraw:drawPolygon( -- 540
		{ -- 540
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 541
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 542
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 543
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 544
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 545
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 546
		}, -- 546
		Color(156, 114, 62, 248), -- 547
		1.1, -- 547
		Color(244, 214, 162, 200) -- 547
	) -- 547
	fgGlow:drawDot( -- 549
		Vec2(headX + f * headR * 0.45, headY + 1), -- 549
		2.2, -- 549
		toColor(PALETTE.amberCore) -- 549
	) -- 549
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 552
	if hasCompass then -- 552
		local compX = x + f * cw * 0.65 -- 554
		local compY = by + H * 0.48 -- 555
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 556
		fgGlow:drawDot( -- 557
			Vec2(compX, compY), -- 557
			2.6, -- 557
			toColor(PALETTE.amberCore, 250) -- 557
		) -- 557
		fillRadialGlow( -- 558
			fgGlow, -- 558
			compX, -- 558
			compY, -- 558
			26 * glowPulse, -- 558
			26 * glowPulse, -- 558
			Color(248, 206, 120, 78 * glowPulse), -- 558
			Color(248, 180, 72, 0), -- 558
			14 -- 558
		) -- 558
	end -- 558
	if afraid then -- 558
		self:drawFear(fgGlow, p, x, by + H + 16) -- 562
	end -- 562
	if isControlled and walking and not a.crouch and speed > 100 then -- 562
		local r = 10 + self.animTime * 32 % 24 -- 567
		fgGlow:drawRing( -- 568
			Vec2(x, by + 3), -- 568
			r, -- 568
			r + 1.5, -- 568
			Color(0, 0, 0, 0), -- 568
			1.1, -- 568
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 568
		) -- 568
	end -- 568
end -- 419
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 572
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 573
	do -- 573
		local i = 0 -- 574
		while i < FEAR_MAX do -- 574
			local lit = i < p.escort.fear -- 575
			drawDiamond( -- 576
				fgGlow, -- 576
				x + (i - 1) * 13, -- 576
				y, -- 576
				4, -- 576
				5, -- 576
				toColor(lit and tint or PALETTE.steelDark, 215), -- 577
				1, -- 577
				toColor(tint, lit and 235 or 100) -- 577
			) -- 577
			i = i + 1 -- 574
		end -- 574
	end -- 574
end -- 572
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 581
	local x = cam:sx(e.x + f * 20) -- 582
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 583
	local dx = cam:sx(p.player.x) - x -- 584
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 585
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 586
	do -- 586
		local i = 0 -- 587
		while i < 8 do -- 587
			local a = length * i / 8 -- 588
			local b = length * (i + 1) / 8 -- 589
			fgGlow:drawSegment( -- 590
				Vec2(x + dx * a, y + dy * a), -- 590
				Vec2(x + dx * b, y + dy * b), -- 590
				1.3, -- 591
				Color(220, 120, 88, 210) -- 591
			) -- 591
			i = i + 2 -- 587
		end -- 587
	end -- 587
end -- 581
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 596
	local cx = cam:sx(e.x) -- 605
	local depth = e.depth or 0 -- 606
	local by = cam:sy(e.y, depth) -- 607
	local H = cam:len(e.h) -- 608
	local W = cam:len(e.w) -- 609
	local f = p.player.x >= e.x and 1 or -1 -- 610
	local slot = "enemy_idle" -- 612
	if not e.alive then -- 612
		slot = "enemy_down" -- 614
	elseif e.hitT > 0 then -- 614
		slot = "enemy_hit" -- 616
	elseif e.warnT > 0 then -- 616
		slot = "enemy_aim" -- 618
	end -- 618
	local height = e.alive and H or H * 0.24 -- 620
	if assets:tryPlace( -- 620
		slot, -- 621
		"actor_enemy_" .. tostring(index), -- 621
		cx, -- 621
		by, -- 621
		W, -- 621
		height, -- 621
		{ -- 621
			facing = f, -- 622
			opacity = e.alive and 1 or 0.78, -- 622
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 622
		} -- 622
	) then -- 622
		if e.alive and e.warnT > 0 then -- 622
			self:drawEnemyWarning( -- 625
				fgGlow, -- 625
				e, -- 625
				p, -- 625
				cam, -- 625
				f -- 625
			) -- 625
		end -- 625
		return -- 627
	end -- 627
	if not e.alive then -- 627
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 631
		fgDraw:drawPolygon( -- 632
			{ -- 632
				Vec2(cx - H * 0.3, by), -- 633
				Vec2(cx + H * 0.28, by), -- 634
				Vec2(cx + H * 0.2, by + H * 0.14), -- 635
				Vec2(cx - H * 0.24, by + H * 0.11) -- 636
			}, -- 636
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 637
		) -- 637
		if flash > 0 then -- 637
			fillRadialGlow( -- 639
				fgGlow, -- 639
				cx, -- 639
				by + 12, -- 639
				34 * flash, -- 639
				18 * flash, -- 639
				toColor(PALETTE.crimson, 180 * flash), -- 639
				Color(255, 48, 82, 0), -- 639
				12 -- 639
			) -- 639
		end -- 639
		return -- 641
	end -- 641
	local sw = H * 0.112 -- 644
	fgDraw:drawEllipse( -- 645
		Vec2(cx, by + 1), -- 645
		sw * 1.9, -- 645
		4, -- 645
		Color(4, 6, 10, 165) -- 645
	) -- 645
	local hipY = by + H * 0.44 -- 648
	local kneeY = by + H * 0.23 -- 649
	local shY = by + H * 0.79 -- 650
	fgDraw:drawSegment( -- 651
		Vec2(cx - 5, hipY), -- 651
		Vec2(cx - 7, kneeY), -- 651
		H * 0.044, -- 651
		Color(20, 16, 26, 255) -- 651
	) -- 651
	fgDraw:drawSegment( -- 652
		Vec2(cx - 7, kneeY), -- 652
		Vec2(cx - 8, by + 2), -- 652
		H * 0.038, -- 652
		Color(20, 16, 26, 255) -- 652
	) -- 652
	fgDraw:drawSegment( -- 653
		Vec2(cx + 5, hipY), -- 653
		Vec2(cx + 7, kneeY), -- 653
		H * 0.046, -- 653
		Color(28, 22, 36, 255) -- 653
	) -- 653
	fgDraw:drawSegment( -- 654
		Vec2(cx + 7, kneeY), -- 654
		Vec2(cx + 8, by + 2), -- 654
		H * 0.04, -- 654
		Color(28, 22, 36, 255) -- 654
	) -- 654
	fgDraw:drawPolygon( -- 656
		{ -- 656
			Vec2(cx - sw * 0.68, hipY), -- 657
			Vec2(cx + sw * 0.68, hipY), -- 658
			Vec2(cx + sw * 1.12, shY), -- 659
			Vec2(cx - sw * 1.12, shY) -- 660
		}, -- 660
		Color(111, 68, 55, 255), -- 661
		1.3, -- 661
		Color(143, 101, 66, 220) -- 661
	) -- 661
	fgDraw:drawPolygon( -- 662
		{ -- 662
			Vec2(cx - sw * 1.26, shY - 6), -- 663
			Vec2(cx + sw * 1.26, shY - 6), -- 664
			Vec2(cx + sw * 0.96, shY + 5), -- 665
			Vec2(cx - sw * 0.96, shY + 5) -- 666
		}, -- 666
		Color(98, 82, 62, 255) -- 667
	) -- 667
	local headR = H * 0.086 -- 669
	local headY = shY + headR * 1.32 -- 670
	fgDraw:drawCircle( -- 671
		Vec2(cx, headY), -- 671
		headR * 0.82, -- 671
		Color(187, 142, 103, 255) -- 671
	) -- 671
	fgDraw:drawPolygon( -- 672
		{ -- 672
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 673
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 674
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 675
		}, -- 675
		Color(136, 105, 65, 255), -- 676
		1.1, -- 676
		Color(177, 145, 91, 220) -- 676
	) -- 676
	local gunX = cx + f * H * 0.34 -- 678
	local gunY = by + H * 0.69 -- 679
	fgDraw:drawSegment( -- 680
		Vec2(cx - f * 6, gunY - 2), -- 680
		Vec2(gunX, gunY), -- 680
		2.8, -- 680
		Color(118, 87, 61, 255) -- 680
	) -- 680
	if e.warnT > 0 then -- 680
		self:drawEnemyWarning( -- 682
			fgGlow, -- 682
			e, -- 682
			p, -- 682
			cam, -- 682
			f -- 682
		) -- 682
	end -- 682
end -- 596
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 687
	local s = p.room.scavenger -- 694
	if s == nil then -- 694
		return -- 696
	end -- 696
	local cx = cam:sx(p.scavX) -- 698
	local by = cam:sy(s.y) -- 699
	local H = cam:len(s.h) -- 700
	local W = cam:len(26) -- 701
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 702
	local alert = p.scavChase or p.scavSee > 0 -- 705
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 706
	local eyeY = by + H * 0.8 -- 707
	local coneLen = cam:len(alert and 155 or 115) -- 708
	fgGlow:drawVertices({ -- 709
		{ -- 710
			Vec2(cx + f * 6, eyeY), -- 710
			toColor(coneCol, alert and 78 or 34) -- 710
		}, -- 710
		{ -- 711
			Vec2(cx + f * coneLen, by + H * 1.05), -- 711
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 711
		}, -- 711
		{ -- 712
			Vec2(cx + f * coneLen, by + 4), -- 712
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 712
		} -- 712
	}) -- 712
	local frame = 0 -- 715
	if p.scavState == "turn" then -- 715
		frame = 2 -- 717
	elseif p.scavState == "chase" then -- 717
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 719
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 719
		frame = math.floor(self.animTime * 8) % 2 -- 721
	end -- 721
	if assets:tryPlace( -- 721
		"scavenger", -- 723
		"actor_scav", -- 723
		cx, -- 723
		by, -- 723
		W, -- 723
		H, -- 723
		{facing = f, frame = frame, layer = 3} -- 723
	) then -- 723
		return -- 724
	end -- 724
	fgDraw:drawEllipse( -- 727
		Vec2(cx, by + 1), -- 727
		W * 0.62, -- 727
		4, -- 727
		Color(4, 6, 10, 155) -- 727
	) -- 727
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 728
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 729
	fgDraw:drawSegment( -- 731
		Vec2(cx - 4, by + H * 0.4), -- 731
		Vec2(cx - stride, by + 2), -- 731
		W * 0.16, -- 731
		Color(32, 30, 28, 255) -- 731
	) -- 731
	fgDraw:drawSegment( -- 732
		Vec2(cx + 4, by + H * 0.4), -- 732
		Vec2(cx + stride, by + 2), -- 732
		W * 0.16, -- 732
		Color(44, 40, 36, 255) -- 732
	) -- 732
	fgDraw:drawPolygon( -- 734
		{ -- 734
			Vec2(cx - W * 0.45, by + H * 0.25), -- 735
			Vec2(cx + W * 0.42, by + H * 0.25), -- 736
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 737
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 738
		}, -- 738
		Color(56, 52, 46, 255), -- 739
		1.2, -- 739
		Color(128, 118, 100, 180) -- 739
	) -- 739
	local headX = cx + f * 5 -- 741
	local headY = by + H * 0.88 -- 742
	fgDraw:drawCircle( -- 743
		Vec2(headX, headY), -- 743
		W * 0.3, -- 743
		Color(42, 38, 34, 255) -- 743
	) -- 743
	fgGlow:drawDot( -- 744
		Vec2(headX + f * 6, headY), -- 744
		3, -- 744
		toColor(coneCol, 245) -- 744
	) -- 744
	local indY = by + H + 18 -- 747
	if p.scavChase then -- 747
		drawDiamond( -- 749
			fgGlow, -- 749
			cx, -- 749
			indY, -- 749
			9, -- 749
			12, -- 749
			toColor(PALETTE.crimson, 240), -- 749
			1.5, -- 749
			toColor(PALETTE.crimsonCore) -- 749
		) -- 749
	elseif p.scavSee > 0 then -- 749
		local frac = math.min(1, p.scavSee / 24) -- 751
		fgGlow:drawArc( -- 752
			Vec2(cx, indY), -- 752
			11, -- 752
			90, -- 752
			90 - 360 * frac, -- 752
			2.4, -- 752
			toColor(PALETTE.crimson, 235) -- 752
		) -- 752
		fgGlow:drawDot( -- 753
			Vec2(cx, indY), -- 753
			3, -- 753
			toColor(PALETTE.amber) -- 753
		) -- 753
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 753
		drawDiamond( -- 755
			fgGlow, -- 755
			cx, -- 755
			indY, -- 755
			6, -- 755
			8, -- 755
			toColor(PALETTE.amber, 220) -- 755
		) -- 755
	end -- 755
end -- 687
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 760
	local cx = cam:sx(p.dogX) -- 767
	local by = cam:sy(0) -- 768
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 769
	local W = cam:len(34) -- 770
	local H = cam:len(28) -- 771
	local frame = 0 -- 773
	if p.dogState == "ear" then -- 773
		frame = 1 -- 775
	elseif p.dogState == "sniff" then -- 775
		frame = 3 -- 777
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 777
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 779
	end -- 779
	if assets:tryPlace( -- 779
		"dog", -- 781
		"actor_dog", -- 781
		cx, -- 781
		by, -- 781
		W, -- 781
		H, -- 781
		{facing = f, frame = frame, layer = 3} -- 781
	) then -- 781
		return -- 782
	end -- 782
	fgDraw:drawEllipse( -- 785
		Vec2(cx, by + 1), -- 785
		W * 0.56, -- 785
		3.5, -- 785
		Color(4, 8, 10, 155) -- 785
	) -- 785
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 786
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 787
	fgDraw:drawSegment( -- 790
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 790
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 790
		2.8, -- 790
		Color(26, 30, 34, 255) -- 790
	) -- 790
	fgDraw:drawSegment( -- 791
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 791
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 791
		2.8, -- 791
		Color(36, 40, 44, 255) -- 791
	) -- 791
	fgDraw:drawPolygon( -- 793
		{ -- 793
			Vec2(cx - W * 0.42, by + H * 0.36), -- 794
			Vec2(cx + W * 0.38, by + H * 0.42), -- 795
			Vec2(cx + W * 0.34, by + H * 0.78), -- 796
			Vec2(cx - W * 0.38, by + H * 0.72) -- 797
		}, -- 797
		Color(38, 42, 48, 255), -- 798
		1.2, -- 798
		Color(102, 118, 126, 175) -- 798
	) -- 798
	local hx = cx + f * W * 0.42 -- 799
	local hy = by + H * 0.84 -- 800
	fgDraw:drawPolygon( -- 801
		{ -- 801
			Vec2(hx - f * 8, hy - 6), -- 802
			Vec2(hx + f * 12, hy - 2), -- 803
			Vec2(hx + f * 4, hy + 8), -- 804
			Vec2(hx - f * 6, hy + 14) -- 805
		}, -- 805
		Color(44, 48, 54, 255) -- 806
	) -- 806
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 808
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 809
	fgGlow:drawDot( -- 810
		Vec2(hx + f * 4, hy + 2), -- 810
		2.8, -- 810
		toColor(eyeCol, 250) -- 810
	) -- 810
	fillRadialGlow( -- 811
		fgGlow, -- 811
		hx + f * 4, -- 811
		hy + 2, -- 811
		16, -- 811
		16, -- 811
		toColor(eyeCol, alert and 135 or 70), -- 811
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 811
		12 -- 811
	) -- 811
	if alert then -- 811
		local r = 12 + self.animTime * 42 % 24 -- 814
		fgGlow:drawArc( -- 815
			Vec2(hx, hy + 12), -- 815
			r, -- 815
			35, -- 815
			145, -- 815
			1.8, -- 815
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 815
		) -- 815
	end -- 815
end -- 760
return ____exports -- 760