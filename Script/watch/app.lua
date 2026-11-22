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
function ensurePlay() -- 224
	play = __TS__New(Play, ROOMS[current + 1]) -- 225
	local reg = _G.package.loaded -- 229
	reg["watch.play"] = play -- 230
	reg["watch.room"] = ROOMS[current + 1].key -- 231
	clock:reset() -- 232
end -- 232
function tickPlay(frameDt) -- 241
	if play == nil or draw == nil or input == nil then -- 241
		return -- 243
	end -- 243
	local p = play -- 245
	if input.retry.pressed then -- 245
		input:consumeEdges() -- 247
		play = __TS__New(Play, ROOMS[current + 1], {checkpoint = p.checkpoint}) -- 249
		clock:reset() -- 250
		return -- 251
	end -- 251
	p.aimX = input.mx -- 253
	p.aimY = input.my -- 254
	if p.paused then -- 254
		clock:reset() -- 258
		input:beginStep(true) -- 259
		p:update(STEP, input) -- 260
		input:endStep() -- 261
		p:draw(draw, viewW, viewH) -- 262
		playHud(p) -- 263
		return -- 264
	end -- 264
	local steps = clock:advance(frameDt) -- 267
	local i = 0 -- 268
	do -- 268
		i = 0 -- 269
		while i < steps do -- 269
			input:beginStep(i == 0) -- 270
			p:update(STEP, input) -- 271
			input:endStep() -- 272
			i = i + 1 -- 269
		end -- 269
	end -- 269
	if p.wantRoom ~= "" then -- 269
		local key = p.wantRoom -- 277
		p.wantRoom = "" -- 278
		local idx = -1 -- 279
		local j = 0 -- 280
		do -- 280
			j = 0 -- 281
			while j < #ROOMS do -- 281
				if ROOMS[j + 1].key == key then -- 281
					idx = j -- 283
				end -- 283
				j = j + 1 -- 281
			end -- 281
		end -- 281
		if idx >= 0 then -- 281
			current = idx -- 287
			ensurePlay() -- 288
			clock:reset() -- 289
			dirty = true -- 290
		end -- 290
		return -- 292
	end -- 292
	p:draw(draw, viewW, viewH) -- 295
	playHud(p) -- 296
end -- 296
function playHud(p) -- 300
	local room = ROOMS[current + 1] -- 301
	if titleLabel ~= nil then -- 301
		titleLabel.text = "守望 · D5 完整试玩" -- 303
	end -- 303
	if roomLabel ~= nil then -- 303
		roomLabel.text = room.name -- 306
	end -- 306
	if captionLabel ~= nil then -- 306
		captionLabel.text = p:statusText() -- 309
		captionLabel.color = C_TEXT -- 310
	end -- 310
	if hintLabel ~= nil then -- 310
		hintLabel.text = p:hintText() -- 313
	end -- 313
	if switchLabel ~= nil then -- 313
		switchLabel.text = "G 回灰盒 · Tab 换房 · 1/2/3 快跳 · R 重置" -- 316
	end -- 316
	if rulerLabel ~= nil then -- 316
		rulerLabel.text = "" -- 319
	end -- 319
	if standLabel ~= nil then -- 319
		standLabel.text = "" -- 322
	end -- 322
	if cartLabel ~= nil then -- 322
		cartLabel.text = "" -- 325
	end -- 325
	local i = 0 -- 327
	do -- 327
		i = 0 -- 328
		while i < #poolBody do -- 328
			poolBody[i + 1].visible = false -- 329
			i = i + 1 -- 328
		end -- 328
	end -- 328
	do -- 328
		i = 0 -- 331
		while i < #poolSmall do -- 331
			poolSmall[i + 1].visible = false -- 332
			i = i + 1 -- 331
		end -- 331
	end -- 331
	place( -- 334
		titleLabel, -- 334
		48, -- 334
		viewH - 40, -- 334
		0, -- 334
		1 -- 334
	) -- 334
	place( -- 335
		roomLabel, -- 335
		48, -- 335
		viewH - 96, -- 335
		0, -- 335
		1 -- 335
	) -- 335
	place( -- 336
		captionLabel, -- 336
		48, -- 336
		viewH - 140, -- 336
		0, -- 336
		1 -- 336
	) -- 336
	place( -- 337
		switchLabel, -- 337
		48, -- 337
		40, -- 337
		0, -- 337
		0 -- 337
	) -- 337
	place( -- 338
		hintLabel, -- 338
		48, -- 338
		84, -- 338
		0, -- 338
		0 -- 338
	) -- 338
end -- 338
function redraw() -- 341
	if draw == nil then -- 341
		return -- 343
	end -- 343
	local w = viewW -- 345
	local h = viewH -- 346
	local room = ROOMS[current + 1] -- 347
	draw:clear() -- 349
	draw:drawRect( -- 352
		Rect(0, h - TOP_H, w, TOP_H), -- 352
		C_BG -- 352
	) -- 352
	draw:drawRect( -- 353
		Rect(0, 0, w, BOTTOM_H), -- 353
		C_BG -- 353
	) -- 353
	draw:drawSegment( -- 354
		Vec2(0, h - TOP_H), -- 354
		Vec2(w, h - TOP_H), -- 354
		1, -- 354
		Color(52, 54, 54, 255) -- 354
	) -- 354
	draw:drawSegment( -- 355
		Vec2(0, BOTTOM_H), -- 355
		Vec2(w, BOTTOM_H), -- 355
		1, -- 355
		Color(52, 54, 54, 255) -- 355
	) -- 355
	local v = computeView(room, w, h) -- 357
	renderWorld( -- 358
		draw, -- 358
		room, -- 358
		v, -- 358
		w, -- 358
		h -- 358
	) -- 358
	local roomTop = v.groundPx + room.height * v.scale -- 360
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 361
	place( -- 363
		titleLabel, -- 363
		48, -- 363
		h - 40, -- 363
		0, -- 363
		1 -- 363
	) -- 363
	place( -- 364
		roomLabel, -- 364
		48, -- 364
		h - 96, -- 364
		0, -- 364
		1 -- 364
	) -- 364
	place( -- 365
		captionLabel, -- 365
		48, -- 365
		h - 140, -- 365
		0, -- 365
		1 -- 365
	) -- 365
	place( -- 367
		switchLabel, -- 367
		48, -- 367
		40, -- 367
		0, -- 367
		0 -- 367
	) -- 367
	place( -- 368
		hintLabel, -- 368
		48, -- 368
		84, -- 368
		0, -- 368
		0 -- 368
	) -- 368
	place( -- 369
		rulerLabel, -- 369
		w - 216, -- 369
		roomTop + 36 + v.scale * 0.5 - 14, -- 369
		1, -- 369
		0 -- 369
	) -- 369
	place( -- 370
		standLabel, -- 370
		48, -- 370
		roomTop + 40, -- 370
		0, -- 370
		0 -- 370
	) -- 370
	place( -- 371
		cartLabel, -- 371
		48, -- 371
		roomTop + 92, -- 371
		0, -- 371
		0 -- 371
	) -- 371
	if roomLabel ~= nil then -- 371
		roomLabel.text = room.name -- 374
	end -- 374
	if captionLabel ~= nil then -- 374
		captionLabel.text = room.caption -- 377
	end -- 377
	if hintLabel ~= nil then -- 377
		local lines = HINTS[current + 1] -- 380
		local merged = lines[1] -- 381
		do -- 381
			local i = 1 -- 382
			while i < #lines do -- 382
				merged = (merged .. "    ") .. lines[i + 1] -- 383
				i = i + 1 -- 382
			end -- 382
		end -- 382
		hintLabel.text = merged -- 385
	end -- 385
	local specs = collectLabels(room, v, w) -- 389
	local body = {} -- 390
	local small = {} -- 391
	do -- 391
		local i = 0 -- 392
		while i < #specs do -- 392
			local s = specs[i + 1] -- 393
			if s.size >= 24 then -- 393
				body[#body + 1] = s -- 395
			else -- 395
				small[#small + 1] = s -- 397
			end -- 397
			i = i + 1 -- 392
		end -- 392
	end -- 392
	applyPool(body, poolBody) -- 400
	applyPool(small, poolSmall) -- 401
	if LAYOUT_AUDIT then -- 401
		auditLayout(w, h) -- 404
	end -- 404
end -- 404
function applyPool(specs, pool) -- 408
	do -- 408
		local i = 0 -- 409
		while i < #pool do -- 409
			local lb = pool[i + 1] -- 410
			if i < #specs then -- 410
				local s = specs[i + 1] -- 412
				lb.text = s.text -- 413
				lb.position = Vec2(s.x, s.y) -- 414
				lb.anchor = Vec2(s.ax, s.ay) -- 415
				lb.color = s.color -- 416
				lb.visible = true -- 417
			else -- 417
				lb.visible = false -- 419
			end -- 419
			i = i + 1 -- 409
		end -- 409
	end -- 409
end -- 409
function auditLayout(w, h) -- 425
	local all = {} -- 426
	collectOne(all, titleLabel) -- 427
	collectOne(all, roomLabel) -- 428
	collectOne(all, captionLabel) -- 429
	collectOne(all, switchLabel) -- 430
	collectOne(all, hintLabel) -- 431
	collectOne(all, rulerLabel) -- 432
	collectOne(all, standLabel) -- 433
	collectOne(all, cartLabel) -- 434
	do -- 434
		local i = 0 -- 435
		while i < #poolBody do -- 435
			collectOne(all, poolBody[i + 1]) -- 436
			i = i + 1 -- 435
		end -- 435
	end -- 435
	do -- 435
		local i = 0 -- 438
		while i < #poolSmall do -- 438
			collectOne(all, poolSmall[i + 1]) -- 439
			i = i + 1 -- 438
		end -- 438
	end -- 438
	local lefts = {} -- 442
	local rights = {} -- 443
	local bottoms = {} -- 444
	local tops = {} -- 445
	local outOfScreen = 0 -- 446
	do -- 446
		local i = 0 -- 447
		while i < #all do -- 447
			local lb = all[i + 1] -- 448
			local bw = lb.width -- 449
			local bh = lb.height -- 450
			local l = lb.x - bw * lb.anchor.x -- 451
			local r = l + bw -- 452
			local b = lb.y - bh * lb.anchor.y -- 453
			local t = b + bh -- 454
			lefts[#lefts + 1] = l -- 455
			rights[#rights + 1] = r -- 456
			bottoms[#bottoms + 1] = b -- 457
			tops[#tops + 1] = t -- 458
			if l < 0 or r > w or b < 0 or t > h then -- 458
				outOfScreen = outOfScreen + 1 -- 460
				print((((((((("AUDIT|越界|" .. lb.text) .. "|") .. tostring(l)) .. ",") .. tostring(r)) .. ",") .. tostring(b)) .. ",") .. tostring(t)) -- 461
			end -- 461
			i = i + 1 -- 447
		end -- 447
	end -- 447
	local overlaps = 0 -- 465
	do -- 465
		local i = 0 -- 466
		while i < #all do -- 466
			do -- 466
				local j = i + 1 -- 467
				while j < #all do -- 467
					local ox = math.min(rights[i + 1], rights[j + 1]) - math.max(lefts[i + 1], lefts[j + 1]) -- 468
					local oy = math.min(tops[i + 1], tops[j + 1]) - math.max(bottoms[i + 1], bottoms[j + 1]) -- 469
					if ox > 4 and oy > 4 then -- 469
						overlaps = overlaps + 1 -- 471
						print((((((("AUDIT|重叠|" .. all[i + 1].text) .. " <> ") .. all[j + 1].text) .. "|") .. tostring(ox)) .. "x") .. tostring(oy)) -- 472
					end -- 472
					j = j + 1 -- 467
				end -- 467
			end -- 467
			i = i + 1 -- 466
		end -- 466
	end -- 466
	print((((((((("AUDIT|小结|标签=" .. tostring(#all)) .. "|越界=") .. tostring(outOfScreen)) .. "|重叠=") .. tostring(overlaps)) .. "|屏幕=") .. tostring(w)) .. "x") .. tostring(h)) -- 476
end -- 476
function collectOne(out, lb) -- 479
	if lb ~= nil and lb.visible then -- 479
		out[#out + 1] = lb -- 481
	end -- 481
end -- 481
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