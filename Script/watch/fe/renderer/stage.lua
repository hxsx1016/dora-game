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
	if solid.art == "basket_wall" then -- 47
		return {clip = "basket_wall", natAR = 144 / 90, heightMul = 1.08, tileable = true} -- 48
	end -- 48
	if solid.art == "curtain" then -- 50
		return {clip = "curtain", natAR = 144 / 126, heightMul = 1.06, tileable = false} -- 51
	end -- 51
	if solid.art == "board" then -- 53
		return {clip = "window_board", natAR = 88 / 144, heightMul = 1.04, tileable = false} -- 54
	end -- 54
	if solid.id == "s1_well" or solid.art == "well" or (string.find(solid.label, "井背", nil, true) or 0) - 1 >= 0 then -- 56
		return {clip = "well_curb", natAR = 144 / 120, heightMul = 1.12, tileable = false} -- 57
	end -- 57
	if solid.art == "grain_sack" or (string.find(solid.label, "粮台", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "粮袋", nil, true) or 0) - 1 >= 0 then -- 59
		return {clip = "grain_sack", natAR = 144 / 74, heightMul = 1.12, tileable = true} -- 60
	end -- 60
	return nil -- 62
end -- 46
local function coverArt(solid) -- 65
	if solid.art == "gate_post" or solid.art == "wall" then -- 66
		return "wall" -- 67
	end -- 67
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 69
		return "cover_wood" -- 70
	end -- 70
	if solid.art == "fence" then -- 72
		return "fence" -- 73
	end -- 73
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 75
end -- 65
local GUARD_LANTERN_CLIPS = {"assets/art/actors_enemies_anim.clip|guard_lantern_0", "assets/art/actors_enemies_anim.clip|guard_lantern_1", "assets/art/actors_enemies_anim.clip|guard_lantern_2", "assets/art/actors_enemies_anim.clip|guard_lantern_3"} -- 78
local GUARD_WRITE_CLIPS = {"assets/art/actors_enemies_anim.clip|guard_write_0", "assets/art/actors_enemies_anim.clip|guard_write_1", "assets/art/actors_enemies_anim.clip|guard_write_2", "assets/art/actors_enemies_anim.clip|guard_write_3"} -- 84
local function tintByShade(base, shade) -- 91
	return Color( -- 92
		math.max( -- 93
			0, -- 93
			math.min( -- 93
				255, -- 93
				math.floor(base.r * shade + 0.5) -- 93
			) -- 93
		), -- 93
		math.max( -- 94
			0, -- 94
			math.min( -- 94
				255, -- 94
				math.floor(base.g * shade + 0.5) -- 94
			) -- 94
		), -- 94
		math.max( -- 95
			0, -- 95
			math.min( -- 95
				255, -- 95
				math.floor(base.b * shade + 0.5) -- 95
			) -- 95
		), -- 95
		base.a -- 96
	) -- 96
end -- 91
____exports.StageRenderer = __TS__Class() -- 100
local StageRenderer = ____exports.StageRenderer -- 100
StageRenderer.name = "StageRenderer" -- 100
function StageRenderer.prototype.____constructor(self) -- 100
end -- 100
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, _time) -- 102
	local w = cam.viewW -- 110
	local h = cam.viewH -- 111
	local theme = themeOf(p.room.key) -- 112
	local span = math.max(1, p.room.maxX - p.room.minX) -- 114
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 115
	local backdropKey = theme.backdropKey or p.room.key -- 116
	local farSlot = "bgFar_" .. backdropKey -- 117
	local backRoadY = cam:sy(0, p.room.depth ~= nil and p.room.depth.max or 0) -- 120
	local artW = math.max(w, h * 16 / 9) * 1.1 -- 121
	local artH = artW * 9 / 16 -- 122
	local artY = math.min( -- 123
		0, -- 123
		math.max(h - artH, backRoadY - artH * 0.25) -- 123
	) -- 123
	if assets:tryPlace( -- 124
		farSlot, -- 124
		"scene", -- 124
		w * (0.5 - progress * 0.08), -- 124
		artY, -- 124
		artW, -- 124
		artH -- 124
	) then -- 124
		self:drawDressing( -- 125
			assets, -- 125
			backdropKey, -- 125
			cam, -- 125
			progress, -- 125
			backRoadY -- 125
		) -- 125
		fillVGradRect( -- 126
			bgDraw, -- 126
			0, -- 126
			0, -- 126
			w, -- 126
			h, -- 126
			toColor(PALETTE.voidDark), -- 126
			toColor(theme.skyMid) -- 126
		) -- 126
		fillVGradRect( -- 127
			bgGlow, -- 127
			0, -- 127
			backRoadY - 2, -- 127
			w, -- 127
			h * 0.14, -- 127
			Color(43, 54, 72, 20), -- 127
			Color(43, 54, 72, 0) -- 127
		) -- 127
		return -- 128
	end -- 128
	local splitY = h * 0.46 -- 132
	fillVGradRect( -- 133
		bgDraw, -- 133
		0, -- 133
		splitY, -- 133
		w, -- 133
		h - splitY, -- 133
		toColor(theme.skyMid), -- 133
		toColor(theme.skyTop) -- 133
	) -- 133
	fillVGradRect( -- 134
		bgDraw, -- 134
		0, -- 134
		0, -- 134
		w, -- 134
		splitY, -- 134
		toColor(theme.skyHorizon), -- 134
		toColor(theme.skyMid) -- 134
	) -- 134
	if theme.showMoon then -- 135
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 136
		local my = h * theme.moonYFrac -- 137
		local mr = math.max(18, h * 0.044) -- 138
		fillRadialGlow( -- 139
			bgGlow, -- 139
			mx, -- 139
			my, -- 139
			mr * 4.6, -- 139
			mr * 4.6, -- 139
			Color(148, 178, 206, 28), -- 139
			Color(20, 32, 52, 0), -- 139
			18 -- 139
		) -- 139
		bgDraw:drawCircle( -- 140
			Vec2(mx, my), -- 140
			mr, -- 140
			Color(218, 232, 242, 215) -- 140
		) -- 140
	end -- 140
	fillVGradRect( -- 142
		bgGlow, -- 143
		0, -- 144
		backRoadY - 10, -- 145
		w, -- 146
		h * 0.3, -- 147
		toColor(theme.fogBottom), -- 148
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 149
	) -- 149
end -- 102
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress, backRoadY) -- 153
	local w = cam.viewW -- 160
	local x = w * (0.76 - progress * 0.24) -- 161
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 164
		assets:tryPlace( -- 165
			"pine", -- 165
			"mid_pine", -- 165
			x, -- 165
			backRoadY - cam:len(4), -- 165
			cam:len(118), -- 165
			cam:len(104), -- 165
			{layer = 1, opacity = 0.48} -- 166
		) -- 166
	elseif backdropKey == "street" then -- 167
		assets:tryPlace( -- 168
			"dp_ruin_house_a", -- 168
			"mid_ruin", -- 168
			x, -- 168
			backRoadY - cam:len(4), -- 168
			cam:len(132), -- 168
			cam:len(118), -- 168
			{layer = 1, opacity = 0.42} -- 169
		) -- 169
	end -- 169
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 171
		local lanternSway = math.sin(progress * 6 + cam.x * 0.004) * 2.5 -- 172
		assets:tryPlace( -- 173
			"prop_lantern", -- 173
			"mid_lantern", -- 173
			w * (0.27 - progress * 0.2), -- 173
			backRoadY + cam:len(86), -- 174
			cam:len(20), -- 174
			cam:len(28), -- 174
			{layer = 2, opacity = 0.86, angle = lanternSway} -- 174
		) -- 174
	end -- 174
end -- 153
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 179
	local theme = themeOf("checkpoint") -- 186
	local splitY = h * 0.44 -- 187
	fillVGradRect( -- 188
		bgDraw, -- 188
		0, -- 188
		splitY, -- 188
		w, -- 188
		h - splitY, -- 188
		toColor(theme.skyMid), -- 188
		toColor(theme.skyTop) -- 188
	) -- 188
	fillVGradRect( -- 189
		bgDraw, -- 189
		0, -- 189
		0, -- 189
		w, -- 189
		splitY, -- 189
		toColor(theme.skyHorizon), -- 189
		toColor(theme.skyMid) -- 189
	) -- 189
	local mx = w * 0.61 -- 190
	local my = h * 0.74 -- 191
	local mr = h * 0.068 -- 192
	local pulse = 0.86 + 0.14 * math.sin(time * 2) -- 193
	fillRadialGlow( -- 194
		bgGlow, -- 194
		mx, -- 194
		my, -- 194
		mr * 4.4 * pulse, -- 194
		mr * 4.4 * pulse, -- 194
		Color(156, 180, 198, 28), -- 194
		Color(16, 22, 34, 0), -- 194
		20 -- 194
	) -- 194
	bgDraw:drawCircle( -- 195
		Vec2(mx, my), -- 195
		mr, -- 195
		Color(224, 232, 236, 218) -- 195
	) -- 195
	local groundY = h * 0.19 -- 196
	fillVGradRect( -- 197
		bgDraw, -- 197
		0, -- 197
		0, -- 197
		w, -- 197
		groundY, -- 197
		Color(9, 11, 17, 255), -- 197
		Color(18, 23, 33, 255) -- 197
	) -- 197
	bgDraw:drawSegment( -- 198
		Vec2(0, groundY), -- 198
		Vec2(w, groundY), -- 198
		1.4, -- 198
		toColor(PALETTE.silkDim, 145) -- 198
	) -- 198
end -- 179
function StageRenderer.prototype.drawPlayableWorld(self, groundDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt, groundArt, roadLineDraw, overlayDraw) -- 202
	local theme = themeOf(p.room.key) -- 215
	local gArt = groundArt or assets -- 216
	local rLine = roadLineDraw or groundDraw -- 217
	local oDraw = overlayDraw or rLine -- 218
	self:drawFloors( -- 219
		groundDraw, -- 219
		rLine, -- 219
		gArt, -- 219
		p, -- 219
		cam, -- 219
		theme -- 219
	) -- 219
	self:drawStairs( -- 220
		rLine, -- 220
		fgGlow, -- 220
		assets, -- 220
		p, -- 220
		cam, -- 220
		theme -- 220
	) -- 220
	self:drawBoundaryClosures(assets, p, cam) -- 221
	self:drawSolids( -- 222
		rLine, -- 222
		oDraw, -- 222
		fgGlow, -- 222
		assets, -- 222
		p, -- 222
		cam, -- 222
		theme, -- 222
		time, -- 222
		occlusion, -- 222
		fadeDt -- 222
	) -- 222
	if p.room.key == "gate" then -- 223
		self:drawGateShutter( -- 224
			rLine, -- 224
			fgGlow, -- 224
			assets, -- 224
			p, -- 224
			cam, -- 224
			time -- 224
		) -- 224
	end -- 224
	self:drawArch(rLine, assets, p, cam) -- 226
end -- 202
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 230
	fillVGradRect( -- 237
		fgDraw, -- 237
		0, -- 237
		h - h * 0.14, -- 237
		w, -- 237
		h * 0.14, -- 237
		Color(4, 6, 12, 0), -- 237
		Color(4, 6, 12, 118) -- 237
	) -- 237
	fillVGradRect( -- 238
		fgDraw, -- 238
		0, -- 238
		0, -- 238
		w, -- 238
		h * 0.11, -- 238
		Color(4, 6, 12, 152), -- 238
		Color(4, 6, 12, 0) -- 238
	) -- 238
end -- 230
function StageRenderer.prototype.drawBoundaryClosures(self, assets, p, cam) -- 242
	local road = p.room.depth -- 243
	if road == nil then -- 244
		return -- 245
	end -- 245
	if p.room.key == "outside" or p.room.key == "village" or p.room.key == "forest" or p.room.key == "tower" or p.room.key == "museum" then -- 247
		return -- 248
	end -- 248
	local function hasWallNear(targetX) -- 250
		do -- 250
			local i = 0 -- 251
			while i < #p.room.solids do -- 251
				do -- 251
					local s = p.room.solids[i + 1] -- 252
					if s.decorative == true then -- 253
						goto __continue34 -- 253
					end -- 253
					if s.h >= 100 and (math.abs(s.x - targetX) <= 85 or math.abs(s.x + s.w - targetX) <= 85) then -- 254
						return true -- 255
					end -- 255
				end -- 255
				::__continue34:: -- 255
				i = i + 1 -- 251
			end -- 251
		end -- 251
		return false -- 258
	end -- 250
	local minX = p.room.minX -- 260
	local maxX = p.room.maxX -- 261
	local backY = cam:sy(0, road.max) -- 262
	local frontY = cam:sy(0, road.min) -- 263
	local barW = cam:len(46) -- 264
	local barH = cam:len(84) -- 265
	if not hasWallNear(minX) then -- 266
		local lx = cam:sx(minX + 6) -- 267
		if lx + barW > -20 and lx - barW < cam.viewW + 20 then -- 268
			assets:tryPlace( -- 269
				"dp_boundary_barricade", -- 269
				"bound_left_back", -- 269
				lx, -- 269
				backY - cam:len(4), -- 269
				barW * 0.92, -- 269
				barH * 0.92, -- 269
				{ -- 269
					layer = depthOrder(road.max, 0), -- 270
					opacity = 0.88 -- 270
				} -- 270
			) -- 270
			assets:tryPlace( -- 272
				"dp_boundary_barricade", -- 272
				"bound_left_front", -- 272
				lx - cam:len(6), -- 272
				frontY - cam:len(2), -- 272
				barW, -- 272
				barH * 0.72, -- 272
				{ -- 272
					layer = depthOrder(road.min, 0), -- 273
					opacity = 0.94 -- 273
				} -- 273
			) -- 273
		end -- 273
	end -- 273
	if not hasWallNear(maxX) then -- 277
		local rx = cam:sx(maxX - 6) -- 278
		if rx + barW > -20 and rx - barW < cam.viewW + 20 then -- 279
			assets:tryPlace( -- 280
				"dp_boundary_barricade", -- 280
				"bound_right_back", -- 280
				rx, -- 280
				backY - cam:len(4), -- 280
				barW * 0.92, -- 280
				barH * 0.92, -- 280
				{ -- 280
					layer = depthOrder(road.max, 0), -- 281
					opacity = 0.88, -- 281
					facing = -1 -- 281
				} -- 281
			) -- 281
			assets:tryPlace( -- 283
				"dp_boundary_barricade", -- 283
				"bound_right_front", -- 283
				rx + cam:len(6), -- 283
				frontY - cam:len(2), -- 283
				barW, -- 283
				barH * 0.72, -- 283
				{ -- 283
					layer = depthOrder(road.min, 0), -- 284
					opacity = 0.94, -- 284
					facing = -1 -- 284
				} -- 284
			) -- 284
		end -- 284
	end -- 284
end -- 242
function StageRenderer.prototype.drawFloors(self, groundDraw, roadLineDraw, groundArt, p, cam, theme) -- 290
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 298
	do -- 298
		local i = 0 -- 299
		while i < #p.room.floors do -- 299
			local floor = p.room.floors[i + 1] -- 300
			local left = cam:sx(floor.x0) -- 301
			local right = cam:sx(floor.x1) -- 302
			local isMain = floor.y <= 0.1 -- 303
			local ____isMain_0 -- 304
			if isMain then -- 304
				____isMain_0 = p.room.depth -- 304
			else -- 304
				____isMain_0 = nil -- 304
			end -- 304
			local road = ____isMain_0 -- 304
			local top = cam:sy(floor.y, road and road.min or 0) -- 305
			if road ~= nil then -- 306
				self:drawRoad( -- 307
					groundDraw, -- 307
					roadLineDraw, -- 307
					groundArt, -- 307
					i, -- 307
					left, -- 307
					right, -- 307
					top, -- 307
					cam:sy(floor.y, road.max), -- 307
					road, -- 307
					cam, -- 307
					theme -- 307
				) -- 307
			end -- 307
			local height = cam:len(isMain and 22 or 12) -- 309
			local bottom = top - height -- 310
			if isMain and bottom > 0 then -- 311
				fillVGradRect( -- 312
					groundDraw, -- 312
					left, -- 312
					0, -- 312
					right - left, -- 312
					bottom + 1, -- 312
					toColor(PALETTE.voidDark), -- 313
					toColor(theme.groundBody) -- 313
				) -- 313
			end -- 313
			local step = cam:len(96) -- 315
			local start = math.max( -- 316
				0, -- 316
				math.floor(-left / step) -- 316
			) -- 316
			do -- 316
				local j = start -- 317
				while left + j * step < math.min(right, cam.viewW) do -- 317
					local x = left + j * step -- 318
					local width = math.min(step, right - x) -- 319
					groundArt:tryPlace( -- 320
						"slab", -- 320
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 320
						x + width * 0.5, -- 320
						bottom, -- 320
						width + 0.5, -- 320
						height, -- 320
						{layer = 3} -- 320
					) -- 320
					if grass and isMain and j % 3 == 1 then -- 321
						groundArt:tryPlace( -- 322
							"grass_low", -- 322
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 322
							x + width * 0.5, -- 322
							top - cam:len(3), -- 323
							width * 0.74, -- 323
							cam:len(13), -- 323
							{opacity = 0.85, layer = 5} -- 323
						) -- 323
					end -- 323
					j = j + 1 -- 317
				end -- 317
			end -- 317
			roadLineDraw:drawSegment( -- 326
				Vec2(left, top), -- 326
				Vec2(right, top), -- 326
				1.2, -- 326
				toColor(theme.groundRim, 160) -- 326
			) -- 326
			i = i + 1 -- 299
		end -- 299
	end -- 299
end -- 290
function StageRenderer.prototype.drawRoad(self, groundDraw, roadLineDraw, groundArt, floorIdx, left, right, front, back, road, cam, theme) -- 336
	local width = right - left -- 349
	local height = back - front -- 350
	if width <= 1 or height <= 1 then -- 351
		return -- 352
	end -- 352
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.36) -- 354
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.52) -- 355
	fillVGradRect( -- 356
		groundDraw, -- 356
		left, -- 356
		front, -- 356
		width, -- 356
		height, -- 356
		toColor(nearCol), -- 356
		toColor(farCol) -- 356
	) -- 356
	local visLeft = math.max(left, -96) -- 358
	local visRight = math.min(right, cam.viewW + 96) -- 359
	local lanes = { -- 362
		{ -- 363
			slot = "dp_road_lower", -- 363
			f0 = 0, -- 363
			f1 = 0.34, -- 363
			tileW = cam:len(104) -- 363
		}, -- 363
		{ -- 364
			slot = "dp_road_mid", -- 364
			f0 = 0.34, -- 364
			f1 = 0.68, -- 364
			tileW = cam:len(96) -- 364
		}, -- 364
		{ -- 365
			slot = "dp_road_upper", -- 365
			f0 = 0.68, -- 365
			f1 = 1, -- 365
			tileW = cam:len(86) -- 365
		} -- 365
	} -- 365
	do -- 365
		local li = 0 -- 367
		while li < #lanes do -- 367
			local ln = lanes[li + 1] -- 368
			local y0 = front + ln.f0 * height -- 369
			local y1 = front + ln.f1 * height -- 370
			local lh = y1 - y0 -- 371
			local twBase = math.max(48, ln.tileW) -- 372
			local tStart = math.max( -- 373
				0, -- 373
				math.floor((visLeft - left) / twBase) -- 373
			) -- 373
			do -- 373
				local col = tStart -- 374
				while left + col * twBase < visRight do -- 374
					do -- 374
						local tx0 = left + col * twBase -- 375
						local tw = math.min(twBase, right - tx0) -- 376
						if tw <= 2 then -- 377
							goto __continue54 -- 377
						end -- 377
						groundArt:tryPlace( -- 378
							ln.slot, -- 378
							(((("road_lane_" .. tostring(floorIdx)) .. "_") .. tostring(li)) .. "_") .. tostring(col), -- 378
							tx0 + tw * 0.5, -- 378
							y0, -- 378
							tw + 0.8, -- 378
							lh + 0.8, -- 378
							{layer = 2, opacity = 0.96} -- 378
						) -- 378
					end -- 378
					::__continue54:: -- 378
					col = col + 1 -- 374
				end -- 374
			end -- 374
			li = li + 1 -- 367
		end -- 367
	end -- 367
	local curbW = math.max( -- 386
		48, -- 386
		cam:len(96) -- 386
	) -- 386
	local curbH = math.max( -- 387
		5, -- 387
		cam:len(7) -- 387
	) -- 387
	local cStart = math.max( -- 388
		0, -- 388
		math.floor((visLeft - left) / curbW) -- 388
	) -- 388
	do -- 388
		local col = cStart -- 389
		while left + col * curbW < visRight do -- 389
			do -- 389
				local tx0 = left + col * curbW -- 390
				local tw = math.min(curbW, right - tx0) -- 391
				if tw <= 2 then -- 392
					goto __continue57 -- 392
				end -- 392
				groundArt:tryPlace( -- 393
					"dp_road_curb", -- 393
					(("road_curb_" .. tostring(floorIdx)) .. "_") .. tostring(col), -- 393
					tx0 + tw * 0.5, -- 393
					front - curbH * 0.35, -- 393
					tw + 0.8, -- 393
					curbH, -- 393
					{layer = 4} -- 393
				) -- 393
			end -- 393
			::__continue57:: -- 393
			col = col + 1 -- 389
		end -- 389
	end -- 389
	local jointDark = Color(8, 11, 18, 138) -- 399
	local laneHint = Color(138, 166, 188, 44) -- 400
	local vpX = cam.viewW * 0.5 -- 401
	local stepWorld = 64 -- 402
	local firstJoint = math.floor((cam.x - cam.viewW * 0.65 / cam.ppu) / stepWorld) -- 403
	local lastJoint = math.ceil((cam.x + cam.viewW * 0.65 / cam.ppu) / stepWorld) -- 404
	do -- 404
		local j = firstJoint -- 405
		while j <= lastJoint do -- 405
			do -- 405
				local xFront = cam:sx(j * stepWorld) -- 406
				if xFront < left - 60 or xFront > right + 60 then -- 407
					goto __continue60 -- 407
				end -- 407
				local xBack = vpX + (xFront - vpX) * cam:depthScale(road.max, true) -- 409
				local cFront = math.max( -- 410
					left, -- 410
					math.min(right, xFront) -- 410
				) -- 410
				local cBack = math.max( -- 411
					left, -- 411
					math.min(right, xBack) -- 411
				) -- 411
				roadLineDraw:drawSegment( -- 412
					Vec2(cFront, front), -- 412
					Vec2(cBack, back), -- 412
					1, -- 412
					jointDark -- 412
				) -- 412
			end -- 412
			::__continue60:: -- 412
			j = j + 1 -- 405
		end -- 405
	end -- 405
	for ____, frac in ipairs({0.34, 0.68}) do -- 416
		local ly = front + frac * height -- 417
		roadLineDraw:drawSegment( -- 418
			Vec2(left, ly), -- 418
			Vec2(right, ly), -- 418
			1, -- 418
			jointDark -- 418
		) -- 418
		roadLineDraw:drawSegment( -- 419
			Vec2(left, ly + 1.1), -- 419
			Vec2(right, ly + 1.1), -- 419
			0.7, -- 419
			laneHint -- 419
		) -- 419
	end -- 419
	fillVGradRect( -- 422
		roadLineDraw, -- 422
		left, -- 422
		back - math.max(4, height * 0.14), -- 422
		width, -- 422
		math.max(4, height * 0.14), -- 422
		Color(6, 8, 14, 0), -- 423
		Color(6, 8, 14, 155) -- 423
	) -- 423
	roadLineDraw:drawSegment( -- 424
		Vec2(left, front), -- 424
		Vec2(right, front), -- 424
		1.5, -- 424
		toColor(theme.groundRim, 168) -- 424
	) -- 424
	roadLineDraw:drawSegment( -- 425
		Vec2(left, back), -- 425
		Vec2(right, back), -- 425
		1.3, -- 425
		Color(118, 144, 166, 95) -- 425
	) -- 425
end -- 336
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 428
	local i = 0 -- 436
	do -- 436
		i = 0 -- 437
		while i < #p.room.stairs do -- 437
			local st = p.room.stairs[i + 1] -- 438
			local n = st.steps + 1 -- 439
			local stepW = (st.x1 - st.x0) / n -- 440
			local depthEnabled = p.room.depth ~= nil -- 441
			local dMin = depthEnabled and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 442
			local dMax = depthEnabled and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 445
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 448
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 449
			local stairLayer = depthEnabled and depthOrder(dMin, 0) or 0 -- 450
			local k = 0 -- 451
			do -- 451
				k = 0 -- 452
				while k < n do -- 452
					do -- 452
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 453
						local wx0 = st.x0 + stepW * k -- 454
						local wx1 = wx0 + stepW -- 455
						local x0 = cam:sx(wx0) -- 456
						local x1 = cam:sx(wx1) -- 457
						if x1 < 0 or x0 > cam.viewW then -- 458
							goto __continue68 -- 459
						end -- 459
						local y1 = cam:sy(wy, dMin) -- 461
						local y0 = cam:sy(baseWorldY, dMin) -- 462
						local yRear = cam:sy(wy, dMax) -- 463
						local sw = x1 - x0 -- 464
						local cx = (x0 + x1) * 0.5 -- 465
						if yRear > y1 + 1 then -- 467
							assets:tryPlace( -- 468
								"dp_stone_top", -- 468
								(("stairs_cap_" .. tostring(i)) .. "_") .. tostring(k), -- 468
								cx, -- 468
								y1, -- 468
								sw + 0.8, -- 468
								yRear - y1 + 0.5, -- 468
								{layer = stairLayer, opacity = 0.96} -- 468
							) -- 468
						end -- 468
						local riserH = y1 - y0 -- 473
						if riserH > 2 then -- 474
							local courseH = math.max( -- 475
								12, -- 475
								cam:len(14) -- 475
							) -- 475
							local courses = math.max( -- 476
								1, -- 476
								math.min( -- 476
									8, -- 476
									math.ceil(riserH / courseH) -- 476
								) -- 476
							) -- 476
							local ch = riserH / courses -- 477
							do -- 477
								local ci = 0 -- 478
								while ci < courses do -- 478
									local slotName = ci == courses - 1 and "dp_stair_step" or "wall" -- 479
									assets:tryPlace( -- 480
										slotName, -- 480
										(((("stairs_" .. tostring(i)) .. "_") .. tostring(k)) .. "_") .. tostring(ci), -- 480
										cx, -- 480
										y0 + ci * ch, -- 480
										sw + 0.8, -- 480
										ch + 0.6, -- 480
										{ -- 480
											layer = stairLayer + 1, -- 481
											color = ci == courses - 1 and Color(246, 250, 255, 255) or Color(196, 206, 218, 255) -- 482
										} -- 482
									) -- 482
									ci = ci + 1 -- 478
								end -- 478
							end -- 478
						end -- 478
						fgDraw:drawSegment( -- 486
							Vec2(x0, y1), -- 486
							Vec2(x1, y1), -- 486
							1.4, -- 486
							toColor(theme.groundRim, 165) -- 486
						) -- 486
						fgGlow:drawSegment( -- 487
							Vec2(x0, y1 + 1), -- 487
							Vec2(x1, y1 + 1), -- 487
							0.8, -- 487
							toColor(theme.accent, 42) -- 487
						) -- 487
					end -- 487
					::__continue68:: -- 487
					k = k + 1 -- 452
				end -- 452
			end -- 452
			i = i + 1 -- 437
		end -- 437
	end -- 437
end -- 428
function StageRenderer.prototype.isSolidActive(self, p, s) -- 493
	local matched = false -- 494
	local anyVisible = false -- 495
	local i = 0 -- 496
	do -- 496
		i = 0 -- 497
		while i < #p.boxes do -- 497
			local b = p.boxes[i + 1] -- 498
			local sameId = s.id ~= nil and b.id == s.id -- 499
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 500
			if sameId or sameGeom then -- 503
				matched = true -- 504
				if b.broken ~= true and b.hidden ~= true then -- 505
					anyVisible = true -- 506
				end -- 506
			end -- 506
			i = i + 1 -- 497
		end -- 497
	end -- 497
	return not matched or anyVisible -- 510
end -- 493
function StageRenderer.prototype.drawSolids(self, fgDraw, overlayDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 513
	local i = 0 -- 525
	do -- 525
		i = 0 -- 526
		while i < #p.room.solids do -- 526
			do -- 526
				local s = p.room.solids[i + 1] -- 527
				if s.decorative == true then -- 529
					if p.room.depth ~= nil and (s.art == "stove_hearth" or s.art == "well") then -- 530
						local bx = cam:sx(s.x + s.w * 0.5) -- 531
						if bx > -80 and bx < cam.viewW + 80 then -- 532
							local backDepth = p.room.depth.max -- 533
							local by = cam:sy(0, backDepth) -- 534
							local dLayer = depthOrder(backDepth, -2) -- 535
							local dScale = cam:depthScale(backDepth, true) -- 536
							assets:tryPlace( -- 537
								"dp_shadow_contact", -- 537
								"decor_sh_" .. tostring(i), -- 537
								bx, -- 537
								by, -- 537
								cam:len(s.w * 1.15) * dScale, -- 537
								cam:len(7) * dScale, -- 537
								{layer = dLayer - 1, opacity = 0.72} -- 537
							) -- 537
							if s.art == "stove_hearth" then -- 540
								assets:tryPlace( -- 541
									"dp_stove_hearth", -- 541
									"decor_stove_" .. tostring(i), -- 541
									bx, -- 541
									by, -- 541
									cam:len(s.w * 1.1) * dScale, -- 541
									cam:len(28) * dScale, -- 541
									{layer = dLayer} -- 541
								) -- 541
							else -- 541
								assets:tryPlacePath( -- 545
									"assets/art/props_ming.clip|well_curb", -- 545
									"decor_well_" .. tostring(i), -- 545
									bx, -- 545
									by, -- 545
									cam:len(s.w * 1.25) * dScale, -- 545
									cam:len(34) * dScale, -- 545
									{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = dLayer} -- 545
								) -- 545
							end -- 545
						end -- 545
					end -- 545
					goto __continue81 -- 551
				end -- 551
				if s.id == "e3_bench" or s.id == "tower_desk" then -- 553
					goto __continue81 -- 554
				end -- 554
				if not self:isSolidActive(p, s) then -- 557
					goto __continue81 -- 558
				end -- 558
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 561
					goto __continue81 -- 562
				end -- 562
				local x0 = cam:sx(s.x) -- 564
				local x1 = cam:sx(s.x + s.w) -- 565
				if p.room.depth ~= nil and s.depth ~= nil then -- 566
					local opacity = occlusion:update( -- 567
						"solid_" .. tostring(i), -- 567
						{ -- 567
							x0 = s.x, -- 568
							x1 = s.x + s.w, -- 568
							y0 = s.y, -- 568
							y1 = s.y + s.h, -- 568
							depth = s.depth, -- 569
							passThrough = s.passable == true or s.soft == true -- 569
						}, -- 569
						p, -- 570
						fadeDt -- 570
					) -- 570
					if x1 > 0 and x0 < cam.viewW then -- 571
						self:drawDepthSolid( -- 572
							fgDraw, -- 572
							overlayDraw, -- 572
							fgGlow, -- 572
							assets, -- 572
							s, -- 572
							s.depth, -- 572
							x0, -- 572
							x1, -- 572
							cam, -- 572
							theme, -- 572
							opacity, -- 572
							p -- 572
						) -- 572
					end -- 572
					goto __continue81 -- 574
				end -- 574
				local y0 = cam:sy(s.y) -- 576
				local y1 = cam:sy(s.y + s.h) -- 577
				local sw = x1 - x0 -- 578
				local sh = y1 - y0 -- 579
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 580
					goto __continue81 -- 581
				end -- 581
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 585
					local groundY = cam:sy(0) -- 586
					local pierW = cam:len(16) -- 587
					assets:tryPlace( -- 588
						"dp_wall_side", -- 588
						"outside_pier_l_" .. tostring(i), -- 588
						x0 + pierW * 0.5, -- 588
						groundY, -- 588
						pierW, -- 588
						y0 - groundY, -- 588
						{layer = 0} -- 588
					) -- 588
					assets:tryPlace( -- 589
						"dp_wall_side", -- 589
						"outside_pier_r_" .. tostring(i), -- 589
						x1 - pierW * 0.5, -- 589
						groundY, -- 589
						pierW, -- 589
						y0 - groundY, -- 589
						{layer = 0} -- 589
					) -- 589
				end -- 589
				if s.passable == true then -- 593
					if not assets:tryPlace( -- 594
						"grass", -- 594
						"hide_grass_" .. tostring(i), -- 594
						(x0 + x1) * 0.5, -- 594
						y0, -- 594
						sw, -- 594
						sh * 1.55, -- 594
						{opacity = 0.85, layer = 7} -- 595
					) then -- 595
						self:drawGrassCluster( -- 596
							fgDraw, -- 596
							fgGlow, -- 596
							x0, -- 596
							y0, -- 596
							sw, -- 596
							sh, -- 596
							p.player.x, -- 596
							s.x + s.w * 0.5, -- 596
							time -- 596
						) -- 596
					end -- 596
					goto __continue81 -- 598
				end -- 598
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 602
					self:drawWinch( -- 603
						fgDraw, -- 603
						assets, -- 603
						x0, -- 603
						y0, -- 603
						sw, -- 603
						sh, -- 603
						p, -- 603
						2 -- 603
					) -- 603
					goto __continue81 -- 604
				end -- 604
				if p.room.key == "tower" then -- 608
					self:drawTowerStructure( -- 609
						fgDraw, -- 609
						fgGlow, -- 609
						assets, -- 609
						x0, -- 609
						y0, -- 609
						sw, -- 609
						sh, -- 609
						s, -- 609
						p, -- 609
						cam, -- 609
						time -- 609
					) -- 609
					goto __continue81 -- 610
				end -- 610
				if s.art == "red_cart" then -- 614
					assets:tryPlace( -- 615
						"dp_shadow_contact", -- 615
						"red_cart_sh", -- 615
						(x0 + x1) * 0.5, -- 615
						y0 + 1, -- 615
						sw * 1.25, -- 615
						cam:len(8), -- 615
						{layer = 1, opacity = 0.82} -- 615
					) -- 615
					assets:tryPlace( -- 616
						"dp_red_cart", -- 616
						"red_cart_sprite", -- 616
						(x0 + x1) * 0.5, -- 616
						y0, -- 616
						sw * 1.38, -- 616
						sh * 1.15, -- 616
						{layer = 2} -- 616
					) -- 616
					goto __continue81 -- 617
				end -- 617
				if s.h <= 64 and s.y <= 2 then -- 621
					self:drawCoverBlock( -- 622
						overlayDraw, -- 622
						fgGlow, -- 622
						assets, -- 622
						x0, -- 622
						y0, -- 622
						sw, -- 622
						sh, -- 622
						s, -- 622
						p, -- 622
						theme -- 622
					) -- 622
					goto __continue81 -- 623
				end -- 623
				self:tileMasonry( -- 626
					assets, -- 626
					s, -- 626
					x0, -- 626
					y0, -- 626
					sw, -- 626
					sh -- 626
				) -- 626
			end -- 626
			::__continue81:: -- 626
			i = i + 1 -- 526
		end -- 526
	end -- 526
end -- 513
function StageRenderer.prototype.drawDepthSolid(self, draw, overlayDraw, fgGlow, assets, solid, depth, left, right, cam, theme, opacity, p) -- 630
	local width = right - left -- 644
	local base = cam:sy(solid.y, depth.min) -- 645
	local top = cam:sy(solid.y + solid.h, depth.min) -- 646
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 647
	local frontH = top - base -- 648
	local slot = coverArt(solid) -- 649
	local layer = depthOrder(depth.min, 1) -- 650
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 651
	local capHeight = rear - top -- 652
	local center = (left + right) * 0.5 -- 653
	local dShade = cam:depthShade(depth.min, true) -- 654
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 657
		assets:tryPlace( -- 658
			"dp_shadow_contact", -- 658
			"winch_sh_" .. tostring(solid.x), -- 658
			center, -- 658
			base + 1, -- 658
			width * 1.18, -- 658
			cam:len(10), -- 658
			{layer = layer - 1, opacity = 0.82 * opacity} -- 658
		) -- 658
		self:drawWinch( -- 661
			draw, -- 661
			assets, -- 661
			left, -- 661
			base, -- 661
			width, -- 661
			frontH, -- 661
			p, -- 661
			layer -- 661
		) -- 661
		return -- 662
	end -- 662
	if solid.art == "latch" then -- 666
		local groundY = cam:sy(0, depth.min) -- 667
		local postH = math.max(frontH, top - groundY) -- 668
		assets:tryPlace( -- 669
			"dp_shadow_contact", -- 669
			"latch_sh_" .. tostring(solid.x), -- 669
			center, -- 669
			groundY + 1, -- 669
			width * 1.1, -- 669
			cam:len(8), -- 669
			{layer = layer - 1, opacity = 0.78 * opacity} -- 669
		) -- 669
		assets:tryPlace( -- 672
			"fe_pillar_wood", -- 672
			"latch_post_" .. tostring(solid.x), -- 672
			right - cam:len(6), -- 672
			groundY, -- 672
			cam:len(12), -- 672
			postH + cam:len(10), -- 672
			{ -- 672
				layer = layer, -- 673
				opacity = opacity, -- 673
				color = occlusionTint(opacity) -- 673
			} -- 673
		) -- 673
		assets:tryPlace( -- 675
			"dp_latch", -- 675
			key, -- 675
			center, -- 675
			base - cam:len(4), -- 675
			math.max( -- 675
				width * 1.3, -- 675
				cam:len(36) -- 675
			), -- 675
			math.max( -- 675
				frontH * 1.3, -- 675
				cam:len(32) -- 675
			), -- 675
			{ -- 675
				layer = layer + 1, -- 676
				opacity = opacity, -- 676
				color = occlusionTint(opacity) -- 676
			} -- 676
		) -- 676
		fillRadialGlow( -- 678
			fgGlow, -- 678
			center - cam:len(6), -- 678
			base + frontH * 0.5, -- 678
			cam:len(18), -- 678
			cam:len(14), -- 678
			Color( -- 679
				238, -- 679
				168, -- 679
				72, -- 679
				math.floor(58 * opacity + 0.5) -- 679
			), -- 679
			Color(238, 168, 72, 0), -- 679
			10 -- 679
		) -- 679
		return -- 680
	end -- 680
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 683
		assets:tryPlace( -- 684
			"slab", -- 684
			"gate_sill_" .. tostring(solid.x), -- 684
			center, -- 684
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 684
			width + cam:len(34), -- 685
			cam:len(12), -- 685
			{ -- 685
				layer = 1, -- 685
				color = Color(180, 169, 150, 255) -- 685
			} -- 685
		) -- 685
		if p.room.key ~= "gate" then -- 687
			local beamY = cam:sy(solid.y + solid.h - 10, LANE_DEPTH.lower) -- 688
			local beamW = math.max( -- 689
				width * 2.8, -- 689
				cam:len(92) -- 689
			) -- 689
			local beamH = cam:len(26) -- 690
			assets:tryPlace( -- 691
				"dp_gate_arch_beam", -- 691
				"gate_beam_" .. tostring(solid.x), -- 691
				center, -- 691
				beamY, -- 691
				beamW, -- 691
				beamH, -- 691
				{ -- 691
					layer = depthOrder(LANE_DEPTH.lower, 3), -- 692
					opacity = math.min(1, opacity + 0.12) -- 693
				} -- 693
			) -- 693
		end -- 693
	end -- 693
	local shadowH = math.max( -- 699
		cam:len(6), -- 699
		cam:sy(solid.y, depth.max) - base + cam:len(5) -- 699
	) -- 699
	assets:tryPlace( -- 700
		"dp_shadow_contact", -- 700
		(("solid_sh_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 700
		center, -- 700
		base + shadowH * 0.32, -- 700
		width * 1.14, -- 701
		shadowH * 1.15, -- 701
		{layer = layer - 1, opacity = 0.78 * opacity} -- 701
	) -- 701
	local propArt = dedicatedSolidProp(solid) -- 707
	if propArt ~= nil then -- 708
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 709
		local drawH = frontH * propArt.heightMul -- 710
		local cols = propArt.tileable and math.max( -- 711
			1, -- 712
			math.min( -- 712
				6, -- 712
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 712
			) -- 712
		) or 1 -- 713
		local colW = width / cols -- 714
		local tint = occlusionTint( -- 715
			opacity, -- 715
			tintByShade( -- 715
				Color(238, 240, 246, 255), -- 715
				dShade -- 715
			) -- 715
		) -- 715
		local placedProp = false -- 716
		do -- 716
			local col = 0 -- 717
			while col < cols do -- 717
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 718
				if assets:tryPlacePath( -- 719
					propPath, -- 719
					tileKey, -- 719
					left + (col + 0.5) * colW, -- 719
					base, -- 719
					colW + 1, -- 719
					drawH, -- 719
					{ -- 719
						anchorX = 0.5, -- 720
						anchorY = 0, -- 721
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 722
						opacity = opacity, -- 723
						color = tint, -- 724
						layer = layer -- 725
					} -- 725
				) then -- 725
					placedProp = true -- 727
				end -- 727
				col = col + 1 -- 717
			end -- 717
		end -- 717
		if placedProp then -- 730
			return -- 731
		end -- 731
	end -- 731
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 735
	local isStoneCover = slot == "cover_stone" -- 736
	local isSoftCloth = solid.soft == true or solid.art == "curtain" -- 737
	local visCapH = solid.y >= 100 and math.min( -- 738
		capHeight, -- 738
		cam:len(10) -- 738
	) or capHeight -- 738
	if slot ~= "fence" and not isSoftCloth and visCapH > 2 and frontH > 8 then -- 741
		local viewShift = (cam.viewW * 0.5 - center) / math.max(240, cam.viewW * 0.5) -- 742
		local sidePx = math.min( -- 743
			cam:len(14), -- 743
			math.abs(viewShift) * visCapH * 0.65 -- 743
		) -- 743
		if sidePx >= 2.2 then -- 744
			local sideSlot = timber and "dp_wood_side" or (isStoneCover and "dp_stone_side" or "dp_wall_side") -- 745
			local sideX = viewShift > 0 and right + sidePx * 0.5 or left - sidePx * 0.5 -- 746
			assets:tryPlace( -- 747
				sideSlot, -- 747
				(("side_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 747
				sideX, -- 747
				base + visCapH * 0.35, -- 747
				sidePx + 0.6, -- 747
				frontH, -- 747
				{ -- 747
					layer = layer - 1, -- 748
					opacity = math.min(1, opacity * 0.92), -- 749
					color = occlusionTint( -- 750
						opacity, -- 750
						tintByShade( -- 750
							Color(210, 218, 228, 255), -- 750
							dShade -- 750
						) -- 750
					) -- 750
				} -- 750
			) -- 750
		end -- 750
	end -- 750
	if isSoftCloth then -- 756
		assets:tryPlace( -- 757
			"fe_beam_wood", -- 757
			(("cap_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 757
			center, -- 757
			top - 1, -- 757
			width + 4, -- 757
			math.max( -- 757
				3, -- 757
				cam:len(4) -- 757
			), -- 757
			{ -- 757
				opacity = math.min(1, opacity), -- 758
				color = occlusionTint( -- 759
					opacity, -- 759
					Color(148, 122, 96, 255) -- 759
				), -- 759
				layer = layer + 1 -- 760
			} -- 760
		) -- 760
	elseif slot ~= "fence" and visCapH > 1 then -- 762
		local capSlot = timber and "dp_wood_top" or (isStoneCover and "dp_stone_top" or "dp_wall_top") -- 763
		local capTint = occlusionTint( -- 764
			opacity, -- 764
			tintByShade( -- 764
				Color(246, 248, 252, 255), -- 764
				dShade -- 764
			) -- 764
		) -- 764
		assets:tryPlace( -- 765
			capSlot, -- 765
			(("cap_" .. tostring(solid.x)) .. "_") .. tostring(depth.min), -- 765
			center, -- 765
			top - 0.5, -- 765
			width + 0.6, -- 765
			visCapH + 1, -- 765
			{ -- 765
				opacity = math.min(1, opacity), -- 766
				color = capTint, -- 767
				layer = layer -- 768
			} -- 768
		) -- 768
	end -- 768
	if timber and solid.h > solid.w * 1.6 then -- 773
		local segs = math.max( -- 774
			1, -- 774
			math.min( -- 774
				6, -- 774
				math.floor(solid.h / math.max(24, solid.w * 3.5) + 0.5) -- 774
			) -- 774
		) -- 774
		local segH = frontH / segs -- 775
		local colTint = occlusionTint( -- 776
			opacity, -- 776
			tintByShade( -- 776
				Color(255, 255, 255, 255), -- 776
				dShade -- 776
			) -- 776
		) -- 776
		do -- 776
			local pi = 0 -- 777
			while pi < segs do -- 777
				local tk = pi == 0 and key or (key .. "_p") .. tostring(pi) -- 778
				assets:tryPlace( -- 779
					"fe_pillar_wood", -- 779
					tk, -- 779
					center, -- 779
					base + pi * segH, -- 779
					width + 0.5, -- 779
					segH + 0.5, -- 779
					{layer = layer, opacity = opacity, color = colTint} -- 779
				) -- 779
				pi = pi + 1 -- 777
			end -- 777
		end -- 777
		return -- 783
	end -- 783
	if solid.w > solid.h * 5 then -- 787
		local segs = math.max( -- 788
			2, -- 788
			math.min( -- 788
				12, -- 788
				math.floor(solid.w / 64 + 0.5) -- 788
			) -- 788
		) -- 788
		local segW = width / segs -- 789
		local beamH = math.max(5, frontH) -- 790
		local beamTint = occlusionTint( -- 791
			opacity, -- 791
			tintByShade( -- 791
				Color(255, 255, 255, 255), -- 791
				dShade -- 791
			) -- 791
		) -- 791
		do -- 791
			local bi = 0 -- 792
			while bi < segs do -- 792
				local tk = bi == 0 and key or (key .. "_b") .. tostring(bi) -- 793
				assets:tryPlace( -- 794
					"fe_beam_wood", -- 794
					tk, -- 794
					left + (bi + 0.5) * segW, -- 794
					base, -- 794
					segW + 0.5, -- 794
					beamH, -- 794
					{layer = layer, opacity = opacity, color = beamTint} -- 794
				) -- 794
				bi = bi + 1 -- 792
			end -- 792
		end -- 792
		return -- 798
	end -- 798
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 802
	local cols = slot == "wall" and math.max( -- 803
		1, -- 804
		math.min( -- 804
			10, -- 804
			math.floor(solid.w / 72 + 0.5) -- 804
		) -- 804
	) or math.max( -- 805
		1, -- 805
		math.min( -- 805
			10, -- 805
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 805
		) -- 805
	) -- 805
	local colW = width / cols -- 806
	local rows = slot == "wall" and math.max( -- 807
		1, -- 808
		math.min( -- 808
			10, -- 808
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 808
		) -- 808
	) or math.max( -- 809
		1, -- 809
		math.min( -- 809
			6, -- 809
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 809
		) -- 809
	) -- 809
	local rowHeight = frontH / rows -- 810
	local baseColor = slot == "wall" and Color(216, 224, 234, 255) or Color(255, 255, 255, 255) -- 811
	local color = occlusionTint( -- 812
		opacity, -- 812
		tintByShade(baseColor, dShade) -- 812
	) -- 812
	do -- 812
		local row = 0 -- 813
		while row < rows do -- 813
			do -- 813
				local col = 0 -- 814
				while col < cols do -- 814
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 815
					assets:tryPlace( -- 816
						slot, -- 816
						tileKey, -- 816
						left + (col + 0.5) * colW, -- 816
						base + row * rowHeight, -- 816
						colW + 0.5, -- 816
						rowHeight + 0.5, -- 816
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 816
					) -- 816
					col = col + 1 -- 814
				end -- 814
			end -- 814
			row = row + 1 -- 813
		end -- 813
	end -- 813
	if not p.childMode and solid.h <= 64 and solid.y <= 2 and (p.coverHug or p.coverNear) then -- 823
		local plx = p.player.x -- 824
		local nearLeft = math.abs(plx - solid.x) < 42 -- 825
		local nearRight = math.abs(plx - (solid.x + solid.w)) < 42 -- 826
		if (nearLeft or nearRight) and math.abs(p.player.depth - (depth.min + depth.max) * 0.5) <= 28 then -- 827
			local edgeX = nearLeft and left - 1.5 or right + 1.5 -- 828
			local col = p.coverHug and (timber and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 829
			overlayDraw:drawSegment( -- 830
				Vec2(edgeX, base + 3), -- 830
				Vec2(edgeX, top + 2), -- 830
				p.coverHug and 2.2 or 1.3, -- 830
				toColor(col, p.coverHug and 220 or 125) -- 830
			) -- 830
		end -- 830
	end -- 830
end -- 630
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 835
	local columns = math.max( -- 840
		1, -- 840
		math.min( -- 840
			10, -- 840
			math.floor(s.w / 58 + 0.5) -- 840
		) -- 840
	) -- 840
	local cellWorldW = s.w / columns -- 841
	local targetCellH = math.max( -- 842
		24, -- 842
		math.min(48, cellWorldW / 1.52) -- 842
	) -- 842
	local rows = math.max( -- 843
		1, -- 843
		math.min( -- 843
			12, -- 843
			math.floor(s.h / targetCellH + 0.5) -- 843
		) -- 843
	) -- 843
	local tileW = width / columns -- 844
	local tileH = height / rows -- 845
	do -- 845
		local row = 0 -- 846
		while row < rows do -- 846
			do -- 846
				local column = 0 -- 847
				while column < columns do -- 847
					assets:tryPlace( -- 848
						"wall", -- 848
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 848
						x + (column + 0.5) * tileW, -- 849
						y + row * tileH, -- 849
						tileW + 0.5, -- 849
						tileH + 0.5, -- 849
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 850
					) -- 850
					column = column + 1 -- 847
				end -- 847
			end -- 847
			row = row + 1 -- 846
		end -- 846
	end -- 846
end -- 835
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 855
	local slot = coverArt(s) -- 862
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 863
	local cols = math.max( -- 864
		1, -- 864
		math.min( -- 864
			8, -- 864
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 864
		) -- 864
	) -- 864
	local tileW = sw / cols -- 865
	local placed = false -- 866
	do -- 866
		local c = 0 -- 867
		while c < cols do -- 867
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 868
			if assets:tryPlace( -- 869
				slot, -- 869
				k, -- 869
				x0 + (c + 0.5) * tileW, -- 869
				y0, -- 869
				tileW + 0.5, -- 869
				sh, -- 869
				{layer = 1} -- 869
			) then -- 869
				placed = true -- 870
			end -- 870
			c = c + 1 -- 867
		end -- 867
	end -- 867
	if not placed then -- 873
		fillVGradRect( -- 874
			fgDraw, -- 874
			x0, -- 874
			y0, -- 874
			sw, -- 874
			sh, -- 874
			toColor(PALETTE.steelDark), -- 874
			toColor(PALETTE.steelMid) -- 874
		) -- 874
		fgDraw:drawSegment( -- 875
			Vec2(x0, y0 + sh), -- 875
			Vec2(x0 + sw, y0 + sh), -- 875
			1.4, -- 875
			toColor(theme.groundRim) -- 875
		) -- 875
	end -- 875
	if not p.childMode and (p.coverHug or p.coverNear) then -- 879
		local plx = p.player.x -- 880
		local nearLeft = math.abs(plx - s.x) < 42 -- 881
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 882
		if nearLeft or nearRight then -- 883
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 884
			local isWood = slot == "cover_wood" -- 885
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 886
			fgDraw:drawSegment( -- 887
				Vec2(edgeX, y0 + 4), -- 887
				Vec2(edgeX, y0 + sh + 2), -- 887
				p.coverHug and 2 or 1.2, -- 887
				toColor(col, p.coverHug and 205 or 120) -- 887
			) -- 887
		end -- 887
	end -- 887
end -- 855
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 895
	if layer == nil then -- 900
		layer = 2 -- 900
	end -- 900
	local cx = x0 + sw * 0.5 -- 902
	local cy = y0 + sh * 0.55 -- 903
	local ropeWidth = math.max(1, sw * 0.023) -- 904
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 905
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 906
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 907
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 908
	draw:drawSegment( -- 909
		drum, -- 909
		bend, -- 909
		ropeWidth, -- 909
		Color(111, 86, 57, 239) -- 909
	) -- 909
	draw:drawSegment( -- 910
		bend, -- 910
		ropeTop, -- 910
		ropeWidth, -- 910
		Color(111, 86, 57, 239) -- 910
	) -- 910
	assets:tryPlace( -- 911
		"prop_winch", -- 911
		"gate_winch", -- 911
		cx, -- 911
		y0 + sh * 0.5, -- 911
		sw, -- 911
		sh, -- 911
		{layer = layer} -- 911
	) -- 911
end -- 895
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 914
	local ____temp_3 -- 922
	if p.room.story ~= nil then -- 922
		____temp_3 = p.room.story.gate -- 922
	else -- 922
		____temp_3 = nil -- 922
	end -- 922
	local g = ____temp_3 -- 922
	if g == nil then -- 923
		return -- 924
	end -- 924
	local closeFrac = 0.08 -- 927
	if p.phase == "gate-hold" then -- 928
		closeFrac = 0.08 + 0.36 * math.min( -- 929
			1, -- 929
			p.gateTick / math.max(1, g.holdTicks) -- 929
		) -- 929
	elseif p.phase == "gate-send" then -- 930
		closeFrac = 0.44 -- 931
	elseif p.phase == "gate-count" then -- 932
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 933
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 934
		closeFrac = 1 -- 935
	end -- 935
	local gx0 = cam:sx(864) -- 937
	local gx1 = cam:sx(1016) -- 938
	local topY = cam:sy(160) -- 939
	local botY = cam:sy(160 * (1 - closeFrac)) -- 940
	local shutterW = gx1 - gx0 -- 941
	local shutterH = topY - botY -- 942
	if shutterH > 2 then -- 943
		fillVGradRect( -- 944
			fgDraw, -- 944
			gx0, -- 944
			botY, -- 944
			shutterW, -- 944
			shutterH, -- 944
			toColor(PALETTE.steelDark), -- 944
			toColor(PALETTE.steelMid) -- 944
		) -- 944
		local rows = math.max( -- 946
			1, -- 946
			math.min( -- 946
				6, -- 946
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 946
			) -- 946
		) -- 946
		local rowH = shutterH / rows -- 947
		do -- 947
			local r = 0 -- 948
			while r < rows do -- 948
				assets:tryPlace( -- 949
					"cover_wood", -- 949
					"gate_shutter_" .. tostring(r), -- 949
					(gx0 + gx1) * 0.5, -- 949
					botY + r * rowH, -- 949
					shutterW, -- 950
					rowH + 0.5, -- 950
					{layer = depthOrder(0, 2)} -- 950
				) -- 950
				r = r + 1 -- 948
			end -- 948
		end -- 948
	end -- 948
	if closeFrac < 0.98 then -- 954
		local gapH = math.max( -- 955
			8, -- 955
			botY - cam:sy(0) -- 955
		) -- 955
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 956
		fillVGradRect( -- 957
			fgGlow, -- 957
			gx0, -- 957
			cam:sy(0), -- 957
			gx1 - gx0, -- 957
			gapH, -- 957
			Color( -- 957
				140, -- 957
				210, -- 957
				255, -- 957
				math.floor(52 * pulse + 0.5) -- 957
			), -- 957
			Color(80, 160, 230, 0) -- 957
		) -- 957
	end -- 957
end -- 914
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 961
	if s.id == "tower_door" then -- 969
		return -- 970
	end -- 970
	fillVGradRect( -- 972
		fgDraw, -- 972
		x0, -- 972
		y0, -- 972
		sw, -- 972
		sh, -- 972
		Color(14, 19, 30, 255), -- 972
		Color(26, 36, 54, 255) -- 972
	) -- 972
	fgDraw:drawRect( -- 973
		Rect(x0, y0, sw, sh), -- 973
		Color(0, 0, 0, 0), -- 973
		1, -- 973
		Color(42, 54, 72, 145) -- 973
	) -- 973
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 975
		self:tileMasonry( -- 976
			assets, -- 976
			s, -- 976
			x0, -- 976
			y0, -- 976
			sw, -- 976
			sh -- 976
		) -- 976
		if s.w >= 60 then -- 977
			local ribs = 4 -- 979
			local r = 1 -- 980
			do -- 980
				r = 1 -- 981
				while r < ribs do -- 981
					local rx = x0 + sw * r / ribs -- 982
					fgDraw:drawSegment( -- 983
						Vec2(rx, y0), -- 983
						Vec2(rx, y0 + sh), -- 983
						2, -- 983
						Color(10, 15, 24, 210) -- 983
					) -- 983
					fgDraw:drawSegment( -- 984
						Vec2(rx + 2, y0), -- 984
						Vec2(rx + 2, y0 + sh), -- 984
						1, -- 984
						Color(68, 86, 114, 130) -- 984
					) -- 984
					r = r + 1 -- 981
				end -- 981
			end -- 981
			local bands = 4 -- 987
			local b = 1 -- 988
			do -- 988
				b = 1 -- 989
				while b < bands do -- 989
					local by = y0 + sh * b / bands -- 990
					fgDraw:drawSegment( -- 991
						Vec2(x0 + 4, by), -- 991
						Vec2(x0 + sw - 4, by), -- 991
						1.2, -- 991
						Color(52, 68, 92, 135) -- 991
					) -- 991
					b = b + 1 -- 989
				end -- 989
			end -- 989
			local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 994
			local slitY = y0 + sh * 0.56 -- 995
			local slitH = sh * 0.22 -- 996
			fgDraw:drawRect( -- 997
				Rect(slitX - 5, slitY, 10, slitH), -- 997
				Color(8, 12, 20, 245), -- 997
				1.2, -- 997
				toColor(PALETTE.amberDim, 190) -- 997
			) -- 997
			fgGlow:drawRect( -- 998
				Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 998
				toColor(PALETTE.amber, 190) -- 998
			) -- 998
			fillRadialGlow( -- 999
				fgGlow, -- 999
				slitX, -- 999
				slitY + slitH * 0.5, -- 999
				44, -- 999
				slitH * 0.7, -- 999
				Color(255, 206, 128, 52), -- 999
				Color(255, 180, 86, 0), -- 999
				14 -- 999
			) -- 999
		end -- 999
	end -- 999
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1004
		self:tileMasonry( -- 1005
			assets, -- 1005
			s, -- 1005
			x0, -- 1005
			y0, -- 1005
			sw, -- 1005
			sh -- 1005
		) -- 1005
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1006
		local cx = x0 + sw * 0.5 -- 1011
		local lampY = y0 - 8 -- 1012
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1013
		if not opened then -- 1014
			assets:tryPlace( -- 1015
				"prop_tower_door", -- 1015
				"tower_door", -- 1015
				cx, -- 1015
				y0 - doorHeight, -- 1015
				sw, -- 1015
				doorHeight, -- 1015
				{layer = 2} -- 1015
			) -- 1015
		end -- 1015
		assets:tryPlace( -- 1017
			"prop_lantern", -- 1017
			"tower_lantern", -- 1017
			cx + sw * 0.43, -- 1017
			lampY - sh * 0.36, -- 1017
			sw * 0.17, -- 1018
			sh * 0.84, -- 1018
			{layer = 3} -- 1018
		) -- 1018
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1019
		local alpha = opened and 58 or 42 -- 1020
		fgDraw:drawSegment( -- 1022
			Vec2(x0 + 4, y0), -- 1022
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1022
			4, -- 1022
			Color(42, 52, 70, 255) -- 1022
		) -- 1022
		fgDraw:drawSegment( -- 1023
			Vec2(x0 + sw - 4, y0), -- 1023
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1023
			4, -- 1023
			Color(42, 52, 70, 255) -- 1023
		) -- 1023
		fgDraw:drawSegment( -- 1024
			Vec2(x0, y0), -- 1024
			Vec2(x0 + sw, y0), -- 1024
			2.5, -- 1024
			toColor(PALETTE.amber, 210) -- 1024
		) -- 1024
		fillVGradRect( -- 1026
			fgGlow, -- 1027
			x0 + 6, -- 1028
			y0 - sh * 3.8, -- 1029
			sw - 12, -- 1030
			sh * 3.8, -- 1031
			Color( -- 1032
				246, -- 1032
				196, -- 1032
				118, -- 1032
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1032
			), -- 1032
			Color(246, 206, 142, opened and 74 or 38) -- 1033
		) -- 1033
		fillRadialGlow( -- 1035
			fgGlow, -- 1035
			cx, -- 1035
			lampY, -- 1035
			opened and 78 or 54, -- 1035
			opened and 72 or 52, -- 1035
			Color( -- 1035
				252, -- 1035
				218, -- 1035
				152, -- 1035
				math.floor(92 * pulse + 0.5) -- 1035
			), -- 1035
			Color(255, 180, 86, 0), -- 1035
			18 -- 1035
		) -- 1035
		fgDraw:drawCircle( -- 1036
			Vec2(cx, lampY), -- 1036
			4.5, -- 1036
			toColor(PALETTE.amberCore) -- 1036
		) -- 1036
		if opened then -- 1039
			local deskCx = cam:sx(p.ox + 605) -- 1040
			local groundY = cam:sy(0) -- 1041
			local deskW = cam:len(84) -- 1042
			local deskH = cam:len(34) -- 1043
			local deskTop = groundY + deskH -- 1044
			local writing = p.deskHold >= 24 or p.towerHanded -- 1045
			fillRadialGlow( -- 1047
				fgGlow, -- 1047
				deskCx, -- 1047
				deskTop + cam:len(26), -- 1047
				cam:len(96), -- 1047
				cam:len(74), -- 1047
				Color( -- 1048
					255, -- 1048
					198, -- 1048
					114, -- 1048
					math.floor(52 * pulse + 0.5) -- 1048
				), -- 1048
				Color(255, 168, 72, 0), -- 1048
				16 -- 1048
			) -- 1048
			local guardX = deskCx + cam:len(26) -- 1050
			local guardFrame = math.floor(time * (writing and 3.2 or 3.8)) % 4 -- 1051
			local guardClip = writing and GUARD_WRITE_CLIPS[guardFrame + 1] or GUARD_LANTERN_CLIPS[guardFrame + 1] -- 1052
			if not assets:tryPlacePath( -- 1055
				guardClip, -- 1055
				"tower_guard_npc", -- 1055
				guardX, -- 1055
				groundY, -- 1055
				cam:len(54), -- 1055
				cam:len(86), -- 1055
				{ -- 1055
					anchorX = 0.5, -- 1056
					anchorY = 0, -- 1057
					preserveAspect = true, -- 1058
					facing = -1, -- 1059
					opacity = 0.96, -- 1060
					layer = 3 -- 1061
				} -- 1061
			) then -- 1061
				fgDraw:drawRect( -- 1063
					Rect( -- 1063
						guardX - cam:len(11), -- 1063
						groundY, -- 1063
						cam:len(22), -- 1063
						cam:len(68) -- 1063
					), -- 1063
					Color(34, 42, 54, 240) -- 1063
				) -- 1063
				fgDraw:drawCircle( -- 1064
					Vec2( -- 1064
						guardX, -- 1064
						groundY + cam:len(76) -- 1064
					), -- 1064
					cam:len(9.5), -- 1064
					Color(42, 50, 62, 245) -- 1064
				) -- 1064
			end -- 1064
			if not assets:tryPlace( -- 1067
				"prop_table", -- 1067
				"tower_guard_desk", -- 1067
				deskCx, -- 1067
				groundY, -- 1067
				deskW * 1.06, -- 1067
				deskH * 1.04, -- 1067
				{ -- 1067
					color = Color(214, 188, 158, 255), -- 1068
					opacity = 0.98, -- 1069
					layer = 4 -- 1070
				} -- 1070
			) then -- 1070
				fgDraw:drawRect( -- 1072
					Rect( -- 1072
						deskCx - deskW * 0.5, -- 1072
						groundY, -- 1072
						cam:len(6), -- 1072
						deskH -- 1072
					), -- 1072
					Color(78, 52, 34, 255) -- 1072
				) -- 1072
				fgDraw:drawRect( -- 1073
					Rect( -- 1073
						deskCx + deskW * 0.5 - cam:len(6), -- 1073
						groundY, -- 1073
						cam:len(6), -- 1073
						deskH -- 1073
					), -- 1073
					Color(78, 52, 34, 255) -- 1073
				) -- 1073
				fgDraw:drawRect( -- 1074
					Rect( -- 1074
						deskCx - deskW * 0.52, -- 1074
						deskTop - cam:len(6), -- 1074
						deskW * 1.04, -- 1074
						cam:len(8) -- 1074
					), -- 1074
					Color(108, 74, 46, 255), -- 1074
					1, -- 1074
					Color(148, 108, 68, 220) -- 1074
				) -- 1074
			end -- 1074
			fgDraw:drawRect( -- 1077
				Rect( -- 1077
					deskCx + cam:len(4), -- 1077
					deskTop + cam:len(1), -- 1077
					cam:len(22), -- 1077
					cam:len(4.5) -- 1077
				), -- 1077
				Color(232, 222, 198, 245) -- 1077
			) -- 1077
			if writing then -- 1078
				assets:tryPlace( -- 1079
					"prop_lantern", -- 1079
					"tower_desk_lamp", -- 1079
					deskCx + cam:len(34), -- 1079
					deskTop + cam:len(10), -- 1079
					cam:len(14), -- 1079
					cam:len(20), -- 1079
					{layer = 5} -- 1079
				) -- 1079
				fillRadialGlow( -- 1080
					fgGlow, -- 1080
					deskCx + cam:len(34), -- 1080
					deskTop + cam:len(12), -- 1080
					cam:len(24), -- 1080
					cam:len(22), -- 1080
					Color( -- 1080
						255, -- 1080
						214, -- 1080
						134, -- 1080
						math.floor(88 * pulse + 0.5) -- 1080
					), -- 1080
					Color(255, 180, 86, 0), -- 1080
					12 -- 1080
				) -- 1080
			else -- 1080
				fillRadialGlow( -- 1082
					fgGlow, -- 1082
					deskCx + cam:len(3), -- 1082
					deskTop + cam:len(18), -- 1082
					cam:len(30), -- 1082
					cam:len(28), -- 1082
					Color( -- 1082
						255, -- 1082
						214, -- 1082
						134, -- 1082
						math.floor(78 * pulse + 0.5) -- 1082
					), -- 1082
					Color(255, 180, 86, 0), -- 1082
					12 -- 1082
				) -- 1082
			end -- 1082
			if p.deskHold >= 12 or p.towerHanded then -- 1085
				if not assets:tryPlacePath( -- 1086
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1086
					"tower_desk_pouch", -- 1086
					deskCx - cam:len(22), -- 1086
					deskTop + cam:len(8), -- 1086
					cam:len(18), -- 1086
					cam:len(18), -- 1086
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1086
				) then -- 1086
					fgDraw:drawRect( -- 1092
						Rect( -- 1092
							deskCx - cam:len(28), -- 1092
							deskTop + cam:len(2), -- 1092
							cam:len(14), -- 1092
							cam:len(6) -- 1092
						), -- 1092
						Color(156, 62, 48, 245) -- 1092
					) -- 1092
				end -- 1092
			end -- 1092
			if writing then -- 1095
				fgDraw:drawRect( -- 1096
					Rect( -- 1096
						deskCx - cam:len(6), -- 1096
						deskTop + cam:len(2), -- 1096
						cam:len(10), -- 1096
						cam:len(3) -- 1096
					), -- 1096
					Color(236, 228, 206, 240) -- 1096
				) -- 1096
			end -- 1096
		end -- 1096
	end -- 1096
end -- 961
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1102
	local blades = math.max( -- 1109
		12, -- 1109
		math.floor(sw / 8) -- 1109
	) -- 1109
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1110
	local k = 0 -- 1111
	do -- 1111
		k = 0 -- 1112
		while k < blades do -- 1112
			local t = (k + 0.5) / blades -- 1113
			local bx = x0 + sw * t -- 1114
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1115
			local bh = sh * hRatio * 1.95 -- 1116
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1117
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1118
			fgDraw:drawPolygon( -- 1119
				{ -- 1119
					Vec2(bx - 7, y0), -- 1120
					Vec2(bx + 7, y0), -- 1121
					Vec2(bx + sway, y0 + bh) -- 1122
				}, -- 1122
				col -- 1123
			) -- 1123
			k = k + 1 -- 1112
		end -- 1112
	end -- 1112
	if nearPlayer then -- 1125
		fgGlow:drawSegment( -- 1126
			Vec2(x0, y0 + 2), -- 1126
			Vec2(x0 + sw, y0 + 2), -- 1126
			2, -- 1126
			toColor(PALETTE.emerald, 145) -- 1126
		) -- 1126
	end -- 1126
end -- 1102
function StageRenderer.prototype.drawArch(self, draw, assets, p, cam) -- 1130
	local a = p.room.arch -- 1136
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1137
		return -- 1138
	end -- 1138
	local x0 = cam:sx(a.x0) -- 1140
	local x1 = cam:sx(a.x1) -- 1141
	local y0 = cam:sy(a.y) -- 1142
	local y1 = cam:sy(a.y + a.h) -- 1143
	local cx = (x0 + x1) * 0.5 -- 1144
	local aw = x1 - x0 -- 1145
	local ah = y1 - y0 -- 1146
	draw:drawRect( -- 1147
		Rect( -- 1147
			x0, -- 1147
			y0, -- 1147
			aw, -- 1147
			ah + cam:len(8) -- 1147
		), -- 1147
		Color(13, 15, 20, 242) -- 1147
	) -- 1147
	if not assets:tryPlace( -- 1148
		"fe_outside_arch", -- 1148
		"outside_arch_vault", -- 1148
		cx, -- 1148
		y0, -- 1148
		aw + cam:len(24), -- 1148
		ah + cam:len(22), -- 1148
		{layer = 2} -- 1148
	) then -- 1148
		draw:drawRect( -- 1149
			Rect( -- 1149
				x0 - cam:len(7), -- 1149
				y0, -- 1149
				cam:len(7), -- 1149
				ah -- 1149
			), -- 1149
			Color(62, 63, 67, 255) -- 1149
		) -- 1149
		draw:drawRect( -- 1150
			Rect( -- 1150
				x1, -- 1150
				y0, -- 1150
				cam:len(7), -- 1150
				ah -- 1150
			), -- 1150
			Color(72, 72, 74, 255) -- 1150
		) -- 1150
	end -- 1150
	if not p.cartDocked then -- 1153
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1154
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1155
		if bx1 > bx0 + 4 then -- 1156
			local deckY = cam:sy(p.room.cart.baseY) -- 1157
			assets:tryPlace( -- 1158
				"fe_pillar_wood", -- 1158
				"outside_arch_bolt", -- 1158
				(bx0 + bx1) * 0.5, -- 1158
				y0 + 2, -- 1158
				bx1 - bx0, -- 1158
				ah - 2, -- 1158
				{layer = 3} -- 1158
			) -- 1158
			draw:drawSegment( -- 1159
				Vec2((bx0 + bx1) * 0.5, y1), -- 1159
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1159
				2.4, -- 1159
				Color(96, 102, 110, 220) -- 1159
			) -- 1159
		end -- 1159
	end -- 1159
end -- 1130
return ____exports -- 1130
