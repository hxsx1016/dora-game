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
	local wheelSpin = -(axleX - c.startX) / math.max(1, c.wheelR) -- 261
	local moved = math.abs(axleX - c.startX) > 0.25 -- 262
	local rollJitter = moved and math.abs(math.sin(wheelSpin * 2)) * cam:len(0.85) or 0 -- 263
	local painted = assets:tryPlace( -- 264
		"prop_cart", -- 264
		"cart", -- 264
		cx, -- 264
		baseY + rollJitter, -- 264
		cam:len(artWidth), -- 264
		cam:len(artHeight), -- 264
		{ -- 264
			layer = raised and depthOrder(depth, 2) or 2, -- 265
			opacity = opacity, -- 265
			color = occlusionTint(opacity) -- 265
		} -- 265
	) -- 265
	if not painted then -- 265
		fillVGradRect( -- 269
			fgDraw, -- 269
			x0, -- 269
			bodyY0, -- 269
			bw, -- 269
			bh, -- 269
			Color(48, 32, 28, 255), -- 269
			toColor(PALETTE.cartWood) -- 269
		) -- 269
		fgDraw:drawRect( -- 270
			Rect(x0, bodyY0, bw, bh), -- 270
			Color(0, 0, 0, 0), -- 270
			1.6, -- 270
			toColor(PALETTE.cartMetal, 220) -- 270
		) -- 270
		fgDraw:drawSegment( -- 272
			Vec2(x0 + bw * 0.33, bodyY0), -- 272
			Vec2(x0 + bw * 0.33, bodyY1), -- 272
			1.4, -- 272
			toColor(PALETTE.cartMetal, 180) -- 272
		) -- 272
		fgDraw:drawSegment( -- 273
			Vec2(x0 + bw * 0.67, bodyY0), -- 273
			Vec2(x0 + bw * 0.67, bodyY1), -- 273
			1.4, -- 273
			toColor(PALETTE.cartMetal, 180) -- 273
		) -- 273
		fgDraw:drawSegment( -- 274
			Vec2(x0 - 2, bodyY1), -- 274
			Vec2(x1 + 2, bodyY1), -- 274
			2.2, -- 274
			toColor(PALETTE.rimSilver, 220) -- 274
		) -- 274
		local wxA = x0 + bw * 0.24 -- 277
		local wxB = x1 - bw * 0.24 -- 278
		local wy = baseY + wr -- 279
		self:drawWheel( -- 280
			fgDraw, -- 280
			wxA, -- 280
			wy, -- 280
			wr, -- 280
			wheelSpin -- 280
		) -- 280
		self:drawWheel( -- 281
			fgDraw, -- 281
			wxB, -- 281
			wy, -- 281
			wr, -- 281
			wheelSpin -- 281
		) -- 281
	end -- 281
	local hx = cam:sx(axleX + c.handleOffset) -- 285
	local hTop = bodyY1 + cam:len(7) -- 286
	local edge = painted and (c.handleOffset < 0 and cx - cam:len(artWidth * 0.42) or cx + cam:len(artWidth * 0.42)) or (c.handleOffset < 0 and x0 or x1) -- 287
	local handleSpan = math.abs(hx - edge) -- 290
	if not painted or handleSpan > cam:len(4) then -- 290
		fgDraw:drawSegment( -- 292
			Vec2(edge, bodyY0 + bh * 0.52), -- 292
			Vec2( -- 292
				hx, -- 292
				hTop - cam:len(4) -- 292
			), -- 292
			math.max( -- 293
				1.8, -- 293
				cam:len(2.4) -- 293
			), -- 293
			toColor(PALETTE.cartWood, 245 * opacity) -- 293
		) -- 293
		fgDraw:drawSegment( -- 294
			Vec2( -- 294
				hx, -- 294
				hTop - cam:len(5.5) -- 294
			), -- 294
			Vec2(hx, hTop), -- 294
			math.max( -- 295
				2.2, -- 295
				cam:len(3.2) -- 295
			), -- 295
			Color(126, 91, 61, 245 * opacity) -- 295
		) -- 295
	end -- 295
	if painted then -- 295
		return -- 299
	end -- 299
end -- 208
function PropsRenderer.prototype.drawWheel(self, draw, cx, cy, r, spin) -- 303
	draw:drawCircle( -- 304
		Vec2(cx, cy), -- 304
		r, -- 304
		Color(24, 28, 36, 255) -- 304
	) -- 304
	draw:drawRing( -- 305
		Vec2(cx, cy), -- 305
		r * 0.72, -- 305
		r, -- 305
		Color(0, 0, 0, 0), -- 305
		1.6, -- 305
		toColor(PALETTE.cartMetal) -- 305
	) -- 305
	local k = 0 -- 306
	do -- 306
		k = 0 -- 307
		while k < 4 do -- 307
			local a = spin + k * math.pi / 4 -- 308
			draw:drawSegment( -- 309
				Vec2( -- 310
					cx - math.cos(a) * r * 0.72, -- 310
					cy - math.sin(a) * r * 0.72 -- 310
				), -- 310
				Vec2( -- 311
					cx + math.cos(a) * r * 0.72, -- 311
					cy + math.sin(a) * r * 0.72 -- 311
				), -- 311
				1.2, -- 312
				toColor(PALETTE.steelLight, 190) -- 313
			) -- 313
			k = k + 1 -- 307
		end -- 307
	end -- 307
	draw:drawDot( -- 316
		Vec2(cx, cy), -- 316
		math.max(2.2, r * 0.18), -- 316
		toColor(PALETTE.rimSilver) -- 316
	) -- 316
end -- 303
function PropsRenderer.prototype.drawVillageProps(self, fgDraw, fgGlow, assets, p, cam, time) -- 319
	local bottle = p.room.bottle -- 328
	if bottle ~= nil then -- 328
		local bx0 = cam:sx(bottle.x - 16) -- 330
		local bx1 = cam:sx(bottle.x + 16) -- 331
		local by0 = cam:sy(0) -- 332
		local by1 = cam:sy(52) -- 333
		if not assets:tryPlacePath( -- 333
			"assets/art/props_ming.clip|bottle_rack", -- 334
			"village_bottle_rack", -- 334
			cam:sx(bottle.x), -- 334
			by0, -- 334
			cam:len(44), -- 334
			by1 - by0, -- 334
			{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = 2} -- 334
		) then -- 334
			local beam = cam:len(3.2) -- 340
			local side = Color(78, 57, 41, 255) -- 341
			fgDraw:drawRect( -- 342
				Rect(bx0, by0, beam, by1 - by0), -- 342
				side -- 342
			) -- 342
			fgDraw:drawRect( -- 343
				Rect(bx1 - beam, by0, beam, by1 - by0), -- 343
				side -- 343
			) -- 343
			for ____, shelfY in ipairs({by0 + (by1 - by0) * 0.46, by1 - beam}) do -- 344
				fgDraw:drawRect( -- 345
					Rect(bx0 - beam * 0.25, shelfY, bx1 - bx0 + beam * 0.5, beam), -- 345
					Color(106, 78, 56, 255), -- 346
					1, -- 346
					Color(56, 42, 34, 240) -- 346
				) -- 346
			end -- 346
		end -- 346
		if not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 346
			self:drawBottleSprite( -- 350
				fgDraw, -- 350
				assets, -- 350
				"bottle_shelf", -- 350
				cam:sx(bottle.x), -- 350
				cam:sy(56), -- 350
				cam.ppu, -- 350
				0 -- 350
			) -- 350
		end -- 350
	end -- 350
	local arch = p.room.arch -- 354
	local tx0 = cam:sx(arch.x0 - 4) -- 355
	local tx1 = cam:sx(arch.x1 + 4) -- 356
	local ty0 = cam:sy(arch.y) -- 357
	local tyBot = cam:sy(arch.y + arch.h) -- 358
	local tyTop = cam:sy(arch.y + arch.h + 6) -- 359
	fillVGradRect( -- 360
		fgDraw, -- 360
		tx0 + 6, -- 360
		ty0, -- 360
		tx1 - tx0 - 12, -- 360
		tyBot - ty0, -- 360
		Color(9, 10, 15, 165), -- 361
		Color(9, 10, 15, 100) -- 361
	) -- 361
	if not assets:tryPlace( -- 361
		"prop_table", -- 362
		"village_table", -- 362
		(tx0 + tx1) * 0.5, -- 362
		ty0, -- 362
		tx1 - tx0, -- 363
		tyTop - ty0, -- 363
		{layer = 6} -- 363
	) then -- 363
		fgDraw:drawRect( -- 364
			Rect(tx0, tyBot, tx1 - tx0, tyTop - tyBot), -- 364
			toColor(PALETTE.cartWood) -- 364
		) -- 364
		fgDraw:drawRect( -- 365
			Rect(tx0 + 2, ty0, 7, tyBot - ty0), -- 365
			toColor(PALETTE.cartWood) -- 365
		) -- 365
		fgDraw:drawRect( -- 366
			Rect(tx1 - 9, ty0, 7, tyBot - ty0), -- 366
			toColor(PALETTE.cartWood) -- 366
		) -- 366
	end -- 366
	if p.hasBottle and p.aimHold <= 0 then -- 366
		local pl = p.player -- 371
		self:drawBottleSprite( -- 372
			fgDraw, -- 372
			assets, -- 372
			"bottle_held", -- 372
			cam:sx(pl.x + pl.facing * 10), -- 372
			cam:sy(pl.y + pl.h * 0.52), -- 372
			cam.ppu, -- 372
			pl.facing * 0.2 -- 372
		) -- 372
	end -- 372
	if p.bottleFly ~= nil then -- 372
		self:drawBottleSprite( -- 375
			fgDraw, -- 375
			assets, -- 375
			"bottle_air", -- 375
			cam:sx(p.bottleFly.x), -- 375
			cam:sy(p.bottleFly.y), -- 375
			cam.ppu, -- 375
			time * 14 -- 375
		) -- 375
	end -- 375
	if p.hasBottle and p.aimHold > 0 then -- 375
		local pl = p.player -- 380
		local endX = p.bottleAimX -- 381
		local endY = p.bottleAimY -- 382
		if endX < 0 then -- 382
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 384
			endX = wAim.x -- 385
			endY = 0 -- 386
		end -- 386
		local dir = endX >= pl.x and 1 or -1 -- 388
		local x0 = pl.x + dir * 10 -- 389
		local y0 = pl.y + pl.h * 0.7 -- 390
		local T = 0.62 -- 391
		local vx = (endX - x0) / T -- 392
		local vy = (endY - y0 + 0.5 * GRAVITY * T * T) / T -- 393
		local isBrick = p.room.brickX ~= nil and math.abs(endX - p.room.brickX) <= 34 -- 395
		local isSoft = p.room.softX ~= nil and math.abs(endX - p.room.softX) <= 34 -- 396
		local arcCol = isBrick and PALETTE.amber or (isSoft and PALETTE.textDim or PALETTE.emerald) -- 397
		local activeAim = p.aimHold > 0.01 -- 398
		local steps = 18 -- 400
		local k = 1 -- 401
		do -- 401
			k = 1 -- 402
			while k <= steps do -- 402
				local tt = k / steps * T -- 403
				local wx = x0 + vx * tt -- 404
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 405
				local sx = cam:sx(wx) -- 406
				local sy = cam:sy(wy) -- 407
				local alpha = (activeAim and 225 or 135) * (0.45 + 0.55 * (k / steps)) -- 408
				fgGlow:drawDot( -- 409
					Vec2(sx, sy), -- 409
					activeAim and 3.2 or 2.2, -- 409
					toColor(arcCol, alpha) -- 409
				) -- 409
				k = k + 1 -- 402
			end -- 402
		end -- 402
		local lx = cam:sx(endX) -- 412
		local ly = cam:sy(endY + 2) -- 413
		local pulse = 0.85 + 0.15 * math.sin(time * 6) -- 414
		fgGlow:drawRing( -- 415
			Vec2(lx, ly), -- 415
			8, -- 415
			11, -- 415
			Color(0, 0, 0, 0), -- 415
			1.6, -- 415
			toColor(arcCol, activeAim and 245 or 165) -- 415
		) -- 415
		if isBrick then -- 415
			fgGlow:drawRing( -- 417
				Vec2(lx, ly), -- 417
				28 * pulse, -- 417
				30 * pulse, -- 417
				Color(0, 0, 0, 0), -- 417
				1.2, -- 417
				toColor(PALETTE.amber, activeAim and 175 or 95) -- 417
			) -- 417
			fillRadialGlow( -- 418
				fgGlow, -- 418
				lx, -- 418
				ly, -- 418
				36, -- 418
				14, -- 418
				Color(242, 188, 96, activeAim and 95 or 48), -- 418
				Color(242, 188, 96, 0), -- 418
				14 -- 418
			) -- 418
		end -- 418
	end -- 418
end -- 319
function PropsRenderer.prototype.drawBottleSprite(self, fgDraw, assets, id, cx, cy, ppu, tilt) -- 423
	local height = math.max(10, ppu * 10.5) -- 430
	if not assets:tryPlace( -- 430
		"prop_bottle", -- 431
		id, -- 431
		cx, -- 431
		cy, -- 431
		height, -- 431
		height, -- 431
		{angle = tilt * 180 / math.pi, layer = 6} -- 431
	) then -- 431
		local dx = math.sin(tilt) * height * 0.4 -- 434
		local dy = math.cos(tilt) * height * 0.5 -- 435
		fgDraw:drawSegment( -- 436
			Vec2(cx - dx, cy - dy), -- 436
			Vec2(cx + dx, cy + dy), -- 436
			height * 0.32, -- 436
			toColor(PALETTE.amber, 225) -- 437
		) -- 437
	end -- 437
end -- 423
return ____exports -- 423