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
	self:drawCraftMaterials(assets, p, cam) -- 38
	if p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 38
		local x = (p.player.x + p.partner.x) * 0.5 -- 40
		local y = p.partner.y + p.partner.h * 0.62 -- 41
		local depth = (p.player.depth + p.partner.depth) * 0.5 -- 42
		assets:tryPlace( -- 43
			"prop_compass", -- 43
			"handover", -- 43
			cam:sx(x), -- 43
			cam:sy(y, depth), -- 43
			cam:len(12), -- 43
			cam:len(12), -- 43
			{layer = p.room.depth == nil and 6 or depthOrder(depth, 6)} -- 44
		) -- 44
	end -- 44
	if p.room.key == "village" then -- 44
		self:drawVillageProps( -- 47
			fgDraw, -- 47
			fgGlow, -- 47
			assets, -- 47
			p, -- 47
			cam, -- 47
			time -- 47
		) -- 47
	end -- 47
end -- 25
function PropsRenderer.prototype.drawCraftMaterials(self, assets, p, cam) -- 51
	for ____, pickup in ipairs(p.pickups) do -- 52
		do -- 52
			local kind = pickup.kind -- 54
			if pickup.id == "" or kind ~= "wood" and kind ~= "bell" then -- 54
				goto __continue7 -- 56
			end -- 56
			local depth = pickup.depth or 0 -- 58
			local isWood = kind == "wood" -- 59
			assets:tryPlace( -- 60
				isWood and "ink_bamboo_slip" or "prop_compass", -- 61
				"pickup_" .. pickup.id, -- 62
				cam:sx(pickup.x), -- 63
				cam:sy(pickup.y + 9, depth), -- 63
				cam:len(18), -- 64
				cam:len(isWood and 7 or 16), -- 64
				{ -- 65
					angle = isWood and 65 or 0, -- 66
					color = isWood and toColor(PALETTE.amber) or toColor(PALETTE.amberCore), -- 67
					layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 68
				} -- 68
			) -- 68
		end -- 68
		::__continue7:: -- 68
	end -- 68
end -- 51
function PropsRenderer.prototype.drawZones(self, fgDraw, p, cam) -- 74
	local i = 0 -- 79
	do -- 79
		i = 0 -- 80
		while i < #p.room.zones do -- 80
			local z = p.room.zones[i + 1] -- 81
			local x0 = cam:sx(z.x0) -- 82
			local x1 = cam:sx(z.x1) -- 83
			local y0 = cam:sy(z.y) -- 84
			local zw = x1 - x0 -- 85
			if z.tint == 1 then -- 85
				local road = p.room.depth -- 88
				local front = cam:sy(z.y, road and road.min or -3) -- 89
				local back = cam:sy(z.y, road and road.max or 1) -- 90
				fgDraw:drawRect( -- 91
					Rect(x0, front, zw, back - front), -- 91
					Color(50, 35, 29, 48) -- 91
				) -- 91
			elseif z.tint == 2 then -- 91
				fgDraw:drawRect( -- 94
					Rect(x0, y0 - 4, zw, 8), -- 94
					Color(74, 58, 44, 220) -- 94
				) -- 94
				fgDraw:drawSegment( -- 95
					Vec2(x0, y0 + 2), -- 95
					Vec2(x1, y0 + 2), -- 95
					1.4, -- 95
					Color(128, 98, 72, 190) -- 95
				) -- 95
			elseif z.tint == 3 then -- 95
				fgDraw:drawRect( -- 98
					Rect(x0, y0 - 4, zw, 9), -- 98
					Color(118, 122, 130, 235) -- 98
				) -- 98
				local bricks = 4 -- 99
				local b = 1 -- 100
				do -- 100
					b = 1 -- 101
					while b < bricks do -- 101
						local bx = x0 + zw * b / bricks -- 102
						fgDraw:drawSegment( -- 103
							Vec2(bx, y0 - 4), -- 103
							Vec2(bx, y0 + 5), -- 103
							1, -- 103
							Color(42, 46, 56, 220) -- 103
						) -- 103
						b = b + 1 -- 101
					end -- 101
				end -- 101
				fgDraw:drawSegment( -- 105
					Vec2(x0, y0 + 4), -- 105
					Vec2(x1, y0 + 4), -- 105
					1.1, -- 105
					Color(168, 151, 127, 130) -- 105
				) -- 105
			end -- 105
			i = i + 1 -- 80
		end -- 80
	end -- 80
end -- 74
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 110
	for ____, m in ipairs(p.room.marks) do -- 118
		do -- 118
			if m.kind ~= 6 then -- 118
				goto __continue19 -- 120
			end -- 120
			local mx = cam:sx(m.x) -- 122
			local my = cam:sy(m.y) -- 123
			local hookY = my + cam:len(52) -- 124
			local armX = mx + cam:len(13) -- 125
			local lampY = hookY - cam:len(12) -- 126
			local wood = Color(82, 58, 40, 245) -- 127
			local joint = math.max( -- 128
				1, -- 128
				cam:len(2) -- 128
			) -- 128
			fgDraw:drawSegment( -- 129
				Vec2(mx, my), -- 129
				Vec2(mx, hookY), -- 129
				joint, -- 129
				wood -- 129
			) -- 129
			fgDraw:drawSegment( -- 130
				Vec2(mx, hookY), -- 130
				Vec2(armX, hookY), -- 130
				joint, -- 130
				wood -- 130
			) -- 130
			fgDraw:drawSegment( -- 131
				Vec2( -- 131
					mx, -- 131
					hookY - cam:len(7) -- 131
				), -- 131
				Vec2(armX - joint, hookY), -- 131
				joint * 0.7, -- 131
				wood -- 131
			) -- 131
			if not assets:tryPlace( -- 131
				"prop_lantern", -- 132
				"path_lamp_" .. tostring(m.x), -- 132
				armX, -- 132
				lampY, -- 132
				cam:len(16), -- 132
				cam:len(20), -- 132
				{layer = 1} -- 132
			) then -- 132
				fgDraw:drawRect( -- 133
					Rect( -- 133
						armX - cam:len(4), -- 133
						lampY - cam:len(7), -- 133
						cam:len(8), -- 133
						cam:len(14) -- 133
					), -- 133
					Color(192, 136, 64, 240), -- 134
					1.4, -- 134
					wood -- 134
				) -- 134
			end -- 134
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 136
			fillRadialGlow( -- 137
				fgGlow, -- 137
				armX, -- 137
				lampY, -- 137
				cam:len(23), -- 137
				cam:len(27), -- 137
				Color(239, 182, 106, 46 * flame), -- 137
				Color(231, 164, 91, 0), -- 138
				16 -- 138
			) -- 138
		end -- 138
		::__continue19:: -- 138
	end -- 138
end -- 110
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 142
	local c = p.room.cart -- 151
	if c.bodyW <= 0 then -- 151
		return -- 153
	end -- 153
	local depth = c.depth or 0 -- 155
	local raised = p.room.depth ~= nil -- 156
	local lo = math.min(c.startX, c.endX) -- 159
	local hi = math.max(c.startX, c.endX) -- 160
	if hi - lo > 4 then -- 160
		local rx0 = cam:sx(lo) -- 162
		local rx1 = cam:sx(hi) -- 163
		local ry = cam:sy(c.baseY, depth) -- 164
		fgDraw:drawSegment( -- 165
			Vec2(rx0, ry + 1), -- 165
			Vec2(rx1, ry + 1), -- 165
			1.2, -- 165
			Color(86, 65, 47, 150) -- 165
		) -- 165
		local dockX = cam:sx(c.endX) -- 166
		local width = cam:len(24) -- 167
		local lip = cam:len(3) -- 168
		fgDraw:drawRect( -- 169
			Rect(dockX - width * 0.5, ry, width, lip), -- 169
			Color(51, 37, 26, 230) -- 169
		) -- 169
		fgDraw:drawRect( -- 170
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 170
			Color(107, 77, 51, 230) -- 170
		) -- 170
	end -- 170
	local axleX = p.cartAxle -- 173
	local cx = cam:sx(axleX) -- 174
	local baseY = cam:sy(c.baseY, depth) -- 175
	local bw = cam:len(c.bodyW) -- 176
	local bh = cam:len(c.bodyH) -- 177
	local wr = cam:len(c.wheelR) -- 178
	local x0 = cx - bw * 0.5 -- 180
	local x1 = cx + bw * 0.5 -- 181
	local bodyY0 = baseY + wr * 1.05 -- 182
	local bodyY1 = bodyY0 + bh -- 183
	local artWidth = c.bodyW * 1.36 -- 186
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 187
	local opacity = raised and occlusion:update("cart", { -- 188
		x0 = axleX - artWidth * 0.5, -- 189
		x1 = axleX + artWidth * 0.5, -- 189
		y0 = c.baseY, -- 190
		y1 = c.baseY + artHeight, -- 190
		depth = {min = depth, max = depth + 8}, -- 191
		passThrough = true -- 191
	}, p, fadeDt) or 1 -- 191
	fgDraw:drawEllipse( -- 193
		Vec2(cx, baseY + 2), -- 193
		bw * 0.62, -- 193
		5, -- 193
		Color(4, 6, 10, 150 * opacity) -- 193
	) -- 193
	local painted = assets:tryPlace( -- 195
		"prop_cart", -- 195
		"cart", -- 195
		cx, -- 195
		baseY, -- 195
		cam:len(artWidth), -- 195
		cam:len(artHeight), -- 195
		{ -- 195
			layer = raised and depthOrder(depth, 2) or 2, -- 196
			opacity = opacity, -- 196
			color = occlusionTint(opacity) -- 196
		} -- 196
	) -- 196
	if not painted then -- 196
		fillVGradRect( -- 200
			fgDraw, -- 200
			x0, -- 200
			bodyY0, -- 200
			bw, -- 200
			bh, -- 200
			Color(48, 32, 28, 255), -- 200
			toColor(PALETTE.cartWood) -- 200
		) -- 200
		fgDraw:drawRect( -- 201
			Rect(x0, bodyY0, bw, bh), -- 201
			Color(0, 0, 0, 0), -- 201
			1.6, -- 201
			toColor(PALETTE.cartMetal, 220) -- 201
		) -- 201
		fgDraw:drawSegment( -- 203
			Vec2(x0 + bw * 0.33, bodyY0), -- 203
			Vec2(x0 + bw * 0.33, bodyY1), -- 203
			1.4, -- 203
			toColor(PALETTE.cartMetal, 180) -- 203
		) -- 203
		fgDraw:drawSegment( -- 204
			Vec2(x0 + bw * 0.67, bodyY0), -- 204
			Vec2(x0 + bw * 0.67, bodyY1), -- 204
			1.4, -- 204
			toColor(PALETTE.cartMetal, 180) -- 204
		) -- 204
		fgDraw:drawSegment( -- 205
			Vec2(x0 - 2, bodyY1), -- 205
			Vec2(x1 + 2, bodyY1), -- 205
			2.2, -- 205
			toColor(PALETTE.rimSilver, 220) -- 205
		) -- 205
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 208
		local wxA = x0 + bw * 0.24 -- 209
		local wxB = x1 - bw * 0.24 -- 210
		local wy = baseY + wr -- 211
		self:drawWheel( -- 212
			fgDraw, -- 212
			wxA, -- 212
			wy, -- 212
			wr, -- 212
			wheelSpin -- 212
		) -- 212
		self:drawWheel( -- 213
			fgDraw, -- 213
			wxB, -- 213
			wy, -- 213
			wr, -- 213
			wheelSpin -- 213
		) -- 213
	end -- 213
	local hx = cam:sx(axleX + c.handleOffset) -- 217
	local hTop = bodyY1 + cam:len(9) -- 218
	local edge = c.handleOffset < 0 and x0 or x1 -- 219
	fgDraw:drawSegment( -- 220
		Vec2(edge, bodyY0 + bh * 0.55), -- 220
		Vec2( -- 220
			hx, -- 220
			hTop - cam:len(4) -- 220
		), -- 220
		math.max( -- 221
			2, -- 221
			cam:len(3) -- 221
		), -- 221
		toColor(PALETTE.cartWood, 255 * opacity) -- 221
	) -- 221
	fgDraw:drawSegment( -- 222
		Vec2( -- 222
			hx, -- 222
			hTop - cam:len(6) -- 222
		), -- 222
		Vec2(hx, hTop), -- 222
		math.max( -- 223
			2, -- 223
			cam:len(4) -- 223
		), -- 223
		Color(126, 91, 61, 255 * opacity) -- 223
	) -- 223
	if painted then -- 223
		return -- 226
	end -- 226
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 229
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 230
	local wave2 = math.cos(time * 2.8) * 3.5 -- 231
	local clothH = cam:len(26) -- 232
	local clothW = cam:len(14) -- 233
	fgDraw:drawPolygon( -- 234
		{ -- 234
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 235
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 236
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 237
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 238
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 239
		}, -- 239
		toColor(PALETTE.clothRed) -- 240
	) -- 240
	fgDraw:drawSegment( -- 242
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 243
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 244
		1.6, -- 245
		toColor(PALETTE.clothRedHighlight, 220) -- 246
	) -- 246
end -- 142
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 250
	draw:drawCircle( -- 251
		Vec2(cx, cy), -- 251
		r, -- 251
		Color(24, 28, 36, 255) -- 251
	) -- 251
	draw:drawRing( -- 252
		Vec2(cx, cy), -- 252
		r * 0.72, -- 252
		r, -- 252
		Color(0, 0, 0, 0), -- 252
		1.6, -- 252
		toColor(PALETTE.cartMetal) -- 252
	) -- 252
	local k = 0 -- 253
	do -- 253
		k = 0 -- 254
		while k < 4 do -- 254
			local a = spin + k * math.pi / 4 -- 255
			draw:drawSegment( -- 256
				Vec2( -- 257
					cx - math.cos(a) * r * 0.72, -- 257
					cy - math.sin(a) * r * 0.72 -- 257
				), -- 257
				Vec2( -- 258
					cx + math.cos(a) * r * 0.72, -- 258
					cy + math.sin(a) * r * 0.72 -- 258
				), -- 258
				1.2, -- 259
				toColor(PALETTE.steelLight, 190) -- 260
			) -- 260
			k = k + 1 -- 254
		end -- 254
	end -- 254
	draw:drawDot( -- 263
		Vec2(cx, cy), -- 263
		math.max(2.2, r * 0.18), -- 263
		toColor(PALETTE.rimSilver) -- 263
	) -- 263
end -- 250
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 266
	local bottle = p.room.bottle -- 275
	if bottle ~= nil then -- 275
		local bx0 = cam:sx(bottle.x - 16) -- 277
		local bx1 = cam:sx(bottle.x + 16) -- 278
		local by0 = cam:sy(0) -- 279
		local by1 = cam:sy(64) -- 280
		local beam = cam:len(3.4) -- 281
		local side = Color(78, 57, 41, 255) -- 282
		fgDraw:drawRect( -- 283
			Rect(bx0, by0, beam, by1 - by0), -- 283
			side -- 283
		) -- 283
		fgDraw:drawRect( -- 284
			Rect(bx1 - beam, by0, beam, by1 - by0), -- 284
			side -- 284
		) -- 284
		for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.45, by1 - beam}) do -- 285
			fgDraw:drawRect( -- 286
				Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 286
				Color(106, 78, 56, 255), -- 287
				1, -- 287
				Color(56, 42, 34, 240) -- 287
			) -- 287
		end -- 287
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 287
			self:drawBottleSprite( -- 290
				fgDraw, -- 290
				assets, -- 290
				"bottle_shelf", -- 290
				cam:sx(bottle.x), -- 290
				cam:sy(70), -- 290
				cam.ppu, -- 290
				0 -- 290
			) -- 290
		end -- 290
	end -- 290
	local arch = p.room.arch -- 294
	local tx0 = cam:sx(arch.x0 - 4) -- 295
	local tx1 = cam:sx(arch.x1 + 4) -- 296
	local ty0 = cam:sy(arch.y) -- 297
	local tyBot = cam:sy(arch.y + arch.h) -- 298
	local tyTop = cam:sy(arch.y + arch.h + 7) -- 299
	fillVGradRect( -- 300
		fgDraw, -- 300
		tx0 + 6, -- 300
		ty0, -- 300
		tx1 - tx0 - 12, -- 300
		tyBot - ty0, -- 300
		Color(9, 10, 15, 165), -- 301
		Color(9, 10, 15, 100) -- 301
	) -- 301
	if not assets:tryPlace( -- 301
		"prop_table", -- 302
		"village_table", -- 302
		(tx0 + tx1) * 0.5, -- 302
		ty0, -- 302
		tx1 - tx0, -- 303
		tyTop - ty0, -- 303
		{layer = 6} -- 303
	) then -- 303
		fgDraw:drawRect( -- 304
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 304
			toColor(PALETTE.cartWood) -- 304
		) -- 304
		fgDraw:drawRect( -- 305
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 305
			toColor(PALETTE.cartWood) -- 305
		) -- 305
		fgDraw:drawRect( -- 306
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 306
			toColor(PALETTE.cartWood) -- 306
		) -- 306
	end -- 306
	if p.hasBottle then -- 306
		local pl = p.player -- 311
		self:drawBottleSprite( -- 312
			fgDraw, -- 312
			assets, -- 312
			"bottle_held", -- 312
			cam:sx(pl.x + pl.facing * 12), -- 312
			cam:sy(pl.y + pl.h * 0.56), -- 312
			cam.ppu, -- 312
			pl.facing * 0.2 -- 312
		) -- 312
	end -- 312
	if p.bottleFly ~= nil then -- 312
		self:drawBottleSprite( -- 315
			fgDraw, -- 315
			assets, -- 315
			"bottle_air", -- 315
			cam:sx(p.bottleFly.x), -- 315
			cam:sy(p.bottleFly.y), -- 315
			cam.ppu, -- 315
			time * 14 -- 315
		) -- 315
	end -- 315
	if p.hasBottle and p.aimHold > 0 then -- 315
		local pl = p.player -- 320
		local endX = p.bottleAimX -- 321
		local endY = p.bottleAimY -- 322
		if endX < 0 then -- 322
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 324
			endX = wAim.x -- 325
			endY = 0 -- 326
		end -- 326
		local dir = endX >= pl.x and 1 or -1 -- 328
		local x0 = pl.x + dir * 10 -- 329
		local y0 = pl.y + pl.h * 0.7 -- 330
		local T = 0.62 -- 331
		local vx = (endX - x0) / T -- 332
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 333
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 335
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 336
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 337
		local activeAim = p.aimHold > 0.01 -- 338
		local steps = 18 -- 340
		local k = 1 -- 341
		do -- 341
			k = 1 -- 342
			while k <= steps do -- 342
				local tt = k / steps * T -- 343
				local wx = x0 + vx * tt -- 344
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 345
				local sx = cam:sx(wx) -- 346
				local sy = cam:sy(wy) -- 347
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 348
				fgGlow:drawDot( -- 349
					Vec2(sx, sy), -- 349
					activeAim and 3.2 or 2.2, -- 349
					toColor(arcCol, alpha) -- 349
				) -- 349
				k = k + 1 -- 342
			end -- 342
		end -- 342
		local lx = cam:sx(endX) -- 352
		local ly = cam:sy(endY + 2) -- 353
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 354
		fgGlow:drawRing( -- 355
			Vec2(lx, ly), -- 355
			8, -- 355
			11, -- 355
			Color(0, 0, 0, 0), -- 355
			1.6, -- 355
			toColor(arcCol, activeAim and 245 or 165) -- 355
		) -- 355
		if isBrick then -- 355
			fgGlow:drawRing( -- 357
				Vec2(lx, ly), -- 357
				28 * pulse, -- 357
				30 * pulse, -- 357
				Color(0, 0, 0, 0), -- 357
				1.2, -- 357
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 357
			) -- 357
			fillRadialGlow( -- 358
				fgGlow, -- 358
				lx, -- 358
				ly, -- 358
				36, -- 358
				14, -- 358
				Color(242, 188, 96, activeAim and 95 or 48), -- 358
				Color(242, 188, 96, 0), -- 358
				14 -- 358
			) -- 358
		end -- 358
	end -- 358
end -- 266
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 363
	local height = math.max(12, ppu * 13) -- 370
	if not assets:tryPlace( -- 370
		"prop_bottle", -- 371
		id, -- 371
		cx, -- 371
		cy, -- 371
		height, -- 371
		height, -- 371
		{angle = tilt * 180 / math.pi, layer = 6} -- 371
	) then -- 371
		local dx = math.sin(tilt) * height * 0.4 -- 374
		local dy = math.cos(tilt) * height * 0.5 -- 375
		fgDraw:drawSegment( -- 376
			Vec2(cx - dx, cy - dy), -- 376
			Vec2(cx + dx, cy + dy), -- 376
			height * 0.32, -- 376
			toColor(PALETTE.amber, 225) -- 377
		) -- 377
	end -- 377
end -- 363
return ____exports -- 363