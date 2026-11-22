-- [ts]: app.ts
local ____exports = {} -- 1
local place, applySize, tick, redraw, applyPool, auditLayout, collectOne, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local DrawNode = ____Dora.DrawNode -- 8
local Label = ____Dora.Label -- 8
local Rect = ____Dora.Rect -- 8
local Size = ____Dora.Size -- 8
local Vec2 = ____Dora.Vec2 -- 8
local View = ____Dora.View -- 8
local ____graybox = require("Script.watch.graybox") -- 9
local collectLabels = ____graybox.collectLabels -- 9
local computeView = ____graybox.computeView -- 9
local drawScaleRuler = ____graybox.drawScaleRuler -- 9
local renderWorld = ____graybox.renderWorld -- 9
local ____keys = require("Script.watch.keys") -- 10
local CART_NOTE = ____keys.CART_NOTE -- 10
local HINTS = ____keys.HINTS -- 10
local RULER_TEXT = ____keys.RULER_TEXT -- 10
local STAND_NOTE = ____keys.STAND_NOTE -- 10
local SWITCH_HINT = ____keys.SWITCH_HINT -- 10
local TITLE = ____keys.TITLE -- 10
local ____rooms = require("Script.watch.rooms") -- 11
local ROOMS = ____rooms.ROOMS -- 11
function place(lb, x, y, ax, ay) -- 68
	if lb == nil then -- 68
		return -- 70
	end -- 70
	lb.position = Vec2(x, y) -- 72
	lb.anchor = Vec2(ax, ay) -- 73
	lb.visible = true -- 74
end -- 74
function applySize() -- 127
	if root == nil then -- 127
		return -- 129
	end -- 129
	root.size = Size(viewW, viewH) -- 131
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 132
end -- 132
function tick() -- 135
	local w = View.size.width -- 136
	local h = View.size.height -- 137
	if w ~= viewW or h ~= viewH then -- 137
		viewW = w -- 139
		viewH = h -- 140
		applySize() -- 141
		dirty = true -- 142
	end -- 142
	if dirty then -- 142
		redraw() -- 145
		dirty = false -- 146
	end -- 146
end -- 146
function redraw() -- 150
	if draw == nil then -- 150
		return -- 152
	end -- 152
	local w = viewW -- 154
	local h = viewH -- 155
	local room = ROOMS[current + 1] -- 156
	draw:clear() -- 158
	draw:drawRect( -- 161
		Rect(0, h - TOP_H, w, TOP_H), -- 161
		C_BG -- 161
	) -- 161
	draw:drawRect( -- 162
		Rect(0, 0, w, BOTTOM_H), -- 162
		C_BG -- 162
	) -- 162
	draw:drawSegment( -- 163
		Vec2(0, h - TOP_H), -- 163
		Vec2(w, h - TOP_H), -- 163
		1, -- 163
		Color(52, 54, 54, 255) -- 163
	) -- 163
	draw:drawSegment( -- 164
		Vec2(0, BOTTOM_H), -- 164
		Vec2(w, BOTTOM_H), -- 164
		1, -- 164
		Color(52, 54, 54, 255) -- 164
	) -- 164
	local v = computeView(room, w, h) -- 166
	renderWorld( -- 167
		draw, -- 167
		room, -- 167
		v, -- 167
		w, -- 167
		h -- 167
	) -- 167
	local roomTop = v.groundPx + room.height * v.scale -- 169
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 170
	place( -- 172
		titleLabel, -- 172
		48, -- 172
		h - 40, -- 172
		0, -- 172
		1 -- 172
	) -- 172
	place( -- 173
		roomLabel, -- 173
		48, -- 173
		h - 96, -- 173
		0, -- 173
		1 -- 173
	) -- 173
	place( -- 174
		captionLabel, -- 174
		48, -- 174
		h - 140, -- 174
		0, -- 174
		1 -- 174
	) -- 174
	place( -- 176
		switchLabel, -- 176
		48, -- 176
		40, -- 176
		0, -- 176
		0 -- 176
	) -- 176
	place( -- 177
		hintLabel, -- 177
		48, -- 177
		84, -- 177
		0, -- 177
		0 -- 177
	) -- 177
	place( -- 178
		rulerLabel, -- 178
		w - 216, -- 178
		roomTop + 36 + v.scale * 0.5 - 14, -- 178
		1, -- 178
		0 -- 178
	) -- 178
	place( -- 179
		standLabel, -- 179
		48, -- 179
		roomTop + 40, -- 179
		0, -- 179
		0 -- 179
	) -- 179
	place( -- 180
		cartLabel, -- 180
		48, -- 180
		roomTop + 92, -- 180
		0, -- 180
		0 -- 180
	) -- 180
	if roomLabel ~= nil then -- 180
		roomLabel.text = room.name -- 183
	end -- 183
	if captionLabel ~= nil then -- 183
		captionLabel.text = room.caption -- 186
	end -- 186
	if hintLabel ~= nil then -- 186
		local lines = HINTS[current + 1] -- 189
		local merged = lines[1] -- 190
		do -- 190
			local i = 1 -- 191
			while i < #lines do -- 191
				merged = (merged .. "    ") .. lines[i + 1] -- 192
				i = i + 1 -- 191
			end -- 191
		end -- 191
		hintLabel.text = merged -- 194
	end -- 194
	local specs = collectLabels(room, v, w) -- 198
	local body = {} -- 199
	local small = {} -- 200
	do -- 200
		local i = 0 -- 201
		while i < #specs do -- 201
			local s = specs[i + 1] -- 202
			if s.size >= 24 then -- 202
				body[#body + 1] = s -- 204
			else -- 204
				small[#small + 1] = s -- 206
			end -- 206
			i = i + 1 -- 201
		end -- 201
	end -- 201
	applyPool(body, poolBody) -- 209
	applyPool(small, poolSmall) -- 210
	if LAYOUT_AUDIT then -- 210
		auditLayout(w, h) -- 213
	end -- 213
end -- 213
function applyPool(specs, pool) -- 217
	do -- 217
		local i = 0 -- 218
		while i < #pool do -- 218
			local lb = pool[i + 1] -- 219
			if i < #specs then -- 219
				local s = specs[i + 1] -- 221
				lb.text = s.text -- 222
				lb.position = Vec2(s.x, s.y) -- 223
				lb.anchor = Vec2(s.ax, s.ay) -- 224
				lb.color = s.color -- 225
				lb.visible = true -- 226
			else -- 226
				lb.visible = false -- 228
			end -- 228
			i = i + 1 -- 218
		end -- 218
	end -- 218
end -- 218
function auditLayout(w, h) -- 234
	local all = {} -- 235
	collectOne(all, titleLabel) -- 236
	collectOne(all, roomLabel) -- 237
	collectOne(all, captionLabel) -- 238
	collectOne(all, switchLabel) -- 239
	collectOne(all, hintLabel) -- 240
	collectOne(all, rulerLabel) -- 241
	collectOne(all, standLabel) -- 242
	collectOne(all, cartLabel) -- 243
	do -- 243
		local i = 0 -- 244
		while i < #poolBody do -- 244
			collectOne(all, poolBody[i + 1]) -- 245
			i = i + 1 -- 244
		end -- 244
	end -- 244
	do -- 244
		local i = 0 -- 247
		while i < #poolSmall do -- 247
			collectOne(all, poolSmall[i + 1]) -- 248
			i = i + 1 -- 247
		end -- 247
	end -- 247
	local lefts = {} -- 251
	local rights = {} -- 252
	local bottoms = {} -- 253
	local tops = {} -- 254
	local outOfScreen = 0 -- 255
	do -- 255
		local i = 0 -- 256
		while i < #all do -- 256
			local lb = all[i + 1] -- 257
			local bw = lb.width -- 258
			local bh = lb.height -- 259
			local l = lb.x - bw * lb.anchor.x -- 260
			local r = l + bw -- 261
			local b = lb.y - bh * lb.anchor.y -- 262
			local t = b + bh -- 263
			lefts[#lefts + 1] = l -- 264
			rights[#rights + 1] = r -- 265
			bottoms[#bottoms + 1] = b -- 266
			tops[#tops + 1] = t -- 267
			if l < 0 or r > w or b < 0 or t > h then -- 267
				outOfScreen = outOfScreen + 1 -- 269
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 270
			end -- 270
			i = i + 1 -- 256
		end -- 256
	end -- 256
	local overlaps = 0 -- 274
	do -- 274
		local i = 0 -- 275
		while i < #all do -- 275
			do -- 275
				local j = i + 1 -- 276
				while j < #all do -- 276
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 277
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 278
					if ox > 4 and oy > 4 then -- 278
						overlaps = overlaps + 1 -- 280
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 281
					end -- 281
					j = j + 1 -- 276
				end -- 276
			end -- 276
			i = i + 1 -- 275
		end -- 275
	end -- 275
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 285
end -- 285
function collectOne(out, lb) -- 288
	if lb ~= nil and lb.visible then -- 288
		out[#out + 1] = lb -- 290
	end -- 290
end -- 290
local FONT = "sarasa-mono-sc-regular" -- 15
LAYOUT_AUDIT = false -- 22
local C_TEXT = Color(236, 236, 232, 255) -- 24
local C_DIM = Color(150, 154, 152, 255) -- 25
local C_ACCENT = Color(226, 186, 84, 255) -- 26
C_BG = Color(17, 18, 19, 255) -- 27
local POOL_BODY = 30 -- 29
local POOL_SMALL = 44 -- 30
TOP_H = 208 -- 31
BOTTOM_H = 216 -- 32
poolBody = {} -- 45
poolSmall = {} -- 46
current = 0 -- 48
viewW = 0 -- 49
viewH = 0 -- 50
dirty = true -- 51
local function makeLabel(text, size, color) -- 53
	if root == nil then -- 53
		return nil -- 55
	end -- 55
	local lb = Label(FONT, size) -- 57
	if lb == nil then -- 57
		return nil -- 59
	end -- 59
	lb.text = text -- 61
	lb.color = color -- 62
	lb:addTo(root) -- 63
	lb.visible = true -- 64
	return lb -- 65
end -- 53
function ____exports.start(parent) -- 77
	root = parent -- 78
	draw = DrawNode() -- 79
	draw:addTo(parent) -- 80
	titleLabel = makeLabel(TITLE, 40, C_TEXT) -- 82
	roomLabel = makeLabel("", 26, C_ACCENT) -- 83
	captionLabel = makeLabel("", 22, C_DIM) -- 84
	switchLabel = makeLabel(SWITCH_HINT, 22, C_DIM) -- 85
	hintLabel = makeLabel("", 22, C_TEXT) -- 86
	rulerLabel = makeLabel(RULER_TEXT, 22, C_DIM) -- 87
	standLabel = makeLabel(STAND_NOTE, 24, C_DIM) -- 88
	cartLabel = makeLabel(CART_NOTE, 24, C_ACCENT) -- 89
	do -- 89
		local i = 0 -- 91
		while i < POOL_BODY do -- 91
			local lb = makeLabel("", 24, C_TEXT) -- 92
			if lb ~= nil then -- 92
				poolBody[#poolBody + 1] = lb -- 94
			end -- 94
			i = i + 1 -- 91
		end -- 91
	end -- 91
	do -- 91
		local i = 0 -- 97
		while i < POOL_SMALL do -- 97
			local lb = makeLabel("", 22, C_DIM) -- 98
			if lb ~= nil then -- 98
				poolSmall[#poolSmall + 1] = lb -- 100
			end -- 100
			i = i + 1 -- 97
		end -- 97
	end -- 97
	parent:onKeyDown(function(key) -- 104
		if key == "1" then -- 104
			current = 0 -- 106
			dirty = true -- 107
		elseif key == "2" then -- 107
			current = 1 -- 109
			dirty = true -- 110
		elseif key == "Tab" then -- 110
			current = (current + 1) % #ROOMS -- 112
			dirty = true -- 113
		end -- 113
	end) -- 104
	viewW = View.size.width -- 117
	viewH = View.size.height -- 118
	applySize() -- 119
	parent:schedule(function() -- 121
		tick() -- 122
		return false -- 123
	end) -- 121
end -- 77
return ____exports -- 77