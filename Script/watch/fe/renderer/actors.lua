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
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam) -- 99
	self:drawAfterimages(fgGlow, cam) -- 107
	local i = 0 -- 110
	do -- 110
		i = 0 -- 111
		while i < #p.enemies do -- 111
			self:drawEnemy( -- 112
				fgDraw, -- 112
				fgGlow, -- 112
				assets, -- 112
				p.enemies[i + 1], -- 112
				i, -- 112
				p, -- 112
				cam -- 112
			) -- 112
			i = i + 1 -- 111
		end -- 111
	end -- 111
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 111
		self:drawScavenger( -- 117
			fgDraw, -- 117
			fgGlow, -- 117
			assets, -- 117
			p, -- 117
			cam -- 117
		) -- 117
	end -- 117
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 117
		self:drawDog( -- 122
			fgDraw, -- 122
			fgGlow, -- 122
			assets, -- 122
			p, -- 122
			cam -- 122
		) -- 122
	end -- 122
	if p.partner.alive then -- 122
		local partnerIsChild = p.partner.w <= 28 -- 127
		if partnerIsChild then -- 127
			self:drawXiaoman( -- 129
				fgDraw, -- 129
				fgGlow, -- 129
				assets, -- 129
				p.partner, -- 129
				p, -- 129
				cam, -- 129
				false -- 129
			) -- 129
		else -- 129
			self:drawZhouShu( -- 131
				fgDraw, -- 131
				fgGlow, -- 131
				assets, -- 131
				p.partner, -- 131
				p, -- 131
				cam, -- 131
				false -- 131
			) -- 131
		end -- 131
	end -- 131
	if p.player.alive then -- 131
		if p.childMode then -- 131
			self:drawXiaoman( -- 138
				fgDraw, -- 138
				fgGlow, -- 138
				assets, -- 138
				p.player, -- 138
				p, -- 138
				cam, -- 138
				true -- 138
			) -- 138
		else -- 138
			self:drawZhouShu( -- 140
				fgDraw, -- 140
				fgGlow, -- 140
				assets, -- 140
				p.player, -- 140
				p, -- 140
				cam, -- 140
				true -- 140
			) -- 140
		end -- 140
	end -- 140
end -- 99
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 145
	local i = 0 -- 146
	do -- 146
		i = 0 -- 147
		while i < #self.ghosts do -- 147
			local g = self.ghosts[i + 1] -- 148
			local k = g.life / g.maxLife -- 149
			local cx = cam:sx(g.x) -- 150
			local by = cam:sy(g.y) -- 151
			local h = cam:len(g.h * 0.68) -- 152
			local w = cam:len(28) -- 153
			local f = g.facing -- 154
			fgGlow:drawPolygon( -- 156
				{ -- 156
					Vec2(cx - f * w * 0.9, by + 4), -- 157
					Vec2(cx + f * w * 0.55, by + 6), -- 158
					Vec2(cx + f * w * 0.85, by + h * 0.72), -- 159
					Vec2(cx - f * w * 0.15, by + h), -- 160
					Vec2(cx - f * w * 0.85, by + h * 0.58) -- 161
				}, -- 161
				toColor(PALETTE.cyan, 115 * k) -- 162
			) -- 162
			fgGlow:drawSegment( -- 164
				Vec2(cx - f * w * 1.15, by + h * 0.62), -- 165
				Vec2(cx + f * w * 0.72, by + h * 0.76), -- 166
				2.2 * k, -- 167
				toColor(PALETTE.cyanCore, 165 * k) -- 168
			) -- 168
			i = i + 1 -- 147
		end -- 147
	end -- 147
end -- 145
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 174
	local cx = cam:sx(a.x) -- 183
	local by = cam:sy(a.y, a.depth) -- 184
	local depthEnabled = p.room.depth ~= nil -- 185
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 186
	local H = cam:len(a.h) -- 187
	local W = cam:len(a.w) -- 188
	local f = a.facing -- 189
	local speed = math.max( -- 190
		math.abs(a.vx), -- 190
		math.abs(a.depthSpeed) -- 190
	) -- 190
	local slot = "soldier_idle" -- 192
	local height = H -- 193
	local frame = 0 -- 194
	local facing = f -- 195
	local step = math.floor(self.animTime * 10) -- 196
	if isControlled and p.ticks < self.hitUntil then -- 196
		slot = "soldier_hit" -- 198
	elseif a.rollT > 0 then -- 198
		slot = "soldier_roll" -- 200
		height = height * 0.59 -- 201
	elseif p.phase == "prologue-give" then -- 201
		slot = "soldier_offer" -- 203
		height = height * 0.75 -- 204
		facing = p.partner.x >= a.x and 1 or -1 -- 205
	elseif isControlled and p.gripping then -- 205
		slot = "soldier_push" -- 207
		frame = self.cartMoving and step or 0 -- 208
		facing = p.room.cart.handleOffset < 0 and 1 or -1 -- 209
		height = height * 0.91 -- 210
	elseif isControlled and p.escort.state == "calming" then -- 210
		slot = "soldier_knock" -- 212
		local calm = p.escort.calmTick -- 213
		frame = (calm >= 12 and calm < 18 or calm >= 36 and calm < 42) and 1 or 0 -- 214
		height = height * 0.76 -- 215
	else -- 215
		local ____temp_3 = p.phase == "gate-send" -- 216
		if ____temp_3 then -- 216
			local ____opt_1 = p.room.story -- 216
			____temp_3 = (____opt_1 and ____opt_1.gate) ~= nil -- 216
		end -- 216
		if ____temp_3 and math.abs(a.x - p.room.story.gate.doorX) <= 60 and speed <= 8 then -- 216
			slot = "soldier_hold" -- 218
			height = height * 1.11 -- 219
		elseif isControlled and p.ticks < self.shotUntil then -- 219
			local running = speed > 8 -- 221
			slot = running and "soldier_fire_move" or "soldier_fire" -- 222
			frame = running and step or 0 -- 223
			facing = p.trace ~= nil and p.trace.x1 < p.trace.x0 and -1 or 1 -- 224
		elseif a.covered or isControlled and p.coverHug then -- 224
			slot = "soldier_cover" -- 226
			height = height * 0.77 -- 227
		elseif speed > 8 then -- 227
			slot = "soldier_run" -- 229
			frame = step -- 230
		end -- 230
	end -- 230
	if assets:tryPlace( -- 230
		slot, -- 232
		"actor_soldier", -- 232
		cx, -- 232
		by, -- 232
		W, -- 232
		height, -- 232
		{ -- 232
			facing = facing, -- 233
			frame = frame, -- 233
			layer = depthEnabled and depthOrder(a.depth, 4) or 4 -- 233
		} -- 233
	) then -- 233
		fgDraw:drawEllipse( -- 235
			Vec2(cx, shadowY + 1), -- 235
			W * 0.54, -- 235
			4, -- 235
			Color(12, 11, 13, 145) -- 235
		) -- 235
		return -- 236
	end -- 236
	fgDraw:drawEllipse( -- 240
		Vec2(cx, shadowY + 1), -- 240
		H * 0.24, -- 240
		4.5, -- 240
		Color(3, 5, 10, 175) -- 240
	) -- 240
	local walking = speed > 10 and a.onGround -- 242
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 243
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 244
	local calming = not p.childMode and p.escort.state == "calming" -- 245
	local rolling = a.rollT > 0 -- 246
	local crouching = a.covered or calming or rolling -- 247
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 250
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 251
	local sw = H * 0.115 -- 252
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 255
	local kneeY = by + bodyH * 0.23 -- 256
	local stepX = stride * H * 0.15 -- 257
	local legDark = Color(14, 21, 34, 255) -- 258
	local legFront = Color(26, 38, 58, 255) -- 259
	local bkX = cx - f * 4 - stepX * 0.5 -- 261
	local bfX = cx - f * 8 - stepX -- 262
	fgDraw:drawSegment( -- 263
		Vec2(cx - f * 3, hipY), -- 263
		Vec2(bkX, kneeY), -- 263
		H * 0.044, -- 263
		legDark -- 263
	) -- 263
	fgDraw:drawSegment( -- 264
		Vec2(bkX, kneeY), -- 264
		Vec2(bfX, by + 3), -- 264
		H * 0.038, -- 264
		legDark -- 264
	) -- 264
	local fkX = cx + f * 6 + stepX * 0.55 -- 266
	local ffX = cx + f * 7 + stepX -- 267
	fgDraw:drawSegment( -- 268
		Vec2(cx + f * 3, hipY), -- 268
		Vec2(fkX, kneeY), -- 268
		H * 0.048, -- 268
		legFront -- 268
	) -- 268
	fgDraw:drawSegment( -- 269
		Vec2(fkX, kneeY), -- 269
		Vec2(ffX, by + 3), -- 269
		H * 0.042, -- 269
		legFront -- 269
	) -- 269
	fgDraw:drawSegment( -- 271
		Vec2(ffX - f * 2, by + 3), -- 271
		Vec2(ffX + f * 9, by + 3), -- 271
		3.4, -- 271
		Color(42, 60, 86, 255) -- 271
	) -- 271
	local shY = by + bodyH * 0.8 + bob -- 274
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 275
	fgDraw:drawPolygon( -- 276
		{ -- 276
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 277
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 278
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 279
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 280
		}, -- 280
		Color(16, 26, 42, 248), -- 281
		1.2, -- 281
		Color(64, 118, 164, 195) -- 281
	) -- 281
	fgDraw:drawPolygon( -- 284
		{ -- 284
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 285
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 286
			Vec2(cx + sw * 1.05 + lean, shY), -- 287
			Vec2(cx - sw * 0.98 + lean, shY) -- 288
		}, -- 288
		Color(24, 38, 60, 255), -- 289
		1.3, -- 289
		toColor(PALETTE.rimSilver, 190) -- 289
	) -- 289
	fgDraw:drawSegment( -- 291
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 292
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 293
		2.4, -- 294
		Color(173, 155, 125, 225) -- 295
	) -- 295
	fgDraw:drawPolygon( -- 297
		{ -- 297
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 298
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 299
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 300
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 301
		}, -- 301
		Color(99, 105, 103, 248) -- 302
	) -- 302
	local headR = H * 0.088 -- 305
	local headX = cx + lean + f * 3 -- 306
	local headY = shY + headR * 1.35 -- 307
	fgDraw:drawCircle( -- 308
		Vec2(headX, headY - headR * 0.12), -- 308
		headR * 0.86, -- 308
		Color(181, 139, 106, 255) -- 308
	) -- 308
	fgDraw:drawEllipse( -- 309
		Vec2(headX, headY + headR * 0.5), -- 309
		headR * 1.12, -- 309
		headR * 0.72, -- 309
		Color(66, 73, 76, 255) -- 309
	) -- 309
	fgDraw:drawSegment( -- 310
		Vec2(headX - headR, headY + 1), -- 310
		Vec2(headX + headR, headY + 1), -- 310
		1.6, -- 311
		Color(97, 103, 101, 255) -- 311
	) -- 311
	fgDraw:drawSegment( -- 312
		Vec2(headX, headY + headR), -- 312
		Vec2(headX - f * headR * 0.38, headY + headR * 1.48), -- 312
		1.6, -- 313
		Color(177, 78, 51, 255) -- 313
	) -- 313
	if isControlled and not calming and not rolling and not p.gripping then -- 313
		local gunPivotX = cx + lean + f * sw * 0.35 -- 317
		local gunPivotY = shY - bodyH * 0.1 -- 318
		local aimDx = f -- 319
		local aimDy = 0 -- 320
		if p.aimX > 0 or p.aimY > 0 then -- 320
			aimDx = p.aimX - gunPivotX -- 322
			aimDy = p.aimY - gunPivotY -- 323
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 324
			if dLen > 4 then -- 324
				aimDx = aimDx / dLen -- 326
				aimDy = aimDy / dLen -- 327
			end -- 327
		end -- 327
		local barrelLen = H * 0.34 -- 330
		local tipX = gunPivotX + aimDx * barrelLen -- 331
		local tipY = gunPivotY + aimDy * barrelLen -- 332
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 333
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 334
		fgDraw:drawSegment( -- 336
			Vec2(cx + lean, shY - 5), -- 336
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 336
			3.6, -- 336
			Color(26, 40, 62, 255) -- 336
		) -- 336
		fgDraw:drawSegment( -- 337
			Vec2(stockX, stockY), -- 337
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 337
			3.8, -- 337
			Color(105, 71, 50, 255) -- 337
		) -- 337
		fgDraw:drawSegment( -- 338
			Vec2(gunPivotX, gunPivotY), -- 338
			Vec2(tipX, tipY), -- 338
			1.8, -- 338
			Color(145, 140, 128, 245) -- 338
		) -- 338
	elseif calming then -- 338
		fgDraw:drawSegment( -- 340
			Vec2(cx + lean, shY - 6), -- 340
			Vec2(cx + f * sw * 2.1, shY - 14), -- 340
			3, -- 340
			Color(196, 222, 240, 235) -- 340
		) -- 340
		fgGlow:drawDot( -- 341
			Vec2(cx + f * sw * 2.15, shY - 14), -- 341
			3.6, -- 341
			toColor(PALETTE.amber, 225) -- 341
		) -- 341
	end -- 341
end -- 174
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 347
	local cx = cam:sx(a.x) -- 356
	local by = cam:sy(a.y, a.depth) -- 357
	local depthEnabled = p.room.depth ~= nil -- 358
	local shadowY = depthEnabled and not a.onGround and cam:sy(0, a.depth) or by -- 359
	local H = cam:len(a.h) -- 360
	local W = cam:len(a.w) -- 361
	local f = a.facing -- 362
	local speed = math.max( -- 363
		math.abs(a.vx), -- 363
		math.abs(a.depthSpeed) -- 363
	) -- 363
	local afraid = not isControlled and p.escort.fear > 0 -- 365
	local slot = "child_idle" -- 366
	local height = H -- 367
	local frame = 0 -- 368
	local step = math.floor(self.animTime * 10) -- 369
	local nearCover = __TS__ArraySome( -- 370
		p.room.solids, -- 370
		function(____, solid) return not solid.decorative and solid.h <= 64 and solid.y <= 2 and overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) and math.min( -- 370
			math.abs(a.x - solid.x), -- 373
			math.abs(a.x - solid.x - solid.w) -- 373
		) <= 30 end -- 373
	) -- 373
	if p.phase == "tower-knock" and (p.phaseTick < 6 or p.phaseTick >= 12 and p.phaseTick < 18) then -- 373
		slot = "child_knock" -- 376
	elseif p.phase == "tower-given" and p.phaseTick >= 60 and p.phaseTick < 120 or p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 376
		slot = "child_offer" -- 379
	elseif isControlled and p.ticks < self.throwUntil then -- 379
		slot = "child_throw" -- 381
	elseif isControlled and p.hasBottle and p.aimHold > 0 then -- 381
		slot = "child_aim" -- 383
	elseif isControlled and p.gripping then -- 383
		slot = "child_pull" -- 385
		frame = self.cartMoving and step or 0 -- 386
	elseif afraid and p.escort.state == "frozen" then -- 386
		slot = "child_fear" -- 388
		height = height * 0.74 -- 389
	elseif not isControlled and nearCover and (p.room.key == "street" or p.room.key == "checkpoint") and speed < 8 then -- 389
		slot = "child_peek" -- 392
		height = height * 0.83 -- 393
	elseif a.crouch then -- 393
		slot = "child_crouch" -- 395
		frame = speed > 8 and step or 0 -- 396
	elseif speed > 8 then -- 396
		slot = "child_run" -- 398
		frame = step -- 399
	end -- 399
	local facing = slot == "child_pull" and (p.room.cart.handleOffset < 0 and 1 or -1) or f -- 401
	if assets:tryPlace( -- 401
		slot, -- 402
		"actor_child", -- 402
		cx, -- 402
		by, -- 402
		W, -- 402
		height, -- 402
		{ -- 402
			facing = facing, -- 403
			frame = frame, -- 403
			layer = depthEnabled and depthOrder(a.depth, 5) or 5 -- 403
		} -- 403
	) then -- 403
		fgDraw:drawEllipse( -- 405
			Vec2(cx, shadowY + 1), -- 405
			W * 0.48, -- 405
			3, -- 405
			Color(12, 11, 13, 125) -- 405
		) -- 405
		if afraid then -- 405
			self:drawFear(fgGlow, p, cx, by + height + 14) -- 407
		end -- 407
		return -- 409
	end -- 409
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 412
	local x = cx + jitter -- 413
	local fullRef = a.crouch and H * 1.35 or H -- 415
	local cw = fullRef * 0.16 -- 416
	fgDraw:drawEllipse( -- 419
		Vec2(x, shadowY + 1), -- 419
		cw * 1.15, -- 419
		3.6, -- 419
		Color(4, 6, 10, 155) -- 419
	) -- 419
	local walking = speed > 6 and a.onGround -- 421
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 422
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 423
	local hipY = by + H * 0.3 -- 426
	local legSwing = stride * cw * 0.85 -- 427
	fgDraw:drawSegment( -- 428
		Vec2(x - 2, hipY), -- 428
		Vec2(x - legSwing, by + 2), -- 428
		math.max(2.6, cw * 0.22), -- 428
		Color(34, 30, 38, 255) -- 428
	) -- 428
	fgDraw:drawSegment( -- 429
		Vec2(x + 2, hipY), -- 429
		Vec2(x + legSwing, by + 2), -- 429
		math.max(2.8, cw * 0.24), -- 429
		Color(52, 46, 56, 255) -- 429
	) -- 429
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 432
	local cloakBotY = by + H * 0.2 -- 433
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 434
	fgDraw:drawPolygon( -- 435
		{ -- 435
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 436
			Vec2(x + cw * 0.92, cloakBotY), -- 437
			Vec2(x + cw * 0.62, cloakTopY), -- 438
			Vec2(x - cw * 0.68, cloakTopY) -- 439
		}, -- 439
		Color(214, 166, 94, 255), -- 440
		1.3, -- 440
		Color(252, 232, 192, 225) -- 440
	) -- 440
	fgDraw:drawPolygon( -- 441
		{ -- 441
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 442
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 443
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 444
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 445
		}, -- 445
		Color(148, 108, 56, 215) -- 446
	) -- 446
	fgDraw:drawSegment( -- 447
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 447
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 447
		1.8, -- 447
		toColor(PALETTE.amberCore, 200) -- 447
	) -- 447
	local scarfY = cloakTopY - 2 -- 450
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 451
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 452
	local sendX = x - f * cw * 1.65 + cloakDrag -- 453
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 454
	fgDraw:drawQuadraticBezier( -- 455
		Vec2(x - f * cw * 0.3, scarfY), -- 455
		Vec2(smidX, smidY), -- 455
		Vec2(sendX, sendY), -- 455
		2.8, -- 455
		toColor(PALETTE.amberCore, 235) -- 455
	) -- 455
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 458
	local headX = x + f * (a.crouch and 5 or 2) -- 459
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 460
	fgDraw:drawCircle( -- 461
		Vec2(headX, headY), -- 461
		headR, -- 461
		Color(240, 222, 198, 255) -- 461
	) -- 461
	fgDraw:drawPolygon( -- 463
		{ -- 463
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 464
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 465
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 466
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 467
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 468
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 469
		}, -- 469
		Color(156, 114, 62, 248), -- 470
		1.1, -- 470
		Color(244, 214, 162, 200) -- 470
	) -- 470
	fgGlow:drawDot( -- 472
		Vec2(headX + f * headR * 0.45, headY + 1), -- 472
		2.2, -- 472
		toColor(PALETTE.amberCore) -- 472
	) -- 472
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 475
	if hasCompass then -- 475
		local compX = x + f * cw * 0.65 -- 477
		local compY = by + H * 0.48 -- 478
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 479
		fgGlow:drawDot( -- 480
			Vec2(compX, compY), -- 480
			2.6, -- 480
			toColor(PALETTE.amberCore, 250) -- 480
		) -- 480
		fillRadialGlow( -- 481
			fgGlow, -- 481
			compX, -- 481
			compY, -- 481
			26 * glowPulse, -- 481
			26 * glowPulse, -- 481
			Color(248, 206, 120, 78 * glowPulse), -- 481
			Color(248, 180, 72, 0), -- 481
			14 -- 481
		) -- 481
	end -- 481
	if afraid then -- 481
		self:drawFear(fgGlow, p, x, by + H + 16) -- 485
	end -- 485
	if isControlled and walking and not a.crouch and speed > 100 then -- 485
		local r = 10 + self.animTime * 32 % 24 -- 490
		fgGlow:drawRing( -- 491
			Vec2(x, by + 3), -- 491
			r, -- 491
			r + 1.5, -- 491
			Color(0, 0, 0, 0), -- 491
			1.1, -- 491
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 491
		) -- 491
	end -- 491
end -- 347
function ActorsRenderer.prototype.drawFear(self, fgGlow, p, x, y) -- 495
	local tint = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 496
	do -- 496
		local i = 0 -- 497
		while i < FEAR_MAX do -- 497
			local lit = i < p.escort.fear -- 498
			drawDiamond( -- 499
				fgGlow, -- 499
				x + (i - 1) * 13, -- 499
				y, -- 499
				4, -- 499
				5, -- 499
				toColor(lit and tint or PALETTE.steelDark, 215), -- 500
				1, -- 500
				toColor(tint, lit and 235 or 100) -- 500
			) -- 500
			i = i + 1 -- 497
		end -- 497
	end -- 497
end -- 495
function ActorsRenderer.prototype.drawEnemyWarning(self, fgGlow, e, p, cam, f) -- 504
	local x = cam:sx(e.x + f * 20) -- 505
	local y = cam:sy(e.y + e.h * 0.69, e.depth or 0) -- 506
	local dx = cam:sx(p.player.x) - x -- 507
	local dy = cam:sy(p.player.y + p.player.h * 0.56, p.player.depth) - y -- 508
	local length = 0.4 + 0.6 * math.min(1, e.warnT / 36) -- 509
	do -- 509
		local i = 0 -- 510
		while i < 8 do -- 510
			local a = length * i / 8 -- 511
			local b = length * (i + 1) / 8 -- 512
			fgGlow:drawSegment( -- 513
				Vec2(x + dx * a, y + dy * a), -- 513
				Vec2(x + dx * b, y + dy * b), -- 513
				1.3, -- 514
				Color(220, 120, 88, 210) -- 514
			) -- 514
			i = i + 2 -- 510
		end -- 510
	end -- 510
end -- 504
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 519
	local cx = cam:sx(e.x) -- 528
	local depth = e.depth or 0 -- 529
	local by = cam:sy(e.y, depth) -- 530
	local H = cam:len(e.h) -- 531
	local W = cam:len(e.w) -- 532
	local f = p.player.x >= e.x and 1 or -1 -- 533
	local slot = "enemy_idle" -- 535
	if not e.alive then -- 535
		slot = "enemy_down" -- 537
	elseif e.hitT > 0 then -- 537
		slot = "enemy_hit" -- 539
	elseif e.warnT > 0 then -- 539
		slot = "enemy_aim" -- 541
	end -- 541
	local height = e.alive and H or H * 0.24 -- 543
	if assets:tryPlace( -- 543
		slot, -- 544
		"actor_enemy_" .. tostring(index), -- 544
		cx, -- 544
		by, -- 544
		W, -- 544
		height, -- 544
		{ -- 544
			facing = f, -- 545
			opacity = e.alive and 1 or 0.78, -- 545
			layer = p.room.depth == nil and 3 or depthOrder(depth, 3) -- 545
		} -- 545
	) then -- 545
		if e.alive and e.warnT > 0 then -- 545
			self:drawEnemyWarning( -- 548
				fgGlow, -- 548
				e, -- 548
				p, -- 548
				cam, -- 548
				f -- 548
			) -- 548
		end -- 548
		return -- 550
	end -- 550
	if not e.alive then -- 550
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 554
		fgDraw:drawPolygon( -- 555
			{ -- 555
				Vec2(cx - H * 0.3, by), -- 556
				Vec2(cx + H * 0.28, by), -- 557
				Vec2(cx + H * 0.2, by + H * 0.14), -- 558
				Vec2(cx - H * 0.24, by + H * 0.11) -- 559
			}, -- 559
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 560
		) -- 560
		if flash > 0 then -- 560
			fillRadialGlow( -- 562
				fgGlow, -- 562
				cx, -- 562
				by + 12, -- 562
				34 * flash, -- 562
				18 * flash, -- 562
				toColor(PALETTE.crimson, 180 * flash), -- 562
				Color(255, 48, 82, 0), -- 562
				12 -- 562
			) -- 562
		end -- 562
		return -- 564
	end -- 564
	local sw = H * 0.112 -- 567
	fgDraw:drawEllipse( -- 568
		Vec2(cx, by + 1), -- 568
		sw * 1.9, -- 568
		4, -- 568
		Color(4, 6, 10, 165) -- 568
	) -- 568
	local hipY = by + H * 0.44 -- 571
	local kneeY = by + H * 0.23 -- 572
	local shY = by + H * 0.79 -- 573
	fgDraw:drawSegment( -- 574
		Vec2(cx - 5, hipY), -- 574
		Vec2(cx - 7, kneeY), -- 574
		H * 0.044, -- 574
		Color(20, 16, 26, 255) -- 574
	) -- 574
	fgDraw:drawSegment( -- 575
		Vec2(cx - 7, kneeY), -- 575
		Vec2(cx - 8, by + 2), -- 575
		H * 0.038, -- 575
		Color(20, 16, 26, 255) -- 575
	) -- 575
	fgDraw:drawSegment( -- 576
		Vec2(cx + 5, hipY), -- 576
		Vec2(cx + 7, kneeY), -- 576
		H * 0.046, -- 576
		Color(28, 22, 36, 255) -- 576
	) -- 576
	fgDraw:drawSegment( -- 577
		Vec2(cx + 7, kneeY), -- 577
		Vec2(cx + 8, by + 2), -- 577
		H * 0.04, -- 577
		Color(28, 22, 36, 255) -- 577
	) -- 577
	fgDraw:drawPolygon( -- 579
		{ -- 579
			Vec2(cx - sw * 0.68, hipY), -- 580
			Vec2(cx + sw * 0.68, hipY), -- 581
			Vec2(cx + sw * 1.12, shY), -- 582
			Vec2(cx - sw * 1.12, shY) -- 583
		}, -- 583
		Color(111, 68, 55, 255), -- 584
		1.3, -- 584
		Color(143, 101, 66, 220) -- 584
	) -- 584
	fgDraw:drawPolygon( -- 585
		{ -- 585
			Vec2(cx - sw * 1.26, shY - 6), -- 586
			Vec2(cx + sw * 1.26, shY - 6), -- 587
			Vec2(cx + sw * 0.96, shY + 5), -- 588
			Vec2(cx - sw * 0.96, shY + 5) -- 589
		}, -- 589
		Color(98, 82, 62, 255) -- 590
	) -- 590
	local headR = H * 0.086 -- 592
	local headY = shY + headR * 1.32 -- 593
	fgDraw:drawCircle( -- 594
		Vec2(cx, headY), -- 594
		headR * 0.82, -- 594
		Color(187, 142, 103, 255) -- 594
	) -- 594
	fgDraw:drawPolygon( -- 595
		{ -- 595
			Vec2(cx - headR * 1.65, headY + headR * 0.22), -- 596
			Vec2(cx + headR * 1.65, headY + headR * 0.22), -- 597
			Vec2(cx - f * headR * 0.18, headY + headR * 1.22) -- 598
		}, -- 598
		Color(136, 105, 65, 255), -- 599
		1.1, -- 599
		Color(177, 145, 91, 220) -- 599
	) -- 599
	local gunX = cx + f * H * 0.34 -- 601
	local gunY = by + H * 0.69 -- 602
	fgDraw:drawSegment( -- 603
		Vec2(cx - f * 6, gunY - 2), -- 603
		Vec2(gunX, gunY), -- 603
		2.8, -- 603
		Color(118, 87, 61, 255) -- 603
	) -- 603
	if e.warnT > 0 then -- 603
		self:drawEnemyWarning( -- 605
			fgGlow, -- 605
			e, -- 605
			p, -- 605
			cam, -- 605
			f -- 605
		) -- 605
	end -- 605
end -- 519
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 610
	local s = p.room.scavenger -- 617
	if s == nil then -- 617
		return -- 619
	end -- 619
	local cx = cam:sx(p.scavX) -- 621
	local by = cam:sy(s.y) -- 622
	local H = cam:len(s.h) -- 623
	local W = cam:len(26) -- 624
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 625
	local alert = p.scavChase or p.scavSee > 0 -- 628
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 629
	local eyeY = by + H * 0.8 -- 630
	local coneLen = cam:len(alert and 155 or 115) -- 631
	fgGlow:drawVertices({ -- 632
		{ -- 633
			Vec2(cx + f * 6, eyeY), -- 633
			toColor(coneCol, alert and 78 or 34) -- 633
		}, -- 633
		{ -- 634
			Vec2(cx + f * coneLen, by + H * 1.05), -- 634
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 634
		}, -- 634
		{ -- 635
			Vec2(cx + f * coneLen, by + 4), -- 635
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 635
		} -- 635
	}) -- 635
	local frame = 0 -- 638
	if p.scavState == "turn" then -- 638
		frame = 2 -- 640
	elseif p.scavState == "chase" then -- 640
		frame = math.floor(self.animTime * 12) % 2 == 0 and 3 or 1 -- 642
	elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" then -- 642
		frame = math.floor(self.animTime * 8) % 2 -- 644
	end -- 644
	if assets:tryPlace( -- 644
		"scavenger", -- 646
		"actor_scav", -- 646
		cx, -- 646
		by, -- 646
		W, -- 646
		H, -- 646
		{facing = f, frame = frame, layer = 3} -- 646
	) then -- 646
		return -- 647
	end -- 647
	fgDraw:drawEllipse( -- 650
		Vec2(cx, by + 1), -- 650
		W * 0.62, -- 650
		4, -- 650
		Color(4, 6, 10, 155) -- 650
	) -- 650
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 651
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 652
	fgDraw:drawSegment( -- 654
		Vec2(cx - 4, by + H * 0.4), -- 654
		Vec2(cx - stride, by + 2), -- 654
		W * 0.16, -- 654
		Color(32, 30, 28, 255) -- 654
	) -- 654
	fgDraw:drawSegment( -- 655
		Vec2(cx + 4, by + H * 0.4), -- 655
		Vec2(cx + stride, by + 2), -- 655
		W * 0.16, -- 655
		Color(44, 40, 36, 255) -- 655
	) -- 655
	fgDraw:drawPolygon( -- 657
		{ -- 657
			Vec2(cx - W * 0.45, by + H * 0.25), -- 658
			Vec2(cx + W * 0.42, by + H * 0.25), -- 659
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 660
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 661
		}, -- 661
		Color(56, 52, 46, 255), -- 662
		1.2, -- 662
		Color(128, 118, 100, 180) -- 662
	) -- 662
	local headX = cx + f * 5 -- 664
	local headY = by + H * 0.88 -- 665
	fgDraw:drawCircle( -- 666
		Vec2(headX, headY), -- 666
		W * 0.3, -- 666
		Color(42, 38, 34, 255) -- 666
	) -- 666
	fgGlow:drawDot( -- 667
		Vec2(headX + f * 6, headY), -- 667
		3, -- 667
		toColor(coneCol, 245) -- 667
	) -- 667
	local indY = by + H + 18 -- 670
	if p.scavChase then -- 670
		drawDiamond( -- 672
			fgGlow, -- 672
			cx, -- 672
			indY, -- 672
			9, -- 672
			12, -- 672
			toColor(PALETTE.crimson, 240), -- 672
			1.5, -- 672
			toColor(PALETTE.crimsonCore) -- 672
		) -- 672
	elseif p.scavSee > 0 then -- 672
		local frac = math.min(1, p.scavSee / 24) -- 674
		fgGlow:drawArc( -- 675
			Vec2(cx, indY), -- 675
			11, -- 675
			90, -- 675
			90 - 360 * frac, -- 675
			2.4, -- 675
			toColor(PALETTE.crimson, 235) -- 675
		) -- 675
		fgGlow:drawDot( -- 676
			Vec2(cx, indY), -- 676
			3, -- 676
			toColor(PALETTE.amber) -- 676
		) -- 676
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 676
		drawDiamond( -- 678
			fgGlow, -- 678
			cx, -- 678
			indY, -- 678
			6, -- 678
			8, -- 678
			toColor(PALETTE.amber, 220) -- 678
		) -- 678
	end -- 678
end -- 610
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 683
	local cx = cam:sx(p.dogX) -- 690
	local by = cam:sy(0) -- 691
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 692
	local W = cam:len(34) -- 693
	local H = cam:len(28) -- 694
	local frame = 0 -- 696
	if p.dogState == "ear" then -- 696
		frame = 1 -- 698
	elseif p.dogState == "sniff" then -- 698
		frame = 3 -- 700
	elseif p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" then -- 700
		frame = math.floor(self.animTime * (p.dogState == "chase" and 14 or 8)) % 2 == 0 and 0 or 2 -- 702
	end -- 702
	if assets:tryPlace( -- 702
		"dog", -- 704
		"actor_dog", -- 704
		cx, -- 704
		by, -- 704
		W, -- 704
		H, -- 704
		{facing = f, frame = frame, layer = 3} -- 704
	) then -- 704
		return -- 705
	end -- 705
	fgDraw:drawEllipse( -- 708
		Vec2(cx, by + 1), -- 708
		W * 0.56, -- 708
		3.5, -- 708
		Color(4, 8, 10, 155) -- 708
	) -- 708
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 709
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 710
	fgDraw:drawSegment( -- 713
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 713
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 713
		2.8, -- 713
		Color(26, 30, 34, 255) -- 713
	) -- 713
	fgDraw:drawSegment( -- 714
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 714
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 714
		2.8, -- 714
		Color(36, 40, 44, 255) -- 714
	) -- 714
	fgDraw:drawPolygon( -- 716
		{ -- 716
			Vec2(cx - W * 0.42, by + H * 0.36), -- 717
			Vec2(cx + W * 0.38, by + H * 0.42), -- 718
			Vec2(cx + W * 0.34, by + H * 0.78), -- 719
			Vec2(cx - W * 0.38, by + H * 0.72) -- 720
		}, -- 720
		Color(38, 42, 48, 255), -- 721
		1.2, -- 721
		Color(102, 118, 126, 175) -- 721
	) -- 721
	local hx = cx + f * W * 0.42 -- 722
	local hy = by + H * 0.84 -- 723
	fgDraw:drawPolygon( -- 724
		{ -- 724
			Vec2(hx - f * 8, hy - 6), -- 725
			Vec2(hx + f * 12, hy - 2), -- 726
			Vec2(hx + f * 4, hy + 8), -- 727
			Vec2(hx - f * 6, hy + 14) -- 728
		}, -- 728
		Color(44, 48, 54, 255) -- 729
	) -- 729
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 731
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 732
	fgGlow:drawDot( -- 733
		Vec2(hx + f * 4, hy + 2), -- 733
		2.8, -- 733
		toColor(eyeCol, 250) -- 733
	) -- 733
	fillRadialGlow( -- 734
		fgGlow, -- 734
		hx + f * 4, -- 734
		hy + 2, -- 734
		16, -- 734
		16, -- 734
		toColor(eyeCol, alert and 135 or 70), -- 734
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 734
		12 -- 734
	) -- 734
	if alert then -- 734
		local r = 12 + self.animTime * 42 % 24 -- 737
		fgGlow:drawArc( -- 738
			Vec2(hx, hy + 12), -- 738
			r, -- 738
			35, -- 738
			145, -- 738
			1.8, -- 738
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 738
		) -- 738
	end -- 738
end -- 683
return ____exports -- 683