-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local place, setMode, enterPlayRoom, pickByIndex, applySize, tick, ensurePlay, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
function setMode(nextMode) -- 217
	mode = nextMode -- 218
	if grayboxLayer ~= nil then -- 218
		grayboxLayer.visible = mode == 0 -- 220
	end -- 220
	if fe ~= nil then -- 220
		fe:setVisible(mode == 1) -- 223
	end -- 223
	dirty = true -- 225
	clock:reset() -- 226
end -- 226
function enterPlayRoom(idx) -- 229
	current = idx -- 230
	setMode(1) -- 231
	if fe ~= nil then -- 231
		fe.screen = "play" -- 233
	end -- 233
	play = nil -- 235
	ensurePlay() -- 236
end -- 236
function pickByIndex(idx) -- 239
	if idx < 0 or idx >= #ROOMS then -- 239
		return -- 241
	end -- 241
	current = idx -- 243
	dirty = true -- 244
	play = nil -- 245
	clock:reset() -- 246
	if mode == 1 then -- 246
		if fe ~= nil then -- 246
			fe.screen = "play" -- 249
		end -- 249
		ensurePlay() -- 251
	end -- 251
end -- 251
function applySize() -- 255
	if root == nil then -- 255
		return -- 257
	end -- 257
	root.size = Size(viewW, viewH) -- 259
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 260
end -- 260
function tick(frameDt) -- 263
	local w = View.size.width -- 264
	local h = View.size.height -- 265
	if w ~= viewW or h ~= viewH then -- 265
		viewW = w -- 267
		viewH = h -- 268
		applySize() -- 269
		dirty = true -- 270
	end -- 270
	if input == nil then -- 270
		return -- 273
	end -- 273
	input:update() -- 275
	if input.toggleView.pressed then -- 275
		input.toggleView.pressed = false -- 279
		setMode(mode == 0 and 1 or 0) -- 280
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 280
			ensurePlay() -- 282
		end -- 282
	end -- 282
	if input.pickRoom ~= 0 then -- 282
		local idx = input.pickRoom - 1 -- 288
		input.pickRoom = 0 -- 289
		pickByIndex(idx) -- 290
	elseif input.tab.pressed then -- 290
		input.tab.pressed = false -- 292
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 292
			pickByIndex((current + 1) % #ROOMS) -- 294
		end -- 294
	end -- 294
	if mode == 1 then -- 294
		tickFrontend(frameDt) -- 299
		return -- 300
	end -- 300
	if dirty then -- 300
		redrawGraybox() -- 303
		dirty = false -- 304
	end -- 304
end -- 304
function ensurePlay(resume) -- 308
	play = __TS__New(Play, ROOMS[current + 1], resume) -- 309
	local reg = _G.package.loaded -- 310
	reg["watch.play"] = play -- 311
	reg["watch.room"] = ROOMS[current + 1].key -- 312
	clock:reset() -- 313
	if fe ~= nil then -- 313
		fe:bindPlay(play, viewW, viewH) -- 315
	end -- 315
end -- 315
function tickFrontend(frameDt) -- 319
	if fe == nil or input == nil then -- 319
		return -- 321
	end -- 321
	if fe.screen ~= "play" then -- 321
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 326
		input:consumeEdges() -- 327
		if act.type == "start" then -- 327
			enterPlayRoom(0) -- 329
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 329
			enterPlayRoom(act.roomIndex) -- 331
		elseif act.type == "openChapters" then -- 331
			fe.menus:openChapters() -- 333
			fe.screen = "chapters" -- 334
		elseif act.type == "openControls" then -- 334
			fe.menus:resetInput() -- 336
			fe.screen = "controls" -- 337
		elseif act.type == "backTitle" then -- 337
			fe.menus:resetInput() -- 339
			fe.screen = "title" -- 340
		elseif act.type == "backPause" then -- 340
			fe.menus:resetInput() -- 342
			fe.screen = "play" -- 343
		end -- 343
		return -- 345
	end -- 345
	if play == nil then -- 345
		ensurePlay() -- 350
	end -- 350
	if play == nil then -- 350
		return -- 353
	end -- 353
	local p = play -- 355
	if input.retry.pressed then -- 355
		input:consumeEdges() -- 358
		ensurePlay({checkpoint = p.checkpoint}) -- 359
		return -- 360
	end -- 360
	p.aimX = input.mx -- 363
	p.aimY = input.my -- 364
	if not p.paused and input.pause.pressed then -- 364
		p.paused = true -- 367
		p.aimHold = 0 -- 368
		p.bottleAimX = -1 -- 369
		fe.menus:openPause() -- 370
		input:consumeEdges() -- 371
	end -- 371
	if p.paused then -- 371
		clock:reset() -- 376
		local pauseAct = fe:renderPlay( -- 377
			frameDt, -- 377
			p, -- 377
			input, -- 377
			viewW, -- 377
			viewH -- 377
		) -- 377
		input:consumeEdges() -- 378
		if pauseAct.type == "resume" then -- 378
			p.paused = false -- 380
		elseif pauseAct.type == "retry" then -- 380
			ensurePlay({checkpoint = p.checkpoint}) -- 382
		elseif pauseAct.type == "openChapters" then -- 382
			fe.menus:openChapters(current) -- 384
			fe.screen = "chapters" -- 385
		elseif pauseAct.type == "toTitle" then -- 385
			fe.menus:resetInput() -- 387
			fe.screen = "title" -- 388
		end -- 388
		return -- 390
	end -- 390
	local steps = clock:advance(frameDt) -- 393
	local i = 0 -- 394
	do -- 394
		i = 0 -- 395
		while i < steps do -- 395
			input:beginStep(i == 0) -- 396
			p:update(STEP, input) -- 397
			input:endStep() -- 398
			if p.wantRoom ~= "" then -- 398
				break -- 400
			end -- 400
			i = i + 1 -- 395
		end -- 395
	end -- 395
	if p.wantRoom ~= "" then -- 395
		local key = p.wantRoom -- 406
		p.wantRoom = "" -- 407
		local idx = -1 -- 408
		local j = 0 -- 409
		do -- 409
			j = 0 -- 410
			while j < #ROOMS do -- 410
				if ROOMS[j + 1].key == key then -- 410
					idx = j -- 412
				end -- 412
				j = j + 1 -- 410
			end -- 410
		end -- 410
		if idx >= 0 then -- 410
			current = idx -- 416
			ensurePlay() -- 417
			dirty = true -- 418
		end -- 418
		return -- 420
	end -- 420
	fe:renderPlay( -- 423
		frameDt, -- 423
		p, -- 423
		input, -- 423
		viewW, -- 423
		viewH -- 423
	) -- 423
end -- 423
function redrawGraybox() -- 427
	if draw == nil then -- 427
		return -- 429
	end -- 429
	local w = viewW -- 431
	local h = viewH -- 432
	local room = ROOMS[current + 1] -- 433
	draw:clear() -- 435
	draw:drawRect( -- 436
		Rect(0, h - TOP_H, w, TOP_H), -- 436
		C_BG -- 436
	) -- 436
	draw:drawRect( -- 437
		Rect(0, 0, w, BOTTOM_H), -- 437
		C_BG -- 437
	) -- 437
	draw:drawSegment( -- 438
		Vec2(0, h - TOP_H), -- 438
		Vec2(w, h - TOP_H), -- 438
		1, -- 438
		Color(52, 54, 54, 255) -- 438
	) -- 438
	draw:drawSegment( -- 439
		Vec2(0, BOTTOM_H), -- 439
		Vec2(w, BOTTOM_H), -- 439
		1, -- 439
		Color(52, 54, 54, 255) -- 439
	) -- 439
	local v = computeView(room, w, h) -- 441
	renderWorld( -- 442
		draw, -- 442
		room, -- 442
		v, -- 442
		w, -- 442
		h -- 442
	) -- 442
	local roomTop = v.groundPx + room.height * v.scale -- 444
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 445
	place( -- 447
		titleLabel, -- 447
		48, -- 447
		h - 40, -- 447
		0, -- 447
		1 -- 447
	) -- 447
	place( -- 448
		roomLabel, -- 448
		48, -- 448
		h - 96, -- 448
		0, -- 448
		1 -- 448
	) -- 448
	place( -- 449
		captionLabel, -- 449
		48, -- 449
		h - 140, -- 449
		0, -- 449
		1 -- 449
	) -- 449
	place( -- 451
		switchLabel, -- 451
		48, -- 451
		40, -- 451
		0, -- 451
		0 -- 451
	) -- 451
	place( -- 452
		hintLabel, -- 452
		48, -- 452
		84, -- 452
		0, -- 452
		0 -- 452
	) -- 452
	place( -- 453
		rulerLabel, -- 453
		w - 216, -- 453
		roomTop + 36 + v.scale * 0.5 - 14, -- 453
		1, -- 453
		0 -- 453
	) -- 453
	place( -- 454
		standLabel, -- 454
		48, -- 454
		roomTop + 40, -- 454
		0, -- 454
		0 -- 454
	) -- 454
	place( -- 455
		cartLabel, -- 455
		48, -- 455
		roomTop + 92, -- 455
		0, -- 455
		0 -- 455
	) -- 455
	if roomLabel ~= nil then -- 455
		roomLabel.text = room.name -- 458
	end -- 458
	if captionLabel ~= nil then -- 458
		captionLabel.text = room.caption -- 461
	end -- 461
	if hintLabel ~= nil then -- 461
		local hintIdx = math.min(current, #HINTS - 1) -- 464
		local lines = HINTS[hintIdx + 1] -- 465
		local merged = lines[1] -- 466
		do -- 466
			local i = 1 -- 467
			while i < #lines do -- 467
				merged = (merged .. "    ") .. lines[i + 1] -- 468
				i = i + 1 -- 467
			end -- 467
		end -- 467
		hintLabel.text = merged -- 470
	end -- 470
	local specs = collectLabels(room, v, w) -- 473
	local body = {} -- 474
	local small = {} -- 475
	do -- 475
		local i = 0 -- 476
		while i < #specs do -- 476
			local s = specs[i + 1] -- 477
			if s.size >= 24 then -- 477
				body[#body + 1] = s -- 479
			else -- 479
				small[#small + 1] = s -- 481
			end -- 481
			i = i + 1 -- 476
		end -- 476
	end -- 476
	applyPool(body, poolBody) -- 484
	applyPool(small, poolSmall) -- 485
	if LAYOUT_AUDIT then -- 485
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 488
	end -- 488
end -- 488
function applyPool(specs, pool) -- 492
	do -- 492
		local i = 0 -- 493
		while i < #pool do -- 493
			local lb = pool[i + 1] -- 494
			if i < #specs then -- 494
				local s = specs[i + 1] -- 496
				lb.text = s.text -- 497
				lb.position = Vec2(s.x, s.y) -- 498
				lb.anchor = Vec2(s.ax, s.ay) -- 499
				lb.color = s.color -- 500
				lb.visible = true -- 501
			else -- 501
				lb.visible = false -- 503
			end -- 503
			i = i + 1 -- 493
		end -- 493
	end -- 493
end -- 493
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
			if sc == "chapters" then -- 177
				fe.menus:openChapters() -- 179
			else -- 179
				fe.menus:resetInput() -- 181
			end -- 181
			if sc == "play" then -- 181
				ensurePlay() -- 184
			end -- 184
		end, -- 172
		jumpRoom = function(keyOrIdx) -- 187
			local idx = -1 -- 188
			if type(keyOrIdx) == "number" then -- 188
				idx = keyOrIdx -- 190
			else -- 190
				local k = 0 -- 192
				do -- 192
					k = 0 -- 193
					while k < #ROOMS do -- 193
						if ROOMS[k + 1].key == keyOrIdx then -- 193
							idx = k -- 195
						end -- 195
						k = k + 1 -- 193
					end -- 193
				end -- 193
			end -- 193
			if idx >= 0 and idx < #ROOMS then -- 193
				enterPlayRoom(idx) -- 200
			end -- 200
		end, -- 187
		getPlay = function() return play end, -- 203
		getFrontend = function() return fe end -- 204
	} -- 204
	if mode == 1 and startScreen == "play" then -- 204
		ensurePlay() -- 208
	end -- 208
	parent:schedule(function(frameDt) -- 211
		tick(frameDt) -- 212
		return false -- 213
	end) -- 211
end -- 83
return ____exports -- 83