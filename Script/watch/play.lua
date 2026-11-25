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
local mmss = ____run.mmss -- 17
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
function makeActor(room, index) -- 3951
	local sp = room.spawns -- 3952
	if index < 0 or index >= #sp then -- 3952
		return { -- 3954
			x = 0, -- 3954
			y = 0, -- 3954
			depth = 0, -- 3954
			depthSpeed = 0, -- 3954
			vx = 0, -- 3954
			vy = 0, -- 3954
			w = CHILD_W, -- 3954
			h = CHILD_H, -- 3954
			onGround = true, -- 3954
			facing = 1, -- 3954
			crouch = false, -- 3954
			rollT = 0, -- 3954
			covered = false, -- 3954
			alive = false -- 3954
		} -- 3954
	end -- 3954
	local s = sp[index + 1] -- 3956
	local child = s.h <= CHILD_H -- 3957
	local ground = room.depth -- 3958
	local depth = ground == nil and 0 or math.max( -- 3959
		ground.min, -- 3959
		math.min(ground.max, s.depth or 0) -- 3959
	) -- 3959
	return { -- 3960
		x = s.x, -- 3961
		y = s.y, -- 3961
		depth = depth, -- 3961
		depthSpeed = 0, -- 3961
		vx = 0, -- 3961
		vy = 0, -- 3961
		w = child and CHILD_W or SOLDIER_W, -- 3962
		h = child and CHILD_H or SOLDIER_H, -- 3963
		onGround = true, -- 3964
		facing = 1, -- 3964
		crouch = false, -- 3964
		rollT = 0, -- 3964
		covered = false, -- 3964
		alive = true -- 3964
	} -- 3964
end -- 3964
function drawFigure(draw, play, w, h, a, body, head) -- 3968
	if not a.alive then -- 3968
		return -- 3970
	end -- 3970
	local x0 = a.x - a.w / 2 -- 3972
	local x1 = a.x + a.w / 2 -- 3973
	local y0 = a.y + a.depth -- 3974
	local y1 = y0 + a.h -- 3975
	play:drawBox( -- 3976
		draw, -- 3976
		w, -- 3976
		h, -- 3976
		x0, -- 3976
		x1, -- 3976
		y0, -- 3976
		y1 - a.h * 0.26, -- 3976
		body -- 3976
	) -- 3976
	play:drawBox( -- 3977
		draw, -- 3977
		w, -- 3977
		h, -- 3977
		x0 + 2, -- 3977
		x1 - 2, -- 3977
		y1 - a.h * 0.26, -- 3977
		y1, -- 3977
		head -- 3977
	) -- 3977
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3979
	play:drawBox( -- 3980
		draw, -- 3980
		w, -- 3980
		h, -- 3980
		eyeX, -- 3980
		eyeX + 4, -- 3980
		y1 - a.h * 0.14, -- 3980
		y1 - a.h * 0.08, -- 3980
		INK -- 3980
	) -- 3980
end -- 3980
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3984
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3985
end -- 3984
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3992
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3993
end -- 3992
function rayInterval(origin, direction, min, max) -- 4000
	if direction == 0 then -- 4000
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4002
	end -- 4002
	local a = (min - origin) / direction -- 4004
	local b = (max - origin) / direction -- 4005
	return { -- 4006
		min = math.min(a, b), -- 4006
		max = math.max(a, b) -- 4006
	} -- 4006
end -- 4006
function hitBox(ray, box) -- 4010
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4011
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4012
	local enter = math.max(0, x.min, y.min) -- 4013
	local leave = math.min(99999, x.max, y.max) -- 4014
	if box.depth ~= nil then -- 4014
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4016
		enter = math.max(enter, depth.min) -- 4017
		leave = math.min(leave, depth.max) -- 4018
	end -- 4018
	return leave >= enter and enter or -1 -- 4020
end -- 4020
function drawCartShape(draw, play, w, h, c, axleX) -- 4023
	local half = c.bodyW / 2 -- 4024
	local x0 = axleX - half -- 4025
	local x1 = axleX + half -- 4026
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4027
	play:drawBox( -- 4028
		draw, -- 4028
		w, -- 4028
		h, -- 4028
		x0, -- 4028
		x1, -- 4028
		axleY, -- 4028
		axleY + c.bodyH, -- 4028
		CART_FILL -- 4028
	) -- 4028
	draw:drawCircle( -- 4029
		Vec2( -- 4029
			play:sx(x0 + c.bodyW * 0.28, w), -- 4029
			play:sy(axleY, h) -- 4029
		), -- 4029
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4029
		Color(52, 50, 48, 255) -- 4029
	) -- 4029
	draw:drawCircle( -- 4030
		Vec2( -- 4030
			play:sx(x1 - c.bodyW * 0.28, w), -- 4030
			play:sy(axleY, h) -- 4030
		), -- 4030
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4030
		Color(52, 50, 48, 255) -- 4030
	) -- 4030
	local cx = c.clothSide < 0 and x0 or x1 -- 4031
	play:drawBox( -- 4032
		draw, -- 4032
		w, -- 4032
		h, -- 4032
		cx - 10, -- 4032
		cx + 10, -- 4032
		axleY + c.bodyH, -- 4032
		axleY + c.bodyH + 18, -- 4032
		CLOTH -- 4032
	) -- 4032
end -- 4032
____exports.STEP = STEP -- 24
____exports.GRAVITY = 1000 -- 25
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 27
CHILD_W = 28 -- 65
CHILD_H = 64 -- 66
local CHILD_CROUCH_H = 36 -- 67
local CHILD_SPEED = 160 -- 68
local CHILD_SLOW = 80 -- 69
local CHILD_JUMP = 320 -- 70
SOLDIER_W = 30 -- 73
SOLDIER_H = 88 -- 74
local SOLDIER_SPEED = 264 -- 75
local ROLL_TIME = 0.35 -- 76
local ROLL_SPEED = 280 -- 77
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 79
local LEDGE_RISE = 60 -- 80
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 83
____exports.LOGIC_H = 180 -- 84
____exports.UNITS_PER_PX = 2 -- 85
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 87
local CAM_FOLLOW = 9 -- 88
local CAM_LOOK_UP = 46 -- 89
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 92
--- 握把触发半径。
____exports.CART_REACH = 70 -- 94
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 96
local CART_CLEAR = 44 -- 97
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 99
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 101
local CONSUMABLE_CAP = 1 -- 102
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 104
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 106
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 108
local FIRE_COOLDOWN = 150 -- 109
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 111
local ENEMY_RANGE = 760 -- 112
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 114
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 116
local DEPTH_SPEED_RATIO = 0.55 -- 117
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 118
INK = Color(232, 232, 228, 255) -- 120
local INK_DIM = Color(150, 152, 150, 255) -- 121
local BG_VOID = Color(8, 9, 10, 255) -- 122
local BG_FAR = Color(24, 26, 28, 255) -- 123
local BG_MID = Color(31, 34, 37, 255) -- 124
local GROUND = Color(112, 114, 112, 255) -- 125
local FLOOR_DECK = Color(66, 70, 72, 255) -- 126
local SOLID_FILL = Color(84, 86, 84, 255) -- 127
local SOLID_EDGE = Color(126, 130, 126, 255) -- 128
CART_FILL = Color(122, 78, 56, 255) -- 129
CLOTH = Color(178, 52, 46, 255) -- 130
local DANGER = Color(150, 54, 48, 46) -- 131
local DANGER_LINE = Color(178, 78, 64, 200) -- 132
local HOLE_FILL = Color(10, 11, 12, 255) -- 133
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 134
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 135
local CHILD_BODY = Color(214, 168, 96, 255) -- 136
local CHILD_HEAD = Color(232, 214, 186, 255) -- 137
local ENEMY_BODY = Color(176, 92, 84, 255) -- 138
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 139
local CHECK = Color(96, 186, 122, 255) -- 140
local STAND = Color(226, 186, 84, 255) -- 141
local AIM = Color(236, 236, 232, 230) -- 142
local AIM_HIT = Color(236, 96, 84, 255) -- 143
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 145
local SOFT_LINE = Color(140, 112, 80, 190) -- 146
local BRICK = Color(126, 118, 110, 70) -- 147
local BRICK_LINE = Color(160, 152, 142, 200) -- 148
local PASS = Color(96, 186, 122, 40) -- 149
local PASS_LINE = Color(96, 186, 122, 200) -- 150
local BOTTLE = Color(120, 186, 160, 255) -- 151
local SCAV_BODY = Color(128, 118, 96, 255) -- 152
local SCAV_HEAD = Color(196, 182, 158, 255) -- 153
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 240
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 241
	if zoom < 1 then -- 241
		zoom = 1 -- 243
	end -- 243
	return { -- 245
		zoom = zoom, -- 246
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 247
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 248
	} -- 248
end -- 240
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 271
	if key == "prologue" then -- 271
		return "prologue-wait" -- 273
	end -- 273
	if key == "street" then -- 273
		return "street-run" -- 276
	end -- 276
	if key == "gate" then -- 276
		return "gate-idle" -- 279
	end -- 279
	if key == "forest" then -- 279
		return "forest-run" -- 282
	end -- 282
	if key == "tower" then -- 282
		return "tower-wait" -- 285
	end -- 285
	return "run" -- 287
end -- 271
____exports.Play = __TS__Class() -- 290
local Play = ____exports.Play -- 290
Play.name = "Play" -- 290
function Play.prototype.____constructor(self, room, resume, run) -- 463
	self.enemies = {} -- 295
	self.boxes = {} -- 296
	self.floors = {} -- 297
	self.checkpoint = -1 -- 299
	self.flash = "" -- 301
	self.flashT = 0 -- 302
	self.traceT = 0 -- 305
	self.focusCart = false -- 307
	self.knocks = 0 -- 309
	self.knockT = 0 -- 310
	self.cartAxle = 0 -- 314
	self.cartDocked = false -- 316
	self.gripping = false -- 318
	self.gateOpen = false -- 320
	self.calmConsumed = false -- 322
	self.craftT = 0 -- 324
	self.nextDangerId = 1 -- 326
	self.wantRoom = "" -- 328
	self.carryCartAxle = -1 -- 330
	self.carryCartDocked = false -- 331
	self.checkpointCartAxle = -1 -- 333
	self.hasBottle = false -- 337
	self.bottleLandX = -1 -- 341
	self.bottleTargetX = -1 -- 342
	self.bottleTargetY = 0 -- 343
	self.bottleLandT = 0 -- 344
	self.aimHold = 0 -- 346
	self.scavX = 0 -- 348
	self.scavDir = 1 -- 349
	self.scavState = "patrol" -- 350
	self.scavT = 0 -- 351
	self.scavTargetX = 0 -- 352
	self.passed = false -- 354
	self.childMode = false -- 358
	self.phase = "" -- 360
	self.phaseTick = 0 -- 362
	self.gateTick = 0 -- 364
	self.countTick = 0 -- 366
	self.countArmed = false -- 368
	self.countPrevMove = 0 -- 370
	self.caughtT = 0 -- 372
	self.hp = 3 -- 374
	self.maxHp = 3 -- 375
	self.invulnT = 0 -- 381
	self.partnerStuck = 0 -- 383
	self.partnerLaneIdx = 0 -- 385
	self.partnerLaneHold = 0 -- 386
	self.coveredFlash = 0 -- 388
	self.coverHug = false -- 390
	self.coverNear = false -- 392
	self.coverEntity = "" -- 394
	self.coverBlocking = false -- 396
	self.gateNeedConfirm = false -- 398
	self.gateRestartArmed = true -- 400
	self.bottleAimX = -1 -- 402
	self.bottleAimY = 0 -- 403
	self.bottleSurfaceY = -1 -- 405
	self.bottleLandY = 0 -- 407
	self.events = {} -- 409
	self.eventSeq = 0 -- 411
	self.dogX = 0 -- 413
	self.dogDir = 1 -- 414
	self.dogState = "patrol" -- 415
	self.dogT = 0 -- 416
	self.dogTargetX = 0 -- 417
	self.scavSee = 0 -- 419
	self.scavChase = false -- 420
	self.gateSpawned = 0 -- 422
	self.gateFailCount = 0 -- 424
	self.isCampaign = false -- 428
	self.pickups = {} -- 432
	self.reloadT = 0 -- 434
	self.objectiveDone = false -- 438
	self.hint = "" -- 440
	self.roomStartTick = 0 -- 442
	self.cartHitT = 0 -- 444
	self.cartExposed = false -- 445
	self.paused = false -- 447
	self.ticks = 0 -- 449
	self.view = {zoom = 1, ox = 0, oy = 0} -- 451
	self.ox = 0 -- 453
	self.aimX = 0 -- 455
	self.aimY = 0 -- 456
	self.viewW = 0 -- 458
	self.viewH = 0 -- 459
	self.ox = room.originX -- 465
	self.room = withOrigin(room) -- 466
	local wr = self.room -- 467
	self.run = run or createRun() -- 468
	self.isCampaign = wr.campaign ~= nil -- 469
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 470
	self:buildWorld() -- 471
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 473
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 474
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 475
	self.player = makeActor(wr, playerIdx) -- 476
	self.partner = makeActor(wr, partnerIdx) -- 477
	self.phase = phaseOf(wr.key) -- 478
	if wr.story ~= nil then -- 478
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 480
	end -- 480
	self.cam.x = self.player.x -- 482
	self.cam.y = self.player.y + CAM_LOOK_UP -- 483
	self.cartAxle = wr.cart.startX -- 484
	self.escort = __TS__New( -- 485
		Escort, -- 485
		safeAnchorX(wr.marks) -- 485
	) -- 485
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 486
	if self.isCampaign then -- 486
		self:setupCampaign() -- 488
	else -- 488
		self:buildEnemies() -- 490
	end -- 490
	if resume ~= nil and resume.checkpoint > 0 then -- 490
		self.checkpoint = resume.checkpoint -- 494
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 494
			self.cartAxle = self.room.cart.endX -- 496
			self.cartDocked = true -- 497
			self.player.x = self.ox + 380 -- 500
			self.player.y = 0 -- 501
			self.player.vy = 0 -- 502
			self.player.onGround = true -- 503
			self.cam.x = self.player.x -- 504
			self.cam.y = self.player.y + CAM_LOOK_UP -- 505
		end -- 505
	end -- 505
end -- 463
function Play.prototype.buildWorld(self) -- 511
	local room = self.room -- 512
	self.boxes = {} -- 513
	self.floors = {} -- 514
	local i = 0 -- 515
	do -- 515
		i = 0 -- 516
		while i < #room.floors do -- 516
			local f = room.floors[i + 1] -- 517
			local ____self_floors_0 = self.floors -- 517
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 518
			i = i + 1 -- 516
		end -- 516
	end -- 516
	do -- 516
		i = 0 -- 520
		while i < #room.solids do -- 520
			local s = room.solids[i + 1] -- 521
			if not s.decorative then -- 521
				local ____self_boxes_12 = self.boxes -- 527
				local ____s_x_3 = s.x -- 528
				local ____temp_4 = s.x + s.w -- 528
				local ____s_y_5 = s.y -- 528
				local ____temp_6 = s.y + s.h -- 528
				local ____temp_1 -- 529
				if room.depth == nil then -- 529
					____temp_1 = nil -- 529
				else -- 529
					____temp_1 = s.depth -- 529
				end -- 529
				local ____temp_7 = s.passable == true -- 530
				local ____s_label_8 = s.label -- 530
				local ____s_id_9 = s.id -- 531
				local ____temp_10 = s.soft == true -- 531
				local ____temp_11 = s.hidden == true -- 531
				local ____temp_2 -- 532
				if s.breakable == nil then -- 532
					____temp_2 = nil -- 532
				else -- 532
					____temp_2 = __TS__ObjectAssign({}, s.breakable) -- 532
				end -- 532
				____self_boxes_12[#____self_boxes_12 + 1] = { -- 527
					x0 = ____s_x_3, -- 528
					x1 = ____temp_4, -- 528
					y0 = ____s_y_5, -- 528
					y1 = ____temp_6, -- 528
					depth = ____temp_1, -- 529
					passable = ____temp_7, -- 530
					label = ____s_label_8, -- 530
					id = ____s_id_9, -- 531
					soft = ____temp_10, -- 531
					hidden = ____temp_11, -- 531
					breakable = ____temp_2, -- 532
					interact = s.interact -- 533
				} -- 533
			end -- 533
			i = i + 1 -- 520
		end -- 520
	end -- 520
	do -- 520
		i = 0 -- 537
		while i < #room.stairs do -- 537
			local st = room.stairs[i + 1] -- 538
			local n = st.steps + 1 -- 539
			local stepW = (st.x1 - st.x0) / n -- 540
			local k = 0 -- 541
			do -- 541
				k = 0 -- 542
				while k < n do -- 542
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 543
					local x0 = st.x0 + stepW * k -- 544
					local ____self_boxes_13 = self.boxes -- 544
					____self_boxes_13[#____self_boxes_13 + 1] = { -- 546
						x0 = x0, -- 546
						x1 = x0 + stepW, -- 546
						y0 = -8, -- 546
						y1 = y, -- 546
						passable = true -- 546
					} -- 546
					k = k + 1 -- 542
				end -- 542
			end -- 542
			i = i + 1 -- 537
		end -- 537
	end -- 537
end -- 511
function Play.prototype.setupCampaign(self) -- 555
	local wr = self.room -- 556
	local c = wr.campaign -- 557
	if c == nil then -- 557
		return -- 559
	end -- 559
	self.roomStartTick = self.run.ticks -- 561
	if wr.key == "s1-crossroad" then -- 561
		self.run.joined = true -- 564
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 564
		local ____self_run_15 = self.run -- 567
		local ____temp_14 -- 567
		if wr.key == "s2-drygoods" then -- 567
			____temp_14 = self.run.route ~= "drygoods" -- 567
		else -- 567
			____temp_14 = false -- 567
		end -- 567
		____self_run_15.joined = ____temp_14 -- 567
	end -- 567
	local x = wr.minX + 60 -- 569
	local y = 0 -- 570
	local depth = 0 -- 571
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 571
		x = wr.minX + 210 -- 573
		depth = -32 -- 574
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 574
		x = wr.minX + 40 -- 576
		y = 32 -- 577
		depth = 32 -- 578
	end -- 578
	self.player = { -- 580
		x = x, -- 581
		y = y, -- 581
		depth = depth, -- 581
		depthSpeed = 0, -- 581
		vx = 0, -- 581
		vy = 0, -- 581
		w = SOLDIER_W, -- 582
		h = SOLDIER_H, -- 582
		onGround = y <= 0, -- 582
		facing = 1, -- 582
		crouch = false, -- 582
		rollT = 0, -- 582
		covered = false, -- 582
		alive = true -- 582
	} -- 582
	self.partner = { -- 584
		x = x + 60, -- 585
		y = y, -- 585
		depth = depth, -- 585
		depthSpeed = 0, -- 585
		vx = 0, -- 585
		vy = 0, -- 585
		w = CHILD_W, -- 586
		h = CHILD_H, -- 586
		onGround = y <= 0, -- 586
		facing = 1, -- 586
		crouch = false, -- 586
		rollT = 0, -- 586
		covered = false, -- 586
		alive = true -- 586
	} -- 586
	self.cam.x = x -- 588
	self.cam.y = y + CAM_LOOK_UP -- 589
	self.phase = "run" -- 590
	self.hp = self.maxHp -- 591
	self:buildEnemies() -- 592
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 593
	local i = 0 -- 594
	do -- 594
		i = 0 -- 595
		while i < #self.boxes do -- 595
			do -- 595
				local b = self.boxes[i + 1] -- 596
				if b.id == nil then -- 596
					goto __continue33 -- 598
				end -- 598
				local st = self.run.props[b.id] -- 600
				if st ~= nil then -- 600
					b.broken = st.broken -- 602
					local ____temp_16 -- 603
					if b.breakable == nil then -- 603
						____temp_16 = nil -- 603
					else -- 603
						____temp_16 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 603
					end -- 603
					b.breakable = ____temp_16 -- 603
					b.hidden = b.hidden == true and st.revealed ~= true -- 604
					if b.hidden then -- 604
						b.broken = true -- 606
					end -- 606
				elseif b.hidden == true then -- 606
					b.broken = true -- 610
				end -- 610
			end -- 610
			::__continue33:: -- 610
			i = i + 1 -- 595
		end -- 595
	end -- 595
	if wr.cart.bodyW > 0 then -- 595
		self.cartAxle = wr.cart.startX -- 614
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 614
			self.cartAxle = wr.cart.endX -- 616
			self.cartDocked = true -- 617
		end -- 617
	end -- 617
	do -- 617
		i = 0 -- 620
		while i < #self.pickups do -- 620
			local pk = self.pickups[i + 1] -- 621
			if self.run.taken[pk.id] == true then -- 621
				pk.id = "" -- 623
			end -- 623
			i = i + 1 -- 620
		end -- 620
	end -- 620
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 626
end -- 555
function Play.prototype.log(self, line) -- 629
	local ____self_run_log_17 = self.run.log -- 629
	____self_run_log_17[#____self_run_log_17 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 630
	if #self.run.log > 120 then -- 630
		table.remove(self.run.log, 1) -- 632
	end -- 632
end -- 629
function Play.prototype.buildEnemies(self) -- 636
	self.enemies = {} -- 637
	if self.isCampaign then -- 637
		local i = 0 -- 639
		do -- 639
			i = 0 -- 640
			while i < #self.room.spawns do -- 640
				local sp = self.room.spawns[i + 1] -- 641
				local kind = sp.kind or "gunner" -- 642
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 643
				local ____self_enemies_18 = self.enemies -- 643
				____self_enemies_18[#____self_enemies_18 + 1] = { -- 644
					x = sp.x, -- 645
					y = sp.y, -- 645
					depth = sp.depth, -- 645
					w = 26, -- 645
					h = sp.h, -- 645
					alive = true, -- 645
					hitT = 0, -- 645
					warnT = 0, -- 645
					fireCd = 40, -- 645
					kind = kind, -- 646
					shieldHp = hp, -- 646
					shieldHpMax = hp, -- 646
					drop = sp.drop or "none", -- 646
					homeX = sp.x, -- 647
					swingT = 0, -- 647
					awake = false, -- 647
					squad = i -- 647
				} -- 647
				i = i + 1 -- 640
			end -- 640
		end -- 640
		return -- 650
	end -- 650
	if self.room.key == "checkpoint" then -- 650
		local ____self_enemies_19 = self.enemies -- 650
		____self_enemies_19[#____self_enemies_19 + 1] = { -- 653
			x = self.ox + 430, -- 653
			y = 0, -- 653
			w = 26, -- 653
			h = 84, -- 653
			alive = true, -- 653
			hitT = 0, -- 653
			warnT = 0, -- 653
			fireCd = 0 -- 653
		} -- 653
		local ____self_enemies_20 = self.enemies -- 653
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 654
			x = self.ox + 505, -- 654
			y = 0, -- 654
			w = 26, -- 654
			h = 84, -- 654
			alive = true, -- 654
			hitT = 0, -- 654
			warnT = 0, -- 654
			fireCd = 0 -- 654
		} -- 654
		return -- 655
	end -- 655
	if self.room.key == "street" then -- 655
		local ____self_enemies_21 = self.enemies -- 655
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 659
			x = self.ox + 340, -- 659
			y = 0, -- 659
			w = 26, -- 659
			h = 84, -- 659
			alive = true, -- 659
			hitT = 0, -- 659
			warnT = 0, -- 659
			fireCd = 0 -- 659
		} -- 659
		local ____self_enemies_22 = self.enemies -- 659
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 660
			x = self.ox + 560, -- 660
			y = 0, -- 660
			w = 26, -- 660
			h = 84, -- 660
			alive = true, -- 660
			hitT = 0, -- 660
			warnT = 0, -- 660
			fireCd = 0 -- 660
		} -- 660
	end -- 660
end -- 636
function Play.prototype.emit(self, name, data) -- 666
	local ____self_events_23 = self.events -- 666
	____self_events_23[#____self_events_23 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 667
	self.eventSeq = self.eventSeq + 1 -- 668
	if #self.events > 256 then -- 668
		table.remove(self.events, 1) -- 670
	end -- 670
end -- 666
function Play.prototype.drainEvents(self) -- 678
	local out = self.events -- 679
	self.events = {} -- 680
	return out -- 681
end -- 678
function Play.prototype.adoptEvents(self, events) -- 690
	if #events == 0 then -- 690
		return -- 692
	end -- 692
	local keep = {} -- 694
	local i = 0 -- 695
	do -- 695
		i = 0 -- 696
		while i < #events do -- 696
			do -- 696
				local e = events[i + 1] -- 697
				if e.name == "knock" and e.data.room ~= self.room.key then -- 697
					goto __continue57 -- 699
				end -- 699
				keep[#keep + 1] = e -- 701
			end -- 701
			::__continue57:: -- 701
			i = i + 1 -- 696
		end -- 696
	end -- 696
	if #keep == 0 then -- 696
		return -- 704
	end -- 704
	self.events = __TS__ArrayConcat(keep, self.events) -- 706
	do -- 706
		i = 0 -- 707
		while i < #self.events do -- 707
			self.events[i + 1].seq = i -- 708
			i = i + 1 -- 707
		end -- 707
	end -- 707
	self.eventSeq = #self.events -- 710
end -- 690
function Play.prototype.update(self, dt, input) -- 714
	if input.pause.pressed then -- 714
		self.paused = not self.paused -- 716
	end -- 716
	if self.flashT > 0 then -- 716
		self.flashT = self.flashT - dt -- 719
		if self.flashT <= 0 then -- 719
			self.flash = "" -- 721
		end -- 721
	end -- 721
	if self.traceT > 0 then -- 721
		self.traceT = self.traceT - dt -- 725
		if self.traceT <= 0 then -- 725
			self.trace = nil -- 727
		end -- 727
	end -- 727
	if self.paused then -- 727
		self:updateCamera(dt) -- 731
		return -- 732
	end -- 732
	self.ticks = self.ticks + 1 -- 735
	if self.invulnT > 0 then -- 735
		self.invulnT = self.invulnT - 1 -- 739
	end -- 739
	if self.isCampaign then -- 739
		local ____self_run_24, ____ticks_25 = self.run, "ticks" -- 739
		____self_run_24[____ticks_25] = ____self_run_24[____ticks_25] + 1 -- 742
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 743
	end -- 743
	local p = self.player -- 745
	self:stepPlayer(p, dt, input) -- 746
	self:refreshCover(p, input) -- 748
	if self.isCampaign then -- 748
		self:stepCampaign(dt, input) -- 750
		self:stepCampaignPartner(dt) -- 751
	end -- 751
	self:stepEnemies(dt, input) -- 754
	if not self.isCampaign then -- 754
		self:stepStory(dt, input) -- 756
		self:stepEscort(dt, input) -- 757
		self:stepVillage(dt, input) -- 758
		self:stepChase(dt, input) -- 759
		self:stepInteract(dt, input) -- 760
	end -- 760
	self:updateGate() -- 762
	self:updateCamera(dt) -- 763
end -- 714
function Play.prototype.underLowArch(self, a) -- 770
	local arch = self.room.arch -- 771
	if arch.h <= 0 then -- 771
		return false -- 773
	end -- 773
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 773
		return false -- 776
	end -- 776
	local top = arch.y + arch.h -- 778
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 779
end -- 770
function Play.prototype.coverAt(self, a) -- 786
	local best = nil -- 787
	local bestGap = 24 -- 788
	local half = a.w / 2 -- 789
	local i = 0 -- 790
	do -- 790
		i = 0 -- 791
		while i < #self.boxes do -- 791
			do -- 791
				local b = self.boxes[i + 1] -- 792
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 792
					goto __continue78 -- 794
				end -- 794
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 794
					goto __continue78 -- 797
				end -- 797
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 799
				if gap < bestGap then -- 799
					bestGap = gap -- 801
					best = b -- 802
				end -- 802
			end -- 802
			::__continue78:: -- 802
			i = i + 1 -- 791
		end -- 791
	end -- 791
	return best -- 805
end -- 786
function Play.prototype.nearCover(self, a) -- 808
	return self:coverAt(a) ~= nil -- 809
end -- 808
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 813
	if enemy == nil then -- 813
		return false -- 815
	end -- 815
	local fromRight = enemy.x >= a.x -- 817
	local edge = fromRight and b.x0 or b.x1 -- 818
	local ____fromRight_26 -- 819
	if fromRight then -- 819
		____fromRight_26 = edge >= a.x - 0.001 and edge <= enemy.x -- 819
	else -- 819
		____fromRight_26 = edge <= a.x + 0.001 and edge >= enemy.x -- 820
	end -- 820
	local between = ____fromRight_26 -- 819
	local separation = enemy.x - a.x -- 821
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 822
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 823
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 824
end -- 813
function Play.prototype.nearestEnemy(self, a) -- 827
	local best -- 828
	local bestD = 1000000000 -- 829
	local i = 0 -- 830
	do -- 830
		i = 0 -- 831
		while i < #self.enemies do -- 831
			do -- 831
				local e = self.enemies[i + 1] -- 832
				if not e.alive then -- 832
					goto __continue87 -- 834
				end -- 834
				local d = math.abs(e.x - a.x) -- 836
				if d < bestD then -- 836
					bestD = d -- 838
					best = e -- 839
				end -- 839
			end -- 839
			::__continue87:: -- 839
			i = i + 1 -- 831
		end -- 831
	end -- 831
	return best -- 842
end -- 827
function Play.prototype.refreshCover(self, a, input) -- 846
	if self.childMode then -- 846
		self.coverNear = false -- 848
		self.coverHug = false -- 849
		self.coverEntity = "" -- 850
		self.coverBlocking = false -- 851
		a.covered = false -- 852
		return -- 853
	end -- 853
	local b = self:coverAt(a) -- 855
	self.coverNear = b ~= nil -- 856
	a.covered = self.coverNear and input.cover.held -- 857
	self.coverHug = a.covered -- 858
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 859
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 860
		b, -- 860
		a, -- 860
		self:nearestEnemy(a) -- 860
	) -- 860
end -- 846
function Play.prototype.cartHandleInReach(self, a) -- 864
	if a == nil then -- 864
		a = self.player -- 864
	end -- 864
	local c = self.room.cart -- 865
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 865
		return false -- 867
	end -- 867
	local handleX = self.cartAxle + c.handleOffset -- 869
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 870
end -- 864
function Play.prototype.nearLowLedge(self, a) -- 875
	local reach = 26 -- 876
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 877
	local x1 = x0 + reach -- 878
	local i = 0 -- 879
	do -- 879
		i = 0 -- 880
		while i < #self.boxes do -- 880
			do -- 880
				local b = self.boxes[i + 1] -- 881
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 881
					goto __continue96 -- 883
				end -- 883
				local rise = b.y1 - a.y -- 885
				if rise > 0 and rise <= LEDGE_RISE then -- 885
					return true -- 887
				end -- 887
			end -- 887
			::__continue96:: -- 887
			i = i + 1 -- 880
		end -- 880
	end -- 880
	return false -- 890
end -- 875
function Play.prototype.stepPlayer(self, a, dt, input) -- 893
	a.depthSpeed = 0 -- 894
	if not a.alive then -- 894
		return -- 896
	end -- 896
	local isChild = self.childMode -- 898
	local lowArch = isChild and self:underLowArch(a) -- 900
	if self:storyLocked() then -- 900
		a.vx = 0 -- 903
		a.crouch = isChild and lowArch -- 904
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 905
		self:fallY(a, dt) -- 906
		return -- 907
	end -- 907
	if not isChild and self.escort.state == "calming" then -- 907
		a.crouch = false -- 911
		a.h = SOLDIER_H -- 912
		a.vx = 0 -- 913
		self:fallY(a, dt) -- 914
		return -- 915
	end -- 915
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 917
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 918
	local nearCover = not isChild and self:nearCover(a) -- 919
	a.covered = nearCover and input.cover.held -- 920
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 922
	if a.rollT > 0 then -- 922
		a.rollT = a.rollT - dt -- 926
		a.vx = a.facing * ROLL_SPEED -- 927
		self:slideX(a, a.vx * dt) -- 928
		self:fallY(a, dt) -- 929
		if a.rollT <= 0 then -- 929
			self:flashSet("翻滚结束", 0.5) -- 931
		end -- 931
		return -- 933
	end -- 933
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 933
		if input.moveX ~= 0 then -- 933
			a.facing = input.moveX > 0 and 1 or -1 -- 938
		end -- 938
		if self:nearLowLedge(a) then -- 938
			a.vy = SOLDIER_JUMP -- 942
			a.onGround = false -- 943
			self:flashSet("翻上去", 0.3) -- 944
			return -- 945
		end -- 945
		a.rollT = ROLL_TIME -- 947
		self:flashSet("翻滚", 0.3) -- 948
		return -- 949
	end -- 949
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 952
	if isChild then -- 952
		if input.cover.held then -- 952
			speed = CHILD_SLOW -- 955
		end -- 955
		if a.crouch then -- 955
			speed = CHILD_SLOW -- 958
		end -- 958
	elseif a.covered then -- 958
		speed = SOLDIER_SPEED * 0.45 -- 961
	end -- 961
	local handsBusy = self.gripping or gripIntent -- 965
	local dir = self.gripping and 0 or input.moveX -- 966
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 967
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 968
	if dir ~= 0 then -- 968
		a.facing = dir > 0 and 1 or -1 -- 970
	end -- 970
	a.vx = dir * speed * diagonal -- 972
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 972
		a.vy = CHILD_JUMP -- 976
		a.onGround = false -- 977
		self:flashSet("跳", 0.25) -- 978
	end -- 978
	local previousDepth = a.depth -- 982
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 983
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 984
	self:slideX(a, a.vx * dt) -- 985
	self:fallY(a, dt) -- 986
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 986
		self:shoot(a) -- 990
	end -- 990
end -- 893
function Play.prototype.stepPartner(self, p, dt) -- 995
	local a = self.partner -- 996
	if not a.alive then -- 996
		return -- 998
	end -- 998
	a.crouch = false -- 1000
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1001
	a.vx = 0 -- 1002
	a.depthSpeed = 0 -- 1003
	self:fallY(a, dt) -- 1004
end -- 995
function Play.prototype.stepEscort(self, dt, input) -- 1011
	local a = self.partner -- 1012
	a.depthSpeed = 0 -- 1013
	if not a.alive then -- 1013
		return -- 1015
	end -- 1015
	if not self:escortOn() then -- 1015
		a.vx = 0 -- 1018
		self:fallY(a, dt) -- 1019
		return -- 1020
	end -- 1020
	local p = self.player -- 1022
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1023
	local hadKnock1 = self.escort.knock1 -- 1024
	local hadKnock2 = self.escort.knock2 -- 1025
	self.calmConsumed = self.escort:update( -- 1026
		input, -- 1026
		p.x, -- 1026
		p.facing, -- 1026
		a.x, -- 1026
		dist -- 1026
	) -- 1026
	if not hadKnock1 and self.escort.knock1 then -- 1026
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1029
	end -- 1029
	if not hadKnock2 and self.escort.knock2 then -- 1029
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1032
	end -- 1032
	a.crouch = self.escort.crouchPose -- 1034
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1035
	if not self.escort.stopped then -- 1035
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1037
		local previousDepth = a.depth -- 1038
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1039
		local distance = math.max( -- 1040
			-travel, -- 1040
			math.min(travel, targetDepth - previousDepth) -- 1040
		) -- 1040
		self:slideDepth(a, distance) -- 1041
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1042
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1042
			a.vy = CHILD_JUMP -- 1044
			a.onGround = false -- 1045
		end -- 1045
	end -- 1045
	local dir = self.escort:moveDir(a.x) -- 1048
	a.vx = dir * CHILD_SPEED -- 1049
	if dir ~= 0 then -- 1049
		a.facing = dir -- 1051
		local before = a.x -- 1052
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1053
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1053
			a.vy = CHILD_JUMP -- 1056
			a.onGround = false -- 1057
		end -- 1057
	end -- 1057
	self:fallY(a, dt) -- 1060
end -- 1011
function Play.prototype.escortOn(self) -- 1064
	if self.room.key == "checkpoint" then -- 1064
		return true -- 1066
	end -- 1066
	if self.room.key == "prologue" then -- 1066
		return self.phase == "prologue-follow" -- 1069
	end -- 1069
	return self.room.key == "street" -- 1071
end -- 1064
function Play.prototype.storyLocked(self) -- 1075
	if self.caughtT > 0 then -- 1075
		return true -- 1077
	end -- 1077
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1077
		return true -- 1080
	end -- 1080
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1080
		return true -- 1083
	end -- 1083
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1083
		return true -- 1086
	end -- 1086
	return false -- 1088
end -- 1075
function Play.prototype.swapToChild(self, x) -- 1092
	local tmp = self.player -- 1093
	self.player = self.partner -- 1094
	self.partner = tmp -- 1095
	self.childMode = true -- 1096
	self.player.alive = true -- 1097
	self.player.x = self.ox + x -- 1098
	self.player.y = 0 -- 1099
	self.player.depth = 0 -- 1100
	self.player.depthSpeed = 0 -- 1101
	self.player.vy = 0 -- 1102
	self.player.vx = 0 -- 1103
	self.player.onGround = true -- 1104
	self.player.crouch = false -- 1105
	self.player.h = CHILD_H -- 1106
	self.player.facing = 1 -- 1107
	self.partner.alive = true -- 1108
	self.cam.x = self.player.x -- 1109
end -- 1092
function Play.prototype.stepStory(self, dt, input) -- 1113
	if self.room.key == "prologue" then -- 1113
		self:stepPrologue(dt, input) -- 1115
	elseif self.room.key == "street" then -- 1115
		self:stepStreet(dt, input) -- 1117
	elseif self.room.key == "gate" then -- 1117
		self:stepGate(dt, input) -- 1119
	elseif self.room.key == "tower" then -- 1119
		self:stepTower(dt, input) -- 1121
	end -- 1121
end -- 1113
function Play.prototype.stepPrologue(self, dt, input) -- 1126
	local child = self.partner -- 1127
	if self.phase == "prologue-wait" then -- 1127
		child.crouch = true -- 1129
		child.h = CHILD_CROUCH_H -- 1130
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1131
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1133
		if near and input.interact.pressed then -- 1133
			self.phase = "prologue-give" -- 1135
			self.phaseTick = 0 -- 1136
			self:flashSet("递出针套", 1) -- 1137
		end -- 1137
		return -- 1139
	end -- 1139
	if self.phase == "prologue-give" then -- 1139
		self.phaseTick = self.phaseTick + 1 -- 1142
		if self.phaseTick == 12 then -- 1142
			self:flashSet("针套递过去", 0.7) -- 1144
		elseif self.phaseTick == 36 then -- 1144
			self:flashSet("纸条塞进针套", 0.9) -- 1146
		elseif self.phaseTick >= 60 then -- 1146
			self.phase = "prologue-follow" -- 1148
			self.phaseTick = 0 -- 1149
			child.crouch = false -- 1150
			child.h = CHILD_H -- 1151
			self:flashSet("她跟上了", 1.2) -- 1152
		end -- 1152
		return -- 1154
	end -- 1154
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1154
		self:requestRoom("street", "序章跟到门口") -- 1158
		self:flashSet("进街道", 1.2) -- 1159
	end -- 1159
end -- 1126
function Play.prototype.stepStreet(self, dt, input) -- 1164
	local p = self.player -- 1165
	local c = self.partner -- 1166
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1166
		self:requestRoom("checkpoint", "两人都到街尾") -- 1168
		self:flashSet("到检查站", 1.2) -- 1169
	end -- 1169
end -- 1164
function Play.prototype.stepGate(self, dt, input) -- 1174
	local ____temp_27 -- 1175
	if self.room.story == nil then -- 1175
		____temp_27 = nil -- 1175
	else -- 1175
		____temp_27 = self.room.story.gate -- 1175
	end -- 1175
	local g = ____temp_27 -- 1175
	if g == nil then -- 1175
		return -- 1177
	end -- 1177
	local p = self.player -- 1179
	if self.phase == "gate-idle" then -- 1179
		local a = self.partner -- 1182
		local gap = g.waitX - a.x -- 1183
		if math.abs(gap) > 3 then -- 1183
			a.facing = gap > 0 and 1 or -1 -- 1185
			a.vx = a.facing * CHILD_SPEED -- 1186
			local beforeX = a.x -- 1187
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1188
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1188
				a.vy = CHILD_JUMP -- 1190
				a.onGround = false -- 1191
			end -- 1191
			self:fallY(a, dt) -- 1193
		else -- 1193
			a.vx = 0 -- 1195
			a.x = g.waitX -- 1196
		end -- 1196
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1199
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1200
		if self.gateNeedConfirm then -- 1200
			if not input.interact.held then -- 1200
				self.gateRestartArmed = true -- 1205
			end -- 1205
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1205
				self.gateNeedConfirm = false -- 1208
				self.gateRestartArmed = true -- 1209
				self.phase = "gate-hold" -- 1210
				self.gateTick = 0 -- 1211
				self.gateSpawned = 0 -- 1212
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1213
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1214
			end -- 1214
			return -- 1216
		end -- 1216
		if atWinch and atWait then -- 1216
			self.phase = "gate-hold" -- 1219
			self.gateTick = 0 -- 1220
			self.gateSpawned = 0 -- 1221
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1222
		end -- 1222
		return -- 1224
	end -- 1224
	if self.phase == "gate-hold" then -- 1224
		self.gateTick = self.gateTick + 1 -- 1227
		local marks = {0, 540, 900, 1500} -- 1229
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1229
			local idx = self.gateSpawned -- 1231
			local ____self_enemies_28 = self.enemies -- 1231
			____self_enemies_28[#____self_enemies_28 + 1] = { -- 1232
				x = self.ox + 620 + idx * 62, -- 1233
				y = 0, -- 1233
				w = 26, -- 1233
				h = 84, -- 1233
				alive = true, -- 1234
				hitT = 0, -- 1234
				warnT = 0, -- 1234
				fireCd = 90 + idx * 45 -- 1234
			} -- 1234
			self.gateSpawned = self.gateSpawned + 1 -- 1236
			self:flashSet( -- 1237
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1237
				0.9 -- 1237
			) -- 1237
		end -- 1237
		if self.gateTick == 900 then -- 1237
			self:flashSet("灯灭了", 1) -- 1240
		elseif self.gateTick == 2100 then -- 1240
			self:flashSet("门底压下来了", 1) -- 1242
		end -- 1242
		if self.gateTick >= g.holdTicks then -- 1242
			self.phase = "gate-send" -- 1245
			self.phaseTick = 0 -- 1246
			self.enemies = {} -- 1248
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1249
		end -- 1249
		return -- 1251
	end -- 1251
	if self.phase == "gate-send" then -- 1251
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1254
		if near and input.interact.pressed then -- 1254
			self:swapToChild(g.doorX + 30) -- 1256
			self.phase = "gate-count" -- 1257
			self.countTick = 0 -- 1258
			self.countArmed = false -- 1260
			self.countPrevMove = input.moveX -- 1261
			self:flashSet("门开了 · 送她出去", 1.8) -- 1262
		end -- 1262
		return -- 1264
	end -- 1264
	if self.phase == "gate-count" then -- 1264
		self.countTick = self.countTick + 1 -- 1267
		if self.countTick == 360 then -- 1267
			self:flashSet("门关上", 0.9) -- 1269
		elseif self.countTick == 1020 then -- 1269
			self:flashSet("数到一百", 2.2) -- 1271
		end -- 1271
		local prevMove = self.countPrevMove -- 1275
		self.countPrevMove = input.moveX -- 1276
		if self.countTick >= 1440 then -- 1276
			if prevMove <= 0 and input.moveX > 0 then -- 1276
				self.countArmed = true -- 1279
			end -- 1279
			if self.countArmed and input.moveX > 0 then -- 1279
				self.phase = "gate-walk" -- 1282
				self.phaseTick = 0 -- 1283
				self:flashSet("她迈出第一步", 1.4) -- 1284
			end -- 1284
		end -- 1284
		return -- 1287
	end -- 1287
	if self.player.x >= g.exitX then -- 1287
		self:requestRoom("outside", "走出城门") -- 1291
		self:flashSet("出城门 · 城外", 1.4) -- 1292
	end -- 1292
end -- 1174
function Play.prototype.stepTower(self, dt, input) -- 1297
	local ____temp_29 -- 1298
	if self.room.story == nil then -- 1298
		____temp_29 = nil -- 1298
	else -- 1298
		____temp_29 = self.room.story.tower -- 1298
	end -- 1298
	local t = ____temp_29 -- 1298
	if t == nil then -- 1298
		return -- 1300
	end -- 1300
	if self.phase == "tower-wait" then -- 1300
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1303
		if near and input.interact.pressed then -- 1303
			self.phase = "tower-knock" -- 1305
			self.phaseTick = 0 -- 1306
			self.knocks = 1 -- 1307
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1308
			self:flashSet("敲一下", 0.6) -- 1309
		end -- 1309
		return -- 1311
	end -- 1311
	if self.phase == "tower-knock" then -- 1311
		self.phaseTick = self.phaseTick + 1 -- 1314
		if self.phaseTick == 12 then -- 1314
			self.knocks = 2 -- 1316
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1317
			self:flashSet("敲两下 · 第二声", 1) -- 1318
		elseif self.phaseTick >= t.knockTicks then -- 1318
			self.phase = "tower-given" -- 1320
			self.phaseTick = 0 -- 1321
			self:flashSet("门开了 · 提灯", 1.4) -- 1322
		end -- 1322
		return -- 1324
	end -- 1324
	if self.phase == "tower-given" then -- 1324
		self.phaseTick = self.phaseTick + 1 -- 1327
		if self.phaseTick == 60 then -- 1327
			self:flashSet("她递出针套和纸条", 1.6) -- 1329
		elseif self.phaseTick == 120 then -- 1329
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1331
		elseif self.phaseTick >= 180 then -- 1331
			self.phase = "tower-end" -- 1333
			self.phaseTick = 0 -- 1334
			self:flashSet("片尾 · E 再玩一次", 3) -- 1335
		end -- 1335
		return -- 1337
	end -- 1337
	if input.interact.pressed or input.retry.pressed then -- 1337
		self:requestRoom("prologue", "片尾再玩") -- 1340
		self:flashSet("回到序章", 1.4) -- 1341
	end -- 1341
end -- 1297
function Play.prototype.stepChase(self, dt, input) -- 1346
	if self.caughtT > 0 then -- 1346
		self.caughtT = self.caughtT - dt -- 1348
		if self.caughtT <= 0 then -- 1348
			self:recoverFromCaught() -- 1350
		end -- 1350
		return -- 1352
	end -- 1352
	if self.room.key == "village" then -- 1352
		self:stepScavChase() -- 1355
	elseif self.room.key == "forest" then -- 1355
		self:stepDog(dt) -- 1357
		if self.player.x >= self.ox + 1450 then -- 1357
			self:requestRoom("tower", "到林缘北塔") -- 1360
			self:flashSet("林缘 · 北塔", 1.4) -- 1361
		end -- 1361
	end -- 1361
end -- 1346
function Play.prototype.stepScavChase(self) -- 1367
	local s = self.room.scavenger -- 1368
	if s == nil then -- 1368
		return -- 1370
	end -- 1370
	local p = self.player -- 1372
	if self.passed and p.x > self.ox + 440 then -- 1372
		if self.scavChase then -- 1372
			self.scavChase = false -- 1376
			self.scavState = "back" -- 1377
			self.scavT = 0 -- 1378
		end -- 1378
		return -- 1380
	end -- 1380
	local dx = p.x - self.scavX -- 1382
	local dist = math.abs(dx) -- 1383
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1384
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1385
	if not self.scavChase then -- 1385
		if visible then -- 1385
			self.scavSee = self.scavSee + 1 -- 1388
			if self.scavSee >= 24 then -- 1388
				self.scavChase = true -- 1390
				self.scavState = "chase" -- 1391
				self.scavTargetX = p.x -- 1392
				self:flashSet("他看见你了", 1.2) -- 1393
			end -- 1393
		else -- 1393
			self.scavSee = 0 -- 1396
		end -- 1396
		return -- 1398
	end -- 1398
	local dir = p.x > self.scavX and 1 or -1 -- 1401
	self.scavX = self.scavX + dir * 96 / 60 -- 1402
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1402
		self:caught() -- 1404
		return -- 1405
	end -- 1405
	if hidden then -- 1405
		self.scavSee = 0 -- 1409
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1410
		self.scavT = self.scavT - 1 -- 1411
		if self.scavT <= 0 then -- 1411
			self.scavChase = false -- 1413
			self.scavState = "patrol" -- 1414
			self:flashSet("他失去了目标", 1) -- 1415
		end -- 1415
	end -- 1415
end -- 1367
function Play.prototype.stepDog(self, dt) -- 1421
	local ____temp_30 -- 1422
	if self.room.story == nil then -- 1422
		____temp_30 = nil -- 1422
	else -- 1422
		____temp_30 = self.room.story.dog -- 1422
	end -- 1422
	local dog = ____temp_30 -- 1422
	if dog == nil then -- 1422
		return -- 1424
	end -- 1424
	local p = self.player -- 1426
	local dist = math.abs(p.x - self.dogX) -- 1427
	if self.dogState == "patrol" then -- 1427
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1429
		if self.dogX < dog.x0 then -- 1429
			self.dogX = dog.x0 -- 1431
			self.dogDir = 1 -- 1432
		elseif self.dogX > dog.x1 then -- 1432
			self.dogX = dog.x1 -- 1434
			self.dogDir = -1 -- 1435
		end -- 1435
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1437
		if not p.crouch and moving and dist < dog.range then -- 1437
			self.dogState = "ear" -- 1439
			self.dogT = 18 -- 1440
			self.dogTargetX = p.x -- 1441
			self:flashSet("狗转耳朵", 0.8) -- 1442
		end -- 1442
		return -- 1444
	end -- 1444
	if self.dogState == "ear" then -- 1444
		self.dogT = self.dogT - 1 -- 1447
		if self.dogT <= 0 then -- 1447
			self.dogState = "chase" -- 1449
			self.dogTargetX = p.x -- 1450
			self:flashSet("狗追来了", 1.4) -- 1451
		end -- 1451
		return -- 1453
	end -- 1453
	if self.dogState == "chase" then -- 1453
		local dir = p.x > self.dogX and 1 or -1 -- 1456
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1457
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1457
			self:caught() -- 1459
			self.dogState = "sniff" -- 1460
			self.dogT = 60 -- 1461
		elseif dist > dog.range * 1.5 or p.crouch then -- 1461
			self.dogState = "sniff" -- 1463
			self.dogT = 60 -- 1464
			self:flashSet("狗停下了", 0.9) -- 1465
		end -- 1465
		return -- 1467
	end -- 1467
	if self.dogState == "sniff" then -- 1467
		self.dogT = self.dogT - 1 -- 1470
		if self.dogT <= 0 then -- 1470
			self.dogState = "back" -- 1472
		end -- 1472
		return -- 1474
	end -- 1474
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1477
	self.dogX = self.dogX + dir * dog.speed * dt -- 1478
	if math.abs(self.dogX - dog.x0) < 2 then -- 1478
		self.dogX = dog.x0 -- 1480
		self.dogState = "patrol" -- 1481
	end -- 1481
end -- 1421
function Play.prototype.caught(self) -- 1485
	self.caughtT = 1 -- 1486
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1487
end -- 1485
function Play.prototype.recoverFromCaught(self) -- 1491
	local p = self.player -- 1492
	p.x = self.ox + 140 -- 1493
	p.y = 0 -- 1494
	p.vy = 0 -- 1495
	p.vx = 0 -- 1496
	p.onGround = true -- 1497
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1497
		self.scavX = self.room.scavenger.x0 -- 1499
		self.scavState = "patrol" -- 1500
		self.scavSee = 0 -- 1501
		self.scavChase = false -- 1502
		self.scavT = 0 -- 1503
	end -- 1503
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1503
		self.dogX = self.room.story.dog.x0 -- 1506
		self.dogState = "patrol" -- 1507
		self.dogT = 0 -- 1508
	end -- 1508
	self.cam.x = p.x -- 1510
	self.cam.y = p.y + CAM_LOOK_UP -- 1511
	self:flashSet("回到安全点", 1.2) -- 1512
end -- 1491
function Play.prototype.updateGate(self) -- 1516
	if self.room.key ~= "checkpoint" then -- 1516
		self.gateOpen = false -- 1518
		return -- 1519
	end -- 1519
	local function inZone(x) -- 1521
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1521
	end -- 1521
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1522
end -- 1516
function Play.prototype.addItem(self, kind) -- 1528
	local inv = self.run.inventory -- 1529
	if kind == "shield" then -- 1529
		if inv.shield >= TOOL_CAP then -- 1529
			return false -- 1532
		end -- 1532
		inv.shield = inv.shield + 1 -- 1534
		return true -- 1535
	end -- 1535
	if kind == "wedge" then -- 1535
		if inv.wedge >= CONSUMABLE_CAP then -- 1535
			return false -- 1539
		end -- 1539
		inv.wedge = inv.wedge + 1 -- 1541
		return true -- 1542
	end -- 1542
	if kind == "ammo" then -- 1542
		if inv.ammo >= CONSUMABLE_CAP then -- 1542
			return false -- 1546
		end -- 1546
		inv.ammo = inv.ammo + 1 -- 1548
		return true -- 1549
	end -- 1549
	if kind == "scrap" then -- 1549
		inv.scrap = inv.scrap + 1 -- 1553
		return true -- 1554
	end -- 1554
	if kind == "pass" then -- 1554
		inv.pass = inv.pass + 1 -- 1557
		return true -- 1558
	end -- 1558
	if kind == "quickbelt" then -- 1558
		inv.quickbelt = inv.quickbelt + 1 -- 1561
		return true -- 1562
	end -- 1562
	return false -- 1564
end -- 1528
function Play.prototype.findBox(self, id) -- 1567
	local i = 0 -- 1568
	do -- 1568
		i = 0 -- 1569
		while i < #self.boxes do -- 1569
			if self.boxes[i + 1].id == id then -- 1569
				return self.boxes[i + 1] -- 1571
			end -- 1571
			i = i + 1 -- 1569
		end -- 1569
	end -- 1569
	return nil -- 1574
end -- 1567
function Play.prototype.findWedgeTarget(self) -- 1578
	local best = nil -- 1579
	local bestD = 0 -- 1580
	local i = 0 -- 1581
	do -- 1581
		i = 0 -- 1582
		while i < #self.boxes do -- 1582
			do -- 1582
				local b = self.boxes[i + 1] -- 1583
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 1583
					goto __continue240 -- 1585
				end -- 1585
				if not self:nearBox(b, 26) then -- 1585
					goto __continue240 -- 1588
				end -- 1588
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 1590
				if best == nil or d < bestD then -- 1590
					best = b -- 1592
					bestD = d -- 1593
				end -- 1593
			end -- 1593
			::__continue240:: -- 1593
			i = i + 1 -- 1582
		end -- 1582
	end -- 1582
	return best -- 1596
end -- 1578
function Play.prototype.stepCraft(self, input) -- 1604
	local inv = self.run.inventory -- 1605
	if self.craftT > 0 then -- 1605
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 1605
			self.craftT = 0 -- 1609
			self:flashSet("制作中断", 0.8) -- 1610
			return true -- 1611
		end -- 1611
		self.craftT = self.craftT + 1 -- 1613
		if self.craftT >= CRAFT_TICKS then -- 1613
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 1613
				inv.scrap = inv.scrap - 1 -- 1616
				inv.wedge = inv.wedge + 1 -- 1617
				self:flashSet("制得木楔", 1.2) -- 1618
				self:log("制木楔") -- 1619
				self:emit("craftDone", {item = "wedge", ticks = CRAFT_TICKS}) -- 1620
			end -- 1620
			self.craftT = 0 -- 1622
		end -- 1622
		return true -- 1624
	end -- 1624
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 1624
		self.craftT = 1 -- 1627
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 1628
		self:emit("craftStart", {item = "wedge", ticks = CRAFT_TICKS}) -- 1629
		return true -- 1630
	end -- 1630
	return false -- 1632
end -- 1604
function Play.prototype.nearBox(self, b, reach) -- 1635
	local p = self.player -- 1636
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1637
end -- 1635
function Play.prototype.findInteract(self) -- 1643
	local p = self.player -- 1644
	local best = nil -- 1645
	local bestD = 1000000000 -- 1646
	local i = 0 -- 1647
	do -- 1647
		i = 0 -- 1648
		while i < #self.boxes do -- 1648
			do -- 1648
				local b = self.boxes[i + 1] -- 1649
				if b.interact == nil or b.broken == true then -- 1649
					goto __continue253 -- 1651
				end -- 1651
				if not self:nearBox(b, b.interact.reach or 27) then -- 1651
					goto __continue253 -- 1654
				end -- 1654
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1656
				if d < bestD then -- 1656
					bestD = d -- 1658
					best = b -- 1659
				end -- 1659
			end -- 1659
			::__continue253:: -- 1659
			i = i + 1 -- 1648
		end -- 1648
	end -- 1648
	return best -- 1662
end -- 1643
function Play.prototype.stepCampaign(self, dt, input) -- 1666
	local wr = self.room -- 1667
	local p = self.player -- 1668
	if self.reloadT > 0 then -- 1668
		self.reloadT = self.reloadT - 1 -- 1670
	end -- 1670
	if self.bracedShield ~= nil then -- 1670
		self.bracedShield.x = p.x + p.facing * 26 -- 1674
		self.bracedShield.y = p.y -- 1675
		local shBox = __TS__ArrayFind( -- 1676
			self.boxes, -- 1676
			function(____, b) return b.id == "braced_shield" end -- 1676
		) -- 1676
		if shBox ~= nil then -- 1676
			shBox.x0 = self.bracedShield.x - 15 -- 1678
			shBox.x1 = self.bracedShield.x + 15 -- 1679
			shBox.y0 = self.bracedShield.y -- 1680
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1681
		end -- 1681
	end -- 1681
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1681
		self.run.route = "drygoods" -- 1687
		self.run.joined = false -- 1688
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1689
		self:log("转布行线") -- 1690
	end -- 1690
	local i = 0 -- 1693
	do -- 1693
		i = 0 -- 1694
		while i < #self.pickups do -- 1694
			do -- 1694
				local pk = self.pickups[i + 1] -- 1695
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1695
					goto __continue264 -- 1697
				end -- 1697
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1699
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1700
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1700
					if not self:addItem(pk.kind) then -- 1700
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 1704
						self:log("满包拒绝 " .. pk.kind) -- 1705
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 1706
						goto __continue264 -- 1707
					end -- 1707
					self.run.taken[pk.id] = true -- 1709
					pk.id = "" -- 1710
					self:flashSet("拾取 " .. pk.label, 1) -- 1711
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1712
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1713
				end -- 1713
			end -- 1713
			::__continue264:: -- 1713
			i = i + 1 -- 1694
		end -- 1694
	end -- 1694
	if not self:stepCraft(input) and input.interact.pressed then -- 1694
		self:campaignInteract() -- 1717
	end -- 1717
	self:stepCampaignCart(dt, input) -- 1719
	self:stepCampaignGoal() -- 1720
end -- 1666
function Play.prototype.campaignInteract(self) -- 1724
	local b = self:findInteract() -- 1725
	if b ~= nil then -- 1725
		self:useInteract(b) -- 1727
		return -- 1728
	end -- 1728
	local inv = self.run.inventory -- 1730
	if inv.wedge > 0 then -- 1730
		local w = self:findWedgeTarget() -- 1732
		if w ~= nil then -- 1732
			if w.breakable ~= nil then -- 1732
				local ____w_breakable_31, ____hp_32 = w.breakable, "hp" -- 1732
				____w_breakable_31[____hp_32] = ____w_breakable_31[____hp_32] + (w.breakable.wedgeHp or 1) -- 1735
			end -- 1735
			inv.wedge = inv.wedge - 1 -- 1737
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1738
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 1740
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 1741
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1742
			return -- 1743
		end -- 1743
	end -- 1743
	if inv.ammo > 0 and self.reloadT > 0 then -- 1743
		self.reloadT = 0 -- 1748
		inv.ammo = inv.ammo - 1 -- 1749
		self:flashSet("备用弹包 · 膛内补满", 1) -- 1750
		self:log("用备用弹包") -- 1751
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 1752
		return -- 1753
	end -- 1753
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1753
		local p = self.player -- 1757
		self.bracedShield = { -- 1758
			x = p.x + p.facing * 26, -- 1758
			y = p.y, -- 1758
			w = 30, -- 1758
			h = 64, -- 1758
			hp = 1 -- 1758
		} -- 1758
		local ____self_boxes_33 = self.boxes -- 1758
		____self_boxes_33[#____self_boxes_33 + 1] = { -- 1759
			x0 = self.bracedShield.x - 15, -- 1760
			x1 = self.bracedShield.x + 15, -- 1760
			y0 = p.y, -- 1761
			y1 = p.y + 64, -- 1761
			depth = {min = -46, max = 46}, -- 1761
			label = "架起的残盾", -- 1761
			id = "braced_shield", -- 1761
			soft = true -- 1762
		} -- 1762
		inv.shield = inv.shield - 1 -- 1765
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1766
		self:log("架残盾") -- 1767
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1768
		return -- 1769
	end -- 1769
	if inv.pass > 0 and self.run.joined == false then -- 1769
		inv.pass = inv.pass - 1 -- 1772
		self.run.joined = true -- 1773
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1774
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1775
		return -- 1776
	end -- 1776
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1778
end -- 1724
function Play.prototype.useInteract(self, b) -- 1781
	local kind = b.interact == nil and "" or b.interact.kind -- 1782
	local wr = self.room -- 1783
	if kind == "open_board" then -- 1783
		b.broken = true -- 1785
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1786
		for ____, cover in ipairs(self.boxes) do -- 1787
			if cover.id == "s2_board_cover" then -- 1787
				cover.broken = false -- 1789
				cover.hidden = false -- 1790
			end -- 1790
		end -- 1790
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1793
		self.run.joined = true -- 1794
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1795
		self:log("放下窗板") -- 1796
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1797
		return -- 1798
	end -- 1798
	if kind == "lower_curtain" then -- 1798
		for ____, curtain in ipairs(self.boxes) do -- 1801
			if curtain.id == "c2_curtain" then -- 1801
				curtain.broken = false -- 1803
				curtain.hidden = false -- 1804
			end -- 1804
		end -- 1804
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1807
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1808
		self:log("放下木帘") -- 1809
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1810
		return -- 1811
	end -- 1811
	if kind == "raise_latch" then -- 1811
		if wr.key == "c2-granary" and not self.cartDocked then -- 1811
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1815
			return -- 1816
		end -- 1816
		b.broken = true -- 1818
		self.objectiveDone = true -- 1819
		if wr.key == "c1-yard" then -- 1819
			self.run.c1Latch = true -- 1822
			self.run.joined = true -- 1823
		else -- 1823
			self.run.c2Latch = true -- 1825
			self.run.joined = true -- 1826
		end -- 1826
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1828
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1829
		self:log("抬闩") -- 1830
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1831
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1832
	end -- 1832
end -- 1781
function Play.prototype.stepCampaignCart(self, dt, input) -- 1837
	local wr = self.room -- 1838
	local c = wr.cart -- 1839
	if c.bodyW <= 0 then -- 1839
		return -- 1841
	end -- 1841
	local p = self.player -- 1843
	local handleX = self.cartAxle + c.handleOffset -- 1844
	if not self.gripping then -- 1844
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1844
			self.gripping = true -- 1848
			self:flashSet("握住车柄 · A/D 推", 1) -- 1849
		end -- 1849
		return -- 1851
	end -- 1851
	if input.interact.pressed then -- 1851
		self.gripping = false -- 1854
		self:flashSet("松手", 0.5) -- 1855
		return -- 1856
	end -- 1856
	if not self.cartDocked then -- 1856
		if input.moveX ~= 0 and not self:stuckCart() then -- 1856
			self.cartAxle = math.max( -- 1860
				c.startX, -- 1860
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1860
			) -- 1860
		end -- 1860
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1860
			self.cartExposed = true -- 1865
			local gun = nil -- 1866
			local gi = 0 -- 1867
			do -- 1867
				gi = 0 -- 1868
				while gi < #self.enemies do -- 1868
					local e = self.enemies[gi + 1] -- 1869
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1869
						gun = e -- 1871
						break -- 1872
					end -- 1872
					gi = gi + 1 -- 1868
				end -- 1868
			end -- 1868
			if gun ~= nil then -- 1868
				self:campaignEnemyFire(gun) -- 1876
			end -- 1876
		end -- 1876
		p.x = self.cartAxle + c.handleOffset -- 1879
		p.y = c.baseY + (c.depth or 0) -- 1880
		p.vx = 0 -- 1881
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1881
			self.cartAxle = c.endX -- 1883
			self.cartDocked = true -- 1884
			self.gripping = false -- 1885
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1886
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1887
			self:flashSet("车轮入窝", 1.2) -- 1888
			self:log("车轮入窝") -- 1889
		end -- 1889
	end -- 1889
end -- 1837
function Play.prototype.stuckCart(self) -- 1895
	local i = 0 -- 1896
	do -- 1896
		i = 0 -- 1897
		while i < #self.boxes do -- 1897
			do -- 1897
				local b = self.boxes[i + 1] -- 1898
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1898
					goto __continue305 -- 1900
				end -- 1900
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1902
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1902
					return true -- 1904
				end -- 1904
			end -- 1904
			::__continue305:: -- 1904
			i = i + 1 -- 1897
		end -- 1897
	end -- 1897
	return false -- 1907
end -- 1895
function Play.prototype.stepCampaignGoal(self) -- 1911
	local wr = self.room -- 1912
	local c = wr.campaign -- 1913
	if c == nil then -- 1913
		return -- 1915
	end -- 1915
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1915
		self.objectiveDone = true -- 1918
	end -- 1918
	if c.goal == "reach_exit" then -- 1918
		self.objectiveDone = true -- 1921
	end -- 1921
	if not self.objectiveDone then -- 1921
		return -- 1924
	end -- 1924
	local p = self.player -- 1926
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1927
	if p.x < c.exitX or not partnerOk then -- 1927
		return -- 1929
	end -- 1929
	if c.next ~= nil and c.next ~= "" then -- 1929
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1932
		self:flashSet("过关 · " .. c.next, 1.2) -- 1933
	elseif not self.run.finished then -- 1933
		self.run.finished = true -- 1935
		self:flashSet( -- 1936
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1936
			2 -- 1936
		) -- 1936
		self:log("C2 灰盒完成") -- 1937
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1938
	end -- 1938
end -- 1911
function Play.prototype.stepCampaignPartner(self, dt) -- 1943
	local a = self.partner -- 1944
	local wr = self.room -- 1945
	local cp = wr.companion -- 1946
	if not a.alive then -- 1946
		return -- 1948
	end -- 1948
	local p = self.player -- 1950
	local wait = false -- 1951
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1952
	local targetDepth = p.depth -- 1953
	if self.run.joined == false then -- 1953
		wait = true -- 1955
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1956
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1957
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1957
		wait = true -- 1959
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1960
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1961
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1961
		wait = true -- 1963
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1964
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1965
	end -- 1965
	if self.partnerStuck > 0.3 then -- 1965
		a.x = a.x + a.facing * 44 -- 1969
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1970
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1971
		self.partnerLaneHold = 1.1 -- 1972
		self.partnerStuck = 0 -- 1973
	end -- 1973
	if self.partnerLaneHold > 0 then -- 1973
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1976
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1977
	end -- 1977
	local dx = targetX - a.x -- 1979
	if not wait and math.abs(dx) > 74 then -- 1979
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1981
		local before = a.x -- 1982
		a.vx = dx > 0 and speed or -speed -- 1983
		a.facing = dx > 0 and 1 or -1 -- 1984
		self:slideX(a, a.vx * dt) -- 1985
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1985
			a.vy = CHILD_JUMP -- 1988
			a.onGround = false -- 1989
		end -- 1989
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1991
	else -- 1991
		a.vx = 0 -- 1993
		self.partnerStuck = 0 -- 1994
	end -- 1994
	local dz = targetDepth - a.depth -- 1996
	if math.abs(dz) > 6 then -- 1996
		local step = math.max( -- 1998
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1998
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1998
		) -- 1998
		a.depth = a.depth + step -- 1999
	end -- 1999
	a.depthSpeed = 0 -- 2001
	a.h = CHILD_H -- 2002
	a.crouch = false -- 2003
	self:fallY(a, dt) -- 2004
end -- 1943
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2008
	local p = self.player -- 2009
	local i = 0 -- 2010
	do -- 2010
		i = 0 -- 2011
		while i < #self.enemies do -- 2011
			do -- 2011
				local e = self.enemies[i + 1] -- 2012
				if not e.alive then -- 2012
					goto __continue329 -- 2014
				end -- 2014
				if e.hitT > 0 then -- 2014
					e.hitT = e.hitT - dt -- 2017
				end -- 2017
				if e.kind == "breaker" then -- 2017
					self:stepBreaker(e, dt) -- 2020
					goto __continue329 -- 2021
				end -- 2021
				if e.kind == "shield" then -- 2021
					self:stepShield(e, dt, input) -- 2024
					goto __continue329 -- 2025
				end -- 2025
				local dx = e.x - p.x -- 2028
				if not e.awake then -- 2028
					if math.abs(dx) > 520 then -- 2028
						goto __continue329 -- 2031
					end -- 2031
					e.awake = true -- 2033
					e.fireCd = 48 -- 2034
					goto __continue329 -- 2035
				end -- 2035
				if math.abs(dx) > ENEMY_RANGE then -- 2035
					goto __continue329 -- 2038
				end -- 2038
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2038
					goto __continue329 -- 2043
				end -- 2043
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2043
					goto __continue329 -- 2046
				end -- 2046
				if self:blockedShot(e, p) then -- 2046
					if e.warnT > 0 then -- 2046
						e.warnT = 0 -- 2052
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2053
					end -- 2053
					goto __continue329 -- 2055
				end -- 2055
				if e.warnT > 0 then -- 2055
					e.warnT = e.warnT - 1 -- 2058
					if e.warnT <= 0 then -- 2058
						self:campaignEnemyFire(e) -- 2060
					end -- 2060
				elseif e.fireCd > 0 then -- 2060
					e.fireCd = e.fireCd - 1 -- 2063
					if e.fireCd <= 0 then -- 2063
						e.warnT = WARN_TICKS -- 2065
					end -- 2065
				else -- 2065
					e.fireCd = 40 -- 2068
				end -- 2068
			end -- 2068
			::__continue329:: -- 2068
			i = i + 1 -- 2011
		end -- 2011
	end -- 2011
end -- 2008
function Play.prototype.blockedShot(self, e, p) -- 2074
	local eDepth = e.depth or 0 -- 2075
	local ex = e.x -- 2076
	local ey = e.y + e.h * 0.62 -- 2078
	local px = p.x -- 2079
	local py = p.y + p.h * 0.55 -- 2080
	local dx = px - ex -- 2081
	local dyScreen = py + p.depth - (ey + eDepth) -- 2082
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 2083
	if len < 0.01 then -- 2083
		return false -- 2085
	end -- 2085
	local ray = { -- 2089
		x = ex, -- 2090
		y = ey, -- 2090
		dx = dx / len, -- 2091
		dy = (py - ey) / len, -- 2091
		depth = eDepth, -- 2092
		dDepth = (p.depth - eDepth) / len -- 2092
	} -- 2092
	local best = -1 -- 2094
	local j = 0 -- 2095
	do -- 2095
		j = 0 -- 2096
		while j < #self.boxes do -- 2096
			do -- 2096
				local b = self.boxes[j + 1] -- 2097
				if b.broken == true or b.passable == true or b.hidden == true then -- 2097
					goto __continue349 -- 2099
				end -- 2099
				if b.id == "braced_shield" then -- 2099
					goto __continue349 -- 2104
				end -- 2104
				local t = hitBox(ray, b) -- 2106
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 2106
					best = t -- 2110
				end -- 2110
			end -- 2110
			::__continue349:: -- 2110
			j = j + 1 -- 2096
		end -- 2096
	end -- 2096
	return best >= 0 -- 2113
end -- 2074
function Play.prototype.campaignEnemyFire(self, e) -- 2116
	local p = self.player -- 2117
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2118
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2118
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 2118
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 2120
		self.boxes = __TS__ArrayFilter( -- 2121
			self.boxes, -- 2121
			function(____, b) return b.id ~= "braced_shield" end -- 2121
		) -- 2121
		self.bracedShield = nil -- 2122
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2123
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2124
		return -- 2125
	end -- 2125
	if self:blockedShot(e, p) then -- 2125
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2128
		return -- 2129
	end -- 2129
	local cover = self:blockedByCover(e, p) -- 2131
	if cover ~= nil and self.coverHug then -- 2131
		self.coveredFlash = 0.5 -- 2133
		self:flashSet("掩体挡下", 0.6) -- 2134
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2135
		return -- 2140
	end -- 2140
	if self.invulnT > 0 then -- 2140
		return -- 2143
	end -- 2143
	self.invulnT = INVULN_HIT_TICKS -- 2145
	self.craftT = 0 -- 2146
	self.hp = self.hp - 1 -- 2147
	self:emit("actorHit", { -- 2148
		target = "player", -- 2148
		amount = 1, -- 2148
		hp = self.hp, -- 2148
		maxHp = self.maxHp, -- 2148
		enemyX = e.x -- 2148
	}) -- 2148
	self:flashSet( -- 2149
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2149
		0.8 -- 2149
	) -- 2149
	if self.hp <= 0 then -- 2149
		self:campaignFailed() -- 2151
	end -- 2151
end -- 2116
function Play.prototype.stepShield(self, e, dt, input) -- 2156
	local p = self.player -- 2157
	local dx = p.x - e.x -- 2158
	local adx = math.abs(dx) -- 2159
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2162
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2163
	if adx > 150 then -- 2163
		local before = e.x -- 2165
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2166
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2166
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2169
		end -- 2169
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2169
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2174
		local rollDodges = p.rollT > 0 and fromFront -- 2175
		if not rollDodges and self.invulnT <= 0 then -- 2175
			self.invulnT = INVULN_HIT_TICKS -- 2177
			self.craftT = 0 -- 2178
			self.hp = self.hp - 1 -- 2179
			self:emit("actorHit", { -- 2180
				target = "player", -- 2180
				amount = 1, -- 2180
				hp = self.hp, -- 2180
				maxHp = self.maxHp, -- 2180
				enemyX = e.x -- 2180
			}) -- 2180
			self:flashSet( -- 2181
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2181
				0.8 -- 2181
			) -- 2181
			if self.hp <= 0 then -- 2181
				self:campaignFailed() -- 2183
				return -- 2184
			end -- 2184
		end -- 2184
		e.swingT = 70 -- 2187
	end -- 2187
	if (e.swingT or 0) > 0 then -- 2187
		e.swingT = (e.swingT or 0) - 1 -- 2190
	end -- 2190
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2190
		local dd = p.depth - (e.depth or 0) -- 2193
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2194
	end -- 2194
end -- 2156
function Play.prototype.stepBreaker(self, e, dt) -- 2199
	local p = self.player -- 2200
	if e.awake ~= true then -- 2200
		if math.abs(p.x - e.x) < 560 then -- 2200
			e.awake = true -- 2203
		else -- 2203
			return -- 2205
		end -- 2205
	end -- 2205
	local target = nil -- 2208
	local bestD = 1000000000 -- 2209
	local i = 0 -- 2210
	do -- 2210
		i = 0 -- 2211
		while i < #self.boxes do -- 2211
			do -- 2211
				local b = self.boxes[i + 1] -- 2212
				if b.breakable == nil or b.broken == true then -- 2212
					goto __continue373 -- 2214
				end -- 2214
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2216
				if d < bestD then -- 2216
					bestD = d -- 2218
					target = b -- 2219
				end -- 2219
			end -- 2219
			::__continue373:: -- 2219
			i = i + 1 -- 2211
		end -- 2211
	end -- 2211
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2222
	local dx = tx - e.x -- 2223
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2224
	if math.abs(dx) > reach then -- 2224
		local before = e.x -- 2226
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2227
		if math.abs(e.x - before) < 0.3 then -- 2227
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2229
		end -- 2229
	elseif (e.swingT or 0) <= 0 then -- 2229
		e.swingT = 64 -- 2232
		if target ~= nil then -- 2232
			self:damageProp(target, 2) -- 2234
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2234
			self.invulnT = INVULN_HIT_TICKS -- 2236
			self.craftT = 0 -- 2237
			self.hp = self.hp - 1 -- 2238
			self:emit("actorHit", { -- 2239
				target = "player", -- 2239
				amount = 1, -- 2239
				hp = self.hp, -- 2239
				maxHp = self.maxHp, -- 2239
				enemyX = e.x -- 2239
			}) -- 2239
			self:flashSet("破障手近身", 0.8) -- 2240
			if self.hp <= 0 then -- 2240
				self:campaignFailed() -- 2242
				return -- 2243
			end -- 2243
		end -- 2243
	end -- 2243
	if (e.swingT or 0) > 0 then -- 2243
		e.swingT = (e.swingT or 0) - 1 -- 2248
	end -- 2248
end -- 2199
function Play.prototype.campaignFailed(self) -- 2252
	local p = self.player -- 2253
	self.hp = self.maxHp -- 2254
	self.invulnT = INVULN_RESPAWN_TICKS -- 2255
	self.reloadT = 0 -- 2256
	self.gripping = false -- 2257
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2258
	self:log("被击倒") -- 2259
	p.x = self.room.minX + 90 -- 2260
	p.y = 0 -- 2261
	p.depth = 0 -- 2262
	p.vx = 0 -- 2263
	p.vy = 0 -- 2264
	p.onGround = true -- 2265
	p.rollT = 0 -- 2266
	self.partner.x = p.x - 50 -- 2267
	self.partner.y = 0 -- 2268
	self.partner.depth = 0 -- 2269
	self.cam.x = p.x -- 2270
	local i = 0 -- 2271
	do -- 2271
		i = 0 -- 2272
		while i < #self.enemies do -- 2272
			do -- 2272
				local e = self.enemies[i + 1] -- 2273
				if not e.alive then -- 2273
					goto __continue385 -- 2275
				end -- 2275
				e.x = e.homeX == nil and e.x or e.homeX -- 2277
				e.warnT = 0 -- 2278
				e.fireCd = 40 -- 2279
				e.swingT = 0 -- 2280
				e.awake = false -- 2281
			end -- 2281
			::__continue385:: -- 2281
			i = i + 1 -- 2272
		end -- 2272
	end -- 2272
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2283
end -- 2252
function Play.prototype.stepEnemies(self, dt, input) -- 2286
	local i = 0 -- 2287
	do -- 2287
		i = 0 -- 2288
		while i < #self.enemies do -- 2288
			local e = self.enemies[i + 1] -- 2289
			if e.hitT > 0 then -- 2289
				e.hitT = e.hitT - dt -- 2291
			end -- 2291
			i = i + 1 -- 2288
		end -- 2288
	end -- 2288
	if self.coveredFlash > 0 then -- 2288
		self.coveredFlash = self.coveredFlash - dt -- 2295
	end -- 2295
	if self.isCampaign then -- 2295
		self:stepCampaignEnemies(dt, input) -- 2298
		return -- 2299
	end -- 2299
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2299
		return -- 2303
	end -- 2303
	do -- 2303
		i = 0 -- 2305
		while i < #self.enemies do -- 2305
			do -- 2305
				local e = self.enemies[i + 1] -- 2306
				if not e.alive then -- 2306
					goto __continue395 -- 2308
				end -- 2308
				if e.warnT > 0 then -- 2308
					e.warnT = e.warnT - 1 -- 2311
					if e.warnT <= 0 then -- 2311
						self:enemyFire(e, input) -- 2313
					end -- 2313
					goto __continue395 -- 2315
				end -- 2315
				if e.fireCd > 0 then -- 2315
					e.fireCd = e.fireCd - 1 -- 2318
					if e.fireCd <= 0 then -- 2318
						e.warnT = WARN_TICKS -- 2320
					end -- 2320
				else -- 2320
					e.warnT = WARN_TICKS -- 2324
				end -- 2324
			end -- 2324
			::__continue395:: -- 2324
			i = i + 1 -- 2305
		end -- 2305
	end -- 2305
end -- 2286
function Play.prototype.enemyFire(self, e, input) -- 2330
	local p = self.player -- 2331
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2331
		self:flashSet("枪声响在远处", 0.4) -- 2333
		e.fireCd = FIRE_COOLDOWN -- 2334
		return -- 2335
	end -- 2335
	local cover = self:blockedByCover(e, p) -- 2338
	local hugging = cover ~= nil -- 2339
	self.coverBlocking = hugging -- 2340
	local covered = hugging and input.cover.held -- 2341
	if covered then -- 2341
		self.coveredFlash = 0.5 -- 2343
		self:flashSet("掩体挡下", 0.5) -- 2344
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2345
		e.fireCd = FIRE_COOLDOWN -- 2350
		return -- 2351
	end -- 2351
	self.hp = self.hp - 1 -- 2353
	self:emit("actorHit", { -- 2354
		target = "player", -- 2354
		amount = 1, -- 2354
		hp = self.hp, -- 2354
		maxHp = self.maxHp, -- 2354
		enemyX = e.x -- 2354
	}) -- 2354
	self:flashSet( -- 2355
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2355
		0.7 -- 2355
	) -- 2355
	e.fireCd = FIRE_COOLDOWN -- 2356
	if self.hp <= 0 then -- 2356
		self:gateFailed() -- 2358
	end -- 2358
end -- 2330
function Play.prototype.blockedByCover(self, enemy, p) -- 2363
	local b = self:coverAt(p) -- 2364
	if b == nil then -- 2364
		return nil -- 2366
	end -- 2366
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2368
end -- 2363
function Play.prototype.gateFailed(self) -- 2372
	local ____temp_36 -- 2373
	if self.room.story == nil then -- 2373
		____temp_36 = nil -- 2373
	else -- 2373
		____temp_36 = self.room.story.gate -- 2373
	end -- 2373
	local g = ____temp_36 -- 2373
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2374
	self.hp = self.maxHp -- 2375
	self.gateTick = 0 -- 2376
	self.gateSpawned = 0 -- 2377
	self.enemies = {} -- 2378
	self.gateFailCount = self.gateFailCount + 1 -- 2379
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2381
	self.player.y = 0 -- 2382
	self.player.vy = 0 -- 2383
	self.player.depth = 0 -- 2384
	self.player.depthSpeed = 0 -- 2385
	self.player.onGround = true -- 2386
	self.player.crouch = false -- 2387
	self.player.h = SOLDIER_H -- 2388
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2389
	self.partner.y = 0 -- 2390
	self.partner.vy = 0 -- 2391
	self.partner.depth = 0 -- 2392
	self.partner.depthSpeed = 0 -- 2393
	self.partner.onGround = true -- 2394
	self.cam.x = self.player.x -- 2395
	self.phase = "gate-idle" -- 2396
	self.phaseTick = 0 -- 2397
	self.coverHug = false -- 2398
	self.coverBlocking = false -- 2399
	self.coverEntity = "" -- 2400
	self.gateNeedConfirm = true -- 2401
	self.gateRestartArmed = false -- 2402
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2403
end -- 2372
function Play.prototype.stepInteract(self, dt, input) -- 2406
	local p = self.player -- 2407
	local calmUsed = self.calmConsumed -- 2408
	self.calmConsumed = false -- 2409
	local calming = self.escort.state == "calming" -- 2411
	self.focusCart = false -- 2412
	if self.room.key == "outside" then -- 2412
		local c = self.room.cart -- 2414
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2415
		local dy = p.y - c.baseY -- 2416
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2417
	end -- 2417
	if not calmUsed and not calming then -- 2417
		self:stepCart(dt, input) -- 2421
	end -- 2421
	if calmUsed then -- 2421
		self:flashSet("安抚 · 敲两下", 0.8) -- 2426
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2426
		if self.knockT > 0 then -- 2426
			self.knocks = self.knocks + 1 -- 2430
		else -- 2430
			self.knocks = 1 -- 2432
		end -- 2432
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2434
		self.knockT = 1.2 -- 2435
		if self.knocks >= 2 then -- 2435
			self:flashSet("敲两下", 0.8) -- 2437
			self.knocks = 0 -- 2438
		else -- 2438
			self:flashSet("敲一下", 0.5) -- 2440
		end -- 2440
	elseif self.knockT > 0 then -- 2440
		self.knockT = self.knockT - dt -- 2443
		if self.knockT <= 0 then -- 2443
			self.knocks = 0 -- 2445
		end -- 2445
	end -- 2445
	local i = 0 -- 2450
	do -- 2450
		i = 0 -- 2451
		while i < #self.room.marks do -- 2451
			do -- 2451
				local m = self.room.marks[i + 1] -- 2452
				if m.kind ~= 0 then -- 2452
					goto __continue421 -- 2454
				end -- 2454
				local subjects = {self.partner, self.player} -- 2456
				local k = 0 -- 2457
				do -- 2457
					k = 0 -- 2458
					while k < #subjects do -- 2458
						do -- 2458
							local s = subjects[k + 1] -- 2459
							if not s.alive then -- 2459
								goto __continue424 -- 2461
							end -- 2461
							local dx = s.x - m.x -- 2463
							local dy = s.y - m.y -- 2464
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2464
								self.checkpoint = m.x -- 2466
								self.checkpointCartAxle = self.cartAxle -- 2467
								if self.cartDocked then -- 2467
									self:flashSet("检查点 · 车已落窝", 1) -- 2469
								else -- 2469
									self:flashSet("检查点 · 车还没到位", 1) -- 2471
								end -- 2471
							end -- 2471
						end -- 2471
						::__continue424:: -- 2471
						k = k + 1 -- 2458
					end -- 2458
				end -- 2458
			end -- 2458
			::__continue421:: -- 2458
			i = i + 1 -- 2451
		end -- 2451
	end -- 2451
	self:checkCarryGate() -- 2477
end -- 2406
function Play.prototype.stepVillage(self, dt, input) -- 2481
	if self.room.key ~= "village" then -- 2481
		return -- 2483
	end -- 2483
	local p = self.player -- 2485
	local bottle = self.room.bottle -- 2486
	local scav = self.room.scavenger -- 2487
	if not self.hasBottle and bottle ~= nil then -- 2487
		local dx = p.x - bottle.x -- 2491
		local dy = p.y + p.h * 0.5 - bottle.y -- 2492
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2492
			self.hasBottle = true -- 2494
			self:flashSet("拾起瓶子", 0.8) -- 2495
		end -- 2495
	end -- 2495
	if self.hasBottle then -- 2495
		if input.aim.held then -- 2495
			self.aimHold = self.aimHold + dt -- 2502
			if self.aimHold > 1.2 then -- 2502
				self.aimHold = 1.2 -- 2504
			end -- 2504
			local cached = self:bottleEnd() -- 2507
			self.bottleAimX = cached.x -- 2508
			self.bottleAimY = cached.y -- 2509
		elseif input.aim.released then -- 2509
			if self.aimHold < 0.12 then -- 2509
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2513
				self.aimHold = 0 -- 2514
			else -- 2514
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2516
				self:throwBottle(____end.x, ____end.y) -- 2517
				self.aimHold = 0 -- 2518
			end -- 2518
		end -- 2518
	else -- 2518
		self.aimHold = 0 -- 2522
		self.bottleAimX = -1 -- 2523
	end -- 2523
	local fly = self.bottleFly -- 2528
	if fly ~= nil then -- 2528
		fly.t = fly.t + dt -- 2530
		fly.x = fly.x0 + fly.vx * fly.t -- 2531
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2532
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2533
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2533
			self:landBottle(fly) -- 2535
		end -- 2535
	end -- 2535
	if self.bottleLandT > 0 then -- 2535
		self.bottleLandT = self.bottleLandT - dt -- 2539
	end -- 2539
	if scav ~= nil then -- 2539
		self:stepScav(dt, scav) -- 2543
	end -- 2543
	local line = self.room.passLine -- 2546
	if line ~= nil and not self.passed and p.x >= line then -- 2546
		self.passed = true -- 2548
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2549
	end -- 2549
	if self.passed and p.x >= self.ox + 640 then -- 2549
		self:requestRoom("forest", "过第一院出院") -- 2553
		self:flashSet("出院 · 北塔森林", 1.4) -- 2554
	end -- 2554
end -- 2481
function Play.prototype.bottleEnd(self) -- 2559
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2560
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2563
	return {x = aim.x, y = g} -- 2564
end -- 2559
function Play.prototype.throwBottle(self, tx, ty) -- 2568
	local p = self.player -- 2569
	local dir = tx >= p.x and 1 or -1 -- 2571
	p.facing = dir -- 2572
	local x0 = p.x + dir * 10 -- 2573
	local y0 = p.y + p.h * 0.7 -- 2574
	self.bottleTargetX = tx -- 2575
	self.bottleTargetY = ty -- 2576
	self.bottleSurfaceY = ty -- 2577
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2578
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2579
	self.bottleFly = { -- 2580
		x = x0, -- 2580
		y = y0, -- 2580
		x0 = x0, -- 2580
		y0 = y0, -- 2580
		vx = vx, -- 2580
		vy = vy, -- 2580
		t = 0 -- 2580
	} -- 2580
	self.hasBottle = false -- 2581
	self:flashSet("投出", 0.4) -- 2582
	self:emit( -- 2583
		"bottleThrown", -- 2583
		{ -- 2583
			fromX = x0, -- 2584
			fromY = y0, -- 2585
			targetX = tx, -- 2586
			targetY = ty, -- 2587
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2588
		} -- 2588
	) -- 2588
end -- 2568
function Play.prototype.landBottle(self, fly) -- 2593
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2594
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2595
	local s = self.room.scavenger -- 2596
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2597
	self.bottleFly = nil -- 2598
	self.bottleTargetX = -1 -- 2599
	self.bottleTargetY = 0 -- 2600
	self.bottleSurfaceY = -1 -- 2601
	self.bottleLandX = x -- 2602
	self.bottleLandY = y -- 2603
	self.bottleLandT = 0.9 -- 2604
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2605
	self:hearBottle(x) -- 2606
end -- 2593
function Play.prototype.hearBottle(self, x) -- 2610
	local s = self.room.scavenger -- 2611
	if s == nil then -- 2611
		return -- 2613
	end -- 2613
	if math.abs(x - self.scavX) > s.range then -- 2613
		self:flashSet("落地 · 他没听见", 0.6) -- 2616
		return -- 2617
	end -- 2617
	self.scavState = "turn" -- 2619
	self.scavT = s.hearTicks -- 2620
	self.scavTargetX = x -- 2621
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2622
end -- 2610
function Play.prototype.stepScav(self, dt, s) -- 2626
	if self.scavState == "chase" then -- 2626
		return -- 2629
	end -- 2629
	if self.scavState == "turn" then -- 2629
		self.scavT = self.scavT - 1 -- 2632
		if self.scavT <= 0 then -- 2632
			self.scavState = "walk" -- 2634
		end -- 2634
		return -- 2636
	end -- 2636
	if self.scavState == "walk" then -- 2636
		local d = self.scavTargetX - self.scavX -- 2639
		if math.abs(d) < 4 then -- 2639
			self.scavState = "stall" -- 2641
			self.scavT = s.stallTicks -- 2642
			return -- 2643
		end -- 2643
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2645
		return -- 2646
	end -- 2646
	if self.scavState == "stall" then -- 2646
		self.scavT = self.scavT - 1 -- 2649
		if self.scavT <= 0 then -- 2649
			self.scavState = "back" -- 2651
		end -- 2651
		return -- 2653
	end -- 2653
	if self.scavState == "back" then -- 2653
		local home = math.max( -- 2656
			s.x0, -- 2656
			math.min(s.x1, self.scavX) -- 2656
		) -- 2656
		if math.abs(home - self.scavX) < 2 then -- 2656
			self.scavState = "patrol" -- 2658
			return -- 2659
		end -- 2659
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2661
		return -- 2662
	end -- 2662
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2664
	if self.scavX >= s.x1 then -- 2664
		self.scavX = s.x1 -- 2666
		self.scavDir = -1 -- 2667
	elseif self.scavX <= s.x0 then -- 2667
		self.scavX = s.x0 -- 2669
		self.scavDir = 1 -- 2670
	end -- 2670
end -- 2626
function Play.prototype.stepCart(self, dt, input) -- 2678
	local p = self.player -- 2679
	local c = self.room.cart -- 2680
	if self.gripping then -- 2680
		if not input.interact.held then -- 2680
			self.gripping = false -- 2684
			self:flashSet("松开车把", 0.4) -- 2685
			return -- 2686
		end -- 2686
	else -- 2686
		if not input.interact.pressed then -- 2686
			return -- 2690
		end -- 2690
		if not self:cartHandleInReach(p) then -- 2690
			return -- 2693
		end -- 2693
		local track = c.depth or 0 -- 2695
		if self:limitDepth(p, track) ~= track then -- 2695
			return -- 2697
		end -- 2697
		p.depth = track -- 2699
		p.depthSpeed = 0 -- 2700
		self.gripping = true -- 2701
		self:flashSet("握住车把", 0.4) -- 2702
		return -- 2703
	end -- 2703
	if self.cartDocked then -- 2703
		return -- 2707
	end -- 2707
	local dir = input.moveX -- 2709
	if dir == 0 then -- 2709
		return -- 2711
	end -- 2711
	local lo = math.min(c.startX, c.endX) -- 2713
	local hi = math.max(c.startX, c.endX) -- 2714
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2715
	if next < lo then -- 2715
		next = lo -- 2717
	end -- 2717
	if next > hi then -- 2717
		next = hi -- 2720
	end -- 2720
	local delta = next - self.cartAxle -- 2722
	if delta == 0 then -- 2722
		return -- 2724
	end -- 2724
	self.cartAxle = next -- 2726
	p.x = p.x + delta -- 2727
	p.facing = dir > 0 and 1 or -1 -- 2728
	self:slideX(p, 0) -- 2729
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2729
		self.gripping = false -- 2731
		self:flashSet("跟不上了，脱手", 0.6) -- 2732
		return -- 2733
	end -- 2733
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2733
		self.cartDocked = true -- 2736
		self.gripping = false -- 2737
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2738
		self:flashSet("车轮落窝", 1.2) -- 2739
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2739
		self:flashSet("车轮回到起点", 0.5) -- 2741
	end -- 2741
end -- 2678
function Play.prototype.requestRoom(self, key, reason) -- 2749
	if self.wantRoom ~= "" then -- 2749
		return -- 2753
	end -- 2753
	self.wantRoom = key -- 2755
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2756
end -- 2749
function Play.prototype.checkCarryGate(self) -- 2763
	if self.room.key == "checkpoint" then -- 2763
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2763
			self.carryCartAxle = self.cartAxle -- 2766
			self.carryCartDocked = self.cartDocked -- 2767
			self:requestRoom("gate", "检查站出口") -- 2768
			self:flashSet("出检查站 · 城门", 1.2) -- 2769
		end -- 2769
		return -- 2771
	end -- 2771
	if self.room.key == "outside" then -- 2771
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2771
			self.carryCartAxle = self.cartAxle -- 2777
			self.carryCartDocked = self.cartDocked -- 2778
			self:requestRoom("village", "墙根走完") -- 2779
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2780
		end -- 2780
	end -- 2780
end -- 2763
function Play.prototype.aimAt(self, wx, wy) -- 2787
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2788
	self.aimX = s.x -- 2789
	self.aimY = s.y -- 2790
end -- 2787
function Play.prototype.shoot(self, a) -- 2793
	if self.isCampaign and self.reloadT > 0 then -- 2793
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2795
		return -- 2796
	end -- 2796
	local ox = a.x + a.facing * 8 -- 2798
	local muzzleY = a.y + a.h * 0.72 -- 2799
	local oy = muzzleY + a.depth -- 2800
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2802
	local dx = aim.x - ox -- 2805
	local dy = aim.y - oy -- 2806
	local len = math.sqrt(dx * dx + dy * dy) -- 2807
	if len < 0.001 then -- 2807
		dx = a.facing -- 2809
		dy = 0 -- 2810
	else -- 2810
		dx = dx / len -- 2812
		dy = dy / len -- 2813
	end -- 2813
	if dx ~= 0 then -- 2813
		a.facing = dx > 0 and 1 or -1 -- 2816
	end -- 2816
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2819
	local hitEnemy = self:raycastEnemies(ray) -- 2820
	local tEnemy = hitEnemy.t -- 2821
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2822
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2823
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2824
	local tWall = solid.t -- 2825
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2826
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2827
	self.trace = { -- 2829
		x0 = ox, -- 2829
		y0 = oy, -- 2829
		x1 = ox + dx * t, -- 2829
		y1 = oy + dy * t, -- 2829
		hit = hit -- 2829
	} -- 2829
	self.traceT = 0.12 -- 2830
	self:applyFireDanger(ox) -- 2831
	local killed = false -- 2832
	if hit then -- 2832
		local i = hitEnemy.index -- 2834
		local e = self.enemies[i + 1] -- 2835
		local impactY = oy + dy * tEnemy -- 2836
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2837
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2838
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2838
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2840
			e.hitT = 0.3 -- 2841
			self:flashSet( -- 2842
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2842
				0.8 -- 2842
			) -- 2842
			self:emit("shotResolved", { -- 2843
				hit = true, -- 2844
				enemyIndex = i, -- 2844
				enemyX = e.x, -- 2844
				aimX = aim.x, -- 2844
				aimY = aim.y, -- 2844
				impactX = ox + dx * t, -- 2845
				impactY = oy + dy * t, -- 2845
				shield = true -- 2845
			}) -- 2845
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2847
			return -- 2848
		end -- 2848
		e.alive = false -- 2850
		e.hitT = 0.4 -- 2851
		killed = true -- 2852
		self:flashSet("命中", 0.6) -- 2853
		self:dropFor(e) -- 2854
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2854
		self:damageProp(solid.box, 1) -- 2856
	else -- 2856
		self:flashSet("打空", 0.35) -- 2858
	end -- 2858
	if self.isCampaign then -- 2858
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2861
	end -- 2861
	self:emit("shotResolved", { -- 2863
		hit = hit, -- 2864
		enemyIndex = hit and hitEnemy.index or -1, -- 2865
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2866
		aimX = aim.x, -- 2867
		aimY = aim.y, -- 2868
		impactX = ox + dx * t, -- 2869
		impactY = oy + dy * t -- 2870
	}) -- 2870
end -- 2793
function Play.prototype.applyFireDanger(self, shotX) -- 2875
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2875
		return -- 2877
	end -- 2877
	local dangerX = shotX -- 2879
	local best = -1 -- 2880
	local bestD = 1000000000 -- 2881
	local i = 0 -- 2882
	do -- 2882
		i = 0 -- 2883
		while i < #self.enemies do -- 2883
			do -- 2883
				local e = self.enemies[i + 1] -- 2884
				if not e.alive then -- 2884
					goto __continue500 -- 2886
				end -- 2886
				local d = math.abs(e.x - self.partner.x) -- 2888
				if d < bestD then -- 2888
					bestD = d -- 2890
					best = i -- 2891
				end -- 2891
			end -- 2891
			::__continue500:: -- 2891
			i = i + 1 -- 2883
		end -- 2883
	end -- 2883
	if best >= 0 then -- 2883
		dangerX = self.enemies[best + 1].x -- 2895
	end -- 2895
	local exposed = self:childExposed(dangerX) -- 2897
	local before = self.escort.fear -- 2898
	local dangerId = self.nextDangerId -- 2899
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2900
	self.nextDangerId = self.nextDangerId + 1 -- 2901
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2902
	if after > before then -- 2902
		self:flashSet( -- 2904
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2904
			1 -- 2904
		) -- 2904
	elseif not exposed then -- 2904
		self:flashSet("枪声没够到她", 0.5) -- 2906
	end -- 2906
end -- 2875
function Play.prototype.childExposed(self, dangerX) -- 2911
	local c = self.partner -- 2912
	if not c.alive then -- 2912
		return false -- 2914
	end -- 2914
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2914
		self.boxes, -- 2917
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2917
	) then -- 2917
		return false -- 2918
	end -- 2918
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2918
		return false -- 2921
	end -- 2921
	local toDanger = dangerX - c.x -- 2923
	local toPlayer = self.player.x - c.x -- 2924
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2924
		return false -- 2927
	end -- 2927
	return true -- 2929
end -- 2911
function Play.prototype.raycastEnemies(self, ray) -- 2933
	local best = -1 -- 2934
	local bestI = -1 -- 2935
	do -- 2935
		local i = 0 -- 2936
		while i < #self.enemies do -- 2936
			do -- 2936
				local e = self.enemies[i + 1] -- 2937
				if not e.alive then -- 2937
					goto __continue514 -- 2939
				end -- 2939
				local y = e.y + (e.depth or 0) -- 2941
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2942
				if t >= 0 and (best < 0 or t < best) then -- 2942
					best = t -- 2944
					bestI = i -- 2945
				end -- 2945
			end -- 2945
			::__continue514:: -- 2945
			i = i + 1 -- 2936
		end -- 2936
	end -- 2936
	return {t = best, index = bestI} -- 2948
end -- 2933
function Play.prototype.raycastWorld(self, ray) -- 2951
	return self:raycastSolid(ray).t -- 2952
end -- 2951
function Play.prototype.raycastSolid(self, ray) -- 2956
	local best = -1 -- 2957
	local bestBox = nil -- 2958
	for ____, box in ipairs(self.boxes) do -- 2959
		do -- 2959
			if box.broken == true or box.hidden == true then -- 2959
				goto __continue519 -- 2961
			end -- 2961
			local t = hitBox(ray, box) -- 2966
			if t > 2 and (best < 0 or t < best) then -- 2966
				best = t -- 2969
				bestBox = box -- 2970
			end -- 2970
		end -- 2970
		::__continue519:: -- 2970
	end -- 2970
	if ray.dy < 0 then -- 2970
		local t = -ray.y / ray.dy -- 2974
		if t >= 0 and (best < 0 or t < best) then -- 2974
			best = t -- 2976
			bestBox = nil -- 2977
		end -- 2977
	end -- 2977
	return {t = best, box = bestBox} -- 2980
end -- 2956
function Play.prototype.dropFor(self, e) -- 2984
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2984
		return -- 2986
	end -- 2986
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2986
		return -- 2989
	end -- 2989
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2991
	local ____self_pickups_37 = self.pickups -- 2991
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2992
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2993
		kind = e.drop, -- 2993
		x = e.x, -- 2993
		y = e.y, -- 2993
		depth = e.depth, -- 2994
		label = label .. " ×1" -- 2994
	} -- 2994
	self:log("掉落 " .. label) -- 2996
end -- 2984
function Play.prototype.damageProp(self, b, amount) -- 3000
	if b.breakable == nil or b.broken == true then -- 3000
		return -- 3002
	end -- 3002
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 3002
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 3004
	if b.breakable.hp > 0 then -- 3004
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3006
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3007
		return -- 3008
	end -- 3008
	b.broken = true -- 3010
	for ____, other in ipairs(self.boxes) do -- 3011
		if other.id ~= nil and other.id == b.id then -- 3011
			other.broken = true -- 3013
		end -- 3013
	end -- 3013
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3016
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3017
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3018
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3019
end -- 3000
function Play.prototype.slideDepth(self, a, distance) -- 3023
	a.depth = self:limitDepth(a, a.depth + distance) -- 3024
end -- 3023
function Play.prototype.limitDepth(self, a, target) -- 3027
	local road = self.room.depth -- 3028
	if road == nil or target == a.depth then -- 3028
		return a.depth -- 3030
	end -- 3030
	local next = math.max( -- 3032
		road.min, -- 3032
		math.min(road.max, target) -- 3032
	) -- 3032
	local half = a.w / 2 -- 3033
	for ____, b in ipairs(self.boxes) do -- 3034
		do -- 3034
			local footprint = b.depth -- 3035
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3035
				goto __continue537 -- 3040
			end -- 3040
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3042
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3043
			if a.depth <= front and next > front then -- 3043
				next = front -- 3045
			elseif a.depth >= back and next < back then -- 3045
				next = back -- 3047
			end -- 3047
		end -- 3047
		::__continue537:: -- 3047
	end -- 3047
	return next -- 3050
end -- 3027
function Play.prototype.slideX(self, a, dx) -- 3054
	local nx = a.x + dx -- 3055
	local half = a.w / 2 -- 3056
	local room = self.room -- 3057
	nx = math.max( -- 3058
		room.minX + half, -- 3058
		math.min(room.maxX - half, nx) -- 3058
	) -- 3058
	local i = 0 -- 3059
	do -- 3059
		i = 0 -- 3060
		while i < #self.boxes do -- 3060
			do -- 3060
				local b = self.boxes[i + 1] -- 3061
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3061
					goto __continue544 -- 3063
				end -- 3063
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3063
					goto __continue544 -- 3066
				end -- 3066
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3066
					goto __continue544 -- 3069
				end -- 3069
				if nx + half > b.x0 and nx - half < b.x1 then -- 3069
					if a.x <= b.x0 then -- 3069
						nx = b.x0 - half -- 3073
					elseif a.x >= b.x1 then -- 3073
						nx = b.x1 + half -- 3075
					else -- 3075
						nx = a.x -- 3077
					end -- 3077
				end -- 3077
			end -- 3077
			::__continue544:: -- 3077
			i = i + 1 -- 3060
		end -- 3060
	end -- 3060
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 3060
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 3085
		local bx0 = self.cartAxle - CART_HALF -- 3086
		local bx1 = self.cartAxle + CART_HALF -- 3087
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 3087
			if a.x <= bx0 then -- 3087
				nx = bx0 - half -- 3090
			elseif a.x >= bx1 then -- 3090
				nx = bx1 + half -- 3092
			else -- 3092
				nx = a.x -- 3094
			end -- 3094
		end -- 3094
	end -- 3094
	local arch = room.arch -- 3102
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 3102
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 3104
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 3104
			if a.x <= arch.x0 then -- 3104
				nx = arch.x0 - half -- 3107
			elseif a.x >= arch.x1 then -- 3107
				nx = arch.x1 + half -- 3109
			end -- 3109
		end -- 3109
	end -- 3109
	a.x = nx -- 3113
end -- 3054
function Play.prototype.fallY(self, a, dt) -- 3117
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3118
	if a.vy < -900 then -- 3118
		a.vy = -900 -- 3120
	end -- 3120
	local ny = a.y + a.vy * dt -- 3122
	local half = a.w / 2 -- 3123
	if a.vy <= 0 then -- 3123
		local reach = a.onGround and STEP_UP or 0 -- 3126
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3127
		if ny <= ground then -- 3127
			ny = ground -- 3129
			a.vy = 0 -- 3130
			a.onGround = true -- 3131
		else -- 3131
			a.onGround = false -- 3133
		end -- 3133
	else -- 3133
		a.onGround = false -- 3136
		local i = 0 -- 3137
		do -- 3137
			i = 0 -- 3138
			while i < #self.boxes do -- 3138
				do -- 3138
					local b = self.boxes[i + 1] -- 3139
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3139
						goto __continue568 -- 3141
					end -- 3141
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3141
						goto __continue568 -- 3144
					end -- 3144
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3144
						goto __continue568 -- 3147
					end -- 3147
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3147
						ny = b.y0 - a.h -- 3150
						a.vy = 0 -- 3151
					end -- 3151
				end -- 3151
				::__continue568:: -- 3151
				i = i + 1 -- 3138
			end -- 3138
		end -- 3138
	end -- 3138
	a.y = ny -- 3155
end -- 3117
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3159
	if depth == nil then -- 3159
		depth = 0 -- 3159
	end -- 3159
	local g = -9999 -- 3160
	local i = 0 -- 3161
	do -- 3161
		i = 0 -- 3162
		while i < #self.floors do -- 3162
			local f = self.floors[i + 1] -- 3163
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3163
				g = f.y1 -- 3165
			end -- 3165
			i = i + 1 -- 3162
		end -- 3162
	end -- 3162
	do -- 3162
		i = 0 -- 3168
		while i < #self.boxes do -- 3168
			do -- 3168
				local b = self.boxes[i + 1] -- 3169
				if b.broken == true or b.hidden == true or b.soft == true then -- 3169
					goto __continue578 -- 3171
				end -- 3171
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3171
					g = b.y1 -- 3175
				end -- 3175
			end -- 3175
			::__continue578:: -- 3175
			i = i + 1 -- 3168
		end -- 3168
	end -- 3168
	return g -- 3178
end -- 3159
function Play.prototype.updateCamera(self, dt) -- 3181
	local p = self.player -- 3182
	local tx = p.x + p.facing * 30 -- 3183
	local ty = p.y + CAM_LOOK_UP -- 3184
	local k = math.min(1, CAM_FOLLOW * dt) -- 3185
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3186
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3187
end -- 3181
function Play.prototype.clampCamera(self, w, h) -- 3191
	local room = self.room -- 3192
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3193
	local spanX = room.maxX - room.minX -- 3194
	if spanX <= halfW * 2 then -- 3194
		self.cam.x = (room.minX + room.maxX) / 2 -- 3196
	else -- 3196
		self.cam.x = math.max( -- 3198
			room.minX + halfW, -- 3198
			math.min(room.maxX - halfW, self.cam.x) -- 3198
		) -- 3198
	end -- 3198
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3201
	local spanY = room.height -- 3202
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3203
	if spanY <= halfH * 2 then -- 3203
		self.cam.y = camY -- 3205
	else -- 3205
		self.cam.y = math.max( -- 3207
			camY, -- 3207
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3207
		) -- 3207
	end -- 3207
end -- 3191
function Play.prototype.flashSet(self, text, t) -- 3211
	self.flash = text -- 3212
	self.flashT = t -- 3213
end -- 3211
function Play.prototype.statusText(self) -- 3217
	local p = self.player -- 3218
	local parts = {} -- 3219
	local who = self.childMode and "小满" or "周戍" -- 3220
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3221
	if self.room.key == "prologue" then -- 3221
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3224
		if self.phase == "prologue-wait" then -- 3224
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3226
		elseif self.phase == "prologue-give" then -- 3226
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3228
		else -- 3228
			parts[#parts + 1] = "跟随" -- 3230
		end -- 3230
		if self.paused then -- 3230
			parts[#parts + 1] = "已暂停" -- 3233
		end -- 3233
		return table.concat(parts, " · ") -- 3235
	end -- 3235
	if self.room.key == "street" then -- 3235
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3238
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3239
		if self.paused then -- 3239
			parts[#parts + 1] = "已暂停" -- 3241
		end -- 3241
		return table.concat(parts, " · ") -- 3243
	end -- 3243
	if self.room.key == "gate" then -- 3243
		local ____temp_40 -- 3246
		if self.room.story == nil then -- 3246
			____temp_40 = nil -- 3246
		else -- 3246
			____temp_40 = self.room.story.gate -- 3246
		end -- 3246
		local g = ____temp_40 -- 3246
		if g ~= nil then -- 3246
			parts[#parts + 1] = self:gateLabel() -- 3248
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3249
				0, -- 3250
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3250
			))) .. " 秒" -- 3250
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3251
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3252
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3253
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3254
			if self.gateFailCount > 0 then -- 3254
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3256
			end -- 3256
			if self.flash ~= "" then -- 3256
				parts[#parts + 1] = self.flash -- 3259
			end -- 3259
		end -- 3259
		if self.paused then -- 3259
			parts[#parts + 1] = "已暂停" -- 3263
		end -- 3263
		return table.concat(parts, " · ") -- 3265
	end -- 3265
	if self.room.key == "forest" then -- 3265
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3268
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3269
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3270
		if self.caughtT > 0 then -- 3270
			parts[#parts + 1] = "复位中" -- 3272
		end -- 3272
		if self.paused then -- 3272
			parts[#parts + 1] = "已暂停" -- 3275
		end -- 3275
		return table.concat(parts, " · ") -- 3277
	end -- 3277
	if self.room.key == "tower" then -- 3277
		if self.phase == "tower-wait" then -- 3277
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3281
		elseif self.phase == "tower-knock" then -- 3281
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3283
		elseif self.phase == "tower-given" then -- 3283
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3285
		else -- 3285
			parts[#parts + 1] = "片尾" -- 3287
		end -- 3287
		if self.paused then -- 3287
			parts[#parts + 1] = "已暂停" -- 3290
		end -- 3290
		return table.concat(parts, " · ") -- 3292
	end -- 3292
	if self.room.key == "village" then -- 3292
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3295
		if self.hasBottle then -- 3295
			parts[#parts + 1] = "有瓶" -- 3297
		elseif self.bottleFly ~= nil then -- 3297
			parts[#parts + 1] = "瓶在飞" -- 3299
		else -- 3299
			parts[#parts + 1] = "空手" -- 3301
		end -- 3301
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3303
		if self.scavChase then -- 3303
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3305
		end -- 3305
		if self.passed then -- 3305
			parts[#parts + 1] = "已过通行线" -- 3308
		end -- 3308
		if self.paused then -- 3308
			parts[#parts + 1] = "已暂停" -- 3311
		end -- 3311
		return table.concat(parts, " · ") -- 3313
	end -- 3313
	local isChild = self.childMode -- 3316
	if isChild then -- 3316
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3318
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3319
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3320
	else -- 3320
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3322
		if p.rollT > 0 then -- 3322
			parts[#parts + 1] = "翻滚中" -- 3324
		end -- 3324
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3326
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3327
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3328
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3329
	end -- 3329
	if self.checkpoint >= 0 then -- 3329
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3332
	end -- 3332
	if self.paused then -- 3332
		parts[#parts + 1] = "已暂停" -- 3335
	end -- 3335
	return table.concat(parts, " · ") -- 3337
end -- 3217
function Play.prototype.aliveEnemies(self) -- 3341
	local n = 0 -- 3342
	local i = 0 -- 3343
	do -- 3343
		i = 0 -- 3344
		while i < #self.enemies do -- 3344
			if self.enemies[i + 1].alive then -- 3344
				n = n + 1 -- 3346
			end -- 3346
			i = i + 1 -- 3344
		end -- 3344
	end -- 3344
	return n -- 3349
end -- 3341
function Play.prototype.threatened(self) -- 3354
	do -- 3354
		local i = 0 -- 3355
		while i < #self.enemies do -- 3355
			local e = self.enemies[i + 1] -- 3356
			if e.alive and e.warnT > 0 then -- 3356
				return true -- 3358
			end -- 3358
			i = i + 1 -- 3355
		end -- 3355
	end -- 3355
	return false -- 3361
end -- 3354
function Play.prototype.gateSecondsLeft(self) -- 3364
	local ____temp_41 -- 3365
	if self.room.story == nil then -- 3365
		____temp_41 = nil -- 3365
	else -- 3365
		____temp_41 = self.room.story.gate -- 3365
	end -- 3365
	local g = ____temp_41 -- 3365
	if g == nil then -- 3365
		return 0 -- 3367
	end -- 3367
	return math.max( -- 3369
		0, -- 3369
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3369
	) -- 3369
end -- 3364
function Play.prototype.gateLabel(self) -- 3372
	if self.phase == "gate-idle" then -- 3372
		return "待就位" -- 3374
	end -- 3374
	if self.phase == "gate-hold" then -- 3374
		return "守点中" -- 3377
	end -- 3377
	if self.phase == "gate-send" then -- 3377
		return "送别" -- 3380
	end -- 3380
	if self.phase == "gate-count" then -- 3380
		return "数数 " .. tostring(self.countTick) -- 3383
	end -- 3383
	return "她走" -- 3385
end -- 3372
function Play.prototype.dogLabel(self) -- 3389
	if self.dogState == "ear" then -- 3389
		return "转耳" -- 3391
	end -- 3391
	if self.dogState == "chase" then -- 3391
		return "追" -- 3394
	end -- 3394
	if self.dogState == "sniff" then -- 3394
		return "停" -- 3397
	end -- 3397
	if self.dogState == "back" then -- 3397
		return "回线" -- 3400
	end -- 3400
	return "巡逻" -- 3402
end -- 3389
function Play.prototype.doorXOf(self) -- 3405
	local ____temp_42 -- 3406
	if self.room.story == nil then -- 3406
		____temp_42 = nil -- 3406
	else -- 3406
		____temp_42 = self.room.story.tower -- 3406
	end -- 3406
	local t = ____temp_42 -- 3406
	return t == nil and 0 or t.doorX -- 3407
end -- 3405
function Play.prototype.scavLabel(self) -- 3411
	if self.scavState == "chase" then -- 3411
		return "追" -- 3413
	end -- 3413
	if self.scavState == "turn" then -- 3413
		return "转头" -- 3416
	end -- 3416
	if self.scavState == "walk" then -- 3416
		return "赶来" -- 3419
	end -- 3419
	if self.scavState == "stall" then -- 3419
		return "停住" -- 3422
	end -- 3422
	if self.scavState == "back" then -- 3422
		return "回位" -- 3425
	end -- 3425
	return "巡逻" -- 3427
end -- 3411
function Play.prototype.hintText(self) -- 3431
	if self.paused then -- 3431
		return "Esc 继续 · R 重置" -- 3433
	end -- 3433
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3433
		if self:threatened() then -- 3433
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3439
		end -- 3439
		if self.coverHug then -- 3439
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3442
		end -- 3442
		if self.coverNear then -- 3442
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3445
		end -- 3445
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3447
	end -- 3447
	if self.flash ~= "" then -- 3447
		return self.flash -- 3450
	end -- 3450
	if self.room.key == "prologue" then -- 3450
		if self.phase == "prologue-wait" then -- 3450
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3454
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3455
		end -- 3455
		if self.phase == "prologue-give" then -- 3455
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3458
		end -- 3458
		return "她跟着你了 · 两人一起走到门口 680" -- 3460
	end -- 3460
	if self.room.key == "street" then -- 3460
		if self:aliveEnemies() > 0 then -- 3460
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3464
		end -- 3464
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3466
	end -- 3466
	if self.room.key == "gate" then -- 3466
		local ____temp_43 -- 3469
		if self.room.story == nil then -- 3469
			____temp_43 = nil -- 3469
		else -- 3469
			____temp_43 = self.room.story.gate -- 3469
		end -- 3469
		local g = ____temp_43 -- 3469
		if g ~= nil then -- 3469
			if self.phase == "gate-idle" then -- 3469
				if self.gateNeedConfirm then -- 3469
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3473
				end -- 3473
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3475
			end -- 3475
			if self.phase == "gate-hold" then -- 3475
				if self.coveredFlash > 0 then -- 3475
					return "掩体挡下了这一枪 · 别露头" -- 3479
				end -- 3479
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3481
			end -- 3481
			if self.phase == "gate-send" then -- 3481
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3484
			end -- 3484
			if self.phase == "gate-count" then -- 3484
				if self.countTick >= 1440 then -- 3484
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3488
				end -- 3488
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3490
			end -- 3490
			return "她自己走 · 跟着出城门 1120" -- 3492
		end -- 3492
	end -- 3492
	if self.room.key == "forest" then -- 3492
		if self.dogState == "chase" then -- 3492
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3497
		end -- 3497
		if self.dogState == "ear" then -- 3497
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3500
		end -- 3500
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3502
	end -- 3502
	if self.room.key == "tower" then -- 3502
		if self.phase == "tower-wait" then -- 3502
			return "走到门前 445 点一次 E 敲两下" -- 3506
		end -- 3506
		if self.phase == "tower-knock" then -- 3506
			return "敲两下 · 等门开" -- 3509
		end -- 3509
		if self.phase == "tower-given" then -- 3509
			return "递交针套和纸条 · 看登记簿最后一行" -- 3512
		end -- 3512
		return "片尾 · 点 E 再玩一次，回到序章" -- 3514
	end -- 3514
	if self.room.key == "village" then -- 3514
		if self.bottleFly ~= nil then -- 3514
			return "等瓶子落地 · 触地才发声" -- 3518
		end -- 3518
		if self.hasBottle then -- 3518
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3521
		end -- 3521
		if self.passed then -- 3521
			return "已过第一院 · R 重置可再来一遍" -- 3524
		end -- 3524
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3526
	end -- 3526
	if self.room.key == "outside" then -- 3526
		if self.focusCart then -- 3526
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3530
		end -- 3530
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3532
	end -- 3532
	if self.escort.state == "frozen" then -- 3532
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3532
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3536
		end -- 3536
		return "小满吓住了 · 走过去，靠近再点 E" -- 3538
	end -- 3538
	if self.escort.state == "calming" then -- 3538
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3541
	end -- 3541
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3543
end -- 3431
function Play.prototype.draw(self, draw, w, h) -- 3548
	self.viewW = w -- 3549
	self.viewH = h -- 3550
	self.view = ____exports.computeViewport(w, h) -- 3551
	self:clampCamera(w, h) -- 3552
	draw:clear() -- 3553
	draw:drawRect( -- 3555
		Rect(0, 0, w, h), -- 3555
		BG_VOID -- 3555
	) -- 3555
	local box = self:canvasRect(w, h) -- 3556
	draw:drawRect(box, BG_FAR) -- 3557
	draw:drawRect( -- 3558
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3558
		BG_MID -- 3558
	) -- 3558
	self:drawFloors(draw, w, h) -- 3560
	self:drawSolids(draw, w, h) -- 3561
	self:drawZones(draw, w, h) -- 3562
	self:drawArch(draw, w, h) -- 3563
	self:drawCart(draw, w, h) -- 3564
	self:drawCampaignProps(draw, w, h) -- 3565
	self:drawActors(draw, w, h) -- 3566
	self:drawTrace(draw, w, h) -- 3567
	self:drawAim(draw, w, h) -- 3568
end -- 3548
function Play.prototype.canvasRect(self, w, h) -- 3572
	local v = self.view -- 3573
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3574
end -- 3572
function Play.prototype.px(self, n) -- 3578
	return n * self.view.zoom -- 3579
end -- 3578
function Play.prototype.sx(self, wx, w) -- 3583
	local v = self.view -- 3584
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3585
	return v.ox + lx * v.zoom -- 3586
end -- 3583
function Play.prototype.sy(self, wy, h) -- 3590
	local v = self.view -- 3591
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3592
	return v.oy + ly * v.zoom -- 3593
end -- 3590
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3596
	local px0 = self:sx(x0, w) -- 3597
	local px1 = self:sx(x1, w) -- 3598
	local py0 = self:sy(y0, h) -- 3599
	local py1 = self:sy(y1, h) -- 3600
	if px1 <= px0 or py1 <= py0 then -- 3600
		return -- 3602
	end -- 3602
	draw:drawRect( -- 3604
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3604
		color -- 3604
	) -- 3604
end -- 3596
function Play.prototype.drawFloors(self, draw, w, h) -- 3607
	local i = 0 -- 3608
	do -- 3608
		i = 0 -- 3609
		while i < #self.room.floors do -- 3609
			local f = self.room.floors[i + 1] -- 3610
			local ____temp_44 -- 3611
			if f.y == 0 then -- 3611
				____temp_44 = self.room.depth -- 3611
			else -- 3611
				____temp_44 = nil -- 3611
			end -- 3611
			local road = ____temp_44 -- 3611
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3612
			local x0 = self:sx(f.x0, w) -- 3613
			local x1 = self:sx(f.x1, w) -- 3614
			local deck = self:px(5) -- 3615
			if road ~= nil then -- 3615
				local back = self:sy(f.y + road.max, h) -- 3617
				draw:drawRect( -- 3618
					Rect(x0, y, x1 - x0, back - y), -- 3618
					FLOOR_DECK, -- 3618
					self:px(1), -- 3618
					SOLID_EDGE -- 3618
				) -- 3618
			end -- 3618
			draw:drawRect( -- 3620
				Rect(x0, y - deck, x1 - x0, deck), -- 3620
				FLOOR_DECK -- 3620
			) -- 3620
			draw:drawSegment( -- 3621
				Vec2(x0, y), -- 3621
				Vec2(x1, y), -- 3621
				self:px(1), -- 3621
				GROUND -- 3621
			) -- 3621
			i = i + 1 -- 3609
		end -- 3609
	end -- 3609
end -- 3607
function Play.prototype.drawSolids(self, draw, w, h) -- 3625
	local i = 0 -- 3626
	do -- 3626
		i = 0 -- 3627
		while i < #self.boxes do -- 3627
			do -- 3627
				local b = self.boxes[i + 1] -- 3628
				if b.id == "braced_shield" or b.hidden == true then -- 3628
					goto __continue699 -- 3630
				end -- 3630
				if b.broken == true then -- 3630
					if b.breakable ~= nil then -- 3630
						local gy = self:sy(b.y0, h) -- 3635
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3636
						local k = 0 -- 3637
						do -- 3637
							k = 0 -- 3638
							while k < 3 do -- 3638
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3639
								draw:drawSegment( -- 3640
									Vec2( -- 3640
										gx - self:px(4), -- 3640
										gy + self:px(k % 2) -- 3640
									), -- 3640
									Vec2( -- 3640
										gx + self:px(5), -- 3640
										gy + self:px(k % 2) -- 3640
									), -- 3640
									self:px(1), -- 3640
									rgb -- 3640
								) -- 3640
								k = k + 1 -- 3638
							end -- 3638
						end -- 3638
					end -- 3638
					goto __continue699 -- 3643
				end -- 3643
				local ____opt_47 = b.depth -- 3643
				local front = ____opt_47 and ____opt_47.min or 0 -- 3645
				local ____opt_49 = b.depth -- 3645
				local back = ____opt_49 and ____opt_49.max or 0 -- 3646
				local fill = SOLID_FILL -- 3647
				local line = SOLID_EDGE -- 3648
				if b.soft == true then -- 3648
					fill = SOFT -- 3650
					line = SOFT_LINE -- 3651
				elseif b.breakable ~= nil then -- 3651
					line = DANGER_LINE -- 3653
					fill = Color(0.3, 0.24, 0.16, 1) -- 3654
				elseif b.interact ~= nil then -- 3654
					line = PASS_LINE -- 3656
				end -- 3656
				self:drawBox( -- 3658
					draw, -- 3658
					w, -- 3658
					h, -- 3658
					b.x0, -- 3658
					b.x1, -- 3658
					b.y0 + front, -- 3658
					b.y1 + back, -- 3658
					fill -- 3658
				) -- 3658
				draw:drawSegment( -- 3659
					Vec2( -- 3659
						self:sx(b.x0, w), -- 3659
						self:sy(b.y1 + front, h) -- 3659
					), -- 3659
					Vec2( -- 3660
						self:sx(b.x1, w), -- 3660
						self:sy(b.y1 + front, h) -- 3660
					), -- 3660
					self:px(1), -- 3660
					line -- 3660
				) -- 3660
				if b.breakable ~= nil then -- 3660
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3663
					local cyp = self:sy(b.y1 + front, h) -- 3664
					draw:drawSegment( -- 3665
						Vec2( -- 3665
							cxp - self:px(4), -- 3665
							cyp + self:px(1) -- 3665
						), -- 3665
						Vec2( -- 3665
							cxp + self:px(3), -- 3665
							cyp + self:px(5) -- 3665
						), -- 3665
						self:px(1), -- 3665
						line -- 3665
					) -- 3665
				end -- 3665
			end -- 3665
			::__continue699:: -- 3665
			i = i + 1 -- 3627
		end -- 3627
	end -- 3627
end -- 3625
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3671
	local i = 0 -- 3672
	do -- 3672
		i = 0 -- 3673
		while i < #self.pickups do -- 3673
			do -- 3673
				local pk = self.pickups[i + 1] -- 3674
				if pk.id == "" then -- 3674
					goto __continue711 -- 3676
				end -- 3676
				local gy = pk.y + (pk.depth or 0) -- 3678
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3679
				draw:drawRect( -- 3680
					Rect( -- 3680
						self:sx(pk.x - 5, w), -- 3680
						self:sy(gy + 12 + bob, h), -- 3680
						self:px(10), -- 3680
						self:px(10) -- 3680
					), -- 3680
					Color(0.84, 0.7, 0.3, 1) -- 3681
				) -- 3681
				draw:drawSegment( -- 3682
					Vec2( -- 3682
						self:sx(pk.x - 5, w), -- 3682
						self:sy(gy + 12 + bob, h) -- 3682
					), -- 3682
					Vec2( -- 3683
						self:sx(pk.x + 5, w), -- 3683
						self:sy(gy + 12 + bob, h) -- 3683
					), -- 3683
					self:px(1), -- 3683
					Color(0.95, 0.86, 0.52, 1) -- 3683
				) -- 3683
			end -- 3683
			::__continue711:: -- 3683
			i = i + 1 -- 3673
		end -- 3673
	end -- 3673
	if self.bracedShield ~= nil then -- 3673
		local sh = self.bracedShield -- 3686
		draw:drawRect( -- 3687
			Rect( -- 3687
				self:sx(sh.x - sh.w / 2, w), -- 3687
				self:sy(sh.y, h), -- 3687
				self:px(sh.w), -- 3687
				self:px(sh.h) -- 3687
			), -- 3687
			Color(0.42, 0.4, 0.34, 1) -- 3688
		) -- 3688
		draw:drawSegment( -- 3689
			Vec2( -- 3689
				self:sx(sh.x - sh.w / 2, w), -- 3689
				self:sy(sh.y + sh.h, h) -- 3689
			), -- 3689
			Vec2( -- 3690
				self:sx(sh.x + sh.w / 2, w), -- 3690
				self:sy(sh.y + sh.h, h) -- 3690
			), -- 3690
			self:px(1), -- 3690
			Color(0.74, 0.72, 0.62, 1) -- 3690
		) -- 3690
	end -- 3690
end -- 3671
function Play.prototype.drawZones(self, draw, w, h) -- 3694
	local i = 0 -- 3695
	do -- 3695
		i = 0 -- 3696
		while i < #self.room.zones do -- 3696
			local z = self.room.zones[i + 1] -- 3697
			local fill = DANGER -- 3698
			local line = DANGER_LINE -- 3699
			if z.tint == 2 then -- 3699
				fill = SOFT -- 3701
				line = SOFT_LINE -- 3702
			elseif z.tint == 3 then -- 3702
				fill = BRICK -- 3704
				line = BRICK_LINE -- 3705
			elseif z.tint == 4 then -- 3705
				fill = PASS -- 3707
				line = PASS_LINE -- 3708
			end -- 3708
			self:drawBox( -- 3710
				draw, -- 3710
				w, -- 3710
				h, -- 3710
				z.x0, -- 3710
				z.x1, -- 3710
				z.y, -- 3710
				z.y + z.h, -- 3710
				fill -- 3710
			) -- 3710
			draw:drawSegment( -- 3711
				Vec2( -- 3711
					self:sx(z.x0, w), -- 3711
					self:sy(z.y, h) -- 3711
				), -- 3711
				Vec2( -- 3711
					self:sx(z.x0, w), -- 3711
					self:sy(z.y + z.h, h) -- 3711
				), -- 3711
				self:px(1), -- 3711
				line -- 3711
			) -- 3711
			draw:drawSegment( -- 3712
				Vec2( -- 3712
					self:sx(z.x1, w), -- 3712
					self:sy(z.y, h) -- 3712
				), -- 3712
				Vec2( -- 3712
					self:sx(z.x1, w), -- 3712
					self:sy(z.y + z.h, h) -- 3712
				), -- 3712
				self:px(1), -- 3712
				line -- 3712
			) -- 3712
			i = i + 1 -- 3696
		end -- 3696
	end -- 3696
end -- 3694
function Play.prototype.drawArch(self, draw, w, h) -- 3716
	local a = self.room.arch -- 3717
	if a.h <= 0 then -- 3717
		return -- 3719
	end -- 3719
	self:drawBox( -- 3721
		draw, -- 3721
		w, -- 3721
		h, -- 3721
		a.x0, -- 3721
		a.x1, -- 3721
		a.y, -- 3721
		a.y + a.h, -- 3721
		HOLE_FILL -- 3721
	) -- 3721
	draw:drawSegment( -- 3722
		Vec2( -- 3722
			self:sx(a.x0, w), -- 3722
			self:sy(a.y + a.h, h) -- 3722
		), -- 3722
		Vec2( -- 3722
			self:sx(a.x1, w), -- 3722
			self:sy(a.y + a.h, h) -- 3722
		), -- 3722
		self:px(1), -- 3722
		SOLID_EDGE -- 3722
	) -- 3722
	draw:drawSegment( -- 3723
		Vec2( -- 3723
			self:sx(a.x0, w), -- 3723
			self:sy(a.y, h) -- 3723
		), -- 3723
		Vec2( -- 3723
			self:sx(a.x0, w), -- 3723
			self:sy(a.y + a.h, h) -- 3723
		), -- 3723
		self:px(1), -- 3723
		SOLID_EDGE -- 3723
	) -- 3723
	draw:drawSegment( -- 3724
		Vec2( -- 3724
			self:sx(a.x1, w), -- 3724
			self:sy(a.y, h) -- 3724
		), -- 3724
		Vec2( -- 3724
			self:sx(a.x1, w), -- 3724
			self:sy(a.y + a.h, h) -- 3724
		), -- 3724
		self:px(1), -- 3724
		SOLID_EDGE -- 3724
	) -- 3724
end -- 3716
function Play.prototype.drawCart(self, draw, w, h) -- 3727
	local c = self.room.cart -- 3728
	if c.bodyW <= 0 then -- 3728
		return -- 3730
	end -- 3730
	drawCartShape( -- 3732
		draw, -- 3732
		self, -- 3732
		w, -- 3732
		h, -- 3732
		c, -- 3732
		self.cartAxle -- 3732
	) -- 3732
	draw:drawRect( -- 3733
		Rect( -- 3733
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3733
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3733
			self:px(2), -- 3733
			self:px(40) -- 3733
		), -- 3733
		STAND -- 3733
	) -- 3733
end -- 3727
function Play.prototype.drawActors(self, draw, w, h) -- 3736
	local p = self.player -- 3737
	local isChild = self.childMode -- 3738
	local footY = p.y + p.depth -- 3739
	if p.covered then -- 3739
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3742
		draw:drawSegment( -- 3743
			Vec2( -- 3743
				self:sx(edge, w), -- 3743
				self:sy(footY + 8, h) -- 3743
			), -- 3743
			Vec2( -- 3743
				self:sx(edge, w), -- 3743
				self:sy(footY + p.h * 0.62, h) -- 3743
			), -- 3743
			self:px(2), -- 3743
			STAND -- 3743
		) -- 3743
		draw:drawSegment( -- 3745
			Vec2( -- 3745
				self:sx(p.x - 8, w), -- 3745
				self:sy(footY + p.h + 3, h) -- 3745
			), -- 3745
			Vec2( -- 3745
				self:sx(p.x + 8, w), -- 3745
				self:sy(footY + p.h + 3, h) -- 3745
			), -- 3745
			self:px(2), -- 3745
			STAND -- 3745
		) -- 3745
	elseif self.coverNear and not isChild then -- 3745
		draw:drawRect( -- 3748
			Rect( -- 3748
				self:sx(p.x - 3, w), -- 3748
				self:sy(footY + 1, h), -- 3748
				self:px(3), -- 3748
				self:px(3) -- 3748
			), -- 3748
			STAND -- 3748
		) -- 3748
	end -- 3748
	drawFigure( -- 3750
		draw, -- 3750
		self, -- 3750
		w, -- 3750
		h, -- 3750
		p, -- 3750
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3750
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3750
	) -- 3750
	local q = self.partner -- 3751
	if q.alive then -- 3751
		local childPartner = q.w == CHILD_W -- 3753
		drawFigure( -- 3754
			draw, -- 3754
			self, -- 3754
			w, -- 3754
			h, -- 3754
			q, -- 3754
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3754
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3754
		) -- 3754
	end -- 3754
	local i = 0 -- 3756
	do -- 3756
		i = 0 -- 3757
		while i < #self.enemies do -- 3757
			local e = self.enemies[i + 1] -- 3758
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3759
			local enemyY = e.y + (e.depth or 0) -- 3760
			self:drawBox( -- 3761
				draw, -- 3761
				w, -- 3761
				h, -- 3761
				e.x - e.w / 2, -- 3761
				e.x + e.w / 2, -- 3761
				enemyY, -- 3761
				enemyY + e.h, -- 3761
				col -- 3761
			) -- 3761
			if e.alive then -- 3761
				local ef = p.x >= e.x and 1 or -1 -- 3763
				if e.kind == "shield" then -- 3763
					local sh = (e.shieldHp or 0) > 0 -- 3765
					draw:drawRect( -- 3766
						Rect( -- 3766
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3766
							self:sy(enemyY, h), -- 3766
							self:px(6), -- 3766
							self:px(64) -- 3766
						), -- 3766
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3767
					) -- 3767
				elseif e.kind == "breaker" then -- 3767
					draw:drawSegment( -- 3769
						Vec2( -- 3769
							self:sx(e.x + ef * 12, w), -- 3769
							self:sy(enemyY + 8, h) -- 3769
						), -- 3769
						Vec2( -- 3770
							self:sx(e.x + ef * 22, w), -- 3770
							self:sy(enemyY + 46, h) -- 3770
						), -- 3770
						self:px(3), -- 3770
						Color(0.5, 0.36, 0.22, 1) -- 3770
					) -- 3770
				end -- 3770
			end -- 3770
			if e.alive and e.warnT > 0 then -- 3770
				local gunX = self:sx(e.x, w) -- 3775
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3776
				local aimX = self:sx(p.x, w) -- 3777
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3778
				local seg = 8 -- 3779
				local s = 0 -- 3780
				do -- 3780
					s = 0 -- 3781
					while s < seg do -- 3781
						local t0 = s / seg -- 3782
						local t1 = (s + 1) / seg -- 3783
						draw:drawSegment( -- 3784
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3785
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3786
							self:px(1), -- 3787
							DANGER -- 3787
						) -- 3787
						s = s + 2 -- 3781
					end -- 3781
				end -- 3781
			end -- 3781
			i = i + 1 -- 3757
		end -- 3757
	end -- 3757
	local k = 0 -- 3792
	do -- 3792
		k = 0 -- 3793
		while k < #self.room.marks do -- 3793
			do -- 3793
				local m = self.room.marks[k + 1] -- 3794
				if m.kind ~= 0 then -- 3794
					goto __continue737 -- 3796
				end -- 3796
				local on = self.checkpoint == m.x -- 3798
				local x = self:sx(m.x, w) -- 3799
				local y = self:sy(m.y, h) -- 3800
				draw:drawSegment( -- 3801
					Vec2(x, y), -- 3801
					Vec2( -- 3801
						x, -- 3801
						y + self:px(35) -- 3801
					), -- 3801
					self:px(1), -- 3801
					on and CHECK or INK_DIM -- 3801
				) -- 3801
				draw:drawDot( -- 3802
					Vec2( -- 3802
						x, -- 3802
						y + self:px(35) -- 3802
					), -- 3802
					self:px(2), -- 3802
					on and CHECK or INK_DIM -- 3802
				) -- 3802
			end -- 3802
			::__continue737:: -- 3802
			k = k + 1 -- 3793
		end -- 3793
	end -- 3793
	local j = 0 -- 3806
	do -- 3806
		j = 0 -- 3807
		while j < #self.room.marks do -- 3807
			do -- 3807
				local m = self.room.marks[j + 1] -- 3808
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3808
					goto __continue740 -- 3810
				end -- 3810
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3810
					goto __continue740 -- 3814
				end -- 3814
				local col = STAND -- 3816
				if m.kind == 4 then -- 3816
					col = PASS_LINE -- 3818
				elseif m.kind == 5 then -- 3818
					col = BRICK_LINE -- 3820
				end -- 3820
				local mx = self:sx(m.x, w) -- 3822
				local my = self:sy(m.y, h) -- 3823
				draw:drawSegment( -- 3824
					Vec2(mx, my), -- 3824
					Vec2( -- 3824
						mx, -- 3824
						my + self:px(24) -- 3824
					), -- 3824
					self:px(1), -- 3824
					col -- 3824
				) -- 3824
			end -- 3824
			::__continue740:: -- 3824
			j = j + 1 -- 3807
		end -- 3807
	end -- 3807
	local t = 0 -- 3827
	do -- 3827
		t = 0 -- 3828
		while t < #self.room.marks do -- 3828
			do -- 3828
				local m = self.room.marks[t + 1] -- 3829
				if m.kind ~= 6 then -- 3829
					goto __continue746 -- 3831
				end -- 3831
				local mx = self:sx(m.x, w) -- 3833
				local my = self:sy(m.y, h) -- 3834
				draw:drawSegment( -- 3835
					Vec2(mx, my), -- 3835
					Vec2( -- 3835
						mx, -- 3835
						my + self:px(30) -- 3835
					), -- 3835
					self:px(1), -- 3835
					INK_DIM -- 3835
				) -- 3835
				self:drawBox( -- 3836
					draw, -- 3836
					w, -- 3836
					h, -- 3836
					m.x - 5, -- 3836
					m.x + 5, -- 3836
					m.y + 30, -- 3836
					m.y + 40, -- 3836
					CHECK -- 3836
				) -- 3836
			end -- 3836
			::__continue746:: -- 3836
			t = t + 1 -- 3828
		end -- 3828
	end -- 3828
	if self.room.key == "village" then -- 3828
		self:drawVillage(draw, w, h) -- 3839
	end -- 3839
	if self.room.key == "forest" then -- 3839
		self:drawDog(draw, w, h) -- 3842
	end -- 3842
end -- 3736
function Play.prototype.drawDog(self, draw, w, h) -- 3847
	local x = self.dogX -- 3848
	self:drawBox( -- 3849
		draw, -- 3849
		w, -- 3849
		h, -- 3849
		x - 14, -- 3849
		x + 14, -- 3849
		0, -- 3849
		20, -- 3849
		SCAV_BODY -- 3849
	) -- 3849
	self:drawBox( -- 3850
		draw, -- 3850
		w, -- 3850
		h, -- 3850
		x - 10, -- 3850
		x - 2, -- 3850
		20, -- 3850
		30, -- 3850
		SCAV_BODY -- 3850
	) -- 3850
	self:drawBox( -- 3851
		draw, -- 3851
		w, -- 3851
		h, -- 3851
		x + 2, -- 3851
		x + 10, -- 3851
		20, -- 3851
		30, -- 3851
		SCAV_HEAD -- 3851
	) -- 3851
	if self.dogState == "ear" or self.dogState == "chase" then -- 3851
		draw:drawSegment( -- 3853
			Vec2( -- 3853
				self:sx(x, w), -- 3853
				self:sy(30, h) -- 3853
			), -- 3853
			Vec2( -- 3854
				self:sx(x, w), -- 3854
				self:sy(40, h) -- 3854
			), -- 3854
			self:px(1), -- 3854
			DANGER -- 3854
		) -- 3854
	end -- 3854
end -- 3847
function Play.prototype.drawVillage(self, draw, w, h) -- 3859
	local bottle = self.room.bottle -- 3860
	if bottle ~= nil then -- 3860
		self:drawBox( -- 3862
			draw, -- 3862
			w, -- 3862
			h, -- 3862
			bottle.x - 14, -- 3862
			bottle.x + 14, -- 3862
			0, -- 3862
			64, -- 3862
			SOLID_FILL -- 3862
		) -- 3862
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3862
			self:drawBottle( -- 3864
				draw, -- 3864
				w, -- 3864
				h, -- 3864
				bottle.x, -- 3864
				64 -- 3864
			) -- 3864
		end -- 3864
	end -- 3864
	self:drawBox( -- 3868
		draw, -- 3868
		w, -- 3868
		h, -- 3868
		300, -- 3868
		420, -- 3868
		44, -- 3868
		50, -- 3868
		FLOOR_DECK -- 3868
	) -- 3868
	self:drawBox( -- 3869
		draw, -- 3869
		w, -- 3869
		h, -- 3869
		300, -- 3869
		306, -- 3869
		0, -- 3869
		44, -- 3869
		FLOOR_DECK -- 3869
	) -- 3869
	self:drawBox( -- 3870
		draw, -- 3870
		w, -- 3870
		h, -- 3870
		414, -- 3870
		420, -- 3870
		0, -- 3870
		44, -- 3870
		FLOOR_DECK -- 3870
	) -- 3870
	local s = self.room.scavenger -- 3872
	if s ~= nil then -- 3872
		local sx0 = self.scavX -- 3874
		self:drawBox( -- 3875
			draw, -- 3875
			w, -- 3875
			h, -- 3875
			sx0 - 12, -- 3875
			sx0 + 12, -- 3875
			0, -- 3875
			s.h - 14, -- 3875
			SCAV_BODY -- 3875
		) -- 3875
		self:drawBox( -- 3876
			draw, -- 3876
			w, -- 3876
			h, -- 3876
			sx0 - 7, -- 3876
			sx0 + 7, -- 3876
			s.h - 14, -- 3876
			s.h, -- 3876
			SCAV_HEAD -- 3876
		) -- 3876
		if self.scavState == "turn" then -- 3876
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3878
			draw:drawSegment( -- 3879
				Vec2( -- 3879
					self:sx(sx0, w), -- 3879
					self:sy(s.h - 6, h) -- 3879
				), -- 3879
				Vec2( -- 3879
					self:sx(fx, w), -- 3879
					self:sy(s.h - 6, h) -- 3879
				), -- 3879
				self:px(1), -- 3879
				INK -- 3879
			) -- 3879
		end -- 3879
	end -- 3879
	if self.hasBottle then -- 3879
		local p = self.player -- 3884
		self:drawBottle( -- 3885
			draw, -- 3885
			w, -- 3885
			h, -- 3885
			p.x + p.facing * 10, -- 3885
			p.y + p.h * 0.62 -- 3885
		) -- 3885
	end -- 3885
	if self.bottleFly ~= nil then -- 3885
		self:drawBottle( -- 3888
			draw, -- 3888
			w, -- 3888
			h, -- 3888
			self.bottleFly.x, -- 3888
			self.bottleFly.y -- 3888
		) -- 3888
	end -- 3888
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3888
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3891
		draw:drawCircle( -- 3892
			Vec2( -- 3892
				self:sx(self.bottleLandX, w), -- 3892
				self:sy(0, h) -- 3892
			), -- 3892
			self:px(r / ____exports.UNITS_PER_PX), -- 3892
			BRICK_LINE -- 3892
		) -- 3892
	end -- 3892
end -- 3859
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3896
	self:drawBox( -- 3897
		draw, -- 3897
		w, -- 3897
		h, -- 3897
		x - 3, -- 3897
		x + 3, -- 3897
		y - 10, -- 3897
		y, -- 3897
		BOTTLE -- 3897
	) -- 3897
end -- 3896
function Play.prototype.drawTrace(self, draw, w, h) -- 3900
	local t = self.trace -- 3901
	if t == nil or self.traceT <= 0 then -- 3901
		return -- 3903
	end -- 3903
	draw:drawSegment( -- 3905
		Vec2( -- 3906
			self:sx(t.x0, w), -- 3906
			self:sy(t.y0, h) -- 3906
		), -- 3906
		Vec2( -- 3907
			self:sx(t.x1, w), -- 3907
			self:sy(t.y1, h) -- 3907
		), -- 3907
		self:px(1), -- 3908
		t.hit and AIM_HIT or INK_DIM -- 3908
	) -- 3908
end -- 3900
function Play.prototype.drawAim(self, draw, w, h) -- 3911
	local v = self.view -- 3913
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3914
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3915
	local dot = self:px(1) -- 3916
	local arm = self:px(3) -- 3917
	local gap = self:px(1) -- 3918
	draw:drawSegment( -- 3919
		Vec2(gx - arm - gap, gy), -- 3919
		Vec2(gx - gap, gy), -- 3919
		dot / 2, -- 3919
		AIM -- 3919
	) -- 3919
	draw:drawSegment( -- 3920
		Vec2(gx + gap, gy), -- 3920
		Vec2(gx + arm + gap, gy), -- 3920
		dot / 2, -- 3920
		AIM -- 3920
	) -- 3920
	draw:drawSegment( -- 3921
		Vec2(gx, gy - arm - gap), -- 3921
		Vec2(gx, gy - gap), -- 3921
		dot / 2, -- 3921
		AIM -- 3921
	) -- 3921
	draw:drawSegment( -- 3922
		Vec2(gx, gy + gap), -- 3922
		Vec2(gx, gy + arm + gap), -- 3922
		dot / 2, -- 3922
		AIM -- 3922
	) -- 3922
	if self.room.key == "village" and self.hasBottle then -- 3922
		local p = self.player -- 3926
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3928
		local dir = ____end.x >= p.x and 1 or -1 -- 3929
		local x0 = p.x + dir * 10 -- 3930
		local y0 = p.y + p.h * 0.7 -- 3931
		local T = BOTTLE_FLY_TIME -- 3932
		local vx = (____end.x - x0) / T -- 3933
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3934
		local pxr = x0 -- 3935
		local pyr = y0 -- 3936
		local t = 1 -- 3937
		do -- 3937
			t = 1 -- 3938
			while t <= 12 do -- 3938
				local tt = t / 12 * T -- 3939
				local nx = x0 + vx * tt -- 3940
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3941
				draw:drawSegment( -- 3942
					Vec2( -- 3942
						self:sx(pxr, w), -- 3942
						self:sy(pyr, h) -- 3942
					), -- 3942
					Vec2( -- 3942
						self:sx(nx, w), -- 3942
						self:sy(ny, h) -- 3942
					), -- 3942
					self:px(1) / 2, -- 3942
					BOTTLE -- 3942
				) -- 3942
				pxr = nx -- 3943
				pyr = ny -- 3944
				t = t + 1 -- 3938
			end -- 3938
		end -- 3938
		draw:drawCircle( -- 3946
			Vec2( -- 3946
				self:sx(____end.x, w), -- 3946
				self:sy(____end.y + 2, h) -- 3946
			), -- 3946
			self:px(2), -- 3946
			BOTTLE -- 3946
		) -- 3946
	end -- 3946
end -- 3911
return ____exports -- 3911