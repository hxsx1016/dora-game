-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local place, applySize, tick, ensurePlay, tickPlay, playHud, redraw, applyPool, auditLayout, collectOne, LAYOUT_AUDIT, C_TEXT, C_BG, TOP_H, BOTTOM_H, root, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, clock -- 1
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
local ____clock = require("Script.watch.clock") -- 14
local STEP = ____clock.STEP -- 14
local StepClock = ____clock.StepClock -- 14
function place(lb, x, y, ax, ay) -- 77
	if lb == nil then -- 77
		return -- 79
	end -- 79
	lb.position = Vec2(x, y) -- 81
	lb.anchor = Vec2(ax, ay) -- 82
	lb.visible = true -- 83
end -- 83
function applySize() -- 154
	if root == nil then -- 154
		return -- 156
	end -- 156
	root.size = Size(viewW, viewH) -- 158
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 159
end -- 159
function tick(frameDt) -- 162
	local w = View.size.width -- 163
	local h = View.size.height -- 164
	if w ~= viewW or h ~= viewH then -- 164
		viewW = w -- 166
		viewH = h -- 167
		applySize() -- 168
		dirty = true -- 169
	end -- 169
	if input == nil then -- 169
		return -- 172
	end -- 172
	input:update() -- 174
	if input.toggleView.pressed then -- 174
		input.toggleView.pressed = false -- 179
		mode = mode == 0 and 1 or 0 -- 180
		dirty = true -- 181
		clock:reset() -- 182
		if mode == 1 then -- 182
			ensurePlay() -- 184
		end -- 184
	end -- 184
	if mode == 1 and play == nil then -- 184
		ensurePlay() -- 188
	end -- 188
	if input.pickRoom ~= 0 then -- 188
		current = input.pickRoom - 1 -- 191
		input.pickRoom = 0 -- 192
		dirty = true -- 193
		play = nil -- 194
		clock:reset() -- 195
		if mode == 1 then -- 195
			ensurePlay() -- 197
		end -- 197
	elseif input.tab.pressed then -- 197
		input.tab.pressed = false -- 200
		current = (current + 1) % #ROOMS -- 201
		dirty = true -- 202
		play = nil -- 203
		clock:reset() -- 204
		if mode == 1 then -- 204
			ensurePlay() -- 206
		end -- 206
	end -- 206
	if mode == 1 then -- 206
		tickPlay(frameDt) -- 210
		return -- 211
	end -- 211
	if dirty then -- 211
		redraw() -- 214
		dirty = false -- 215
	end -- 215
end -- 215
function ensurePlay() -- 220
	play = __TS__New(Play, ROOMS[current + 1]) -- 221
	clock:reset() -- 222
end -- 222
function tickPlay(frameDt) -- 231
	if play == nil or draw == nil or input == nil then -- 231
		return -- 233
	end -- 233
	local p = play -- 235
	if input.retry.pressed then -- 235
		input:consumeEdges() -- 237
		play = __TS__New(Play, ROOMS[current + 1], {checkpoint = p.checkpoint}) -- 239
		clock:reset() -- 240
		return -- 241
	end -- 241
	p.aimX = input.mx -- 243
	p.aimY = input.my -- 244
	if p.paused then -- 244
		clock:reset() -- 248
		input:beginStep(true) -- 249
		p:update(STEP, input) -- 250
		input:endStep() -- 251
		p:draw(draw, viewW, viewH) -- 252
		playHud(p) -- 253
		return -- 254
	end -- 254
	local steps = clock:advance(frameDt) -- 257
	local i = 0 -- 258
	do -- 258
		i = 0 -- 259
		while i < steps do -- 259
			input:beginStep(i == 0) -- 260
			p:update(STEP, input) -- 261
			input:endStep() -- 262
			i = i + 1 -- 259
		end -- 259
	end -- 259
	if p.wantRoom ~= "" then -- 259
		local key = p.wantRoom -- 267
		p.wantRoom = "" -- 268
		local idx = -1 -- 269
		local j = 0 -- 270
		do -- 270
			j = 0 -- 271
			while j < #ROOMS do -- 271
				if ROOMS[j + 1].key == key then -- 271
					idx = j -- 273
				end -- 273
				j = j + 1 -- 271
			end -- 271
		end -- 271
		if idx >= 0 then -- 271
			current = idx -- 277
			ensurePlay() -- 278
			clock:reset() -- 279
			dirty = true -- 280
		end -- 280
		return -- 282
	end -- 282
	p:draw(draw, viewW, viewH) -- 285
	playHud(p) -- 286
end -- 286
function playHud(p) -- 290
	local room = ROOMS[current + 1] -- 291
	if titleLabel ~= nil then -- 291
		titleLabel.text = "守望 · D3 试玩" -- 293
	end -- 293
	if roomLabel ~= nil then -- 293
		roomLabel.text = room.name -- 296
	end -- 296
	if captionLabel ~= nil then -- 296
		captionLabel.text = p:statusText() -- 299
		captionLabel.color = C_TEXT -- 300
	end -- 300
	if hintLabel ~= nil then -- 300
		hintLabel.text = p:hintText() -- 303
	end -- 303
	if switchLabel ~= nil then -- 303
		switchLabel.text = "G 回灰盒 · 1 检查站 · 2 城外 · 3 村口 · R 重置" -- 306
	end -- 306
	if rulerLabel ~= nil then -- 306
		rulerLabel.text = "" -- 309
	end -- 309
	if standLabel ~= nil then -- 309
		standLabel.text = "" -- 312
	end -- 312
	if cartLabel ~= nil then -- 312
		cartLabel.text = "" -- 315
	end -- 315
	local i = 0 -- 317
	do -- 317
		i = 0 -- 318
		while i < #poolBody do -- 318
			poolBody[i + 1].visible = false -- 319
			i = i + 1 -- 318
		end -- 318
	end -- 318
	do -- 318
		i = 0 -- 321
		while i < #poolSmall do -- 321
			poolSmall[i + 1].visible = false -- 322
			i = i + 1 -- 321
		end -- 321
	end -- 321
	place( -- 324
		titleLabel, -- 324
		48, -- 324
		viewH - 40, -- 324
		0, -- 324
		1 -- 324
	) -- 324
	place( -- 325
		roomLabel, -- 325
		48, -- 325
		viewH - 96, -- 325
		0, -- 325
		1 -- 325
	) -- 325
	place( -- 326
		captionLabel, -- 326
		48, -- 326
		viewH - 140, -- 326
		0, -- 326
		1 -- 326
	) -- 326
	place( -- 327
		switchLabel, -- 327
		48, -- 327
		40, -- 327
		0, -- 327
		0 -- 327
	) -- 327
	place( -- 328
		hintLabel, -- 328
		48, -- 328
		84, -- 328
		0, -- 328
		0 -- 328
	) -- 328
end -- 328
function redraw() -- 331
	if draw == nil then -- 331
		return -- 333
	end -- 333
	local w = viewW -- 335
	local h = viewH -- 336
	local room = ROOMS[current + 1] -- 337
	draw:clear() -- 339
	draw:drawRect( -- 342
		Rect(0, h - TOP_H, w, TOP_H), -- 342
		C_BG -- 342
	) -- 342
	draw:drawRect( -- 343
		Rect(0, 0, w, BOTTOM_H), -- 343
		C_BG -- 343
	) -- 343
	draw:drawSegment( -- 344
		Vec2(0, h - TOP_H), -- 344
		Vec2(w, h - TOP_H), -- 344
		1, -- 344
		Color(52, 54, 54, 255) -- 344
	) -- 344
	draw:drawSegment( -- 345
		Vec2(0, BOTTOM_H), -- 345
		Vec2(w, BOTTOM_H), -- 345
		1, -- 345
		Color(52, 54, 54, 255) -- 345
	) -- 345
	local v = computeView(room, w, h) -- 347
	renderWorld( -- 348
		draw, -- 348
		room, -- 348
		v, -- 348
		w, -- 348
		h -- 348
	) -- 348
	local roomTop = v.groundPx + room.height * v.scale -- 350
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 351
	place( -- 353
		titleLabel, -- 353
		48, -- 353
		h - 40, -- 353
		0, -- 353
		1 -- 353
	) -- 353
	place( -- 354
		roomLabel, -- 354
		48, -- 354
		h - 96, -- 354
		0, -- 354
		1 -- 354
	) -- 354
	place( -- 355
		captionLabel, -- 355
		48, -- 355
		h - 140, -- 355
		0, -- 355
		1 -- 355
	) -- 355
	place( -- 357
		switchLabel, -- 357
		48, -- 357
		40, -- 357
		0, -- 357
		0 -- 357
	) -- 357
	place( -- 358
		hintLabel, -- 358
		48, -- 358
		84, -- 358
		0, -- 358
		0 -- 358
	) -- 358
	place( -- 359
		rulerLabel, -- 359
		w - 216, -- 359
		roomTop + 36 + v.scale * 0.5 - 14, -- 359
		1, -- 359
		0 -- 359
	) -- 359
	place( -- 360
		standLabel, -- 360
		48, -- 360
		roomTop + 40, -- 360
		0, -- 360
		0 -- 360
	) -- 360
	place( -- 361
		cartLabel, -- 361
		48, -- 361
		roomTop + 92, -- 361
		0, -- 361
		0 -- 361
	) -- 361
	if roomLabel ~= nil then -- 361
		roomLabel.text = room.name -- 364
	end -- 364
	if captionLabel ~= nil then -- 364
		captionLabel.text = room.caption -- 367
	end -- 367
	if hintLabel ~= nil then -- 367
		local lines = HINTS[current + 1] -- 370
		local merged = lines[1] -- 371
		do -- 371
			local i = 1 -- 372
			while i < #lines do -- 372
				merged = (merged .. "    ") .. lines[i + 1] -- 373
				i = i + 1 -- 372
			end -- 372
		end -- 372
		hintLabel.text = merged -- 375
	end -- 375
	local specs = collectLabels(room, v, w) -- 379
	local body = {} -- 380
	local small = {} -- 381
	do -- 381
		local i = 0 -- 382
		while i < #specs do -- 382
			local s = specs[i + 1] -- 383
			if s.size >= 24 then -- 383
				body[#body + 1] = s -- 385
			else -- 385
				small[#small + 1] = s -- 387
			end -- 387
			i = i + 1 -- 382
		end -- 382
	end -- 382
	applyPool(body, poolBody) -- 390
	applyPool(small, poolSmall) -- 391
	if LAYOUT_AUDIT then -- 391
		auditLayout(w, h) -- 394
	end -- 394
end -- 394
function applyPool(specs, pool) -- 398
	do -- 398
		local i = 0 -- 399
		while i < #pool do -- 399
			local lb = pool[i + 1] -- 400
			if i < #specs then -- 400
				local s = specs[i + 1] -- 402
				lb.text = s.text -- 403
				lb.position = Vec2(s.x, s.y) -- 404
				lb.anchor = Vec2(s.ax, s.ay) -- 405
				lb.color = s.color -- 406
				lb.visible = true -- 407
			else -- 407
				lb.visible = false -- 409
			end -- 409
			i = i + 1 -- 399
		end -- 399
	end -- 399
end -- 399
function auditLayout(w, h) -- 415
	local all = {} -- 416
	collectOne(all, titleLabel) -- 417
	collectOne(all, roomLabel) -- 418
	collectOne(all, captionLabel) -- 419
	collectOne(all, switchLabel) -- 420
	collectOne(all, hintLabel) -- 421
	collectOne(all, rulerLabel) -- 422
	collectOne(all, standLabel) -- 423
	collectOne(all, cartLabel) -- 424
	do -- 424
		local i = 0 -- 425
		while i < #poolBody do -- 425
			collectOne(all, poolBody[i + 1]) -- 426
			i = i + 1 -- 425
		end -- 425
	end -- 425
	do -- 425
		local i = 0 -- 428
		while i < #poolSmall do -- 428
			collectOne(all, poolSmall[i + 1]) -- 429
			i = i + 1 -- 428
		end -- 428
	end -- 428
	local lefts = {} -- 432
	local rights = {} -- 433
	local bottoms = {} -- 434
	local tops = {} -- 435
	local outOfScreen = 0 -- 436
	do -- 436
		local i = 0 -- 437
		while i < #all do -- 437
			local lb = all[i + 1] -- 438
			local bw = lb.width -- 439
			local bh = lb.height -- 440
			local l = lb.x - bw * lb.anchor.x -- 441
			local r = l + bw -- 442
			local b = lb.y - bh * lb.anchor.y -- 443
			local t = b + bh -- 444
			lefts[#lefts + 1] = l -- 445
			rights[#rights + 1] = r -- 446
			bottoms[#bottoms + 1] = b -- 447
			tops[#tops + 1] = t -- 448
			if l < 0 or r > w or b < 0 or t > h then -- 448
				outOfScreen = outOfScreen + 1 -- 450
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 451
			end -- 451
			i = i + 1 -- 437
		end -- 437
	end -- 437
	local overlaps = 0 -- 455
	do -- 455
		local i = 0 -- 456
		while i < #all do -- 456
			do -- 456
				local j = i + 1 -- 457
				while j < #all do -- 457
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 458
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 459
					if ox > 4 and oy > 4 then -- 459
						overlaps = overlaps + 1 -- 461
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 462
					end -- 462
					j = j + 1 -- 457
				end -- 457
			end -- 457
			i = i + 1 -- 456
		end -- 456
	end -- 456
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 466
end -- 466
function collectOne(out, lb) -- 469
	if lb ~= nil and lb.visible then -- 469
		out[#out + 1] = lb -- 471
	end -- 471
end -- 471
local FONT = "sarasa-mono-sc-regular" -- 18
LAYOUT_AUDIT = false -- 25
C_TEXT = Color(236, 236, 232, 255) -- 27
local C_DIM = Color(150, 154, 152, 255) -- 28
local C_ACCENT = Color(226, 186, 84, 255) -- 29
C_BG = Color(17, 18, 19, 255) -- 30
local POOL_BODY = 30 -- 32
local POOL_SMALL = 44 -- 33
TOP_H = 208 -- 34
BOTTOM_H = 216 -- 35
poolBody = {} -- 48
poolSmall = {} -- 49
current = 0 -- 51
viewW = 0 -- 52
viewH = 0 -- 53
dirty = true -- 54
mode = 0 -- 56
clock = __TS__New(StepClock) -- 60
local function makeLabel(text, size, color) -- 62
	if root == nil then -- 62
		return nil -- 64
	end -- 64
	local lb = Label(FONT, size) -- 66
	if lb == nil then -- 66
		return nil -- 68
	end -- 68
	lb.text = text -- 70
	lb.color = color -- 71
	lb:addTo(root) -- 72
	lb.visible = true -- 73
	return lb -- 74
end -- 62
function ____exports.start(parent, initialMode) -- 86
	if initialMode == nil then -- 86
		initialMode = 1 -- 86
	end -- 86
	root = parent -- 87
	mode = initialMode -- 88
	draw = DrawNode() -- 89
	draw:addTo(parent) -- 90
	titleLabel = makeLabel(TITLE, 40, C_TEXT) -- 92
	roomLabel = makeLabel("", 26, C_ACCENT) -- 93
	captionLabel = makeLabel("", 22, C_DIM) -- 94
	switchLabel = makeLabel(SWITCH_HINT, 22, C_DIM) -- 95
	hintLabel = makeLabel("", 22, C_TEXT) -- 96
	rulerLabel = makeLabel(RULER_TEXT, 22, C_DIM) -- 97
	standLabel = makeLabel(STAND_NOTE, 24, C_DIM) -- 98
	cartLabel = makeLabel(CART_NOTE, 24, C_ACCENT) -- 99
	do -- 99
		local i = 0 -- 101
		while i < POOL_BODY do -- 101
			local lb = makeLabel("", 24, C_TEXT) -- 102
			if lb ~= nil then -- 102
				poolBody[#poolBody + 1] = lb -- 104
			end -- 104
			i = i + 1 -- 101
		end -- 101
	end -- 101
	do -- 101
		local i = 0 -- 107
		while i < POOL_SMALL do -- 107
			local lb = makeLabel("", 22, C_DIM) -- 108
			if lb ~= nil then -- 108
				poolSmall[#poolSmall + 1] = lb -- 110
			end -- 110
			i = i + 1 -- 107
		end -- 107
	end -- 107
	input = __TS__New(Input) -- 114
	parent:onKeyDown(function(key) -- 119
		if key == "F1" then -- 119
			mode = 1 -- 121
			play = nil -- 122
			ensurePlay() -- 123
		elseif key == "F2" then -- 123
			mode = 0 -- 125
			dirty = true -- 126
		elseif key == "1" then -- 126
			current = 0 -- 128
			play = nil -- 129
			dirty = true -- 130
			if mode == 1 then -- 130
				ensurePlay() -- 132
			end -- 132
		elseif key == "2" then -- 132
			current = 1 -- 135
			play = nil -- 136
			dirty = true -- 137
			if mode == 1 then -- 137
				ensurePlay() -- 139
			end -- 139
		end -- 139
	end) -- 119
	viewW = View.size.width -- 144
	viewH = View.size.height -- 145
	applySize() -- 146
	parent:schedule(function(frameDt) -- 148
		tick(frameDt) -- 149
		return false -- 150
	end) -- 148
end -- 86
return ____exports -- 86