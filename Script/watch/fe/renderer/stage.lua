-- [ts]: stage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____depth = require("Script.watch.depth") -- 5
local LANE_DEPTH = ____depth.LANE_DEPTH -- 5
local ____occlusion = require("Script.watch.fe.occlusion") -- 9
local depthOrder = ____occlusion.depthOrder -- 9
local occlusionTint = ____occlusion.occlusionTint -- 9
local ____theme = require("Script.watch.fe.theme") -- 10
local PALETTE = ____theme.PALETTE -- 11
local fillRadialGlow = ____theme.fillRadialGlow -- 15
local fillVGradRect = ____theme.fillVGradRect -- 16
local lerpRGBA = ____theme.lerpRGBA -- 17
local themeOf = ____theme.themeOf -- 18
local toColor = ____theme.toColor -- 19
--- 确定性伪随机（避免跨帧闪烁）
local function hash01(seed) -- 23
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 24
	return x - math.floor(x) -- 25
end -- 23
--- 根据房间名取一个稳定数值种子
local function roomSeed(key) -- 29
	local h = 17 -- 30
	local i = 0 -- 31
	do -- 31
		i = 0 -- 32
		while i < #key do -- 32
			h = (h * 31 + __TS__StringCharCodeAt(key, i)) % 9973 -- 33
			i = i + 1 -- 32
		end -- 32
	end -- 32
	return h -- 35
end -- 29
--- 将特定明代场景道具（空筐墙/粮袋堆/木帘/窗板/石井栏）映射至专属 props_ming.clip 手绘精灵，避免退化为通用砖木块
local function dedicatedSolidProp(solid) -- 46
	if solid.art == "basket_wall" then -- 46
		return {clip = "basket_wall", natAR = 144 / 90, heightMul = 1.08, tileable = true} -- 48
	end -- 48
	if solid.art == "curtain" then -- 48
		return {clip = "curtain", natAR = 144 / 126, heightMul = 1.06, tileable = false} -- 51
	end -- 51
	if solid.art == "board" then -- 51
		return {clip = "window_board", natAR = 88 / 144, heightMul = 1.04, tileable = false} -- 54
	end -- 54
	if solid.art == "thin_wood" then -- 54
		return {clip = "window_board", natAR = 88 / 144, heightMul = 1, tileable = true} -- 57
	end -- 57
	if solid.id == "s1_well" or solid.art == "well" or (string.find(solid.label, "井背", nil, true) or 0) - 1 >= 0 then -- 57
		return {clip = "well_curb", natAR = 144 / 120, heightMul = 1.12, tileable = false} -- 60
	end -- 60
	if solid.art == "grain_sack" or (string.find(solid.label, "粮台", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "粮袋", nil, true) or 0) - 1 >= 0 then -- 60
		return {clip = "grain_sack", natAR = 144 / 74, heightMul = 1.12, tileable = true} -- 63
	end -- 63
	return nil -- 65
end -- 46
local function coverArt(solid) -- 68
	if solid.art == "gate_post" or solid.art == "wall" then -- 68
		return "wall" -- 70
	end -- 70
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 70
		return "cover_wood" -- 73
	end -- 73
	if solid.art == "cover_stone" then -- 73
		return "cover_stone" -- 76
	end -- 76
	if solid.art == "fence" then -- 76
		return "fence" -- 79
	end -- 79
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 81
end -- 68
local GUARD_LANTERN_CLIPS = {"assets/art/actors_enemies_anim.clip|guard_lantern_0", "assets/art/actors_enemies_anim.clip|guard_lantern_1", "assets/art/actors_enemies_anim.clip|guard_lantern_2", "assets/art/actors_enemies_anim.clip|guard_lantern_3"} -- 84
local GUARD_WRITE_CLIPS = {"assets/art/actors_enemies_anim.clip|guard_write_0", "assets/art/actors_enemies_anim.clip|guard_write_1", "assets/art/actors_enemies_anim.clip|guard_write_2", "assets/art/actors_enemies_anim.clip|guard_write_3"} -- 90
local function tintByShade(base, shade) -- 97
	return Color( -- 98
		math.max( -- 99
			0, -- 99
			math.min( -- 99
				255, -- 99
				math.floor(base.r * shade + 0.5) -- 99
			) -- 99
		), -- 99
		math.max( -- 100
			0, -- 100
			math.min( -- 100
				255, -- 100
				math.floor(base.g * shade + 0.5) -- 100
			) -- 100
		), -- 100
		math.max( -- 101
			0, -- 101
			math.min( -- 101
				255, -- 101
				math.floor(base.b * shade + 0.5) -- 101
			) -- 101
		), -- 101
		base.a -- 102
	) -- 102
end -- 97
____exports.StageRenderer = __TS__Class() -- 106
local StageRenderer = ____exports.StageRenderer -- 106
StageRenderer.name = "StageRenderer" -- 106
function StageRenderer.prototype.____constructor(self) -- 106
end -- 106
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, _time) -- 108
	local w = cam.viewW -- 116
	local h = cam.viewH -- 117
	local theme = themeOf(p.room.key) -- 118
	local span = math.max(1, p.room.maxX - p.room.minX) -- 120
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 121
	local backdropKey = theme.backdropKey or p.room.key -- 122
	local farSlot = "bgFar_" .. backdropKey -- 123
	local backRoadY = cam:sy(0, p.room.depth ~= nil and p.room.depth.max or 0) -- 126
	local artW = math.max(w, h * 16 / 9) * 1.1 -- 127
	local artH = artW * 9 / 16 -- 128
	local artY = math.min( -- 129
		0, -- 129
		math.max(h - artH, backRoadY - artH * 0.25) -- 129
	) -- 129
	if assets:tryPlace( -- 129
		farSlot, -- 130
		"scene", -- 130
		w * (0.5 - progress * 0.08), -- 130
		artY, -- 130
		artW, -- 130
		artH -- 130
	) then -- 130
		self:drawDressing( -- 131
			assets, -- 131
			backdropKey, -- 131
			cam, -- 131
			progress, -- 131
			backRoadY -- 131
		) -- 131
		fillVGradRect( -- 132
			bgDraw, -- 132
			0, -- 132
			0, -- 132
			w, -- 132
			h, -- 132
			toColor(PALETTE.voidDark), -- 132
			toColor(theme.skyMid) -- 132
		) -- 132
		fillVGradRect( -- 133
			bgGlow, -- 133
			0, -- 133
			backRoadY - 2, -- 133
			w, -- 133
			h * 0.14, -- 133
			Color(43, 54, 72, 20), -- 133
			Color(43, 54, 72, 0) -- 133
		) -- 133
		return -- 134
	end -- 134
	local splitY = h * 0.46 -- 138
	fillVGradRect( -- 139
		bgDraw, -- 139
		0, -- 139
		splitY, -- 139
		w, -- 139
		h - splitY, -- 139
		toColor(theme.skyMid), -- 139
		toColor(theme.skyTop) -- 139
	) -- 139
	fillVGradRect( -- 140
		bgDraw, -- 140
		0, -- 140
		0, -- 140
		w, -- 140
		splitY, -- 140
		toColor(theme.skyHorizon), -- 140
		toColor(theme.skyMid) -- 140
	) -- 140
	if theme.showMoon then -- 140
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 142
		local my = h * theme.moonYFrac -- 143
		local mr = math.max(18, h * 0.044) -- 144
		fillRadialGlow( -- 145
			bgGlow, -- 145
			mx, -- 145
			my, -- 145
			mr * 4.6, -- 145
			mr * 4.6, -- 145
			Color(148, 178, 206, 28), -- 145
			Color(20, 32, 52, 0), -- 145
			18 -- 145
		) -- 145
		bgDraw:drawCircle( -- 146
			Vec2(mx, my), -- 146
			mr, -- 146
			Color(218, 232, 242, 215) -- 146
		) -- 146
	end -- 146
	fillVGradRect( -- 148
		bgGlow, -- 149
		0, -- 150
		backRoadY - 10, -- 151
		w, -- 152
		h * 0.3, -- 153
		toColor(theme.fogBottom), -- 154
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 155
	) -- 155
end -- 108
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress, backRoadY) -- 159
	local w = cam.viewW -- 166
	local x = w * (0.76 - progress * 0.24) -- 167
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 167
		assets:tryPlace( -- 171
			"pine", -- 171
			"mid_pine", -- 171
			x, -- 171
			backRoadY - cam:len(4), -- 171
			cam:len(118), -- 171
			cam:len(104), -- 171
			{layer = 1, opacity = 0.48} -- 172
		) -- 172
	elseif backdropKey == "street" then -- 172
		assets:tryPlace( -- 174
			"dp_ruin_house_a", -- 174
			"mid_ruin", -- 174
			x, -- 174
			backRoadY - cam:len(4), -- 174
			cam:len(132), -- 174
			cam:len(118), -- 174
			{layer = 1, opacity = 0.42} -- 175
		) -- 175
	end -- 175
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 175
		local lanternSway = math.sin(progress * 6 + cam.x * 0.004) * 2.5 -- 178
		assets:tryPlace( -- 179
			"prop_lantern", -- 179
			"mid_lantern", -- 179
			w * (0.27 - progress * 0.2), -- 179
			backRoadY + cam:len(86), -- 180
			cam:len(20), -- 180
			cam:len(28), -- 180
			{layer = 2, opacity = 0.86, angle = lanternSway} -- 180
		) -- 180
	end -- 180
end -- 159
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 185
	local theme = themeOf("checkpoint") -- 192
	local splitY = h * 0.44 -- 193
	fillVGradRect( -- 194
		bgDraw, -- 194
		0, -- 194
		splitY, -- 194
		w, -- 194
		h - splitY, -- 194
		toColor(theme.skyMid), -- 194
		toColor(theme.skyTop) -- 194
	) -- 194
	fillVGradRect( -- 195
		bgDraw, -- 195
		0, -- 195
		0, -- 195
		w, -- 195
		splitY, -- 195
		toColor(theme.skyHorizon), -- 195
		toColor(theme.skyMid) -- 195
	) -- 195
	local mx = w * 0.61 -- 196
	local my = h * 0.74 -- 197
	local mr = h * 0.068 -- 198
	local pulse = 0.86 + 0.14 * math.sin(time * 2) -- 199
	fillRadialGlow( -- 200
		bgGlow, -- 200
		mx, -- 200
		my, -- 200
		mr * 4.4 * pulse, -- 200
		mr * 4.4 * pulse, -- 200
		Color(156, 180, 198, 28), -- 200
		Color(16, 22, 34, 0), -- 200
		20 -- 200
	) -- 200
	bgDraw:drawCircle( -- 201
		Vec2(mx, my), -- 201
		mr, -- 201
		Color(224, 232, 236, 218) -- 201
	) -- 201
	local groundY = h * 0.19 -- 202
	fillVGradRect( -- 203
		bgDraw, -- 203
		0, -- 203
		0, -- 203
		w, -- 203
		groundY, -- 203
		Color(9, 11, 17, 255), -- 203
		Color(18, 23, 33, 255) -- 203
	) -- 203
	bgDraw:drawSegment( -- 204
		Vec2(0, groundY), -- 204
		Vec2(w, groundY), -- 204
		1.4, -- 204
		toColor(PALETTE.silkDim, 145) -- 204
	) -- 204
end -- 185
function StageRenderer.prototype.drawPlayableWorld(self, groundDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt, groundArt, roadLineDraw, overlayDraw) -- 208
	local theme = themeOf(p.room.key) -- 221
	local gArt = groundArt or assets -- 222
	local rLine = roadLineDraw or groundDraw -- 223
	local oDraw = overlayDraw or rLine -- 224
	self:drawFloors( -- 225
		groundDraw, -- 225
		rLine, -- 225
		gArt, -- 225
		p, -- 225
		cam, -- 225
		theme -- 225
	) -- 225
	self:drawStairs( -- 226
		rLine, -- 226
		fgGlow, -- 226
		assets, -- 226
		p, -- 226
		cam, -- 226
		theme -- 226
	) -- 226
	self:drawBoundaryClosures(assets, p, cam) -- 227
	self:drawSolids( -- 228
		rLine, -- 228
		oDraw, -- 228
		fgGlow, -- 228
		assets, -- 228
		p, -- 228
		cam, -- 228
		theme, -- 228
		time, -- 228
		occlusion, -- 228
		fadeDt -- 228
	) -- 228
	if p.room.key == "gate" then -- 228
		self:drawGateShutter( -- 230
			rLine, -- 230
			fgGlow, -- 230
			assets, -- 230
			p, -- 230
			cam, -- 230
			time -- 230
		) -- 230
	end -- 230
	self:drawArch(rLine, assets, p, cam) -- 232
end -- 208
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 236
	fillVGradRect( -- 243
		fgDraw, -- 243
		0, -- 243
		h - h * 0.14, -- 243
		w, -- 243
		h * 0.14, -- 243
		Color(4, 6, 12, 0), -- 243
		Color(4, 6, 12, 118) -- 243
	) -- 243
	fillVGradRect( -- 244
		fgDraw, -- 244
		0, -- 244
		0, -- 244
		w, -- 244
		h * 0.11, -- 244
		Color(4, 6, 12, 152), -- 244
		Color(4, 6, 12, 0) -- 244
	) -- 244
end -- 236
function StageRenderer.prototype.drawBoundaryClosures(self, assets, p, cam) -- 248
	local road = p.room.depth -- 249
	if road == nil then -- 249
		return -- 251
	end -- 251
	if p.room.key == "outside" or p.room.key == "village" or p.room.key == "forest" or p.room.key == "tower" or p.room.key == "museum" then -- 251
		return -- 254
	end -- 254
	local function hasWallNear(targetX) -- 256
		do -- 256
			local i = 0 -- 257
			while i < #p.room.solids do -- 257
				do -- 257
					local s = p.room.solids[i + 1] -- 258
					if s.decorative == true then -- 258
						goto __continue36 -- 259
					end -- 259
					if s.h >= 100 and (math.abs(s.x - targetX) <= 85 or math.abs(s.x + s.w - targetX) <= 85) then -- 259
						return true -- 261
					end -- 261
				end -- 261
				::__continue36:: -- 261
				i = i + 1 -- 257
			end -- 257
		end -- 257
		return false -- 264
	end -- 256
	local minX = p.room.minX -- 266
	local maxX = p.room.maxX -- 267
	local backY = cam:sy(0, road.max) -- 268
	local frontY = cam:sy(0, road.min) -- 269
	local barW = cam:len(46) -- 270
	local barH = cam:len(84) -- 271
	if not hasWallNear(minX) then -- 271
		local lx = cam:sx(minX + 6) -- 273
		if lx + barW > -20 and lx - barW < cam.viewW + 20 then -- 273
			assets:tryPlace( -- 275
				"dp_boundary_barricade", -- 275
				"bound_left_back", -- 275
				lx, -- 275
				backY - cam:len(4), -- 275
				barW * 0.92, -- 275
				barH * 0.92, -- 275
				{ -- 275
					layer = depthOrder(road.max, 0), -- 276
					opacity = 0.88 -- 276
				} -- 276
			) -- 276
			assets:tryPlace( -- 278
				"dp_boundary_barricade", -- 278
				"bound_left_front", -- 278
				lx - cam:len(6), -- 278
				frontY - cam:len(2), -- 278
				barW, -- 278
				barH * 0.72, -- 278
				{ -- 278
					layer = depthOrder(road.min, 0), -- 279
					opacity = 0.94 -- 279
				} -- 279
			) -- 279
		end -- 279
	end -- 279
	if not hasWallNear(maxX) then -- 279
		local rx = cam:sx(maxX - 6) -- 284
		if rx + barW > -20 and rx - barW < cam.viewW + 20 then -- 284
			assets:tryPlace( -- 286
				"dp_boundary_barricade", -- 286
				"bound_right_back", -- 286
				rx, -- 286
				backY - cam:len(4), -- 286
				barW * 0.92, -- 286
				barH * 0.92, -- 286
				{ -- 286
					layer = depthOrder(road.max, 0), -- 287
					opacity = 0.88, -- 287
					facing = -1 -- 287
				} -- 287
			) -- 287
			assets:tryPlace( -- 289
				"dp_boundary_barricade", -- 289
				"bound_right_front", -- 289
				rx + cam:len(6), -- 289
				frontY - cam:len(2), -- 289
				barW, -- 289
				barH * 0.72, -- 289
				{ -- 289
					layer = depthOrder(road.min, 0), -- 290
					opacity = 0.94, -- 290
					facing = -1 -- 290
				} -- 290
			) -- 290
		end -- 290
	end -- 290
end -- 248
function StageRenderer.prototype.drawFloors(self, groundDraw, roadLineDraw, groundArt, p, cam, theme) -- 296
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 304
	do -- 304
		local i = 0 -- 305
		while i < #p.room.floors do -- 305
			local floor = p.room.floors[i + 1] -- 306
			local left = cam:sx(floor.x0) -- 307
			local right = cam:sx(floor.x1) -- 308
			local isMain = floor.y <= 0.1 -- 309
			local ____isMain_0 -- 310
			if isMain then -- 310
				____isMain_0 = p.room.depth -- 310
			else -- 310
				____isMain_0 = nil -- 310
			end -- 310
			local road = ____isMain_0 -- 310
			local top = cam:sy(floor.y, road and road.min or 0) -- 311
			if road ~= nil then -- 311
				self:drawRoad( -- 313
					groundDraw, -- 313
					roadLineDraw, -- 313
					groundArt, -- 313
					i, -- 313
					left, -- 313
					right, -- 313
					top, -- 313
					cam:sy(floor.y, road.max), -- 313
					road, -- 313
					cam, -- 313
					theme -- 313
				) -- 313
			end -- 313
			local height = cam:len(isMain and 22 or 12) -- 315
			local bottom = top - height -- 316
			if isMain and bottom > 0 then -- 316
				fillVGradRect( -- 318
					groundDraw, -- 318
					left, -- 318
					0, -- 318
					right - left, -- 318
					bottom + 1, -- 318
					toColor(PALETTE.voidDark), -- 319
					toColor(theme.groundBody) -- 319
				) -- 319
			end -- 319
			local step = cam:len(96) -- 321
			local start = math.max( -- 322
				0, -- 322
				math.floor(-left / step) -- 322
			) -- 322
			do -- 322
				local j = start -- 323
				while left + j * step < math.min(right, cam.viewW) do -- 323
					local x = left + j * step -- 324
					local width = math.min(step, right - x) -- 325
					groundArt:tryPlace( -- 326
						"slab", -- 326
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 326
						x + width * 0.5, -- 326
						bottom, -- 326
						width + 0.5, -- 326
						height, -- 326
						{layer = 3} -- 326
					) -- 326
					if grass and isMain and j % 3 == 1 then -- 326
						groundArt:tryPlace( -- 328
							"grass_low", -- 328
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 328
							x + width * 0.5, -- 328
							top - cam:len(3), -- 329
							width * 0.74, -- 329
							cam:len(13), -- 329
							{opacity = 0.85, layer = 5} -- 329
						) -- 329
					end -- 329
					j = j + 1 -- 323
				end -- 323
			end -- 323
			roadLineDraw:drawSegment( -- 332
				Vec2(left, top), -- 332
				Vec2(right, top), -- 332
				1.2, -- 332
				toColor(theme.groundRim, 160) -- 332
			) -- 332
			i = i + 1 -- 305
		end -- 305
	end -- 305
end -- 296
function StageRenderer.prototype.drawRoad(self, groundDraw, roadLineDraw, groundArt, floorIdx, left, right, front, back, road, cam, theme) -- 342
	local width = right - left -- 355
	local height = back - front -- 356
	if width <= 1 or height <= 1 then -- 356
		return -- 358
	end -- 358
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.36) -- 360
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.52) -- 361
	fillVGradRect( -- 362
		groundDraw, -- 362
		left, -- 362
		front, -- 362
		width, -- 362
		height, -- 362
		toColor(nearCol), -- 362
		toColor(farCol) -- 362
	) -- 362
	local visLeft = math.max(left, -96) -- 364
	local visRight = math.min(right, cam.viewW + 96) -- 365
	local lanes = { -- 368
		{ -- 369
			slot = "dp_road_lower", -- 369
			f0 = 0, -- 369
			f1 = 0.34, -- 369
			tileW = cam:len(104) -- 369
		}, -- 369
		{ -- 370
			slot = "dp_road_mid", -- 370
			f0 = 0.34, -- 370
			f1 = 0.68, -- 370
			tileW = cam:len(96) -- 370
		}, -- 370
		{ -- 371
			slot = "dp_road_upper", -- 371
			f0 = 0.68, -- 371
			f1 = 1, -- 371
			tileW = cam:len(86) -- 371
		} -- 371
	} -- 371
	do -- 371
		local li = 0 -- 373
		while li < #lanes do -- 373
			local ln = lanes[li + 1] -- 374
			local y0 = front + ln.f0 * height -- 375
			local y1 = front + ln.f1 * height -- 376
			local lh = y1 - y0 -- 377
			local twBase = math.max(48, ln.tileW) -- 378
			local tStart = math.max( -- 379
				0, -- 379
				math.floor((visLeft - left) / twBase) -- 379
			) -- 379
			do -- 379
				local col = tStart -- 380
				while left + col * twBase < visRight do -- 380
					do -- 380
						local tx0 = left + col * twBase -- 381
						local tw = math.min(twBase, right - tx0) -- 382
						if tw <= 2 then -- 382
							goto __continue56 -- 383
						end -- 383
						groundArt:tryPlace( -- 384
							ln.slot, -- 384
							(((("road_lane_" .. tostring(floorIdx)) .. "_") .. tostring(li)) .. "_") .. tostring(col), -- 384
							tx0 + tw * 0.5, -- 384
							y0, -- 384
							tw + 0.8, -- 384
							lh + 0.8, -- 384
							{layer = 2, opacity = 0.96} -- 384
						) -- 384
					end -- 384
					::__continue56:: -- 384
					col = col + 1 -- 380
				end -- 380
			end -- 380
			li = li + 1 -- 373
		end -- 373
	end -- 373
	local curbW = math.max( -- 392
		48, -- 392
		cam:len(96) -- 392
	) -- 392
	local curbH = math.max( -- 393
		5, -- 393
		cam:len(7) -- 393
	) -- 393
	local cStart = math.max( -- 394
		0, -- 394
		math.floor((visLeft - left) / curbW) -- 394
	) -- 394
	do -- 394
		local col = cStart -- 395
		while left + col * curbW < visRight do -- 395
			do -- 395
				local tx0 = left + col * curbW -- 396
				local tw = math.min(curbW, right - tx0) -- 397
				if tw <= 2 then -- 397
					goto __continue59 -- 398
				end -- 398
				groundArt:tryPlace( -- 399
					"dp_road_curb", -- 399
					(("road_curb_" .. tostring(floorIdx)) .. "_") .. tostring(col), -- 399
					tx0 + tw * 0.5, -- 399
					front - curbH * 0.35, -- 399
					tw + 0.8, -- 399
					curbH, -- 399
					{layer = 4} -- 399
				) -- 399
			end -- 399
			::__continue59:: -- 399
			col = col + 1 -- 395
		end -- 395
	end -- 395
	local jointDark = Color(8, 11, 18, 138) -- 405
	local laneHint = Color(138, 166, 188, 44) -- 406
	local vpX = cam.viewW * 0.5 -- 407
	local stepWorld = 64 -- 408
	local firstJoint = math.floor((cam.x - cam.viewW * 0.65 / cam.ppu) / stepWorld) -- 409
	local lastJoint = math.ceil((cam.x + cam.viewW * 0.65 / cam.ppu) / stepWorld) -- 410
	do -- 410
		local j = firstJoint -- 411
		while j <= lastJoint do -- 411
			do -- 411
				local xFront = cam:sx(j * stepWorld) -- 412
				if xFront < left - 60 or xFront > right + 60 then -- 412
					goto __continue62 -- 413
				end -- 413
				local xBack = vpX + (xFront - vpX) * cam:depthScale(road.max, true) -- 415
				local cFront = math.max( -- 416
					left, -- 416
					math.min(right, xFront) -- 416
				) -- 416
				local cBack = math.max( -- 417
					left, -- 417
					math.min(right, xBack) -- 417
				) -- 417
				roadLineDraw:drawSegment( -- 418
					Vec2(cFront, front), -- 418
					Vec2(cBack, back), -- 418
					1, -- 418
					jointDark -- 418
				) -- 418
			end -- 418
			::__continue62:: -- 418
			j = j + 1 -- 411
		end -- 411
	end -- 411
	for ____, frac in ipairs({0.34, 0.68}) do -- 422
		local ly = front + frac * height -- 423
		roadLineDraw:drawSegment( -- 424
			Vec2(left, ly), -- 424
			Vec2(right, ly), -- 424
			1, -- 424
			jointDark -- 424
		) -- 424
		roadLineDraw:drawSegment( -- 425
			Vec2(left, ly + 1.1), -- 425
			Vec2(right, ly + 1.1), -- 425
			0.7, -- 425
			laneHint -- 425
		) -- 425
	end -- 425
	fillVGradRect( -- 428
		roadLineDraw, -- 428
		left, -- 428
		back - math.max(4, height * 0.14), -- 428
		width, -- 428
		math.max(4, height * 0.14), -- 428
		Color(6, 8, 14, 0), -- 429
		Color(6, 8, 14, 155) -- 429
	) -- 429
	roadLineDraw:drawSegment( -- 430
		Vec2(left, front), -- 430
		Vec2(right, front), -- 430
		1.5, -- 430
		toColor(theme.groundRim, 168) -- 430
	) -- 430
	roadLineDraw:drawSegment( -- 431
		Vec2(left, back), -- 431
		Vec2(right, back), -- 431
		1.3, -- 431
		Color(118, 144, 166, 95) -- 431
	) -- 431
end -- 342
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 434
	local i = 0 -- 442
	do -- 442
		i = 0 -- 443
		while i < #p.room.stairs do -- 443
			local st = p.room.stairs[i + 1] -- 444
			local n = st.steps + 1 -- 445
			local stepW = (st.x1 - st.x0) / n -- 446
			local depthEnabled = p.room.depth ~= nil -- 447
			local dMin = depthEnabled and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 448
			local dMax = depthEnabled and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 451
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 454
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 455
			local stairLayer = depthEnabled and depthOrder(dMin, 0) or 0 -- 456
			local k = 0 -- 457
			do -- 457
				k = 0 -- 458
				while k < n do -- 458
					do -- 458
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 459
						local wx0 = st.x0 + stepW * k -- 460
						local wx1 = wx0 + stepW -- 461
						local x0 = cam:sx(wx0) -- 462
						local x1 = cam:sx(wx1) -- 463
						if x1 < 0 or x0 > cam.viewW then -- 463
							goto __continue70 -- 465
						end -- 465
						local y1 = cam:sy(wy, dMin) -- 467
						local y0 = cam:sy(baseWorldY, dMin) -- 468
						local yRear = cam:sy(wy, dMax) -- 469
						local sw = x1 - x0 -- 470
						local cx = (x0 + x1) * 0.5 -- 471
						if yRear > y1 + 1 then -- 471
							assets:tryPlace( -- 474
								"dp_stone_top", -- 474
								(("stairs_cap_" .. tostring(i)) .. "_") .. tostring(k), -- 474
								cx, -- 474
								y1, -- 474
								sw + 0.8, -- 474
								yRear - y1 + 0.5, -- 474
								{layer = stairLayer, opacity = 0.96} -- 474
							) -- 474
						end -- 474
						local riserH = y1 - y0 -- 479
						if riserH > 2 then -- 479
							local courseH = math.max( -- 481
								12, -- 481
								cam:len(14) -- 481
							) -- 481
							local courses = math.max( -- 482
								1, -- 482
								math.min( -- 482
									8, -- 482
									math.ceil(riserH / courseH) -- 482
								) -- 482
							) -- 482
							local ch = riserH / courses -- 483
							do -- 483
								local ci = 0 -- 484
								while ci < courses do -- 484
									local slotName = ci == courses - 1 and "dp_stair_step" or "wall" -- 485
									assets:tryPlace( -- 486
										slotName, -- 486
										(((("stairs_" .. tostring(i)) .. "_") .. tostring(k)) .. "_") .. tostring(ci), -- 486
										cx, -- 486
										y0 + ci * ch, -- 486
										sw + 0.8, -- 486
										ch + 0.6, -- 486
										{ -- 486
											layer = stairLayer + 1, -- 487
											color = ci == courses - 1 and Color(246, 250, 255, 255) or Color(196, 206, 218, 255) -- 488
										} -- 488
									) -- 488
									ci = ci + 1 -- 484
								end -- 484
							end -- 484
						end -- 484
						fgDraw:drawSegment( -- 492
							Vec2(x0, y1), -- 492
							Vec2(x1, y1), -- 492
							1.4, -- 492
							toColor(theme.groundRim, 165) -- 492
						) -- 492
						fgGlow:drawSegment( -- 493
							Vec2(x0, y1 + 1), -- 493
							Vec2(x1, y1 + 1), -- 493
							0.8, -- 493
							toColor(theme.accent, 42) -- 493
						) -- 493
					end -- 493
					::__continue70:: -- 493
					k = k + 1 -- 458
				end -- 458
			end -- 458
			i = i + 1 -- 443
		end -- 443
	end -- 443
end -- 434
function StageRenderer.prototype.isSolidActive(self, p, s) -- 499
	local matched = false -- 500
	local anyVisible = false -- 501
	local i = 0 -- 502
	do -- 502
		i = 0 -- 503
		while i < #p.boxes do -- 503
			local b = p.boxes[i + 1] -- 504
			local sameId = s.id ~= nil and b.id == s.id -- 505
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 506
			if sameId or sameGeom then -- 506
				matched = true -- 510
				if b.broken ~= true and b.hidden ~= true then -- 510
					anyVisible = true -- 512
				end -- 512
			end -- 512
			i = i + 1 -- 503
		end -- 503
	end -- 503
	return not matched or anyVisible -- 516
end -- 499
function StageRenderer.prototype.drawSolids(self, fgDraw, overlayDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 519
	local i = 0 -- 531
	do -- 531
		i = 0 -- 532
		while i < #p.room.solids do -- 532
			do -- 532
				local s = p.room.solids[i + 1] -- 533
				if s.decorative == true then -- 533
					if p.room.depth ~= nil and (s.art == "stove_hearth" or s.art == "well") then -- 533
						local bx = cam:sx(s.x + s.w * 0.5) -- 537
						if bx > -80 and bx < cam.viewW + 80 then -- 537
							local backDepth = p.room.depth.max -- 539
							local by = cam:sy(0, backDepth) -- 540
							local dLayer = depthOrder(backDepth, -2) -- 541
							local dScale = cam:depthScale(backDepth, true) -- 542
							assets:tryPlace( -- 543
								"dp_shadow_contact", -- 543
								"decor_sh_" .. tostring(i), -- 543
								bx, -- 543
								by, -- 543
								cam:len(s.w * 1.15) * dScale, -- 543
								cam:len(7) * dScale, -- 543
								{layer = dLayer - 1, opacity = 0.72} -- 543
							) -- 543
							if s.art == "stove_hearth" then -- 543
								assets:tryPlace( -- 547
									"dp_stove_hearth", -- 547
									"decor_stove_" .. tostring(i), -- 547
									bx, -- 547
									by, -- 547
									cam:len(s.w * 1.1) * dScale, -- 547
									cam:len(28) * dScale, -- 547
									{layer = dLayer} -- 547
								) -- 547
							else -- 547
								assets:tryPlacePath( -- 551
									"assets/art/props_ming.clip|well_curb", -- 551
									"decor_well_" .. tostring(i), -- 551
									bx, -- 551
									by, -- 551
									cam:len(s.w * 1.25) * dScale, -- 551
									cam:len(34) * dScale, -- 551
									{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = dLayer} -- 551
								) -- 551
							end -- 551
						end -- 551
					end -- 551
					goto __continue83 -- 557
				end -- 557
				if s.id == "e3_bench" or s.id == "tower_desk" then -- 557
					goto __continue83 -- 560
				end -- 560
				if not self:isSolidActive(p, s) then -- 560
					goto __continue83 -- 564
				end -- 564
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 564
					goto __continue83 -- 568
				end -- 568
				local x0 = cam:sx(s.x) -- 570
				local x1 = cam:sx(s.x + s.w) -- 571
				if p.room.depth ~= nil and s.depth ~= nil then -- 571
					local opacity = occlusion:update( -- 573
						"solid_" .. tostring(i), -- 573
						{ -- 573
							x0 = s.x, -- 574
							x1 = s.x + s.w, -- 574
							y0 = s.y, -- 574
							y1 = s.y + s.h, -- 574
							depth = s.depth, -- 575
							passThrough = s.passable == true or s.soft == true -- 575
						}, -- 575
						p, -- 576
						fadeDt -- 576
					) -- 576
					if x1 > 0 and x0 < cam.viewW then -- 576
						self:drawDepthSolid( -- 578
							fgDraw, -- 578
							overlayDraw, -- 578
							fgGlow, -- 578
							assets, -- 578
							s, -- 578
							s.depth, -- 578
							x0, -- 578
							x1, -- 578
							cam, -- 578
							theme, -- 578
							opacity, -- 578
							p -- 578
						) -- 578
					end -- 578
					goto __continue83 -- 580
				end -- 580
				local y0 = cam:sy(s.y) -- 582
				local y1 = cam:sy(s.y + s.h) -- 583
				local sw = x1 - x0 -- 584
				local sh = y1 - y0 -- 585
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 585
					goto __continue83 -- 587
				end -- 587
				if p.room.key == "outside" and s.y > 10 then -- 587
					local groundY = cam:sy(0) -- 592
					local pierW = cam:len(16) -- 593
					assets:tryPlace( -- 594
						"dp_wall_side", -- 594
						"outside_pier_l_" .. tostring(i), -- 594
						x0 + pierW * 0.5, -- 594
						groundY, -- 594
						pierW, -- 594
						y0 - groundY, -- 594
						{layer = 0} -- 594
					) -- 594
					assets:tryPlace( -- 595
						"dp_wall_side", -- 595
						"outside_pier_r_" .. tostring(i), -- 595
						x1 - pierW * 0.5, -- 595
						groundY, -- 595
						pierW, -- 595
						y0 - groundY, -- 595
						{layer = 0} -- 595
					) -- 595
				end -- 595
				if s.passable == true then -- 595
					if not assets:tryPlace( -- 595
						"grass", -- 600
						"hide_grass_" .. tostring(i), -- 600
						(x0 + x1) * 0.5, -- 600
						y0, -- 600
						sw, -- 600
						sh * 1.55, -- 600
						{opacity = 0.85, layer = 7} -- 601
					) then -- 601
						self:drawGrassCluster( -- 602
							fgDraw, -- 602
							fgGlow, -- 602
							x0, -- 602
							y0, -- 602
							sw, -- 602
							sh, -- 602
							p.player.x, -- 602
							s.x + s.w * 0.5, -- 602
							time -- 602
						) -- 602
					end -- 602
					goto __continue83 -- 604
				end -- 604
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 604
					self:drawWinch( -- 609
						fgDraw, -- 609
						assets, -- 609
						x0, -- 609
						y0, -- 609
						sw, -- 609
						sh, -- 609
						p, -- 609
						2 -- 609
					) -- 609
					goto __continue83 -- 610
				end -- 610
				if p.room.key == "tower" then -- 610
					self:drawTowerStructure( -- 615
						fgDraw, -- 615
						fgGlow, -- 615
						assets, -- 615
						x0, -- 615
						y0, -- 615
						sw, -- 615
						sh, -- 615
						s, -- 615
						p, -- 615
						cam, -- 615
						time -- 615
					) -- 615
					goto __continue83 -- 616
				end -- 616
				if s.art == "red_cart" then -- 616
					assets:tryPlace( -- 621
						"dp_shadow_contact", -- 621
						"red_cart_sh", -- 621
						(x0 + x1) * 0.5, -- 621
						y0 + 1, -- 621
						sw * 1.25, -- 621
						cam:len(8), -- 621
						{layer = 1, opacity = 0.82} -- 621
					) -- 621
					assets:tryPlace( -- 622
						"dp_red_cart", -- 622
						"red_cart_sprite", -- 622
						(x0 + x1) * 0.5, -- 622
						y0, -- 622
						sw * 1.38, -- 622
						sh * 1.15, -- 622
						{layer = 2} -- 622
					) -- 622
					goto __continue83 -- 623
				end -- 623
				if s.h <= 64 and s.y <= 2 then -- 623
					self:drawCoverBlock( -- 628
						overlayDraw, -- 628
						fgGlow, -- 628
						assets, -- 628
						x0, -- 628
						y0, -- 628
						sw, -- 628
						sh, -- 628
						s, -- 628
						p, -- 628
						theme -- 628
					) -- 628
					goto __continue83 -- 629
				end -- 629
				self:tileMasonry( -- 632
					assets, -- 632
					s, -- 632
					x0, -- 632
					y0, -- 632
					sw, -- 632
					sh -- 632
				) -- 632
			end -- 632
			::__continue83:: -- 632
			i = i + 1 -- 532
		end -- 532
	end -- 532
end -- 519
function StageRenderer.prototype.drawDepthSolid(self, draw, overlayDraw, fgGlow, assets, solid, depth, left, right, cam, theme, opacity, p) -- 636
	local width = right - left -- 650
	local base = cam:sy(solid.y, depth.min) -- 651
	local top = cam:sy(solid.y + solid.h, depth.min) -- 652
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 653
	local frontH = top - base -- 654
	local slot = coverArt(solid) -- 655
	local layer = depthOrder(depth.min, 1) -- 656
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 657
	local capHeight = rear - top -- 658
	local center = (left + right) * 0.5 -- 659
	local dShade = cam:depthShade(depth.min, true) -- 660
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 660
		assets:tryPlace( -- 664
			"dp_shadow_contact", -- 664
			"winch_sh_" .. tostring(solid.x), -- 664
			center, -- 664
			base + 1, -- 664
			width * 1.18, -- 664
			cam:len(10), -- 664
			{layer = layer - 1, opacity = 0.82 * opacity} -- 664
		) -- 664
		self:drawWinch( -- 667
			draw, -- 667
			assets, -- 667
			left, -- 667
			base, -- 667
			width, -- 667
			frontH, -- 667
			p, -- 667
			layer -- 667
		) -- 667
		return -- 668
	end -- 668
	if solid.art == "latch" then -- 668
		local groundY = cam:sy(0, depth.min) -- 673
		local postH = math.max(frontH, top - groundY) -- 674
		assets:tryPlace( -- 675
			"dp_shadow_contact", -- 675
			"latch_sh_" .. tostring(solid.x), -- 675
			center, -- 675
			groundY + 1, -- 675
			width * 1.1, -- 675
			cam:len(8), -- 675
			{layer = layer - 1, opacity = 0.78 * opacity} -- 675
		) -- 675
		assets:tryPlace( -- 678
			"fe_pillar_wood", -- 678
			"latch_post_" .. tostring(solid.x), -- 678
			right - cam:len(6), -- 678
			groundY, -- 678
			cam:len(12), -- 678
			postH + cam:len(10), -- 678
			{ -- 678
				layer = layer, -- 679
				opacity = opacity, -- 679
				color = occlusionTint(opacity) -- 679
			} -- 679
		) -- 679
		assets:tryPlace( -- 681
			"dp_latch", -- 681
			key, -- 681
			center, -- 681
			base - cam:len(4), -- 681
			math.max( -- 681
				width * 1.3, -- 681
				cam:len(36) -- 681
			), -- 681
			math.max( -- 681
				frontH * 1.3, -- 681
				cam:len(32) -- 681
			), -- 681
			{ -- 681
				layer = layer + 1, -- 682
				opacity = opacity, -- 682
				color = occlusionTint(opacity) -- 682
			} -- 682
		) -- 682
		fillRadialGlow( -- 684
			fgGlow, -- 684
			center - cam:len(6), -- 684
			base + frontH * 0.5, -- 684
			cam:len(18), -- 684
			cam:len(14), -- 684
			Color( -- 685
				238, -- 685
				168, -- 685
				72, -- 685
				math.floor(58 * opacity + 0.5) -- 685
			), -- 685
			Color(238, 168, 72, 0), -- 685
			10 -- 685
		) -- 685
		return -- 686
	end -- 686
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 686
		assets:tryPlace( -- 690
			"slab", -- 690
			"gate_sill_" .. tostring(solid.x), -- 690
			center, -- 690
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 690
			width + cam:len(34), -- 691
			cam:len(12), -- 691
			{ -- 691
				layer = 1, -- 691
				color = Color(180, 169, 150, 255) -- 691
			} -- 691
		) -- 691
		if p.room.key ~= "gate" then -- 691
			local beamY = cam:sy(solid.y + solid.h - 10, LANE_DEPTH.lower) -- 694
			local beamW = math.max( -- 695
				width * 2.8, -- 695
				cam:len(92) -- 695
			) -- 695
			local beamH = cam:len(26) -- 696
			assets:tryPlace( -- 697
				"dp_gate_arch_beam", -- 697
				"gate_beam_" .. tostring(solid.x), -- 697
				center, -- 697
				beamY, -- 697
				beamW, -- 697
				beamH, -- 697
				{ -- 697
					layer = depthOrder(LANE_DEPTH.lower, 3), -- 698
					opacity = math.min(1, opacity + 0.12) -- 699
				} -- 699
			) -- 699
		end -- 699
	end -- 699
	local shadowH = math.max( -- 705
		cam:len(6), -- 705
		cam:sy(solid.y, depth.max) - base + cam:len(5) -- 705
	) -- 705
	assets:tryPlace( -- 706
		"dp_shadow_contact", -- 706
		(("solid_sh_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 706
		center, -- 706
		base + shadowH * 0.32, -- 706
		width * 1.14, -- 707
		shadowH * 1.15, -- 707
		{layer = layer - 1, opacity = 0.78 * opacity} -- 707
	) -- 707
	local propArt = dedicatedSolidProp(solid) -- 713
	if propArt ~= nil then -- 713
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 715
		local drawH = frontH * propArt.heightMul -- 716
		local cols = propArt.tileable and math.max( -- 717
			1, -- 718
			math.min( -- 718
				6, -- 718
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 718
			) -- 718
		) or 1 -- 718
		local colW = width / cols -- 720
		local tint = occlusionTint( -- 721
			opacity, -- 721
			tintByShade( -- 721
				Color(238, 240, 246, 255), -- 721
				dShade -- 721
			) -- 721
		) -- 721
		local placedProp = false -- 722
		do -- 722
			local col = 0 -- 723
			while col < cols do -- 723
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 724
				if assets:tryPlacePath( -- 724
					propPath, -- 725
					tileKey, -- 725
					left + (col + 0.5) * colW, -- 725
					base, -- 725
					colW + 1, -- 725
					drawH, -- 725
					{ -- 725
						anchorX = 0.5, -- 726
						anchorY = 0, -- 727
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 728
						opacity = opacity, -- 729
						color = tint, -- 730
						layer = layer -- 731
					} -- 731
				) then -- 731
					placedProp = true -- 733
				end -- 733
				col = col + 1 -- 723
			end -- 723
		end -- 723
		if placedProp then -- 723
			return -- 737
		end -- 737
	end -- 737
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 741
	local isStoneCover = slot == "cover_stone" -- 742
	local isSoftCloth = solid.soft == true or solid.art == "curtain" -- 743
	local visCapH = solid.y >= 100 and math.min( -- 744
		capHeight, -- 744
		cam:len(10) -- 744
	) or capHeight -- 744
	if slot ~= "fence" and not isSoftCloth and visCapH > 2 and frontH > 8 then -- 744
		local viewShift = (cam.viewW * 0.5 - center) / math.max(240, cam.viewW * 0.5) -- 748
		local sidePx = math.min( -- 749
			cam:len(14), -- 749
			math.abs(viewShift) * visCapH * 0.65 -- 749
		) -- 749
		if sidePx >= 2.2 then -- 749
			local sideSlot = timber and "dp_wood_side" or (isStoneCover and "dp_stone_side" or "dp_wall_side") -- 751
			local sideX = viewShift > 0 and right + sidePx * 0.5 or left - sidePx * 0.5 -- 752
			assets:tryPlace( -- 753
				sideSlot, -- 753
				(("side_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 753
				sideX, -- 753
				base + visCapH * 0.35, -- 753
				sidePx + 0.6, -- 753
				frontH, -- 753
				{ -- 753
					layer = layer - 1, -- 754
					opacity = math.min(1, opacity * 0.92), -- 755
					color = occlusionTint( -- 756
						opacity, -- 756
						tintByShade( -- 756
							Color(210, 218, 228, 255), -- 756
							dShade -- 756
						) -- 756
					) -- 756
				} -- 756
			) -- 756
		end -- 756
	end -- 756
	if isSoftCloth then -- 756
		assets:tryPlace( -- 763
			"fe_beam_wood", -- 763
			(("cap_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 763
			center, -- 763
			top - 1, -- 763
			width + 4, -- 763
			math.max( -- 763
				3, -- 763
				cam:len(4) -- 763
			), -- 763
			{ -- 763
				opacity = math.min(1, opacity), -- 764
				color = occlusionTint( -- 765
					opacity, -- 765
					Color(148, 122, 96, 255) -- 765
				), -- 765
				layer = layer + 1 -- 766
			} -- 766
		) -- 766
	elseif slot ~= "fence" and visCapH > 1 then -- 766
		local capSlot = timber and "dp_wood_top" or (isStoneCover and "dp_stone_top" or "dp_wall_top") -- 769
		local capTint = occlusionTint( -- 770
			opacity, -- 770
			tintByShade( -- 770
				Color(246, 248, 252, 255), -- 770
				dShade -- 770
			) -- 770
		) -- 770
		assets:tryPlace( -- 771
			capSlot, -- 771
			(("cap_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 771
			center, -- 771
			top - 0.5, -- 771
			width + 0.6, -- 771
			visCapH + 1, -- 771
			{ -- 771
				opacity = math.min(1, opacity), -- 772
				color = capTint, -- 773
				layer = layer -- 774
			} -- 774
		) -- 774
	end -- 774
	if timber and solid.h > solid.w * 1.6 then -- 774
		local segs = math.max( -- 780
			1, -- 780
			math.min( -- 780
				6, -- 780
				math.floor(solid.h / math.max(24, solid.w * 3.5) + 0.5) -- 780
			) -- 780
		) -- 780
		local segH = frontH / segs -- 781
		local colTint = occlusionTint( -- 782
			opacity, -- 782
			tintByShade( -- 782
				Color(255, 255, 255, 255), -- 782
				dShade -- 782
			) -- 782
		) -- 782
		do -- 782
			local pi = 0 -- 783
			while pi < segs do -- 783
				local tk = pi == 0 and key or (key .. "_p") .. tostring(pi) -- 784
				assets:tryPlace( -- 785
					"fe_pillar_wood", -- 785
					tk, -- 785
					center, -- 785
					base + pi * segH, -- 785
					width + 0.5, -- 785
					segH + 0.5, -- 785
					{layer = layer, opacity = opacity, color = colTint} -- 785
				) -- 785
				pi = pi + 1 -- 783
			end -- 783
		end -- 783
		return -- 789
	end -- 789
	if timber and solid.w > solid.h * 5 then -- 789
		local segs = math.max( -- 794
			2, -- 794
			math.min( -- 794
				12, -- 794
				math.floor(solid.w / 64 + 0.5) -- 794
			) -- 794
		) -- 794
		local segW = width / segs -- 795
		local beamH = math.max(5, frontH) -- 796
		local beamTint = occlusionTint( -- 797
			opacity, -- 797
			tintByShade( -- 797
				Color(255, 255, 255, 255), -- 797
				dShade -- 797
			) -- 797
		) -- 797
		do -- 797
			local bi = 0 -- 798
			while bi < segs do -- 798
				local tk = bi == 0 and key or (key .. "_b") .. tostring(bi) -- 799
				assets:tryPlace( -- 800
					"fe_beam_wood", -- 800
					tk, -- 800
					left + (bi + 0.5) * segW, -- 800
					base, -- 800
					segW + 0.5, -- 800
					beamH, -- 800
					{layer = layer, opacity = opacity, color = beamTint} -- 800
				) -- 800
				bi = bi + 1 -- 798
			end -- 798
		end -- 798
		return -- 804
	end -- 804
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 808
	local cols = slot == "wall" and math.max( -- 809
		1, -- 810
		math.min( -- 810
			10, -- 810
			math.floor(solid.w / 72 + 0.5) -- 810
		) -- 810
	) or math.max( -- 810
		1, -- 811
		math.min( -- 811
			10, -- 811
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 811
		) -- 811
	) -- 811
	local colW = width / cols -- 812
	local rows = slot == "wall" and math.max( -- 813
		1, -- 814
		math.min( -- 814
			10, -- 814
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 814
		) -- 814
	) or math.max( -- 814
		1, -- 815
		math.min( -- 815
			6, -- 815
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 815
		) -- 815
	) -- 815
	local rowHeight = frontH / rows -- 816
	local baseColor = slot == "wall" and Color(216, 224, 234, 255) or Color(255, 255, 255, 255) -- 817
	local color = occlusionTint( -- 818
		opacity, -- 818
		tintByShade(baseColor, dShade) -- 818
	) -- 818
	do -- 818
		local row = 0 -- 819
		while row < rows do -- 819
			do -- 819
				local col = 0 -- 820
				while col < cols do -- 820
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 821
					assets:tryPlace( -- 822
						slot, -- 822
						tileKey, -- 822
						left + (col + 0.5) * colW, -- 822
						base + row * rowHeight, -- 822
						colW + 0.5, -- 822
						rowHeight + 0.5, -- 822
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 822
					) -- 822
					col = col + 1 -- 820
				end -- 820
			end -- 820
			row = row + 1 -- 819
		end -- 819
	end -- 819
	if not p.childMode and solid.h <= 64 and solid.y <= 2 and (p.coverHug or p.coverNear) then -- 819
		local plx = p.player.x -- 830
		local nearLeft = math.abs(plx - solid.x) < 42 -- 831
		local nearRight = math.abs(plx - (solid.x + solid.w)) < 42 -- 832
		if (nearLeft or nearRight) and math.abs(p.player.depth - (depth.min + depth.max) * 0.5) <= 28 then -- 832
			local edgeX = nearLeft and left - 1.5 or right + 1.5 -- 834
			local col = p.coverHug and (timber and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 835
			overlayDraw:drawSegment( -- 836
				Vec2(edgeX, base + 3), -- 836
				Vec2(edgeX, top + 2), -- 836
				p.coverHug and 2.2 or 1.3, -- 836
				toColor(col, p.coverHug and 220 or 125) -- 836
			) -- 836
		end -- 836
	end -- 836
end -- 636
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 841
	local columns = math.max( -- 846
		1, -- 846
		math.min( -- 846
			10, -- 846
			math.floor(s.w / 58 + 0.5) -- 846
		) -- 846
	) -- 846
	local cellWorldW = s.w / columns -- 847
	local targetCellH = math.max( -- 848
		24, -- 848
		math.min(48, cellWorldW / 1.52) -- 848
	) -- 848
	local rows = math.max( -- 849
		1, -- 849
		math.min( -- 849
			12, -- 849
			math.floor(s.h / targetCellH + 0.5) -- 849
		) -- 849
	) -- 849
	local tileW = width / columns -- 850
	local tileH = height / rows -- 851
	do -- 851
		local row = 0 -- 852
		while row < rows do -- 852
			do -- 852
				local column = 0 -- 853
				while column < columns do -- 853
					assets:tryPlace( -- 854
						"wall", -- 854
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 854
						x + (column + 0.5) * tileW, -- 855
						y + row * tileH, -- 855
						tileW + 0.5, -- 855
						tileH + 0.5, -- 855
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 856
					) -- 856
					column = column + 1 -- 853
				end -- 853
			end -- 853
			row = row + 1 -- 852
		end -- 852
	end -- 852
end -- 841
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 861
	local slot = coverArt(s) -- 868
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 869
	local cols = math.max( -- 870
		1, -- 870
		math.min( -- 870
			8, -- 870
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 870
		) -- 870
	) -- 870
	local tileW = sw / cols -- 871
	local placed = false -- 872
	do -- 872
		local c = 0 -- 873
		while c < cols do -- 873
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 874
			if assets:tryPlace( -- 874
				slot, -- 875
				k, -- 875
				x0 + (c + 0.5) * tileW, -- 875
				y0, -- 875
				tileW + 0.5, -- 875
				sh, -- 875
				{layer = 1} -- 875
			) then -- 875
				placed = true -- 876
			end -- 876
			c = c + 1 -- 873
		end -- 873
	end -- 873
	if not placed then -- 873
		fillVGradRect( -- 880
			fgDraw, -- 880
			x0, -- 880
			y0, -- 880
			sw, -- 880
			sh, -- 880
			toColor(PALETTE.steelDark), -- 880
			toColor(PALETTE.steelMid) -- 880
		) -- 880
		fgDraw:drawSegment( -- 881
			Vec2(x0, y0 + sh), -- 881
			Vec2(x0 + sw, y0 + sh), -- 881
			1.4, -- 881
			toColor(theme.groundRim) -- 881
		) -- 881
	end -- 881
	if not p.childMode and (p.coverHug or p.coverNear) then -- 881
		local plx = p.player.x -- 886
		local nearLeft = math.abs(plx - s.x) < 42 -- 887
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 888
		if nearLeft or nearRight then -- 888
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 890
			local isWood = slot == "cover_wood" -- 891
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 892
			fgDraw:drawSegment( -- 893
				Vec2(edgeX, y0 + 4), -- 893
				Vec2(edgeX, y0 + sh + 2), -- 893
				p.coverHug and 2 or 1.2, -- 893
				toColor(col, p.coverHug and 205 or 120) -- 893
			) -- 893
		end -- 893
	end -- 893
end -- 861
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 901
	if layer == nil then -- 901
		layer = 2 -- 906
	end -- 906
	local cx = x0 + sw * 0.5 -- 908
	local cy = y0 + sh * 0.55 -- 909
	local ropeWidth = math.max(1, sw * 0.023) -- 910
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 911
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 912
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 913
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 914
	draw:drawSegment( -- 915
		drum, -- 915
		bend, -- 915
		ropeWidth, -- 915
		Color(111, 86, 57, 239) -- 915
	) -- 915
	draw:drawSegment( -- 916
		bend, -- 916
		ropeTop, -- 916
		ropeWidth, -- 916
		Color(111, 86, 57, 239) -- 916
	) -- 916
	assets:tryPlace( -- 917
		"prop_winch", -- 917
		"gate_winch", -- 917
		cx, -- 917
		y0 + sh * 0.5, -- 917
		sw, -- 917
		sh, -- 917
		{layer = layer} -- 917
	) -- 917
end -- 901
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 920
	local ____temp_3 -- 928
	if p.room.story ~= nil then -- 928
		____temp_3 = p.room.story.gate -- 928
	else -- 928
		____temp_3 = nil -- 928
	end -- 928
	local g = ____temp_3 -- 928
	if g == nil then -- 928
		return -- 930
	end -- 930
	local closeFrac = 0.08 -- 933
	if p.phase == "gate-hold" then -- 933
		closeFrac = 0.08 + 0.36 * math.min( -- 935
			1, -- 935
			p.gateTick / math.max(1, g.holdTicks) -- 935
		) -- 935
	elseif p.phase == "gate-send" then -- 935
		closeFrac = 0.44 -- 937
	elseif p.phase == "gate-count" then -- 937
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 939
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 939
		closeFrac = 1 -- 941
	end -- 941
	local gx0 = cam:sx(864) -- 943
	local gx1 = cam:sx(1016) -- 944
	local topY = cam:sy(160) -- 945
	local botY = cam:sy(160 * (1 - closeFrac)) -- 946
	local shutterW = gx1 - gx0 -- 947
	local shutterH = topY - botY -- 948
	if shutterH > 2 then -- 948
		fillVGradRect( -- 950
			fgDraw, -- 950
			gx0, -- 950
			botY, -- 950
			shutterW, -- 950
			shutterH, -- 950
			toColor(PALETTE.steelDark), -- 950
			toColor(PALETTE.steelMid) -- 950
		) -- 950
		local rows = math.max( -- 952
			1, -- 952
			math.min( -- 952
				6, -- 952
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 952
			) -- 952
		) -- 952
		local rowH = shutterH / rows -- 953
		do -- 953
			local r = 0 -- 954
			while r < rows do -- 954
				assets:tryPlace( -- 955
					"cover_wood", -- 955
					"gate_shutter_" .. tostring(r), -- 955
					(gx0 + gx1) * 0.5, -- 955
					botY + r * rowH, -- 955
					shutterW, -- 956
					rowH + 0.5, -- 956
					{layer = depthOrder(0, 2)} -- 956
				) -- 956
				r = r + 1 -- 954
			end -- 954
		end -- 954
	end -- 954
	if closeFrac < 0.98 then -- 954
		local gapH = math.max( -- 961
			8, -- 961
			botY - cam:sy(0) -- 961
		) -- 961
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 962
		fillVGradRect( -- 963
			fgGlow, -- 963
			gx0, -- 963
			cam:sy(0), -- 963
			gx1 - gx0, -- 963
			gapH, -- 963
			Color( -- 963
				140, -- 963
				210, -- 963
				255, -- 963
				math.floor(52 * pulse + 0.5) -- 963
			), -- 963
			Color(80, 160, 230, 0) -- 963
		) -- 963
	end -- 963
end -- 920
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 967
	if s.id == "tower_door" then -- 967
		return -- 976
	end -- 976
	fillVGradRect( -- 978
		fgDraw, -- 978
		x0, -- 978
		y0, -- 978
		sw, -- 978
		sh, -- 978
		Color(14, 19, 30, 255), -- 978
		Color(26, 36, 54, 255) -- 978
	) -- 978
	fgDraw:drawRect( -- 979
		Rect(x0, y0, sw, sh), -- 979
		Color(0, 0, 0, 0), -- 979
		1, -- 979
		Color(42, 54, 72, 145) -- 979
	) -- 979
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 979
		self:tileMasonry( -- 982
			assets, -- 982
			s, -- 982
			x0, -- 982
			y0, -- 982
			sw, -- 982
			sh -- 982
		) -- 982
		if s.w >= 60 then -- 982
			local ribs = 4 -- 985
			local r = 1 -- 986
			do -- 986
				r = 1 -- 987
				while r < ribs do -- 987
					local rx = x0 + sw * r / ribs -- 988
					fgDraw:drawSegment( -- 989
						Vec2(rx, y0), -- 989
						Vec2(rx, y0 + sh), -- 989
						2, -- 989
						Color(10, 15, 24, 210) -- 989
					) -- 989
					fgDraw:drawSegment( -- 990
						Vec2(rx + 2, y0), -- 990
						Vec2(rx + 2, y0 + sh), -- 990
						1, -- 990
						Color(68, 86, 114, 130) -- 990
					) -- 990
					r = r + 1 -- 987
				end -- 987
			end -- 987
			local bands = 4 -- 993
			local b = 1 -- 994
			do -- 994
				b = 1 -- 995
				while b < bands do -- 995
					local by = y0 + sh * b / bands -- 996
					fgDraw:drawSegment( -- 997
						Vec2(x0 + 4, by), -- 997
						Vec2(x0 + sw - 4, by), -- 997
						1.2, -- 997
						Color(52, 68, 92, 135) -- 997
					) -- 997
					b = b + 1 -- 995
				end -- 995
			end -- 995
			local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1000
			local slitY = y0 + sh * 0.56 -- 1001
			local slitH = sh * 0.22 -- 1002
			fgDraw:drawRect( -- 1003
				Rect(slitX - 5, slitY, 10, slitH), -- 1003
				Color(8, 12, 20, 245), -- 1003
				1.2, -- 1003
				toColor(PALETTE.amberDim, 190) -- 1003
			) -- 1003
			fgGlow:drawRect( -- 1004
				Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1004
				toColor(PALETTE.amber, 190) -- 1004
			) -- 1004
			fillRadialGlow( -- 1005
				fgGlow, -- 1005
				slitX, -- 1005
				slitY + slitH * 0.5, -- 1005
				44, -- 1005
				slitH * 0.7, -- 1005
				Color(255, 206, 128, 52), -- 1005
				Color(255, 180, 86, 0), -- 1005
				14 -- 1005
			) -- 1005
		end -- 1005
	end -- 1005
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1005
		self:tileMasonry( -- 1011
			assets, -- 1011
			s, -- 1011
			x0, -- 1011
			y0, -- 1011
			sw, -- 1011
			sh -- 1011
		) -- 1011
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1012
		local cx = x0 + sw * 0.5 -- 1017
		local lampY = y0 - 8 -- 1018
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1019
		if not opened then -- 1019
			assets:tryPlace( -- 1021
				"prop_tower_door", -- 1021
				"tower_door", -- 1021
				cx, -- 1021
				y0 - doorHeight, -- 1021
				sw, -- 1021
				doorHeight, -- 1021
				{layer = 2} -- 1021
			) -- 1021
		end -- 1021
		assets:tryPlace( -- 1023
			"prop_lantern", -- 1023
			"tower_lantern", -- 1023
			cx + sw * 0.43, -- 1023
			lampY - sh * 0.36, -- 1023
			sw * 0.17, -- 1024
			sh * 0.84, -- 1024
			{layer = 3} -- 1024
		) -- 1024
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1025
		local alpha = opened and 58 or 42 -- 1026
		fgDraw:drawSegment( -- 1028
			Vec2(x0 + 4, y0), -- 1028
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1028
			4, -- 1028
			Color(42, 52, 70, 255) -- 1028
		) -- 1028
		fgDraw:drawSegment( -- 1029
			Vec2(x0 + sw - 4, y0), -- 1029
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1029
			4, -- 1029
			Color(42, 52, 70, 255) -- 1029
		) -- 1029
		fgDraw:drawSegment( -- 1030
			Vec2(x0, y0), -- 1030
			Vec2(x0 + sw, y0), -- 1030
			2.5, -- 1030
			toColor(PALETTE.amber, 210) -- 1030
		) -- 1030
		fillVGradRect( -- 1032
			fgGlow, -- 1033
			x0 + 6, -- 1034
			y0 - sh * 3.8, -- 1035
			sw - 12, -- 1036
			sh * 3.8, -- 1037
			Color( -- 1038
				246, -- 1038
				196, -- 1038
				118, -- 1038
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1038
			), -- 1038
			Color(246, 206, 142, opened and 74 or 38) -- 1039
		) -- 1039
		fillRadialGlow( -- 1041
			fgGlow, -- 1041
			cx, -- 1041
			lampY, -- 1041
			opened and 78 or 54, -- 1041
			opened and 72 or 52, -- 1041
			Color( -- 1041
				252, -- 1041
				218, -- 1041
				152, -- 1041
				math.floor(92 * pulse + 0.5) -- 1041
			), -- 1041
			Color(255, 180, 86, 0), -- 1041
			18 -- 1041
		) -- 1041
		fgDraw:drawCircle( -- 1042
			Vec2(cx, lampY), -- 1042
			4.5, -- 1042
			toColor(PALETTE.amberCore) -- 1042
		) -- 1042
		if opened then -- 1042
			local deskCx = cam:sx(p.ox + 605) -- 1046
			local groundY = cam:sy(0) -- 1047
			local deskW = cam:len(84) -- 1048
			local deskH = cam:len(34) -- 1049
			local deskTop = groundY + deskH -- 1050
			local writing = p.deskHold >= 24 or p.towerHanded -- 1051
			fillRadialGlow( -- 1053
				fgGlow, -- 1053
				deskCx, -- 1053
				deskTop + cam:len(26), -- 1053
				cam:len(96), -- 1053
				cam:len(74), -- 1053
				Color( -- 1054
					255, -- 1054
					198, -- 1054
					114, -- 1054
					math.floor(52 * pulse + 0.5) -- 1054
				), -- 1054
				Color(255, 168, 72, 0), -- 1054
				16 -- 1054
			) -- 1054
			local guardX = deskCx + cam:len(26) -- 1056
			local guardFrame = math.floor(time * (writing and 3.2 or 3.8)) % 4 -- 1057
			local guardClip = writing and GUARD_WRITE_CLIPS[guardFrame + 1] or GUARD_LANTERN_CLIPS[guardFrame + 1] -- 1058
			if not assets:tryPlacePath( -- 1058
				guardClip, -- 1061
				"tower_guard_npc", -- 1061
				guardX, -- 1061
				groundY, -- 1061
				cam:len(54), -- 1061
				cam:len(86), -- 1061
				{ -- 1061
					anchorX = 0.5, -- 1062
					anchorY = 0, -- 1063
					preserveAspect = true, -- 1064
					facing = -1, -- 1065
					opacity = 0.96, -- 1066
					layer = 3 -- 1067
				} -- 1067
			) then -- 1067
				fgDraw:drawRect( -- 1069
					Rect( -- 1069
						guardX - cam:len(11), -- 1069
						groundY, -- 1069
						cam:len(22), -- 1069
						cam:len(68) -- 1069
					), -- 1069
					Color(34, 42, 54, 240) -- 1069
				) -- 1069
				fgDraw:drawCircle( -- 1070
					Vec2( -- 1070
						guardX, -- 1070
						groundY + cam:len(76) -- 1070
					), -- 1070
					cam:len(9.5), -- 1070
					Color(42, 50, 62, 245) -- 1070
				) -- 1070
			end -- 1070
			if not assets:tryPlace( -- 1070
				"prop_table", -- 1073
				"tower_guard_desk", -- 1073
				deskCx, -- 1073
				groundY, -- 1073
				deskW * 1.06, -- 1073
				deskH * 1.04, -- 1073
				{ -- 1073
					color = Color(214, 188, 158, 255), -- 1074
					opacity = 0.98, -- 1075
					layer = 4 -- 1076
				} -- 1076
			) then -- 1076
				fgDraw:drawRect( -- 1078
					Rect( -- 1078
						deskCx - deskW * 0.5, -- 1078
						groundY, -- 1078
						cam:len(6), -- 1078
						deskH -- 1078
					), -- 1078
					Color(78, 52, 34, 255) -- 1078
				) -- 1078
				fgDraw:drawRect( -- 1079
					Rect( -- 1079
						deskCx + deskW * 0.5 - cam:len(6), -- 1079
						groundY, -- 1079
						cam:len(6), -- 1079
						deskH -- 1079
					), -- 1079
					Color(78, 52, 34, 255) -- 1079
				) -- 1079
				fgDraw:drawRect( -- 1080
					Rect( -- 1080
						deskCx - deskW * 0.52, -- 1080
						deskTop - cam:len(6), -- 1080
						deskW * 1.04, -- 1080
						cam:len(8) -- 1080
					), -- 1080
					Color(108, 74, 46, 255), -- 1080
					1, -- 1080
					Color(148, 108, 68, 220) -- 1080
				) -- 1080
			end -- 1080
			fgDraw:drawRect( -- 1083
				Rect( -- 1083
					deskCx + cam:len(4), -- 1083
					deskTop + cam:len(1), -- 1083
					cam:len(22), -- 1083
					cam:len(4.5) -- 1083
				), -- 1083
				Color(232, 222, 198, 245) -- 1083
			) -- 1083
			if writing then -- 1083
				assets:tryPlace( -- 1085
					"prop_lantern", -- 1085
					"tower_desk_lamp", -- 1085
					deskCx + cam:len(34), -- 1085
					deskTop + cam:len(10), -- 1085
					cam:len(14), -- 1085
					cam:len(20), -- 1085
					{layer = 5} -- 1085
				) -- 1085
				fillRadialGlow( -- 1086
					fgGlow, -- 1086
					deskCx + cam:len(34), -- 1086
					deskTop + cam:len(12), -- 1086
					cam:len(24), -- 1086
					cam:len(22), -- 1086
					Color( -- 1086
						255, -- 1086
						214, -- 1086
						134, -- 1086
						math.floor(88 * pulse + 0.5) -- 1086
					), -- 1086
					Color(255, 180, 86, 0), -- 1086
					12 -- 1086
				) -- 1086
			else -- 1086
				fillRadialGlow( -- 1088
					fgGlow, -- 1088
					deskCx + cam:len(3), -- 1088
					deskTop + cam:len(18), -- 1088
					cam:len(30), -- 1088
					cam:len(28), -- 1088
					Color( -- 1088
						255, -- 1088
						214, -- 1088
						134, -- 1088
						math.floor(78 * pulse + 0.5) -- 1088
					), -- 1088
					Color(255, 180, 86, 0), -- 1088
					12 -- 1088
				) -- 1088
			end -- 1088
			if p.deskHold >= 12 or p.towerHanded then -- 1088
				if not assets:tryPlacePath( -- 1088
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1092
					"tower_desk_pouch", -- 1092
					deskCx - cam:len(22), -- 1092
					deskTop + cam:len(8), -- 1092
					cam:len(18), -- 1092
					cam:len(18), -- 1092
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1092
				) then -- 1092
					fgDraw:drawRect( -- 1098
						Rect( -- 1098
							deskCx - cam:len(28), -- 1098
							deskTop + cam:len(2), -- 1098
							cam:len(14), -- 1098
							cam:len(6) -- 1098
						), -- 1098
						Color(156, 62, 48, 245) -- 1098
					) -- 1098
				end -- 1098
			end -- 1098
			if writing then -- 1098
				fgDraw:drawRect( -- 1102
					Rect( -- 1102
						deskCx - cam:len(6), -- 1102
						deskTop + cam:len(2), -- 1102
						cam:len(10), -- 1102
						cam:len(3) -- 1102
					), -- 1102
					Color(236, 228, 206, 240) -- 1102
				) -- 1102
			end -- 1102
		end -- 1102
	end -- 1102
end -- 967
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1108
	local blades = math.max( -- 1115
		12, -- 1115
		math.floor(sw / 8) -- 1115
	) -- 1115
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1116
	local k = 0 -- 1117
	do -- 1117
		k = 0 -- 1118
		while k < blades do -- 1118
			local t = (k + 0.5) / blades -- 1119
			local bx = x0 + sw * t -- 1120
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1121
			local bh = sh * hRatio * 1.95 -- 1122
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1123
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1124
			fgDraw:drawPolygon( -- 1125
				{ -- 1125
					Vec2(bx - 7, y0), -- 1126
					Vec2(bx + 7, y0), -- 1127
					Vec2(bx + sway, y0 + bh) -- 1128
				}, -- 1128
				col -- 1129
			) -- 1129
			k = k + 1 -- 1118
		end -- 1118
	end -- 1118
	if nearPlayer then -- 1118
		fgGlow:drawSegment( -- 1132
			Vec2(x0, y0 + 2), -- 1132
			Vec2(x0 + sw, y0 + 2), -- 1132
			2, -- 1132
			toColor(PALETTE.emerald, 145) -- 1132
		) -- 1132
	end -- 1132
end -- 1108
function StageRenderer.prototype.drawArch(self, draw, assets, p, cam) -- 1136
	local a = p.room.arch -- 1142
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1142
		return -- 1144
	end -- 1144
	local x0 = cam:sx(a.x0) -- 1146
	local x1 = cam:sx(a.x1) -- 1147
	local y0 = cam:sy(a.y) -- 1148
	local y1 = cam:sy(a.y + a.h) -- 1149
	local cx = (x0 + x1) * 0.5 -- 1150
	local aw = x1 - x0 -- 1151
	local ah = y1 - y0 -- 1152
	draw:drawRect( -- 1153
		Rect( -- 1153
			x0, -- 1153
			y0, -- 1153
			aw, -- 1153
			ah + cam:len(8) -- 1153
		), -- 1153
		Color(13, 15, 20, 242) -- 1153
	) -- 1153
	if not assets:tryPlace( -- 1153
		"fe_outside_arch", -- 1154
		"outside_arch_vault", -- 1154
		cx, -- 1154
		y0, -- 1154
		aw + cam:len(24), -- 1154
		ah + cam:len(22), -- 1154
		{layer = 2} -- 1154
	) then -- 1154
		draw:drawRect( -- 1155
			Rect( -- 1155
				x0 - cam:len(7), -- 1155
				y0, -- 1155
				cam:len(7), -- 1155
				ah -- 1155
			), -- 1155
			Color(62, 63, 67, 255) -- 1155
		) -- 1155
		draw:drawRect( -- 1156
			Rect( -- 1156
				x1, -- 1156
				y0, -- 1156
				cam:len(7), -- 1156
				ah -- 1156
			), -- 1156
			Color(72, 72, 74, 255) -- 1156
		) -- 1156
	end -- 1156
	local latch = p:cartLatchBounds() -- 1159
	if latch ~= nil then -- 1159
		local bx0 = cam:sx(latch.x) -- 1161
		local bx1 = cam:sx(latch.x + latch.width) -- 1162
		local deckY = cam:sy(p.room.cart.baseY) -- 1163
		assets:tryPlace( -- 1164
			"fe_pillar_wood", -- 1164
			"outside_arch_bolt", -- 1164
			(bx0 + bx1) * 0.5, -- 1164
			y0 + 2, -- 1164
			bx1 - bx0, -- 1164
			ah - 2, -- 1164
			{layer = 3} -- 1164
		) -- 1164
		draw:drawSegment( -- 1165
			Vec2((bx0 + bx1) * 0.5, y1), -- 1165
			Vec2((bx0 + bx1) * 0.5, deckY), -- 1165
			2.4, -- 1165
			Color(96, 102, 110, 220) -- 1165
		) -- 1165
	end -- 1165
end -- 1136
return ____exports -- 1136