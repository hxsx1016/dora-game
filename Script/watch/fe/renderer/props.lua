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
end -- 25
function PropsRenderer.prototype.drawBracedShield(self, fgDraw, assets, p, cam) -- 54
	local sh = p.bracedShield -- 55
	if sh == nil or sh.hp <= 0 then -- 56
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
	if assets:tryPlacePath( -- 70
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
			if pickup.id == "" or p.run.taken[pickup.id] then -- 95
				goto __continue10 -- 96
			end -- 96
			local clipName = "" -- 98
			local glowCol = PALETTE.amber -- 99
			if kind == "wood" then -- 100
				clipName = "pickup_wood" -- 101
				glowCol = PALETTE.amber -- 102
			elseif kind == "bell" then -- 103
				clipName = "pickup_bell" -- 104
				glowCol = PALETTE.amberCore -- 105
			elseif kind == "scrap" then -- 106
				clipName = "pickup_scrap" -- 107
				glowCol = PALETTE.amber -- 108
			elseif kind == "wedge" then -- 109
				clipName = "pickup_wedge" -- 110
				glowCol = PALETTE.emerald -- 111
			elseif kind == "ammo" then -- 112
				clipName = "pickup_ammo" -- 113
				glowCol = PALETTE.cyan -- 114
			elseif kind == "shield" then -- 115
				clipName = "pickup_shield" -- 116
				glowCol = PALETTE.cyan -- 117
			elseif kind == "pass" then -- 118
				clipName = "pickup_pass" -- 119
				glowCol = PALETTE.amberCore -- 120
			elseif kind == "quickbelt" then -- 121
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
			if z.tint == 1 then -- 172
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
			elseif z.tint == 2 or z.tint == 3 then -- 187
				local slot = z.tint == 2 and "fe_ground_soft" or "fe_ground_brick" -- 188
				local prefix = z.tint == 2 and "zone_soft_" or "zone_brick_" -- 189
				if p.room.depth ~= nil then -- 190
					local tileW = math.max( -- 192
						48, -- 192
						cam:len(64) -- 192
					) -- 192
					local cols = math.max( -- 193
						1, -- 193
						math.ceil(zw / tileW) -- 193
					) -- 193
					local segW = zw / cols -- 194
					local bandH = cam:len(15) -- 195
					local tint = z.tint == 2 and Color(148, 138, 124, 255) or Color(124, 134, 150, 255) -- 196
					local op = z.tint == 2 and 0.46 or 0.36 -- 197
					do -- 197
						local c = 0 -- 198
						while c < cols do -- 198
							groundArt:tryPlace( -- 199
								slot, -- 199
								((prefix .. tostring(i)) .. "_") .. tostring(c), -- 199
								x0 + (c + 0.5) * segW, -- 199
								y0 - cam:len(5), -- 199
								segW + 0.6, -- 199
								bandH, -- 199
								{layer = 6, opacity = op, color = tint} -- 199
							) -- 199
							c = c + 1 -- 198
						end -- 198
					end -- 198
				elseif not groundArt:tryPlace( -- 205
					slot, -- 205
					prefix .. tostring(i), -- 205
					(x0 + x1) * 0.5, -- 205
					y0 - cam:len(4), -- 205
					zw, -- 205
					cam:len(14), -- 205
					{layer = 6} -- 205
				) then -- 205
					fgDraw:drawRect( -- 206
						Rect(x0, y0 - 4, zw, z.tint == 2 and 8 or 9), -- 207
						z.tint == 2 and Color(74, 58, 44, 220) or Color(118, 122, 130, 235) -- 208
					) -- 208
				end -- 208
			end -- 208
			i = i + 1 -- 165
		end -- 165
	end -- 165
end -- 158
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 215
	for ____, m in ipairs(p.room.marks) do -- 223
		do -- 223
			if m.kind ~= 6 then -- 224
				goto __continue34 -- 225
			end -- 225
			local mx = cam:sx(m.x) -- 227
			local my = cam:sy(m.y) -- 228
			local hookY = my + cam:len(52) -- 229
			local armX = mx + cam:len(13) -- 230
			local lampY = hookY - cam:len(12) -- 231
			local wood = Color(82, 58, 40, 245) -- 232
			local joint = math.max( -- 233
				1, -- 233
				cam:len(2) -- 233
			) -- 233
			fgDraw:drawSegment( -- 234
				Vec2(mx, my), -- 234
				Vec2(mx, hookY), -- 234
				joint, -- 234
				wood -- 234
			) -- 234
			fgDraw:drawSegment( -- 235
				Vec2(mx, hookY), -- 235
				Vec2(armX, hookY), -- 235
				joint, -- 235
				wood -- 235
			) -- 235
			fgDraw:drawSegment( -- 236
				Vec2( -- 236
					mx, -- 236
					hookY - cam:len(7) -- 236
				), -- 236
				Vec2(armX - joint, hookY), -- 236
				joint * 0.7, -- 236
				wood -- 236
			) -- 236
			if not assets:tryPlace( -- 237
				"prop_lantern", -- 237
				"path_lamp_" .. tostring(m.x), -- 237
				armX, -- 237
				lampY, -- 237
				cam:len(16), -- 237
				cam:len(20), -- 237
				{layer = 1} -- 237
			) then -- 237
				fgDraw:drawRect( -- 238
					Rect( -- 238
						armX - cam:len(4), -- 238
						lampY - cam:len(7), -- 238
						cam:len(8), -- 238
						cam:len(14) -- 238
					), -- 238
					Color(192, 136, 64, 240), -- 239
					1.4, -- 239
					wood -- 239
				) -- 239
			end -- 239
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 241
			fillRadialGlow( -- 242
				fgGlow, -- 242
				armX, -- 242
				lampY, -- 242
				cam:len(23), -- 242
				cam:len(27), -- 242
				Color(239, 182, 106, 46 * flame), -- 242
				Color(231, 164, 91, 0), -- 243
				16 -- 243
			) -- 243
		end -- 243
		::__continue34:: -- 243
	end -- 243
end -- 215
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 247
	local c = p.room.cart -- 256
	if c.bodyW <= 0 then -- 257
		return -- 258
	end -- 258
	local depth = c.depth or 0 -- 260
	local raised = p.room.depth ~= nil -- 261
	local lo = math.min(c.startX, c.endX) -- 264
	local hi = math.max(c.startX, c.endX) -- 265
	if hi - lo > 4 then -- 266
		local rx0 = cam:sx(lo) -- 267
		local rx1 = cam:sx(hi) -- 268
		local ry = cam:sy(c.baseY, depth) -- 269
		fgDraw:drawSegment( -- 270
			Vec2(rx0, ry + 1), -- 270
			Vec2(rx1, ry + 1), -- 270
			1.2, -- 270
			Color(86, 65, 47, 150) -- 270
		) -- 270
		local dockX = cam:sx(c.endX) -- 271
		local width = cam:len(24) -- 272
		local lip = cam:len(3) -- 273
		fgDraw:drawRect( -- 274
			Rect(dockX - width * 0.5, ry, width, lip), -- 274
			Color(51, 37, 26, 230) -- 274
		) -- 274
		fgDraw:drawRect( -- 275
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 275
			Color(107, 77, 51, 230) -- 275
		) -- 275
	end -- 275
	local axleX = p.cartAxle -- 278
	local cx = cam:sx(axleX) -- 279
	local baseY = cam:sy(c.baseY, depth) -- 280
	local bw = cam:len(c.bodyW) -- 281
	local bh = cam:len(c.bodyH) -- 282
	local wr = cam:len(c.wheelR) -- 283
	local x0 = cx - bw * 0.5 -- 285
	local x1 = cx + bw * 0.5 -- 286
	local bodyY0 = baseY + wr * 1.05 -- 287
	local bodyY1 = bodyY0 + bh -- 288
	local artWidth = c.bodyW * 1.36 -- 291
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 292
	local dScale = cam:depthScale(depth, raised) -- 293
	local opacity = raised and occlusion:update("cart", { -- 294
		x0 = axleX - artWidth * 0.5, -- 295
		x1 = axleX + artWidth * 0.5, -- 295
		y0 = c.baseY, -- 296
		y1 = c.baseY + artHeight, -- 296
		depth = {min = depth, max = depth + 8}, -- 297
		passThrough = true -- 297
	}, p, fadeDt) or 1 -- 298
	local cartLayer = raised and depthOrder(depth, 2) or 2 -- 299
	assets:tryPlace( -- 300
		"dp_shadow_contact", -- 300
		"cart_shadow", -- 300
		cx, -- 300
		baseY + 1, -- 300
		bw * 1.48 * dScale, -- 300
		cam:len(11) * dScale, -- 300
		{layer = cartLayer - 1, opacity = 0.85 * opacity} -- 300
	) -- 300
	local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 305
	local moved = math.abs(axleX - c.startX) > 0.25 -- 306
	local rollJitter = moved and math.abs(math.sin(wheelSpin * 2)) * cam:len(0.85) * dScale or 0 -- 307
	local painted = assets:tryPlace( -- 308
		"prop_cart", -- 308
		"cart", -- 308
		cx, -- 308
		baseY + rollJitter, -- 308
		cam:len(artWidth) * dScale, -- 308
		cam:len(artHeight) * dScale, -- 308
		{ -- 308
			layer = cartLayer, -- 309
			opacity = opacity, -- 309
			color = occlusionTint(opacity) -- 309
		} -- 309
	) -- 309
	if not painted then -- 311
		fillVGradRect( -- 313
			fgDraw, -- 313
			x0, -- 313
			bodyY0, -- 313
			bw, -- 313
			bh, -- 313
			Color(48, 32, 28, 255), -- 313
			toColor(PALETTE.cartWood) -- 313
		) -- 313
		fgDraw:drawRect( -- 314
			Rect(x0, bodyY0, bw, bh), -- 314
			Color(0, 0, 0, 0), -- 314
			1.6, -- 314
			toColor(PALETTE.cartMetal, 220) -- 314
		) -- 314
		fgDraw:drawSegment( -- 316
			Vec2(x0 + bw * 0.33, bodyY0), -- 316
			Vec2(x0 + bw * 0.33, bodyY1), -- 316
			1.4, -- 316
			toColor(PALETTE.cartMetal, 180) -- 316
		) -- 316
		fgDraw:drawSegment( -- 317
			Vec2(x0 + bw * 0.67, bodyY0), -- 317
			Vec2(x0 + bw * 0.67, bodyY1), -- 317
			1.4, -- 317
			toColor(PALETTE.cartMetal, 180) -- 317
		) -- 317
		fgDraw:drawSegment( -- 318
			Vec2(x0 - 2, bodyY1), -- 318
			Vec2(x1 + 2, bodyY1), -- 318
			2.2, -- 318
			toColor(PALETTE.rimSilver, 220) -- 318
		) -- 318
		local wxA = x0 + bw * 0.24 -- 321
		local wxB = x1 - bw * 0.24 -- 322
		local wy = baseY + wr -- 323
		self:drawWheel( -- 324
			fgDraw, -- 324
			wxA, -- 324
			wy, -- 324
			wr, -- 324
			wheelSpin -- 324
		) -- 324
		self:drawWheel( -- 325
			fgDraw, -- 325
			wxB, -- 325
			wy, -- 325
			wr, -- 325
			wheelSpin -- 325
		) -- 325
	end -- 325
	local hx = cam:sx(axleX + c.handleOffset) -- 329
	local hTop = bodyY1 + cam:len(7) -- 330
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 331
	local handleSpan = math.abs(hx - edge) -- 334
	if not painted or handleSpan > cam:len(4) then -- 335
		fgDraw:drawSegment( -- 336
			Vec2(edge, bodyY0 + bh * 0.52), -- 336
			Vec2( -- 336
				hx, -- 336
				hTop - cam:len(4) -- 336
			), -- 336
			math.max( -- 337
				1.8, -- 337
				cam:len(2.4) -- 337
			), -- 337
			toColor(PALETTE.cartWood, 245 * opacity) -- 337
		) -- 337
		fgDraw:drawSegment( -- 338
			Vec2( -- 338
				hx, -- 338
				hTop - cam:len(5.5) -- 338
			), -- 338
			Vec2(hx, hTop), -- 338
			math.max( -- 339
				2.2, -- 339
				cam:len(3.2) -- 339
			), -- 339
			Color(126, 91, 61, 245 * opacity) -- 339
		) -- 339
	end -- 339
	if painted then -- 342
		return -- 343
	end -- 343
end -- 247
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 347
	draw:drawCircle( -- 348
		Vec2(cx, cy), -- 348
		r, -- 348
		Color(24, 28, 36, 255) -- 348
	) -- 348
	draw:drawRing( -- 349
		Vec2(cx, cy), -- 349
		r * 0.72, -- 349
		r, -- 349
		Color(0, 0, 0, 0), -- 349
		1.6, -- 349
		toColor(PALETTE.cartMetal) -- 349
	) -- 349
	local k = 0 -- 350
	do -- 350
		k = 0 -- 351
		while k < 4 do -- 351
			local a = spin + k * math.pi / 4 -- 352
			draw:drawSegment( -- 353
				Vec2( -- 354
					cx - math.cos(a) * r * 0.72, -- 354
					cy - math.sin(a) * r * 0.72 -- 354
				), -- 354
				Vec2( -- 355
					cx + math.cos(a) * r * 0.72, -- 355
					cy + math.sin(a) * r * 0.72 -- 355
				), -- 355
				1.2, -- 356
				toColor(PALETTE.steelLight, 190) -- 357
			) -- 357
			k = k + 1 -- 351
		end -- 351
	end -- 351
	draw:drawDot( -- 360
		Vec2(cx, cy), -- 360
		math.max(2.2, r * 0.18), -- 360
		toColor(PALETTE.rimSilver) -- 360
	) -- 360
end -- 347
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 363
	local bottle = p.room.bottle -- 372
	if bottle ~= nil then -- 373
		local bx0 = cam:sx(bottle.x - 16) -- 374
		local bx1 = cam:sx(bottle.x + 16) -- 375
		local by0 = cam:sy(0) -- 376
		local by1 = cam:sy(52) -- 377
		if not assets:tryPlacePath( -- 378
			"assets/art/props_ming.clip|bottle_rack", -- 378
			"village_bottle_rack", -- 378
			cam:sx(bottle.x), -- 378
			by0, -- 378
			cam:len(44), -- 378
			by1 - by0, -- 378
			{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = 2} -- 378
		) then -- 378
			local beam = cam:len(3.2) -- 384
			local side = Color(78, 57, 41, 255) -- 385
			fgDraw:drawRect( -- 386
				Rect(bx0, by0, beam, by1 - by0), -- 386
				side -- 386
			) -- 386
			fgDraw:drawRect( -- 387
				Rect(bx1 - beam, by0, beam, by1 - by0), -- 387
				side -- 387
			) -- 387
			for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 388
				fgDraw:drawRect( -- 389
					Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 389
					Color(106, 78, 56, 255), -- 390
					1, -- 390
					Color(56, 42, 34, 240) -- 390
				) -- 390
			end -- 390
		end -- 390
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 393
			self:drawBottleSprite( -- 394
				fgDraw, -- 394
				assets, -- 394
				"bottle_shelf", -- 394
				cam:sx(bottle.x), -- 394
				cam:sy(56), -- 394
				cam.ppu, -- 394
				0 -- 394
			) -- 394
		end -- 394
	end -- 394
	local arch = p.room.arch -- 398
	local tx0 = cam:sx(arch.x0 - 4) -- 399
	local tx1 = cam:sx(arch.x1 + 4) -- 400
	local ty0 = cam:sy(arch.y) -- 401
	local tyBot = cam:sy(arch.y + arch.h) -- 402
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 403
	fillVGradRect( -- 404
		fgDraw, -- 404
		tx0 + 6, -- 404
		ty0, -- 404
		tx1 - tx0 - 12, -- 404
		tyBot - ty0, -- 404
		Color(9, 10, 15, 165), -- 405
		Color(9, 10, 15, 100) -- 405
	) -- 405
	if not assets:tryPlace( -- 406
		"prop_table", -- 406
		"village_table", -- 406
		(tx0 + tx1) * 0.5, -- 406
		ty0, -- 406
		tx1 - tx0, -- 407
		tyTop - ty0, -- 407
		{layer = 6} -- 407
	) then -- 407
		fgDraw:drawRect( -- 408
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 408
			toColor(PALETTE.cartWood) -- 408
		) -- 408
		fgDraw:drawRect( -- 409
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 409
			toColor(PALETTE.cartWood) -- 409
		) -- 409
		fgDraw:drawRect( -- 410
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 410
			toColor(PALETTE.cartWood) -- 410
		) -- 410
	end -- 410
	if p.hasBottle and p.aimHold <= 0 then -- 414
		local pl = p.player -- 415
		self:drawBottleSprite( -- 416
			fgDraw, -- 416
			assets, -- 416
			"bottle_held", -- 416
			cam:sx(pl.x + pl.facing * 10), -- 416
			cam:sy(pl.y + pl.h * 0.52), -- 416
			cam.ppu, -- 416
			pl.facing * 0.2 -- 416
		) -- 416
	end -- 416
	if p.bottleFly ~= nil then -- 418
		self:drawBottleSprite( -- 419
			fgDraw, -- 419
			assets, -- 419
			"bottle_air", -- 419
			cam:sx(p.bottleFly.x), -- 419
			cam:sy(p.bottleFly.y), -- 419
			cam.ppu, -- 419
			time * 14 -- 419
		) -- 419
	end -- 419
	if p.hasBottle and p.aimHold > 0 then -- 423
		local pl = p.player -- 424
		local endX = p.bottleAimX -- 425
		local endY = p.bottleAimY -- 426
		if endX < 0 then -- 427
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 428
			endX = wAim.x -- 429
			endY = 0 -- 430
		end -- 430
		local dir = endX >= pl.x and 1 or -1 -- 432
		local x0 = pl.x + dir * 10 -- 433
		local y0 = pl.y + pl.h * 0.7 -- 434
		local T = 0.62 -- 435
		local vx = (endX - x0) / T -- 436
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 437
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 439
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 440
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 441
		local activeAim = p.aimHold > 0.01 -- 442
		local steps = 18 -- 444
		local k = 1 -- 445
		do -- 445
			k = 1 -- 446
			while k <= steps do -- 446
				local tt = k / steps * T -- 447
				local wx = x0 + vx * tt -- 448
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 449
				local sx = cam:sx(wx) -- 450
				local sy = cam:sy(wy) -- 451
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 452
				fgGlow:drawDot( -- 453
					Vec2(sx, sy), -- 453
					activeAim and 3.2 or 2.2, -- 453
					toColor(arcCol, alpha) -- 453
				) -- 453
				k = k + 1 -- 446
			end -- 446
		end -- 446
		local lx = cam:sx(endX) -- 456
		local ly = cam:sy(endY + 2) -- 457
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 458
		fgGlow:drawRing( -- 459
			Vec2(lx, ly), -- 459
			8, -- 459
			11, -- 459
			Color(0, 0, 0, 0), -- 459
			1.6, -- 459
			toColor(arcCol, activeAim and 245 or 165) -- 459
		) -- 459
		if isBrick then -- 460
			fgGlow:drawRing( -- 461
				Vec2(lx, ly), -- 461
				28 * pulse, -- 461
				30 * pulse, -- 461
				Color(0, 0, 0, 0), -- 461
				1.2, -- 461
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 461
			) -- 461
			fillRadialGlow( -- 462
				fgGlow, -- 462
				lx, -- 462
				ly, -- 462
				36, -- 462
				14, -- 462
				Color(242, 188, 96, activeAim and 95 or 48), -- 462
				Color(242, 188, 96, 0), -- 462
				14 -- 462
			) -- 462
		end -- 462
	end -- 462
end -- 363
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 467
	local height = math.max(10, ppu * 10.5) -- 474
	if not assets:tryPlace( -- 475
		"prop_bottle", -- 475
		id, -- 475
		cx, -- 475
		cy, -- 475
		height, -- 475
		height, -- 475
		{angle = tilt * 180 / math.pi, layer = 6} -- 475
	) then -- 475
		local dx = math.sin(tilt) * height * 0.4 -- 478
		local dy = math.cos(tilt) * height * 0.5 -- 479
		fgDraw:drawSegment( -- 480
			Vec2(cx - dx, cy - dy), -- 480
			Vec2(cx + dx, cy + dy), -- 480
			height * 0.32, -- 480
			toColor(PALETTE.amber, 225) -- 481
		) -- 481
	end -- 481
end -- 467
return ____exports -- 467
