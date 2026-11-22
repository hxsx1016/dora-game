-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local place, applySize, tick, ensurePlay, tickPlay, playHud, redraw, applyPool, auditLayout, collectOne, LAYOUT_AUDIT, C_TEXT, C_BG, TOP_H, BOTTOM_H, root, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play -- 1
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
local ____input = require("Script.watch.input") -- 12
local Input = ____input.Input -- 12
local ____play = require("Script.watch.play") -- 13
local Play = ____play.Play -- 13
local STEP = ____play.STEP -- 13
function place(lb, x, y, ax, ay) -- 74
	if lb == nil then -- 74
		return -- 76
	end -- 76
	lb.position = Vec2(x, y) -- 78
	lb.anchor = Vec2(ax, ay) -- 79
	lb.visible = true -- 80
end -- 80
function applySize() -- 151
	if root == nil then -- 151
		return -- 153
	end -- 153
	root.size = Size(viewW, viewH) -- 155
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 156
end -- 156
function tick() -- 159
	local w = View.size.width -- 160
	local h = View.size.height -- 161
	if w ~= viewW or h ~= viewH then -- 161
		viewW = w -- 163
		viewH = h -- 164
		applySize() -- 165
		dirty = true -- 166
	end -- 166
	if input == nil then -- 166
		return -- 169
	end -- 169
	input:update() -- 171
	if input.toggleView.pressed then -- 171
		mode = mode == 0 and 1 or 0 -- 173
		dirty = true -- 174
		if mode == 1 then -- 174
			ensurePlay() -- 176
		end -- 176
	end -- 176
	if mode == 1 and play == nil then -- 176
		ensurePlay() -- 180
	end -- 180
	if input.pickRoom ~= 0 then -- 180
		current = input.pickRoom - 1 -- 183
		dirty = true -- 184
		play = nil -- 185
		if mode == 1 then -- 185
			ensurePlay() -- 187
		end -- 187
	elseif input.tab.pressed then -- 187
		current = (current + 1) % #ROOMS -- 190
		dirty = true -- 191
		play = nil -- 192
		if mode == 1 then -- 192
			ensurePlay() -- 194
		end -- 194
	end -- 194
	if mode == 1 then -- 194
		tickPlay() -- 198
		return -- 199
	end -- 199
	if dirty then -- 199
		redraw() -- 202
		dirty = false -- 203
	end -- 203
end -- 203
function ensurePlay() -- 208
	play = __TS__New(Play, ROOMS[current + 1]) -- 209
end -- 209
function tickPlay() -- 213
	if play == nil or draw == nil or input == nil then -- 213
		return -- 215
	end -- 215
	local p = play -- 217
	if input.retry.pressed then -- 217
		play = __TS__New(Play, ROOMS[current + 1]) -- 219
		return -- 220
	end -- 220
	p.aimX = input.mx -- 222
	p.aimY = input.my -- 223
	p:update(STEP, input) -- 224
	p:draw(draw, viewW, viewH) -- 225
	playHud(p) -- 226
end -- 226
function playHud(p) -- 230
	local room = ROOMS[current + 1] -- 231
	if titleLabel ~= nil then -- 231
		titleLabel.text = "守望 · D2 试玩" -- 233
	end -- 233
	if roomLabel ~= nil then -- 233
		roomLabel.text = room.name -- 236
	end -- 236
	if captionLabel ~= nil then -- 236
		captionLabel.text = p:statusText() -- 239
		captionLabel.color = C_TEXT -- 240
	end -- 240
	if hintLabel ~= nil then -- 240
		hintLabel.text = p:hintText() -- 243
	end -- 243
	if switchLabel ~= nil then -- 243
		switchLabel.text = "G 回灰盒 · 1 检查站 · 2 城外 · R 重置" -- 246
	end -- 246
	if rulerLabel ~= nil then -- 246
		rulerLabel.text = "" -- 249
	end -- 249
	if standLabel ~= nil then -- 249
		standLabel.text = "" -- 252
	end -- 252
	if cartLabel ~= nil then -- 252
		cartLabel.text = "" -- 255
	end -- 255
	local i = 0 -- 257
	do -- 257
		i = 0 -- 258
		while i < #poolBody do -- 258
			poolBody[i + 1].visible = false -- 259
			i = i + 1 -- 258
		end -- 258
	end -- 258
	do -- 258
		i = 0 -- 261
		while i < #poolSmall do -- 261
			poolSmall[i + 1].visible = false -- 262
			i = i + 1 -- 261
		end -- 261
	end -- 261
	place( -- 264
		titleLabel, -- 264
		48, -- 264
		viewH - 40, -- 264
		0, -- 264
		1 -- 264
	) -- 264
	place( -- 265
		roomLabel, -- 265
		48, -- 265
		viewH - 96, -- 265
		0, -- 265
		1 -- 265
	) -- 265
	place( -- 266
		captionLabel, -- 266
		48, -- 266
		viewH - 140, -- 266
		0, -- 266
		1 -- 266
	) -- 266
	place( -- 267
		switchLabel, -- 267
		48, -- 267
		40, -- 267
		0, -- 267
		0 -- 267
	) -- 267
	place( -- 268
		hintLabel, -- 268
		48, -- 268
		84, -- 268
		0, -- 268
		0 -- 268
	) -- 268
end -- 268
function redraw() -- 271
	if draw == nil then -- 271
		return -- 273
	end -- 273
	local w = viewW -- 275
	local h = viewH -- 276
	local room = ROOMS[current + 1] -- 277
	draw:clear() -- 279
	draw:drawRect( -- 282
		Rect(0, h - TOP_H, w, TOP_H), -- 282
		C_BG -- 282
	) -- 282
	draw:drawRect( -- 283
		Rect(0, 0, w, BOTTOM_H), -- 283
		C_BG -- 283
	) -- 283
	draw:drawSegment( -- 284
		Vec2(0, h - TOP_H), -- 284
		Vec2(w, h - TOP_H), -- 284
		1, -- 284
		Color(52, 54, 54, 255) -- 284
	) -- 284
	draw:drawSegment( -- 285
		Vec2(0, BOTTOM_H), -- 285
		Vec2(w, BOTTOM_H), -- 285
		1, -- 285
		Color(52, 54, 54, 255) -- 285
	) -- 285
	local v = computeView(room, w, h) -- 287
	renderWorld( -- 288
		draw, -- 288
		room, -- 288
		v, -- 288
		w, -- 288
		h -- 288
	) -- 288
	local roomTop = v.groundPx + room.height * v.scale -- 290
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 291
	place( -- 293
		titleLabel, -- 293
		48, -- 293
		h - 40, -- 293
		0, -- 293
		1 -- 293
	) -- 293
	place( -- 294
		roomLabel, -- 294
		48, -- 294
		h - 96, -- 294
		0, -- 294
		1 -- 294
	) -- 294
	place( -- 295
		captionLabel, -- 295
		48, -- 295
		h - 140, -- 295
		0, -- 295
		1 -- 295
	) -- 295
	place( -- 297
		switchLabel, -- 297
		48, -- 297
		40, -- 297
		0, -- 297
		0 -- 297
	) -- 297
	place( -- 298
		hintLabel, -- 298
		48, -- 298
		84, -- 298
		0, -- 298
		0 -- 298
	) -- 298
	place( -- 299
		rulerLabel, -- 299
		w - 216, -- 299
		roomTop + 36 + v.scale * 0.5 - 14, -- 299
		1, -- 299
		0 -- 299
	) -- 299
	place( -- 300
		standLabel, -- 300
		48, -- 300
		roomTop + 40, -- 300
		0, -- 300
		0 -- 300
	) -- 300
	place( -- 301
		cartLabel, -- 301
		48, -- 301
		roomTop + 92, -- 301
		0, -- 301
		0 -- 301
	) -- 301
	if roomLabel ~= nil then -- 301
		roomLabel.text = room.name -- 304
	end -- 304
	if captionLabel ~= nil then -- 304
		captionLabel.text = room.caption -- 307
	end -- 307
	if hintLabel ~= nil then -- 307
		local lines = HINTS[current + 1] -- 310
		local merged = lines[1] -- 311
		do -- 311
			local i = 1 -- 312
			while i < #lines do -- 312
				merged = (merged .. "    ") .. lines[i + 1] -- 313
				i = i + 1 -- 312
			end -- 312
		end -- 312
		hintLabel.text = merged -- 315
	end -- 315
	local specs = collectLabels(room, v, w) -- 319
	local body = {} -- 320
	local small = {} -- 321
	do -- 321
		local i = 0 -- 322
		while i < #specs do -- 322
			local s = specs[i + 1] -- 323
			if s.size >= 24 then -- 323
				body[#body + 1] = s -- 325
			else -- 325
				small[#small + 1] = s -- 327
			end -- 327
			i = i + 1 -- 322
		end -- 322
	end -- 322
	applyPool(body, poolBody) -- 330
	applyPool(small, poolSmall) -- 331
	if LAYOUT_AUDIT then -- 331
		auditLayout(w, h) -- 334
	end -- 334
end -- 334
function applyPool(specs, pool) -- 338
	do -- 338
		local i = 0 -- 339
		while i < #pool do -- 339
			local lb = pool[i + 1] -- 340
			if i < #specs then -- 340
				local s = specs[i + 1] -- 342
				lb.text = s.text -- 343
				lb.position = Vec2(s.x, s.y) -- 344
				lb.anchor = Vec2(s.ax, s.ay) -- 345
				lb.color = s.color -- 346
				lb.visible = true -- 347
			else -- 347
				lb.visible = false -- 349
			end -- 349
			i = i + 1 -- 339
		end -- 339
	end -- 339
end -- 339
function auditLayout(w, h) -- 355
	local all = {} -- 356
	collectOne(all, titleLabel) -- 357
	collectOne(all, roomLabel) -- 358
	collectOne(all, captionLabel) -- 359
	collectOne(all, switchLabel) -- 360
	collectOne(all, hintLabel) -- 361
	collectOne(all, rulerLabel) -- 362
	collectOne(all, standLabel) -- 363
	collectOne(all, cartLabel) -- 364
	do -- 364
		local i = 0 -- 365
		while i < #poolBody do -- 365
			collectOne(all, poolBody[i + 1]) -- 366
			i = i + 1 -- 365
		end -- 365
	end -- 365
	do -- 365
		local i = 0 -- 368
		while i < #poolSmall do -- 368
			collectOne(all, poolSmall[i + 1]) -- 369
			i = i + 1 -- 368
		end -- 368
	end -- 368
	local lefts = {} -- 372
	local rights = {} -- 373
	local bottoms = {} -- 374
	local tops = {} -- 375
	local outOfScreen = 0 -- 376
	do -- 376
		local i = 0 -- 377
		while i < #all do -- 377
			local lb = all[i + 1] -- 378
			local bw = lb.width -- 379
			local bh = lb.height -- 380
			local l = lb.x - bw * lb.anchor.x -- 381
			local r = l + bw -- 382
			local b = lb.y - bh * lb.anchor.y -- 383
			local t = b + bh -- 384
			lefts[#lefts + 1] = l -- 385
			rights[#rights + 1] = r -- 386
			bottoms[#bottoms + 1] = b -- 387
			tops[#tops + 1] = t -- 388
			if l < 0 or r > w or b < 0 or t > h then -- 388
				outOfScreen = outOfScreen + 1 -- 390
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 391
			end -- 391
			i = i + 1 -- 377
		end -- 377
	end -- 377
	local overlaps = 0 -- 395
	do -- 395
		local i = 0 -- 396
		while i < #all do -- 396
			do -- 396
				local j = i + 1 -- 397
				while j < #all do -- 397
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 398
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 399
					if ox > 4 and oy > 4 then -- 399
						overlaps = overlaps + 1 -- 401
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 402
					end -- 402
					j = j + 1 -- 397
				end -- 397
			end -- 397
			i = i + 1 -- 396
		end -- 396
	end -- 396
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 406
end -- 406
function collectOne(out, lb) -- 409
	if lb ~= nil and lb.visible then -- 409
		out[#out + 1] = lb -- 411
	end -- 411
end -- 411
local FONT = "sarasa-mono-sc-regular" -- 17
LAYOUT_AUDIT = false -- 24
C_TEXT = Color(236, 236, 232, 255) -- 26
local C_DIM = Color(150, 154, 152, 255) -- 27
local C_ACCENT = Color(226, 186, 84, 255) -- 28
C_BG = Color(17, 18, 19, 255) -- 29
local POOL_BODY = 30 -- 31
local POOL_SMALL = 44 -- 32
TOP_H = 208 -- 33
BOTTOM_H = 216 -- 34
poolBody = {} -- 47
poolSmall = {} -- 48
current = 0 -- 50
viewW = 0 -- 51
viewH = 0 -- 52
dirty = true -- 53
mode = 0 -- 55
local function makeLabel(text, size, color) -- 59
	if root == nil then -- 59
		return nil -- 61
	end -- 61
	local lb = Label(FONT, size) -- 63
	if lb == nil then -- 63
		return nil -- 65
	end -- 65
	lb.text = text -- 67
	lb.color = color -- 68
	lb:addTo(root) -- 69
	lb.visible = true -- 70
	return lb -- 71
end -- 59
function ____exports.start(parent, initialMode) -- 83
	if initialMode == nil then -- 83
		initialMode = 1 -- 83
	end -- 83
	root = parent -- 84
	mode = initialMode -- 85
	draw = DrawNode() -- 86
	draw:addTo(parent) -- 87
	titleLabel = makeLabel(TITLE, 40, C_TEXT) -- 89
	roomLabel = makeLabel("", 26, C_ACCENT) -- 90
	captionLabel = makeLabel("", 22, C_DIM) -- 91
	switchLabel = makeLabel(SWITCH_HINT, 22, C_DIM) -- 92
	hintLabel = makeLabel("", 22, C_TEXT) -- 93
	rulerLabel = makeLabel(RULER_TEXT, 22, C_DIM) -- 94
	standLabel = makeLabel(STAND_NOTE, 24, C_DIM) -- 95
	cartLabel = makeLabel(CART_NOTE, 24, C_ACCENT) -- 96
	do -- 96
		local i = 0 -- 98
		while i < POOL_BODY do -- 98
			local lb = makeLabel("", 24, C_TEXT) -- 99
			if lb ~= nil then -- 99
				poolBody[#poolBody + 1] = lb -- 101
			end -- 101
			i = i + 1 -- 98
		end -- 98
	end -- 98
	do -- 98
		local i = 0 -- 104
		while i < POOL_SMALL do -- 104
			local lb = makeLabel("", 22, C_DIM) -- 105
			if lb ~= nil then -- 105
				poolSmall[#poolSmall + 1] = lb -- 107
			end -- 107
			i = i + 1 -- 104
		end -- 104
	end -- 104
	input = __TS__New(Input) -- 111
	parent:onKeyDown(function(key) -- 116
		if key == "F1" then -- 116
			mode = 1 -- 118
			play = nil -- 119
			ensurePlay() -- 120
		elseif key == "F2" then -- 120
			mode = 0 -- 122
			dirty = true -- 123
		elseif key == "1" then -- 123
			current = 0 -- 125
			play = nil -- 126
			dirty = true -- 127
			if mode == 1 then -- 127
				ensurePlay() -- 129
			end -- 129
		elseif key == "2" then -- 129
			current = 1 -- 132
			play = nil -- 133
			dirty = true -- 134
			if mode == 1 then -- 134
				ensurePlay() -- 136
			end -- 136
		end -- 136
	end) -- 116
	viewW = View.size.width -- 141
	viewH = View.size.height -- 142
	applySize() -- 143
	parent:schedule(function() -- 145
		tick() -- 146
		return false -- 147
	end) -- 145
end -- 83
return ____exports -- 83