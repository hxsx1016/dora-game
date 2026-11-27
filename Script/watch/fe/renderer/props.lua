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
			if pickup.id == "" or p.run.taken[pickup.id] or kind ~= "wood" and kind ~= "bell" then -- 54
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
	local hTop = bodyY1 + cam:len(7) -- 218
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 219
	local handleSpan = math.abs(hx - edge) -- 222
	if not painted or handleSpan > cam:len(4) then -- 222
		fgDraw:drawSegment( -- 224
			Vec2(edge, bodyY0 + bh * 0.52), -- 224
			Vec2( -- 224
				hx, -- 224
				hTop - cam:len(4) -- 224
			), -- 224
			math.max( -- 225
				1.8, -- 225
				cam:len(2.4) -- 225
			), -- 225
			toColor(PALETTE.cartWood, 245 * opacity) -- 225
		) -- 225
		fgDraw:drawSegment( -- 226
			Vec2( -- 226
				hx, -- 226
				hTop - cam:len(5.5) -- 226
			), -- 226
			Vec2(hx, hTop), -- 226
			math.max( -- 227
				2.2, -- 227
				cam:len(3.2) -- 227
			), -- 227
			Color(126, 91, 61, 245 * opacity) -- 227
		) -- 227
	end -- 227
	if painted then -- 227
		return -- 231
	end -- 231
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 234
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 235
	local wave2 = math.cos(time * 2.8) * 3.5 -- 236
	local clothH = cam:len(26) -- 237
	local clothW = cam:len(14) -- 238
	fgDraw:drawPolygon( -- 239
		{ -- 239
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 240
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 241
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 242
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 243
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 244
		}, -- 244
		toColor(PALETTE.clothRed) -- 245
	) -- 245
	fgDraw:drawSegment( -- 247
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 248
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 249
		1.6, -- 250
		toColor(PALETTE.clothRedHighlight, 220) -- 251
	) -- 251
end -- 142
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 255
	draw:drawCircle( -- 256
		Vec2(cx, cy), -- 256
		r, -- 256
		Color(24, 28, 36, 255) -- 256
	) -- 256
	draw:drawRing( -- 257
		Vec2(cx, cy), -- 257
		r * 0.72, -- 257
		r, -- 257
		Color(0, 0, 0, 0), -- 257
		1.6, -- 257
		toColor(PALETTE.cartMetal) -- 257
	) -- 257
	local k = 0 -- 258
	do -- 258
		k = 0 -- 259
		while k < 4 do -- 259
			local a = spin + k * math.pi / 4 -- 260
			draw:drawSegment( -- 261
				Vec2( -- 262
					cx - math.cos(a) * r * 0.72, -- 262
					cy - math.sin(a) * r * 0.72 -- 262
				), -- 262
				Vec2( -- 263
					cx + math.cos(a) * r * 0.72, -- 263
					cy + math.sin(a) * r * 0.72 -- 263
				), -- 263
				1.2, -- 264
				toColor(PALETTE.steelLight, 190) -- 265
			) -- 265
			k = k + 1 -- 259
		end -- 259
	end -- 259
	draw:drawDot( -- 268
		Vec2(cx, cy), -- 268
		math.max(2.2, r * 0.18), -- 268
		toColor(PALETTE.rimSilver) -- 268
	) -- 268
end -- 255
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 271
	local bottle = p.room.bottle -- 280
	if bottle ~= nil then -- 280
		local bx0 = cam:sx(bottle.x - 16) -- 282
		local bx1 = cam:sx(bottle.x + 16) -- 283
		local by0 = cam:sy(0) -- 284
		local by1 = cam:sy(52) -- 285
		local beam = cam:len(3.2) -- 286
		local side = Color(78, 57, 41, 255) -- 287
		fgDraw:drawRect( -- 288
			Rect(bx0, by0, beam, by1 - by0), -- 288
			side -- 288
		) -- 288
		fgDraw:drawRect( -- 289
			Rect(bx1 - beam, by0, beam, by1 - by0), -- 289
			side -- 289
		) -- 289
		for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 290
			fgDraw:drawRect( -- 291
				Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 291
				Color(106, 78, 56, 255), -- 292
				1, -- 292
				Color(56, 42, 34, 240) -- 292
			) -- 292
		end -- 292
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 292
			self:drawBottleSprite( -- 295
				fgDraw, -- 295
				assets, -- 295
				"bottle_shelf", -- 295
				cam:sx(bottle.x), -- 295
				cam:sy(56), -- 295
				cam.ppu, -- 295
				0 -- 295
			) -- 295
		end -- 295
	end -- 295
	local arch = p.room.arch -- 299
	local tx0 = cam:sx(arch.x0 - 4) -- 300
	local tx1 = cam:sx(arch.x1 + 4) -- 301
	local ty0 = cam:sy(arch.y) -- 302
	local tyBot = cam:sy(arch.y + arch.h) -- 303
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 304
	fillVGradRect( -- 305
		fgDraw, -- 305
		tx0 + 6, -- 305
		ty0, -- 305
		tx1 - tx0 - 12, -- 305
		tyBot - ty0, -- 305
		Color(9, 10, 15, 165), -- 306
		Color(9, 10, 15, 100) -- 306
	) -- 306
	if not assets:tryPlace( -- 306
		"prop_table", -- 307
		"village_table", -- 307
		(tx0 + tx1) * 0.5, -- 307
		ty0, -- 307
		tx1 - tx0, -- 308
		tyTop - ty0, -- 308
		{layer = 6} -- 308
	) then -- 308
		fgDraw:drawRect( -- 309
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 309
			toColor(PALETTE.cartWood) -- 309
		) -- 309
		fgDraw:drawRect( -- 310
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 310
			toColor(PALETTE.cartWood) -- 310
		) -- 310
		fgDraw:drawRect( -- 311
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 311
			toColor(PALETTE.cartWood) -- 311
		) -- 311
	end -- 311
	if p.hasBottle and p.aimHold <= 0 then -- 311
		local pl = p.player -- 316
		self:drawBottleSprite( -- 317
			fgDraw, -- 317
			assets, -- 317
			"bottle_held", -- 317
			cam:sx(pl.x + pl.facing * 10), -- 317
			cam:sy(pl.y + pl.h * 0.52), -- 317
			cam.ppu, -- 317
			pl.facing * 0.2 -- 317
		) -- 317
	end -- 317
	if p.bottleFly ~= nil then -- 317
		self:drawBottleSprite( -- 320
			fgDraw, -- 320
			assets, -- 320
			"bottle_air", -- 320
			cam:sx(p.bottleFly.x), -- 320
			cam:sy(p.bottleFly.y), -- 320
			cam.ppu, -- 320
			time * 14 -- 320
		) -- 320
	end -- 320
	if p.hasBottle and p.aimHold > 0 then -- 320
		local pl = p.player -- 325
		local endX = p.bottleAimX -- 326
		local endY = p.bottleAimY -- 327
		if endX < 0 then -- 327
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 329
			endX = wAim.x -- 330
			endY = 0 -- 331
		end -- 331
		local dir = endX >= pl.x and 1 or -1 -- 333
		local x0 = pl.x + dir * 10 -- 334
		local y0 = pl.y + pl.h * 0.7 -- 335
		local T = 0.62 -- 336
		local vx = (endX - x0) / T -- 337
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 338
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 340
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 341
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 342
		local activeAim = p.aimHold > 0.01 -- 343
		local steps = 18 -- 345
		local k = 1 -- 346
		do -- 346
			k = 1 -- 347
			while k <= steps do -- 347
				local tt = k / steps * T -- 348
				local wx = x0 + vx * tt -- 349
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 350
				local sx = cam:sx(wx) -- 351
				local sy = cam:sy(wy) -- 352
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 353
				fgGlow:drawDot( -- 354
					Vec2(sx, sy), -- 354
					activeAim and 3.2 or 2.2, -- 354
					toColor(arcCol, alpha) -- 354
				) -- 354
				k = k + 1 -- 347
			end -- 347
		end -- 347
		local lx = cam:sx(endX) -- 357
		local ly = cam:sy(endY + 2) -- 358
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 359
		fgGlow:drawRing( -- 360
			Vec2(lx, ly), -- 360
			8, -- 360
			11, -- 360
			Color(0, 0, 0, 0), -- 360
			1.6, -- 360
			toColor(arcCol, activeAim and 245 or 165) -- 360
		) -- 360
		if isBrick then -- 360
			fgGlow:drawRing( -- 362
				Vec2(lx, ly), -- 362
				28 * pulse, -- 362
				30 * pulse, -- 362
				Color(0, 0, 0, 0), -- 362
				1.2, -- 362
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 362
			) -- 362
			fillRadialGlow( -- 363
				fgGlow, -- 363
				lx, -- 363
				ly, -- 363
				36, -- 363
				14, -- 363
				Color(242, 188, 96, activeAim and 95 or 48), -- 363
				Color(242, 188, 96, 0), -- 363
				14 -- 363
			) -- 363
		end -- 363
	end -- 363
end -- 271
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 368
	local height = math.max(10, ppu * 10.5) -- 375
	if not assets:tryPlace( -- 375
		"prop_bottle", -- 376
		id, -- 376
		cx, -- 376
		cy, -- 376
		height, -- 376
		height, -- 376
		{angle = tilt * 180 / math.pi, layer = 6} -- 376
	) then -- 376
		local dx = math.sin(tilt) * height * 0.4 -- 379
		local dy = math.cos(tilt) * height * 0.5 -- 380
		fgDraw:drawSegment( -- 381
			Vec2(cx - dx, cy - dy), -- 381
			Vec2(cx + dx, cy + dy), -- 381
			height * 0.32, -- 381
			toColor(PALETTE.amber, 225) -- 382
		) -- 382
	end -- 382
end -- 368
return ____exports -- 368