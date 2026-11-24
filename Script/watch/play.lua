-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
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
local ____depth = require("Script.watch.depth") -- 17
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 17
local adjacentLane = ____depth.adjacentLane -- 17
local inReachDepth = ____depth.inReachDepth -- 17
local nearestLane = ____depth.nearestLane -- 17
local overlapsDepth = ____depth.overlapsDepth -- 17
function makeActor(room, index) -- 2839
	local sp = room.spawns -- 2840
	if index < 0 or index >= #sp then -- 2840
		return { -- 2842
			x = 0, -- 2842
			y = 0, -- 2842
			depth = 0, -- 2842
			depthSpeed = 0, -- 2842
			vx = 0, -- 2842
			vy = 0, -- 2842
			w = CHILD_W, -- 2842
			h = CHILD_H, -- 2842
			onGround = true, -- 2842
			facing = 1, -- 2842
			crouch = false, -- 2842
			rollT = 0, -- 2842
			covered = false, -- 2842
			alive = false -- 2842
		} -- 2842
	end -- 2842
	local s = sp[index + 1] -- 2844
	local child = s.h <= CHILD_H -- 2845
	local ground = room.depth -- 2846
	local depth = ground == nil and 0 or nearestLane(s.depth or 0) -- 2847
	return { -- 2848
		x = s.x, -- 2849
		y = s.y, -- 2849
		depth = depth, -- 2849
		depthSpeed = 0, -- 2849
		vx = 0, -- 2849
		vy = 0, -- 2849
		w = child and CHILD_W or SOLDIER_W, -- 2850
		h = child and CHILD_H or SOLDIER_H, -- 2851
		onGround = true, -- 2852
		facing = 1, -- 2852
		crouch = false, -- 2852
		rollT = 0, -- 2852
		covered = false, -- 2852
		alive = true -- 2852
	} -- 2852
end -- 2852
function drawFigure(draw, play, w, h, a, body, head) -- 2856
	if not a.alive then -- 2856
		return -- 2858
	end -- 2858
	local x0 = a.x - a.w / 2 -- 2860
	local x1 = a.x + a.w / 2 -- 2861
	local y0 = a.y + a.depth -- 2862
	local y1 = y0 + a.h -- 2863
	play:drawBox( -- 2864
		draw, -- 2864
		w, -- 2864
		h, -- 2864
		x0, -- 2864
		x1, -- 2864
		y0, -- 2864
		y1 - a.h * 0.26, -- 2864
		body -- 2864
	) -- 2864
	play:drawBox( -- 2865
		draw, -- 2865
		w, -- 2865
		h, -- 2865
		x0 + 2, -- 2865
		x1 - 2, -- 2865
		y1 - a.h * 0.26, -- 2865
		y1, -- 2865
		head -- 2865
	) -- 2865
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 2867
	play:drawBox( -- 2868
		draw, -- 2868
		w, -- 2868
		h, -- 2868
		eyeX, -- 2868
		eyeX + 4, -- 2868
		y1 - a.h * 0.14, -- 2868
		y1 - a.h * 0.08, -- 2868
		INK -- 2868
	) -- 2868
end -- 2868
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 2872
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 2873
end -- 2872
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 2880
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 2881
end -- 2880
function rayInterval(origin, direction, min, max) -- 2888
	if direction == 0 then -- 2888
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 2890
	end -- 2890
	local a = (min - origin) / direction -- 2892
	local b = (max - origin) / direction -- 2893
	return { -- 2894
		min = math.min(a, b), -- 2894
		max = math.max(a, b) -- 2894
	} -- 2894
end -- 2894
function hitBox(ray, box) -- 2898
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 2899
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 2900
	local enter = math.max(0, x.min, y.min) -- 2901
	local leave = math.min(99999, x.max, y.max) -- 2902
	if box.depth ~= nil then -- 2902
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 2904
		enter = math.max(enter, depth.min) -- 2905
		leave = math.min(leave, depth.max) -- 2906
	end -- 2906
	return leave >= enter and enter or -1 -- 2908
end -- 2908
function drawCartShape(draw, play, w, h, c, axleX) -- 2911
	local half = c.bodyW / 2 -- 2912
	local x0 = axleX - half -- 2913
	local x1 = axleX + half -- 2914
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 2915
	play:drawBox( -- 2916
		draw, -- 2916
		w, -- 2916
		h, -- 2916
		x0, -- 2916
		x1, -- 2916
		axleY, -- 2916
		axleY + c.bodyH, -- 2916
		CART_FILL -- 2916
	) -- 2916
	draw:drawCircle( -- 2917
		Vec2( -- 2917
			play:sx(x0 + c.bodyW * 0.28, w), -- 2917
			play:sy(axleY, h) -- 2917
		), -- 2917
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2917
		Color(52, 50, 48, 255) -- 2917
	) -- 2917
	draw:drawCircle( -- 2918
		Vec2( -- 2918
			play:sx(x1 - c.bodyW * 0.28, w), -- 2918
			play:sy(axleY, h) -- 2918
		), -- 2918
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 2918
		Color(52, 50, 48, 255) -- 2918
	) -- 2918
	local cx = c.clothSide < 0 and x0 or x1 -- 2919
	play:drawBox( -- 2920
		draw, -- 2920
		w, -- 2920
		h, -- 2920
		cx - 10, -- 2920
		cx + 10, -- 2920
		axleY + c.bodyH, -- 2920
		axleY + c.bodyH + 18, -- 2920
		CLOTH -- 2920
	) -- 2920
end -- 2920
____exports.STEP = STEP -- 20
____exports.GRAVITY = 1000 -- 21
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 23
CHILD_W = 28 -- 53
CHILD_H = 64 -- 54
local CHILD_CROUCH_H = 36 -- 55
local CHILD_SPEED = 160 -- 56
local CHILD_SLOW = 80 -- 57
local CHILD_JUMP = 320 -- 58
SOLDIER_W = 30 -- 61
SOLDIER_H = 88 -- 62
local SOLDIER_SPEED = 264 -- 63
local ROLL_TIME = 0.35 -- 64
local ROLL_SPEED = 280 -- 65
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 67
local LEDGE_RISE = 60 -- 68
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 71
____exports.LOGIC_H = 180 -- 72
____exports.UNITS_PER_PX = 2 -- 73
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 75
local CAM_FOLLOW = 9 -- 76
local CAM_LOOK_UP = 46 -- 77
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 80
--- 握把触发半径。
____exports.CART_REACH = 70 -- 82
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 84
local CART_CLEAR = 44 -- 85
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 87
local FIRE_COOLDOWN = 150 -- 88
local ENEMY_RANGE = 760 -- 89
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 91
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 93
local DEPTH_SPEED_RATIO = 0.55 -- 94
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 95
INK = Color(232, 232, 228, 255) -- 97
local INK_DIM = Color(150, 152, 150, 255) -- 98
local BG_VOID = Color(8, 9, 10, 255) -- 99
local BG_FAR = Color(24, 26, 28, 255) -- 100
local BG_MID = Color(31, 34, 37, 255) -- 101
local GROUND = Color(112, 114, 112, 255) -- 102
local FLOOR_DECK = Color(66, 70, 72, 255) -- 103
local SOLID_FILL = Color(84, 86, 84, 255) -- 104
local SOLID_EDGE = Color(126, 130, 126, 255) -- 105
CART_FILL = Color(122, 78, 56, 255) -- 106
CLOTH = Color(178, 52, 46, 255) -- 107
local DANGER = Color(150, 54, 48, 46) -- 108
local DANGER_LINE = Color(178, 78, 64, 200) -- 109
local HOLE_FILL = Color(10, 11, 12, 255) -- 110
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 111
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 112
local CHILD_BODY = Color(214, 168, 96, 255) -- 113
local CHILD_HEAD = Color(232, 214, 186, 255) -- 114
local ENEMY_BODY = Color(176, 92, 84, 255) -- 115
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 116
local CHECK = Color(96, 186, 122, 255) -- 117
local STAND = Color(226, 186, 84, 255) -- 118
local AIM = Color(236, 236, 232, 230) -- 119
local AIM_HIT = Color(236, 96, 84, 255) -- 120
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 122
local SOFT_LINE = Color(140, 112, 80, 190) -- 123
local BRICK = Color(126, 118, 110, 70) -- 124
local BRICK_LINE = Color(160, 152, 142, 200) -- 125
local PASS = Color(96, 186, 122, 40) -- 126
local PASS_LINE = Color(96, 186, 122, 200) -- 127
local BOTTLE = Color(120, 186, 160, 255) -- 128
local SCAV_BODY = Color(128, 118, 96, 255) -- 129
local SCAV_HEAD = Color(196, 182, 158, 255) -- 130
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 190
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 191
	if zoom < 1 then -- 191
		zoom = 1 -- 193
	end -- 193
	return { -- 195
		zoom = zoom, -- 196
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 197
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 198
	} -- 198
end -- 190
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 221
	if key == "prologue" then -- 221
		return "prologue-wait" -- 223
	end -- 223
	if key == "street" then -- 223
		return "street-run" -- 226
	end -- 226
	if key == "gate" then -- 226
		return "gate-idle" -- 229
	end -- 229
	if key == "forest" then -- 229
		return "forest-run" -- 232
	end -- 232
	if key == "tower" then -- 232
		return "tower-wait" -- 235
	end -- 235
	return "run" -- 237
end -- 221
____exports.Play = __TS__Class() -- 240
local Play = ____exports.Play -- 240
Play.name = "Play" -- 240
function Play.prototype.____constructor(self, room, resume) -- 381
	self.enemies = {} -- 245
	self.boxes = {} -- 246
	self.floors = {} -- 247
	self.checkpoint = -1 -- 249
	self.flash = "" -- 251
	self.flashT = 0 -- 252
	self.traceT = 0 -- 255
	self.focusCart = false -- 257
	self.knocks = 0 -- 259
	self.knockT = 0 -- 260
	self.cartAxle = 0 -- 264
	self.cartDocked = false -- 266
	self.gripping = false -- 268
	self.gateOpen = false -- 270
	self.calmConsumed = false -- 272
	self.nextDangerId = 1 -- 274
	self.wantRoom = "" -- 276
	self.carryCartAxle = -1 -- 278
	self.carryCartDocked = false -- 279
	self.checkpointCartAxle = -1 -- 281
	self.hasBottle = false -- 285
	self.bottleLandX = -1 -- 289
	self.bottleTargetX = -1 -- 290
	self.bottleTargetY = 0 -- 291
	self.bottleLandT = 0 -- 292
	self.aimHold = 0 -- 294
	self.scavX = 0 -- 296
	self.scavDir = 1 -- 297
	self.scavState = "patrol" -- 298
	self.scavT = 0 -- 299
	self.scavTargetX = 0 -- 300
	self.passed = false -- 302
	self.childMode = false -- 306
	self.phase = "" -- 308
	self.phaseTick = 0 -- 310
	self.gateTick = 0 -- 312
	self.countTick = 0 -- 314
	self.countArmed = false -- 316
	self.countPrevMove = 0 -- 318
	self.caughtT = 0 -- 320
	self.hp = 3 -- 322
	self.maxHp = 3 -- 323
	self.coveredFlash = 0 -- 325
	self.coverHug = false -- 327
	self.coverNear = false -- 329
	self.coverEntity = "" -- 331
	self.coverBlocking = false -- 333
	self.gateNeedConfirm = false -- 335
	self.gateRestartArmed = true -- 337
	self.bottleAimX = -1 -- 339
	self.bottleAimY = 0 -- 340
	self.bottleSurfaceY = -1 -- 342
	self.bottleLandY = 0 -- 344
	self.events = {} -- 346
	self.eventSeq = 0 -- 348
	self.previousDepthInput = 0 -- 350
	self.dogX = 0 -- 352
	self.dogDir = 1 -- 353
	self.dogState = "patrol" -- 354
	self.dogT = 0 -- 355
	self.dogTargetX = 0 -- 356
	self.scavSee = 0 -- 358
	self.scavChase = false -- 359
	self.gateSpawned = 0 -- 361
	self.gateFailCount = 0 -- 363
	self.paused = false -- 365
	self.ticks = 0 -- 367
	self.view = {zoom = 1, ox = 0, oy = 0} -- 369
	self.ox = 0 -- 371
	self.aimX = 0 -- 373
	self.aimY = 0 -- 374
	self.viewW = 0 -- 376
	self.viewH = 0 -- 377
	self.ox = room.originX -- 383
	self.room = withOrigin(room) -- 384
	local wr = self.room -- 385
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 386
	self:buildWorld() -- 387
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 389
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 390
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 391
	self.player = makeActor(wr, playerIdx) -- 392
	self.partner = makeActor(wr, partnerIdx) -- 393
	self.phase = phaseOf(wr.key) -- 394
	if wr.story ~= nil then -- 394
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 396
	end -- 396
	self.cam.x = self.player.x -- 398
	self.cam.y = self.player.y + CAM_LOOK_UP -- 399
	self.cartAxle = wr.cart.startX -- 400
	self.escort = __TS__New( -- 401
		Escort, -- 401
		safeAnchorX(wr.marks) -- 401
	) -- 401
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 402
	self:buildEnemies() -- 403
	if resume ~= nil and resume.checkpoint > 0 then -- 403
		self.checkpoint = resume.checkpoint -- 406
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 406
			self.cartAxle = self.room.cart.endX -- 408
			self.cartDocked = true -- 409
			self.player.x = self.ox + 380 -- 412
			self.player.y = 0 -- 413
			self.player.vy = 0 -- 414
			self.player.onGround = true -- 415
			self.cam.x = self.player.x -- 416
			self.cam.y = self.player.y + CAM_LOOK_UP -- 417
		end -- 417
	end -- 417
end -- 381
function Play.prototype.buildWorld(self) -- 423
	local room = self.room -- 424
	self.boxes = {} -- 425
	self.floors = {} -- 426
	local i = 0 -- 427
	do -- 427
		i = 0 -- 428
		while i < #room.floors do -- 428
			local f = room.floors[i + 1] -- 429
			local ____self_floors_0 = self.floors -- 429
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 430
			i = i + 1 -- 428
		end -- 428
	end -- 428
	do -- 428
		i = 0 -- 432
		while i < #room.solids do -- 432
			local s = room.solids[i + 1] -- 433
			if not s.decorative then -- 433
				local ____self_boxes_6 = self.boxes -- 435
				local ____s_x_2 = s.x -- 436
				local ____temp_3 = s.x + s.w -- 436
				local ____s_y_4 = s.y -- 436
				local ____temp_5 = s.y + s.h -- 436
				local ____temp_1 -- 437
				if room.depth == nil then -- 437
					____temp_1 = nil -- 437
				else -- 437
					____temp_1 = s.depth -- 437
				end -- 437
				____self_boxes_6[#____self_boxes_6 + 1] = { -- 435
					x0 = ____s_x_2, -- 436
					x1 = ____temp_3, -- 436
					y0 = ____s_y_4, -- 436
					y1 = ____temp_5, -- 436
					depth = ____temp_1, -- 437
					passable = s.passable == true, -- 438
					label = s.label -- 438
				} -- 438
			end -- 438
			i = i + 1 -- 432
		end -- 432
	end -- 432
	do -- 432
		i = 0 -- 442
		while i < #room.stairs do -- 442
			local st = room.stairs[i + 1] -- 443
			local n = st.steps + 1 -- 444
			local stepW = (st.x1 - st.x0) / n -- 445
			local k = 0 -- 446
			do -- 446
				k = 0 -- 447
				while k < n do -- 447
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 448
					local x0 = st.x0 + stepW * k -- 449
					local ____self_boxes_7 = self.boxes -- 449
					____self_boxes_7[#____self_boxes_7 + 1] = { -- 451
						x0 = x0, -- 451
						x1 = x0 + stepW, -- 451
						y0 = -8, -- 451
						y1 = y, -- 451
						passable = true -- 451
					} -- 451
					k = k + 1 -- 447
				end -- 447
			end -- 447
			i = i + 1 -- 442
		end -- 442
	end -- 442
end -- 423
function Play.prototype.buildEnemies(self) -- 456
	self.enemies = {} -- 457
	if self.room.key == "checkpoint" then -- 457
		local ____self_enemies_8 = self.enemies -- 457
		____self_enemies_8[#____self_enemies_8 + 1] = { -- 459
			x = self.ox + 430, -- 459
			y = 0, -- 459
			w = 26, -- 459
			h = 84, -- 459
			alive = true, -- 459
			hitT = 0, -- 459
			warnT = 0, -- 459
			fireCd = 0 -- 459
		} -- 459
		local ____self_enemies_9 = self.enemies -- 459
		____self_enemies_9[#____self_enemies_9 + 1] = { -- 460
			x = self.ox + 505, -- 460
			y = 0, -- 460
			w = 26, -- 460
			h = 84, -- 460
			alive = true, -- 460
			hitT = 0, -- 460
			warnT = 0, -- 460
			fireCd = 0 -- 460
		} -- 460
		return -- 461
	end -- 461
	if self.room.key == "street" then -- 461
		local ____self_enemies_10 = self.enemies -- 461
		____self_enemies_10[#____self_enemies_10 + 1] = { -- 465
			x = self.ox + 340, -- 465
			y = 0, -- 465
			w = 26, -- 465
			h = 84, -- 465
			alive = true, -- 465
			hitT = 0, -- 465
			warnT = 0, -- 465
			fireCd = 0 -- 465
		} -- 465
		local ____self_enemies_11 = self.enemies -- 465
		____self_enemies_11[#____self_enemies_11 + 1] = { -- 466
			x = self.ox + 560, -- 466
			y = 0, -- 466
			w = 26, -- 466
			h = 84, -- 466
			alive = true, -- 466
			hitT = 0, -- 466
			warnT = 0, -- 466
			fireCd = 0 -- 466
		} -- 466
	end -- 466
end -- 456
function Play.prototype.emit(self, name, data) -- 472
	local ____self_events_12 = self.events -- 472
	____self_events_12[#____self_events_12 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 473
	self.eventSeq = self.eventSeq + 1 -- 474
	if #self.events > 256 then -- 474
		table.remove(self.events, 1) -- 476
	end -- 476
end -- 472
function Play.prototype.drainEvents(self) -- 484
	local out = self.events -- 485
	self.events = {} -- 486
	return out -- 487
end -- 484
function Play.prototype.adoptEvents(self, events) -- 496
	if #events == 0 then -- 496
		return -- 498
	end -- 498
	local keep = {} -- 500
	local i = 0 -- 501
	do -- 501
		i = 0 -- 502
		while i < #events do -- 502
			do -- 502
				local e = events[i + 1] -- 503
				if e.name == "knock" and e.data.room ~= self.room.key then -- 503
					goto __continue33 -- 505
				end -- 505
				keep[#keep + 1] = e -- 507
			end -- 507
			::__continue33:: -- 507
			i = i + 1 -- 502
		end -- 502
	end -- 502
	if #keep == 0 then -- 502
		return -- 510
	end -- 510
	self.events = __TS__ArrayConcat(keep, self.events) -- 512
	do -- 512
		i = 0 -- 513
		while i < #self.events do -- 513
			self.events[i + 1].seq = i -- 514
			i = i + 1 -- 513
		end -- 513
	end -- 513
	self.eventSeq = #self.events -- 516
end -- 496
function Play.prototype.update(self, dt, input) -- 520
	if input.pause.pressed then -- 520
		self.paused = not self.paused -- 522
	end -- 522
	if self.flashT > 0 then -- 522
		self.flashT = self.flashT - dt -- 525
		if self.flashT <= 0 then -- 525
			self.flash = "" -- 527
		end -- 527
	end -- 527
	if self.traceT > 0 then -- 527
		self.traceT = self.traceT - dt -- 531
		if self.traceT <= 0 then -- 531
			self.trace = nil -- 533
		end -- 533
	end -- 533
	if self.paused then -- 533
		self:updateCamera(dt) -- 537
		return -- 538
	end -- 538
	self.ticks = self.ticks + 1 -- 541
	local p = self.player -- 542
	self:stepPlayer(p, dt, input) -- 543
	self:refreshCover(p, input) -- 545
	self:stepEnemies(dt, input) -- 547
	self:stepStory(dt, input) -- 548
	self:stepEscort(dt, input) -- 549
	self:stepVillage(dt, input) -- 550
	self:stepChase(dt, input) -- 551
	self:stepInteract(dt, input) -- 552
	self:updateGate() -- 553
	self:updateCamera(dt) -- 554
end -- 520
function Play.prototype.underLowArch(self, a) -- 561
	local arch = self.room.arch -- 562
	if arch.h <= 0 then -- 562
		return false -- 564
	end -- 564
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 564
		return false -- 567
	end -- 567
	local top = arch.y + arch.h -- 569
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 570
end -- 561
function Play.prototype.coverAt(self, a) -- 577
	local best = nil -- 578
	local bestGap = 24 -- 579
	local half = a.w / 2 -- 580
	local i = 0 -- 581
	do -- 581
		i = 0 -- 582
		while i < #self.boxes do -- 582
			do -- 582
				local b = self.boxes[i + 1] -- 583
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 583
					goto __continue50 -- 585
				end -- 585
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 585
					goto __continue50 -- 588
				end -- 588
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 590
				if gap < bestGap then -- 590
					bestGap = gap -- 592
					best = b -- 593
				end -- 593
			end -- 593
			::__continue50:: -- 593
			i = i + 1 -- 582
		end -- 582
	end -- 582
	return best -- 596
end -- 577
function Play.prototype.nearCover(self, a) -- 599
	return self:coverAt(a) ~= nil -- 600
end -- 599
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 604
	if enemy == nil then -- 604
		return false -- 606
	end -- 606
	local fromRight = enemy.x >= a.x -- 608
	local edge = fromRight and b.x0 or b.x1 -- 609
	local ____fromRight_13 -- 610
	if fromRight then -- 610
		____fromRight_13 = edge >= a.x - 0.001 and edge <= enemy.x -- 610
	else -- 610
		____fromRight_13 = edge <= a.x + 0.001 and edge >= enemy.x -- 611
	end -- 611
	local between = ____fromRight_13 -- 610
	local separation = enemy.x - a.x -- 612
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 613
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 614
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 615
end -- 604
function Play.prototype.nearestEnemy(self, a) -- 618
	local best -- 619
	local bestD = 1000000000 -- 620
	local i = 0 -- 621
	do -- 621
		i = 0 -- 622
		while i < #self.enemies do -- 622
			do -- 622
				local e = self.enemies[i + 1] -- 623
				if not e.alive then -- 623
					goto __continue59 -- 625
				end -- 625
				local d = math.abs(e.x - a.x) -- 627
				if d < bestD then -- 627
					bestD = d -- 629
					best = e -- 630
				end -- 630
			end -- 630
			::__continue59:: -- 630
			i = i + 1 -- 622
		end -- 622
	end -- 622
	return best -- 633
end -- 618
function Play.prototype.refreshCover(self, a, input) -- 637
	if self.childMode then -- 637
		self.coverNear = false -- 639
		self.coverHug = false -- 640
		self.coverEntity = "" -- 641
		self.coverBlocking = false -- 642
		a.covered = false -- 643
		return -- 644
	end -- 644
	local b = self:coverAt(a) -- 646
	self.coverNear = b ~= nil -- 647
	a.covered = self.coverNear and input.cover.held -- 648
	self.coverHug = a.covered -- 649
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 650
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 651
		b, -- 651
		a, -- 651
		self:nearestEnemy(a) -- 651
	) -- 651
end -- 637
function Play.prototype.cartHandleInReach(self, a) -- 655
	if a == nil then -- 655
		a = self.player -- 655
	end -- 655
	local c = self.room.cart -- 656
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 656
		return false -- 658
	end -- 658
	local handleX = self.cartAxle + c.handleOffset -- 660
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 661
end -- 655
function Play.prototype.nearLowLedge(self, a) -- 666
	local reach = 26 -- 667
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 668
	local x1 = x0 + reach -- 669
	local i = 0 -- 670
	do -- 670
		i = 0 -- 671
		while i < #self.boxes do -- 671
			do -- 671
				local b = self.boxes[i + 1] -- 672
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 672
					goto __continue68 -- 674
				end -- 674
				local rise = b.y1 - a.y -- 676
				if rise > 0 and rise <= LEDGE_RISE then -- 676
					return true -- 678
				end -- 678
			end -- 678
			::__continue68:: -- 678
			i = i + 1 -- 671
		end -- 671
	end -- 671
	return false -- 681
end -- 666
function Play.prototype.stepPlayer(self, a, dt, input) -- 684
	a.depthSpeed = 0 -- 685
	local laneDirection = input.moveY == self.previousDepthInput and 0 or -input.moveY -- 686
	self.previousDepthInput = input.moveY -- 687
	if not a.alive then -- 687
		return -- 689
	end -- 689
	local isChild = self.childMode -- 691
	local lowArch = isChild and self:underLowArch(a) -- 693
	if self:storyLocked() then -- 693
		a.vx = 0 -- 696
		a.crouch = isChild and lowArch -- 697
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 698
		self:fallY(a, dt) -- 699
		return -- 700
	end -- 700
	if not isChild and self.escort.state == "calming" then -- 700
		a.crouch = false -- 704
		a.h = SOLDIER_H -- 705
		a.vx = 0 -- 706
		self:fallY(a, dt) -- 707
		return -- 708
	end -- 708
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 710
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 711
	local nearCover = not isChild and self:nearCover(a) -- 712
	a.covered = nearCover and input.cover.held -- 713
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 715
	if a.rollT > 0 then -- 715
		a.rollT = a.rollT - dt -- 719
		a.vx = a.facing * ROLL_SPEED -- 720
		self:slideX(a, a.vx * dt, self.laneDestination) -- 721
		self:fallY(a, dt) -- 722
		if a.rollT <= 0 then -- 722
			self:flashSet("翻滚结束", 0.5) -- 724
		end -- 724
		return -- 726
	end -- 726
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 726
		if input.moveX ~= 0 then -- 726
			a.facing = input.moveX > 0 and 1 or -1 -- 731
		end -- 731
		if self:nearLowLedge(a) then -- 731
			a.vy = SOLDIER_JUMP -- 735
			a.onGround = false -- 736
			self:flashSet("翻上去", 0.3) -- 737
			return -- 738
		end -- 738
		a.rollT = ROLL_TIME -- 740
		self:flashSet("翻滚", 0.3) -- 741
		return -- 742
	end -- 742
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 745
	if isChild then -- 745
		if input.cover.held then -- 745
			speed = CHILD_SLOW -- 748
		end -- 748
		if a.crouch then -- 748
			speed = CHILD_SLOW -- 751
		end -- 751
	elseif a.covered then -- 751
		speed = SOLDIER_SPEED * 0.45 -- 754
	end -- 754
	local handsBusy = self.gripping or gripIntent -- 758
	local dir = self.gripping and 0 or input.moveX -- 759
	if self.room.depth ~= nil and not isChild and not handsBusy and laneDirection ~= 0 then -- 759
		local target = adjacentLane(self.laneDestination or a.depth, laneDirection) -- 761
		if self:limitDepth(a, target) == target then -- 761
			self.laneDestination = target -- 763
		end -- 763
	end -- 763
	local targetDepth = handsBusy and a.depth or (self.laneDestination or a.depth) -- 766
	local diagonal = dir ~= 0 and targetDepth ~= a.depth and DIAGONAL_SCALE or 1 -- 767
	if dir ~= 0 then -- 767
		a.facing = dir > 0 and 1 or -1 -- 769
	end -- 769
	a.vx = dir * speed * diagonal -- 771
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 771
		a.vy = CHILD_JUMP -- 775
		a.onGround = false -- 776
		self:flashSet("跳", 0.25) -- 777
	end -- 777
	local previousDepth = a.depth -- 780
	local depthStep = speed * DEPTH_SPEED_RATIO * diagonal * dt -- 781
	local nextDepth = targetDepth > a.depth and math.min(targetDepth, a.depth + depthStep) or math.max(targetDepth, a.depth - depthStep) -- 782
	self:slideX(a, a.vx * dt, targetDepth) -- 785
	a.depth = self:limitDepth(a, nextDepth) -- 786
	if a.depth == self.laneDestination then -- 786
		self.laneDestination = nil -- 788
	end -- 788
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 790
	self:fallY(a, dt) -- 791
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 791
		self:shoot(a) -- 795
	end -- 795
end -- 684
function Play.prototype.stepPartner(self, p, dt) -- 800
	local a = self.partner -- 801
	if not a.alive then -- 801
		return -- 803
	end -- 803
	a.crouch = false -- 805
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 806
	a.vx = 0 -- 807
	a.depthSpeed = 0 -- 808
	self:fallY(a, dt) -- 809
end -- 800
function Play.prototype.stepEscort(self, dt, input) -- 816
	local a = self.partner -- 817
	a.depthSpeed = 0 -- 818
	if not a.alive then -- 818
		return -- 820
	end -- 820
	if not self:escortOn() then -- 820
		a.vx = 0 -- 823
		self:fallY(a, dt) -- 824
		return -- 825
	end -- 825
	local p = self.player -- 827
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 828
	local hadKnock1 = self.escort.knock1 -- 829
	local hadKnock2 = self.escort.knock2 -- 830
	self.calmConsumed = self.escort:update( -- 831
		input, -- 831
		p.x, -- 831
		p.facing, -- 831
		a.x, -- 831
		dist -- 831
	) -- 831
	if not hadKnock1 and self.escort.knock1 then -- 831
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 834
	end -- 834
	if not hadKnock2 and self.escort.knock2 then -- 834
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 837
	end -- 837
	a.crouch = self.escort.crouchPose -- 839
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 840
	if not self.escort.stopped then -- 840
		local targetDepth = self.escort.state == "follow" and nearestLane(p.depth) or 0 -- 842
		local previousDepth = a.depth -- 843
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 844
		local distance = math.max( -- 845
			-travel, -- 845
			math.min(travel, targetDepth - previousDepth) -- 845
		) -- 845
		self:slideDepth(a, distance) -- 846
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 847
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 847
			a.vy = CHILD_JUMP -- 849
			a.onGround = false -- 850
		end -- 850
	end -- 850
	local dir = self.escort:moveDir(a.x) -- 853
	a.vx = dir * CHILD_SPEED -- 854
	if dir ~= 0 then -- 854
		a.facing = dir -- 856
		local before = a.x -- 857
		self:slideX(a, dir * CHILD_SPEED * dt) -- 858
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 858
			a.vy = CHILD_JUMP -- 861
			a.onGround = false -- 862
		end -- 862
	end -- 862
	self:fallY(a, dt) -- 865
end -- 816
function Play.prototype.escortOn(self) -- 869
	if self.room.key == "checkpoint" then -- 869
		return true -- 871
	end -- 871
	if self.room.key == "prologue" then -- 871
		return self.phase == "prologue-follow" -- 874
	end -- 874
	return self.room.key == "street" -- 876
end -- 869
function Play.prototype.storyLocked(self) -- 880
	if self.caughtT > 0 then -- 880
		return true -- 882
	end -- 882
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 882
		return true -- 885
	end -- 885
	if self.room.key == "gate" and self.phase == "gate-count" then -- 885
		return true -- 888
	end -- 888
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 888
		return true -- 891
	end -- 891
	return false -- 893
end -- 880
function Play.prototype.swapToChild(self, x) -- 897
	local tmp = self.player -- 898
	self.player = self.partner -- 899
	self.partner = tmp -- 900
	self.childMode = true -- 901
	self.laneDestination = nil -- 902
	self.player.alive = true -- 903
	self.player.x = self.ox + x -- 904
	self.player.y = 0 -- 905
	self.player.depth = 0 -- 906
	self.player.depthSpeed = 0 -- 907
	self.player.vy = 0 -- 908
	self.player.vx = 0 -- 909
	self.player.onGround = true -- 910
	self.player.crouch = false -- 911
	self.player.h = CHILD_H -- 912
	self.player.facing = 1 -- 913
	self.partner.alive = true -- 914
	self.cam.x = self.player.x -- 915
end -- 897
function Play.prototype.stepStory(self, dt, input) -- 919
	if self.room.key == "prologue" then -- 919
		self:stepPrologue(dt, input) -- 921
	elseif self.room.key == "street" then -- 921
		self:stepStreet(dt, input) -- 923
	elseif self.room.key == "gate" then -- 923
		self:stepGate(dt, input) -- 925
	elseif self.room.key == "tower" then -- 925
		self:stepTower(dt, input) -- 927
	end -- 927
end -- 919
function Play.prototype.stepPrologue(self, dt, input) -- 932
	local child = self.partner -- 933
	if self.phase == "prologue-wait" then -- 933
		child.crouch = true -- 935
		child.h = CHILD_CROUCH_H -- 936
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 937
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 939
		if near and input.interact.pressed then -- 939
			self.phase = "prologue-give" -- 941
			self.phaseTick = 0 -- 942
			self:flashSet("递出针套", 1) -- 943
		end -- 943
		return -- 945
	end -- 945
	if self.phase == "prologue-give" then -- 945
		self.phaseTick = self.phaseTick + 1 -- 948
		if self.phaseTick == 12 then -- 948
			self:flashSet("针套递过去", 0.7) -- 950
		elseif self.phaseTick == 36 then -- 950
			self:flashSet("纸条塞进针套", 0.9) -- 952
		elseif self.phaseTick >= 60 then -- 952
			self.phase = "prologue-follow" -- 954
			self.phaseTick = 0 -- 955
			child.crouch = false -- 956
			child.h = CHILD_H -- 957
			self:flashSet("她跟上了", 1.2) -- 958
		end -- 958
		return -- 960
	end -- 960
	if self.player.x >= self.ox + 660 and inReachDepth(self.player.depth) and child.x >= self.ox + 620 then -- 960
		self:requestRoom("street", "序章跟到门口") -- 964
		self:flashSet("进街道", 1.2) -- 965
	end -- 965
end -- 932
function Play.prototype.stepStreet(self, dt, input) -- 970
	local p = self.player -- 971
	local c = self.partner -- 972
	if p.x >= self.ox + 900 and inReachDepth(p.depth) and c.x >= self.ox + 860 then -- 972
		self:requestRoom("checkpoint", "两人都到街尾") -- 974
		self:flashSet("到检查站", 1.2) -- 975
	end -- 975
end -- 970
function Play.prototype.stepGate(self, dt, input) -- 980
	local ____temp_14 -- 981
	if self.room.story == nil then -- 981
		____temp_14 = nil -- 981
	else -- 981
		____temp_14 = self.room.story.gate -- 981
	end -- 981
	local g = ____temp_14 -- 981
	if g == nil then -- 981
		return -- 983
	end -- 983
	local p = self.player -- 985
	if self.phase == "gate-idle" then -- 985
		local a = self.partner -- 988
		local gap = g.waitX - a.x -- 989
		if math.abs(gap) > 3 then -- 989
			a.facing = gap > 0 and 1 or -1 -- 991
			a.vx = a.facing * CHILD_SPEED -- 992
			local beforeX = a.x -- 993
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 994
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 994
				a.vy = CHILD_JUMP -- 996
				a.onGround = false -- 997
			end -- 997
			self:fallY(a, dt) -- 999
		else -- 999
			a.vx = 0 -- 1001
			a.x = g.waitX -- 1002
		end -- 1002
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1005
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1006
		if self.gateNeedConfirm then -- 1006
			if not input.interact.held then -- 1006
				self.gateRestartArmed = true -- 1011
			end -- 1011
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1011
				self.gateNeedConfirm = false -- 1014
				self.gateRestartArmed = true -- 1015
				self.phase = "gate-hold" -- 1016
				self.gateTick = 0 -- 1017
				self.gateSpawned = 0 -- 1018
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1019
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1020
			end -- 1020
			return -- 1022
		end -- 1022
		if atWinch and atWait then -- 1022
			self.phase = "gate-hold" -- 1025
			self.gateTick = 0 -- 1026
			self.gateSpawned = 0 -- 1027
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1028
		end -- 1028
		return -- 1030
	end -- 1030
	if self.phase == "gate-hold" then -- 1030
		self.gateTick = self.gateTick + 1 -- 1033
		local marks = {0, 540, 900, 1500} -- 1035
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1035
			local idx = self.gateSpawned -- 1037
			local ____self_enemies_15 = self.enemies -- 1037
			____self_enemies_15[#____self_enemies_15 + 1] = { -- 1038
				x = self.ox + 620 + idx * 62, -- 1039
				y = 0, -- 1039
				w = 26, -- 1039
				h = 84, -- 1039
				alive = true, -- 1040
				hitT = 0, -- 1040
				warnT = 0, -- 1040
				fireCd = 90 + idx * 45 -- 1040
			} -- 1040
			self.gateSpawned = self.gateSpawned + 1 -- 1042
			self:flashSet( -- 1043
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1043
				0.9 -- 1043
			) -- 1043
		end -- 1043
		if self.gateTick == 900 then -- 1043
			self:flashSet("灯灭了", 1) -- 1046
		elseif self.gateTick == 2100 then -- 1046
			self:flashSet("门底压下来了", 1) -- 1048
		end -- 1048
		if self.gateTick >= g.holdTicks then -- 1048
			self.phase = "gate-send" -- 1051
			self.phaseTick = 0 -- 1052
			self.enemies = {} -- 1054
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1055
		end -- 1055
		return -- 1057
	end -- 1057
	if self.phase == "gate-send" then -- 1057
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1060
		if near and input.interact.pressed then -- 1060
			self:swapToChild(g.doorX + 30) -- 1062
			self.phase = "gate-count" -- 1063
			self.countTick = 0 -- 1064
			self.countArmed = false -- 1066
			self.countPrevMove = input.moveX -- 1067
			self:flashSet("门开了 · 送她出去", 1.8) -- 1068
		end -- 1068
		return -- 1070
	end -- 1070
	if self.phase == "gate-count" then -- 1070
		self.countTick = self.countTick + 1 -- 1073
		if self.countTick == 360 then -- 1073
			self:flashSet("门关上", 0.9) -- 1075
		elseif self.countTick == 1020 then -- 1075
			self:flashSet("数到一百", 2.2) -- 1077
		end -- 1077
		local prevMove = self.countPrevMove -- 1081
		self.countPrevMove = input.moveX -- 1082
		if self.countTick >= 1440 then -- 1082
			if prevMove <= 0 and input.moveX > 0 then -- 1082
				self.countArmed = true -- 1085
			end -- 1085
			if self.countArmed and input.moveX > 0 then -- 1085
				self.phase = "gate-walk" -- 1088
				self.phaseTick = 0 -- 1089
				self:flashSet("她迈出第一步", 1.4) -- 1090
			end -- 1090
		end -- 1090
		return -- 1093
	end -- 1093
	if self.player.x >= g.exitX then -- 1093
		self:requestRoom("outside", "走出城门") -- 1097
		self:flashSet("出城门 · 城外", 1.4) -- 1098
	end -- 1098
end -- 980
function Play.prototype.stepTower(self, dt, input) -- 1103
	local ____temp_16 -- 1104
	if self.room.story == nil then -- 1104
		____temp_16 = nil -- 1104
	else -- 1104
		____temp_16 = self.room.story.tower -- 1104
	end -- 1104
	local t = ____temp_16 -- 1104
	if t == nil then -- 1104
		return -- 1106
	end -- 1106
	if self.phase == "tower-wait" then -- 1106
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1109
		if near and input.interact.pressed then -- 1109
			self.phase = "tower-knock" -- 1111
			self.phaseTick = 0 -- 1112
			self.knocks = 1 -- 1113
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1114
			self:flashSet("敲一下", 0.6) -- 1115
		end -- 1115
		return -- 1117
	end -- 1117
	if self.phase == "tower-knock" then -- 1117
		self.phaseTick = self.phaseTick + 1 -- 1120
		if self.phaseTick == 12 then -- 1120
			self.knocks = 2 -- 1122
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1123
			self:flashSet("敲两下 · 第二声", 1) -- 1124
		elseif self.phaseTick >= t.knockTicks then -- 1124
			self.phase = "tower-given" -- 1126
			self.phaseTick = 0 -- 1127
			self:flashSet("门开了 · 提灯", 1.4) -- 1128
		end -- 1128
		return -- 1130
	end -- 1130
	if self.phase == "tower-given" then -- 1130
		self.phaseTick = self.phaseTick + 1 -- 1133
		if self.phaseTick == 60 then -- 1133
			self:flashSet("她递出针套和纸条", 1.6) -- 1135
		elseif self.phaseTick == 120 then -- 1135
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1137
		elseif self.phaseTick >= 180 then -- 1137
			self.phase = "tower-end" -- 1139
			self.phaseTick = 0 -- 1140
			self:flashSet("片尾 · E 再玩一次", 3) -- 1141
		end -- 1141
		return -- 1143
	end -- 1143
	if input.interact.pressed or input.retry.pressed then -- 1143
		self:requestRoom("prologue", "片尾再玩") -- 1146
		self:flashSet("回到序章", 1.4) -- 1147
	end -- 1147
end -- 1103
function Play.prototype.stepChase(self, dt, input) -- 1152
	if self.caughtT > 0 then -- 1152
		self.caughtT = self.caughtT - dt -- 1154
		if self.caughtT <= 0 then -- 1154
			self:recoverFromCaught() -- 1156
		end -- 1156
		return -- 1158
	end -- 1158
	if self.room.key == "village" then -- 1158
		self:stepScavChase() -- 1161
	elseif self.room.key == "forest" then -- 1161
		self:stepDog(dt) -- 1163
		if self.player.x >= self.ox + 1450 then -- 1163
			self:requestRoom("tower", "到林缘北塔") -- 1166
			self:flashSet("林缘 · 北塔", 1.4) -- 1167
		end -- 1167
	end -- 1167
end -- 1152
function Play.prototype.stepScavChase(self) -- 1173
	local s = self.room.scavenger -- 1174
	if s == nil then -- 1174
		return -- 1176
	end -- 1176
	local p = self.player -- 1178
	if self.passed and p.x > self.ox + 440 then -- 1178
		if self.scavChase then -- 1178
			self.scavChase = false -- 1182
			self.scavState = "back" -- 1183
			self.scavT = 0 -- 1184
		end -- 1184
		return -- 1186
	end -- 1186
	local dx = p.x - self.scavX -- 1188
	local dist = math.abs(dx) -- 1189
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1190
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1191
	if not self.scavChase then -- 1191
		if visible then -- 1191
			self.scavSee = self.scavSee + 1 -- 1194
			if self.scavSee >= 24 then -- 1194
				self.scavChase = true -- 1196
				self.scavState = "chase" -- 1197
				self.scavTargetX = p.x -- 1198
				self:flashSet("他看见你了", 1.2) -- 1199
			end -- 1199
		else -- 1199
			self.scavSee = 0 -- 1202
		end -- 1202
		return -- 1204
	end -- 1204
	local dir = p.x > self.scavX and 1 or -1 -- 1207
	self.scavX = self.scavX + dir * 96 / 60 -- 1208
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1208
		self:caught() -- 1210
		return -- 1211
	end -- 1211
	if hidden then -- 1211
		self.scavSee = 0 -- 1215
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1216
		self.scavT = self.scavT - 1 -- 1217
		if self.scavT <= 0 then -- 1217
			self.scavChase = false -- 1219
			self.scavState = "patrol" -- 1220
			self:flashSet("他失去了目标", 1) -- 1221
		end -- 1221
	end -- 1221
end -- 1173
function Play.prototype.stepDog(self, dt) -- 1227
	local ____temp_17 -- 1228
	if self.room.story == nil then -- 1228
		____temp_17 = nil -- 1228
	else -- 1228
		____temp_17 = self.room.story.dog -- 1228
	end -- 1228
	local dog = ____temp_17 -- 1228
	if dog == nil then -- 1228
		return -- 1230
	end -- 1230
	local p = self.player -- 1232
	local dist = math.abs(p.x - self.dogX) -- 1233
	if self.dogState == "patrol" then -- 1233
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1235
		if self.dogX < dog.x0 then -- 1235
			self.dogX = dog.x0 -- 1237
			self.dogDir = 1 -- 1238
		elseif self.dogX > dog.x1 then -- 1238
			self.dogX = dog.x1 -- 1240
			self.dogDir = -1 -- 1241
		end -- 1241
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1243
		if not p.crouch and moving and dist < dog.range then -- 1243
			self.dogState = "ear" -- 1245
			self.dogT = 18 -- 1246
			self.dogTargetX = p.x -- 1247
			self:flashSet("狗转耳朵", 0.8) -- 1248
		end -- 1248
		return -- 1250
	end -- 1250
	if self.dogState == "ear" then -- 1250
		self.dogT = self.dogT - 1 -- 1253
		if self.dogT <= 0 then -- 1253
			self.dogState = "chase" -- 1255
			self.dogTargetX = p.x -- 1256
			self:flashSet("狗追来了", 1.4) -- 1257
		end -- 1257
		return -- 1259
	end -- 1259
	if self.dogState == "chase" then -- 1259
		local dir = p.x > self.dogX and 1 or -1 -- 1262
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1263
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1263
			self:caught() -- 1265
			self.dogState = "sniff" -- 1266
			self.dogT = 60 -- 1267
		elseif dist > dog.range * 1.5 or p.crouch then -- 1267
			self.dogState = "sniff" -- 1269
			self.dogT = 60 -- 1270
			self:flashSet("狗停下了", 0.9) -- 1271
		end -- 1271
		return -- 1273
	end -- 1273
	if self.dogState == "sniff" then -- 1273
		self.dogT = self.dogT - 1 -- 1276
		if self.dogT <= 0 then -- 1276
			self.dogState = "back" -- 1278
		end -- 1278
		return -- 1280
	end -- 1280
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1283
	self.dogX = self.dogX + dir * dog.speed * dt -- 1284
	if math.abs(self.dogX - dog.x0) < 2 then -- 1284
		self.dogX = dog.x0 -- 1286
		self.dogState = "patrol" -- 1287
	end -- 1287
end -- 1227
function Play.prototype.caught(self) -- 1291
	self.caughtT = 1 -- 1292
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1293
end -- 1291
function Play.prototype.recoverFromCaught(self) -- 1297
	local p = self.player -- 1298
	p.x = self.ox + 140 -- 1299
	p.y = 0 -- 1300
	p.vy = 0 -- 1301
	p.vx = 0 -- 1302
	p.onGround = true -- 1303
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1303
		self.scavX = self.room.scavenger.x0 -- 1305
		self.scavState = "patrol" -- 1306
		self.scavSee = 0 -- 1307
		self.scavChase = false -- 1308
		self.scavT = 0 -- 1309
	end -- 1309
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1309
		self.dogX = self.room.story.dog.x0 -- 1312
		self.dogState = "patrol" -- 1313
		self.dogT = 0 -- 1314
	end -- 1314
	self.cam.x = p.x -- 1316
	self.cam.y = p.y + CAM_LOOK_UP -- 1317
	self:flashSet("回到安全点", 1.2) -- 1318
end -- 1297
function Play.prototype.updateGate(self) -- 1322
	if self.room.key ~= "checkpoint" then -- 1322
		self.gateOpen = false -- 1324
		return -- 1325
	end -- 1325
	local function inZone(x) -- 1327
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1327
	end -- 1327
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1328
end -- 1322
function Play.prototype.stepEnemies(self, dt, input) -- 1331
	local i = 0 -- 1332
	do -- 1332
		i = 0 -- 1333
		while i < #self.enemies do -- 1333
			local e = self.enemies[i + 1] -- 1334
			if e.hitT > 0 then -- 1334
				e.hitT = e.hitT - dt -- 1336
			end -- 1336
			i = i + 1 -- 1333
		end -- 1333
	end -- 1333
	if self.coveredFlash > 0 then -- 1333
		self.coveredFlash = self.coveredFlash - dt -- 1340
	end -- 1340
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 1340
		return -- 1344
	end -- 1344
	do -- 1344
		i = 0 -- 1346
		while i < #self.enemies do -- 1346
			do -- 1346
				local e = self.enemies[i + 1] -- 1347
				if not e.alive then -- 1347
					goto __continue206 -- 1349
				end -- 1349
				if e.warnT > 0 then -- 1349
					e.warnT = e.warnT - 1 -- 1352
					if e.warnT <= 0 then -- 1352
						self:enemyFire(e, input) -- 1354
					end -- 1354
					goto __continue206 -- 1356
				end -- 1356
				if e.fireCd > 0 then -- 1356
					e.fireCd = e.fireCd - 1 -- 1359
					if e.fireCd <= 0 then -- 1359
						e.warnT = WARN_TICKS -- 1361
					end -- 1361
				else -- 1361
					e.warnT = WARN_TICKS -- 1365
				end -- 1365
			end -- 1365
			::__continue206:: -- 1365
			i = i + 1 -- 1346
		end -- 1346
	end -- 1346
end -- 1331
function Play.prototype.enemyFire(self, e, input) -- 1371
	local p = self.player -- 1372
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 1372
		self:flashSet("枪声响在远处", 0.4) -- 1374
		e.fireCd = FIRE_COOLDOWN -- 1375
		return -- 1376
	end -- 1376
	local cover = self:blockedByCover(e, p) -- 1379
	local hugging = cover ~= nil -- 1380
	self.coverBlocking = hugging -- 1381
	local covered = hugging and input.cover.held -- 1382
	if covered then -- 1382
		self.coveredFlash = 0.5 -- 1384
		self:flashSet("掩体挡下", 0.5) -- 1385
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1386
		e.fireCd = FIRE_COOLDOWN -- 1391
		return -- 1392
	end -- 1392
	self.hp = self.hp - 1 -- 1394
	self:emit("actorHit", { -- 1395
		target = "player", -- 1395
		amount = 1, -- 1395
		hp = self.hp, -- 1395
		maxHp = self.maxHp, -- 1395
		enemyX = e.x -- 1395
	}) -- 1395
	self:flashSet( -- 1396
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1396
		0.7 -- 1396
	) -- 1396
	e.fireCd = FIRE_COOLDOWN -- 1397
	if self.hp <= 0 then -- 1397
		self:gateFailed() -- 1399
	end -- 1399
end -- 1371
function Play.prototype.blockedByCover(self, enemy, p) -- 1404
	local b = self:coverAt(p) -- 1405
	if b == nil then -- 1405
		return nil -- 1407
	end -- 1407
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 1409
end -- 1404
function Play.prototype.gateFailed(self) -- 1413
	local ____temp_18 -- 1414
	if self.room.story == nil then -- 1414
		____temp_18 = nil -- 1414
	else -- 1414
		____temp_18 = self.room.story.gate -- 1414
	end -- 1414
	local g = ____temp_18 -- 1414
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 1415
	self.hp = self.maxHp -- 1416
	self.gateTick = 0 -- 1417
	self.gateSpawned = 0 -- 1418
	self.enemies = {} -- 1419
	self.gateFailCount = self.gateFailCount + 1 -- 1420
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 1422
	self.player.y = 0 -- 1423
	self.player.vy = 0 -- 1424
	self.player.depth = 0 -- 1425
	self.player.depthSpeed = 0 -- 1426
	self.laneDestination = nil -- 1427
	self.player.onGround = true -- 1428
	self.player.crouch = false -- 1429
	self.player.h = SOLDIER_H -- 1430
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 1431
	self.partner.y = 0 -- 1432
	self.partner.vy = 0 -- 1433
	self.partner.depth = 0 -- 1434
	self.partner.depthSpeed = 0 -- 1435
	self.partner.onGround = true -- 1436
	self.cam.x = self.player.x -- 1437
	self.phase = "gate-idle" -- 1438
	self.phaseTick = 0 -- 1439
	self.coverHug = false -- 1440
	self.coverBlocking = false -- 1441
	self.coverEntity = "" -- 1442
	self.gateNeedConfirm = true -- 1443
	self.gateRestartArmed = false -- 1444
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 1445
end -- 1413
function Play.prototype.stepInteract(self, dt, input) -- 1448
	local p = self.player -- 1449
	local calmUsed = self.calmConsumed -- 1450
	self.calmConsumed = false -- 1451
	local calming = self.escort.state == "calming" -- 1453
	self.focusCart = false -- 1454
	if self.room.key == "outside" then -- 1454
		local c = self.room.cart -- 1456
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 1457
		local dy = p.y - c.baseY -- 1458
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 1459
	end -- 1459
	if not calmUsed and not calming then -- 1459
		self:stepCart(dt, input) -- 1463
	end -- 1463
	if calmUsed then -- 1463
		self:flashSet("安抚 · 敲两下", 0.8) -- 1468
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 1468
		if self.knockT > 0 then -- 1468
			self.knocks = self.knocks + 1 -- 1472
		else -- 1472
			self.knocks = 1 -- 1474
		end -- 1474
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 1476
		self.knockT = 1.2 -- 1477
		if self.knocks >= 2 then -- 1477
			self:flashSet("敲两下", 0.8) -- 1479
			self.knocks = 0 -- 1480
		else -- 1480
			self:flashSet("敲一下", 0.5) -- 1482
		end -- 1482
	elseif self.knockT > 0 then -- 1482
		self.knockT = self.knockT - dt -- 1485
		if self.knockT <= 0 then -- 1485
			self.knocks = 0 -- 1487
		end -- 1487
	end -- 1487
	local i = 0 -- 1492
	do -- 1492
		i = 0 -- 1493
		while i < #self.room.marks do -- 1493
			do -- 1493
				local m = self.room.marks[i + 1] -- 1494
				if m.kind ~= 0 then -- 1494
					goto __continue232 -- 1496
				end -- 1496
				local subjects = {self.partner, self.player} -- 1498
				local k = 0 -- 1499
				do -- 1499
					k = 0 -- 1500
					while k < #subjects do -- 1500
						do -- 1500
							local s = subjects[k + 1] -- 1501
							if not s.alive then -- 1501
								goto __continue235 -- 1503
							end -- 1503
							local dx = s.x - m.x -- 1505
							local dy = s.y - m.y -- 1506
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 1506
								self.checkpoint = m.x -- 1508
								self.checkpointCartAxle = self.cartAxle -- 1509
								if self.cartDocked then -- 1509
									self:flashSet("检查点 · 车已落窝", 1) -- 1511
								else -- 1511
									self:flashSet("检查点 · 车还没到位", 1) -- 1513
								end -- 1513
							end -- 1513
						end -- 1513
						::__continue235:: -- 1513
						k = k + 1 -- 1500
					end -- 1500
				end -- 1500
			end -- 1500
			::__continue232:: -- 1500
			i = i + 1 -- 1493
		end -- 1493
	end -- 1493
	self:checkCarryGate() -- 1519
end -- 1448
function Play.prototype.stepVillage(self, dt, input) -- 1523
	if self.room.key ~= "village" then -- 1523
		return -- 1525
	end -- 1525
	local p = self.player -- 1527
	local bottle = self.room.bottle -- 1528
	local scav = self.room.scavenger -- 1529
	if not self.hasBottle and bottle ~= nil then -- 1529
		local dx = p.x - bottle.x -- 1533
		local dy = p.y + p.h * 0.5 - bottle.y -- 1534
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 1534
			self.hasBottle = true -- 1536
			self:flashSet("拾起瓶子", 0.8) -- 1537
		end -- 1537
	end -- 1537
	if self.hasBottle then -- 1537
		if input.aim.held then -- 1537
			self.aimHold = self.aimHold + dt -- 1544
			if self.aimHold > 1.2 then -- 1544
				self.aimHold = 1.2 -- 1546
			end -- 1546
			local cached = self:bottleEnd() -- 1549
			self.bottleAimX = cached.x -- 1550
			self.bottleAimY = cached.y -- 1551
		elseif input.aim.released then -- 1551
			if self.aimHold < 0.12 then -- 1551
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 1555
				self.aimHold = 0 -- 1556
			else -- 1556
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 1558
				self:throwBottle(____end.x, ____end.y) -- 1559
				self.aimHold = 0 -- 1560
			end -- 1560
		end -- 1560
	else -- 1560
		self.aimHold = 0 -- 1564
		self.bottleAimX = -1 -- 1565
	end -- 1565
	local fly = self.bottleFly -- 1570
	if fly ~= nil then -- 1570
		fly.t = fly.t + dt -- 1572
		fly.x = fly.x0 + fly.vx * fly.t -- 1573
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 1574
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 1575
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 1575
			self:landBottle(fly) -- 1577
		end -- 1577
	end -- 1577
	if self.bottleLandT > 0 then -- 1577
		self.bottleLandT = self.bottleLandT - dt -- 1581
	end -- 1581
	if scav ~= nil then -- 1581
		self:stepScav(dt, scav) -- 1585
	end -- 1585
	local line = self.room.passLine -- 1588
	if line ~= nil and not self.passed and p.x >= line then -- 1588
		self.passed = true -- 1590
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 1591
	end -- 1591
	if self.passed and p.x >= self.ox + 640 then -- 1591
		self:requestRoom("forest", "过第一院出院") -- 1595
		self:flashSet("出院 · 北塔森林", 1.4) -- 1596
	end -- 1596
end -- 1523
function Play.prototype.bottleEnd(self) -- 1601
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1602
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 1605
	return {x = aim.x, y = g} -- 1606
end -- 1601
function Play.prototype.throwBottle(self, tx, ty) -- 1610
	local p = self.player -- 1611
	local dir = tx >= p.x and 1 or -1 -- 1613
	p.facing = dir -- 1614
	local x0 = p.x + dir * 10 -- 1615
	local y0 = p.y + p.h * 0.7 -- 1616
	self.bottleTargetX = tx -- 1617
	self.bottleTargetY = ty -- 1618
	self.bottleSurfaceY = ty -- 1619
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 1620
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 1621
	self.bottleFly = { -- 1622
		x = x0, -- 1622
		y = y0, -- 1622
		x0 = x0, -- 1622
		y0 = y0, -- 1622
		vx = vx, -- 1622
		vy = vy, -- 1622
		t = 0 -- 1622
	} -- 1622
	self.hasBottle = false -- 1623
	self:flashSet("投出", 0.4) -- 1624
	self:emit( -- 1625
		"bottleThrown", -- 1625
		{ -- 1625
			fromX = x0, -- 1626
			fromY = y0, -- 1627
			targetX = tx, -- 1628
			targetY = ty, -- 1629
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 1630
		} -- 1630
	) -- 1630
end -- 1610
function Play.prototype.landBottle(self, fly) -- 1635
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 1636
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 1637
	local s = self.room.scavenger -- 1638
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 1639
	self.bottleFly = nil -- 1640
	self.bottleTargetX = -1 -- 1641
	self.bottleTargetY = 0 -- 1642
	self.bottleSurfaceY = -1 -- 1643
	self.bottleLandX = x -- 1644
	self.bottleLandY = y -- 1645
	self.bottleLandT = 0.9 -- 1646
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 1647
	self:hearBottle(x) -- 1648
end -- 1635
function Play.prototype.hearBottle(self, x) -- 1652
	local s = self.room.scavenger -- 1653
	if s == nil then -- 1653
		return -- 1655
	end -- 1655
	if math.abs(x - self.scavX) > s.range then -- 1655
		self:flashSet("落地 · 他没听见", 0.6) -- 1658
		return -- 1659
	end -- 1659
	self.scavState = "turn" -- 1661
	self.scavT = s.hearTicks -- 1662
	self.scavTargetX = x -- 1663
	self:flashSet("砖地一响 · 他转头", 0.9) -- 1664
end -- 1652
function Play.prototype.stepScav(self, dt, s) -- 1668
	if self.scavState == "chase" then -- 1668
		return -- 1671
	end -- 1671
	if self.scavState == "turn" then -- 1671
		self.scavT = self.scavT - 1 -- 1674
		if self.scavT <= 0 then -- 1674
			self.scavState = "walk" -- 1676
		end -- 1676
		return -- 1678
	end -- 1678
	if self.scavState == "walk" then -- 1678
		local d = self.scavTargetX - self.scavX -- 1681
		if math.abs(d) < 4 then -- 1681
			self.scavState = "stall" -- 1683
			self.scavT = s.stallTicks -- 1684
			return -- 1685
		end -- 1685
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 1687
		return -- 1688
	end -- 1688
	if self.scavState == "stall" then -- 1688
		self.scavT = self.scavT - 1 -- 1691
		if self.scavT <= 0 then -- 1691
			self.scavState = "back" -- 1693
		end -- 1693
		return -- 1695
	end -- 1695
	if self.scavState == "back" then -- 1695
		local home = math.max( -- 1698
			s.x0, -- 1698
			math.min(s.x1, self.scavX) -- 1698
		) -- 1698
		if math.abs(home - self.scavX) < 2 then -- 1698
			self.scavState = "patrol" -- 1700
			return -- 1701
		end -- 1701
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 1703
		return -- 1704
	end -- 1704
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 1706
	if self.scavX >= s.x1 then -- 1706
		self.scavX = s.x1 -- 1708
		self.scavDir = -1 -- 1709
	elseif self.scavX <= s.x0 then -- 1709
		self.scavX = s.x0 -- 1711
		self.scavDir = 1 -- 1712
	end -- 1712
end -- 1668
function Play.prototype.stepCart(self, dt, input) -- 1720
	local p = self.player -- 1721
	local c = self.room.cart -- 1722
	if self.gripping then -- 1722
		if not input.interact.held then -- 1722
			self.gripping = false -- 1726
			self:flashSet("松开车把", 0.4) -- 1727
			return -- 1728
		end -- 1728
	else -- 1728
		if not input.interact.pressed then -- 1728
			return -- 1732
		end -- 1732
		if not self:cartHandleInReach(p) then -- 1732
			return -- 1735
		end -- 1735
		local track = c.depth or 0 -- 1737
		if self:limitDepth(p, track) ~= track then -- 1737
			return -- 1739
		end -- 1739
		p.depth = track -- 1741
		self.laneDestination = nil -- 1742
		p.depthSpeed = 0 -- 1743
		self.gripping = true -- 1744
		self:flashSet("握住车把", 0.4) -- 1745
		return -- 1746
	end -- 1746
	if self.cartDocked then -- 1746
		return -- 1750
	end -- 1750
	local dir = input.moveX -- 1752
	if dir == 0 then -- 1752
		return -- 1754
	end -- 1754
	local lo = math.min(c.startX, c.endX) -- 1756
	local hi = math.max(c.startX, c.endX) -- 1757
	local next = self.cartAxle + dir * CART_SPEED * dt -- 1758
	if next < lo then -- 1758
		next = lo -- 1760
	end -- 1760
	if next > hi then -- 1760
		next = hi -- 1763
	end -- 1763
	local delta = next - self.cartAxle -- 1765
	if delta == 0 then -- 1765
		return -- 1767
	end -- 1767
	self.cartAxle = next -- 1769
	p.x = p.x + delta -- 1770
	p.facing = dir > 0 and 1 or -1 -- 1771
	self:slideX(p, 0) -- 1772
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 1772
		self.gripping = false -- 1774
		self:flashSet("跟不上了，脱手", 0.6) -- 1775
		return -- 1776
	end -- 1776
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 1776
		self.cartDocked = true -- 1779
		self.gripping = false -- 1780
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 1781
		self:flashSet("车轮落窝", 1.2) -- 1782
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 1782
		self:flashSet("车轮回到起点", 0.5) -- 1784
	end -- 1784
end -- 1720
function Play.prototype.requestRoom(self, key, reason) -- 1792
	if self.wantRoom ~= "" then -- 1792
		return -- 1796
	end -- 1796
	self.wantRoom = key -- 1798
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 1799
end -- 1792
function Play.prototype.checkCarryGate(self) -- 1806
	if self.room.key == "checkpoint" then -- 1806
		if self.gateOpen and self.player.x >= self.ox + 900 and inReachDepth(self.player.depth) then -- 1806
			self.carryCartAxle = self.cartAxle -- 1809
			self.carryCartDocked = self.cartDocked -- 1810
			self:requestRoom("gate", "检查站出口") -- 1811
			self:flashSet("出检查站 · 城门", 1.2) -- 1812
		end -- 1812
		return -- 1814
	end -- 1814
	if self.room.key == "outside" then -- 1814
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 1814
			self.carryCartAxle = self.cartAxle -- 1820
			self.carryCartDocked = self.cartDocked -- 1821
			self:requestRoom("village", "墙根走完") -- 1822
			self:flashSet("墙根走完 · 进村口", 1.2) -- 1823
		end -- 1823
	end -- 1823
end -- 1806
function Play.prototype.aimAt(self, wx, wy) -- 1830
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 1831
	self.aimX = s.x -- 1832
	self.aimY = s.y -- 1833
end -- 1830
function Play.prototype.shoot(self, a) -- 1836
	local ox = a.x + a.facing * 8 -- 1837
	local muzzleY = a.y + a.h * 0.72 -- 1838
	local oy = muzzleY + a.depth -- 1839
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 1841
	local dx = aim.x - ox -- 1844
	local dy = aim.y - oy -- 1845
	local len = math.sqrt(dx * dx + dy * dy) -- 1846
	if len < 0.001 then -- 1846
		dx = a.facing -- 1848
		dy = 0 -- 1849
	else -- 1849
		dx = dx / len -- 1851
		dy = dy / len -- 1852
	end -- 1852
	if dx ~= 0 then -- 1852
		a.facing = dx > 0 and 1 or -1 -- 1855
	end -- 1855
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 1858
	local hitEnemy = self:raycastEnemies(ray) -- 1859
	local tEnemy = hitEnemy.t -- 1860
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 1861
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 1862
	local tWall = self:raycastWorld(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 1863
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 1864
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 1865
	self.trace = { -- 1867
		x0 = ox, -- 1867
		y0 = oy, -- 1867
		x1 = ox + dx * t, -- 1867
		y1 = oy + dy * t, -- 1867
		hit = hit -- 1867
	} -- 1867
	self.traceT = 0.12 -- 1868
	self:applyFireDanger(ox) -- 1869
	if hit then -- 1869
		local i = hitEnemy.index -- 1871
		local e = self.enemies[i + 1] -- 1872
		e.alive = false -- 1873
		e.hitT = 0.4 -- 1874
		self:flashSet("命中", 0.6) -- 1875
	else -- 1875
		self:flashSet("打空", 0.35) -- 1877
	end -- 1877
	self:emit("shotResolved", { -- 1879
		hit = hit, -- 1880
		enemyIndex = hit and hitEnemy.index or -1, -- 1881
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 1882
		aimX = aim.x, -- 1883
		aimY = aim.y, -- 1884
		impactX = ox + dx * t, -- 1885
		impactY = oy + dy * t -- 1886
	}) -- 1886
end -- 1836
function Play.prototype.applyFireDanger(self, shotX) -- 1891
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 1891
		return -- 1893
	end -- 1893
	local dangerX = shotX -- 1895
	local best = -1 -- 1896
	local bestD = 1000000000 -- 1897
	local i = 0 -- 1898
	do -- 1898
		i = 0 -- 1899
		while i < #self.enemies do -- 1899
			do -- 1899
				local e = self.enemies[i + 1] -- 1900
				if not e.alive then -- 1900
					goto __continue307 -- 1902
				end -- 1902
				local d = math.abs(e.x - self.partner.x) -- 1904
				if d < bestD then -- 1904
					bestD = d -- 1906
					best = i -- 1907
				end -- 1907
			end -- 1907
			::__continue307:: -- 1907
			i = i + 1 -- 1899
		end -- 1899
	end -- 1899
	if best >= 0 then -- 1899
		dangerX = self.enemies[best + 1].x -- 1911
	end -- 1911
	local exposed = self:childExposed(dangerX) -- 1913
	local before = self.escort.fear -- 1914
	local dangerId = self.nextDangerId -- 1915
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 1916
	self.nextDangerId = self.nextDangerId + 1 -- 1917
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 1918
	if after > before then -- 1918
		self:flashSet( -- 1920
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 1920
			1 -- 1920
		) -- 1920
	elseif not exposed then -- 1920
		self:flashSet("枪声没够到她", 0.5) -- 1922
	end -- 1922
end -- 1891
function Play.prototype.childExposed(self, dangerX) -- 1927
	local c = self.partner -- 1928
	if not c.alive then -- 1928
		return false -- 1930
	end -- 1930
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 1930
		self.boxes, -- 1933
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 1933
	) then -- 1933
		return false -- 1934
	end -- 1934
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 1934
		return false -- 1937
	end -- 1937
	local toDanger = dangerX - c.x -- 1939
	local toPlayer = self.player.x - c.x -- 1940
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 1940
		return false -- 1943
	end -- 1943
	return true -- 1945
end -- 1927
function Play.prototype.raycastEnemies(self, ray) -- 1949
	local best = -1 -- 1950
	local bestI = -1 -- 1951
	do -- 1951
		local i = 0 -- 1952
		while i < #self.enemies do -- 1952
			do -- 1952
				local e = self.enemies[i + 1] -- 1953
				if not e.alive then -- 1953
					goto __continue321 -- 1955
				end -- 1955
				local y = e.y + (e.depth or 0) -- 1957
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 1958
				if t >= 0 and (best < 0 or t < best) then -- 1958
					best = t -- 1960
					bestI = i -- 1961
				end -- 1961
			end -- 1961
			::__continue321:: -- 1961
			i = i + 1 -- 1952
		end -- 1952
	end -- 1952
	return {t = best, index = bestI} -- 1964
end -- 1949
function Play.prototype.raycastWorld(self, ray) -- 1967
	local best = -1 -- 1968
	for ____, box in ipairs(self.boxes) do -- 1969
		local t = hitBox(ray, box) -- 1970
		if t >= 0 and (best < 0 or t < best) then -- 1970
			best = t -- 1972
		end -- 1972
	end -- 1972
	if ray.dy < 0 then -- 1972
		local t = -ray.y / ray.dy -- 1976
		if t >= 0 and (best < 0 or t < best) then -- 1976
			best = t -- 1978
		end -- 1978
	end -- 1978
	return best -- 1981
end -- 1967
function Play.prototype.slideDepth(self, a, distance) -- 1985
	a.depth = self:limitDepth(a, a.depth + distance) -- 1986
end -- 1985
function Play.prototype.limitDepth(self, a, target) -- 1989
	local road = self.room.depth -- 1990
	if road == nil or target == a.depth then -- 1990
		return a.depth -- 1992
	end -- 1992
	local next = math.max( -- 1994
		road.min, -- 1994
		math.min(road.max, target) -- 1994
	) -- 1994
	local half = a.w / 2 -- 1995
	for ____, b in ipairs(self.boxes) do -- 1996
		do -- 1996
			local footprint = b.depth -- 1997
			if footprint == nil or b.passable == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1997
				goto __continue333 -- 2001
			end -- 2001
			local front = footprint.min - ACTOR_DEPTH_HALF -- 2003
			local back = footprint.max + ACTOR_DEPTH_HALF -- 2004
			if a.depth <= front and next > front then -- 2004
				next = front -- 2006
			elseif a.depth >= back and next < back then -- 2006
				next = back -- 2008
			end -- 2008
		end -- 2008
		::__continue333:: -- 2008
	end -- 2008
	return next -- 2011
end -- 1989
function Play.prototype.slideX(self, a, dx, targetDepth) -- 2015
	if targetDepth == nil then -- 2015
		targetDepth = a.depth -- 2015
	end -- 2015
	local nx = a.x + dx -- 2016
	local half = a.w / 2 -- 2017
	local room = self.room -- 2018
	nx = math.max( -- 2019
		room.minX + half, -- 2019
		math.min(room.maxX - half, nx) -- 2019
	) -- 2019
	local i = 0 -- 2020
	do -- 2020
		i = 0 -- 2021
		while i < #self.boxes do -- 2021
			do -- 2021
				local b = self.boxes[i + 1] -- 2022
				if b.passable == true or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF, targetDepth) then -- 2022
					goto __continue340 -- 2024
				end -- 2024
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2024
					goto __continue340 -- 2027
				end -- 2027
				if nx + half > b.x0 and nx - half < b.x1 then -- 2027
					if a.x <= b.x0 then -- 2027
						nx = b.x0 - half -- 2031
					elseif a.x >= b.x1 then -- 2031
						nx = b.x1 + half -- 2033
					else -- 2033
						nx = a.x -- 2035
					end -- 2035
				end -- 2035
			end -- 2035
			::__continue340:: -- 2035
			i = i + 1 -- 2021
		end -- 2021
	end -- 2021
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2021
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2043
		local bx0 = self.cartAxle - CART_HALF -- 2044
		local bx1 = self.cartAxle + CART_HALF -- 2045
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2045
			if a.x <= bx0 then -- 2045
				nx = bx0 - half -- 2048
			elseif a.x >= bx1 then -- 2048
				nx = bx1 + half -- 2050
			else -- 2050
				nx = a.x -- 2052
			end -- 2052
		end -- 2052
	end -- 2052
	local arch = room.arch -- 2060
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2060
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2062
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2062
			if a.x <= arch.x0 then -- 2062
				nx = arch.x0 - half -- 2065
			elseif a.x >= arch.x1 then -- 2065
				nx = arch.x1 + half -- 2067
			end -- 2067
		end -- 2067
	end -- 2067
	a.x = nx -- 2071
end -- 2015
function Play.prototype.fallY(self, a, dt) -- 2075
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2076
	if a.vy < -900 then -- 2076
		a.vy = -900 -- 2078
	end -- 2078
	local ny = a.y + a.vy * dt -- 2080
	local half = a.w / 2 -- 2081
	if a.vy <= 0 then -- 2081
		local reach = a.onGround and STEP_UP or 0 -- 2084
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 2085
		if ny <= ground then -- 2085
			ny = ground -- 2087
			a.vy = 0 -- 2088
			a.onGround = true -- 2089
		else -- 2089
			a.onGround = false -- 2091
		end -- 2091
	else -- 2091
		a.onGround = false -- 2094
		local i = 0 -- 2095
		do -- 2095
			i = 0 -- 2096
			while i < #self.boxes do -- 2096
				do -- 2096
					local b = self.boxes[i + 1] -- 2097
					if b.passable == true or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2097
						goto __continue363 -- 2099
					end -- 2099
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 2099
						goto __continue363 -- 2102
					end -- 2102
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 2102
						ny = b.y0 - a.h -- 2105
						a.vy = 0 -- 2106
					end -- 2106
				end -- 2106
				::__continue363:: -- 2106
				i = i + 1 -- 2096
			end -- 2096
		end -- 2096
	end -- 2096
	a.y = ny -- 2110
end -- 2075
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 2114
	if depth == nil then -- 2114
		depth = 0 -- 2114
	end -- 2114
	local g = -9999 -- 2115
	local i = 0 -- 2116
	do -- 2116
		i = 0 -- 2117
		while i < #self.floors do -- 2117
			local f = self.floors[i + 1] -- 2118
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 2118
				g = f.y1 -- 2120
			end -- 2120
			i = i + 1 -- 2117
		end -- 2117
	end -- 2117
	do -- 2117
		i = 0 -- 2123
		while i < #self.boxes do -- 2123
			local b = self.boxes[i + 1] -- 2124
			if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 2124
				g = b.y1 -- 2127
			end -- 2127
			i = i + 1 -- 2123
		end -- 2123
	end -- 2123
	return g -- 2130
end -- 2114
function Play.prototype.updateCamera(self, dt) -- 2133
	local p = self.player -- 2134
	local tx = p.x + p.facing * 30 -- 2135
	local ty = p.y + CAM_LOOK_UP -- 2136
	local k = math.min(1, CAM_FOLLOW * dt) -- 2137
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2138
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2139
end -- 2133
function Play.prototype.clampCamera(self, w, h) -- 2143
	local room = self.room -- 2144
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2145
	local spanX = room.maxX - room.minX -- 2146
	if spanX <= halfW * 2 then -- 2146
		self.cam.x = (room.minX + room.maxX) / 2 -- 2148
	else -- 2148
		self.cam.x = math.max( -- 2150
			room.minX + halfW, -- 2150
			math.min(room.maxX - halfW, self.cam.x) -- 2150
		) -- 2150
	end -- 2150
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 2153
	local spanY = room.height -- 2154
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 2155
	if spanY <= halfH * 2 then -- 2155
		self.cam.y = camY -- 2157
	else -- 2157
		self.cam.y = math.max( -- 2159
			camY, -- 2159
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 2159
		) -- 2159
	end -- 2159
end -- 2143
function Play.prototype.flashSet(self, text, t) -- 2163
	self.flash = text -- 2164
	self.flashT = t -- 2165
end -- 2163
function Play.prototype.statusText(self) -- 2169
	local p = self.player -- 2170
	local parts = {} -- 2171
	local who = self.childMode and "小满" or "周戍" -- 2172
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 2173
	if self.room.key == "prologue" then -- 2173
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2176
		if self.phase == "prologue-wait" then -- 2176
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 2178
		elseif self.phase == "prologue-give" then -- 2178
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 2180
		else -- 2180
			parts[#parts + 1] = "跟随" -- 2182
		end -- 2182
		if self.paused then -- 2182
			parts[#parts + 1] = "已暂停" -- 2185
		end -- 2185
		return table.concat(parts, " · ") -- 2187
	end -- 2187
	if self.room.key == "street" then -- 2187
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2190
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2191
		if self.paused then -- 2191
			parts[#parts + 1] = "已暂停" -- 2193
		end -- 2193
		return table.concat(parts, " · ") -- 2195
	end -- 2195
	if self.room.key == "gate" then -- 2195
		local ____temp_19 -- 2198
		if self.room.story == nil then -- 2198
			____temp_19 = nil -- 2198
		else -- 2198
			____temp_19 = self.room.story.gate -- 2198
		end -- 2198
		local g = ____temp_19 -- 2198
		if g ~= nil then -- 2198
			parts[#parts + 1] = self:gateLabel() -- 2200
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 2201
				0, -- 2202
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 2202
			))) .. " 秒" -- 2202
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 2203
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2204
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 2205
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 2206
			if self.gateFailCount > 0 then -- 2206
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 2208
			end -- 2208
			if self.flash ~= "" then -- 2208
				parts[#parts + 1] = self.flash -- 2211
			end -- 2211
		end -- 2211
		if self.paused then -- 2211
			parts[#parts + 1] = "已暂停" -- 2215
		end -- 2215
		return table.concat(parts, " · ") -- 2217
	end -- 2217
	if self.room.key == "forest" then -- 2217
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2220
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 2221
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 2222
		if self.caughtT > 0 then -- 2222
			parts[#parts + 1] = "复位中" -- 2224
		end -- 2224
		if self.paused then -- 2224
			parts[#parts + 1] = "已暂停" -- 2227
		end -- 2227
		return table.concat(parts, " · ") -- 2229
	end -- 2229
	if self.room.key == "tower" then -- 2229
		if self.phase == "tower-wait" then -- 2229
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 2233
		elseif self.phase == "tower-knock" then -- 2233
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 2235
		elseif self.phase == "tower-given" then -- 2235
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 2237
		else -- 2237
			parts[#parts + 1] = "片尾" -- 2239
		end -- 2239
		if self.paused then -- 2239
			parts[#parts + 1] = "已暂停" -- 2242
		end -- 2242
		return table.concat(parts, " · ") -- 2244
	end -- 2244
	if self.room.key == "village" then -- 2244
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2247
		if self.hasBottle then -- 2247
			parts[#parts + 1] = "有瓶" -- 2249
		elseif self.bottleFly ~= nil then -- 2249
			parts[#parts + 1] = "瓶在飞" -- 2251
		else -- 2251
			parts[#parts + 1] = "空手" -- 2253
		end -- 2253
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 2255
		if self.scavChase then -- 2255
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 2257
		end -- 2257
		if self.passed then -- 2257
			parts[#parts + 1] = "已过通行线" -- 2260
		end -- 2260
		if self.paused then -- 2260
			parts[#parts + 1] = "已暂停" -- 2263
		end -- 2263
		return table.concat(parts, " · ") -- 2265
	end -- 2265
	local isChild = self.childMode -- 2268
	if isChild then -- 2268
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 2270
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 2271
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2272
	else -- 2272
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 2274
		if p.rollT > 0 then -- 2274
			parts[#parts + 1] = "翻滚中" -- 2276
		end -- 2276
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 2278
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 2279
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 2280
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 2281
	end -- 2281
	if self.checkpoint >= 0 then -- 2281
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 2284
	end -- 2284
	if self.paused then -- 2284
		parts[#parts + 1] = "已暂停" -- 2287
	end -- 2287
	return table.concat(parts, " · ") -- 2289
end -- 2169
function Play.prototype.aliveEnemies(self) -- 2293
	local n = 0 -- 2294
	local i = 0 -- 2295
	do -- 2295
		i = 0 -- 2296
		while i < #self.enemies do -- 2296
			if self.enemies[i + 1].alive then -- 2296
				n = n + 1 -- 2298
			end -- 2298
			i = i + 1 -- 2296
		end -- 2296
	end -- 2296
	return n -- 2301
end -- 2293
function Play.prototype.threatened(self) -- 2306
	do -- 2306
		local i = 0 -- 2307
		while i < #self.enemies do -- 2307
			local e = self.enemies[i + 1] -- 2308
			if e.alive and e.warnT > 0 then -- 2308
				return true -- 2310
			end -- 2310
			i = i + 1 -- 2307
		end -- 2307
	end -- 2307
	return false -- 2313
end -- 2306
function Play.prototype.gateSecondsLeft(self) -- 2316
	local ____temp_20 -- 2317
	if self.room.story == nil then -- 2317
		____temp_20 = nil -- 2317
	else -- 2317
		____temp_20 = self.room.story.gate -- 2317
	end -- 2317
	local g = ____temp_20 -- 2317
	if g == nil then -- 2317
		return 0 -- 2319
	end -- 2319
	return math.max( -- 2321
		0, -- 2321
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 2321
	) -- 2321
end -- 2316
function Play.prototype.gateLabel(self) -- 2324
	if self.phase == "gate-idle" then -- 2324
		return "待就位" -- 2326
	end -- 2326
	if self.phase == "gate-hold" then -- 2326
		return "守点中" -- 2329
	end -- 2329
	if self.phase == "gate-send" then -- 2329
		return "送别" -- 2332
	end -- 2332
	if self.phase == "gate-count" then -- 2332
		return "数数 " .. tostring(self.countTick) -- 2335
	end -- 2335
	return "她走" -- 2337
end -- 2324
function Play.prototype.dogLabel(self) -- 2341
	if self.dogState == "ear" then -- 2341
		return "转耳" -- 2343
	end -- 2343
	if self.dogState == "chase" then -- 2343
		return "追" -- 2346
	end -- 2346
	if self.dogState == "sniff" then -- 2346
		return "停" -- 2349
	end -- 2349
	if self.dogState == "back" then -- 2349
		return "回线" -- 2352
	end -- 2352
	return "巡逻" -- 2354
end -- 2341
function Play.prototype.doorXOf(self) -- 2357
	local ____temp_21 -- 2358
	if self.room.story == nil then -- 2358
		____temp_21 = nil -- 2358
	else -- 2358
		____temp_21 = self.room.story.tower -- 2358
	end -- 2358
	local t = ____temp_21 -- 2358
	return t == nil and 0 or t.doorX -- 2359
end -- 2357
function Play.prototype.scavLabel(self) -- 2363
	if self.scavState == "chase" then -- 2363
		return "追" -- 2365
	end -- 2365
	if self.scavState == "turn" then -- 2365
		return "转头" -- 2368
	end -- 2368
	if self.scavState == "walk" then -- 2368
		return "赶来" -- 2371
	end -- 2371
	if self.scavState == "stall" then -- 2371
		return "停住" -- 2374
	end -- 2374
	if self.scavState == "back" then -- 2374
		return "回位" -- 2377
	end -- 2377
	return "巡逻" -- 2379
end -- 2363
function Play.prototype.hintText(self) -- 2383
	if self.paused then -- 2383
		return "Esc 继续 · R 重置" -- 2385
	end -- 2385
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 2385
		if self:threatened() then -- 2385
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 2391
		end -- 2391
		if self.coverHug then -- 2391
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 2394
		end -- 2394
		if self.coverNear then -- 2394
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 2397
		end -- 2397
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 2399
	end -- 2399
	if self.flash ~= "" then -- 2399
		return self.flash -- 2402
	end -- 2402
	if self.room.key == "prologue" then -- 2402
		if self.phase == "prologue-wait" then -- 2402
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 2406
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 2407
		end -- 2407
		if self.phase == "prologue-give" then -- 2407
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 2410
		end -- 2410
		return "她跟着你了 · 两人一起走到门口 680" -- 2412
	end -- 2412
	if self.room.key == "street" then -- 2412
		if self:aliveEnemies() > 0 then -- 2412
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 2416
		end -- 2416
		return "清完了 · 两人一起走到右边检查站入口 900" -- 2418
	end -- 2418
	if self.room.key == "gate" then -- 2418
		local ____temp_22 -- 2421
		if self.room.story == nil then -- 2421
			____temp_22 = nil -- 2421
		else -- 2421
			____temp_22 = self.room.story.gate -- 2421
		end -- 2421
		local g = ____temp_22 -- 2421
		if g ~= nil then -- 2421
			if self.phase == "gate-idle" then -- 2421
				if self.gateNeedConfirm then -- 2421
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 2425
				end -- 2425
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 2427
			end -- 2427
			if self.phase == "gate-hold" then -- 2427
				if self.coveredFlash > 0 then -- 2427
					return "掩体挡下了这一枪 · 别露头" -- 2431
				end -- 2431
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 2433
			end -- 2433
			if self.phase == "gate-send" then -- 2433
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 2436
			end -- 2436
			if self.phase == "gate-count" then -- 2436
				if self.countTick >= 1440 then -- 2436
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 2440
				end -- 2440
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 2442
			end -- 2442
			return "她自己走 · 跟着出城门 1120" -- 2444
		end -- 2444
	end -- 2444
	if self.room.key == "forest" then -- 2444
		if self.dogState == "chase" then -- 2444
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 2449
		end -- 2449
		if self.dogState == "ear" then -- 2449
			return "狗转耳朵了 · 停下或蹲下别出声" -- 2452
		end -- 2452
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 2454
	end -- 2454
	if self.room.key == "tower" then -- 2454
		if self.phase == "tower-wait" then -- 2454
			return "走到门前 445 点一次 E 敲两下" -- 2458
		end -- 2458
		if self.phase == "tower-knock" then -- 2458
			return "敲两下 · 等门开" -- 2461
		end -- 2461
		if self.phase == "tower-given" then -- 2461
			return "递交针套和纸条 · 看登记簿最后一行" -- 2464
		end -- 2464
		return "片尾 · 点 E 再玩一次，回到序章" -- 2466
	end -- 2466
	if self.room.key == "village" then -- 2466
		if self.bottleFly ~= nil then -- 2466
			return "等瓶子落地 · 触地才发声" -- 2470
		end -- 2470
		if self.hasBottle then -- 2470
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 2473
		end -- 2473
		if self.passed then -- 2473
			return "已过第一院 · R 重置可再来一遍" -- 2476
		end -- 2476
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 2478
	end -- 2478
	if self.room.key == "outside" then -- 2478
		if self.focusCart then -- 2478
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 2482
		end -- 2482
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 2484
	end -- 2484
	if self.escort.state == "frozen" then -- 2484
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 2484
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 2488
		end -- 2488
		return "小满吓住了 · 走过去，靠近再点 E" -- 2490
	end -- 2490
	if self.escort.state == "calming" then -- 2490
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 2493
	end -- 2493
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 2495
end -- 2383
function Play.prototype.draw(self, draw, w, h) -- 2500
	self.viewW = w -- 2501
	self.viewH = h -- 2502
	self.view = ____exports.computeViewport(w, h) -- 2503
	self:clampCamera(w, h) -- 2504
	draw:clear() -- 2505
	draw:drawRect( -- 2507
		Rect(0, 0, w, h), -- 2507
		BG_VOID -- 2507
	) -- 2507
	local box = self:canvasRect(w, h) -- 2508
	draw:drawRect(box, BG_FAR) -- 2509
	draw:drawRect( -- 2510
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 2510
		BG_MID -- 2510
	) -- 2510
	self:drawFloors(draw, w, h) -- 2512
	self:drawSolids(draw, w, h) -- 2513
	self:drawZones(draw, w, h) -- 2514
	self:drawArch(draw, w, h) -- 2515
	self:drawCart(draw, w, h) -- 2516
	self:drawActors(draw, w, h) -- 2517
	self:drawTrace(draw, w, h) -- 2518
	self:drawAim(draw, w, h) -- 2519
end -- 2500
function Play.prototype.canvasRect(self, w, h) -- 2523
	local v = self.view -- 2524
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 2525
end -- 2523
function Play.prototype.px(self, n) -- 2529
	return n * self.view.zoom -- 2530
end -- 2529
function Play.prototype.sx(self, wx, w) -- 2534
	local v = self.view -- 2535
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 2536
	return v.ox + lx * v.zoom -- 2537
end -- 2534
function Play.prototype.sy(self, wy, h) -- 2541
	local v = self.view -- 2542
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 2543
	return v.oy + ly * v.zoom -- 2544
end -- 2541
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 2547
	local px0 = self:sx(x0, w) -- 2548
	local px1 = self:sx(x1, w) -- 2549
	local py0 = self:sy(y0, h) -- 2550
	local py1 = self:sy(y1, h) -- 2551
	if px1 <= px0 or py1 <= py0 then -- 2551
		return -- 2553
	end -- 2553
	draw:drawRect( -- 2555
		Rect(px0, py0, px1 - px0, py1 - py0), -- 2555
		color -- 2555
	) -- 2555
end -- 2547
function Play.prototype.drawFloors(self, draw, w, h) -- 2558
	local i = 0 -- 2559
	do -- 2559
		i = 0 -- 2560
		while i < #self.room.floors do -- 2560
			local f = self.room.floors[i + 1] -- 2561
			local ____temp_23 -- 2562
			if f.y == 0 then -- 2562
				____temp_23 = self.room.depth -- 2562
			else -- 2562
				____temp_23 = nil -- 2562
			end -- 2562
			local road = ____temp_23 -- 2562
			local y = self:sy(f.y + (road and road.min or 0), h) -- 2563
			local x0 = self:sx(f.x0, w) -- 2564
			local x1 = self:sx(f.x1, w) -- 2565
			local deck = self:px(5) -- 2566
			if road ~= nil then -- 2566
				local back = self:sy(f.y + road.max, h) -- 2568
				draw:drawRect( -- 2569
					Rect(x0, y, x1 - x0, back - y), -- 2569
					FLOOR_DECK, -- 2569
					self:px(1), -- 2569
					SOLID_EDGE -- 2569
				) -- 2569
			end -- 2569
			draw:drawRect( -- 2571
				Rect(x0, y - deck, x1 - x0, deck), -- 2571
				FLOOR_DECK -- 2571
			) -- 2571
			draw:drawSegment( -- 2572
				Vec2(x0, y), -- 2572
				Vec2(x1, y), -- 2572
				self:px(1), -- 2572
				GROUND -- 2572
			) -- 2572
			i = i + 1 -- 2560
		end -- 2560
	end -- 2560
end -- 2558
function Play.prototype.drawSolids(self, draw, w, h) -- 2576
	local i = 0 -- 2577
	do -- 2577
		i = 0 -- 2578
		while i < #self.boxes do -- 2578
			do -- 2578
				local b = self.boxes[i + 1] -- 2579
				if b.y0 < -4 and b.y1 <= 96 then -- 2579
					draw:drawSegment( -- 2582
						Vec2( -- 2582
							self:sx(b.x0, w), -- 2582
							self:sy(b.y1, h) -- 2582
						), -- 2582
						Vec2( -- 2582
							self:sx(b.x1, w), -- 2582
							self:sy(b.y1, h) -- 2582
						), -- 2582
						self:px(1), -- 2582
						GROUND -- 2582
					) -- 2582
					goto __continue492 -- 2583
				end -- 2583
				local ____opt_26 = b.depth -- 2583
				local front = ____opt_26 and ____opt_26.min or 0 -- 2585
				local ____opt_28 = b.depth -- 2585
				local back = ____opt_28 and ____opt_28.max or 0 -- 2586
				self:drawBox( -- 2587
					draw, -- 2587
					w, -- 2587
					h, -- 2587
					b.x0, -- 2587
					b.x1, -- 2587
					b.y0 + front, -- 2587
					b.y1 + back, -- 2587
					SOLID_FILL -- 2587
				) -- 2587
				draw:drawSegment( -- 2588
					Vec2( -- 2588
						self:sx(b.x0, w), -- 2588
						self:sy(b.y1 + front, h) -- 2588
					), -- 2588
					Vec2( -- 2589
						self:sx(b.x1, w), -- 2589
						self:sy(b.y1 + front, h) -- 2589
					), -- 2589
					self:px(1), -- 2589
					SOLID_EDGE -- 2589
				) -- 2589
			end -- 2589
			::__continue492:: -- 2589
			i = i + 1 -- 2578
		end -- 2578
	end -- 2578
end -- 2576
function Play.prototype.drawZones(self, draw, w, h) -- 2593
	local i = 0 -- 2594
	do -- 2594
		i = 0 -- 2595
		while i < #self.room.zones do -- 2595
			local z = self.room.zones[i + 1] -- 2596
			local fill = DANGER -- 2597
			local line = DANGER_LINE -- 2598
			if z.tint == 2 then -- 2598
				fill = SOFT -- 2600
				line = SOFT_LINE -- 2601
			elseif z.tint == 3 then -- 2601
				fill = BRICK -- 2603
				line = BRICK_LINE -- 2604
			elseif z.tint == 4 then -- 2604
				fill = PASS -- 2606
				line = PASS_LINE -- 2607
			end -- 2607
			self:drawBox( -- 2609
				draw, -- 2609
				w, -- 2609
				h, -- 2609
				z.x0, -- 2609
				z.x1, -- 2609
				z.y, -- 2609
				z.y + z.h, -- 2609
				fill -- 2609
			) -- 2609
			draw:drawSegment( -- 2610
				Vec2( -- 2610
					self:sx(z.x0, w), -- 2610
					self:sy(z.y, h) -- 2610
				), -- 2610
				Vec2( -- 2610
					self:sx(z.x0, w), -- 2610
					self:sy(z.y + z.h, h) -- 2610
				), -- 2610
				self:px(1), -- 2610
				line -- 2610
			) -- 2610
			draw:drawSegment( -- 2611
				Vec2( -- 2611
					self:sx(z.x1, w), -- 2611
					self:sy(z.y, h) -- 2611
				), -- 2611
				Vec2( -- 2611
					self:sx(z.x1, w), -- 2611
					self:sy(z.y + z.h, h) -- 2611
				), -- 2611
				self:px(1), -- 2611
				line -- 2611
			) -- 2611
			i = i + 1 -- 2595
		end -- 2595
	end -- 2595
end -- 2593
function Play.prototype.drawArch(self, draw, w, h) -- 2615
	local a = self.room.arch -- 2616
	if a.h <= 0 then -- 2616
		return -- 2618
	end -- 2618
	self:drawBox( -- 2620
		draw, -- 2620
		w, -- 2620
		h, -- 2620
		a.x0, -- 2620
		a.x1, -- 2620
		a.y, -- 2620
		a.y + a.h, -- 2620
		HOLE_FILL -- 2620
	) -- 2620
	draw:drawSegment( -- 2621
		Vec2( -- 2621
			self:sx(a.x0, w), -- 2621
			self:sy(a.y + a.h, h) -- 2621
		), -- 2621
		Vec2( -- 2621
			self:sx(a.x1, w), -- 2621
			self:sy(a.y + a.h, h) -- 2621
		), -- 2621
		self:px(1), -- 2621
		SOLID_EDGE -- 2621
	) -- 2621
	draw:drawSegment( -- 2622
		Vec2( -- 2622
			self:sx(a.x0, w), -- 2622
			self:sy(a.y, h) -- 2622
		), -- 2622
		Vec2( -- 2622
			self:sx(a.x0, w), -- 2622
			self:sy(a.y + a.h, h) -- 2622
		), -- 2622
		self:px(1), -- 2622
		SOLID_EDGE -- 2622
	) -- 2622
	draw:drawSegment( -- 2623
		Vec2( -- 2623
			self:sx(a.x1, w), -- 2623
			self:sy(a.y, h) -- 2623
		), -- 2623
		Vec2( -- 2623
			self:sx(a.x1, w), -- 2623
			self:sy(a.y + a.h, h) -- 2623
		), -- 2623
		self:px(1), -- 2623
		SOLID_EDGE -- 2623
	) -- 2623
end -- 2615
function Play.prototype.drawCart(self, draw, w, h) -- 2626
	local c = self.room.cart -- 2627
	if c.bodyW <= 0 then -- 2627
		return -- 2629
	end -- 2629
	drawCartShape( -- 2631
		draw, -- 2631
		self, -- 2631
		w, -- 2631
		h, -- 2631
		c, -- 2631
		self.cartAxle -- 2631
	) -- 2631
	draw:drawRect( -- 2632
		Rect( -- 2632
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 2632
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 2632
			self:px(2), -- 2632
			self:px(40) -- 2632
		), -- 2632
		STAND -- 2632
	) -- 2632
end -- 2626
function Play.prototype.drawActors(self, draw, w, h) -- 2635
	local p = self.player -- 2636
	local isChild = self.childMode -- 2637
	local footY = p.y + p.depth -- 2638
	if p.covered then -- 2638
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 2641
		draw:drawSegment( -- 2642
			Vec2( -- 2642
				self:sx(edge, w), -- 2642
				self:sy(footY + 8, h) -- 2642
			), -- 2642
			Vec2( -- 2642
				self:sx(edge, w), -- 2642
				self:sy(footY + p.h * 0.62, h) -- 2642
			), -- 2642
			self:px(2), -- 2642
			STAND -- 2642
		) -- 2642
		draw:drawSegment( -- 2644
			Vec2( -- 2644
				self:sx(p.x - 8, w), -- 2644
				self:sy(footY + p.h + 3, h) -- 2644
			), -- 2644
			Vec2( -- 2644
				self:sx(p.x + 8, w), -- 2644
				self:sy(footY + p.h + 3, h) -- 2644
			), -- 2644
			self:px(2), -- 2644
			STAND -- 2644
		) -- 2644
	elseif self.coverNear and not isChild then -- 2644
		draw:drawRect( -- 2647
			Rect( -- 2647
				self:sx(p.x - 3, w), -- 2647
				self:sy(footY + 1, h), -- 2647
				self:px(3), -- 2647
				self:px(3) -- 2647
			), -- 2647
			STAND -- 2647
		) -- 2647
	end -- 2647
	drawFigure( -- 2649
		draw, -- 2649
		self, -- 2649
		w, -- 2649
		h, -- 2649
		p, -- 2649
		isChild and CHILD_BODY or SOLDIER_BODY, -- 2649
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 2649
	) -- 2649
	local q = self.partner -- 2650
	if q.alive then -- 2650
		local childPartner = q.w == CHILD_W -- 2652
		drawFigure( -- 2653
			draw, -- 2653
			self, -- 2653
			w, -- 2653
			h, -- 2653
			q, -- 2653
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 2653
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 2653
		) -- 2653
	end -- 2653
	local i = 0 -- 2655
	do -- 2655
		i = 0 -- 2656
		while i < #self.enemies do -- 2656
			local e = self.enemies[i + 1] -- 2657
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 2658
			local enemyY = e.y + (e.depth or 0) -- 2659
			self:drawBox( -- 2660
				draw, -- 2660
				w, -- 2660
				h, -- 2660
				e.x - e.w / 2, -- 2660
				e.x + e.w / 2, -- 2660
				enemyY, -- 2660
				enemyY + e.h, -- 2660
				col -- 2660
			) -- 2660
			if e.alive and e.warnT > 0 then -- 2660
				local gunX = self:sx(e.x, w) -- 2663
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 2664
				local aimX = self:sx(p.x, w) -- 2665
				local aimY = self:sy(footY + p.h * 0.55, h) -- 2666
				local seg = 8 -- 2667
				local s = 0 -- 2668
				do -- 2668
					s = 0 -- 2669
					while s < seg do -- 2669
						local t0 = s / seg -- 2670
						local t1 = (s + 1) / seg -- 2671
						draw:drawSegment( -- 2672
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 2673
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 2674
							self:px(1), -- 2675
							DANGER -- 2675
						) -- 2675
						s = s + 2 -- 2669
					end -- 2669
				end -- 2669
			end -- 2669
			i = i + 1 -- 2656
		end -- 2656
	end -- 2656
	local k = 0 -- 2680
	do -- 2680
		k = 0 -- 2681
		while k < #self.room.marks do -- 2681
			do -- 2681
				local m = self.room.marks[k + 1] -- 2682
				if m.kind ~= 0 then -- 2682
					goto __continue514 -- 2684
				end -- 2684
				local on = self.checkpoint == m.x -- 2686
				local x = self:sx(m.x, w) -- 2687
				local y = self:sy(m.y, h) -- 2688
				draw:drawSegment( -- 2689
					Vec2(x, y), -- 2689
					Vec2( -- 2689
						x, -- 2689
						y + self:px(35) -- 2689
					), -- 2689
					self:px(1), -- 2689
					on and CHECK or INK_DIM -- 2689
				) -- 2689
				draw:drawDot( -- 2690
					Vec2( -- 2690
						x, -- 2690
						y + self:px(35) -- 2690
					), -- 2690
					self:px(2), -- 2690
					on and CHECK or INK_DIM -- 2690
				) -- 2690
			end -- 2690
			::__continue514:: -- 2690
			k = k + 1 -- 2681
		end -- 2681
	end -- 2681
	local j = 0 -- 2694
	do -- 2694
		j = 0 -- 2695
		while j < #self.room.marks do -- 2695
			do -- 2695
				local m = self.room.marks[j + 1] -- 2696
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 2696
					goto __continue517 -- 2698
				end -- 2698
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 2698
					goto __continue517 -- 2702
				end -- 2702
				local col = STAND -- 2704
				if m.kind == 4 then -- 2704
					col = PASS_LINE -- 2706
				elseif m.kind == 5 then -- 2706
					col = BRICK_LINE -- 2708
				end -- 2708
				local mx = self:sx(m.x, w) -- 2710
				local my = self:sy(m.y, h) -- 2711
				draw:drawSegment( -- 2712
					Vec2(mx, my), -- 2712
					Vec2( -- 2712
						mx, -- 2712
						my + self:px(24) -- 2712
					), -- 2712
					self:px(1), -- 2712
					col -- 2712
				) -- 2712
			end -- 2712
			::__continue517:: -- 2712
			j = j + 1 -- 2695
		end -- 2695
	end -- 2695
	local t = 0 -- 2715
	do -- 2715
		t = 0 -- 2716
		while t < #self.room.marks do -- 2716
			do -- 2716
				local m = self.room.marks[t + 1] -- 2717
				if m.kind ~= 6 then -- 2717
					goto __continue523 -- 2719
				end -- 2719
				local mx = self:sx(m.x, w) -- 2721
				local my = self:sy(m.y, h) -- 2722
				draw:drawSegment( -- 2723
					Vec2(mx, my), -- 2723
					Vec2( -- 2723
						mx, -- 2723
						my + self:px(30) -- 2723
					), -- 2723
					self:px(1), -- 2723
					INK_DIM -- 2723
				) -- 2723
				self:drawBox( -- 2724
					draw, -- 2724
					w, -- 2724
					h, -- 2724
					m.x - 5, -- 2724
					m.x + 5, -- 2724
					m.y + 30, -- 2724
					m.y + 40, -- 2724
					CHECK -- 2724
				) -- 2724
			end -- 2724
			::__continue523:: -- 2724
			t = t + 1 -- 2716
		end -- 2716
	end -- 2716
	if self.room.key == "village" then -- 2716
		self:drawVillage(draw, w, h) -- 2727
	end -- 2727
	if self.room.key == "forest" then -- 2727
		self:drawDog(draw, w, h) -- 2730
	end -- 2730
end -- 2635
function Play.prototype.drawDog(self, draw, w, h) -- 2735
	local x = self.dogX -- 2736
	self:drawBox( -- 2737
		draw, -- 2737
		w, -- 2737
		h, -- 2737
		x - 14, -- 2737
		x + 14, -- 2737
		0, -- 2737
		20, -- 2737
		SCAV_BODY -- 2737
	) -- 2737
	self:drawBox( -- 2738
		draw, -- 2738
		w, -- 2738
		h, -- 2738
		x - 10, -- 2738
		x - 2, -- 2738
		20, -- 2738
		30, -- 2738
		SCAV_BODY -- 2738
	) -- 2738
	self:drawBox( -- 2739
		draw, -- 2739
		w, -- 2739
		h, -- 2739
		x + 2, -- 2739
		x + 10, -- 2739
		20, -- 2739
		30, -- 2739
		SCAV_HEAD -- 2739
	) -- 2739
	if self.dogState == "ear" or self.dogState == "chase" then -- 2739
		draw:drawSegment( -- 2741
			Vec2( -- 2741
				self:sx(x, w), -- 2741
				self:sy(30, h) -- 2741
			), -- 2741
			Vec2( -- 2742
				self:sx(x, w), -- 2742
				self:sy(40, h) -- 2742
			), -- 2742
			self:px(1), -- 2742
			DANGER -- 2742
		) -- 2742
	end -- 2742
end -- 2735
function Play.prototype.drawVillage(self, draw, w, h) -- 2747
	local bottle = self.room.bottle -- 2748
	if bottle ~= nil then -- 2748
		self:drawBox( -- 2750
			draw, -- 2750
			w, -- 2750
			h, -- 2750
			bottle.x - 14, -- 2750
			bottle.x + 14, -- 2750
			0, -- 2750
			64, -- 2750
			SOLID_FILL -- 2750
		) -- 2750
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 2750
			self:drawBottle( -- 2752
				draw, -- 2752
				w, -- 2752
				h, -- 2752
				bottle.x, -- 2752
				64 -- 2752
			) -- 2752
		end -- 2752
	end -- 2752
	self:drawBox( -- 2756
		draw, -- 2756
		w, -- 2756
		h, -- 2756
		300, -- 2756
		420, -- 2756
		44, -- 2756
		50, -- 2756
		FLOOR_DECK -- 2756
	) -- 2756
	self:drawBox( -- 2757
		draw, -- 2757
		w, -- 2757
		h, -- 2757
		300, -- 2757
		306, -- 2757
		0, -- 2757
		44, -- 2757
		FLOOR_DECK -- 2757
	) -- 2757
	self:drawBox( -- 2758
		draw, -- 2758
		w, -- 2758
		h, -- 2758
		414, -- 2758
		420, -- 2758
		0, -- 2758
		44, -- 2758
		FLOOR_DECK -- 2758
	) -- 2758
	local s = self.room.scavenger -- 2760
	if s ~= nil then -- 2760
		local sx0 = self.scavX -- 2762
		self:drawBox( -- 2763
			draw, -- 2763
			w, -- 2763
			h, -- 2763
			sx0 - 12, -- 2763
			sx0 + 12, -- 2763
			0, -- 2763
			s.h - 14, -- 2763
			SCAV_BODY -- 2763
		) -- 2763
		self:drawBox( -- 2764
			draw, -- 2764
			w, -- 2764
			h, -- 2764
			sx0 - 7, -- 2764
			sx0 + 7, -- 2764
			s.h - 14, -- 2764
			s.h, -- 2764
			SCAV_HEAD -- 2764
		) -- 2764
		if self.scavState == "turn" then -- 2764
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 2766
			draw:drawSegment( -- 2767
				Vec2( -- 2767
					self:sx(sx0, w), -- 2767
					self:sy(s.h - 6, h) -- 2767
				), -- 2767
				Vec2( -- 2767
					self:sx(fx, w), -- 2767
					self:sy(s.h - 6, h) -- 2767
				), -- 2767
				self:px(1), -- 2767
				INK -- 2767
			) -- 2767
		end -- 2767
	end -- 2767
	if self.hasBottle then -- 2767
		local p = self.player -- 2772
		self:drawBottle( -- 2773
			draw, -- 2773
			w, -- 2773
			h, -- 2773
			p.x + p.facing * 10, -- 2773
			p.y + p.h * 0.62 -- 2773
		) -- 2773
	end -- 2773
	if self.bottleFly ~= nil then -- 2773
		self:drawBottle( -- 2776
			draw, -- 2776
			w, -- 2776
			h, -- 2776
			self.bottleFly.x, -- 2776
			self.bottleFly.y -- 2776
		) -- 2776
	end -- 2776
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 2776
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 2779
		draw:drawCircle( -- 2780
			Vec2( -- 2780
				self:sx(self.bottleLandX, w), -- 2780
				self:sy(0, h) -- 2780
			), -- 2780
			self:px(r / ____exports.UNITS_PER_PX), -- 2780
			BRICK_LINE -- 2780
		) -- 2780
	end -- 2780
end -- 2747
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 2784
	self:drawBox( -- 2785
		draw, -- 2785
		w, -- 2785
		h, -- 2785
		x - 3, -- 2785
		x + 3, -- 2785
		y - 10, -- 2785
		y, -- 2785
		BOTTLE -- 2785
	) -- 2785
end -- 2784
function Play.prototype.drawTrace(self, draw, w, h) -- 2788
	local t = self.trace -- 2789
	if t == nil or self.traceT <= 0 then -- 2789
		return -- 2791
	end -- 2791
	draw:drawSegment( -- 2793
		Vec2( -- 2794
			self:sx(t.x0, w), -- 2794
			self:sy(t.y0, h) -- 2794
		), -- 2794
		Vec2( -- 2795
			self:sx(t.x1, w), -- 2795
			self:sy(t.y1, h) -- 2795
		), -- 2795
		self:px(1), -- 2796
		t.hit and AIM_HIT or INK_DIM -- 2796
	) -- 2796
end -- 2788
function Play.prototype.drawAim(self, draw, w, h) -- 2799
	local v = self.view -- 2801
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 2802
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 2803
	local dot = self:px(1) -- 2804
	local arm = self:px(3) -- 2805
	local gap = self:px(1) -- 2806
	draw:drawSegment( -- 2807
		Vec2(gx - arm - gap, gy), -- 2807
		Vec2(gx - gap, gy), -- 2807
		dot / 2, -- 2807
		AIM -- 2807
	) -- 2807
	draw:drawSegment( -- 2808
		Vec2(gx + gap, gy), -- 2808
		Vec2(gx + arm + gap, gy), -- 2808
		dot / 2, -- 2808
		AIM -- 2808
	) -- 2808
	draw:drawSegment( -- 2809
		Vec2(gx, gy - arm - gap), -- 2809
		Vec2(gx, gy - gap), -- 2809
		dot / 2, -- 2809
		AIM -- 2809
	) -- 2809
	draw:drawSegment( -- 2810
		Vec2(gx, gy + gap), -- 2810
		Vec2(gx, gy + arm + gap), -- 2810
		dot / 2, -- 2810
		AIM -- 2810
	) -- 2810
	if self.room.key == "village" and self.hasBottle then -- 2810
		local p = self.player -- 2814
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2816
		local dir = ____end.x >= p.x and 1 or -1 -- 2817
		local x0 = p.x + dir * 10 -- 2818
		local y0 = p.y + p.h * 0.7 -- 2819
		local T = BOTTLE_FLY_TIME -- 2820
		local vx = (____end.x - x0) / T -- 2821
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 2822
		local pxr = x0 -- 2823
		local pyr = y0 -- 2824
		local t = 1 -- 2825
		do -- 2825
			t = 1 -- 2826
			while t <= 12 do -- 2826
				local tt = t / 12 * T -- 2827
				local nx = x0 + vx * tt -- 2828
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 2829
				draw:drawSegment( -- 2830
					Vec2( -- 2830
						self:sx(pxr, w), -- 2830
						self:sy(pyr, h) -- 2830
					), -- 2830
					Vec2( -- 2830
						self:sx(nx, w), -- 2830
						self:sy(ny, h) -- 2830
					), -- 2830
					self:px(1) / 2, -- 2830
					BOTTLE -- 2830
				) -- 2830
				pxr = nx -- 2831
				pyr = ny -- 2832
				t = t + 1 -- 2826
			end -- 2826
		end -- 2826
		draw:drawCircle( -- 2834
			Vec2( -- 2834
				self:sx(____end.x, w), -- 2834
				self:sy(____end.y + 2, h) -- 2834
			), -- 2834
			self:px(2), -- 2834
			BOTTLE -- 2834
		) -- 2834
	end -- 2834
end -- 2799
return ____exports -- 2799