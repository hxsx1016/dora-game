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
function makeActor(room, index) -- 2714
	local sp = room.spawns -- 2715
	if index < 0 or index >= #sp then -- 2715
		return { -- 2717
			x = 0, -- 2717
			y = 0, -- 2717
			vx = 0, -- 2717
			vy = 0, -- 2717
			w = CHILD_W, -- 2717
			h = CHILD_H, -- 2717
			onGround = true, -- 2717
			facing = 1, -- 2717
			crouch = false, -- 2717
			rollT = 0, -- 2717
			covered = false, -- 2717
			alive = false -- 2717
		} -- 2717
	end -- 2717
	local s = sp[index + 1] -- 2719
	local child = s.h <= CHILD_H -- 2720
	return { -- 2721
		x = s.x, -- 2722
		y = s.y, -- 2722
		vx = 0, -- 2722
		vy = 0, -- 2722
		w = child and CHILD_W or SOLDIER_W, -- 2723
		h = child and CHILD_H or SOLDIER_H, -- 2724
		onGround = true, -- 2725
		facing = 1, -- 2725
		crouch = false, -- 2725
		rollT = 0, -- 2725
		covered = false, -- 2725
		alive = true -- 2725
	} -- 2725
end -- 2725
function drawFigure(draw, play, w, h, a, body, head) -- 2729
	if not a.alive then -- 2729
		return -- 2731
	end -- 2731
	local x0 = a.x - a.w / 2 -- 2733
	local x1 = a.x + a.w / 2 -- 2734
	local y0 = a.y -- 2735
	local y1 = a.y + a.h -- 2736
	play:drawBox( -- 2737
		draw, -- 2737
		w, -- 2737
		h, -- 2737
		x0, -- 2737
		x1, -- 2737
		y0, -- 2737
		y1 - a.h * 0.26, -- 2737
		body -- 2737
	) -- 2737
	play:drawBox( -- 2738
		draw, -- 2738
		w, -- 2738
		h, -- 2738
		x0 + 2, -- 2738
		x1 - 2, -- 2738
		y1 - a.h * 0.26, -- 2738
		y1, -- 2738
		head -- 2738
	) -- 2738
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2740
	play:drawBox( -- 2741
		draw, -- 2741
		w, -- 2741
		h, -- 2741
		eyeX, -- 2741
		eyeX + 4, -- 2741
		y1 - a.h * 0.14, -- 2741
		y1 - a.h * 0.08, -- 2741
		INK -- 2741
	) -- 2741
end -- 2741
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2745
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2746
end -- 2745
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2753
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2754
end -- 2753
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2761
	local tmin = 0 -- 2762
	local tmax = 99999 -- 2763
	if dx == 0 then -- 2763
		if ox < x0 or ox > x1 then -- 2763
			return -1 -- 2766
		end -- 2766
	else -- 2766
		local t1 = (x0 - ox) / dx -- 2769
		local t2 = (x1 - ox) / dx -- 2770
		local lo = t1 < t2 and t1 or t2 -- 2771
		local hi = t1 < t2 and t2 or t1 -- 2772
		if lo > tmin then -- 2772
			tmin = lo -- 2774
		end -- 2774
		if hi < tmax then -- 2774
			tmax = hi -- 2777
		end -- 2777
	end -- 2777
	if dy == 0 then -- 2777
		if oy < y0 or oy > y1 then -- 2777
			return -1 -- 2782
		end -- 2782
	else -- 2782
		local t1 = (y0 - oy) / dy -- 2785
		local t2 = (y1 - oy) / dy -- 2786
		local lo = t1 < t2 and t1 or t2 -- 2787
		local hi = t1 < t2 and t2 or t1 -- 2788
		if lo > tmin then -- 2788
			tmin = lo -- 2790
		end -- 2790
		if hi < tmax then -- 2790
			tmax = hi -- 2793
		end -- 2793
	end -- 2793
	return tmax >= tmin and tmin or -1 -- 2796
end -- 2796
function drawCartShape(draw, play, w, h, c, axleX) -- 2799
	local half = c.bodyW / 2 -- 2800
	local x0 = axleX - half -- 2801
	local x1 = axleX + half -- 2802
	play:drawBox( -- 2803
		draw, -- 2803
		w, -- 2803
		h, -- 2803
		x0, -- 2803
		x1, -- 2803
		c.baseY + c.wheelR, -- 2803
		c.baseY + c.wheelR + c.bodyH, -- 2803
		CART_FILL -- 2803
	) -- 2803
	draw:drawCircle( -- 2804
		Vec2( -- 2804
			play:sx(x0 + c.bodyW * 0.28, w), -- 2804
			play:sy(c.baseY + c.wheelR, h) -- 2804
		), -- 2804
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2804
		Color(52, 50, 48, 255) -- 2804
	) -- 2804
	draw:drawCircle( -- 2805
		Vec2( -- 2805
			play:sx(x1 - c.bodyW * 0.28, w), -- 2805
			play:sy(c.baseY + c.wheelR, h) -- 2805
		), -- 2805
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2805
		Color(52, 50, 48, 255) -- 2805
	) -- 2805
	local cx = c.clothSide < 0 and x0 or x1 -- 2806
	play:drawBox( -- 2807
		draw, -- 2807
		w, -- 2807
		h, -- 2807
		cx - 10, -- 2807
		cx + 10, -- 2807
		c.baseY + c.wheelR + c.bodyH, -- 2807
		c.baseY + c.wheelR + c.bodyH + 18, -- 2807
		CLOTH -- 2807
	) -- 2807
end -- 2807
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
function Play.prototype.____constructor(self, room, resume) -- 362
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
	self.ox = room.originX -- 364
	self.room = withOrigin(room) -- 365
	local wr = self.room -- 366
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 367
	self:buildWorld() -- 368
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 370
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 371
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 372
	self.player = makeActor(wr, playerIdx) -- 373
	self.partner = makeActor(wr, partnerIdx) -- 374
	self.phase = phaseOf(wr.key) -- 375
	if wr.story ~= nil then -- 375
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 377
	end -- 377
	self.cam.x = self.player.x -- 379
	self.cam.y = self.player.y + CAM_LOOK_UP -- 380
	self.cartAxle = wr.cart.startX -- 381
	self.escort = __TS__New( -- 382
		Escort, -- 382
		safeAnchorX(wr.marks) -- 382
	) -- 382
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 383
	self:buildEnemies() -- 384
	if resume ~= nil and resume.checkpoint > 0 then -- 384
		self.checkpoint = resume.checkpoint -- 387
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 387
			self.cartAxle = self.room.cart.endX -- 389
			self.cartDocked = true -- 390
			self.player.x = self.ox + 380 -- 393
			self.player.y = 0 -- 394
			self.player.vy = 0 -- 395
			self.player.onGround = true -- 396
			self.cam.x = self.player.x -- 397
			self.cam.y = self.player.y + CAM_LOOK_UP -- 398
		end -- 398
	end -- 398
end -- 362
function Play.prototype.buildWorld(self) -- 404
	local room = self.room -- 405
	self.boxes = {} -- 406
	self.floors = {} -- 407
	local i = 0 -- 408
	do -- 408
		i = 0 -- 409
		while i < #room.floors do -- 409
			local f = room.floors[i + 1] -- 410
			local ____self_floors_0 = self.floors -- 410
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 411
			i = i + 1 -- 409
		end -- 409
	end -- 409
	do -- 409
		i = 0 -- 413
		while i < #room.solids do -- 413
			local s = room.solids[i + 1] -- 414
			local ____self_boxes_1 = self.boxes -- 414
			____self_boxes_1[#____self_boxes_1 + 1] = { -- 415
				x0 = s.x, -- 415
				x1 = s.x + s.w, -- 415
				y0 = s.y, -- 415
				y1 = s.y + s.h, -- 415
				passable = s.passable == true, -- 415
				label = s.label -- 415
			} -- 415
			i = i + 1 -- 413
		end -- 413
	end -- 413
	do -- 413
		i = 0 -- 417
		while i < #room.stairs do -- 417
			local st = room.stairs[i + 1] -- 418
			local n = st.steps + 1 -- 419
			local stepW = (st.x1 - st.x0) / n -- 420
			local k = 0 -- 421
			do -- 421
				k = 0 -- 422
				while k < n do -- 422
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 423
					local x0 = st.x0 + stepW * k -- 424
					local ____self_boxes_2 = self.boxes -- 424
					____self_boxes_2[#____self_boxes_2 + 1] = { -- 426
						x0 = x0, -- 426
						x1 = x0 + stepW, -- 426
						y0 = -8, -- 426
						y1 = y, -- 426
						passable = true -- 426
					} -- 426
					k = k + 1 -- 422
				end -- 422
			end -- 422
			i = i + 1 -- 417
		end -- 417
	end -- 417
end -- 404
function Play.prototype.buildEnemies(self) -- 431
	self.enemies = {} -- 432
	if self.room.key == "checkpoint" then -- 432
		local ____self_enemies_3 = self.enemies -- 432
		____self_enemies_3[#____self_enemies_3 + 1] = { -- 434
			x = self.ox + 430, -- 434
			y = 0, -- 434
			w = 26, -- 434
			h = 84, -- 434
			alive = true, -- 434
			hitT = 0, -- 434
			warnT = 0, -- 434
			fireCd = 0 -- 434
		} -- 434
		local ____self_enemies_4 = self.enemies -- 434
		____self_enemies_4[#____self_enemies_4 + 1] = { -- 435
			x = self.ox + 505, -- 435
			y = 0, -- 435
			w = 26, -- 435
			h = 84, -- 435
			alive = true, -- 435
			hitT = 0, -- 435
			warnT = 0, -- 435
			fireCd = 0 -- 435
		} -- 435
		return -- 436
	end -- 436
	if self.room.key == "street" then -- 436
		local ____self_enemies_5 = self.enemies -- 436
		____self_enemies_5[#____self_enemies_5 + 1] = { -- 440
			x = self.ox + 340, -- 440
			y = 0, -- 440
			w = 26, -- 440
			h = 84, -- 440
			alive = true, -- 440
			hitT = 0, -- 440
			warnT = 0, -- 440
			fireCd = 0 -- 440
		} -- 440
		local ____self_enemies_6 = self.enemies -- 440
		____self_enemies_6[#____self_enemies_6 + 1] = { -- 441
			x = self.ox + 560, -- 441
			y = 0, -- 441
			w = 26, -- 441
			h = 84, -- 441
			alive = true, -- 441
			hitT = 0, -- 441
			warnT = 0, -- 441
			fireCd = 0 -- 441
		} -- 441
	end -- 441
end -- 431
function Play.prototype.emit(self, name, data) -- 447
	local ____self_events_7 = self.events -- 447
	____self_events_7[#____self_events_7 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 448
	self.eventSeq = self.eventSeq + 1 -- 449
	if #self.events > 256 then -- 449
		table.remove(self.events, 1) -- 451
	end -- 451
end -- 447
function Play.prototype.drainEvents(self) -- 459
	local out = self.events -- 460
	self.events = {} -- 461
	return out -- 462
end -- 459
function Play.prototype.adoptEvents(self, events) -- 471
	if #events == 0 then -- 471
		return -- 473
	end -- 473
	local keep = {} -- 475
	local i = 0 -- 476
	do -- 476
		i = 0 -- 477
		while i < #events do -- 477
			do -- 477
				local e = events[i + 1] -- 478
				if e.name == "knock" and e.data.room ~= self.room.key then -- 478
					goto __continue32 -- 480
				end -- 480
				keep[#keep + 1] = e -- 482
			end -- 482
			::__continue32:: -- 482
			i = i + 1 -- 477
		end -- 477
	end -- 477
	if #keep == 0 then -- 477
		return -- 485
	end -- 485
	self.events = __TS__ArrayConcat(keep, self.events) -- 487
	do -- 487
		i = 0 -- 488
		while i < #self.events do -- 488
			self.events[i + 1].seq = i -- 489
			i = i + 1 -- 488
		end -- 488
	end -- 488
	self.eventSeq = #self.events -- 491
end -- 471
function Play.prototype.update(self, dt, input) -- 495
	if input.pause.pressed then -- 495
		self.paused = not self.paused -- 497
	end -- 497
	if self.flashT > 0 then -- 497
		self.flashT = self.flashT - dt -- 500
		if self.flashT <= 0 then -- 500
			self.flash = "" -- 502
		end -- 502
	end -- 502
	if self.traceT > 0 then -- 502
		self.traceT = self.traceT - dt -- 506
		if self.traceT <= 0 then -- 506
			self.trace = nil -- 508
		end -- 508
	end -- 508
	if self.paused then -- 508
		self:updateCamera(dt) -- 512
		return -- 513
	end -- 513
	self.ticks = self.ticks + 1 -- 516
	local p = self.player -- 517
	self:stepPlayer(p, dt, input) -- 518
	self:refreshCover(p, input) -- 520
	self:stepEnemies(dt, input) -- 522
	self:stepStory(dt, input) -- 523
	self:stepEscort(dt, input) -- 524
	self:stepVillage(dt, input) -- 525
	self:stepChase(dt, input) -- 526
	self:stepInteract(dt, input) -- 527
	self:updateGate() -- 528
	self:updateCamera(dt) -- 529
end -- 495
function Play.prototype.underLowArch(self, a) -- 536
	local arch = self.room.arch -- 537
	if arch.h <= 0 then -- 537
		return false -- 539
	end -- 539
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 539
		return false -- 542
	end -- 542
	local top = arch.y + arch.h -- 544
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 545
end -- 536
function Play.prototype.coverAt(self, a) -- 552
	local best = nil -- 553
	local bestGap = 24 -- 554
	local half = a.w / 2 -- 555
	local i = 0 -- 556
	do -- 556
		i = 0 -- 557
		while i < #self.boxes do -- 557
			do -- 557
				local b = self.boxes[i + 1] -- 558
				if b.passable == true or b.y1 - b.y0 < 44 then -- 558
					goto __continue49 -- 560
				end -- 560
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 560
					goto __continue49 -- 563
				end -- 563
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 565
				if gap < bestGap then -- 565
					bestGap = gap -- 567
					best = b -- 568
				end -- 568
			end -- 568
			::__continue49:: -- 568
			i = i + 1 -- 557
		end -- 557
	end -- 557
	return best -- 571
end -- 552
function Play.prototype.nearCover(self, a) -- 574
	return self:coverAt(a) ~= nil -- 575
end -- 574
function Play.prototype.coverGuardsFrom(self, b, a, enemyX) -- 579
	if enemyX < 0 then -- 579
		return false -- 581
	end -- 581
	if enemyX >= a.x then -- 581
		return b.x0 >= a.x - 0.001 and b.x0 <= enemyX -- 584
	end -- 584
	return b.x1 <= a.x + 0.001 and b.x1 >= enemyX -- 586
end -- 579
function Play.prototype.nearestEnemyX(self, a) -- 590
	local best = -1 -- 591
	local bestD = 1000000000 -- 592
	local i = 0 -- 593
	do -- 593
		i = 0 -- 594
		while i < #self.enemies do -- 594
			do -- 594
				local e = self.enemies[i + 1] -- 595
				if not e.alive then -- 595
					goto __continue59 -- 597
				end -- 597
				local d = math.abs(e.x - a.x) -- 599
				if d < bestD then -- 599
					bestD = d -- 601
					best = e.x -- 602
				end -- 602
			end -- 602
			::__continue59:: -- 602
			i = i + 1 -- 594
		end -- 594
	end -- 594
	return best -- 605
end -- 590
function Play.prototype.refreshCover(self, a, input) -- 609
	if self.childMode then -- 609
		self.coverNear = false -- 611
		self.coverHug = false -- 612
		self.coverEntity = "" -- 613
		self.coverBlocking = false -- 614
		a.covered = false -- 615
		return -- 616
	end -- 616
	local b = self:coverAt(a) -- 618
	self.coverNear = b ~= nil -- 619
	a.covered = self.coverNear and input.cover.held -- 620
	self.coverHug = a.covered -- 621
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 622
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 623
		b, -- 623
		a, -- 623
		self:nearestEnemyX(a) -- 623
	) -- 623
end -- 609
function Play.prototype.cartHandleInReach(self, a) -- 627
	local c = self.room.cart -- 628
	if self.cartDocked or c.endX <= c.startX then -- 628
		return false -- 630
	end -- 630
	local handleX = self.cartAxle + c.handleOffset -- 632
	return math.abs(a.x - handleX) <= CART_REACH and math.abs(a.y - c.baseY) <= 40 -- 633
end -- 627
function Play.prototype.nearLowLedge(self, a) -- 637
	local reach = 26 -- 638
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 639
	local x1 = x0 + reach -- 640
	local i = 0 -- 641
	do -- 641
		i = 0 -- 642
		while i < #self.boxes do -- 642
			do -- 642
				local b = self.boxes[i + 1] -- 643
				if b.x1 <= x0 or b.x0 >= x1 then -- 643
					goto __continue68 -- 645
				end -- 645
				local rise = b.y1 - a.y -- 647
				if rise > 0 and rise <= LEDGE_RISE then -- 647
					return true -- 649
				end -- 649
			end -- 649
			::__continue68:: -- 649
			i = i + 1 -- 642
		end -- 642
	end -- 642
	return false -- 652
end -- 637
function Play.prototype.stepPlayer(self, a, dt, input) -- 655
	if not a.alive then -- 655
		return -- 657
	end -- 657
	local isChild = self.childMode -- 659
	local lowArch = isChild and self:underLowArch(a) -- 661
	if self:storyLocked() then -- 661
		a.vx = 0 -- 664
		a.crouch = isChild and lowArch -- 665
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 666
		self:fallY(a, dt) -- 667
		return -- 668
	end -- 668
	if not isChild and self.escort.state == "calming" then -- 668
		a.crouch = false -- 672
		a.h = SOLDIER_H -- 673
		a.vx = 0 -- 674
		self:fallY(a, dt) -- 675
		return -- 676
	end -- 676
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 678
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 679
	local nearCover = not isChild and self:nearCover(a) -- 680
	a.covered = nearCover and input.cover.held -- 681
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 683
	if a.rollT > 0 then -- 683
		a.rollT = a.rollT - dt -- 687
		a.vx = a.facing * ROLL_SPEED -- 688
		self:slideX(a, a.vx * dt) -- 689
		self:fallY(a, dt) -- 690
		if a.rollT <= 0 then -- 690
			self:flashSet("翻滚结束", 0.5) -- 692
		end -- 692
		return -- 694
	end -- 694
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 694
		if input.moveX ~= 0 then -- 694
			a.facing = input.moveX > 0 and 1 or -1 -- 699
		end -- 699
		if self:nearLowLedge(a) then -- 699
			a.vy = SOLDIER_JUMP -- 703
			a.onGround = false -- 704
			self:flashSet("翻上去", 0.3) -- 705
			return -- 706
		end -- 706
		a.rollT = ROLL_TIME -- 708
		self:flashSet("翻滚", 0.3) -- 709
		return -- 710
	end -- 710
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 713
	if isChild then -- 713
		if input.cover.held then -- 713
			speed = CHILD_SLOW -- 716
		end -- 716
		if a.crouch then -- 716
			speed = CHILD_SLOW -- 719
		end -- 719
	elseif a.covered then -- 719
		speed = SOLDIER_SPEED * 0.45 -- 722
	end -- 722
	local dir = self.gripping and 0 or input.moveX -- 726
	if dir ~= 0 then -- 726
		a.facing = dir > 0 and 1 or -1 -- 728
	end -- 728
	a.vx = dir * speed -- 730
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 730
		a.vy = CHILD_JUMP -- 734
		a.onGround = false -- 735
		self:flashSet("跳", 0.25) -- 736
	end -- 736
	self:slideX(a, a.vx * dt) -- 739
	self:fallY(a, dt) -- 740
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 740
		self:shoot(a) -- 744
	end -- 744
end -- 655
function Play.prototype.stepPartner(self, p, dt) -- 749
	local a = self.partner -- 750
	if not a.alive then -- 750
		return -- 752
	end -- 752
	a.crouch = false -- 754
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 755
	a.vx = 0 -- 756
	self:fallY(a, dt) -- 757
end -- 749
function Play.prototype.stepEscort(self, dt, input) -- 764
	local a = self.partner -- 765
	if not a.alive then -- 765
		return -- 767
	end -- 767
	if not self:escortOn() then -- 767
		a.vx = 0 -- 770
		self:fallY(a, dt) -- 771
		return -- 772
	end -- 772
	local p = self.player -- 774
	local dist = math.abs(p.x - a.x) -- 775
	local hadKnock1 = self.escort.knock1 -- 776
	local hadKnock2 = self.escort.knock2 -- 777
	self.calmConsumed = self.escort:update( -- 778
		input, -- 778
		p.x, -- 778
		p.facing, -- 778
		a.x, -- 778
		dist -- 778
	) -- 778
	if not hadKnock1 and self.escort.knock1 then -- 778
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 781
	end -- 781
	if not hadKnock2 and self.escort.knock2 then -- 781
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 784
	end -- 784
	a.crouch = self.escort.crouchPose -- 786
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 787
	local dir = self.escort:moveDir(a.x) -- 788
	a.vx = dir * CHILD_SPEED -- 789
	if dir ~= 0 then -- 789
		a.facing = dir -- 791
		local before = a.x -- 792
		self:slideX(a, dir * CHILD_SPEED * dt) -- 793
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 793
			a.vy = CHILD_JUMP -- 796
			a.onGround = false -- 797
		end -- 797
	end -- 797
	self:fallY(a, dt) -- 800
end -- 764
function Play.prototype.escortOn(self) -- 804
	if self.room.key == "checkpoint" then -- 804
		return true -- 806
	end -- 806
	if self.room.key == "prologue" then -- 806
		return self.phase == "prologue-follow" -- 809
	end -- 809
	return self.room.key == "street" -- 811
end -- 804
function Play.prototype.storyLocked(self) -- 815
	if self.caughtT > 0 then -- 815
		return true -- 817
	end -- 817
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 817
		return true -- 820
	end -- 820
	if self.room.key == "gate" and self.phase == "gate-count" then -- 820
		return true -- 823
	end -- 823
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 823
		return true -- 826
	end -- 826
	return false -- 828
end -- 815
function Play.prototype.swapToChild(self, x) -- 832
	local tmp = self.player -- 833
	self.player = self.partner -- 834
	self.partner = tmp -- 835
	self.childMode = true -- 836
	self.player.alive = true -- 837
	self.player.x = self.ox + x -- 838
	self.player.y = 0 -- 839
	self.player.vy = 0 -- 840
	self.player.vx = 0 -- 841
	self.player.onGround = true -- 842
	self.player.crouch = false -- 843
	self.player.h = CHILD_H -- 844
	self.player.facing = 1 -- 845
	self.partner.alive = true -- 846
	self.cam.x = self.player.x -- 847
end -- 832
function Play.prototype.stepStory(self, dt, input) -- 851
	if self.room.key == "prologue" then -- 851
		self:stepPrologue(dt, input) -- 853
	elseif self.room.key == "street" then -- 853
		self:stepStreet(dt, input) -- 855
	elseif self.room.key == "gate" then -- 855
		self:stepGate(dt, input) -- 857
	elseif self.room.key == "tower" then -- 857
		self:stepTower(dt, input) -- 859
	end -- 859
end -- 851
function Play.prototype.stepPrologue(self, dt, input) -- 864
	local child = self.partner -- 865
	if self.phase == "prologue-wait" then -- 865
		child.crouch = true -- 867
		child.h = CHILD_CROUCH_H -- 868
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 869
		local near = math.abs(self.player.x - child.x) <= reach -- 871
		if near and input.interact.pressed then -- 871
			self.phase = "prologue-give" -- 873
			self.phaseTick = 0 -- 874
			self:flashSet("递出针套", 1) -- 875
		end -- 875
		return -- 877
	end -- 877
	if self.phase == "prologue-give" then -- 877
		self.phaseTick = self.phaseTick + 1 -- 880
		if self.phaseTick == 12 then -- 880
			self:flashSet("针套递过去", 0.7) -- 882
		elseif self.phaseTick == 36 then -- 882
			self:flashSet("纸条塞进针套", 0.9) -- 884
		elseif self.phaseTick >= 60 then -- 884
			self.phase = "prologue-follow" -- 886
			self.phaseTick = 0 -- 887
			child.crouch = false -- 888
			child.h = CHILD_H -- 889
			self:flashSet("她跟上了", 1.2) -- 890
		end -- 890
		return -- 892
	end -- 892
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 892
		self:requestRoom("street", "序章跟到门口") -- 896
		self:flashSet("进街道", 1.2) -- 897
	end -- 897
end -- 864
function Play.prototype.stepStreet(self, dt, input) -- 902
	local p = self.player -- 903
	local c = self.partner -- 904
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 904
		self:requestRoom("checkpoint", "两人都到街尾") -- 906
		self:flashSet("到检查站", 1.2) -- 907
	end -- 907
end -- 902
function Play.prototype.stepGate(self, dt, input) -- 912
	local ____temp_8 -- 913
	if self.room.story == nil then -- 913
		____temp_8 = nil -- 913
	else -- 913
		____temp_8 = self.room.story.gate -- 913
	end -- 913
	local g = ____temp_8 -- 913
	if g == nil then -- 913
		return -- 915
	end -- 915
	local p = self.player -- 917
	if self.phase == "gate-idle" then -- 917
		local a = self.partner -- 920
		local gap = g.waitX - a.x -- 921
		if math.abs(gap) > 3 then -- 921
			a.facing = gap > 0 and 1 or -1 -- 923
			a.vx = a.facing * CHILD_SPEED -- 924
			local beforeX = a.x -- 925
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 926
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 926
				a.vy = CHILD_JUMP -- 928
				a.onGround = false -- 929
			end -- 929
			self:fallY(a, dt) -- 931
		else -- 931
			a.vx = 0 -- 933
			a.x = g.waitX -- 934
		end -- 934
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 937
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 938
		if self.gateNeedConfirm then -- 938
			if not input.interact.held then -- 938
				self.gateRestartArmed = true -- 943
			end -- 943
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 943
				self.gateNeedConfirm = false -- 946
				self.gateRestartArmed = true -- 947
				self.phase = "gate-hold" -- 948
				self.gateTick = 0 -- 949
				self.gateSpawned = 0 -- 950
				self:flashSet("重新就位 · 守点开始", 1.4) -- 951
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 952
			end -- 952
			return -- 954
		end -- 954
		if atWinch and atWait then -- 954
			self.phase = "gate-hold" -- 957
			self.gateTick = 0 -- 958
			self.gateSpawned = 0 -- 959
			self:flashSet("两人就位 · 守点开始", 1.4) -- 960
		end -- 960
		return -- 962
	end -- 962
	if self.phase == "gate-hold" then -- 962
		self.gateTick = self.gateTick + 1 -- 965
		local marks = {0, 540, 900, 1500} -- 967
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 967
			local idx = self.gateSpawned -- 969
			local ____self_enemies_9 = self.enemies -- 969
			____self_enemies_9[#____self_enemies_9 + 1] = { -- 970
				x = self.ox + 620 + idx * 62, -- 971
				y = 0, -- 971
				w = 26, -- 971
				h = 84, -- 971
				alive = true, -- 972
				hitT = 0, -- 972
				warnT = 0, -- 972
				fireCd = 90 + idx * 45 -- 972
			} -- 972
			self.gateSpawned = self.gateSpawned + 1 -- 974
			self:flashSet( -- 975
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 975
				0.9 -- 975
			) -- 975
		end -- 975
		if self.gateTick == 900 then -- 975
			self:flashSet("灯灭了", 1) -- 978
		elseif self.gateTick == 2100 then -- 978
			self:flashSet("门底压下来了", 1) -- 980
		end -- 980
		if self.gateTick >= g.holdTicks then -- 980
			self.phase = "gate-send" -- 983
			self.phaseTick = 0 -- 984
			self.enemies = {} -- 986
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 987
		end -- 987
		return -- 989
	end -- 989
	if self.phase == "gate-send" then -- 989
		local near = math.abs(p.x - g.doorX) <= 60 -- 992
		if near and input.interact.pressed then -- 992
			self:swapToChild(g.doorX + 30) -- 994
			self.phase = "gate-count" -- 995
			self.countTick = 0 -- 996
			self.countArmed = false -- 998
			self.countPrevMove = input.moveX -- 999
			self:flashSet("门开了 · 送她出去", 1.8) -- 1000
		end -- 1000
		return -- 1002
	end -- 1002
	if self.phase == "gate-count" then -- 1002
		self.countTick = self.countTick + 1 -- 1005
		if self.countTick == 360 then -- 1005
			self:flashSet("门关上", 0.9) -- 1007
		elseif self.countTick == 1020 then -- 1007
			self:flashSet("数到一百", 2.2) -- 1009
		end -- 1009
		local prevMove = self.countPrevMove -- 1013
		self.countPrevMove = input.moveX -- 1014
		if self.countTick >= 1440 then -- 1014
			if prevMove <= 0 and input.moveX > 0 then -- 1014
				self.countArmed = true -- 1017
			end -- 1017
			if self.countArmed and input.moveX > 0 then -- 1017
				self.phase = "gate-walk" -- 1020
				self.phaseTick = 0 -- 1021
				self:flashSet("她迈出第一步", 1.4) -- 1022
			end -- 1022
		end -- 1022
		return -- 1025
	end -- 1025
	if self.player.x >= g.exitX then -- 1025
		self:requestRoom("outside", "走出城门") -- 1029
		self:flashSet("出城门 · 城外", 1.4) -- 1030
	end -- 1030
end -- 912
function Play.prototype.stepTower(self, dt, input) -- 1035
	local ____temp_10 -- 1036
	if self.room.story == nil then -- 1036
		____temp_10 = nil -- 1036
	else -- 1036
		____temp_10 = self.room.story.tower -- 1036
	end -- 1036
	local t = ____temp_10 -- 1036
	if t == nil then -- 1036
		return -- 1038
	end -- 1038
	if self.phase == "tower-wait" then -- 1038
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1041
		if near and input.interact.pressed then -- 1041
			self.phase = "tower-knock" -- 1043
			self.phaseTick = 0 -- 1044
			self.knocks = 1 -- 1045
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1046
			self:flashSet("敲一下", 0.6) -- 1047
		end -- 1047
		return -- 1049
	end -- 1049
	if self.phase == "tower-knock" then -- 1049
		self.phaseTick = self.phaseTick + 1 -- 1052
		if self.phaseTick == 12 then -- 1052
			self.knocks = 2 -- 1054
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1055
			self:flashSet("敲两下 · 第二声", 1) -- 1056
		elseif self.phaseTick >= t.knockTicks then -- 1056
			self.phase = "tower-given" -- 1058
			self.phaseTick = 0 -- 1059
			self:flashSet("门开了 · 提灯", 1.4) -- 1060
		end -- 1060
		return -- 1062
	end -- 1062
	if self.phase == "tower-given" then -- 1062
		self.phaseTick = self.phaseTick + 1 -- 1065
		if self.phaseTick == 60 then -- 1065
			self:flashSet("她递出针套和纸条", 1.6) -- 1067
		elseif self.phaseTick == 120 then -- 1067
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1069
		elseif self.phaseTick >= 180 then -- 1069
			self.phase = "tower-end" -- 1071
			self.phaseTick = 0 -- 1072
			self:flashSet("片尾 · E 再玩一次", 3) -- 1073
		end -- 1073
		return -- 1075
	end -- 1075
	if input.interact.pressed or input.retry.pressed then -- 1075
		self:requestRoom("prologue", "片尾再玩") -- 1078
		self:flashSet("回到序章", 1.4) -- 1079
	end -- 1079
end -- 1035
function Play.prototype.stepChase(self, dt, input) -- 1084
	if self.caughtT > 0 then -- 1084
		self.caughtT = self.caughtT - dt -- 1086
		if self.caughtT <= 0 then -- 1086
			self:recoverFromCaught() -- 1088
		end -- 1088
		return -- 1090
	end -- 1090
	if self.room.key == "village" then -- 1090
		self:stepScavChase() -- 1093
	elseif self.room.key == "forest" then -- 1093
		self:stepDog(dt) -- 1095
		if self.player.x >= self.ox + 1450 then -- 1095
			self:requestRoom("tower", "到林缘北塔") -- 1098
			self:flashSet("林缘 · 北塔", 1.4) -- 1099
		end -- 1099
	end -- 1099
end -- 1084
function Play.prototype.stepScavChase(self) -- 1105
	local s = self.room.scavenger -- 1106
	if s == nil then -- 1106
		return -- 1108
	end -- 1108
	local p = self.player -- 1110
	if self.passed and p.x > self.ox + 440 then -- 1110
		if self.scavChase then -- 1110
			self.scavChase = false -- 1114
			self.scavState = "back" -- 1115
			self.scavT = 0 -- 1116
		end -- 1116
		return -- 1118
	end -- 1118
	local dx = p.x - self.scavX -- 1120
	local dist = math.abs(dx) -- 1121
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1122
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1123
	if not self.scavChase then -- 1123
		if visible then -- 1123
			self.scavSee = self.scavSee + 1 -- 1126
			if self.scavSee >= 24 then -- 1126
				self.scavChase = true -- 1128
				self.scavState = "chase" -- 1129
				self.scavTargetX = p.x -- 1130
				self:flashSet("他看见你了", 1.2) -- 1131
			end -- 1131
		else -- 1131
			self.scavSee = 0 -- 1134
		end -- 1134
		return -- 1136
	end -- 1136
	local dir = p.x > self.scavX and 1 or -1 -- 1139
	self.scavX = self.scavX + dir * 96 / 60 -- 1140
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1140
		self:caught() -- 1142
		return -- 1143
	end -- 1143
	if hidden then -- 1143
		self.scavSee = 0 -- 1147
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1148
		self.scavT = self.scavT - 1 -- 1149
		if self.scavT <= 0 then -- 1149
			self.scavChase = false -- 1151
			self.scavState = "patrol" -- 1152
			self:flashSet("他失去了目标", 1) -- 1153
		end -- 1153
	end -- 1153
end -- 1105
function Play.prototype.stepDog(self, dt) -- 1159
	local ____temp_11 -- 1160
	if self.room.story == nil then -- 1160
		____temp_11 = nil -- 1160
	else -- 1160
		____temp_11 = self.room.story.dog -- 1160
	end -- 1160
	local dog = ____temp_11 -- 1160
	if dog == nil then -- 1160
		return -- 1162
	end -- 1162
	local p = self.player -- 1164
	local dist = math.abs(p.x - self.dogX) -- 1165
	if self.dogState == "patrol" then -- 1165
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1167
		if self.dogX < dog.x0 then -- 1167
			self.dogX = dog.x0 -- 1169
			self.dogDir = 1 -- 1170
		elseif self.dogX > dog.x1 then -- 1170
			self.dogX = dog.x1 -- 1172
			self.dogDir = -1 -- 1173
		end -- 1173
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1175
		if not p.crouch and moving and dist < dog.range then -- 1175
			self.dogState = "ear" -- 1177
			self.dogT = 18 -- 1178
			self.dogTargetX = p.x -- 1179
			self:flashSet("狗转耳朵", 0.8) -- 1180
		end -- 1180
		return -- 1182
	end -- 1182
	if self.dogState == "ear" then -- 1182
		self.dogT = self.dogT - 1 -- 1185
		if self.dogT <= 0 then -- 1185
			self.dogState = "chase" -- 1187
			self.dogTargetX = p.x -- 1188
			self:flashSet("狗追来了", 1.4) -- 1189
		end -- 1189
		return -- 1191
	end -- 1191
	if self.dogState == "chase" then -- 1191
		local dir = p.x > self.dogX and 1 or -1 -- 1194
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1195
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1195
			self:caught() -- 1197
			self.dogState = "sniff" -- 1198
			self.dogT = 60 -- 1199
		elseif dist > dog.range * 1.5 or p.crouch then -- 1199
			self.dogState = "sniff" -- 1201
			self.dogT = 60 -- 1202
			self:flashSet("狗停下了", 0.9) -- 1203
		end -- 1203
		return -- 1205
	end -- 1205
	if self.dogState == "sniff" then -- 1205
		self.dogT = self.dogT - 1 -- 1208
		if self.dogT <= 0 then -- 1208
			self.dogState = "back" -- 1210
		end -- 1210
		return -- 1212
	end -- 1212
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1215
	self.dogX = self.dogX + dir * dog.speed * dt -- 1216
	if math.abs(self.dogX - dog.x0) < 2 then -- 1216
		self.dogX = dog.x0 -- 1218
		self.dogState = "patrol" -- 1219
	end -- 1219
end -- 1159
function Play.prototype.caught(self) -- 1223
	self.caughtT = 1 -- 1224
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1225
end -- 1223
function Play.prototype.recoverFromCaught(self) -- 1229
	local p = self.player -- 1230
	p.x = self.ox + 140 -- 1231
	p.y = 0 -- 1232
	p.vy = 0 -- 1233
	p.vx = 0 -- 1234
	p.onGround = true -- 1235
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1235
		self.scavX = self.room.scavenger.x0 -- 1237
		self.scavState = "patrol" -- 1238
		self.scavSee = 0 -- 1239
		self.scavChase = false -- 1240
		self.scavT = 0 -- 1241
	end -- 1241
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1241
		self.dogX = self.room.story.dog.x0 -- 1244
		self.dogState = "patrol" -- 1245
		self.dogT = 0 -- 1246
	end -- 1246
	self.cam.x = p.x -- 1248
	self.cam.y = p.y + CAM_LOOK_UP -- 1249
	self:flashSet("回到安全点", 1.2) -- 1250
end -- 1229
function Play.prototype.updateGate(self) -- 1254
	if self.room.key ~= "checkpoint" then -- 1254
		self.gateOpen = false -- 1256
		return -- 1257
	end -- 1257
	local function inZone(x) -- 1259
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1259
	end -- 1259
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1260
end -- 1254
function Play.prototype.stepEnemies(self, dt, input) -- 1263
	local i = 0 -- 1264
	do -- 1264
		i = 0 -- 1265
		while i < #self.enemies do -- 1265
			local e = self.enemies[i + 1] -- 1266
			if e.hitT > 0 then -- 1266
				e.hitT = e.hitT - dt -- 1268
			end -- 1268
			i = i + 1 -- 1265
		end -- 1265
	end -- 1265
	if self.coveredFlash > 0 then -- 1265
		self.coveredFlash = self.coveredFlash - dt -- 1272
	end -- 1272
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1272
		return -- 1276
	end -- 1276
	do -- 1276
		i = 0 -- 1278
		while i < #self.enemies do -- 1278
			do -- 1278
				local e = self.enemies[i + 1] -- 1279
				if not e.alive then -- 1279
					goto __continue201 -- 1281
				end -- 1281
				if e.warnT > 0 then -- 1281
					e.warnT = e.warnT - 1 -- 1284
					if e.warnT <= 0 then -- 1284
						self:enemyFire(e, input) -- 1286
					end -- 1286
					goto __continue201 -- 1288
				end -- 1288
				if e.fireCd > 0 then -- 1288
					e.fireCd = e.fireCd - 1 -- 1291
					if e.fireCd <= 0 then -- 1291
						e.warnT = WARN_TICKS -- 1293
					end -- 1293
				else -- 1293
					e.warnT = WARN_TICKS -- 1297
				end -- 1297
			end -- 1297
			::__continue201:: -- 1297
			i = i + 1 -- 1278
		end -- 1278
	end -- 1278
end -- 1263
function Play.prototype.enemyFire(self, e, input) -- 1303
	local p = self.player -- 1304
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1304
		self:flashSet("枪声响在远处", 0.4) -- 1306
		e.fireCd = FIRE_COOLDOWN -- 1307
		return -- 1308
	end -- 1308
	local cover = self:blockedByCover(e.x, p) -- 1311
	local hugging = cover ~= nil -- 1312
	self.coverBlocking = hugging -- 1313
	local covered = hugging and input.cover.held -- 1314
	if covered then -- 1314
		self.coveredFlash = 0.5 -- 1316
		self:flashSet("掩体挡下", 0.5) -- 1317
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1318
		e.fireCd = FIRE_COOLDOWN -- 1323
		return -- 1324
	end -- 1324
	self.hp = self.hp - 1 -- 1326
	self:emit("actorHit", { -- 1327
		target = "player", -- 1327
		amount = 1, -- 1327
		hp = self.hp, -- 1327
		maxHp = self.maxHp, -- 1327
		enemyX = e.x -- 1327
	}) -- 1327
	self:flashSet( -- 1328
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1328
		0.7 -- 1328
	) -- 1328
	e.fireCd = FIRE_COOLDOWN -- 1329
	if self.hp <= 0 then -- 1329
		self:gateFailed() -- 1331
	end -- 1331
end -- 1303
function Play.prototype.blockedByCover(self, ex, p) -- 1336
	local b = self:coverAt(p) -- 1337
	if b == nil then -- 1337
		return nil -- 1339
	end -- 1339
	return self:coverGuardsFrom(b, p, ex) and b or nil -- 1341
end -- 1336
function Play.prototype.gateFailed(self) -- 1345
	local ____temp_12 -- 1346
	if self.room.story == nil then -- 1346
		____temp_12 = nil -- 1346
	else -- 1346
		____temp_12 = self.room.story.gate -- 1346
	end -- 1346
	local g = ____temp_12 -- 1346
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1347
	self.hp = self.maxHp -- 1348
	self.gateTick = 0 -- 1349
	self.gateSpawned = 0 -- 1350
	self.enemies = {} -- 1351
	self.gateFailCount = self.gateFailCount + 1 -- 1352
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1354
	self.player.y = 0 -- 1355
	self.player.vy = 0 -- 1356
	self.player.onGround = true -- 1357
	self.player.crouch = false -- 1358
	self.player.h = SOLDIER_H -- 1359
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1360
	self.partner.y = 0 -- 1361
	self.partner.vy = 0 -- 1362
	self.partner.onGround = true -- 1363
	self.cam.x = self.player.x -- 1364
	self.phase = "gate-idle" -- 1365
	self.phaseTick = 0 -- 1366
	self.coverHug = false -- 1367
	self.coverBlocking = false -- 1368
	self.coverEntity = "" -- 1369
	self.gateNeedConfirm = true -- 1370
	self.gateRestartArmed = false -- 1371
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1372
end -- 1345
function Play.prototype.stepInteract(self, dt, input) -- 1375
	local p = self.player -- 1376
	local calmUsed = self.calmConsumed -- 1377
	self.calmConsumed = false -- 1378
	local calming = self.escort.state == "calming" -- 1380
	self.focusCart = false -- 1381
	if self.room.key == "outside" then -- 1381
		local c = self.room.cart -- 1383
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1384
		local dy = p.y - c.baseY -- 1385
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < CART_REACH * CART_REACH -- 1386
	end -- 1386
	if not calmUsed and not calming then -- 1386
		self:stepCart(dt, input) -- 1390
	end -- 1390
	if calmUsed then -- 1390
		self:flashSet("安抚 · 敲两下", 0.8) -- 1395
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1395
		if self.knockT > 0 then -- 1395
			self.knocks = self.knocks + 1 -- 1399
		else -- 1399
			self.knocks = 1 -- 1401
		end -- 1401
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1403
		self.knockT = 1.2 -- 1404
		if self.knocks >= 2 then -- 1404
			self:flashSet("敲两下", 0.8) -- 1406
			self.knocks = 0 -- 1407
		else -- 1407
			self:flashSet("敲一下", 0.5) -- 1409
		end -- 1409
	elseif self.knockT > 0 then -- 1409
		self.knockT = self.knockT - dt -- 1412
		if self.knockT <= 0 then -- 1412
			self.knocks = 0 -- 1414
		end -- 1414
	end -- 1414
	local i = 0 -- 1419
	do -- 1419
		i = 0 -- 1420
		while i < #self.room.marks do -- 1420
			do -- 1420
				local m = self.room.marks[i + 1] -- 1421
				if m.kind ~= 0 then -- 1421
					goto __continue227 -- 1423
				end -- 1423
				local subjects = {self.partner, self.player} -- 1425
				local k = 0 -- 1426
				do -- 1426
					k = 0 -- 1427
					while k < #subjects do -- 1427
						do -- 1427
							local s = subjects[k + 1] -- 1428
							if not s.alive then -- 1428
								goto __continue230 -- 1430
							end -- 1430
							local dx = s.x - m.x -- 1432
							local dy = s.y - m.y -- 1433
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1433
								self.checkpoint = m.x -- 1435
								self.checkpointCartAxle = self.cartAxle -- 1436
								if self.cartDocked then -- 1436
									self:flashSet("检查点 · 车已落窝", 1) -- 1438
								else -- 1438
									self:flashSet("检查点 · 车还没到位", 1) -- 1440
								end -- 1440
							end -- 1440
						end -- 1440
						::__continue230:: -- 1440
						k = k + 1 -- 1427
					end -- 1427
				end -- 1427
			end -- 1427
			::__continue227:: -- 1427
			i = i + 1 -- 1420
		end -- 1420
	end -- 1420
	self:checkCarryGate() -- 1446
end -- 1375
function Play.prototype.stepVillage(self, dt, input) -- 1450
	if self.room.key ~= "village" then -- 1450
		return -- 1452
	end -- 1452
	local p = self.player -- 1454
	local bottle = self.room.bottle -- 1455
	local scav = self.room.scavenger -- 1456
	if not self.hasBottle and bottle ~= nil then -- 1456
		local dx = p.x - bottle.x -- 1460
		local dy = p.y + p.h * 0.5 - bottle.y -- 1461
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1461
			self.hasBottle = true -- 1463
			self:flashSet("拾起瓶子", 0.8) -- 1464
		end -- 1464
	end -- 1464
	if self.hasBottle then -- 1464
		if input.aim.held then -- 1464
			self.aimHold = self.aimHold + dt -- 1471
			if self.aimHold > 1.2 then -- 1471
				self.aimHold = 1.2 -- 1473
			end -- 1473
			local cached = self:bottleEnd() -- 1476
			self.bottleAimX = cached.x -- 1477
			self.bottleAimY = cached.y -- 1478
		elseif input.aim.released then -- 1478
			if self.aimHold < 0.12 then -- 1478
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1482
				self.aimHold = 0 -- 1483
			else -- 1483
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1485
				self:throwBottle(____end.x, ____end.y) -- 1486
				self.aimHold = 0 -- 1487
			end -- 1487
		end -- 1487
	else -- 1487
		self.aimHold = 0 -- 1491
		self.bottleAimX = -1 -- 1492
	end -- 1492
	local fly = self.bottleFly -- 1497
	if fly ~= nil then -- 1497
		fly.t = fly.t + dt -- 1499
		fly.x = fly.x0 + fly.vx * fly.t -- 1500
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1501
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1502
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1502
			self:landBottle(fly) -- 1504
		end -- 1504
	end -- 1504
	if self.bottleLandT > 0 then -- 1504
		self.bottleLandT = self.bottleLandT - dt -- 1508
	end -- 1508
	if scav ~= nil then -- 1508
		self:stepScav(dt, scav) -- 1512
	end -- 1512
	local line = self.room.passLine -- 1515
	if line ~= nil and not self.passed and p.x >= line then -- 1515
		self.passed = true -- 1517
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1518
	end -- 1518
	if self.passed and p.x >= self.ox + 640 then -- 1518
		self:requestRoom("forest", "过第一院出院") -- 1522
		self:flashSet("出院 · 北塔森林", 1.4) -- 1523
	end -- 1523
end -- 1450
function Play.prototype.bottleEnd(self) -- 1528
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1529
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1532
	return {x = aim.x, y = g} -- 1533
end -- 1528
function Play.prototype.throwBottle(self, tx, ty) -- 1537
	local p = self.player -- 1538
	local dir = tx >= p.x and 1 or -1 -- 1540
	p.facing = dir -- 1541
	local x0 = p.x + dir * 10 -- 1542
	local y0 = p.y + p.h * 0.7 -- 1543
	self.bottleTargetX = tx -- 1544
	self.bottleTargetY = ty -- 1545
	self.bottleSurfaceY = ty -- 1546
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1547
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1548
	self.bottleFly = { -- 1549
		x = x0, -- 1549
		y = y0, -- 1549
		x0 = x0, -- 1549
		y0 = y0, -- 1549
		vx = vx, -- 1549
		vy = vy, -- 1549
		t = 0 -- 1549
	} -- 1549
	self.hasBottle = false -- 1550
	self:flashSet("投出", 0.4) -- 1551
	self:emit( -- 1552
		"bottleThrown", -- 1552
		{ -- 1552
			fromX = x0, -- 1553
			fromY = y0, -- 1554
			targetX = tx, -- 1555
			targetY = ty, -- 1556
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1557
		} -- 1557
	) -- 1557
end -- 1537
function Play.prototype.landBottle(self, fly) -- 1562
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1563
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1564
	local s = self.room.scavenger -- 1565
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1566
	self.bottleFly = nil -- 1567
	self.bottleTargetX = -1 -- 1568
	self.bottleTargetY = 0 -- 1569
	self.bottleSurfaceY = -1 -- 1570
	self.bottleLandX = x -- 1571
	self.bottleLandY = y -- 1572
	self.bottleLandT = 0.9 -- 1573
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1574
	self:hearBottle(x) -- 1575
end -- 1562
function Play.prototype.hearBottle(self, x) -- 1579
	local s = self.room.scavenger -- 1580
	if s == nil then -- 1580
		return -- 1582
	end -- 1582
	if math.abs(x - self.scavX) > s.range then -- 1582
		self:flashSet("落地 · 他没听见", 0.6) -- 1585
		return -- 1586
	end -- 1586
	self.scavState = "turn" -- 1588
	self.scavT = s.hearTicks -- 1589
	self.scavTargetX = x -- 1590
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1591
end -- 1579
function Play.prototype.stepScav(self, dt, s) -- 1595
	if self.scavState == "chase" then -- 1595
		return -- 1598
	end -- 1598
	if self.scavState == "turn" then -- 1598
		self.scavT = self.scavT - 1 -- 1601
		if self.scavT <= 0 then -- 1601
			self.scavState = "walk" -- 1603
		end -- 1603
		return -- 1605
	end -- 1605
	if self.scavState == "walk" then -- 1605
		local d = self.scavTargetX - self.scavX -- 1608
		if math.abs(d) < 4 then -- 1608
			self.scavState = "stall" -- 1610
			self.scavT = s.stallTicks -- 1611
			return -- 1612
		end -- 1612
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1614
		return -- 1615
	end -- 1615
	if self.scavState == "stall" then -- 1615
		self.scavT = self.scavT - 1 -- 1618
		if self.scavT <= 0 then -- 1618
			self.scavState = "back" -- 1620
		end -- 1620
		return -- 1622
	end -- 1622
	if self.scavState == "back" then -- 1622
		local home = math.max( -- 1625
			s.x0, -- 1625
			math.min(s.x1, self.scavX) -- 1625
		) -- 1625
		if math.abs(home - self.scavX) < 2 then -- 1625
			self.scavState = "patrol" -- 1627
			return -- 1628
		end -- 1628
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1630
		return -- 1631
	end -- 1631
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1633
	if self.scavX >= s.x1 then -- 1633
		self.scavX = s.x1 -- 1635
		self.scavDir = -1 -- 1636
	elseif self.scavX <= s.x0 then -- 1636
		self.scavX = s.x0 -- 1638
		self.scavDir = 1 -- 1639
	end -- 1639
end -- 1595
function Play.prototype.stepCart(self, dt, input) -- 1647
	local p = self.player -- 1648
	local c = self.room.cart -- 1649
	local handleX = self.cartAxle + c.handleOffset -- 1650
	if self.gripping then -- 1650
		if not input.interact.held then -- 1650
			self.gripping = false -- 1654
			self:flashSet("松开车把", 0.4) -- 1655
			return -- 1656
		end -- 1656
	else -- 1656
		if not input.interact.pressed then -- 1656
			return -- 1660
		end -- 1660
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1660
			return -- 1663
		end -- 1663
		self.gripping = true -- 1665
		self:flashSet("握住车把", 0.4) -- 1666
		return -- 1667
	end -- 1667
	if self.cartDocked then -- 1667
		return -- 1671
	end -- 1671
	local dir = input.moveX -- 1673
	if dir == 0 then -- 1673
		return -- 1675
	end -- 1675
	local lo = math.min(c.startX, c.endX) -- 1677
	local hi = math.max(c.startX, c.endX) -- 1678
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1679
	if next < lo then -- 1679
		next = lo -- 1681
	end -- 1681
	if next > hi then -- 1681
		next = hi -- 1684
	end -- 1684
	local delta = next - self.cartAxle -- 1686
	if delta == 0 then -- 1686
		return -- 1688
	end -- 1688
	self.cartAxle = next -- 1690
	p.x = p.x + delta -- 1691
	p.facing = dir > 0 and 1 or -1 -- 1692
	self:slideX(p, 0) -- 1693
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1693
		self.gripping = false -- 1695
		self:flashSet("跟不上了，脱手", 0.6) -- 1696
		return -- 1697
	end -- 1697
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1697
		self.cartDocked = true -- 1700
		self.gripping = false -- 1701
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1702
		self:flashSet("车轮落窝", 1.2) -- 1703
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1703
		self:flashSet("车轮回到起点", 0.5) -- 1705
	end -- 1705
end -- 1647
function Play.prototype.requestRoom(self, key, reason) -- 1713
	if self.wantRoom ~= "" then -- 1713
		return -- 1717
	end -- 1717
	self.wantRoom = key -- 1719
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1720
end -- 1713
function Play.prototype.checkCarryGate(self) -- 1727
	if self.room.key == "checkpoint" then -- 1727
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1727
			self.carryCartAxle = self.cartAxle -- 1730
			self.carryCartDocked = self.cartDocked -- 1731
			self:requestRoom("gate", "检查站出口") -- 1732
			self:flashSet("出检查站 · 城门", 1.2) -- 1733
		end -- 1733
		return -- 1735
	end -- 1735
	if self.room.key == "outside" then -- 1735
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1735
			self.carryCartAxle = self.cartAxle -- 1741
			self.carryCartDocked = self.cartDocked -- 1742
			self:requestRoom("village", "墙根走完") -- 1743
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1744
		end -- 1744
	end -- 1744
end -- 1727
function Play.prototype.aimAt(self, wx, wy) -- 1751
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1752
	self.aimX = s.x -- 1753
	self.aimY = s.y -- 1754
end -- 1751
function Play.prototype.shoot(self, a) -- 1757
	local ox = a.x + a.facing * 8 -- 1758
	local oy = a.y + a.h * 0.72 -- 1759
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1761
	local dx = aim.x - ox -- 1764
	local dy = aim.y - oy -- 1765
	local len = math.sqrt(dx * dx + dy * dy) -- 1766
	if len < 0.001 then -- 1766
		dx = a.facing -- 1768
		dy = 0 -- 1769
	else -- 1769
		dx = dx / len -- 1771
		dy = dy / len -- 1772
	end -- 1772
	if dx ~= 0 then -- 1772
		a.facing = dx > 0 and 1 or -1 -- 1775
	end -- 1775
	local hitEnemy = self:raycast( -- 1778
		ox, -- 1778
		oy, -- 1778
		dx, -- 1778
		dy, -- 1778
		true -- 1778
	) -- 1778
	local hitWall = self:raycast( -- 1779
		ox, -- 1779
		oy, -- 1779
		dx, -- 1779
		dy, -- 1779
		false -- 1779
	) -- 1779
	local tEnemy = hitEnemy.t -- 1780
	local tWall = hitWall.t -- 1781
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1782
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1783
	self.trace = { -- 1785
		x0 = ox, -- 1785
		y0 = oy, -- 1785
		x1 = ox + dx * t, -- 1785
		y1 = oy + dy * t, -- 1785
		hit = hit -- 1785
	} -- 1785
	self.traceT = 0.12 -- 1786
	self:applyFireDanger(ox) -- 1787
	if hit then -- 1787
		local i = hitEnemy.index -- 1789
		local e = self.enemies[i + 1] -- 1790
		e.alive = false -- 1791
		e.hitT = 0.4 -- 1792
		self:flashSet("命中", 0.6) -- 1793
	else -- 1793
		self:flashSet("打空", 0.35) -- 1795
	end -- 1795
	self:emit("shotResolved", { -- 1797
		hit = hit, -- 1798
		enemyIndex = hit and hitEnemy.index or -1, -- 1799
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1800
		aimX = aim.x, -- 1801
		aimY = aim.y, -- 1802
		impactX = ox + dx * t, -- 1803
		impactY = oy + dy * t -- 1804
	}) -- 1804
end -- 1757
function Play.prototype.applyFireDanger(self, shotX) -- 1809
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1809
		return -- 1811
	end -- 1811
	local dangerX = shotX -- 1813
	local best = -1 -- 1814
	local bestD = 1000000000 -- 1815
	local i = 0 -- 1816
	do -- 1816
		i = 0 -- 1817
		while i < #self.enemies do -- 1817
			do -- 1817
				local e = self.enemies[i + 1] -- 1818
				if not e.alive then -- 1818
					goto __continue301 -- 1820
				end -- 1820
				local d = math.abs(e.x - self.partner.x) -- 1822
				if d < bestD then -- 1822
					bestD = d -- 1824
					best = i -- 1825
				end -- 1825
			end -- 1825
			::__continue301:: -- 1825
			i = i + 1 -- 1817
		end -- 1817
	end -- 1817
	if best >= 0 then -- 1817
		dangerX = self.enemies[best + 1].x -- 1829
	end -- 1829
	local exposed = self:childExposed(dangerX) -- 1831
	local before = self.escort.fear -- 1832
	local dangerId = self.nextDangerId -- 1833
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1834
	self.nextDangerId = self.nextDangerId + 1 -- 1835
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1836
	if after > before then -- 1836
		self:flashSet( -- 1838
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1838
			1 -- 1838
		) -- 1838
	elseif not exposed then -- 1838
		self:flashSet("枪声没够到她", 0.5) -- 1840
	end -- 1840
end -- 1809
function Play.prototype.childExposed(self, dangerX) -- 1845
	local c = self.partner -- 1846
	if not c.alive then -- 1846
		return false -- 1848
	end -- 1848
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1848
		return false -- 1851
	end -- 1851
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1851
		return false -- 1854
	end -- 1854
	local toDanger = dangerX - c.x -- 1856
	local toPlayer = self.player.x - c.x -- 1857
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1857
		return false -- 1859
	end -- 1859
	return true -- 1861
end -- 1845
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1865
	local best = -1 -- 1866
	local bestI = -1 -- 1867
	local i = 0 -- 1868
	if enemies then -- 1868
		do -- 1868
			i = 0 -- 1870
			while i < #self.enemies do -- 1870
				do -- 1870
					local e = self.enemies[i + 1] -- 1871
					if not e.alive then -- 1871
						goto __continue315 -- 1873
					end -- 1873
					local t = hitBox( -- 1875
						ox, -- 1875
						oy, -- 1875
						dx, -- 1875
						dy, -- 1875
						e.x - e.w / 2, -- 1875
						e.x + e.w / 2, -- 1875
						e.y, -- 1875
						e.y + e.h -- 1875
					) -- 1875
					if t >= 0 and (best < 0 or t < best) then -- 1875
						best = t -- 1877
						bestI = i -- 1878
					end -- 1878
				end -- 1878
				::__continue315:: -- 1878
				i = i + 1 -- 1870
			end -- 1870
		end -- 1870
		return {t = best, index = bestI} -- 1881
	end -- 1881
	do -- 1881
		i = 0 -- 1883
		while i < #self.boxes do -- 1883
			local b = self.boxes[i + 1] -- 1884
			local t = hitBox( -- 1885
				ox, -- 1885
				oy, -- 1885
				dx, -- 1885
				dy, -- 1885
				b.x0, -- 1885
				b.x1, -- 1885
				b.y0, -- 1885
				b.y1 -- 1885
			) -- 1885
			if t >= 0 and (best < 0 or t < best) then -- 1885
				best = t -- 1887
			end -- 1887
			i = i + 1 -- 1883
		end -- 1883
	end -- 1883
	if dy < 0 then -- 1883
		local t = (0 - oy) / dy -- 1892
		if t >= 0 and (best < 0 or t < best) then -- 1892
			best = t -- 1894
		end -- 1894
	end -- 1894
	return {t = best, index = -1} -- 1897
end -- 1865
function Play.prototype.slideX(self, a, dx) -- 1901
	local nx = a.x + dx -- 1902
	local half = a.w / 2 -- 1903
	local room = self.room -- 1904
	nx = math.max( -- 1905
		room.minX + half, -- 1905
		math.min(room.maxX - half, nx) -- 1905
	) -- 1905
	local i = 0 -- 1906
	do -- 1906
		i = 0 -- 1907
		while i < #self.boxes do -- 1907
			do -- 1907
				local b = self.boxes[i + 1] -- 1908
				if b.passable == true then -- 1908
					goto __continue325 -- 1910
				end -- 1910
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1910
					goto __continue325 -- 1913
				end -- 1913
				if nx + half > b.x0 and nx - half < b.x1 then -- 1913
					if a.x <= b.x0 then -- 1913
						nx = b.x0 - half -- 1917
					elseif a.x >= b.x1 then -- 1917
						nx = b.x1 + half -- 1919
					else -- 1919
						nx = a.x -- 1921
					end -- 1921
				end -- 1921
			end -- 1921
			::__continue325:: -- 1921
			i = i + 1 -- 1907
		end -- 1907
	end -- 1907
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1907
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1929
		local bx0 = self.cartAxle - CART_HALF -- 1930
		local bx1 = self.cartAxle + CART_HALF -- 1931
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1931
			if a.x <= bx0 then -- 1931
				nx = bx0 - half -- 1934
			elseif a.x >= bx1 then -- 1934
				nx = bx1 + half -- 1936
			else -- 1936
				nx = a.x -- 1938
			end -- 1938
		end -- 1938
	end -- 1938
	local arch = room.arch -- 1946
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1946
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1948
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1948
			if a.x <= arch.x0 then -- 1948
				nx = arch.x0 - half -- 1951
			elseif a.x >= arch.x1 then -- 1951
				nx = arch.x1 + half -- 1953
			end -- 1953
		end -- 1953
	end -- 1953
	a.x = nx -- 1957
end -- 1901
function Play.prototype.fallY(self, a, dt) -- 1961
	a.vy = a.vy - ____exports.GRAVITY * dt -- 1962
	if a.vy < -900 then -- 1962
		a.vy = -900 -- 1964
	end -- 1964
	local ny = a.y + a.vy * dt -- 1966
	local half = a.w / 2 -- 1967
	if a.vy <= 0 then -- 1967
		local reach = a.onGround and STEP_UP or 0 -- 1970
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1971
		if ny <= ground then -- 1971
			ny = ground -- 1973
			a.vy = 0 -- 1974
			a.onGround = true -- 1975
		else -- 1975
			a.onGround = false -- 1977
		end -- 1977
	else -- 1977
		a.onGround = false -- 1980
		local i = 0 -- 1981
		do -- 1981
			i = 0 -- 1982
			while i < #self.boxes do -- 1982
				do -- 1982
					local b = self.boxes[i + 1] -- 1983
					if b.passable == true then -- 1983
						goto __continue348 -- 1985
					end -- 1985
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1985
						goto __continue348 -- 1988
					end -- 1988
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1988
						ny = b.y0 - a.h -- 1991
						a.vy = 0 -- 1992
					end -- 1992
				end -- 1992
				::__continue348:: -- 1992
				i = i + 1 -- 1982
			end -- 1982
		end -- 1982
	end -- 1982
	a.y = ny -- 1996
end -- 1961
function Play.prototype.groundAt(self, x, ceiling, half) -- 2000
	local g = -9999 -- 2001
	local i = 0 -- 2002
	do -- 2002
		i = 0 -- 2003
		while i < #self.floors do -- 2003
			local f = self.floors[i + 1] -- 2004
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 2004
				g = f.y1 -- 2006
			end -- 2006
			i = i + 1 -- 2003
		end -- 2003
	end -- 2003
	do -- 2003
		i = 0 -- 2009
		while i < #self.boxes do -- 2009
			local b = self.boxes[i + 1] -- 2010
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 2010
				g = b.y1 -- 2012
			end -- 2012
			i = i + 1 -- 2009
		end -- 2009
	end -- 2009
	return g -- 2015
end -- 2000
function Play.prototype.updateCamera(self, dt) -- 2018
	local p = self.player -- 2019
	local tx = p.x + p.facing * 30 -- 2020
	local ty = p.y + CAM_LOOK_UP -- 2021
	local k = math.min(1, CAM_FOLLOW * dt) -- 2022
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2023
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2024
end -- 2018
function Play.prototype.clampCamera(self, w, h) -- 2028
	local room = self.room -- 2029
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2030
	local spanX = room.maxX - room.minX -- 2031
	if spanX <= halfW * 2 then -- 2031
		self.cam.x = (room.minX + room.maxX) / 2 -- 2033
	else -- 2033
		self.cam.x = math.max( -- 2035
			room.minX + halfW, -- 2035
			math.min(room.maxX - halfW, self.cam.x) -- 2035
		) -- 2035
	end -- 2035
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 2038
	local spanY = room.height -- 2039
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 2040
	if spanY <= halfH * 2 then -- 2040
		self.cam.y = camY -- 2042
	else -- 2042
		self.cam.y = math.max( -- 2044
			camY, -- 2044
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2044
		) -- 2044
	end -- 2044
end -- 2028
function Play.prototype.flashSet(self, text, t) -- 2048
	self.flash = text -- 2049
	self.flashT = t -- 2050
end -- 2048
function Play.prototype.statusText(self) -- 2054
	local p = self.player -- 2055
	local parts = {} -- 2056
	local who = self.childMode and "小满" or "周戍" -- 2057
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2058
	if self.room.key == "prologue" then -- 2058
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2061
		if self.phase == "prologue-wait" then -- 2061
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2063
		elseif self.phase == "prologue-give" then -- 2063
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2065
		else -- 2065
			parts[#parts + 1] = "跟随" -- 2067
		end -- 2067
		if self.paused then -- 2067
			parts[#parts + 1] = "已暂停" -- 2070
		end -- 2070
		return table.concat(parts, " · ") -- 2072
	end -- 2072
	if self.room.key == "street" then -- 2072
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2075
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2076
		if self.paused then -- 2076
			parts[#parts + 1] = "已暂停" -- 2078
		end -- 2078
		return table.concat(parts, " · ") -- 2080
	end -- 2080
	if self.room.key == "gate" then -- 2080
		local ____temp_13 -- 2083
		if self.room.story == nil then -- 2083
			____temp_13 = nil -- 2083
		else -- 2083
			____temp_13 = self.room.story.gate -- 2083
		end -- 2083
		local g = ____temp_13 -- 2083
		if g ~= nil then -- 2083
			parts[#parts + 1] = self:gateLabel() -- 2085
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2086
				0, -- 2087
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2087
			))) .. " 秒" -- 2087
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2088
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2089
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2090
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2091
			if self.gateFailCount > 0 then -- 2091
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2093
			end -- 2093
			if self.flash ~= "" then -- 2093
				parts[#parts + 1] = self.flash -- 2096
			end -- 2096
		end -- 2096
		if self.paused then -- 2096
			parts[#parts + 1] = "已暂停" -- 2100
		end -- 2100
		return table.concat(parts, " · ") -- 2102
	end -- 2102
	if self.room.key == "forest" then -- 2102
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2105
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2106
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2107
		if self.caughtT > 0 then -- 2107
			parts[#parts + 1] = "复位中" -- 2109
		end -- 2109
		if self.paused then -- 2109
			parts[#parts + 1] = "已暂停" -- 2112
		end -- 2112
		return table.concat(parts, " · ") -- 2114
	end -- 2114
	if self.room.key == "tower" then -- 2114
		if self.phase == "tower-wait" then -- 2114
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2118
		elseif self.phase == "tower-knock" then -- 2118
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2120
		elseif self.phase == "tower-given" then -- 2120
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2122
		else -- 2122
			parts[#parts + 1] = "片尾" -- 2124
		end -- 2124
		if self.paused then -- 2124
			parts[#parts + 1] = "已暂停" -- 2127
		end -- 2127
		return table.concat(parts, " · ") -- 2129
	end -- 2129
	if self.room.key == "village" then -- 2129
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2132
		if self.hasBottle then -- 2132
			parts[#parts + 1] = "有瓶" -- 2134
		elseif self.bottleFly ~= nil then -- 2134
			parts[#parts + 1] = "瓶在飞" -- 2136
		else -- 2136
			parts[#parts + 1] = "空手" -- 2138
		end -- 2138
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2140
		if self.scavChase then -- 2140
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2142
		end -- 2142
		if self.passed then -- 2142
			parts[#parts + 1] = "已过通行线" -- 2145
		end -- 2145
		if self.paused then -- 2145
			parts[#parts + 1] = "已暂停" -- 2148
		end -- 2148
		return table.concat(parts, " · ") -- 2150
	end -- 2150
	local isChild = self.childMode -- 2153
	if isChild then -- 2153
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2155
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2156
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2157
	else -- 2157
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2159
		if p.rollT > 0 then -- 2159
			parts[#parts + 1] = "翻滚中" -- 2161
		end -- 2161
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2163
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2164
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2165
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2166
	end -- 2166
	if self.checkpoint >= 0 then -- 2166
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2169
	end -- 2169
	if self.paused then -- 2169
		parts[#parts + 1] = "已暂停" -- 2172
	end -- 2172
	return table.concat(parts, " · ") -- 2174
end -- 2054
function Play.prototype.aliveEnemies(self) -- 2178
	local n = 0 -- 2179
	local i = 0 -- 2180
	do -- 2180
		i = 0 -- 2181
		while i < #self.enemies do -- 2181
			if self.enemies[i + 1].alive then -- 2181
				n = n + 1 -- 2183
			end -- 2183
			i = i + 1 -- 2181
		end -- 2181
	end -- 2181
	return n -- 2186
end -- 2178
function Play.prototype.threatened(self) -- 2191
	do -- 2191
		local i = 0 -- 2192
		while i < #self.enemies do -- 2192
			local e = self.enemies[i + 1] -- 2193
			if e.alive and e.warnT > 0 then -- 2193
				return true -- 2195
			end -- 2195
			i = i + 1 -- 2192
		end -- 2192
	end -- 2192
	return false -- 2198
end -- 2191
function Play.prototype.gateSecondsLeft(self) -- 2201
	local ____temp_14 -- 2202
	if self.room.story == nil then -- 2202
		____temp_14 = nil -- 2202
	else -- 2202
		____temp_14 = self.room.story.gate -- 2202
	end -- 2202
	local g = ____temp_14 -- 2202
	if g == nil then -- 2202
		return 0 -- 2204
	end -- 2204
	return math.max( -- 2206
		0, -- 2206
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2206
	) -- 2206
end -- 2201
function Play.prototype.gateLabel(self) -- 2209
	if self.phase == "gate-idle" then -- 2209
		return "待就位" -- 2211
	end -- 2211
	if self.phase == "gate-hold" then -- 2211
		return "守点中" -- 2214
	end -- 2214
	if self.phase == "gate-send" then -- 2214
		return "送别" -- 2217
	end -- 2217
	if self.phase == "gate-count" then -- 2217
		return "数数 " .. tostring(self.countTick) -- 2220
	end -- 2220
	return "她走" -- 2222
end -- 2209
function Play.prototype.dogLabel(self) -- 2226
	if self.dogState == "ear" then -- 2226
		return "转耳" -- 2228
	end -- 2228
	if self.dogState == "chase" then -- 2228
		return "追" -- 2231
	end -- 2231
	if self.dogState == "sniff" then -- 2231
		return "停" -- 2234
	end -- 2234
	if self.dogState == "back" then -- 2234
		return "回线" -- 2237
	end -- 2237
	return "巡逻" -- 2239
end -- 2226
function Play.prototype.doorXOf(self) -- 2242
	local ____temp_15 -- 2243
	if self.room.story == nil then -- 2243
		____temp_15 = nil -- 2243
	else -- 2243
		____temp_15 = self.room.story.tower -- 2243
	end -- 2243
	local t = ____temp_15 -- 2243
	return t == nil and 0 or t.doorX -- 2244
end -- 2242
function Play.prototype.scavLabel(self) -- 2248
	if self.scavState == "chase" then -- 2248
		return "追" -- 2250
	end -- 2250
	if self.scavState == "turn" then -- 2250
		return "转头" -- 2253
	end -- 2253
	if self.scavState == "walk" then -- 2253
		return "赶来" -- 2256
	end -- 2256
	if self.scavState == "stall" then -- 2256
		return "停住" -- 2259
	end -- 2259
	if self.scavState == "back" then -- 2259
		return "回位" -- 2262
	end -- 2262
	return "巡逻" -- 2264
end -- 2248
function Play.prototype.hintText(self) -- 2268
	if self.paused then -- 2268
		return "Esc 继续 · R 重置" -- 2270
	end -- 2270
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2270
		if self:threatened() then -- 2270
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2276
		end -- 2276
		if self.coverHug then -- 2276
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2279
		end -- 2279
		if self.coverNear then -- 2279
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2282
		end -- 2282
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2284
	end -- 2284
	if self.flash ~= "" then -- 2284
		return self.flash -- 2287
	end -- 2287
	if self.room.key == "prologue" then -- 2287
		if self.phase == "prologue-wait" then -- 2287
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2291
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2292
		end -- 2292
		if self.phase == "prologue-give" then -- 2292
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2295
		end -- 2295
		return "她跟着你了 · 两人一起走到门口 680" -- 2297
	end -- 2297
	if self.room.key == "street" then -- 2297
		if self:aliveEnemies() > 0 then -- 2297
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2301
		end -- 2301
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2303
	end -- 2303
	if self.room.key == "gate" then -- 2303
		local ____temp_16 -- 2306
		if self.room.story == nil then -- 2306
			____temp_16 = nil -- 2306
		else -- 2306
			____temp_16 = self.room.story.gate -- 2306
		end -- 2306
		local g = ____temp_16 -- 2306
		if g ~= nil then -- 2306
			if self.phase == "gate-idle" then -- 2306
				if self.gateNeedConfirm then -- 2306
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2310
				end -- 2310
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2312
			end -- 2312
			if self.phase == "gate-hold" then -- 2312
				if self.coveredFlash > 0 then -- 2312
					return "掩体挡下了这一枪 · 别露头" -- 2316
				end -- 2316
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2318
			end -- 2318
			if self.phase == "gate-send" then -- 2318
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2321
			end -- 2321
			if self.phase == "gate-count" then -- 2321
				if self.countTick >= 1440 then -- 2321
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2325
				end -- 2325
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2327
			end -- 2327
			return "她自己走 · 跟着出城门 1120" -- 2329
		end -- 2329
	end -- 2329
	if self.room.key == "forest" then -- 2329
		if self.dogState == "chase" then -- 2329
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2334
		end -- 2334
		if self.dogState == "ear" then -- 2334
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2337
		end -- 2337
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2339
	end -- 2339
	if self.room.key == "tower" then -- 2339
		if self.phase == "tower-wait" then -- 2339
			return "走到门前 445 点一次 E 敲两下" -- 2343
		end -- 2343
		if self.phase == "tower-knock" then -- 2343
			return "敲两下 · 等门开" -- 2346
		end -- 2346
		if self.phase == "tower-given" then -- 2346
			return "递交针套和纸条 · 看登记簿最后一行" -- 2349
		end -- 2349
		return "片尾 · 点 E 再玩一次，回到序章" -- 2351
	end -- 2351
	if self.room.key == "village" then -- 2351
		if self.bottleFly ~= nil then -- 2351
			return "等瓶子落地 · 触地才发声" -- 2355
		end -- 2355
		if self.hasBottle then -- 2355
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2358
		end -- 2358
		if self.passed then -- 2358
			return "已过第一院 · R 重置可再来一遍" -- 2361
		end -- 2361
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2363
	end -- 2363
	if self.room.key == "outside" then -- 2363
		if self.focusCart then -- 2363
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2367
		end -- 2367
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2369
	end -- 2369
	if self.escort.state == "frozen" then -- 2369
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2369
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2373
		end -- 2373
		return "小满吓住了 · 走过去，靠近再点 E" -- 2375
	end -- 2375
	if self.escort.state == "calming" then -- 2375
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2378
	end -- 2378
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2380
end -- 2268
function Play.prototype.draw(self, draw, w, h) -- 2385
	self.viewW = w -- 2386
	self.viewH = h -- 2387
	self.view = ____exports.computeViewport(w, h) -- 2388
	self:clampCamera(w, h) -- 2389
	draw:clear() -- 2390
	draw:drawRect( -- 2392
		Rect(0, 0, w, h), -- 2392
		BG_VOID -- 2392
	) -- 2392
	local box = self:canvasRect(w, h) -- 2393
	draw:drawRect(box, BG_FAR) -- 2394
	draw:drawRect( -- 2395
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2395
		BG_MID -- 2395
	) -- 2395
	self:drawFloors(draw, w, h) -- 2397
	self:drawSolids(draw, w, h) -- 2398
	self:drawZones(draw, w, h) -- 2399
	self:drawArch(draw, w, h) -- 2400
	self:drawCart(draw, w, h) -- 2401
	self:drawActors(draw, w, h) -- 2402
	self:drawTrace(draw, w, h) -- 2403
	self:drawAim(draw, w, h) -- 2404
end -- 2385
function Play.prototype.canvasRect(self, w, h) -- 2408
	local v = self.view -- 2409
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2410
end -- 2408
function Play.prototype.px(self, n) -- 2414
	return n * self.view.zoom -- 2415
end -- 2414
function Play.prototype.sx(self, wx, w) -- 2419
	local v = self.view -- 2420
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2421
	return v.ox + lx * v.zoom -- 2422
end -- 2419
function Play.prototype.sy(self, wy, h) -- 2426
	local v = self.view -- 2427
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2428
	return v.oy + ly * v.zoom -- 2429
end -- 2426
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2432
	local px0 = self:sx(x0, w) -- 2433
	local px1 = self:sx(x1, w) -- 2434
	local py0 = self:sy(y0, h) -- 2435
	local py1 = self:sy(y1, h) -- 2436
	if px1 <= px0 or py1 <= py0 then -- 2436
		return -- 2438
	end -- 2438
	draw:drawRect( -- 2440
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2440
		color -- 2440
	) -- 2440
end -- 2432
function Play.prototype.drawFloors(self, draw, w, h) -- 2443
	local i = 0 -- 2444
	do -- 2444
		i = 0 -- 2445
		while i < #self.room.floors do -- 2445
			local f = self.room.floors[i + 1] -- 2446
			local y = self:sy(f.y, h) -- 2447
			local x0 = self:sx(f.x0, w) -- 2448
			local x1 = self:sx(f.x1, w) -- 2449
			local deck = self:px(5) -- 2450
			draw:drawRect( -- 2451
				Rect(x0, y - deck, x1 - x0, deck), -- 2451
				FLOOR_DECK -- 2451
			) -- 2451
			draw:drawSegment( -- 2452
				Vec2(x0, y), -- 2452
				Vec2(x1, y), -- 2452
				self:px(1), -- 2452
				GROUND -- 2452
			) -- 2452
			i = i + 1 -- 2445
		end -- 2445
	end -- 2445
end -- 2443
function Play.prototype.drawSolids(self, draw, w, h) -- 2456
	local i = 0 -- 2457
	do -- 2457
		i = 0 -- 2458
		while i < #self.boxes do -- 2458
			do -- 2458
				local b = self.boxes[i + 1] -- 2459
				if b.y0 < -4 and b.y1 <= 96 then -- 2459
					draw:drawSegment( -- 2462
						Vec2( -- 2462
							self:sx(b.x0, w), -- 2462
							self:sy(b.y1, h) -- 2462
						), -- 2462
						Vec2( -- 2462
							self:sx(b.x1, w), -- 2462
							self:sy(b.y1, h) -- 2462
						), -- 2462
						self:px(1), -- 2462
						GROUND -- 2462
					) -- 2462
					goto __continue476 -- 2463
				end -- 2463
				self:drawBox( -- 2465
					draw, -- 2465
					w, -- 2465
					h, -- 2465
					b.x0, -- 2465
					b.x1, -- 2465
					b.y0, -- 2465
					b.y1, -- 2465
					SOLID_FILL -- 2465
				) -- 2465
				draw:drawSegment( -- 2466
					Vec2( -- 2466
						self:sx(b.x0, w), -- 2466
						self:sy(b.y1, h) -- 2466
					), -- 2466
					Vec2( -- 2466
						self:sx(b.x1, w), -- 2466
						self:sy(b.y1, h) -- 2466
					), -- 2466
					self:px(1), -- 2466
					SOLID_EDGE -- 2466
				) -- 2466
			end -- 2466
			::__continue476:: -- 2466
			i = i + 1 -- 2458
		end -- 2458
	end -- 2458
end -- 2456
function Play.prototype.drawZones(self, draw, w, h) -- 2470
	local i = 0 -- 2471
	do -- 2471
		i = 0 -- 2472
		while i < #self.room.zones do -- 2472
			local z = self.room.zones[i + 1] -- 2473
			local fill = DANGER -- 2474
			local line = DANGER_LINE -- 2475
			if z.tint == 2 then -- 2475
				fill = SOFT -- 2477
				line = SOFT_LINE -- 2478
			elseif z.tint == 3 then -- 2478
				fill = BRICK -- 2480
				line = BRICK_LINE -- 2481
			elseif z.tint == 4 then -- 2481
				fill = PASS -- 2483
				line = PASS_LINE -- 2484
			end -- 2484
			self:drawBox( -- 2486
				draw, -- 2486
				w, -- 2486
				h, -- 2486
				z.x0, -- 2486
				z.x1, -- 2486
				z.y, -- 2486
				z.y + z.h, -- 2486
				fill -- 2486
			) -- 2486
			draw:drawSegment( -- 2487
				Vec2( -- 2487
					self:sx(z.x0, w), -- 2487
					self:sy(z.y, h) -- 2487
				), -- 2487
				Vec2( -- 2487
					self:sx(z.x0, w), -- 2487
					self:sy(z.y + z.h, h) -- 2487
				), -- 2487
				self:px(1), -- 2487
				line -- 2487
			) -- 2487
			draw:drawSegment( -- 2488
				Vec2( -- 2488
					self:sx(z.x1, w), -- 2488
					self:sy(z.y, h) -- 2488
				), -- 2488
				Vec2( -- 2488
					self:sx(z.x1, w), -- 2488
					self:sy(z.y + z.h, h) -- 2488
				), -- 2488
				self:px(1), -- 2488
				line -- 2488
			) -- 2488
			i = i + 1 -- 2472
		end -- 2472
	end -- 2472
end -- 2470
function Play.prototype.drawArch(self, draw, w, h) -- 2492
	local a = self.room.arch -- 2493
	if a.h <= 0 then -- 2493
		return -- 2495
	end -- 2495
	self:drawBox( -- 2497
		draw, -- 2497
		w, -- 2497
		h, -- 2497
		a.x0, -- 2497
		a.x1, -- 2497
		a.y, -- 2497
		a.y + a.h, -- 2497
		HOLE_FILL -- 2497
	) -- 2497
	draw:drawSegment( -- 2498
		Vec2( -- 2498
			self:sx(a.x0, w), -- 2498
			self:sy(a.y + a.h, h) -- 2498
		), -- 2498
		Vec2( -- 2498
			self:sx(a.x1, w), -- 2498
			self:sy(a.y + a.h, h) -- 2498
		), -- 2498
		self:px(1), -- 2498
		SOLID_EDGE -- 2498
	) -- 2498
	draw:drawSegment( -- 2499
		Vec2( -- 2499
			self:sx(a.x0, w), -- 2499
			self:sy(a.y, h) -- 2499
		), -- 2499
		Vec2( -- 2499
			self:sx(a.x0, w), -- 2499
			self:sy(a.y + a.h, h) -- 2499
		), -- 2499
		self:px(1), -- 2499
		SOLID_EDGE -- 2499
	) -- 2499
	draw:drawSegment( -- 2500
		Vec2( -- 2500
			self:sx(a.x1, w), -- 2500
			self:sy(a.y, h) -- 2500
		), -- 2500
		Vec2( -- 2500
			self:sx(a.x1, w), -- 2500
			self:sy(a.y + a.h, h) -- 2500
		), -- 2500
		self:px(1), -- 2500
		SOLID_EDGE -- 2500
	) -- 2500
end -- 2492
function Play.prototype.drawCart(self, draw, w, h) -- 2503
	local c = self.room.cart -- 2504
	if c.bodyW <= 0 then -- 2504
		return -- 2506
	end -- 2506
	drawCartShape( -- 2508
		draw, -- 2508
		self, -- 2508
		w, -- 2508
		h, -- 2508
		c, -- 2508
		self.cartAxle -- 2508
	) -- 2508
	draw:drawRect( -- 2509
		Rect( -- 2509
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2509
			self:sy(c.baseY + 40, h), -- 2509
			self:px(2), -- 2509
			self:px(40) -- 2509
		), -- 2509
		STAND -- 2509
	) -- 2509
end -- 2503
function Play.prototype.drawActors(self, draw, w, h) -- 2512
	local p = self.player -- 2513
	local isChild = self.childMode -- 2514
	if p.covered then -- 2514
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2517
		draw:drawSegment( -- 2518
			Vec2( -- 2518
				self:sx(edge, w), -- 2518
				self:sy(p.y + 8, h) -- 2518
			), -- 2518
			Vec2( -- 2518
				self:sx(edge, w), -- 2518
				self:sy(p.y + p.h * 0.62, h) -- 2518
			), -- 2518
			self:px(2), -- 2518
			STAND -- 2518
		) -- 2518
		draw:drawSegment( -- 2520
			Vec2( -- 2520
				self:sx(p.x - 8, w), -- 2520
				self:sy(p.y + p.h + 3, h) -- 2520
			), -- 2520
			Vec2( -- 2520
				self:sx(p.x + 8, w), -- 2520
				self:sy(p.y + p.h + 3, h) -- 2520
			), -- 2520
			self:px(2), -- 2520
			STAND -- 2520
		) -- 2520
	elseif self.coverNear and not isChild then -- 2520
		draw:drawRect( -- 2523
			Rect( -- 2523
				self:sx(p.x - 3, w), -- 2523
				self:sy(p.y + 1, h), -- 2523
				self:px(3), -- 2523
				self:px(3) -- 2523
			), -- 2523
			STAND -- 2523
		) -- 2523
	end -- 2523
	drawFigure( -- 2525
		draw, -- 2525
		self, -- 2525
		w, -- 2525
		h, -- 2525
		p, -- 2525
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2525
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2525
	) -- 2525
	local q = self.partner -- 2526
	if q.alive then -- 2526
		local childPartner = q.w == CHILD_W -- 2528
		drawFigure( -- 2529
			draw, -- 2529
			self, -- 2529
			w, -- 2529
			h, -- 2529
			q, -- 2529
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2529
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2529
		) -- 2529
	end -- 2529
	local i = 0 -- 2531
	do -- 2531
		i = 0 -- 2532
		while i < #self.enemies do -- 2532
			local e = self.enemies[i + 1] -- 2533
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2534
			self:drawBox( -- 2535
				draw, -- 2535
				w, -- 2535
				h, -- 2535
				e.x - e.w / 2, -- 2535
				e.x + e.w / 2, -- 2535
				e.y, -- 2535
				e.y + e.h, -- 2535
				col -- 2535
			) -- 2535
			if e.alive and e.warnT > 0 then -- 2535
				local gunX = self:sx(e.x, w) -- 2538
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2539
				local aimX = self:sx(p.x, w) -- 2540
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2541
				local seg = 8 -- 2542
				local s = 0 -- 2543
				do -- 2543
					s = 0 -- 2544
					while s < seg do -- 2544
						local t0 = s / seg -- 2545
						local t1 = (s + 1) / seg -- 2546
						draw:drawSegment( -- 2547
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2548
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2549
							self:px(1), -- 2550
							DANGER -- 2550
						) -- 2550
						s = s + 2 -- 2544
					end -- 2544
				end -- 2544
			end -- 2544
			i = i + 1 -- 2532
		end -- 2532
	end -- 2532
	local k = 0 -- 2555
	do -- 2555
		k = 0 -- 2556
		while k < #self.room.marks do -- 2556
			do -- 2556
				local m = self.room.marks[k + 1] -- 2557
				if m.kind ~= 0 then -- 2557
					goto __continue498 -- 2559
				end -- 2559
				local on = self.checkpoint == m.x -- 2561
				local x = self:sx(m.x, w) -- 2562
				local y = self:sy(m.y, h) -- 2563
				draw:drawSegment( -- 2564
					Vec2(x, y), -- 2564
					Vec2( -- 2564
						x, -- 2564
						y + self:px(35) -- 2564
					), -- 2564
					self:px(1), -- 2564
					on and CHECK or INK_DIM -- 2564
				) -- 2564
				draw:drawDot( -- 2565
					Vec2( -- 2565
						x, -- 2565
						y + self:px(35) -- 2565
					), -- 2565
					self:px(2), -- 2565
					on and CHECK or INK_DIM -- 2565
				) -- 2565
			end -- 2565
			::__continue498:: -- 2565
			k = k + 1 -- 2556
		end -- 2556
	end -- 2556
	local j = 0 -- 2569
	do -- 2569
		j = 0 -- 2570
		while j < #self.room.marks do -- 2570
			do -- 2570
				local m = self.room.marks[j + 1] -- 2571
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2571
					goto __continue501 -- 2573
				end -- 2573
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2573
					goto __continue501 -- 2577
				end -- 2577
				local col = STAND -- 2579
				if m.kind == 4 then -- 2579
					col = PASS_LINE -- 2581
				elseif m.kind == 5 then -- 2581
					col = BRICK_LINE -- 2583
				end -- 2583
				local mx = self:sx(m.x, w) -- 2585
				local my = self:sy(m.y, h) -- 2586
				draw:drawSegment( -- 2587
					Vec2(mx, my), -- 2587
					Vec2( -- 2587
						mx, -- 2587
						my + self:px(24) -- 2587
					), -- 2587
					self:px(1), -- 2587
					col -- 2587
				) -- 2587
			end -- 2587
			::__continue501:: -- 2587
			j = j + 1 -- 2570
		end -- 2570
	end -- 2570
	local t = 0 -- 2590
	do -- 2590
		t = 0 -- 2591
		while t < #self.room.marks do -- 2591
			do -- 2591
				local m = self.room.marks[t + 1] -- 2592
				if m.kind ~= 6 then -- 2592
					goto __continue507 -- 2594
				end -- 2594
				local mx = self:sx(m.x, w) -- 2596
				local my = self:sy(m.y, h) -- 2597
				draw:drawSegment( -- 2598
					Vec2(mx, my), -- 2598
					Vec2( -- 2598
						mx, -- 2598
						my + self:px(30) -- 2598
					), -- 2598
					self:px(1), -- 2598
					INK_DIM -- 2598
				) -- 2598
				self:drawBox( -- 2599
					draw, -- 2599
					w, -- 2599
					h, -- 2599
					m.x - 5, -- 2599
					m.x + 5, -- 2599
					m.y + 30, -- 2599
					m.y + 40, -- 2599
					CHECK -- 2599
				) -- 2599
			end -- 2599
			::__continue507:: -- 2599
			t = t + 1 -- 2591
		end -- 2591
	end -- 2591
	if self.room.key == "village" then -- 2591
		self:drawVillage(draw, w, h) -- 2602
	end -- 2602
	if self.room.key == "forest" then -- 2602
		self:drawDog(draw, w, h) -- 2605
	end -- 2605
end -- 2512
function Play.prototype.drawDog(self, draw, w, h) -- 2610
	local x = self.dogX -- 2611
	self:drawBox( -- 2612
		draw, -- 2612
		w, -- 2612
		h, -- 2612
		x - 14, -- 2612
		x + 14, -- 2612
		0, -- 2612
		20, -- 2612
		SCAV_BODY -- 2612
	) -- 2612
	self:drawBox( -- 2613
		draw, -- 2613
		w, -- 2613
		h, -- 2613
		x - 10, -- 2613
		x - 2, -- 2613
		20, -- 2613
		30, -- 2613
		SCAV_BODY -- 2613
	) -- 2613
	self:drawBox( -- 2614
		draw, -- 2614
		w, -- 2614
		h, -- 2614
		x + 2, -- 2614
		x + 10, -- 2614
		20, -- 2614
		30, -- 2614
		SCAV_HEAD -- 2614
	) -- 2614
	if self.dogState == "ear" or self.dogState == "chase" then -- 2614
		draw:drawSegment( -- 2616
			Vec2( -- 2616
				self:sx(x, w), -- 2616
				self:sy(30, h) -- 2616
			), -- 2616
			Vec2( -- 2617
				self:sx(x, w), -- 2617
				self:sy(40, h) -- 2617
			), -- 2617
			self:px(1), -- 2617
			DANGER -- 2617
		) -- 2617
	end -- 2617
end -- 2610
function Play.prototype.drawVillage(self, draw, w, h) -- 2622
	local bottle = self.room.bottle -- 2623
	if bottle ~= nil then -- 2623
		self:drawBox( -- 2625
			draw, -- 2625
			w, -- 2625
			h, -- 2625
			bottle.x - 14, -- 2625
			bottle.x + 14, -- 2625
			0, -- 2625
			64, -- 2625
			SOLID_FILL -- 2625
		) -- 2625
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2625
			self:drawBottle( -- 2627
				draw, -- 2627
				w, -- 2627
				h, -- 2627
				bottle.x, -- 2627
				64 -- 2627
			) -- 2627
		end -- 2627
	end -- 2627
	self:drawBox( -- 2631
		draw, -- 2631
		w, -- 2631
		h, -- 2631
		300, -- 2631
		420, -- 2631
		44, -- 2631
		50, -- 2631
		FLOOR_DECK -- 2631
	) -- 2631
	self:drawBox( -- 2632
		draw, -- 2632
		w, -- 2632
		h, -- 2632
		300, -- 2632
		306, -- 2632
		0, -- 2632
		44, -- 2632
		FLOOR_DECK -- 2632
	) -- 2632
	self:drawBox( -- 2633
		draw, -- 2633
		w, -- 2633
		h, -- 2633
		414, -- 2633
		420, -- 2633
		0, -- 2633
		44, -- 2633
		FLOOR_DECK -- 2633
	) -- 2633
	local s = self.room.scavenger -- 2635
	if s ~= nil then -- 2635
		local sx0 = self.scavX -- 2637
		self:drawBox( -- 2638
			draw, -- 2638
			w, -- 2638
			h, -- 2638
			sx0 - 12, -- 2638
			sx0 + 12, -- 2638
			0, -- 2638
			s.h - 14, -- 2638
			SCAV_BODY -- 2638
		) -- 2638
		self:drawBox( -- 2639
			draw, -- 2639
			w, -- 2639
			h, -- 2639
			sx0 - 7, -- 2639
			sx0 + 7, -- 2639
			s.h - 14, -- 2639
			s.h, -- 2639
			SCAV_HEAD -- 2639
		) -- 2639
		if self.scavState == "turn" then -- 2639
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2641
			draw:drawSegment( -- 2642
				Vec2( -- 2642
					self:sx(sx0, w), -- 2642
					self:sy(s.h - 6, h) -- 2642
				), -- 2642
				Vec2( -- 2642
					self:sx(fx, w), -- 2642
					self:sy(s.h - 6, h) -- 2642
				), -- 2642
				self:px(1), -- 2642
				INK -- 2642
			) -- 2642
		end -- 2642
	end -- 2642
	if self.hasBottle then -- 2642
		local p = self.player -- 2647
		self:drawBottle( -- 2648
			draw, -- 2648
			w, -- 2648
			h, -- 2648
			p.x + p.facing * 10, -- 2648
			p.y + p.h * 0.62 -- 2648
		) -- 2648
	end -- 2648
	if self.bottleFly ~= nil then -- 2648
		self:drawBottle( -- 2651
			draw, -- 2651
			w, -- 2651
			h, -- 2651
			self.bottleFly.x, -- 2651
			self.bottleFly.y -- 2651
		) -- 2651
	end -- 2651
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2651
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2654
		draw:drawCircle( -- 2655
			Vec2( -- 2655
				self:sx(self.bottleLandX, w), -- 2655
				self:sy(0, h) -- 2655
			), -- 2655
			self:px(r / ____exports.UNITS_PER_PX), -- 2655
			BRICK_LINE -- 2655
		) -- 2655
	end -- 2655
end -- 2622
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2659
	self:drawBox( -- 2660
		draw, -- 2660
		w, -- 2660
		h, -- 2660
		x - 3, -- 2660
		x + 3, -- 2660
		y - 10, -- 2660
		y, -- 2660
		BOTTLE -- 2660
	) -- 2660
end -- 2659
function Play.prototype.drawTrace(self, draw, w, h) -- 2663
	local t = self.trace -- 2664
	if t == nil or self.traceT <= 0 then -- 2664
		return -- 2666
	end -- 2666
	draw:drawSegment( -- 2668
		Vec2( -- 2669
			self:sx(t.x0, w), -- 2669
			self:sy(t.y0, h) -- 2669
		), -- 2669
		Vec2( -- 2670
			self:sx(t.x1, w), -- 2670
			self:sy(t.y1, h) -- 2670
		), -- 2670
		self:px(1), -- 2671
		t.hit and AIM_HIT or INK_DIM -- 2671
	) -- 2671
end -- 2663
function Play.prototype.drawAim(self, draw, w, h) -- 2674
	local v = self.view -- 2676
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2677
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2678
	local dot = self:px(1) -- 2679
	local arm = self:px(3) -- 2680
	local gap = self:px(1) -- 2681
	draw:drawSegment( -- 2682
		Vec2(gx - arm - gap, gy), -- 2682
		Vec2(gx - gap, gy), -- 2682
		dot / 2, -- 2682
		AIM -- 2682
	) -- 2682
	draw:drawSegment( -- 2683
		Vec2(gx + gap, gy), -- 2683
		Vec2(gx + arm + gap, gy), -- 2683
		dot / 2, -- 2683
		AIM -- 2683
	) -- 2683
	draw:drawSegment( -- 2684
		Vec2(gx, gy - arm - gap), -- 2684
		Vec2(gx, gy - gap), -- 2684
		dot / 2, -- 2684
		AIM -- 2684
	) -- 2684
	draw:drawSegment( -- 2685
		Vec2(gx, gy + gap), -- 2685
		Vec2(gx, gy + arm + gap), -- 2685
		dot / 2, -- 2685
		AIM -- 2685
	) -- 2685
	if self.room.key == "village" and self.hasBottle then -- 2685
		local p = self.player -- 2689
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2691
		local dir = ____end.x >= p.x and 1 or -1 -- 2692
		local x0 = p.x + dir * 10 -- 2693
		local y0 = p.y + p.h * 0.7 -- 2694
		local T = BOTTLE_FLY_TIME -- 2695
		local vx = (____end.x - x0) / T -- 2696
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2697
		local pxr = x0 -- 2698
		local pyr = y0 -- 2699
		local t = 1 -- 2700
		do -- 2700
			t = 1 -- 2701
			while t <= 12 do -- 2701
				local tt = t / 12 * T -- 2702
				local nx = x0 + vx * tt -- 2703
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2704
				draw:drawSegment( -- 2705
					Vec2( -- 2705
						self:sx(pxr, w), -- 2705
						self:sy(pyr, h) -- 2705
					), -- 2705
					Vec2( -- 2705
						self:sx(nx, w), -- 2705
						self:sy(ny, h) -- 2705
					), -- 2705
					self:px(1) / 2, -- 2705
					BOTTLE -- 2705
				) -- 2705
				pxr = nx -- 2706
				pyr = ny -- 2707
				t = t + 1 -- 2701
			end -- 2701
		end -- 2701
		draw:drawCircle( -- 2709
			Vec2( -- 2709
				self:sx(____end.x, w), -- 2709
				self:sy(____end.y + 2, h) -- 2709
			), -- 2709
			self:px(2), -- 2709
			BOTTLE -- 2709
		) -- 2709
	end -- 2709
end -- 2674
return ____exports -- 2674