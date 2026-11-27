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
____exports.ActorsRenderer = __TS__Class() -- 23
local ActorsRenderer = ____exports.ActorsRenderer -- 23
ActorsRenderer.name = "ActorsRenderer" -- 23
function ActorsRenderer.prototype.____constructor(self) -- 23
	self.ghosts = {} -- 24
	self.ghostCooldown = 0 -- 25
	self.animTime = 0 -- 26
	self.previousHp = 3 -- 27
	self.previousAxle = 0 -- 28
	self.cartMoving = false -- 29
	self.previousBottle = false -- 30
	self.hitUntil = -1 -- 32
	self.throwUntil = -1 -- 33
	self.shotUntil = -1 -- 34
end -- 23
function ActorsRenderer.prototype.reset(self, p) -- 36
	self.ghosts = {} -- 37
	self.ghostCooldown = 0 -- 38
	self.animTime = 0 -- 39
	self.previousHp = p.hp -- 40
	self.previousAxle = p.cartAxle -- 41
	self.cartMoving = false -- 42
	self.previousBottle = p.hasBottle -- 43
	self.previousTrace = p.trace -- 44
	self.hitUntil = -1 -- 45
	self.throwUntil = -1 -- 46
	self.shotUntil = -1 -- 47
end -- 36
function ActorsRenderer.prototype.update(self, dt, p) -- 51
	self.animTime = self.animTime + dt -- 52
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 53
		self.hitUntil = p.ticks + 14 -- 54
	end -- 54
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 56
		self.throwUntil = p.ticks + 12 -- 57
	end -- 57
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 59
		self.shotUntil = p.ticks + 7 -- 60
	end -- 60
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 62
	self.previousAxle = p.cartAxle -- 63
	self.previousHp = p.hp -- 64
	self.previousBottle = p.hasBottle -- 65
	self.previousTrace = p.trace -- 66
	if not p.childMode and p.player.rollT > 0 then -- 68
		self.ghostCooldown = self.ghostCooldown - dt -- 69
		if self.ghostCooldown <= 0 then -- 70
			local ____self_ghosts_0 = self.ghosts -- 71
			____self_ghosts_0[#____self_ghosts_0 + 1] = { -- 71
				x = p.player.x, -- 72
				y = p.player.y, -- 73
				depth = p.player.depth, -- 74
				h = p.player.h, -- 75
				facing = p.player.facing, -- 76
				life = 0.28, -- 77
				maxLife = 0.28, -- 78
				isRoll = true -- 79
			} -- 79
			self.ghostCooldown = 0.036 -- 81
		end -- 81
	else -- 81
		self.ghostCooldown = 0 -- 84
	end -- 84
	local write = 0 -- 88
	local i = 0 -- 89
	do -- 89
		i = 0 -- 90
		while i < #self.ghosts do -- 90
			local g = self.ghosts[i + 1] -- 91
			g.life = g.life - dt -- 92
			if g.life > 0 then -- 93
				self.ghosts[write + 1] = g -- 94
				write = write + 1 -- 95
			end -- 95
			i = i + 1 -- 90
		end -- 90
	end -- 90
	__TS__ArraySetLength(self.ghosts, write) -- 98
end -- 51
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 101
	if suppressPartner == nil then -- 107
		suppressPartner = false -- 107
	end -- 107
	self:drawAfterimages(fgGlow, cam) -- 110
	local i = 0 -- 113
	do -- 113
		i = 0 -- 114
		while i < #p.enemies do -- 114
			self:drawEnemy( -- 115
				fgDraw, -- 115
				fgGlow, -- 115
				assets, -- 115
				p.enemies[i + 1], -- 115
				i, -- 115
				p, -- 115
				cam -- 115
			) -- 115
			i = i + 1 -- 114
		end -- 114
	end -- 114
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 119
		self:drawScavenger( -- 120
			fgDraw, -- 120
			fgGlow, -- 120
			assets, -- 120
			p, -- 120
			cam -- 120
		) -- 120
	end -- 120
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 124
		self:drawDog( -- 125
			fgDraw, -- 125
			fgGlow, -- 125
			assets, -- 125
			p, -- 125
			cam -- 125
		) -- 125
	end -- 125
	if p.partner.alive and not suppressPartner then -- 129
		local partnerIsChild = p.partner.w <= 28 -- 130
		if partnerIsChild then -- 131
			self:drawXiaoman( -- 132
				fgDraw, -- 132
				fgGlow, -- 132
				assets, -- 132
				p.partner, -- 132
				p, -- 132
				cam, -- 132
				false -- 132
			) -- 132
		else -- 132
			self:drawZhouShu( -- 134
				fgDraw, -- 134
				fgGlow, -- 134
				assets, -- 134
				p.partner, -- 134
				p, -- 134
				cam, -- 134
				false -- 134
			) -- 134
		end -- 134
	end -- 134
	if p.player.alive then -- 139
		if p.childMode then -- 140
			self:drawXiaoman( -- 141
				fgDraw, -- 141
				fgGlow, -- 141
				assets, -- 141
				p.player, -- 141
				p, -- 141
				cam, -- 141
				true -- 141
			) -- 141
		else -- 141
			self:drawZhouShu( -- 143
				fgDraw, -- 143
				fgGlow, -- 143
				assets, -- 143
				p.player, -- 143
				p, -- 143
				cam, -- 143
				true -- 143
			) -- 143
		end -- 143
	end -- 143
end -- 101
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 149
	local i = 0 -- 150
	do -- 150
		i = 0 -- 151
		while i < #self.ghosts do -- 151
			local g = self.ghosts[i + 1] -- 152
			local k = math.max( -- 153
				0, -- 153
				math.min(1, g.life / g.maxLife) -- 153
			) -- 153
			local spread = 1 - k -- 154
			local cx = cam:sx(g.x) -- 155
			local by = cam:sy(g.y, g.depth) -- 156
			local f = g.facing -- 157
			local rBase = cam:len(6 + spread * 9) -- 158
			fgGlow:drawCircle( -- 160
				Vec2( -- 161
					cx - f * cam:len(6 + spread * 10), -- 161
					by + cam:len(4 + spread * 5) -- 161
				), -- 161
				rBase, -- 162
				Color( -- 163
					156, -- 163
					144, -- 163
					124, -- 163
					math.floor(78 * k + 0.5) -- 163
				) -- 163
			) -- 163
			fgGlow:drawCircle( -- 165
				Vec2( -- 166
					cx - f * cam:len(14 + spread * 14), -- 166
					by + cam:len(8 + spread * 8) -- 166
				), -- 166
				rBase * 0.72, -- 167
				Color( -- 168
					186, -- 168
					174, -- 168
					152, -- 168
					math.floor(54 * k + 0.5) -- 168
				) -- 168
			) -- 168
			i = i + 1 -- 151
		end -- 151
	end -- 151
end -- 149
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 174
	local half = a.w * 0.5 -- 175
	local g = 0 -- 176
	local i = 0 -- 177
	do -- 177
		i = 0 -- 178
		while i < #p.room.floors do -- 178
			local f = p.room.floors[i + 1] -- 179
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 180
				g = f.y -- 181
			end -- 181
			i = i + 1 -- 178
		end -- 178
	end -- 178
	do -- 178
		i = 0 -- 184
		while i < #p.boxes do -- 184
			do -- 184
				local b = p.boxes[i + 1] -- 185
				if b.broken == true or b.hidden == true or b.soft == true then -- 186
					goto __continue33 -- 187
				end -- 187
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 189
					g = b.y1 -- 191
				end -- 191
			end -- 191
			::__continue33:: -- 191
			i = i + 1 -- 184
		end -- 184
	end -- 184
	return g -- 194
end -- 174
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 198
	local cx = cam:sx(a.x) -- 207
	local by = cam:sy(a.y, a.depth) -- 208
	local depthEnabled = p.room.depth ~= nil -- 209
	local shadowY = not a.onGround and cam:sy( -- 210
		self:supportGroundY(p, a), -- 210
		a.depth -- 210
	) or by -- 210
	local H = cam:len(a.h) -- 211
	local W = cam:len(a.w) -- 212
	local f = a.facing -- 213
	local speed = math.max( -- 214
		math.abs(a.vx), -- 214
		math.abs(a.depthSpeed) -- 214
	) -- 214
	local slot = "soldier_idle" -- 216
	local height = H -- 217
	local frame = 0 -- 218
	local facing = f -- 219
	local step = math.floor(self.animTime * 10) -- 220
	if isControlled and p.ticks < self.hitUntil then -- 221
		slot = "soldier_hit" -- 222
	elseif a.rollT > 0 then -- 223
		slot = "soldier_roll" -- 224
		height = height * 0.59 -- 225
	elseif p.phase == "prologue-give" then -- 226
		slot = "soldier_offer" -- 227
		height = height * 0.75 -- 228
		facing = p.partner.x >= a.x and 1 or -1 -- 229
	elseif isControlled and p.gripping then -- 230
		slot = "soldier_push" -- 231
		frame = self.cartMoving and step or 0 -- 232
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 233
		height = height * 0.91 -- 234
	elseif isControlled and p.escort.state == "calming" then -- 235
		slot = "soldier_knock" -- 236
		local calm = p.escort.calmTick -- 237
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 238
		height = height * 0.76 -- 239
	else -- 239
		local ____temp_3 = p.phase == "gate-send" -- 240
		if ____temp_3 then -- 240
			local ____opt_1 = p.room.story -- 240
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 240
		end -- 240
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 240
			slot = "soldier_hold" -- 242
			height = height * 1.11 -- 243
		elseif isControlled and p.ticks < self.shotUntil then -- 244
			local running = speed > 8 -- 245
			slot = running and "soldier_fire_move" or "soldier_fire" -- 246
			frame = running and step or 0 -- 247
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 248
		elseif a.covered or isControlled and p.coverHug then -- 249
			slot = "soldier_cover" -- 250
			height = height * 0.77 -- 251
		elseif speed > 8 then -- 252
			slot = "soldier_run" -- 253
			frame = step -- 254
		end -- 254
	end -- 254
	if assets:tryPlace( -- 256
		slot, -- 256
		"actor_soldier", -- 256
		cx, -- 256
		by, -- 256
		W, -- 256
		height, -- 256
		{ -- 256
			facing = facing, -- 257
			frame = frame, -- 257
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 257
		} -- 257
	) then -- 257
		fgDraw:drawEllipse( -- 259
			Vec2(cx, shadowY + 1), -- 259
			W * 0.54, -- 259
			4, -- 259
			Color(12, 11, 13, 145) -- 259
		) -- 259
		return -- 260
	end -- 260
	fgDraw:drawEllipse( -- 264
		Vec2(cx, shadowY + 1), -- 264
		H * 0.24, -- 264
		4.5, -- 264
		Color(3, 5, 10, 175) -- 264
	) -- 264
	local walking = speed > 10 and a.onGround -- 266
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 267
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 268
	local calming = not p.childMode and p.escort.state == "calming" -- 269
	local rolling = a.rollT > 0 -- 270
	local crouching = a.covered or calming or rolling -- 271
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 274
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 275
	local sw = H * 0.115 -- 276
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 279
	local kneeY = by + bodyH * 0.23 -- 280
	local stepX = stride * H * 0.15 -- 281
	local legDark = Color(14, 21, 34, 255) -- 282
	local legFront = Color(26, 38, 58, 255) -- 283
	local bkX = cx - f * 4 - stepX * 0.5 -- 285
	local bfX = cx - f * 8 - stepX -- 286
	fgDraw:drawSegment( -- 287
		Vec2(cx - f * 3, hipY), -- 287
		Vec2(bkX, kneeY), -- 287
		H * 0.044, -- 287
		legDark -- 287
	) -- 287
	fgDraw:drawSegment( -- 288
		Vec2(bkX, kneeY), -- 288
		Vec2(bfX, by + 3), -- 288
		H * 0.038, -- 288
		legDark -- 288
	) -- 288
	local fkX = cx + f * 6 + stepX * 0.55 -- 290
	local ffX = cx + f * 7 + stepX -- 291
	fgDraw:drawSegment( -- 292
		Vec2(cx + f * 3, hipY), -- 292
		Vec2(fkX, kneeY), -- 292
		H * 0.048, -- 292
		legFront -- 292
	) -- 292
	fgDraw:drawSegment( -- 293
		Vec2(fkX, kneeY), -- 293
		Vec2(ffX, by + 3), -- 293
		H * 0.042, -- 293
		legFront -- 293
	) -- 293
	fgDraw:drawSegment( -- 295
		Vec2(ffX - f * 2, by + 3), -- 295
		Vec2(ffX + f * 9, by + 3), -- 295
		3.4, -- 295
		Color(42, 60, 86, 255) -- 295
	) -- 295
	local shY = by + bodyH * 0.8 + bob -- 298
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 299
	fgDraw:drawPolygon( -- 300
		{ -- 300
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 301
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 302
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 303
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 304
		}, -- 304
		Color(16, 26, 42, 248), -- 305
		1.2, -- 305
		Color(64, 118, 164, 195) -- 305
	) -- 305
	fgDraw:drawPolygon( -- 308
		{ -- 308
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 309
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 310
			Vec2(cx + sw * 1.05 + lean, shY), -- 311
			Vec2(cx - sw * 0.98 + lean, shY) -- 312
		}, -- 312
		Color(24, 38, 60, 255), -- 313
		1.3, -- 313
		toColor(PALETTE.rimSilver, 190) -- 313
	) -- 313
	fgDraw:drawSegment( -- 315
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 316
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 317
		2.4, -- 318
		Color(173, 155, 125, 225) -- 319
	) -- 319
	fgDraw:drawPolygon( -- 321
		{ -- 321
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 322
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 323
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 324
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 325
		}, -- 325
		Color(99, 105, 103, 248) -- 326
	) -- 326
	local headR = H * 0.088 -- 329
	local headX = cx + lean + f * 3 -- 330
	local headY = shY + headR * 1.35 -- 331
	fgDraw:drawCircle( -- 332
		Vec2(headX, headY - headR * 0.12), -- 332
		headR * 0.86, -- 332
		Color(181, 139, 106, 255) -- 332
	) -- 332
	fgDraw:drawEllipse( -- 333
		Vec2(headX, headY + headR * 0.5), -- 333
		headR * 1.12, -- 333
		headR * 0.72, -- 333
		Color(66, 73, 76, 255) -- 333
	) -- 333
	fgDraw:drawSegment( -- 334
		Vec2(headX - headR, headY + 1), -- 334
		Vec2(headX + headR, headY + 1), -- 334
		1.6, -- 335
		Color(97, 103, 101, 255) -- 335
	) -- 335
	fgDraw:drawSegment( -- 336
		Vec2(headX, headY + headR), -- 336
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 336
		1.6, -- 337
		Color(177, 78, 51, 255) -- 337
	) -- 337
	if isControlled and not calming and not rolling and not p.gripping then -- 340
		local gunPivotX = cx + lean + f * sw * 0.35 -- 341
		local gunPivotY = shY - bodyH * 0.1 -- 342
		local aimDx = f -- 343
		local aimDy = 0 -- 344
		if p.aimX > 0 or p.aimY > 0 then -- 345
			aimDx = p.aimX - gunPivotX -- 346
			aimDy = p.aimY - gunPivotY -- 347
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 348
			if dLen > 4 then -- 349
				aimDx = aimDx / dLen -- 350
				aimDy = aimDy / dLen -- 351
			end -- 351
		end -- 351
		local barrelLen = H * 0.34 -- 354
		local tipX = gunPivotX + aimDx * barrelLen -- 355
		local tipY = gunPivotY + aimDy * barrelLen -- 356
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 357
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 358
		fgDraw:drawSegment( -- 360
			Vec2(cx + lean, shY - 5), -- 360
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 360
			3.6, -- 360
			Color(26, 40, 62, 255) -- 360
		) -- 360
		fgDraw:drawSegment( -- 361
			Vec2(stockX, stockY), -- 361
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 361
			3.8, -- 361
			Color(105, 71, 50, 255) -- 361
		) -- 361
		fgDraw:drawSegment( -- 362
			Vec2(gunPivotX, gunPivotY), -- 362
			Vec2(tipX, tipY), -- 362
			1.8, -- 362
			Color(145, 140, 128, 245) -- 362
		) -- 362
	elseif calming then -- 363
		fgDraw:drawSegment( -- 364
			Vec2(cx + lean, shY - 6), -- 364
			Vec2(cx + f * sw * 2.1, shY - 14), -- 364
			3, -- 364
			Color(196, 222, 240, 235) -- 364
		) -- 364
		fgGlow:drawDot( -- 365
			Vec2(cx + f * sw * 2.15, shY - 14), -- 365
			3.6, -- 365
			toColor(PALETTE.amber, 225) -- 365
		) -- 365
	end -- 365
end -- 198
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 371
	local cx = cam:sx(a.x) -- 380
	local by = cam:sy(a.y, a.depth) -- 381
	local depthEnabled = p.room.depth ~= nil -- 382
	local shadowY = not a.onGround and cam:sy( -- 383
		self:supportGroundY(p, a), -- 383
		a.depth -- 383
	) or by -- 383
	local H = cam:len(a.h) -- 384
	local W = cam:len(a.w) -- 385
	local f = a.facing -- 386
	local speed = math.max( -- 387
		math.abs(a.vx), -- 387
		math.abs(a.depthSpeed) -- 387
	) -- 387
	local afraid = not isControlled and p.escort.fear > 0 -- 389
	local slot = "child_idle" -- 390
	local height = H -- 391
	local frame = 0 -- 392
	local step = math.floor(self.animTime * 10) -- 393
	local nearCover = __TS__ArraySome( -- 394
		p.room.solids, -- 394
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 394
			math.abs(a.x - solid.x), -- 397
			math.abs(a.x - solid.x - solid.w) -- 397
		) <= 30 end -- 397
	) -- 397
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 399
		slot = "child_knock" -- 400
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 401
		slot = "child_offer" -- 403
	elseif isControlled and p.ticks < self.throwUntil then -- 404
		slot = "child_throw" -- 405
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 406
		slot = "child_aim" -- 407
	elseif isControlled and p.gripping then -- 408
		slot = "child_pull" -- 409
		frame = self.cartMoving and step or 0 -- 410
	elseif afraid and p.escort.state == "frozen" then -- 411
		slot = "child_fear" -- 412
		height = height * 0.74 -- 413
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 414
		slot = "child_peek" -- 416
		height = height * 0.83 -- 417
	elseif a.crouch then -- 418
		slot = "child_crouch" -- 419
		frame = speed > 8 and step or 0 -- 420
	elseif speed > 8 then -- 421
		slot = "child_run" -- 422
		frame = step -- 423
	end -- 423
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 425
	if assets:tryPlace( -- 426
		slot, -- 426
		"actor_child", -- 426
		cx, -- 426
		by, -- 426
		W, -- 426
		height, -- 426
		{ -- 426
			facing = facing, -- 427
			frame = frame, -- 427
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 427
		} -- 427
	) then -- 427
		fgDraw:drawEllipse( -- 429
			Vec2(cx, shadowY + 1), -- 429
			W * 0.48, -- 429
			3, -- 429
			Color(12, 11, 13, 125) -- 429
		) -- 429
		if afraid then -- 430
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 431
		end -- 431
		return -- 433
	end -- 433
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 436
	local x = cx + jitter -- 437
	local fullRef = a.crouch and H * 1.35 or H -- 439
	local cw = fullRef * 0.16 -- 440
	fgDraw:drawEllipse( -- 443
		Vec2(x, shadowY + 1), -- 443
		cw * 1.15, -- 443
		3.6, -- 443
		Color(4, 6, 10, 155) -- 443
	) -- 443
	local walking = speed > 6 and a.onGround -- 445
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 446
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 447
	local hipY = by + H * 0.3 -- 450
	local legSwing = stride * cw * 0.85 -- 451
	fgDraw:drawSegment( -- 452
		Vec2(x - 2, hipY), -- 452
		Vec2(x - legSwing, by + 2), -- 452
		math.max(2.6, cw * 0.22), -- 452
		Color(34, 30, 38, 255) -- 452
	) -- 452
	fgDraw:drawSegment( -- 453
		Vec2(x + 2, hipY), -- 453
		Vec2(x + legSwing, by + 2), -- 453
		math.max(2.8, cw * 0.24), -- 453
		Color(52, 46, 56, 255) -- 453
	) -- 453
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 456
	local cloakBotY = by + H * 0.2 -- 457
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 458
	fgDraw:drawPolygon( -- 459
		{ -- 459
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 460
			Vec2(x + cw * 0.92, cloakBotY), -- 461
			Vec2(x + cw * 0.62, cloakTopY), -- 462
			Vec2(x - cw * 0.68, cloakTopY) -- 463
		}, -- 463
		Color(214, 166, 94, 255), -- 464
		1.3, -- 464
		Color(252, 232, 192, 225) -- 464
	) -- 464
	fgDraw:drawPolygon( -- 465
		{ -- 465
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 466
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 467
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 468
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 469
		}, -- 469
		Color(148, 108, 56, 215) -- 470
	) -- 470
	fgDraw:drawSegment( -- 471
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 471
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 471
		1.8, -- 471
		toColor(PALETTE.amberCore, 200) -- 471
	) -- 471
	local scarfY = cloakTopY - 2 -- 474
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 475
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 476
	local sendX = x - f * cw * 1.65 + cloakDrag -- 477
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 478
	fgDraw:drawQuadraticBezier( -- 479
		Vec2(x - f * cw * 0.3, scarfY), -- 479
		Vec2(smidX, smidY), -- 479
		Vec2(sendX, sendY), -- 479
		2.8, -- 479
		toColor(PALETTE.amberCore, 235) -- 479
	) -- 479
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 482
	local headX = x + f * (a.crouch and 5 or 2) -- 483
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 484
	fgDraw:drawCircle( -- 485
		Vec2(headX, headY), -- 485
		headR, -- 485
		Color(232, 212, 188, 255) -- 485
	) -- 485
	fgDraw:drawCircle( -- 486
		Vec2(headX - f * headR * 0.45, headY + headR * 0.72), -- 486
		headR * 0.42, -- 486
		Color(36, 30, 32, 250) -- 486
	) -- 486
	fgDraw:drawCircle( -- 487
		Vec2(headX + f * headR * 0.15, headY + headR * 0.82), -- 487
		headR * 0.36, -- 487
		Color(36, 30, 32, 250) -- 487
	) -- 487
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 490
	if hasCompass then -- 491
		local compX = x + f * cw * 0.65 -- 492
		local compY = by + H * 0.48 -- 493
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 494
		fgGlow:drawDot( -- 495
			Vec2(compX, compY), -- 495
			2.6, -- 495
			toColor(PALETTE.amberCore, 250) -- 495
		) -- 495
		fillRadialGlow( -- 496
			fgGlow, -- 496
			compX, -- 496
			compY, -- 496
			26 * glowPulse, -- 496
			26 * glowPulse, -- 496
			Color(248, 206, 120, 78 * glowPulse), -- 496
			Color(248, 180, 72, 0), -- 496
			14 -- 496
		) -- 496
	end -- 496
	if afraid then -- 499
		self:drawFear(fgGlow, p, x, by + H + 16) -- 500
	end -- 500
	if isControlled and walking and not a.crouch and speed > 100 then -- 504
		local r = 10 + self.animTime * 32 % 24 -- 505
		fgGlow:drawRing( -- 506
			Vec2(x, by + 3), -- 506
			r, -- 506
			r + 1.5, -- 506
			Color(0, 0, 0, 0), -- 506
			1.1, -- 506
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 506
		) -- 506
	end -- 506
end -- 371
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 510
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 511
	do -- 511
		local i = 0 -- 512
		while i < FEAR_MAX do -- 512
			local lit = i < p.escort.fear -- 513
			drawDiamond( -- 514
				fgGlow, -- 514
				x + (i - 1) * 13, -- 514
				y, -- 514
				4, -- 514
				5, -- 514
				toColor(lit and tint or PALETTE.steelDark, 215), -- 515
				1, -- 515
				toColor(tint, lit and 235 or 100) -- 515
			) -- 515
			i = i + 1 -- 512
		end -- 512
	end -- 512
end -- 510
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 519
	local x = cam:sx(e.x + f * 20) -- 520
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 521
	local dx = cam:sx(p.player.x) - x -- 522
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 523
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 524
	do -- 524
		local i = 0 -- 525
		while i < 8 do -- 525
			local a = length * i / 8 -- 526
			local b = length * (i + 1) / 8 -- 527
			fgGlow:drawSegment( -- 528
				Vec2(x + dx * a, y + dy * a), -- 528
				Vec2(x + dx * b, y + dy * b), -- 528
				1.3, -- 529
				Color(220, 120, 88, 210) -- 529
			) -- 529
			i = i + 2 -- 525
		end -- 525
	end -- 525
end -- 519
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 534
	local cx = cam:sx(e.x) -- 543
	local depth = e.depth or 0 -- 544
	local by = cam:sy(e.y, depth) -- 545
	local H = cam:len(e.h) -- 546
	local W = cam:len(e.w) -- 547
	local f = p.player.x >= e.x and 1 or -1 -- 548
	if e.kind == "target" then -- 551
		if p.room.key == "escort3" then -- 552
			return -- 553
		end -- 553
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 555
		fgDraw:drawEllipse( -- 556
			Vec2(cx, by + 1), -- 556
			W * 0.56, -- 556
			3.6, -- 556
			Color(12, 11, 13, 140) -- 556
		) -- 556
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 557
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 558
		if assets:tryPlacePath( -- 559
			"assets/art/props_ming.clip|target_dummy", -- 559
			"actor_target_" .. tostring(index), -- 559
			cx, -- 559
			by, -- 559
			H * 0.82, -- 559
			H * 0.96, -- 559
			{ -- 559
				anchorX = 0.5, -- 560
				anchorY = 0, -- 561
				preserveAspect = true, -- 562
				angle = angle, -- 563
				color = tint, -- 564
				opacity = e.alive and 1 or 0.76, -- 565
				layer = targetLayer -- 566
			} -- 566
		) then -- 566
			return -- 568
		end -- 568
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 570
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 571
		fgDraw:drawSegment( -- 572
			Vec2( -- 572
				cx - cam:len(9), -- 572
				by -- 572
			), -- 572
			Vec2(cx + lean * 0.4, postTopY), -- 572
			math.max( -- 572
				2, -- 572
				cam:len(3.2) -- 572
			), -- 572
			Color(92, 64, 42, 255) -- 572
		) -- 572
		fgDraw:drawSegment( -- 573
			Vec2( -- 573
				cx + cam:len(9), -- 573
				by -- 573
			), -- 573
			Vec2(cx + lean * 0.4, postTopY), -- 573
			math.max( -- 573
				2, -- 573
				cam:len(3.2) -- 573
			), -- 573
			Color(76, 52, 34, 255) -- 573
		) -- 573
		local discX = cx + lean -- 574
		local discY = by + H * (e.alive and 0.56 or 0.3) -- 575
		local discR = math.max( -- 576
			7, -- 576
			cam:len(13) -- 576
		) -- 576
		local hitTint = e.hitT > 0 or not e.alive -- 577
		fgDraw:drawCircle( -- 578
			Vec2(discX, discY), -- 578
			discR, -- 578
			hitTint and Color(214, 152, 116, 245) or Color(196, 174, 134, 250) -- 578
		) -- 578
		fgDraw:drawRing( -- 579
			Vec2(discX, discY), -- 579
			discR * 0.62, -- 579
			discR * 0.76, -- 579
			Color(0, 0, 0, 0), -- 579
			1.4, -- 579
			Color(62, 46, 34, 230) -- 579
		) -- 579
		fgDraw:drawCircle( -- 580
			Vec2(discX, discY), -- 580
			discR * 0.3, -- 580
			toColor(PALETTE.rouge, hitTint and 255 or 220) -- 580
		) -- 580
		return -- 581
	end -- 581
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 584
	if e.alive and e.hitT <= 0 then -- 586
		local extraClip = "" -- 587
		local extraAnchorX = 0.5 -- 588
		local extraHeight = H * 0.96 -- 589
		local extraTint = Color(255, 255, 255, 255) -- 590
		if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 591
			extraClip = e.warnT > 0 and "enemy_shield_aim" or "enemy_shield_idle" -- 592
			extraAnchorX = e.warnT > 0 and 0.45 or 0.5 -- 593
			extraHeight = H * 0.94 -- 594
			if (e.shieldHp or 2) <= 1 then -- 595
				extraTint = Color(234, 198, 178, 255) -- 596
			end -- 596
		elseif e.kind == "breaker" then -- 598
			local swing = (e.swingT or 0) > 0 or e.warnT > 0 -- 599
			extraClip = swing and "enemy_breaker_aim" or "enemy_breaker_idle" -- 600
			extraAnchorX = swing and 0.52 or 0.38 -- 601
			extraHeight = H * (swing and 0.98 or 0.94) -- 602
		elseif e.kind == "leader" then -- 603
			extraClip = e.warnT > 0 and "enemy_leader_aim" or "enemy_leader_idle" -- 604
			extraAnchorX = e.warnT > 0 and 0.38 or 0.44 -- 605
			extraHeight = H * 1 -- 606
		end -- 606
		if extraClip ~= "" and assets:tryPlacePath( -- 608
			"assets/art/actors_extra.clip|" .. extraClip, -- 609
			"actor_enemy_" .. tostring(index), -- 610
			cx, -- 611
			by, -- 612
			W * 1.8, -- 613
			extraHeight, -- 614
			{ -- 615
				anchorX = extraAnchorX, -- 616
				anchorY = 0, -- 617
				preserveAspect = true, -- 618
				facing = f, -- 619
				color = extraTint, -- 620
				layer = enemyLayer -- 621
			} -- 621
		) then -- 621
			fgDraw:drawEllipse( -- 624
				Vec2(cx, by + 1), -- 624
				W * 0.58, -- 624
				3.8, -- 624
				Color(12, 11, 13, 145) -- 624
			) -- 624
			if e.kind == "breaker" and (e.swingT or 0) > 0 then -- 625
				fgGlow:drawArc( -- 626
					Vec2( -- 626
						cx + f * cam:len(10), -- 626
						by + H * 0.56 -- 626
					), -- 626
					cam:len(18), -- 626
					f > 0 and -40 or 140, -- 626
					f > 0 and 50 or 230, -- 626
					1.8, -- 626
					toColor(PALETTE.rouge, 195) -- 626
				) -- 626
			end -- 626
			if e.warnT > 0 then -- 628
				self:drawEnemyWarning( -- 629
					fgGlow, -- 629
					e, -- 629
					p, -- 629
					cam, -- 629
					f -- 629
				) -- 629
			end -- 629
			return -- 631
		end -- 631
	end -- 631
	local slot = "enemy_idle" -- 635
	if not e.alive then -- 636
		slot = "enemy_down" -- 637
	elseif e.hitT > 0 then -- 638
		slot = "enemy_hit" -- 639
	elseif e.warnT > 0 then -- 640
		slot = "enemy_aim" -- 641
	end -- 641
	local height = e.alive and H or H * 0.24 -- 643
	if assets:tryPlace( -- 644
		slot, -- 644
		"actor_enemy_" .. tostring(index), -- 644
		cx, -- 644
		by, -- 644
		W, -- 644
		height, -- 644
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 644
	) then -- 644
		if e.alive then -- 647
			self:drawEnemyArchetypeGear( -- 648
				fgDraw, -- 648
				fgGlow, -- 648
				e, -- 648
				cx, -- 648
				by, -- 648
				H, -- 648
				f, -- 648
				cam -- 648
			) -- 648
			if e.warnT > 0 then -- 649
				self:drawEnemyWarning( -- 650
					fgGlow, -- 650
					e, -- 650
					p, -- 650
					cam, -- 650
					f -- 650
				) -- 650
			end -- 650
		end -- 650
		return -- 653
	end -- 653
	if not e.alive then -- 656
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 657
		fgDraw:drawPolygon( -- 658
			{ -- 658
				Vec2(cx - H * 0.3, by), -- 659
				Vec2(cx + H * 0.28, by), -- 660
				Vec2(cx + H * 0.2, by + H * 0.14), -- 661
				Vec2(cx - H * 0.24, by + H * 0.11) -- 662
			}, -- 662
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 663
		) -- 663
		if flash > 0 then -- 664
			fillRadialGlow( -- 665
				fgGlow, -- 665
				cx, -- 665
				by + 12, -- 665
				34 * flash, -- 665
				18 * flash, -- 665
				toColor(PALETTE.crimson, 180 * flash), -- 665
				Color(255, 48, 82, 0), -- 665
				12 -- 665
			) -- 665
		end -- 665
		return -- 667
	end -- 667
	local sw = H * 0.112 -- 670
	fgDraw:drawEllipse( -- 671
		Vec2(cx, by + 1), -- 671
		sw * 1.9, -- 671
		4, -- 671
		Color(4, 6, 10, 165) -- 671
	) -- 671
	local hipY = by + H * 0.44 -- 674
	local kneeY = by + H * 0.23 -- 675
	local shY = by + H * 0.79 -- 676
	fgDraw:drawSegment( -- 677
		Vec2(cx - 5, hipY), -- 677
		Vec2(cx - 7, kneeY), -- 677
		H * 0.044, -- 677
		Color(20, 16, 26, 255) -- 677
	) -- 677
	fgDraw:drawSegment( -- 678
		Vec2(cx - 7, kneeY), -- 678
		Vec2(cx - 8, by + 2), -- 678
		H * 0.038, -- 678
		Color(20, 16, 26, 255) -- 678
	) -- 678
	fgDraw:drawSegment( -- 679
		Vec2(cx + 5, hipY), -- 679
		Vec2(cx + 7, kneeY), -- 679
		H * 0.046, -- 679
		Color(28, 22, 36, 255) -- 679
	) -- 679
	fgDraw:drawSegment( -- 680
		Vec2(cx + 7, kneeY), -- 680
		Vec2(cx + 8, by + 2), -- 680
		H * 0.04, -- 680
		Color(28, 22, 36, 255) -- 680
	) -- 680
	fgDraw:drawPolygon( -- 682
		{ -- 682
			Vec2(cx - sw * 0.68, hipY), -- 683
			Vec2(cx + sw * 0.68, hipY), -- 684
			Vec2(cx + sw * 1.12, shY), -- 685
			Vec2(cx - sw * 1.12, shY) -- 686
		}, -- 686
		Color(111, 68, 55, 255), -- 687
		1.3, -- 687
		Color(143, 101, 66, 220) -- 687
	) -- 687
	fgDraw:drawPolygon( -- 688
		{ -- 688
			Vec2(cx - sw * 1.26, shY - 6), -- 689
			Vec2(cx + sw * 1.26, shY - 6), -- 690
			Vec2(cx + sw * 0.96, shY + 5), -- 691
			Vec2(cx - sw * 0.96, shY + 5) -- 692
		}, -- 692
		Color(98, 82, 62, 255) -- 693
	) -- 693
	local headR = H * 0.086 -- 695
	local headY = shY + headR * 1.32 -- 696
	fgDraw:drawCircle( -- 697
		Vec2(cx, headY), -- 697
		headR * 0.82, -- 697
		Color(187, 142, 103, 255) -- 697
	) -- 697
	fgDraw:drawPolygon( -- 698
		{ -- 698
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 699
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 700
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 701
		}, -- 701
		Color(136, 105, 65, 255), -- 702
		1.1, -- 702
		Color(177, 145, 91, 220) -- 702
	) -- 702
	local gunX = cx + f * H * 0.34 -- 704
	local gunY = by + H * 0.69 -- 705
	fgDraw:drawSegment( -- 706
		Vec2(cx - f * 6, gunY - 2), -- 706
		Vec2(gunX, gunY), -- 706
		2.8, -- 706
		Color(118, 87, 61, 255) -- 706
	) -- 706
	self:drawEnemyArchetypeGear( -- 707
		fgDraw, -- 707
		fgGlow, -- 707
		e, -- 707
		cx, -- 707
		by, -- 707
		H, -- 707
		f, -- 707
		cam -- 707
	) -- 707
	if e.warnT > 0 then -- 708
		self:drawEnemyWarning( -- 709
			fgGlow, -- 709
			e, -- 709
			p, -- 709
			cam, -- 709
			f -- 709
		) -- 709
	end -- 709
end -- 534
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, e, cx, by, H, f, cam) -- 714
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 724
		local shX = cx + f * cam:len(13) -- 725
		local shW = math.max( -- 726
			5, -- 726
			cam:len(8) -- 726
		) -- 726
		local shH = H * 0.72 -- 727
		local cracked = (e.shieldHp or 2) <= 1 -- 728
		fgDraw:drawRect( -- 729
			Rect(shX - shW * 0.5, by + H * 0.08, shW, shH), -- 730
			cracked and Color(122, 82, 52, 245) or Color(96, 66, 42, 250), -- 731
			1.3, -- 732
			Color(168, 174, 180, 230) -- 733
		) -- 733
		fgDraw:drawCircle( -- 735
			Vec2(shX, by + H * 0.44), -- 735
			math.max( -- 735
				2.2, -- 735
				cam:len(3.5) -- 735
			), -- 735
			Color(142, 148, 154, 240) -- 735
		) -- 735
		if cracked then -- 736
			fgDraw:drawSegment( -- 737
				Vec2(shX - shW * 0.4, by + H * 0.28), -- 737
				Vec2(shX + shW * 0.4, by + H * 0.58), -- 737
				1.4, -- 737
				Color(24, 18, 16, 235) -- 737
			) -- 737
		end -- 737
	elseif e.kind == "breaker" then -- 739
		local swing = (e.swingT or 0) > 0 -- 740
		local handleX0 = cx - f * cam:len(4) -- 741
		local handleY0 = by + H * 0.44 -- 742
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 743
		local tipY = by + H * (swing and 0.46 or 0.78) -- 744
		fgDraw:drawSegment( -- 745
			Vec2(handleX0, handleY0), -- 745
			Vec2(tipX, tipY), -- 745
			math.max( -- 745
				2.2, -- 745
				cam:len(3) -- 745
			), -- 745
			Color(98, 66, 44, 255) -- 745
		) -- 745
		fgDraw:drawPolygon( -- 746
			{ -- 746
				Vec2( -- 747
					tipX - f * cam:len(3), -- 747
					tipY - cam:len(4) -- 747
				), -- 747
				Vec2( -- 748
					tipX + f * cam:len(9), -- 748
					tipY - cam:len(1) -- 748
				), -- 748
				Vec2( -- 749
					tipX + f * cam:len(7), -- 749
					tipY + cam:len(9) -- 749
				), -- 749
				Vec2( -- 750
					tipX - f * cam:len(2), -- 750
					tipY + cam:len(6) -- 750
				) -- 750
			}, -- 750
			Color(148, 154, 162, 250), -- 751
			1, -- 751
			Color(224, 228, 232, 220) -- 751
		) -- 751
		if swing then -- 752
			fgGlow:drawArc( -- 753
				Vec2( -- 753
					cx + f * cam:len(10), -- 753
					by + H * 0.56 -- 753
				), -- 753
				cam:len(18), -- 753
				f > 0 and -40 or 140, -- 753
				f > 0 and 50 or 230, -- 753
				1.8, -- 753
				toColor(PALETTE.rouge, 195) -- 753
			) -- 753
		end -- 753
	elseif e.kind == "leader" then -- 755
		local topY = by + H * 1.02 -- 757
		fgDraw:drawSegment( -- 758
			Vec2(cx, topY), -- 758
			Vec2( -- 758
				cx - f * cam:len(10), -- 758
				topY + cam:len(9) -- 758
			), -- 758
			2.2, -- 758
			toColor(PALETTE.rouge, 240) -- 758
		) -- 758
		fgDraw:drawDot( -- 759
			Vec2( -- 759
				cx - f * cam:len(10), -- 759
				topY + cam:len(9) -- 759
			), -- 759
			2.6, -- 759
			toColor(PALETTE.crimsonCore, 235) -- 759
		) -- 759
	end -- 759
end -- 714
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 764
	local s = p.room.scavenger -- 771
	if s == nil then -- 772
		return -- 773
	end -- 773
	local cx = cam:sx(p.scavX) -- 775
	local by = cam:sy(s.y) -- 776
	local H = cam:len(s.h) -- 777
	local W = cam:len(26) -- 778
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 779
	local alert = p.scavChase or p.scavSee > 0 -- 782
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 783
	local eyeY = by + H * 0.8 -- 784
	local coneLen = cam:len(alert and 155 or 115) -- 785
	fgGlow:drawVertices({ -- 786
		{ -- 787
			Vec2(cx + f * 6, eyeY), -- 787
			toColor(coneCol, alert and 78 or 34) -- 787
		}, -- 787
		{ -- 788
			Vec2(cx + f * coneLen, by + H * 1.05), -- 788
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 788
		}, -- 788
		{ -- 789
			Vec2(cx + f * coneLen, by + 4), -- 789
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 789
		} -- 789
	}) -- 789
	local frame = 0 -- 792
	if p.scavState == "turn" then -- 793
		frame = 2 -- 794
	elseif p.scavState == "chase" then -- 795
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 796
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 797
		frame = math.floor(self.animTime * 8) % 2 -- 798
	end -- 798
	if assets:tryPlace( -- 800
		"scavenger", -- 800
		"actor_scav", -- 800
		cx, -- 800
		by, -- 800
		W, -- 800
		H, -- 800
		{facing = f, frame = frame, layer = 3} -- 800
	) then -- 800
		return -- 801
	end -- 801
	fgDraw:drawEllipse( -- 804
		Vec2(cx, by + 1), -- 804
		W * 0.62, -- 804
		4, -- 804
		Color(4, 6, 10, 155) -- 804
	) -- 804
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 805
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 806
	fgDraw:drawSegment( -- 808
		Vec2(cx - 4, by + H * 0.4), -- 808
		Vec2(cx - stride, by + 2), -- 808
		W * 0.16, -- 808
		Color(32, 30, 28, 255) -- 808
	) -- 808
	fgDraw:drawSegment( -- 809
		Vec2(cx + 4, by + H * 0.4), -- 809
		Vec2(cx + stride, by + 2), -- 809
		W * 0.16, -- 809
		Color(44, 40, 36, 255) -- 809
	) -- 809
	fgDraw:drawPolygon( -- 811
		{ -- 811
			Vec2(cx - W * 0.45, by + H * 0.25), -- 812
			Vec2(cx + W * 0.42, by + H * 0.25), -- 813
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 814
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 815
		}, -- 815
		Color(56, 52, 46, 255), -- 816
		1.2, -- 816
		Color(128, 118, 100, 180) -- 816
	) -- 816
	local headX = cx + f * 5 -- 818
	local headY = by + H * 0.88 -- 819
	fgDraw:drawCircle( -- 820
		Vec2(headX, headY), -- 820
		W * 0.3, -- 820
		Color(42, 38, 34, 255) -- 820
	) -- 820
	fgGlow:drawDot( -- 821
		Vec2(headX + f * 6, headY), -- 821
		3, -- 821
		toColor(coneCol, 245) -- 821
	) -- 821
	local indY = by + H + 18 -- 824
	if p.scavChase then -- 825
		drawDiamond( -- 826
			fgGlow, -- 826
			cx, -- 826
			indY, -- 826
			9, -- 826
			12, -- 826
			toColor(PALETTE.crimson, 240), -- 826
			1.5, -- 826
			toColor(PALETTE.crimsonCore) -- 826
		) -- 826
	elseif p.scavSee > 0 then -- 827
		local frac = math.min(1, p.scavSee / 24) -- 828
		fgGlow:drawArc( -- 829
			Vec2(cx, indY), -- 829
			11, -- 829
			90, -- 829
			90 - 360 * frac, -- 829
			2.4, -- 829
			toColor(PALETTE.crimson, 235) -- 829
		) -- 829
		fgGlow:drawDot( -- 830
			Vec2(cx, indY), -- 830
			3, -- 830
			toColor(PALETTE.amber) -- 830
		) -- 830
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 831
		drawDiamond( -- 832
			fgGlow, -- 832
			cx, -- 832
			indY, -- 832
			6, -- 832
			8, -- 832
			toColor(PALETTE.amber, 220) -- 832
		) -- 832
	end -- 832
end -- 764
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 837
	local cx = cam:sx(p.dogX) -- 844
	local by = cam:sy(0) -- 845
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 846
	local W = cam:len(42) -- 847
	local H = cam:len(34) -- 848
	local frame = 0 -- 850
	if p.dogState == "ear" then -- 851
		frame = 1 -- 852
	elseif p.dogState == "sniff" then -- 853
		frame = 3 -- 854
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 855
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 856
	end -- 856
	if assets:tryPlace( -- 858
		"dog", -- 858
		"actor_dog", -- 858
		cx, -- 858
		by, -- 858
		W, -- 858
		H, -- 858
		{facing = f, frame = frame, layer = 3} -- 858
	) then -- 858
		return -- 859
	end -- 859
	fgDraw:drawEllipse( -- 862
		Vec2(cx, by + 1), -- 862
		W * 0.56, -- 862
		3.5, -- 862
		Color(4, 8, 10, 155) -- 862
	) -- 862
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 863
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 864
	fgDraw:drawSegment( -- 867
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 867
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 867
		2.8, -- 867
		Color(26, 30, 34, 255) -- 867
	) -- 867
	fgDraw:drawSegment( -- 868
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 868
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 868
		2.8, -- 868
		Color(36, 40, 44, 255) -- 868
	) -- 868
	fgDraw:drawPolygon( -- 870
		{ -- 870
			Vec2(cx - W * 0.42, by + H * 0.36), -- 871
			Vec2(cx + W * 0.38, by + H * 0.42), -- 872
			Vec2(cx + W * 0.34, by + H * 0.78), -- 873
			Vec2(cx - W * 0.38, by + H * 0.72) -- 874
		}, -- 874
		Color(38, 42, 48, 255), -- 875
		1.2, -- 875
		Color(102, 118, 126, 175) -- 875
	) -- 875
	local hx = cx + f * W * 0.42 -- 876
	local hy = by + H * 0.84 -- 877
	fgDraw:drawPolygon( -- 878
		{ -- 878
			Vec2(hx - f * 8, hy - 6), -- 879
			Vec2(hx + f * 12, hy - 2), -- 880
			Vec2(hx + f * 4, hy + 8), -- 881
			Vec2(hx - f * 6, hy + 14) -- 882
		}, -- 882
		Color(44, 48, 54, 255) -- 883
	) -- 883
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 885
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 886
	fgGlow:drawDot( -- 887
		Vec2(hx + f * 4, hy + 2), -- 887
		2.8, -- 887
		toColor(eyeCol, 250) -- 887
	) -- 887
	fillRadialGlow( -- 888
		fgGlow, -- 888
		hx + f * 4, -- 888
		hy + 2, -- 888
		16, -- 888
		16, -- 888
		toColor(eyeCol, alert and 135 or 70), -- 888
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 888
		12 -- 888
	) -- 888
	if alert then -- 890
		local r = 12 + self.animTime * 42 % 24 -- 891
		fgGlow:drawArc( -- 892
			Vec2(hx, hy + 12), -- 892
			r, -- 892
			35, -- 892
			145, -- 892
			1.8, -- 892
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 892
		) -- 892
	end -- 892
end -- 837
return ____exports -- 837
