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
local ____talent_catalog = require("Script.watch.fe.ui.talent_catalog") -- 21
local drawWorldPickupVisual = ____talent_catalog.drawWorldPickupVisual -- 21
local GRAVITY = 1000 -- 23
____exports.PropsRenderer = __TS__Class() -- 25
local PropsRenderer = ____exports.PropsRenderer -- 25
PropsRenderer.name = "PropsRenderer" -- 25
function PropsRenderer.prototype.____constructor(self) -- 25
end -- 25
function PropsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 26
	self:drawZones(fgDraw, p, cam) -- 36
	self:drawMarks( -- 37
		fgDraw, -- 37
		fgGlow, -- 37
		assets, -- 37
		p, -- 37
		cam, -- 37
		time -- 37
	) -- 37
	self:drawCart( -- 38
		fgDraw, -- 38
		assets, -- 38
		p, -- 38
		cam, -- 38
		time, -- 38
		occlusion, -- 38
		fadeDt -- 38
	) -- 38
	self:drawBracedShield(fgDraw, p, cam) -- 39
	self:drawCraftMaterials( -- 40
		fgDraw, -- 40
		fgGlow, -- 40
		assets, -- 40
		p, -- 40
		cam, -- 40
		time -- 40
	) -- 40
	if p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 41
		local x = (p.player.x + p.partner.x) * 0.5 -- 42
		local y = p.partner.y + p.partner.h * 0.62 -- 43
		local depth = (p.player.depth + p.partner.depth) * 0.5 -- 44
		assets:tryPlace( -- 45
			"prop_compass", -- 45
			"handover", -- 45
			cam:sx(x), -- 45
			cam:sy(y, depth), -- 45
			cam:len(12), -- 45
			cam:len(12), -- 45
			{layer = p.room.depth == nil and 6 or depthOrder(depth, 6)} -- 46
		) -- 46
	end -- 46
	if p.room.key == "village" then -- 48
		self:drawVillageProps( -- 49
			fgDraw, -- 49
			fgGlow, -- 49
			assets, -- 49
			p, -- 49
			cam, -- 49
			time -- 49
		) -- 49
	end -- 49
end -- 26
function PropsRenderer.prototype.drawBracedShield(self, fgDraw, p, cam) -- 54
	local sh = p.bracedShield -- 55
	if sh == nil or sh.hp <= 0 then -- 56
		return -- 57
	end -- 57
	local cx = cam:sx(sh.x) -- 59
	local by = cam:sy(sh.y, p.player.depth) -- 60
	local w = math.max( -- 61
		8, -- 61
		cam:len(12) -- 61
	) -- 61
	local h = cam:len(sh.h) -- 62
	fgDraw:drawEllipse( -- 63
		Vec2(cx, by + 1), -- 63
		w * 0.9, -- 63
		3.2, -- 63
		Color(8, 10, 14, 150) -- 63
	) -- 63
	fgDraw:drawSegment( -- 64
		Vec2(cx - w * 0.65, by), -- 64
		Vec2(cx - w * 0.15, by + h * 0.55), -- 64
		2.2, -- 64
		Color(84, 58, 38, 255) -- 64
	) -- 64
	fgDraw:drawRect( -- 65
		Rect(cx - w * 0.5, by + 2, w, h - 2), -- 65
		Color(104, 72, 46, 248), -- 65
		1.4, -- 65
		Color(172, 178, 184, 235) -- 65
	) -- 65
	fgDraw:drawCircle( -- 66
		Vec2(cx, by + h * 0.52), -- 66
		math.max( -- 66
			2.5, -- 66
			cam:len(4) -- 66
		), -- 66
		Color(148, 154, 160, 245) -- 66
	) -- 66
end -- 54
function PropsRenderer.prototype.drawCraftMaterials(self, fgDraw, fgGlow, assets, p, cam, time) -- 69
	local idx = 0 -- 77
	for ____, pickup in ipairs(p.pickups) do -- 78
		do -- 78
			idx = idx + 1 -- 79
			local kind = pickup.kind -- 81
			if pickup.id == "" or p.run.taken[pickup.id] then -- 82
				goto __continue9 -- 83
			end -- 83
			local depth = pickup.depth or 0 -- 85
			local isWood = kind == "wood" or kind == "scrap" or kind == "wedge" -- 86
			local isMetal = kind == "bell" or kind == "shield" or kind == "ammo" or kind == "pass" or kind == "quickbelt" -- 87
			if not isWood and not isMetal then -- 88
				goto __continue9 -- 89
			end -- 89
			assets:tryPlace( -- 92
				isWood and "ink_bamboo_slip" or "prop_compass", -- 93
				"pickup_" .. pickup.id, -- 94
				cam:sx(pickup.x), -- 95
				cam:sy(pickup.y + 9, depth), -- 95
				cam:len(14), -- 96
				cam:len(isWood and 6 or 12), -- 96
				{ -- 97
					angle = isWood and 65 or 0, -- 98
					opacity = 0.01, -- 99
					layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 100
				} -- 100
			) -- 100
			drawWorldPickupVisual( -- 103
				fgDraw, -- 104
				fgGlow, -- 105
				cam:sx(pickup.x), -- 106
				cam:sy(pickup.y, depth), -- 107
				cam:len(13.5), -- 108
				kind, -- 109
				time, -- 110
				idx * 1.37 + pickup.x * 0.02 -- 111
			) -- 111
		end -- 111
		::__continue9:: -- 111
	end -- 111
end -- 69
function PropsRenderer.prototype.drawZones(self, fgDraw, p, cam) -- 116
	local i = 0 -- 121
	do -- 121
		i = 0 -- 122
		while i < #p.room.zones do -- 122
			local z = p.room.zones[i + 1] -- 123
			local x0 = cam:sx(z.x0) -- 124
			local x1 = cam:sx(z.x1) -- 125
			local y0 = cam:sy(z.y) -- 126
			local zw = x1 - x0 -- 127
			if z.tint == 1 then -- 129
				local road = p.room.depth -- 130
				local front = cam:sy(z.y, road and road.min or -3) -- 131
				local back = cam:sy(z.y, road and road.max or 1) -- 132
				fgDraw:drawRect( -- 133
					Rect(x0, front, zw, back - front), -- 133
					Color(50, 35, 29, 48) -- 133
				) -- 133
			elseif z.tint == 2 then -- 134
				fgDraw:drawRect( -- 136
					Rect(x0, y0 - 4, zw, 8), -- 136
					Color(74, 58, 44, 220) -- 136
				) -- 136
				fgDraw:drawSegment( -- 137
					Vec2(x0, y0 + 2), -- 137
					Vec2(x1, y0 + 2), -- 137
					1.4, -- 137
					Color(128, 98, 72, 190) -- 137
				) -- 137
			elseif z.tint == 3 then -- 138
				fgDraw:drawRect( -- 140
					Rect(x0, y0 - 4, zw, 9), -- 140
					Color(118, 122, 130, 235) -- 140
				) -- 140
				local bricks = 4 -- 141
				local b = 1 -- 142
				do -- 142
					b = 1 -- 143
					while b < bricks do -- 143
						local bx = x0 + zw * b / bricks -- 144
						fgDraw:drawSegment( -- 145
							Vec2(bx, y0 - 4), -- 145
							Vec2(bx, y0 + 5), -- 145
							1, -- 145
							Color(42, 46, 56, 220) -- 145
						) -- 145
						b = b + 1 -- 143
					end -- 143
				end -- 143
				fgDraw:drawSegment( -- 147
					Vec2(x0, y0 + 4), -- 147
					Vec2(x1, y0 + 4), -- 147
					1.1, -- 147
					Color(168, 151, 127, 130) -- 147
				) -- 147
			end -- 147
			i = i + 1 -- 122
		end -- 122
	end -- 122
end -- 116
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 152
	for ____, m in ipairs(p.room.marks) do -- 160
		do -- 160
			if m.kind ~= 6 then -- 161
				goto __continue22 -- 162
			end -- 162
			local mx = cam:sx(m.x) -- 164
			local my = cam:sy(m.y) -- 165
			local hookY = my + cam:len(52) -- 166
			local armX = mx + cam:len(13) -- 167
			local lampY = hookY - cam:len(12) -- 168
			local wood = Color(82, 58, 40, 245) -- 169
			local joint = math.max( -- 170
				1, -- 170
				cam:len(2) -- 170
			) -- 170
			fgDraw:drawSegment( -- 171
				Vec2(mx, my), -- 171
				Vec2(mx, hookY), -- 171
				joint, -- 171
				wood -- 171
			) -- 171
			fgDraw:drawSegment( -- 172
				Vec2(mx, hookY), -- 172
				Vec2(armX, hookY), -- 172
				joint, -- 172
				wood -- 172
			) -- 172
			fgDraw:drawSegment( -- 173
				Vec2( -- 173
					mx, -- 173
					hookY - cam:len(7) -- 173
				), -- 173
				Vec2(armX - joint, hookY), -- 173
				joint * 0.7, -- 173
				wood -- 173
			) -- 173
			if not assets:tryPlace( -- 174
				"prop_lantern", -- 174
				"path_lamp_" .. tostring(m.x), -- 174
				armX, -- 174
				lampY, -- 174
				cam:len(16), -- 174
				cam:len(20), -- 174
				{layer = 1} -- 174
			) then -- 174
				fgDraw:drawRect( -- 175
					Rect( -- 175
						armX - cam:len(4), -- 175
						lampY - cam:len(7), -- 175
						cam:len(8), -- 175
						cam:len(14) -- 175
					), -- 175
					Color(192, 136, 64, 240), -- 176
					1.4, -- 176
					wood -- 176
				) -- 176
			end -- 176
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 178
			fillRadialGlow( -- 179
				fgGlow, -- 179
				armX, -- 179
				lampY, -- 179
				cam:len(23), -- 179
				cam:len(27), -- 179
				Color(239, 182, 106, 46 * flame), -- 179
				Color(231, 164, 91, 0), -- 180
				16 -- 180
			) -- 180
		end -- 180
		::__continue22:: -- 180
	end -- 180
end -- 152
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 184
	local c = p.room.cart -- 193
	if c.bodyW <= 0 then -- 194
		return -- 195
	end -- 195
	local depth = c.depth or 0 -- 197
	local raised = p.room.depth ~= nil -- 198
	local lo = math.min(c.startX, c.endX) -- 201
	local hi = math.max(c.startX, c.endX) -- 202
	if hi - lo > 4 then -- 203
		local rx0 = cam:sx(lo) -- 204
		local rx1 = cam:sx(hi) -- 205
		local ry = cam:sy(c.baseY, depth) -- 206
		fgDraw:drawSegment( -- 207
			Vec2(rx0, ry + 1), -- 207
			Vec2(rx1, ry + 1), -- 207
			1.2, -- 207
			Color(86, 65, 47, 150) -- 207
		) -- 207
		local dockX = cam:sx(c.endX) -- 208
		local width = cam:len(24) -- 209
		local lip = cam:len(3) -- 210
		fgDraw:drawRect( -- 211
			Rect(dockX - width * 0.5, ry, width, lip), -- 211
			Color(51, 37, 26, 230) -- 211
		) -- 211
		fgDraw:drawRect( -- 212
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 212
			Color(107, 77, 51, 230) -- 212
		) -- 212
	end -- 212
	local axleX = p.cartAxle -- 215
	local cx = cam:sx(axleX) -- 216
	local baseY = cam:sy(c.baseY, depth) -- 217
	local bw = cam:len(c.bodyW) -- 218
	local bh = cam:len(c.bodyH) -- 219
	local wr = cam:len(c.wheelR) -- 220
	local x0 = cx - bw * 0.5 -- 222
	local x1 = cx + bw * 0.5 -- 223
	local bodyY0 = baseY + wr * 1.05 -- 224
	local bodyY1 = bodyY0 + bh -- 225
	local artWidth = c.bodyW * 1.36 -- 228
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 229
	local opacity = raised and occlusion:update("cart", { -- 230
		x0 = axleX - artWidth * 0.5, -- 231
		x1 = axleX + artWidth * 0.5, -- 231
		y0 = c.baseY, -- 232
		y1 = c.baseY + artHeight, -- 232
		depth = {min = depth, max = depth + 8}, -- 233
		passThrough = true -- 233
	}, p, fadeDt) or 1 -- 234
	fgDraw:drawEllipse( -- 235
		Vec2(cx, baseY + 2), -- 235
		bw * 0.62, -- 235
		5, -- 235
		Color(4, 6, 10, 150 * opacity) -- 235
	) -- 235
	local painted = assets:tryPlace( -- 237
		"prop_cart", -- 237
		"cart", -- 237
		cx, -- 237
		baseY, -- 237
		cam:len(artWidth), -- 237
		cam:len(artHeight), -- 237
		{ -- 237
			layer = raised and depthOrder(depth, 2) or 2, -- 238
			opacity = opacity, -- 238
			color = occlusionTint(opacity) -- 238
		} -- 238
	) -- 238
	if not painted then -- 240
		fillVGradRect( -- 242
			fgDraw, -- 242
			x0, -- 242
			bodyY0, -- 242
			bw, -- 242
			bh, -- 242
			Color(48, 32, 28, 255), -- 242
			toColor(PALETTE.cartWood) -- 242
		) -- 242
		fgDraw:drawRect( -- 243
			Rect(x0, bodyY0, bw, bh), -- 243
			Color(0, 0, 0, 0), -- 243
			1.6, -- 243
			toColor(PALETTE.cartMetal, 220) -- 243
		) -- 243
		fgDraw:drawSegment( -- 245
			Vec2(x0 + bw * 0.33, bodyY0), -- 245
			Vec2(x0 + bw * 0.33, bodyY1), -- 245
			1.4, -- 245
			toColor(PALETTE.cartMetal, 180) -- 245
		) -- 245
		fgDraw:drawSegment( -- 246
			Vec2(x0 + bw * 0.67, bodyY0), -- 246
			Vec2(x0 + bw * 0.67, bodyY1), -- 246
			1.4, -- 246
			toColor(PALETTE.cartMetal, 180) -- 246
		) -- 246
		fgDraw:drawSegment( -- 247
			Vec2(x0 - 2, bodyY1), -- 247
			Vec2(x1 + 2, bodyY1), -- 247
			2.2, -- 247
			toColor(PALETTE.rimSilver, 220) -- 247
		) -- 247
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 250
		local wxA = x0 + bw * 0.24 -- 251
		local wxB = x1 - bw * 0.24 -- 252
		local wy = baseY + wr -- 253
		self:drawWheel( -- 254
			fgDraw, -- 254
			wxA, -- 254
			wy, -- 254
			wr, -- 254
			wheelSpin -- 254
		) -- 254
		self:drawWheel( -- 255
			fgDraw, -- 255
			wxB, -- 255
			wy, -- 255
			wr, -- 255
			wheelSpin -- 255
		) -- 255
	end -- 255
	local hx = cam:sx(axleX + c.handleOffset) -- 259
	local hTop = bodyY1 + cam:len(7) -- 260
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 261
	local handleSpan = math.abs(hx - edge) -- 264
	if not painted or handleSpan > cam:len(4) then -- 265
		fgDraw:drawSegment( -- 266
			Vec2(edge, bodyY0 + bh * 0.52), -- 266
			Vec2( -- 266
				hx, -- 266
				hTop - cam:len(4) -- 266
			), -- 266
			math.max( -- 267
				1.8, -- 267
				cam:len(2.4) -- 267
			), -- 267
			toColor(PALETTE.cartWood, 245 * opacity) -- 267
		) -- 267
		fgDraw:drawSegment( -- 268
			Vec2( -- 268
				hx, -- 268
				hTop - cam:len(5.5) -- 268
			), -- 268
			Vec2(hx, hTop), -- 268
			math.max( -- 269
				2.2, -- 269
				cam:len(3.2) -- 269
			), -- 269
			Color(126, 91, 61, 245 * opacity) -- 269
		) -- 269
	end -- 269
	if painted then -- 272
		return -- 273
	end -- 273
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 276
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 277
	local wave2 = math.cos(time * 2.8) * 3.5 -- 278
	local clothH = cam:len(26) -- 279
	local clothW = cam:len(14) -- 280
	fgDraw:drawPolygon( -- 281
		{ -- 281
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 282
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 283
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 284
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 285
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 286
		}, -- 286
		toColor(PALETTE.clothRed) -- 287
	) -- 287
	fgDraw:drawSegment( -- 289
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 290
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 291
		1.6, -- 292
		toColor(PALETTE.clothRedHighlight, 220) -- 293
	) -- 293
end -- 184
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 297
	draw:drawCircle( -- 298
		Vec2(cx, cy), -- 298
		r, -- 298
		Color(24, 28, 36, 255) -- 298
	) -- 298
	draw:drawRing( -- 299
		Vec2(cx, cy), -- 299
		r * 0.72, -- 299
		r, -- 299
		Color(0, 0, 0, 0), -- 299
		1.6, -- 299
		toColor(PALETTE.cartMetal) -- 299
	) -- 299
	local k = 0 -- 300
	do -- 300
		k = 0 -- 301
		while k < 4 do -- 301
			local a = spin + k * math.pi / 4 -- 302
			draw:drawSegment( -- 303
				Vec2( -- 304
					cx - math.cos(a) * r * 0.72, -- 304
					cy - math.sin(a) * r * 0.72 -- 304
				), -- 304
				Vec2( -- 305
					cx + math.cos(a) * r * 0.72, -- 305
					cy + math.sin(a) * r * 0.72 -- 305
				), -- 305
				1.2, -- 306
				toColor(PALETTE.steelLight, 190) -- 307
			) -- 307
			k = k + 1 -- 301
		end -- 301
	end -- 301
	draw:drawDot( -- 310
		Vec2(cx, cy), -- 310
		math.max(2.2, r * 0.18), -- 310
		toColor(PALETTE.rimSilver) -- 310
	) -- 310
end -- 297
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 313
	local bottle = p.room.bottle -- 322
	if bottle ~= nil then -- 323
		local bx0 = cam:sx(bottle.x - 16) -- 324
		local bx1 = cam:sx(bottle.x + 16) -- 325
		local by0 = cam:sy(0) -- 326
		local by1 = cam:sy(52) -- 327
		local beam = cam:len(3.2) -- 328
		local side = Color(78, 57, 41, 255) -- 329
		fgDraw:drawRect( -- 330
			Rect(bx0, by0, beam, by1 - by0), -- 330
			side -- 330
		) -- 330
		fgDraw:drawRect( -- 331
			Rect(bx1 - beam, by0, beam, by1 - by0), -- 331
			side -- 331
		) -- 331
		for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 332
			fgDraw:drawRect( -- 333
				Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 333
				Color(106, 78, 56, 255), -- 334
				1, -- 334
				Color(56, 42, 34, 240) -- 334
			) -- 334
		end -- 334
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 336
			self:drawBottleSprite( -- 337
				fgDraw, -- 337
				assets, -- 337
				"bottle_shelf", -- 337
				cam:sx(bottle.x), -- 337
				cam:sy(56), -- 337
				cam.ppu, -- 337
				0 -- 337
			) -- 337
		end -- 337
	end -- 337
	local arch = p.room.arch -- 341
	local tx0 = cam:sx(arch.x0 - 4) -- 342
	local tx1 = cam:sx(arch.x1 + 4) -- 343
	local ty0 = cam:sy(arch.y) -- 344
	local tyBot = cam:sy(arch.y + arch.h) -- 345
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 346
	fillVGradRect( -- 347
		fgDraw, -- 347
		tx0 + 6, -- 347
		ty0, -- 347
		tx1 - tx0 - 12, -- 347
		tyBot - ty0, -- 347
		Color(9, 10, 15, 165), -- 348
		Color(9, 10, 15, 100) -- 348
	) -- 348
	if not assets:tryPlace( -- 349
		"prop_table", -- 349
		"village_table", -- 349
		(tx0 + tx1) * 0.5, -- 349
		ty0, -- 349
		tx1 - tx0, -- 350
		tyTop - ty0, -- 350
		{layer = 6} -- 350
	) then -- 350
		fgDraw:drawRect( -- 351
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 351
			toColor(PALETTE.cartWood) -- 351
		) -- 351
		fgDraw:drawRect( -- 352
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 352
			toColor(PALETTE.cartWood) -- 352
		) -- 352
		fgDraw:drawRect( -- 353
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 353
			toColor(PALETTE.cartWood) -- 353
		) -- 353
	end -- 353
	if p.hasBottle and p.aimHold <= 0 then -- 357
		local pl = p.player -- 358
		self:drawBottleSprite( -- 359
			fgDraw, -- 359
			assets, -- 359
			"bottle_held", -- 359
			cam:sx(pl.x + pl.facing * 10), -- 359
			cam:sy(pl.y + pl.h * 0.52), -- 359
			cam.ppu, -- 359
			pl.facing * 0.2 -- 359
		) -- 359
	end -- 359
	if p.bottleFly ~= nil then -- 361
		self:drawBottleSprite( -- 362
			fgDraw, -- 362
			assets, -- 362
			"bottle_air", -- 362
			cam:sx(p.bottleFly.x), -- 362
			cam:sy(p.bottleFly.y), -- 362
			cam.ppu, -- 362
			time * 14 -- 362
		) -- 362
	end -- 362
	if p.hasBottle and p.aimHold > 0 then -- 366
		local pl = p.player -- 367
		local endX = p.bottleAimX -- 368
		local endY = p.bottleAimY -- 369
		if endX < 0 then -- 370
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 371
			endX = wAim.x -- 372
			endY = 0 -- 373
		end -- 373
		local dir = endX >= pl.x and 1 or -1 -- 375
		local x0 = pl.x + dir * 10 -- 376
		local y0 = pl.y + pl.h * 0.7 -- 377
		local T = 0.62 -- 378
		local vx = (endX - x0) / T -- 379
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 380
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 382
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 383
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 384
		local activeAim = p.aimHold > 0.01 -- 385
		local steps = 18 -- 387
		local k = 1 -- 388
		do -- 388
			k = 1 -- 389
			while k <= steps do -- 389
				local tt = k / steps * T -- 390
				local wx = x0 + vx * tt -- 391
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 392
				local sx = cam:sx(wx) -- 393
				local sy = cam:sy(wy) -- 394
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 395
				fgGlow:drawDot( -- 396
					Vec2(sx, sy), -- 396
					activeAim and 3.2 or 2.2, -- 396
					toColor(arcCol, alpha) -- 396
				) -- 396
				k = k + 1 -- 389
			end -- 389
		end -- 389
		local lx = cam:sx(endX) -- 399
		local ly = cam:sy(endY + 2) -- 400
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 401
		fgGlow:drawRing( -- 402
			Vec2(lx, ly), -- 402
			8, -- 402
			11, -- 402
			Color(0, 0, 0, 0), -- 402
			1.6, -- 402
			toColor(arcCol, activeAim and 245 or 165) -- 402
		) -- 402
		if isBrick then -- 403
			fgGlow:drawRing( -- 404
				Vec2(lx, ly), -- 404
				28 * pulse, -- 404
				30 * pulse, -- 404
				Color(0, 0, 0, 0), -- 404
				1.2, -- 404
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 404
			) -- 404
			fillRadialGlow( -- 405
				fgGlow, -- 405
				lx, -- 405
				ly, -- 405
				36, -- 405
				14, -- 405
				Color(242, 188, 96, activeAim and 95 or 48), -- 405
				Color(242, 188, 96, 0), -- 405
				14 -- 405
			) -- 405
		end -- 405
	end -- 405
end -- 313
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 410
	local height = math.max(10, ppu * 10.5) -- 417
	if not assets:tryPlace( -- 418
		"prop_bottle", -- 418
		id, -- 418
		cx, -- 418
		cy, -- 418
		height, -- 418
		height, -- 418
		{angle = tilt * 180 / math.pi, layer = 6} -- 418
	) then -- 418
		local dx = math.sin(tilt) * height * 0.4 -- 421
		local dy = math.cos(tilt) * height * 0.5 -- 422
		fgDraw:drawSegment( -- 423
			Vec2(cx - dx, cy - dy), -- 423
			Vec2(cx + dx, cy + dy), -- 423
			height * 0.32, -- 423
			toColor(PALETTE.amber, 225) -- 424
		) -- 424
	end -- 424
end -- 410
return ____exports -- 410
