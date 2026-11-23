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
function makeActor(room, index) -- 2708
	local sp = room.spawns -- 2709
	if index < 0 or index >= #sp then -- 2709
		return { -- 2711
			x = 0, -- 2711
			y = 0, -- 2711
			vx = 0, -- 2711
			vy = 0, -- 2711
			w = CHILD_W, -- 2711
			h = CHILD_H, -- 2711
			onGround = true, -- 2711
			facing = 1, -- 2711
			crouch = false, -- 2711
			rollT = 0, -- 2711
			covered = false, -- 2711
			alive = false -- 2711
		} -- 2711
	end -- 2711
	local s = sp[index + 1] -- 2713
	local child = s.h <= CHILD_H -- 2714
	return { -- 2715
		x = s.x, -- 2716
		y = s.y, -- 2716
		vx = 0, -- 2716
		vy = 0, -- 2716
		w = child and CHILD_W or SOLDIER_W, -- 2717
		h = child and CHILD_H or SOLDIER_H, -- 2718
		onGround = true, -- 2719
		facing = 1, -- 2719
		crouch = false, -- 2719
		rollT = 0, -- 2719
		covered = false, -- 2719
		alive = true -- 2719
	} -- 2719
end -- 2719
function drawFigure(draw, play, w, h, a, body, head) -- 2723
	if not a.alive then -- 2723
		return -- 2725
	end -- 2725
	local x0 = a.x - a.w / 2 -- 2727
	local x1 = a.x + a.w / 2 -- 2728
	local y0 = a.y -- 2729
	local y1 = a.y + a.h -- 2730
	play:drawBox( -- 2731
		draw, -- 2731
		w, -- 2731
		h, -- 2731
		x0, -- 2731
		x1, -- 2731
		y0, -- 2731
		y1 - a.h * 0.26, -- 2731
		body -- 2731
	) -- 2731
	play:drawBox( -- 2732
		draw, -- 2732
		w, -- 2732
		h, -- 2732
		x0 + 2, -- 2732
		x1 - 2, -- 2732
		y1 - a.h * 0.26, -- 2732
		y1, -- 2732
		head -- 2732
	) -- 2732
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2734
	play:drawBox( -- 2735
		draw, -- 2735
		w, -- 2735
		h, -- 2735
		eyeX, -- 2735
		eyeX + 4, -- 2735
		y1 - a.h * 0.14, -- 2735
		y1 - a.h * 0.08, -- 2735
		INK -- 2735
	) -- 2735
end -- 2735
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2739
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2740
end -- 2739
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2747
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2748
end -- 2747
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2755
	local tmin = 0 -- 2756
	local tmax = 99999 -- 2757
	if dx == 0 then -- 2757
		if ox < x0 or ox > x1 then -- 2757
			return -1 -- 2760
		end -- 2760
	else -- 2760
		local t1 = (x0 - ox) / dx -- 2763
		local t2 = (x1 - ox) / dx -- 2764
		local lo = t1 < t2 and t1 or t2 -- 2765
		local hi = t1 < t2 and t2 or t1 -- 2766
		if lo > tmin then -- 2766
			tmin = lo -- 2768
		end -- 2768
		if hi < tmax then -- 2768
			tmax = hi -- 2771
		end -- 2771
	end -- 2771
	if dy == 0 then -- 2771
		if oy < y0 or oy > y1 then -- 2771
			return -1 -- 2776
		end -- 2776
	else -- 2776
		local t1 = (y0 - oy) / dy -- 2779
		local t2 = (y1 - oy) / dy -- 2780
		local lo = t1 < t2 and t1 or t2 -- 2781
		local hi = t1 < t2 and t2 or t1 -- 2782
		if lo > tmin then -- 2782
			tmin = lo -- 2784
		end -- 2784
		if hi < tmax then -- 2784
			tmax = hi -- 2787
		end -- 2787
	end -- 2787
	return tmax >= tmin and tmin or -1 -- 2790
end -- 2790
function drawCartShape(draw, play, w, h, c, axleX) -- 2793
	local half = c.bodyW / 2 -- 2794
	local x0 = axleX - half -- 2795
	local x1 = axleX + half -- 2796
	play:drawBox( -- 2797
		draw, -- 2797
		w, -- 2797
		h, -- 2797
		x0, -- 2797
		x1, -- 2797
		c.baseY + c.wheelR, -- 2797
		c.baseY + c.wheelR + c.bodyH, -- 2797
		CART_FILL -- 2797
	) -- 2797
	draw:drawCircle( -- 2798
		Vec2( -- 2798
			play:sx(x0 + c.bodyW * 0.28, w), -- 2798
			play:sy(c.baseY + c.wheelR, h) -- 2798
		), -- 2798
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2798
		Color(52, 50, 48, 255) -- 2798
	) -- 2798
	draw:drawCircle( -- 2799
		Vec2( -- 2799
			play:sx(x1 - c.bodyW * 0.28, w), -- 2799
			play:sy(c.baseY + c.wheelR, h) -- 2799
		), -- 2799
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2799
		Color(52, 50, 48, 255) -- 2799
	) -- 2799
	local cx = c.clothSide < 0 and x0 or x1 -- 2800
	play:drawBox( -- 2801
		draw, -- 2801
		w, -- 2801
		h, -- 2801
		cx - 10, -- 2801
		cx + 10, -- 2801
		c.baseY + c.wheelR + c.bodyH, -- 2801
		c.baseY + c.wheelR + c.bodyH + 18, -- 2801
		CLOTH -- 2801
	) -- 2801
end -- 2801
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
function Play.prototype.adoptEvents(self, events) -- 469
	if #events == 0 then -- 469
		return -- 471
	end -- 471
	local keep = {} -- 473
	local i = 0 -- 474
	do -- 474
		i = 0 -- 475
		while i < #events do -- 475
			do -- 475
				local e = events[i + 1] -- 476
				if e.name == "knock" and e.data.room ~= self.room.key then -- 476
					goto __continue32 -- 478
				end -- 478
				keep[#keep + 1] = e -- 480
			end -- 480
			::__continue32:: -- 480
			i = i + 1 -- 475
		end -- 475
	end -- 475
	if #keep == 0 then -- 475
		return -- 483
	end -- 483
	self.events = __TS__ArrayConcat(keep, self.events) -- 485
	do -- 485
		i = 0 -- 486
		while i < #self.events do -- 486
			self.events[i + 1].seq = i -- 487
			i = i + 1 -- 486
		end -- 486
	end -- 486
	self.eventSeq = #self.events -- 489
end -- 469
function Play.prototype.update(self, dt, input) -- 493
	if input.pause.pressed then -- 493
		self.paused = not self.paused -- 495
	end -- 495
	if self.flashT > 0 then -- 495
		self.flashT = self.flashT - dt -- 498
		if self.flashT <= 0 then -- 498
			self.flash = "" -- 500
		end -- 500
	end -- 500
	if self.traceT > 0 then -- 500
		self.traceT = self.traceT - dt -- 504
		if self.traceT <= 0 then -- 504
			self.trace = nil -- 506
		end -- 506
	end -- 506
	if self.paused then -- 506
		self:updateCamera(dt) -- 510
		return -- 511
	end -- 511
	self.ticks = self.ticks + 1 -- 514
	local p = self.player -- 515
	self:stepPlayer(p, dt, input) -- 516
	self:refreshCover(p, input) -- 518
	self:stepEnemies(dt, input) -- 520
	self:stepStory(dt, input) -- 521
	self:stepEscort(dt, input) -- 522
	self:stepVillage(dt, input) -- 523
	self:stepChase(dt, input) -- 524
	self:stepInteract(dt, input) -- 525
	self:updateGate() -- 526
	self:updateCamera(dt) -- 527
end -- 493
function Play.prototype.underLowArch(self, a) -- 534
	local arch = self.room.arch -- 535
	if arch.h <= 0 then -- 535
		return false -- 537
	end -- 537
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 537
		return false -- 540
	end -- 540
	local top = arch.y + arch.h -- 542
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 543
end -- 534
function Play.prototype.coverAt(self, a) -- 550
	local best = nil -- 551
	local bestGap = 24 -- 552
	local half = a.w / 2 -- 553
	local i = 0 -- 554
	do -- 554
		i = 0 -- 555
		while i < #self.boxes do -- 555
			do -- 555
				local b = self.boxes[i + 1] -- 556
				if b.passable == true or b.y1 - b.y0 < 44 then -- 556
					goto __continue49 -- 558
				end -- 558
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 558
					goto __continue49 -- 561
				end -- 561
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 563
				if gap < bestGap then -- 563
					bestGap = gap -- 565
					best = b -- 566
				end -- 566
			end -- 566
			::__continue49:: -- 566
			i = i + 1 -- 555
		end -- 555
	end -- 555
	return best -- 569
end -- 550
function Play.prototype.nearCover(self, a) -- 572
	return self:coverAt(a) ~= nil -- 573
end -- 572
function Play.prototype.coverGuardsFrom(self, b, a, enemyX) -- 577
	if enemyX < 0 then -- 577
		return false -- 579
	end -- 579
	if enemyX >= a.x then -- 579
		return b.x0 >= a.x - 0.001 and b.x0 <= enemyX -- 582
	end -- 582
	return b.x1 <= a.x + 0.001 and b.x1 >= enemyX -- 584
end -- 577
function Play.prototype.nearestEnemyX(self, a) -- 588
	local best = -1 -- 589
	local bestD = 1000000000 -- 590
	local i = 0 -- 591
	do -- 591
		i = 0 -- 592
		while i < #self.enemies do -- 592
			do -- 592
				local e = self.enemies[i + 1] -- 593
				if not e.alive then -- 593
					goto __continue59 -- 595
				end -- 595
				local d = math.abs(e.x - a.x) -- 597
				if d < bestD then -- 597
					bestD = d -- 599
					best = e.x -- 600
				end -- 600
			end -- 600
			::__continue59:: -- 600
			i = i + 1 -- 592
		end -- 592
	end -- 592
	return best -- 603
end -- 588
function Play.prototype.refreshCover(self, a, input) -- 607
	if self.childMode then -- 607
		self.coverNear = false -- 609
		self.coverHug = false -- 610
		self.coverEntity = "" -- 611
		self.coverBlocking = false -- 612
		a.covered = false -- 613
		return -- 614
	end -- 614
	local b = self:coverAt(a) -- 616
	self.coverNear = b ~= nil -- 617
	a.covered = self.coverNear and input.cover.held -- 618
	self.coverHug = a.covered -- 619
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 620
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 621
		b, -- 621
		a, -- 621
		self:nearestEnemyX(a) -- 621
	) -- 621
end -- 607
function Play.prototype.cartHandleInReach(self, a) -- 625
	local c = self.room.cart -- 626
	if self.cartDocked or c.endX <= c.startX then -- 626
		return false -- 628
	end -- 628
	local handleX = self.cartAxle + c.handleOffset -- 630
	return math.abs(a.x - handleX) <= CART_REACH and math.abs(a.y - c.baseY) <= 40 -- 631
end -- 625
function Play.prototype.nearLowLedge(self, a) -- 635
	local reach = 26 -- 636
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 637
	local x1 = x0 + reach -- 638
	local i = 0 -- 639
	do -- 639
		i = 0 -- 640
		while i < #self.boxes do -- 640
			do -- 640
				local b = self.boxes[i + 1] -- 641
				if b.x1 <= x0 or b.x0 >= x1 then -- 641
					goto __continue68 -- 643
				end -- 643
				local rise = b.y1 - a.y -- 645
				if rise > 0 and rise <= LEDGE_RISE then -- 645
					return true -- 647
				end -- 647
			end -- 647
			::__continue68:: -- 647
			i = i + 1 -- 640
		end -- 640
	end -- 640
	return false -- 650
end -- 635
function Play.prototype.stepPlayer(self, a, dt, input) -- 653
	if not a.alive then -- 653
		return -- 655
	end -- 655
	local isChild = self.childMode -- 657
	local lowArch = isChild and self:underLowArch(a) -- 659
	if self:storyLocked() then -- 659
		a.vx = 0 -- 662
		a.crouch = isChild and lowArch -- 663
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 664
		self:fallY(a, dt) -- 665
		return -- 666
	end -- 666
	if not isChild and self.escort.state == "calming" then -- 666
		a.crouch = false -- 670
		a.h = SOLDIER_H -- 671
		a.vx = 0 -- 672
		self:fallY(a, dt) -- 673
		return -- 674
	end -- 674
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 676
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 677
	local nearCover = not isChild and self:nearCover(a) -- 678
	a.covered = nearCover and input.cover.held -- 679
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 681
	if a.rollT > 0 then -- 681
		a.rollT = a.rollT - dt -- 685
		a.vx = a.facing * ROLL_SPEED -- 686
		self:slideX(a, a.vx * dt) -- 687
		self:fallY(a, dt) -- 688
		if a.rollT <= 0 then -- 688
			self:flashSet("翻滚结束", 0.5) -- 690
		end -- 690
		return -- 692
	end -- 692
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 692
		if input.moveX ~= 0 then -- 692
			a.facing = input.moveX > 0 and 1 or -1 -- 697
		end -- 697
		if self:nearLowLedge(a) then -- 697
			a.vy = SOLDIER_JUMP -- 701
			a.onGround = false -- 702
			self:flashSet("翻上去", 0.3) -- 703
			return -- 704
		end -- 704
		a.rollT = ROLL_TIME -- 706
		self:flashSet("翻滚", 0.3) -- 707
		return -- 708
	end -- 708
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 711
	if isChild then -- 711
		if input.cover.held then -- 711
			speed = CHILD_SLOW -- 714
		end -- 714
		if a.crouch then -- 714
			speed = CHILD_SLOW -- 717
		end -- 717
	elseif a.covered then -- 717
		speed = SOLDIER_SPEED * 0.45 -- 720
	end -- 720
	local dir = self.gripping and 0 or input.moveX -- 724
	if dir ~= 0 then -- 724
		a.facing = dir > 0 and 1 or -1 -- 726
	end -- 726
	a.vx = dir * speed -- 728
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 728
		a.vy = CHILD_JUMP -- 732
		a.onGround = false -- 733
		self:flashSet("跳", 0.25) -- 734
	end -- 734
	self:slideX(a, a.vx * dt) -- 737
	self:fallY(a, dt) -- 738
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 738
		self:shoot(a) -- 742
	end -- 742
end -- 653
function Play.prototype.stepPartner(self, p, dt) -- 747
	local a = self.partner -- 748
	if not a.alive then -- 748
		return -- 750
	end -- 750
	a.crouch = false -- 752
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 753
	a.vx = 0 -- 754
	self:fallY(a, dt) -- 755
end -- 747
function Play.prototype.stepEscort(self, dt, input) -- 762
	local a = self.partner -- 763
	if not a.alive then -- 763
		return -- 765
	end -- 765
	if not self:escortOn() then -- 765
		a.vx = 0 -- 768
		self:fallY(a, dt) -- 769
		return -- 770
	end -- 770
	local p = self.player -- 772
	local dist = math.abs(p.x - a.x) -- 773
	local hadKnock1 = self.escort.knock1 -- 774
	local hadKnock2 = self.escort.knock2 -- 775
	self.calmConsumed = self.escort:update( -- 776
		input, -- 776
		p.x, -- 776
		p.facing, -- 776
		a.x, -- 776
		dist -- 776
	) -- 776
	if not hadKnock1 and self.escort.knock1 then -- 776
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 779
	end -- 779
	if not hadKnock2 and self.escort.knock2 then -- 779
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 782
	end -- 782
	a.crouch = self.escort.crouchPose -- 784
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 785
	local dir = self.escort:moveDir(a.x) -- 786
	a.vx = dir * CHILD_SPEED -- 787
	if dir ~= 0 then -- 787
		a.facing = dir -- 789
		local before = a.x -- 790
		self:slideX(a, dir * CHILD_SPEED * dt) -- 791
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 791
			a.vy = CHILD_JUMP -- 794
			a.onGround = false -- 795
		end -- 795
	end -- 795
	self:fallY(a, dt) -- 798
end -- 762
function Play.prototype.escortOn(self) -- 802
	if self.room.key == "checkpoint" then -- 802
		return true -- 804
	end -- 804
	if self.room.key == "prologue" then -- 804
		return self.phase == "prologue-follow" -- 807
	end -- 807
	return self.room.key == "street" -- 809
end -- 802
function Play.prototype.storyLocked(self) -- 813
	if self.caughtT > 0 then -- 813
		return true -- 815
	end -- 815
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 815
		return true -- 818
	end -- 818
	if self.room.key == "gate" and self.phase == "gate-count" then -- 818
		return true -- 821
	end -- 821
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 821
		return true -- 824
	end -- 824
	return false -- 826
end -- 813
function Play.prototype.swapToChild(self, x) -- 830
	local tmp = self.player -- 831
	self.player = self.partner -- 832
	self.partner = tmp -- 833
	self.childMode = true -- 834
	self.player.alive = true -- 835
	self.player.x = self.ox + x -- 836
	self.player.y = 0 -- 837
	self.player.vy = 0 -- 838
	self.player.vx = 0 -- 839
	self.player.onGround = true -- 840
	self.player.crouch = false -- 841
	self.player.h = CHILD_H -- 842
	self.player.facing = 1 -- 843
	self.partner.alive = true -- 844
	self.cam.x = self.player.x -- 845
end -- 830
function Play.prototype.stepStory(self, dt, input) -- 849
	if self.room.key == "prologue" then -- 849
		self:stepPrologue(dt, input) -- 851
	elseif self.room.key == "street" then -- 851
		self:stepStreet(dt, input) -- 853
	elseif self.room.key == "gate" then -- 853
		self:stepGate(dt, input) -- 855
	elseif self.room.key == "tower" then -- 855
		self:stepTower(dt, input) -- 857
	end -- 857
end -- 849
function Play.prototype.stepPrologue(self, dt, input) -- 862
	local child = self.partner -- 863
	if self.phase == "prologue-wait" then -- 863
		child.crouch = true -- 865
		child.h = CHILD_CROUCH_H -- 866
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 867
		local near = math.abs(self.player.x - child.x) <= reach -- 869
		if near and input.interact.pressed then -- 869
			self.phase = "prologue-give" -- 871
			self.phaseTick = 0 -- 872
			self:flashSet("递出针套", 1) -- 873
		end -- 873
		return -- 875
	end -- 875
	if self.phase == "prologue-give" then -- 875
		self.phaseTick = self.phaseTick + 1 -- 878
		if self.phaseTick == 12 then -- 878
			self:flashSet("针套递过去", 0.7) -- 880
		elseif self.phaseTick == 36 then -- 880
			self:flashSet("纸条塞进针套", 0.9) -- 882
		elseif self.phaseTick >= 60 then -- 882
			self.phase = "prologue-follow" -- 884
			self.phaseTick = 0 -- 885
			child.crouch = false -- 886
			child.h = CHILD_H -- 887
			self:flashSet("她跟上了", 1.2) -- 888
		end -- 888
		return -- 890
	end -- 890
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 890
		self:requestRoom("street", "序章跟到门口") -- 894
		self:flashSet("进街道", 1.2) -- 895
	end -- 895
end -- 862
function Play.prototype.stepStreet(self, dt, input) -- 900
	local p = self.player -- 901
	local c = self.partner -- 902
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 902
		self:requestRoom("checkpoint", "两人都到街尾") -- 904
		self:flashSet("到检查站", 1.2) -- 905
	end -- 905
end -- 900
function Play.prototype.stepGate(self, dt, input) -- 910
	local ____temp_8 -- 911
	if self.room.story == nil then -- 911
		____temp_8 = nil -- 911
	else -- 911
		____temp_8 = self.room.story.gate -- 911
	end -- 911
	local g = ____temp_8 -- 911
	if g == nil then -- 911
		return -- 913
	end -- 913
	local p = self.player -- 915
	if self.phase == "gate-idle" then -- 915
		local a = self.partner -- 918
		local gap = g.waitX - a.x -- 919
		if math.abs(gap) > 3 then -- 919
			a.facing = gap > 0 and 1 or -1 -- 921
			a.vx = a.facing * CHILD_SPEED -- 922
			local beforeX = a.x -- 923
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 924
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 924
				a.vy = CHILD_JUMP -- 926
				a.onGround = false -- 927
			end -- 927
			self:fallY(a, dt) -- 929
		else -- 929
			a.vx = 0 -- 931
			a.x = g.waitX -- 932
		end -- 932
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 935
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 936
		if self.gateNeedConfirm then -- 936
			if not input.interact.held then -- 936
				self.gateRestartArmed = true -- 941
			end -- 941
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 941
				self.gateNeedConfirm = false -- 944
				self.gateRestartArmed = true -- 945
				self.phase = "gate-hold" -- 946
				self.gateTick = 0 -- 947
				self.gateSpawned = 0 -- 948
				self:flashSet("重新就位 · 守点开始", 1.4) -- 949
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 950
			end -- 950
			return -- 952
		end -- 952
		if atWinch and atWait then -- 952
			self.phase = "gate-hold" -- 955
			self.gateTick = 0 -- 956
			self.gateSpawned = 0 -- 957
			self:flashSet("两人就位 · 守点开始", 1.4) -- 958
		end -- 958
		return -- 960
	end -- 960
	if self.phase == "gate-hold" then -- 960
		self.gateTick = self.gateTick + 1 -- 963
		local marks = {0, 540, 900, 1500} -- 965
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 965
			local idx = self.gateSpawned -- 967
			local ____self_enemies_9 = self.enemies -- 967
			____self_enemies_9[#____self_enemies_9 + 1] = { -- 968
				x = self.ox + 620 + idx * 62, -- 969
				y = 0, -- 969
				w = 26, -- 969
				h = 84, -- 969
				alive = true, -- 970
				hitT = 0, -- 970
				warnT = 0, -- 970
				fireCd = 90 + idx * 45 -- 970
			} -- 970
			self.gateSpawned = self.gateSpawned + 1 -- 972
			self:flashSet( -- 973
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 973
				0.9 -- 973
			) -- 973
		end -- 973
		if self.gateTick == 900 then -- 973
			self:flashSet("灯灭了", 1) -- 976
		elseif self.gateTick == 2100 then -- 976
			self:flashSet("门底压下来了", 1) -- 978
		end -- 978
		if self.gateTick >= g.holdTicks then -- 978
			self.phase = "gate-send" -- 981
			self.phaseTick = 0 -- 982
			self.enemies = {} -- 984
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 985
		end -- 985
		return -- 987
	end -- 987
	if self.phase == "gate-send" then -- 987
		local near = math.abs(p.x - g.doorX) <= 60 -- 990
		if near and input.interact.pressed then -- 990
			self:swapToChild(g.doorX + 30) -- 992
			self.phase = "gate-count" -- 993
			self.countTick = 0 -- 994
			self.countArmed = false -- 996
			self.countPrevMove = input.moveX -- 997
			self:flashSet("门开了 · 送她出去", 1.8) -- 998
		end -- 998
		return -- 1000
	end -- 1000
	if self.phase == "gate-count" then -- 1000
		self.countTick = self.countTick + 1 -- 1003
		if self.countTick == 360 then -- 1003
			self:flashSet("门关上", 0.9) -- 1005
		elseif self.countTick == 1020 then -- 1005
			self:flashSet("数到一百", 2.2) -- 1007
		end -- 1007
		local prevMove = self.countPrevMove -- 1011
		self.countPrevMove = input.moveX -- 1012
		if self.countTick >= 1440 then -- 1012
			if prevMove <= 0 and input.moveX > 0 then -- 1012
				self.countArmed = true -- 1015
			end -- 1015
			if self.countArmed and input.moveX > 0 then -- 1015
				self.phase = "gate-walk" -- 1018
				self.phaseTick = 0 -- 1019
				self:flashSet("她迈出第一步", 1.4) -- 1020
			end -- 1020
		end -- 1020
		return -- 1023
	end -- 1023
	if self.player.x >= g.exitX then -- 1023
		self:requestRoom("outside", "走出城门") -- 1027
		self:flashSet("出城门 · 城外", 1.4) -- 1028
	end -- 1028
end -- 910
function Play.prototype.stepTower(self, dt, input) -- 1033
	local ____temp_10 -- 1034
	if self.room.story == nil then -- 1034
		____temp_10 = nil -- 1034
	else -- 1034
		____temp_10 = self.room.story.tower -- 1034
	end -- 1034
	local t = ____temp_10 -- 1034
	if t == nil then -- 1034
		return -- 1036
	end -- 1036
	if self.phase == "tower-wait" then -- 1036
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1039
		if near and input.interact.pressed then -- 1039
			self.phase = "tower-knock" -- 1041
			self.phaseTick = 0 -- 1042
			self.knocks = 1 -- 1043
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1044
			self:flashSet("敲一下", 0.6) -- 1045
		end -- 1045
		return -- 1047
	end -- 1047
	if self.phase == "tower-knock" then -- 1047
		self.phaseTick = self.phaseTick + 1 -- 1050
		if self.phaseTick == 12 then -- 1050
			self.knocks = 2 -- 1052
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1053
			self:flashSet("敲两下 · 第二声", 1) -- 1054
		elseif self.phaseTick >= t.knockTicks then -- 1054
			self.phase = "tower-given" -- 1056
			self.phaseTick = 0 -- 1057
			self:flashSet("门开了 · 提灯", 1.4) -- 1058
		end -- 1058
		return -- 1060
	end -- 1060
	if self.phase == "tower-given" then -- 1060
		self.phaseTick = self.phaseTick + 1 -- 1063
		if self.phaseTick == 60 then -- 1063
			self:flashSet("她递出针套和纸条", 1.6) -- 1065
		elseif self.phaseTick == 120 then -- 1065
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1067
		elseif self.phaseTick >= 180 then -- 1067
			self.phase = "tower-end" -- 1069
			self.phaseTick = 0 -- 1070
			self:flashSet("片尾 · E 再玩一次", 3) -- 1071
		end -- 1071
		return -- 1073
	end -- 1073
	if input.interact.pressed or input.retry.pressed then -- 1073
		self:requestRoom("prologue", "片尾再玩") -- 1076
		self:flashSet("回到序章", 1.4) -- 1077
	end -- 1077
end -- 1033
function Play.prototype.stepChase(self, dt, input) -- 1082
	if self.caughtT > 0 then -- 1082
		self.caughtT = self.caughtT - dt -- 1084
		if self.caughtT <= 0 then -- 1084
			self:recoverFromCaught() -- 1086
		end -- 1086
		return -- 1088
	end -- 1088
	if self.room.key == "village" then -- 1088
		self:stepScavChase() -- 1091
	elseif self.room.key == "forest" then -- 1091
		self:stepDog(dt) -- 1093
		if self.player.x >= self.ox + 1450 then -- 1093
			self:requestRoom("tower", "到林缘北塔") -- 1096
			self:flashSet("林缘 · 北塔", 1.4) -- 1097
		end -- 1097
	end -- 1097
end -- 1082
function Play.prototype.stepScavChase(self) -- 1103
	local s = self.room.scavenger -- 1104
	if s == nil then -- 1104
		return -- 1106
	end -- 1106
	local p = self.player -- 1108
	if self.passed and p.x > self.ox + 440 then -- 1108
		if self.scavChase then -- 1108
			self.scavChase = false -- 1112
			self.scavState = "back" -- 1113
			self.scavT = 0 -- 1114
		end -- 1114
		return -- 1116
	end -- 1116
	local dx = p.x - self.scavX -- 1118
	local dist = math.abs(dx) -- 1119
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1120
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1121
	if not self.scavChase then -- 1121
		if visible then -- 1121
			self.scavSee = self.scavSee + 1 -- 1124
			if self.scavSee >= 24 then -- 1124
				self.scavChase = true -- 1126
				self.scavState = "chase" -- 1127
				self.scavTargetX = p.x -- 1128
				self:flashSet("他看见你了", 1.2) -- 1129
			end -- 1129
		else -- 1129
			self.scavSee = 0 -- 1132
		end -- 1132
		return -- 1134
	end -- 1134
	local dir = p.x > self.scavX and 1 or -1 -- 1137
	self.scavX = self.scavX + dir * 96 / 60 -- 1138
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1138
		self:caught() -- 1140
		return -- 1141
	end -- 1141
	if hidden then -- 1141
		self.scavSee = 0 -- 1145
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1146
		self.scavT = self.scavT - 1 -- 1147
		if self.scavT <= 0 then -- 1147
			self.scavChase = false -- 1149
			self.scavState = "patrol" -- 1150
			self:flashSet("他失去了目标", 1) -- 1151
		end -- 1151
	end -- 1151
end -- 1103
function Play.prototype.stepDog(self, dt) -- 1157
	local ____temp_11 -- 1158
	if self.room.story == nil then -- 1158
		____temp_11 = nil -- 1158
	else -- 1158
		____temp_11 = self.room.story.dog -- 1158
	end -- 1158
	local dog = ____temp_11 -- 1158
	if dog == nil then -- 1158
		return -- 1160
	end -- 1160
	local p = self.player -- 1162
	local dist = math.abs(p.x - self.dogX) -- 1163
	if self.dogState == "patrol" then -- 1163
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1165
		if self.dogX < dog.x0 then -- 1165
			self.dogX = dog.x0 -- 1167
			self.dogDir = 1 -- 1168
		elseif self.dogX > dog.x1 then -- 1168
			self.dogX = dog.x1 -- 1170
			self.dogDir = -1 -- 1171
		end -- 1171
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1173
		if not p.crouch and moving and dist < dog.range then -- 1173
			self.dogState = "ear" -- 1175
			self.dogT = 18 -- 1176
			self.dogTargetX = p.x -- 1177
			self:flashSet("狗转耳朵", 0.8) -- 1178
		end -- 1178
		return -- 1180
	end -- 1180
	if self.dogState == "ear" then -- 1180
		self.dogT = self.dogT - 1 -- 1183
		if self.dogT <= 0 then -- 1183
			self.dogState = "chase" -- 1185
			self.dogTargetX = p.x -- 1186
			self:flashSet("狗追来了", 1.4) -- 1187
		end -- 1187
		return -- 1189
	end -- 1189
	if self.dogState == "chase" then -- 1189
		local dir = p.x > self.dogX and 1 or -1 -- 1192
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1193
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1193
			self:caught() -- 1195
			self.dogState = "sniff" -- 1196
			self.dogT = 60 -- 1197
		elseif dist > dog.range * 1.5 or p.crouch then -- 1197
			self.dogState = "sniff" -- 1199
			self.dogT = 60 -- 1200
			self:flashSet("狗停下了", 0.9) -- 1201
		end -- 1201
		return -- 1203
	end -- 1203
	if self.dogState == "sniff" then -- 1203
		self.dogT = self.dogT - 1 -- 1206
		if self.dogT <= 0 then -- 1206
			self.dogState = "back" -- 1208
		end -- 1208
		return -- 1210
	end -- 1210
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1213
	self.dogX = self.dogX + dir * dog.speed * dt -- 1214
	if math.abs(self.dogX - dog.x0) < 2 then -- 1214
		self.dogX = dog.x0 -- 1216
		self.dogState = "patrol" -- 1217
	end -- 1217
end -- 1157
function Play.prototype.caught(self) -- 1221
	self.caughtT = 1 -- 1222
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1223
end -- 1221
function Play.prototype.recoverFromCaught(self) -- 1227
	local p = self.player -- 1228
	p.x = self.ox + 140 -- 1229
	p.y = 0 -- 1230
	p.vy = 0 -- 1231
	p.vx = 0 -- 1232
	p.onGround = true -- 1233
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1233
		self.scavX = self.room.scavenger.x0 -- 1235
		self.scavState = "patrol" -- 1236
		self.scavSee = 0 -- 1237
		self.scavChase = false -- 1238
		self.scavT = 0 -- 1239
	end -- 1239
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1239
		self.dogX = self.room.story.dog.x0 -- 1242
		self.dogState = "patrol" -- 1243
		self.dogT = 0 -- 1244
	end -- 1244
	self.cam.x = p.x -- 1246
	self.cam.y = p.y + CAM_LOOK_UP -- 1247
	self:flashSet("回到安全点", 1.2) -- 1248
end -- 1227
function Play.prototype.updateGate(self) -- 1252
	if self.room.key ~= "checkpoint" then -- 1252
		self.gateOpen = false -- 1254
		return -- 1255
	end -- 1255
	local function inZone(x) -- 1257
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1257
	end -- 1257
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1258
end -- 1252
function Play.prototype.stepEnemies(self, dt, input) -- 1261
	local i = 0 -- 1262
	do -- 1262
		i = 0 -- 1263
		while i < #self.enemies do -- 1263
			local e = self.enemies[i + 1] -- 1264
			if e.hitT > 0 then -- 1264
				e.hitT = e.hitT - dt -- 1266
			end -- 1266
			i = i + 1 -- 1263
		end -- 1263
	end -- 1263
	if self.coveredFlash > 0 then -- 1263
		self.coveredFlash = self.coveredFlash - dt -- 1270
	end -- 1270
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1270
		return -- 1274
	end -- 1274
	do -- 1274
		i = 0 -- 1276
		while i < #self.enemies do -- 1276
			do -- 1276
				local e = self.enemies[i + 1] -- 1277
				if not e.alive then -- 1277
					goto __continue201 -- 1279
				end -- 1279
				if e.warnT > 0 then -- 1279
					e.warnT = e.warnT - 1 -- 1282
					if e.warnT <= 0 then -- 1282
						self:enemyFire(e, input) -- 1284
					end -- 1284
					goto __continue201 -- 1286
				end -- 1286
				if e.fireCd > 0 then -- 1286
					e.fireCd = e.fireCd - 1 -- 1289
					if e.fireCd <= 0 then -- 1289
						e.warnT = WARN_TICKS -- 1291
					end -- 1291
				else -- 1291
					e.warnT = WARN_TICKS -- 1295
				end -- 1295
			end -- 1295
			::__continue201:: -- 1295
			i = i + 1 -- 1276
		end -- 1276
	end -- 1276
end -- 1261
function Play.prototype.enemyFire(self, e, input) -- 1301
	local p = self.player -- 1302
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1302
		self:flashSet("枪声响在远处", 0.4) -- 1304
		e.fireCd = FIRE_COOLDOWN -- 1305
		return -- 1306
	end -- 1306
	local cover = self:blockedByCover(e.x, p) -- 1309
	local hugging = cover ~= nil -- 1310
	self.coverBlocking = hugging -- 1311
	local covered = hugging and input.cover.held -- 1312
	if covered then -- 1312
		self.coveredFlash = 0.5 -- 1314
		self:flashSet("掩体挡下", 0.5) -- 1315
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1316
		e.fireCd = FIRE_COOLDOWN -- 1321
		return -- 1322
	end -- 1322
	self.hp = self.hp - 1 -- 1324
	self:emit("actorHit", { -- 1325
		target = "player", -- 1325
		amount = 1, -- 1325
		hp = self.hp, -- 1325
		maxHp = self.maxHp, -- 1325
		enemyX = e.x -- 1325
	}) -- 1325
	self:flashSet( -- 1326
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1326
		0.7 -- 1326
	) -- 1326
	e.fireCd = FIRE_COOLDOWN -- 1327
	if self.hp <= 0 then -- 1327
		self:gateFailed() -- 1329
	end -- 1329
end -- 1301
function Play.prototype.blockedByCover(self, ex, p) -- 1334
	local b = self:coverAt(p) -- 1335
	if b == nil then -- 1335
		return nil -- 1337
	end -- 1337
	return self:coverGuardsFrom(b, p, ex) and b or nil -- 1339
end -- 1334
function Play.prototype.gateFailed(self) -- 1343
	local ____temp_12 -- 1344
	if self.room.story == nil then -- 1344
		____temp_12 = nil -- 1344
	else -- 1344
		____temp_12 = self.room.story.gate -- 1344
	end -- 1344
	local g = ____temp_12 -- 1344
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1345
	self.hp = self.maxHp -- 1346
	self.gateTick = 0 -- 1347
	self.gateSpawned = 0 -- 1348
	self.enemies = {} -- 1349
	self.gateFailCount = self.gateFailCount + 1 -- 1350
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1352
	self.player.y = 0 -- 1353
	self.player.vy = 0 -- 1354
	self.player.onGround = true -- 1355
	self.player.crouch = false -- 1356
	self.player.h = SOLDIER_H -- 1357
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1358
	self.partner.y = 0 -- 1359
	self.partner.vy = 0 -- 1360
	self.partner.onGround = true -- 1361
	self.cam.x = self.player.x -- 1362
	self.phase = "gate-idle" -- 1363
	self.phaseTick = 0 -- 1364
	self.coverHug = false -- 1365
	self.coverBlocking = false -- 1366
	self.coverEntity = "" -- 1367
	self.gateNeedConfirm = true -- 1368
	self.gateRestartArmed = false -- 1369
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1370
end -- 1343
function Play.prototype.stepInteract(self, dt, input) -- 1373
	local p = self.player -- 1374
	local calmUsed = self.calmConsumed -- 1375
	self.calmConsumed = false -- 1376
	local calming = self.escort.state == "calming" -- 1378
	self.focusCart = false -- 1379
	if self.room.key == "outside" then -- 1379
		local c = self.room.cart -- 1381
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1382
		local dy = p.y - c.baseY -- 1383
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < CART_REACH * CART_REACH -- 1384
	end -- 1384
	if not calmUsed and not calming then -- 1384
		self:stepCart(dt, input) -- 1388
	end -- 1388
	if calmUsed then -- 1388
		self:flashSet("安抚 · 敲两下", 0.8) -- 1393
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1393
		if self.knockT > 0 then -- 1393
			self.knocks = self.knocks + 1 -- 1397
		else -- 1397
			self.knocks = 1 -- 1399
		end -- 1399
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1401
		self.knockT = 1.2 -- 1402
		if self.knocks >= 2 then -- 1402
			self:flashSet("敲两下", 0.8) -- 1404
			self.knocks = 0 -- 1405
		else -- 1405
			self:flashSet("敲一下", 0.5) -- 1407
		end -- 1407
	elseif self.knockT > 0 then -- 1407
		self.knockT = self.knockT - dt -- 1410
		if self.knockT <= 0 then -- 1410
			self.knocks = 0 -- 1412
		end -- 1412
	end -- 1412
	local i = 0 -- 1417
	do -- 1417
		i = 0 -- 1418
		while i < #self.room.marks do -- 1418
			do -- 1418
				local m = self.room.marks[i + 1] -- 1419
				if m.kind ~= 0 then -- 1419
					goto __continue227 -- 1421
				end -- 1421
				local subjects = {self.partner, self.player} -- 1423
				local k = 0 -- 1424
				do -- 1424
					k = 0 -- 1425
					while k < #subjects do -- 1425
						do -- 1425
							local s = subjects[k + 1] -- 1426
							if not s.alive then -- 1426
								goto __continue230 -- 1428
							end -- 1428
							local dx = s.x - m.x -- 1430
							local dy = s.y - m.y -- 1431
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1431
								self.checkpoint = m.x -- 1433
								self.checkpointCartAxle = self.cartAxle -- 1434
								if self.cartDocked then -- 1434
									self:flashSet("检查点 · 车已落窝", 1) -- 1436
								else -- 1436
									self:flashSet("检查点 · 车还没到位", 1) -- 1438
								end -- 1438
							end -- 1438
						end -- 1438
						::__continue230:: -- 1438
						k = k + 1 -- 1425
					end -- 1425
				end -- 1425
			end -- 1425
			::__continue227:: -- 1425
			i = i + 1 -- 1418
		end -- 1418
	end -- 1418
	self:checkCarryGate() -- 1444
end -- 1373
function Play.prototype.stepVillage(self, dt, input) -- 1448
	if self.room.key ~= "village" then -- 1448
		return -- 1450
	end -- 1450
	local p = self.player -- 1452
	local bottle = self.room.bottle -- 1453
	local scav = self.room.scavenger -- 1454
	if not self.hasBottle and bottle ~= nil then -- 1454
		local dx = p.x - bottle.x -- 1458
		local dy = p.y + p.h * 0.5 - bottle.y -- 1459
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1459
			self.hasBottle = true -- 1461
			self:flashSet("拾起瓶子", 0.8) -- 1462
		end -- 1462
	end -- 1462
	if self.hasBottle then -- 1462
		if input.aim.held then -- 1462
			self.aimHold = self.aimHold + dt -- 1469
			if self.aimHold > 1.2 then -- 1469
				self.aimHold = 1.2 -- 1471
			end -- 1471
			local cached = self:bottleEnd() -- 1474
			self.bottleAimX = cached.x -- 1475
			self.bottleAimY = cached.y -- 1476
		elseif input.aim.released then -- 1476
			if self.aimHold < 0.12 then -- 1476
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1480
				self.aimHold = 0 -- 1481
			else -- 1481
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1483
				self:throwBottle(____end.x, ____end.y) -- 1484
				self.aimHold = 0 -- 1485
			end -- 1485
		end -- 1485
	else -- 1485
		self.aimHold = 0 -- 1489
		self.bottleAimX = -1 -- 1490
	end -- 1490
	local fly = self.bottleFly -- 1495
	if fly ~= nil then -- 1495
		fly.t = fly.t + dt -- 1497
		fly.x = fly.x0 + fly.vx * fly.t -- 1498
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1499
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1500
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1500
			self:landBottle(fly) -- 1502
		end -- 1502
	end -- 1502
	if self.bottleLandT > 0 then -- 1502
		self.bottleLandT = self.bottleLandT - dt -- 1506
	end -- 1506
	if scav ~= nil then -- 1506
		self:stepScav(dt, scav) -- 1510
	end -- 1510
	local line = self.room.passLine -- 1513
	if line ~= nil and not self.passed and p.x >= line then -- 1513
		self.passed = true -- 1515
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1516
	end -- 1516
	if self.passed and p.x >= self.ox + 640 then -- 1516
		self:requestRoom("forest", "过第一院出院") -- 1520
		self:flashSet("出院 · 北塔森林", 1.4) -- 1521
	end -- 1521
end -- 1448
function Play.prototype.bottleEnd(self) -- 1526
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1527
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1528
	return {x = aim.x, y = g} -- 1529
end -- 1526
function Play.prototype.throwBottle(self, tx, ty) -- 1533
	local p = self.player -- 1534
	local dir = tx >= p.x and 1 or -1 -- 1536
	p.facing = dir -- 1537
	local x0 = p.x + dir * 10 -- 1538
	local y0 = p.y + p.h * 0.7 -- 1539
	self.bottleTargetX = tx -- 1540
	self.bottleTargetY = ty -- 1541
	self.bottleSurfaceY = ty -- 1542
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1543
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1544
	self.bottleFly = { -- 1545
		x = x0, -- 1545
		y = y0, -- 1545
		x0 = x0, -- 1545
		y0 = y0, -- 1545
		vx = vx, -- 1545
		vy = vy, -- 1545
		t = 0 -- 1545
	} -- 1545
	self.hasBottle = false -- 1546
	self:flashSet("投出", 0.4) -- 1547
	self:emit( -- 1548
		"bottleThrown", -- 1548
		{ -- 1548
			fromX = x0, -- 1549
			fromY = y0, -- 1550
			targetX = tx, -- 1551
			targetY = ty, -- 1552
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1553
		} -- 1553
	) -- 1553
end -- 1533
function Play.prototype.landBottle(self, fly) -- 1558
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1559
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1560
	local s = self.room.scavenger -- 1561
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1562
	self.bottleFly = nil -- 1563
	self.bottleTargetX = -1 -- 1564
	self.bottleTargetY = 0 -- 1565
	self.bottleSurfaceY = -1 -- 1566
	self.bottleLandX = x -- 1567
	self.bottleLandY = y -- 1568
	self.bottleLandT = 0.9 -- 1569
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1570
	self:hearBottle(x) -- 1571
end -- 1558
function Play.prototype.hearBottle(self, x) -- 1575
	local s = self.room.scavenger -- 1576
	if s == nil then -- 1576
		return -- 1578
	end -- 1578
	if math.abs(x - self.scavX) > s.range then -- 1578
		self:flashSet("落地 · 他没听见", 0.6) -- 1581
		return -- 1582
	end -- 1582
	self.scavState = "turn" -- 1584
	self.scavT = s.hearTicks -- 1585
	self.scavTargetX = x -- 1586
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1587
end -- 1575
function Play.prototype.stepScav(self, dt, s) -- 1591
	if self.scavState == "chase" then -- 1591
		return -- 1594
	end -- 1594
	if self.scavState == "turn" then -- 1594
		self.scavT = self.scavT - 1 -- 1597
		if self.scavT <= 0 then -- 1597
			self.scavState = "walk" -- 1599
		end -- 1599
		return -- 1601
	end -- 1601
	if self.scavState == "walk" then -- 1601
		local d = self.scavTargetX - self.scavX -- 1604
		if math.abs(d) < 4 then -- 1604
			self.scavState = "stall" -- 1606
			self.scavT = s.stallTicks -- 1607
			return -- 1608
		end -- 1608
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1610
		return -- 1611
	end -- 1611
	if self.scavState == "stall" then -- 1611
		self.scavT = self.scavT - 1 -- 1614
		if self.scavT <= 0 then -- 1614
			self.scavState = "back" -- 1616
		end -- 1616
		return -- 1618
	end -- 1618
	if self.scavState == "back" then -- 1618
		local home = math.max( -- 1621
			s.x0, -- 1621
			math.min(s.x1, self.scavX) -- 1621
		) -- 1621
		if math.abs(home - self.scavX) < 2 then -- 1621
			self.scavState = "patrol" -- 1623
			return -- 1624
		end -- 1624
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1626
		return -- 1627
	end -- 1627
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1629
	if self.scavX >= s.x1 then -- 1629
		self.scavX = s.x1 -- 1631
		self.scavDir = -1 -- 1632
	elseif self.scavX <= s.x0 then -- 1632
		self.scavX = s.x0 -- 1634
		self.scavDir = 1 -- 1635
	end -- 1635
end -- 1591
function Play.prototype.stepCart(self, dt, input) -- 1643
	local p = self.player -- 1644
	local c = self.room.cart -- 1645
	local handleX = self.cartAxle + c.handleOffset -- 1646
	if self.gripping then -- 1646
		if not input.interact.held then -- 1646
			self.gripping = false -- 1650
			self:flashSet("松开车把", 0.4) -- 1651
			return -- 1652
		end -- 1652
	else -- 1652
		if not input.interact.pressed then -- 1652
			return -- 1656
		end -- 1656
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1656
			return -- 1659
		end -- 1659
		self.gripping = true -- 1661
		self:flashSet("握住车把", 0.4) -- 1662
		return -- 1663
	end -- 1663
	if self.cartDocked then -- 1663
		return -- 1667
	end -- 1667
	local dir = input.moveX -- 1669
	if dir == 0 then -- 1669
		return -- 1671
	end -- 1671
	local lo = math.min(c.startX, c.endX) -- 1673
	local hi = math.max(c.startX, c.endX) -- 1674
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1675
	if next < lo then -- 1675
		next = lo -- 1677
	end -- 1677
	if next > hi then -- 1677
		next = hi -- 1680
	end -- 1680
	local delta = next - self.cartAxle -- 1682
	if delta == 0 then -- 1682
		return -- 1684
	end -- 1684
	self.cartAxle = next -- 1686
	p.x = p.x + delta -- 1687
	p.facing = dir > 0 and 1 or -1 -- 1688
	self:slideX(p, 0) -- 1689
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1689
		self.gripping = false -- 1691
		self:flashSet("跟不上了，脱手", 0.6) -- 1692
		return -- 1693
	end -- 1693
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1693
		self.cartDocked = true -- 1696
		self.gripping = false -- 1697
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1698
		self:flashSet("车轮落窝", 1.2) -- 1699
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1699
		self:flashSet("车轮回到起点", 0.5) -- 1701
	end -- 1701
end -- 1643
function Play.prototype.requestRoom(self, key, reason) -- 1709
	if self.wantRoom ~= "" then -- 1709
		return -- 1713
	end -- 1713
	self.wantRoom = key -- 1715
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1716
end -- 1709
function Play.prototype.checkCarryGate(self) -- 1723
	if self.room.key == "checkpoint" then -- 1723
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1723
			self.carryCartAxle = self.cartAxle -- 1726
			self.carryCartDocked = self.cartDocked -- 1727
			self:requestRoom("gate", "检查站出口") -- 1728
			self:flashSet("出检查站 · 城门", 1.2) -- 1729
		end -- 1729
		return -- 1731
	end -- 1731
	if self.room.key == "outside" then -- 1731
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1731
			self.carryCartAxle = self.cartAxle -- 1737
			self.carryCartDocked = self.cartDocked -- 1738
			self:requestRoom("village", "墙根走完") -- 1739
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1740
		end -- 1740
	end -- 1740
end -- 1723
function Play.prototype.aimAt(self, wx, wy) -- 1747
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1748
	self.aimX = s.x -- 1749
	self.aimY = s.y -- 1750
end -- 1747
function Play.prototype.shoot(self, a) -- 1753
	local ox = a.x + a.facing * 8 -- 1754
	local oy = a.y + a.h * 0.72 -- 1755
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1757
	local dx = aim.x - ox -- 1758
	local dy = aim.y - oy -- 1759
	local len = math.sqrt(dx * dx + dy * dy) -- 1760
	if len < 0.001 then -- 1760
		dx = a.facing -- 1762
		dy = 0 -- 1763
	else -- 1763
		dx = dx / len -- 1765
		dy = dy / len -- 1766
	end -- 1766
	if dx ~= 0 then -- 1766
		a.facing = dx > 0 and 1 or -1 -- 1769
	end -- 1769
	local hitEnemy = self:raycast( -- 1772
		ox, -- 1772
		oy, -- 1772
		dx, -- 1772
		dy, -- 1772
		true -- 1772
	) -- 1772
	local hitWall = self:raycast( -- 1773
		ox, -- 1773
		oy, -- 1773
		dx, -- 1773
		dy, -- 1773
		false -- 1773
	) -- 1773
	local tEnemy = hitEnemy.t -- 1774
	local tWall = hitWall.t -- 1775
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1776
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1777
	self.trace = { -- 1779
		x0 = ox, -- 1779
		y0 = oy, -- 1779
		x1 = ox + dx * t, -- 1779
		y1 = oy + dy * t, -- 1779
		hit = hit -- 1779
	} -- 1779
	self.traceT = 0.12 -- 1780
	self:applyFireDanger(ox) -- 1781
	if hit then -- 1781
		local i = hitEnemy.index -- 1783
		local e = self.enemies[i + 1] -- 1784
		e.alive = false -- 1785
		e.hitT = 0.4 -- 1786
		self:flashSet("命中", 0.6) -- 1787
	else -- 1787
		self:flashSet("打空", 0.35) -- 1789
	end -- 1789
	self:emit("shotResolved", { -- 1791
		hit = hit, -- 1792
		enemyIndex = hit and hitEnemy.index or -1, -- 1793
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1794
		aimX = aim.x, -- 1795
		aimY = aim.y, -- 1796
		impactX = ox + dx * t, -- 1797
		impactY = oy + dy * t -- 1798
	}) -- 1798
end -- 1753
function Play.prototype.applyFireDanger(self, shotX) -- 1803
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1803
		return -- 1805
	end -- 1805
	local dangerX = shotX -- 1807
	local best = -1 -- 1808
	local bestD = 1000000000 -- 1809
	local i = 0 -- 1810
	do -- 1810
		i = 0 -- 1811
		while i < #self.enemies do -- 1811
			do -- 1811
				local e = self.enemies[i + 1] -- 1812
				if not e.alive then -- 1812
					goto __continue301 -- 1814
				end -- 1814
				local d = math.abs(e.x - self.partner.x) -- 1816
				if d < bestD then -- 1816
					bestD = d -- 1818
					best = i -- 1819
				end -- 1819
			end -- 1819
			::__continue301:: -- 1819
			i = i + 1 -- 1811
		end -- 1811
	end -- 1811
	if best >= 0 then -- 1811
		dangerX = self.enemies[best + 1].x -- 1823
	end -- 1823
	local exposed = self:childExposed(dangerX) -- 1825
	local before = self.escort.fear -- 1826
	local dangerId = self.nextDangerId -- 1827
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1828
	self.nextDangerId = self.nextDangerId + 1 -- 1829
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1830
	if after > before then -- 1830
		self:flashSet( -- 1832
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1832
			1 -- 1832
		) -- 1832
	elseif not exposed then -- 1832
		self:flashSet("枪声没够到她", 0.5) -- 1834
	end -- 1834
end -- 1803
function Play.prototype.childExposed(self, dangerX) -- 1839
	local c = self.partner -- 1840
	if not c.alive then -- 1840
		return false -- 1842
	end -- 1842
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1842
		return false -- 1845
	end -- 1845
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1845
		return false -- 1848
	end -- 1848
	local toDanger = dangerX - c.x -- 1850
	local toPlayer = self.player.x - c.x -- 1851
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1851
		return false -- 1853
	end -- 1853
	return true -- 1855
end -- 1839
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1859
	local best = -1 -- 1860
	local bestI = -1 -- 1861
	local i = 0 -- 1862
	if enemies then -- 1862
		do -- 1862
			i = 0 -- 1864
			while i < #self.enemies do -- 1864
				do -- 1864
					local e = self.enemies[i + 1] -- 1865
					if not e.alive then -- 1865
						goto __continue315 -- 1867
					end -- 1867
					local t = hitBox( -- 1869
						ox, -- 1869
						oy, -- 1869
						dx, -- 1869
						dy, -- 1869
						e.x - e.w / 2, -- 1869
						e.x + e.w / 2, -- 1869
						e.y, -- 1869
						e.y + e.h -- 1869
					) -- 1869
					if t >= 0 and (best < 0 or t < best) then -- 1869
						best = t -- 1871
						bestI = i -- 1872
					end -- 1872
				end -- 1872
				::__continue315:: -- 1872
				i = i + 1 -- 1864
			end -- 1864
		end -- 1864
		return {t = best, index = bestI} -- 1875
	end -- 1875
	do -- 1875
		i = 0 -- 1877
		while i < #self.boxes do -- 1877
			local b = self.boxes[i + 1] -- 1878
			local t = hitBox( -- 1879
				ox, -- 1879
				oy, -- 1879
				dx, -- 1879
				dy, -- 1879
				b.x0, -- 1879
				b.x1, -- 1879
				b.y0, -- 1879
				b.y1 -- 1879
			) -- 1879
			if t >= 0 and (best < 0 or t < best) then -- 1879
				best = t -- 1881
			end -- 1881
			i = i + 1 -- 1877
		end -- 1877
	end -- 1877
	if dy < 0 then -- 1877
		local t = (0 - oy) / dy -- 1886
		if t >= 0 and (best < 0 or t < best) then -- 1886
			best = t -- 1888
		end -- 1888
	end -- 1888
	return {t = best, index = -1} -- 1891
end -- 1859
function Play.prototype.slideX(self, a, dx) -- 1895
	local nx = a.x + dx -- 1896
	local half = a.w / 2 -- 1897
	local room = self.room -- 1898
	nx = math.max( -- 1899
		room.minX + half, -- 1899
		math.min(room.maxX - half, nx) -- 1899
	) -- 1899
	local i = 0 -- 1900
	do -- 1900
		i = 0 -- 1901
		while i < #self.boxes do -- 1901
			do -- 1901
				local b = self.boxes[i + 1] -- 1902
				if b.passable == true then -- 1902
					goto __continue325 -- 1904
				end -- 1904
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1904
					goto __continue325 -- 1907
				end -- 1907
				if nx + half > b.x0 and nx - half < b.x1 then -- 1907
					if a.x <= b.x0 then -- 1907
						nx = b.x0 - half -- 1911
					elseif a.x >= b.x1 then -- 1911
						nx = b.x1 + half -- 1913
					else -- 1913
						nx = a.x -- 1915
					end -- 1915
				end -- 1915
			end -- 1915
			::__continue325:: -- 1915
			i = i + 1 -- 1901
		end -- 1901
	end -- 1901
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1901
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1923
		local bx0 = self.cartAxle - CART_HALF -- 1924
		local bx1 = self.cartAxle + CART_HALF -- 1925
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1925
			if a.x <= bx0 then -- 1925
				nx = bx0 - half -- 1928
			elseif a.x >= bx1 then -- 1928
				nx = bx1 + half -- 1930
			else -- 1930
				nx = a.x -- 1932
			end -- 1932
		end -- 1932
	end -- 1932
	local arch = room.arch -- 1940
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1940
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1942
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1942
			if a.x <= arch.x0 then -- 1942
				nx = arch.x0 - half -- 1945
			elseif a.x >= arch.x1 then -- 1945
				nx = arch.x1 + half -- 1947
			end -- 1947
		end -- 1947
	end -- 1947
	a.x = nx -- 1951
end -- 1895
function Play.prototype.fallY(self, a, dt) -- 1955
	a.vy = a.vy - ____exports.GRAVITY * dt -- 1956
	if a.vy < -900 then -- 1956
		a.vy = -900 -- 1958
	end -- 1958
	local ny = a.y + a.vy * dt -- 1960
	local half = a.w / 2 -- 1961
	if a.vy <= 0 then -- 1961
		local reach = a.onGround and STEP_UP or 0 -- 1964
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1965
		if ny <= ground then -- 1965
			ny = ground -- 1967
			a.vy = 0 -- 1968
			a.onGround = true -- 1969
		else -- 1969
			a.onGround = false -- 1971
		end -- 1971
	else -- 1971
		a.onGround = false -- 1974
		local i = 0 -- 1975
		do -- 1975
			i = 0 -- 1976
			while i < #self.boxes do -- 1976
				do -- 1976
					local b = self.boxes[i + 1] -- 1977
					if b.passable == true then -- 1977
						goto __continue348 -- 1979
					end -- 1979
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1979
						goto __continue348 -- 1982
					end -- 1982
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1982
						ny = b.y0 - a.h -- 1985
						a.vy = 0 -- 1986
					end -- 1986
				end -- 1986
				::__continue348:: -- 1986
				i = i + 1 -- 1976
			end -- 1976
		end -- 1976
	end -- 1976
	a.y = ny -- 1990
end -- 1955
function Play.prototype.groundAt(self, x, ceiling, half) -- 1994
	local g = -9999 -- 1995
	local i = 0 -- 1996
	do -- 1996
		i = 0 -- 1997
		while i < #self.floors do -- 1997
			local f = self.floors[i + 1] -- 1998
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1998
				g = f.y1 -- 2000
			end -- 2000
			i = i + 1 -- 1997
		end -- 1997
	end -- 1997
	do -- 1997
		i = 0 -- 2003
		while i < #self.boxes do -- 2003
			local b = self.boxes[i + 1] -- 2004
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 2004
				g = b.y1 -- 2006
			end -- 2006
			i = i + 1 -- 2003
		end -- 2003
	end -- 2003
	return g -- 2009
end -- 1994
function Play.prototype.updateCamera(self, dt) -- 2012
	local p = self.player -- 2013
	local tx = p.x + p.facing * 30 -- 2014
	local ty = p.y + CAM_LOOK_UP -- 2015
	local k = math.min(1, CAM_FOLLOW * dt) -- 2016
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2017
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2018
end -- 2012
function Play.prototype.clampCamera(self, w, h) -- 2022
	local room = self.room -- 2023
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2024
	local spanX = room.maxX - room.minX -- 2025
	if spanX <= halfW * 2 then -- 2025
		self.cam.x = (room.minX + room.maxX) / 2 -- 2027
	else -- 2027
		self.cam.x = math.max( -- 2029
			room.minX + halfW, -- 2029
			math.min(room.maxX - halfW, self.cam.x) -- 2029
		) -- 2029
	end -- 2029
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 2032
	local spanY = room.height -- 2033
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 2034
	if spanY <= halfH * 2 then -- 2034
		self.cam.y = camY -- 2036
	else -- 2036
		self.cam.y = math.max( -- 2038
			camY, -- 2038
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2038
		) -- 2038
	end -- 2038
end -- 2022
function Play.prototype.flashSet(self, text, t) -- 2042
	self.flash = text -- 2043
	self.flashT = t -- 2044
end -- 2042
function Play.prototype.statusText(self) -- 2048
	local p = self.player -- 2049
	local parts = {} -- 2050
	local who = self.childMode and "小满" or "周戍" -- 2051
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2052
	if self.room.key == "prologue" then -- 2052
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2055
		if self.phase == "prologue-wait" then -- 2055
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2057
		elseif self.phase == "prologue-give" then -- 2057
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2059
		else -- 2059
			parts[#parts + 1] = "跟随" -- 2061
		end -- 2061
		if self.paused then -- 2061
			parts[#parts + 1] = "已暂停" -- 2064
		end -- 2064
		return table.concat(parts, " · ") -- 2066
	end -- 2066
	if self.room.key == "street" then -- 2066
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2069
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2070
		if self.paused then -- 2070
			parts[#parts + 1] = "已暂停" -- 2072
		end -- 2072
		return table.concat(parts, " · ") -- 2074
	end -- 2074
	if self.room.key == "gate" then -- 2074
		local ____temp_13 -- 2077
		if self.room.story == nil then -- 2077
			____temp_13 = nil -- 2077
		else -- 2077
			____temp_13 = self.room.story.gate -- 2077
		end -- 2077
		local g = ____temp_13 -- 2077
		if g ~= nil then -- 2077
			parts[#parts + 1] = self:gateLabel() -- 2079
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2080
				0, -- 2081
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2081
			))) .. " 秒" -- 2081
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2082
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2083
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2084
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2085
			if self.gateFailCount > 0 then -- 2085
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2087
			end -- 2087
			if self.flash ~= "" then -- 2087
				parts[#parts + 1] = self.flash -- 2090
			end -- 2090
		end -- 2090
		if self.paused then -- 2090
			parts[#parts + 1] = "已暂停" -- 2094
		end -- 2094
		return table.concat(parts, " · ") -- 2096
	end -- 2096
	if self.room.key == "forest" then -- 2096
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2099
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2100
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2101
		if self.caughtT > 0 then -- 2101
			parts[#parts + 1] = "复位中" -- 2103
		end -- 2103
		if self.paused then -- 2103
			parts[#parts + 1] = "已暂停" -- 2106
		end -- 2106
		return table.concat(parts, " · ") -- 2108
	end -- 2108
	if self.room.key == "tower" then -- 2108
		if self.phase == "tower-wait" then -- 2108
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2112
		elseif self.phase == "tower-knock" then -- 2112
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2114
		elseif self.phase == "tower-given" then -- 2114
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2116
		else -- 2116
			parts[#parts + 1] = "片尾" -- 2118
		end -- 2118
		if self.paused then -- 2118
			parts[#parts + 1] = "已暂停" -- 2121
		end -- 2121
		return table.concat(parts, " · ") -- 2123
	end -- 2123
	if self.room.key == "village" then -- 2123
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2126
		if self.hasBottle then -- 2126
			parts[#parts + 1] = "有瓶" -- 2128
		elseif self.bottleFly ~= nil then -- 2128
			parts[#parts + 1] = "瓶在飞" -- 2130
		else -- 2130
			parts[#parts + 1] = "空手" -- 2132
		end -- 2132
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2134
		if self.scavChase then -- 2134
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2136
		end -- 2136
		if self.passed then -- 2136
			parts[#parts + 1] = "已过通行线" -- 2139
		end -- 2139
		if self.paused then -- 2139
			parts[#parts + 1] = "已暂停" -- 2142
		end -- 2142
		return table.concat(parts, " · ") -- 2144
	end -- 2144
	local isChild = self.childMode -- 2147
	if isChild then -- 2147
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2149
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2150
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2151
	else -- 2151
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2153
		if p.rollT > 0 then -- 2153
			parts[#parts + 1] = "翻滚中" -- 2155
		end -- 2155
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2157
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2158
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2159
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2160
	end -- 2160
	if self.checkpoint >= 0 then -- 2160
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2163
	end -- 2163
	if self.paused then -- 2163
		parts[#parts + 1] = "已暂停" -- 2166
	end -- 2166
	return table.concat(parts, " · ") -- 2168
end -- 2048
function Play.prototype.aliveEnemies(self) -- 2172
	local n = 0 -- 2173
	local i = 0 -- 2174
	do -- 2174
		i = 0 -- 2175
		while i < #self.enemies do -- 2175
			if self.enemies[i + 1].alive then -- 2175
				n = n + 1 -- 2177
			end -- 2177
			i = i + 1 -- 2175
		end -- 2175
	end -- 2175
	return n -- 2180
end -- 2172
function Play.prototype.threatened(self) -- 2185
	do -- 2185
		local i = 0 -- 2186
		while i < #self.enemies do -- 2186
			local e = self.enemies[i + 1] -- 2187
			if e.alive and e.warnT > 0 then -- 2187
				return true -- 2189
			end -- 2189
			i = i + 1 -- 2186
		end -- 2186
	end -- 2186
	return false -- 2192
end -- 2185
function Play.prototype.gateSecondsLeft(self) -- 2195
	local ____temp_14 -- 2196
	if self.room.story == nil then -- 2196
		____temp_14 = nil -- 2196
	else -- 2196
		____temp_14 = self.room.story.gate -- 2196
	end -- 2196
	local g = ____temp_14 -- 2196
	if g == nil then -- 2196
		return 0 -- 2198
	end -- 2198
	return math.max( -- 2200
		0, -- 2200
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2200
	) -- 2200
end -- 2195
function Play.prototype.gateLabel(self) -- 2203
	if self.phase == "gate-idle" then -- 2203
		return "待就位" -- 2205
	end -- 2205
	if self.phase == "gate-hold" then -- 2205
		return "守点中" -- 2208
	end -- 2208
	if self.phase == "gate-send" then -- 2208
		return "送别" -- 2211
	end -- 2211
	if self.phase == "gate-count" then -- 2211
		return "数数 " .. tostring(self.countTick) -- 2214
	end -- 2214
	return "她走" -- 2216
end -- 2203
function Play.prototype.dogLabel(self) -- 2220
	if self.dogState == "ear" then -- 2220
		return "转耳" -- 2222
	end -- 2222
	if self.dogState == "chase" then -- 2222
		return "追" -- 2225
	end -- 2225
	if self.dogState == "sniff" then -- 2225
		return "停" -- 2228
	end -- 2228
	if self.dogState == "back" then -- 2228
		return "回线" -- 2231
	end -- 2231
	return "巡逻" -- 2233
end -- 2220
function Play.prototype.doorXOf(self) -- 2236
	local ____temp_15 -- 2237
	if self.room.story == nil then -- 2237
		____temp_15 = nil -- 2237
	else -- 2237
		____temp_15 = self.room.story.tower -- 2237
	end -- 2237
	local t = ____temp_15 -- 2237
	return t == nil and 0 or t.doorX -- 2238
end -- 2236
function Play.prototype.scavLabel(self) -- 2242
	if self.scavState == "chase" then -- 2242
		return "追" -- 2244
	end -- 2244
	if self.scavState == "turn" then -- 2244
		return "转头" -- 2247
	end -- 2247
	if self.scavState == "walk" then -- 2247
		return "赶来" -- 2250
	end -- 2250
	if self.scavState == "stall" then -- 2250
		return "停住" -- 2253
	end -- 2253
	if self.scavState == "back" then -- 2253
		return "回位" -- 2256
	end -- 2256
	return "巡逻" -- 2258
end -- 2242
function Play.prototype.hintText(self) -- 2262
	if self.paused then -- 2262
		return "Esc 继续 · R 重置" -- 2264
	end -- 2264
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2264
		if self:threatened() then -- 2264
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2270
		end -- 2270
		if self.coverHug then -- 2270
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2273
		end -- 2273
		if self.coverNear then -- 2273
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2276
		end -- 2276
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2278
	end -- 2278
	if self.flash ~= "" then -- 2278
		return self.flash -- 2281
	end -- 2281
	if self.room.key == "prologue" then -- 2281
		if self.phase == "prologue-wait" then -- 2281
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2285
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2286
		end -- 2286
		if self.phase == "prologue-give" then -- 2286
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2289
		end -- 2289
		return "她跟着你了 · 两人一起走到门口 680" -- 2291
	end -- 2291
	if self.room.key == "street" then -- 2291
		if self:aliveEnemies() > 0 then -- 2291
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2295
		end -- 2295
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2297
	end -- 2297
	if self.room.key == "gate" then -- 2297
		local ____temp_16 -- 2300
		if self.room.story == nil then -- 2300
			____temp_16 = nil -- 2300
		else -- 2300
			____temp_16 = self.room.story.gate -- 2300
		end -- 2300
		local g = ____temp_16 -- 2300
		if g ~= nil then -- 2300
			if self.phase == "gate-idle" then -- 2300
				if self.gateNeedConfirm then -- 2300
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2304
				end -- 2304
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2306
			end -- 2306
			if self.phase == "gate-hold" then -- 2306
				if self.coveredFlash > 0 then -- 2306
					return "掩体挡下了这一枪 · 别露头" -- 2310
				end -- 2310
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2312
			end -- 2312
			if self.phase == "gate-send" then -- 2312
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2315
			end -- 2315
			if self.phase == "gate-count" then -- 2315
				if self.countTick >= 1440 then -- 2315
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2319
				end -- 2319
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2321
			end -- 2321
			return "她自己走 · 跟着出城门 1120" -- 2323
		end -- 2323
	end -- 2323
	if self.room.key == "forest" then -- 2323
		if self.dogState == "chase" then -- 2323
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2328
		end -- 2328
		if self.dogState == "ear" then -- 2328
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2331
		end -- 2331
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2333
	end -- 2333
	if self.room.key == "tower" then -- 2333
		if self.phase == "tower-wait" then -- 2333
			return "走到门前 445 点一次 E 敲两下" -- 2337
		end -- 2337
		if self.phase == "tower-knock" then -- 2337
			return "敲两下 · 等门开" -- 2340
		end -- 2340
		if self.phase == "tower-given" then -- 2340
			return "递交针套和纸条 · 看登记簿最后一行" -- 2343
		end -- 2343
		return "片尾 · 点 E 再玩一次，回到序章" -- 2345
	end -- 2345
	if self.room.key == "village" then -- 2345
		if self.bottleFly ~= nil then -- 2345
			return "等瓶子落地 · 触地才发声" -- 2349
		end -- 2349
		if self.hasBottle then -- 2349
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2352
		end -- 2352
		if self.passed then -- 2352
			return "已过第一院 · R 重置可再来一遍" -- 2355
		end -- 2355
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2357
	end -- 2357
	if self.room.key == "outside" then -- 2357
		if self.focusCart then -- 2357
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2361
		end -- 2361
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2363
	end -- 2363
	if self.escort.state == "frozen" then -- 2363
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2363
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2367
		end -- 2367
		return "小满吓住了 · 走过去，靠近再点 E" -- 2369
	end -- 2369
	if self.escort.state == "calming" then -- 2369
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2372
	end -- 2372
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2374
end -- 2262
function Play.prototype.draw(self, draw, w, h) -- 2379
	self.viewW = w -- 2380
	self.viewH = h -- 2381
	self.view = ____exports.computeViewport(w, h) -- 2382
	self:clampCamera(w, h) -- 2383
	draw:clear() -- 2384
	draw:drawRect( -- 2386
		Rect(0, 0, w, h), -- 2386
		BG_VOID -- 2386
	) -- 2386
	local box = self:canvasRect(w, h) -- 2387
	draw:drawRect(box, BG_FAR) -- 2388
	draw:drawRect( -- 2389
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2389
		BG_MID -- 2389
	) -- 2389
	self:drawFloors(draw, w, h) -- 2391
	self:drawSolids(draw, w, h) -- 2392
	self:drawZones(draw, w, h) -- 2393
	self:drawArch(draw, w, h) -- 2394
	self:drawCart(draw, w, h) -- 2395
	self:drawActors(draw, w, h) -- 2396
	self:drawTrace(draw, w, h) -- 2397
	self:drawAim(draw, w, h) -- 2398
end -- 2379
function Play.prototype.canvasRect(self, w, h) -- 2402
	local v = self.view -- 2403
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2404
end -- 2402
function Play.prototype.px(self, n) -- 2408
	return n * self.view.zoom -- 2409
end -- 2408
function Play.prototype.sx(self, wx, w) -- 2413
	local v = self.view -- 2414
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2415
	return v.ox + lx * v.zoom -- 2416
end -- 2413
function Play.prototype.sy(self, wy, h) -- 2420
	local v = self.view -- 2421
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2422
	return v.oy + ly * v.zoom -- 2423
end -- 2420
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2426
	local px0 = self:sx(x0, w) -- 2427
	local px1 = self:sx(x1, w) -- 2428
	local py0 = self:sy(y0, h) -- 2429
	local py1 = self:sy(y1, h) -- 2430
	if px1 <= px0 or py1 <= py0 then -- 2430
		return -- 2432
	end -- 2432
	draw:drawRect( -- 2434
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2434
		color -- 2434
	) -- 2434
end -- 2426
function Play.prototype.drawFloors(self, draw, w, h) -- 2437
	local i = 0 -- 2438
	do -- 2438
		i = 0 -- 2439
		while i < #self.room.floors do -- 2439
			local f = self.room.floors[i + 1] -- 2440
			local y = self:sy(f.y, h) -- 2441
			local x0 = self:sx(f.x0, w) -- 2442
			local x1 = self:sx(f.x1, w) -- 2443
			local deck = self:px(5) -- 2444
			draw:drawRect( -- 2445
				Rect(x0, y - deck, x1 - x0, deck), -- 2445
				FLOOR_DECK -- 2445
			) -- 2445
			draw:drawSegment( -- 2446
				Vec2(x0, y), -- 2446
				Vec2(x1, y), -- 2446
				self:px(1), -- 2446
				GROUND -- 2446
			) -- 2446
			i = i + 1 -- 2439
		end -- 2439
	end -- 2439
end -- 2437
function Play.prototype.drawSolids(self, draw, w, h) -- 2450
	local i = 0 -- 2451
	do -- 2451
		i = 0 -- 2452
		while i < #self.boxes do -- 2452
			do -- 2452
				local b = self.boxes[i + 1] -- 2453
				if b.y0 < -4 and b.y1 <= 96 then -- 2453
					draw:drawSegment( -- 2456
						Vec2( -- 2456
							self:sx(b.x0, w), -- 2456
							self:sy(b.y1, h) -- 2456
						), -- 2456
						Vec2( -- 2456
							self:sx(b.x1, w), -- 2456
							self:sy(b.y1, h) -- 2456
						), -- 2456
						self:px(1), -- 2456
						GROUND -- 2456
					) -- 2456
					goto __continue476 -- 2457
				end -- 2457
				self:drawBox( -- 2459
					draw, -- 2459
					w, -- 2459
					h, -- 2459
					b.x0, -- 2459
					b.x1, -- 2459
					b.y0, -- 2459
					b.y1, -- 2459
					SOLID_FILL -- 2459
				) -- 2459
				draw:drawSegment( -- 2460
					Vec2( -- 2460
						self:sx(b.x0, w), -- 2460
						self:sy(b.y1, h) -- 2460
					), -- 2460
					Vec2( -- 2460
						self:sx(b.x1, w), -- 2460
						self:sy(b.y1, h) -- 2460
					), -- 2460
					self:px(1), -- 2460
					SOLID_EDGE -- 2460
				) -- 2460
			end -- 2460
			::__continue476:: -- 2460
			i = i + 1 -- 2452
		end -- 2452
	end -- 2452
end -- 2450
function Play.prototype.drawZones(self, draw, w, h) -- 2464
	local i = 0 -- 2465
	do -- 2465
		i = 0 -- 2466
		while i < #self.room.zones do -- 2466
			local z = self.room.zones[i + 1] -- 2467
			local fill = DANGER -- 2468
			local line = DANGER_LINE -- 2469
			if z.tint == 2 then -- 2469
				fill = SOFT -- 2471
				line = SOFT_LINE -- 2472
			elseif z.tint == 3 then -- 2472
				fill = BRICK -- 2474
				line = BRICK_LINE -- 2475
			elseif z.tint == 4 then -- 2475
				fill = PASS -- 2477
				line = PASS_LINE -- 2478
			end -- 2478
			self:drawBox( -- 2480
				draw, -- 2480
				w, -- 2480
				h, -- 2480
				z.x0, -- 2480
				z.x1, -- 2480
				z.y, -- 2480
				z.y + z.h, -- 2480
				fill -- 2480
			) -- 2480
			draw:drawSegment( -- 2481
				Vec2( -- 2481
					self:sx(z.x0, w), -- 2481
					self:sy(z.y, h) -- 2481
				), -- 2481
				Vec2( -- 2481
					self:sx(z.x0, w), -- 2481
					self:sy(z.y + z.h, h) -- 2481
				), -- 2481
				self:px(1), -- 2481
				line -- 2481
			) -- 2481
			draw:drawSegment( -- 2482
				Vec2( -- 2482
					self:sx(z.x1, w), -- 2482
					self:sy(z.y, h) -- 2482
				), -- 2482
				Vec2( -- 2482
					self:sx(z.x1, w), -- 2482
					self:sy(z.y + z.h, h) -- 2482
				), -- 2482
				self:px(1), -- 2482
				line -- 2482
			) -- 2482
			i = i + 1 -- 2466
		end -- 2466
	end -- 2466
end -- 2464
function Play.prototype.drawArch(self, draw, w, h) -- 2486
	local a = self.room.arch -- 2487
	if a.h <= 0 then -- 2487
		return -- 2489
	end -- 2489
	self:drawBox( -- 2491
		draw, -- 2491
		w, -- 2491
		h, -- 2491
		a.x0, -- 2491
		a.x1, -- 2491
		a.y, -- 2491
		a.y + a.h, -- 2491
		HOLE_FILL -- 2491
	) -- 2491
	draw:drawSegment( -- 2492
		Vec2( -- 2492
			self:sx(a.x0, w), -- 2492
			self:sy(a.y + a.h, h) -- 2492
		), -- 2492
		Vec2( -- 2492
			self:sx(a.x1, w), -- 2492
			self:sy(a.y + a.h, h) -- 2492
		), -- 2492
		self:px(1), -- 2492
		SOLID_EDGE -- 2492
	) -- 2492
	draw:drawSegment( -- 2493
		Vec2( -- 2493
			self:sx(a.x0, w), -- 2493
			self:sy(a.y, h) -- 2493
		), -- 2493
		Vec2( -- 2493
			self:sx(a.x0, w), -- 2493
			self:sy(a.y + a.h, h) -- 2493
		), -- 2493
		self:px(1), -- 2493
		SOLID_EDGE -- 2493
	) -- 2493
	draw:drawSegment( -- 2494
		Vec2( -- 2494
			self:sx(a.x1, w), -- 2494
			self:sy(a.y, h) -- 2494
		), -- 2494
		Vec2( -- 2494
			self:sx(a.x1, w), -- 2494
			self:sy(a.y + a.h, h) -- 2494
		), -- 2494
		self:px(1), -- 2494
		SOLID_EDGE -- 2494
	) -- 2494
end -- 2486
function Play.prototype.drawCart(self, draw, w, h) -- 2497
	local c = self.room.cart -- 2498
	if c.bodyW <= 0 then -- 2498
		return -- 2500
	end -- 2500
	drawCartShape( -- 2502
		draw, -- 2502
		self, -- 2502
		w, -- 2502
		h, -- 2502
		c, -- 2502
		self.cartAxle -- 2502
	) -- 2502
	draw:drawRect( -- 2503
		Rect( -- 2503
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2503
			self:sy(c.baseY + 40, h), -- 2503
			self:px(2), -- 2503
			self:px(40) -- 2503
		), -- 2503
		STAND -- 2503
	) -- 2503
end -- 2497
function Play.prototype.drawActors(self, draw, w, h) -- 2506
	local p = self.player -- 2507
	local isChild = self.childMode -- 2508
	if p.covered then -- 2508
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2511
		draw:drawSegment( -- 2512
			Vec2( -- 2512
				self:sx(edge, w), -- 2512
				self:sy(p.y + 8, h) -- 2512
			), -- 2512
			Vec2( -- 2512
				self:sx(edge, w), -- 2512
				self:sy(p.y + p.h * 0.62, h) -- 2512
			), -- 2512
			self:px(2), -- 2512
			STAND -- 2512
		) -- 2512
		draw:drawSegment( -- 2514
			Vec2( -- 2514
				self:sx(p.x - 8, w), -- 2514
				self:sy(p.y + p.h + 3, h) -- 2514
			), -- 2514
			Vec2( -- 2514
				self:sx(p.x + 8, w), -- 2514
				self:sy(p.y + p.h + 3, h) -- 2514
			), -- 2514
			self:px(2), -- 2514
			STAND -- 2514
		) -- 2514
	elseif self.coverNear and not isChild then -- 2514
		draw:drawRect( -- 2517
			Rect( -- 2517
				self:sx(p.x - 3, w), -- 2517
				self:sy(p.y + 1, h), -- 2517
				self:px(3), -- 2517
				self:px(3) -- 2517
			), -- 2517
			STAND -- 2517
		) -- 2517
	end -- 2517
	drawFigure( -- 2519
		draw, -- 2519
		self, -- 2519
		w, -- 2519
		h, -- 2519
		p, -- 2519
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2519
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2519
	) -- 2519
	local q = self.partner -- 2520
	if q.alive then -- 2520
		local childPartner = q.w == CHILD_W -- 2522
		drawFigure( -- 2523
			draw, -- 2523
			self, -- 2523
			w, -- 2523
			h, -- 2523
			q, -- 2523
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2523
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2523
		) -- 2523
	end -- 2523
	local i = 0 -- 2525
	do -- 2525
		i = 0 -- 2526
		while i < #self.enemies do -- 2526
			local e = self.enemies[i + 1] -- 2527
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2528
			self:drawBox( -- 2529
				draw, -- 2529
				w, -- 2529
				h, -- 2529
				e.x - e.w / 2, -- 2529
				e.x + e.w / 2, -- 2529
				e.y, -- 2529
				e.y + e.h, -- 2529
				col -- 2529
			) -- 2529
			if e.alive and e.warnT > 0 then -- 2529
				local gunX = self:sx(e.x, w) -- 2532
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2533
				local aimX = self:sx(p.x, w) -- 2534
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2535
				local seg = 8 -- 2536
				local s = 0 -- 2537
				do -- 2537
					s = 0 -- 2538
					while s < seg do -- 2538
						local t0 = s / seg -- 2539
						local t1 = (s + 1) / seg -- 2540
						draw:drawSegment( -- 2541
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2542
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2543
							self:px(1), -- 2544
							DANGER -- 2544
						) -- 2544
						s = s + 2 -- 2538
					end -- 2538
				end -- 2538
			end -- 2538
			i = i + 1 -- 2526
		end -- 2526
	end -- 2526
	local k = 0 -- 2549
	do -- 2549
		k = 0 -- 2550
		while k < #self.room.marks do -- 2550
			do -- 2550
				local m = self.room.marks[k + 1] -- 2551
				if m.kind ~= 0 then -- 2551
					goto __continue498 -- 2553
				end -- 2553
				local on = self.checkpoint == m.x -- 2555
				local x = self:sx(m.x, w) -- 2556
				local y = self:sy(m.y, h) -- 2557
				draw:drawSegment( -- 2558
					Vec2(x, y), -- 2558
					Vec2( -- 2558
						x, -- 2558
						y + self:px(35) -- 2558
					), -- 2558
					self:px(1), -- 2558
					on and CHECK or INK_DIM -- 2558
				) -- 2558
				draw:drawDot( -- 2559
					Vec2( -- 2559
						x, -- 2559
						y + self:px(35) -- 2559
					), -- 2559
					self:px(2), -- 2559
					on and CHECK or INK_DIM -- 2559
				) -- 2559
			end -- 2559
			::__continue498:: -- 2559
			k = k + 1 -- 2550
		end -- 2550
	end -- 2550
	local j = 0 -- 2563
	do -- 2563
		j = 0 -- 2564
		while j < #self.room.marks do -- 2564
			do -- 2564
				local m = self.room.marks[j + 1] -- 2565
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2565
					goto __continue501 -- 2567
				end -- 2567
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2567
					goto __continue501 -- 2571
				end -- 2571
				local col = STAND -- 2573
				if m.kind == 4 then -- 2573
					col = PASS_LINE -- 2575
				elseif m.kind == 5 then -- 2575
					col = BRICK_LINE -- 2577
				end -- 2577
				local mx = self:sx(m.x, w) -- 2579
				local my = self:sy(m.y, h) -- 2580
				draw:drawSegment( -- 2581
					Vec2(mx, my), -- 2581
					Vec2( -- 2581
						mx, -- 2581
						my + self:px(24) -- 2581
					), -- 2581
					self:px(1), -- 2581
					col -- 2581
				) -- 2581
			end -- 2581
			::__continue501:: -- 2581
			j = j + 1 -- 2564
		end -- 2564
	end -- 2564
	local t = 0 -- 2584
	do -- 2584
		t = 0 -- 2585
		while t < #self.room.marks do -- 2585
			do -- 2585
				local m = self.room.marks[t + 1] -- 2586
				if m.kind ~= 6 then -- 2586
					goto __continue507 -- 2588
				end -- 2588
				local mx = self:sx(m.x, w) -- 2590
				local my = self:sy(m.y, h) -- 2591
				draw:drawSegment( -- 2592
					Vec2(mx, my), -- 2592
					Vec2( -- 2592
						mx, -- 2592
						my + self:px(30) -- 2592
					), -- 2592
					self:px(1), -- 2592
					INK_DIM -- 2592
				) -- 2592
				self:drawBox( -- 2593
					draw, -- 2593
					w, -- 2593
					h, -- 2593
					m.x - 5, -- 2593
					m.x + 5, -- 2593
					m.y + 30, -- 2593
					m.y + 40, -- 2593
					CHECK -- 2593
				) -- 2593
			end -- 2593
			::__continue507:: -- 2593
			t = t + 1 -- 2585
		end -- 2585
	end -- 2585
	if self.room.key == "village" then -- 2585
		self:drawVillage(draw, w, h) -- 2596
	end -- 2596
	if self.room.key == "forest" then -- 2596
		self:drawDog(draw, w, h) -- 2599
	end -- 2599
end -- 2506
function Play.prototype.drawDog(self, draw, w, h) -- 2604
	local x = self.dogX -- 2605
	self:drawBox( -- 2606
		draw, -- 2606
		w, -- 2606
		h, -- 2606
		x - 14, -- 2606
		x + 14, -- 2606
		0, -- 2606
		20, -- 2606
		SCAV_BODY -- 2606
	) -- 2606
	self:drawBox( -- 2607
		draw, -- 2607
		w, -- 2607
		h, -- 2607
		x - 10, -- 2607
		x - 2, -- 2607
		20, -- 2607
		30, -- 2607
		SCAV_BODY -- 2607
	) -- 2607
	self:drawBox( -- 2608
		draw, -- 2608
		w, -- 2608
		h, -- 2608
		x + 2, -- 2608
		x + 10, -- 2608
		20, -- 2608
		30, -- 2608
		SCAV_HEAD -- 2608
	) -- 2608
	if self.dogState == "ear" or self.dogState == "chase" then -- 2608
		draw:drawSegment( -- 2610
			Vec2( -- 2610
				self:sx(x, w), -- 2610
				self:sy(30, h) -- 2610
			), -- 2610
			Vec2( -- 2611
				self:sx(x, w), -- 2611
				self:sy(40, h) -- 2611
			), -- 2611
			self:px(1), -- 2611
			DANGER -- 2611
		) -- 2611
	end -- 2611
end -- 2604
function Play.prototype.drawVillage(self, draw, w, h) -- 2616
	local bottle = self.room.bottle -- 2617
	if bottle ~= nil then -- 2617
		self:drawBox( -- 2619
			draw, -- 2619
			w, -- 2619
			h, -- 2619
			bottle.x - 14, -- 2619
			bottle.x + 14, -- 2619
			0, -- 2619
			64, -- 2619
			SOLID_FILL -- 2619
		) -- 2619
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2619
			self:drawBottle( -- 2621
				draw, -- 2621
				w, -- 2621
				h, -- 2621
				bottle.x, -- 2621
				64 -- 2621
			) -- 2621
		end -- 2621
	end -- 2621
	self:drawBox( -- 2625
		draw, -- 2625
		w, -- 2625
		h, -- 2625
		300, -- 2625
		420, -- 2625
		44, -- 2625
		50, -- 2625
		FLOOR_DECK -- 2625
	) -- 2625
	self:drawBox( -- 2626
		draw, -- 2626
		w, -- 2626
		h, -- 2626
		300, -- 2626
		306, -- 2626
		0, -- 2626
		44, -- 2626
		FLOOR_DECK -- 2626
	) -- 2626
	self:drawBox( -- 2627
		draw, -- 2627
		w, -- 2627
		h, -- 2627
		414, -- 2627
		420, -- 2627
		0, -- 2627
		44, -- 2627
		FLOOR_DECK -- 2627
	) -- 2627
	local s = self.room.scavenger -- 2629
	if s ~= nil then -- 2629
		local sx0 = self.scavX -- 2631
		self:drawBox( -- 2632
			draw, -- 2632
			w, -- 2632
			h, -- 2632
			sx0 - 12, -- 2632
			sx0 + 12, -- 2632
			0, -- 2632
			s.h - 14, -- 2632
			SCAV_BODY -- 2632
		) -- 2632
		self:drawBox( -- 2633
			draw, -- 2633
			w, -- 2633
			h, -- 2633
			sx0 - 7, -- 2633
			sx0 + 7, -- 2633
			s.h - 14, -- 2633
			s.h, -- 2633
			SCAV_HEAD -- 2633
		) -- 2633
		if self.scavState == "turn" then -- 2633
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2635
			draw:drawSegment( -- 2636
				Vec2( -- 2636
					self:sx(sx0, w), -- 2636
					self:sy(s.h - 6, h) -- 2636
				), -- 2636
				Vec2( -- 2636
					self:sx(fx, w), -- 2636
					self:sy(s.h - 6, h) -- 2636
				), -- 2636
				self:px(1), -- 2636
				INK -- 2636
			) -- 2636
		end -- 2636
	end -- 2636
	if self.hasBottle then -- 2636
		local p = self.player -- 2641
		self:drawBottle( -- 2642
			draw, -- 2642
			w, -- 2642
			h, -- 2642
			p.x + p.facing * 10, -- 2642
			p.y + p.h * 0.62 -- 2642
		) -- 2642
	end -- 2642
	if self.bottleFly ~= nil then -- 2642
		self:drawBottle( -- 2645
			draw, -- 2645
			w, -- 2645
			h, -- 2645
			self.bottleFly.x, -- 2645
			self.bottleFly.y -- 2645
		) -- 2645
	end -- 2645
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2645
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2648
		draw:drawCircle( -- 2649
			Vec2( -- 2649
				self:sx(self.bottleLandX, w), -- 2649
				self:sy(0, h) -- 2649
			), -- 2649
			self:px(r / ____exports.UNITS_PER_PX), -- 2649
			BRICK_LINE -- 2649
		) -- 2649
	end -- 2649
end -- 2616
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2653
	self:drawBox( -- 2654
		draw, -- 2654
		w, -- 2654
		h, -- 2654
		x - 3, -- 2654
		x + 3, -- 2654
		y - 10, -- 2654
		y, -- 2654
		BOTTLE -- 2654
	) -- 2654
end -- 2653
function Play.prototype.drawTrace(self, draw, w, h) -- 2657
	local t = self.trace -- 2658
	if t == nil or self.traceT <= 0 then -- 2658
		return -- 2660
	end -- 2660
	draw:drawSegment( -- 2662
		Vec2( -- 2663
			self:sx(t.x0, w), -- 2663
			self:sy(t.y0, h) -- 2663
		), -- 2663
		Vec2( -- 2664
			self:sx(t.x1, w), -- 2664
			self:sy(t.y1, h) -- 2664
		), -- 2664
		self:px(1), -- 2665
		t.hit and AIM_HIT or INK_DIM -- 2665
	) -- 2665
end -- 2657
function Play.prototype.drawAim(self, draw, w, h) -- 2668
	local v = self.view -- 2670
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2671
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2672
	local dot = self:px(1) -- 2673
	local arm = self:px(3) -- 2674
	local gap = self:px(1) -- 2675
	draw:drawSegment( -- 2676
		Vec2(gx - arm - gap, gy), -- 2676
		Vec2(gx - gap, gy), -- 2676
		dot / 2, -- 2676
		AIM -- 2676
	) -- 2676
	draw:drawSegment( -- 2677
		Vec2(gx + gap, gy), -- 2677
		Vec2(gx + arm + gap, gy), -- 2677
		dot / 2, -- 2677
		AIM -- 2677
	) -- 2677
	draw:drawSegment( -- 2678
		Vec2(gx, gy - arm - gap), -- 2678
		Vec2(gx, gy - gap), -- 2678
		dot / 2, -- 2678
		AIM -- 2678
	) -- 2678
	draw:drawSegment( -- 2679
		Vec2(gx, gy + gap), -- 2679
		Vec2(gx, gy + arm + gap), -- 2679
		dot / 2, -- 2679
		AIM -- 2679
	) -- 2679
	if self.room.key == "village" and self.hasBottle then -- 2679
		local p = self.player -- 2683
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2685
		local dir = ____end.x >= p.x and 1 or -1 -- 2686
		local x0 = p.x + dir * 10 -- 2687
		local y0 = p.y + p.h * 0.7 -- 2688
		local T = BOTTLE_FLY_TIME -- 2689
		local vx = (____end.x - x0) / T -- 2690
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2691
		local pxr = x0 -- 2692
		local pyr = y0 -- 2693
		local t = 1 -- 2694
		do -- 2694
			t = 1 -- 2695
			while t <= 12 do -- 2695
				local tt = t / 12 * T -- 2696
				local nx = x0 + vx * tt -- 2697
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2698
				draw:drawSegment( -- 2699
					Vec2( -- 2699
						self:sx(pxr, w), -- 2699
						self:sy(pyr, h) -- 2699
					), -- 2699
					Vec2( -- 2699
						self:sx(nx, w), -- 2699
						self:sy(ny, h) -- 2699
					), -- 2699
					self:px(1) / 2, -- 2699
					BOTTLE -- 2699
				) -- 2699
				pxr = nx -- 2700
				pyr = ny -- 2701
				t = t + 1 -- 2695
			end -- 2695
		end -- 2695
		draw:drawCircle( -- 2703
			Vec2( -- 2703
				self:sx(____end.x, w), -- 2703
				self:sy(____end.y + 2, h) -- 2703
			), -- 2703
			self:px(2), -- 2703
			BOTTLE -- 2703
		) -- 2703
	end -- 2703
end -- 2668
return ____exports -- 2668