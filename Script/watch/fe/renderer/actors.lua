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
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled, bodyPlaced) -- 263
	if bodyPlaced == nil then -- 263
		bodyPlaced = false -- 271
	end -- 271
	local cx = cam:sx(a.x) -- 273
	local by = cam:sy(a.y, a.depth) -- 274
	local depthEnabled = p.room.depth ~= nil -- 275
	local shadowY = depthEnabled and not a.onGround and cam:sy( -- 276
		self:supportGroundY(p, a), -- 276
		a.depth -- 276
	) or by -- 276
	local H = cam:len(a.h) -- 277
	local W = cam:len(a.w) -- 278
	local f = a.facing -- 279
	local speed = math.max( -- 280
		math.abs(a.vx), -- 280
		math.abs(a.depthSpeed) -- 280
	) -- 280
	local slot = "soldier_idle" -- 282
	local height = H -- 283
	local frame = 0 -- 284
	local facing = f -- 285
	local step = math.floor(self.animTime * 10) -- 286
	local ____isControlled_9 -- 287
	if isControlled then -- 287
		____isControlled_9 = self.playerStride -- 287
	else -- 287
		____isControlled_9 = self.partnerStride -- 287
	end -- 287
	local gait = ____isControlled_9 -- 287
	if isControlled and p.ticks < self.hitUntil then -- 287
		slot = "soldier_hit" -- 289
	elseif a.rollT > 0 then -- 289
		slot = "soldier_slide" -- 291
		local progress = self:slidePhase(a) -- 292
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 293
	elseif p.phase == "prologue-give" then -- 293
		slot = "soldier_offer" -- 295
		height = height * 0.75 -- 296
		facing = p.partner.x >= a.x and 1 or -1 -- 297
	elseif isControlled and p.gripping then -- 297
		slot = "soldier_push" -- 299
		frame = self.cartMoving and step or 0 -- 300
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 301
		height = height * 0.91 -- 302
	elseif isControlled and p.escort.state == "calming" then -- 302
		slot = "soldier_knock" -- 304
		local calm = p.escort.calmTick -- 305
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 306
		height = height * 0.76 -- 307
	else -- 307
		local ____temp_12 = p.phase == "gate-send" -- 308
		if ____temp_12 then -- 308
			local ____opt_10 = p.room.story -- 308
			____temp_12 = (____opt_10 and ____opt_10.gate) ~= nil -- 308
		end -- 308
		if ____temp_12 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 308
			slot = "soldier_hold" -- 310
			height = height * 1.11 -- 311
		elseif isControlled and p.ticks < self.shotUntil then -- 311
			local running = speed > 8 -- 313
			slot = running and "soldier_fire_move" or "soldier_fire" -- 314
			frame = running and step or 0 -- 315
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 316
		elseif a.covered or isControlled and p.coverHug then -- 316
			slot = "soldier_cover" -- 318
			height = height * 0.77 -- 319
		elseif (gait and gait.speed or 0) > 8 then -- 319
			slot = "soldier_run" -- 321
			frame = step -- 322
		end -- 322
	end -- 322
	local pose = { -- 324
		facing = facing, -- 325
		frame = frame, -- 325
		layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 325
	} -- 325
	local sliding = not bodyPlaced and slot == "soldier_slide" and assets:tryPlaceSlide( -- 327
		"actor_soldier", -- 328
		cx, -- 328
		by, -- 328
		W, -- 328
		height, -- 328
		self:slidePhase(a), -- 328
		pose -- 328
	) -- 328
	local running = not bodyPlaced and (slot == "soldier_run" or slot == "soldier_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 329
		"soldier", -- 331
		"actor_soldier", -- 331
		cx, -- 331
		by, -- 331
		W, -- 331
		height, -- 331
		gait.cycle, -- 331
		pose, -- 331
		gait.effort -- 331
	) -- 331
	if bodyPlaced or sliding or running or assets:tryPlace( -- 331
		slot, -- 332
		"actor_soldier", -- 332
		cx, -- 332
		by, -- 332
		W, -- 332
		height, -- 332
		pose -- 332
	) then -- 332
		fgDraw:drawEllipse( -- 333
			Vec2(cx, shadowY + 1), -- 333
			W * 0.54, -- 333
			4, -- 333
			Color(12, 11, 13, 145) -- 333
		) -- 333
		return -- 334
	end -- 334
	fgDraw:drawEllipse( -- 338
		Vec2(cx, shadowY + 1), -- 338
		H * 0.24, -- 338
		4.5, -- 338
		Color(3, 5, 10, 175) -- 338
	) -- 338
	local walking = speed > 10 and a.onGround -- 340
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 341
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 342
	local calming = not p.childMode and p.escort.state == "calming" -- 343
	local rolling = a.rollT > 0 -- 344
	local crouching = a.covered or calming or rolling -- 345
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 348
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 349
	local sw = H * 0.115 -- 350
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 353
	local kneeY = by + bodyH * 0.23 -- 354
	local stepX = stride * H * 0.15 -- 355
	local legDark = Color(14, 21, 34, 255) -- 356
	local legFront = Color(26, 38, 58, 255) -- 357
	local bkX = cx - f * 4 - stepX * 0.5 -- 359
	local bfX = cx - f * 8 - stepX -- 360
	fgDraw:drawSegment( -- 361
		Vec2(cx - f * 3, hipY), -- 361
		Vec2(bkX, kneeY), -- 361
		H * 0.044, -- 361
		legDark -- 361
	) -- 361
	fgDraw:drawSegment( -- 362
		Vec2(bkX, kneeY), -- 362
		Vec2(bfX, by + 3), -- 362
		H * 0.038, -- 362
		legDark -- 362
	) -- 362
	local fkX = cx + f * 6 + stepX * 0.55 -- 364
	local ffX = cx + f * 7 + stepX -- 365
	fgDraw:drawSegment( -- 366
		Vec2(cx + f * 3, hipY), -- 366
		Vec2(fkX, kneeY), -- 366
		H * 0.048, -- 366
		legFront -- 366
	) -- 366
	fgDraw:drawSegment( -- 367
		Vec2(fkX, kneeY), -- 367
		Vec2(ffX, by + 3), -- 367
		H * 0.042, -- 367
		legFront -- 367
	) -- 367
	fgDraw:drawSegment( -- 369
		Vec2(ffX - f * 2, by + 3), -- 369
		Vec2(ffX + f * 9, by + 3), -- 369
		3.4, -- 369
		Color(42, 60, 86, 255) -- 369
	) -- 369
	local shY = by + bodyH * 0.8 + bob -- 372
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 373
	fgDraw:drawPolygon( -- 374
		{ -- 374
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 375
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 376
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 377
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 378
		}, -- 378
		Color(16, 26, 42, 248), -- 379
		1.2, -- 379
		Color(64, 118, 164, 195) -- 379
	) -- 379
	fgDraw:drawPolygon( -- 382
		{ -- 382
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 383
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 384
			Vec2(cx + sw * 1.05 + lean, shY), -- 385
			Vec2(cx - sw * 0.98 + lean, shY) -- 386
		}, -- 386
		Color(24, 38, 60, 255), -- 387
		1.3, -- 387
		toColor(PALETTE.rimSilver, 190) -- 387
	) -- 387
	fgDraw:drawSegment( -- 389
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 390
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 391
		2.4, -- 392
		Color(173, 155, 125, 225) -- 393
	) -- 393
	fgDraw:drawPolygon( -- 395
		{ -- 395
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 396
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 397
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 398
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 399
		}, -- 399
		Color(99, 105, 103, 248) -- 400
	) -- 400
	local headR = H * 0.088 -- 403
	local headX = cx + lean + f * 3 -- 404
	local headY = shY + headR * 1.35 -- 405
	fgDraw:drawCircle( -- 406
		Vec2(headX, headY - headR * 0.12), -- 406
		headR * 0.86, -- 406
		Color(181, 139, 106, 255) -- 406
	) -- 406
	fgDraw:drawEllipse( -- 407
		Vec2(headX, headY + headR * 0.5), -- 407
		headR * 1.12, -- 407
		headR * 0.72, -- 407
		Color(66, 73, 76, 255) -- 407
	) -- 407
	fgDraw:drawSegment( -- 408
		Vec2(headX - headR, headY + 1), -- 408
		Vec2(headX + headR, headY + 1), -- 408
		1.6, -- 409
		Color(97, 103, 101, 255) -- 409
	) -- 409
	fgDraw:drawSegment( -- 410
		Vec2(headX, headY + headR), -- 410
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 410
		1.6, -- 411
		Color(177, 78, 51, 255) -- 411
	) -- 411
	if isControlled and not calming and not rolling and not p.gripping then -- 411
		local gunPivotX = cx + lean + f * sw * 0.35 -- 415
		local gunPivotY = shY - bodyH * 0.1 -- 416
		local aimDx = f -- 417
		local aimDy = 0 -- 418
		if p.aimX > 0 or p.aimY > 0 then -- 418
			aimDx = p.aimX - gunPivotX -- 420
			aimDy = p.aimY - gunPivotY -- 421
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 422
			if dLen > 4 then -- 422
				aimDx = aimDx / dLen -- 424
				aimDy = aimDy / dLen -- 425
			end -- 425
		end -- 425
		local barrelLen = H * 0.34 -- 428
		local tipX = gunPivotX + aimDx * barrelLen -- 429
		local tipY = gunPivotY + aimDy * barrelLen -- 430
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 431
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 432
		fgDraw:drawSegment( -- 434
			Vec2(cx + lean, shY - 5), -- 434
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 434
			3.6, -- 434
			Color(26, 40, 62, 255) -- 434
		) -- 434
		fgDraw:drawSegment( -- 435
			Vec2(stockX, stockY), -- 435
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 435
			3.8, -- 435
			Color(105, 71, 50, 255) -- 435
		) -- 435
		fgDraw:drawSegment( -- 436
			Vec2(gunPivotX, gunPivotY), -- 436
			Vec2(tipX, tipY), -- 436
			1.8, -- 436
			Color(145, 140, 128, 245) -- 436
		) -- 436
	elseif calming then -- 436
		fgDraw:drawSegment( -- 438
			Vec2(cx + lean, shY - 6), -- 438
			Vec2(cx + f * sw * 2.1, shY - 14), -- 438
			3, -- 438
			Color(196, 222, 240, 235) -- 438
		) -- 438
		fgGlow:drawDot( -- 439
			Vec2(cx + f * sw * 2.15, shY - 14), -- 439
			3.6, -- 439
			toColor(PALETTE.amber, 225) -- 439
		) -- 439
	end -- 439
end -- 263
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 445
	local cx = cam:sx(a.x) -- 454
	local by = cam:sy(a.y, a.depth) -- 455
	local depthEnabled = p.room.depth ~= nil -- 456
	local shadowY = depthEnabled and not a.onGround and cam:sy( -- 457
		self:supportGroundY(p, a), -- 457
		a.depth -- 457
	) or by -- 457
	local H = cam:len(a.h) -- 458
	local W = cam:len(a.w) -- 459
	local f = a.facing -- 460
	local speed = math.max( -- 461
		math.abs(a.vx), -- 461
		math.abs(a.depthSpeed) -- 461
	) -- 461
	local ____isControlled_15 -- 462
	if isControlled then -- 462
		____isControlled_15 = self.playerStride -- 462
	else -- 462
		____isControlled_15 = self.partnerStride -- 462
	end -- 462
	local gait = ____isControlled_15 -- 462
	local afraid = not isControlled and p.escort.fear > 0 -- 464
	local slot = "child_idle" -- 465
	local height = H -- 466
	local frame = 0 -- 467
	local step = math.floor(self.animTime * 10) -- 468
	local nearCover = __TS__ArraySome( -- 469
		p.room.solids, -- 469
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 469
			math.abs(a.x - solid.x), -- 472
			math.abs(a.x - solid.x - solid.w) -- 472
		) <= 30 end -- 472
	) -- 472
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 472
		slot = "child_knock" -- 475
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 475
		slot = "child_offer" -- 478
	elseif isControlled and p.ticks < self.throwUntil then -- 478
		slot = "child_throw" -- 480
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 480
		slot = "child_aim" -- 482
	elseif isControlled and p.gripping then -- 482
		slot = "child_pull" -- 484
		frame = self.cartMoving and step or 0 -- 485
	elseif afraid and p.escort.state == "frozen" then -- 485
		slot = "child_fear" -- 487
		height = height * 0.74 -- 488
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 488
		slot = "child_peek" -- 491
		height = height * 0.83 -- 492
	elseif a.crouch then -- 492
		slot = "child_crouch" -- 494
		frame = speed > 8 and step or 0 -- 495
	elseif (gait and gait.speed or 0) > 8 then -- 495
		slot = "child_run" -- 497
		frame = step -- 498
	end -- 498
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 500
	local pose = { -- 501
		facing = facing, -- 502
		frame = frame, -- 502
		layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 502
	} -- 502
	local running = (slot == "child_run" or slot == "child_idle") and a.onGround and gait ~= nil and gait.effort > 0 and assets:tryPlaceRun( -- 504
		"child", -- 506
		"actor_child", -- 506
		cx, -- 506
		by, -- 506
		W, -- 506
		height, -- 506
		gait.cycle, -- 506
		pose, -- 506
		gait.effort -- 506
	) -- 506
	if running or assets:tryPlace( -- 506
		slot, -- 507
		"actor_child", -- 507
		cx, -- 507
		by, -- 507
		W, -- 507
		height, -- 507
		pose -- 507
	) then -- 507
		fgDraw:drawEllipse( -- 508
			Vec2(cx, shadowY + 1), -- 508
			W * 0.48, -- 508
			3, -- 508
			Color(12, 11, 13, 125) -- 508
		) -- 508
		if afraid then -- 508
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 510
		end -- 510
		return -- 512
	end -- 512
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 515
	local x = cx + jitter -- 516
	local fullRef = a.crouch and H * 1.35 or H -- 518
	local cw = fullRef * 0.16 -- 519
	fgDraw:drawEllipse( -- 522
		Vec2(x, shadowY + 1), -- 522
		cw * 1.15, -- 522
		3.6, -- 522
		Color(4, 6, 10, 155) -- 522
	) -- 522
	local walking = speed > 6 and a.onGround -- 524
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 525
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 526
	local hipY = by + H * 0.3 -- 529
	local legSwing = stride * cw * 0.85 -- 530
	fgDraw:drawSegment( -- 531
		Vec2(x - 2, hipY), -- 531
		Vec2(x - legSwing, by + 2), -- 531
		math.max(2.6, cw * 0.22), -- 531
		Color(34, 30, 38, 255) -- 531
	) -- 531
	fgDraw:drawSegment( -- 532
		Vec2(x + 2, hipY), -- 532
		Vec2(x + legSwing, by + 2), -- 532
		math.max(2.8, cw * 0.24), -- 532
		Color(52, 46, 56, 255) -- 532
	) -- 532
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 535
	local cloakBotY = by + H * 0.2 -- 536
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 537
	fgDraw:drawPolygon( -- 538
		{ -- 538
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 539
			Vec2(x + cw * 0.92, cloakBotY), -- 540
			Vec2(x + cw * 0.62, cloakTopY), -- 541
			Vec2(x - cw * 0.68, cloakTopY) -- 542
		}, -- 542
		Color(214, 166, 94, 255), -- 543
		1.3, -- 543
		Color(252, 232, 192, 225) -- 543
	) -- 543
	fgDraw:drawPolygon( -- 544
		{ -- 544
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 545
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 546
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 547
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 548
		}, -- 548
		Color(148, 108, 56, 215) -- 549
	) -- 549
	fgDraw:drawSegment( -- 550
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 550
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 550
		1.8, -- 550
		toColor(PALETTE.amberCore, 200) -- 550
	) -- 550
	local scarfY = cloakTopY - 2 -- 553
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 554
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 555
	local sendX = x - f * cw * 1.65 + cloakDrag -- 556
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 557
	fgDraw:drawQuadraticBezier( -- 558
		Vec2(x - f * cw * 0.3, scarfY), -- 558
		Vec2(smidX, smidY), -- 558
		Vec2(sendX, sendY), -- 558
		2.8, -- 558
		toColor(PALETTE.amberCore, 235) -- 558
	) -- 558
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 561
	local headX = x + f * (a.crouch and 5 or 2) -- 562
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 563
	fgDraw:drawCircle( -- 564
		Vec2(headX, headY), -- 564
		headR, -- 564
		Color(240, 222, 198, 255) -- 564
	) -- 564
	fgDraw:drawPolygon( -- 566
		{ -- 566
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 567
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 568
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 569
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 570
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 571
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 572
		}, -- 572
		Color(156, 114, 62, 248), -- 573
		1.1, -- 573
		Color(244, 214, 162, 200) -- 573
	) -- 573
	fgGlow:drawDot( -- 575
		Vec2(headX + f * headR * 0.45, headY + 1), -- 575
		2.2, -- 575
		toColor(PALETTE.amberCore) -- 575
	) -- 575
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 578
	if hasCompass then -- 578
		local compX = x + f * cw * 0.65 -- 580
		local compY = by + H * 0.48 -- 581
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 582
		fgGlow:drawDot( -- 583
			Vec2(compX, compY), -- 583
			2.6, -- 583
			toColor(PALETTE.amberCore, 250) -- 583
		) -- 583
		fillRadialGlow( -- 584
			fgGlow, -- 584
			compX, -- 584
			compY, -- 584
			26 * glowPulse, -- 584
			26 * glowPulse, -- 584
			Color(248, 206, 120, 78 * glowPulse), -- 584
			Color(248, 180, 72, 0), -- 584
			14 -- 584
		) -- 584
	end -- 584
	if afraid then -- 584
		self:drawFear(fgGlow, p, x, by + H + 16) -- 588
	end -- 588
	if isControlled and walking and not a.crouch and speed > 100 then -- 588
		local r = 10 + self.animTime * 32 % 24 -- 593
		fgGlow:drawRing( -- 594
			Vec2(x, by + 3), -- 594
			r, -- 594
			r + 1.5, -- 594
			Color(0, 0, 0, 0), -- 594
			1.1, -- 594
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 594
		) -- 594
	end -- 594
end -- 445
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 598
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 599
	do -- 599
		local i = 0 -- 600
		while i < FEAR_MAX do -- 600
			local lit = i < p.escort.fear -- 601
			drawDiamond( -- 602
				fgGlow, -- 602
				x + (i - 1) * 13, -- 602
				y, -- 602
				4, -- 602
				5, -- 602
				toColor(lit and tint or PALETTE.steelDark, 215), -- 603
				1, -- 603
				toColor(tint, lit and 235 or 100) -- 603
			) -- 603
			i = i + 1 -- 600
		end -- 600
	end -- 600
end -- 598
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 607
	local x = cam:sx(e.x + f * 20) -- 608
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 609
	local dx = cam:sx(p.player.x) - x -- 610
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 611
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 612
	do -- 612
		local i = 0 -- 613
		while i < 8 do -- 613
			local a = length * i / 8 -- 614
			local b = length * (i + 1) / 8 -- 615
			fgGlow:drawSegment( -- 616
				Vec2(x + dx * a, y + dy * a), -- 616
				Vec2(x + dx * b, y + dy * b), -- 616
				1.3, -- 617
				Color(220, 120, 88, 210) -- 617
			) -- 617
			i = i + 2 -- 613
		end -- 613
	end -- 613
end -- 607
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 622
	local cx = cam:sx(e.x) -- 631
	local depth = e.depth or 0 -- 632
	local by = cam:sy(e.y, depth) -- 633
	local H = cam:len(e.h) -- 634
	local W = cam:len(e.w) -- 635
	local f = p.player.x >= e.x and 1 or -1 -- 636
	if e.kind == "target" then -- 636
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 640
		fgDraw:drawEllipse( -- 641
			Vec2(cx, by + 1), -- 641
			W * 0.56, -- 641
			3.6, -- 641
			Color(12, 11, 13, 140) -- 641
		) -- 641
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 642
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 643
		if assets:tryPlacePath( -- 643
			"assets/art/props_ming.clip|target_dummy", -- 644
			"actor_target_" .. tostring(index), -- 644
			cx, -- 644
			by, -- 644
			H * 0.82, -- 644
			H * 0.96, -- 644
			{ -- 644
				anchorX = 0.5, -- 645
				anchorY = 0, -- 646
				preserveAspect = true, -- 647
				angle = angle, -- 648
				color = tint, -- 649
				opacity = e.alive and 1 or 0.76, -- 650
				layer = targetLayer -- 651
			} -- 651
		) then -- 651
			return -- 653
		end -- 653
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 655
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 656
		fgDraw:drawSegment( -- 657
			Vec2( -- 657
				cx - cam:len(9), -- 657
				by -- 657
			), -- 657
			Vec2(cx + lean * 0.4, postTopY), -- 657
			math.max( -- 657
				2, -- 657
				cam:len(3.2) -- 657
			), -- 657
			Color(92, 64, 42, 255) -- 657
		) -- 657
		fgDraw:drawSegment( -- 658
			Vec2( -- 658
				cx + cam:len(9), -- 658
				by -- 658
			), -- 658
			Vec2(cx + lean * 0.4, postTopY), -- 658
			math.max( -- 658
				2, -- 658
				cam:len(3.2) -- 658
			), -- 658
			Color(76, 52, 34, 255) -- 658
		) -- 658
		local discX = cx + lean -- 659
		local discY = by + H * (e.alive and 0.56 or 0.3) -- 660
		local discR = math.max( -- 661
			7, -- 661
			cam:len(13) -- 661
		) -- 661
		local hitTint = e.hitT > 0 or not e.alive -- 662
		fgDraw:drawCircle( -- 663
			Vec2(discX, discY), -- 663
			discR, -- 663
			hitTint and Color(214, 152, 116, 245) or Color(196, 174, 134, 250) -- 663
		) -- 663
		fgDraw:drawRing( -- 664
			Vec2(discX, discY), -- 664
			discR * 0.62, -- 664
			discR * 0.76, -- 664
			Color(0, 0, 0, 0), -- 664
			1.4, -- 664
			Color(62, 46, 34, 230) -- 664
		) -- 664
		fgDraw:drawCircle( -- 665
			Vec2(discX, discY), -- 665
			discR * 0.3, -- 665
			toColor(PALETTE.rouge, hitTint and 255 or 220) -- 665
		) -- 665
		return -- 666
	end -- 666
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 669
	if e.alive and e.hitT <= 0 then -- 669
		local extraClip = "" -- 672
		local extraAnchorX = 0.5 -- 673
		local extraHeight = H * 0.96 -- 674
		local extraTint = Color(255, 255, 255, 255) -- 675
		if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 675
			extraClip = e.warnT > 0 and "enemy_shield_aim" or "enemy_shield_idle" -- 677
			extraAnchorX = e.warnT > 0 and 0.45 or 0.5 -- 678
			extraHeight = H * 0.94 -- 679
			if (e.shieldHp or 2) <= 1 then -- 679
				extraTint = Color(234, 198, 178, 255) -- 681
			end -- 681
		elseif e.kind == "breaker" then -- 681
			local swing = (e.swingT or 0) > 0 or e.warnT > 0 -- 684
			extraClip = swing and "enemy_breaker_aim" or "enemy_breaker_idle" -- 685
			extraAnchorX = swing and 0.52 or 0.38 -- 686
			extraHeight = H * (swing and 0.98 or 0.94) -- 687
		elseif e.kind == "leader" then -- 687
			extraClip = e.warnT > 0 and "enemy_leader_aim" or "enemy_leader_idle" -- 689
			extraAnchorX = e.warnT > 0 and 0.38 or 0.44 -- 690
			extraHeight = H * 1 -- 691
		end -- 691
		if extraClip ~= "" and assets:tryPlacePath( -- 691
			"assets/art/actors_extra.clip|" .. extraClip, -- 694
			"actor_enemy_" .. tostring(index), -- 695
			cx, -- 696
			by, -- 697
			W * 1.8, -- 698
			extraHeight, -- 699
			{ -- 700
				anchorX = extraAnchorX, -- 701
				anchorY = 0, -- 702
				preserveAspect = true, -- 703
				facing = f, -- 704
				color = extraTint, -- 705
				layer = enemyLayer -- 706
			} -- 706
		) then -- 706
			fgDraw:drawEllipse( -- 709
				Vec2(cx, by + 1), -- 709
				W * 0.58, -- 709
				3.8, -- 709
				Color(12, 11, 13, 145) -- 709
			) -- 709
			if e.kind == "breaker" and (e.swingT or 0) > 0 then -- 709
				fgGlow:drawArc( -- 711
					Vec2( -- 711
						cx + f * cam:len(10), -- 711
						by + H * 0.56 -- 711
					), -- 711
					cam:len(18), -- 711
					f > 0 and -40 or 140, -- 711
					f > 0 and 50 or 230, -- 711
					1.8, -- 711
					toColor(PALETTE.rouge, 195) -- 711
				) -- 711
			end -- 711
			if e.warnT > 0 then -- 711
				self:drawEnemyWarning( -- 714
					fgGlow, -- 714
					e, -- 714
					p, -- 714
					cam, -- 714
					f -- 714
				) -- 714
			end -- 714
			return -- 716
		end -- 716
	end -- 716
	local slot = "enemy_idle" -- 720
	if not e.alive then -- 720
		slot = "enemy_down" -- 722
	elseif e.hitT > 0 then -- 722
		slot = "enemy_hit" -- 724
	elseif e.warnT > 0 then -- 724
		slot = "enemy_aim" -- 726
	end -- 726
	local height = e.alive and H or H * 0.24 -- 728
	if assets:tryPlace( -- 728
		slot, -- 729
		"actor_enemy_" .. tostring(index), -- 729
		cx, -- 729
		by, -- 729
		W, -- 729
		height, -- 729
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 729
	) then -- 729
		if e.alive then -- 729
			self:drawEnemyArchetypeGear( -- 733
				fgDraw, -- 733
				fgGlow, -- 733
				assets, -- 733
				e, -- 733
				index, -- 733
				cx, -- 733
				by, -- 733
				H, -- 733
				f, -- 733
				cam, -- 733
				enemyLayer + 1 -- 733
			) -- 733
			if e.warnT > 0 then -- 733
				self:drawEnemyWarning( -- 735
					fgGlow, -- 735
					e, -- 735
					p, -- 735
					cam, -- 735
					f -- 735
				) -- 735
			end -- 735
		end -- 735
		return -- 738
	end -- 738
	if not e.alive then -- 738
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 742
		fgDraw:drawPolygon( -- 743
			{ -- 743
				Vec2(cx - H * 0.3, by), -- 744
				Vec2(cx + H * 0.28, by), -- 745
				Vec2(cx + H * 0.2, by + H * 0.14), -- 746
				Vec2(cx - H * 0.24, by + H * 0.11) -- 747
			}, -- 747
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 748
		) -- 748
		if flash > 0 then -- 748
			fillRadialGlow( -- 750
				fgGlow, -- 750
				cx, -- 750
				by + 12, -- 750
				34 * flash, -- 750
				18 * flash, -- 750
				toColor(PALETTE.crimson, 180 * flash), -- 750
				Color(255, 48, 82, 0), -- 750
				12 -- 750
			) -- 750
		end -- 750
		return -- 752
	end -- 752
	local sw = H * 0.112 -- 755
	fgDraw:drawEllipse( -- 756
		Vec2(cx, by + 1), -- 756
		sw * 1.9, -- 756
		4, -- 756
		Color(4, 6, 10, 165) -- 756
	) -- 756
	local hipY = by + H * 0.44 -- 759
	local kneeY = by + H * 0.23 -- 760
	local shY = by + H * 0.79 -- 761
	fgDraw:drawSegment( -- 762
		Vec2(cx - 5, hipY), -- 762
		Vec2(cx - 7, kneeY), -- 762
		H * 0.044, -- 762
		Color(20, 16, 26, 255) -- 762
	) -- 762
	fgDraw:drawSegment( -- 763
		Vec2(cx - 7, kneeY), -- 763
		Vec2(cx - 8, by + 2), -- 763
		H * 0.038, -- 763
		Color(20, 16, 26, 255) -- 763
	) -- 763
	fgDraw:drawSegment( -- 764
		Vec2(cx + 5, hipY), -- 764
		Vec2(cx + 7, kneeY), -- 764
		H * 0.046, -- 764
		Color(28, 22, 36, 255) -- 764
	) -- 764
	fgDraw:drawSegment( -- 765
		Vec2(cx + 7, kneeY), -- 765
		Vec2(cx + 8, by + 2), -- 765
		H * 0.04, -- 765
		Color(28, 22, 36, 255) -- 765
	) -- 765
	fgDraw:drawPolygon( -- 767
		{ -- 767
			Vec2(cx - sw * 0.68, hipY), -- 768
			Vec2(cx + sw * 0.68, hipY), -- 769
			Vec2(cx + sw * 1.12, shY), -- 770
			Vec2(cx - sw * 1.12, shY) -- 771
		}, -- 771
		Color(111, 68, 55, 255), -- 772
		1.3, -- 772
		Color(143, 101, 66, 220) -- 772
	) -- 772
	fgDraw:drawPolygon( -- 773
		{ -- 773
			Vec2(cx - sw * 1.26, shY - 6), -- 774
			Vec2(cx + sw * 1.26, shY - 6), -- 775
			Vec2(cx + sw * 0.96, shY + 5), -- 776
			Vec2(cx - sw * 0.96, shY + 5) -- 777
		}, -- 777
		Color(98, 82, 62, 255) -- 778
	) -- 778
	local headR = H * 0.086 -- 780
	local headY = shY + headR * 1.32 -- 781
	fgDraw:drawCircle( -- 782
		Vec2(cx, headY), -- 782
		headR * 0.82, -- 782
		Color(187, 142, 103, 255) -- 782
	) -- 782
	fgDraw:drawPolygon( -- 783
		{ -- 783
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 784
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 785
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 786
		}, -- 786
		Color(136, 105, 65, 255), -- 787
		1.1, -- 787
		Color(177, 145, 91, 220) -- 787
	) -- 787
	local gunX = cx + f * H * 0.34 -- 789
	local gunY = by + H * 0.69 -- 790
	fgDraw:drawSegment( -- 791
		Vec2(cx - f * 6, gunY - 2), -- 791
		Vec2(gunX, gunY), -- 791
		2.8, -- 791
		Color(118, 87, 61, 255) -- 791
	) -- 791
	self:drawEnemyArchetypeGear( -- 792
		fgDraw, -- 792
		fgGlow, -- 792
		assets, -- 792
		e, -- 792
		index, -- 792
		cx, -- 792
		by, -- 792
		H, -- 792
		f, -- 792
		cam, -- 792
		enemyLayer + 1 -- 792
	) -- 792
	if e.warnT > 0 then -- 792
		self:drawEnemyWarning( -- 794
			fgGlow, -- 794
			e, -- 794
			p, -- 794
			cam, -- 794
			f -- 794
		) -- 794
	end -- 794
end -- 622
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 799
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 799
		local shX = cx + f * cam:len(13) -- 813
		local cracked = (e.shieldHp or 2) <= 1 -- 814
		if not assets:tryPlace( -- 814
			"fe_gear_rattan_shield", -- 815
			"enemy_shield_" .. tostring(index), -- 815
			shX, -- 815
			by + H * 0.44, -- 815
			cam:len(22), -- 815
			H * 0.64, -- 815
			{ -- 815
				facing = f, -- 816
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 817
				layer = layer -- 818
			} -- 818
		) then -- 818
			local shW = math.max( -- 820
				5, -- 820
				cam:len(8) -- 820
			) -- 820
			fgDraw:drawRect( -- 821
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 821
				Color(96, 66, 42, 250), -- 821
				1.3, -- 821
				Color(168, 174, 180, 230) -- 821
			) -- 821
		end -- 821
		if cracked then -- 821
			fgDraw:drawSegment( -- 824
				Vec2( -- 824
					shX - cam:len(4), -- 824
					by + H * 0.3 -- 824
				), -- 824
				Vec2( -- 824
					shX + cam:len(4), -- 824
					by + H * 0.56 -- 824
				), -- 824
				1.4, -- 824
				Color(24, 18, 16, 235) -- 824
			) -- 824
		end -- 824
	elseif e.kind == "breaker" then -- 824
		local swing = (e.swingT or 0) > 0 -- 827
		local handleX0 = cx - f * cam:len(4) -- 828
		local handleY0 = by + H * 0.44 -- 829
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 830
		local tipY = by + H * (swing and 0.46 or 0.78) -- 831
		fgDraw:drawSegment( -- 832
			Vec2(handleX0, handleY0), -- 832
			Vec2(tipX, tipY), -- 832
			math.max( -- 832
				2.2, -- 832
				cam:len(3) -- 832
			), -- 832
			Color(98, 66, 44, 255) -- 832
		) -- 832
		fgDraw:drawPolygon( -- 833
			{ -- 833
				Vec2( -- 834
					tipX - f * cam:len(3), -- 834
					tipY - cam:len(4) -- 834
				), -- 834
				Vec2( -- 835
					tipX + f * cam:len(9), -- 835
					tipY - cam:len(1) -- 835
				), -- 835
				Vec2( -- 836
					tipX + f * cam:len(7), -- 836
					tipY + cam:len(9) -- 836
				), -- 836
				Vec2( -- 837
					tipX - f * cam:len(2), -- 837
					tipY + cam:len(6) -- 837
				) -- 837
			}, -- 837
			Color(148, 154, 162, 250), -- 838
			1, -- 838
			Color(224, 228, 232, 220) -- 838
		) -- 838
		if swing then -- 838
			fgGlow:drawArc( -- 840
				Vec2( -- 840
					cx + f * cam:len(10), -- 840
					by + H * 0.56 -- 840
				), -- 840
				cam:len(18), -- 840
				f > 0 and -40 or 140, -- 840
				f > 0 and 50 or 230, -- 840
				1.8, -- 840
				toColor(PALETTE.rouge, 195) -- 840
			) -- 840
		end -- 840
	elseif e.kind == "leader" then -- 840
		local topY = by + H * 1.02 -- 844
		fgDraw:drawSegment( -- 845
			Vec2(cx, topY), -- 845
			Vec2( -- 845
				cx - f * cam:len(10), -- 845
				topY + cam:len(9) -- 845
			), -- 845
			2.2, -- 845
			toColor(PALETTE.rouge, 240) -- 845
		) -- 845
		fgDraw:drawDot( -- 846
			Vec2( -- 846
				cx - f * cam:len(10), -- 846
				topY + cam:len(9) -- 846
			), -- 846
			2.6, -- 846
			toColor(PALETTE.crimsonCore, 235) -- 846
		) -- 846
	end -- 846
end -- 799
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 851
	local s = p.room.scavenger -- 858
	if s == nil then -- 858
		return -- 860
	end -- 860
	local cx = cam:sx(p.scavX) -- 862
	local by = cam:sy(s.y) -- 863
	local H = cam:len(s.h) -- 864
	local W = cam:len(26) -- 865
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 866
	local alert = p.scavChase or p.scavSee > 0 -- 869
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 870
	local eyeY = by + H * 0.8 -- 871
	local coneLen = cam:len(alert and 155 or 115) -- 872
	fgGlow:drawVertices({ -- 873
		{ -- 874
			Vec2(cx + f * 6, eyeY), -- 874
			toColor(coneCol, alert and 78 or 34) -- 874
		}, -- 874
		{ -- 875
			Vec2(cx + f * coneLen, by + H * 1.05), -- 875
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 875
		}, -- 875
		{ -- 876
			Vec2(cx + f * coneLen, by + 4), -- 876
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 876
		} -- 876
	}) -- 876
	local frame = 0 -- 879
	if p.scavState == "turn" then -- 879
		frame = 2 -- 881
	elseif p.scavState == "chase" then -- 881
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 883
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 883
		frame = math.floor(self.animTime * 8) % 2 -- 885
	end -- 885
	if assets:tryPlace( -- 885
		"scavenger", -- 887
		"actor_scav", -- 887
		cx, -- 887
		by, -- 887
		W, -- 887
		H, -- 887
		{facing = f, frame = frame, layer = 3} -- 887
	) then -- 887
		return -- 888
	end -- 888
	fgDraw:drawEllipse( -- 891
		Vec2(cx, by + 1), -- 891
		W * 0.62, -- 891
		4, -- 891
		Color(4, 6, 10, 155) -- 891
	) -- 891
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 892
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 893
	fgDraw:drawSegment( -- 895
		Vec2(cx - 4, by + H * 0.4), -- 895
		Vec2(cx - stride, by + 2), -- 895
		W * 0.16, -- 895
		Color(32, 30, 28, 255) -- 895
	) -- 895
	fgDraw:drawSegment( -- 896
		Vec2(cx + 4, by + H * 0.4), -- 896
		Vec2(cx + stride, by + 2), -- 896
		W * 0.16, -- 896
		Color(44, 40, 36, 255) -- 896
	) -- 896
	fgDraw:drawPolygon( -- 898
		{ -- 898
			Vec2(cx - W * 0.45, by + H * 0.25), -- 899
			Vec2(cx + W * 0.42, by + H * 0.25), -- 900
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 901
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 902
		}, -- 902
		Color(56, 52, 46, 255), -- 903
		1.2, -- 903
		Color(128, 118, 100, 180) -- 903
	) -- 903
	local headX = cx + f * 5 -- 905
	local headY = by + H * 0.88 -- 906
	fgDraw:drawCircle( -- 907
		Vec2(headX, headY), -- 907
		W * 0.3, -- 907
		Color(42, 38, 34, 255) -- 907
	) -- 907
	fgGlow:drawDot( -- 908
		Vec2(headX + f * 6, headY), -- 908
		3, -- 908
		toColor(coneCol, 245) -- 908
	) -- 908
	local indY = by + H + 18 -- 911
	if p.scavChase then -- 911
		drawDiamond( -- 913
			fgGlow, -- 913
			cx, -- 913
			indY, -- 913
			9, -- 913
			12, -- 913
			toColor(PALETTE.crimson, 240), -- 913
			1.5, -- 913
			toColor(PALETTE.crimsonCore) -- 913
		) -- 913
	elseif p.scavSee > 0 then -- 913
		local frac = math.min(1, p.scavSee / 24) -- 915
		fgGlow:drawArc( -- 916
			Vec2(cx, indY), -- 916
			11, -- 916
			90, -- 916
			90 - 360 * frac, -- 916
			2.4, -- 916
			toColor(PALETTE.crimson, 235) -- 916
		) -- 916
		fgGlow:drawDot( -- 917
			Vec2(cx, indY), -- 917
			3, -- 917
			toColor(PALETTE.amber) -- 917
		) -- 917
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 917
		drawDiamond( -- 919
			fgGlow, -- 919
			cx, -- 919
			indY, -- 919
			6, -- 919
			8, -- 919
			toColor(PALETTE.amber, 220) -- 919
		) -- 919
	end -- 919
end -- 851
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 924
	local cx = cam:sx(p.dogX) -- 931
	local by = cam:sy(0) -- 932
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 933
	local W = cam:len(34) -- 934
	local H = cam:len(28) -- 935
	local frame = 0 -- 937
	if p.dogState == "ear" then -- 937
		frame = 1 -- 939
	elseif p.dogState == "sniff" then -- 939
		frame = 3 -- 941
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 941
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 943
	end -- 943
	if assets:tryPlace( -- 943
		"dog", -- 945
		"actor_dog", -- 945
		cx, -- 945
		by, -- 945
		W, -- 945
		H, -- 945
		{facing = f, frame = frame, layer = 3} -- 945
	) then -- 945
		return -- 946
	end -- 946
	fgDraw:drawEllipse( -- 949
		Vec2(cx, by + 1), -- 949
		W * 0.56, -- 949
		3.5, -- 949
		Color(4, 8, 10, 155) -- 949
	) -- 949
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 950
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 951
	fgDraw:drawSegment( -- 954
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 954
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 954
		2.8, -- 954
		Color(26, 30, 34, 255) -- 954
	) -- 954
	fgDraw:drawSegment( -- 955
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 955
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 955
		2.8, -- 955
		Color(36, 40, 44, 255) -- 955
	) -- 955
	fgDraw:drawPolygon( -- 957
		{ -- 957
			Vec2(cx - W * 0.42, by + H * 0.36), -- 958
			Vec2(cx + W * 0.38, by + H * 0.42), -- 959
			Vec2(cx + W * 0.34, by + H * 0.78), -- 960
			Vec2(cx - W * 0.38, by + H * 0.72) -- 961
		}, -- 961
		Color(38, 42, 48, 255), -- 962
		1.2, -- 962
		Color(102, 118, 126, 175) -- 962
	) -- 962
	local hx = cx + f * W * 0.42 -- 963
	local hy = by + H * 0.84 -- 964
	fgDraw:drawPolygon( -- 965
		{ -- 965
			Vec2(hx - f * 8, hy - 6), -- 966
			Vec2(hx + f * 12, hy - 2), -- 967
			Vec2(hx + f * 4, hy + 8), -- 968
			Vec2(hx - f * 6, hy + 14) -- 969
		}, -- 969
		Color(44, 48, 54, 255) -- 970
	) -- 970
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 972
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 973
	fgGlow:drawDot( -- 974
		Vec2(hx + f * 4, hy + 2), -- 974
		2.8, -- 974
		toColor(eyeCol, 250) -- 974
	) -- 974
	fillRadialGlow( -- 975
		fgGlow, -- 975
		hx + f * 4, -- 975
		hy + 2, -- 975
		16, -- 975
		16, -- 975
		toColor(eyeCol, alert and 135 or 70), -- 975
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 975
		12 -- 975
	) -- 975
	if alert then -- 975
		local r = 12 + self.animTime * 42 % 24 -- 978
		fgGlow:drawArc( -- 979
			Vec2(hx, hy + 12), -- 979
			r, -- 979
			35, -- 979
			145, -- 979
			1.8, -- 979
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 979
		) -- 979
	end -- 979
end -- 924
return ____exports -- 924