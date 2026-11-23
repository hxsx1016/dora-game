-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
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
function makeActor(room, index) -- 2630
	local sp = room.spawns -- 2631
	if index < 0 or index >= #sp then -- 2631
		return { -- 2633
			x = 0, -- 2633
			y = 0, -- 2633
			vx = 0, -- 2633
			vy = 0, -- 2633
			w = CHILD_W, -- 2633
			h = CHILD_H, -- 2633
			onGround = true, -- 2633
			facing = 1, -- 2633
			crouch = false, -- 2633
			rollT = 0, -- 2633
			covered = false, -- 2633
			alive = false -- 2633
		} -- 2633
	end -- 2633
	local s = sp[index + 1] -- 2635
	local child = s.h <= CHILD_H -- 2636
	return { -- 2637
		x = s.x, -- 2638
		y = s.y, -- 2638
		vx = 0, -- 2638
		vy = 0, -- 2638
		w = child and CHILD_W or SOLDIER_W, -- 2639
		h = child and CHILD_H or SOLDIER_H, -- 2640
		onGround = true, -- 2641
		facing = 1, -- 2641
		crouch = false, -- 2641
		rollT = 0, -- 2641
		covered = false, -- 2641
		alive = true -- 2641
	} -- 2641
end -- 2641
function drawFigure(draw, play, w, h, a, body, head) -- 2645
	if not a.alive then -- 2645
		return -- 2647
	end -- 2647
	local x0 = a.x - a.w / 2 -- 2649
	local x1 = a.x + a.w / 2 -- 2650
	local y0 = a.y -- 2651
	local y1 = a.y + a.h -- 2652
	play:drawBox( -- 2653
		draw, -- 2653
		w, -- 2653
		h, -- 2653
		x0, -- 2653
		x1, -- 2653
		y0, -- 2653
		y1 - a.h * 0.26, -- 2653
		body -- 2653
	) -- 2653
	play:drawBox( -- 2654
		draw, -- 2654
		w, -- 2654
		h, -- 2654
		x0 + 2, -- 2654
		x1 - 2, -- 2654
		y1 - a.h * 0.26, -- 2654
		y1, -- 2654
		head -- 2654
	) -- 2654
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2656
	play:drawBox( -- 2657
		draw, -- 2657
		w, -- 2657
		h, -- 2657
		eyeX, -- 2657
		eyeX + 4, -- 2657
		y1 - a.h * 0.14, -- 2657
		y1 - a.h * 0.08, -- 2657
		INK -- 2657
	) -- 2657
end -- 2657
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2661
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2662
end -- 2661
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2669
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2670
end -- 2669
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2677
	local tmin = 0 -- 2678
	local tmax = 99999 -- 2679
	if dx == 0 then -- 2679
		if ox < x0 or ox > x1 then -- 2679
			return -1 -- 2682
		end -- 2682
	else -- 2682
		local t1 = (x0 - ox) / dx -- 2685
		local t2 = (x1 - ox) / dx -- 2686
		local lo = t1 < t2 and t1 or t2 -- 2687
		local hi = t1 < t2 and t2 or t1 -- 2688
		if lo > tmin then -- 2688
			tmin = lo -- 2690
		end -- 2690
		if hi < tmax then -- 2690
			tmax = hi -- 2693
		end -- 2693
	end -- 2693
	if dy == 0 then -- 2693
		if oy < y0 or oy > y1 then -- 2693
			return -1 -- 2698
		end -- 2698
	else -- 2698
		local t1 = (y0 - oy) / dy -- 2701
		local t2 = (y1 - oy) / dy -- 2702
		local lo = t1 < t2 and t1 or t2 -- 2703
		local hi = t1 < t2 and t2 or t1 -- 2704
		if lo > tmin then -- 2704
			tmin = lo -- 2706
		end -- 2706
		if hi < tmax then -- 2706
			tmax = hi -- 2709
		end -- 2709
	end -- 2709
	return tmax >= tmin and tmin or -1 -- 2712
end -- 2712
function drawCartShape(draw, play, w, h, c, axleX) -- 2715
	local half = c.bodyW / 2 -- 2716
	local x0 = axleX - half -- 2717
	local x1 = axleX + half -- 2718
	play:drawBox( -- 2719
		draw, -- 2719
		w, -- 2719
		h, -- 2719
		x0, -- 2719
		x1, -- 2719
		c.baseY + c.wheelR, -- 2719
		c.baseY + c.wheelR + c.bodyH, -- 2719
		CART_FILL -- 2719
	) -- 2719
	draw:drawCircle( -- 2720
		Vec2( -- 2720
			play:sx(x0 + c.bodyW * 0.28, w), -- 2720
			play:sy(c.baseY + c.wheelR, h) -- 2720
		), -- 2720
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2720
		Color(52, 50, 48, 255) -- 2720
	) -- 2720
	draw:drawCircle( -- 2721
		Vec2( -- 2721
			play:sx(x1 - c.bodyW * 0.28, w), -- 2721
			play:sy(c.baseY + c.wheelR, h) -- 2721
		), -- 2721
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2721
		Color(52, 50, 48, 255) -- 2721
	) -- 2721
	local cx = c.clothSide < 0 and x0 or x1 -- 2722
	play:drawBox( -- 2723
		draw, -- 2723
		w, -- 2723
		h, -- 2723
		cx - 10, -- 2723
		cx + 10, -- 2723
		c.baseY + c.wheelR + c.bodyH, -- 2723
		c.baseY + c.wheelR + c.bodyH + 18, -- 2723
		CLOTH -- 2723
	) -- 2723
end -- 2723
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
function Play.prototype.update(self, dt, input) -- 464
	if input.pause.pressed then -- 464
		self.paused = not self.paused -- 466
	end -- 466
	if self.flashT > 0 then -- 466
		self.flashT = self.flashT - dt -- 469
		if self.flashT <= 0 then -- 469
			self.flash = "" -- 471
		end -- 471
	end -- 471
	if self.traceT > 0 then -- 471
		self.traceT = self.traceT - dt -- 475
		if self.traceT <= 0 then -- 475
			self.trace = nil -- 477
		end -- 477
	end -- 477
	if self.paused then -- 477
		self:updateCamera(dt) -- 481
		return -- 482
	end -- 482
	self.ticks = self.ticks + 1 -- 485
	local p = self.player -- 486
	self:stepPlayer(p, dt, input) -- 487
	self:refreshCover(p, input) -- 489
	self:stepEnemies(dt, input) -- 491
	self:stepStory(dt, input) -- 492
	self:stepEscort(dt, input) -- 493
	self:stepVillage(dt, input) -- 494
	self:stepChase(dt, input) -- 495
	self:stepInteract(dt, input) -- 496
	self:updateGate() -- 497
	self:updateCamera(dt) -- 498
end -- 464
function Play.prototype.coverAt(self, a) -- 505
	local best = nil -- 506
	local bestGap = 24 -- 507
	local half = a.w / 2 -- 508
	local i = 0 -- 509
	do -- 509
		i = 0 -- 510
		while i < #self.boxes do -- 510
			do -- 510
				local b = self.boxes[i + 1] -- 511
				if b.passable == true or b.y1 - b.y0 < 44 then -- 511
					goto __continue38 -- 513
				end -- 513
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 513
					goto __continue38 -- 516
				end -- 516
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 518
				if gap < bestGap then -- 518
					bestGap = gap -- 520
					best = b -- 521
				end -- 521
			end -- 521
			::__continue38:: -- 521
			i = i + 1 -- 510
		end -- 510
	end -- 510
	return best -- 524
end -- 505
function Play.prototype.nearCover(self, a) -- 527
	return self:coverAt(a) ~= nil -- 528
end -- 527
function Play.prototype.coverGuardsFrom(self, b, a, enemyX) -- 532
	if enemyX < 0 then -- 532
		return false -- 534
	end -- 534
	if enemyX >= a.x then -- 534
		return b.x0 >= a.x - 0.001 and b.x0 <= enemyX -- 537
	end -- 537
	return b.x1 <= a.x + 0.001 and b.x1 >= enemyX -- 539
end -- 532
function Play.prototype.nearestEnemyX(self, a) -- 543
	local best = -1 -- 544
	local bestD = 1000000000 -- 545
	local i = 0 -- 546
	do -- 546
		i = 0 -- 547
		while i < #self.enemies do -- 547
			do -- 547
				local e = self.enemies[i + 1] -- 548
				if not e.alive then -- 548
					goto __continue48 -- 550
				end -- 550
				local d = math.abs(e.x - a.x) -- 552
				if d < bestD then -- 552
					bestD = d -- 554
					best = e.x -- 555
				end -- 555
			end -- 555
			::__continue48:: -- 555
			i = i + 1 -- 547
		end -- 547
	end -- 547
	return best -- 558
end -- 543
function Play.prototype.refreshCover(self, a, input) -- 562
	if self.childMode then -- 562
		self.coverNear = false -- 564
		self.coverHug = false -- 565
		self.coverEntity = "" -- 566
		self.coverBlocking = false -- 567
		a.covered = false -- 568
		return -- 569
	end -- 569
	local b = self:coverAt(a) -- 571
	self.coverNear = b ~= nil -- 572
	a.covered = self.coverNear and input.cover.held -- 573
	self.coverHug = a.covered -- 574
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 575
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 576
		b, -- 576
		a, -- 576
		self:nearestEnemyX(a) -- 576
	) -- 576
end -- 562
function Play.prototype.nearLowLedge(self, a) -- 580
	local reach = 26 -- 581
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 582
	local x1 = x0 + reach -- 583
	local i = 0 -- 584
	do -- 584
		i = 0 -- 585
		while i < #self.boxes do -- 585
			do -- 585
				local b = self.boxes[i + 1] -- 586
				if b.x1 <= x0 or b.x0 >= x1 then -- 586
					goto __continue55 -- 588
				end -- 588
				local rise = b.y1 - a.y -- 590
				if rise > 0 and rise <= LEDGE_RISE then -- 590
					return true -- 592
				end -- 592
			end -- 592
			::__continue55:: -- 592
			i = i + 1 -- 585
		end -- 585
	end -- 585
	return false -- 595
end -- 580
function Play.prototype.stepPlayer(self, a, dt, input) -- 598
	if not a.alive then -- 598
		return -- 600
	end -- 600
	local isChild = self.childMode -- 602
	if self:storyLocked() then -- 602
		a.vx = 0 -- 605
		a.crouch = false -- 606
		a.h = isChild and CHILD_H or SOLDIER_H -- 607
		self:fallY(a, dt) -- 608
		return -- 609
	end -- 609
	if not isChild and self.escort.state == "calming" then -- 609
		a.crouch = false -- 613
		a.h = SOLDIER_H -- 614
		a.vx = 0 -- 615
		self:fallY(a, dt) -- 616
		return -- 617
	end -- 617
	a.crouch = isChild and input.crouch.held and a.onGround -- 619
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 620
	local nearCover = not isChild and self:nearCover(a) -- 621
	a.covered = nearCover and input.cover.held -- 622
	if a.rollT > 0 then -- 622
		a.rollT = a.rollT - dt -- 626
		a.vx = a.facing * ROLL_SPEED -- 627
		self:slideX(a, a.vx * dt) -- 628
		self:fallY(a, dt) -- 629
		if a.rollT <= 0 then -- 629
			self:flashSet("翻滚结束", 0.5) -- 631
		end -- 631
		return -- 633
	end -- 633
	if not isChild and input.jump.pressed and a.onGround then -- 633
		if input.moveX ~= 0 then -- 633
			a.facing = input.moveX > 0 and 1 or -1 -- 638
		end -- 638
		if self:nearLowLedge(a) then -- 638
			a.vy = SOLDIER_JUMP -- 642
			a.onGround = false -- 643
			self:flashSet("翻上去", 0.3) -- 644
			return -- 645
		end -- 645
		a.rollT = ROLL_TIME -- 647
		self:flashSet("翻滚", 0.3) -- 648
		return -- 649
	end -- 649
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 652
	if isChild then -- 652
		if input.cover.held then -- 652
			speed = CHILD_SLOW -- 655
		end -- 655
		if a.crouch then -- 655
			speed = CHILD_SLOW -- 658
		end -- 658
	elseif a.covered then -- 658
		speed = SOLDIER_SPEED * 0.45 -- 661
	end -- 661
	local dir = self.gripping and 0 or input.moveX -- 665
	if dir ~= 0 then -- 665
		a.facing = dir > 0 and 1 or -1 -- 667
	end -- 667
	a.vx = dir * speed -- 669
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 669
		a.vy = CHILD_JUMP -- 673
		a.onGround = false -- 674
		self:flashSet("跳", 0.25) -- 675
	end -- 675
	self:slideX(a, a.vx * dt) -- 678
	self:fallY(a, dt) -- 679
	if not isChild and input.fire.pressed then -- 679
		self:shoot(a) -- 683
	end -- 683
end -- 598
function Play.prototype.stepPartner(self, p, dt) -- 688
	local a = self.partner -- 689
	if not a.alive then -- 689
		return -- 691
	end -- 691
	a.crouch = false -- 693
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 694
	a.vx = 0 -- 695
	self:fallY(a, dt) -- 696
end -- 688
function Play.prototype.stepEscort(self, dt, input) -- 703
	local a = self.partner -- 704
	if not a.alive then -- 704
		return -- 706
	end -- 706
	if not self:escortOn() then -- 706
		a.vx = 0 -- 709
		self:fallY(a, dt) -- 710
		return -- 711
	end -- 711
	local p = self.player -- 713
	local dist = math.abs(p.x - a.x) -- 714
	self.calmConsumed = self.escort:update( -- 715
		input, -- 715
		p.x, -- 715
		p.facing, -- 715
		a.x, -- 715
		dist -- 715
	) -- 715
	a.crouch = self.escort.crouchPose -- 716
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 717
	local dir = self.escort:moveDir(a.x) -- 718
	a.vx = dir * CHILD_SPEED -- 719
	if dir ~= 0 then -- 719
		a.facing = dir -- 721
		local before = a.x -- 722
		self:slideX(a, dir * CHILD_SPEED * dt) -- 723
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 723
			a.vy = CHILD_JUMP -- 726
			a.onGround = false -- 727
		end -- 727
	end -- 727
	self:fallY(a, dt) -- 730
end -- 703
function Play.prototype.escortOn(self) -- 734
	if self.room.key == "checkpoint" then -- 734
		return true -- 736
	end -- 736
	if self.room.key == "prologue" then -- 736
		return self.phase == "prologue-follow" -- 739
	end -- 739
	return self.room.key == "street" -- 741
end -- 734
function Play.prototype.storyLocked(self) -- 745
	if self.caughtT > 0 then -- 745
		return true -- 747
	end -- 747
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 747
		return true -- 750
	end -- 750
	if self.room.key == "gate" and self.phase == "gate-count" then -- 750
		return true -- 753
	end -- 753
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 753
		return true -- 756
	end -- 756
	return false -- 758
end -- 745
function Play.prototype.swapToChild(self, x) -- 762
	local tmp = self.player -- 763
	self.player = self.partner -- 764
	self.partner = tmp -- 765
	self.childMode = true -- 766
	self.player.alive = true -- 767
	self.player.x = self.ox + x -- 768
	self.player.y = 0 -- 769
	self.player.vy = 0 -- 770
	self.player.vx = 0 -- 771
	self.player.onGround = true -- 772
	self.player.crouch = false -- 773
	self.player.h = CHILD_H -- 774
	self.player.facing = 1 -- 775
	self.partner.alive = true -- 776
	self.cam.x = self.player.x -- 777
end -- 762
function Play.prototype.stepStory(self, dt, input) -- 781
	if self.room.key == "prologue" then -- 781
		self:stepPrologue(dt, input) -- 783
	elseif self.room.key == "street" then -- 783
		self:stepStreet(dt, input) -- 785
	elseif self.room.key == "gate" then -- 785
		self:stepGate(dt, input) -- 787
	elseif self.room.key == "tower" then -- 787
		self:stepTower(dt, input) -- 789
	end -- 789
end -- 781
function Play.prototype.stepPrologue(self, dt, input) -- 794
	local child = self.partner -- 795
	if self.phase == "prologue-wait" then -- 795
		child.crouch = true -- 797
		child.h = CHILD_CROUCH_H -- 798
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 799
		local near = math.abs(self.player.x - child.x) <= reach -- 801
		if near and input.interact.pressed then -- 801
			self.phase = "prologue-give" -- 803
			self.phaseTick = 0 -- 804
			self:flashSet("递出针套", 1) -- 805
		end -- 805
		return -- 807
	end -- 807
	if self.phase == "prologue-give" then -- 807
		self.phaseTick = self.phaseTick + 1 -- 810
		if self.phaseTick == 12 then -- 810
			self:flashSet("针套递过去", 0.7) -- 812
		elseif self.phaseTick == 36 then -- 812
			self:flashSet("纸条塞进针套", 0.9) -- 814
		elseif self.phaseTick >= 60 then -- 814
			self.phase = "prologue-follow" -- 816
			self.phaseTick = 0 -- 817
			child.crouch = false -- 818
			child.h = CHILD_H -- 819
			self:flashSet("她跟上了", 1.2) -- 820
		end -- 820
		return -- 822
	end -- 822
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 822
		self:requestRoom("street", "序章跟到门口") -- 826
		self:flashSet("进街道", 1.2) -- 827
	end -- 827
end -- 794
function Play.prototype.stepStreet(self, dt, input) -- 832
	local p = self.player -- 833
	local c = self.partner -- 834
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 834
		self:requestRoom("checkpoint", "两人都到街尾") -- 836
		self:flashSet("到检查站", 1.2) -- 837
	end -- 837
end -- 832
function Play.prototype.stepGate(self, dt, input) -- 842
	local ____temp_8 -- 843
	if self.room.story == nil then -- 843
		____temp_8 = nil -- 843
	else -- 843
		____temp_8 = self.room.story.gate -- 843
	end -- 843
	local g = ____temp_8 -- 843
	if g == nil then -- 843
		return -- 845
	end -- 845
	local p = self.player -- 847
	if self.phase == "gate-idle" then -- 847
		local a = self.partner -- 850
		local gap = g.waitX - a.x -- 851
		if math.abs(gap) > 3 then -- 851
			a.facing = gap > 0 and 1 or -1 -- 853
			a.vx = a.facing * CHILD_SPEED -- 854
			local beforeX = a.x -- 855
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 856
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 856
				a.vy = CHILD_JUMP -- 858
				a.onGround = false -- 859
			end -- 859
			self:fallY(a, dt) -- 861
		else -- 861
			a.vx = 0 -- 863
			a.x = g.waitX -- 864
		end -- 864
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 867
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 868
		if self.gateNeedConfirm then -- 868
			if not input.interact.held then -- 868
				self.gateRestartArmed = true -- 873
			end -- 873
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 873
				self.gateNeedConfirm = false -- 876
				self.gateRestartArmed = true -- 877
				self.phase = "gate-hold" -- 878
				self.gateTick = 0 -- 879
				self.gateSpawned = 0 -- 880
				self:flashSet("重新就位 · 守点开始", 1.4) -- 881
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 882
			end -- 882
			return -- 884
		end -- 884
		if atWinch and atWait then -- 884
			self.phase = "gate-hold" -- 887
			self.gateTick = 0 -- 888
			self.gateSpawned = 0 -- 889
			self:flashSet("两人就位 · 守点开始", 1.4) -- 890
		end -- 890
		return -- 892
	end -- 892
	if self.phase == "gate-hold" then -- 892
		self.gateTick = self.gateTick + 1 -- 895
		local marks = {0, 540, 900, 1500} -- 897
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 897
			local idx = self.gateSpawned -- 899
			local ____self_enemies_9 = self.enemies -- 899
			____self_enemies_9[#____self_enemies_9 + 1] = { -- 900
				x = self.ox + 620 + idx * 62, -- 901
				y = 0, -- 901
				w = 26, -- 901
				h = 84, -- 901
				alive = true, -- 902
				hitT = 0, -- 902
				warnT = 0, -- 902
				fireCd = 90 + idx * 45 -- 902
			} -- 902
			self.gateSpawned = self.gateSpawned + 1 -- 904
			self:flashSet( -- 905
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 905
				0.9 -- 905
			) -- 905
		end -- 905
		if self.gateTick == 900 then -- 905
			self:flashSet("灯灭了", 1) -- 908
		elseif self.gateTick == 2100 then -- 908
			self:flashSet("门底压下来了", 1) -- 910
		end -- 910
		if self.gateTick >= g.holdTicks then -- 910
			self.phase = "gate-send" -- 913
			self.phaseTick = 0 -- 914
			self.enemies = {} -- 916
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 917
		end -- 917
		return -- 919
	end -- 919
	if self.phase == "gate-send" then -- 919
		local near = math.abs(p.x - g.doorX) <= 60 -- 922
		if near and input.interact.pressed then -- 922
			self:swapToChild(g.doorX + 30) -- 924
			self.phase = "gate-count" -- 925
			self.countTick = 0 -- 926
			self.countArmed = false -- 928
			self.countPrevMove = input.moveX -- 929
			self:flashSet("门开了 · 送她出去", 1.8) -- 930
		end -- 930
		return -- 932
	end -- 932
	if self.phase == "gate-count" then -- 932
		self.countTick = self.countTick + 1 -- 935
		if self.countTick == 360 then -- 935
			self:flashSet("门关上", 0.9) -- 937
		elseif self.countTick == 1020 then -- 937
			self:flashSet("数到一百", 2.2) -- 939
		end -- 939
		local prevMove = self.countPrevMove -- 943
		self.countPrevMove = input.moveX -- 944
		if self.countTick >= 1440 then -- 944
			if prevMove <= 0 and input.moveX > 0 then -- 944
				self.countArmed = true -- 947
			end -- 947
			if self.countArmed and input.moveX > 0 then -- 947
				self.phase = "gate-walk" -- 950
				self.phaseTick = 0 -- 951
				self:flashSet("她迈出第一步", 1.4) -- 952
			end -- 952
		end -- 952
		return -- 955
	end -- 955
	if self.player.x >= g.exitX then -- 955
		self:requestRoom("outside", "走出城门") -- 959
		self:flashSet("出城门 · 城外", 1.4) -- 960
	end -- 960
end -- 842
function Play.prototype.stepTower(self, dt, input) -- 965
	local ____temp_10 -- 966
	if self.room.story == nil then -- 966
		____temp_10 = nil -- 966
	else -- 966
		____temp_10 = self.room.story.tower -- 966
	end -- 966
	local t = ____temp_10 -- 966
	if t == nil then -- 966
		return -- 968
	end -- 968
	if self.phase == "tower-wait" then -- 968
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 971
		if near and input.interact.pressed then -- 971
			self.phase = "tower-knock" -- 973
			self.phaseTick = 0 -- 974
			self.knocks = 1 -- 975
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 976
			self:flashSet("敲一下", 0.6) -- 977
		end -- 977
		return -- 979
	end -- 979
	if self.phase == "tower-knock" then -- 979
		self.phaseTick = self.phaseTick + 1 -- 982
		if self.phaseTick == 12 then -- 982
			self.knocks = 2 -- 984
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 985
			self:flashSet("敲两下 · 第二声", 1) -- 986
		elseif self.phaseTick >= t.knockTicks then -- 986
			self.phase = "tower-given" -- 988
			self.phaseTick = 0 -- 989
			self:flashSet("门开了 · 提灯", 1.4) -- 990
		end -- 990
		return -- 992
	end -- 992
	if self.phase == "tower-given" then -- 992
		self.phaseTick = self.phaseTick + 1 -- 995
		if self.phaseTick == 60 then -- 995
			self:flashSet("她递出针套和纸条", 1.6) -- 997
		elseif self.phaseTick == 120 then -- 997
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 999
		elseif self.phaseTick >= 180 then -- 999
			self.phase = "tower-end" -- 1001
			self.phaseTick = 0 -- 1002
			self:flashSet("片尾 · E 再玩一次", 3) -- 1003
		end -- 1003
		return -- 1005
	end -- 1005
	if input.interact.pressed or input.retry.pressed then -- 1005
		self:requestRoom("prologue", "片尾再玩") -- 1008
		self:flashSet("回到序章", 1.4) -- 1009
	end -- 1009
end -- 965
function Play.prototype.stepChase(self, dt, input) -- 1014
	if self.caughtT > 0 then -- 1014
		self.caughtT = self.caughtT - dt -- 1016
		if self.caughtT <= 0 then -- 1016
			self:recoverFromCaught() -- 1018
		end -- 1018
		return -- 1020
	end -- 1020
	if self.room.key == "village" then -- 1020
		self:stepScavChase() -- 1023
	elseif self.room.key == "forest" then -- 1023
		self:stepDog(dt) -- 1025
		if self.player.x >= self.ox + 1450 then -- 1025
			self:requestRoom("tower", "到林缘北塔") -- 1028
			self:flashSet("林缘 · 北塔", 1.4) -- 1029
		end -- 1029
	end -- 1029
end -- 1014
function Play.prototype.stepScavChase(self) -- 1035
	local s = self.room.scavenger -- 1036
	if s == nil then -- 1036
		return -- 1038
	end -- 1038
	local p = self.player -- 1040
	if self.passed and p.x > self.ox + 440 then -- 1040
		if self.scavChase then -- 1040
			self.scavChase = false -- 1044
			self.scavState = "back" -- 1045
			self.scavT = 0 -- 1046
		end -- 1046
		return -- 1048
	end -- 1048
	local dx = p.x - self.scavX -- 1050
	local dist = math.abs(dx) -- 1051
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1052
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1053
	if not self.scavChase then -- 1053
		if visible then -- 1053
			self.scavSee = self.scavSee + 1 -- 1056
			if self.scavSee >= 24 then -- 1056
				self.scavChase = true -- 1058
				self.scavState = "chase" -- 1059
				self.scavTargetX = p.x -- 1060
				self:flashSet("他看见你了", 1.2) -- 1061
			end -- 1061
		else -- 1061
			self.scavSee = 0 -- 1064
		end -- 1064
		return -- 1066
	end -- 1066
	local dir = p.x > self.scavX and 1 or -1 -- 1069
	self.scavX = self.scavX + dir * 96 / 60 -- 1070
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1070
		self:caught() -- 1072
		return -- 1073
	end -- 1073
	if hidden then -- 1073
		self.scavSee = 0 -- 1077
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1078
		self.scavT = self.scavT - 1 -- 1079
		if self.scavT <= 0 then -- 1079
			self.scavChase = false -- 1081
			self.scavState = "patrol" -- 1082
			self:flashSet("他失去了目标", 1) -- 1083
		end -- 1083
	end -- 1083
end -- 1035
function Play.prototype.stepDog(self, dt) -- 1089
	local ____temp_11 -- 1090
	if self.room.story == nil then -- 1090
		____temp_11 = nil -- 1090
	else -- 1090
		____temp_11 = self.room.story.dog -- 1090
	end -- 1090
	local dog = ____temp_11 -- 1090
	if dog == nil then -- 1090
		return -- 1092
	end -- 1092
	local p = self.player -- 1094
	local dist = math.abs(p.x - self.dogX) -- 1095
	if self.dogState == "patrol" then -- 1095
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1097
		if self.dogX < dog.x0 then -- 1097
			self.dogX = dog.x0 -- 1099
			self.dogDir = 1 -- 1100
		elseif self.dogX > dog.x1 then -- 1100
			self.dogX = dog.x1 -- 1102
			self.dogDir = -1 -- 1103
		end -- 1103
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1105
		if not p.crouch and moving and dist < dog.range then -- 1105
			self.dogState = "ear" -- 1107
			self.dogT = 18 -- 1108
			self.dogTargetX = p.x -- 1109
			self:flashSet("狗转耳朵", 0.8) -- 1110
		end -- 1110
		return -- 1112
	end -- 1112
	if self.dogState == "ear" then -- 1112
		self.dogT = self.dogT - 1 -- 1115
		if self.dogT <= 0 then -- 1115
			self.dogState = "chase" -- 1117
			self.dogTargetX = p.x -- 1118
			self:flashSet("狗追来了", 1.4) -- 1119
		end -- 1119
		return -- 1121
	end -- 1121
	if self.dogState == "chase" then -- 1121
		local dir = p.x > self.dogX and 1 or -1 -- 1124
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1125
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1125
			self:caught() -- 1127
			self.dogState = "sniff" -- 1128
			self.dogT = 60 -- 1129
		elseif dist > dog.range * 1.5 or p.crouch then -- 1129
			self.dogState = "sniff" -- 1131
			self.dogT = 60 -- 1132
			self:flashSet("狗停下了", 0.9) -- 1133
		end -- 1133
		return -- 1135
	end -- 1135
	if self.dogState == "sniff" then -- 1135
		self.dogT = self.dogT - 1 -- 1138
		if self.dogT <= 0 then -- 1138
			self.dogState = "back" -- 1140
		end -- 1140
		return -- 1142
	end -- 1142
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1145
	self.dogX = self.dogX + dir * dog.speed * dt -- 1146
	if math.abs(self.dogX - dog.x0) < 2 then -- 1146
		self.dogX = dog.x0 -- 1148
		self.dogState = "patrol" -- 1149
	end -- 1149
end -- 1089
function Play.prototype.caught(self) -- 1153
	self.caughtT = 1 -- 1154
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1155
end -- 1153
function Play.prototype.recoverFromCaught(self) -- 1159
	local p = self.player -- 1160
	p.x = self.ox + 140 -- 1161
	p.y = 0 -- 1162
	p.vy = 0 -- 1163
	p.vx = 0 -- 1164
	p.onGround = true -- 1165
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1165
		self.scavX = self.room.scavenger.x0 -- 1167
		self.scavState = "patrol" -- 1168
		self.scavSee = 0 -- 1169
		self.scavChase = false -- 1170
		self.scavT = 0 -- 1171
	end -- 1171
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1171
		self.dogX = self.room.story.dog.x0 -- 1174
		self.dogState = "patrol" -- 1175
		self.dogT = 0 -- 1176
	end -- 1176
	self.cam.x = p.x -- 1178
	self.cam.y = p.y + CAM_LOOK_UP -- 1179
	self:flashSet("回到安全点", 1.2) -- 1180
end -- 1159
function Play.prototype.updateGate(self) -- 1184
	if self.room.key ~= "checkpoint" then -- 1184
		self.gateOpen = false -- 1186
		return -- 1187
	end -- 1187
	local function inZone(x) -- 1189
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1189
	end -- 1189
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1190
end -- 1184
function Play.prototype.stepEnemies(self, dt, input) -- 1193
	local i = 0 -- 1194
	do -- 1194
		i = 0 -- 1195
		while i < #self.enemies do -- 1195
			local e = self.enemies[i + 1] -- 1196
			if e.hitT > 0 then -- 1196
				e.hitT = e.hitT - dt -- 1198
			end -- 1198
			i = i + 1 -- 1195
		end -- 1195
	end -- 1195
	if self.coveredFlash > 0 then -- 1195
		self.coveredFlash = self.coveredFlash - dt -- 1202
	end -- 1202
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1202
		return -- 1206
	end -- 1206
	do -- 1206
		i = 0 -- 1208
		while i < #self.enemies do -- 1208
			do -- 1208
				local e = self.enemies[i + 1] -- 1209
				if not e.alive then -- 1209
					goto __continue186 -- 1211
				end -- 1211
				if e.warnT > 0 then -- 1211
					e.warnT = e.warnT - 1 -- 1214
					if e.warnT <= 0 then -- 1214
						self:enemyFire(e, input) -- 1216
					end -- 1216
					goto __continue186 -- 1218
				end -- 1218
				if e.fireCd > 0 then -- 1218
					e.fireCd = e.fireCd - 1 -- 1221
					if e.fireCd <= 0 then -- 1221
						e.warnT = WARN_TICKS -- 1223
					end -- 1223
				else -- 1223
					e.warnT = WARN_TICKS -- 1227
				end -- 1227
			end -- 1227
			::__continue186:: -- 1227
			i = i + 1 -- 1208
		end -- 1208
	end -- 1208
end -- 1193
function Play.prototype.enemyFire(self, e, input) -- 1233
	local p = self.player -- 1234
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1234
		self:flashSet("枪声响在远处", 0.4) -- 1236
		e.fireCd = FIRE_COOLDOWN -- 1237
		return -- 1238
	end -- 1238
	local cover = self:blockedByCover(e.x, p) -- 1241
	local hugging = cover ~= nil -- 1242
	self.coverBlocking = hugging -- 1243
	local covered = hugging and input.cover.held -- 1244
	if covered then -- 1244
		self.coveredFlash = 0.5 -- 1246
		self:flashSet("掩体挡下", 0.5) -- 1247
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1248
		e.fireCd = FIRE_COOLDOWN -- 1253
		return -- 1254
	end -- 1254
	self.hp = self.hp - 1 -- 1256
	self:emit("actorHit", { -- 1257
		target = "player", -- 1257
		amount = 1, -- 1257
		hp = self.hp, -- 1257
		maxHp = self.maxHp, -- 1257
		enemyX = e.x -- 1257
	}) -- 1257
	self:flashSet( -- 1258
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1258
		0.7 -- 1258
	) -- 1258
	e.fireCd = FIRE_COOLDOWN -- 1259
	if self.hp <= 0 then -- 1259
		self:gateFailed() -- 1261
	end -- 1261
end -- 1233
function Play.prototype.blockedByCover(self, ex, p) -- 1266
	local b = self:coverAt(p) -- 1267
	if b == nil then -- 1267
		return nil -- 1269
	end -- 1269
	return self:coverGuardsFrom(b, p, ex) and b or nil -- 1271
end -- 1266
function Play.prototype.gateFailed(self) -- 1275
	local ____temp_12 -- 1276
	if self.room.story == nil then -- 1276
		____temp_12 = nil -- 1276
	else -- 1276
		____temp_12 = self.room.story.gate -- 1276
	end -- 1276
	local g = ____temp_12 -- 1276
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1277
	self.hp = self.maxHp -- 1278
	self.gateTick = 0 -- 1279
	self.gateSpawned = 0 -- 1280
	self.enemies = {} -- 1281
	self.gateFailCount = self.gateFailCount + 1 -- 1282
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1284
	self.player.y = 0 -- 1285
	self.player.vy = 0 -- 1286
	self.player.onGround = true -- 1287
	self.player.crouch = false -- 1288
	self.player.h = SOLDIER_H -- 1289
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1290
	self.partner.y = 0 -- 1291
	self.partner.vy = 0 -- 1292
	self.partner.onGround = true -- 1293
	self.cam.x = self.player.x -- 1294
	self.phase = "gate-idle" -- 1295
	self.phaseTick = 0 -- 1296
	self.coverHug = false -- 1297
	self.coverBlocking = false -- 1298
	self.coverEntity = "" -- 1299
	self.gateNeedConfirm = true -- 1300
	self.gateRestartArmed = false -- 1301
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1302
end -- 1275
function Play.prototype.stepInteract(self, dt, input) -- 1305
	local p = self.player -- 1306
	local calmUsed = self.calmConsumed -- 1307
	self.calmConsumed = false -- 1308
	self.focusCart = false -- 1309
	if self.room.key == "outside" then -- 1309
		local c = self.room.cart -- 1311
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1312
		local dy = p.y - c.baseY -- 1313
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1314
	end -- 1314
	self:stepCart(dt, input) -- 1316
	if calmUsed then -- 1316
		self:flashSet("安抚 · 敲两下", 0.8) -- 1320
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1320
		if self.knockT > 0 then -- 1320
			self.knocks = self.knocks + 1 -- 1324
		else -- 1324
			self.knocks = 1 -- 1326
		end -- 1326
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1328
		self.knockT = 1.2 -- 1329
		if self.knocks >= 2 then -- 1329
			self:flashSet("敲两下", 0.8) -- 1331
			self.knocks = 0 -- 1332
		else -- 1332
			self:flashSet("敲一下", 0.5) -- 1334
		end -- 1334
	elseif self.knockT > 0 then -- 1334
		self.knockT = self.knockT - dt -- 1337
		if self.knockT <= 0 then -- 1337
			self.knocks = 0 -- 1339
		end -- 1339
	end -- 1339
	local i = 0 -- 1344
	do -- 1344
		i = 0 -- 1345
		while i < #self.room.marks do -- 1345
			do -- 1345
				local m = self.room.marks[i + 1] -- 1346
				if m.kind ~= 0 then -- 1346
					goto __continue211 -- 1348
				end -- 1348
				local subjects = {self.partner, self.player} -- 1350
				local k = 0 -- 1351
				do -- 1351
					k = 0 -- 1352
					while k < #subjects do -- 1352
						do -- 1352
							local s = subjects[k + 1] -- 1353
							if not s.alive then -- 1353
								goto __continue214 -- 1355
							end -- 1355
							local dx = s.x - m.x -- 1357
							local dy = s.y - m.y -- 1358
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1358
								self.checkpoint = m.x -- 1360
								self.checkpointCartAxle = self.cartAxle -- 1361
								if self.cartDocked then -- 1361
									self:flashSet("检查点 · 车已落窝", 1) -- 1363
								else -- 1363
									self:flashSet("检查点 · 车还没到位", 1) -- 1365
								end -- 1365
							end -- 1365
						end -- 1365
						::__continue214:: -- 1365
						k = k + 1 -- 1352
					end -- 1352
				end -- 1352
			end -- 1352
			::__continue211:: -- 1352
			i = i + 1 -- 1345
		end -- 1345
	end -- 1345
	self:checkCarryGate() -- 1371
end -- 1305
function Play.prototype.stepVillage(self, dt, input) -- 1375
	if self.room.key ~= "village" then -- 1375
		return -- 1377
	end -- 1377
	local p = self.player -- 1379
	local bottle = self.room.bottle -- 1380
	local scav = self.room.scavenger -- 1381
	if not self.hasBottle and bottle ~= nil then -- 1381
		local dx = p.x - bottle.x -- 1385
		local dy = p.y + p.h * 0.5 - bottle.y -- 1386
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1386
			self.hasBottle = true -- 1388
			self:flashSet("拾起瓶子", 0.8) -- 1389
		end -- 1389
	end -- 1389
	if self.hasBottle then -- 1389
		if input.aim.held then -- 1389
			self.aimHold = self.aimHold + dt -- 1396
			if self.aimHold > 1.2 then -- 1396
				self.aimHold = 1.2 -- 1398
			end -- 1398
			local cached = self:bottleEnd() -- 1401
			self.bottleAimX = cached.x -- 1402
			self.bottleAimY = cached.y -- 1403
		elseif input.aim.released then -- 1403
			if self.aimHold < 0.12 then -- 1403
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1407
				self.aimHold = 0 -- 1408
			else -- 1408
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1410
				self:throwBottle(____end.x, ____end.y) -- 1411
				self.aimHold = 0 -- 1412
			end -- 1412
		end -- 1412
	else -- 1412
		self.aimHold = 0 -- 1416
		self.bottleAimX = -1 -- 1417
	end -- 1417
	local fly = self.bottleFly -- 1422
	if fly ~= nil then -- 1422
		fly.t = fly.t + dt -- 1424
		fly.x = fly.x0 + fly.vx * fly.t -- 1425
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1426
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1427
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1427
			self:landBottle(fly) -- 1429
		end -- 1429
	end -- 1429
	if self.bottleLandT > 0 then -- 1429
		self.bottleLandT = self.bottleLandT - dt -- 1433
	end -- 1433
	if scav ~= nil then -- 1433
		self:stepScav(dt, scav) -- 1437
	end -- 1437
	local line = self.room.passLine -- 1440
	if line ~= nil and not self.passed and p.x >= line then -- 1440
		self.passed = true -- 1442
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1443
	end -- 1443
	if self.passed and p.x >= self.ox + 640 then -- 1443
		self:requestRoom("forest", "过第一院出院") -- 1447
		self:flashSet("出院 · 北塔森林", 1.4) -- 1448
	end -- 1448
end -- 1375
function Play.prototype.bottleEnd(self) -- 1453
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1454
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1455
	return {x = aim.x, y = g} -- 1456
end -- 1453
function Play.prototype.throwBottle(self, tx, ty) -- 1460
	local p = self.player -- 1461
	local dir = tx >= p.x and 1 or -1 -- 1463
	p.facing = dir -- 1464
	local x0 = p.x + dir * 10 -- 1465
	local y0 = p.y + p.h * 0.7 -- 1466
	self.bottleTargetX = tx -- 1467
	self.bottleTargetY = ty -- 1468
	self.bottleSurfaceY = ty -- 1469
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1470
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1471
	self.bottleFly = { -- 1472
		x = x0, -- 1472
		y = y0, -- 1472
		x0 = x0, -- 1472
		y0 = y0, -- 1472
		vx = vx, -- 1472
		vy = vy, -- 1472
		t = 0 -- 1472
	} -- 1472
	self.hasBottle = false -- 1473
	self:flashSet("投出", 0.4) -- 1474
	self:emit( -- 1475
		"bottleThrown", -- 1475
		{ -- 1475
			fromX = x0, -- 1476
			fromY = y0, -- 1477
			targetX = tx, -- 1478
			targetY = ty, -- 1479
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1480
		} -- 1480
	) -- 1480
end -- 1460
function Play.prototype.landBottle(self, fly) -- 1485
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1486
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1487
	local s = self.room.scavenger -- 1488
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1489
	self.bottleFly = nil -- 1490
	self.bottleTargetX = -1 -- 1491
	self.bottleTargetY = 0 -- 1492
	self.bottleSurfaceY = -1 -- 1493
	self.bottleLandX = x -- 1494
	self.bottleLandY = y -- 1495
	self.bottleLandT = 0.9 -- 1496
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1497
	self:hearBottle(x) -- 1498
end -- 1485
function Play.prototype.hearBottle(self, x) -- 1502
	local s = self.room.scavenger -- 1503
	if s == nil then -- 1503
		return -- 1505
	end -- 1505
	if math.abs(x - self.scavX) > s.range then -- 1505
		self:flashSet("落地 · 他没听见", 0.6) -- 1508
		return -- 1509
	end -- 1509
	self.scavState = "turn" -- 1511
	self.scavT = s.hearTicks -- 1512
	self.scavTargetX = x -- 1513
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1514
end -- 1502
function Play.prototype.stepScav(self, dt, s) -- 1518
	if self.scavState == "chase" then -- 1518
		return -- 1521
	end -- 1521
	if self.scavState == "turn" then -- 1521
		self.scavT = self.scavT - 1 -- 1524
		if self.scavT <= 0 then -- 1524
			self.scavState = "walk" -- 1526
		end -- 1526
		return -- 1528
	end -- 1528
	if self.scavState == "walk" then -- 1528
		local d = self.scavTargetX - self.scavX -- 1531
		if math.abs(d) < 4 then -- 1531
			self.scavState = "stall" -- 1533
			self.scavT = s.stallTicks -- 1534
			return -- 1535
		end -- 1535
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1537
		return -- 1538
	end -- 1538
	if self.scavState == "stall" then -- 1538
		self.scavT = self.scavT - 1 -- 1541
		if self.scavT <= 0 then -- 1541
			self.scavState = "back" -- 1543
		end -- 1543
		return -- 1545
	end -- 1545
	if self.scavState == "back" then -- 1545
		local home = math.max( -- 1548
			s.x0, -- 1548
			math.min(s.x1, self.scavX) -- 1548
		) -- 1548
		if math.abs(home - self.scavX) < 2 then -- 1548
			self.scavState = "patrol" -- 1550
			return -- 1551
		end -- 1551
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1553
		return -- 1554
	end -- 1554
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1556
	if self.scavX >= s.x1 then -- 1556
		self.scavX = s.x1 -- 1558
		self.scavDir = -1 -- 1559
	elseif self.scavX <= s.x0 then -- 1559
		self.scavX = s.x0 -- 1561
		self.scavDir = 1 -- 1562
	end -- 1562
end -- 1518
function Play.prototype.stepCart(self, dt, input) -- 1570
	local p = self.player -- 1571
	local c = self.room.cart -- 1572
	local handleX = self.cartAxle + c.handleOffset -- 1573
	if self.gripping then -- 1573
		if not input.interact.held then -- 1573
			self.gripping = false -- 1577
			self:flashSet("松开车把", 0.4) -- 1578
			return -- 1579
		end -- 1579
	else -- 1579
		if not input.interact.pressed then -- 1579
			return -- 1583
		end -- 1583
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1583
			return -- 1586
		end -- 1586
		self.gripping = true -- 1588
		self:flashSet("握住车把", 0.4) -- 1589
		return -- 1590
	end -- 1590
	if self.cartDocked then -- 1590
		return -- 1594
	end -- 1594
	local dir = input.moveX -- 1596
	if dir == 0 then -- 1596
		return -- 1598
	end -- 1598
	local lo = math.min(c.startX, c.endX) -- 1600
	local hi = math.max(c.startX, c.endX) -- 1601
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1602
	if next < lo then -- 1602
		next = lo -- 1604
	end -- 1604
	if next > hi then -- 1604
		next = hi -- 1607
	end -- 1607
	local delta = next - self.cartAxle -- 1609
	if delta == 0 then -- 1609
		return -- 1611
	end -- 1611
	self.cartAxle = next -- 1613
	p.x = p.x + delta -- 1614
	p.facing = dir > 0 and 1 or -1 -- 1615
	self:slideX(p, 0) -- 1616
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1616
		self.gripping = false -- 1618
		self:flashSet("跟不上了，脱手", 0.6) -- 1619
		return -- 1620
	end -- 1620
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1620
		self.cartDocked = true -- 1623
		self.gripping = false -- 1624
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1625
		self:flashSet("车轮落窝", 1.2) -- 1626
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1626
		self:flashSet("车轮回到起点", 0.5) -- 1628
	end -- 1628
end -- 1570
function Play.prototype.requestRoom(self, key, reason) -- 1636
	self.wantRoom = key -- 1637
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1638
end -- 1636
function Play.prototype.checkCarryGate(self) -- 1645
	if self.room.key == "checkpoint" then -- 1645
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1645
			self.carryCartAxle = self.cartAxle -- 1648
			self.carryCartDocked = self.cartDocked -- 1649
			self:requestRoom("gate", "检查站出口") -- 1650
			self:flashSet("出检查站 · 城门", 1.2) -- 1651
		end -- 1651
		return -- 1653
	end -- 1653
	if self.room.key == "outside" then -- 1653
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1653
			self.carryCartAxle = self.cartAxle -- 1659
			self.carryCartDocked = self.cartDocked -- 1660
			self:requestRoom("village", "墙根走完") -- 1661
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1662
		end -- 1662
	end -- 1662
end -- 1645
function Play.prototype.aimAt(self, wx, wy) -- 1669
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1670
	self.aimX = s.x -- 1671
	self.aimY = s.y -- 1672
end -- 1669
function Play.prototype.shoot(self, a) -- 1675
	local ox = a.x + a.facing * 8 -- 1676
	local oy = a.y + a.h * 0.72 -- 1677
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1679
	local dx = aim.x - ox -- 1680
	local dy = aim.y - oy -- 1681
	local len = math.sqrt(dx * dx + dy * dy) -- 1682
	if len < 0.001 then -- 1682
		dx = a.facing -- 1684
		dy = 0 -- 1685
	else -- 1685
		dx = dx / len -- 1687
		dy = dy / len -- 1688
	end -- 1688
	if dx ~= 0 then -- 1688
		a.facing = dx > 0 and 1 or -1 -- 1691
	end -- 1691
	local hitEnemy = self:raycast( -- 1694
		ox, -- 1694
		oy, -- 1694
		dx, -- 1694
		dy, -- 1694
		true -- 1694
	) -- 1694
	local hitWall = self:raycast( -- 1695
		ox, -- 1695
		oy, -- 1695
		dx, -- 1695
		dy, -- 1695
		false -- 1695
	) -- 1695
	local tEnemy = hitEnemy.t -- 1696
	local tWall = hitWall.t -- 1697
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1698
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1699
	self.trace = { -- 1701
		x0 = ox, -- 1701
		y0 = oy, -- 1701
		x1 = ox + dx * t, -- 1701
		y1 = oy + dy * t, -- 1701
		hit = hit -- 1701
	} -- 1701
	self.traceT = 0.12 -- 1702
	self:applyFireDanger(ox) -- 1703
	if hit then -- 1703
		local i = hitEnemy.index -- 1705
		local e = self.enemies[i + 1] -- 1706
		e.alive = false -- 1707
		e.hitT = 0.4 -- 1708
		self:flashSet("命中", 0.6) -- 1709
	else -- 1709
		self:flashSet("打空", 0.35) -- 1711
	end -- 1711
	self:emit("shotResolved", { -- 1713
		hit = hit, -- 1714
		enemyIndex = hit and hitEnemy.index or -1, -- 1715
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1716
		aimX = aim.x, -- 1717
		aimY = aim.y, -- 1718
		impactX = ox + dx * t, -- 1719
		impactY = oy + dy * t -- 1720
	}) -- 1720
end -- 1675
function Play.prototype.applyFireDanger(self, shotX) -- 1725
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1725
		return -- 1727
	end -- 1727
	local dangerX = shotX -- 1729
	local best = -1 -- 1730
	local bestD = 1000000000 -- 1731
	local i = 0 -- 1732
	do -- 1732
		i = 0 -- 1733
		while i < #self.enemies do -- 1733
			do -- 1733
				local e = self.enemies[i + 1] -- 1734
				if not e.alive then -- 1734
					goto __continue284 -- 1736
				end -- 1736
				local d = math.abs(e.x - self.partner.x) -- 1738
				if d < bestD then -- 1738
					bestD = d -- 1740
					best = i -- 1741
				end -- 1741
			end -- 1741
			::__continue284:: -- 1741
			i = i + 1 -- 1733
		end -- 1733
	end -- 1733
	if best >= 0 then -- 1733
		dangerX = self.enemies[best + 1].x -- 1745
	end -- 1745
	local exposed = self:childExposed(dangerX) -- 1747
	local before = self.escort.fear -- 1748
	local dangerId = self.nextDangerId -- 1749
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1750
	self.nextDangerId = self.nextDangerId + 1 -- 1751
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1752
	if after > before then -- 1752
		self:flashSet( -- 1754
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1754
			1 -- 1754
		) -- 1754
	elseif not exposed then -- 1754
		self:flashSet("枪声没够到她", 0.5) -- 1756
	end -- 1756
end -- 1725
function Play.prototype.childExposed(self, dangerX) -- 1761
	local c = self.partner -- 1762
	if not c.alive then -- 1762
		return false -- 1764
	end -- 1764
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1764
		return false -- 1767
	end -- 1767
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1767
		return false -- 1770
	end -- 1770
	local toDanger = dangerX - c.x -- 1772
	local toPlayer = self.player.x - c.x -- 1773
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1773
		return false -- 1775
	end -- 1775
	return true -- 1777
end -- 1761
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1781
	local best = -1 -- 1782
	local bestI = -1 -- 1783
	local i = 0 -- 1784
	if enemies then -- 1784
		do -- 1784
			i = 0 -- 1786
			while i < #self.enemies do -- 1786
				do -- 1786
					local e = self.enemies[i + 1] -- 1787
					if not e.alive then -- 1787
						goto __continue298 -- 1789
					end -- 1789
					local t = hitBox( -- 1791
						ox, -- 1791
						oy, -- 1791
						dx, -- 1791
						dy, -- 1791
						e.x - e.w / 2, -- 1791
						e.x + e.w / 2, -- 1791
						e.y, -- 1791
						e.y + e.h -- 1791
					) -- 1791
					if t >= 0 and (best < 0 or t < best) then -- 1791
						best = t -- 1793
						bestI = i -- 1794
					end -- 1794
				end -- 1794
				::__continue298:: -- 1794
				i = i + 1 -- 1786
			end -- 1786
		end -- 1786
		return {t = best, index = bestI} -- 1797
	end -- 1797
	do -- 1797
		i = 0 -- 1799
		while i < #self.boxes do -- 1799
			local b = self.boxes[i + 1] -- 1800
			local t = hitBox( -- 1801
				ox, -- 1801
				oy, -- 1801
				dx, -- 1801
				dy, -- 1801
				b.x0, -- 1801
				b.x1, -- 1801
				b.y0, -- 1801
				b.y1 -- 1801
			) -- 1801
			if t >= 0 and (best < 0 or t < best) then -- 1801
				best = t -- 1803
			end -- 1803
			i = i + 1 -- 1799
		end -- 1799
	end -- 1799
	if dy < 0 then -- 1799
		local t = (0 - oy) / dy -- 1808
		if t >= 0 and (best < 0 or t < best) then -- 1808
			best = t -- 1810
		end -- 1810
	end -- 1810
	return {t = best, index = -1} -- 1813
end -- 1781
function Play.prototype.slideX(self, a, dx) -- 1817
	local nx = a.x + dx -- 1818
	local half = a.w / 2 -- 1819
	local room = self.room -- 1820
	nx = math.max( -- 1821
		room.minX + half, -- 1821
		math.min(room.maxX - half, nx) -- 1821
	) -- 1821
	local i = 0 -- 1822
	do -- 1822
		i = 0 -- 1823
		while i < #self.boxes do -- 1823
			do -- 1823
				local b = self.boxes[i + 1] -- 1824
				if b.passable == true then -- 1824
					goto __continue308 -- 1826
				end -- 1826
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1826
					goto __continue308 -- 1829
				end -- 1829
				if nx + half > b.x0 and nx - half < b.x1 then -- 1829
					if a.x <= b.x0 then -- 1829
						nx = b.x0 - half -- 1833
					elseif a.x >= b.x1 then -- 1833
						nx = b.x1 + half -- 1835
					else -- 1835
						nx = a.x -- 1837
					end -- 1837
				end -- 1837
			end -- 1837
			::__continue308:: -- 1837
			i = i + 1 -- 1823
		end -- 1823
	end -- 1823
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1823
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1845
		local bx0 = self.cartAxle - CART_HALF -- 1846
		local bx1 = self.cartAxle + CART_HALF -- 1847
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1847
			if a.x <= bx0 then -- 1847
				nx = bx0 - half -- 1850
			elseif a.x >= bx1 then -- 1850
				nx = bx1 + half -- 1852
			else -- 1852
				nx = a.x -- 1854
			end -- 1854
		end -- 1854
	end -- 1854
	local arch = room.arch -- 1862
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1862
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1864
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1864
			if a.x <= arch.x0 then -- 1864
				nx = arch.x0 - half -- 1867
			elseif a.x >= arch.x1 then -- 1867
				nx = arch.x1 + half -- 1869
			end -- 1869
		end -- 1869
	end -- 1869
	a.x = nx -- 1873
end -- 1817
function Play.prototype.fallY(self, a, dt) -- 1877
	a.vy = a.vy - ____exports.GRAVITY * dt -- 1878
	if a.vy < -900 then -- 1878
		a.vy = -900 -- 1880
	end -- 1880
	local ny = a.y + a.vy * dt -- 1882
	local half = a.w / 2 -- 1883
	if a.vy <= 0 then -- 1883
		local reach = a.onGround and STEP_UP or 0 -- 1886
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1887
		if ny <= ground then -- 1887
			ny = ground -- 1889
			a.vy = 0 -- 1890
			a.onGround = true -- 1891
		else -- 1891
			a.onGround = false -- 1893
		end -- 1893
	else -- 1893
		a.onGround = false -- 1896
		local i = 0 -- 1897
		do -- 1897
			i = 0 -- 1898
			while i < #self.boxes do -- 1898
				do -- 1898
					local b = self.boxes[i + 1] -- 1899
					if b.passable == true then -- 1899
						goto __continue331 -- 1901
					end -- 1901
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1901
						goto __continue331 -- 1904
					end -- 1904
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1904
						ny = b.y0 - a.h -- 1907
						a.vy = 0 -- 1908
					end -- 1908
				end -- 1908
				::__continue331:: -- 1908
				i = i + 1 -- 1898
			end -- 1898
		end -- 1898
	end -- 1898
	a.y = ny -- 1912
end -- 1877
function Play.prototype.groundAt(self, x, ceiling, half) -- 1916
	local g = -9999 -- 1917
	local i = 0 -- 1918
	do -- 1918
		i = 0 -- 1919
		while i < #self.floors do -- 1919
			local f = self.floors[i + 1] -- 1920
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1920
				g = f.y1 -- 1922
			end -- 1922
			i = i + 1 -- 1919
		end -- 1919
	end -- 1919
	do -- 1919
		i = 0 -- 1925
		while i < #self.boxes do -- 1925
			local b = self.boxes[i + 1] -- 1926
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1926
				g = b.y1 -- 1928
			end -- 1928
			i = i + 1 -- 1925
		end -- 1925
	end -- 1925
	return g -- 1931
end -- 1916
function Play.prototype.updateCamera(self, dt) -- 1934
	local p = self.player -- 1935
	local tx = p.x + p.facing * 30 -- 1936
	local ty = p.y + CAM_LOOK_UP -- 1937
	local k = math.min(1, CAM_FOLLOW * dt) -- 1938
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1939
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1940
end -- 1934
function Play.prototype.clampCamera(self, w, h) -- 1944
	local room = self.room -- 1945
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1946
	local spanX = room.maxX - room.minX -- 1947
	if spanX <= halfW * 2 then -- 1947
		self.cam.x = (room.minX + room.maxX) / 2 -- 1949
	else -- 1949
		self.cam.x = math.max( -- 1951
			room.minX + halfW, -- 1951
			math.min(room.maxX - halfW, self.cam.x) -- 1951
		) -- 1951
	end -- 1951
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1954
	local spanY = room.height -- 1955
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1956
	if spanY <= halfH * 2 then -- 1956
		self.cam.y = camY -- 1958
	else -- 1958
		self.cam.y = math.max( -- 1960
			camY, -- 1960
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 1960
		) -- 1960
	end -- 1960
end -- 1944
function Play.prototype.flashSet(self, text, t) -- 1964
	self.flash = text -- 1965
	self.flashT = t -- 1966
end -- 1964
function Play.prototype.statusText(self) -- 1970
	local p = self.player -- 1971
	local parts = {} -- 1972
	local who = self.childMode and "小满" or "周戍" -- 1973
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 1974
	if self.room.key == "prologue" then -- 1974
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1977
		if self.phase == "prologue-wait" then -- 1977
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 1979
		elseif self.phase == "prologue-give" then -- 1979
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 1981
		else -- 1981
			parts[#parts + 1] = "跟随" -- 1983
		end -- 1983
		if self.paused then -- 1983
			parts[#parts + 1] = "已暂停" -- 1986
		end -- 1986
		return table.concat(parts, " · ") -- 1988
	end -- 1988
	if self.room.key == "street" then -- 1988
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 1991
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 1992
		if self.paused then -- 1992
			parts[#parts + 1] = "已暂停" -- 1994
		end -- 1994
		return table.concat(parts, " · ") -- 1996
	end -- 1996
	if self.room.key == "gate" then -- 1996
		local ____temp_13 -- 1999
		if self.room.story == nil then -- 1999
			____temp_13 = nil -- 1999
		else -- 1999
			____temp_13 = self.room.story.gate -- 1999
		end -- 1999
		local g = ____temp_13 -- 1999
		if g ~= nil then -- 1999
			parts[#parts + 1] = self:gateLabel() -- 2001
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2002
				0, -- 2003
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2003
			))) .. " 秒" -- 2003
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2004
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2005
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2006
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2007
			if self.gateFailCount > 0 then -- 2007
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2009
			end -- 2009
			if self.flash ~= "" then -- 2009
				parts[#parts + 1] = self.flash -- 2012
			end -- 2012
		end -- 2012
		if self.paused then -- 2012
			parts[#parts + 1] = "已暂停" -- 2016
		end -- 2016
		return table.concat(parts, " · ") -- 2018
	end -- 2018
	if self.room.key == "forest" then -- 2018
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2021
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2022
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2023
		if self.caughtT > 0 then -- 2023
			parts[#parts + 1] = "复位中" -- 2025
		end -- 2025
		if self.paused then -- 2025
			parts[#parts + 1] = "已暂停" -- 2028
		end -- 2028
		return table.concat(parts, " · ") -- 2030
	end -- 2030
	if self.room.key == "tower" then -- 2030
		if self.phase == "tower-wait" then -- 2030
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2034
		elseif self.phase == "tower-knock" then -- 2034
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2036
		elseif self.phase == "tower-given" then -- 2036
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2038
		else -- 2038
			parts[#parts + 1] = "片尾" -- 2040
		end -- 2040
		if self.paused then -- 2040
			parts[#parts + 1] = "已暂停" -- 2043
		end -- 2043
		return table.concat(parts, " · ") -- 2045
	end -- 2045
	if self.room.key == "village" then -- 2045
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2048
		if self.hasBottle then -- 2048
			parts[#parts + 1] = "有瓶" -- 2050
		elseif self.bottleFly ~= nil then -- 2050
			parts[#parts + 1] = "瓶在飞" -- 2052
		else -- 2052
			parts[#parts + 1] = "空手" -- 2054
		end -- 2054
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2056
		if self.scavChase then -- 2056
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2058
		end -- 2058
		if self.passed then -- 2058
			parts[#parts + 1] = "已过通行线" -- 2061
		end -- 2061
		if self.paused then -- 2061
			parts[#parts + 1] = "已暂停" -- 2064
		end -- 2064
		return table.concat(parts, " · ") -- 2066
	end -- 2066
	local isChild = self.childMode -- 2069
	if isChild then -- 2069
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2071
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2072
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2073
	else -- 2073
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2075
		if p.rollT > 0 then -- 2075
			parts[#parts + 1] = "翻滚中" -- 2077
		end -- 2077
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2079
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2080
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2081
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2082
	end -- 2082
	if self.checkpoint >= 0 then -- 2082
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2085
	end -- 2085
	if self.paused then -- 2085
		parts[#parts + 1] = "已暂停" -- 2088
	end -- 2088
	return table.concat(parts, " · ") -- 2090
end -- 1970
function Play.prototype.aliveEnemies(self) -- 2094
	local n = 0 -- 2095
	local i = 0 -- 2096
	do -- 2096
		i = 0 -- 2097
		while i < #self.enemies do -- 2097
			if self.enemies[i + 1].alive then -- 2097
				n = n + 1 -- 2099
			end -- 2099
			i = i + 1 -- 2097
		end -- 2097
	end -- 2097
	return n -- 2102
end -- 2094
function Play.prototype.threatened(self) -- 2107
	do -- 2107
		local i = 0 -- 2108
		while i < #self.enemies do -- 2108
			local e = self.enemies[i + 1] -- 2109
			if e.alive and e.warnT > 0 then -- 2109
				return true -- 2111
			end -- 2111
			i = i + 1 -- 2108
		end -- 2108
	end -- 2108
	return false -- 2114
end -- 2107
function Play.prototype.gateSecondsLeft(self) -- 2117
	local ____temp_14 -- 2118
	if self.room.story == nil then -- 2118
		____temp_14 = nil -- 2118
	else -- 2118
		____temp_14 = self.room.story.gate -- 2118
	end -- 2118
	local g = ____temp_14 -- 2118
	if g == nil then -- 2118
		return 0 -- 2120
	end -- 2120
	return math.max( -- 2122
		0, -- 2122
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2122
	) -- 2122
end -- 2117
function Play.prototype.gateLabel(self) -- 2125
	if self.phase == "gate-idle" then -- 2125
		return "待就位" -- 2127
	end -- 2127
	if self.phase == "gate-hold" then -- 2127
		return "守点中" -- 2130
	end -- 2130
	if self.phase == "gate-send" then -- 2130
		return "送别" -- 2133
	end -- 2133
	if self.phase == "gate-count" then -- 2133
		return "数数 " .. tostring(self.countTick) -- 2136
	end -- 2136
	return "她走" -- 2138
end -- 2125
function Play.prototype.dogLabel(self) -- 2142
	if self.dogState == "ear" then -- 2142
		return "转耳" -- 2144
	end -- 2144
	if self.dogState == "chase" then -- 2144
		return "追" -- 2147
	end -- 2147
	if self.dogState == "sniff" then -- 2147
		return "停" -- 2150
	end -- 2150
	if self.dogState == "back" then -- 2150
		return "回线" -- 2153
	end -- 2153
	return "巡逻" -- 2155
end -- 2142
function Play.prototype.doorXOf(self) -- 2158
	local ____temp_15 -- 2159
	if self.room.story == nil then -- 2159
		____temp_15 = nil -- 2159
	else -- 2159
		____temp_15 = self.room.story.tower -- 2159
	end -- 2159
	local t = ____temp_15 -- 2159
	return t == nil and 0 or t.doorX -- 2160
end -- 2158
function Play.prototype.scavLabel(self) -- 2164
	if self.scavState == "chase" then -- 2164
		return "追" -- 2166
	end -- 2166
	if self.scavState == "turn" then -- 2166
		return "转头" -- 2169
	end -- 2169
	if self.scavState == "walk" then -- 2169
		return "赶来" -- 2172
	end -- 2172
	if self.scavState == "stall" then -- 2172
		return "停住" -- 2175
	end -- 2175
	if self.scavState == "back" then -- 2175
		return "回位" -- 2178
	end -- 2178
	return "巡逻" -- 2180
end -- 2164
function Play.prototype.hintText(self) -- 2184
	if self.paused then -- 2184
		return "Esc 继续 · R 重置" -- 2186
	end -- 2186
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2186
		if self:threatened() then -- 2186
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2192
		end -- 2192
		if self.coverHug then -- 2192
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2195
		end -- 2195
		if self.coverNear then -- 2195
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2198
		end -- 2198
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2200
	end -- 2200
	if self.flash ~= "" then -- 2200
		return self.flash -- 2203
	end -- 2203
	if self.room.key == "prologue" then -- 2203
		if self.phase == "prologue-wait" then -- 2203
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2207
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2208
		end -- 2208
		if self.phase == "prologue-give" then -- 2208
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2211
		end -- 2211
		return "她跟着你了 · 两人一起走到门口 680" -- 2213
	end -- 2213
	if self.room.key == "street" then -- 2213
		if self:aliveEnemies() > 0 then -- 2213
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2217
		end -- 2217
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2219
	end -- 2219
	if self.room.key == "gate" then -- 2219
		local ____temp_16 -- 2222
		if self.room.story == nil then -- 2222
			____temp_16 = nil -- 2222
		else -- 2222
			____temp_16 = self.room.story.gate -- 2222
		end -- 2222
		local g = ____temp_16 -- 2222
		if g ~= nil then -- 2222
			if self.phase == "gate-idle" then -- 2222
				if self.gateNeedConfirm then -- 2222
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2226
				end -- 2226
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2228
			end -- 2228
			if self.phase == "gate-hold" then -- 2228
				if self.coveredFlash > 0 then -- 2228
					return "掩体挡下了这一枪 · 别露头" -- 2232
				end -- 2232
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2234
			end -- 2234
			if self.phase == "gate-send" then -- 2234
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2237
			end -- 2237
			if self.phase == "gate-count" then -- 2237
				if self.countTick >= 1440 then -- 2237
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2241
				end -- 2241
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2243
			end -- 2243
			return "她自己走 · 跟着出城门 1120" -- 2245
		end -- 2245
	end -- 2245
	if self.room.key == "forest" then -- 2245
		if self.dogState == "chase" then -- 2245
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2250
		end -- 2250
		if self.dogState == "ear" then -- 2250
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2253
		end -- 2253
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2255
	end -- 2255
	if self.room.key == "tower" then -- 2255
		if self.phase == "tower-wait" then -- 2255
			return "走到门前 445 点一次 E 敲两下" -- 2259
		end -- 2259
		if self.phase == "tower-knock" then -- 2259
			return "敲两下 · 等门开" -- 2262
		end -- 2262
		if self.phase == "tower-given" then -- 2262
			return "递交针套和纸条 · 看登记簿最后一行" -- 2265
		end -- 2265
		return "片尾 · 点 E 再玩一次，回到序章" -- 2267
	end -- 2267
	if self.room.key == "village" then -- 2267
		if self.bottleFly ~= nil then -- 2267
			return "等瓶子落地 · 触地才发声" -- 2271
		end -- 2271
		if self.hasBottle then -- 2271
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2274
		end -- 2274
		if self.passed then -- 2274
			return "已过第一院 · R 重置可再来一遍" -- 2277
		end -- 2277
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2279
	end -- 2279
	if self.room.key == "outside" then -- 2279
		if self.focusCart then -- 2279
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2283
		end -- 2283
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2285
	end -- 2285
	if self.escort.state == "frozen" then -- 2285
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2285
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2289
		end -- 2289
		return "小满吓住了 · 走过去，靠近再点 E" -- 2291
	end -- 2291
	if self.escort.state == "calming" then -- 2291
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2294
	end -- 2294
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2296
end -- 2184
function Play.prototype.draw(self, draw, w, h) -- 2301
	self.viewW = w -- 2302
	self.viewH = h -- 2303
	self.view = ____exports.computeViewport(w, h) -- 2304
	self:clampCamera(w, h) -- 2305
	draw:clear() -- 2306
	draw:drawRect( -- 2308
		Rect(0, 0, w, h), -- 2308
		BG_VOID -- 2308
	) -- 2308
	local box = self:canvasRect(w, h) -- 2309
	draw:drawRect(box, BG_FAR) -- 2310
	draw:drawRect( -- 2311
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2311
		BG_MID -- 2311
	) -- 2311
	self:drawFloors(draw, w, h) -- 2313
	self:drawSolids(draw, w, h) -- 2314
	self:drawZones(draw, w, h) -- 2315
	self:drawArch(draw, w, h) -- 2316
	self:drawCart(draw, w, h) -- 2317
	self:drawActors(draw, w, h) -- 2318
	self:drawTrace(draw, w, h) -- 2319
	self:drawAim(draw, w, h) -- 2320
end -- 2301
function Play.prototype.canvasRect(self, w, h) -- 2324
	local v = self.view -- 2325
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2326
end -- 2324
function Play.prototype.px(self, n) -- 2330
	return n * self.view.zoom -- 2331
end -- 2330
function Play.prototype.sx(self, wx, w) -- 2335
	local v = self.view -- 2336
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2337
	return v.ox + lx * v.zoom -- 2338
end -- 2335
function Play.prototype.sy(self, wy, h) -- 2342
	local v = self.view -- 2343
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2344
	return v.oy + ly * v.zoom -- 2345
end -- 2342
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2348
	local px0 = self:sx(x0, w) -- 2349
	local px1 = self:sx(x1, w) -- 2350
	local py0 = self:sy(y0, h) -- 2351
	local py1 = self:sy(y1, h) -- 2352
	if px1 <= px0 or py1 <= py0 then -- 2352
		return -- 2354
	end -- 2354
	draw:drawRect( -- 2356
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2356
		color -- 2356
	) -- 2356
end -- 2348
function Play.prototype.drawFloors(self, draw, w, h) -- 2359
	local i = 0 -- 2360
	do -- 2360
		i = 0 -- 2361
		while i < #self.room.floors do -- 2361
			local f = self.room.floors[i + 1] -- 2362
			local y = self:sy(f.y, h) -- 2363
			local x0 = self:sx(f.x0, w) -- 2364
			local x1 = self:sx(f.x1, w) -- 2365
			local deck = self:px(5) -- 2366
			draw:drawRect( -- 2367
				Rect(x0, y - deck, x1 - x0, deck), -- 2367
				FLOOR_DECK -- 2367
			) -- 2367
			draw:drawSegment( -- 2368
				Vec2(x0, y), -- 2368
				Vec2(x1, y), -- 2368
				self:px(1), -- 2368
				GROUND -- 2368
			) -- 2368
			i = i + 1 -- 2361
		end -- 2361
	end -- 2361
end -- 2359
function Play.prototype.drawSolids(self, draw, w, h) -- 2372
	local i = 0 -- 2373
	do -- 2373
		i = 0 -- 2374
		while i < #self.boxes do -- 2374
			do -- 2374
				local b = self.boxes[i + 1] -- 2375
				if b.y0 < -4 and b.y1 <= 96 then -- 2375
					draw:drawSegment( -- 2378
						Vec2( -- 2378
							self:sx(b.x0, w), -- 2378
							self:sy(b.y1, h) -- 2378
						), -- 2378
						Vec2( -- 2378
							self:sx(b.x1, w), -- 2378
							self:sy(b.y1, h) -- 2378
						), -- 2378
						self:px(1), -- 2378
						GROUND -- 2378
					) -- 2378
					goto __continue459 -- 2379
				end -- 2379
				self:drawBox( -- 2381
					draw, -- 2381
					w, -- 2381
					h, -- 2381
					b.x0, -- 2381
					b.x1, -- 2381
					b.y0, -- 2381
					b.y1, -- 2381
					SOLID_FILL -- 2381
				) -- 2381
				draw:drawSegment( -- 2382
					Vec2( -- 2382
						self:sx(b.x0, w), -- 2382
						self:sy(b.y1, h) -- 2382
					), -- 2382
					Vec2( -- 2382
						self:sx(b.x1, w), -- 2382
						self:sy(b.y1, h) -- 2382
					), -- 2382
					self:px(1), -- 2382
					SOLID_EDGE -- 2382
				) -- 2382
			end -- 2382
			::__continue459:: -- 2382
			i = i + 1 -- 2374
		end -- 2374
	end -- 2374
end -- 2372
function Play.prototype.drawZones(self, draw, w, h) -- 2386
	local i = 0 -- 2387
	do -- 2387
		i = 0 -- 2388
		while i < #self.room.zones do -- 2388
			local z = self.room.zones[i + 1] -- 2389
			local fill = DANGER -- 2390
			local line = DANGER_LINE -- 2391
			if z.tint == 2 then -- 2391
				fill = SOFT -- 2393
				line = SOFT_LINE -- 2394
			elseif z.tint == 3 then -- 2394
				fill = BRICK -- 2396
				line = BRICK_LINE -- 2397
			elseif z.tint == 4 then -- 2397
				fill = PASS -- 2399
				line = PASS_LINE -- 2400
			end -- 2400
			self:drawBox( -- 2402
				draw, -- 2402
				w, -- 2402
				h, -- 2402
				z.x0, -- 2402
				z.x1, -- 2402
				z.y, -- 2402
				z.y + z.h, -- 2402
				fill -- 2402
			) -- 2402
			draw:drawSegment( -- 2403
				Vec2( -- 2403
					self:sx(z.x0, w), -- 2403
					self:sy(z.y, h) -- 2403
				), -- 2403
				Vec2( -- 2403
					self:sx(z.x0, w), -- 2403
					self:sy(z.y + z.h, h) -- 2403
				), -- 2403
				self:px(1), -- 2403
				line -- 2403
			) -- 2403
			draw:drawSegment( -- 2404
				Vec2( -- 2404
					self:sx(z.x1, w), -- 2404
					self:sy(z.y, h) -- 2404
				), -- 2404
				Vec2( -- 2404
					self:sx(z.x1, w), -- 2404
					self:sy(z.y + z.h, h) -- 2404
				), -- 2404
				self:px(1), -- 2404
				line -- 2404
			) -- 2404
			i = i + 1 -- 2388
		end -- 2388
	end -- 2388
end -- 2386
function Play.prototype.drawArch(self, draw, w, h) -- 2408
	local a = self.room.arch -- 2409
	if a.h <= 0 then -- 2409
		return -- 2411
	end -- 2411
	self:drawBox( -- 2413
		draw, -- 2413
		w, -- 2413
		h, -- 2413
		a.x0, -- 2413
		a.x1, -- 2413
		a.y, -- 2413
		a.y + a.h, -- 2413
		HOLE_FILL -- 2413
	) -- 2413
	draw:drawSegment( -- 2414
		Vec2( -- 2414
			self:sx(a.x0, w), -- 2414
			self:sy(a.y + a.h, h) -- 2414
		), -- 2414
		Vec2( -- 2414
			self:sx(a.x1, w), -- 2414
			self:sy(a.y + a.h, h) -- 2414
		), -- 2414
		self:px(1), -- 2414
		SOLID_EDGE -- 2414
	) -- 2414
	draw:drawSegment( -- 2415
		Vec2( -- 2415
			self:sx(a.x0, w), -- 2415
			self:sy(a.y, h) -- 2415
		), -- 2415
		Vec2( -- 2415
			self:sx(a.x0, w), -- 2415
			self:sy(a.y + a.h, h) -- 2415
		), -- 2415
		self:px(1), -- 2415
		SOLID_EDGE -- 2415
	) -- 2415
	draw:drawSegment( -- 2416
		Vec2( -- 2416
			self:sx(a.x1, w), -- 2416
			self:sy(a.y, h) -- 2416
		), -- 2416
		Vec2( -- 2416
			self:sx(a.x1, w), -- 2416
			self:sy(a.y + a.h, h) -- 2416
		), -- 2416
		self:px(1), -- 2416
		SOLID_EDGE -- 2416
	) -- 2416
end -- 2408
function Play.prototype.drawCart(self, draw, w, h) -- 2419
	local c = self.room.cart -- 2420
	if c.bodyW <= 0 then -- 2420
		return -- 2422
	end -- 2422
	drawCartShape( -- 2424
		draw, -- 2424
		self, -- 2424
		w, -- 2424
		h, -- 2424
		c, -- 2424
		self.cartAxle -- 2424
	) -- 2424
	draw:drawRect( -- 2425
		Rect( -- 2425
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2425
			self:sy(c.baseY + 40, h), -- 2425
			self:px(2), -- 2425
			self:px(40) -- 2425
		), -- 2425
		STAND -- 2425
	) -- 2425
end -- 2419
function Play.prototype.drawActors(self, draw, w, h) -- 2428
	local p = self.player -- 2429
	local isChild = self.childMode -- 2430
	if p.covered then -- 2430
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2433
		draw:drawSegment( -- 2434
			Vec2( -- 2434
				self:sx(edge, w), -- 2434
				self:sy(p.y + 8, h) -- 2434
			), -- 2434
			Vec2( -- 2434
				self:sx(edge, w), -- 2434
				self:sy(p.y + p.h * 0.62, h) -- 2434
			), -- 2434
			self:px(2), -- 2434
			STAND -- 2434
		) -- 2434
		draw:drawSegment( -- 2436
			Vec2( -- 2436
				self:sx(p.x - 8, w), -- 2436
				self:sy(p.y + p.h + 3, h) -- 2436
			), -- 2436
			Vec2( -- 2436
				self:sx(p.x + 8, w), -- 2436
				self:sy(p.y + p.h + 3, h) -- 2436
			), -- 2436
			self:px(2), -- 2436
			STAND -- 2436
		) -- 2436
	elseif self.coverNear and not isChild then -- 2436
		draw:drawRect( -- 2439
			Rect( -- 2439
				self:sx(p.x - 3, w), -- 2439
				self:sy(p.y + 1, h), -- 2439
				self:px(3), -- 2439
				self:px(3) -- 2439
			), -- 2439
			STAND -- 2439
		) -- 2439
	end -- 2439
	drawFigure( -- 2441
		draw, -- 2441
		self, -- 2441
		w, -- 2441
		h, -- 2441
		p, -- 2441
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2441
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2441
	) -- 2441
	local q = self.partner -- 2442
	if q.alive then -- 2442
		local childPartner = q.w == CHILD_W -- 2444
		drawFigure( -- 2445
			draw, -- 2445
			self, -- 2445
			w, -- 2445
			h, -- 2445
			q, -- 2445
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2445
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2445
		) -- 2445
	end -- 2445
	local i = 0 -- 2447
	do -- 2447
		i = 0 -- 2448
		while i < #self.enemies do -- 2448
			local e = self.enemies[i + 1] -- 2449
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2450
			self:drawBox( -- 2451
				draw, -- 2451
				w, -- 2451
				h, -- 2451
				e.x - e.w / 2, -- 2451
				e.x + e.w / 2, -- 2451
				e.y, -- 2451
				e.y + e.h, -- 2451
				col -- 2451
			) -- 2451
			if e.alive and e.warnT > 0 then -- 2451
				local gunX = self:sx(e.x, w) -- 2454
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2455
				local aimX = self:sx(p.x, w) -- 2456
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2457
				local seg = 8 -- 2458
				local s = 0 -- 2459
				do -- 2459
					s = 0 -- 2460
					while s < seg do -- 2460
						local t0 = s / seg -- 2461
						local t1 = (s + 1) / seg -- 2462
						draw:drawSegment( -- 2463
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2464
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2465
							self:px(1), -- 2466
							DANGER -- 2466
						) -- 2466
						s = s + 2 -- 2460
					end -- 2460
				end -- 2460
			end -- 2460
			i = i + 1 -- 2448
		end -- 2448
	end -- 2448
	local k = 0 -- 2471
	do -- 2471
		k = 0 -- 2472
		while k < #self.room.marks do -- 2472
			do -- 2472
				local m = self.room.marks[k + 1] -- 2473
				if m.kind ~= 0 then -- 2473
					goto __continue481 -- 2475
				end -- 2475
				local on = self.checkpoint == m.x -- 2477
				local x = self:sx(m.x, w) -- 2478
				local y = self:sy(m.y, h) -- 2479
				draw:drawSegment( -- 2480
					Vec2(x, y), -- 2480
					Vec2( -- 2480
						x, -- 2480
						y + self:px(35) -- 2480
					), -- 2480
					self:px(1), -- 2480
					on and CHECK or INK_DIM -- 2480
				) -- 2480
				draw:drawDot( -- 2481
					Vec2( -- 2481
						x, -- 2481
						y + self:px(35) -- 2481
					), -- 2481
					self:px(2), -- 2481
					on and CHECK or INK_DIM -- 2481
				) -- 2481
			end -- 2481
			::__continue481:: -- 2481
			k = k + 1 -- 2472
		end -- 2472
	end -- 2472
	local j = 0 -- 2485
	do -- 2485
		j = 0 -- 2486
		while j < #self.room.marks do -- 2486
			do -- 2486
				local m = self.room.marks[j + 1] -- 2487
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2487
					goto __continue484 -- 2489
				end -- 2489
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2489
					goto __continue484 -- 2493
				end -- 2493
				local col = STAND -- 2495
				if m.kind == 4 then -- 2495
					col = PASS_LINE -- 2497
				elseif m.kind == 5 then -- 2497
					col = BRICK_LINE -- 2499
				end -- 2499
				local mx = self:sx(m.x, w) -- 2501
				local my = self:sy(m.y, h) -- 2502
				draw:drawSegment( -- 2503
					Vec2(mx, my), -- 2503
					Vec2( -- 2503
						mx, -- 2503
						my + self:px(24) -- 2503
					), -- 2503
					self:px(1), -- 2503
					col -- 2503
				) -- 2503
			end -- 2503
			::__continue484:: -- 2503
			j = j + 1 -- 2486
		end -- 2486
	end -- 2486
	local t = 0 -- 2506
	do -- 2506
		t = 0 -- 2507
		while t < #self.room.marks do -- 2507
			do -- 2507
				local m = self.room.marks[t + 1] -- 2508
				if m.kind ~= 6 then -- 2508
					goto __continue490 -- 2510
				end -- 2510
				local mx = self:sx(m.x, w) -- 2512
				local my = self:sy(m.y, h) -- 2513
				draw:drawSegment( -- 2514
					Vec2(mx, my), -- 2514
					Vec2( -- 2514
						mx, -- 2514
						my + self:px(30) -- 2514
					), -- 2514
					self:px(1), -- 2514
					INK_DIM -- 2514
				) -- 2514
				self:drawBox( -- 2515
					draw, -- 2515
					w, -- 2515
					h, -- 2515
					m.x - 5, -- 2515
					m.x + 5, -- 2515
					m.y + 30, -- 2515
					m.y + 40, -- 2515
					CHECK -- 2515
				) -- 2515
			end -- 2515
			::__continue490:: -- 2515
			t = t + 1 -- 2507
		end -- 2507
	end -- 2507
	if self.room.key == "village" then -- 2507
		self:drawVillage(draw, w, h) -- 2518
	end -- 2518
	if self.room.key == "forest" then -- 2518
		self:drawDog(draw, w, h) -- 2521
	end -- 2521
end -- 2428
function Play.prototype.drawDog(self, draw, w, h) -- 2526
	local x = self.dogX -- 2527
	self:drawBox( -- 2528
		draw, -- 2528
		w, -- 2528
		h, -- 2528
		x - 14, -- 2528
		x + 14, -- 2528
		0, -- 2528
		20, -- 2528
		SCAV_BODY -- 2528
	) -- 2528
	self:drawBox( -- 2529
		draw, -- 2529
		w, -- 2529
		h, -- 2529
		x - 10, -- 2529
		x - 2, -- 2529
		20, -- 2529
		30, -- 2529
		SCAV_BODY -- 2529
	) -- 2529
	self:drawBox( -- 2530
		draw, -- 2530
		w, -- 2530
		h, -- 2530
		x + 2, -- 2530
		x + 10, -- 2530
		20, -- 2530
		30, -- 2530
		SCAV_HEAD -- 2530
	) -- 2530
	if self.dogState == "ear" or self.dogState == "chase" then -- 2530
		draw:drawSegment( -- 2532
			Vec2( -- 2532
				self:sx(x, w), -- 2532
				self:sy(30, h) -- 2532
			), -- 2532
			Vec2( -- 2533
				self:sx(x, w), -- 2533
				self:sy(40, h) -- 2533
			), -- 2533
			self:px(1), -- 2533
			DANGER -- 2533
		) -- 2533
	end -- 2533
end -- 2526
function Play.prototype.drawVillage(self, draw, w, h) -- 2538
	local bottle = self.room.bottle -- 2539
	if bottle ~= nil then -- 2539
		self:drawBox( -- 2541
			draw, -- 2541
			w, -- 2541
			h, -- 2541
			bottle.x - 14, -- 2541
			bottle.x + 14, -- 2541
			0, -- 2541
			64, -- 2541
			SOLID_FILL -- 2541
		) -- 2541
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2541
			self:drawBottle( -- 2543
				draw, -- 2543
				w, -- 2543
				h, -- 2543
				bottle.x, -- 2543
				64 -- 2543
			) -- 2543
		end -- 2543
	end -- 2543
	self:drawBox( -- 2547
		draw, -- 2547
		w, -- 2547
		h, -- 2547
		300, -- 2547
		420, -- 2547
		44, -- 2547
		50, -- 2547
		FLOOR_DECK -- 2547
	) -- 2547
	self:drawBox( -- 2548
		draw, -- 2548
		w, -- 2548
		h, -- 2548
		300, -- 2548
		306, -- 2548
		0, -- 2548
		44, -- 2548
		FLOOR_DECK -- 2548
	) -- 2548
	self:drawBox( -- 2549
		draw, -- 2549
		w, -- 2549
		h, -- 2549
		414, -- 2549
		420, -- 2549
		0, -- 2549
		44, -- 2549
		FLOOR_DECK -- 2549
	) -- 2549
	local s = self.room.scavenger -- 2551
	if s ~= nil then -- 2551
		local sx0 = self.scavX -- 2553
		self:drawBox( -- 2554
			draw, -- 2554
			w, -- 2554
			h, -- 2554
			sx0 - 12, -- 2554
			sx0 + 12, -- 2554
			0, -- 2554
			s.h - 14, -- 2554
			SCAV_BODY -- 2554
		) -- 2554
		self:drawBox( -- 2555
			draw, -- 2555
			w, -- 2555
			h, -- 2555
			sx0 - 7, -- 2555
			sx0 + 7, -- 2555
			s.h - 14, -- 2555
			s.h, -- 2555
			SCAV_HEAD -- 2555
		) -- 2555
		if self.scavState == "turn" then -- 2555
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2557
			draw:drawSegment( -- 2558
				Vec2( -- 2558
					self:sx(sx0, w), -- 2558
					self:sy(s.h - 6, h) -- 2558
				), -- 2558
				Vec2( -- 2558
					self:sx(fx, w), -- 2558
					self:sy(s.h - 6, h) -- 2558
				), -- 2558
				self:px(1), -- 2558
				INK -- 2558
			) -- 2558
		end -- 2558
	end -- 2558
	if self.hasBottle then -- 2558
		local p = self.player -- 2563
		self:drawBottle( -- 2564
			draw, -- 2564
			w, -- 2564
			h, -- 2564
			p.x + p.facing * 10, -- 2564
			p.y + p.h * 0.62 -- 2564
		) -- 2564
	end -- 2564
	if self.bottleFly ~= nil then -- 2564
		self:drawBottle( -- 2567
			draw, -- 2567
			w, -- 2567
			h, -- 2567
			self.bottleFly.x, -- 2567
			self.bottleFly.y -- 2567
		) -- 2567
	end -- 2567
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2567
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2570
		draw:drawCircle( -- 2571
			Vec2( -- 2571
				self:sx(self.bottleLandX, w), -- 2571
				self:sy(0, h) -- 2571
			), -- 2571
			self:px(r / ____exports.UNITS_PER_PX), -- 2571
			BRICK_LINE -- 2571
		) -- 2571
	end -- 2571
end -- 2538
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2575
	self:drawBox( -- 2576
		draw, -- 2576
		w, -- 2576
		h, -- 2576
		x - 3, -- 2576
		x + 3, -- 2576
		y - 10, -- 2576
		y, -- 2576
		BOTTLE -- 2576
	) -- 2576
end -- 2575
function Play.prototype.drawTrace(self, draw, w, h) -- 2579
	local t = self.trace -- 2580
	if t == nil or self.traceT <= 0 then -- 2580
		return -- 2582
	end -- 2582
	draw:drawSegment( -- 2584
		Vec2( -- 2585
			self:sx(t.x0, w), -- 2585
			self:sy(t.y0, h) -- 2585
		), -- 2585
		Vec2( -- 2586
			self:sx(t.x1, w), -- 2586
			self:sy(t.y1, h) -- 2586
		), -- 2586
		self:px(1), -- 2587
		t.hit and AIM_HIT or INK_DIM -- 2587
	) -- 2587
end -- 2579
function Play.prototype.drawAim(self, draw, w, h) -- 2590
	local v = self.view -- 2592
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2593
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2594
	local dot = self:px(1) -- 2595
	local arm = self:px(3) -- 2596
	local gap = self:px(1) -- 2597
	draw:drawSegment( -- 2598
		Vec2(gx - arm - gap, gy), -- 2598
		Vec2(gx - gap, gy), -- 2598
		dot / 2, -- 2598
		AIM -- 2598
	) -- 2598
	draw:drawSegment( -- 2599
		Vec2(gx + gap, gy), -- 2599
		Vec2(gx + arm + gap, gy), -- 2599
		dot / 2, -- 2599
		AIM -- 2599
	) -- 2599
	draw:drawSegment( -- 2600
		Vec2(gx, gy - arm - gap), -- 2600
		Vec2(gx, gy - gap), -- 2600
		dot / 2, -- 2600
		AIM -- 2600
	) -- 2600
	draw:drawSegment( -- 2601
		Vec2(gx, gy + gap), -- 2601
		Vec2(gx, gy + arm + gap), -- 2601
		dot / 2, -- 2601
		AIM -- 2601
	) -- 2601
	if self.room.key == "village" and self.hasBottle then -- 2601
		local p = self.player -- 2605
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2607
		local dir = ____end.x >= p.x and 1 or -1 -- 2608
		local x0 = p.x + dir * 10 -- 2609
		local y0 = p.y + p.h * 0.7 -- 2610
		local T = BOTTLE_FLY_TIME -- 2611
		local vx = (____end.x - x0) / T -- 2612
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2613
		local pxr = x0 -- 2614
		local pyr = y0 -- 2615
		local t = 1 -- 2616
		do -- 2616
			t = 1 -- 2617
			while t <= 12 do -- 2617
				local tt = t / 12 * T -- 2618
				local nx = x0 + vx * tt -- 2619
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2620
				draw:drawSegment( -- 2621
					Vec2( -- 2621
						self:sx(pxr, w), -- 2621
						self:sy(pyr, h) -- 2621
					), -- 2621
					Vec2( -- 2621
						self:sx(nx, w), -- 2621
						self:sy(ny, h) -- 2621
					), -- 2621
					self:px(1) / 2, -- 2621
					BOTTLE -- 2621
				) -- 2621
				pxr = nx -- 2622
				pyr = ny -- 2623
				t = t + 1 -- 2617
			end -- 2617
		end -- 2617
		draw:drawCircle( -- 2625
			Vec2( -- 2625
				self:sx(____end.x, w), -- 2625
				self:sy(____end.y + 2, h) -- 2625
			), -- 2625
			self:px(2), -- 2625
			BOTTLE -- 2625
		) -- 2625
	end -- 2625
end -- 2590
return ____exports -- 2590