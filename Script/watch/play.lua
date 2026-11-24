-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
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
function makeActor(room, index) -- 3752
	local sp = room.spawns -- 3753
	if index < 0 or index >= #sp then -- 3753
		return { -- 3755
			x = 0, -- 3755
			y = 0, -- 3755
			depth = 0, -- 3755
			depthSpeed = 0, -- 3755
			vx = 0, -- 3755
			vy = 0, -- 3755
			w = CHILD_W, -- 3755
			h = CHILD_H, -- 3755
			onGround = true, -- 3755
			facing = 1, -- 3755
			crouch = false, -- 3755
			rollT = 0, -- 3755
			covered = false, -- 3755
			alive = false -- 3755
		} -- 3755
	end -- 3755
	local s = sp[index + 1] -- 3757
	local child = s.h <= CHILD_H -- 3758
	local ground = room.depth -- 3759
	local depth = ground == nil and 0 or math.max( -- 3760
		ground.min, -- 3760
		math.min(ground.max, s.depth or 0) -- 3760
	) -- 3760
	return { -- 3761
		x = s.x, -- 3762
		y = s.y, -- 3762
		depth = depth, -- 3762
		depthSpeed = 0, -- 3762
		vx = 0, -- 3762
		vy = 0, -- 3762
		w = child and CHILD_W or SOLDIER_W, -- 3763
		h = child and CHILD_H or SOLDIER_H, -- 3764
		onGround = true, -- 3765
		facing = 1, -- 3765
		crouch = false, -- 3765
		rollT = 0, -- 3765
		covered = false, -- 3765
		alive = true -- 3765
	} -- 3765
end -- 3765
function drawFigure(draw, play, w, h, a, body, head) -- 3769
	if not a.alive then -- 3769
		return -- 3771
	end -- 3771
	local x0 = a.x - a.w / 2 -- 3773
	local x1 = a.x + a.w / 2 -- 3774
	local y0 = a.y + a.depth -- 3775
	local y1 = y0 + a.h -- 3776
	play:drawBox( -- 3777
		draw, -- 3777
		w, -- 3777
		h, -- 3777
		x0, -- 3777
		x1, -- 3777
		y0, -- 3777
		y1 - a.h * 0.26, -- 3777
		body -- 3777
	) -- 3777
	play:drawBox( -- 3778
		draw, -- 3778
		w, -- 3778
		h, -- 3778
		x0 + 2, -- 3778
		x1 - 2, -- 3778
		y1 - a.h * 0.26, -- 3778
		y1, -- 3778
		head -- 3778
	) -- 3778
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3780
	play:drawBox( -- 3781
		draw, -- 3781
		w, -- 3781
		h, -- 3781
		eyeX, -- 3781
		eyeX + 4, -- 3781
		y1 - a.h * 0.14, -- 3781
		y1 - a.h * 0.08, -- 3781
		INK -- 3781
	) -- 3781
end -- 3781
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3785
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3786
end -- 3785
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3793
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3794
end -- 3793
function rayInterval(origin, direction, min, max) -- 3801
	if direction == 0 then -- 3801
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 3803
	end -- 3803
	local a = (min - origin) / direction -- 3805
	local b = (max - origin) / direction -- 3806
	return { -- 3807
		min = math.min(a, b), -- 3807
		max = math.max(a, b) -- 3807
	} -- 3807
end -- 3807
function hitBox(ray, box) -- 3811
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 3812
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 3813
	local enter = math.max(0, x.min, y.min) -- 3814
	local leave = math.min(99999, x.max, y.max) -- 3815
	if box.depth ~= nil then -- 3815
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 3817
		enter = math.max(enter, depth.min) -- 3818
		leave = math.min(leave, depth.max) -- 3819
	end -- 3819
	return leave >= enter and enter or -1 -- 3821
end -- 3821
function drawCartShape(draw, play, w, h, c, axleX) -- 3824
	local half = c.bodyW / 2 -- 3825
	local x0 = axleX - half -- 3826
	local x1 = axleX + half -- 3827
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 3828
	play:drawBox( -- 3829
		draw, -- 3829
		w, -- 3829
		h, -- 3829
		x0, -- 3829
		x1, -- 3829
		axleY, -- 3829
		axleY + c.bodyH, -- 3829
		CART_FILL -- 3829
	) -- 3829
	draw:drawCircle( -- 3830
		Vec2( -- 3830
			play:sx(x0 + c.bodyW * 0.28, w), -- 3830
			play:sy(axleY, h) -- 3830
		), -- 3830
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3830
		Color(52, 50, 48, 255) -- 3830
	) -- 3830
	draw:drawCircle( -- 3831
		Vec2( -- 3831
			play:sx(x1 - c.bodyW * 0.28, w), -- 3831
			play:sy(axleY, h) -- 3831
		), -- 3831
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 3831
		Color(52, 50, 48, 255) -- 3831
	) -- 3831
	local cx = c.clothSide < 0 and x0 or x1 -- 3832
	play:drawBox( -- 3833
		draw, -- 3833
		w, -- 3833
		h, -- 3833
		cx - 10, -- 3833
		cx + 10, -- 3833
		axleY + c.bodyH, -- 3833
		axleY + c.bodyH + 18, -- 3833
		CLOTH -- 3833
	) -- 3833
end -- 3833
____exports.STEP = STEP -- 24
____exports.GRAVITY = 1000 -- 25
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 27
CHILD_W = 28 -- 62
CHILD_H = 64 -- 63
local CHILD_CROUCH_H = 36 -- 64
local CHILD_SPEED = 160 -- 65
local CHILD_SLOW = 80 -- 66
local CHILD_JUMP = 372 -- 67
SOLDIER_W = 30 -- 70
SOLDIER_H = 88 -- 71
local SOLDIER_SPEED = 264 -- 72
local ROLL_TIME = 0.35 -- 73
local ROLL_SPEED = 280 -- 74
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 76
local LEDGE_RISE = 60 -- 77
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 80
____exports.LOGIC_H = 180 -- 81
____exports.UNITS_PER_PX = 2 -- 82
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 84
local CAM_FOLLOW = 9 -- 85
local CAM_LOOK_UP = 46 -- 86
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 89
--- 握把触发半径。
____exports.CART_REACH = 70 -- 91
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 93
local CART_CLEAR = 44 -- 94
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 96
local FIRE_COOLDOWN = 150 -- 97
local ENEMY_RANGE = 760 -- 98
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 100
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 102
local DEPTH_SPEED_RATIO = 0.55 -- 103
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 104
INK = Color(232, 232, 228, 255) -- 106
local INK_DIM = Color(150, 152, 150, 255) -- 107
local BG_VOID = Color(8, 9, 10, 255) -- 108
local BG_FAR = Color(24, 26, 28, 255) -- 109
local BG_MID = Color(31, 34, 37, 255) -- 110
local GROUND = Color(112, 114, 112, 255) -- 111
local FLOOR_DECK = Color(66, 70, 72, 255) -- 112
local SOLID_FILL = Color(84, 86, 84, 255) -- 113
local SOLID_EDGE = Color(126, 130, 126, 255) -- 114
CART_FILL = Color(122, 78, 56, 255) -- 115
CLOTH = Color(178, 52, 46, 255) -- 116
local DANGER = Color(150, 54, 48, 46) -- 117
local DANGER_LINE = Color(178, 78, 64, 200) -- 118
local HOLE_FILL = Color(10, 11, 12, 255) -- 119
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 120
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 121
local CHILD_BODY = Color(214, 168, 96, 255) -- 122
local CHILD_HEAD = Color(232, 214, 186, 255) -- 123
local ENEMY_BODY = Color(176, 92, 84, 255) -- 124
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 125
local CHECK = Color(96, 186, 122, 255) -- 126
local STAND = Color(226, 186, 84, 255) -- 127
local AIM = Color(236, 236, 232, 230) -- 128
local AIM_HIT = Color(236, 96, 84, 255) -- 129
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 131
local SOFT_LINE = Color(140, 112, 80, 190) -- 132
local BRICK = Color(126, 118, 110, 70) -- 133
local BRICK_LINE = Color(160, 152, 142, 200) -- 134
local PASS = Color(96, 186, 122, 40) -- 135
local PASS_LINE = Color(96, 186, 122, 200) -- 136
local BOTTLE = Color(120, 186, 160, 255) -- 137
local SCAV_BODY = Color(128, 118, 96, 255) -- 138
local SCAV_HEAD = Color(196, 182, 158, 255) -- 139
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 226
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 227
	if zoom < 1 then -- 227
		zoom = 1 -- 229
	end -- 229
	return { -- 231
		zoom = zoom, -- 232
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 233
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 234
	} -- 234
end -- 226
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 257
	if key == "prologue" then -- 257
		return "prologue-wait" -- 259
	end -- 259
	if key == "street" then -- 259
		return "street-run" -- 262
	end -- 262
	if key == "gate" then -- 262
		return "gate-idle" -- 265
	end -- 265
	if key == "forest" then -- 265
		return "forest-run" -- 268
	end -- 268
	if key == "tower" then -- 268
		return "tower-wait" -- 271
	end -- 271
	return "run" -- 273
end -- 257
____exports.Play = __TS__Class() -- 276
local Play = ____exports.Play -- 276
Play.name = "Play" -- 276
function Play.prototype.____constructor(self, room, resume, run) -- 442
	self.enemies = {} -- 281
	self.boxes = {} -- 282
	self.floors = {} -- 283
	self.checkpoint = -1 -- 285
	self.flash = "" -- 287
	self.flashT = 0 -- 288
	self.traceT = 0 -- 291
	self.focusCart = false -- 293
	self.knocks = 0 -- 295
	self.knockT = 0 -- 296
	self.cartAxle = 0 -- 300
	self.cartDocked = false -- 302
	self.gripping = false -- 304
	self.gateOpen = false -- 306
	self.calmConsumed = false -- 308
	self.nextDangerId = 1 -- 310
	self.wantRoom = "" -- 312
	self.carryCartAxle = -1 -- 314
	self.carryCartDocked = false -- 315
	self.checkpointCartAxle = -1 -- 317
	self.hasBottle = false -- 321
	self.bottleLandX = -1 -- 325
	self.bottleTargetX = -1 -- 326
	self.bottleTargetY = 0 -- 327
	self.bottleLandT = 0 -- 328
	self.aimHold = 0 -- 330
	self.scavX = 0 -- 332
	self.scavDir = 1 -- 333
	self.scavState = "patrol" -- 334
	self.scavT = 0 -- 335
	self.scavTargetX = 0 -- 336
	self.passed = false -- 338
	self.childMode = false -- 342
	self.phase = "" -- 344
	self.phaseTick = 0 -- 346
	self.gateTick = 0 -- 348
	self.countTick = 0 -- 350
	self.countArmed = false -- 352
	self.countPrevMove = 0 -- 354
	self.caughtT = 0 -- 356
	self.hp = 3 -- 358
	self.maxHp = 3 -- 359
	self.invulnT = 0 -- 361
	self.partnerStuck = 0 -- 363
	self.partnerLaneIdx = 0 -- 365
	self.partnerLaneHold = 0 -- 366
	self.coveredFlash = 0 -- 368
	self.coverHug = false -- 370
	self.coverNear = false -- 372
	self.coverEntity = "" -- 374
	self.coverBlocking = false -- 376
	self.gateNeedConfirm = false -- 378
	self.gateRestartArmed = true -- 380
	self.bottleAimX = -1 -- 382
	self.bottleAimY = 0 -- 383
	self.bottleSurfaceY = -1 -- 385
	self.bottleLandY = 0 -- 387
	self.events = {} -- 389
	self.eventSeq = 0 -- 391
	self.dogX = 0 -- 393
	self.dogDir = 1 -- 394
	self.dogState = "patrol" -- 395
	self.dogT = 0 -- 396
	self.dogTargetX = 0 -- 397
	self.scavSee = 0 -- 399
	self.scavChase = false -- 400
	self.gateSpawned = 0 -- 402
	self.gateFailCount = 0 -- 404
	self.isCampaign = false -- 408
	self.pickups = {} -- 412
	self.reloadT = 0 -- 414
	self.objectiveDone = false -- 418
	self.hint = "" -- 420
	self.roomStartTick = 0 -- 422
	self.cartHitT = 0 -- 424
	self.paused = false -- 426
	self.ticks = 0 -- 428
	self.view = {zoom = 1, ox = 0, oy = 0} -- 430
	self.ox = 0 -- 432
	self.aimX = 0 -- 434
	self.aimY = 0 -- 435
	self.viewW = 0 -- 437
	self.viewH = 0 -- 438
	self.ox = room.originX -- 444
	self.room = withOrigin(room) -- 445
	local wr = self.room -- 446
	self.run = run or createRun() -- 447
	self.isCampaign = wr.campaign ~= nil -- 448
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 449
	self:buildWorld() -- 450
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 452
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 453
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 454
	self.player = makeActor(wr, playerIdx) -- 455
	self.partner = makeActor(wr, partnerIdx) -- 456
	self.phase = phaseOf(wr.key) -- 457
	if wr.story ~= nil then -- 457
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 459
	end -- 459
	self.cam.x = self.player.x -- 461
	self.cam.y = self.player.y + CAM_LOOK_UP -- 462
	self.cartAxle = wr.cart.startX -- 463
	self.escort = __TS__New( -- 464
		Escort, -- 464
		safeAnchorX(wr.marks) -- 464
	) -- 464
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 465
	if self.isCampaign then -- 465
		self:setupCampaign() -- 467
	else -- 467
		self:buildEnemies() -- 469
	end -- 469
	if resume ~= nil and resume.checkpoint > 0 then -- 469
		self.checkpoint = resume.checkpoint -- 473
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 473
			self.cartAxle = self.room.cart.endX -- 475
			self.cartDocked = true -- 476
			self.player.x = self.ox + 380 -- 479
			self.player.y = 0 -- 480
			self.player.vy = 0 -- 481
			self.player.onGround = true -- 482
			self.cam.x = self.player.x -- 483
			self.cam.y = self.player.y + CAM_LOOK_UP -- 484
		end -- 484
	end -- 484
end -- 442
function Play.prototype.buildWorld(self) -- 490
	local room = self.room -- 491
	self.boxes = {} -- 492
	self.floors = {} -- 493
	local i = 0 -- 494
	do -- 494
		i = 0 -- 495
		while i < #room.floors do -- 495
			local f = room.floors[i + 1] -- 496
			local ____self_floors_0 = self.floors -- 496
			____self_floors_0[#____self_floors_0 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 497
			i = i + 1 -- 495
		end -- 495
	end -- 495
	do -- 495
		i = 0 -- 499
		while i < #room.solids do -- 499
			local s = room.solids[i + 1] -- 500
			if not s.decorative then -- 500
				local ____self_boxes_12 = self.boxes -- 506
				local ____s_x_3 = s.x -- 507
				local ____temp_4 = s.x + s.w -- 507
				local ____s_y_5 = s.y -- 507
				local ____temp_6 = s.y + s.h -- 507
				local ____temp_1 -- 508
				if room.depth == nil then -- 508
					____temp_1 = nil -- 508
				else -- 508
					____temp_1 = s.depth -- 508
				end -- 508
				local ____temp_7 = s.passable == true -- 509
				local ____s_label_8 = s.label -- 509
				local ____s_id_9 = s.id -- 510
				local ____temp_10 = s.soft == true -- 510
				local ____temp_11 = s.hidden == true -- 510
				local ____temp_2 -- 511
				if s.breakable == nil then -- 511
					____temp_2 = nil -- 511
				else -- 511
					____temp_2 = __TS__ObjectAssign({}, s.breakable) -- 511
				end -- 511
				____self_boxes_12[#____self_boxes_12 + 1] = { -- 506
					x0 = ____s_x_3, -- 507
					x1 = ____temp_4, -- 507
					y0 = ____s_y_5, -- 507
					y1 = ____temp_6, -- 507
					depth = ____temp_1, -- 508
					passable = ____temp_7, -- 509
					label = ____s_label_8, -- 509
					id = ____s_id_9, -- 510
					soft = ____temp_10, -- 510
					hidden = ____temp_11, -- 510
					breakable = ____temp_2, -- 511
					interact = s.interact -- 512
				} -- 512
			end -- 512
			i = i + 1 -- 499
		end -- 499
	end -- 499
	do -- 499
		i = 0 -- 516
		while i < #room.stairs do -- 516
			local st = room.stairs[i + 1] -- 517
			local n = st.steps + 1 -- 518
			local stepW = (st.x1 - st.x0) / n -- 519
			local k = 0 -- 520
			do -- 520
				k = 0 -- 521
				while k < n do -- 521
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 522
					local x0 = st.x0 + stepW * k -- 523
					local ____self_boxes_13 = self.boxes -- 523
					____self_boxes_13[#____self_boxes_13 + 1] = { -- 525
						x0 = x0, -- 525
						x1 = x0 + stepW, -- 525
						y0 = -8, -- 525
						y1 = y, -- 525
						passable = true -- 525
					} -- 525
					k = k + 1 -- 521
				end -- 521
			end -- 521
			i = i + 1 -- 516
		end -- 516
	end -- 516
end -- 490
function Play.prototype.setupCampaign(self) -- 534
	local wr = self.room -- 535
	local c = wr.campaign -- 536
	if c == nil then -- 536
		return -- 538
	end -- 538
	self.roomStartTick = self.run.ticks -- 540
	if wr.key == "s1-crossroad" then -- 540
		self.run.joined = true -- 543
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 543
		local ____self_run_15 = self.run -- 546
		local ____temp_14 -- 546
		if wr.key == "s2-drygoods" then -- 546
			____temp_14 = self.run.route ~= "drygoods" -- 546
		else -- 546
			____temp_14 = false -- 546
		end -- 546
		____self_run_15.joined = ____temp_14 -- 546
	end -- 546
	local x = wr.minX + 60 -- 548
	local y = 0 -- 549
	local depth = 0 -- 550
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 550
		x = wr.minX + 210 -- 552
		depth = -32 -- 553
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 553
		x = wr.minX + 40 -- 555
		y = 32 -- 556
		depth = 32 -- 557
	end -- 557
	self.player = { -- 559
		x = x, -- 560
		y = y, -- 560
		depth = depth, -- 560
		depthSpeed = 0, -- 560
		vx = 0, -- 560
		vy = 0, -- 560
		w = SOLDIER_W, -- 561
		h = SOLDIER_H, -- 561
		onGround = y <= 0, -- 561
		facing = 1, -- 561
		crouch = false, -- 561
		rollT = 0, -- 561
		covered = false, -- 561
		alive = true -- 561
	} -- 561
	self.partner = { -- 563
		x = x + 60, -- 564
		y = y, -- 564
		depth = depth, -- 564
		depthSpeed = 0, -- 564
		vx = 0, -- 564
		vy = 0, -- 564
		w = CHILD_W, -- 565
		h = CHILD_H, -- 565
		onGround = y <= 0, -- 565
		facing = 1, -- 565
		crouch = false, -- 565
		rollT = 0, -- 565
		covered = false, -- 565
		alive = true -- 565
	} -- 565
	self.cam.x = x -- 567
	self.cam.y = y + CAM_LOOK_UP -- 568
	self.phase = "run" -- 569
	self.hp = self.maxHp -- 570
	self:buildEnemies() -- 571
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 572
	local i = 0 -- 573
	do -- 573
		i = 0 -- 574
		while i < #self.boxes do -- 574
			do -- 574
				local b = self.boxes[i + 1] -- 575
				if b.id == nil then -- 575
					goto __continue33 -- 577
				end -- 577
				local st = self.run.props[b.id] -- 579
				if st ~= nil then -- 579
					b.broken = st.broken -- 581
					local ____temp_16 -- 582
					if b.breakable == nil then -- 582
						____temp_16 = nil -- 582
					else -- 582
						____temp_16 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 582
					end -- 582
					b.breakable = ____temp_16 -- 582
					b.hidden = b.hidden == true and st.revealed ~= true -- 583
					if b.hidden then -- 583
						b.broken = true -- 585
					end -- 585
				elseif b.hidden == true then -- 585
					b.broken = true -- 589
				end -- 589
			end -- 589
			::__continue33:: -- 589
			i = i + 1 -- 574
		end -- 574
	end -- 574
	if wr.cart.bodyW > 0 then -- 574
		self.cartAxle = wr.cart.startX -- 593
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 593
			self.cartAxle = wr.cart.endX -- 595
			self.cartDocked = true -- 596
		end -- 596
	end -- 596
	do -- 596
		i = 0 -- 599
		while i < #self.pickups do -- 599
			local pk = self.pickups[i + 1] -- 600
			if self.run.taken[pk.id] == true then -- 600
				pk.id = "" -- 602
			end -- 602
			i = i + 1 -- 599
		end -- 599
	end -- 599
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 605
end -- 534
function Play.prototype.log(self, line) -- 608
	local ____self_run_log_17 = self.run.log -- 608
	____self_run_log_17[#____self_run_log_17 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 609
	if #self.run.log > 120 then -- 609
		table.remove(self.run.log, 1) -- 611
	end -- 611
end -- 608
function Play.prototype.buildEnemies(self) -- 615
	self.enemies = {} -- 616
	if self.isCampaign then -- 616
		local i = 0 -- 618
		do -- 618
			i = 0 -- 619
			while i < #self.room.spawns do -- 619
				local sp = self.room.spawns[i + 1] -- 620
				local kind = sp.kind or "gunner" -- 621
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 622
				local ____self_enemies_18 = self.enemies -- 622
				____self_enemies_18[#____self_enemies_18 + 1] = { -- 623
					x = sp.x, -- 624
					y = sp.y, -- 624
					depth = sp.depth, -- 624
					w = 26, -- 624
					h = sp.h, -- 624
					alive = true, -- 624
					hitT = 0, -- 624
					warnT = 0, -- 624
					fireCd = 40, -- 624
					kind = kind, -- 625
					shieldHp = hp, -- 625
					shieldHpMax = hp, -- 625
					drop = sp.drop or "none", -- 625
					homeX = sp.x, -- 626
					swingT = 0, -- 626
					awake = false, -- 626
					squad = i -- 626
				} -- 626
				i = i + 1 -- 619
			end -- 619
		end -- 619
		return -- 629
	end -- 629
	if self.room.key == "checkpoint" then -- 629
		local ____self_enemies_19 = self.enemies -- 629
		____self_enemies_19[#____self_enemies_19 + 1] = { -- 632
			x = self.ox + 430, -- 632
			y = 0, -- 632
			w = 26, -- 632
			h = 84, -- 632
			alive = true, -- 632
			hitT = 0, -- 632
			warnT = 0, -- 632
			fireCd = 0 -- 632
		} -- 632
		local ____self_enemies_20 = self.enemies -- 632
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 633
			x = self.ox + 505, -- 633
			y = 0, -- 633
			w = 26, -- 633
			h = 84, -- 633
			alive = true, -- 633
			hitT = 0, -- 633
			warnT = 0, -- 633
			fireCd = 0 -- 633
		} -- 633
		return -- 634
	end -- 634
	if self.room.key == "street" then -- 634
		local ____self_enemies_21 = self.enemies -- 634
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 638
			x = self.ox + 340, -- 638
			y = 0, -- 638
			w = 26, -- 638
			h = 84, -- 638
			alive = true, -- 638
			hitT = 0, -- 638
			warnT = 0, -- 638
			fireCd = 0 -- 638
		} -- 638
		local ____self_enemies_22 = self.enemies -- 638
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 639
			x = self.ox + 560, -- 639
			y = 0, -- 639
			w = 26, -- 639
			h = 84, -- 639
			alive = true, -- 639
			hitT = 0, -- 639
			warnT = 0, -- 639
			fireCd = 0 -- 639
		} -- 639
	end -- 639
end -- 615
function Play.prototype.emit(self, name, data) -- 645
	local ____self_events_23 = self.events -- 645
	____self_events_23[#____self_events_23 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 646
	self.eventSeq = self.eventSeq + 1 -- 647
	if #self.events > 256 then -- 647
		table.remove(self.events, 1) -- 649
	end -- 649
end -- 645
function Play.prototype.drainEvents(self) -- 657
	local out = self.events -- 658
	self.events = {} -- 659
	return out -- 660
end -- 657
function Play.prototype.adoptEvents(self, events) -- 669
	if #events == 0 then -- 669
		return -- 671
	end -- 671
	local keep = {} -- 673
	local i = 0 -- 674
	do -- 674
		i = 0 -- 675
		while i < #events do -- 675
			do -- 675
				local e = events[i + 1] -- 676
				if e.name == "knock" and e.data.room ~= self.room.key then -- 676
					goto __continue57 -- 678
				end -- 678
				keep[#keep + 1] = e -- 680
			end -- 680
			::__continue57:: -- 680
			i = i + 1 -- 675
		end -- 675
	end -- 675
	if #keep == 0 then -- 675
		return -- 683
	end -- 683
	self.events = __TS__ArrayConcat(keep, self.events) -- 685
	do -- 685
		i = 0 -- 686
		while i < #self.events do -- 686
			self.events[i + 1].seq = i -- 687
			i = i + 1 -- 686
		end -- 686
	end -- 686
	self.eventSeq = #self.events -- 689
end -- 669
function Play.prototype.update(self, dt, input) -- 693
	if input.pause.pressed then -- 693
		self.paused = not self.paused -- 695
	end -- 695
	if self.invulnT > 0 then -- 695
		self.invulnT = self.invulnT - dt -- 698
	end -- 698
	if self.flashT > 0 then -- 698
		self.flashT = self.flashT - dt -- 701
		if self.flashT <= 0 then -- 701
			self.flash = "" -- 703
		end -- 703
	end -- 703
	if self.traceT > 0 then -- 703
		self.traceT = self.traceT - dt -- 707
		if self.traceT <= 0 then -- 707
			self.trace = nil -- 709
		end -- 709
	end -- 709
	if self.paused then -- 709
		self:updateCamera(dt) -- 713
		return -- 714
	end -- 714
	self.ticks = self.ticks + 1 -- 717
	if self.isCampaign then -- 717
		local ____self_run_24, ____ticks_25 = self.run, "ticks" -- 717
		____self_run_24[____ticks_25] = ____self_run_24[____ticks_25] + 1 -- 719
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 720
	end -- 720
	local p = self.player -- 722
	self:stepPlayer(p, dt, input) -- 723
	self:refreshCover(p, input) -- 725
	if self.isCampaign then -- 725
		self:stepCampaign(dt, input) -- 727
		self:stepCampaignPartner(dt) -- 728
	end -- 728
	self:stepEnemies(dt, input) -- 731
	if not self.isCampaign then -- 731
		self:stepStory(dt, input) -- 733
		self:stepEscort(dt, input) -- 734
		self:stepVillage(dt, input) -- 735
		self:stepChase(dt, input) -- 736
		self:stepInteract(dt, input) -- 737
	end -- 737
	self:updateGate() -- 739
	self:updateCamera(dt) -- 740
end -- 693
function Play.prototype.underLowArch(self, a) -- 747
	local arch = self.room.arch -- 748
	if arch.h <= 0 then -- 748
		return false -- 750
	end -- 750
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 750
		return false -- 753
	end -- 753
	local top = arch.y + arch.h -- 755
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 756
end -- 747
function Play.prototype.coverAt(self, a) -- 763
	local best = nil -- 764
	local bestGap = 24 -- 765
	local half = a.w / 2 -- 766
	local i = 0 -- 767
	do -- 767
		i = 0 -- 768
		while i < #self.boxes do -- 768
			do -- 768
				local b = self.boxes[i + 1] -- 769
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 769
					goto __continue78 -- 771
				end -- 771
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 771
					goto __continue78 -- 774
				end -- 774
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 776
				if gap < bestGap then -- 776
					bestGap = gap -- 778
					best = b -- 779
				end -- 779
			end -- 779
			::__continue78:: -- 779
			i = i + 1 -- 768
		end -- 768
	end -- 768
	return best -- 782
end -- 763
function Play.prototype.nearCover(self, a) -- 785
	return self:coverAt(a) ~= nil -- 786
end -- 785
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 790
	if enemy == nil then -- 790
		return false -- 792
	end -- 792
	local fromRight = enemy.x >= a.x -- 794
	local edge = fromRight and b.x0 or b.x1 -- 795
	local ____fromRight_26 -- 796
	if fromRight then -- 796
		____fromRight_26 = edge >= a.x - 0.001 and edge <= enemy.x -- 796
	else -- 796
		____fromRight_26 = edge <= a.x + 0.001 and edge >= enemy.x -- 797
	end -- 797
	local between = ____fromRight_26 -- 796
	local separation = enemy.x - a.x -- 798
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 799
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 800
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 801
end -- 790
function Play.prototype.nearestEnemy(self, a) -- 804
	local best -- 805
	local bestD = 1000000000 -- 806
	local i = 0 -- 807
	do -- 807
		i = 0 -- 808
		while i < #self.enemies do -- 808
			do -- 808
				local e = self.enemies[i + 1] -- 809
				if not e.alive then -- 809
					goto __continue87 -- 811
				end -- 811
				local d = math.abs(e.x - a.x) -- 813
				if d < bestD then -- 813
					bestD = d -- 815
					best = e -- 816
				end -- 816
			end -- 816
			::__continue87:: -- 816
			i = i + 1 -- 808
		end -- 808
	end -- 808
	return best -- 819
end -- 804
function Play.prototype.refreshCover(self, a, input) -- 823
	if self.childMode then -- 823
		self.coverNear = false -- 825
		self.coverHug = false -- 826
		self.coverEntity = "" -- 827
		self.coverBlocking = false -- 828
		a.covered = false -- 829
		return -- 830
	end -- 830
	local b = self:coverAt(a) -- 832
	self.coverNear = b ~= nil -- 833
	a.covered = self.coverNear and input.cover.held -- 834
	self.coverHug = a.covered -- 835
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 836
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 837
		b, -- 837
		a, -- 837
		self:nearestEnemy(a) -- 837
	) -- 837
end -- 823
function Play.prototype.cartHandleInReach(self, a) -- 841
	if a == nil then -- 841
		a = self.player -- 841
	end -- 841
	local c = self.room.cart -- 842
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 842
		return false -- 844
	end -- 844
	local handleX = self.cartAxle + c.handleOffset -- 846
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 847
end -- 841
function Play.prototype.nearLowLedge(self, a) -- 852
	local reach = 26 -- 853
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 854
	local x1 = x0 + reach -- 855
	local i = 0 -- 856
	do -- 856
		i = 0 -- 857
		while i < #self.boxes do -- 857
			do -- 857
				local b = self.boxes[i + 1] -- 858
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 858
					goto __continue96 -- 860
				end -- 860
				local rise = b.y1 - a.y -- 862
				if rise > 0 and rise <= LEDGE_RISE then -- 862
					return true -- 864
				end -- 864
			end -- 864
			::__continue96:: -- 864
			i = i + 1 -- 857
		end -- 857
	end -- 857
	return false -- 867
end -- 852
function Play.prototype.stepPlayer(self, a, dt, input) -- 870
	a.depthSpeed = 0 -- 871
	if not a.alive then -- 871
		return -- 873
	end -- 873
	local isChild = self.childMode -- 875
	local lowArch = isChild and self:underLowArch(a) -- 877
	if self:storyLocked() then -- 877
		a.vx = 0 -- 880
		a.crouch = isChild and lowArch -- 881
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 882
		self:fallY(a, dt) -- 883
		return -- 884
	end -- 884
	if not isChild and self.escort.state == "calming" then -- 884
		a.crouch = false -- 888
		a.h = SOLDIER_H -- 889
		a.vx = 0 -- 890
		self:fallY(a, dt) -- 891
		return -- 892
	end -- 892
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 894
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 895
	local nearCover = not isChild and self:nearCover(a) -- 896
	a.covered = nearCover and input.cover.held -- 897
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 899
	if a.rollT > 0 then -- 899
		a.rollT = a.rollT - dt -- 903
		a.vx = a.facing * ROLL_SPEED -- 904
		self:slideX(a, a.vx * dt) -- 905
		self:fallY(a, dt) -- 906
		if a.rollT <= 0 then -- 906
			self:flashSet("翻滚结束", 0.5) -- 908
		end -- 908
		return -- 910
	end -- 910
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 910
		if input.moveX ~= 0 then -- 910
			a.facing = input.moveX > 0 and 1 or -1 -- 915
		end -- 915
		if self:nearLowLedge(a) then -- 915
			a.vy = SOLDIER_JUMP -- 919
			a.onGround = false -- 920
			self:flashSet("翻上去", 0.3) -- 921
			return -- 922
		end -- 922
		a.rollT = ROLL_TIME -- 924
		self:flashSet("翻滚", 0.3) -- 925
		return -- 926
	end -- 926
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 929
	if isChild then -- 929
		if input.cover.held then -- 929
			speed = CHILD_SLOW -- 932
		end -- 932
		if a.crouch then -- 932
			speed = CHILD_SLOW -- 935
		end -- 935
	elseif a.covered then -- 935
		speed = SOLDIER_SPEED * 0.45 -- 938
	end -- 938
	local handsBusy = self.gripping or gripIntent -- 942
	local dir = self.gripping and 0 or input.moveX -- 943
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 944
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 945
	if dir ~= 0 then -- 945
		a.facing = dir > 0 and 1 or -1 -- 947
	end -- 947
	a.vx = dir * speed * diagonal -- 949
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 949
		a.vy = CHILD_JUMP -- 953
		a.onGround = false -- 954
		self:flashSet("跳", 0.25) -- 955
	end -- 955
	local previousDepth = a.depth -- 959
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 960
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 961
	self:slideX(a, a.vx * dt) -- 962
	self:fallY(a, dt) -- 963
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 963
		self:shoot(a) -- 967
	end -- 967
end -- 870
function Play.prototype.stepPartner(self, p, dt) -- 972
	local a = self.partner -- 973
	if not a.alive then -- 973
		return -- 975
	end -- 975
	a.crouch = false -- 977
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 978
	a.vx = 0 -- 979
	a.depthSpeed = 0 -- 980
	self:fallY(a, dt) -- 981
end -- 972
function Play.prototype.stepEscort(self, dt, input) -- 988
	local a = self.partner -- 989
	a.depthSpeed = 0 -- 990
	if not a.alive then -- 990
		return -- 992
	end -- 992
	if not self:escortOn() then -- 992
		a.vx = 0 -- 995
		self:fallY(a, dt) -- 996
		return -- 997
	end -- 997
	local p = self.player -- 999
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1000
	local hadKnock1 = self.escort.knock1 -- 1001
	local hadKnock2 = self.escort.knock2 -- 1002
	self.calmConsumed = self.escort:update( -- 1003
		input, -- 1003
		p.x, -- 1003
		p.facing, -- 1003
		a.x, -- 1003
		dist -- 1003
	) -- 1003
	if not hadKnock1 and self.escort.knock1 then -- 1003
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1006
	end -- 1006
	if not hadKnock2 and self.escort.knock2 then -- 1006
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1009
	end -- 1009
	a.crouch = self.escort.crouchPose -- 1011
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1012
	if not self.escort.stopped then -- 1012
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1014
		local previousDepth = a.depth -- 1015
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1016
		local distance = math.max( -- 1017
			-travel, -- 1017
			math.min(travel, targetDepth - previousDepth) -- 1017
		) -- 1017
		self:slideDepth(a, distance) -- 1018
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1019
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1019
			a.vy = CHILD_JUMP -- 1021
			a.onGround = false -- 1022
		end -- 1022
	end -- 1022
	local dir = self.escort:moveDir(a.x) -- 1025
	a.vx = dir * CHILD_SPEED -- 1026
	if dir ~= 0 then -- 1026
		a.facing = dir -- 1028
		local before = a.x -- 1029
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1030
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1030
			a.vy = CHILD_JUMP -- 1033
			a.onGround = false -- 1034
		end -- 1034
	end -- 1034
	self:fallY(a, dt) -- 1037
end -- 988
function Play.prototype.escortOn(self) -- 1041
	if self.room.key == "checkpoint" then -- 1041
		return true -- 1043
	end -- 1043
	if self.room.key == "prologue" then -- 1043
		return self.phase == "prologue-follow" -- 1046
	end -- 1046
	return self.room.key == "street" -- 1048
end -- 1041
function Play.prototype.storyLocked(self) -- 1052
	if self.caughtT > 0 then -- 1052
		return true -- 1054
	end -- 1054
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1054
		return true -- 1057
	end -- 1057
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1057
		return true -- 1060
	end -- 1060
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1060
		return true -- 1063
	end -- 1063
	return false -- 1065
end -- 1052
function Play.prototype.swapToChild(self, x) -- 1069
	local tmp = self.player -- 1070
	self.player = self.partner -- 1071
	self.partner = tmp -- 1072
	self.childMode = true -- 1073
	self.player.alive = true -- 1074
	self.player.x = self.ox + x -- 1075
	self.player.y = 0 -- 1076
	self.player.depth = 0 -- 1077
	self.player.depthSpeed = 0 -- 1078
	self.player.vy = 0 -- 1079
	self.player.vx = 0 -- 1080
	self.player.onGround = true -- 1081
	self.player.crouch = false -- 1082
	self.player.h = CHILD_H -- 1083
	self.player.facing = 1 -- 1084
	self.partner.alive = true -- 1085
	self.cam.x = self.player.x -- 1086
end -- 1069
function Play.prototype.stepStory(self, dt, input) -- 1090
	if self.room.key == "prologue" then -- 1090
		self:stepPrologue(dt, input) -- 1092
	elseif self.room.key == "street" then -- 1092
		self:stepStreet(dt, input) -- 1094
	elseif self.room.key == "gate" then -- 1094
		self:stepGate(dt, input) -- 1096
	elseif self.room.key == "tower" then -- 1096
		self:stepTower(dt, input) -- 1098
	end -- 1098
end -- 1090
function Play.prototype.stepPrologue(self, dt, input) -- 1103
	local child = self.partner -- 1104
	if self.phase == "prologue-wait" then -- 1104
		child.crouch = true -- 1106
		child.h = CHILD_CROUCH_H -- 1107
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1108
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1110
		if near and input.interact.pressed then -- 1110
			self.phase = "prologue-give" -- 1112
			self.phaseTick = 0 -- 1113
			self:flashSet("递出针套", 1) -- 1114
		end -- 1114
		return -- 1116
	end -- 1116
	if self.phase == "prologue-give" then -- 1116
		self.phaseTick = self.phaseTick + 1 -- 1119
		if self.phaseTick == 12 then -- 1119
			self:flashSet("针套递过去", 0.7) -- 1121
		elseif self.phaseTick == 36 then -- 1121
			self:flashSet("纸条塞进针套", 0.9) -- 1123
		elseif self.phaseTick >= 60 then -- 1123
			self.phase = "prologue-follow" -- 1125
			self.phaseTick = 0 -- 1126
			child.crouch = false -- 1127
			child.h = CHILD_H -- 1128
			self:flashSet("她跟上了", 1.2) -- 1129
		end -- 1129
		return -- 1131
	end -- 1131
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1131
		self:requestRoom("street", "序章跟到门口") -- 1135
		self:flashSet("进街道", 1.2) -- 1136
	end -- 1136
end -- 1103
function Play.prototype.stepStreet(self, dt, input) -- 1141
	local p = self.player -- 1142
	local c = self.partner -- 1143
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1143
		self:requestRoom("checkpoint", "两人都到街尾") -- 1145
		self:flashSet("到检查站", 1.2) -- 1146
	end -- 1146
end -- 1141
function Play.prototype.stepGate(self, dt, input) -- 1151
	local ____temp_27 -- 1152
	if self.room.story == nil then -- 1152
		____temp_27 = nil -- 1152
	else -- 1152
		____temp_27 = self.room.story.gate -- 1152
	end -- 1152
	local g = ____temp_27 -- 1152
	if g == nil then -- 1152
		return -- 1154
	end -- 1154
	local p = self.player -- 1156
	if self.phase == "gate-idle" then -- 1156
		local a = self.partner -- 1159
		local gap = g.waitX - a.x -- 1160
		if math.abs(gap) > 3 then -- 1160
			a.facing = gap > 0 and 1 or -1 -- 1162
			a.vx = a.facing * CHILD_SPEED -- 1163
			local beforeX = a.x -- 1164
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1165
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1165
				a.vy = CHILD_JUMP -- 1167
				a.onGround = false -- 1168
			end -- 1168
			self:fallY(a, dt) -- 1170
		else -- 1170
			a.vx = 0 -- 1172
			a.x = g.waitX -- 1173
		end -- 1173
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1176
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1177
		if self.gateNeedConfirm then -- 1177
			if not input.interact.held then -- 1177
				self.gateRestartArmed = true -- 1182
			end -- 1182
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1182
				self.gateNeedConfirm = false -- 1185
				self.gateRestartArmed = true -- 1186
				self.phase = "gate-hold" -- 1187
				self.gateTick = 0 -- 1188
				self.gateSpawned = 0 -- 1189
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1190
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1191
			end -- 1191
			return -- 1193
		end -- 1193
		if atWinch and atWait then -- 1193
			self.phase = "gate-hold" -- 1196
			self.gateTick = 0 -- 1197
			self.gateSpawned = 0 -- 1198
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1199
		end -- 1199
		return -- 1201
	end -- 1201
	if self.phase == "gate-hold" then -- 1201
		self.gateTick = self.gateTick + 1 -- 1204
		local marks = {0, 540, 900, 1500} -- 1206
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1206
			local idx = self.gateSpawned -- 1208
			local ____self_enemies_28 = self.enemies -- 1208
			____self_enemies_28[#____self_enemies_28 + 1] = { -- 1209
				x = self.ox + 620 + idx * 62, -- 1210
				y = 0, -- 1210
				w = 26, -- 1210
				h = 84, -- 1210
				alive = true, -- 1211
				hitT = 0, -- 1211
				warnT = 0, -- 1211
				fireCd = 90 + idx * 45 -- 1211
			} -- 1211
			self.gateSpawned = self.gateSpawned + 1 -- 1213
			self:flashSet( -- 1214
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1214
				0.9 -- 1214
			) -- 1214
		end -- 1214
		if self.gateTick == 900 then -- 1214
			self:flashSet("灯灭了", 1) -- 1217
		elseif self.gateTick == 2100 then -- 1217
			self:flashSet("门底压下来了", 1) -- 1219
		end -- 1219
		if self.gateTick >= g.holdTicks then -- 1219
			self.phase = "gate-send" -- 1222
			self.phaseTick = 0 -- 1223
			self.enemies = {} -- 1225
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1226
		end -- 1226
		return -- 1228
	end -- 1228
	if self.phase == "gate-send" then -- 1228
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1231
		if near and input.interact.pressed then -- 1231
			self:swapToChild(g.doorX + 30) -- 1233
			self.phase = "gate-count" -- 1234
			self.countTick = 0 -- 1235
			self.countArmed = false -- 1237
			self.countPrevMove = input.moveX -- 1238
			self:flashSet("门开了 · 送她出去", 1.8) -- 1239
		end -- 1239
		return -- 1241
	end -- 1241
	if self.phase == "gate-count" then -- 1241
		self.countTick = self.countTick + 1 -- 1244
		if self.countTick == 360 then -- 1244
			self:flashSet("门关上", 0.9) -- 1246
		elseif self.countTick == 1020 then -- 1246
			self:flashSet("数到一百", 2.2) -- 1248
		end -- 1248
		local prevMove = self.countPrevMove -- 1252
		self.countPrevMove = input.moveX -- 1253
		if self.countTick >= 1440 then -- 1253
			if prevMove <= 0 and input.moveX > 0 then -- 1253
				self.countArmed = true -- 1256
			end -- 1256
			if self.countArmed and input.moveX > 0 then -- 1256
				self.phase = "gate-walk" -- 1259
				self.phaseTick = 0 -- 1260
				self:flashSet("她迈出第一步", 1.4) -- 1261
			end -- 1261
		end -- 1261
		return -- 1264
	end -- 1264
	if self.player.x >= g.exitX then -- 1264
		self:requestRoom("outside", "走出城门") -- 1268
		self:flashSet("出城门 · 城外", 1.4) -- 1269
	end -- 1269
end -- 1151
function Play.prototype.stepTower(self, dt, input) -- 1274
	local ____temp_29 -- 1275
	if self.room.story == nil then -- 1275
		____temp_29 = nil -- 1275
	else -- 1275
		____temp_29 = self.room.story.tower -- 1275
	end -- 1275
	local t = ____temp_29 -- 1275
	if t == nil then -- 1275
		return -- 1277
	end -- 1277
	if self.phase == "tower-wait" then -- 1277
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1280
		if near and input.interact.pressed then -- 1280
			self.phase = "tower-knock" -- 1282
			self.phaseTick = 0 -- 1283
			self.knocks = 1 -- 1284
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1285
			self:flashSet("敲一下", 0.6) -- 1286
		end -- 1286
		return -- 1288
	end -- 1288
	if self.phase == "tower-knock" then -- 1288
		self.phaseTick = self.phaseTick + 1 -- 1291
		if self.phaseTick == 12 then -- 1291
			self.knocks = 2 -- 1293
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1294
			self:flashSet("敲两下 · 第二声", 1) -- 1295
		elseif self.phaseTick >= t.knockTicks then -- 1295
			self.phase = "tower-given" -- 1297
			self.phaseTick = 0 -- 1298
			self:flashSet("门开了 · 提灯", 1.4) -- 1299
		end -- 1299
		return -- 1301
	end -- 1301
	if self.phase == "tower-given" then -- 1301
		self.phaseTick = self.phaseTick + 1 -- 1304
		if self.phaseTick == 60 then -- 1304
			self:flashSet("她递出针套和纸条", 1.6) -- 1306
		elseif self.phaseTick == 120 then -- 1306
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1308
		elseif self.phaseTick >= 180 then -- 1308
			self.phase = "tower-end" -- 1310
			self.phaseTick = 0 -- 1311
			self:flashSet("片尾 · E 再玩一次", 3) -- 1312
		end -- 1312
		return -- 1314
	end -- 1314
	if input.interact.pressed or input.retry.pressed then -- 1314
		self:requestRoom("prologue", "片尾再玩") -- 1317
		self:flashSet("回到序章", 1.4) -- 1318
	end -- 1318
end -- 1274
function Play.prototype.stepChase(self, dt, input) -- 1323
	if self.caughtT > 0 then -- 1323
		self.caughtT = self.caughtT - dt -- 1325
		if self.caughtT <= 0 then -- 1325
			self:recoverFromCaught() -- 1327
		end -- 1327
		return -- 1329
	end -- 1329
	if self.room.key == "village" then -- 1329
		self:stepScavChase() -- 1332
	elseif self.room.key == "forest" then -- 1332
		self:stepDog(dt) -- 1334
		if self.player.x >= self.ox + 1450 then -- 1334
			self:requestRoom("tower", "到林缘北塔") -- 1337
			self:flashSet("林缘 · 北塔", 1.4) -- 1338
		end -- 1338
	end -- 1338
end -- 1323
function Play.prototype.stepScavChase(self) -- 1344
	local s = self.room.scavenger -- 1345
	if s == nil then -- 1345
		return -- 1347
	end -- 1347
	local p = self.player -- 1349
	if self.passed and p.x > self.ox + 440 then -- 1349
		if self.scavChase then -- 1349
			self.scavChase = false -- 1353
			self.scavState = "back" -- 1354
			self.scavT = 0 -- 1355
		end -- 1355
		return -- 1357
	end -- 1357
	local dx = p.x - self.scavX -- 1359
	local dist = math.abs(dx) -- 1360
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1361
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1362
	if not self.scavChase then -- 1362
		if visible then -- 1362
			self.scavSee = self.scavSee + 1 -- 1365
			if self.scavSee >= 24 then -- 1365
				self.scavChase = true -- 1367
				self.scavState = "chase" -- 1368
				self.scavTargetX = p.x -- 1369
				self:flashSet("他看见你了", 1.2) -- 1370
			end -- 1370
		else -- 1370
			self.scavSee = 0 -- 1373
		end -- 1373
		return -- 1375
	end -- 1375
	local dir = p.x > self.scavX and 1 or -1 -- 1378
	self.scavX = self.scavX + dir * 96 / 60 -- 1379
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1379
		self:caught() -- 1381
		return -- 1382
	end -- 1382
	if hidden then -- 1382
		self.scavSee = 0 -- 1386
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1387
		self.scavT = self.scavT - 1 -- 1388
		if self.scavT <= 0 then -- 1388
			self.scavChase = false -- 1390
			self.scavState = "patrol" -- 1391
			self:flashSet("他失去了目标", 1) -- 1392
		end -- 1392
	end -- 1392
end -- 1344
function Play.prototype.stepDog(self, dt) -- 1398
	local ____temp_30 -- 1399
	if self.room.story == nil then -- 1399
		____temp_30 = nil -- 1399
	else -- 1399
		____temp_30 = self.room.story.dog -- 1399
	end -- 1399
	local dog = ____temp_30 -- 1399
	if dog == nil then -- 1399
		return -- 1401
	end -- 1401
	local p = self.player -- 1403
	local dist = math.abs(p.x - self.dogX) -- 1404
	if self.dogState == "patrol" then -- 1404
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1406
		if self.dogX < dog.x0 then -- 1406
			self.dogX = dog.x0 -- 1408
			self.dogDir = 1 -- 1409
		elseif self.dogX > dog.x1 then -- 1409
			self.dogX = dog.x1 -- 1411
			self.dogDir = -1 -- 1412
		end -- 1412
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1414
		if not p.crouch and moving and dist < dog.range then -- 1414
			self.dogState = "ear" -- 1416
			self.dogT = 18 -- 1417
			self.dogTargetX = p.x -- 1418
			self:flashSet("狗转耳朵", 0.8) -- 1419
		end -- 1419
		return -- 1421
	end -- 1421
	if self.dogState == "ear" then -- 1421
		self.dogT = self.dogT - 1 -- 1424
		if self.dogT <= 0 then -- 1424
			self.dogState = "chase" -- 1426
			self.dogTargetX = p.x -- 1427
			self:flashSet("狗追来了", 1.4) -- 1428
		end -- 1428
		return -- 1430
	end -- 1430
	if self.dogState == "chase" then -- 1430
		local dir = p.x > self.dogX and 1 or -1 -- 1433
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1434
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1434
			self:caught() -- 1436
			self.dogState = "sniff" -- 1437
			self.dogT = 60 -- 1438
		elseif dist > dog.range * 1.5 or p.crouch then -- 1438
			self.dogState = "sniff" -- 1440
			self.dogT = 60 -- 1441
			self:flashSet("狗停下了", 0.9) -- 1442
		end -- 1442
		return -- 1444
	end -- 1444
	if self.dogState == "sniff" then -- 1444
		self.dogT = self.dogT - 1 -- 1447
		if self.dogT <= 0 then -- 1447
			self.dogState = "back" -- 1449
		end -- 1449
		return -- 1451
	end -- 1451
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1454
	self.dogX = self.dogX + dir * dog.speed * dt -- 1455
	if math.abs(self.dogX - dog.x0) < 2 then -- 1455
		self.dogX = dog.x0 -- 1457
		self.dogState = "patrol" -- 1458
	end -- 1458
end -- 1398
function Play.prototype.caught(self) -- 1462
	self.caughtT = 1 -- 1463
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1464
end -- 1462
function Play.prototype.recoverFromCaught(self) -- 1468
	local p = self.player -- 1469
	p.x = self.ox + 140 -- 1470
	p.y = 0 -- 1471
	p.vy = 0 -- 1472
	p.vx = 0 -- 1473
	p.onGround = true -- 1474
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1474
		self.scavX = self.room.scavenger.x0 -- 1476
		self.scavState = "patrol" -- 1477
		self.scavSee = 0 -- 1478
		self.scavChase = false -- 1479
		self.scavT = 0 -- 1480
	end -- 1480
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1480
		self.dogX = self.room.story.dog.x0 -- 1483
		self.dogState = "patrol" -- 1484
		self.dogT = 0 -- 1485
	end -- 1485
	self.cam.x = p.x -- 1487
	self.cam.y = p.y + CAM_LOOK_UP -- 1488
	self:flashSet("回到安全点", 1.2) -- 1489
end -- 1468
function Play.prototype.updateGate(self) -- 1493
	if self.room.key ~= "checkpoint" then -- 1493
		self.gateOpen = false -- 1495
		return -- 1496
	end -- 1496
	local function inZone(x) -- 1498
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1498
	end -- 1498
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1499
end -- 1493
function Play.prototype.addItem(self, kind) -- 1505
	local inv = self.run.inventory -- 1506
	if kind == "shield" then -- 1506
		inv.shield = inv.shield + 1 -- 1508
	elseif kind == "wedge" then -- 1508
		inv.wedge = inv.wedge + 1 -- 1510
	elseif kind == "ammo" then -- 1510
		inv.ammo = inv.ammo + 1 -- 1512
	elseif kind == "pass" then -- 1512
		inv.pass = inv.pass + 1 -- 1514
	elseif kind == "quickbelt" then -- 1514
		inv.quickbelt = inv.quickbelt + 1 -- 1516
	end -- 1516
end -- 1505
function Play.prototype.findBox(self, id) -- 1520
	local i = 0 -- 1521
	do -- 1521
		i = 0 -- 1522
		while i < #self.boxes do -- 1522
			if self.boxes[i + 1].id == id then -- 1522
				return self.boxes[i + 1] -- 1524
			end -- 1524
			i = i + 1 -- 1522
		end -- 1522
	end -- 1522
	return nil -- 1527
end -- 1520
function Play.prototype.nearBox(self, b, reach) -- 1530
	local p = self.player -- 1531
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1532
end -- 1530
function Play.prototype.findInteract(self) -- 1538
	local p = self.player -- 1539
	local best = nil -- 1540
	local bestD = 1000000000 -- 1541
	local i = 0 -- 1542
	do -- 1542
		i = 0 -- 1543
		while i < #self.boxes do -- 1543
			do -- 1543
				local b = self.boxes[i + 1] -- 1544
				if b.interact == nil or b.broken == true then -- 1544
					goto __continue237 -- 1546
				end -- 1546
				if not self:nearBox(b, b.interact.reach or 27) then -- 1546
					goto __continue237 -- 1549
				end -- 1549
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1551
				if d < bestD then -- 1551
					bestD = d -- 1553
					best = b -- 1554
				end -- 1554
			end -- 1554
			::__continue237:: -- 1554
			i = i + 1 -- 1543
		end -- 1543
	end -- 1543
	return best -- 1557
end -- 1538
function Play.prototype.stepCampaign(self, dt, input) -- 1561
	local wr = self.room -- 1562
	local p = self.player -- 1563
	if self.reloadT > 0 then -- 1563
		self.reloadT = self.reloadT - 1 -- 1565
	end -- 1565
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1565
		self.run.route = "drygoods" -- 1570
		self.run.joined = false -- 1571
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1572
		self:log("转布行线") -- 1573
	end -- 1573
	local i = 0 -- 1576
	do -- 1576
		i = 0 -- 1577
		while i < #self.pickups do -- 1577
			do -- 1577
				local pk = self.pickups[i + 1] -- 1578
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1578
					goto __continue245 -- 1580
				end -- 1580
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1582
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1583
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1583
					self.run.taken[pk.id] = true -- 1585
					self:addItem(pk.kind) -- 1586
					pk.id = "" -- 1587
					self:flashSet("拾取 " .. pk.label, 1) -- 1588
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1589
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1590
				end -- 1590
			end -- 1590
			::__continue245:: -- 1590
			i = i + 1 -- 1577
		end -- 1577
	end -- 1577
	if input.interact.pressed then -- 1577
		self:campaignInteract() -- 1594
	end -- 1594
	self:stepCampaignCart(dt, input) -- 1596
	self:stepCampaignGoal() -- 1597
end -- 1561
function Play.prototype.campaignInteract(self) -- 1601
	local b = self:findInteract() -- 1602
	if b ~= nil then -- 1602
		self:useInteract(b) -- 1604
		return -- 1605
	end -- 1605
	local inv = self.run.inventory -- 1607
	if inv.wedge > 0 then -- 1607
		local w = self:findBox("s2_wood") -- 1609
		if w ~= nil and w.broken ~= true and self:nearBox(w, 26) then -- 1609
			if w.breakable ~= nil then -- 1609
				local ____w_breakable_31, ____hp_32 = w.breakable, "hp" -- 1609
				____w_breakable_31[____hp_32] = ____w_breakable_31[____hp_32] + (w.breakable.wedgeHp or 1) -- 1612
			end -- 1612
			inv.wedge = inv.wedge - 1 -- 1614
			self.run.props.s2_wood = {broken = false, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1615
			self:flashSet("钉木楔 · 薄木挡多承一次", 1.2) -- 1616
			self:log("加固薄木挡") -- 1617
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1618
			return -- 1619
		end -- 1619
	end -- 1619
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1619
		local p = self.player -- 1624
		self.bracedShield = { -- 1625
			x = p.x + p.facing * 26, -- 1625
			y = p.y, -- 1625
			w = 30, -- 1625
			h = 64, -- 1625
			hp = 1 -- 1625
		} -- 1625
		local ____self_boxes_33 = self.boxes -- 1625
		____self_boxes_33[#____self_boxes_33 + 1] = { -- 1626
			x0 = self.bracedShield.x - 15, -- 1627
			x1 = self.bracedShield.x + 15, -- 1627
			y0 = p.y, -- 1628
			y1 = p.y + 64, -- 1628
			depth = {min = -46, max = 46}, -- 1628
			label = "架起的残盾", -- 1628
			id = "braced_shield" -- 1628
		} -- 1628
		inv.shield = inv.shield - 1 -- 1630
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1631
		self:log("架残盾") -- 1632
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1633
		return -- 1634
	end -- 1634
	if inv.pass > 0 and self.run.joined == false then -- 1634
		inv.pass = inv.pass - 1 -- 1637
		self.run.joined = true -- 1638
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1639
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1640
		return -- 1641
	end -- 1641
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1643
end -- 1601
function Play.prototype.useInteract(self, b) -- 1646
	local kind = b.interact == nil and "" or b.interact.kind -- 1647
	local wr = self.room -- 1648
	if kind == "open_board" then -- 1648
		b.broken = true -- 1650
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1651
		for ____, cover in ipairs(self.boxes) do -- 1652
			if cover.id == "s2_board_cover" then -- 1652
				cover.broken = false -- 1654
				cover.hidden = false -- 1655
			end -- 1655
		end -- 1655
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1658
		self.run.joined = true -- 1659
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1660
		self:log("放下窗板") -- 1661
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1662
		return -- 1663
	end -- 1663
	if kind == "lower_curtain" then -- 1663
		for ____, curtain in ipairs(self.boxes) do -- 1666
			if curtain.id == "c2_curtain" then -- 1666
				curtain.broken = false -- 1668
				curtain.hidden = false -- 1669
			end -- 1669
		end -- 1669
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1672
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1673
		self:log("放下木帘") -- 1674
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1675
		return -- 1676
	end -- 1676
	if kind == "raise_latch" then -- 1676
		if wr.key == "c2-granary" and not self.cartDocked then -- 1676
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1680
			return -- 1681
		end -- 1681
		b.broken = true -- 1683
		self.run.latchOpen = true -- 1684
		self.objectiveDone = true -- 1685
		if wr.key == "c1-yard" then -- 1685
			self.run.joined = true -- 1688
		end -- 1688
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1690
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1691
		self:log("抬闩") -- 1692
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1693
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1694
	end -- 1694
end -- 1646
function Play.prototype.stepCampaignCart(self, dt, input) -- 1699
	local wr = self.room -- 1700
	local c = wr.cart -- 1701
	if c.bodyW <= 0 then -- 1701
		return -- 1703
	end -- 1703
	local p = self.player -- 1705
	local handleX = self.cartAxle + c.handleOffset -- 1706
	if not self.gripping then -- 1706
		if input.interact.pressed and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1706
			self.gripping = true -- 1710
			self:flashSet("握住车柄 · A/D 推", 1) -- 1711
		end -- 1711
		return -- 1713
	end -- 1713
	if input.interact.pressed then -- 1713
		self.gripping = false -- 1716
		self:flashSet("松手", 0.5) -- 1717
		return -- 1718
	end -- 1718
	if not self.cartDocked then -- 1718
		if input.moveX ~= 0 and not self:stuckCart() then -- 1718
			self.cartAxle = math.max( -- 1722
				c.startX, -- 1722
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1722
			) -- 1722
		end -- 1722
		p.x = self.cartAxle + c.handleOffset -- 1724
		p.y = c.baseY + (c.depth or 0) -- 1725
		p.vx = 0 -- 1726
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1726
			self.cartAxle = c.endX -- 1728
			self.cartDocked = true -- 1729
			self.gripping = false -- 1730
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1731
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1732
			self:flashSet("车轮入窝", 1.2) -- 1733
			self:log("车轮入窝") -- 1734
		end -- 1734
	end -- 1734
end -- 1699
function Play.prototype.stuckCart(self) -- 1740
	local i = 0 -- 1741
	do -- 1741
		i = 0 -- 1742
		while i < #self.boxes do -- 1742
			do -- 1742
				local b = self.boxes[i + 1] -- 1743
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1743
					goto __continue278 -- 1745
				end -- 1745
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1747
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1747
					return true -- 1749
				end -- 1749
			end -- 1749
			::__continue278:: -- 1749
			i = i + 1 -- 1742
		end -- 1742
	end -- 1742
	return false -- 1752
end -- 1740
function Play.prototype.stepCampaignGoal(self) -- 1756
	local wr = self.room -- 1757
	local c = wr.campaign -- 1758
	if c == nil then -- 1758
		return -- 1760
	end -- 1760
	if wr.key == "c2-granary" and self.cartDocked and self.run.latchOpen == true then -- 1760
		self.objectiveDone = true -- 1763
	end -- 1763
	if c.goal == "reach_exit" then -- 1763
		self.objectiveDone = true -- 1766
	end -- 1766
	if not self.objectiveDone then -- 1766
		return -- 1769
	end -- 1769
	local p = self.player -- 1771
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1772
	if p.x < c.exitX or not partnerOk then -- 1772
		return -- 1774
	end -- 1774
	if c.next ~= nil and c.next ~= "" then -- 1774
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1777
		self:flashSet("过关 · " .. c.next, 1.2) -- 1778
	elseif not self.run.finished then -- 1778
		self.run.finished = true -- 1780
		self:flashSet( -- 1781
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1781
			2 -- 1781
		) -- 1781
		self:log("C2 灰盒完成") -- 1782
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1783
	end -- 1783
end -- 1756
function Play.prototype.stepCampaignPartner(self, dt) -- 1788
	local a = self.partner -- 1789
	local wr = self.room -- 1790
	local cp = wr.companion -- 1791
	if not a.alive then -- 1791
		return -- 1793
	end -- 1793
	local p = self.player -- 1795
	local wait = false -- 1796
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1797
	local targetDepth = p.depth -- 1798
	if self.run.joined == false then -- 1798
		wait = true -- 1800
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1801
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1802
	elseif wr.key == "c1-yard" and not self.run.latchOpen then -- 1802
		wait = true -- 1804
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1805
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1806
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1806
		wait = true -- 1808
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1809
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1810
	end -- 1810
	if self.partnerStuck > 0.3 then -- 1810
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1814
		self.partnerLaneHold = 1.1 -- 1815
		self.partnerStuck = 0 -- 1816
	end -- 1816
	if self.partnerLaneHold > 0 then -- 1816
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1819
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1820
	end -- 1820
	local dx = targetX - a.x -- 1822
	if not wait and math.abs(dx) > 74 then -- 1822
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1824
		local before = a.x -- 1825
		a.vx = dx > 0 and speed or -speed -- 1826
		a.facing = dx > 0 and 1 or -1 -- 1827
		self:slideX(a, a.vx * dt) -- 1828
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1828
			a.vy = CHILD_JUMP -- 1831
			a.onGround = false -- 1832
		end -- 1832
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1834
	else -- 1834
		a.vx = 0 -- 1836
		self.partnerStuck = 0 -- 1837
	end -- 1837
	local dz = targetDepth - a.depth -- 1839
	if math.abs(dz) > 6 then -- 1839
		local step = math.max( -- 1841
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1841
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1841
		) -- 1841
		a.depth = a.depth + step -- 1842
	end -- 1842
	a.depthSpeed = 0 -- 1844
	a.h = CHILD_H -- 1845
	a.crouch = false -- 1846
	self:fallY(a, dt) -- 1847
end -- 1788
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 1851
	local p = self.player -- 1852
	local i = 0 -- 1853
	do -- 1853
		i = 0 -- 1854
		while i < #self.enemies do -- 1854
			do -- 1854
				local e = self.enemies[i + 1] -- 1855
				if not e.alive then -- 1855
					goto __continue302 -- 1857
				end -- 1857
				if e.hitT > 0 then -- 1857
					e.hitT = e.hitT - dt -- 1860
				end -- 1860
				if e.kind == "breaker" then -- 1860
					self:stepBreaker(e, dt) -- 1863
					goto __continue302 -- 1864
				end -- 1864
				if e.kind == "shield" then -- 1864
					self:stepShield(e, dt, input) -- 1867
					goto __continue302 -- 1868
				end -- 1868
				local dx = e.x - p.x -- 1871
				if not e.awake then -- 1871
					if math.abs(dx) > 520 then -- 1871
						goto __continue302 -- 1874
					end -- 1874
					e.awake = true -- 1876
					e.fireCd = 48 -- 1877
					goto __continue302 -- 1878
				end -- 1878
				if math.abs(dx) > ENEMY_RANGE then -- 1878
					goto __continue302 -- 1881
				end -- 1881
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 1881
					goto __continue302 -- 1884
				end -- 1884
				if self:blockedShot(e, p) then -- 1884
					goto __continue302 -- 1887
				end -- 1887
				if e.warnT > 0 then -- 1887
					e.warnT = e.warnT - 1 -- 1890
					if e.warnT <= 0 then -- 1890
						self:campaignEnemyFire(e) -- 1892
					end -- 1892
				elseif e.fireCd > 0 then -- 1892
					e.fireCd = e.fireCd - 1 -- 1895
					if e.fireCd <= 0 then -- 1895
						e.warnT = WARN_TICKS -- 1897
					end -- 1897
				else -- 1897
					e.fireCd = 40 -- 1900
				end -- 1900
			end -- 1900
			::__continue302:: -- 1900
			i = i + 1 -- 1854
		end -- 1854
	end -- 1854
end -- 1851
function Play.prototype.blockedShot(self, e, p) -- 1906
	local ex = e.x -- 1907
	local ey = e.y + (e.depth or 0) + e.h * 0.62 -- 1908
	local px = p.x -- 1909
	local py = p.y + p.depth + p.h * 0.55 -- 1910
	local dx = px - ex -- 1911
	local dy = py - ey -- 1912
	local len = math.sqrt(dx * dx + dy * dy) -- 1913
	if len < 0.01 then -- 1913
		return false -- 1915
	end -- 1915
	local ray = {x = ex, y = ey, dx = dx / len, dy = dy / len} -- 1917
	local best = -1 -- 1918
	local j = 0 -- 1919
	do -- 1919
		j = 0 -- 1920
		while j < #self.boxes do -- 1920
			do -- 1920
				local b = self.boxes[j + 1] -- 1921
				if b.broken == true or b.passable == true then -- 1921
					goto __continue320 -- 1923
				end -- 1923
				if not overlapsDepth(e.depth or 0, b.depth, ACTOR_DEPTH_HALF) then -- 1923
					goto __continue320 -- 1926
				end -- 1926
				local t = hitBox(ray, b) -- 1928
				if t >= 0 and t < len - 2 and (best < 0 or t < best) then -- 1928
					best = t -- 1930
				end -- 1930
			end -- 1930
			::__continue320:: -- 1930
			j = j + 1 -- 1920
		end -- 1920
	end -- 1920
	return best >= 0 -- 1933
end -- 1906
function Play.prototype.campaignEnemyFire(self, e) -- 1936
	local p = self.player -- 1937
	e.fireCd = FIRE_COOLDOWN -- 1938
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 1938
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 1938
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 1940
		self.boxes = __TS__ArrayFilter( -- 1941
			self.boxes, -- 1941
			function(____, b) return b.id ~= "braced_shield" end -- 1941
		) -- 1941
		self.bracedShield = nil -- 1942
		self:flashSet("残盾碎 · 挡下一发", 1) -- 1943
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 1944
		return -- 1945
	end -- 1945
	local cover = self:blockedByCover(e, p) -- 1947
	if cover ~= nil and self.coverHug then -- 1947
		self.coveredFlash = 0.5 -- 1949
		self:flashSet("掩体挡下", 0.6) -- 1950
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 1951
		return -- 1956
	end -- 1956
	if self.invulnT > 0 then -- 1956
		return -- 1959
	end -- 1959
	self.invulnT = 0.7 -- 1961
	self.hp = self.hp - 1 -- 1962
	self:emit("actorHit", { -- 1963
		target = "player", -- 1963
		amount = 1, -- 1963
		hp = self.hp, -- 1963
		maxHp = self.maxHp, -- 1963
		enemyX = e.x -- 1963
	}) -- 1963
	self:flashSet( -- 1964
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1964
		0.8 -- 1964
	) -- 1964
	if self.hp <= 0 then -- 1964
		self:campaignFailed() -- 1966
	end -- 1966
end -- 1936
function Play.prototype.stepShield(self, e, dt, input) -- 1971
	local p = self.player -- 1972
	local dx = p.x - e.x -- 1973
	local adx = math.abs(dx) -- 1974
	if adx > 150 then -- 1974
		local before = e.x -- 1976
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 1977
		if math.abs(e.x - before) < 0.3 then -- 1977
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 1980
		end -- 1980
	elseif adx < 48 and (e.swingT or 0) <= 0 then -- 1980
		if p.rollT <= 0 and self.invulnT <= 0 then -- 1980
			self.invulnT = 0.7 -- 1984
			self.hp = self.hp - 1 -- 1985
			self:emit("actorHit", { -- 1986
				target = "player", -- 1986
				amount = 1, -- 1986
				hp = self.hp, -- 1986
				maxHp = self.maxHp, -- 1986
				enemyX = e.x -- 1986
			}) -- 1986
			self:flashSet( -- 1987
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 1987
				0.8 -- 1987
			) -- 1987
			if self.hp <= 0 then -- 1987
				self:campaignFailed() -- 1989
				return -- 1990
			end -- 1990
		end -- 1990
		e.swingT = 70 -- 1993
	end -- 1993
	if (e.swingT or 0) > 0 then -- 1993
		e.swingT = (e.swingT or 0) - 1 -- 1996
	end -- 1996
	if math.abs((e.depth or 0) - p.depth) > 20 then -- 1996
		local dd = p.depth - (e.depth or 0) -- 1999
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2000
	end -- 2000
end -- 1971
function Play.prototype.stepBreaker(self, e, dt) -- 2005
	local p = self.player -- 2006
	if e.awake ~= true then -- 2006
		if math.abs(p.x - e.x) < 560 then -- 2006
			e.awake = true -- 2009
		else -- 2009
			return -- 2011
		end -- 2011
	end -- 2011
	local target = nil -- 2014
	local bestD = 1000000000 -- 2015
	local i = 0 -- 2016
	do -- 2016
		i = 0 -- 2017
		while i < #self.boxes do -- 2017
			do -- 2017
				local b = self.boxes[i + 1] -- 2018
				if b.breakable == nil or b.broken == true then -- 2018
					goto __continue343 -- 2020
				end -- 2020
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2022
				if d < bestD then -- 2022
					bestD = d -- 2024
					target = b -- 2025
				end -- 2025
			end -- 2025
			::__continue343:: -- 2025
			i = i + 1 -- 2017
		end -- 2017
	end -- 2017
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2028
	local dx = tx - e.x -- 2029
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2030
	if math.abs(dx) > reach then -- 2030
		local before = e.x -- 2032
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2033
		if math.abs(e.x - before) < 0.3 then -- 2033
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2035
		end -- 2035
	elseif (e.swingT or 0) <= 0 then -- 2035
		e.swingT = 64 -- 2038
		if target ~= nil then -- 2038
			self:damageProp(target, 2) -- 2040
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2040
			self.invulnT = 0.7 -- 2042
			self.hp = self.hp - 1 -- 2043
			self:emit("actorHit", { -- 2044
				target = "player", -- 2044
				amount = 1, -- 2044
				hp = self.hp, -- 2044
				maxHp = self.maxHp, -- 2044
				enemyX = e.x -- 2044
			}) -- 2044
			self:flashSet("破障手近身", 0.8) -- 2045
			if self.hp <= 0 then -- 2045
				self:campaignFailed() -- 2047
				return -- 2048
			end -- 2048
		end -- 2048
	end -- 2048
	if (e.swingT or 0) > 0 then -- 2048
		e.swingT = (e.swingT or 0) - 1 -- 2053
	end -- 2053
end -- 2005
function Play.prototype.campaignFailed(self) -- 2057
	local p = self.player -- 2058
	self.hp = self.maxHp -- 2059
	self.invulnT = 1.2 -- 2060
	self.reloadT = 0 -- 2061
	self.gripping = false -- 2062
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2063
	self:log("被击倒") -- 2064
	p.x = self.room.minX + 90 -- 2065
	p.y = 0 -- 2066
	p.depth = 0 -- 2067
	p.vx = 0 -- 2068
	p.vy = 0 -- 2069
	p.onGround = true -- 2070
	p.rollT = 0 -- 2071
	self.partner.x = p.x - 50 -- 2072
	self.partner.y = 0 -- 2073
	self.partner.depth = 0 -- 2074
	self.cam.x = p.x -- 2075
	local i = 0 -- 2076
	do -- 2076
		i = 0 -- 2077
		while i < #self.enemies do -- 2077
			do -- 2077
				local e = self.enemies[i + 1] -- 2078
				if not e.alive then -- 2078
					goto __continue355 -- 2080
				end -- 2080
				e.x = e.homeX == nil and e.x or e.homeX -- 2082
				e.warnT = 0 -- 2083
				e.fireCd = 40 -- 2084
				e.swingT = 0 -- 2085
				e.awake = false -- 2086
			end -- 2086
			::__continue355:: -- 2086
			i = i + 1 -- 2077
		end -- 2077
	end -- 2077
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2088
end -- 2057
function Play.prototype.stepEnemies(self, dt, input) -- 2091
	local i = 0 -- 2092
	do -- 2092
		i = 0 -- 2093
		while i < #self.enemies do -- 2093
			local e = self.enemies[i + 1] -- 2094
			if e.hitT > 0 then -- 2094
				e.hitT = e.hitT - dt -- 2096
			end -- 2096
			i = i + 1 -- 2093
		end -- 2093
	end -- 2093
	if self.coveredFlash > 0 then -- 2093
		self.coveredFlash = self.coveredFlash - dt -- 2100
	end -- 2100
	if self.isCampaign then -- 2100
		self:stepCampaignEnemies(dt, input) -- 2103
		return -- 2104
	end -- 2104
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2104
		return -- 2108
	end -- 2108
	do -- 2108
		i = 0 -- 2110
		while i < #self.enemies do -- 2110
			do -- 2110
				local e = self.enemies[i + 1] -- 2111
				if not e.alive then -- 2111
					goto __continue365 -- 2113
				end -- 2113
				if e.warnT > 0 then -- 2113
					e.warnT = e.warnT - 1 -- 2116
					if e.warnT <= 0 then -- 2116
						self:enemyFire(e, input) -- 2118
					end -- 2118
					goto __continue365 -- 2120
				end -- 2120
				if e.fireCd > 0 then -- 2120
					e.fireCd = e.fireCd - 1 -- 2123
					if e.fireCd <= 0 then -- 2123
						e.warnT = WARN_TICKS -- 2125
					end -- 2125
				else -- 2125
					e.warnT = WARN_TICKS -- 2129
				end -- 2129
			end -- 2129
			::__continue365:: -- 2129
			i = i + 1 -- 2110
		end -- 2110
	end -- 2110
end -- 2091
function Play.prototype.enemyFire(self, e, input) -- 2135
	local p = self.player -- 2136
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2136
		self:flashSet("枪声响在远处", 0.4) -- 2138
		e.fireCd = FIRE_COOLDOWN -- 2139
		return -- 2140
	end -- 2140
	local cover = self:blockedByCover(e, p) -- 2143
	local hugging = cover ~= nil -- 2144
	self.coverBlocking = hugging -- 2145
	local covered = hugging and input.cover.held -- 2146
	if covered then -- 2146
		self.coveredFlash = 0.5 -- 2148
		self:flashSet("掩体挡下", 0.5) -- 2149
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2150
		e.fireCd = FIRE_COOLDOWN -- 2155
		return -- 2156
	end -- 2156
	self.hp = self.hp - 1 -- 2158
	self:emit("actorHit", { -- 2159
		target = "player", -- 2159
		amount = 1, -- 2159
		hp = self.hp, -- 2159
		maxHp = self.maxHp, -- 2159
		enemyX = e.x -- 2159
	}) -- 2159
	self:flashSet( -- 2160
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2160
		0.7 -- 2160
	) -- 2160
	e.fireCd = FIRE_COOLDOWN -- 2161
	if self.hp <= 0 then -- 2161
		self:gateFailed() -- 2163
	end -- 2163
end -- 2135
function Play.prototype.blockedByCover(self, enemy, p) -- 2168
	local b = self:coverAt(p) -- 2169
	if b == nil then -- 2169
		return nil -- 2171
	end -- 2171
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2173
end -- 2168
function Play.prototype.gateFailed(self) -- 2177
	local ____temp_36 -- 2178
	if self.room.story == nil then -- 2178
		____temp_36 = nil -- 2178
	else -- 2178
		____temp_36 = self.room.story.gate -- 2178
	end -- 2178
	local g = ____temp_36 -- 2178
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2179
	self.hp = self.maxHp -- 2180
	self.gateTick = 0 -- 2181
	self.gateSpawned = 0 -- 2182
	self.enemies = {} -- 2183
	self.gateFailCount = self.gateFailCount + 1 -- 2184
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2186
	self.player.y = 0 -- 2187
	self.player.vy = 0 -- 2188
	self.player.depth = 0 -- 2189
	self.player.depthSpeed = 0 -- 2190
	self.player.onGround = true -- 2191
	self.player.crouch = false -- 2192
	self.player.h = SOLDIER_H -- 2193
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2194
	self.partner.y = 0 -- 2195
	self.partner.vy = 0 -- 2196
	self.partner.depth = 0 -- 2197
	self.partner.depthSpeed = 0 -- 2198
	self.partner.onGround = true -- 2199
	self.cam.x = self.player.x -- 2200
	self.phase = "gate-idle" -- 2201
	self.phaseTick = 0 -- 2202
	self.coverHug = false -- 2203
	self.coverBlocking = false -- 2204
	self.coverEntity = "" -- 2205
	self.gateNeedConfirm = true -- 2206
	self.gateRestartArmed = false -- 2207
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2208
end -- 2177
function Play.prototype.stepInteract(self, dt, input) -- 2211
	local p = self.player -- 2212
	local calmUsed = self.calmConsumed -- 2213
	self.calmConsumed = false -- 2214
	local calming = self.escort.state == "calming" -- 2216
	self.focusCart = false -- 2217
	if self.room.key == "outside" then -- 2217
		local c = self.room.cart -- 2219
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2220
		local dy = p.y - c.baseY -- 2221
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2222
	end -- 2222
	if not calmUsed and not calming then -- 2222
		self:stepCart(dt, input) -- 2226
	end -- 2226
	if calmUsed then -- 2226
		self:flashSet("安抚 · 敲两下", 0.8) -- 2231
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2231
		if self.knockT > 0 then -- 2231
			self.knocks = self.knocks + 1 -- 2235
		else -- 2235
			self.knocks = 1 -- 2237
		end -- 2237
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2239
		self.knockT = 1.2 -- 2240
		if self.knocks >= 2 then -- 2240
			self:flashSet("敲两下", 0.8) -- 2242
			self.knocks = 0 -- 2243
		else -- 2243
			self:flashSet("敲一下", 0.5) -- 2245
		end -- 2245
	elseif self.knockT > 0 then -- 2245
		self.knockT = self.knockT - dt -- 2248
		if self.knockT <= 0 then -- 2248
			self.knocks = 0 -- 2250
		end -- 2250
	end -- 2250
	local i = 0 -- 2255
	do -- 2255
		i = 0 -- 2256
		while i < #self.room.marks do -- 2256
			do -- 2256
				local m = self.room.marks[i + 1] -- 2257
				if m.kind ~= 0 then -- 2257
					goto __continue391 -- 2259
				end -- 2259
				local subjects = {self.partner, self.player} -- 2261
				local k = 0 -- 2262
				do -- 2262
					k = 0 -- 2263
					while k < #subjects do -- 2263
						do -- 2263
							local s = subjects[k + 1] -- 2264
							if not s.alive then -- 2264
								goto __continue394 -- 2266
							end -- 2266
							local dx = s.x - m.x -- 2268
							local dy = s.y - m.y -- 2269
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2269
								self.checkpoint = m.x -- 2271
								self.checkpointCartAxle = self.cartAxle -- 2272
								if self.cartDocked then -- 2272
									self:flashSet("检查点 · 车已落窝", 1) -- 2274
								else -- 2274
									self:flashSet("检查点 · 车还没到位", 1) -- 2276
								end -- 2276
							end -- 2276
						end -- 2276
						::__continue394:: -- 2276
						k = k + 1 -- 2263
					end -- 2263
				end -- 2263
			end -- 2263
			::__continue391:: -- 2263
			i = i + 1 -- 2256
		end -- 2256
	end -- 2256
	self:checkCarryGate() -- 2282
end -- 2211
function Play.prototype.stepVillage(self, dt, input) -- 2286
	if self.room.key ~= "village" then -- 2286
		return -- 2288
	end -- 2288
	local p = self.player -- 2290
	local bottle = self.room.bottle -- 2291
	local scav = self.room.scavenger -- 2292
	if not self.hasBottle and bottle ~= nil then -- 2292
		local dx = p.x - bottle.x -- 2296
		local dy = p.y + p.h * 0.5 - bottle.y -- 2297
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2297
			self.hasBottle = true -- 2299
			self:flashSet("拾起瓶子", 0.8) -- 2300
		end -- 2300
	end -- 2300
	if self.hasBottle then -- 2300
		if input.aim.held then -- 2300
			self.aimHold = self.aimHold + dt -- 2307
			if self.aimHold > 1.2 then -- 2307
				self.aimHold = 1.2 -- 2309
			end -- 2309
			local cached = self:bottleEnd() -- 2312
			self.bottleAimX = cached.x -- 2313
			self.bottleAimY = cached.y -- 2314
		elseif input.aim.released then -- 2314
			if self.aimHold < 0.12 then -- 2314
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2318
				self.aimHold = 0 -- 2319
			else -- 2319
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2321
				self:throwBottle(____end.x, ____end.y) -- 2322
				self.aimHold = 0 -- 2323
			end -- 2323
		end -- 2323
	else -- 2323
		self.aimHold = 0 -- 2327
		self.bottleAimX = -1 -- 2328
	end -- 2328
	local fly = self.bottleFly -- 2333
	if fly ~= nil then -- 2333
		fly.t = fly.t + dt -- 2335
		fly.x = fly.x0 + fly.vx * fly.t -- 2336
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2337
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2338
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2338
			self:landBottle(fly) -- 2340
		end -- 2340
	end -- 2340
	if self.bottleLandT > 0 then -- 2340
		self.bottleLandT = self.bottleLandT - dt -- 2344
	end -- 2344
	if scav ~= nil then -- 2344
		self:stepScav(dt, scav) -- 2348
	end -- 2348
	local line = self.room.passLine -- 2351
	if line ~= nil and not self.passed and p.x >= line then -- 2351
		self.passed = true -- 2353
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2354
	end -- 2354
	if self.passed and p.x >= self.ox + 640 then -- 2354
		self:requestRoom("forest", "过第一院出院") -- 2358
		self:flashSet("出院 · 北塔森林", 1.4) -- 2359
	end -- 2359
end -- 2286
function Play.prototype.bottleEnd(self) -- 2364
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2365
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2368
	return {x = aim.x, y = g} -- 2369
end -- 2364
function Play.prototype.throwBottle(self, tx, ty) -- 2373
	local p = self.player -- 2374
	local dir = tx >= p.x and 1 or -1 -- 2376
	p.facing = dir -- 2377
	local x0 = p.x + dir * 10 -- 2378
	local y0 = p.y + p.h * 0.7 -- 2379
	self.bottleTargetX = tx -- 2380
	self.bottleTargetY = ty -- 2381
	self.bottleSurfaceY = ty -- 2382
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2383
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2384
	self.bottleFly = { -- 2385
		x = x0, -- 2385
		y = y0, -- 2385
		x0 = x0, -- 2385
		y0 = y0, -- 2385
		vx = vx, -- 2385
		vy = vy, -- 2385
		t = 0 -- 2385
	} -- 2385
	self.hasBottle = false -- 2386
	self:flashSet("投出", 0.4) -- 2387
	self:emit( -- 2388
		"bottleThrown", -- 2388
		{ -- 2388
			fromX = x0, -- 2389
			fromY = y0, -- 2390
			targetX = tx, -- 2391
			targetY = ty, -- 2392
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2393
		} -- 2393
	) -- 2393
end -- 2373
function Play.prototype.landBottle(self, fly) -- 2398
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2399
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2400
	local s = self.room.scavenger -- 2401
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2402
	self.bottleFly = nil -- 2403
	self.bottleTargetX = -1 -- 2404
	self.bottleTargetY = 0 -- 2405
	self.bottleSurfaceY = -1 -- 2406
	self.bottleLandX = x -- 2407
	self.bottleLandY = y -- 2408
	self.bottleLandT = 0.9 -- 2409
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2410
	self:hearBottle(x) -- 2411
end -- 2398
function Play.prototype.hearBottle(self, x) -- 2415
	local s = self.room.scavenger -- 2416
	if s == nil then -- 2416
		return -- 2418
	end -- 2418
	if math.abs(x - self.scavX) > s.range then -- 2418
		self:flashSet("落地 · 他没听见", 0.6) -- 2421
		return -- 2422
	end -- 2422
	self.scavState = "turn" -- 2424
	self.scavT = s.hearTicks -- 2425
	self.scavTargetX = x -- 2426
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2427
end -- 2415
function Play.prototype.stepScav(self, dt, s) -- 2431
	if self.scavState == "chase" then -- 2431
		return -- 2434
	end -- 2434
	if self.scavState == "turn" then -- 2434
		self.scavT = self.scavT - 1 -- 2437
		if self.scavT <= 0 then -- 2437
			self.scavState = "walk" -- 2439
		end -- 2439
		return -- 2441
	end -- 2441
	if self.scavState == "walk" then -- 2441
		local d = self.scavTargetX - self.scavX -- 2444
		if math.abs(d) < 4 then -- 2444
			self.scavState = "stall" -- 2446
			self.scavT = s.stallTicks -- 2447
			return -- 2448
		end -- 2448
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2450
		return -- 2451
	end -- 2451
	if self.scavState == "stall" then -- 2451
		self.scavT = self.scavT - 1 -- 2454
		if self.scavT <= 0 then -- 2454
			self.scavState = "back" -- 2456
		end -- 2456
		return -- 2458
	end -- 2458
	if self.scavState == "back" then -- 2458
		local home = math.max( -- 2461
			s.x0, -- 2461
			math.min(s.x1, self.scavX) -- 2461
		) -- 2461
		if math.abs(home - self.scavX) < 2 then -- 2461
			self.scavState = "patrol" -- 2463
			return -- 2464
		end -- 2464
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2466
		return -- 2467
	end -- 2467
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2469
	if self.scavX >= s.x1 then -- 2469
		self.scavX = s.x1 -- 2471
		self.scavDir = -1 -- 2472
	elseif self.scavX <= s.x0 then -- 2472
		self.scavX = s.x0 -- 2474
		self.scavDir = 1 -- 2475
	end -- 2475
end -- 2431
function Play.prototype.stepCart(self, dt, input) -- 2483
	local p = self.player -- 2484
	local c = self.room.cart -- 2485
	if self.gripping then -- 2485
		if not input.interact.held then -- 2485
			self.gripping = false -- 2489
			self:flashSet("松开车把", 0.4) -- 2490
			return -- 2491
		end -- 2491
	else -- 2491
		if not input.interact.pressed then -- 2491
			return -- 2495
		end -- 2495
		if not self:cartHandleInReach(p) then -- 2495
			return -- 2498
		end -- 2498
		local track = c.depth or 0 -- 2500
		if self:limitDepth(p, track) ~= track then -- 2500
			return -- 2502
		end -- 2502
		p.depth = track -- 2504
		p.depthSpeed = 0 -- 2505
		self.gripping = true -- 2506
		self:flashSet("握住车把", 0.4) -- 2507
		return -- 2508
	end -- 2508
	if self.cartDocked then -- 2508
		return -- 2512
	end -- 2512
	local dir = input.moveX -- 2514
	if dir == 0 then -- 2514
		return -- 2516
	end -- 2516
	local lo = math.min(c.startX, c.endX) -- 2518
	local hi = math.max(c.startX, c.endX) -- 2519
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2520
	if next < lo then -- 2520
		next = lo -- 2522
	end -- 2522
	if next > hi then -- 2522
		next = hi -- 2525
	end -- 2525
	local delta = next - self.cartAxle -- 2527
	if delta == 0 then -- 2527
		return -- 2529
	end -- 2529
	self.cartAxle = next -- 2531
	p.x = p.x + delta -- 2532
	p.facing = dir > 0 and 1 or -1 -- 2533
	self:slideX(p, 0) -- 2534
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2534
		self.gripping = false -- 2536
		self:flashSet("跟不上了，脱手", 0.6) -- 2537
		return -- 2538
	end -- 2538
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2538
		self.cartDocked = true -- 2541
		self.gripping = false -- 2542
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2543
		self:flashSet("车轮落窝", 1.2) -- 2544
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2544
		self:flashSet("车轮回到起点", 0.5) -- 2546
	end -- 2546
end -- 2483
function Play.prototype.requestRoom(self, key, reason) -- 2554
	if self.wantRoom ~= "" then -- 2554
		return -- 2558
	end -- 2558
	self.wantRoom = key -- 2560
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2561
end -- 2554
function Play.prototype.checkCarryGate(self) -- 2568
	if self.room.key == "checkpoint" then -- 2568
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2568
			self.carryCartAxle = self.cartAxle -- 2571
			self.carryCartDocked = self.cartDocked -- 2572
			self:requestRoom("gate", "检查站出口") -- 2573
			self:flashSet("出检查站 · 城门", 1.2) -- 2574
		end -- 2574
		return -- 2576
	end -- 2576
	if self.room.key == "outside" then -- 2576
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2576
			self.carryCartAxle = self.cartAxle -- 2582
			self.carryCartDocked = self.cartDocked -- 2583
			self:requestRoom("village", "墙根走完") -- 2584
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2585
		end -- 2585
	end -- 2585
end -- 2568
function Play.prototype.aimAt(self, wx, wy) -- 2592
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2593
	self.aimX = s.x -- 2594
	self.aimY = s.y -- 2595
end -- 2592
function Play.prototype.shoot(self, a) -- 2598
	if self.isCampaign and self.reloadT > 0 then -- 2598
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2600
		return -- 2601
	end -- 2601
	local ox = a.x + a.facing * 8 -- 2603
	local muzzleY = a.y + a.h * 0.72 -- 2604
	local oy = muzzleY + a.depth -- 2605
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2607
	local dx = aim.x - ox -- 2610
	local dy = aim.y - oy -- 2611
	local len = math.sqrt(dx * dx + dy * dy) -- 2612
	if len < 0.001 then -- 2612
		dx = a.facing -- 2614
		dy = 0 -- 2615
	else -- 2615
		dx = dx / len -- 2617
		dy = dy / len -- 2618
	end -- 2618
	if dx ~= 0 then -- 2618
		a.facing = dx > 0 and 1 or -1 -- 2621
	end -- 2621
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2624
	local hitEnemy = self:raycastEnemies(ray) -- 2625
	local tEnemy = hitEnemy.t -- 2626
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2627
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2628
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2629
	local tWall = solid.t -- 2630
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2631
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2632
	self.trace = { -- 2634
		x0 = ox, -- 2634
		y0 = oy, -- 2634
		x1 = ox + dx * t, -- 2634
		y1 = oy + dy * t, -- 2634
		hit = hit -- 2634
	} -- 2634
	self.traceT = 0.12 -- 2635
	self:applyFireDanger(ox) -- 2636
	local killed = false -- 2637
	if hit then -- 2637
		local i = hitEnemy.index -- 2639
		local e = self.enemies[i + 1] -- 2640
		local impactY = oy + dy * tEnemy -- 2641
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2642
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2643
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2643
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2645
			e.hitT = 0.3 -- 2646
			self:flashSet( -- 2647
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2647
				0.8 -- 2647
			) -- 2647
			self:emit("shotResolved", { -- 2648
				hit = true, -- 2649
				enemyIndex = i, -- 2649
				enemyX = e.x, -- 2649
				aimX = aim.x, -- 2649
				aimY = aim.y, -- 2649
				impactX = ox + dx * t, -- 2650
				impactY = oy + dy * t, -- 2650
				shield = true -- 2650
			}) -- 2650
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2652
			return -- 2653
		end -- 2653
		e.alive = false -- 2655
		e.hitT = 0.4 -- 2656
		killed = true -- 2657
		self:flashSet("命中", 0.6) -- 2658
		self:dropFor(e) -- 2659
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2659
		self:damageProp(solid.box, 1) -- 2661
	else -- 2661
		self:flashSet("打空", 0.35) -- 2663
	end -- 2663
	if self.isCampaign then -- 2663
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2666
	end -- 2666
	self:emit("shotResolved", { -- 2668
		hit = hit, -- 2669
		enemyIndex = hit and hitEnemy.index or -1, -- 2670
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2671
		aimX = aim.x, -- 2672
		aimY = aim.y, -- 2673
		impactX = ox + dx * t, -- 2674
		impactY = oy + dy * t -- 2675
	}) -- 2675
end -- 2598
function Play.prototype.applyFireDanger(self, shotX) -- 2680
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2680
		return -- 2682
	end -- 2682
	local dangerX = shotX -- 2684
	local best = -1 -- 2685
	local bestD = 1000000000 -- 2686
	local i = 0 -- 2687
	do -- 2687
		i = 0 -- 2688
		while i < #self.enemies do -- 2688
			do -- 2688
				local e = self.enemies[i + 1] -- 2689
				if not e.alive then -- 2689
					goto __continue470 -- 2691
				end -- 2691
				local d = math.abs(e.x - self.partner.x) -- 2693
				if d < bestD then -- 2693
					bestD = d -- 2695
					best = i -- 2696
				end -- 2696
			end -- 2696
			::__continue470:: -- 2696
			i = i + 1 -- 2688
		end -- 2688
	end -- 2688
	if best >= 0 then -- 2688
		dangerX = self.enemies[best + 1].x -- 2700
	end -- 2700
	local exposed = self:childExposed(dangerX) -- 2702
	local before = self.escort.fear -- 2703
	local dangerId = self.nextDangerId -- 2704
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2705
	self.nextDangerId = self.nextDangerId + 1 -- 2706
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2707
	if after > before then -- 2707
		self:flashSet( -- 2709
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2709
			1 -- 2709
		) -- 2709
	elseif not exposed then -- 2709
		self:flashSet("枪声没够到她", 0.5) -- 2711
	end -- 2711
end -- 2680
function Play.prototype.childExposed(self, dangerX) -- 2716
	local c = self.partner -- 2717
	if not c.alive then -- 2717
		return false -- 2719
	end -- 2719
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2719
		self.boxes, -- 2722
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2722
	) then -- 2722
		return false -- 2723
	end -- 2723
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2723
		return false -- 2726
	end -- 2726
	local toDanger = dangerX - c.x -- 2728
	local toPlayer = self.player.x - c.x -- 2729
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2729
		return false -- 2732
	end -- 2732
	return true -- 2734
end -- 2716
function Play.prototype.raycastEnemies(self, ray) -- 2738
	local best = -1 -- 2739
	local bestI = -1 -- 2740
	do -- 2740
		local i = 0 -- 2741
		while i < #self.enemies do -- 2741
			do -- 2741
				local e = self.enemies[i + 1] -- 2742
				if not e.alive then -- 2742
					goto __continue484 -- 2744
				end -- 2744
				local y = e.y + (e.depth or 0) -- 2746
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2747
				if t >= 0 and (best < 0 or t < best) then -- 2747
					best = t -- 2749
					bestI = i -- 2750
				end -- 2750
			end -- 2750
			::__continue484:: -- 2750
			i = i + 1 -- 2741
		end -- 2741
	end -- 2741
	return {t = best, index = bestI} -- 2753
end -- 2738
function Play.prototype.raycastWorld(self, ray) -- 2756
	return self:raycastSolid(ray).t -- 2757
end -- 2756
function Play.prototype.raycastSolid(self, ray) -- 2761
	local best = -1 -- 2762
	local bestBox = nil -- 2763
	for ____, box in ipairs(self.boxes) do -- 2764
		do -- 2764
			if box.broken == true or box.hidden == true then -- 2764
				goto __continue489 -- 2766
			end -- 2766
			local t = hitBox(ray, box) -- 2768
			if t >= 0 and (best < 0 or t < best) then -- 2768
				best = t -- 2770
				bestBox = box -- 2771
			end -- 2771
		end -- 2771
		::__continue489:: -- 2771
	end -- 2771
	if ray.dy < 0 then -- 2771
		local t = -ray.y / ray.dy -- 2775
		if t >= 0 and (best < 0 or t < best) then -- 2775
			best = t -- 2777
			bestBox = nil -- 2778
		end -- 2778
	end -- 2778
	return {t = best, box = bestBox} -- 2781
end -- 2761
function Play.prototype.dropFor(self, e) -- 2785
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2785
		return -- 2787
	end -- 2787
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2787
		return -- 2790
	end -- 2790
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2792
	local ____self_pickups_37 = self.pickups -- 2792
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2793
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2794
		kind = e.drop, -- 2794
		x = e.x, -- 2794
		y = e.y, -- 2794
		depth = e.depth, -- 2795
		label = label .. " ×1" -- 2795
	} -- 2795
	self:log("掉落 " .. label) -- 2797
end -- 2785
function Play.prototype.damageProp(self, b, amount) -- 2801
	if b.breakable == nil or b.broken == true then -- 2801
		return -- 2803
	end -- 2803
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 2803
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 2805
	if b.breakable.hp > 0 then -- 2805
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 2807
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 2808
		return -- 2809
	end -- 2809
	b.broken = true -- 2811
	for ____, other in ipairs(self.boxes) do -- 2812
		if other.id ~= nil and other.id == b.id then -- 2812
			other.broken = true -- 2814
		end -- 2814
	end -- 2814
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 2817
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 2818
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 2819
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 2820
end -- 2801
function Play.prototype.slideDepth(self, a, distance) -- 2824
	a.depth = self:limitDepth(a, a.depth + distance) -- 2825
end -- 2824
function Play.prototype.limitDepth(self, a, target) -- 2828
	local road = self.room.depth -- 2829
	if road == nil or target == a.depth then -- 2829
		return a.depth -- 2831
	end -- 2831
	local next = math.max( -- 2833
		road.min, -- 2833
		math.min(road.max, target) -- 2833
	) -- 2833
	local half = a.w / 2 -- 2834
	for ____, b in ipairs(self.boxes) do -- 2835
		do -- 2835
			local footprint = b.depth -- 2836
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2836
				goto __continue507 -- 2841
			end -- 2841
			local front = footprint.min - ACTOR_DEPTH_HALF -- 2843
			local back = footprint.max + ACTOR_DEPTH_HALF -- 2844
			if a.depth <= front and next > front then -- 2844
				next = front -- 2846
			elseif a.depth >= back and next < back then -- 2846
				next = back -- 2848
			end -- 2848
		end -- 2848
		::__continue507:: -- 2848
	end -- 2848
	return next -- 2851
end -- 2828
function Play.prototype.slideX(self, a, dx) -- 2855
	local nx = a.x + dx -- 2856
	local half = a.w / 2 -- 2857
	local room = self.room -- 2858
	nx = math.max( -- 2859
		room.minX + half, -- 2859
		math.min(room.maxX - half, nx) -- 2859
	) -- 2859
	local i = 0 -- 2860
	do -- 2860
		i = 0 -- 2861
		while i < #self.boxes do -- 2861
			do -- 2861
				local b = self.boxes[i + 1] -- 2862
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 2862
					goto __continue514 -- 2864
				end -- 2864
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2864
					goto __continue514 -- 2867
				end -- 2867
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 2867
					goto __continue514 -- 2870
				end -- 2870
				if nx + half > b.x0 and nx - half < b.x1 then -- 2870
					if a.x <= b.x0 then -- 2870
						nx = b.x0 - half -- 2874
					elseif a.x >= b.x1 then -- 2874
						nx = b.x1 + half -- 2876
					else -- 2876
						nx = a.x -- 2878
					end -- 2878
				end -- 2878
			end -- 2878
			::__continue514:: -- 2878
			i = i + 1 -- 2861
		end -- 2861
	end -- 2861
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 2861
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 2886
		local bx0 = self.cartAxle - CART_HALF -- 2887
		local bx1 = self.cartAxle + CART_HALF -- 2888
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 2888
			if a.x <= bx0 then -- 2888
				nx = bx0 - half -- 2891
			elseif a.x >= bx1 then -- 2891
				nx = bx1 + half -- 2893
			else -- 2893
				nx = a.x -- 2895
			end -- 2895
		end -- 2895
	end -- 2895
	local arch = room.arch -- 2903
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 2903
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 2905
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 2905
			if a.x <= arch.x0 then -- 2905
				nx = arch.x0 - half -- 2908
			elseif a.x >= arch.x1 then -- 2908
				nx = arch.x1 + half -- 2910
			end -- 2910
		end -- 2910
	end -- 2910
	a.x = nx -- 2914
end -- 2855
function Play.prototype.fallY(self, a, dt) -- 2918
	a.vy = a.vy - ____exports.GRAVITY * dt -- 2919
	if a.vy < -900 then -- 2919
		a.vy = -900 -- 2921
	end -- 2921
	local ny = a.y + a.vy * dt -- 2923
	local half = a.w / 2 -- 2924
	if a.vy <= 0 then -- 2924
		local reach = a.onGround and STEP_UP or 0 -- 2927
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 2928
		if ny <= ground then -- 2928
			ny = ground -- 2930
			a.vy = 0 -- 2931
			a.onGround = true -- 2932
		else -- 2932
			a.onGround = false -- 2934
		end -- 2934
	else -- 2934
		a.onGround = false -- 2937
		local i = 0 -- 2938
		do -- 2938
			i = 0 -- 2939
			while i < #self.boxes do -- 2939
				do -- 2939
					local b = self.boxes[i + 1] -- 2940
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 2940
						goto __continue538 -- 2942
					end -- 2942
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2942
						goto __continue538 -- 2945
					end -- 2945
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 2945
						goto __continue538 -- 2948
					end -- 2948
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 2948
						ny = b.y0 - a.h -- 2951
						a.vy = 0 -- 2952
					end -- 2952
				end -- 2952
				::__continue538:: -- 2952
				i = i + 1 -- 2939
			end -- 2939
		end -- 2939
	end -- 2939
	a.y = ny -- 2956
end -- 2918
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 2960
	if depth == nil then -- 2960
		depth = 0 -- 2960
	end -- 2960
	local g = -9999 -- 2961
	local i = 0 -- 2962
	do -- 2962
		i = 0 -- 2963
		while i < #self.floors do -- 2963
			local f = self.floors[i + 1] -- 2964
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 2964
				g = f.y1 -- 2966
			end -- 2966
			i = i + 1 -- 2963
		end -- 2963
	end -- 2963
	do -- 2963
		i = 0 -- 2969
		while i < #self.boxes do -- 2969
			do -- 2969
				local b = self.boxes[i + 1] -- 2970
				if b.broken == true or b.hidden == true or b.soft == true then -- 2970
					goto __continue548 -- 2972
				end -- 2972
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 2972
					g = b.y1 -- 2976
				end -- 2976
			end -- 2976
			::__continue548:: -- 2976
			i = i + 1 -- 2969
		end -- 2969
	end -- 2969
	return g -- 2979
end -- 2960
function Play.prototype.updateCamera(self, dt) -- 2982
	local p = self.player -- 2983
	local tx = p.x + p.facing * 30 -- 2984
	local ty = p.y + CAM_LOOK_UP -- 2985
	local k = math.min(1, CAM_FOLLOW * dt) -- 2986
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 2987
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 2988
end -- 2982
function Play.prototype.clampCamera(self, w, h) -- 2992
	local room = self.room -- 2993
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 2994
	local spanX = room.maxX - room.minX -- 2995
	if spanX <= halfW * 2 then -- 2995
		self.cam.x = (room.minX + room.maxX) / 2 -- 2997
	else -- 2997
		self.cam.x = math.max( -- 2999
			room.minX + halfW, -- 2999
			math.min(room.maxX - halfW, self.cam.x) -- 2999
		) -- 2999
	end -- 2999
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3002
	local spanY = room.height -- 3003
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3004
	if spanY <= halfH * 2 then -- 3004
		self.cam.y = camY -- 3006
	else -- 3006
		self.cam.y = math.max( -- 3008
			camY, -- 3008
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3008
		) -- 3008
	end -- 3008
end -- 2992
function Play.prototype.flashSet(self, text, t) -- 3012
	self.flash = text -- 3013
	self.flashT = t -- 3014
end -- 3012
function Play.prototype.statusText(self) -- 3018
	local p = self.player -- 3019
	local parts = {} -- 3020
	local who = self.childMode and "小满" or "周戍" -- 3021
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3022
	if self.room.key == "prologue" then -- 3022
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3025
		if self.phase == "prologue-wait" then -- 3025
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3027
		elseif self.phase == "prologue-give" then -- 3027
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3029
		else -- 3029
			parts[#parts + 1] = "跟随" -- 3031
		end -- 3031
		if self.paused then -- 3031
			parts[#parts + 1] = "已暂停" -- 3034
		end -- 3034
		return table.concat(parts, " · ") -- 3036
	end -- 3036
	if self.room.key == "street" then -- 3036
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3039
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3040
		if self.paused then -- 3040
			parts[#parts + 1] = "已暂停" -- 3042
		end -- 3042
		return table.concat(parts, " · ") -- 3044
	end -- 3044
	if self.room.key == "gate" then -- 3044
		local ____temp_40 -- 3047
		if self.room.story == nil then -- 3047
			____temp_40 = nil -- 3047
		else -- 3047
			____temp_40 = self.room.story.gate -- 3047
		end -- 3047
		local g = ____temp_40 -- 3047
		if g ~= nil then -- 3047
			parts[#parts + 1] = self:gateLabel() -- 3049
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3050
				0, -- 3051
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3051
			))) .. " 秒" -- 3051
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3052
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3053
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3054
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3055
			if self.gateFailCount > 0 then -- 3055
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3057
			end -- 3057
			if self.flash ~= "" then -- 3057
				parts[#parts + 1] = self.flash -- 3060
			end -- 3060
		end -- 3060
		if self.paused then -- 3060
			parts[#parts + 1] = "已暂停" -- 3064
		end -- 3064
		return table.concat(parts, " · ") -- 3066
	end -- 3066
	if self.room.key == "forest" then -- 3066
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3069
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3070
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3071
		if self.caughtT > 0 then -- 3071
			parts[#parts + 1] = "复位中" -- 3073
		end -- 3073
		if self.paused then -- 3073
			parts[#parts + 1] = "已暂停" -- 3076
		end -- 3076
		return table.concat(parts, " · ") -- 3078
	end -- 3078
	if self.room.key == "tower" then -- 3078
		if self.phase == "tower-wait" then -- 3078
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3082
		elseif self.phase == "tower-knock" then -- 3082
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3084
		elseif self.phase == "tower-given" then -- 3084
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3086
		else -- 3086
			parts[#parts + 1] = "片尾" -- 3088
		end -- 3088
		if self.paused then -- 3088
			parts[#parts + 1] = "已暂停" -- 3091
		end -- 3091
		return table.concat(parts, " · ") -- 3093
	end -- 3093
	if self.room.key == "village" then -- 3093
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3096
		if self.hasBottle then -- 3096
			parts[#parts + 1] = "有瓶" -- 3098
		elseif self.bottleFly ~= nil then -- 3098
			parts[#parts + 1] = "瓶在飞" -- 3100
		else -- 3100
			parts[#parts + 1] = "空手" -- 3102
		end -- 3102
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3104
		if self.scavChase then -- 3104
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3106
		end -- 3106
		if self.passed then -- 3106
			parts[#parts + 1] = "已过通行线" -- 3109
		end -- 3109
		if self.paused then -- 3109
			parts[#parts + 1] = "已暂停" -- 3112
		end -- 3112
		return table.concat(parts, " · ") -- 3114
	end -- 3114
	local isChild = self.childMode -- 3117
	if isChild then -- 3117
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3119
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3120
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3121
	else -- 3121
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3123
		if p.rollT > 0 then -- 3123
			parts[#parts + 1] = "翻滚中" -- 3125
		end -- 3125
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3127
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3128
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3129
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3130
	end -- 3130
	if self.checkpoint >= 0 then -- 3130
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3133
	end -- 3133
	if self.paused then -- 3133
		parts[#parts + 1] = "已暂停" -- 3136
	end -- 3136
	return table.concat(parts, " · ") -- 3138
end -- 3018
function Play.prototype.aliveEnemies(self) -- 3142
	local n = 0 -- 3143
	local i = 0 -- 3144
	do -- 3144
		i = 0 -- 3145
		while i < #self.enemies do -- 3145
			if self.enemies[i + 1].alive then -- 3145
				n = n + 1 -- 3147
			end -- 3147
			i = i + 1 -- 3145
		end -- 3145
	end -- 3145
	return n -- 3150
end -- 3142
function Play.prototype.threatened(self) -- 3155
	do -- 3155
		local i = 0 -- 3156
		while i < #self.enemies do -- 3156
			local e = self.enemies[i + 1] -- 3157
			if e.alive and e.warnT > 0 then -- 3157
				return true -- 3159
			end -- 3159
			i = i + 1 -- 3156
		end -- 3156
	end -- 3156
	return false -- 3162
end -- 3155
function Play.prototype.gateSecondsLeft(self) -- 3165
	local ____temp_41 -- 3166
	if self.room.story == nil then -- 3166
		____temp_41 = nil -- 3166
	else -- 3166
		____temp_41 = self.room.story.gate -- 3166
	end -- 3166
	local g = ____temp_41 -- 3166
	if g == nil then -- 3166
		return 0 -- 3168
	end -- 3168
	return math.max( -- 3170
		0, -- 3170
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3170
	) -- 3170
end -- 3165
function Play.prototype.gateLabel(self) -- 3173
	if self.phase == "gate-idle" then -- 3173
		return "待就位" -- 3175
	end -- 3175
	if self.phase == "gate-hold" then -- 3175
		return "守点中" -- 3178
	end -- 3178
	if self.phase == "gate-send" then -- 3178
		return "送别" -- 3181
	end -- 3181
	if self.phase == "gate-count" then -- 3181
		return "数数 " .. tostring(self.countTick) -- 3184
	end -- 3184
	return "她走" -- 3186
end -- 3173
function Play.prototype.dogLabel(self) -- 3190
	if self.dogState == "ear" then -- 3190
		return "转耳" -- 3192
	end -- 3192
	if self.dogState == "chase" then -- 3192
		return "追" -- 3195
	end -- 3195
	if self.dogState == "sniff" then -- 3195
		return "停" -- 3198
	end -- 3198
	if self.dogState == "back" then -- 3198
		return "回线" -- 3201
	end -- 3201
	return "巡逻" -- 3203
end -- 3190
function Play.prototype.doorXOf(self) -- 3206
	local ____temp_42 -- 3207
	if self.room.story == nil then -- 3207
		____temp_42 = nil -- 3207
	else -- 3207
		____temp_42 = self.room.story.tower -- 3207
	end -- 3207
	local t = ____temp_42 -- 3207
	return t == nil and 0 or t.doorX -- 3208
end -- 3206
function Play.prototype.scavLabel(self) -- 3212
	if self.scavState == "chase" then -- 3212
		return "追" -- 3214
	end -- 3214
	if self.scavState == "turn" then -- 3214
		return "转头" -- 3217
	end -- 3217
	if self.scavState == "walk" then -- 3217
		return "赶来" -- 3220
	end -- 3220
	if self.scavState == "stall" then -- 3220
		return "停住" -- 3223
	end -- 3223
	if self.scavState == "back" then -- 3223
		return "回位" -- 3226
	end -- 3226
	return "巡逻" -- 3228
end -- 3212
function Play.prototype.hintText(self) -- 3232
	if self.paused then -- 3232
		return "Esc 继续 · R 重置" -- 3234
	end -- 3234
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3234
		if self:threatened() then -- 3234
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3240
		end -- 3240
		if self.coverHug then -- 3240
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3243
		end -- 3243
		if self.coverNear then -- 3243
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3246
		end -- 3246
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3248
	end -- 3248
	if self.flash ~= "" then -- 3248
		return self.flash -- 3251
	end -- 3251
	if self.room.key == "prologue" then -- 3251
		if self.phase == "prologue-wait" then -- 3251
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3255
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3256
		end -- 3256
		if self.phase == "prologue-give" then -- 3256
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3259
		end -- 3259
		return "她跟着你了 · 两人一起走到门口 680" -- 3261
	end -- 3261
	if self.room.key == "street" then -- 3261
		if self:aliveEnemies() > 0 then -- 3261
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3265
		end -- 3265
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3267
	end -- 3267
	if self.room.key == "gate" then -- 3267
		local ____temp_43 -- 3270
		if self.room.story == nil then -- 3270
			____temp_43 = nil -- 3270
		else -- 3270
			____temp_43 = self.room.story.gate -- 3270
		end -- 3270
		local g = ____temp_43 -- 3270
		if g ~= nil then -- 3270
			if self.phase == "gate-idle" then -- 3270
				if self.gateNeedConfirm then -- 3270
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3274
				end -- 3274
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3276
			end -- 3276
			if self.phase == "gate-hold" then -- 3276
				if self.coveredFlash > 0 then -- 3276
					return "掩体挡下了这一枪 · 别露头" -- 3280
				end -- 3280
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3282
			end -- 3282
			if self.phase == "gate-send" then -- 3282
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3285
			end -- 3285
			if self.phase == "gate-count" then -- 3285
				if self.countTick >= 1440 then -- 3285
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3289
				end -- 3289
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3291
			end -- 3291
			return "她自己走 · 跟着出城门 1120" -- 3293
		end -- 3293
	end -- 3293
	if self.room.key == "forest" then -- 3293
		if self.dogState == "chase" then -- 3293
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3298
		end -- 3298
		if self.dogState == "ear" then -- 3298
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3301
		end -- 3301
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3303
	end -- 3303
	if self.room.key == "tower" then -- 3303
		if self.phase == "tower-wait" then -- 3303
			return "走到门前 445 点一次 E 敲两下" -- 3307
		end -- 3307
		if self.phase == "tower-knock" then -- 3307
			return "敲两下 · 等门开" -- 3310
		end -- 3310
		if self.phase == "tower-given" then -- 3310
			return "递交针套和纸条 · 看登记簿最后一行" -- 3313
		end -- 3313
		return "片尾 · 点 E 再玩一次，回到序章" -- 3315
	end -- 3315
	if self.room.key == "village" then -- 3315
		if self.bottleFly ~= nil then -- 3315
			return "等瓶子落地 · 触地才发声" -- 3319
		end -- 3319
		if self.hasBottle then -- 3319
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3322
		end -- 3322
		if self.passed then -- 3322
			return "已过第一院 · R 重置可再来一遍" -- 3325
		end -- 3325
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3327
	end -- 3327
	if self.room.key == "outside" then -- 3327
		if self.focusCart then -- 3327
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3331
		end -- 3331
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3333
	end -- 3333
	if self.escort.state == "frozen" then -- 3333
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3333
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3337
		end -- 3337
		return "小满吓住了 · 走过去，靠近再点 E" -- 3339
	end -- 3339
	if self.escort.state == "calming" then -- 3339
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3342
	end -- 3342
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3344
end -- 3232
function Play.prototype.draw(self, draw, w, h) -- 3349
	self.viewW = w -- 3350
	self.viewH = h -- 3351
	self.view = ____exports.computeViewport(w, h) -- 3352
	self:clampCamera(w, h) -- 3353
	draw:clear() -- 3354
	draw:drawRect( -- 3356
		Rect(0, 0, w, h), -- 3356
		BG_VOID -- 3356
	) -- 3356
	local box = self:canvasRect(w, h) -- 3357
	draw:drawRect(box, BG_FAR) -- 3358
	draw:drawRect( -- 3359
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3359
		BG_MID -- 3359
	) -- 3359
	self:drawFloors(draw, w, h) -- 3361
	self:drawSolids(draw, w, h) -- 3362
	self:drawZones(draw, w, h) -- 3363
	self:drawArch(draw, w, h) -- 3364
	self:drawCart(draw, w, h) -- 3365
	self:drawCampaignProps(draw, w, h) -- 3366
	self:drawActors(draw, w, h) -- 3367
	self:drawTrace(draw, w, h) -- 3368
	self:drawAim(draw, w, h) -- 3369
end -- 3349
function Play.prototype.canvasRect(self, w, h) -- 3373
	local v = self.view -- 3374
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3375
end -- 3373
function Play.prototype.px(self, n) -- 3379
	return n * self.view.zoom -- 3380
end -- 3379
function Play.prototype.sx(self, wx, w) -- 3384
	local v = self.view -- 3385
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3386
	return v.ox + lx * v.zoom -- 3387
end -- 3384
function Play.prototype.sy(self, wy, h) -- 3391
	local v = self.view -- 3392
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3393
	return v.oy + ly * v.zoom -- 3394
end -- 3391
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3397
	local px0 = self:sx(x0, w) -- 3398
	local px1 = self:sx(x1, w) -- 3399
	local py0 = self:sy(y0, h) -- 3400
	local py1 = self:sy(y1, h) -- 3401
	if px1 <= px0 or py1 <= py0 then -- 3401
		return -- 3403
	end -- 3403
	draw:drawRect( -- 3405
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3405
		color -- 3405
	) -- 3405
end -- 3397
function Play.prototype.drawFloors(self, draw, w, h) -- 3408
	local i = 0 -- 3409
	do -- 3409
		i = 0 -- 3410
		while i < #self.room.floors do -- 3410
			local f = self.room.floors[i + 1] -- 3411
			local ____temp_44 -- 3412
			if f.y == 0 then -- 3412
				____temp_44 = self.room.depth -- 3412
			else -- 3412
				____temp_44 = nil -- 3412
			end -- 3412
			local road = ____temp_44 -- 3412
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3413
			local x0 = self:sx(f.x0, w) -- 3414
			local x1 = self:sx(f.x1, w) -- 3415
			local deck = self:px(5) -- 3416
			if road ~= nil then -- 3416
				local back = self:sy(f.y + road.max, h) -- 3418
				draw:drawRect( -- 3419
					Rect(x0, y, x1 - x0, back - y), -- 3419
					FLOOR_DECK, -- 3419
					self:px(1), -- 3419
					SOLID_EDGE -- 3419
				) -- 3419
			end -- 3419
			draw:drawRect( -- 3421
				Rect(x0, y - deck, x1 - x0, deck), -- 3421
				FLOOR_DECK -- 3421
			) -- 3421
			draw:drawSegment( -- 3422
				Vec2(x0, y), -- 3422
				Vec2(x1, y), -- 3422
				self:px(1), -- 3422
				GROUND -- 3422
			) -- 3422
			i = i + 1 -- 3410
		end -- 3410
	end -- 3410
end -- 3408
function Play.prototype.drawSolids(self, draw, w, h) -- 3426
	local i = 0 -- 3427
	do -- 3427
		i = 0 -- 3428
		while i < #self.boxes do -- 3428
			do -- 3428
				local b = self.boxes[i + 1] -- 3429
				if b.id == "braced_shield" or b.hidden == true then -- 3429
					goto __continue669 -- 3431
				end -- 3431
				if b.broken == true then -- 3431
					if b.breakable ~= nil then -- 3431
						local gy = self:sy(b.y0, h) -- 3436
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3437
						local k = 0 -- 3438
						do -- 3438
							k = 0 -- 3439
							while k < 3 do -- 3439
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3440
								draw:drawSegment( -- 3441
									Vec2( -- 3441
										gx - self:px(4), -- 3441
										gy + self:px(k % 2) -- 3441
									), -- 3441
									Vec2( -- 3441
										gx + self:px(5), -- 3441
										gy + self:px(k % 2) -- 3441
									), -- 3441
									self:px(1), -- 3441
									rgb -- 3441
								) -- 3441
								k = k + 1 -- 3439
							end -- 3439
						end -- 3439
					end -- 3439
					goto __continue669 -- 3444
				end -- 3444
				local ____opt_47 = b.depth -- 3444
				local front = ____opt_47 and ____opt_47.min or 0 -- 3446
				local ____opt_49 = b.depth -- 3446
				local back = ____opt_49 and ____opt_49.max or 0 -- 3447
				local fill = SOLID_FILL -- 3448
				local line = SOLID_EDGE -- 3449
				if b.soft == true then -- 3449
					fill = SOFT -- 3451
					line = SOFT_LINE -- 3452
				elseif b.breakable ~= nil then -- 3452
					line = DANGER_LINE -- 3454
					fill = Color(0.3, 0.24, 0.16, 1) -- 3455
				elseif b.interact ~= nil then -- 3455
					line = PASS_LINE -- 3457
				end -- 3457
				self:drawBox( -- 3459
					draw, -- 3459
					w, -- 3459
					h, -- 3459
					b.x0, -- 3459
					b.x1, -- 3459
					b.y0 + front, -- 3459
					b.y1 + back, -- 3459
					fill -- 3459
				) -- 3459
				draw:drawSegment( -- 3460
					Vec2( -- 3460
						self:sx(b.x0, w), -- 3460
						self:sy(b.y1 + front, h) -- 3460
					), -- 3460
					Vec2( -- 3461
						self:sx(b.x1, w), -- 3461
						self:sy(b.y1 + front, h) -- 3461
					), -- 3461
					self:px(1), -- 3461
					line -- 3461
				) -- 3461
				if b.breakable ~= nil then -- 3461
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3464
					local cyp = self:sy(b.y1 + front, h) -- 3465
					draw:drawSegment( -- 3466
						Vec2( -- 3466
							cxp - self:px(4), -- 3466
							cyp + self:px(1) -- 3466
						), -- 3466
						Vec2( -- 3466
							cxp + self:px(3), -- 3466
							cyp + self:px(5) -- 3466
						), -- 3466
						self:px(1), -- 3466
						line -- 3466
					) -- 3466
				end -- 3466
			end -- 3466
			::__continue669:: -- 3466
			i = i + 1 -- 3428
		end -- 3428
	end -- 3428
end -- 3426
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3472
	local i = 0 -- 3473
	do -- 3473
		i = 0 -- 3474
		while i < #self.pickups do -- 3474
			do -- 3474
				local pk = self.pickups[i + 1] -- 3475
				if pk.id == "" then -- 3475
					goto __continue681 -- 3477
				end -- 3477
				local gy = pk.y + (pk.depth or 0) -- 3479
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3480
				draw:drawRect( -- 3481
					Rect( -- 3481
						self:sx(pk.x - 5, w), -- 3481
						self:sy(gy + 12 + bob, h), -- 3481
						self:px(10), -- 3481
						self:px(10) -- 3481
					), -- 3481
					Color(0.84, 0.7, 0.3, 1) -- 3482
				) -- 3482
				draw:drawSegment( -- 3483
					Vec2( -- 3483
						self:sx(pk.x - 5, w), -- 3483
						self:sy(gy + 12 + bob, h) -- 3483
					), -- 3483
					Vec2( -- 3484
						self:sx(pk.x + 5, w), -- 3484
						self:sy(gy + 12 + bob, h) -- 3484
					), -- 3484
					self:px(1), -- 3484
					Color(0.95, 0.86, 0.52, 1) -- 3484
				) -- 3484
			end -- 3484
			::__continue681:: -- 3484
			i = i + 1 -- 3474
		end -- 3474
	end -- 3474
	if self.bracedShield ~= nil then -- 3474
		local sh = self.bracedShield -- 3487
		draw:drawRect( -- 3488
			Rect( -- 3488
				self:sx(sh.x - sh.w / 2, w), -- 3488
				self:sy(sh.y, h), -- 3488
				self:px(sh.w), -- 3488
				self:px(sh.h) -- 3488
			), -- 3488
			Color(0.42, 0.4, 0.34, 1) -- 3489
		) -- 3489
		draw:drawSegment( -- 3490
			Vec2( -- 3490
				self:sx(sh.x - sh.w / 2, w), -- 3490
				self:sy(sh.y + sh.h, h) -- 3490
			), -- 3490
			Vec2( -- 3491
				self:sx(sh.x + sh.w / 2, w), -- 3491
				self:sy(sh.y + sh.h, h) -- 3491
			), -- 3491
			self:px(1), -- 3491
			Color(0.74, 0.72, 0.62, 1) -- 3491
		) -- 3491
	end -- 3491
end -- 3472
function Play.prototype.drawZones(self, draw, w, h) -- 3495
	local i = 0 -- 3496
	do -- 3496
		i = 0 -- 3497
		while i < #self.room.zones do -- 3497
			local z = self.room.zones[i + 1] -- 3498
			local fill = DANGER -- 3499
			local line = DANGER_LINE -- 3500
			if z.tint == 2 then -- 3500
				fill = SOFT -- 3502
				line = SOFT_LINE -- 3503
			elseif z.tint == 3 then -- 3503
				fill = BRICK -- 3505
				line = BRICK_LINE -- 3506
			elseif z.tint == 4 then -- 3506
				fill = PASS -- 3508
				line = PASS_LINE -- 3509
			end -- 3509
			self:drawBox( -- 3511
				draw, -- 3511
				w, -- 3511
				h, -- 3511
				z.x0, -- 3511
				z.x1, -- 3511
				z.y, -- 3511
				z.y + z.h, -- 3511
				fill -- 3511
			) -- 3511
			draw:drawSegment( -- 3512
				Vec2( -- 3512
					self:sx(z.x0, w), -- 3512
					self:sy(z.y, h) -- 3512
				), -- 3512
				Vec2( -- 3512
					self:sx(z.x0, w), -- 3512
					self:sy(z.y + z.h, h) -- 3512
				), -- 3512
				self:px(1), -- 3512
				line -- 3512
			) -- 3512
			draw:drawSegment( -- 3513
				Vec2( -- 3513
					self:sx(z.x1, w), -- 3513
					self:sy(z.y, h) -- 3513
				), -- 3513
				Vec2( -- 3513
					self:sx(z.x1, w), -- 3513
					self:sy(z.y + z.h, h) -- 3513
				), -- 3513
				self:px(1), -- 3513
				line -- 3513
			) -- 3513
			i = i + 1 -- 3497
		end -- 3497
	end -- 3497
end -- 3495
function Play.prototype.drawArch(self, draw, w, h) -- 3517
	local a = self.room.arch -- 3518
	if a.h <= 0 then -- 3518
		return -- 3520
	end -- 3520
	self:drawBox( -- 3522
		draw, -- 3522
		w, -- 3522
		h, -- 3522
		a.x0, -- 3522
		a.x1, -- 3522
		a.y, -- 3522
		a.y + a.h, -- 3522
		HOLE_FILL -- 3522
	) -- 3522
	draw:drawSegment( -- 3523
		Vec2( -- 3523
			self:sx(a.x0, w), -- 3523
			self:sy(a.y + a.h, h) -- 3523
		), -- 3523
		Vec2( -- 3523
			self:sx(a.x1, w), -- 3523
			self:sy(a.y + a.h, h) -- 3523
		), -- 3523
		self:px(1), -- 3523
		SOLID_EDGE -- 3523
	) -- 3523
	draw:drawSegment( -- 3524
		Vec2( -- 3524
			self:sx(a.x0, w), -- 3524
			self:sy(a.y, h) -- 3524
		), -- 3524
		Vec2( -- 3524
			self:sx(a.x0, w), -- 3524
			self:sy(a.y + a.h, h) -- 3524
		), -- 3524
		self:px(1), -- 3524
		SOLID_EDGE -- 3524
	) -- 3524
	draw:drawSegment( -- 3525
		Vec2( -- 3525
			self:sx(a.x1, w), -- 3525
			self:sy(a.y, h) -- 3525
		), -- 3525
		Vec2( -- 3525
			self:sx(a.x1, w), -- 3525
			self:sy(a.y + a.h, h) -- 3525
		), -- 3525
		self:px(1), -- 3525
		SOLID_EDGE -- 3525
	) -- 3525
end -- 3517
function Play.prototype.drawCart(self, draw, w, h) -- 3528
	local c = self.room.cart -- 3529
	if c.bodyW <= 0 then -- 3529
		return -- 3531
	end -- 3531
	drawCartShape( -- 3533
		draw, -- 3533
		self, -- 3533
		w, -- 3533
		h, -- 3533
		c, -- 3533
		self.cartAxle -- 3533
	) -- 3533
	draw:drawRect( -- 3534
		Rect( -- 3534
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3534
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3534
			self:px(2), -- 3534
			self:px(40) -- 3534
		), -- 3534
		STAND -- 3534
	) -- 3534
end -- 3528
function Play.prototype.drawActors(self, draw, w, h) -- 3537
	local p = self.player -- 3538
	local isChild = self.childMode -- 3539
	local footY = p.y + p.depth -- 3540
	if p.covered then -- 3540
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3543
		draw:drawSegment( -- 3544
			Vec2( -- 3544
				self:sx(edge, w), -- 3544
				self:sy(footY + 8, h) -- 3544
			), -- 3544
			Vec2( -- 3544
				self:sx(edge, w), -- 3544
				self:sy(footY + p.h * 0.62, h) -- 3544
			), -- 3544
			self:px(2), -- 3544
			STAND -- 3544
		) -- 3544
		draw:drawSegment( -- 3546
			Vec2( -- 3546
				self:sx(p.x - 8, w), -- 3546
				self:sy(footY + p.h + 3, h) -- 3546
			), -- 3546
			Vec2( -- 3546
				self:sx(p.x + 8, w), -- 3546
				self:sy(footY + p.h + 3, h) -- 3546
			), -- 3546
			self:px(2), -- 3546
			STAND -- 3546
		) -- 3546
	elseif self.coverNear and not isChild then -- 3546
		draw:drawRect( -- 3549
			Rect( -- 3549
				self:sx(p.x - 3, w), -- 3549
				self:sy(footY + 1, h), -- 3549
				self:px(3), -- 3549
				self:px(3) -- 3549
			), -- 3549
			STAND -- 3549
		) -- 3549
	end -- 3549
	drawFigure( -- 3551
		draw, -- 3551
		self, -- 3551
		w, -- 3551
		h, -- 3551
		p, -- 3551
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3551
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3551
	) -- 3551
	local q = self.partner -- 3552
	if q.alive then -- 3552
		local childPartner = q.w == CHILD_W -- 3554
		drawFigure( -- 3555
			draw, -- 3555
			self, -- 3555
			w, -- 3555
			h, -- 3555
			q, -- 3555
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3555
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3555
		) -- 3555
	end -- 3555
	local i = 0 -- 3557
	do -- 3557
		i = 0 -- 3558
		while i < #self.enemies do -- 3558
			local e = self.enemies[i + 1] -- 3559
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3560
			local enemyY = e.y + (e.depth or 0) -- 3561
			self:drawBox( -- 3562
				draw, -- 3562
				w, -- 3562
				h, -- 3562
				e.x - e.w / 2, -- 3562
				e.x + e.w / 2, -- 3562
				enemyY, -- 3562
				enemyY + e.h, -- 3562
				col -- 3562
			) -- 3562
			if e.alive then -- 3562
				local ef = p.x >= e.x and 1 or -1 -- 3564
				if e.kind == "shield" then -- 3564
					local sh = (e.shieldHp or 0) > 0 -- 3566
					draw:drawRect( -- 3567
						Rect( -- 3567
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3567
							self:sy(enemyY, h), -- 3567
							self:px(6), -- 3567
							self:px(64) -- 3567
						), -- 3567
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3568
					) -- 3568
				elseif e.kind == "breaker" then -- 3568
					draw:drawSegment( -- 3570
						Vec2( -- 3570
							self:sx(e.x + ef * 12, w), -- 3570
							self:sy(enemyY + 8, h) -- 3570
						), -- 3570
						Vec2( -- 3571
							self:sx(e.x + ef * 22, w), -- 3571
							self:sy(enemyY + 46, h) -- 3571
						), -- 3571
						self:px(3), -- 3571
						Color(0.5, 0.36, 0.22, 1) -- 3571
					) -- 3571
				end -- 3571
			end -- 3571
			if e.alive and e.warnT > 0 then -- 3571
				local gunX = self:sx(e.x, w) -- 3576
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3577
				local aimX = self:sx(p.x, w) -- 3578
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3579
				local seg = 8 -- 3580
				local s = 0 -- 3581
				do -- 3581
					s = 0 -- 3582
					while s < seg do -- 3582
						local t0 = s / seg -- 3583
						local t1 = (s + 1) / seg -- 3584
						draw:drawSegment( -- 3585
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3586
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3587
							self:px(1), -- 3588
							DANGER -- 3588
						) -- 3588
						s = s + 2 -- 3582
					end -- 3582
				end -- 3582
			end -- 3582
			i = i + 1 -- 3558
		end -- 3558
	end -- 3558
	local k = 0 -- 3593
	do -- 3593
		k = 0 -- 3594
		while k < #self.room.marks do -- 3594
			do -- 3594
				local m = self.room.marks[k + 1] -- 3595
				if m.kind ~= 0 then -- 3595
					goto __continue707 -- 3597
				end -- 3597
				local on = self.checkpoint == m.x -- 3599
				local x = self:sx(m.x, w) -- 3600
				local y = self:sy(m.y, h) -- 3601
				draw:drawSegment( -- 3602
					Vec2(x, y), -- 3602
					Vec2( -- 3602
						x, -- 3602
						y + self:px(35) -- 3602
					), -- 3602
					self:px(1), -- 3602
					on and CHECK or INK_DIM -- 3602
				) -- 3602
				draw:drawDot( -- 3603
					Vec2( -- 3603
						x, -- 3603
						y + self:px(35) -- 3603
					), -- 3603
					self:px(2), -- 3603
					on and CHECK or INK_DIM -- 3603
				) -- 3603
			end -- 3603
			::__continue707:: -- 3603
			k = k + 1 -- 3594
		end -- 3594
	end -- 3594
	local j = 0 -- 3607
	do -- 3607
		j = 0 -- 3608
		while j < #self.room.marks do -- 3608
			do -- 3608
				local m = self.room.marks[j + 1] -- 3609
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3609
					goto __continue710 -- 3611
				end -- 3611
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3611
					goto __continue710 -- 3615
				end -- 3615
				local col = STAND -- 3617
				if m.kind == 4 then -- 3617
					col = PASS_LINE -- 3619
				elseif m.kind == 5 then -- 3619
					col = BRICK_LINE -- 3621
				end -- 3621
				local mx = self:sx(m.x, w) -- 3623
				local my = self:sy(m.y, h) -- 3624
				draw:drawSegment( -- 3625
					Vec2(mx, my), -- 3625
					Vec2( -- 3625
						mx, -- 3625
						my + self:px(24) -- 3625
					), -- 3625
					self:px(1), -- 3625
					col -- 3625
				) -- 3625
			end -- 3625
			::__continue710:: -- 3625
			j = j + 1 -- 3608
		end -- 3608
	end -- 3608
	local t = 0 -- 3628
	do -- 3628
		t = 0 -- 3629
		while t < #self.room.marks do -- 3629
			do -- 3629
				local m = self.room.marks[t + 1] -- 3630
				if m.kind ~= 6 then -- 3630
					goto __continue716 -- 3632
				end -- 3632
				local mx = self:sx(m.x, w) -- 3634
				local my = self:sy(m.y, h) -- 3635
				draw:drawSegment( -- 3636
					Vec2(mx, my), -- 3636
					Vec2( -- 3636
						mx, -- 3636
						my + self:px(30) -- 3636
					), -- 3636
					self:px(1), -- 3636
					INK_DIM -- 3636
				) -- 3636
				self:drawBox( -- 3637
					draw, -- 3637
					w, -- 3637
					h, -- 3637
					m.x - 5, -- 3637
					m.x + 5, -- 3637
					m.y + 30, -- 3637
					m.y + 40, -- 3637
					CHECK -- 3637
				) -- 3637
			end -- 3637
			::__continue716:: -- 3637
			t = t + 1 -- 3629
		end -- 3629
	end -- 3629
	if self.room.key == "village" then -- 3629
		self:drawVillage(draw, w, h) -- 3640
	end -- 3640
	if self.room.key == "forest" then -- 3640
		self:drawDog(draw, w, h) -- 3643
	end -- 3643
end -- 3537
function Play.prototype.drawDog(self, draw, w, h) -- 3648
	local x = self.dogX -- 3649
	self:drawBox( -- 3650
		draw, -- 3650
		w, -- 3650
		h, -- 3650
		x - 14, -- 3650
		x + 14, -- 3650
		0, -- 3650
		20, -- 3650
		SCAV_BODY -- 3650
	) -- 3650
	self:drawBox( -- 3651
		draw, -- 3651
		w, -- 3651
		h, -- 3651
		x - 10, -- 3651
		x - 2, -- 3651
		20, -- 3651
		30, -- 3651
		SCAV_BODY -- 3651
	) -- 3651
	self:drawBox( -- 3652
		draw, -- 3652
		w, -- 3652
		h, -- 3652
		x + 2, -- 3652
		x + 10, -- 3652
		20, -- 3652
		30, -- 3652
		SCAV_HEAD -- 3652
	) -- 3652
	if self.dogState == "ear" or self.dogState == "chase" then -- 3652
		draw:drawSegment( -- 3654
			Vec2( -- 3654
				self:sx(x, w), -- 3654
				self:sy(30, h) -- 3654
			), -- 3654
			Vec2( -- 3655
				self:sx(x, w), -- 3655
				self:sy(40, h) -- 3655
			), -- 3655
			self:px(1), -- 3655
			DANGER -- 3655
		) -- 3655
	end -- 3655
end -- 3648
function Play.prototype.drawVillage(self, draw, w, h) -- 3660
	local bottle = self.room.bottle -- 3661
	if bottle ~= nil then -- 3661
		self:drawBox( -- 3663
			draw, -- 3663
			w, -- 3663
			h, -- 3663
			bottle.x - 14, -- 3663
			bottle.x + 14, -- 3663
			0, -- 3663
			64, -- 3663
			SOLID_FILL -- 3663
		) -- 3663
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3663
			self:drawBottle( -- 3665
				draw, -- 3665
				w, -- 3665
				h, -- 3665
				bottle.x, -- 3665
				64 -- 3665
			) -- 3665
		end -- 3665
	end -- 3665
	self:drawBox( -- 3669
		draw, -- 3669
		w, -- 3669
		h, -- 3669
		300, -- 3669
		420, -- 3669
		44, -- 3669
		50, -- 3669
		FLOOR_DECK -- 3669
	) -- 3669
	self:drawBox( -- 3670
		draw, -- 3670
		w, -- 3670
		h, -- 3670
		300, -- 3670
		306, -- 3670
		0, -- 3670
		44, -- 3670
		FLOOR_DECK -- 3670
	) -- 3670
	self:drawBox( -- 3671
		draw, -- 3671
		w, -- 3671
		h, -- 3671
		414, -- 3671
		420, -- 3671
		0, -- 3671
		44, -- 3671
		FLOOR_DECK -- 3671
	) -- 3671
	local s = self.room.scavenger -- 3673
	if s ~= nil then -- 3673
		local sx0 = self.scavX -- 3675
		self:drawBox( -- 3676
			draw, -- 3676
			w, -- 3676
			h, -- 3676
			sx0 - 12, -- 3676
			sx0 + 12, -- 3676
			0, -- 3676
			s.h - 14, -- 3676
			SCAV_BODY -- 3676
		) -- 3676
		self:drawBox( -- 3677
			draw, -- 3677
			w, -- 3677
			h, -- 3677
			sx0 - 7, -- 3677
			sx0 + 7, -- 3677
			s.h - 14, -- 3677
			s.h, -- 3677
			SCAV_HEAD -- 3677
		) -- 3677
		if self.scavState == "turn" then -- 3677
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3679
			draw:drawSegment( -- 3680
				Vec2( -- 3680
					self:sx(sx0, w), -- 3680
					self:sy(s.h - 6, h) -- 3680
				), -- 3680
				Vec2( -- 3680
					self:sx(fx, w), -- 3680
					self:sy(s.h - 6, h) -- 3680
				), -- 3680
				self:px(1), -- 3680
				INK -- 3680
			) -- 3680
		end -- 3680
	end -- 3680
	if self.hasBottle then -- 3680
		local p = self.player -- 3685
		self:drawBottle( -- 3686
			draw, -- 3686
			w, -- 3686
			h, -- 3686
			p.x + p.facing * 10, -- 3686
			p.y + p.h * 0.62 -- 3686
		) -- 3686
	end -- 3686
	if self.bottleFly ~= nil then -- 3686
		self:drawBottle( -- 3689
			draw, -- 3689
			w, -- 3689
			h, -- 3689
			self.bottleFly.x, -- 3689
			self.bottleFly.y -- 3689
		) -- 3689
	end -- 3689
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3689
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3692
		draw:drawCircle( -- 3693
			Vec2( -- 3693
				self:sx(self.bottleLandX, w), -- 3693
				self:sy(0, h) -- 3693
			), -- 3693
			self:px(r / ____exports.UNITS_PER_PX), -- 3693
			BRICK_LINE -- 3693
		) -- 3693
	end -- 3693
end -- 3660
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3697
	self:drawBox( -- 3698
		draw, -- 3698
		w, -- 3698
		h, -- 3698
		x - 3, -- 3698
		x + 3, -- 3698
		y - 10, -- 3698
		y, -- 3698
		BOTTLE -- 3698
	) -- 3698
end -- 3697
function Play.prototype.drawTrace(self, draw, w, h) -- 3701
	local t = self.trace -- 3702
	if t == nil or self.traceT <= 0 then -- 3702
		return -- 3704
	end -- 3704
	draw:drawSegment( -- 3706
		Vec2( -- 3707
			self:sx(t.x0, w), -- 3707
			self:sy(t.y0, h) -- 3707
		), -- 3707
		Vec2( -- 3708
			self:sx(t.x1, w), -- 3708
			self:sy(t.y1, h) -- 3708
		), -- 3708
		self:px(1), -- 3709
		t.hit and AIM_HIT or INK_DIM -- 3709
	) -- 3709
end -- 3701
function Play.prototype.drawAim(self, draw, w, h) -- 3712
	local v = self.view -- 3714
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3715
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3716
	local dot = self:px(1) -- 3717
	local arm = self:px(3) -- 3718
	local gap = self:px(1) -- 3719
	draw:drawSegment( -- 3720
		Vec2(gx - arm - gap, gy), -- 3720
		Vec2(gx - gap, gy), -- 3720
		dot / 2, -- 3720
		AIM -- 3720
	) -- 3720
	draw:drawSegment( -- 3721
		Vec2(gx + gap, gy), -- 3721
		Vec2(gx + arm + gap, gy), -- 3721
		dot / 2, -- 3721
		AIM -- 3721
	) -- 3721
	draw:drawSegment( -- 3722
		Vec2(gx, gy - arm - gap), -- 3722
		Vec2(gx, gy - gap), -- 3722
		dot / 2, -- 3722
		AIM -- 3722
	) -- 3722
	draw:drawSegment( -- 3723
		Vec2(gx, gy + gap), -- 3723
		Vec2(gx, gy + arm + gap), -- 3723
		dot / 2, -- 3723
		AIM -- 3723
	) -- 3723
	if self.room.key == "village" and self.hasBottle then -- 3723
		local p = self.player -- 3727
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3729
		local dir = ____end.x >= p.x and 1 or -1 -- 3730
		local x0 = p.x + dir * 10 -- 3731
		local y0 = p.y + p.h * 0.7 -- 3732
		local T = BOTTLE_FLY_TIME -- 3733
		local vx = (____end.x - x0) / T -- 3734
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3735
		local pxr = x0 -- 3736
		local pyr = y0 -- 3737
		local t = 1 -- 3738
		do -- 3738
			t = 1 -- 3739
			while t <= 12 do -- 3739
				local tt = t / 12 * T -- 3740
				local nx = x0 + vx * tt -- 3741
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3742
				draw:drawSegment( -- 3743
					Vec2( -- 3743
						self:sx(pxr, w), -- 3743
						self:sy(pyr, h) -- 3743
					), -- 3743
					Vec2( -- 3743
						self:sx(nx, w), -- 3743
						self:sy(ny, h) -- 3743
					), -- 3743
					self:px(1) / 2, -- 3743
					BOTTLE -- 3743
				) -- 3743
				pxr = nx -- 3744
				pyr = ny -- 3745
				t = t + 1 -- 3739
			end -- 3739
		end -- 3739
		draw:drawCircle( -- 3747
			Vec2( -- 3747
				self:sx(____end.x, w), -- 3747
				self:sy(____end.y + 2, h) -- 3747
			), -- 3747
			self:px(2), -- 3747
			BOTTLE -- 3747
		) -- 3747
	end -- 3747
end -- 3712
return ____exports -- 3712