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
function makeActor(room, index) -- 3985
	local sp = room.spawns -- 3986
	if index < 0 or index >= #sp then -- 3986
		return { -- 3988
			x = 0, -- 3988
			y = 0, -- 3988
			depth = 0, -- 3988
			depthSpeed = 0, -- 3988
			vx = 0, -- 3988
			vy = 0, -- 3988
			w = CHILD_W, -- 3988
			h = CHILD_H, -- 3988
			onGround = true, -- 3988
			facing = 1, -- 3988
			crouch = false, -- 3988
			rollT = 0, -- 3988
			covered = false, -- 3988
			alive = false -- 3988
		} -- 3988
	end -- 3988
	local s = sp[index + 1] -- 3990
	local child = s.h <= CHILD_H -- 3991
	local ground = room.depth -- 3992
	local depth = ground == nil and 0 or math.max( -- 3993
		ground.min, -- 3993
		math.min(ground.max, s.depth or 0) -- 3993
	) -- 3993
	return { -- 3994
		x = s.x, -- 3995
		y = s.y, -- 3995
		depth = depth, -- 3995
		depthSpeed = 0, -- 3995
		vx = 0, -- 3995
		vy = 0, -- 3995
		w = child and CHILD_W or SOLDIER_W, -- 3996
		h = child and CHILD_H or SOLDIER_H, -- 3997
		onGround = true, -- 3998
		facing = 1, -- 3998
		crouch = false, -- 3998
		rollT = 0, -- 3998
		covered = false, -- 3998
		alive = true -- 3998
	} -- 3998
end -- 3998
function drawFigure(draw, play, w, h, a, body, head) -- 4002
	if not a.alive then -- 4002
		return -- 4004
	end -- 4004
	local x0 = a.x - a.w / 2 -- 4006
	local x1 = a.x + a.w / 2 -- 4007
	local y0 = a.y + a.depth -- 4008
	local y1 = y0 + a.h -- 4009
	play:drawBox( -- 4010
		draw, -- 4010
		w, -- 4010
		h, -- 4010
		x0, -- 4010
		x1, -- 4010
		y0, -- 4010
		y1 - a.h * 0.26, -- 4010
		body -- 4010
	) -- 4010
	play:drawBox( -- 4011
		draw, -- 4011
		w, -- 4011
		h, -- 4011
		x0 + 2, -- 4011
		x1 - 2, -- 4011
		y1 - a.h * 0.26, -- 4011
		y1, -- 4011
		head -- 4011
	) -- 4011
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 4013
	play:drawBox( -- 4014
		draw, -- 4014
		w, -- 4014
		h, -- 4014
		eyeX, -- 4014
		eyeX + 4, -- 4014
		y1 - a.h * 0.14, -- 4014
		y1 - a.h * 0.08, -- 4014
		INK -- 4014
	) -- 4014
end -- 4014
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 4018
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 4019
end -- 4018
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 4026
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 4027
end -- 4026
function rayInterval(origin, direction, min, max) -- 4034
	if direction == 0 then -- 4034
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4036
	end -- 4036
	local a = (min - origin) / direction -- 4038
	local b = (max - origin) / direction -- 4039
	return { -- 4040
		min = math.min(a, b), -- 4040
		max = math.max(a, b) -- 4040
	} -- 4040
end -- 4040
function hitBox(ray, box) -- 4044
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4045
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4046
	local enter = math.max(0, x.min, y.min) -- 4047
	local leave = math.min(99999, x.max, y.max) -- 4048
	if box.depth ~= nil then -- 4048
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4050
		enter = math.max(enter, depth.min) -- 4051
		leave = math.min(leave, depth.max) -- 4052
	end -- 4052
	return leave >= enter and enter or -1 -- 4054
end -- 4054
function drawCartShape(draw, play, w, h, c, axleX) -- 4057
	local half = c.bodyW / 2 -- 4058
	local x0 = axleX - half -- 4059
	local x1 = axleX + half -- 4060
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4061
	play:drawBox( -- 4062
		draw, -- 4062
		w, -- 4062
		h, -- 4062
		x0, -- 4062
		x1, -- 4062
		axleY, -- 4062
		axleY + c.bodyH, -- 4062
		CART_FILL -- 4062
	) -- 4062
	draw:drawCircle( -- 4063
		Vec2( -- 4063
			play:sx(x0 + c.bodyW * 0.28, w), -- 4063
			play:sy(axleY, h) -- 4063
		), -- 4063
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4063
		Color(52, 50, 48, 255) -- 4063
	) -- 4063
	draw:drawCircle( -- 4064
		Vec2( -- 4064
			play:sx(x1 - c.bodyW * 0.28, w), -- 4064
			play:sy(axleY, h) -- 4064
		), -- 4064
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4064
		Color(52, 50, 48, 255) -- 4064
	) -- 4064
	local cx = c.clothSide < 0 and x0 or x1 -- 4065
	play:drawBox( -- 4066
		draw, -- 4066
		w, -- 4066
		h, -- 4066
		cx - 10, -- 4066
		cx + 10, -- 4066
		axleY + c.bodyH, -- 4066
		axleY + c.bodyH + 18, -- 4066
		CLOTH -- 4066
	) -- 4066
end -- 4066
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
	local trial = self.run.trial -- 592
	if trial ~= nil then -- 592
		draftRoom(trial, wr.key) -- 594
		self.maxHp = self.maxHp + trial.ranks.vitality -- 595
		self.hp = trial.hp -- 596
	end -- 596
	self:buildEnemies() -- 598
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 599
	local i = 0 -- 600
	do -- 600
		i = 0 -- 601
		while i < #self.boxes do -- 601
			do -- 601
				local b = self.boxes[i + 1] -- 602
				if b.id == nil then -- 602
					goto __continue34 -- 604
				end -- 604
				local st = self.run.props[b.id] -- 606
				if st ~= nil then -- 606
					b.broken = st.broken -- 608
					local ____temp_16 -- 609
					if b.breakable == nil then -- 609
						____temp_16 = nil -- 609
					else -- 609
						____temp_16 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 609
					end -- 609
					b.breakable = ____temp_16 -- 609
					b.hidden = b.hidden == true and st.revealed ~= true -- 610
					if b.hidden then -- 610
						b.broken = true -- 612
					end -- 612
				elseif b.hidden == true then -- 612
					b.broken = true -- 616
				end -- 616
			end -- 616
			::__continue34:: -- 616
			i = i + 1 -- 601
		end -- 601
	end -- 601
	if wr.cart.bodyW > 0 then -- 601
		self.cartAxle = wr.cart.startX -- 620
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 620
			self.cartAxle = wr.cart.endX -- 622
			self.cartDocked = true -- 623
		end -- 623
	end -- 623
	do -- 623
		i = 0 -- 626
		while i < #self.pickups do -- 626
			local pk = self.pickups[i + 1] -- 627
			if self.run.taken[pk.id] == true then -- 627
				pk.id = "" -- 629
			end -- 629
			i = i + 1 -- 626
		end -- 626
	end -- 626
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 632
end -- 555
function Play.prototype.log(self, line) -- 635
	local ____self_run_log_17 = self.run.log -- 635
	____self_run_log_17[#____self_run_log_17 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 636
	if #self.run.log > 120 then -- 636
		table.remove(self.run.log, 1) -- 638
	end -- 638
end -- 635
function Play.prototype.buildEnemies(self) -- 642
	self.enemies = {} -- 643
	if self.isCampaign then -- 643
		local i = 0 -- 645
		do -- 645
			i = 0 -- 646
			while i < #self.room.spawns do -- 646
				local sp = self.room.spawns[i + 1] -- 647
				local kind = sp.kind or "gunner" -- 648
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 649
				local ____self_enemies_18 = self.enemies -- 649
				____self_enemies_18[#____self_enemies_18 + 1] = { -- 650
					x = sp.x, -- 651
					y = sp.y, -- 651
					depth = sp.depth, -- 651
					w = 26, -- 651
					h = sp.h, -- 651
					alive = true, -- 651
					hitT = 0, -- 651
					warnT = 0, -- 651
					fireCd = 40, -- 651
					kind = kind, -- 652
					shieldHp = hp, -- 652
					shieldHpMax = hp, -- 652
					drop = sp.drop or "none", -- 652
					homeX = sp.x, -- 653
					swingT = 0, -- 653
					awake = false, -- 653
					squad = i -- 653
				} -- 653
				i = i + 1 -- 646
			end -- 646
		end -- 646
		return -- 656
	end -- 656
	if self.room.key == "checkpoint" then -- 656
		local ____self_enemies_19 = self.enemies -- 656
		____self_enemies_19[#____self_enemies_19 + 1] = { -- 659
			x = self.ox + 430, -- 659
			y = 0, -- 659
			w = 26, -- 659
			h = 84, -- 659
			alive = true, -- 659
			hitT = 0, -- 659
			warnT = 0, -- 659
			fireCd = 0 -- 659
		} -- 659
		local ____self_enemies_20 = self.enemies -- 659
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 660
			x = self.ox + 505, -- 660
			y = 0, -- 660
			w = 26, -- 660
			h = 84, -- 660
			alive = true, -- 660
			hitT = 0, -- 660
			warnT = 0, -- 660
			fireCd = 0 -- 660
		} -- 660
		return -- 661
	end -- 661
	if self.room.key == "street" then -- 661
		local ____self_enemies_21 = self.enemies -- 661
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 665
			x = self.ox + 340, -- 665
			y = 0, -- 665
			w = 26, -- 665
			h = 84, -- 665
			alive = true, -- 665
			hitT = 0, -- 665
			warnT = 0, -- 665
			fireCd = 0 -- 665
		} -- 665
		local ____self_enemies_22 = self.enemies -- 665
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 666
			x = self.ox + 560, -- 666
			y = 0, -- 666
			w = 26, -- 666
			h = 84, -- 666
			alive = true, -- 666
			hitT = 0, -- 666
			warnT = 0, -- 666
			fireCd = 0 -- 666
		} -- 666
	end -- 666
end -- 642
function Play.prototype.emit(self, name, data) -- 672
	local ____self_events_23 = self.events -- 672
	____self_events_23[#____self_events_23 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 673
	self.eventSeq = self.eventSeq + 1 -- 674
	if #self.events > 256 then -- 674
		table.remove(self.events, 1) -- 676
	end -- 676
end -- 672
function Play.prototype.drainEvents(self) -- 684
	local out = self.events -- 685
	self.events = {} -- 686
	return out -- 687
end -- 684
function Play.prototype.adoptEvents(self, events) -- 696
	if #events == 0 then -- 696
		return -- 698
	end -- 698
	local keep = {} -- 700
	local i = 0 -- 701
	do -- 701
		i = 0 -- 702
		while i < #events do -- 702
			do -- 702
				local e = events[i + 1] -- 703
				if e.name == "knock" and e.data.room ~= self.room.key then -- 703
					goto __continue58 -- 705
				end -- 705
				keep[#keep + 1] = e -- 707
			end -- 707
			::__continue58:: -- 707
			i = i + 1 -- 702
		end -- 702
	end -- 702
	if #keep == 0 then -- 702
		return -- 710
	end -- 710
	self.events = __TS__ArrayConcat(keep, self.events) -- 712
	do -- 712
		i = 0 -- 713
		while i < #self.events do -- 713
			self.events[i + 1].seq = i -- 714
			i = i + 1 -- 713
		end -- 713
	end -- 713
	self.eventSeq = #self.events -- 716
end -- 696
function Play.prototype.chooseTalent(self, slot) -- 719
	local trial = self.run.trial -- 720
	local talent = trial and trial.offers[slot + 1] -- 721
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 721
		return -- 722
	end -- 722
	local ____trial_ranks_26, ____talent_27 = trial.ranks, talent -- 722
	____trial_ranks_26[____talent_27] = ____trial_ranks_26[____talent_27] + 1 -- 723
	trial.offers = {} -- 724
	if talent == "vitality" then -- 724
		self.maxHp = self.maxHp + 1 -- 726
		self.hp = self.hp + 1 -- 727
		trial.hp = self.hp -- 728
	end -- 728
	self:flashSet(talentNames[talent], 1.2) -- 730
end -- 719
function Play.prototype.reloadTicks(self) -- 733
	local ____temp_30 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 734
	local ____opt_28 = self.run.trial -- 734
	return math.max(6, ____temp_30 - 6 * (____opt_28 and ____opt_28.ranks.reload or 0)) -- 734
end -- 733
function Play.prototype.update(self, dt, input) -- 737
	local trial = self.run.trial -- 738
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 738
		return -- 739
	end -- 739
	if input.pause.pressed then -- 739
		self.paused = not self.paused -- 741
	end -- 741
	if self.flashT > 0 then -- 741
		self.flashT = self.flashT - dt -- 744
		if self.flashT <= 0 then -- 744
			self.flash = "" -- 746
		end -- 746
	end -- 746
	if self.traceT > 0 then -- 746
		self.traceT = self.traceT - dt -- 750
		if self.traceT <= 0 then -- 750
			self.trace = nil -- 752
		end -- 752
	end -- 752
	if self.paused then -- 752
		self:updateCamera(dt) -- 756
		return -- 757
	end -- 757
	self.ticks = self.ticks + 1 -- 760
	if self.invulnT > 0 then -- 760
		self.invulnT = self.invulnT - 1 -- 764
	end -- 764
	if self.isCampaign then -- 764
		local ____self_run_31, ____ticks_32 = self.run, "ticks" -- 764
		____self_run_31[____ticks_32] = ____self_run_31[____ticks_32] + 1 -- 767
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 768
	end -- 768
	local p = self.player -- 770
	self:stepPlayer(p, dt, input) -- 771
	self:refreshCover(p, input) -- 773
	if self.isCampaign then -- 773
		self:stepCampaign(dt, input) -- 775
		self:stepCampaignPartner(dt) -- 776
	end -- 776
	if trial == nil or not self.run.finished then -- 776
		self:stepEnemies(dt, input) -- 779
	end -- 779
	if trial ~= nil then -- 779
		trial.hp = self.hp -- 780
	end -- 780
	if not self.isCampaign then -- 780
		self:stepStory(dt, input) -- 782
		self:stepEscort(dt, input) -- 783
		self:stepVillage(dt, input) -- 784
		self:stepChase(dt, input) -- 785
		self:stepInteract(dt, input) -- 786
	end -- 786
	self:updateGate() -- 788
	self:updateCamera(dt) -- 789
end -- 737
function Play.prototype.underLowArch(self, a) -- 796
	local arch = self.room.arch -- 797
	if arch.h <= 0 then -- 797
		return false -- 799
	end -- 799
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 799
		return false -- 802
	end -- 802
	local top = arch.y + arch.h -- 804
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 805
end -- 796
function Play.prototype.coverAt(self, a) -- 812
	local best = nil -- 813
	local bestGap = 24 -- 814
	local half = a.w / 2 -- 815
	local i = 0 -- 816
	do -- 816
		i = 0 -- 817
		while i < #self.boxes do -- 817
			do -- 817
				local b = self.boxes[i + 1] -- 818
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 818
					goto __continue86 -- 820
				end -- 820
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 820
					goto __continue86 -- 823
				end -- 823
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 825
				if gap < bestGap then -- 825
					bestGap = gap -- 827
					best = b -- 828
				end -- 828
			end -- 828
			::__continue86:: -- 828
			i = i + 1 -- 817
		end -- 817
	end -- 817
	return best -- 831
end -- 812
function Play.prototype.nearCover(self, a) -- 834
	return self:coverAt(a) ~= nil -- 835
end -- 834
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 839
	if enemy == nil then -- 839
		return false -- 841
	end -- 841
	local fromRight = enemy.x >= a.x -- 843
	local edge = fromRight and b.x0 or b.x1 -- 844
	local ____fromRight_33 -- 845
	if fromRight then -- 845
		____fromRight_33 = edge >= a.x - 0.001 and edge <= enemy.x -- 845
	else -- 845
		____fromRight_33 = edge <= a.x + 0.001 and edge >= enemy.x -- 846
	end -- 846
	local between = ____fromRight_33 -- 845
	local separation = enemy.x - a.x -- 847
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 848
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 849
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 850
end -- 839
function Play.prototype.nearestEnemy(self, a) -- 853
	local best -- 854
	local bestD = 1000000000 -- 855
	local i = 0 -- 856
	do -- 856
		i = 0 -- 857
		while i < #self.enemies do -- 857
			do -- 857
				local e = self.enemies[i + 1] -- 858
				if not e.alive then -- 858
					goto __continue95 -- 860
				end -- 860
				local d = math.abs(e.x - a.x) -- 862
				if d < bestD then -- 862
					bestD = d -- 864
					best = e -- 865
				end -- 865
			end -- 865
			::__continue95:: -- 865
			i = i + 1 -- 857
		end -- 857
	end -- 857
	return best -- 868
end -- 853
function Play.prototype.refreshCover(self, a, input) -- 872
	if self.childMode then -- 872
		self.coverNear = false -- 874
		self.coverHug = false -- 875
		self.coverEntity = "" -- 876
		self.coverBlocking = false -- 877
		a.covered = false -- 878
		return -- 879
	end -- 879
	local b = self:coverAt(a) -- 881
	self.coverNear = b ~= nil -- 882
	a.covered = self.coverNear and input.cover.held -- 883
	self.coverHug = a.covered -- 884
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 885
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 886
		b, -- 886
		a, -- 886
		self:nearestEnemy(a) -- 886
	) -- 886
end -- 872
function Play.prototype.cartHandleInReach(self, a) -- 890
	if a == nil then -- 890
		a = self.player -- 890
	end -- 890
	local c = self.room.cart -- 891
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 891
		return false -- 893
	end -- 893
	local handleX = self.cartAxle + c.handleOffset -- 895
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 896
end -- 890
function Play.prototype.nearLowLedge(self, a) -- 901
	local reach = 26 -- 902
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 903
	local x1 = x0 + reach -- 904
	local i = 0 -- 905
	do -- 905
		i = 0 -- 906
		while i < #self.boxes do -- 906
			do -- 906
				local b = self.boxes[i + 1] -- 907
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 907
					goto __continue104 -- 909
				end -- 909
				local rise = b.y1 - a.y -- 911
				if rise > 0 and rise <= LEDGE_RISE then -- 911
					return true -- 913
				end -- 913
			end -- 913
			::__continue104:: -- 913
			i = i + 1 -- 906
		end -- 906
	end -- 906
	return false -- 916
end -- 901
function Play.prototype.stepPlayer(self, a, dt, input) -- 919
	a.depthSpeed = 0 -- 920
	if not a.alive then -- 920
		return -- 922
	end -- 922
	local isChild = self.childMode -- 924
	local lowArch = isChild and self:underLowArch(a) -- 926
	if self:storyLocked() then -- 926
		a.vx = 0 -- 929
		a.crouch = isChild and lowArch -- 930
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 931
		self:fallY(a, dt) -- 932
		return -- 933
	end -- 933
	if not isChild and self.escort.state == "calming" then -- 933
		a.crouch = false -- 937
		a.h = SOLDIER_H -- 938
		a.vx = 0 -- 939
		self:fallY(a, dt) -- 940
		return -- 941
	end -- 941
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 943
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 944
	local nearCover = not isChild and self:nearCover(a) -- 945
	a.covered = nearCover and input.cover.held -- 946
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 948
	if a.rollT > 0 then -- 948
		a.rollT = a.rollT - dt -- 952
		a.vx = a.facing * ROLL_SPEED -- 953
		self:slideX(a, a.vx * dt) -- 954
		self:fallY(a, dt) -- 955
		if a.rollT <= 0 then -- 955
			self:flashSet("翻滚结束", 0.5) -- 957
		end -- 957
		return -- 959
	end -- 959
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 959
		if input.moveX ~= 0 then -- 959
			a.facing = input.moveX > 0 and 1 or -1 -- 964
		end -- 964
		if self:nearLowLedge(a) then -- 964
			a.vy = SOLDIER_JUMP -- 968
			a.onGround = false -- 969
			self:flashSet("翻上去", 0.3) -- 970
			return -- 971
		end -- 971
		a.rollT = ROLL_TIME -- 973
		self:flashSet("翻滚", 0.3) -- 974
		return -- 975
	end -- 975
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 978
	if isChild then -- 978
		if input.cover.held then -- 978
			speed = CHILD_SLOW -- 981
		end -- 981
		if a.crouch then -- 981
			speed = CHILD_SLOW -- 984
		end -- 984
	elseif a.covered then -- 984
		speed = SOLDIER_SPEED * 0.45 -- 987
	end -- 987
	local handsBusy = self.gripping or gripIntent -- 991
	local dir = self.gripping and 0 or input.moveX -- 992
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 993
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 994
	if dir ~= 0 then -- 994
		a.facing = dir > 0 and 1 or -1 -- 996
	end -- 996
	a.vx = dir * speed * diagonal -- 998
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 998
		a.vy = CHILD_JUMP -- 1002
		a.onGround = false -- 1003
		self:flashSet("跳", 0.25) -- 1004
	end -- 1004
	local previousDepth = a.depth -- 1008
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1009
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1010
	self:slideX(a, a.vx * dt) -- 1011
	self:fallY(a, dt) -- 1012
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1012
		self:shoot(a) -- 1016
	end -- 1016
end -- 919
function Play.prototype.stepPartner(self, p, dt) -- 1021
	local a = self.partner -- 1022
	if not a.alive then -- 1022
		return -- 1024
	end -- 1024
	a.crouch = false -- 1026
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1027
	a.vx = 0 -- 1028
	a.depthSpeed = 0 -- 1029
	self:fallY(a, dt) -- 1030
end -- 1021
function Play.prototype.stepEscort(self, dt, input) -- 1037
	local a = self.partner -- 1038
	a.depthSpeed = 0 -- 1039
	if not a.alive then -- 1039
		return -- 1041
	end -- 1041
	if not self:escortOn() then -- 1041
		a.vx = 0 -- 1044
		self:fallY(a, dt) -- 1045
		return -- 1046
	end -- 1046
	local p = self.player -- 1048
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1049
	local hadKnock1 = self.escort.knock1 -- 1050
	local hadKnock2 = self.escort.knock2 -- 1051
	self.calmConsumed = self.escort:update( -- 1052
		input, -- 1052
		p.x, -- 1052
		p.facing, -- 1052
		a.x, -- 1052
		dist -- 1052
	) -- 1052
	if not hadKnock1 and self.escort.knock1 then -- 1052
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1055
	end -- 1055
	if not hadKnock2 and self.escort.knock2 then -- 1055
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1058
	end -- 1058
	a.crouch = self.escort.crouchPose -- 1060
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1061
	if not self.escort.stopped then -- 1061
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1063
		local previousDepth = a.depth -- 1064
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1065
		local distance = math.max( -- 1066
			-travel, -- 1066
			math.min(travel, targetDepth - previousDepth) -- 1066
		) -- 1066
		self:slideDepth(a, distance) -- 1067
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1068
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1068
			a.vy = CHILD_JUMP -- 1070
			a.onGround = false -- 1071
		end -- 1071
	end -- 1071
	local dir = self.escort:moveDir(a.x) -- 1074
	a.vx = dir * CHILD_SPEED -- 1075
	if dir ~= 0 then -- 1075
		a.facing = dir -- 1077
		local before = a.x -- 1078
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1079
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1079
			a.vy = CHILD_JUMP -- 1082
			a.onGround = false -- 1083
		end -- 1083
	end -- 1083
	self:fallY(a, dt) -- 1086
end -- 1037
function Play.prototype.escortOn(self) -- 1090
	if self.room.key == "checkpoint" then -- 1090
		return true -- 1092
	end -- 1092
	if self.room.key == "prologue" then -- 1092
		return self.phase == "prologue-follow" -- 1095
	end -- 1095
	return self.room.key == "street" -- 1097
end -- 1090
function Play.prototype.storyLocked(self) -- 1101
	if self.caughtT > 0 then -- 1101
		return true -- 1103
	end -- 1103
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1103
		return true -- 1106
	end -- 1106
	if self.room.key == "gate" and self.phase == "gate-count" then -- 1106
		return true -- 1109
	end -- 1109
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1109
		return true -- 1112
	end -- 1112
	return false -- 1114
end -- 1101
function Play.prototype.swapToChild(self, x) -- 1118
	local tmp = self.player -- 1119
	self.player = self.partner -- 1120
	self.partner = tmp -- 1121
	self.childMode = true -- 1122
	self.player.alive = true -- 1123
	self.player.x = self.ox + x -- 1124
	self.player.y = 0 -- 1125
	self.player.depth = 0 -- 1126
	self.player.depthSpeed = 0 -- 1127
	self.player.vy = 0 -- 1128
	self.player.vx = 0 -- 1129
	self.player.onGround = true -- 1130
	self.player.crouch = false -- 1131
	self.player.h = CHILD_H -- 1132
	self.player.facing = 1 -- 1133
	self.partner.alive = true -- 1134
	self.cam.x = self.player.x -- 1135
end -- 1118
function Play.prototype.stepStory(self, dt, input) -- 1139
	if self.room.key == "prologue" then -- 1139
		self:stepPrologue(dt, input) -- 1141
	elseif self.room.key == "street" then -- 1141
		self:stepStreet(dt, input) -- 1143
	elseif self.room.key == "gate" then -- 1143
		self:stepGate(dt, input) -- 1145
	elseif self.room.key == "tower" then -- 1145
		self:stepTower(dt, input) -- 1147
	end -- 1147
end -- 1139
function Play.prototype.stepPrologue(self, dt, input) -- 1152
	local child = self.partner -- 1153
	if self.phase == "prologue-wait" then -- 1153
		child.crouch = true -- 1155
		child.h = CHILD_CROUCH_H -- 1156
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1157
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1159
		if near and input.interact.pressed then -- 1159
			self.phase = "prologue-give" -- 1161
			self.phaseTick = 0 -- 1162
			self:flashSet("递出针套", 1) -- 1163
		end -- 1163
		return -- 1165
	end -- 1165
	if self.phase == "prologue-give" then -- 1165
		self.phaseTick = self.phaseTick + 1 -- 1168
		if self.phaseTick == 12 then -- 1168
			self:flashSet("针套递过去", 0.7) -- 1170
		elseif self.phaseTick == 36 then -- 1170
			self:flashSet("纸条塞进针套", 0.9) -- 1172
		elseif self.phaseTick >= 60 then -- 1172
			self.phase = "prologue-follow" -- 1174
			self.phaseTick = 0 -- 1175
			child.crouch = false -- 1176
			child.h = CHILD_H -- 1177
			self:flashSet("她跟上了", 1.2) -- 1178
		end -- 1178
		return -- 1180
	end -- 1180
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1180
		self:requestRoom("street", "序章跟到门口") -- 1184
		self:flashSet("进街道", 1.2) -- 1185
	end -- 1185
end -- 1152
function Play.prototype.stepStreet(self, dt, input) -- 1190
	local p = self.player -- 1191
	local c = self.partner -- 1192
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1192
		self:requestRoom("checkpoint", "两人都到街尾") -- 1194
		self:flashSet("到检查站", 1.2) -- 1195
	end -- 1195
end -- 1190
function Play.prototype.stepGate(self, dt, input) -- 1200
	local ____temp_34 -- 1201
	if self.room.story == nil then -- 1201
		____temp_34 = nil -- 1201
	else -- 1201
		____temp_34 = self.room.story.gate -- 1201
	end -- 1201
	local g = ____temp_34 -- 1201
	if g == nil then -- 1201
		return -- 1203
	end -- 1203
	local p = self.player -- 1205
	if self.phase == "gate-idle" then -- 1205
		local a = self.partner -- 1208
		local gap = g.waitX - a.x -- 1209
		if math.abs(gap) > 3 then -- 1209
			a.facing = gap > 0 and 1 or -1 -- 1211
			a.vx = a.facing * CHILD_SPEED -- 1212
			local beforeX = a.x -- 1213
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1214
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1214
				a.vy = CHILD_JUMP -- 1216
				a.onGround = false -- 1217
			end -- 1217
			self:fallY(a, dt) -- 1219
		else -- 1219
			a.vx = 0 -- 1221
			a.x = g.waitX -- 1222
		end -- 1222
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1225
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1226
		if self.gateNeedConfirm then -- 1226
			if not input.interact.held then -- 1226
				self.gateRestartArmed = true -- 1231
			end -- 1231
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1231
				self.gateNeedConfirm = false -- 1234
				self.gateRestartArmed = true -- 1235
				self.phase = "gate-hold" -- 1236
				self.gateTick = 0 -- 1237
				self.gateSpawned = 0 -- 1238
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1239
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1240
			end -- 1240
			return -- 1242
		end -- 1242
		if atWinch and atWait then -- 1242
			self.phase = "gate-hold" -- 1245
			self.gateTick = 0 -- 1246
			self.gateSpawned = 0 -- 1247
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1248
		end -- 1248
		return -- 1250
	end -- 1250
	if self.phase == "gate-hold" then -- 1250
		self.gateTick = self.gateTick + 1 -- 1253
		local marks = {0, 540, 900, 1500} -- 1255
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1255
			local idx = self.gateSpawned -- 1257
			local ____self_enemies_35 = self.enemies -- 1257
			____self_enemies_35[#____self_enemies_35 + 1] = { -- 1258
				x = self.ox + 620 + idx * 62, -- 1259
				y = 0, -- 1259
				w = 26, -- 1259
				h = 84, -- 1259
				alive = true, -- 1260
				hitT = 0, -- 1260
				warnT = 0, -- 1260
				fireCd = 90 + idx * 45 -- 1260
			} -- 1260
			self.gateSpawned = self.gateSpawned + 1 -- 1262
			self:flashSet( -- 1263
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1263
				0.9 -- 1263
			) -- 1263
		end -- 1263
		if self.gateTick == 900 then -- 1263
			self:flashSet("灯灭了", 1) -- 1266
		elseif self.gateTick == 2100 then -- 1266
			self:flashSet("门底压下来了", 1) -- 1268
		end -- 1268
		if self.gateTick >= g.holdTicks then -- 1268
			self.phase = "gate-send" -- 1271
			self.phaseTick = 0 -- 1272
			self.enemies = {} -- 1274
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1275
		end -- 1275
		return -- 1277
	end -- 1277
	if self.phase == "gate-send" then -- 1277
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1280
		if near and input.interact.pressed then -- 1280
			self:swapToChild(g.doorX + 30) -- 1282
			self.phase = "gate-count" -- 1283
			self.countTick = 0 -- 1284
			self.countArmed = false -- 1286
			self.countPrevMove = input.moveX -- 1287
			self:flashSet("门开了 · 送她出去", 1.8) -- 1288
		end -- 1288
		return -- 1290
	end -- 1290
	if self.phase == "gate-count" then -- 1290
		self.countTick = self.countTick + 1 -- 1293
		if self.countTick == 360 then -- 1293
			self:flashSet("门关上", 0.9) -- 1295
		elseif self.countTick == 1020 then -- 1295
			self:flashSet("数到一百", 2.2) -- 1297
		end -- 1297
		local prevMove = self.countPrevMove -- 1301
		self.countPrevMove = input.moveX -- 1302
		if self.countTick >= 1440 then -- 1302
			if prevMove <= 0 and input.moveX > 0 then -- 1302
				self.countArmed = true -- 1305
			end -- 1305
			if self.countArmed and input.moveX > 0 then -- 1305
				self.phase = "gate-walk" -- 1308
				self.phaseTick = 0 -- 1309
				self:flashSet("她迈出第一步", 1.4) -- 1310
			end -- 1310
		end -- 1310
		return -- 1313
	end -- 1313
	if self.player.x >= g.exitX then -- 1313
		self:requestRoom("outside", "走出城门") -- 1317
		self:flashSet("出城门 · 城外", 1.4) -- 1318
	end -- 1318
end -- 1200
function Play.prototype.stepTower(self, dt, input) -- 1323
	local ____temp_36 -- 1324
	if self.room.story == nil then -- 1324
		____temp_36 = nil -- 1324
	else -- 1324
		____temp_36 = self.room.story.tower -- 1324
	end -- 1324
	local t = ____temp_36 -- 1324
	if t == nil then -- 1324
		return -- 1326
	end -- 1326
	if self.phase == "tower-wait" then -- 1326
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1329
		if near and input.interact.pressed then -- 1329
			self.phase = "tower-knock" -- 1331
			self.phaseTick = 0 -- 1332
			self.knocks = 1 -- 1333
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1334
			self:flashSet("敲一下", 0.6) -- 1335
		end -- 1335
		return -- 1337
	end -- 1337
	if self.phase == "tower-knock" then -- 1337
		self.phaseTick = self.phaseTick + 1 -- 1340
		if self.phaseTick == 12 then -- 1340
			self.knocks = 2 -- 1342
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1343
			self:flashSet("敲两下 · 第二声", 1) -- 1344
		elseif self.phaseTick >= t.knockTicks then -- 1344
			self.phase = "tower-given" -- 1346
			self.phaseTick = 0 -- 1347
			self:flashSet("门开了 · 提灯", 1.4) -- 1348
		end -- 1348
		return -- 1350
	end -- 1350
	if self.phase == "tower-given" then -- 1350
		self.phaseTick = self.phaseTick + 1 -- 1353
		if self.phaseTick == 60 then -- 1353
			self:flashSet("她递出针套和纸条", 1.6) -- 1355
		elseif self.phaseTick == 120 then -- 1355
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1357
		elseif self.phaseTick >= 180 then -- 1357
			self.phase = "tower-end" -- 1359
			self.phaseTick = 0 -- 1360
			self:flashSet("片尾 · E 再玩一次", 3) -- 1361
		end -- 1361
		return -- 1363
	end -- 1363
	if input.interact.pressed or input.retry.pressed then -- 1363
		self:requestRoom("prologue", "片尾再玩") -- 1366
		self:flashSet("回到序章", 1.4) -- 1367
	end -- 1367
end -- 1323
function Play.prototype.stepChase(self, dt, input) -- 1372
	if self.caughtT > 0 then -- 1372
		self.caughtT = self.caughtT - dt -- 1374
		if self.caughtT <= 0 then -- 1374
			self:recoverFromCaught() -- 1376
		end -- 1376
		return -- 1378
	end -- 1378
	if self.room.key == "village" then -- 1378
		self:stepScavChase() -- 1381
	elseif self.room.key == "forest" then -- 1381
		self:stepDog(dt) -- 1383
		if self.player.x >= self.ox + 1450 then -- 1383
			self:requestRoom("tower", "到林缘北塔") -- 1386
			self:flashSet("林缘 · 北塔", 1.4) -- 1387
		end -- 1387
	end -- 1387
end -- 1372
function Play.prototype.stepScavChase(self) -- 1393
	local s = self.room.scavenger -- 1394
	if s == nil then -- 1394
		return -- 1396
	end -- 1396
	local p = self.player -- 1398
	if self.passed and p.x > self.ox + 440 then -- 1398
		if self.scavChase then -- 1398
			self.scavChase = false -- 1402
			self.scavState = "back" -- 1403
			self.scavT = 0 -- 1404
		end -- 1404
		return -- 1406
	end -- 1406
	local dx = p.x - self.scavX -- 1408
	local dist = math.abs(dx) -- 1409
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1410
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1411
	if not self.scavChase then -- 1411
		if visible then -- 1411
			self.scavSee = self.scavSee + 1 -- 1414
			if self.scavSee >= 24 then -- 1414
				self.scavChase = true -- 1416
				self.scavState = "chase" -- 1417
				self.scavTargetX = p.x -- 1418
				self:flashSet("他看见你了", 1.2) -- 1419
			end -- 1419
		else -- 1419
			self.scavSee = 0 -- 1422
		end -- 1422
		return -- 1424
	end -- 1424
	local dir = p.x > self.scavX and 1 or -1 -- 1427
	self.scavX = self.scavX + dir * 96 / 60 -- 1428
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1428
		self:caught() -- 1430
		return -- 1431
	end -- 1431
	if hidden then -- 1431
		self.scavSee = 0 -- 1435
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1436
		self.scavT = self.scavT - 1 -- 1437
		if self.scavT <= 0 then -- 1437
			self.scavChase = false -- 1439
			self.scavState = "patrol" -- 1440
			self:flashSet("他失去了目标", 1) -- 1441
		end -- 1441
	end -- 1441
end -- 1393
function Play.prototype.stepDog(self, dt) -- 1447
	local ____temp_37 -- 1448
	if self.room.story == nil then -- 1448
		____temp_37 = nil -- 1448
	else -- 1448
		____temp_37 = self.room.story.dog -- 1448
	end -- 1448
	local dog = ____temp_37 -- 1448
	if dog == nil then -- 1448
		return -- 1450
	end -- 1450
	local p = self.player -- 1452
	local dist = math.abs(p.x - self.dogX) -- 1453
	if self.dogState == "patrol" then -- 1453
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1455
		if self.dogX < dog.x0 then -- 1455
			self.dogX = dog.x0 -- 1457
			self.dogDir = 1 -- 1458
		elseif self.dogX > dog.x1 then -- 1458
			self.dogX = dog.x1 -- 1460
			self.dogDir = -1 -- 1461
		end -- 1461
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1463
		if not p.crouch and moving and dist < dog.range then -- 1463
			self.dogState = "ear" -- 1465
			self.dogT = 18 -- 1466
			self.dogTargetX = p.x -- 1467
			self:flashSet("狗转耳朵", 0.8) -- 1468
		end -- 1468
		return -- 1470
	end -- 1470
	if self.dogState == "ear" then -- 1470
		self.dogT = self.dogT - 1 -- 1473
		if self.dogT <= 0 then -- 1473
			self.dogState = "chase" -- 1475
			self.dogTargetX = p.x -- 1476
			self:flashSet("狗追来了", 1.4) -- 1477
		end -- 1477
		return -- 1479
	end -- 1479
	if self.dogState == "chase" then -- 1479
		local dir = p.x > self.dogX and 1 or -1 -- 1482
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1483
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1483
			self:caught() -- 1485
			self.dogState = "sniff" -- 1486
			self.dogT = 60 -- 1487
		elseif dist > dog.range * 1.5 or p.crouch then -- 1487
			self.dogState = "sniff" -- 1489
			self.dogT = 60 -- 1490
			self:flashSet("狗停下了", 0.9) -- 1491
		end -- 1491
		return -- 1493
	end -- 1493
	if self.dogState == "sniff" then -- 1493
		self.dogT = self.dogT - 1 -- 1496
		if self.dogT <= 0 then -- 1496
			self.dogState = "back" -- 1498
		end -- 1498
		return -- 1500
	end -- 1500
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1503
	self.dogX = self.dogX + dir * dog.speed * dt -- 1504
	if math.abs(self.dogX - dog.x0) < 2 then -- 1504
		self.dogX = dog.x0 -- 1506
		self.dogState = "patrol" -- 1507
	end -- 1507
end -- 1447
function Play.prototype.caught(self) -- 1511
	self.caughtT = 1 -- 1512
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1513
end -- 1511
function Play.prototype.recoverFromCaught(self) -- 1517
	local p = self.player -- 1518
	p.x = self.ox + 140 -- 1519
	p.y = 0 -- 1520
	p.vy = 0 -- 1521
	p.vx = 0 -- 1522
	p.onGround = true -- 1523
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1523
		self.scavX = self.room.scavenger.x0 -- 1525
		self.scavState = "patrol" -- 1526
		self.scavSee = 0 -- 1527
		self.scavChase = false -- 1528
		self.scavT = 0 -- 1529
	end -- 1529
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1529
		self.dogX = self.room.story.dog.x0 -- 1532
		self.dogState = "patrol" -- 1533
		self.dogT = 0 -- 1534
	end -- 1534
	self.cam.x = p.x -- 1536
	self.cam.y = p.y + CAM_LOOK_UP -- 1537
	self:flashSet("回到安全点", 1.2) -- 1538
end -- 1517
function Play.prototype.updateGate(self) -- 1542
	if self.room.key ~= "checkpoint" then -- 1542
		self.gateOpen = false -- 1544
		return -- 1545
	end -- 1545
	local function inZone(x) -- 1547
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1547
	end -- 1547
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1548
end -- 1542
function Play.prototype.addItem(self, kind) -- 1554
	local inv = self.run.inventory -- 1555
	if kind == "shield" then -- 1555
		if inv.shield >= TOOL_CAP then -- 1555
			return false -- 1558
		end -- 1558
		inv.shield = inv.shield + 1 -- 1560
		return true -- 1561
	end -- 1561
	if kind == "wedge" then -- 1561
		if inv.wedge >= CONSUMABLE_CAP then -- 1561
			return false -- 1565
		end -- 1565
		inv.wedge = inv.wedge + 1 -- 1567
		return true -- 1568
	end -- 1568
	if kind == "ammo" then -- 1568
		if inv.ammo >= CONSUMABLE_CAP then -- 1568
			return false -- 1572
		end -- 1572
		inv.ammo = inv.ammo + 1 -- 1574
		return true -- 1575
	end -- 1575
	if kind == "scrap" then -- 1575
		inv.scrap = inv.scrap + 1 -- 1579
		return true -- 1580
	end -- 1580
	if kind == "pass" then -- 1580
		inv.pass = inv.pass + 1 -- 1583
		return true -- 1584
	end -- 1584
	if kind == "quickbelt" then -- 1584
		inv.quickbelt = inv.quickbelt + 1 -- 1587
		return true -- 1588
	end -- 1588
	return false -- 1590
end -- 1554
function Play.prototype.findBox(self, id) -- 1593
	local i = 0 -- 1594
	do -- 1594
		i = 0 -- 1595
		while i < #self.boxes do -- 1595
			if self.boxes[i + 1].id == id then -- 1595
				return self.boxes[i + 1] -- 1597
			end -- 1597
			i = i + 1 -- 1595
		end -- 1595
	end -- 1595
	return nil -- 1600
end -- 1593
function Play.prototype.findWedgeTarget(self) -- 1604
	local best = nil -- 1605
	local bestD = 0 -- 1606
	local i = 0 -- 1607
	do -- 1607
		i = 0 -- 1608
		while i < #self.boxes do -- 1608
			do -- 1608
				local b = self.boxes[i + 1] -- 1609
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 1609
					goto __continue248 -- 1611
				end -- 1611
				if not self:nearBox(b, 26) then -- 1611
					goto __continue248 -- 1614
				end -- 1614
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 1616
				if best == nil or d < bestD then -- 1616
					best = b -- 1618
					bestD = d -- 1619
				end -- 1619
			end -- 1619
			::__continue248:: -- 1619
			i = i + 1 -- 1608
		end -- 1608
	end -- 1608
	return best -- 1622
end -- 1604
function Play.prototype.stepCraft(self, input) -- 1630
	local inv = self.run.inventory -- 1631
	local ____opt_38 = self.run.trial -- 1631
	local required = CRAFT_TICKS - 6 * (____opt_38 and ____opt_38.ranks.craft or 0) -- 1632
	if self.craftT > 0 then -- 1632
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 1632
			self.craftT = 0 -- 1636
			self:flashSet("制作中断", 0.8) -- 1637
			return true -- 1638
		end -- 1638
		self.craftT = self.craftT + 1 -- 1640
		if self.craftT >= required then -- 1640
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 1640
				inv.scrap = inv.scrap - 1 -- 1643
				inv.wedge = inv.wedge + 1 -- 1644
				self:flashSet("制得木楔", 1.2) -- 1645
				self:log("制木楔") -- 1646
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 1647
			end -- 1647
			self.craftT = 0 -- 1649
		end -- 1649
		return true -- 1651
	end -- 1651
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 1651
		self.craftT = 1 -- 1654
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 1655
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 1656
		return true -- 1657
	end -- 1657
	return false -- 1659
end -- 1630
function Play.prototype.nearBox(self, b, reach) -- 1662
	local p = self.player -- 1663
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1664
end -- 1662
function Play.prototype.findInteract(self) -- 1670
	local p = self.player -- 1671
	local best = nil -- 1672
	local bestD = 1000000000 -- 1673
	local i = 0 -- 1674
	do -- 1674
		i = 0 -- 1675
		while i < #self.boxes do -- 1675
			do -- 1675
				local b = self.boxes[i + 1] -- 1676
				if b.interact == nil or b.broken == true then -- 1676
					goto __continue261 -- 1678
				end -- 1678
				if not self:nearBox(b, b.interact.reach or 27) then -- 1678
					goto __continue261 -- 1681
				end -- 1681
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1683
				if d < bestD then -- 1683
					bestD = d -- 1685
					best = b -- 1686
				end -- 1686
			end -- 1686
			::__continue261:: -- 1686
			i = i + 1 -- 1675
		end -- 1675
	end -- 1675
	return best -- 1689
end -- 1670
function Play.prototype.stepCampaign(self, dt, input) -- 1693
	local wr = self.room -- 1694
	local p = self.player -- 1695
	if self.reloadT > 0 then -- 1695
		self.reloadT = self.reloadT - 1 -- 1697
	end -- 1697
	if self.bracedShield ~= nil then -- 1697
		self.bracedShield.x = p.x + p.facing * 26 -- 1701
		self.bracedShield.y = p.y -- 1702
		local shBox = __TS__ArrayFind( -- 1703
			self.boxes, -- 1703
			function(____, b) return b.id == "braced_shield" end -- 1703
		) -- 1703
		if shBox ~= nil then -- 1703
			shBox.x0 = self.bracedShield.x - 15 -- 1705
			shBox.x1 = self.bracedShield.x + 15 -- 1706
			shBox.y0 = self.bracedShield.y -- 1707
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1708
		end -- 1708
	end -- 1708
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1708
		self.run.route = "drygoods" -- 1714
		self.run.joined = false -- 1715
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1716
		self:log("转布行线") -- 1717
	end -- 1717
	local i = 0 -- 1720
	do -- 1720
		i = 0 -- 1721
		while i < #self.pickups do -- 1721
			do -- 1721
				local pk = self.pickups[i + 1] -- 1722
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1722
					goto __continue272 -- 1724
				end -- 1724
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1726
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1727
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1727
					if not self:addItem(pk.kind) then -- 1727
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 1731
						self:log("满包拒绝 " .. pk.kind) -- 1732
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 1733
						goto __continue272 -- 1734
					end -- 1734
					self.run.taken[pk.id] = true -- 1736
					pk.id = "" -- 1737
					self:flashSet("拾取 " .. pk.label, 1) -- 1738
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1739
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1740
				end -- 1740
			end -- 1740
			::__continue272:: -- 1740
			i = i + 1 -- 1721
		end -- 1721
	end -- 1721
	if not self:stepCraft(input) and input.interact.pressed then -- 1721
		self:campaignInteract() -- 1744
	end -- 1744
	self:stepCampaignCart(dt, input) -- 1746
	self:stepCampaignGoal() -- 1747
end -- 1693
function Play.prototype.campaignInteract(self) -- 1751
	local b = self:findInteract() -- 1752
	if b ~= nil then -- 1752
		self:useInteract(b) -- 1754
		return -- 1755
	end -- 1755
	local inv = self.run.inventory -- 1757
	if inv.wedge > 0 then -- 1757
		local w = self:findWedgeTarget() -- 1759
		if w ~= nil then -- 1759
			if w.breakable ~= nil then -- 1759
				local ____w_breakable_40, ____hp_41 = w.breakable, "hp" -- 1759
				____w_breakable_40[____hp_41] = ____w_breakable_40[____hp_41] + (w.breakable.wedgeHp or 1) -- 1762
			end -- 1762
			inv.wedge = inv.wedge - 1 -- 1764
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 1765
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 1767
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 1768
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 1769
			return -- 1770
		end -- 1770
	end -- 1770
	if inv.ammo > 0 and self.reloadT > 0 then -- 1770
		self.reloadT = 0 -- 1775
		inv.ammo = inv.ammo - 1 -- 1776
		self:flashSet("备用弹包 · 膛内补满", 1) -- 1777
		self:log("用备用弹包") -- 1778
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 1779
		return -- 1780
	end -- 1780
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 1780
		local p = self.player -- 1784
		self.bracedShield = { -- 1785
			x = p.x + p.facing * 26, -- 1785
			y = p.y, -- 1785
			w = 30, -- 1785
			h = 64, -- 1785
			hp = 1 -- 1785
		} -- 1785
		local ____self_boxes_42 = self.boxes -- 1785
		____self_boxes_42[#____self_boxes_42 + 1] = { -- 1786
			x0 = self.bracedShield.x - 15, -- 1787
			x1 = self.bracedShield.x + 15, -- 1787
			y0 = p.y, -- 1788
			y1 = p.y + 64, -- 1788
			depth = {min = -46, max = 46}, -- 1788
			label = "架起的残盾", -- 1788
			id = "braced_shield", -- 1788
			soft = true -- 1789
		} -- 1789
		inv.shield = inv.shield - 1 -- 1792
		self:flashSet("架残盾 · 挡一发", 1.2) -- 1793
		self:log("架残盾") -- 1794
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 1795
		return -- 1796
	end -- 1796
	if inv.pass > 0 and self.run.joined == false then -- 1796
		inv.pass = inv.pass - 1 -- 1799
		self.run.joined = true -- 1800
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 1801
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 1802
		return -- 1803
	end -- 1803
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 1805
end -- 1751
function Play.prototype.useInteract(self, b) -- 1808
	local kind = b.interact == nil and "" or b.interact.kind -- 1809
	local wr = self.room -- 1810
	if kind == "open_board" then -- 1810
		b.broken = true -- 1812
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 1813
		for ____, cover in ipairs(self.boxes) do -- 1814
			if cover.id == "s2_board_cover" then -- 1814
				cover.broken = false -- 1816
				cover.hidden = false -- 1817
			end -- 1817
		end -- 1817
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 1820
		self.run.joined = true -- 1821
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 1822
		self:log("放下窗板") -- 1823
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 1824
		return -- 1825
	end -- 1825
	if kind == "lower_curtain" then -- 1825
		for ____, curtain in ipairs(self.boxes) do -- 1828
			if curtain.id == "c2_curtain" then -- 1828
				curtain.broken = false -- 1830
				curtain.hidden = false -- 1831
			end -- 1831
		end -- 1831
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 1834
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 1835
		self:log("放下木帘") -- 1836
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 1837
		return -- 1838
	end -- 1838
	if kind == "raise_latch" then -- 1838
		if wr.key == "c2-granary" and not self.cartDocked then -- 1838
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 1842
			return -- 1843
		end -- 1843
		b.broken = true -- 1845
		self.objectiveDone = true -- 1846
		if wr.key == "c1-yard" then -- 1846
			self.run.c1Latch = true -- 1849
			self.run.joined = true -- 1850
		else -- 1850
			self.run.c2Latch = true -- 1852
			self.run.joined = true -- 1853
		end -- 1853
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 1855
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 1856
		self:log("抬闩") -- 1857
		self:flashSet("抬闩 · 通路打开", 1.4) -- 1858
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 1859
	end -- 1859
end -- 1808
function Play.prototype.stepCampaignCart(self, dt, input) -- 1864
	local wr = self.room -- 1865
	local c = wr.cart -- 1866
	if c.bodyW <= 0 then -- 1866
		return -- 1868
	end -- 1868
	local p = self.player -- 1870
	local handleX = self.cartAxle + c.handleOffset -- 1871
	if not self.gripping then -- 1871
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 1871
			self.gripping = true -- 1875
			self:flashSet("握住车柄 · A/D 推", 1) -- 1876
		end -- 1876
		return -- 1878
	end -- 1878
	if input.interact.pressed then -- 1878
		self.gripping = false -- 1881
		self:flashSet("松手", 0.5) -- 1882
		return -- 1883
	end -- 1883
	if not self.cartDocked then -- 1883
		if input.moveX ~= 0 and not self:stuckCart() then -- 1883
			self.cartAxle = math.max( -- 1887
				c.startX, -- 1887
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 1887
			) -- 1887
		end -- 1887
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 1887
			self.cartExposed = true -- 1892
			local gun = nil -- 1893
			local gi = 0 -- 1894
			do -- 1894
				gi = 0 -- 1895
				while gi < #self.enemies do -- 1895
					local e = self.enemies[gi + 1] -- 1896
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 1896
						gun = e -- 1898
						break -- 1899
					end -- 1899
					gi = gi + 1 -- 1895
				end -- 1895
			end -- 1895
			if gun ~= nil then -- 1895
				self:campaignEnemyFire(gun) -- 1903
			end -- 1903
		end -- 1903
		p.x = self.cartAxle + c.handleOffset -- 1906
		p.y = c.baseY + (c.depth or 0) -- 1907
		p.vx = 0 -- 1908
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 1908
			self.cartAxle = c.endX -- 1910
			self.cartDocked = true -- 1911
			self.gripping = false -- 1912
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 1913
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 1914
			self:flashSet("车轮入窝", 1.2) -- 1915
			self:log("车轮入窝") -- 1916
		end -- 1916
	end -- 1916
end -- 1864
function Play.prototype.stuckCart(self) -- 1922
	local i = 0 -- 1923
	do -- 1923
		i = 0 -- 1924
		while i < #self.boxes do -- 1924
			do -- 1924
				local b = self.boxes[i + 1] -- 1925
				if b.broken == true or b.breakable == nil or b.soft == true then -- 1925
					goto __continue313 -- 1927
				end -- 1927
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 1929
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 1929
					return true -- 1931
				end -- 1931
			end -- 1931
			::__continue313:: -- 1931
			i = i + 1 -- 1924
		end -- 1924
	end -- 1924
	return false -- 1934
end -- 1922
function Play.prototype.stepCampaignGoal(self) -- 1938
	local wr = self.room -- 1939
	local c = wr.campaign -- 1940
	if c == nil then -- 1940
		return -- 1942
	end -- 1942
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 1942
		self.objectiveDone = true -- 1945
	end -- 1945
	if c.goal == "reach_exit" then -- 1945
		self.objectiveDone = true -- 1948
	end -- 1948
	if not self.objectiveDone then -- 1948
		return -- 1951
	end -- 1951
	local p = self.player -- 1953
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 1954
	if p.x < c.exitX or not partnerOk then -- 1954
		return -- 1956
	end -- 1956
	if c.next ~= nil and c.next ~= "" then -- 1956
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 1959
		self:flashSet("过关 · " .. c.next, 1.2) -- 1960
	elseif not self.run.finished then -- 1960
		self.run.finished = true -- 1962
		self:flashSet( -- 1963
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 1963
			2 -- 1963
		) -- 1963
		self:log("C2 灰盒完成") -- 1964
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 1965
	end -- 1965
end -- 1938
function Play.prototype.stepCampaignPartner(self, dt) -- 1970
	local a = self.partner -- 1971
	local wr = self.room -- 1972
	local cp = wr.companion -- 1973
	if not a.alive then -- 1973
		return -- 1975
	end -- 1975
	local p = self.player -- 1977
	local wait = false -- 1978
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 1979
	local targetDepth = p.depth -- 1980
	if self.run.joined == false then -- 1980
		wait = true -- 1982
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1983
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1984
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 1984
		wait = true -- 1986
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1987
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1988
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 1988
		wait = true -- 1990
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 1991
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 1992
	end -- 1992
	if self.partnerStuck > 0.3 then -- 1992
		a.x = a.x + a.facing * 44 -- 1996
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 1997
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 1998
		self.partnerLaneHold = 1.1 -- 1999
		self.partnerStuck = 0 -- 2000
	end -- 2000
	if self.partnerLaneHold > 0 then -- 2000
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2003
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2004
	end -- 2004
	local dx = targetX - a.x -- 2006
	if not wait and math.abs(dx) > 74 then -- 2006
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2008
		local before = a.x -- 2009
		a.vx = dx > 0 and speed or -speed -- 2010
		a.facing = dx > 0 and 1 or -1 -- 2011
		self:slideX(a, a.vx * dt) -- 2012
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2012
			a.vy = CHILD_JUMP -- 2015
			a.onGround = false -- 2016
		end -- 2016
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2018
	else -- 2018
		a.vx = 0 -- 2020
		self.partnerStuck = 0 -- 2021
	end -- 2021
	local dz = targetDepth - a.depth -- 2023
	if math.abs(dz) > 6 then -- 2023
		local step = math.max( -- 2025
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2025
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2025
		) -- 2025
		a.depth = a.depth + step -- 2026
	end -- 2026
	a.depthSpeed = 0 -- 2028
	a.h = CHILD_H -- 2029
	a.crouch = false -- 2030
	self:fallY(a, dt) -- 2031
end -- 1970
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2035
	local p = self.player -- 2036
	local i = 0 -- 2037
	do -- 2037
		i = 0 -- 2038
		while i < #self.enemies do -- 2038
			do -- 2038
				local ____opt_43 = self.run.trial -- 2038
				if ____opt_43 and ____opt_43.lost then -- 2038
					return -- 2039
				end -- 2039
				local e = self.enemies[i + 1] -- 2040
				if not e.alive then -- 2040
					goto __continue337 -- 2042
				end -- 2042
				if e.hitT > 0 then -- 2042
					e.hitT = e.hitT - dt -- 2045
				end -- 2045
				if e.kind == "breaker" then -- 2045
					self:stepBreaker(e, dt) -- 2048
					goto __continue337 -- 2049
				end -- 2049
				if e.kind == "shield" then -- 2049
					self:stepShield(e, dt, input) -- 2052
					goto __continue337 -- 2053
				end -- 2053
				local dx = e.x - p.x -- 2056
				if not e.awake then -- 2056
					if math.abs(dx) > 520 then -- 2056
						goto __continue337 -- 2059
					end -- 2059
					e.awake = true -- 2061
					e.fireCd = 48 -- 2062
					goto __continue337 -- 2063
				end -- 2063
				if math.abs(dx) > ENEMY_RANGE then -- 2063
					goto __continue337 -- 2066
				end -- 2066
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2066
					goto __continue337 -- 2071
				end -- 2071
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2071
					goto __continue337 -- 2074
				end -- 2074
				if self:blockedShot(e, p) then -- 2074
					if e.warnT > 0 then -- 2074
						e.warnT = 0 -- 2080
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2081
					end -- 2081
					goto __continue337 -- 2083
				end -- 2083
				if e.warnT > 0 then -- 2083
					e.warnT = e.warnT - 1 -- 2086
					if e.warnT <= 0 then -- 2086
						self:campaignEnemyFire(e) -- 2088
					end -- 2088
				elseif e.fireCd > 0 then -- 2088
					e.fireCd = e.fireCd - 1 -- 2091
					if e.fireCd <= 0 then -- 2091
						e.warnT = WARN_TICKS -- 2093
					end -- 2093
				else -- 2093
					e.fireCd = 40 -- 2096
				end -- 2096
			end -- 2096
			::__continue337:: -- 2096
			i = i + 1 -- 2038
		end -- 2038
	end -- 2038
end -- 2035
function Play.prototype.blockedShot(self, e, p) -- 2102
	local eDepth = e.depth or 0 -- 2103
	local ex = e.x -- 2104
	local ey = e.y + e.h * 0.62 -- 2106
	local px = p.x -- 2107
	local py = p.y + p.h * 0.55 -- 2108
	local dx = px - ex -- 2109
	local dyScreen = py + p.depth - (ey + eDepth) -- 2110
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 2111
	if len < 0.01 then -- 2111
		return false -- 2113
	end -- 2113
	local ray = { -- 2117
		x = ex, -- 2118
		y = ey, -- 2118
		dx = dx / len, -- 2119
		dy = (py - ey) / len, -- 2119
		depth = eDepth, -- 2120
		dDepth = (p.depth - eDepth) / len -- 2120
	} -- 2120
	local best = -1 -- 2122
	local j = 0 -- 2123
	do -- 2123
		j = 0 -- 2124
		while j < #self.boxes do -- 2124
			do -- 2124
				local b = self.boxes[j + 1] -- 2125
				if b.broken == true or b.passable == true or b.hidden == true then -- 2125
					goto __continue358 -- 2127
				end -- 2127
				if b.id == "braced_shield" then -- 2127
					goto __continue358 -- 2132
				end -- 2132
				local t = hitBox(ray, b) -- 2134
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 2134
					best = t -- 2138
				end -- 2138
			end -- 2138
			::__continue358:: -- 2138
			j = j + 1 -- 2124
		end -- 2124
	end -- 2124
	return best >= 0 -- 2141
end -- 2102
function Play.prototype.campaignEnemyFire(self, e) -- 2144
	local p = self.player -- 2145
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2146
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2146
		local ____self_bracedShield_45, ____hp_46 = self.bracedShield, "hp" -- 2146
		____self_bracedShield_45[____hp_46] = ____self_bracedShield_45[____hp_46] - 1 -- 2148
		self.boxes = __TS__ArrayFilter( -- 2149
			self.boxes, -- 2149
			function(____, b) return b.id ~= "braced_shield" end -- 2149
		) -- 2149
		self.bracedShield = nil -- 2150
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2151
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2152
		return -- 2153
	end -- 2153
	if self:blockedShot(e, p) then -- 2153
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2156
		return -- 2157
	end -- 2157
	local cover = self:blockedByCover(e, p) -- 2159
	if cover ~= nil and self.coverHug then -- 2159
		self.coveredFlash = 0.5 -- 2161
		self:flashSet("掩体挡下", 0.6) -- 2162
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2163
		return -- 2168
	end -- 2168
	if self.invulnT > 0 then -- 2168
		return -- 2171
	end -- 2171
	local ____opt_47 = self.run.trial -- 2171
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_47 and ____opt_47.ranks.guard or 0) -- 2173
	self.craftT = 0 -- 2174
	self.hp = self.hp - 1 -- 2175
	self:emit("actorHit", { -- 2176
		target = "player", -- 2176
		amount = 1, -- 2176
		hp = self.hp, -- 2176
		maxHp = self.maxHp, -- 2176
		enemyX = e.x -- 2176
	}) -- 2176
	self:flashSet( -- 2177
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2177
		0.8 -- 2177
	) -- 2177
	if self.hp <= 0 then -- 2177
		self:campaignFailed() -- 2179
	end -- 2179
end -- 2144
function Play.prototype.stepShield(self, e, dt, input) -- 2184
	local p = self.player -- 2185
	local dx = p.x - e.x -- 2186
	local adx = math.abs(dx) -- 2187
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2190
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2191
	if adx > 150 then -- 2191
		local before = e.x -- 2193
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2194
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2194
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2197
		end -- 2197
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2197
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2202
		local rollDodges = p.rollT > 0 and fromFront -- 2203
		if not rollDodges and self.invulnT <= 0 then -- 2203
			local ____opt_49 = self.run.trial -- 2203
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_49 and ____opt_49.ranks.guard or 0) -- 2205
			self.craftT = 0 -- 2206
			self.hp = self.hp - 1 -- 2207
			self:emit("actorHit", { -- 2208
				target = "player", -- 2208
				amount = 1, -- 2208
				hp = self.hp, -- 2208
				maxHp = self.maxHp, -- 2208
				enemyX = e.x -- 2208
			}) -- 2208
			self:flashSet( -- 2209
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2209
				0.8 -- 2209
			) -- 2209
			if self.hp <= 0 then -- 2209
				self:campaignFailed() -- 2211
				return -- 2212
			end -- 2212
		end -- 2212
		e.swingT = 70 -- 2215
	end -- 2215
	if (e.swingT or 0) > 0 then -- 2215
		e.swingT = (e.swingT or 0) - 1 -- 2218
	end -- 2218
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2218
		local dd = p.depth - (e.depth or 0) -- 2221
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2222
	end -- 2222
end -- 2184
function Play.prototype.stepBreaker(self, e, dt) -- 2227
	local p = self.player -- 2228
	if e.awake ~= true then -- 2228
		if math.abs(p.x - e.x) < 560 then -- 2228
			e.awake = true -- 2231
		else -- 2231
			return -- 2233
		end -- 2233
	end -- 2233
	local target = nil -- 2236
	local bestD = 1000000000 -- 2237
	local i = 0 -- 2238
	do -- 2238
		i = 0 -- 2239
		while i < #self.boxes do -- 2239
			do -- 2239
				local b = self.boxes[i + 1] -- 2240
				if b.breakable == nil or b.broken == true then -- 2240
					goto __continue382 -- 2242
				end -- 2242
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2244
				if d < bestD then -- 2244
					bestD = d -- 2246
					target = b -- 2247
				end -- 2247
			end -- 2247
			::__continue382:: -- 2247
			i = i + 1 -- 2239
		end -- 2239
	end -- 2239
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2250
	local dx = tx - e.x -- 2251
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2252
	if math.abs(dx) > reach then -- 2252
		local before = e.x -- 2254
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2255
		if math.abs(e.x - before) < 0.3 then -- 2255
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2257
		end -- 2257
	elseif (e.swingT or 0) <= 0 then -- 2257
		e.swingT = 64 -- 2260
		if target ~= nil then -- 2260
			self:damageProp(target, 2) -- 2262
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2262
			local ____opt_51 = self.run.trial -- 2262
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_51 and ____opt_51.ranks.guard or 0) -- 2264
			self.craftT = 0 -- 2265
			self.hp = self.hp - 1 -- 2266
			self:emit("actorHit", { -- 2267
				target = "player", -- 2267
				amount = 1, -- 2267
				hp = self.hp, -- 2267
				maxHp = self.maxHp, -- 2267
				enemyX = e.x -- 2267
			}) -- 2267
			self:flashSet("破障手近身", 0.8) -- 2268
			if self.hp <= 0 then -- 2268
				self:campaignFailed() -- 2270
				return -- 2271
			end -- 2271
		end -- 2271
	end -- 2271
	if (e.swingT or 0) > 0 then -- 2271
		e.swingT = (e.swingT or 0) - 1 -- 2276
	end -- 2276
end -- 2227
function Play.prototype.campaignFailed(self) -- 2280
	if self.run.trial ~= nil then -- 2280
		self.run.trial.lost = true -- 2282
		self.wantRoom = "" -- 2283
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2284
		return -- 2285
	end -- 2285
	local p = self.player -- 2287
	self.hp = self.maxHp -- 2288
	self.invulnT = INVULN_RESPAWN_TICKS -- 2289
	self.reloadT = 0 -- 2290
	self.gripping = false -- 2291
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2292
	self:log("被击倒") -- 2293
	p.x = self.room.minX + 90 -- 2294
	p.y = 0 -- 2295
	p.depth = 0 -- 2296
	p.vx = 0 -- 2297
	p.vy = 0 -- 2298
	p.onGround = true -- 2299
	p.rollT = 0 -- 2300
	self.partner.x = p.x - 50 -- 2301
	self.partner.y = 0 -- 2302
	self.partner.depth = 0 -- 2303
	self.cam.x = p.x -- 2304
	local i = 0 -- 2305
	do -- 2305
		i = 0 -- 2306
		while i < #self.enemies do -- 2306
			do -- 2306
				local e = self.enemies[i + 1] -- 2307
				if not e.alive then -- 2307
					goto __continue395 -- 2309
				end -- 2309
				e.x = e.homeX == nil and e.x or e.homeX -- 2311
				e.warnT = 0 -- 2312
				e.fireCd = 40 -- 2313
				e.swingT = 0 -- 2314
				e.awake = false -- 2315
			end -- 2315
			::__continue395:: -- 2315
			i = i + 1 -- 2306
		end -- 2306
	end -- 2306
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2317
end -- 2280
function Play.prototype.stepEnemies(self, dt, input) -- 2320
	local i = 0 -- 2321
	do -- 2321
		i = 0 -- 2322
		while i < #self.enemies do -- 2322
			local e = self.enemies[i + 1] -- 2323
			if e.hitT > 0 then -- 2323
				e.hitT = e.hitT - dt -- 2325
			end -- 2325
			i = i + 1 -- 2322
		end -- 2322
	end -- 2322
	if self.coveredFlash > 0 then -- 2322
		self.coveredFlash = self.coveredFlash - dt -- 2329
	end -- 2329
	if self.isCampaign then -- 2329
		self:stepCampaignEnemies(dt, input) -- 2332
		return -- 2333
	end -- 2333
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2333
		return -- 2337
	end -- 2337
	do -- 2337
		i = 0 -- 2339
		while i < #self.enemies do -- 2339
			do -- 2339
				local e = self.enemies[i + 1] -- 2340
				if not e.alive then -- 2340
					goto __continue405 -- 2342
				end -- 2342
				if e.warnT > 0 then -- 2342
					e.warnT = e.warnT - 1 -- 2345
					if e.warnT <= 0 then -- 2345
						self:enemyFire(e, input) -- 2347
					end -- 2347
					goto __continue405 -- 2349
				end -- 2349
				if e.fireCd > 0 then -- 2349
					e.fireCd = e.fireCd - 1 -- 2352
					if e.fireCd <= 0 then -- 2352
						e.warnT = WARN_TICKS -- 2354
					end -- 2354
				else -- 2354
					e.warnT = WARN_TICKS -- 2358
				end -- 2358
			end -- 2358
			::__continue405:: -- 2358
			i = i + 1 -- 2339
		end -- 2339
	end -- 2339
end -- 2320
function Play.prototype.enemyFire(self, e, input) -- 2364
	local p = self.player -- 2365
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2365
		self:flashSet("枪声响在远处", 0.4) -- 2367
		e.fireCd = FIRE_COOLDOWN -- 2368
		return -- 2369
	end -- 2369
	local cover = self:blockedByCover(e, p) -- 2372
	local hugging = cover ~= nil -- 2373
	self.coverBlocking = hugging -- 2374
	local covered = hugging and input.cover.held -- 2375
	if covered then -- 2375
		self.coveredFlash = 0.5 -- 2377
		self:flashSet("掩体挡下", 0.5) -- 2378
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2379
		e.fireCd = FIRE_COOLDOWN -- 2384
		return -- 2385
	end -- 2385
	self.hp = self.hp - 1 -- 2387
	self:emit("actorHit", { -- 2388
		target = "player", -- 2388
		amount = 1, -- 2388
		hp = self.hp, -- 2388
		maxHp = self.maxHp, -- 2388
		enemyX = e.x -- 2388
	}) -- 2388
	self:flashSet( -- 2389
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2389
		0.7 -- 2389
	) -- 2389
	e.fireCd = FIRE_COOLDOWN -- 2390
	if self.hp <= 0 then -- 2390
		self:gateFailed() -- 2392
	end -- 2392
end -- 2364
function Play.prototype.blockedByCover(self, enemy, p) -- 2397
	local b = self:coverAt(p) -- 2398
	if b == nil then -- 2398
		return nil -- 2400
	end -- 2400
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2402
end -- 2397
function Play.prototype.gateFailed(self) -- 2406
	local ____temp_53 -- 2407
	if self.room.story == nil then -- 2407
		____temp_53 = nil -- 2407
	else -- 2407
		____temp_53 = self.room.story.gate -- 2407
	end -- 2407
	local g = ____temp_53 -- 2407
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2408
	self.hp = self.maxHp -- 2409
	self.gateTick = 0 -- 2410
	self.gateSpawned = 0 -- 2411
	self.enemies = {} -- 2412
	self.gateFailCount = self.gateFailCount + 1 -- 2413
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2415
	self.player.y = 0 -- 2416
	self.player.vy = 0 -- 2417
	self.player.depth = 0 -- 2418
	self.player.depthSpeed = 0 -- 2419
	self.player.onGround = true -- 2420
	self.player.crouch = false -- 2421
	self.player.h = SOLDIER_H -- 2422
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2423
	self.partner.y = 0 -- 2424
	self.partner.vy = 0 -- 2425
	self.partner.depth = 0 -- 2426
	self.partner.depthSpeed = 0 -- 2427
	self.partner.onGround = true -- 2428
	self.cam.x = self.player.x -- 2429
	self.phase = "gate-idle" -- 2430
	self.phaseTick = 0 -- 2431
	self.coverHug = false -- 2432
	self.coverBlocking = false -- 2433
	self.coverEntity = "" -- 2434
	self.gateNeedConfirm = true -- 2435
	self.gateRestartArmed = false -- 2436
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2437
end -- 2406
function Play.prototype.stepInteract(self, dt, input) -- 2440
	local p = self.player -- 2441
	local calmUsed = self.calmConsumed -- 2442
	self.calmConsumed = false -- 2443
	local calming = self.escort.state == "calming" -- 2445
	self.focusCart = false -- 2446
	if self.room.key == "outside" then -- 2446
		local c = self.room.cart -- 2448
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2449
		local dy = p.y - c.baseY -- 2450
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2451
	end -- 2451
	if not calmUsed and not calming then -- 2451
		self:stepCart(dt, input) -- 2455
	end -- 2455
	if calmUsed then -- 2455
		self:flashSet("安抚 · 敲两下", 0.8) -- 2460
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2460
		if self.knockT > 0 then -- 2460
			self.knocks = self.knocks + 1 -- 2464
		else -- 2464
			self.knocks = 1 -- 2466
		end -- 2466
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2468
		self.knockT = 1.2 -- 2469
		if self.knocks >= 2 then -- 2469
			self:flashSet("敲两下", 0.8) -- 2471
			self.knocks = 0 -- 2472
		else -- 2472
			self:flashSet("敲一下", 0.5) -- 2474
		end -- 2474
	elseif self.knockT > 0 then -- 2474
		self.knockT = self.knockT - dt -- 2477
		if self.knockT <= 0 then -- 2477
			self.knocks = 0 -- 2479
		end -- 2479
	end -- 2479
	local i = 0 -- 2484
	do -- 2484
		i = 0 -- 2485
		while i < #self.room.marks do -- 2485
			do -- 2485
				local m = self.room.marks[i + 1] -- 2486
				if m.kind ~= 0 then -- 2486
					goto __continue431 -- 2488
				end -- 2488
				local subjects = {self.partner, self.player} -- 2490
				local k = 0 -- 2491
				do -- 2491
					k = 0 -- 2492
					while k < #subjects do -- 2492
						do -- 2492
							local s = subjects[k + 1] -- 2493
							if not s.alive then -- 2493
								goto __continue434 -- 2495
							end -- 2495
							local dx = s.x - m.x -- 2497
							local dy = s.y - m.y -- 2498
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2498
								self.checkpoint = m.x -- 2500
								self.checkpointCartAxle = self.cartAxle -- 2501
								if self.cartDocked then -- 2501
									self:flashSet("检查点 · 车已落窝", 1) -- 2503
								else -- 2503
									self:flashSet("检查点 · 车还没到位", 1) -- 2505
								end -- 2505
							end -- 2505
						end -- 2505
						::__continue434:: -- 2505
						k = k + 1 -- 2492
					end -- 2492
				end -- 2492
			end -- 2492
			::__continue431:: -- 2492
			i = i + 1 -- 2485
		end -- 2485
	end -- 2485
	self:checkCarryGate() -- 2511
end -- 2440
function Play.prototype.stepVillage(self, dt, input) -- 2515
	if self.room.key ~= "village" then -- 2515
		return -- 2517
	end -- 2517
	local p = self.player -- 2519
	local bottle = self.room.bottle -- 2520
	local scav = self.room.scavenger -- 2521
	if not self.hasBottle and bottle ~= nil then -- 2521
		local dx = p.x - bottle.x -- 2525
		local dy = p.y + p.h * 0.5 - bottle.y -- 2526
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2526
			self.hasBottle = true -- 2528
			self:flashSet("拾起瓶子", 0.8) -- 2529
		end -- 2529
	end -- 2529
	if self.hasBottle then -- 2529
		if input.aim.held then -- 2529
			self.aimHold = self.aimHold + dt -- 2536
			if self.aimHold > 1.2 then -- 2536
				self.aimHold = 1.2 -- 2538
			end -- 2538
			local cached = self:bottleEnd() -- 2541
			self.bottleAimX = cached.x -- 2542
			self.bottleAimY = cached.y -- 2543
		elseif input.aim.released then -- 2543
			if self.aimHold < 0.12 then -- 2543
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2547
				self.aimHold = 0 -- 2548
			else -- 2548
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2550
				self:throwBottle(____end.x, ____end.y) -- 2551
				self.aimHold = 0 -- 2552
			end -- 2552
		end -- 2552
	else -- 2552
		self.aimHold = 0 -- 2556
		self.bottleAimX = -1 -- 2557
	end -- 2557
	local fly = self.bottleFly -- 2562
	if fly ~= nil then -- 2562
		fly.t = fly.t + dt -- 2564
		fly.x = fly.x0 + fly.vx * fly.t -- 2565
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2566
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2567
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2567
			self:landBottle(fly) -- 2569
		end -- 2569
	end -- 2569
	if self.bottleLandT > 0 then -- 2569
		self.bottleLandT = self.bottleLandT - dt -- 2573
	end -- 2573
	if scav ~= nil then -- 2573
		self:stepScav(dt, scav) -- 2577
	end -- 2577
	local line = self.room.passLine -- 2580
	if line ~= nil and not self.passed and p.x >= line then -- 2580
		self.passed = true -- 2582
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2583
	end -- 2583
	if self.passed and p.x >= self.ox + 640 then -- 2583
		self:requestRoom("forest", "过第一院出院") -- 2587
		self:flashSet("出院 · 北塔森林", 1.4) -- 2588
	end -- 2588
end -- 2515
function Play.prototype.bottleEnd(self) -- 2593
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2594
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2597
	return {x = aim.x, y = g} -- 2598
end -- 2593
function Play.prototype.throwBottle(self, tx, ty) -- 2602
	local p = self.player -- 2603
	local dir = tx >= p.x and 1 or -1 -- 2605
	p.facing = dir -- 2606
	local x0 = p.x + dir * 10 -- 2607
	local y0 = p.y + p.h * 0.7 -- 2608
	self.bottleTargetX = tx -- 2609
	self.bottleTargetY = ty -- 2610
	self.bottleSurfaceY = ty -- 2611
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2612
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2613
	self.bottleFly = { -- 2614
		x = x0, -- 2614
		y = y0, -- 2614
		x0 = x0, -- 2614
		y0 = y0, -- 2614
		vx = vx, -- 2614
		vy = vy, -- 2614
		t = 0 -- 2614
	} -- 2614
	self.hasBottle = false -- 2615
	self:flashSet("投出", 0.4) -- 2616
	self:emit( -- 2617
		"bottleThrown", -- 2617
		{ -- 2617
			fromX = x0, -- 2618
			fromY = y0, -- 2619
			targetX = tx, -- 2620
			targetY = ty, -- 2621
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2622
		} -- 2622
	) -- 2622
end -- 2602
function Play.prototype.landBottle(self, fly) -- 2627
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2628
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2629
	local s = self.room.scavenger -- 2630
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2631
	self.bottleFly = nil -- 2632
	self.bottleTargetX = -1 -- 2633
	self.bottleTargetY = 0 -- 2634
	self.bottleSurfaceY = -1 -- 2635
	self.bottleLandX = x -- 2636
	self.bottleLandY = y -- 2637
	self.bottleLandT = 0.9 -- 2638
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2639
	self:hearBottle(x) -- 2640
end -- 2627
function Play.prototype.hearBottle(self, x) -- 2644
	local s = self.room.scavenger -- 2645
	if s == nil then -- 2645
		return -- 2647
	end -- 2647
	if math.abs(x - self.scavX) > s.range then -- 2647
		self:flashSet("落地 · 他没听见", 0.6) -- 2650
		return -- 2651
	end -- 2651
	self.scavState = "turn" -- 2653
	self.scavT = s.hearTicks -- 2654
	self.scavTargetX = x -- 2655
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2656
end -- 2644
function Play.prototype.stepScav(self, dt, s) -- 2660
	if self.scavState == "chase" then -- 2660
		return -- 2663
	end -- 2663
	if self.scavState == "turn" then -- 2663
		self.scavT = self.scavT - 1 -- 2666
		if self.scavT <= 0 then -- 2666
			self.scavState = "walk" -- 2668
		end -- 2668
		return -- 2670
	end -- 2670
	if self.scavState == "walk" then -- 2670
		local d = self.scavTargetX - self.scavX -- 2673
		if math.abs(d) < 4 then -- 2673
			self.scavState = "stall" -- 2675
			self.scavT = s.stallTicks -- 2676
			return -- 2677
		end -- 2677
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2679
		return -- 2680
	end -- 2680
	if self.scavState == "stall" then -- 2680
		self.scavT = self.scavT - 1 -- 2683
		if self.scavT <= 0 then -- 2683
			self.scavState = "back" -- 2685
		end -- 2685
		return -- 2687
	end -- 2687
	if self.scavState == "back" then -- 2687
		local home = math.max( -- 2690
			s.x0, -- 2690
			math.min(s.x1, self.scavX) -- 2690
		) -- 2690
		if math.abs(home - self.scavX) < 2 then -- 2690
			self.scavState = "patrol" -- 2692
			return -- 2693
		end -- 2693
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2695
		return -- 2696
	end -- 2696
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2698
	if self.scavX >= s.x1 then -- 2698
		self.scavX = s.x1 -- 2700
		self.scavDir = -1 -- 2701
	elseif self.scavX <= s.x0 then -- 2701
		self.scavX = s.x0 -- 2703
		self.scavDir = 1 -- 2704
	end -- 2704
end -- 2660
function Play.prototype.stepCart(self, dt, input) -- 2712
	local p = self.player -- 2713
	local c = self.room.cart -- 2714
	if self.gripping then -- 2714
		if not input.interact.held then -- 2714
			self.gripping = false -- 2718
			self:flashSet("松开车把", 0.4) -- 2719
			return -- 2720
		end -- 2720
	else -- 2720
		if not input.interact.pressed then -- 2720
			return -- 2724
		end -- 2724
		if not self:cartHandleInReach(p) then -- 2724
			return -- 2727
		end -- 2727
		local track = c.depth or 0 -- 2729
		if self:limitDepth(p, track) ~= track then -- 2729
			return -- 2731
		end -- 2731
		p.depth = track -- 2733
		p.depthSpeed = 0 -- 2734
		self.gripping = true -- 2735
		self:flashSet("握住车把", 0.4) -- 2736
		return -- 2737
	end -- 2737
	if self.cartDocked then -- 2737
		return -- 2741
	end -- 2741
	local dir = input.moveX -- 2743
	if dir == 0 then -- 2743
		return -- 2745
	end -- 2745
	local lo = math.min(c.startX, c.endX) -- 2747
	local hi = math.max(c.startX, c.endX) -- 2748
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2749
	if next < lo then -- 2749
		next = lo -- 2751
	end -- 2751
	if next > hi then -- 2751
		next = hi -- 2754
	end -- 2754
	local delta = next - self.cartAxle -- 2756
	if delta == 0 then -- 2756
		return -- 2758
	end -- 2758
	self.cartAxle = next -- 2760
	p.x = p.x + delta -- 2761
	p.facing = dir > 0 and 1 or -1 -- 2762
	self:slideX(p, 0) -- 2763
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 2763
		self.gripping = false -- 2765
		self:flashSet("跟不上了，脱手", 0.6) -- 2766
		return -- 2767
	end -- 2767
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 2767
		self.cartDocked = true -- 2770
		self.gripping = false -- 2771
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 2772
		self:flashSet("车轮落窝", 1.2) -- 2773
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 2773
		self:flashSet("车轮回到起点", 0.5) -- 2775
	end -- 2775
end -- 2712
function Play.prototype.requestRoom(self, key, reason) -- 2783
	if self.wantRoom ~= "" then -- 2783
		return -- 2787
	end -- 2787
	self.wantRoom = key -- 2789
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 2790
end -- 2783
function Play.prototype.checkCarryGate(self) -- 2797
	if self.room.key == "checkpoint" then -- 2797
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 2797
			self.carryCartAxle = self.cartAxle -- 2800
			self.carryCartDocked = self.cartDocked -- 2801
			self:requestRoom("gate", "检查站出口") -- 2802
			self:flashSet("出检查站 · 城门", 1.2) -- 2803
		end -- 2803
		return -- 2805
	end -- 2805
	if self.room.key == "outside" then -- 2805
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 2805
			self.carryCartAxle = self.cartAxle -- 2811
			self.carryCartDocked = self.cartDocked -- 2812
			self:requestRoom("village", "墙根走完") -- 2813
			self:flashSet("墙根走完 · 进村口", 1.2) -- 2814
		end -- 2814
	end -- 2814
end -- 2797
function Play.prototype.aimAt(self, wx, wy) -- 2821
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 2822
	self.aimX = s.x -- 2823
	self.aimY = s.y -- 2824
end -- 2821
function Play.prototype.shoot(self, a) -- 2827
	if self.isCampaign and self.reloadT > 0 then -- 2827
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 2829
		return -- 2830
	end -- 2830
	local ox = a.x + a.facing * 8 -- 2832
	local muzzleY = a.y + a.h * 0.72 -- 2833
	local oy = muzzleY + a.depth -- 2834
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2836
	local dx = aim.x - ox -- 2839
	local dy = aim.y - oy -- 2840
	local len = math.sqrt(dx * dx + dy * dy) -- 2841
	if len < 0.001 then -- 2841
		dx = a.facing -- 2843
		dy = 0 -- 2844
	else -- 2844
		dx = dx / len -- 2846
		dy = dy / len -- 2847
	end -- 2847
	if dx ~= 0 then -- 2847
		a.facing = dx > 0 and 1 or -1 -- 2850
	end -- 2850
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 2853
	local hitEnemy = self:raycastEnemies(ray) -- 2854
	local tEnemy = hitEnemy.t -- 2855
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 2856
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 2857
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 2858
	local tWall = solid.t -- 2859
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 2860
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 2861
	self.trace = { -- 2863
		x0 = ox, -- 2863
		y0 = oy, -- 2863
		x1 = ox + dx * t, -- 2863
		y1 = oy + dy * t, -- 2863
		hit = hit -- 2863
	} -- 2863
	self.traceT = 0.12 -- 2864
	self:applyFireDanger(ox) -- 2865
	local killed = false -- 2866
	if hit then -- 2866
		local i = hitEnemy.index -- 2868
		local e = self.enemies[i + 1] -- 2869
		local impactY = oy + dy * tEnemy -- 2870
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 2871
		local shieldTop = e.y + (e.depth or 0) + 64 -- 2872
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 2872
			e.shieldHp = (e.shieldHp or 0) - 1 -- 2874
			e.hitT = 0.3 -- 2875
			self:flashSet( -- 2876
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 2876
				0.8 -- 2876
			) -- 2876
			self:emit("shotResolved", { -- 2877
				hit = true, -- 2878
				enemyIndex = i, -- 2878
				enemyX = e.x, -- 2878
				aimX = aim.x, -- 2878
				aimY = aim.y, -- 2878
				impactX = ox + dx * t, -- 2879
				impactY = oy + dy * t, -- 2879
				shield = true -- 2879
			}) -- 2879
			self.reloadT = self:reloadTicks() -- 2881
			return -- 2882
		end -- 2882
		e.alive = false -- 2884
		e.hitT = 0.4 -- 2885
		killed = true -- 2886
		self:flashSet("命中", 0.6) -- 2887
		self:dropFor(e) -- 2888
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 2888
		self:damageProp(solid.box, 1) -- 2890
	else -- 2890
		self:flashSet("打空", 0.35) -- 2892
	end -- 2892
	if self.isCampaign then -- 2892
		self.reloadT = self:reloadTicks() -- 2895
	end -- 2895
	self:emit("shotResolved", { -- 2897
		hit = hit, -- 2898
		enemyIndex = hit and hitEnemy.index or -1, -- 2899
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 2900
		aimX = aim.x, -- 2901
		aimY = aim.y, -- 2902
		impactX = ox + dx * t, -- 2903
		impactY = oy + dy * t -- 2904
	}) -- 2904
end -- 2827
function Play.prototype.applyFireDanger(self, shotX) -- 2909
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 2909
		return -- 2911
	end -- 2911
	local dangerX = shotX -- 2913
	local best = -1 -- 2914
	local bestD = 1000000000 -- 2915
	local i = 0 -- 2916
	do -- 2916
		i = 0 -- 2917
		while i < #self.enemies do -- 2917
			do -- 2917
				local e = self.enemies[i + 1] -- 2918
				if not e.alive then -- 2918
					goto __continue510 -- 2920
				end -- 2920
				local d = math.abs(e.x - self.partner.x) -- 2922
				if d < bestD then -- 2922
					bestD = d -- 2924
					best = i -- 2925
				end -- 2925
			end -- 2925
			::__continue510:: -- 2925
			i = i + 1 -- 2917
		end -- 2917
	end -- 2917
	if best >= 0 then -- 2917
		dangerX = self.enemies[best + 1].x -- 2929
	end -- 2929
	local exposed = self:childExposed(dangerX) -- 2931
	local before = self.escort.fear -- 2932
	local dangerId = self.nextDangerId -- 2933
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 2934
	self.nextDangerId = self.nextDangerId + 1 -- 2935
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 2936
	if after > before then -- 2936
		self:flashSet( -- 2938
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 2938
			1 -- 2938
		) -- 2938
	elseif not exposed then -- 2938
		self:flashSet("枪声没够到她", 0.5) -- 2940
	end -- 2940
end -- 2909
function Play.prototype.childExposed(self, dangerX) -- 2945
	local c = self.partner -- 2946
	if not c.alive then -- 2946
		return false -- 2948
	end -- 2948
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 2948
		self.boxes, -- 2951
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 2951
	) then -- 2951
		return false -- 2952
	end -- 2952
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 2952
		return false -- 2955
	end -- 2955
	local toDanger = dangerX - c.x -- 2957
	local toPlayer = self.player.x - c.x -- 2958
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 2958
		return false -- 2961
	end -- 2961
	return true -- 2963
end -- 2945
function Play.prototype.raycastEnemies(self, ray) -- 2967
	local best = -1 -- 2968
	local bestI = -1 -- 2969
	do -- 2969
		local i = 0 -- 2970
		while i < #self.enemies do -- 2970
			do -- 2970
				local e = self.enemies[i + 1] -- 2971
				if not e.alive then -- 2971
					goto __continue524 -- 2973
				end -- 2973
				local y = e.y + (e.depth or 0) -- 2975
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 2976
				if t >= 0 and (best < 0 or t < best) then -- 2976
					best = t -- 2978
					bestI = i -- 2979
				end -- 2979
			end -- 2979
			::__continue524:: -- 2979
			i = i + 1 -- 2970
		end -- 2970
	end -- 2970
	return {t = best, index = bestI} -- 2982
end -- 2967
function Play.prototype.raycastWorld(self, ray) -- 2985
	return self:raycastSolid(ray).t -- 2986
end -- 2985
function Play.prototype.raycastSolid(self, ray) -- 2990
	local best = -1 -- 2991
	local bestBox = nil -- 2992
	for ____, box in ipairs(self.boxes) do -- 2993
		do -- 2993
			if box.broken == true or box.hidden == true then -- 2993
				goto __continue529 -- 2995
			end -- 2995
			local t = hitBox(ray, box) -- 3000
			if t > 2 and (best < 0 or t < best) then -- 3000
				best = t -- 3003
				bestBox = box -- 3004
			end -- 3004
		end -- 3004
		::__continue529:: -- 3004
	end -- 3004
	if ray.dy < 0 then -- 3004
		local t = -ray.y / ray.dy -- 3008
		if t >= 0 and (best < 0 or t < best) then -- 3008
			best = t -- 3010
			bestBox = nil -- 3011
		end -- 3011
	end -- 3011
	return {t = best, box = bestBox} -- 3014
end -- 2990
function Play.prototype.dropFor(self, e) -- 3018
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 3018
		return -- 3020
	end -- 3020
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 3020
		return -- 3023
	end -- 3023
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 3025
	local ____self_pickups_54 = self.pickups -- 3025
	____self_pickups_54[#____self_pickups_54 + 1] = { -- 3026
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 3027
		kind = e.drop, -- 3027
		x = e.x, -- 3027
		y = e.y, -- 3027
		depth = e.depth, -- 3028
		label = label .. " ×1" -- 3028
	} -- 3028
	self:log("掉落 " .. label) -- 3030
end -- 3018
function Play.prototype.damageProp(self, b, amount) -- 3034
	if b.breakable == nil or b.broken == true then -- 3034
		return -- 3036
	end -- 3036
	local ____b_breakable_55, ____hp_56 = b.breakable, "hp" -- 3036
	____b_breakable_55[____hp_56] = ____b_breakable_55[____hp_56] - amount -- 3038
	if b.breakable.hp > 0 then -- 3038
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3040
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3041
		return -- 3042
	end -- 3042
	b.broken = true -- 3044
	for ____, other in ipairs(self.boxes) do -- 3045
		if other.id ~= nil and other.id == b.id then -- 3045
			other.broken = true -- 3047
		end -- 3047
	end -- 3047
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3050
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3051
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3052
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3053
end -- 3034
function Play.prototype.slideDepth(self, a, distance) -- 3057
	a.depth = self:limitDepth(a, a.depth + distance) -- 3058
end -- 3057
function Play.prototype.limitDepth(self, a, target) -- 3061
	local road = self.room.depth -- 3062
	if road == nil or target == a.depth then -- 3062
		return a.depth -- 3064
	end -- 3064
	local next = math.max( -- 3066
		road.min, -- 3066
		math.min(road.max, target) -- 3066
	) -- 3066
	local half = a.w / 2 -- 3067
	for ____, b in ipairs(self.boxes) do -- 3068
		do -- 3068
			local footprint = b.depth -- 3069
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3069
				goto __continue547 -- 3074
			end -- 3074
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3076
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3077
			if a.depth <= front and next > front then -- 3077
				next = front -- 3079
			elseif a.depth >= back and next < back then -- 3079
				next = back -- 3081
			end -- 3081
		end -- 3081
		::__continue547:: -- 3081
	end -- 3081
	return next -- 3084
end -- 3061
function Play.prototype.slideX(self, a, dx) -- 3088
	local nx = a.x + dx -- 3089
	local half = a.w / 2 -- 3090
	local room = self.room -- 3091
	nx = math.max( -- 3092
		room.minX + half, -- 3092
		math.min(room.maxX - half, nx) -- 3092
	) -- 3092
	local i = 0 -- 3093
	do -- 3093
		i = 0 -- 3094
		while i < #self.boxes do -- 3094
			do -- 3094
				local b = self.boxes[i + 1] -- 3095
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3095
					goto __continue554 -- 3097
				end -- 3097
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3097
					goto __continue554 -- 3100
				end -- 3100
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3100
					goto __continue554 -- 3103
				end -- 3103
				if nx + half > b.x0 and nx - half < b.x1 then -- 3103
					if a.x <= b.x0 then -- 3103
						nx = b.x0 - half -- 3107
					elseif a.x >= b.x1 then -- 3107
						nx = b.x1 + half -- 3109
					else -- 3109
						nx = a.x -- 3111
					end -- 3111
				end -- 3111
			end -- 3111
			::__continue554:: -- 3111
			i = i + 1 -- 3094
		end -- 3094
	end -- 3094
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 3094
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 3119
		local bx0 = self.cartAxle - CART_HALF -- 3120
		local bx1 = self.cartAxle + CART_HALF -- 3121
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 3121
			if a.x <= bx0 then -- 3121
				nx = bx0 - half -- 3124
			elseif a.x >= bx1 then -- 3124
				nx = bx1 + half -- 3126
			else -- 3126
				nx = a.x -- 3128
			end -- 3128
		end -- 3128
	end -- 3128
	local arch = room.arch -- 3136
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 3136
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 3138
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 3138
			if a.x <= arch.x0 then -- 3138
				nx = arch.x0 - half -- 3141
			elseif a.x >= arch.x1 then -- 3141
				nx = arch.x1 + half -- 3143
			end -- 3143
		end -- 3143
	end -- 3143
	a.x = nx -- 3147
end -- 3088
function Play.prototype.fallY(self, a, dt) -- 3151
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3152
	if a.vy < -900 then -- 3152
		a.vy = -900 -- 3154
	end -- 3154
	local ny = a.y + a.vy * dt -- 3156
	local half = a.w / 2 -- 3157
	if a.vy <= 0 then -- 3157
		local reach = a.onGround and STEP_UP or 0 -- 3160
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3161
		if ny <= ground then -- 3161
			ny = ground -- 3163
			a.vy = 0 -- 3164
			a.onGround = true -- 3165
		else -- 3165
			a.onGround = false -- 3167
		end -- 3167
	else -- 3167
		a.onGround = false -- 3170
		local i = 0 -- 3171
		do -- 3171
			i = 0 -- 3172
			while i < #self.boxes do -- 3172
				do -- 3172
					local b = self.boxes[i + 1] -- 3173
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3173
						goto __continue578 -- 3175
					end -- 3175
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3175
						goto __continue578 -- 3178
					end -- 3178
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3178
						goto __continue578 -- 3181
					end -- 3181
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3181
						ny = b.y0 - a.h -- 3184
						a.vy = 0 -- 3185
					end -- 3185
				end -- 3185
				::__continue578:: -- 3185
				i = i + 1 -- 3172
			end -- 3172
		end -- 3172
	end -- 3172
	a.y = ny -- 3189
end -- 3151
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3193
	if depth == nil then -- 3193
		depth = 0 -- 3193
	end -- 3193
	local g = -9999 -- 3194
	local i = 0 -- 3195
	do -- 3195
		i = 0 -- 3196
		while i < #self.floors do -- 3196
			local f = self.floors[i + 1] -- 3197
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3197
				g = f.y1 -- 3199
			end -- 3199
			i = i + 1 -- 3196
		end -- 3196
	end -- 3196
	do -- 3196
		i = 0 -- 3202
		while i < #self.boxes do -- 3202
			do -- 3202
				local b = self.boxes[i + 1] -- 3203
				if b.broken == true or b.hidden == true or b.soft == true then -- 3203
					goto __continue588 -- 3205
				end -- 3205
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3205
					g = b.y1 -- 3209
				end -- 3209
			end -- 3209
			::__continue588:: -- 3209
			i = i + 1 -- 3202
		end -- 3202
	end -- 3202
	return g -- 3212
end -- 3193
function Play.prototype.updateCamera(self, dt) -- 3215
	local p = self.player -- 3216
	local tx = p.x + p.facing * 30 -- 3217
	local ty = p.y + CAM_LOOK_UP -- 3218
	local k = math.min(1, CAM_FOLLOW * dt) -- 3219
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3220
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3221
end -- 3215
function Play.prototype.clampCamera(self, w, h) -- 3225
	local room = self.room -- 3226
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3227
	local spanX = room.maxX - room.minX -- 3228
	if spanX <= halfW * 2 then -- 3228
		self.cam.x = (room.minX + room.maxX) / 2 -- 3230
	else -- 3230
		self.cam.x = math.max( -- 3232
			room.minX + halfW, -- 3232
			math.min(room.maxX - halfW, self.cam.x) -- 3232
		) -- 3232
	end -- 3232
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3235
	local spanY = room.height -- 3236
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3237
	if spanY <= halfH * 2 then -- 3237
		self.cam.y = camY -- 3239
	else -- 3239
		self.cam.y = math.max( -- 3241
			camY, -- 3241
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3241
		) -- 3241
	end -- 3241
end -- 3225
function Play.prototype.flashSet(self, text, t) -- 3245
	self.flash = text -- 3246
	self.flashT = t -- 3247
end -- 3245
function Play.prototype.statusText(self) -- 3251
	local p = self.player -- 3252
	local parts = {} -- 3253
	local who = self.childMode and "小满" or "周戍" -- 3254
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3255
	if self.room.key == "prologue" then -- 3255
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3258
		if self.phase == "prologue-wait" then -- 3258
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3260
		elseif self.phase == "prologue-give" then -- 3260
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3262
		else -- 3262
			parts[#parts + 1] = "跟随" -- 3264
		end -- 3264
		if self.paused then -- 3264
			parts[#parts + 1] = "已暂停" -- 3267
		end -- 3267
		return table.concat(parts, " · ") -- 3269
	end -- 3269
	if self.room.key == "street" then -- 3269
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3272
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3273
		if self.paused then -- 3273
			parts[#parts + 1] = "已暂停" -- 3275
		end -- 3275
		return table.concat(parts, " · ") -- 3277
	end -- 3277
	if self.room.key == "gate" then -- 3277
		local ____temp_57 -- 3280
		if self.room.story == nil then -- 3280
			____temp_57 = nil -- 3280
		else -- 3280
			____temp_57 = self.room.story.gate -- 3280
		end -- 3280
		local g = ____temp_57 -- 3280
		if g ~= nil then -- 3280
			parts[#parts + 1] = self:gateLabel() -- 3282
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3283
				0, -- 3284
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3284
			))) .. " 秒" -- 3284
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3285
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3286
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3287
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3288
			if self.gateFailCount > 0 then -- 3288
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3290
			end -- 3290
			if self.flash ~= "" then -- 3290
				parts[#parts + 1] = self.flash -- 3293
			end -- 3293
		end -- 3293
		if self.paused then -- 3293
			parts[#parts + 1] = "已暂停" -- 3297
		end -- 3297
		return table.concat(parts, " · ") -- 3299
	end -- 3299
	if self.room.key == "forest" then -- 3299
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3302
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3303
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3304
		if self.caughtT > 0 then -- 3304
			parts[#parts + 1] = "复位中" -- 3306
		end -- 3306
		if self.paused then -- 3306
			parts[#parts + 1] = "已暂停" -- 3309
		end -- 3309
		return table.concat(parts, " · ") -- 3311
	end -- 3311
	if self.room.key == "tower" then -- 3311
		if self.phase == "tower-wait" then -- 3311
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3315
		elseif self.phase == "tower-knock" then -- 3315
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3317
		elseif self.phase == "tower-given" then -- 3317
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3319
		else -- 3319
			parts[#parts + 1] = "片尾" -- 3321
		end -- 3321
		if self.paused then -- 3321
			parts[#parts + 1] = "已暂停" -- 3324
		end -- 3324
		return table.concat(parts, " · ") -- 3326
	end -- 3326
	if self.room.key == "village" then -- 3326
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3329
		if self.hasBottle then -- 3329
			parts[#parts + 1] = "有瓶" -- 3331
		elseif self.bottleFly ~= nil then -- 3331
			parts[#parts + 1] = "瓶在飞" -- 3333
		else -- 3333
			parts[#parts + 1] = "空手" -- 3335
		end -- 3335
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3337
		if self.scavChase then -- 3337
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3339
		end -- 3339
		if self.passed then -- 3339
			parts[#parts + 1] = "已过通行线" -- 3342
		end -- 3342
		if self.paused then -- 3342
			parts[#parts + 1] = "已暂停" -- 3345
		end -- 3345
		return table.concat(parts, " · ") -- 3347
	end -- 3347
	local isChild = self.childMode -- 3350
	if isChild then -- 3350
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3352
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3353
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3354
	else -- 3354
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3356
		if p.rollT > 0 then -- 3356
			parts[#parts + 1] = "翻滚中" -- 3358
		end -- 3358
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3360
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3361
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3362
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3363
	end -- 3363
	if self.checkpoint >= 0 then -- 3363
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3366
	end -- 3366
	if self.paused then -- 3366
		parts[#parts + 1] = "已暂停" -- 3369
	end -- 3369
	return table.concat(parts, " · ") -- 3371
end -- 3251
function Play.prototype.aliveEnemies(self) -- 3375
	local n = 0 -- 3376
	local i = 0 -- 3377
	do -- 3377
		i = 0 -- 3378
		while i < #self.enemies do -- 3378
			if self.enemies[i + 1].alive then -- 3378
				n = n + 1 -- 3380
			end -- 3380
			i = i + 1 -- 3378
		end -- 3378
	end -- 3378
	return n -- 3383
end -- 3375
function Play.prototype.threatened(self) -- 3388
	do -- 3388
		local i = 0 -- 3389
		while i < #self.enemies do -- 3389
			local e = self.enemies[i + 1] -- 3390
			if e.alive and e.warnT > 0 then -- 3390
				return true -- 3392
			end -- 3392
			i = i + 1 -- 3389
		end -- 3389
	end -- 3389
	return false -- 3395
end -- 3388
function Play.prototype.gateSecondsLeft(self) -- 3398
	local ____temp_58 -- 3399
	if self.room.story == nil then -- 3399
		____temp_58 = nil -- 3399
	else -- 3399
		____temp_58 = self.room.story.gate -- 3399
	end -- 3399
	local g = ____temp_58 -- 3399
	if g == nil then -- 3399
		return 0 -- 3401
	end -- 3401
	return math.max( -- 3403
		0, -- 3403
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3403
	) -- 3403
end -- 3398
function Play.prototype.gateLabel(self) -- 3406
	if self.phase == "gate-idle" then -- 3406
		return "待就位" -- 3408
	end -- 3408
	if self.phase == "gate-hold" then -- 3408
		return "守点中" -- 3411
	end -- 3411
	if self.phase == "gate-send" then -- 3411
		return "送别" -- 3414
	end -- 3414
	if self.phase == "gate-count" then -- 3414
		return "数数 " .. tostring(self.countTick) -- 3417
	end -- 3417
	return "她走" -- 3419
end -- 3406
function Play.prototype.dogLabel(self) -- 3423
	if self.dogState == "ear" then -- 3423
		return "转耳" -- 3425
	end -- 3425
	if self.dogState == "chase" then -- 3425
		return "追" -- 3428
	end -- 3428
	if self.dogState == "sniff" then -- 3428
		return "停" -- 3431
	end -- 3431
	if self.dogState == "back" then -- 3431
		return "回线" -- 3434
	end -- 3434
	return "巡逻" -- 3436
end -- 3423
function Play.prototype.doorXOf(self) -- 3439
	local ____temp_59 -- 3440
	if self.room.story == nil then -- 3440
		____temp_59 = nil -- 3440
	else -- 3440
		____temp_59 = self.room.story.tower -- 3440
	end -- 3440
	local t = ____temp_59 -- 3440
	return t == nil and 0 or t.doorX -- 3441
end -- 3439
function Play.prototype.scavLabel(self) -- 3445
	if self.scavState == "chase" then -- 3445
		return "追" -- 3447
	end -- 3447
	if self.scavState == "turn" then -- 3447
		return "转头" -- 3450
	end -- 3450
	if self.scavState == "walk" then -- 3450
		return "赶来" -- 3453
	end -- 3453
	if self.scavState == "stall" then -- 3453
		return "停住" -- 3456
	end -- 3456
	if self.scavState == "back" then -- 3456
		return "回位" -- 3459
	end -- 3459
	return "巡逻" -- 3461
end -- 3445
function Play.prototype.hintText(self) -- 3465
	if self.paused then -- 3465
		return "Esc 继续 · R 重置" -- 3467
	end -- 3467
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3467
		if self:threatened() then -- 3467
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3473
		end -- 3473
		if self.coverHug then -- 3473
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3476
		end -- 3476
		if self.coverNear then -- 3476
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3479
		end -- 3479
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3481
	end -- 3481
	if self.flash ~= "" then -- 3481
		return self.flash -- 3484
	end -- 3484
	if self.room.key == "prologue" then -- 3484
		if self.phase == "prologue-wait" then -- 3484
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3488
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3489
		end -- 3489
		if self.phase == "prologue-give" then -- 3489
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3492
		end -- 3492
		return "她跟着你了 · 两人一起走到门口 680" -- 3494
	end -- 3494
	if self.room.key == "street" then -- 3494
		if self:aliveEnemies() > 0 then -- 3494
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3498
		end -- 3498
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3500
	end -- 3500
	if self.room.key == "gate" then -- 3500
		local ____temp_60 -- 3503
		if self.room.story == nil then -- 3503
			____temp_60 = nil -- 3503
		else -- 3503
			____temp_60 = self.room.story.gate -- 3503
		end -- 3503
		local g = ____temp_60 -- 3503
		if g ~= nil then -- 3503
			if self.phase == "gate-idle" then -- 3503
				if self.gateNeedConfirm then -- 3503
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3507
				end -- 3507
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3509
			end -- 3509
			if self.phase == "gate-hold" then -- 3509
				if self.coveredFlash > 0 then -- 3509
					return "掩体挡下了这一枪 · 别露头" -- 3513
				end -- 3513
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3515
			end -- 3515
			if self.phase == "gate-send" then -- 3515
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3518
			end -- 3518
			if self.phase == "gate-count" then -- 3518
				if self.countTick >= 1440 then -- 3518
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3522
				end -- 3522
				return ("数到一百 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3524
			end -- 3524
			return "她自己走 · 跟着出城门 1120" -- 3526
		end -- 3526
	end -- 3526
	if self.room.key == "forest" then -- 3526
		if self.dogState == "chase" then -- 3526
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3531
		end -- 3531
		if self.dogState == "ear" then -- 3531
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3534
		end -- 3534
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3536
	end -- 3536
	if self.room.key == "tower" then -- 3536
		if self.phase == "tower-wait" then -- 3536
			return "走到门前 445 点一次 E 敲两下" -- 3540
		end -- 3540
		if self.phase == "tower-knock" then -- 3540
			return "敲两下 · 等门开" -- 3543
		end -- 3543
		if self.phase == "tower-given" then -- 3543
			return "递交针套和纸条 · 看登记簿最后一行" -- 3546
		end -- 3546
		return "片尾 · 点 E 再玩一次，回到序章" -- 3548
	end -- 3548
	if self.room.key == "village" then -- 3548
		if self.bottleFly ~= nil then -- 3548
			return "等瓶子落地 · 触地才发声" -- 3552
		end -- 3552
		if self.hasBottle then -- 3552
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3555
		end -- 3555
		if self.passed then -- 3555
			return "已过第一院 · R 重置可再来一遍" -- 3558
		end -- 3558
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3560
	end -- 3560
	if self.room.key == "outside" then -- 3560
		if self.focusCart then -- 3560
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3564
		end -- 3564
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3566
	end -- 3566
	if self.escort.state == "frozen" then -- 3566
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3566
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3570
		end -- 3570
		return "小满吓住了 · 走过去，靠近再点 E" -- 3572
	end -- 3572
	if self.escort.state == "calming" then -- 3572
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3575
	end -- 3575
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3577
end -- 3465
function Play.prototype.draw(self, draw, w, h) -- 3582
	self.viewW = w -- 3583
	self.viewH = h -- 3584
	self.view = ____exports.computeViewport(w, h) -- 3585
	self:clampCamera(w, h) -- 3586
	draw:clear() -- 3587
	draw:drawRect( -- 3589
		Rect(0, 0, w, h), -- 3589
		BG_VOID -- 3589
	) -- 3589
	local box = self:canvasRect(w, h) -- 3590
	draw:drawRect(box, BG_FAR) -- 3591
	draw:drawRect( -- 3592
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3592
		BG_MID -- 3592
	) -- 3592
	self:drawFloors(draw, w, h) -- 3594
	self:drawSolids(draw, w, h) -- 3595
	self:drawZones(draw, w, h) -- 3596
	self:drawArch(draw, w, h) -- 3597
	self:drawCart(draw, w, h) -- 3598
	self:drawCampaignProps(draw, w, h) -- 3599
	self:drawActors(draw, w, h) -- 3600
	self:drawTrace(draw, w, h) -- 3601
	self:drawAim(draw, w, h) -- 3602
end -- 3582
function Play.prototype.canvasRect(self, w, h) -- 3606
	local v = self.view -- 3607
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3608
end -- 3606
function Play.prototype.px(self, n) -- 3612
	return n * self.view.zoom -- 3613
end -- 3612
function Play.prototype.sx(self, wx, w) -- 3617
	local v = self.view -- 3618
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3619
	return v.ox + lx * v.zoom -- 3620
end -- 3617
function Play.prototype.sy(self, wy, h) -- 3624
	local v = self.view -- 3625
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3626
	return v.oy + ly * v.zoom -- 3627
end -- 3624
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3630
	local px0 = self:sx(x0, w) -- 3631
	local px1 = self:sx(x1, w) -- 3632
	local py0 = self:sy(y0, h) -- 3633
	local py1 = self:sy(y1, h) -- 3634
	if px1 <= px0 or py1 <= py0 then -- 3634
		return -- 3636
	end -- 3636
	draw:drawRect( -- 3638
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3638
		color -- 3638
	) -- 3638
end -- 3630
function Play.prototype.drawFloors(self, draw, w, h) -- 3641
	local i = 0 -- 3642
	do -- 3642
		i = 0 -- 3643
		while i < #self.room.floors do -- 3643
			local f = self.room.floors[i + 1] -- 3644
			local ____temp_61 -- 3645
			if f.y == 0 then -- 3645
				____temp_61 = self.room.depth -- 3645
			else -- 3645
				____temp_61 = nil -- 3645
			end -- 3645
			local road = ____temp_61 -- 3645
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3646
			local x0 = self:sx(f.x0, w) -- 3647
			local x1 = self:sx(f.x1, w) -- 3648
			local deck = self:px(5) -- 3649
			if road ~= nil then -- 3649
				local back = self:sy(f.y + road.max, h) -- 3651
				draw:drawRect( -- 3652
					Rect(x0, y, x1 - x0, back - y), -- 3652
					FLOOR_DECK, -- 3652
					self:px(1), -- 3652
					SOLID_EDGE -- 3652
				) -- 3652
			end -- 3652
			draw:drawRect( -- 3654
				Rect(x0, y - deck, x1 - x0, deck), -- 3654
				FLOOR_DECK -- 3654
			) -- 3654
			draw:drawSegment( -- 3655
				Vec2(x0, y), -- 3655
				Vec2(x1, y), -- 3655
				self:px(1), -- 3655
				GROUND -- 3655
			) -- 3655
			i = i + 1 -- 3643
		end -- 3643
	end -- 3643
end -- 3641
function Play.prototype.drawSolids(self, draw, w, h) -- 3659
	local i = 0 -- 3660
	do -- 3660
		i = 0 -- 3661
		while i < #self.boxes do -- 3661
			do -- 3661
				local b = self.boxes[i + 1] -- 3662
				if b.id == "braced_shield" or b.hidden == true then -- 3662
					goto __continue709 -- 3664
				end -- 3664
				if b.broken == true then -- 3664
					if b.breakable ~= nil then -- 3664
						local gy = self:sy(b.y0, h) -- 3669
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3670
						local k = 0 -- 3671
						do -- 3671
							k = 0 -- 3672
							while k < 3 do -- 3672
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3673
								draw:drawSegment( -- 3674
									Vec2( -- 3674
										gx - self:px(4), -- 3674
										gy + self:px(k % 2) -- 3674
									), -- 3674
									Vec2( -- 3674
										gx + self:px(5), -- 3674
										gy + self:px(k % 2) -- 3674
									), -- 3674
									self:px(1), -- 3674
									rgb -- 3674
								) -- 3674
								k = k + 1 -- 3672
							end -- 3672
						end -- 3672
					end -- 3672
					goto __continue709 -- 3677
				end -- 3677
				local ____opt_64 = b.depth -- 3677
				local front = ____opt_64 and ____opt_64.min or 0 -- 3679
				local ____opt_66 = b.depth -- 3679
				local back = ____opt_66 and ____opt_66.max or 0 -- 3680
				local fill = SOLID_FILL -- 3681
				local line = SOLID_EDGE -- 3682
				if b.soft == true then -- 3682
					fill = SOFT -- 3684
					line = SOFT_LINE -- 3685
				elseif b.breakable ~= nil then -- 3685
					line = DANGER_LINE -- 3687
					fill = Color(0.3, 0.24, 0.16, 1) -- 3688
				elseif b.interact ~= nil then -- 3688
					line = PASS_LINE -- 3690
				end -- 3690
				self:drawBox( -- 3692
					draw, -- 3692
					w, -- 3692
					h, -- 3692
					b.x0, -- 3692
					b.x1, -- 3692
					b.y0 + front, -- 3692
					b.y1 + back, -- 3692
					fill -- 3692
				) -- 3692
				draw:drawSegment( -- 3693
					Vec2( -- 3693
						self:sx(b.x0, w), -- 3693
						self:sy(b.y1 + front, h) -- 3693
					), -- 3693
					Vec2( -- 3694
						self:sx(b.x1, w), -- 3694
						self:sy(b.y1 + front, h) -- 3694
					), -- 3694
					self:px(1), -- 3694
					line -- 3694
				) -- 3694
				if b.breakable ~= nil then -- 3694
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3697
					local cyp = self:sy(b.y1 + front, h) -- 3698
					draw:drawSegment( -- 3699
						Vec2( -- 3699
							cxp - self:px(4), -- 3699
							cyp + self:px(1) -- 3699
						), -- 3699
						Vec2( -- 3699
							cxp + self:px(3), -- 3699
							cyp + self:px(5) -- 3699
						), -- 3699
						self:px(1), -- 3699
						line -- 3699
					) -- 3699
				end -- 3699
			end -- 3699
			::__continue709:: -- 3699
			i = i + 1 -- 3661
		end -- 3661
	end -- 3661
end -- 3659
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3705
	local i = 0 -- 3706
	do -- 3706
		i = 0 -- 3707
		while i < #self.pickups do -- 3707
			do -- 3707
				local pk = self.pickups[i + 1] -- 3708
				if pk.id == "" then -- 3708
					goto __continue721 -- 3710
				end -- 3710
				local gy = pk.y + (pk.depth or 0) -- 3712
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3713
				draw:drawRect( -- 3714
					Rect( -- 3714
						self:sx(pk.x - 5, w), -- 3714
						self:sy(gy + 12 + bob, h), -- 3714
						self:px(10), -- 3714
						self:px(10) -- 3714
					), -- 3714
					Color(0.84, 0.7, 0.3, 1) -- 3715
				) -- 3715
				draw:drawSegment( -- 3716
					Vec2( -- 3716
						self:sx(pk.x - 5, w), -- 3716
						self:sy(gy + 12 + bob, h) -- 3716
					), -- 3716
					Vec2( -- 3717
						self:sx(pk.x + 5, w), -- 3717
						self:sy(gy + 12 + bob, h) -- 3717
					), -- 3717
					self:px(1), -- 3717
					Color(0.95, 0.86, 0.52, 1) -- 3717
				) -- 3717
			end -- 3717
			::__continue721:: -- 3717
			i = i + 1 -- 3707
		end -- 3707
	end -- 3707
	if self.bracedShield ~= nil then -- 3707
		local sh = self.bracedShield -- 3720
		draw:drawRect( -- 3721
			Rect( -- 3721
				self:sx(sh.x - sh.w / 2, w), -- 3721
				self:sy(sh.y, h), -- 3721
				self:px(sh.w), -- 3721
				self:px(sh.h) -- 3721
			), -- 3721
			Color(0.42, 0.4, 0.34, 1) -- 3722
		) -- 3722
		draw:drawSegment( -- 3723
			Vec2( -- 3723
				self:sx(sh.x - sh.w / 2, w), -- 3723
				self:sy(sh.y + sh.h, h) -- 3723
			), -- 3723
			Vec2( -- 3724
				self:sx(sh.x + sh.w / 2, w), -- 3724
				self:sy(sh.y + sh.h, h) -- 3724
			), -- 3724
			self:px(1), -- 3724
			Color(0.74, 0.72, 0.62, 1) -- 3724
		) -- 3724
	end -- 3724
end -- 3705
function Play.prototype.drawZones(self, draw, w, h) -- 3728
	local i = 0 -- 3729
	do -- 3729
		i = 0 -- 3730
		while i < #self.room.zones do -- 3730
			local z = self.room.zones[i + 1] -- 3731
			local fill = DANGER -- 3732
			local line = DANGER_LINE -- 3733
			if z.tint == 2 then -- 3733
				fill = SOFT -- 3735
				line = SOFT_LINE -- 3736
			elseif z.tint == 3 then -- 3736
				fill = BRICK -- 3738
				line = BRICK_LINE -- 3739
			elseif z.tint == 4 then -- 3739
				fill = PASS -- 3741
				line = PASS_LINE -- 3742
			end -- 3742
			self:drawBox( -- 3744
				draw, -- 3744
				w, -- 3744
				h, -- 3744
				z.x0, -- 3744
				z.x1, -- 3744
				z.y, -- 3744
				z.y + z.h, -- 3744
				fill -- 3744
			) -- 3744
			draw:drawSegment( -- 3745
				Vec2( -- 3745
					self:sx(z.x0, w), -- 3745
					self:sy(z.y, h) -- 3745
				), -- 3745
				Vec2( -- 3745
					self:sx(z.x0, w), -- 3745
					self:sy(z.y + z.h, h) -- 3745
				), -- 3745
				self:px(1), -- 3745
				line -- 3745
			) -- 3745
			draw:drawSegment( -- 3746
				Vec2( -- 3746
					self:sx(z.x1, w), -- 3746
					self:sy(z.y, h) -- 3746
				), -- 3746
				Vec2( -- 3746
					self:sx(z.x1, w), -- 3746
					self:sy(z.y + z.h, h) -- 3746
				), -- 3746
				self:px(1), -- 3746
				line -- 3746
			) -- 3746
			i = i + 1 -- 3730
		end -- 3730
	end -- 3730
end -- 3728
function Play.prototype.drawArch(self, draw, w, h) -- 3750
	local a = self.room.arch -- 3751
	if a.h <= 0 then -- 3751
		return -- 3753
	end -- 3753
	self:drawBox( -- 3755
		draw, -- 3755
		w, -- 3755
		h, -- 3755
		a.x0, -- 3755
		a.x1, -- 3755
		a.y, -- 3755
		a.y + a.h, -- 3755
		HOLE_FILL -- 3755
	) -- 3755
	draw:drawSegment( -- 3756
		Vec2( -- 3756
			self:sx(a.x0, w), -- 3756
			self:sy(a.y + a.h, h) -- 3756
		), -- 3756
		Vec2( -- 3756
			self:sx(a.x1, w), -- 3756
			self:sy(a.y + a.h, h) -- 3756
		), -- 3756
		self:px(1), -- 3756
		SOLID_EDGE -- 3756
	) -- 3756
	draw:drawSegment( -- 3757
		Vec2( -- 3757
			self:sx(a.x0, w), -- 3757
			self:sy(a.y, h) -- 3757
		), -- 3757
		Vec2( -- 3757
			self:sx(a.x0, w), -- 3757
			self:sy(a.y + a.h, h) -- 3757
		), -- 3757
		self:px(1), -- 3757
		SOLID_EDGE -- 3757
	) -- 3757
	draw:drawSegment( -- 3758
		Vec2( -- 3758
			self:sx(a.x1, w), -- 3758
			self:sy(a.y, h) -- 3758
		), -- 3758
		Vec2( -- 3758
			self:sx(a.x1, w), -- 3758
			self:sy(a.y + a.h, h) -- 3758
		), -- 3758
		self:px(1), -- 3758
		SOLID_EDGE -- 3758
	) -- 3758
end -- 3750
function Play.prototype.drawCart(self, draw, w, h) -- 3761
	local c = self.room.cart -- 3762
	if c.bodyW <= 0 then -- 3762
		return -- 3764
	end -- 3764
	drawCartShape( -- 3766
		draw, -- 3766
		self, -- 3766
		w, -- 3766
		h, -- 3766
		c, -- 3766
		self.cartAxle -- 3766
	) -- 3766
	draw:drawRect( -- 3767
		Rect( -- 3767
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 3767
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 3767
			self:px(2), -- 3767
			self:px(40) -- 3767
		), -- 3767
		STAND -- 3767
	) -- 3767
end -- 3761
function Play.prototype.drawActors(self, draw, w, h) -- 3770
	local p = self.player -- 3771
	local isChild = self.childMode -- 3772
	local footY = p.y + p.depth -- 3773
	if p.covered then -- 3773
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 3776
		draw:drawSegment( -- 3777
			Vec2( -- 3777
				self:sx(edge, w), -- 3777
				self:sy(footY + 8, h) -- 3777
			), -- 3777
			Vec2( -- 3777
				self:sx(edge, w), -- 3777
				self:sy(footY + p.h * 0.62, h) -- 3777
			), -- 3777
			self:px(2), -- 3777
			STAND -- 3777
		) -- 3777
		draw:drawSegment( -- 3779
			Vec2( -- 3779
				self:sx(p.x - 8, w), -- 3779
				self:sy(footY + p.h + 3, h) -- 3779
			), -- 3779
			Vec2( -- 3779
				self:sx(p.x + 8, w), -- 3779
				self:sy(footY + p.h + 3, h) -- 3779
			), -- 3779
			self:px(2), -- 3779
			STAND -- 3779
		) -- 3779
	elseif self.coverNear and not isChild then -- 3779
		draw:drawRect( -- 3782
			Rect( -- 3782
				self:sx(p.x - 3, w), -- 3782
				self:sy(footY + 1, h), -- 3782
				self:px(3), -- 3782
				self:px(3) -- 3782
			), -- 3782
			STAND -- 3782
		) -- 3782
	end -- 3782
	drawFigure( -- 3784
		draw, -- 3784
		self, -- 3784
		w, -- 3784
		h, -- 3784
		p, -- 3784
		isChild and CHILD_BODY or SOLDIER_BODY, -- 3784
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 3784
	) -- 3784
	local q = self.partner -- 3785
	if q.alive then -- 3785
		local childPartner = q.w == CHILD_W -- 3787
		drawFigure( -- 3788
			draw, -- 3788
			self, -- 3788
			w, -- 3788
			h, -- 3788
			q, -- 3788
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 3788
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 3788
		) -- 3788
	end -- 3788
	local i = 0 -- 3790
	do -- 3790
		i = 0 -- 3791
		while i < #self.enemies do -- 3791
			local e = self.enemies[i + 1] -- 3792
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 3793
			local enemyY = e.y + (e.depth or 0) -- 3794
			self:drawBox( -- 3795
				draw, -- 3795
				w, -- 3795
				h, -- 3795
				e.x - e.w / 2, -- 3795
				e.x + e.w / 2, -- 3795
				enemyY, -- 3795
				enemyY + e.h, -- 3795
				col -- 3795
			) -- 3795
			if e.alive then -- 3795
				local ef = p.x >= e.x and 1 or -1 -- 3797
				if e.kind == "shield" then -- 3797
					local sh = (e.shieldHp or 0) > 0 -- 3799
					draw:drawRect( -- 3800
						Rect( -- 3800
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 3800
							self:sy(enemyY, h), -- 3800
							self:px(6), -- 3800
							self:px(64) -- 3800
						), -- 3800
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 3801
					) -- 3801
				elseif e.kind == "breaker" then -- 3801
					draw:drawSegment( -- 3803
						Vec2( -- 3803
							self:sx(e.x + ef * 12, w), -- 3803
							self:sy(enemyY + 8, h) -- 3803
						), -- 3803
						Vec2( -- 3804
							self:sx(e.x + ef * 22, w), -- 3804
							self:sy(enemyY + 46, h) -- 3804
						), -- 3804
						self:px(3), -- 3804
						Color(0.5, 0.36, 0.22, 1) -- 3804
					) -- 3804
				end -- 3804
			end -- 3804
			if e.alive and e.warnT > 0 then -- 3804
				local gunX = self:sx(e.x, w) -- 3809
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 3810
				local aimX = self:sx(p.x, w) -- 3811
				local aimY = self:sy(footY + p.h * 0.55, h) -- 3812
				local seg = 8 -- 3813
				local s = 0 -- 3814
				do -- 3814
					s = 0 -- 3815
					while s < seg do -- 3815
						local t0 = s / seg -- 3816
						local t1 = (s + 1) / seg -- 3817
						draw:drawSegment( -- 3818
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 3819
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 3820
							self:px(1), -- 3821
							DANGER -- 3821
						) -- 3821
						s = s + 2 -- 3815
					end -- 3815
				end -- 3815
			end -- 3815
			i = i + 1 -- 3791
		end -- 3791
	end -- 3791
	local k = 0 -- 3826
	do -- 3826
		k = 0 -- 3827
		while k < #self.room.marks do -- 3827
			do -- 3827
				local m = self.room.marks[k + 1] -- 3828
				if m.kind ~= 0 then -- 3828
					goto __continue747 -- 3830
				end -- 3830
				local on = self.checkpoint == m.x -- 3832
				local x = self:sx(m.x, w) -- 3833
				local y = self:sy(m.y, h) -- 3834
				draw:drawSegment( -- 3835
					Vec2(x, y), -- 3835
					Vec2( -- 3835
						x, -- 3835
						y + self:px(35) -- 3835
					), -- 3835
					self:px(1), -- 3835
					on and CHECK or INK_DIM -- 3835
				) -- 3835
				draw:drawDot( -- 3836
					Vec2( -- 3836
						x, -- 3836
						y + self:px(35) -- 3836
					), -- 3836
					self:px(2), -- 3836
					on and CHECK or INK_DIM -- 3836
				) -- 3836
			end -- 3836
			::__continue747:: -- 3836
			k = k + 1 -- 3827
		end -- 3827
	end -- 3827
	local j = 0 -- 3840
	do -- 3840
		j = 0 -- 3841
		while j < #self.room.marks do -- 3841
			do -- 3841
				local m = self.room.marks[j + 1] -- 3842
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 3842
					goto __continue750 -- 3844
				end -- 3844
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 3844
					goto __continue750 -- 3848
				end -- 3848
				local col = STAND -- 3850
				if m.kind == 4 then -- 3850
					col = PASS_LINE -- 3852
				elseif m.kind == 5 then -- 3852
					col = BRICK_LINE -- 3854
				end -- 3854
				local mx = self:sx(m.x, w) -- 3856
				local my = self:sy(m.y, h) -- 3857
				draw:drawSegment( -- 3858
					Vec2(mx, my), -- 3858
					Vec2( -- 3858
						mx, -- 3858
						my + self:px(24) -- 3858
					), -- 3858
					self:px(1), -- 3858
					col -- 3858
				) -- 3858
			end -- 3858
			::__continue750:: -- 3858
			j = j + 1 -- 3841
		end -- 3841
	end -- 3841
	local t = 0 -- 3861
	do -- 3861
		t = 0 -- 3862
		while t < #self.room.marks do -- 3862
			do -- 3862
				local m = self.room.marks[t + 1] -- 3863
				if m.kind ~= 6 then -- 3863
					goto __continue756 -- 3865
				end -- 3865
				local mx = self:sx(m.x, w) -- 3867
				local my = self:sy(m.y, h) -- 3868
				draw:drawSegment( -- 3869
					Vec2(mx, my), -- 3869
					Vec2( -- 3869
						mx, -- 3869
						my + self:px(30) -- 3869
					), -- 3869
					self:px(1), -- 3869
					INK_DIM -- 3869
				) -- 3869
				self:drawBox( -- 3870
					draw, -- 3870
					w, -- 3870
					h, -- 3870
					m.x - 5, -- 3870
					m.x + 5, -- 3870
					m.y + 30, -- 3870
					m.y + 40, -- 3870
					CHECK -- 3870
				) -- 3870
			end -- 3870
			::__continue756:: -- 3870
			t = t + 1 -- 3862
		end -- 3862
	end -- 3862
	if self.room.key == "village" then -- 3862
		self:drawVillage(draw, w, h) -- 3873
	end -- 3873
	if self.room.key == "forest" then -- 3873
		self:drawDog(draw, w, h) -- 3876
	end -- 3876
end -- 3770
function Play.prototype.drawDog(self, draw, w, h) -- 3881
	local x = self.dogX -- 3882
	self:drawBox( -- 3883
		draw, -- 3883
		w, -- 3883
		h, -- 3883
		x - 14, -- 3883
		x + 14, -- 3883
		0, -- 3883
		20, -- 3883
		SCAV_BODY -- 3883
	) -- 3883
	self:drawBox( -- 3884
		draw, -- 3884
		w, -- 3884
		h, -- 3884
		x - 10, -- 3884
		x - 2, -- 3884
		20, -- 3884
		30, -- 3884
		SCAV_BODY -- 3884
	) -- 3884
	self:drawBox( -- 3885
		draw, -- 3885
		w, -- 3885
		h, -- 3885
		x + 2, -- 3885
		x + 10, -- 3885
		20, -- 3885
		30, -- 3885
		SCAV_HEAD -- 3885
	) -- 3885
	if self.dogState == "ear" or self.dogState == "chase" then -- 3885
		draw:drawSegment( -- 3887
			Vec2( -- 3887
				self:sx(x, w), -- 3887
				self:sy(30, h) -- 3887
			), -- 3887
			Vec2( -- 3888
				self:sx(x, w), -- 3888
				self:sy(40, h) -- 3888
			), -- 3888
			self:px(1), -- 3888
			DANGER -- 3888
		) -- 3888
	end -- 3888
end -- 3881
function Play.prototype.drawVillage(self, draw, w, h) -- 3893
	local bottle = self.room.bottle -- 3894
	if bottle ~= nil then -- 3894
		self:drawBox( -- 3896
			draw, -- 3896
			w, -- 3896
			h, -- 3896
			bottle.x - 14, -- 3896
			bottle.x + 14, -- 3896
			0, -- 3896
			64, -- 3896
			SOLID_FILL -- 3896
		) -- 3896
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 3896
			self:drawBottle( -- 3898
				draw, -- 3898
				w, -- 3898
				h, -- 3898
				bottle.x, -- 3898
				64 -- 3898
			) -- 3898
		end -- 3898
	end -- 3898
	self:drawBox( -- 3902
		draw, -- 3902
		w, -- 3902
		h, -- 3902
		300, -- 3902
		420, -- 3902
		44, -- 3902
		50, -- 3902
		FLOOR_DECK -- 3902
	) -- 3902
	self:drawBox( -- 3903
		draw, -- 3903
		w, -- 3903
		h, -- 3903
		300, -- 3903
		306, -- 3903
		0, -- 3903
		44, -- 3903
		FLOOR_DECK -- 3903
	) -- 3903
	self:drawBox( -- 3904
		draw, -- 3904
		w, -- 3904
		h, -- 3904
		414, -- 3904
		420, -- 3904
		0, -- 3904
		44, -- 3904
		FLOOR_DECK -- 3904
	) -- 3904
	local s = self.room.scavenger -- 3906
	if s ~= nil then -- 3906
		local sx0 = self.scavX -- 3908
		self:drawBox( -- 3909
			draw, -- 3909
			w, -- 3909
			h, -- 3909
			sx0 - 12, -- 3909
			sx0 + 12, -- 3909
			0, -- 3909
			s.h - 14, -- 3909
			SCAV_BODY -- 3909
		) -- 3909
		self:drawBox( -- 3910
			draw, -- 3910
			w, -- 3910
			h, -- 3910
			sx0 - 7, -- 3910
			sx0 + 7, -- 3910
			s.h - 14, -- 3910
			s.h, -- 3910
			SCAV_HEAD -- 3910
		) -- 3910
		if self.scavState == "turn" then -- 3910
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 3912
			draw:drawSegment( -- 3913
				Vec2( -- 3913
					self:sx(sx0, w), -- 3913
					self:sy(s.h - 6, h) -- 3913
				), -- 3913
				Vec2( -- 3913
					self:sx(fx, w), -- 3913
					self:sy(s.h - 6, h) -- 3913
				), -- 3913
				self:px(1), -- 3913
				INK -- 3913
			) -- 3913
		end -- 3913
	end -- 3913
	if self.hasBottle then -- 3913
		local p = self.player -- 3918
		self:drawBottle( -- 3919
			draw, -- 3919
			w, -- 3919
			h, -- 3919
			p.x + p.facing * 10, -- 3919
			p.y + p.h * 0.62 -- 3919
		) -- 3919
	end -- 3919
	if self.bottleFly ~= nil then -- 3919
		self:drawBottle( -- 3922
			draw, -- 3922
			w, -- 3922
			h, -- 3922
			self.bottleFly.x, -- 3922
			self.bottleFly.y -- 3922
		) -- 3922
	end -- 3922
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 3922
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 3925
		draw:drawCircle( -- 3926
			Vec2( -- 3926
				self:sx(self.bottleLandX, w), -- 3926
				self:sy(0, h) -- 3926
			), -- 3926
			self:px(r / ____exports.UNITS_PER_PX), -- 3926
			BRICK_LINE -- 3926
		) -- 3926
	end -- 3926
end -- 3893
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 3930
	self:drawBox( -- 3931
		draw, -- 3931
		w, -- 3931
		h, -- 3931
		x - 3, -- 3931
		x + 3, -- 3931
		y - 10, -- 3931
		y, -- 3931
		BOTTLE -- 3931
	) -- 3931
end -- 3930
function Play.prototype.drawTrace(self, draw, w, h) -- 3934
	local t = self.trace -- 3935
	if t == nil or self.traceT <= 0 then -- 3935
		return -- 3937
	end -- 3937
	draw:drawSegment( -- 3939
		Vec2( -- 3940
			self:sx(t.x0, w), -- 3940
			self:sy(t.y0, h) -- 3940
		), -- 3940
		Vec2( -- 3941
			self:sx(t.x1, w), -- 3941
			self:sy(t.y1, h) -- 3941
		), -- 3941
		self:px(1), -- 3942
		t.hit and AIM_HIT or INK_DIM -- 3942
	) -- 3942
end -- 3934
function Play.prototype.drawAim(self, draw, w, h) -- 3945
	local v = self.view -- 3947
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 3948
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 3949
	local dot = self:px(1) -- 3950
	local arm = self:px(3) -- 3951
	local gap = self:px(1) -- 3952
	draw:drawSegment( -- 3953
		Vec2(gx - arm - gap, gy), -- 3953
		Vec2(gx - gap, gy), -- 3953
		dot / 2, -- 3953
		AIM -- 3953
	) -- 3953
	draw:drawSegment( -- 3954
		Vec2(gx + gap, gy), -- 3954
		Vec2(gx + arm + gap, gy), -- 3954
		dot / 2, -- 3954
		AIM -- 3954
	) -- 3954
	draw:drawSegment( -- 3955
		Vec2(gx, gy - arm - gap), -- 3955
		Vec2(gx, gy - gap), -- 3955
		dot / 2, -- 3955
		AIM -- 3955
	) -- 3955
	draw:drawSegment( -- 3956
		Vec2(gx, gy + gap), -- 3956
		Vec2(gx, gy + arm + gap), -- 3956
		dot / 2, -- 3956
		AIM -- 3956
	) -- 3956
	if self.room.key == "village" and self.hasBottle then -- 3956
		local p = self.player -- 3960
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3962
		local dir = ____end.x >= p.x and 1 or -1 -- 3963
		local x0 = p.x + dir * 10 -- 3964
		local y0 = p.y + p.h * 0.7 -- 3965
		local T = BOTTLE_FLY_TIME -- 3966
		local vx = (____end.x - x0) / T -- 3967
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 3968
		local pxr = x0 -- 3969
		local pyr = y0 -- 3970
		local t = 1 -- 3971
		do -- 3971
			t = 1 -- 3972
			while t <= 12 do -- 3972
				local tt = t / 12 * T -- 3973
				local nx = x0 + vx * tt -- 3974
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 3975
				draw:drawSegment( -- 3976
					Vec2( -- 3976
						self:sx(pxr, w), -- 3976
						self:sy(pyr, h) -- 3976
					), -- 3976
					Vec2( -- 3976
						self:sx(nx, w), -- 3976
						self:sy(ny, h) -- 3976
					), -- 3976
					self:px(1) / 2, -- 3976
					BOTTLE -- 3976
				) -- 3976
				pxr = nx -- 3977
				pyr = ny -- 3978
				t = t + 1 -- 3972
			end -- 3972
		end -- 3972
		draw:drawCircle( -- 3980
			Vec2( -- 3980
				self:sx(____end.x, w), -- 3980
				self:sy(____end.y + 2, h) -- 3980
			), -- 3980
			self:px(2), -- 3980
			BOTTLE -- 3980
		) -- 3980
	end -- 3980
end -- 3945
return ____exports -- 3945