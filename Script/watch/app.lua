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
			local leaving = p:drainEvents() -- 292
			current = idx -- 293
			ensurePlay() -- 294
			local fresh = play -- 295
			if fresh ~= nil then -- 295
				fresh:adoptEvents(leaving) -- 297
			end -- 297
			clock:reset() -- 299
			dirty = true -- 300
		end -- 300
		return -- 302
	end -- 302
	p:draw(draw, viewW, viewH) -- 305
	playHud(p) -- 306
end -- 306
function playHud(p) -- 310
	local room = ROOMS[current + 1] -- 311
	if titleLabel ~= nil then -- 311
		titleLabel.text = "守望 · D5 完整试玩" -- 313
	end -- 313
	if roomLabel ~= nil then -- 313
		roomLabel.text = room.name -- 316
	end -- 316
	if captionLabel ~= nil then -- 316
		captionLabel.text = p:statusText() -- 319
		captionLabel.color = C_TEXT -- 320
	end -- 320
	if hintLabel ~= nil then -- 320
		hintLabel.text = p:hintText() -- 323
	end -- 323
	if switchLabel ~= nil then -- 323
		switchLabel.text = "G 回灰盒 · Tab 换房 · 1/2/3 快跳 · R 重置" -- 326
	end -- 326
	if rulerLabel ~= nil then -- 326
		rulerLabel.text = "" -- 329
	end -- 329
	if standLabel ~= nil then -- 329
		standLabel.text = "" -- 332
	end -- 332
	if cartLabel ~= nil then -- 332
		cartLabel.text = "" -- 335
	end -- 335
	local i = 0 -- 337
	do -- 337
		i = 0 -- 338
		while i < #poolBody do -- 338
			poolBody[i + 1].visible = false -- 339
			i = i + 1 -- 338
		end -- 338
	end -- 338
	do -- 338
		i = 0 -- 341
		while i < #poolSmall do -- 341
			poolSmall[i + 1].visible = false -- 342
			i = i + 1 -- 341
		end -- 341
	end -- 341
	place( -- 344
		titleLabel, -- 344
		48, -- 344
		viewH - 40, -- 344
		0, -- 344
		1 -- 344
	) -- 344
	place( -- 345
		roomLabel, -- 345
		48, -- 345
		viewH - 96, -- 345
		0, -- 345
		1 -- 345
	) -- 345
	place( -- 346
		captionLabel, -- 346
		48, -- 346
		viewH - 140, -- 346
		0, -- 346
		1 -- 346
	) -- 346
	place( -- 347
		switchLabel, -- 347
		48, -- 347
		40, -- 347
		0, -- 347
		0 -- 347
	) -- 347
	place( -- 348
		hintLabel, -- 348
		48, -- 348
		84, -- 348
		0, -- 348
		0 -- 348
	) -- 348
end -- 348
function redraw() -- 351
	if draw == nil then -- 351
		return -- 353
	end -- 353
	local w = viewW -- 355
	local h = viewH -- 356
	local room = ROOMS[current + 1] -- 357
	draw:clear() -- 359
	draw:drawRect( -- 362
		Rect(0, h - TOP_H, w, TOP_H), -- 362
		C_BG -- 362
	) -- 362
	draw:drawRect( -- 363
		Rect(0, 0, w, BOTTOM_H), -- 363
		C_BG -- 363
	) -- 363
	draw:drawSegment( -- 364
		Vec2(0, h - TOP_H), -- 364
		Vec2(w, h - TOP_H), -- 364
		1, -- 364
		Color(52, 54, 54, 255) -- 364
	) -- 364
	draw:drawSegment( -- 365
		Vec2(0, BOTTOM_H), -- 365
		Vec2(w, BOTTOM_H), -- 365
		1, -- 365
		Color(52, 54, 54, 255) -- 365
	) -- 365
	local v = computeView(room, w, h) -- 367
	renderWorld( -- 368
		draw, -- 368
		room, -- 368
		v, -- 368
		w, -- 368
		h -- 368
	) -- 368
	local roomTop = v.groundPx + room.height * v.scale -- 370
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 371
	place( -- 373
		titleLabel, -- 373
		48, -- 373
		h - 40, -- 373
		0, -- 373
		1 -- 373
	) -- 373
	place( -- 374
		roomLabel, -- 374
		48, -- 374
		h - 96, -- 374
		0, -- 374
		1 -- 374
	) -- 374
	place( -- 375
		captionLabel, -- 375
		48, -- 375
		h - 140, -- 375
		0, -- 375
		1 -- 375
	) -- 375
	place( -- 377
		switchLabel, -- 377
		48, -- 377
		40, -- 377
		0, -- 377
		0 -- 377
	) -- 377
	place( -- 378
		hintLabel, -- 378
		48, -- 378
		84, -- 378
		0, -- 378
		0 -- 378
	) -- 378
	place( -- 379
		rulerLabel, -- 379
		w - 216, -- 379
		roomTop + 36 + v.scale * 0.5 - 14, -- 379
		1, -- 379
		0 -- 379
	) -- 379
	place( -- 380
		standLabel, -- 380
		48, -- 380
		roomTop + 40, -- 380
		0, -- 380
		0 -- 380
	) -- 380
	place( -- 381
		cartLabel, -- 381
		48, -- 381
		roomTop + 92, -- 381
		0, -- 381
		0 -- 381
	) -- 381
	if roomLabel ~= nil then -- 381
		roomLabel.text = room.name -- 384
	end -- 384
	if captionLabel ~= nil then -- 384
		captionLabel.text = room.caption -- 387
	end -- 387
	if hintLabel ~= nil then -- 387
		local lines = HINTS[current + 1] -- 390
		local merged = lines[1] -- 391
		do -- 391
			local i = 1 -- 392
			while i < #lines do -- 392
				merged = (merged .. "    ") .. lines[i + 1] -- 393
				i = i + 1 -- 392
			end -- 392
		end -- 392
		hintLabel.text = merged -- 395
	end -- 395
	local specs = collectLabels(room, v, w) -- 399
	local body = {} -- 400
	local small = {} -- 401
	do -- 401
		local i = 0 -- 402
		while i < #specs do -- 402
			local s = specs[i + 1] -- 403
			if s.size >= 24 then -- 403
				body[#body + 1] = s -- 405
			else -- 405
				small[#small + 1] = s -- 407
			end -- 407
			i = i + 1 -- 402
		end -- 402
	end -- 402
	applyPool(body, poolBody) -- 410
	applyPool(small, poolSmall) -- 411
	if LAYOUT_AUDIT then -- 411
		auditLayout(w, h) -- 414
	end -- 414
end -- 414
function applyPool(specs, pool) -- 418
	do -- 418
		local i = 0 -- 419
		while i < #pool do -- 419
			local lb = pool[i + 1] -- 420
			if i < #specs then -- 420
				local s = specs[i + 1] -- 422
				lb.text = s.text -- 423
				lb.position = Vec2(s.x, s.y) -- 424
				lb.anchor = Vec2(s.ax, s.ay) -- 425
				lb.color = s.color -- 426
				lb.visible = true -- 427
			else -- 427
				lb.visible = false -- 429
			end -- 429
			i = i + 1 -- 419
		end -- 419
	end -- 419
end -- 419
function auditLayout(w, h) -- 435
	local all = {} -- 436
	collectOne(all, titleLabel) -- 437
	collectOne(all, roomLabel) -- 438
	collectOne(all, captionLabel) -- 439
	collectOne(all, switchLabel) -- 440
	collectOne(all, hintLabel) -- 441
	collectOne(all, rulerLabel) -- 442
	collectOne(all, standLabel) -- 443
	collectOne(all, cartLabel) -- 444
	do -- 444
		local i = 0 -- 445
		while i < #poolBody do -- 445
			collectOne(all, poolBody[i + 1]) -- 446
			i = i + 1 -- 445
		end -- 445
	end -- 445
	do -- 445
		local i = 0 -- 448
		while i < #poolSmall do -- 448
			collectOne(all, poolSmall[i + 1]) -- 449
			i = i + 1 -- 448
		end -- 448
	end -- 448
	local lefts = {} -- 452
	local rights = {} -- 453
	local bottoms = {} -- 454
	local tops = {} -- 455
	local outOfScreen = 0 -- 456
	do -- 456
		local i = 0 -- 457
		while i < #all do -- 457
			local lb = all[i + 1] -- 458
			local bw = lb.width -- 459
			local bh = lb.height -- 460
			local l = lb.x - bw * lb.anchor.x -- 461
			local r = l + bw -- 462
			local b = lb.y - bh * lb.anchor.y -- 463
			local t = b + bh -- 464
			lefts[#lefts + 1] = l -- 465
			rights[#rights + 1] = r -- 466
			bottoms[#bottoms + 1] = b -- 467
			tops[#tops + 1] = t -- 468
			if l < 0 or r > w or b < 0 or t > h then -- 468
				outOfScreen = outOfScreen + 1 -- 470
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 471
			end -- 471
			i = i + 1 -- 457
		end -- 457
	end -- 457
	local overlaps = 0 -- 475
	do -- 475
		local i = 0 -- 476
		while i < #all do -- 476
			do -- 476
				local j = i + 1 -- 477
				while j < #all do -- 477
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 478
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 479
					if ox > 4 and oy > 4 then -- 479
						overlaps = overlaps + 1 -- 481
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 482
					end -- 482
					j = j + 1 -- 477
				end -- 477
			end -- 477
			i = i + 1 -- 476
		end -- 476
	end -- 476
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 486
end -- 486
function collectOne(out, lb) -- 489
	if lb ~= nil and lb.visible then -- 489
		out[#out + 1] = lb -- 491
	end -- 491
end -- 491
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