-- [ts]: actors.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local Color = ____Dora.Color -- 13
local Vec2 = ____Dora.Vec2 -- 13
local ____escort = require("Script.watch.escort") -- 15
local FEAR_MAX = ____escort.FEAR_MAX -- 15
local ____theme = require("Script.watch.fe.theme") -- 18
local PALETTE = ____theme.PALETTE -- 18
local drawDiamond = ____theme.drawDiamond -- 18
local fillRadialGlow = ____theme.fillRadialGlow -- 18
local toColor = ____theme.toColor -- 18
____exports.ActorsRenderer = __TS__Class() -- 30
local ActorsRenderer = ____exports.ActorsRenderer -- 30
ActorsRenderer.name = "ActorsRenderer" -- 30
function ActorsRenderer.prototype.____constructor(self) -- 30
	self.ghosts = {} -- 31
	self.ghostCooldown = 0 -- 32
	self.animTime = 0 -- 33
end -- 30
function ActorsRenderer.prototype.reset(self) -- 35
	self.ghosts = {} -- 36
	self.ghostCooldown = 0 -- 37
end -- 35
function ActorsRenderer.prototype.update(self, dt, p) -- 41
	self.animTime = self.animTime + dt -- 42
	if not p.childMode and p.player.rollT > 0 then -- 42
		self.ghostCooldown = self.ghostCooldown - dt -- 45
		if self.ghostCooldown <= 0 then -- 45
			local ____self_ghosts_0 = self.ghosts -- 45
			____self_ghosts_0[#____self_ghosts_0 + 1] = { -- 47
				x = p.player.x, -- 48
				y = p.player.y, -- 49
				h = p.player.h, -- 50
				facing = p.player.facing, -- 51
				life = 0.28, -- 52
				maxLife = 0.28, -- 53
				isRoll = true -- 54
			} -- 54
			self.ghostCooldown = 0.036 -- 56
		end -- 56
	else -- 56
		self.ghostCooldown = 0 -- 59
	end -- 59
	local write = 0 -- 63
	local i = 0 -- 64
	do -- 64
		i = 0 -- 65
		while i < #self.ghosts do -- 65
			local g = self.ghosts[i + 1] -- 66
			g.life = g.life - dt -- 67
			if g.life > 0 then -- 67
				self.ghosts[write + 1] = g -- 69
				write = write + 1 -- 70
			end -- 70
			i = i + 1 -- 65
		end -- 65
	end -- 65
	__TS__ArraySetLength(self.ghosts, write) -- 65
end -- 41
function ActorsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam) -- 76
	self:drawAfterimages(fgGlow, cam) -- 84
	local i = 0 -- 87
	do -- 87
		i = 0 -- 88
		while i < #p.enemies do -- 88
			self:drawEnemy( -- 89
				fgDraw, -- 89
				fgGlow, -- 89
				assets, -- 89
				p.enemies[i + 1], -- 89
				i, -- 89
				p, -- 89
				cam -- 89
			) -- 89
			i = i + 1 -- 88
		end -- 88
	end -- 88
	if p.room.key == "village" and p.room.scavenger ~= nil then -- 88
		self:drawScavenger( -- 94
			fgDraw, -- 94
			fgGlow, -- 94
			assets, -- 94
			p, -- 94
			cam -- 94
		) -- 94
	end -- 94
	if p.room.key == "forest" and p.room.story ~= nil and p.room.story.dog ~= nil then -- 94
		self:drawDog( -- 99
			fgDraw, -- 99
			fgGlow, -- 99
			assets, -- 99
			p, -- 99
			cam -- 99
		) -- 99
	end -- 99
	if p.partner.alive then -- 99
		local partnerIsChild = p.partner.w <= 28 -- 104
		if partnerIsChild then -- 104
			self:drawXiaoman( -- 106
				fgDraw, -- 106
				fgGlow, -- 106
				assets, -- 106
				p.partner, -- 106
				p, -- 106
				cam, -- 106
				false -- 106
			) -- 106
		else -- 106
			self:drawZhouShu( -- 108
				fgDraw, -- 108
				fgGlow, -- 108
				assets, -- 108
				p.partner, -- 108
				p, -- 108
				cam, -- 108
				false -- 108
			) -- 108
		end -- 108
	end -- 108
	if p.player.alive then -- 108
		if p.childMode then -- 108
			self:drawXiaoman( -- 115
				fgDraw, -- 115
				fgGlow, -- 115
				assets, -- 115
				p.player, -- 115
				p, -- 115
				cam, -- 115
				true -- 115
			) -- 115
		else -- 115
			self:drawZhouShu( -- 117
				fgDraw, -- 117
				fgGlow, -- 117
				assets, -- 117
				p.player, -- 117
				p, -- 117
				cam, -- 117
				true -- 117
			) -- 117
		end -- 117
	end -- 117
end -- 76
function ActorsRenderer.prototype.drawAfterimages(self, fgGlow, cam) -- 122
	local i = 0 -- 123
	do -- 123
		i = 0 -- 124
		while i < #self.ghosts do -- 124
			local g = self.ghosts[i + 1] -- 125
			local k = g.life / g.maxLife -- 126
			local cx = cam:sx(g.x) -- 127
			local by = cam:sy(g.y) -- 128
			local h = cam:len(g.h * 0.68) -- 129
			local w = cam:len(28) -- 130
			local f = g.facing -- 131
			fgGlow:drawPolygon( -- 133
				{ -- 133
					Vec2(cx - f * w * 0.9, by + 4), -- 134
					Vec2(cx + f * w * 0.55, by + 6), -- 135
					Vec2(cx + f * w * 0.85, by + h * 0.72), -- 136
					Vec2(cx - f * w * 0.15, by + h), -- 137
					Vec2(cx - f * w * 0.85, by + h * 0.58) -- 138
				}, -- 138
				toColor(PALETTE.cyan, 115 * k) -- 139
			) -- 139
			fgGlow:drawSegment( -- 141
				Vec2(cx - f * w * 1.15, by + h * 0.62), -- 142
				Vec2(cx + f * w * 0.72, by + h * 0.76), -- 143
				2.2 * k, -- 144
				toColor(PALETTE.cyanCore, 165 * k) -- 145
			) -- 145
			i = i + 1 -- 124
		end -- 124
	end -- 124
end -- 122
function ActorsRenderer.prototype.drawZhouShu(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 151
	local cx = cam:sx(a.x) -- 160
	local by = cam:sy(a.y) -- 161
	local H = cam:len(a.h) -- 162
	local W = cam:len(a.w) -- 163
	local f = a.facing -- 164
	local slot = "soldier_idle" -- 167
	if a.rollT > 0 then -- 167
		slot = "soldier_roll" -- 169
	elseif a.covered then -- 169
		slot = "soldier_cover" -- 171
	elseif math.abs(a.vx) > 8 then -- 171
		slot = "soldier_run" -- 173
	end -- 173
	if assets:tryPlace( -- 173
		slot, -- 175
		"actor_soldier", -- 175
		cx, -- 175
		by, -- 175
		W * 1.8, -- 175
		H * 1.05, -- 175
		f, -- 175
		1 -- 175
	) then -- 175
		return -- 176
	end -- 176
	fgDraw:drawEllipse( -- 180
		Vec2(cx, by + 1), -- 180
		H * 0.24, -- 180
		4.5, -- 180
		Color(3, 5, 10, 175) -- 180
	) -- 180
	local speed = math.abs(a.vx) -- 182
	local walking = speed > 10 and a.onGround -- 183
	local stride = walking and math.sin(self.animTime * 12.5) or 0 -- 184
	local bob = walking and math.abs(math.cos(self.animTime * 12.5)) * 3.5 or math.sin(self.animTime * 2.6) * 1.4 -- 185
	local calming = not p.childMode and p.escort.state == "calming" -- 186
	local rolling = a.rollT > 0 -- 187
	local crouching = a.covered or calming or rolling -- 188
	local bodyH = rolling and H * 0.62 or (crouching and H * 0.82 or H) -- 191
	local lean = rolling and f * H * 0.14 or (p.gripping and f * H * 0.1 or (walking and f * 6 or f * 2)) -- 192
	local sw = H * 0.115 -- 193
	local hipY = by + bodyH * 0.44 + bob * 0.4 -- 196
	local kneeY = by + bodyH * 0.23 -- 197
	local stepX = stride * H * 0.15 -- 198
	local legDark = Color(14, 21, 34, 255) -- 199
	local legFront = Color(26, 38, 58, 255) -- 200
	local bkX = cx - f * 4 - stepX * 0.5 -- 202
	local bfX = cx - f * 8 - stepX -- 203
	fgDraw:drawSegment( -- 204
		Vec2(cx - f * 3, hipY), -- 204
		Vec2(bkX, kneeY), -- 204
		H * 0.044, -- 204
		legDark -- 204
	) -- 204
	fgDraw:drawSegment( -- 205
		Vec2(bkX, kneeY), -- 205
		Vec2(bfX, by + 3), -- 205
		H * 0.038, -- 205
		legDark -- 205
	) -- 205
	local fkX = cx + f * 6 + stepX * 0.55 -- 207
	local ffX = cx + f * 7 + stepX -- 208
	fgDraw:drawSegment( -- 209
		Vec2(cx + f * 3, hipY), -- 209
		Vec2(fkX, kneeY), -- 209
		H * 0.048, -- 209
		legFront -- 209
	) -- 209
	fgDraw:drawSegment( -- 210
		Vec2(fkX, kneeY), -- 210
		Vec2(ffX, by + 3), -- 210
		H * 0.042, -- 210
		legFront -- 210
	) -- 210
	fgDraw:drawSegment( -- 212
		Vec2(ffX - f * 2, by + 3), -- 212
		Vec2(ffX + f * 9, by + 3), -- 212
		3.4, -- 212
		Color(42, 60, 86, 255) -- 212
	) -- 212
	fgGlow:drawDot( -- 213
		Vec2(fkX + f * 2, kneeY), -- 213
		2.3, -- 213
		toColor(PALETTE.cyan, 195) -- 213
	) -- 213
	local shY = by + bodyH * 0.8 + bob -- 216
	local coatDrag = -f * (walking and 24 or (rolling and 34 or 14)) + math.sin(self.animTime * 4.4) * 4 -- 217
	fgDraw:drawPolygon( -- 218
		{ -- 218
			Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6), -- 219
			Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4), -- 220
			Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16), -- 221
			Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22) -- 222
		}, -- 222
		Color(16, 26, 42, 248), -- 223
		1.2, -- 223
		Color(64, 118, 164, 195) -- 223
	) -- 223
	fgDraw:drawPolygon( -- 226
		{ -- 226
			Vec2(cx - sw * 0.62 + lean * 0.45, hipY), -- 227
			Vec2(cx + sw * 0.62 + lean * 0.45, hipY), -- 228
			Vec2(cx + sw * 1.05 + lean, shY), -- 229
			Vec2(cx - sw * 0.98 + lean, shY) -- 230
		}, -- 230
		Color(24, 38, 60, 255), -- 231
		1.3, -- 231
		toColor(PALETTE.rimSilver, 190) -- 231
	) -- 231
	fgDraw:drawSegment( -- 233
		Vec2(cx - sw * 0.7 + lean, shY - 2), -- 234
		Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6), -- 235
		2.4, -- 236
		Color(196, 232, 248, 220) -- 237
	) -- 237
	fgDraw:drawPolygon( -- 240
		{ -- 240
			Vec2(cx - sw * 1.18 + lean, shY - 6), -- 241
			Vec2(cx + sw * 1.12 + lean, shY - 3), -- 242
			Vec2(cx + sw * 0.9 + lean, shY + 5), -- 243
			Vec2(cx - sw * 0.95 + lean, shY + 4) -- 244
		}, -- 244
		Color(218, 240, 252, 248) -- 245
	) -- 245
	fgGlow:drawSegment( -- 246
		Vec2(cx - sw * 0.9 + lean, shY - 1), -- 247
		Vec2(cx + sw * 0.95 + lean, shY + 1), -- 248
		1.8, -- 249
		toColor(PALETTE.cyan, 230) -- 250
	) -- 250
	local headR = H * 0.088 -- 254
	local headX = cx + lean + f * 3 -- 255
	local headY = shY + headR * 1.35 -- 256
	fgDraw:drawCircle( -- 257
		Vec2(headX, headY), -- 257
		headR, -- 257
		Color(20, 32, 50, 255) -- 257
	) -- 257
	fgDraw:drawPolygon( -- 259
		{ -- 259
			Vec2(headX - f * headR * 1.18, headY + headR * 0.15), -- 260
			Vec2(headX - f * headR * 0.45, headY + headR * 1.18), -- 261
			Vec2(headX + f * headR * 0.92, headY + headR * 0.72), -- 262
			Vec2(headX + f * headR * 0.25, headY + headR * 0.18) -- 263
		}, -- 263
		Color(224, 244, 255, 245) -- 264
	) -- 264
	local vx0 = headX + f * headR * 0.12 -- 266
	local vx1 = headX + f * headR * 1.05 -- 267
	fgGlow:drawSegment( -- 268
		Vec2(vx0, headY - 1), -- 268
		Vec2(vx1, headY + 1.5), -- 268
		2.5, -- 268
		toColor(PALETTE.cyanCore, 255) -- 268
	) -- 268
	fgGlow:drawSegment( -- 269
		Vec2(vx0 - f * 5, headY - 1), -- 269
		Vec2(vx1 + f * 4, headY + 2), -- 269
		1.1, -- 269
		toColor(PALETTE.cyan, 165) -- 269
	) -- 269
	fillRadialGlow( -- 270
		fgGlow, -- 270
		vx1, -- 270
		headY + 1, -- 270
		18, -- 270
		10, -- 270
		toColor(PALETTE.cyan, 125), -- 270
		Color(72, 224, 255, 0), -- 270
		12 -- 270
	) -- 270
	if isControlled and not calming and not rolling and not p.gripping then -- 270
		local gunPivotX = cx + lean + f * sw * 0.35 -- 274
		local gunPivotY = shY - bodyH * 0.1 -- 275
		local aimDx = f -- 276
		local aimDy = 0 -- 277
		if p.aimX > 0 or p.aimY > 0 then -- 277
			aimDx = p.aimX - gunPivotX -- 279
			aimDy = p.aimY - gunPivotY -- 280
			local dLen = math.sqrt(aimDx * aimDx + aimDy * aimDy) -- 281
			if dLen > 4 then -- 281
				aimDx = aimDx / dLen -- 283
				aimDy = aimDy / dLen -- 284
			end -- 284
		end -- 284
		local barrelLen = H * 0.34 -- 287
		local tipX = gunPivotX + aimDx * barrelLen -- 288
		local tipY = gunPivotY + aimDy * barrelLen -- 289
		local stockX = gunPivotX - aimDx * (H * 0.08) -- 290
		local stockY = gunPivotY - aimDy * (H * 0.08) -- 291
		fgDraw:drawSegment( -- 293
			Vec2(cx + lean, shY - 5), -- 293
			Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), -- 293
			3.6, -- 293
			Color(26, 40, 62, 255) -- 293
		) -- 293
		fgDraw:drawSegment( -- 295
			Vec2(stockX, stockY), -- 295
			Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), -- 295
			4.6, -- 295
			Color(34, 48, 70, 255) -- 295
		) -- 295
		fgDraw:drawSegment( -- 296
			Vec2(gunPivotX, gunPivotY), -- 296
			Vec2(tipX, tipY), -- 296
			2.4, -- 296
			Color(166, 202, 232, 235) -- 296
		) -- 296
		fgGlow:drawSegment( -- 298
			Vec2(gunPivotX + aimDx * 6, gunPivotY + aimDy * 6 + 2.5), -- 299
			Vec2(gunPivotX + aimDx * barrelLen * 0.68, gunPivotY + aimDy * barrelLen * 0.68 + 2.5), -- 300
			1.4, -- 301
			toColor(PALETTE.cyan, 230) -- 302
		) -- 302
		fgGlow:drawDot( -- 304
			Vec2(tipX, tipY), -- 304
			2.6, -- 304
			toColor(PALETTE.cyanCore, 230) -- 304
		) -- 304
	elseif calming then -- 304
		fgDraw:drawSegment( -- 306
			Vec2(cx + lean, shY - 6), -- 306
			Vec2(cx + f * sw * 2.1, shY - 14), -- 306
			3, -- 306
			Color(196, 222, 240, 235) -- 306
		) -- 306
		fgGlow:drawDot( -- 307
			Vec2(cx + f * sw * 2.15, shY - 14), -- 307
			3.6, -- 307
			toColor(PALETTE.amber, 225) -- 307
		) -- 307
	end -- 307
	if a.covered then -- 307
		local shieldX = cx + f * (sw * 1.85) -- 312
		fgGlow:drawSegment( -- 313
			Vec2(shieldX, by + 6), -- 313
			Vec2(shieldX, by + bodyH * 0.92), -- 313
			2.8, -- 313
			toColor(PALETTE.cyan, 240) -- 313
		) -- 313
		fgGlow:drawSegment( -- 314
			Vec2(shieldX - f * 9, by + bodyH * 0.96), -- 314
			Vec2(shieldX + f * 4, by + bodyH * 0.92), -- 314
			2, -- 314
			toColor(PALETTE.cyanCore, 230) -- 314
		) -- 314
		fillRadialGlow( -- 315
			fgGlow, -- 315
			shieldX, -- 315
			by + bodyH * 0.5, -- 315
			20, -- 315
			bodyH * 0.52, -- 315
			toColor(PALETTE.cyan, 82), -- 315
			Color(72, 224, 255, 0), -- 315
			14 -- 315
		) -- 315
	end -- 315
end -- 151
function ActorsRenderer.prototype.drawXiaoman(self, fgDraw, fgGlow, assets, a, p, cam, isControlled) -- 320
	local cx = cam:sx(a.x) -- 329
	local by = cam:sy(a.y) -- 330
	local H = cam:len(a.h) -- 331
	local W = cam:len(a.w) -- 332
	local f = a.facing -- 333
	local afraid = not isControlled and (p.escort.state == "frozen" or p.escort.fear > 0) -- 335
	local slot = "child_idle" -- 336
	if afraid and p.escort.state == "frozen" then -- 336
		slot = "child_fear" -- 338
	elseif a.crouch then -- 338
		slot = "child_crouch" -- 340
	elseif math.abs(a.vx) > 8 then -- 340
		slot = "child_run" -- 342
	end -- 342
	if assets:tryPlace( -- 342
		slot, -- 344
		"actor_child", -- 344
		cx, -- 344
		by, -- 344
		W * 1.75, -- 344
		H * 1.05, -- 344
		f, -- 344
		1 -- 344
	) then -- 344
		return -- 345
	end -- 345
	local jitter = not isControlled and p.escort.state == "frozen" and math.sin(self.animTime * 42) * 2.2 or 0 -- 348
	local x = cx + jitter -- 349
	local fullRef = a.crouch and H * 1.35 or H -- 351
	local cw = fullRef * 0.16 -- 352
	fgDraw:drawEllipse( -- 355
		Vec2(x, by + 1), -- 355
		cw * 1.15, -- 355
		3.6, -- 355
		Color(4, 6, 10, 155) -- 355
	) -- 355
	local speed = math.abs(a.vx) -- 357
	local walking = speed > 6 and a.onGround -- 358
	local stride = walking and math.sin(self.animTime * 11) or 0 -- 359
	local bob = walking and math.abs(math.cos(self.animTime * 11)) * 2.8 or math.sin(self.animTime * 2.8) * 1.1 -- 360
	local hipY = by + H * 0.3 -- 363
	local legSwing = stride * cw * 0.85 -- 364
	fgDraw:drawSegment( -- 365
		Vec2(x - 2, hipY), -- 365
		Vec2(x - legSwing, by + 2), -- 365
		math.max(2.6, cw * 0.22), -- 365
		Color(34, 30, 38, 255) -- 365
	) -- 365
	fgDraw:drawSegment( -- 366
		Vec2(x + 2, hipY), -- 366
		Vec2(x + legSwing, by + 2), -- 366
		math.max(2.8, cw * 0.24), -- 366
		Color(52, 46, 56, 255) -- 366
	) -- 366
	local cloakTopY = by + H * (a.crouch and 0.68 or 0.74) + bob -- 369
	local cloakBotY = by + H * 0.2 -- 370
	local cloakDrag = -f * (walking and 14 or 6) + math.sin(self.animTime * 3.8) * 2.8 -- 371
	fgDraw:drawPolygon( -- 372
		{ -- 372
			Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY), -- 373
			Vec2(x + cw * 0.92, cloakBotY), -- 374
			Vec2(x + cw * 0.62, cloakTopY), -- 375
			Vec2(x - cw * 0.68, cloakTopY) -- 376
		}, -- 376
		Color(214, 166, 94, 255), -- 377
		1.3, -- 377
		Color(252, 232, 192, 225) -- 377
	) -- 377
	fgDraw:drawPolygon( -- 378
		{ -- 378
			Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2), -- 379
			Vec2(x - f * cw * 0.12, cloakBotY + 2), -- 380
			Vec2(x - f * cw * 0.18, cloakTopY - 3), -- 381
			Vec2(x - cw * 0.6, cloakTopY - 2) -- 382
		}, -- 382
		Color(148, 108, 56, 215) -- 383
	) -- 383
	fgDraw:drawSegment( -- 384
		Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), -- 384
		Vec2(x + cw * 0.88, cloakBotY + 3), -- 384
		1.8, -- 384
		toColor(PALETTE.amberCore, 200) -- 384
	) -- 384
	local scarfY = cloakTopY - 2 -- 387
	local smidX = x - f * cw * 0.95 + cloakDrag * 0.55 -- 388
	local smidY = scarfY - 6 + math.sin(self.animTime * 4.5) * 2.5 -- 389
	local sendX = x - f * cw * 1.65 + cloakDrag -- 390
	local sendY = scarfY - 12 + math.cos(self.animTime * 4.8) * 3.5 -- 391
	fgDraw:drawQuadraticBezier( -- 392
		Vec2(x - f * cw * 0.3, scarfY), -- 392
		Vec2(smidX, smidY), -- 392
		Vec2(sendX, sendY), -- 392
		2.8, -- 392
		toColor(PALETTE.amberCore, 235) -- 392
	) -- 392
	local headR = fullRef * (a.crouch and 0.118 or 0.126) -- 395
	local headX = x + f * (a.crouch and 5 or 2) -- 396
	local headY = math.min(by + H - headR - 1, cloakTopY + headR * 0.92) -- 397
	fgDraw:drawCircle( -- 398
		Vec2(headX, headY), -- 398
		headR, -- 398
		Color(240, 222, 198, 255) -- 398
	) -- 398
	fgDraw:drawPolygon( -- 400
		{ -- 400
			Vec2(headX - f * headR * 1.28, headY - headR * 0.72), -- 401
			Vec2(headX - f * headR * 1.48, headY + headR * 0.35), -- 402
			Vec2(headX - f * headR * 0.25, headY + headR * 1.15), -- 403
			Vec2(headX + f * headR * 0.68, headY + headR * 0.82), -- 404
			Vec2(headX - f * headR * 0.18, headY + headR * 0.15), -- 405
			Vec2(headX - f * headR * 0.35, headY - headR * 0.78) -- 406
		}, -- 406
		Color(156, 114, 62, 248), -- 407
		1.1, -- 407
		Color(244, 214, 162, 200) -- 407
	) -- 407
	fgGlow:drawDot( -- 409
		Vec2(headX + f * headR * 0.45, headY + 1), -- 409
		2.2, -- 409
		toColor(PALETTE.amberCore) -- 409
	) -- 409
	local hasCompass = isControlled or p.room.key ~= "prologue" or p.phase ~= "prologue-wait" -- 412
	if hasCompass then -- 412
		local compX = x + f * cw * 0.65 -- 414
		local compY = by + H * 0.48 -- 415
		local glowPulse = 0.78 + 0.22 * math.sin(self.animTime * 3.2) -- 416
		fgGlow:drawDot( -- 417
			Vec2(compX, compY), -- 417
			2.6, -- 417
			toColor(PALETTE.amberCore, 250) -- 417
		) -- 417
		fillRadialGlow( -- 418
			fgGlow, -- 418
			compX, -- 418
			compY, -- 418
			26 * glowPulse, -- 418
			26 * glowPulse, -- 418
			Color(248, 206, 120, 78 * glowPulse), -- 418
			Color(248, 180, 72, 0), -- 418
			14 -- 418
		) -- 418
	end -- 418
	if not isControlled and p.escort.fear > 0 then -- 418
		local topY = by + H + 16 -- 423
		local k = 0 -- 424
		do -- 424
			k = 0 -- 425
			while k < FEAR_MAX do -- 425
				local dx = x + (k - 1) * 14 -- 426
				local lit = k < p.escort.fear -- 427
				local c = p.escort.state == "frozen" and PALETTE.crimson or PALETTE.amber -- 428
				drawDiamond( -- 429
					fgGlow, -- 430
					dx, -- 431
					topY, -- 432
					5, -- 433
					6.5, -- 434
					lit and toColor(c, 235) or Color(60, 72, 92, 90), -- 435
					1.2, -- 436
					toColor(c, lit and 255 or 120) -- 437
				) -- 437
				k = k + 1 -- 425
			end -- 425
		end -- 425
		if p.escort.state == "frozen" then -- 425
			local ringR = 26 + self.animTime * 28 % 22 -- 441
			fgGlow:drawRing( -- 442
				Vec2(x, by + H * 0.45), -- 442
				ringR, -- 442
				ringR + 2, -- 442
				Color(0, 0, 0, 0), -- 442
				1.4, -- 442
				toColor(PALETTE.crimson, 130) -- 442
			) -- 442
		end -- 442
	end -- 442
	if isControlled and walking and not a.crouch and speed > 100 then -- 442
		local r = 10 + self.animTime * 32 % 24 -- 448
		fgGlow:drawRing( -- 449
			Vec2(x, by + 3), -- 449
			r, -- 449
			r + 1.5, -- 449
			Color(0, 0, 0, 0), -- 449
			1.1, -- 449
			toColor(PALETTE.amber, 95 * (1 - r / 36)) -- 449
		) -- 449
	end -- 449
end -- 320
function ActorsRenderer.prototype.drawEnemy(self, fgDraw, fgGlow, assets, e, index, p, cam) -- 454
	local cx = cam:sx(e.x) -- 463
	local by = cam:sy(e.y) -- 464
	local H = cam:len(e.h) -- 465
	local W = cam:len(e.w) -- 466
	local f = p.player.x >= e.x and 1 or -1 -- 467
	local slot = not e.alive and "enemy_down" or (e.warnT > 0 and "enemy_aim" or "enemy_idle") -- 469
	if assets:tryPlace( -- 469
		slot, -- 470
		"actor_enemy_" .. tostring(index), -- 470
		cx, -- 470
		by, -- 470
		W * 1.8, -- 470
		H * 1.05, -- 470
		f, -- 470
		e.alive and 1 or 0.65 -- 470
	) then -- 470
		return -- 471
	end -- 471
	if not e.alive then -- 471
		local flash = e.hitT > 0 and math.min(1, e.hitT / 0.4) or 0 -- 475
		fgDraw:drawPolygon( -- 476
			{ -- 476
				Vec2(cx - H * 0.3, by), -- 477
				Vec2(cx + H * 0.28, by), -- 478
				Vec2(cx + H * 0.2, by + H * 0.14), -- 479
				Vec2(cx - H * 0.24, by + H * 0.11) -- 480
			}, -- 480
			flash > 0.2 and Color(220, 120, 130, 220) or Color(28, 22, 34, 215) -- 481
		) -- 481
		if flash > 0 then -- 481
			fillRadialGlow( -- 483
				fgGlow, -- 483
				cx, -- 483
				by + 12, -- 483
				34 * flash, -- 483
				18 * flash, -- 483
				toColor(PALETTE.crimson, 180 * flash), -- 483
				Color(255, 48, 82, 0), -- 483
				12 -- 483
			) -- 483
		end -- 483
		return -- 485
	end -- 485
	local sw = H * 0.112 -- 488
	fgDraw:drawEllipse( -- 489
		Vec2(cx, by + 1), -- 489
		sw * 1.9, -- 489
		4, -- 489
		Color(4, 6, 10, 165) -- 489
	) -- 489
	local hipY = by + H * 0.44 -- 492
	local kneeY = by + H * 0.23 -- 493
	local shY = by + H * 0.79 -- 494
	fgDraw:drawSegment( -- 495
		Vec2(cx - 5, hipY), -- 495
		Vec2(cx - 7, kneeY), -- 495
		H * 0.044, -- 495
		Color(20, 16, 26, 255) -- 495
	) -- 495
	fgDraw:drawSegment( -- 496
		Vec2(cx - 7, kneeY), -- 496
		Vec2(cx - 8, by + 2), -- 496
		H * 0.038, -- 496
		Color(20, 16, 26, 255) -- 496
	) -- 496
	fgDraw:drawSegment( -- 497
		Vec2(cx + 5, hipY), -- 497
		Vec2(cx + 7, kneeY), -- 497
		H * 0.046, -- 497
		Color(28, 22, 36, 255) -- 497
	) -- 497
	fgDraw:drawSegment( -- 498
		Vec2(cx + 7, kneeY), -- 498
		Vec2(cx + 8, by + 2), -- 498
		H * 0.04, -- 498
		Color(28, 22, 36, 255) -- 498
	) -- 498
	fgDraw:drawPolygon( -- 500
		{ -- 500
			Vec2(cx - sw * 0.68, hipY), -- 501
			Vec2(cx + sw * 0.68, hipY), -- 502
			Vec2(cx + sw * 1.12, shY), -- 503
			Vec2(cx - sw * 1.12, shY) -- 504
		}, -- 504
		Color(30, 22, 36, 255), -- 505
		1.3, -- 505
		Color(134, 52, 72, 210) -- 505
	) -- 505
	fgDraw:drawPolygon( -- 507
		{ -- 507
			Vec2(cx - sw * 1.26, shY - 6), -- 508
			Vec2(cx + sw * 1.26, shY - 6), -- 509
			Vec2(cx + sw * 0.96, shY + 5), -- 510
			Vec2(cx - sw * 0.96, shY + 5) -- 511
		}, -- 511
		Color(44, 28, 44, 255), -- 512
		1.2, -- 512
		toColor(PALETTE.crimson, 200) -- 512
	) -- 512
	local headR = H * 0.086 -- 515
	local headY = shY + headR * 1.32 -- 516
	fgDraw:drawPolygon( -- 517
		{ -- 517
			Vec2(cx - headR * 0.95, headY - headR * 0.8), -- 518
			Vec2(cx + headR * 0.95, headY - headR * 0.8), -- 519
			Vec2(cx + headR * 0.65, headY + headR * 1.05), -- 520
			Vec2(cx - headR * 0.65, headY + headR * 1.05) -- 521
		}, -- 521
		Color(22, 16, 28, 255), -- 522
		1.1, -- 522
		Color(138, 48, 68, 220) -- 522
	) -- 522
	fgGlow:drawSegment( -- 523
		Vec2(cx + f * 1, headY), -- 524
		Vec2(cx + f * headR * 0.98, headY + 1.5), -- 525
		2.5, -- 526
		toColor(PALETTE.crimson, 255) -- 527
	) -- 527
	fillRadialGlow( -- 529
		fgGlow, -- 529
		cx + f * headR * 0.6, -- 529
		headY + 1, -- 529
		18, -- 529
		10, -- 529
		toColor(PALETTE.crimson, 125), -- 529
		Color(255, 48, 82, 0), -- 529
		12 -- 529
	) -- 529
	local gunX = cx + f * H * 0.34 -- 532
	local gunY = by + H * 0.69 -- 533
	fgDraw:drawSegment( -- 534
		Vec2(cx - f * 6, gunY), -- 534
		Vec2(gunX, gunY), -- 534
		3.6, -- 534
		Color(46, 34, 52, 255) -- 534
	) -- 534
	fgGlow:drawDot( -- 535
		Vec2(gunX, gunY), -- 535
		2.4, -- 535
		toColor(PALETTE.crimson, 220) -- 535
	) -- 535
	if e.warnT > 0 then -- 535
		local urgency = 1 - math.min(1, e.warnT / 36) -- 539
		local tx = cam:sx(p.player.x) -- 540
		local ty = cam:sy(p.player.y + p.player.h * 0.56) -- 541
		local flash = e.warnT < 10 and 0.55 + 0.45 * math.sin(self.animTime * 48) or 1 -- 542
		fgGlow:drawSegment( -- 544
			Vec2(gunX, gunY), -- 544
			Vec2(tx, ty), -- 544
			3.2 * (0.6 + urgency * 0.7), -- 544
			toColor(PALETTE.crimson, 85 * flash) -- 544
		) -- 544
		fgGlow:drawSegment( -- 545
			Vec2(gunX, gunY), -- 545
			Vec2(tx, ty), -- 545
			1.2, -- 545
			toColor(PALETTE.crimsonCore, 235 * flash) -- 545
		) -- 545
		local retR = 18 - urgency * 11 -- 547
		drawDiamond( -- 548
			fgGlow, -- 548
			gunX, -- 548
			gunY, -- 548
			retR, -- 548
			retR, -- 548
			Color(255, 48, 82, 40), -- 548
			1.6, -- 548
			toColor(PALETTE.crimson, 240 * flash) -- 548
		) -- 548
		fillRadialGlow( -- 549
			fgGlow, -- 549
			gunX, -- 549
			gunY, -- 549
			24, -- 549
			24, -- 549
			toColor(PALETTE.crimson, 140 * flash), -- 549
			Color(255, 48, 82, 0), -- 549
			14 -- 549
		) -- 549
	end -- 549
end -- 454
function ActorsRenderer.prototype.drawScavenger(self, fgDraw, fgGlow, assets, p, cam) -- 554
	local s = p.room.scavenger -- 561
	if s == nil then -- 561
		return -- 563
	end -- 563
	local cx = cam:sx(p.scavX) -- 565
	local by = cam:sy(s.y) -- 566
	local H = cam:len(s.h) -- 567
	local W = cam:len(26) -- 568
	local f = p.scavState == "chase" and (p.player.x >= p.scavX and 1 or -1) or p.scavDir -- 569
	local alert = p.scavChase or p.scavSee > 0 -- 572
	local coneCol = alert and PALETTE.crimson or PALETTE.amber -- 573
	local eyeY = by + H * 0.8 -- 574
	local coneLen = cam:len(alert and 155 or 115) -- 575
	fgGlow:drawVertices({ -- 576
		{ -- 577
			Vec2(cx + f * 6, eyeY), -- 577
			toColor(coneCol, alert and 78 or 34) -- 577
		}, -- 577
		{ -- 578
			Vec2(cx + f * coneLen, by + H * 1.05), -- 578
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 578
		}, -- 578
		{ -- 579
			Vec2(cx + f * coneLen, by + 4), -- 579
			Color(coneCol.r, coneCol.g, coneCol.b, 0) -- 579
		} -- 579
	}) -- 579
	if assets:tryPlace( -- 579
		"scavenger", -- 582
		"actor_scav", -- 582
		cx, -- 582
		by, -- 582
		W * 1.8, -- 582
		H * 1.05, -- 582
		f, -- 582
		1 -- 582
	) then -- 582
		return -- 583
	end -- 583
	fgDraw:drawEllipse( -- 586
		Vec2(cx, by + 1), -- 586
		W * 0.62, -- 586
		4, -- 586
		Color(4, 6, 10, 155) -- 586
	) -- 586
	local walk = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 587
	local stride = walk and math.sin(self.animTime * (p.scavState == "chase" and 13 or 7)) * W * 0.36 or 0 -- 588
	fgDraw:drawSegment( -- 590
		Vec2(cx - 4, by + H * 0.4), -- 590
		Vec2(cx - stride, by + 2), -- 590
		W * 0.16, -- 590
		Color(32, 30, 28, 255) -- 590
	) -- 590
	fgDraw:drawSegment( -- 591
		Vec2(cx + 4, by + H * 0.4), -- 591
		Vec2(cx + stride, by + 2), -- 591
		W * 0.16, -- 591
		Color(44, 40, 36, 255) -- 591
	) -- 591
	fgDraw:drawPolygon( -- 593
		{ -- 593
			Vec2(cx - W * 0.45, by + H * 0.25), -- 594
			Vec2(cx + W * 0.42, by + H * 0.25), -- 595
			Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78), -- 596
			Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74) -- 597
		}, -- 597
		Color(56, 52, 46, 255), -- 598
		1.2, -- 598
		Color(128, 118, 100, 180) -- 598
	) -- 598
	local headX = cx + f * 5 -- 600
	local headY = by + H * 0.88 -- 601
	fgDraw:drawCircle( -- 602
		Vec2(headX, headY), -- 602
		W * 0.3, -- 602
		Color(42, 38, 34, 255) -- 602
	) -- 602
	fgGlow:drawDot( -- 603
		Vec2(headX + f * 6, headY), -- 603
		3, -- 603
		toColor(coneCol, 245) -- 603
	) -- 603
	local indY = by + H + 18 -- 606
	if p.scavChase then -- 606
		drawDiamond( -- 608
			fgGlow, -- 608
			cx, -- 608
			indY, -- 608
			9, -- 608
			12, -- 608
			toColor(PALETTE.crimson, 240), -- 608
			1.5, -- 608
			toColor(PALETTE.crimsonCore) -- 608
		) -- 608
	elseif p.scavSee > 0 then -- 608
		local frac = math.min(1, p.scavSee / 24) -- 610
		fgGlow:drawArc( -- 611
			Vec2(cx, indY), -- 611
			11, -- 611
			90, -- 611
			90 - 360 * frac, -- 611
			2.4, -- 611
			toColor(PALETTE.crimson, 235) -- 611
		) -- 611
		fgGlow:drawDot( -- 612
			Vec2(cx, indY), -- 612
			3, -- 612
			toColor(PALETTE.amber) -- 612
		) -- 612
	elseif p.scavState == "turn" or p.scavState == "walk" then -- 612
		drawDiamond( -- 614
			fgGlow, -- 614
			cx, -- 614
			indY, -- 614
			6, -- 614
			8, -- 614
			toColor(PALETTE.amber, 220) -- 614
		) -- 614
	end -- 614
end -- 554
function ActorsRenderer.prototype.drawDog(self, fgDraw, fgGlow, assets, p, cam) -- 619
	local cx = cam:sx(p.dogX) -- 626
	local by = cam:sy(0) -- 627
	local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 628
	local W = cam:len(34) -- 629
	local H = cam:len(28) -- 630
	if assets:tryPlace( -- 630
		"dog", -- 632
		"actor_dog", -- 632
		cx, -- 632
		by, -- 632
		W * 1.4, -- 632
		H * 1.2, -- 632
		f, -- 632
		1 -- 632
	) then -- 632
		return -- 633
	end -- 633
	fgDraw:drawEllipse( -- 636
		Vec2(cx, by + 1), -- 636
		W * 0.56, -- 636
		3.5, -- 636
		Color(4, 8, 10, 155) -- 636
	) -- 636
	local running = p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back" -- 637
	local gallop = running and math.sin(self.animTime * (p.dogState == "chase" and 18 or 10)) * 9 or 0 -- 638
	fgDraw:drawSegment( -- 641
		Vec2(cx - f * W * 0.28, by + H * 0.48), -- 641
		Vec2(cx - f * W * 0.36 - gallop, by + 2), -- 641
		2.8, -- 641
		Color(26, 30, 34, 255) -- 641
	) -- 641
	fgDraw:drawSegment( -- 642
		Vec2(cx + f * W * 0.28, by + H * 0.48), -- 642
		Vec2(cx + f * W * 0.34 + gallop, by + 2), -- 642
		2.8, -- 642
		Color(36, 40, 44, 255) -- 642
	) -- 642
	fgDraw:drawPolygon( -- 644
		{ -- 644
			Vec2(cx - W * 0.42, by + H * 0.36), -- 645
			Vec2(cx + W * 0.38, by + H * 0.42), -- 646
			Vec2(cx + W * 0.34, by + H * 0.78), -- 647
			Vec2(cx - W * 0.38, by + H * 0.72) -- 648
		}, -- 648
		Color(38, 42, 48, 255), -- 649
		1.2, -- 649
		Color(102, 118, 126, 175) -- 649
	) -- 649
	local hx = cx + f * W * 0.42 -- 650
	local hy = by + H * 0.84 -- 651
	fgDraw:drawPolygon( -- 652
		{ -- 652
			Vec2(hx - f * 8, hy - 6), -- 653
			Vec2(hx + f * 12, hy - 2), -- 654
			Vec2(hx + f * 4, hy + 8), -- 655
			Vec2(hx - f * 6, hy + 14) -- 656
		}, -- 656
		Color(44, 48, 54, 255) -- 657
	) -- 657
	local alert = p.dogState == "ear" or p.dogState == "chase" -- 659
	local eyeCol = alert and PALETTE.crimson or PALETTE.amber -- 660
	fgGlow:drawDot( -- 661
		Vec2(hx + f * 4, hy + 2), -- 661
		2.8, -- 661
		toColor(eyeCol, 250) -- 661
	) -- 661
	fillRadialGlow( -- 662
		fgGlow, -- 662
		hx + f * 4, -- 662
		hy + 2, -- 662
		16, -- 662
		16, -- 662
		toColor(eyeCol, alert and 135 or 70), -- 662
		Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), -- 662
		12 -- 662
	) -- 662
	if alert then -- 662
		local r = 12 + self.animTime * 42 % 24 -- 665
		fgGlow:drawArc( -- 666
			Vec2(hx, hy + 12), -- 666
			r, -- 666
			35, -- 666
			145, -- 666
			1.8, -- 666
			toColor(PALETTE.crimson, 210 * (1 - r / 38)) -- 666
		) -- 666
	end -- 666
end -- 619
return ____exports -- 619