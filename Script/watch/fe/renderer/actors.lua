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
local function strideAt(actor) -- 28
	return { -- 29
		actor = actor, -- 29
		x = actor.x, -- 29
		depth = actor.depth, -- 29
		speed = 0, -- 29
		cycle = 0 -- 29
	} -- 29
end -- 28
local function advanceStride(stride, steps, dt) -- 32
	local a = stride.actor -- 33
	if steps > 0 then -- 33
		local dx = a.x - stride.x -- 35
		local depth = a.depth - stride.depth -- 36
		local speed = math.sqrt(dx * dx + depth * depth) / (steps * STEP) -- 37
		stride.speed = speed <= 380 and speed or 0 -- 38
		stride.x = a.x -- 39
		stride.depth = a.depth -- 40
	end -- 40
	if a.onGround and not a.crouch and not a.covered and a.rollT <= 0 and stride.speed > 8 then -- 40
		local strideLength = a.h * (a.w <= 28 and 1.4 or 1.32) -- 43
		stride.cycle = (stride.cycle + stride.speed * dt / strideLength) % 1 -- 44
	end -- 44
end -- 32
local DUST_LIFE = 0.23 -- 48
____exports.ActorsRenderer = __TS__Class() -- 50
local ActorsRenderer = ____exports.ActorsRenderer -- 50
ActorsRenderer.name = "ActorsRenderer" -- 50
function ActorsRenderer.prototype.____constructor(self) -- 50
	self.slideDust = {} -- 51
	self.dustCooldown = 0 -- 52
	self.slideDuration = 0 -- 53
	self.strideTick = 0 -- 54
	self.animTime = 0 -- 57
	self.previousHp = 3 -- 58
	self.previousAxle = 0 -- 59
	self.cartMoving = false -- 60
	self.previousBottle = false -- 61
	self.hitUntil = -1 -- 63
	self.throwUntil = -1 -- 64
	self.shotUntil = -1 -- 65
end -- 50
function ActorsRenderer.prototype.reset(self, p) -- 67
	self.slideDust = {} -- 68
	self.dustCooldown = 0 -- 69
	self.slideDuration = 0 -- 70
	self.strideTick = p.ticks -- 71
	self.playerStride = strideAt(p.player) -- 72
	self.partnerStride = strideAt(p.partner) -- 73
	self.animTime = 0 -- 74
	self.previousHp = p.hp -- 75
	self.previousAxle = p.cartAxle -- 76
	self.cartMoving = false -- 77
	self.previousBottle = p.hasBottle -- 78
	self.previousTrace = p.trace -- 79
	self.hitUntil = -1 -- 80
	self.throwUntil = -1 -- 81
	self.shotUntil = -1 -- 82
end -- 67
function ActorsRenderer.prototype.update(self, dt, p) -- 86
	self.animTime = self.animTime + dt -- 87
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 87
		self.hitUntil = p.ticks + 14 -- 89
	end -- 89
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 89
		self.throwUntil = p.ticks + 12 -- 92
	end -- 92
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 92
		self.shotUntil = p.ticks + 7 -- 95
	end -- 95
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 97
	self.previousAxle = p.cartAxle -- 98
	self.previousHp = p.hp -- 99
	self.previousBottle = p.hasBottle -- 100
	self.previousTrace = p.trace -- 101
	local ____opt_0 = self.playerStride -- 101
	if (____opt_0 and ____opt_0.actor) ~= p.player then -- 101
		self.playerStride = strideAt(p.player) -- 103
	end -- 103
	local ____opt_2 = self.partnerStride -- 103
	if (____opt_2 and ____opt_2.actor) ~= p.partner then -- 103
		self.partnerStride = strideAt(p.partner) -- 106
	end -- 106
	local steps = math.max(0, p.ticks - self.strideTick) -- 108
	advanceStride(self.playerStride, steps, dt) -- 109
	advanceStride(self.partnerStride, steps, dt) -- 110
	self.strideTick = p.ticks -- 111
	self:updateSlideDust(dt, p, self.playerStride.speed) -- 112
end -- 86
function ActorsRenderer.prototype.slidePhase(self, a) -- 115
	return self.slideDuration > 0 and 1 - a.rollT / self.slideDuration or 0 -- 116
end -- 115
function ActorsRenderer.prototype.updateSlideDust(self, dt, p, speed) -- 119
	local a = p.player -- 120
	if not p.childMode and a.rollT > 0 then -- 120
		self.slideDuration = math.max(self.slideDuration, a.rollT) -- 122
		local progress = self:slidePhase(a) -- 123
		self.dustCooldown = self.dustCooldown - dt -- 124
		if a.onGround and speed > 8 and progress >= 0.16 and progress < 0.77 and self.dustCooldown <= 0 then -- 124
			local ____self_slideDust_4 = self.slideDust -- 124
			____self_slideDust_4[#____self_slideDust_4 + 1] = {x = a.x + a.facing * a.h * 0.34, y = a.y + a.depth, facing = a.facing, life = DUST_LIFE} -- 126
			self.dustCooldown = 0.038 -- 132
		end -- 132
	else -- 132
		self.slideDuration = 0 -- 135
		self.dustCooldown = 0 -- 136
	end -- 136
	local write = 0 -- 138
	for ____, dust in ipairs(self.slideDust) do -- 139
		dust.life = dust.life - dt -- 140
		if dust.life > 0 then -- 140
			self.slideDust[write + 1] = dust -- 142
			write = write + 1 -- 143
		end -- 143
	end -- 143
	__TS__ArraySetLength(self.slideDust, write) -- 143
end -- 119
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 149
	if suppressPartner == nil then -- 149
		suppressPartner = false -- 155
	end -- 155
	self:drawSlideDust(fgGlow, cam) -- 157
	local i = 0 -- 160
	do -- 160
		i = 0 -- 161
		while i < #p.enemies do -- 161
			self:drawEnemy( -- 162
				fgDraw, -- 162
				fgGlow, -- 162
				assets, -- 162
				p.enemies[i + 1], -- 162
				i, -- 162
				p, -- 162
				cam -- 162
			) -- 162
			i = i + 1 -- 161
		end -- 161
	end -- 161
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 161
		self:drawScavenger( -- 167
			fgDraw, -- 167
			fgGlow, -- 167
			assets, -- 167
			p, -- 167
			cam -- 167
		) -- 167
	end -- 167
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 167
		self:drawDog( -- 172
			fgDraw, -- 172
			fgGlow, -- 172
			assets, -- 172
			p, -- 172
			cam -- 172
		) -- 172
	end -- 172
	if p.partner.alive and not suppressPartner then -- 172
		local partnerIsChild = p.partner.w <= 28 -- 177
		if partnerIsChild then -- 177
			self:drawXiaoman( -- 179
				fgDraw, -- 179
				fgGlow, -- 179
				assets, -- 179
				p.partner, -- 179
				p, -- 179
				cam, -- 179
				false -- 179
			) -- 179
		else -- 179
			self:drawZhouShu( -- 181
				fgDraw, -- 181
				fgGlow, -- 181
				assets, -- 181
				p.partner, -- 181
				p, -- 181
				cam, -- 181
				false -- 181
			) -- 181
		end -- 181
	end -- 181
	if p.player.alive then -- 181
		if p.childMode then -- 181
			self:drawXiaoman( -- 188
				fgDraw, -- 188
				fgGlow, -- 188
				assets, -- 188
				p.player, -- 188
				p, -- 188
				cam, -- 188
				true -- 188
			) -- 188
		else -- 188
			self:drawZhouShu( -- 190
				fgDraw, -- 190
				fgGlow, -- 190
				assets, -- 190
				p.player, -- 190
				p, -- 190
				cam, -- 190
				true -- 190
			) -- 190
		end -- 190
	end -- 190
end -- 149
function ActorsRenderer.prototype.drawSlideDust(self, draw, cam) -- 195
	for ____, dust in ipairs(self.slideDust) do -- 196
		local alpha = dust.life / DUST_LIFE -- 197
		local spread = 1 - alpha -- 198
		local x = cam:sx(dust.x - dust.facing * spread * 17) -- 199
		local y = cam:sy(dust.y + 1.5 + spread * 2) -- 200
		draw:drawEllipse( -- 201
			Vec2(x, y), -- 201
			cam:len(5 + spread * 7), -- 201
			cam:len(1.5 + spread * 2), -- 201
			Color(166, 147, 124, 170 * alpha) -- 202
		) -- 202
		draw:drawDot( -- 203
			Vec2( -- 203
				x - dust.facing * cam:len(3), -- 203
				y + cam:len(4) -- 203
			), -- 203
			cam:len(1.1), -- 204
			Color(195, 174, 148, 135 * alpha) -- 204
		) -- 204
	end -- 204
end -- 195
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 209
	local cx = cam:sx(a.x) -- 218
	local by = cam:sy(a.y, a.depth) -- 219
	local depthEnabled = p.room.depth ~= nil -- 220
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 221
	local H = cam:len(a.h) -- 222
	local W = cam:len(a.w) -- 223
	local f = a.facing -- 224
	local speed = math.max( -- 225
		math.abs(a.vx), -- 225
		math.abs(a.depthSpeed) -- 225
	) -- 225
	local slot = "soldier_idle" -- 227
	local height = H -- 228
	local frame = 0 -- 229
	local facing = f -- 230
	local step = math.floor(self.animTime * 10) -- 231
	local ____isControlled_5 -- 232
	if isControlled then -- 232
		____isControlled_5 = self.playerStride -- 232
	else -- 232
		____isControlled_5 = self.partnerStride -- 232
	end -- 232
	local gait = ____isControlled_5 -- 232
	if isControlled and p.ticks < self.hitUntil then -- 232
		slot = "soldier_hit" -- 234
	elseif a.rollT > 0 then -- 234
		slot = "soldier_slide" -- 236
		local progress = self:slidePhase(a) -- 237
		frame = progress < 0.16 and 0 or (progress < 0.64 and 1 or (progress < 0.82 and 2 or 3)) -- 238
	elseif p.phase == "prologue-give" then -- 238
		slot = "soldier_offer" -- 240
		height = height * 0.75 -- 241
		facing = p.partner.x >= a.x and 1 or -1 -- 242
	elseif isControlled and p.gripping then -- 242
		slot = "soldier_push" -- 244
		frame = self.cartMoving and step or 0 -- 245
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 246
		height = height * 0.91 -- 247
	elseif isControlled and p.escort.state == "calming" then -- 247
		slot = "soldier_knock" -- 249
		local calm = p.escort.calmTick -- 250
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 251
		height = height * 0.76 -- 252
	else -- 252
		local ____temp_8 = p.phase == "gate-send" -- 253
		if ____temp_8 then -- 253
			local ____opt_6 = p.room.story -- 253
			____temp_8 = (____opt_6 and ____opt_6.gate) ~= nil -- 253
		end -- 253
		if ____temp_8 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 253
			slot = "soldier_hold" -- 255
			height = height * 1.11 -- 256
		elseif isControlled and p.ticks < self.shotUntil then -- 256
			local running = speed > 8 -- 258
			slot = running and "soldier_fire_move" or "soldier_fire" -- 259
			frame = running and step or 0 -- 260
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 261
		elseif a.covered or isControlled and p.coverHug then -- 261
			slot = "soldier_cover" -- 263
			height = height * 0.77 -- 264
		elseif (gait and gait.speed or 0) > 8 then -- 264
			slot = "soldier_run" -- 266
			frame = step -- 267
		end -- 267
	end -- 267
	local pose = { -- 269
		facing = facing, -- 270
		frame = frame, -- 270
		layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 270
	} -- 270
	local running = slot == "soldier_run" and a.onGround and gait ~= nil and assets:tryPlaceRun( -- 272
		"soldier", -- 273
		"actor_soldier", -- 273
		cx, -- 273
		by, -- 273
		W, -- 273
		height, -- 273
		gait.cycle, -- 273
		pose -- 273
	) -- 273
	if running or assets:tryPlace( -- 273
		slot, -- 274
		"actor_soldier", -- 274
		cx, -- 274
		by, -- 274
		W, -- 274
		height, -- 274
		pose -- 274
	) then -- 274
		fgDraw:drawEllipse( -- 275
			Vec2(cx, shadowY + 1), -- 275
			W * 0.54, -- 275
			4, -- 275
			Color(12, 11, 13, 145) -- 275
		) -- 275
		return -- 276
	end -- 276
	fgDraw:drawEllipse( -- 280
		Vec2(cx, shadowY + 1), -- 280
		H * 0.24, -- 280
		4.5, -- 280
		Color(3, 5, 10, 175) -- 280
	) -- 280
	local walking = speed > 10 and a.onGround -- 282
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 283
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 284
	local calming = not p.childMode and p.escort.state == "calming" -- 285
	local rolling = a.rollT > 0 -- 286
	local crouching = a.covered or calming or rolling -- 287
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 290
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 291
	local sw = H * 0.115 -- 292
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 295
	local kneeY = by + bodyH * 0.23 -- 296
	local stepX = stride * H * 0.15 -- 297
	local legDark = Color(14, 21, 34, 255) -- 298
	local legFront = Color(26, 38, 58, 255) -- 299
	local bkX = cx - f * 4 - stepX * 0.5 -- 301
	local bfX = cx - f * 8 - stepX -- 302
	fgDraw:drawSegment( -- 303
		Vec2(cx - f * 3, hipY), -- 303
		Vec2(bkX, kneeY), -- 303
		H * 0.044, -- 303
		legDark -- 303
	) -- 303
	fgDraw:drawSegment( -- 304
		Vec2(bkX, kneeY), -- 304
		Vec2(bfX, by + 3), -- 304
		H * 0.038, -- 304
		legDark -- 304
	) -- 304
	local fkX = cx + f * 6 + stepX * 0.55 -- 306
	local ffX = cx + f * 7 + stepX -- 307
	fgDraw:drawSegment( -- 308
		Vec2(cx + f * 3, hipY), -- 308
		Vec2(fkX, kneeY), -- 308
		H * 0.048, -- 308
		legFront -- 308
	) -- 308
	fgDraw:drawSegment( -- 309
		Vec2(fkX, kneeY), -- 309
		Vec2(ffX, by + 3), -- 309
		H * 0.042, -- 309
		legFront -- 309
	) -- 309
	fgDraw:drawSegment( -- 311
		Vec2(ffX - f * 2, by + 3), -- 311
		Vec2(ffX + f * 9, by + 3), -- 311
		3.4, -- 311
		Color(42, 60, 86, 255) -- 311
	) -- 311
	local shY = by + bodyH * 0.8 + bob -- 314
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 315
	fgDraw:drawPolygon( -- 316
		{ -- 316
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 317
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 318
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 319
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 320
		}, -- 320
		Color(16, 26, 42, 248), -- 321
		1.2, -- 321
		Color(64, 118, 164, 195) -- 321
	) -- 321
	fgDraw:drawPolygon( -- 324
		{ -- 324
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 325
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 326
			Vec2(cx + sw * 1.05 + lean, shY), -- 327
			Vec2(cx - sw * 0.98 + lean, shY) -- 328
		}, -- 328
		Color(24, 38, 60, 255), -- 329
		1.3, -- 329
		toColor(PALETTE.rimSilver, 190) -- 329
	) -- 329
	fgDraw:drawSegment( -- 331
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 332
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 333
		2.4, -- 334
		Color(173, 155, 125, 225) -- 335
	) -- 335
	fgDraw:drawPolygon( -- 337
		{ -- 337
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 338
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 339
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 340
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 341
		}, -- 341
		Color(99, 105, 103, 248) -- 342
	) -- 342
	local headR = H * 0.088 -- 345
	local headX = cx + lean + f * 3 -- 346
	local headY = shY + headR * 1.35 -- 347
	fgDraw:drawCircle( -- 348
		Vec2(headX, headY - headR * 0.12), -- 348
		headR * 0.86, -- 348
		Color(181, 139, 106, 255) -- 348
	) -- 348
	fgDraw:drawEllipse( -- 349
		Vec2(headX, headY + headR * 0.5), -- 349
		headR * 1.12, -- 349
		headR * 0.72, -- 349
		Color(66, 73, 76, 255) -- 349
	) -- 349
	fgDraw:drawSegment( -- 350
		Vec2(headX - headR, headY + 1), -- 350
		Vec2(headX + headR, headY + 1), -- 350
		1.6, -- 351
		Color(97, 103, 101, 255) -- 351
	) -- 351
	fgDraw:drawSegment( -- 352
		Vec2(headX, headY + headR), -- 352
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 352
		1.6, -- 353
		Color(177, 78, 51, 255) -- 353
	) -- 353
	if isControlled and not calming and not rolling and not p.gripping then -- 353
		local gunPivotX = cx + lean + f * sw * 0.35 -- 357
		local gunPivotY = shY - bodyH * 0.1 -- 358
		local aimDx = f -- 359
		local aimDy = 0 -- 360
		if p.aimX > 0 or p.aimY > 0 then -- 360
			aimDx = p.aimX - gunPivotX -- 362
			aimDy = p.aimY - gunPivotY -- 363
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 364
			if dLen > 4 then -- 364
				aimDx = aimDx / dLen -- 366
				aimDy = aimDy / dLen -- 367
			end -- 367
		end -- 367
		local barrelLen = H * 0.34 -- 370
		local tipX = gunPivotX + aimDx * barrelLen -- 371
		local tipY = gunPivotY + aimDy * barrelLen -- 372
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 373
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 374
		fgDraw:drawSegment( -- 376
			Vec2(cx + lean, shY - 5), -- 376
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 376
			3.6, -- 376
			Color(26, 40, 62, 255) -- 376
		) -- 376
		fgDraw:drawSegment( -- 377
			Vec2(stockX, stockY), -- 377
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 377
			3.8, -- 377
			Color(105, 71, 50, 255) -- 377
		) -- 377
		fgDraw:drawSegment( -- 378
			Vec2(gunPivotX, gunPivotY), -- 378
			Vec2(tipX, tipY), -- 378
			1.8, -- 378
			Color(145, 140, 128, 245) -- 378
		) -- 378
	elseif calming then -- 378
		fgDraw:drawSegment( -- 380
			Vec2(cx + lean, shY - 6), -- 380
			Vec2(cx + f * sw * 2.1, shY - 14), -- 380
			3, -- 380
			Color(196, 222, 240, 235) -- 380
		) -- 380
		fgGlow:drawDot( -- 381
			Vec2(cx + f * sw * 2.15, shY - 14), -- 381
			3.6, -- 381
			toColor(PALETTE.amber, 225) -- 381
		) -- 381
	end -- 381
end -- 209
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 387
	local cx = cam:sx(a.x) -- 396
	local by = cam:sy(a.y, a.depth) -- 397
	local depthEnabled = p.room.depth ~= nil -- 398
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 399
	local H = cam:len(a.h) -- 400
	local W = cam:len(a.w) -- 401
	local f = a.facing -- 402
	local speed = math.max( -- 403
		math.abs(a.vx), -- 403
		math.abs(a.depthSpeed) -- 403
	) -- 403
	local ____isControlled_11 -- 404
	if isControlled then -- 404
		____isControlled_11 = self.playerStride -- 404
	else -- 404
		____isControlled_11 = self.partnerStride -- 404
	end -- 404
	local gait = ____isControlled_11 -- 404
	local afraid = not isControlled and p.escort.fear > 0 -- 406
	local slot = "child_idle" -- 407
	local height = H -- 408
	local frame = 0 -- 409
	local step = math.floor(self.animTime * 10) -- 410
	local nearCover = __TS__ArraySome( -- 411
		p.room.solids, -- 411
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 411
			math.abs(a.x - solid.x), -- 414
			math.abs(a.x - solid.x - solid.w) -- 414
		) <= 30 end -- 414
	) -- 414
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 414
		slot = "child_knock" -- 417
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 417
		slot = "child_offer" -- 420
	elseif isControlled and p.ticks < self.throwUntil then -- 420
		slot = "child_throw" -- 422
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 422
		slot = "child_aim" -- 424
	elseif isControlled and p.gripping then -- 424
		slot = "child_pull" -- 426
		frame = self.cartMoving and step or 0 -- 427
	elseif afraid and p.escort.state == "frozen" then -- 427
		slot = "child_fear" -- 429
		height = height * 0.74 -- 430
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 430
		slot = "child_peek" -- 433
		height = height * 0.83 -- 434
	elseif a.crouch then -- 434
		slot = "child_crouch" -- 436
		frame = speed > 8 and step or 0 -- 437
	elseif (gait and gait.speed or 0) > 8 then -- 437
		slot = "child_run" -- 439
		frame = step -- 440
	end -- 440
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 442
	local pose = { -- 443
		facing = facing, -- 444
		frame = frame, -- 444
		layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 444
	} -- 444
	local running = slot == "child_run" and a.onGround and gait ~= nil and assets:tryPlaceRun( -- 446
		"child", -- 447
		"actor_child", -- 447
		cx, -- 447
		by, -- 447
		W, -- 447
		height, -- 447
		gait.cycle, -- 447
		pose -- 447
	) -- 447
	if running or assets:tryPlace( -- 447
		slot, -- 448
		"actor_child", -- 448
		cx, -- 448
		by, -- 448
		W, -- 448
		height, -- 448
		pose -- 448
	) then -- 448
		fgDraw:drawEllipse( -- 449
			Vec2(cx, shadowY + 1), -- 449
			W * 0.48, -- 449
			3, -- 449
			Color(12, 11, 13, 125) -- 449
		) -- 449
		if afraid then -- 449
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 451
		end -- 451
		return -- 453
	end -- 453
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 456
	local x = cx + jitter -- 457
	local fullRef = a.crouch and H * 1.35 or H -- 459
	local cw = fullRef * 0.16 -- 460
	fgDraw:drawEllipse( -- 463
		Vec2(x, shadowY + 1), -- 463
		cw * 1.15, -- 463
		3.6, -- 463
		Color(4, 6, 10, 155) -- 463
	) -- 463
	local walking = speed > 6 and a.onGround -- 465
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 466
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 467
	local hipY = by + H * 0.3 -- 470
	local legSwing = stride * cw * 0.85 -- 471
	fgDraw:drawSegment( -- 472
		Vec2(x - 2, hipY), -- 472
		Vec2(x - legSwing, by + 2), -- 472
		math.max(2.6, cw * 0.22), -- 472
		Color(34, 30, 38, 255) -- 472
	) -- 472
	fgDraw:drawSegment( -- 473
		Vec2(x + 2, hipY), -- 473
		Vec2(x + legSwing, by + 2), -- 473
		math.max(2.8, cw * 0.24), -- 473
		Color(52, 46, 56, 255) -- 473
	) -- 473
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 476
	local cloakBotY = by + H * 0.2 -- 477
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 478
	fgDraw:drawPolygon( -- 479
		{ -- 479
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 480
			Vec2(x + cw * 0.92, cloakBotY), -- 481
			Vec2(x + cw * 0.62, cloakTopY), -- 482
			Vec2(x - cw * 0.68, cloakTopY) -- 483
		}, -- 483
		Color(214, 166, 94, 255), -- 484
		1.3, -- 484
		Color(252, 232, 192, 225) -- 484
	) -- 484
	fgDraw:drawPolygon( -- 485
		{ -- 485
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 486
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 487
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 488
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 489
		}, -- 489
		Color(148, 108, 56, 215) -- 490
	) -- 490
	fgDraw:drawSegment( -- 491
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 491
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 491
		1.8, -- 491
		toColor(PALETTE.amberCore, 200) -- 491
	) -- 491
	local scarfY = cloakTopY - 2 -- 494
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 495
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 496
	local sendX = x - f * cw * 1.65 + cloakDrag -- 497
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 498
	fgDraw:drawQuadraticBezier( -- 499
		Vec2(x - f * cw * 0.3, scarfY), -- 499
		Vec2(smidX, smidY), -- 499
		Vec2(sendX, sendY), -- 499
		2.8, -- 499
		toColor(PALETTE.amberCore, 235) -- 499
	) -- 499
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 502
	local headX = x + f * (a.crouch and 5 or 2) -- 503
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 504
	fgDraw:drawCircle( -- 505
		Vec2(headX, headY), -- 505
		headR, -- 505
		Color(240, 222, 198, 255) -- 505
	) -- 505
	fgDraw:drawPolygon( -- 507
		{ -- 507
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 508
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 509
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 510
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 511
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 512
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 513
		}, -- 513
		Color(156, 114, 62, 248), -- 514
		1.1, -- 514
		Color(244, 214, 162, 200) -- 514
	) -- 514
	fgGlow:drawDot( -- 516
		Vec2(headX + f * headR * 0.45, headY + 1), -- 516
		2.2, -- 516
		toColor(PALETTE.amberCore) -- 516
	) -- 516
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 519
	if hasCompass then -- 519
		local compX = x + f * cw * 0.65 -- 521
		local compY = by + H * 0.48 -- 522
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 523
		fgGlow:drawDot( -- 524
			Vec2(compX, compY), -- 524
			2.6, -- 524
			toColor(PALETTE.amberCore, 250) -- 524
		) -- 524
		fillRadialGlow( -- 525
			fgGlow, -- 525
			compX, -- 525
			compY, -- 525
			26 * glowPulse, -- 525
			26 * glowPulse, -- 525
			Color(248, 206, 120, 78 * glowPulse), -- 525
			Color(248, 180, 72, 0), -- 525
			14 -- 525
		) -- 525
	end -- 525
	if afraid then -- 525
		self:drawFear(fgGlow, p, x, by + H + 16) -- 529
	end -- 529
	if isControlled and walking and not a.crouch and speed > 100 then -- 529
		local r = 10 + self.animTime * 32 % 24 -- 534
		fgGlow:drawRing( -- 535
			Vec2(x, by + 3), -- 535
			r, -- 535
			r + 1.5, -- 535
			Color(0, 0, 0, 0), -- 535
			1.1, -- 535
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 535
		) -- 535
	end -- 535
end -- 387
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 539
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 540
	do -- 540
		local i = 0 -- 541
		while i < FEAR_MAX do -- 541
			local lit = i < p.escort.fear -- 542
			drawDiamond( -- 543
				fgGlow, -- 543
				x + (i - 1) * 13, -- 543
				y, -- 543
				4, -- 543
				5, -- 543
				toColor(lit and tint or PALETTE.steelDark, 215), -- 544
				1, -- 544
				toColor(tint, lit and 235 or 100) -- 544
			) -- 544
			i = i + 1 -- 541
		end -- 541
	end -- 541
end -- 539
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 548
	local x = cam:sx(e.x + f * 20) -- 549
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 550
	local dx = cam:sx(p.player.x) - x -- 551
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 552
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 553
	do -- 553
		local i = 0 -- 554
		while i < 8 do -- 554
			local a = length * i / 8 -- 555
			local b = length * (i + 1) / 8 -- 556
			fgGlow:drawSegment( -- 557
				Vec2(x + dx * a, y + dy * a), -- 557
				Vec2(x + dx * b, y + dy * b), -- 557
				1.3, -- 558
				Color(220, 120, 88, 210) -- 558
			) -- 558
			i = i + 2 -- 554
		end -- 554
	end -- 554
end -- 548
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 563
	local cx = cam:sx(e.x) -- 572
	local depth = e.depth or 0 -- 573
	local by = cam:sy(e.y, depth) -- 574
	local H = cam:len(e.h) -- 575
	local W = cam:len(e.w) -- 576
	local f = p.player.x >= e.x and 1 or -1 -- 577
	local slot = "enemy_idle" -- 579
	if not e.alive then -- 579
		slot = "enemy_down" -- 581
	elseif e.hitT > 0 then -- 581
		slot = "enemy_hit" -- 583
	elseif e.warnT > 0 then -- 583
		slot = "enemy_aim" -- 585
	end -- 585
	local height = e.alive and H or H * 0.24 -- 587
	if assets:tryPlace( -- 587
		slot, -- 588
		"actor_enemy_" .. tostring(index), -- 588
		cx, -- 588
		by, -- 588
		W, -- 588
		height, -- 588
		{ -- 588
			facing = f, -- 589
			opacity = e.alive and 1 or 0.78, -- 589
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 589
		} -- 589
	) then -- 589
		if e.alive and e.warnT > 0 then -- 589
			self:drawEnemyWarning( -- 592
				fgGlow, -- 592
				e, -- 592
				p, -- 592
				cam, -- 592
				f -- 592
			) -- 592
		end -- 592
		return -- 594
	end -- 594
	if not e.alive then -- 594
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 598
		fgDraw:drawPolygon( -- 599
			{ -- 599
				Vec2(cx - H * 0.3, by), -- 600
				Vec2(cx + H * 0.28, by), -- 601
				Vec2(cx + H * 0.2, by + H * 0.14), -- 602
				Vec2(cx - H * 0.24, by + H * 0.11) -- 603
			}, -- 603
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 604
		) -- 604
		if flash > 0 then -- 604
			fillRadialGlow( -- 606
				fgGlow, -- 606
				cx, -- 606
				by + 12, -- 606
				34 * flash, -- 606
				18 * flash, -- 606
				toColor(PALETTE.crimson, 180 * flash), -- 606
				Color(255, 48, 82, 0), -- 606
				12 -- 606
			) -- 606
		end -- 606
		return -- 608
	end -- 608
	local sw = H * 0.112 -- 611
	fgDraw:drawEllipse( -- 612
		Vec2(cx, by + 1), -- 612
		sw * 1.9, -- 612
		4, -- 612
		Color(4, 6, 10, 165) -- 612
	) -- 612
	local hipY = by + H * 0.44 -- 615
	local kneeY = by + H * 0.23 -- 616
	local shY = by + H * 0.79 -- 617
	fgDraw:drawSegment( -- 618
		Vec2(cx - 5, hipY), -- 618
		Vec2(cx - 7, kneeY), -- 618
		H * 0.044, -- 618
		Color(20, 16, 26, 255) -- 618
	) -- 618
	fgDraw:drawSegment( -- 619
		Vec2(cx - 7, kneeY), -- 619
		Vec2(cx - 8, by + 2), -- 619
		H * 0.038, -- 619
		Color(20, 16, 26, 255) -- 619
	) -- 619
	fgDraw:drawSegment( -- 620
		Vec2(cx + 5, hipY), -- 620
		Vec2(cx + 7, kneeY), -- 620
		H * 0.046, -- 620
		Color(28, 22, 36, 255) -- 620
	) -- 620
	fgDraw:drawSegment( -- 621
		Vec2(cx + 7, kneeY), -- 621
		Vec2(cx + 8, by + 2), -- 621
		H * 0.04, -- 621
		Color(28, 22, 36, 255) -- 621
	) -- 621
	fgDraw:drawPolygon( -- 623
		{ -- 623
			Vec2(cx - sw * 0.68, hipY), -- 624
			Vec2(cx + sw * 0.68, hipY), -- 625
			Vec2(cx + sw * 1.12, shY), -- 626
			Vec2(cx - sw * 1.12, shY) -- 627
		}, -- 627
		Color(111, 68, 55, 255), -- 628
		1.3, -- 628
		Color(143, 101, 66, 220) -- 628
	) -- 628
	fgDraw:drawPolygon( -- 629
		{ -- 629
			Vec2(cx - sw * 1.26, shY - 6), -- 630
			Vec2(cx + sw * 1.26, shY - 6), -- 631
			Vec2(cx + sw * 0.96, shY + 5), -- 632
			Vec2(cx - sw * 0.96, shY + 5) -- 633
		}, -- 633
		Color(98, 82, 62, 255) -- 634
	) -- 634
	local headR = H * 0.086 -- 636
	local headY = shY + headR * 1.32 -- 637
	fgDraw:drawCircle( -- 638
		Vec2(cx, headY), -- 638
		headR * 0.82, -- 638
		Color(187, 142, 103, 255) -- 638
	) -- 638
	fgDraw:drawPolygon( -- 639
		{ -- 639
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 640
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 641
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 642
		}, -- 642
		Color(136, 105, 65, 255), -- 643
		1.1, -- 643
		Color(177, 145, 91, 220) -- 643
	) -- 643
	local gunX = cx + f * H * 0.34 -- 645
	local gunY = by + H * 0.69 -- 646
	fgDraw:drawSegment( -- 647
		Vec2(cx - f * 6, gunY - 2), -- 647
		Vec2(gunX, gunY), -- 647
		2.8, -- 647
		Color(118, 87, 61, 255) -- 647
	) -- 647
	if e.warnT > 0 then -- 647
		self:drawEnemyWarning( -- 649
			fgGlow, -- 649
			e, -- 649
			p, -- 649
			cam, -- 649
			f -- 649
		) -- 649
	end -- 649
end -- 563
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 654
	local s = p.room.scavenger -- 661
	if s == nil then -- 661
		return -- 663
	end -- 663
	local cx = cam:sx(p.scavX) -- 665
	local by = cam:sy(s.y) -- 666
	local H = cam:len(s.h) -- 667
	local W = cam:len(26) -- 668
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 669
	local alert = p.scavChase or p.scavSee > 0 -- 672
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 673
	local eyeY = by + H * 0.8 -- 674
	local coneLen = cam:len(alert and 155 or 115) -- 675
	fgGlow:drawVertices({ -- 676
		{ -- 677
			Vec2(cx + f * 6, eyeY), -- 677
			toColor(coneCol, alert and 78 or 34) -- 677
		}, -- 677
		{ -- 678
			Vec2(cx + f * coneLen, by + H * 1.05), -- 678
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 678
		}, -- 678
		{ -- 679
			Vec2(cx + f * coneLen, by + 4), -- 679
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 679
		} -- 679
	}) -- 679
	local frame = 0 -- 682
	if p.scavState == "turn" then -- 682
		frame = 2 -- 684
	elseif p.scavState == "chase" then -- 684
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 686
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 686
		frame = math.floor(self.animTime * 8) % 2 -- 688
	end -- 688
	if assets:tryPlace( -- 688
		"scavenger", -- 690
		"actor_scav", -- 690
		cx, -- 690
		by, -- 690
		W, -- 690
		H, -- 690
		{facing = f, frame = frame, layer = 3} -- 690
	) then -- 690
		return -- 691
	end -- 691
	fgDraw:drawEllipse( -- 694
		Vec2(cx, by + 1), -- 694
		W * 0.62, -- 694
		4, -- 694
		Color(4, 6, 10, 155) -- 694
	) -- 694
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 695
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 696
	fgDraw:drawSegment( -- 698
		Vec2(cx - 4, by + H * 0.4), -- 698
		Vec2(cx - stride, by + 2), -- 698
		W * 0.16, -- 698
		Color(32, 30, 28, 255) -- 698
	) -- 698
	fgDraw:drawSegment( -- 699
		Vec2(cx + 4, by + H * 0.4), -- 699
		Vec2(cx + stride, by + 2), -- 699
		W * 0.16, -- 699
		Color(44, 40, 36, 255) -- 699
	) -- 699
	fgDraw:drawPolygon( -- 701
		{ -- 701
			Vec2(cx - W * 0.45, by + H * 0.25), -- 702
			Vec2(cx + W * 0.42, by + H * 0.25), -- 703
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 704
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 705
		}, -- 705
		Color(56, 52, 46, 255), -- 706
		1.2, -- 706
		Color(128, 118, 100, 180) -- 706
	) -- 706
	local headX = cx + f * 5 -- 708
	local headY = by + H * 0.88 -- 709
	fgDraw:drawCircle( -- 710
		Vec2(headX, headY), -- 710
		W * 0.3, -- 710
		Color(42, 38, 34, 255) -- 710
	) -- 710
	fgGlow:drawDot( -- 711
		Vec2(headX + f * 6, headY), -- 711
		3, -- 711
		toColor(coneCol, 245) -- 711
	) -- 711
	local indY = by + H + 18 -- 714
	if p.scavChase then -- 714
		drawDiamond( -- 716
			fgGlow, -- 716
			cx, -- 716
			indY, -- 716
			9, -- 716
			12, -- 716
			toColor(PALETTE.crimson, 240), -- 716
			1.5, -- 716
			toColor(PALETTE.crimsonCore) -- 716
		) -- 716
	elseif p.scavSee > 0 then -- 716
		local frac = math.min(1, p.scavSee / 24) -- 718
		fgGlow:drawArc( -- 719
			Vec2(cx, indY), -- 719
			11, -- 719
			90, -- 719
			90 - 360 * frac, -- 719
			2.4, -- 719
			toColor(PALETTE.crimson, 235) -- 719
		) -- 719
		fgGlow:drawDot( -- 720
			Vec2(cx, indY), -- 720
			3, -- 720
			toColor(PALETTE.amber) -- 720
		) -- 720
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 720
		drawDiamond( -- 722
			fgGlow, -- 722
			cx, -- 722
			indY, -- 722
			6, -- 722
			8, -- 722
			toColor(PALETTE.amber, 220) -- 722
		) -- 722
	end -- 722
end -- 654
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 727
	local cx = cam:sx(p.dogX) -- 734
	local by = cam:sy(0) -- 735
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 736
	local W = cam:len(34) -- 737
	local H = cam:len(28) -- 738
	local frame = 0 -- 740
	if p.dogState == "ear" then -- 740
		frame = 1 -- 742
	elseif p.dogState == "sniff" then -- 742
		frame = 3 -- 744
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 744
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 746
	end -- 746
	if assets:tryPlace( -- 746
		"dog", -- 748
		"actor_dog", -- 748
		cx, -- 748
		by, -- 748
		W, -- 748
		H, -- 748
		{facing = f, frame = frame, layer = 3} -- 748
	) then -- 748
		return -- 749
	end -- 749
	fgDraw:drawEllipse( -- 752
		Vec2(cx, by + 1), -- 752
		W * 0.56, -- 752
		3.5, -- 752
		Color(4, 8, 10, 155) -- 752
	) -- 752
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 753
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 754
	fgDraw:drawSegment( -- 757
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 757
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 757
		2.8, -- 757
		Color(26, 30, 34, 255) -- 757
	) -- 757
	fgDraw:drawSegment( -- 758
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 758
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 758
		2.8, -- 758
		Color(36, 40, 44, 255) -- 758
	) -- 758
	fgDraw:drawPolygon( -- 760
		{ -- 760
			Vec2(cx - W * 0.42, by + H * 0.36), -- 761
			Vec2(cx + W * 0.38, by + H * 0.42), -- 762
			Vec2(cx + W * 0.34, by + H * 0.78), -- 763
			Vec2(cx - W * 0.38, by + H * 0.72) -- 764
		}, -- 764
		Color(38, 42, 48, 255), -- 765
		1.2, -- 765
		Color(102, 118, 126, 175) -- 765
	) -- 765
	local hx = cx + f * W * 0.42 -- 766
	local hy = by + H * 0.84 -- 767
	fgDraw:drawPolygon( -- 768
		{ -- 768
			Vec2(hx - f * 8, hy - 6), -- 769
			Vec2(hx + f * 12, hy - 2), -- 770
			Vec2(hx + f * 4, hy + 8), -- 771
			Vec2(hx - f * 6, hy + 14) -- 772
		}, -- 772
		Color(44, 48, 54, 255) -- 773
	) -- 773
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 775
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 776
	fgGlow:drawDot( -- 777
		Vec2(hx + f * 4, hy + 2), -- 777
		2.8, -- 777
		toColor(eyeCol, 250) -- 777
	) -- 777
	fillRadialGlow( -- 778
		fgGlow, -- 778
		hx + f * 4, -- 778
		hy + 2, -- 778
		16, -- 778
		16, -- 778
		toColor(eyeCol, alert and 135 or 70), -- 778
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 778
		12 -- 778
	) -- 778
	if alert then -- 778
		local r = 12 + self.animTime * 42 % 24 -- 781
		fgGlow:drawArc( -- 782
			Vec2(hx, hy + 12), -- 782
			r, -- 782
			35, -- 782
			145, -- 782
			1.8, -- 782
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 782
		) -- 782
	end -- 782
end -- 727
return ____exports -- 727