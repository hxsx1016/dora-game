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
	if solid.id == "s1_well" or solid.art == "well" or (string.find(solid.label, "井背", nil, true) or 0) - 1 >= 0 then -- 54
		return {clip = "well_curb", natAR = 144 / 120, heightMul = 1.12, tileable = false} -- 57
	end -- 57
	if solid.art == "grain_sack" or (string.find(solid.label, "粮台", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "粮袋", nil, true) or 0) - 1 >= 0 then -- 57
		return {clip = "grain_sack", natAR = 144 / 74, heightMul = 1.12, tileable = true} -- 60
	end -- 60
	return nil -- 62
end -- 46
local function coverArt(solid) -- 65
	if solid.art == "gate_post" or solid.art == "wall" then -- 65
		return "wall" -- 67
	end -- 67
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 67
		return "cover_wood" -- 70
	end -- 70
	if solid.art == "fence" then -- 70
		return "fence" -- 73
	end -- 73
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 75
end -- 65
local function tintByShade(base, shade) -- 78
	return Color( -- 79
		math.max( -- 80
			0, -- 80
			math.min( -- 80
				255, -- 80
				math.floor(base.r * shade + 0.5) -- 80
			) -- 80
		), -- 80
		math.max( -- 81
			0, -- 81
			math.min( -- 81
				255, -- 81
				math.floor(base.g * shade + 0.5) -- 81
			) -- 81
		), -- 81
		math.max( -- 82
			0, -- 82
			math.min( -- 82
				255, -- 82
				math.floor(base.b * shade + 0.5) -- 82
			) -- 82
		), -- 82
		base.a -- 83
	) -- 83
end -- 78
____exports.StageRenderer = __TS__Class() -- 87
local StageRenderer = ____exports.StageRenderer -- 87
StageRenderer.name = "StageRenderer" -- 87
function StageRenderer.prototype.____constructor(self) -- 87
end -- 87
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, _time) -- 89
	local w = cam.viewW -- 97
	local h = cam.viewH -- 98
	local theme = themeOf(p.room.key) -- 99
	local span = math.max(1, p.room.maxX - p.room.minX) -- 101
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 102
	local backdropKey = theme.backdropKey or p.room.key -- 103
	local farSlot = "bgFar_" .. backdropKey -- 104
	local backRoadY = cam:sy(0, p.room.depth ~= nil and p.room.depth.max or 0) -- 107
	local artW = math.max(w, h * 16 / 9) * 1.1 -- 108
	local artH = artW * 9 / 16 -- 109
	local artY = math.min( -- 110
		0, -- 110
		math.max(h - artH, backRoadY - artH * 0.25) -- 110
	) -- 110
	if assets:tryPlace( -- 110
		farSlot, -- 111
		"scene", -- 111
		w * (0.5 - progress * 0.08), -- 111
		artY, -- 111
		artW, -- 111
		artH -- 111
	) then -- 111
		self:drawDressing( -- 112
			assets, -- 112
			backdropKey, -- 112
			cam, -- 112
			progress, -- 112
			backRoadY -- 112
		) -- 112
		fillVGradRect( -- 113
			bgDraw, -- 113
			0, -- 113
			0, -- 113
			w, -- 113
			h, -- 113
			toColor(PALETTE.voidDark), -- 113
			toColor(theme.skyMid) -- 113
		) -- 113
		fillVGradRect( -- 114
			bgGlow, -- 114
			0, -- 114
			backRoadY - 2, -- 114
			w, -- 114
			h * 0.14, -- 114
			Color(43, 54, 72, 20), -- 114
			Color(43, 54, 72, 0) -- 114
		) -- 114
		return -- 115
	end -- 115
	local splitY = h * 0.46 -- 119
	fillVGradRect( -- 120
		bgDraw, -- 120
		0, -- 120
		splitY, -- 120
		w, -- 120
		h - splitY, -- 120
		toColor(theme.skyMid), -- 120
		toColor(theme.skyTop) -- 120
	) -- 120
	fillVGradRect( -- 121
		bgDraw, -- 121
		0, -- 121
		0, -- 121
		w, -- 121
		splitY, -- 121
		toColor(theme.skyHorizon), -- 121
		toColor(theme.skyMid) -- 121
	) -- 121
	if theme.showMoon then -- 121
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 123
		local my = h * theme.moonYFrac -- 124
		local mr = math.max(18, h * 0.044) -- 125
		fillRadialGlow( -- 126
			bgGlow, -- 126
			mx, -- 126
			my, -- 126
			mr * 4.6, -- 126
			mr * 4.6, -- 126
			Color(148, 178, 206, 28), -- 126
			Color(20, 32, 52, 0), -- 126
			18 -- 126
		) -- 126
		bgDraw:drawCircle( -- 127
			Vec2(mx, my), -- 127
			mr, -- 127
			Color(218, 232, 242, 215) -- 127
		) -- 127
	end -- 127
	fillVGradRect( -- 129
		bgGlow, -- 130
		0, -- 131
		backRoadY - 10, -- 132
		w, -- 133
		h * 0.3, -- 134
		toColor(theme.fogBottom), -- 135
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 136
	) -- 136
end -- 89
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress, backRoadY) -- 140
	local w = cam.viewW -- 147
	local x = w * (0.76 - progress * 0.24) -- 148
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 148
		assets:tryPlace( -- 151
			"pine", -- 151
			"mid_pine", -- 151
			x, -- 151
			backRoadY - cam:len(4), -- 151
			cam:len(118), -- 151
			cam:len(104), -- 151
			{layer = 1, opacity = 0.48} -- 152
		) -- 152
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 152
		assets:tryPlace( -- 154
			"eaves", -- 154
			"mid_eaves", -- 154
			x, -- 154
			backRoadY - cam:len(4), -- 154
			cam:len(172), -- 154
			cam:len(94), -- 154
			{layer = 1, opacity = 0.44} -- 155
		) -- 155
	elseif backdropKey ~= "gate" then -- 155
		assets:tryPlace( -- 157
			"dp_ruin_house_a", -- 157
			"mid_ruin", -- 157
			x, -- 157
			backRoadY - cam:len(4), -- 157
			cam:len(132), -- 157
			cam:len(118), -- 157
			{layer = 1, opacity = 0.42} -- 158
		) -- 158
	end -- 158
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 158
		assets:tryPlace( -- 161
			"prop_lantern", -- 161
			"mid_lantern", -- 161
			w * (0.27 - progress * 0.2), -- 161
			backRoadY + cam:len(86), -- 162
			cam:len(20), -- 162
			cam:len(28), -- 162
			{layer = 2, opacity = 0.86} -- 162
		) -- 162
	end -- 162
end -- 140
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 167
	local theme = themeOf("checkpoint") -- 174
	local splitY = h * 0.44 -- 175
	fillVGradRect( -- 176
		bgDraw, -- 176
		0, -- 176
		splitY, -- 176
		w, -- 176
		h - splitY, -- 176
		toColor(theme.skyMid), -- 176
		toColor(theme.skyTop) -- 176
	) -- 176
	fillVGradRect( -- 177
		bgDraw, -- 177
		0, -- 177
		0, -- 177
		w, -- 177
		splitY, -- 177
		toColor(theme.skyHorizon), -- 177
		toColor(theme.skyMid) -- 177
	) -- 177
	local mx = w * 0.61 -- 178
	local my = h * 0.74 -- 179
	local mr = h * 0.068 -- 180
	local pulse = 0.86 + 0.14 * math.sin(time * 2) -- 181
	fillRadialGlow( -- 182
		bgGlow, -- 182
		mx, -- 182
		my, -- 182
		mr * 4.4 * pulse, -- 182
		mr * 4.4 * pulse, -- 182
		Color(156, 180, 198, 28), -- 182
		Color(16, 22, 34, 0), -- 182
		20 -- 182
	) -- 182
	bgDraw:drawCircle( -- 183
		Vec2(mx, my), -- 183
		mr, -- 183
		Color(224, 232, 236, 218) -- 183
	) -- 183
	local groundY = h * 0.19 -- 184
	fillVGradRect( -- 185
		bgDraw, -- 185
		0, -- 185
		0, -- 185
		w, -- 185
		groundY, -- 185
		Color(9, 11, 17, 255), -- 185
		Color(18, 23, 33, 255) -- 185
	) -- 185
	bgDraw:drawSegment( -- 186
		Vec2(0, groundY), -- 186
		Vec2(w, groundY), -- 186
		1.4, -- 186
		toColor(PALETTE.silkDim, 145) -- 186
	) -- 186
end -- 167
function StageRenderer.prototype.drawPlayableWorld(self, groundDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt, groundArt, roadLineDraw, overlayDraw) -- 190
	local theme = themeOf(p.room.key) -- 203
	local gArt = groundArt or assets -- 204
	local rLine = roadLineDraw or groundDraw -- 205
	local oDraw = overlayDraw or rLine -- 206
	self:drawFloors( -- 207
		groundDraw, -- 207
		rLine, -- 207
		gArt, -- 207
		p, -- 207
		cam, -- 207
		theme -- 207
	) -- 207
	self:drawStairs( -- 208
		rLine, -- 208
		fgGlow, -- 208
		assets, -- 208
		p, -- 208
		cam, -- 208
		theme -- 208
	) -- 208
	self:drawBoundaryClosures(assets, p, cam) -- 209
	self:drawSolids( -- 210
		rLine, -- 210
		oDraw, -- 210
		fgGlow, -- 210
		assets, -- 210
		p, -- 210
		cam, -- 210
		theme, -- 210
		time, -- 210
		occlusion, -- 210
		fadeDt -- 210
	) -- 210
	if p.room.key == "gate" then -- 210
		self:drawGateShutter( -- 212
			rLine, -- 212
			fgGlow, -- 212
			assets, -- 212
			p, -- 212
			cam, -- 212
			time -- 212
		) -- 212
	end -- 212
	self:drawArch(rLine, assets, p, cam) -- 214
end -- 190
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 218
	fillVGradRect( -- 225
		fgDraw, -- 225
		0, -- 225
		h - h * 0.14, -- 225
		w, -- 225
		h * 0.14, -- 225
		Color(4, 6, 12, 0), -- 225
		Color(4, 6, 12, 118) -- 225
	) -- 225
	fillVGradRect( -- 226
		fgDraw, -- 226
		0, -- 226
		0, -- 226
		w, -- 226
		h * 0.11, -- 226
		Color(4, 6, 12, 152), -- 226
		Color(4, 6, 12, 0) -- 226
	) -- 226
end -- 218
function StageRenderer.prototype.drawBoundaryClosures(self, assets, p, cam) -- 230
	local road = p.room.depth -- 231
	if road == nil then -- 231
		return -- 233
	end -- 233
	if p.room.key == "outside" or p.room.key == "village" or p.room.key == "forest" or p.room.key == "tower" or p.room.key == "museum" then -- 233
		return -- 236
	end -- 236
	local function hasWallNear(targetX) -- 238
		do -- 238
			local i = 0 -- 239
			while i < #p.room.solids do -- 239
				do -- 239
					local s = p.room.solids[i + 1] -- 240
					if s.decorative == true then -- 240
						goto __continue35 -- 241
					end -- 241
					if s.h >= 100 and (math.abs(s.x - targetX) <= 85 or math.abs(s.x + s.w - targetX) <= 85) then -- 241
						return true -- 243
					end -- 243
				end -- 243
				::__continue35:: -- 243
				i = i + 1 -- 239
			end -- 239
		end -- 239
		return false -- 246
	end -- 238
	local minX = p.room.minX -- 248
	local maxX = p.room.maxX -- 249
	local backY = cam:sy(0, road.max) -- 250
	local frontY = cam:sy(0, road.min) -- 251
	local barW = cam:len(46) -- 252
	local barH = cam:len(84) -- 253
	if not hasWallNear(minX) then -- 253
		local lx = cam:sx(minX + 6) -- 255
		if lx + barW > -20 and lx - barW < cam.viewW + 20 then -- 255
			assets:tryPlace( -- 257
				"dp_boundary_barricade", -- 257
				"bound_left_back", -- 257
				lx, -- 257
				backY - cam:len(4), -- 257
				barW * 0.92, -- 257
				barH * 0.92, -- 257
				{ -- 257
					layer = depthOrder(road.max, 0), -- 258
					opacity = 0.88 -- 258
				} -- 258
			) -- 258
			assets:tryPlace( -- 260
				"dp_boundary_barricade", -- 260
				"bound_left_front", -- 260
				lx - cam:len(6), -- 260
				frontY - cam:len(2), -- 260
				barW, -- 260
				barH * 0.72, -- 260
				{ -- 260
					layer = depthOrder(road.min, 0), -- 261
					opacity = 0.94 -- 261
				} -- 261
			) -- 261
		end -- 261
	end -- 261
	if not hasWallNear(maxX) then -- 261
		local rx = cam:sx(maxX - 6) -- 266
		if rx + barW > -20 and rx - barW < cam.viewW + 20 then -- 266
			assets:tryPlace( -- 268
				"dp_boundary_barricade", -- 268
				"bound_right_back", -- 268
				rx, -- 268
				backY - cam:len(4), -- 268
				barW * 0.92, -- 268
				barH * 0.92, -- 268
				{ -- 268
					layer = depthOrder(road.max, 0), -- 269
					opacity = 0.88, -- 269
					facing = -1 -- 269
				} -- 269
			) -- 269
			assets:tryPlace( -- 271
				"dp_boundary_barricade", -- 271
				"bound_right_front", -- 271
				rx + cam:len(6), -- 271
				frontY - cam:len(2), -- 271
				barW, -- 271
				barH * 0.72, -- 271
				{ -- 271
					layer = depthOrder(road.min, 0), -- 272
					opacity = 0.94, -- 272
					facing = -1 -- 272
				} -- 272
			) -- 272
		end -- 272
	end -- 272
end -- 230
function StageRenderer.prototype.drawFloors(self, groundDraw, roadLineDraw, groundArt, p, cam, theme) -- 278
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 286
	do -- 286
		local i = 0 -- 287
		while i < #p.room.floors do -- 287
			local floor = p.room.floors[i + 1] -- 288
			local left = cam:sx(floor.x0) -- 289
			local right = cam:sx(floor.x1) -- 290
			local isMain = floor.y <= 0.1 -- 291
			local ____isMain_0 -- 292
			if isMain then -- 292
				____isMain_0 = p.room.depth -- 292
			else -- 292
				____isMain_0 = nil -- 292
			end -- 292
			local road = ____isMain_0 -- 292
			local top = cam:sy(floor.y, road and road.min or 0) -- 293
			if road ~= nil then -- 293
				self:drawRoad( -- 295
					groundDraw, -- 295
					roadLineDraw, -- 295
					groundArt, -- 295
					i, -- 295
					left, -- 295
					right, -- 295
					top, -- 295
					cam:sy(floor.y, road.max), -- 295
					road, -- 295
					cam, -- 295
					theme -- 295
				) -- 295
			end -- 295
			local height = cam:len(isMain and 22 or 12) -- 297
			local bottom = top - height -- 298
			if isMain and bottom > 0 then -- 298
				fillVGradRect( -- 300
					groundDraw, -- 300
					left, -- 300
					0, -- 300
					right - left, -- 300
					bottom + 1, -- 300
					toColor(PALETTE.voidDark), -- 301
					toColor(theme.groundBody) -- 301
				) -- 301
			end -- 301
			local step = cam:len(96) -- 303
			local start = math.max( -- 304
				0, -- 304
				math.floor(-left / step) -- 304
			) -- 304
			do -- 304
				local j = start -- 305
				while left + j * step < math.min(right, cam.viewW) do -- 305
					local x = left + j * step -- 306
					local width = math.min(step, right - x) -- 307
					groundArt:tryPlace( -- 308
						"slab", -- 308
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 308
						x + width * 0.5, -- 308
						bottom, -- 308
						width + 0.5, -- 308
						height, -- 308
						{layer = 3} -- 308
					) -- 308
					if grass and isMain and j % 3 == 1 then -- 308
						groundArt:tryPlace( -- 310
							"grass_low", -- 310
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 310
							x + width * 0.5, -- 310
							top - cam:len(3), -- 311
							width * 0.74, -- 311
							cam:len(13), -- 311
							{opacity = 0.85, layer = 5} -- 311
						) -- 311
					end -- 311
					j = j + 1 -- 305
				end -- 305
			end -- 305
			roadLineDraw:drawSegment( -- 314
				Vec2(left, top), -- 314
				Vec2(right, top), -- 314
				1.2, -- 314
				toColor(theme.groundRim, 160) -- 314
			) -- 314
			i = i + 1 -- 287
		end -- 287
	end -- 287
end -- 278
function StageRenderer.prototype.drawRoad(self, groundDraw, roadLineDraw, groundArt, floorIdx, left, right, front, back, road, cam, theme) -- 324
	local width = right - left -- 337
	local height = back - front -- 338
	if width <= 1 or height <= 1 then -- 338
		return -- 340
	end -- 340
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.36) -- 342
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.52) -- 343
	fillVGradRect( -- 344
		groundDraw, -- 344
		left, -- 344
		front, -- 344
		width, -- 344
		height, -- 344
		toColor(nearCol), -- 344
		toColor(farCol) -- 344
	) -- 344
	local visLeft = math.max(left, -96) -- 346
	local visRight = math.min(right, cam.viewW + 96) -- 347
	local lanes = { -- 350
		{ -- 351
			slot = "dp_road_lower", -- 351
			f0 = 0, -- 351
			f1 = 0.34, -- 351
			tileW = cam:len(104) -- 351
		}, -- 351
		{ -- 352
			slot = "dp_road_mid", -- 352
			f0 = 0.34, -- 352
			f1 = 0.68, -- 352
			tileW = cam:len(96) -- 352
		}, -- 352
		{ -- 353
			slot = "dp_road_upper", -- 353
			f0 = 0.68, -- 353
			f1 = 1, -- 353
			tileW = cam:len(86) -- 353
		} -- 353
	} -- 353
	do -- 353
		local li = 0 -- 355
		while li < #lanes do -- 355
			local ln = lanes[li + 1] -- 356
			local y0 = front + ln.f0 * height -- 357
			local y1 = front + ln.f1 * height -- 358
			local lh = y1 - y0 -- 359
			local twBase = math.max(48, ln.tileW) -- 360
			local tStart = math.max( -- 361
				0, -- 361
				math.floor((visLeft - left) / twBase) -- 361
			) -- 361
			do -- 361
				local col = tStart -- 362
				while left + col * twBase < visRight do -- 362
					do -- 362
						local tx0 = left + col * twBase -- 363
						local tw = math.min(twBase, right - tx0) -- 364
						if tw <= 2 then -- 364
							goto __continue55 -- 365
						end -- 365
						groundArt:tryPlace( -- 366
							ln.slot, -- 366
							(((("road_lane_" .. tostring(floorIdx)) .. "_") .. tostring(li)) .. "_") .. tostring(col), -- 366
							tx0 + tw * 0.5, -- 366
							y0, -- 366
							tw + 0.8, -- 366
							lh + 0.8, -- 366
							{layer = 2, opacity = 0.96} -- 366
						) -- 366
					end -- 366
					::__continue55:: -- 366
					col = col + 1 -- 362
				end -- 362
			end -- 362
			li = li + 1 -- 355
		end -- 355
	end -- 355
	local curbW = math.max( -- 374
		48, -- 374
		cam:len(96) -- 374
	) -- 374
	local curbH = math.max( -- 375
		5, -- 375
		cam:len(7) -- 375
	) -- 375
	local cStart = math.max( -- 376
		0, -- 376
		math.floor((visLeft - left) / curbW) -- 376
	) -- 376
	do -- 376
		local col = cStart -- 377
		while left + col * curbW < visRight do -- 377
			do -- 377
				local tx0 = left + col * curbW -- 378
				local tw = math.min(curbW, right - tx0) -- 379
				if tw <= 2 then -- 379
					goto __continue58 -- 380
				end -- 380
				groundArt:tryPlace( -- 381
					"dp_road_curb", -- 381
					(("road_curb_" .. tostring(floorIdx)) .. "_") .. tostring(col), -- 381
					tx0 + tw * 0.5, -- 381
					front - curbH * 0.35, -- 381
					tw + 0.8, -- 381
					curbH, -- 381
					{layer = 4} -- 381
				) -- 381
			end -- 381
			::__continue58:: -- 381
			col = col + 1 -- 377
		end -- 377
	end -- 377
	local jointDark = Color(8, 11, 18, 138) -- 387
	local laneHint = Color(138, 166, 188, 44) -- 388
	local vpX = cam.viewW * 0.5 -- 389
	local stepWorld = 64 -- 390
	local firstJoint = math.floor((cam.x - cam.viewW * 0.65 / cam.ppu) / stepWorld) -- 391
	local lastJoint = math.ceil((cam.x + cam.viewW * 0.65 / cam.ppu) / stepWorld) -- 392
	do -- 392
		local j = firstJoint -- 393
		while j <= lastJoint do -- 393
			do -- 393
				local xFront = cam:sx(j * stepWorld) -- 394
				if xFront < left - 60 or xFront > right + 60 then -- 394
					goto __continue61 -- 395
				end -- 395
				local xBack = vpX + (xFront - vpX) * cam:depthScale(road.max, true) -- 397
				local cFront = math.max( -- 398
					left, -- 398
					math.min(right, xFront) -- 398
				) -- 398
				local cBack = math.max( -- 399
					left, -- 399
					math.min(right, xBack) -- 399
				) -- 399
				roadLineDraw:drawSegment( -- 400
					Vec2(cFront, front), -- 400
					Vec2(cBack, back), -- 400
					1, -- 400
					jointDark -- 400
				) -- 400
			end -- 400
			::__continue61:: -- 400
			j = j + 1 -- 393
		end -- 393
	end -- 393
	for ____, frac in ipairs({0.34, 0.68}) do -- 404
		local ly = front + frac * height -- 405
		roadLineDraw:drawSegment( -- 406
			Vec2(left, ly), -- 406
			Vec2(right, ly), -- 406
			1, -- 406
			jointDark -- 406
		) -- 406
		roadLineDraw:drawSegment( -- 407
			Vec2(left, ly + 1.1), -- 407
			Vec2(right, ly + 1.1), -- 407
			0.7, -- 407
			laneHint -- 407
		) -- 407
	end -- 407
	fillVGradRect( -- 410
		roadLineDraw, -- 410
		left, -- 410
		back - math.max(4, height * 0.14), -- 410
		width, -- 410
		math.max(4, height * 0.14), -- 410
		Color(6, 8, 14, 0), -- 411
		Color(6, 8, 14, 155) -- 411
	) -- 411
	roadLineDraw:drawSegment( -- 412
		Vec2(left, front), -- 412
		Vec2(right, front), -- 412
		1.5, -- 412
		toColor(theme.groundRim, 168) -- 412
	) -- 412
	roadLineDraw:drawSegment( -- 413
		Vec2(left, back), -- 413
		Vec2(right, back), -- 413
		1.3, -- 413
		Color(118, 144, 166, 95) -- 413
	) -- 413
end -- 324
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 416
	local i = 0 -- 424
	do -- 424
		i = 0 -- 425
		while i < #p.room.stairs do -- 425
			local st = p.room.stairs[i + 1] -- 426
			local n = st.steps + 1 -- 427
			local stepW = (st.x1 - st.x0) / n -- 428
			local depthEnabled = p.room.depth ~= nil -- 429
			local dMin = depthEnabled and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 430
			local dMax = depthEnabled and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 433
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 436
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 437
			local stairLayer = depthEnabled and depthOrder(dMin, 0) or 0 -- 438
			local k = 0 -- 439
			do -- 439
				k = 0 -- 440
				while k < n do -- 440
					do -- 440
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 441
						local wx0 = st.x0 + stepW * k -- 442
						local wx1 = wx0 + stepW -- 443
						local x0 = cam:sx(wx0) -- 444
						local x1 = cam:sx(wx1) -- 445
						if x1 < 0 or x0 > cam.viewW then -- 445
							goto __continue69 -- 447
						end -- 447
						local y1 = cam:sy(wy, dMin) -- 449
						local y0 = cam:sy(baseWorldY, dMin) -- 450
						local yRear = cam:sy(wy, dMax) -- 451
						local sw = x1 - x0 -- 452
						local cx = (x0 + x1) * 0.5 -- 453
						if yRear > y1 + 1 then -- 453
							assets:tryPlace( -- 456
								"dp_stone_top", -- 456
								(("stairs_cap_" .. tostring(i)) .. "_") .. tostring(k), -- 456
								cx, -- 456
								y1, -- 456
								sw + 0.8, -- 456
								yRear - y1 + 0.5, -- 456
								{layer = stairLayer, opacity = 0.96} -- 456
							) -- 456
						end -- 456
						local riserH = y1 - y0 -- 461
						if riserH > 2 then -- 461
							local courseH = math.max( -- 463
								12, -- 463
								cam:len(14) -- 463
							) -- 463
							local courses = math.max( -- 464
								1, -- 464
								math.min( -- 464
									8, -- 464
									math.ceil(riserH / courseH) -- 464
								) -- 464
							) -- 464
							local ch = riserH / courses -- 465
							do -- 465
								local ci = 0 -- 466
								while ci < courses do -- 466
									local slotName = ci == courses - 1 and "dp_stair_step" or "wall" -- 467
									assets:tryPlace( -- 468
										slotName, -- 468
										(((("stairs_" .. tostring(i)) .. "_") .. tostring(k)) .. "_") .. tostring(ci), -- 468
										cx, -- 468
										y0 + ci * ch, -- 468
										sw + 0.8, -- 468
										ch + 0.6, -- 468
										{ -- 468
											layer = stairLayer + 1, -- 469
											color = ci == courses - 1 and Color(246, 250, 255, 255) or Color(196, 206, 218, 255) -- 470
										} -- 470
									) -- 470
									ci = ci + 1 -- 466
								end -- 466
							end -- 466
						end -- 466
						fgDraw:drawSegment( -- 474
							Vec2(x0, y1), -- 474
							Vec2(x1, y1), -- 474
							1.4, -- 474
							toColor(theme.groundRim, 165) -- 474
						) -- 474
						fgGlow:drawSegment( -- 475
							Vec2(x0, y1 + 1), -- 475
							Vec2(x1, y1 + 1), -- 475
							0.8, -- 475
							toColor(theme.accent, 42) -- 475
						) -- 475
					end -- 475
					::__continue69:: -- 475
					k = k + 1 -- 440
				end -- 440
			end -- 440
			i = i + 1 -- 425
		end -- 425
	end -- 425
end -- 416
function StageRenderer.prototype.isSolidActive(self, p, s) -- 481
	local matched = false -- 482
	local anyVisible = false -- 483
	local i = 0 -- 484
	do -- 484
		i = 0 -- 485
		while i < #p.boxes do -- 485
			local b = p.boxes[i + 1] -- 486
			local sameId = s.id ~= nil and b.id == s.id -- 487
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 488
			if sameId or sameGeom then -- 488
				matched = true -- 492
				if b.broken ~= true and b.hidden ~= true then -- 492
					anyVisible = true -- 494
				end -- 494
			end -- 494
			i = i + 1 -- 485
		end -- 485
	end -- 485
	return not matched or anyVisible -- 498
end -- 481
function StageRenderer.prototype.drawSolids(self, fgDraw, overlayDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 501
	local i = 0 -- 513
	do -- 513
		i = 0 -- 514
		while i < #p.room.solids do -- 514
			do -- 514
				local s = p.room.solids[i + 1] -- 515
				if s.decorative == true then -- 515
					if p.room.depth ~= nil and (s.art == "stove_hearth" or s.art == "well") then -- 515
						local bx = cam:sx(s.x + s.w * 0.5) -- 519
						if bx > -80 and bx < cam.viewW + 80 then -- 519
							local backDepth = p.room.depth.max -- 521
							local by = cam:sy(0, backDepth) -- 522
							local dLayer = depthOrder(backDepth, -2) -- 523
							local dScale = cam:depthScale(backDepth, true) -- 524
							assets:tryPlace( -- 525
								"dp_shadow_contact", -- 525
								"decor_sh_" .. tostring(i), -- 525
								bx, -- 525
								by, -- 525
								cam:len(s.w * 1.15) * dScale, -- 525
								cam:len(7) * dScale, -- 525
								{layer = dLayer - 1, opacity = 0.72} -- 525
							) -- 525
							if s.art == "stove_hearth" then -- 525
								assets:tryPlace( -- 529
									"dp_stove_hearth", -- 529
									"decor_stove_" .. tostring(i), -- 529
									bx, -- 529
									by, -- 529
									cam:len(s.w * 1.1) * dScale, -- 529
									cam:len(28) * dScale, -- 529
									{layer = dLayer} -- 529
								) -- 529
							else -- 529
								assets:tryPlacePath( -- 533
									"assets/art/props_ming.clip|well_curb", -- 533
									"decor_well_" .. tostring(i), -- 533
									bx, -- 533
									by, -- 533
									cam:len(s.w * 1.25) * dScale, -- 533
									cam:len(34) * dScale, -- 533
									{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = dLayer} -- 533
								) -- 533
							end -- 533
						end -- 533
					end -- 533
					goto __continue82 -- 539
				end -- 539
				if s.id == "e3_bench" or s.id == "tower_desk" then -- 539
					goto __continue82 -- 542
				end -- 542
				if not self:isSolidActive(p, s) then -- 542
					goto __continue82 -- 546
				end -- 546
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 546
					goto __continue82 -- 550
				end -- 550
				local x0 = cam:sx(s.x) -- 552
				local x1 = cam:sx(s.x + s.w) -- 553
				if p.room.depth ~= nil and s.depth ~= nil then -- 553
					local opacity = occlusion:update( -- 555
						"solid_" .. tostring(i), -- 555
						{ -- 555
							x0 = s.x, -- 556
							x1 = s.x + s.w, -- 556
							y0 = s.y, -- 556
							y1 = s.y + s.h, -- 556
							depth = s.depth, -- 557
							passThrough = s.passable == true or s.soft == true -- 557
						}, -- 557
						p, -- 558
						fadeDt -- 558
					) -- 558
					if x1 > 0 and x0 < cam.viewW then -- 558
						self:drawDepthSolid( -- 560
							fgDraw, -- 560
							overlayDraw, -- 560
							fgGlow, -- 560
							assets, -- 560
							s, -- 560
							s.depth, -- 560
							x0, -- 560
							x1, -- 560
							cam, -- 560
							theme, -- 560
							opacity, -- 560
							p -- 560
						) -- 560
					end -- 560
					goto __continue82 -- 562
				end -- 562
				local y0 = cam:sy(s.y) -- 564
				local y1 = cam:sy(s.y + s.h) -- 565
				local sw = x1 - x0 -- 566
				local sh = y1 - y0 -- 567
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 567
					goto __continue82 -- 569
				end -- 569
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 569
					local groundY = cam:sy(0) -- 574
					local pierW = cam:len(16) -- 575
					assets:tryPlace( -- 576
						"dp_wall_side", -- 576
						"outside_pier_l_" .. tostring(i), -- 576
						x0 + pierW * 0.5, -- 576
						groundY, -- 576
						pierW, -- 576
						y0 - groundY, -- 576
						{layer = 0} -- 576
					) -- 576
					assets:tryPlace( -- 577
						"dp_wall_side", -- 577
						"outside_pier_r_" .. tostring(i), -- 577
						x1 - pierW * 0.5, -- 577
						groundY, -- 577
						pierW, -- 577
						y0 - groundY, -- 577
						{layer = 0} -- 577
					) -- 577
				end -- 577
				if s.passable == true then -- 577
					if not assets:tryPlace( -- 577
						"grass", -- 582
						"hide_grass_" .. tostring(i), -- 582
						(x0 + x1) * 0.5, -- 582
						y0, -- 582
						sw, -- 582
						sh * 1.55, -- 582
						{opacity = 0.85, layer = 7} -- 583
					) then -- 583
						self:drawGrassCluster( -- 584
							fgDraw, -- 584
							fgGlow, -- 584
							x0, -- 584
							y0, -- 584
							sw, -- 584
							sh, -- 584
							p.player.x, -- 584
							s.x + s.w * 0.5, -- 584
							time -- 584
						) -- 584
					end -- 584
					goto __continue82 -- 586
				end -- 586
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 586
					self:drawWinch( -- 591
						fgDraw, -- 591
						assets, -- 591
						x0, -- 591
						y0, -- 591
						sw, -- 591
						sh, -- 591
						p, -- 591
						2 -- 591
					) -- 591
					goto __continue82 -- 592
				end -- 592
				if p.room.key == "tower" then -- 592
					self:drawTowerStructure( -- 597
						fgDraw, -- 597
						fgGlow, -- 597
						assets, -- 597
						x0, -- 597
						y0, -- 597
						sw, -- 597
						sh, -- 597
						s, -- 597
						p, -- 597
						cam, -- 597
						time -- 597
					) -- 597
					goto __continue82 -- 598
				end -- 598
				if s.art == "red_cart" then -- 598
					assets:tryPlace( -- 603
						"dp_shadow_contact", -- 603
						"red_cart_sh", -- 603
						(x0 + x1) * 0.5, -- 603
						y0 + 1, -- 603
						sw * 1.25, -- 603
						cam:len(8), -- 603
						{layer = 1, opacity = 0.82} -- 603
					) -- 603
					assets:tryPlace( -- 604
						"dp_red_cart", -- 604
						"red_cart_sprite", -- 604
						(x0 + x1) * 0.5, -- 604
						y0, -- 604
						sw * 1.38, -- 604
						sh * 1.15, -- 604
						{layer = 2} -- 604
					) -- 604
					goto __continue82 -- 605
				end -- 605
				if s.h <= 64 and s.y <= 2 then -- 605
					self:drawCoverBlock( -- 610
						overlayDraw, -- 610
						fgGlow, -- 610
						assets, -- 610
						x0, -- 610
						y0, -- 610
						sw, -- 610
						sh, -- 610
						s, -- 610
						p, -- 610
						theme -- 610
					) -- 610
					goto __continue82 -- 611
				end -- 611
				self:tileMasonry( -- 614
					assets, -- 614
					s, -- 614
					x0, -- 614
					y0, -- 614
					sw, -- 614
					sh -- 614
				) -- 614
			end -- 614
			::__continue82:: -- 614
			i = i + 1 -- 514
		end -- 514
	end -- 514
end -- 501
function StageRenderer.prototype.drawDepthSolid(self, draw, overlayDraw, fgGlow, assets, solid, depth, left, right, cam, theme, opacity, p) -- 618
	local width = right - left -- 632
	local base = cam:sy(solid.y, depth.min) -- 633
	local top = cam:sy(solid.y + solid.h, depth.min) -- 634
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 635
	local frontH = top - base -- 636
	local slot = coverArt(solid) -- 637
	local layer = depthOrder(depth.min, 1) -- 638
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 639
	local capHeight = rear - top -- 640
	local center = (left + right) * 0.5 -- 641
	local dShade = cam:depthShade(depth.min, true) -- 642
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 642
		assets:tryPlace( -- 646
			"dp_shadow_contact", -- 646
			"winch_sh_" .. tostring(solid.x), -- 646
			center, -- 646
			base + 1, -- 646
			width * 1.18, -- 646
			cam:len(10), -- 646
			{layer = layer - 1, opacity = 0.82 * opacity} -- 646
		) -- 646
		self:drawWinch( -- 649
			draw, -- 649
			assets, -- 649
			left, -- 649
			base, -- 649
			width, -- 649
			frontH, -- 649
			p, -- 649
			layer -- 649
		) -- 649
		return -- 650
	end -- 650
	if solid.art == "latch" then -- 650
		local groundY = cam:sy(0, depth.min) -- 655
		local postH = math.max(frontH, top - groundY) -- 656
		assets:tryPlace( -- 657
			"dp_shadow_contact", -- 657
			"latch_sh_" .. tostring(solid.x), -- 657
			center, -- 657
			groundY + 1, -- 657
			width * 1.1, -- 657
			cam:len(8), -- 657
			{layer = layer - 1, opacity = 0.78 * opacity} -- 657
		) -- 657
		assets:tryPlace( -- 660
			"fe_pillar_wood", -- 660
			"latch_post_" .. tostring(solid.x), -- 660
			right - cam:len(6), -- 660
			groundY, -- 660
			cam:len(12), -- 660
			postH + cam:len(10), -- 660
			{ -- 660
				layer = layer, -- 661
				opacity = opacity, -- 661
				color = occlusionTint(opacity) -- 661
			} -- 661
		) -- 661
		assets:tryPlace( -- 663
			"dp_latch", -- 663
			key, -- 663
			center, -- 663
			base - cam:len(4), -- 663
			math.max( -- 663
				width * 1.3, -- 663
				cam:len(36) -- 663
			), -- 663
			math.max( -- 663
				frontH * 1.3, -- 663
				cam:len(32) -- 663
			), -- 663
			{ -- 663
				layer = layer + 1, -- 664
				opacity = opacity, -- 664
				color = occlusionTint(opacity) -- 664
			} -- 664
		) -- 664
		fillRadialGlow( -- 666
			fgGlow, -- 666
			center - cam:len(6), -- 666
			base + frontH * 0.5, -- 666
			cam:len(18), -- 666
			cam:len(14), -- 666
			Color( -- 667
				238, -- 667
				168, -- 667
				72, -- 667
				math.floor(58 * opacity + 0.5) -- 667
			), -- 667
			Color(238, 168, 72, 0), -- 667
			10 -- 667
		) -- 667
		return -- 668
	end -- 668
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 668
		assets:tryPlace( -- 672
			"slab", -- 672
			"gate_sill_" .. tostring(solid.x), -- 672
			center, -- 672
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 672
			width + cam:len(34), -- 673
			cam:len(12), -- 673
			{ -- 673
				layer = 1, -- 673
				color = Color(180, 169, 150, 255) -- 673
			} -- 673
		) -- 673
		if p.room.key ~= "gate" then -- 673
			local beamY = cam:sy(solid.y + solid.h - 10, LANE_DEPTH.lower) -- 676
			local beamW = math.max( -- 677
				width * 2.8, -- 677
				cam:len(92) -- 677
			) -- 677
			local beamH = cam:len(26) -- 678
			assets:tryPlace( -- 679
				"dp_gate_arch_beam", -- 679
				"gate_beam_" .. tostring(solid.x), -- 679
				center, -- 679
				beamY, -- 679
				beamW, -- 679
				beamH, -- 679
				{ -- 679
					layer = depthOrder(LANE_DEPTH.lower, 3), -- 680
					opacity = math.min(1, opacity + 0.12) -- 681
				} -- 681
			) -- 681
		end -- 681
	end -- 681
	local shadowH = math.max( -- 687
		cam:len(6), -- 687
		cam:sy(solid.y, depth.max) - base + cam:len(5) -- 687
	) -- 687
	assets:tryPlace( -- 688
		"dp_shadow_contact", -- 688
		(("solid_sh_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 688
		center, -- 688
		base + shadowH * 0.32, -- 688
		width * 1.14, -- 689
		shadowH * 1.15, -- 689
		{layer = layer - 1, opacity = 0.78 * opacity} -- 689
	) -- 689
	local propArt = dedicatedSolidProp(solid) -- 695
	if propArt ~= nil then -- 695
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 697
		local drawH = frontH * propArt.heightMul -- 698
		local cols = propArt.tileable and math.max( -- 699
			1, -- 700
			math.min( -- 700
				6, -- 700
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 700
			) -- 700
		) or 1 -- 700
		local colW = width / cols -- 702
		local tint = occlusionTint( -- 703
			opacity, -- 703
			tintByShade( -- 703
				Color(238, 240, 246, 255), -- 703
				dShade -- 703
			) -- 703
		) -- 703
		local placedProp = false -- 704
		do -- 704
			local col = 0 -- 705
			while col < cols do -- 705
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 706
				if assets:tryPlacePath( -- 706
					propPath, -- 707
					tileKey, -- 707
					left + (col + 0.5) * colW, -- 707
					base, -- 707
					colW + 1, -- 707
					drawH, -- 707
					{ -- 707
						anchorX = 0.5, -- 708
						anchorY = 0, -- 709
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 710
						opacity = opacity, -- 711
						color = tint, -- 712
						layer = layer -- 713
					} -- 713
				) then -- 713
					placedProp = true -- 715
				end -- 715
				col = col + 1 -- 705
			end -- 705
		end -- 705
		if placedProp then -- 705
			return -- 719
		end -- 719
	end -- 719
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 723
	local isStoneCover = slot == "cover_stone" -- 724
	local isSoftCloth = solid.soft == true or solid.art == "curtain" -- 725
	local visCapH = solid.y >= 100 and math.min( -- 726
		capHeight, -- 726
		cam:len(10) -- 726
	) or capHeight -- 726
	if slot ~= "fence" and not isSoftCloth and visCapH > 2 and frontH > 8 then -- 726
		local viewShift = (cam.viewW * 0.5 - center) / math.max(240, cam.viewW * 0.5) -- 730
		local sidePx = math.min( -- 731
			cam:len(14), -- 731
			math.abs(viewShift) * visCapH * 0.65 -- 731
		) -- 731
		if sidePx >= 2.2 then -- 731
			local sideSlot = timber and "dp_wood_side" or (isStoneCover and "dp_stone_side" or "dp_wall_side") -- 733
			local sideX = viewShift > 0 and right + sidePx * 0.5 or left - sidePx * 0.5 -- 734
			assets:tryPlace( -- 735
				sideSlot, -- 735
				(("side_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 735
				sideX, -- 735
				base + visCapH * 0.35, -- 735
				sidePx + 0.6, -- 735
				frontH, -- 735
				{ -- 735
					layer = layer - 1, -- 736
					opacity = math.min(1, opacity * 0.92), -- 737
					color = occlusionTint( -- 738
						opacity, -- 738
						tintByShade( -- 738
							Color(210, 218, 228, 255), -- 738
							dShade -- 738
						) -- 738
					) -- 738
				} -- 738
			) -- 738
		end -- 738
	end -- 738
	if isSoftCloth then -- 738
		assets:tryPlace( -- 745
			"fe_beam_wood", -- 745
			(("cap_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 745
			center, -- 745
			top - 1, -- 745
			width + 4, -- 745
			math.max( -- 745
				3, -- 745
				cam:len(4) -- 745
			), -- 745
			{ -- 745
				opacity = math.min(1, opacity), -- 746
				color = occlusionTint( -- 747
					opacity, -- 747
					Color(148, 122, 96, 255) -- 747
				), -- 747
				layer = layer + 1 -- 748
			} -- 748
		) -- 748
	elseif slot ~= "fence" and visCapH > 1 then -- 748
		local capSlot = timber and "dp_wood_top" or (isStoneCover and "dp_stone_top" or "dp_wall_top") -- 751
		local capTint = occlusionTint( -- 752
			opacity, -- 752
			tintByShade( -- 752
				Color(246, 248, 252, 255), -- 752
				dShade -- 752
			) -- 752
		) -- 752
		assets:tryPlace( -- 753
			capSlot, -- 753
			(("cap_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 753
			center, -- 753
			top - 0.5, -- 753
			width + 0.6, -- 753
			visCapH + 1, -- 753
			{ -- 753
				opacity = math.min(1, opacity), -- 754
				color = capTint, -- 755
				layer = layer -- 756
			} -- 756
		) -- 756
	end -- 756
	if timber and solid.h > solid.w * 1.6 then -- 756
		local segs = math.max( -- 762
			1, -- 762
			math.min( -- 762
				6, -- 762
				math.floor(solid.h / math.max(24, solid.w * 3.5) + 0.5) -- 762
			) -- 762
		) -- 762
		local segH = frontH / segs -- 763
		local colTint = occlusionTint( -- 764
			opacity, -- 764
			tintByShade( -- 764
				Color(255, 255, 255, 255), -- 764
				dShade -- 764
			) -- 764
		) -- 764
		do -- 764
			local pi = 0 -- 765
			while pi < segs do -- 765
				local tk = pi == 0 and key or (key .. "_p") .. tostring(pi) -- 766
				assets:tryPlace( -- 767
					"fe_pillar_wood", -- 767
					tk, -- 767
					center, -- 767
					base + pi * segH, -- 767
					width + 0.5, -- 767
					segH + 0.5, -- 767
					{layer = layer, opacity = opacity, color = colTint} -- 767
				) -- 767
				pi = pi + 1 -- 765
			end -- 765
		end -- 765
		return -- 771
	end -- 771
	if solid.w > solid.h * 5 then -- 771
		local segs = math.max( -- 776
			2, -- 776
			math.min( -- 776
				12, -- 776
				math.floor(solid.w / 64 + 0.5) -- 776
			) -- 776
		) -- 776
		local segW = width / segs -- 777
		local beamH = math.max(5, frontH) -- 778
		local beamTint = occlusionTint( -- 779
			opacity, -- 779
			tintByShade( -- 779
				Color(255, 255, 255, 255), -- 779
				dShade -- 779
			) -- 779
		) -- 779
		do -- 779
			local bi = 0 -- 780
			while bi < segs do -- 780
				local tk = bi == 0 and key or (key .. "_b") .. tostring(bi) -- 781
				assets:tryPlace( -- 782
					"fe_beam_wood", -- 782
					tk, -- 782
					left + (bi + 0.5) * segW, -- 782
					base, -- 782
					segW + 0.5, -- 782
					beamH, -- 782
					{layer = layer, opacity = opacity, color = beamTint} -- 782
				) -- 782
				bi = bi + 1 -- 780
			end -- 780
		end -- 780
		return -- 786
	end -- 786
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 790
	local cols = slot == "wall" and math.max( -- 791
		1, -- 792
		math.min( -- 792
			10, -- 792
			math.floor(solid.w / 72 + 0.5) -- 792
		) -- 792
	) or math.max( -- 792
		1, -- 793
		math.min( -- 793
			10, -- 793
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 793
		) -- 793
	) -- 793
	local colW = width / cols -- 794
	local rows = slot == "wall" and math.max( -- 795
		1, -- 796
		math.min( -- 796
			10, -- 796
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 796
		) -- 796
	) or math.max( -- 796
		1, -- 797
		math.min( -- 797
			6, -- 797
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 797
		) -- 797
	) -- 797
	local rowHeight = frontH / rows -- 798
	local baseColor = slot == "wall" and Color(216, 224, 234, 255) or Color(255, 255, 255, 255) -- 799
	local color = occlusionTint( -- 800
		opacity, -- 800
		tintByShade(baseColor, dShade) -- 800
	) -- 800
	do -- 800
		local row = 0 -- 801
		while row < rows do -- 801
			do -- 801
				local col = 0 -- 802
				while col < cols do -- 802
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 803
					assets:tryPlace( -- 804
						slot, -- 804
						tileKey, -- 804
						left + (col + 0.5) * colW, -- 804
						base + row * rowHeight, -- 804
						colW + 0.5, -- 804
						rowHeight + 0.5, -- 804
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 804
					) -- 804
					col = col + 1 -- 802
				end -- 802
			end -- 802
			row = row + 1 -- 801
		end -- 801
	end -- 801
	if not p.childMode and solid.h <= 64 and solid.y <= 2 and (p.coverHug or p.coverNear) then -- 801
		local plx = p.player.x -- 812
		local nearLeft = math.abs(plx - solid.x) < 42 -- 813
		local nearRight = math.abs(plx - (solid.x + solid.w)) < 42 -- 814
		if (nearLeft or nearRight) and math.abs(p.player.depth - (depth.min + depth.max) * 0.5) <= 28 then -- 814
			local edgeX = nearLeft and left - 1.5 or right + 1.5 -- 816
			local col = p.coverHug and (timber and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 817
			overlayDraw:drawSegment( -- 818
				Vec2(edgeX, base + 3), -- 818
				Vec2(edgeX, top + 2), -- 818
				p.coverHug and 2.2 or 1.3, -- 818
				toColor(col, p.coverHug and 220 or 125) -- 818
			) -- 818
		end -- 818
	end -- 818
end -- 618
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 823
	local columns = math.max( -- 828
		1, -- 828
		math.min( -- 828
			10, -- 828
			math.floor(s.w / 58 + 0.5) -- 828
		) -- 828
	) -- 828
	local cellWorldW = s.w / columns -- 829
	local targetCellH = math.max( -- 830
		24, -- 830
		math.min(48, cellWorldW / 1.52) -- 830
	) -- 830
	local rows = math.max( -- 831
		1, -- 831
		math.min( -- 831
			12, -- 831
			math.floor(s.h / targetCellH + 0.5) -- 831
		) -- 831
	) -- 831
	local tileW = width / columns -- 832
	local tileH = height / rows -- 833
	do -- 833
		local row = 0 -- 834
		while row < rows do -- 834
			do -- 834
				local column = 0 -- 835
				while column < columns do -- 835
					assets:tryPlace( -- 836
						"wall", -- 836
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 836
						x + (column + 0.5) * tileW, -- 837
						y + row * tileH, -- 837
						tileW + 0.5, -- 837
						tileH + 0.5, -- 837
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 838
					) -- 838
					column = column + 1 -- 835
				end -- 835
			end -- 835
			row = row + 1 -- 834
		end -- 834
	end -- 834
end -- 823
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 843
	local slot = coverArt(s) -- 850
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 851
	local cols = math.max( -- 852
		1, -- 852
		math.min( -- 852
			8, -- 852
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 852
		) -- 852
	) -- 852
	local tileW = sw / cols -- 853
	local placed = false -- 854
	do -- 854
		local c = 0 -- 855
		while c < cols do -- 855
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 856
			if assets:tryPlace( -- 856
				slot, -- 857
				k, -- 857
				x0 + (c + 0.5) * tileW, -- 857
				y0, -- 857
				tileW + 0.5, -- 857
				sh, -- 857
				{layer = 1} -- 857
			) then -- 857
				placed = true -- 858
			end -- 858
			c = c + 1 -- 855
		end -- 855
	end -- 855
	if not placed then -- 855
		fillVGradRect( -- 862
			fgDraw, -- 862
			x0, -- 862
			y0, -- 862
			sw, -- 862
			sh, -- 862
			toColor(PALETTE.steelDark), -- 862
			toColor(PALETTE.steelMid) -- 862
		) -- 862
		fgDraw:drawSegment( -- 863
			Vec2(x0, y0 + sh), -- 863
			Vec2(x0 + sw, y0 + sh), -- 863
			1.4, -- 863
			toColor(theme.groundRim) -- 863
		) -- 863
	end -- 863
	if not p.childMode and (p.coverHug or p.coverNear) then -- 863
		local plx = p.player.x -- 868
		local nearLeft = math.abs(plx - s.x) < 42 -- 869
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 870
		if nearLeft or nearRight then -- 870
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 872
			local isWood = slot == "cover_wood" -- 873
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 874
			fgDraw:drawSegment( -- 875
				Vec2(edgeX, y0 + 4), -- 875
				Vec2(edgeX, y0 + sh + 2), -- 875
				p.coverHug and 2 or 1.2, -- 875
				toColor(col, p.coverHug and 205 or 120) -- 875
			) -- 875
		end -- 875
	end -- 875
end -- 843
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 883
	if layer == nil then -- 883
		layer = 2 -- 888
	end -- 888
	local cx = x0 + sw * 0.5 -- 890
	local cy = y0 + sh * 0.55 -- 891
	local ropeWidth = math.max(1, sw * 0.023) -- 892
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 893
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 894
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 895
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 896
	draw:drawSegment( -- 897
		drum, -- 897
		bend, -- 897
		ropeWidth, -- 897
		Color(111, 86, 57, 239) -- 897
	) -- 897
	draw:drawSegment( -- 898
		bend, -- 898
		ropeTop, -- 898
		ropeWidth, -- 898
		Color(111, 86, 57, 239) -- 898
	) -- 898
	assets:tryPlace( -- 899
		"prop_winch", -- 899
		"gate_winch", -- 899
		cx, -- 899
		y0 + sh * 0.5, -- 899
		sw, -- 899
		sh, -- 899
		{layer = layer} -- 899
	) -- 899
end -- 883
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 902
	local ____temp_3 -- 910
	if p.room.story ~= nil then -- 910
		____temp_3 = p.room.story.gate -- 910
	else -- 910
		____temp_3 = nil -- 910
	end -- 910
	local g = ____temp_3 -- 910
	if g == nil then -- 910
		return -- 912
	end -- 912
	local closeFrac = 0.08 -- 915
	if p.phase == "gate-hold" then -- 915
		closeFrac = 0.08 + 0.36 * math.min( -- 917
			1, -- 917
			p.gateTick / math.max(1, g.holdTicks) -- 917
		) -- 917
	elseif p.phase == "gate-send" then -- 917
		closeFrac = 0.44 -- 919
	elseif p.phase == "gate-count" then -- 919
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 921
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 921
		closeFrac = 1 -- 923
	end -- 923
	local gx0 = cam:sx(864) -- 925
	local gx1 = cam:sx(1016) -- 926
	local topY = cam:sy(160) -- 927
	local botY = cam:sy(160 * (1 - closeFrac)) -- 928
	local shutterW = gx1 - gx0 -- 929
	local shutterH = topY - botY -- 930
	if shutterH > 2 then -- 930
		fillVGradRect( -- 932
			fgDraw, -- 932
			gx0, -- 932
			botY, -- 932
			shutterW, -- 932
			shutterH, -- 932
			toColor(PALETTE.steelDark), -- 932
			toColor(PALETTE.steelMid) -- 932
		) -- 932
		local rows = math.max( -- 934
			1, -- 934
			math.min( -- 934
				6, -- 934
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 934
			) -- 934
		) -- 934
		local rowH = shutterH / rows -- 935
		do -- 935
			local r = 0 -- 936
			while r < rows do -- 936
				assets:tryPlace( -- 937
					"cover_wood", -- 937
					"gate_shutter_" .. tostring(r), -- 937
					(gx0 + gx1) * 0.5, -- 937
					botY + r * rowH, -- 937
					shutterW, -- 938
					rowH + 0.5, -- 938
					{layer = depthOrder(0, 2)} -- 938
				) -- 938
				r = r + 1 -- 936
			end -- 936
		end -- 936
	end -- 936
	if closeFrac < 0.98 then -- 936
		local gapH = math.max( -- 943
			8, -- 943
			botY - cam:sy(0) -- 943
		) -- 943
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 944
		fillVGradRect( -- 945
			fgGlow, -- 945
			gx0, -- 945
			cam:sy(0), -- 945
			gx1 - gx0, -- 945
			gapH, -- 945
			Color( -- 945
				140, -- 945
				210, -- 945
				255, -- 945
				math.floor(52 * pulse + 0.5) -- 945
			), -- 945
			Color(80, 160, 230, 0) -- 945
		) -- 945
	end -- 945
end -- 902
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 949
	fillVGradRect( -- 956
		fgDraw, -- 956
		x0, -- 956
		y0, -- 956
		sw, -- 956
		sh, -- 956
		Color(15, 21, 34, 255), -- 956
		Color(32, 44, 66, 255) -- 956
	) -- 956
	fgDraw:drawRect( -- 957
		Rect(x0, y0, sw, sh), -- 957
		Color(0, 0, 0, 0), -- 957
		1.4, -- 957
		toColor(PALETTE.rimSilver, 165) -- 957
	) -- 957
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 957
		self:tileMasonry( -- 960
			assets, -- 960
			s, -- 960
			x0, -- 960
			y0, -- 960
			sw, -- 960
			sh -- 960
		) -- 960
		local ribs = 4 -- 962
		local r = 1 -- 963
		do -- 963
			r = 1 -- 964
			while r < ribs do -- 964
				local rx = x0 + sw * r / ribs -- 965
				fgDraw:drawSegment( -- 966
					Vec2(rx, y0), -- 966
					Vec2(rx, y0 + sh), -- 966
					2, -- 966
					Color(10, 15, 24, 210) -- 966
				) -- 966
				fgDraw:drawSegment( -- 967
					Vec2(rx + 2, y0), -- 967
					Vec2(rx + 2, y0 + sh), -- 967
					1, -- 967
					Color(68, 86, 114, 130) -- 967
				) -- 967
				r = r + 1 -- 964
			end -- 964
		end -- 964
		local bands = 4 -- 970
		local b = 1 -- 971
		do -- 971
			b = 1 -- 972
			while b < bands do -- 972
				local by = y0 + sh * b / bands -- 973
				fgDraw:drawSegment( -- 974
					Vec2(x0 + 4, by), -- 974
					Vec2(x0 + sw - 4, by), -- 974
					1.2, -- 974
					Color(52, 68, 92, 135) -- 974
				) -- 974
				b = b + 1 -- 972
			end -- 972
		end -- 972
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 977
		local slitY = y0 + sh * 0.56 -- 978
		local slitH = sh * 0.22 -- 979
		fgDraw:drawRect( -- 980
			Rect(slitX - 5, slitY, 10, slitH), -- 980
			Color(8, 12, 20, 245), -- 980
			1.2, -- 980
			toColor(PALETTE.amberDim, 190) -- 980
		) -- 980
		fgGlow:drawRect( -- 981
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 981
			toColor(PALETTE.amber, 190) -- 981
		) -- 981
		fillRadialGlow( -- 982
			fgGlow, -- 982
			slitX, -- 982
			slitY + slitH * 0.5, -- 982
			44, -- 982
			slitH * 0.7, -- 982
			Color(255, 206, 128, 52), -- 982
			Color(255, 180, 86, 0), -- 982
			14 -- 982
		) -- 982
	end -- 982
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 982
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 987
		local cx = x0 + sw * 0.5 -- 992
		local lampY = y0 - 8 -- 993
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 994
		if not opened then -- 994
			assets:tryPlace( -- 996
				"prop_tower_door", -- 996
				"tower_door", -- 996
				cx, -- 996
				y0 - doorHeight, -- 996
				sw, -- 996
				doorHeight, -- 996
				{layer = 2} -- 996
			) -- 996
		end -- 996
		assets:tryPlace( -- 998
			"prop_lantern", -- 998
			"tower_lantern", -- 998
			cx + sw * 0.43, -- 998
			lampY - sh * 0.36, -- 998
			sw * 0.17, -- 999
			sh * 0.84, -- 999
			{layer = 3} -- 999
		) -- 999
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1000
		local alpha = opened and 58 or 42 -- 1001
		fgDraw:drawSegment( -- 1003
			Vec2(x0 + 4, y0), -- 1003
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1003
			4, -- 1003
			Color(42, 52, 70, 255) -- 1003
		) -- 1003
		fgDraw:drawSegment( -- 1004
			Vec2(x0 + sw - 4, y0), -- 1004
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1004
			4, -- 1004
			Color(42, 52, 70, 255) -- 1004
		) -- 1004
		fgDraw:drawSegment( -- 1005
			Vec2(x0, y0), -- 1005
			Vec2(x0 + sw, y0), -- 1005
			2.5, -- 1005
			toColor(PALETTE.amber, 210) -- 1005
		) -- 1005
		fillVGradRect( -- 1007
			fgGlow, -- 1008
			x0 + 6, -- 1009
			y0 - sh * 3.8, -- 1010
			sw - 12, -- 1011
			sh * 3.8, -- 1012
			Color( -- 1013
				246, -- 1013
				196, -- 1013
				118, -- 1013
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1013
			), -- 1013
			Color(246, 206, 142, opened and 74 or 38) -- 1014
		) -- 1014
		fillRadialGlow( -- 1016
			fgGlow, -- 1016
			cx, -- 1016
			lampY, -- 1016
			opened and 78 or 54, -- 1016
			opened and 72 or 52, -- 1016
			Color( -- 1016
				252, -- 1016
				218, -- 1016
				152, -- 1016
				math.floor(92 * pulse + 0.5) -- 1016
			), -- 1016
			Color(255, 180, 86, 0), -- 1016
			18 -- 1016
		) -- 1016
		fgDraw:drawCircle( -- 1017
			Vec2(cx, lampY), -- 1017
			4.5, -- 1017
			toColor(PALETTE.amberCore) -- 1017
		) -- 1017
		if opened then -- 1017
			local deskCx = cam:sx(p.ox + 605) -- 1021
			local groundY = cam:sy(0) -- 1022
			local deskW = cam:len(84) -- 1023
			local deskH = cam:len(34) -- 1024
			local deskTop = groundY + deskH -- 1025
			local writing = p.deskHold >= 24 or p.towerHanded -- 1026
			fillRadialGlow( -- 1028
				fgGlow, -- 1028
				deskCx, -- 1028
				deskTop + cam:len(26), -- 1028
				cam:len(96), -- 1028
				cam:len(74), -- 1028
				Color( -- 1029
					255, -- 1029
					198, -- 1029
					114, -- 1029
					math.floor(52 * pulse + 0.5) -- 1029
				), -- 1029
				Color(255, 168, 72, 0), -- 1029
				16 -- 1029
			) -- 1029
			local guardX = deskCx + cam:len(26) -- 1031
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 1032
			if not assets:tryPlacePath( -- 1032
				guardClip, -- 1035
				"tower_guard_npc", -- 1035
				guardX, -- 1035
				groundY, -- 1035
				cam:len(54), -- 1035
				cam:len(84), -- 1035
				{ -- 1035
					anchorX = 0.44, -- 1036
					anchorY = 0, -- 1037
					preserveAspect = true, -- 1038
					facing = -1, -- 1039
					opacity = 0.96, -- 1040
					layer = 3 -- 1041
				} -- 1041
			) then -- 1041
				fgDraw:drawRect( -- 1043
					Rect( -- 1043
						guardX - cam:len(11), -- 1043
						groundY, -- 1043
						cam:len(22), -- 1043
						cam:len(68) -- 1043
					), -- 1043
					Color(34, 42, 54, 240) -- 1043
				) -- 1043
				fgDraw:drawCircle( -- 1044
					Vec2( -- 1044
						guardX, -- 1044
						groundY + cam:len(76) -- 1044
					), -- 1044
					cam:len(9.5), -- 1044
					Color(42, 50, 62, 245) -- 1044
				) -- 1044
			end -- 1044
			if not assets:tryPlace( -- 1044
				"prop_table", -- 1047
				"tower_guard_desk", -- 1047
				deskCx, -- 1047
				groundY, -- 1047
				deskW * 1.06, -- 1047
				deskH * 1.04, -- 1047
				{ -- 1047
					color = Color(214, 188, 158, 255), -- 1048
					opacity = 0.98, -- 1049
					layer = 4 -- 1050
				} -- 1050
			) then -- 1050
				fgDraw:drawRect( -- 1052
					Rect( -- 1052
						deskCx - deskW * 0.5, -- 1052
						groundY, -- 1052
						cam:len(6), -- 1052
						deskH -- 1052
					), -- 1052
					Color(78, 52, 34, 255) -- 1052
				) -- 1052
				fgDraw:drawRect( -- 1053
					Rect( -- 1053
						deskCx + deskW * 0.5 - cam:len(6), -- 1053
						groundY, -- 1053
						cam:len(6), -- 1053
						deskH -- 1053
					), -- 1053
					Color(78, 52, 34, 255) -- 1053
				) -- 1053
				fgDraw:drawRect( -- 1054
					Rect( -- 1054
						deskCx - deskW * 0.52, -- 1054
						deskTop - cam:len(6), -- 1054
						deskW * 1.04, -- 1054
						cam:len(8) -- 1054
					), -- 1054
					Color(108, 74, 46, 255), -- 1054
					1, -- 1054
					Color(148, 108, 68, 220) -- 1054
				) -- 1054
			end -- 1054
			fgDraw:drawRect( -- 1057
				Rect( -- 1057
					deskCx + cam:len(4), -- 1057
					deskTop + cam:len(1), -- 1057
					cam:len(22), -- 1057
					cam:len(4.5) -- 1057
				), -- 1057
				Color(232, 222, 198, 245) -- 1057
			) -- 1057
			if writing then -- 1057
				assets:tryPlace( -- 1059
					"prop_lantern", -- 1059
					"tower_desk_lamp", -- 1059
					deskCx + cam:len(34), -- 1059
					deskTop + cam:len(10), -- 1059
					cam:len(14), -- 1059
					cam:len(20), -- 1059
					{layer = 5} -- 1059
				) -- 1059
				fillRadialGlow( -- 1060
					fgGlow, -- 1060
					deskCx + cam:len(34), -- 1060
					deskTop + cam:len(12), -- 1060
					cam:len(24), -- 1060
					cam:len(22), -- 1060
					Color( -- 1060
						255, -- 1060
						214, -- 1060
						134, -- 1060
						math.floor(88 * pulse + 0.5) -- 1060
					), -- 1060
					Color(255, 180, 86, 0), -- 1060
					12 -- 1060
				) -- 1060
			else -- 1060
				fillRadialGlow( -- 1062
					fgGlow, -- 1062
					deskCx + cam:len(3), -- 1062
					deskTop + cam:len(18), -- 1062
					cam:len(30), -- 1062
					cam:len(28), -- 1062
					Color( -- 1062
						255, -- 1062
						214, -- 1062
						134, -- 1062
						math.floor(78 * pulse + 0.5) -- 1062
					), -- 1062
					Color(255, 180, 86, 0), -- 1062
					12 -- 1062
				) -- 1062
			end -- 1062
			if p.deskHold >= 12 or p.towerHanded then -- 1062
				if not assets:tryPlacePath( -- 1062
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1066
					"tower_desk_pouch", -- 1066
					deskCx - cam:len(22), -- 1066
					deskTop + cam:len(8), -- 1066
					cam:len(18), -- 1066
					cam:len(18), -- 1066
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1066
				) then -- 1066
					fgDraw:drawRect( -- 1072
						Rect( -- 1072
							deskCx - cam:len(28), -- 1072
							deskTop + cam:len(2), -- 1072
							cam:len(14), -- 1072
							cam:len(6) -- 1072
						), -- 1072
						Color(156, 62, 48, 245) -- 1072
					) -- 1072
				end -- 1072
			end -- 1072
			if writing then -- 1072
				fgDraw:drawRect( -- 1076
					Rect( -- 1076
						deskCx - cam:len(6), -- 1076
						deskTop + cam:len(2), -- 1076
						cam:len(10), -- 1076
						cam:len(3) -- 1076
					), -- 1076
					Color(236, 228, 206, 240) -- 1076
				) -- 1076
			end -- 1076
		end -- 1076
	end -- 1076
end -- 949
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1082
	local blades = math.max( -- 1089
		12, -- 1089
		math.floor(sw / 8) -- 1089
	) -- 1089
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1090
	local k = 0 -- 1091
	do -- 1091
		k = 0 -- 1092
		while k < blades do -- 1092
			local t = (k + 0.5) / blades -- 1093
			local bx = x0 + sw * t -- 1094
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1095
			local bh = sh * hRatio * 1.95 -- 1096
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1097
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1098
			fgDraw:drawPolygon( -- 1099
				{ -- 1099
					Vec2(bx - 7, y0), -- 1100
					Vec2(bx + 7, y0), -- 1101
					Vec2(bx + sway, y0 + bh) -- 1102
				}, -- 1102
				col -- 1103
			) -- 1103
			k = k + 1 -- 1092
		end -- 1092
	end -- 1092
	if nearPlayer then -- 1092
		fgGlow:drawSegment( -- 1106
			Vec2(x0, y0 + 2), -- 1106
			Vec2(x0 + sw, y0 + 2), -- 1106
			2, -- 1106
			toColor(PALETTE.emerald, 145) -- 1106
		) -- 1106
	end -- 1106
end -- 1082
function StageRenderer.prototype.drawArch(self, draw, assets, p, cam) -- 1110
	local a = p.room.arch -- 1116
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1116
		return -- 1118
	end -- 1118
	local x0 = cam:sx(a.x0) -- 1120
	local x1 = cam:sx(a.x1) -- 1121
	local y0 = cam:sy(a.y) -- 1122
	local y1 = cam:sy(a.y + a.h) -- 1123
	local cx = (x0 + x1) * 0.5 -- 1124
	local aw = x1 - x0 -- 1125
	local ah = y1 - y0 -- 1126
	draw:drawRect( -- 1127
		Rect( -- 1127
			x0, -- 1127
			y0, -- 1127
			aw, -- 1127
			ah + cam:len(8) -- 1127
		), -- 1127
		Color(13, 15, 20, 242) -- 1127
	) -- 1127
	if not assets:tryPlace( -- 1127
		"fe_outside_arch", -- 1128
		"outside_arch_vault", -- 1128
		cx, -- 1128
		y0, -- 1128
		aw + cam:len(24), -- 1128
		ah + cam:len(22), -- 1128
		{layer = 2} -- 1128
	) then -- 1128
		draw:drawRect( -- 1129
			Rect( -- 1129
				x0 - cam:len(7), -- 1129
				y0, -- 1129
				cam:len(7), -- 1129
				ah -- 1129
			), -- 1129
			Color(62, 63, 67, 255) -- 1129
		) -- 1129
		draw:drawRect( -- 1130
			Rect( -- 1130
				x1, -- 1130
				y0, -- 1130
				cam:len(7), -- 1130
				ah -- 1130
			), -- 1130
			Color(72, 72, 74, 255) -- 1130
		) -- 1130
	end -- 1130
	if not p.cartDocked then -- 1130
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1134
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1135
		if bx1 > bx0 + 4 then -- 1135
			local deckY = cam:sy(p.room.cart.baseY) -- 1137
			assets:tryPlace( -- 1138
				"fe_pillar_wood", -- 1138
				"outside_arch_bolt", -- 1138
				(bx0 + bx1) * 0.5, -- 1138
				y0 + 2, -- 1138
				bx1 - bx0, -- 1138
				ah - 2, -- 1138
				{layer = 3} -- 1138
			) -- 1138
			draw:drawSegment( -- 1139
				Vec2((bx0 + bx1) * 0.5, y1), -- 1139
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1139
				2.4, -- 1139
				Color(96, 102, 110, 220) -- 1139
			) -- 1139
		end -- 1139
	end -- 1139
end -- 1110
return ____exports -- 1110