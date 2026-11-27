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
			local tint = (kind == "wood" or kind == "scrap") and PALETTE.amber or (kind == "wedge" and PALETTE.emerald or ((kind == "shield" or kind == "ammo") and PALETTE.cyan or PALETTE.amberCore)) -- 81
			assets:tryPlace( -- 84
				isWood and "ink_bamboo_slip" or "prop_compass", -- 85
				"pickup_" .. pickup.id, -- 86
				cam:sx(pickup.x), -- 87
				cam:sy(pickup.y + 9, depth), -- 87
				cam:len(18), -- 88
				cam:len(isWood and 7 or 16), -- 88
				{ -- 89
					angle = isWood and 65 or 0, -- 90
					color = toColor(tint), -- 91
					layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 92
				} -- 92
			) -- 92
		end -- 92
		::__continue9:: -- 92
	end -- 92
end -- 68
function PropsRenderer.prototype.drawZones(self, fgDraw, p, cam) -- 98
	local i = 0 -- 103
	do -- 103
		i = 0 -- 104
		while i < #p.room.zones do -- 104
			local z = p.room.zones[i + 1] -- 105
			local x0 = cam:sx(z.x0) -- 106
			local x1 = cam:sx(z.x1) -- 107
			local y0 = cam:sy(z.y) -- 108
			local zw = x1 - x0 -- 109
			if z.tint == 1 then -- 111
				local road = p.room.depth -- 112
				local front = cam:sy(z.y, road and road.min or -3) -- 113
				local back = cam:sy(z.y, road and road.max or 1) -- 114
				fgDraw:drawRect( -- 115
					Rect(x0, front, zw, back - front), -- 115
					Color(50, 35, 29, 48) -- 115
				) -- 115
			elseif z.tint == 2 then -- 116
				fgDraw:drawRect( -- 118
					Rect(x0, y0 - 4, zw, 8), -- 118
					Color(74, 58, 44, 220) -- 118
				) -- 118
				fgDraw:drawSegment( -- 119
					Vec2(x0, y0 + 2), -- 119
					Vec2(x1, y0 + 2), -- 119
					1.4, -- 119
					Color(128, 98, 72, 190) -- 119
				) -- 119
			elseif z.tint == 3 then -- 120
				fgDraw:drawRect( -- 122
					Rect(x0, y0 - 4, zw, 9), -- 122
					Color(118, 122, 130, 235) -- 122
				) -- 122
				local bricks = 4 -- 123
				local b = 1 -- 124
				do -- 124
					b = 1 -- 125
					while b < bricks do -- 125
						local bx = x0 + zw * b / bricks -- 126
						fgDraw:drawSegment( -- 127
							Vec2(bx, y0 - 4), -- 127
							Vec2(bx, y0 + 5), -- 127
							1, -- 127
							Color(42, 46, 56, 220) -- 127
						) -- 127
						b = b + 1 -- 125
					end -- 125
				end -- 125
				fgDraw:drawSegment( -- 129
					Vec2(x0, y0 + 4), -- 129
					Vec2(x1, y0 + 4), -- 129
					1.1, -- 129
					Color(168, 151, 127, 130) -- 129
				) -- 129
			end -- 129
			i = i + 1 -- 104
		end -- 104
	end -- 104
end -- 98
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 134
	for ____, m in ipairs(p.room.marks) do -- 142
		do -- 142
			if m.kind ~= 6 then -- 143
				goto __continue22 -- 144
			end -- 144
			local mx = cam:sx(m.x) -- 146
			local my = cam:sy(m.y) -- 147
			local hookY = my + cam:len(52) -- 148
			local armX = mx + cam:len(13) -- 149
			local lampY = hookY - cam:len(12) -- 150
			local wood = Color(82, 58, 40, 245) -- 151
			local joint = math.max( -- 152
				1, -- 152
				cam:len(2) -- 152
			) -- 152
			fgDraw:drawSegment( -- 153
				Vec2(mx, my), -- 153
				Vec2(mx, hookY), -- 153
				joint, -- 153
				wood -- 153
			) -- 153
			fgDraw:drawSegment( -- 154
				Vec2(mx, hookY), -- 154
				Vec2(armX, hookY), -- 154
				joint, -- 154
				wood -- 154
			) -- 154
			fgDraw:drawSegment( -- 155
				Vec2( -- 155
					mx, -- 155
					hookY - cam:len(7) -- 155
				), -- 155
				Vec2(armX - joint, hookY), -- 155
				joint * 0.7, -- 155
				wood -- 155
			) -- 155
			if not assets:tryPlace( -- 156
				"prop_lantern", -- 156
				"path_lamp_" .. tostring(m.x), -- 156
				armX, -- 156
				lampY, -- 156
				cam:len(16), -- 156
				cam:len(20), -- 156
				{layer = 1} -- 156
			) then -- 156
				fgDraw:drawRect( -- 157
					Rect( -- 157
						armX - cam:len(4), -- 157
						lampY - cam:len(7), -- 157
						cam:len(8), -- 157
						cam:len(14) -- 157
					), -- 157
					Color(192, 136, 64, 240), -- 158
					1.4, -- 158
					wood -- 158
				) -- 158
			end -- 158
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 160
			fillRadialGlow( -- 161
				fgGlow, -- 161
				armX, -- 161
				lampY, -- 161
				cam:len(23), -- 161
				cam:len(27), -- 161
				Color(239, 182, 106, 46 * flame), -- 161
				Color(231, 164, 91, 0), -- 162
				16 -- 162
			) -- 162
		end -- 162
		::__continue22:: -- 162
	end -- 162
end -- 134
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 166
	local c = p.room.cart -- 175
	if c.bodyW <= 0 then -- 176
		return -- 177
	end -- 177
	local depth = c.depth or 0 -- 179
	local raised = p.room.depth ~= nil -- 180
	local lo = math.min(c.startX, c.endX) -- 183
	local hi = math.max(c.startX, c.endX) -- 184
	if hi - lo > 4 then -- 185
		local rx0 = cam:sx(lo) -- 186
		local rx1 = cam:sx(hi) -- 187
		local ry = cam:sy(c.baseY, depth) -- 188
		fgDraw:drawSegment( -- 189
			Vec2(rx0, ry + 1), -- 189
			Vec2(rx1, ry + 1), -- 189
			1.2, -- 189
			Color(86, 65, 47, 150) -- 189
		) -- 189
		local dockX = cam:sx(c.endX) -- 190
		local width = cam:len(24) -- 191
		local lip = cam:len(3) -- 192
		fgDraw:drawRect( -- 193
			Rect(dockX - width * 0.5, ry, width, lip), -- 193
			Color(51, 37, 26, 230) -- 193
		) -- 193
		fgDraw:drawRect( -- 194
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 194
			Color(107, 77, 51, 230) -- 194
		) -- 194
	end -- 194
	local axleX = p.cartAxle -- 197
	local cx = cam:sx(axleX) -- 198
	local baseY = cam:sy(c.baseY, depth) -- 199
	local bw = cam:len(c.bodyW) -- 200
	local bh = cam:len(c.bodyH) -- 201
	local wr = cam:len(c.wheelR) -- 202
	local x0 = cx - bw * 0.5 -- 204
	local x1 = cx + bw * 0.5 -- 205
	local bodyY0 = baseY + wr * 1.05 -- 206
	local bodyY1 = bodyY0 + bh -- 207
	local artWidth = c.bodyW * 1.36 -- 210
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 211
	local opacity = raised and occlusion:update("cart", { -- 212
		x0 = axleX - artWidth * 0.5, -- 213
		x1 = axleX + artWidth * 0.5, -- 213
		y0 = c.baseY, -- 214
		y1 = c.baseY + artHeight, -- 214
		depth = {min = depth, max = depth + 8}, -- 215
		passThrough = true -- 215
	}, p, fadeDt) or 1 -- 216
	fgDraw:drawEllipse( -- 217
		Vec2(cx, baseY + 2), -- 217
		bw * 0.62, -- 217
		5, -- 217
		Color(4, 6, 10, 150 * opacity) -- 217
	) -- 217
	local painted = assets:tryPlace( -- 219
		"prop_cart", -- 219
		"cart", -- 219
		cx, -- 219
		baseY, -- 219
		cam:len(artWidth), -- 219
		cam:len(artHeight), -- 219
		{ -- 219
			layer = raised and depthOrder(depth, 2) or 2, -- 220
			opacity = opacity, -- 220
			color = occlusionTint(opacity) -- 220
		} -- 220
	) -- 220
	if not painted then -- 222
		fillVGradRect( -- 224
			fgDraw, -- 224
			x0, -- 224
			bodyY0, -- 224
			bw, -- 224
			bh, -- 224
			Color(48, 32, 28, 255), -- 224
			toColor(PALETTE.cartWood) -- 224
		) -- 224
		fgDraw:drawRect( -- 225
			Rect(x0, bodyY0, bw, bh), -- 225
			Color(0, 0, 0, 0), -- 225
			1.6, -- 225
			toColor(PALETTE.cartMetal, 220) -- 225
		) -- 225
		fgDraw:drawSegment( -- 227
			Vec2(x0 + bw * 0.33, bodyY0), -- 227
			Vec2(x0 + bw * 0.33, bodyY1), -- 227
			1.4, -- 227
			toColor(PALETTE.cartMetal, 180) -- 227
		) -- 227
		fgDraw:drawSegment( -- 228
			Vec2(x0 + bw * 0.67, bodyY0), -- 228
			Vec2(x0 + bw * 0.67, bodyY1), -- 228
			1.4, -- 228
			toColor(PALETTE.cartMetal, 180) -- 228
		) -- 228
		fgDraw:drawSegment( -- 229
			Vec2(x0 - 2, bodyY1), -- 229
			Vec2(x1 + 2, bodyY1), -- 229
			2.2, -- 229
			toColor(PALETTE.rimSilver, 220) -- 229
		) -- 229
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 232
		local wxA = x0 + bw * 0.24 -- 233
		local wxB = x1 - bw * 0.24 -- 234
		local wy = baseY + wr -- 235
		self:drawWheel( -- 236
			fgDraw, -- 236
			wxA, -- 236
			wy, -- 236
			wr, -- 236
			wheelSpin -- 236
		) -- 236
		self:drawWheel( -- 237
			fgDraw, -- 237
			wxB, -- 237
			wy, -- 237
			wr, -- 237
			wheelSpin -- 237
		) -- 237
	end -- 237
	local hx = cam:sx(axleX + c.handleOffset) -- 241
	local hTop = bodyY1 + cam:len(7) -- 242
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 243
	local handleSpan = math.abs(hx - edge) -- 246
	if not painted or handleSpan > cam:len(4) then -- 247
		fgDraw:drawSegment( -- 248
			Vec2(edge, bodyY0 + bh * 0.52), -- 248
			Vec2( -- 248
				hx, -- 248
				hTop - cam:len(4) -- 248
			), -- 248
			math.max( -- 249
				1.8, -- 249
				cam:len(2.4) -- 249
			), -- 249
			toColor(PALETTE.cartWood, 245 * opacity) -- 249
		) -- 249
		fgDraw:drawSegment( -- 250
			Vec2( -- 250
				hx, -- 250
				hTop - cam:len(5.5) -- 250
			), -- 250
			Vec2(hx, hTop), -- 250
			math.max( -- 251
				2.2, -- 251
				cam:len(3.2) -- 251
			), -- 251
			Color(126, 91, 61, 245 * opacity) -- 251
		) -- 251
	end -- 251
	if painted then -- 254
		return -- 255
	end -- 255
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 258
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 259
	local wave2 = math.cos(time * 2.8) * 3.5 -- 260
	local clothH = cam:len(26) -- 261
	local clothW = cam:len(14) -- 262
	fgDraw:drawPolygon( -- 263
		{ -- 263
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 264
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 265
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 266
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 267
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 268
		}, -- 268
		toColor(PALETTE.clothRed) -- 269
	) -- 269
	fgDraw:drawSegment( -- 271
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 272
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 273
		1.6, -- 274
		toColor(PALETTE.clothRedHighlight, 220) -- 275
	) -- 275
end -- 166
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 279
	draw:drawCircle( -- 280
		Vec2(cx, cy), -- 280
		r, -- 280
		Color(24, 28, 36, 255) -- 280
	) -- 280
	draw:drawRing( -- 281
		Vec2(cx, cy), -- 281
		r * 0.72, -- 281
		r, -- 281
		Color(0, 0, 0, 0), -- 281
		1.6, -- 281
		toColor(PALETTE.cartMetal) -- 281
	) -- 281
	local k = 0 -- 282
	do -- 282
		k = 0 -- 283
		while k < 4 do -- 283
			local a = spin + k * math.pi / 4 -- 284
			draw:drawSegment( -- 285
				Vec2( -- 286
					cx - math.cos(a) * r * 0.72, -- 286
					cy - math.sin(a) * r * 0.72 -- 286
				), -- 286
				Vec2( -- 287
					cx + math.cos(a) * r * 0.72, -- 287
					cy + math.sin(a) * r * 0.72 -- 287
				), -- 287
				1.2, -- 288
				toColor(PALETTE.steelLight, 190) -- 289
			) -- 289
			k = k + 1 -- 283
		end -- 283
	end -- 283
	draw:drawDot( -- 292
		Vec2(cx, cy), -- 292
		math.max(2.2, r * 0.18), -- 292
		toColor(PALETTE.rimSilver) -- 292
	) -- 292
end -- 279
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 295
	local bottle = p.room.bottle -- 304
	if bottle ~= nil then -- 305
		local bx0 = cam:sx(bottle.x - 16) -- 306
		local bx1 = cam:sx(bottle.x + 16) -- 307
		local by0 = cam:sy(0) -- 308
		local by1 = cam:sy(52) -- 309
		local beam = cam:len(3.2) -- 310
		local side = Color(78, 57, 41, 255) -- 311
		fgDraw:drawRect( -- 312
			Rect(bx0, by0, beam, by1 - by0), -- 312
			side -- 312
		) -- 312
		fgDraw:drawRect( -- 313
			Rect(bx1 - beam, by0, beam, by1 - by0), -- 313
			side -- 313
		) -- 313
		for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 314
			fgDraw:drawRect( -- 315
				Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 315
				Color(106, 78, 56, 255), -- 316
				1, -- 316
				Color(56, 42, 34, 240) -- 316
			) -- 316
		end -- 316
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 318
			self:drawBottleSprite( -- 319
				fgDraw, -- 319
				assets, -- 319
				"bottle_shelf", -- 319
				cam:sx(bottle.x), -- 319
				cam:sy(56), -- 319
				cam.ppu, -- 319
				0 -- 319
			) -- 319
		end -- 319
	end -- 319
	local arch = p.room.arch -- 323
	local tx0 = cam:sx(arch.x0 - 4) -- 324
	local tx1 = cam:sx(arch.x1 + 4) -- 325
	local ty0 = cam:sy(arch.y) -- 326
	local tyBot = cam:sy(arch.y + arch.h) -- 327
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 328
	fillVGradRect( -- 329
		fgDraw, -- 329
		tx0 + 6, -- 329
		ty0, -- 329
		tx1 - tx0 - 12, -- 329
		tyBot - ty0, -- 329
		Color(9, 10, 15, 165), -- 330
		Color(9, 10, 15, 100) -- 330
	) -- 330
	if not assets:tryPlace( -- 331
		"prop_table", -- 331
		"village_table", -- 331
		(tx0 + tx1) * 0.5, -- 331
		ty0, -- 331
		tx1 - tx0, -- 332
		tyTop - ty0, -- 332
		{layer = 6} -- 332
	) then -- 332
		fgDraw:drawRect( -- 333
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 333
			toColor(PALETTE.cartWood) -- 333
		) -- 333
		fgDraw:drawRect( -- 334
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 334
			toColor(PALETTE.cartWood) -- 334
		) -- 334
		fgDraw:drawRect( -- 335
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 335
			toColor(PALETTE.cartWood) -- 335
		) -- 335
	end -- 335
	if p.hasBottle and p.aimHold <= 0 then -- 339
		local pl = p.player -- 340
		self:drawBottleSprite( -- 341
			fgDraw, -- 341
			assets, -- 341
			"bottle_held", -- 341
			cam:sx(pl.x + pl.facing * 10), -- 341
			cam:sy(pl.y + pl.h * 0.52), -- 341
			cam.ppu, -- 341
			pl.facing * 0.2 -- 341
		) -- 341
	end -- 341
	if p.bottleFly ~= nil then -- 343
		self:drawBottleSprite( -- 344
			fgDraw, -- 344
			assets, -- 344
			"bottle_air", -- 344
			cam:sx(p.bottleFly.x), -- 344
			cam:sy(p.bottleFly.y), -- 344
			cam.ppu, -- 344
			time * 14 -- 344
		) -- 344
	end -- 344
	if p.hasBottle and p.aimHold > 0 then -- 348
		local pl = p.player -- 349
		local endX = p.bottleAimX -- 350
		local endY = p.bottleAimY -- 351
		if endX < 0 then -- 352
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 353
			endX = wAim.x -- 354
			endY = 0 -- 355
		end -- 355
		local dir = endX >= pl.x and 1 or -1 -- 357
		local x0 = pl.x + dir * 10 -- 358
		local y0 = pl.y + pl.h * 0.7 -- 359
		local T = 0.62 -- 360
		local vx = (endX - x0) / T -- 361
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 362
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 364
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 365
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 366
		local activeAim = p.aimHold > 0.01 -- 367
		local steps = 18 -- 369
		local k = 1 -- 370
		do -- 370
			k = 1 -- 371
			while k <= steps do -- 371
				local tt = k / steps * T -- 372
				local wx = x0 + vx * tt -- 373
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 374
				local sx = cam:sx(wx) -- 375
				local sy = cam:sy(wy) -- 376
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 377
				fgGlow:drawDot( -- 378
					Vec2(sx, sy), -- 378
					activeAim and 3.2 or 2.2, -- 378
					toColor(arcCol, alpha) -- 378
				) -- 378
				k = k + 1 -- 371
			end -- 371
		end -- 371
		local lx = cam:sx(endX) -- 381
		local ly = cam:sy(endY + 2) -- 382
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 383
		fgGlow:drawRing( -- 384
			Vec2(lx, ly), -- 384
			8, -- 384
			11, -- 384
			Color(0, 0, 0, 0), -- 384
			1.6, -- 384
			toColor(arcCol, activeAim and 245 or 165) -- 384
		) -- 384
		if isBrick then -- 385
			fgGlow:drawRing( -- 386
				Vec2(lx, ly), -- 386
				28 * pulse, -- 386
				30 * pulse, -- 386
				Color(0, 0, 0, 0), -- 386
				1.2, -- 386
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 386
			) -- 386
			fillRadialGlow( -- 387
				fgGlow, -- 387
				lx, -- 387
				ly, -- 387
				36, -- 387
				14, -- 387
				Color(242, 188, 96, activeAim and 95 or 48), -- 387
				Color(242, 188, 96, 0), -- 387
				14 -- 387
			) -- 387
		end -- 387
	end -- 387
end -- 295
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 392
	local height = math.max(10, ppu * 10.5) -- 399
	if not assets:tryPlace( -- 400
		"prop_bottle", -- 400
		id, -- 400
		cx, -- 400
		cy, -- 400
		height, -- 400
		height, -- 400
		{angle = tilt * 180 / math.pi, layer = 6} -- 400
	) then -- 400
		local dx = math.sin(tilt) * height * 0.4 -- 403
		local dy = math.cos(tilt) * height * 0.5 -- 404
		fgDraw:drawSegment( -- 405
			Vec2(cx - dx, cy - dy), -- 405
			Vec2(cx + dx, cy + dy), -- 405
			height * 0.32, -- 405
			toColor(PALETTE.amber, 225) -- 406
		) -- 406
	end -- 406
end -- 392
return ____exports -- 392
