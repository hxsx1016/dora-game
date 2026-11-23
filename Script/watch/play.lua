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
function makeActor(room, index) -- 2673
	local sp = room.spawns -- 2674
	if index < 0 or index >= #sp then -- 2674
		return { -- 2676
			x = 0, -- 2676
			y = 0, -- 2676
			vx = 0, -- 2676
			vy = 0, -- 2676
			w = CHILD_W, -- 2676
			h = CHILD_H, -- 2676
			onGround = true, -- 2676
			facing = 1, -- 2676
			crouch = false, -- 2676
			rollT = 0, -- 2676
			covered = false, -- 2676
			alive = false -- 2676
		} -- 2676
	end -- 2676
	local s = sp[index + 1] -- 2678
	local child = s.h <= CHILD_H -- 2679
	return { -- 2680
		x = s.x, -- 2681
		y = s.y, -- 2681
		vx = 0, -- 2681
		vy = 0, -- 2681
		w = child and CHILD_W or SOLDIER_W, -- 2682
		h = child and CHILD_H or SOLDIER_H, -- 2683
		onGround = true, -- 2684
		facing = 1, -- 2684
		crouch = false, -- 2684
		rollT = 0, -- 2684
		covered = false, -- 2684
		alive = true -- 2684
	} -- 2684
end -- 2684
function drawFigure(draw, play, w, h, a, body, head) -- 2688
	if not a.alive then -- 2688
		return -- 2690
	end -- 2690
	local x0 = a.x - a.w / 2 -- 2692
	local x1 = a.x + a.w / 2 -- 2693
	local y0 = a.y -- 2694
	local y1 = a.y + a.h -- 2695
	play:drawBox( -- 2696
		draw, -- 2696
		w, -- 2696
		h, -- 2696
		x0, -- 2696
		x1, -- 2696
		y0, -- 2696
		y1 - a.h * 0.26, -- 2696
		body -- 2696
	) -- 2696
	play:drawBox( -- 2697
		draw, -- 2697
		w, -- 2697
		h, -- 2697
		x0 + 2, -- 2697
		x1 - 2, -- 2697
		y1 - a.h * 0.26, -- 2697
		y1, -- 2697
		head -- 2697
	) -- 2697
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2699
	play:drawBox( -- 2700
		draw, -- 2700
		w, -- 2700
		h, -- 2700
		eyeX, -- 2700
		eyeX + 4, -- 2700
		y1 - a.h * 0.14, -- 2700
		y1 - a.h * 0.08, -- 2700
		INK -- 2700
	) -- 2700
end -- 2700
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2704
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2705
end -- 2704
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2712
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2713
end -- 2712
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2720
	local tmin = 0 -- 2721
	local tmax = 99999 -- 2722
	if dx == 0 then -- 2722
		if ox < x0 or ox > x1 then -- 2722
			return -1 -- 2725
		end -- 2725
	else -- 2725
		local t1 = (x0 - ox) / dx -- 2728
		local t2 = (x1 - ox) / dx -- 2729
		local lo = t1 < t2 and t1 or t2 -- 2730
		local hi = t1 < t2 and t2 or t1 -- 2731
		if lo > tmin then -- 2731
			tmin = lo -- 2733
		end -- 2733
		if hi < tmax then -- 2733
			tmax = hi -- 2736
		end -- 2736
	end -- 2736
	if dy == 0 then -- 2736
		if oy < y0 or oy > y1 then -- 2736
			return -1 -- 2741
		end -- 2741
	else -- 2741
		local t1 = (y0 - oy) / dy -- 2744
		local t2 = (y1 - oy) / dy -- 2745
		local lo = t1 < t2 and t1 or t2 -- 2746
		local hi = t1 < t2 and t2 or t1 -- 2747
		if lo > tmin then -- 2747
			tmin = lo -- 2749
		end -- 2749
		if hi < tmax then -- 2749
			tmax = hi -- 2752
		end -- 2752
	end -- 2752
	return tmax >= tmin and tmin or -1 -- 2755
end -- 2755
function drawCartShape(draw, play, w, h, c, axleX) -- 2758
	local half = c.bodyW / 2 -- 2759
	local x0 = axleX - half -- 2760
	local x1 = axleX + half -- 2761
	play:drawBox( -- 2762
		draw, -- 2762
		w, -- 2762
		h, -- 2762
		x0, -- 2762
		x1, -- 2762
		c.baseY + c.wheelR, -- 2762
		c.baseY + c.wheelR + c.bodyH, -- 2762
		CART_FILL -- 2762
	) -- 2762
	draw:drawCircle( -- 2763
		Vec2( -- 2763
			play:sx(x0 + c.bodyW * 0.28, w), -- 2763
			play:sy(c.baseY + c.wheelR, h) -- 2763
		), -- 2763
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2763
		Color(52, 50, 48, 255) -- 2763
	) -- 2763
	draw:drawCircle( -- 2764
		Vec2( -- 2764
			play:sx(x1 - c.bodyW * 0.28, w), -- 2764
			play:sy(c.baseY + c.wheelR, h) -- 2764
		), -- 2764
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2764
		Color(52, 50, 48, 255) -- 2764
	) -- 2764
	local cx = c.clothSide < 0 and x0 or x1 -- 2765
	play:drawBox( -- 2766
		draw, -- 2766
		w, -- 2766
		h, -- 2766
		cx - 10, -- 2766
		cx + 10, -- 2766
		c.baseY + c.wheelR + c.bodyH, -- 2766
		c.baseY + c.wheelR + c.bodyH + 18, -- 2766
		CLOTH -- 2766
	) -- 2766
end -- 2766
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
function Play.prototype.coverAt(self, a) -- 534
	local best = nil -- 535
	local bestGap = 24 -- 536
	local half = a.w / 2 -- 537
	local i = 0 -- 538
	do -- 538
		i = 0 -- 539
		while i < #self.boxes do -- 539
			do -- 539
				local b = self.boxes[i + 1] -- 540
				if b.passable == true or b.y1 - b.y0 < 44 then -- 540
					goto __continue46 -- 542
				end -- 542
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 542
					goto __continue46 -- 545
				end -- 545
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 547
				if gap < bestGap then -- 547
					bestGap = gap -- 549
					best = b -- 550
				end -- 550
			end -- 550
			::__continue46:: -- 550
			i = i + 1 -- 539
		end -- 539
	end -- 539
	return best -- 553
end -- 534
function Play.prototype.nearCover(self, a) -- 556
	return self:coverAt(a) ~= nil -- 557
end -- 556
function Play.prototype.coverGuardsFrom(self, b, a, enemyX) -- 561
	if enemyX < 0 then -- 561
		return false -- 563
	end -- 563
	if enemyX >= a.x then -- 563
		return b.x0 >= a.x - 0.001 and b.x0 <= enemyX -- 566
	end -- 566
	return b.x1 <= a.x + 0.001 and b.x1 >= enemyX -- 568
end -- 561
function Play.prototype.nearestEnemyX(self, a) -- 572
	local best = -1 -- 573
	local bestD = 1000000000 -- 574
	local i = 0 -- 575
	do -- 575
		i = 0 -- 576
		while i < #self.enemies do -- 576
			do -- 576
				local e = self.enemies[i + 1] -- 577
				if not e.alive then -- 577
					goto __continue56 -- 579
				end -- 579
				local d = math.abs(e.x - a.x) -- 581
				if d < bestD then -- 581
					bestD = d -- 583
					best = e.x -- 584
				end -- 584
			end -- 584
			::__continue56:: -- 584
			i = i + 1 -- 576
		end -- 576
	end -- 576
	return best -- 587
end -- 572
function Play.prototype.refreshCover(self, a, input) -- 591
	if self.childMode then -- 591
		self.coverNear = false -- 593
		self.coverHug = false -- 594
		self.coverEntity = "" -- 595
		self.coverBlocking = false -- 596
		a.covered = false -- 597
		return -- 598
	end -- 598
	local b = self:coverAt(a) -- 600
	self.coverNear = b ~= nil -- 601
	a.covered = self.coverNear and input.cover.held -- 602
	self.coverHug = a.covered -- 603
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 604
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 605
		b, -- 605
		a, -- 605
		self:nearestEnemyX(a) -- 605
	) -- 605
end -- 591
function Play.prototype.nearLowLedge(self, a) -- 609
	local reach = 26 -- 610
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 611
	local x1 = x0 + reach -- 612
	local i = 0 -- 613
	do -- 613
		i = 0 -- 614
		while i < #self.boxes do -- 614
			do -- 614
				local b = self.boxes[i + 1] -- 615
				if b.x1 <= x0 or b.x0 >= x1 then -- 615
					goto __continue63 -- 617
				end -- 617
				local rise = b.y1 - a.y -- 619
				if rise > 0 and rise <= LEDGE_RISE then -- 619
					return true -- 621
				end -- 621
			end -- 621
			::__continue63:: -- 621
			i = i + 1 -- 614
		end -- 614
	end -- 614
	return false -- 624
end -- 609
function Play.prototype.stepPlayer(self, a, dt, input) -- 627
	if not a.alive then -- 627
		return -- 629
	end -- 629
	local isChild = self.childMode -- 631
	if self:storyLocked() then -- 631
		a.vx = 0 -- 634
		a.crouch = false -- 635
		a.h = isChild and CHILD_H or SOLDIER_H -- 636
		self:fallY(a, dt) -- 637
		return -- 638
	end -- 638
	if not isChild and self.escort.state == "calming" then -- 638
		a.crouch = false -- 642
		a.h = SOLDIER_H -- 643
		a.vx = 0 -- 644
		self:fallY(a, dt) -- 645
		return -- 646
	end -- 646
	a.crouch = isChild and input.crouch.held and a.onGround -- 648
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 649
	local nearCover = not isChild and self:nearCover(a) -- 650
	a.covered = nearCover and input.cover.held -- 651
	if a.rollT > 0 then -- 651
		a.rollT = a.rollT - dt -- 655
		a.vx = a.facing * ROLL_SPEED -- 656
		self:slideX(a, a.vx * dt) -- 657
		self:fallY(a, dt) -- 658
		if a.rollT <= 0 then -- 658
			self:flashSet("翻滚结束", 0.5) -- 660
		end -- 660
		return -- 662
	end -- 662
	if not isChild and input.jump.pressed and a.onGround then -- 662
		if input.moveX ~= 0 then -- 662
			a.facing = input.moveX > 0 and 1 or -1 -- 667
		end -- 667
		if self:nearLowLedge(a) then -- 667
			a.vy = SOLDIER_JUMP -- 671
			a.onGround = false -- 672
			self:flashSet("翻上去", 0.3) -- 673
			return -- 674
		end -- 674
		a.rollT = ROLL_TIME -- 676
		self:flashSet("翻滚", 0.3) -- 677
		return -- 678
	end -- 678
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 681
	if isChild then -- 681
		if input.cover.held then -- 681
			speed = CHILD_SLOW -- 684
		end -- 684
		if a.crouch then -- 684
			speed = CHILD_SLOW -- 687
		end -- 687
	elseif a.covered then -- 687
		speed = SOLDIER_SPEED * 0.45 -- 690
	end -- 690
	local dir = self.gripping and 0 or input.moveX -- 694
	if dir ~= 0 then -- 694
		a.facing = dir > 0 and 1 or -1 -- 696
	end -- 696
	a.vx = dir * speed -- 698
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 698
		a.vy = CHILD_JUMP -- 702
		a.onGround = false -- 703
		self:flashSet("跳", 0.25) -- 704
	end -- 704
	self:slideX(a, a.vx * dt) -- 707
	self:fallY(a, dt) -- 708
	if not isChild and input.fire.pressed then -- 708
		self:shoot(a) -- 712
	end -- 712
end -- 627
function Play.prototype.stepPartner(self, p, dt) -- 717
	local a = self.partner -- 718
	if not a.alive then -- 718
		return -- 720
	end -- 720
	a.crouch = false -- 722
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 723
	a.vx = 0 -- 724
	self:fallY(a, dt) -- 725
end -- 717
function Play.prototype.stepEscort(self, dt, input) -- 732
	local a = self.partner -- 733
	if not a.alive then -- 733
		return -- 735
	end -- 735
	if not self:escortOn() then -- 735
		a.vx = 0 -- 738
		self:fallY(a, dt) -- 739
		return -- 740
	end -- 740
	local p = self.player -- 742
	local dist = math.abs(p.x - a.x) -- 743
	local hadKnock1 = self.escort.knock1 -- 744
	local hadKnock2 = self.escort.knock2 -- 745
	self.calmConsumed = self.escort:update( -- 746
		input, -- 746
		p.x, -- 746
		p.facing, -- 746
		a.x, -- 746
		dist -- 746
	) -- 746
	if not hadKnock1 and self.escort.knock1 then -- 746
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 749
	end -- 749
	if not hadKnock2 and self.escort.knock2 then -- 749
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 752
	end -- 752
	a.crouch = self.escort.crouchPose -- 754
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 755
	local dir = self.escort:moveDir(a.x) -- 756
	a.vx = dir * CHILD_SPEED -- 757
	if dir ~= 0 then -- 757
		a.facing = dir -- 759
		local before = a.x -- 760
		self:slideX(a, dir * CHILD_SPEED * dt) -- 761
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 761
			a.vy = CHILD_JUMP -- 764
			a.onGround = false -- 765
		end -- 765
	end -- 765
	self:fallY(a, dt) -- 768
end -- 732
function Play.prototype.escortOn(self) -- 772
	if self.room.key == "checkpoint" then -- 772
		return true -- 774
	end -- 774
	if self.room.key == "prologue" then -- 774
		return self.phase == "prologue-follow" -- 777
	end -- 777
	return self.room.key == "street" -- 779
end -- 772
function Play.prototype.storyLocked(self) -- 783
	if self.caughtT > 0 then -- 783
		return true -- 785
	end -- 785
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 785
		return true -- 788
	end -- 788
	if self.room.key == "gate" and self.phase == "gate-count" then -- 788
		return true -- 791
	end -- 791
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 791
		return true -- 794
	end -- 794
	return false -- 796
end -- 783
function Play.prototype.swapToChild(self, x) -- 800
	local tmp = self.player -- 801
	self.player = self.partner -- 802
	self.partner = tmp -- 803
	self.childMode = true -- 804
	self.player.alive = true -- 805
	self.player.x = self.ox + x -- 806
	self.player.y = 0 -- 807
	self.player.vy = 0 -- 808
	self.player.vx = 0 -- 809
	self.player.onGround = true -- 810
	self.player.crouch = false -- 811
	self.player.h = CHILD_H -- 812
	self.player.facing = 1 -- 813
	self.partner.alive = true -- 814
	self.cam.x = self.player.x -- 815
end -- 800
function Play.prototype.stepStory(self, dt, input) -- 819
	if self.room.key == "prologue" then -- 819
		self:stepPrologue(dt, input) -- 821
	elseif self.room.key == "street" then -- 821
		self:stepStreet(dt, input) -- 823
	elseif self.room.key == "gate" then -- 823
		self:stepGate(dt, input) -- 825
	elseif self.room.key == "tower" then -- 825
		self:stepTower(dt, input) -- 827
	end -- 827
end -- 819
function Play.prototype.stepPrologue(self, dt, input) -- 832
	local child = self.partner -- 833
	if self.phase == "prologue-wait" then -- 833
		child.crouch = true -- 835
		child.h = CHILD_CROUCH_H -- 836
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 837
		local near = math.abs(self.player.x - child.x) <= reach -- 839
		if near and input.interact.pressed then -- 839
			self.phase = "prologue-give" -- 841
			self.phaseTick = 0 -- 842
			self:flashSet("递出针套", 1) -- 843
		end -- 843
		return -- 845
	end -- 845
	if self.phase == "prologue-give" then -- 845
		self.phaseTick = self.phaseTick + 1 -- 848
		if self.phaseTick == 12 then -- 848
			self:flashSet("针套递过去", 0.7) -- 850
		elseif self.phaseTick == 36 then -- 850
			self:flashSet("纸条塞进针套", 0.9) -- 852
		elseif self.phaseTick >= 60 then -- 852
			self.phase = "prologue-follow" -- 854
			self.phaseTick = 0 -- 855
			child.crouch = false -- 856
			child.h = CHILD_H -- 857
			self:flashSet("她跟上了", 1.2) -- 858
		end -- 858
		return -- 860
	end -- 860
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 860
		self:requestRoom("street", "序章跟到门口") -- 864
		self:flashSet("进街道", 1.2) -- 865
	end -- 865
end -- 832
function Play.prototype.stepStreet(self, dt, input) -- 870
	local p = self.player -- 871
	local c = self.partner -- 872
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 872
		self:requestRoom("checkpoint", "两人都到街尾") -- 874
		self:flashSet("到检查站", 1.2) -- 875
	end -- 875
end -- 870
function Play.prototype.stepGate(self, dt, input) -- 880
	local ____temp_8 -- 881
	if self.room.story == nil then -- 881
		____temp_8 = nil -- 881
	else -- 881
		____temp_8 = self.room.story.gate -- 881
	end -- 881
	local g = ____temp_8 -- 881
	if g == nil then -- 881
		return -- 883
	end -- 883
	local p = self.player -- 885
	if self.phase == "gate-idle" then -- 885
		local a = self.partner -- 888
		local gap = g.waitX - a.x -- 889
		if math.abs(gap) > 3 then -- 889
			a.facing = gap > 0 and 1 or -1 -- 891
			a.vx = a.facing * CHILD_SPEED -- 892
			local beforeX = a.x -- 893
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 894
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 894
				a.vy = CHILD_JUMP -- 896
				a.onGround = false -- 897
			end -- 897
			self:fallY(a, dt) -- 899
		else -- 899
			a.vx = 0 -- 901
			a.x = g.waitX -- 902
		end -- 902
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 905
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 906
		if self.gateNeedConfirm then -- 906
			if not input.interact.held then -- 906
				self.gateRestartArmed = true -- 911
			end -- 911
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 911
				self.gateNeedConfirm = false -- 914
				self.gateRestartArmed = true -- 915
				self.phase = "gate-hold" -- 916
				self.gateTick = 0 -- 917
				self.gateSpawned = 0 -- 918
				self:flashSet("重新就位 · 守点开始", 1.4) -- 919
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 920
			end -- 920
			return -- 922
		end -- 922
		if atWinch and atWait then -- 922
			self.phase = "gate-hold" -- 925
			self.gateTick = 0 -- 926
			self.gateSpawned = 0 -- 927
			self:flashSet("两人就位 · 守点开始", 1.4) -- 928
		end -- 928
		return -- 930
	end -- 930
	if self.phase == "gate-hold" then -- 930
		self.gateTick = self.gateTick + 1 -- 933
		local marks = {0, 540, 900, 1500} -- 935
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 935
			local idx = self.gateSpawned -- 937
			local ____self_enemies_9 = self.enemies -- 937
			____self_enemies_9[#____self_enemies_9 + 1] = { -- 938
				x = self.ox + 620 + idx * 62, -- 939
				y = 0, -- 939
				w = 26, -- 939
				h = 84, -- 939
				alive = true, -- 940
				hitT = 0, -- 940
				warnT = 0, -- 940
				fireCd = 90 + idx * 45 -- 940
			} -- 940
			self.gateSpawned = self.gateSpawned + 1 -- 942
			self:flashSet( -- 943
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 943
				0.9 -- 943
			) -- 943
		end -- 943
		if self.gateTick == 900 then -- 943
			self:flashSet("灯灭了", 1) -- 946
		elseif self.gateTick == 2100 then -- 946
			self:flashSet("门底压下来了", 1) -- 948
		end -- 948
		if self.gateTick >= g.holdTicks then -- 948
			self.phase = "gate-send" -- 951
			self.phaseTick = 0 -- 952
			self.enemies = {} -- 954
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 955
		end -- 955
		return -- 957
	end -- 957
	if self.phase == "gate-send" then -- 957
		local near = math.abs(p.x - g.doorX) <= 60 -- 960
		if near and input.interact.pressed then -- 960
			self:swapToChild(g.doorX + 30) -- 962
			self.phase = "gate-count" -- 963
			self.countTick = 0 -- 964
			self.countArmed = false -- 966
			self.countPrevMove = input.moveX -- 967
			self:flashSet("门开了 · 送她出去", 1.8) -- 968
		end -- 968
		return -- 970
	end -- 970
	if self.phase == "gate-count" then -- 970
		self.countTick = self.countTick + 1 -- 973
		if self.countTick == 360 then -- 973
			self:flashSet("门关上", 0.9) -- 975
		elseif self.countTick == 1020 then -- 975
			self:flashSet("数到一百", 2.2) -- 977
		end -- 977
		local prevMove = self.countPrevMove -- 981
		self.countPrevMove = input.moveX -- 982
		if self.countTick >= 1440 then -- 982
			if prevMove <= 0 and input.moveX > 0 then -- 982
				self.countArmed = true -- 985
			end -- 985
			if self.countArmed and input.moveX > 0 then -- 985
				self.phase = "gate-walk" -- 988
				self.phaseTick = 0 -- 989
				self:flashSet("她迈出第一步", 1.4) -- 990
			end -- 990
		end -- 990
		return -- 993
	end -- 993
	if self.player.x >= g.exitX then -- 993
		self:requestRoom("outside", "走出城门") -- 997
		self:flashSet("出城门 · 城外", 1.4) -- 998
	end -- 998
end -- 880
function Play.prototype.stepTower(self, dt, input) -- 1003
	local ____temp_10 -- 1004
	if self.room.story == nil then -- 1004
		____temp_10 = nil -- 1004
	else -- 1004
		____temp_10 = self.room.story.tower -- 1004
	end -- 1004
	local t = ____temp_10 -- 1004
	if t == nil then -- 1004
		return -- 1006
	end -- 1006
	if self.phase == "tower-wait" then -- 1006
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1009
		if near and input.interact.pressed then -- 1009
			self.phase = "tower-knock" -- 1011
			self.phaseTick = 0 -- 1012
			self.knocks = 1 -- 1013
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1014
			self:flashSet("敲一下", 0.6) -- 1015
		end -- 1015
		return -- 1017
	end -- 1017
	if self.phase == "tower-knock" then -- 1017
		self.phaseTick = self.phaseTick + 1 -- 1020
		if self.phaseTick == 12 then -- 1020
			self.knocks = 2 -- 1022
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1023
			self:flashSet("敲两下 · 第二声", 1) -- 1024
		elseif self.phaseTick >= t.knockTicks then -- 1024
			self.phase = "tower-given" -- 1026
			self.phaseTick = 0 -- 1027
			self:flashSet("门开了 · 提灯", 1.4) -- 1028
		end -- 1028
		return -- 1030
	end -- 1030
	if self.phase == "tower-given" then -- 1030
		self.phaseTick = self.phaseTick + 1 -- 1033
		if self.phaseTick == 60 then -- 1033
			self:flashSet("她递出针套和纸条", 1.6) -- 1035
		elseif self.phaseTick == 120 then -- 1035
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1037
		elseif self.phaseTick >= 180 then -- 1037
			self.phase = "tower-end" -- 1039
			self.phaseTick = 0 -- 1040
			self:flashSet("片尾 · E 再玩一次", 3) -- 1041
		end -- 1041
		return -- 1043
	end -- 1043
	if input.interact.pressed or input.retry.pressed then -- 1043
		self:requestRoom("prologue", "片尾再玩") -- 1046
		self:flashSet("回到序章", 1.4) -- 1047
	end -- 1047
end -- 1003
function Play.prototype.stepChase(self, dt, input) -- 1052
	if self.caughtT > 0 then -- 1052
		self.caughtT = self.caughtT - dt -- 1054
		if self.caughtT <= 0 then -- 1054
			self:recoverFromCaught() -- 1056
		end -- 1056
		return -- 1058
	end -- 1058
	if self.room.key == "village" then -- 1058
		self:stepScavChase() -- 1061
	elseif self.room.key == "forest" then -- 1061
		self:stepDog(dt) -- 1063
		if self.player.x >= self.ox + 1450 then -- 1063
			self:requestRoom("tower", "到林缘北塔") -- 1066
			self:flashSet("林缘 · 北塔", 1.4) -- 1067
		end -- 1067
	end -- 1067
end -- 1052
function Play.prototype.stepScavChase(self) -- 1073
	local s = self.room.scavenger -- 1074
	if s == nil then -- 1074
		return -- 1076
	end -- 1076
	local p = self.player -- 1078
	if self.passed and p.x > self.ox + 440 then -- 1078
		if self.scavChase then -- 1078
			self.scavChase = false -- 1082
			self.scavState = "back" -- 1083
			self.scavT = 0 -- 1084
		end -- 1084
		return -- 1086
	end -- 1086
	local dx = p.x - self.scavX -- 1088
	local dist = math.abs(dx) -- 1089
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1090
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1091
	if not self.scavChase then -- 1091
		if visible then -- 1091
			self.scavSee = self.scavSee + 1 -- 1094
			if self.scavSee >= 24 then -- 1094
				self.scavChase = true -- 1096
				self.scavState = "chase" -- 1097
				self.scavTargetX = p.x -- 1098
				self:flashSet("他看见你了", 1.2) -- 1099
			end -- 1099
		else -- 1099
			self.scavSee = 0 -- 1102
		end -- 1102
		return -- 1104
	end -- 1104
	local dir = p.x > self.scavX and 1 or -1 -- 1107
	self.scavX = self.scavX + dir * 96 / 60 -- 1108
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1108
		self:caught() -- 1110
		return -- 1111
	end -- 1111
	if hidden then -- 1111
		self.scavSee = 0 -- 1115
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1116
		self.scavT = self.scavT - 1 -- 1117
		if self.scavT <= 0 then -- 1117
			self.scavChase = false -- 1119
			self.scavState = "patrol" -- 1120
			self:flashSet("他失去了目标", 1) -- 1121
		end -- 1121
	end -- 1121
end -- 1073
function Play.prototype.stepDog(self, dt) -- 1127
	local ____temp_11 -- 1128
	if self.room.story == nil then -- 1128
		____temp_11 = nil -- 1128
	else -- 1128
		____temp_11 = self.room.story.dog -- 1128
	end -- 1128
	local dog = ____temp_11 -- 1128
	if dog == nil then -- 1128
		return -- 1130
	end -- 1130
	local p = self.player -- 1132
	local dist = math.abs(p.x - self.dogX) -- 1133
	if self.dogState == "patrol" then -- 1133
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1135
		if self.dogX < dog.x0 then -- 1135
			self.dogX = dog.x0 -- 1137
			self.dogDir = 1 -- 1138
		elseif self.dogX > dog.x1 then -- 1138
			self.dogX = dog.x1 -- 1140
			self.dogDir = -1 -- 1141
		end -- 1141
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1143
		if not p.crouch and moving and dist < dog.range then -- 1143
			self.dogState = "ear" -- 1145
			self.dogT = 18 -- 1146
			self.dogTargetX = p.x -- 1147
			self:flashSet("狗转耳朵", 0.8) -- 1148
		end -- 1148
		return -- 1150
	end -- 1150
	if self.dogState == "ear" then -- 1150
		self.dogT = self.dogT - 1 -- 1153
		if self.dogT <= 0 then -- 1153
			self.dogState = "chase" -- 1155
			self.dogTargetX = p.x -- 1156
			self:flashSet("狗追来了", 1.4) -- 1157
		end -- 1157
		return -- 1159
	end -- 1159
	if self.dogState == "chase" then -- 1159
		local dir = p.x > self.dogX and 1 or -1 -- 1162
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1163
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1163
			self:caught() -- 1165
			self.dogState = "sniff" -- 1166
			self.dogT = 60 -- 1167
		elseif dist > dog.range * 1.5 or p.crouch then -- 1167
			self.dogState = "sniff" -- 1169
			self.dogT = 60 -- 1170
			self:flashSet("狗停下了", 0.9) -- 1171
		end -- 1171
		return -- 1173
	end -- 1173
	if self.dogState == "sniff" then -- 1173
		self.dogT = self.dogT - 1 -- 1176
		if self.dogT <= 0 then -- 1176
			self.dogState = "back" -- 1178
		end -- 1178
		return -- 1180
	end -- 1180
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1183
	self.dogX = self.dogX + dir * dog.speed * dt -- 1184
	if math.abs(self.dogX - dog.x0) < 2 then -- 1184
		self.dogX = dog.x0 -- 1186
		self.dogState = "patrol" -- 1187
	end -- 1187
end -- 1127
function Play.prototype.caught(self) -- 1191
	self.caughtT = 1 -- 1192
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1193
end -- 1191
function Play.prototype.recoverFromCaught(self) -- 1197
	local p = self.player -- 1198
	p.x = self.ox + 140 -- 1199
	p.y = 0 -- 1200
	p.vy = 0 -- 1201
	p.vx = 0 -- 1202
	p.onGround = true -- 1203
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1203
		self.scavX = self.room.scavenger.x0 -- 1205
		self.scavState = "patrol" -- 1206
		self.scavSee = 0 -- 1207
		self.scavChase = false -- 1208
		self.scavT = 0 -- 1209
	end -- 1209
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1209
		self.dogX = self.room.story.dog.x0 -- 1212
		self.dogState = "patrol" -- 1213
		self.dogT = 0 -- 1214
	end -- 1214
	self.cam.x = p.x -- 1216
	self.cam.y = p.y + CAM_LOOK_UP -- 1217
	self:flashSet("回到安全点", 1.2) -- 1218
end -- 1197
function Play.prototype.updateGate(self) -- 1222
	if self.room.key ~= "checkpoint" then -- 1222
		self.gateOpen = false -- 1224
		return -- 1225
	end -- 1225
	local function inZone(x) -- 1227
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1227
	end -- 1227
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1228
end -- 1222
function Play.prototype.stepEnemies(self, dt, input) -- 1231
	local i = 0 -- 1232
	do -- 1232
		i = 0 -- 1233
		while i < #self.enemies do -- 1233
			local e = self.enemies[i + 1] -- 1234
			if e.hitT > 0 then -- 1234
				e.hitT = e.hitT - dt -- 1236
			end -- 1236
			i = i + 1 -- 1233
		end -- 1233
	end -- 1233
	if self.coveredFlash > 0 then -- 1233
		self.coveredFlash = self.coveredFlash - dt -- 1240
	end -- 1240
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1240
		return -- 1244
	end -- 1244
	do -- 1244
		i = 0 -- 1246
		while i < #self.enemies do -- 1246
			do -- 1246
				local e = self.enemies[i + 1] -- 1247
				if not e.alive then -- 1247
					goto __continue196 -- 1249
				end -- 1249
				if e.warnT > 0 then -- 1249
					e.warnT = e.warnT - 1 -- 1252
					if e.warnT <= 0 then -- 1252
						self:enemyFire(e, input) -- 1254
					end -- 1254
					goto __continue196 -- 1256
				end -- 1256
				if e.fireCd > 0 then -- 1256
					e.fireCd = e.fireCd - 1 -- 1259
					if e.fireCd <= 0 then -- 1259
						e.warnT = WARN_TICKS -- 1261
					end -- 1261
				else -- 1261
					e.warnT = WARN_TICKS -- 1265
				end -- 1265
			end -- 1265
			::__continue196:: -- 1265
			i = i + 1 -- 1246
		end -- 1246
	end -- 1246
end -- 1231
function Play.prototype.enemyFire(self, e, input) -- 1271
	local p = self.player -- 1272
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1272
		self:flashSet("枪声响在远处", 0.4) -- 1274
		e.fireCd = FIRE_COOLDOWN -- 1275
		return -- 1276
	end -- 1276
	local cover = self:blockedByCover(e.x, p) -- 1279
	local hugging = cover ~= nil -- 1280
	self.coverBlocking = hugging -- 1281
	local covered = hugging and input.cover.held -- 1282
	if covered then -- 1282
		self.coveredFlash = 0.5 -- 1284
		self:flashSet("掩体挡下", 0.5) -- 1285
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1286
		e.fireCd = FIRE_COOLDOWN -- 1291
		return -- 1292
	end -- 1292
	self.hp = self.hp - 1 -- 1294
	self:emit("actorHit", { -- 1295
		target = "player", -- 1295
		amount = 1, -- 1295
		hp = self.hp, -- 1295
		maxHp = self.maxHp, -- 1295
		enemyX = e.x -- 1295
	}) -- 1295
	self:flashSet( -- 1296
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1296
		0.7 -- 1296
	) -- 1296
	e.fireCd = FIRE_COOLDOWN -- 1297
	if self.hp <= 0 then -- 1297
		self:gateFailed() -- 1299
	end -- 1299
end -- 1271
function Play.prototype.blockedByCover(self, ex, p) -- 1304
	local b = self:coverAt(p) -- 1305
	if b == nil then -- 1305
		return nil -- 1307
	end -- 1307
	return self:coverGuardsFrom(b, p, ex) and b or nil -- 1309
end -- 1304
function Play.prototype.gateFailed(self) -- 1313
	local ____temp_12 -- 1314
	if self.room.story == nil then -- 1314
		____temp_12 = nil -- 1314
	else -- 1314
		____temp_12 = self.room.story.gate -- 1314
	end -- 1314
	local g = ____temp_12 -- 1314
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1315
	self.hp = self.maxHp -- 1316
	self.gateTick = 0 -- 1317
	self.gateSpawned = 0 -- 1318
	self.enemies = {} -- 1319
	self.gateFailCount = self.gateFailCount + 1 -- 1320
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1322
	self.player.y = 0 -- 1323
	self.player.vy = 0 -- 1324
	self.player.onGround = true -- 1325
	self.player.crouch = false -- 1326
	self.player.h = SOLDIER_H -- 1327
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1328
	self.partner.y = 0 -- 1329
	self.partner.vy = 0 -- 1330
	self.partner.onGround = true -- 1331
	self.cam.x = self.player.x -- 1332
	self.phase = "gate-idle" -- 1333
	self.phaseTick = 0 -- 1334
	self.coverHug = false -- 1335
	self.coverBlocking = false -- 1336
	self.coverEntity = "" -- 1337
	self.gateNeedConfirm = true -- 1338
	self.gateRestartArmed = false -- 1339
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1340
end -- 1313
function Play.prototype.stepInteract(self, dt, input) -- 1343
	local p = self.player -- 1344
	local calmUsed = self.calmConsumed -- 1345
	self.calmConsumed = false -- 1346
	self.focusCart = false -- 1347
	if self.room.key == "outside" then -- 1347
		local c = self.room.cart -- 1349
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1350
		local dy = p.y - c.baseY -- 1351
		self.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH -- 1352
	end -- 1352
	self:stepCart(dt, input) -- 1354
	if calmUsed then -- 1354
		self:flashSet("安抚 · 敲两下", 0.8) -- 1358
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1358
		if self.knockT > 0 then -- 1358
			self.knocks = self.knocks + 1 -- 1362
		else -- 1362
			self.knocks = 1 -- 1364
		end -- 1364
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1366
		self.knockT = 1.2 -- 1367
		if self.knocks >= 2 then -- 1367
			self:flashSet("敲两下", 0.8) -- 1369
			self.knocks = 0 -- 1370
		else -- 1370
			self:flashSet("敲一下", 0.5) -- 1372
		end -- 1372
	elseif self.knockT > 0 then -- 1372
		self.knockT = self.knockT - dt -- 1375
		if self.knockT <= 0 then -- 1375
			self.knocks = 0 -- 1377
		end -- 1377
	end -- 1377
	local i = 0 -- 1382
	do -- 1382
		i = 0 -- 1383
		while i < #self.room.marks do -- 1383
			do -- 1383
				local m = self.room.marks[i + 1] -- 1384
				if m.kind ~= 0 then -- 1384
					goto __continue221 -- 1386
				end -- 1386
				local subjects = {self.partner, self.player} -- 1388
				local k = 0 -- 1389
				do -- 1389
					k = 0 -- 1390
					while k < #subjects do -- 1390
						do -- 1390
							local s = subjects[k + 1] -- 1391
							if not s.alive then -- 1391
								goto __continue224 -- 1393
							end -- 1393
							local dx = s.x - m.x -- 1395
							local dy = s.y - m.y -- 1396
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1396
								self.checkpoint = m.x -- 1398
								self.checkpointCartAxle = self.cartAxle -- 1399
								if self.cartDocked then -- 1399
									self:flashSet("检查点 · 车已落窝", 1) -- 1401
								else -- 1401
									self:flashSet("检查点 · 车还没到位", 1) -- 1403
								end -- 1403
							end -- 1403
						end -- 1403
						::__continue224:: -- 1403
						k = k + 1 -- 1390
					end -- 1390
				end -- 1390
			end -- 1390
			::__continue221:: -- 1390
			i = i + 1 -- 1383
		end -- 1383
	end -- 1383
	self:checkCarryGate() -- 1409
end -- 1343
function Play.prototype.stepVillage(self, dt, input) -- 1413
	if self.room.key ~= "village" then -- 1413
		return -- 1415
	end -- 1415
	local p = self.player -- 1417
	local bottle = self.room.bottle -- 1418
	local scav = self.room.scavenger -- 1419
	if not self.hasBottle and bottle ~= nil then -- 1419
		local dx = p.x - bottle.x -- 1423
		local dy = p.y + p.h * 0.5 - bottle.y -- 1424
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1424
			self.hasBottle = true -- 1426
			self:flashSet("拾起瓶子", 0.8) -- 1427
		end -- 1427
	end -- 1427
	if self.hasBottle then -- 1427
		if input.aim.held then -- 1427
			self.aimHold = self.aimHold + dt -- 1434
			if self.aimHold > 1.2 then -- 1434
				self.aimHold = 1.2 -- 1436
			end -- 1436
			local cached = self:bottleEnd() -- 1439
			self.bottleAimX = cached.x -- 1440
			self.bottleAimY = cached.y -- 1441
		elseif input.aim.released then -- 1441
			if self.aimHold < 0.12 then -- 1441
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1445
				self.aimHold = 0 -- 1446
			else -- 1446
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1448
				self:throwBottle(____end.x, ____end.y) -- 1449
				self.aimHold = 0 -- 1450
			end -- 1450
		end -- 1450
	else -- 1450
		self.aimHold = 0 -- 1454
		self.bottleAimX = -1 -- 1455
	end -- 1455
	local fly = self.bottleFly -- 1460
	if fly ~= nil then -- 1460
		fly.t = fly.t + dt -- 1462
		fly.x = fly.x0 + fly.vx * fly.t -- 1463
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1464
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1465
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1465
			self:landBottle(fly) -- 1467
		end -- 1467
	end -- 1467
	if self.bottleLandT > 0 then -- 1467
		self.bottleLandT = self.bottleLandT - dt -- 1471
	end -- 1471
	if scav ~= nil then -- 1471
		self:stepScav(dt, scav) -- 1475
	end -- 1475
	local line = self.room.passLine -- 1478
	if line ~= nil and not self.passed and p.x >= line then -- 1478
		self.passed = true -- 1480
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1481
	end -- 1481
	if self.passed and p.x >= self.ox + 640 then -- 1481
		self:requestRoom("forest", "过第一院出院") -- 1485
		self:flashSet("出院 · 北塔森林", 1.4) -- 1486
	end -- 1486
end -- 1413
function Play.prototype.bottleEnd(self) -- 1491
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1492
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1493
	return {x = aim.x, y = g} -- 1494
end -- 1491
function Play.prototype.throwBottle(self, tx, ty) -- 1498
	local p = self.player -- 1499
	local dir = tx >= p.x and 1 or -1 -- 1501
	p.facing = dir -- 1502
	local x0 = p.x + dir * 10 -- 1503
	local y0 = p.y + p.h * 0.7 -- 1504
	self.bottleTargetX = tx -- 1505
	self.bottleTargetY = ty -- 1506
	self.bottleSurfaceY = ty -- 1507
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1508
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1509
	self.bottleFly = { -- 1510
		x = x0, -- 1510
		y = y0, -- 1510
		x0 = x0, -- 1510
		y0 = y0, -- 1510
		vx = vx, -- 1510
		vy = vy, -- 1510
		t = 0 -- 1510
	} -- 1510
	self.hasBottle = false -- 1511
	self:flashSet("投出", 0.4) -- 1512
	self:emit( -- 1513
		"bottleThrown", -- 1513
		{ -- 1513
			fromX = x0, -- 1514
			fromY = y0, -- 1515
			targetX = tx, -- 1516
			targetY = ty, -- 1517
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1518
		} -- 1518
	) -- 1518
end -- 1498
function Play.prototype.landBottle(self, fly) -- 1523
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1524
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1525
	local s = self.room.scavenger -- 1526
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1527
	self.bottleFly = nil -- 1528
	self.bottleTargetX = -1 -- 1529
	self.bottleTargetY = 0 -- 1530
	self.bottleSurfaceY = -1 -- 1531
	self.bottleLandX = x -- 1532
	self.bottleLandY = y -- 1533
	self.bottleLandT = 0.9 -- 1534
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1535
	self:hearBottle(x) -- 1536
end -- 1523
function Play.prototype.hearBottle(self, x) -- 1540
	local s = self.room.scavenger -- 1541
	if s == nil then -- 1541
		return -- 1543
	end -- 1543
	if math.abs(x - self.scavX) > s.range then -- 1543
		self:flashSet("落地 · 他没听见", 0.6) -- 1546
		return -- 1547
	end -- 1547
	self.scavState = "turn" -- 1549
	self.scavT = s.hearTicks -- 1550
	self.scavTargetX = x -- 1551
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1552
end -- 1540
function Play.prototype.stepScav(self, dt, s) -- 1556
	if self.scavState == "chase" then -- 1556
		return -- 1559
	end -- 1559
	if self.scavState == "turn" then -- 1559
		self.scavT = self.scavT - 1 -- 1562
		if self.scavT <= 0 then -- 1562
			self.scavState = "walk" -- 1564
		end -- 1564
		return -- 1566
	end -- 1566
	if self.scavState == "walk" then -- 1566
		local d = self.scavTargetX - self.scavX -- 1569
		if math.abs(d) < 4 then -- 1569
			self.scavState = "stall" -- 1571
			self.scavT = s.stallTicks -- 1572
			return -- 1573
		end -- 1573
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1575
		return -- 1576
	end -- 1576
	if self.scavState == "stall" then -- 1576
		self.scavT = self.scavT - 1 -- 1579
		if self.scavT <= 0 then -- 1579
			self.scavState = "back" -- 1581
		end -- 1581
		return -- 1583
	end -- 1583
	if self.scavState == "back" then -- 1583
		local home = math.max( -- 1586
			s.x0, -- 1586
			math.min(s.x1, self.scavX) -- 1586
		) -- 1586
		if math.abs(home - self.scavX) < 2 then -- 1586
			self.scavState = "patrol" -- 1588
			return -- 1589
		end -- 1589
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1591
		return -- 1592
	end -- 1592
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1594
	if self.scavX >= s.x1 then -- 1594
		self.scavX = s.x1 -- 1596
		self.scavDir = -1 -- 1597
	elseif self.scavX <= s.x0 then -- 1597
		self.scavX = s.x0 -- 1599
		self.scavDir = 1 -- 1600
	end -- 1600
end -- 1556
function Play.prototype.stepCart(self, dt, input) -- 1608
	local p = self.player -- 1609
	local c = self.room.cart -- 1610
	local handleX = self.cartAxle + c.handleOffset -- 1611
	if self.gripping then -- 1611
		if not input.interact.held then -- 1611
			self.gripping = false -- 1615
			self:flashSet("松开车把", 0.4) -- 1616
			return -- 1617
		end -- 1617
	else -- 1617
		if not input.interact.pressed then -- 1617
			return -- 1621
		end -- 1621
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1621
			return -- 1624
		end -- 1624
		self.gripping = true -- 1626
		self:flashSet("握住车把", 0.4) -- 1627
		return -- 1628
	end -- 1628
	if self.cartDocked then -- 1628
		return -- 1632
	end -- 1632
	local dir = input.moveX -- 1634
	if dir == 0 then -- 1634
		return -- 1636
	end -- 1636
	local lo = math.min(c.startX, c.endX) -- 1638
	local hi = math.max(c.startX, c.endX) -- 1639
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1640
	if next < lo then -- 1640
		next = lo -- 1642
	end -- 1642
	if next > hi then -- 1642
		next = hi -- 1645
	end -- 1645
	local delta = next - self.cartAxle -- 1647
	if delta == 0 then -- 1647
		return -- 1649
	end -- 1649
	self.cartAxle = next -- 1651
	p.x = p.x + delta -- 1652
	p.facing = dir > 0 and 1 or -1 -- 1653
	self:slideX(p, 0) -- 1654
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1654
		self.gripping = false -- 1656
		self:flashSet("跟不上了，脱手", 0.6) -- 1657
		return -- 1658
	end -- 1658
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1658
		self.cartDocked = true -- 1661
		self.gripping = false -- 1662
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1663
		self:flashSet("车轮落窝", 1.2) -- 1664
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1664
		self:flashSet("车轮回到起点", 0.5) -- 1666
	end -- 1666
end -- 1608
function Play.prototype.requestRoom(self, key, reason) -- 1674
	if self.wantRoom ~= "" then -- 1674
		return -- 1678
	end -- 1678
	self.wantRoom = key -- 1680
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1681
end -- 1674
function Play.prototype.checkCarryGate(self) -- 1688
	if self.room.key == "checkpoint" then -- 1688
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1688
			self.carryCartAxle = self.cartAxle -- 1691
			self.carryCartDocked = self.cartDocked -- 1692
			self:requestRoom("gate", "检查站出口") -- 1693
			self:flashSet("出检查站 · 城门", 1.2) -- 1694
		end -- 1694
		return -- 1696
	end -- 1696
	if self.room.key == "outside" then -- 1696
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1696
			self.carryCartAxle = self.cartAxle -- 1702
			self.carryCartDocked = self.cartDocked -- 1703
			self:requestRoom("village", "墙根走完") -- 1704
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1705
		end -- 1705
	end -- 1705
end -- 1688
function Play.prototype.aimAt(self, wx, wy) -- 1712
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1713
	self.aimX = s.x -- 1714
	self.aimY = s.y -- 1715
end -- 1712
function Play.prototype.shoot(self, a) -- 1718
	local ox = a.x + a.facing * 8 -- 1719
	local oy = a.y + a.h * 0.72 -- 1720
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1722
	local dx = aim.x - ox -- 1723
	local dy = aim.y - oy -- 1724
	local len = math.sqrt(dx * dx + dy * dy) -- 1725
	if len < 0.001 then -- 1725
		dx = a.facing -- 1727
		dy = 0 -- 1728
	else -- 1728
		dx = dx / len -- 1730
		dy = dy / len -- 1731
	end -- 1731
	if dx ~= 0 then -- 1731
		a.facing = dx > 0 and 1 or -1 -- 1734
	end -- 1734
	local hitEnemy = self:raycast( -- 1737
		ox, -- 1737
		oy, -- 1737
		dx, -- 1737
		dy, -- 1737
		true -- 1737
	) -- 1737
	local hitWall = self:raycast( -- 1738
		ox, -- 1738
		oy, -- 1738
		dx, -- 1738
		dy, -- 1738
		false -- 1738
	) -- 1738
	local tEnemy = hitEnemy.t -- 1739
	local tWall = hitWall.t -- 1740
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1741
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1742
	self.trace = { -- 1744
		x0 = ox, -- 1744
		y0 = oy, -- 1744
		x1 = ox + dx * t, -- 1744
		y1 = oy + dy * t, -- 1744
		hit = hit -- 1744
	} -- 1744
	self.traceT = 0.12 -- 1745
	self:applyFireDanger(ox) -- 1746
	if hit then -- 1746
		local i = hitEnemy.index -- 1748
		local e = self.enemies[i + 1] -- 1749
		e.alive = false -- 1750
		e.hitT = 0.4 -- 1751
		self:flashSet("命中", 0.6) -- 1752
	else -- 1752
		self:flashSet("打空", 0.35) -- 1754
	end -- 1754
	self:emit("shotResolved", { -- 1756
		hit = hit, -- 1757
		enemyIndex = hit and hitEnemy.index or -1, -- 1758
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1759
		aimX = aim.x, -- 1760
		aimY = aim.y, -- 1761
		impactX = ox + dx * t, -- 1762
		impactY = oy + dy * t -- 1763
	}) -- 1763
end -- 1718
function Play.prototype.applyFireDanger(self, shotX) -- 1768
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1768
		return -- 1770
	end -- 1770
	local dangerX = shotX -- 1772
	local best = -1 -- 1773
	local bestD = 1000000000 -- 1774
	local i = 0 -- 1775
	do -- 1775
		i = 0 -- 1776
		while i < #self.enemies do -- 1776
			do -- 1776
				local e = self.enemies[i + 1] -- 1777
				if not e.alive then -- 1777
					goto __continue295 -- 1779
				end -- 1779
				local d = math.abs(e.x - self.partner.x) -- 1781
				if d < bestD then -- 1781
					bestD = d -- 1783
					best = i -- 1784
				end -- 1784
			end -- 1784
			::__continue295:: -- 1784
			i = i + 1 -- 1776
		end -- 1776
	end -- 1776
	if best >= 0 then -- 1776
		dangerX = self.enemies[best + 1].x -- 1788
	end -- 1788
	local exposed = self:childExposed(dangerX) -- 1790
	local before = self.escort.fear -- 1791
	local dangerId = self.nextDangerId -- 1792
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1793
	self.nextDangerId = self.nextDangerId + 1 -- 1794
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1795
	if after > before then -- 1795
		self:flashSet( -- 1797
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1797
			1 -- 1797
		) -- 1797
	elseif not exposed then -- 1797
		self:flashSet("枪声没够到她", 0.5) -- 1799
	end -- 1799
end -- 1768
function Play.prototype.childExposed(self, dangerX) -- 1804
	local c = self.partner -- 1805
	if not c.alive then -- 1805
		return false -- 1807
	end -- 1807
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1807
		return false -- 1810
	end -- 1810
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1810
		return false -- 1813
	end -- 1813
	local toDanger = dangerX - c.x -- 1815
	local toPlayer = self.player.x - c.x -- 1816
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1816
		return false -- 1818
	end -- 1818
	return true -- 1820
end -- 1804
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1824
	local best = -1 -- 1825
	local bestI = -1 -- 1826
	local i = 0 -- 1827
	if enemies then -- 1827
		do -- 1827
			i = 0 -- 1829
			while i < #self.enemies do -- 1829
				do -- 1829
					local e = self.enemies[i + 1] -- 1830
					if not e.alive then -- 1830
						goto __continue309 -- 1832
					end -- 1832
					local t = hitBox( -- 1834
						ox, -- 1834
						oy, -- 1834
						dx, -- 1834
						dy, -- 1834
						e.x - e.w / 2, -- 1834
						e.x + e.w / 2, -- 1834
						e.y, -- 1834
						e.y + e.h -- 1834
					) -- 1834
					if t >= 0 and (best < 0 or t < best) then -- 1834
						best = t -- 1836
						bestI = i -- 1837
					end -- 1837
				end -- 1837
				::__continue309:: -- 1837
				i = i + 1 -- 1829
			end -- 1829
		end -- 1829
		return {t = best, index = bestI} -- 1840
	end -- 1840
	do -- 1840
		i = 0 -- 1842
		while i < #self.boxes do -- 1842
			local b = self.boxes[i + 1] -- 1843
			local t = hitBox( -- 1844
				ox, -- 1844
				oy, -- 1844
				dx, -- 1844
				dy, -- 1844
				b.x0, -- 1844
				b.x1, -- 1844
				b.y0, -- 1844
				b.y1 -- 1844
			) -- 1844
			if t >= 0 and (best < 0 or t < best) then -- 1844
				best = t -- 1846
			end -- 1846
			i = i + 1 -- 1842
		end -- 1842
	end -- 1842
	if dy < 0 then -- 1842
		local t = (0 - oy) / dy -- 1851
		if t >= 0 and (best < 0 or t < best) then -- 1851
			best = t -- 1853
		end -- 1853
	end -- 1853
	return {t = best, index = -1} -- 1856
end -- 1824
function Play.prototype.slideX(self, a, dx) -- 1860
	local nx = a.x + dx -- 1861
	local half = a.w / 2 -- 1862
	local room = self.room -- 1863
	nx = math.max( -- 1864
		room.minX + half, -- 1864
		math.min(room.maxX - half, nx) -- 1864
	) -- 1864
	local i = 0 -- 1865
	do -- 1865
		i = 0 -- 1866
		while i < #self.boxes do -- 1866
			do -- 1866
				local b = self.boxes[i + 1] -- 1867
				if b.passable == true then -- 1867
					goto __continue319 -- 1869
				end -- 1869
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1869
					goto __continue319 -- 1872
				end -- 1872
				if nx + half > b.x0 and nx - half < b.x1 then -- 1872
					if a.x <= b.x0 then -- 1872
						nx = b.x0 - half -- 1876
					elseif a.x >= b.x1 then -- 1876
						nx = b.x1 + half -- 1878
					else -- 1878
						nx = a.x -- 1880
					end -- 1880
				end -- 1880
			end -- 1880
			::__continue319:: -- 1880
			i = i + 1 -- 1866
		end -- 1866
	end -- 1866
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1866
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1888
		local bx0 = self.cartAxle - CART_HALF -- 1889
		local bx1 = self.cartAxle + CART_HALF -- 1890
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1890
			if a.x <= bx0 then -- 1890
				nx = bx0 - half -- 1893
			elseif a.x >= bx1 then -- 1893
				nx = bx1 + half -- 1895
			else -- 1895
				nx = a.x -- 1897
			end -- 1897
		end -- 1897
	end -- 1897
	local arch = room.arch -- 1905
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1905
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1907
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1907
			if a.x <= arch.x0 then -- 1907
				nx = arch.x0 - half -- 1910
			elseif a.x >= arch.x1 then -- 1910
				nx = arch.x1 + half -- 1912
			end -- 1912
		end -- 1912
	end -- 1912
	a.x = nx -- 1916
end -- 1860
function Play.prototype.fallY(self, a, dt) -- 1920
	a.vy = a.vy - ____exports.GRAVITY * dt -- 1921
	if a.vy < -900 then -- 1921
		a.vy = -900 -- 1923
	end -- 1923
	local ny = a.y + a.vy * dt -- 1925
	local half = a.w / 2 -- 1926
	if a.vy <= 0 then -- 1926
		local reach = a.onGround and STEP_UP or 0 -- 1929
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1930
		if ny <= ground then -- 1930
			ny = ground -- 1932
			a.vy = 0 -- 1933
			a.onGround = true -- 1934
		else -- 1934
			a.onGround = false -- 1936
		end -- 1936
	else -- 1936
		a.onGround = false -- 1939
		local i = 0 -- 1940
		do -- 1940
			i = 0 -- 1941
			while i < #self.boxes do -- 1941
				do -- 1941
					local b = self.boxes[i + 1] -- 1942
					if b.passable == true then -- 1942
						goto __continue342 -- 1944
					end -- 1944
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1944
						goto __continue342 -- 1947
					end -- 1947
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1947
						ny = b.y0 - a.h -- 1950
						a.vy = 0 -- 1951
					end -- 1951
				end -- 1951
				::__continue342:: -- 1951
				i = i + 1 -- 1941
			end -- 1941
		end -- 1941
	end -- 1941
	a.y = ny -- 1955
end -- 1920
function Play.prototype.groundAt(self, x, ceiling, half) -- 1959
	local g = -9999 -- 1960
	local i = 0 -- 1961
	do -- 1961
		i = 0 -- 1962
		while i < #self.floors do -- 1962
			local f = self.floors[i + 1] -- 1963
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1963
				g = f.y1 -- 1965
			end -- 1965
			i = i + 1 -- 1962
		end -- 1962
	end -- 1962
	do -- 1962
		i = 0 -- 1968
		while i < #self.boxes do -- 1968
			local b = self.boxes[i + 1] -- 1969
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1969
				g = b.y1 -- 1971
			end -- 1971
			i = i + 1 -- 1968
		end -- 1968
	end -- 1968
	return g -- 1974
end -- 1959
function Play.prototype.updateCamera(self, dt) -- 1977
	local p = self.player -- 1978
	local tx = p.x + p.facing * 30 -- 1979
	local ty = p.y + CAM_LOOK_UP -- 1980
	local k = math.min(1, CAM_FOLLOW * dt) -- 1981
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 1982
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 1983
end -- 1977
function Play.prototype.clampCamera(self, w, h) -- 1987
	local room = self.room -- 1988
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 1989
	local spanX = room.maxX - room.minX -- 1990
	if spanX <= halfW * 2 then -- 1990
		self.cam.x = (room.minX + room.maxX) / 2 -- 1992
	else -- 1992
		self.cam.x = math.max( -- 1994
			room.minX + halfW, -- 1994
			math.min(room.maxX - halfW, self.cam.x) -- 1994
		) -- 1994
	end -- 1994
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 1997
	local spanY = room.height -- 1998
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 1999
	if spanY <= halfH * 2 then -- 1999
		self.cam.y = camY -- 2001
	else -- 2001
		self.cam.y = math.max( -- 2003
			camY, -- 2003
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2003
		) -- 2003
	end -- 2003
end -- 1987
function Play.prototype.flashSet(self, text, t) -- 2007
	self.flash = text -- 2008
	self.flashT = t -- 2009
end -- 2007
function Play.prototype.statusText(self) -- 2013
	local p = self.player -- 2014
	local parts = {} -- 2015
	local who = self.childMode and "小满" or "周戍" -- 2016
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2017
	if self.room.key == "prologue" then -- 2017
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2020
		if self.phase == "prologue-wait" then -- 2020
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2022
		elseif self.phase == "prologue-give" then -- 2022
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2024
		else -- 2024
			parts[#parts + 1] = "跟随" -- 2026
		end -- 2026
		if self.paused then -- 2026
			parts[#parts + 1] = "已暂停" -- 2029
		end -- 2029
		return table.concat(parts, " · ") -- 2031
	end -- 2031
	if self.room.key == "street" then -- 2031
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2034
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2035
		if self.paused then -- 2035
			parts[#parts + 1] = "已暂停" -- 2037
		end -- 2037
		return table.concat(parts, " · ") -- 2039
	end -- 2039
	if self.room.key == "gate" then -- 2039
		local ____temp_13 -- 2042
		if self.room.story == nil then -- 2042
			____temp_13 = nil -- 2042
		else -- 2042
			____temp_13 = self.room.story.gate -- 2042
		end -- 2042
		local g = ____temp_13 -- 2042
		if g ~= nil then -- 2042
			parts[#parts + 1] = self:gateLabel() -- 2044
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2045
				0, -- 2046
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2046
			))) .. " 秒" -- 2046
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2047
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2048
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2049
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2050
			if self.gateFailCount > 0 then -- 2050
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2052
			end -- 2052
			if self.flash ~= "" then -- 2052
				parts[#parts + 1] = self.flash -- 2055
			end -- 2055
		end -- 2055
		if self.paused then -- 2055
			parts[#parts + 1] = "已暂停" -- 2059
		end -- 2059
		return table.concat(parts, " · ") -- 2061
	end -- 2061
	if self.room.key == "forest" then -- 2061
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2064
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2065
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2066
		if self.caughtT > 0 then -- 2066
			parts[#parts + 1] = "复位中" -- 2068
		end -- 2068
		if self.paused then -- 2068
			parts[#parts + 1] = "已暂停" -- 2071
		end -- 2071
		return table.concat(parts, " · ") -- 2073
	end -- 2073
	if self.room.key == "tower" then -- 2073
		if self.phase == "tower-wait" then -- 2073
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2077
		elseif self.phase == "tower-knock" then -- 2077
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2079
		elseif self.phase == "tower-given" then -- 2079
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2081
		else -- 2081
			parts[#parts + 1] = "片尾" -- 2083
		end -- 2083
		if self.paused then -- 2083
			parts[#parts + 1] = "已暂停" -- 2086
		end -- 2086
		return table.concat(parts, " · ") -- 2088
	end -- 2088
	if self.room.key == "village" then -- 2088
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2091
		if self.hasBottle then -- 2091
			parts[#parts + 1] = "有瓶" -- 2093
		elseif self.bottleFly ~= nil then -- 2093
			parts[#parts + 1] = "瓶在飞" -- 2095
		else -- 2095
			parts[#parts + 1] = "空手" -- 2097
		end -- 2097
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2099
		if self.scavChase then -- 2099
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2101
		end -- 2101
		if self.passed then -- 2101
			parts[#parts + 1] = "已过通行线" -- 2104
		end -- 2104
		if self.paused then -- 2104
			parts[#parts + 1] = "已暂停" -- 2107
		end -- 2107
		return table.concat(parts, " · ") -- 2109
	end -- 2109
	local isChild = self.childMode -- 2112
	if isChild then -- 2112
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2114
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2115
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2116
	else -- 2116
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2118
		if p.rollT > 0 then -- 2118
			parts[#parts + 1] = "翻滚中" -- 2120
		end -- 2120
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2122
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2123
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2124
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2125
	end -- 2125
	if self.checkpoint >= 0 then -- 2125
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2128
	end -- 2128
	if self.paused then -- 2128
		parts[#parts + 1] = "已暂停" -- 2131
	end -- 2131
	return table.concat(parts, " · ") -- 2133
end -- 2013
function Play.prototype.aliveEnemies(self) -- 2137
	local n = 0 -- 2138
	local i = 0 -- 2139
	do -- 2139
		i = 0 -- 2140
		while i < #self.enemies do -- 2140
			if self.enemies[i + 1].alive then -- 2140
				n = n + 1 -- 2142
			end -- 2142
			i = i + 1 -- 2140
		end -- 2140
	end -- 2140
	return n -- 2145
end -- 2137
function Play.prototype.threatened(self) -- 2150
	do -- 2150
		local i = 0 -- 2151
		while i < #self.enemies do -- 2151
			local e = self.enemies[i + 1] -- 2152
			if e.alive and e.warnT > 0 then -- 2152
				return true -- 2154
			end -- 2154
			i = i + 1 -- 2151
		end -- 2151
	end -- 2151
	return false -- 2157
end -- 2150
function Play.prototype.gateSecondsLeft(self) -- 2160
	local ____temp_14 -- 2161
	if self.room.story == nil then -- 2161
		____temp_14 = nil -- 2161
	else -- 2161
		____temp_14 = self.room.story.gate -- 2161
	end -- 2161
	local g = ____temp_14 -- 2161
	if g == nil then -- 2161
		return 0 -- 2163
	end -- 2163
	return math.max( -- 2165
		0, -- 2165
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2165
	) -- 2165
end -- 2160
function Play.prototype.gateLabel(self) -- 2168
	if self.phase == "gate-idle" then -- 2168
		return "待就位" -- 2170
	end -- 2170
	if self.phase == "gate-hold" then -- 2170
		return "守点中" -- 2173
	end -- 2173
	if self.phase == "gate-send" then -- 2173
		return "送别" -- 2176
	end -- 2176
	if self.phase == "gate-count" then -- 2176
		return "数数 " .. tostring(self.countTick) -- 2179
	end -- 2179
	return "她走" -- 2181
end -- 2168
function Play.prototype.dogLabel(self) -- 2185
	if self.dogState == "ear" then -- 2185
		return "转耳" -- 2187
	end -- 2187
	if self.dogState == "chase" then -- 2187
		return "追" -- 2190
	end -- 2190
	if self.dogState == "sniff" then -- 2190
		return "停" -- 2193
	end -- 2193
	if self.dogState == "back" then -- 2193
		return "回线" -- 2196
	end -- 2196
	return "巡逻" -- 2198
end -- 2185
function Play.prototype.doorXOf(self) -- 2201
	local ____temp_15 -- 2202
	if self.room.story == nil then -- 2202
		____temp_15 = nil -- 2202
	else -- 2202
		____temp_15 = self.room.story.tower -- 2202
	end -- 2202
	local t = ____temp_15 -- 2202
	return t == nil and 0 or t.doorX -- 2203
end -- 2201
function Play.prototype.scavLabel(self) -- 2207
	if self.scavState == "chase" then -- 2207
		return "追" -- 2209
	end -- 2209
	if self.scavState == "turn" then -- 2209
		return "转头" -- 2212
	end -- 2212
	if self.scavState == "walk" then -- 2212
		return "赶来" -- 2215
	end -- 2215
	if self.scavState == "stall" then -- 2215
		return "停住" -- 2218
	end -- 2218
	if self.scavState == "back" then -- 2218
		return "回位" -- 2221
	end -- 2221
	return "巡逻" -- 2223
end -- 2207
function Play.prototype.hintText(self) -- 2227
	if self.paused then -- 2227
		return "Esc 继续 · R 重置" -- 2229
	end -- 2229
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2229
		if self:threatened() then -- 2229
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2235
		end -- 2235
		if self.coverHug then -- 2235
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2238
		end -- 2238
		if self.coverNear then -- 2238
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2241
		end -- 2241
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2243
	end -- 2243
	if self.flash ~= "" then -- 2243
		return self.flash -- 2246
	end -- 2246
	if self.room.key == "prologue" then -- 2246
		if self.phase == "prologue-wait" then -- 2246
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2250
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2251
		end -- 2251
		if self.phase == "prologue-give" then -- 2251
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2254
		end -- 2254
		return "她跟着你了 · 两人一起走到门口 680" -- 2256
	end -- 2256
	if self.room.key == "street" then -- 2256
		if self:aliveEnemies() > 0 then -- 2256
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2260
		end -- 2260
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2262
	end -- 2262
	if self.room.key == "gate" then -- 2262
		local ____temp_16 -- 2265
		if self.room.story == nil then -- 2265
			____temp_16 = nil -- 2265
		else -- 2265
			____temp_16 = self.room.story.gate -- 2265
		end -- 2265
		local g = ____temp_16 -- 2265
		if g ~= nil then -- 2265
			if self.phase == "gate-idle" then -- 2265
				if self.gateNeedConfirm then -- 2265
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2269
				end -- 2269
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2271
			end -- 2271
			if self.phase == "gate-hold" then -- 2271
				if self.coveredFlash > 0 then -- 2271
					return "掩体挡下了这一枪 · 别露头" -- 2275
				end -- 2275
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2277
			end -- 2277
			if self.phase == "gate-send" then -- 2277
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2280
			end -- 2280
			if self.phase == "gate-count" then -- 2280
				if self.countTick >= 1440 then -- 2280
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2284
				end -- 2284
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2286
			end -- 2286
			return "她自己走 · 跟着出城门 1120" -- 2288
		end -- 2288
	end -- 2288
	if self.room.key == "forest" then -- 2288
		if self.dogState == "chase" then -- 2288
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2293
		end -- 2293
		if self.dogState == "ear" then -- 2293
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2296
		end -- 2296
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2298
	end -- 2298
	if self.room.key == "tower" then -- 2298
		if self.phase == "tower-wait" then -- 2298
			return "走到门前 445 点一次 E 敲两下" -- 2302
		end -- 2302
		if self.phase == "tower-knock" then -- 2302
			return "敲两下 · 等门开" -- 2305
		end -- 2305
		if self.phase == "tower-given" then -- 2305
			return "递交针套和纸条 · 看登记簿最后一行" -- 2308
		end -- 2308
		return "片尾 · 点 E 再玩一次，回到序章" -- 2310
	end -- 2310
	if self.room.key == "village" then -- 2310
		if self.bottleFly ~= nil then -- 2310
			return "等瓶子落地 · 触地才发声" -- 2314
		end -- 2314
		if self.hasBottle then -- 2314
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2317
		end -- 2317
		if self.passed then -- 2317
			return "已过第一院 · R 重置可再来一遍" -- 2320
		end -- 2320
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2322
	end -- 2322
	if self.room.key == "outside" then -- 2322
		if self.focusCart then -- 2322
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2326
		end -- 2326
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2328
	end -- 2328
	if self.escort.state == "frozen" then -- 2328
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2328
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2332
		end -- 2332
		return "小满吓住了 · 走过去，靠近再点 E" -- 2334
	end -- 2334
	if self.escort.state == "calming" then -- 2334
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2337
	end -- 2337
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2339
end -- 2227
function Play.prototype.draw(self, draw, w, h) -- 2344
	self.viewW = w -- 2345
	self.viewH = h -- 2346
	self.view = ____exports.computeViewport(w, h) -- 2347
	self:clampCamera(w, h) -- 2348
	draw:clear() -- 2349
	draw:drawRect( -- 2351
		Rect(0, 0, w, h), -- 2351
		BG_VOID -- 2351
	) -- 2351
	local box = self:canvasRect(w, h) -- 2352
	draw:drawRect(box, BG_FAR) -- 2353
	draw:drawRect( -- 2354
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2354
		BG_MID -- 2354
	) -- 2354
	self:drawFloors(draw, w, h) -- 2356
	self:drawSolids(draw, w, h) -- 2357
	self:drawZones(draw, w, h) -- 2358
	self:drawArch(draw, w, h) -- 2359
	self:drawCart(draw, w, h) -- 2360
	self:drawActors(draw, w, h) -- 2361
	self:drawTrace(draw, w, h) -- 2362
	self:drawAim(draw, w, h) -- 2363
end -- 2344
function Play.prototype.canvasRect(self, w, h) -- 2367
	local v = self.view -- 2368
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2369
end -- 2367
function Play.prototype.px(self, n) -- 2373
	return n * self.view.zoom -- 2374
end -- 2373
function Play.prototype.sx(self, wx, w) -- 2378
	local v = self.view -- 2379
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2380
	return v.ox + lx * v.zoom -- 2381
end -- 2378
function Play.prototype.sy(self, wy, h) -- 2385
	local v = self.view -- 2386
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2387
	return v.oy + ly * v.zoom -- 2388
end -- 2385
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2391
	local px0 = self:sx(x0, w) -- 2392
	local px1 = self:sx(x1, w) -- 2393
	local py0 = self:sy(y0, h) -- 2394
	local py1 = self:sy(y1, h) -- 2395
	if px1 <= px0 or py1 <= py0 then -- 2395
		return -- 2397
	end -- 2397
	draw:drawRect( -- 2399
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2399
		color -- 2399
	) -- 2399
end -- 2391
function Play.prototype.drawFloors(self, draw, w, h) -- 2402
	local i = 0 -- 2403
	do -- 2403
		i = 0 -- 2404
		while i < #self.room.floors do -- 2404
			local f = self.room.floors[i + 1] -- 2405
			local y = self:sy(f.y, h) -- 2406
			local x0 = self:sx(f.x0, w) -- 2407
			local x1 = self:sx(f.x1, w) -- 2408
			local deck = self:px(5) -- 2409
			draw:drawRect( -- 2410
				Rect(x0, y - deck, x1 - x0, deck), -- 2410
				FLOOR_DECK -- 2410
			) -- 2410
			draw:drawSegment( -- 2411
				Vec2(x0, y), -- 2411
				Vec2(x1, y), -- 2411
				self:px(1), -- 2411
				GROUND -- 2411
			) -- 2411
			i = i + 1 -- 2404
		end -- 2404
	end -- 2404
end -- 2402
function Play.prototype.drawSolids(self, draw, w, h) -- 2415
	local i = 0 -- 2416
	do -- 2416
		i = 0 -- 2417
		while i < #self.boxes do -- 2417
			do -- 2417
				local b = self.boxes[i + 1] -- 2418
				if b.y0 < -4 and b.y1 <= 96 then -- 2418
					draw:drawSegment( -- 2421
						Vec2( -- 2421
							self:sx(b.x0, w), -- 2421
							self:sy(b.y1, h) -- 2421
						), -- 2421
						Vec2( -- 2421
							self:sx(b.x1, w), -- 2421
							self:sy(b.y1, h) -- 2421
						), -- 2421
						self:px(1), -- 2421
						GROUND -- 2421
					) -- 2421
					goto __continue470 -- 2422
				end -- 2422
				self:drawBox( -- 2424
					draw, -- 2424
					w, -- 2424
					h, -- 2424
					b.x0, -- 2424
					b.x1, -- 2424
					b.y0, -- 2424
					b.y1, -- 2424
					SOLID_FILL -- 2424
				) -- 2424
				draw:drawSegment( -- 2425
					Vec2( -- 2425
						self:sx(b.x0, w), -- 2425
						self:sy(b.y1, h) -- 2425
					), -- 2425
					Vec2( -- 2425
						self:sx(b.x1, w), -- 2425
						self:sy(b.y1, h) -- 2425
					), -- 2425
					self:px(1), -- 2425
					SOLID_EDGE -- 2425
				) -- 2425
			end -- 2425
			::__continue470:: -- 2425
			i = i + 1 -- 2417
		end -- 2417
	end -- 2417
end -- 2415
function Play.prototype.drawZones(self, draw, w, h) -- 2429
	local i = 0 -- 2430
	do -- 2430
		i = 0 -- 2431
		while i < #self.room.zones do -- 2431
			local z = self.room.zones[i + 1] -- 2432
			local fill = DANGER -- 2433
			local line = DANGER_LINE -- 2434
			if z.tint == 2 then -- 2434
				fill = SOFT -- 2436
				line = SOFT_LINE -- 2437
			elseif z.tint == 3 then -- 2437
				fill = BRICK -- 2439
				line = BRICK_LINE -- 2440
			elseif z.tint == 4 then -- 2440
				fill = PASS -- 2442
				line = PASS_LINE -- 2443
			end -- 2443
			self:drawBox( -- 2445
				draw, -- 2445
				w, -- 2445
				h, -- 2445
				z.x0, -- 2445
				z.x1, -- 2445
				z.y, -- 2445
				z.y + z.h, -- 2445
				fill -- 2445
			) -- 2445
			draw:drawSegment( -- 2446
				Vec2( -- 2446
					self:sx(z.x0, w), -- 2446
					self:sy(z.y, h) -- 2446
				), -- 2446
				Vec2( -- 2446
					self:sx(z.x0, w), -- 2446
					self:sy(z.y + z.h, h) -- 2446
				), -- 2446
				self:px(1), -- 2446
				line -- 2446
			) -- 2446
			draw:drawSegment( -- 2447
				Vec2( -- 2447
					self:sx(z.x1, w), -- 2447
					self:sy(z.y, h) -- 2447
				), -- 2447
				Vec2( -- 2447
					self:sx(z.x1, w), -- 2447
					self:sy(z.y + z.h, h) -- 2447
				), -- 2447
				self:px(1), -- 2447
				line -- 2447
			) -- 2447
			i = i + 1 -- 2431
		end -- 2431
	end -- 2431
end -- 2429
function Play.prototype.drawArch(self, draw, w, h) -- 2451
	local a = self.room.arch -- 2452
	if a.h <= 0 then -- 2452
		return -- 2454
	end -- 2454
	self:drawBox( -- 2456
		draw, -- 2456
		w, -- 2456
		h, -- 2456
		a.x0, -- 2456
		a.x1, -- 2456
		a.y, -- 2456
		a.y + a.h, -- 2456
		HOLE_FILL -- 2456
	) -- 2456
	draw:drawSegment( -- 2457
		Vec2( -- 2457
			self:sx(a.x0, w), -- 2457
			self:sy(a.y + a.h, h) -- 2457
		), -- 2457
		Vec2( -- 2457
			self:sx(a.x1, w), -- 2457
			self:sy(a.y + a.h, h) -- 2457
		), -- 2457
		self:px(1), -- 2457
		SOLID_EDGE -- 2457
	) -- 2457
	draw:drawSegment( -- 2458
		Vec2( -- 2458
			self:sx(a.x0, w), -- 2458
			self:sy(a.y, h) -- 2458
		), -- 2458
		Vec2( -- 2458
			self:sx(a.x0, w), -- 2458
			self:sy(a.y + a.h, h) -- 2458
		), -- 2458
		self:px(1), -- 2458
		SOLID_EDGE -- 2458
	) -- 2458
	draw:drawSegment( -- 2459
		Vec2( -- 2459
			self:sx(a.x1, w), -- 2459
			self:sy(a.y, h) -- 2459
		), -- 2459
		Vec2( -- 2459
			self:sx(a.x1, w), -- 2459
			self:sy(a.y + a.h, h) -- 2459
		), -- 2459
		self:px(1), -- 2459
		SOLID_EDGE -- 2459
	) -- 2459
end -- 2451
function Play.prototype.drawCart(self, draw, w, h) -- 2462
	local c = self.room.cart -- 2463
	if c.bodyW <= 0 then -- 2463
		return -- 2465
	end -- 2465
	drawCartShape( -- 2467
		draw, -- 2467
		self, -- 2467
		w, -- 2467
		h, -- 2467
		c, -- 2467
		self.cartAxle -- 2467
	) -- 2467
	draw:drawRect( -- 2468
		Rect( -- 2468
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2468
			self:sy(c.baseY + 40, h), -- 2468
			self:px(2), -- 2468
			self:px(40) -- 2468
		), -- 2468
		STAND -- 2468
	) -- 2468
end -- 2462
function Play.prototype.drawActors(self, draw, w, h) -- 2471
	local p = self.player -- 2472
	local isChild = self.childMode -- 2473
	if p.covered then -- 2473
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2476
		draw:drawSegment( -- 2477
			Vec2( -- 2477
				self:sx(edge, w), -- 2477
				self:sy(p.y + 8, h) -- 2477
			), -- 2477
			Vec2( -- 2477
				self:sx(edge, w), -- 2477
				self:sy(p.y + p.h * 0.62, h) -- 2477
			), -- 2477
			self:px(2), -- 2477
			STAND -- 2477
		) -- 2477
		draw:drawSegment( -- 2479
			Vec2( -- 2479
				self:sx(p.x - 8, w), -- 2479
				self:sy(p.y + p.h + 3, h) -- 2479
			), -- 2479
			Vec2( -- 2479
				self:sx(p.x + 8, w), -- 2479
				self:sy(p.y + p.h + 3, h) -- 2479
			), -- 2479
			self:px(2), -- 2479
			STAND -- 2479
		) -- 2479
	elseif self.coverNear and not isChild then -- 2479
		draw:drawRect( -- 2482
			Rect( -- 2482
				self:sx(p.x - 3, w), -- 2482
				self:sy(p.y + 1, h), -- 2482
				self:px(3), -- 2482
				self:px(3) -- 2482
			), -- 2482
			STAND -- 2482
		) -- 2482
	end -- 2482
	drawFigure( -- 2484
		draw, -- 2484
		self, -- 2484
		w, -- 2484
		h, -- 2484
		p, -- 2484
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2484
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2484
	) -- 2484
	local q = self.partner -- 2485
	if q.alive then -- 2485
		local childPartner = q.w == CHILD_W -- 2487
		drawFigure( -- 2488
			draw, -- 2488
			self, -- 2488
			w, -- 2488
			h, -- 2488
			q, -- 2488
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2488
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2488
		) -- 2488
	end -- 2488
	local i = 0 -- 2490
	do -- 2490
		i = 0 -- 2491
		while i < #self.enemies do -- 2491
			local e = self.enemies[i + 1] -- 2492
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2493
			self:drawBox( -- 2494
				draw, -- 2494
				w, -- 2494
				h, -- 2494
				e.x - e.w / 2, -- 2494
				e.x + e.w / 2, -- 2494
				e.y, -- 2494
				e.y + e.h, -- 2494
				col -- 2494
			) -- 2494
			if e.alive and e.warnT > 0 then -- 2494
				local gunX = self:sx(e.x, w) -- 2497
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2498
				local aimX = self:sx(p.x, w) -- 2499
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2500
				local seg = 8 -- 2501
				local s = 0 -- 2502
				do -- 2502
					s = 0 -- 2503
					while s < seg do -- 2503
						local t0 = s / seg -- 2504
						local t1 = (s + 1) / seg -- 2505
						draw:drawSegment( -- 2506
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2507
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2508
							self:px(1), -- 2509
							DANGER -- 2509
						) -- 2509
						s = s + 2 -- 2503
					end -- 2503
				end -- 2503
			end -- 2503
			i = i + 1 -- 2491
		end -- 2491
	end -- 2491
	local k = 0 -- 2514
	do -- 2514
		k = 0 -- 2515
		while k < #self.room.marks do -- 2515
			do -- 2515
				local m = self.room.marks[k + 1] -- 2516
				if m.kind ~= 0 then -- 2516
					goto __continue492 -- 2518
				end -- 2518
				local on = self.checkpoint == m.x -- 2520
				local x = self:sx(m.x, w) -- 2521
				local y = self:sy(m.y, h) -- 2522
				draw:drawSegment( -- 2523
					Vec2(x, y), -- 2523
					Vec2( -- 2523
						x, -- 2523
						y + self:px(35) -- 2523
					), -- 2523
					self:px(1), -- 2523
					on and CHECK or INK_DIM -- 2523
				) -- 2523
				draw:drawDot( -- 2524
					Vec2( -- 2524
						x, -- 2524
						y + self:px(35) -- 2524
					), -- 2524
					self:px(2), -- 2524
					on and CHECK or INK_DIM -- 2524
				) -- 2524
			end -- 2524
			::__continue492:: -- 2524
			k = k + 1 -- 2515
		end -- 2515
	end -- 2515
	local j = 0 -- 2528
	do -- 2528
		j = 0 -- 2529
		while j < #self.room.marks do -- 2529
			do -- 2529
				local m = self.room.marks[j + 1] -- 2530
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2530
					goto __continue495 -- 2532
				end -- 2532
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2532
					goto __continue495 -- 2536
				end -- 2536
				local col = STAND -- 2538
				if m.kind == 4 then -- 2538
					col = PASS_LINE -- 2540
				elseif m.kind == 5 then -- 2540
					col = BRICK_LINE -- 2542
				end -- 2542
				local mx = self:sx(m.x, w) -- 2544
				local my = self:sy(m.y, h) -- 2545
				draw:drawSegment( -- 2546
					Vec2(mx, my), -- 2546
					Vec2( -- 2546
						mx, -- 2546
						my + self:px(24) -- 2546
					), -- 2546
					self:px(1), -- 2546
					col -- 2546
				) -- 2546
			end -- 2546
			::__continue495:: -- 2546
			j = j + 1 -- 2529
		end -- 2529
	end -- 2529
	local t = 0 -- 2549
	do -- 2549
		t = 0 -- 2550
		while t < #self.room.marks do -- 2550
			do -- 2550
				local m = self.room.marks[t + 1] -- 2551
				if m.kind ~= 6 then -- 2551
					goto __continue501 -- 2553
				end -- 2553
				local mx = self:sx(m.x, w) -- 2555
				local my = self:sy(m.y, h) -- 2556
				draw:drawSegment( -- 2557
					Vec2(mx, my), -- 2557
					Vec2( -- 2557
						mx, -- 2557
						my + self:px(30) -- 2557
					), -- 2557
					self:px(1), -- 2557
					INK_DIM -- 2557
				) -- 2557
				self:drawBox( -- 2558
					draw, -- 2558
					w, -- 2558
					h, -- 2558
					m.x - 5, -- 2558
					m.x + 5, -- 2558
					m.y + 30, -- 2558
					m.y + 40, -- 2558
					CHECK -- 2558
				) -- 2558
			end -- 2558
			::__continue501:: -- 2558
			t = t + 1 -- 2550
		end -- 2550
	end -- 2550
	if self.room.key == "village" then -- 2550
		self:drawVillage(draw, w, h) -- 2561
	end -- 2561
	if self.room.key == "forest" then -- 2561
		self:drawDog(draw, w, h) -- 2564
	end -- 2564
end -- 2471
function Play.prototype.drawDog(self, draw, w, h) -- 2569
	local x = self.dogX -- 2570
	self:drawBox( -- 2571
		draw, -- 2571
		w, -- 2571
		h, -- 2571
		x - 14, -- 2571
		x + 14, -- 2571
		0, -- 2571
		20, -- 2571
		SCAV_BODY -- 2571
	) -- 2571
	self:drawBox( -- 2572
		draw, -- 2572
		w, -- 2572
		h, -- 2572
		x - 10, -- 2572
		x - 2, -- 2572
		20, -- 2572
		30, -- 2572
		SCAV_BODY -- 2572
	) -- 2572
	self:drawBox( -- 2573
		draw, -- 2573
		w, -- 2573
		h, -- 2573
		x + 2, -- 2573
		x + 10, -- 2573
		20, -- 2573
		30, -- 2573
		SCAV_HEAD -- 2573
	) -- 2573
	if self.dogState == "ear" or self.dogState == "chase" then -- 2573
		draw:drawSegment( -- 2575
			Vec2( -- 2575
				self:sx(x, w), -- 2575
				self:sy(30, h) -- 2575
			), -- 2575
			Vec2( -- 2576
				self:sx(x, w), -- 2576
				self:sy(40, h) -- 2576
			), -- 2576
			self:px(1), -- 2576
			DANGER -- 2576
		) -- 2576
	end -- 2576
end -- 2569
function Play.prototype.drawVillage(self, draw, w, h) -- 2581
	local bottle = self.room.bottle -- 2582
	if bottle ~= nil then -- 2582
		self:drawBox( -- 2584
			draw, -- 2584
			w, -- 2584
			h, -- 2584
			bottle.x - 14, -- 2584
			bottle.x + 14, -- 2584
			0, -- 2584
			64, -- 2584
			SOLID_FILL -- 2584
		) -- 2584
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2584
			self:drawBottle( -- 2586
				draw, -- 2586
				w, -- 2586
				h, -- 2586
				bottle.x, -- 2586
				64 -- 2586
			) -- 2586
		end -- 2586
	end -- 2586
	self:drawBox( -- 2590
		draw, -- 2590
		w, -- 2590
		h, -- 2590
		300, -- 2590
		420, -- 2590
		44, -- 2590
		50, -- 2590
		FLOOR_DECK -- 2590
	) -- 2590
	self:drawBox( -- 2591
		draw, -- 2591
		w, -- 2591
		h, -- 2591
		300, -- 2591
		306, -- 2591
		0, -- 2591
		44, -- 2591
		FLOOR_DECK -- 2591
	) -- 2591
	self:drawBox( -- 2592
		draw, -- 2592
		w, -- 2592
		h, -- 2592
		414, -- 2592
		420, -- 2592
		0, -- 2592
		44, -- 2592
		FLOOR_DECK -- 2592
	) -- 2592
	local s = self.room.scavenger -- 2594
	if s ~= nil then -- 2594
		local sx0 = self.scavX -- 2596
		self:drawBox( -- 2597
			draw, -- 2597
			w, -- 2597
			h, -- 2597
			sx0 - 12, -- 2597
			sx0 + 12, -- 2597
			0, -- 2597
			s.h - 14, -- 2597
			SCAV_BODY -- 2597
		) -- 2597
		self:drawBox( -- 2598
			draw, -- 2598
			w, -- 2598
			h, -- 2598
			sx0 - 7, -- 2598
			sx0 + 7, -- 2598
			s.h - 14, -- 2598
			s.h, -- 2598
			SCAV_HEAD -- 2598
		) -- 2598
		if self.scavState == "turn" then -- 2598
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2600
			draw:drawSegment( -- 2601
				Vec2( -- 2601
					self:sx(sx0, w), -- 2601
					self:sy(s.h - 6, h) -- 2601
				), -- 2601
				Vec2( -- 2601
					self:sx(fx, w), -- 2601
					self:sy(s.h - 6, h) -- 2601
				), -- 2601
				self:px(1), -- 2601
				INK -- 2601
			) -- 2601
		end -- 2601
	end -- 2601
	if self.hasBottle then -- 2601
		local p = self.player -- 2606
		self:drawBottle( -- 2607
			draw, -- 2607
			w, -- 2607
			h, -- 2607
			p.x + p.facing * 10, -- 2607
			p.y + p.h * 0.62 -- 2607
		) -- 2607
	end -- 2607
	if self.bottleFly ~= nil then -- 2607
		self:drawBottle( -- 2610
			draw, -- 2610
			w, -- 2610
			h, -- 2610
			self.bottleFly.x, -- 2610
			self.bottleFly.y -- 2610
		) -- 2610
	end -- 2610
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2610
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2613
		draw:drawCircle( -- 2614
			Vec2( -- 2614
				self:sx(self.bottleLandX, w), -- 2614
				self:sy(0, h) -- 2614
			), -- 2614
			self:px(r / ____exports.UNITS_PER_PX), -- 2614
			BRICK_LINE -- 2614
		) -- 2614
	end -- 2614
end -- 2581
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2618
	self:drawBox( -- 2619
		draw, -- 2619
		w, -- 2619
		h, -- 2619
		x - 3, -- 2619
		x + 3, -- 2619
		y - 10, -- 2619
		y, -- 2619
		BOTTLE -- 2619
	) -- 2619
end -- 2618
function Play.prototype.drawTrace(self, draw, w, h) -- 2622
	local t = self.trace -- 2623
	if t == nil or self.traceT <= 0 then -- 2623
		return -- 2625
	end -- 2625
	draw:drawSegment( -- 2627
		Vec2( -- 2628
			self:sx(t.x0, w), -- 2628
			self:sy(t.y0, h) -- 2628
		), -- 2628
		Vec2( -- 2629
			self:sx(t.x1, w), -- 2629
			self:sy(t.y1, h) -- 2629
		), -- 2629
		self:px(1), -- 2630
		t.hit and AIM_HIT or INK_DIM -- 2630
	) -- 2630
end -- 2622
function Play.prototype.drawAim(self, draw, w, h) -- 2633
	local v = self.view -- 2635
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2636
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2637
	local dot = self:px(1) -- 2638
	local arm = self:px(3) -- 2639
	local gap = self:px(1) -- 2640
	draw:drawSegment( -- 2641
		Vec2(gx - arm - gap, gy), -- 2641
		Vec2(gx - gap, gy), -- 2641
		dot / 2, -- 2641
		AIM -- 2641
	) -- 2641
	draw:drawSegment( -- 2642
		Vec2(gx + gap, gy), -- 2642
		Vec2(gx + arm + gap, gy), -- 2642
		dot / 2, -- 2642
		AIM -- 2642
	) -- 2642
	draw:drawSegment( -- 2643
		Vec2(gx, gy - arm - gap), -- 2643
		Vec2(gx, gy - gap), -- 2643
		dot / 2, -- 2643
		AIM -- 2643
	) -- 2643
	draw:drawSegment( -- 2644
		Vec2(gx, gy + gap), -- 2644
		Vec2(gx, gy + arm + gap), -- 2644
		dot / 2, -- 2644
		AIM -- 2644
	) -- 2644
	if self.room.key == "village" and self.hasBottle then -- 2644
		local p = self.player -- 2648
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2650
		local dir = ____end.x >= p.x and 1 or -1 -- 2651
		local x0 = p.x + dir * 10 -- 2652
		local y0 = p.y + p.h * 0.7 -- 2653
		local T = BOTTLE_FLY_TIME -- 2654
		local vx = (____end.x - x0) / T -- 2655
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2656
		local pxr = x0 -- 2657
		local pyr = y0 -- 2658
		local t = 1 -- 2659
		do -- 2659
			t = 1 -- 2660
			while t <= 12 do -- 2660
				local tt = t / 12 * T -- 2661
				local nx = x0 + vx * tt -- 2662
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2663
				draw:drawSegment( -- 2664
					Vec2( -- 2664
						self:sx(pxr, w), -- 2664
						self:sy(pyr, h) -- 2664
					), -- 2664
					Vec2( -- 2664
						self:sx(nx, w), -- 2664
						self:sy(ny, h) -- 2664
					), -- 2664
					self:px(1) / 2, -- 2664
					BOTTLE -- 2664
				) -- 2664
				pxr = nx -- 2665
				pyr = ny -- 2666
				t = t + 1 -- 2660
			end -- 2660
		end -- 2660
		draw:drawCircle( -- 2668
			Vec2( -- 2668
				self:sx(____end.x, w), -- 2668
				self:sy(____end.y + 2, h) -- 2668
			), -- 2668
			self:px(2), -- 2668
			BOTTLE -- 2668
		) -- 2668
	end -- 2668
end -- 2633
return ____exports -- 2633