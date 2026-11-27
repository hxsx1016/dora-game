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
		Color(240, 222, 198, 255) -- 485
	) -- 485
	fgDraw:drawPolygon( -- 487
		{ -- 487
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 488
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 489
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 490
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 491
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 492
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 493
		}, -- 493
		Color(156, 114, 62, 248), -- 494
		1.1, -- 494
		Color(244, 214, 162, 200) -- 494
	) -- 494
	fgGlow:drawDot( -- 496
		Vec2(headX + f * headR * 0.45, headY + 1), -- 496
		2.2, -- 496
		toColor(PALETTE.amberCore) -- 496
	) -- 496
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 499
	if hasCompass then -- 500
		local compX = x + f * cw * 0.65 -- 501
		local compY = by + H * 0.48 -- 502
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 503
		fgGlow:drawDot( -- 504
			Vec2(compX, compY), -- 504
			2.6, -- 504
			toColor(PALETTE.amberCore, 250) -- 504
		) -- 504
		fillRadialGlow( -- 505
			fgGlow, -- 505
			compX, -- 505
			compY, -- 505
			26 * glowPulse, -- 505
			26 * glowPulse, -- 505
			Color(248, 206, 120, 78 * glowPulse), -- 505
			Color(248, 180, 72, 0), -- 505
			14 -- 505
		) -- 505
	end -- 505
	if afraid then -- 508
		self:drawFear(fgGlow, p, x, by + H + 16) -- 509
	end -- 509
	if isControlled and walking and not a.crouch and speed > 100 then -- 513
		local r = 10 + self.animTime * 32 % 24 -- 514
		fgGlow:drawRing( -- 515
			Vec2(x, by + 3), -- 515
			r, -- 515
			r + 1.5, -- 515
			Color(0, 0, 0, 0), -- 515
			1.1, -- 515
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 515
		) -- 515
	end -- 515
end -- 371
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 519
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 520
	do -- 520
		local i = 0 -- 521
		while i < FEAR_MAX do -- 521
			local lit = i < p.escort.fear -- 522
			drawDiamond( -- 523
				fgGlow, -- 523
				x + (i - 1) * 13, -- 523
				y, -- 523
				4, -- 523
				5, -- 523
				toColor(lit and tint or PALETTE.steelDark, 215), -- 524
				1, -- 524
				toColor(tint, lit and 235 or 100) -- 524
			) -- 524
			i = i + 1 -- 521
		end -- 521
	end -- 521
end -- 519
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 528
	local x = cam:sx(e.x + f * 20) -- 529
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 530
	local dx = cam:sx(p.player.x) - x -- 531
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 532
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 533
	do -- 533
		local i = 0 -- 534
		while i < 8 do -- 534
			local a = length * i / 8 -- 535
			local b = length * (i + 1) / 8 -- 536
			fgGlow:drawSegment( -- 537
				Vec2(x + dx * a, y + dy * a), -- 537
				Vec2(x + dx * b, y + dy * b), -- 537
				1.3, -- 538
				Color(220, 120, 88, 210) -- 538
			) -- 538
			i = i + 2 -- 534
		end -- 534
	end -- 534
end -- 528
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 543
	local cx = cam:sx(e.x) -- 552
	local depth = e.depth or 0 -- 553
	local by = cam:sy(e.y, depth) -- 554
	local H = cam:len(e.h) -- 555
	local W = cam:len(e.w) -- 556
	local f = p.player.x >= e.x and 1 or -1 -- 557
	if e.kind == "target" then -- 560
		if p.room.key == "escort3" then -- 561
			return -- 562
		end -- 562
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 564
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 565
		fgDraw:drawEllipse( -- 566
			Vec2(cx, by + 1), -- 566
			W * 0.52, -- 566
			3.6, -- 566
			Color(12, 11, 13, 140) -- 566
		) -- 566
		fgDraw:drawSegment( -- 568
			Vec2( -- 568
				cx - cam:len(9), -- 568
				by -- 568
			), -- 568
			Vec2(cx + lean * 0.4, postTopY), -- 568
			math.max( -- 568
				2, -- 568
				cam:len(3.2) -- 568
			), -- 568
			Color(92, 64, 42, 255) -- 568
		) -- 568
		fgDraw:drawSegment( -- 569
			Vec2( -- 569
				cx + cam:len(9), -- 569
				by -- 569
			), -- 569
			Vec2(cx + lean * 0.4, postTopY), -- 569
			math.max( -- 569
				2, -- 569
				cam:len(3.2) -- 569
			), -- 569
			Color(76, 52, 34, 255) -- 569
		) -- 569
		local discX = cx + lean -- 571
		local discY = by + H * (e.alive and 0.56 or 0.3) -- 572
		local discR = math.max( -- 573
			7, -- 573
			cam:len(13) -- 573
		) -- 573
		local hitTint = e.hitT > 0 or not e.alive -- 574
		fgDraw:drawCircle( -- 575
			Vec2(discX, discY), -- 575
			discR, -- 575
			hitTint and Color(214, 152, 116, 245) or Color(196, 174, 134, 250) -- 575
		) -- 575
		fgDraw:drawRing( -- 576
			Vec2(discX, discY), -- 576
			discR * 0.62, -- 576
			discR * 0.76, -- 576
			Color(0, 0, 0, 0), -- 576
			1.4, -- 576
			Color(62, 46, 34, 230) -- 576
		) -- 576
		fgDraw:drawCircle( -- 577
			Vec2(discX, discY), -- 577
			discR * 0.3, -- 577
			toColor(PALETTE.rouge, hitTint and 255 or 220) -- 577
		) -- 577
		return -- 578
	end -- 578
	local slot = "enemy_idle" -- 581
	if not e.alive then -- 582
		slot = "enemy_down" -- 583
	elseif e.hitT > 0 then -- 584
		slot = "enemy_hit" -- 585
	elseif e.warnT > 0 then -- 586
		slot = "enemy_aim" -- 587
	end -- 587
	local height = e.alive and H or H * 0.24 -- 589
	if assets:tryPlace( -- 590
		slot, -- 590
		"actor_enemy_" .. tostring(index), -- 590
		cx, -- 590
		by, -- 590
		W, -- 590
		height, -- 590
		{ -- 590
			facing = f, -- 591
			opacity = e.alive and 1 or 0.78, -- 591
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 591
		} -- 591
	) then -- 591
		if e.alive then -- 593
			self:drawEnemyArchetypeGear( -- 594
				fgDraw, -- 594
				fgGlow, -- 594
				e, -- 594
				cx, -- 594
				by, -- 594
				H, -- 594
				f, -- 594
				cam -- 594
			) -- 594
			if e.warnT > 0 then -- 595
				self:drawEnemyWarning( -- 596
					fgGlow, -- 596
					e, -- 596
					p, -- 596
					cam, -- 596
					f -- 596
				) -- 596
			end -- 596
		end -- 596
		return -- 599
	end -- 599
	if not e.alive then -- 602
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 603
		fgDraw:drawPolygon( -- 604
			{ -- 604
				Vec2(cx - H * 0.3, by), -- 605
				Vec2(cx + H * 0.28, by), -- 606
				Vec2(cx + H * 0.2, by + H * 0.14), -- 607
				Vec2(cx - H * 0.24, by + H * 0.11) -- 608
			}, -- 608
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 609
		) -- 609
		if flash > 0 then -- 610
			fillRadialGlow( -- 611
				fgGlow, -- 611
				cx, -- 611
				by + 12, -- 611
				34 * flash, -- 611
				18 * flash, -- 611
				toColor(PALETTE.crimson, 180 * flash), -- 611
				Color(255, 48, 82, 0), -- 611
				12 -- 611
			) -- 611
		end -- 611
		return -- 613
	end -- 613
	local sw = H * 0.112 -- 616
	fgDraw:drawEllipse( -- 617
		Vec2(cx, by + 1), -- 617
		sw * 1.9, -- 617
		4, -- 617
		Color(4, 6, 10, 165) -- 617
	) -- 617
	local hipY = by + H * 0.44 -- 620
	local kneeY = by + H * 0.23 -- 621
	local shY = by + H * 0.79 -- 622
	fgDraw:drawSegment( -- 623
		Vec2(cx - 5, hipY), -- 623
		Vec2(cx - 7, kneeY), -- 623
		H * 0.044, -- 623
		Color(20, 16, 26, 255) -- 623
	) -- 623
	fgDraw:drawSegment( -- 624
		Vec2(cx - 7, kneeY), -- 624
		Vec2(cx - 8, by + 2), -- 624
		H * 0.038, -- 624
		Color(20, 16, 26, 255) -- 624
	) -- 624
	fgDraw:drawSegment( -- 625
		Vec2(cx + 5, hipY), -- 625
		Vec2(cx + 7, kneeY), -- 625
		H * 0.046, -- 625
		Color(28, 22, 36, 255) -- 625
	) -- 625
	fgDraw:drawSegment( -- 626
		Vec2(cx + 7, kneeY), -- 626
		Vec2(cx + 8, by + 2), -- 626
		H * 0.04, -- 626
		Color(28, 22, 36, 255) -- 626
	) -- 626
	fgDraw:drawPolygon( -- 628
		{ -- 628
			Vec2(cx - sw * 0.68, hipY), -- 629
			Vec2(cx + sw * 0.68, hipY), -- 630
			Vec2(cx + sw * 1.12, shY), -- 631
			Vec2(cx - sw * 1.12, shY) -- 632
		}, -- 632
		Color(111, 68, 55, 255), -- 633
		1.3, -- 633
		Color(143, 101, 66, 220) -- 633
	) -- 633
	fgDraw:drawPolygon( -- 634
		{ -- 634
			Vec2(cx - sw * 1.26, shY - 6), -- 635
			Vec2(cx + sw * 1.26, shY - 6), -- 636
			Vec2(cx + sw * 0.96, shY + 5), -- 637
			Vec2(cx - sw * 0.96, shY + 5) -- 638
		}, -- 638
		Color(98, 82, 62, 255) -- 639
	) -- 639
	local headR = H * 0.086 -- 641
	local headY = shY + headR * 1.32 -- 642
	fgDraw:drawCircle( -- 643
		Vec2(cx, headY), -- 643
		headR * 0.82, -- 643
		Color(187, 142, 103, 255) -- 643
	) -- 643
	fgDraw:drawPolygon( -- 644
		{ -- 644
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 645
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 646
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 647
		}, -- 647
		Color(136, 105, 65, 255), -- 648
		1.1, -- 648
		Color(177, 145, 91, 220) -- 648
	) -- 648
	local gunX = cx + f * H * 0.34 -- 650
	local gunY = by + H * 0.69 -- 651
	fgDraw:drawSegment( -- 652
		Vec2(cx - f * 6, gunY - 2), -- 652
		Vec2(gunX, gunY), -- 652
		2.8, -- 652
		Color(118, 87, 61, 255) -- 652
	) -- 652
	self:drawEnemyArchetypeGear( -- 653
		fgDraw, -- 653
		fgGlow, -- 653
		e, -- 653
		cx, -- 653
		by, -- 653
		H, -- 653
		f, -- 653
		cam -- 653
	) -- 653
	if e.warnT > 0 then -- 654
		self:drawEnemyWarning( -- 655
			fgGlow, -- 655
			e, -- 655
			p, -- 655
			cam, -- 655
			f -- 655
		) -- 655
	end -- 655
end -- 543
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, e, cx, by, H, f, cam) -- 660
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 670
		local shX = cx + f * cam:len(13) -- 671
		local shW = math.max( -- 672
			5, -- 672
			cam:len(8) -- 672
		) -- 672
		local shH = H * 0.72 -- 673
		local cracked = (e.shieldHp or 2) <= 1 -- 674
		fgDraw:drawRect( -- 675
			Rect(shX - shW * 0.5, by + H * 0.08, shW, shH), -- 676
			cracked and Color(122, 82, 52, 245) or Color(96, 66, 42, 250), -- 677
			1.3, -- 678
			Color(168, 174, 180, 230) -- 679
		) -- 679
		fgDraw:drawCircle( -- 681
			Vec2(shX, by + H * 0.44), -- 681
			math.max( -- 681
				2.2, -- 681
				cam:len(3.5) -- 681
			), -- 681
			Color(142, 148, 154, 240) -- 681
		) -- 681
		if cracked then -- 682
			fgDraw:drawSegment( -- 683
				Vec2(shX - shW * 0.4, by + H * 0.28), -- 683
				Vec2(shX + shW * 0.4, by + H * 0.58), -- 683
				1.4, -- 683
				Color(24, 18, 16, 235) -- 683
			) -- 683
		end -- 683
	elseif e.kind == "breaker" then -- 685
		local swing = (e.swingT or 0) > 0 -- 686
		local handleX0 = cx - f * cam:len(4) -- 687
		local handleY0 = by + H * 0.44 -- 688
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 689
		local tipY = by + H * (swing and 0.46 or 0.78) -- 690
		fgDraw:drawSegment( -- 691
			Vec2(handleX0, handleY0), -- 691
			Vec2(tipX, tipY), -- 691
			math.max( -- 691
				2.2, -- 691
				cam:len(3) -- 691
			), -- 691
			Color(98, 66, 44, 255) -- 691
		) -- 691
		fgDraw:drawPolygon( -- 692
			{ -- 692
				Vec2( -- 693
					tipX - f * cam:len(3), -- 693
					tipY - cam:len(4) -- 693
				), -- 693
				Vec2( -- 694
					tipX + f * cam:len(9), -- 694
					tipY - cam:len(1) -- 694
				), -- 694
				Vec2( -- 695
					tipX + f * cam:len(7), -- 695
					tipY + cam:len(9) -- 695
				), -- 695
				Vec2( -- 696
					tipX - f * cam:len(2), -- 696
					tipY + cam:len(6) -- 696
				) -- 696
			}, -- 696
			Color(148, 154, 162, 250), -- 697
			1, -- 697
			Color(224, 228, 232, 220) -- 697
		) -- 697
		if swing then -- 698
			fgGlow:drawArc( -- 699
				Vec2( -- 699
					cx + f * cam:len(10), -- 699
					by + H * 0.56 -- 699
				), -- 699
				cam:len(18), -- 699
				f > 0 and -40 or 140, -- 699
				f > 0 and 50 or 230, -- 699
				1.8, -- 699
				toColor(PALETTE.rouge, 195) -- 699
			) -- 699
		end -- 699
	elseif e.kind == "leader" then -- 701
		local topY = by + H * 1.02 -- 703
		fgDraw:drawSegment( -- 704
			Vec2(cx, topY), -- 704
			Vec2( -- 704
				cx - f * cam:len(10), -- 704
				topY + cam:len(9) -- 704
			), -- 704
			2.2, -- 704
			toColor(PALETTE.rouge, 240) -- 704
		) -- 704
		fgDraw:drawDot( -- 705
			Vec2( -- 705
				cx - f * cam:len(10), -- 705
				topY + cam:len(9) -- 705
			), -- 705
			2.6, -- 705
			toColor(PALETTE.crimsonCore, 235) -- 705
		) -- 705
	end -- 705
end -- 660
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 710
	local s = p.room.scavenger -- 717
	if s == nil then -- 718
		return -- 719
	end -- 719
	local cx = cam:sx(p.scavX) -- 721
	local by = cam:sy(s.y) -- 722
	local H = cam:len(s.h) -- 723
	local W = cam:len(26) -- 724
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 725
	local alert = p.scavChase or p.scavSee > 0 -- 728
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 729
	local eyeY = by + H * 0.8 -- 730
	local coneLen = cam:len(alert and 155 or 115) -- 731
	fgGlow:drawVertices({ -- 732
		{ -- 733
			Vec2(cx + f * 6, eyeY), -- 733
			toColor(coneCol, alert and 78 or 34) -- 733
		}, -- 733
		{ -- 734
			Vec2(cx + f * coneLen, by + H * 1.05), -- 734
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 734
		}, -- 734
		{ -- 735
			Vec2(cx + f * coneLen, by + 4), -- 735
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 735
		} -- 735
	}) -- 735
	local frame = 0 -- 738
	if p.scavState == "turn" then -- 739
		frame = 2 -- 740
	elseif p.scavState == "chase" then -- 741
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 742
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 743
		frame = math.floor(self.animTime * 8) % 2 -- 744
	end -- 744
	if assets:tryPlace( -- 746
		"scavenger", -- 746
		"actor_scav", -- 746
		cx, -- 746
		by, -- 746
		W, -- 746
		H, -- 746
		{facing = f, frame = frame, layer = 3} -- 746
	) then -- 746
		return -- 747
	end -- 747
	fgDraw:drawEllipse( -- 750
		Vec2(cx, by + 1), -- 750
		W * 0.62, -- 750
		4, -- 750
		Color(4, 6, 10, 155) -- 750
	) -- 750
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 751
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 752
	fgDraw:drawSegment( -- 754
		Vec2(cx - 4, by + H * 0.4), -- 754
		Vec2(cx - stride, by + 2), -- 754
		W * 0.16, -- 754
		Color(32, 30, 28, 255) -- 754
	) -- 754
	fgDraw:drawSegment( -- 755
		Vec2(cx + 4, by + H * 0.4), -- 755
		Vec2(cx + stride, by + 2), -- 755
		W * 0.16, -- 755
		Color(44, 40, 36, 255) -- 755
	) -- 755
	fgDraw:drawPolygon( -- 757
		{ -- 757
			Vec2(cx - W * 0.45, by + H * 0.25), -- 758
			Vec2(cx + W * 0.42, by + H * 0.25), -- 759
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 760
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 761
		}, -- 761
		Color(56, 52, 46, 255), -- 762
		1.2, -- 762
		Color(128, 118, 100, 180) -- 762
	) -- 762
	local headX = cx + f * 5 -- 764
	local headY = by + H * 0.88 -- 765
	fgDraw:drawCircle( -- 766
		Vec2(headX, headY), -- 766
		W * 0.3, -- 766
		Color(42, 38, 34, 255) -- 766
	) -- 766
	fgGlow:drawDot( -- 767
		Vec2(headX + f * 6, headY), -- 767
		3, -- 767
		toColor(coneCol, 245) -- 767
	) -- 767
	local indY = by + H + 18 -- 770
	if p.scavChase then -- 771
		drawDiamond( -- 772
			fgGlow, -- 772
			cx, -- 772
			indY, -- 772
			9, -- 772
			12, -- 772
			toColor(PALETTE.crimson, 240), -- 772
			1.5, -- 772
			toColor(PALETTE.crimsonCore) -- 772
		) -- 772
	elseif p.scavSee > 0 then -- 773
		local frac = math.min(1, p.scavSee / 24) -- 774
		fgGlow:drawArc( -- 775
			Vec2(cx, indY), -- 775
			11, -- 775
			90, -- 775
			90 - 360 * frac, -- 775
			2.4, -- 775
			toColor(PALETTE.crimson, 235) -- 775
		) -- 775
		fgGlow:drawDot( -- 776
			Vec2(cx, indY), -- 776
			3, -- 776
			toColor(PALETTE.amber) -- 776
		) -- 776
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 777
		drawDiamond( -- 778
			fgGlow, -- 778
			cx, -- 778
			indY, -- 778
			6, -- 778
			8, -- 778
			toColor(PALETTE.amber, 220) -- 778
		) -- 778
	end -- 778
end -- 710
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 783
	local cx = cam:sx(p.dogX) -- 790
	local by = cam:sy(0) -- 791
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 792
	local W = cam:len(42) -- 793
	local H = cam:len(34) -- 794
	local frame = 0 -- 796
	if p.dogState == "ear" then -- 797
		frame = 1 -- 798
	elseif p.dogState == "sniff" then -- 799
		frame = 3 -- 800
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 801
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 802
	end -- 802
	if assets:tryPlace( -- 804
		"dog", -- 804
		"actor_dog", -- 804
		cx, -- 804
		by, -- 804
		W, -- 804
		H, -- 804
		{facing = f, frame = frame, layer = 3} -- 804
	) then -- 804
		return -- 805
	end -- 805
	fgDraw:drawEllipse( -- 808
		Vec2(cx, by + 1), -- 808
		W * 0.56, -- 808
		3.5, -- 808
		Color(4, 8, 10, 155) -- 808
	) -- 808
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 809
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 810
	fgDraw:drawSegment( -- 813
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 813
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 813
		2.8, -- 813
		Color(26, 30, 34, 255) -- 813
	) -- 813
	fgDraw:drawSegment( -- 814
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 814
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 814
		2.8, -- 814
		Color(36, 40, 44, 255) -- 814
	) -- 814
	fgDraw:drawPolygon( -- 816
		{ -- 816
			Vec2(cx - W * 0.42, by + H * 0.36), -- 817
			Vec2(cx + W * 0.38, by + H * 0.42), -- 818
			Vec2(cx + W * 0.34, by + H * 0.78), -- 819
			Vec2(cx - W * 0.38, by + H * 0.72) -- 820
		}, -- 820
		Color(38, 42, 48, 255), -- 821
		1.2, -- 821
		Color(102, 118, 126, 175) -- 821
	) -- 821
	local hx = cx + f * W * 0.42 -- 822
	local hy = by + H * 0.84 -- 823
	fgDraw:drawPolygon( -- 824
		{ -- 824
			Vec2(hx - f * 8, hy - 6), -- 825
			Vec2(hx + f * 12, hy - 2), -- 826
			Vec2(hx + f * 4, hy + 8), -- 827
			Vec2(hx - f * 6, hy + 14) -- 828
		}, -- 828
		Color(44, 48, 54, 255) -- 829
	) -- 829
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 831
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 832
	fgGlow:drawDot( -- 833
		Vec2(hx + f * 4, hy + 2), -- 833
		2.8, -- 833
		toColor(eyeCol, 250) -- 833
	) -- 833
	fillRadialGlow( -- 834
		fgGlow, -- 834
		hx + f * 4, -- 834
		hy + 2, -- 834
		16, -- 834
		16, -- 834
		toColor(eyeCol, alert and 135 or 70), -- 834
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 834
		12 -- 834
	) -- 834
	if alert then -- 836
		local r = 12 + self.animTime * 42 % 24 -- 837
		fgGlow:drawArc( -- 838
			Vec2(hx, hy + 12), -- 838
			r, -- 838
			35, -- 838
			145, -- 838
			1.8, -- 838
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 838
		) -- 838
	end -- 838
end -- 783
return ____exports -- 783
