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
			local leaving = p:drainEvents() -- 293
			current = idx -- 294
			ensurePlay() -- 295
			local fresh = play -- 296
			if fresh ~= nil then -- 296
				fresh:adoptEvents(leaving) -- 298
			end -- 298
			clock:reset() -- 300
			dirty = true -- 301
		end -- 301
		return -- 303
	end -- 303
	p:draw(draw, viewW, viewH) -- 306
	playHud(p) -- 307
end -- 307
function playHud(p) -- 311
	local room = ROOMS[current + 1] -- 312
	if titleLabel ~= nil then -- 312
		titleLabel.text = "守望 · D5 完整试玩" -- 314
	end -- 314
	if roomLabel ~= nil then -- 314
		roomLabel.text = room.name -- 317
	end -- 317
	if captionLabel ~= nil then -- 317
		captionLabel.text = p:statusText() -- 320
		captionLabel.color = C_TEXT -- 321
	end -- 321
	if hintLabel ~= nil then -- 321
		hintLabel.text = p:hintText() -- 324
	end -- 324
	if switchLabel ~= nil then -- 324
		switchLabel.text = "G 回灰盒 · Tab 换房 · 1/2/3 快跳 · R 重置" -- 327
	end -- 327
	if rulerLabel ~= nil then -- 327
		rulerLabel.text = "" -- 330
	end -- 330
	if standLabel ~= nil then -- 330
		standLabel.text = "" -- 333
	end -- 333
	if cartLabel ~= nil then -- 333
		cartLabel.text = "" -- 336
	end -- 336
	local i = 0 -- 338
	do -- 338
		i = 0 -- 339
		while i < #poolBody do -- 339
			poolBody[i + 1].visible = false -- 340
			i = i + 1 -- 339
		end -- 339
	end -- 339
	do -- 339
		i = 0 -- 342
		while i < #poolSmall do -- 342
			poolSmall[i + 1].visible = false -- 343
			i = i + 1 -- 342
		end -- 342
	end -- 342
	place( -- 345
		titleLabel, -- 345
		48, -- 345
		viewH - 40, -- 345
		0, -- 345
		1 -- 345
	) -- 345
	place( -- 346
		roomLabel, -- 346
		48, -- 346
		viewH - 96, -- 346
		0, -- 346
		1 -- 346
	) -- 346
	place( -- 347
		captionLabel, -- 347
		48, -- 347
		viewH - 140, -- 347
		0, -- 347
		1 -- 347
	) -- 347
	place( -- 348
		switchLabel, -- 348
		48, -- 348
		40, -- 348
		0, -- 348
		0 -- 348
	) -- 348
	place( -- 349
		hintLabel, -- 349
		48, -- 349
		84, -- 349
		0, -- 349
		0 -- 349
	) -- 349
end -- 349
function redraw() -- 352
	if draw == nil then -- 352
		return -- 354
	end -- 354
	local w = viewW -- 356
	local h = viewH -- 357
	local room = ROOMS[current + 1] -- 358
	draw:clear() -- 360
	draw:drawRect( -- 363
		Rect(0, h - TOP_H, w, TOP_H), -- 363
		C_BG -- 363
	) -- 363
	draw:drawRect( -- 364
		Rect(0, 0, w, BOTTOM_H), -- 364
		C_BG -- 364
	) -- 364
	draw:drawSegment( -- 365
		Vec2(0, h - TOP_H), -- 365
		Vec2(w, h - TOP_H), -- 365
		1, -- 365
		Color(52, 54, 54, 255) -- 365
	) -- 365
	draw:drawSegment( -- 366
		Vec2(0, BOTTOM_H), -- 366
		Vec2(w, BOTTOM_H), -- 366
		1, -- 366
		Color(52, 54, 54, 255) -- 366
	) -- 366
	local v = computeView(room, w, h) -- 368
	renderWorld( -- 369
		draw, -- 369
		room, -- 369
		v, -- 369
		w, -- 369
		h -- 369
	) -- 369
	local roomTop = v.groundPx + room.height * v.scale -- 371
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 372
	place( -- 374
		titleLabel, -- 374
		48, -- 374
		h - 40, -- 374
		0, -- 374
		1 -- 374
	) -- 374
	place( -- 375
		roomLabel, -- 375
		48, -- 375
		h - 96, -- 375
		0, -- 375
		1 -- 375
	) -- 375
	place( -- 376
		captionLabel, -- 376
		48, -- 376
		h - 140, -- 376
		0, -- 376
		1 -- 376
	) -- 376
	place( -- 378
		switchLabel, -- 378
		48, -- 378
		40, -- 378
		0, -- 378
		0 -- 378
	) -- 378
	place( -- 379
		hintLabel, -- 379
		48, -- 379
		84, -- 379
		0, -- 379
		0 -- 379
	) -- 379
	place( -- 380
		rulerLabel, -- 380
		w - 216, -- 380
		roomTop + 36 + v.scale * 0.5 - 14, -- 380
		1, -- 380
		0 -- 380
	) -- 380
	place( -- 381
		standLabel, -- 381
		48, -- 381
		roomTop + 40, -- 381
		0, -- 381
		0 -- 381
	) -- 381
	place( -- 382
		cartLabel, -- 382
		48, -- 382
		roomTop + 92, -- 382
		0, -- 382
		0 -- 382
	) -- 382
	if roomLabel ~= nil then -- 382
		roomLabel.text = room.name -- 385
	end -- 385
	if captionLabel ~= nil then -- 385
		captionLabel.text = room.caption -- 388
	end -- 388
	if hintLabel ~= nil then -- 388
		local lines = HINTS[current + 1] -- 391
		local merged = lines[1] -- 392
		do -- 392
			local i = 1 -- 393
			while i < #lines do -- 393
				merged = (merged .. "    ") .. lines[i + 1] -- 394
				i = i + 1 -- 393
			end -- 393
		end -- 393
		hintLabel.text = merged -- 396
	end -- 396
	local specs = collectLabels(room, v, w) -- 400
	local body = {} -- 401
	local small = {} -- 402
	do -- 402
		local i = 0 -- 403
		while i < #specs do -- 403
			local s = specs[i + 1] -- 404
			if s.size >= 24 then -- 404
				body[#body + 1] = s -- 406
			else -- 406
				small[#small + 1] = s -- 408
			end -- 408
			i = i + 1 -- 403
		end -- 403
	end -- 403
	applyPool(body, poolBody) -- 411
	applyPool(small, poolSmall) -- 412
	if LAYOUT_AUDIT then -- 412
		auditLayout(w, h) -- 415
	end -- 415
end -- 415
function applyPool(specs, pool) -- 419
	do -- 419
		local i = 0 -- 420
		while i < #pool do -- 420
			local lb = pool[i + 1] -- 421
			if i < #specs then -- 421
				local s = specs[i + 1] -- 423
				lb.text = s.text -- 424
				lb.position = Vec2(s.x, s.y) -- 425
				lb.anchor = Vec2(s.ax, s.ay) -- 426
				lb.color = s.color -- 427
				lb.visible = true -- 428
			else -- 428
				lb.visible = false -- 430
			end -- 430
			i = i + 1 -- 420
		end -- 420
	end -- 420
end -- 420
function auditLayout(w, h) -- 436
	local all = {} -- 437
	collectOne(all, titleLabel) -- 438
	collectOne(all, roomLabel) -- 439
	collectOne(all, captionLabel) -- 440
	collectOne(all, switchLabel) -- 441
	collectOne(all, hintLabel) -- 442
	collectOne(all, rulerLabel) -- 443
	collectOne(all, standLabel) -- 444
	collectOne(all, cartLabel) -- 445
	do -- 445
		local i = 0 -- 446
		while i < #poolBody do -- 446
			collectOne(all, poolBody[i + 1]) -- 447
			i = i + 1 -- 446
		end -- 446
	end -- 446
	do -- 446
		local i = 0 -- 449
		while i < #poolSmall do -- 449
			collectOne(all, poolSmall[i + 1]) -- 450
			i = i + 1 -- 449
		end -- 449
	end -- 449
	local lefts = {} -- 453
	local rights = {} -- 454
	local bottoms = {} -- 455
	local tops = {} -- 456
	local outOfScreen = 0 -- 457
	do -- 457
		local i = 0 -- 458
		while i < #all do -- 458
			local lb = all[i + 1] -- 459
			local bw = lb.width -- 460
			local bh = lb.height -- 461
			local l = lb.x - bw * lb.anchor.x -- 462
			local r = l + bw -- 463
			local b = lb.y - bh * lb.anchor.y -- 464
			local t = b + bh -- 465
			lefts[#lefts + 1] = l -- 466
			rights[#rights + 1] = r -- 467
			bottoms[#bottoms + 1] = b -- 468
			tops[#tops + 1] = t -- 469
			if l < 0 or r > w or b < 0 or t > h then -- 469
				outOfScreen = outOfScreen + 1 -- 471
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 472
			end -- 472
			i = i + 1 -- 458
		end -- 458
	end -- 458
	local overlaps = 0 -- 476
	do -- 476
		local i = 0 -- 477
		while i < #all do -- 477
			do -- 477
				local j = i + 1 -- 478
				while j < #all do -- 478
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 479
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 480
					if ox > 4 and oy > 4 then -- 480
						overlaps = overlaps + 1 -- 482
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 483
					end -- 483
					j = j + 1 -- 478
				end -- 478
			end -- 478
			i = i + 1 -- 477
		end -- 477
	end -- 477
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 487
end -- 487
function collectOne(out, lb) -- 490
	if lb ~= nil and lb.visible then -- 490
		out[#out + 1] = lb -- 492
	end -- 492
end -- 492
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