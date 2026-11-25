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
function makeActor(room, index) -- 3939
	local sp = room.spawns -- 3940
	if index < 0 or index >= #sp then -- 3940
		return { -- 3942
			x = 0, -- 3942
			y = 0, -- 3942
			depth = 0, -- 3942
			depthSpeed = 0, -- 3942
			vx = 0, -- 3942
			vy = 0, -- 3942
			w = CHILD_W, -- 3942
			h = CHILD_H, -- 3942
			onGround = true, -- 3942
			facing = 1, -- 3942
			crouch = false, -- 3942
			rollT = 0, -- 3942
			covered = false, -- 3942
			alive = false -- 3942
		} -- 3942
	end -- 3942
	local s = sp[index + 1] -- 3944
	local child = s.h <= CHILD_H -- 3945
	local ground = room.depth -- 3946
	local depth = ground == nil and 0 or math.max( -- 3947
		ground.min, -- 3947
		math.min(ground.max, s.depth or 0) -- 3947
	) -- 3947
	return { -- 3948
		x = s.x, -- 3949
		y = s.y, -- 3949
		depth = depth, -- 3949
		depthSpeed = 0, -- 3949
		vx = 0, -- 3949
		vy = 0, -- 3949
		w = child and CHILD_W or SOLDIER_W, -- 3950
		h = child and CHILD_H or SOLDIER_H, -- 3951
		onGround = true, -- 3952
		facing = 1, -- 3952
		crouch = false, -- 3952
		rollT = 0, -- 3952
		covered = false, -- 3952
		alive = true -- 3952
	} -- 3952
end -- 3952
function drawFigure(draw, play, w, h, a, body, head) -- 3956
	if not a.alive then -- 3956
		return -- 3958
	end -- 3958
	local x0 = a.x - a.w / 2 -- 3960
	local x1 = a.x + a.w / 2 -- 3961
	local y0 = a.y + a.depth -- 3962
	local y1 = y0 + a.h -- 3963
	play:drawBox( -- 3964
		draw, -- 3964
		w, -- 3964
		h, -- 3964
		x0, -- 3964
		x1, -- 3964
		y0, -- 3964
		y1 - a.h * 0.26, -- 3964
		body -- 3964
	) -- 3964
	play:drawBox( -- 3965
		draw, -- 3965
		w, -- 3965
		h, -- 3965
		x0 + 2, -- 3965
		x1 - 2, -- 3965
		y1 - a.h * 0.26, -- 3965
		y1, -- 3965
		head -- 3965
	) -- 3965
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 3967
	play:drawBox( -- 3968
		draw, -- 3968
		w, -- 3968
		h, -- 3968
		eyeX, -- 3968
		eyeX + 4, -- 3968
		y1 - a.h * 0.14, -- 3968
		y1 - a.h * 0.08, -- 3968
		INK -- 3968
	) -- 3968
end -- 3968
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 3972
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 3973
end -- 3972
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 3980
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 3981
end -- 3980
function rayInterval(origin, direction, min, max) -- 3988
	if direction == 0 then -- 3988
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 3990
	end -- 3990
	local a = (min - origin) / direction -- 3992
	local b = (max - origin) / direction -- 3993
	return { -- 3994
		min = math.min(a, b), -- 3994
		max = math.max(a, b) -- 3994
	} -- 3994
end -- 3994
function hitBox(ray, box) -- 3998
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 3999
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4000
	local enter = math.max(0, x.min, y.min) -- 4001
	local leave = math.min(99999, x.max, y.max) -- 4002
	if box.depth ~= nil then -- 4002
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4004
		enter = math.max(enter, depth.min) -- 4005
		leave = math.min(leave, depth.max) -- 4006
	end -- 4006
	return leave >= enter and enter or -1 -- 4008
end -- 4008
function drawCartShape(draw, play, w, h, c, axleX) -- 4011
	local half = c.bodyW / 2 -- 4012
	local x0 = axleX - half -- 4013
	local x1 = axleX + half -- 4014
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4015
	play:drawBox( -- 4016
		draw, -- 4016
		w, -- 4016
		h, -- 4016
		x0, -- 4016
		x1, -- 4016
		axleY, -- 4016
		axleY + c.bodyH, -- 4016
		CART_FILL -- 4016
	) -- 4016
	draw:drawCircle( -- 4017
		Vec2( -- 4017
			play:sx(x0 + c.bodyW * 0.28, w), -- 4017
			play:sy(axleY, h) -- 4017
		), -- 4017
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4017
		Color(52, 50, 48, 255) -- 4017
	) -- 4017
	draw:drawCircle( -- 4018
		Vec2( -- 4018
			play:sx(x1 - c.bodyW * 0.28, w), -- 4018
			play:sy(axleY, h) -- 4018
		), -- 4018
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4018
		Color(52, 50, 48, 255) -- 4018
	) -- 4018
	local cx = c.clothSide < 0 and x0 or x1 -- 4019
	play:drawBox( -- 4020
		draw, -- 4020
		w, -- 4020
		h, -- 4020
		cx - 10, -- 4020
		cx + 10, -- 4020
		axleY + c.bodyH, -- 4020
		axleY + c.bodyH + 18, -- 4020
		CLOTH -- 4020
	) -- 4020
end -- 4020
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
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1743
		local p = self.player -- 1748
		self.bracedShield = { -- 1749
			x = p.x + p.facing * 26, -- 1749
			y = p.y, -- 1749
			w = 30, -- 1749
			h = 64, -- 1749
			hp = 1 -- 1749
		} -- 1749
		local ____self_boxes_33 = self.boxes -- 1749
		____self_boxes_33[#____self_boxes_33 + 1] = { -- 1750
			x0 = self.bracedShield.x - 15, -- 1751
			x1 = self.bracedShield.x + 15, -- 1751
			y0 = p.y, -- 1752
			y1 = p.y + 64, -- 1752
			depth = {min = -46, max = 46}, -- 1752
			label = "架起的残盾", -- 1752
			id = "braced_shield", -- 1752
			soft = true -- 1753
		} -- 1753
		inv.shield = inv.shield - 1 -- 1756
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1757
		self:log("架残盾") -- 1758
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1759
		return -- 1760
	end -- 1760
	if inv.pass > 0 and self.run.joined == false then -- 1760
		inv.pass = inv.pass - 1 -- 1763
		self.run.joined = true -- 1764
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1765
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1766
		return -- 1767
	end -- 1767
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1769
end -- 1724
function Play.prototype.useInteract(self, b) -- 1772
	local kind = b.interact == nil and "" or b.interact.kind -- 1773
	local wr = self.room -- 1774
	if kind == "open_board" then -- 1774
		b.broken = true -- 1776
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1777
		for ____, cover in ipairs(self.boxes) do -- 1778
			if cover.id == "s2_board_cover" then -- 1778
				cover.broken = false -- 1780
				cover.hidden = false -- 1781
			end -- 1781
		end -- 1781
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1784
		self.run.joined = true -- 1785
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1786
		self:log("放下窗板") -- 1787
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1788
		return -- 1789
	end -- 1789
	if kind == "lower_curtain" then -- 1789
		for ____, curtain in ipairs(self.boxes) do -- 1792
			if curtain.id == "c2_curtain" then -- 1792
				curtain.broken = false -- 1794
				curtain.hidden = false -- 1795
			end -- 1795
		end -- 1795
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1798
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1799
		self:log("放下木帘") -- 1800
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1801
		return -- 1802
	end -- 1802
	if kind == "raise_latch" then -- 1802
		if wr.key == "c2-granary" and not self.cartDocked then -- 1802
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1806
			return -- 1807
		end -- 1807
		b.broken = true -- 1809
		self.objectiveDone = true -- 1810
		if wr.key == "c1-yard" then -- 1810
			self.run.c1Latch = true -- 1813
			self.run.joined = true -- 1814
		else -- 1814
			self.run.c2Latch = true -- 1816
			self.run.joined = true -- 1817
		end -- 1817
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1819
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1820
		self:log("抬闩") -- 1821
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1822
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1823
	end -- 1823
end -- 1772
function Play.prototype.stepCampaignCart(self, dt, input) -- 1828
	local wr = self.room -- 1829
	local c = wr.cart -- 1830
	if c.bodyW <= 0 then -- 1830
		return -- 1832
	end -- 1832
	local p = self.player -- 1834
	local handleX = self.cartAxle + c.handleOffset -- 1835
	if not self.gripping then -- 1835
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1835
			self.gripping = true -- 1839
			self:flashSet("握住车柄 · A/D 推", 1) -- 1840
		end -- 1840
		return -- 1842
	end -- 1842
	if input.interact.pressed then -- 1842
		self.gripping = false -- 1845
		self:flashSet("松手", 0.5) -- 1846
		return -- 1847
	end -- 1847
	if not self.cartDocked then -- 1847
		if input.moveX ~= 0 and not self:stuckCart() then -- 1847
			self.cartAxle = math.max( -- 1851
				c.startX, -- 1851
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1851
			) -- 1851
		end -- 1851
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1851
			self.cartExposed = true -- 1856
			local gun = nil -- 1857
			local gi = 0 -- 1858
			do -- 1858
				gi = 0 -- 1859
				while gi < #self.enemies do -- 1859
					local e = self.enemies[gi + 1] -- 1860
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1860
						gun = e -- 1862
						break -- 1863
					end -- 1863
					gi = gi + 1 -- 1859
				end -- 1859
			end -- 1859
			if gun ~= nil then -- 1859
				self:campaignEnemyFire(gun) -- 1867
			end -- 1867
		end -- 1867
		p.x = self.cartAxle + c.handleOffset -- 1870
		p.y = c.baseY + (c.depth or 0) -- 1871
		p.vx = 0 -- 1872
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1872
			self.cartAxle = c.endX -- 1874
			self.cartDocked = true -- 1875
			self.gripping = false -- 1876
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1877
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1878
			self:flashSet("车轮入窝", 1.2) -- 1879
			self:log("车轮入窝") -- 1880
		end -- 1880
	end -- 1880
end -- 1828
function Play.prototype.stuckCart(self) -- 1886
	local i = 0 -- 1887
	do -- 1887
		i = 0 -- 1888
		while i < #self.boxes do -- 1888
			do -- 1888
				local b = self.boxes[i + 1] -- 1889
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1889
					goto __continue304 -- 1891
				end -- 1891
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1893
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1893
					return true -- 1895
				end -- 1895
			end -- 1895
			::__continue304:: -- 1895
			i = i + 1 -- 1888
		end -- 1888
	end -- 1888
	return false -- 1898
end -- 1886
function Play.prototype.stepCampaignGoal(self) -- 1902
	local wr = self.room -- 1903
	local c = wr.campaign -- 1904
	if c == nil then -- 1904
		return -- 1906
	end -- 1906
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1906
		self.objectiveDone = true -- 1909
	end -- 1909
	if c.goal == "reach_exit" then -- 1909
		self.objectiveDone = true -- 1912
	end -- 1912
	if not self.objectiveDone then -- 1912
		return -- 1915
	end -- 1915
	local p = self.player -- 1917
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1918
	if p.x < c.exitX or not partnerOk then -- 1918
		return -- 1920
	end -- 1920
	if c.next ~= nil and c.next ~= "" then -- 1920
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1923
		self:flashSet("过关 · " .. c.next, 1.2) -- 1924
	elseif not self.run.finished then -- 1924
		self.run.finished = true -- 1926
		self:flashSet( -- 1927
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1927
			2 -- 1927
		) -- 1927
		self:log("C2 灰盒完成") -- 1928
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1929
	end -- 1929
end -- 1902
function Play.prototype.stepCampaignPartner(self, dt) -- 1934
	local a = self.partner -- 1935
	local wr = self.room -- 1936
	local cp = wr.companion -- 1937
	if not a.alive then -- 1937
		return -- 1939
	end -- 1939
	local p = self.player -- 1941
	local wait = false -- 1942
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1943
	local targetDepth = p.depth -- 1944
	if self.run.joined == false then -- 1944
		wait = true -- 1946
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1947
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1948
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1948
		wait = true -- 1950
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1951
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1952
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1952
		wait = true -- 1954
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1955
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1956
	end -- 1956
	if self.partnerStuck > 0.3 then -- 1956
		a.x = a.x - a.facing * 30 -- 1960
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1961
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1962
		self.partnerLaneHold = 1.1 -- 1963
		self.partnerStuck = 0 -- 1964
	end -- 1964
	if self.partnerLaneHold > 0 then -- 1964
		self.partnerLaneHold = self.partnerLaneHold - dt -- 1967
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1968
	end -- 1968
	local dx = targetX - a.x -- 1970
	if not wait and math.abs(dx) > 74 then -- 1970
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 1972
		local before = a.x -- 1973
		a.vx = dx > 0 and speed or -speed -- 1974
		a.facing = dx > 0 and 1 or -1 -- 1975
		self:slideX(a, a.vx * dt) -- 1976
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 1976
			a.vy = CHILD_JUMP -- 1979
			a.onGround = false -- 1980
		end -- 1980
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 1982
	else -- 1982
		a.vx = 0 -- 1984
		self.partnerStuck = 0 -- 1985
	end -- 1985
	local dz = targetDepth - a.depth -- 1987
	if math.abs(dz) > 6 then -- 1987
		local step = math.max( -- 1989
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 1989
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 1989
		) -- 1989
		a.depth = a.depth + step -- 1990
	end -- 1990
	a.depthSpeed = 0 -- 1992
	a.h = CHILD_H -- 1993
	a.crouch = false -- 1994
	self:fallY(a, dt) -- 1995
end -- 1934
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 1999
	local p = self.player -- 2000
	local i = 0 -- 2001
	do -- 2001
		i = 0 -- 2002
		while i < #self.enemies do -- 2002
			do -- 2002
				local e = self.enemies[i + 1] -- 2003
				if not e.alive then -- 2003
					goto __continue328 -- 2005
				end -- 2005
				if e.hitT > 0 then -- 2005
					e.hitT = e.hitT - dt -- 2008
				end -- 2008
				if e.kind == "breaker" then -- 2008
					self:stepBreaker(e, dt) -- 2011
					goto __continue328 -- 2012
				end -- 2012
				if e.kind == "shield" then -- 2012
					self:stepShield(e, dt, input) -- 2015
					goto __continue328 -- 2016
				end -- 2016
				local dx = e.x - p.x -- 2019
				if not e.awake then -- 2019
					if math.abs(dx) > 520 then -- 2019
						goto __continue328 -- 2022
					end -- 2022
					e.awake = true -- 2024
					e.fireCd = 48 -- 2025
					goto __continue328 -- 2026
				end -- 2026
				if math.abs(dx) > ENEMY_RANGE then -- 2026
					goto __continue328 -- 2029
				end -- 2029
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2029
					goto __continue328 -- 2034
				end -- 2034
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2034
					goto __continue328 -- 2037
				end -- 2037
				if self:blockedShot(e, p) then -- 2037
					if e.warnT > 0 then -- 2037
						e.warnT = 0 -- 2043
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2044
					end -- 2044
					goto __continue328 -- 2046
				end -- 2046
				if e.warnT > 0 then -- 2046
					e.warnT = e.warnT - 1 -- 2049
					if e.warnT <= 0 then -- 2049
						self:campaignEnemyFire(e) -- 2051
					end -- 2051
				elseif e.fireCd > 0 then -- 2051
					e.fireCd = e.fireCd - 1 -- 2054
					if e.fireCd <= 0 then -- 2054
						e.warnT = WARN_TICKS -- 2056
					end -- 2056
				else -- 2056
					e.fireCd = 40 -- 2059
				end -- 2059
			end -- 2059
			::__continue328:: -- 2059
			i = i + 1 -- 2002
		end -- 2002
	end -- 2002
end -- 1999
function Play.prototype.blockedShot(self, e, p) -- 2065
	local eDepth = e.depth or 0 -- 2066
	local ex = e.x -- 2067
	local ey = e.y + e.h * 0.62 -- 2069
	local px = p.x -- 2070
	local py = p.y + p.h * 0.55 -- 2071
	local dx = px - ex -- 2072
	local dyScreen = py + p.depth - (ey + eDepth) -- 2073
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 2074
	if len < 0.01 then -- 2074
		return false -- 2076
	end -- 2076
	local ray = { -- 2080
		x = ex, -- 2081
		y = ey, -- 2081
		dx = dx / len, -- 2082
		dy = (py - ey) / len, -- 2082
		depth = eDepth, -- 2083
		dDepth = (p.depth - eDepth) / len -- 2083
	} -- 2083
	local best = -1 -- 2085
	local j = 0 -- 2086
	do -- 2086
		j = 0 -- 2087
		while j < #self.boxes do -- 2087
			do -- 2087
				local b = self.boxes[j + 1] -- 2088
				if b.broken == true or b.passable == true then -- 2088
					goto __continue348 -- 2090
				end -- 2090
				if b.id == "braced_shield" then -- 2090
					goto __continue348 -- 2095
				end -- 2095
				local t = hitBox(ray, b) -- 2097
				if t >= 0 and t < len - 2 and (best < 0 or t < best) then -- 2097
					best = t -- 2099
				end -- 2099
			end -- 2099
			::__continue348:: -- 2099
			j = j + 1 -- 2087
		end -- 2087
	end -- 2087
	return best >= 0 -- 2102
end -- 2065
function Play.prototype.campaignEnemyFire(self, e) -- 2105
	local p = self.player -- 2106
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2107
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2107
		local ____self_bracedShield_34, ____hp_35 = self.bracedShield, "hp" -- 2107
		____self_bracedShield_34[____hp_35] = ____self_bracedShield_34[____hp_35] - 1 -- 2109
		self.boxes = __TS__ArrayFilter( -- 2110
			self.boxes, -- 2110
			function(____, b) return b.id ~= "braced_shield" end -- 2110
		) -- 2110
		self.bracedShield = nil -- 2111
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2112
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2113
		return -- 2114
	end -- 2114
	if self:blockedShot(e, p) then -- 2114
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2117
		return -- 2118
	end -- 2118
	local cover = self:blockedByCover(e, p) -- 2120
	if cover ~= nil and self.coverHug then -- 2120
		self.coveredFlash = 0.5 -- 2122
		self:flashSet("掩体挡下", 0.6) -- 2123
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2124
		return -- 2129
	end -- 2129
	if self.invulnT > 0 then -- 2129
		return -- 2132
	end -- 2132
	self.invulnT = INVULN_HIT_TICKS -- 2134
	self.craftT = 0 -- 2135
	self.hp = self.hp - 1 -- 2136
	self:emit("actorHit", { -- 2137
		target = "player", -- 2137
		amount = 1, -- 2137
		hp = self.hp, -- 2137
		maxHp = self.maxHp, -- 2137
		enemyX = e.x -- 2137
	}) -- 2137
	self:flashSet( -- 2138
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2138
		0.8 -- 2138
	) -- 2138
	if self.hp <= 0 then -- 2138
		self:campaignFailed() -- 2140
	end -- 2140
end -- 2105
function Play.prototype.stepShield(self, e, dt, input) -- 2145
	local p = self.player -- 2146
	local dx = p.x - e.x -- 2147
	local adx = math.abs(dx) -- 2148
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2151
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2152
	if adx > 150 then -- 2152
		local before = e.x -- 2154
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2155
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2155
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2158
		end -- 2158
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2158
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2163
		local rollDodges = p.rollT > 0 and fromFront -- 2164
		if not rollDodges and self.invulnT <= 0 then -- 2164
			self.invulnT = INVULN_HIT_TICKS -- 2166
			self.craftT = 0 -- 2167
			self.hp = self.hp - 1 -- 2168
			self:emit("actorHit", { -- 2169
				target = "player", -- 2169
				amount = 1, -- 2169
				hp = self.hp, -- 2169
				maxHp = self.maxHp, -- 2169
				enemyX = e.x -- 2169
			}) -- 2169
			self:flashSet( -- 2170
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2170
				0.8 -- 2170
			) -- 2170
			if self.hp <= 0 then -- 2170
				self:campaignFailed() -- 2172
				return -- 2173
			end -- 2173
		end -- 2173
		e.swingT = 70 -- 2176
	end -- 2176
	if (e.swingT or 0) > 0 then -- 2176
		e.swingT = (e.swingT or 0) - 1 -- 2179
	end -- 2179
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2179
		local dd = p.depth - (e.depth or 0) -- 2182
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2183
	end -- 2183
end -- 2145
function Play.prototype.stepBreaker(self, e, dt) -- 2188
	local p = self.player -- 2189
	if e.awake ~= true then -- 2189
		if math.abs(p.x - e.x) < 560 then -- 2189
			e.awake = true -- 2192
		else -- 2192
			return -- 2194
		end -- 2194
	end -- 2194
	local target = nil -- 2197
	local bestD = 1000000000 -- 2198
	local i = 0 -- 2199
	do -- 2199
		i = 0 -- 2200
		while i < #self.boxes do -- 2200
			do -- 2200
				local b = self.boxes[i + 1] -- 2201
				if b.breakable == nil or b.broken == true then -- 2201
					goto __continue372 -- 2203
				end -- 2203
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2205
				if d < bestD then -- 2205
					bestD = d -- 2207
					target = b -- 2208
				end -- 2208
			end -- 2208
			::__continue372:: -- 2208
			i = i + 1 -- 2200
		end -- 2200
	end -- 2200
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2211
	local dx = tx - e.x -- 2212
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2213
	if math.abs(dx) > reach then -- 2213
		local before = e.x -- 2215
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2216
		if math.abs(e.x - before) < 0.3 then -- 2216
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2218
		end -- 2218
	elseif (e.swingT or 0) <= 0 then -- 2218
		e.swingT = 64 -- 2221
		if target ~= nil then -- 2221
			self:damageProp(target, 2) -- 2223
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2223
			self.invulnT = INVULN_HIT_TICKS -- 2225
			self.craftT = 0 -- 2226
			self.hp = self.hp - 1 -- 2227
			self:emit("actorHit", { -- 2228
				target = "player", -- 2228
				amount = 1, -- 2228
				hp = self.hp, -- 2228
				maxHp = self.maxHp, -- 2228
				enemyX = e.x -- 2228
			}) -- 2228
			self:flashSet("破障手近身", 0.8) -- 2229
			if self.hp <= 0 then -- 2229
				self:campaignFailed() -- 2231
				return -- 2232
			end -- 2232
		end -- 2232
	end -- 2232
	if (e.swingT or 0) > 0 then -- 2232
		e.swingT = (e.swingT or 0) - 1 -- 2237
	end -- 2237
end -- 2188
function Play.prototype.campaignFailed(self) -- 2241
	local p = self.player -- 2242
	self.hp = self.maxHp -- 2243
	self.invulnT = INVULN_RESPAWN_TICKS -- 2244
	self.reloadT = 0 -- 2245
	self.gripping = false -- 2246
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2247
	self:log("被击倒") -- 2248
	p.x = self.room.minX + 90 -- 2249
	p.y = 0 -- 2250
	p.depth = 0 -- 2251
	p.vx = 0 -- 2252
	p.vy = 0 -- 2253
	p.onGround = true -- 2254
	p.rollT = 0 -- 2255
	self.partner.x = p.x - 50 -- 2256
	self.partner.y = 0 -- 2257
	self.partner.depth = 0 -- 2258
	self.cam.x = p.x -- 2259
	local i = 0 -- 2260
	do -- 2260
		i = 0 -- 2261
		while i < #self.enemies do -- 2261
			do -- 2261
				local e = self.enemies[i + 1] -- 2262
				if not e.alive then -- 2262
					goto __continue384 -- 2264
				end -- 2264
				e.x = e.homeX == nil and e.x or e.homeX -- 2266
				e.warnT = 0 -- 2267
				e.fireCd = 40 -- 2268
				e.swingT = 0 -- 2269
				e.awake = false -- 2270
			end -- 2270
			::__continue384:: -- 2270
			i = i + 1 -- 2261
		end -- 2261
	end -- 2261
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2272
end -- 2241
function Play.prototype.stepEnemies(self, dt, input) -- 2275
	local i = 0 -- 2276
	do -- 2276
		i = 0 -- 2277
		while i < #self.enemies do -- 2277
			local e = self.enemies[i + 1] -- 2278
			if e.hitT > 0 then -- 2278
				e.hitT = e.hitT - dt -- 2280
			end -- 2280
			i = i + 1 -- 2277
		end -- 2277
	end -- 2277
	if self.coveredFlash > 0 then -- 2277
		self.coveredFlash = self.coveredFlash - dt -- 2284
	end -- 2284
	if self.isCampaign then -- 2284
		self:stepCampaignEnemies(dt, input) -- 2287
		return -- 2288
	end -- 2288
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2288
		return -- 2292
	end -- 2292
	do -- 2292
		i = 0 -- 2294
		while i < #self.enemies do -- 2294
			do -- 2294
				local e = self.enemies[i + 1] -- 2295
				if not e.alive then -- 2295
					goto __continue394 -- 2297
				end -- 2297
				if e.warnT > 0 then -- 2297
					e.warnT = e.warnT - 1 -- 2300
					if e.warnT <= 0 then -- 2300
						self:enemyFire(e, input) -- 2302
					end -- 2302
					goto __continue394 -- 2304
				end -- 2304
				if e.fireCd > 0 then -- 2304
					e.fireCd = e.fireCd - 1 -- 2307
					if e.fireCd <= 0 then -- 2307
						e.warnT = WARN_TICKS -- 2309
					end -- 2309
				else -- 2309
					e.warnT = WARN_TICKS -- 2313
				end -- 2313
			end -- 2313
			::__continue394:: -- 2313
			i = i + 1 -- 2294
		end -- 2294
	end -- 2294
end -- 2275
function Play.prototype.enemyFire(self, e, input) -- 2319
	local p = self.player -- 2320
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2320
		self:flashSet("枪声响在远处", 0.4) -- 2322
		e.fireCd = FIRE_COOLDOWN -- 2323
		return -- 2324
	end -- 2324
	local cover = self:blockedByCover(e, p) -- 2327
	local hugging = cover ~= nil -- 2328
	self.coverBlocking = hugging -- 2329
	local covered = hugging and input.cover.held -- 2330
	if covered then -- 2330
		self.coveredFlash = 0.5 -- 2332
		self:flashSet("掩体挡下", 0.5) -- 2333
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2334
		e.fireCd = FIRE_COOLDOWN -- 2339
		return -- 2340
	end -- 2340
	self.hp = self.hp - 1 -- 2342
	self:emit("actorHit", { -- 2343
		target = "player", -- 2343
		amount = 1, -- 2343
		hp = self.hp, -- 2343
		maxHp = self.maxHp, -- 2343
		enemyX = e.x -- 2343
	}) -- 2343
	self:flashSet( -- 2344
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2344
		0.7 -- 2344
	) -- 2344
	e.fireCd = FIRE_COOLDOWN -- 2345
	if self.hp <= 0 then -- 2345
		self:gateFailed() -- 2347
	end -- 2347
end -- 2319
function Play.prototype.blockedByCover(self, enemy, p) -- 2352
	local b = self:coverAt(p) -- 2353
	if b == nil then -- 2353
		return nil -- 2355
	end -- 2355
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2357
end -- 2352
function Play.prototype.gateFailed(self) -- 2361
	local ____temp_36 -- 2362
	if self.room.story == nil then -- 2362
		____temp_36 = nil -- 2362
	else -- 2362
		____temp_36 = self.room.story.gate -- 2362
	end -- 2362
	local g = ____temp_36 -- 2362
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2363
	self.hp = self.maxHp -- 2364
	self.gateTick = 0 -- 2365
	self.gateSpawned = 0 -- 2366
	self.enemies = {} -- 2367
	self.gateFailCount = self.gateFailCount + 1 -- 2368
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2370
	self.player.y = 0 -- 2371
	self.player.vy = 0 -- 2372
	self.player.depth = 0 -- 2373
	self.player.depthSpeed = 0 -- 2374
	self.player.onGround = true -- 2375
	self.player.crouch = false -- 2376
	self.player.h = SOLDIER_H -- 2377
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2378
	self.partner.y = 0 -- 2379
	self.partner.vy = 0 -- 2380
	self.partner.depth = 0 -- 2381
	self.partner.depthSpeed = 0 -- 2382
	self.partner.onGround = true -- 2383
	self.cam.x = self.player.x -- 2384
	self.phase = "gate-idle" -- 2385
	self.phaseTick = 0 -- 2386
	self.coverHug = false -- 2387
	self.coverBlocking = false -- 2388
	self.coverEntity = "" -- 2389
	self.gateNeedConfirm = true -- 2390
	self.gateRestartArmed = false -- 2391
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2392
end -- 2361
function Play.prototype.stepInteract(self, dt, input) -- 2395
	local p = self.player -- 2396
	local calmUsed = self.calmConsumed -- 2397
	self.calmConsumed = false -- 2398
	local calming = self.escort.state == "calming" -- 2400
	self.focusCart = false -- 2401
	if self.room.key == "outside" then -- 2401
		local c = self.room.cart -- 2403
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2404
		local dy = p.y - c.baseY -- 2405
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2406
	end -- 2406
	if not calmUsed and not calming then -- 2406
		self:stepCart(dt, input) -- 2410
	end -- 2410
	if calmUsed then -- 2410
		self:flashSet("安抚 · 敲两下", 0.8) -- 2415
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2415
		if self.knockT > 0 then -- 2415
			self.knocks = self.knocks + 1 -- 2419
		else -- 2419
			self.knocks = 1 -- 2421
		end -- 2421
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2423
		self.knockT = 1.2 -- 2424
		if self.knocks >= 2 then -- 2424
			self:flashSet("敲两下", 0.8) -- 2426
			self.knocks = 0 -- 2427
		else -- 2427
			self:flashSet("敲一下", 0.5) -- 2429
		end -- 2429
	elseif self.knockT > 0 then -- 2429
		self.knockT = self.knockT - dt -- 2432
		if self.knockT <= 0 then -- 2432
			self.knocks = 0 -- 2434
		end -- 2434
	end -- 2434
	local i = 0 -- 2439
	do -- 2439
		i = 0 -- 2440
		while i < #self.room.marks do -- 2440
			do -- 2440
				local m = self.room.marks[i + 1] -- 2441
				if m.kind ~= 0 then -- 2441
					goto __continue420 -- 2443
				end -- 2443
				local subjects = {self.partner, self.player} -- 2445
				local k = 0 -- 2446
				do -- 2446
					k = 0 -- 2447
					while k < #subjects do -- 2447
						do -- 2447
							local s = subjects[k + 1] -- 2448
							if not s.alive then -- 2448
								goto __continue423 -- 2450
							end -- 2450
							local dx = s.x - m.x -- 2452
							local dy = s.y - m.y -- 2453
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2453
								self.checkpoint = m.x -- 2455
								self.checkpointCartAxle = self.cartAxle -- 2456
								if self.cartDocked then -- 2456
									self:flashSet("检查点 · 车已落窝", 1) -- 2458
								else -- 2458
									self:flashSet("检查点 · 车还没到位", 1) -- 2460
								end -- 2460
							end -- 2460
						end -- 2460
						::__continue423:: -- 2460
						k = k + 1 -- 2447
					end -- 2447
				end -- 2447
			end -- 2447
			::__continue420:: -- 2447
			i = i + 1 -- 2440
		end -- 2440
	end -- 2440
	self:checkCarryGate() -- 2466
end -- 2395
function Play.prototype.stepVillage(self, dt, input) -- 2470
	if self.room.key ~= "village" then -- 2470
		return -- 2472
	end -- 2472
	local p = self.player -- 2474
	local bottle = self.room.bottle -- 2475
	local scav = self.room.scavenger -- 2476
	if not self.hasBottle and bottle ~= nil then -- 2476
		local dx = p.x - bottle.x -- 2480
		local dy = p.y + p.h * 0.5 - bottle.y -- 2481
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2481
			self.hasBottle = true -- 2483
			self:flashSet("拾起瓶子", 0.8) -- 2484
		end -- 2484
	end -- 2484
	if self.hasBottle then -- 2484
		if input.aim.held then -- 2484
			self.aimHold = self.aimHold + dt -- 2491
			if self.aimHold > 1.2 then -- 2491
				self.aimHold = 1.2 -- 2493
			end -- 2493
			local cached = self:bottleEnd() -- 2496
			self.bottleAimX = cached.x -- 2497
			self.bottleAimY = cached.y -- 2498
		elseif input.aim.released then -- 2498
			if self.aimHold < 0.12 then -- 2498
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2502
				self.aimHold = 0 -- 2503
			else -- 2503
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2505
				self:throwBottle(____end.x, ____end.y) -- 2506
				self.aimHold = 0 -- 2507
			end -- 2507
		end -- 2507
	else -- 2507
		self.aimHold = 0 -- 2511
		self.bottleAimX = -1 -- 2512
	end -- 2512
	local fly = self.bottleFly -- 2517
	if fly ~= nil then -- 2517
		fly.t = fly.t + dt -- 2519
		fly.x = fly.x0 + fly.vx * fly.t -- 2520
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2521
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2522
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2522
			self:landBottle(fly) -- 2524
		end -- 2524
	end -- 2524
	if self.bottleLandT > 0 then -- 2524
		self.bottleLandT = self.bottleLandT - dt -- 2528
	end -- 2528
	if scav ~= nil then -- 2528
		self:stepScav(dt, scav) -- 2532
	end -- 2532
	local line = self.room.passLine -- 2535
	if line ~= nil and not self.passed and p.x >= line then -- 2535
		self.passed = true -- 2537
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2538
	end -- 2538
	if self.passed and p.x >= self.ox + 640 then -- 2538
		self:requestRoom("forest", "过第一院出院") -- 2542
		self:flashSet("出院 · 北塔森林", 1.4) -- 2543
	end -- 2543
end -- 2470
function Play.prototype.bottleEnd(self) -- 2548
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2549
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2552
	return {x = aim.x, y = g} -- 2553
end -- 2548
function Play.prototype.throwBottle(self, tx, ty) -- 2557
	local p = self.player -- 2558
	local dir = tx >= p.x and 1 or -1 -- 2560
	p.facing = dir -- 2561
	local x0 = p.x + dir * 10 -- 2562
	local y0 = p.y + p.h * 0.7 -- 2563
	self.bottleTargetX = tx -- 2564
	self.bottleTargetY = ty -- 2565
	self.bottleSurfaceY = ty -- 2566
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2567
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2568
	self.bottleFly = { -- 2569
		x = x0, -- 2569
		y = y0, -- 2569
		x0 = x0, -- 2569
		y0 = y0, -- 2569
		vx = vx, -- 2569
		vy = vy, -- 2569
		t = 0 -- 2569
	} -- 2569
	self.hasBottle = false -- 2570
	self:flashSet("投出", 0.4) -- 2571
	self:emit( -- 2572
		"bottleThrown", -- 2572
		{ -- 2572
			fromX = x0, -- 2573
			fromY = y0, -- 2574
			targetX = tx, -- 2575
			targetY = ty, -- 2576
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2577
		} -- 2577
	) -- 2577
end -- 2557
function Play.prototype.landBottle(self, fly) -- 2582
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2583
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2584
	local s = self.room.scavenger -- 2585
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2586
	self.bottleFly = nil -- 2587
	self.bottleTargetX = -1 -- 2588
	self.bottleTargetY = 0 -- 2589
	self.bottleSurfaceY = -1 -- 2590
	self.bottleLandX = x -- 2591
	self.bottleLandY = y -- 2592
	self.bottleLandT = 0.9 -- 2593
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2594
	self:hearBottle(x) -- 2595
end -- 2582
function Play.prototype.hearBottle(self, x) -- 2599
	local s = self.room.scavenger -- 2600
	if s == nil then -- 2600
		return -- 2602
	end -- 2602
	if math.abs(x - self.scavX) > s.range then -- 2602
		self:flashSet("落地 · 他没听见", 0.6) -- 2605
		return -- 2606
	end -- 2606
	self.scavState = "turn" -- 2608
	self.scavT = s.hearTicks -- 2609
	self.scavTargetX = x -- 2610
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2611
end -- 2599
function Play.prototype.stepScav(self, dt, s) -- 2615
	if self.scavState == "chase" then -- 2615
		return -- 2618
	end -- 2618
	if self.scavState == "turn" then -- 2618
		self.scavT = self.scavT - 1 -- 2621
		if self.scavT <= 0 then -- 2621
			self.scavState = "walk" -- 2623
		end -- 2623
		return -- 2625
	end -- 2625
	if self.scavState == "walk" then -- 2625
		local d = self.scavTargetX - self.scavX -- 2628
		if math.abs(d) < 4 then -- 2628
			self.scavState = "stall" -- 2630
			self.scavT = s.stallTicks -- 2631
			return -- 2632
		end -- 2632
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2634
		return -- 2635
	end -- 2635
	if self.scavState == "stall" then -- 2635
		self.scavT = self.scavT - 1 -- 2638
		if self.scavT <= 0 then -- 2638
			self.scavState = "back" -- 2640
		end -- 2640
		return -- 2642
	end -- 2642
	if self.scavState == "back" then -- 2642
		local home = math.max( -- 2645
			s.x0, -- 2645
			math.min(s.x1, self.scavX) -- 2645
		) -- 2645
		if math.abs(home - self.scavX) < 2 then -- 2645
			self.scavState = "patrol" -- 2647
			return -- 2648
		end -- 2648
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2650
		return -- 2651
	end -- 2651
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2653
	if self.scavX >= s.x1 then -- 2653
		self.scavX = s.x1 -- 2655
		self.scavDir = -1 -- 2656
	elseif self.scavX <= s.x0 then -- 2656
		self.scavX = s.x0 -- 2658
		self.scavDir = 1 -- 2659
	end -- 2659
end -- 2615
function Play.prototype.stepCart(self, dt, input) -- 2667
	local p = self.player -- 2668
	local c = self.room.cart -- 2669
	if self.gripping then -- 2669
		if not input.interact.held then -- 2669
			self.gripping = false -- 2673
			self:flashSet("松开车把", 0.4) -- 2674
			return -- 2675
		end -- 2675
	else -- 2675
		if not input.interact.pressed then -- 2675
			return -- 2679
		end -- 2679
		if not self:cartHandleInReach(p) then -- 2679
			return -- 2682
		end -- 2682
		local track = c.depth or 0 -- 2684
		if self:limitDepth(p, track) ~= track then -- 2684
			return -- 2686
		end -- 2686
		p.depth = track -- 2688
		p.depthSpeed = 0 -- 2689
		self.gripping = true -- 2690
		self:flashSet("握住车把", 0.4) -- 2691
		return -- 2692
	end -- 2692
	if self.cartDocked then -- 2692
		return -- 2696
	end -- 2696
	local dir = input.moveX -- 2698
	if dir == 0 then -- 2698
		return -- 2700
	end -- 2700
	local lo = math.min(c.startX, c.endX) -- 2702
	local hi = math.max(c.startX, c.endX) -- 2703
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2704
	if next < lo then -- 2704
		next = lo -- 2706
	end -- 2706
	if next > hi then -- 2706
		next = hi -- 2709
	end -- 2709
	local delta = next - self.cartAxle -- 2711
	if delta == 0 then -- 2711
		return -- 2713
	end -- 2713
	self.cartAxle = next -- 2715
	p.x = p.x + delta -- 2716
	p.facing = dir > 0 and 1 or -1 -- 2717
	self:slideX(p, 0) -- 2718
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2718
		self.gripping = false -- 2720
		self:flashSet("跟不上了，脱手", 0.6) -- 2721
		return -- 2722
	end -- 2722
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2722
		self.cartDocked = true -- 2725
		self.gripping = false -- 2726
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2727
		self:flashSet("车轮落窝", 1.2) -- 2728
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2728
		self:flashSet("车轮回到起点", 0.5) -- 2730
	end -- 2730
end -- 2667
function Play.prototype.requestRoom(self, key, reason) -- 2738
	if self.wantRoom ~= "" then -- 2738
		return -- 2742
	end -- 2742
	self.wantRoom = key -- 2744
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2745
end -- 2738
function Play.prototype.checkCarryGate(self) -- 2752
	if self.room.key == "checkpoint" then -- 2752
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2752
			self.carryCartAxle = self.cartAxle -- 2755
			self.carryCartDocked = self.cartDocked -- 2756
			self:requestRoom("gate", "检查站出口") -- 2757
			self:flashSet("出检查站 · 城门", 1.2) -- 2758
		end -- 2758
		return -- 2760
	end -- 2760
	if self.room.key == "outside" then -- 2760
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2760
			self.carryCartAxle = self.cartAxle -- 2766
			self.carryCartDocked = self.cartDocked -- 2767
			self:requestRoom("village", "墙根走完") -- 2768
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2769
		end -- 2769
	end -- 2769
end -- 2752
function Play.prototype.aimAt(self, wx, wy) -- 2776
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2777
	self.aimX = s.x -- 2778
	self.aimY = s.y -- 2779
end -- 2776
function Play.prototype.shoot(self, a) -- 2782
	if self.isCampaign and self.reloadT > 0 then -- 2782
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2784
		return -- 2785
	end -- 2785
	local ox = a.x + a.facing * 8 -- 2787
	local muzzleY = a.y + a.h * 0.72 -- 2788
	local oy = muzzleY + a.depth -- 2789
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2791
	local dx = aim.x - ox -- 2794
	local dy = aim.y - oy -- 2795
	local len = math.sqrt(dx * dx + dy * dy) -- 2796
	if len < 0.001 then -- 2796
		dx = a.facing -- 2798
		dy = 0 -- 2799
	else -- 2799
		dx = dx / len -- 2801
		dy = dy / len -- 2802
	end -- 2802
	if dx ~= 0 then -- 2802
		a.facing = dx > 0 and 1 or -1 -- 2805
	end -- 2805
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2808
	local hitEnemy = self:raycastEnemies(ray) -- 2809
	local tEnemy = hitEnemy.t -- 2810
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2811
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2812
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2813
	local tWall = solid.t -- 2814
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2815
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2816
	self.trace = { -- 2818
		x0 = ox, -- 2818
		y0 = oy, -- 2818
		x1 = ox + dx * t, -- 2818
		y1 = oy + dy * t, -- 2818
		hit = hit -- 2818
	} -- 2818
	self.traceT = 0.12 -- 2819
	self:applyFireDanger(ox) -- 2820
	local killed = false -- 2821
	if hit then -- 2821
		local i = hitEnemy.index -- 2823
		local e = self.enemies[i + 1] -- 2824
		local impactY = oy + dy * tEnemy -- 2825
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2826
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2827
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2827
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2829
			e.hitT = 0.3 -- 2830
			self:flashSet( -- 2831
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2831
				0.8 -- 2831
			) -- 2831
			self:emit("shotResolved", { -- 2832
				hit = true, -- 2833
				enemyIndex = i, -- 2833
				enemyX = e.x, -- 2833
				aimX = aim.x, -- 2833
				aimY = aim.y, -- 2833
				impactX = ox + dx * t, -- 2834
				impactY = oy + dy * t, -- 2834
				shield = true -- 2834
			}) -- 2834
			self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2836
			return -- 2837
		end -- 2837
		e.alive = false -- 2839
		e.hitT = 0.4 -- 2840
		killed = true -- 2841
		self:flashSet("命中", 0.6) -- 2842
		self:dropFor(e) -- 2843
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2843
		self:damageProp(solid.box, 1) -- 2845
	else -- 2845
		self:flashSet("打空", 0.35) -- 2847
	end -- 2847
	if self.isCampaign then -- 2847
		self.reloadT = self.run.inventory.quickbelt > 0 and 36 or 54 -- 2850
	end -- 2850
	self:emit("shotResolved", { -- 2852
		hit = hit, -- 2853
		enemyIndex = hit and hitEnemy.index or -1, -- 2854
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2855
		aimX = aim.x, -- 2856
		aimY = aim.y, -- 2857
		impactX = ox + dx * t, -- 2858
		impactY = oy + dy * t -- 2859
	}) -- 2859
end -- 2782
function Play.prototype.applyFireDanger(self, shotX) -- 2864
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2864
		return -- 2866
	end -- 2866
	local dangerX = shotX -- 2868
	local best = -1 -- 2869
	local bestD = 1000000000 -- 2870
	local i = 0 -- 2871
	do -- 2871
		i = 0 -- 2872
		while i < #self.enemies do -- 2872
			do -- 2872
				local e = self.enemies[i + 1] -- 2873
				if not e.alive then -- 2873
					goto __continue499 -- 2875
				end -- 2875
				local d = math.abs(e.x - self.partner.x) -- 2877
				if d < bestD then -- 2877
					bestD = d -- 2879
					best = i -- 2880
				end -- 2880
			end -- 2880
			::__continue499:: -- 2880
			i = i + 1 -- 2872
		end -- 2872
	end -- 2872
	if best >= 0 then -- 2872
		dangerX = self.enemies[best + 1].x -- 2884
	end -- 2884
	local exposed = self:childExposed(dangerX) -- 2886
	local before = self.escort.fear -- 2887
	local dangerId = self.nextDangerId -- 2888
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2889
	self.nextDangerId = self.nextDangerId + 1 -- 2890
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2891
	if after > before then -- 2891
		self:flashSet( -- 2893
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2893
			1 -- 2893
		) -- 2893
	elseif not exposed then -- 2893
		self:flashSet("枪声没够到她", 0.5) -- 2895
	end -- 2895
end -- 2864
function Play.prototype.childExposed(self, dangerX) -- 2900
	local c = self.partner -- 2901
	if not c.alive then -- 2901
		return false -- 2903
	end -- 2903
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2903
		self.boxes, -- 2906
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2906
	) then -- 2906
		return false -- 2907
	end -- 2907
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2907
		return false -- 2910
	end -- 2910
	local toDanger = dangerX - c.x -- 2912
	local toPlayer = self.player.x - c.x -- 2913
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2913
		return false -- 2916
	end -- 2916
	return true -- 2918
end -- 2900
function Play.prototype.raycastEnemies(self, ray) -- 2922
	local best = -1 -- 2923
	local bestI = -1 -- 2924
	do -- 2924
		local i = 0 -- 2925
		while i < #self.enemies do -- 2925
			do -- 2925
				local e = self.enemies[i + 1] -- 2926
				if not e.alive then -- 2926
					goto __continue513 -- 2928
				end -- 2928
				local y = e.y + (e.depth or 0) -- 2930
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2931
				if t >= 0 and (best < 0 or t < best) then -- 2931
					best = t -- 2933
					bestI = i -- 2934
				end -- 2934
			end -- 2934
			::__continue513:: -- 2934
			i = i + 1 -- 2925
		end -- 2925
	end -- 2925
	return {t = best, index = bestI} -- 2937
end -- 2922
function Play.prototype.raycastWorld(self, ray) -- 2940
	return self:raycastSolid(ray).t -- 2941
end -- 2940
function Play.prototype.raycastSolid(self, ray) -- 2945
	local best = -1 -- 2946
	local bestBox = nil -- 2947
	for ____, box in ipairs(self.boxes) do -- 2948
		do -- 2948
			if box.broken == true or box.hidden == true then -- 2948
				goto __continue518 -- 2950
			end -- 2950
			local t = hitBox(ray, box) -- 2955
			if t >= 0 and (best < 0 or t < best) then -- 2955
				best = t -- 2957
				bestBox = box -- 2958
			end -- 2958
		end -- 2958
		::__continue518:: -- 2958
	end -- 2958
	if ray.dy < 0 then -- 2958
		local t = -ray.y / ray.dy -- 2962
		if t >= 0 and (best < 0 or t < best) then -- 2962
			best = t -- 2964
			bestBox = nil -- 2965
		end -- 2965
	end -- 2965
	return {t = best, box = bestBox} -- 2968
end -- 2945
function Play.prototype.dropFor(self, e) -- 2972
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 2972
		return -- 2974
	end -- 2974
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 2974
		return -- 2977
	end -- 2977
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 2979
	local ____self_pickups_37 = self.pickups -- 2979
	____self_pickups_37[#____self_pickups_37 + 1] = { -- 2980
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 2981
		kind = e.drop, -- 2981
		x = e.x, -- 2981
		y = e.y, -- 2981
		depth = e.depth, -- 2982
		label = label .. " ×1" -- 2982
	} -- 2982
	self:log("掉落 " .. label) -- 2984
end -- 2972
function Play.prototype.damageProp(self, b, amount) -- 2988
	if b.breakable == nil or b.broken == true then -- 2988
		return -- 2990
	end -- 2990
	local ____b_breakable_38, ____hp_39 = b.breakable, "hp" -- 2990
	____b_breakable_38[____hp_39] = ____b_breakable_38[____hp_39] - amount -- 2992
	if b.breakable.hp > 0 then -- 2992
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 2994
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 2995
		return -- 2996
	end -- 2996
	b.broken = true -- 2998
	for ____, other in ipairs(self.boxes) do -- 2999
		if other.id ~= nil and other.id == b.id then -- 2999
			other.broken = true -- 3001
		end -- 3001
	end -- 3001
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3004
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3005
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3006
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3007
end -- 2988
function Play.prototype.slideDepth(self, a, distance) -- 3011
	a.depth = self:limitDepth(a, a.depth + distance) -- 3012
end -- 3011
function Play.prototype.limitDepth(self, a, target) -- 3015
	local road = self.room.depth -- 3016
	if road == nil or target == a.depth then -- 3016
		return a.depth -- 3018
	end -- 3018
	local next = math.max( -- 3020
		road.min, -- 3020
		math.min(road.max, target) -- 3020
	) -- 3020
	local half = a.w / 2 -- 3021
	for ____, b in ipairs(self.boxes) do -- 3022
		do -- 3022
			local footprint = b.depth -- 3023
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3023
				goto __continue536 -- 3028
			end -- 3028
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3030
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3031
			if a.depth <= front and next > front then -- 3031
				next = front -- 3033
			elseif a.depth >= back and next < back then -- 3033
				next = back -- 3035
			end -- 3035
		end -- 3035
		::__continue536:: -- 3035
	end -- 3035
	return next -- 3038
end -- 3015
function Play.prototype.slideX(self, a, dx) -- 3042
	local nx = a.x + dx -- 3043
	local half = a.w / 2 -- 3044
	local room = self.room -- 3045
	nx = math.max( -- 3046
		room.minX + half, -- 3046
		math.min(room.maxX - half, nx) -- 3046
	) -- 3046
	local i = 0 -- 3047
	do -- 3047
		i = 0 -- 3048
		while i < #self.boxes do -- 3048
			do -- 3048
				local b = self.boxes[i + 1] -- 3049
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3049
					goto __continue543 -- 3051
				end -- 3051
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3051
					goto __continue543 -- 3054
				end -- 3054
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3054
					goto __continue543 -- 3057
				end -- 3057
				if nx + half > b.x0 and nx - half < b.x1 then -- 3057
					if a.x <= b.x0 then -- 3057
						nx = b.x0 - half -- 3061
					elseif a.x >= b.x1 then -- 3061
						nx = b.x1 + half -- 3063
					else -- 3063
						nx = a.x -- 3065
					end -- 3065
				end -- 3065
			end -- 3065
			::__continue543:: -- 3065
			i = i + 1 -- 3048
		end -- 3048
	end -- 3048
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 3048
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 3073
		local bx0 = self.cartAxle - CART_HALF -- 3074
		local bx1 = self.cartAxle + CART_HALF -- 3075
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 3075
			if a.x <= bx0 then -- 3075
				nx = bx0 - half -- 3078
			elseif a.x >= bx1 then -- 3078
				nx = bx1 + half -- 3080
			else -- 3080
				nx = a.x -- 3082
			end -- 3082
		end -- 3082
	end -- 3082
	local arch = room.arch -- 3090
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 3090
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 3092
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 3092
			if a.x <= arch.x0 then -- 3092
				nx = arch.x0 - half -- 3095
			elseif a.x >= arch.x1 then -- 3095
				nx = arch.x1 + half -- 3097
			end -- 3097
		end -- 3097
	end -- 3097
	a.x = nx -- 3101
end -- 3042
function Play.prototype.fallY(self, a, dt) -- 3105
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3106
	if a.vy < -900 then -- 3106
		a.vy = -900 -- 3108
	end -- 3108
	local ny = a.y + a.vy * dt -- 3110
	local half = a.w / 2 -- 3111
	if a.vy <= 0 then -- 3111
		local reach = a.onGround and STEP_UP or 0 -- 3114
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3115
		if ny <= ground then -- 3115
			ny = ground -- 3117
			a.vy = 0 -- 3118
			a.onGround = true -- 3119
		else -- 3119
			a.onGround = false -- 3121
		end -- 3121
	else -- 3121
		a.onGround = false -- 3124
		local i = 0 -- 3125
		do -- 3125
			i = 0 -- 3126
			while i < #self.boxes do -- 3126
				do -- 3126
					local b = self.boxes[i + 1] -- 3127
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3127
						goto __continue567 -- 3129
					end -- 3129
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3129
						goto __continue567 -- 3132
					end -- 3132
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3132
						goto __continue567 -- 3135
					end -- 3135
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3135
						ny = b.y0 - a.h -- 3138
						a.vy = 0 -- 3139
					end -- 3139
				end -- 3139
				::__continue567:: -- 3139
				i = i + 1 -- 3126
			end -- 3126
		end -- 3126
	end -- 3126
	a.y = ny -- 3143
end -- 3105
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3147
	if depth == nil then -- 3147
		depth = 0 -- 3147
	end -- 3147
	local g = -9999 -- 3148
	local i = 0 -- 3149
	do -- 3149
		i = 0 -- 3150
		while i < #self.floors do -- 3150
			local f = self.floors[i + 1] -- 3151
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3151
				g = f.y1 -- 3153
			end -- 3153
			i = i + 1 -- 3150
		end -- 3150
	end -- 3150
	do -- 3150
		i = 0 -- 3156
		while i < #self.boxes do -- 3156
			do -- 3156
				local b = self.boxes[i + 1] -- 3157
				if b.broken == true or b.hidden == true or b.soft == true then -- 3157
					goto __continue577 -- 3159
				end -- 3159
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3159
					g = b.y1 -- 3163
				end -- 3163
			end -- 3163
			::__continue577:: -- 3163
			i = i + 1 -- 3156
		end -- 3156
	end -- 3156
	return g -- 3166
end -- 3147
function Play.prototype.updateCamera(self, dt) -- 3169
	local p = self.player -- 3170
	local tx = p.x + p.facing * 30 -- 3171
	local ty = p.y + CAM_LOOK_UP -- 3172
	local k = math.min(1, CAM_FOLLOW * dt) -- 3173
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3174
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3175
end -- 3169
function Play.prototype.clampCamera(self, w, h) -- 3179
	local room = self.room -- 3180
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3181
	local spanX = room.maxX - room.minX -- 3182
	if spanX <= halfW * 2 then -- 3182
		self.cam.x = (room.minX + room.maxX) / 2 -- 3184
	else -- 3184
		self.cam.x = math.max( -- 3186
			room.minX + halfW, -- 3186
			math.min(room.maxX - halfW, self.cam.x) -- 3186
		) -- 3186
	end -- 3186
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3189
	local spanY = room.height -- 3190
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3191
	if spanY <= halfH * 2 then -- 3191
		self.cam.y = camY -- 3193
	else -- 3193
		self.cam.y = math.max( -- 3195
			camY, -- 3195
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3195
		) -- 3195
	end -- 3195
end -- 3179
function Play.prototype.flashSet(self, text, t) -- 3199
	self.flash = text -- 3200
	self.flashT = t -- 3201
end -- 3199
function Play.prototype.statusText(self) -- 3205
	local p = self.player -- 3206
	local parts = {} -- 3207
	local who = self.childMode and "小满" or "周戍" -- 3208
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3209
	if self.room.key == "prologue" then -- 3209
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3212
		if self.phase == "prologue-wait" then -- 3212
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3214
		elseif self.phase == "prologue-give" then -- 3214
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3216
		else -- 3216
			parts[#parts + 1] = "跟随" -- 3218
		end -- 3218
		if self.paused then -- 3218
			parts[#parts + 1] = "已暂停" -- 3221
		end -- 3221
		return table.concat(parts, " · ") -- 3223
	end -- 3223
	if self.room.key == "street" then -- 3223
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3226
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3227
		if self.paused then -- 3227
			parts[#parts + 1] = "已暂停" -- 3229
		end -- 3229
		return table.concat(parts, " · ") -- 3231
	end -- 3231
	if self.room.key == "gate" then -- 3231
		local ____temp_40 -- 3234
		if self.room.story == nil then -- 3234
			____temp_40 = nil -- 3234
		else -- 3234
			____temp_40 = self.room.story.gate -- 3234
		end -- 3234
		local g = ____temp_40 -- 3234
		if g ~= nil then -- 3234
			parts[#parts + 1] = self:gateLabel() -- 3236
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3237
				0, -- 3238
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3238
			))) .. " 秒" -- 3238
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3239
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3240
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3241
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3242
			if self.gateFailCount > 0 then -- 3242
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3244
			end -- 3244
			if self.flash ~= "" then -- 3244
				parts[#parts + 1] = self.flash -- 3247
			end -- 3247
		end -- 3247
		if self.paused then -- 3247
			parts[#parts + 1] = "已暂停" -- 3251
		end -- 3251
		return table.concat(parts, " · ") -- 3253
	end -- 3253
	if self.room.key == "forest" then -- 3253
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3256
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3257
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3258
		if self.caughtT > 0 then -- 3258
			parts[#parts + 1] = "复位中" -- 3260
		end -- 3260
		if self.paused then -- 3260
			parts[#parts + 1] = "已暂停" -- 3263
		end -- 3263
		return table.concat(parts, " · ") -- 3265
	end -- 3265
	if self.room.key == "tower" then -- 3265
		if self.phase == "tower-wait" then -- 3265
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3269
		elseif self.phase == "tower-knock" then -- 3269
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3271
		elseif self.phase == "tower-given" then -- 3271
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3273
		else -- 3273
			parts[#parts + 1] = "片尾" -- 3275
		end -- 3275
		if self.paused then -- 3275
			parts[#parts + 1] = "已暂停" -- 3278
		end -- 3278
		return table.concat(parts, " · ") -- 3280
	end -- 3280
	if self.room.key == "village" then -- 3280
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3283
		if self.hasBottle then -- 3283
			parts[#parts + 1] = "有瓶" -- 3285
		elseif self.bottleFly ~= nil then -- 3285
			parts[#parts + 1] = "瓶在飞" -- 3287
		else -- 3287
			parts[#parts + 1] = "空手" -- 3289
		end -- 3289
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3291
		if self.scavChase then -- 3291
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3293
		end -- 3293
		if self.passed then -- 3293
			parts[#parts + 1] = "已过通行线" -- 3296
		end -- 3296
		if self.paused then -- 3296
			parts[#parts + 1] = "已暂停" -- 3299
		end -- 3299
		return table.concat(parts, " · ") -- 3301
	end -- 3301
	local isChild = self.childMode -- 3304
	if isChild then -- 3304
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3306
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3307
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3308
	else -- 3308
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3310
		if p.rollT > 0 then -- 3310
			parts[#parts + 1] = "翻滚中" -- 3312
		end -- 3312
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3314
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3315
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3316
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3317
	end -- 3317
	if self.checkpoint >= 0 then -- 3317
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3320
	end -- 3320
	if self.paused then -- 3320
		parts[#parts + 1] = "已暂停" -- 3323
	end -- 3323
	return table.concat(parts, " · ") -- 3325
end -- 3205
function Play.prototype.aliveEnemies(self) -- 3329
	local n = 0 -- 3330
	local i = 0 -- 3331
	do -- 3331
		i = 0 -- 3332
		while i < #self.enemies do -- 3332
			if self.enemies[i + 1].alive then -- 3332
				n = n + 1 -- 3334
			end -- 3334
			i = i + 1 -- 3332
		end -- 3332
	end -- 3332
	return n -- 3337
end -- 3329
function Play.prototype.threatened(self) -- 3342
	do -- 3342
		local i = 0 -- 3343
		while i < #self.enemies do -- 3343
			local e = self.enemies[i + 1] -- 3344
			if e.alive and e.warnT > 0 then -- 3344
				return true -- 3346
			end -- 3346
			i = i + 1 -- 3343
		end -- 3343
	end -- 3343
	return false -- 3349
end -- 3342
function Play.prototype.gateSecondsLeft(self) -- 3352
	local ____temp_41 -- 3353
	if self.room.story == nil then -- 3353
		____temp_41 = nil -- 3353
	else -- 3353
		____temp_41 = self.room.story.gate -- 3353
	end -- 3353
	local g = ____temp_41 -- 3353
	if g == nil then -- 3353
		return 0 -- 3355
	end -- 3355
	return math.max( -- 3357
		0, -- 3357
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3357
	) -- 3357
end -- 3352
function Play.prototype.gateLabel(self) -- 3360
	if self.phase == "gate-idle" then -- 3360
		return "待就位" -- 3362
	end -- 3362
	if self.phase == "gate-hold" then -- 3362
		return "守点中" -- 3365
	end -- 3365
	if self.phase == "gate-send" then -- 3365
		return "送别" -- 3368
	end -- 3368
	if self.phase == "gate-count" then -- 3368
		return "数数 " .. tostring(self.countTick) -- 3371
	end -- 3371
	return "她走" -- 3373
end -- 3360
function Play.prototype.dogLabel(self) -- 3377
	if self.dogState == "ear" then -- 3377
		return "转耳" -- 3379
	end -- 3379
	if self.dogState == "chase" then -- 3379
		return "追" -- 3382
	end -- 3382
	if self.dogState == "sniff" then -- 3382
		return "停" -- 3385
	end -- 3385
	if self.dogState == "back" then -- 3385
		return "回线" -- 3388
	end -- 3388
	return "巡逻" -- 3390
end -- 3377
function Play.prototype.doorXOf(self) -- 3393
	local ____temp_42 -- 3394
	if self.room.story == nil then -- 3394
		____temp_42 = nil -- 3394
	else -- 3394
		____temp_42 = self.room.story.tower -- 3394
	end -- 3394
	local t = ____temp_42 -- 3394
	return t == nil and 0 or t.doorX -- 3395
end -- 3393
function Play.prototype.scavLabel(self) -- 3399
	if self.scavState == "chase" then -- 3399
		return "追" -- 3401
	end -- 3401
	if self.scavState == "turn" then -- 3401
		return "转头" -- 3404
	end -- 3404
	if self.scavState == "walk" then -- 3404
		return "赶来" -- 3407
	end -- 3407
	if self.scavState == "stall" then -- 3407
		return "停住" -- 3410
	end -- 3410
	if self.scavState == "back" then -- 3410
		return "回位" -- 3413
	end -- 3413
	return "巡逻" -- 3415
end -- 3399
function Play.prototype.hintText(self) -- 3419
	if self.paused then -- 3419
		return "Esc 继续 · R 重置" -- 3421
	end -- 3421
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3421
		if self:threatened() then -- 3421
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3427
		end -- 3427
		if self.coverHug then -- 3427
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3430
		end -- 3430
		if self.coverNear then -- 3430
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3433
		end -- 3433
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3435
	end -- 3435
	if self.flash ~= "" then -- 3435
		return self.flash -- 3438
	end -- 3438
	if self.room.key == "prologue" then -- 3438
		if self.phase == "prologue-wait" then -- 3438
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3442
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3443
		end -- 3443
		if self.phase == "prologue-give" then -- 3443
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3446
		end -- 3446
		return "她跟着你了 · 两人一起走到门口 680" -- 3448
	end -- 3448
	if self.room.key == "street" then -- 3448
		if self:aliveEnemies() > 0 then -- 3448
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3452
		end -- 3452
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3454
	end -- 3454
	if self.room.key == "gate" then -- 3454
		local ____temp_43 -- 3457
		if self.room.story == nil then -- 3457
			____temp_43 = nil -- 3457
		else -- 3457
			____temp_43 = self.room.story.gate -- 3457
		end -- 3457
		local g = ____temp_43 -- 3457
		if g ~= nil then -- 3457
			if self.phase == "gate-idle" then -- 3457
				if self.gateNeedConfirm then -- 3457
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3461
				end -- 3461
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3463
			end -- 3463
			if self.phase == "gate-hold" then -- 3463
				if self.coveredFlash > 0 then -- 3463
					return "掩体挡下了这一枪 · 别露头" -- 3467
				end -- 3467
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3469
			end -- 3469
			if self.phase == "gate-send" then -- 3469
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3472
			end -- 3472
			if self.phase == "gate-count" then -- 3472
				if self.countTick >= 1440 then -- 3472
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3476
				end -- 3476
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3478
			end -- 3478
			return "她自己走 · 跟着出城门 1120" -- 3480
		end -- 3480
	end -- 3480
	if self.room.key == "forest" then -- 3480
		if self.dogState == "chase" then -- 3480
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3485
		end -- 3485
		if self.dogState == "ear" then -- 3485
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3488
		end -- 3488
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3490
	end -- 3490
	if self.room.key == "tower" then -- 3490
		if self.phase == "tower-wait" then -- 3490
			return "走到门前 445 点一次 E 敲两下" -- 3494
		end -- 3494
		if self.phase == "tower-knock" then -- 3494
			return "敲两下 · 等门开" -- 3497
		end -- 3497
		if self.phase == "tower-given" then -- 3497
			return "递交针套和纸条 · 看登记簿最后一行" -- 3500
		end -- 3500
		return "片尾 · 点 E 再玩一次，回到序章" -- 3502
	end -- 3502
	if self.room.key == "village" then -- 3502
		if self.bottleFly ~= nil then -- 3502
			return "等瓶子落地 · 触地才发声" -- 3506
		end -- 3506
		if self.hasBottle then -- 3506
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3509
		end -- 3509
		if self.passed then -- 3509
			return "已过第一院 · R 重置可再来一遍" -- 3512
		end -- 3512
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3514
	end -- 3514
	if self.room.key == "outside" then -- 3514
		if self.focusCart then -- 3514
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3518
		end -- 3518
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3520
	end -- 3520
	if self.escort.state == "frozen" then -- 3520
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3520
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3524
		end -- 3524
		return "小满吓住了 · 走过去，靠近再点 E" -- 3526
	end -- 3526
	if self.escort.state == "calming" then -- 3526
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3529
	end -- 3529
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3531
end -- 3419
function Play.prototype.draw(self, draw, w, h) -- 3536
	self.viewW = w -- 3537
	self.viewH = h -- 3538
	self.view = ____exports.computeViewport(w, h) -- 3539
	self:clampCamera(w, h) -- 3540
	draw:clear() -- 3541
	draw:drawRect( -- 3543
		Rect(0, 0, w, h), -- 3543
		BG_VOID -- 3543
	) -- 3543
	local box = self:canvasRect(w, h) -- 3544
	draw:drawRect(box, BG_FAR) -- 3545
	draw:drawRect( -- 3546
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3546
		BG_MID -- 3546
	) -- 3546
	self:drawFloors(draw, w, h) -- 3548
	self:drawSolids(draw, w, h) -- 3549
	self:drawZones(draw, w, h) -- 3550
	self:drawArch(draw, w, h) -- 3551
	self:drawCart(draw, w, h) -- 3552
	self:drawCampaignProps(draw, w, h) -- 3553
	self:drawActors(draw, w, h) -- 3554
	self:drawTrace(draw, w, h) -- 3555
	self:drawAim(draw, w, h) -- 3556
end -- 3536
function Play.prototype.canvasRect(self, w, h) -- 3560
	local v = self.view -- 3561
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3562
end -- 3560
function Play.prototype.px(self, n) -- 3566
	return n * self.view.zoom -- 3567
end -- 3566
function Play.prototype.sx(self, wx, w) -- 3571
	local v = self.view -- 3572
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3573
	return v.ox + lx * v.zoom -- 3574
end -- 3571
function Play.prototype.sy(self, wy, h) -- 3578
	local v = self.view -- 3579
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3580
	return v.oy + ly * v.zoom -- 3581
end -- 3578
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3584
	local px0 = self:sx(x0, w) -- 3585
	local px1 = self:sx(x1, w) -- 3586
	local py0 = self:sy(y0, h) -- 3587
	local py1 = self:sy(y1, h) -- 3588
	if px1 <= px0 or py1 <= py0 then -- 3588
		return -- 3590
	end -- 3590
	draw:drawRect( -- 3592
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3592
		color -- 3592
	) -- 3592
end -- 3584
function Play.prototype.drawFloors(self, draw, w, h) -- 3595
	local i = 0 -- 3596
	do -- 3596
		i = 0 -- 3597
		while i < #self.room.floors do -- 3597
			local f = self.room.floors[i + 1] -- 3598
			local ____temp_44 -- 3599
			if f.y == 0 then -- 3599
				____temp_44 = self.room.depth -- 3599
			else -- 3599
				____temp_44 = nil -- 3599
			end -- 3599
			local road = ____temp_44 -- 3599
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3600
			local x0 = self:sx(f.x0, w) -- 3601
			local x1 = self:sx(f.x1, w) -- 3602
			local deck = self:px(5) -- 3603
			if road ~= nil then -- 3603
				local back = self:sy(f.y + road.max, h) -- 3605
				draw:drawRect( -- 3606
					Rect(x0, y, x1 - x0, back - y), -- 3606
					FLOOR_DECK, -- 3606
					self:px(1), -- 3606
					SOLID_EDGE -- 3606
				) -- 3606
			end -- 3606
			draw:drawRect( -- 3608
				Rect(x0, y - deck, x1 - x0, deck), -- 3608
				FLOOR_DECK -- 3608
			) -- 3608
			draw:drawSegment( -- 3609
				Vec2(x0, y), -- 3609
				Vec2(x1, y), -- 3609
				self:px(1), -- 3609
				GROUND -- 3609
			) -- 3609
			i = i + 1 -- 3597
		end -- 3597
	end -- 3597
end -- 3595
function Play.prototype.drawSolids(self, draw, w, h) -- 3613
	local i = 0 -- 3614
	do -- 3614
		i = 0 -- 3615
		while i < #self.boxes do -- 3615
			do -- 3615
				local b = self.boxes[i + 1] -- 3616
				if b.id == "braced_shield" or b.hidden == true then -- 3616
					goto __continue698 -- 3618
				end -- 3618
				if b.broken == true then -- 3618
					if b.breakable ~= nil then -- 3618
						local gy = self:sy(b.y0, h) -- 3623
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3624
						local k = 0 -- 3625
						do -- 3625
							k = 0 -- 3626
							while k < 3 do -- 3626
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3627
								draw:drawSegment( -- 3628
									Vec2( -- 3628
										gx - self:px(4), -- 3628
										gy + self:px(k % 2) -- 3628
									), -- 3628
									Vec2( -- 3628
										gx + self:px(5), -- 3628
										gy + self:px(k % 2) -- 3628
									), -- 3628
									self:px(1), -- 3628
									rgb -- 3628
								) -- 3628
								k = k + 1 -- 3626
							end -- 3626
						end -- 3626
					end -- 3626
					goto __continue698 -- 3631
				end -- 3631
				local ____opt_47 = b.depth -- 3631
				local front = ____opt_47 and ____opt_47.min or 0 -- 3633
				local ____opt_49 = b.depth -- 3633
				local back = ____opt_49 and ____opt_49.max or 0 -- 3634
				local fill = SOLID_FILL -- 3635
				local line = SOLID_EDGE -- 3636
				if b.soft == true then -- 3636
					fill = SOFT -- 3638
					line = SOFT_LINE -- 3639
				elseif b.breakable ~= nil then -- 3639
					line = DANGER_LINE -- 3641
					fill = Color(0.3, 0.24, 0.16, 1) -- 3642
				elseif b.interact ~= nil then -- 3642
					line = PASS_LINE -- 3644
				end -- 3644
				self:drawBox( -- 3646
					draw, -- 3646
					w, -- 3646
					h, -- 3646
					b.x0, -- 3646
					b.x1, -- 3646
					b.y0 + front, -- 3646
					b.y1 + back, -- 3646
					fill -- 3646
				) -- 3646
				draw:drawSegment( -- 3647
					Vec2( -- 3647
						self:sx(b.x0, w), -- 3647
						self:sy(b.y1 + front, h) -- 3647
					), -- 3647
					Vec2( -- 3648
						self:sx(b.x1, w), -- 3648
						self:sy(b.y1 + front, h) -- 3648
					), -- 3648
					self:px(1), -- 3648
					line -- 3648
				) -- 3648
				if b.breakable ~= nil then -- 3648
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3651
					local cyp = self:sy(b.y1 + front, h) -- 3652
					draw:drawSegment( -- 3653
						Vec2( -- 3653
							cxp - self:px(4), -- 3653
							cyp + self:px(1) -- 3653
						), -- 3653
						Vec2( -- 3653
							cxp + self:px(3), -- 3653
							cyp + self:px(5) -- 3653
						), -- 3653
						self:px(1), -- 3653
						line -- 3653
					) -- 3653
				end -- 3653
			end -- 3653
			::__continue698:: -- 3653
			i = i + 1 -- 3615
		end -- 3615
	end -- 3615
end -- 3613
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3659
	local i = 0 -- 3660
	do -- 3660
		i = 0 -- 3661
		while i < #self.pickups do -- 3661
			do -- 3661
				local pk = self.pickups[i + 1] -- 3662
				if pk.id == "" then -- 3662
					goto __continue710 -- 3664
				end -- 3664
				local gy = pk.y + (pk.depth or 0) -- 3666
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3667
				draw:drawRect( -- 3668
					Rect( -- 3668
						self:sx(pk.x - 5, w), -- 3668
						self:sy(gy + 12 + bob, h), -- 3668
						self:px(10), -- 3668
						self:px(10) -- 3668
					), -- 3668
					Color(0.84, 0.7, 0.3, 1) -- 3669
				) -- 3669
				draw:drawSegment( -- 3670
					Vec2( -- 3670
						self:sx(pk.x - 5, w), -- 3670
						self:sy(gy + 12 + bob, h) -- 3670
					), -- 3670
					Vec2( -- 3671
						self:sx(pk.x + 5, w), -- 3671
						self:sy(gy + 12 + bob, h) -- 3671
					), -- 3671
					self:px(1), -- 3671
					Color(0.95, 0.86, 0.52, 1) -- 3671
				) -- 3671
			end -- 3671
			::__continue710:: -- 3671
			i = i + 1 -- 3661
		end -- 3661
	end -- 3661
	if self.bracedShield ~= nil then -- 3661
		local sh = self.bracedShield -- 3674
		draw:drawRect( -- 3675
			Rect( -- 3675
				self:sx(sh.x - sh.w / 2, w), -- 3675
				self:sy(sh.y, h), -- 3675
				self:px(sh.w), -- 3675
				self:px(sh.h) -- 3675
			), -- 3675
			Color(0.42, 0.4, 0.34, 1) -- 3676
		) -- 3676
		draw:drawSegment( -- 3677
			Vec2( -- 3677
				self:sx(sh.x - sh.w / 2, w), -- 3677
				self:sy(sh.y + sh.h, h) -- 3677
			), -- 3677
			Vec2( -- 3678
				self:sx(sh.x + sh.w / 2, w), -- 3678
				self:sy(sh.y + sh.h, h) -- 3678
			), -- 3678
			self:px(1), -- 3678
			Color(0.74, 0.72, 0.62, 1) -- 3678
		) -- 3678
	end -- 3678
end -- 3659
function Play.prototype.drawZones(self, draw, w, h) -- 3682
	local i = 0 -- 3683
	do -- 3683
		i = 0 -- 3684
		while i < #self.room.zones do -- 3684
			local z = self.room.zones[i + 1] -- 3685
			local fill = DANGER -- 3686
			local line = DANGER_LINE -- 3687
			if z.tint == 2 then -- 3687
				fill = SOFT -- 3689
				line = SOFT_LINE -- 3690
			elseif z.tint == 3 then -- 3690
				fill = BRICK -- 3692
				line = BRICK_LINE -- 3693
			elseif z.tint == 4 then -- 3693
				fill = PASS -- 3695
				line = PASS_LINE -- 3696
			end -- 3696
			self:drawBox( -- 3698
				draw, -- 3698
				w, -- 3698
				h, -- 3698
				z.x0, -- 3698
				z.x1, -- 3698
				z.y, -- 3698
				z.y + z.h, -- 3698
				fill -- 3698
			) -- 3698
			draw:drawSegment( -- 3699
				Vec2( -- 3699
					self:sx(z.x0, w), -- 3699
					self:sy(z.y, h) -- 3699
				), -- 3699
				Vec2( -- 3699
					self:sx(z.x0, w), -- 3699
					self:sy(z.y + z.h, h) -- 3699
				), -- 3699
				self:px(1), -- 3699
				line -- 3699
			) -- 3699
			draw:drawSegment( -- 3700
				Vec2( -- 3700
					self:sx(z.x1, w), -- 3700
					self:sy(z.y, h) -- 3700
				), -- 3700
				Vec2( -- 3700
					self:sx(z.x1, w), -- 3700
					self:sy(z.y + z.h, h) -- 3700
				), -- 3700
				self:px(1), -- 3700
				line -- 3700
			) -- 3700
			i = i + 1 -- 3684
		end -- 3684
	end -- 3684
end -- 3682
function Play.prototype.drawArch(self, draw, w, h) -- 3704
	local a = self.room.arch -- 3705
	if a.h <= 0 then -- 3705
		return -- 3707
	end -- 3707
	self:drawBox( -- 3709
		draw, -- 3709
		w, -- 3709
		h, -- 3709
		a.x0, -- 3709
		a.x1, -- 3709
		a.y, -- 3709
		a.y + a.h, -- 3709
		HOLE_FILL -- 3709
	) -- 3709
	draw:drawSegment( -- 3710
		Vec2( -- 3710
			self:sx(a.x0, w), -- 3710
			self:sy(a.y + a.h, h) -- 3710
		), -- 3710
		Vec2( -- 3710
			self:sx(a.x1, w), -- 3710
			self:sy(a.y + a.h, h) -- 3710
		), -- 3710
		self:px(1), -- 3710
		SOLID_EDGE -- 3710
	) -- 3710
	draw:drawSegment( -- 3711
		Vec2( -- 3711
			self:sx(a.x0, w), -- 3711
			self:sy(a.y, h) -- 3711
		), -- 3711
		Vec2( -- 3711
			self:sx(a.x0, w), -- 3711
			self:sy(a.y + a.h, h) -- 3711
		), -- 3711
		self:px(1), -- 3711
		SOLID_EDGE -- 3711
	) -- 3711
	draw:drawSegment( -- 3712
		Vec2( -- 3712
			self:sx(a.x1, w), -- 3712
			self:sy(a.y, h) -- 3712
		), -- 3712
		Vec2( -- 3712
			self:sx(a.x1, w), -- 3712
			self:sy(a.y + a.h, h) -- 3712
		), -- 3712
		self:px(1), -- 3712
		SOLID_EDGE -- 3712
	) -- 3712
end -- 3704
function Play.prototype.drawCart(self, draw, w, h) -- 3715
	local c = self.room.cart -- 3716
	if c.bodyW <= 0 then -- 3716
		return -- 3718
	end -- 3718
	drawCartShape( -- 3720
		draw, -- 3720
		self, -- 3720
		w, -- 3720
		h, -- 3720
		c, -- 3720
		self.cartAxle -- 3720
	) -- 3720
	draw:drawRect( -- 3721
		Rect( -- 3721
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3721
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3721
			self:px(2), -- 3721
			self:px(40) -- 3721
		), -- 3721
		STAND -- 3721
	) -- 3721
end -- 3715
function Play.prototype.drawActors(self, draw, w, h) -- 3724
	local p = self.player -- 3725
	local isChild = self.childMode -- 3726
	local footY = p.y + p.depth -- 3727
	if p.covered then -- 3727
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3730
		draw:drawSegment( -- 3731
			Vec2( -- 3731
				self:sx(edge, w), -- 3731
				self:sy(footY + 8, h) -- 3731
			), -- 3731
			Vec2( -- 3731
				self:sx(edge, w), -- 3731
				self:sy(footY + p.h * 0.62, h) -- 3731
			), -- 3731
			self:px(2), -- 3731
			STAND -- 3731
		) -- 3731
		draw:drawSegment( -- 3733
			Vec2( -- 3733
				self:sx(p.x - 8, w), -- 3733
				self:sy(footY + p.h + 3, h) -- 3733
			), -- 3733
			Vec2( -- 3733
				self:sx(p.x + 8, w), -- 3733
				self:sy(footY + p.h + 3, h) -- 3733
			), -- 3733
			self:px(2), -- 3733
			STAND -- 3733
		) -- 3733
	elseif self.coverNear and not isChild then -- 3733
		draw:drawRect( -- 3736
			Rect( -- 3736
				self:sx(p.x - 3, w), -- 3736
				self:sy(footY + 1, h), -- 3736
				self:px(3), -- 3736
				self:px(3) -- 3736
			), -- 3736
			STAND -- 3736
		) -- 3736
	end -- 3736
	drawFigure( -- 3738
		draw, -- 3738
		self, -- 3738
		w, -- 3738
		h, -- 3738
		p, -- 3738
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3738
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3738
	) -- 3738
	local q = self.partner -- 3739
	if q.alive then -- 3739
		local childPartner = q.w == CHILD_W -- 3741
		drawFigure( -- 3742
			draw, -- 3742
			self, -- 3742
			w, -- 3742
			h, -- 3742
			q, -- 3742
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3742
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3742
		) -- 3742
	end -- 3742
	local i = 0 -- 3744
	do -- 3744
		i = 0 -- 3745
		while i < #self.enemies do -- 3745
			local e = self.enemies[i + 1] -- 3746
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3747
			local enemyY = e.y + (e.depth or 0) -- 3748
			self:drawBox( -- 3749
				draw, -- 3749
				w, -- 3749
				h, -- 3749
				e.x - e.w / 2, -- 3749
				e.x + e.w / 2, -- 3749
				enemyY, -- 3749
				enemyY + e.h, -- 3749
				col -- 3749
			) -- 3749
			if e.alive then -- 3749
				local ef = p.x >= e.x and 1 or -1 -- 3751
				if e.kind == "shield" then -- 3751
					local sh = (e.shieldHp or 0) > 0 -- 3753
					draw:drawRect( -- 3754
						Rect( -- 3754
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3754
							self:sy(enemyY, h), -- 3754
							self:px(6), -- 3754
							self:px(64) -- 3754
						), -- 3754
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3755
					) -- 3755
				elseif e.kind == "breaker" then -- 3755
					draw:drawSegment( -- 3757
						Vec2( -- 3757
							self:sx(e.x + ef * 12, w), -- 3757
							self:sy(enemyY + 8, h) -- 3757
						), -- 3757
						Vec2( -- 3758
							self:sx(e.x + ef * 22, w), -- 3758
							self:sy(enemyY + 46, h) -- 3758
						), -- 3758
						self:px(3), -- 3758
						Color(0.5, 0.36, 0.22, 1) -- 3758
					) -- 3758
				end -- 3758
			end -- 3758
			if e.alive and e.warnT > 0 then -- 3758
				local gunX = self:sx(e.x, w) -- 3763
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3764
				local aimX = self:sx(p.x, w) -- 3765
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3766
				local seg = 8 -- 3767
				local s = 0 -- 3768
				do -- 3768
					s = 0 -- 3769
					while s < seg do -- 3769
						local t0 = s / seg -- 3770
						local t1 = (s + 1) / seg -- 3771
						draw:drawSegment( -- 3772
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3773
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3774
							self:px(1), -- 3775
							DANGER -- 3775
						) -- 3775
						s = s + 2 -- 3769
					end -- 3769
				end -- 3769
			end -- 3769
			i = i + 1 -- 3745
		end -- 3745
	end -- 3745
	local k = 0 -- 3780
	do -- 3780
		k = 0 -- 3781
		while k < #self.room.marks do -- 3781
			do -- 3781
				local m = self.room.marks[k + 1] -- 3782
				if m.kind ~= 0 then -- 3782
					goto __continue736 -- 3784
				end -- 3784
				local on = self.checkpoint == m.x -- 3786
				local x = self:sx(m.x, w) -- 3787
				local y = self:sy(m.y, h) -- 3788
				draw:drawSegment( -- 3789
					Vec2(x, y), -- 3789
					Vec2( -- 3789
						x, -- 3789
						y + self:px(35) -- 3789
					), -- 3789
					self:px(1), -- 3789
					on and CHECK or INK_DIM -- 3789
				) -- 3789
				draw:drawDot( -- 3790
					Vec2( -- 3790
						x, -- 3790
						y + self:px(35) -- 3790
					), -- 3790
					self:px(2), -- 3790
					on and CHECK or INK_DIM -- 3790
				) -- 3790
			end -- 3790
			::__continue736:: -- 3790
			k = k + 1 -- 3781
		end -- 3781
	end -- 3781
	local j = 0 -- 3794
	do -- 3794
		j = 0 -- 3795
		while j < #self.room.marks do -- 3795
			do -- 3795
				local m = self.room.marks[j + 1] -- 3796
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3796
					goto __continue739 -- 3798
				end -- 3798
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3798
					goto __continue739 -- 3802
				end -- 3802
				local col = STAND -- 3804
				if m.kind == 4 then -- 3804
					col = PASS_LINE -- 3806
				elseif m.kind == 5 then -- 3806
					col = BRICK_LINE -- 3808
				end -- 3808
				local mx = self:sx(m.x, w) -- 3810
				local my = self:sy(m.y, h) -- 3811
				draw:drawSegment( -- 3812
					Vec2(mx, my), -- 3812
					Vec2( -- 3812
						mx, -- 3812
						my + self:px(24) -- 3812
					), -- 3812
					self:px(1), -- 3812
					col -- 3812
				) -- 3812
			end -- 3812
			::__continue739:: -- 3812
			j = j + 1 -- 3795
		end -- 3795
	end -- 3795
	local t = 0 -- 3815
	do -- 3815
		t = 0 -- 3816
		while t < #self.room.marks do -- 3816
			do -- 3816
				local m = self.room.marks[t + 1] -- 3817
				if m.kind ~= 6 then -- 3817
					goto __continue745 -- 3819
				end -- 3819
				local mx = self:sx(m.x, w) -- 3821
				local my = self:sy(m.y, h) -- 3822
				draw:drawSegment( -- 3823
					Vec2(mx, my), -- 3823
					Vec2( -- 3823
						mx, -- 3823
						my + self:px(30) -- 3823
					), -- 3823
					self:px(1), -- 3823
					INK_DIM -- 3823
				) -- 3823
				self:drawBox( -- 3824
					draw, -- 3824
					w, -- 3824
					h, -- 3824
					m.x - 5, -- 3824
					m.x + 5, -- 3824
					m.y + 30, -- 3824
					m.y + 40, -- 3824
					CHECK -- 3824
				) -- 3824
			end -- 3824
			::__continue745:: -- 3824
			t = t + 1 -- 3816
		end -- 3816
	end -- 3816
	if self.room.key == "village" then -- 3816
		self:drawVillage(draw, w, h) -- 3827
	end -- 3827
	if self.room.key == "forest" then -- 3827
		self:drawDog(draw, w, h) -- 3830
	end -- 3830
end -- 3724
function Play.prototype.drawDog(self, draw, w, h) -- 3835
	local x = self.dogX -- 3836
	self:drawBox( -- 3837
		draw, -- 3837
		w, -- 3837
		h, -- 3837
		x - 14, -- 3837
		x + 14, -- 3837
		0, -- 3837
		20, -- 3837
		SCAV_BODY -- 3837
	) -- 3837
	self:drawBox( -- 3838
		draw, -- 3838
		w, -- 3838
		h, -- 3838
		x - 10, -- 3838
		x - 2, -- 3838
		20, -- 3838
		30, -- 3838
		SCAV_BODY -- 3838
	) -- 3838
	self:drawBox( -- 3839
		draw, -- 3839
		w, -- 3839
		h, -- 3839
		x + 2, -- 3839
		x + 10, -- 3839
		20, -- 3839
		30, -- 3839
		SCAV_HEAD -- 3839
	) -- 3839
	if self.dogState == "ear" or self.dogState == "chase" then -- 3839
		draw:drawSegment( -- 3841
			Vec2( -- 3841
				self:sx(x, w), -- 3841
				self:sy(30, h) -- 3841
			), -- 3841
			Vec2( -- 3842
				self:sx(x, w), -- 3842
				self:sy(40, h) -- 3842
			), -- 3842
			self:px(1), -- 3842
			DANGER -- 3842
		) -- 3842
	end -- 3842
end -- 3835
function Play.prototype.drawVillage(self, draw, w, h) -- 3847
	local bottle = self.room.bottle -- 3848
	if bottle ~= nil then -- 3848
		self:drawBox( -- 3850
			draw, -- 3850
			w, -- 3850
			h, -- 3850
			bottle.x - 14, -- 3850
			bottle.x + 14, -- 3850
			0, -- 3850
			64, -- 3850
			SOLID_FILL -- 3850
		) -- 3850
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3850
			self:drawBottle( -- 3852
				draw, -- 3852
				w, -- 3852
				h, -- 3852
				bottle.x, -- 3852
				64 -- 3852
			) -- 3852
		end -- 3852
	end -- 3852
	self:drawBox( -- 3856
		draw, -- 3856
		w, -- 3856
		h, -- 3856
		300, -- 3856
		420, -- 3856
		44, -- 3856
		50, -- 3856
		FLOOR_DECK -- 3856
	) -- 3856
	self:drawBox( -- 3857
		draw, -- 3857
		w, -- 3857
		h, -- 3857
		300, -- 3857
		306, -- 3857
		0, -- 3857
		44, -- 3857
		FLOOR_DECK -- 3857
	) -- 3857
	self:drawBox( -- 3858
		draw, -- 3858
		w, -- 3858
		h, -- 3858
		414, -- 3858
		420, -- 3858
		0, -- 3858
		44, -- 3858
		FLOOR_DECK -- 3858
	) -- 3858
	local s = self.room.scavenger -- 3860
	if s ~= nil then -- 3860
		local sx0 = self.scavX -- 3862
		self:drawBox( -- 3863
			draw, -- 3863
			w, -- 3863
			h, -- 3863
			sx0 - 12, -- 3863
			sx0 + 12, -- 3863
			0, -- 3863
			s.h - 14, -- 3863
			SCAV_BODY -- 3863
		) -- 3863
		self:drawBox( -- 3864
			draw, -- 3864
			w, -- 3864
			h, -- 3864
			sx0 - 7, -- 3864
			sx0 + 7, -- 3864
			s.h - 14, -- 3864
			s.h, -- 3864
			SCAV_HEAD -- 3864
		) -- 3864
		if self.scavState == "turn" then -- 3864
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3866
			draw:drawSegment( -- 3867
				Vec2( -- 3867
					self:sx(sx0, w), -- 3867
					self:sy(s.h - 6, h) -- 3867
				), -- 3867
				Vec2( -- 3867
					self:sx(fx, w), -- 3867
					self:sy(s.h - 6, h) -- 3867
				), -- 3867
				self:px(1), -- 3867
				INK -- 3867
			) -- 3867
		end -- 3867
	end -- 3867
	if self.hasBottle then -- 3867
		local p = self.player -- 3872
		self:drawBottle( -- 3873
			draw, -- 3873
			w, -- 3873
			h, -- 3873
			p.x + p.facing * 10, -- 3873
			p.y + p.h * 0.62 -- 3873
		) -- 3873
	end -- 3873
	if self.bottleFly ~= nil then -- 3873
		self:drawBottle( -- 3876
			draw, -- 3876
			w, -- 3876
			h, -- 3876
			self.bottleFly.x, -- 3876
			self.bottleFly.y -- 3876
		) -- 3876
	end -- 3876
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3876
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3879
		draw:drawCircle( -- 3880
			Vec2( -- 3880
				self:sx(self.bottleLandX, w), -- 3880
				self:sy(0, h) -- 3880
			), -- 3880
			self:px(r / ____exports.UNITS_PER_PX), -- 3880
			BRICK_LINE -- 3880
		) -- 3880
	end -- 3880
end -- 3847
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3884
	self:drawBox( -- 3885
		draw, -- 3885
		w, -- 3885
		h, -- 3885
		x - 3, -- 3885
		x + 3, -- 3885
		y - 10, -- 3885
		y, -- 3885
		BOTTLE -- 3885
	) -- 3885
end -- 3884
function Play.prototype.drawTrace(self, draw, w, h) -- 3888
	local t = self.trace -- 3889
	if t == nil or self.traceT <= 0 then -- 3889
		return -- 3891
	end -- 3891
	draw:drawSegment( -- 3893
		Vec2( -- 3894
			self:sx(t.x0, w), -- 3894
			self:sy(t.y0, h) -- 3894
		), -- 3894
		Vec2( -- 3895
			self:sx(t.x1, w), -- 3895
			self:sy(t.y1, h) -- 3895
		), -- 3895
		self:px(1), -- 3896
		t.hit and AIM_HIT or INK_DIM -- 3896
	) -- 3896
end -- 3888
function Play.prototype.drawAim(self, draw, w, h) -- 3899
	local v = self.view -- 3901
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3902
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3903
	local dot = self:px(1) -- 3904
	local arm = self:px(3) -- 3905
	local gap = self:px(1) -- 3906
	draw:drawSegment( -- 3907
		Vec2(gx - arm - gap, gy), -- 3907
		Vec2(gx - gap, gy), -- 3907
		dot / 2, -- 3907
		AIM -- 3907
	) -- 3907
	draw:drawSegment( -- 3908
		Vec2(gx + gap, gy), -- 3908
		Vec2(gx + arm + gap, gy), -- 3908
		dot / 2, -- 3908
		AIM -- 3908
	) -- 3908
	draw:drawSegment( -- 3909
		Vec2(gx, gy - arm - gap), -- 3909
		Vec2(gx, gy - gap), -- 3909
		dot / 2, -- 3909
		AIM -- 3909
	) -- 3909
	draw:drawSegment( -- 3910
		Vec2(gx, gy + gap), -- 3910
		Vec2(gx, gy + arm + gap), -- 3910
		dot / 2, -- 3910
		AIM -- 3910
	) -- 3910
	if self.room.key == "village" and self.hasBottle then -- 3910
		local p = self.player -- 3914
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3916
		local dir = ____end.x >= p.x and 1 or -1 -- 3917
		local x0 = p.x + dir * 10 -- 3918
		local y0 = p.y + p.h * 0.7 -- 3919
		local T = BOTTLE_FLY_TIME -- 3920
		local vx = (____end.x - x0) / T -- 3921
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3922
		local pxr = x0 -- 3923
		local pyr = y0 -- 3924
		local t = 1 -- 3925
		do -- 3925
			t = 1 -- 3926
			while t <= 12 do -- 3926
				local tt = t / 12 * T -- 3927
				local nx = x0 + vx * tt -- 3928
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3929
				draw:drawSegment( -- 3930
					Vec2( -- 3930
						self:sx(pxr, w), -- 3930
						self:sy(pyr, h) -- 3930
					), -- 3930
					Vec2( -- 3930
						self:sx(nx, w), -- 3930
						self:sy(ny, h) -- 3930
					), -- 3930
					self:px(1) / 2, -- 3930
					BOTTLE -- 3930
				) -- 3930
				pxr = nx -- 3931
				pyr = ny -- 3932
				t = t + 1 -- 3926
			end -- 3926
		end -- 3926
		draw:drawCircle( -- 3934
			Vec2( -- 3934
				self:sx(____end.x, w), -- 3934
				self:sy(____end.y + 2, h) -- 3934
			), -- 3934
			self:px(2), -- 3934
			BOTTLE -- 3934
		) -- 3934
	end -- 3934
end -- 3899
return ____exports -- 3899