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
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 238
	local half = a.w * 0.5 -- 239
	local g = 0 -- 240
	local i = 0 -- 241
	do -- 241
		i = 0 -- 242
		while i < #p.room.floors do -- 242
			local f = p.room.floors[i + 1] -- 243
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 243
				g = f.y -- 245
			end -- 245
			i = i + 1 -- 242
		end -- 242
	end -- 242
	do -- 242
		i = 0 -- 248
		while i < #p.boxes do -- 248
			do -- 248
				local b = p.boxes[i + 1] -- 249
				if b.broken == true or b.hidden == true or b.soft == true then -- 249
					goto __continue44 -- 251
				end -- 251
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 251
					g = b.y1 -- 255
				end -- 255
			end -- 255
			::__continue44:: -- 255
			i = i + 1 -- 248
		end -- 248
	end -- 248
	return g -- 258
end -- 238
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 262
	local cx = cam:sx(a.x) -- 271
	local by = cam:sy(a.y, a.depth) -- 272
	local depthEnabled = p.room.depth ~= nil -- 273
	local shadowY = depthEnabled and not a.onGround and cam:sy( -- 274
		self:supportGroundY(p, a), -- 274
		a.depth -- 274
	) or by -- 274
	local H = cam:len(a.h) -- 275
	local W = cam:len(a.w) -- 276
	local f = a.facing -- 277
	local speed = math.max( -- 278
		math.abs(a.vx), -- 278
		math.abs(a.depthSpeed) -- 278
	) -- 278
	local slot = "soldier_idle" -- 280
	local height = H -- 281
	local frame = 0 -- 282
	local facing = f -- 283
	local step = math.floor(self.animTime * 10) -- 284
	local ____isControlled_5 -- 285
	if isControlled then -- 285
		____isControlled_5 = self.playerStride -- 285
	else -- 285
		____isControlled_5 = self.partnerStride -- 285
	end -- 285
	local gait = ____isControlled_5 -- 285
	if isControlled and p.ticks < self.hitUntil then -- 285
		slot = "soldier_hit" -- 287
	elseif a.rollT > 0 then -- 287
		slot = "soldier_slide" -- 289
		local progress = self:slidePhase(a) -- 290
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 291
	elseif p.phase == "prologue-give" then -- 291
		slot = "soldier_offer" -- 293
		height = height * 0.75 -- 294
		facing = p.partner.x >= a.x and 1 or -1 -- 295
	elseif isControlled and p.gripping then -- 295
		slot = "soldier_push" -- 297
		frame = self.cartMoving and step or 0 -- 298
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 299
		height = height * 0.91 -- 300
	elseif isControlled and p.escort.state == "calming" then -- 300
		slot = "soldier_knock" -- 302
		local calm = p.escort.calmTick -- 303
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 304
		height = height * 0.76 -- 305
	else -- 305
		local ____temp_8 = p.phase == "gate-send" -- 306
		if ____temp_8 then -- 306
			local ____opt_6 = p.room.story -- 306
			____temp_8 = (____opt_6 and ____opt_6.gate) ~= nil -- 306
		end -- 306
		if ____temp_8 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 306
			slot = "soldier_hold" -- 308
			height = height * 1.11 -- 309
		elseif isControlled and p.ticks < self.shotUntil then -- 309
			local running = speed > 8 -- 311
			slot = running and "soldier_fire_move" or "soldier_fire" -- 312
			frame = running and step or 0 -- 313
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 314
		elseif a.covered or isControlled and p.coverHug then -- 314
			slot = "soldier_cover" -- 316
			height = height * 0.77 -- 317
		elseif (gait and gait.speed or 0) > 8 then -- 317
			slot = "soldier_run" -- 319
			frame = step -- 320
		end -- 320
	end -- 320
	local pose = { -- 322
		facing = facing, -- 323
		frame = frame, -- 323
		layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 323
	} -- 323
	local sliding = slot == "soldier_slide" and assets:tryPlaceSlide( -- 325
		"actor_soldier", -- 326
		cx, -- 326
		by, -- 326
		W, -- 326
		height, -- 326
		self:slidePhase(a), -- 326
		pose -- 326
	) -- 326
	local running = (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 327
		"soldier", -- 329
		"actor_soldier", -- 329
		cx, -- 329
		by, -- 329
		W, -- 329
		height, -- 329
		gait.cycle, -- 329
		pose, -- 329
		gait.effort -- 329
	) -- 329
	if sliding or running or assets:tryPlace( -- 329
		slot, -- 330
		"actor_soldier", -- 330
		cx, -- 330
		by, -- 330
		W, -- 330
		height, -- 330
		pose -- 330
	) then -- 330
		fgDraw:drawEllipse( -- 331
			Vec2(cx, shadowY + 1), -- 331
			W * 0.54, -- 331
			4, -- 331
			Color(12, 11, 13, 145) -- 331
		) -- 331
		return -- 332
	end -- 332
	fgDraw:drawEllipse( -- 336
		Vec2(cx, shadowY + 1), -- 336
		H * 0.24, -- 336
		4.5, -- 336
		Color(3, 5, 10, 175) -- 336
	) -- 336
	local walking = speed > 10 and a.onGround -- 338
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 339
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 340
	local calming = not p.childMode and p.escort.state == "calming" -- 341
	local rolling = a.rollT > 0 -- 342
	local crouching = a.covered or calming or rolling -- 343
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 346
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 347
	local sw = H * 0.115 -- 348
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 351
	local kneeY = by + bodyH * 0.23 -- 352
	local stepX = stride * H * 0.15 -- 353
	local legDark = Color(14, 21, 34, 255) -- 354
	local legFront = Color(26, 38, 58, 255) -- 355
	local bkX = cx - f * 4 - stepX * 0.5 -- 357
	local bfX = cx - f * 8 - stepX -- 358
	fgDraw:drawSegment( -- 359
		Vec2(cx - f * 3, hipY), -- 359
		Vec2(bkX, kneeY), -- 359
		H * 0.044, -- 359
		legDark -- 359
	) -- 359
	fgDraw:drawSegment( -- 360
		Vec2(bkX, kneeY), -- 360
		Vec2(bfX, by + 3), -- 360
		H * 0.038, -- 360
		legDark -- 360
	) -- 360
	local fkX = cx + f * 6 + stepX * 0.55 -- 362
	local ffX = cx + f * 7 + stepX -- 363
	fgDraw:drawSegment( -- 364
		Vec2(cx + f * 3, hipY), -- 364
		Vec2(fkX, kneeY), -- 364
		H * 0.048, -- 364
		legFront -- 364
	) -- 364
	fgDraw:drawSegment( -- 365
		Vec2(fkX, kneeY), -- 365
		Vec2(ffX, by + 3), -- 365
		H * 0.042, -- 365
		legFront -- 365
	) -- 365
	fgDraw:drawSegment( -- 367
		Vec2(ffX - f * 2, by + 3), -- 367
		Vec2(ffX + f * 9, by + 3), -- 367
		3.4, -- 367
		Color(42, 60, 86, 255) -- 367
	) -- 367
	local shY = by + bodyH * 0.8 + bob -- 370
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 371
	fgDraw:drawPolygon( -- 372
		{ -- 372
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 373
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 374
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 375
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 376
		}, -- 376
		Color(16, 26, 42, 248), -- 377
		1.2, -- 377
		Color(64, 118, 164, 195) -- 377
	) -- 377
	fgDraw:drawPolygon( -- 380
		{ -- 380
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 381
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 382
			Vec2(cx + sw * 1.05 + lean, shY), -- 383
			Vec2(cx - sw * 0.98 + lean, shY) -- 384
		}, -- 384
		Color(24, 38, 60, 255), -- 385
		1.3, -- 385
		toColor(PALETTE.rimSilver, 190) -- 385
	) -- 385
	fgDraw:drawSegment( -- 387
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 388
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 389
		2.4, -- 390
		Color(173, 155, 125, 225) -- 391
	) -- 391
	fgDraw:drawPolygon( -- 393
		{ -- 393
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 394
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 395
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 396
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 397
		}, -- 397
		Color(99, 105, 103, 248) -- 398
	) -- 398
	local headR = H * 0.088 -- 401
	local headX = cx + lean + f * 3 -- 402
	local headY = shY + headR * 1.35 -- 403
	fgDraw:drawCircle( -- 404
		Vec2(headX, headY - headR * 0.12), -- 404
		headR * 0.86, -- 404
		Color(181, 139, 106, 255) -- 404
	) -- 404
	fgDraw:drawEllipse( -- 405
		Vec2(headX, headY + headR * 0.5), -- 405
		headR * 1.12, -- 405
		headR * 0.72, -- 405
		Color(66, 73, 76, 255) -- 405
	) -- 405
	fgDraw:drawSegment( -- 406
		Vec2(headX - headR, headY + 1), -- 406
		Vec2(headX + headR, headY + 1), -- 406
		1.6, -- 407
		Color(97, 103, 101, 255) -- 407
	) -- 407
	fgDraw:drawSegment( -- 408
		Vec2(headX, headY + headR), -- 408
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 408
		1.6, -- 409
		Color(177, 78, 51, 255) -- 409
	) -- 409
	if isControlled and not calming and not rolling and not p.gripping then -- 409
		local gunPivotX = cx + lean + f * sw * 0.35 -- 413
		local gunPivotY = shY - bodyH * 0.1 -- 414
		local aimDx = f -- 415
		local aimDy = 0 -- 416
		if p.aimX > 0 or p.aimY > 0 then -- 416
			aimDx = p.aimX - gunPivotX -- 418
			aimDy = p.aimY - gunPivotY -- 419
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 420
			if dLen > 4 then -- 420
				aimDx = aimDx / dLen -- 422
				aimDy = aimDy / dLen -- 423
			end -- 423
		end -- 423
		local barrelLen = H * 0.34 -- 426
		local tipX = gunPivotX + aimDx * barrelLen -- 427
		local tipY = gunPivotY + aimDy * barrelLen -- 428
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 429
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 430
		fgDraw:drawSegment( -- 432
			Vec2(cx + lean, shY - 5), -- 432
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 432
			3.6, -- 432
			Color(26, 40, 62, 255) -- 432
		) -- 432
		fgDraw:drawSegment( -- 433
			Vec2(stockX, stockY), -- 433
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 433
			3.8, -- 433
			Color(105, 71, 50, 255) -- 433
		) -- 433
		fgDraw:drawSegment( -- 434
			Vec2(gunPivotX, gunPivotY), -- 434
			Vec2(tipX, tipY), -- 434
			1.8, -- 434
			Color(145, 140, 128, 245) -- 434
		) -- 434
	elseif calming then -- 434
		fgDraw:drawSegment( -- 436
			Vec2(cx + lean, shY - 6), -- 436
			Vec2(cx + f * sw * 2.1, shY - 14), -- 436
			3, -- 436
			Color(196, 222, 240, 235) -- 436
		) -- 436
		fgGlow:drawDot( -- 437
			Vec2(cx + f * sw * 2.15, shY - 14), -- 437
			3.6, -- 437
			toColor(PALETTE.amber, 225) -- 437
		) -- 437
	end -- 437
end -- 262
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 443
	local cx = cam:sx(a.x) -- 452
	local by = cam:sy(a.y, a.depth) -- 453
	local depthEnabled = p.room.depth ~= nil -- 454
	local shadowY = depthEnabled and not a.onGround and cam:sy( -- 455
		self:supportGroundY(p, a), -- 455
		a.depth -- 455
	) or by -- 455
	local H = cam:len(a.h) -- 456
	local W = cam:len(a.w) -- 457
	local f = a.facing -- 458
	local speed = math.max( -- 459
		math.abs(a.vx), -- 459
		math.abs(a.depthSpeed) -- 459
	) -- 459
	local ____isControlled_11 -- 460
	if isControlled then -- 460
		____isControlled_11 = self.playerStride -- 460
	else -- 460
		____isControlled_11 = self.partnerStride -- 460
	end -- 460
	local gait = ____isControlled_11 -- 460
	local afraid = not isControlled and p.escort.fear > 0 -- 462
	local slot = "child_idle" -- 463
	local height = H -- 464
	local frame = 0 -- 465
	local step = math.floor(self.animTime * 10) -- 466
	local nearCover = __TS__ArraySome( -- 467
		p.room.solids, -- 467
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 467
			math.abs(a.x - solid.x), -- 470
			math.abs(a.x - solid.x - solid.w) -- 470
		) <= 30 end -- 470
	) -- 470
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 470
		slot = "child_knock" -- 473
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 473
		slot = "child_offer" -- 476
	elseif isControlled and p.ticks < self.throwUntil then -- 476
		slot = "child_throw" -- 478
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 478
		slot = "child_aim" -- 480
	elseif isControlled and p.gripping then -- 480
		slot = "child_pull" -- 482
		frame = self.cartMoving and step or 0 -- 483
	elseif afraid and p.escort.state == "frozen" then -- 483
		slot = "child_fear" -- 485
		height = height * 0.74 -- 486
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 486
		slot = "child_peek" -- 489
		height = height * 0.83 -- 490
	elseif a.crouch then -- 490
		slot = "child_crouch" -- 492
		frame = speed > 8 and step or 0 -- 493
	elseif (gait and gait.speed or 0) > 8 then -- 493
		slot = "child_run" -- 495
		frame = step -- 496
	end -- 496
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 498
	local pose = { -- 499
		facing = facing, -- 500
		frame = frame, -- 500
		layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 500
	} -- 500
	local running = (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 502
		"child", -- 504
		"actor_child", -- 504
		cx, -- 504
		by, -- 504
		W, -- 504
		height, -- 504
		gait.cycle, -- 504
		pose, -- 504
		gait.effort -- 504
	) -- 504
	if running or assets:tryPlace( -- 504
		slot, -- 505
		"actor_child", -- 505
		cx, -- 505
		by, -- 505
		W, -- 505
		height, -- 505
		pose -- 505
	) then -- 505
		fgDraw:drawEllipse( -- 506
			Vec2(cx, shadowY + 1), -- 506
			W * 0.48, -- 506
			3, -- 506
			Color(12, 11, 13, 125) -- 506
		) -- 506
		if afraid then -- 506
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 508
		end -- 508
		return -- 510
	end -- 510
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 513
	local x = cx + jitter -- 514
	local fullRef = a.crouch and H * 1.35 or H -- 516
	local cw = fullRef * 0.16 -- 517
	fgDraw:drawEllipse( -- 520
		Vec2(x, shadowY + 1), -- 520
		cw * 1.15, -- 520
		3.6, -- 520
		Color(4, 6, 10, 155) -- 520
	) -- 520
	local walking = speed > 6 and a.onGround -- 522
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 523
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 524
	local hipY = by + H * 0.3 -- 527
	local legSwing = stride * cw * 0.85 -- 528
	fgDraw:drawSegment( -- 529
		Vec2(x - 2, hipY), -- 529
		Vec2(x - legSwing, by + 2), -- 529
		math.max(2.6, cw * 0.22), -- 529
		Color(34, 30, 38, 255) -- 529
	) -- 529
	fgDraw:drawSegment( -- 530
		Vec2(x + 2, hipY), -- 530
		Vec2(x + legSwing, by + 2), -- 530
		math.max(2.8, cw * 0.24), -- 530
		Color(52, 46, 56, 255) -- 530
	) -- 530
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 533
	local cloakBotY = by + H * 0.2 -- 534
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 535
	fgDraw:drawPolygon( -- 536
		{ -- 536
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 537
			Vec2(x + cw * 0.92, cloakBotY), -- 538
			Vec2(x + cw * 0.62, cloakTopY), -- 539
			Vec2(x - cw * 0.68, cloakTopY) -- 540
		}, -- 540
		Color(214, 166, 94, 255), -- 541
		1.3, -- 541
		Color(252, 232, 192, 225) -- 541
	) -- 541
	fgDraw:drawPolygon( -- 542
		{ -- 542
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 543
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 544
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 545
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 546
		}, -- 546
		Color(148, 108, 56, 215) -- 547
	) -- 547
	fgDraw:drawSegment( -- 548
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 548
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 548
		1.8, -- 548
		toColor(PALETTE.amberCore, 200) -- 548
	) -- 548
	local scarfY = cloakTopY - 2 -- 551
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 552
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 553
	local sendX = x - f * cw * 1.65 + cloakDrag -- 554
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 555
	fgDraw:drawQuadraticBezier( -- 556
		Vec2(x - f * cw * 0.3, scarfY), -- 556
		Vec2(smidX, smidY), -- 556
		Vec2(sendX, sendY), -- 556
		2.8, -- 556
		toColor(PALETTE.amberCore, 235) -- 556
	) -- 556
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 559
	local headX = x + f * (a.crouch and 5 or 2) -- 560
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 561
	fgDraw:drawCircle( -- 562
		Vec2(headX, headY), -- 562
		headR, -- 562
		Color(240, 222, 198, 255) -- 562
	) -- 562
	fgDraw:drawPolygon( -- 564
		{ -- 564
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 565
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 566
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 567
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 568
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 569
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 570
		}, -- 570
		Color(156, 114, 62, 248), -- 571
		1.1, -- 571
		Color(244, 214, 162, 200) -- 571
	) -- 571
	fgGlow:drawDot( -- 573
		Vec2(headX + f * headR * 0.45, headY + 1), -- 573
		2.2, -- 573
		toColor(PALETTE.amberCore) -- 573
	) -- 573
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 576
	if hasCompass then -- 576
		local compX = x + f * cw * 0.65 -- 578
		local compY = by + H * 0.48 -- 579
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 580
		fgGlow:drawDot( -- 581
			Vec2(compX, compY), -- 581
			2.6, -- 581
			toColor(PALETTE.amberCore, 250) -- 581
		) -- 581
		fillRadialGlow( -- 582
			fgGlow, -- 582
			compX, -- 582
			compY, -- 582
			26 * glowPulse, -- 582
			26 * glowPulse, -- 582
			Color(248, 206, 120, 78 * glowPulse), -- 582
			Color(248, 180, 72, 0), -- 582
			14 -- 582
		) -- 582
	end -- 582
	if afraid then -- 582
		self:drawFear(fgGlow, p, x, by + H + 16) -- 586
	end -- 586
	if isControlled and walking and not a.crouch and speed > 100 then -- 586
		local r = 10 + self.animTime * 32 % 24 -- 591
		fgGlow:drawRing( -- 592
			Vec2(x, by + 3), -- 592
			r, -- 592
			r + 1.5, -- 592
			Color(0, 0, 0, 0), -- 592
			1.1, -- 592
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 592
		) -- 592
	end -- 592
end -- 443
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 596
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 597
	do -- 597
		local i = 0 -- 598
		while i < FEAR_MAX do -- 598
			local lit = i < p.escort.fear -- 599
			drawDiamond( -- 600
				fgGlow, -- 600
				x + (i - 1) * 13, -- 600
				y, -- 600
				4, -- 600
				5, -- 600
				toColor(lit and tint or PALETTE.steelDark, 215), -- 601
				1, -- 601
				toColor(tint, lit and 235 or 100) -- 601
			) -- 601
			i = i + 1 -- 598
		end -- 598
	end -- 598
end -- 596
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 605
	local x = cam:sx(e.x + f * 20) -- 606
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 607
	local dx = cam:sx(p.player.x) - x -- 608
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 609
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 610
	do -- 610
		local i = 0 -- 611
		while i < 8 do -- 611
			local a = length * i / 8 -- 612
			local b = length * (i + 1) / 8 -- 613
			fgGlow:drawSegment( -- 614
				Vec2(x + dx * a, y + dy * a), -- 614
				Vec2(x + dx * b, y + dy * b), -- 614
				1.3, -- 615
				Color(220, 120, 88, 210) -- 615
			) -- 615
			i = i + 2 -- 611
		end -- 611
	end -- 611
end -- 605
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 620
	local cx = cam:sx(e.x) -- 629
	local depth = e.depth or 0 -- 630
	local by = cam:sy(e.y, depth) -- 631
	local H = cam:len(e.h) -- 632
	local W = cam:len(e.w) -- 633
	local f = p.player.x >= e.x and 1 or -1 -- 634
	local slot = "enemy_idle" -- 636
	if not e.alive then -- 636
		slot = "enemy_down" -- 638
	elseif e.hitT > 0 then -- 638
		slot = "enemy_hit" -- 640
	elseif e.warnT > 0 then -- 640
		slot = "enemy_aim" -- 642
	end -- 642
	local height = e.alive and H or H * 0.24 -- 644
	if assets:tryPlace( -- 644
		slot, -- 645
		"actor_enemy_" .. tostring(index), -- 645
		cx, -- 645
		by, -- 645
		W, -- 645
		height, -- 645
		{ -- 645
			facing = f, -- 646
			opacity = e.alive and 1 or 0.78, -- 646
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 646
		} -- 646
	) then -- 646
		if e.alive and e.warnT > 0 then -- 646
			self:drawEnemyWarning( -- 649
				fgGlow, -- 649
				e, -- 649
				p, -- 649
				cam, -- 649
				f -- 649
			) -- 649
		end -- 649
		return -- 651
	end -- 651
	if not e.alive then -- 651
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 655
		fgDraw:drawPolygon( -- 656
			{ -- 656
				Vec2(cx - H * 0.3, by), -- 657
				Vec2(cx + H * 0.28, by), -- 658
				Vec2(cx + H * 0.2, by + H * 0.14), -- 659
				Vec2(cx - H * 0.24, by + H * 0.11) -- 660
			}, -- 660
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 661
		) -- 661
		if flash > 0 then -- 661
			fillRadialGlow( -- 663
				fgGlow, -- 663
				cx, -- 663
				by + 12, -- 663
				34 * flash, -- 663
				18 * flash, -- 663
				toColor(PALETTE.crimson, 180 * flash), -- 663
				Color(255, 48, 82, 0), -- 663
				12 -- 663
			) -- 663
		end -- 663
		return -- 665
	end -- 665
	local sw = H * 0.112 -- 668
	fgDraw:drawEllipse( -- 669
		Vec2(cx, by + 1), -- 669
		sw * 1.9, -- 669
		4, -- 669
		Color(4, 6, 10, 165) -- 669
	) -- 669
	local hipY = by + H * 0.44 -- 672
	local kneeY = by + H * 0.23 -- 673
	local shY = by + H * 0.79 -- 674
	fgDraw:drawSegment( -- 675
		Vec2(cx - 5, hipY), -- 675
		Vec2(cx - 7, kneeY), -- 675
		H * 0.044, -- 675
		Color(20, 16, 26, 255) -- 675
	) -- 675
	fgDraw:drawSegment( -- 676
		Vec2(cx - 7, kneeY), -- 676
		Vec2(cx - 8, by + 2), -- 676
		H * 0.038, -- 676
		Color(20, 16, 26, 255) -- 676
	) -- 676
	fgDraw:drawSegment( -- 677
		Vec2(cx + 5, hipY), -- 677
		Vec2(cx + 7, kneeY), -- 677
		H * 0.046, -- 677
		Color(28, 22, 36, 255) -- 677
	) -- 677
	fgDraw:drawSegment( -- 678
		Vec2(cx + 7, kneeY), -- 678
		Vec2(cx + 8, by + 2), -- 678
		H * 0.04, -- 678
		Color(28, 22, 36, 255) -- 678
	) -- 678
	fgDraw:drawPolygon( -- 680
		{ -- 680
			Vec2(cx - sw * 0.68, hipY), -- 681
			Vec2(cx + sw * 0.68, hipY), -- 682
			Vec2(cx + sw * 1.12, shY), -- 683
			Vec2(cx - sw * 1.12, shY) -- 684
		}, -- 684
		Color(111, 68, 55, 255), -- 685
		1.3, -- 685
		Color(143, 101, 66, 220) -- 685
	) -- 685
	fgDraw:drawPolygon( -- 686
		{ -- 686
			Vec2(cx - sw * 1.26, shY - 6), -- 687
			Vec2(cx + sw * 1.26, shY - 6), -- 688
			Vec2(cx + sw * 0.96, shY + 5), -- 689
			Vec2(cx - sw * 0.96, shY + 5) -- 690
		}, -- 690
		Color(98, 82, 62, 255) -- 691
	) -- 691
	local headR = H * 0.086 -- 693
	local headY = shY + headR * 1.32 -- 694
	fgDraw:drawCircle( -- 695
		Vec2(cx, headY), -- 695
		headR * 0.82, -- 695
		Color(187, 142, 103, 255) -- 695
	) -- 695
	fgDraw:drawPolygon( -- 696
		{ -- 696
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 697
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 698
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 699
		}, -- 699
		Color(136, 105, 65, 255), -- 700
		1.1, -- 700
		Color(177, 145, 91, 220) -- 700
	) -- 700
	local gunX = cx + f * H * 0.34 -- 702
	local gunY = by + H * 0.69 -- 703
	fgDraw:drawSegment( -- 704
		Vec2(cx - f * 6, gunY - 2), -- 704
		Vec2(gunX, gunY), -- 704
		2.8, -- 704
		Color(118, 87, 61, 255) -- 704
	) -- 704
	if e.warnT > 0 then -- 704
		self:drawEnemyWarning( -- 706
			fgGlow, -- 706
			e, -- 706
			p, -- 706
			cam, -- 706
			f -- 706
		) -- 706
	end -- 706
end -- 620
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 711
	local s = p.room.scavenger -- 718
	if s == nil then -- 718
		return -- 720
	end -- 720
	local cx = cam:sx(p.scavX) -- 722
	local by = cam:sy(s.y) -- 723
	local H = cam:len(s.h) -- 724
	local W = cam:len(26) -- 725
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 726
	local alert = p.scavChase or p.scavSee > 0 -- 729
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 730
	local eyeY = by + H * 0.8 -- 731
	local coneLen = cam:len(alert and 155 or 115) -- 732
	fgGlow:drawVertices({ -- 733
		{ -- 734
			Vec2(cx + f * 6, eyeY), -- 734
			toColor(coneCol, alert and 78 or 34) -- 734
		}, -- 734
		{ -- 735
			Vec2(cx + f * coneLen, by + H * 1.05), -- 735
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 735
		}, -- 735
		{ -- 736
			Vec2(cx + f * coneLen, by + 4), -- 736
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 736
		} -- 736
	}) -- 736
	local frame = 0 -- 739
	if p.scavState == "turn" then -- 739
		frame = 2 -- 741
	elseif p.scavState == "chase" then -- 741
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 743
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 743
		frame = math.floor(self.animTime * 8) % 2 -- 745
	end -- 745
	if assets:tryPlace( -- 745
		"scavenger", -- 747
		"actor_scav", -- 747
		cx, -- 747
		by, -- 747
		W, -- 747
		H, -- 747
		{facing = f, frame = frame, layer = 3} -- 747
	) then -- 747
		return -- 748
	end -- 748
	fgDraw:drawEllipse( -- 751
		Vec2(cx, by + 1), -- 751
		W * 0.62, -- 751
		4, -- 751
		Color(4, 6, 10, 155) -- 751
	) -- 751
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 752
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 753
	fgDraw:drawSegment( -- 755
		Vec2(cx - 4, by + H * 0.4), -- 755
		Vec2(cx - stride, by + 2), -- 755
		W * 0.16, -- 755
		Color(32, 30, 28, 255) -- 755
	) -- 755
	fgDraw:drawSegment( -- 756
		Vec2(cx + 4, by + H * 0.4), -- 756
		Vec2(cx + stride, by + 2), -- 756
		W * 0.16, -- 756
		Color(44, 40, 36, 255) -- 756
	) -- 756
	fgDraw:drawPolygon( -- 758
		{ -- 758
			Vec2(cx - W * 0.45, by + H * 0.25), -- 759
			Vec2(cx + W * 0.42, by + H * 0.25), -- 760
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 761
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 762
		}, -- 762
		Color(56, 52, 46, 255), -- 763
		1.2, -- 763
		Color(128, 118, 100, 180) -- 763
	) -- 763
	local headX = cx + f * 5 -- 765
	local headY = by + H * 0.88 -- 766
	fgDraw:drawCircle( -- 767
		Vec2(headX, headY), -- 767
		W * 0.3, -- 767
		Color(42, 38, 34, 255) -- 767
	) -- 767
	fgGlow:drawDot( -- 768
		Vec2(headX + f * 6, headY), -- 768
		3, -- 768
		toColor(coneCol, 245) -- 768
	) -- 768
	local indY = by + H + 18 -- 771
	if p.scavChase then -- 771
		drawDiamond( -- 773
			fgGlow, -- 773
			cx, -- 773
			indY, -- 773
			9, -- 773
			12, -- 773
			toColor(PALETTE.crimson, 240), -- 773
			1.5, -- 773
			toColor(PALETTE.crimsonCore) -- 773
		) -- 773
	elseif p.scavSee > 0 then -- 773
		local frac = math.min(1, p.scavSee / 24) -- 775
		fgGlow:drawArc( -- 776
			Vec2(cx, indY), -- 776
			11, -- 776
			90, -- 776
			90 - 360 * frac, -- 776
			2.4, -- 776
			toColor(PALETTE.crimson, 235) -- 776
		) -- 776
		fgGlow:drawDot( -- 777
			Vec2(cx, indY), -- 777
			3, -- 777
			toColor(PALETTE.amber) -- 777
		) -- 777
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 777
		drawDiamond( -- 779
			fgGlow, -- 779
			cx, -- 779
			indY, -- 779
			6, -- 779
			8, -- 779
			toColor(PALETTE.amber, 220) -- 779
		) -- 779
	end -- 779
end -- 711
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 784
	local cx = cam:sx(p.dogX) -- 791
	local by = cam:sy(0) -- 792
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 793
	local W = cam:len(34) -- 794
	local H = cam:len(28) -- 795
	local frame = 0 -- 797
	if p.dogState == "ear" then -- 797
		frame = 1 -- 799
	elseif p.dogState == "sniff" then -- 799
		frame = 3 -- 801
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 801
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 803
	end -- 803
	if assets:tryPlace( -- 803
		"dog", -- 805
		"actor_dog", -- 805
		cx, -- 805
		by, -- 805
		W, -- 805
		H, -- 805
		{facing = f, frame = frame, layer = 3} -- 805
	) then -- 805
		return -- 806
	end -- 806
	fgDraw:drawEllipse( -- 809
		Vec2(cx, by + 1), -- 809
		W * 0.56, -- 809
		3.5, -- 809
		Color(4, 8, 10, 155) -- 809
	) -- 809
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 810
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 811
	fgDraw:drawSegment( -- 814
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 814
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 814
		2.8, -- 814
		Color(26, 30, 34, 255) -- 814
	) -- 814
	fgDraw:drawSegment( -- 815
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 815
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 815
		2.8, -- 815
		Color(36, 40, 44, 255) -- 815
	) -- 815
	fgDraw:drawPolygon( -- 817
		{ -- 817
			Vec2(cx - W * 0.42, by + H * 0.36), -- 818
			Vec2(cx + W * 0.38, by + H * 0.42), -- 819
			Vec2(cx + W * 0.34, by + H * 0.78), -- 820
			Vec2(cx - W * 0.38, by + H * 0.72) -- 821
		}, -- 821
		Color(38, 42, 48, 255), -- 822
		1.2, -- 822
		Color(102, 118, 126, 175) -- 822
	) -- 822
	local hx = cx + f * W * 0.42 -- 823
	local hy = by + H * 0.84 -- 824
	fgDraw:drawPolygon( -- 825
		{ -- 825
			Vec2(hx - f * 8, hy - 6), -- 826
			Vec2(hx + f * 12, hy - 2), -- 827
			Vec2(hx + f * 4, hy + 8), -- 828
			Vec2(hx - f * 6, hy + 14) -- 829
		}, -- 829
		Color(44, 48, 54, 255) -- 830
	) -- 830
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 832
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 833
	fgGlow:drawDot( -- 834
		Vec2(hx + f * 4, hy + 2), -- 834
		2.8, -- 834
		toColor(eyeCol, 250) -- 834
	) -- 834
	fillRadialGlow( -- 835
		fgGlow, -- 835
		hx + f * 4, -- 835
		hy + 2, -- 835
		16, -- 835
		16, -- 835
		toColor(eyeCol, alert and 135 or 70), -- 835
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 835
		12 -- 835
	) -- 835
	if alert then -- 835
		local r = 12 + self.animTime * 42 % 24 -- 838
		fgGlow:drawArc( -- 839
			Vec2(hx, hy + 12), -- 839
			r, -- 839
			35, -- 839
			145, -- 839
			1.8, -- 839
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 839
		) -- 839
	end -- 839
end -- 784
return ____exports -- 784