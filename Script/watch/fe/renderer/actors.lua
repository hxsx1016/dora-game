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
		local targetLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 569
		fgDraw:drawEllipse( -- 570
			Vec2(cx, by + 1), -- 570
			W * 0.56, -- 570
			3.6, -- 570
			Color(12, 11, 13, 140) -- 570
		) -- 570
		local angle = not e.alive and f * 62 or (e.hitT > 0 and f * 18 or 0) -- 571
		local tint = (e.hitT > 0 or not e.alive) and Color(238, 196, 174, 255) or Color(255, 255, 255, 255) -- 572
		if assets:tryPlacePath( -- 572
			"assets/art/props_ming.clip|target_dummy", -- 573
			"actor_target_" .. tostring(index), -- 573
			cx, -- 573
			by, -- 573
			H * 0.82, -- 573
			H * 0.96, -- 573
			{ -- 573
				anchorX = 0.5, -- 574
				anchorY = 0, -- 575
				preserveAspect = true, -- 576
				angle = angle, -- 577
				color = tint, -- 578
				opacity = e.alive and 1 or 0.76, -- 579
				layer = targetLayer -- 580
			} -- 580
		) then -- 580
			return -- 582
		end -- 582
		local lean = not e.alive and f * cam:len(16) or (e.hitT > 0 and f * cam:len(8) or 0) -- 584
		local postTopY = by + H * (e.alive and 0.78 or 0.42) -- 585
		fgDraw:drawSegment( -- 586
			Vec2( -- 586
				cx - cam:len(9), -- 586
				by -- 586
			), -- 586
			Vec2(cx + lean * 0.4, postTopY), -- 586
			math.max( -- 586
				2, -- 586
				cam:len(3.2) -- 586
			), -- 586
			Color(92, 64, 42, 255) -- 586
		) -- 586
		fgDraw:drawSegment( -- 587
			Vec2( -- 587
				cx + cam:len(9), -- 587
				by -- 587
			), -- 587
			Vec2(cx + lean * 0.4, postTopY), -- 587
			math.max( -- 587
				2, -- 587
				cam:len(3.2) -- 587
			), -- 587
			Color(76, 52, 34, 255) -- 587
		) -- 587
		local discX = cx + lean -- 588
		local discY = by + H * (e.alive and 0.56 or 0.3) -- 589
		local discR = math.max( -- 590
			7, -- 590
			cam:len(13) -- 590
		) -- 590
		local hitTint = e.hitT > 0 or not e.alive -- 591
		fgDraw:drawCircle( -- 592
			Vec2(discX, discY), -- 592
			discR, -- 592
			hitTint and Color(214, 152, 116, 245) or Color(196, 174, 134, 250) -- 592
		) -- 592
		fgDraw:drawRing( -- 593
			Vec2(discX, discY), -- 593
			discR * 0.62, -- 593
			discR * 0.76, -- 593
			Color(0, 0, 0, 0), -- 593
			1.4, -- 593
			Color(62, 46, 34, 230) -- 593
		) -- 593
		fgDraw:drawCircle( -- 594
			Vec2(discX, discY), -- 594
			discR * 0.3, -- 594
			toColor(PALETTE.rouge, hitTint and 255 or 220) -- 594
		) -- 594
		return -- 595
	end -- 595
	local enemyLayer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 598
	if e.alive and e.hitT <= 0 then -- 598
		local extraClip = "" -- 601
		local extraAnchorX = 0.5 -- 602
		local extraHeight = H * 0.96 -- 603
		local extraTint = Color(255, 255, 255, 255) -- 604
		if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 604
			extraClip = e.warnT > 0 and "enemy_shield_aim" or "enemy_shield_idle" -- 606
			extraAnchorX = e.warnT > 0 and 0.45 or 0.5 -- 607
			extraHeight = H * 0.94 -- 608
			if (e.shieldHp or 2) <= 1 then -- 608
				extraTint = Color(234, 198, 178, 255) -- 610
			end -- 610
		elseif e.kind == "breaker" then -- 610
			local swing = (e.swingT or 0) > 0 or e.warnT > 0 -- 613
			extraClip = swing and "enemy_breaker_aim" or "enemy_breaker_idle" -- 614
			extraAnchorX = swing and 0.52 or 0.38 -- 615
			extraHeight = H * (swing and 0.98 or 0.94) -- 616
		elseif e.kind == "leader" then -- 616
			extraClip = e.warnT > 0 and "enemy_leader_aim" or "enemy_leader_idle" -- 618
			extraAnchorX = e.warnT > 0 and 0.38 or 0.44 -- 619
			extraHeight = H * 1 -- 620
		end -- 620
		if extraClip ~= "" and assets:tryPlacePath( -- 620
			"assets/art/actors_extra.clip|" .. extraClip, -- 623
			"actor_enemy_" .. tostring(index), -- 624
			cx, -- 625
			by, -- 626
			W * 1.8, -- 627
			extraHeight, -- 628
			{ -- 629
				anchorX = extraAnchorX, -- 630
				anchorY = 0, -- 631
				preserveAspect = true, -- 632
				facing = f, -- 633
				color = extraTint, -- 634
				layer = enemyLayer -- 635
			} -- 635
		) then -- 635
			fgDraw:drawEllipse( -- 638
				Vec2(cx, by + 1), -- 638
				W * 0.58, -- 638
				3.8, -- 638
				Color(12, 11, 13, 145) -- 638
			) -- 638
			if e.kind == "breaker" and (e.swingT or 0) > 0 then -- 638
				fgGlow:drawArc( -- 640
					Vec2( -- 640
						cx + f * cam:len(10), -- 640
						by + H * 0.56 -- 640
					), -- 640
					cam:len(18), -- 640
					f > 0 and -40 or 140, -- 640
					f > 0 and 50 or 230, -- 640
					1.8, -- 640
					toColor(PALETTE.rouge, 195) -- 640
				) -- 640
			end -- 640
			if e.warnT > 0 then -- 640
				self:drawEnemyWarning( -- 643
					fgGlow, -- 643
					e, -- 643
					p, -- 643
					cam, -- 643
					f -- 643
				) -- 643
			end -- 643
			return -- 645
		end -- 645
	end -- 645
	local slot = "enemy_idle" -- 649
	if not e.alive then -- 649
		slot = "enemy_down" -- 651
	elseif e.hitT > 0 then -- 651
		slot = "enemy_hit" -- 653
	elseif e.warnT > 0 then -- 653
		slot = "enemy_aim" -- 655
	end -- 655
	local height = e.alive and H or H * 0.24 -- 657
	if assets:tryPlace( -- 657
		slot, -- 658
		"actor_enemy_" .. tostring(index), -- 658
		cx, -- 658
		by, -- 658
		W, -- 658
		height, -- 658
		{facing = f, opacity = e.alive and 1 or 0.78, layer = enemyLayer} -- 658
	) then -- 658
		if e.alive then -- 658
			self:drawEnemyArchetypeGear( -- 662
				fgDraw, -- 662
				fgGlow, -- 662
				assets, -- 662
				e, -- 662
				index, -- 662
				cx, -- 662
				by, -- 662
				H, -- 662
				f, -- 662
				cam, -- 662
				enemyLayer + 1 -- 662
			) -- 662
			if e.warnT > 0 then -- 662
				self:drawEnemyWarning( -- 664
					fgGlow, -- 664
					e, -- 664
					p, -- 664
					cam, -- 664
					f -- 664
				) -- 664
			end -- 664
		end -- 664
		return -- 667
	end -- 667
	if not e.alive then -- 667
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 671
		fgDraw:drawPolygon( -- 672
			{ -- 672
				Vec2(cx - H * 0.3, by), -- 673
				Vec2(cx + H * 0.28, by), -- 674
				Vec2(cx + H * 0.2, by + H * 0.14), -- 675
				Vec2(cx - H * 0.24, by + H * 0.11) -- 676
			}, -- 676
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 677
		) -- 677
		if flash > 0 then -- 677
			fillRadialGlow( -- 679
				fgGlow, -- 679
				cx, -- 679
				by + 12, -- 679
				34 * flash, -- 679
				18 * flash, -- 679
				toColor(PALETTE.crimson, 180 * flash), -- 679
				Color(255, 48, 82, 0), -- 679
				12 -- 679
			) -- 679
		end -- 679
		return -- 681
	end -- 681
	local sw = H * 0.112 -- 684
	fgDraw:drawEllipse( -- 685
		Vec2(cx, by + 1), -- 685
		sw * 1.9, -- 685
		4, -- 685
		Color(4, 6, 10, 165) -- 685
	) -- 685
	local hipY = by + H * 0.44 -- 688
	local kneeY = by + H * 0.23 -- 689
	local shY = by + H * 0.79 -- 690
	fgDraw:drawSegment( -- 691
		Vec2(cx - 5, hipY), -- 691
		Vec2(cx - 7, kneeY), -- 691
		H * 0.044, -- 691
		Color(20, 16, 26, 255) -- 691
	) -- 691
	fgDraw:drawSegment( -- 692
		Vec2(cx - 7, kneeY), -- 692
		Vec2(cx - 8, by + 2), -- 692
		H * 0.038, -- 692
		Color(20, 16, 26, 255) -- 692
	) -- 692
	fgDraw:drawSegment( -- 693
		Vec2(cx + 5, hipY), -- 693
		Vec2(cx + 7, kneeY), -- 693
		H * 0.046, -- 693
		Color(28, 22, 36, 255) -- 693
	) -- 693
	fgDraw:drawSegment( -- 694
		Vec2(cx + 7, kneeY), -- 694
		Vec2(cx + 8, by + 2), -- 694
		H * 0.04, -- 694
		Color(28, 22, 36, 255) -- 694
	) -- 694
	fgDraw:drawPolygon( -- 696
		{ -- 696
			Vec2(cx - sw * 0.68, hipY), -- 697
			Vec2(cx + sw * 0.68, hipY), -- 698
			Vec2(cx + sw * 1.12, shY), -- 699
			Vec2(cx - sw * 1.12, shY) -- 700
		}, -- 700
		Color(111, 68, 55, 255), -- 701
		1.3, -- 701
		Color(143, 101, 66, 220) -- 701
	) -- 701
	fgDraw:drawPolygon( -- 702
		{ -- 702
			Vec2(cx - sw * 1.26, shY - 6), -- 703
			Vec2(cx + sw * 1.26, shY - 6), -- 704
			Vec2(cx + sw * 0.96, shY + 5), -- 705
			Vec2(cx - sw * 0.96, shY + 5) -- 706
		}, -- 706
		Color(98, 82, 62, 255) -- 707
	) -- 707
	local headR = H * 0.086 -- 709
	local headY = shY + headR * 1.32 -- 710
	fgDraw:drawCircle( -- 711
		Vec2(cx, headY), -- 711
		headR * 0.82, -- 711
		Color(187, 142, 103, 255) -- 711
	) -- 711
	fgDraw:drawPolygon( -- 712
		{ -- 712
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 713
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 714
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 715
		}, -- 715
		Color(136, 105, 65, 255), -- 716
		1.1, -- 716
		Color(177, 145, 91, 220) -- 716
	) -- 716
	local gunX = cx + f * H * 0.34 -- 718
	local gunY = by + H * 0.69 -- 719
	fgDraw:drawSegment( -- 720
		Vec2(cx - f * 6, gunY - 2), -- 720
		Vec2(gunX, gunY), -- 720
		2.8, -- 720
		Color(118, 87, 61, 255) -- 720
	) -- 720
	self:drawEnemyArchetypeGear( -- 721
		fgDraw, -- 721
		fgGlow, -- 721
		assets, -- 721
		e, -- 721
		index, -- 721
		cx, -- 721
		by, -- 721
		H, -- 721
		f, -- 721
		cam, -- 721
		enemyLayer + 1 -- 721
	) -- 721
	if e.warnT > 0 then -- 721
		self:drawEnemyWarning( -- 723
			fgGlow, -- 723
			e, -- 723
			p, -- 723
			cam, -- 723
			f -- 723
		) -- 723
	end -- 723
end -- 551
function ActorsRenderer.prototype.drawEnemyArchetypeGear(self, fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, layer) -- 728
	if e.kind == "shield" and (e.shieldHp or 0) > 0 then -- 728
		local shX = cx + f * cam:len(13) -- 742
		local cracked = (e.shieldHp or 2) <= 1 -- 743
		if not assets:tryPlace( -- 743
			"fe_gear_rattan_shield", -- 744
			"enemy_shield_" .. tostring(index), -- 744
			shX, -- 744
			by + H * 0.44, -- 744
			cam:len(22), -- 744
			H * 0.64, -- 744
			{ -- 744
				facing = f, -- 745
				color = cracked and Color(224, 178, 146, 255) or Color(255, 255, 255, 255), -- 746
				layer = layer -- 747
			} -- 747
		) then -- 747
			local shW = math.max( -- 749
				5, -- 749
				cam:len(8) -- 749
			) -- 749
			fgDraw:drawRect( -- 750
				Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), -- 750
				Color(96, 66, 42, 250), -- 750
				1.3, -- 750
				Color(168, 174, 180, 230) -- 750
			) -- 750
		end -- 750
		if cracked then -- 750
			fgDraw:drawSegment( -- 753
				Vec2( -- 753
					shX - cam:len(4), -- 753
					by + H * 0.3 -- 753
				), -- 753
				Vec2( -- 753
					shX + cam:len(4), -- 753
					by + H * 0.56 -- 753
				), -- 753
				1.4, -- 753
				Color(24, 18, 16, 235) -- 753
			) -- 753
		end -- 753
	elseif e.kind == "breaker" then -- 753
		local swing = (e.swingT or 0) > 0 -- 756
		local handleX0 = cx - f * cam:len(4) -- 757
		local handleY0 = by + H * 0.44 -- 758
		local tipX = cx + f * cam:len(swing and 26 or 19) -- 759
		local tipY = by + H * (swing and 0.46 or 0.78) -- 760
		fgDraw:drawSegment( -- 761
			Vec2(handleX0, handleY0), -- 761
			Vec2(tipX, tipY), -- 761
			math.max( -- 761
				2.2, -- 761
				cam:len(3) -- 761
			), -- 761
			Color(98, 66, 44, 255) -- 761
		) -- 761
		fgDraw:drawPolygon( -- 762
			{ -- 762
				Vec2( -- 763
					tipX - f * cam:len(3), -- 763
					tipY - cam:len(4) -- 763
				), -- 763
				Vec2( -- 764
					tipX + f * cam:len(9), -- 764
					tipY - cam:len(1) -- 764
				), -- 764
				Vec2( -- 765
					tipX + f * cam:len(7), -- 765
					tipY + cam:len(9) -- 765
				), -- 765
				Vec2( -- 766
					tipX - f * cam:len(2), -- 766
					tipY + cam:len(6) -- 766
				) -- 766
			}, -- 766
			Color(148, 154, 162, 250), -- 767
			1, -- 767
			Color(224, 228, 232, 220) -- 767
		) -- 767
		if swing then -- 767
			fgGlow:drawArc( -- 769
				Vec2( -- 769
					cx + f * cam:len(10), -- 769
					by + H * 0.56 -- 769
				), -- 769
				cam:len(18), -- 769
				f > 0 and -40 or 140, -- 769
				f > 0 and 50 or 230, -- 769
				1.8, -- 769
				toColor(PALETTE.rouge, 195) -- 769
			) -- 769
		end -- 769
	elseif e.kind == "leader" then -- 769
		local topY = by + H * 1.02 -- 773
		fgDraw:drawSegment( -- 774
			Vec2(cx, topY), -- 774
			Vec2( -- 774
				cx - f * cam:len(10), -- 774
				topY + cam:len(9) -- 774
			), -- 774
			2.2, -- 774
			toColor(PALETTE.rouge, 240) -- 774
		) -- 774
		fgDraw:drawDot( -- 775
			Vec2( -- 775
				cx - f * cam:len(10), -- 775
				topY + cam:len(9) -- 775
			), -- 775
			2.6, -- 775
			toColor(PALETTE.crimsonCore, 235) -- 775
		) -- 775
	end -- 775
end -- 728
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 780
	local s = p.room.scavenger -- 787
	if s == nil then -- 787
		return -- 789
	end -- 789
	local cx = cam:sx(p.scavX) -- 791
	local by = cam:sy(s.y) -- 792
	local H = cam:len(s.h) -- 793
	local W = cam:len(26) -- 794
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 795
	local alert = p.scavChase or p.scavSee > 0 -- 798
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 799
	local eyeY = by + H * 0.8 -- 800
	local coneLen = cam:len(alert and 155 or 115) -- 801
	fgGlow:drawVertices({ -- 802
		{ -- 803
			Vec2(cx + f * 6, eyeY), -- 803
			toColor(coneCol, alert and 78 or 34) -- 803
		}, -- 803
		{ -- 804
			Vec2(cx + f * coneLen, by + H * 1.05), -- 804
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 804
		}, -- 804
		{ -- 805
			Vec2(cx + f * coneLen, by + 4), -- 805
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 805
		} -- 805
	}) -- 805
	local frame = 0 -- 808
	if p.scavState == "turn" then -- 808
		frame = 2 -- 810
	elseif p.scavState == "chase" then -- 810
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 812
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 812
		frame = math.floor(self.animTime * 8) % 2 -- 814
	end -- 814
	if assets:tryPlace( -- 814
		"scavenger", -- 816
		"actor_scav", -- 816
		cx, -- 816
		by, -- 816
		W, -- 816
		H, -- 816
		{facing = f, frame = frame, layer = 3} -- 816
	) then -- 816
		return -- 817
	end -- 817
	fgDraw:drawEllipse( -- 820
		Vec2(cx, by + 1), -- 820
		W * 0.62, -- 820
		4, -- 820
		Color(4, 6, 10, 155) -- 820
	) -- 820
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 821
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 822
	fgDraw:drawSegment( -- 824
		Vec2(cx - 4, by + H * 0.4), -- 824
		Vec2(cx - stride, by + 2), -- 824
		W * 0.16, -- 824
		Color(32, 30, 28, 255) -- 824
	) -- 824
	fgDraw:drawSegment( -- 825
		Vec2(cx + 4, by + H * 0.4), -- 825
		Vec2(cx + stride, by + 2), -- 825
		W * 0.16, -- 825
		Color(44, 40, 36, 255) -- 825
	) -- 825
	fgDraw:drawPolygon( -- 827
		{ -- 827
			Vec2(cx - W * 0.45, by + H * 0.25), -- 828
			Vec2(cx + W * 0.42, by + H * 0.25), -- 829
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 830
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 831
		}, -- 831
		Color(56, 52, 46, 255), -- 832
		1.2, -- 832
		Color(128, 118, 100, 180) -- 832
	) -- 832
	local headX = cx + f * 5 -- 834
	local headY = by + H * 0.88 -- 835
	fgDraw:drawCircle( -- 836
		Vec2(headX, headY), -- 836
		W * 0.3, -- 836
		Color(42, 38, 34, 255) -- 836
	) -- 836
	fgGlow:drawDot( -- 837
		Vec2(headX + f * 6, headY), -- 837
		3, -- 837
		toColor(coneCol, 245) -- 837
	) -- 837
	local indY = by + H + 18 -- 840
	if p.scavChase then -- 840
		drawDiamond( -- 842
			fgGlow, -- 842
			cx, -- 842
			indY, -- 842
			9, -- 842
			12, -- 842
			toColor(PALETTE.crimson, 240), -- 842
			1.5, -- 842
			toColor(PALETTE.crimsonCore) -- 842
		) -- 842
	elseif p.scavSee > 0 then -- 842
		local frac = math.min(1, p.scavSee / 24) -- 844
		fgGlow:drawArc( -- 845
			Vec2(cx, indY), -- 845
			11, -- 845
			90, -- 845
			90 - 360 * frac, -- 845
			2.4, -- 845
			toColor(PALETTE.crimson, 235) -- 845
		) -- 845
		fgGlow:drawDot( -- 846
			Vec2(cx, indY), -- 846
			3, -- 846
			toColor(PALETTE.amber) -- 846
		) -- 846
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 846
		drawDiamond( -- 848
			fgGlow, -- 848
			cx, -- 848
			indY, -- 848
			6, -- 848
			8, -- 848
			toColor(PALETTE.amber, 220) -- 848
		) -- 848
	end -- 848
end -- 780
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 853
	local cx = cam:sx(p.dogX) -- 860
	local by = cam:sy(0) -- 861
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 862
	local W = cam:len(42) -- 863
	local H = cam:len(34) -- 864
	local frame = 0 -- 866
	if p.dogState == "ear" then -- 866
		frame = 1 -- 868
	elseif p.dogState == "sniff" then -- 868
		frame = 3 -- 870
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 870
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 872
	end -- 872
	if assets:tryPlace( -- 872
		"dog", -- 874
		"actor_dog", -- 874
		cx, -- 874
		by, -- 874
		W, -- 874
		H, -- 874
		{facing = f, frame = frame, layer = 3} -- 874
	) then -- 874
		return -- 875
	end -- 875
	fgDraw:drawEllipse( -- 878
		Vec2(cx, by + 1), -- 878
		W * 0.56, -- 878
		3.5, -- 878
		Color(4, 8, 10, 155) -- 878
	) -- 878
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 879
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 880
	fgDraw:drawSegment( -- 883
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 883
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 883
		2.8, -- 883
		Color(26, 30, 34, 255) -- 883
	) -- 883
	fgDraw:drawSegment( -- 884
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 884
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 884
		2.8, -- 884
		Color(36, 40, 44, 255) -- 884
	) -- 884
	fgDraw:drawPolygon( -- 886
		{ -- 886
			Vec2(cx - W * 0.42, by + H * 0.36), -- 887
			Vec2(cx + W * 0.38, by + H * 0.42), -- 888
			Vec2(cx + W * 0.34, by + H * 0.78), -- 889
			Vec2(cx - W * 0.38, by + H * 0.72) -- 890
		}, -- 890
		Color(38, 42, 48, 255), -- 891
		1.2, -- 891
		Color(102, 118, 126, 175) -- 891
	) -- 891
	local hx = cx + f * W * 0.42 -- 892
	local hy = by + H * 0.84 -- 893
	fgDraw:drawPolygon( -- 894
		{ -- 894
			Vec2(hx - f * 8, hy - 6), -- 895
			Vec2(hx + f * 12, hy - 2), -- 896
			Vec2(hx + f * 4, hy + 8), -- 897
			Vec2(hx - f * 6, hy + 14) -- 898
		}, -- 898
		Color(44, 48, 54, 255) -- 899
	) -- 899
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 901
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 902
	fgGlow:drawDot( -- 903
		Vec2(hx + f * 4, hy + 2), -- 903
		2.8, -- 903
		toColor(eyeCol, 250) -- 903
	) -- 903
	fillRadialGlow( -- 904
		fgGlow, -- 904
		hx + f * 4, -- 904
		hy + 2, -- 904
		16, -- 904
		16, -- 904
		toColor(eyeCol, alert and 135 or 70), -- 904
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 904
		12 -- 904
	) -- 904
	if alert then -- 904
		local r = 12 + self.animTime * 42 % 24 -- 907
		fgGlow:drawArc( -- 908
			Vec2(hx, hy + 12), -- 908
			r, -- 908
			35, -- 908
			145, -- 908
			1.8, -- 908
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 908
		) -- 908
	end -- 908
end -- 853
return ____exports -- 853