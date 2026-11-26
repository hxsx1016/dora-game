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
local ____depth = require("Script.watch.depth") -- 6
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 6
local overlapsDepth = ____depth.overlapsDepth -- 6
local ____occlusion = require("Script.watch.fe.occlusion") -- 7
local depthOrder = ____occlusion.depthOrder -- 7
local ____theme = require("Script.watch.fe.theme") -- 10
local PALETTE = ____theme.PALETTE -- 10
local drawDiamond = ____theme.drawDiamond -- 10
local fillRadialGlow = ____theme.fillRadialGlow -- 10
local toColor = ____theme.toColor -- 10
____exports.ActorsRenderer = __TS__Class() -- 22
local ActorsRenderer = ____exports.ActorsRenderer -- 22
ActorsRenderer.name = "ActorsRenderer" -- 22
function ActorsRenderer.prototype.____constructor(self) -- 22
	self.ghosts = {} -- 23
	self.ghostCooldown = 0 -- 24
	self.animTime = 0 -- 25
	self.previousHp = 3 -- 26
	self.previousAxle = 0 -- 27
	self.cartMoving = false -- 28
	self.previousBottle = false -- 29
	self.hitUntil = -1 -- 31
	self.throwUntil = -1 -- 32
	self.shotUntil = -1 -- 33
end -- 22
function ActorsRenderer.prototype.reset(self, p) -- 35
	self.ghosts = {} -- 36
	self.ghostCooldown = 0 -- 37
	self.animTime = 0 -- 38
	self.previousHp = p.hp -- 39
	self.previousAxle = p.cartAxle -- 40
	self.cartMoving = false -- 41
	self.previousBottle = p.hasBottle -- 42
	self.previousTrace = p.trace -- 43
	self.hitUntil = -1 -- 44
	self.throwUntil = -1 -- 45
	self.shotUntil = -1 -- 46
end -- 35
function ActorsRenderer.prototype.update(self, dt, p) -- 50
	self.animTime = self.animTime + dt -- 51
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 51
		self.hitUntil = p.ticks + 14 -- 53
	end -- 53
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 53
		self.throwUntil = p.ticks + 12 -- 56
	end -- 56
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 56
		self.shotUntil = p.ticks + 7 -- 59
	end -- 59
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 61
	self.previousAxle = p.cartAxle -- 62
	self.previousHp = p.hp -- 63
	self.previousBottle = p.hasBottle -- 64
	self.previousTrace = p.trace -- 65
	if not p.childMode and p.player.rollT > 0 then -- 65
		self.ghostCooldown = self.ghostCooldown - dt -- 68
		if self.ghostCooldown <= 0 then -- 68
			local ____self_ghosts_0 = self.ghosts -- 68
			____self_ghosts_0[#____self_ghosts_0 + 1] = { -- 70
				x = p.player.x, -- 71
				y = p.player.y + p.player.depth, -- 72
				h = p.player.h, -- 73
				facing = p.player.facing, -- 74
				life = 0.28, -- 75
				maxLife = 0.28, -- 76
				isRoll = true -- 77
			} -- 77
			self.ghostCooldown = 0.036 -- 79
		end -- 79
	else -- 79
		self.ghostCooldown = 0 -- 82
	end -- 82
	local write = 0 -- 86
	local i = 0 -- 87
	do -- 87
		i = 0 -- 88
		while i < #self.ghosts do -- 88
			local g = self.ghosts[i + 1] -- 89
			g.life = g.life - dt -- 90
			if g.life > 0 then -- 90
				self.ghosts[write + 1] = g -- 92
				write = write + 1 -- 93
			end -- 93
			i = i + 1 -- 88
		end -- 88
	end -- 88
	__TS__ArraySetLength(self.ghosts, write) -- 88
end -- 50
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 99
	if suppressPartner == nil then -- 99
		suppressPartner = false -- 105
	end -- 105
	self:drawAfterimages(fgGlow, cam) -- 108
	local i = 0 -- 111
	do -- 111
		i = 0 -- 112
		while i < #p.enemies do -- 112
			self:drawEnemy( -- 113
				fgDraw, -- 113
				fgGlow, -- 113
				assets, -- 113
				p.enemies[i + 1], -- 113
				i, -- 113
				p, -- 113
				cam -- 113
			) -- 113
			i = i + 1 -- 112
		end -- 112
	end -- 112
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 112
		self:drawScavenger( -- 118
			fgDraw, -- 118
			fgGlow, -- 118
			assets, -- 118
			p, -- 118
			cam -- 118
		) -- 118
	end -- 118
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 118
		self:drawDog( -- 123
			fgDraw, -- 123
			fgGlow, -- 123
			assets, -- 123
			p, -- 123
			cam -- 123
		) -- 123
	end -- 123
	if p.partner.alive and not suppressPartner then -- 123
		local partnerIsChild = p.partner.w <= 28 -- 128
		if partnerIsChild then -- 128
			self:drawXiaoman( -- 130
				fgDraw, -- 130
				fgGlow, -- 130
				assets, -- 130
				p.partner, -- 130
				p, -- 130
				cam, -- 130
				false -- 130
			) -- 130
		else -- 130
			self:drawZhouShu( -- 132
				fgDraw, -- 132
				fgGlow, -- 132
				assets, -- 132
				p.partner, -- 132
				p, -- 132
				cam, -- 132
				false -- 132
			) -- 132
		end -- 132
	end -- 132
	if p.player.alive then -- 132
		if p.childMode then -- 132
			self:drawXiaoman( -- 139
				fgDraw, -- 139
				fgGlow, -- 139
				assets, -- 139
				p.player, -- 139
				p, -- 139
				cam, -- 139
				true -- 139
			) -- 139
		else -- 139
			self:drawZhouShu( -- 141
				fgDraw, -- 141
				fgGlow, -- 141
				assets, -- 141
				p.player, -- 141
				p, -- 141
				cam, -- 141
				true -- 141
			) -- 141
		end -- 141
	end -- 141
end -- 99
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 147
	local i = 0 -- 148
	do -- 148
		i = 0 -- 149
		while i < #self.ghosts do -- 149
			local g = self.ghosts[i + 1] -- 150
			local k = math.max( -- 151
				0, -- 151
				math.min(1, g.life / g.maxLife) -- 151
			) -- 151
			local spread = 1 - k -- 152
			local cx = cam:sx(g.x) -- 153
			local by = cam:sy(g.y) -- 154
			local f = g.facing -- 155
			local rBase = cam:len(6 + spread * 9) -- 156
			fgGlow:drawCircle( -- 158
				Vec2( -- 159
					cx - f * cam:len(6 + spread * 10), -- 159
					by + cam:len(4 + spread * 5) -- 159
				), -- 159
				rBase, -- 160
				Color( -- 161
					156, -- 161
					144, -- 161
					124, -- 161
					math.floor(78 * k + 0.5) -- 161
				) -- 161
			) -- 161
			fgGlow:drawCircle( -- 163
				Vec2( -- 164
					cx - f * cam:len(14 + spread * 14), -- 164
					by + cam:len(8 + spread * 8) -- 164
				), -- 164
				rBase * 0.72, -- 165
				Color( -- 166
					186, -- 166
					174, -- 166
					152, -- 166
					math.floor(54 * k + 0.5) -- 166
				) -- 166
			) -- 166
			i = i + 1 -- 149
		end -- 149
	end -- 149
end -- 147
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 172
	local cx = cam:sx(a.x) -- 181
	local by = cam:sy(a.y, a.depth) -- 182
	local depthEnabled = p.room.depth ~= nil -- 183
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 184
	local H = cam:len(a.h) -- 185
	local W = cam:len(a.w) -- 186
	local f = a.facing -- 187
	local speed = math.max( -- 188
		math.abs(a.vx), -- 188
		math.abs(a.depthSpeed) -- 188
	) -- 188
	local slot = "soldier_idle" -- 190
	local height = H -- 191
	local frame = 0 -- 192
	local facing = f -- 193
	local step = math.floor(self.animTime * 10) -- 194
	if isControlled and p.ticks < self.hitUntil then -- 194
		slot = "soldier_hit" -- 196
	elseif a.rollT > 0 then -- 196
		slot = "soldier_roll" -- 198
		height = height * 0.59 -- 199
	elseif p.phase == "prologue-give" then -- 199
		slot = "soldier_offer" -- 201
		height = height * 0.75 -- 202
		facing = p.partner.x >= a.x and 1 or -1 -- 203
	elseif isControlled and p.gripping then -- 203
		slot = "soldier_push" -- 205
		frame = self.cartMoving and step or 0 -- 206
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 207
		height = height * 0.91 -- 208
	elseif isControlled and p.escort.state == "calming" then -- 208
		slot = "soldier_knock" -- 210
		local calm = p.escort.calmTick -- 211
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 212
		height = height * 0.76 -- 213
	else -- 213
		local ____temp_3 = p.phase == "gate-send" -- 214
		if ____temp_3 then -- 214
			local ____opt_1 = p.room.story -- 214
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 214
		end -- 214
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 214
			slot = "soldier_hold" -- 216
			height = height * 1.11 -- 217
		elseif isControlled and p.ticks < self.shotUntil then -- 217
			local running = speed > 8 -- 219
			slot = running and "soldier_fire_move" or "soldier_fire" -- 220
			frame = running and step or 0 -- 221
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 222
		elseif a.covered or isControlled and p.coverHug then -- 222
			slot = "soldier_cover" -- 224
			height = height * 0.77 -- 225
		elseif speed > 8 then -- 225
			slot = "soldier_run" -- 227
			frame = step -- 228
		end -- 228
	end -- 228
	if assets:tryPlace( -- 228
		slot, -- 230
		"actor_soldier", -- 230
		cx, -- 230
		by, -- 230
		W, -- 230
		height, -- 230
		{ -- 230
			facing = facing, -- 231
			frame = frame, -- 231
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 231
		} -- 231
	) then -- 231
		fgDraw:drawEllipse( -- 233
			Vec2(cx, shadowY + 1), -- 233
			W * 0.54, -- 233
			4, -- 233
			Color(12, 11, 13, 145) -- 233
		) -- 233
		return -- 234
	end -- 234
	fgDraw:drawEllipse( -- 238
		Vec2(cx, shadowY + 1), -- 238
		H * 0.24, -- 238
		4.5, -- 238
		Color(3, 5, 10, 175) -- 238
	) -- 238
	local walking = speed > 10 and a.onGround -- 240
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 241
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 242
	local calming = not p.childMode and p.escort.state == "calming" -- 243
	local rolling = a.rollT > 0 -- 244
	local crouching = a.covered or calming or rolling -- 245
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 248
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 249
	local sw = H * 0.115 -- 250
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 253
	local kneeY = by + bodyH * 0.23 -- 254
	local stepX = stride * H * 0.15 -- 255
	local legDark = Color(14, 21, 34, 255) -- 256
	local legFront = Color(26, 38, 58, 255) -- 257
	local bkX = cx - f * 4 - stepX * 0.5 -- 259
	local bfX = cx - f * 8 - stepX -- 260
	fgDraw:drawSegment( -- 261
		Vec2(cx - f * 3, hipY), -- 261
		Vec2(bkX, kneeY), -- 261
		H * 0.044, -- 261
		legDark -- 261
	) -- 261
	fgDraw:drawSegment( -- 262
		Vec2(bkX, kneeY), -- 262
		Vec2(bfX, by + 3), -- 262
		H * 0.038, -- 262
		legDark -- 262
	) -- 262
	local fkX = cx + f * 6 + stepX * 0.55 -- 264
	local ffX = cx + f * 7 + stepX -- 265
	fgDraw:drawSegment( -- 266
		Vec2(cx + f * 3, hipY), -- 266
		Vec2(fkX, kneeY), -- 266
		H * 0.048, -- 266
		legFront -- 266
	) -- 266
	fgDraw:drawSegment( -- 267
		Vec2(fkX, kneeY), -- 267
		Vec2(ffX, by + 3), -- 267
		H * 0.042, -- 267
		legFront -- 267
	) -- 267
	fgDraw:drawSegment( -- 269
		Vec2(ffX - f * 2, by + 3), -- 269
		Vec2(ffX + f * 9, by + 3), -- 269
		3.4, -- 269
		Color(42, 60, 86, 255) -- 269
	) -- 269
	local shY = by + bodyH * 0.8 + bob -- 272
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 273
	fgDraw:drawPolygon( -- 274
		{ -- 274
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 275
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 276
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 277
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 278
		}, -- 278
		Color(16, 26, 42, 248), -- 279
		1.2, -- 279
		Color(64, 118, 164, 195) -- 279
	) -- 279
	fgDraw:drawPolygon( -- 282
		{ -- 282
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 283
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 284
			Vec2(cx + sw * 1.05 + lean, shY), -- 285
			Vec2(cx - sw * 0.98 + lean, shY) -- 286
		}, -- 286
		Color(24, 38, 60, 255), -- 287
		1.3, -- 287
		toColor(PALETTE.rimSilver, 190) -- 287
	) -- 287
	fgDraw:drawSegment( -- 289
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 290
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 291
		2.4, -- 292
		Color(173, 155, 125, 225) -- 293
	) -- 293
	fgDraw:drawPolygon( -- 295
		{ -- 295
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 296
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 297
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 298
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 299
		}, -- 299
		Color(99, 105, 103, 248) -- 300
	) -- 300
	local headR = H * 0.088 -- 303
	local headX = cx + lean + f * 3 -- 304
	local headY = shY + headR * 1.35 -- 305
	fgDraw:drawCircle( -- 306
		Vec2(headX, headY - headR * 0.12), -- 306
		headR * 0.86, -- 306
		Color(181, 139, 106, 255) -- 306
	) -- 306
	fgDraw:drawEllipse( -- 307
		Vec2(headX, headY + headR * 0.5), -- 307
		headR * 1.12, -- 307
		headR * 0.72, -- 307
		Color(66, 73, 76, 255) -- 307
	) -- 307
	fgDraw:drawSegment( -- 308
		Vec2(headX - headR, headY + 1), -- 308
		Vec2(headX + headR, headY + 1), -- 308
		1.6, -- 309
		Color(97, 103, 101, 255) -- 309
	) -- 309
	fgDraw:drawSegment( -- 310
		Vec2(headX, headY + headR), -- 310
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 310
		1.6, -- 311
		Color(177, 78, 51, 255) -- 311
	) -- 311
	if isControlled and not calming and not rolling and not p.gripping then -- 311
		local gunPivotX = cx + lean + f * sw * 0.35 -- 315
		local gunPivotY = shY - bodyH * 0.1 -- 316
		local aimDx = f -- 317
		local aimDy = 0 -- 318
		if p.aimX > 0 or p.aimY > 0 then -- 318
			aimDx = p.aimX - gunPivotX -- 320
			aimDy = p.aimY - gunPivotY -- 321
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 322
			if dLen > 4 then -- 322
				aimDx = aimDx / dLen -- 324
				aimDy = aimDy / dLen -- 325
			end -- 325
		end -- 325
		local barrelLen = H * 0.34 -- 328
		local tipX = gunPivotX + aimDx * barrelLen -- 329
		local tipY = gunPivotY + aimDy * barrelLen -- 330
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 331
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 332
		fgDraw:drawSegment( -- 334
			Vec2(cx + lean, shY - 5), -- 334
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 334
			3.6, -- 334
			Color(26, 40, 62, 255) -- 334
		) -- 334
		fgDraw:drawSegment( -- 335
			Vec2(stockX, stockY), -- 335
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 335
			3.8, -- 335
			Color(105, 71, 50, 255) -- 335
		) -- 335
		fgDraw:drawSegment( -- 336
			Vec2(gunPivotX, gunPivotY), -- 336
			Vec2(tipX, tipY), -- 336
			1.8, -- 336
			Color(145, 140, 128, 245) -- 336
		) -- 336
	elseif calming then -- 336
		fgDraw:drawSegment( -- 338
			Vec2(cx + lean, shY - 6), -- 338
			Vec2(cx + f * sw * 2.1, shY - 14), -- 338
			3, -- 338
			Color(196, 222, 240, 235) -- 338
		) -- 338
		fgGlow:drawDot( -- 339
			Vec2(cx + f * sw * 2.15, shY - 14), -- 339
			3.6, -- 339
			toColor(PALETTE.amber, 225) -- 339
		) -- 339
	end -- 339
end -- 172
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 345
	local cx = cam:sx(a.x) -- 354
	local by = cam:sy(a.y, a.depth) -- 355
	local depthEnabled = p.room.depth ~= nil -- 356
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 357
	local H = cam:len(a.h) -- 358
	local W = cam:len(a.w) -- 359
	local f = a.facing -- 360
	local speed = math.max( -- 361
		math.abs(a.vx), -- 361
		math.abs(a.depthSpeed) -- 361
	) -- 361
	local afraid = not isControlled and p.escort.fear > 0 -- 363
	local slot = "child_idle" -- 364
	local height = H -- 365
	local frame = 0 -- 366
	local step = math.floor(self.animTime * 10) -- 367
	local nearCover = __TS__ArraySome( -- 368
		p.room.solids, -- 368
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 368
			math.abs(a.x - solid.x), -- 371
			math.abs(a.x - solid.x - solid.w) -- 371
		) <= 30 end -- 371
	) -- 371
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 371
		slot = "child_knock" -- 374
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 374
		slot = "child_offer" -- 377
	elseif isControlled and p.ticks < self.throwUntil then -- 377
		slot = "child_throw" -- 379
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 379
		slot = "child_aim" -- 381
	elseif isControlled and p.gripping then -- 381
		slot = "child_pull" -- 383
		frame = self.cartMoving and step or 0 -- 384
	elseif afraid and p.escort.state == "frozen" then -- 384
		slot = "child_fear" -- 386
		height = height * 0.74 -- 387
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 387
		slot = "child_peek" -- 390
		height = height * 0.83 -- 391
	elseif a.crouch then -- 391
		slot = "child_crouch" -- 393
		frame = speed > 8 and step or 0 -- 394
	elseif speed > 8 then -- 394
		slot = "child_run" -- 396
		frame = step -- 397
	end -- 397
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 399
	if assets:tryPlace( -- 399
		slot, -- 400
		"actor_child", -- 400
		cx, -- 400
		by, -- 400
		W, -- 400
		height, -- 400
		{ -- 400
			facing = facing, -- 401
			frame = frame, -- 401
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 401
		} -- 401
	) then -- 401
		fgDraw:drawEllipse( -- 403
			Vec2(cx, shadowY + 1), -- 403
			W * 0.48, -- 403
			3, -- 403
			Color(12, 11, 13, 125) -- 403
		) -- 403
		if afraid then -- 403
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 405
		end -- 405
		return -- 407
	end -- 407
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 410
	local x = cx + jitter -- 411
	local fullRef = a.crouch and H * 1.35 or H -- 413
	local cw = fullRef * 0.16 -- 414
	fgDraw:drawEllipse( -- 417
		Vec2(x, shadowY + 1), -- 417
		cw * 1.15, -- 417
		3.6, -- 417
		Color(4, 6, 10, 155) -- 417
	) -- 417
	local walking = speed > 6 and a.onGround -- 419
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 420
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 421
	local hipY = by + H * 0.3 -- 424
	local legSwing = stride * cw * 0.85 -- 425
	fgDraw:drawSegment( -- 426
		Vec2(x - 2, hipY), -- 426
		Vec2(x - legSwing, by + 2), -- 426
		math.max(2.6, cw * 0.22), -- 426
		Color(34, 30, 38, 255) -- 426
	) -- 426
	fgDraw:drawSegment( -- 427
		Vec2(x + 2, hipY), -- 427
		Vec2(x + legSwing, by + 2), -- 427
		math.max(2.8, cw * 0.24), -- 427
		Color(52, 46, 56, 255) -- 427
	) -- 427
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 430
	local cloakBotY = by + H * 0.2 -- 431
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 432
	fgDraw:drawPolygon( -- 433
		{ -- 433
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 434
			Vec2(x + cw * 0.92, cloakBotY), -- 435
			Vec2(x + cw * 0.62, cloakTopY), -- 436
			Vec2(x - cw * 0.68, cloakTopY) -- 437
		}, -- 437
		Color(214, 166, 94, 255), -- 438
		1.3, -- 438
		Color(252, 232, 192, 225) -- 438
	) -- 438
	fgDraw:drawPolygon( -- 439
		{ -- 439
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 440
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 441
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 442
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 443
		}, -- 443
		Color(148, 108, 56, 215) -- 444
	) -- 444
	fgDraw:drawSegment( -- 445
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 445
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 445
		1.8, -- 445
		toColor(PALETTE.amberCore, 200) -- 445
	) -- 445
	local scarfY = cloakTopY - 2 -- 448
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 449
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 450
	local sendX = x - f * cw * 1.65 + cloakDrag -- 451
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 452
	fgDraw:drawQuadraticBezier( -- 453
		Vec2(x - f * cw * 0.3, scarfY), -- 453
		Vec2(smidX, smidY), -- 453
		Vec2(sendX, sendY), -- 453
		2.8, -- 453
		toColor(PALETTE.amberCore, 235) -- 453
	) -- 453
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 456
	local headX = x + f * (a.crouch and 5 or 2) -- 457
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 458
	fgDraw:drawCircle( -- 459
		Vec2(headX, headY), -- 459
		headR, -- 459
		Color(240, 222, 198, 255) -- 459
	) -- 459
	fgDraw:drawPolygon( -- 461
		{ -- 461
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 462
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 463
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 464
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 465
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 466
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 467
		}, -- 467
		Color(156, 114, 62, 248), -- 468
		1.1, -- 468
		Color(244, 214, 162, 200) -- 468
	) -- 468
	fgGlow:drawDot( -- 470
		Vec2(headX + f * headR * 0.45, headY + 1), -- 470
		2.2, -- 470
		toColor(PALETTE.amberCore) -- 470
	) -- 470
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 473
	if hasCompass then -- 473
		local compX = x + f * cw * 0.65 -- 475
		local compY = by + H * 0.48 -- 476
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 477
		fgGlow:drawDot( -- 478
			Vec2(compX, compY), -- 478
			2.6, -- 478
			toColor(PALETTE.amberCore, 250) -- 478
		) -- 478
		fillRadialGlow( -- 479
			fgGlow, -- 479
			compX, -- 479
			compY, -- 479
			26 * glowPulse, -- 479
			26 * glowPulse, -- 479
			Color(248, 206, 120, 78 * glowPulse), -- 479
			Color(248, 180, 72, 0), -- 479
			14 -- 479
		) -- 479
	end -- 479
	if afraid then -- 479
		self:drawFear(fgGlow, p, x, by + H + 16) -- 483
	end -- 483
	if isControlled and walking and not a.crouch and speed > 100 then -- 483
		local r = 10 + self.animTime * 32 % 24 -- 488
		fgGlow:drawRing( -- 489
			Vec2(x, by + 3), -- 489
			r, -- 489
			r + 1.5, -- 489
			Color(0, 0, 0, 0), -- 489
			1.1, -- 489
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 489
		) -- 489
	end -- 489
end -- 345
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 493
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 494
	do -- 494
		local i = 0 -- 495
		while i < FEAR_MAX do -- 495
			local lit = i < p.escort.fear -- 496
			drawDiamond( -- 497
				fgGlow, -- 497
				x + (i - 1) * 13, -- 497
				y, -- 497
				4, -- 497
				5, -- 497
				toColor(lit and tint or PALETTE.steelDark, 215), -- 498
				1, -- 498
				toColor(tint, lit and 235 or 100) -- 498
			) -- 498
			i = i + 1 -- 495
		end -- 495
	end -- 495
end -- 493
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 502
	local x = cam:sx(e.x + f * 20) -- 503
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 504
	local dx = cam:sx(p.player.x) - x -- 505
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 506
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 507
	do -- 507
		local i = 0 -- 508
		while i < 8 do -- 508
			local a = length * i / 8 -- 509
			local b = length * (i + 1) / 8 -- 510
			fgGlow:drawSegment( -- 511
				Vec2(x + dx * a, y + dy * a), -- 511
				Vec2(x + dx * b, y + dy * b), -- 511
				1.3, -- 512
				Color(220, 120, 88, 210) -- 512
			) -- 512
			i = i + 2 -- 508
		end -- 508
	end -- 508
end -- 502
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 517
	local cx = cam:sx(e.x) -- 526
	local depth = e.depth or 0 -- 527
	local by = cam:sy(e.y, depth) -- 528
	local H = cam:len(e.h) -- 529
	local W = cam:len(e.w) -- 530
	local f = p.player.x >= e.x and 1 or -1 -- 531
	local slot = "enemy_idle" -- 533
	if not e.alive then -- 533
		slot = "enemy_down" -- 535
	elseif e.hitT > 0 then -- 535
		slot = "enemy_hit" -- 537
	elseif e.warnT > 0 then -- 537
		slot = "enemy_aim" -- 539
	end -- 539
	local height = e.alive and H or H * 0.24 -- 541
	if assets:tryPlace( -- 541
		slot, -- 542
		"actor_enemy_" .. tostring(index), -- 542
		cx, -- 542
		by, -- 542
		W, -- 542
		height, -- 542
		{ -- 542
			facing = f, -- 543
			opacity = e.alive and 1 or 0.78, -- 543
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 543
		} -- 543
	) then -- 543
		if e.alive and e.warnT > 0 then -- 543
			self:drawEnemyWarning( -- 546
				fgGlow, -- 546
				e, -- 546
				p, -- 546
				cam, -- 546
				f -- 546
			) -- 546
		end -- 546
		return -- 548
	end -- 548
	if not e.alive then -- 548
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 552
		fgDraw:drawPolygon( -- 553
			{ -- 553
				Vec2(cx - H * 0.3, by), -- 554
				Vec2(cx + H * 0.28, by), -- 555
				Vec2(cx + H * 0.2, by + H * 0.14), -- 556
				Vec2(cx - H * 0.24, by + H * 0.11) -- 557
			}, -- 557
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 558
		) -- 558
		if flash > 0 then -- 558
			fillRadialGlow( -- 560
				fgGlow, -- 560
				cx, -- 560
				by + 12, -- 560
				34 * flash, -- 560
				18 * flash, -- 560
				toColor(PALETTE.crimson, 180 * flash), -- 560
				Color(255, 48, 82, 0), -- 560
				12 -- 560
			) -- 560
		end -- 560
		return -- 562
	end -- 562
	local sw = H * 0.112 -- 565
	fgDraw:drawEllipse( -- 566
		Vec2(cx, by + 1), -- 566
		sw * 1.9, -- 566
		4, -- 566
		Color(4, 6, 10, 165) -- 566
	) -- 566
	local hipY = by + H * 0.44 -- 569
	local kneeY = by + H * 0.23 -- 570
	local shY = by + H * 0.79 -- 571
	fgDraw:drawSegment( -- 572
		Vec2(cx - 5, hipY), -- 572
		Vec2(cx - 7, kneeY), -- 572
		H * 0.044, -- 572
		Color(20, 16, 26, 255) -- 572
	) -- 572
	fgDraw:drawSegment( -- 573
		Vec2(cx - 7, kneeY), -- 573
		Vec2(cx - 8, by + 2), -- 573
		H * 0.038, -- 573
		Color(20, 16, 26, 255) -- 573
	) -- 573
	fgDraw:drawSegment( -- 574
		Vec2(cx + 5, hipY), -- 574
		Vec2(cx + 7, kneeY), -- 574
		H * 0.046, -- 574
		Color(28, 22, 36, 255) -- 574
	) -- 574
	fgDraw:drawSegment( -- 575
		Vec2(cx + 7, kneeY), -- 575
		Vec2(cx + 8, by + 2), -- 575
		H * 0.04, -- 575
		Color(28, 22, 36, 255) -- 575
	) -- 575
	fgDraw:drawPolygon( -- 577
		{ -- 577
			Vec2(cx - sw * 0.68, hipY), -- 578
			Vec2(cx + sw * 0.68, hipY), -- 579
			Vec2(cx + sw * 1.12, shY), -- 580
			Vec2(cx - sw * 1.12, shY) -- 581
		}, -- 581
		Color(111, 68, 55, 255), -- 582
		1.3, -- 582
		Color(143, 101, 66, 220) -- 582
	) -- 582
	fgDraw:drawPolygon( -- 583
		{ -- 583
			Vec2(cx - sw * 1.26, shY - 6), -- 584
			Vec2(cx + sw * 1.26, shY - 6), -- 585
			Vec2(cx + sw * 0.96, shY + 5), -- 586
			Vec2(cx - sw * 0.96, shY + 5) -- 587
		}, -- 587
		Color(98, 82, 62, 255) -- 588
	) -- 588
	local headR = H * 0.086 -- 590
	local headY = shY + headR * 1.32 -- 591
	fgDraw:drawCircle( -- 592
		Vec2(cx, headY), -- 592
		headR * 0.82, -- 592
		Color(187, 142, 103, 255) -- 592
	) -- 592
	fgDraw:drawPolygon( -- 593
		{ -- 593
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 594
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 595
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 596
		}, -- 596
		Color(136, 105, 65, 255), -- 597
		1.1, -- 597
		Color(177, 145, 91, 220) -- 597
	) -- 597
	local gunX = cx + f * H * 0.34 -- 599
	local gunY = by + H * 0.69 -- 600
	fgDraw:drawSegment( -- 601
		Vec2(cx - f * 6, gunY - 2), -- 601
		Vec2(gunX, gunY), -- 601
		2.8, -- 601
		Color(118, 87, 61, 255) -- 601
	) -- 601
	if e.warnT > 0 then -- 601
		self:drawEnemyWarning( -- 603
			fgGlow, -- 603
			e, -- 603
			p, -- 603
			cam, -- 603
			f -- 603
		) -- 603
	end -- 603
end -- 517
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 608
	local s = p.room.scavenger -- 615
	if s == nil then -- 615
		return -- 617
	end -- 617
	local cx = cam:sx(p.scavX) -- 619
	local by = cam:sy(s.y) -- 620
	local H = cam:len(s.h) -- 621
	local W = cam:len(26) -- 622
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 623
	local alert = p.scavChase or p.scavSee > 0 -- 626
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 627
	local eyeY = by + H * 0.8 -- 628
	local coneLen = cam:len(alert and 155 or 115) -- 629
	fgGlow:drawVertices({ -- 630
		{ -- 631
			Vec2(cx + f * 6, eyeY), -- 631
			toColor(coneCol, alert and 78 or 34) -- 631
		}, -- 631
		{ -- 632
			Vec2(cx + f * coneLen, by + H * 1.05), -- 632
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 632
		}, -- 632
		{ -- 633
			Vec2(cx + f * coneLen, by + 4), -- 633
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 633
		} -- 633
	}) -- 633
	local frame = 0 -- 636
	if p.scavState == "turn" then -- 636
		frame = 2 -- 638
	elseif p.scavState == "chase" then -- 638
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 640
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 640
		frame = math.floor(self.animTime * 8) % 2 -- 642
	end -- 642
	if assets:tryPlace( -- 642
		"scavenger", -- 644
		"actor_scav", -- 644
		cx, -- 644
		by, -- 644
		W, -- 644
		H, -- 644
		{facing = f, frame = frame, layer = 3} -- 644
	) then -- 644
		return -- 645
	end -- 645
	fgDraw:drawEllipse( -- 648
		Vec2(cx, by + 1), -- 648
		W * 0.62, -- 648
		4, -- 648
		Color(4, 6, 10, 155) -- 648
	) -- 648
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 649
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 650
	fgDraw:drawSegment( -- 652
		Vec2(cx - 4, by + H * 0.4), -- 652
		Vec2(cx - stride, by + 2), -- 652
		W * 0.16, -- 652
		Color(32, 30, 28, 255) -- 652
	) -- 652
	fgDraw:drawSegment( -- 653
		Vec2(cx + 4, by + H * 0.4), -- 653
		Vec2(cx + stride, by + 2), -- 653
		W * 0.16, -- 653
		Color(44, 40, 36, 255) -- 653
	) -- 653
	fgDraw:drawPolygon( -- 655
		{ -- 655
			Vec2(cx - W * 0.45, by + H * 0.25), -- 656
			Vec2(cx + W * 0.42, by + H * 0.25), -- 657
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 658
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 659
		}, -- 659
		Color(56, 52, 46, 255), -- 660
		1.2, -- 660
		Color(128, 118, 100, 180) -- 660
	) -- 660
	local headX = cx + f * 5 -- 662
	local headY = by + H * 0.88 -- 663
	fgDraw:drawCircle( -- 664
		Vec2(headX, headY), -- 664
		W * 0.3, -- 664
		Color(42, 38, 34, 255) -- 664
	) -- 664
	fgGlow:drawDot( -- 665
		Vec2(headX + f * 6, headY), -- 665
		3, -- 665
		toColor(coneCol, 245) -- 665
	) -- 665
	local indY = by + H + 18 -- 668
	if p.scavChase then -- 668
		drawDiamond( -- 670
			fgGlow, -- 670
			cx, -- 670
			indY, -- 670
			9, -- 670
			12, -- 670
			toColor(PALETTE.crimson, 240), -- 670
			1.5, -- 670
			toColor(PALETTE.crimsonCore) -- 670
		) -- 670
	elseif p.scavSee > 0 then -- 670
		local frac = math.min(1, p.scavSee / 24) -- 672
		fgGlow:drawArc( -- 673
			Vec2(cx, indY), -- 673
			11, -- 673
			90, -- 673
			90 - 360 * frac, -- 673
			2.4, -- 673
			toColor(PALETTE.crimson, 235) -- 673
		) -- 673
		fgGlow:drawDot( -- 674
			Vec2(cx, indY), -- 674
			3, -- 674
			toColor(PALETTE.amber) -- 674
		) -- 674
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 674
		drawDiamond( -- 676
			fgGlow, -- 676
			cx, -- 676
			indY, -- 676
			6, -- 676
			8, -- 676
			toColor(PALETTE.amber, 220) -- 676
		) -- 676
	end -- 676
end -- 608
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 681
	local cx = cam:sx(p.dogX) -- 688
	local by = cam:sy(0) -- 689
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 690
	local W = cam:len(34) -- 691
	local H = cam:len(28) -- 692
	local frame = 0 -- 694
	if p.dogState == "ear" then -- 694
		frame = 1 -- 696
	elseif p.dogState == "sniff" then -- 696
		frame = 3 -- 698
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 698
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 700
	end -- 700
	if assets:tryPlace( -- 700
		"dog", -- 702
		"actor_dog", -- 702
		cx, -- 702
		by, -- 702
		W, -- 702
		H, -- 702
		{facing = f, frame = frame, layer = 3} -- 702
	) then -- 702
		return -- 703
	end -- 703
	fgDraw:drawEllipse( -- 706
		Vec2(cx, by + 1), -- 706
		W * 0.56, -- 706
		3.5, -- 706
		Color(4, 8, 10, 155) -- 706
	) -- 706
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 707
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 708
	fgDraw:drawSegment( -- 711
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 711
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 711
		2.8, -- 711
		Color(26, 30, 34, 255) -- 711
	) -- 711
	fgDraw:drawSegment( -- 712
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 712
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 712
		2.8, -- 712
		Color(36, 40, 44, 255) -- 712
	) -- 712
	fgDraw:drawPolygon( -- 714
		{ -- 714
			Vec2(cx - W * 0.42, by + H * 0.36), -- 715
			Vec2(cx + W * 0.38, by + H * 0.42), -- 716
			Vec2(cx + W * 0.34, by + H * 0.78), -- 717
			Vec2(cx - W * 0.38, by + H * 0.72) -- 718
		}, -- 718
		Color(38, 42, 48, 255), -- 719
		1.2, -- 719
		Color(102, 118, 126, 175) -- 719
	) -- 719
	local hx = cx + f * W * 0.42 -- 720
	local hy = by + H * 0.84 -- 721
	fgDraw:drawPolygon( -- 722
		{ -- 722
			Vec2(hx - f * 8, hy - 6), -- 723
			Vec2(hx + f * 12, hy - 2), -- 724
			Vec2(hx + f * 4, hy + 8), -- 725
			Vec2(hx - f * 6, hy + 14) -- 726
		}, -- 726
		Color(44, 48, 54, 255) -- 727
	) -- 727
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 729
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 730
	fgGlow:drawDot( -- 731
		Vec2(hx + f * 4, hy + 2), -- 731
		2.8, -- 731
		toColor(eyeCol, 250) -- 731
	) -- 731
	fillRadialGlow( -- 732
		fgGlow, -- 732
		hx + f * 4, -- 732
		hy + 2, -- 732
		16, -- 732
		16, -- 732
		toColor(eyeCol, alert and 135 or 70), -- 732
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 732
		12 -- 732
	) -- 732
	if alert then -- 732
		local r = 12 + self.animTime * 42 % 24 -- 735
		fgGlow:drawArc( -- 736
			Vec2(hx, hy + 12), -- 736
			r, -- 736
			35, -- 736
			145, -- 736
			1.8, -- 736
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 736
		) -- 736
	end -- 736
end -- 681
return ____exports -- 681