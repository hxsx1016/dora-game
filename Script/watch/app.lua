-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local place, applySize, tick, registerPlay, ensurePlay, tickPlay, playHud, redraw, applyPool, auditLayout, collectOne, LAYOUT_AUDIT, C_TEXT, C_BG, TOP_H, BOTTOM_H, root, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, clock -- 1
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
function applySize() -- 158
	if root == nil then -- 158
		return -- 160
	end -- 160
	root.size = Size(viewW, viewH) -- 162
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 163
end -- 163
function tick(frameDt) -- 166
	local w = View.size.width -- 167
	local h = View.size.height -- 168
	if w ~= viewW or h ~= viewH then -- 168
		viewW = w -- 170
		viewH = h -- 171
		applySize() -- 172
		dirty = true -- 173
	end -- 173
	if input == nil then -- 173
		return -- 176
	end -- 176
	input:update() -- 178
	if input.toggleView.pressed then -- 178
		input.toggleView.pressed = false -- 183
		mode = mode == 0 and 1 or 0 -- 184
		dirty = true -- 185
		clock:reset() -- 186
		if mode == 1 then -- 186
			ensurePlay() -- 188
		end -- 188
	end -- 188
	if mode == 1 and play == nil then -- 188
		ensurePlay() -- 192
	end -- 192
	if input.pickRoom ~= 0 then -- 192
		current = input.pickRoom - 1 -- 195
		input.pickRoom = 0 -- 196
		dirty = true -- 197
		play = nil -- 198
		clock:reset() -- 199
		if mode == 1 then -- 199
			ensurePlay() -- 201
		end -- 201
	elseif input.tab.pressed then -- 201
		input.tab.pressed = false -- 204
		current = (current + 1) % #ROOMS -- 205
		dirty = true -- 206
		play = nil -- 207
		clock:reset() -- 208
		if mode == 1 then -- 208
			ensurePlay() -- 210
		end -- 210
	end -- 210
	if mode == 1 then -- 210
		tickPlay(frameDt) -- 214
		return -- 215
	end -- 215
	if dirty then -- 215
		redraw() -- 218
		dirty = false -- 219
	end -- 219
end -- 219
function registerPlay() -- 224
	local reg = _G.package.loaded -- 225
	reg["watch.play"] = play -- 226
	reg["watch.room"] = ROOMS[current + 1].key -- 227
end -- 227
function ensurePlay() -- 231
	play = __TS__New(Play, ROOMS[current + 1]) -- 232
	registerPlay() -- 233
	clock:reset() -- 234
end -- 234
function tickPlay(frameDt) -- 243
	if play == nil or draw == nil or input == nil then -- 243
		return -- 245
	end -- 245
	local p = play -- 247
	if input.retry.pressed then -- 247
		input:consumeEdges() -- 249
		play = __TS__New(Play, ROOMS[current + 1], {checkpoint = p.checkpoint}) -- 251
		registerPlay() -- 253
		clock:reset() -- 254
		return -- 255
	end -- 255
	p.aimX = input.mx -- 257
	p.aimY = input.my -- 258
	if p.paused then -- 258
		clock:reset() -- 262
		input:beginStep(true) -- 263
		p:update(STEP, input) -- 264
		input:endStep() -- 265
		p:draw(draw, viewW, viewH) -- 266
		playHud(p) -- 267
		return -- 268
	end -- 268
	local steps = clock:advance(frameDt) -- 271
	local i = 0 -- 272
	do -- 272
		i = 0 -- 273
		while i < steps do -- 273
			input:beginStep(i == 0) -- 274
			p:update(STEP, input) -- 275
			input:endStep() -- 276
			i = i + 1 -- 273
		end -- 273
	end -- 273
	if p.wantRoom ~= "" then -- 273
		local key = p.wantRoom -- 281
		p.wantRoom = "" -- 282
		local idx = -1 -- 283
		local j = 0 -- 284
		do -- 284
			j = 0 -- 285
			while j < #ROOMS do -- 285
				if ROOMS[j + 1].key == key then -- 285
					idx = j -- 287
				end -- 287
				j = j + 1 -- 285
			end -- 285
		end -- 285
		if idx >= 0 then -- 285
			current = idx -- 291
			ensurePlay() -- 292
			clock:reset() -- 293
			dirty = true -- 294
		end -- 294
		return -- 296
	end -- 296
	p:draw(draw, viewW, viewH) -- 299
	playHud(p) -- 300
end -- 300
function playHud(p) -- 304
	local room = ROOMS[current + 1] -- 305
	if titleLabel ~= nil then -- 305
		titleLabel.text = "守望 · D5 完整试玩" -- 307
	end -- 307
	if roomLabel ~= nil then -- 307
		roomLabel.text = room.name -- 310
	end -- 310
	if captionLabel ~= nil then -- 310
		captionLabel.text = p:statusText() -- 313
		captionLabel.color = C_TEXT -- 314
	end -- 314
	if hintLabel ~= nil then -- 314
		hintLabel.text = p:hintText() -- 317
	end -- 317
	if switchLabel ~= nil then -- 317
		switchLabel.text = "G 回灰盒 · Tab 换房 · 1/2/3 快跳 · R 重置" -- 320
	end -- 320
	if rulerLabel ~= nil then -- 320
		rulerLabel.text = "" -- 323
	end -- 323
	if standLabel ~= nil then -- 323
		standLabel.text = "" -- 326
	end -- 326
	if cartLabel ~= nil then -- 326
		cartLabel.text = "" -- 329
	end -- 329
	local i = 0 -- 331
	do -- 331
		i = 0 -- 332
		while i < #poolBody do -- 332
			poolBody[i + 1].visible = false -- 333
			i = i + 1 -- 332
		end -- 332
	end -- 332
	do -- 332
		i = 0 -- 335
		while i < #poolSmall do -- 335
			poolSmall[i + 1].visible = false -- 336
			i = i + 1 -- 335
		end -- 335
	end -- 335
	place( -- 338
		titleLabel, -- 338
		48, -- 338
		viewH - 40, -- 338
		0, -- 338
		1 -- 338
	) -- 338
	place( -- 339
		roomLabel, -- 339
		48, -- 339
		viewH - 96, -- 339
		0, -- 339
		1 -- 339
	) -- 339
	place( -- 340
		captionLabel, -- 340
		48, -- 340
		viewH - 140, -- 340
		0, -- 340
		1 -- 340
	) -- 340
	place( -- 341
		switchLabel, -- 341
		48, -- 341
		40, -- 341
		0, -- 341
		0 -- 341
	) -- 341
	place( -- 342
		hintLabel, -- 342
		48, -- 342
		84, -- 342
		0, -- 342
		0 -- 342
	) -- 342
end -- 342
function redraw() -- 345
	if draw == nil then -- 345
		return -- 347
	end -- 347
	local w = viewW -- 349
	local h = viewH -- 350
	local room = ROOMS[current + 1] -- 351
	draw:clear() -- 353
	draw:drawRect( -- 356
		Rect(0, h - TOP_H, w, TOP_H), -- 356
		C_BG -- 356
	) -- 356
	draw:drawRect( -- 357
		Rect(0, 0, w, BOTTOM_H), -- 357
		C_BG -- 357
	) -- 357
	draw:drawSegment( -- 358
		Vec2(0, h - TOP_H), -- 358
		Vec2(w, h - TOP_H), -- 358
		1, -- 358
		Color(52, 54, 54, 255) -- 358
	) -- 358
	draw:drawSegment( -- 359
		Vec2(0, BOTTOM_H), -- 359
		Vec2(w, BOTTOM_H), -- 359
		1, -- 359
		Color(52, 54, 54, 255) -- 359
	) -- 359
	local v = computeView(room, w, h) -- 361
	renderWorld( -- 362
		draw, -- 362
		room, -- 362
		v, -- 362
		w, -- 362
		h -- 362
	) -- 362
	local roomTop = v.groundPx + room.height * v.scale -- 364
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 365
	place( -- 367
		titleLabel, -- 367
		48, -- 367
		h - 40, -- 367
		0, -- 367
		1 -- 367
	) -- 367
	place( -- 368
		roomLabel, -- 368
		48, -- 368
		h - 96, -- 368
		0, -- 368
		1 -- 368
	) -- 368
	place( -- 369
		captionLabel, -- 369
		48, -- 369
		h - 140, -- 369
		0, -- 369
		1 -- 369
	) -- 369
	place( -- 371
		switchLabel, -- 371
		48, -- 371
		40, -- 371
		0, -- 371
		0 -- 371
	) -- 371
	place( -- 372
		hintLabel, -- 372
		48, -- 372
		84, -- 372
		0, -- 372
		0 -- 372
	) -- 372
	place( -- 373
		rulerLabel, -- 373
		w - 216, -- 373
		roomTop + 36 + v.scale * 0.5 - 14, -- 373
		1, -- 373
		0 -- 373
	) -- 373
	place( -- 374
		standLabel, -- 374
		48, -- 374
		roomTop + 40, -- 374
		0, -- 374
		0 -- 374
	) -- 374
	place( -- 375
		cartLabel, -- 375
		48, -- 375
		roomTop + 92, -- 375
		0, -- 375
		0 -- 375
	) -- 375
	if roomLabel ~= nil then -- 375
		roomLabel.text = room.name -- 378
	end -- 378
	if captionLabel ~= nil then -- 378
		captionLabel.text = room.caption -- 381
	end -- 381
	if hintLabel ~= nil then -- 381
		local lines = HINTS[current + 1] -- 384
		local merged = lines[1] -- 385
		do -- 385
			local i = 1 -- 386
			while i < #lines do -- 386
				merged = (merged .. "    ") .. lines[i + 1] -- 387
				i = i + 1 -- 386
			end -- 386
		end -- 386
		hintLabel.text = merged -- 389
	end -- 389
	local specs = collectLabels(room, v, w) -- 393
	local body = {} -- 394
	local small = {} -- 395
	do -- 395
		local i = 0 -- 396
		while i < #specs do -- 396
			local s = specs[i + 1] -- 397
			if s.size >= 24 then -- 397
				body[#body + 1] = s -- 399
			else -- 399
				small[#small + 1] = s -- 401
			end -- 401
			i = i + 1 -- 396
		end -- 396
	end -- 396
	applyPool(body, poolBody) -- 404
	applyPool(small, poolSmall) -- 405
	if LAYOUT_AUDIT then -- 405
		auditLayout(w, h) -- 408
	end -- 408
end -- 408
function applyPool(specs, pool) -- 412
	do -- 412
		local i = 0 -- 413
		while i < #pool do -- 413
			local lb = pool[i + 1] -- 414
			if i < #specs then -- 414
				local s = specs[i + 1] -- 416
				lb.text = s.text -- 417
				lb.position = Vec2(s.x, s.y) -- 418
				lb.anchor = Vec2(s.ax, s.ay) -- 419
				lb.color = s.color -- 420
				lb.visible = true -- 421
			else -- 421
				lb.visible = false -- 423
			end -- 423
			i = i + 1 -- 413
		end -- 413
	end -- 413
end -- 413
function auditLayout(w, h) -- 429
	local all = {} -- 430
	collectOne(all, titleLabel) -- 431
	collectOne(all, roomLabel) -- 432
	collectOne(all, captionLabel) -- 433
	collectOne(all, switchLabel) -- 434
	collectOne(all, hintLabel) -- 435
	collectOne(all, rulerLabel) -- 436
	collectOne(all, standLabel) -- 437
	collectOne(all, cartLabel) -- 438
	do -- 438
		local i = 0 -- 439
		while i < #poolBody do -- 439
			collectOne(all, poolBody[i + 1]) -- 440
			i = i + 1 -- 439
		end -- 439
	end -- 439
	do -- 439
		local i = 0 -- 442
		while i < #poolSmall do -- 442
			collectOne(all, poolSmall[i + 1]) -- 443
			i = i + 1 -- 442
		end -- 442
	end -- 442
	local lefts = {} -- 446
	local rights = {} -- 447
	local bottoms = {} -- 448
	local tops = {} -- 449
	local outOfScreen = 0 -- 450
	do -- 450
		local i = 0 -- 451
		while i < #all do -- 451
			local lb = all[i + 1] -- 452
			local bw = lb.width -- 453
			local bh = lb.height -- 454
			local l = lb.x - bw * lb.anchor.x -- 455
			local r = l + bw -- 456
			local b = lb.y - bh * lb.anchor.y -- 457
			local t = b + bh -- 458
			lefts[#lefts + 1] = l -- 459
			rights[#rights + 1] = r -- 460
			bottoms[#bottoms + 1] = b -- 461
			tops[#tops + 1] = t -- 462
			if l < 0 or r > w or b < 0 or t > h then -- 462
				outOfScreen = outOfScreen + 1 -- 464
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 465
			end -- 465
			i = i + 1 -- 451
		end -- 451
	end -- 451
	local overlaps = 0 -- 469
	do -- 469
		local i = 0 -- 470
		while i < #all do -- 470
			do -- 470
				local j = i + 1 -- 471
				while j < #all do -- 471
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 472
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 473
					if ox > 4 and oy > 4 then -- 473
						overlaps = overlaps + 1 -- 475
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 476
					end -- 476
					j = j + 1 -- 471
				end -- 471
			end -- 471
			i = i + 1 -- 470
		end -- 470
	end -- 470
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 480
end -- 480
function collectOne(out, lb) -- 483
	if lb ~= nil and lb.visible then -- 483
		out[#out + 1] = lb -- 485
	end -- 485
end -- 485
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
	local reg = _G.package.loaded -- 149
	reg["watch.input"] = input -- 150
	parent:schedule(function(frameDt) -- 152
		tick(frameDt) -- 153
		return false -- 154
	end) -- 152
end -- 86
return ____exports -- 86