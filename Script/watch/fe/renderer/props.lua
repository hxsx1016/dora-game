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
	self:drawZones(fgDraw, assets, p, cam) -- 35
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
	self:drawBracedShield(fgDraw, assets, p, cam) -- 38
	self:drawCraftMaterials(assets, p, cam) -- 39
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
end -- 25
function PropsRenderer.prototype.drawBracedShield(self, fgDraw, assets, p, cam) -- 53
	local sh = p.bracedShield -- 54
	if sh == nil or sh.hp <= 0 then -- 54
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
	if not assets:tryPlace( -- 62
		"fe_braced_shield", -- 63
		"braced_shield", -- 63
		cx, -- 63
		by, -- 63
		cam:len(26), -- 63
		h * 1.05, -- 63
		{layer = p.room.depth == nil and 4 or depthOrder(p.player.depth, 4)} -- 63
	) then -- 63
		fgDraw:drawRect( -- 66
			Rect(cx - w * 0.5, by + 2, w, h - 2), -- 66
			Color(104, 72, 46, 248), -- 66
			1.4, -- 66
			Color(172, 178, 184, 235) -- 66
		) -- 66
	end -- 66
end -- 53
function PropsRenderer.prototype.drawCraftMaterials(self, assets, p, cam) -- 70
	for ____, pickup in ipairs(p.pickups) do -- 71
		do -- 71
			local kind = pickup.kind -- 73
			if pickup.id == "" or p.run.taken[pickup.id] then -- 73
				goto __continue10 -- 75
			end -- 75
			local depth = pickup.depth or 0 -- 77
			local isWood = kind == "wood" or kind == "scrap" or kind == "wedge" -- 78
			local isMetal = kind == "bell" or kind == "shield" or kind == "ammo" or kind == "pass" or kind == "quickbelt" -- 79
			if not isWood and not isMetal then -- 79
				goto __continue10 -- 81
			end -- 81
			local tint = (kind == "wood" or kind == "scrap") and PALETTE.amber or (kind == "wedge" and PALETTE.emerald or ((kind == "shield" or kind == "ammo") and PALETTE.cyan or PALETTE.amberCore)) -- 83
			assets:tryPlace( -- 86
				isWood and "ink_bamboo_slip" or "prop_compass", -- 87
				"pickup_" .. pickup.id, -- 88
				cam:sx(pickup.x), -- 89
				cam:sy(pickup.y + 9, depth), -- 89
				cam:len(18), -- 90
				cam:len(isWood and 7 or 16), -- 90
				{ -- 91
					angle = isWood and 65 or 0, -- 92
					color = toColor(tint), -- 93
					layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 94
				} -- 94
			) -- 94
		end -- 94
		::__continue10:: -- 94
	end -- 94
end -- 70
function PropsRenderer.prototype.drawZones(self, fgDraw, assets, p, cam) -- 100
	local i = 0 -- 106
	do -- 106
		i = 0 -- 107
		while i < #p.room.zones do -- 107
			local z = p.room.zones[i + 1] -- 108
			local x0 = cam:sx(z.x0) -- 109
			local x1 = cam:sx(z.x1) -- 110
			local y0 = cam:sy(z.y) -- 111
			local zw = x1 - x0 -- 112
			if z.tint == 1 then -- 112
				local road = p.room.depth -- 115
				local front = cam:sy(z.y, road and road.min or -3) -- 116
				local back = cam:sy(z.y, road and road.max or 1) -- 117
				fgDraw:drawRect( -- 118
					Rect(x0, front, zw, back - front), -- 118
					Color(50, 35, 29, 48) -- 118
				) -- 118
			elseif z.tint == 2 then -- 118
				if not assets:tryPlace( -- 118
					"fe_ground_soft", -- 120
					"zone_soft_" .. tostring(i), -- 120
					(x0 + x1) * 0.5, -- 120
					y0 - cam:len(4), -- 120
					zw, -- 120
					cam:len(14), -- 120
					{layer = 1} -- 120
				) then -- 120
					fgDraw:drawRect( -- 121
						Rect(x0, y0 - 4, zw, 8), -- 121
						Color(74, 58, 44, 220) -- 121
					) -- 121
				end -- 121
			elseif z.tint == 3 then -- 121
				if not assets:tryPlace( -- 121
					"fe_ground_brick", -- 124
					"zone_brick_" .. tostring(i), -- 124
					(x0 + x1) * 0.5, -- 124
					y0 - cam:len(4), -- 124
					zw, -- 124
					cam:len(14), -- 124
					{layer = 1} -- 124
				) then -- 124
					fgDraw:drawRect( -- 125
						Rect(x0, y0 - 4, zw, 9), -- 125
						Color(118, 122, 130, 235) -- 125
					) -- 125
				end -- 125
			end -- 125
			i = i + 1 -- 107
		end -- 107
	end -- 107
end -- 100
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 131
	for ____, m in ipairs(p.room.marks) do -- 139
		do -- 139
			if m.kind ~= 6 then -- 139
				goto __continue23 -- 141
			end -- 141
			local mx = cam:sx(m.x) -- 143
			local my = cam:sy(m.y) -- 144
			local hookY = my + cam:len(52) -- 145
			local armX = mx + cam:len(13) -- 146
			local lampY = hookY - cam:len(12) -- 147
			if not assets:tryPlace( -- 147
				"fe_lamp_bracket", -- 148
				"lamp_bracket_" .. tostring(m.x), -- 148
				mx + cam:len(6), -- 148
				my, -- 148
				cam:len(26), -- 148
				cam:len(54), -- 148
				{layer = 1} -- 148
			) then -- 148
				local wood = Color(82, 58, 40, 245) -- 149
				local joint = math.max( -- 150
					1, -- 150
					cam:len(2) -- 150
				) -- 150
				fgDraw:drawSegment( -- 151
					Vec2(mx, my), -- 151
					Vec2(mx, hookY), -- 151
					joint, -- 151
					wood -- 151
				) -- 151
				fgDraw:drawSegment( -- 152
					Vec2(mx, hookY), -- 152
					Vec2(armX, hookY), -- 152
					joint, -- 152
					wood -- 152
				) -- 152
			end -- 152
			if not assets:tryPlace( -- 152
				"prop_lantern", -- 154
				"path_lamp_" .. tostring(m.x), -- 154
				armX, -- 154
				lampY, -- 154
				cam:len(16), -- 154
				cam:len(20), -- 154
				{layer = 2} -- 154
			) then -- 154
				fgDraw:drawRect( -- 155
					Rect( -- 155
						armX - cam:len(4), -- 155
						lampY - cam:len(7), -- 155
						cam:len(8), -- 155
						cam:len(14) -- 155
					), -- 155
					Color(192, 136, 64, 240), -- 156
					1.4, -- 156
					Color(82, 58, 40, 245) -- 156
				) -- 156
			end -- 156
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 158
			fillRadialGlow( -- 159
				fgGlow, -- 159
				armX, -- 159
				lampY, -- 159
				cam:len(23), -- 159
				cam:len(27), -- 159
				Color(239, 182, 106, 46 * flame), -- 159
				Color(231, 164, 91, 0), -- 160
				16 -- 160
			) -- 160
		end -- 160
		::__continue23:: -- 160
	end -- 160
end -- 131
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 164
	local c = p.room.cart -- 173
	if c.bodyW <= 0 then -- 173
		return -- 175
	end -- 175
	local depth = c.depth or 0 -- 177
	local raised = p.room.depth ~= nil -- 178
	local lo = math.min(c.startX, c.endX) -- 181
	local hi = math.max(c.startX, c.endX) -- 182
	if hi - lo > 4 then -- 182
		local rx0 = cam:sx(lo) -- 184
		local rx1 = cam:sx(hi) -- 185
		local ry = cam:sy(c.baseY, depth) -- 186
		fgDraw:drawSegment( -- 187
			Vec2(rx0, ry + 1), -- 187
			Vec2(rx1, ry + 1), -- 187
			1.2, -- 187
			Color(86, 65, 47, 150) -- 187
		) -- 187
		local dockX = cam:sx(c.endX) -- 188
		local width = cam:len(24) -- 189
		local lip = cam:len(3) -- 190
		fgDraw:drawRect( -- 191
			Rect(dockX - width * 0.5, ry, width, lip), -- 191
			Color(51, 37, 26, 230) -- 191
		) -- 191
		fgDraw:drawRect( -- 192
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 192
			Color(107, 77, 51, 230) -- 192
		) -- 192
	end -- 192
	local axleX = p.cartAxle -- 195
	local cx = cam:sx(axleX) -- 196
	local baseY = cam:sy(c.baseY, depth) -- 197
	local bw = cam:len(c.bodyW) -- 198
	local bh = cam:len(c.bodyH) -- 199
	local wr = cam:len(c.wheelR) -- 200
	local x0 = cx - bw * 0.5 -- 202
	local x1 = cx + bw * 0.5 -- 203
	local bodyY0 = baseY + wr * 1.05 -- 204
	local bodyY1 = bodyY0 + bh -- 205
	local artWidth = c.bodyW * 1.36 -- 208
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 209
	local opacity = raised and occlusion:update("cart", { -- 210
		x0 = axleX - artWidth * 0.5, -- 211
		x1 = axleX + artWidth * 0.5, -- 211
		y0 = c.baseY, -- 212
		y1 = c.baseY + artHeight, -- 212
		depth = {min = depth, max = depth + 8}, -- 213
		passThrough = true -- 213
	}, p, fadeDt) or 1 -- 213
	fgDraw:drawEllipse( -- 215
		Vec2(cx, baseY + 2), -- 215
		bw * 0.62, -- 215
		5, -- 215
		Color(4, 6, 10, 150 * opacity) -- 215
	) -- 215
	local painted = assets:tryPlace( -- 217
		"prop_cart", -- 217
		"cart", -- 217
		cx, -- 217
		baseY, -- 217
		cam:len(artWidth), -- 217
		cam:len(artHeight), -- 217
		{ -- 217
			layer = raised and depthOrder(depth, 2) or 2, -- 218
			opacity = opacity, -- 218
			color = occlusionTint(opacity) -- 218
		} -- 218
	) -- 218
	if not painted then -- 218
		fillVGradRect( -- 222
			fgDraw, -- 222
			x0, -- 222
			bodyY0, -- 222
			bw, -- 222
			bh, -- 222
			Color(48, 32, 28, 255), -- 222
			toColor(PALETTE.cartWood) -- 222
		) -- 222
		fgDraw:drawRect( -- 223
			Rect(x0, bodyY0, bw, bh), -- 223
			Color(0, 0, 0, 0), -- 223
			1.6, -- 223
			toColor(PALETTE.cartMetal, 220) -- 223
		) -- 223
		fgDraw:drawSegment( -- 225
			Vec2(x0 + bw * 0.33, bodyY0), -- 225
			Vec2(x0 + bw * 0.33, bodyY1), -- 225
			1.4, -- 225
			toColor(PALETTE.cartMetal, 180) -- 225
		) -- 225
		fgDraw:drawSegment( -- 226
			Vec2(x0 + bw * 0.67, bodyY0), -- 226
			Vec2(x0 + bw * 0.67, bodyY1), -- 226
			1.4, -- 226
			toColor(PALETTE.cartMetal, 180) -- 226
		) -- 226
		fgDraw:drawSegment( -- 227
			Vec2(x0 - 2, bodyY1), -- 227
			Vec2(x1 + 2, bodyY1), -- 227
			2.2, -- 227
			toColor(PALETTE.rimSilver, 220) -- 227
		) -- 227
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 230
		local wxA = x0 + bw * 0.24 -- 231
		local wxB = x1 - bw * 0.24 -- 232
		local wy = baseY + wr -- 233
		self:drawWheel( -- 234
			fgDraw, -- 234
			wxA, -- 234
			wy, -- 234
			wr, -- 234
			wheelSpin -- 234
		) -- 234
		self:drawWheel( -- 235
			fgDraw, -- 235
			wxB, -- 235
			wy, -- 235
			wr, -- 235
			wheelSpin -- 235
		) -- 235
	end -- 235
	local hx = cam:sx(axleX + c.handleOffset) -- 239
	local hTop = bodyY1 + cam:len(7) -- 240
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 241
	local handleSpan = math.abs(hx - edge) -- 244
	if not painted or handleSpan > cam:len(4) then -- 244
		fgDraw:drawSegment( -- 246
			Vec2(edge, bodyY0 + bh * 0.52), -- 246
			Vec2( -- 246
				hx, -- 246
				hTop - cam:len(4) -- 246
			), -- 246
			math.max( -- 247
				1.8, -- 247
				cam:len(2.4) -- 247
			), -- 247
			toColor(PALETTE.cartWood, 245 * opacity) -- 247
		) -- 247
		fgDraw:drawSegment( -- 248
			Vec2( -- 248
				hx, -- 248
				hTop - cam:len(5.5) -- 248
			), -- 248
			Vec2(hx, hTop), -- 248
			math.max( -- 249
				2.2, -- 249
				cam:len(3.2) -- 249
			), -- 249
			Color(126, 91, 61, 245 * opacity) -- 249
		) -- 249
	end -- 249
	if painted then -- 249
		return -- 253
	end -- 253
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 256
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 257
	local wave2 = math.cos(time * 2.8) * 3.5 -- 258
	local clothH = cam:len(26) -- 259
	local clothW = cam:len(14) -- 260
	fgDraw:drawPolygon( -- 261
		{ -- 261
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 262
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 263
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 264
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 265
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 266
		}, -- 266
		toColor(PALETTE.clothRed) -- 267
	) -- 267
	fgDraw:drawSegment( -- 269
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 270
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 271
		1.6, -- 272
		toColor(PALETTE.clothRedHighlight, 220) -- 273
	) -- 273
end -- 164
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 277
	draw:drawCircle( -- 278
		Vec2(cx, cy), -- 278
		r, -- 278
		Color(24, 28, 36, 255) -- 278
	) -- 278
	draw:drawRing( -- 279
		Vec2(cx, cy), -- 279
		r * 0.72, -- 279
		r, -- 279
		Color(0, 0, 0, 0), -- 279
		1.6, -- 279
		toColor(PALETTE.cartMetal) -- 279
	) -- 279
	local k = 0 -- 280
	do -- 280
		k = 0 -- 281
		while k < 4 do -- 281
			local a = spin + k * math.pi / 4 -- 282
			draw:drawSegment( -- 283
				Vec2( -- 284
					cx - math.cos(a) * r * 0.72, -- 284
					cy - math.sin(a) * r * 0.72 -- 284
				), -- 284
				Vec2( -- 285
					cx + math.cos(a) * r * 0.72, -- 285
					cy + math.sin(a) * r * 0.72 -- 285
				), -- 285
				1.2, -- 286
				toColor(PALETTE.steelLight, 190) -- 287
			) -- 287
			k = k + 1 -- 281
		end -- 281
	end -- 281
	draw:drawDot( -- 290
		Vec2(cx, cy), -- 290
		math.max(2.2, r * 0.18), -- 290
		toColor(PALETTE.rimSilver) -- 290
	) -- 290
end -- 277
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 293
	local bottle = p.room.bottle -- 302
	if bottle ~= nil then -- 302
		local by0 = cam:sy(0) -- 304
		local by1 = cam:sy(52) -- 305
		if not assets:tryPlace( -- 305
			"fe_bottle_rack", -- 306
			"village_bottle_rack", -- 306
			cam:sx(bottle.x), -- 306
			by0, -- 306
			cam:len(38), -- 306
			by1 - by0 + cam:len(2), -- 306
			{layer = 2} -- 306
		) then -- 306
			local bx0 = cam:sx(bottle.x - 16) -- 307
			local bx1 = cam:sx(bottle.x + 16) -- 308
			local beam = cam:len(3.2) -- 309
			local side = Color(78, 57, 41, 255) -- 310
			fgDraw:drawRect( -- 311
				Rect(bx0, by0, beam, by1 - by0), -- 311
				side -- 311
			) -- 311
			fgDraw:drawRect( -- 312
				Rect(bx1 - beam, by0, beam, by1 - by0), -- 312
				side -- 312
			) -- 312
		end -- 312
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 312
			self:drawBottleSprite( -- 315
				fgDraw, -- 315
				assets, -- 315
				"bottle_shelf", -- 315
				cam:sx(bottle.x), -- 315
				cam:sy(56), -- 315
				cam.ppu, -- 315
				0 -- 315
			) -- 315
		end -- 315
	end -- 315
	local arch = p.room.arch -- 319
	local tx0 = cam:sx(arch.x0 - 4) -- 320
	local tx1 = cam:sx(arch.x1 + 4) -- 321
	local ty0 = cam:sy(arch.y) -- 322
	local tyBot = cam:sy(arch.y + arch.h) -- 323
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 324
	fillVGradRect( -- 325
		fgDraw, -- 325
		tx0 + 6, -- 325
		ty0, -- 325
		tx1 - tx0 - 12, -- 325
		tyBot - ty0, -- 325
		Color(9, 10, 15, 165), -- 326
		Color(9, 10, 15, 100) -- 326
	) -- 326
	if not assets:tryPlace( -- 326
		"prop_table", -- 327
		"village_table", -- 327
		(tx0 + tx1) * 0.5, -- 327
		ty0, -- 327
		tx1 - tx0, -- 328
		tyTop - ty0, -- 328
		{layer = 6} -- 328
	) then -- 328
		fgDraw:drawRect( -- 329
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 329
			toColor(PALETTE.cartWood) -- 329
		) -- 329
		fgDraw:drawRect( -- 330
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 330
			toColor(PALETTE.cartWood) -- 330
		) -- 330
		fgDraw:drawRect( -- 331
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 331
			toColor(PALETTE.cartWood) -- 331
		) -- 331
	end -- 331
	if p.hasBottle and p.aimHold <= 0 then -- 331
		local pl = p.player -- 336
		self:drawBottleSprite( -- 337
			fgDraw, -- 337
			assets, -- 337
			"bottle_held", -- 337
			cam:sx(pl.x + pl.facing * 10), -- 337
			cam:sy(pl.y + pl.h * 0.52), -- 337
			cam.ppu, -- 337
			pl.facing * 0.2 -- 337
		) -- 337
	end -- 337
	if p.bottleFly ~= nil then -- 337
		self:drawBottleSprite( -- 340
			fgDraw, -- 340
			assets, -- 340
			"bottle_air", -- 340
			cam:sx(p.bottleFly.x), -- 340
			cam:sy(p.bottleFly.y), -- 340
			cam.ppu, -- 340
			time * 14 -- 340
		) -- 340
	end -- 340
	if p.hasBottle and p.aimHold > 0 then -- 340
		local pl = p.player -- 345
		local endX = p.bottleAimX -- 346
		local endY = p.bottleAimY -- 347
		if endX < 0 then -- 347
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 349
			endX = wAim.x -- 350
			endY = 0 -- 351
		end -- 351
		local dir = endX >= pl.x and 1 or -1 -- 353
		local x0 = pl.x + dir * 10 -- 354
		local y0 = pl.y + pl.h * 0.7 -- 355
		local T = 0.62 -- 356
		local vx = (endX - x0) / T -- 357
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 358
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 360
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 361
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 362
		local activeAim = p.aimHold > 0.01 -- 363
		local steps = 18 -- 365
		local k = 1 -- 366
		do -- 366
			k = 1 -- 367
			while k <= steps do -- 367
				local tt = k / steps * T -- 368
				local wx = x0 + vx * tt -- 369
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 370
				local sx = cam:sx(wx) -- 371
				local sy = cam:sy(wy) -- 372
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 373
				fgGlow:drawDot( -- 374
					Vec2(sx, sy), -- 374
					activeAim and 3.2 or 2.2, -- 374
					toColor(arcCol, alpha) -- 374
				) -- 374
				k = k + 1 -- 367
			end -- 367
		end -- 367
		local lx = cam:sx(endX) -- 377
		local ly = cam:sy(endY + 2) -- 378
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 379
		fgGlow:drawRing( -- 380
			Vec2(lx, ly), -- 380
			8, -- 380
			11, -- 380
			Color(0, 0, 0, 0), -- 380
			1.6, -- 380
			toColor(arcCol, activeAim and 245 or 165) -- 380
		) -- 380
		if isBrick then -- 380
			fgGlow:drawRing( -- 382
				Vec2(lx, ly), -- 382
				28 * pulse, -- 382
				30 * pulse, -- 382
				Color(0, 0, 0, 0), -- 382
				1.2, -- 382
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 382
			) -- 382
			fillRadialGlow( -- 383
				fgGlow, -- 383
				lx, -- 383
				ly, -- 383
				36, -- 383
				14, -- 383
				Color(242, 188, 96, activeAim and 95 or 48), -- 383
				Color(242, 188, 96, 0), -- 383
				14 -- 383
			) -- 383
		end -- 383
	end -- 383
end -- 293
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 388
	local height = math.max(10, ppu * 10.5) -- 395
	if not assets:tryPlace( -- 395
		"prop_bottle", -- 396
		id, -- 396
		cx, -- 396
		cy, -- 396
		height, -- 396
		height, -- 396
		{angle = tilt * 180 / math.pi, layer = 6} -- 396
	) then -- 396
		local dx = math.sin(tilt) * height * 0.4 -- 399
		local dy = math.cos(tilt) * height * 0.5 -- 400
		fgDraw:drawSegment( -- 401
			Vec2(cx - dx, cy - dy), -- 401
			Vec2(cx + dx, cy + dy), -- 401
			height * 0.32, -- 401
			toColor(PALETTE.amber, 225) -- 402
		) -- 402
	end -- 402
end -- 388
return ____exports -- 388