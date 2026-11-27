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
function PropsRenderer.prototype.drawZones(self, fgDraw, assets, p, cam) -- 145
	local i = 0 -- 151
	do -- 151
		i = 0 -- 152
		while i < #p.room.zones do -- 152
			local z = p.room.zones[i + 1] -- 153
			local x0 = cam:sx(z.x0) -- 154
			local x1 = cam:sx(z.x1) -- 155
			local y0 = cam:sy(z.y) -- 156
			local zw = x1 - x0 -- 157
			if z.tint == 1 then -- 157
				local road = p.room.depth -- 160
				local front = cam:sy(z.y, road and road.min or -3) -- 161
				local back = cam:sy(z.y, road and road.max or 1) -- 162
				fgDraw:drawRect( -- 163
					Rect(x0, front, zw, back - front), -- 163
					Color(50, 35, 29, 48) -- 163
				) -- 163
			elseif z.tint == 2 then -- 163
				if not assets:tryPlace( -- 163
					"fe_ground_soft", -- 165
					"zone_soft_" .. tostring(i), -- 165
					(x0 + x1) * 0.5, -- 165
					y0 - cam:len(4), -- 165
					zw, -- 165
					cam:len(14), -- 165
					{layer = 1} -- 165
				) then -- 165
					fgDraw:drawRect( -- 166
						Rect(x0, y0 - 4, zw, 8), -- 166
						Color(74, 58, 44, 220) -- 166
					) -- 166
				end -- 166
			elseif z.tint == 3 then -- 166
				if not assets:tryPlace( -- 166
					"fe_ground_brick", -- 169
					"zone_brick_" .. tostring(i), -- 169
					(x0 + x1) * 0.5, -- 169
					y0 - cam:len(4), -- 169
					zw, -- 169
					cam:len(14), -- 169
					{layer = 1} -- 169
				) then -- 169
					fgDraw:drawRect( -- 170
						Rect(x0, y0 - 4, zw, 9), -- 170
						Color(118, 122, 130, 235) -- 170
					) -- 170
				end -- 170
			end -- 170
			i = i + 1 -- 152
		end -- 152
	end -- 152
end -- 145
function PropsRenderer.prototype.drawMarks(self, fgDraw, fgGlow, assets, p, cam, time) -- 176
	for ____, m in ipairs(p.room.marks) do -- 184
		do -- 184
			if m.kind ~= 6 then -- 184
				goto __continue31 -- 186
			end -- 186
			local mx = cam:sx(m.x) -- 188
			local my = cam:sy(m.y) -- 189
			local hookY = my + cam:len(52) -- 190
			local armX = mx + cam:len(13) -- 191
			local lampY = hookY - cam:len(12) -- 192
			local wood = Color(82, 58, 40, 245) -- 193
			local joint = math.max( -- 194
				1, -- 194
				cam:len(2) -- 194
			) -- 194
			fgDraw:drawSegment( -- 195
				Vec2(mx, my), -- 195
				Vec2(mx, hookY), -- 195
				joint, -- 195
				wood -- 195
			) -- 195
			fgDraw:drawSegment( -- 196
				Vec2(mx, hookY), -- 196
				Vec2(armX, hookY), -- 196
				joint, -- 196
				wood -- 196
			) -- 196
			fgDraw:drawSegment( -- 197
				Vec2( -- 197
					mx, -- 197
					hookY - cam:len(7) -- 197
				), -- 197
				Vec2(armX - joint, hookY), -- 197
				joint * 0.7, -- 197
				wood -- 197
			) -- 197
			if not assets:tryPlace( -- 197
				"prop_lantern", -- 198
				"path_lamp_" .. tostring(m.x), -- 198
				armX, -- 198
				lampY, -- 198
				cam:len(16), -- 198
				cam:len(20), -- 198
				{layer = 1} -- 198
			) then -- 198
				fgDraw:drawRect( -- 199
					Rect( -- 199
						armX - cam:len(4), -- 199
						lampY - cam:len(7), -- 199
						cam:len(8), -- 199
						cam:len(14) -- 199
					), -- 199
					Color(192, 136, 64, 240), -- 200
					1.4, -- 200
					wood -- 200
				) -- 200
			end -- 200
			local flame = 0.91 + math.sin(time * 3.1) * 0.09 -- 202
			fillRadialGlow( -- 203
				fgGlow, -- 203
				armX, -- 203
				lampY, -- 203
				cam:len(23), -- 203
				cam:len(27), -- 203
				Color(239, 182, 106, 46 * flame), -- 203
				Color(231, 164, 91, 0), -- 204
				16 -- 204
			) -- 204
		end -- 204
		::__continue31:: -- 204
	end -- 204
end -- 176
function PropsRenderer.prototype.drawCart(self, fgDraw, assets, p, cam, time, occlusion, fadeDt) -- 208
	local c = p.room.cart -- 217
	if c.bodyW <= 0 then -- 217
		return -- 219
	end -- 219
	local depth = c.depth or 0 -- 221
	local raised = p.room.depth ~= nil -- 222
	local lo = math.min(c.startX, c.endX) -- 225
	local hi = math.max(c.startX, c.endX) -- 226
	if hi - lo > 4 then -- 226
		local rx0 = cam:sx(lo) -- 228
		local rx1 = cam:sx(hi) -- 229
		local ry = cam:sy(c.baseY, depth) -- 230
		fgDraw:drawSegment( -- 231
			Vec2(rx0, ry + 1), -- 231
			Vec2(rx1, ry + 1), -- 231
			1.2, -- 231
			Color(86, 65, 47, 150) -- 231
		) -- 231
		local dockX = cam:sx(c.endX) -- 232
		local width = cam:len(24) -- 233
		local lip = cam:len(3) -- 234
		fgDraw:drawRect( -- 235
			Rect(dockX - width * 0.5, ry, width, lip), -- 235
			Color(51, 37, 26, 230) -- 235
		) -- 235
		fgDraw:drawRect( -- 236
			Rect(dockX + width * 0.5 - lip, ry, lip, lip * 2), -- 236
			Color(107, 77, 51, 230) -- 236
		) -- 236
	end -- 236
	local axleX = p.cartAxle -- 239
	local cx = cam:sx(axleX) -- 240
	local baseY = cam:sy(c.baseY, depth) -- 241
	local bw = cam:len(c.bodyW) -- 242
	local bh = cam:len(c.bodyH) -- 243
	local wr = cam:len(c.wheelR) -- 244
	local x0 = cx - bw * 0.5 -- 246
	local x1 = cx + bw * 0.5 -- 247
	local bodyY0 = baseY + wr * 1.05 -- 248
	local bodyY1 = bodyY0 + bh -- 249
	local artWidth = c.bodyW * 1.36 -- 252
	local artHeight = (c.wheelR * 2 + c.bodyH) * 0.88 -- 253
	local opacity = raised and occlusion:update("cart", { -- 254
		x0 = axleX - artWidth * 0.5, -- 255
		x1 = axleX + artWidth * 0.5, -- 255
		y0 = c.baseY, -- 256
		y1 = c.baseY + artHeight, -- 256
		depth = {min = depth, max = depth + 8}, -- 257
		passThrough = true -- 257
	}, p, fadeDt) or 1 -- 257
	fgDraw:drawEllipse( -- 259
		Vec2(cx, baseY + 2), -- 259
		bw * 0.62, -- 259
		5, -- 259
		Color(4, 6, 10, 150 * opacity) -- 259
	) -- 259
	local painted = assets:tryPlace( -- 261
		"prop_cart", -- 261
		"cart", -- 261
		cx, -- 261
		baseY, -- 261
		cam:len(artWidth), -- 261
		cam:len(artHeight), -- 261
		{ -- 261
			layer = raised and depthOrder(depth, 2) or 2, -- 262
			opacity = opacity, -- 262
			color = occlusionTint(opacity) -- 262
		} -- 262
	) -- 262
	if not painted then -- 262
		fillVGradRect( -- 266
			fgDraw, -- 266
			x0, -- 266
			bodyY0, -- 266
			bw, -- 266
			bh, -- 266
			Color(48, 32, 28, 255), -- 266
			toColor(PALETTE.cartWood) -- 266
		) -- 266
		fgDraw:drawRect( -- 267
			Rect(x0, bodyY0, bw, bh), -- 267
			Color(0, 0, 0, 0), -- 267
			1.6, -- 267
			toColor(PALETTE.cartMetal, 220) -- 267
		) -- 267
		fgDraw:drawSegment( -- 269
			Vec2(x0 + bw * 0.33, bodyY0), -- 269
			Vec2(x0 + bw * 0.33, bodyY1), -- 269
			1.4, -- 269
			toColor(PALETTE.cartMetal, 180) -- 269
		) -- 269
		fgDraw:drawSegment( -- 270
			Vec2(x0 + bw * 0.67, bodyY0), -- 270
			Vec2(x0 + bw * 0.67, bodyY1), -- 270
			1.4, -- 270
			toColor(PALETTE.cartMetal, 180) -- 270
		) -- 270
		fgDraw:drawSegment( -- 271
			Vec2(x0 - 2, bodyY1), -- 271
			Vec2(x1 + 2, bodyY1), -- 271
			2.2, -- 271
			toColor(PALETTE.rimSilver, 220) -- 271
		) -- 271
		local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 274
		local wxA = x0 + bw * 0.24 -- 275
		local wxB = x1 - bw * 0.24 -- 276
		local wy = baseY + wr -- 277
		self:drawWheel( -- 278
			fgDraw, -- 278
			wxA, -- 278
			wy, -- 278
			wr, -- 278
			wheelSpin -- 278
		) -- 278
		self:drawWheel( -- 279
			fgDraw, -- 279
			wxB, -- 279
			wy, -- 279
			wr, -- 279
			wheelSpin -- 279
		) -- 279
	end -- 279
	local hx = cam:sx(axleX + c.handleOffset) -- 283
	local hTop = bodyY1 + cam:len(7) -- 284
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 285
	local handleSpan = math.abs(hx - edge) -- 288
	if not painted or handleSpan > cam:len(4) then -- 288
		fgDraw:drawSegment( -- 290
			Vec2(edge, bodyY0 + bh * 0.52), -- 290
			Vec2( -- 290
				hx, -- 290
				hTop - cam:len(4) -- 290
			), -- 290
			math.max( -- 291
				1.8, -- 291
				cam:len(2.4) -- 291
			), -- 291
			toColor(PALETTE.cartWood, 245 * opacity) -- 291
		) -- 291
		fgDraw:drawSegment( -- 292
			Vec2( -- 292
				hx, -- 292
				hTop - cam:len(5.5) -- 292
			), -- 292
			Vec2(hx, hTop), -- 292
			math.max( -- 293
				2.2, -- 293
				cam:len(3.2) -- 293
			), -- 293
			Color(126, 91, 61, 245 * opacity) -- 293
		) -- 293
	end -- 293
	if painted then -- 293
		return -- 297
	end -- 297
end -- 208
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 301
	draw:drawCircle( -- 302
		Vec2(cx, cy), -- 302
		r, -- 302
		Color(24, 28, 36, 255) -- 302
	) -- 302
	draw:drawRing( -- 303
		Vec2(cx, cy), -- 303
		r * 0.72, -- 303
		r, -- 303
		Color(0, 0, 0, 0), -- 303
		1.6, -- 303
		toColor(PALETTE.cartMetal) -- 303
	) -- 303
	local k = 0 -- 304
	do -- 304
		k = 0 -- 305
		while k < 4 do -- 305
			local a = spin + k * math.pi / 4 -- 306
			draw:drawSegment( -- 307
				Vec2( -- 308
					cx - math.cos(a) * r * 0.72, -- 308
					cy - math.sin(a) * r * 0.72 -- 308
				), -- 308
				Vec2( -- 309
					cx + math.cos(a) * r * 0.72, -- 309
					cy + math.sin(a) * r * 0.72 -- 309
				), -- 309
				1.2, -- 310
				toColor(PALETTE.steelLight, 190) -- 311
			) -- 311
			k = k + 1 -- 305
		end -- 305
	end -- 305
	draw:drawDot( -- 314
		Vec2(cx, cy), -- 314
		math.max(2.2, r * 0.18), -- 314
		toColor(PALETTE.rimSilver) -- 314
	) -- 314
end -- 301
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 317
	local bottle = p.room.bottle -- 326
	if bottle ~= nil then -- 326
		local bx0 = cam:sx(bottle.x - 16) -- 328
		local bx1 = cam:sx(bottle.x + 16) -- 329
		local by0 = cam:sy(0) -- 330
		local by1 = cam:sy(52) -- 331
		if not assets:tryPlacePath( -- 331
			"assets/art/props_ming.clip|bottle_rack", -- 332
			"village_bottle_rack", -- 332
			cam:sx(bottle.x), -- 332
			by0, -- 332
			cam:len(44), -- 332
			by1 - by0, -- 332
			{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = 2} -- 332
		) then -- 332
			local beam = cam:len(3.2) -- 338
			local side = Color(78, 57, 41, 255) -- 339
			fgDraw:drawRect( -- 340
				Rect(bx0, by0, beam, by1 - by0), -- 340
				side -- 340
			) -- 340
			fgDraw:drawRect( -- 341
				Rect(bx1 - beam, by0, beam, by1 - by0), -- 341
				side -- 341
			) -- 341
			for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 342
				fgDraw:drawRect( -- 343
					Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 343
					Color(106, 78, 56, 255), -- 344
					1, -- 344
					Color(56, 42, 34, 240) -- 344
				) -- 344
			end -- 344
		end -- 344
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 344
			self:drawBottleSprite( -- 348
				fgDraw, -- 348
				assets, -- 348
				"bottle_shelf", -- 348
				cam:sx(bottle.x), -- 348
				cam:sy(56), -- 348
				cam.ppu, -- 348
				0 -- 348
			) -- 348
		end -- 348
	end -- 348
	local arch = p.room.arch -- 352
	local tx0 = cam:sx(arch.x0 - 4) -- 353
	local tx1 = cam:sx(arch.x1 + 4) -- 354
	local ty0 = cam:sy(arch.y) -- 355
	local tyBot = cam:sy(arch.y + arch.h) -- 356
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 357
	fillVGradRect( -- 358
		fgDraw, -- 358
		tx0 + 6, -- 358
		ty0, -- 358
		tx1 - tx0 - 12, -- 358
		tyBot - ty0, -- 358
		Color(9, 10, 15, 165), -- 359
		Color(9, 10, 15, 100) -- 359
	) -- 359
	if not assets:tryPlace( -- 359
		"prop_table", -- 360
		"village_table", -- 360
		(tx0 + tx1) * 0.5, -- 360
		ty0, -- 360
		tx1 - tx0, -- 361
		tyTop - ty0, -- 361
		{layer = 6} -- 361
	) then -- 361
		fgDraw:drawRect( -- 362
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 362
			toColor(PALETTE.cartWood) -- 362
		) -- 362
		fgDraw:drawRect( -- 363
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 363
			toColor(PALETTE.cartWood) -- 363
		) -- 363
		fgDraw:drawRect( -- 364
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 364
			toColor(PALETTE.cartWood) -- 364
		) -- 364
	end -- 364
	if p.hasBottle and p.aimHold <= 0 then -- 364
		local pl = p.player -- 369
		self:drawBottleSprite( -- 370
			fgDraw, -- 370
			assets, -- 370
			"bottle_held", -- 370
			cam:sx(pl.x + pl.facing * 10), -- 370
			cam:sy(pl.y + pl.h * 0.52), -- 370
			cam.ppu, -- 370
			pl.facing * 0.2 -- 370
		) -- 370
	end -- 370
	if p.bottleFly ~= nil then -- 370
		self:drawBottleSprite( -- 373
			fgDraw, -- 373
			assets, -- 373
			"bottle_air", -- 373
			cam:sx(p.bottleFly.x), -- 373
			cam:sy(p.bottleFly.y), -- 373
			cam.ppu, -- 373
			time * 14 -- 373
		) -- 373
	end -- 373
	if p.hasBottle and p.aimHold > 0 then -- 373
		local pl = p.player -- 378
		local endX = p.bottleAimX -- 379
		local endY = p.bottleAimY -- 380
		if endX < 0 then -- 380
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 382
			endX = wAim.x -- 383
			endY = 0 -- 384
		end -- 384
		local dir = endX >= pl.x and 1 or -1 -- 386
		local x0 = pl.x + dir * 10 -- 387
		local y0 = pl.y + pl.h * 0.7 -- 388
		local T = 0.62 -- 389
		local vx = (endX - x0) / T -- 390
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 391
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 393
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 394
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 395
		local activeAim = p.aimHold > 0.01 -- 396
		local steps = 18 -- 398
		local k = 1 -- 399
		do -- 399
			k = 1 -- 400
			while k <= steps do -- 400
				local tt = k / steps * T -- 401
				local wx = x0 + vx * tt -- 402
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 403
				local sx = cam:sx(wx) -- 404
				local sy = cam:sy(wy) -- 405
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 406
				fgGlow:drawDot( -- 407
					Vec2(sx, sy), -- 407
					activeAim and 3.2 or 2.2, -- 407
					toColor(arcCol, alpha) -- 407
				) -- 407
				k = k + 1 -- 400
			end -- 400
		end -- 400
		local lx = cam:sx(endX) -- 410
		local ly = cam:sy(endY + 2) -- 411
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 412
		fgGlow:drawRing( -- 413
			Vec2(lx, ly), -- 413
			8, -- 413
			11, -- 413
			Color(0, 0, 0, 0), -- 413
			1.6, -- 413
			toColor(arcCol, activeAim and 245 or 165) -- 413
		) -- 413
		if isBrick then -- 413
			fgGlow:drawRing( -- 415
				Vec2(lx, ly), -- 415
				28 * pulse, -- 415
				30 * pulse, -- 415
				Color(0, 0, 0, 0), -- 415
				1.2, -- 415
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 415
			) -- 415
			fillRadialGlow( -- 416
				fgGlow, -- 416
				lx, -- 416
				ly, -- 416
				36, -- 416
				14, -- 416
				Color(242, 188, 96, activeAim and 95 or 48), -- 416
				Color(242, 188, 96, 0), -- 416
				14 -- 416
			) -- 416
		end -- 416
	end -- 416
end -- 317
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 421
	local height = math.max(10, ppu * 10.5) -- 428
	if not assets:tryPlace( -- 428
		"prop_bottle", -- 429
		id, -- 429
		cx, -- 429
		cy, -- 429
		height, -- 429
		height, -- 429
		{angle = tilt * 180 / math.pi, layer = 6} -- 429
	) then -- 429
		local dx = math.sin(tilt) * height * 0.4 -- 432
		local dy = math.cos(tilt) * height * 0.5 -- 433
		fgDraw:drawSegment( -- 434
			Vec2(cx - dx, cy - dy), -- 434
			Vec2(cx + dx, cy + dy), -- 434
			height * 0.32, -- 434
			toColor(PALETTE.amber, 225) -- 435
		) -- 435
	end -- 435
end -- 421
return ____exports -- 421