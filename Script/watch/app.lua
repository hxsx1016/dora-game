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
function applySize() -- 150
	if root == nil then -- 150
		return -- 152
	end -- 152
	root.size = Size(viewW, viewH) -- 154
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 155
end -- 155
function tick() -- 158
	local w = View.size.width -- 159
	local h = View.size.height -- 160
	if w ~= viewW or h ~= viewH then -- 160
		viewW = w -- 162
		viewH = h -- 163
		applySize() -- 164
		dirty = true -- 165
	end -- 165
	if input == nil then -- 165
		return -- 168
	end -- 168
	input:update() -- 170
	if input.toggleView.pressed then -- 170
		mode = mode == 0 and 1 or 0 -- 172
		dirty = true -- 173
		if mode == 1 then -- 173
			ensurePlay() -- 175
		end -- 175
	end -- 175
	if input.pickRoom ~= 0 then -- 175
		current = input.pickRoom - 1 -- 179
		dirty = true -- 180
		play = nil -- 181
		if mode == 1 then -- 181
			ensurePlay() -- 183
		end -- 183
	elseif input.tab.pressed then -- 183
		current = (current + 1) % #ROOMS -- 186
		dirty = true -- 187
		play = nil -- 188
		if mode == 1 then -- 188
			ensurePlay() -- 190
		end -- 190
	end -- 190
	if mode == 1 then -- 190
		tickPlay() -- 194
		return -- 195
	end -- 195
	if dirty then -- 195
		redraw() -- 198
		dirty = false -- 199
	end -- 199
end -- 199
function ensurePlay() -- 204
	play = __TS__New(Play, ROOMS[current + 1]) -- 205
end -- 205
function tickPlay() -- 209
	if play == nil or draw == nil or input == nil then -- 209
		return -- 211
	end -- 211
	local p = play -- 213
	if input.retry.pressed then -- 213
		play = __TS__New(Play, ROOMS[current + 1]) -- 215
		return -- 216
	end -- 216
	p.aimX = input.mx -- 218
	p.aimY = input.my -- 219
	p:update(STEP, input) -- 220
	p:draw(draw, viewW, viewH) -- 221
	playHud(p) -- 222
end -- 222
function playHud(p) -- 226
	local room = ROOMS[current + 1] -- 227
	if titleLabel ~= nil then -- 227
		titleLabel.text = "守望 · D2 试玩" -- 229
	end -- 229
	if roomLabel ~= nil then -- 229
		roomLabel.text = room.name -- 232
	end -- 232
	if captionLabel ~= nil then -- 232
		captionLabel.text = p:statusText() -- 235
		captionLabel.color = C_TEXT -- 236
	end -- 236
	if hintLabel ~= nil then -- 236
		hintLabel.text = p:hintText() -- 239
	end -- 239
	if switchLabel ~= nil then -- 239
		switchLabel.text = "G 回灰盒 · 1 检查站 · 2 城外 · R 重置" -- 242
	end -- 242
	if rulerLabel ~= nil then -- 242
		rulerLabel.text = "" -- 245
	end -- 245
	if standLabel ~= nil then -- 245
		standLabel.text = "" -- 248
	end -- 248
	if cartLabel ~= nil then -- 248
		cartLabel.text = "" -- 251
	end -- 251
	local i = 0 -- 253
	do -- 253
		i = 0 -- 254
		while i < #poolBody do -- 254
			poolBody[i + 1].visible = false -- 255
			i = i + 1 -- 254
		end -- 254
	end -- 254
	do -- 254
		i = 0 -- 257
		while i < #poolSmall do -- 257
			poolSmall[i + 1].visible = false -- 258
			i = i + 1 -- 257
		end -- 257
	end -- 257
	place( -- 260
		titleLabel, -- 260
		48, -- 260
		viewH - 40, -- 260
		0, -- 260
		1 -- 260
	) -- 260
	place( -- 261
		roomLabel, -- 261
		48, -- 261
		viewH - 96, -- 261
		0, -- 261
		1 -- 261
	) -- 261
	place( -- 262
		captionLabel, -- 262
		48, -- 262
		viewH - 140, -- 262
		0, -- 262
		1 -- 262
	) -- 262
	place( -- 263
		switchLabel, -- 263
		48, -- 263
		40, -- 263
		0, -- 263
		0 -- 263
	) -- 263
	place( -- 264
		hintLabel, -- 264
		48, -- 264
		84, -- 264
		0, -- 264
		0 -- 264
	) -- 264
end -- 264
function redraw() -- 267
	if draw == nil then -- 267
		return -- 269
	end -- 269
	local w = viewW -- 271
	local h = viewH -- 272
	local room = ROOMS[current + 1] -- 273
	draw:clear() -- 275
	draw:drawRect( -- 278
		Rect(0, h - TOP_H, w, TOP_H), -- 278
		C_BG -- 278
	) -- 278
	draw:drawRect( -- 279
		Rect(0, 0, w, BOTTOM_H), -- 279
		C_BG -- 279
	) -- 279
	draw:drawSegment( -- 280
		Vec2(0, h - TOP_H), -- 280
		Vec2(w, h - TOP_H), -- 280
		1, -- 280
		Color(52, 54, 54, 255) -- 280
	) -- 280
	draw:drawSegment( -- 281
		Vec2(0, BOTTOM_H), -- 281
		Vec2(w, BOTTOM_H), -- 281
		1, -- 281
		Color(52, 54, 54, 255) -- 281
	) -- 281
	local v = computeView(room, w, h) -- 283
	renderWorld( -- 284
		draw, -- 284
		room, -- 284
		v, -- 284
		w, -- 284
		h -- 284
	) -- 284
	local roomTop = v.groundPx + room.height * v.scale -- 286
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 287
	place( -- 289
		titleLabel, -- 289
		48, -- 289
		h - 40, -- 289
		0, -- 289
		1 -- 289
	) -- 289
	place( -- 290
		roomLabel, -- 290
		48, -- 290
		h - 96, -- 290
		0, -- 290
		1 -- 290
	) -- 290
	place( -- 291
		captionLabel, -- 291
		48, -- 291
		h - 140, -- 291
		0, -- 291
		1 -- 291
	) -- 291
	place( -- 293
		switchLabel, -- 293
		48, -- 293
		40, -- 293
		0, -- 293
		0 -- 293
	) -- 293
	place( -- 294
		hintLabel, -- 294
		48, -- 294
		84, -- 294
		0, -- 294
		0 -- 294
	) -- 294
	place( -- 295
		rulerLabel, -- 295
		w - 216, -- 295
		roomTop + 36 + v.scale * 0.5 - 14, -- 295
		1, -- 295
		0 -- 295
	) -- 295
	place( -- 296
		standLabel, -- 296
		48, -- 296
		roomTop + 40, -- 296
		0, -- 296
		0 -- 296
	) -- 296
	place( -- 297
		cartLabel, -- 297
		48, -- 297
		roomTop + 92, -- 297
		0, -- 297
		0 -- 297
	) -- 297
	if roomLabel ~= nil then -- 297
		roomLabel.text = room.name -- 300
	end -- 300
	if captionLabel ~= nil then -- 300
		captionLabel.text = room.caption -- 303
	end -- 303
	if hintLabel ~= nil then -- 303
		local lines = HINTS[current + 1] -- 306
		local merged = lines[1] -- 307
		do -- 307
			local i = 1 -- 308
			while i < #lines do -- 308
				merged = (merged .. "    ") .. lines[i + 1] -- 309
				i = i + 1 -- 308
			end -- 308
		end -- 308
		hintLabel.text = merged -- 311
	end -- 311
	local specs = collectLabels(room, v, w) -- 315
	local body = {} -- 316
	local small = {} -- 317
	do -- 317
		local i = 0 -- 318
		while i < #specs do -- 318
			local s = specs[i + 1] -- 319
			if s.size >= 24 then -- 319
				body[#body + 1] = s -- 321
			else -- 321
				small[#small + 1] = s -- 323
			end -- 323
			i = i + 1 -- 318
		end -- 318
	end -- 318
	applyPool(body, poolBody) -- 326
	applyPool(small, poolSmall) -- 327
	if LAYOUT_AUDIT then -- 327
		auditLayout(w, h) -- 330
	end -- 330
end -- 330
function applyPool(specs, pool) -- 334
	do -- 334
		local i = 0 -- 335
		while i < #pool do -- 335
			local lb = pool[i + 1] -- 336
			if i < #specs then -- 336
				local s = specs[i + 1] -- 338
				lb.text = s.text -- 339
				lb.position = Vec2(s.x, s.y) -- 340
				lb.anchor = Vec2(s.ax, s.ay) -- 341
				lb.color = s.color -- 342
				lb.visible = true -- 343
			else -- 343
				lb.visible = false -- 345
			end -- 345
			i = i + 1 -- 335
		end -- 335
	end -- 335
end -- 335
function auditLayout(w, h) -- 351
	local all = {} -- 352
	collectOne(all, titleLabel) -- 353
	collectOne(all, roomLabel) -- 354
	collectOne(all, captionLabel) -- 355
	collectOne(all, switchLabel) -- 356
	collectOne(all, hintLabel) -- 357
	collectOne(all, rulerLabel) -- 358
	collectOne(all, standLabel) -- 359
	collectOne(all, cartLabel) -- 360
	do -- 360
		local i = 0 -- 361
		while i < #poolBody do -- 361
			collectOne(all, poolBody[i + 1]) -- 362
			i = i + 1 -- 361
		end -- 361
	end -- 361
	do -- 361
		local i = 0 -- 364
		while i < #poolSmall do -- 364
			collectOne(all, poolSmall[i + 1]) -- 365
			i = i + 1 -- 364
		end -- 364
	end -- 364
	local lefts = {} -- 368
	local rights = {} -- 369
	local bottoms = {} -- 370
	local tops = {} -- 371
	local outOfScreen = 0 -- 372
	do -- 372
		local i = 0 -- 373
		while i < #all do -- 373
			local lb = all[i + 1] -- 374
			local bw = lb.width -- 375
			local bh = lb.height -- 376
			local l = lb.x - bw * lb.anchor.x -- 377
			local r = l + bw -- 378
			local b = lb.y - bh * lb.anchor.y -- 379
			local t = b + bh -- 380
			lefts[#lefts + 1] = l -- 381
			rights[#rights + 1] = r -- 382
			bottoms[#bottoms + 1] = b -- 383
			tops[#tops + 1] = t -- 384
			if l < 0 or r > w or b < 0 or t > h then -- 384
				outOfScreen = outOfScreen + 1 -- 386
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 387
			end -- 387
			i = i + 1 -- 373
		end -- 373
	end -- 373
	local overlaps = 0 -- 391
	do -- 391
		local i = 0 -- 392
		while i < #all do -- 392
			do -- 392
				local j = i + 1 -- 393
				while j < #all do -- 393
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 394
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 395
					if ox > 4 and oy > 4 then -- 395
						overlaps = overlaps + 1 -- 397
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 398
					end -- 398
					j = j + 1 -- 393
				end -- 393
			end -- 393
			i = i + 1 -- 392
		end -- 392
	end -- 392
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 402
end -- 402
function collectOne(out, lb) -- 405
	if lb ~= nil and lb.visible then -- 405
		out[#out + 1] = lb -- 407
	end -- 407
end -- 407
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
function ____exports.start(parent) -- 83
	root = parent -- 84
	draw = DrawNode() -- 85
	draw:addTo(parent) -- 86
	titleLabel = makeLabel(TITLE, 40, C_TEXT) -- 88
	roomLabel = makeLabel("", 26, C_ACCENT) -- 89
	captionLabel = makeLabel("", 22, C_DIM) -- 90
	switchLabel = makeLabel(SWITCH_HINT, 22, C_DIM) -- 91
	hintLabel = makeLabel("", 22, C_TEXT) -- 92
	rulerLabel = makeLabel(RULER_TEXT, 22, C_DIM) -- 93
	standLabel = makeLabel(STAND_NOTE, 24, C_DIM) -- 94
	cartLabel = makeLabel(CART_NOTE, 24, C_ACCENT) -- 95
	do -- 95
		local i = 0 -- 97
		while i < POOL_BODY do -- 97
			local lb = makeLabel("", 24, C_TEXT) -- 98
			if lb ~= nil then -- 98
				poolBody[#poolBody + 1] = lb -- 100
			end -- 100
			i = i + 1 -- 97
		end -- 97
	end -- 97
	do -- 97
		local i = 0 -- 103
		while i < POOL_SMALL do -- 103
			local lb = makeLabel("", 22, C_DIM) -- 104
			if lb ~= nil then -- 104
				poolSmall[#poolSmall + 1] = lb -- 106
			end -- 106
			i = i + 1 -- 103
		end -- 103
	end -- 103
	input = __TS__New(Input) -- 110
	parent:onKeyDown(function(key) -- 115
		if key == "F1" then -- 115
			mode = 1 -- 117
			play = nil -- 118
			ensurePlay() -- 119
		elseif key == "F2" then -- 119
			mode = 0 -- 121
			dirty = true -- 122
		elseif key == "1" then -- 122
			current = 0 -- 124
			play = nil -- 125
			dirty = true -- 126
			if mode == 1 then -- 126
				ensurePlay() -- 128
			end -- 128
		elseif key == "2" then -- 128
			current = 1 -- 131
			play = nil -- 132
			dirty = true -- 133
			if mode == 1 then -- 133
				ensurePlay() -- 135
			end -- 135
		end -- 135
	end) -- 115
	viewW = View.size.width -- 140
	viewH = View.size.height -- 141
	applySize() -- 142
	parent:schedule(function() -- 144
		tick() -- 145
		return false -- 146
	end) -- 144
end -- 83
return ____exports -- 83