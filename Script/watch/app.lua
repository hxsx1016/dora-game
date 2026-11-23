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
function ensurePlay(resume) -- 301
	play = __TS__New(Play, ROOMS[current + 1], resume) -- 302
	local reg = _G.package.loaded -- 303
	reg["watch.play"] = play -- 304
	reg["watch.room"] = ROOMS[current + 1].key -- 305
	clock:reset() -- 306
	if fe ~= nil then -- 306
		fe:bindPlay(play, viewW, viewH) -- 308
	end -- 308
end -- 308
function tickFrontend(frameDt) -- 312
	if fe == nil or input == nil then -- 312
		return -- 314
	end -- 314
	if fe.screen ~= "play" then -- 314
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 319
		input:consumeEdges() -- 320
		if act.type == "start" then -- 320
			enterPlayRoom(0) -- 322
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 322
			enterPlayRoom(act.roomIndex) -- 324
		elseif act.type == "openChapters" then -- 324
			fe.screen = "chapters" -- 326
		elseif act.type == "openControls" then -- 326
			fe.screen = "controls" -- 328
		elseif act.type == "backTitle" then -- 328
			fe.screen = "title" -- 330
		end -- 330
		return -- 332
	end -- 332
	if play == nil then -- 332
		ensurePlay() -- 337
	end -- 337
	if play == nil then -- 337
		return -- 340
	end -- 340
	local p = play -- 342
	if input.retry.pressed then -- 342
		input:consumeEdges() -- 345
		ensurePlay({checkpoint = p.checkpoint}) -- 346
		return -- 347
	end -- 347
	p.aimX = input.mx -- 350
	p.aimY = input.my -- 351
	if p.paused then -- 351
		clock:reset() -- 354
		input:beginStep(true) -- 355
		p:update(STEP, input) -- 356
		input:endStep() -- 357
		local pauseAct = fe:renderPlay( -- 358
			frameDt, -- 358
			p, -- 358
			input, -- 358
			viewW, -- 358
			viewH -- 358
		) -- 358
		if pauseAct.type == "resume" then -- 358
			p.paused = false -- 360
		elseif pauseAct.type == "retry" then -- 360
			ensurePlay({checkpoint = p.checkpoint}) -- 362
		elseif pauseAct.type == "openChapters" then -- 362
			p.paused = false -- 364
			fe.screen = "chapters" -- 365
		elseif pauseAct.type == "toTitle" then -- 365
			p.paused = false -- 367
			fe.screen = "title" -- 368
		end -- 368
		return -- 370
	end -- 370
	local steps = clock:advance(frameDt) -- 373
	local i = 0 -- 374
	do -- 374
		i = 0 -- 375
		while i < steps do -- 375
			input:beginStep(i == 0) -- 376
			p:update(STEP, input) -- 377
			input:endStep() -- 378
			i = i + 1 -- 375
		end -- 375
	end -- 375
	if p.wantRoom ~= "" then -- 375
		local key = p.wantRoom -- 383
		p.wantRoom = "" -- 384
		local idx = -1 -- 385
		local j = 0 -- 386
		do -- 386
			j = 0 -- 387
			while j < #ROOMS do -- 387
				if ROOMS[j + 1].key == key then -- 387
					idx = j -- 389
				end -- 389
				j = j + 1 -- 387
			end -- 387
		end -- 387
		if idx >= 0 then -- 387
			current = idx -- 393
			ensurePlay() -- 394
			dirty = true -- 395
		end -- 395
		return -- 397
	end -- 397
	fe:renderPlay( -- 400
		frameDt, -- 400
		p, -- 400
		input, -- 400
		viewW, -- 400
		viewH -- 400
	) -- 400
end -- 400
function redrawGraybox() -- 404
	if draw == nil then -- 404
		return -- 406
	end -- 406
	local w = viewW -- 408
	local h = viewH -- 409
	local room = ROOMS[current + 1] -- 410
	draw:clear() -- 412
	draw:drawRect( -- 413
		Rect(0, h - TOP_H, w, TOP_H), -- 413
		C_BG -- 413
	) -- 413
	draw:drawRect( -- 414
		Rect(0, 0, w, BOTTOM_H), -- 414
		C_BG -- 414
	) -- 414
	draw:drawSegment( -- 415
		Vec2(0, h - TOP_H), -- 415
		Vec2(w, h - TOP_H), -- 415
		1, -- 415
		Color(52, 54, 54, 255) -- 415
	) -- 415
	draw:drawSegment( -- 416
		Vec2(0, BOTTOM_H), -- 416
		Vec2(w, BOTTOM_H), -- 416
		1, -- 416
		Color(52, 54, 54, 255) -- 416
	) -- 416
	local v = computeView(room, w, h) -- 418
	renderWorld( -- 419
		draw, -- 419
		room, -- 419
		v, -- 419
		w, -- 419
		h -- 419
	) -- 419
	local roomTop = v.groundPx + room.height * v.scale -- 421
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 422
	place( -- 424
		titleLabel, -- 424
		48, -- 424
		h - 40, -- 424
		0, -- 424
		1 -- 424
	) -- 424
	place( -- 425
		roomLabel, -- 425
		48, -- 425
		h - 96, -- 425
		0, -- 425
		1 -- 425
	) -- 425
	place( -- 426
		captionLabel, -- 426
		48, -- 426
		h - 140, -- 426
		0, -- 426
		1 -- 426
	) -- 426
	place( -- 428
		switchLabel, -- 428
		48, -- 428
		40, -- 428
		0, -- 428
		0 -- 428
	) -- 428
	place( -- 429
		hintLabel, -- 429
		48, -- 429
		84, -- 429
		0, -- 429
		0 -- 429
	) -- 429
	place( -- 430
		rulerLabel, -- 430
		w - 216, -- 430
		roomTop + 36 + v.scale * 0.5 - 14, -- 430
		1, -- 430
		0 -- 430
	) -- 430
	place( -- 431
		standLabel, -- 431
		48, -- 431
		roomTop + 40, -- 431
		0, -- 431
		0 -- 431
	) -- 431
	place( -- 432
		cartLabel, -- 432
		48, -- 432
		roomTop + 92, -- 432
		0, -- 432
		0 -- 432
	) -- 432
	if roomLabel ~= nil then -- 432
		roomLabel.text = room.name -- 435
	end -- 435
	if captionLabel ~= nil then -- 435
		captionLabel.text = room.caption -- 438
	end -- 438
	if hintLabel ~= nil then -- 438
		local hintIdx = math.min(current, #HINTS - 1) -- 441
		local lines = HINTS[hintIdx + 1] -- 442
		local merged = lines[1] -- 443
		do -- 443
			local i = 1 -- 444
			while i < #lines do -- 444
				merged = (merged .. "    ") .. lines[i + 1] -- 445
				i = i + 1 -- 444
			end -- 444
		end -- 444
		hintLabel.text = merged -- 447
	end -- 447
	local specs = collectLabels(room, v, w) -- 450
	local body = {} -- 451
	local small = {} -- 452
	do -- 452
		local i = 0 -- 453
		while i < #specs do -- 453
			local s = specs[i + 1] -- 454
			if s.size >= 24 then -- 454
				body[#body + 1] = s -- 456
			else -- 456
				small[#small + 1] = s -- 458
			end -- 458
			i = i + 1 -- 453
		end -- 453
	end -- 453
	applyPool(body, poolBody) -- 461
	applyPool(small, poolSmall) -- 462
	if LAYOUT_AUDIT then -- 462
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 465
	end -- 465
end -- 465
function applyPool(specs, pool) -- 469
	do -- 469
		local i = 0 -- 470
		while i < #pool do -- 470
			local lb = pool[i + 1] -- 471
			if i < #specs then -- 471
				local s = specs[i + 1] -- 473
				lb.text = s.text -- 474
				lb.position = Vec2(s.x, s.y) -- 475
				lb.anchor = Vec2(s.ax, s.ay) -- 476
				lb.color = s.color -- 477
				lb.visible = true -- 478
			else -- 478
				lb.visible = false -- 480
			end -- 480
			i = i + 1 -- 470
		end -- 470
	end -- 470
end -- 470
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