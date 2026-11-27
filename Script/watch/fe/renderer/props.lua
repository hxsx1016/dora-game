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
			if pickup.id == "" or p.run.taken[pickup.id] then -- 54
				goto __continue7 -- 56
			end -- 56
			local depth = pickup.depth or 0 -- 58
			local isWood = kind == "wood" or kind == "scrap" or kind == "wedge" -- 59
			local isMetal = kind == "bell" or kind == "shield" or kind == "ammo" or kind == "pass" or kind == "quickbelt" -- 60
			if not isWood and not isMetal then -- 60
				goto __continue7 -- 62
			end -- 62
			local tint = (kind == "wood" or kind == "scrap") and PALETTE.amber or (kind == "wedge" and PALETTE.emerald or ((kind == "shield" or kind == "ammo") and PALETTE.cyan or PALETTE.amberCore)) -- 64
			assets:tryPlace( -- 67
				isWood and "ink_bamboo_slip" or "prop_compass", -- 68
				"pickup_" .. pickup.id, -- 69
				cam:sx(pickup.x), -- 70
				cam:sy(pickup.y + 9, depth), -- 70
				cam:len(18), -- 71
				cam:len(isWood and 7 or 16), -- 71
				{ -- 72
					angle = isWood and 65 or 0, -- 73
					color = toColor(tint), -- 74
					layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 75
				} -- 75
			) -- 75
		end -- 75
		::__continue7:: -- 75
	end -- 75
end -- 51
function PropsRenderer.prototype.drawZones(self, fgDraw, p, cam) -- 81
	local i = 0 -- 86
	do -- 86
		i = 0 -- 87
		while i < #p.room.zones do -- 87
			local z = p.room.zones[i + 1] -- 88
			local x0 = cam:sx(z.x0) -- 89
			local x1 = cam:sx(z.x1) -- 90
			local y0 = cam:sy(z.y) -- 91
			local zw = x1 - x0 -- 92
			if z.tint == 1 then -- 92
				local road = p.room.depth -- 95
				local front = cam:sy(z.y, road and road.min or -3) -- 96
				local back = cam:sy(z.y, road and road.max or 1) -- 97
				fgDraw:drawRect( -- 98
					Rect(x0, front, zw, back - front), -- 98
					Color(50, 35, 29, 48) -- 98
				) -- 98
			elseif z.tint == 2 then -- 98
				fgDraw:drawRect( -- 101
					Rect(x0, y0 - 4, zw, 8), -- 101
					Color(74, 58, 44, 220) -- 101
				) -- 101
				fgDraw:drawSegment( -- 102
					Vec2(x0, y0 + 2), -- 102
					Vec2(x1, y0 + 2), -- 102
					1.4, -- 102
					Color(128, 98, 72, 190) -- 102
				) -- 102
			elseif z.tint == 3 then -- 102
				fgDraw:drawRect( -- 105
					Rect(x0, y0 - 4, zw, 9), -- 105
					Color(118, 122, 130, 235) -- 105
				) -- 105
				local bricks = 4 -- 106
				local b = 1 -- 107
				do -- 107
					b = 1 -- 108
					while b < bricks do -- 108
						local bx = x0 + zw * b / bricks -- 109
						fgDraw:drawSegment( -- 110
							Vec2(bx, y0 - 4), -- 110
							Vec2(bx, y0 + 5), -- 110
							1, -- 110
							Color(42, 46, 56, 220) -- 110
						) -- 110
						b = b + 1 -- 108
					end -- 108
				end -- 108
				fgDraw:drawSegment( -- 112
					Vec2(x0, y0 + 4), -- 112
					Vec2(x1, y0 + 4), -- 112
					1.1, -- 112
					Color(168, 151, 127, 130) -- 112
				) -- 112
			end -- 112
			i = i + 1 -- 87
		end -- 87
	end -- 87
end -- 81
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 117
	for ____, m in ipairs(p.room.marks) do -- 125
		do -- 125
			if m.kind ~= 6 then -- 125
				goto __continue20 -- 127
			end -- 127
			local mx = cam:sx(m.x) -- 129
			local my = cam:sy(m.y) -- 130
			local hookY = my + cam:len(52) -- 131
			local armX = mx + cam:len(13) -- 132
			local lampY = hookY - cam:len(12) -- 133
			local wood = Color(82, 58, 40, 245) -- 134
			local joint = math.max( -- 135
				1, -- 135
				cam:len(2) -- 135
			) -- 135
			fgDraw:drawSegment( -- 136
				Vec2(mx, my), -- 136
				Vec2(mx, hookY), -- 136
				joint, -- 136
				wood -- 136
			) -- 136
			fgDraw:drawSegment( -- 137
				Vec2(mx, hookY), -- 137
				Vec2(armX, hookY), -- 137
				joint, -- 137
				wood -- 137
			) -- 137
			fgDraw:drawSegment( -- 138
				Vec2( -- 138
					mx, -- 138
					hookY - cam:len(7) -- 138
				), -- 138
				Vec2(armX - joint, hookY), -- 138
				joint * 0.7, -- 138
				wood -- 138
			) -- 138
			if not assets:tryPlace( -- 138
				"prop_lantern", -- 139
				"path_lamp_" .. tostring(m.x), -- 139
				armX, -- 139
				lampY, -- 139
				cam:len(16), -- 139
				cam:len(20), -- 139
				{layer = 1} -- 139
			) then -- 139
				fgDraw:drawRect( -- 140
					Rect( -- 140
						armX - cam:len(4), -- 140
						lampY - cam:len(7), -- 140
						cam:len(8), -- 140
						cam:len(14) -- 140
					), -- 140
					Color(192, 136, 64, 240), -- 141
					1.4, -- 141
					wood -- 141
				) -- 141
			end -- 141
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 143
			fillRadialGlow( -- 144
				fgGlow, -- 144
				armX, -- 144
				lampY, -- 144
				cam:len(23), -- 144
				cam:len(27), -- 144
				Color(239, 182, 106, 46 * flame), -- 144
				Color(231, 164, 91, 0), -- 145
				16 -- 145
			) -- 145
		end -- 145
		::__continue20:: -- 145
	end -- 145
end -- 117
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 149
	local c = p.room.cart -- 158
	if c.bodyW <= 0 then -- 158
		return -- 160
	end -- 160
	local depth = c.depth or 0 -- 162
	local raised = p.room.depth ~= nil -- 163
	local lo = math.min(c.startX, c.endX) -- 166
	local hi = math.max(c.startX, c.endX) -- 167
	if hi - lo > 4 then -- 167
		local rx0 = cam:sx(lo) -- 169
		local rx1 = cam:sx(hi) -- 170
		local ry = cam:sy(c.baseY, depth) -- 171
		fgDraw:drawSegment( -- 172
			Vec2(rx0, ry + 1), -- 172
			Vec2(rx1, ry + 1), -- 172
			1.2, -- 172
			Color(86, 65, 47, 150) -- 172
		) -- 172
		local dockX = cam:sx(c.endX) -- 173
		local width = cam:len(24) -- 174
		local lip = cam:len(3) -- 175
		fgDraw:drawRect( -- 176
			Rect(dockX - width * 0.5, ry, width, lip), -- 176
			Color(51, 37, 26, 230) -- 176
		) -- 176
		fgDraw:drawRect( -- 177
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 177
			Color(107, 77, 51, 230) -- 177
		) -- 177
	end -- 177
	local axleX = p.cartAxle -- 180
	local cx = cam:sx(axleX) -- 181
	local baseY = cam:sy(c.baseY, depth) -- 182
	local bw = cam:len(c.bodyW) -- 183
	local bh = cam:len(c.bodyH) -- 184
	local wr = cam:len(c.wheelR) -- 185
	local x0 = cx - bw * 0.5 -- 187
	local x1 = cx + bw * 0.5 -- 188
	local bodyY0 = baseY + wr * 1.05 -- 189
	local bodyY1 = bodyY0 + bh -- 190
	local artWidth = c.bodyW * 1.36 -- 193
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 194
	local opacity = raised and occlusion:update("cart", { -- 195
		x0 = axleX - artWidth * 0.5, -- 196
		x1 = axleX + artWidth * 0.5, -- 196
		y0 = c.baseY, -- 197
		y1 = c.baseY + artHeight, -- 197
		depth = {min = depth, max = depth + 8}, -- 198
		passThrough = true -- 198
	}, p, fadeDt) or 1 -- 198
	fgDraw:drawEllipse( -- 200
		Vec2(cx, baseY + 2), -- 200
		bw * 0.62, -- 200
		5, -- 200
		Color(4, 6, 10, 150 * opacity) -- 200
	) -- 200
	local painted = assets:tryPlace( -- 202
		"prop_cart", -- 202
		"cart", -- 202
		cx, -- 202
		baseY, -- 202
		cam:len(artWidth), -- 202
		cam:len(artHeight), -- 202
		{ -- 202
			layer = raised and depthOrder(depth, 2) or 2, -- 203
			opacity = opacity, -- 203
			color = occlusionTint(opacity) -- 203
		} -- 203
	) -- 203
	if not painted then -- 203
		fillVGradRect( -- 207
			fgDraw, -- 207
			x0, -- 207
			bodyY0, -- 207
			bw, -- 207
			bh, -- 207
			Color(48, 32, 28, 255), -- 207
			toColor(PALETTE.cartWood) -- 207
		) -- 207
		fgDraw:drawRect( -- 208
			Rect(x0, bodyY0, bw, bh), -- 208
			Color(0, 0, 0, 0), -- 208
			1.6, -- 208
			toColor(PALETTE.cartMetal, 220) -- 208
		) -- 208
		fgDraw:drawSegment( -- 210
			Vec2(x0 + bw * 0.33, bodyY0), -- 210
			Vec2(x0 + bw * 0.33, bodyY1), -- 210
			1.4, -- 210
			toColor(PALETTE.cartMetal, 180) -- 210
		) -- 210
		fgDraw:drawSegment( -- 211
			Vec2(x0 + bw * 0.67, bodyY0), -- 211
			Vec2(x0 + bw * 0.67, bodyY1), -- 211
			1.4, -- 211
			toColor(PALETTE.cartMetal, 180) -- 211
		) -- 211
		fgDraw:drawSegment( -- 212
			Vec2(x0 - 2, bodyY1), -- 212
			Vec2(x1 + 2, bodyY1), -- 212
			2.2, -- 212
			toColor(PALETTE.rimSilver, 220) -- 212
		) -- 212
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 215
		local wxA = x0 + bw * 0.24 -- 216
		local wxB = x1 - bw * 0.24 -- 217
		local wy = baseY + wr -- 218
		self:drawWheel( -- 219
			fgDraw, -- 219
			wxA, -- 219
			wy, -- 219
			wr, -- 219
			wheelSpin -- 219
		) -- 219
		self:drawWheel( -- 220
			fgDraw, -- 220
			wxB, -- 220
			wy, -- 220
			wr, -- 220
			wheelSpin -- 220
		) -- 220
	end -- 220
	local hx = cam:sx(axleX + c.handleOffset) -- 224
	local hTop = bodyY1 + cam:len(7) -- 225
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 226
	local handleSpan = math.abs(hx - edge) -- 229
	if not painted or handleSpan > cam:len(4) then -- 229
		fgDraw:drawSegment( -- 231
			Vec2(edge, bodyY0 + bh * 0.52), -- 231
			Vec2( -- 231
				hx, -- 231
				hTop - cam:len(4) -- 231
			), -- 231
			math.max( -- 232
				1.8, -- 232
				cam:len(2.4) -- 232
			), -- 232
			toColor(PALETTE.cartWood, 245 * opacity) -- 232
		) -- 232
		fgDraw:drawSegment( -- 233
			Vec2( -- 233
				hx, -- 233
				hTop - cam:len(5.5) -- 233
			), -- 233
			Vec2(hx, hTop), -- 233
			math.max( -- 234
				2.2, -- 234
				cam:len(3.2) -- 234
			), -- 234
			Color(126, 91, 61, 245 * opacity) -- 234
		) -- 234
	end -- 234
	if painted then -- 234
		return -- 238
	end -- 238
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 241
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 242
	local wave2 = math.cos(time * 2.8) * 3.5 -- 243
	local clothH = cam:len(26) -- 244
	local clothW = cam:len(14) -- 245
	fgDraw:drawPolygon( -- 246
		{ -- 246
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 247
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 248
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 249
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 250
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 251
		}, -- 251
		toColor(PALETTE.clothRed) -- 252
	) -- 252
	fgDraw:drawSegment( -- 254
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 255
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 256
		1.6, -- 257
		toColor(PALETTE.clothRedHighlight, 220) -- 258
	) -- 258
end -- 149
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 262
	draw:drawCircle( -- 263
		Vec2(cx, cy), -- 263
		r, -- 263
		Color(24, 28, 36, 255) -- 263
	) -- 263
	draw:drawRing( -- 264
		Vec2(cx, cy), -- 264
		r * 0.72, -- 264
		r, -- 264
		Color(0, 0, 0, 0), -- 264
		1.6, -- 264
		toColor(PALETTE.cartMetal) -- 264
	) -- 264
	local k = 0 -- 265
	do -- 265
		k = 0 -- 266
		while k < 4 do -- 266
			local a = spin + k * math.pi / 4 -- 267
			draw:drawSegment( -- 268
				Vec2( -- 269
					cx - math.cos(a) * r * 0.72, -- 269
					cy - math.sin(a) * r * 0.72 -- 269
				), -- 269
				Vec2( -- 270
					cx + math.cos(a) * r * 0.72, -- 270
					cy + math.sin(a) * r * 0.72 -- 270
				), -- 270
				1.2, -- 271
				toColor(PALETTE.steelLight, 190) -- 272
			) -- 272
			k = k + 1 -- 266
		end -- 266
	end -- 266
	draw:drawDot( -- 275
		Vec2(cx, cy), -- 275
		math.max(2.2, r * 0.18), -- 275
		toColor(PALETTE.rimSilver) -- 275
	) -- 275
end -- 262
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 278
	local bottle = p.room.bottle -- 287
	if bottle ~= nil then -- 287
		local bx0 = cam:sx(bottle.x - 16) -- 289
		local bx1 = cam:sx(bottle.x + 16) -- 290
		local by0 = cam:sy(0) -- 291
		local by1 = cam:sy(52) -- 292
		local beam = cam:len(3.2) -- 293
		local side = Color(78, 57, 41, 255) -- 294
		fgDraw:drawRect( -- 295
			Rect(bx0, by0, beam, by1 - by0), -- 295
			side -- 295
		) -- 295
		fgDraw:drawRect( -- 296
			Rect(bx1 - beam, by0, beam, by1 - by0), -- 296
			side -- 296
		) -- 296
		for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 297
			fgDraw:drawRect( -- 298
				Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 298
				Color(106, 78, 56, 255), -- 299
				1, -- 299
				Color(56, 42, 34, 240) -- 299
			) -- 299
		end -- 299
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 299
			self:drawBottleSprite( -- 302
				fgDraw, -- 302
				assets, -- 302
				"bottle_shelf", -- 302
				cam:sx(bottle.x), -- 302
				cam:sy(56), -- 302
				cam.ppu, -- 302
				0 -- 302
			) -- 302
		end -- 302
	end -- 302
	local arch = p.room.arch -- 306
	local tx0 = cam:sx(arch.x0 - 4) -- 307
	local tx1 = cam:sx(arch.x1 + 4) -- 308
	local ty0 = cam:sy(arch.y) -- 309
	local tyBot = cam:sy(arch.y + arch.h) -- 310
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 311
	fillVGradRect( -- 312
		fgDraw, -- 312
		tx0 + 6, -- 312
		ty0, -- 312
		tx1 - tx0 - 12, -- 312
		tyBot - ty0, -- 312
		Color(9, 10, 15, 165), -- 313
		Color(9, 10, 15, 100) -- 313
	) -- 313
	if not assets:tryPlace( -- 313
		"prop_table", -- 314
		"village_table", -- 314
		(tx0 + tx1) * 0.5, -- 314
		ty0, -- 314
		tx1 - tx0, -- 315
		tyTop - ty0, -- 315
		{layer = 6} -- 315
	) then -- 315
		fgDraw:drawRect( -- 316
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 316
			toColor(PALETTE.cartWood) -- 316
		) -- 316
		fgDraw:drawRect( -- 317
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 317
			toColor(PALETTE.cartWood) -- 317
		) -- 317
		fgDraw:drawRect( -- 318
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 318
			toColor(PALETTE.cartWood) -- 318
		) -- 318
	end -- 318
	if p.hasBottle and p.aimHold <= 0 then -- 318
		local pl = p.player -- 323
		self:drawBottleSprite( -- 324
			fgDraw, -- 324
			assets, -- 324
			"bottle_held", -- 324
			cam:sx(pl.x + pl.facing * 10), -- 324
			cam:sy(pl.y + pl.h * 0.52), -- 324
			cam.ppu, -- 324
			pl.facing * 0.2 -- 324
		) -- 324
	end -- 324
	if p.bottleFly ~= nil then -- 324
		self:drawBottleSprite( -- 327
			fgDraw, -- 327
			assets, -- 327
			"bottle_air", -- 327
			cam:sx(p.bottleFly.x), -- 327
			cam:sy(p.bottleFly.y), -- 327
			cam.ppu, -- 327
			time * 14 -- 327
		) -- 327
	end -- 327
	if p.hasBottle and p.aimHold > 0 then -- 327
		local pl = p.player -- 332
		local endX = p.bottleAimX -- 333
		local endY = p.bottleAimY -- 334
		if endX < 0 then -- 334
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 336
			endX = wAim.x -- 337
			endY = 0 -- 338
		end -- 338
		local dir = endX >= pl.x and 1 or -1 -- 340
		local x0 = pl.x + dir * 10 -- 341
		local y0 = pl.y + pl.h * 0.7 -- 342
		local T = 0.62 -- 343
		local vx = (endX - x0) / T -- 344
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 345
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 347
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 348
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 349
		local activeAim = p.aimHold > 0.01 -- 350
		local steps = 18 -- 352
		local k = 1 -- 353
		do -- 353
			k = 1 -- 354
			while k <= steps do -- 354
				local tt = k / steps * T -- 355
				local wx = x0 + vx * tt -- 356
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 357
				local sx = cam:sx(wx) -- 358
				local sy = cam:sy(wy) -- 359
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 360
				fgGlow:drawDot( -- 361
					Vec2(sx, sy), -- 361
					activeAim and 3.2 or 2.2, -- 361
					toColor(arcCol, alpha) -- 361
				) -- 361
				k = k + 1 -- 354
			end -- 354
		end -- 354
		local lx = cam:sx(endX) -- 364
		local ly = cam:sy(endY + 2) -- 365
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 366
		fgGlow:drawRing( -- 367
			Vec2(lx, ly), -- 367
			8, -- 367
			11, -- 367
			Color(0, 0, 0, 0), -- 367
			1.6, -- 367
			toColor(arcCol, activeAim and 245 or 165) -- 367
		) -- 367
		if isBrick then -- 367
			fgGlow:drawRing( -- 369
				Vec2(lx, ly), -- 369
				28 * pulse, -- 369
				30 * pulse, -- 369
				Color(0, 0, 0, 0), -- 369
				1.2, -- 369
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 369
			) -- 369
			fillRadialGlow( -- 370
				fgGlow, -- 370
				lx, -- 370
				ly, -- 370
				36, -- 370
				14, -- 370
				Color(242, 188, 96, activeAim and 95 or 48), -- 370
				Color(242, 188, 96, 0), -- 370
				14 -- 370
			) -- 370
		end -- 370
	end -- 370
end -- 278
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 375
	local height = math.max(10, ppu * 10.5) -- 382
	if not assets:tryPlace( -- 382
		"prop_bottle", -- 383
		id, -- 383
		cx, -- 383
		cy, -- 383
		height, -- 383
		height, -- 383
		{angle = tilt * 180 / math.pi, layer = 6} -- 383
	) then -- 383
		local dx = math.sin(tilt) * height * 0.4 -- 386
		local dy = math.cos(tilt) * height * 0.5 -- 387
		fgDraw:drawSegment( -- 388
			Vec2(cx - dx, cy - dy), -- 388
			Vec2(cx + dx, cy + dy), -- 388
			height * 0.32, -- 388
			toColor(PALETTE.amber, 225) -- 389
		) -- 389
	end -- 389
end -- 375
return ____exports -- 375