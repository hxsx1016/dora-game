-- [ts]: props.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____occlusion = require("Script.watch.fe.occlusion") -- 14
local depthOrder = ____occlusion.depthOrder -- 14
local occlusionTint = ____occlusion.occlusionTint -- 14
local ____theme = require("Script.watch.fe.theme") -- 15
local PALETTE = ____theme.PALETTE -- 16
local drawDiamond = ____theme.drawDiamond -- 17
local fillRadialGlow = ____theme.fillRadialGlow -- 19
local fillVGradRect = ____theme.fillVGradRect -- 20
local toColor = ____theme.toColor -- 21
local GRAVITY = 1000 -- 24
____exports.PropsRenderer = __TS__Class() -- 26
local PropsRenderer = ____exports.PropsRenderer -- 26
PropsRenderer.name = "PropsRenderer" -- 26
function PropsRenderer.prototype.____constructor(self) -- 26
end -- 26
function PropsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 27
	self:drawZones( -- 37
		fgDraw, -- 37
		fgGlow, -- 37
		p, -- 37
		cam, -- 37
		time -- 37
	) -- 37
	self:drawMarks( -- 38
		fgDraw, -- 38
		fgGlow, -- 38
		p, -- 38
		cam, -- 38
		time -- 38
	) -- 38
	self:drawCart( -- 39
		fgDraw, -- 39
		fgGlow, -- 39
		assets, -- 39
		p, -- 39
		cam, -- 39
		time, -- 39
		occlusion, -- 39
		fadeDt -- 39
	) -- 39
	if p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 39
		local x = (p.player.x + p.partner.x) * 0.5 -- 41
		local y = p.partner.y + p.partner.h * 0.62 -- 42
		local depth = (p.player.depth + p.partner.depth) * 0.5 -- 43
		assets:tryPlace( -- 44
			"prop_compass", -- 44
			"handover", -- 44
			cam:sx(x), -- 44
			cam:sy(y, depth), -- 44
			cam:len(12), -- 44
			cam:len(12), -- 44
			{layer = p.room.depth == nil and 6 or depthOrder(depth, 6)} -- 45
		) -- 45
	end -- 45
	if p.room.key == "village" then -- 45
		self:drawVillageProps( -- 48
			fgDraw, -- 48
			fgGlow, -- 48
			assets, -- 48
			p, -- 48
			cam, -- 48
			time -- 48
		) -- 48
	end -- 48
end -- 27
function PropsRenderer.prototype.drawZones(self, fgDraw, fgGlow, p, cam, time) -- 52
	local i = 0 -- 59
	do -- 59
		i = 0 -- 60
		while i < #p.room.zones do -- 60
			do -- 60
				local z = p.room.zones[i + 1] -- 61
				local x0 = cam:sx(z.x0) -- 62
				local x1 = cam:sx(z.x1) -- 63
				local y0 = cam:sy(z.y) -- 64
				local y1 = cam:sy(z.y + z.h) -- 65
				local zw = x1 - x0 -- 66
				local zh = math.max(6, y1 - y0) -- 67
				if z.tint == 1 then -- 67
					local road = p.room.depth -- 70
					if road ~= nil then -- 70
						local front = cam:sy(z.y, road.min) -- 72
						local back = cam:sy(z.y, road.max) -- 73
						fgGlow:drawRect( -- 74
							Rect(x0, front, zw, back - front), -- 74
							Color(141, 56, 64, 24), -- 74
							1, -- 75
							Color(166, 75, 75, 57) -- 75
						) -- 75
						goto __continue8 -- 76
					end -- 76
					fillVGradRect( -- 79
						fgGlow, -- 79
						x0, -- 79
						y0, -- 79
						zw, -- 79
						zh, -- 79
						Color(255, 36, 70, 42), -- 79
						Color(255, 36, 70, 6) -- 79
					) -- 79
					fgGlow:drawSegment( -- 80
						Vec2(x0, y0), -- 80
						Vec2(x0, y1), -- 80
						1.4, -- 80
						toColor(PALETTE.crimson, 145) -- 80
					) -- 80
					fgGlow:drawSegment( -- 81
						Vec2(x1, y0), -- 81
						Vec2(x1, y1), -- 81
						1.4, -- 81
						toColor(PALETTE.crimson, 145) -- 81
					) -- 81
					local scanY = y0 + time * 48 % zh -- 82
					fgGlow:drawSegment( -- 83
						Vec2(x0, scanY), -- 83
						Vec2(x1, scanY), -- 83
						1.2, -- 83
						toColor(PALETTE.crimson, 95) -- 83
					) -- 83
				elseif z.tint == 2 then -- 83
					fgDraw:drawRect( -- 86
						Rect(x0, y0 - 4, zw, 8), -- 86
						Color(74, 58, 44, 220) -- 86
					) -- 86
					fgDraw:drawSegment( -- 87
						Vec2(x0, y0 + 2), -- 87
						Vec2(x1, y0 + 2), -- 87
						1.4, -- 87
						Color(128, 98, 72, 190) -- 87
					) -- 87
				elseif z.tint == 3 then -- 87
					fgDraw:drawRect( -- 90
						Rect(x0, y0 - 4, zw, 9), -- 90
						Color(118, 122, 130, 235) -- 90
					) -- 90
					local bricks = 4 -- 91
					local b = 1 -- 92
					do -- 92
						b = 1 -- 93
						while b < bricks do -- 93
							local bx = x0 + zw * b / bricks -- 94
							fgDraw:drawSegment( -- 95
								Vec2(bx, y0 - 4), -- 95
								Vec2(bx, y0 + 5), -- 95
								1, -- 95
								Color(42, 46, 56, 220) -- 95
							) -- 95
							b = b + 1 -- 93
						end -- 93
					end -- 93
					local pulse = 0.65 + 0.35 * math.sin(time * 3.2) -- 97
					fgGlow:drawSegment( -- 98
						Vec2(x0, y0 + 5), -- 98
						Vec2(x1, y0 + 5), -- 98
						1.8, -- 98
						toColor(PALETTE.amber, 165 * pulse) -- 98
					) -- 98
				elseif z.tint == 4 then -- 98
					fillVGradRect( -- 101
						fgGlow, -- 101
						x0, -- 101
						y0, -- 101
						zw, -- 101
						math.min( -- 101
							85, -- 101
							math.max(24, zh) -- 101
						), -- 101
						Color(84, 232, 168, 48), -- 101
						Color(84, 232, 168, 0) -- 101
					) -- 101
					fgGlow:drawSegment( -- 102
						Vec2(x0, y0 + 1), -- 102
						Vec2(x1, y0 + 1), -- 102
						2, -- 102
						toColor(PALETTE.emerald, 190) -- 102
					) -- 102
				end -- 102
			end -- 102
			::__continue8:: -- 102
			i = i + 1 -- 60
		end -- 60
	end -- 60
	if p.room.key == "checkpoint" then -- 60
		local ex0 = cam:sx(p.ox + 792) -- 108
		local ex1 = cam:sx(p.ox + 928) -- 109
		local ey = cam:sy(0) -- 110
		local col = p.gateOpen and PALETTE.emerald or PALETTE.cyanDim -- 111
		fillVGradRect( -- 112
			fgGlow, -- 112
			ex0, -- 112
			ey, -- 112
			ex1 - ex0, -- 112
			74, -- 112
			toColor(col, p.gateOpen and 68 or 26), -- 112
			Color(col.r, col.g, col.b, 0) -- 112
		) -- 112
		fgGlow:drawSegment( -- 113
			Vec2(ex0, ey + 2), -- 113
			Vec2(ex1, ey + 2), -- 113
			2.4, -- 113
			toColor(col, p.gateOpen and 235 or 130) -- 113
		) -- 113
	end -- 113
end -- 52
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, p, cam, time) -- 117
	local i = 0 -- 124
	do -- 124
		i = 0 -- 125
		while i < #p.room.marks do -- 125
			local m = p.room.marks[i + 1] -- 126
			local mx = cam:sx(m.x) -- 127
			local my = cam:sy(m.y) -- 128
			local pulse = 0.72 + 0.28 * math.sin(time * 3.4 + i) -- 129
			if m.kind == 0 then -- 129
				local on = p.checkpoint == m.x -- 133
				local col = on and PALETTE.emerald or PALETTE.cyanDim -- 134
				fgDraw:drawSegment( -- 135
					Vec2(mx, my), -- 135
					Vec2(mx, my + 48), -- 135
					1.4, -- 135
					toColor(col, on and 220 or 120) -- 135
				) -- 135
				drawDiamond( -- 136
					fgGlow, -- 136
					mx, -- 136
					my + 54, -- 136
					7, -- 136
					10, -- 136
					toColor(col, on and 220 or 120), -- 136
					1.2, -- 136
					toColor(PALETTE.cyanCore, on and 220 or 90) -- 136
				) -- 136
				if on then -- 136
					fillRadialGlow( -- 138
						fgGlow, -- 138
						mx, -- 138
						my + 54, -- 138
						30, -- 138
						30, -- 138
						toColor(PALETTE.emerald, 95), -- 138
						Color(84, 232, 168, 0), -- 138
						14 -- 138
					) -- 138
				end -- 138
			elseif m.kind == 1 then -- 138
				local col = PALETTE.amber -- 142
				fgGlow:drawSegment( -- 143
					Vec2(mx - 14, my + 2), -- 143
					Vec2(mx + 14, my + 2), -- 143
					1.8, -- 143
					toColor(col, 165 * pulse) -- 143
				) -- 143
				drawDiamond( -- 144
					fgGlow, -- 144
					mx, -- 144
					my + 12, -- 144
					4.5, -- 144
					4.5, -- 144
					toColor(col, 185 * pulse) -- 144
				) -- 144
			elseif m.kind == 6 then -- 144
				local topY = my + cam:len(42) -- 147
				fgDraw:drawSegment( -- 148
					Vec2(mx, my), -- 148
					Vec2(mx, topY), -- 148
					2.5, -- 148
					toColor(PALETTE.steelLight) -- 148
				) -- 148
				fgDraw:drawRect( -- 149
					Rect(mx - 7, topY, 14, 16), -- 149
					toColor(PALETTE.steelDark), -- 149
					1.4, -- 149
					toColor(PALETTE.amber, 220) -- 149
				) -- 149
				fgGlow:drawDot( -- 150
					Vec2(mx, topY + 8), -- 150
					4.2, -- 150
					toColor(PALETTE.amberCore) -- 150
				) -- 150
				fillRadialGlow( -- 151
					fgGlow, -- 151
					mx, -- 151
					topY + 8, -- 151
					54 * pulse, -- 151
					54 * pulse, -- 151
					Color(255, 222, 142, 115), -- 151
					Color(255, 180, 82, 0), -- 151
					18 -- 151
				) -- 151
				fillRadialGlow( -- 152
					fgGlow, -- 152
					mx, -- 152
					my + 4, -- 152
					48, -- 152
					12, -- 152
					Color(255, 210, 128, 65), -- 152
					Color(255, 180, 82, 0), -- 152
					14 -- 152
				) -- 152
			end -- 152
			i = i + 1 -- 125
		end -- 125
	end -- 125
end -- 117
function PropsRenderer.prototype.drawCart(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 157
	local c = p.room.cart -- 167
	if c.bodyW <= 0 then -- 167
		return -- 169
	end -- 169
	local depth = c.depth or 0 -- 171
	local raised = p.room.depth ~= nil -- 172
	local lo = math.min(c.startX, c.endX) -- 175
	local hi = math.max(c.startX, c.endX) -- 176
	if hi - lo > 4 then -- 176
		local rx0 = cam:sx(lo) -- 178
		local rx1 = cam:sx(hi) -- 179
		local ry = cam:sy(c.baseY, depth) -- 180
		fgDraw:drawSegment( -- 181
			Vec2(rx0, ry + 2), -- 181
			Vec2(rx1, ry + 2), -- 181
			1.2, -- 181
			toColor(PALETTE.steelLight, 140) -- 181
		) -- 181
		local dockX = cam:sx(c.endX) -- 182
		local dockCol = p.cartDocked and PALETTE.emerald or PALETTE.amber -- 183
		fgDraw:drawRect( -- 184
			Rect( -- 184
				dockX - cam:len(12), -- 184
				ry - 4, -- 184
				cam:len(24), -- 184
				5 -- 184
			), -- 184
			toColor(PALETTE.voidDark) -- 184
		) -- 184
		fgGlow:drawSegment( -- 185
			Vec2( -- 185
				dockX - cam:len(14), -- 185
				ry + 1 -- 185
			), -- 185
			Vec2( -- 185
				dockX + cam:len(14), -- 185
				ry + 1 -- 185
			), -- 185
			2.4, -- 185
			toColor(dockCol, 220) -- 185
		) -- 185
		drawDiamond( -- 186
			fgGlow, -- 186
			dockX, -- 186
			ry + 12, -- 186
			5, -- 186
			5, -- 186
			toColor(dockCol, p.cartDocked and 235 or 140) -- 186
		) -- 186
	end -- 186
	local axleX = p.cartAxle -- 189
	local cx = cam:sx(axleX) -- 190
	local baseY = cam:sy(c.baseY, depth) -- 191
	local bw = cam:len(c.bodyW) -- 192
	local bh = cam:len(c.bodyH) -- 193
	local wr = cam:len(c.wheelR) -- 194
	local x0 = cx - bw * 0.5 -- 196
	local x1 = cx + bw * 0.5 -- 197
	local bodyY0 = baseY + wr * 1.05 -- 198
	local bodyY1 = bodyY0 + bh -- 199
	local artWidth = c.bodyW * 1.36 -- 202
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 203
	local opacity = raised and occlusion:update("cart", { -- 204
		x0 = axleX - artWidth * 0.5, -- 205
		x1 = axleX + artWidth * 0.5, -- 205
		y0 = c.baseY, -- 206
		y1 = c.baseY + artHeight, -- 206
		depth = {min = depth, max = depth + 8}, -- 207
		passThrough = true -- 207
	}, p, fadeDt) or 1 -- 207
	fgDraw:drawEllipse( -- 209
		Vec2(cx, baseY + 2), -- 209
		bw * 0.62, -- 209
		5, -- 209
		Color(4, 6, 10, 150 * opacity) -- 209
	) -- 209
	local painted = assets:tryPlace( -- 211
		"prop_cart", -- 211
		"cart", -- 211
		cx, -- 211
		baseY, -- 211
		cam:len(artWidth), -- 211
		cam:len(artHeight), -- 211
		{ -- 211
			layer = raised and depthOrder(depth, 2) or 2, -- 212
			opacity = opacity, -- 212
			color = occlusionTint(opacity) -- 212
		} -- 212
	) -- 212
	if not painted then -- 212
		fillVGradRect( -- 216
			fgDraw, -- 216
			x0, -- 216
			bodyY0, -- 216
			bw, -- 216
			bh, -- 216
			Color(48, 32, 28, 255), -- 216
			toColor(PALETTE.cartWood) -- 216
		) -- 216
		fgDraw:drawRect( -- 217
			Rect(x0, bodyY0, bw, bh), -- 217
			Color(0, 0, 0, 0), -- 217
			1.6, -- 217
			toColor(PALETTE.cartMetal, 220) -- 217
		) -- 217
		fgDraw:drawSegment( -- 219
			Vec2(x0 + bw * 0.33, bodyY0), -- 219
			Vec2(x0 + bw * 0.33, bodyY1), -- 219
			1.4, -- 219
			toColor(PALETTE.cartMetal, 180) -- 219
		) -- 219
		fgDraw:drawSegment( -- 220
			Vec2(x0 + bw * 0.67, bodyY0), -- 220
			Vec2(x0 + bw * 0.67, bodyY1), -- 220
			1.4, -- 220
			toColor(PALETTE.cartMetal, 180) -- 220
		) -- 220
		fgDraw:drawSegment( -- 221
			Vec2(x0 - 2, bodyY1), -- 221
			Vec2(x1 + 2, bodyY1), -- 221
			2.2, -- 221
			toColor(PALETTE.rimSilver, 220) -- 221
		) -- 221
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 224
		local wxA = x0 + bw * 0.24 -- 225
		local wxB = x1 - bw * 0.24 -- 226
		local wy = baseY + wr -- 227
		self:drawWheel( -- 228
			fgDraw, -- 228
			wxA, -- 228
			wy, -- 228
			wr, -- 228
			wheelSpin -- 228
		) -- 228
		self:drawWheel( -- 229
			fgDraw, -- 229
			wxB, -- 229
			wy, -- 229
			wr, -- 229
			wheelSpin -- 229
		) -- 229
	end -- 229
	local hx = cam:sx(axleX + c.handleOffset) -- 233
	local hTop = bodyY1 + cam:len(9) -- 234
	local gripReady = p.gripping or p.focusCart or p:cartHandleInReach() -- 235
	local handleCol = p.gripping and PALETTE.cyan or (gripReady and PALETTE.amber or PALETTE.cartMetal) -- 236
	local edge = c.handleOffset < 0 and x0 or x1 -- 237
	fgDraw:drawSegment( -- 238
		Vec2(edge, bodyY0 + bh * 0.55), -- 238
		Vec2( -- 238
			hx, -- 238
			hTop - cam:len(4) -- 238
		), -- 238
		math.max( -- 239
			2, -- 239
			cam:len(3) -- 239
		), -- 239
		toColor(PALETTE.cartWood, 255 * opacity) -- 239
	) -- 239
	fgDraw:drawSegment( -- 240
		Vec2( -- 240
			hx, -- 240
			hTop - cam:len(6) -- 240
		), -- 240
		Vec2(hx, hTop), -- 240
		math.max( -- 241
			2, -- 241
			cam:len(4) -- 241
		), -- 241
		toColor(handleCol, 255 * opacity) -- 241
	) -- 241
	fgGlow:drawDot( -- 242
		Vec2(hx, hTop), -- 242
		gripReady and 4.8 or 3.2, -- 242
		toColor(handleCol, gripReady and 245 or 160 * opacity) -- 242
	) -- 242
	if gripReady and not p.cartDocked then -- 242
		fillRadialGlow( -- 244
			fgGlow, -- 244
			hx, -- 244
			hTop, -- 244
			22, -- 244
			22, -- 244
			toColor(handleCol, 95), -- 244
			Color(handleCol.r, handleCol.g, handleCol.b, 0), -- 244
			12 -- 244
		) -- 244
	end -- 244
	if painted then -- 244
		return -- 248
	end -- 248
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 251
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 252
	local wave2 = math.cos(time * 2.8) * 3.5 -- 253
	local clothH = cam:len(26) -- 254
	local clothW = cam:len(14) -- 255
	fgDraw:drawPolygon( -- 256
		{ -- 256
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 257
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 258
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 259
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 260
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 261
		}, -- 261
		toColor(PALETTE.clothRed) -- 262
	) -- 262
	fgDraw:drawSegment( -- 264
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 265
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 266
		1.6, -- 267
		toColor(PALETTE.clothRedHighlight, 220) -- 268
	) -- 268
	fillRadialGlow( -- 270
		fgGlow, -- 270
		clothAnchorX, -- 270
		bodyY1 - clothH * 0.35, -- 270
		32, -- 270
		32, -- 270
		Color(235, 42, 62, 54), -- 270
		Color(235, 42, 62, 0), -- 270
		14 -- 270
	) -- 270
end -- 157
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 273
	draw:drawCircle( -- 274
		Vec2(cx, cy), -- 274
		r, -- 274
		Color(24, 28, 36, 255) -- 274
	) -- 274
	draw:drawRing( -- 275
		Vec2(cx, cy), -- 275
		r * 0.72, -- 275
		r, -- 275
		Color(0, 0, 0, 0), -- 275
		1.6, -- 275
		toColor(PALETTE.cartMetal) -- 275
	) -- 275
	local k = 0 -- 276
	do -- 276
		k = 0 -- 277
		while k < 4 do -- 277
			local a = spin + k * math.pi / 4 -- 278
			draw:drawSegment( -- 279
				Vec2( -- 280
					cx - math.cos(a) * r * 0.72, -- 280
					cy - math.sin(a) * r * 0.72 -- 280
				), -- 280
				Vec2( -- 281
					cx + math.cos(a) * r * 0.72, -- 281
					cy + math.sin(a) * r * 0.72 -- 281
				), -- 281
				1.2, -- 282
				toColor(PALETTE.steelLight, 190) -- 283
			) -- 283
			k = k + 1 -- 277
		end -- 277
	end -- 277
	draw:drawDot( -- 286
		Vec2(cx, cy), -- 286
		math.max(2.2, r * 0.18), -- 286
		toColor(PALETTE.rimSilver) -- 286
	) -- 286
end -- 273
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 289
	local bottle = p.room.bottle -- 298
	if bottle ~= nil then -- 298
		local bx0 = cam:sx(bottle.x - 16) -- 300
		local bx1 = cam:sx(bottle.x + 16) -- 301
		local by0 = cam:sy(0) -- 302
		local by1 = cam:sy(64) -- 303
		fgDraw:drawRect( -- 304
			Rect(bx0, by0, bx1 - bx0, by1 - by0), -- 304
			Color(32, 36, 46, 235), -- 304
			1.2, -- 304
			toColor(PALETTE.steelLight, 180) -- 304
		) -- 304
		fgDraw:drawSegment( -- 306
			Vec2(bx0 + 2, by0 + (by1 - by0) * 0.48), -- 306
			Vec2(bx1 - 2, by0 + (by1 - by0) * 0.48), -- 306
			2, -- 306
			toColor(PALETTE.cartWood) -- 306
		) -- 306
		assets:tryPlace( -- 307
			"cover_wood", -- 307
			"village_shelf", -- 307
			(bx0 + bx1) * 0.5, -- 307
			by0, -- 307
			bx1 - bx0, -- 308
			by1 - by0, -- 308
			{layer = 1, opacity = 0.85} -- 308
		) -- 308
		fgDraw:drawSegment( -- 309
			Vec2(bx0, by1), -- 309
			Vec2(bx1, by1), -- 309
			1.3, -- 309
			toColor(PALETTE.rimSilver, 175) -- 309
		) -- 309
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 309
			self:drawBottleSprite( -- 311
				fgDraw, -- 311
				fgGlow, -- 311
				assets, -- 311
				"bottle_shelf", -- 311
				cam:sx(bottle.x), -- 311
				cam:sy(65), -- 311
				cam.ppu, -- 311
				0, -- 311
				true, -- 311
				time -- 311
			) -- 311
		end -- 311
	end -- 311
	local arch = p.room.arch -- 315
	local tx0 = cam:sx(arch.x0 - 4) -- 316
	local tx1 = cam:sx(arch.x1 + 4) -- 317
	local ty0 = cam:sy(arch.y) -- 318
	local tyBot = cam:sy(arch.y + arch.h) -- 319
	local tyTop = cam:sy(arch.y + arch.h + 7) -- 320
	fillVGradRect( -- 321
		fgDraw, -- 321
		tx0 + 6, -- 321
		ty0, -- 321
		tx1 - tx0 - 12, -- 321
		tyBot - ty0, -- 321
		Color(9, 10, 15, 165), -- 322
		Color(9, 10, 15, 100) -- 322
	) -- 322
	if not assets:tryPlace( -- 322
		"prop_table", -- 323
		"village_table", -- 323
		(tx0 + tx1) * 0.5, -- 323
		ty0, -- 323
		tx1 - tx0, -- 324
		tyTop - ty0, -- 324
		{layer = 6} -- 324
	) then -- 324
		fgDraw:drawRect( -- 325
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 325
			toColor(PALETTE.cartWood) -- 325
		) -- 325
		fgDraw:drawRect( -- 326
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 326
			toColor(PALETTE.cartWood) -- 326
		) -- 326
		fgDraw:drawRect( -- 327
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 327
			toColor(PALETTE.cartWood) -- 327
		) -- 327
	end -- 327
	if p.hasBottle then -- 327
		local pl = p.player -- 332
		self:drawBottleSprite( -- 333
			fgDraw, -- 333
			fgGlow, -- 333
			assets, -- 333
			"bottle_held", -- 333
			cam:sx(pl.x + pl.facing * 12), -- 333
			cam:sy(pl.y + pl.h * 0.56), -- 333
			cam.ppu, -- 333
			pl.facing * 0.2, -- 333
			false, -- 333
			time -- 333
		) -- 333
	end -- 333
	if p.bottleFly ~= nil then -- 333
		self:drawBottleSprite( -- 336
			fgDraw, -- 336
			fgGlow, -- 336
			assets, -- 336
			"bottle_air", -- 336
			cam:sx(p.bottleFly.x), -- 336
			cam:sy(p.bottleFly.y), -- 336
			cam.ppu, -- 336
			time * 14, -- 336
			true, -- 336
			time -- 336
		) -- 336
	end -- 336
	if p.hasBottle and p.aimHold > 0 then -- 336
		local pl = p.player -- 341
		local endX = p.bottleAimX -- 342
		local endY = p.bottleAimY -- 343
		if endX < 0 then -- 343
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 345
			endX = wAim.x -- 346
			endY = 0 -- 347
		end -- 347
		local dir = endX >= pl.x and 1 or -1 -- 349
		local x0 = pl.x + dir * 10 -- 350
		local y0 = pl.y + pl.h * 0.7 -- 351
		local T = 0.62 -- 352
		local vx = (endX - x0) / T -- 353
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 354
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 356
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 357
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 358
		local activeAim = p.aimHold > 0.01 -- 359
		local steps = 18 -- 361
		local k = 1 -- 362
		do -- 362
			k = 1 -- 363
			while k <= steps do -- 363
				local tt = k / steps * T -- 364
				local wx = x0 + vx * tt -- 365
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 366
				local sx = cam:sx(wx) -- 367
				local sy = cam:sy(wy) -- 368
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 369
				fgGlow:drawDot( -- 370
					Vec2(sx, sy), -- 370
					activeAim and 3.2 or 2.2, -- 370
					toColor(arcCol, alpha) -- 370
				) -- 370
				k = k + 1 -- 363
			end -- 363
		end -- 363
		local lx = cam:sx(endX) -- 373
		local ly = cam:sy(endY + 2) -- 374
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 375
		fgGlow:drawRing( -- 376
			Vec2(lx, ly), -- 376
			8, -- 376
			11, -- 376
			Color(0, 0, 0, 0), -- 376
			1.6, -- 376
			toColor(arcCol, activeAim and 245 or 165) -- 376
		) -- 376
		if isBrick then -- 376
			fgGlow:drawRing( -- 378
				Vec2(lx, ly), -- 378
				28 * pulse, -- 378
				30 * pulse, -- 378
				Color(0, 0, 0, 0), -- 378
				1.2, -- 378
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 378
			) -- 378
			fillRadialGlow( -- 379
				fgGlow, -- 379
				lx, -- 379
				ly, -- 379
				36, -- 379
				14, -- 379
				Color(242, 188, 96, activeAim and 95 or 48), -- 379
				Color(242, 188, 96, 0), -- 379
				14 -- 379
			) -- 379
		end -- 379
	end -- 379
end -- 289
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, fgGlow, assets, id, cx, cy, ppu, tilt, highlight, time) -- 384
	local height = math.max(12, ppu * 13) -- 392
	if not assets:tryPlace( -- 392
		"prop_bottle", -- 393
		id, -- 393
		cx, -- 393
		cy, -- 393
		height, -- 393
		height, -- 393
		{angle = tilt * 180 / math.pi, layer = 6} -- 393
	) then -- 393
		local dx = math.sin(tilt) * height * 0.4 -- 396
		local dy = math.cos(tilt) * height * 0.5 -- 397
		fgDraw:drawSegment( -- 398
			Vec2(cx - dx, cy - dy), -- 398
			Vec2(cx + dx, cy + dy), -- 398
			height * 0.32, -- 398
			toColor(PALETTE.amber, 225) -- 399
		) -- 399
	end -- 399
	if highlight then -- 399
		local p = 0.7 + 0.3 * math.sin(time * 4.5) -- 402
		fillRadialGlow( -- 403
			fgGlow, -- 403
			cx, -- 403
			cy, -- 403
			18 * p, -- 403
			18 * p, -- 403
			toColor(PALETTE.emerald, 85 * p), -- 403
			Color(84, 232, 168, 0), -- 403
			12 -- 403
		) -- 403
	end -- 403
end -- 384
return ____exports -- 384