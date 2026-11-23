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
			local running = math.abs(a.vx) > 8 -- 216
			slot = running and "soldier_fire_move" or "soldier_fire" -- 217
			frame = running and step or 0 -- 218
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 219
		elseif a.covered or isControlled and p.coverHug then -- 219
			slot = "soldier_cover" -- 221
			height = height * 0.77 -- 222
		elseif math.abs(a.vx) > 8 then -- 222
			slot = "soldier_run" -- 224
			frame = step -- 225
		end -- 225
	end -- 225
	if assets:tryPlace( -- 225
		slot, -- 227
		"actor_soldier", -- 227
		cx, -- 227
		by, -- 227
		W, -- 227
		height, -- 227
		{facing = facing, frame = frame, layer = 4} -- 227
	) then -- 227
		fgDraw:drawEllipse( -- 228
			Vec2(cx, by + 1), -- 228
			W * 0.54, -- 228
			4, -- 228
			Color(12, 11, 13, 145) -- 228
		) -- 228
		return -- 229
	end -- 229
	fgDraw:drawEllipse( -- 233
		Vec2(cx, by + 1), -- 233
		H * 0.24, -- 233
		4.5, -- 233
		Color(3, 5, 10, 175) -- 233
	) -- 233
	local speed = math.abs(a.vx) -- 235
	local walking = speed > 10 and a.onGround -- 236
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 237
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 238
	local calming = not p.childMode and p.escort.state == "calming" -- 239
	local rolling = a.rollT > 0 -- 240
	local crouching = a.covered or calming or rolling -- 241
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 244
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 245
	local sw = H * 0.115 -- 246
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 249
	local kneeY = by + bodyH * 0.23 -- 250
	local stepX = stride * H * 0.15 -- 251
	local legDark = Color(14, 21, 34, 255) -- 252
	local legFront = Color(26, 38, 58, 255) -- 253
	local bkX = cx - f * 4 - stepX * 0.5 -- 255
	local bfX = cx - f * 8 - stepX -- 256
	fgDraw:drawSegment( -- 257
		Vec2(cx - f * 3, hipY), -- 257
		Vec2(bkX, kneeY), -- 257
		H * 0.044, -- 257
		legDark -- 257
	) -- 257
	fgDraw:drawSegment( -- 258
		Vec2(bkX, kneeY), -- 258
		Vec2(bfX, by + 3), -- 258
		H * 0.038, -- 258
		legDark -- 258
	) -- 258
	local fkX = cx + f * 6 + stepX * 0.55 -- 260
	local ffX = cx + f * 7 + stepX -- 261
	fgDraw:drawSegment( -- 262
		Vec2(cx + f * 3, hipY), -- 262
		Vec2(fkX, kneeY), -- 262
		H * 0.048, -- 262
		legFront -- 262
	) -- 262
	fgDraw:drawSegment( -- 263
		Vec2(fkX, kneeY), -- 263
		Vec2(ffX, by + 3), -- 263
		H * 0.042, -- 263
		legFront -- 263
	) -- 263
	fgDraw:drawSegment( -- 265
		Vec2(ffX - f * 2, by + 3), -- 265
		Vec2(ffX + f * 9, by + 3), -- 265
		3.4, -- 265
		Color(42, 60, 86, 255) -- 265
	) -- 265
	local shY = by + bodyH * 0.8 + bob -- 268
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 269
	fgDraw:drawPolygon( -- 270
		{ -- 270
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 271
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 272
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 273
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 274
		}, -- 274
		Color(16, 26, 42, 248), -- 275
		1.2, -- 275
		Color(64, 118, 164, 195) -- 275
	) -- 275
	fgDraw:drawPolygon( -- 278
		{ -- 278
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 279
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 280
			Vec2(cx + sw * 1.05 + lean, shY), -- 281
			Vec2(cx - sw * 0.98 + lean, shY) -- 282
		}, -- 282
		Color(24, 38, 60, 255), -- 283
		1.3, -- 283
		toColor(PALETTE.rimSilver, 190) -- 283
	) -- 283
	fgDraw:drawSegment( -- 285
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 286
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 287
		2.4, -- 288
		Color(173, 155, 125, 225) -- 289
	) -- 289
	fgDraw:drawPolygon( -- 291
		{ -- 291
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 292
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 293
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 294
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 295
		}, -- 295
		Color(99, 105, 103, 248) -- 296
	) -- 296
	local headR = H * 0.088 -- 299
	local headX = cx + lean + f * 3 -- 300
	local headY = shY + headR * 1.35 -- 301
	fgDraw:drawCircle( -- 302
		Vec2(headX, headY - headR * 0.12), -- 302
		headR * 0.86, -- 302
		Color(181, 139, 106, 255) -- 302
	) -- 302
	fgDraw:drawEllipse( -- 303
		Vec2(headX, headY + headR * 0.5), -- 303
		headR * 1.12, -- 303
		headR * 0.72, -- 303
		Color(66, 73, 76, 255) -- 303
	) -- 303
	fgDraw:drawSegment( -- 304
		Vec2(headX - headR, headY + 1), -- 304
		Vec2(headX + headR, headY + 1), -- 304
		1.6, -- 305
		Color(97, 103, 101, 255) -- 305
	) -- 305
	fgDraw:drawSegment( -- 306
		Vec2(headX, headY + headR), -- 306
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 306
		1.6, -- 307
		Color(177, 78, 51, 255) -- 307
	) -- 307
	if isControlled and not calming and not rolling and not p.gripping then -- 307
		local gunPivotX = cx + lean + f * sw * 0.35 -- 311
		local gunPivotY = shY - bodyH * 0.1 -- 312
		local aimDx = f -- 313
		local aimDy = 0 -- 314
		if p.aimX > 0 or p.aimY > 0 then -- 314
			aimDx = p.aimX - gunPivotX -- 316
			aimDy = p.aimY - gunPivotY -- 317
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 318
			if dLen > 4 then -- 318
				aimDx = aimDx / dLen -- 320
				aimDy = aimDy / dLen -- 321
			end -- 321
		end -- 321
		local barrelLen = H * 0.34 -- 324
		local tipX = gunPivotX + aimDx * barrelLen -- 325
		local tipY = gunPivotY + aimDy * barrelLen -- 326
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 327
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 328
		fgDraw:drawSegment( -- 330
			Vec2(cx + lean, shY - 5), -- 330
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 330
			3.6, -- 330
			Color(26, 40, 62, 255) -- 330
		) -- 330
		fgDraw:drawSegment( -- 331
			Vec2(stockX, stockY), -- 331
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 331
			3.8, -- 331
			Color(105, 71, 50, 255) -- 331
		) -- 331
		fgDraw:drawSegment( -- 332
			Vec2(gunPivotX, gunPivotY), -- 332
			Vec2(tipX, tipY), -- 332
			1.8, -- 332
			Color(145, 140, 128, 245) -- 332
		) -- 332
	elseif calming then -- 332
		fgDraw:drawSegment( -- 334
			Vec2(cx + lean, shY - 6), -- 334
			Vec2(cx + f * sw * 2.1, shY - 14), -- 334
			3, -- 334
			Color(196, 222, 240, 235) -- 334
		) -- 334
		fgGlow:drawDot( -- 335
			Vec2(cx + f * sw * 2.15, shY - 14), -- 335
			3.6, -- 335
			toColor(PALETTE.amber, 225) -- 335
		) -- 335
	end -- 335
end -- 172
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 341
	local cx = cam:sx(a.x) -- 350
	local by = cam:sy(a.y) -- 351
	local H = cam:len(a.h) -- 352
	local W = cam:len(a.w) -- 353
	local f = a.facing -- 354
	local afraid = not isControlled and p.escort.fear > 0 -- 356
	local slot = "child_idle" -- 357
	local height = H -- 358
	local frame = 0 -- 359
	local step = math.floor(self.animTime * 10) -- 360
	local nearCover = __TS__ArraySome( -- 361
		p.room.solids, -- 361
		function(____, solid) return solid.h <= 64 and solid.y <= 2 and math.min( -- 361
			math.abs(a.x - solid.x), -- 363
			math.abs(a.x - solid.x - solid.w) -- 363
		) <= 30 end -- 363
	) -- 363
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 363
		slot = "child_knock" -- 366
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 366
		slot = "child_offer" -- 369
	elseif isControlled and p.ticks < self.throwUntil then -- 369
		slot = "child_throw" -- 371
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 371
		slot = "child_aim" -- 373
	elseif isControlled and p.gripping then -- 373
		slot = "child_pull" -- 375
		frame = self.cartMoving and step or 0 -- 376
	elseif afraid and p.escort.state == "frozen" then -- 376
		slot = "child_fear" -- 378
		height = height * 0.74 -- 379
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and math.abs(a.vx) < 8 then -- 379
		slot = "child_peek" -- 382
		height = height * 0.83 -- 383
	elseif a.crouch then -- 383
		slot = "child_crouch" -- 385
		frame = math.abs(a.vx) > 8 and step or 0 -- 386
	elseif math.abs(a.vx) > 8 then -- 386
		slot = "child_run" -- 388
		frame = step -- 389
	end -- 389
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 391
	if assets:tryPlace( -- 391
		slot, -- 392
		"actor_child", -- 392
		cx, -- 392
		by, -- 392
		W, -- 392
		height, -- 392
		{facing = facing, frame = frame, layer = 5} -- 392
	) then -- 392
		fgDraw:drawEllipse( -- 393
			Vec2(cx, by + 1), -- 393
			W * 0.48, -- 393
			3, -- 393
			Color(12, 11, 13, 125) -- 393
		) -- 393
		if afraid then -- 393
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 395
		end -- 395
		return -- 397
	end -- 397
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 400
	local x = cx + jitter -- 401
	local fullRef = a.crouch and H * 1.35 or H -- 403
	local cw = fullRef * 0.16 -- 404
	fgDraw:drawEllipse( -- 407
		Vec2(x, by + 1), -- 407
		cw * 1.15, -- 407
		3.6, -- 407
		Color(4, 6, 10, 155) -- 407
	) -- 407
	local speed = math.abs(a.vx) -- 409
	local walking = speed > 6 and a.onGround -- 410
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 411
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 412
	local hipY = by + H * 0.3 -- 415
	local legSwing = stride * cw * 0.85 -- 416
	fgDraw:drawSegment( -- 417
		Vec2(x - 2, hipY), -- 417
		Vec2(x - legSwing, by + 2), -- 417
		math.max(2.6, cw * 0.22), -- 417
		Color(34, 30, 38, 255) -- 417
	) -- 417
	fgDraw:drawSegment( -- 418
		Vec2(x + 2, hipY), -- 418
		Vec2(x + legSwing, by + 2), -- 418
		math.max(2.8, cw * 0.24), -- 418
		Color(52, 46, 56, 255) -- 418
	) -- 418
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 421
	local cloakBotY = by + H * 0.2 -- 422
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 423
	fgDraw:drawPolygon( -- 424
		{ -- 424
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 425
			Vec2(x + cw * 0.92, cloakBotY), -- 426
			Vec2(x + cw * 0.62, cloakTopY), -- 427
			Vec2(x - cw * 0.68, cloakTopY) -- 428
		}, -- 428
		Color(214, 166, 94, 255), -- 429
		1.3, -- 429
		Color(252, 232, 192, 225) -- 429
	) -- 429
	fgDraw:drawPolygon( -- 430
		{ -- 430
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 431
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 432
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 433
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 434
		}, -- 434
		Color(148, 108, 56, 215) -- 435
	) -- 435
	fgDraw:drawSegment( -- 436
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 436
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 436
		1.8, -- 436
		toColor(PALETTE.amberCore, 200) -- 436
	) -- 436
	local scarfY = cloakTopY - 2 -- 439
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 440
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 441
	local sendX = x - f * cw * 1.65 + cloakDrag -- 442
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 443
	fgDraw:drawQuadraticBezier( -- 444
		Vec2(x - f * cw * 0.3, scarfY), -- 444
		Vec2(smidX, smidY), -- 444
		Vec2(sendX, sendY), -- 444
		2.8, -- 444
		toColor(PALETTE.amberCore, 235) -- 444
	) -- 444
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 447
	local headX = x + f * (a.crouch and 5 or 2) -- 448
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 449
	fgDraw:drawCircle( -- 450
		Vec2(headX, headY), -- 450
		headR, -- 450
		Color(240, 222, 198, 255) -- 450
	) -- 450
	fgDraw:drawPolygon( -- 452
		{ -- 452
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 453
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 454
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 455
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 456
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 457
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 458
		}, -- 458
		Color(156, 114, 62, 248), -- 459
		1.1, -- 459
		Color(244, 214, 162, 200) -- 459
	) -- 459
	fgGlow:drawDot( -- 461
		Vec2(headX + f * headR * 0.45, headY + 1), -- 461
		2.2, -- 461
		toColor(PALETTE.amberCore) -- 461
	) -- 461
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 464
	if hasCompass then -- 464
		local compX = x + f * cw * 0.65 -- 466
		local compY = by + H * 0.48 -- 467
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 468
		fgGlow:drawDot( -- 469
			Vec2(compX, compY), -- 469
			2.6, -- 469
			toColor(PALETTE.amberCore, 250) -- 469
		) -- 469
		fillRadialGlow( -- 470
			fgGlow, -- 470
			compX, -- 470
			compY, -- 470
			26 * glowPulse, -- 470
			26 * glowPulse, -- 470
			Color(248, 206, 120, 78 * glowPulse), -- 470
			Color(248, 180, 72, 0), -- 470
			14 -- 470
		) -- 470
	end -- 470
	if afraid then -- 470
		self:drawFear(fgGlow, p, x, by + H + 16) -- 474
	end -- 474
	if isControlled and walking and not a.crouch and speed > 100 then -- 474
		local r = 10 + self.animTime * 32 % 24 -- 479
		fgGlow:drawRing( -- 480
			Vec2(x, by + 3), -- 480
			r, -- 480
			r + 1.5, -- 480
			Color(0, 0, 0, 0), -- 480
			1.1, -- 480
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 480
		) -- 480
	end -- 480
end -- 341
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 484
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 485
	do -- 485
		local i = 0 -- 486
		while i < FEAR_MAX do -- 486
			local lit = i < p.escort.fear -- 487
			drawDiamond( -- 488
				fgGlow, -- 488
				x + (i - 1) * 13, -- 488
				y, -- 488
				4, -- 488
				5, -- 488
				toColor(lit and tint or PALETTE.steelDark, 215), -- 489
				1, -- 489
				toColor(tint, lit and 235 or 100) -- 489
			) -- 489
			i = i + 1 -- 486
		end -- 486
	end -- 486
end -- 484
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 493
	local x = cam:sx(e.x + f * 20) -- 494
	local y = cam:sy(e.y + e.h * 0.69) -- 495
	local dx = cam:sx(p.player.x) - x -- 496
	local dy = cam:sy(p.player.y + p.player.h * 0.56) - y -- 497
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 498
	do -- 498
		local i = 0 -- 499
		while i < 8 do -- 499
			local a = length * i / 8 -- 500
			local b = length * (i + 1) / 8 -- 501
			fgGlow:drawSegment( -- 502
				Vec2(x + dx * a, y + dy * a), -- 502
				Vec2(x + dx * b, y + dy * b), -- 502
				1.3, -- 503
				Color(220, 120, 88, 210) -- 503
			) -- 503
			i = i + 2 -- 499
		end -- 499
	end -- 499
end -- 493
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 508
	local cx = cam:sx(e.x) -- 517
	local by = cam:sy(e.y) -- 518
	local H = cam:len(e.h) -- 519
	local W = cam:len(e.w) -- 520
	local f = p.player.x >= e.x and 1 or -1 -- 521
	local slot = "enemy_idle" -- 523
	if not e.alive then -- 523
		slot = "enemy_down" -- 525
	elseif e.hitT > 0 then -- 525
		slot = "enemy_hit" -- 527
	elseif e.warnT > 0 then -- 527
		slot = "enemy_aim" -- 529
	end -- 529
	local height = e.alive and H or H * 0.24 -- 531
	if assets:tryPlace( -- 531
		slot, -- 532
		"actor_enemy_" .. tostring(index), -- 532
		cx, -- 532
		by, -- 532
		W, -- 532
		height, -- 532
		{facing = f, opacity = e.alive and 1 or 0.78, layer = 3} -- 532
	) then -- 532
		if e.alive and e.warnT > 0 then -- 532
			self:drawEnemyWarning( -- 536
				fgGlow, -- 536
				e, -- 536
				p, -- 536
				cam, -- 536
				f -- 536
			) -- 536
		end -- 536
		return -- 538
	end -- 538
	if not e.alive then -- 538
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 542
		fgDraw:drawPolygon( -- 543
			{ -- 543
				Vec2(cx - H * 0.3, by), -- 544
				Vec2(cx + H * 0.28, by), -- 545
				Vec2(cx + H * 0.2, by + H * 0.14), -- 546
				Vec2(cx - H * 0.24, by + H * 0.11) -- 547
			}, -- 547
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 548
		) -- 548
		if flash > 0 then -- 548
			fillRadialGlow( -- 550
				fgGlow, -- 550
				cx, -- 550
				by + 12, -- 550
				34 * flash, -- 550
				18 * flash, -- 550
				toColor(PALETTE.crimson, 180 * flash), -- 550
				Color(255, 48, 82, 0), -- 550
				12 -- 550
			) -- 550
		end -- 550
		return -- 552
	end -- 552
	local sw = H * 0.112 -- 555
	fgDraw:drawEllipse( -- 556
		Vec2(cx, by + 1), -- 556
		sw * 1.9, -- 556
		4, -- 556
		Color(4, 6, 10, 165) -- 556
	) -- 556
	local hipY = by + H * 0.44 -- 559
	local kneeY = by + H * 0.23 -- 560
	local shY = by + H * 0.79 -- 561
	fgDraw:drawSegment( -- 562
		Vec2(cx - 5, hipY), -- 562
		Vec2(cx - 7, kneeY), -- 562
		H * 0.044, -- 562
		Color(20, 16, 26, 255) -- 562
	) -- 562
	fgDraw:drawSegment( -- 563
		Vec2(cx - 7, kneeY), -- 563
		Vec2(cx - 8, by + 2), -- 563
		H * 0.038, -- 563
		Color(20, 16, 26, 255) -- 563
	) -- 563
	fgDraw:drawSegment( -- 564
		Vec2(cx + 5, hipY), -- 564
		Vec2(cx + 7, kneeY), -- 564
		H * 0.046, -- 564
		Color(28, 22, 36, 255) -- 564
	) -- 564
	fgDraw:drawSegment( -- 565
		Vec2(cx + 7, kneeY), -- 565
		Vec2(cx + 8, by + 2), -- 565
		H * 0.04, -- 565
		Color(28, 22, 36, 255) -- 565
	) -- 565
	fgDraw:drawPolygon( -- 567
		{ -- 567
			Vec2(cx - sw * 0.68, hipY), -- 568
			Vec2(cx + sw * 0.68, hipY), -- 569
			Vec2(cx + sw * 1.12, shY), -- 570
			Vec2(cx - sw * 1.12, shY) -- 571
		}, -- 571
		Color(111, 68, 55, 255), -- 572
		1.3, -- 572
		Color(143, 101, 66, 220) -- 572
	) -- 572
	fgDraw:drawPolygon( -- 573
		{ -- 573
			Vec2(cx - sw * 1.26, shY - 6), -- 574
			Vec2(cx + sw * 1.26, shY - 6), -- 575
			Vec2(cx + sw * 0.96, shY + 5), -- 576
			Vec2(cx - sw * 0.96, shY + 5) -- 577
		}, -- 577
		Color(98, 82, 62, 255) -- 578
	) -- 578
	local headR = H * 0.086 -- 580
	local headY = shY + headR * 1.32 -- 581
	fgDraw:drawCircle( -- 582
		Vec2(cx, headY), -- 582
		headR * 0.82, -- 582
		Color(187, 142, 103, 255) -- 582
	) -- 582
	fgDraw:drawPolygon( -- 583
		{ -- 583
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 584
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 585
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 586
		}, -- 586
		Color(136, 105, 65, 255), -- 587
		1.1, -- 587
		Color(177, 145, 91, 220) -- 587
	) -- 587
	local gunX = cx + f * H * 0.34 -- 589
	local gunY = by + H * 0.69 -- 590
	fgDraw:drawSegment( -- 591
		Vec2(cx - f * 6, gunY - 2), -- 591
		Vec2(gunX, gunY), -- 591
		2.8, -- 591
		Color(118, 87, 61, 255) -- 591
	) -- 591
	if e.warnT > 0 then -- 591
		self:drawEnemyWarning( -- 593
			fgGlow, -- 593
			e, -- 593
			p, -- 593
			cam, -- 593
			f -- 593
		) -- 593
	end -- 593
end -- 508
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 598
	local s = p.room.scavenger -- 605
	if s == nil then -- 605
		return -- 607
	end -- 607
	local cx = cam:sx(p.scavX) -- 609
	local by = cam:sy(s.y) -- 610
	local H = cam:len(s.h) -- 611
	local W = cam:len(26) -- 612
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 613
	local alert = p.scavChase or p.scavSee > 0 -- 616
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 617
	local eyeY = by + H * 0.8 -- 618
	local coneLen = cam:len(alert and 155 or 115) -- 619
	fgGlow:drawVertices({ -- 620
		{ -- 621
			Vec2(cx + f * 6, eyeY), -- 621
			toColor(coneCol, alert and 78 or 34) -- 621
		}, -- 621
		{ -- 622
			Vec2(cx + f * coneLen, by + H * 1.05), -- 622
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 622
		}, -- 622
		{ -- 623
			Vec2(cx + f * coneLen, by + 4), -- 623
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 623
		} -- 623
	}) -- 623
	local frame = 0 -- 626
	if p.scavState == "turn" then -- 626
		frame = 2 -- 628
	elseif p.scavState == "chase" then -- 628
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 630
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 630
		frame = math.floor(self.animTime * 8) % 2 -- 632
	end -- 632
	if assets:tryPlace( -- 632
		"scavenger", -- 634
		"actor_scav", -- 634
		cx, -- 634
		by, -- 634
		W, -- 634
		H, -- 634
		{facing = f, frame = frame, layer = 3} -- 634
	) then -- 634
		return -- 635
	end -- 635
	fgDraw:drawEllipse( -- 638
		Vec2(cx, by + 1), -- 638
		W * 0.62, -- 638
		4, -- 638
		Color(4, 6, 10, 155) -- 638
	) -- 638
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 639
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 640
	fgDraw:drawSegment( -- 642
		Vec2(cx - 4, by + H * 0.4), -- 642
		Vec2(cx - stride, by + 2), -- 642
		W * 0.16, -- 642
		Color(32, 30, 28, 255) -- 642
	) -- 642
	fgDraw:drawSegment( -- 643
		Vec2(cx + 4, by + H * 0.4), -- 643
		Vec2(cx + stride, by + 2), -- 643
		W * 0.16, -- 643
		Color(44, 40, 36, 255) -- 643
	) -- 643
	fgDraw:drawPolygon( -- 645
		{ -- 645
			Vec2(cx - W * 0.45, by + H * 0.25), -- 646
			Vec2(cx + W * 0.42, by + H * 0.25), -- 647
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 648
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 649
		}, -- 649
		Color(56, 52, 46, 255), -- 650
		1.2, -- 650
		Color(128, 118, 100, 180) -- 650
	) -- 650
	local headX = cx + f * 5 -- 652
	local headY = by + H * 0.88 -- 653
	fgDraw:drawCircle( -- 654
		Vec2(headX, headY), -- 654
		W * 0.3, -- 654
		Color(42, 38, 34, 255) -- 654
	) -- 654
	fgGlow:drawDot( -- 655
		Vec2(headX + f * 6, headY), -- 655
		3, -- 655
		toColor(coneCol, 245) -- 655
	) -- 655
	local indY = by + H + 18 -- 658
	if p.scavChase then -- 658
		drawDiamond( -- 660
			fgGlow, -- 660
			cx, -- 660
			indY, -- 660
			9, -- 660
			12, -- 660
			toColor(PALETTE.crimson, 240), -- 660
			1.5, -- 660
			toColor(PALETTE.crimsonCore) -- 660
		) -- 660
	elseif p.scavSee > 0 then -- 660
		local frac = math.min(1, p.scavSee / 24) -- 662
		fgGlow:drawArc( -- 663
			Vec2(cx, indY), -- 663
			11, -- 663
			90, -- 663
			90 - 360 * frac, -- 663
			2.4, -- 663
			toColor(PALETTE.crimson, 235) -- 663
		) -- 663
		fgGlow:drawDot( -- 664
			Vec2(cx, indY), -- 664
			3, -- 664
			toColor(PALETTE.amber) -- 664
		) -- 664
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 664
		drawDiamond( -- 666
			fgGlow, -- 666
			cx, -- 666
			indY, -- 666
			6, -- 666
			8, -- 666
			toColor(PALETTE.amber, 220) -- 666
		) -- 666
	end -- 666
end -- 598
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 671
	local cx = cam:sx(p.dogX) -- 678
	local by = cam:sy(0) -- 679
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 680
	local W = cam:len(34) -- 681
	local H = cam:len(28) -- 682
	local frame = 0 -- 684
	if p.dogState == "ear" then -- 684
		frame = 1 -- 686
	elseif p.dogState == "sniff" then -- 686
		frame = 3 -- 688
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 688
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 690
	end -- 690
	if assets:tryPlace( -- 690
		"dog", -- 692
		"actor_dog", -- 692
		cx, -- 692
		by, -- 692
		W, -- 692
		H, -- 692
		{facing = f, frame = frame, layer = 3} -- 692
	) then -- 692
		return -- 693
	end -- 693
	fgDraw:drawEllipse( -- 696
		Vec2(cx, by + 1), -- 696
		W * 0.56, -- 696
		3.5, -- 696
		Color(4, 8, 10, 155) -- 696
	) -- 696
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 697
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 698
	fgDraw:drawSegment( -- 701
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 701
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 701
		2.8, -- 701
		Color(26, 30, 34, 255) -- 701
	) -- 701
	fgDraw:drawSegment( -- 702
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 702
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 702
		2.8, -- 702
		Color(36, 40, 44, 255) -- 702
	) -- 702
	fgDraw:drawPolygon( -- 704
		{ -- 704
			Vec2(cx - W * 0.42, by + H * 0.36), -- 705
			Vec2(cx + W * 0.38, by + H * 0.42), -- 706
			Vec2(cx + W * 0.34, by + H * 0.78), -- 707
			Vec2(cx - W * 0.38, by + H * 0.72) -- 708
		}, -- 708
		Color(38, 42, 48, 255), -- 709
		1.2, -- 709
		Color(102, 118, 126, 175) -- 709
	) -- 709
	local hx = cx + f * W * 0.42 -- 710
	local hy = by + H * 0.84 -- 711
	fgDraw:drawPolygon( -- 712
		{ -- 712
			Vec2(hx - f * 8, hy - 6), -- 713
			Vec2(hx + f * 12, hy - 2), -- 714
			Vec2(hx + f * 4, hy + 8), -- 715
			Vec2(hx - f * 6, hy + 14) -- 716
		}, -- 716
		Color(44, 48, 54, 255) -- 717
	) -- 717
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 719
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 720
	fgGlow:drawDot( -- 721
		Vec2(hx + f * 4, hy + 2), -- 721
		2.8, -- 721
		toColor(eyeCol, 250) -- 721
	) -- 721
	fillRadialGlow( -- 722
		fgGlow, -- 722
		hx + f * 4, -- 722
		hy + 2, -- 722
		16, -- 722
		16, -- 722
		toColor(eyeCol, alert and 135 or 70), -- 722
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 722
		12 -- 722
	) -- 722
	if alert then -- 722
		local r = 12 + self.animTime * 42 % 24 -- 725
		fgGlow:drawArc( -- 726
			Vec2(hx, hy + 12), -- 726
			r, -- 726
			35, -- 726
			145, -- 726
			1.8, -- 726
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 726
		) -- 726
	end -- 726
end -- 671
return ____exports -- 671