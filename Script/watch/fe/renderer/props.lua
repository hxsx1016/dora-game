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
	if p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 36
		local x = (p.player.x + p.partner.x) * 0.5 -- 38
		local y = p.partner.y + p.partner.h * 0.62 -- 39
		assets:tryPlace( -- 40
			"prop_compass", -- 40
			"handover", -- 40
			cam:sx(x), -- 40
			cam:sy(y), -- 40
			cam:len(12), -- 40
			cam:len(12), -- 40
			{layer = 6} -- 40
		) -- 40
	end -- 40
	if p.room.key == "village" then -- 40
		self:drawVillageProps( -- 43
			fgDraw, -- 43
			fgGlow, -- 43
			assets, -- 43
			p, -- 43
			cam, -- 43
			time -- 43
		) -- 43
	end -- 43
end -- 26
function PropsRenderer.prototype.drawZones(self, fgDraw, fgGlow, p, cam, time) -- 47
	local i = 0 -- 54
	do -- 54
		i = 0 -- 55
		while i < #p.room.zones do -- 55
			local z = p.room.zones[i + 1] -- 56
			local x0 = cam:sx(z.x0) -- 57
			local x1 = cam:sx(z.x1) -- 58
			local y0 = cam:sy(z.y) -- 59
			local y1 = cam:sy(z.y + z.h) -- 60
			local zw = x1 - x0 -- 61
			local zh = math.max(6, y1 - y0) -- 62
			if z.tint == 1 then -- 62
				fillVGradRect( -- 66
					fgGlow, -- 66
					x0, -- 66
					y0, -- 66
					zw, -- 66
					zh, -- 66
					Color(255, 36, 70, 42), -- 66
					Color(255, 36, 70, 6) -- 66
				) -- 66
				fgGlow:drawSegment( -- 67
					Vec2(x0, y0), -- 67
					Vec2(x0, y1), -- 67
					1.4, -- 67
					toColor(PALETTE.crimson, 145) -- 67
				) -- 67
				fgGlow:drawSegment( -- 68
					Vec2(x1, y0), -- 68
					Vec2(x1, y1), -- 68
					1.4, -- 68
					toColor(PALETTE.crimson, 145) -- 68
				) -- 68
				local scanY = y0 + time * 48 % zh -- 69
				fgGlow:drawSegment( -- 70
					Vec2(x0, scanY), -- 70
					Vec2(x1, scanY), -- 70
					1.2, -- 70
					toColor(PALETTE.crimson, 95) -- 70
				) -- 70
			elseif z.tint == 2 then -- 70
				fgDraw:drawRect( -- 73
					Rect(x0, y0 - 4, zw, 8), -- 73
					Color(74, 58, 44, 220) -- 73
				) -- 73
				fgDraw:drawSegment( -- 74
					Vec2(x0, y0 + 2), -- 74
					Vec2(x1, y0 + 2), -- 74
					1.4, -- 74
					Color(128, 98, 72, 190) -- 74
				) -- 74
			elseif z.tint == 3 then -- 74
				fgDraw:drawRect( -- 77
					Rect(x0, y0 - 4, zw, 9), -- 77
					Color(118, 122, 130, 235) -- 77
				) -- 77
				local bricks = 4 -- 78
				local b = 1 -- 79
				do -- 79
					b = 1 -- 80
					while b < bricks do -- 80
						local bx = x0 + zw * b / bricks -- 81
						fgDraw:drawSegment( -- 82
							Vec2(bx, y0 - 4), -- 82
							Vec2(bx, y0 + 5), -- 82
							1, -- 82
							Color(42, 46, 56, 220) -- 82
						) -- 82
						b = b + 1 -- 80
					end -- 80
				end -- 80
				local pulse = 0.65 + 0.35 * math.sin(time * 3.2) -- 84
				fgGlow:drawSegment( -- 85
					Vec2(x0, y0 + 5), -- 85
					Vec2(x1, y0 + 5), -- 85
					1.8, -- 85
					toColor(PALETTE.amber, 165 * pulse) -- 85
				) -- 85
			elseif z.tint == 4 then -- 85
				fillVGradRect( -- 88
					fgGlow, -- 88
					x0, -- 88
					y0, -- 88
					zw, -- 88
					math.min( -- 88
						85, -- 88
						math.max(24, zh) -- 88
					), -- 88
					Color(84, 232, 168, 48), -- 88
					Color(84, 232, 168, 0) -- 88
				) -- 88
				fgGlow:drawSegment( -- 89
					Vec2(x0, y0 + 1), -- 89
					Vec2(x1, y0 + 1), -- 89
					2, -- 89
					toColor(PALETTE.emerald, 190) -- 89
				) -- 89
			end -- 89
			i = i + 1 -- 55
		end -- 55
	end -- 55
	if p.room.key == "checkpoint" then -- 55
		local ex0 = cam:sx(p.ox + 792) -- 95
		local ex1 = cam:sx(p.ox + 928) -- 96
		local ey = cam:sy(0) -- 97
		local col = p.gateOpen and PALETTE.emerald or PALETTE.cyanDim -- 98
		fillVGradRect( -- 99
			fgGlow, -- 99
			ex0, -- 99
			ey, -- 99
			ex1 - ex0, -- 99
			74, -- 99
			toColor(col, p.gateOpen and 68 or 26), -- 99
			Color(col.r, col.g, col.b, 0) -- 99
		) -- 99
		fgGlow:drawSegment( -- 100
			Vec2(ex0, ey + 2), -- 100
			Vec2(ex1, ey + 2), -- 100
			2.4, -- 100
			toColor(col, p.gateOpen and 235 or 130) -- 100
		) -- 100
	end -- 100
end -- 47
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, p, cam, time) -- 104
	local i = 0 -- 111
	do -- 111
		i = 0 -- 112
		while i < #p.room.marks do -- 112
			local m = p.room.marks[i + 1] -- 113
			local mx = cam:sx(m.x) -- 114
			local my = cam:sy(m.y) -- 115
			local pulse = 0.72 + 0.28 * math.sin(time * 3.4 + i) -- 116
			if m.kind == 0 then -- 116
				local on = p.checkpoint == m.x -- 120
				local col = on and PALETTE.emerald or PALETTE.cyanDim -- 121
				fgDraw:drawSegment( -- 122
					Vec2(mx, my), -- 122
					Vec2(mx, my + 48), -- 122
					1.4, -- 122
					toColor(col, on and 220 or 120) -- 122
				) -- 122
				drawDiamond( -- 123
					fgGlow, -- 123
					mx, -- 123
					my + 54, -- 123
					7, -- 123
					10, -- 123
					toColor(col, on and 220 or 120), -- 123
					1.2, -- 123
					toColor(PALETTE.cyanCore, on and 220 or 90) -- 123
				) -- 123
				if on then -- 123
					fillRadialGlow( -- 125
						fgGlow, -- 125
						mx, -- 125
						my + 54, -- 125
						30, -- 125
						30, -- 125
						toColor(PALETTE.emerald, 95), -- 125
						Color(84, 232, 168, 0), -- 125
						14 -- 125
					) -- 125
				end -- 125
			elseif m.kind == 1 then -- 125
				local col = PALETTE.amber -- 129
				fgGlow:drawSegment( -- 130
					Vec2(mx - 14, my + 2), -- 130
					Vec2(mx + 14, my + 2), -- 130
					1.8, -- 130
					toColor(col, 165 * pulse) -- 130
				) -- 130
				drawDiamond( -- 131
					fgGlow, -- 131
					mx, -- 131
					my + 12, -- 131
					4.5, -- 131
					4.5, -- 131
					toColor(col, 185 * pulse) -- 131
				) -- 131
			elseif m.kind == 6 then -- 131
				local topY = my + cam:len(42) -- 134
				fgDraw:drawSegment( -- 135
					Vec2(mx, my), -- 135
					Vec2(mx, topY), -- 135
					2.5, -- 135
					toColor(PALETTE.steelLight) -- 135
				) -- 135
				fgDraw:drawRect( -- 136
					Rect(mx - 7, topY, 14, 16), -- 136
					toColor(PALETTE.steelDark), -- 136
					1.4, -- 136
					toColor(PALETTE.amber, 220) -- 136
				) -- 136
				fgGlow:drawDot( -- 137
					Vec2(mx, topY + 8), -- 137
					4.2, -- 137
					toColor(PALETTE.amberCore) -- 137
				) -- 137
				fillRadialGlow( -- 138
					fgGlow, -- 138
					mx, -- 138
					topY + 8, -- 138
					54 * pulse, -- 138
					54 * pulse, -- 138
					Color(255, 222, 142, 115), -- 138
					Color(255, 180, 82, 0), -- 138
					18 -- 138
				) -- 138
				fillRadialGlow( -- 139
					fgGlow, -- 139
					mx, -- 139
					my + 4, -- 139
					48, -- 139
					12, -- 139
					Color(255, 210, 128, 65), -- 139
					Color(255, 180, 82, 0), -- 139
					14 -- 139
				) -- 139
			end -- 139
			i = i + 1 -- 112
		end -- 112
	end -- 112
end -- 104
function PropsRenderer.prototype.drawCart(self, fgDraw, fgGlow, assets, p, cam, time) -- 144
	local c = p.room.cart -- 152
	if c.bodyW <= 0 then -- 152
		return -- 154
	end -- 154
	local lo = math.min(c.startX, c.endX) -- 158
	local hi = math.max(c.startX, c.endX) -- 159
	if hi - lo > 4 then -- 159
		local rx0 = cam:sx(lo) -- 161
		local rx1 = cam:sx(hi) -- 162
		local ry = cam:sy(c.baseY) -- 163
		fgDraw:drawSegment( -- 164
			Vec2(rx0, ry + 2), -- 164
			Vec2(rx1, ry + 2), -- 164
			1.2, -- 164
			toColor(PALETTE.steelLight, 140) -- 164
		) -- 164
		local dockX = cam:sx(c.endX) -- 165
		local dockCol = p.cartDocked and PALETTE.emerald or PALETTE.amber -- 166
		fgDraw:drawRect( -- 167
			Rect( -- 167
				dockX - cam:len(12), -- 167
				ry - 4, -- 167
				cam:len(24), -- 167
				5 -- 167
			), -- 167
			toColor(PALETTE.voidDark) -- 167
		) -- 167
		fgGlow:drawSegment( -- 168
			Vec2( -- 168
				dockX - cam:len(14), -- 168
				ry + 1 -- 168
			), -- 168
			Vec2( -- 168
				dockX + cam:len(14), -- 168
				ry + 1 -- 168
			), -- 168
			2.4, -- 168
			toColor(dockCol, 220) -- 168
		) -- 168
		drawDiamond( -- 169
			fgGlow, -- 169
			dockX, -- 169
			ry + 12, -- 169
			5, -- 169
			5, -- 169
			toColor(dockCol, p.cartDocked and 235 or 140) -- 169
		) -- 169
	end -- 169
	local axleX = p.cartAxle -- 172
	local cx = cam:sx(axleX) -- 173
	local baseY = cam:sy(c.baseY) -- 174
	local bw = cam:len(c.bodyW) -- 175
	local bh = cam:len(c.bodyH) -- 176
	local wr = cam:len(c.wheelR) -- 177
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
	local painted = assets:tryPlace( -- 187
		"prop_cart", -- 187
		"cart", -- 187
		cx, -- 187
		baseY, -- 187
		bw * 1.36, -- 187
		(c.wheelR * 2 + c.bodyH) * cam.ppu * 0.88, -- 188
		{layer = 2} -- 188
	) -- 188
	if not painted then -- 188
		fillVGradRect( -- 191
			fgDraw, -- 191
			x0, -- 191
			bodyY0, -- 191
			bw, -- 191
			bh, -- 191
			Color(48, 32, 28, 255), -- 191
			toColor(PALETTE.cartWood) -- 191
		) -- 191
		fgDraw:drawRect( -- 192
			Rect(x0, bodyY0, bw, bh), -- 192
			Color(0, 0, 0, 0), -- 192
			1.6, -- 192
			toColor(PALETTE.cartMetal, 220) -- 192
		) -- 192
		fgDraw:drawSegment( -- 194
			Vec2(x0 + bw * 0.33, bodyY0), -- 194
			Vec2(x0 + bw * 0.33, bodyY1), -- 194
			1.4, -- 194
			toColor(PALETTE.cartMetal, 180) -- 194
		) -- 194
		fgDraw:drawSegment( -- 195
			Vec2(x0 + bw * 0.67, bodyY0), -- 195
			Vec2(x0 + bw * 0.67, bodyY1), -- 195
			1.4, -- 195
			toColor(PALETTE.cartMetal, 180) -- 195
		) -- 195
		fgDraw:drawSegment( -- 196
			Vec2(x0 - 2, bodyY1), -- 196
			Vec2(x1 + 2, bodyY1), -- 196
			2.2, -- 196
			toColor(PALETTE.rimSilver, 220) -- 196
		) -- 196
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 199
		local wxA = x0 + bw * 0.24 -- 200
		local wxB = x1 - bw * 0.24 -- 201
		local wy = baseY + wr -- 202
		self:drawWheel( -- 203
			fgDraw, -- 203
			wxA, -- 203
			wy, -- 203
			wr, -- 203
			wheelSpin -- 203
		) -- 203
		self:drawWheel( -- 204
			fgDraw, -- 204
			wxB, -- 204
			wy, -- 204
			wr, -- 204
			wheelSpin -- 204
		) -- 204
	end -- 204
	local hx = cam:sx(axleX + c.handleOffset) -- 208
	local hTop = bodyY1 + cam:len(9) -- 209
	local gripReady = p.gripping or p.focusCart or math.abs(p.player.x - (axleX + c.handleOffset)) < 70 -- 210
	local handleCol = p.gripping and PALETTE.cyan or (gripReady and PALETTE.amber or PALETTE.cartMetal) -- 211
	local edge = c.handleOffset < 0 and x0 or x1 -- 212
	fgDraw:drawSegment( -- 213
		Vec2(edge, bodyY0 + bh * 0.55), -- 213
		Vec2( -- 213
			hx, -- 213
			hTop - cam:len(4) -- 213
		), -- 213
		math.max( -- 214
			2, -- 214
			cam:len(3) -- 214
		), -- 214
		toColor(PALETTE.cartWood) -- 214
	) -- 214
	fgDraw:drawSegment( -- 215
		Vec2( -- 215
			hx, -- 215
			hTop - cam:len(6) -- 215
		), -- 215
		Vec2(hx, hTop), -- 215
		math.max( -- 216
			2, -- 216
			cam:len(4) -- 216
		), -- 216
		toColor(handleCol) -- 216
	) -- 216
	fgGlow:drawDot( -- 217
		Vec2(hx, hTop), -- 217
		gripReady and 4.8 or 3.2, -- 217
		toColor(handleCol, gripReady and 245 or 160) -- 217
	) -- 217
	if gripReady and not p.cartDocked then -- 217
		fillRadialGlow( -- 219
			fgGlow, -- 219
			hx, -- 219
			hTop, -- 219
			22, -- 219
			22, -- 219
			toColor(handleCol, 95), -- 219
			Color(handleCol.r, handleCol.g, handleCol.b, 0), -- 219
			12 -- 219
		) -- 219
	end -- 219
	if painted then -- 219
		return -- 223
	end -- 223
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 226
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 227
	local wave2 = math.cos(time * 2.8) * 3.5 -- 228
	local clothH = cam:len(26) -- 229
	local clothW = cam:len(14) -- 230
	fgDraw:drawPolygon( -- 231
		{ -- 231
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 232
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 233
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 234
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 235
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 236
		}, -- 236
		toColor(PALETTE.clothRed) -- 237
	) -- 237
	fgDraw:drawSegment( -- 239
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 240
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 241
		1.6, -- 242
		toColor(PALETTE.clothRedHighlight, 220) -- 243
	) -- 243
	fillRadialGlow( -- 245
		fgGlow, -- 245
		clothAnchorX, -- 245
		bodyY1 - clothH * 0.35, -- 245
		32, -- 245
		32, -- 245
		Color(235, 42, 62, 54), -- 245
		Color(235, 42, 62, 0), -- 245
		14 -- 245
	) -- 245
end -- 144
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 248
	draw:drawCircle( -- 249
		Vec2(cx, cy), -- 249
		r, -- 249
		Color(24, 28, 36, 255) -- 249
	) -- 249
	draw:drawRing( -- 250
		Vec2(cx, cy), -- 250
		r * 0.72, -- 250
		r, -- 250
		Color(0, 0, 0, 0), -- 250
		1.6, -- 250
		toColor(PALETTE.cartMetal) -- 250
	) -- 250
	local k = 0 -- 251
	do -- 251
		k = 0 -- 252
		while k < 4 do -- 252
			local a = spin + k * math.pi / 4 -- 253
			draw:drawSegment( -- 254
				Vec2( -- 255
					cx - math.cos(a) * r * 0.72, -- 255
					cy - math.sin(a) * r * 0.72 -- 255
				), -- 255
				Vec2( -- 256
					cx + math.cos(a) * r * 0.72, -- 256
					cy + math.sin(a) * r * 0.72 -- 256
				), -- 256
				1.2, -- 257
				toColor(PALETTE.steelLight, 190) -- 258
			) -- 258
			k = k + 1 -- 252
		end -- 252
	end -- 252
	draw:drawDot( -- 261
		Vec2(cx, cy), -- 261
		math.max(2.2, r * 0.18), -- 261
		toColor(PALETTE.rimSilver) -- 261
	) -- 261
end -- 248
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 264
	local bottle = p.room.bottle -- 273
	if bottle ~= nil then -- 273
		local bx0 = cam:sx(bottle.x - 16) -- 275
		local bx1 = cam:sx(bottle.x + 16) -- 276
		local by0 = cam:sy(0) -- 277
		local by1 = cam:sy(64) -- 278
		fgDraw:drawRect( -- 279
			Rect(bx0, by0, bx1 - bx0, by1 - by0), -- 279
			Color(32, 36, 46, 235), -- 279
			1.2, -- 279
			toColor(PALETTE.steelLight, 180) -- 279
		) -- 279
		fgDraw:drawSegment( -- 281
			Vec2(bx0 + 2, by0 + (by1 - by0) * 0.48), -- 281
			Vec2(bx1 - 2, by0 + (by1 - by0) * 0.48), -- 281
			2, -- 281
			toColor(PALETTE.cartWood) -- 281
		) -- 281
		assets:tryPlace( -- 282
			"cover_wood", -- 282
			"village_shelf", -- 282
			(bx0 + bx1) * 0.5, -- 282
			by0, -- 282
			bx1 - bx0, -- 283
			by1 - by0, -- 283
			{layer = 1, opacity = 0.85} -- 283
		) -- 283
		fgDraw:drawSegment( -- 284
			Vec2(bx0, by1), -- 284
			Vec2(bx1, by1), -- 284
			1.3, -- 284
			toColor(PALETTE.rimSilver, 175) -- 284
		) -- 284
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 284
			self:drawBottleSprite( -- 286
				fgDraw, -- 286
				fgGlow, -- 286
				assets, -- 286
				"bottle_shelf", -- 286
				cam:sx(bottle.x), -- 286
				cam:sy(65), -- 286
				cam.ppu, -- 286
				0, -- 286
				true, -- 286
				time -- 286
			) -- 286
		end -- 286
	end -- 286
	local arch = p.room.arch -- 290
	local tx0 = cam:sx(arch.x0 - 4) -- 291
	local tx1 = cam:sx(arch.x1 + 4) -- 292
	local ty0 = cam:sy(arch.y) -- 293
	local tyBot = cam:sy(arch.y + arch.h) -- 294
	local tyTop = cam:sy(arch.y + arch.h + 7) -- 295
	fillVGradRect( -- 296
		fgDraw, -- 296
		tx0 + 6, -- 296
		ty0, -- 296
		tx1 - tx0 - 12, -- 296
		tyBot - ty0, -- 296
		Color(9, 10, 15, 165), -- 297
		Color(9, 10, 15, 100) -- 297
	) -- 297
	if not assets:tryPlace( -- 297
		"prop_table", -- 298
		"village_table", -- 298
		(tx0 + tx1) * 0.5, -- 298
		ty0, -- 298
		tx1 - tx0, -- 299
		tyTop - ty0, -- 299
		{layer = 6} -- 299
	) then -- 299
		fgDraw:drawRect( -- 300
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 300
			toColor(PALETTE.cartWood) -- 300
		) -- 300
		fgDraw:drawRect( -- 301
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 301
			toColor(PALETTE.cartWood) -- 301
		) -- 301
		fgDraw:drawRect( -- 302
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 302
			toColor(PALETTE.cartWood) -- 302
		) -- 302
	end -- 302
	if p.hasBottle then -- 302
		local pl = p.player -- 307
		self:drawBottleSprite( -- 308
			fgDraw, -- 308
			fgGlow, -- 308
			assets, -- 308
			"bottle_held", -- 308
			cam:sx(pl.x + pl.facing * 12), -- 308
			cam:sy(pl.y + pl.h * 0.56), -- 308
			cam.ppu, -- 308
			pl.facing * 0.2, -- 308
			false, -- 308
			time -- 308
		) -- 308
	end -- 308
	if p.bottleFly ~= nil then -- 308
		self:drawBottleSprite( -- 311
			fgDraw, -- 311
			fgGlow, -- 311
			assets, -- 311
			"bottle_air", -- 311
			cam:sx(p.bottleFly.x), -- 311
			cam:sy(p.bottleFly.y), -- 311
			cam.ppu, -- 311
			time * 14, -- 311
			true, -- 311
			time -- 311
		) -- 311
	end -- 311
	if p.hasBottle and p.aimHold > 0 then -- 311
		local pl = p.player -- 316
		local endX = p.bottleAimX -- 317
		local endY = p.bottleAimY -- 318
		if endX < 0 then -- 318
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 320
			endX = wAim.x -- 321
			endY = 0 -- 322
		end -- 322
		local dir = endX >= pl.x and 1 or -1 -- 324
		local x0 = pl.x + dir * 10 -- 325
		local y0 = pl.y + pl.h * 0.7 -- 326
		local T = 0.62 -- 327
		local vx = (endX - x0) / T -- 328
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 329
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 331
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 332
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 333
		local activeAim = p.aimHold > 0.01 -- 334
		local steps = 18 -- 336
		local k = 1 -- 337
		do -- 337
			k = 1 -- 338
			while k <= steps do -- 338
				local tt = k / steps * T -- 339
				local wx = x0 + vx * tt -- 340
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 341
				local sx = cam:sx(wx) -- 342
				local sy = cam:sy(wy) -- 343
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 344
				fgGlow:drawDot( -- 345
					Vec2(sx, sy), -- 345
					activeAim and 3.2 or 2.2, -- 345
					toColor(arcCol, alpha) -- 345
				) -- 345
				k = k + 1 -- 338
			end -- 338
		end -- 338
		local lx = cam:sx(endX) -- 348
		local ly = cam:sy(endY + 2) -- 349
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 350
		fgGlow:drawRing( -- 351
			Vec2(lx, ly), -- 351
			8, -- 351
			11, -- 351
			Color(0, 0, 0, 0), -- 351
			1.6, -- 351
			toColor(arcCol, activeAim and 245 or 165) -- 351
		) -- 351
		if isBrick then -- 351
			fgGlow:drawRing( -- 353
				Vec2(lx, ly), -- 353
				28 * pulse, -- 353
				30 * pulse, -- 353
				Color(0, 0, 0, 0), -- 353
				1.2, -- 353
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 353
			) -- 353
			fillRadialGlow( -- 354
				fgGlow, -- 354
				lx, -- 354
				ly, -- 354
				36, -- 354
				14, -- 354
				Color(242, 188, 96, activeAim and 95 or 48), -- 354
				Color(242, 188, 96, 0), -- 354
				14 -- 354
			) -- 354
		end -- 354
	end -- 354
end -- 264
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, fgGlow, assets, id, cx, cy, ppu, tilt, highlight, time) -- 359
	local height = math.max(12, ppu * 13) -- 367
	if not assets:tryPlace( -- 367
		"prop_bottle", -- 368
		id, -- 368
		cx, -- 368
		cy, -- 368
		height, -- 368
		height, -- 368
		{angle = tilt * 180 / math.pi, layer = 6} -- 368
	) then -- 368
		local dx = math.sin(tilt) * height * 0.4 -- 371
		local dy = math.cos(tilt) * height * 0.5 -- 372
		fgDraw:drawSegment( -- 373
			Vec2(cx - dx, cy - dy), -- 373
			Vec2(cx + dx, cy + dy), -- 373
			height * 0.32, -- 373
			toColor(PALETTE.amber, 225) -- 374
		) -- 374
	end -- 374
	if highlight then -- 374
		local p = 0.7 + 0.3 * math.sin(time * 4.5) -- 377
		fillRadialGlow( -- 378
			fgGlow, -- 378
			cx, -- 378
			cy, -- 378
			18 * p, -- 378
			18 * p, -- 378
			toColor(PALETTE.emerald, 85 * p), -- 378
			Color(84, 232, 168, 0), -- 378
			12 -- 378
		) -- 378
	end -- 378
end -- 359
return ____exports -- 359