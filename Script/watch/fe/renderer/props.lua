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
	self:drawBracedShield(fgDraw, assets, p, cam) -- 38
	self:drawCraftMaterials( -- 39
		fgDraw, -- 39
		fgGlow, -- 39
		assets, -- 39
		p, -- 39
		cam, -- 39
		time -- 39
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
		math.max(w * 0.9, h * 0.42), -- 62
		3.4, -- 62
		Color(8, 10, 14, 150) -- 62
	) -- 62
	if assets:tryPlacePath( -- 62
		"assets/art/props_ming.clip|braced_shield", -- 63
		"braced_shield_prop", -- 63
		cx, -- 63
		by, -- 63
		h * 0.95, -- 63
		h * 1.04, -- 63
		{ -- 63
			anchorX = 0.5, -- 64
			anchorY = 0, -- 65
			preserveAspect = true, -- 66
			color = sh.hp <= 1 and Color(218, 178, 154, 255) or Color(255, 255, 255, 255), -- 67
			layer = p.room.depth == nil and 3 or depthOrder(p.player.depth, 2) -- 68
		} -- 68
	) then -- 68
		return -- 70
	end -- 70
	fgDraw:drawSegment( -- 72
		Vec2(cx - w * 0.65, by), -- 72
		Vec2(cx - w * 0.15, by + h * 0.55), -- 72
		2.2, -- 72
		Color(84, 58, 38, 255) -- 72
	) -- 72
	fgDraw:drawRect( -- 73
		Rect(cx - w * 0.5, by + 2, w, h - 2), -- 73
		Color(104, 72, 46, 248), -- 73
		1.4, -- 73
		Color(172, 178, 184, 235) -- 73
	) -- 73
	fgDraw:drawCircle( -- 74
		Vec2(cx, by + h * 0.52), -- 74
		math.max( -- 74
			2.5, -- 74
			cam:len(4) -- 74
		), -- 74
		Color(148, 154, 160, 245) -- 74
	) -- 74
end -- 53
function PropsRenderer.prototype.drawCraftMaterials(self, fgDraw, fgGlow, assets, p, cam, time) -- 77
	for ____, pickup in ipairs(p.pickups) do -- 85
		do -- 85
			local kind = pickup.kind -- 87
			if pickup.id == "" or p.run.taken[pickup.id] then -- 87
				goto __continue10 -- 89
			end -- 89
			local clipName = "" -- 91
			local glowCol = PALETTE.amber -- 92
			if kind == "wood" then -- 92
				clipName = "pickup_wood" -- 94
				glowCol = PALETTE.amber -- 95
			elseif kind == "bell" then -- 95
				clipName = "pickup_bell" -- 97
				glowCol = PALETTE.amberCore -- 98
			elseif kind == "scrap" then -- 98
				clipName = "pickup_scrap" -- 100
				glowCol = PALETTE.amber -- 101
			elseif kind == "wedge" then -- 101
				clipName = "pickup_wedge" -- 103
				glowCol = PALETTE.emerald -- 104
			elseif kind == "ammo" then -- 104
				clipName = "pickup_ammo" -- 106
				glowCol = PALETTE.cyan -- 107
			elseif kind == "shield" then -- 107
				clipName = "pickup_shield" -- 109
				glowCol = PALETTE.cyan -- 110
			elseif kind == "pass" then -- 110
				clipName = "pickup_pass" -- 112
				glowCol = PALETTE.amberCore -- 113
			elseif kind == "quickbelt" then -- 113
				clipName = "pickup_quickbelt" -- 115
				glowCol = PALETTE.amberCore -- 116
			else -- 116
				goto __continue10 -- 118
			end -- 118
			local depth = pickup.depth or 0 -- 120
			local sx = cam:sx(pickup.x) -- 121
			local groundY = cam:sy(pickup.y, depth) -- 122
			local bob = math.sin(time * 3.1 + pickup.x * 0.03) * cam:len(2.4) -- 123
			local sy = cam:sy(pickup.y + 11, depth) + bob -- 124
			local iconSize = cam:len(20) -- 125
			fgDraw:drawEllipse( -- 126
				Vec2(sx, groundY + 1), -- 126
				cam:len(9.5), -- 126
				2.6, -- 126
				Color(10, 10, 14, 130) -- 126
			) -- 126
			fillRadialGlow( -- 127
				fgGlow, -- 127
				sx, -- 127
				sy, -- 127
				cam:len(14), -- 127
				cam:len(12), -- 127
				toColor(glowCol, 42), -- 127
				Color(glowCol.r, glowCol.g, glowCol.b, 0), -- 127
				10 -- 127
			) -- 127
			assets:tryPlacePath( -- 128
				"assets/art/props_ming.clip|" .. clipName, -- 129
				"pickup_" .. pickup.id, -- 130
				sx, -- 131
				sy, -- 132
				iconSize, -- 133
				iconSize, -- 134
				{ -- 135
					anchorX = 0.5, -- 136
					anchorY = 0.5, -- 137
					preserveAspect = true, -- 138
					layer = p.room.depth == nil and 3 or depthOrder(depth, 1) -- 139
				} -- 139
			) -- 139
		end -- 139
		::__continue10:: -- 139
	end -- 139
end -- 77
function PropsRenderer.prototype.drawZones(self, fgDraw, p, cam) -- 145
	local i = 0 -- 150
	do -- 150
		i = 0 -- 151
		while i < #p.room.zones do -- 151
			local z = p.room.zones[i + 1] -- 152
			local x0 = cam:sx(z.x0) -- 153
			local x1 = cam:sx(z.x1) -- 154
			local y0 = cam:sy(z.y) -- 155
			local zw = x1 - x0 -- 156
			if z.tint == 1 then -- 156
				local road = p.room.depth -- 159
				local front = cam:sy(z.y, road and road.min or -3) -- 160
				local back = cam:sy(z.y, road and road.max or 1) -- 161
				fgDraw:drawRect( -- 162
					Rect(x0, front, zw, back - front), -- 162
					Color(50, 35, 29, 48) -- 162
				) -- 162
			elseif z.tint == 2 then -- 162
				fgDraw:drawRect( -- 165
					Rect(x0, y0 - 4, zw, 8), -- 165
					Color(74, 58, 44, 220) -- 165
				) -- 165
				fgDraw:drawSegment( -- 166
					Vec2(x0, y0 + 2), -- 166
					Vec2(x1, y0 + 2), -- 166
					1.4, -- 166
					Color(128, 98, 72, 190) -- 166
				) -- 166
			elseif z.tint == 3 then -- 166
				fgDraw:drawRect( -- 169
					Rect(x0, y0 - 4, zw, 9), -- 169
					Color(118, 122, 130, 235) -- 169
				) -- 169
				local bricks = 4 -- 170
				local b = 1 -- 171
				do -- 171
					b = 1 -- 172
					while b < bricks do -- 172
						local bx = x0 + zw * b / bricks -- 173
						fgDraw:drawSegment( -- 174
							Vec2(bx, y0 - 4), -- 174
							Vec2(bx, y0 + 5), -- 174
							1, -- 174
							Color(42, 46, 56, 220) -- 174
						) -- 174
						b = b + 1 -- 172
					end -- 172
				end -- 172
				fgDraw:drawSegment( -- 176
					Vec2(x0, y0 + 4), -- 176
					Vec2(x1, y0 + 4), -- 176
					1.1, -- 176
					Color(168, 151, 127, 130) -- 176
				) -- 176
			end -- 176
			i = i + 1 -- 151
		end -- 151
	end -- 151
end -- 145
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 181
	for ____, m in ipairs(p.room.marks) do -- 189
		do -- 189
			if m.kind ~= 6 then -- 189
				goto __continue31 -- 191
			end -- 191
			local mx = cam:sx(m.x) -- 193
			local my = cam:sy(m.y) -- 194
			local hookY = my + cam:len(52) -- 195
			local armX = mx + cam:len(13) -- 196
			local lampY = hookY - cam:len(12) -- 197
			local wood = Color(82, 58, 40, 245) -- 198
			local joint = math.max( -- 199
				1, -- 199
				cam:len(2) -- 199
			) -- 199
			fgDraw:drawSegment( -- 200
				Vec2(mx, my), -- 200
				Vec2(mx, hookY), -- 200
				joint, -- 200
				wood -- 200
			) -- 200
			fgDraw:drawSegment( -- 201
				Vec2(mx, hookY), -- 201
				Vec2(armX, hookY), -- 201
				joint, -- 201
				wood -- 201
			) -- 201
			fgDraw:drawSegment( -- 202
				Vec2( -- 202
					mx, -- 202
					hookY - cam:len(7) -- 202
				), -- 202
				Vec2(armX - joint, hookY), -- 202
				joint * 0.7, -- 202
				wood -- 202
			) -- 202
			if not assets:tryPlace( -- 202
				"prop_lantern", -- 203
				"path_lamp_" .. tostring(m.x), -- 203
				armX, -- 203
				lampY, -- 203
				cam:len(16), -- 203
				cam:len(20), -- 203
				{layer = 1} -- 203
			) then -- 203
				fgDraw:drawRect( -- 204
					Rect( -- 204
						armX - cam:len(4), -- 204
						lampY - cam:len(7), -- 204
						cam:len(8), -- 204
						cam:len(14) -- 204
					), -- 204
					Color(192, 136, 64, 240), -- 205
					1.4, -- 205
					wood -- 205
				) -- 205
			end -- 205
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 207
			fillRadialGlow( -- 208
				fgGlow, -- 208
				armX, -- 208
				lampY, -- 208
				cam:len(23), -- 208
				cam:len(27), -- 208
				Color(239, 182, 106, 46 * flame), -- 208
				Color(231, 164, 91, 0), -- 209
				16 -- 209
			) -- 209
		end -- 209
		::__continue31:: -- 209
	end -- 209
end -- 181
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 213
	local c = p.room.cart -- 222
	if c.bodyW <= 0 then -- 222
		return -- 224
	end -- 224
	local depth = c.depth or 0 -- 226
	local raised = p.room.depth ~= nil -- 227
	local lo = math.min(c.startX, c.endX) -- 230
	local hi = math.max(c.startX, c.endX) -- 231
	if hi - lo > 4 then -- 231
		local rx0 = cam:sx(lo) -- 233
		local rx1 = cam:sx(hi) -- 234
		local ry = cam:sy(c.baseY, depth) -- 235
		fgDraw:drawSegment( -- 236
			Vec2(rx0, ry + 1), -- 236
			Vec2(rx1, ry + 1), -- 236
			1.2, -- 236
			Color(86, 65, 47, 150) -- 236
		) -- 236
		local dockX = cam:sx(c.endX) -- 237
		local width = cam:len(24) -- 238
		local lip = cam:len(3) -- 239
		fgDraw:drawRect( -- 240
			Rect(dockX - width * 0.5, ry, width, lip), -- 240
			Color(51, 37, 26, 230) -- 240
		) -- 240
		fgDraw:drawRect( -- 241
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 241
			Color(107, 77, 51, 230) -- 241
		) -- 241
	end -- 241
	local axleX = p.cartAxle -- 244
	local cx = cam:sx(axleX) -- 245
	local baseY = cam:sy(c.baseY, depth) -- 246
	local bw = cam:len(c.bodyW) -- 247
	local bh = cam:len(c.bodyH) -- 248
	local wr = cam:len(c.wheelR) -- 249
	local x0 = cx - bw * 0.5 -- 251
	local x1 = cx + bw * 0.5 -- 252
	local bodyY0 = baseY + wr * 1.05 -- 253
	local bodyY1 = bodyY0 + bh -- 254
	local artWidth = c.bodyW * 1.36 -- 257
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 258
	local opacity = raised and occlusion:update("cart", { -- 259
		x0 = axleX - artWidth * 0.5, -- 260
		x1 = axleX + artWidth * 0.5, -- 260
		y0 = c.baseY, -- 261
		y1 = c.baseY + artHeight, -- 261
		depth = {min = depth, max = depth + 8}, -- 262
		passThrough = true -- 262
	}, p, fadeDt) or 1 -- 262
	fgDraw:drawEllipse( -- 264
		Vec2(cx, baseY + 2), -- 264
		bw * 0.62, -- 264
		5, -- 264
		Color(4, 6, 10, 150 * opacity) -- 264
	) -- 264
	local painted = assets:tryPlace( -- 266
		"prop_cart", -- 266
		"cart", -- 266
		cx, -- 266
		baseY, -- 266
		cam:len(artWidth), -- 266
		cam:len(artHeight), -- 266
		{ -- 266
			layer = raised and depthOrder(depth, 2) or 2, -- 267
			opacity = opacity, -- 267
			color = occlusionTint(opacity) -- 267
		} -- 267
	) -- 267
	if not painted then -- 267
		fillVGradRect( -- 271
			fgDraw, -- 271
			x0, -- 271
			bodyY0, -- 271
			bw, -- 271
			bh, -- 271
			Color(48, 32, 28, 255), -- 271
			toColor(PALETTE.cartWood) -- 271
		) -- 271
		fgDraw:drawRect( -- 272
			Rect(x0, bodyY0, bw, bh), -- 272
			Color(0, 0, 0, 0), -- 272
			1.6, -- 272
			toColor(PALETTE.cartMetal, 220) -- 272
		) -- 272
		fgDraw:drawSegment( -- 274
			Vec2(x0 + bw * 0.33, bodyY0), -- 274
			Vec2(x0 + bw * 0.33, bodyY1), -- 274
			1.4, -- 274
			toColor(PALETTE.cartMetal, 180) -- 274
		) -- 274
		fgDraw:drawSegment( -- 275
			Vec2(x0 + bw * 0.67, bodyY0), -- 275
			Vec2(x0 + bw * 0.67, bodyY1), -- 275
			1.4, -- 275
			toColor(PALETTE.cartMetal, 180) -- 275
		) -- 275
		fgDraw:drawSegment( -- 276
			Vec2(x0 - 2, bodyY1), -- 276
			Vec2(x1 + 2, bodyY1), -- 276
			2.2, -- 276
			toColor(PALETTE.rimSilver, 220) -- 276
		) -- 276
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 279
		local wxA = x0 + bw * 0.24 -- 280
		local wxB = x1 - bw * 0.24 -- 281
		local wy = baseY + wr -- 282
		self:drawWheel( -- 283
			fgDraw, -- 283
			wxA, -- 283
			wy, -- 283
			wr, -- 283
			wheelSpin -- 283
		) -- 283
		self:drawWheel( -- 284
			fgDraw, -- 284
			wxB, -- 284
			wy, -- 284
			wr, -- 284
			wheelSpin -- 284
		) -- 284
	end -- 284
	local hx = cam:sx(axleX + c.handleOffset) -- 288
	local hTop = bodyY1 + cam:len(7) -- 289
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 290
	local handleSpan = math.abs(hx - edge) -- 293
	if not painted or handleSpan > cam:len(4) then -- 293
		fgDraw:drawSegment( -- 295
			Vec2(edge, bodyY0 + bh * 0.52), -- 295
			Vec2( -- 295
				hx, -- 295
				hTop - cam:len(4) -- 295
			), -- 295
			math.max( -- 296
				1.8, -- 296
				cam:len(2.4) -- 296
			), -- 296
			toColor(PALETTE.cartWood, 245 * opacity) -- 296
		) -- 296
		fgDraw:drawSegment( -- 297
			Vec2( -- 297
				hx, -- 297
				hTop - cam:len(5.5) -- 297
			), -- 297
			Vec2(hx, hTop), -- 297
			math.max( -- 298
				2.2, -- 298
				cam:len(3.2) -- 298
			), -- 298
			Color(126, 91, 61, 245 * opacity) -- 298
		) -- 298
	end -- 298
	if painted then -- 298
		return -- 302
	end -- 302
	local clothAnchorX = c.clothSide < 0 and x0 + 3 or x1 - 3 -- 305
	local wave = math.sin(time * 3.4) * 5 + (p.gripping and -p.player.facing * 6 or 0) -- 306
	local wave2 = math.cos(time * 2.8) * 3.5 -- 307
	local clothH = cam:len(26) -- 308
	local clothW = cam:len(14) -- 309
	fgDraw:drawPolygon( -- 310
		{ -- 310
			Vec2(clothAnchorX - 3, bodyY1 + 2), -- 311
			Vec2(clothAnchorX + clothW * 0.65, bodyY1 + 2), -- 312
			Vec2(clothAnchorX + clothW * 0.45 + wave2, bodyY1 - clothH * 0.55), -- 313
			Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 314
			Vec2(clothAnchorX - clothW * 0.72 + wave * 0.7, bodyY1 - clothH * 0.62) -- 315
		}, -- 315
		toColor(PALETTE.clothRed) -- 316
	) -- 316
	fgDraw:drawSegment( -- 318
		Vec2(clothAnchorX - 2, bodyY1 + 1), -- 319
		Vec2(clothAnchorX - clothW * 0.35 + wave, bodyY1 - clothH), -- 320
		1.6, -- 321
		toColor(PALETTE.clothRedHighlight, 220) -- 322
	) -- 322
end -- 213
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 326
	draw:drawCircle( -- 327
		Vec2(cx, cy), -- 327
		r, -- 327
		Color(24, 28, 36, 255) -- 327
	) -- 327
	draw:drawRing( -- 328
		Vec2(cx, cy), -- 328
		r * 0.72, -- 328
		r, -- 328
		Color(0, 0, 0, 0), -- 328
		1.6, -- 328
		toColor(PALETTE.cartMetal) -- 328
	) -- 328
	local k = 0 -- 329
	do -- 329
		k = 0 -- 330
		while k < 4 do -- 330
			local a = spin + k * math.pi / 4 -- 331
			draw:drawSegment( -- 332
				Vec2( -- 333
					cx - math.cos(a) * r * 0.72, -- 333
					cy - math.sin(a) * r * 0.72 -- 333
				), -- 333
				Vec2( -- 334
					cx + math.cos(a) * r * 0.72, -- 334
					cy + math.sin(a) * r * 0.72 -- 334
				), -- 334
				1.2, -- 335
				toColor(PALETTE.steelLight, 190) -- 336
			) -- 336
			k = k + 1 -- 330
		end -- 330
	end -- 330
	draw:drawDot( -- 339
		Vec2(cx, cy), -- 339
		math.max(2.2, r * 0.18), -- 339
		toColor(PALETTE.rimSilver) -- 339
	) -- 339
end -- 326
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 342
	local bottle = p.room.bottle -- 351
	if bottle ~= nil then -- 351
		local bx0 = cam:sx(bottle.x - 16) -- 353
		local bx1 = cam:sx(bottle.x + 16) -- 354
		local by0 = cam:sy(0) -- 355
		local by1 = cam:sy(52) -- 356
		if not assets:tryPlacePath( -- 356
			"assets/art/props_ming.clip|bottle_rack", -- 357
			"village_bottle_rack", -- 357
			cam:sx(bottle.x), -- 357
			by0, -- 357
			cam:len(44), -- 357
			by1 - by0, -- 357
			{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = 2} -- 357
		) then -- 357
			local beam = cam:len(3.2) -- 363
			local side = Color(78, 57, 41, 255) -- 364
			fgDraw:drawRect( -- 365
				Rect(bx0, by0, beam, by1 - by0), -- 365
				side -- 365
			) -- 365
			fgDraw:drawRect( -- 366
				Rect(bx1 - beam, by0, beam, by1 - by0), -- 366
				side -- 366
			) -- 366
			for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 367
				fgDraw:drawRect( -- 368
					Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 368
					Color(106, 78, 56, 255), -- 369
					1, -- 369
					Color(56, 42, 34, 240) -- 369
				) -- 369
			end -- 369
		end -- 369
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 369
			self:drawBottleSprite( -- 373
				fgDraw, -- 373
				assets, -- 373
				"bottle_shelf", -- 373
				cam:sx(bottle.x), -- 373
				cam:sy(56), -- 373
				cam.ppu, -- 373
				0 -- 373
			) -- 373
		end -- 373
	end -- 373
	local arch = p.room.arch -- 377
	local tx0 = cam:sx(arch.x0 - 4) -- 378
	local tx1 = cam:sx(arch.x1 + 4) -- 379
	local ty0 = cam:sy(arch.y) -- 380
	local tyBot = cam:sy(arch.y + arch.h) -- 381
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 382
	fillVGradRect( -- 383
		fgDraw, -- 383
		tx0 + 6, -- 383
		ty0, -- 383
		tx1 - tx0 - 12, -- 383
		tyBot - ty0, -- 383
		Color(9, 10, 15, 165), -- 384
		Color(9, 10, 15, 100) -- 384
	) -- 384
	if not assets:tryPlace( -- 384
		"prop_table", -- 385
		"village_table", -- 385
		(tx0 + tx1) * 0.5, -- 385
		ty0, -- 385
		tx1 - tx0, -- 386
		tyTop - ty0, -- 386
		{layer = 6} -- 386
	) then -- 386
		fgDraw:drawRect( -- 387
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 387
			toColor(PALETTE.cartWood) -- 387
		) -- 387
		fgDraw:drawRect( -- 388
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 388
			toColor(PALETTE.cartWood) -- 388
		) -- 388
		fgDraw:drawRect( -- 389
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 389
			toColor(PALETTE.cartWood) -- 389
		) -- 389
	end -- 389
	if p.hasBottle and p.aimHold <= 0 then -- 389
		local pl = p.player -- 394
		self:drawBottleSprite( -- 395
			fgDraw, -- 395
			assets, -- 395
			"bottle_held", -- 395
			cam:sx(pl.x + pl.facing * 10), -- 395
			cam:sy(pl.y + pl.h * 0.52), -- 395
			cam.ppu, -- 395
			pl.facing * 0.2 -- 395
		) -- 395
	end -- 395
	if p.bottleFly ~= nil then -- 395
		self:drawBottleSprite( -- 398
			fgDraw, -- 398
			assets, -- 398
			"bottle_air", -- 398
			cam:sx(p.bottleFly.x), -- 398
			cam:sy(p.bottleFly.y), -- 398
			cam.ppu, -- 398
			time * 14 -- 398
		) -- 398
	end -- 398
	if p.hasBottle and p.aimHold > 0 then -- 398
		local pl = p.player -- 403
		local endX = p.bottleAimX -- 404
		local endY = p.bottleAimY -- 405
		if endX < 0 then -- 405
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 407
			endX = wAim.x -- 408
			endY = 0 -- 409
		end -- 409
		local dir = endX >= pl.x and 1 or -1 -- 411
		local x0 = pl.x + dir * 10 -- 412
		local y0 = pl.y + pl.h * 0.7 -- 413
		local T = 0.62 -- 414
		local vx = (endX - x0) / T -- 415
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 416
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 418
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 419
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 420
		local activeAim = p.aimHold > 0.01 -- 421
		local steps = 18 -- 423
		local k = 1 -- 424
		do -- 424
			k = 1 -- 425
			while k <= steps do -- 425
				local tt = k / steps * T -- 426
				local wx = x0 + vx * tt -- 427
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 428
				local sx = cam:sx(wx) -- 429
				local sy = cam:sy(wy) -- 430
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 431
				fgGlow:drawDot( -- 432
					Vec2(sx, sy), -- 432
					activeAim and 3.2 or 2.2, -- 432
					toColor(arcCol, alpha) -- 432
				) -- 432
				k = k + 1 -- 425
			end -- 425
		end -- 425
		local lx = cam:sx(endX) -- 435
		local ly = cam:sy(endY + 2) -- 436
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 437
		fgGlow:drawRing( -- 438
			Vec2(lx, ly), -- 438
			8, -- 438
			11, -- 438
			Color(0, 0, 0, 0), -- 438
			1.6, -- 438
			toColor(arcCol, activeAim and 245 or 165) -- 438
		) -- 438
		if isBrick then -- 438
			fgGlow:drawRing( -- 440
				Vec2(lx, ly), -- 440
				28 * pulse, -- 440
				30 * pulse, -- 440
				Color(0, 0, 0, 0), -- 440
				1.2, -- 440
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 440
			) -- 440
			fillRadialGlow( -- 441
				fgGlow, -- 441
				lx, -- 441
				ly, -- 441
				36, -- 441
				14, -- 441
				Color(242, 188, 96, activeAim and 95 or 48), -- 441
				Color(242, 188, 96, 0), -- 441
				14 -- 441
			) -- 441
		end -- 441
	end -- 441
end -- 342
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 446
	local height = math.max(10, ppu * 10.5) -- 453
	if not assets:tryPlace( -- 453
		"prop_bottle", -- 454
		id, -- 454
		cx, -- 454
		cy, -- 454
		height, -- 454
		height, -- 454
		{angle = tilt * 180 / math.pi, layer = 6} -- 454
	) then -- 454
		local dx = math.sin(tilt) * height * 0.4 -- 457
		local dy = math.cos(tilt) * height * 0.5 -- 458
		fgDraw:drawSegment( -- 459
			Vec2(cx - dx, cy - dy), -- 459
			Vec2(cx + dx, cy + dy), -- 459
			height * 0.32, -- 459
			toColor(PALETTE.amber, 225) -- 460
		) -- 460
	end -- 460
end -- 446
return ____exports -- 446