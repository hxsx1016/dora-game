-- [ts]: props.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____theme = require("Script.watch.fe.theme") -- 14
local PALETTE = ____theme.PALETTE -- 15
local drawDiamond = ____theme.drawDiamond -- 16
local fillRadialGlow = ____theme.fillRadialGlow -- 18
local fillVGradRect = ____theme.fillVGradRect -- 19
local toColor = ____theme.toColor -- 20
local GRAVITY = 1000 -- 23
____exports.PropsRenderer = __TS__Class() -- 25
local PropsRenderer = ____exports.PropsRenderer -- 25
PropsRenderer.name = "PropsRenderer" -- 25
function PropsRenderer.prototype.____constructor(self) -- 25
end -- 25
function PropsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, time) -- 26
	self:drawZones( -- 34
		fgDraw, -- 34
		fgGlow, -- 34
		p, -- 34
		cam, -- 34
		time -- 34
	) -- 34
	self:drawMarks( -- 35
		fgDraw, -- 35
		fgGlow, -- 35
		p, -- 35
		cam, -- 35
		time -- 35
	) -- 35
	self:drawCart( -- 36
		fgDraw, -- 36
		fgGlow, -- 36
		assets, -- 36
		p, -- 36
		cam, -- 36
		time -- 36
	) -- 36
	if p.room.key == "village" then -- 36
		self:drawVillageProps( -- 38
			fgDraw, -- 38
			fgGlow, -- 38
			p, -- 38
			cam, -- 38
			time -- 38
		) -- 38
	end -- 38
end -- 26
function PropsRenderer.prototype.drawZones(self, fgDraw, fgGlow, p, cam, time) -- 42
	local i = 0 -- 49
	do -- 49
		i = 0 -- 50
		while i < #p.room.zones do -- 50
			local z = p.room.zones[i + 1] -- 51
			local x0 = cam:sx(z.x0) -- 52
			local x1 = cam:sx(z.x1) -- 53
			local y0 = cam:sy(z.y) -- 54
			local y1 = cam:sy(z.y + z.h) -- 55
			local zw = x1 - x0 -- 56
			local zh = math.max(6, y1 - y0) -- 57
			if z.tint == 1 then -- 57
				fillVGradRect( -- 61
					fgGlow, -- 61
					x0, -- 61
					y0, -- 61
					zw, -- 61
					zh, -- 61
					Color(255, 36, 70, 42), -- 61
					Color(255, 36, 70, 6) -- 61
				) -- 61
				fgGlow:drawSegment( -- 62
					Vec2(x0, y0), -- 62
					Vec2(x0, y1), -- 62
					1.4, -- 62
					toColor(PALETTE.crimson, 145) -- 62
				) -- 62
				fgGlow:drawSegment( -- 63
					Vec2(x1, y0), -- 63
					Vec2(x1, y1), -- 63
					1.4, -- 63
					toColor(PALETTE.crimson, 145) -- 63
				) -- 63
				local scanY = y0 + time * 48 % zh -- 64
				fgGlow:drawSegment( -- 65
					Vec2(x0, scanY), -- 65
					Vec2(x1, scanY), -- 65
					1.2, -- 65
					toColor(PALETTE.crimson, 95) -- 65
				) -- 65
			elseif z.tint == 2 then -- 65
				fgDraw:drawRect( -- 68
					Rect(x0, y0 - 4, zw, 8), -- 68
					Color(74, 58, 44, 220) -- 68
				) -- 68
				fgDraw:drawSegment( -- 69
					Vec2(x0, y0 + 2), -- 69
					Vec2(x1, y0 + 2), -- 69
					1.4, -- 69
					Color(128, 98, 72, 190) -- 69
				) -- 69
			elseif z.tint == 3 then -- 69
				fgDraw:drawRect( -- 72
					Rect(x0, y0 - 4, zw, 9), -- 72
					Color(118, 122, 130, 235) -- 72
				) -- 72
				local bricks = 4 -- 73
				local b = 1 -- 74
				do -- 74
					b = 1 -- 75
					while b < bricks do -- 75
						local bx = x0 + zw * b / bricks -- 76
						fgDraw:drawSegment( -- 77
							Vec2(bx, y0 - 4), -- 77
							Vec2(bx, y0 + 5), -- 77
							1, -- 77
							Color(42, 46, 56, 220) -- 77
						) -- 77
						b = b + 1 -- 75
					end -- 75
				end -- 75
				local pulse = 0.65 + 0.35 * math.sin(time * 3.2) -- 79
				fgGlow:drawSegment( -- 80
					Vec2(x0, y0 + 5), -- 80
					Vec2(x1, y0 + 5), -- 80
					1.8, -- 80
					toColor(PALETTE.amber, 165 * pulse) -- 80
				) -- 80
			elseif z.tint == 4 then -- 80
				fillVGradRect( -- 83
					fgGlow, -- 83
					x0, -- 83
					y0, -- 83
					zw, -- 83
					math.min( -- 83
						85, -- 83
						math.max(24, zh) -- 83
					), -- 83
					Color(84, 232, 168, 48), -- 83
					Color(84, 232, 168, 0) -- 83
				) -- 83
				fgGlow:drawSegment( -- 84
					Vec2(x0, y0 + 1), -- 84
					Vec2(x1, y0 + 1), -- 84
					2, -- 84
					toColor(PALETTE.emerald, 190) -- 84
				) -- 84
			end -- 84
			i = i + 1 -- 50
		end -- 50
	end -- 50
	if p.room.key == "checkpoint" then -- 50
		local ex0 = cam:sx(p.ox + 792) -- 90
		local ex1 = cam:sx(p.ox + 928) -- 91
		local ey = cam:sy(0) -- 92
		local col = p.gateOpen and PALETTE.emerald or PALETTE.cyanDim -- 93
		fillVGradRect( -- 94
			fgGlow, -- 94
			ex0, -- 94
			ey, -- 94
			ex1 - ex0, -- 94
			74, -- 94
			toColor(col, p.gateOpen and 68 or 26), -- 94
			Color(col.r, col.g, col.b, 0) -- 94
		) -- 94
		fgGlow:drawSegment( -- 95
			Vec2(ex0, ey + 2), -- 95
			Vec2(ex1, ey + 2), -- 95
			2.4, -- 95
			toColor(col, p.gateOpen and 235 or 130) -- 95
		) -- 95
	end -- 95
end -- 42
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, p, cam, time) -- 99
	local i = 0 -- 106
	do -- 106
		i = 0 -- 107
		while i < #p.room.marks do -- 107
			local m = p.room.marks[i + 1] -- 108
			local mx = cam:sx(m.x) -- 109
			local my = cam:sy(m.y) -- 110
			local pulse = 0.72 + 0.28 * math.sin(time * 3.4 + i) -- 111
			if m.kind == 0 then -- 111
				local on = p.checkpoint == m.x -- 115
				local col = on and PALETTE.emerald or PALETTE.cyanDim -- 116
				fgDraw:drawSegment( -- 117
					Vec2(mx, my), -- 117
					Vec2(mx, my + 48), -- 117
					1.4, -- 117
					toColor(col, on and 220 or 120) -- 117
				) -- 117
				drawDiamond( -- 118
					fgGlow, -- 118
					mx, -- 118
					my + 54, -- 118
					7, -- 118
					10, -- 118
					toColor(col, on and 220 or 120), -- 118
					1.2, -- 118
					toColor(PALETTE.cyanCore, on and 220 or 90) -- 118
				) -- 118
				if on then -- 118
					fillRadialGlow( -- 120
						fgGlow, -- 120
						mx, -- 120
						my + 54, -- 120
						30, -- 120
						30, -- 120
						toColor(PALETTE.emerald, 95), -- 120
						Color(84, 232, 168, 0), -- 120
						14 -- 120
					) -- 120
				end -- 120
			elseif m.kind == 1 then -- 120
				local col = PALETTE.amber -- 124
				fgGlow:drawSegment( -- 125
					Vec2(mx - 14, my + 2), -- 125
					Vec2(mx + 14, my + 2), -- 125
					1.8, -- 125
					toColor(col, 165 * pulse) -- 125
				) -- 125
				drawDiamond( -- 126
					fgGlow, -- 126
					mx, -- 126
					my + 12, -- 126
					4.5, -- 126
					4.5, -- 126
					toColor(col, 185 * pulse) -- 126
				) -- 126
			elseif m.kind == 6 then -- 126
				local topY = my + cam:len(42) -- 129
				fgDraw:drawSegment( -- 130
					Vec2(mx, my), -- 130
					Vec2(mx, topY), -- 130
					2.5, -- 130
					toColor(PALETTE.steelLight) -- 130
				) -- 130
				fgDraw:drawRect( -- 131
					Rect(mx - 7, topY, 14, 16), -- 131
					toColor(PALETTE.steelDark), -- 131
					1.4, -- 131
					toColor(PALETTE.amber, 220) -- 131
				) -- 131
				fgGlow:drawDot( -- 132
					Vec2(mx, topY + 8), -- 132
					4.2, -- 132
					toColor(PALETTE.amberCore) -- 132
				) -- 132
				fillRadialGlow( -- 133
					fgGlow, -- 133
					mx, -- 133
					topY + 8, -- 133
					54 * pulse, -- 133
					54 * pulse, -- 133
					Color(255, 222, 142, 115), -- 133
					Color(255, 180, 82, 0), -- 133
					18 -- 133
				) -- 133
				fillRadialGlow( -- 134
					fgGlow, -- 134
					mx, -- 134
					my + 4, -- 134
					48, -- 134
					12, -- 134
					Color(255, 210, 128, 65), -- 134
					Color(255, 180, 82, 0), -- 134
					14 -- 134
				) -- 134
			end -- 134
			i = i + 1 -- 107
		end -- 107
	end -- 107
end -- 99
function PropsRenderer.prototype.drawCart(self, fgDraw, fgGlow, assets, p, cam, time) -- 139
	local c = p.room.cart -- 147
	if c.bodyW <= 0 then -- 147
		return -- 149
	end -- 149
	local lo = math.min(c.startX, c.endX) -- 153
	local hi = math.max(c.startX, c.endX) -- 154
	if hi - lo > 4 then -- 154
		local rx0 = cam:sx(lo) -- 156
		local rx1 = cam:sx(hi) -- 157
		local ry = cam:sy(c.baseY) -- 158
		fgDraw:drawSegment( -- 159
			Vec2(rx0, ry + 2), -- 159
			Vec2(rx1, ry + 2), -- 159
			1.2, -- 159
			toColor(PALETTE.steelLight, 140) -- 159
		) -- 159
		local dockX = cam:sx(c.endX) -- 160
		local dockCol = p.cartDocked and PALETTE.emerald or PALETTE.amber -- 161
		fgDraw:drawRect( -- 162
			Rect( -- 162
				dockX - cam:len(12), -- 162
				ry - 4, -- 162
				cam:len(24), -- 162
				5 -- 162
			), -- 162
			toColor(PALETTE.voidDark) -- 162
		) -- 162
		fgGlow:drawSegment( -- 163
			Vec2( -- 163
				dockX - cam:len(14), -- 163
				ry + 1 -- 163
			), -- 163
			Vec2( -- 163
				dockX + cam:len(14), -- 163
				ry + 1 -- 163
			), -- 163
			2.4, -- 163
			toColor(dockCol, 220) -- 163
		) -- 163
		drawDiamond( -- 164
			fgGlow, -- 164
			dockX, -- 164
			ry + 12, -- 164
			5, -- 164
			5, -- 164
			toColor(dockCol, p.cartDocked and 235 or 140) -- 164
		) -- 164
	end -- 164
	local axleX = p.cartAxle -- 167
	local cx = cam:sx(axleX) -- 168
	local baseY = cam:sy(c.baseY) -- 169
	local bw = cam:len(c.bodyW) -- 170
	local bh = cam:len(c.bodyH) -- 171
	local wr = cam:len(c.wheelR) -- 172
	if assets:tryPlace( -- 172
		"prop_cart", -- 175
		"cart_" .. p.room.key, -- 175
		cx, -- 175
		baseY, -- 175
		bw * 1.4, -- 175
		(c.wheelR + c.bodyH + 18) * cam.ppu, -- 175
		1, -- 175
		1 -- 175
	) then -- 175
		return -- 176
	end -- 176
	local x0 = cx - bw * 0.5 -- 179
	local x1 = cx + bw * 0.5 -- 180
	local bodyY0 = baseY + wr * 1.05 -- 181
	local bodyY1 = bodyY0 + bh -- 182
	fgDraw:drawEllipse( -- 185
		Vec2(cx, baseY + 2), -- 185
		bw * 0.62, -- 185
		5, -- 185
		Color(4, 6, 10, 150) -- 185
	) -- 185
	fillVGradRect( -- 188
		fgDraw, -- 188
		x0, -- 188
		bodyY0, -- 188
		bw, -- 188
		bh, -- 188
		Color(48, 32, 28, 255), -- 188
		toColor(PALETTE.cartWood) -- 188
	) -- 188
	fgDraw:drawRect( -- 189
		Rect(x0, bodyY0, bw, bh), -- 189
		Color(0, 0, 0, 0), -- 189
		1.6, -- 189
		toColor(PALETTE.cartMetal, 220) -- 189
	) -- 189
	fgDraw:drawSegment( -- 191
		Vec2(x0 + bw * 0.33, bodyY0), -- 191
		Vec2(x0 + bw * 0.33, bodyY1), -- 191
		1.4, -- 191
		toColor(PALETTE.cartMetal, 180) -- 191
	) -- 191
	fgDraw:drawSegment( -- 192
		Vec2(x0 + bw * 0.67, bodyY0), -- 192
		Vec2(x0 + bw * 0.67, bodyY1), -- 192
		1.4, -- 192
		toColor(PALETTE.cartMetal, 180) -- 192
	) -- 192
	fgDraw:drawSegment( -- 193
		Vec2(x0 - 2, bodyY1), -- 193
		Vec2(x1 + 2, bodyY1), -- 193
		2.2, -- 193
		toColor(PALETTE.rimSilver, 220) -- 193
	) -- 193
	local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 196
	local wxA = x0 + bw * 0.24 -- 197
	local wxB = x1 - bw * 0.24 -- 198
	local wy = baseY + wr -- 199
	self:drawWheel( -- 200
		fgDraw, -- 200
		wxA, -- 200
		wy, -- 200
		wr, -- 200
		wheelSpin -- 200
	) -- 200
	self:drawWheel( -- 201
		fgDraw, -- 201
		wxB, -- 201
		wy, -- 201
		wr, -- 201
		wheelSpin -- 201
	) -- 201
	local hx = cam:sx(axleX + c.handleOffset) -- 204
	local hTop = bodyY1 + cam:len(18) -- 205
	local gripReady = p.gripping or p.focusCart or math.abs(p.player.x - (axleX + c.handleOffset)) < 70 -- 206
	local handleCol = p.gripping and PALETTE.cyan or (gripReady and PALETTE.amber or PALETTE.cartMetal) -- 207
	fgDraw:drawSegment( -- 208
		Vec2(hx, bodyY0 + 4), -- 208
		Vec2(hx, hTop), -- 208
		2.6, -- 208
		toColor(handleCol) -- 208
	) -- 208
	fgDraw:drawSegment( -- 209
		Vec2(c.handleOffset < 0 and x0 or x1, bodyY0 + bh * 0.5), -- 209
		Vec2(hx, bodyY0 + bh * 0.55), -- 209
		2.2, -- 209
		toColor(PALETTE.cartMetal) -- 209
	) -- 209
	fgGlow:drawDot( -- 210
		Vec2(hx, hTop), -- 210
		gripReady and 4.8 or 3.2, -- 210
		toColor(handleCol, gripReady and 245 or 160) -- 210
	) -- 210
	if gripReady and not p.cartDocked then -- 210
		fillRadialGlow( -- 212
			fgGlow, -- 212
			hx, -- 212
			hTop, -- 212
			22, -- 212
			22, -- 212
			toColor(handleCol, 95), -- 212
			Color(handleCol.r, handleCol.g, handleCol.b, 0), -- 212
			12 -- 212
		) -- 212
	end -- 212
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 216
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 217
	local wave2 = math.cos(time * 2.8) * 3.5 -- 218
	local clothH = cam:len(26) -- 219
	local clothW = cam:len(14) -- 220
	fgDraw:drawPolygon( -- 221
		{ -- 221
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 222
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 223
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 224
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 225
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 226
		}, -- 226
		toColor(PALETTE.clothRed) -- 227
	) -- 227
	fgDraw:drawSegment( -- 229
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 230
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 231
		1.6, -- 232
		toColor(PALETTE.clothRedHighlight, 220) -- 233
	) -- 233
	fillRadialGlow( -- 235
		fgGlow, -- 235
		clothAnchorX, -- 235
		bodyY1 - clothH * 0.35, -- 235
		32, -- 235
		32, -- 235
		Color(235, 42, 62, 54), -- 235
		Color(235, 42, 62, 0), -- 235
		14 -- 235
	) -- 235
end -- 139
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 238
	draw:drawCircle( -- 239
		Vec2(cx, cy), -- 239
		r, -- 239
		Color(24, 28, 36, 255) -- 239
	) -- 239
	draw:drawRing( -- 240
		Vec2(cx, cy), -- 240
		r * 0.72, -- 240
		r, -- 240
		Color(0, 0, 0, 0), -- 240
		1.6, -- 240
		toColor(PALETTE.cartMetal) -- 240
	) -- 240
	local k = 0 -- 241
	do -- 241
		k = 0 -- 242
		while k < 4 do -- 242
			local a = spin + k * math.pi / 4 -- 243
			draw:drawSegment( -- 244
				Vec2( -- 245
					cx - math.cos(a) * r * 0.72, -- 245
					cy - math.sin(a) * r * 0.72 -- 245
				), -- 245
				Vec2( -- 246
					cx + math.cos(a) * r * 0.72, -- 246
					cy + math.sin(a) * r * 0.72 -- 246
				), -- 246
				1.2, -- 247
				toColor(PALETTE.steelLight, 190) -- 248
			) -- 248
			k = k + 1 -- 242
		end -- 242
	end -- 242
	draw:drawDot( -- 251
		Vec2(cx, cy), -- 251
		math.max(2.2, r * 0.18), -- 251
		toColor(PALETTE.rimSilver) -- 251
	) -- 251
end -- 238
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, p, cam, time) -- 254
	local bottle = p.room.bottle -- 262
	if bottle ~= nil then -- 262
		local bx0 = cam:sx(bottle.x - 16) -- 264
		local bx1 = cam:sx(bottle.x + 16) -- 265
		local by0 = cam:sy(0) -- 266
		local by1 = cam:sy(64) -- 267
		fgDraw:drawRect( -- 268
			Rect(bx0, by0, bx1 - bx0, by1 - by0), -- 268
			Color(32, 36, 46, 235), -- 268
			1.2, -- 268
			toColor(PALETTE.steelLight, 180) -- 268
		) -- 268
		fgDraw:drawSegment( -- 270
			Vec2(bx0 + 2, by0 + (by1 - by0) * 0.48), -- 270
			Vec2(bx1 - 2, by0 + (by1 - by0) * 0.48), -- 270
			2, -- 270
			toColor(PALETTE.cartWood) -- 270
		) -- 270
		fgDraw:drawSegment( -- 271
			Vec2(bx0, by1), -- 271
			Vec2(bx1, by1), -- 271
			2.2, -- 271
			toColor(PALETTE.rimSilver, 210) -- 271
		) -- 271
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 271
			self:drawBottleSprite( -- 273
				fgDraw, -- 273
				fgGlow, -- 273
				cam:sx(bottle.x), -- 273
				cam:sy(65), -- 273
				cam.ppu, -- 273
				0, -- 273
				true, -- 273
				time -- 273
			) -- 273
		end -- 273
	end -- 273
	local tx0 = cam:sx(300) -- 278
	local tx1 = cam:sx(420) -- 279
	local ty0 = cam:sy(0) -- 280
	local tyBot = cam:sy(44) -- 281
	local tyTop = cam:sy(51) -- 282
	fillVGradRect( -- 284
		fgDraw, -- 284
		tx0 + 6, -- 284
		ty0, -- 284
		tx1 - tx0 - 12, -- 284
		tyBot - ty0, -- 284
		Color(5, 7, 12, 185), -- 284
		Color(5, 7, 12, 110) -- 284
	) -- 284
	fgDraw:drawRect( -- 286
		Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 286
		Color(68, 52, 42, 255), -- 286
		1.3, -- 286
		toColor(PALETTE.rimSilver, 185) -- 286
	) -- 286
	fgDraw:drawRect( -- 287
		Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 287
		Color(48, 38, 32, 255) -- 287
	) -- 287
	fgDraw:drawRect( -- 288
		Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 288
		Color(48, 38, 32, 255) -- 288
	) -- 288
	fgDraw:drawSegment( -- 289
		Vec2(tx0, tyTop), -- 289
		Vec2(tx1, tyTop), -- 289
		1.8, -- 289
		toColor(PALETTE.amber, 165) -- 289
	) -- 289
	if p.hasBottle then -- 289
		local pl = p.player -- 293
		self:drawBottleSprite( -- 294
			fgDraw, -- 294
			fgGlow, -- 294
			cam:sx(pl.x + pl.facing * 12), -- 294
			cam:sy(pl.y + pl.h * 0.56), -- 294
			cam.ppu, -- 294
			pl.facing * 0.2, -- 294
			false, -- 294
			time -- 294
		) -- 294
	end -- 294
	if p.bottleFly ~= nil then -- 294
		self:drawBottleSprite( -- 297
			fgDraw, -- 297
			fgGlow, -- 297
			cam:sx(p.bottleFly.x), -- 297
			cam:sy(p.bottleFly.y), -- 297
			cam.ppu, -- 297
			time * 14, -- 297
			true, -- 297
			time -- 297
		) -- 297
	end -- 297
	if p.hasBottle then -- 297
		local pl = p.player -- 302
		local endX = p.bottleAimX -- 303
		local endY = p.bottleAimY -- 304
		if endX < 0 then -- 304
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 306
			endX = wAim.x -- 307
			endY = 0 -- 308
		end -- 308
		local dir = endX >= pl.x and 1 or -1 -- 310
		local x0 = pl.x + dir * 10 -- 311
		local y0 = pl.y + pl.h * 0.7 -- 312
		local T = 0.62 -- 313
		local vx = (endX - x0) / T -- 314
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 315
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 317
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 318
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 319
		local activeAim = p.aimHold > 0.01 -- 320
		local steps = 18 -- 322
		local k = 1 -- 323
		do -- 323
			k = 1 -- 324
			while k <= steps do -- 324
				local tt = k / steps * T -- 325
				local wx = x0 + vx * tt -- 326
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 327
				local sx = cam:sx(wx) -- 328
				local sy = cam:sy(wy) -- 329
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 330
				fgGlow:drawDot( -- 331
					Vec2(sx, sy), -- 331
					activeAim and 3.2 or 2.2, -- 331
					toColor(arcCol, alpha) -- 331
				) -- 331
				k = k + 1 -- 324
			end -- 324
		end -- 324
		local lx = cam:sx(endX) -- 334
		local ly = cam:sy(endY + 2) -- 335
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 336
		fgGlow:drawRing( -- 337
			Vec2(lx, ly), -- 337
			8, -- 337
			11, -- 337
			Color(0, 0, 0, 0), -- 337
			1.6, -- 337
			toColor(arcCol, activeAim and 245 or 165) -- 337
		) -- 337
		if isBrick then -- 337
			fgGlow:drawRing( -- 339
				Vec2(lx, ly), -- 339
				28 * pulse, -- 339
				30 * pulse, -- 339
				Color(0, 0, 0, 0), -- 339
				1.2, -- 339
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 339
			) -- 339
			fillRadialGlow( -- 340
				fgGlow, -- 340
				lx, -- 340
				ly, -- 340
				36, -- 340
				14, -- 340
				Color(242, 188, 96, activeAim and 95 or 48), -- 340
				Color(242, 188, 96, 0), -- 340
				14 -- 340
			) -- 340
		end -- 340
	end -- 340
end -- 254
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, fgGlow, cx, cy, ppu, tilt, highlight, time) -- 345
	local bw = math.max(5, ppu * 3.2) -- 351
	local bh = math.max(12, ppu * 8.5) -- 352
	local dx = math.sin(tilt) * bh * 0.4 -- 353
	local dy = math.cos(tilt) * bh * 0.5 -- 354
	fgDraw:drawSegment( -- 355
		Vec2(cx - dx, cy - dy), -- 355
		Vec2(cx + dx, cy + dy), -- 355
		bw * 0.52, -- 355
		toColor(PALETTE.emerald, 225) -- 355
	) -- 355
	fgDraw:drawSegment( -- 356
		Vec2(cx + dx * 0.7, cy + dy * 0.7), -- 356
		Vec2(cx + dx * 1.25, cy + dy * 1.25), -- 356
		bw * 0.28, -- 356
		toColor(PALETTE.cyanCore, 230) -- 356
	) -- 356
	if highlight then -- 356
		local p = 0.7 + 0.3 * math.sin(time * 4.5) -- 358
		fillRadialGlow( -- 359
			fgGlow, -- 359
			cx, -- 359
			cy, -- 359
			18 * p, -- 359
			18 * p, -- 359
			toColor(PALETTE.emerald, 85 * p), -- 359
			Color(84, 232, 168, 0), -- 359
			12 -- 359
		) -- 359
	end -- 359
end -- 345
return ____exports -- 345