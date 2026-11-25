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
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 146
	local i = 0 -- 147
	do -- 147
		i = 0 -- 148
		while i < #self.ghosts do -- 148
			local g = self.ghosts[i + 1] -- 149
			local k = g.life / g.maxLife -- 150
			local cx = cam:sx(g.x) -- 151
			local by = cam:sy(g.y) -- 152
			local h = cam:len(g.h * 0.68) -- 153
			local w = cam:len(28) -- 154
			local f = g.facing -- 155
			fgGlow:drawPolygon( -- 157
				{ -- 157
					Vec2(cx - f * w * 0.9, by + 4), -- 158
					Vec2(cx + f * w * 0.55, by + 6), -- 159
					Vec2(cx + f * w * 0.85, by + h * 0.72), -- 160
					Vec2(cx - f * w * 0.15, by + h), -- 161
					Vec2(cx - f * w * 0.85, by + h * 0.58) -- 162
				}, -- 162
				toColor(PALETTE.cyan, 115 * k) -- 163
			) -- 163
			fgGlow:drawSegment( -- 165
				Vec2(cx - f * w * 1.15, by + h * 0.62), -- 166
				Vec2(cx + f * w * 0.72, by + h * 0.76), -- 167
				2.2 * k, -- 168
				toColor(PALETTE.cyanCore, 165 * k) -- 169
			) -- 169
			i = i + 1 -- 148
		end -- 148
	end -- 148
end -- 146
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 175
	local cx = cam:sx(a.x) -- 184
	local by = cam:sy(a.y, a.depth) -- 185
	local depthEnabled = p.room.depth ~= nil -- 186
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 187
	local H = cam:len(a.h) -- 188
	local W = cam:len(a.w) -- 189
	local f = a.facing -- 190
	local speed = math.max( -- 191
		math.abs(a.vx), -- 191
		math.abs(a.depthSpeed) -- 191
	) -- 191
	local slot = "soldier_idle" -- 193
	local height = H -- 194
	local frame = 0 -- 195
	local facing = f -- 196
	local step = math.floor(self.animTime * 10) -- 197
	if isControlled and p.ticks < self.hitUntil then -- 197
		slot = "soldier_hit" -- 199
	elseif a.rollT > 0 then -- 199
		slot = "soldier_roll" -- 201
		height = height * 0.59 -- 202
	elseif p.phase == "prologue-give" then -- 202
		slot = "soldier_offer" -- 204
		height = height * 0.75 -- 205
		facing = p.partner.x >= a.x and 1 or -1 -- 206
	elseif isControlled and p.gripping then -- 206
		slot = "soldier_push" -- 208
		frame = self.cartMoving and step or 0 -- 209
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 210
		height = height * 0.91 -- 211
	elseif isControlled and p.escort.state == "calming" then -- 211
		slot = "soldier_knock" -- 213
		local calm = p.escort.calmTick -- 214
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 215
		height = height * 0.76 -- 216
	else -- 216
		local ____temp_3 = p.phase == "gate-send" -- 217
		if ____temp_3 then -- 217
			local ____opt_1 = p.room.story -- 217
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 217
		end -- 217
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 217
			slot = "soldier_hold" -- 219
			height = height * 1.11 -- 220
		elseif isControlled and p.ticks < self.shotUntil then -- 220
			local running = speed > 8 -- 222
			slot = running and "soldier_fire_move" or "soldier_fire" -- 223
			frame = running and step or 0 -- 224
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 225
		elseif a.covered or isControlled and p.coverHug then -- 225
			slot = "soldier_cover" -- 227
			height = height * 0.77 -- 228
		elseif speed > 8 then -- 228
			slot = "soldier_run" -- 230
			frame = step -- 231
		end -- 231
	end -- 231
	if assets:tryPlace( -- 231
		slot, -- 233
		"actor_soldier", -- 233
		cx, -- 233
		by, -- 233
		W, -- 233
		height, -- 233
		{ -- 233
			facing = facing, -- 234
			frame = frame, -- 234
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 234
		} -- 234
	) then -- 234
		fgDraw:drawEllipse( -- 236
			Vec2(cx, shadowY + 1), -- 236
			W * 0.54, -- 236
			4, -- 236
			Color(12, 11, 13, 145) -- 236
		) -- 236
		return -- 237
	end -- 237
	fgDraw:drawEllipse( -- 241
		Vec2(cx, shadowY + 1), -- 241
		H * 0.24, -- 241
		4.5, -- 241
		Color(3, 5, 10, 175) -- 241
	) -- 241
	local walking = speed > 10 and a.onGround -- 243
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 244
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 245
	local calming = not p.childMode and p.escort.state == "calming" -- 246
	local rolling = a.rollT > 0 -- 247
	local crouching = a.covered or calming or rolling -- 248
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 251
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 252
	local sw = H * 0.115 -- 253
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 256
	local kneeY = by + bodyH * 0.23 -- 257
	local stepX = stride * H * 0.15 -- 258
	local legDark = Color(14, 21, 34, 255) -- 259
	local legFront = Color(26, 38, 58, 255) -- 260
	local bkX = cx - f * 4 - stepX * 0.5 -- 262
	local bfX = cx - f * 8 - stepX -- 263
	fgDraw:drawSegment( -- 264
		Vec2(cx - f * 3, hipY), -- 264
		Vec2(bkX, kneeY), -- 264
		H * 0.044, -- 264
		legDark -- 264
	) -- 264
	fgDraw:drawSegment( -- 265
		Vec2(bkX, kneeY), -- 265
		Vec2(bfX, by + 3), -- 265
		H * 0.038, -- 265
		legDark -- 265
	) -- 265
	local fkX = cx + f * 6 + stepX * 0.55 -- 267
	local ffX = cx + f * 7 + stepX -- 268
	fgDraw:drawSegment( -- 269
		Vec2(cx + f * 3, hipY), -- 269
		Vec2(fkX, kneeY), -- 269
		H * 0.048, -- 269
		legFront -- 269
	) -- 269
	fgDraw:drawSegment( -- 270
		Vec2(fkX, kneeY), -- 270
		Vec2(ffX, by + 3), -- 270
		H * 0.042, -- 270
		legFront -- 270
	) -- 270
	fgDraw:drawSegment( -- 272
		Vec2(ffX - f * 2, by + 3), -- 272
		Vec2(ffX + f * 9, by + 3), -- 272
		3.4, -- 272
		Color(42, 60, 86, 255) -- 272
	) -- 272
	local shY = by + bodyH * 0.8 + bob -- 275
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 276
	fgDraw:drawPolygon( -- 277
		{ -- 277
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 278
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 279
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 280
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 281
		}, -- 281
		Color(16, 26, 42, 248), -- 282
		1.2, -- 282
		Color(64, 118, 164, 195) -- 282
	) -- 282
	fgDraw:drawPolygon( -- 285
		{ -- 285
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 286
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 287
			Vec2(cx + sw * 1.05 + lean, shY), -- 288
			Vec2(cx - sw * 0.98 + lean, shY) -- 289
		}, -- 289
		Color(24, 38, 60, 255), -- 290
		1.3, -- 290
		toColor(PALETTE.rimSilver, 190) -- 290
	) -- 290
	fgDraw:drawSegment( -- 292
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 293
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 294
		2.4, -- 295
		Color(173, 155, 125, 225) -- 296
	) -- 296
	fgDraw:drawPolygon( -- 298
		{ -- 298
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 299
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 300
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 301
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 302
		}, -- 302
		Color(99, 105, 103, 248) -- 303
	) -- 303
	local headR = H * 0.088 -- 306
	local headX = cx + lean + f * 3 -- 307
	local headY = shY + headR * 1.35 -- 308
	fgDraw:drawCircle( -- 309
		Vec2(headX, headY - headR * 0.12), -- 309
		headR * 0.86, -- 309
		Color(181, 139, 106, 255) -- 309
	) -- 309
	fgDraw:drawEllipse( -- 310
		Vec2(headX, headY + headR * 0.5), -- 310
		headR * 1.12, -- 310
		headR * 0.72, -- 310
		Color(66, 73, 76, 255) -- 310
	) -- 310
	fgDraw:drawSegment( -- 311
		Vec2(headX - headR, headY + 1), -- 311
		Vec2(headX + headR, headY + 1), -- 311
		1.6, -- 312
		Color(97, 103, 101, 255) -- 312
	) -- 312
	fgDraw:drawSegment( -- 313
		Vec2(headX, headY + headR), -- 313
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 313
		1.6, -- 314
		Color(177, 78, 51, 255) -- 314
	) -- 314
	if isControlled and not calming and not rolling and not p.gripping then -- 314
		local gunPivotX = cx + lean + f * sw * 0.35 -- 318
		local gunPivotY = shY - bodyH * 0.1 -- 319
		local aimDx = f -- 320
		local aimDy = 0 -- 321
		if p.aimX > 0 or p.aimY > 0 then -- 321
			aimDx = p.aimX - gunPivotX -- 323
			aimDy = p.aimY - gunPivotY -- 324
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 325
			if dLen > 4 then -- 325
				aimDx = aimDx / dLen -- 327
				aimDy = aimDy / dLen -- 328
			end -- 328
		end -- 328
		local barrelLen = H * 0.34 -- 331
		local tipX = gunPivotX + aimDx * barrelLen -- 332
		local tipY = gunPivotY + aimDy * barrelLen -- 333
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 334
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 335
		fgDraw:drawSegment( -- 337
			Vec2(cx + lean, shY - 5), -- 337
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 337
			3.6, -- 337
			Color(26, 40, 62, 255) -- 337
		) -- 337
		fgDraw:drawSegment( -- 338
			Vec2(stockX, stockY), -- 338
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 338
			3.8, -- 338
			Color(105, 71, 50, 255) -- 338
		) -- 338
		fgDraw:drawSegment( -- 339
			Vec2(gunPivotX, gunPivotY), -- 339
			Vec2(tipX, tipY), -- 339
			1.8, -- 339
			Color(145, 140, 128, 245) -- 339
		) -- 339
	elseif calming then -- 339
		fgDraw:drawSegment( -- 341
			Vec2(cx + lean, shY - 6), -- 341
			Vec2(cx + f * sw * 2.1, shY - 14), -- 341
			3, -- 341
			Color(196, 222, 240, 235) -- 341
		) -- 341
		fgGlow:drawDot( -- 342
			Vec2(cx + f * sw * 2.15, shY - 14), -- 342
			3.6, -- 342
			toColor(PALETTE.amber, 225) -- 342
		) -- 342
	end -- 342
end -- 175
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 348
	local cx = cam:sx(a.x) -- 357
	local by = cam:sy(a.y, a.depth) -- 358
	local depthEnabled = p.room.depth ~= nil -- 359
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 360
	local H = cam:len(a.h) -- 361
	local W = cam:len(a.w) -- 362
	local f = a.facing -- 363
	local speed = math.max( -- 364
		math.abs(a.vx), -- 364
		math.abs(a.depthSpeed) -- 364
	) -- 364
	local afraid = not isControlled and p.escort.fear > 0 -- 366
	local slot = "child_idle" -- 367
	local height = H -- 368
	local frame = 0 -- 369
	local step = math.floor(self.animTime * 10) -- 370
	local nearCover = __TS__ArraySome( -- 371
		p.room.solids, -- 371
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 371
			math.abs(a.x - solid.x), -- 374
			math.abs(a.x - solid.x - solid.w) -- 374
		) <= 30 end -- 374
	) -- 374
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 374
		slot = "child_knock" -- 377
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 377
		slot = "child_offer" -- 380
	elseif isControlled and p.ticks < self.throwUntil then -- 380
		slot = "child_throw" -- 382
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 382
		slot = "child_aim" -- 384
	elseif isControlled and p.gripping then -- 384
		slot = "child_pull" -- 386
		frame = self.cartMoving and step or 0 -- 387
	elseif afraid and p.escort.state == "frozen" then -- 387
		slot = "child_fear" -- 389
		height = height * 0.74 -- 390
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 390
		slot = "child_peek" -- 393
		height = height * 0.83 -- 394
	elseif a.crouch then -- 394
		slot = "child_crouch" -- 396
		frame = speed > 8 and step or 0 -- 397
	elseif speed > 8 then -- 397
		slot = "child_run" -- 399
		frame = step -- 400
	end -- 400
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 402
	if assets:tryPlace( -- 402
		slot, -- 403
		"actor_child", -- 403
		cx, -- 403
		by, -- 403
		W, -- 403
		height, -- 403
		{ -- 403
			facing = facing, -- 404
			frame = frame, -- 404
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 404
		} -- 404
	) then -- 404
		fgDraw:drawEllipse( -- 406
			Vec2(cx, shadowY + 1), -- 406
			W * 0.48, -- 406
			3, -- 406
			Color(12, 11, 13, 125) -- 406
		) -- 406
		if afraid then -- 406
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 408
		end -- 408
		return -- 410
	end -- 410
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 413
	local x = cx + jitter -- 414
	local fullRef = a.crouch and H * 1.35 or H -- 416
	local cw = fullRef * 0.16 -- 417
	fgDraw:drawEllipse( -- 420
		Vec2(x, shadowY + 1), -- 420
		cw * 1.15, -- 420
		3.6, -- 420
		Color(4, 6, 10, 155) -- 420
	) -- 420
	local walking = speed > 6 and a.onGround -- 422
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 423
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 424
	local hipY = by + H * 0.3 -- 427
	local legSwing = stride * cw * 0.85 -- 428
	fgDraw:drawSegment( -- 429
		Vec2(x - 2, hipY), -- 429
		Vec2(x - legSwing, by + 2), -- 429
		math.max(2.6, cw * 0.22), -- 429
		Color(34, 30, 38, 255) -- 429
	) -- 429
	fgDraw:drawSegment( -- 430
		Vec2(x + 2, hipY), -- 430
		Vec2(x + legSwing, by + 2), -- 430
		math.max(2.8, cw * 0.24), -- 430
		Color(52, 46, 56, 255) -- 430
	) -- 430
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 433
	local cloakBotY = by + H * 0.2 -- 434
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 435
	fgDraw:drawPolygon( -- 436
		{ -- 436
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 437
			Vec2(x + cw * 0.92, cloakBotY), -- 438
			Vec2(x + cw * 0.62, cloakTopY), -- 439
			Vec2(x - cw * 0.68, cloakTopY) -- 440
		}, -- 440
		Color(214, 166, 94, 255), -- 441
		1.3, -- 441
		Color(252, 232, 192, 225) -- 441
	) -- 441
	fgDraw:drawPolygon( -- 442
		{ -- 442
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 443
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 444
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 445
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 446
		}, -- 446
		Color(148, 108, 56, 215) -- 447
	) -- 447
	fgDraw:drawSegment( -- 448
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 448
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 448
		1.8, -- 448
		toColor(PALETTE.amberCore, 200) -- 448
	) -- 448
	local scarfY = cloakTopY - 2 -- 451
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 452
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 453
	local sendX = x - f * cw * 1.65 + cloakDrag -- 454
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 455
	fgDraw:drawQuadraticBezier( -- 456
		Vec2(x - f * cw * 0.3, scarfY), -- 456
		Vec2(smidX, smidY), -- 456
		Vec2(sendX, sendY), -- 456
		2.8, -- 456
		toColor(PALETTE.amberCore, 235) -- 456
	) -- 456
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 459
	local headX = x + f * (a.crouch and 5 or 2) -- 460
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 461
	fgDraw:drawCircle( -- 462
		Vec2(headX, headY), -- 462
		headR, -- 462
		Color(240, 222, 198, 255) -- 462
	) -- 462
	fgDraw:drawPolygon( -- 464
		{ -- 464
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 465
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 466
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 467
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 468
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 469
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 470
		}, -- 470
		Color(156, 114, 62, 248), -- 471
		1.1, -- 471
		Color(244, 214, 162, 200) -- 471
	) -- 471
	fgGlow:drawDot( -- 473
		Vec2(headX + f * headR * 0.45, headY + 1), -- 473
		2.2, -- 473
		toColor(PALETTE.amberCore) -- 473
	) -- 473
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 476
	if hasCompass then -- 476
		local compX = x + f * cw * 0.65 -- 478
		local compY = by + H * 0.48 -- 479
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 480
		fgGlow:drawDot( -- 481
			Vec2(compX, compY), -- 481
			2.6, -- 481
			toColor(PALETTE.amberCore, 250) -- 481
		) -- 481
		fillRadialGlow( -- 482
			fgGlow, -- 482
			compX, -- 482
			compY, -- 482
			26 * glowPulse, -- 482
			26 * glowPulse, -- 482
			Color(248, 206, 120, 78 * glowPulse), -- 482
			Color(248, 180, 72, 0), -- 482
			14 -- 482
		) -- 482
	end -- 482
	if afraid then -- 482
		self:drawFear(fgGlow, p, x, by + H + 16) -- 486
	end -- 486
	if isControlled and walking and not a.crouch and speed > 100 then -- 486
		local r = 10 + self.animTime * 32 % 24 -- 491
		fgGlow:drawRing( -- 492
			Vec2(x, by + 3), -- 492
			r, -- 492
			r + 1.5, -- 492
			Color(0, 0, 0, 0), -- 492
			1.1, -- 492
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 492
		) -- 492
	end -- 492
end -- 348
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 496
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 497
	do -- 497
		local i = 0 -- 498
		while i < FEAR_MAX do -- 498
			local lit = i < p.escort.fear -- 499
			drawDiamond( -- 500
				fgGlow, -- 500
				x + (i - 1) * 13, -- 500
				y, -- 500
				4, -- 500
				5, -- 500
				toColor(lit and tint or PALETTE.steelDark, 215), -- 501
				1, -- 501
				toColor(tint, lit and 235 or 100) -- 501
			) -- 501
			i = i + 1 -- 498
		end -- 498
	end -- 498
end -- 496
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 505
	local x = cam:sx(e.x + f * 20) -- 506
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 507
	local dx = cam:sx(p.player.x) - x -- 508
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 509
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 510
	do -- 510
		local i = 0 -- 511
		while i < 8 do -- 511
			local a = length * i / 8 -- 512
			local b = length * (i + 1) / 8 -- 513
			fgGlow:drawSegment( -- 514
				Vec2(x + dx * a, y + dy * a), -- 514
				Vec2(x + dx * b, y + dy * b), -- 514
				1.3, -- 515
				Color(220, 120, 88, 210) -- 515
			) -- 515
			i = i + 2 -- 511
		end -- 511
	end -- 511
end -- 505
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 520
	local cx = cam:sx(e.x) -- 529
	local depth = e.depth or 0 -- 530
	local by = cam:sy(e.y, depth) -- 531
	local H = cam:len(e.h) -- 532
	local W = cam:len(e.w) -- 533
	local f = p.player.x >= e.x and 1 or -1 -- 534
	local slot = "enemy_idle" -- 536
	if not e.alive then -- 536
		slot = "enemy_down" -- 538
	elseif e.hitT > 0 then -- 538
		slot = "enemy_hit" -- 540
	elseif e.warnT > 0 then -- 540
		slot = "enemy_aim" -- 542
	end -- 542
	local height = e.alive and H or H * 0.24 -- 544
	if assets:tryPlace( -- 544
		slot, -- 545
		"actor_enemy_" .. tostring(index), -- 545
		cx, -- 545
		by, -- 545
		W, -- 545
		height, -- 545
		{ -- 545
			facing = f, -- 546
			opacity = e.alive and 1 or 0.78, -- 546
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 546
		} -- 546
	) then -- 546
		if e.alive and e.warnT > 0 then -- 546
			self:drawEnemyWarning( -- 549
				fgGlow, -- 549
				e, -- 549
				p, -- 549
				cam, -- 549
				f -- 549
			) -- 549
		end -- 549
		return -- 551
	end -- 551
	if not e.alive then -- 551
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 555
		fgDraw:drawPolygon( -- 556
			{ -- 556
				Vec2(cx - H * 0.3, by), -- 557
				Vec2(cx + H * 0.28, by), -- 558
				Vec2(cx + H * 0.2, by + H * 0.14), -- 559
				Vec2(cx - H * 0.24, by + H * 0.11) -- 560
			}, -- 560
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 561
		) -- 561
		if flash > 0 then -- 561
			fillRadialGlow( -- 563
				fgGlow, -- 563
				cx, -- 563
				by + 12, -- 563
				34 * flash, -- 563
				18 * flash, -- 563
				toColor(PALETTE.crimson, 180 * flash), -- 563
				Color(255, 48, 82, 0), -- 563
				12 -- 563
			) -- 563
		end -- 563
		return -- 565
	end -- 565
	local sw = H * 0.112 -- 568
	fgDraw:drawEllipse( -- 569
		Vec2(cx, by + 1), -- 569
		sw * 1.9, -- 569
		4, -- 569
		Color(4, 6, 10, 165) -- 569
	) -- 569
	local hipY = by + H * 0.44 -- 572
	local kneeY = by + H * 0.23 -- 573
	local shY = by + H * 0.79 -- 574
	fgDraw:drawSegment( -- 575
		Vec2(cx - 5, hipY), -- 575
		Vec2(cx - 7, kneeY), -- 575
		H * 0.044, -- 575
		Color(20, 16, 26, 255) -- 575
	) -- 575
	fgDraw:drawSegment( -- 576
		Vec2(cx - 7, kneeY), -- 576
		Vec2(cx - 8, by + 2), -- 576
		H * 0.038, -- 576
		Color(20, 16, 26, 255) -- 576
	) -- 576
	fgDraw:drawSegment( -- 577
		Vec2(cx + 5, hipY), -- 577
		Vec2(cx + 7, kneeY), -- 577
		H * 0.046, -- 577
		Color(28, 22, 36, 255) -- 577
	) -- 577
	fgDraw:drawSegment( -- 578
		Vec2(cx + 7, kneeY), -- 578
		Vec2(cx + 8, by + 2), -- 578
		H * 0.04, -- 578
		Color(28, 22, 36, 255) -- 578
	) -- 578
	fgDraw:drawPolygon( -- 580
		{ -- 580
			Vec2(cx - sw * 0.68, hipY), -- 581
			Vec2(cx + sw * 0.68, hipY), -- 582
			Vec2(cx + sw * 1.12, shY), -- 583
			Vec2(cx - sw * 1.12, shY) -- 584
		}, -- 584
		Color(111, 68, 55, 255), -- 585
		1.3, -- 585
		Color(143, 101, 66, 220) -- 585
	) -- 585
	fgDraw:drawPolygon( -- 586
		{ -- 586
			Vec2(cx - sw * 1.26, shY - 6), -- 587
			Vec2(cx + sw * 1.26, shY - 6), -- 588
			Vec2(cx + sw * 0.96, shY + 5), -- 589
			Vec2(cx - sw * 0.96, shY + 5) -- 590
		}, -- 590
		Color(98, 82, 62, 255) -- 591
	) -- 591
	local headR = H * 0.086 -- 593
	local headY = shY + headR * 1.32 -- 594
	fgDraw:drawCircle( -- 595
		Vec2(cx, headY), -- 595
		headR * 0.82, -- 595
		Color(187, 142, 103, 255) -- 595
	) -- 595
	fgDraw:drawPolygon( -- 596
		{ -- 596
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 597
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 598
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 599
		}, -- 599
		Color(136, 105, 65, 255), -- 600
		1.1, -- 600
		Color(177, 145, 91, 220) -- 600
	) -- 600
	local gunX = cx + f * H * 0.34 -- 602
	local gunY = by + H * 0.69 -- 603
	fgDraw:drawSegment( -- 604
		Vec2(cx - f * 6, gunY - 2), -- 604
		Vec2(gunX, gunY), -- 604
		2.8, -- 604
		Color(118, 87, 61, 255) -- 604
	) -- 604
	if e.warnT > 0 then -- 604
		self:drawEnemyWarning( -- 606
			fgGlow, -- 606
			e, -- 606
			p, -- 606
			cam, -- 606
			f -- 606
		) -- 606
	end -- 606
end -- 520
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 611
	local s = p.room.scavenger -- 618
	if s == nil then -- 618
		return -- 620
	end -- 620
	local cx = cam:sx(p.scavX) -- 622
	local by = cam:sy(s.y) -- 623
	local H = cam:len(s.h) -- 624
	local W = cam:len(26) -- 625
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 626
	local alert = p.scavChase or p.scavSee > 0 -- 629
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 630
	local eyeY = by + H * 0.8 -- 631
	local coneLen = cam:len(alert and 155 or 115) -- 632
	fgGlow:drawVertices({ -- 633
		{ -- 634
			Vec2(cx + f * 6, eyeY), -- 634
			toColor(coneCol, alert and 78 or 34) -- 634
		}, -- 634
		{ -- 635
			Vec2(cx + f * coneLen, by + H * 1.05), -- 635
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 635
		}, -- 635
		{ -- 636
			Vec2(cx + f * coneLen, by + 4), -- 636
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 636
		} -- 636
	}) -- 636
	local frame = 0 -- 639
	if p.scavState == "turn" then -- 639
		frame = 2 -- 641
	elseif p.scavState == "chase" then -- 641
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 643
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 643
		frame = math.floor(self.animTime * 8) % 2 -- 645
	end -- 645
	if assets:tryPlace( -- 645
		"scavenger", -- 647
		"actor_scav", -- 647
		cx, -- 647
		by, -- 647
		W, -- 647
		H, -- 647
		{facing = f, frame = frame, layer = 3} -- 647
	) then -- 647
		return -- 648
	end -- 648
	fgDraw:drawEllipse( -- 651
		Vec2(cx, by + 1), -- 651
		W * 0.62, -- 651
		4, -- 651
		Color(4, 6, 10, 155) -- 651
	) -- 651
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 652
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 653
	fgDraw:drawSegment( -- 655
		Vec2(cx - 4, by + H * 0.4), -- 655
		Vec2(cx - stride, by + 2), -- 655
		W * 0.16, -- 655
		Color(32, 30, 28, 255) -- 655
	) -- 655
	fgDraw:drawSegment( -- 656
		Vec2(cx + 4, by + H * 0.4), -- 656
		Vec2(cx + stride, by + 2), -- 656
		W * 0.16, -- 656
		Color(44, 40, 36, 255) -- 656
	) -- 656
	fgDraw:drawPolygon( -- 658
		{ -- 658
			Vec2(cx - W * 0.45, by + H * 0.25), -- 659
			Vec2(cx + W * 0.42, by + H * 0.25), -- 660
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 661
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 662
		}, -- 662
		Color(56, 52, 46, 255), -- 663
		1.2, -- 663
		Color(128, 118, 100, 180) -- 663
	) -- 663
	local headX = cx + f * 5 -- 665
	local headY = by + H * 0.88 -- 666
	fgDraw:drawCircle( -- 667
		Vec2(headX, headY), -- 667
		W * 0.3, -- 667
		Color(42, 38, 34, 255) -- 667
	) -- 667
	fgGlow:drawDot( -- 668
		Vec2(headX + f * 6, headY), -- 668
		3, -- 668
		toColor(coneCol, 245) -- 668
	) -- 668
	local indY = by + H + 18 -- 671
	if p.scavChase then -- 671
		drawDiamond( -- 673
			fgGlow, -- 673
			cx, -- 673
			indY, -- 673
			9, -- 673
			12, -- 673
			toColor(PALETTE.crimson, 240), -- 673
			1.5, -- 673
			toColor(PALETTE.crimsonCore) -- 673
		) -- 673
	elseif p.scavSee > 0 then -- 673
		local frac = math.min(1, p.scavSee / 24) -- 675
		fgGlow:drawArc( -- 676
			Vec2(cx, indY), -- 676
			11, -- 676
			90, -- 676
			90 - 360 * frac, -- 676
			2.4, -- 676
			toColor(PALETTE.crimson, 235) -- 676
		) -- 676
		fgGlow:drawDot( -- 677
			Vec2(cx, indY), -- 677
			3, -- 677
			toColor(PALETTE.amber) -- 677
		) -- 677
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 677
		drawDiamond( -- 679
			fgGlow, -- 679
			cx, -- 679
			indY, -- 679
			6, -- 679
			8, -- 679
			toColor(PALETTE.amber, 220) -- 679
		) -- 679
	end -- 679
end -- 611
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 684
	local cx = cam:sx(p.dogX) -- 691
	local by = cam:sy(0) -- 692
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 693
	local W = cam:len(34) -- 694
	local H = cam:len(28) -- 695
	local frame = 0 -- 697
	if p.dogState == "ear" then -- 697
		frame = 1 -- 699
	elseif p.dogState == "sniff" then -- 699
		frame = 3 -- 701
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 701
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 703
	end -- 703
	if assets:tryPlace( -- 703
		"dog", -- 705
		"actor_dog", -- 705
		cx, -- 705
		by, -- 705
		W, -- 705
		H, -- 705
		{facing = f, frame = frame, layer = 3} -- 705
	) then -- 705
		return -- 706
	end -- 706
	fgDraw:drawEllipse( -- 709
		Vec2(cx, by + 1), -- 709
		W * 0.56, -- 709
		3.5, -- 709
		Color(4, 8, 10, 155) -- 709
	) -- 709
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 710
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 711
	fgDraw:drawSegment( -- 714
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 714
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 714
		2.8, -- 714
		Color(26, 30, 34, 255) -- 714
	) -- 714
	fgDraw:drawSegment( -- 715
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 715
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 715
		2.8, -- 715
		Color(36, 40, 44, 255) -- 715
	) -- 715
	fgDraw:drawPolygon( -- 717
		{ -- 717
			Vec2(cx - W * 0.42, by + H * 0.36), -- 718
			Vec2(cx + W * 0.38, by + H * 0.42), -- 719
			Vec2(cx + W * 0.34, by + H * 0.78), -- 720
			Vec2(cx - W * 0.38, by + H * 0.72) -- 721
		}, -- 721
		Color(38, 42, 48, 255), -- 722
		1.2, -- 722
		Color(102, 118, 126, 175) -- 722
	) -- 722
	local hx = cx + f * W * 0.42 -- 723
	local hy = by + H * 0.84 -- 724
	fgDraw:drawPolygon( -- 725
		{ -- 725
			Vec2(hx - f * 8, hy - 6), -- 726
			Vec2(hx + f * 12, hy - 2), -- 727
			Vec2(hx + f * 4, hy + 8), -- 728
			Vec2(hx - f * 6, hy + 14) -- 729
		}, -- 729
		Color(44, 48, 54, 255) -- 730
	) -- 730
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 732
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 733
	fgGlow:drawDot( -- 734
		Vec2(hx + f * 4, hy + 2), -- 734
		2.8, -- 734
		toColor(eyeCol, 250) -- 734
	) -- 734
	fillRadialGlow( -- 735
		fgGlow, -- 735
		hx + f * 4, -- 735
		hy + 2, -- 735
		16, -- 735
		16, -- 735
		toColor(eyeCol, alert and 135 or 70), -- 735
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 735
		12 -- 735
	) -- 735
	if alert then -- 735
		local r = 12 + self.animTime * 42 % 24 -- 738
		fgGlow:drawArc( -- 739
			Vec2(hx, hy + 12), -- 739
			r, -- 739
			35, -- 739
			145, -- 739
			1.8, -- 739
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 739
		) -- 739
	end -- 739
end -- 684
return ____exports -- 684