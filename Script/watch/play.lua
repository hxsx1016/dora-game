-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____rooms = require("Script.watch.rooms") -- 13
local withOrigin = ____rooms.withOrigin -- 13
local ____clock = require("Script.watch.clock") -- 15
local STEP = ____clock.STEP -- 15
local ____escort = require("Script.watch.escort") -- 16
local CALM_REACH = ____escort.CALM_REACH -- 16
local Escort = ____escort.Escort -- 16
local FEAR_MAX = ____escort.FEAR_MAX -- 16
local safeAnchorX = ____escort.safeAnchorX -- 16
function makeActor(room, index) -- 2660
	local sp = room.spawns -- 2661
	if index < 0 or index >= #sp then -- 2661
		return { -- 2663
			x = 0, -- 2663
			y = 0, -- 2663
			vx = 0, -- 2663
			vy = 0, -- 2663
			w = CHILD_W, -- 2663
			h = CHILD_H, -- 2663
			onGround = true, -- 2663
			facing = 1, -- 2663
			crouch = false, -- 2663
			rollT = 0, -- 2663
			covered = false, -- 2663
			alive = false -- 2663
		} -- 2663
	end -- 2663
	local s = sp[index + 1] -- 2665
	local child = s.h <= CHILD_H -- 2666
	return { -- 2667
		x = s.x, -- 2668
		y = s.y, -- 2668
		vx = 0, -- 2668
		vy = 0, -- 2668
		w = child and CHILD_W or SOLDIER_W, -- 2669
		h = child and CHILD_H or SOLDIER_H, -- 2670
		onGround = true, -- 2671
		facing = 1, -- 2671
		crouch = false, -- 2671
		rollT = 0, -- 2671
		covered = false, -- 2671
		alive = true -- 2671
	} -- 2671
end -- 2671
function drawFigure(draw, play, w, h, a, body, head) -- 2675
	if not a.alive then -- 2675
		return -- 2677
	end -- 2677
	local x0 = a.x - a.w / 2 -- 2679
	local x1 = a.x + a.w / 2 -- 2680
	local y0 = a.y -- 2681
	local y1 = a.y + a.h -- 2682
	play:drawBox( -- 2683
		draw, -- 2683
		w, -- 2683
		h, -- 2683
		x0, -- 2683
		x1, -- 2683
		y0, -- 2683
		y1 - a.h * 0.26, -- 2683
		body -- 2683
	) -- 2683
	play:drawBox( -- 2684
		draw, -- 2684
		w, -- 2684
		h, -- 2684
		x0 + 2, -- 2684
		x1 - 2, -- 2684
		y1 - a.h * 0.26, -- 2684
		y1, -- 2684
		head -- 2684
	) -- 2684
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2686
	play:drawBox( -- 2687
		draw, -- 2687
		w, -- 2687
		h, -- 2687
		eyeX, -- 2687
		eyeX + 4, -- 2687
		y1 - a.h * 0.14, -- 2687
		y1 - a.h * 0.08, -- 2687
		INK -- 2687
	) -- 2687
end -- 2687
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2691
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2692
end -- 2691
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2699
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2700
end -- 2699
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2707
	local tmin = 0 -- 2708
	local tmax = 99999 -- 2709
	if dx == 0 then -- 2709
		if ox < x0 or ox > x1 then -- 2709
			return -1 -- 2712
		end -- 2712
	else -- 2712
		local t1 = (x0 - ox) / dx -- 2715
		local t2 = (x1 - ox) / dx -- 2716
		local lo = t1 < t2 and t1 or t2 -- 2717
		local hi = t1 < t2 and t2 or t1 -- 2718
		if lo > tmin then -- 2718
			tmin = lo -- 2720
		end -- 2720
		if hi < tmax then -- 2720
			tmax = hi -- 2723
		end -- 2723
	end -- 2723
	if dy == 0 then -- 2723
		if oy < y0 or oy > y1 then -- 2723
			return -1 -- 2728
		end -- 2728
	else -- 2728
		local t1 = (y0 - oy) / dy -- 2731
		local t2 = (y1 - oy) / dy -- 2732
		local lo = t1 < t2 and t1 or t2 -- 2733
		local hi = t1 < t2 and t2 or t1 -- 2734
		if lo > tmin then -- 2734
			tmin = lo -- 2736
		end -- 2736
		if hi < tmax then -- 2736
			tmax = hi -- 2739
		end -- 2739
	end -- 2739
	return tmax >= tmin and tmin or -1 -- 2742
end -- 2742
function drawCartShape(draw, play, w, h, c, axleX) -- 2745
	local half = c.bodyW / 2 -- 2746
	local x0 = axleX - half -- 2747
	local x1 = axleX + half -- 2748
	play:drawBox( -- 2749
		draw, -- 2749
		w, -- 2749
		h, -- 2749
		x0, -- 2749
		x1, -- 2749
		c.baseY + c.wheelR, -- 2749
		c.baseY + c.wheelR + c.bodyH, -- 2749
		CART_FILL -- 2749
	) -- 2749
	draw:drawCircle( -- 2750
		Vec2( -- 2750
			play:sx(x0 + c.bodyW * 0.28, w), -- 2750
			play:sy(c.baseY + c.wheelR, h) -- 2750
		), -- 2750
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2750
		Color(52, 50, 48, 255) -- 2750
	) -- 2750
	draw:drawCircle( -- 2751
		Vec2( -- 2751
			play:sx(x1 - c.bodyW * 0.28, w), -- 2751
			play:sy(c.baseY + c.wheelR, h) -- 2751
		), -- 2751
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2751
		Color(52, 50, 48, 255) -- 2751
	) -- 2751
	local cx = c.clothSide < 0 and x0 or x1 -- 2752
	play:drawBox( -- 2753
		draw, -- 2753
		w, -- 2753
		h, -- 2753
		cx - 10, -- 2753
		cx + 10, -- 2753
		c.baseY + c.wheelR + c.bodyH, -- 2753
		c.baseY + c.wheelR + c.bodyH + 18, -- 2753
		CLOTH -- 2753
	) -- 2753
end -- 2753
____exports.STEP = STEP -- 19
____exports.GRAVITY = 1000 -- 20
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 22
CHILD_W = 28 -- 52
CHILD_H = 64 -- 53
local CHILD_CROUCH_H = 36 -- 54
local CHILD_SPEED = 160 -- 55
local CHILD_SLOW = 80 -- 56
local CHILD_JUMP = 320 -- 57
SOLDIER_W = 30 -- 60
SOLDIER_H = 88 -- 61
local SOLDIER_SPEED = 264 -- 62
local ROLL_TIME = 0.35 -- 63
local ROLL_SPEED = 280 -- 64
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 66
local LEDGE_RISE = 60 -- 67
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 70
____exports.LOGIC_H = 180 -- 71
____exports.UNITS_PER_PX = 2 -- 72
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 74
local CAM_FOLLOW = 9 -- 75
local CAM_LOOK_UP = 46 -- 76
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 79
--- 握把触发半径。
local CART_REACH = 70 -- 81
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 83
local CART_CLEAR = 44 -- 84
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 86
local FIRE_COOLDOWN = 150 -- 87
local ENEMY_RANGE = 760 -- 88
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 90
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 92
INK = Color(232, 232, 228, 255) -- 94
local INK_DIM = Color(150, 152, 150, 255) -- 95
local BG_VOID = Color(8, 9, 10, 255) -- 96
local BG_FAR = Color(24, 26, 28, 255) -- 97
local BG_MID = Color(31, 34, 37, 255) -- 98
local GROUND = Color(112, 114, 112, 255) -- 99
local FLOOR_DECK = Color(66, 70, 72, 255) -- 100
local SOLID_FILL = Color(84, 86, 84, 255) -- 101
local SOLID_EDGE = Color(126, 130, 126, 255) -- 102
CART_FILL = Color(122, 78, 56, 255) -- 103
CLOTH = Color(178, 52, 46, 255) -- 104
local DANGER = Color(150, 54, 48, 46) -- 105
local DANGER_LINE = Color(178, 78, 64, 200) -- 106
local HOLE_FILL = Color(10, 11, 12, 255) -- 107
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 108
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 109
local CHILD_BODY = Color(214, 168, 96, 255) -- 110
local CHILD_HEAD = Color(232, 214, 186, 255) -- 111
local ENEMY_BODY = Color(176, 92, 84, 255) -- 112
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 113
local CHECK = Color(96, 186, 122, 255) -- 114
local STAND = Color(226, 186, 84, 255) -- 115
local AIM = Color(236, 236, 232, 230) -- 116
local AIM_HIT = Color(236, 96, 84, 255) -- 117
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 119
local SOFT_LINE = Color(140, 112, 80, 190) -- 120
local BRICK = Color(126, 118, 110, 70) -- 121
local BRICK_LINE = Color(160, 152, 142, 200) -- 122
local PASS = Color(96, 186, 122, 40) -- 123
local PASS_LINE = Color(96, 186, 122, 200) -- 124
local BOTTLE = Color(120, 186, 160, 255) -- 125
local SCAV_BODY = Color(128, 118, 96, 255) -- 126
local SCAV_HEAD = Color(196, 182, 158, 255) -- 127
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 182
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 183
	if zoom < 1 then -- 183
		zoom = 1 -- 185
	end -- 185
	return { -- 187
		zoom = zoom, -- 188
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 189
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 190
	} -- 190
end -- 182
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 204
	if key == "prologue" then -- 204
		return "prologue-wait" -- 206
	end -- 206
	if key == "street" then -- 206
		return "street-run" -- 209
	end -- 209
	if key == "gate" then -- 209
		return "gate-idle" -- 212
	end -- 212
	if key == "forest" then -- 212
		return "forest-run" -- 215
	end -- 215
	if key == "tower" then -- 215
		return "tower-wait" -- 218
	end -- 218
	return "run" -- 220
end -- 204
____exports.Play = __TS__Class() -- 223
local Play = ____exports.Play -- 223
Play.name = "Play" -- 223
function Play.prototype.____constructor(self, room, resume) -- 360
	self.enemies = {} -- 228
	self.boxes = {} -- 229
	self.floors = {} -- 230
	self.checkpoint = -1 -- 232
	self.flash = "" -- 234
	self.flashT = 0 -- 235
	self.traceT = 0 -- 238
	self.focusCart = false -- 240
	self.knocks = 0 -- 242
	self.knockT = 0 -- 243
	self.cartAxle = 0 -- 247
	self.cartDocked = false -- 249
	self.gripping = false -- 251
	self.gateOpen = false -- 253
	self.calmConsumed = false -- 255
	self.nextDangerId = 1 -- 257
	self.wantRoom = "" -- 259
	self.carryCartAxle = -1 -- 261
	self.carryCartDocked = false -- 262
	self.checkpointCartAxle = -1 -- 264
	self.hasBottle = false -- 268
	self.bottleLandX = -1 -- 272
	self.bottleTargetX = -1 -- 273
	self.bottleTargetY = 0 -- 274
	self.bottleLandT = 0 -- 275
	self.aimHold = 0 -- 277
	self.scavX = 0 -- 279
	self.scavDir = 1 -- 280
	self.scavState = "patrol" -- 281
	self.scavT = 0 -- 282
	self.scavTargetX = 0 -- 283
	self.passed = false -- 285
	self.childMode = false -- 289
	self.phase = "" -- 291
	self.phaseTick = 0 -- 293
	self.gateTick = 0 -- 295
	self.countTick = 0 -- 297
	self.countArmed = false -- 299
	self.countPrevMove = 0 -- 301
	self.caughtT = 0 -- 303
	self.hp = 3 -- 305
	self.maxHp = 3 -- 306
	self.coveredFlash = 0 -- 308
	self.coverHug = false -- 310
	self.coverNear = false -- 312
	self.coverEntity = "" -- 314
	self.coverBlocking = false -- 316
	self.gateNeedConfirm = false -- 318
	self.gateRestartArmed = true -- 320
	self.bottleAimX = -1 -- 322
	self.bottleAimY = 0 -- 323
	self.bottleSurfaceY = -1 -- 325
	self.bottleLandY = 0 -- 327
	self.events = {} -- 329
	self.eventSeq = 0 -- 331
	self.dogX = 0 -- 333
	self.dogDir = 1 -- 334
	self.dogState = "patrol" -- 335
	self.dogT = 0 -- 336
	self.dogTargetX = 0 -- 337
	self.scavSee = 0 -- 339
	self.scavChase = false -- 340
	self.gateSpawned = 0 -- 342
	self.gateFailCount = 0 -- 344
	self.paused = false -- 346
	self.ticks = 0 -- 348
	self.view = {zoom = 1, ox = 0, oy = 0} -- 350
	self.ox = 0 -- 352
	self.aimX = 0 -- 354
	self.aimY = 0 -- 355
	self.viewW = 0 -- 357
	self.viewH = 0 -- 358
	self.ox = room.originX -- 362
	self.room = withOrigin(room) -- 363
	local wr = self.room -- 364
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 365
	self:buildWorld() -- 366
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 368
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 369
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 370
	self.player = makeActor(wr, playerIdx) -- 371
	self.partner = makeActor(wr, partnerIdx) -- 372
	self.phase = phaseOf(wr.key) -- 373
	if wr.story ~= nil then -- 373
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 375
	end -- 375
	self.cam.x = self.player.x -- 377
	self.cam.y = self.player.y + CAM_LOOK_UP -- 378
	self.cartAxle = wr.cart.startX -- 379
	self.escort = __TS__New( -- 380
		Escort, -- 380
		safeAnchorX(wr.marks) -- 380
	) -- 380
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 381
	self:buildEnemies() -- 382
	if resume ~= nil and resume.checkpoint > 0 then -- 382
		self.checkpoint = resume.checkpoint -- 385
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 385
			self.cartAxle = self.room.cart.endX -- 387
			self.cartDocked = true -- 388
			self.player.x = self.ox + 380 -- 391
			self.player.y = 0 -- 392
			self.player.vy = 0 -- 393
			self.player.onGround = true -- 394
			self.cam.x = self.player.x -- 395
			self.cam.y = self.player.y + CAM_LOOK_UP -- 396
		end -- 396
	end -- 396
end -- 360
function Play.prototype.buildWorld(self) -- 402
	local room = self.room -- 403
	self.boxes = {} -- 404
	self.floors = {} -- 405
	local i = 0 -- 406
	do -- 406
		i = 0 -- 407
		while i < #room.floors do -- 407
			local f = room.floors[i + 1] -- 408
			local ____self_floors_0 = self.floors -- 408
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 409
			i = i + 1 -- 407
		end -- 407
	end -- 407
	do -- 407
		i = 0 -- 411
		while i < #room.solids do -- 411
			local s = room.solids[i + 1] -- 412
			local ____self_boxes_1 = self.boxes -- 412
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 413
				x0 = s.x, -- 413
				x1 = s.x + s.w, -- 413
				y0 = s.y, -- 413
				y1 = s.y + s.h, -- 413
				passable = s.passable == true, -- 413
				label = s.label -- 413
			} -- 413
			i = i + 1 -- 411
		end -- 411
	end -- 411
	do -- 411
		i = 0 -- 415
		while i < #room.stairs do -- 415
			local st = room.stairs[i + 1] -- 416
			local n = st.steps + 1 -- 417
			local stepW = (st.x1 - st.x0) / n -- 418
			local k = 0 -- 419
			do -- 419
				k = 0 -- 420
				while k < n do -- 420
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 421
					local x0 = st.x0 + stepW * k -- 422
					local ____self_boxes_2 = self.boxes -- 422
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 424
						x0 = x0, -- 424
						x1 = x0 + stepW, -- 424
						y0 = -8, -- 424
						y1 = y, -- 424
						passable = true -- 424
					} -- 424
					k = k + 1 -- 420
				end -- 420
			end -- 420
			i = i + 1 -- 415
		end -- 415
	end -- 415
end -- 402
function Play.prototype.buildEnemies(self) -- 429
	self.enemies = {} -- 430
	if self.room.key == "checkpoint" then -- 430
		local ____self_enemies_3 = self.enemies -- 430
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 432
			x = self.ox + 430, -- 432
			y = 0, -- 432
			w = 26, -- 432
			h = 84, -- 432
			alive = true, -- 432
			hitT = 0, -- 432
			warnT = 0, -- 432
			fireCd = 0 -- 432
		} -- 432
		local ____self_enemies_4 = self.enemies -- 432
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 433
			x = self.ox + 505, -- 433
			y = 0, -- 433
			w = 26, -- 433
			h = 84, -- 433
			alive = true, -- 433
			hitT = 0, -- 433
			warnT = 0, -- 433
			fireCd = 0 -- 433
		} -- 433
		return -- 434
	end -- 434
	if self.room.key == "street" then -- 434
		local ____self_enemies_5 = self.enemies -- 434
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 438
			x = self.ox + 340, -- 438
			y = 0, -- 438
			w = 26, -- 438
			h = 84, -- 438
			alive = true, -- 438
			hitT = 0, -- 438
			warnT = 0, -- 438
			fireCd = 0 -- 438
		} -- 438
		local ____self_enemies_6 = self.enemies -- 438
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 439
			x = self.ox + 560, -- 439
			y = 0, -- 439
			w = 26, -- 439
			h = 84, -- 439
			alive = true, -- 439
			hitT = 0, -- 439
			warnT = 0, -- 439
			fireCd = 0 -- 439
		} -- 439
	end -- 439
end -- 429
function Play.prototype.emit(self, name, data) -- 445
	local ____self_events_7 = self.events -- 445
	____self_events_7[#____self_events_7 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 446
	self.eventSeq = self.eventSeq + 1 -- 447
	if #self.events > 256 then -- 447
		table.remove(self.events, 1) -- 449
	end -- 449
end -- 445
function Play.prototype.drainEvents(self) -- 457
	local out = self.events -- 458
	self.events = {} -- 459
	return out -- 460
end -- 457
function Play.prototype.adoptEvents(self, events) -- 467
	if #events == 0 then -- 467
		return -- 469
	end -- 469
	self.events = __TS__ArrayConcat(events, self.events) -- 471
	local i = 0 -- 472
	do -- 472
		i = 0 -- 473
		while i < #self.events do -- 473
			self.events[i + 1].seq = i -- 474
			i = i + 1 -- 473
		end -- 473
	end -- 473
	self.eventSeq = #self.events -- 476
end -- 467
function Play.prototype.update(self, dt, input) -- 480
	if input.pause.pressed then -- 480
		self.paused = not self.paused -- 482
	end -- 482
	if self.flashT > 0 then -- 482
		self.flashT = self.flashT - dt -- 485
		if self.flashT <= 0 then -- 485
			self.flash = "" -- 487
		end -- 487
	end -- 487
	if self.traceT > 0 then -- 487
		self.traceT = self.traceT - dt -- 491
		if self.traceT <= 0 then -- 491
			self.trace = nil -- 493
		end -- 493
	end -- 493
	if self.paused then -- 493
		self:updateCamera(dt) -- 497
		return -- 498
	end -- 498
	self.ticks = self.ticks + 1 -- 501
	local p = self.player -- 502
	self:stepPlayer(p, dt, input) -- 503
	self:refreshCover(p, input) -- 505
	self:stepEnemies(dt, input) -- 507
	self:stepStory(dt, input) -- 508
	self:stepEscort(dt, input) -- 509
	self:stepVillage(dt, input) -- 510
	self:stepChase(dt, input) -- 511
	self:stepInteract(dt, input) -- 512
	self:updateGate() -- 513
	self:updateCamera(dt) -- 514
end -- 480
function Play.prototype.coverAt(self, a) -- 521
	local best = nil -- 522
	local bestGap = 24 -- 523
	local half = a.w / 2 -- 524
	local i = 0 -- 525
	do -- 525
		i = 0 -- 526
		while i < #self.boxes do -- 526
			do -- 526
				local b = self.boxes[i + 1] -- 527
				if b.passable == true or b.y1 - b.y0 < 44 then -- 527
					goto __continue42 -- 529
				end -- 529
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 529
					goto __continue42 -- 532
				end -- 532
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 534
				if gap < bestGap then -- 534
					bestGap = gap -- 536
					best = b -- 537
				end -- 537
			end -- 537
			::__continue42:: -- 537
			i = i + 1 -- 526
		end -- 526
	end -- 526
	return best -- 540
end -- 521
function Play.prototype.nearCover(self, a) -- 543
	return self:coverAt(a) ~= nil -- 544
end -- 543
function Play.prototype.coverGuardsFrom(self, b, a, enemyX) -- 548
	if enemyX < 0 then -- 548
		return false -- 550
	end -- 550
	if enemyX >= a.x then -- 550
		return b.x0 >= a.x - 0.001 and b.x0 <= enemyX -- 553
	end -- 553
	return b.x1 <= a.x + 0.001 and b.x1 >= enemyX -- 555
end -- 548
function Play.prototype.nearestEnemyX(self, a) -- 559
	local best = -1 -- 560
	local bestD = 1000000000 -- 561
	local i = 0 -- 562
	do -- 562
		i = 0 -- 563
		while i < #self.enemies do -- 563
			do -- 563
				local e = self.enemies[i + 1] -- 564
				if not e.alive then -- 564
					goto __continue52 -- 566
				end -- 566
				local d = math.abs(e.x - a.x) -- 568
				if d < bestD then -- 568
					bestD = d -- 570
					best = e.x -- 571
				end -- 571
			end -- 571
			::__continue52:: -- 571
			i = i + 1 -- 563
		end -- 563
	end -- 563
	return best -- 574
end -- 559
function Play.prototype.refreshCover(self, a, input) -- 578
	if self.childMode then -- 578
		self.coverNear = false -- 580
		self.coverHug = false -- 581
		self.coverEntity = "" -- 582
		self.coverBlocking = false -- 583
		a.covered = false -- 584
		return -- 585
	end -- 585
	local b = self:coverAt(a) -- 587
	self.coverNear = b ~= nil -- 588
	a.covered = self.coverNear and input.cover.held -- 589
	self.coverHug = a.covered -- 590
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 591
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 592
		b, -- 592
		a, -- 592
		self:nearestEnemyX(a) -- 592
	) -- 592
end -- 578
function Play.prototype.nearLowLedge(self, a) -- 596
	local reach = 26 -- 597
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 598
	local x1 = x0 + reach -- 599
	local i = 0 -- 600
	do -- 600
		i = 0 -- 601
		while i < #self.boxes do -- 601
			do -- 601
				local b = self.boxes[i + 1] -- 602
				if b.x1 <= x0 or b.x0 >= x1 then -- 602
					goto __continue59 -- 604
				end -- 604
				local rise = b.y1 - a.y -- 606
				if rise > 0 and rise <= LEDGE_RISE then -- 606
					return true -- 608
				end -- 608
			end -- 608
			::__continue59:: -- 608
			i = i + 1 -- 601
		end -- 601
	end -- 601
	return false -- 611
end -- 596
function Play.prototype.stepPlayer(self, a, dt, input) -- 614
	if not a.alive then -- 614
		return -- 616
	end -- 616
	local isChild = self.childMode -- 618
	if self:storyLocked() then -- 618
		a.vx = 0 -- 621
		a.crouch = false -- 622
		a.h = isChild and CHILD_H or SOLDIER_H -- 623
		self:fallY(a, dt) -- 624
		return -- 625
	end -- 625
	if not isChild and self.escort.state == "calming" then -- 625
		a.crouch = false -- 629
		a.h = SOLDIER_H -- 630
		a.vx = 0 -- 631
		self:fallY(a, dt) -- 632
		return -- 633
	end -- 633
	a.crouch = isChild and input.crouch.held and a.onGround -- 635
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 636
	local nearCover = not isChild and self:nearCover(a) -- 637
	a.covered = nearCover and input.cover.held -- 638
	if a.rollT > 0 then -- 638
		a.rollT = a.rollT - dt -- 642
		a.vx = a.facing * ROLL_SPEED -- 643
		self:slideX(a, a.vx * dt) -- 644
		self:fallY(a, dt) -- 645
		if a.rollT <= 0 then -- 645
			self:flashSet("翻滚结束", 0.5) -- 647
		end -- 647
		return -- 649
	end -- 649
	if not isChild and input.jump.pressed and a.onGround then -- 649
		if input.moveX ~= 0 then -- 649
			a.facing = input.moveX > 0 and 1 or -1 -- 654
		end -- 654
		if self:nearLowLedge(a) then -- 654
			a.vy = SOLDIER_JUMP -- 658
			a.onGround = false -- 659
			self:flashSet("翻上去", 0.3) -- 660
			return -- 661
		end -- 661
		a.rollT = ROLL_TIME -- 663
		self:flashSet("翻滚", 0.3) -- 664
		return -- 665
	end -- 665
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 668
	if isChild then -- 668
		if input.cover.held then -- 668
			speed = CHILD_SLOW -- 671
		end -- 671
		if a.crouch then -- 671
			speed = CHILD_SLOW -- 674
		end -- 674
	elseif a.covered then -- 674
		speed = SOLDIER_SPEED * 0.45 -- 677
	end -- 677
	local dir = self.gripping and 0 or input.moveX -- 681
	if dir ~= 0 then -- 681
		a.facing = dir > 0 and 1 or -1 -- 683
	end -- 683
	a.vx = dir * speed -- 685
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 685
		a.vy = CHILD_JUMP -- 689
		a.onGround = false -- 690
		self:flashSet("跳", 0.25) -- 691
	end -- 691
	self:slideX(a, a.vx * dt) -- 694
	self:fallY(a, dt) -- 695
	if not isChild and input.fire.pressed then -- 695
		self:shoot(a) -- 699
	end -- 699
end -- 614
function Play.prototype.stepPartner(self, p, dt) -- 704
	local a = self.partner -- 705
	if not a.alive then -- 705
		return -- 707
	end -- 707
	a.crouch = false -- 709
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 710
	a.vx = 0 -- 711
	self:fallY(a, dt) -- 712
end -- 704
function Play.prototype.stepEscort(self, dt, input) -- 719
	local a = self.partner -- 720
	if not a.alive then -- 720
		return -- 722
	end -- 722
	if not self:escortOn() then -- 722
		a.vx = 0 -- 725
		self:fallY(a, dt) -- 726
		return -- 727
	end -- 727
	local p = self.player -- 729
	local dist = math.abs(p.x - a.x) -- 730
	local hadKnock1 = self.escort.knock1 -- 731
	local hadKnock2 = self.escort.knock2 -- 732
	self.calmConsumed = self.escort:update( -- 733
		input, -- 733
		p.x, -- 733
		p.facing, -- 733
		a.x, -- 733
		dist -- 733
	) -- 733
	if not hadKnock1 and self.escort.knock1 then -- 733
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 736
	end -- 736
	if not hadKnock2 and self.escort.knock2 then -- 736
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 739
	end -- 739
	a.crouch = self.escort.crouchPose -- 741
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 742
	local dir = self.escort:moveDir(a.x) -- 743
	a.vx = dir * CHILD_SPEED -- 744
	if dir ~= 0 then -- 744
		a.facing = dir -- 746
		local before = a.x -- 747
		self:slideX(a, dir * CHILD_SPEED * dt) -- 748
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 748
			a.vy = CHILD_JUMP -- 751
			a.onGround = false -- 752
		end -- 752
	end -- 752
	self:fallY(a, dt) -- 755
end -- 719
function Play.prototype.escortOn(self) -- 759
	if self.room.key == "checkpoint" then -- 759
		return true -- 761
	end -- 761
	if self.room.key == "prologue" then -- 761
		return self.phase == "prologue-follow" -- 764
	end -- 764
	return self.room.key == "street" -- 766
end -- 759
function Play.prototype.storyLocked(self) -- 770
	if self.caughtT > 0 then -- 770
		return true -- 772
	end -- 772
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 772
		return true -- 775
	end -- 775
	if self.room.key == "gate" and self.phase == "gate-count" then -- 775
		return true -- 778
	end -- 778
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 778
		return true -- 781
	end -- 781
	return false -- 783
end -- 770
function Play.prototype.swapToChild(self, x) -- 787
	local tmp = self.player -- 788
	self.player = self.partner -- 789
	self.partner = tmp -- 790
	self.childMode = true -- 791
	self.player.alive = true -- 792
	self.player.x = self.ox + x -- 793
	self.player.y = 0 -- 794
	self.player.vy = 0 -- 795
	self.player.vx = 0 -- 796
	self.player.onGround = true -- 797
	self.player.crouch = false -- 798
	self.player.h = CHILD_H -- 799
	self.player.facing = 1 -- 800
	self.partner.alive = true -- 801
	self.cam.x = self.player.x -- 802
end -- 787
function Play.prototype.stepStory(self, dt, input) -- 806
	if self.room.key == "prologue" then -- 806
		self:stepPrologue(dt, input) -- 808
	elseif self.room.key == "street" then -- 808
		self:stepStreet(dt, input) -- 810
	elseif self.room.key == "gate" then -- 810
		self:stepGate(dt, input) -- 812
	elseif self.room.key == "tower" then -- 812
		self:stepTower(dt, input) -- 814
	end -- 814
end -- 806
function Play.prototype.stepPrologue(self, dt, input) -- 819
	local child = self.partner -- 820
	if self.phase == "prologue-wait" then -- 820
		child.crouch = true -- 822
		child.h = CHILD_CROUCH_H -- 823
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 824
		local near = math.abs(self.player.x - child.x) <= reach -- 826
		if near and input.interact.pressed then -- 826
			self.phase = "prologue-give" -- 828
			self.phaseTick = 0 -- 829
			self:flashSet("递出针套", 1) -- 830
		end -- 830
		return -- 832
	end -- 832
	if self.phase == "prologue-give" then -- 832
		self.phaseTick = self.phaseTick + 1 -- 835
		if self.phaseTick == 12 then -- 835
			self:flashSet("针套递过去", 0.7) -- 837
		elseif self.phaseTick == 36 then -- 837
			self:flashSet("纸条塞进针套", 0.9) -- 839
		elseif self.phaseTick >= 60 then -- 839
			self.phase = "prologue-follow" -- 841
			self.phaseTick = 0 -- 842
			child.crouch = false -- 843
			child.h = CHILD_H -- 844
			self:flashSet("她跟上了", 1.2) -- 845
		end -- 845
		return -- 847
	end -- 847
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 847
		self:requestRoom("street", "序章跟到门口") -- 851
		self:flashSet("进街道", 1.2) -- 852
	end -- 852
end -- 819
function Play.prototype.stepStreet(self, dt, input) -- 857
	local p = self.player -- 858
	local c = self.partner -- 859
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 859
		self:requestRoom("checkpoint", "两人都到街尾") -- 861
		self:flashSet("到检查站", 1.2) -- 862
	end -- 862
end -- 857
function Play.prototype.stepGate(self, dt, input) -- 867
	local ____temp_8 -- 868
	if self.room.story == nil then -- 868
		____temp_8 = nil -- 868
	else -- 868
		____temp_8 = self.room.story.gate -- 868
	end -- 868
	local g = ____temp_8 -- 868
	if g == nil then -- 868
		return -- 870
	end -- 870
	local p = self.player -- 872
	if self.phase == "gate-idle" then -- 872
		local a = self.partner -- 875
		local gap = g.waitX - a.x -- 876
		if math.abs(gap) > 3 then -- 876
			a.facing = gap > 0 and 1 or -1 -- 878
			a.vx = a.facing * CHILD_SPEED -- 879
			local beforeX = a.x -- 880
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 881
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 881
				a.vy = CHILD_JUMP -- 883
				a.onGround = false -- 884
			end -- 884
			self:fallY(a, dt) -- 886
		else -- 886
			a.vx = 0 -- 888
			a.x = g.waitX -- 889
		end -- 889
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 892
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 893
		if self.gateNeedConfirm then -- 893
			if not input.interact.held then -- 893
				self.gateRestartArmed = true -- 898
			end -- 898
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 898
				self.gateNeedConfirm = false -- 901
				self.gateRestartArmed = true -- 902
				self.phase = "gate-hold" -- 903
				self.gateTick = 0 -- 904
				self.gateSpawned = 0 -- 905
				self:flashSet("重新就位 · 守点开始", 1.4) -- 906
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 907
			end -- 907
			return -- 909
		end -- 909
		if atWinch and atWait then -- 909
			self.phase = "gate-hold" -- 912
			self.gateTick = 0 -- 913
			self.gateSpawned = 0 -- 914
			self:flashSet("两人就位 · 守点开始", 1.4) -- 915
		end -- 915
		return -- 917
	end -- 917
	if self.phase == "gate-hold" then -- 917
		self.gateTick = self.gateTick + 1 -- 920
		local marks = {0, 540, 900, 1500} -- 922
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 922
			local idx = self.gateSpawned -- 924
			local ____self_enemies_9 = self.enemies -- 924
			____self_enemies_9[#____self_enemies_9 + 1] = { -- 925
				x = self.ox + 620 + idx * 62, -- 926
				y = 0, -- 926
				w = 26, -- 926
				h = 84, -- 926
				alive = true, -- 927
				hitT = 0, -- 927
				warnT = 0, -- 927
				fireCd = 90 + idx * 45 -- 927
			} -- 927
			self.gateSpawned = self.gateSpawned + 1 -- 929
			self:flashSet( -- 930
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 930
				0.9 -- 930
			) -- 930
		end -- 930
		if self.gateTick == 900 then -- 930
			self:flashSet("灯灭了", 1) -- 933
		elseif self.gateTick == 2100 then -- 933
			self:flashSet("门底压下来了", 1) -- 935
		end -- 935
		if self.gateTick >= g.holdTicks then -- 935
			self.phase = "gate-send" -- 938
			self.phaseTick = 0 -- 939
			self.enemies = {} -- 941
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 942
		end -- 942
		return -- 944
	end -- 944
	if self.phase == "gate-send" then -- 944
		local near = math.abs(p.x - g.doorX) <= 60 -- 947
		if near and input.interact.pressed then -- 947
			self:swapToChild(g.doorX + 30) -- 949
			self.phase = "gate-count" -- 950
			self.countTick = 0 -- 951
			self.countArmed = false -- 953
			self.countPrevMove = input.moveX -- 954
			self:flashSet("门开了 · 送她出去", 1.8) -- 955
		end -- 955
		return -- 957
	end -- 957
	if self.phase == "gate-count" then -- 957
		self.countTick = self.countTick + 1 -- 960
		if self.countTick == 360 then -- 960
			self:flashSet("门关上", 0.9) -- 962
		elseif self.countTick == 1020 then -- 962
			self:flashSet("数到一百", 2.2) -- 964
		end -- 964
		local prevMove = self.countPrevMove -- 968
		self.countPrevMove = input.moveX -- 969
		if self.countTick >= 1440 then -- 969
			if prevMove <= 0 and input.moveX > 0 then -- 969
				self.countArmed = true -- 972
			end -- 972
			if self.countArmed and input.moveX > 0 then -- 972
				self.phase = "gate-walk" -- 975
				self.phaseTick = 0 -- 976
				self:flashSet("她迈出第一步", 1.4) -- 977
			end -- 977
		end -- 977
		return -- 980
	end -- 980
	if self.player.x >= g.exitX then -- 980
		self:requestRoom("outside", "走出城门") -- 984
		self:flashSet("出城门 · 城外", 1.4) -- 985
	end -- 985
end -- 867
function Play.prototype.stepTower(self, dt, input) -- 990
	local ____temp_10 -- 991
	if self.room.story == nil then -- 991
		____temp_10 = nil -- 991
	else -- 991
		____temp_10 = self.room.story.tower -- 991
	end -- 991
	local t = ____temp_10 -- 991
	if t == nil then -- 991
		return -- 993
	end -- 993
	if self.phase == "tower-wait" then -- 993
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 996
		if near and input.interact.pressed then -- 996
			self.phase = "tower-knock" -- 998
			self.phaseTick = 0 -- 999
			self.knocks = 1 -- 1000
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1001
			self:flashSet("敲一下", 0.6) -- 1002
		end -- 1002
		return -- 1004
	end -- 1004
	if self.phase == "tower-knock" then -- 1004
		self.phaseTick = self.phaseTick + 1 -- 1007
		if self.phaseTick == 12 then -- 1007
			self.knocks = 2 -- 1009
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1010
			self:flashSet("敲两下 · 第二声", 1) -- 1011
		elseif self.phaseTick >= t.knockTicks then -- 1011
			self.phase = "tower-given" -- 1013
			self.phaseTick = 0 -- 1014
			self:flashSet("门开了 · 提灯", 1.4) -- 1015
		end -- 1015
		return -- 1017
	end -- 1017
	if self.phase == "tower-given" then -- 1017
		self.phaseTick = self.phaseTick + 1 -- 1020
		if self.phaseTick == 60 then -- 1020
			self:flashSet("她递出针套和纸条", 1.6) -- 1022
		elseif self.phaseTick == 120 then -- 1022
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1024
		elseif self.phaseTick >= 180 then -- 1024
			self.phase = "tower-end" -- 1026
			self.phaseTick = 0 -- 1027
			self:flashSet("片尾 · E 再玩一次", 3) -- 1028
		end -- 1028
		return -- 1030
	end -- 1030
	if input.interact.pressed or input.retry.pressed then -- 1030
		self:requestRoom("prologue", "片尾再玩") -- 1033
		self:flashSet("回到序章", 1.4) -- 1034
	end -- 1034
end -- 990
function Play.prototype.stepChase(self, dt, input) -- 1039
	if self.caughtT > 0 then -- 1039
		self.caughtT = self.caughtT - dt -- 1041
		if self.caughtT <= 0 then -- 1041
			self:recoverFromCaught() -- 1043
		end -- 1043
		return -- 1045
	end -- 1045
	if self.room.key == "village" then -- 1045
		self:stepScavChase() -- 1048
	elseif self.room.key == "forest" then -- 1048
		self:stepDog(dt) -- 1050
		if self.player.x >= self.ox + 1450 then -- 1050
			self:requestRoom("tower", "到林缘北塔") -- 1053
			self:flashSet("林缘 · 北塔", 1.4) -- 1054
		end -- 1054
	end -- 1054
end -- 1039
function Play.prototype.stepScavChase(self) -- 1060
	local s = self.room.scavenger -- 1061
	if s == nil then -- 1061
		return -- 1063
	end -- 1063
	local p = self.player -- 1065
	if self.passed and p.x > self.ox + 440 then -- 1065
		if self.scavChase then -- 1065
			self.scavChase = false -- 1069
			self.scavState = "back" -- 1070
			self.scavT = 0 -- 1071
		end -- 1071
		return -- 1073
	end -- 1073
	local dx = p.x - self.scavX -- 1075
	local dist = math.abs(dx) -- 1076
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1077
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1078
	if not self.scavChase then -- 1078
		if visible then -- 1078
			self.scavSee = self.scavSee + 1 -- 1081
			if self.scavSee >= 24 then -- 1081
				self.scavChase = true -- 1083
				self.scavState = "chase" -- 1084
				self.scavTargetX = p.x -- 1085
				self:flashSet("他看见你了", 1.2) -- 1086
			end -- 1086
		else -- 1086
			self.scavSee = 0 -- 1089
		end -- 1089
		return -- 1091
	end -- 1091
	local dir = p.x > self.scavX and 1 or -1 -- 1094
	self.scavX = self.scavX + dir * 96 / 60 -- 1095
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1095
		self:caught() -- 1097
		return -- 1098
	end -- 1098
	if hidden then -- 1098
		self.scavSee = 0 -- 1102
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1103
		self.scavT = self.scavT - 1 -- 1104
		if self.scavT <= 0 then -- 1104
			self.scavChase = false -- 1106
			self.scavState = "patrol" -- 1107
			self:flashSet("他失去了目标", 1) -- 1108
		end -- 1108
	end -- 1108
end -- 1060
function Play.prototype.stepDog(self, dt) -- 1114
	local ____temp_11 -- 1115
	if self.room.story == nil then -- 1115
		____temp_11 = nil -- 1115
	else -- 1115
		____temp_11 = self.room.story.dog -- 1115
	end -- 1115
	local dog = ____temp_11 -- 1115
	if dog == nil then -- 1115
		return -- 1117
	end -- 1117
	local p = self.player -- 1119
	local dist = math.abs(p.x - self.dogX) -- 1120
	if self.dogState == "patrol" then -- 1120
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1122
		if self.dogX < dog.x0 then -- 1122
			self.dogX = dog.x0 -- 1124
			self.dogDir = 1 -- 1125
		elseif self.dogX > dog.x1 then -- 1125
			self.dogX = dog.x1 -- 1127
			self.dogDir = -1 -- 1128
		end -- 1128
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1130
		if not p.crouch and moving and dist < dog.range then -- 1130
			self.dogState = "ear" -- 1132
			self.dogT = 18 -- 1133
			self.dogTargetX = p.x -- 1134
			self:flashSet("狗转耳朵", 0.8) -- 1135
		end -- 1135
		return -- 1137
	end -- 1137
	if self.dogState == "ear" then -- 1137
		self.dogT = self.dogT - 1 -- 1140
		if self.dogT <= 0 then -- 1140
			self.dogState = "chase" -- 1142
			self.dogTargetX = p.x -- 1143
			self:flashSet("狗追来了", 1.4) -- 1144
		end -- 1144
		return -- 1146
	end -- 1146
	if self.dogState == "chase" then -- 1146
		local dir = p.x > self.dogX and 1 or -1 -- 1149
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1150
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1150
			self:caught() -- 1152
			self.dogState = "sniff" -- 1153
			self.dogT = 60 -- 1154
		elseif dist > dog.range * 1.5 or p.crouch then -- 1154
			self.dogState = "sniff" -- 1156
			self.dogT = 60 -- 1157
			self:flashSet("狗停下了", 0.9) -- 1158
		end -- 1158
		return -- 1160
	end -- 1160
	if self.dogState == "sniff" then -- 1160
		self.dogT = self.dogT - 1 -- 1163
		if self.dogT <= 0 then -- 1163
			self.dogState = "back" -- 1165
		end -- 1165
		return -- 1167
	end -- 1167
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1170
	self.dogX = self.dogX + dir * dog.speed * dt -- 1171
	if math.abs(self.dogX - dog.x0) < 2 then -- 1171
		self.dogX = dog.x0 -- 1173
		self.dogState = "patrol" -- 1174
	end -- 1174
end -- 1114
function Play.prototype.caught(self) -- 1178
	self.caughtT = 1 -- 1179
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1180
end -- 1178
function Play.prototype.recoverFromCaught(self) -- 1184
	local p = self.player -- 1185
	p.x = self.ox + 140 -- 1186
	p.y = 0 -- 1187
	p.vy = 0 -- 1188
	p.vx = 0 -- 1189
	p.onGround = true -- 1190
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1190
		self.scavX = self.room.scavenger.x0 -- 1192
		self.scavState = "patrol" -- 1193
		self.scavSee = 0 -- 1194
		self.scavChase = false -- 1195
		self.scavT = 0 -- 1196
	end -- 1196
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1196
		self.dogX = self.room.story.dog.x0 -- 1199
		self.dogState = "patrol" -- 1200
		self.dogT = 0 -- 1201
	end -- 1201
	self.cam.x = p.x -- 1203
	self.cam.y = p.y + CAM_LOOK_UP -- 1204
	self:flashSet("回到安全点", 1.2) -- 1205
end -- 1184
function Play.prototype.updateGate(self) -- 1209
	if self.room.key ~= "checkpoint" then -- 1209
		self.gateOpen = false -- 1211
		return -- 1212
	end -- 1212
	local function inZone(x) -- 1214
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1214
	end -- 1214
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1215
end -- 1209
function Play.prototype.stepEnemies(self, dt, input) -- 1218
	local i = 0 -- 1219
	do -- 1219
		i = 0 -- 1220
		while i < #self.enemies do -- 1220
			local e = self.enemies[i + 1] -- 1221
			if e.hitT > 0 then -- 1221
				e.hitT = e.hitT - dt -- 1223
			end -- 1223
			i = i + 1 -- 1220
		end -- 1220
	end -- 1220
	if self.coveredFlash > 0 then -- 1220
		self.coveredFlash = self.coveredFlash - dt -- 1227
	end -- 1227
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1227
		return -- 1231
	end -- 1231
	do -- 1231
		i = 0 -- 1233
		while i < #self.enemies do -- 1233
			do -- 1233
				local e = self.enemies[i + 1] -- 1234
				if not e.alive then -- 1234
					goto __continue192 -- 1236
				end -- 1236
				if e.warnT > 0 then -- 1236
					e.warnT = e.warnT - 1 -- 1239
					if e.warnT <= 0 then -- 1239
						self:enemyFire(e, input) -- 1241
					end -- 1241
					goto __continue192 -- 1243
				end -- 1243
				if e.fireCd > 0 then -- 1243
					e.fireCd = e.fireCd - 1 -- 1246
					if e.fireCd <= 0 then -- 1246
						e.warnT = WARN_TICKS -- 1248
					end -- 1248
				else -- 1248
					e.warnT = WARN_TICKS -- 1252
				end -- 1252
			end -- 1252
			::__continue192:: -- 1252
			i = i + 1 -- 1233
		end -- 1233
	end -- 1233
end -- 1218
function Play.prototype.enemyFire(self, e, input) -- 1258
	local p = self.player -- 1259
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1259
		self:flashSet("枪声响在远处", 0.4) -- 1261
		e.fireCd = FIRE_COOLDOWN -- 1262
		return -- 1263
	end -- 1263
	local cover = self:blockedByCover(e.x, p) -- 1266
	local hugging = cover ~= nil -- 1267
	self.coverBlocking = hugging -- 1268
	local covered = hugging and input.cover.held -- 1269
	if covered then -- 1269
		self.coveredFlash = 0.5 -- 1271
		self:flashSet("掩体挡下", 0.5) -- 1272
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1273
		e.fireCd = FIRE_COOLDOWN -- 1278
		return -- 1279
	end -- 1279
	self.hp = self.hp - 1 -- 1281
	self:emit("actorHit", { -- 1282
		target = "player", -- 1282
		amount = 1, -- 1282
		hp = self.hp, -- 1282
		maxHp = self.maxHp, -- 1282
		enemyX = e.x -- 1282
	}) -- 1282
	self:flashSet( -- 1283
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1283
		0.7 -- 1283
	) -- 1283
	e.fireCd = FIRE_COOLDOWN -- 1284
	if self.hp <= 0 then -- 1284
		self:gateFailed() -- 1286
	end -- 1286
end -- 1258
function Play.prototype.blockedByCover(self, ex, p) -- 1291
	local b = self:coverAt(p) -- 1292
	if b == nil then -- 1292
		return nil -- 1294
	end -- 1294
	return self:coverGuardsFrom(b, p, ex) and b or nil -- 1296
end -- 1291
function Play.prototype.gateFailed(self) -- 1300
	local ____temp_12 -- 1301
	if self.room.story == nil then -- 1301
		____temp_12 = nil -- 1301
	else -- 1301
		____temp_12 = self.room.story.gate -- 1301
	end -- 1301
	local g = ____temp_12 -- 1301
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1302
	self.hp = self.maxHp -- 1303
	self.gateTick = 0 -- 1304
	self.gateSpawned = 0 -- 1305
	self.enemies = {} -- 1306
	self.gateFailCount = self.gateFailCount + 1 -- 1307
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1309
	self.player.y = 0 -- 1310
	self.player.vy = 0 -- 1311
	self.player.onGround = true -- 1312
	self.player.crouch = false -- 1313
	self.player.h = SOLDIER_H -- 1314
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1315
	self.partner.y = 0 -- 1316
	self.partner.vy = 0 -- 1317
	self.partner.onGround = true -- 1318
	self.cam.x = self.player.x -- 1319
	self.phase = "gate-idle" -- 1320
	self.phaseTick = 0 -- 1321
	self.coverHug = false -- 1322
	self.coverBlocking = false -- 1323
	self.coverEntity = "" -- 1324
	self.gateNeedConfirm = true -- 1325
	self.gateRestartArmed = false -- 1326
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1327
end -- 1300
function Play.prototype.stepInteract(self, dt, input) -- 1330
	local p = self.player -- 1331
	local calmUsed = self.calmConsumed -- 1332
	self.calmConsumed = false -- 1333
	self.focusCart = false -- 1334
	if self.room.key == "outside" then -- 1334
		local c = self.room.cart -- 1336
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1337
		local dy = p.y - c.baseY -- 1338
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1339
	end -- 1339
	self:stepCart(dt, input) -- 1341
	if calmUsed then -- 1341
		self:flashSet("安抚 · 敲两下", 0.8) -- 1345
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1345
		if self.knockT > 0 then -- 1345
			self.knocks = self.knocks + 1 -- 1349
		else -- 1349
			self.knocks = 1 -- 1351
		end -- 1351
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1353
		self.knockT = 1.2 -- 1354
		if self.knocks >= 2 then -- 1354
			self:flashSet("敲两下", 0.8) -- 1356
			self.knocks = 0 -- 1357
		else -- 1357
			self:flashSet("敲一下", 0.5) -- 1359
		end -- 1359
	elseif self.knockT > 0 then -- 1359
		self.knockT = self.knockT - dt -- 1362
		if self.knockT <= 0 then -- 1362
			self.knocks = 0 -- 1364
		end -- 1364
	end -- 1364
	local i = 0 -- 1369
	do -- 1369
		i = 0 -- 1370
		while i < #self.room.marks do -- 1370
			do -- 1370
				local m = self.room.marks[i + 1] -- 1371
				if m.kind ~= 0 then -- 1371
					goto __continue217 -- 1373
				end -- 1373
				local subjects = {self.partner, self.player} -- 1375
				local k = 0 -- 1376
				do -- 1376
					k = 0 -- 1377
					while k < #subjects do -- 1377
						do -- 1377
							local s = subjects[k + 1] -- 1378
							if not s.alive then -- 1378
								goto __continue220 -- 1380
							end -- 1380
							local dx = s.x - m.x -- 1382
							local dy = s.y - m.y -- 1383
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1383
								self.checkpoint = m.x -- 1385
								self.checkpointCartAxle = self.cartAxle -- 1386
								if self.cartDocked then -- 1386
									self:flashSet("检查点 · 车已落窝", 1) -- 1388
								else -- 1388
									self:flashSet("检查点 · 车还没到位", 1) -- 1390
								end -- 1390
							end -- 1390
						end -- 1390
						::__continue220:: -- 1390
						k = k + 1 -- 1377
					end -- 1377
				end -- 1377
			end -- 1377
			::__continue217:: -- 1377
			i = i + 1 -- 1370
		end -- 1370
	end -- 1370
	self:checkCarryGate() -- 1396
end -- 1330
function Play.prototype.stepVillage(self, dt, input) -- 1400
	if self.room.key ~= "village" then -- 1400
		return -- 1402
	end -- 1402
	local p = self.player -- 1404
	local bottle = self.room.bottle -- 1405
	local scav = self.room.scavenger -- 1406
	if not self.hasBottle and bottle ~= nil then -- 1406
		local dx = p.x - bottle.x -- 1410
		local dy = p.y + p.h * 0.5 - bottle.y -- 1411
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1411
			self.hasBottle = true -- 1413
			self:flashSet("拾起瓶子", 0.8) -- 1414
		end -- 1414
	end -- 1414
	if self.hasBottle then -- 1414
		if input.aim.held then -- 1414
			self.aimHold = self.aimHold + dt -- 1421
			if self.aimHold > 1.2 then -- 1421
				self.aimHold = 1.2 -- 1423
			end -- 1423
			local cached = self:bottleEnd() -- 1426
			self.bottleAimX = cached.x -- 1427
			self.bottleAimY = cached.y -- 1428
		elseif input.aim.released then -- 1428
			if self.aimHold < 0.12 then -- 1428
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1432
				self.aimHold = 0 -- 1433
			else -- 1433
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1435
				self:throwBottle(____end.x, ____end.y) -- 1436
				self.aimHold = 0 -- 1437
			end -- 1437
		end -- 1437
	else -- 1437
		self.aimHold = 0 -- 1441
		self.bottleAimX = -1 -- 1442
	end -- 1442
	local fly = self.bottleFly -- 1447
	if fly ~= nil then -- 1447
		fly.t = fly.t + dt -- 1449
		fly.x = fly.x0 + fly.vx * fly.t -- 1450
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1451
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1452
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1452
			self:landBottle(fly) -- 1454
		end -- 1454
	end -- 1454
	if self.bottleLandT > 0 then -- 1454
		self.bottleLandT = self.bottleLandT - dt -- 1458
	end -- 1458
	if scav ~= nil then -- 1458
		self:stepScav(dt, scav) -- 1462
	end -- 1462
	local line = self.room.passLine -- 1465
	if line ~= nil and not self.passed and p.x >= line then -- 1465
		self.passed = true -- 1467
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1468
	end -- 1468
	if self.passed and p.x >= self.ox + 640 then -- 1468
		self:requestRoom("forest", "过第一院出院") -- 1472
		self:flashSet("出院 · 北塔森林", 1.4) -- 1473
	end -- 1473
end -- 1400
function Play.prototype.bottleEnd(self) -- 1478
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1479
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1480
	return {x = aim.x, y = g} -- 1481
end -- 1478
function Play.prototype.throwBottle(self, tx, ty) -- 1485
	local p = self.player -- 1486
	local dir = tx >= p.x and 1 or -1 -- 1488
	p.facing = dir -- 1489
	local x0 = p.x + dir * 10 -- 1490
	local y0 = p.y + p.h * 0.7 -- 1491
	self.bottleTargetX = tx -- 1492
	self.bottleTargetY = ty -- 1493
	self.bottleSurfaceY = ty -- 1494
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1495
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1496
	self.bottleFly = { -- 1497
		x = x0, -- 1497
		y = y0, -- 1497
		x0 = x0, -- 1497
		y0 = y0, -- 1497
		vx = vx, -- 1497
		vy = vy, -- 1497
		t = 0 -- 1497
	} -- 1497
	self.hasBottle = false -- 1498
	self:flashSet("投出", 0.4) -- 1499
	self:emit( -- 1500
		"bottleThrown", -- 1500
		{ -- 1500
			fromX = x0, -- 1501
			fromY = y0, -- 1502
			targetX = tx, -- 1503
			targetY = ty, -- 1504
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1505
		} -- 1505
	) -- 1505
end -- 1485
function Play.prototype.landBottle(self, fly) -- 1510
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1511
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1512
	local s = self.room.scavenger -- 1513
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1514
	self.bottleFly = nil -- 1515
	self.bottleTargetX = -1 -- 1516
	self.bottleTargetY = 0 -- 1517
	self.bottleSurfaceY = -1 -- 1518
	self.bottleLandX = x -- 1519
	self.bottleLandY = y -- 1520
	self.bottleLandT = 0.9 -- 1521
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1522
	self:hearBottle(x) -- 1523
end -- 1510
function Play.prototype.hearBottle(self, x) -- 1527
	local s = self.room.scavenger -- 1528
	if s == nil then -- 1528
		return -- 1530
	end -- 1530
	if math.abs(x - self.scavX) > s.range then -- 1530
		self:flashSet("落地 · 他没听见", 0.6) -- 1533
		return -- 1534
	end -- 1534
	self.scavState = "turn" -- 1536
	self.scavT = s.hearTicks -- 1537
	self.scavTargetX = x -- 1538
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1539
end -- 1527
function Play.prototype.stepScav(self, dt, s) -- 1543
	if self.scavState == "chase" then -- 1543
		return -- 1546
	end -- 1546
	if self.scavState == "turn" then -- 1546
		self.scavT = self.scavT - 1 -- 1549
		if self.scavT <= 0 then -- 1549
			self.scavState = "walk" -- 1551
		end -- 1551
		return -- 1553
	end -- 1553
	if self.scavState == "walk" then -- 1553
		local d = self.scavTargetX - self.scavX -- 1556
		if math.abs(d) < 4 then -- 1556
			self.scavState = "stall" -- 1558
			self.scavT = s.stallTicks -- 1559
			return -- 1560
		end -- 1560
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1562
		return -- 1563
	end -- 1563
	if self.scavState == "stall" then -- 1563
		self.scavT = self.scavT - 1 -- 1566
		if self.scavT <= 0 then -- 1566
			self.scavState = "back" -- 1568
		end -- 1568
		return -- 1570
	end -- 1570
	if self.scavState == "back" then -- 1570
		local home = math.max( -- 1573
			s.x0, -- 1573
			math.min(s.x1, self.scavX) -- 1573
		) -- 1573
		if math.abs(home - self.scavX) < 2 then -- 1573
			self.scavState = "patrol" -- 1575
			return -- 1576
		end -- 1576
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1578
		return -- 1579
	end -- 1579
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1581
	if self.scavX >= s.x1 then -- 1581
		self.scavX = s.x1 -- 1583
		self.scavDir = -1 -- 1584
	elseif self.scavX <= s.x0 then -- 1584
		self.scavX = s.x0 -- 1586
		self.scavDir = 1 -- 1587
	end -- 1587
end -- 1543
function Play.prototype.stepCart(self, dt, input) -- 1595
	local p = self.player -- 1596
	local c = self.room.cart -- 1597
	local handleX = self.cartAxle + c.handleOffset -- 1598
	if self.gripping then -- 1598
		if not input.interact.held then -- 1598
			self.gripping = false -- 1602
			self:flashSet("松开车把", 0.4) -- 1603
			return -- 1604
		end -- 1604
	else -- 1604
		if not input.interact.pressed then -- 1604
			return -- 1608
		end -- 1608
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1608
			return -- 1611
		end -- 1611
		self.gripping = true -- 1613
		self:flashSet("握住车把", 0.4) -- 1614
		return -- 1615
	end -- 1615
	if self.cartDocked then -- 1615
		return -- 1619
	end -- 1619
	local dir = input.moveX -- 1621
	if dir == 0 then -- 1621
		return -- 1623
	end -- 1623
	local lo = math.min(c.startX, c.endX) -- 1625
	local hi = math.max(c.startX, c.endX) -- 1626
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1627
	if next < lo then -- 1627
		next = lo -- 1629
	end -- 1629
	if next > hi then -- 1629
		next = hi -- 1632
	end -- 1632
	local delta = next - self.cartAxle -- 1634
	if delta == 0 then -- 1634
		return -- 1636
	end -- 1636
	self.cartAxle = next -- 1638
	p.x = p.x + delta -- 1639
	p.facing = dir > 0 and 1 or -1 -- 1640
	self:slideX(p, 0) -- 1641
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1641
		self.gripping = false -- 1643
		self:flashSet("跟不上了，脱手", 0.6) -- 1644
		return -- 1645
	end -- 1645
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1645
		self.cartDocked = true -- 1648
		self.gripping = false -- 1649
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1650
		self:flashSet("车轮落窝", 1.2) -- 1651
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1651
		self:flashSet("车轮回到起点", 0.5) -- 1653
	end -- 1653
end -- 1595
function Play.prototype.requestRoom(self, key, reason) -- 1661
	if self.wantRoom ~= "" then -- 1661
		return -- 1665
	end -- 1665
	self.wantRoom = key -- 1667
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1668
end -- 1661
function Play.prototype.checkCarryGate(self) -- 1675
	if self.room.key == "checkpoint" then -- 1675
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1675
			self.carryCartAxle = self.cartAxle -- 1678
			self.carryCartDocked = self.cartDocked -- 1679
			self:requestRoom("gate", "检查站出口") -- 1680
			self:flashSet("出检查站 · 城门", 1.2) -- 1681
		end -- 1681
		return -- 1683
	end -- 1683
	if self.room.key == "outside" then -- 1683
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1683
			self.carryCartAxle = self.cartAxle -- 1689
			self.carryCartDocked = self.cartDocked -- 1690
			self:requestRoom("village", "墙根走完") -- 1691
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1692
		end -- 1692
	end -- 1692
end -- 1675
function Play.prototype.aimAt(self, wx, wy) -- 1699
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1700
	self.aimX = s.x -- 1701
	self.aimY = s.y -- 1702
end -- 1699
function Play.prototype.shoot(self, a) -- 1705
	local ox = a.x + a.facing * 8 -- 1706
	local oy = a.y + a.h * 0.72 -- 1707
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1709
	local dx = aim.x - ox -- 1710
	local dy = aim.y - oy -- 1711
	local len = math.sqrt(dx * dx + dy * dy) -- 1712
	if len < 0.001 then -- 1712
		dx = a.facing -- 1714
		dy = 0 -- 1715
	else -- 1715
		dx = dx / len -- 1717
		dy = dy / len -- 1718
	end -- 1718
	if dx ~= 0 then -- 1718
		a.facing = dx > 0 and 1 or -1 -- 1721
	end -- 1721
	local hitEnemy = self:raycast( -- 1724
		ox, -- 1724
		oy, -- 1724
		dx, -- 1724
		dy, -- 1724
		true -- 1724
	) -- 1724
	local hitWall = self:raycast( -- 1725
		ox, -- 1725
		oy, -- 1725
		dx, -- 1725
		dy, -- 1725
		false -- 1725
	) -- 1725
	local tEnemy = hitEnemy.t -- 1726
	local tWall = hitWall.t -- 1727
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1728
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1729
	self.trace = { -- 1731
		x0 = ox, -- 1731
		y0 = oy, -- 1731
		x1 = ox + dx * t, -- 1731
		y1 = oy + dy * t, -- 1731
		hit = hit -- 1731
	} -- 1731
	self.traceT = 0.12 -- 1732
	self:applyFireDanger(ox) -- 1733
	if hit then -- 1733
		local i = hitEnemy.index -- 1735
		local e = self.enemies[i + 1] -- 1736
		e.alive = false -- 1737
		e.hitT = 0.4 -- 1738
		self:flashSet("命中", 0.6) -- 1739
	else -- 1739
		self:flashSet("打空", 0.35) -- 1741
	end -- 1741
	self:emit("shotResolved", { -- 1743
		hit = hit, -- 1744
		enemyIndex = hit and hitEnemy.index or -1, -- 1745
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1746
		aimX = aim.x, -- 1747
		aimY = aim.y, -- 1748
		impactX = ox + dx * t, -- 1749
		impactY = oy + dy * t -- 1750
	}) -- 1750
end -- 1705
function Play.prototype.applyFireDanger(self, shotX) -- 1755
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1755
		return -- 1757
	end -- 1757
	local dangerX = shotX -- 1759
	local best = -1 -- 1760
	local bestD = 1000000000 -- 1761
	local i = 0 -- 1762
	do -- 1762
		i = 0 -- 1763
		while i < #self.enemies do -- 1763
			do -- 1763
				local e = self.enemies[i + 1] -- 1764
				if not e.alive then -- 1764
					goto __continue291 -- 1766
				end -- 1766
				local d = math.abs(e.x - self.partner.x) -- 1768
				if d < bestD then -- 1768
					bestD = d -- 1770
					best = i -- 1771
				end -- 1771
			end -- 1771
			::__continue291:: -- 1771
			i = i + 1 -- 1763
		end -- 1763
	end -- 1763
	if best >= 0 then -- 1763
		dangerX = self.enemies[best + 1].x -- 1775
	end -- 1775
	local exposed = self:childExposed(dangerX) -- 1777
	local before = self.escort.fear -- 1778
	local dangerId = self.nextDangerId -- 1779
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1780
	self.nextDangerId = self.nextDangerId + 1 -- 1781
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1782
	if after > before then -- 1782
		self:flashSet( -- 1784
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1784
			1 -- 1784
		) -- 1784
	elseif not exposed then -- 1784
		self:flashSet("枪声没够到她", 0.5) -- 1786
	end -- 1786
end -- 1755
function Play.prototype.childExposed(self, dangerX) -- 1791
	local c = self.partner -- 1792
	if not c.alive then -- 1792
		return false -- 1794
	end -- 1794
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1794
		return false -- 1797
	end -- 1797
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1797
		return false -- 1800
	end -- 1800
	local toDanger = dangerX - c.x -- 1802
	local toPlayer = self.player.x - c.x -- 1803
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1803
		return false -- 1805
	end -- 1805
	return true -- 1807
end -- 1791
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1811
	local best = -1 -- 1812
	local bestI = -1 -- 1813
	local i = 0 -- 1814
	if enemies then -- 1814
		do -- 1814
			i = 0 -- 1816
			while i < #self.enemies do -- 1816
				do -- 1816
					local e = self.enemies[i + 1] -- 1817
					if not e.alive then -- 1817
						goto __continue305 -- 1819
					end -- 1819
					local t = hitBox( -- 1821
						ox, -- 1821
						oy, -- 1821
						dx, -- 1821
						dy, -- 1821
						e.x - e.w / 2, -- 1821
						e.x + e.w / 2, -- 1821
						e.y, -- 1821
						e.y + e.h -- 1821
					) -- 1821
					if t >= 0 and (best < 0 or t < best) then -- 1821
						best = t -- 1823
						bestI = i -- 1824
					end -- 1824
				end -- 1824
				::__continue305:: -- 1824
				i = i + 1 -- 1816
			end -- 1816
		end -- 1816
		return {t = best, index = bestI} -- 1827
	end -- 1827
	do -- 1827
		i = 0 -- 1829
		while i < #self.boxes do -- 1829
			local b = self.boxes[i + 1] -- 1830
			local t = hitBox( -- 1831
				ox, -- 1831
				oy, -- 1831
				dx, -- 1831
				dy, -- 1831
				b.x0, -- 1831
				b.x1, -- 1831
				b.y0, -- 1831
				b.y1 -- 1831
			) -- 1831
			if t >= 0 and (best < 0 or t < best) then -- 1831
				best = t -- 1833
			end -- 1833
			i = i + 1 -- 1829
		end -- 1829
	end -- 1829
	if dy < 0 then -- 1829
		local t = (0 - oy) / dy -- 1838
		if t >= 0 and (best < 0 or t < best) then -- 1838
			best = t -- 1840
		end -- 1840
	end -- 1840
	return {t = best, index = -1} -- 1843
end -- 1811
function Play.prototype.slideX(self, a, dx) -- 1847
	local nx = a.x + dx -- 1848
	local half = a.w / 2 -- 1849
	local room = self.room -- 1850
	nx = math.max( -- 1851
		room.minX + half, -- 1851
		math.min(room.maxX - half, nx) -- 1851
	) -- 1851
	local i = 0 -- 1852
	do -- 1852
		i = 0 -- 1853
		while i < #self.boxes do -- 1853
			do -- 1853
				local b = self.boxes[i + 1] -- 1854
				if b.passable == true then -- 1854
					goto __continue315 -- 1856
				end -- 1856
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1856
					goto __continue315 -- 1859
				end -- 1859
				if nx + half > b.x0 and nx - half < b.x1 then -- 1859
					if a.x <= b.x0 then -- 1859
						nx = b.x0 - half -- 1863
					elseif a.x >= b.x1 then -- 1863
						nx = b.x1 + half -- 1865
					else -- 1865
						nx = a.x -- 1867
					end -- 1867
				end -- 1867
			end -- 1867
			::__continue315:: -- 1867
			i = i + 1 -- 1853
		end -- 1853
	end -- 1853
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1853
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1875
		local bx0 = self.cartAxle - CART_HALF -- 1876
		local bx1 = self.cartAxle + CART_HALF -- 1877
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1877
			if a.x <= bx0 then -- 1877
				nx = bx0 - half -- 1880
			elseif a.x >= bx1 then -- 1880
				nx = bx1 + half -- 1882
			else -- 1882
				nx = a.x -- 1884
			end -- 1884
		end -- 1884
	end -- 1884
	local arch = room.arch -- 1892
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1892
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1894
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1894
			if a.x <= arch.x0 then -- 1894
				nx = arch.x0 - half -- 1897
			elseif a.x >= arch.x1 then -- 1897
				nx = arch.x1 + half -- 1899
			end -- 1899
		end -- 1899
	end -- 1899
	a.x = nx -- 1903
end -- 1847
function Play.prototype.fallY(self, a, dt) -- 1907
	a.vy = a.vy - ____exports.GRAVITY * dt -- 1908
	if a.vy < -900 then -- 1908
		a.vy = -900 -- 1910
	end -- 1910
	local ny = a.y + a.vy * dt -- 1912
	local half = a.w / 2 -- 1913
	if a.vy <= 0 then -- 1913
		local reach = a.onGround and STEP_UP or 0 -- 1916
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1917
		if ny <= ground then -- 1917
			ny = ground -- 1919
			a.vy = 0 -- 1920
			a.onGround = true -- 1921
		else -- 1921
			a.onGround = false -- 1923
		end -- 1923
	else -- 1923
		a.onGround = false -- 1926
		local i = 0 -- 1927
		do -- 1927
			i = 0 -- 1928
			while i < #self.boxes do -- 1928
				do -- 1928
					local b = self.boxes[i + 1] -- 1929
					if b.passable == true then -- 1929
						goto __continue338 -- 1931
					end -- 1931
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1931
						goto __continue338 -- 1934
					end -- 1934
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1934
						ny = b.y0 - a.h -- 1937
						a.vy = 0 -- 1938
					end -- 1938
				end -- 1938
				::__continue338:: -- 1938
				i = i + 1 -- 1928
			end -- 1928
		end -- 1928
	end -- 1928
	a.y = ny -- 1942
end -- 1907
function Play.prototype.groundAt(self, x, ceiling, half) -- 1946
	local g = -9999 -- 1947
	local i = 0 -- 1948
	do -- 1948
		i = 0 -- 1949
		while i < #self.floors do -- 1949
			local f = self.floors[i + 1] -- 1950
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1950
				g = f.y1 -- 1952
			end -- 1952
			i = i + 1 -- 1949
		end -- 1949
	end -- 1949
	do -- 1949
		i = 0 -- 1955
		while i < #self.boxes do -- 1955
			local b = self.boxes[i + 1] -- 1956
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1956
				g = b.y1 -- 1958
			end -- 1958
			i = i + 1 -- 1955
		end -- 1955
	end -- 1955
	return g -- 1961
end -- 1946
function Play.prototype.updateCamera(self, dt) -- 1964
	local p = self.player -- 1965
	local tx = p.x + p.facing * 30 -- 1966
	local ty = p.y + CAM_LOOK_UP -- 1967
	local k = math.min(1, CAM_FOLLOW * dt) -- 1968
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1969
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1970
end -- 1964
function Play.prototype.clampCamera(self, w, h) -- 1974
	local room = self.room -- 1975
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1976
	local spanX = room.maxX - room.minX -- 1977
	if spanX <= halfW * 2 then -- 1977
		self.cam.x = (room.minX + room.maxX) / 2 -- 1979
	else -- 1979
		self.cam.x = math.max( -- 1981
			room.minX + halfW, -- 1981
			math.min(room.maxX - halfW, self.cam.x) -- 1981
		) -- 1981
	end -- 1981
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1984
	local spanY = room.height -- 1985
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1986
	if spanY <= halfH * 2 then -- 1986
		self.cam.y = camY -- 1988
	else -- 1988
		self.cam.y = math.max( -- 1990
			camY, -- 1990
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1990
		) -- 1990
	end -- 1990
end -- 1974
function Play.prototype.flashSet(self, text, t) -- 1994
	self.flash = text -- 1995
	self.flashT = t -- 1996
end -- 1994
function Play.prototype.statusText(self) -- 2000
	local p = self.player -- 2001
	local parts = {} -- 2002
	local who = self.childMode and "小满" or "周戍" -- 2003
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2004
	if self.room.key == "prologue" then -- 2004
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2007
		if self.phase == "prologue-wait" then -- 2007
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2009
		elseif self.phase == "prologue-give" then -- 2009
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2011
		else -- 2011
			parts[#parts + 1] = "跟随" -- 2013
		end -- 2013
		if self.paused then -- 2013
			parts[#parts + 1] = "已暂停" -- 2016
		end -- 2016
		return table.concat(parts, " · ") -- 2018
	end -- 2018
	if self.room.key == "street" then -- 2018
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2021
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2022
		if self.paused then -- 2022
			parts[#parts + 1] = "已暂停" -- 2024
		end -- 2024
		return table.concat(parts, " · ") -- 2026
	end -- 2026
	if self.room.key == "gate" then -- 2026
		local ____temp_13 -- 2029
		if self.room.story == nil then -- 2029
			____temp_13 = nil -- 2029
		else -- 2029
			____temp_13 = self.room.story.gate -- 2029
		end -- 2029
		local g = ____temp_13 -- 2029
		if g ~= nil then -- 2029
			parts[#parts + 1] = self:gateLabel() -- 2031
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2032
				0, -- 2033
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2033
			))) .. " 秒" -- 2033
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2034
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2035
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2036
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2037
			if self.gateFailCount > 0 then -- 2037
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2039
			end -- 2039
			if self.flash ~= "" then -- 2039
				parts[#parts + 1] = self.flash -- 2042
			end -- 2042
		end -- 2042
		if self.paused then -- 2042
			parts[#parts + 1] = "已暂停" -- 2046
		end -- 2046
		return table.concat(parts, " · ") -- 2048
	end -- 2048
	if self.room.key == "forest" then -- 2048
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2051
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2052
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2053
		if self.caughtT > 0 then -- 2053
			parts[#parts + 1] = "复位中" -- 2055
		end -- 2055
		if self.paused then -- 2055
			parts[#parts + 1] = "已暂停" -- 2058
		end -- 2058
		return table.concat(parts, " · ") -- 2060
	end -- 2060
	if self.room.key == "tower" then -- 2060
		if self.phase == "tower-wait" then -- 2060
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2064
		elseif self.phase == "tower-knock" then -- 2064
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2066
		elseif self.phase == "tower-given" then -- 2066
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2068
		else -- 2068
			parts[#parts + 1] = "片尾" -- 2070
		end -- 2070
		if self.paused then -- 2070
			parts[#parts + 1] = "已暂停" -- 2073
		end -- 2073
		return table.concat(parts, " · ") -- 2075
	end -- 2075
	if self.room.key == "village" then -- 2075
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2078
		if self.hasBottle then -- 2078
			parts[#parts + 1] = "有瓶" -- 2080
		elseif self.bottleFly ~= nil then -- 2080
			parts[#parts + 1] = "瓶在飞" -- 2082
		else -- 2082
			parts[#parts + 1] = "空手" -- 2084
		end -- 2084
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2086
		if self.scavChase then -- 2086
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2088
		end -- 2088
		if self.passed then -- 2088
			parts[#parts + 1] = "已过通行线" -- 2091
		end -- 2091
		if self.paused then -- 2091
			parts[#parts + 1] = "已暂停" -- 2094
		end -- 2094
		return table.concat(parts, " · ") -- 2096
	end -- 2096
	local isChild = self.childMode -- 2099
	if isChild then -- 2099
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2101
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2102
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2103
	else -- 2103
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2105
		if p.rollT > 0 then -- 2105
			parts[#parts + 1] = "翻滚中" -- 2107
		end -- 2107
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2109
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2110
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2111
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2112
	end -- 2112
	if self.checkpoint >= 0 then -- 2112
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2115
	end -- 2115
	if self.paused then -- 2115
		parts[#parts + 1] = "已暂停" -- 2118
	end -- 2118
	return table.concat(parts, " · ") -- 2120
end -- 2000
function Play.prototype.aliveEnemies(self) -- 2124
	local n = 0 -- 2125
	local i = 0 -- 2126
	do -- 2126
		i = 0 -- 2127
		while i < #self.enemies do -- 2127
			if self.enemies[i + 1].alive then -- 2127
				n = n + 1 -- 2129
			end -- 2129
			i = i + 1 -- 2127
		end -- 2127
	end -- 2127
	return n -- 2132
end -- 2124
function Play.prototype.threatened(self) -- 2137
	do -- 2137
		local i = 0 -- 2138
		while i < #self.enemies do -- 2138
			local e = self.enemies[i + 1] -- 2139
			if e.alive and e.warnT > 0 then -- 2139
				return true -- 2141
			end -- 2141
			i = i + 1 -- 2138
		end -- 2138
	end -- 2138
	return false -- 2144
end -- 2137
function Play.prototype.gateSecondsLeft(self) -- 2147
	local ____temp_14 -- 2148
	if self.room.story == nil then -- 2148
		____temp_14 = nil -- 2148
	else -- 2148
		____temp_14 = self.room.story.gate -- 2148
	end -- 2148
	local g = ____temp_14 -- 2148
	if g == nil then -- 2148
		return 0 -- 2150
	end -- 2150
	return math.max( -- 2152
		0, -- 2152
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2152
	) -- 2152
end -- 2147
function Play.prototype.gateLabel(self) -- 2155
	if self.phase == "gate-idle" then -- 2155
		return "待就位" -- 2157
	end -- 2157
	if self.phase == "gate-hold" then -- 2157
		return "守点中" -- 2160
	end -- 2160
	if self.phase == "gate-send" then -- 2160
		return "送别" -- 2163
	end -- 2163
	if self.phase == "gate-count" then -- 2163
		return "数数 " .. tostring(self.countTick) -- 2166
	end -- 2166
	return "她走" -- 2168
end -- 2155
function Play.prototype.dogLabel(self) -- 2172
	if self.dogState == "ear" then -- 2172
		return "转耳" -- 2174
	end -- 2174
	if self.dogState == "chase" then -- 2174
		return "追" -- 2177
	end -- 2177
	if self.dogState == "sniff" then -- 2177
		return "停" -- 2180
	end -- 2180
	if self.dogState == "back" then -- 2180
		return "回线" -- 2183
	end -- 2183
	return "巡逻" -- 2185
end -- 2172
function Play.prototype.doorXOf(self) -- 2188
	local ____temp_15 -- 2189
	if self.room.story == nil then -- 2189
		____temp_15 = nil -- 2189
	else -- 2189
		____temp_15 = self.room.story.tower -- 2189
	end -- 2189
	local t = ____temp_15 -- 2189
	return t == nil and 0 or t.doorX -- 2190
end -- 2188
function Play.prototype.scavLabel(self) -- 2194
	if self.scavState == "chase" then -- 2194
		return "追" -- 2196
	end -- 2196
	if self.scavState == "turn" then -- 2196
		return "转头" -- 2199
	end -- 2199
	if self.scavState == "walk" then -- 2199
		return "赶来" -- 2202
	end -- 2202
	if self.scavState == "stall" then -- 2202
		return "停住" -- 2205
	end -- 2205
	if self.scavState == "back" then -- 2205
		return "回位" -- 2208
	end -- 2208
	return "巡逻" -- 2210
end -- 2194
function Play.prototype.hintText(self) -- 2214
	if self.paused then -- 2214
		return "Esc 继续 · R 重置" -- 2216
	end -- 2216
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2216
		if self:threatened() then -- 2216
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2222
		end -- 2222
		if self.coverHug then -- 2222
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2225
		end -- 2225
		if self.coverNear then -- 2225
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2228
		end -- 2228
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2230
	end -- 2230
	if self.flash ~= "" then -- 2230
		return self.flash -- 2233
	end -- 2233
	if self.room.key == "prologue" then -- 2233
		if self.phase == "prologue-wait" then -- 2233
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2237
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2238
		end -- 2238
		if self.phase == "prologue-give" then -- 2238
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2241
		end -- 2241
		return "她跟着你了 · 两人一起走到门口 680" -- 2243
	end -- 2243
	if self.room.key == "street" then -- 2243
		if self:aliveEnemies() > 0 then -- 2243
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2247
		end -- 2247
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2249
	end -- 2249
	if self.room.key == "gate" then -- 2249
		local ____temp_16 -- 2252
		if self.room.story == nil then -- 2252
			____temp_16 = nil -- 2252
		else -- 2252
			____temp_16 = self.room.story.gate -- 2252
		end -- 2252
		local g = ____temp_16 -- 2252
		if g ~= nil then -- 2252
			if self.phase == "gate-idle" then -- 2252
				if self.gateNeedConfirm then -- 2252
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2256
				end -- 2256
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2258
			end -- 2258
			if self.phase == "gate-hold" then -- 2258
				if self.coveredFlash > 0 then -- 2258
					return "掩体挡下了这一枪 · 别露头" -- 2262
				end -- 2262
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2264
			end -- 2264
			if self.phase == "gate-send" then -- 2264
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2267
			end -- 2267
			if self.phase == "gate-count" then -- 2267
				if self.countTick >= 1440 then -- 2267
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2271
				end -- 2271
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2273
			end -- 2273
			return "她自己走 · 跟着出城门 1120" -- 2275
		end -- 2275
	end -- 2275
	if self.room.key == "forest" then -- 2275
		if self.dogState == "chase" then -- 2275
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2280
		end -- 2280
		if self.dogState == "ear" then -- 2280
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2283
		end -- 2283
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2285
	end -- 2285
	if self.room.key == "tower" then -- 2285
		if self.phase == "tower-wait" then -- 2285
			return "走到门前 445 点一次 E 敲两下" -- 2289
		end -- 2289
		if self.phase == "tower-knock" then -- 2289
			return "敲两下 · 等门开" -- 2292
		end -- 2292
		if self.phase == "tower-given" then -- 2292
			return "递交针套和纸条 · 看登记簿最后一行" -- 2295
		end -- 2295
		return "片尾 · 点 E 再玩一次，回到序章" -- 2297
	end -- 2297
	if self.room.key == "village" then -- 2297
		if self.bottleFly ~= nil then -- 2297
			return "等瓶子落地 · 触地才发声" -- 2301
		end -- 2301
		if self.hasBottle then -- 2301
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2304
		end -- 2304
		if self.passed then -- 2304
			return "已过第一院 · R 重置可再来一遍" -- 2307
		end -- 2307
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2309
	end -- 2309
	if self.room.key == "outside" then -- 2309
		if self.focusCart then -- 2309
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2313
		end -- 2313
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2315
	end -- 2315
	if self.escort.state == "frozen" then -- 2315
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2315
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2319
		end -- 2319
		return "小满吓住了 · 走过去，靠近再点 E" -- 2321
	end -- 2321
	if self.escort.state == "calming" then -- 2321
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2324
	end -- 2324
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2326
end -- 2214
function Play.prototype.draw(self, draw, w, h) -- 2331
	self.viewW = w -- 2332
	self.viewH = h -- 2333
	self.view = ____exports.computeViewport(w, h) -- 2334
	self:clampCamera(w, h) -- 2335
	draw:clear() -- 2336
	draw:drawRect( -- 2338
		Rect(0, 0, w, h), -- 2338
		BG_VOID -- 2338
	) -- 2338
	local box = self:canvasRect(w, h) -- 2339
	draw:drawRect(box, BG_FAR) -- 2340
	draw:drawRect( -- 2341
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2341
		BG_MID -- 2341
	) -- 2341
	self:drawFloors(draw, w, h) -- 2343
	self:drawSolids(draw, w, h) -- 2344
	self:drawZones(draw, w, h) -- 2345
	self:drawArch(draw, w, h) -- 2346
	self:drawCart(draw, w, h) -- 2347
	self:drawActors(draw, w, h) -- 2348
	self:drawTrace(draw, w, h) -- 2349
	self:drawAim(draw, w, h) -- 2350
end -- 2331
function Play.prototype.canvasRect(self, w, h) -- 2354
	local v = self.view -- 2355
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2356
end -- 2354
function Play.prototype.px(self, n) -- 2360
	return n * self.view.zoom -- 2361
end -- 2360
function Play.prototype.sx(self, wx, w) -- 2365
	local v = self.view -- 2366
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2367
	return v.ox + lx * v.zoom -- 2368
end -- 2365
function Play.prototype.sy(self, wy, h) -- 2372
	local v = self.view -- 2373
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2374
	return v.oy + ly * v.zoom -- 2375
end -- 2372
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2378
	local px0 = self:sx(x0, w) -- 2379
	local px1 = self:sx(x1, w) -- 2380
	local py0 = self:sy(y0, h) -- 2381
	local py1 = self:sy(y1, h) -- 2382
	if px1 <= px0 or py1 <= py0 then -- 2382
		return -- 2384
	end -- 2384
	draw:drawRect( -- 2386
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2386
		color -- 2386
	) -- 2386
end -- 2378
function Play.prototype.drawFloors(self, draw, w, h) -- 2389
	local i = 0 -- 2390
	do -- 2390
		i = 0 -- 2391
		while i < #self.room.floors do -- 2391
			local f = self.room.floors[i + 1] -- 2392
			local y = self:sy(f.y, h) -- 2393
			local x0 = self:sx(f.x0, w) -- 2394
			local x1 = self:sx(f.x1, w) -- 2395
			local deck = self:px(5) -- 2396
			draw:drawRect( -- 2397
				Rect(x0, y - deck, x1 - x0, deck), -- 2397
				FLOOR_DECK -- 2397
			) -- 2397
			draw:drawSegment( -- 2398
				Vec2(x0, y), -- 2398
				Vec2(x1, y), -- 2398
				self:px(1), -- 2398
				GROUND -- 2398
			) -- 2398
			i = i + 1 -- 2391
		end -- 2391
	end -- 2391
end -- 2389
function Play.prototype.drawSolids(self, draw, w, h) -- 2402
	local i = 0 -- 2403
	do -- 2403
		i = 0 -- 2404
		while i < #self.boxes do -- 2404
			do -- 2404
				local b = self.boxes[i + 1] -- 2405
				if b.y0 < -4 and b.y1 <= 96 then -- 2405
					draw:drawSegment( -- 2408
						Vec2( -- 2408
							self:sx(b.x0, w), -- 2408
							self:sy(b.y1, h) -- 2408
						), -- 2408
						Vec2( -- 2408
							self:sx(b.x1, w), -- 2408
							self:sy(b.y1, h) -- 2408
						), -- 2408
						self:px(1), -- 2408
						GROUND -- 2408
					) -- 2408
					goto __continue466 -- 2409
				end -- 2409
				self:drawBox( -- 2411
					draw, -- 2411
					w, -- 2411
					h, -- 2411
					b.x0, -- 2411
					b.x1, -- 2411
					b.y0, -- 2411
					b.y1, -- 2411
					SOLID_FILL -- 2411
				) -- 2411
				draw:drawSegment( -- 2412
					Vec2( -- 2412
						self:sx(b.x0, w), -- 2412
						self:sy(b.y1, h) -- 2412
					), -- 2412
					Vec2( -- 2412
						self:sx(b.x1, w), -- 2412
						self:sy(b.y1, h) -- 2412
					), -- 2412
					self:px(1), -- 2412
					SOLID_EDGE -- 2412
				) -- 2412
			end -- 2412
			::__continue466:: -- 2412
			i = i + 1 -- 2404
		end -- 2404
	end -- 2404
end -- 2402
function Play.prototype.drawZones(self, draw, w, h) -- 2416
	local i = 0 -- 2417
	do -- 2417
		i = 0 -- 2418
		while i < #self.room.zones do -- 2418
			local z = self.room.zones[i + 1] -- 2419
			local fill = DANGER -- 2420
			local line = DANGER_LINE -- 2421
			if z.tint == 2 then -- 2421
				fill = SOFT -- 2423
				line = SOFT_LINE -- 2424
			elseif z.tint == 3 then -- 2424
				fill = BRICK -- 2426
				line = BRICK_LINE -- 2427
			elseif z.tint == 4 then -- 2427
				fill = PASS -- 2429
				line = PASS_LINE -- 2430
			end -- 2430
			self:drawBox( -- 2432
				draw, -- 2432
				w, -- 2432
				h, -- 2432
				z.x0, -- 2432
				z.x1, -- 2432
				z.y, -- 2432
				z.y + z.h, -- 2432
				fill -- 2432
			) -- 2432
			draw:drawSegment( -- 2433
				Vec2( -- 2433
					self:sx(z.x0, w), -- 2433
					self:sy(z.y, h) -- 2433
				), -- 2433
				Vec2( -- 2433
					self:sx(z.x0, w), -- 2433
					self:sy(z.y + z.h, h) -- 2433
				), -- 2433
				self:px(1), -- 2433
				line -- 2433
			) -- 2433
			draw:drawSegment( -- 2434
				Vec2( -- 2434
					self:sx(z.x1, w), -- 2434
					self:sy(z.y, h) -- 2434
				), -- 2434
				Vec2( -- 2434
					self:sx(z.x1, w), -- 2434
					self:sy(z.y + z.h, h) -- 2434
				), -- 2434
				self:px(1), -- 2434
				line -- 2434
			) -- 2434
			i = i + 1 -- 2418
		end -- 2418
	end -- 2418
end -- 2416
function Play.prototype.drawArch(self, draw, w, h) -- 2438
	local a = self.room.arch -- 2439
	if a.h <= 0 then -- 2439
		return -- 2441
	end -- 2441
	self:drawBox( -- 2443
		draw, -- 2443
		w, -- 2443
		h, -- 2443
		a.x0, -- 2443
		a.x1, -- 2443
		a.y, -- 2443
		a.y + a.h, -- 2443
		HOLE_FILL -- 2443
	) -- 2443
	draw:drawSegment( -- 2444
		Vec2( -- 2444
			self:sx(a.x0, w), -- 2444
			self:sy(a.y + a.h, h) -- 2444
		), -- 2444
		Vec2( -- 2444
			self:sx(a.x1, w), -- 2444
			self:sy(a.y + a.h, h) -- 2444
		), -- 2444
		self:px(1), -- 2444
		SOLID_EDGE -- 2444
	) -- 2444
	draw:drawSegment( -- 2445
		Vec2( -- 2445
			self:sx(a.x0, w), -- 2445
			self:sy(a.y, h) -- 2445
		), -- 2445
		Vec2( -- 2445
			self:sx(a.x0, w), -- 2445
			self:sy(a.y + a.h, h) -- 2445
		), -- 2445
		self:px(1), -- 2445
		SOLID_EDGE -- 2445
	) -- 2445
	draw:drawSegment( -- 2446
		Vec2( -- 2446
			self:sx(a.x1, w), -- 2446
			self:sy(a.y, h) -- 2446
		), -- 2446
		Vec2( -- 2446
			self:sx(a.x1, w), -- 2446
			self:sy(a.y + a.h, h) -- 2446
		), -- 2446
		self:px(1), -- 2446
		SOLID_EDGE -- 2446
	) -- 2446
end -- 2438
function Play.prototype.drawCart(self, draw, w, h) -- 2449
	local c = self.room.cart -- 2450
	if c.bodyW <= 0 then -- 2450
		return -- 2452
	end -- 2452
	drawCartShape( -- 2454
		draw, -- 2454
		self, -- 2454
		w, -- 2454
		h, -- 2454
		c, -- 2454
		self.cartAxle -- 2454
	) -- 2454
	draw:drawRect( -- 2455
		Rect( -- 2455
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2455
			self:sy(c.baseY + 40, h), -- 2455
			self:px(2), -- 2455
			self:px(40) -- 2455
		), -- 2455
		STAND -- 2455
	) -- 2455
end -- 2449
function Play.prototype.drawActors(self, draw, w, h) -- 2458
	local p = self.player -- 2459
	local isChild = self.childMode -- 2460
	if p.covered then -- 2460
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2463
		draw:drawSegment( -- 2464
			Vec2( -- 2464
				self:sx(edge, w), -- 2464
				self:sy(p.y + 8, h) -- 2464
			), -- 2464
			Vec2( -- 2464
				self:sx(edge, w), -- 2464
				self:sy(p.y + p.h * 0.62, h) -- 2464
			), -- 2464
			self:px(2), -- 2464
			STAND -- 2464
		) -- 2464
		draw:drawSegment( -- 2466
			Vec2( -- 2466
				self:sx(p.x - 8, w), -- 2466
				self:sy(p.y + p.h + 3, h) -- 2466
			), -- 2466
			Vec2( -- 2466
				self:sx(p.x + 8, w), -- 2466
				self:sy(p.y + p.h + 3, h) -- 2466
			), -- 2466
			self:px(2), -- 2466
			STAND -- 2466
		) -- 2466
	elseif self.coverNear and not isChild then -- 2466
		draw:drawRect( -- 2469
			Rect( -- 2469
				self:sx(p.x - 3, w), -- 2469
				self:sy(p.y + 1, h), -- 2469
				self:px(3), -- 2469
				self:px(3) -- 2469
			), -- 2469
			STAND -- 2469
		) -- 2469
	end -- 2469
	drawFigure( -- 2471
		draw, -- 2471
		self, -- 2471
		w, -- 2471
		h, -- 2471
		p, -- 2471
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2471
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2471
	) -- 2471
	local q = self.partner -- 2472
	if q.alive then -- 2472
		local childPartner = q.w == CHILD_W -- 2474
		drawFigure( -- 2475
			draw, -- 2475
			self, -- 2475
			w, -- 2475
			h, -- 2475
			q, -- 2475
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2475
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2475
		) -- 2475
	end -- 2475
	local i = 0 -- 2477
	do -- 2477
		i = 0 -- 2478
		while i < #self.enemies do -- 2478
			local e = self.enemies[i + 1] -- 2479
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2480
			self:drawBox( -- 2481
				draw, -- 2481
				w, -- 2481
				h, -- 2481
				e.x - e.w / 2, -- 2481
				e.x + e.w / 2, -- 2481
				e.y, -- 2481
				e.y + e.h, -- 2481
				col -- 2481
			) -- 2481
			if e.alive and e.warnT > 0 then -- 2481
				local gunX = self:sx(e.x, w) -- 2484
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2485
				local aimX = self:sx(p.x, w) -- 2486
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2487
				local seg = 8 -- 2488
				local s = 0 -- 2489
				do -- 2489
					s = 0 -- 2490
					while s < seg do -- 2490
						local t0 = s / seg -- 2491
						local t1 = (s + 1) / seg -- 2492
						draw:drawSegment( -- 2493
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2494
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2495
							self:px(1), -- 2496
							DANGER -- 2496
						) -- 2496
						s = s + 2 -- 2490
					end -- 2490
				end -- 2490
			end -- 2490
			i = i + 1 -- 2478
		end -- 2478
	end -- 2478
	local k = 0 -- 2501
	do -- 2501
		k = 0 -- 2502
		while k < #self.room.marks do -- 2502
			do -- 2502
				local m = self.room.marks[k + 1] -- 2503
				if m.kind ~= 0 then -- 2503
					goto __continue488 -- 2505
				end -- 2505
				local on = self.checkpoint == m.x -- 2507
				local x = self:sx(m.x, w) -- 2508
				local y = self:sy(m.y, h) -- 2509
				draw:drawSegment( -- 2510
					Vec2(x, y), -- 2510
					Vec2( -- 2510
						x, -- 2510
						y + self:px(35) -- 2510
					), -- 2510
					self:px(1), -- 2510
					on and CHECK or INK_DIM -- 2510
				) -- 2510
				draw:drawDot( -- 2511
					Vec2( -- 2511
						x, -- 2511
						y + self:px(35) -- 2511
					), -- 2511
					self:px(2), -- 2511
					on and CHECK or INK_DIM -- 2511
				) -- 2511
			end -- 2511
			::__continue488:: -- 2511
			k = k + 1 -- 2502
		end -- 2502
	end -- 2502
	local j = 0 -- 2515
	do -- 2515
		j = 0 -- 2516
		while j < #self.room.marks do -- 2516
			do -- 2516
				local m = self.room.marks[j + 1] -- 2517
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2517
					goto __continue491 -- 2519
				end -- 2519
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2519
					goto __continue491 -- 2523
				end -- 2523
				local col = STAND -- 2525
				if m.kind == 4 then -- 2525
					col = PASS_LINE -- 2527
				elseif m.kind == 5 then -- 2527
					col = BRICK_LINE -- 2529
				end -- 2529
				local mx = self:sx(m.x, w) -- 2531
				local my = self:sy(m.y, h) -- 2532
				draw:drawSegment( -- 2533
					Vec2(mx, my), -- 2533
					Vec2( -- 2533
						mx, -- 2533
						my + self:px(24) -- 2533
					), -- 2533
					self:px(1), -- 2533
					col -- 2533
				) -- 2533
			end -- 2533
			::__continue491:: -- 2533
			j = j + 1 -- 2516
		end -- 2516
	end -- 2516
	local t = 0 -- 2536
	do -- 2536
		t = 0 -- 2537
		while t < #self.room.marks do -- 2537
			do -- 2537
				local m = self.room.marks[t + 1] -- 2538
				if m.kind ~= 6 then -- 2538
					goto __continue497 -- 2540
				end -- 2540
				local mx = self:sx(m.x, w) -- 2542
				local my = self:sy(m.y, h) -- 2543
				draw:drawSegment( -- 2544
					Vec2(mx, my), -- 2544
					Vec2( -- 2544
						mx, -- 2544
						my + self:px(30) -- 2544
					), -- 2544
					self:px(1), -- 2544
					INK_DIM -- 2544
				) -- 2544
				self:drawBox( -- 2545
					draw, -- 2545
					w, -- 2545
					h, -- 2545
					m.x - 5, -- 2545
					m.x + 5, -- 2545
					m.y + 30, -- 2545
					m.y + 40, -- 2545
					CHECK -- 2545
				) -- 2545
			end -- 2545
			::__continue497:: -- 2545
			t = t + 1 -- 2537
		end -- 2537
	end -- 2537
	if self.room.key == "village" then -- 2537
		self:drawVillage(draw, w, h) -- 2548
	end -- 2548
	if self.room.key == "forest" then -- 2548
		self:drawDog(draw, w, h) -- 2551
	end -- 2551
end -- 2458
function Play.prototype.drawDog(self, draw, w, h) -- 2556
	local x = self.dogX -- 2557
	self:drawBox( -- 2558
		draw, -- 2558
		w, -- 2558
		h, -- 2558
		x - 14, -- 2558
		x + 14, -- 2558
		0, -- 2558
		20, -- 2558
		SCAV_BODY -- 2558
	) -- 2558
	self:drawBox( -- 2559
		draw, -- 2559
		w, -- 2559
		h, -- 2559
		x - 10, -- 2559
		x - 2, -- 2559
		20, -- 2559
		30, -- 2559
		SCAV_BODY -- 2559
	) -- 2559
	self:drawBox( -- 2560
		draw, -- 2560
		w, -- 2560
		h, -- 2560
		x + 2, -- 2560
		x + 10, -- 2560
		20, -- 2560
		30, -- 2560
		SCAV_HEAD -- 2560
	) -- 2560
	if self.dogState == "ear" or self.dogState == "chase" then -- 2560
		draw:drawSegment( -- 2562
			Vec2( -- 2562
				self:sx(x, w), -- 2562
				self:sy(30, h) -- 2562
			), -- 2562
			Vec2( -- 2563
				self:sx(x, w), -- 2563
				self:sy(40, h) -- 2563
			), -- 2563
			self:px(1), -- 2563
			DANGER -- 2563
		) -- 2563
	end -- 2563
end -- 2556
function Play.prototype.drawVillage(self, draw, w, h) -- 2568
	local bottle = self.room.bottle -- 2569
	if bottle ~= nil then -- 2569
		self:drawBox( -- 2571
			draw, -- 2571
			w, -- 2571
			h, -- 2571
			bottle.x - 14, -- 2571
			bottle.x + 14, -- 2571
			0, -- 2571
			64, -- 2571
			SOLID_FILL -- 2571
		) -- 2571
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2571
			self:drawBottle( -- 2573
				draw, -- 2573
				w, -- 2573
				h, -- 2573
				bottle.x, -- 2573
				64 -- 2573
			) -- 2573
		end -- 2573
	end -- 2573
	self:drawBox( -- 2577
		draw, -- 2577
		w, -- 2577
		h, -- 2577
		300, -- 2577
		420, -- 2577
		44, -- 2577
		50, -- 2577
		FLOOR_DECK -- 2577
	) -- 2577
	self:drawBox( -- 2578
		draw, -- 2578
		w, -- 2578
		h, -- 2578
		300, -- 2578
		306, -- 2578
		0, -- 2578
		44, -- 2578
		FLOOR_DECK -- 2578
	) -- 2578
	self:drawBox( -- 2579
		draw, -- 2579
		w, -- 2579
		h, -- 2579
		414, -- 2579
		420, -- 2579
		0, -- 2579
		44, -- 2579
		FLOOR_DECK -- 2579
	) -- 2579
	local s = self.room.scavenger -- 2581
	if s ~= nil then -- 2581
		local sx0 = self.scavX -- 2583
		self:drawBox( -- 2584
			draw, -- 2584
			w, -- 2584
			h, -- 2584
			sx0 - 12, -- 2584
			sx0 + 12, -- 2584
			0, -- 2584
			s.h - 14, -- 2584
			SCAV_BODY -- 2584
		) -- 2584
		self:drawBox( -- 2585
			draw, -- 2585
			w, -- 2585
			h, -- 2585
			sx0 - 7, -- 2585
			sx0 + 7, -- 2585
			s.h - 14, -- 2585
			s.h, -- 2585
			SCAV_HEAD -- 2585
		) -- 2585
		if self.scavState == "turn" then -- 2585
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2587
			draw:drawSegment( -- 2588
				Vec2( -- 2588
					self:sx(sx0, w), -- 2588
					self:sy(s.h - 6, h) -- 2588
				), -- 2588
				Vec2( -- 2588
					self:sx(fx, w), -- 2588
					self:sy(s.h - 6, h) -- 2588
				), -- 2588
				self:px(1), -- 2588
				INK -- 2588
			) -- 2588
		end -- 2588
	end -- 2588
	if self.hasBottle then -- 2588
		local p = self.player -- 2593
		self:drawBottle( -- 2594
			draw, -- 2594
			w, -- 2594
			h, -- 2594
			p.x + p.facing * 10, -- 2594
			p.y + p.h * 0.62 -- 2594
		) -- 2594
	end -- 2594
	if self.bottleFly ~= nil then -- 2594
		self:drawBottle( -- 2597
			draw, -- 2597
			w, -- 2597
			h, -- 2597
			self.bottleFly.x, -- 2597
			self.bottleFly.y -- 2597
		) -- 2597
	end -- 2597
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2597
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2600
		draw:drawCircle( -- 2601
			Vec2( -- 2601
				self:sx(self.bottleLandX, w), -- 2601
				self:sy(0, h) -- 2601
			), -- 2601
			self:px(r / ____exports.UNITS_PER_PX), -- 2601
			BRICK_LINE -- 2601
		) -- 2601
	end -- 2601
end -- 2568
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2605
	self:drawBox( -- 2606
		draw, -- 2606
		w, -- 2606
		h, -- 2606
		x - 3, -- 2606
		x + 3, -- 2606
		y - 10, -- 2606
		y, -- 2606
		BOTTLE -- 2606
	) -- 2606
end -- 2605
function Play.prototype.drawTrace(self, draw, w, h) -- 2609
	local t = self.trace -- 2610
	if t == nil or self.traceT <= 0 then -- 2610
		return -- 2612
	end -- 2612
	draw:drawSegment( -- 2614
		Vec2( -- 2615
			self:sx(t.x0, w), -- 2615
			self:sy(t.y0, h) -- 2615
		), -- 2615
		Vec2( -- 2616
			self:sx(t.x1, w), -- 2616
			self:sy(t.y1, h) -- 2616
		), -- 2616
		self:px(1), -- 2617
		t.hit and AIM_HIT or INK_DIM -- 2617
	) -- 2617
end -- 2609
function Play.prototype.drawAim(self, draw, w, h) -- 2620
	local v = self.view -- 2622
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2623
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2624
	local dot = self:px(1) -- 2625
	local arm = self:px(3) -- 2626
	local gap = self:px(1) -- 2627
	draw:drawSegment( -- 2628
		Vec2(gx - arm - gap, gy), -- 2628
		Vec2(gx - gap, gy), -- 2628
		dot / 2, -- 2628
		AIM -- 2628
	) -- 2628
	draw:drawSegment( -- 2629
		Vec2(gx + gap, gy), -- 2629
		Vec2(gx + arm + gap, gy), -- 2629
		dot / 2, -- 2629
		AIM -- 2629
	) -- 2629
	draw:drawSegment( -- 2630
		Vec2(gx, gy - arm - gap), -- 2630
		Vec2(gx, gy - gap), -- 2630
		dot / 2, -- 2630
		AIM -- 2630
	) -- 2630
	draw:drawSegment( -- 2631
		Vec2(gx, gy + gap), -- 2631
		Vec2(gx, gy + arm + gap), -- 2631
		dot / 2, -- 2631
		AIM -- 2631
	) -- 2631
	if self.room.key == "village" and self.hasBottle then -- 2631
		local p = self.player -- 2635
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2637
		local dir = ____end.x >= p.x and 1 or -1 -- 2638
		local x0 = p.x + dir * 10 -- 2639
		local y0 = p.y + p.h * 0.7 -- 2640
		local T = BOTTLE_FLY_TIME -- 2641
		local vx = (____end.x - x0) / T -- 2642
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2643
		local pxr = x0 -- 2644
		local pyr = y0 -- 2645
		local t = 1 -- 2646
		do -- 2646
			t = 1 -- 2647
			while t <= 12 do -- 2647
				local tt = t / 12 * T -- 2648
				local nx = x0 + vx * tt -- 2649
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2650
				draw:drawSegment( -- 2651
					Vec2( -- 2651
						self:sx(pxr, w), -- 2651
						self:sy(pyr, h) -- 2651
					), -- 2651
					Vec2( -- 2651
						self:sx(nx, w), -- 2651
						self:sy(ny, h) -- 2651
					), -- 2651
					self:px(1) / 2, -- 2651
					BOTTLE -- 2651
				) -- 2651
				pxr = nx -- 2652
				pyr = ny -- 2653
				t = t + 1 -- 2647
			end -- 2647
		end -- 2647
		draw:drawCircle( -- 2655
			Vec2( -- 2655
				self:sx(____end.x, w), -- 2655
				self:sy(____end.y + 2, h) -- 2655
			), -- 2655
			self:px(2), -- 2655
			BOTTLE -- 2655
		) -- 2655
	end -- 2655
end -- 2620
return ____exports -- 2620