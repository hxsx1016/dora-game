-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____rooms = require("Script.watch.rooms") -- 13
local withOrigin = ____rooms.withOrigin -- 15
local ____run = require("Script.watch.run") -- 17
local createRun = ____run.createRun -- 17
local draftRoom = ____run.draftRoom -- 17
local mmss = ____run.mmss -- 17
local talentNames = ____run.talentNames -- 17
local ____clock = require("Script.watch.clock") -- 19
local STEP = ____clock.STEP -- 19
local ____escort = require("Script.watch.escort") -- 20
local CALM_REACH = ____escort.CALM_REACH -- 20
local Escort = ____escort.Escort -- 20
local FEAR_MAX = ____escort.FEAR_MAX -- 20
local safeAnchorX = ____escort.safeAnchorX -- 20
local ____depth = require("Script.watch.depth") -- 21
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 21
local INTERACT_DEPTH_REACH = ____depth.INTERACT_DEPTH_REACH -- 21
local inReachDepth = ____depth.inReachDepth -- 21
local overlapsDepth = ____depth.overlapsDepth -- 21
function makeActor(room, index) -- 3994
	local sp = room.spawns -- 3995
	if index < 0 or index >= #sp then -- 3995
		return { -- 3997
			x = 0, -- 3997
			y = 0, -- 3997
			depth = 0, -- 3997
			depthSpeed = 0, -- 3997
			vx = 0, -- 3997
			vy = 0, -- 3997
			w = CHILD_W, -- 3997
			h = CHILD_H, -- 3997
			onGround = true, -- 3997
			facing = 1, -- 3997
			crouch = false, -- 3997
			rollT = 0, -- 3997
			covered = false, -- 3997
			alive = false -- 3997
		} -- 3997
	end -- 3997
	local s = sp[index + 1] -- 3999
	local child = s.h <= CHILD_H -- 4000
	local ground = room.depth -- 4001
	local depth = ground == nil and 0 or math.max( -- 4002
		ground.min, -- 4002
		math.min(ground.max, s.depth or 0) -- 4002
	) -- 4002
	return { -- 4003
		x = s.x, -- 4004
		y = s.y, -- 4004
		depth = depth, -- 4004
		depthSpeed = 0, -- 4004
		vx = 0, -- 4004
		vy = 0, -- 4004
		w = child and CHILD_W or SOLDIER_W, -- 4005
		h = child and CHILD_H or SOLDIER_H, -- 4006
		onGround = true, -- 4007
		facing = 1, -- 4007
		crouch = false, -- 4007
		rollT = 0, -- 4007
		covered = false, -- 4007
		alive = true -- 4007
	} -- 4007
end -- 4007
function drawFigure(draw, play, w, h, a, body, head) -- 4011
	if not a.alive then -- 4011
		return -- 4013
	end -- 4013
	local x0 = a.x - a.w / 2 -- 4015
	local x1 = a.x + a.w / 2 -- 4016
	local y0 = a.y + a.depth -- 4017
	local y1 = y0 + a.h -- 4018
	play:drawBox( -- 4019
		draw, -- 4019
		w, -- 4019
		h, -- 4019
		x0, -- 4019
		x1, -- 4019
		y0, -- 4019
		y1 - a.h * 0.26, -- 4019
		body -- 4019
	) -- 4019
	play:drawBox( -- 4020
		draw, -- 4020
		w, -- 4020
		h, -- 4020
		x0 + 2, -- 4020
		x1 - 2, -- 4020
		y1 - a.h * 0.26, -- 4020
		y1, -- 4020
		head -- 4020
	) -- 4020
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 4022
	play:drawBox( -- 4023
		draw, -- 4023
		w, -- 4023
		h, -- 4023
		eyeX, -- 4023
		eyeX + 4, -- 4023
		y1 - a.h * 0.14, -- 4023
		y1 - a.h * 0.08, -- 4023
		INK -- 4023
	) -- 4023
end -- 4023
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 4027
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 4028
end -- 4027
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 4035
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 4036
end -- 4035
function rayInterval(origin, direction, min, max) -- 4043
	if direction == 0 then -- 4043
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4045
	end -- 4045
	local a = (min - origin) / direction -- 4047
	local b = (max - origin) / direction -- 4048
	return { -- 4049
		min = math.min(a, b), -- 4049
		max = math.max(a, b) -- 4049
	} -- 4049
end -- 4049
function hitBox(ray, box) -- 4053
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4054
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4055
	local enter = math.max(0, x.min, y.min) -- 4056
	local leave = math.min(99999, x.max, y.max) -- 4057
	if box.depth ~= nil then -- 4057
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4059
		enter = math.max(enter, depth.min) -- 4060
		leave = math.min(leave, depth.max) -- 4061
	end -- 4061
	return leave >= enter and enter or -1 -- 4063
end -- 4063
function drawCartShape(draw, play, w, h, c, axleX) -- 4066
	local half = c.bodyW / 2 -- 4067
	local x0 = axleX - half -- 4068
	local x1 = axleX + half -- 4069
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4070
	play:drawBox( -- 4071
		draw, -- 4071
		w, -- 4071
		h, -- 4071
		x0, -- 4071
		x1, -- 4071
		axleY, -- 4071
		axleY + c.bodyH, -- 4071
		CART_FILL -- 4071
	) -- 4071
	draw:drawCircle( -- 4072
		Vec2( -- 4072
			play:sx(x0 + c.bodyW * 0.28, w), -- 4072
			play:sy(axleY, h) -- 4072
		), -- 4072
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4072
		Color(52, 50, 48, 255) -- 4072
	) -- 4072
	draw:drawCircle( -- 4073
		Vec2( -- 4073
			play:sx(x1 - c.bodyW * 0.28, w), -- 4073
			play:sy(axleY, h) -- 4073
		), -- 4073
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4073
		Color(52, 50, 48, 255) -- 4073
	) -- 4073
	local cx = c.clothSide < 0 and x0 or x1 -- 4074
	play:drawBox( -- 4075
		draw, -- 4075
		w, -- 4075
		h, -- 4075
		cx - 10, -- 4075
		cx + 10, -- 4075
		axleY + c.bodyH, -- 4075
		axleY + c.bodyH + 18, -- 4075
		CLOTH -- 4075
	) -- 4075
end -- 4075
____exports.STEP = STEP -- 24
____exports.GRAVITY = 1000 -- 25
____exports.GATE_COUNT_END = 1440 -- 26
function ____exports.gateCountAtTick(tick) -- 28
	if tick >= ____exports.GATE_COUNT_END then -- 28
		return 20 -- 29
	end -- 29
	if tick >= 1260 then -- 29
		return 19 -- 30
	end -- 30
	if tick >= 1080 then -- 30
		return 18 -- 31
	end -- 31
	if tick >= 480 then -- 31
		return 11 + math.floor((tick - 480) * 7 / 600) -- 32
	end -- 32
	return 1 + math.floor(math.max(0, tick) / 48) -- 33
end -- 28
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 36
CHILD_W = 28 -- 74
CHILD_H = 64 -- 75
local CHILD_CROUCH_H = 36 -- 76
local CHILD_SPEED = 160 -- 77
local CHILD_SLOW = 80 -- 78
local CHILD_JUMP = 320 -- 79
SOLDIER_W = 30 -- 82
SOLDIER_H = 88 -- 83
local SOLDIER_SPEED = 264 -- 84
local ROLL_TIME = 0.35 -- 85
local ROLL_SPEED = 280 -- 86
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 88
local LEDGE_RISE = 60 -- 89
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 92
____exports.LOGIC_H = 180 -- 93
____exports.UNITS_PER_PX = 2 -- 94
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 96
local CAM_FOLLOW = 9 -- 97
local CAM_LOOK_UP = 46 -- 98
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 101
--- 握把触发半径。
____exports.CART_REACH = 70 -- 103
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 105
local CART_CLEAR = 44 -- 106
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 108
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 110
local CONSUMABLE_CAP = 1 -- 111
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 113
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 115
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 117
local FIRE_COOLDOWN = 150 -- 118
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 120
local ENEMY_RANGE = 760 -- 121
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 123
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 125
local DEPTH_SPEED_RATIO = 0.55 -- 126
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 127
INK = Color(232, 232, 228, 255) -- 129
local INK_DIM = Color(150, 152, 150, 255) -- 130
local BG_VOID = Color(8, 9, 10, 255) -- 131
local BG_FAR = Color(24, 26, 28, 255) -- 132
local BG_MID = Color(31, 34, 37, 255) -- 133
local GROUND = Color(112, 114, 112, 255) -- 134
local FLOOR_DECK = Color(66, 70, 72, 255) -- 135
local SOLID_FILL = Color(84, 86, 84, 255) -- 136
local SOLID_EDGE = Color(126, 130, 126, 255) -- 137
CART_FILL = Color(122, 78, 56, 255) -- 138
CLOTH = Color(178, 52, 46, 255) -- 139
local DANGER = Color(150, 54, 48, 46) -- 140
local DANGER_LINE = Color(178, 78, 64, 200) -- 141
local HOLE_FILL = Color(10, 11, 12, 255) -- 142
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 143
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 144
local CHILD_BODY = Color(214, 168, 96, 255) -- 145
local CHILD_HEAD = Color(232, 214, 186, 255) -- 146
local ENEMY_BODY = Color(176, 92, 84, 255) -- 147
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 148
local CHECK = Color(96, 186, 122, 255) -- 149
local STAND = Color(226, 186, 84, 255) -- 150
local AIM = Color(236, 236, 232, 230) -- 151
local AIM_HIT = Color(236, 96, 84, 255) -- 152
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 154
local SOFT_LINE = Color(140, 112, 80, 190) -- 155
local BRICK = Color(126, 118, 110, 70) -- 156
local BRICK_LINE = Color(160, 152, 142, 200) -- 157
local PASS = Color(96, 186, 122, 40) -- 158
local PASS_LINE = Color(96, 186, 122, 200) -- 159
local BOTTLE = Color(120, 186, 160, 255) -- 160
local SCAV_BODY = Color(128, 118, 96, 255) -- 161
local SCAV_HEAD = Color(196, 182, 158, 255) -- 162
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 249
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 250
	if zoom < 1 then -- 250
		zoom = 1 -- 252
	end -- 252
	return { -- 254
		zoom = zoom, -- 255
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 256
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 257
	} -- 257
end -- 249
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 280
	if key == "prologue" then -- 280
		return "prologue-wait" -- 282
	end -- 282
	if key == "street" then -- 282
		return "street-run" -- 285
	end -- 285
	if key == "gate" then -- 285
		return "gate-idle" -- 288
	end -- 288
	if key == "forest" then -- 288
		return "forest-run" -- 291
	end -- 291
	if key == "tower" then -- 291
		return "tower-wait" -- 294
	end -- 294
	return "run" -- 296
end -- 280
____exports.Play = __TS__Class() -- 299
local Play = ____exports.Play -- 299
Play.name = "Play" -- 299
function Play.prototype.____constructor(self, room, resume, run) -- 472
	self.enemies = {} -- 304
	self.boxes = {} -- 305
	self.floors = {} -- 306
	self.checkpoint = -1 -- 308
	self.flash = "" -- 310
	self.flashT = 0 -- 311
	self.traceT = 0 -- 314
	self.focusCart = false -- 316
	self.knocks = 0 -- 318
	self.knockT = 0 -- 319
	self.cartAxle = 0 -- 323
	self.cartDocked = false -- 325
	self.gripping = false -- 327
	self.gateOpen = false -- 329
	self.calmConsumed = false -- 331
	self.craftT = 0 -- 333
	self.nextDangerId = 1 -- 335
	self.wantRoom = "" -- 337
	self.carryCartAxle = -1 -- 339
	self.carryCartDocked = false -- 340
	self.checkpointCartAxle = -1 -- 342
	self.hasBottle = false -- 346
	self.bottleLandX = -1 -- 350
	self.bottleTargetX = -1 -- 351
	self.bottleTargetY = 0 -- 352
	self.bottleLandT = 0 -- 353
	self.aimHold = 0 -- 355
	self.scavX = 0 -- 357
	self.scavDir = 1 -- 358
	self.scavState = "patrol" -- 359
	self.scavT = 0 -- 360
	self.scavTargetX = 0 -- 361
	self.passed = false -- 363
	self.childMode = false -- 367
	self.phase = "" -- 369
	self.phaseTick = 0 -- 371
	self.gateTick = 0 -- 373
	self.countTick = 0 -- 375
	self.countArmed = false -- 377
	self.countPrevMove = 0 -- 379
	self.caughtT = 0 -- 381
	self.hp = 3 -- 383
	self.maxHp = 3 -- 384
	self.invulnT = 0 -- 390
	self.partnerStuck = 0 -- 392
	self.partnerLaneIdx = 0 -- 394
	self.partnerLaneHold = 0 -- 395
	self.coveredFlash = 0 -- 397
	self.coverHug = false -- 399
	self.coverNear = false -- 401
	self.coverEntity = "" -- 403
	self.coverBlocking = false -- 405
	self.gateNeedConfirm = false -- 407
	self.gateRestartArmed = true -- 409
	self.bottleAimX = -1 -- 411
	self.bottleAimY = 0 -- 412
	self.bottleSurfaceY = -1 -- 414
	self.bottleLandY = 0 -- 416
	self.events = {} -- 418
	self.eventSeq = 0 -- 420
	self.dogX = 0 -- 422
	self.dogDir = 1 -- 423
	self.dogState = "patrol" -- 424
	self.dogT = 0 -- 425
	self.dogTargetX = 0 -- 426
	self.scavSee = 0 -- 428
	self.scavChase = false -- 429
	self.gateSpawned = 0 -- 431
	self.gateFailCount = 0 -- 433
	self.isCampaign = false -- 437
	self.pickups = {} -- 441
	self.reloadT = 0 -- 443
	self.objectiveDone = false -- 447
	self.hint = "" -- 449
	self.roomStartTick = 0 -- 451
	self.cartHitT = 0 -- 453
	self.cartExposed = false -- 454
	self.paused = false -- 456
	self.ticks = 0 -- 458
	self.view = {zoom = 1, ox = 0, oy = 0} -- 460
	self.ox = 0 -- 462
	self.aimX = 0 -- 464
	self.aimY = 0 -- 465
	self.viewW = 0 -- 467
	self.viewH = 0 -- 468
	self.ox = room.originX -- 474
	self.room = withOrigin(room) -- 475
	local wr = self.room -- 476
	self.run = run or createRun() -- 477
	self.isCampaign = wr.campaign ~= nil -- 478
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 479
	self:buildWorld() -- 480
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 482
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 483
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 484
	self.player = makeActor(wr, playerIdx) -- 485
	self.partner = makeActor(wr, partnerIdx) -- 486
	self.phase = phaseOf(wr.key) -- 487
	if wr.story ~= nil then -- 487
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 489
	end -- 489
	self.cam.x = self.player.x -- 491
	self.cam.y = self.player.y + CAM_LOOK_UP -- 492
	self.cartAxle = wr.cart.startX -- 493
	self.escort = __TS__New( -- 494
		Escort, -- 494
		safeAnchorX(wr.marks) -- 494
	) -- 494
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 495
	if self.isCampaign then -- 495
		self:setupCampaign() -- 497
	else -- 497
		self:buildEnemies() -- 499
	end -- 499
	if resume ~= nil and resume.checkpoint > 0 then -- 499
		self.checkpoint = resume.checkpoint -- 503
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 503
			self.cartAxle = self.room.cart.endX -- 505
			self.cartDocked = true -- 506
			self.player.x = self.ox + 380 -- 509
			self.player.y = 0 -- 510
			self.player.vy = 0 -- 511
			self.player.onGround = true -- 512
			self.cam.x = self.player.x -- 513
			self.cam.y = self.player.y + CAM_LOOK_UP -- 514
		end -- 514
	end -- 514
end -- 472
function Play.prototype.buildWorld(self) -- 520
	local room = self.room -- 521
	self.boxes = {} -- 522
	self.floors = {} -- 523
	local i = 0 -- 524
	do -- 524
		i = 0 -- 525
		while i < #room.floors do -- 525
			local f = room.floors[i + 1] -- 526
			local ____self_floors_0 = self.floors -- 526
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 527
			i = i + 1 -- 525
		end -- 525
	end -- 525
	do -- 525
		i = 0 -- 529
		while i < #room.solids do -- 529
			local s = room.solids[i + 1] -- 530
			if not s.decorative then -- 530
				local ____self_boxes_12 = self.boxes -- 536
				local ____s_x_3 = s.x -- 537
				local ____temp_4 = s.x + s.w -- 537
				local ____s_y_5 = s.y -- 537
				local ____temp_6 = s.y + s.h -- 537
				local ____temp_1 -- 538
				if room.depth == nil then -- 538
					____temp_1 = nil -- 538
				else -- 538
					____temp_1 = s.depth -- 538
				end -- 538
				local ____temp_7 = s.passable == true -- 539
				local ____s_label_8 = s.label -- 539
				local ____s_id_9 = s.id -- 540
				local ____temp_10 = s.soft == true -- 540
				local ____temp_11 = s.hidden == true -- 540
				local ____temp_2 -- 541
				if s.breakable == nil then -- 541
					____temp_2 = nil -- 541
				else -- 541
					____temp_2 = __TS__ObjectAssign({}, s.breakable) -- 541
				end -- 541
				____self_boxes_12[#____self_boxes_12 + 1] = { -- 536
					x0 = ____s_x_3, -- 537
					x1 = ____temp_4, -- 537
					y0 = ____s_y_5, -- 537
					y1 = ____temp_6, -- 537
					depth = ____temp_1, -- 538
					passable = ____temp_7, -- 539
					label = ____s_label_8, -- 539
					id = ____s_id_9, -- 540
					soft = ____temp_10, -- 540
					hidden = ____temp_11, -- 540
					breakable = ____temp_2, -- 541
					interact = s.interact -- 542
				} -- 542
			end -- 542
			i = i + 1 -- 529
		end -- 529
	end -- 529
	do -- 529
		i = 0 -- 546
		while i < #room.stairs do -- 546
			local st = room.stairs[i + 1] -- 547
			local n = st.steps + 1 -- 548
			local stepW = (st.x1 - st.x0) / n -- 549
			local k = 0 -- 550
			do -- 550
				k = 0 -- 551
				while k < n do -- 551
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 552
					local x0 = st.x0 + stepW * k -- 553
					local ____self_boxes_13 = self.boxes -- 553
					____self_boxes_13[#____self_boxes_13 + 1] = { -- 555
						x0 = x0, -- 555
						x1 = x0 + stepW, -- 555
						y0 = -8, -- 555
						y1 = y, -- 555
						passable = true -- 555
					} -- 555
					k = k + 1 -- 551
				end -- 551
			end -- 551
			i = i + 1 -- 546
		end -- 546
	end -- 546
end -- 520
function Play.prototype.setupCampaign(self) -- 564
	local wr = self.room -- 565
	local c = wr.campaign -- 566
	if c == nil then -- 566
		return -- 568
	end -- 568
	self.roomStartTick = self.run.ticks -- 570
	if wr.key == "s1-crossroad" then -- 570
		self.run.joined = true -- 573
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 573
		local ____self_run_15 = self.run -- 576
		local ____temp_14 -- 576
		if wr.key == "s2-drygoods" then -- 576
			____temp_14 = self.run.route ~= "drygoods" -- 576
		else -- 576
			____temp_14 = false -- 576
		end -- 576
		____self_run_15.joined = ____temp_14 -- 576
	end -- 576
	local x = wr.minX + 60 -- 578
	local y = 0 -- 579
	local depth = 0 -- 580
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 580
		x = wr.minX + 210 -- 582
		depth = -32 -- 583
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 583
		x = wr.minX + 40 -- 585
		y = 32 -- 586
		depth = 32 -- 587
	end -- 587
	self.player = { -- 589
		x = x, -- 590
		y = y, -- 590
		depth = depth, -- 590
		depthSpeed = 0, -- 590
		vx = 0, -- 590
		vy = 0, -- 590
		w = SOLDIER_W, -- 591
		h = SOLDIER_H, -- 591
		onGround = y <= 0, -- 591
		facing = 1, -- 591
		crouch = false, -- 591
		rollT = 0, -- 591
		covered = false, -- 591
		alive = true -- 591
	} -- 591
	self.partner = { -- 593
		x = x + 60, -- 594
		y = y, -- 594
		depth = depth, -- 594
		depthSpeed = 0, -- 594
		vx = 0, -- 594
		vy = 0, -- 594
		w = CHILD_W, -- 595
		h = CHILD_H, -- 595
		onGround = y <= 0, -- 595
		facing = 1, -- 595
		crouch = false, -- 595
		rollT = 0, -- 595
		covered = false, -- 595
		alive = true -- 595
	} -- 595
	self.cam.x = x -- 597
	self.cam.y = y + CAM_LOOK_UP -- 598
	self.phase = "run" -- 599
	self.hp = self.maxHp -- 600
	local trial = self.run.trial -- 601
	if trial ~= nil then -- 601
		draftRoom(trial, wr.key) -- 603
		self.maxHp = self.maxHp + trial.ranks.vitality -- 604
		self.hp = trial.hp -- 605
	end -- 605
	self:buildEnemies() -- 607
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 608
	local i = 0 -- 609
	do -- 609
		i = 0 -- 610
		while i < #self.boxes do -- 610
			do -- 610
				local b = self.boxes[i + 1] -- 611
				if b.id == nil then -- 611
					goto __continue39 -- 613
				end -- 613
				local st = self.run.props[b.id] -- 615
				if st ~= nil then -- 615
					b.broken = st.broken -- 617
					local ____temp_16 -- 618
					if b.breakable == nil then -- 618
						____temp_16 = nil -- 618
					else -- 618
						____temp_16 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 618
					end -- 618
					b.breakable = ____temp_16 -- 618
					b.hidden = b.hidden == true and st.revealed ~= true -- 619
					if b.hidden then -- 619
						b.broken = true -- 621
					end -- 621
				elseif b.hidden == true then -- 621
					b.broken = true -- 625
				end -- 625
			end -- 625
			::__continue39:: -- 625
			i = i + 1 -- 610
		end -- 610
	end -- 610
	if wr.cart.bodyW > 0 then -- 610
		self.cartAxle = wr.cart.startX -- 629
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 629
			self.cartAxle = wr.cart.endX -- 631
			self.cartDocked = true -- 632
		end -- 632
	end -- 632
	do -- 632
		i = 0 -- 635
		while i < #self.pickups do -- 635
			local pk = self.pickups[i + 1] -- 636
			if self.run.taken[pk.id] == true then -- 636
				pk.id = "" -- 638
			end -- 638
			i = i + 1 -- 635
		end -- 635
	end -- 635
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 641
end -- 564
function Play.prototype.log(self, line) -- 644
	local ____self_run_log_17 = self.run.log -- 644
	____self_run_log_17[#____self_run_log_17 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 645
	if #self.run.log > 120 then -- 645
		table.remove(self.run.log, 1) -- 647
	end -- 647
end -- 644
function Play.prototype.buildEnemies(self) -- 651
	self.enemies = {} -- 652
	if self.isCampaign then -- 652
		local i = 0 -- 654
		do -- 654
			i = 0 -- 655
			while i < #self.room.spawns do -- 655
				local sp = self.room.spawns[i + 1] -- 656
				local kind = sp.kind or "gunner" -- 657
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 658
				local ____self_enemies_18 = self.enemies -- 658
				____self_enemies_18[#____self_enemies_18 + 1] = { -- 659
					x = sp.x, -- 660
					y = sp.y, -- 660
					depth = sp.depth, -- 660
					w = 26, -- 660
					h = sp.h, -- 660
					alive = true, -- 660
					hitT = 0, -- 660
					warnT = 0, -- 660
					fireCd = 40, -- 660
					kind = kind, -- 661
					shieldHp = hp, -- 661
					shieldHpMax = hp, -- 661
					drop = sp.drop or "none", -- 661
					homeX = sp.x, -- 662
					swingT = 0, -- 662
					awake = false, -- 662
					squad = i -- 662
				} -- 662
				i = i + 1 -- 655
			end -- 655
		end -- 655
		return -- 665
	end -- 665
	if self.room.key == "checkpoint" then -- 665
		local ____self_enemies_19 = self.enemies -- 665
		____self_enemies_19[#____self_enemies_19 + 1] = { -- 668
			x = self.ox + 430, -- 668
			y = 0, -- 668
			w = 26, -- 668
			h = 84, -- 668
			alive = true, -- 668
			hitT = 0, -- 668
			warnT = 0, -- 668
			fireCd = 0 -- 668
		} -- 668
		local ____self_enemies_20 = self.enemies -- 668
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 669
			x = self.ox + 505, -- 669
			y = 0, -- 669
			w = 26, -- 669
			h = 84, -- 669
			alive = true, -- 669
			hitT = 0, -- 669
			warnT = 0, -- 669
			fireCd = 0 -- 669
		} -- 669
		return -- 670
	end -- 670
	if self.room.key == "street" then -- 670
		local ____self_enemies_21 = self.enemies -- 670
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 674
			x = self.ox + 340, -- 674
			y = 0, -- 674
			w = 26, -- 674
			h = 84, -- 674
			alive = true, -- 674
			hitT = 0, -- 674
			warnT = 0, -- 674
			fireCd = 0 -- 674
		} -- 674
		local ____self_enemies_22 = self.enemies -- 674
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 675
			x = self.ox + 560, -- 675
			y = 0, -- 675
			w = 26, -- 675
			h = 84, -- 675
			alive = true, -- 675
			hitT = 0, -- 675
			warnT = 0, -- 675
			fireCd = 0 -- 675
		} -- 675
	end -- 675
end -- 651
function Play.prototype.emit(self, name, data) -- 681
	local ____self_events_23 = self.events -- 681
	____self_events_23[#____self_events_23 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 682
	self.eventSeq = self.eventSeq + 1 -- 683
	if #self.events > 256 then -- 683
		table.remove(self.events, 1) -- 685
	end -- 685
end -- 681
function Play.prototype.drainEvents(self) -- 693
	local out = self.events -- 694
	self.events = {} -- 695
	return out -- 696
end -- 693
function Play.prototype.adoptEvents(self, events) -- 705
	if #events == 0 then -- 705
		return -- 707
	end -- 707
	local keep = {} -- 709
	local i = 0 -- 710
	do -- 710
		i = 0 -- 711
		while i < #events do -- 711
			do -- 711
				local e = events[i + 1] -- 712
				if e.name == "knock" and e.data.room ~= self.room.key then -- 712
					goto __continue63 -- 714
				end -- 714
				keep[#keep + 1] = e -- 716
			end -- 716
			::__continue63:: -- 716
			i = i + 1 -- 711
		end -- 711
	end -- 711
	if #keep == 0 then -- 711
		return -- 719
	end -- 719
	self.events = __TS__ArrayConcat(keep, self.events) -- 721
	do -- 721
		i = 0 -- 722
		while i < #self.events do -- 722
			self.events[i + 1].seq = i -- 723
			i = i + 1 -- 722
		end -- 722
	end -- 722
	self.eventSeq = #self.events -- 725
end -- 705
function Play.prototype.chooseTalent(self, slot) -- 728
	local trial = self.run.trial -- 729
	local talent = trial and trial.offers[slot + 1] -- 730
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 730
		return -- 731
	end -- 731
	local ____trial_ranks_26, ____talent_27 = trial.ranks, talent -- 731
	____trial_ranks_26[____talent_27] = ____trial_ranks_26[____talent_27] + 1 -- 732
	trial.offers = {} -- 733
	if talent == "vitality" then -- 733
		self.maxHp = self.maxHp + 1 -- 735
		self.hp = self.hp + 1 -- 736
		trial.hp = self.hp -- 737
	end -- 737
	self:flashSet(talentNames[talent], 1.2) -- 739
end -- 728
function Play.prototype.reloadTicks(self) -- 742
	local ____temp_30 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 743
	local ____opt_28 = self.run.trial -- 743
	return math.max(6, ____temp_30 - 6 * (____opt_28 and ____opt_28.ranks.reload or 0)) -- 743
end -- 742
function Play.prototype.update(self, dt, input) -- 746
	local trial = self.run.trial -- 747
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 747
		return -- 748
	end -- 748
	if input.pause.pressed then -- 748
		self.paused = not self.paused -- 750
	end -- 750
	if self.flashT > 0 then -- 750
		self.flashT = self.flashT - dt -- 753
		if self.flashT <= 0 then -- 753
			self.flash = "" -- 755
		end -- 755
	end -- 755
	if self.traceT > 0 then -- 755
		self.traceT = self.traceT - dt -- 759
		if self.traceT <= 0 then -- 759
			self.trace = nil -- 761
		end -- 761
	end -- 761
	if self.paused then -- 761
		self:updateCamera(dt) -- 765
		return -- 766
	end -- 766
	self.ticks = self.ticks + 1 -- 769
	if self.invulnT > 0 then -- 769
		self.invulnT = self.invulnT - 1 -- 773
	end -- 773
	if self.isCampaign then -- 773
		local ____self_run_31, ____ticks_32 = self.run, "ticks" -- 773
		____self_run_31[____ticks_32] = ____self_run_31[____ticks_32] + 1 -- 776
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 777
	end -- 777
	local p = self.player -- 779
	self:stepPlayer(p, dt, input) -- 780
	self:refreshCover(p, input) -- 782
	if self.isCampaign then -- 782
		self:stepCampaign(dt, input) -- 784
		self:stepCampaignPartner(dt) -- 785
	end -- 785
	if trial == nil or not self.run.finished then -- 785
		self:stepEnemies(dt, input) -- 788
	end -- 788
	if trial ~= nil then -- 788
		trial.hp = self.hp -- 789
	end -- 789
	if not self.isCampaign then -- 789
		self:stepStory(dt, input) -- 791
		self:stepEscort(dt, input) -- 792
		self:stepVillage(dt, input) -- 793
		self:stepChase(dt, input) -- 794
		self:stepInteract(dt, input) -- 795
	end -- 795
	self:updateGate() -- 797
	self:updateCamera(dt) -- 798
end -- 746
function Play.prototype.underLowArch(self, a) -- 805
	local arch = self.room.arch -- 806
	if arch.h <= 0 then -- 806
		return false -- 808
	end -- 808
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 808
		return false -- 811
	end -- 811
	local top = arch.y + arch.h -- 813
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 814
end -- 805
function Play.prototype.coverAt(self, a) -- 821
	local best = nil -- 822
	local bestGap = 24 -- 823
	local half = a.w / 2 -- 824
	local i = 0 -- 825
	do -- 825
		i = 0 -- 826
		while i < #self.boxes do -- 826
			do -- 826
				local b = self.boxes[i + 1] -- 827
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 827
					goto __continue91 -- 829
				end -- 829
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 829
					goto __continue91 -- 832
				end -- 832
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 834
				if gap < bestGap then -- 834
					bestGap = gap -- 836
					best = b -- 837
				end -- 837
			end -- 837
			::__continue91:: -- 837
			i = i + 1 -- 826
		end -- 826
	end -- 826
	return best -- 840
end -- 821
function Play.prototype.nearCover(self, a) -- 843
	return self:coverAt(a) ~= nil -- 844
end -- 843
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 848
	if enemy == nil then -- 848
		return false -- 850
	end -- 850
	local fromRight = enemy.x >= a.x -- 852
	local edge = fromRight and b.x0 or b.x1 -- 853
	local ____fromRight_33 -- 854
	if fromRight then -- 854
		____fromRight_33 = edge >= a.x - 0.001 and edge <= enemy.x -- 854
	else -- 854
		____fromRight_33 = edge <= a.x + 0.001 and edge >= enemy.x -- 855
	end -- 855
	local between = ____fromRight_33 -- 854
	local separation = enemy.x - a.x -- 856
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 857
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 858
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 859
end -- 848
function Play.prototype.nearestEnemy(self, a) -- 862
	local best -- 863
	local bestD = 1000000000 -- 864
	local i = 0 -- 865
	do -- 865
		i = 0 -- 866
		while i < #self.enemies do -- 866
			do -- 866
				local e = self.enemies[i + 1] -- 867
				if not e.alive then -- 867
					goto __continue100 -- 869
				end -- 869
				local d = math.abs(e.x - a.x) -- 871
				if d < bestD then -- 871
					bestD = d -- 873
					best = e -- 874
				end -- 874
			end -- 874
			::__continue100:: -- 874
			i = i + 1 -- 866
		end -- 866
	end -- 866
	return best -- 877
end -- 862
function Play.prototype.refreshCover(self, a, input) -- 881
	if self.childMode then -- 881
		self.coverNear = false -- 883
		self.coverHug = false -- 884
		self.coverEntity = "" -- 885
		self.coverBlocking = false -- 886
		a.covered = false -- 887
		return -- 888
	end -- 888
	local b = self:coverAt(a) -- 890
	self.coverNear = b ~= nil -- 891
	a.covered = self.coverNear and input.cover.held -- 892
	self.coverHug = a.covered -- 893
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 894
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 895
		b, -- 895
		a, -- 895
		self:nearestEnemy(a) -- 895
	) -- 895
end -- 881
function Play.prototype.cartHandleInReach(self, a) -- 899
	if a == nil then -- 899
		a = self.player -- 899
	end -- 899
	local c = self.room.cart -- 900
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 900
		return false -- 902
	end -- 902
	local handleX = self.cartAxle + c.handleOffset -- 904
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 905
end -- 899
function Play.prototype.nearLowLedge(self, a) -- 910
	local reach = 26 -- 911
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 912
	local x1 = x0 + reach -- 913
	local i = 0 -- 914
	do -- 914
		i = 0 -- 915
		while i < #self.boxes do -- 915
			do -- 915
				local b = self.boxes[i + 1] -- 916
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 916
					goto __continue109 -- 918
				end -- 918
				local rise = b.y1 - a.y -- 920
				if rise > 0 and rise <= LEDGE_RISE then -- 920
					return true -- 922
				end -- 922
			end -- 922
			::__continue109:: -- 922
			i = i + 1 -- 915
		end -- 915
	end -- 915
	return false -- 925
end -- 910
function Play.prototype.stepPlayer(self, a, dt, input) -- 928
	a.depthSpeed = 0 -- 929
	if not a.alive then -- 929
		return -- 931
	end -- 931
	local isChild = self.childMode -- 933
	local lowArch = isChild and self:underLowArch(a) -- 935
	if self:storyLocked() then -- 935
		a.vx = 0 -- 938
		a.crouch = isChild and lowArch -- 939
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 940
		self:fallY(a, dt) -- 941
		return -- 942
	end -- 942
	if not isChild and self.escort.state == "calming" then -- 942
		a.crouch = false -- 946
		a.h = SOLDIER_H -- 947
		a.vx = 0 -- 948
		self:fallY(a, dt) -- 949
		return -- 950
	end -- 950
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 952
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 953
	local nearCover = not isChild and self:nearCover(a) -- 954
	a.covered = nearCover and input.cover.held -- 955
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 957
	if a.rollT > 0 then -- 957
		a.rollT = a.rollT - dt -- 961
		a.vx = a.facing * ROLL_SPEED -- 962
		self:slideX(a, a.vx * dt) -- 963
		self:fallY(a, dt) -- 964
		if a.rollT <= 0 then -- 964
			self:flashSet("翻滚结束", 0.5) -- 966
		end -- 966
		return -- 968
	end -- 968
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 968
		if input.moveX ~= 0 then -- 968
			a.facing = input.moveX > 0 and 1 or -1 -- 973
		end -- 973
		if self:nearLowLedge(a) then -- 973
			a.vy = SOLDIER_JUMP -- 977
			a.onGround = false -- 978
			self:flashSet("翻上去", 0.3) -- 979
			return -- 980
		end -- 980
		a.rollT = ROLL_TIME -- 982
		self:flashSet("翻滚", 0.3) -- 983
		return -- 984
	end -- 984
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 987
	if isChild then -- 987
		if input.cover.held then -- 987
			speed = CHILD_SLOW -- 990
		end -- 990
		if a.crouch then -- 990
			speed = CHILD_SLOW -- 993
		end -- 993
	elseif a.covered then -- 993
		speed = SOLDIER_SPEED * 0.45 -- 996
	end -- 996
	local handsBusy = self.gripping or gripIntent -- 1000
	local dir = self.gripping and 0 or input.moveX -- 1001
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1002
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1003
	if dir ~= 0 then -- 1003
		a.facing = dir > 0 and 1 or -1 -- 1005
	end -- 1005
	a.vx = dir * speed * diagonal -- 1007
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1007
		a.vy = CHILD_JUMP -- 1011
		a.onGround = false -- 1012
		self:flashSet("跳", 0.25) -- 1013
	end -- 1013
	local previousDepth = a.depth -- 1017
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1018
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1019
	self:slideX(a, a.vx * dt) -- 1020
	self:fallY(a, dt) -- 1021
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1021
		self:shoot(a) -- 1025
	end -- 1025
end -- 928
function Play.prototype.stepPartner(self, p, dt) -- 1030
	local a = self.partner -- 1031
	if not a.alive then -- 1031
		return -- 1033
	end -- 1033
	a.crouch = false -- 1035
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1036
	a.vx = 0 -- 1037
	a.depthSpeed = 0 -- 1038
	self:fallY(a, dt) -- 1039
end -- 1030
function Play.prototype.stepEscort(self, dt, input) -- 1046
	local a = self.partner -- 1047
	a.depthSpeed = 0 -- 1048
	if not a.alive then -- 1048
		return -- 1050
	end -- 1050
	if not self:escortOn() then -- 1050
		a.vx = 0 -- 1053
		self:fallY(a, dt) -- 1054
		return -- 1055
	end -- 1055
	local p = self.player -- 1057
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1058
	local hadKnock1 = self.escort.knock1 -- 1059
	local hadKnock2 = self.escort.knock2 -- 1060
	self.calmConsumed = self.escort:update( -- 1061
		input, -- 1061
		p.x, -- 1061
		p.facing, -- 1061
		a.x, -- 1061
		dist -- 1061
	) -- 1061
	if not hadKnock1 and self.escort.knock1 then -- 1061
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1064
	end -- 1064
	if not hadKnock2 and self.escort.knock2 then -- 1064
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1067
	end -- 1067
	a.crouch = self.escort.crouchPose -- 1069
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1070
	if not self.escort.stopped then -- 1070
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1072
		local previousDepth = a.depth -- 1073
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1074
		local distance = math.max( -- 1075
			-travel, -- 1075
			math.min(travel, targetDepth - previousDepth) -- 1075
		) -- 1075
		self:slideDepth(a, distance) -- 1076
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1077
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1077
			a.vy = CHILD_JUMP -- 1079
			a.onGround = false -- 1080
		end -- 1080
	end -- 1080
	local dir = self.escort:moveDir(a.x) -- 1083
	a.vx = dir * CHILD_SPEED -- 1084
	if dir ~= 0 then -- 1084
		a.facing = dir -- 1086
		local before = a.x -- 1087
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1088
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1088
			a.vy = CHILD_JUMP -- 1091
			a.onGround = false -- 1092
		end -- 1092
	end -- 1092
	self:fallY(a, dt) -- 1095
end -- 1046
function Play.prototype.escortOn(self) -- 1099
	if self.room.key == "checkpoint" then -- 1099
		return true -- 1101
	end -- 1101
	if self.room.key == "prologue" then -- 1101
		return self.phase == "prologue-follow" -- 1104
	end -- 1104
	return self.room.key == "street" -- 1106
end -- 1099
function Play.prototype.storyLocked(self) -- 1110
	if self.caughtT > 0 then -- 1110
		return true -- 1112
	end -- 1112
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1112
		return true -- 1115
	end -- 1115
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1115
		return true -- 1118
	end -- 1118
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1118
		return true -- 1121
	end -- 1121
	return false -- 1123
end -- 1110
function Play.prototype.swapToChild(self, x) -- 1127
	local tmp = self.player -- 1128
	self.player = self.partner -- 1129
	self.partner = tmp -- 1130
	self.childMode = true -- 1131
	self.player.alive = true -- 1132
	self.player.x = self.ox + x -- 1133
	self.player.y = 0 -- 1134
	self.player.depth = 0 -- 1135
	self.player.depthSpeed = 0 -- 1136
	self.player.vy = 0 -- 1137
	self.player.vx = 0 -- 1138
	self.player.onGround = true -- 1139
	self.player.crouch = false -- 1140
	self.player.h = CHILD_H -- 1141
	self.player.facing = 1 -- 1142
	self.partner.alive = true -- 1143
	self.cam.x = self.player.x -- 1144
end -- 1127
function Play.prototype.stepStory(self, dt, input) -- 1148
	if self.room.key == "prologue" then -- 1148
		self:stepPrologue(dt, input) -- 1150
	elseif self.room.key == "street" then -- 1150
		self:stepStreet(dt, input) -- 1152
	elseif self.room.key == "gate" then -- 1152
		self:stepGate(dt, input) -- 1154
	elseif self.room.key == "tower" then -- 1154
		self:stepTower(dt, input) -- 1156
	end -- 1156
end -- 1148
function Play.prototype.stepPrologue(self, dt, input) -- 1161
	local child = self.partner -- 1162
	if self.phase == "prologue-wait" then -- 1162
		child.crouch = true -- 1164
		child.h = CHILD_CROUCH_H -- 1165
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1166
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1168
		if near and input.interact.pressed then -- 1168
			self.phase = "prologue-give" -- 1170
			self.phaseTick = 0 -- 1171
			self:flashSet("递出针套", 1) -- 1172
		end -- 1172
		return -- 1174
	end -- 1174
	if self.phase == "prologue-give" then -- 1174
		self.phaseTick = self.phaseTick + 1 -- 1177
		if self.phaseTick == 12 then -- 1177
			self:flashSet("针套递过去", 0.7) -- 1179
		elseif self.phaseTick == 36 then -- 1179
			self:flashSet("纸条塞进针套", 0.9) -- 1181
		elseif self.phaseTick >= 60 then -- 1181
			self.phase = "prologue-follow" -- 1183
			self.phaseTick = 0 -- 1184
			child.crouch = false -- 1185
			child.h = CHILD_H -- 1186
			self:flashSet("她跟上了", 1.2) -- 1187
		end -- 1187
		return -- 1189
	end -- 1189
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1189
		self:requestRoom("street", "序章跟到门口") -- 1193
		self:flashSet("进街道", 1.2) -- 1194
	end -- 1194
end -- 1161
function Play.prototype.stepStreet(self, dt, input) -- 1199
	local p = self.player -- 1200
	local c = self.partner -- 1201
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1201
		self:requestRoom("checkpoint", "两人都到街尾") -- 1203
		self:flashSet("到检查站", 1.2) -- 1204
	end -- 1204
end -- 1199
function Play.prototype.stepGate(self, dt, input) -- 1209
	local ____temp_34 -- 1210
	if self.room.story == nil then -- 1210
		____temp_34 = nil -- 1210
	else -- 1210
		____temp_34 = self.room.story.gate -- 1210
	end -- 1210
	local g = ____temp_34 -- 1210
	if g == nil then -- 1210
		return -- 1212
	end -- 1212
	local p = self.player -- 1214
	if self.phase == "gate-idle" then -- 1214
		local a = self.partner -- 1217
		local gap = g.waitX - a.x -- 1218
		if math.abs(gap) > 3 then -- 1218
			a.facing = gap > 0 and 1 or -1 -- 1220
			a.vx = a.facing * CHILD_SPEED -- 1221
			local beforeX = a.x -- 1222
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1223
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1223
				a.vy = CHILD_JUMP -- 1225
				a.onGround = false -- 1226
			end -- 1226
			self:fallY(a, dt) -- 1228
		else -- 1228
			a.vx = 0 -- 1230
			a.x = g.waitX -- 1231
		end -- 1231
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1234
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1235
		if self.gateNeedConfirm then -- 1235
			if not input.interact.held then -- 1235
				self.gateRestartArmed = true -- 1240
			end -- 1240
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1240
				self.gateNeedConfirm = false -- 1243
				self.gateRestartArmed = true -- 1244
				self.phase = "gate-hold" -- 1245
				self.gateTick = 0 -- 1246
				self.gateSpawned = 0 -- 1247
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1248
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1249
			end -- 1249
			return -- 1251
		end -- 1251
		if atWinch and atWait then -- 1251
			self.phase = "gate-hold" -- 1254
			self.gateTick = 0 -- 1255
			self.gateSpawned = 0 -- 1256
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1257
		end -- 1257
		return -- 1259
	end -- 1259
	if self.phase == "gate-hold" then -- 1259
		self.gateTick = self.gateTick + 1 -- 1262
		local marks = {0, 540, 900, 1500} -- 1264
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1264
			local idx = self.gateSpawned -- 1266
			local ____self_enemies_35 = self.enemies -- 1266
			____self_enemies_35[#____self_enemies_35 + 1] = { -- 1267
				x = self.ox + 620 + idx * 62, -- 1268
				y = 0, -- 1268
				w = 26, -- 1268
				h = 84, -- 1268
				alive = true, -- 1269
				hitT = 0, -- 1269
				warnT = 0, -- 1269
				fireCd = 90 + idx * 45 -- 1269
			} -- 1269
			self.gateSpawned = self.gateSpawned + 1 -- 1271
			self:flashSet( -- 1272
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1272
				0.9 -- 1272
			) -- 1272
		end -- 1272
		if self.gateTick == 900 then -- 1272
			self:flashSet("灯灭了", 1) -- 1275
		elseif self.gateTick == 2100 then -- 1275
			self:flashSet("门底压下来了", 1) -- 1277
		end -- 1277
		if self.gateTick >= g.holdTicks then -- 1277
			self.phase = "gate-send" -- 1280
			self.phaseTick = 0 -- 1281
			self.enemies = {} -- 1283
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1284
		end -- 1284
		return -- 1286
	end -- 1286
	if self.phase == "gate-send" then -- 1286
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1289
		if near and input.interact.pressed then -- 1289
			self:swapToChild(g.doorX + 30) -- 1291
			self.phase = "gate-count" -- 1292
			self.countTick = 0 -- 1293
			self.countArmed = false -- 1295
			self.countPrevMove = input.moveX -- 1296
			self:flashSet("门开了 · 送她出去", 1.8) -- 1297
		end -- 1297
		return -- 1299
	end -- 1299
	if self.phase == "gate-count" then -- 1299
		self.countTick = self.countTick + 1 -- 1302
		if self.countTick == 360 then -- 1302
			self:flashSet("门关上", 0.9) -- 1304
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 1304
			self:flashSet("数到二十", 2.2) -- 1306
		end -- 1306
		local prevMove = self.countPrevMove -- 1310
		self.countPrevMove = input.moveX -- 1311
		if self.countTick >= ____exports.GATE_COUNT_END then -- 1311
			if prevMove <= 0 and input.moveX > 0 then -- 1311
				self.countArmed = true -- 1314
			end -- 1314
			if self.countArmed and input.moveX > 0 then -- 1314
				self.phase = "gate-walk" -- 1317
				self.phaseTick = 0 -- 1318
				self:flashSet("她迈出第一步", 1.4) -- 1319
			end -- 1319
		end -- 1319
		return -- 1322
	end -- 1322
	if self.player.x >= g.exitX then -- 1322
		self:requestRoom("outside", "走出城门") -- 1326
		self:flashSet("出城门 · 城外", 1.4) -- 1327
	end -- 1327
end -- 1209
function Play.prototype.stepTower(self, dt, input) -- 1332
	local ____temp_36 -- 1333
	if self.room.story == nil then -- 1333
		____temp_36 = nil -- 1333
	else -- 1333
		____temp_36 = self.room.story.tower -- 1333
	end -- 1333
	local t = ____temp_36 -- 1333
	if t == nil then -- 1333
		return -- 1335
	end -- 1335
	if self.phase == "tower-wait" then -- 1335
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1338
		if near and input.interact.pressed then -- 1338
			self.phase = "tower-knock" -- 1340
			self.phaseTick = 0 -- 1341
			self.knocks = 1 -- 1342
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1343
			self:flashSet("敲一下", 0.6) -- 1344
		end -- 1344
		return -- 1346
	end -- 1346
	if self.phase == "tower-knock" then -- 1346
		self.phaseTick = self.phaseTick + 1 -- 1349
		if self.phaseTick == 12 then -- 1349
			self.knocks = 2 -- 1351
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1352
			self:flashSet("敲两下 · 第二声", 1) -- 1353
		elseif self.phaseTick >= t.knockTicks then -- 1353
			self.phase = "tower-given" -- 1355
			self.phaseTick = 0 -- 1356
			self:flashSet("门开了 · 提灯", 1.4) -- 1357
		end -- 1357
		return -- 1359
	end -- 1359
	if self.phase == "tower-given" then -- 1359
		self.phaseTick = self.phaseTick + 1 -- 1362
		if self.phaseTick == 60 then -- 1362
			self:flashSet("她递出针套和纸条", 1.6) -- 1364
		elseif self.phaseTick == 120 then -- 1364
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1366
		elseif self.phaseTick >= 180 then -- 1366
			self.phase = "tower-end" -- 1368
			self.phaseTick = 0 -- 1369
			self:flashSet("片尾 · E 再玩一次", 3) -- 1370
		end -- 1370
		return -- 1372
	end -- 1372
	if input.interact.pressed or input.retry.pressed then -- 1372
		self:requestRoom("prologue", "片尾再玩") -- 1375
		self:flashSet("回到序章", 1.4) -- 1376
	end -- 1376
end -- 1332
function Play.prototype.stepChase(self, dt, input) -- 1381
	if self.caughtT > 0 then -- 1381
		self.caughtT = self.caughtT - dt -- 1383
		if self.caughtT <= 0 then -- 1383
			self:recoverFromCaught() -- 1385
		end -- 1385
		return -- 1387
	end -- 1387
	if self.room.key == "village" then -- 1387
		self:stepScavChase() -- 1390
	elseif self.room.key == "forest" then -- 1390
		self:stepDog(dt) -- 1392
		if self.player.x >= self.ox + 1450 then -- 1392
			self:requestRoom("tower", "到林缘北塔") -- 1395
			self:flashSet("林缘 · 北塔", 1.4) -- 1396
		end -- 1396
	end -- 1396
end -- 1381
function Play.prototype.stepScavChase(self) -- 1402
	local s = self.room.scavenger -- 1403
	if s == nil then -- 1403
		return -- 1405
	end -- 1405
	local p = self.player -- 1407
	if self.passed and p.x > self.ox + 440 then -- 1407
		if self.scavChase then -- 1407
			self.scavChase = false -- 1411
			self.scavState = "back" -- 1412
			self.scavT = 0 -- 1413
		end -- 1413
		return -- 1415
	end -- 1415
	local dx = p.x - self.scavX -- 1417
	local dist = math.abs(dx) -- 1418
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1419
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1420
	if not self.scavChase then -- 1420
		if visible then -- 1420
			self.scavSee = self.scavSee + 1 -- 1423
			if self.scavSee >= 24 then -- 1423
				self.scavChase = true -- 1425
				self.scavState = "chase" -- 1426
				self.scavTargetX = p.x -- 1427
				self:flashSet("他看见你了", 1.2) -- 1428
			end -- 1428
		else -- 1428
			self.scavSee = 0 -- 1431
		end -- 1431
		return -- 1433
	end -- 1433
	local dir = p.x > self.scavX and 1 or -1 -- 1436
	self.scavX = self.scavX + dir * 96 / 60 -- 1437
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1437
		self:caught() -- 1439
		return -- 1440
	end -- 1440
	if hidden then -- 1440
		self.scavSee = 0 -- 1444
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1445
		self.scavT = self.scavT - 1 -- 1446
		if self.scavT <= 0 then -- 1446
			self.scavChase = false -- 1448
			self.scavState = "patrol" -- 1449
			self:flashSet("他失去了目标", 1) -- 1450
		end -- 1450
	end -- 1450
end -- 1402
function Play.prototype.stepDog(self, dt) -- 1456
	local ____temp_37 -- 1457
	if self.room.story == nil then -- 1457
		____temp_37 = nil -- 1457
	else -- 1457
		____temp_37 = self.room.story.dog -- 1457
	end -- 1457
	local dog = ____temp_37 -- 1457
	if dog == nil then -- 1457
		return -- 1459
	end -- 1459
	local p = self.player -- 1461
	local dist = math.abs(p.x - self.dogX) -- 1462
	if self.dogState == "patrol" then -- 1462
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1464
		if self.dogX < dog.x0 then -- 1464
			self.dogX = dog.x0 -- 1466
			self.dogDir = 1 -- 1467
		elseif self.dogX > dog.x1 then -- 1467
			self.dogX = dog.x1 -- 1469
			self.dogDir = -1 -- 1470
		end -- 1470
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1472
		if not p.crouch and moving and dist < dog.range then -- 1472
			self.dogState = "ear" -- 1474
			self.dogT = 18 -- 1475
			self.dogTargetX = p.x -- 1476
			self:flashSet("狗转耳朵", 0.8) -- 1477
		end -- 1477
		return -- 1479
	end -- 1479
	if self.dogState == "ear" then -- 1479
		self.dogT = self.dogT - 1 -- 1482
		if self.dogT <= 0 then -- 1482
			self.dogState = "chase" -- 1484
			self.dogTargetX = p.x -- 1485
			self:flashSet("狗追来了", 1.4) -- 1486
		end -- 1486
		return -- 1488
	end -- 1488
	if self.dogState == "chase" then -- 1488
		local dir = p.x > self.dogX and 1 or -1 -- 1491
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1492
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1492
			self:caught() -- 1494
			self.dogState = "sniff" -- 1495
			self.dogT = 60 -- 1496
		elseif dist > dog.range * 1.5 or p.crouch then -- 1496
			self.dogState = "sniff" -- 1498
			self.dogT = 60 -- 1499
			self:flashSet("狗停下了", 0.9) -- 1500
		end -- 1500
		return -- 1502
	end -- 1502
	if self.dogState == "sniff" then -- 1502
		self.dogT = self.dogT - 1 -- 1505
		if self.dogT <= 0 then -- 1505
			self.dogState = "back" -- 1507
		end -- 1507
		return -- 1509
	end -- 1509
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1512
	self.dogX = self.dogX + dir * dog.speed * dt -- 1513
	if math.abs(self.dogX - dog.x0) < 2 then -- 1513
		self.dogX = dog.x0 -- 1515
		self.dogState = "patrol" -- 1516
	end -- 1516
end -- 1456
function Play.prototype.caught(self) -- 1520
	self.caughtT = 1 -- 1521
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1522
end -- 1520
function Play.prototype.recoverFromCaught(self) -- 1526
	local p = self.player -- 1527
	p.x = self.ox + 140 -- 1528
	p.y = 0 -- 1529
	p.vy = 0 -- 1530
	p.vx = 0 -- 1531
	p.onGround = true -- 1532
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1532
		self.scavX = self.room.scavenger.x0 -- 1534
		self.scavState = "patrol" -- 1535
		self.scavSee = 0 -- 1536
		self.scavChase = false -- 1537
		self.scavT = 0 -- 1538
	end -- 1538
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1538
		self.dogX = self.room.story.dog.x0 -- 1541
		self.dogState = "patrol" -- 1542
		self.dogT = 0 -- 1543
	end -- 1543
	self.cam.x = p.x -- 1545
	self.cam.y = p.y + CAM_LOOK_UP -- 1546
	self:flashSet("回到安全点", 1.2) -- 1547
end -- 1526
function Play.prototype.updateGate(self) -- 1551
	if self.room.key ~= "checkpoint" then -- 1551
		self.gateOpen = false -- 1553
		return -- 1554
	end -- 1554
	local function inZone(x) -- 1556
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1556
	end -- 1556
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1557
end -- 1551
function Play.prototype.addItem(self, kind) -- 1563
	local inv = self.run.inventory -- 1564
	if kind == "shield" then -- 1564
		if inv.shield >= TOOL_CAP then -- 1564
			return false -- 1567
		end -- 1567
		inv.shield = inv.shield + 1 -- 1569
		return true -- 1570
	end -- 1570
	if kind == "wedge" then -- 1570
		if inv.wedge >= CONSUMABLE_CAP then -- 1570
			return false -- 1574
		end -- 1574
		inv.wedge = inv.wedge + 1 -- 1576
		return true -- 1577
	end -- 1577
	if kind == "ammo" then -- 1577
		if inv.ammo >= CONSUMABLE_CAP then -- 1577
			return false -- 1581
		end -- 1581
		inv.ammo = inv.ammo + 1 -- 1583
		return true -- 1584
	end -- 1584
	if kind == "scrap" then -- 1584
		inv.scrap = inv.scrap + 1 -- 1588
		return true -- 1589
	end -- 1589
	if kind == "pass" then -- 1589
		inv.pass = inv.pass + 1 -- 1592
		return true -- 1593
	end -- 1593
	if kind == "quickbelt" then -- 1593
		inv.quickbelt = inv.quickbelt + 1 -- 1596
		return true -- 1597
	end -- 1597
	return false -- 1599
end -- 1563
function Play.prototype.findBox(self, id) -- 1602
	local i = 0 -- 1603
	do -- 1603
		i = 0 -- 1604
		while i < #self.boxes do -- 1604
			if self.boxes[i + 1].id == id then -- 1604
				return self.boxes[i + 1] -- 1606
			end -- 1606
			i = i + 1 -- 1604
		end -- 1604
	end -- 1604
	return nil -- 1609
end -- 1602
function Play.prototype.findWedgeTarget(self) -- 1613
	local best = nil -- 1614
	local bestD = 0 -- 1615
	local i = 0 -- 1616
	do -- 1616
		i = 0 -- 1617
		while i < #self.boxes do -- 1617
			do -- 1617
				local b = self.boxes[i + 1] -- 1618
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 1618
					goto __continue253 -- 1620
				end -- 1620
				if not self:nearBox(b, 26) then -- 1620
					goto __continue253 -- 1623
				end -- 1623
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 1625
				if best == nil or d < bestD then -- 1625
					best = b -- 1627
					bestD = d -- 1628
				end -- 1628
			end -- 1628
			::__continue253:: -- 1628
			i = i + 1 -- 1617
		end -- 1617
	end -- 1617
	return best -- 1631
end -- 1613
function Play.prototype.stepCraft(self, input) -- 1639
	local inv = self.run.inventory -- 1640
	local ____opt_38 = self.run.trial -- 1640
	local required = CRAFT_TICKS - 6 * (____opt_38 and ____opt_38.ranks.craft or 0) -- 1641
	if self.craftT > 0 then -- 1641
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 1641
			self.craftT = 0 -- 1645
			self:flashSet("制作中断", 0.8) -- 1646
			return true -- 1647
		end -- 1647
		self.craftT = self.craftT + 1 -- 1649
		if self.craftT >= required then -- 1649
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 1649
				inv.scrap = inv.scrap - 1 -- 1652
				inv.wedge = inv.wedge + 1 -- 1653
				self:flashSet("制得木楔", 1.2) -- 1654
				self:log("制木楔") -- 1655
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 1656
			end -- 1656
			self.craftT = 0 -- 1658
		end -- 1658
		return true -- 1660
	end -- 1660
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 1660
		self.craftT = 1 -- 1663
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 1664
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 1665
		return true -- 1666
	end -- 1666
	return false -- 1668
end -- 1639
function Play.prototype.nearBox(self, b, reach) -- 1671
	local p = self.player -- 1672
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1673
end -- 1671
function Play.prototype.findInteract(self) -- 1679
	local p = self.player -- 1680
	local best = nil -- 1681
	local bestD = 1000000000 -- 1682
	local i = 0 -- 1683
	do -- 1683
		i = 0 -- 1684
		while i < #self.boxes do -- 1684
			do -- 1684
				local b = self.boxes[i + 1] -- 1685
				if b.interact == nil or b.broken == true then -- 1685
					goto __continue266 -- 1687
				end -- 1687
				if not self:nearBox(b, b.interact.reach or 27) then -- 1687
					goto __continue266 -- 1690
				end -- 1690
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1692
				if d < bestD then -- 1692
					bestD = d -- 1694
					best = b -- 1695
				end -- 1695
			end -- 1695
			::__continue266:: -- 1695
			i = i + 1 -- 1684
		end -- 1684
	end -- 1684
	return best -- 1698
end -- 1679
function Play.prototype.stepCampaign(self, dt, input) -- 1702
	local wr = self.room -- 1703
	local p = self.player -- 1704
	if self.reloadT > 0 then -- 1704
		self.reloadT = self.reloadT - 1 -- 1706
	end -- 1706
	if self.bracedShield ~= nil then -- 1706
		self.bracedShield.x = p.x + p.facing * 26 -- 1710
		self.bracedShield.y = p.y -- 1711
		local shBox = __TS__ArrayFind( -- 1712
			self.boxes, -- 1712
			function(____, b) return b.id == "braced_shield" end -- 1712
		) -- 1712
		if shBox ~= nil then -- 1712
			shBox.x0 = self.bracedShield.x - 15 -- 1714
			shBox.x1 = self.bracedShield.x + 15 -- 1715
			shBox.y0 = self.bracedShield.y -- 1716
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1717
		end -- 1717
	end -- 1717
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1717
		self.run.route = "drygoods" -- 1723
		self.run.joined = false -- 1724
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1725
		self:log("转布行线") -- 1726
	end -- 1726
	local i = 0 -- 1729
	do -- 1729
		i = 0 -- 1730
		while i < #self.pickups do -- 1730
			do -- 1730
				local pk = self.pickups[i + 1] -- 1731
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1731
					goto __continue277 -- 1733
				end -- 1733
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1735
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1736
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1736
					if not self:addItem(pk.kind) then -- 1736
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 1740
						self:log("满包拒绝 " .. pk.kind) -- 1741
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 1742
						goto __continue277 -- 1743
					end -- 1743
					self.run.taken[pk.id] = true -- 1745
					pk.id = "" -- 1746
					self:flashSet("拾取 " .. pk.label, 1) -- 1747
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1748
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1749
				end -- 1749
			end -- 1749
			::__continue277:: -- 1749
			i = i + 1 -- 1730
		end -- 1730
	end -- 1730
	if not self:stepCraft(input) and input.interact.pressed then -- 1730
		self:campaignInteract() -- 1753
	end -- 1753
	self:stepCampaignCart(dt, input) -- 1755
	self:stepCampaignGoal() -- 1756
end -- 1702
function Play.prototype.campaignInteract(self) -- 1760
	local b = self:findInteract() -- 1761
	if b ~= nil then -- 1761
		self:useInteract(b) -- 1763
		return -- 1764
	end -- 1764
	local inv = self.run.inventory -- 1766
	if inv.wedge > 0 then -- 1766
		local w = self:findWedgeTarget() -- 1768
		if w ~= nil then -- 1768
			if w.breakable ~= nil then -- 1768
				local ____w_breakable_40, ____hp_41 = w.breakable, "hp" -- 1768
				____w_breakable_40[____hp_41] = ____w_breakable_40[____hp_41] + (w.breakable.wedgeHp or 1) -- 1771
			end -- 1771
			inv.wedge = inv.wedge - 1 -- 1773
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1774
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 1776
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 1777
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1778
			return -- 1779
		end -- 1779
	end -- 1779
	if inv.ammo > 0 and self.reloadT > 0 then -- 1779
		self.reloadT = 0 -- 1784
		inv.ammo = inv.ammo - 1 -- 1785
		self:flashSet("备用弹包 · 膛内补满", 1) -- 1786
		self:log("用备用弹包") -- 1787
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 1788
		return -- 1789
	end -- 1789
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1789
		local p = self.player -- 1793
		self.bracedShield = { -- 1794
			x = p.x + p.facing * 26, -- 1794
			y = p.y, -- 1794
			w = 30, -- 1794
			h = 64, -- 1794
			hp = 1 -- 1794
		} -- 1794
		local ____self_boxes_42 = self.boxes -- 1794
		____self_boxes_42[#____self_boxes_42 + 1] = { -- 1795
			x0 = self.bracedShield.x - 15, -- 1796
			x1 = self.bracedShield.x + 15, -- 1796
			y0 = p.y, -- 1797
			y1 = p.y + 64, -- 1797
			depth = {min = -46, max = 46}, -- 1797
			label = "架起的残盾", -- 1797
			id = "braced_shield", -- 1797
			soft = true -- 1798
		} -- 1798
		inv.shield = inv.shield - 1 -- 1801
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1802
		self:log("架残盾") -- 1803
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1804
		return -- 1805
	end -- 1805
	if inv.pass > 0 and self.run.joined == false then -- 1805
		inv.pass = inv.pass - 1 -- 1808
		self.run.joined = true -- 1809
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1810
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1811
		return -- 1812
	end -- 1812
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1814
end -- 1760
function Play.prototype.useInteract(self, b) -- 1817
	local kind = b.interact == nil and "" or b.interact.kind -- 1818
	local wr = self.room -- 1819
	if kind == "open_board" then -- 1819
		b.broken = true -- 1821
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1822
		for ____, cover in ipairs(self.boxes) do -- 1823
			if cover.id == "s2_board_cover" then -- 1823
				cover.broken = false -- 1825
				cover.hidden = false -- 1826
			end -- 1826
		end -- 1826
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1829
		self.run.joined = true -- 1830
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1831
		self:log("放下窗板") -- 1832
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1833
		return -- 1834
	end -- 1834
	if kind == "lower_curtain" then -- 1834
		for ____, curtain in ipairs(self.boxes) do -- 1837
			if curtain.id == "c2_curtain" then -- 1837
				curtain.broken = false -- 1839
				curtain.hidden = false -- 1840
			end -- 1840
		end -- 1840
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1843
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1844
		self:log("放下木帘") -- 1845
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1846
		return -- 1847
	end -- 1847
	if kind == "raise_latch" then -- 1847
		if wr.key == "c2-granary" and not self.cartDocked then -- 1847
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1851
			return -- 1852
		end -- 1852
		b.broken = true -- 1854
		self.objectiveDone = true -- 1855
		if wr.key == "c1-yard" then -- 1855
			self.run.c1Latch = true -- 1858
			self.run.joined = true -- 1859
		else -- 1859
			self.run.c2Latch = true -- 1861
			self.run.joined = true -- 1862
		end -- 1862
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1864
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1865
		self:log("抬闩") -- 1866
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1867
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1868
	end -- 1868
end -- 1817
function Play.prototype.stepCampaignCart(self, dt, input) -- 1873
	local wr = self.room -- 1874
	local c = wr.cart -- 1875
	if c.bodyW <= 0 then -- 1875
		return -- 1877
	end -- 1877
	local p = self.player -- 1879
	local handleX = self.cartAxle + c.handleOffset -- 1880
	if not self.gripping then -- 1880
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1880
			self.gripping = true -- 1884
			self:flashSet("握住车柄 · A/D 推", 1) -- 1885
		end -- 1885
		return -- 1887
	end -- 1887
	if input.interact.pressed then -- 1887
		self.gripping = false -- 1890
		self:flashSet("松手", 0.5) -- 1891
		return -- 1892
	end -- 1892
	if not self.cartDocked then -- 1892
		if input.moveX ~= 0 and not self:stuckCart() then -- 1892
			self.cartAxle = math.max( -- 1896
				c.startX, -- 1896
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1896
			) -- 1896
		end -- 1896
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1896
			self.cartExposed = true -- 1901
			local gun = nil -- 1902
			local gi = 0 -- 1903
			do -- 1903
				gi = 0 -- 1904
				while gi < #self.enemies do -- 1904
					local e = self.enemies[gi + 1] -- 1905
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1905
						gun = e -- 1907
						break -- 1908
					end -- 1908
					gi = gi + 1 -- 1904
				end -- 1904
			end -- 1904
			if gun ~= nil then -- 1904
				self:campaignEnemyFire(gun) -- 1912
			end -- 1912
		end -- 1912
		p.x = self.cartAxle + c.handleOffset -- 1915
		p.y = c.baseY + (c.depth or 0) -- 1916
		p.vx = 0 -- 1917
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1917
			self.cartAxle = c.endX -- 1919
			self.cartDocked = true -- 1920
			self.gripping = false -- 1921
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1922
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1923
			self:flashSet("车轮入窝", 1.2) -- 1924
			self:log("车轮入窝") -- 1925
		end -- 1925
	end -- 1925
end -- 1873
function Play.prototype.stuckCart(self) -- 1931
	local i = 0 -- 1932
	do -- 1932
		i = 0 -- 1933
		while i < #self.boxes do -- 1933
			do -- 1933
				local b = self.boxes[i + 1] -- 1934
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1934
					goto __continue318 -- 1936
				end -- 1936
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1938
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1938
					return true -- 1940
				end -- 1940
			end -- 1940
			::__continue318:: -- 1940
			i = i + 1 -- 1933
		end -- 1933
	end -- 1933
	return false -- 1943
end -- 1931
function Play.prototype.stepCampaignGoal(self) -- 1947
	local wr = self.room -- 1948
	local c = wr.campaign -- 1949
	if c == nil then -- 1949
		return -- 1951
	end -- 1951
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1951
		self.objectiveDone = true -- 1954
	end -- 1954
	if c.goal == "reach_exit" then -- 1954
		self.objectiveDone = true -- 1957
	end -- 1957
	if not self.objectiveDone then -- 1957
		return -- 1960
	end -- 1960
	local p = self.player -- 1962
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1963
	if p.x < c.exitX or not partnerOk then -- 1963
		return -- 1965
	end -- 1965
	if c.next ~= nil and c.next ~= "" then -- 1965
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1968
		self:flashSet("过关 · " .. c.next, 1.2) -- 1969
	elseif not self.run.finished then -- 1969
		self.run.finished = true -- 1971
		self:flashSet( -- 1972
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1972
			2 -- 1972
		) -- 1972
		self:log("C2 灰盒完成") -- 1973
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1974
	end -- 1974
end -- 1947
function Play.prototype.stepCampaignPartner(self, dt) -- 1979
	local a = self.partner -- 1980
	local wr = self.room -- 1981
	local cp = wr.companion -- 1982
	if not a.alive then -- 1982
		return -- 1984
	end -- 1984
	local p = self.player -- 1986
	local wait = false -- 1987
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1988
	local targetDepth = p.depth -- 1989
	if self.run.joined == false then -- 1989
		wait = true -- 1991
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1992
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1993
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1993
		wait = true -- 1995
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1996
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1997
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1997
		wait = true -- 1999
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2000
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2001
	end -- 2001
	if self.partnerStuck > 0.3 then -- 2001
		a.x = a.x + a.facing * 44 -- 2005
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2006
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2007
		self.partnerLaneHold = 1.1 -- 2008
		self.partnerStuck = 0 -- 2009
	end -- 2009
	if self.partnerLaneHold > 0 then -- 2009
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2012
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2013
	end -- 2013
	local dx = targetX - a.x -- 2015
	if not wait and math.abs(dx) > 74 then -- 2015
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2017
		local before = a.x -- 2018
		a.vx = dx > 0 and speed or -speed -- 2019
		a.facing = dx > 0 and 1 or -1 -- 2020
		self:slideX(a, a.vx * dt) -- 2021
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2021
			a.vy = CHILD_JUMP -- 2024
			a.onGround = false -- 2025
		end -- 2025
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2027
	else -- 2027
		a.vx = 0 -- 2029
		self.partnerStuck = 0 -- 2030
	end -- 2030
	local dz = targetDepth - a.depth -- 2032
	if math.abs(dz) > 6 then -- 2032
		local step = math.max( -- 2034
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2034
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2034
		) -- 2034
		a.depth = a.depth + step -- 2035
	end -- 2035
	a.depthSpeed = 0 -- 2037
	a.h = CHILD_H -- 2038
	a.crouch = false -- 2039
	self:fallY(a, dt) -- 2040
end -- 1979
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2044
	local p = self.player -- 2045
	local i = 0 -- 2046
	do -- 2046
		i = 0 -- 2047
		while i < #self.enemies do -- 2047
			do -- 2047
				local ____opt_43 = self.run.trial -- 2047
				if ____opt_43 and ____opt_43.lost then -- 2047
					return -- 2048
				end -- 2048
				local e = self.enemies[i + 1] -- 2049
				if not e.alive then -- 2049
					goto __continue342 -- 2051
				end -- 2051
				if e.hitT > 0 then -- 2051
					e.hitT = e.hitT - dt -- 2054
				end -- 2054
				if e.kind == "breaker" then -- 2054
					self:stepBreaker(e, dt) -- 2057
					goto __continue342 -- 2058
				end -- 2058
				if e.kind == "shield" then -- 2058
					self:stepShield(e, dt, input) -- 2061
					goto __continue342 -- 2062
				end -- 2062
				local dx = e.x - p.x -- 2065
				if not e.awake then -- 2065
					if math.abs(dx) > 520 then -- 2065
						goto __continue342 -- 2068
					end -- 2068
					e.awake = true -- 2070
					e.fireCd = 48 -- 2071
					goto __continue342 -- 2072
				end -- 2072
				if math.abs(dx) > ENEMY_RANGE then -- 2072
					goto __continue342 -- 2075
				end -- 2075
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2075
					goto __continue342 -- 2080
				end -- 2080
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2080
					goto __continue342 -- 2083
				end -- 2083
				if self:blockedShot(e, p) then -- 2083
					if e.warnT > 0 then -- 2083
						e.warnT = 0 -- 2089
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2090
					end -- 2090
					goto __continue342 -- 2092
				end -- 2092
				if e.warnT > 0 then -- 2092
					e.warnT = e.warnT - 1 -- 2095
					if e.warnT <= 0 then -- 2095
						self:campaignEnemyFire(e) -- 2097
					end -- 2097
				elseif e.fireCd > 0 then -- 2097
					e.fireCd = e.fireCd - 1 -- 2100
					if e.fireCd <= 0 then -- 2100
						e.warnT = WARN_TICKS -- 2102
					end -- 2102
				else -- 2102
					e.fireCd = 40 -- 2105
				end -- 2105
			end -- 2105
			::__continue342:: -- 2105
			i = i + 1 -- 2047
		end -- 2047
	end -- 2047
end -- 2044
function Play.prototype.blockedShot(self, e, p) -- 2111
	local eDepth = e.depth or 0 -- 2112
	local ex = e.x -- 2113
	local ey = e.y + e.h * 0.62 -- 2115
	local px = p.x -- 2116
	local py = p.y + p.h * 0.55 -- 2117
	local dx = px - ex -- 2118
	local dyScreen = py + p.depth - (ey + eDepth) -- 2119
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 2120
	if len < 0.01 then -- 2120
		return false -- 2122
	end -- 2122
	local ray = { -- 2126
		x = ex, -- 2127
		y = ey, -- 2127
		dx = dx / len, -- 2128
		dy = (py - ey) / len, -- 2128
		depth = eDepth, -- 2129
		dDepth = (p.depth - eDepth) / len -- 2129
	} -- 2129
	local best = -1 -- 2131
	local j = 0 -- 2132
	do -- 2132
		j = 0 -- 2133
		while j < #self.boxes do -- 2133
			do -- 2133
				local b = self.boxes[j + 1] -- 2134
				if b.broken == true or b.passable == true or b.hidden == true then -- 2134
					goto __continue363 -- 2136
				end -- 2136
				if b.id == "braced_shield" then -- 2136
					goto __continue363 -- 2141
				end -- 2141
				local t = hitBox(ray, b) -- 2143
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 2143
					best = t -- 2147
				end -- 2147
			end -- 2147
			::__continue363:: -- 2147
			j = j + 1 -- 2133
		end -- 2133
	end -- 2133
	return best >= 0 -- 2150
end -- 2111
function Play.prototype.campaignEnemyFire(self, e) -- 2153
	local p = self.player -- 2154
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2155
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2155
		local ____self_bracedShield_45, ____hp_46 = self.bracedShield, "hp" -- 2155
		____self_bracedShield_45[____hp_46] = ____self_bracedShield_45[____hp_46] - 1 -- 2157
		self.boxes = __TS__ArrayFilter( -- 2158
			self.boxes, -- 2158
			function(____, b) return b.id ~= "braced_shield" end -- 2158
		) -- 2158
		self.bracedShield = nil -- 2159
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2160
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2161
		return -- 2162
	end -- 2162
	if self:blockedShot(e, p) then -- 2162
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2165
		return -- 2166
	end -- 2166
	local cover = self:blockedByCover(e, p) -- 2168
	if cover ~= nil and self.coverHug then -- 2168
		self.coveredFlash = 0.5 -- 2170
		self:flashSet("掩体挡下", 0.6) -- 2171
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2172
		return -- 2177
	end -- 2177
	if self.invulnT > 0 then -- 2177
		return -- 2180
	end -- 2180
	local ____opt_47 = self.run.trial -- 2180
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_47 and ____opt_47.ranks.guard or 0) -- 2182
	self.craftT = 0 -- 2183
	self.hp = self.hp - 1 -- 2184
	self:emit("actorHit", { -- 2185
		target = "player", -- 2185
		amount = 1, -- 2185
		hp = self.hp, -- 2185
		maxHp = self.maxHp, -- 2185
		enemyX = e.x -- 2185
	}) -- 2185
	self:flashSet( -- 2186
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2186
		0.8 -- 2186
	) -- 2186
	if self.hp <= 0 then -- 2186
		self:campaignFailed() -- 2188
	end -- 2188
end -- 2153
function Play.prototype.stepShield(self, e, dt, input) -- 2193
	local p = self.player -- 2194
	local dx = p.x - e.x -- 2195
	local adx = math.abs(dx) -- 2196
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2199
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2200
	if adx > 150 then -- 2200
		local before = e.x -- 2202
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2203
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2203
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2206
		end -- 2206
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2206
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2211
		local rollDodges = p.rollT > 0 and fromFront -- 2212
		if not rollDodges and self.invulnT <= 0 then -- 2212
			local ____opt_49 = self.run.trial -- 2212
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_49 and ____opt_49.ranks.guard or 0) -- 2214
			self.craftT = 0 -- 2215
			self.hp = self.hp - 1 -- 2216
			self:emit("actorHit", { -- 2217
				target = "player", -- 2217
				amount = 1, -- 2217
				hp = self.hp, -- 2217
				maxHp = self.maxHp, -- 2217
				enemyX = e.x -- 2217
			}) -- 2217
			self:flashSet( -- 2218
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2218
				0.8 -- 2218
			) -- 2218
			if self.hp <= 0 then -- 2218
				self:campaignFailed() -- 2220
				return -- 2221
			end -- 2221
		end -- 2221
		e.swingT = 70 -- 2224
	end -- 2224
	if (e.swingT or 0) > 0 then -- 2224
		e.swingT = (e.swingT or 0) - 1 -- 2227
	end -- 2227
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2227
		local dd = p.depth - (e.depth or 0) -- 2230
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2231
	end -- 2231
end -- 2193
function Play.prototype.stepBreaker(self, e, dt) -- 2236
	local p = self.player -- 2237
	if e.awake ~= true then -- 2237
		if math.abs(p.x - e.x) < 560 then -- 2237
			e.awake = true -- 2240
		else -- 2240
			return -- 2242
		end -- 2242
	end -- 2242
	local target = nil -- 2245
	local bestD = 1000000000 -- 2246
	local i = 0 -- 2247
	do -- 2247
		i = 0 -- 2248
		while i < #self.boxes do -- 2248
			do -- 2248
				local b = self.boxes[i + 1] -- 2249
				if b.breakable == nil or b.broken == true then -- 2249
					goto __continue387 -- 2251
				end -- 2251
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2253
				if d < bestD then -- 2253
					bestD = d -- 2255
					target = b -- 2256
				end -- 2256
			end -- 2256
			::__continue387:: -- 2256
			i = i + 1 -- 2248
		end -- 2248
	end -- 2248
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2259
	local dx = tx - e.x -- 2260
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2261
	if math.abs(dx) > reach then -- 2261
		local before = e.x -- 2263
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2264
		if math.abs(e.x - before) < 0.3 then -- 2264
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2266
		end -- 2266
	elseif (e.swingT or 0) <= 0 then -- 2266
		e.swingT = 64 -- 2269
		if target ~= nil then -- 2269
			self:damageProp(target, 2) -- 2271
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2271
			local ____opt_51 = self.run.trial -- 2271
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_51 and ____opt_51.ranks.guard or 0) -- 2273
			self.craftT = 0 -- 2274
			self.hp = self.hp - 1 -- 2275
			self:emit("actorHit", { -- 2276
				target = "player", -- 2276
				amount = 1, -- 2276
				hp = self.hp, -- 2276
				maxHp = self.maxHp, -- 2276
				enemyX = e.x -- 2276
			}) -- 2276
			self:flashSet("破障手近身", 0.8) -- 2277
			if self.hp <= 0 then -- 2277
				self:campaignFailed() -- 2279
				return -- 2280
			end -- 2280
		end -- 2280
	end -- 2280
	if (e.swingT or 0) > 0 then -- 2280
		e.swingT = (e.swingT or 0) - 1 -- 2285
	end -- 2285
end -- 2236
function Play.prototype.campaignFailed(self) -- 2289
	if self.run.trial ~= nil then -- 2289
		self.run.trial.lost = true -- 2291
		self.wantRoom = "" -- 2292
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2293
		return -- 2294
	end -- 2294
	local p = self.player -- 2296
	self.hp = self.maxHp -- 2297
	self.invulnT = INVULN_RESPAWN_TICKS -- 2298
	self.reloadT = 0 -- 2299
	self.gripping = false -- 2300
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2301
	self:log("被击倒") -- 2302
	p.x = self.room.minX + 90 -- 2303
	p.y = 0 -- 2304
	p.depth = 0 -- 2305
	p.vx = 0 -- 2306
	p.vy = 0 -- 2307
	p.onGround = true -- 2308
	p.rollT = 0 -- 2309
	self.partner.x = p.x - 50 -- 2310
	self.partner.y = 0 -- 2311
	self.partner.depth = 0 -- 2312
	self.cam.x = p.x -- 2313
	local i = 0 -- 2314
	do -- 2314
		i = 0 -- 2315
		while i < #self.enemies do -- 2315
			do -- 2315
				local e = self.enemies[i + 1] -- 2316
				if not e.alive then -- 2316
					goto __continue400 -- 2318
				end -- 2318
				e.x = e.homeX == nil and e.x or e.homeX -- 2320
				e.warnT = 0 -- 2321
				e.fireCd = 40 -- 2322
				e.swingT = 0 -- 2323
				e.awake = false -- 2324
			end -- 2324
			::__continue400:: -- 2324
			i = i + 1 -- 2315
		end -- 2315
	end -- 2315
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2326
end -- 2289
function Play.prototype.stepEnemies(self, dt, input) -- 2329
	local i = 0 -- 2330
	do -- 2330
		i = 0 -- 2331
		while i < #self.enemies do -- 2331
			local e = self.enemies[i + 1] -- 2332
			if e.hitT > 0 then -- 2332
				e.hitT = e.hitT - dt -- 2334
			end -- 2334
			i = i + 1 -- 2331
		end -- 2331
	end -- 2331
	if self.coveredFlash > 0 then -- 2331
		self.coveredFlash = self.coveredFlash - dt -- 2338
	end -- 2338
	if self.isCampaign then -- 2338
		self:stepCampaignEnemies(dt, input) -- 2341
		return -- 2342
	end -- 2342
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2342
		return -- 2346
	end -- 2346
	do -- 2346
		i = 0 -- 2348
		while i < #self.enemies do -- 2348
			do -- 2348
				local e = self.enemies[i + 1] -- 2349
				if not e.alive then -- 2349
					goto __continue410 -- 2351
				end -- 2351
				if e.warnT > 0 then -- 2351
					e.warnT = e.warnT - 1 -- 2354
					if e.warnT <= 0 then -- 2354
						self:enemyFire(e, input) -- 2356
					end -- 2356
					goto __continue410 -- 2358
				end -- 2358
				if e.fireCd > 0 then -- 2358
					e.fireCd = e.fireCd - 1 -- 2361
					if e.fireCd <= 0 then -- 2361
						e.warnT = WARN_TICKS -- 2363
					end -- 2363
				else -- 2363
					e.warnT = WARN_TICKS -- 2367
				end -- 2367
			end -- 2367
			::__continue410:: -- 2367
			i = i + 1 -- 2348
		end -- 2348
	end -- 2348
end -- 2329
function Play.prototype.enemyFire(self, e, input) -- 2373
	local p = self.player -- 2374
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2374
		self:flashSet("枪声响在远处", 0.4) -- 2376
		e.fireCd = FIRE_COOLDOWN -- 2377
		return -- 2378
	end -- 2378
	local cover = self:blockedByCover(e, p) -- 2381
	local hugging = cover ~= nil -- 2382
	self.coverBlocking = hugging -- 2383
	local covered = hugging and input.cover.held -- 2384
	if covered then -- 2384
		self.coveredFlash = 0.5 -- 2386
		self:flashSet("掩体挡下", 0.5) -- 2387
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2388
		e.fireCd = FIRE_COOLDOWN -- 2393
		return -- 2394
	end -- 2394
	self.hp = self.hp - 1 -- 2396
	self:emit("actorHit", { -- 2397
		target = "player", -- 2397
		amount = 1, -- 2397
		hp = self.hp, -- 2397
		maxHp = self.maxHp, -- 2397
		enemyX = e.x -- 2397
	}) -- 2397
	self:flashSet( -- 2398
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2398
		0.7 -- 2398
	) -- 2398
	e.fireCd = FIRE_COOLDOWN -- 2399
	if self.hp <= 0 then -- 2399
		self:gateFailed() -- 2401
	end -- 2401
end -- 2373
function Play.prototype.blockedByCover(self, enemy, p) -- 2406
	local b = self:coverAt(p) -- 2407
	if b == nil then -- 2407
		return nil -- 2409
	end -- 2409
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2411
end -- 2406
function Play.prototype.gateFailed(self) -- 2415
	local ____temp_53 -- 2416
	if self.room.story == nil then -- 2416
		____temp_53 = nil -- 2416
	else -- 2416
		____temp_53 = self.room.story.gate -- 2416
	end -- 2416
	local g = ____temp_53 -- 2416
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2417
	self.hp = self.maxHp -- 2418
	self.gateTick = 0 -- 2419
	self.gateSpawned = 0 -- 2420
	self.enemies = {} -- 2421
	self.gateFailCount = self.gateFailCount + 1 -- 2422
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2424
	self.player.y = 0 -- 2425
	self.player.vy = 0 -- 2426
	self.player.depth = 0 -- 2427
	self.player.depthSpeed = 0 -- 2428
	self.player.onGround = true -- 2429
	self.player.crouch = false -- 2430
	self.player.h = SOLDIER_H -- 2431
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2432
	self.partner.y = 0 -- 2433
	self.partner.vy = 0 -- 2434
	self.partner.depth = 0 -- 2435
	self.partner.depthSpeed = 0 -- 2436
	self.partner.onGround = true -- 2437
	self.cam.x = self.player.x -- 2438
	self.phase = "gate-idle" -- 2439
	self.phaseTick = 0 -- 2440
	self.coverHug = false -- 2441
	self.coverBlocking = false -- 2442
	self.coverEntity = "" -- 2443
	self.gateNeedConfirm = true -- 2444
	self.gateRestartArmed = false -- 2445
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2446
end -- 2415
function Play.prototype.stepInteract(self, dt, input) -- 2449
	local p = self.player -- 2450
	local calmUsed = self.calmConsumed -- 2451
	self.calmConsumed = false -- 2452
	local calming = self.escort.state == "calming" -- 2454
	self.focusCart = false -- 2455
	if self.room.key == "outside" then -- 2455
		local c = self.room.cart -- 2457
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2458
		local dy = p.y - c.baseY -- 2459
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2460
	end -- 2460
	if not calmUsed and not calming then -- 2460
		self:stepCart(dt, input) -- 2464
	end -- 2464
	if calmUsed then -- 2464
		self:flashSet("安抚 · 敲两下", 0.8) -- 2469
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2469
		if self.knockT > 0 then -- 2469
			self.knocks = self.knocks + 1 -- 2473
		else -- 2473
			self.knocks = 1 -- 2475
		end -- 2475
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2477
		self.knockT = 1.2 -- 2478
		if self.knocks >= 2 then -- 2478
			self:flashSet("敲两下", 0.8) -- 2480
			self.knocks = 0 -- 2481
		else -- 2481
			self:flashSet("敲一下", 0.5) -- 2483
		end -- 2483
	elseif self.knockT > 0 then -- 2483
		self.knockT = self.knockT - dt -- 2486
		if self.knockT <= 0 then -- 2486
			self.knocks = 0 -- 2488
		end -- 2488
	end -- 2488
	local i = 0 -- 2493
	do -- 2493
		i = 0 -- 2494
		while i < #self.room.marks do -- 2494
			do -- 2494
				local m = self.room.marks[i + 1] -- 2495
				if m.kind ~= 0 then -- 2495
					goto __continue436 -- 2497
				end -- 2497
				local subjects = {self.partner, self.player} -- 2499
				local k = 0 -- 2500
				do -- 2500
					k = 0 -- 2501
					while k < #subjects do -- 2501
						do -- 2501
							local s = subjects[k + 1] -- 2502
							if not s.alive then -- 2502
								goto __continue439 -- 2504
							end -- 2504
							local dx = s.x - m.x -- 2506
							local dy = s.y - m.y -- 2507
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2507
								self.checkpoint = m.x -- 2509
								self.checkpointCartAxle = self.cartAxle -- 2510
								if self.cartDocked then -- 2510
									self:flashSet("检查点 · 车已落窝", 1) -- 2512
								else -- 2512
									self:flashSet("检查点 · 车还没到位", 1) -- 2514
								end -- 2514
							end -- 2514
						end -- 2514
						::__continue439:: -- 2514
						k = k + 1 -- 2501
					end -- 2501
				end -- 2501
			end -- 2501
			::__continue436:: -- 2501
			i = i + 1 -- 2494
		end -- 2494
	end -- 2494
	self:checkCarryGate() -- 2520
end -- 2449
function Play.prototype.stepVillage(self, dt, input) -- 2524
	if self.room.key ~= "village" then -- 2524
		return -- 2526
	end -- 2526
	local p = self.player -- 2528
	local bottle = self.room.bottle -- 2529
	local scav = self.room.scavenger -- 2530
	if not self.hasBottle and bottle ~= nil then -- 2530
		local dx = p.x - bottle.x -- 2534
		local dy = p.y + p.h * 0.5 - bottle.y -- 2535
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2535
			self.hasBottle = true -- 2537
			self:flashSet("拾起瓶子", 0.8) -- 2538
		end -- 2538
	end -- 2538
	if self.hasBottle then -- 2538
		if input.aim.held then -- 2538
			self.aimHold = self.aimHold + dt -- 2545
			if self.aimHold > 1.2 then -- 2545
				self.aimHold = 1.2 -- 2547
			end -- 2547
			local cached = self:bottleEnd() -- 2550
			self.bottleAimX = cached.x -- 2551
			self.bottleAimY = cached.y -- 2552
		elseif input.aim.released then -- 2552
			if self.aimHold < 0.12 then -- 2552
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2556
				self.aimHold = 0 -- 2557
			else -- 2557
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2559
				self:throwBottle(____end.x, ____end.y) -- 2560
				self.aimHold = 0 -- 2561
			end -- 2561
		end -- 2561
	else -- 2561
		self.aimHold = 0 -- 2565
		self.bottleAimX = -1 -- 2566
	end -- 2566
	local fly = self.bottleFly -- 2571
	if fly ~= nil then -- 2571
		fly.t = fly.t + dt -- 2573
		fly.x = fly.x0 + fly.vx * fly.t -- 2574
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2575
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2576
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2576
			self:landBottle(fly) -- 2578
		end -- 2578
	end -- 2578
	if self.bottleLandT > 0 then -- 2578
		self.bottleLandT = self.bottleLandT - dt -- 2582
	end -- 2582
	if scav ~= nil then -- 2582
		self:stepScav(dt, scav) -- 2586
	end -- 2586
	local line = self.room.passLine -- 2589
	if line ~= nil and not self.passed and p.x >= line then -- 2589
		self.passed = true -- 2591
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2592
	end -- 2592
	if self.passed and p.x >= self.ox + 640 then -- 2592
		self:requestRoom("forest", "过第一院出院") -- 2596
		self:flashSet("出院 · 北塔森林", 1.4) -- 2597
	end -- 2597
end -- 2524
function Play.prototype.bottleEnd(self) -- 2602
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2603
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2606
	return {x = aim.x, y = g} -- 2607
end -- 2602
function Play.prototype.throwBottle(self, tx, ty) -- 2611
	local p = self.player -- 2612
	local dir = tx >= p.x and 1 or -1 -- 2614
	p.facing = dir -- 2615
	local x0 = p.x + dir * 10 -- 2616
	local y0 = p.y + p.h * 0.7 -- 2617
	self.bottleTargetX = tx -- 2618
	self.bottleTargetY = ty -- 2619
	self.bottleSurfaceY = ty -- 2620
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2621
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2622
	self.bottleFly = { -- 2623
		x = x0, -- 2623
		y = y0, -- 2623
		x0 = x0, -- 2623
		y0 = y0, -- 2623
		vx = vx, -- 2623
		vy = vy, -- 2623
		t = 0 -- 2623
	} -- 2623
	self.hasBottle = false -- 2624
	self:flashSet("投出", 0.4) -- 2625
	self:emit( -- 2626
		"bottleThrown", -- 2626
		{ -- 2626
			fromX = x0, -- 2627
			fromY = y0, -- 2628
			targetX = tx, -- 2629
			targetY = ty, -- 2630
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2631
		} -- 2631
	) -- 2631
end -- 2611
function Play.prototype.landBottle(self, fly) -- 2636
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2637
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2638
	local s = self.room.scavenger -- 2639
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2640
	self.bottleFly = nil -- 2641
	self.bottleTargetX = -1 -- 2642
	self.bottleTargetY = 0 -- 2643
	self.bottleSurfaceY = -1 -- 2644
	self.bottleLandX = x -- 2645
	self.bottleLandY = y -- 2646
	self.bottleLandT = 0.9 -- 2647
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2648
	self:hearBottle(x) -- 2649
end -- 2636
function Play.prototype.hearBottle(self, x) -- 2653
	local s = self.room.scavenger -- 2654
	if s == nil then -- 2654
		return -- 2656
	end -- 2656
	if math.abs(x - self.scavX) > s.range then -- 2656
		self:flashSet("落地 · 他没听见", 0.6) -- 2659
		return -- 2660
	end -- 2660
	self.scavState = "turn" -- 2662
	self.scavT = s.hearTicks -- 2663
	self.scavTargetX = x -- 2664
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2665
end -- 2653
function Play.prototype.stepScav(self, dt, s) -- 2669
	if self.scavState == "chase" then -- 2669
		return -- 2672
	end -- 2672
	if self.scavState == "turn" then -- 2672
		self.scavT = self.scavT - 1 -- 2675
		if self.scavT <= 0 then -- 2675
			self.scavState = "walk" -- 2677
		end -- 2677
		return -- 2679
	end -- 2679
	if self.scavState == "walk" then -- 2679
		local d = self.scavTargetX - self.scavX -- 2682
		if math.abs(d) < 4 then -- 2682
			self.scavState = "stall" -- 2684
			self.scavT = s.stallTicks -- 2685
			return -- 2686
		end -- 2686
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2688
		return -- 2689
	end -- 2689
	if self.scavState == "stall" then -- 2689
		self.scavT = self.scavT - 1 -- 2692
		if self.scavT <= 0 then -- 2692
			self.scavState = "back" -- 2694
		end -- 2694
		return -- 2696
	end -- 2696
	if self.scavState == "back" then -- 2696
		local home = math.max( -- 2699
			s.x0, -- 2699
			math.min(s.x1, self.scavX) -- 2699
		) -- 2699
		if math.abs(home - self.scavX) < 2 then -- 2699
			self.scavState = "patrol" -- 2701
			return -- 2702
		end -- 2702
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2704
		return -- 2705
	end -- 2705
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2707
	if self.scavX >= s.x1 then -- 2707
		self.scavX = s.x1 -- 2709
		self.scavDir = -1 -- 2710
	elseif self.scavX <= s.x0 then -- 2710
		self.scavX = s.x0 -- 2712
		self.scavDir = 1 -- 2713
	end -- 2713
end -- 2669
function Play.prototype.stepCart(self, dt, input) -- 2721
	local p = self.player -- 2722
	local c = self.room.cart -- 2723
	if self.gripping then -- 2723
		if not input.interact.held then -- 2723
			self.gripping = false -- 2727
			self:flashSet("松开车把", 0.4) -- 2728
			return -- 2729
		end -- 2729
	else -- 2729
		if not input.interact.pressed then -- 2729
			return -- 2733
		end -- 2733
		if not self:cartHandleInReach(p) then -- 2733
			return -- 2736
		end -- 2736
		local track = c.depth or 0 -- 2738
		if self:limitDepth(p, track) ~= track then -- 2738
			return -- 2740
		end -- 2740
		p.depth = track -- 2742
		p.depthSpeed = 0 -- 2743
		self.gripping = true -- 2744
		self:flashSet("握住车把", 0.4) -- 2745
		return -- 2746
	end -- 2746
	if self.cartDocked then -- 2746
		return -- 2750
	end -- 2750
	local dir = input.moveX -- 2752
	if dir == 0 then -- 2752
		return -- 2754
	end -- 2754
	local lo = math.min(c.startX, c.endX) -- 2756
	local hi = math.max(c.startX, c.endX) -- 2757
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2758
	if next < lo then -- 2758
		next = lo -- 2760
	end -- 2760
	if next > hi then -- 2760
		next = hi -- 2763
	end -- 2763
	local delta = next - self.cartAxle -- 2765
	if delta == 0 then -- 2765
		return -- 2767
	end -- 2767
	self.cartAxle = next -- 2769
	p.x = p.x + delta -- 2770
	p.facing = dir > 0 and 1 or -1 -- 2771
	self:slideX(p, 0) -- 2772
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2772
		self.gripping = false -- 2774
		self:flashSet("跟不上了，脱手", 0.6) -- 2775
		return -- 2776
	end -- 2776
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2776
		self.cartDocked = true -- 2779
		self.gripping = false -- 2780
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2781
		self:flashSet("车轮落窝", 1.2) -- 2782
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2782
		self:flashSet("车轮回到起点", 0.5) -- 2784
	end -- 2784
end -- 2721
function Play.prototype.requestRoom(self, key, reason) -- 2792
	if self.wantRoom ~= "" then -- 2792
		return -- 2796
	end -- 2796
	self.wantRoom = key -- 2798
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2799
end -- 2792
function Play.prototype.checkCarryGate(self) -- 2806
	if self.room.key == "checkpoint" then -- 2806
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2806
			self.carryCartAxle = self.cartAxle -- 2809
			self.carryCartDocked = self.cartDocked -- 2810
			self:requestRoom("gate", "检查站出口") -- 2811
			self:flashSet("出检查站 · 城门", 1.2) -- 2812
		end -- 2812
		return -- 2814
	end -- 2814
	if self.room.key == "outside" then -- 2814
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2814
			self.carryCartAxle = self.cartAxle -- 2820
			self.carryCartDocked = self.cartDocked -- 2821
			self:requestRoom("village", "墙根走完") -- 2822
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2823
		end -- 2823
	end -- 2823
end -- 2806
function Play.prototype.aimAt(self, wx, wy) -- 2830
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2831
	self.aimX = s.x -- 2832
	self.aimY = s.y -- 2833
end -- 2830
function Play.prototype.shoot(self, a) -- 2836
	if self.isCampaign and self.reloadT > 0 then -- 2836
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2838
		return -- 2839
	end -- 2839
	local ox = a.x + a.facing * 8 -- 2841
	local muzzleY = a.y + a.h * 0.72 -- 2842
	local oy = muzzleY + a.depth -- 2843
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2845
	local dx = aim.x - ox -- 2848
	local dy = aim.y - oy -- 2849
	local len = math.sqrt(dx * dx + dy * dy) -- 2850
	if len < 0.001 then -- 2850
		dx = a.facing -- 2852
		dy = 0 -- 2853
	else -- 2853
		dx = dx / len -- 2855
		dy = dy / len -- 2856
	end -- 2856
	if dx ~= 0 then -- 2856
		a.facing = dx > 0 and 1 or -1 -- 2859
	end -- 2859
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2862
	local hitEnemy = self:raycastEnemies(ray) -- 2863
	local tEnemy = hitEnemy.t -- 2864
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2865
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2866
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2867
	local tWall = solid.t -- 2868
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2869
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2870
	self.trace = { -- 2872
		x0 = ox, -- 2872
		y0 = oy, -- 2872
		x1 = ox + dx * t, -- 2872
		y1 = oy + dy * t, -- 2872
		hit = hit -- 2872
	} -- 2872
	self.traceT = 0.12 -- 2873
	self:applyFireDanger(ox) -- 2874
	local killed = false -- 2875
	if hit then -- 2875
		local i = hitEnemy.index -- 2877
		local e = self.enemies[i + 1] -- 2878
		local impactY = oy + dy * tEnemy -- 2879
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2880
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2881
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2881
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2883
			e.hitT = 0.3 -- 2884
			self:flashSet( -- 2885
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2885
				0.8 -- 2885
			) -- 2885
			self:emit("shotResolved", { -- 2886
				hit = true, -- 2887
				enemyIndex = i, -- 2887
				enemyX = e.x, -- 2887
				aimX = aim.x, -- 2887
				aimY = aim.y, -- 2887
				impactX = ox + dx * t, -- 2888
				impactY = oy + dy * t, -- 2888
				shield = true -- 2888
			}) -- 2888
			self.reloadT = self:reloadTicks() -- 2890
			return -- 2891
		end -- 2891
		e.alive = false -- 2893
		e.hitT = 0.4 -- 2894
		killed = true -- 2895
		self:flashSet("命中", 0.6) -- 2896
		self:dropFor(e) -- 2897
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2897
		self:damageProp(solid.box, 1) -- 2899
	else -- 2899
		self:flashSet("打空", 0.35) -- 2901
	end -- 2901
	if self.isCampaign then -- 2901
		self.reloadT = self:reloadTicks() -- 2904
	end -- 2904
	self:emit("shotResolved", { -- 2906
		hit = hit, -- 2907
		enemyIndex = hit and hitEnemy.index or -1, -- 2908
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2909
		aimX = aim.x, -- 2910
		aimY = aim.y, -- 2911
		impactX = ox + dx * t, -- 2912
		impactY = oy + dy * t -- 2913
	}) -- 2913
end -- 2836
function Play.prototype.applyFireDanger(self, shotX) -- 2918
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2918
		return -- 2920
	end -- 2920
	local dangerX = shotX -- 2922
	local best = -1 -- 2923
	local bestD = 1000000000 -- 2924
	local i = 0 -- 2925
	do -- 2925
		i = 0 -- 2926
		while i < #self.enemies do -- 2926
			do -- 2926
				local e = self.enemies[i + 1] -- 2927
				if not e.alive then -- 2927
					goto __continue515 -- 2929
				end -- 2929
				local d = math.abs(e.x - self.partner.x) -- 2931
				if d < bestD then -- 2931
					bestD = d -- 2933
					best = i -- 2934
				end -- 2934
			end -- 2934
			::__continue515:: -- 2934
			i = i + 1 -- 2926
		end -- 2926
	end -- 2926
	if best >= 0 then -- 2926
		dangerX = self.enemies[best + 1].x -- 2938
	end -- 2938
	local exposed = self:childExposed(dangerX) -- 2940
	local before = self.escort.fear -- 2941
	local dangerId = self.nextDangerId -- 2942
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2943
	self.nextDangerId = self.nextDangerId + 1 -- 2944
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2945
	if after > before then -- 2945
		self:flashSet( -- 2947
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2947
			1 -- 2947
		) -- 2947
	elseif not exposed then -- 2947
		self:flashSet("枪声没够到她", 0.5) -- 2949
	end -- 2949
end -- 2918
function Play.prototype.childExposed(self, dangerX) -- 2954
	local c = self.partner -- 2955
	if not c.alive then -- 2955
		return false -- 2957
	end -- 2957
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2957
		self.boxes, -- 2960
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2960
	) then -- 2960
		return false -- 2961
	end -- 2961
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2961
		return false -- 2964
	end -- 2964
	local toDanger = dangerX - c.x -- 2966
	local toPlayer = self.player.x - c.x -- 2967
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2967
		return false -- 2970
	end -- 2970
	return true -- 2972
end -- 2954
function Play.prototype.raycastEnemies(self, ray) -- 2976
	local best = -1 -- 2977
	local bestI = -1 -- 2978
	do -- 2978
		local i = 0 -- 2979
		while i < #self.enemies do -- 2979
			do -- 2979
				local e = self.enemies[i + 1] -- 2980
				if not e.alive then -- 2980
					goto __continue529 -- 2982
				end -- 2982
				local y = e.y + (e.depth or 0) -- 2984
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2985
				if t >= 0 and (best < 0 or t < best) then -- 2985
					best = t -- 2987
					bestI = i -- 2988
				end -- 2988
			end -- 2988
			::__continue529:: -- 2988
			i = i + 1 -- 2979
		end -- 2979
	end -- 2979
	return {t = best, index = bestI} -- 2991
end -- 2976
function Play.prototype.raycastWorld(self, ray) -- 2994
	return self:raycastSolid(ray).t -- 2995
end -- 2994
function Play.prototype.raycastSolid(self, ray) -- 2999
	local best = -1 -- 3000
	local bestBox = nil -- 3001
	for ____, box in ipairs(self.boxes) do -- 3002
		do -- 3002
			if box.broken == true or box.hidden == true then -- 3002
				goto __continue534 -- 3004
			end -- 3004
			local t = hitBox(ray, box) -- 3009
			if t > 2 and (best < 0 or t < best) then -- 3009
				best = t -- 3012
				bestBox = box -- 3013
			end -- 3013
		end -- 3013
		::__continue534:: -- 3013
	end -- 3013
	if ray.dy < 0 then -- 3013
		local t = -ray.y / ray.dy -- 3017
		if t >= 0 and (best < 0 or t < best) then -- 3017
			best = t -- 3019
			bestBox = nil -- 3020
		end -- 3020
	end -- 3020
	return {t = best, box = bestBox} -- 3023
end -- 2999
function Play.prototype.dropFor(self, e) -- 3027
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 3027
		return -- 3029
	end -- 3029
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 3029
		return -- 3032
	end -- 3032
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 3034
	local ____self_pickups_54 = self.pickups -- 3034
	____self_pickups_54[#____self_pickups_54 + 1] = { -- 3035
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 3036
		kind = e.drop, -- 3036
		x = e.x, -- 3036
		y = e.y, -- 3036
		depth = e.depth, -- 3037
		label = label .. " ×1" -- 3037
	} -- 3037
	self:log("掉落 " .. label) -- 3039
end -- 3027
function Play.prototype.damageProp(self, b, amount) -- 3043
	if b.breakable == nil or b.broken == true then -- 3043
		return -- 3045
	end -- 3045
	local ____b_breakable_55, ____hp_56 = b.breakable, "hp" -- 3045
	____b_breakable_55[____hp_56] = ____b_breakable_55[____hp_56] - amount -- 3047
	if b.breakable.hp > 0 then -- 3047
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3049
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3050
		return -- 3051
	end -- 3051
	b.broken = true -- 3053
	for ____, other in ipairs(self.boxes) do -- 3054
		if other.id ~= nil and other.id == b.id then -- 3054
			other.broken = true -- 3056
		end -- 3056
	end -- 3056
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3059
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3060
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3061
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3062
end -- 3043
function Play.prototype.slideDepth(self, a, distance) -- 3066
	a.depth = self:limitDepth(a, a.depth + distance) -- 3067
end -- 3066
function Play.prototype.limitDepth(self, a, target) -- 3070
	local road = self.room.depth -- 3071
	if road == nil or target == a.depth then -- 3071
		return a.depth -- 3073
	end -- 3073
	local next = math.max( -- 3075
		road.min, -- 3075
		math.min(road.max, target) -- 3075
	) -- 3075
	local half = a.w / 2 -- 3076
	for ____, b in ipairs(self.boxes) do -- 3077
		do -- 3077
			local footprint = b.depth -- 3078
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3078
				goto __continue552 -- 3083
			end -- 3083
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3085
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3086
			if a.depth <= front and next > front then -- 3086
				next = front -- 3088
			elseif a.depth >= back and next < back then -- 3088
				next = back -- 3090
			end -- 3090
		end -- 3090
		::__continue552:: -- 3090
	end -- 3090
	return next -- 3093
end -- 3070
function Play.prototype.slideX(self, a, dx) -- 3097
	local nx = a.x + dx -- 3098
	local half = a.w / 2 -- 3099
	local room = self.room -- 3100
	nx = math.max( -- 3101
		room.minX + half, -- 3101
		math.min(room.maxX - half, nx) -- 3101
	) -- 3101
	local i = 0 -- 3102
	do -- 3102
		i = 0 -- 3103
		while i < #self.boxes do -- 3103
			do -- 3103
				local b = self.boxes[i + 1] -- 3104
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3104
					goto __continue559 -- 3106
				end -- 3106
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3106
					goto __continue559 -- 3109
				end -- 3109
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3109
					goto __continue559 -- 3112
				end -- 3112
				if nx + half > b.x0 and nx - half < b.x1 then -- 3112
					if a.x <= b.x0 then -- 3112
						nx = b.x0 - half -- 3116
					elseif a.x >= b.x1 then -- 3116
						nx = b.x1 + half -- 3118
					else -- 3118
						nx = a.x -- 3120
					end -- 3120
				end -- 3120
			end -- 3120
			::__continue559:: -- 3120
			i = i + 1 -- 3103
		end -- 3103
	end -- 3103
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 3103
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 3128
		local bx0 = self.cartAxle - CART_HALF -- 3129
		local bx1 = self.cartAxle + CART_HALF -- 3130
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 3130
			if a.x <= bx0 then -- 3130
				nx = bx0 - half -- 3133
			elseif a.x >= bx1 then -- 3133
				nx = bx1 + half -- 3135
			else -- 3135
				nx = a.x -- 3137
			end -- 3137
		end -- 3137
	end -- 3137
	local arch = room.arch -- 3145
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 3145
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 3147
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 3147
			if a.x <= arch.x0 then -- 3147
				nx = arch.x0 - half -- 3150
			elseif a.x >= arch.x1 then -- 3150
				nx = arch.x1 + half -- 3152
			end -- 3152
		end -- 3152
	end -- 3152
	a.x = nx -- 3156
end -- 3097
function Play.prototype.fallY(self, a, dt) -- 3160
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3161
	if a.vy < -900 then -- 3161
		a.vy = -900 -- 3163
	end -- 3163
	local ny = a.y + a.vy * dt -- 3165
	local half = a.w / 2 -- 3166
	if a.vy <= 0 then -- 3166
		local reach = a.onGround and STEP_UP or 0 -- 3169
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3170
		if ny <= ground then -- 3170
			ny = ground -- 3172
			a.vy = 0 -- 3173
			a.onGround = true -- 3174
		else -- 3174
			a.onGround = false -- 3176
		end -- 3176
	else -- 3176
		a.onGround = false -- 3179
		local i = 0 -- 3180
		do -- 3180
			i = 0 -- 3181
			while i < #self.boxes do -- 3181
				do -- 3181
					local b = self.boxes[i + 1] -- 3182
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3182
						goto __continue583 -- 3184
					end -- 3184
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3184
						goto __continue583 -- 3187
					end -- 3187
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3187
						goto __continue583 -- 3190
					end -- 3190
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3190
						ny = b.y0 - a.h -- 3193
						a.vy = 0 -- 3194
					end -- 3194
				end -- 3194
				::__continue583:: -- 3194
				i = i + 1 -- 3181
			end -- 3181
		end -- 3181
	end -- 3181
	a.y = ny -- 3198
end -- 3160
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3202
	if depth == nil then -- 3202
		depth = 0 -- 3202
	end -- 3202
	local g = -9999 -- 3203
	local i = 0 -- 3204
	do -- 3204
		i = 0 -- 3205
		while i < #self.floors do -- 3205
			local f = self.floors[i + 1] -- 3206
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3206
				g = f.y1 -- 3208
			end -- 3208
			i = i + 1 -- 3205
		end -- 3205
	end -- 3205
	do -- 3205
		i = 0 -- 3211
		while i < #self.boxes do -- 3211
			do -- 3211
				local b = self.boxes[i + 1] -- 3212
				if b.broken == true or b.hidden == true or b.soft == true then -- 3212
					goto __continue593 -- 3214
				end -- 3214
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3214
					g = b.y1 -- 3218
				end -- 3218
			end -- 3218
			::__continue593:: -- 3218
			i = i + 1 -- 3211
		end -- 3211
	end -- 3211
	return g -- 3221
end -- 3202
function Play.prototype.updateCamera(self, dt) -- 3224
	local p = self.player -- 3225
	local tx = p.x + p.facing * 30 -- 3226
	local ty = p.y + CAM_LOOK_UP -- 3227
	local k = math.min(1, CAM_FOLLOW * dt) -- 3228
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3229
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3230
end -- 3224
function Play.prototype.clampCamera(self, w, h) -- 3234
	local room = self.room -- 3235
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3236
	local spanX = room.maxX - room.minX -- 3237
	if spanX <= halfW * 2 then -- 3237
		self.cam.x = (room.minX + room.maxX) / 2 -- 3239
	else -- 3239
		self.cam.x = math.max( -- 3241
			room.minX + halfW, -- 3241
			math.min(room.maxX - halfW, self.cam.x) -- 3241
		) -- 3241
	end -- 3241
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3244
	local spanY = room.height -- 3245
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3246
	if spanY <= halfH * 2 then -- 3246
		self.cam.y = camY -- 3248
	else -- 3248
		self.cam.y = math.max( -- 3250
			camY, -- 3250
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3250
		) -- 3250
	end -- 3250
end -- 3234
function Play.prototype.flashSet(self, text, t) -- 3254
	self.flash = text -- 3255
	self.flashT = t -- 3256
end -- 3254
function Play.prototype.statusText(self) -- 3260
	local p = self.player -- 3261
	local parts = {} -- 3262
	local who = self.childMode and "小满" or "周戍" -- 3263
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3264
	if self.room.key == "prologue" then -- 3264
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3267
		if self.phase == "prologue-wait" then -- 3267
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3269
		elseif self.phase == "prologue-give" then -- 3269
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3271
		else -- 3271
			parts[#parts + 1] = "跟随" -- 3273
		end -- 3273
		if self.paused then -- 3273
			parts[#parts + 1] = "已暂停" -- 3276
		end -- 3276
		return table.concat(parts, " · ") -- 3278
	end -- 3278
	if self.room.key == "street" then -- 3278
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3281
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3282
		if self.paused then -- 3282
			parts[#parts + 1] = "已暂停" -- 3284
		end -- 3284
		return table.concat(parts, " · ") -- 3286
	end -- 3286
	if self.room.key == "gate" then -- 3286
		local ____temp_57 -- 3289
		if self.room.story == nil then -- 3289
			____temp_57 = nil -- 3289
		else -- 3289
			____temp_57 = self.room.story.gate -- 3289
		end -- 3289
		local g = ____temp_57 -- 3289
		if g ~= nil then -- 3289
			parts[#parts + 1] = self:gateLabel() -- 3291
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3292
				0, -- 3293
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3293
			))) .. " 秒" -- 3293
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3294
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3295
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3296
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3297
			if self.gateFailCount > 0 then -- 3297
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3299
			end -- 3299
			if self.flash ~= "" then -- 3299
				parts[#parts + 1] = self.flash -- 3302
			end -- 3302
		end -- 3302
		if self.paused then -- 3302
			parts[#parts + 1] = "已暂停" -- 3306
		end -- 3306
		return table.concat(parts, " · ") -- 3308
	end -- 3308
	if self.room.key == "forest" then -- 3308
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3311
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3312
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3313
		if self.caughtT > 0 then -- 3313
			parts[#parts + 1] = "复位中" -- 3315
		end -- 3315
		if self.paused then -- 3315
			parts[#parts + 1] = "已暂停" -- 3318
		end -- 3318
		return table.concat(parts, " · ") -- 3320
	end -- 3320
	if self.room.key == "tower" then -- 3320
		if self.phase == "tower-wait" then -- 3320
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3324
		elseif self.phase == "tower-knock" then -- 3324
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3326
		elseif self.phase == "tower-given" then -- 3326
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3328
		else -- 3328
			parts[#parts + 1] = "片尾" -- 3330
		end -- 3330
		if self.paused then -- 3330
			parts[#parts + 1] = "已暂停" -- 3333
		end -- 3333
		return table.concat(parts, " · ") -- 3335
	end -- 3335
	if self.room.key == "village" then -- 3335
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3338
		if self.hasBottle then -- 3338
			parts[#parts + 1] = "有瓶" -- 3340
		elseif self.bottleFly ~= nil then -- 3340
			parts[#parts + 1] = "瓶在飞" -- 3342
		else -- 3342
			parts[#parts + 1] = "空手" -- 3344
		end -- 3344
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3346
		if self.scavChase then -- 3346
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3348
		end -- 3348
		if self.passed then -- 3348
			parts[#parts + 1] = "已过通行线" -- 3351
		end -- 3351
		if self.paused then -- 3351
			parts[#parts + 1] = "已暂停" -- 3354
		end -- 3354
		return table.concat(parts, " · ") -- 3356
	end -- 3356
	local isChild = self.childMode -- 3359
	if isChild then -- 3359
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3361
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3362
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3363
	else -- 3363
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3365
		if p.rollT > 0 then -- 3365
			parts[#parts + 1] = "翻滚中" -- 3367
		end -- 3367
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3369
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3370
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3371
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3372
	end -- 3372
	if self.checkpoint >= 0 then -- 3372
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3375
	end -- 3375
	if self.paused then -- 3375
		parts[#parts + 1] = "已暂停" -- 3378
	end -- 3378
	return table.concat(parts, " · ") -- 3380
end -- 3260
function Play.prototype.aliveEnemies(self) -- 3384
	local n = 0 -- 3385
	local i = 0 -- 3386
	do -- 3386
		i = 0 -- 3387
		while i < #self.enemies do -- 3387
			if self.enemies[i + 1].alive then -- 3387
				n = n + 1 -- 3389
			end -- 3389
			i = i + 1 -- 3387
		end -- 3387
	end -- 3387
	return n -- 3392
end -- 3384
function Play.prototype.threatened(self) -- 3397
	do -- 3397
		local i = 0 -- 3398
		while i < #self.enemies do -- 3398
			local e = self.enemies[i + 1] -- 3399
			if e.alive and e.warnT > 0 then -- 3399
				return true -- 3401
			end -- 3401
			i = i + 1 -- 3398
		end -- 3398
	end -- 3398
	return false -- 3404
end -- 3397
function Play.prototype.gateSecondsLeft(self) -- 3407
	local ____temp_58 -- 3408
	if self.room.story == nil then -- 3408
		____temp_58 = nil -- 3408
	else -- 3408
		____temp_58 = self.room.story.gate -- 3408
	end -- 3408
	local g = ____temp_58 -- 3408
	if g == nil then -- 3408
		return 0 -- 3410
	end -- 3410
	return math.max( -- 3412
		0, -- 3412
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3412
	) -- 3412
end -- 3407
function Play.prototype.gateLabel(self) -- 3415
	if self.phase == "gate-idle" then -- 3415
		return "待就位" -- 3417
	end -- 3417
	if self.phase == "gate-hold" then -- 3417
		return "守点中" -- 3420
	end -- 3420
	if self.phase == "gate-send" then -- 3420
		return "送别" -- 3423
	end -- 3423
	if self.phase == "gate-count" then -- 3423
		return "数数 " .. tostring(self.countTick) -- 3426
	end -- 3426
	return "她走" -- 3428
end -- 3415
function Play.prototype.dogLabel(self) -- 3432
	if self.dogState == "ear" then -- 3432
		return "转耳" -- 3434
	end -- 3434
	if self.dogState == "chase" then -- 3434
		return "追" -- 3437
	end -- 3437
	if self.dogState == "sniff" then -- 3437
		return "停" -- 3440
	end -- 3440
	if self.dogState == "back" then -- 3440
		return "回线" -- 3443
	end -- 3443
	return "巡逻" -- 3445
end -- 3432
function Play.prototype.doorXOf(self) -- 3448
	local ____temp_59 -- 3449
	if self.room.story == nil then -- 3449
		____temp_59 = nil -- 3449
	else -- 3449
		____temp_59 = self.room.story.tower -- 3449
	end -- 3449
	local t = ____temp_59 -- 3449
	return t == nil and 0 or t.doorX -- 3450
end -- 3448
function Play.prototype.scavLabel(self) -- 3454
	if self.scavState == "chase" then -- 3454
		return "追" -- 3456
	end -- 3456
	if self.scavState == "turn" then -- 3456
		return "转头" -- 3459
	end -- 3459
	if self.scavState == "walk" then -- 3459
		return "赶来" -- 3462
	end -- 3462
	if self.scavState == "stall" then -- 3462
		return "停住" -- 3465
	end -- 3465
	if self.scavState == "back" then -- 3465
		return "回位" -- 3468
	end -- 3468
	return "巡逻" -- 3470
end -- 3454
function Play.prototype.hintText(self) -- 3474
	if self.paused then -- 3474
		return "Esc 继续 · R 重置" -- 3476
	end -- 3476
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3476
		if self:threatened() then -- 3476
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3482
		end -- 3482
		if self.coverHug then -- 3482
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3485
		end -- 3485
		if self.coverNear then -- 3485
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3488
		end -- 3488
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3490
	end -- 3490
	if self.flash ~= "" then -- 3490
		return self.flash -- 3493
	end -- 3493
	if self.room.key == "prologue" then -- 3493
		if self.phase == "prologue-wait" then -- 3493
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3497
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3498
		end -- 3498
		if self.phase == "prologue-give" then -- 3498
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3501
		end -- 3501
		return "她跟着你了 · 两人一起走到门口 680" -- 3503
	end -- 3503
	if self.room.key == "street" then -- 3503
		if self:aliveEnemies() > 0 then -- 3503
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3507
		end -- 3507
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3509
	end -- 3509
	if self.room.key == "gate" then -- 3509
		local ____temp_60 -- 3512
		if self.room.story == nil then -- 3512
			____temp_60 = nil -- 3512
		else -- 3512
			____temp_60 = self.room.story.gate -- 3512
		end -- 3512
		local g = ____temp_60 -- 3512
		if g ~= nil then -- 3512
			if self.phase == "gate-idle" then -- 3512
				if self.gateNeedConfirm then -- 3512
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3516
				end -- 3516
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3518
			end -- 3518
			if self.phase == "gate-hold" then -- 3518
				if self.coveredFlash > 0 then -- 3518
					return "掩体挡下了这一枪 · 别露头" -- 3522
				end -- 3522
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3524
			end -- 3524
			if self.phase == "gate-send" then -- 3524
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3527
			end -- 3527
			if self.phase == "gate-count" then -- 3527
				if self.countTick >= ____exports.GATE_COUNT_END then -- 3527
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3531
				end -- 3531
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3533
			end -- 3533
			return "她自己走 · 跟着出城门 1120" -- 3535
		end -- 3535
	end -- 3535
	if self.room.key == "forest" then -- 3535
		if self.dogState == "chase" then -- 3535
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3540
		end -- 3540
		if self.dogState == "ear" then -- 3540
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3543
		end -- 3543
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3545
	end -- 3545
	if self.room.key == "tower" then -- 3545
		if self.phase == "tower-wait" then -- 3545
			return "走到门前 445 点一次 E 敲两下" -- 3549
		end -- 3549
		if self.phase == "tower-knock" then -- 3549
			return "敲两下 · 等门开" -- 3552
		end -- 3552
		if self.phase == "tower-given" then -- 3552
			return "递交针套和纸条 · 看登记簿最后一行" -- 3555
		end -- 3555
		return "片尾 · 点 E 再玩一次，回到序章" -- 3557
	end -- 3557
	if self.room.key == "village" then -- 3557
		if self.bottleFly ~= nil then -- 3557
			return "等瓶子落地 · 触地才发声" -- 3561
		end -- 3561
		if self.hasBottle then -- 3561
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3564
		end -- 3564
		if self.passed then -- 3564
			return "已过第一院 · R 重置可再来一遍" -- 3567
		end -- 3567
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3569
	end -- 3569
	if self.room.key == "outside" then -- 3569
		if self.focusCart then -- 3569
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3573
		end -- 3573
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3575
	end -- 3575
	if self.escort.state == "frozen" then -- 3575
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3575
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3579
		end -- 3579
		return "小满吓住了 · 走过去，靠近再点 E" -- 3581
	end -- 3581
	if self.escort.state == "calming" then -- 3581
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3584
	end -- 3584
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3586
end -- 3474
function Play.prototype.draw(self, draw, w, h) -- 3591
	self.viewW = w -- 3592
	self.viewH = h -- 3593
	self.view = ____exports.computeViewport(w, h) -- 3594
	self:clampCamera(w, h) -- 3595
	draw:clear() -- 3596
	draw:drawRect( -- 3598
		Rect(0, 0, w, h), -- 3598
		BG_VOID -- 3598
	) -- 3598
	local box = self:canvasRect(w, h) -- 3599
	draw:drawRect(box, BG_FAR) -- 3600
	draw:drawRect( -- 3601
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3601
		BG_MID -- 3601
	) -- 3601
	self:drawFloors(draw, w, h) -- 3603
	self:drawSolids(draw, w, h) -- 3604
	self:drawZones(draw, w, h) -- 3605
	self:drawArch(draw, w, h) -- 3606
	self:drawCart(draw, w, h) -- 3607
	self:drawCampaignProps(draw, w, h) -- 3608
	self:drawActors(draw, w, h) -- 3609
	self:drawTrace(draw, w, h) -- 3610
	self:drawAim(draw, w, h) -- 3611
end -- 3591
function Play.prototype.canvasRect(self, w, h) -- 3615
	local v = self.view -- 3616
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3617
end -- 3615
function Play.prototype.px(self, n) -- 3621
	return n * self.view.zoom -- 3622
end -- 3621
function Play.prototype.sx(self, wx, w) -- 3626
	local v = self.view -- 3627
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3628
	return v.ox + lx * v.zoom -- 3629
end -- 3626
function Play.prototype.sy(self, wy, h) -- 3633
	local v = self.view -- 3634
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3635
	return v.oy + ly * v.zoom -- 3636
end -- 3633
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3639
	local px0 = self:sx(x0, w) -- 3640
	local px1 = self:sx(x1, w) -- 3641
	local py0 = self:sy(y0, h) -- 3642
	local py1 = self:sy(y1, h) -- 3643
	if px1 <= px0 or py1 <= py0 then -- 3643
		return -- 3645
	end -- 3645
	draw:drawRect( -- 3647
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3647
		color -- 3647
	) -- 3647
end -- 3639
function Play.prototype.drawFloors(self, draw, w, h) -- 3650
	local i = 0 -- 3651
	do -- 3651
		i = 0 -- 3652
		while i < #self.room.floors do -- 3652
			local f = self.room.floors[i + 1] -- 3653
			local ____temp_61 -- 3654
			if f.y == 0 then -- 3654
				____temp_61 = self.room.depth -- 3654
			else -- 3654
				____temp_61 = nil -- 3654
			end -- 3654
			local road = ____temp_61 -- 3654
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3655
			local x0 = self:sx(f.x0, w) -- 3656
			local x1 = self:sx(f.x1, w) -- 3657
			local deck = self:px(5) -- 3658
			if road ~= nil then -- 3658
				local back = self:sy(f.y + road.max, h) -- 3660
				draw:drawRect( -- 3661
					Rect(x0, y, x1 - x0, back - y), -- 3661
					FLOOR_DECK, -- 3661
					self:px(1), -- 3661
					SOLID_EDGE -- 3661
				) -- 3661
			end -- 3661
			draw:drawRect( -- 3663
				Rect(x0, y - deck, x1 - x0, deck), -- 3663
				FLOOR_DECK -- 3663
			) -- 3663
			draw:drawSegment( -- 3664
				Vec2(x0, y), -- 3664
				Vec2(x1, y), -- 3664
				self:px(1), -- 3664
				GROUND -- 3664
			) -- 3664
			i = i + 1 -- 3652
		end -- 3652
	end -- 3652
end -- 3650
function Play.prototype.drawSolids(self, draw, w, h) -- 3668
	local i = 0 -- 3669
	do -- 3669
		i = 0 -- 3670
		while i < #self.boxes do -- 3670
			do -- 3670
				local b = self.boxes[i + 1] -- 3671
				if b.id == "braced_shield" or b.hidden == true then -- 3671
					goto __continue714 -- 3673
				end -- 3673
				if b.broken == true then -- 3673
					if b.breakable ~= nil then -- 3673
						local gy = self:sy(b.y0, h) -- 3678
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3679
						local k = 0 -- 3680
						do -- 3680
							k = 0 -- 3681
							while k < 3 do -- 3681
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3682
								draw:drawSegment( -- 3683
									Vec2( -- 3683
										gx - self:px(4), -- 3683
										gy + self:px(k % 2) -- 3683
									), -- 3683
									Vec2( -- 3683
										gx + self:px(5), -- 3683
										gy + self:px(k % 2) -- 3683
									), -- 3683
									self:px(1), -- 3683
									rgb -- 3683
								) -- 3683
								k = k + 1 -- 3681
							end -- 3681
						end -- 3681
					end -- 3681
					goto __continue714 -- 3686
				end -- 3686
				local ____opt_64 = b.depth -- 3686
				local front = ____opt_64 and ____opt_64.min or 0 -- 3688
				local ____opt_66 = b.depth -- 3688
				local back = ____opt_66 and ____opt_66.max or 0 -- 3689
				local fill = SOLID_FILL -- 3690
				local line = SOLID_EDGE -- 3691
				if b.soft == true then -- 3691
					fill = SOFT -- 3693
					line = SOFT_LINE -- 3694
				elseif b.breakable ~= nil then -- 3694
					line = DANGER_LINE -- 3696
					fill = Color(0.3, 0.24, 0.16, 1) -- 3697
				elseif b.interact ~= nil then -- 3697
					line = PASS_LINE -- 3699
				end -- 3699
				self:drawBox( -- 3701
					draw, -- 3701
					w, -- 3701
					h, -- 3701
					b.x0, -- 3701
					b.x1, -- 3701
					b.y0 + front, -- 3701
					b.y1 + back, -- 3701
					fill -- 3701
				) -- 3701
				draw:drawSegment( -- 3702
					Vec2( -- 3702
						self:sx(b.x0, w), -- 3702
						self:sy(b.y1 + front, h) -- 3702
					), -- 3702
					Vec2( -- 3703
						self:sx(b.x1, w), -- 3703
						self:sy(b.y1 + front, h) -- 3703
					), -- 3703
					self:px(1), -- 3703
					line -- 3703
				) -- 3703
				if b.breakable ~= nil then -- 3703
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3706
					local cyp = self:sy(b.y1 + front, h) -- 3707
					draw:drawSegment( -- 3708
						Vec2( -- 3708
							cxp - self:px(4), -- 3708
							cyp + self:px(1) -- 3708
						), -- 3708
						Vec2( -- 3708
							cxp + self:px(3), -- 3708
							cyp + self:px(5) -- 3708
						), -- 3708
						self:px(1), -- 3708
						line -- 3708
					) -- 3708
				end -- 3708
			end -- 3708
			::__continue714:: -- 3708
			i = i + 1 -- 3670
		end -- 3670
	end -- 3670
end -- 3668
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3714
	local i = 0 -- 3715
	do -- 3715
		i = 0 -- 3716
		while i < #self.pickups do -- 3716
			do -- 3716
				local pk = self.pickups[i + 1] -- 3717
				if pk.id == "" then -- 3717
					goto __continue726 -- 3719
				end -- 3719
				local gy = pk.y + (pk.depth or 0) -- 3721
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3722
				draw:drawRect( -- 3723
					Rect( -- 3723
						self:sx(pk.x - 5, w), -- 3723
						self:sy(gy + 12 + bob, h), -- 3723
						self:px(10), -- 3723
						self:px(10) -- 3723
					), -- 3723
					Color(0.84, 0.7, 0.3, 1) -- 3724
				) -- 3724
				draw:drawSegment( -- 3725
					Vec2( -- 3725
						self:sx(pk.x - 5, w), -- 3725
						self:sy(gy + 12 + bob, h) -- 3725
					), -- 3725
					Vec2( -- 3726
						self:sx(pk.x + 5, w), -- 3726
						self:sy(gy + 12 + bob, h) -- 3726
					), -- 3726
					self:px(1), -- 3726
					Color(0.95, 0.86, 0.52, 1) -- 3726
				) -- 3726
			end -- 3726
			::__continue726:: -- 3726
			i = i + 1 -- 3716
		end -- 3716
	end -- 3716
	if self.bracedShield ~= nil then -- 3716
		local sh = self.bracedShield -- 3729
		draw:drawRect( -- 3730
			Rect( -- 3730
				self:sx(sh.x - sh.w / 2, w), -- 3730
				self:sy(sh.y, h), -- 3730
				self:px(sh.w), -- 3730
				self:px(sh.h) -- 3730
			), -- 3730
			Color(0.42, 0.4, 0.34, 1) -- 3731
		) -- 3731
		draw:drawSegment( -- 3732
			Vec2( -- 3732
				self:sx(sh.x - sh.w / 2, w), -- 3732
				self:sy(sh.y + sh.h, h) -- 3732
			), -- 3732
			Vec2( -- 3733
				self:sx(sh.x + sh.w / 2, w), -- 3733
				self:sy(sh.y + sh.h, h) -- 3733
			), -- 3733
			self:px(1), -- 3733
			Color(0.74, 0.72, 0.62, 1) -- 3733
		) -- 3733
	end -- 3733
end -- 3714
function Play.prototype.drawZones(self, draw, w, h) -- 3737
	local i = 0 -- 3738
	do -- 3738
		i = 0 -- 3739
		while i < #self.room.zones do -- 3739
			local z = self.room.zones[i + 1] -- 3740
			local fill = DANGER -- 3741
			local line = DANGER_LINE -- 3742
			if z.tint == 2 then -- 3742
				fill = SOFT -- 3744
				line = SOFT_LINE -- 3745
			elseif z.tint == 3 then -- 3745
				fill = BRICK -- 3747
				line = BRICK_LINE -- 3748
			elseif z.tint == 4 then -- 3748
				fill = PASS -- 3750
				line = PASS_LINE -- 3751
			end -- 3751
			self:drawBox( -- 3753
				draw, -- 3753
				w, -- 3753
				h, -- 3753
				z.x0, -- 3753
				z.x1, -- 3753
				z.y, -- 3753
				z.y + z.h, -- 3753
				fill -- 3753
			) -- 3753
			draw:drawSegment( -- 3754
				Vec2( -- 3754
					self:sx(z.x0, w), -- 3754
					self:sy(z.y, h) -- 3754
				), -- 3754
				Vec2( -- 3754
					self:sx(z.x0, w), -- 3754
					self:sy(z.y + z.h, h) -- 3754
				), -- 3754
				self:px(1), -- 3754
				line -- 3754
			) -- 3754
			draw:drawSegment( -- 3755
				Vec2( -- 3755
					self:sx(z.x1, w), -- 3755
					self:sy(z.y, h) -- 3755
				), -- 3755
				Vec2( -- 3755
					self:sx(z.x1, w), -- 3755
					self:sy(z.y + z.h, h) -- 3755
				), -- 3755
				self:px(1), -- 3755
				line -- 3755
			) -- 3755
			i = i + 1 -- 3739
		end -- 3739
	end -- 3739
end -- 3737
function Play.prototype.drawArch(self, draw, w, h) -- 3759
	local a = self.room.arch -- 3760
	if a.h <= 0 then -- 3760
		return -- 3762
	end -- 3762
	self:drawBox( -- 3764
		draw, -- 3764
		w, -- 3764
		h, -- 3764
		a.x0, -- 3764
		a.x1, -- 3764
		a.y, -- 3764
		a.y + a.h, -- 3764
		HOLE_FILL -- 3764
	) -- 3764
	draw:drawSegment( -- 3765
		Vec2( -- 3765
			self:sx(a.x0, w), -- 3765
			self:sy(a.y + a.h, h) -- 3765
		), -- 3765
		Vec2( -- 3765
			self:sx(a.x1, w), -- 3765
			self:sy(a.y + a.h, h) -- 3765
		), -- 3765
		self:px(1), -- 3765
		SOLID_EDGE -- 3765
	) -- 3765
	draw:drawSegment( -- 3766
		Vec2( -- 3766
			self:sx(a.x0, w), -- 3766
			self:sy(a.y, h) -- 3766
		), -- 3766
		Vec2( -- 3766
			self:sx(a.x0, w), -- 3766
			self:sy(a.y + a.h, h) -- 3766
		), -- 3766
		self:px(1), -- 3766
		SOLID_EDGE -- 3766
	) -- 3766
	draw:drawSegment( -- 3767
		Vec2( -- 3767
			self:sx(a.x1, w), -- 3767
			self:sy(a.y, h) -- 3767
		), -- 3767
		Vec2( -- 3767
			self:sx(a.x1, w), -- 3767
			self:sy(a.y + a.h, h) -- 3767
		), -- 3767
		self:px(1), -- 3767
		SOLID_EDGE -- 3767
	) -- 3767
end -- 3759
function Play.prototype.drawCart(self, draw, w, h) -- 3770
	local c = self.room.cart -- 3771
	if c.bodyW <= 0 then -- 3771
		return -- 3773
	end -- 3773
	drawCartShape( -- 3775
		draw, -- 3775
		self, -- 3775
		w, -- 3775
		h, -- 3775
		c, -- 3775
		self.cartAxle -- 3775
	) -- 3775
	draw:drawRect( -- 3776
		Rect( -- 3776
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3776
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3776
			self:px(2), -- 3776
			self:px(40) -- 3776
		), -- 3776
		STAND -- 3776
	) -- 3776
end -- 3770
function Play.prototype.drawActors(self, draw, w, h) -- 3779
	local p = self.player -- 3780
	local isChild = self.childMode -- 3781
	local footY = p.y + p.depth -- 3782
	if p.covered then -- 3782
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3785
		draw:drawSegment( -- 3786
			Vec2( -- 3786
				self:sx(edge, w), -- 3786
				self:sy(footY + 8, h) -- 3786
			), -- 3786
			Vec2( -- 3786
				self:sx(edge, w), -- 3786
				self:sy(footY + p.h * 0.62, h) -- 3786
			), -- 3786
			self:px(2), -- 3786
			STAND -- 3786
		) -- 3786
		draw:drawSegment( -- 3788
			Vec2( -- 3788
				self:sx(p.x - 8, w), -- 3788
				self:sy(footY + p.h + 3, h) -- 3788
			), -- 3788
			Vec2( -- 3788
				self:sx(p.x + 8, w), -- 3788
				self:sy(footY + p.h + 3, h) -- 3788
			), -- 3788
			self:px(2), -- 3788
			STAND -- 3788
		) -- 3788
	elseif self.coverNear and not isChild then -- 3788
		draw:drawRect( -- 3791
			Rect( -- 3791
				self:sx(p.x - 3, w), -- 3791
				self:sy(footY + 1, h), -- 3791
				self:px(3), -- 3791
				self:px(3) -- 3791
			), -- 3791
			STAND -- 3791
		) -- 3791
	end -- 3791
	drawFigure( -- 3793
		draw, -- 3793
		self, -- 3793
		w, -- 3793
		h, -- 3793
		p, -- 3793
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3793
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3793
	) -- 3793
	local q = self.partner -- 3794
	if q.alive then -- 3794
		local childPartner = q.w == CHILD_W -- 3796
		drawFigure( -- 3797
			draw, -- 3797
			self, -- 3797
			w, -- 3797
			h, -- 3797
			q, -- 3797
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3797
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3797
		) -- 3797
	end -- 3797
	local i = 0 -- 3799
	do -- 3799
		i = 0 -- 3800
		while i < #self.enemies do -- 3800
			local e = self.enemies[i + 1] -- 3801
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3802
			local enemyY = e.y + (e.depth or 0) -- 3803
			self:drawBox( -- 3804
				draw, -- 3804
				w, -- 3804
				h, -- 3804
				e.x - e.w / 2, -- 3804
				e.x + e.w / 2, -- 3804
				enemyY, -- 3804
				enemyY + e.h, -- 3804
				col -- 3804
			) -- 3804
			if e.alive then -- 3804
				local ef = p.x >= e.x and 1 or -1 -- 3806
				if e.kind == "shield" then -- 3806
					local sh = (e.shieldHp or 0) > 0 -- 3808
					draw:drawRect( -- 3809
						Rect( -- 3809
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3809
							self:sy(enemyY, h), -- 3809
							self:px(6), -- 3809
							self:px(64) -- 3809
						), -- 3809
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3810
					) -- 3810
				elseif e.kind == "breaker" then -- 3810
					draw:drawSegment( -- 3812
						Vec2( -- 3812
							self:sx(e.x + ef * 12, w), -- 3812
							self:sy(enemyY + 8, h) -- 3812
						), -- 3812
						Vec2( -- 3813
							self:sx(e.x + ef * 22, w), -- 3813
							self:sy(enemyY + 46, h) -- 3813
						), -- 3813
						self:px(3), -- 3813
						Color(0.5, 0.36, 0.22, 1) -- 3813
					) -- 3813
				end -- 3813
			end -- 3813
			if e.alive and e.warnT > 0 then -- 3813
				local gunX = self:sx(e.x, w) -- 3818
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3819
				local aimX = self:sx(p.x, w) -- 3820
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3821
				local seg = 8 -- 3822
				local s = 0 -- 3823
				do -- 3823
					s = 0 -- 3824
					while s < seg do -- 3824
						local t0 = s / seg -- 3825
						local t1 = (s + 1) / seg -- 3826
						draw:drawSegment( -- 3827
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3828
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3829
							self:px(1), -- 3830
							DANGER -- 3830
						) -- 3830
						s = s + 2 -- 3824
					end -- 3824
				end -- 3824
			end -- 3824
			i = i + 1 -- 3800
		end -- 3800
	end -- 3800
	local k = 0 -- 3835
	do -- 3835
		k = 0 -- 3836
		while k < #self.room.marks do -- 3836
			do -- 3836
				local m = self.room.marks[k + 1] -- 3837
				if m.kind ~= 0 then -- 3837
					goto __continue752 -- 3839
				end -- 3839
				local on = self.checkpoint == m.x -- 3841
				local x = self:sx(m.x, w) -- 3842
				local y = self:sy(m.y, h) -- 3843
				draw:drawSegment( -- 3844
					Vec2(x, y), -- 3844
					Vec2( -- 3844
						x, -- 3844
						y + self:px(35) -- 3844
					), -- 3844
					self:px(1), -- 3844
					on and CHECK or INK_DIM -- 3844
				) -- 3844
				draw:drawDot( -- 3845
					Vec2( -- 3845
						x, -- 3845
						y + self:px(35) -- 3845
					), -- 3845
					self:px(2), -- 3845
					on and CHECK or INK_DIM -- 3845
				) -- 3845
			end -- 3845
			::__continue752:: -- 3845
			k = k + 1 -- 3836
		end -- 3836
	end -- 3836
	local j = 0 -- 3849
	do -- 3849
		j = 0 -- 3850
		while j < #self.room.marks do -- 3850
			do -- 3850
				local m = self.room.marks[j + 1] -- 3851
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3851
					goto __continue755 -- 3853
				end -- 3853
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3853
					goto __continue755 -- 3857
				end -- 3857
				local col = STAND -- 3859
				if m.kind == 4 then -- 3859
					col = PASS_LINE -- 3861
				elseif m.kind == 5 then -- 3861
					col = BRICK_LINE -- 3863
				end -- 3863
				local mx = self:sx(m.x, w) -- 3865
				local my = self:sy(m.y, h) -- 3866
				draw:drawSegment( -- 3867
					Vec2(mx, my), -- 3867
					Vec2( -- 3867
						mx, -- 3867
						my + self:px(24) -- 3867
					), -- 3867
					self:px(1), -- 3867
					col -- 3867
				) -- 3867
			end -- 3867
			::__continue755:: -- 3867
			j = j + 1 -- 3850
		end -- 3850
	end -- 3850
	local t = 0 -- 3870
	do -- 3870
		t = 0 -- 3871
		while t < #self.room.marks do -- 3871
			do -- 3871
				local m = self.room.marks[t + 1] -- 3872
				if m.kind ~= 6 then -- 3872
					goto __continue761 -- 3874
				end -- 3874
				local mx = self:sx(m.x, w) -- 3876
				local my = self:sy(m.y, h) -- 3877
				draw:drawSegment( -- 3878
					Vec2(mx, my), -- 3878
					Vec2( -- 3878
						mx, -- 3878
						my + self:px(30) -- 3878
					), -- 3878
					self:px(1), -- 3878
					INK_DIM -- 3878
				) -- 3878
				self:drawBox( -- 3879
					draw, -- 3879
					w, -- 3879
					h, -- 3879
					m.x - 5, -- 3879
					m.x + 5, -- 3879
					m.y + 30, -- 3879
					m.y + 40, -- 3879
					CHECK -- 3879
				) -- 3879
			end -- 3879
			::__continue761:: -- 3879
			t = t + 1 -- 3871
		end -- 3871
	end -- 3871
	if self.room.key == "village" then -- 3871
		self:drawVillage(draw, w, h) -- 3882
	end -- 3882
	if self.room.key == "forest" then -- 3882
		self:drawDog(draw, w, h) -- 3885
	end -- 3885
end -- 3779
function Play.prototype.drawDog(self, draw, w, h) -- 3890
	local x = self.dogX -- 3891
	self:drawBox( -- 3892
		draw, -- 3892
		w, -- 3892
		h, -- 3892
		x - 14, -- 3892
		x + 14, -- 3892
		0, -- 3892
		20, -- 3892
		SCAV_BODY -- 3892
	) -- 3892
	self:drawBox( -- 3893
		draw, -- 3893
		w, -- 3893
		h, -- 3893
		x - 10, -- 3893
		x - 2, -- 3893
		20, -- 3893
		30, -- 3893
		SCAV_BODY -- 3893
	) -- 3893
	self:drawBox( -- 3894
		draw, -- 3894
		w, -- 3894
		h, -- 3894
		x + 2, -- 3894
		x + 10, -- 3894
		20, -- 3894
		30, -- 3894
		SCAV_HEAD -- 3894
	) -- 3894
	if self.dogState == "ear" or self.dogState == "chase" then -- 3894
		draw:drawSegment( -- 3896
			Vec2( -- 3896
				self:sx(x, w), -- 3896
				self:sy(30, h) -- 3896
			), -- 3896
			Vec2( -- 3897
				self:sx(x, w), -- 3897
				self:sy(40, h) -- 3897
			), -- 3897
			self:px(1), -- 3897
			DANGER -- 3897
		) -- 3897
	end -- 3897
end -- 3890
function Play.prototype.drawVillage(self, draw, w, h) -- 3902
	local bottle = self.room.bottle -- 3903
	if bottle ~= nil then -- 3903
		self:drawBox( -- 3905
			draw, -- 3905
			w, -- 3905
			h, -- 3905
			bottle.x - 14, -- 3905
			bottle.x + 14, -- 3905
			0, -- 3905
			64, -- 3905
			SOLID_FILL -- 3905
		) -- 3905
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3905
			self:drawBottle( -- 3907
				draw, -- 3907
				w, -- 3907
				h, -- 3907
				bottle.x, -- 3907
				64 -- 3907
			) -- 3907
		end -- 3907
	end -- 3907
	self:drawBox( -- 3911
		draw, -- 3911
		w, -- 3911
		h, -- 3911
		300, -- 3911
		420, -- 3911
		44, -- 3911
		50, -- 3911
		FLOOR_DECK -- 3911
	) -- 3911
	self:drawBox( -- 3912
		draw, -- 3912
		w, -- 3912
		h, -- 3912
		300, -- 3912
		306, -- 3912
		0, -- 3912
		44, -- 3912
		FLOOR_DECK -- 3912
	) -- 3912
	self:drawBox( -- 3913
		draw, -- 3913
		w, -- 3913
		h, -- 3913
		414, -- 3913
		420, -- 3913
		0, -- 3913
		44, -- 3913
		FLOOR_DECK -- 3913
	) -- 3913
	local s = self.room.scavenger -- 3915
	if s ~= nil then -- 3915
		local sx0 = self.scavX -- 3917
		self:drawBox( -- 3918
			draw, -- 3918
			w, -- 3918
			h, -- 3918
			sx0 - 12, -- 3918
			sx0 + 12, -- 3918
			0, -- 3918
			s.h - 14, -- 3918
			SCAV_BODY -- 3918
		) -- 3918
		self:drawBox( -- 3919
			draw, -- 3919
			w, -- 3919
			h, -- 3919
			sx0 - 7, -- 3919
			sx0 + 7, -- 3919
			s.h - 14, -- 3919
			s.h, -- 3919
			SCAV_HEAD -- 3919
		) -- 3919
		if self.scavState == "turn" then -- 3919
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3921
			draw:drawSegment( -- 3922
				Vec2( -- 3922
					self:sx(sx0, w), -- 3922
					self:sy(s.h - 6, h) -- 3922
				), -- 3922
				Vec2( -- 3922
					self:sx(fx, w), -- 3922
					self:sy(s.h - 6, h) -- 3922
				), -- 3922
				self:px(1), -- 3922
				INK -- 3922
			) -- 3922
		end -- 3922
	end -- 3922
	if self.hasBottle then -- 3922
		local p = self.player -- 3927
		self:drawBottle( -- 3928
			draw, -- 3928
			w, -- 3928
			h, -- 3928
			p.x + p.facing * 10, -- 3928
			p.y + p.h * 0.62 -- 3928
		) -- 3928
	end -- 3928
	if self.bottleFly ~= nil then -- 3928
		self:drawBottle( -- 3931
			draw, -- 3931
			w, -- 3931
			h, -- 3931
			self.bottleFly.x, -- 3931
			self.bottleFly.y -- 3931
		) -- 3931
	end -- 3931
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3931
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3934
		draw:drawCircle( -- 3935
			Vec2( -- 3935
				self:sx(self.bottleLandX, w), -- 3935
				self:sy(0, h) -- 3935
			), -- 3935
			self:px(r / ____exports.UNITS_PER_PX), -- 3935
			BRICK_LINE -- 3935
		) -- 3935
	end -- 3935
end -- 3902
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3939
	self:drawBox( -- 3940
		draw, -- 3940
		w, -- 3940
		h, -- 3940
		x - 3, -- 3940
		x + 3, -- 3940
		y - 10, -- 3940
		y, -- 3940
		BOTTLE -- 3940
	) -- 3940
end -- 3939
function Play.prototype.drawTrace(self, draw, w, h) -- 3943
	local t = self.trace -- 3944
	if t == nil or self.traceT <= 0 then -- 3944
		return -- 3946
	end -- 3946
	draw:drawSegment( -- 3948
		Vec2( -- 3949
			self:sx(t.x0, w), -- 3949
			self:sy(t.y0, h) -- 3949
		), -- 3949
		Vec2( -- 3950
			self:sx(t.x1, w), -- 3950
			self:sy(t.y1, h) -- 3950
		), -- 3950
		self:px(1), -- 3951
		t.hit and AIM_HIT or INK_DIM -- 3951
	) -- 3951
end -- 3943
function Play.prototype.drawAim(self, draw, w, h) -- 3954
	local v = self.view -- 3956
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3957
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3958
	local dot = self:px(1) -- 3959
	local arm = self:px(3) -- 3960
	local gap = self:px(1) -- 3961
	draw:drawSegment( -- 3962
		Vec2(gx - arm - gap, gy), -- 3962
		Vec2(gx - gap, gy), -- 3962
		dot / 2, -- 3962
		AIM -- 3962
	) -- 3962
	draw:drawSegment( -- 3963
		Vec2(gx + gap, gy), -- 3963
		Vec2(gx + arm + gap, gy), -- 3963
		dot / 2, -- 3963
		AIM -- 3963
	) -- 3963
	draw:drawSegment( -- 3964
		Vec2(gx, gy - arm - gap), -- 3964
		Vec2(gx, gy - gap), -- 3964
		dot / 2, -- 3964
		AIM -- 3964
	) -- 3964
	draw:drawSegment( -- 3965
		Vec2(gx, gy + gap), -- 3965
		Vec2(gx, gy + arm + gap), -- 3965
		dot / 2, -- 3965
		AIM -- 3965
	) -- 3965
	if self.room.key == "village" and self.hasBottle then -- 3965
		local p = self.player -- 3969
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3971
		local dir = ____end.x >= p.x and 1 or -1 -- 3972
		local x0 = p.x + dir * 10 -- 3973
		local y0 = p.y + p.h * 0.7 -- 3974
		local T = BOTTLE_FLY_TIME -- 3975
		local vx = (____end.x - x0) / T -- 3976
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3977
		local pxr = x0 -- 3978
		local pyr = y0 -- 3979
		local t = 1 -- 3980
		do -- 3980
			t = 1 -- 3981
			while t <= 12 do -- 3981
				local tt = t / 12 * T -- 3982
				local nx = x0 + vx * tt -- 3983
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3984
				draw:drawSegment( -- 3985
					Vec2( -- 3985
						self:sx(pxr, w), -- 3985
						self:sy(pyr, h) -- 3985
					), -- 3985
					Vec2( -- 3985
						self:sx(nx, w), -- 3985
						self:sy(ny, h) -- 3985
					), -- 3985
					self:px(1) / 2, -- 3985
					BOTTLE -- 3985
				) -- 3985
				pxr = nx -- 3986
				pyr = ny -- 3987
				t = t + 1 -- 3981
			end -- 3981
		end -- 3981
		draw:drawCircle( -- 3989
			Vec2( -- 3989
				self:sx(____end.x, w), -- 3989
				self:sy(____end.y + 2, h) -- 3989
			), -- 3989
			self:px(2), -- 3989
			BOTTLE -- 3989
		) -- 3989
	end -- 3989
end -- 3954
return ____exports -- 3954