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
local ____theme = require("Script.watch.fe.theme") -- 11
local PALETTE = ____theme.PALETTE -- 11
local drawDiamond = ____theme.drawDiamond -- 11
local fillRadialGlow = ____theme.fillRadialGlow -- 11
local toColor = ____theme.toColor -- 11
____exports.ActorsRenderer = __TS__Class() -- 24
local ActorsRenderer = ____exports.ActorsRenderer -- 24
ActorsRenderer.name = "ActorsRenderer" -- 24
function ActorsRenderer.prototype.____constructor(self) -- 24
	self.ghosts = {} -- 25
	self.ghostCooldown = 0 -- 26
	self.animTime = 0 -- 27
	self.previousHp = 3 -- 28
	self.previousAxle = 0 -- 29
	self.cartMoving = false -- 30
	self.previousBottle = false -- 31
	self.hitUntil = -1 -- 33
	self.throwUntil = -1 -- 34
	self.shotUntil = -1 -- 35
end -- 24
function ActorsRenderer.prototype.reset(self, p) -- 37
	self.ghosts = {} -- 38
	self.ghostCooldown = 0 -- 39
	self.animTime = 0 -- 40
	self.previousHp = p.hp -- 41
	self.previousAxle = p.cartAxle -- 42
	self.cartMoving = false -- 43
	self.previousBottle = p.hasBottle -- 44
	self.previousTrace = p.trace -- 45
	self.hitUntil = -1 -- 46
	self.throwUntil = -1 -- 47
	self.shotUntil = -1 -- 48
end -- 37
function ActorsRenderer.prototype.update(self, dt, p) -- 52
	self.animTime = self.animTime + dt -- 53
	if p.hp < self.previousHp or p.gateNeedConfirm then -- 53
		self.hitUntil = p.ticks + 14 -- 55
	end -- 55
	if self.previousBottle and not p.hasBottle and p.bottleFly ~= nil then -- 55
		self.throwUntil = p.ticks + 12 -- 58
	end -- 58
	if p.trace ~= nil and p.trace ~= self.previousTrace then -- 58
		self.shotUntil = p.ticks + 7 -- 61
	end -- 61
	self.cartMoving = math.abs(p.cartAxle - self.previousAxle) > 0.01 -- 63
	self.previousAxle = p.cartAxle -- 64
	self.previousHp = p.hp -- 65
	self.previousBottle = p.hasBottle -- 66
	self.previousTrace = p.trace -- 67
	if not p.childMode and p.player.rollT > 0 then -- 67
		self.ghostCooldown = self.ghostCooldown - dt -- 70
		if self.ghostCooldown <= 0 then -- 70
			local ____self_ghosts_0 = self.ghosts -- 70
			____self_ghosts_0[#____self_ghosts_0 + 1] = { -- 72
				x = p.player.x, -- 73
				y = p.player.y, -- 74
				depth = p.player.depth, -- 75
				h = p.player.h, -- 76
				facing = p.player.facing, -- 77
				life = 0.28, -- 78
				maxLife = 0.28, -- 79
				isRoll = true -- 80
			} -- 80
			self.ghostCooldown = 0.036 -- 82
		end -- 82
	else -- 82
		self.ghostCooldown = 0 -- 85
	end -- 85
	local write = 0 -- 89
	local i = 0 -- 90
	do -- 90
		i = 0 -- 91
		while i < #self.ghosts do -- 91
			local g = self.ghosts[i + 1] -- 92
			g.life = g.life - dt -- 93
			if g.life > 0 then -- 93
				self.ghosts[write + 1] = g -- 95
				write = write + 1 -- 96
			end -- 96
			i = i + 1 -- 91
		end -- 91
	end -- 91
	__TS__ArraySetLength(self.ghosts, write) -- 91
end -- 52
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, pose) -- 102
	self:drawAfterimages(fgGlow, assets, cam) -- 111
	local i = 0 -- 114
	do -- 114
		i = 0 -- 115
		while i < #p.enemies do -- 115
			self:drawEnemy( -- 116
				fgDraw, -- 116
				fgGlow, -- 116
				assets, -- 116
				p.enemies[i + 1], -- 116
				i, -- 116
				p, -- 116
				cam -- 116
			) -- 116
			i = i + 1 -- 115
		end -- 115
	end -- 115
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 115
		self:drawScavenger( -- 121
			fgDraw, -- 121
			fgGlow, -- 121
			assets, -- 121
			p, -- 121
			cam -- 121
		) -- 121
	end -- 121
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 121
		self:drawDog( -- 126
			fgDraw, -- 126
			fgGlow, -- 126
			assets, -- 126
			p, -- 126
			cam -- 126
		) -- 126
	end -- 126
	if p.partner.alive and not (pose and pose.partner) then -- 126
		local partnerIsChild = p.partner.w <= 28 -- 131
		if partnerIsChild then -- 131
			self:drawXiaoman( -- 133
				fgDraw, -- 133
				fgGlow, -- 133
				assets, -- 133
				p.partner, -- 133
				p, -- 133
				cam, -- 133
				false -- 133
			) -- 133
		else -- 133
			self:drawZhouShu( -- 135
				fgDraw, -- 135
				fgGlow, -- 135
				assets, -- 135
				p.partner, -- 135
				p, -- 135
				cam, -- 135
				false -- 135
			) -- 135
		end -- 135
	end -- 135
	if p.player.alive then -- 135
		if p.childMode then -- 135
			self:drawXiaoman( -- 142
				fgDraw, -- 142
				fgGlow, -- 142
				assets, -- 142
				p.player, -- 142
				p, -- 142
				cam, -- 142
				true -- 142
			) -- 142
		else -- 142
			self:drawZhouShu( -- 144
				fgDraw, -- 144
				fgGlow, -- 144
				assets, -- 144
				p.player, -- 144
				p, -- 144
				cam, -- 144
				true, -- 144
				pose and pose.player -- 144
			) -- 144
		end -- 144
	end -- 144
end -- 102
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, assets, cam) -- 150
	local i = 0 -- 151
	do -- 151
		i = 0 -- 152
		while i < #self.ghosts do -- 152
			local g = self.ghosts[i + 1] -- 153
			local k = math.max( -- 154
				0, -- 154
				math.min(1, g.life / g.maxLife) -- 154
			) -- 154
			local spread = 1 - k -- 155
			local cx = cam:sx(g.x) -- 156
			local by = cam:sy(g.y, g.depth) -- 157
			local f = g.facing -- 158
			local sz = cam:len(16 + spread * 16) -- 159
			if not assets:tryPlace( -- 159
				"fe_vfx_smoke", -- 161
				"roll_dust_" .. tostring(i), -- 162
				cx - f * cam:len(7 + spread * 12), -- 163
				by + cam:len(6 + spread * 6), -- 164
				sz, -- 165
				sz, -- 166
				{ -- 167
					frame = math.min( -- 168
						3, -- 168
						math.floor(spread * 4) -- 168
					), -- 168
					color = Color(218, 206, 186, 255), -- 169
					opacity = 0.7 * k, -- 170
					layer = 2 -- 171
				} -- 171
			) then -- 171
				local rBase = cam:len(6 + spread * 9) -- 174
				fgGlow:drawCircle( -- 175
					Vec2( -- 175
						cx - f * cam:len(6 + spread * 10), -- 175
						by + cam:len(4 + spread * 5) -- 175
					), -- 175
					rBase, -- 175
					Color( -- 175
						156, -- 175
						144, -- 175
						124, -- 175
						math.floor(78 * k + 0.5) -- 175
					) -- 175
				) -- 175
			end -- 175
			i = i + 1 -- 152
		end -- 152
	end -- 152
end -- 150
function ActorsRenderer.prototype.supportGroundY(self, p, a) -- 181
	local half = a.w * 0.5 -- 182
	local g = 0 -- 183
	local i = 0 -- 184
	do -- 184
		i = 0 -- 185
		while i < #p.room.floors do -- 185
			local f = p.room.floors[i + 1] -- 186
			if a.x + half > f.x0 and a.x - half < f.x1 and f.y <= a.y + 0.5 and f.y > g then -- 186
				g = f.y -- 188
			end -- 188
			i = i + 1 -- 185
		end -- 185
	end -- 185
	do -- 185
		i = 0 -- 191
		while i < #p.boxes do -- 191
			do -- 191
				local b = p.boxes[i + 1] -- 192
				if b.broken == true or b.hidden == true or b.soft == true then -- 192
					goto __continue34 -- 194
				end -- 194
				if a.x + half > b.x0 and a.x - half < b.x1 and b.y1 <= a.y + 0.5 and b.y1 > g and overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 194
					g = b.y1 -- 198
				end -- 198
			end -- 198
			::__continue34:: -- 198
			i = i + 1 -- 191
		end -- 191
	end -- 191
	return g -- 201
end -- 181
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled, bodyPlaced) -- 205
	if bodyPlaced == nil then -- 205
		bodyPlaced = false -- 213
	end -- 213
	local cx = cam:sx(a.x) -- 215
	local by = cam:sy(a.y, a.depth) -- 216
	local depthEnabled = p.room.depth ~= nil -- 217
	local shadowY = not a.onGround and cam:sy( -- 218
		self:supportGroundY(p, a), -- 218
		a.depth -- 218
	) or by -- 218
	local H = cam:len(a.h) -- 219
	local W = cam:len(a.w) -- 220
	local f = a.facing -- 221
	local speed = math.max( -- 222
		math.abs(a.vx), -- 222
		math.abs(a.depthSpeed) -- 222
	) -- 222
	local slot = "soldier_idle" -- 224
	local height = H -- 225
	local frame = 0 -- 226
	local facing = f -- 227
	local step = math.floor(self.animTime * 10) -- 228
	if isControlled and p.ticks < self.hitUntil then -- 228
		slot = "soldier_hit" -- 230
	elseif a.rollT > 0 then -- 230
		slot = "soldier_roll" -- 232
		height = height * 0.59 -- 233
	elseif p.phase == "prologue-give" then -- 233
		slot = "soldier_offer" -- 235
		height = height * 0.75 -- 236
		facing = p.partner.x >= a.x and 1 or -1 -- 237
	elseif isControlled and p.gripping then -- 237
		slot = "soldier_push" -- 239
		frame = self.cartMoving and step or 0 -- 240
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 241
		height = height * 0.91 -- 242
	elseif isControlled and p.escort.state == "calming" then -- 242
		slot = "soldier_knock" -- 244
		local calm = p.escort.calmTick -- 245
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 246
		height = height * 0.76 -- 247
	else -- 247
		local ____temp_7 = p.phase == "gate-send" -- 248
		if ____temp_7 then -- 248
			local ____opt_5 = p.room.story -- 248
			____temp_7 = (____opt_5 and ____opt_5.gate) ~= nil -- 248
		end -- 248
		if ____temp_7 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 248
			slot = "soldier_hold" -- 250
			height = height * 1.11 -- 251
		elseif isControlled and p.ticks < self.shotUntil then -- 251
			local running = speed > 8 -- 253
			slot = running and "soldier_fire_move" or "soldier_fire" -- 254
			frame = running and step or 0 -- 255
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 256
		elseif a.covered or isControlled and p.coverHug then -- 256
			slot = "soldier_cover" -- 258
			height = height * 0.77 -- 259
		elseif speed > 8 then -- 259
			slot = "soldier_run" -- 261
			frame = step -- 262
		end -- 262
	end -- 262
	if bodyPlaced or assets:tryPlace( -- 262
		slot, -- 264
		"actor_soldier", -- 264
		cx, -- 264
		by, -- 264
		W, -- 264
		height, -- 264
		{ -- 264
			facing = facing, -- 265
			frame = frame, -- 265
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 265
		} -- 265
	) then -- 265
		fgDraw:drawEllipse( -- 267
			Vec2(cx, shadowY + 1), -- 267
			W * 0.54, -- 267
			4, -- 267
			Color(12, 11, 13, 145) -- 267
		) -- 267
		return -- 268
	end -- 268
	fgDraw:drawEllipse( -- 272
		Vec2(cx, shadowY + 1), -- 272
		H * 0.24, -- 272
		4.5, -- 272
		Color(3, 5, 10, 175) -- 272
	) -- 272
	local walking = speed > 10 and a.onGround -- 274
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 275
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 276
	local calming = not p.childMode and p.escort.state == "calming" -- 277
	local rolling = a.rollT > 0 -- 278
	local crouching = a.covered or calming or rolling -- 279
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 282
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 283
	local sw = H * 0.115 -- 284
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 287
	local kneeY = by + bodyH * 0.23 -- 288
	local stepX = stride * H * 0.15 -- 289
	local legDark = Color(14, 21, 34, 255) -- 290
	local legFront = Color(26, 38, 58, 255) -- 291
	local bkX = cx - f * 4 - stepX * 0.5 -- 293
	local bfX = cx - f * 8 - stepX -- 294
	fgDraw:drawSegment( -- 295
		Vec2(cx - f * 3, hipY), -- 295
		Vec2(bkX, kneeY), -- 295
		H * 0.044, -- 295
		legDark -- 295
	) -- 295
	fgDraw:drawSegment( -- 296
		Vec2(bkX, kneeY), -- 296
		Vec2(bfX, by + 3), -- 296
		H * 0.038, -- 296
		legDark -- 296
	) -- 296
	local fkX = cx + f * 6 + stepX * 0.55 -- 298
	local ffX = cx + f * 7 + stepX -- 299
	fgDraw:drawSegment( -- 300
		Vec2(cx + f * 3, hipY), -- 300
		Vec2(fkX, kneeY), -- 300
		H * 0.048, -- 300
		legFront -- 300
	) -- 300
	fgDraw:drawSegment( -- 301
		Vec2(fkX, kneeY), -- 301
		Vec2(ffX, by + 3), -- 301
		H * 0.042, -- 301
		legFront -- 301
	) -- 301
	fgDraw:drawSegment( -- 303
		Vec2(ffX - f * 2, by + 3), -- 303
		Vec2(ffX + f * 9, by + 3), -- 303
		3.4, -- 303
		Color(42, 60, 86, 255) -- 303
	) -- 303
	local shY = by + bodyH * 0.8 + bob -- 306
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 307
	fgDraw:drawPolygon( -- 308
		{ -- 308
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 309
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 310
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 311
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 312
		}, -- 312
		Color(16, 26, 42, 248), -- 313
		1.2, -- 313
		Color(64, 118, 164, 195) -- 313
	) -- 313
	fgDraw:drawPolygon( -- 316
		{ -- 316
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 317
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 318
			Vec2(cx + sw * 1.05 + lean, shY), -- 319
			Vec2(cx - sw * 0.98 + lean, shY) -- 320
		}, -- 320
		Color(24, 38, 60, 255), -- 321
		1.3, -- 321
		toColor(PALETTE.rimSilver, 190) -- 321
	) -- 321
	fgDraw:drawSegment( -- 323
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 324
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 325
		2.4, -- 326
		Color(173, 155, 125, 225) -- 327
	) -- 327
	fgDraw:drawPolygon( -- 329
		{ -- 329
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 330
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 331
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 332
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 333
		}, -- 333
		Color(99, 105, 103, 248) -- 334
	) -- 334
	local headR = H * 0.088 -- 337
	local headX = cx + lean + f * 3 -- 338
	local headY = shY + headR * 1.35 -- 339
	fgDraw:drawCircle( -- 340
		Vec2(headX, headY - headR * 0.12), -- 340
		headR * 0.86, -- 340
		Color(181, 139, 106, 255) -- 340
	) -- 340
	fgDraw:drawEllipse( -- 341
		Vec2(headX, headY + headR * 0.5), -- 341
		headR * 1.12, -- 341
		headR * 0.72, -- 341
		Color(66, 73, 76, 255) -- 341
	) -- 341
	fgDraw:drawSegment( -- 342
		Vec2(headX - headR, headY + 1), -- 342
		Vec2(headX + headR, headY + 1), -- 342
		1.6, -- 343
		Color(97, 103, 101, 255) -- 343
	) -- 343
	fgDraw:drawSegment( -- 344
		Vec2(headX, headY + headR), -- 344
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 344
		1.6, -- 345
		Color(177, 78, 51, 255) -- 345
	) -- 345
	if isControlled and not calming and not rolling and not p.gripping then -- 345
		local gunPivotX = cx + lean + f * sw * 0.35 -- 349
		local gunPivotY = shY - bodyH * 0.1 -- 350
		local aimDx = f -- 351
		local aimDy = 0 -- 352
		if p.aimX > 0 or p.aimY > 0 then -- 352
			aimDx = p.aimX - gunPivotX -- 354
			aimDy = p.aimY - gunPivotY -- 355
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 356
			if dLen > 4 then -- 356
				aimDx = aimDx / dLen -- 358
				aimDy = aimDy / dLen -- 359
			end -- 359
		end -- 359
		local barrelLen = H * 0.34 -- 362
		local tipX = gunPivotX + aimDx * barrelLen -- 363
		local tipY = gunPivotY + aimDy * barrelLen -- 364
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 365
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 366
		fgDraw:drawSegment( -- 368
			Vec2(cx + lean, shY - 5), -- 368
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 368
			3.6, -- 368
			Color(26, 40, 62, 255) -- 368
		) -- 368
		fgDraw:drawSegment( -- 369
			Vec2(stockX, stockY), -- 369
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 369
			3.8, -- 369
			Color(105, 71, 50, 255) -- 369
		) -- 369
		fgDraw:drawSegment( -- 370
			Vec2(gunPivotX, gunPivotY), -- 370
			Vec2(tipX, tipY), -- 370
			1.8, -- 370
			Color(145, 140, 128, 245) -- 370
		) -- 370
	elseif calming then -- 370
		fgDraw:drawSegment( -- 372
			Vec2(cx + lean, shY - 6), -- 372
			Vec2(cx + f * sw * 2.1, shY - 14), -- 372
			3, -- 372
			Color(196, 222, 240, 235) -- 372
		) -- 372
		fgGlow:drawDot( -- 373
			Vec2(cx + f * sw * 2.15, shY - 14), -- 373
			3.6, -- 373
			toColor(PALETTE.amber, 225) -- 373
		) -- 373
	end -- 373
end -- 205
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 379
	local cx = cam:sx(a.x) -- 388
	local by = cam:sy(a.y, a.depth) -- 389
	local depthEnabled = p.room.depth ~= nil -- 390
	local shadowY = not a.onGround and cam:sy( -- 391
		self:supportGroundY(p, a), -- 391
		a.depth -- 391
	) or by -- 391
	local H = cam:len(a.h) -- 392
	local W = cam:len(a.w) -- 393
	local f = a.facing -- 394
	local speed = math.max( -- 395
		math.abs(a.vx), -- 395
		math.abs(a.depthSpeed) -- 395
	) -- 395
	local afraid = not isControlled and p.escort.fear > 0 -- 397
	local slot = "child_idle" -- 398
	local height = H -- 399
	local frame = 0 -- 400
	local step = math.floor(self.animTime * 10) -- 401
	local nearCover = __TS__ArraySome( -- 402
		p.room.solids, -- 402
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 402
			math.abs(a.x - solid.x), -- 405
			math.abs(a.x - solid.x - solid.w) -- 405
		) <= 30 end -- 405
	) -- 405
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 405
		slot = "child_knock" -- 408
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 408
		slot = "child_offer" -- 411
	elseif isControlled and p.ticks < self.throwUntil then -- 411
		slot = "child_throw" -- 413
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 413
		slot = "child_aim" -- 415
	elseif isControlled and p.gripping then -- 415
		slot = "child_pull" -- 417
		frame = self.cartMoving and step or 0 -- 418
	elseif afraid and p.escort.state == "frozen" then -- 418
		slot = "child_fear" -- 420
		height = height * 0.74 -- 421
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 421
		slot = "child_peek" -- 424
		height = height * 0.83 -- 425
	elseif a.crouch then -- 425
		slot = "child_crouch" -- 427
		frame = speed > 8 and step or 0 -- 428
	elseif speed > 8 then -- 428
		slot = "child_run" -- 430
		frame = step -- 431
	end -- 431
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 433
	if assets:tryPlace( -- 433
		slot, -- 434
		"actor_child", -- 434
		cx, -- 434
		by, -- 434
		W, -- 434
		height, -- 434
		{ -- 434
			facing = facing, -- 435
			frame = frame, -- 435
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 435
		} -- 435
	) then -- 435
		fgDraw:drawEllipse( -- 437
			Vec2(cx, shadowY + 1), -- 437
			W * 0.48, -- 437
			3, -- 437
			Color(12, 11, 13, 125) -- 437
		) -- 437
		if afraid then -- 437
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 439
		end -- 439
		return -- 441
	end -- 441
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 444
	local x = cx + jitter -- 445
	local fullRef = a.crouch and H * 1.35 or H -- 447
	local cw = fullRef * 0.16 -- 448
	fgDraw:drawEllipse( -- 451
		Vec2(x, shadowY + 1), -- 451
		cw * 1.15, -- 451
		3.6, -- 451
		Color(4, 6, 10, 155) -- 451
	) -- 451
	local walking = speed > 6 and a.onGround -- 453
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 454
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 455
	local hipY = by + H * 0.3 -- 458
	local legSwing = stride * cw * 0.85 -- 459
	fgDraw:drawSegment( -- 460
		Vec2(x - 2, hipY), -- 460
		Vec2(x - legSwing, by + 2), -- 460
		math.max(2.6, cw * 0.22), -- 460
		Color(34, 30, 38, 255) -- 460
	) -- 460
	fgDraw:drawSegment( -- 461
		Vec2(x + 2, hipY), -- 461
		Vec2(x + legSwing, by + 2), -- 461
		math.max(2.8, cw * 0.24), -- 461
		Color(52, 46, 56, 255) -- 461
	) -- 461
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 464
	local cloakBotY = by + H * 0.2 -- 465
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 466
	fgDraw:drawPolygon( -- 467
		{ -- 467
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 468
			Vec2(x + cw * 0.92, cloakBotY), -- 469
			Vec2(x + cw * 0.62, cloakTopY), -- 470
			Vec2(x - cw * 0.68, cloakTopY) -- 471
		}, -- 471
		Color(214, 166, 94, 255), -- 472
		1.3, -- 472
		Color(252, 232, 192, 225) -- 472
	) -- 472
	fgDraw:drawPolygon( -- 473
		{ -- 473
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 474
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 475
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 476
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 477
		}, -- 477
		Color(148, 108, 56, 215) -- 478
	) -- 478
	fgDraw:drawSegment( -- 479
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 479
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 479
		1.8, -- 479
		toColor(PALETTE.amberCore, 200) -- 479
	) -- 479
	local scarfY = cloakTopY - 2 -- 482
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 483
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 484
	local sendX = x - f * cw * 1.65 + cloakDrag -- 485
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 486
	fgDraw:drawQuadraticBezier( -- 487
		Vec2(x - f * cw * 0.3, scarfY), -- 487
		Vec2(smidX, smidY), -- 487
		Vec2(sendX, sendY), -- 487
		2.8, -- 487
		toColor(PALETTE.amberCore, 235) -- 487
	) -- 487
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 490
	local headX = x + f * (a.crouch and 5 or 2) -- 491
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 492
	fgDraw:drawCircle( -- 493
		Vec2(headX, headY), -- 493
		headR, -- 493
		Color(240, 222, 198, 255) -- 493
	) -- 493
	fgDraw:drawPolygon( -- 495
		{ -- 495
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 496
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 497
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 498
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 499
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 500
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 501
		}, -- 501
		Color(156, 114, 62, 248), -- 502
		1.1, -- 502
		Color(244, 214, 162, 200) -- 502
	) -- 502
	fgGlow:drawDot( -- 504
		Vec2(headX + f * headR * 0.45, headY + 1), -- 504
		2.2, -- 504
		toColor(PALETTE.amberCore) -- 504
	) -- 504
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 507
	if hasCompass then -- 507
		local compX = x + f * cw * 0.65 -- 509
		local compY = by + H * 0.48 -- 510
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 511
		fgGlow:drawDot( -- 512
			Vec2(compX, compY), -- 512
			2.6, -- 512
			toColor(PALETTE.amberCore, 250) -- 512
		) -- 512
		fillRadialGlow( -- 513
			fgGlow, -- 513
			compX, -- 513
			compY, -- 513
			26 * glowPulse, -- 513
			26 * glowPulse, -- 513
			Color(248, 206, 120, 78 * glowPulse), -- 513
			Color(248, 180, 72, 0), -- 513
			14 -- 513
		) -- 513
	end -- 513
	if afraid then -- 513
		self:drawFear(fgGlow, p, x, by + H + 16) -- 517
	end -- 517
	if isControlled and walking and not a.crouch and speed > 100 then -- 517
		local r = 10 + self.animTime * 32 % 24 -- 522
		fgGlow:drawRing( -- 523
			Vec2(x, by + 3), -- 523
			r, -- 523
			r + 1.5, -- 523
			Color(0, 0, 0, 0), -- 523
			1.1, -- 523
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 523
		) -- 523
	end -- 523
end -- 379
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 527
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 528
	do -- 528
		local i = 0 -- 529
		while i < FEAR_MAX do -- 529
			local lit = i < p.escort.fear -- 530
			drawDiamond( -- 531
				fgGlow, -- 531
				x + (i - 1) * 13, -- 531
				y, -- 531
				4, -- 531
				5, -- 531
				toColor(lit and tint or PALETTE.steelDark, 215), -- 532
				1, -- 532
				toColor(tint, lit and 235 or 100) -- 532
			) -- 532
			i = i + 1 -- 529
		end -- 529
	end -- 529
end -- 527
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 536
	local x = cam:sx(e.x + f * 20) -- 537
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 538
	local dx = cam:sx(p.player.x) - x -- 539
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 540
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 541
	do -- 541
		local i = 0 -- 542
		while i < 8 do -- 542
			local a = length * i / 8 -- 543
			local b = length * (i + 1) / 8 -- 544
			fgGlow:drawSegment( -- 545
				Vec2(x + dx * a, y + dy * a), -- 545
				Vec2(x + dx * b, y + dy * b), -- 545
				1.3, -- 546
				Color(220, 120, 88, 210) -- 546
			) -- 546
			i = i + 2 -- 542
		end -- 542
	end -- 542
end -- 536
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 551
	local cx = cam:sx(e.x) -- 560
	local depth = e.depth or 0 -- 561
	local by = cam:sy(e.y, depth) -- 562
	local H = cam:len(e.h) -- 563
	local W = cam:len(e.w) -- 564
	local f = p.player.x >= e.x and 1 or -1 -- 565
	if e.kind == "target" then -- 565
		local lean = not e.alive and f * cam:len(12) or (e.hitT > 0 and f * cam:len(5) or 0) -- 569
		local hitTint = e.hitT > 0 or not e.alive -- 570
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 571
		fgDraw:drawEllipse( -- 572
			Vec2(cx, by + 1), -- 572
			W * 0.52, -- 572
			3.6, -- 572
			Color(12, 11, 13, 140) -- 572
		) -- 572
		if not assets:tryPlace( -- 572
			"fe_straw_target", -- 573
			"actor_target_" .. tostring(index), -- 573
			cx + lean * 0.4, -- 573
			by, -- 573
			cam:len(40), -- 573
			H * (e.alive and 0.94 or 0.66), -- 573
			{ -- 573
				angle = not e.alive and f * 48 or (e.hitT > 0 and f * 12 or 0), -- 574
				color = hitTint and Color(242, 188, 156, 255) or Color(255, 255, 255, 255), -- 575
				layer = targetLayer -- 576
			} -- 576
		) then -- 576
			local discR = math.max( -- 578
				7, -- 578
				cam:len(13) -- 578
			) -- 578
			fgDraw:drawCircle( -- 579
				Vec2(cx + lean, by + H * 0.56), -- 579
				discR, -- 579
				Color(196, 174, 134, 250) -- 579
			) -- 579
		end -- 579
		return -- 581
	end -- 581
	local slot = "enemy_idle" -- 584
	if not e.alive then -- 584
		slot = "enemy_down" -- 586
	elseif e.hitT > 0 then -- 586
		slot = "enemy_hit" -- 588
	elseif e.warnT > 0 then -- 588
		slot = "enemy_aim" -- 590
	end -- 590
	local height = e.alive and H or H * 0.24 -- 592
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 593
	if assets:tryPlace( -- 593
		slot, -- 594
		"actor_enemy_" .. tostring(index), -- 594
		cx, -- 594
		by, -- 594
		W, -- 594
		height, -- 594
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 594
	) then -- 594
		if e.alive then -- 594
			self:drawEnemyArchetypeGear( -- 598
				fgDraw, -- 598
				fgGlow, -- 598
				assets, -- 598
				e, -- 598
				index, -- 598
				cx, -- 598
				by, -- 598
				H, -- 598
				f, -- 598
				cam, -- 598
				enemyLayer + 1 -- 598
			) -- 598
			if e.warnT > 0 then -- 598
				self:drawEnemyWarning( -- 600
					fgGlow, -- 600
					e, -- 600
					p, -- 600
					cam, -- 600
					f -- 600
				) -- 600
			end -- 600
		end -- 600
		return -- 603
	end -- 603
	if not e.alive then -- 603
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 607
		fgDraw:drawPolygon( -- 608
			{ -- 608
				Vec2(cx - H * 0.3, by), -- 609
				Vec2(cx + H * 0.28, by), -- 610
				Vec2(cx + H * 0.2, by + H * 0.14), -- 611
				Vec2(cx - H * 0.24, by + H * 0.11) -- 612
			}, -- 612
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 613
		) -- 613
		if flash > 0 then -- 613
			fillRadialGlow( -- 615
				fgGlow, -- 615
				cx, -- 615
				by + 12, -- 615
				34 * flash, -- 615
				18 * flash, -- 615
				toColor(PALETTE.crimson, 180 * flash), -- 615
				Color(255, 48, 82, 0), -- 615
				12 -- 615
			) -- 615
		end -- 615
		return -- 617
	end -- 617
	local sw = H * 0.112 -- 620
	fgDraw:drawEllipse( -- 621
		Vec2(cx, by + 1), -- 621
		sw * 1.9, -- 621
		4, -- 621
		Color(4, 6, 10, 165) -- 621
	) -- 621
	local hipY = by + H * 0.44 -- 624
	local kneeY = by + H * 0.23 -- 625
	local shY = by + H * 0.79 -- 626
	fgDraw:drawSegment( -- 627
		Vec2(cx - 5, hipY), -- 627
		Vec2(cx - 7, kneeY), -- 627
		H * 0.044, -- 627
		Color(20, 16, 26, 255) -- 627
	) -- 627
	fgDraw:drawSegment( -- 628
		Vec2(cx - 7, kneeY), -- 628
		Vec2(cx - 8, by + 2), -- 628
		H * 0.038, -- 628
		Color(20, 16, 26, 255) -- 628
	) -- 628
	fgDraw:drawSegment( -- 629
		Vec2(cx + 5, hipY), -- 629
		Vec2(cx + 7, kneeY), -- 629
		H * 0.046, -- 629
		Color(28, 22, 36, 255) -- 629
	) -- 629
	fgDraw:drawSegment( -- 630
		Vec2(cx + 7, kneeY), -- 630
		Vec2(cx + 8, by + 2), -- 630
		H * 0.04, -- 630
		Color(28, 22, 36, 255) -- 630
	) -- 630
	fgDraw:drawPolygon( -- 632
		{ -- 632
			Vec2(cx - sw * 0.68, hipY), -- 633
			Vec2(cx + sw * 0.68, hipY), -- 634
			Vec2(cx + sw * 1.12, shY), -- 635
			Vec2(cx - sw * 1.12, shY) -- 636
		}, -- 636
		Color(111, 68, 55, 255), -- 637
		1.3, -- 637
		Color(143, 101, 66, 220) -- 637
	) -- 637
	fgDraw:drawPolygon( -- 638
		{ -- 638
			Vec2(cx - sw * 1.26, shY - 6), -- 639
			Vec2(cx + sw * 1.26, shY - 6), -- 640
			Vec2(cx + sw * 0.96, shY + 5), -- 641
			Vec2(cx - sw * 0.96, shY + 5) -- 642
		}, -- 642
		Color(98, 82, 62, 255) -- 643
	) -- 643
	local headR = H * 0.086 -- 645
	local headY = shY + headR * 1.32 -- 646
	fgDraw:drawCircle( -- 647
		Vec2(cx, headY), -- 647
		headR * 0.82, -- 647
		Color(187, 142, 103, 255) -- 647
	) -- 647
	fgDraw:drawPolygon( -- 648
		{ -- 648
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 649
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 650
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 651
		}, -- 651
		Color(136, 105, 65, 255), -- 652
		1.1, -- 652
		Color(177, 145, 91, 220) -- 652
	) -- 652
	local gunX = cx + f * H * 0.34 -- 654
	local gunY = by + H * 0.69 -- 655
	fgDraw:drawSegment( -- 656
		Vec2(cx - f * 6, gunY - 2), -- 656
		Vec2(gunX, gunY), -- 656
		2.8, -- 656
		Color(118, 87, 61, 255) -- 656
	) -- 656
	self:drawEnemyArchetypeGear( -- 657
		fgDraw, -- 657
		fgGlow, -- 657
		assets, -- 657
		e, -- 657
		index, -- 657
		cx, -- 657
		by, -- 657
		H, -- 657
		f, -- 657
		cam, -- 657
		enemyLayer + 1 -- 657
	) -- 657
	if e.warnT > 0 then -- 657
		self:drawEnemyWarning( -- 659
			fgGlow, -- 659
			e, -- 659
			p, -- 659
			cam, -- 659
			f -- 659
		) -- 659
	end -- 659
end -- 551
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 664
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 664
		local shX = cx + f * cam:len(13) -- 678
		local cracked = (e.shieldHp or 2) <= 1 -- 679
		if not assets:tryPlace( -- 679
			"fe_gear_rattan_shield", -- 680
			"enemy_shield_" .. tostring(index), -- 680
			shX, -- 680
			by + H * 0.44, -- 680
			cam:len(22), -- 680
			H * 0.64, -- 680
			{ -- 680
				facing = f, -- 681
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 682
				layer = layer -- 683
			} -- 683
		) then -- 683
			local shW = math.max( -- 685
				5, -- 685
				cam:len(8) -- 685
			) -- 685
			fgDraw:drawRect( -- 686
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 686
				Color(96, 66, 42, 250), -- 686
				1.3, -- 686
				Color(168, 174, 180, 230) -- 686
			) -- 686
		end -- 686
		if cracked then -- 686
			fgDraw:drawSegment( -- 689
				Vec2( -- 689
					shX - cam:len(4), -- 689
					by + H * 0.3 -- 689
				), -- 689
				Vec2( -- 689
					shX + cam:len(4), -- 689
					by + H * 0.56 -- 689
				), -- 689
				1.4, -- 689
				Color(24, 18, 16, 235) -- 689
			) -- 689
		end -- 689
	elseif e.kind == "breaker" then -- 689
		local swing = (e.swingT or 0) > 0 -- 692
		local handleX0 = cx - f * cam:len(4) -- 693
		local handleY0 = by + H * 0.44 -- 694
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 695
		local tipY = by + H * (swing and 0.46 or 0.78) -- 696
		fgDraw:drawSegment( -- 697
			Vec2(handleX0, handleY0), -- 697
			Vec2(tipX, tipY), -- 697
			math.max( -- 697
				2.2, -- 697
				cam:len(3) -- 697
			), -- 697
			Color(98, 66, 44, 255) -- 697
		) -- 697
		fgDraw:drawPolygon( -- 698
			{ -- 698
				Vec2( -- 699
					tipX - f * cam:len(3), -- 699
					tipY - cam:len(4) -- 699
				), -- 699
				Vec2( -- 700
					tipX + f * cam:len(9), -- 700
					tipY - cam:len(1) -- 700
				), -- 700
				Vec2( -- 701
					tipX + f * cam:len(7), -- 701
					tipY + cam:len(9) -- 701
				), -- 701
				Vec2( -- 702
					tipX - f * cam:len(2), -- 702
					tipY + cam:len(6) -- 702
				) -- 702
			}, -- 702
			Color(148, 154, 162, 250), -- 703
			1, -- 703
			Color(224, 228, 232, 220) -- 703
		) -- 703
		if swing then -- 703
			fgGlow:drawArc( -- 705
				Vec2( -- 705
					cx + f * cam:len(10), -- 705
					by + H * 0.56 -- 705
				), -- 705
				cam:len(18), -- 705
				f > 0 and -40 or 140, -- 705
				f > 0 and 50 or 230, -- 705
				1.8, -- 705
				toColor(PALETTE.rouge, 195) -- 705
			) -- 705
		end -- 705
	elseif e.kind == "leader" then -- 705
		local topY = by + H * 1.02 -- 709
		fgDraw:drawSegment( -- 710
			Vec2(cx, topY), -- 710
			Vec2( -- 710
				cx - f * cam:len(10), -- 710
				topY + cam:len(9) -- 710
			), -- 710
			2.2, -- 710
			toColor(PALETTE.rouge, 240) -- 710
		) -- 710
		fgDraw:drawDot( -- 711
			Vec2( -- 711
				cx - f * cam:len(10), -- 711
				topY + cam:len(9) -- 711
			), -- 711
			2.6, -- 711
			toColor(PALETTE.crimsonCore, 235) -- 711
		) -- 711
	end -- 711
end -- 664
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 716
	local s = p.room.scavenger -- 723
	if s == nil then -- 723
		return -- 725
	end -- 725
	local cx = cam:sx(p.scavX) -- 727
	local by = cam:sy(s.y) -- 728
	local H = cam:len(s.h) -- 729
	local W = cam:len(26) -- 730
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 731
	local alert = p.scavChase or p.scavSee > 0 -- 734
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 735
	local eyeY = by + H * 0.8 -- 736
	local coneLen = cam:len(alert and 155 or 115) -- 737
	fgGlow:drawVertices({ -- 738
		{ -- 739
			Vec2(cx + f * 6, eyeY), -- 739
			toColor(coneCol, alert and 78 or 34) -- 739
		}, -- 739
		{ -- 740
			Vec2(cx + f * coneLen, by + H * 1.05), -- 740
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 740
		}, -- 740
		{ -- 741
			Vec2(cx + f * coneLen, by + 4), -- 741
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 741
		} -- 741
	}) -- 741
	local frame = 0 -- 744
	if p.scavState == "turn" then -- 744
		frame = 2 -- 746
	elseif p.scavState == "chase" then -- 746
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 748
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 748
		frame = math.floor(self.animTime * 8) % 2 -- 750
	end -- 750
	if assets:tryPlace( -- 750
		"scavenger", -- 752
		"actor_scav", -- 752
		cx, -- 752
		by, -- 752
		W, -- 752
		H, -- 752
		{facing = f, frame = frame, layer = 3} -- 752
	) then -- 752
		return -- 753
	end -- 753
	fgDraw:drawEllipse( -- 756
		Vec2(cx, by + 1), -- 756
		W * 0.62, -- 756
		4, -- 756
		Color(4, 6, 10, 155) -- 756
	) -- 756
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 757
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 758
	fgDraw:drawSegment( -- 760
		Vec2(cx - 4, by + H * 0.4), -- 760
		Vec2(cx - stride, by + 2), -- 760
		W * 0.16, -- 760
		Color(32, 30, 28, 255) -- 760
	) -- 760
	fgDraw:drawSegment( -- 761
		Vec2(cx + 4, by + H * 0.4), -- 761
		Vec2(cx + stride, by + 2), -- 761
		W * 0.16, -- 761
		Color(44, 40, 36, 255) -- 761
	) -- 761
	fgDraw:drawPolygon( -- 763
		{ -- 763
			Vec2(cx - W * 0.45, by + H * 0.25), -- 764
			Vec2(cx + W * 0.42, by + H * 0.25), -- 765
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 766
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 767
		}, -- 767
		Color(56, 52, 46, 255), -- 768
		1.2, -- 768
		Color(128, 118, 100, 180) -- 768
	) -- 768
	local headX = cx + f * 5 -- 770
	local headY = by + H * 0.88 -- 771
	fgDraw:drawCircle( -- 772
		Vec2(headX, headY), -- 772
		W * 0.3, -- 772
		Color(42, 38, 34, 255) -- 772
	) -- 772
	fgGlow:drawDot( -- 773
		Vec2(headX + f * 6, headY), -- 773
		3, -- 773
		toColor(coneCol, 245) -- 773
	) -- 773
	local indY = by + H + 18 -- 776
	if p.scavChase then -- 776
		drawDiamond( -- 778
			fgGlow, -- 778
			cx, -- 778
			indY, -- 778
			9, -- 778
			12, -- 778
			toColor(PALETTE.crimson, 240), -- 778
			1.5, -- 778
			toColor(PALETTE.crimsonCore) -- 778
		) -- 778
	elseif p.scavSee > 0 then -- 778
		local frac = math.min(1, p.scavSee / 24) -- 780
		fgGlow:drawArc( -- 781
			Vec2(cx, indY), -- 781
			11, -- 781
			90, -- 781
			90 - 360 * frac, -- 781
			2.4, -- 781
			toColor(PALETTE.crimson, 235) -- 781
		) -- 781
		fgGlow:drawDot( -- 782
			Vec2(cx, indY), -- 782
			3, -- 782
			toColor(PALETTE.amber) -- 782
		) -- 782
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 782
		drawDiamond( -- 784
			fgGlow, -- 784
			cx, -- 784
			indY, -- 784
			6, -- 784
			8, -- 784
			toColor(PALETTE.amber, 220) -- 784
		) -- 784
	end -- 784
end -- 716
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 789
	local cx = cam:sx(p.dogX) -- 796
	local by = cam:sy(0) -- 797
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 798
	local W = cam:len(42) -- 799
	local H = cam:len(34) -- 800
	local frame = 0 -- 802
	if p.dogState == "ear" then -- 802
		frame = 1 -- 804
	elseif p.dogState == "sniff" then -- 804
		frame = 3 -- 806
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 806
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 808
	end -- 808
	if assets:tryPlace( -- 808
		"dog", -- 810
		"actor_dog", -- 810
		cx, -- 810
		by, -- 810
		W, -- 810
		H, -- 810
		{facing = f, frame = frame, layer = 3} -- 810
	) then -- 810
		return -- 811
	end -- 811
	fgDraw:drawEllipse( -- 814
		Vec2(cx, by + 1), -- 814
		W * 0.56, -- 814
		3.5, -- 814
		Color(4, 8, 10, 155) -- 814
	) -- 814
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 815
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 816
	fgDraw:drawSegment( -- 819
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 819
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 819
		2.8, -- 819
		Color(26, 30, 34, 255) -- 819
	) -- 819
	fgDraw:drawSegment( -- 820
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 820
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 820
		2.8, -- 820
		Color(36, 40, 44, 255) -- 820
	) -- 820
	fgDraw:drawPolygon( -- 822
		{ -- 822
			Vec2(cx - W * 0.42, by + H * 0.36), -- 823
			Vec2(cx + W * 0.38, by + H * 0.42), -- 824
			Vec2(cx + W * 0.34, by + H * 0.78), -- 825
			Vec2(cx - W * 0.38, by + H * 0.72) -- 826
		}, -- 826
		Color(38, 42, 48, 255), -- 827
		1.2, -- 827
		Color(102, 118, 126, 175) -- 827
	) -- 827
	local hx = cx + f * W * 0.42 -- 828
	local hy = by + H * 0.84 -- 829
	fgDraw:drawPolygon( -- 830
		{ -- 830
			Vec2(hx - f * 8, hy - 6), -- 831
			Vec2(hx + f * 12, hy - 2), -- 832
			Vec2(hx + f * 4, hy + 8), -- 833
			Vec2(hx - f * 6, hy + 14) -- 834
		}, -- 834
		Color(44, 48, 54, 255) -- 835
	) -- 835
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 837
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 838
	fgGlow:drawDot( -- 839
		Vec2(hx + f * 4, hy + 2), -- 839
		2.8, -- 839
		toColor(eyeCol, 250) -- 839
	) -- 839
	fillRadialGlow( -- 840
		fgGlow, -- 840
		hx + f * 4, -- 840
		hy + 2, -- 840
		16, -- 840
		16, -- 840
		toColor(eyeCol, alert and 135 or 70), -- 840
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 840
		12 -- 840
	) -- 840
	if alert then -- 840
		local r = 12 + self.animTime * 42 % 24 -- 843
		fgGlow:drawArc( -- 844
			Vec2(hx, hy + 12), -- 844
			r, -- 844
			35, -- 844
			145, -- 844
			1.8, -- 844
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 844
		) -- 844
	end -- 844
end -- 789
return ____exports -- 789