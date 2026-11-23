-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local place, setMode, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local DrawNode = ____Dora.DrawNode -- 8
local Label = ____Dora.Label -- 8
local Node = ____Dora.Node -- 8
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
local ____frontend = require("Script.watch.fe.frontend") -- 15
local WatchFrontend = ____frontend.WatchFrontend -- 15
function place(lb, x, y, ax, ay) -- 74
	if lb == nil then -- 74
		return -- 76
	end -- 76
	lb.position = Vec2(x, y) -- 78
	lb.anchor = Vec2(ax, ay) -- 79
	lb.visible = true -- 80
end -- 80
function setMode(nextMode) -- 212
	mode = nextMode -- 213
	if grayboxLayer ~= nil then -- 213
		grayboxLayer.visible = mode == 0 -- 215
	end -- 215
	if fe ~= nil then -- 215
		fe:setVisible(mode == 1) -- 218
	end -- 218
	dirty = true -- 220
	clock:reset() -- 221
end -- 221
function enterPlayRoom(idx) -- 224
	current = idx -- 225
	setMode(1) -- 226
	if fe ~= nil then -- 226
		fe.screen = "play" -- 228
	end -- 228
	play = nil -- 230
	ensurePlay() -- 231
end -- 231
function pickByIndex(idx) -- 234
	if idx < 0 or idx >= #ROOMS then -- 234
		return -- 236
	end -- 236
	current = idx -- 238
	dirty = true -- 239
	play = nil -- 240
	clock:reset() -- 241
	if mode == 1 then -- 241
		if fe ~= nil then -- 241
			fe.screen = "play" -- 244
		end -- 244
		ensurePlay() -- 246
	end -- 246
end -- 246
function applySize() -- 250
	if root == nil then -- 250
		return -- 252
	end -- 252
	root.size = Size(viewW, viewH) -- 254
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 255
end -- 255
function tick(frameDt) -- 258
	local w = View.size.width -- 259
	local h = View.size.height -- 260
	if w ~= viewW or h ~= viewH then -- 260
		viewW = w -- 262
		viewH = h -- 263
		applySize() -- 264
		dirty = true -- 265
	end -- 265
	if input == nil then -- 265
		return -- 268
	end -- 268
	input:update() -- 270
	if input.toggleView.pressed then -- 270
		input.toggleView.pressed = false -- 274
		setMode(mode == 0 and 1 or 0) -- 275
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 275
			ensurePlay() -- 277
		end -- 277
	end -- 277
	if input.pickRoom ~= 0 then -- 277
		local idx = input.pickRoom - 1 -- 283
		input.pickRoom = 0 -- 284
		pickByIndex(idx) -- 285
	elseif input.tab.pressed then -- 285
		input.tab.pressed = false -- 287
		pickByIndex((current + 1) % #ROOMS) -- 288
	end -- 288
	if mode == 1 then -- 288
		tickFrontend(frameDt) -- 292
		return -- 293
	end -- 293
	if dirty then -- 293
		redrawGraybox() -- 296
		dirty = false -- 297
	end -- 297
end -- 297
function registerPlay() -- 302
	local reg = _G.package.loaded -- 303
	reg["watch.play"] = play -- 304
	reg["watch.room"] = ROOMS[current + 1].key -- 305
end -- 305
function ensurePlay(resume) -- 309
	play = __TS__New(Play, ROOMS[current + 1], resume) -- 310
	registerPlay() -- 311
	clock:reset() -- 312
	if fe ~= nil then -- 312
		fe:bindPlay(play, viewW, viewH) -- 314
	end -- 314
end -- 314
function tickFrontend(frameDt) -- 318
	if fe == nil or input == nil then -- 318
		return -- 320
	end -- 320
	if fe.screen ~= "play" then -- 320
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 325
		input:consumeEdges() -- 326
		if act.type == "start" then -- 326
			enterPlayRoom(0) -- 328
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 328
			enterPlayRoom(act.roomIndex) -- 330
		elseif act.type == "openChapters" then -- 330
			fe.screen = "chapters" -- 332
		elseif act.type == "openControls" then -- 332
			fe.screen = "controls" -- 334
		elseif act.type == "backTitle" then -- 334
			fe.screen = "title" -- 336
		end -- 336
		return -- 338
	end -- 338
	if play == nil then -- 338
		ensurePlay() -- 343
	end -- 343
	if play == nil then -- 343
		return -- 346
	end -- 346
	local p = play -- 348
	if input.retry.pressed then -- 348
		input:consumeEdges() -- 351
		ensurePlay({checkpoint = p.checkpoint}) -- 353
		return -- 354
	end -- 354
	p.aimX = input.mx -- 357
	p.aimY = input.my -- 358
	if p.paused then -- 358
		clock:reset() -- 361
		input:beginStep(true) -- 362
		p:update(STEP, input) -- 363
		input:endStep() -- 364
		local pauseAct = fe:renderPlay( -- 365
			frameDt, -- 365
			p, -- 365
			input, -- 365
			viewW, -- 365
			viewH -- 365
		) -- 365
		if pauseAct.type == "resume" then -- 365
			p.paused = false -- 367
		elseif pauseAct.type == "retry" then -- 367
			ensurePlay({checkpoint = p.checkpoint}) -- 369
		elseif pauseAct.type == "openChapters" then -- 369
			p.paused = false -- 371
			fe.screen = "chapters" -- 372
		elseif pauseAct.type == "toTitle" then -- 372
			p.paused = false -- 374
			fe.screen = "title" -- 375
		end -- 375
		return -- 377
	end -- 377
	local steps = clock:advance(frameDt) -- 380
	local i = 0 -- 381
	do -- 381
		i = 0 -- 382
		while i < steps do -- 382
			input:beginStep(i == 0) -- 383
			p:update(STEP, input) -- 384
			input:endStep() -- 385
			i = i + 1 -- 382
		end -- 382
	end -- 382
	if p.wantRoom ~= "" then -- 382
		local key = p.wantRoom -- 390
		p.wantRoom = "" -- 391
		local idx = -1 -- 392
		local j = 0 -- 393
		do -- 393
			j = 0 -- 394
			while j < #ROOMS do -- 394
				if ROOMS[j + 1].key == key then -- 394
					idx = j -- 396
				end -- 396
				j = j + 1 -- 394
			end -- 394
		end -- 394
		if idx >= 0 then -- 394
			local leaving = p:drainEvents() -- 402
			current = idx -- 403
			ensurePlay() -- 404
			local fresh = play -- 405
			if fresh ~= nil then -- 405
				fresh:adoptEvents(leaving) -- 407
			end -- 407
			clock:reset() -- 409
			dirty = true -- 410
		end -- 410
		return -- 412
	end -- 412
	fe:renderPlay( -- 415
		frameDt, -- 415
		p, -- 415
		input, -- 415
		viewW, -- 415
		viewH -- 415
	) -- 415
end -- 415
function redrawGraybox() -- 419
	if draw == nil then -- 419
		return -- 421
	end -- 421
	local w = viewW -- 423
	local h = viewH -- 424
	local room = ROOMS[current + 1] -- 425
	draw:clear() -- 427
	draw:drawRect( -- 428
		Rect(0, h - TOP_H, w, TOP_H), -- 428
		C_BG -- 428
	) -- 428
	draw:drawRect( -- 429
		Rect(0, 0, w, BOTTOM_H), -- 429
		C_BG -- 429
	) -- 429
	draw:drawSegment( -- 430
		Vec2(0, h - TOP_H), -- 430
		Vec2(w, h - TOP_H), -- 430
		1, -- 430
		Color(52, 54, 54, 255) -- 430
	) -- 430
	draw:drawSegment( -- 431
		Vec2(0, BOTTOM_H), -- 431
		Vec2(w, BOTTOM_H), -- 431
		1, -- 431
		Color(52, 54, 54, 255) -- 431
	) -- 431
	local v = computeView(room, w, h) -- 433
	renderWorld( -- 434
		draw, -- 434
		room, -- 434
		v, -- 434
		w, -- 434
		h -- 434
	) -- 434
	local roomTop = v.groundPx + room.height * v.scale -- 436
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 437
	place( -- 439
		titleLabel, -- 439
		48, -- 439
		h - 40, -- 439
		0, -- 439
		1 -- 439
	) -- 439
	place( -- 440
		roomLabel, -- 440
		48, -- 440
		h - 96, -- 440
		0, -- 440
		1 -- 440
	) -- 440
	place( -- 441
		captionLabel, -- 441
		48, -- 441
		h - 140, -- 441
		0, -- 441
		1 -- 441
	) -- 441
	place( -- 443
		switchLabel, -- 443
		48, -- 443
		40, -- 443
		0, -- 443
		0 -- 443
	) -- 443
	place( -- 444
		hintLabel, -- 444
		48, -- 444
		84, -- 444
		0, -- 444
		0 -- 444
	) -- 444
	place( -- 445
		rulerLabel, -- 445
		w - 216, -- 445
		roomTop + 36 + v.scale * 0.5 - 14, -- 445
		1, -- 445
		0 -- 445
	) -- 445
	place( -- 446
		standLabel, -- 446
		48, -- 446
		roomTop + 40, -- 446
		0, -- 446
		0 -- 446
	) -- 446
	place( -- 447
		cartLabel, -- 447
		48, -- 447
		roomTop + 92, -- 447
		0, -- 447
		0 -- 447
	) -- 447
	if roomLabel ~= nil then -- 447
		roomLabel.text = room.name -- 450
	end -- 450
	if captionLabel ~= nil then -- 450
		captionLabel.text = room.caption -- 453
	end -- 453
	if hintLabel ~= nil then -- 453
		local hintIdx = math.min(current, #HINTS - 1) -- 456
		local lines = HINTS[hintIdx + 1] -- 457
		local merged = lines[1] -- 458
		do -- 458
			local i = 1 -- 459
			while i < #lines do -- 459
				merged = (merged .. "    ") .. lines[i + 1] -- 460
				i = i + 1 -- 459
			end -- 459
		end -- 459
		hintLabel.text = merged -- 462
	end -- 462
	local specs = collectLabels(room, v, w) -- 465
	local body = {} -- 466
	local small = {} -- 467
	do -- 467
		local i = 0 -- 468
		while i < #specs do -- 468
			local s = specs[i + 1] -- 469
			if s.size >= 24 then -- 469
				body[#body + 1] = s -- 471
			else -- 471
				small[#small + 1] = s -- 473
			end -- 473
			i = i + 1 -- 468
		end -- 468
	end -- 468
	applyPool(body, poolBody) -- 476
	applyPool(small, poolSmall) -- 477
	if LAYOUT_AUDIT then -- 477
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 480
	end -- 480
end -- 480
function applyPool(specs, pool) -- 484
	do -- 484
		local i = 0 -- 485
		while i < #pool do -- 485
			local lb = pool[i + 1] -- 486
			if i < #specs then -- 486
				local s = specs[i + 1] -- 488
				lb.text = s.text -- 489
				lb.position = Vec2(s.x, s.y) -- 490
				lb.anchor = Vec2(s.ax, s.ay) -- 491
				lb.color = s.color -- 492
				lb.visible = true -- 493
			else -- 493
				lb.visible = false -- 495
			end -- 495
			i = i + 1 -- 485
		end -- 485
	end -- 485
end -- 485
local FONT = "sarasa-mono-sc-regular" -- 20
LAYOUT_AUDIT = false -- 21
local C_TEXT = Color(236, 236, 232, 255) -- 23
local C_DIM = Color(150, 154, 152, 255) -- 24
local C_ACCENT = Color(226, 186, 84, 255) -- 25
C_BG = Color(17, 18, 19, 255) -- 26
local POOL_BODY = 30 -- 28
local POOL_SMALL = 44 -- 29
TOP_H = 208 -- 30
BOTTOM_H = 216 -- 31
poolBody = {} -- 45
poolSmall = {} -- 46
current = 0 -- 48
viewW = 0 -- 49
viewH = 0 -- 50
dirty = true -- 51
mode = 1 -- 53
clock = __TS__New(StepClock) -- 57
local function makeGrayboxLabel(text, size, color) -- 59
	if grayboxLayer == nil then -- 59
		return nil -- 61
	end -- 61
	local lb = Label(FONT, size) -- 63
	if lb == nil then -- 63
		return nil -- 65
	end -- 65
	lb.text = text -- 67
	lb.color = color -- 68
	lb:addTo(grayboxLayer) -- 69
	lb.visible = true -- 70
	return lb -- 71
end -- 59
function ____exports.start(parent, initialMode, startScreen) -- 83
	if initialMode == nil then -- 83
		initialMode = 1 -- 83
	end -- 83
	if startScreen == nil then -- 83
		startScreen = "title" -- 83
	end -- 83
	root = parent -- 84
	mode = initialMode -- 85
	grayboxLayer = Node() -- 88
	grayboxLayer.order = 2 -- 89
	grayboxLayer:addTo(parent) -- 90
	draw = DrawNode() -- 92
	draw:addTo(grayboxLayer) -- 93
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 95
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 96
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 97
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 98
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 99
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 100
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 101
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 102
	do -- 102
		local i = 0 -- 104
		while i < POOL_BODY do -- 104
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 105
			if lb ~= nil then -- 105
				poolBody[#poolBody + 1] = lb -- 107
			end -- 107
			i = i + 1 -- 104
		end -- 104
	end -- 104
	do -- 104
		local i = 0 -- 110
		while i < POOL_SMALL do -- 110
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 111
			if lb ~= nil then -- 111
				poolSmall[#poolSmall + 1] = lb -- 113
			end -- 113
			i = i + 1 -- 110
		end -- 110
	end -- 110
	fe = __TS__New(WatchFrontend, parent) -- 118
	fe.screen = startScreen -- 119
	grayboxLayer.visible = mode == 0 -- 120
	fe:setVisible(mode == 1) -- 121
	input = __TS__New(Input) -- 123
	parent:onKeyDown(function(key) -- 126
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 126
			fe.menus:onKeyEvent(key) -- 128
		end -- 128
		if input ~= nil and mode == 1 and fe ~= nil and fe.screen == "play" then -- 128
			if key == "E" then -- 128
				input.interact.pressed = true -- 132
			elseif key == "Space" then -- 132
				input.jump.pressed = true -- 134
			elseif key == "Escape" then -- 134
				input.pause.pressed = true -- 136
			elseif key == "R" then -- 136
				input.retry.pressed = true -- 138
			end -- 138
		end -- 138
		if key == "F1" then -- 138
			enterPlayRoom(current) -- 142
		elseif key == "F2" then -- 142
			setMode(0) -- 144
		elseif key == "1" then -- 144
			pickByIndex(0) -- 146
		elseif key == "2" then -- 146
			pickByIndex(1) -- 148
		elseif key == "3" then -- 148
			pickByIndex(2) -- 150
		elseif key == "4" then -- 150
			pickByIndex(3) -- 152
		elseif key == "5" then -- 152
			pickByIndex(4) -- 154
		elseif key == "6" then -- 154
			pickByIndex(5) -- 156
		elseif key == "7" then -- 156
			pickByIndex(6) -- 158
		elseif key == "8" then -- 158
			pickByIndex(7) -- 160
		end -- 160
	end) -- 126
	viewW = View.size.width -- 164
	viewH = View.size.height -- 165
	applySize() -- 166
	local reg = _G.package.loaded -- 169
	reg["watch.input"] = input -- 170
	reg["watch.fe"] = { -- 171
		setScreen = function(sc) -- 172
			if fe == nil then -- 172
				return -- 174
			end -- 174
			setMode(1) -- 176
			fe.screen = sc -- 177
			if sc == "play" then -- 177
				ensurePlay() -- 179
			end -- 179
		end, -- 172
		jumpRoom = function(keyOrIdx) -- 182
			local idx = -1 -- 183
			if type(keyOrIdx) == "number" then -- 183
				idx = keyOrIdx -- 185
			else -- 185
				local k = 0 -- 187
				do -- 187
					k = 0 -- 188
					while k < #ROOMS do -- 188
						if ROOMS[k + 1].key == keyOrIdx then -- 188
							idx = k -- 190
						end -- 190
						k = k + 1 -- 188
					end -- 188
				end -- 188
			end -- 188
			if idx >= 0 and idx < #ROOMS then -- 188
				enterPlayRoom(idx) -- 195
			end -- 195
		end, -- 182
		getPlay = function() return play end, -- 198
		getFrontend = function() return fe end -- 199
	} -- 199
	if mode == 1 and startScreen == "play" then -- 199
		ensurePlay() -- 203
	end -- 203
	parent:schedule(function(frameDt) -- 206
		tick(frameDt) -- 207
		return false -- 208
	end) -- 206
end -- 83
return ____exports -- 83