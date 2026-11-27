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
function PropsRenderer.prototype.drawAll(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt, groundArt) -- 25
	self:drawZones(fgDraw, groundArt or assets, p, cam) -- 36
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
	self:drawBracedShield(fgDraw, assets, p, cam) -- 39
	self:drawCraftMaterials( -- 40
		fgDraw, -- 40
		fgGlow, -- 40
		assets, -- 40
		p, -- 40
		cam, -- 40
		time -- 40
	) -- 40
	if p.phase == "prologue-give" and p.phaseTick >= 12 and p.phaseTick < 36 then -- 40
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
	if p.room.key == "village" then -- 46
		self:drawVillageProps( -- 49
			fgDraw, -- 49
			fgGlow, -- 49
			assets, -- 49
			p, -- 49
			cam, -- 49
			time -- 49
		) -- 49
	end -- 49
end -- 25
function PropsRenderer.prototype.drawBracedShield(self, fgDraw, assets, p, cam) -- 54
	local sh = p.bracedShield -- 55
	if sh == nil or sh.hp <= 0 then -- 55
		return -- 57
	end -- 57
	local cx = cam:sx(sh.x) -- 59
	local depthEnabled = p.room.depth ~= nil -- 60
	local dScale = cam:depthScale(p.player.depth, depthEnabled) -- 61
	local by = cam:sy(sh.y, p.player.depth) -- 62
	local w = math.max( -- 63
		8, -- 63
		cam:len(12) * dScale -- 63
	) -- 63
	local h = cam:len(sh.h) * dScale -- 64
	local shieldLayer = depthEnabled and depthOrder(p.player.depth, 2) or 3 -- 65
	assets:tryPlace( -- 66
		"dp_shadow_contact", -- 66
		"braced_shield_shadow", -- 66
		cx, -- 66
		by + 1, -- 66
		math.max(w * 2.2, h * 0.92), -- 66
		cam:len(7.5) * dScale, -- 66
		{layer = shieldLayer - 1, opacity = 0.78} -- 66
	) -- 66
	if assets:tryPlacePath( -- 66
		"assets/art/props_ming.clip|braced_shield", -- 70
		"braced_shield_prop", -- 70
		cx, -- 70
		by, -- 70
		h * 0.95, -- 70
		h * 1.04, -- 70
		{ -- 70
			anchorX = 0.5, -- 71
			anchorY = 0, -- 72
			preserveAspect = true, -- 73
			color = sh.hp <= 1 and Color(218, 178, 154, 255) or Color(255, 255, 255, 255), -- 74
			layer = shieldLayer -- 75
		} -- 75
	) then -- 75
		return -- 77
	end -- 77
	fgDraw:drawSegment( -- 79
		Vec2(cx - w * 0.65, by), -- 79
		Vec2(cx - w * 0.15, by + h * 0.55), -- 79
		2.2, -- 79
		Color(84, 58, 38, 255) -- 79
	) -- 79
	fgDraw:drawRect( -- 80
		Rect(cx - w * 0.5, by + 2, w, h - 2), -- 80
		Color(104, 72, 46, 248), -- 80
		1.4, -- 80
		Color(172, 178, 184, 235) -- 80
	) -- 80
	fgDraw:drawCircle( -- 81
		Vec2(cx, by + h * 0.52), -- 81
		math.max( -- 81
			2.5, -- 81
			cam:len(4) -- 81
		), -- 81
		Color(148, 154, 160, 245) -- 81
	) -- 81
end -- 54
function PropsRenderer.prototype.drawCraftMaterials(self, fgDraw, fgGlow, assets, p, cam, time) -- 84
	for ____, pickup in ipairs(p.pickups) do -- 92
		do -- 92
			local kind = pickup.kind -- 94
			if pickup.id == "" or p.run.taken[pickup.id] then -- 94
				goto __continue10 -- 96
			end -- 96
			local clipName = "" -- 98
			local glowCol = PALETTE.amber -- 99
			if kind == "wood" then -- 99
				clipName = "pickup_wood" -- 101
				glowCol = PALETTE.amber -- 102
			elseif kind == "bell" then -- 102
				clipName = "pickup_bell" -- 104
				glowCol = PALETTE.amberCore -- 105
			elseif kind == "scrap" then -- 105
				clipName = "pickup_scrap" -- 107
				glowCol = PALETTE.amber -- 108
			elseif kind == "wedge" then -- 108
				clipName = "pickup_wedge" -- 110
				glowCol = PALETTE.emerald -- 111
			elseif kind == "ammo" then -- 111
				clipName = "pickup_ammo" -- 113
				glowCol = PALETTE.cyan -- 114
			elseif kind == "shield" then -- 114
				clipName = "pickup_shield" -- 116
				glowCol = PALETTE.cyan -- 117
			elseif kind == "pass" then -- 117
				clipName = "pickup_pass" -- 119
				glowCol = PALETTE.amberCore -- 120
			elseif kind == "quickbelt" then -- 120
				clipName = "pickup_quickbelt" -- 122
				glowCol = PALETTE.amberCore -- 123
			else -- 123
				goto __continue10 -- 125
			end -- 125
			local depth = pickup.depth or 0 -- 127
			local depthEnabled = p.room.depth ~= nil -- 128
			local dScale = cam:depthScale(depth, depthEnabled) -- 129
			local sx = cam:sx(pickup.x) -- 130
			local groundY = cam:sy(pickup.y, depth) -- 131
			local bob = math.sin(time * 3.1 + pickup.x * 0.03) * cam:len(2.4) -- 132
			local sy = cam:sy(pickup.y + 11, depth) + bob -- 133
			local iconSize = cam:len(20) * dScale -- 134
			local itemLayer = depthEnabled and depthOrder(depth, 2) or 3 -- 135
			assets:tryPlace( -- 136
				"dp_shadow_contact", -- 136
				"pickup_shadow_" .. pickup.id, -- 136
				sx, -- 136
				groundY + 1, -- 136
				cam:len(20) * dScale, -- 136
				cam:len(6.5) * dScale, -- 136
				{layer = itemLayer - 1, opacity = 0.72} -- 136
			) -- 136
			fillRadialGlow( -- 140
				fgGlow, -- 140
				sx, -- 140
				sy, -- 140
				cam:len(14), -- 140
				cam:len(12), -- 140
				toColor(glowCol, 42), -- 140
				Color(glowCol.r, glowCol.g, glowCol.b, 0), -- 140
				10 -- 140
			) -- 140
			assets:tryPlacePath( -- 141
				"assets/art/props_ming.clip|" .. clipName, -- 142
				"pickup_" .. pickup.id, -- 143
				sx, -- 144
				sy, -- 145
				iconSize, -- 146
				iconSize, -- 147
				{anchorX = 0.5, anchorY = 0.5, preserveAspect = true, layer = itemLayer} -- 148
			) -- 148
		end -- 148
		::__continue10:: -- 148
	end -- 148
end -- 84
function PropsRenderer.prototype.drawZones(self, fgDraw, groundArt, p, cam) -- 158
	local i = 0 -- 164
	do -- 164
		i = 0 -- 165
		while i < #p.room.zones do -- 165
			local z = p.room.zones[i + 1] -- 166
			local x0 = cam:sx(z.x0) -- 167
			local x1 = cam:sx(z.x1) -- 168
			local y0 = cam:sy(z.y) -- 169
			local zw = x1 - x0 -- 170
			if z.tint == 1 then -- 170
				local road = p.room.depth -- 174
				local front = cam:sy(z.y, road and road.min or -3) -- 175
				local back = cam:sy(z.y, road and road.max or 1) -- 176
				local zh = math.max(8, back - front) -- 177
				local tileW = math.max( -- 178
					72, -- 178
					cam:len(110) -- 178
				) -- 178
				local cols = math.max( -- 179
					1, -- 179
					math.ceil(zw / tileW) -- 179
				) -- 179
				local segW = zw / cols -- 180
				do -- 180
					local c = 0 -- 181
					while c < cols do -- 181
						groundArt:tryPlace( -- 182
							"dp_scorch_zone", -- 182
							(("zone_scorch_" .. tostring(i)) .. "_") .. tostring(c), -- 182
							x0 + (c + 0.5) * segW, -- 182
							front, -- 182
							segW + 1, -- 182
							zh, -- 182
							{layer = 8, opacity = 0.72} -- 182
						) -- 182
						c = c + 1 -- 181
					end -- 181
				end -- 181
			elseif z.tint == 2 then -- 181
				if not groundArt:tryPlace( -- 181
					"fe_ground_soft", -- 188
					"zone_soft_" .. tostring(i), -- 188
					(x0 + x1) * 0.5, -- 188
					y0 - cam:len(4), -- 188
					zw, -- 188
					cam:len(14), -- 188
					{layer = 6} -- 188
				) then -- 188
					fgDraw:drawRect( -- 189
						Rect(x0, y0 - 4, zw, 8), -- 189
						Color(74, 58, 44, 220) -- 189
					) -- 189
				end -- 189
			elseif z.tint == 3 then -- 189
				if not groundArt:tryPlace( -- 189
					"fe_ground_brick", -- 192
					"zone_brick_" .. tostring(i), -- 192
					(x0 + x1) * 0.5, -- 192
					y0 - cam:len(4), -- 192
					zw, -- 192
					cam:len(14), -- 192
					{layer = 6} -- 192
				) then -- 192
					fgDraw:drawRect( -- 193
						Rect(x0, y0 - 4, zw, 9), -- 193
						Color(118, 122, 130, 235) -- 193
					) -- 193
				end -- 193
			end -- 193
			i = i + 1 -- 165
		end -- 165
	end -- 165
end -- 158
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 199
	for ____, m in ipairs(p.room.marks) do -- 207
		do -- 207
			if m.kind ~= 6 then -- 207
				goto __continue33 -- 209
			end -- 209
			local mx = cam:sx(m.x) -- 211
			local my = cam:sy(m.y) -- 212
			local hookY = my + cam:len(52) -- 213
			local armX = mx + cam:len(13) -- 214
			local lampY = hookY - cam:len(12) -- 215
			local wood = Color(82, 58, 40, 245) -- 216
			local joint = math.max( -- 217
				1, -- 217
				cam:len(2) -- 217
			) -- 217
			fgDraw:drawSegment( -- 218
				Vec2(mx, my), -- 218
				Vec2(mx, hookY), -- 218
				joint, -- 218
				wood -- 218
			) -- 218
			fgDraw:drawSegment( -- 219
				Vec2(mx, hookY), -- 219
				Vec2(armX, hookY), -- 219
				joint, -- 219
				wood -- 219
			) -- 219
			fgDraw:drawSegment( -- 220
				Vec2( -- 220
					mx, -- 220
					hookY - cam:len(7) -- 220
				), -- 220
				Vec2(armX - joint, hookY), -- 220
				joint * 0.7, -- 220
				wood -- 220
			) -- 220
			if not assets:tryPlace( -- 220
				"prop_lantern", -- 221
				"path_lamp_" .. tostring(m.x), -- 221
				armX, -- 221
				lampY, -- 221
				cam:len(16), -- 221
				cam:len(20), -- 221
				{layer = 1} -- 221
			) then -- 221
				fgDraw:drawRect( -- 222
					Rect( -- 222
						armX - cam:len(4), -- 222
						lampY - cam:len(7), -- 222
						cam:len(8), -- 222
						cam:len(14) -- 222
					), -- 222
					Color(192, 136, 64, 240), -- 223
					1.4, -- 223
					wood -- 223
				) -- 223
			end -- 223
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 225
			fillRadialGlow( -- 226
				fgGlow, -- 226
				armX, -- 226
				lampY, -- 226
				cam:len(23), -- 226
				cam:len(27), -- 226
				Color(239, 182, 106, 46 * flame), -- 226
				Color(231, 164, 91, 0), -- 227
				16 -- 227
			) -- 227
		end -- 227
		::__continue33:: -- 227
	end -- 227
end -- 199
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 231
	local c = p.room.cart -- 240
	if c.bodyW <= 0 then -- 240
		return -- 242
	end -- 242
	local depth = c.depth or 0 -- 244
	local raised = p.room.depth ~= nil -- 245
	local lo = math.min(c.startX, c.endX) -- 248
	local hi = math.max(c.startX, c.endX) -- 249
	if hi - lo > 4 then -- 249
		local rx0 = cam:sx(lo) -- 251
		local rx1 = cam:sx(hi) -- 252
		local ry = cam:sy(c.baseY, depth) -- 253
		fgDraw:drawSegment( -- 254
			Vec2(rx0, ry + 1), -- 254
			Vec2(rx1, ry + 1), -- 254
			1.2, -- 254
			Color(86, 65, 47, 150) -- 254
		) -- 254
		local dockX = cam:sx(c.endX) -- 255
		local width = cam:len(24) -- 256
		local lip = cam:len(3) -- 257
		fgDraw:drawRect( -- 258
			Rect(dockX - width * 0.5, ry, width, lip), -- 258
			Color(51, 37, 26, 230) -- 258
		) -- 258
		fgDraw:drawRect( -- 259
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 259
			Color(107, 77, 51, 230) -- 259
		) -- 259
	end -- 259
	local axleX = p.cartAxle -- 262
	local cx = cam:sx(axleX) -- 263
	local baseY = cam:sy(c.baseY, depth) -- 264
	local bw = cam:len(c.bodyW) -- 265
	local bh = cam:len(c.bodyH) -- 266
	local wr = cam:len(c.wheelR) -- 267
	local x0 = cx - bw * 0.5 -- 269
	local x1 = cx + bw * 0.5 -- 270
	local bodyY0 = baseY + wr * 1.05 -- 271
	local bodyY1 = bodyY0 + bh -- 272
	local artWidth = c.bodyW * 1.36 -- 275
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 276
	local dScale = cam:depthScale(depth, raised) -- 277
	local opacity = raised and occlusion:update("cart", { -- 278
		x0 = axleX - artWidth * 0.5, -- 279
		x1 = axleX + artWidth * 0.5, -- 279
		y0 = c.baseY, -- 280
		y1 = c.baseY + artHeight, -- 280
		depth = {min = depth, max = depth + 8}, -- 281
		passThrough = true -- 281
	}, p, fadeDt) or 1 -- 281
	local cartLayer = raised and depthOrder(depth, 2) or 2 -- 283
	assets:tryPlace( -- 284
		"dp_shadow_contact", -- 284
		"cart_shadow", -- 284
		cx, -- 284
		baseY + 1, -- 284
		bw * 1.48 * dScale, -- 284
		cam:len(11) * dScale, -- 284
		{layer = cartLayer - 1, opacity = 0.85 * opacity} -- 284
	) -- 284
	local painted = assets:tryPlace( -- 289
		"prop_cart", -- 289
		"cart", -- 289
		cx, -- 289
		baseY, -- 289
		cam:len(artWidth) * dScale, -- 289
		cam:len(artHeight) * dScale, -- 289
		{ -- 289
			layer = cartLayer, -- 290
			opacity = opacity, -- 290
			color = occlusionTint(opacity) -- 290
		} -- 290
	) -- 290
	if not painted then -- 290
		fillVGradRect( -- 294
			fgDraw, -- 294
			x0, -- 294
			bodyY0, -- 294
			bw, -- 294
			bh, -- 294
			Color(48, 32, 28, 255), -- 294
			toColor(PALETTE.cartWood) -- 294
		) -- 294
		fgDraw:drawRect( -- 295
			Rect(x0, bodyY0, bw, bh), -- 295
			Color(0, 0, 0, 0), -- 295
			1.6, -- 295
			toColor(PALETTE.cartMetal, 220) -- 295
		) -- 295
		fgDraw:drawSegment( -- 297
			Vec2(x0 + bw * 0.33, bodyY0), -- 297
			Vec2(x0 + bw * 0.33, bodyY1), -- 297
			1.4, -- 297
			toColor(PALETTE.cartMetal, 180) -- 297
		) -- 297
		fgDraw:drawSegment( -- 298
			Vec2(x0 + bw * 0.67, bodyY0), -- 298
			Vec2(x0 + bw * 0.67, bodyY1), -- 298
			1.4, -- 298
			toColor(PALETTE.cartMetal, 180) -- 298
		) -- 298
		fgDraw:drawSegment( -- 299
			Vec2(x0 - 2, bodyY1), -- 299
			Vec2(x1 + 2, bodyY1), -- 299
			2.2, -- 299
			toColor(PALETTE.rimSilver, 220) -- 299
		) -- 299
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 302
		local wxA = x0 + bw * 0.24 -- 303
		local wxB = x1 - bw * 0.24 -- 304
		local wy = baseY + wr -- 305
		self:drawWheel( -- 306
			fgDraw, -- 306
			wxA, -- 306
			wy, -- 306
			wr, -- 306
			wheelSpin -- 306
		) -- 306
		self:drawWheel( -- 307
			fgDraw, -- 307
			wxB, -- 307
			wy, -- 307
			wr, -- 307
			wheelSpin -- 307
		) -- 307
	end -- 307
	local hx = cam:sx(axleX + c.handleOffset) -- 311
	local hTop = bodyY1 + cam:len(7) -- 312
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 313
	local handleSpan = math.abs(hx - edge) -- 316
	if not painted or handleSpan > cam:len(4) then -- 316
		fgDraw:drawSegment( -- 318
			Vec2(edge, bodyY0 + bh * 0.52), -- 318
			Vec2( -- 318
				hx, -- 318
				hTop - cam:len(4) -- 318
			), -- 318
			math.max( -- 319
				1.8, -- 319
				cam:len(2.4) -- 319
			), -- 319
			toColor(PALETTE.cartWood, 245 * opacity) -- 319
		) -- 319
		fgDraw:drawSegment( -- 320
			Vec2( -- 320
				hx, -- 320
				hTop - cam:len(5.5) -- 320
			), -- 320
			Vec2(hx, hTop), -- 320
			math.max( -- 321
				2.2, -- 321
				cam:len(3.2) -- 321
			), -- 321
			Color(126, 91, 61, 245 * opacity) -- 321
		) -- 321
	end -- 321
	if painted then -- 321
		return -- 325
	end -- 325
end -- 231
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 329
	draw:drawCircle( -- 330
		Vec2(cx, cy), -- 330
		r, -- 330
		Color(24, 28, 36, 255) -- 330
	) -- 330
	draw:drawRing( -- 331
		Vec2(cx, cy), -- 331
		r * 0.72, -- 331
		r, -- 331
		Color(0, 0, 0, 0), -- 331
		1.6, -- 331
		toColor(PALETTE.cartMetal) -- 331
	) -- 331
	local k = 0 -- 332
	do -- 332
		k = 0 -- 333
		while k < 4 do -- 333
			local a = spin + k * math.pi / 4 -- 334
			draw:drawSegment( -- 335
				Vec2( -- 336
					cx - math.cos(a) * r * 0.72, -- 336
					cy - math.sin(a) * r * 0.72 -- 336
				), -- 336
				Vec2( -- 337
					cx + math.cos(a) * r * 0.72, -- 337
					cy + math.sin(a) * r * 0.72 -- 337
				), -- 337
				1.2, -- 338
				toColor(PALETTE.steelLight, 190) -- 339
			) -- 339
			k = k + 1 -- 333
		end -- 333
	end -- 333
	draw:drawDot( -- 342
		Vec2(cx, cy), -- 342
		math.max(2.2, r * 0.18), -- 342
		toColor(PALETTE.rimSilver) -- 342
	) -- 342
end -- 329
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 345
	local bottle = p.room.bottle -- 354
	if bottle ~= nil then -- 354
		local bx0 = cam:sx(bottle.x - 16) -- 356
		local bx1 = cam:sx(bottle.x + 16) -- 357
		local by0 = cam:sy(0) -- 358
		local by1 = cam:sy(52) -- 359
		if not assets:tryPlacePath( -- 359
			"assets/art/props_ming.clip|bottle_rack", -- 360
			"village_bottle_rack", -- 360
			cam:sx(bottle.x), -- 360
			by0, -- 360
			cam:len(44), -- 360
			by1 - by0, -- 360
			{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = 2} -- 360
		) then -- 360
			local beam = cam:len(3.2) -- 366
			local side = Color(78, 57, 41, 255) -- 367
			fgDraw:drawRect( -- 368
				Rect(bx0, by0, beam, by1 - by0), -- 368
				side -- 368
			) -- 368
			fgDraw:drawRect( -- 369
				Rect(bx1 - beam, by0, beam, by1 - by0), -- 369
				side -- 369
			) -- 369
			for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 370
				fgDraw:drawRect( -- 371
					Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 371
					Color(106, 78, 56, 255), -- 372
					1, -- 372
					Color(56, 42, 34, 240) -- 372
				) -- 372
			end -- 372
		end -- 372
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 372
			self:drawBottleSprite( -- 376
				fgDraw, -- 376
				assets, -- 376
				"bottle_shelf", -- 376
				cam:sx(bottle.x), -- 376
				cam:sy(56), -- 376
				cam.ppu, -- 376
				0 -- 376
			) -- 376
		end -- 376
	end -- 376
	local arch = p.room.arch -- 380
	local tx0 = cam:sx(arch.x0 - 4) -- 381
	local tx1 = cam:sx(arch.x1 + 4) -- 382
	local ty0 = cam:sy(arch.y) -- 383
	local tyBot = cam:sy(arch.y + arch.h) -- 384
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 385
	fillVGradRect( -- 386
		fgDraw, -- 386
		tx0 + 6, -- 386
		ty0, -- 386
		tx1 - tx0 - 12, -- 386
		tyBot - ty0, -- 386
		Color(9, 10, 15, 165), -- 387
		Color(9, 10, 15, 100) -- 387
	) -- 387
	if not assets:tryPlace( -- 387
		"prop_table", -- 388
		"village_table", -- 388
		(tx0 + tx1) * 0.5, -- 388
		ty0, -- 388
		tx1 - tx0, -- 389
		tyTop - ty0, -- 389
		{layer = 6} -- 389
	) then -- 389
		fgDraw:drawRect( -- 390
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 390
			toColor(PALETTE.cartWood) -- 390
		) -- 390
		fgDraw:drawRect( -- 391
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 391
			toColor(PALETTE.cartWood) -- 391
		) -- 391
		fgDraw:drawRect( -- 392
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 392
			toColor(PALETTE.cartWood) -- 392
		) -- 392
	end -- 392
	if p.hasBottle and p.aimHold <= 0 then -- 392
		local pl = p.player -- 397
		self:drawBottleSprite( -- 398
			fgDraw, -- 398
			assets, -- 398
			"bottle_held", -- 398
			cam:sx(pl.x + pl.facing * 10), -- 398
			cam:sy(pl.y + pl.h * 0.52), -- 398
			cam.ppu, -- 398
			pl.facing * 0.2 -- 398
		) -- 398
	end -- 398
	if p.bottleFly ~= nil then -- 398
		self:drawBottleSprite( -- 401
			fgDraw, -- 401
			assets, -- 401
			"bottle_air", -- 401
			cam:sx(p.bottleFly.x), -- 401
			cam:sy(p.bottleFly.y), -- 401
			cam.ppu, -- 401
			time * 14 -- 401
		) -- 401
	end -- 401
	if p.hasBottle and p.aimHold > 0 then -- 401
		local pl = p.player -- 406
		local endX = p.bottleAimX -- 407
		local endY = p.bottleAimY -- 408
		if endX < 0 then -- 408
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 410
			endX = wAim.x -- 411
			endY = 0 -- 412
		end -- 412
		local dir = endX >= pl.x and 1 or -1 -- 414
		local x0 = pl.x + dir * 10 -- 415
		local y0 = pl.y + pl.h * 0.7 -- 416
		local T = 0.62 -- 417
		local vx = (endX - x0) / T -- 418
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 419
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 421
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 422
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 423
		local activeAim = p.aimHold > 0.01 -- 424
		local steps = 18 -- 426
		local k = 1 -- 427
		do -- 427
			k = 1 -- 428
			while k <= steps do -- 428
				local tt = k / steps * T -- 429
				local wx = x0 + vx * tt -- 430
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 431
				local sx = cam:sx(wx) -- 432
				local sy = cam:sy(wy) -- 433
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 434
				fgGlow:drawDot( -- 435
					Vec2(sx, sy), -- 435
					activeAim and 3.2 or 2.2, -- 435
					toColor(arcCol, alpha) -- 435
				) -- 435
				k = k + 1 -- 428
			end -- 428
		end -- 428
		local lx = cam:sx(endX) -- 438
		local ly = cam:sy(endY + 2) -- 439
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 440
		fgGlow:drawRing( -- 441
			Vec2(lx, ly), -- 441
			8, -- 441
			11, -- 441
			Color(0, 0, 0, 0), -- 441
			1.6, -- 441
			toColor(arcCol, activeAim and 245 or 165) -- 441
		) -- 441
		if isBrick then -- 441
			fgGlow:drawRing( -- 443
				Vec2(lx, ly), -- 443
				28 * pulse, -- 443
				30 * pulse, -- 443
				Color(0, 0, 0, 0), -- 443
				1.2, -- 443
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 443
			) -- 443
			fillRadialGlow( -- 444
				fgGlow, -- 444
				lx, -- 444
				ly, -- 444
				36, -- 444
				14, -- 444
				Color(242, 188, 96, activeAim and 95 or 48), -- 444
				Color(242, 188, 96, 0), -- 444
				14 -- 444
			) -- 444
		end -- 444
	end -- 444
end -- 345
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 449
	local height = math.max(10, ppu * 10.5) -- 456
	if not assets:tryPlace( -- 456
		"prop_bottle", -- 457
		id, -- 457
		cx, -- 457
		cy, -- 457
		height, -- 457
		height, -- 457
		{angle = tilt * 180 / math.pi, layer = 6} -- 457
	) then -- 457
		local dx = math.sin(tilt) * height * 0.4 -- 460
		local dy = math.cos(tilt) * height * 0.5 -- 461
		fgDraw:drawSegment( -- 462
			Vec2(cx - dx, cy - dy), -- 462
			Vec2(cx + dx, cy + dy), -- 462
			height * 0.32, -- 462
			toColor(PALETTE.amber, 225) -- 463
		) -- 463
	end -- 463
end -- 449
return ____exports -- 449