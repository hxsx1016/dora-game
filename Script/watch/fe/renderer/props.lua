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
local fillRadialGlow = ____theme.fillRadialGlow -- 17
local fillVGradRect = ____theme.fillVGradRect -- 18
local toColor = ____theme.toColor -- 19
local GRAVITY = 1000 -- 22
____exports.PropsRenderer = __TS__Class() -- 24
local PropsRenderer = ____exports.PropsRenderer -- 24
PropsRenderer.name = "PropsRenderer" -- 24
function PropsRenderer.prototype.____constructor(self) -- 24
end -- 24
function PropsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 25
	self:drawZones(fgDraw, p, cam) -- 35
	self:drawMarks( -- 36
		fgDraw, -- 36
		fgGlow, -- 36
		assets, -- 36
		p, -- 36
		cam, -- 36
		time -- 36
	) -- 36
	self:drawCart( -- 37
		fgDraw, -- 37
		assets, -- 37
		p, -- 37
		cam, -- 37
		time, -- 37
		occlusion, -- 37
		fadeDt -- 37
	) -- 37
	self:drawBracedShield(fgDraw, p, cam) -- 38
	self:drawCraftMaterials(assets, p, cam) -- 39
	if p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 40
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
	if p.room.key == "village" then -- 47
		self:drawVillageProps( -- 48
			fgDraw, -- 48
			fgGlow, -- 48
			assets, -- 48
			p, -- 48
			cam, -- 48
			time -- 48
		) -- 48
	end -- 48
end -- 25
function PropsRenderer.prototype.drawBracedShield(self, fgDraw, p, cam) -- 53
	local sh = p.bracedShield -- 54
	if sh == nil or sh.hp <= 0 then -- 55
		return -- 56
	end -- 56
	local cx = cam:sx(sh.x) -- 58
	local by = cam:sy(sh.y, p.player.depth) -- 59
	local w = math.max( -- 60
		8, -- 60
		cam:len(12) -- 60
	) -- 60
	local h = cam:len(sh.h) -- 61
	fgDraw:drawEllipse( -- 62
		Vec2(cx, by + 1), -- 62
		w * 0.9, -- 62
		3.2, -- 62
		Color(8, 10, 14, 150) -- 62
	) -- 62
	fgDraw:drawSegment( -- 63
		Vec2(cx - w * 0.65, by), -- 63
		Vec2(cx - w * 0.15, by + h * 0.55), -- 63
		2.2, -- 63
		Color(84, 58, 38, 255) -- 63
	) -- 63
	fgDraw:drawRect( -- 64
		Rect(cx - w * 0.5, by + 2, w, h - 2), -- 64
		Color(104, 72, 46, 248), -- 64
		1.4, -- 64
		Color(172, 178, 184, 235) -- 64
	) -- 64
	fgDraw:drawCircle( -- 65
		Vec2(cx, by + h * 0.52), -- 65
		math.max( -- 65
			2.5, -- 65
			cam:len(4) -- 65
		), -- 65
		Color(148, 154, 160, 245) -- 65
	) -- 65
end -- 53
function PropsRenderer.prototype.drawCraftMaterials(self, assets, p, cam) -- 68
	for ____, pickup in ipairs(p.pickups) do -- 69
		do -- 69
			local kind = pickup.kind -- 71
			if pickup.id == "" or p.run.taken[pickup.id] then -- 72
				goto __continue9 -- 73
			end -- 73
			local depth = pickup.depth or 0 -- 75
			local isWood = kind == "wood" or kind == "scrap" or kind == "wedge" -- 76
			local isMetal = kind == "bell" or kind == "shield" or kind == "ammo" or kind == "pass" or kind == "quickbelt" -- 77
			if not isWood and not isMetal then -- 78
				goto __continue9 -- 79
			end -- 79
			local layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 81
			local sx = cam:sx(pickup.x) -- 82
			local sy = cam:sy(pickup.y + 4, depth) -- 83
			if kind == "wood" and assets:tryPlace( -- 84
				"sh_wood_tally", -- 84
				"pickup_" .. pickup.id, -- 84
				sx, -- 84
				sy, -- 84
				cam:len(18), -- 84
				cam:len(24), -- 84
				{layer = layer} -- 84
			) then -- 84
				goto __continue9 -- 85
			end -- 85
			if kind == "bell" and assets:tryPlace( -- 87
				"sh_bell_tally", -- 87
				"pickup_" .. pickup.id, -- 87
				sx, -- 87
				sy, -- 87
				cam:len(20), -- 87
				cam:len(24), -- 87
				{layer = layer} -- 87
			) then -- 87
				goto __continue9 -- 88
			end -- 88
			local tint = (kind == "wood" or kind == "scrap") and PALETTE.amber or (kind == "wedge" and PALETTE.emerald or ((kind == "shield" or kind == "ammo") and PALETTE.cyan or PALETTE.amberCore)) -- 90
			assets:tryPlace( -- 93
				isWood and "ink_bamboo_slip" or "prop_compass", -- 94
				"pickup_" .. pickup.id, -- 95
				sx, -- 96
				cam:sy(pickup.y + 9, depth), -- 96
				cam:len(18), -- 97
				cam:len(isWood and 7 or 16), -- 97
				{ -- 98
					angle = isWood and 65 or 0, -- 99
					color = toColor(tint), -- 100
					layer = layer -- 101
				} -- 101
			) -- 101
		end -- 101
		::__continue9:: -- 101
	end -- 101
end -- 68
function PropsRenderer.prototype.drawZones(self, fgDraw, p, cam) -- 107
	local i = 0 -- 112
	do -- 112
		i = 0 -- 113
		while i < #p.room.zones do -- 113
			local z = p.room.zones[i + 1] -- 114
			local x0 = cam:sx(z.x0) -- 115
			local x1 = cam:sx(z.x1) -- 116
			local y0 = cam:sy(z.y) -- 117
			local zw = x1 - x0 -- 118
			if z.tint == 1 then -- 120
				local road = p.room.depth -- 121
				local front = cam:sy(z.y, road and road.min or -3) -- 122
				local back = cam:sy(z.y, road and road.max or 1) -- 123
				fgDraw:drawRect( -- 124
					Rect(x0, front, zw, back - front), -- 124
					Color(50, 35, 29, 48) -- 124
				) -- 124
			elseif z.tint == 2 then -- 125
				fgDraw:drawRect( -- 127
					Rect(x0, y0 - 4, zw, 8), -- 127
					Color(74, 58, 44, 220) -- 127
				) -- 127
				fgDraw:drawSegment( -- 128
					Vec2(x0, y0 + 2), -- 128
					Vec2(x1, y0 + 2), -- 128
					1.4, -- 128
					Color(128, 98, 72, 190) -- 128
				) -- 128
			elseif z.tint == 3 then -- 129
				fgDraw:drawRect( -- 131
					Rect(x0, y0 - 4, zw, 9), -- 131
					Color(118, 122, 130, 235) -- 131
				) -- 131
				local bricks = 4 -- 132
				local b = 1 -- 133
				do -- 133
					b = 1 -- 134
					while b < bricks do -- 134
						local bx = x0 + zw * b / bricks -- 135
						fgDraw:drawSegment( -- 136
							Vec2(bx, y0 - 4), -- 136
							Vec2(bx, y0 + 5), -- 136
							1, -- 136
							Color(42, 46, 56, 220) -- 136
						) -- 136
						b = b + 1 -- 134
					end -- 134
				end -- 134
				fgDraw:drawSegment( -- 138
					Vec2(x0, y0 + 4), -- 138
					Vec2(x1, y0 + 4), -- 138
					1.1, -- 138
					Color(168, 151, 127, 130) -- 138
				) -- 138
			end -- 138
			i = i + 1 -- 113
		end -- 113
	end -- 113
end -- 107
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 143
	for ____, m in ipairs(p.room.marks) do -- 151
		do -- 151
			if m.kind ~= 6 then -- 152
				goto __continue24 -- 153
			end -- 153
			local mx = cam:sx(m.x) -- 155
			local my = cam:sy(m.y) -- 156
			local hookY = my + cam:len(52) -- 157
			local armX = mx + cam:len(13) -- 158
			local lampY = hookY - cam:len(12) -- 159
			local wood = Color(82, 58, 40, 245) -- 160
			local joint = math.max( -- 161
				1, -- 161
				cam:len(2) -- 161
			) -- 161
			fgDraw:drawSegment( -- 162
				Vec2(mx, my), -- 162
				Vec2(mx, hookY), -- 162
				joint, -- 162
				wood -- 162
			) -- 162
			fgDraw:drawSegment( -- 163
				Vec2(mx, hookY), -- 163
				Vec2(armX, hookY), -- 163
				joint, -- 163
				wood -- 163
			) -- 163
			fgDraw:drawSegment( -- 164
				Vec2( -- 164
					mx, -- 164
					hookY - cam:len(7) -- 164
				), -- 164
				Vec2(armX - joint, hookY), -- 164
				joint * 0.7, -- 164
				wood -- 164
			) -- 164
			if not assets:tryPlace( -- 165
				"prop_lantern", -- 165
				"path_lamp_" .. tostring(m.x), -- 165
				armX, -- 165
				lampY, -- 165
				cam:len(16), -- 165
				cam:len(20), -- 165
				{layer = 1} -- 165
			) then -- 165
				fgDraw:drawRect( -- 166
					Rect( -- 166
						armX - cam:len(4), -- 166
						lampY - cam:len(7), -- 166
						cam:len(8), -- 166
						cam:len(14) -- 166
					), -- 166
					Color(192, 136, 64, 240), -- 167
					1.4, -- 167
					wood -- 167
				) -- 167
			end -- 167
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 169
			fillRadialGlow( -- 170
				fgGlow, -- 170
				armX, -- 170
				lampY, -- 170
				cam:len(23), -- 170
				cam:len(27), -- 170
				Color(239, 182, 106, 46 * flame), -- 170
				Color(231, 164, 91, 0), -- 171
				16 -- 171
			) -- 171
		end -- 171
		::__continue24:: -- 171
	end -- 171
end -- 143
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 175
	local c = p.room.cart -- 184
	if c.bodyW <= 0 then -- 185
		return -- 186
	end -- 186
	local depth = c.depth or 0 -- 188
	local raised = p.room.depth ~= nil -- 189
	local lo = math.min(c.startX, c.endX) -- 192
	local hi = math.max(c.startX, c.endX) -- 193
	if hi - lo > 4 then -- 194
		local rx0 = cam:sx(lo) -- 195
		local rx1 = cam:sx(hi) -- 196
		local ry = cam:sy(c.baseY, depth) -- 197
		fgDraw:drawSegment( -- 198
			Vec2(rx0, ry + 1), -- 198
			Vec2(rx1, ry + 1), -- 198
			1.2, -- 198
			Color(86, 65, 47, 150) -- 198
		) -- 198
		local dockX = cam:sx(c.endX) -- 199
		local width = cam:len(24) -- 200
		local lip = cam:len(3) -- 201
		fgDraw:drawRect( -- 202
			Rect(dockX - width * 0.5, ry, width, lip), -- 202
			Color(51, 37, 26, 230) -- 202
		) -- 202
		fgDraw:drawRect( -- 203
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 203
			Color(107, 77, 51, 230) -- 203
		) -- 203
	end -- 203
	local axleX = p.cartAxle -- 206
	local cx = cam:sx(axleX) -- 207
	local baseY = cam:sy(c.baseY, depth) -- 208
	local bw = cam:len(c.bodyW) -- 209
	local bh = cam:len(c.bodyH) -- 210
	local wr = cam:len(c.wheelR) -- 211
	local x0 = cx - bw * 0.5 -- 213
	local x1 = cx + bw * 0.5 -- 214
	local bodyY0 = baseY + wr * 1.05 -- 215
	local bodyY1 = bodyY0 + bh -- 216
	local artWidth = c.bodyW * 1.36 -- 219
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 220
	local opacity = raised and occlusion:update("cart", { -- 221
		x0 = axleX - artWidth * 0.5, -- 222
		x1 = axleX + artWidth * 0.5, -- 222
		y0 = c.baseY, -- 223
		y1 = c.baseY + artHeight, -- 223
		depth = {min = depth, max = depth + 8}, -- 224
		passThrough = true -- 224
	}, p, fadeDt) or 1 -- 225
	fgDraw:drawEllipse( -- 226
		Vec2(cx, baseY + 2), -- 226
		bw * 0.62, -- 226
		5, -- 226
		Color(4, 6, 10, 150 * opacity) -- 226
	) -- 226
	local painted = assets:tryPlace( -- 228
		"prop_cart", -- 228
		"cart", -- 228
		cx, -- 228
		baseY, -- 228
		cam:len(artWidth), -- 228
		cam:len(artHeight), -- 228
		{ -- 228
			layer = raised and depthOrder(depth, 2) or 2, -- 229
			opacity = opacity, -- 229
			color = occlusionTint(opacity) -- 229
		} -- 229
	) -- 229
	if not painted then -- 231
		fillVGradRect( -- 233
			fgDraw, -- 233
			x0, -- 233
			bodyY0, -- 233
			bw, -- 233
			bh, -- 233
			Color(48, 32, 28, 255), -- 233
			toColor(PALETTE.cartWood) -- 233
		) -- 233
		fgDraw:drawRect( -- 234
			Rect(x0, bodyY0, bw, bh), -- 234
			Color(0, 0, 0, 0), -- 234
			1.6, -- 234
			toColor(PALETTE.cartMetal, 220) -- 234
		) -- 234
		fgDraw:drawSegment( -- 236
			Vec2(x0 + bw * 0.33, bodyY0), -- 236
			Vec2(x0 + bw * 0.33, bodyY1), -- 236
			1.4, -- 236
			toColor(PALETTE.cartMetal, 180) -- 236
		) -- 236
		fgDraw:drawSegment( -- 237
			Vec2(x0 + bw * 0.67, bodyY0), -- 237
			Vec2(x0 + bw * 0.67, bodyY1), -- 237
			1.4, -- 237
			toColor(PALETTE.cartMetal, 180) -- 237
		) -- 237
		fgDraw:drawSegment( -- 238
			Vec2(x0 - 2, bodyY1), -- 238
			Vec2(x1 + 2, bodyY1), -- 238
			2.2, -- 238
			toColor(PALETTE.rimSilver, 220) -- 238
		) -- 238
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 241
		local wxA = x0 + bw * 0.24 -- 242
		local wxB = x1 - bw * 0.24 -- 243
		local wy = baseY + wr -- 244
		self:drawWheel( -- 245
			fgDraw, -- 245
			wxA, -- 245
			wy, -- 245
			wr, -- 245
			wheelSpin -- 245
		) -- 245
		self:drawWheel( -- 246
			fgDraw, -- 246
			wxB, -- 246
			wy, -- 246
			wr, -- 246
			wheelSpin -- 246
		) -- 246
	end -- 246
	local hx = cam:sx(axleX + c.handleOffset) -- 250
	local hTop = bodyY1 + cam:len(7) -- 251
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 252
	local handleSpan = math.abs(hx - edge) -- 255
	if not painted or handleSpan > cam:len(4) then -- 256
		fgDraw:drawSegment( -- 257
			Vec2(edge, bodyY0 + bh * 0.52), -- 257
			Vec2( -- 257
				hx, -- 257
				hTop - cam:len(4) -- 257
			), -- 257
			math.max( -- 258
				1.8, -- 258
				cam:len(2.4) -- 258
			), -- 258
			toColor(PALETTE.cartWood, 245 * opacity) -- 258
		) -- 258
		fgDraw:drawSegment( -- 259
			Vec2( -- 259
				hx, -- 259
				hTop - cam:len(5.5) -- 259
			), -- 259
			Vec2(hx, hTop), -- 259
			math.max( -- 260
				2.2, -- 260
				cam:len(3.2) -- 260
			), -- 260
			Color(126, 91, 61, 245 * opacity) -- 260
		) -- 260
	end -- 260
	if painted then -- 263
		return -- 264
	end -- 264
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 267
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 268
	local wave2 = math.cos(time * 2.8) * 3.5 -- 269
	local clothH = cam:len(26) -- 270
	local clothW = cam:len(14) -- 271
	fgDraw:drawPolygon( -- 272
		{ -- 272
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 273
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 274
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 275
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 276
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 277
		}, -- 277
		toColor(PALETTE.clothRed) -- 278
	) -- 278
	fgDraw:drawSegment( -- 280
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 281
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 282
		1.6, -- 283
		toColor(PALETTE.clothRedHighlight, 220) -- 284
	) -- 284
end -- 175
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 288
	draw:drawCircle( -- 289
		Vec2(cx, cy), -- 289
		r, -- 289
		Color(24, 28, 36, 255) -- 289
	) -- 289
	draw:drawRing( -- 290
		Vec2(cx, cy), -- 290
		r * 0.72, -- 290
		r, -- 290
		Color(0, 0, 0, 0), -- 290
		1.6, -- 290
		toColor(PALETTE.cartMetal) -- 290
	) -- 290
	local k = 0 -- 291
	do -- 291
		k = 0 -- 292
		while k < 4 do -- 292
			local a = spin + k * math.pi / 4 -- 293
			draw:drawSegment( -- 294
				Vec2( -- 295
					cx - math.cos(a) * r * 0.72, -- 295
					cy - math.sin(a) * r * 0.72 -- 295
				), -- 295
				Vec2( -- 296
					cx + math.cos(a) * r * 0.72, -- 296
					cy + math.sin(a) * r * 0.72 -- 296
				), -- 296
				1.2, -- 297
				toColor(PALETTE.steelLight, 190) -- 298
			) -- 298
			k = k + 1 -- 292
		end -- 292
	end -- 292
	draw:drawDot( -- 301
		Vec2(cx, cy), -- 301
		math.max(2.2, r * 0.18), -- 301
		toColor(PALETTE.rimSilver) -- 301
	) -- 301
end -- 288
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 304
	local bottle = p.room.bottle -- 313
	if bottle ~= nil then -- 314
		local bx0 = cam:sx(bottle.x - 16) -- 315
		local bx1 = cam:sx(bottle.x + 16) -- 316
		local by0 = cam:sy(0) -- 317
		local by1 = cam:sy(52) -- 318
		local beam = cam:len(3.2) -- 319
		local side = Color(78, 57, 41, 255) -- 320
		fgDraw:drawRect( -- 321
			Rect(bx0, by0, beam, by1 - by0), -- 321
			side -- 321
		) -- 321
		fgDraw:drawRect( -- 322
			Rect(bx1 - beam, by0, beam, by1 - by0), -- 322
			side -- 322
		) -- 322
		for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 323
			fgDraw:drawRect( -- 324
				Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 324
				Color(106, 78, 56, 255), -- 325
				1, -- 325
				Color(56, 42, 34, 240) -- 325
			) -- 325
		end -- 325
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 327
			self:drawBottleSprite( -- 328
				fgDraw, -- 328
				assets, -- 328
				"bottle_shelf", -- 328
				cam:sx(bottle.x), -- 328
				cam:sy(56), -- 328
				cam.ppu, -- 328
				0 -- 328
			) -- 328
		end -- 328
	end -- 328
	local arch = p.room.arch -- 332
	local tx0 = cam:sx(arch.x0 - 4) -- 333
	local tx1 = cam:sx(arch.x1 + 4) -- 334
	local ty0 = cam:sy(arch.y) -- 335
	local tyBot = cam:sy(arch.y + arch.h) -- 336
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 337
	fillVGradRect( -- 338
		fgDraw, -- 338
		tx0 + 6, -- 338
		ty0, -- 338
		tx1 - tx0 - 12, -- 338
		tyBot - ty0, -- 338
		Color(9, 10, 15, 165), -- 339
		Color(9, 10, 15, 100) -- 339
	) -- 339
	if not assets:tryPlace( -- 340
		"prop_table", -- 340
		"village_table", -- 340
		(tx0 + tx1) * 0.5, -- 340
		ty0, -- 340
		tx1 - tx0, -- 341
		tyTop - ty0, -- 341
		{layer = 6} -- 341
	) then -- 341
		fgDraw:drawRect( -- 342
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 342
			toColor(PALETTE.cartWood) -- 342
		) -- 342
		fgDraw:drawRect( -- 343
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 343
			toColor(PALETTE.cartWood) -- 343
		) -- 343
		fgDraw:drawRect( -- 344
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 344
			toColor(PALETTE.cartWood) -- 344
		) -- 344
	end -- 344
	local basinX = cam:sx(p.ox + 548) -- 348
	local basinY = cam:sy(0) -- 349
	assets:tryPlace( -- 350
		"sh_iron_basin", -- 350
		"village_iron_basin_px", -- 350
		basinX, -- 350
		basinY - cam:len(3), -- 350
		cam:len(38), -- 350
		cam:len(24), -- 350
		{layer = 4} -- 350
	) -- 350
	if p.hasBottle and p.aimHold <= 0 then -- 353
		local pl = p.player -- 354
		self:drawBottleSprite( -- 355
			fgDraw, -- 355
			assets, -- 355
			"bottle_held", -- 355
			cam:sx(pl.x + pl.facing * 10), -- 355
			cam:sy(pl.y + pl.h * 0.52), -- 355
			cam.ppu, -- 355
			pl.facing * 0.2 -- 355
		) -- 355
	end -- 355
	if p.bottleFly ~= nil then -- 357
		self:drawBottleSprite( -- 358
			fgDraw, -- 358
			assets, -- 358
			"bottle_air", -- 358
			cam:sx(p.bottleFly.x), -- 358
			cam:sy(p.bottleFly.y), -- 358
			cam.ppu, -- 358
			time * 14 -- 358
		) -- 358
	end -- 358
	if p.hasBottle and p.aimHold > 0 then -- 362
		local pl = p.player -- 363
		local endX = p.bottleAimX -- 364
		local endY = p.bottleAimY -- 365
		if endX < 0 then -- 366
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 367
			endX = wAim.x -- 368
			endY = 0 -- 369
		end -- 369
		local dir = endX >= pl.x and 1 or -1 -- 371
		local x0 = pl.x + dir * 10 -- 372
		local y0 = pl.y + pl.h * 0.7 -- 373
		local T = 0.62 -- 374
		local vx = (endX - x0) / T -- 375
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 376
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 378
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 379
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 380
		local activeAim = p.aimHold > 0.01 -- 381
		local steps = 18 -- 383
		local k = 1 -- 384
		do -- 384
			k = 1 -- 385
			while k <= steps do -- 385
				local tt = k / steps * T -- 386
				local wx = x0 + vx * tt -- 387
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 388
				local sx = cam:sx(wx) -- 389
				local sy = cam:sy(wy) -- 390
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 391
				fgGlow:drawDot( -- 392
					Vec2(sx, sy), -- 392
					activeAim and 3.2 or 2.2, -- 392
					toColor(arcCol, alpha) -- 392
				) -- 392
				k = k + 1 -- 385
			end -- 385
		end -- 385
		local lx = cam:sx(endX) -- 395
		local ly = cam:sy(endY + 2) -- 396
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 397
		fgGlow:drawRing( -- 398
			Vec2(lx, ly), -- 398
			8, -- 398
			11, -- 398
			Color(0, 0, 0, 0), -- 398
			1.6, -- 398
			toColor(arcCol, activeAim and 245 or 165) -- 398
		) -- 398
		if isBrick then -- 399
			fgGlow:drawRing( -- 400
				Vec2(lx, ly), -- 400
				28 * pulse, -- 400
				30 * pulse, -- 400
				Color(0, 0, 0, 0), -- 400
				1.2, -- 400
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 400
			) -- 400
			fillRadialGlow( -- 401
				fgGlow, -- 401
				lx, -- 401
				ly, -- 401
				36, -- 401
				14, -- 401
				Color(242, 188, 96, activeAim and 95 or 48), -- 401
				Color(242, 188, 96, 0), -- 401
				14 -- 401
			) -- 401
		end -- 401
	end -- 401
end -- 304
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 406
	local height = math.max(10, ppu * 10.5) -- 413
	if not assets:tryPlace( -- 414
		"prop_bottle", -- 414
		id, -- 414
		cx, -- 414
		cy, -- 414
		height, -- 414
		height, -- 414
		{angle = tilt * 180 / math.pi, layer = 6} -- 414
	) then -- 414
		local dx = math.sin(tilt) * height * 0.4 -- 417
		local dy = math.cos(tilt) * height * 0.5 -- 418
		fgDraw:drawSegment( -- 419
			Vec2(cx - dx, cy - dy), -- 419
			Vec2(cx + dx, cy + dy), -- 419
			height * 0.32, -- 419
			toColor(PALETTE.amber, 225) -- 420
		) -- 420
	end -- 420
end -- 406
return ____exports -- 406
