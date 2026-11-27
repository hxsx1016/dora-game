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
	self:drawAfterimages(fgGlow, assets, cam) -- 110
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
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, assets, cam) -- 149
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
			local sz = cam:len(16 + spread * 16) -- 158
			if not assets:tryPlace( -- 158
				"fe_vfx_smoke", -- 160
				"roll_dust_" .. tostring(i), -- 161
				cx - f * cam:len(7 + spread * 12), -- 162
				by + cam:len(6 + spread * 6), -- 163
				sz, -- 164
				sz, -- 165
				{ -- 166
					frame = math.min( -- 167
						3, -- 167
						math.floor(spread * 4) -- 167
					), -- 167
					color = Color(218, 206, 186, 255), -- 168
					opacity = 0.7 * k, -- 169
					layer = 2 -- 170
				} -- 170
			) then -- 170
				local rBase = cam:len(6 + spread * 9) -- 173
				fgGlow:drawCircle( -- 174
					Vec2( -- 174
						cx - f * cam:len(6 + spread * 10), -- 174
						by + cam:len(4 + spread * 5) -- 174
					), -- 174
					rBase, -- 174
					Color( -- 174
						156, -- 174
						144, -- 174
						124, -- 174
						math.floor(78 * k + 0.5) -- 174
					) -- 174
				) -- 174
			end -- 174
			i = i + 1 -- 151
		end -- 151
	end -- 151
end -- 149
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 180
	local half = a.w * 0.5 -- 181
	local g = 0 -- 182
	local i = 0 -- 183
	do -- 183
		i = 0 -- 184
		while i < #p.room.floors do -- 184
			local f = p.room.floors[i + 1] -- 185
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 185
				g = f.y -- 187
			end -- 187
			i = i + 1 -- 184
		end -- 184
	end -- 184
	do -- 184
		i = 0 -- 190
		while i < #p.boxes do -- 190
			do -- 190
				local b = p.boxes[i + 1] -- 191
				if b.broken == true or b.hidden == true or b.soft == true then -- 191
					goto __continue34 -- 193
				end -- 193
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 193
					g = b.y1 -- 197
				end -- 197
			end -- 197
			::__continue34:: -- 197
			i = i + 1 -- 190
		end -- 190
	end -- 190
	return g -- 200
end -- 180
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 204
	local cx = cam:sx(a.x) -- 213
	local by = cam:sy(a.y, a.depth) -- 214
	local depthEnabled = p.room.depth ~= nil -- 215
	local shadowY = not a.onGround and cam:sy( -- 216
		self:supportGroundY(p, a), -- 216
		a.depth -- 216
	) or by -- 216
	local H = cam:len(a.h) -- 217
	local W = cam:len(a.w) -- 218
	local f = a.facing -- 219
	local speed = math.max( -- 220
		math.abs(a.vx), -- 220
		math.abs(a.depthSpeed) -- 220
	) -- 220
	local slot = "soldier_idle" -- 222
	local height = H -- 223
	local frame = 0 -- 224
	local facing = f -- 225
	local step = math.floor(self.animTime * 10) -- 226
	if isControlled and p.ticks < self.hitUntil then -- 226
		slot = "soldier_hit" -- 228
	elseif a.rollT > 0 then -- 228
		slot = "soldier_roll" -- 230
		height = height * 0.59 -- 231
	elseif p.phase == "prologue-give" then -- 231
		slot = "soldier_offer" -- 233
		height = height * 0.75 -- 234
		facing = p.partner.x >= a.x and 1 or -1 -- 235
	elseif isControlled and p.gripping then -- 235
		slot = "soldier_push" -- 237
		frame = self.cartMoving and step or 0 -- 238
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 239
		height = height * 0.91 -- 240
	elseif isControlled and p.escort.state == "calming" then -- 240
		slot = "soldier_knock" -- 242
		local calm = p.escort.calmTick -- 243
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 244
		height = height * 0.76 -- 245
	else -- 245
		local ____temp_3 = p.phase == "gate-send" -- 246
		if ____temp_3 then -- 246
			local ____opt_1 = p.room.story -- 246
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 246
		end -- 246
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 246
			slot = "soldier_hold" -- 248
			height = height * 1.11 -- 249
		elseif isControlled and p.ticks < self.shotUntil then -- 249
			local running = speed > 8 -- 251
			slot = running and "soldier_fire_move" or "soldier_fire" -- 252
			frame = running and step or 0 -- 253
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 254
		elseif a.covered or isControlled and p.coverHug then -- 254
			slot = "soldier_cover" -- 256
			height = height * 0.77 -- 257
		elseif speed > 8 then -- 257
			slot = "soldier_run" -- 259
			frame = step -- 260
		end -- 260
	end -- 260
	if assets:tryPlace( -- 260
		slot, -- 262
		"actor_soldier", -- 262
		cx, -- 262
		by, -- 262
		W, -- 262
		height, -- 262
		{ -- 262
			facing = facing, -- 263
			frame = frame, -- 263
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 263
		} -- 263
	) then -- 263
		fgDraw:drawEllipse( -- 265
			Vec2(cx, shadowY + 1), -- 265
			W * 0.54, -- 265
			4, -- 265
			Color(12, 11, 13, 145) -- 265
		) -- 265
		return -- 266
	end -- 266
	fgDraw:drawEllipse( -- 270
		Vec2(cx, shadowY + 1), -- 270
		H * 0.24, -- 270
		4.5, -- 270
		Color(3, 5, 10, 175) -- 270
	) -- 270
	local walking = speed > 10 and a.onGround -- 272
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 273
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 274
	local calming = not p.childMode and p.escort.state == "calming" -- 275
	local rolling = a.rollT > 0 -- 276
	local crouching = a.covered or calming or rolling -- 277
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 280
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 281
	local sw = H * 0.115 -- 282
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 285
	local kneeY = by + bodyH * 0.23 -- 286
	local stepX = stride * H * 0.15 -- 287
	local legDark = Color(14, 21, 34, 255) -- 288
	local legFront = Color(26, 38, 58, 255) -- 289
	local bkX = cx - f * 4 - stepX * 0.5 -- 291
	local bfX = cx - f * 8 - stepX -- 292
	fgDraw:drawSegment( -- 293
		Vec2(cx - f * 3, hipY), -- 293
		Vec2(bkX, kneeY), -- 293
		H * 0.044, -- 293
		legDark -- 293
	) -- 293
	fgDraw:drawSegment( -- 294
		Vec2(bkX, kneeY), -- 294
		Vec2(bfX, by + 3), -- 294
		H * 0.038, -- 294
		legDark -- 294
	) -- 294
	local fkX = cx + f * 6 + stepX * 0.55 -- 296
	local ffX = cx + f * 7 + stepX -- 297
	fgDraw:drawSegment( -- 298
		Vec2(cx + f * 3, hipY), -- 298
		Vec2(fkX, kneeY), -- 298
		H * 0.048, -- 298
		legFront -- 298
	) -- 298
	fgDraw:drawSegment( -- 299
		Vec2(fkX, kneeY), -- 299
		Vec2(ffX, by + 3), -- 299
		H * 0.042, -- 299
		legFront -- 299
	) -- 299
	fgDraw:drawSegment( -- 301
		Vec2(ffX - f * 2, by + 3), -- 301
		Vec2(ffX + f * 9, by + 3), -- 301
		3.4, -- 301
		Color(42, 60, 86, 255) -- 301
	) -- 301
	local shY = by + bodyH * 0.8 + bob -- 304
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 305
	fgDraw:drawPolygon( -- 306
		{ -- 306
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 307
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 308
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 309
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 310
		}, -- 310
		Color(16, 26, 42, 248), -- 311
		1.2, -- 311
		Color(64, 118, 164, 195) -- 311
	) -- 311
	fgDraw:drawPolygon( -- 314
		{ -- 314
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 315
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 316
			Vec2(cx + sw * 1.05 + lean, shY), -- 317
			Vec2(cx - sw * 0.98 + lean, shY) -- 318
		}, -- 318
		Color(24, 38, 60, 255), -- 319
		1.3, -- 319
		toColor(PALETTE.rimSilver, 190) -- 319
	) -- 319
	fgDraw:drawSegment( -- 321
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 322
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 323
		2.4, -- 324
		Color(173, 155, 125, 225) -- 325
	) -- 325
	fgDraw:drawPolygon( -- 327
		{ -- 327
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 328
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 329
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 330
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 331
		}, -- 331
		Color(99, 105, 103, 248) -- 332
	) -- 332
	local headR = H * 0.088 -- 335
	local headX = cx + lean + f * 3 -- 336
	local headY = shY + headR * 1.35 -- 337
	fgDraw:drawCircle( -- 338
		Vec2(headX, headY - headR * 0.12), -- 338
		headR * 0.86, -- 338
		Color(181, 139, 106, 255) -- 338
	) -- 338
	fgDraw:drawEllipse( -- 339
		Vec2(headX, headY + headR * 0.5), -- 339
		headR * 1.12, -- 339
		headR * 0.72, -- 339
		Color(66, 73, 76, 255) -- 339
	) -- 339
	fgDraw:drawSegment( -- 340
		Vec2(headX - headR, headY + 1), -- 340
		Vec2(headX + headR, headY + 1), -- 340
		1.6, -- 341
		Color(97, 103, 101, 255) -- 341
	) -- 341
	fgDraw:drawSegment( -- 342
		Vec2(headX, headY + headR), -- 342
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 342
		1.6, -- 343
		Color(177, 78, 51, 255) -- 343
	) -- 343
	if isControlled and not calming and not rolling and not p.gripping then -- 343
		local gunPivotX = cx + lean + f * sw * 0.35 -- 347
		local gunPivotY = shY - bodyH * 0.1 -- 348
		local aimDx = f -- 349
		local aimDy = 0 -- 350
		if p.aimX > 0 or p.aimY > 0 then -- 350
			aimDx = p.aimX - gunPivotX -- 352
			aimDy = p.aimY - gunPivotY -- 353
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 354
			if dLen > 4 then -- 354
				aimDx = aimDx / dLen -- 356
				aimDy = aimDy / dLen -- 357
			end -- 357
		end -- 357
		local barrelLen = H * 0.34 -- 360
		local tipX = gunPivotX + aimDx * barrelLen -- 361
		local tipY = gunPivotY + aimDy * barrelLen -- 362
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 363
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 364
		fgDraw:drawSegment( -- 366
			Vec2(cx + lean, shY - 5), -- 366
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 366
			3.6, -- 366
			Color(26, 40, 62, 255) -- 366
		) -- 366
		fgDraw:drawSegment( -- 367
			Vec2(stockX, stockY), -- 367
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 367
			3.8, -- 367
			Color(105, 71, 50, 255) -- 367
		) -- 367
		fgDraw:drawSegment( -- 368
			Vec2(gunPivotX, gunPivotY), -- 368
			Vec2(tipX, tipY), -- 368
			1.8, -- 368
			Color(145, 140, 128, 245) -- 368
		) -- 368
	elseif calming then -- 368
		fgDraw:drawSegment( -- 370
			Vec2(cx + lean, shY - 6), -- 370
			Vec2(cx + f * sw * 2.1, shY - 14), -- 370
			3, -- 370
			Color(196, 222, 240, 235) -- 370
		) -- 370
		fgGlow:drawDot( -- 371
			Vec2(cx + f * sw * 2.15, shY - 14), -- 371
			3.6, -- 371
			toColor(PALETTE.amber, 225) -- 371
		) -- 371
	end -- 371
end -- 204
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 377
	local cx = cam:sx(a.x) -- 386
	local by = cam:sy(a.y, a.depth) -- 387
	local depthEnabled = p.room.depth ~= nil -- 388
	local shadowY = not a.onGround and cam:sy( -- 389
		self:supportGroundY(p, a), -- 389
		a.depth -- 389
	) or by -- 389
	local H = cam:len(a.h) -- 390
	local W = cam:len(a.w) -- 391
	local f = a.facing -- 392
	local speed = math.max( -- 393
		math.abs(a.vx), -- 393
		math.abs(a.depthSpeed) -- 393
	) -- 393
	local afraid = not isControlled and p.escort.fear > 0 -- 395
	local slot = "child_idle" -- 396
	local height = H -- 397
	local frame = 0 -- 398
	local step = math.floor(self.animTime * 10) -- 399
	local nearCover = __TS__ArraySome( -- 400
		p.room.solids, -- 400
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 400
			math.abs(a.x - solid.x), -- 403
			math.abs(a.x - solid.x - solid.w) -- 403
		) <= 30 end -- 403
	) -- 403
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 403
		slot = "child_knock" -- 406
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 406
		slot = "child_offer" -- 409
	elseif isControlled and p.ticks < self.throwUntil then -- 409
		slot = "child_throw" -- 411
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 411
		slot = "child_aim" -- 413
	elseif isControlled and p.gripping then -- 413
		slot = "child_pull" -- 415
		frame = self.cartMoving and step or 0 -- 416
	elseif afraid and p.escort.state == "frozen" then -- 416
		slot = "child_fear" -- 418
		height = height * 0.74 -- 419
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 419
		slot = "child_peek" -- 422
		height = height * 0.83 -- 423
	elseif a.crouch then -- 423
		slot = "child_crouch" -- 425
		frame = speed > 8 and step or 0 -- 426
	elseif speed > 8 then -- 426
		slot = "child_run" -- 428
		frame = step -- 429
	end -- 429
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 431
	if assets:tryPlace( -- 431
		slot, -- 432
		"actor_child", -- 432
		cx, -- 432
		by, -- 432
		W, -- 432
		height, -- 432
		{ -- 432
			facing = facing, -- 433
			frame = frame, -- 433
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 433
		} -- 433
	) then -- 433
		fgDraw:drawEllipse( -- 435
			Vec2(cx, shadowY + 1), -- 435
			W * 0.48, -- 435
			3, -- 435
			Color(12, 11, 13, 125) -- 435
		) -- 435
		if afraid then -- 435
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 437
		end -- 437
		return -- 439
	end -- 439
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 442
	local x = cx + jitter -- 443
	local fullRef = a.crouch and H * 1.35 or H -- 445
	local cw = fullRef * 0.16 -- 446
	fgDraw:drawEllipse( -- 449
		Vec2(x, shadowY + 1), -- 449
		cw * 1.15, -- 449
		3.6, -- 449
		Color(4, 6, 10, 155) -- 449
	) -- 449
	local walking = speed > 6 and a.onGround -- 451
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 452
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 453
	local hipY = by + H * 0.3 -- 456
	local legSwing = stride * cw * 0.85 -- 457
	fgDraw:drawSegment( -- 458
		Vec2(x - 2, hipY), -- 458
		Vec2(x - legSwing, by + 2), -- 458
		math.max(2.6, cw * 0.22), -- 458
		Color(34, 30, 38, 255) -- 458
	) -- 458
	fgDraw:drawSegment( -- 459
		Vec2(x + 2, hipY), -- 459
		Vec2(x + legSwing, by + 2), -- 459
		math.max(2.8, cw * 0.24), -- 459
		Color(52, 46, 56, 255) -- 459
	) -- 459
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 462
	local cloakBotY = by + H * 0.2 -- 463
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 464
	fgDraw:drawPolygon( -- 465
		{ -- 465
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 466
			Vec2(x + cw * 0.92, cloakBotY), -- 467
			Vec2(x + cw * 0.62, cloakTopY), -- 468
			Vec2(x - cw * 0.68, cloakTopY) -- 469
		}, -- 469
		Color(214, 166, 94, 255), -- 470
		1.3, -- 470
		Color(252, 232, 192, 225) -- 470
	) -- 470
	fgDraw:drawPolygon( -- 471
		{ -- 471
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 472
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 473
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 474
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 475
		}, -- 475
		Color(148, 108, 56, 215) -- 476
	) -- 476
	fgDraw:drawSegment( -- 477
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 477
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 477
		1.8, -- 477
		toColor(PALETTE.amberCore, 200) -- 477
	) -- 477
	local scarfY = cloakTopY - 2 -- 480
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 481
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 482
	local sendX = x - f * cw * 1.65 + cloakDrag -- 483
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 484
	fgDraw:drawQuadraticBezier( -- 485
		Vec2(x - f * cw * 0.3, scarfY), -- 485
		Vec2(smidX, smidY), -- 485
		Vec2(sendX, sendY), -- 485
		2.8, -- 485
		toColor(PALETTE.amberCore, 235) -- 485
	) -- 485
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 488
	local headX = x + f * (a.crouch and 5 or 2) -- 489
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 490
	fgDraw:drawCircle( -- 491
		Vec2(headX, headY), -- 491
		headR, -- 491
		Color(240, 222, 198, 255) -- 491
	) -- 491
	fgDraw:drawPolygon( -- 493
		{ -- 493
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 494
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 495
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 496
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 497
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 498
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 499
		}, -- 499
		Color(156, 114, 62, 248), -- 500
		1.1, -- 500
		Color(244, 214, 162, 200) -- 500
	) -- 500
	fgGlow:drawDot( -- 502
		Vec2(headX + f * headR * 0.45, headY + 1), -- 502
		2.2, -- 502
		toColor(PALETTE.amberCore) -- 502
	) -- 502
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 505
	if hasCompass then -- 505
		local compX = x + f * cw * 0.65 -- 507
		local compY = by + H * 0.48 -- 508
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 509
		fgGlow:drawDot( -- 510
			Vec2(compX, compY), -- 510
			2.6, -- 510
			toColor(PALETTE.amberCore, 250) -- 510
		) -- 510
		fillRadialGlow( -- 511
			fgGlow, -- 511
			compX, -- 511
			compY, -- 511
			26 * glowPulse, -- 511
			26 * glowPulse, -- 511
			Color(248, 206, 120, 78 * glowPulse), -- 511
			Color(248, 180, 72, 0), -- 511
			14 -- 511
		) -- 511
	end -- 511
	if afraid then -- 511
		self:drawFear(fgGlow, p, x, by + H + 16) -- 515
	end -- 515
	if isControlled and walking and not a.crouch and speed > 100 then -- 515
		local r = 10 + self.animTime * 32 % 24 -- 520
		fgGlow:drawRing( -- 521
			Vec2(x, by + 3), -- 521
			r, -- 521
			r + 1.5, -- 521
			Color(0, 0, 0, 0), -- 521
			1.1, -- 521
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 521
		) -- 521
	end -- 521
end -- 377
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 525
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 526
	do -- 526
		local i = 0 -- 527
		while i < FEAR_MAX do -- 527
			local lit = i < p.escort.fear -- 528
			drawDiamond( -- 529
				fgGlow, -- 529
				x + (i - 1) * 13, -- 529
				y, -- 529
				4, -- 529
				5, -- 529
				toColor(lit and tint or PALETTE.steelDark, 215), -- 530
				1, -- 530
				toColor(tint, lit and 235 or 100) -- 530
			) -- 530
			i = i + 1 -- 527
		end -- 527
	end -- 527
end -- 525
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 534
	local x = cam:sx(e.x + f * 20) -- 535
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 536
	local dx = cam:sx(p.player.x) - x -- 537
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 538
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 539
	do -- 539
		local i = 0 -- 540
		while i < 8 do -- 540
			local a = length * i / 8 -- 541
			local b = length * (i + 1) / 8 -- 542
			fgGlow:drawSegment( -- 543
				Vec2(x + dx * a, y + dy * a), -- 543
				Vec2(x + dx * b, y + dy * b), -- 543
				1.3, -- 544
				Color(220, 120, 88, 210) -- 544
			) -- 544
			i = i + 2 -- 540
		end -- 540
	end -- 540
end -- 534
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 549
	local cx = cam:sx(e.x) -- 558
	local depth = e.depth or 0 -- 559
	local by = cam:sy(e.y, depth) -- 560
	local H = cam:len(e.h) -- 561
	local W = cam:len(e.w) -- 562
	local f = p.player.x >= e.x and 1 or -1 -- 563
	if e.kind == "target" then -- 563
		local lean = not e.alive and f * cam:len(12) or (e.hitT > 0 and f * cam:len(5) or 0) -- 567
		local hitTint = e.hitT > 0 or not e.alive -- 568
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 569
		fgDraw:drawEllipse( -- 570
			Vec2(cx, by + 1), -- 570
			W * 0.52, -- 570
			3.6, -- 570
			Color(12, 11, 13, 140) -- 570
		) -- 570
		if not assets:tryPlace( -- 570
			"fe_straw_target", -- 571
			"actor_target_" .. tostring(index), -- 571
			cx + lean * 0.4, -- 571
			by, -- 571
			cam:len(40), -- 571
			H * (e.alive and 0.94 or 0.66), -- 571
			{ -- 571
				angle = not e.alive and f * 48 or (e.hitT > 0 and f * 12 or 0), -- 572
				color = hitTint and Color(242, 188, 156, 255) or Color(255, 255, 255, 255), -- 573
				layer = targetLayer -- 574
			} -- 574
		) then -- 574
			local discR = math.max( -- 576
				7, -- 576
				cam:len(13) -- 576
			) -- 576
			fgDraw:drawCircle( -- 577
				Vec2(cx + lean, by + H * 0.56), -- 577
				discR, -- 577
				Color(196, 174, 134, 250) -- 577
			) -- 577
		end -- 577
		return -- 579
	end -- 579
	local slot = "enemy_idle" -- 582
	if not e.alive then -- 582
		slot = "enemy_down" -- 584
	elseif e.hitT > 0 then -- 584
		slot = "enemy_hit" -- 586
	elseif e.warnT > 0 then -- 586
		slot = "enemy_aim" -- 588
	end -- 588
	local height = e.alive and H or H * 0.24 -- 590
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 591
	if assets:tryPlace( -- 591
		slot, -- 592
		"actor_enemy_" .. tostring(index), -- 592
		cx, -- 592
		by, -- 592
		W, -- 592
		height, -- 592
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 592
	) then -- 592
		if e.alive then -- 592
			self:drawEnemyArchetypeGear( -- 596
				fgDraw, -- 596
				fgGlow, -- 596
				assets, -- 596
				e, -- 596
				index, -- 596
				cx, -- 596
				by, -- 596
				H, -- 596
				f, -- 596
				cam, -- 596
				enemyLayer + 1 -- 596
			) -- 596
			if e.warnT > 0 then -- 596
				self:drawEnemyWarning( -- 598
					fgGlow, -- 598
					e, -- 598
					p, -- 598
					cam, -- 598
					f -- 598
				) -- 598
			end -- 598
		end -- 598
		return -- 601
	end -- 601
	if not e.alive then -- 601
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 605
		fgDraw:drawPolygon( -- 606
			{ -- 606
				Vec2(cx - H * 0.3, by), -- 607
				Vec2(cx + H * 0.28, by), -- 608
				Vec2(cx + H * 0.2, by + H * 0.14), -- 609
				Vec2(cx - H * 0.24, by + H * 0.11) -- 610
			}, -- 610
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 611
		) -- 611
		if flash > 0 then -- 611
			fillRadialGlow( -- 613
				fgGlow, -- 613
				cx, -- 613
				by + 12, -- 613
				34 * flash, -- 613
				18 * flash, -- 613
				toColor(PALETTE.crimson, 180 * flash), -- 613
				Color(255, 48, 82, 0), -- 613
				12 -- 613
			) -- 613
		end -- 613
		return -- 615
	end -- 615
	local sw = H * 0.112 -- 618
	fgDraw:drawEllipse( -- 619
		Vec2(cx, by + 1), -- 619
		sw * 1.9, -- 619
		4, -- 619
		Color(4, 6, 10, 165) -- 619
	) -- 619
	local hipY = by + H * 0.44 -- 622
	local kneeY = by + H * 0.23 -- 623
	local shY = by + H * 0.79 -- 624
	fgDraw:drawSegment( -- 625
		Vec2(cx - 5, hipY), -- 625
		Vec2(cx - 7, kneeY), -- 625
		H * 0.044, -- 625
		Color(20, 16, 26, 255) -- 625
	) -- 625
	fgDraw:drawSegment( -- 626
		Vec2(cx - 7, kneeY), -- 626
		Vec2(cx - 8, by + 2), -- 626
		H * 0.038, -- 626
		Color(20, 16, 26, 255) -- 626
	) -- 626
	fgDraw:drawSegment( -- 627
		Vec2(cx + 5, hipY), -- 627
		Vec2(cx + 7, kneeY), -- 627
		H * 0.046, -- 627
		Color(28, 22, 36, 255) -- 627
	) -- 627
	fgDraw:drawSegment( -- 628
		Vec2(cx + 7, kneeY), -- 628
		Vec2(cx + 8, by + 2), -- 628
		H * 0.04, -- 628
		Color(28, 22, 36, 255) -- 628
	) -- 628
	fgDraw:drawPolygon( -- 630
		{ -- 630
			Vec2(cx - sw * 0.68, hipY), -- 631
			Vec2(cx + sw * 0.68, hipY), -- 632
			Vec2(cx + sw * 1.12, shY), -- 633
			Vec2(cx - sw * 1.12, shY) -- 634
		}, -- 634
		Color(111, 68, 55, 255), -- 635
		1.3, -- 635
		Color(143, 101, 66, 220) -- 635
	) -- 635
	fgDraw:drawPolygon( -- 636
		{ -- 636
			Vec2(cx - sw * 1.26, shY - 6), -- 637
			Vec2(cx + sw * 1.26, shY - 6), -- 638
			Vec2(cx + sw * 0.96, shY + 5), -- 639
			Vec2(cx - sw * 0.96, shY + 5) -- 640
		}, -- 640
		Color(98, 82, 62, 255) -- 641
	) -- 641
	local headR = H * 0.086 -- 643
	local headY = shY + headR * 1.32 -- 644
	fgDraw:drawCircle( -- 645
		Vec2(cx, headY), -- 645
		headR * 0.82, -- 645
		Color(187, 142, 103, 255) -- 645
	) -- 645
	fgDraw:drawPolygon( -- 646
		{ -- 646
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 647
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 648
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 649
		}, -- 649
		Color(136, 105, 65, 255), -- 650
		1.1, -- 650
		Color(177, 145, 91, 220) -- 650
	) -- 650
	local gunX = cx + f * H * 0.34 -- 652
	local gunY = by + H * 0.69 -- 653
	fgDraw:drawSegment( -- 654
		Vec2(cx - f * 6, gunY - 2), -- 654
		Vec2(gunX, gunY), -- 654
		2.8, -- 654
		Color(118, 87, 61, 255) -- 654
	) -- 654
	self:drawEnemyArchetypeGear( -- 655
		fgDraw, -- 655
		fgGlow, -- 655
		assets, -- 655
		e, -- 655
		index, -- 655
		cx, -- 655
		by, -- 655
		H, -- 655
		f, -- 655
		cam, -- 655
		enemyLayer + 1 -- 655
	) -- 655
	if e.warnT > 0 then -- 655
		self:drawEnemyWarning( -- 657
			fgGlow, -- 657
			e, -- 657
			p, -- 657
			cam, -- 657
			f -- 657
		) -- 657
	end -- 657
end -- 549
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 662
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 662
		local shX = cx + f * cam:len(13) -- 676
		local cracked = (e.shieldHp or 2) <= 1 -- 677
		if not assets:tryPlace( -- 677
			"fe_gear_rattan_shield", -- 678
			"enemy_shield_" .. tostring(index), -- 678
			shX, -- 678
			by + H * 0.44, -- 678
			cam:len(22), -- 678
			H * 0.64, -- 678
			{ -- 678
				facing = f, -- 679
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 680
				layer = layer -- 681
			} -- 681
		) then -- 681
			local shW = math.max( -- 683
				5, -- 683
				cam:len(8) -- 683
			) -- 683
			fgDraw:drawRect( -- 684
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 684
				Color(96, 66, 42, 250), -- 684
				1.3, -- 684
				Color(168, 174, 180, 230) -- 684
			) -- 684
		end -- 684
		if cracked then -- 684
			fgDraw:drawSegment( -- 687
				Vec2( -- 687
					shX - cam:len(4), -- 687
					by + H * 0.3 -- 687
				), -- 687
				Vec2( -- 687
					shX + cam:len(4), -- 687
					by + H * 0.56 -- 687
				), -- 687
				1.4, -- 687
				Color(24, 18, 16, 235) -- 687
			) -- 687
		end -- 687
	elseif e.kind == "breaker" then -- 687
		local swing = (e.swingT or 0) > 0 -- 690
		local handleX0 = cx - f * cam:len(4) -- 691
		local handleY0 = by + H * 0.44 -- 692
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 693
		local tipY = by + H * (swing and 0.46 or 0.78) -- 694
		fgDraw:drawSegment( -- 695
			Vec2(handleX0, handleY0), -- 695
			Vec2(tipX, tipY), -- 695
			math.max( -- 695
				2.2, -- 695
				cam:len(3) -- 695
			), -- 695
			Color(98, 66, 44, 255) -- 695
		) -- 695
		fgDraw:drawPolygon( -- 696
			{ -- 696
				Vec2( -- 697
					tipX - f * cam:len(3), -- 697
					tipY - cam:len(4) -- 697
				), -- 697
				Vec2( -- 698
					tipX + f * cam:len(9), -- 698
					tipY - cam:len(1) -- 698
				), -- 698
				Vec2( -- 699
					tipX + f * cam:len(7), -- 699
					tipY + cam:len(9) -- 699
				), -- 699
				Vec2( -- 700
					tipX - f * cam:len(2), -- 700
					tipY + cam:len(6) -- 700
				) -- 700
			}, -- 700
			Color(148, 154, 162, 250), -- 701
			1, -- 701
			Color(224, 228, 232, 220) -- 701
		) -- 701
		if swing then -- 701
			fgGlow:drawArc( -- 703
				Vec2( -- 703
					cx + f * cam:len(10), -- 703
					by + H * 0.56 -- 703
				), -- 703
				cam:len(18), -- 703
				f > 0 and -40 or 140, -- 703
				f > 0 and 50 or 230, -- 703
				1.8, -- 703
				toColor(PALETTE.rouge, 195) -- 703
			) -- 703
		end -- 703
	elseif e.kind == "leader" then -- 703
		local topY = by + H * 1.02 -- 707
		fgDraw:drawSegment( -- 708
			Vec2(cx, topY), -- 708
			Vec2( -- 708
				cx - f * cam:len(10), -- 708
				topY + cam:len(9) -- 708
			), -- 708
			2.2, -- 708
			toColor(PALETTE.rouge, 240) -- 708
		) -- 708
		fgDraw:drawDot( -- 709
			Vec2( -- 709
				cx - f * cam:len(10), -- 709
				topY + cam:len(9) -- 709
			), -- 709
			2.6, -- 709
			toColor(PALETTE.crimsonCore, 235) -- 709
		) -- 709
	end -- 709
end -- 662
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 714
	local s = p.room.scavenger -- 721
	if s == nil then -- 721
		return -- 723
	end -- 723
	local cx = cam:sx(p.scavX) -- 725
	local by = cam:sy(s.y) -- 726
	local H = cam:len(s.h) -- 727
	local W = cam:len(26) -- 728
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 729
	local alert = p.scavChase or p.scavSee > 0 -- 732
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 733
	local eyeY = by + H * 0.8 -- 734
	local coneLen = cam:len(alert and 155 or 115) -- 735
	fgGlow:drawVertices({ -- 736
		{ -- 737
			Vec2(cx + f * 6, eyeY), -- 737
			toColor(coneCol, alert and 78 or 34) -- 737
		}, -- 737
		{ -- 738
			Vec2(cx + f * coneLen, by + H * 1.05), -- 738
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 738
		}, -- 738
		{ -- 739
			Vec2(cx + f * coneLen, by + 4), -- 739
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 739
		} -- 739
	}) -- 739
	local frame = 0 -- 742
	if p.scavState == "turn" then -- 742
		frame = 2 -- 744
	elseif p.scavState == "chase" then -- 744
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 746
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 746
		frame = math.floor(self.animTime * 8) % 2 -- 748
	end -- 748
	if assets:tryPlace( -- 748
		"scavenger", -- 750
		"actor_scav", -- 750
		cx, -- 750
		by, -- 750
		W, -- 750
		H, -- 750
		{facing = f, frame = frame, layer = 3} -- 750
	) then -- 750
		return -- 751
	end -- 751
	fgDraw:drawEllipse( -- 754
		Vec2(cx, by + 1), -- 754
		W * 0.62, -- 754
		4, -- 754
		Color(4, 6, 10, 155) -- 754
	) -- 754
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 755
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 756
	fgDraw:drawSegment( -- 758
		Vec2(cx - 4, by + H * 0.4), -- 758
		Vec2(cx - stride, by + 2), -- 758
		W * 0.16, -- 758
		Color(32, 30, 28, 255) -- 758
	) -- 758
	fgDraw:drawSegment( -- 759
		Vec2(cx + 4, by + H * 0.4), -- 759
		Vec2(cx + stride, by + 2), -- 759
		W * 0.16, -- 759
		Color(44, 40, 36, 255) -- 759
	) -- 759
	fgDraw:drawPolygon( -- 761
		{ -- 761
			Vec2(cx - W * 0.45, by + H * 0.25), -- 762
			Vec2(cx + W * 0.42, by + H * 0.25), -- 763
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 764
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 765
		}, -- 765
		Color(56, 52, 46, 255), -- 766
		1.2, -- 766
		Color(128, 118, 100, 180) -- 766
	) -- 766
	local headX = cx + f * 5 -- 768
	local headY = by + H * 0.88 -- 769
	fgDraw:drawCircle( -- 770
		Vec2(headX, headY), -- 770
		W * 0.3, -- 770
		Color(42, 38, 34, 255) -- 770
	) -- 770
	fgGlow:drawDot( -- 771
		Vec2(headX + f * 6, headY), -- 771
		3, -- 771
		toColor(coneCol, 245) -- 771
	) -- 771
	local indY = by + H + 18 -- 774
	if p.scavChase then -- 774
		drawDiamond( -- 776
			fgGlow, -- 776
			cx, -- 776
			indY, -- 776
			9, -- 776
			12, -- 776
			toColor(PALETTE.crimson, 240), -- 776
			1.5, -- 776
			toColor(PALETTE.crimsonCore) -- 776
		) -- 776
	elseif p.scavSee > 0 then -- 776
		local frac = math.min(1, p.scavSee / 24) -- 778
		fgGlow:drawArc( -- 779
			Vec2(cx, indY), -- 779
			11, -- 779
			90, -- 779
			90 - 360 * frac, -- 779
			2.4, -- 779
			toColor(PALETTE.crimson, 235) -- 779
		) -- 779
		fgGlow:drawDot( -- 780
			Vec2(cx, indY), -- 780
			3, -- 780
			toColor(PALETTE.amber) -- 780
		) -- 780
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 780
		drawDiamond( -- 782
			fgGlow, -- 782
			cx, -- 782
			indY, -- 782
			6, -- 782
			8, -- 782
			toColor(PALETTE.amber, 220) -- 782
		) -- 782
	end -- 782
end -- 714
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 787
	local cx = cam:sx(p.dogX) -- 794
	local by = cam:sy(0) -- 795
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 796
	local W = cam:len(42) -- 797
	local H = cam:len(34) -- 798
	local frame = 0 -- 800
	if p.dogState == "ear" then -- 800
		frame = 1 -- 802
	elseif p.dogState == "sniff" then -- 802
		frame = 3 -- 804
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 804
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 806
	end -- 806
	if assets:tryPlace( -- 806
		"dog", -- 808
		"actor_dog", -- 808
		cx, -- 808
		by, -- 808
		W, -- 808
		H, -- 808
		{facing = f, frame = frame, layer = 3} -- 808
	) then -- 808
		return -- 809
	end -- 809
	fgDraw:drawEllipse( -- 812
		Vec2(cx, by + 1), -- 812
		W * 0.56, -- 812
		3.5, -- 812
		Color(4, 8, 10, 155) -- 812
	) -- 812
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 813
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 814
	fgDraw:drawSegment( -- 817
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 817
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 817
		2.8, -- 817
		Color(26, 30, 34, 255) -- 817
	) -- 817
	fgDraw:drawSegment( -- 818
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 818
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 818
		2.8, -- 818
		Color(36, 40, 44, 255) -- 818
	) -- 818
	fgDraw:drawPolygon( -- 820
		{ -- 820
			Vec2(cx - W * 0.42, by + H * 0.36), -- 821
			Vec2(cx + W * 0.38, by + H * 0.42), -- 822
			Vec2(cx + W * 0.34, by + H * 0.78), -- 823
			Vec2(cx - W * 0.38, by + H * 0.72) -- 824
		}, -- 824
		Color(38, 42, 48, 255), -- 825
		1.2, -- 825
		Color(102, 118, 126, 175) -- 825
	) -- 825
	local hx = cx + f * W * 0.42 -- 826
	local hy = by + H * 0.84 -- 827
	fgDraw:drawPolygon( -- 828
		{ -- 828
			Vec2(hx - f * 8, hy - 6), -- 829
			Vec2(hx + f * 12, hy - 2), -- 830
			Vec2(hx + f * 4, hy + 8), -- 831
			Vec2(hx - f * 6, hy + 14) -- 832
		}, -- 832
		Color(44, 48, 54, 255) -- 833
	) -- 833
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 835
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 836
	fgGlow:drawDot( -- 837
		Vec2(hx + f * 4, hy + 2), -- 837
		2.8, -- 837
		toColor(eyeCol, 250) -- 837
	) -- 837
	fillRadialGlow( -- 838
		fgGlow, -- 838
		hx + f * 4, -- 838
		hy + 2, -- 838
		16, -- 838
		16, -- 838
		toColor(eyeCol, alert and 135 or 70), -- 838
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 838
		12 -- 838
	) -- 838
	if alert then -- 838
		local r = 12 + self.animTime * 42 % 24 -- 841
		fgGlow:drawArc( -- 842
			Vec2(hx, hy + 12), -- 842
			r, -- 842
			35, -- 842
			145, -- 842
			1.8, -- 842
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 842
		) -- 842
	end -- 842
end -- 787
return ____exports -- 787