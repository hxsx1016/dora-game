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
function makeActor(room, index) -- 2694
	local sp = room.spawns -- 2695
	if index < 0 or index >= #sp then -- 2695
		return { -- 2697
			x = 0, -- 2697
			y = 0, -- 2697
			vx = 0, -- 2697
			vy = 0, -- 2697
			w = CHILD_W, -- 2697
			h = CHILD_H, -- 2697
			onGround = true, -- 2697
			facing = 1, -- 2697
			crouch = false, -- 2697
			rollT = 0, -- 2697
			covered = false, -- 2697
			alive = false -- 2697
		} -- 2697
	end -- 2697
	local s = sp[index + 1] -- 2699
	local child = s.h <= CHILD_H -- 2700
	return { -- 2701
		x = s.x, -- 2702
		y = s.y, -- 2702
		vx = 0, -- 2702
		vy = 0, -- 2702
		w = child and CHILD_W or SOLDIER_W, -- 2703
		h = child and CHILD_H or SOLDIER_H, -- 2704
		onGround = true, -- 2705
		facing = 1, -- 2705
		crouch = false, -- 2705
		rollT = 0, -- 2705
		covered = false, -- 2705
		alive = true -- 2705
	} -- 2705
end -- 2705
function drawFigure(draw, play, w, h, a, body, head) -- 2709
	if not a.alive then -- 2709
		return -- 2711
	end -- 2711
	local x0 = a.x - a.w / 2 -- 2713
	local x1 = a.x + a.w / 2 -- 2714
	local y0 = a.y -- 2715
	local y1 = a.y + a.h -- 2716
	play:drawBox( -- 2717
		draw, -- 2717
		w, -- 2717
		h, -- 2717
		x0, -- 2717
		x1, -- 2717
		y0, -- 2717
		y1 - a.h * 0.26, -- 2717
		body -- 2717
	) -- 2717
	play:drawBox( -- 2718
		draw, -- 2718
		w, -- 2718
		h, -- 2718
		x0 + 2, -- 2718
		x1 - 2, -- 2718
		y1 - a.h * 0.26, -- 2718
		y1, -- 2718
		head -- 2718
	) -- 2718
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2720
	play:drawBox( -- 2721
		draw, -- 2721
		w, -- 2721
		h, -- 2721
		eyeX, -- 2721
		eyeX + 4, -- 2721
		y1 - a.h * 0.14, -- 2721
		y1 - a.h * 0.08, -- 2721
		INK -- 2721
	) -- 2721
end -- 2721
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2725
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2726
end -- 2725
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2733
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2734
end -- 2733
function hitBox(ox, oy, dx, dy, x0, x1, y0, y1) -- 2741
	local tmin = 0 -- 2742
	local tmax = 99999 -- 2743
	if dx == 0 then -- 2743
		if ox < x0 or ox > x1 then -- 2743
			return -1 -- 2746
		end -- 2746
	else -- 2746
		local t1 = (x0 - ox) / dx -- 2749
		local t2 = (x1 - ox) / dx -- 2750
		local lo = t1 < t2 and t1 or t2 -- 2751
		local hi = t1 < t2 and t2 or t1 -- 2752
		if lo > tmin then -- 2752
			tmin = lo -- 2754
		end -- 2754
		if hi < tmax then -- 2754
			tmax = hi -- 2757
		end -- 2757
	end -- 2757
	if dy == 0 then -- 2757
		if oy < y0 or oy > y1 then -- 2757
			return -1 -- 2762
		end -- 2762
	else -- 2762
		local t1 = (y0 - oy) / dy -- 2765
		local t2 = (y1 - oy) / dy -- 2766
		local lo = t1 < t2 and t1 or t2 -- 2767
		local hi = t1 < t2 and t2 or t1 -- 2768
		if lo > tmin then -- 2768
			tmin = lo -- 2770
		end -- 2770
		if hi < tmax then -- 2770
			tmax = hi -- 2773
		end -- 2773
	end -- 2773
	return tmax >= tmin and tmin or -1 -- 2776
end -- 2776
function drawCartShape(draw, play, w, h, c, axleX) -- 2779
	local half = c.bodyW / 2 -- 2780
	local x0 = axleX - half -- 2781
	local x1 = axleX + half -- 2782
	play:drawBox( -- 2783
		draw, -- 2783
		w, -- 2783
		h, -- 2783
		x0, -- 2783
		x1, -- 2783
		c.baseY + c.wheelR, -- 2783
		c.baseY + c.wheelR + c.bodyH, -- 2783
		CART_FILL -- 2783
	) -- 2783
	draw:drawCircle( -- 2784
		Vec2( -- 2784
			play:sx(x0 + c.bodyW * 0.28, w), -- 2784
			play:sy(c.baseY + c.wheelR, h) -- 2784
		), -- 2784
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2784
		Color(52, 50, 48, 255) -- 2784
	) -- 2784
	draw:drawCircle( -- 2785
		Vec2( -- 2785
			play:sx(x1 - c.bodyW * 0.28, w), -- 2785
			play:sy(c.baseY + c.wheelR, h) -- 2785
		), -- 2785
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2785
		Color(52, 50, 48, 255) -- 2785
	) -- 2785
	local cx = c.clothSide < 0 and x0 or x1 -- 2786
	play:drawBox( -- 2787
		draw, -- 2787
		w, -- 2787
		h, -- 2787
		cx - 10, -- 2787
		cx + 10, -- 2787
		c.baseY + c.wheelR + c.bodyH, -- 2787
		c.baseY + c.wheelR + c.bodyH + 18, -- 2787
		CLOTH -- 2787
	) -- 2787
end -- 2787
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
function Play.prototype.nearLowLedge(self, a) -- 625
	local reach = 26 -- 626
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 627
	local x1 = x0 + reach -- 628
	local i = 0 -- 629
	do -- 629
		i = 0 -- 630
		while i < #self.boxes do -- 630
			do -- 630
				local b = self.boxes[i + 1] -- 631
				if b.x1 <= x0 or b.x0 >= x1 then -- 631
					goto __continue66 -- 633
				end -- 633
				local rise = b.y1 - a.y -- 635
				if rise > 0 and rise <= LEDGE_RISE then -- 635
					return true -- 637
				end -- 637
			end -- 637
			::__continue66:: -- 637
			i = i + 1 -- 630
		end -- 630
	end -- 630
	return false -- 640
end -- 625
function Play.prototype.stepPlayer(self, a, dt, input) -- 643
	if not a.alive then -- 643
		return -- 645
	end -- 645
	local isChild = self.childMode -- 647
	local lowArch = isChild and self:underLowArch(a) -- 649
	if self:storyLocked() then -- 649
		a.vx = 0 -- 652
		a.crouch = isChild and lowArch -- 653
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 654
		self:fallY(a, dt) -- 655
		return -- 656
	end -- 656
	if not isChild and self.escort.state == "calming" then -- 656
		a.crouch = false -- 660
		a.h = SOLDIER_H -- 661
		a.vx = 0 -- 662
		self:fallY(a, dt) -- 663
		return -- 664
	end -- 664
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 666
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 667
	local nearCover = not isChild and self:nearCover(a) -- 668
	a.covered = nearCover and input.cover.held -- 669
	if a.rollT > 0 then -- 669
		a.rollT = a.rollT - dt -- 673
		a.vx = a.facing * ROLL_SPEED -- 674
		self:slideX(a, a.vx * dt) -- 675
		self:fallY(a, dt) -- 676
		if a.rollT <= 0 then -- 676
			self:flashSet("翻滚结束", 0.5) -- 678
		end -- 678
		return -- 680
	end -- 680
	if not isChild and not self.gripping and input.jump.pressed and a.onGround then -- 680
		if input.moveX ~= 0 then -- 680
			a.facing = input.moveX > 0 and 1 or -1 -- 685
		end -- 685
		if self:nearLowLedge(a) then -- 685
			a.vy = SOLDIER_JUMP -- 689
			a.onGround = false -- 690
			self:flashSet("翻上去", 0.3) -- 691
			return -- 692
		end -- 692
		a.rollT = ROLL_TIME -- 694
		self:flashSet("翻滚", 0.3) -- 695
		return -- 696
	end -- 696
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 699
	if isChild then -- 699
		if input.cover.held then -- 699
			speed = CHILD_SLOW -- 702
		end -- 702
		if a.crouch then -- 702
			speed = CHILD_SLOW -- 705
		end -- 705
	elseif a.covered then -- 705
		speed = SOLDIER_SPEED * 0.45 -- 708
	end -- 708
	local dir = self.gripping and 0 or input.moveX -- 712
	if dir ~= 0 then -- 712
		a.facing = dir > 0 and 1 or -1 -- 714
	end -- 714
	a.vx = dir * speed -- 716
	if isChild and input.jump.pressed and a.onGround and not a.crouch then -- 716
		a.vy = CHILD_JUMP -- 720
		a.onGround = false -- 721
		self:flashSet("跳", 0.25) -- 722
	end -- 722
	self:slideX(a, a.vx * dt) -- 725
	self:fallY(a, dt) -- 726
	if not isChild and not self.gripping and input.fire.pressed then -- 726
		self:shoot(a) -- 730
	end -- 730
end -- 643
function Play.prototype.stepPartner(self, p, dt) -- 735
	local a = self.partner -- 736
	if not a.alive then -- 736
		return -- 738
	end -- 738
	a.crouch = false -- 740
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 741
	a.vx = 0 -- 742
	self:fallY(a, dt) -- 743
end -- 735
function Play.prototype.stepEscort(self, dt, input) -- 750
	local a = self.partner -- 751
	if not a.alive then -- 751
		return -- 753
	end -- 753
	if not self:escortOn() then -- 753
		a.vx = 0 -- 756
		self:fallY(a, dt) -- 757
		return -- 758
	end -- 758
	local p = self.player -- 760
	local dist = math.abs(p.x - a.x) -- 761
	local hadKnock1 = self.escort.knock1 -- 762
	local hadKnock2 = self.escort.knock2 -- 763
	self.calmConsumed = self.escort:update( -- 764
		input, -- 764
		p.x, -- 764
		p.facing, -- 764
		a.x, -- 764
		dist -- 764
	) -- 764
	if not hadKnock1 and self.escort.knock1 then -- 764
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 767
	end -- 767
	if not hadKnock2 and self.escort.knock2 then -- 767
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 770
	end -- 770
	a.crouch = self.escort.crouchPose -- 772
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 773
	local dir = self.escort:moveDir(a.x) -- 774
	a.vx = dir * CHILD_SPEED -- 775
	if dir ~= 0 then -- 775
		a.facing = dir -- 777
		local before = a.x -- 778
		self:slideX(a, dir * CHILD_SPEED * dt) -- 779
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 779
			a.vy = CHILD_JUMP -- 782
			a.onGround = false -- 783
		end -- 783
	end -- 783
	self:fallY(a, dt) -- 786
end -- 750
function Play.prototype.escortOn(self) -- 790
	if self.room.key == "checkpoint" then -- 790
		return true -- 792
	end -- 792
	if self.room.key == "prologue" then -- 792
		return self.phase == "prologue-follow" -- 795
	end -- 795
	return self.room.key == "street" -- 797
end -- 790
function Play.prototype.storyLocked(self) -- 801
	if self.caughtT > 0 then -- 801
		return true -- 803
	end -- 803
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 803
		return true -- 806
	end -- 806
	if self.room.key == "gate" and self.phase == "gate-count" then -- 806
		return true -- 809
	end -- 809
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 809
		return true -- 812
	end -- 812
	return false -- 814
end -- 801
function Play.prototype.swapToChild(self, x) -- 818
	local tmp = self.player -- 819
	self.player = self.partner -- 820
	self.partner = tmp -- 821
	self.childMode = true -- 822
	self.player.alive = true -- 823
	self.player.x = self.ox + x -- 824
	self.player.y = 0 -- 825
	self.player.vy = 0 -- 826
	self.player.vx = 0 -- 827
	self.player.onGround = true -- 828
	self.player.crouch = false -- 829
	self.player.h = CHILD_H -- 830
	self.player.facing = 1 -- 831
	self.partner.alive = true -- 832
	self.cam.x = self.player.x -- 833
end -- 818
function Play.prototype.stepStory(self, dt, input) -- 837
	if self.room.key == "prologue" then -- 837
		self:stepPrologue(dt, input) -- 839
	elseif self.room.key == "street" then -- 839
		self:stepStreet(dt, input) -- 841
	elseif self.room.key == "gate" then -- 841
		self:stepGate(dt, input) -- 843
	elseif self.room.key == "tower" then -- 843
		self:stepTower(dt, input) -- 845
	end -- 845
end -- 837
function Play.prototype.stepPrologue(self, dt, input) -- 850
	local child = self.partner -- 851
	if self.phase == "prologue-wait" then -- 851
		child.crouch = true -- 853
		child.h = CHILD_CROUCH_H -- 854
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 855
		local near = math.abs(self.player.x - child.x) <= reach -- 857
		if near and input.interact.pressed then -- 857
			self.phase = "prologue-give" -- 859
			self.phaseTick = 0 -- 860
			self:flashSet("递出针套", 1) -- 861
		end -- 861
		return -- 863
	end -- 863
	if self.phase == "prologue-give" then -- 863
		self.phaseTick = self.phaseTick + 1 -- 866
		if self.phaseTick == 12 then -- 866
			self:flashSet("针套递过去", 0.7) -- 868
		elseif self.phaseTick == 36 then -- 868
			self:flashSet("纸条塞进针套", 0.9) -- 870
		elseif self.phaseTick >= 60 then -- 870
			self.phase = "prologue-follow" -- 872
			self.phaseTick = 0 -- 873
			child.crouch = false -- 874
			child.h = CHILD_H -- 875
			self:flashSet("她跟上了", 1.2) -- 876
		end -- 876
		return -- 878
	end -- 878
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 878
		self:requestRoom("street", "序章跟到门口") -- 882
		self:flashSet("进街道", 1.2) -- 883
	end -- 883
end -- 850
function Play.prototype.stepStreet(self, dt, input) -- 888
	local p = self.player -- 889
	local c = self.partner -- 890
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 890
		self:requestRoom("checkpoint", "两人都到街尾") -- 892
		self:flashSet("到检查站", 1.2) -- 893
	end -- 893
end -- 888
function Play.prototype.stepGate(self, dt, input) -- 898
	local ____temp_8 -- 899
	if self.room.story == nil then -- 899
		____temp_8 = nil -- 899
	else -- 899
		____temp_8 = self.room.story.gate -- 899
	end -- 899
	local g = ____temp_8 -- 899
	if g == nil then -- 899
		return -- 901
	end -- 901
	local p = self.player -- 903
	if self.phase == "gate-idle" then -- 903
		local a = self.partner -- 906
		local gap = g.waitX - a.x -- 907
		if math.abs(gap) > 3 then -- 907
			a.facing = gap > 0 and 1 or -1 -- 909
			a.vx = a.facing * CHILD_SPEED -- 910
			local beforeX = a.x -- 911
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 912
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 912
				a.vy = CHILD_JUMP -- 914
				a.onGround = false -- 915
			end -- 915
			self:fallY(a, dt) -- 917
		else -- 917
			a.vx = 0 -- 919
			a.x = g.waitX -- 920
		end -- 920
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 -- 923
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 924
		if self.gateNeedConfirm then -- 924
			if not input.interact.held then -- 924
				self.gateRestartArmed = true -- 929
			end -- 929
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 929
				self.gateNeedConfirm = false -- 932
				self.gateRestartArmed = true -- 933
				self.phase = "gate-hold" -- 934
				self.gateTick = 0 -- 935
				self.gateSpawned = 0 -- 936
				self:flashSet("重新就位 · 守点开始", 1.4) -- 937
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 938
			end -- 938
			return -- 940
		end -- 940
		if atWinch and atWait then -- 940
			self.phase = "gate-hold" -- 943
			self.gateTick = 0 -- 944
			self.gateSpawned = 0 -- 945
			self:flashSet("两人就位 · 守点开始", 1.4) -- 946
		end -- 946
		return -- 948
	end -- 948
	if self.phase == "gate-hold" then -- 948
		self.gateTick = self.gateTick + 1 -- 951
		local marks = {0, 540, 900, 1500} -- 953
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 953
			local idx = self.gateSpawned -- 955
			local ____self_enemies_9 = self.enemies -- 955
			____self_enemies_9[#____self_enemies_9 + 1] = { -- 956
				x = self.ox + 620 + idx * 62, -- 957
				y = 0, -- 957
				w = 26, -- 957
				h = 84, -- 957
				alive = true, -- 958
				hitT = 0, -- 958
				warnT = 0, -- 958
				fireCd = 90 + idx * 45 -- 958
			} -- 958
			self.gateSpawned = self.gateSpawned + 1 -- 960
			self:flashSet( -- 961
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 961
				0.9 -- 961
			) -- 961
		end -- 961
		if self.gateTick == 900 then -- 961
			self:flashSet("灯灭了", 1) -- 964
		elseif self.gateTick == 2100 then -- 964
			self:flashSet("门底压下来了", 1) -- 966
		end -- 966
		if self.gateTick >= g.holdTicks then -- 966
			self.phase = "gate-send" -- 969
			self.phaseTick = 0 -- 970
			self.enemies = {} -- 972
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 973
		end -- 973
		return -- 975
	end -- 975
	if self.phase == "gate-send" then -- 975
		local near = math.abs(p.x - g.doorX) <= 60 -- 978
		if near and input.interact.pressed then -- 978
			self:swapToChild(g.doorX + 30) -- 980
			self.phase = "gate-count" -- 981
			self.countTick = 0 -- 982
			self.countArmed = false -- 984
			self.countPrevMove = input.moveX -- 985
			self:flashSet("门开了 · 送她出去", 1.8) -- 986
		end -- 986
		return -- 988
	end -- 988
	if self.phase == "gate-count" then -- 988
		self.countTick = self.countTick + 1 -- 991
		if self.countTick == 360 then -- 991
			self:flashSet("门关上", 0.9) -- 993
		elseif self.countTick == 1020 then -- 993
			self:flashSet("数到一百", 2.2) -- 995
		end -- 995
		local prevMove = self.countPrevMove -- 999
		self.countPrevMove = input.moveX -- 1000
		if self.countTick >= 1440 then -- 1000
			if prevMove <= 0 and input.moveX > 0 then -- 1000
				self.countArmed = true -- 1003
			end -- 1003
			if self.countArmed and input.moveX > 0 then -- 1003
				self.phase = "gate-walk" -- 1006
				self.phaseTick = 0 -- 1007
				self:flashSet("她迈出第一步", 1.4) -- 1008
			end -- 1008
		end -- 1008
		return -- 1011
	end -- 1011
	if self.player.x >= g.exitX then -- 1011
		self:requestRoom("outside", "走出城门") -- 1015
		self:flashSet("出城门 · 城外", 1.4) -- 1016
	end -- 1016
end -- 898
function Play.prototype.stepTower(self, dt, input) -- 1021
	local ____temp_10 -- 1022
	if self.room.story == nil then -- 1022
		____temp_10 = nil -- 1022
	else -- 1022
		____temp_10 = self.room.story.tower -- 1022
	end -- 1022
	local t = ____temp_10 -- 1022
	if t == nil then -- 1022
		return -- 1024
	end -- 1024
	if self.phase == "tower-wait" then -- 1024
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1027
		if near and input.interact.pressed then -- 1027
			self.phase = "tower-knock" -- 1029
			self.phaseTick = 0 -- 1030
			self.knocks = 1 -- 1031
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1032
			self:flashSet("敲一下", 0.6) -- 1033
		end -- 1033
		return -- 1035
	end -- 1035
	if self.phase == "tower-knock" then -- 1035
		self.phaseTick = self.phaseTick + 1 -- 1038
		if self.phaseTick == 12 then -- 1038
			self.knocks = 2 -- 1040
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1041
			self:flashSet("敲两下 · 第二声", 1) -- 1042
		elseif self.phaseTick >= t.knockTicks then -- 1042
			self.phase = "tower-given" -- 1044
			self.phaseTick = 0 -- 1045
			self:flashSet("门开了 · 提灯", 1.4) -- 1046
		end -- 1046
		return -- 1048
	end -- 1048
	if self.phase == "tower-given" then -- 1048
		self.phaseTick = self.phaseTick + 1 -- 1051
		if self.phaseTick == 60 then -- 1051
			self:flashSet("她递出针套和纸条", 1.6) -- 1053
		elseif self.phaseTick == 120 then -- 1053
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1055
		elseif self.phaseTick >= 180 then -- 1055
			self.phase = "tower-end" -- 1057
			self.phaseTick = 0 -- 1058
			self:flashSet("片尾 · E 再玩一次", 3) -- 1059
		end -- 1059
		return -- 1061
	end -- 1061
	if input.interact.pressed or input.retry.pressed then -- 1061
		self:requestRoom("prologue", "片尾再玩") -- 1064
		self:flashSet("回到序章", 1.4) -- 1065
	end -- 1065
end -- 1021
function Play.prototype.stepChase(self, dt, input) -- 1070
	if self.caughtT > 0 then -- 1070
		self.caughtT = self.caughtT - dt -- 1072
		if self.caughtT <= 0 then -- 1072
			self:recoverFromCaught() -- 1074
		end -- 1074
		return -- 1076
	end -- 1076
	if self.room.key == "village" then -- 1076
		self:stepScavChase() -- 1079
	elseif self.room.key == "forest" then -- 1079
		self:stepDog(dt) -- 1081
		if self.player.x >= self.ox + 1450 then -- 1081
			self:requestRoom("tower", "到林缘北塔") -- 1084
			self:flashSet("林缘 · 北塔", 1.4) -- 1085
		end -- 1085
	end -- 1085
end -- 1070
function Play.prototype.stepScavChase(self) -- 1091
	local s = self.room.scavenger -- 1092
	if s == nil then -- 1092
		return -- 1094
	end -- 1094
	local p = self.player -- 1096
	if self.passed and p.x > self.ox + 440 then -- 1096
		if self.scavChase then -- 1096
			self.scavChase = false -- 1100
			self.scavState = "back" -- 1101
			self.scavT = 0 -- 1102
		end -- 1102
		return -- 1104
	end -- 1104
	local dx = p.x - self.scavX -- 1106
	local dist = math.abs(dx) -- 1107
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1108
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1109
	if not self.scavChase then -- 1109
		if visible then -- 1109
			self.scavSee = self.scavSee + 1 -- 1112
			if self.scavSee >= 24 then -- 1112
				self.scavChase = true -- 1114
				self.scavState = "chase" -- 1115
				self.scavTargetX = p.x -- 1116
				self:flashSet("他看见你了", 1.2) -- 1117
			end -- 1117
		else -- 1117
			self.scavSee = 0 -- 1120
		end -- 1120
		return -- 1122
	end -- 1122
	local dir = p.x > self.scavX and 1 or -1 -- 1125
	self.scavX = self.scavX + dir * 96 / 60 -- 1126
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1126
		self:caught() -- 1128
		return -- 1129
	end -- 1129
	if hidden then -- 1129
		self.scavSee = 0 -- 1133
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1134
		self.scavT = self.scavT - 1 -- 1135
		if self.scavT <= 0 then -- 1135
			self.scavChase = false -- 1137
			self.scavState = "patrol" -- 1138
			self:flashSet("他失去了目标", 1) -- 1139
		end -- 1139
	end -- 1139
end -- 1091
function Play.prototype.stepDog(self, dt) -- 1145
	local ____temp_11 -- 1146
	if self.room.story == nil then -- 1146
		____temp_11 = nil -- 1146
	else -- 1146
		____temp_11 = self.room.story.dog -- 1146
	end -- 1146
	local dog = ____temp_11 -- 1146
	if dog == nil then -- 1146
		return -- 1148
	end -- 1148
	local p = self.player -- 1150
	local dist = math.abs(p.x - self.dogX) -- 1151
	if self.dogState == "patrol" then -- 1151
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1153
		if self.dogX < dog.x0 then -- 1153
			self.dogX = dog.x0 -- 1155
			self.dogDir = 1 -- 1156
		elseif self.dogX > dog.x1 then -- 1156
			self.dogX = dog.x1 -- 1158
			self.dogDir = -1 -- 1159
		end -- 1159
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1161
		if not p.crouch and moving and dist < dog.range then -- 1161
			self.dogState = "ear" -- 1163
			self.dogT = 18 -- 1164
			self.dogTargetX = p.x -- 1165
			self:flashSet("狗转耳朵", 0.8) -- 1166
		end -- 1166
		return -- 1168
	end -- 1168
	if self.dogState == "ear" then -- 1168
		self.dogT = self.dogT - 1 -- 1171
		if self.dogT <= 0 then -- 1171
			self.dogState = "chase" -- 1173
			self.dogTargetX = p.x -- 1174
			self:flashSet("狗追来了", 1.4) -- 1175
		end -- 1175
		return -- 1177
	end -- 1177
	if self.dogState == "chase" then -- 1177
		local dir = p.x > self.dogX and 1 or -1 -- 1180
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1181
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1181
			self:caught() -- 1183
			self.dogState = "sniff" -- 1184
			self.dogT = 60 -- 1185
		elseif dist > dog.range * 1.5 or p.crouch then -- 1185
			self.dogState = "sniff" -- 1187
			self.dogT = 60 -- 1188
			self:flashSet("狗停下了", 0.9) -- 1189
		end -- 1189
		return -- 1191
	end -- 1191
	if self.dogState == "sniff" then -- 1191
		self.dogT = self.dogT - 1 -- 1194
		if self.dogT <= 0 then -- 1194
			self.dogState = "back" -- 1196
		end -- 1196
		return -- 1198
	end -- 1198
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1201
	self.dogX = self.dogX + dir * dog.speed * dt -- 1202
	if math.abs(self.dogX - dog.x0) < 2 then -- 1202
		self.dogX = dog.x0 -- 1204
		self.dogState = "patrol" -- 1205
	end -- 1205
end -- 1145
function Play.prototype.caught(self) -- 1209
	self.caughtT = 1 -- 1210
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1211
end -- 1209
function Play.prototype.recoverFromCaught(self) -- 1215
	local p = self.player -- 1216
	p.x = self.ox + 140 -- 1217
	p.y = 0 -- 1218
	p.vy = 0 -- 1219
	p.vx = 0 -- 1220
	p.onGround = true -- 1221
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1221
		self.scavX = self.room.scavenger.x0 -- 1223
		self.scavState = "patrol" -- 1224
		self.scavSee = 0 -- 1225
		self.scavChase = false -- 1226
		self.scavT = 0 -- 1227
	end -- 1227
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1227
		self.dogX = self.room.story.dog.x0 -- 1230
		self.dogState = "patrol" -- 1231
		self.dogT = 0 -- 1232
	end -- 1232
	self.cam.x = p.x -- 1234
	self.cam.y = p.y + CAM_LOOK_UP -- 1235
	self:flashSet("回到安全点", 1.2) -- 1236
end -- 1215
function Play.prototype.updateGate(self) -- 1240
	if self.room.key ~= "checkpoint" then -- 1240
		self.gateOpen = false -- 1242
		return -- 1243
	end -- 1243
	local function inZone(x) -- 1245
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1245
	end -- 1245
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1246
end -- 1240
function Play.prototype.stepEnemies(self, dt, input) -- 1249
	local i = 0 -- 1250
	do -- 1250
		i = 0 -- 1251
		while i < #self.enemies do -- 1251
			local e = self.enemies[i + 1] -- 1252
			if e.hitT > 0 then -- 1252
				e.hitT = e.hitT - dt -- 1254
			end -- 1254
			i = i + 1 -- 1251
		end -- 1251
	end -- 1251
	if self.coveredFlash > 0 then -- 1251
		self.coveredFlash = self.coveredFlash - dt -- 1258
	end -- 1258
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1258
		return -- 1262
	end -- 1262
	do -- 1262
		i = 0 -- 1264
		while i < #self.enemies do -- 1264
			do -- 1264
				local e = self.enemies[i + 1] -- 1265
				if not e.alive then -- 1265
					goto __continue199 -- 1267
				end -- 1267
				if e.warnT > 0 then -- 1267
					e.warnT = e.warnT - 1 -- 1270
					if e.warnT <= 0 then -- 1270
						self:enemyFire(e, input) -- 1272
					end -- 1272
					goto __continue199 -- 1274
				end -- 1274
				if e.fireCd > 0 then -- 1274
					e.fireCd = e.fireCd - 1 -- 1277
					if e.fireCd <= 0 then -- 1277
						e.warnT = WARN_TICKS -- 1279
					end -- 1279
				else -- 1279
					e.warnT = WARN_TICKS -- 1283
				end -- 1283
			end -- 1283
			::__continue199:: -- 1283
			i = i + 1 -- 1264
		end -- 1264
	end -- 1264
end -- 1249
function Play.prototype.enemyFire(self, e, input) -- 1289
	local p = self.player -- 1290
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1290
		self:flashSet("枪声响在远处", 0.4) -- 1292
		e.fireCd = FIRE_COOLDOWN -- 1293
		return -- 1294
	end -- 1294
	local cover = self:blockedByCover(e.x, p) -- 1297
	local hugging = cover ~= nil -- 1298
	self.coverBlocking = hugging -- 1299
	local covered = hugging and input.cover.held -- 1300
	if covered then -- 1300
		self.coveredFlash = 0.5 -- 1302
		self:flashSet("掩体挡下", 0.5) -- 1303
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1304
		e.fireCd = FIRE_COOLDOWN -- 1309
		return -- 1310
	end -- 1310
	self.hp = self.hp - 1 -- 1312
	self:emit("actorHit", { -- 1313
		target = "player", -- 1313
		amount = 1, -- 1313
		hp = self.hp, -- 1313
		maxHp = self.maxHp, -- 1313
		enemyX = e.x -- 1313
	}) -- 1313
	self:flashSet( -- 1314
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1314
		0.7 -- 1314
	) -- 1314
	e.fireCd = FIRE_COOLDOWN -- 1315
	if self.hp <= 0 then -- 1315
		self:gateFailed() -- 1317
	end -- 1317
end -- 1289
function Play.prototype.blockedByCover(self, ex, p) -- 1322
	local b = self:coverAt(p) -- 1323
	if b == nil then -- 1323
		return nil -- 1325
	end -- 1325
	return self:coverGuardsFrom(b, p, ex) and b or nil -- 1327
end -- 1322
function Play.prototype.gateFailed(self) -- 1331
	local ____temp_12 -- 1332
	if self.room.story == nil then -- 1332
		____temp_12 = nil -- 1332
	else -- 1332
		____temp_12 = self.room.story.gate -- 1332
	end -- 1332
	local g = ____temp_12 -- 1332
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1333
	self.hp = self.maxHp -- 1334
	self.gateTick = 0 -- 1335
	self.gateSpawned = 0 -- 1336
	self.enemies = {} -- 1337
	self.gateFailCount = self.gateFailCount + 1 -- 1338
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1340
	self.player.y = 0 -- 1341
	self.player.vy = 0 -- 1342
	self.player.onGround = true -- 1343
	self.player.crouch = false -- 1344
	self.player.h = SOLDIER_H -- 1345
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1346
	self.partner.y = 0 -- 1347
	self.partner.vy = 0 -- 1348
	self.partner.onGround = true -- 1349
	self.cam.x = self.player.x -- 1350
	self.phase = "gate-idle" -- 1351
	self.phaseTick = 0 -- 1352
	self.coverHug = false -- 1353
	self.coverBlocking = false -- 1354
	self.coverEntity = "" -- 1355
	self.gateNeedConfirm = true -- 1356
	self.gateRestartArmed = false -- 1357
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1358
end -- 1331
function Play.prototype.stepInteract(self, dt, input) -- 1361
	local p = self.player -- 1362
	local calmUsed = self.calmConsumed -- 1363
	self.calmConsumed = false -- 1364
	self.focusCart = false -- 1365
	if self.room.key == "outside" then -- 1365
		local c = self.room.cart -- 1367
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1368
		local dy = p.y - c.baseY -- 1369
		self.focusCart = not calmUsed and dx * dx + dy * dy < CART_REACH * CART_REACH -- 1370
	end -- 1370
	if not calmUsed then -- 1370
		self:stepCart(dt, input) -- 1374
	end -- 1374
	if calmUsed then -- 1374
		self:flashSet("安抚 · 敲两下", 0.8) -- 1379
	elseif input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1379
		if self.knockT > 0 then -- 1379
			self.knocks = self.knocks + 1 -- 1383
		else -- 1383
			self.knocks = 1 -- 1385
		end -- 1385
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1387
		self.knockT = 1.2 -- 1388
		if self.knocks >= 2 then -- 1388
			self:flashSet("敲两下", 0.8) -- 1390
			self.knocks = 0 -- 1391
		else -- 1391
			self:flashSet("敲一下", 0.5) -- 1393
		end -- 1393
	elseif self.knockT > 0 then -- 1393
		self.knockT = self.knockT - dt -- 1396
		if self.knockT <= 0 then -- 1396
			self.knocks = 0 -- 1398
		end -- 1398
	end -- 1398
	local i = 0 -- 1403
	do -- 1403
		i = 0 -- 1404
		while i < #self.room.marks do -- 1404
			do -- 1404
				local m = self.room.marks[i + 1] -- 1405
				if m.kind ~= 0 then -- 1405
					goto __continue225 -- 1407
				end -- 1407
				local subjects = {self.partner, self.player} -- 1409
				local k = 0 -- 1410
				do -- 1410
					k = 0 -- 1411
					while k < #subjects do -- 1411
						do -- 1411
							local s = subjects[k + 1] -- 1412
							if not s.alive then -- 1412
								goto __continue228 -- 1414
							end -- 1414
							local dx = s.x - m.x -- 1416
							local dy = s.y - m.y -- 1417
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1417
								self.checkpoint = m.x -- 1419
								self.checkpointCartAxle = self.cartAxle -- 1420
								if self.cartDocked then -- 1420
									self:flashSet("检查点 · 车已落窝", 1) -- 1422
								else -- 1422
									self:flashSet("检查点 · 车还没到位", 1) -- 1424
								end -- 1424
							end -- 1424
						end -- 1424
						::__continue228:: -- 1424
						k = k + 1 -- 1411
					end -- 1411
				end -- 1411
			end -- 1411
			::__continue225:: -- 1411
			i = i + 1 -- 1404
		end -- 1404
	end -- 1404
	self:checkCarryGate() -- 1430
end -- 1361
function Play.prototype.stepVillage(self, dt, input) -- 1434
	if self.room.key ~= "village" then -- 1434
		return -- 1436
	end -- 1436
	local p = self.player -- 1438
	local bottle = self.room.bottle -- 1439
	local scav = self.room.scavenger -- 1440
	if not self.hasBottle and bottle ~= nil then -- 1440
		local dx = p.x - bottle.x -- 1444
		local dy = p.y + p.h * 0.5 - bottle.y -- 1445
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1445
			self.hasBottle = true -- 1447
			self:flashSet("拾起瓶子", 0.8) -- 1448
		end -- 1448
	end -- 1448
	if self.hasBottle then -- 1448
		if input.aim.held then -- 1448
			self.aimHold = self.aimHold + dt -- 1455
			if self.aimHold > 1.2 then -- 1455
				self.aimHold = 1.2 -- 1457
			end -- 1457
			local cached = self:bottleEnd() -- 1460
			self.bottleAimX = cached.x -- 1461
			self.bottleAimY = cached.y -- 1462
		elseif input.aim.released then -- 1462
			if self.aimHold < 0.12 then -- 1462
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1466
				self.aimHold = 0 -- 1467
			else -- 1467
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1469
				self:throwBottle(____end.x, ____end.y) -- 1470
				self.aimHold = 0 -- 1471
			end -- 1471
		end -- 1471
	else -- 1471
		self.aimHold = 0 -- 1475
		self.bottleAimX = -1 -- 1476
	end -- 1476
	local fly = self.bottleFly -- 1481
	if fly ~= nil then -- 1481
		fly.t = fly.t + dt -- 1483
		fly.x = fly.x0 + fly.vx * fly.t -- 1484
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1485
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1486
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1486
			self:landBottle(fly) -- 1488
		end -- 1488
	end -- 1488
	if self.bottleLandT > 0 then -- 1488
		self.bottleLandT = self.bottleLandT - dt -- 1492
	end -- 1492
	if scav ~= nil then -- 1492
		self:stepScav(dt, scav) -- 1496
	end -- 1496
	local line = self.room.passLine -- 1499
	if line ~= nil and not self.passed and p.x >= line then -- 1499
		self.passed = true -- 1501
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1502
	end -- 1502
	if self.passed and p.x >= self.ox + 640 then -- 1502
		self:requestRoom("forest", "过第一院出院") -- 1506
		self:flashSet("出院 · 北塔森林", 1.4) -- 1507
	end -- 1507
end -- 1434
function Play.prototype.bottleEnd(self) -- 1512
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1513
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1514
	return {x = aim.x, y = g} -- 1515
end -- 1512
function Play.prototype.throwBottle(self, tx, ty) -- 1519
	local p = self.player -- 1520
	local dir = tx >= p.x and 1 or -1 -- 1522
	p.facing = dir -- 1523
	local x0 = p.x + dir * 10 -- 1524
	local y0 = p.y + p.h * 0.7 -- 1525
	self.bottleTargetX = tx -- 1526
	self.bottleTargetY = ty -- 1527
	self.bottleSurfaceY = ty -- 1528
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1529
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1530
	self.bottleFly = { -- 1531
		x = x0, -- 1531
		y = y0, -- 1531
		x0 = x0, -- 1531
		y0 = y0, -- 1531
		vx = vx, -- 1531
		vy = vy, -- 1531
		t = 0 -- 1531
	} -- 1531
	self.hasBottle = false -- 1532
	self:flashSet("投出", 0.4) -- 1533
	self:emit( -- 1534
		"bottleThrown", -- 1534
		{ -- 1534
			fromX = x0, -- 1535
			fromY = y0, -- 1536
			targetX = tx, -- 1537
			targetY = ty, -- 1538
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1539
		} -- 1539
	) -- 1539
end -- 1519
function Play.prototype.landBottle(self, fly) -- 1544
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1545
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1546
	local s = self.room.scavenger -- 1547
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1548
	self.bottleFly = nil -- 1549
	self.bottleTargetX = -1 -- 1550
	self.bottleTargetY = 0 -- 1551
	self.bottleSurfaceY = -1 -- 1552
	self.bottleLandX = x -- 1553
	self.bottleLandY = y -- 1554
	self.bottleLandT = 0.9 -- 1555
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1556
	self:hearBottle(x) -- 1557
end -- 1544
function Play.prototype.hearBottle(self, x) -- 1561
	local s = self.room.scavenger -- 1562
	if s == nil then -- 1562
		return -- 1564
	end -- 1564
	if math.abs(x - self.scavX) > s.range then -- 1564
		self:flashSet("落地 · 他没听见", 0.6) -- 1567
		return -- 1568
	end -- 1568
	self.scavState = "turn" -- 1570
	self.scavT = s.hearTicks -- 1571
	self.scavTargetX = x -- 1572
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1573
end -- 1561
function Play.prototype.stepScav(self, dt, s) -- 1577
	if self.scavState == "chase" then -- 1577
		return -- 1580
	end -- 1580
	if self.scavState == "turn" then -- 1580
		self.scavT = self.scavT - 1 -- 1583
		if self.scavT <= 0 then -- 1583
			self.scavState = "walk" -- 1585
		end -- 1585
		return -- 1587
	end -- 1587
	if self.scavState == "walk" then -- 1587
		local d = self.scavTargetX - self.scavX -- 1590
		if math.abs(d) < 4 then -- 1590
			self.scavState = "stall" -- 1592
			self.scavT = s.stallTicks -- 1593
			return -- 1594
		end -- 1594
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1596
		return -- 1597
	end -- 1597
	if self.scavState == "stall" then -- 1597
		self.scavT = self.scavT - 1 -- 1600
		if self.scavT <= 0 then -- 1600
			self.scavState = "back" -- 1602
		end -- 1602
		return -- 1604
	end -- 1604
	if self.scavState == "back" then -- 1604
		local home = math.max( -- 1607
			s.x0, -- 1607
			math.min(s.x1, self.scavX) -- 1607
		) -- 1607
		if math.abs(home - self.scavX) < 2 then -- 1607
			self.scavState = "patrol" -- 1609
			return -- 1610
		end -- 1610
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1612
		return -- 1613
	end -- 1613
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1615
	if self.scavX >= s.x1 then -- 1615
		self.scavX = s.x1 -- 1617
		self.scavDir = -1 -- 1618
	elseif self.scavX <= s.x0 then -- 1618
		self.scavX = s.x0 -- 1620
		self.scavDir = 1 -- 1621
	end -- 1621
end -- 1577
function Play.prototype.stepCart(self, dt, input) -- 1629
	local p = self.player -- 1630
	local c = self.room.cart -- 1631
	local handleX = self.cartAxle + c.handleOffset -- 1632
	if self.gripping then -- 1632
		if not input.interact.held then -- 1632
			self.gripping = false -- 1636
			self:flashSet("松开车把", 0.4) -- 1637
			return -- 1638
		end -- 1638
	else -- 1638
		if not input.interact.pressed then -- 1638
			return -- 1642
		end -- 1642
		if math.abs(p.x - handleX) > CART_REACH or math.abs(p.y - c.baseY) > 40 then -- 1642
			return -- 1645
		end -- 1645
		self.gripping = true -- 1647
		self:flashSet("握住车把", 0.4) -- 1648
		return -- 1649
	end -- 1649
	if self.cartDocked then -- 1649
		return -- 1653
	end -- 1653
	local dir = input.moveX -- 1655
	if dir == 0 then -- 1655
		return -- 1657
	end -- 1657
	local lo = math.min(c.startX, c.endX) -- 1659
	local hi = math.max(c.startX, c.endX) -- 1660
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1661
	if next < lo then -- 1661
		next = lo -- 1663
	end -- 1663
	if next > hi then -- 1663
		next = hi -- 1666
	end -- 1666
	local delta = next - self.cartAxle -- 1668
	if delta == 0 then -- 1668
		return -- 1670
	end -- 1670
	self.cartAxle = next -- 1672
	p.x = p.x + delta -- 1673
	p.facing = dir > 0 and 1 or -1 -- 1674
	self:slideX(p, 0) -- 1675
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > CART_REACH then -- 1675
		self.gripping = false -- 1677
		self:flashSet("跟不上了，脱手", 0.6) -- 1678
		return -- 1679
	end -- 1679
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1679
		self.cartDocked = true -- 1682
		self.gripping = false -- 1683
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1684
		self:flashSet("车轮落窝", 1.2) -- 1685
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1685
		self:flashSet("车轮回到起点", 0.5) -- 1687
	end -- 1687
end -- 1629
function Play.prototype.requestRoom(self, key, reason) -- 1695
	if self.wantRoom ~= "" then -- 1695
		return -- 1699
	end -- 1699
	self.wantRoom = key -- 1701
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1702
end -- 1695
function Play.prototype.checkCarryGate(self) -- 1709
	if self.room.key == "checkpoint" then -- 1709
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 1709
			self.carryCartAxle = self.cartAxle -- 1712
			self.carryCartDocked = self.cartDocked -- 1713
			self:requestRoom("gate", "检查站出口") -- 1714
			self:flashSet("出检查站 · 城门", 1.2) -- 1715
		end -- 1715
		return -- 1717
	end -- 1717
	if self.room.key == "outside" then -- 1717
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1717
			self.carryCartAxle = self.cartAxle -- 1723
			self.carryCartDocked = self.cartDocked -- 1724
			self:requestRoom("village", "墙根走完") -- 1725
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1726
		end -- 1726
	end -- 1726
end -- 1709
function Play.prototype.aimAt(self, wx, wy) -- 1733
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1734
	self.aimX = s.x -- 1735
	self.aimY = s.y -- 1736
end -- 1733
function Play.prototype.shoot(self, a) -- 1739
	local ox = a.x + a.facing * 8 -- 1740
	local oy = a.y + a.h * 0.72 -- 1741
	local aim = ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1743
	local dx = aim.x - ox -- 1744
	local dy = aim.y - oy -- 1745
	local len = math.sqrt(dx * dx + dy * dy) -- 1746
	if len < 0.001 then -- 1746
		dx = a.facing -- 1748
		dy = 0 -- 1749
	else -- 1749
		dx = dx / len -- 1751
		dy = dy / len -- 1752
	end -- 1752
	if dx ~= 0 then -- 1752
		a.facing = dx > 0 and 1 or -1 -- 1755
	end -- 1755
	local hitEnemy = self:raycast( -- 1758
		ox, -- 1758
		oy, -- 1758
		dx, -- 1758
		dy, -- 1758
		true -- 1758
	) -- 1758
	local hitWall = self:raycast( -- 1759
		ox, -- 1759
		oy, -- 1759
		dx, -- 1759
		dy, -- 1759
		false -- 1759
	) -- 1759
	local tEnemy = hitEnemy.t -- 1760
	local tWall = hitWall.t -- 1761
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1762
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1763
	self.trace = { -- 1765
		x0 = ox, -- 1765
		y0 = oy, -- 1765
		x1 = ox + dx * t, -- 1765
		y1 = oy + dy * t, -- 1765
		hit = hit -- 1765
	} -- 1765
	self.traceT = 0.12 -- 1766
	self:applyFireDanger(ox) -- 1767
	if hit then -- 1767
		local i = hitEnemy.index -- 1769
		local e = self.enemies[i + 1] -- 1770
		e.alive = false -- 1771
		e.hitT = 0.4 -- 1772
		self:flashSet("命中", 0.6) -- 1773
	else -- 1773
		self:flashSet("打空", 0.35) -- 1775
	end -- 1775
	self:emit("shotResolved", { -- 1777
		hit = hit, -- 1778
		enemyIndex = hit and hitEnemy.index or -1, -- 1779
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1780
		aimX = aim.x, -- 1781
		aimY = aim.y, -- 1782
		impactX = ox + dx * t, -- 1783
		impactY = oy + dy * t -- 1784
	}) -- 1784
end -- 1739
function Play.prototype.applyFireDanger(self, shotX) -- 1789
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1789
		return -- 1791
	end -- 1791
	local dangerX = shotX -- 1793
	local best = -1 -- 1794
	local bestD = 1000000000 -- 1795
	local i = 0 -- 1796
	do -- 1796
		i = 0 -- 1797
		while i < #self.enemies do -- 1797
			do -- 1797
				local e = self.enemies[i + 1] -- 1798
				if not e.alive then -- 1798
					goto __continue299 -- 1800
				end -- 1800
				local d = math.abs(e.x - self.partner.x) -- 1802
				if d < bestD then -- 1802
					bestD = d -- 1804
					best = i -- 1805
				end -- 1805
			end -- 1805
			::__continue299:: -- 1805
			i = i + 1 -- 1797
		end -- 1797
	end -- 1797
	if best >= 0 then -- 1797
		dangerX = self.enemies[best + 1].x -- 1809
	end -- 1809
	local exposed = self:childExposed(dangerX) -- 1811
	local before = self.escort.fear -- 1812
	local dangerId = self.nextDangerId -- 1813
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1814
	self.nextDangerId = self.nextDangerId + 1 -- 1815
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1816
	if after > before then -- 1816
		self:flashSet( -- 1818
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1818
			1 -- 1818
		) -- 1818
	elseif not exposed then -- 1818
		self:flashSet("枪声没够到她", 0.5) -- 1820
	end -- 1820
end -- 1789
function Play.prototype.childExposed(self, dangerX) -- 1825
	local c = self.partner -- 1826
	if not c.alive then -- 1826
		return false -- 1828
	end -- 1828
	if c.x > self.ox + 240 and c.x < self.ox + 340 then -- 1828
		return false -- 1831
	end -- 1831
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1831
		return false -- 1834
	end -- 1834
	local toDanger = dangerX - c.x -- 1836
	local toPlayer = self.player.x - c.x -- 1837
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) then -- 1837
		return false -- 1839
	end -- 1839
	return true -- 1841
end -- 1825
function Play.prototype.raycast(self, ox, oy, dx, dy, enemies) -- 1845
	local best = -1 -- 1846
	local bestI = -1 -- 1847
	local i = 0 -- 1848
	if enemies then -- 1848
		do -- 1848
			i = 0 -- 1850
			while i < #self.enemies do -- 1850
				do -- 1850
					local e = self.enemies[i + 1] -- 1851
					if not e.alive then -- 1851
						goto __continue313 -- 1853
					end -- 1853
					local t = hitBox( -- 1855
						ox, -- 1855
						oy, -- 1855
						dx, -- 1855
						dy, -- 1855
						e.x - e.w / 2, -- 1855
						e.x + e.w / 2, -- 1855
						e.y, -- 1855
						e.y + e.h -- 1855
					) -- 1855
					if t >= 0 and (best < 0 or t < best) then -- 1855
						best = t -- 1857
						bestI = i -- 1858
					end -- 1858
				end -- 1858
				::__continue313:: -- 1858
				i = i + 1 -- 1850
			end -- 1850
		end -- 1850
		return {t = best, index = bestI} -- 1861
	end -- 1861
	do -- 1861
		i = 0 -- 1863
		while i < #self.boxes do -- 1863
			local b = self.boxes[i + 1] -- 1864
			local t = hitBox( -- 1865
				ox, -- 1865
				oy, -- 1865
				dx, -- 1865
				dy, -- 1865
				b.x0, -- 1865
				b.x1, -- 1865
				b.y0, -- 1865
				b.y1 -- 1865
			) -- 1865
			if t >= 0 and (best < 0 or t < best) then -- 1865
				best = t -- 1867
			end -- 1867
			i = i + 1 -- 1863
		end -- 1863
	end -- 1863
	if dy < 0 then -- 1863
		local t = (0 - oy) / dy -- 1872
		if t >= 0 and (best < 0 or t < best) then -- 1872
			best = t -- 1874
		end -- 1874
	end -- 1874
	return {t = best, index = -1} -- 1877
end -- 1845
function Play.prototype.slideX(self, a, dx) -- 1881
	local nx = a.x + dx -- 1882
	local half = a.w / 2 -- 1883
	local room = self.room -- 1884
	nx = math.max( -- 1885
		room.minX + half, -- 1885
		math.min(room.maxX - half, nx) -- 1885
	) -- 1885
	local i = 0 -- 1886
	do -- 1886
		i = 0 -- 1887
		while i < #self.boxes do -- 1887
			do -- 1887
				local b = self.boxes[i + 1] -- 1888
				if b.passable == true then -- 1888
					goto __continue323 -- 1890
				end -- 1890
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1890
					goto __continue323 -- 1893
				end -- 1893
				if nx + half > b.x0 and nx - half < b.x1 then -- 1893
					if a.x <= b.x0 then -- 1893
						nx = b.x0 - half -- 1897
					elseif a.x >= b.x1 then -- 1897
						nx = b.x1 + half -- 1899
					else -- 1899
						nx = a.x -- 1901
					end -- 1901
				end -- 1901
			end -- 1901
			::__continue323:: -- 1901
			i = i + 1 -- 1887
		end -- 1887
	end -- 1887
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 1887
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 1909
		local bx0 = self.cartAxle - CART_HALF -- 1910
		local bx1 = self.cartAxle + CART_HALF -- 1911
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 1911
			if a.x <= bx0 then -- 1911
				nx = bx0 - half -- 1914
			elseif a.x >= bx1 then -- 1914
				nx = bx1 + half -- 1916
			else -- 1916
				nx = a.x -- 1918
			end -- 1918
		end -- 1918
	end -- 1918
	local arch = room.arch -- 1926
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 1926
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 1928
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 1928
			if a.x <= arch.x0 then -- 1928
				nx = arch.x0 - half -- 1931
			elseif a.x >= arch.x1 then -- 1931
				nx = arch.x1 + half -- 1933
			end -- 1933
		end -- 1933
	end -- 1933
	a.x = nx -- 1937
end -- 1881
function Play.prototype.fallY(self, a, dt) -- 1941
	a.vy = a.vy - ____exports.GRAVITY * dt -- 1942
	if a.vy < -900 then -- 1942
		a.vy = -900 -- 1944
	end -- 1944
	local ny = a.y + a.vy * dt -- 1946
	local half = a.w / 2 -- 1947
	if a.vy <= 0 then -- 1947
		local reach = a.onGround and STEP_UP or 0 -- 1950
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half) -- 1951
		if ny <= ground then -- 1951
			ny = ground -- 1953
			a.vy = 0 -- 1954
			a.onGround = true -- 1955
		else -- 1955
			a.onGround = false -- 1957
		end -- 1957
	else -- 1957
		a.onGround = false -- 1960
		local i = 0 -- 1961
		do -- 1961
			i = 0 -- 1962
			while i < #self.boxes do -- 1962
				do -- 1962
					local b = self.boxes[i + 1] -- 1963
					if b.passable == true then -- 1963
						goto __continue346 -- 1965
					end -- 1965
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 1965
						goto __continue346 -- 1968
					end -- 1968
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 1968
						ny = b.y0 - a.h -- 1971
						a.vy = 0 -- 1972
					end -- 1972
				end -- 1972
				::__continue346:: -- 1972
				i = i + 1 -- 1962
			end -- 1962
		end -- 1962
	end -- 1962
	a.y = ny -- 1976
end -- 1941
function Play.prototype.groundAt(self, x, ceiling, half) -- 1980
	local g = -9999 -- 1981
	local i = 0 -- 1982
	do -- 1982
		i = 0 -- 1983
		while i < #self.floors do -- 1983
			local f = self.floors[i + 1] -- 1984
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 1984
				g = f.y1 -- 1986
			end -- 1986
			i = i + 1 -- 1983
		end -- 1983
	end -- 1983
	do -- 1983
		i = 0 -- 1989
		while i < #self.boxes do -- 1989
			local b = self.boxes[i + 1] -- 1990
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g then -- 1990
				g = b.y1 -- 1992
			end -- 1992
			i = i + 1 -- 1989
		end -- 1989
	end -- 1989
	return g -- 1995
end -- 1980
function Play.prototype.updateCamera(self, dt) -- 1998
	local p = self.player -- 1999
	local tx = p.x + p.facing * 30 -- 2000
	local ty = p.y + CAM_LOOK_UP -- 2001
	local k = math.min(1, CAM_FOLLOW * dt) -- 2002
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2003
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2004
end -- 1998
function Play.prototype.clampCamera(self, w, h) -- 2008
	local room = self.room -- 2009
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2010
	local spanX = room.maxX - room.minX -- 2011
	if spanX <= halfW * 2 then -- 2011
		self.cam.x = (room.minX + room.maxX) / 2 -- 2013
	else -- 2013
		self.cam.x = math.max( -- 2015
			room.minX + halfW, -- 2015
			math.min(room.maxX - halfW, self.cam.x) -- 2015
		) -- 2015
	end -- 2015
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 2018
	local spanY = room.height -- 2019
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 2020
	if spanY <= halfH * 2 then -- 2020
		self.cam.y = camY -- 2022
	else -- 2022
		self.cam.y = math.max( -- 2024
			camY, -- 2024
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2024
		) -- 2024
	end -- 2024
end -- 2008
function Play.prototype.flashSet(self, text, t) -- 2028
	self.flash = text -- 2029
	self.flashT = t -- 2030
end -- 2028
function Play.prototype.statusText(self) -- 2034
	local p = self.player -- 2035
	local parts = {} -- 2036
	local who = self.childMode and "小满" or "周戍" -- 2037
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2038
	if self.room.key == "prologue" then -- 2038
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2041
		if self.phase == "prologue-wait" then -- 2041
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2043
		elseif self.phase == "prologue-give" then -- 2043
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2045
		else -- 2045
			parts[#parts + 1] = "跟随" -- 2047
		end -- 2047
		if self.paused then -- 2047
			parts[#parts + 1] = "已暂停" -- 2050
		end -- 2050
		return table.concat(parts, " · ") -- 2052
	end -- 2052
	if self.room.key == "street" then -- 2052
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2055
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2056
		if self.paused then -- 2056
			parts[#parts + 1] = "已暂停" -- 2058
		end -- 2058
		return table.concat(parts, " · ") -- 2060
	end -- 2060
	if self.room.key == "gate" then -- 2060
		local ____temp_13 -- 2063
		if self.room.story == nil then -- 2063
			____temp_13 = nil -- 2063
		else -- 2063
			____temp_13 = self.room.story.gate -- 2063
		end -- 2063
		local g = ____temp_13 -- 2063
		if g ~= nil then -- 2063
			parts[#parts + 1] = self:gateLabel() -- 2065
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2066
				0, -- 2067
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2067
			))) .. " 秒" -- 2067
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2068
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2069
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2070
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2071
			if self.gateFailCount > 0 then -- 2071
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2073
			end -- 2073
			if self.flash ~= "" then -- 2073
				parts[#parts + 1] = self.flash -- 2076
			end -- 2076
		end -- 2076
		if self.paused then -- 2076
			parts[#parts + 1] = "已暂停" -- 2080
		end -- 2080
		return table.concat(parts, " · ") -- 2082
	end -- 2082
	if self.room.key == "forest" then -- 2082
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2085
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2086
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2087
		if self.caughtT > 0 then -- 2087
			parts[#parts + 1] = "复位中" -- 2089
		end -- 2089
		if self.paused then -- 2089
			parts[#parts + 1] = "已暂停" -- 2092
		end -- 2092
		return table.concat(parts, " · ") -- 2094
	end -- 2094
	if self.room.key == "tower" then -- 2094
		if self.phase == "tower-wait" then -- 2094
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2098
		elseif self.phase == "tower-knock" then -- 2098
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2100
		elseif self.phase == "tower-given" then -- 2100
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2102
		else -- 2102
			parts[#parts + 1] = "片尾" -- 2104
		end -- 2104
		if self.paused then -- 2104
			parts[#parts + 1] = "已暂停" -- 2107
		end -- 2107
		return table.concat(parts, " · ") -- 2109
	end -- 2109
	if self.room.key == "village" then -- 2109
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2112
		if self.hasBottle then -- 2112
			parts[#parts + 1] = "有瓶" -- 2114
		elseif self.bottleFly ~= nil then -- 2114
			parts[#parts + 1] = "瓶在飞" -- 2116
		else -- 2116
			parts[#parts + 1] = "空手" -- 2118
		end -- 2118
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2120
		if self.scavChase then -- 2120
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2122
		end -- 2122
		if self.passed then -- 2122
			parts[#parts + 1] = "已过通行线" -- 2125
		end -- 2125
		if self.paused then -- 2125
			parts[#parts + 1] = "已暂停" -- 2128
		end -- 2128
		return table.concat(parts, " · ") -- 2130
	end -- 2130
	local isChild = self.childMode -- 2133
	if isChild then -- 2133
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2135
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2136
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2137
	else -- 2137
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2139
		if p.rollT > 0 then -- 2139
			parts[#parts + 1] = "翻滚中" -- 2141
		end -- 2141
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2143
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2144
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2145
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2146
	end -- 2146
	if self.checkpoint >= 0 then -- 2146
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2149
	end -- 2149
	if self.paused then -- 2149
		parts[#parts + 1] = "已暂停" -- 2152
	end -- 2152
	return table.concat(parts, " · ") -- 2154
end -- 2034
function Play.prototype.aliveEnemies(self) -- 2158
	local n = 0 -- 2159
	local i = 0 -- 2160
	do -- 2160
		i = 0 -- 2161
		while i < #self.enemies do -- 2161
			if self.enemies[i + 1].alive then -- 2161
				n = n + 1 -- 2163
			end -- 2163
			i = i + 1 -- 2161
		end -- 2161
	end -- 2161
	return n -- 2166
end -- 2158
function Play.prototype.threatened(self) -- 2171
	do -- 2171
		local i = 0 -- 2172
		while i < #self.enemies do -- 2172
			local e = self.enemies[i + 1] -- 2173
			if e.alive and e.warnT > 0 then -- 2173
				return true -- 2175
			end -- 2175
			i = i + 1 -- 2172
		end -- 2172
	end -- 2172
	return false -- 2178
end -- 2171
function Play.prototype.gateSecondsLeft(self) -- 2181
	local ____temp_14 -- 2182
	if self.room.story == nil then -- 2182
		____temp_14 = nil -- 2182
	else -- 2182
		____temp_14 = self.room.story.gate -- 2182
	end -- 2182
	local g = ____temp_14 -- 2182
	if g == nil then -- 2182
		return 0 -- 2184
	end -- 2184
	return math.max( -- 2186
		0, -- 2186
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2186
	) -- 2186
end -- 2181
function Play.prototype.gateLabel(self) -- 2189
	if self.phase == "gate-idle" then -- 2189
		return "待就位" -- 2191
	end -- 2191
	if self.phase == "gate-hold" then -- 2191
		return "守点中" -- 2194
	end -- 2194
	if self.phase == "gate-send" then -- 2194
		return "送别" -- 2197
	end -- 2197
	if self.phase == "gate-count" then -- 2197
		return "数数 " .. tostring(self.countTick) -- 2200
	end -- 2200
	return "她走" -- 2202
end -- 2189
function Play.prototype.dogLabel(self) -- 2206
	if self.dogState == "ear" then -- 2206
		return "转耳" -- 2208
	end -- 2208
	if self.dogState == "chase" then -- 2208
		return "追" -- 2211
	end -- 2211
	if self.dogState == "sniff" then -- 2211
		return "停" -- 2214
	end -- 2214
	if self.dogState == "back" then -- 2214
		return "回线" -- 2217
	end -- 2217
	return "巡逻" -- 2219
end -- 2206
function Play.prototype.doorXOf(self) -- 2222
	local ____temp_15 -- 2223
	if self.room.story == nil then -- 2223
		____temp_15 = nil -- 2223
	else -- 2223
		____temp_15 = self.room.story.tower -- 2223
	end -- 2223
	local t = ____temp_15 -- 2223
	return t == nil and 0 or t.doorX -- 2224
end -- 2222
function Play.prototype.scavLabel(self) -- 2228
	if self.scavState == "chase" then -- 2228
		return "追" -- 2230
	end -- 2230
	if self.scavState == "turn" then -- 2230
		return "转头" -- 2233
	end -- 2233
	if self.scavState == "walk" then -- 2233
		return "赶来" -- 2236
	end -- 2236
	if self.scavState == "stall" then -- 2236
		return "停住" -- 2239
	end -- 2239
	if self.scavState == "back" then -- 2239
		return "回位" -- 2242
	end -- 2242
	return "巡逻" -- 2244
end -- 2228
function Play.prototype.hintText(self) -- 2248
	if self.paused then -- 2248
		return "Esc 继续 · R 重置" -- 2250
	end -- 2250
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2250
		if self:threatened() then -- 2250
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2256
		end -- 2256
		if self.coverHug then -- 2256
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2259
		end -- 2259
		if self.coverNear then -- 2259
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2262
		end -- 2262
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2264
	end -- 2264
	if self.flash ~= "" then -- 2264
		return self.flash -- 2267
	end -- 2267
	if self.room.key == "prologue" then -- 2267
		if self.phase == "prologue-wait" then -- 2267
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2271
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2272
		end -- 2272
		if self.phase == "prologue-give" then -- 2272
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2275
		end -- 2275
		return "她跟着你了 · 两人一起走到门口 680" -- 2277
	end -- 2277
	if self.room.key == "street" then -- 2277
		if self:aliveEnemies() > 0 then -- 2277
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2281
		end -- 2281
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2283
	end -- 2283
	if self.room.key == "gate" then -- 2283
		local ____temp_16 -- 2286
		if self.room.story == nil then -- 2286
			____temp_16 = nil -- 2286
		else -- 2286
			____temp_16 = self.room.story.gate -- 2286
		end -- 2286
		local g = ____temp_16 -- 2286
		if g ~= nil then -- 2286
			if self.phase == "gate-idle" then -- 2286
				if self.gateNeedConfirm then -- 2286
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2290
				end -- 2290
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2292
			end -- 2292
			if self.phase == "gate-hold" then -- 2292
				if self.coveredFlash > 0 then -- 2292
					return "掩体挡下了这一枪 · 别露头" -- 2296
				end -- 2296
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2298
			end -- 2298
			if self.phase == "gate-send" then -- 2298
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2301
			end -- 2301
			if self.phase == "gate-count" then -- 2301
				if self.countTick >= 1440 then -- 2301
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2305
				end -- 2305
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2307
			end -- 2307
			return "她自己走 · 跟着出城门 1120" -- 2309
		end -- 2309
	end -- 2309
	if self.room.key == "forest" then -- 2309
		if self.dogState == "chase" then -- 2309
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2314
		end -- 2314
		if self.dogState == "ear" then -- 2314
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2317
		end -- 2317
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2319
	end -- 2319
	if self.room.key == "tower" then -- 2319
		if self.phase == "tower-wait" then -- 2319
			return "走到门前 445 点一次 E 敲两下" -- 2323
		end -- 2323
		if self.phase == "tower-knock" then -- 2323
			return "敲两下 · 等门开" -- 2326
		end -- 2326
		if self.phase == "tower-given" then -- 2326
			return "递交针套和纸条 · 看登记簿最后一行" -- 2329
		end -- 2329
		return "片尾 · 点 E 再玩一次，回到序章" -- 2331
	end -- 2331
	if self.room.key == "village" then -- 2331
		if self.bottleFly ~= nil then -- 2331
			return "等瓶子落地 · 触地才发声" -- 2335
		end -- 2335
		if self.hasBottle then -- 2335
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2338
		end -- 2338
		if self.passed then -- 2338
			return "已过第一院 · R 重置可再来一遍" -- 2341
		end -- 2341
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2343
	end -- 2343
	if self.room.key == "outside" then -- 2343
		if self.focusCart then -- 2343
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2347
		end -- 2347
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2349
	end -- 2349
	if self.escort.state == "frozen" then -- 2349
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2349
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2353
		end -- 2353
		return "小满吓住了 · 走过去，靠近再点 E" -- 2355
	end -- 2355
	if self.escort.state == "calming" then -- 2355
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2358
	end -- 2358
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2360
end -- 2248
function Play.prototype.draw(self, draw, w, h) -- 2365
	self.viewW = w -- 2366
	self.viewH = h -- 2367
	self.view = ____exports.computeViewport(w, h) -- 2368
	self:clampCamera(w, h) -- 2369
	draw:clear() -- 2370
	draw:drawRect( -- 2372
		Rect(0, 0, w, h), -- 2372
		BG_VOID -- 2372
	) -- 2372
	local box = self:canvasRect(w, h) -- 2373
	draw:drawRect(box, BG_FAR) -- 2374
	draw:drawRect( -- 2375
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2375
		BG_MID -- 2375
	) -- 2375
	self:drawFloors(draw, w, h) -- 2377
	self:drawSolids(draw, w, h) -- 2378
	self:drawZones(draw, w, h) -- 2379
	self:drawArch(draw, w, h) -- 2380
	self:drawCart(draw, w, h) -- 2381
	self:drawActors(draw, w, h) -- 2382
	self:drawTrace(draw, w, h) -- 2383
	self:drawAim(draw, w, h) -- 2384
end -- 2365
function Play.prototype.canvasRect(self, w, h) -- 2388
	local v = self.view -- 2389
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2390
end -- 2388
function Play.prototype.px(self, n) -- 2394
	return n * self.view.zoom -- 2395
end -- 2394
function Play.prototype.sx(self, wx, w) -- 2399
	local v = self.view -- 2400
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2401
	return v.ox + lx * v.zoom -- 2402
end -- 2399
function Play.prototype.sy(self, wy, h) -- 2406
	local v = self.view -- 2407
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2408
	return v.oy + ly * v.zoom -- 2409
end -- 2406
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2412
	local px0 = self:sx(x0, w) -- 2413
	local px1 = self:sx(x1, w) -- 2414
	local py0 = self:sy(y0, h) -- 2415
	local py1 = self:sy(y1, h) -- 2416
	if px1 <= px0 or py1 <= py0 then -- 2416
		return -- 2418
	end -- 2418
	draw:drawRect( -- 2420
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2420
		color -- 2420
	) -- 2420
end -- 2412
function Play.prototype.drawFloors(self, draw, w, h) -- 2423
	local i = 0 -- 2424
	do -- 2424
		i = 0 -- 2425
		while i < #self.room.floors do -- 2425
			local f = self.room.floors[i + 1] -- 2426
			local y = self:sy(f.y, h) -- 2427
			local x0 = self:sx(f.x0, w) -- 2428
			local x1 = self:sx(f.x1, w) -- 2429
			local deck = self:px(5) -- 2430
			draw:drawRect( -- 2431
				Rect(x0, y - deck, x1 - x0, deck), -- 2431
				FLOOR_DECK -- 2431
			) -- 2431
			draw:drawSegment( -- 2432
				Vec2(x0, y), -- 2432
				Vec2(x1, y), -- 2432
				self:px(1), -- 2432
				GROUND -- 2432
			) -- 2432
			i = i + 1 -- 2425
		end -- 2425
	end -- 2425
end -- 2423
function Play.prototype.drawSolids(self, draw, w, h) -- 2436
	local i = 0 -- 2437
	do -- 2437
		i = 0 -- 2438
		while i < #self.boxes do -- 2438
			do -- 2438
				local b = self.boxes[i + 1] -- 2439
				if b.y0 < -4 and b.y1 <= 96 then -- 2439
					draw:drawSegment( -- 2442
						Vec2( -- 2442
							self:sx(b.x0, w), -- 2442
							self:sy(b.y1, h) -- 2442
						), -- 2442
						Vec2( -- 2442
							self:sx(b.x1, w), -- 2442
							self:sy(b.y1, h) -- 2442
						), -- 2442
						self:px(1), -- 2442
						GROUND -- 2442
					) -- 2442
					goto __continue474 -- 2443
				end -- 2443
				self:drawBox( -- 2445
					draw, -- 2445
					w, -- 2445
					h, -- 2445
					b.x0, -- 2445
					b.x1, -- 2445
					b.y0, -- 2445
					b.y1, -- 2445
					SOLID_FILL -- 2445
				) -- 2445
				draw:drawSegment( -- 2446
					Vec2( -- 2446
						self:sx(b.x0, w), -- 2446
						self:sy(b.y1, h) -- 2446
					), -- 2446
					Vec2( -- 2446
						self:sx(b.x1, w), -- 2446
						self:sy(b.y1, h) -- 2446
					), -- 2446
					self:px(1), -- 2446
					SOLID_EDGE -- 2446
				) -- 2446
			end -- 2446
			::__continue474:: -- 2446
			i = i + 1 -- 2438
		end -- 2438
	end -- 2438
end -- 2436
function Play.prototype.drawZones(self, draw, w, h) -- 2450
	local i = 0 -- 2451
	do -- 2451
		i = 0 -- 2452
		while i < #self.room.zones do -- 2452
			local z = self.room.zones[i + 1] -- 2453
			local fill = DANGER -- 2454
			local line = DANGER_LINE -- 2455
			if z.tint == 2 then -- 2455
				fill = SOFT -- 2457
				line = SOFT_LINE -- 2458
			elseif z.tint == 3 then -- 2458
				fill = BRICK -- 2460
				line = BRICK_LINE -- 2461
			elseif z.tint == 4 then -- 2461
				fill = PASS -- 2463
				line = PASS_LINE -- 2464
			end -- 2464
			self:drawBox( -- 2466
				draw, -- 2466
				w, -- 2466
				h, -- 2466
				z.x0, -- 2466
				z.x1, -- 2466
				z.y, -- 2466
				z.y + z.h, -- 2466
				fill -- 2466
			) -- 2466
			draw:drawSegment( -- 2467
				Vec2( -- 2467
					self:sx(z.x0, w), -- 2467
					self:sy(z.y, h) -- 2467
				), -- 2467
				Vec2( -- 2467
					self:sx(z.x0, w), -- 2467
					self:sy(z.y + z.h, h) -- 2467
				), -- 2467
				self:px(1), -- 2467
				line -- 2467
			) -- 2467
			draw:drawSegment( -- 2468
				Vec2( -- 2468
					self:sx(z.x1, w), -- 2468
					self:sy(z.y, h) -- 2468
				), -- 2468
				Vec2( -- 2468
					self:sx(z.x1, w), -- 2468
					self:sy(z.y + z.h, h) -- 2468
				), -- 2468
				self:px(1), -- 2468
				line -- 2468
			) -- 2468
			i = i + 1 -- 2452
		end -- 2452
	end -- 2452
end -- 2450
function Play.prototype.drawArch(self, draw, w, h) -- 2472
	local a = self.room.arch -- 2473
	if a.h <= 0 then -- 2473
		return -- 2475
	end -- 2475
	self:drawBox( -- 2477
		draw, -- 2477
		w, -- 2477
		h, -- 2477
		a.x0, -- 2477
		a.x1, -- 2477
		a.y, -- 2477
		a.y + a.h, -- 2477
		HOLE_FILL -- 2477
	) -- 2477
	draw:drawSegment( -- 2478
		Vec2( -- 2478
			self:sx(a.x0, w), -- 2478
			self:sy(a.y + a.h, h) -- 2478
		), -- 2478
		Vec2( -- 2478
			self:sx(a.x1, w), -- 2478
			self:sy(a.y + a.h, h) -- 2478
		), -- 2478
		self:px(1), -- 2478
		SOLID_EDGE -- 2478
	) -- 2478
	draw:drawSegment( -- 2479
		Vec2( -- 2479
			self:sx(a.x0, w), -- 2479
			self:sy(a.y, h) -- 2479
		), -- 2479
		Vec2( -- 2479
			self:sx(a.x0, w), -- 2479
			self:sy(a.y + a.h, h) -- 2479
		), -- 2479
		self:px(1), -- 2479
		SOLID_EDGE -- 2479
	) -- 2479
	draw:drawSegment( -- 2480
		Vec2( -- 2480
			self:sx(a.x1, w), -- 2480
			self:sy(a.y, h) -- 2480
		), -- 2480
		Vec2( -- 2480
			self:sx(a.x1, w), -- 2480
			self:sy(a.y + a.h, h) -- 2480
		), -- 2480
		self:px(1), -- 2480
		SOLID_EDGE -- 2480
	) -- 2480
end -- 2472
function Play.prototype.drawCart(self, draw, w, h) -- 2483
	local c = self.room.cart -- 2484
	if c.bodyW <= 0 then -- 2484
		return -- 2486
	end -- 2486
	drawCartShape( -- 2488
		draw, -- 2488
		self, -- 2488
		w, -- 2488
		h, -- 2488
		c, -- 2488
		self.cartAxle -- 2488
	) -- 2488
	draw:drawRect( -- 2489
		Rect( -- 2489
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2489
			self:sy(c.baseY + 40, h), -- 2489
			self:px(2), -- 2489
			self:px(40) -- 2489
		), -- 2489
		STAND -- 2489
	) -- 2489
end -- 2483
function Play.prototype.drawActors(self, draw, w, h) -- 2492
	local p = self.player -- 2493
	local isChild = self.childMode -- 2494
	if p.covered then -- 2494
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2497
		draw:drawSegment( -- 2498
			Vec2( -- 2498
				self:sx(edge, w), -- 2498
				self:sy(p.y + 8, h) -- 2498
			), -- 2498
			Vec2( -- 2498
				self:sx(edge, w), -- 2498
				self:sy(p.y + p.h * 0.62, h) -- 2498
			), -- 2498
			self:px(2), -- 2498
			STAND -- 2498
		) -- 2498
		draw:drawSegment( -- 2500
			Vec2( -- 2500
				self:sx(p.x - 8, w), -- 2500
				self:sy(p.y + p.h + 3, h) -- 2500
			), -- 2500
			Vec2( -- 2500
				self:sx(p.x + 8, w), -- 2500
				self:sy(p.y + p.h + 3, h) -- 2500
			), -- 2500
			self:px(2), -- 2500
			STAND -- 2500
		) -- 2500
	elseif self.coverNear and not isChild then -- 2500
		draw:drawRect( -- 2503
			Rect( -- 2503
				self:sx(p.x - 3, w), -- 2503
				self:sy(p.y + 1, h), -- 2503
				self:px(3), -- 2503
				self:px(3) -- 2503
			), -- 2503
			STAND -- 2503
		) -- 2503
	end -- 2503
	drawFigure( -- 2505
		draw, -- 2505
		self, -- 2505
		w, -- 2505
		h, -- 2505
		p, -- 2505
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2505
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2505
	) -- 2505
	local q = self.partner -- 2506
	if q.alive then -- 2506
		local childPartner = q.w == CHILD_W -- 2508
		drawFigure( -- 2509
			draw, -- 2509
			self, -- 2509
			w, -- 2509
			h, -- 2509
			q, -- 2509
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2509
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2509
		) -- 2509
	end -- 2509
	local i = 0 -- 2511
	do -- 2511
		i = 0 -- 2512
		while i < #self.enemies do -- 2512
			local e = self.enemies[i + 1] -- 2513
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2514
			self:drawBox( -- 2515
				draw, -- 2515
				w, -- 2515
				h, -- 2515
				e.x - e.w / 2, -- 2515
				e.x + e.w / 2, -- 2515
				e.y, -- 2515
				e.y + e.h, -- 2515
				col -- 2515
			) -- 2515
			if e.alive and e.warnT > 0 then -- 2515
				local gunX = self:sx(e.x, w) -- 2518
				local gunY = self:sy(e.y + e.h * 0.72, h) -- 2519
				local aimX = self:sx(p.x, w) -- 2520
				local aimY = self:sy(p.y + p.h * 0.55, h) -- 2521
				local seg = 8 -- 2522
				local s = 0 -- 2523
				do -- 2523
					s = 0 -- 2524
					while s < seg do -- 2524
						local t0 = s / seg -- 2525
						local t1 = (s + 1) / seg -- 2526
						draw:drawSegment( -- 2527
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2528
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2529
							self:px(1), -- 2530
							DANGER -- 2530
						) -- 2530
						s = s + 2 -- 2524
					end -- 2524
				end -- 2524
			end -- 2524
			i = i + 1 -- 2512
		end -- 2512
	end -- 2512
	local k = 0 -- 2535
	do -- 2535
		k = 0 -- 2536
		while k < #self.room.marks do -- 2536
			do -- 2536
				local m = self.room.marks[k + 1] -- 2537
				if m.kind ~= 0 then -- 2537
					goto __continue496 -- 2539
				end -- 2539
				local on = self.checkpoint == m.x -- 2541
				local x = self:sx(m.x, w) -- 2542
				local y = self:sy(m.y, h) -- 2543
				draw:drawSegment( -- 2544
					Vec2(x, y), -- 2544
					Vec2( -- 2544
						x, -- 2544
						y + self:px(35) -- 2544
					), -- 2544
					self:px(1), -- 2544
					on and CHECK or INK_DIM -- 2544
				) -- 2544
				draw:drawDot( -- 2545
					Vec2( -- 2545
						x, -- 2545
						y + self:px(35) -- 2545
					), -- 2545
					self:px(2), -- 2545
					on and CHECK or INK_DIM -- 2545
				) -- 2545
			end -- 2545
			::__continue496:: -- 2545
			k = k + 1 -- 2536
		end -- 2536
	end -- 2536
	local j = 0 -- 2549
	do -- 2549
		j = 0 -- 2550
		while j < #self.room.marks do -- 2550
			do -- 2550
				local m = self.room.marks[j + 1] -- 2551
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2551
					goto __continue499 -- 2553
				end -- 2553
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2553
					goto __continue499 -- 2557
				end -- 2557
				local col = STAND -- 2559
				if m.kind == 4 then -- 2559
					col = PASS_LINE -- 2561
				elseif m.kind == 5 then -- 2561
					col = BRICK_LINE -- 2563
				end -- 2563
				local mx = self:sx(m.x, w) -- 2565
				local my = self:sy(m.y, h) -- 2566
				draw:drawSegment( -- 2567
					Vec2(mx, my), -- 2567
					Vec2( -- 2567
						mx, -- 2567
						my + self:px(24) -- 2567
					), -- 2567
					self:px(1), -- 2567
					col -- 2567
				) -- 2567
			end -- 2567
			::__continue499:: -- 2567
			j = j + 1 -- 2550
		end -- 2550
	end -- 2550
	local t = 0 -- 2570
	do -- 2570
		t = 0 -- 2571
		while t < #self.room.marks do -- 2571
			do -- 2571
				local m = self.room.marks[t + 1] -- 2572
				if m.kind ~= 6 then -- 2572
					goto __continue505 -- 2574
				end -- 2574
				local mx = self:sx(m.x, w) -- 2576
				local my = self:sy(m.y, h) -- 2577
				draw:drawSegment( -- 2578
					Vec2(mx, my), -- 2578
					Vec2( -- 2578
						mx, -- 2578
						my + self:px(30) -- 2578
					), -- 2578
					self:px(1), -- 2578
					INK_DIM -- 2578
				) -- 2578
				self:drawBox( -- 2579
					draw, -- 2579
					w, -- 2579
					h, -- 2579
					m.x - 5, -- 2579
					m.x + 5, -- 2579
					m.y + 30, -- 2579
					m.y + 40, -- 2579
					CHECK -- 2579
				) -- 2579
			end -- 2579
			::__continue505:: -- 2579
			t = t + 1 -- 2571
		end -- 2571
	end -- 2571
	if self.room.key == "village" then -- 2571
		self:drawVillage(draw, w, h) -- 2582
	end -- 2582
	if self.room.key == "forest" then -- 2582
		self:drawDog(draw, w, h) -- 2585
	end -- 2585
end -- 2492
function Play.prototype.drawDog(self, draw, w, h) -- 2590
	local x = self.dogX -- 2591
	self:drawBox( -- 2592
		draw, -- 2592
		w, -- 2592
		h, -- 2592
		x - 14, -- 2592
		x + 14, -- 2592
		0, -- 2592
		20, -- 2592
		SCAV_BODY -- 2592
	) -- 2592
	self:drawBox( -- 2593
		draw, -- 2593
		w, -- 2593
		h, -- 2593
		x - 10, -- 2593
		x - 2, -- 2593
		20, -- 2593
		30, -- 2593
		SCAV_BODY -- 2593
	) -- 2593
	self:drawBox( -- 2594
		draw, -- 2594
		w, -- 2594
		h, -- 2594
		x + 2, -- 2594
		x + 10, -- 2594
		20, -- 2594
		30, -- 2594
		SCAV_HEAD -- 2594
	) -- 2594
	if self.dogState == "ear" or self.dogState == "chase" then -- 2594
		draw:drawSegment( -- 2596
			Vec2( -- 2596
				self:sx(x, w), -- 2596
				self:sy(30, h) -- 2596
			), -- 2596
			Vec2( -- 2597
				self:sx(x, w), -- 2597
				self:sy(40, h) -- 2597
			), -- 2597
			self:px(1), -- 2597
			DANGER -- 2597
		) -- 2597
	end -- 2597
end -- 2590
function Play.prototype.drawVillage(self, draw, w, h) -- 2602
	local bottle = self.room.bottle -- 2603
	if bottle ~= nil then -- 2603
		self:drawBox( -- 2605
			draw, -- 2605
			w, -- 2605
			h, -- 2605
			bottle.x - 14, -- 2605
			bottle.x + 14, -- 2605
			0, -- 2605
			64, -- 2605
			SOLID_FILL -- 2605
		) -- 2605
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2605
			self:drawBottle( -- 2607
				draw, -- 2607
				w, -- 2607
				h, -- 2607
				bottle.x, -- 2607
				64 -- 2607
			) -- 2607
		end -- 2607
	end -- 2607
	self:drawBox( -- 2611
		draw, -- 2611
		w, -- 2611
		h, -- 2611
		300, -- 2611
		420, -- 2611
		44, -- 2611
		50, -- 2611
		FLOOR_DECK -- 2611
	) -- 2611
	self:drawBox( -- 2612
		draw, -- 2612
		w, -- 2612
		h, -- 2612
		300, -- 2612
		306, -- 2612
		0, -- 2612
		44, -- 2612
		FLOOR_DECK -- 2612
	) -- 2612
	self:drawBox( -- 2613
		draw, -- 2613
		w, -- 2613
		h, -- 2613
		414, -- 2613
		420, -- 2613
		0, -- 2613
		44, -- 2613
		FLOOR_DECK -- 2613
	) -- 2613
	local s = self.room.scavenger -- 2615
	if s ~= nil then -- 2615
		local sx0 = self.scavX -- 2617
		self:drawBox( -- 2618
			draw, -- 2618
			w, -- 2618
			h, -- 2618
			sx0 - 12, -- 2618
			sx0 + 12, -- 2618
			0, -- 2618
			s.h - 14, -- 2618
			SCAV_BODY -- 2618
		) -- 2618
		self:drawBox( -- 2619
			draw, -- 2619
			w, -- 2619
			h, -- 2619
			sx0 - 7, -- 2619
			sx0 + 7, -- 2619
			s.h - 14, -- 2619
			s.h, -- 2619
			SCAV_HEAD -- 2619
		) -- 2619
		if self.scavState == "turn" then -- 2619
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2621
			draw:drawSegment( -- 2622
				Vec2( -- 2622
					self:sx(sx0, w), -- 2622
					self:sy(s.h - 6, h) -- 2622
				), -- 2622
				Vec2( -- 2622
					self:sx(fx, w), -- 2622
					self:sy(s.h - 6, h) -- 2622
				), -- 2622
				self:px(1), -- 2622
				INK -- 2622
			) -- 2622
		end -- 2622
	end -- 2622
	if self.hasBottle then -- 2622
		local p = self.player -- 2627
		self:drawBottle( -- 2628
			draw, -- 2628
			w, -- 2628
			h, -- 2628
			p.x + p.facing * 10, -- 2628
			p.y + p.h * 0.62 -- 2628
		) -- 2628
	end -- 2628
	if self.bottleFly ~= nil then -- 2628
		self:drawBottle( -- 2631
			draw, -- 2631
			w, -- 2631
			h, -- 2631
			self.bottleFly.x, -- 2631
			self.bottleFly.y -- 2631
		) -- 2631
	end -- 2631
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2631
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2634
		draw:drawCircle( -- 2635
			Vec2( -- 2635
				self:sx(self.bottleLandX, w), -- 2635
				self:sy(0, h) -- 2635
			), -- 2635
			self:px(r / ____exports.UNITS_PER_PX), -- 2635
			BRICK_LINE -- 2635
		) -- 2635
	end -- 2635
end -- 2602
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2639
	self:drawBox( -- 2640
		draw, -- 2640
		w, -- 2640
		h, -- 2640
		x - 3, -- 2640
		x + 3, -- 2640
		y - 10, -- 2640
		y, -- 2640
		BOTTLE -- 2640
	) -- 2640
end -- 2639
function Play.prototype.drawTrace(self, draw, w, h) -- 2643
	local t = self.trace -- 2644
	if t == nil or self.traceT <= 0 then -- 2644
		return -- 2646
	end -- 2646
	draw:drawSegment( -- 2648
		Vec2( -- 2649
			self:sx(t.x0, w), -- 2649
			self:sy(t.y0, h) -- 2649
		), -- 2649
		Vec2( -- 2650
			self:sx(t.x1, w), -- 2650
			self:sy(t.y1, h) -- 2650
		), -- 2650
		self:px(1), -- 2651
		t.hit and AIM_HIT or INK_DIM -- 2651
	) -- 2651
end -- 2643
function Play.prototype.drawAim(self, draw, w, h) -- 2654
	local v = self.view -- 2656
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2657
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2658
	local dot = self:px(1) -- 2659
	local arm = self:px(3) -- 2660
	local gap = self:px(1) -- 2661
	draw:drawSegment( -- 2662
		Vec2(gx - arm - gap, gy), -- 2662
		Vec2(gx - gap, gy), -- 2662
		dot / 2, -- 2662
		AIM -- 2662
	) -- 2662
	draw:drawSegment( -- 2663
		Vec2(gx + gap, gy), -- 2663
		Vec2(gx + arm + gap, gy), -- 2663
		dot / 2, -- 2663
		AIM -- 2663
	) -- 2663
	draw:drawSegment( -- 2664
		Vec2(gx, gy - arm - gap), -- 2664
		Vec2(gx, gy - gap), -- 2664
		dot / 2, -- 2664
		AIM -- 2664
	) -- 2664
	draw:drawSegment( -- 2665
		Vec2(gx, gy + gap), -- 2665
		Vec2(gx, gy + arm + gap), -- 2665
		dot / 2, -- 2665
		AIM -- 2665
	) -- 2665
	if self.room.key == "village" and self.hasBottle then -- 2665
		local p = self.player -- 2669
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2671
		local dir = ____end.x >= p.x and 1 or -1 -- 2672
		local x0 = p.x + dir * 10 -- 2673
		local y0 = p.y + p.h * 0.7 -- 2674
		local T = BOTTLE_FLY_TIME -- 2675
		local vx = (____end.x - x0) / T -- 2676
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2677
		local pxr = x0 -- 2678
		local pyr = y0 -- 2679
		local t = 1 -- 2680
		do -- 2680
			t = 1 -- 2681
			while t <= 12 do -- 2681
				local tt = t / 12 * T -- 2682
				local nx = x0 + vx * tt -- 2683
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2684
				draw:drawSegment( -- 2685
					Vec2( -- 2685
						self:sx(pxr, w), -- 2685
						self:sy(pyr, h) -- 2685
					), -- 2685
					Vec2( -- 2685
						self:sx(nx, w), -- 2685
						self:sy(ny, h) -- 2685
					), -- 2685
					self:px(1) / 2, -- 2685
					BOTTLE -- 2685
				) -- 2685
				pxr = nx -- 2686
				pyr = ny -- 2687
				t = t + 1 -- 2681
			end -- 2681
		end -- 2681
		draw:drawCircle( -- 2689
			Vec2( -- 2689
				self:sx(____end.x, w), -- 2689
				self:sy(____end.y + 2, h) -- 2689
			), -- 2689
			self:px(2), -- 2689
			BOTTLE -- 2689
		) -- 2689
	end -- 2689
end -- 2654
return ____exports -- 2654