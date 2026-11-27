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
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 52
		self.hitUntil = p.ticks + 14 -- 54
	end -- 54
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 54
		self.throwUntil = p.ticks + 12 -- 57
	end -- 57
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 57
		self.shotUntil = p.ticks + 7 -- 60
	end -- 60
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 62
	self.previousAxle = p.cartAxle -- 63
	self.previousHp = p.hp -- 64
	self.previousBottle = p.hasBottle -- 65
	self.previousTrace = p.trace -- 66
	if not p.childMode and p.player.rollT > 0 then -- 66
		self.ghostCooldown = self.ghostCooldown - dt -- 69
		if self.ghostCooldown <= 0 then -- 69
			local ____self_ghosts_0 = self.ghosts -- 69
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
			if g.life > 0 then -- 92
				self.ghosts[write + 1] = g -- 94
				write = write + 1 -- 95
			end -- 95
			i = i + 1 -- 90
		end -- 90
	end -- 90
	__TS__ArraySetLength(self.ghosts, write) -- 90
end -- 51
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, suppressPartner) -- 101
	if suppressPartner == nil then -- 101
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
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 114
		self:drawScavenger( -- 120
			fgDraw, -- 120
			fgGlow, -- 120
			assets, -- 120
			p, -- 120
			cam -- 120
		) -- 120
	end -- 120
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 120
		self:drawDog( -- 125
			fgDraw, -- 125
			fgGlow, -- 125
			assets, -- 125
			p, -- 125
			cam -- 125
		) -- 125
	end -- 125
	if p.partner.alive and not suppressPartner then -- 125
		local partnerIsChild = p.partner.w <= 28 -- 130
		if partnerIsChild then -- 130
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
	if p.player.alive then -- 134
		if p.childMode then -- 134
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
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 179
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
				if b.broken == true or b.hidden == true or b.soft == true then -- 185
					goto __continue33 -- 187
				end -- 187
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 187
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
	if isControlled and p.ticks < self.hitUntil then -- 220
		slot = "soldier_hit" -- 222
	elseif a.rollT > 0 then -- 222
		slot = "soldier_roll" -- 224
		height = height * 0.59 -- 225
	elseif p.phase == "prologue-give" then -- 225
		slot = "soldier_offer" -- 227
		height = height * 0.75 -- 228
		facing = p.partner.x >= a.x and 1 or -1 -- 229
	elseif isControlled and p.gripping then -- 229
		slot = "soldier_push" -- 231
		frame = self.cartMoving and step or 0 -- 232
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 233
		height = height * 0.91 -- 234
	elseif isControlled and p.escort.state == "calming" then -- 234
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
		elseif isControlled and p.ticks < self.shotUntil then -- 243
			local running = speed > 8 -- 245
			slot = running and "soldier_fire_move" or "soldier_fire" -- 246
			frame = running and step or 0 -- 247
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 248
		elseif a.covered or isControlled and p.coverHug then -- 248
			slot = "soldier_cover" -- 250
			height = height * 0.77 -- 251
		elseif speed > 8 then -- 251
			slot = "soldier_run" -- 253
			frame = step -- 254
		end -- 254
	end -- 254
	if assets:tryPlace( -- 254
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
	if isControlled and not calming and not rolling and not p.gripping then -- 337
		local gunPivotX = cx + lean + f * sw * 0.35 -- 341
		local gunPivotY = shY - bodyH * 0.1 -- 342
		local aimDx = f -- 343
		local aimDy = 0 -- 344
		if p.aimX > 0 or p.aimY > 0 then -- 344
			aimDx = p.aimX - gunPivotX -- 346
			aimDy = p.aimY - gunPivotY -- 347
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 348
			if dLen > 4 then -- 348
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
	elseif calming then -- 362
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
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 397
		slot = "child_knock" -- 400
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 400
		slot = "child_offer" -- 403
	elseif isControlled and p.ticks < self.throwUntil then -- 403
		slot = "child_throw" -- 405
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 405
		slot = "child_aim" -- 407
	elseif isControlled and p.gripping then -- 407
		slot = "child_pull" -- 409
		frame = self.cartMoving and step or 0 -- 410
	elseif afraid and p.escort.state == "frozen" then -- 410
		slot = "child_fear" -- 412
		height = height * 0.74 -- 413
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 413
		slot = "child_peek" -- 416
		height = height * 0.83 -- 417
	elseif a.crouch then -- 417
		slot = "child_crouch" -- 419
		frame = speed > 8 and step or 0 -- 420
	elseif speed > 8 then -- 420
		slot = "child_run" -- 422
		frame = step -- 423
	end -- 423
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 425
	if assets:tryPlace( -- 425
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
		if afraid then -- 429
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
	if hasCompass then -- 490
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
	if afraid then -- 496
		self:drawFear(fgGlow, p, x, by + H + 16) -- 500
	end -- 500
	if isControlled and walking and not a.crouch and speed > 100 then -- 500
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
	if e.kind == "target" then -- 548
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 552
		fgDraw:drawEllipse( -- 553
			Vec2(cx, by + 1), -- 553
			W * 0.56, -- 553
			3.6, -- 553
			Color(12, 11, 13, 140) -- 553
		) -- 553
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 554
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 555
		if assets:tryPlacePath( -- 555
			"assets/art/props_ming.clip|target_dummy", -- 556
			"actor_target_" .. tostring(index), -- 556
			cx, -- 556
			by, -- 556
			H * 0.82, -- 556
			H * 0.96, -- 556
			{ -- 556
				anchorX = 0.5, -- 557
				anchorY = 0, -- 558
				preserveAspect = true, -- 559
				angle = angle, -- 560
				color = tint, -- 561
				opacity = e.alive and 1 or 0.76, -- 562
				layer = targetLayer -- 563
			} -- 563
		) then -- 563
			return -- 565
		end -- 565
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 567
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 568
		fgDraw:drawSegment( -- 569
			Vec2( -- 569
				cx - cam:len(9), -- 569
				by -- 569
			), -- 569
			Vec2(cx + lean * 0.4, postTopY), -- 569
			math.max( -- 569
				2, -- 569
				cam:len(3.2) -- 569
			), -- 569
			Color(92, 64, 42, 255) -- 569
		) -- 569
		fgDraw:drawSegment( -- 570
			Vec2( -- 570
				cx + cam:len(9), -- 570
				by -- 570
			), -- 570
			Vec2(cx + lean * 0.4, postTopY), -- 570
			math.max( -- 570
				2, -- 570
				cam:len(3.2) -- 570
			), -- 570
			Color(76, 52, 34, 255) -- 570
		) -- 570
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
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 581
	if e.alive and e.hitT <= 0 then -- 581
		local extraClip = "" -- 584
		local extraAnchorX = 0.5 -- 585
		local extraHeight = H * 0.96 -- 586
		local extraTint = Color(255, 255, 255, 255) -- 587
		if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 587
			extraClip = e.warnT > 0 and "enemy_shield_aim" or "enemy_shield_idle" -- 589
			extraAnchorX = e.warnT > 0 and 0.45 or 0.5 -- 590
			extraHeight = H * 0.94 -- 591
			if (e.shieldHp or 2) <= 1 then -- 591
				extraTint = Color(234, 198, 178, 255) -- 593
			end -- 593
		elseif e.kind == "breaker" then -- 593
			local swing = (e.swingT or 0) > 0 or e.warnT > 0 -- 596
			extraClip = swing and "enemy_breaker_aim" or "enemy_breaker_idle" -- 597
			extraAnchorX = swing and 0.52 or 0.38 -- 598
			extraHeight = H * (swing and 0.98 or 0.94) -- 599
		elseif e.kind == "leader" then -- 599
			extraClip = e.warnT > 0 and "enemy_leader_aim" or "enemy_leader_idle" -- 601
			extraAnchorX = e.warnT > 0 and 0.38 or 0.44 -- 602
			extraHeight = H * 1 -- 603
		end -- 603
		if extraClip ~= "" and assets:tryPlacePath( -- 603
			"assets/art/actors_extra.clip|" .. extraClip, -- 606
			"actor_enemy_" .. tostring(index), -- 607
			cx, -- 608
			by, -- 609
			W * 1.8, -- 610
			extraHeight, -- 611
			{ -- 612
				anchorX = extraAnchorX, -- 613
				anchorY = 0, -- 614
				preserveAspect = true, -- 615
				facing = f, -- 616
				color = extraTint, -- 617
				layer = enemyLayer -- 618
			} -- 618
		) then -- 618
			fgDraw:drawEllipse( -- 621
				Vec2(cx, by + 1), -- 621
				W * 0.58, -- 621
				3.8, -- 621
				Color(12, 11, 13, 145) -- 621
			) -- 621
			if e.kind == "breaker" and (e.swingT or 0) > 0 then -- 621
				fgGlow:drawArc( -- 623
					Vec2( -- 623
						cx + f * cam:len(10), -- 623
						by + H * 0.56 -- 623
					), -- 623
					cam:len(18), -- 623
					f > 0 and -40 or 140, -- 623
					f > 0 and 50 or 230, -- 623
					1.8, -- 623
					toColor(PALETTE.rouge, 195) -- 623
				) -- 623
			end -- 623
			if e.warnT > 0 then -- 623
				self:drawEnemyWarning( -- 626
					fgGlow, -- 626
					e, -- 626
					p, -- 626
					cam, -- 626
					f -- 626
				) -- 626
			end -- 626
			return -- 628
		end -- 628
	end -- 628
	local slot = "enemy_idle" -- 632
	if not e.alive then -- 632
		slot = "enemy_down" -- 634
	elseif e.hitT > 0 then -- 634
		slot = "enemy_hit" -- 636
	elseif e.warnT > 0 then -- 636
		slot = "enemy_aim" -- 638
	end -- 638
	local height = e.alive and H or H * 0.24 -- 640
	if assets:tryPlace( -- 640
		slot, -- 641
		"actor_enemy_" .. tostring(index), -- 641
		cx, -- 641
		by, -- 641
		W, -- 641
		height, -- 641
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 641
	) then -- 641
		if e.alive then -- 641
			self:drawEnemyArchetypeGear( -- 645
				fgDraw, -- 645
				fgGlow, -- 645
				e, -- 645
				cx, -- 645
				by, -- 645
				H, -- 645
				f, -- 645
				cam -- 645
			) -- 645
			if e.warnT > 0 then -- 645
				self:drawEnemyWarning( -- 647
					fgGlow, -- 647
					e, -- 647
					p, -- 647
					cam, -- 647
					f -- 647
				) -- 647
			end -- 647
		end -- 647
		return -- 650
	end -- 650
	if not e.alive then -- 650
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 654
		fgDraw:drawPolygon( -- 655
			{ -- 655
				Vec2(cx - H * 0.3, by), -- 656
				Vec2(cx + H * 0.28, by), -- 657
				Vec2(cx + H * 0.2, by + H * 0.14), -- 658
				Vec2(cx - H * 0.24, by + H * 0.11) -- 659
			}, -- 659
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 660
		) -- 660
		if flash > 0 then -- 660
			fillRadialGlow( -- 662
				fgGlow, -- 662
				cx, -- 662
				by + 12, -- 662
				34 * flash, -- 662
				18 * flash, -- 662
				toColor(PALETTE.crimson, 180 * flash), -- 662
				Color(255, 48, 82, 0), -- 662
				12 -- 662
			) -- 662
		end -- 662
		return -- 664
	end -- 664
	local sw = H * 0.112 -- 667
	fgDraw:drawEllipse( -- 668
		Vec2(cx, by + 1), -- 668
		sw * 1.9, -- 668
		4, -- 668
		Color(4, 6, 10, 165) -- 668
	) -- 668
	local hipY = by + H * 0.44 -- 671
	local kneeY = by + H * 0.23 -- 672
	local shY = by + H * 0.79 -- 673
	fgDraw:drawSegment( -- 674
		Vec2(cx - 5, hipY), -- 674
		Vec2(cx - 7, kneeY), -- 674
		H * 0.044, -- 674
		Color(20, 16, 26, 255) -- 674
	) -- 674
	fgDraw:drawSegment( -- 675
		Vec2(cx - 7, kneeY), -- 675
		Vec2(cx - 8, by + 2), -- 675
		H * 0.038, -- 675
		Color(20, 16, 26, 255) -- 675
	) -- 675
	fgDraw:drawSegment( -- 676
		Vec2(cx + 5, hipY), -- 676
		Vec2(cx + 7, kneeY), -- 676
		H * 0.046, -- 676
		Color(28, 22, 36, 255) -- 676
	) -- 676
	fgDraw:drawSegment( -- 677
		Vec2(cx + 7, kneeY), -- 677
		Vec2(cx + 8, by + 2), -- 677
		H * 0.04, -- 677
		Color(28, 22, 36, 255) -- 677
	) -- 677
	fgDraw:drawPolygon( -- 679
		{ -- 679
			Vec2(cx - sw * 0.68, hipY), -- 680
			Vec2(cx + sw * 0.68, hipY), -- 681
			Vec2(cx + sw * 1.12, shY), -- 682
			Vec2(cx - sw * 1.12, shY) -- 683
		}, -- 683
		Color(111, 68, 55, 255), -- 684
		1.3, -- 684
		Color(143, 101, 66, 220) -- 684
	) -- 684
	fgDraw:drawPolygon( -- 685
		{ -- 685
			Vec2(cx - sw * 1.26, shY - 6), -- 686
			Vec2(cx + sw * 1.26, shY - 6), -- 687
			Vec2(cx + sw * 0.96, shY + 5), -- 688
			Vec2(cx - sw * 0.96, shY + 5) -- 689
		}, -- 689
		Color(98, 82, 62, 255) -- 690
	) -- 690
	local headR = H * 0.086 -- 692
	local headY = shY + headR * 1.32 -- 693
	fgDraw:drawCircle( -- 694
		Vec2(cx, headY), -- 694
		headR * 0.82, -- 694
		Color(187, 142, 103, 255) -- 694
	) -- 694
	fgDraw:drawPolygon( -- 695
		{ -- 695
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 696
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 697
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 698
		}, -- 698
		Color(136, 105, 65, 255), -- 699
		1.1, -- 699
		Color(177, 145, 91, 220) -- 699
	) -- 699
	local gunX = cx + f * H * 0.34 -- 701
	local gunY = by + H * 0.69 -- 702
	fgDraw:drawSegment( -- 703
		Vec2(cx - f * 6, gunY - 2), -- 703
		Vec2(gunX, gunY), -- 703
		2.8, -- 703
		Color(118, 87, 61, 255) -- 703
	) -- 703
	self:drawEnemyArchetypeGear( -- 704
		fgDraw, -- 704
		fgGlow, -- 704
		e, -- 704
		cx, -- 704
		by, -- 704
		H, -- 704
		f, -- 704
		cam -- 704
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
end -- 534
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, e, cx, by, H, f, cam) -- 711
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 711
		local shX = cx + f * cam:len(13) -- 722
		local shW = math.max( -- 723
			5, -- 723
			cam:len(8) -- 723
		) -- 723
		local shH = H * 0.72 -- 724
		local cracked = (e.shieldHp or 2) <= 1 -- 725
		fgDraw:drawRect( -- 726
			Rect(shX - shW * 0.5, by + H * 0.08, shW, shH), -- 727
			cracked and Color(122, 82, 52, 245) or Color(96, 66, 42, 250), -- 728
			1.3, -- 729
			Color(168, 174, 180, 230) -- 730
		) -- 730
		fgDraw:drawCircle( -- 732
			Vec2(shX, by + H * 0.44), -- 732
			math.max( -- 732
				2.2, -- 732
				cam:len(3.5) -- 732
			), -- 732
			Color(142, 148, 154, 240) -- 732
		) -- 732
		if cracked then -- 732
			fgDraw:drawSegment( -- 734
				Vec2(shX - shW * 0.4, by + H * 0.28), -- 734
				Vec2(shX + shW * 0.4, by + H * 0.58), -- 734
				1.4, -- 734
				Color(24, 18, 16, 235) -- 734
			) -- 734
		end -- 734
	elseif e.kind == "breaker" then -- 734
		local swing = (e.swingT or 0) > 0 -- 737
		local handleX0 = cx - f * cam:len(4) -- 738
		local handleY0 = by + H * 0.44 -- 739
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 740
		local tipY = by + H * (swing and 0.46 or 0.78) -- 741
		fgDraw:drawSegment( -- 742
			Vec2(handleX0, handleY0), -- 742
			Vec2(tipX, tipY), -- 742
			math.max( -- 742
				2.2, -- 742
				cam:len(3) -- 742
			), -- 742
			Color(98, 66, 44, 255) -- 742
		) -- 742
		fgDraw:drawPolygon( -- 743
			{ -- 743
				Vec2( -- 744
					tipX - f * cam:len(3), -- 744
					tipY - cam:len(4) -- 744
				), -- 744
				Vec2( -- 745
					tipX + f * cam:len(9), -- 745
					tipY - cam:len(1) -- 745
				), -- 745
				Vec2( -- 746
					tipX + f * cam:len(7), -- 746
					tipY + cam:len(9) -- 746
				), -- 746
				Vec2( -- 747
					tipX - f * cam:len(2), -- 747
					tipY + cam:len(6) -- 747
				) -- 747
			}, -- 747
			Color(148, 154, 162, 250), -- 748
			1, -- 748
			Color(224, 228, 232, 220) -- 748
		) -- 748
		if swing then -- 748
			fgGlow:drawArc( -- 750
				Vec2( -- 750
					cx + f * cam:len(10), -- 750
					by + H * 0.56 -- 750
				), -- 750
				cam:len(18), -- 750
				f > 0 and -40 or 140, -- 750
				f > 0 and 50 or 230, -- 750
				1.8, -- 750
				toColor(PALETTE.rouge, 195) -- 750
			) -- 750
		end -- 750
	elseif e.kind == "leader" then -- 750
		local topY = by + H * 1.02 -- 754
		fgDraw:drawSegment( -- 755
			Vec2(cx, topY), -- 755
			Vec2( -- 755
				cx - f * cam:len(10), -- 755
				topY + cam:len(9) -- 755
			), -- 755
			2.2, -- 755
			toColor(PALETTE.rouge, 240) -- 755
		) -- 755
		fgDraw:drawDot( -- 756
			Vec2( -- 756
				cx - f * cam:len(10), -- 756
				topY + cam:len(9) -- 756
			), -- 756
			2.6, -- 756
			toColor(PALETTE.crimsonCore, 235) -- 756
		) -- 756
	end -- 756
end -- 711
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 761
	local s = p.room.scavenger -- 768
	if s == nil then -- 768
		return -- 770
	end -- 770
	local cx = cam:sx(p.scavX) -- 772
	local by = cam:sy(s.y) -- 773
	local H = cam:len(s.h) -- 774
	local W = cam:len(26) -- 775
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 776
	local alert = p.scavChase or p.scavSee > 0 -- 779
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 780
	local eyeY = by + H * 0.8 -- 781
	local coneLen = cam:len(alert and 155 or 115) -- 782
	fgGlow:drawVertices({ -- 783
		{ -- 784
			Vec2(cx + f * 6, eyeY), -- 784
			toColor(coneCol, alert and 78 or 34) -- 784
		}, -- 784
		{ -- 785
			Vec2(cx + f * coneLen, by + H * 1.05), -- 785
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 785
		}, -- 785
		{ -- 786
			Vec2(cx + f * coneLen, by + 4), -- 786
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 786
		} -- 786
	}) -- 786
	local frame = 0 -- 789
	if p.scavState == "turn" then -- 789
		frame = 2 -- 791
	elseif p.scavState == "chase" then -- 791
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 793
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 793
		frame = math.floor(self.animTime * 8) % 2 -- 795
	end -- 795
	if assets:tryPlace( -- 795
		"scavenger", -- 797
		"actor_scav", -- 797
		cx, -- 797
		by, -- 797
		W, -- 797
		H, -- 797
		{facing = f, frame = frame, layer = 3} -- 797
	) then -- 797
		return -- 798
	end -- 798
	fgDraw:drawEllipse( -- 801
		Vec2(cx, by + 1), -- 801
		W * 0.62, -- 801
		4, -- 801
		Color(4, 6, 10, 155) -- 801
	) -- 801
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 802
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 803
	fgDraw:drawSegment( -- 805
		Vec2(cx - 4, by + H * 0.4), -- 805
		Vec2(cx - stride, by + 2), -- 805
		W * 0.16, -- 805
		Color(32, 30, 28, 255) -- 805
	) -- 805
	fgDraw:drawSegment( -- 806
		Vec2(cx + 4, by + H * 0.4), -- 806
		Vec2(cx + stride, by + 2), -- 806
		W * 0.16, -- 806
		Color(44, 40, 36, 255) -- 806
	) -- 806
	fgDraw:drawPolygon( -- 808
		{ -- 808
			Vec2(cx - W * 0.45, by + H * 0.25), -- 809
			Vec2(cx + W * 0.42, by + H * 0.25), -- 810
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 811
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 812
		}, -- 812
		Color(56, 52, 46, 255), -- 813
		1.2, -- 813
		Color(128, 118, 100, 180) -- 813
	) -- 813
	local headX = cx + f * 5 -- 815
	local headY = by + H * 0.88 -- 816
	fgDraw:drawCircle( -- 817
		Vec2(headX, headY), -- 817
		W * 0.3, -- 817
		Color(42, 38, 34, 255) -- 817
	) -- 817
	fgGlow:drawDot( -- 818
		Vec2(headX + f * 6, headY), -- 818
		3, -- 818
		toColor(coneCol, 245) -- 818
	) -- 818
	local indY = by + H + 18 -- 821
	if p.scavChase then -- 821
		drawDiamond( -- 823
			fgGlow, -- 823
			cx, -- 823
			indY, -- 823
			9, -- 823
			12, -- 823
			toColor(PALETTE.crimson, 240), -- 823
			1.5, -- 823
			toColor(PALETTE.crimsonCore) -- 823
		) -- 823
	elseif p.scavSee > 0 then -- 823
		local frac = math.min(1, p.scavSee / 24) -- 825
		fgGlow:drawArc( -- 826
			Vec2(cx, indY), -- 826
			11, -- 826
			90, -- 826
			90 - 360 * frac, -- 826
			2.4, -- 826
			toColor(PALETTE.crimson, 235) -- 826
		) -- 826
		fgGlow:drawDot( -- 827
			Vec2(cx, indY), -- 827
			3, -- 827
			toColor(PALETTE.amber) -- 827
		) -- 827
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 827
		drawDiamond( -- 829
			fgGlow, -- 829
			cx, -- 829
			indY, -- 829
			6, -- 829
			8, -- 829
			toColor(PALETTE.amber, 220) -- 829
		) -- 829
	end -- 829
end -- 761
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 834
	local cx = cam:sx(p.dogX) -- 841
	local by = cam:sy(0) -- 842
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 843
	local W = cam:len(42) -- 844
	local H = cam:len(34) -- 845
	local frame = 0 -- 847
	if p.dogState == "ear" then -- 847
		frame = 1 -- 849
	elseif p.dogState == "sniff" then -- 849
		frame = 3 -- 851
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 851
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 853
	end -- 853
	if assets:tryPlace( -- 853
		"dog", -- 855
		"actor_dog", -- 855
		cx, -- 855
		by, -- 855
		W, -- 855
		H, -- 855
		{facing = f, frame = frame, layer = 3} -- 855
	) then -- 855
		return -- 856
	end -- 856
	fgDraw:drawEllipse( -- 859
		Vec2(cx, by + 1), -- 859
		W * 0.56, -- 859
		3.5, -- 859
		Color(4, 8, 10, 155) -- 859
	) -- 859
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 860
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 861
	fgDraw:drawSegment( -- 864
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 864
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 864
		2.8, -- 864
		Color(26, 30, 34, 255) -- 864
	) -- 864
	fgDraw:drawSegment( -- 865
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 865
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 865
		2.8, -- 865
		Color(36, 40, 44, 255) -- 865
	) -- 865
	fgDraw:drawPolygon( -- 867
		{ -- 867
			Vec2(cx - W * 0.42, by + H * 0.36), -- 868
			Vec2(cx + W * 0.38, by + H * 0.42), -- 869
			Vec2(cx + W * 0.34, by + H * 0.78), -- 870
			Vec2(cx - W * 0.38, by + H * 0.72) -- 871
		}, -- 871
		Color(38, 42, 48, 255), -- 872
		1.2, -- 872
		Color(102, 118, 126, 175) -- 872
	) -- 872
	local hx = cx + f * W * 0.42 -- 873
	local hy = by + H * 0.84 -- 874
	fgDraw:drawPolygon( -- 875
		{ -- 875
			Vec2(hx - f * 8, hy - 6), -- 876
			Vec2(hx + f * 12, hy - 2), -- 877
			Vec2(hx + f * 4, hy + 8), -- 878
			Vec2(hx - f * 6, hy + 14) -- 879
		}, -- 879
		Color(44, 48, 54, 255) -- 880
	) -- 880
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 882
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 883
	fgGlow:drawDot( -- 884
		Vec2(hx + f * 4, hy + 2), -- 884
		2.8, -- 884
		toColor(eyeCol, 250) -- 884
	) -- 884
	fillRadialGlow( -- 885
		fgGlow, -- 885
		hx + f * 4, -- 885
		hy + 2, -- 885
		16, -- 885
		16, -- 885
		toColor(eyeCol, alert and 135 or 70), -- 885
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 885
		12 -- 885
	) -- 885
	if alert then -- 885
		local r = 12 + self.animTime * 42 % 24 -- 888
		fgGlow:drawArc( -- 889
			Vec2(hx, hy + 12), -- 889
			r, -- 889
			35, -- 889
			145, -- 889
			1.8, -- 889
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 889
		) -- 889
	end -- 889
end -- 834
return ____exports -- 834