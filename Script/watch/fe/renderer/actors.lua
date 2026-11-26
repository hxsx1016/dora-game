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
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 172
	local half = a.w * 0.5 -- 173
	local g = 0 -- 174
	local i = 0 -- 175
	do -- 175
		i = 0 -- 176
		while i < #p.room.floors do -- 176
			local f = p.room.floors[i + 1] -- 177
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 177
				g = f.y -- 179
			end -- 179
			i = i + 1 -- 176
		end -- 176
	end -- 176
	do -- 176
		i = 0 -- 182
		while i < #p.boxes do -- 182
			do -- 182
				local b = p.boxes[i + 1] -- 183
				if b.broken == true or b.hidden == true or b.soft == true then -- 183
					goto __continue33 -- 185
				end -- 185
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 185
					g = b.y1 -- 189
				end -- 189
			end -- 189
			::__continue33:: -- 189
			i = i + 1 -- 182
		end -- 182
	end -- 182
	return g -- 192
end -- 172
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 196
	local cx = cam:sx(a.x) -- 205
	local by = cam:sy(a.y, a.depth) -- 206
	local depthEnabled = p.room.depth ~= nil -- 207
	local shadowY = not a.onGround and cam:sy( -- 208
		self:supportGroundY(p, a), -- 208
		a.depth -- 208
	) or by -- 208
	local H = cam:len(a.h) -- 209
	local W = cam:len(a.w) -- 210
	local f = a.facing -- 211
	local speed = math.max( -- 212
		math.abs(a.vx), -- 212
		math.abs(a.depthSpeed) -- 212
	) -- 212
	local slot = "soldier_idle" -- 214
	local height = H -- 215
	local frame = 0 -- 216
	local facing = f -- 217
	local step = math.floor(self.animTime * 10) -- 218
	if isControlled and p.ticks < self.hitUntil then -- 218
		slot = "soldier_hit" -- 220
	elseif a.rollT > 0 then -- 220
		slot = "soldier_roll" -- 222
		height = height * 0.59 -- 223
	elseif p.phase == "prologue-give" then -- 223
		slot = "soldier_offer" -- 225
		height = height * 0.75 -- 226
		facing = p.partner.x >= a.x and 1 or -1 -- 227
	elseif isControlled and p.gripping then -- 227
		slot = "soldier_push" -- 229
		frame = self.cartMoving and step or 0 -- 230
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 231
		height = height * 0.91 -- 232
	elseif isControlled and p.escort.state == "calming" then -- 232
		slot = "soldier_knock" -- 234
		local calm = p.escort.calmTick -- 235
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 236
		height = height * 0.76 -- 237
	else -- 237
		local ____temp_3 = p.phase == "gate-send" -- 238
		if ____temp_3 then -- 238
			local ____opt_1 = p.room.story -- 238
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 238
		end -- 238
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 238
			slot = "soldier_hold" -- 240
			height = height * 1.11 -- 241
		elseif isControlled and p.ticks < self.shotUntil then -- 241
			local running = speed > 8 -- 243
			slot = running and "soldier_fire_move" or "soldier_fire" -- 244
			frame = running and step or 0 -- 245
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 246
		elseif a.covered or isControlled and p.coverHug then -- 246
			slot = "soldier_cover" -- 248
			height = height * 0.77 -- 249
		elseif speed > 8 then -- 249
			slot = "soldier_run" -- 251
			frame = step -- 252
		end -- 252
	end -- 252
	if assets:tryPlace( -- 252
		slot, -- 254
		"actor_soldier", -- 254
		cx, -- 254
		by, -- 254
		W, -- 254
		height, -- 254
		{ -- 254
			facing = facing, -- 255
			frame = frame, -- 255
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 255
		} -- 255
	) then -- 255
		fgDraw:drawEllipse( -- 257
			Vec2(cx, shadowY + 1), -- 257
			W * 0.54, -- 257
			4, -- 257
			Color(12, 11, 13, 145) -- 257
		) -- 257
		return -- 258
	end -- 258
	fgDraw:drawEllipse( -- 262
		Vec2(cx, shadowY + 1), -- 262
		H * 0.24, -- 262
		4.5, -- 262
		Color(3, 5, 10, 175) -- 262
	) -- 262
	local walking = speed > 10 and a.onGround -- 264
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 265
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 266
	local calming = not p.childMode and p.escort.state == "calming" -- 267
	local rolling = a.rollT > 0 -- 268
	local crouching = a.covered or calming or rolling -- 269
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 272
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 273
	local sw = H * 0.115 -- 274
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 277
	local kneeY = by + bodyH * 0.23 -- 278
	local stepX = stride * H * 0.15 -- 279
	local legDark = Color(14, 21, 34, 255) -- 280
	local legFront = Color(26, 38, 58, 255) -- 281
	local bkX = cx - f * 4 - stepX * 0.5 -- 283
	local bfX = cx - f * 8 - stepX -- 284
	fgDraw:drawSegment( -- 285
		Vec2(cx - f * 3, hipY), -- 285
		Vec2(bkX, kneeY), -- 285
		H * 0.044, -- 285
		legDark -- 285
	) -- 285
	fgDraw:drawSegment( -- 286
		Vec2(bkX, kneeY), -- 286
		Vec2(bfX, by + 3), -- 286
		H * 0.038, -- 286
		legDark -- 286
	) -- 286
	local fkX = cx + f * 6 + stepX * 0.55 -- 288
	local ffX = cx + f * 7 + stepX -- 289
	fgDraw:drawSegment( -- 290
		Vec2(cx + f * 3, hipY), -- 290
		Vec2(fkX, kneeY), -- 290
		H * 0.048, -- 290
		legFront -- 290
	) -- 290
	fgDraw:drawSegment( -- 291
		Vec2(fkX, kneeY), -- 291
		Vec2(ffX, by + 3), -- 291
		H * 0.042, -- 291
		legFront -- 291
	) -- 291
	fgDraw:drawSegment( -- 293
		Vec2(ffX - f * 2, by + 3), -- 293
		Vec2(ffX + f * 9, by + 3), -- 293
		3.4, -- 293
		Color(42, 60, 86, 255) -- 293
	) -- 293
	local shY = by + bodyH * 0.8 + bob -- 296
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 297
	fgDraw:drawPolygon( -- 298
		{ -- 298
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 299
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 300
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 301
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 302
		}, -- 302
		Color(16, 26, 42, 248), -- 303
		1.2, -- 303
		Color(64, 118, 164, 195) -- 303
	) -- 303
	fgDraw:drawPolygon( -- 306
		{ -- 306
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 307
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 308
			Vec2(cx + sw * 1.05 + lean, shY), -- 309
			Vec2(cx - sw * 0.98 + lean, shY) -- 310
		}, -- 310
		Color(24, 38, 60, 255), -- 311
		1.3, -- 311
		toColor(PALETTE.rimSilver, 190) -- 311
	) -- 311
	fgDraw:drawSegment( -- 313
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 314
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 315
		2.4, -- 316
		Color(173, 155, 125, 225) -- 317
	) -- 317
	fgDraw:drawPolygon( -- 319
		{ -- 319
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 320
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 321
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 322
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 323
		}, -- 323
		Color(99, 105, 103, 248) -- 324
	) -- 324
	local headR = H * 0.088 -- 327
	local headX = cx + lean + f * 3 -- 328
	local headY = shY + headR * 1.35 -- 329
	fgDraw:drawCircle( -- 330
		Vec2(headX, headY - headR * 0.12), -- 330
		headR * 0.86, -- 330
		Color(181, 139, 106, 255) -- 330
	) -- 330
	fgDraw:drawEllipse( -- 331
		Vec2(headX, headY + headR * 0.5), -- 331
		headR * 1.12, -- 331
		headR * 0.72, -- 331
		Color(66, 73, 76, 255) -- 331
	) -- 331
	fgDraw:drawSegment( -- 332
		Vec2(headX - headR, headY + 1), -- 332
		Vec2(headX + headR, headY + 1), -- 332
		1.6, -- 333
		Color(97, 103, 101, 255) -- 333
	) -- 333
	fgDraw:drawSegment( -- 334
		Vec2(headX, headY + headR), -- 334
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 334
		1.6, -- 335
		Color(177, 78, 51, 255) -- 335
	) -- 335
	if isControlled and not calming and not rolling and not p.gripping then -- 335
		local gunPivotX = cx + lean + f * sw * 0.35 -- 339
		local gunPivotY = shY - bodyH * 0.1 -- 340
		local aimDx = f -- 341
		local aimDy = 0 -- 342
		if p.aimX > 0 or p.aimY > 0 then -- 342
			aimDx = p.aimX - gunPivotX -- 344
			aimDy = p.aimY - gunPivotY -- 345
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 346
			if dLen > 4 then -- 346
				aimDx = aimDx / dLen -- 348
				aimDy = aimDy / dLen -- 349
			end -- 349
		end -- 349
		local barrelLen = H * 0.34 -- 352
		local tipX = gunPivotX + aimDx * barrelLen -- 353
		local tipY = gunPivotY + aimDy * barrelLen -- 354
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 355
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 356
		fgDraw:drawSegment( -- 358
			Vec2(cx + lean, shY - 5), -- 358
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 358
			3.6, -- 358
			Color(26, 40, 62, 255) -- 358
		) -- 358
		fgDraw:drawSegment( -- 359
			Vec2(stockX, stockY), -- 359
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 359
			3.8, -- 359
			Color(105, 71, 50, 255) -- 359
		) -- 359
		fgDraw:drawSegment( -- 360
			Vec2(gunPivotX, gunPivotY), -- 360
			Vec2(tipX, tipY), -- 360
			1.8, -- 360
			Color(145, 140, 128, 245) -- 360
		) -- 360
	elseif calming then -- 360
		fgDraw:drawSegment( -- 362
			Vec2(cx + lean, shY - 6), -- 362
			Vec2(cx + f * sw * 2.1, shY - 14), -- 362
			3, -- 362
			Color(196, 222, 240, 235) -- 362
		) -- 362
		fgGlow:drawDot( -- 363
			Vec2(cx + f * sw * 2.15, shY - 14), -- 363
			3.6, -- 363
			toColor(PALETTE.amber, 225) -- 363
		) -- 363
	end -- 363
end -- 196
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 369
	local cx = cam:sx(a.x) -- 378
	local by = cam:sy(a.y, a.depth) -- 379
	local depthEnabled = p.room.depth ~= nil -- 380
	local shadowY = not a.onGround and cam:sy( -- 381
		self:supportGroundY(p, a), -- 381
		a.depth -- 381
	) or by -- 381
	local H = cam:len(a.h) -- 382
	local W = cam:len(a.w) -- 383
	local f = a.facing -- 384
	local speed = math.max( -- 385
		math.abs(a.vx), -- 385
		math.abs(a.depthSpeed) -- 385
	) -- 385
	local afraid = not isControlled and p.escort.fear > 0 -- 387
	local slot = "child_idle" -- 388
	local height = H -- 389
	local frame = 0 -- 390
	local step = math.floor(self.animTime * 10) -- 391
	local nearCover = __TS__ArraySome( -- 392
		p.room.solids, -- 392
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 392
			math.abs(a.x - solid.x), -- 395
			math.abs(a.x - solid.x - solid.w) -- 395
		) <= 30 end -- 395
	) -- 395
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 395
		slot = "child_knock" -- 398
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 398
		slot = "child_offer" -- 401
	elseif isControlled and p.ticks < self.throwUntil then -- 401
		slot = "child_throw" -- 403
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 403
		slot = "child_aim" -- 405
	elseif isControlled and p.gripping then -- 405
		slot = "child_pull" -- 407
		frame = self.cartMoving and step or 0 -- 408
	elseif afraid and p.escort.state == "frozen" then -- 408
		slot = "child_fear" -- 410
		height = height * 0.74 -- 411
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 411
		slot = "child_peek" -- 414
		height = height * 0.83 -- 415
	elseif a.crouch then -- 415
		slot = "child_crouch" -- 417
		frame = speed > 8 and step or 0 -- 418
	elseif speed > 8 then -- 418
		slot = "child_run" -- 420
		frame = step -- 421
	end -- 421
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 423
	if assets:tryPlace( -- 423
		slot, -- 424
		"actor_child", -- 424
		cx, -- 424
		by, -- 424
		W, -- 424
		height, -- 424
		{ -- 424
			facing = facing, -- 425
			frame = frame, -- 425
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 425
		} -- 425
	) then -- 425
		fgDraw:drawEllipse( -- 427
			Vec2(cx, shadowY + 1), -- 427
			W * 0.48, -- 427
			3, -- 427
			Color(12, 11, 13, 125) -- 427
		) -- 427
		if afraid then -- 427
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 429
		end -- 429
		return -- 431
	end -- 431
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 434
	local x = cx + jitter -- 435
	local fullRef = a.crouch and H * 1.35 or H -- 437
	local cw = fullRef * 0.16 -- 438
	fgDraw:drawEllipse( -- 441
		Vec2(x, shadowY + 1), -- 441
		cw * 1.15, -- 441
		3.6, -- 441
		Color(4, 6, 10, 155) -- 441
	) -- 441
	local walking = speed > 6 and a.onGround -- 443
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 444
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 445
	local hipY = by + H * 0.3 -- 448
	local legSwing = stride * cw * 0.85 -- 449
	fgDraw:drawSegment( -- 450
		Vec2(x - 2, hipY), -- 450
		Vec2(x - legSwing, by + 2), -- 450
		math.max(2.6, cw * 0.22), -- 450
		Color(34, 30, 38, 255) -- 450
	) -- 450
	fgDraw:drawSegment( -- 451
		Vec2(x + 2, hipY), -- 451
		Vec2(x + legSwing, by + 2), -- 451
		math.max(2.8, cw * 0.24), -- 451
		Color(52, 46, 56, 255) -- 451
	) -- 451
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 454
	local cloakBotY = by + H * 0.2 -- 455
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 456
	fgDraw:drawPolygon( -- 457
		{ -- 457
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 458
			Vec2(x + cw * 0.92, cloakBotY), -- 459
			Vec2(x + cw * 0.62, cloakTopY), -- 460
			Vec2(x - cw * 0.68, cloakTopY) -- 461
		}, -- 461
		Color(214, 166, 94, 255), -- 462
		1.3, -- 462
		Color(252, 232, 192, 225) -- 462
	) -- 462
	fgDraw:drawPolygon( -- 463
		{ -- 463
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 464
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 465
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 466
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 467
		}, -- 467
		Color(148, 108, 56, 215) -- 468
	) -- 468
	fgDraw:drawSegment( -- 469
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 469
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 469
		1.8, -- 469
		toColor(PALETTE.amberCore, 200) -- 469
	) -- 469
	local scarfY = cloakTopY - 2 -- 472
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 473
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 474
	local sendX = x - f * cw * 1.65 + cloakDrag -- 475
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 476
	fgDraw:drawQuadraticBezier( -- 477
		Vec2(x - f * cw * 0.3, scarfY), -- 477
		Vec2(smidX, smidY), -- 477
		Vec2(sendX, sendY), -- 477
		2.8, -- 477
		toColor(PALETTE.amberCore, 235) -- 477
	) -- 477
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 480
	local headX = x + f * (a.crouch and 5 or 2) -- 481
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 482
	fgDraw:drawCircle( -- 483
		Vec2(headX, headY), -- 483
		headR, -- 483
		Color(240, 222, 198, 255) -- 483
	) -- 483
	fgDraw:drawPolygon( -- 485
		{ -- 485
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 486
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 487
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 488
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 489
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 490
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 491
		}, -- 491
		Color(156, 114, 62, 248), -- 492
		1.1, -- 492
		Color(244, 214, 162, 200) -- 492
	) -- 492
	fgGlow:drawDot( -- 494
		Vec2(headX + f * headR * 0.45, headY + 1), -- 494
		2.2, -- 494
		toColor(PALETTE.amberCore) -- 494
	) -- 494
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 497
	if hasCompass then -- 497
		local compX = x + f * cw * 0.65 -- 499
		local compY = by + H * 0.48 -- 500
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 501
		fgGlow:drawDot( -- 502
			Vec2(compX, compY), -- 502
			2.6, -- 502
			toColor(PALETTE.amberCore, 250) -- 502
		) -- 502
		fillRadialGlow( -- 503
			fgGlow, -- 503
			compX, -- 503
			compY, -- 503
			26 * glowPulse, -- 503
			26 * glowPulse, -- 503
			Color(248, 206, 120, 78 * glowPulse), -- 503
			Color(248, 180, 72, 0), -- 503
			14 -- 503
		) -- 503
	end -- 503
	if afraid then -- 503
		self:drawFear(fgGlow, p, x, by + H + 16) -- 507
	end -- 507
	if isControlled and walking and not a.crouch and speed > 100 then -- 507
		local r = 10 + self.animTime * 32 % 24 -- 512
		fgGlow:drawRing( -- 513
			Vec2(x, by + 3), -- 513
			r, -- 513
			r + 1.5, -- 513
			Color(0, 0, 0, 0), -- 513
			1.1, -- 513
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 513
		) -- 513
	end -- 513
end -- 369
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 517
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 518
	do -- 518
		local i = 0 -- 519
		while i < FEAR_MAX do -- 519
			local lit = i < p.escort.fear -- 520
			drawDiamond( -- 521
				fgGlow, -- 521
				x + (i - 1) * 13, -- 521
				y, -- 521
				4, -- 521
				5, -- 521
				toColor(lit and tint or PALETTE.steelDark, 215), -- 522
				1, -- 522
				toColor(tint, lit and 235 or 100) -- 522
			) -- 522
			i = i + 1 -- 519
		end -- 519
	end -- 519
end -- 517
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 526
	local x = cam:sx(e.x + f * 20) -- 527
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 528
	local dx = cam:sx(p.player.x) - x -- 529
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 530
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 531
	do -- 531
		local i = 0 -- 532
		while i < 8 do -- 532
			local a = length * i / 8 -- 533
			local b = length * (i + 1) / 8 -- 534
			fgGlow:drawSegment( -- 535
				Vec2(x + dx * a, y + dy * a), -- 535
				Vec2(x + dx * b, y + dy * b), -- 535
				1.3, -- 536
				Color(220, 120, 88, 210) -- 536
			) -- 536
			i = i + 2 -- 532
		end -- 532
	end -- 532
end -- 526
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 541
	local cx = cam:sx(e.x) -- 550
	local depth = e.depth or 0 -- 551
	local by = cam:sy(e.y, depth) -- 552
	local H = cam:len(e.h) -- 553
	local W = cam:len(e.w) -- 554
	local f = p.player.x >= e.x and 1 or -1 -- 555
	local slot = "enemy_idle" -- 557
	if not e.alive then -- 557
		slot = "enemy_down" -- 559
	elseif e.hitT > 0 then -- 559
		slot = "enemy_hit" -- 561
	elseif e.warnT > 0 then -- 561
		slot = "enemy_aim" -- 563
	end -- 563
	local height = e.alive and H or H * 0.24 -- 565
	if assets:tryPlace( -- 565
		slot, -- 566
		"actor_enemy_" .. tostring(index), -- 566
		cx, -- 566
		by, -- 566
		W, -- 566
		height, -- 566
		{ -- 566
			facing = f, -- 567
			opacity = e.alive and 1 or 0.78, -- 567
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 567
		} -- 567
	) then -- 567
		if e.alive and e.warnT > 0 then -- 567
			self:drawEnemyWarning( -- 570
				fgGlow, -- 570
				e, -- 570
				p, -- 570
				cam, -- 570
				f -- 570
			) -- 570
		end -- 570
		return -- 572
	end -- 572
	if not e.alive then -- 572
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 576
		fgDraw:drawPolygon( -- 577
			{ -- 577
				Vec2(cx - H * 0.3, by), -- 578
				Vec2(cx + H * 0.28, by), -- 579
				Vec2(cx + H * 0.2, by + H * 0.14), -- 580
				Vec2(cx - H * 0.24, by + H * 0.11) -- 581
			}, -- 581
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 582
		) -- 582
		if flash > 0 then -- 582
			fillRadialGlow( -- 584
				fgGlow, -- 584
				cx, -- 584
				by + 12, -- 584
				34 * flash, -- 584
				18 * flash, -- 584
				toColor(PALETTE.crimson, 180 * flash), -- 584
				Color(255, 48, 82, 0), -- 584
				12 -- 584
			) -- 584
		end -- 584
		return -- 586
	end -- 586
	local sw = H * 0.112 -- 589
	fgDraw:drawEllipse( -- 590
		Vec2(cx, by + 1), -- 590
		sw * 1.9, -- 590
		4, -- 590
		Color(4, 6, 10, 165) -- 590
	) -- 590
	local hipY = by + H * 0.44 -- 593
	local kneeY = by + H * 0.23 -- 594
	local shY = by + H * 0.79 -- 595
	fgDraw:drawSegment( -- 596
		Vec2(cx - 5, hipY), -- 596
		Vec2(cx - 7, kneeY), -- 596
		H * 0.044, -- 596
		Color(20, 16, 26, 255) -- 596
	) -- 596
	fgDraw:drawSegment( -- 597
		Vec2(cx - 7, kneeY), -- 597
		Vec2(cx - 8, by + 2), -- 597
		H * 0.038, -- 597
		Color(20, 16, 26, 255) -- 597
	) -- 597
	fgDraw:drawSegment( -- 598
		Vec2(cx + 5, hipY), -- 598
		Vec2(cx + 7, kneeY), -- 598
		H * 0.046, -- 598
		Color(28, 22, 36, 255) -- 598
	) -- 598
	fgDraw:drawSegment( -- 599
		Vec2(cx + 7, kneeY), -- 599
		Vec2(cx + 8, by + 2), -- 599
		H * 0.04, -- 599
		Color(28, 22, 36, 255) -- 599
	) -- 599
	fgDraw:drawPolygon( -- 601
		{ -- 601
			Vec2(cx - sw * 0.68, hipY), -- 602
			Vec2(cx + sw * 0.68, hipY), -- 603
			Vec2(cx + sw * 1.12, shY), -- 604
			Vec2(cx - sw * 1.12, shY) -- 605
		}, -- 605
		Color(111, 68, 55, 255), -- 606
		1.3, -- 606
		Color(143, 101, 66, 220) -- 606
	) -- 606
	fgDraw:drawPolygon( -- 607
		{ -- 607
			Vec2(cx - sw * 1.26, shY - 6), -- 608
			Vec2(cx + sw * 1.26, shY - 6), -- 609
			Vec2(cx + sw * 0.96, shY + 5), -- 610
			Vec2(cx - sw * 0.96, shY + 5) -- 611
		}, -- 611
		Color(98, 82, 62, 255) -- 612
	) -- 612
	local headR = H * 0.086 -- 614
	local headY = shY + headR * 1.32 -- 615
	fgDraw:drawCircle( -- 616
		Vec2(cx, headY), -- 616
		headR * 0.82, -- 616
		Color(187, 142, 103, 255) -- 616
	) -- 616
	fgDraw:drawPolygon( -- 617
		{ -- 617
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 618
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 619
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 620
		}, -- 620
		Color(136, 105, 65, 255), -- 621
		1.1, -- 621
		Color(177, 145, 91, 220) -- 621
	) -- 621
	local gunX = cx + f * H * 0.34 -- 623
	local gunY = by + H * 0.69 -- 624
	fgDraw:drawSegment( -- 625
		Vec2(cx - f * 6, gunY - 2), -- 625
		Vec2(gunX, gunY), -- 625
		2.8, -- 625
		Color(118, 87, 61, 255) -- 625
	) -- 625
	if e.warnT > 0 then -- 625
		self:drawEnemyWarning( -- 627
			fgGlow, -- 627
			e, -- 627
			p, -- 627
			cam, -- 627
			f -- 627
		) -- 627
	end -- 627
end -- 541
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 632
	local s = p.room.scavenger -- 639
	if s == nil then -- 639
		return -- 641
	end -- 641
	local cx = cam:sx(p.scavX) -- 643
	local by = cam:sy(s.y) -- 644
	local H = cam:len(s.h) -- 645
	local W = cam:len(26) -- 646
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 647
	local alert = p.scavChase or p.scavSee > 0 -- 650
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 651
	local eyeY = by + H * 0.8 -- 652
	local coneLen = cam:len(alert and 155 or 115) -- 653
	fgGlow:drawVertices({ -- 654
		{ -- 655
			Vec2(cx + f * 6, eyeY), -- 655
			toColor(coneCol, alert and 78 or 34) -- 655
		}, -- 655
		{ -- 656
			Vec2(cx + f * coneLen, by + H * 1.05), -- 656
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 656
		}, -- 656
		{ -- 657
			Vec2(cx + f * coneLen, by + 4), -- 657
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 657
		} -- 657
	}) -- 657
	local frame = 0 -- 660
	if p.scavState == "turn" then -- 660
		frame = 2 -- 662
	elseif p.scavState == "chase" then -- 662
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 664
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 664
		frame = math.floor(self.animTime * 8) % 2 -- 666
	end -- 666
	if assets:tryPlace( -- 666
		"scavenger", -- 668
		"actor_scav", -- 668
		cx, -- 668
		by, -- 668
		W, -- 668
		H, -- 668
		{facing = f, frame = frame, layer = 3} -- 668
	) then -- 668
		return -- 669
	end -- 669
	fgDraw:drawEllipse( -- 672
		Vec2(cx, by + 1), -- 672
		W * 0.62, -- 672
		4, -- 672
		Color(4, 6, 10, 155) -- 672
	) -- 672
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 673
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 674
	fgDraw:drawSegment( -- 676
		Vec2(cx - 4, by + H * 0.4), -- 676
		Vec2(cx - stride, by + 2), -- 676
		W * 0.16, -- 676
		Color(32, 30, 28, 255) -- 676
	) -- 676
	fgDraw:drawSegment( -- 677
		Vec2(cx + 4, by + H * 0.4), -- 677
		Vec2(cx + stride, by + 2), -- 677
		W * 0.16, -- 677
		Color(44, 40, 36, 255) -- 677
	) -- 677
	fgDraw:drawPolygon( -- 679
		{ -- 679
			Vec2(cx - W * 0.45, by + H * 0.25), -- 680
			Vec2(cx + W * 0.42, by + H * 0.25), -- 681
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 682
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 683
		}, -- 683
		Color(56, 52, 46, 255), -- 684
		1.2, -- 684
		Color(128, 118, 100, 180) -- 684
	) -- 684
	local headX = cx + f * 5 -- 686
	local headY = by + H * 0.88 -- 687
	fgDraw:drawCircle( -- 688
		Vec2(headX, headY), -- 688
		W * 0.3, -- 688
		Color(42, 38, 34, 255) -- 688
	) -- 688
	fgGlow:drawDot( -- 689
		Vec2(headX + f * 6, headY), -- 689
		3, -- 689
		toColor(coneCol, 245) -- 689
	) -- 689
	local indY = by + H + 18 -- 692
	if p.scavChase then -- 692
		drawDiamond( -- 694
			fgGlow, -- 694
			cx, -- 694
			indY, -- 694
			9, -- 694
			12, -- 694
			toColor(PALETTE.crimson, 240), -- 694
			1.5, -- 694
			toColor(PALETTE.crimsonCore) -- 694
		) -- 694
	elseif p.scavSee > 0 then -- 694
		local frac = math.min(1, p.scavSee / 24) -- 696
		fgGlow:drawArc( -- 697
			Vec2(cx, indY), -- 697
			11, -- 697
			90, -- 697
			90 - 360 * frac, -- 697
			2.4, -- 697
			toColor(PALETTE.crimson, 235) -- 697
		) -- 697
		fgGlow:drawDot( -- 698
			Vec2(cx, indY), -- 698
			3, -- 698
			toColor(PALETTE.amber) -- 698
		) -- 698
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 698
		drawDiamond( -- 700
			fgGlow, -- 700
			cx, -- 700
			indY, -- 700
			6, -- 700
			8, -- 700
			toColor(PALETTE.amber, 220) -- 700
		) -- 700
	end -- 700
end -- 632
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 705
	local cx = cam:sx(p.dogX) -- 712
	local by = cam:sy(0) -- 713
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 714
	local W = cam:len(42) -- 715
	local H = cam:len(34) -- 716
	local frame = 0 -- 718
	if p.dogState == "ear" then -- 718
		frame = 1 -- 720
	elseif p.dogState == "sniff" then -- 720
		frame = 3 -- 722
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 722
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 724
	end -- 724
	if assets:tryPlace( -- 724
		"dog", -- 726
		"actor_dog", -- 726
		cx, -- 726
		by, -- 726
		W, -- 726
		H, -- 726
		{facing = f, frame = frame, layer = 3} -- 726
	) then -- 726
		return -- 727
	end -- 727
	fgDraw:drawEllipse( -- 730
		Vec2(cx, by + 1), -- 730
		W * 0.56, -- 730
		3.5, -- 730
		Color(4, 8, 10, 155) -- 730
	) -- 730
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 731
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 732
	fgDraw:drawSegment( -- 735
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 735
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 735
		2.8, -- 735
		Color(26, 30, 34, 255) -- 735
	) -- 735
	fgDraw:drawSegment( -- 736
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 736
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 736
		2.8, -- 736
		Color(36, 40, 44, 255) -- 736
	) -- 736
	fgDraw:drawPolygon( -- 738
		{ -- 738
			Vec2(cx - W * 0.42, by + H * 0.36), -- 739
			Vec2(cx + W * 0.38, by + H * 0.42), -- 740
			Vec2(cx + W * 0.34, by + H * 0.78), -- 741
			Vec2(cx - W * 0.38, by + H * 0.72) -- 742
		}, -- 742
		Color(38, 42, 48, 255), -- 743
		1.2, -- 743
		Color(102, 118, 126, 175) -- 743
	) -- 743
	local hx = cx + f * W * 0.42 -- 744
	local hy = by + H * 0.84 -- 745
	fgDraw:drawPolygon( -- 746
		{ -- 746
			Vec2(hx - f * 8, hy - 6), -- 747
			Vec2(hx + f * 12, hy - 2), -- 748
			Vec2(hx + f * 4, hy + 8), -- 749
			Vec2(hx - f * 6, hy + 14) -- 750
		}, -- 750
		Color(44, 48, 54, 255) -- 751
	) -- 751
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 753
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 754
	fgGlow:drawDot( -- 755
		Vec2(hx + f * 4, hy + 2), -- 755
		2.8, -- 755
		toColor(eyeCol, 250) -- 755
	) -- 755
	fillRadialGlow( -- 756
		fgGlow, -- 756
		hx + f * 4, -- 756
		hy + 2, -- 756
		16, -- 756
		16, -- 756
		toColor(eyeCol, alert and 135 or 70), -- 756
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 756
		12 -- 756
	) -- 756
	if alert then -- 756
		local r = 12 + self.animTime * 42 % 24 -- 759
		fgGlow:drawArc( -- 760
			Vec2(hx, hy + 12), -- 760
			r, -- 760
			35, -- 760
			145, -- 760
			1.8, -- 760
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 760
		) -- 760
	end -- 760
end -- 705
return ____exports -- 705