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
local ____theme = require("Script.watch.fe.theme") -- 8
local PALETTE = ____theme.PALETTE -- 8
local drawDiamond = ____theme.drawDiamond -- 8
local fillRadialGlow = ____theme.fillRadialGlow -- 8
local toColor = ____theme.toColor -- 8
____exports.ActorsRenderer = __TS__Class() -- 20
local ActorsRenderer = ____exports.ActorsRenderer -- 20
ActorsRenderer.name = "ActorsRenderer" -- 20
function ActorsRenderer.prototype.____constructor(self) -- 20
	self.ghosts = {} -- 21
	self.ghostCooldown = 0 -- 22
	self.animTime = 0 -- 23
	self.previousHp = 3 -- 24
	self.previousAxle = 0 -- 25
	self.cartMoving = false -- 26
	self.previousBottle = false -- 27
	self.hitUntil = -1 -- 29
	self.throwUntil = -1 -- 30
	self.shotUntil = -1 -- 31
end -- 20
function ActorsRenderer.prototype.reset(self, p) -- 33
	self.ghosts = {} -- 34
	self.ghostCooldown = 0 -- 35
	self.animTime = 0 -- 36
	self.previousHp = p.hp -- 37
	self.previousAxle = p.cartAxle -- 38
	self.cartMoving = false -- 39
	self.previousBottle = p.hasBottle -- 40
	self.previousTrace = p.trace -- 41
	self.hitUntil = -1 -- 42
	self.throwUntil = -1 -- 43
	self.shotUntil = -1 -- 44
end -- 33
function ActorsRenderer.prototype.update(self, dt, p) -- 48
	self.animTime = self.animTime + dt -- 49
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 49
		self.hitUntil = p.ticks + 14 -- 51
	end -- 51
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 51
		self.throwUntil = p.ticks + 12 -- 54
	end -- 54
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 54
		self.shotUntil = p.ticks + 7 -- 57
	end -- 57
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 59
	self.previousAxle = p.cartAxle -- 60
	self.previousHp = p.hp -- 61
	self.previousBottle = p.hasBottle -- 62
	self.previousTrace = p.trace -- 63
	if not p.childMode and p.player.rollT > 0 then -- 63
		self.ghostCooldown = self.ghostCooldown - dt -- 66
		if self.ghostCooldown <= 0 then -- 66
			local ____self_ghosts_0 = self.ghosts -- 66
			____self_ghosts_0[#____self_ghosts_0 + 1] = { -- 68
				x = p.player.x, -- 69
				y = p.player.y, -- 70
				h = p.player.h, -- 71
				facing = p.player.facing, -- 72
				life = 0.28, -- 73
				maxLife = 0.28, -- 74
				isRoll = true -- 75
			} -- 75
			self.ghostCooldown = 0.036 -- 77
		end -- 77
	else -- 77
		self.ghostCooldown = 0 -- 80
	end -- 80
	local write = 0 -- 84
	local i = 0 -- 85
	do -- 85
		i = 0 -- 86
		while i < #self.ghosts do -- 86
			local g = self.ghosts[i + 1] -- 87
			g.life = g.life - dt -- 88
			if g.life > 0 then -- 88
				self.ghosts[write + 1] = g -- 90
				write = write + 1 -- 91
			end -- 91
			i = i + 1 -- 86
		end -- 86
	end -- 86
	__TS__ArraySetLength(self.ghosts, write) -- 86
end -- 48
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam) -- 97
	self:drawAfterimages(fgGlow, cam) -- 105
	local i = 0 -- 108
	do -- 108
		i = 0 -- 109
		while i < #p.enemies do -- 109
			self:drawEnemy( -- 110
				fgDraw, -- 110
				fgGlow, -- 110
				assets, -- 110
				p.enemies[i + 1], -- 110
				i, -- 110
				p, -- 110
				cam -- 110
			) -- 110
			i = i + 1 -- 109
		end -- 109
	end -- 109
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 109
		self:drawScavenger( -- 115
			fgDraw, -- 115
			fgGlow, -- 115
			assets, -- 115
			p, -- 115
			cam -- 115
		) -- 115
	end -- 115
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 115
		self:drawDog( -- 120
			fgDraw, -- 120
			fgGlow, -- 120
			assets, -- 120
			p, -- 120
			cam -- 120
		) -- 120
	end -- 120
	if p.partner.alive then -- 120
		local partnerIsChild = p.partner.w <= 28 -- 125
		if partnerIsChild then -- 125
			self:drawXiaoman( -- 127
				fgDraw, -- 127
				fgGlow, -- 127
				assets, -- 127
				p.partner, -- 127
				p, -- 127
				cam, -- 127
				false -- 127
			) -- 127
		else -- 127
			self:drawZhouShu( -- 129
				fgDraw, -- 129
				fgGlow, -- 129
				assets, -- 129
				p.partner, -- 129
				p, -- 129
				cam, -- 129
				false -- 129
			) -- 129
		end -- 129
	end -- 129
	if p.player.alive then -- 129
		if p.childMode then -- 129
			self:drawXiaoman( -- 136
				fgDraw, -- 136
				fgGlow, -- 136
				assets, -- 136
				p.player, -- 136
				p, -- 136
				cam, -- 136
				true -- 136
			) -- 136
		else -- 136
			self:drawZhouShu( -- 138
				fgDraw, -- 138
				fgGlow, -- 138
				assets, -- 138
				p.player, -- 138
				p, -- 138
				cam, -- 138
				true -- 138
			) -- 138
		end -- 138
	end -- 138
end -- 97
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 143
	local i = 0 -- 144
	do -- 144
		i = 0 -- 145
		while i < #self.ghosts do -- 145
			local g = self.ghosts[i + 1] -- 146
			local k = g.life / g.maxLife -- 147
			local cx = cam:sx(g.x) -- 148
			local by = cam:sy(g.y) -- 149
			local h = cam:len(g.h * 0.68) -- 150
			local w = cam:len(28) -- 151
			local f = g.facing -- 152
			fgGlow:drawPolygon( -- 154
				{ -- 154
					Vec2(cx - f * w * 0.9, by + 4), -- 155
					Vec2(cx + f * w * 0.55, by + 6), -- 156
					Vec2(cx + f * w * 0.85, by + h * 0.72), -- 157
					Vec2(cx - f * w * 0.15, by + h), -- 158
					Vec2(cx - f * w * 0.85, by + h * 0.58) -- 159
				}, -- 159
				toColor(PALETTE.cyan, 115 * k) -- 160
			) -- 160
			fgGlow:drawSegment( -- 162
				Vec2(cx - f * w * 1.15, by + h * 0.62), -- 163
				Vec2(cx + f * w * 0.72, by + h * 0.76), -- 164
				2.2 * k, -- 165
				toColor(PALETTE.cyanCore, 165 * k) -- 166
			) -- 166
			i = i + 1 -- 145
		end -- 145
	end -- 145
end -- 143
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 172
	local cx = cam:sx(a.x) -- 181
	local by = cam:sy(a.y) -- 182
	local H = cam:len(a.h) -- 183
	local W = cam:len(a.w) -- 184
	local f = a.facing -- 185
	local slot = "soldier_idle" -- 187
	local height = H -- 188
	local frame = 0 -- 189
	local facing = f -- 190
	local step = math.floor(self.animTime * 10) -- 191
	if isControlled and p.ticks < self.hitUntil then -- 191
		slot = "soldier_hit" -- 193
	elseif a.rollT > 0 then -- 193
		slot = "soldier_roll" -- 195
		height = height * 0.59 -- 196
	elseif p.phase == "prologue-give" then -- 196
		slot = "soldier_offer" -- 198
		height = height * 0.75 -- 199
		facing = p.partner.x >= a.x and 1 or -1 -- 200
	elseif isControlled and p.gripping then -- 200
		slot = "soldier_push" -- 202
		frame = self.cartMoving and step or 0 -- 203
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 204
		height = height * 0.91 -- 205
	elseif isControlled and p.escort.state == "calming" then -- 205
		slot = "soldier_knock" -- 207
		local calm = p.escort.calmTick -- 208
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 209
		height = height * 0.76 -- 210
	else -- 210
		local ____temp_3 = p.phase == "gate-send" -- 211
		if ____temp_3 then -- 211
			local ____opt_1 = p.room.story -- 211
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 211
		end -- 211
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and math.abs(a.vx) <= 8 then -- 211
			slot = "soldier_hold" -- 213
			height = height * 1.11 -- 214
		elseif isControlled and p.ticks < self.shotUntil then -- 214
			slot = "soldier_fire" -- 216
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 217
		elseif a.covered or isControlled and p.coverHug then -- 217
			slot = "soldier_cover" -- 219
			height = height * 0.77 -- 220
		elseif math.abs(a.vx) > 8 then -- 220
			slot = "soldier_run" -- 222
			frame = step -- 223
		end -- 223
	end -- 223
	if assets:tryPlace( -- 223
		slot, -- 225
		"actor_soldier", -- 225
		cx, -- 225
		by, -- 225
		W, -- 225
		height, -- 225
		{facing = facing, frame = frame, layer = 4} -- 225
	) then -- 225
		fgDraw:drawEllipse( -- 226
			Vec2(cx, by + 1), -- 226
			W * 0.54, -- 226
			4, -- 226
			Color(12, 11, 13, 145) -- 226
		) -- 226
		return -- 227
	end -- 227
	fgDraw:drawEllipse( -- 231
		Vec2(cx, by + 1), -- 231
		H * 0.24, -- 231
		4.5, -- 231
		Color(3, 5, 10, 175) -- 231
	) -- 231
	local speed = math.abs(a.vx) -- 233
	local walking = speed > 10 and a.onGround -- 234
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 235
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 236
	local calming = not p.childMode and p.escort.state == "calming" -- 237
	local rolling = a.rollT > 0 -- 238
	local crouching = a.covered or calming or rolling -- 239
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 242
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 243
	local sw = H * 0.115 -- 244
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 247
	local kneeY = by + bodyH * 0.23 -- 248
	local stepX = stride * H * 0.15 -- 249
	local legDark = Color(14, 21, 34, 255) -- 250
	local legFront = Color(26, 38, 58, 255) -- 251
	local bkX = cx - f * 4 - stepX * 0.5 -- 253
	local bfX = cx - f * 8 - stepX -- 254
	fgDraw:drawSegment( -- 255
		Vec2(cx - f * 3, hipY), -- 255
		Vec2(bkX, kneeY), -- 255
		H * 0.044, -- 255
		legDark -- 255
	) -- 255
	fgDraw:drawSegment( -- 256
		Vec2(bkX, kneeY), -- 256
		Vec2(bfX, by + 3), -- 256
		H * 0.038, -- 256
		legDark -- 256
	) -- 256
	local fkX = cx + f * 6 + stepX * 0.55 -- 258
	local ffX = cx + f * 7 + stepX -- 259
	fgDraw:drawSegment( -- 260
		Vec2(cx + f * 3, hipY), -- 260
		Vec2(fkX, kneeY), -- 260
		H * 0.048, -- 260
		legFront -- 260
	) -- 260
	fgDraw:drawSegment( -- 261
		Vec2(fkX, kneeY), -- 261
		Vec2(ffX, by + 3), -- 261
		H * 0.042, -- 261
		legFront -- 261
	) -- 261
	fgDraw:drawSegment( -- 263
		Vec2(ffX - f * 2, by + 3), -- 263
		Vec2(ffX + f * 9, by + 3), -- 263
		3.4, -- 263
		Color(42, 60, 86, 255) -- 263
	) -- 263
	fgGlow:drawDot( -- 264
		Vec2(fkX + f * 2, kneeY), -- 264
		2.3, -- 264
		toColor(PALETTE.cyan, 195) -- 264
	) -- 264
	local shY = by + bodyH * 0.8 + bob -- 267
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 268
	fgDraw:drawPolygon( -- 269
		{ -- 269
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 270
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 271
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 272
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 273
		}, -- 273
		Color(16, 26, 42, 248), -- 274
		1.2, -- 274
		Color(64, 118, 164, 195) -- 274
	) -- 274
	fgDraw:drawPolygon( -- 277
		{ -- 277
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 278
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 279
			Vec2(cx + sw * 1.05 + lean, shY), -- 280
			Vec2(cx - sw * 0.98 + lean, shY) -- 281
		}, -- 281
		Color(24, 38, 60, 255), -- 282
		1.3, -- 282
		toColor(PALETTE.rimSilver, 190) -- 282
	) -- 282
	fgDraw:drawSegment( -- 284
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 285
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 286
		2.4, -- 287
		Color(196, 232, 248, 220) -- 288
	) -- 288
	fgDraw:drawPolygon( -- 291
		{ -- 291
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 292
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 293
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 294
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 295
		}, -- 295
		Color(218, 240, 252, 248) -- 296
	) -- 296
	fgGlow:drawSegment( -- 297
		Vec2(cx - sw * 0.9 + lean, shY - 1), -- 298
		Vec2(cx + sw * 0.95 + lean, shY + 1), -- 299
		1.8, -- 300
		toColor(PALETTE.cyan, 230) -- 301
	) -- 301
	local headR = H * 0.088 -- 305
	local headX = cx + lean + f * 3 -- 306
	local headY = shY + headR * 1.35 -- 307
	fgDraw:drawCircle( -- 308
		Vec2(headX, headY), -- 308
		headR, -- 308
		Color(20, 32, 50, 255) -- 308
	) -- 308
	fgDraw:drawPolygon( -- 310
		{ -- 310
			Vec2(headX - f * headR * 1.18, headY + headR * 0.15), -- 311
			Vec2(headX - f * headR * 0.45, headY + headR * 1.18), -- 312
			Vec2(headX + f * headR * 0.92, headY + headR * 0.72), -- 313
			Vec2(headX + f * headR * 0.25, headY + headR * 0.18) -- 314
		}, -- 314
		Color(224, 244, 255, 245) -- 315
	) -- 315
	local vx0 = headX + f * headR * 0.12 -- 317
	local vx1 = headX + f * headR * 1.05 -- 318
	fgGlow:drawSegment( -- 319
		Vec2(vx0, headY - 1), -- 319
		Vec2(vx1, headY + 1.5), -- 319
		2.5, -- 319
		toColor(PALETTE.cyanCore, 255) -- 319
	) -- 319
	fgGlow:drawSegment( -- 320
		Vec2(vx0 - f * 5, headY - 1), -- 320
		Vec2(vx1 + f * 4, headY + 2), -- 320
		1.1, -- 320
		toColor(PALETTE.cyan, 165) -- 320
	) -- 320
	fillRadialGlow( -- 321
		fgGlow, -- 321
		vx1, -- 321
		headY + 1, -- 321
		18, -- 321
		10, -- 321
		toColor(PALETTE.cyan, 125), -- 321
		Color(72, 224, 255, 0), -- 321
		12 -- 321
	) -- 321
	if isControlled and not calming and not rolling and not p.gripping then -- 321
		local gunPivotX = cx + lean + f * sw * 0.35 -- 325
		local gunPivotY = shY - bodyH * 0.1 -- 326
		local aimDx = f -- 327
		local aimDy = 0 -- 328
		if p.aimX > 0 or p.aimY > 0 then -- 328
			aimDx = p.aimX - gunPivotX -- 330
			aimDy = p.aimY - gunPivotY -- 331
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 332
			if dLen > 4 then -- 332
				aimDx = aimDx / dLen -- 334
				aimDy = aimDy / dLen -- 335
			end -- 335
		end -- 335
		local barrelLen = H * 0.34 -- 338
		local tipX = gunPivotX + aimDx * barrelLen -- 339
		local tipY = gunPivotY + aimDy * barrelLen -- 340
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 341
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 342
		fgDraw:drawSegment( -- 344
			Vec2(cx + lean, shY - 5), -- 344
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 344
			3.6, -- 344
			Color(26, 40, 62, 255) -- 344
		) -- 344
		fgDraw:drawSegment( -- 346
			Vec2(stockX, stockY), -- 346
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 346
			4.6, -- 346
			Color(34, 48, 70, 255) -- 346
		) -- 346
		fgDraw:drawSegment( -- 347
			Vec2(gunPivotX, gunPivotY), -- 347
			Vec2(tipX, tipY), -- 347
			2.4, -- 347
			Color(166, 202, 232, 235) -- 347
		) -- 347
		fgGlow:drawSegment( -- 349
			Vec2(gunPivotX + aimDx * 6, gunPivotY + aimDy * 6 + 2.5), -- 350
			Vec2(gunPivotX + aimDx * barrelLen * 0.68, gunPivotY + aimDy * barrelLen * 0.68 + 2.5), -- 351
			1.4, -- 352
			toColor(PALETTE.cyan, 230) -- 353
		) -- 353
		fgGlow:drawDot( -- 355
			Vec2(tipX, tipY), -- 355
			2.6, -- 355
			toColor(PALETTE.cyanCore, 230) -- 355
		) -- 355
	elseif calming then -- 355
		fgDraw:drawSegment( -- 357
			Vec2(cx + lean, shY - 6), -- 357
			Vec2(cx + f * sw * 2.1, shY - 14), -- 357
			3, -- 357
			Color(196, 222, 240, 235) -- 357
		) -- 357
		fgGlow:drawDot( -- 358
			Vec2(cx + f * sw * 2.15, shY - 14), -- 358
			3.6, -- 358
			toColor(PALETTE.amber, 225) -- 358
		) -- 358
	end -- 358
	if a.covered then -- 358
		local shieldX = cx + f * (sw * 1.85) -- 363
		fgGlow:drawSegment( -- 364
			Vec2(shieldX, by + 6), -- 364
			Vec2(shieldX, by + bodyH * 0.92), -- 364
			2.8, -- 364
			toColor(PALETTE.cyan, 240) -- 364
		) -- 364
		fgGlow:drawSegment( -- 365
			Vec2(shieldX - f * 9, by + bodyH * 0.96), -- 365
			Vec2(shieldX + f * 4, by + bodyH * 0.92), -- 365
			2, -- 365
			toColor(PALETTE.cyanCore, 230) -- 365
		) -- 365
		fillRadialGlow( -- 366
			fgGlow, -- 366
			shieldX, -- 366
			by + bodyH * 0.5, -- 366
			20, -- 366
			bodyH * 0.52, -- 366
			toColor(PALETTE.cyan, 82), -- 366
			Color(72, 224, 255, 0), -- 366
			14 -- 366
		) -- 366
	end -- 366
end -- 172
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 371
	local cx = cam:sx(a.x) -- 380
	local by = cam:sy(a.y) -- 381
	local H = cam:len(a.h) -- 382
	local W = cam:len(a.w) -- 383
	local f = a.facing -- 384
	local afraid = not isControlled and p.escort.fear > 0 -- 386
	local slot = "child_idle" -- 387
	local height = H -- 388
	local frame = 0 -- 389
	local step = math.floor(self.animTime * 10) -- 390
	local nearCover = __TS__ArraySome( -- 391
		p.room.solids, -- 391
		function(____, solid) return solid.h <= 64 and solid.y <= 2 and math.min( -- 391
			math.abs(a.x - solid.x), -- 393
			math.abs(a.x - solid.x - solid.w) -- 393
		) <= 30 end -- 393
	) -- 393
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 393
		slot = "child_knock" -- 396
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 396
		slot = "child_offer" -- 399
	elseif isControlled and p.ticks < self.throwUntil then -- 399
		slot = "child_throw" -- 401
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 401
		slot = "child_aim" -- 403
	elseif isControlled and p.gripping then -- 403
		slot = "child_pull" -- 405
		frame = self.cartMoving and step or 0 -- 406
	elseif afraid and p.escort.state == "frozen" then -- 406
		slot = "child_fear" -- 408
		height = height * 0.74 -- 409
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and math.abs(a.vx) < 8 then -- 409
		slot = "child_peek" -- 412
		height = height * 0.83 -- 413
	elseif a.crouch then -- 413
		slot = "child_crouch" -- 415
		frame = math.abs(a.vx) > 8 and step or 0 -- 416
	elseif math.abs(a.vx) > 8 then -- 416
		slot = "child_run" -- 418
		frame = step -- 419
	end -- 419
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 421
	if assets:tryPlace( -- 421
		slot, -- 422
		"actor_child", -- 422
		cx, -- 422
		by, -- 422
		W, -- 422
		height, -- 422
		{facing = facing, frame = frame, layer = 5} -- 422
	) then -- 422
		fgDraw:drawEllipse( -- 423
			Vec2(cx, by + 1), -- 423
			W * 0.48, -- 423
			3, -- 423
			Color(12, 11, 13, 125) -- 423
		) -- 423
		if afraid then -- 423
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 425
		end -- 425
		return -- 427
	end -- 427
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 430
	local x = cx + jitter -- 431
	local fullRef = a.crouch and H * 1.35 or H -- 433
	local cw = fullRef * 0.16 -- 434
	fgDraw:drawEllipse( -- 437
		Vec2(x, by + 1), -- 437
		cw * 1.15, -- 437
		3.6, -- 437
		Color(4, 6, 10, 155) -- 437
	) -- 437
	local speed = math.abs(a.vx) -- 439
	local walking = speed > 6 and a.onGround -- 440
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 441
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 442
	local hipY = by + H * 0.3 -- 445
	local legSwing = stride * cw * 0.85 -- 446
	fgDraw:drawSegment( -- 447
		Vec2(x - 2, hipY), -- 447
		Vec2(x - legSwing, by + 2), -- 447
		math.max(2.6, cw * 0.22), -- 447
		Color(34, 30, 38, 255) -- 447
	) -- 447
	fgDraw:drawSegment( -- 448
		Vec2(x + 2, hipY), -- 448
		Vec2(x + legSwing, by + 2), -- 448
		math.max(2.8, cw * 0.24), -- 448
		Color(52, 46, 56, 255) -- 448
	) -- 448
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 451
	local cloakBotY = by + H * 0.2 -- 452
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 453
	fgDraw:drawPolygon( -- 454
		{ -- 454
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 455
			Vec2(x + cw * 0.92, cloakBotY), -- 456
			Vec2(x + cw * 0.62, cloakTopY), -- 457
			Vec2(x - cw * 0.68, cloakTopY) -- 458
		}, -- 458
		Color(214, 166, 94, 255), -- 459
		1.3, -- 459
		Color(252, 232, 192, 225) -- 459
	) -- 459
	fgDraw:drawPolygon( -- 460
		{ -- 460
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 461
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 462
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 463
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 464
		}, -- 464
		Color(148, 108, 56, 215) -- 465
	) -- 465
	fgDraw:drawSegment( -- 466
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 466
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 466
		1.8, -- 466
		toColor(PALETTE.amberCore, 200) -- 466
	) -- 466
	local scarfY = cloakTopY - 2 -- 469
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 470
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 471
	local sendX = x - f * cw * 1.65 + cloakDrag -- 472
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 473
	fgDraw:drawQuadraticBezier( -- 474
		Vec2(x - f * cw * 0.3, scarfY), -- 474
		Vec2(smidX, smidY), -- 474
		Vec2(sendX, sendY), -- 474
		2.8, -- 474
		toColor(PALETTE.amberCore, 235) -- 474
	) -- 474
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 477
	local headX = x + f * (a.crouch and 5 or 2) -- 478
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 479
	fgDraw:drawCircle( -- 480
		Vec2(headX, headY), -- 480
		headR, -- 480
		Color(240, 222, 198, 255) -- 480
	) -- 480
	fgDraw:drawPolygon( -- 482
		{ -- 482
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 483
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 484
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 485
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 486
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 487
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 488
		}, -- 488
		Color(156, 114, 62, 248), -- 489
		1.1, -- 489
		Color(244, 214, 162, 200) -- 489
	) -- 489
	fgGlow:drawDot( -- 491
		Vec2(headX + f * headR * 0.45, headY + 1), -- 491
		2.2, -- 491
		toColor(PALETTE.amberCore) -- 491
	) -- 491
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 494
	if hasCompass then -- 494
		local compX = x + f * cw * 0.65 -- 496
		local compY = by + H * 0.48 -- 497
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 498
		fgGlow:drawDot( -- 499
			Vec2(compX, compY), -- 499
			2.6, -- 499
			toColor(PALETTE.amberCore, 250) -- 499
		) -- 499
		fillRadialGlow( -- 500
			fgGlow, -- 500
			compX, -- 500
			compY, -- 500
			26 * glowPulse, -- 500
			26 * glowPulse, -- 500
			Color(248, 206, 120, 78 * glowPulse), -- 500
			Color(248, 180, 72, 0), -- 500
			14 -- 500
		) -- 500
	end -- 500
	if afraid then -- 500
		self:drawFear(fgGlow, p, x, by + H + 16) -- 504
	end -- 504
	if isControlled and walking and not a.crouch and speed > 100 then -- 504
		local r = 10 + self.animTime * 32 % 24 -- 509
		fgGlow:drawRing( -- 510
			Vec2(x, by + 3), -- 510
			r, -- 510
			r + 1.5, -- 510
			Color(0, 0, 0, 0), -- 510
			1.1, -- 510
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 510
		) -- 510
	end -- 510
end -- 371
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 514
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 515
	do -- 515
		local i = 0 -- 516
		while i < FEAR_MAX do -- 516
			local lit = i < p.escort.fear -- 517
			drawDiamond( -- 518
				fgGlow, -- 518
				x + (i - 1) * 13, -- 518
				y, -- 518
				4, -- 518
				5, -- 518
				toColor(lit and tint or PALETTE.steelDark, 215), -- 519
				1, -- 519
				toColor(tint, lit and 235 or 100) -- 519
			) -- 519
			i = i + 1 -- 516
		end -- 516
	end -- 516
end -- 514
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 523
	local x = cam:sx(e.x + f * 20) -- 524
	local y = cam:sy(e.y + e.h * 0.69) -- 525
	local dx = cam:sx(p.player.x) - x -- 526
	local dy = cam:sy(p.player.y + p.player.h * 0.56) - y -- 527
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 528
	do -- 528
		local i = 0 -- 529
		while i < 8 do -- 529
			local a = length * i / 8 -- 530
			local b = length * (i + 1) / 8 -- 531
			fgGlow:drawSegment( -- 532
				Vec2(x + dx * a, y + dy * a), -- 532
				Vec2(x + dx * b, y + dy * b), -- 532
				1.3, -- 533
				toColor(PALETTE.crimsonCore, 200) -- 533
			) -- 533
			i = i + 2 -- 529
		end -- 529
	end -- 529
end -- 523
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 538
	local cx = cam:sx(e.x) -- 547
	local by = cam:sy(e.y) -- 548
	local H = cam:len(e.h) -- 549
	local W = cam:len(e.w) -- 550
	local f = p.player.x >= e.x and 1 or -1 -- 551
	local slot = "enemy_idle" -- 553
	if not e.alive then -- 553
		slot = "enemy_down" -- 555
	elseif e.hitT > 0 then -- 555
		slot = "enemy_hit" -- 557
	elseif e.warnT > 0 then -- 557
		slot = "enemy_aim" -- 559
	end -- 559
	local height = e.alive and H or H * 0.24 -- 561
	if assets:tryPlace( -- 561
		slot, -- 562
		"actor_enemy_" .. tostring(index), -- 562
		cx, -- 562
		by, -- 562
		W, -- 562
		height, -- 562
		{facing = f, opacity = e.alive and 1 or 0.78, layer = 3} -- 562
	) then -- 562
		if e.alive and e.warnT > 0 then -- 562
			self:drawEnemyWarning( -- 566
				fgGlow, -- 566
				e, -- 566
				p, -- 566
				cam, -- 566
				f -- 566
			) -- 566
		end -- 566
		return -- 568
	end -- 568
	if not e.alive then -- 568
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 572
		fgDraw:drawPolygon( -- 573
			{ -- 573
				Vec2(cx - H * 0.3, by), -- 574
				Vec2(cx + H * 0.28, by), -- 575
				Vec2(cx + H * 0.2, by + H * 0.14), -- 576
				Vec2(cx - H * 0.24, by + H * 0.11) -- 577
			}, -- 577
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 578
		) -- 578
		if flash > 0 then -- 578
			fillRadialGlow( -- 580
				fgGlow, -- 580
				cx, -- 580
				by + 12, -- 580
				34 * flash, -- 580
				18 * flash, -- 580
				toColor(PALETTE.crimson, 180 * flash), -- 580
				Color(255, 48, 82, 0), -- 580
				12 -- 580
			) -- 580
		end -- 580
		return -- 582
	end -- 582
	local sw = H * 0.112 -- 585
	fgDraw:drawEllipse( -- 586
		Vec2(cx, by + 1), -- 586
		sw * 1.9, -- 586
		4, -- 586
		Color(4, 6, 10, 165) -- 586
	) -- 586
	local hipY = by + H * 0.44 -- 589
	local kneeY = by + H * 0.23 -- 590
	local shY = by + H * 0.79 -- 591
	fgDraw:drawSegment( -- 592
		Vec2(cx - 5, hipY), -- 592
		Vec2(cx - 7, kneeY), -- 592
		H * 0.044, -- 592
		Color(20, 16, 26, 255) -- 592
	) -- 592
	fgDraw:drawSegment( -- 593
		Vec2(cx - 7, kneeY), -- 593
		Vec2(cx - 8, by + 2), -- 593
		H * 0.038, -- 593
		Color(20, 16, 26, 255) -- 593
	) -- 593
	fgDraw:drawSegment( -- 594
		Vec2(cx + 5, hipY), -- 594
		Vec2(cx + 7, kneeY), -- 594
		H * 0.046, -- 594
		Color(28, 22, 36, 255) -- 594
	) -- 594
	fgDraw:drawSegment( -- 595
		Vec2(cx + 7, kneeY), -- 595
		Vec2(cx + 8, by + 2), -- 595
		H * 0.04, -- 595
		Color(28, 22, 36, 255) -- 595
	) -- 595
	fgDraw:drawPolygon( -- 597
		{ -- 597
			Vec2(cx - sw * 0.68, hipY), -- 598
			Vec2(cx + sw * 0.68, hipY), -- 599
			Vec2(cx + sw * 1.12, shY), -- 600
			Vec2(cx - sw * 1.12, shY) -- 601
		}, -- 601
		Color(30, 22, 36, 255), -- 602
		1.3, -- 602
		Color(134, 52, 72, 210) -- 602
	) -- 602
	fgDraw:drawPolygon( -- 604
		{ -- 604
			Vec2(cx - sw * 1.26, shY - 6), -- 605
			Vec2(cx + sw * 1.26, shY - 6), -- 606
			Vec2(cx + sw * 0.96, shY + 5), -- 607
			Vec2(cx - sw * 0.96, shY + 5) -- 608
		}, -- 608
		Color(44, 28, 44, 255), -- 609
		1.2, -- 609
		toColor(PALETTE.crimson, 200) -- 609
	) -- 609
	local headR = H * 0.086 -- 612
	local headY = shY + headR * 1.32 -- 613
	fgDraw:drawPolygon( -- 614
		{ -- 614
			Vec2(cx - headR * 0.95, headY - headR * 0.8), -- 615
			Vec2(cx + headR * 0.95, headY - headR * 0.8), -- 616
			Vec2(cx + headR * 0.65, headY + headR * 1.05), -- 617
			Vec2(cx - headR * 0.65, headY + headR * 1.05) -- 618
		}, -- 618
		Color(22, 16, 28, 255), -- 619
		1.1, -- 619
		Color(138, 48, 68, 220) -- 619
	) -- 619
	fgGlow:drawSegment( -- 620
		Vec2(cx + f * 1, headY), -- 621
		Vec2(cx + f * headR * 0.98, headY + 1.5), -- 622
		2.5, -- 623
		toColor(PALETTE.crimson, 255) -- 624
	) -- 624
	fillRadialGlow( -- 626
		fgGlow, -- 626
		cx + f * headR * 0.6, -- 626
		headY + 1, -- 626
		18, -- 626
		10, -- 626
		toColor(PALETTE.crimson, 125), -- 626
		Color(255, 48, 82, 0), -- 626
		12 -- 626
	) -- 626
	local gunX = cx + f * H * 0.34 -- 629
	local gunY = by + H * 0.69 -- 630
	fgDraw:drawSegment( -- 631
		Vec2(cx - f * 6, gunY), -- 631
		Vec2(gunX, gunY), -- 631
		3.6, -- 631
		Color(46, 34, 52, 255) -- 631
	) -- 631
	fgGlow:drawDot( -- 632
		Vec2(gunX, gunY), -- 632
		2.4, -- 632
		toColor(PALETTE.crimson, 220) -- 632
	) -- 632
	if e.warnT > 0 then -- 632
		local urgency = 1 - math.min(1, e.warnT / 36) -- 636
		local tx = cam:sx(p.player.x) -- 637
		local ty = cam:sy(p.player.y + p.player.h * 0.56) -- 638
		local flash = e.warnT < 10 and 0.55 + 0.45 * math.sin(self.animTime * 48) or 1 -- 639
		fgGlow:drawSegment( -- 641
			Vec2(gunX, gunY), -- 641
			Vec2(tx, ty), -- 641
			3.2 * (0.6 + urgency * 0.7), -- 641
			toColor(PALETTE.crimson, 85 * flash) -- 641
		) -- 641
		fgGlow:drawSegment( -- 642
			Vec2(gunX, gunY), -- 642
			Vec2(tx, ty), -- 642
			1.2, -- 642
			toColor(PALETTE.crimsonCore, 235 * flash) -- 642
		) -- 642
		local retR = 18 - urgency * 11 -- 644
		drawDiamond( -- 645
			fgGlow, -- 645
			gunX, -- 645
			gunY, -- 645
			retR, -- 645
			retR, -- 645
			Color(255, 48, 82, 40), -- 645
			1.6, -- 645
			toColor(PALETTE.crimson, 240 * flash) -- 645
		) -- 645
		fillRadialGlow( -- 646
			fgGlow, -- 646
			gunX, -- 646
			gunY, -- 646
			24, -- 646
			24, -- 646
			toColor(PALETTE.crimson, 140 * flash), -- 646
			Color(255, 48, 82, 0), -- 646
			14 -- 646
		) -- 646
	end -- 646
end -- 538
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 651
	local s = p.room.scavenger -- 658
	if s == nil then -- 658
		return -- 660
	end -- 660
	local cx = cam:sx(p.scavX) -- 662
	local by = cam:sy(s.y) -- 663
	local H = cam:len(s.h) -- 664
	local W = cam:len(26) -- 665
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 666
	local alert = p.scavChase or p.scavSee > 0 -- 669
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 670
	local eyeY = by + H * 0.8 -- 671
	local coneLen = cam:len(alert and 155 or 115) -- 672
	fgGlow:drawVertices({ -- 673
		{ -- 674
			Vec2(cx + f * 6, eyeY), -- 674
			toColor(coneCol, alert and 78 or 34) -- 674
		}, -- 674
		{ -- 675
			Vec2(cx + f * coneLen, by + H * 1.05), -- 675
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 675
		}, -- 675
		{ -- 676
			Vec2(cx + f * coneLen, by + 4), -- 676
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 676
		} -- 676
	}) -- 676
	local frame = 0 -- 679
	if p.scavState == "turn" then -- 679
		frame = 2 -- 681
	elseif p.scavState == "chase" then -- 681
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 683
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 683
		frame = math.floor(self.animTime * 8) % 2 -- 685
	end -- 685
	if assets:tryPlace( -- 685
		"scavenger", -- 687
		"actor_scav", -- 687
		cx, -- 687
		by, -- 687
		W, -- 687
		H, -- 687
		{facing = f, frame = frame, layer = 3} -- 687
	) then -- 687
		return -- 688
	end -- 688
	fgDraw:drawEllipse( -- 691
		Vec2(cx, by + 1), -- 691
		W * 0.62, -- 691
		4, -- 691
		Color(4, 6, 10, 155) -- 691
	) -- 691
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 692
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 693
	fgDraw:drawSegment( -- 695
		Vec2(cx - 4, by + H * 0.4), -- 695
		Vec2(cx - stride, by + 2), -- 695
		W * 0.16, -- 695
		Color(32, 30, 28, 255) -- 695
	) -- 695
	fgDraw:drawSegment( -- 696
		Vec2(cx + 4, by + H * 0.4), -- 696
		Vec2(cx + stride, by + 2), -- 696
		W * 0.16, -- 696
		Color(44, 40, 36, 255) -- 696
	) -- 696
	fgDraw:drawPolygon( -- 698
		{ -- 698
			Vec2(cx - W * 0.45, by + H * 0.25), -- 699
			Vec2(cx + W * 0.42, by + H * 0.25), -- 700
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 701
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 702
		}, -- 702
		Color(56, 52, 46, 255), -- 703
		1.2, -- 703
		Color(128, 118, 100, 180) -- 703
	) -- 703
	local headX = cx + f * 5 -- 705
	local headY = by + H * 0.88 -- 706
	fgDraw:drawCircle( -- 707
		Vec2(headX, headY), -- 707
		W * 0.3, -- 707
		Color(42, 38, 34, 255) -- 707
	) -- 707
	fgGlow:drawDot( -- 708
		Vec2(headX + f * 6, headY), -- 708
		3, -- 708
		toColor(coneCol, 245) -- 708
	) -- 708
	local indY = by + H + 18 -- 711
	if p.scavChase then -- 711
		drawDiamond( -- 713
			fgGlow, -- 713
			cx, -- 713
			indY, -- 713
			9, -- 713
			12, -- 713
			toColor(PALETTE.crimson, 240), -- 713
			1.5, -- 713
			toColor(PALETTE.crimsonCore) -- 713
		) -- 713
	elseif p.scavSee > 0 then -- 713
		local frac = math.min(1, p.scavSee / 24) -- 715
		fgGlow:drawArc( -- 716
			Vec2(cx, indY), -- 716
			11, -- 716
			90, -- 716
			90 - 360 * frac, -- 716
			2.4, -- 716
			toColor(PALETTE.crimson, 235) -- 716
		) -- 716
		fgGlow:drawDot( -- 717
			Vec2(cx, indY), -- 717
			3, -- 717
			toColor(PALETTE.amber) -- 717
		) -- 717
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 717
		drawDiamond( -- 719
			fgGlow, -- 719
			cx, -- 719
			indY, -- 719
			6, -- 719
			8, -- 719
			toColor(PALETTE.amber, 220) -- 719
		) -- 719
	end -- 719
end -- 651
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 724
	local cx = cam:sx(p.dogX) -- 731
	local by = cam:sy(0) -- 732
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 733
	local W = cam:len(34) -- 734
	local H = cam:len(28) -- 735
	local frame = 0 -- 737
	if p.dogState == "ear" then -- 737
		frame = 1 -- 739
	elseif p.dogState == "sniff" then -- 739
		frame = 3 -- 741
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 741
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 743
	end -- 743
	if assets:tryPlace( -- 743
		"dog", -- 745
		"actor_dog", -- 745
		cx, -- 745
		by, -- 745
		W, -- 745
		H, -- 745
		{facing = f, frame = frame, layer = 3} -- 745
	) then -- 745
		return -- 746
	end -- 746
	fgDraw:drawEllipse( -- 749
		Vec2(cx, by + 1), -- 749
		W * 0.56, -- 749
		3.5, -- 749
		Color(4, 8, 10, 155) -- 749
	) -- 749
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 750
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 751
	fgDraw:drawSegment( -- 754
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 754
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 754
		2.8, -- 754
		Color(26, 30, 34, 255) -- 754
	) -- 754
	fgDraw:drawSegment( -- 755
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 755
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 755
		2.8, -- 755
		Color(36, 40, 44, 255) -- 755
	) -- 755
	fgDraw:drawPolygon( -- 757
		{ -- 757
			Vec2(cx - W * 0.42, by + H * 0.36), -- 758
			Vec2(cx + W * 0.38, by + H * 0.42), -- 759
			Vec2(cx + W * 0.34, by + H * 0.78), -- 760
			Vec2(cx - W * 0.38, by + H * 0.72) -- 761
		}, -- 761
		Color(38, 42, 48, 255), -- 762
		1.2, -- 762
		Color(102, 118, 126, 175) -- 762
	) -- 762
	local hx = cx + f * W * 0.42 -- 763
	local hy = by + H * 0.84 -- 764
	fgDraw:drawPolygon( -- 765
		{ -- 765
			Vec2(hx - f * 8, hy - 6), -- 766
			Vec2(hx + f * 12, hy - 2), -- 767
			Vec2(hx + f * 4, hy + 8), -- 768
			Vec2(hx - f * 6, hy + 14) -- 769
		}, -- 769
		Color(44, 48, 54, 255) -- 770
	) -- 770
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 772
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 773
	fgGlow:drawDot( -- 774
		Vec2(hx + f * 4, hy + 2), -- 774
		2.8, -- 774
		toColor(eyeCol, 250) -- 774
	) -- 774
	fillRadialGlow( -- 775
		fgGlow, -- 775
		hx + f * 4, -- 775
		hy + 2, -- 775
		16, -- 775
		16, -- 775
		toColor(eyeCol, alert and 135 or 70), -- 775
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 775
		12 -- 775
	) -- 775
	if alert then -- 775
		local r = 12 + self.animTime * 42 % 24 -- 778
		fgGlow:drawArc( -- 779
			Vec2(hx, hy + 12), -- 779
			r, -- 779
			35, -- 779
			145, -- 779
			1.8, -- 779
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 779
		) -- 779
	end -- 779
end -- 724
return ____exports -- 724