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
function makeActor(room, index) -- 4235
	local sp = room.spawns -- 4236
	if index < 0 or index >= #sp then -- 4236
		return { -- 4238
			x = 0, -- 4238
			y = 0, -- 4238
			depth = 0, -- 4238
			depthSpeed = 0, -- 4238
			vx = 0, -- 4238
			vy = 0, -- 4238
			w = CHILD_W, -- 4238
			h = CHILD_H, -- 4238
			onGround = true, -- 4238
			facing = 1, -- 4238
			crouch = false, -- 4238
			rollT = 0, -- 4238
			covered = false, -- 4238
			alive = false -- 4238
		} -- 4238
	end -- 4238
	local s = sp[index + 1] -- 4240
	local child = s.h <= CHILD_H -- 4241
	local ground = room.depth -- 4242
	local depth = ground == nil and 0 or math.max( -- 4243
		ground.min, -- 4243
		math.min(ground.max, s.depth or 0) -- 4243
	) -- 4243
	return { -- 4244
		x = s.x, -- 4245
		y = s.y, -- 4245
		depth = depth, -- 4245
		depthSpeed = 0, -- 4245
		vx = 0, -- 4245
		vy = 0, -- 4245
		w = child and CHILD_W or SOLDIER_W, -- 4246
		h = child and CHILD_H or SOLDIER_H, -- 4247
		onGround = true, -- 4248
		facing = 1, -- 4248
		crouch = false, -- 4248
		rollT = 0, -- 4248
		covered = false, -- 4248
		alive = true -- 4248
	} -- 4248
end -- 4248
function drawFigure(draw, play, w, h, a, body, head) -- 4252
	if not a.alive then -- 4252
		return -- 4254
	end -- 4254
	local x0 = a.x - a.w / 2 -- 4256
	local x1 = a.x + a.w / 2 -- 4257
	local y0 = a.y + a.depth -- 4258
	local y1 = y0 + a.h -- 4259
	play:drawBox( -- 4260
		draw, -- 4260
		w, -- 4260
		h, -- 4260
		x0, -- 4260
		x1, -- 4260
		y0, -- 4260
		y1 - a.h * 0.26, -- 4260
		body -- 4260
	) -- 4260
	play:drawBox( -- 4261
		draw, -- 4261
		w, -- 4261
		h, -- 4261
		x0 + 2, -- 4261
		x1 - 2, -- 4261
		y1 - a.h * 0.26, -- 4261
		y1, -- 4261
		head -- 4261
	) -- 4261
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 4263
	play:drawBox( -- 4264
		draw, -- 4264
		w, -- 4264
		h, -- 4264
		eyeX, -- 4264
		eyeX + 4, -- 4264
		y1 - a.h * 0.14, -- 4264
		y1 - a.h * 0.08, -- 4264
		INK -- 4264
	) -- 4264
end -- 4264
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 4268
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 4269
end -- 4268
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 4276
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 4277
end -- 4276
function rayInterval(origin, direction, min, max) -- 4284
	if direction == 0 then -- 4284
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4286
	end -- 4286
	local a = (min - origin) / direction -- 4288
	local b = (max - origin) / direction -- 4289
	return { -- 4290
		min = math.min(a, b), -- 4290
		max = math.max(a, b) -- 4290
	} -- 4290
end -- 4290
function hitBox(ray, box) -- 4294
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4295
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4296
	local enter = math.max(0, x.min, y.min) -- 4297
	local leave = math.min(99999, x.max, y.max) -- 4298
	if box.depth ~= nil then -- 4298
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4300
		enter = math.max(enter, depth.min) -- 4301
		leave = math.min(leave, depth.max) -- 4302
	end -- 4302
	return leave >= enter and enter or -1 -- 4304
end -- 4304
function drawCartShape(draw, play, w, h, c, axleX) -- 4307
	local half = c.bodyW / 2 -- 4308
	local x0 = axleX - half -- 4309
	local x1 = axleX + half -- 4310
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4311
	play:drawBox( -- 4312
		draw, -- 4312
		w, -- 4312
		h, -- 4312
		x0, -- 4312
		x1, -- 4312
		axleY, -- 4312
		axleY + c.bodyH, -- 4312
		CART_FILL -- 4312
	) -- 4312
	draw:drawCircle( -- 4313
		Vec2( -- 4313
			play:sx(x0 + c.bodyW * 0.28, w), -- 4313
			play:sy(axleY, h) -- 4313
		), -- 4313
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4313
		Color(52, 50, 48, 255) -- 4313
	) -- 4313
	draw:drawCircle( -- 4314
		Vec2( -- 4314
			play:sx(x1 - c.bodyW * 0.28, w), -- 4314
			play:sy(axleY, h) -- 4314
		), -- 4314
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4314
		Color(52, 50, 48, 255) -- 4314
	) -- 4314
	local cx = c.clothSide < 0 and x0 or x1 -- 4315
	play:drawBox( -- 4316
		draw, -- 4316
		w, -- 4316
		h, -- 4316
		cx - 10, -- 4316
		cx + 10, -- 4316
		axleY + c.bodyH, -- 4316
		axleY + c.bodyH + 18, -- 4316
		CLOTH -- 4316
	) -- 4316
end -- 4316
____exports.STEP = STEP -- 24
____exports.GRAVITY = 1000 -- 25
____exports.GATE_COUNT_END = 1440 -- 26
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 28
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 30
function ____exports.gateCountAtTick(tick) -- 32
	if tick >= ____exports.GATE_COUNT_END then -- 32
		return 20 -- 33
	end -- 33
	if tick >= 1260 then -- 33
		return 19 -- 34
	end -- 34
	if tick >= 1080 then -- 34
		return 18 -- 35
	end -- 35
	if tick >= 480 then -- 35
		return 11 + math.floor((tick - 480) * 7 / 600) -- 36
	end -- 36
	return 1 + math.floor(math.max(0, tick) / 48) -- 37
end -- 32
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 40
CHILD_W = 28 -- 85
CHILD_H = 64 -- 86
local CHILD_CROUCH_H = 36 -- 87
local CHILD_SPEED = 160 -- 88
local CHILD_SLOW = 80 -- 89
local CHILD_JUMP = 320 -- 90
SOLDIER_W = 30 -- 93
SOLDIER_H = 88 -- 94
local SOLDIER_SPEED = 264 -- 95
local ROLL_TIME = 0.35 -- 96
local ROLL_SPEED = 280 -- 97
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 99
local LEDGE_RISE = 60 -- 100
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 103
____exports.LOGIC_H = 180 -- 104
____exports.UNITS_PER_PX = 2 -- 105
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 107
local CAM_FOLLOW = 9 -- 108
local CAM_LOOK_UP = 46 -- 109
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 112
--- 握把触发半径。
____exports.CART_REACH = 70 -- 114
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 116
local CART_CLEAR = 44 -- 117
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 119
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 121
local CONSUMABLE_CAP = 1 -- 122
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 124
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 126
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 128
local FIRE_COOLDOWN = 150 -- 129
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 131
local ENEMY_RANGE = 760 -- 132
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 134
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 136
local DEPTH_SPEED_RATIO = 0.55 -- 137
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 138
INK = Color(232, 232, 228, 255) -- 140
local INK_DIM = Color(150, 152, 150, 255) -- 141
local BG_VOID = Color(8, 9, 10, 255) -- 142
local BG_FAR = Color(24, 26, 28, 255) -- 143
local BG_MID = Color(31, 34, 37, 255) -- 144
local GROUND = Color(112, 114, 112, 255) -- 145
local FLOOR_DECK = Color(66, 70, 72, 255) -- 146
local SOLID_FILL = Color(84, 86, 84, 255) -- 147
local SOLID_EDGE = Color(126, 130, 126, 255) -- 148
CART_FILL = Color(122, 78, 56, 255) -- 149
CLOTH = Color(178, 52, 46, 255) -- 150
local DANGER = Color(150, 54, 48, 46) -- 151
local DANGER_LINE = Color(178, 78, 64, 200) -- 152
local HOLE_FILL = Color(10, 11, 12, 255) -- 153
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 154
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 155
local CHILD_BODY = Color(214, 168, 96, 255) -- 156
local CHILD_HEAD = Color(232, 214, 186, 255) -- 157
local ENEMY_BODY = Color(176, 92, 84, 255) -- 158
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 159
local CHECK = Color(96, 186, 122, 255) -- 160
local STAND = Color(226, 186, 84, 255) -- 161
local AIM = Color(236, 236, 232, 230) -- 162
local AIM_HIT = Color(236, 96, 84, 255) -- 163
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 165
local SOFT_LINE = Color(140, 112, 80, 190) -- 166
local BRICK = Color(126, 118, 110, 70) -- 167
local BRICK_LINE = Color(160, 152, 142, 200) -- 168
local PASS = Color(96, 186, 122, 40) -- 169
local PASS_LINE = Color(96, 186, 122, 200) -- 170
local BOTTLE = Color(120, 186, 160, 255) -- 171
local SCAV_BODY = Color(128, 118, 96, 255) -- 172
local SCAV_HEAD = Color(196, 182, 158, 255) -- 173
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 260
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 261
	if zoom < 1 then -- 261
		zoom = 1 -- 263
	end -- 263
	return { -- 265
		zoom = zoom, -- 266
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 267
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 268
	} -- 268
end -- 260
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 291
	if key == "prologue" then -- 291
		return "prologue-wait" -- 293
	end -- 293
	if key == "street" then -- 293
		return "street-run" -- 296
	end -- 296
	if key == "gate" then -- 296
		return "gate-idle" -- 299
	end -- 299
	if key == "gatepath" then -- 299
		return "gatepath-start" -- 302
	end -- 302
	if key == "forest" then -- 302
		return "forest-run" -- 305
	end -- 305
	if key == "tower" then -- 305
		return "tower-wait" -- 308
	end -- 308
	return "run" -- 310
end -- 291
____exports.Play = __TS__Class() -- 313
local Play = ____exports.Play -- 313
Play.name = "Play" -- 313
function Play.prototype.____constructor(self, room, resume, run) -- 508
	self.enemies = {} -- 318
	self.boxes = {} -- 319
	self.floors = {} -- 320
	self.checkpoint = -1 -- 322
	self.flash = "" -- 324
	self.flashT = 0 -- 325
	self.traceT = 0 -- 328
	self.focusCart = false -- 330
	self.knocks = 0 -- 332
	self.knockT = 0 -- 333
	self.cartAxle = 0 -- 337
	self.cartDocked = false -- 339
	self.gripping = false -- 341
	self.gateOpen = false -- 343
	self.calmConsumed = false -- 345
	self.craftT = 0 -- 347
	self.nextDangerId = 1 -- 349
	self.wantRoom = "" -- 351
	self.carryCartAxle = -1 -- 353
	self.carryCartDocked = false -- 354
	self.checkpointCartAxle = -1 -- 356
	self.hasBottle = false -- 360
	self.bottleLandX = -1 -- 364
	self.bottleTargetX = -1 -- 365
	self.bottleTargetY = 0 -- 366
	self.bottleLandT = 0 -- 367
	self.aimHold = 0 -- 369
	self.scavX = 0 -- 371
	self.scavDir = 1 -- 372
	self.scavState = "patrol" -- 373
	self.scavT = 0 -- 374
	self.scavTargetX = 0 -- 375
	self.passed = false -- 377
	self.childMode = false -- 381
	self.phase = "" -- 383
	self.phaseTick = 0 -- 385
	self.gateTick = 0 -- 387
	self.countTick = 0 -- 389
	self.countArmed = false -- 391
	self.countPrevMove = 0 -- 393
	self.caughtT = 0 -- 395
	self.hp = 3 -- 397
	self.maxHp = 3 -- 398
	self.invulnT = 0 -- 404
	self.partnerStuck = 0 -- 406
	self.partnerLaneIdx = 0 -- 408
	self.partnerLaneHold = 0 -- 409
	self.coveredFlash = 0 -- 411
	self.coverHug = false -- 413
	self.coverNear = false -- 415
	self.coverEntity = "" -- 417
	self.coverBlocking = false -- 419
	self.gateNeedConfirm = false -- 421
	self.gateRestartArmed = true -- 423
	self.bottleAimX = -1 -- 425
	self.bottleAimY = 0 -- 426
	self.bottleSurfaceY = -1 -- 428
	self.bottleLandY = 0 -- 430
	self.events = {} -- 432
	self.eventSeq = 0 -- 434
	self.dogX = 0 -- 436
	self.dogDir = 1 -- 437
	self.dogState = "patrol" -- 438
	self.dogT = 0 -- 439
	self.dogTargetX = 0 -- 440
	self.scavSee = 0 -- 442
	self.scavChase = false -- 443
	self.gateSpawned = 0 -- 445
	self.gateFailCount = 0 -- 447
	self.isCampaign = false -- 451
	self.pickups = {} -- 455
	self.reloadT = 0 -- 457
	self.objectiveDone = false -- 461
	self.hint = "" -- 463
	self.roomStartTick = 0 -- 465
	self.cartHitT = 0 -- 467
	self.cartExposed = false -- 468
	self.storyRoute = "" -- 472
	self.storySettled = false -- 474
	self.hpAtGate = -1 -- 476
	self.maxHpAtGate = -1 -- 477
	self.handTicks = 0 -- 479
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 481
	self.handArmed = false -- 483
	self.handDone = false -- 485
	self.lineSaid = false -- 486
	self.tied = false -- 488
	self.pathDone = false -- 490
	self.paused = false -- 492
	self.ticks = 0 -- 494
	self.view = {zoom = 1, ox = 0, oy = 0} -- 496
	self.ox = 0 -- 498
	self.aimX = 0 -- 500
	self.aimY = 0 -- 501
	self.viewW = 0 -- 503
	self.viewH = 0 -- 504
	self.ox = room.originX -- 510
	self.room = withOrigin(room) -- 511
	local wr = self.room -- 512
	self.run = run or createRun() -- 513
	self.isCampaign = wr.campaign ~= nil -- 514
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 515
	self:buildWorld() -- 516
	self.childMode = wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower" -- 518
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 519
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 520
	self.player = makeActor(wr, playerIdx) -- 521
	self.partner = makeActor(wr, partnerIdx) -- 522
	self.phase = phaseOf(wr.key) -- 523
	if wr.story ~= nil then -- 523
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 525
	end -- 525
	self.cam.x = self.player.x -- 527
	self.cam.y = self.player.y + CAM_LOOK_UP -- 528
	self.cartAxle = wr.cart.startX -- 529
	self.escort = __TS__New( -- 530
		Escort, -- 530
		safeAnchorX(wr.marks) -- 530
	) -- 530
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 531
	if self.isCampaign then -- 531
		self:setupCampaign() -- 533
	else -- 533
		self:buildEnemies() -- 535
	end -- 535
	if resume ~= nil and resume.checkpoint > 0 then -- 535
		self.checkpoint = resume.checkpoint -- 539
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 539
			self.cartAxle = self.room.cart.endX -- 541
			self.cartDocked = true -- 542
			self.player.x = self.ox + 380 -- 545
			self.player.y = 0 -- 546
			self.player.vy = 0 -- 547
			self.player.onGround = true -- 548
			self.cam.x = self.player.x -- 549
			self.cam.y = self.player.y + CAM_LOOK_UP -- 550
		end -- 550
	end -- 550
	self:restoreStory() -- 553
end -- 508
function Play.prototype.restoreStory(self) -- 563
	if self.isCampaign then -- 563
		return -- 566
	end -- 566
	local story = self.run.story -- 568
	if story == nil then -- 568
		return -- 570
	end -- 570
	if story.maxHp > 0 then -- 570
		self.maxHp = story.maxHp -- 573
		self.hp = math.max( -- 574
			1, -- 574
			math.min(story.hp, story.maxHp) -- 574
		) -- 574
	end -- 574
	self.storyRoute = story.route -- 576
	self.storySettled = story.settled -- 577
	self.hpAtGate = story.hpAtGate -- 578
	self.maxHpAtGate = story.maxHpAtGate -- 579
	self.handDone = story.handDone -- 580
	self.lineSaid = story.lineSaid -- 581
	self.tied = story.handDone -- 582
	if self.room.key ~= "gate" or not story.settled then -- 582
		return -- 584
	end -- 584
	local ____temp_0 -- 586
	if self.room.story == nil then -- 586
		____temp_0 = nil -- 586
	else -- 586
		____temp_0 = self.room.story.gate -- 586
	end -- 586
	local g = ____temp_0 -- 586
	if g == nil then -- 586
		return -- 588
	end -- 588
	self.gateTick = g.holdTicks -- 591
	self.gateSpawned = 4 -- 592
	self.enemies = {} -- 593
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 593
		self.phase = story.phase -- 595
		self.countTick = math.max(story.countTick, 0) -- 596
		self:swapToChild(g.doorX + 30) -- 597
		self.countPrevMove = 0 -- 598
		self.countArmed = false -- 599
		return -- 600
	end -- 600
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 600
		self.phase = story.phase -- 603
		self.countTick = ____exports.GATE_COUNT_END -- 604
		self.phaseTick = story.phaseTick -- 605
		self:swapToChild(g.doorX + 30) -- 606
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 607
			0, -- 607
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 607
		) -- 607
		self.handArmed = false -- 608
	end -- 608
end -- 563
function Play.prototype.buildWorld(self) -- 613
	local room = self.room -- 614
	self.boxes = {} -- 615
	self.floors = {} -- 616
	local i = 0 -- 617
	do -- 617
		i = 0 -- 618
		while i < #room.floors do -- 618
			local f = room.floors[i + 1] -- 619
			local ____self_floors_1 = self.floors -- 619
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 620
			i = i + 1 -- 618
		end -- 618
	end -- 618
	do -- 618
		i = 0 -- 622
		while i < #room.solids do -- 622
			local s = room.solids[i + 1] -- 623
			if not s.decorative then -- 623
				local ____self_boxes_13 = self.boxes -- 629
				local ____s_x_4 = s.x -- 630
				local ____temp_5 = s.x + s.w -- 630
				local ____s_y_6 = s.y -- 630
				local ____temp_7 = s.y + s.h -- 630
				local ____temp_2 -- 631
				if room.depth == nil then -- 631
					____temp_2 = nil -- 631
				else -- 631
					____temp_2 = s.depth -- 631
				end -- 631
				local ____temp_8 = s.passable == true -- 632
				local ____s_label_9 = s.label -- 632
				local ____s_id_10 = s.id -- 633
				local ____temp_11 = s.soft == true -- 633
				local ____temp_12 = s.hidden == true -- 633
				local ____temp_3 -- 634
				if s.breakable == nil then -- 634
					____temp_3 = nil -- 634
				else -- 634
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 634
				end -- 634
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 629
					x0 = ____s_x_4, -- 630
					x1 = ____temp_5, -- 630
					y0 = ____s_y_6, -- 630
					y1 = ____temp_7, -- 630
					depth = ____temp_2, -- 631
					passable = ____temp_8, -- 632
					label = ____s_label_9, -- 632
					id = ____s_id_10, -- 633
					soft = ____temp_11, -- 633
					hidden = ____temp_12, -- 633
					breakable = ____temp_3, -- 634
					interact = s.interact -- 635
				} -- 635
			end -- 635
			i = i + 1 -- 622
		end -- 622
	end -- 622
	do -- 622
		i = 0 -- 639
		while i < #room.stairs do -- 639
			local st = room.stairs[i + 1] -- 640
			local n = st.steps + 1 -- 641
			local stepW = (st.x1 - st.x0) / n -- 642
			local k = 0 -- 643
			do -- 643
				k = 0 -- 644
				while k < n do -- 644
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 645
					local x0 = st.x0 + stepW * k -- 646
					local ____self_boxes_14 = self.boxes -- 646
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 648
						x0 = x0, -- 648
						x1 = x0 + stepW, -- 648
						y0 = -8, -- 648
						y1 = y, -- 648
						passable = true -- 648
					} -- 648
					k = k + 1 -- 644
				end -- 644
			end -- 644
			i = i + 1 -- 639
		end -- 639
	end -- 639
end -- 613
function Play.prototype.setupCampaign(self) -- 657
	local wr = self.room -- 658
	local c = wr.campaign -- 659
	if c == nil then -- 659
		return -- 661
	end -- 661
	self.roomStartTick = self.run.ticks -- 663
	if wr.key == "s1-crossroad" then -- 663
		self.run.joined = true -- 666
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 666
		local ____self_run_16 = self.run -- 669
		local ____temp_15 -- 669
		if wr.key == "s2-drygoods" then -- 669
			____temp_15 = self.run.route ~= "drygoods" -- 669
		else -- 669
			____temp_15 = false -- 669
		end -- 669
		____self_run_16.joined = ____temp_15 -- 669
	end -- 669
	local x = wr.minX + 60 -- 671
	local y = 0 -- 672
	local depth = 0 -- 673
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 673
		x = wr.minX + 210 -- 675
		depth = -32 -- 676
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 676
		x = wr.minX + 40 -- 678
		y = 32 -- 679
		depth = 32 -- 680
	end -- 680
	self.player = { -- 682
		x = x, -- 683
		y = y, -- 683
		depth = depth, -- 683
		depthSpeed = 0, -- 683
		vx = 0, -- 683
		vy = 0, -- 683
		w = SOLDIER_W, -- 684
		h = SOLDIER_H, -- 684
		onGround = y <= 0, -- 684
		facing = 1, -- 684
		crouch = false, -- 684
		rollT = 0, -- 684
		covered = false, -- 684
		alive = true -- 684
	} -- 684
	self.partner = { -- 686
		x = x + 60, -- 687
		y = y, -- 687
		depth = depth, -- 687
		depthSpeed = 0, -- 687
		vx = 0, -- 687
		vy = 0, -- 687
		w = CHILD_W, -- 688
		h = CHILD_H, -- 688
		onGround = y <= 0, -- 688
		facing = 1, -- 688
		crouch = false, -- 688
		rollT = 0, -- 688
		covered = false, -- 688
		alive = true -- 688
	} -- 688
	self.cam.x = x -- 690
	self.cam.y = y + CAM_LOOK_UP -- 691
	self.phase = "run" -- 692
	self.hp = self.maxHp -- 693
	local trial = self.run.trial -- 694
	if trial ~= nil then -- 694
		draftRoom(trial, wr.key) -- 696
		self.maxHp = self.maxHp + trial.ranks.vitality -- 697
		self.hp = trial.hp -- 698
	end -- 698
	self:buildEnemies() -- 700
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 701
	local i = 0 -- 702
	do -- 702
		i = 0 -- 703
		while i < #self.boxes do -- 703
			do -- 703
				local b = self.boxes[i + 1] -- 704
				if b.id == nil then -- 704
					goto __continue48 -- 706
				end -- 706
				local st = self.run.props[b.id] -- 708
				if st ~= nil then -- 708
					b.broken = st.broken -- 710
					local ____temp_17 -- 711
					if b.breakable == nil then -- 711
						____temp_17 = nil -- 711
					else -- 711
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 711
					end -- 711
					b.breakable = ____temp_17 -- 711
					b.hidden = b.hidden == true and st.revealed ~= true -- 712
					if b.hidden then -- 712
						b.broken = true -- 714
					end -- 714
				elseif b.hidden == true then -- 714
					b.broken = true -- 718
				end -- 718
			end -- 718
			::__continue48:: -- 718
			i = i + 1 -- 703
		end -- 703
	end -- 703
	if wr.cart.bodyW > 0 then -- 703
		self.cartAxle = wr.cart.startX -- 722
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 722
			self.cartAxle = wr.cart.endX -- 724
			self.cartDocked = true -- 725
		end -- 725
	end -- 725
	do -- 725
		i = 0 -- 728
		while i < #self.pickups do -- 728
			local pk = self.pickups[i + 1] -- 729
			if self.run.taken[pk.id] == true then -- 729
				pk.id = "" -- 731
			end -- 731
			i = i + 1 -- 728
		end -- 728
	end -- 728
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 734
end -- 657
function Play.prototype.log(self, line) -- 737
	local ____self_run_log_18 = self.run.log -- 737
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 738
	if #self.run.log > 120 then -- 738
		table.remove(self.run.log, 1) -- 740
	end -- 740
end -- 737
function Play.prototype.buildEnemies(self) -- 744
	self.enemies = {} -- 745
	if self.isCampaign then -- 745
		local i = 0 -- 747
		do -- 747
			i = 0 -- 748
			while i < #self.room.spawns do -- 748
				local sp = self.room.spawns[i + 1] -- 749
				local kind = sp.kind or "gunner" -- 750
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 751
				local ____self_enemies_19 = self.enemies -- 751
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 752
					x = sp.x, -- 753
					y = sp.y, -- 753
					depth = sp.depth, -- 753
					w = 26, -- 753
					h = sp.h, -- 753
					alive = true, -- 753
					hitT = 0, -- 753
					warnT = 0, -- 753
					fireCd = 40, -- 753
					kind = kind, -- 754
					shieldHp = hp, -- 754
					shieldHpMax = hp, -- 754
					drop = sp.drop or "none", -- 754
					homeX = sp.x, -- 755
					swingT = 0, -- 755
					awake = false, -- 755
					squad = i -- 755
				} -- 755
				i = i + 1 -- 748
			end -- 748
		end -- 748
		return -- 758
	end -- 758
	if self.room.key == "checkpoint" then -- 758
		local ____self_enemies_20 = self.enemies -- 758
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 761
			x = self.ox + 430, -- 761
			y = 0, -- 761
			w = 26, -- 761
			h = 84, -- 761
			alive = true, -- 761
			hitT = 0, -- 761
			warnT = 0, -- 761
			fireCd = 0 -- 761
		} -- 761
		local ____self_enemies_21 = self.enemies -- 761
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 762
			x = self.ox + 505, -- 762
			y = 0, -- 762
			w = 26, -- 762
			h = 84, -- 762
			alive = true, -- 762
			hitT = 0, -- 762
			warnT = 0, -- 762
			fireCd = 0 -- 762
		} -- 762
		return -- 763
	end -- 763
	if self.room.key == "street" then -- 763
		local ____self_enemies_22 = self.enemies -- 763
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 767
			x = self.ox + 340, -- 767
			y = 0, -- 767
			w = 26, -- 767
			h = 84, -- 767
			alive = true, -- 767
			hitT = 0, -- 767
			warnT = 0, -- 767
			fireCd = 0 -- 767
		} -- 767
		local ____self_enemies_23 = self.enemies -- 767
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 768
			x = self.ox + 560, -- 768
			y = 0, -- 768
			w = 26, -- 768
			h = 84, -- 768
			alive = true, -- 768
			hitT = 0, -- 768
			warnT = 0, -- 768
			fireCd = 0 -- 768
		} -- 768
	end -- 768
end -- 744
function Play.prototype.emit(self, name, data) -- 774
	local ____self_events_24 = self.events -- 774
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 775
	self.eventSeq = self.eventSeq + 1 -- 776
	if #self.events > 256 then -- 776
		table.remove(self.events, 1) -- 778
	end -- 778
end -- 774
function Play.prototype.drainEvents(self) -- 786
	local out = self.events -- 787
	self.events = {} -- 788
	return out -- 789
end -- 786
function Play.prototype.adoptEvents(self, events) -- 798
	if #events == 0 then -- 798
		return -- 800
	end -- 800
	local keep = {} -- 802
	local i = 0 -- 803
	do -- 803
		i = 0 -- 804
		while i < #events do -- 804
			do -- 804
				local e = events[i + 1] -- 805
				if e.name == "knock" and e.data.room ~= self.room.key then -- 805
					goto __continue72 -- 807
				end -- 807
				keep[#keep + 1] = e -- 809
			end -- 809
			::__continue72:: -- 809
			i = i + 1 -- 804
		end -- 804
	end -- 804
	if #keep == 0 then -- 804
		return -- 812
	end -- 812
	self.events = __TS__ArrayConcat(keep, self.events) -- 814
	do -- 814
		i = 0 -- 815
		while i < #self.events do -- 815
			self.events[i + 1].seq = i -- 816
			i = i + 1 -- 815
		end -- 815
	end -- 815
	self.eventSeq = #self.events -- 818
end -- 798
function Play.prototype.chooseTalent(self, slot) -- 821
	local trial = self.run.trial -- 822
	local talent = trial and trial.offers[slot + 1] -- 823
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 823
		return -- 824
	end -- 824
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 824
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 825
	trial.offers = {} -- 826
	if talent == "vitality" then -- 826
		self.maxHp = self.maxHp + 1 -- 828
		self.hp = self.hp + 1 -- 829
		trial.hp = self.hp -- 830
	end -- 830
	self:flashSet(talentNames[talent], 1.2) -- 832
end -- 821
function Play.prototype.reloadTicks(self) -- 835
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 836
	local ____opt_29 = self.run.trial -- 836
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 836
end -- 835
function Play.prototype.update(self, dt, input) -- 839
	local trial = self.run.trial -- 840
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 840
		return -- 841
	end -- 841
	if input.pause.pressed then -- 841
		self.paused = not self.paused -- 843
	end -- 843
	if self.flashT > 0 then -- 843
		self.flashT = self.flashT - dt -- 846
		if self.flashT <= 0 then -- 846
			self.flash = "" -- 848
		end -- 848
	end -- 848
	if self.traceT > 0 then -- 848
		self.traceT = self.traceT - dt -- 852
		if self.traceT <= 0 then -- 852
			self.trace = nil -- 854
		end -- 854
	end -- 854
	if self.paused then -- 854
		self:updateCamera(dt) -- 858
		return -- 859
	end -- 859
	self.ticks = self.ticks + 1 -- 862
	if self.invulnT > 0 then -- 862
		self.invulnT = self.invulnT - 1 -- 866
	end -- 866
	if self.isCampaign then -- 866
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 866
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 869
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 870
	end -- 870
	local p = self.player -- 872
	self:stepPlayer(p, dt, input) -- 873
	self:refreshCover(p, input) -- 875
	if self.isCampaign then -- 875
		self:stepCampaign(dt, input) -- 877
		self:stepCampaignPartner(dt) -- 878
	end -- 878
	if trial == nil or not self.run.finished then -- 878
		self:stepEnemies(dt, input) -- 881
	end -- 881
	if trial ~= nil then -- 881
		trial.hp = self.hp -- 882
	end -- 882
	if not self.isCampaign then -- 882
		self:stepStory(dt, input) -- 884
		self:stepEscort(dt, input) -- 885
		self:stepVillage(dt, input) -- 886
		self:stepChase(dt, input) -- 887
		self:stepInteract(dt, input) -- 888
	end -- 888
	self:updateGate() -- 890
	self:updateCamera(dt) -- 891
	self:syncStory() -- 893
end -- 839
function Play.prototype.underLowArch(self, a) -- 900
	local arch = self.room.arch -- 901
	if arch.h <= 0 then -- 901
		return false -- 903
	end -- 903
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 903
		return false -- 906
	end -- 906
	local top = arch.y + arch.h -- 908
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 909
end -- 900
function Play.prototype.coverAt(self, a) -- 916
	local best = nil -- 917
	local bestGap = 24 -- 918
	local half = a.w / 2 -- 919
	local i = 0 -- 920
	do -- 920
		i = 0 -- 921
		while i < #self.boxes do -- 921
			do -- 921
				local b = self.boxes[i + 1] -- 922
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 922
					goto __continue100 -- 924
				end -- 924
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 924
					goto __continue100 -- 927
				end -- 927
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 929
				if gap < bestGap then -- 929
					bestGap = gap -- 931
					best = b -- 932
				end -- 932
			end -- 932
			::__continue100:: -- 932
			i = i + 1 -- 921
		end -- 921
	end -- 921
	return best -- 935
end -- 916
function Play.prototype.nearCover(self, a) -- 938
	return self:coverAt(a) ~= nil -- 939
end -- 938
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 943
	if enemy == nil then -- 943
		return false -- 945
	end -- 945
	local fromRight = enemy.x >= a.x -- 947
	local edge = fromRight and b.x0 or b.x1 -- 948
	local ____fromRight_34 -- 949
	if fromRight then -- 949
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 949
	else -- 949
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 950
	end -- 950
	local between = ____fromRight_34 -- 949
	local separation = enemy.x - a.x -- 951
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 952
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 953
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 954
end -- 943
function Play.prototype.nearestEnemy(self, a) -- 957
	local best -- 958
	local bestD = 1000000000 -- 959
	local i = 0 -- 960
	do -- 960
		i = 0 -- 961
		while i < #self.enemies do -- 961
			do -- 961
				local e = self.enemies[i + 1] -- 962
				if not e.alive then -- 962
					goto __continue109 -- 964
				end -- 964
				local d = math.abs(e.x - a.x) -- 966
				if d < bestD then -- 966
					bestD = d -- 968
					best = e -- 969
				end -- 969
			end -- 969
			::__continue109:: -- 969
			i = i + 1 -- 961
		end -- 961
	end -- 961
	return best -- 972
end -- 957
function Play.prototype.refreshCover(self, a, input) -- 976
	if self.childMode then -- 976
		self.coverNear = false -- 978
		self.coverHug = false -- 979
		self.coverEntity = "" -- 980
		self.coverBlocking = false -- 981
		a.covered = false -- 982
		return -- 983
	end -- 983
	local b = self:coverAt(a) -- 985
	self.coverNear = b ~= nil -- 986
	a.covered = self.coverNear and input.cover.held -- 987
	self.coverHug = a.covered -- 988
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 989
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 990
		b, -- 990
		a, -- 990
		self:nearestEnemy(a) -- 990
	) -- 990
end -- 976
function Play.prototype.cartHandleInReach(self, a) -- 994
	if a == nil then -- 994
		a = self.player -- 994
	end -- 994
	local c = self.room.cart -- 995
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 995
		return false -- 997
	end -- 997
	local handleX = self.cartAxle + c.handleOffset -- 999
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1000
end -- 994
function Play.prototype.nearLowLedge(self, a) -- 1005
	local reach = 26 -- 1006
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1007
	local x1 = x0 + reach -- 1008
	local i = 0 -- 1009
	do -- 1009
		i = 0 -- 1010
		while i < #self.boxes do -- 1010
			do -- 1010
				local b = self.boxes[i + 1] -- 1011
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1011
					goto __continue118 -- 1013
				end -- 1013
				local rise = b.y1 - a.y -- 1015
				if rise > 0 and rise <= LEDGE_RISE then -- 1015
					return true -- 1017
				end -- 1017
			end -- 1017
			::__continue118:: -- 1017
			i = i + 1 -- 1010
		end -- 1010
	end -- 1010
	return false -- 1020
end -- 1005
function Play.prototype.stepPlayer(self, a, dt, input) -- 1023
	a.depthSpeed = 0 -- 1024
	if not a.alive then -- 1024
		return -- 1026
	end -- 1026
	local isChild = self.childMode -- 1028
	local lowArch = isChild and self:underLowArch(a) -- 1030
	if self:storyLocked() then -- 1030
		a.vx = 0 -- 1033
		a.crouch = isChild and lowArch -- 1034
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1035
		self:fallY(a, dt) -- 1036
		return -- 1037
	end -- 1037
	if not isChild and self.escort.state == "calming" then -- 1037
		a.crouch = false -- 1041
		a.h = SOLDIER_H -- 1042
		a.vx = 0 -- 1043
		self:fallY(a, dt) -- 1044
		return -- 1045
	end -- 1045
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1047
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1048
	local nearCover = not isChild and self:nearCover(a) -- 1049
	a.covered = nearCover and input.cover.held -- 1050
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1052
	if a.rollT > 0 then -- 1052
		a.rollT = a.rollT - dt -- 1056
		a.vx = a.facing * ROLL_SPEED -- 1057
		self:slideX(a, a.vx * dt) -- 1058
		self:fallY(a, dt) -- 1059
		if a.rollT <= 0 then -- 1059
			self:flashSet("翻滚结束", 0.5) -- 1061
		end -- 1061
		return -- 1063
	end -- 1063
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1063
		if input.moveX ~= 0 then -- 1063
			a.facing = input.moveX > 0 and 1 or -1 -- 1068
		end -- 1068
		if self:nearLowLedge(a) then -- 1068
			a.vy = SOLDIER_JUMP -- 1072
			a.onGround = false -- 1073
			self:flashSet("翻上去", 0.3) -- 1074
			return -- 1075
		end -- 1075
		a.rollT = ROLL_TIME -- 1077
		self:flashSet("翻滚", 0.3) -- 1078
		return -- 1079
	end -- 1079
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1082
	if isChild then -- 1082
		if input.cover.held then -- 1082
			speed = CHILD_SLOW -- 1085
		end -- 1085
		if a.crouch then -- 1085
			speed = CHILD_SLOW -- 1088
		end -- 1088
	elseif a.covered then -- 1088
		speed = SOLDIER_SPEED * 0.45 -- 1091
	end -- 1091
	local handsBusy = self.gripping or gripIntent -- 1095
	local dir = self.gripping and 0 or input.moveX -- 1096
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1097
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1098
	if dir ~= 0 then -- 1098
		a.facing = dir > 0 and 1 or -1 -- 1100
	end -- 1100
	a.vx = dir * speed * diagonal -- 1102
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1102
		a.vy = CHILD_JUMP -- 1106
		a.onGround = false -- 1107
		self:flashSet("跳", 0.25) -- 1108
	end -- 1108
	local previousDepth = a.depth -- 1112
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1113
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1114
	self:slideX(a, a.vx * dt) -- 1115
	self:fallY(a, dt) -- 1116
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1116
		self:shoot(a) -- 1120
	end -- 1120
end -- 1023
function Play.prototype.stepPartner(self, p, dt) -- 1125
	local a = self.partner -- 1126
	if not a.alive then -- 1126
		return -- 1128
	end -- 1128
	a.crouch = false -- 1130
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1131
	a.vx = 0 -- 1132
	a.depthSpeed = 0 -- 1133
	self:fallY(a, dt) -- 1134
end -- 1125
function Play.prototype.stepEscort(self, dt, input) -- 1141
	local a = self.partner -- 1142
	a.depthSpeed = 0 -- 1143
	if not a.alive then -- 1143
		return -- 1145
	end -- 1145
	if self.room.key == "gatepath" then -- 1145
		local p = self.player -- 1149
		a.depth = p.depth -- 1150
		a.facing = p.facing -- 1151
		a.crouch = false -- 1152
		a.h = CHILD_H -- 1153
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1154
		a.y = p.y -- 1155
		a.vy = 0 -- 1156
		a.vx = p.vx -- 1157
		a.onGround = p.onGround -- 1158
		return -- 1159
	end -- 1159
	if not self:escortOn() then -- 1159
		a.vx = 0 -- 1162
		self:fallY(a, dt) -- 1163
		return -- 1164
	end -- 1164
	local p = self.player -- 1166
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1167
	local hadKnock1 = self.escort.knock1 -- 1168
	local hadKnock2 = self.escort.knock2 -- 1169
	self.calmConsumed = self.escort:update( -- 1170
		input, -- 1170
		p.x, -- 1170
		p.facing, -- 1170
		a.x, -- 1170
		dist -- 1170
	) -- 1170
	if not hadKnock1 and self.escort.knock1 then -- 1170
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1173
	end -- 1173
	if not hadKnock2 and self.escort.knock2 then -- 1173
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1176
	end -- 1176
	a.crouch = self.escort.crouchPose -- 1178
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1179
	if not self.escort.stopped then -- 1179
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1181
		local previousDepth = a.depth -- 1182
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1183
		local distance = math.max( -- 1184
			-travel, -- 1184
			math.min(travel, targetDepth - previousDepth) -- 1184
		) -- 1184
		self:slideDepth(a, distance) -- 1185
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1186
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1186
			a.vy = CHILD_JUMP -- 1188
			a.onGround = false -- 1189
		end -- 1189
	end -- 1189
	local dir = self.escort:moveDir(a.x) -- 1192
	a.vx = dir * CHILD_SPEED -- 1193
	if dir ~= 0 then -- 1193
		a.facing = dir -- 1195
		local before = a.x -- 1196
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1197
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1197
			a.vy = CHILD_JUMP -- 1200
			a.onGround = false -- 1201
		end -- 1201
	end -- 1201
	self:fallY(a, dt) -- 1204
end -- 1141
function Play.prototype.escortOn(self) -- 1208
	if self.room.key == "checkpoint" then -- 1208
		return true -- 1210
	end -- 1210
	if self.room.key == "gatepath" then -- 1210
		return true -- 1213
	end -- 1213
	if self.room.key == "prologue" then -- 1213
		return self.phase == "prologue-follow" -- 1216
	end -- 1216
	return self.room.key == "street" -- 1218
end -- 1208
function Play.prototype.storyLocked(self) -- 1222
	if self.caughtT > 0 then -- 1222
		return true -- 1224
	end -- 1224
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1224
		return true -- 1227
	end -- 1227
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1227
		return true -- 1230
	end -- 1230
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1230
		return true -- 1233
	end -- 1233
	return false -- 1235
end -- 1222
function Play.prototype.swapToChild(self, x) -- 1239
	local tmp = self.player -- 1240
	self.player = self.partner -- 1241
	self.partner = tmp -- 1242
	self.childMode = true -- 1243
	self.player.alive = true -- 1244
	self.player.x = self.ox + x -- 1245
	self.player.y = 0 -- 1246
	self.player.depth = 0 -- 1247
	self.player.depthSpeed = 0 -- 1248
	self.player.vy = 0 -- 1249
	self.player.vx = 0 -- 1250
	self.player.onGround = true -- 1251
	self.player.crouch = false -- 1252
	self.player.h = CHILD_H -- 1253
	self.player.facing = 1 -- 1254
	self.partner.alive = true -- 1255
	self.cam.x = self.player.x -- 1256
end -- 1239
function Play.prototype.stepStory(self, dt, input) -- 1260
	if self.room.key == "prologue" then -- 1260
		self:stepPrologue(dt, input) -- 1262
	elseif self.room.key == "street" then -- 1262
		self:stepStreet(dt, input) -- 1264
	elseif self.room.key == "gate" then -- 1264
		self:stepGate(dt, input) -- 1266
	elseif self.room.key == "gatepath" then -- 1266
		self:stepGatePath() -- 1268
	elseif self.room.key == "tower" then -- 1268
		self:stepTower(dt, input) -- 1270
	end -- 1270
end -- 1260
function Play.prototype.stepPrologue(self, dt, input) -- 1275
	local child = self.partner -- 1276
	if self.phase == "prologue-wait" then -- 1276
		child.crouch = true -- 1278
		child.h = CHILD_CROUCH_H -- 1279
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1280
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1282
		if near and input.interact.pressed then -- 1282
			self.phase = "prologue-give" -- 1284
			self.phaseTick = 0 -- 1285
			self:flashSet("递出针套", 1) -- 1286
		end -- 1286
		return -- 1288
	end -- 1288
	if self.phase == "prologue-give" then -- 1288
		self.phaseTick = self.phaseTick + 1 -- 1291
		if self.phaseTick == 12 then -- 1291
			self:flashSet("针套递过去", 0.7) -- 1293
		elseif self.phaseTick == 36 then -- 1293
			self:flashSet("纸条塞进针套", 0.9) -- 1295
		elseif self.phaseTick >= 60 then -- 1295
			self.phase = "prologue-follow" -- 1297
			self.phaseTick = 0 -- 1298
			child.crouch = false -- 1299
			child.h = CHILD_H -- 1300
			self:flashSet("她跟上了", 1.2) -- 1301
		end -- 1301
		return -- 1303
	end -- 1303
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1303
		self:requestRoom("street", "序章跟到门口") -- 1307
		self:flashSet("进街道", 1.2) -- 1308
	end -- 1308
end -- 1275
function Play.prototype.stepStreet(self, dt, input) -- 1313
	local p = self.player -- 1314
	local c = self.partner -- 1315
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1315
		self:requestRoom("checkpoint", "两人都到街尾") -- 1317
		self:flashSet("到检查站", 1.2) -- 1318
	end -- 1318
end -- 1313
function Play.prototype.stepGate(self, dt, input) -- 1323
	local ____temp_35 -- 1324
	if self.room.story == nil then -- 1324
		____temp_35 = nil -- 1324
	else -- 1324
		____temp_35 = self.room.story.gate -- 1324
	end -- 1324
	local g = ____temp_35 -- 1324
	if g == nil then -- 1324
		return -- 1326
	end -- 1326
	local p = self.player -- 1328
	if self.phase == "gate-idle" then -- 1328
		local a = self.partner -- 1331
		local gap = g.waitX - a.x -- 1332
		if math.abs(gap) > 3 then -- 1332
			a.facing = gap > 0 and 1 or -1 -- 1334
			a.vx = a.facing * CHILD_SPEED -- 1335
			local beforeX = a.x -- 1336
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1337
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1337
				a.vy = CHILD_JUMP -- 1339
				a.onGround = false -- 1340
			end -- 1340
			self:fallY(a, dt) -- 1342
		else -- 1342
			a.vx = 0 -- 1344
			a.x = g.waitX -- 1345
		end -- 1345
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1348
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1349
		if self.gateNeedConfirm then -- 1349
			if not input.interact.held then -- 1349
				self.gateRestartArmed = true -- 1354
			end -- 1354
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1354
				self.gateNeedConfirm = false -- 1357
				self.gateRestartArmed = true -- 1358
				self.phase = "gate-hold" -- 1359
				self.gateTick = 0 -- 1360
				self.gateSpawned = 0 -- 1361
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1362
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1363
			end -- 1363
			return -- 1365
		end -- 1365
		if atWinch and atWait then -- 1365
			self.phase = "gate-hold" -- 1368
			self.gateTick = 0 -- 1369
			self.gateSpawned = 0 -- 1370
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1371
		end -- 1371
		return -- 1373
	end -- 1373
	if self.phase == "gate-hold" then -- 1373
		self.gateTick = self.gateTick + 1 -- 1376
		local marks = {0, 540, 900, 1500} -- 1378
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1378
			local idx = self.gateSpawned -- 1380
			local ____self_enemies_36 = self.enemies -- 1380
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 1381
				x = self.ox + 620 + idx * 62, -- 1382
				y = 0, -- 1382
				w = 26, -- 1382
				h = 84, -- 1382
				alive = true, -- 1383
				hitT = 0, -- 1383
				warnT = 0, -- 1383
				fireCd = 90 + idx * 45 -- 1383
			} -- 1383
			self.gateSpawned = self.gateSpawned + 1 -- 1385
			self:flashSet( -- 1386
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1386
				0.9 -- 1386
			) -- 1386
		end -- 1386
		if self.gateTick == 900 then -- 1386
			self:flashSet("灯灭了", 1) -- 1389
		elseif self.gateTick == 2100 then -- 1389
			self:flashSet("门底压下来了", 1) -- 1391
		end -- 1391
		if self.gateTick >= g.holdTicks then -- 1391
			self:settleRoute() -- 1395
			self.phase = "gate-send" -- 1396
			self.phaseTick = 0 -- 1397
			self.enemies = {} -- 1399
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1400
		end -- 1400
		return -- 1402
	end -- 1402
	if self.phase == "gate-send" then -- 1402
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1405
		if near and input.interact.pressed then -- 1405
			self:swapToChild(g.doorX + 30) -- 1407
			self.phase = "gate-count" -- 1408
			self.countTick = 0 -- 1409
			self.countArmed = false -- 1411
			self.countPrevMove = input.moveX -- 1412
			self:flashSet("门开了 · 送她出去", 1.8) -- 1413
		end -- 1413
		return -- 1415
	end -- 1415
	if self.phase == "gate-count" then -- 1415
		self.countTick = self.countTick + 1 -- 1418
		if self.countTick == 360 then -- 1418
			self:flashSet("门关上", 0.9) -- 1420
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 1420
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 1422
			if self.storyRoute == "soldier" then -- 1422
				self.phase = "gate-wait" -- 1428
				self.phaseTick = 0 -- 1429
				self.knocks = 1 -- 1430
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 1431
				self.handArmed = not input.interact.held -- 1433
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 1434
			else -- 1434
				self:flashSet("数到二十", 2.2) -- 1436
			end -- 1436
		end -- 1436
		local prevMove = self.countPrevMove -- 1441
		self.countPrevMove = input.moveX -- 1442
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 1442
			if prevMove <= 0 and input.moveX > 0 then -- 1442
				self.countArmed = true -- 1445
			end -- 1445
			if self.countArmed and input.moveX > 0 then -- 1445
				self.phase = "gate-walk" -- 1448
				self.phaseTick = 0 -- 1449
				self:flashSet("她迈出第一步", 1.4) -- 1450
				self:emit("storyExit", { -- 1451
					route = "child", -- 1451
					via = "walk", -- 1451
					countTick = self.countTick, -- 1451
					hp = self.hp, -- 1451
					maxHp = self.maxHp -- 1451
				}) -- 1451
			end -- 1451
		end -- 1451
		return -- 1454
	end -- 1454
	if self.phase == "gate-wait" then -- 1454
		self.phaseTick = self.phaseTick + 1 -- 1458
		if self.phaseTick == 12 then -- 1458
			self.knocks = 2 -- 1460
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 1461
			self:flashSet("第二下 · 她抬手了", 1.6) -- 1462
		end -- 1462
		if not input.interact.held then -- 1462
			if self.handTicks > 0 then -- 1462
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1466
			end -- 1466
			self.handTicks = 0 -- 1468
			self.handArmed = true -- 1469
			return -- 1470
		end -- 1470
		if self.handArmed then -- 1470
			self.handTicks = self.handTicks + 1 -- 1473
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 1473
				self.phase = "gate-hand" -- 1475
				self.phaseTick = 0 -- 1476
				self.handDone = true -- 1477
				self.tied = true -- 1478
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1479
				if not self.lineSaid then -- 1479
					self.lineSaid = true -- 1481
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 1482
				end -- 1482
				self:flashSet("我们走吧。", 3) -- 1484
			end -- 1484
		end -- 1484
		return -- 1487
	end -- 1487
	if self.phase == "gate-hand" then -- 1487
		self.phaseTick = self.phaseTick + 1 -- 1491
		if self.phaseTick == 30 then -- 1491
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 1493
		elseif self.phaseTick >= 90 then -- 1493
			self:emit("storyExit", { -- 1495
				route = "soldier", -- 1495
				via = "hand", -- 1495
				handTicks = self.handTicks, -- 1495
				hp = self.hp, -- 1495
				maxHp = self.maxHp -- 1495
			}) -- 1495
			self:requestRoom("gatepath", "牵手同行") -- 1496
		end -- 1496
		return -- 1498
	end -- 1498
	if self.phase == "gate-walk" then -- 1498
		if self.player.x >= g.exitX then -- 1498
			self:requestRoom("outside", "走出城门") -- 1503
			self:flashSet("出城门 · 城外", 1.4) -- 1504
		end -- 1504
	end -- 1504
end -- 1323
function Play.prototype.settleRoute(self) -- 1510
	if self.storySettled then -- 1510
		return -- 1512
	end -- 1512
	local maxHp = self.maxHp > 0 and self.maxHp or 1 -- 1514
	self.hpAtGate = self.hp -- 1515
	self.maxHpAtGate = self.maxHp -- 1516
	self.storyRoute = 100 * self.hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 1517
	self.storySettled = true -- 1518
	self:emit("storyRouteLocked", { -- 1519
		route = self.storyRoute, -- 1520
		hp = self.hp, -- 1520
		maxHp = self.maxHp, -- 1520
		hpAtGate = self.hpAtGate, -- 1521
		maxHpAtGate = self.maxHpAtGate -- 1521
	}) -- 1521
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 1523
end -- 1510
function Play.prototype.syncStory(self) -- 1527
	if self.isCampaign then -- 1527
		return -- 1529
	end -- 1529
	local s = self.run.story -- 1531
	if s == nil then -- 1531
		return -- 1533
	end -- 1533
	s.hp = self.hp -- 1535
	s.maxHp = self.maxHp -- 1536
	s.route = self.storyRoute -- 1537
	s.settled = self.storySettled -- 1538
	s.hpAtGate = self.hpAtGate -- 1539
	s.maxHpAtGate = self.maxHpAtGate -- 1540
	s.handDone = self.handDone -- 1541
	s.lineSaid = self.lineSaid -- 1542
	s.tied = self.tied -- 1543
	if self.room.key == "gate" then -- 1543
		s.phase = self.phase -- 1545
		s.countTick = self.countTick -- 1546
		s.phaseTick = self.phaseTick -- 1547
		s.handTicks = self.handTicks -- 1548
	end -- 1548
end -- 1527
function Play.prototype.stepGatePath(self) -- 1553
	if self.phase == "gatepath-start" then -- 1553
		if self.player.x >= self.ox + 840 and self.player.onGround then -- 1553
			self.phase = "gatepath-stair" -- 1556
			self.phaseTick = 0 -- 1557
			self.pathDone = true -- 1558
			self:flashSet("高石阶 · 下一段入口", 2.6) -- 1559
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 1560
		end -- 1560
		return -- 1562
	end -- 1562
	if self.phase == "gatepath-stair" then -- 1562
		self.phaseTick = self.phaseTick + 1 -- 1565
		if self.phaseTick >= 30 then -- 1565
			self:requestRoom("outside", "同行段收尾") -- 1567
		end -- 1567
	end -- 1567
end -- 1553
function Play.prototype.stepTower(self, dt, input) -- 1573
	local ____temp_37 -- 1574
	if self.room.story == nil then -- 1574
		____temp_37 = nil -- 1574
	else -- 1574
		____temp_37 = self.room.story.tower -- 1574
	end -- 1574
	local t = ____temp_37 -- 1574
	if t == nil then -- 1574
		return -- 1576
	end -- 1576
	if self.phase == "tower-wait" then -- 1576
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1579
		if near and input.interact.pressed then -- 1579
			self.phase = "tower-knock" -- 1581
			self.phaseTick = 0 -- 1582
			self.knocks = 1 -- 1583
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1584
			self:flashSet("敲一下", 0.6) -- 1585
		end -- 1585
		return -- 1587
	end -- 1587
	if self.phase == "tower-knock" then -- 1587
		self.phaseTick = self.phaseTick + 1 -- 1590
		if self.phaseTick == 12 then -- 1590
			self.knocks = 2 -- 1592
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1593
			self:flashSet("敲两下 · 第二声", 1) -- 1594
		elseif self.phaseTick >= t.knockTicks then -- 1594
			self.phase = "tower-given" -- 1596
			self.phaseTick = 0 -- 1597
			self:flashSet("门开了 · 提灯", 1.4) -- 1598
		end -- 1598
		return -- 1600
	end -- 1600
	if self.phase == "tower-given" then -- 1600
		self.phaseTick = self.phaseTick + 1 -- 1603
		if self.phaseTick == 60 then -- 1603
			self:flashSet("她递出针套和纸条", 1.6) -- 1605
		elseif self.phaseTick == 120 then -- 1605
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1607
		elseif self.phaseTick >= 180 then -- 1607
			self.phase = "tower-end" -- 1609
			self.phaseTick = 0 -- 1610
			self:flashSet("片尾 · E 再玩一次", 3) -- 1611
		end -- 1611
		return -- 1613
	end -- 1613
	if input.interact.pressed or input.retry.pressed then -- 1613
		self:requestRoom("prologue", "片尾再玩") -- 1616
		self:flashSet("回到序章", 1.4) -- 1617
	end -- 1617
end -- 1573
function Play.prototype.stepChase(self, dt, input) -- 1622
	if self.caughtT > 0 then -- 1622
		self.caughtT = self.caughtT - dt -- 1624
		if self.caughtT <= 0 then -- 1624
			self:recoverFromCaught() -- 1626
		end -- 1626
		return -- 1628
	end -- 1628
	if self.room.key == "village" then -- 1628
		self:stepScavChase() -- 1631
	elseif self.room.key == "forest" then -- 1631
		self:stepDog(dt) -- 1633
		if self.player.x >= self.ox + 1450 then -- 1633
			self:requestRoom("tower", "到林缘北塔") -- 1636
			self:flashSet("林缘 · 北塔", 1.4) -- 1637
		end -- 1637
	end -- 1637
end -- 1622
function Play.prototype.stepScavChase(self) -- 1643
	local s = self.room.scavenger -- 1644
	if s == nil then -- 1644
		return -- 1646
	end -- 1646
	local p = self.player -- 1648
	if self.passed and p.x > self.ox + 440 then -- 1648
		if self.scavChase then -- 1648
			self.scavChase = false -- 1652
			self.scavState = "back" -- 1653
			self.scavT = 0 -- 1654
		end -- 1654
		return -- 1656
	end -- 1656
	local dx = p.x - self.scavX -- 1658
	local dist = math.abs(dx) -- 1659
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1660
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1661
	if not self.scavChase then -- 1661
		if visible then -- 1661
			self.scavSee = self.scavSee + 1 -- 1664
			if self.scavSee >= 24 then -- 1664
				self.scavChase = true -- 1666
				self.scavState = "chase" -- 1667
				self.scavTargetX = p.x -- 1668
				self:flashSet("他看见你了", 1.2) -- 1669
			end -- 1669
		else -- 1669
			self.scavSee = 0 -- 1672
		end -- 1672
		return -- 1674
	end -- 1674
	local dir = p.x > self.scavX and 1 or -1 -- 1677
	self.scavX = self.scavX + dir * 96 / 60 -- 1678
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1678
		self:caught() -- 1680
		return -- 1681
	end -- 1681
	if hidden then -- 1681
		self.scavSee = 0 -- 1685
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1686
		self.scavT = self.scavT - 1 -- 1687
		if self.scavT <= 0 then -- 1687
			self.scavChase = false -- 1689
			self.scavState = "patrol" -- 1690
			self:flashSet("他失去了目标", 1) -- 1691
		end -- 1691
	end -- 1691
end -- 1643
function Play.prototype.stepDog(self, dt) -- 1697
	local ____temp_38 -- 1698
	if self.room.story == nil then -- 1698
		____temp_38 = nil -- 1698
	else -- 1698
		____temp_38 = self.room.story.dog -- 1698
	end -- 1698
	local dog = ____temp_38 -- 1698
	if dog == nil then -- 1698
		return -- 1700
	end -- 1700
	local p = self.player -- 1702
	local dist = math.abs(p.x - self.dogX) -- 1703
	if self.dogState == "patrol" then -- 1703
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1705
		if self.dogX < dog.x0 then -- 1705
			self.dogX = dog.x0 -- 1707
			self.dogDir = 1 -- 1708
		elseif self.dogX > dog.x1 then -- 1708
			self.dogX = dog.x1 -- 1710
			self.dogDir = -1 -- 1711
		end -- 1711
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1713
		if not p.crouch and moving and dist < dog.range then -- 1713
			self.dogState = "ear" -- 1715
			self.dogT = 18 -- 1716
			self.dogTargetX = p.x -- 1717
			self:flashSet("狗转耳朵", 0.8) -- 1718
		end -- 1718
		return -- 1720
	end -- 1720
	if self.dogState == "ear" then -- 1720
		self.dogT = self.dogT - 1 -- 1723
		if self.dogT <= 0 then -- 1723
			self.dogState = "chase" -- 1725
			self.dogTargetX = p.x -- 1726
			self:flashSet("狗追来了", 1.4) -- 1727
		end -- 1727
		return -- 1729
	end -- 1729
	if self.dogState == "chase" then -- 1729
		local dir = p.x > self.dogX and 1 or -1 -- 1732
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1733
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1733
			self:caught() -- 1735
			self.dogState = "sniff" -- 1736
			self.dogT = 60 -- 1737
		elseif dist > dog.range * 1.5 or p.crouch then -- 1737
			self.dogState = "sniff" -- 1739
			self.dogT = 60 -- 1740
			self:flashSet("狗停下了", 0.9) -- 1741
		end -- 1741
		return -- 1743
	end -- 1743
	if self.dogState == "sniff" then -- 1743
		self.dogT = self.dogT - 1 -- 1746
		if self.dogT <= 0 then -- 1746
			self.dogState = "back" -- 1748
		end -- 1748
		return -- 1750
	end -- 1750
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1753
	self.dogX = self.dogX + dir * dog.speed * dt -- 1754
	if math.abs(self.dogX - dog.x0) < 2 then -- 1754
		self.dogX = dog.x0 -- 1756
		self.dogState = "patrol" -- 1757
	end -- 1757
end -- 1697
function Play.prototype.caught(self) -- 1761
	self.caughtT = 1 -- 1762
	self:flashSet("被抓 · 回到安全点", 1.6) -- 1763
end -- 1761
function Play.prototype.recoverFromCaught(self) -- 1767
	local p = self.player -- 1768
	p.x = self.ox + 140 -- 1769
	p.y = 0 -- 1770
	p.vy = 0 -- 1771
	p.vx = 0 -- 1772
	p.onGround = true -- 1773
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 1773
		self.scavX = self.room.scavenger.x0 -- 1775
		self.scavState = "patrol" -- 1776
		self.scavSee = 0 -- 1777
		self.scavChase = false -- 1778
		self.scavT = 0 -- 1779
	end -- 1779
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 1779
		self.dogX = self.room.story.dog.x0 -- 1782
		self.dogState = "patrol" -- 1783
		self.dogT = 0 -- 1784
	end -- 1784
	self.cam.x = p.x -- 1786
	self.cam.y = p.y + CAM_LOOK_UP -- 1787
	self:flashSet("回到安全点", 1.2) -- 1788
end -- 1767
function Play.prototype.updateGate(self) -- 1792
	if self.room.key ~= "checkpoint" then -- 1792
		self.gateOpen = false -- 1794
		return -- 1795
	end -- 1795
	local function inZone(x) -- 1797
		return x >= self.ox + 792 and x <= self.ox + 928 -- 1797
	end -- 1797
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 1798
end -- 1792
function Play.prototype.addItem(self, kind) -- 1804
	local inv = self.run.inventory -- 1805
	if kind == "shield" then -- 1805
		if inv.shield >= TOOL_CAP then -- 1805
			return false -- 1808
		end -- 1808
		inv.shield = inv.shield + 1 -- 1810
		return true -- 1811
	end -- 1811
	if kind == "wedge" then -- 1811
		if inv.wedge >= CONSUMABLE_CAP then -- 1811
			return false -- 1815
		end -- 1815
		inv.wedge = inv.wedge + 1 -- 1817
		return true -- 1818
	end -- 1818
	if kind == "ammo" then -- 1818
		if inv.ammo >= CONSUMABLE_CAP then -- 1818
			return false -- 1822
		end -- 1822
		inv.ammo = inv.ammo + 1 -- 1824
		return true -- 1825
	end -- 1825
	if kind == "scrap" then -- 1825
		inv.scrap = inv.scrap + 1 -- 1829
		return true -- 1830
	end -- 1830
	if kind == "pass" then -- 1830
		inv.pass = inv.pass + 1 -- 1833
		return true -- 1834
	end -- 1834
	if kind == "quickbelt" then -- 1834
		inv.quickbelt = inv.quickbelt + 1 -- 1837
		return true -- 1838
	end -- 1838
	return false -- 1840
end -- 1804
function Play.prototype.findBox(self, id) -- 1843
	local i = 0 -- 1844
	do -- 1844
		i = 0 -- 1845
		while i < #self.boxes do -- 1845
			if self.boxes[i + 1].id == id then -- 1845
				return self.boxes[i + 1] -- 1847
			end -- 1847
			i = i + 1 -- 1845
		end -- 1845
	end -- 1845
	return nil -- 1850
end -- 1843
function Play.prototype.findWedgeTarget(self) -- 1854
	local best = nil -- 1855
	local bestD = 0 -- 1856
	local i = 0 -- 1857
	do -- 1857
		i = 0 -- 1858
		while i < #self.boxes do -- 1858
			do -- 1858
				local b = self.boxes[i + 1] -- 1859
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 1859
					goto __continue289 -- 1861
				end -- 1861
				if not self:nearBox(b, 26) then -- 1861
					goto __continue289 -- 1864
				end -- 1864
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 1866
				if best == nil or d < bestD then -- 1866
					best = b -- 1868
					bestD = d -- 1869
				end -- 1869
			end -- 1869
			::__continue289:: -- 1869
			i = i + 1 -- 1858
		end -- 1858
	end -- 1858
	return best -- 1872
end -- 1854
function Play.prototype.stepCraft(self, input) -- 1880
	local inv = self.run.inventory -- 1881
	local ____opt_39 = self.run.trial -- 1881
	local required = CRAFT_TICKS - 6 * (____opt_39 and ____opt_39.ranks.craft or 0) -- 1882
	if self.craftT > 0 then -- 1882
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 1882
			self.craftT = 0 -- 1886
			self:flashSet("制作中断", 0.8) -- 1887
			return true -- 1888
		end -- 1888
		self.craftT = self.craftT + 1 -- 1890
		if self.craftT >= required then -- 1890
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 1890
				inv.scrap = inv.scrap - 1 -- 1893
				inv.wedge = inv.wedge + 1 -- 1894
				self:flashSet("制得木楔", 1.2) -- 1895
				self:log("制木楔") -- 1896
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 1897
			end -- 1897
			self.craftT = 0 -- 1899
		end -- 1899
		return true -- 1901
	end -- 1901
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 1901
		self.craftT = 1 -- 1904
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 1905
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 1906
		return true -- 1907
	end -- 1907
	return false -- 1909
end -- 1880
function Play.prototype.nearBox(self, b, reach) -- 1912
	local p = self.player -- 1913
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 1914
end -- 1912
function Play.prototype.findInteract(self) -- 1920
	local p = self.player -- 1921
	local best = nil -- 1922
	local bestD = 1000000000 -- 1923
	local i = 0 -- 1924
	do -- 1924
		i = 0 -- 1925
		while i < #self.boxes do -- 1925
			do -- 1925
				local b = self.boxes[i + 1] -- 1926
				if b.interact == nil or b.broken == true then -- 1926
					goto __continue302 -- 1928
				end -- 1928
				if not self:nearBox(b, b.interact.reach or 27) then -- 1928
					goto __continue302 -- 1931
				end -- 1931
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 1933
				if d < bestD then -- 1933
					bestD = d -- 1935
					best = b -- 1936
				end -- 1936
			end -- 1936
			::__continue302:: -- 1936
			i = i + 1 -- 1925
		end -- 1925
	end -- 1925
	return best -- 1939
end -- 1920
function Play.prototype.stepCampaign(self, dt, input) -- 1943
	local wr = self.room -- 1944
	local p = self.player -- 1945
	if self.reloadT > 0 then -- 1945
		self.reloadT = self.reloadT - 1 -- 1947
	end -- 1947
	if self.bracedShield ~= nil then -- 1947
		self.bracedShield.x = p.x + p.facing * 26 -- 1951
		self.bracedShield.y = p.y -- 1952
		local shBox = __TS__ArrayFind( -- 1953
			self.boxes, -- 1953
			function(____, b) return b.id == "braced_shield" end -- 1953
		) -- 1953
		if shBox ~= nil then -- 1953
			shBox.x0 = self.bracedShield.x - 15 -- 1955
			shBox.x1 = self.bracedShield.x + 15 -- 1956
			shBox.y0 = self.bracedShield.y -- 1957
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 1958
		end -- 1958
	end -- 1958
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 1958
		self.run.route = "drygoods" -- 1964
		self.run.joined = false -- 1965
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 1966
		self:log("转布行线") -- 1967
	end -- 1967
	local i = 0 -- 1970
	do -- 1970
		i = 0 -- 1971
		while i < #self.pickups do -- 1971
			do -- 1971
				local pk = self.pickups[i + 1] -- 1972
				if pk.id == "" or self.run.taken[pk.id] == true then -- 1972
					goto __continue313 -- 1974
				end -- 1974
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 1976
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 1977
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 1977
					if not self:addItem(pk.kind) then -- 1977
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 1981
						self:log("满包拒绝 " .. pk.kind) -- 1982
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 1983
						goto __continue313 -- 1984
					end -- 1984
					self.run.taken[pk.id] = true -- 1986
					pk.id = "" -- 1987
					self:flashSet("拾取 " .. pk.label, 1) -- 1988
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 1989
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 1990
				end -- 1990
			end -- 1990
			::__continue313:: -- 1990
			i = i + 1 -- 1971
		end -- 1971
	end -- 1971
	if not self:stepCraft(input) and input.interact.pressed then -- 1971
		self:campaignInteract() -- 1994
	end -- 1994
	self:stepCampaignCart(dt, input) -- 1996
	self:stepCampaignGoal() -- 1997
end -- 1943
function Play.prototype.campaignInteract(self) -- 2001
	local b = self:findInteract() -- 2002
	if b ~= nil then -- 2002
		self:useInteract(b) -- 2004
		return -- 2005
	end -- 2005
	local inv = self.run.inventory -- 2007
	if inv.wedge > 0 then -- 2007
		local w = self:findWedgeTarget() -- 2009
		if w ~= nil then -- 2009
			if w.breakable ~= nil then -- 2009
				local ____w_breakable_41, ____hp_42 = w.breakable, "hp" -- 2009
				____w_breakable_41[____hp_42] = ____w_breakable_41[____hp_42] + (w.breakable.wedgeHp or 1) -- 2012
			end -- 2012
			inv.wedge = inv.wedge - 1 -- 2014
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2015
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2017
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2018
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2019
			return -- 2020
		end -- 2020
	end -- 2020
	if inv.ammo > 0 and self.reloadT > 0 then -- 2020
		self.reloadT = 0 -- 2025
		inv.ammo = inv.ammo - 1 -- 2026
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2027
		self:log("用备用弹包") -- 2028
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2029
		return -- 2030
	end -- 2030
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2030
		local p = self.player -- 2034
		self.bracedShield = { -- 2035
			x = p.x + p.facing * 26, -- 2035
			y = p.y, -- 2035
			w = 30, -- 2035
			h = 64, -- 2035
			hp = 1 -- 2035
		} -- 2035
		local ____self_boxes_43 = self.boxes -- 2035
		____self_boxes_43[#____self_boxes_43 + 1] = { -- 2036
			x0 = self.bracedShield.x - 15, -- 2037
			x1 = self.bracedShield.x + 15, -- 2037
			y0 = p.y, -- 2038
			y1 = p.y + 64, -- 2038
			depth = {min = -46, max = 46}, -- 2038
			label = "架起的残盾", -- 2038
			id = "braced_shield", -- 2038
			soft = true -- 2039
		} -- 2039
		inv.shield = inv.shield - 1 -- 2042
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2043
		self:log("架残盾") -- 2044
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2045
		return -- 2046
	end -- 2046
	if inv.pass > 0 and self.run.joined == false then -- 2046
		inv.pass = inv.pass - 1 -- 2049
		self.run.joined = true -- 2050
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2051
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2052
		return -- 2053
	end -- 2053
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2055
end -- 2001
function Play.prototype.useInteract(self, b) -- 2058
	local kind = b.interact == nil and "" or b.interact.kind -- 2059
	local wr = self.room -- 2060
	if kind == "open_board" then -- 2060
		b.broken = true -- 2062
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2063
		for ____, cover in ipairs(self.boxes) do -- 2064
			if cover.id == "s2_board_cover" then -- 2064
				cover.broken = false -- 2066
				cover.hidden = false -- 2067
			end -- 2067
		end -- 2067
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2070
		self.run.joined = true -- 2071
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2072
		self:log("放下窗板") -- 2073
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2074
		return -- 2075
	end -- 2075
	if kind == "lower_curtain" then -- 2075
		for ____, curtain in ipairs(self.boxes) do -- 2078
			if curtain.id == "c2_curtain" then -- 2078
				curtain.broken = false -- 2080
				curtain.hidden = false -- 2081
			end -- 2081
		end -- 2081
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2084
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2085
		self:log("放下木帘") -- 2086
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2087
		return -- 2088
	end -- 2088
	if kind == "raise_latch" then -- 2088
		if wr.key == "c2-granary" and not self.cartDocked then -- 2088
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2092
			return -- 2093
		end -- 2093
		b.broken = true -- 2095
		self.objectiveDone = true -- 2096
		if wr.key == "c1-yard" then -- 2096
			self.run.c1Latch = true -- 2099
			self.run.joined = true -- 2100
		else -- 2100
			self.run.c2Latch = true -- 2102
			self.run.joined = true -- 2103
		end -- 2103
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2105
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2106
		self:log("抬闩") -- 2107
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2108
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2109
	end -- 2109
end -- 2058
function Play.prototype.stepCampaignCart(self, dt, input) -- 2114
	local wr = self.room -- 2115
	local c = wr.cart -- 2116
	if c.bodyW <= 0 then -- 2116
		return -- 2118
	end -- 2118
	local p = self.player -- 2120
	local handleX = self.cartAxle + c.handleOffset -- 2121
	if not self.gripping then -- 2121
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2121
			self.gripping = true -- 2125
			self:flashSet("握住车柄 · A/D 推", 1) -- 2126
		end -- 2126
		return -- 2128
	end -- 2128
	if input.interact.pressed then -- 2128
		self.gripping = false -- 2131
		self:flashSet("松手", 0.5) -- 2132
		return -- 2133
	end -- 2133
	if not self.cartDocked then -- 2133
		if input.moveX ~= 0 and not self:stuckCart() then -- 2133
			self.cartAxle = math.max( -- 2137
				c.startX, -- 2137
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2137
			) -- 2137
		end -- 2137
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2137
			self.cartExposed = true -- 2142
			local gun = nil -- 2143
			local gi = 0 -- 2144
			do -- 2144
				gi = 0 -- 2145
				while gi < #self.enemies do -- 2145
					local e = self.enemies[gi + 1] -- 2146
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2146
						gun = e -- 2148
						break -- 2149
					end -- 2149
					gi = gi + 1 -- 2145
				end -- 2145
			end -- 2145
			if gun ~= nil then -- 2145
				self:campaignEnemyFire(gun) -- 2153
			end -- 2153
		end -- 2153
		p.x = self.cartAxle + c.handleOffset -- 2156
		p.y = c.baseY + (c.depth or 0) -- 2157
		p.vx = 0 -- 2158
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2158
			self.cartAxle = c.endX -- 2160
			self.cartDocked = true -- 2161
			self.gripping = false -- 2162
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2163
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2164
			self:flashSet("车轮入窝", 1.2) -- 2165
			self:log("车轮入窝") -- 2166
		end -- 2166
	end -- 2166
end -- 2114
function Play.prototype.stuckCart(self) -- 2172
	local i = 0 -- 2173
	do -- 2173
		i = 0 -- 2174
		while i < #self.boxes do -- 2174
			do -- 2174
				local b = self.boxes[i + 1] -- 2175
				if b.broken == true or b.breakable == nil or b.soft == true then -- 2175
					goto __continue354 -- 2177
				end -- 2177
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 2179
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 2179
					return true -- 2181
				end -- 2181
			end -- 2181
			::__continue354:: -- 2181
			i = i + 1 -- 2174
		end -- 2174
	end -- 2174
	return false -- 2184
end -- 2172
function Play.prototype.stepCampaignGoal(self) -- 2188
	local wr = self.room -- 2189
	local c = wr.campaign -- 2190
	if c == nil then -- 2190
		return -- 2192
	end -- 2192
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 2192
		self.objectiveDone = true -- 2195
	end -- 2195
	if c.goal == "reach_exit" then -- 2195
		self.objectiveDone = true -- 2198
	end -- 2198
	if not self.objectiveDone then -- 2198
		return -- 2201
	end -- 2201
	local p = self.player -- 2203
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 2204
	if p.x < c.exitX or not partnerOk then -- 2204
		return -- 2206
	end -- 2206
	if c.next ~= nil and c.next ~= "" then -- 2206
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 2209
		self:flashSet("过关 · " .. c.next, 1.2) -- 2210
	elseif not self.run.finished then -- 2210
		self.run.finished = true -- 2212
		self:flashSet( -- 2213
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 2213
			2 -- 2213
		) -- 2213
		self:log("C2 灰盒完成") -- 2214
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 2215
	end -- 2215
end -- 2188
function Play.prototype.stepCampaignPartner(self, dt) -- 2220
	local a = self.partner -- 2221
	local wr = self.room -- 2222
	local cp = wr.companion -- 2223
	if not a.alive then -- 2223
		return -- 2225
	end -- 2225
	local p = self.player -- 2227
	local wait = false -- 2228
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 2229
	local targetDepth = p.depth -- 2230
	if self.run.joined == false then -- 2230
		wait = true -- 2232
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2233
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2234
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 2234
		wait = true -- 2236
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2237
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2238
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 2238
		wait = true -- 2240
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2241
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2242
	end -- 2242
	if self.partnerStuck > 0.3 then -- 2242
		a.x = a.x + a.facing * 44 -- 2246
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2247
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2248
		self.partnerLaneHold = 1.1 -- 2249
		self.partnerStuck = 0 -- 2250
	end -- 2250
	if self.partnerLaneHold > 0 then -- 2250
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2253
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2254
	end -- 2254
	local dx = targetX - a.x -- 2256
	if not wait and math.abs(dx) > 74 then -- 2256
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2258
		local before = a.x -- 2259
		a.vx = dx > 0 and speed or -speed -- 2260
		a.facing = dx > 0 and 1 or -1 -- 2261
		self:slideX(a, a.vx * dt) -- 2262
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2262
			a.vy = CHILD_JUMP -- 2265
			a.onGround = false -- 2266
		end -- 2266
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2268
	else -- 2268
		a.vx = 0 -- 2270
		self.partnerStuck = 0 -- 2271
	end -- 2271
	local dz = targetDepth - a.depth -- 2273
	if math.abs(dz) > 6 then -- 2273
		local step = math.max( -- 2275
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2275
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2275
		) -- 2275
		a.depth = a.depth + step -- 2276
	end -- 2276
	a.depthSpeed = 0 -- 2278
	a.h = CHILD_H -- 2279
	a.crouch = false -- 2280
	self:fallY(a, dt) -- 2281
end -- 2220
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2285
	local p = self.player -- 2286
	local i = 0 -- 2287
	do -- 2287
		i = 0 -- 2288
		while i < #self.enemies do -- 2288
			do -- 2288
				local ____opt_44 = self.run.trial -- 2288
				if ____opt_44 and ____opt_44.lost then -- 2288
					return -- 2289
				end -- 2289
				local e = self.enemies[i + 1] -- 2290
				if not e.alive then -- 2290
					goto __continue378 -- 2292
				end -- 2292
				if e.hitT > 0 then -- 2292
					e.hitT = e.hitT - dt -- 2295
				end -- 2295
				if e.kind == "breaker" then -- 2295
					self:stepBreaker(e, dt) -- 2298
					goto __continue378 -- 2299
				end -- 2299
				if e.kind == "shield" then -- 2299
					self:stepShield(e, dt, input) -- 2302
					goto __continue378 -- 2303
				end -- 2303
				local dx = e.x - p.x -- 2306
				if not e.awake then -- 2306
					if math.abs(dx) > 520 then -- 2306
						goto __continue378 -- 2309
					end -- 2309
					e.awake = true -- 2311
					e.fireCd = 48 -- 2312
					goto __continue378 -- 2313
				end -- 2313
				if math.abs(dx) > ENEMY_RANGE then -- 2313
					goto __continue378 -- 2316
				end -- 2316
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2316
					goto __continue378 -- 2321
				end -- 2321
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2321
					goto __continue378 -- 2324
				end -- 2324
				if self:blockedShot(e, p) then -- 2324
					if e.warnT > 0 then -- 2324
						e.warnT = 0 -- 2330
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2331
					end -- 2331
					goto __continue378 -- 2333
				end -- 2333
				if e.warnT > 0 then -- 2333
					e.warnT = e.warnT - 1 -- 2336
					if e.warnT <= 0 then -- 2336
						self:campaignEnemyFire(e) -- 2338
					end -- 2338
				elseif e.fireCd > 0 then -- 2338
					e.fireCd = e.fireCd - 1 -- 2341
					if e.fireCd <= 0 then -- 2341
						e.warnT = WARN_TICKS -- 2343
					end -- 2343
				else -- 2343
					e.fireCd = 40 -- 2346
				end -- 2346
			end -- 2346
			::__continue378:: -- 2346
			i = i + 1 -- 2288
		end -- 2288
	end -- 2288
end -- 2285
function Play.prototype.blockedShot(self, e, p) -- 2352
	local eDepth = e.depth or 0 -- 2353
	local ex = e.x -- 2354
	local ey = e.y + e.h * 0.62 -- 2356
	local px = p.x -- 2357
	local py = p.y + p.h * 0.55 -- 2358
	local dx = px - ex -- 2359
	local dyScreen = py + p.depth - (ey + eDepth) -- 2360
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 2361
	if len < 0.01 then -- 2361
		return false -- 2363
	end -- 2363
	local ray = { -- 2367
		x = ex, -- 2368
		y = ey, -- 2368
		dx = dx / len, -- 2369
		dy = (py - ey) / len, -- 2369
		depth = eDepth, -- 2370
		dDepth = (p.depth - eDepth) / len -- 2370
	} -- 2370
	local best = -1 -- 2372
	local j = 0 -- 2373
	do -- 2373
		j = 0 -- 2374
		while j < #self.boxes do -- 2374
			do -- 2374
				local b = self.boxes[j + 1] -- 2375
				if b.broken == true or b.passable == true or b.hidden == true then -- 2375
					goto __continue399 -- 2377
				end -- 2377
				if b.id == "braced_shield" then -- 2377
					goto __continue399 -- 2382
				end -- 2382
				local t = hitBox(ray, b) -- 2384
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 2384
					best = t -- 2388
				end -- 2388
			end -- 2388
			::__continue399:: -- 2388
			j = j + 1 -- 2374
		end -- 2374
	end -- 2374
	return best >= 0 -- 2391
end -- 2352
function Play.prototype.campaignEnemyFire(self, e) -- 2394
	local p = self.player -- 2395
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2396
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2396
		local ____self_bracedShield_46, ____hp_47 = self.bracedShield, "hp" -- 2396
		____self_bracedShield_46[____hp_47] = ____self_bracedShield_46[____hp_47] - 1 -- 2398
		self.boxes = __TS__ArrayFilter( -- 2399
			self.boxes, -- 2399
			function(____, b) return b.id ~= "braced_shield" end -- 2399
		) -- 2399
		self.bracedShield = nil -- 2400
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2401
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2402
		return -- 2403
	end -- 2403
	if self:blockedShot(e, p) then -- 2403
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2406
		return -- 2407
	end -- 2407
	local cover = self:blockedByCover(e, p) -- 2409
	if cover ~= nil and self.coverHug then -- 2409
		self.coveredFlash = 0.5 -- 2411
		self:flashSet("掩体挡下", 0.6) -- 2412
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2413
		return -- 2418
	end -- 2418
	if self.invulnT > 0 then -- 2418
		return -- 2421
	end -- 2421
	local ____opt_48 = self.run.trial -- 2421
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_48 and ____opt_48.ranks.guard or 0) -- 2423
	self.craftT = 0 -- 2424
	self.hp = self.hp - 1 -- 2425
	self:emit("actorHit", { -- 2426
		target = "player", -- 2426
		amount = 1, -- 2426
		hp = self.hp, -- 2426
		maxHp = self.maxHp, -- 2426
		enemyX = e.x -- 2426
	}) -- 2426
	self:flashSet( -- 2427
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2427
		0.8 -- 2427
	) -- 2427
	if self.hp <= 0 then -- 2427
		self:campaignFailed() -- 2429
	end -- 2429
end -- 2394
function Play.prototype.stepShield(self, e, dt, input) -- 2434
	local p = self.player -- 2435
	local dx = p.x - e.x -- 2436
	local adx = math.abs(dx) -- 2437
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2440
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2441
	if adx > 150 then -- 2441
		local before = e.x -- 2443
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2444
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2444
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2447
		end -- 2447
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2447
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2452
		local rollDodges = p.rollT > 0 and fromFront -- 2453
		if not rollDodges and self.invulnT <= 0 then -- 2453
			local ____opt_50 = self.run.trial -- 2453
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 2455
			self.craftT = 0 -- 2456
			self.hp = self.hp - 1 -- 2457
			self:emit("actorHit", { -- 2458
				target = "player", -- 2458
				amount = 1, -- 2458
				hp = self.hp, -- 2458
				maxHp = self.maxHp, -- 2458
				enemyX = e.x -- 2458
			}) -- 2458
			self:flashSet( -- 2459
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2459
				0.8 -- 2459
			) -- 2459
			if self.hp <= 0 then -- 2459
				self:campaignFailed() -- 2461
				return -- 2462
			end -- 2462
		end -- 2462
		e.swingT = 70 -- 2465
	end -- 2465
	if (e.swingT or 0) > 0 then -- 2465
		e.swingT = (e.swingT or 0) - 1 -- 2468
	end -- 2468
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2468
		local dd = p.depth - (e.depth or 0) -- 2471
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2472
	end -- 2472
end -- 2434
function Play.prototype.stepBreaker(self, e, dt) -- 2477
	local p = self.player -- 2478
	if e.awake ~= true then -- 2478
		if math.abs(p.x - e.x) < 560 then -- 2478
			e.awake = true -- 2481
		else -- 2481
			return -- 2483
		end -- 2483
	end -- 2483
	local target = nil -- 2486
	local bestD = 1000000000 -- 2487
	local i = 0 -- 2488
	do -- 2488
		i = 0 -- 2489
		while i < #self.boxes do -- 2489
			do -- 2489
				local b = self.boxes[i + 1] -- 2490
				if b.breakable == nil or b.broken == true then -- 2490
					goto __continue423 -- 2492
				end -- 2492
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2494
				if d < bestD then -- 2494
					bestD = d -- 2496
					target = b -- 2497
				end -- 2497
			end -- 2497
			::__continue423:: -- 2497
			i = i + 1 -- 2489
		end -- 2489
	end -- 2489
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2500
	local dx = tx - e.x -- 2501
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2502
	if math.abs(dx) > reach then -- 2502
		local before = e.x -- 2504
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2505
		if math.abs(e.x - before) < 0.3 then -- 2505
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2507
		end -- 2507
	elseif (e.swingT or 0) <= 0 then -- 2507
		e.swingT = 64 -- 2510
		if target ~= nil then -- 2510
			self:damageProp(target, 2) -- 2512
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2512
			local ____opt_52 = self.run.trial -- 2512
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 2514
			self.craftT = 0 -- 2515
			self.hp = self.hp - 1 -- 2516
			self:emit("actorHit", { -- 2517
				target = "player", -- 2517
				amount = 1, -- 2517
				hp = self.hp, -- 2517
				maxHp = self.maxHp, -- 2517
				enemyX = e.x -- 2517
			}) -- 2517
			self:flashSet("破障手近身", 0.8) -- 2518
			if self.hp <= 0 then -- 2518
				self:campaignFailed() -- 2520
				return -- 2521
			end -- 2521
		end -- 2521
	end -- 2521
	if (e.swingT or 0) > 0 then -- 2521
		e.swingT = (e.swingT or 0) - 1 -- 2526
	end -- 2526
end -- 2477
function Play.prototype.campaignFailed(self) -- 2530
	if self.run.trial ~= nil then -- 2530
		self.run.trial.lost = true -- 2532
		self.wantRoom = "" -- 2533
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2534
		return -- 2535
	end -- 2535
	local p = self.player -- 2537
	self.hp = self.maxHp -- 2538
	self.invulnT = INVULN_RESPAWN_TICKS -- 2539
	self.reloadT = 0 -- 2540
	self.gripping = false -- 2541
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2542
	self:log("被击倒") -- 2543
	p.x = self.room.minX + 90 -- 2544
	p.y = 0 -- 2545
	p.depth = 0 -- 2546
	p.vx = 0 -- 2547
	p.vy = 0 -- 2548
	p.onGround = true -- 2549
	p.rollT = 0 -- 2550
	self.partner.x = p.x - 50 -- 2551
	self.partner.y = 0 -- 2552
	self.partner.depth = 0 -- 2553
	self.cam.x = p.x -- 2554
	local i = 0 -- 2555
	do -- 2555
		i = 0 -- 2556
		while i < #self.enemies do -- 2556
			do -- 2556
				local e = self.enemies[i + 1] -- 2557
				if not e.alive then -- 2557
					goto __continue436 -- 2559
				end -- 2559
				e.x = e.homeX == nil and e.x or e.homeX -- 2561
				e.warnT = 0 -- 2562
				e.fireCd = 40 -- 2563
				e.swingT = 0 -- 2564
				e.awake = false -- 2565
			end -- 2565
			::__continue436:: -- 2565
			i = i + 1 -- 2556
		end -- 2556
	end -- 2556
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2567
end -- 2530
function Play.prototype.stepEnemies(self, dt, input) -- 2570
	local i = 0 -- 2571
	do -- 2571
		i = 0 -- 2572
		while i < #self.enemies do -- 2572
			local e = self.enemies[i + 1] -- 2573
			if e.hitT > 0 then -- 2573
				e.hitT = e.hitT - dt -- 2575
			end -- 2575
			i = i + 1 -- 2572
		end -- 2572
	end -- 2572
	if self.coveredFlash > 0 then -- 2572
		self.coveredFlash = self.coveredFlash - dt -- 2579
	end -- 2579
	if self.isCampaign then -- 2579
		self:stepCampaignEnemies(dt, input) -- 2582
		return -- 2583
	end -- 2583
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2583
		return -- 2587
	end -- 2587
	do -- 2587
		i = 0 -- 2589
		while i < #self.enemies do -- 2589
			do -- 2589
				local e = self.enemies[i + 1] -- 2590
				if not e.alive then -- 2590
					goto __continue446 -- 2592
				end -- 2592
				if e.warnT > 0 then -- 2592
					e.warnT = e.warnT - 1 -- 2595
					if e.warnT <= 0 then -- 2595
						self:enemyFire(e, input) -- 2597
					end -- 2597
					goto __continue446 -- 2599
				end -- 2599
				if e.fireCd > 0 then -- 2599
					e.fireCd = e.fireCd - 1 -- 2602
					if e.fireCd <= 0 then -- 2602
						e.warnT = WARN_TICKS -- 2604
					end -- 2604
				else -- 2604
					e.warnT = WARN_TICKS -- 2608
				end -- 2608
			end -- 2608
			::__continue446:: -- 2608
			i = i + 1 -- 2589
		end -- 2589
	end -- 2589
end -- 2570
function Play.prototype.enemyFire(self, e, input) -- 2614
	local p = self.player -- 2615
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2615
		self:flashSet("枪声响在远处", 0.4) -- 2617
		e.fireCd = FIRE_COOLDOWN -- 2618
		return -- 2619
	end -- 2619
	local cover = self:blockedByCover(e, p) -- 2622
	local hugging = cover ~= nil -- 2623
	self.coverBlocking = hugging -- 2624
	local covered = hugging and input.cover.held -- 2625
	if covered then -- 2625
		self.coveredFlash = 0.5 -- 2627
		self:flashSet("掩体挡下", 0.5) -- 2628
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2629
		e.fireCd = FIRE_COOLDOWN -- 2634
		return -- 2635
	end -- 2635
	self.hp = self.hp - 1 -- 2637
	self:emit("actorHit", { -- 2638
		target = "player", -- 2638
		amount = 1, -- 2638
		hp = self.hp, -- 2638
		maxHp = self.maxHp, -- 2638
		enemyX = e.x -- 2638
	}) -- 2638
	self:flashSet( -- 2639
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2639
		0.7 -- 2639
	) -- 2639
	e.fireCd = FIRE_COOLDOWN -- 2640
	if self.hp <= 0 then -- 2640
		self:gateFailed() -- 2642
	end -- 2642
end -- 2614
function Play.prototype.blockedByCover(self, enemy, p) -- 2647
	local b = self:coverAt(p) -- 2648
	if b == nil then -- 2648
		return nil -- 2650
	end -- 2650
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2652
end -- 2647
function Play.prototype.gateFailed(self) -- 2656
	local ____temp_54 -- 2657
	if self.room.story == nil then -- 2657
		____temp_54 = nil -- 2657
	else -- 2657
		____temp_54 = self.room.story.gate -- 2657
	end -- 2657
	local g = ____temp_54 -- 2657
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2658
	self.hp = self.maxHp -- 2659
	self.gateTick = 0 -- 2660
	self.gateSpawned = 0 -- 2661
	self.enemies = {} -- 2662
	self.gateFailCount = self.gateFailCount + 1 -- 2663
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2665
	self.player.y = 0 -- 2666
	self.player.vy = 0 -- 2667
	self.player.depth = 0 -- 2668
	self.player.depthSpeed = 0 -- 2669
	self.player.onGround = true -- 2670
	self.player.crouch = false -- 2671
	self.player.h = SOLDIER_H -- 2672
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2673
	self.partner.y = 0 -- 2674
	self.partner.vy = 0 -- 2675
	self.partner.depth = 0 -- 2676
	self.partner.depthSpeed = 0 -- 2677
	self.partner.onGround = true -- 2678
	self.cam.x = self.player.x -- 2679
	self.phase = "gate-idle" -- 2680
	self.phaseTick = 0 -- 2681
	self.coverHug = false -- 2682
	self.coverBlocking = false -- 2683
	self.coverEntity = "" -- 2684
	self.gateNeedConfirm = true -- 2685
	self.gateRestartArmed = false -- 2686
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2687
end -- 2656
function Play.prototype.stepInteract(self, dt, input) -- 2690
	local p = self.player -- 2691
	local calmUsed = self.calmConsumed -- 2692
	self.calmConsumed = false -- 2693
	local calming = self.escort.state == "calming" -- 2695
	self.focusCart = false -- 2696
	if self.room.key == "outside" then -- 2696
		local c = self.room.cart -- 2698
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2699
		local dy = p.y - c.baseY -- 2700
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2701
	end -- 2701
	if not calmUsed and not calming then -- 2701
		self:stepCart(dt, input) -- 2705
	end -- 2705
	if calmUsed then -- 2705
		self:flashSet("安抚 · 敲两下", 0.8) -- 2710
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2710
		if self.knockT > 0 then -- 2710
			self.knocks = self.knocks + 1 -- 2714
		else -- 2714
			self.knocks = 1 -- 2716
		end -- 2716
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2718
		self.knockT = 1.2 -- 2719
		if self.knocks >= 2 then -- 2719
			self:flashSet("敲两下", 0.8) -- 2721
			self.knocks = 0 -- 2722
		else -- 2722
			self:flashSet("敲一下", 0.5) -- 2724
		end -- 2724
	elseif self.knockT > 0 then -- 2724
		self.knockT = self.knockT - dt -- 2727
		if self.knockT <= 0 then -- 2727
			self.knocks = 0 -- 2729
		end -- 2729
	end -- 2729
	local i = 0 -- 2734
	do -- 2734
		i = 0 -- 2735
		while i < #self.room.marks do -- 2735
			do -- 2735
				local m = self.room.marks[i + 1] -- 2736
				if m.kind ~= 0 then -- 2736
					goto __continue472 -- 2738
				end -- 2738
				local subjects = {self.partner, self.player} -- 2740
				local k = 0 -- 2741
				do -- 2741
					k = 0 -- 2742
					while k < #subjects do -- 2742
						do -- 2742
							local s = subjects[k + 1] -- 2743
							if not s.alive then -- 2743
								goto __continue475 -- 2745
							end -- 2745
							local dx = s.x - m.x -- 2747
							local dy = s.y - m.y -- 2748
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2748
								self.checkpoint = m.x -- 2750
								self.checkpointCartAxle = self.cartAxle -- 2751
								if self.cartDocked then -- 2751
									self:flashSet("检查点 · 车已落窝", 1) -- 2753
								else -- 2753
									self:flashSet("检查点 · 车还没到位", 1) -- 2755
								end -- 2755
							end -- 2755
						end -- 2755
						::__continue475:: -- 2755
						k = k + 1 -- 2742
					end -- 2742
				end -- 2742
			end -- 2742
			::__continue472:: -- 2742
			i = i + 1 -- 2735
		end -- 2735
	end -- 2735
	self:checkCarryGate() -- 2761
end -- 2690
function Play.prototype.stepVillage(self, dt, input) -- 2765
	if self.room.key ~= "village" then -- 2765
		return -- 2767
	end -- 2767
	local p = self.player -- 2769
	local bottle = self.room.bottle -- 2770
	local scav = self.room.scavenger -- 2771
	if not self.hasBottle and bottle ~= nil then -- 2771
		local dx = p.x - bottle.x -- 2775
		local dy = p.y + p.h * 0.5 - bottle.y -- 2776
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 2776
			self.hasBottle = true -- 2778
			self:flashSet("拾起瓶子", 0.8) -- 2779
		end -- 2779
	end -- 2779
	if self.hasBottle then -- 2779
		if input.aim.held then -- 2779
			self.aimHold = self.aimHold + dt -- 2786
			if self.aimHold > 1.2 then -- 2786
				self.aimHold = 1.2 -- 2788
			end -- 2788
			local cached = self:bottleEnd() -- 2791
			self.bottleAimX = cached.x -- 2792
			self.bottleAimY = cached.y -- 2793
		elseif input.aim.released then -- 2793
			if self.aimHold < 0.12 then -- 2793
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 2797
				self.aimHold = 0 -- 2798
			else -- 2798
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 2800
				self:throwBottle(____end.x, ____end.y) -- 2801
				self.aimHold = 0 -- 2802
			end -- 2802
		end -- 2802
	else -- 2802
		self.aimHold = 0 -- 2806
		self.bottleAimX = -1 -- 2807
	end -- 2807
	local fly = self.bottleFly -- 2812
	if fly ~= nil then -- 2812
		fly.t = fly.t + dt -- 2814
		fly.x = fly.x0 + fly.vx * fly.t -- 2815
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 2816
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 2817
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 2817
			self:landBottle(fly) -- 2819
		end -- 2819
	end -- 2819
	if self.bottleLandT > 0 then -- 2819
		self.bottleLandT = self.bottleLandT - dt -- 2823
	end -- 2823
	if scav ~= nil then -- 2823
		self:stepScav(dt, scav) -- 2827
	end -- 2827
	local line = self.room.passLine -- 2830
	if line ~= nil and not self.passed and p.x >= line then -- 2830
		self.passed = true -- 2832
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 2833
	end -- 2833
	if self.passed and p.x >= self.ox + 640 then -- 2833
		self:requestRoom("forest", "过第一院出院") -- 2837
		self:flashSet("出院 · 北塔森林", 1.4) -- 2838
	end -- 2838
end -- 2765
function Play.prototype.bottleEnd(self) -- 2843
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 2844
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 2847
	return {x = aim.x, y = g} -- 2848
end -- 2843
function Play.prototype.throwBottle(self, tx, ty) -- 2852
	local p = self.player -- 2853
	local dir = tx >= p.x and 1 or -1 -- 2855
	p.facing = dir -- 2856
	local x0 = p.x + dir * 10 -- 2857
	local y0 = p.y + p.h * 0.7 -- 2858
	self.bottleTargetX = tx -- 2859
	self.bottleTargetY = ty -- 2860
	self.bottleSurfaceY = ty -- 2861
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 2862
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 2863
	self.bottleFly = { -- 2864
		x = x0, -- 2864
		y = y0, -- 2864
		x0 = x0, -- 2864
		y0 = y0, -- 2864
		vx = vx, -- 2864
		vy = vy, -- 2864
		t = 0 -- 2864
	} -- 2864
	self.hasBottle = false -- 2865
	self:flashSet("投出", 0.4) -- 2866
	self:emit( -- 2867
		"bottleThrown", -- 2867
		{ -- 2867
			fromX = x0, -- 2868
			fromY = y0, -- 2869
			targetX = tx, -- 2870
			targetY = ty, -- 2871
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 2872
		} -- 2872
	) -- 2872
end -- 2852
function Play.prototype.landBottle(self, fly) -- 2877
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 2878
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 2879
	local s = self.room.scavenger -- 2880
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 2881
	self.bottleFly = nil -- 2882
	self.bottleTargetX = -1 -- 2883
	self.bottleTargetY = 0 -- 2884
	self.bottleSurfaceY = -1 -- 2885
	self.bottleLandX = x -- 2886
	self.bottleLandY = y -- 2887
	self.bottleLandT = 0.9 -- 2888
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 2889
	self:hearBottle(x) -- 2890
end -- 2877
function Play.prototype.hearBottle(self, x) -- 2894
	local s = self.room.scavenger -- 2895
	if s == nil then -- 2895
		return -- 2897
	end -- 2897
	if math.abs(x - self.scavX) > s.range then -- 2897
		self:flashSet("落地 · 他没听见", 0.6) -- 2900
		return -- 2901
	end -- 2901
	self.scavState = "turn" -- 2903
	self.scavT = s.hearTicks -- 2904
	self.scavTargetX = x -- 2905
	self:flashSet("砖地一响 · 他转头", 0.9) -- 2906
end -- 2894
function Play.prototype.stepScav(self, dt, s) -- 2910
	if self.scavState == "chase" then -- 2910
		return -- 2913
	end -- 2913
	if self.scavState == "turn" then -- 2913
		self.scavT = self.scavT - 1 -- 2916
		if self.scavT <= 0 then -- 2916
			self.scavState = "walk" -- 2918
		end -- 2918
		return -- 2920
	end -- 2920
	if self.scavState == "walk" then -- 2920
		local d = self.scavTargetX - self.scavX -- 2923
		if math.abs(d) < 4 then -- 2923
			self.scavState = "stall" -- 2925
			self.scavT = s.stallTicks -- 2926
			return -- 2927
		end -- 2927
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 2929
		return -- 2930
	end -- 2930
	if self.scavState == "stall" then -- 2930
		self.scavT = self.scavT - 1 -- 2933
		if self.scavT <= 0 then -- 2933
			self.scavState = "back" -- 2935
		end -- 2935
		return -- 2937
	end -- 2937
	if self.scavState == "back" then -- 2937
		local home = math.max( -- 2940
			s.x0, -- 2940
			math.min(s.x1, self.scavX) -- 2940
		) -- 2940
		if math.abs(home - self.scavX) < 2 then -- 2940
			self.scavState = "patrol" -- 2942
			return -- 2943
		end -- 2943
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 2945
		return -- 2946
	end -- 2946
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 2948
	if self.scavX >= s.x1 then -- 2948
		self.scavX = s.x1 -- 2950
		self.scavDir = -1 -- 2951
	elseif self.scavX <= s.x0 then -- 2951
		self.scavX = s.x0 -- 2953
		self.scavDir = 1 -- 2954
	end -- 2954
end -- 2910
function Play.prototype.stepCart(self, dt, input) -- 2962
	local p = self.player -- 2963
	local c = self.room.cart -- 2964
	if self.gripping then -- 2964
		if not input.interact.held then -- 2964
			self.gripping = false -- 2968
			self:flashSet("松开车把", 0.4) -- 2969
			return -- 2970
		end -- 2970
	else -- 2970
		if not input.interact.pressed then -- 2970
			return -- 2974
		end -- 2974
		if not self:cartHandleInReach(p) then -- 2974
			return -- 2977
		end -- 2977
		local track = c.depth or 0 -- 2979
		if self:limitDepth(p, track) ~= track then -- 2979
			return -- 2981
		end -- 2981
		p.depth = track -- 2983
		p.depthSpeed = 0 -- 2984
		self.gripping = true -- 2985
		self:flashSet("握住车把", 0.4) -- 2986
		return -- 2987
	end -- 2987
	if self.cartDocked then -- 2987
		return -- 2991
	end -- 2991
	local dir = input.moveX -- 2993
	if dir == 0 then -- 2993
		return -- 2995
	end -- 2995
	local lo = math.min(c.startX, c.endX) -- 2997
	local hi = math.max(c.startX, c.endX) -- 2998
	local next = self.cartAxle + dir * CART_SPEED * dt -- 2999
	if next < lo then -- 2999
		next = lo -- 3001
	end -- 3001
	if next > hi then -- 3001
		next = hi -- 3004
	end -- 3004
	local delta = next - self.cartAxle -- 3006
	if delta == 0 then -- 3006
		return -- 3008
	end -- 3008
	self.cartAxle = next -- 3010
	p.x = p.x + delta -- 3011
	p.facing = dir > 0 and 1 or -1 -- 3012
	self:slideX(p, 0) -- 3013
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3013
		self.gripping = false -- 3015
		self:flashSet("跟不上了，脱手", 0.6) -- 3016
		return -- 3017
	end -- 3017
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3017
		self.cartDocked = true -- 3020
		self.gripping = false -- 3021
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3022
		self:flashSet("车轮落窝", 1.2) -- 3023
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3023
		self:flashSet("车轮回到起点", 0.5) -- 3025
	end -- 3025
end -- 2962
function Play.prototype.requestRoom(self, key, reason) -- 3033
	if self.wantRoom ~= "" then -- 3033
		return -- 3037
	end -- 3037
	self.wantRoom = key -- 3039
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3040
end -- 3033
function Play.prototype.checkCarryGate(self) -- 3047
	if self.room.key == "checkpoint" then -- 3047
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3047
			self.carryCartAxle = self.cartAxle -- 3050
			self.carryCartDocked = self.cartDocked -- 3051
			self:requestRoom("gate", "检查站出口") -- 3052
			self:flashSet("出检查站 · 城门", 1.2) -- 3053
		end -- 3053
		return -- 3055
	end -- 3055
	if self.room.key == "outside" then -- 3055
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3055
			self.carryCartAxle = self.cartAxle -- 3061
			self.carryCartDocked = self.cartDocked -- 3062
			self:requestRoom("village", "墙根走完") -- 3063
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3064
		end -- 3064
	end -- 3064
end -- 3047
function Play.prototype.aimAt(self, wx, wy) -- 3071
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3072
	self.aimX = s.x -- 3073
	self.aimY = s.y -- 3074
end -- 3071
function Play.prototype.shoot(self, a) -- 3077
	if self.isCampaign and self.reloadT > 0 then -- 3077
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3079
		return -- 3080
	end -- 3080
	local ox = a.x + a.facing * 8 -- 3082
	local muzzleY = a.y + a.h * 0.72 -- 3083
	local oy = muzzleY + a.depth -- 3084
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3086
	local dx = aim.x - ox -- 3089
	local dy = aim.y - oy -- 3090
	local len = math.sqrt(dx * dx + dy * dy) -- 3091
	if len < 0.001 then -- 3091
		dx = a.facing -- 3093
		dy = 0 -- 3094
	else -- 3094
		dx = dx / len -- 3096
		dy = dy / len -- 3097
	end -- 3097
	if dx ~= 0 then -- 3097
		a.facing = dx > 0 and 1 or -1 -- 3100
	end -- 3100
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3103
	local hitEnemy = self:raycastEnemies(ray) -- 3104
	local tEnemy = hitEnemy.t -- 3105
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3106
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3107
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3108
	local tWall = solid.t -- 3109
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall) -- 3110
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3111
	self.trace = { -- 3113
		x0 = ox, -- 3113
		y0 = oy, -- 3113
		x1 = ox + dx * t, -- 3113
		y1 = oy + dy * t, -- 3113
		hit = hit -- 3113
	} -- 3113
	self.traceT = 0.12 -- 3114
	self:applyFireDanger(ox) -- 3115
	local killed = false -- 3116
	if hit then -- 3116
		local i = hitEnemy.index -- 3118
		local e = self.enemies[i + 1] -- 3119
		local impactY = oy + dy * tEnemy -- 3120
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3121
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3122
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3122
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3124
			e.hitT = 0.3 -- 3125
			self:flashSet( -- 3126
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3126
				0.8 -- 3126
			) -- 3126
			self:emit("shotResolved", { -- 3127
				hit = true, -- 3128
				enemyIndex = i, -- 3128
				enemyX = e.x, -- 3128
				aimX = aim.x, -- 3128
				aimY = aim.y, -- 3128
				impactX = ox + dx * t, -- 3129
				impactY = oy + dy * t, -- 3129
				shield = true -- 3129
			}) -- 3129
			self.reloadT = self:reloadTicks() -- 3131
			return -- 3132
		end -- 3132
		e.alive = false -- 3134
		e.hitT = 0.4 -- 3135
		killed = true -- 3136
		self:flashSet("命中", 0.6) -- 3137
		self:dropFor(e) -- 3138
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3138
		self:damageProp(solid.box, 1) -- 3140
	else -- 3140
		self:flashSet("打空", 0.35) -- 3142
	end -- 3142
	if self.isCampaign then -- 3142
		self.reloadT = self:reloadTicks() -- 3145
	end -- 3145
	self:emit("shotResolved", { -- 3147
		hit = hit, -- 3148
		enemyIndex = hit and hitEnemy.index or -1, -- 3149
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3150
		aimX = aim.x, -- 3151
		aimY = aim.y, -- 3152
		impactX = ox + dx * t, -- 3153
		impactY = oy + dy * t -- 3154
	}) -- 3154
end -- 3077
function Play.prototype.applyFireDanger(self, shotX) -- 3159
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3159
		return -- 3161
	end -- 3161
	local dangerX = shotX -- 3163
	local best = -1 -- 3164
	local bestD = 1000000000 -- 3165
	local i = 0 -- 3166
	do -- 3166
		i = 0 -- 3167
		while i < #self.enemies do -- 3167
			do -- 3167
				local e = self.enemies[i + 1] -- 3168
				if not e.alive then -- 3168
					goto __continue551 -- 3170
				end -- 3170
				local d = math.abs(e.x - self.partner.x) -- 3172
				if d < bestD then -- 3172
					bestD = d -- 3174
					best = i -- 3175
				end -- 3175
			end -- 3175
			::__continue551:: -- 3175
			i = i + 1 -- 3167
		end -- 3167
	end -- 3167
	if best >= 0 then -- 3167
		dangerX = self.enemies[best + 1].x -- 3179
	end -- 3179
	local exposed = self:childExposed(dangerX) -- 3181
	local before = self.escort.fear -- 3182
	local dangerId = self.nextDangerId -- 3183
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 3184
	self.nextDangerId = self.nextDangerId + 1 -- 3185
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 3186
	if after > before then -- 3186
		self:flashSet( -- 3188
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 3188
			1 -- 3188
		) -- 3188
	elseif not exposed then -- 3188
		self:flashSet("枪声没够到她", 0.5) -- 3190
	end -- 3190
end -- 3159
function Play.prototype.childExposed(self, dangerX) -- 3195
	local c = self.partner -- 3196
	if not c.alive then -- 3196
		return false -- 3198
	end -- 3198
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 3198
		self.boxes, -- 3201
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 3201
	) then -- 3201
		return false -- 3202
	end -- 3202
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 3202
		return false -- 3205
	end -- 3205
	local toDanger = dangerX - c.x -- 3207
	local toPlayer = self.player.x - c.x -- 3208
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 3208
		return false -- 3211
	end -- 3211
	return true -- 3213
end -- 3195
function Play.prototype.raycastEnemies(self, ray) -- 3217
	local best = -1 -- 3218
	local bestI = -1 -- 3219
	do -- 3219
		local i = 0 -- 3220
		while i < #self.enemies do -- 3220
			do -- 3220
				local e = self.enemies[i + 1] -- 3221
				if not e.alive then -- 3221
					goto __continue565 -- 3223
				end -- 3223
				local y = e.y + (e.depth or 0) -- 3225
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 3226
				if t >= 0 and (best < 0 or t < best) then -- 3226
					best = t -- 3228
					bestI = i -- 3229
				end -- 3229
			end -- 3229
			::__continue565:: -- 3229
			i = i + 1 -- 3220
		end -- 3220
	end -- 3220
	return {t = best, index = bestI} -- 3232
end -- 3217
function Play.prototype.raycastWorld(self, ray) -- 3235
	return self:raycastSolid(ray).t -- 3236
end -- 3235
function Play.prototype.raycastSolid(self, ray) -- 3240
	local best = -1 -- 3241
	local bestBox = nil -- 3242
	for ____, box in ipairs(self.boxes) do -- 3243
		do -- 3243
			if box.broken == true or box.hidden == true then -- 3243
				goto __continue570 -- 3245
			end -- 3245
			local t = hitBox(ray, box) -- 3250
			if t > 2 and (best < 0 or t < best) then -- 3250
				best = t -- 3253
				bestBox = box -- 3254
			end -- 3254
		end -- 3254
		::__continue570:: -- 3254
	end -- 3254
	if ray.dy < 0 then -- 3254
		local t = -ray.y / ray.dy -- 3258
		if t >= 0 and (best < 0 or t < best) then -- 3258
			best = t -- 3260
			bestBox = nil -- 3261
		end -- 3261
	end -- 3261
	return {t = best, box = bestBox} -- 3264
end -- 3240
function Play.prototype.dropFor(self, e) -- 3268
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 3268
		return -- 3270
	end -- 3270
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 3270
		return -- 3273
	end -- 3273
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 3275
	local ____self_pickups_55 = self.pickups -- 3275
	____self_pickups_55[#____self_pickups_55 + 1] = { -- 3276
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 3277
		kind = e.drop, -- 3277
		x = e.x, -- 3277
		y = e.y, -- 3277
		depth = e.depth, -- 3278
		label = label .. " ×1" -- 3278
	} -- 3278
	self:log("掉落 " .. label) -- 3280
end -- 3268
function Play.prototype.damageProp(self, b, amount) -- 3284
	if b.breakable == nil or b.broken == true then -- 3284
		return -- 3286
	end -- 3286
	local ____b_breakable_56, ____hp_57 = b.breakable, "hp" -- 3286
	____b_breakable_56[____hp_57] = ____b_breakable_56[____hp_57] - amount -- 3288
	if b.breakable.hp > 0 then -- 3288
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3290
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3291
		return -- 3292
	end -- 3292
	b.broken = true -- 3294
	for ____, other in ipairs(self.boxes) do -- 3295
		if other.id ~= nil and other.id == b.id then -- 3295
			other.broken = true -- 3297
		end -- 3297
	end -- 3297
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3300
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3301
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3302
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3303
end -- 3284
function Play.prototype.slideDepth(self, a, distance) -- 3307
	a.depth = self:limitDepth(a, a.depth + distance) -- 3308
end -- 3307
function Play.prototype.limitDepth(self, a, target) -- 3311
	local road = self.room.depth -- 3312
	if road == nil or target == a.depth then -- 3312
		return a.depth -- 3314
	end -- 3314
	local next = math.max( -- 3316
		road.min, -- 3316
		math.min(road.max, target) -- 3316
	) -- 3316
	local half = a.w / 2 -- 3317
	for ____, b in ipairs(self.boxes) do -- 3318
		do -- 3318
			local footprint = b.depth -- 3319
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3319
				goto __continue588 -- 3324
			end -- 3324
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3326
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3327
			if a.depth <= front and next > front then -- 3327
				next = front -- 3329
			elseif a.depth >= back and next < back then -- 3329
				next = back -- 3331
			end -- 3331
		end -- 3331
		::__continue588:: -- 3331
	end -- 3331
	return next -- 3334
end -- 3311
function Play.prototype.slideX(self, a, dx) -- 3338
	local nx = a.x + dx -- 3339
	local half = a.w / 2 -- 3340
	local room = self.room -- 3341
	nx = math.max( -- 3342
		room.minX + half, -- 3342
		math.min(room.maxX - half, nx) -- 3342
	) -- 3342
	local i = 0 -- 3343
	do -- 3343
		i = 0 -- 3344
		while i < #self.boxes do -- 3344
			do -- 3344
				local b = self.boxes[i + 1] -- 3345
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3345
					goto __continue595 -- 3347
				end -- 3347
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3347
					goto __continue595 -- 3350
				end -- 3350
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3350
					goto __continue595 -- 3353
				end -- 3353
				if nx + half > b.x0 and nx - half < b.x1 then -- 3353
					if a.x <= b.x0 then -- 3353
						nx = b.x0 - half -- 3357
					elseif a.x >= b.x1 then -- 3357
						nx = b.x1 + half -- 3359
					else -- 3359
						nx = a.x -- 3361
					end -- 3361
				end -- 3361
			end -- 3361
			::__continue595:: -- 3361
			i = i + 1 -- 3344
		end -- 3344
	end -- 3344
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 3344
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 3369
		local bx0 = self.cartAxle - CART_HALF -- 3370
		local bx1 = self.cartAxle + CART_HALF -- 3371
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 3371
			if a.x <= bx0 then -- 3371
				nx = bx0 - half -- 3374
			elseif a.x >= bx1 then -- 3374
				nx = bx1 + half -- 3376
			else -- 3376
				nx = a.x -- 3378
			end -- 3378
		end -- 3378
	end -- 3378
	local arch = room.arch -- 3386
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 3386
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 3388
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 3388
			if a.x <= arch.x0 then -- 3388
				nx = arch.x0 - half -- 3391
			elseif a.x >= arch.x1 then -- 3391
				nx = arch.x1 + half -- 3393
			end -- 3393
		end -- 3393
	end -- 3393
	a.x = nx -- 3397
end -- 3338
function Play.prototype.fallY(self, a, dt) -- 3401
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3402
	if a.vy < -900 then -- 3402
		a.vy = -900 -- 3404
	end -- 3404
	local ny = a.y + a.vy * dt -- 3406
	local half = a.w / 2 -- 3407
	if a.vy <= 0 then -- 3407
		local reach = a.onGround and STEP_UP or 0 -- 3410
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3411
		if ny <= ground then -- 3411
			ny = ground -- 3413
			a.vy = 0 -- 3414
			a.onGround = true -- 3415
		else -- 3415
			a.onGround = false -- 3417
		end -- 3417
	else -- 3417
		a.onGround = false -- 3420
		local i = 0 -- 3421
		do -- 3421
			i = 0 -- 3422
			while i < #self.boxes do -- 3422
				do -- 3422
					local b = self.boxes[i + 1] -- 3423
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3423
						goto __continue619 -- 3425
					end -- 3425
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3425
						goto __continue619 -- 3428
					end -- 3428
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3428
						goto __continue619 -- 3431
					end -- 3431
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3431
						ny = b.y0 - a.h -- 3434
						a.vy = 0 -- 3435
					end -- 3435
				end -- 3435
				::__continue619:: -- 3435
				i = i + 1 -- 3422
			end -- 3422
		end -- 3422
	end -- 3422
	a.y = ny -- 3439
end -- 3401
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3443
	if depth == nil then -- 3443
		depth = 0 -- 3443
	end -- 3443
	local g = -9999 -- 3444
	local i = 0 -- 3445
	do -- 3445
		i = 0 -- 3446
		while i < #self.floors do -- 3446
			local f = self.floors[i + 1] -- 3447
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3447
				g = f.y1 -- 3449
			end -- 3449
			i = i + 1 -- 3446
		end -- 3446
	end -- 3446
	do -- 3446
		i = 0 -- 3452
		while i < #self.boxes do -- 3452
			do -- 3452
				local b = self.boxes[i + 1] -- 3453
				if b.broken == true or b.hidden == true or b.soft == true then -- 3453
					goto __continue629 -- 3455
				end -- 3455
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3455
					g = b.y1 -- 3459
				end -- 3459
			end -- 3459
			::__continue629:: -- 3459
			i = i + 1 -- 3452
		end -- 3452
	end -- 3452
	return g -- 3462
end -- 3443
function Play.prototype.updateCamera(self, dt) -- 3465
	local p = self.player -- 3466
	local tx = p.x + p.facing * 30 -- 3467
	local ty = p.y + CAM_LOOK_UP -- 3468
	local k = math.min(1, CAM_FOLLOW * dt) -- 3469
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3470
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3471
end -- 3465
function Play.prototype.clampCamera(self, w, h) -- 3475
	local room = self.room -- 3476
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3477
	local spanX = room.maxX - room.minX -- 3478
	if spanX <= halfW * 2 then -- 3478
		self.cam.x = (room.minX + room.maxX) / 2 -- 3480
	else -- 3480
		self.cam.x = math.max( -- 3482
			room.minX + halfW, -- 3482
			math.min(room.maxX - halfW, self.cam.x) -- 3482
		) -- 3482
	end -- 3482
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3485
	local spanY = room.height -- 3486
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3487
	if spanY <= halfH * 2 then -- 3487
		self.cam.y = camY -- 3489
	else -- 3489
		self.cam.y = math.max( -- 3491
			camY, -- 3491
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3491
		) -- 3491
	end -- 3491
end -- 3475
function Play.prototype.flashSet(self, text, t) -- 3495
	self.flash = text -- 3496
	self.flashT = t -- 3497
end -- 3495
function Play.prototype.statusText(self) -- 3501
	local p = self.player -- 3502
	local parts = {} -- 3503
	local who = self.childMode and "小满" or "周戍" -- 3504
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3505
	if self.room.key == "prologue" then -- 3505
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3508
		if self.phase == "prologue-wait" then -- 3508
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3510
		elseif self.phase == "prologue-give" then -- 3510
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3512
		else -- 3512
			parts[#parts + 1] = "跟随" -- 3514
		end -- 3514
		if self.paused then -- 3514
			parts[#parts + 1] = "已暂停" -- 3517
		end -- 3517
		return table.concat(parts, " · ") -- 3519
	end -- 3519
	if self.room.key == "street" then -- 3519
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3522
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3523
		if self.paused then -- 3523
			parts[#parts + 1] = "已暂停" -- 3525
		end -- 3525
		return table.concat(parts, " · ") -- 3527
	end -- 3527
	if self.room.key == "gate" then -- 3527
		local ____temp_58 -- 3530
		if self.room.story == nil then -- 3530
			____temp_58 = nil -- 3530
		else -- 3530
			____temp_58 = self.room.story.gate -- 3530
		end -- 3530
		local g = ____temp_58 -- 3530
		if g ~= nil then -- 3530
			parts[#parts + 1] = self:gateLabel() -- 3532
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3533
				0, -- 3534
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3534
			))) .. " 秒" -- 3534
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3535
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3536
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3537
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3538
			if self.gateFailCount > 0 then -- 3538
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3540
			end -- 3540
			if self.flash ~= "" then -- 3540
				parts[#parts + 1] = self.flash -- 3543
			end -- 3543
		end -- 3543
		if self.paused then -- 3543
			parts[#parts + 1] = "已暂停" -- 3547
		end -- 3547
		return table.concat(parts, " · ") -- 3549
	end -- 3549
	if self.room.key == "forest" then -- 3549
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3552
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3553
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3554
		if self.caughtT > 0 then -- 3554
			parts[#parts + 1] = "复位中" -- 3556
		end -- 3556
		if self.paused then -- 3556
			parts[#parts + 1] = "已暂停" -- 3559
		end -- 3559
		return table.concat(parts, " · ") -- 3561
	end -- 3561
	if self.room.key == "tower" then -- 3561
		if self.phase == "tower-wait" then -- 3561
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3565
		elseif self.phase == "tower-knock" then -- 3565
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3567
		elseif self.phase == "tower-given" then -- 3567
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3569
		else -- 3569
			parts[#parts + 1] = "片尾" -- 3571
		end -- 3571
		if self.paused then -- 3571
			parts[#parts + 1] = "已暂停" -- 3574
		end -- 3574
		return table.concat(parts, " · ") -- 3576
	end -- 3576
	if self.room.key == "village" then -- 3576
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3579
		if self.hasBottle then -- 3579
			parts[#parts + 1] = "有瓶" -- 3581
		elseif self.bottleFly ~= nil then -- 3581
			parts[#parts + 1] = "瓶在飞" -- 3583
		else -- 3583
			parts[#parts + 1] = "空手" -- 3585
		end -- 3585
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3587
		if self.scavChase then -- 3587
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3589
		end -- 3589
		if self.passed then -- 3589
			parts[#parts + 1] = "已过通行线" -- 3592
		end -- 3592
		if self.paused then -- 3592
			parts[#parts + 1] = "已暂停" -- 3595
		end -- 3595
		return table.concat(parts, " · ") -- 3597
	end -- 3597
	local isChild = self.childMode -- 3600
	if isChild then -- 3600
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3602
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3603
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3604
	else -- 3604
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3606
		if p.rollT > 0 then -- 3606
			parts[#parts + 1] = "翻滚中" -- 3608
		end -- 3608
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3610
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3611
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3612
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3613
	end -- 3613
	if self.checkpoint >= 0 then -- 3613
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3616
	end -- 3616
	if self.paused then -- 3616
		parts[#parts + 1] = "已暂停" -- 3619
	end -- 3619
	return table.concat(parts, " · ") -- 3621
end -- 3501
function Play.prototype.aliveEnemies(self) -- 3625
	local n = 0 -- 3626
	local i = 0 -- 3627
	do -- 3627
		i = 0 -- 3628
		while i < #self.enemies do -- 3628
			if self.enemies[i + 1].alive then -- 3628
				n = n + 1 -- 3630
			end -- 3630
			i = i + 1 -- 3628
		end -- 3628
	end -- 3628
	return n -- 3633
end -- 3625
function Play.prototype.threatened(self) -- 3638
	do -- 3638
		local i = 0 -- 3639
		while i < #self.enemies do -- 3639
			local e = self.enemies[i + 1] -- 3640
			if e.alive and e.warnT > 0 then -- 3640
				return true -- 3642
			end -- 3642
			i = i + 1 -- 3639
		end -- 3639
	end -- 3639
	return false -- 3645
end -- 3638
function Play.prototype.gateSecondsLeft(self) -- 3648
	local ____temp_59 -- 3649
	if self.room.story == nil then -- 3649
		____temp_59 = nil -- 3649
	else -- 3649
		____temp_59 = self.room.story.gate -- 3649
	end -- 3649
	local g = ____temp_59 -- 3649
	if g == nil then -- 3649
		return 0 -- 3651
	end -- 3651
	return math.max( -- 3653
		0, -- 3653
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3653
	) -- 3653
end -- 3648
function Play.prototype.gateLabel(self) -- 3656
	if self.phase == "gate-idle" then -- 3656
		return "待就位" -- 3658
	end -- 3658
	if self.phase == "gate-hold" then -- 3658
		return "守点中" -- 3661
	end -- 3661
	if self.phase == "gate-send" then -- 3661
		return "送别" -- 3664
	end -- 3664
	if self.phase == "gate-count" then -- 3664
		return "数数 " .. tostring(self.countTick) -- 3667
	end -- 3667
	return "她走" -- 3669
end -- 3656
function Play.prototype.dogLabel(self) -- 3673
	if self.dogState == "ear" then -- 3673
		return "转耳" -- 3675
	end -- 3675
	if self.dogState == "chase" then -- 3675
		return "追" -- 3678
	end -- 3678
	if self.dogState == "sniff" then -- 3678
		return "停" -- 3681
	end -- 3681
	if self.dogState == "back" then -- 3681
		return "回线" -- 3684
	end -- 3684
	return "巡逻" -- 3686
end -- 3673
function Play.prototype.doorXOf(self) -- 3689
	local ____temp_60 -- 3690
	if self.room.story == nil then -- 3690
		____temp_60 = nil -- 3690
	else -- 3690
		____temp_60 = self.room.story.tower -- 3690
	end -- 3690
	local t = ____temp_60 -- 3690
	return t == nil and 0 or t.doorX -- 3691
end -- 3689
function Play.prototype.scavLabel(self) -- 3695
	if self.scavState == "chase" then -- 3695
		return "追" -- 3697
	end -- 3697
	if self.scavState == "turn" then -- 3697
		return "转头" -- 3700
	end -- 3700
	if self.scavState == "walk" then -- 3700
		return "赶来" -- 3703
	end -- 3703
	if self.scavState == "stall" then -- 3703
		return "停住" -- 3706
	end -- 3706
	if self.scavState == "back" then -- 3706
		return "回位" -- 3709
	end -- 3709
	return "巡逻" -- 3711
end -- 3695
function Play.prototype.hintText(self) -- 3715
	if self.paused then -- 3715
		return "Esc 继续 · R 重置" -- 3717
	end -- 3717
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3717
		if self:threatened() then -- 3717
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3723
		end -- 3723
		if self.coverHug then -- 3723
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3726
		end -- 3726
		if self.coverNear then -- 3726
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3729
		end -- 3729
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3731
	end -- 3731
	if self.flash ~= "" then -- 3731
		return self.flash -- 3734
	end -- 3734
	if self.room.key == "prologue" then -- 3734
		if self.phase == "prologue-wait" then -- 3734
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3738
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3739
		end -- 3739
		if self.phase == "prologue-give" then -- 3739
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3742
		end -- 3742
		return "她跟着你了 · 两人一起走到门口 680" -- 3744
	end -- 3744
	if self.room.key == "street" then -- 3744
		if self:aliveEnemies() > 0 then -- 3744
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3748
		end -- 3748
		return "清完了 · 两人一起走到右边检查站入口 900" -- 3750
	end -- 3750
	if self.room.key == "gate" then -- 3750
		local ____temp_61 -- 3753
		if self.room.story == nil then -- 3753
			____temp_61 = nil -- 3753
		else -- 3753
			____temp_61 = self.room.story.gate -- 3753
		end -- 3753
		local g = ____temp_61 -- 3753
		if g ~= nil then -- 3753
			if self.phase == "gate-idle" then -- 3753
				if self.gateNeedConfirm then -- 3753
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 3757
				end -- 3757
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 3759
			end -- 3759
			if self.phase == "gate-hold" then -- 3759
				if self.coveredFlash > 0 then -- 3759
					return "掩体挡下了这一枪 · 别露头" -- 3763
				end -- 3763
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 3765
			end -- 3765
			if self.phase == "gate-send" then -- 3765
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 3768
			end -- 3768
			if self.phase == "gate-count" then -- 3768
				if self.countTick >= ____exports.GATE_COUNT_END then -- 3768
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 3772
				end -- 3772
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 3774
			end -- 3774
			return "她自己走 · 跟着出城门 1120" -- 3776
		end -- 3776
	end -- 3776
	if self.room.key == "forest" then -- 3776
		if self.dogState == "chase" then -- 3776
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 3781
		end -- 3781
		if self.dogState == "ear" then -- 3781
			return "狗转耳朵了 · 停下或蹲下别出声" -- 3784
		end -- 3784
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 3786
	end -- 3786
	if self.room.key == "tower" then -- 3786
		if self.phase == "tower-wait" then -- 3786
			return "走到门前 445 点一次 E 敲两下" -- 3790
		end -- 3790
		if self.phase == "tower-knock" then -- 3790
			return "敲两下 · 等门开" -- 3793
		end -- 3793
		if self.phase == "tower-given" then -- 3793
			return "递交针套和纸条 · 看登记簿最后一行" -- 3796
		end -- 3796
		return "片尾 · 点 E 再玩一次，回到序章" -- 3798
	end -- 3798
	if self.room.key == "village" then -- 3798
		if self.bottleFly ~= nil then -- 3798
			return "等瓶子落地 · 触地才发声" -- 3802
		end -- 3802
		if self.hasBottle then -- 3802
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 3805
		end -- 3805
		if self.passed then -- 3805
			return "已过第一院 · R 重置可再来一遍" -- 3808
		end -- 3808
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 3810
	end -- 3810
	if self.room.key == "outside" then -- 3810
		if self.focusCart then -- 3810
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 3814
		end -- 3814
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 3816
	end -- 3816
	if self.escort.state == "frozen" then -- 3816
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 3816
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 3820
		end -- 3820
		return "小满吓住了 · 走过去，靠近再点 E" -- 3822
	end -- 3822
	if self.escort.state == "calming" then -- 3822
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 3825
	end -- 3825
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 3827
end -- 3715
function Play.prototype.draw(self, draw, w, h) -- 3832
	self.viewW = w -- 3833
	self.viewH = h -- 3834
	self.view = ____exports.computeViewport(w, h) -- 3835
	self:clampCamera(w, h) -- 3836
	draw:clear() -- 3837
	draw:drawRect( -- 3839
		Rect(0, 0, w, h), -- 3839
		BG_VOID -- 3839
	) -- 3839
	local box = self:canvasRect(w, h) -- 3840
	draw:drawRect(box, BG_FAR) -- 3841
	draw:drawRect( -- 3842
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 3842
		BG_MID -- 3842
	) -- 3842
	self:drawFloors(draw, w, h) -- 3844
	self:drawSolids(draw, w, h) -- 3845
	self:drawZones(draw, w, h) -- 3846
	self:drawArch(draw, w, h) -- 3847
	self:drawCart(draw, w, h) -- 3848
	self:drawCampaignProps(draw, w, h) -- 3849
	self:drawActors(draw, w, h) -- 3850
	self:drawTrace(draw, w, h) -- 3851
	self:drawAim(draw, w, h) -- 3852
end -- 3832
function Play.prototype.canvasRect(self, w, h) -- 3856
	local v = self.view -- 3857
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 3858
end -- 3856
function Play.prototype.px(self, n) -- 3862
	return n * self.view.zoom -- 3863
end -- 3862
function Play.prototype.sx(self, wx, w) -- 3867
	local v = self.view -- 3868
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 3869
	return v.ox + lx * v.zoom -- 3870
end -- 3867
function Play.prototype.sy(self, wy, h) -- 3874
	local v = self.view -- 3875
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 3876
	return v.oy + ly * v.zoom -- 3877
end -- 3874
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 3880
	local px0 = self:sx(x0, w) -- 3881
	local px1 = self:sx(x1, w) -- 3882
	local py0 = self:sy(y0, h) -- 3883
	local py1 = self:sy(y1, h) -- 3884
	if px1 <= px0 or py1 <= py0 then -- 3884
		return -- 3886
	end -- 3886
	draw:drawRect( -- 3888
		Rect(px0, py0, px1 - px0, py1 - py0), -- 3888
		color -- 3888
	) -- 3888
end -- 3880
function Play.prototype.drawFloors(self, draw, w, h) -- 3891
	local i = 0 -- 3892
	do -- 3892
		i = 0 -- 3893
		while i < #self.room.floors do -- 3893
			local f = self.room.floors[i + 1] -- 3894
			local ____temp_62 -- 3895
			if f.y == 0 then -- 3895
				____temp_62 = self.room.depth -- 3895
			else -- 3895
				____temp_62 = nil -- 3895
			end -- 3895
			local road = ____temp_62 -- 3895
			local y = self:sy(f.y + (road and road.min or 0), h) -- 3896
			local x0 = self:sx(f.x0, w) -- 3897
			local x1 = self:sx(f.x1, w) -- 3898
			local deck = self:px(5) -- 3899
			if road ~= nil then -- 3899
				local back = self:sy(f.y + road.max, h) -- 3901
				draw:drawRect( -- 3902
					Rect(x0, y, x1 - x0, back - y), -- 3902
					FLOOR_DECK, -- 3902
					self:px(1), -- 3902
					SOLID_EDGE -- 3902
				) -- 3902
			end -- 3902
			draw:drawRect( -- 3904
				Rect(x0, y - deck, x1 - x0, deck), -- 3904
				FLOOR_DECK -- 3904
			) -- 3904
			draw:drawSegment( -- 3905
				Vec2(x0, y), -- 3905
				Vec2(x1, y), -- 3905
				self:px(1), -- 3905
				GROUND -- 3905
			) -- 3905
			i = i + 1 -- 3893
		end -- 3893
	end -- 3893
end -- 3891
function Play.prototype.drawSolids(self, draw, w, h) -- 3909
	local i = 0 -- 3910
	do -- 3910
		i = 0 -- 3911
		while i < #self.boxes do -- 3911
			do -- 3911
				local b = self.boxes[i + 1] -- 3912
				if b.id == "braced_shield" or b.hidden == true then -- 3912
					goto __continue750 -- 3914
				end -- 3914
				if b.broken == true then -- 3914
					if b.breakable ~= nil then -- 3914
						local gy = self:sy(b.y0, h) -- 3919
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 3920
						local k = 0 -- 3921
						do -- 3921
							k = 0 -- 3922
							while k < 3 do -- 3922
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 3923
								draw:drawSegment( -- 3924
									Vec2( -- 3924
										gx - self:px(4), -- 3924
										gy + self:px(k % 2) -- 3924
									), -- 3924
									Vec2( -- 3924
										gx + self:px(5), -- 3924
										gy + self:px(k % 2) -- 3924
									), -- 3924
									self:px(1), -- 3924
									rgb -- 3924
								) -- 3924
								k = k + 1 -- 3922
							end -- 3922
						end -- 3922
					end -- 3922
					goto __continue750 -- 3927
				end -- 3927
				local ____opt_65 = b.depth -- 3927
				local front = ____opt_65 and ____opt_65.min or 0 -- 3929
				local ____opt_67 = b.depth -- 3929
				local back = ____opt_67 and ____opt_67.max or 0 -- 3930
				local fill = SOLID_FILL -- 3931
				local line = SOLID_EDGE -- 3932
				if b.soft == true then -- 3932
					fill = SOFT -- 3934
					line = SOFT_LINE -- 3935
				elseif b.breakable ~= nil then -- 3935
					line = DANGER_LINE -- 3937
					fill = Color(0.3, 0.24, 0.16, 1) -- 3938
				elseif b.interact ~= nil then -- 3938
					line = PASS_LINE -- 3940
				end -- 3940
				self:drawBox( -- 3942
					draw, -- 3942
					w, -- 3942
					h, -- 3942
					b.x0, -- 3942
					b.x1, -- 3942
					b.y0 + front, -- 3942
					b.y1 + back, -- 3942
					fill -- 3942
				) -- 3942
				draw:drawSegment( -- 3943
					Vec2( -- 3943
						self:sx(b.x0, w), -- 3943
						self:sy(b.y1 + front, h) -- 3943
					), -- 3943
					Vec2( -- 3944
						self:sx(b.x1, w), -- 3944
						self:sy(b.y1 + front, h) -- 3944
					), -- 3944
					self:px(1), -- 3944
					line -- 3944
				) -- 3944
				if b.breakable ~= nil then -- 3944
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 3947
					local cyp = self:sy(b.y1 + front, h) -- 3948
					draw:drawSegment( -- 3949
						Vec2( -- 3949
							cxp - self:px(4), -- 3949
							cyp + self:px(1) -- 3949
						), -- 3949
						Vec2( -- 3949
							cxp + self:px(3), -- 3949
							cyp + self:px(5) -- 3949
						), -- 3949
						self:px(1), -- 3949
						line -- 3949
					) -- 3949
				end -- 3949
			end -- 3949
			::__continue750:: -- 3949
			i = i + 1 -- 3911
		end -- 3911
	end -- 3911
end -- 3909
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 3955
	local i = 0 -- 3956
	do -- 3956
		i = 0 -- 3957
		while i < #self.pickups do -- 3957
			do -- 3957
				local pk = self.pickups[i + 1] -- 3958
				if pk.id == "" then -- 3958
					goto __continue762 -- 3960
				end -- 3960
				local gy = pk.y + (pk.depth or 0) -- 3962
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 3963
				draw:drawRect( -- 3964
					Rect( -- 3964
						self:sx(pk.x - 5, w), -- 3964
						self:sy(gy + 12 + bob, h), -- 3964
						self:px(10), -- 3964
						self:px(10) -- 3964
					), -- 3964
					Color(0.84, 0.7, 0.3, 1) -- 3965
				) -- 3965
				draw:drawSegment( -- 3966
					Vec2( -- 3966
						self:sx(pk.x - 5, w), -- 3966
						self:sy(gy + 12 + bob, h) -- 3966
					), -- 3966
					Vec2( -- 3967
						self:sx(pk.x + 5, w), -- 3967
						self:sy(gy + 12 + bob, h) -- 3967
					), -- 3967
					self:px(1), -- 3967
					Color(0.95, 0.86, 0.52, 1) -- 3967
				) -- 3967
			end -- 3967
			::__continue762:: -- 3967
			i = i + 1 -- 3957
		end -- 3957
	end -- 3957
	if self.bracedShield ~= nil then -- 3957
		local sh = self.bracedShield -- 3970
		draw:drawRect( -- 3971
			Rect( -- 3971
				self:sx(sh.x - sh.w / 2, w), -- 3971
				self:sy(sh.y, h), -- 3971
				self:px(sh.w), -- 3971
				self:px(sh.h) -- 3971
			), -- 3971
			Color(0.42, 0.4, 0.34, 1) -- 3972
		) -- 3972
		draw:drawSegment( -- 3973
			Vec2( -- 3973
				self:sx(sh.x - sh.w / 2, w), -- 3973
				self:sy(sh.y + sh.h, h) -- 3973
			), -- 3973
			Vec2( -- 3974
				self:sx(sh.x + sh.w / 2, w), -- 3974
				self:sy(sh.y + sh.h, h) -- 3974
			), -- 3974
			self:px(1), -- 3974
			Color(0.74, 0.72, 0.62, 1) -- 3974
		) -- 3974
	end -- 3974
end -- 3955
function Play.prototype.drawZones(self, draw, w, h) -- 3978
	local i = 0 -- 3979
	do -- 3979
		i = 0 -- 3980
		while i < #self.room.zones do -- 3980
			local z = self.room.zones[i + 1] -- 3981
			local fill = DANGER -- 3982
			local line = DANGER_LINE -- 3983
			if z.tint == 2 then -- 3983
				fill = SOFT -- 3985
				line = SOFT_LINE -- 3986
			elseif z.tint == 3 then -- 3986
				fill = BRICK -- 3988
				line = BRICK_LINE -- 3989
			elseif z.tint == 4 then -- 3989
				fill = PASS -- 3991
				line = PASS_LINE -- 3992
			end -- 3992
			self:drawBox( -- 3994
				draw, -- 3994
				w, -- 3994
				h, -- 3994
				z.x0, -- 3994
				z.x1, -- 3994
				z.y, -- 3994
				z.y + z.h, -- 3994
				fill -- 3994
			) -- 3994
			draw:drawSegment( -- 3995
				Vec2( -- 3995
					self:sx(z.x0, w), -- 3995
					self:sy(z.y, h) -- 3995
				), -- 3995
				Vec2( -- 3995
					self:sx(z.x0, w), -- 3995
					self:sy(z.y + z.h, h) -- 3995
				), -- 3995
				self:px(1), -- 3995
				line -- 3995
			) -- 3995
			draw:drawSegment( -- 3996
				Vec2( -- 3996
					self:sx(z.x1, w), -- 3996
					self:sy(z.y, h) -- 3996
				), -- 3996
				Vec2( -- 3996
					self:sx(z.x1, w), -- 3996
					self:sy(z.y + z.h, h) -- 3996
				), -- 3996
				self:px(1), -- 3996
				line -- 3996
			) -- 3996
			i = i + 1 -- 3980
		end -- 3980
	end -- 3980
end -- 3978
function Play.prototype.drawArch(self, draw, w, h) -- 4000
	local a = self.room.arch -- 4001
	if a.h <= 0 then -- 4001
		return -- 4003
	end -- 4003
	self:drawBox( -- 4005
		draw, -- 4005
		w, -- 4005
		h, -- 4005
		a.x0, -- 4005
		a.x1, -- 4005
		a.y, -- 4005
		a.y + a.h, -- 4005
		HOLE_FILL -- 4005
	) -- 4005
	draw:drawSegment( -- 4006
		Vec2( -- 4006
			self:sx(a.x0, w), -- 4006
			self:sy(a.y + a.h, h) -- 4006
		), -- 4006
		Vec2( -- 4006
			self:sx(a.x1, w), -- 4006
			self:sy(a.y + a.h, h) -- 4006
		), -- 4006
		self:px(1), -- 4006
		SOLID_EDGE -- 4006
	) -- 4006
	draw:drawSegment( -- 4007
		Vec2( -- 4007
			self:sx(a.x0, w), -- 4007
			self:sy(a.y, h) -- 4007
		), -- 4007
		Vec2( -- 4007
			self:sx(a.x0, w), -- 4007
			self:sy(a.y + a.h, h) -- 4007
		), -- 4007
		self:px(1), -- 4007
		SOLID_EDGE -- 4007
	) -- 4007
	draw:drawSegment( -- 4008
		Vec2( -- 4008
			self:sx(a.x1, w), -- 4008
			self:sy(a.y, h) -- 4008
		), -- 4008
		Vec2( -- 4008
			self:sx(a.x1, w), -- 4008
			self:sy(a.y + a.h, h) -- 4008
		), -- 4008
		self:px(1), -- 4008
		SOLID_EDGE -- 4008
	) -- 4008
end -- 4000
function Play.prototype.drawCart(self, draw, w, h) -- 4011
	local c = self.room.cart -- 4012
	if c.bodyW <= 0 then -- 4012
		return -- 4014
	end -- 4014
	drawCartShape( -- 4016
		draw, -- 4016
		self, -- 4016
		w, -- 4016
		h, -- 4016
		c, -- 4016
		self.cartAxle -- 4016
	) -- 4016
	draw:drawRect( -- 4017
		Rect( -- 4017
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4017
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4017
			self:px(2), -- 4017
			self:px(40) -- 4017
		), -- 4017
		STAND -- 4017
	) -- 4017
end -- 4011
function Play.prototype.drawActors(self, draw, w, h) -- 4020
	local p = self.player -- 4021
	local isChild = self.childMode -- 4022
	local footY = p.y + p.depth -- 4023
	if p.covered then -- 4023
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4026
		draw:drawSegment( -- 4027
			Vec2( -- 4027
				self:sx(edge, w), -- 4027
				self:sy(footY + 8, h) -- 4027
			), -- 4027
			Vec2( -- 4027
				self:sx(edge, w), -- 4027
				self:sy(footY + p.h * 0.62, h) -- 4027
			), -- 4027
			self:px(2), -- 4027
			STAND -- 4027
		) -- 4027
		draw:drawSegment( -- 4029
			Vec2( -- 4029
				self:sx(p.x - 8, w), -- 4029
				self:sy(footY + p.h + 3, h) -- 4029
			), -- 4029
			Vec2( -- 4029
				self:sx(p.x + 8, w), -- 4029
				self:sy(footY + p.h + 3, h) -- 4029
			), -- 4029
			self:px(2), -- 4029
			STAND -- 4029
		) -- 4029
	elseif self.coverNear and not isChild then -- 4029
		draw:drawRect( -- 4032
			Rect( -- 4032
				self:sx(p.x - 3, w), -- 4032
				self:sy(footY + 1, h), -- 4032
				self:px(3), -- 4032
				self:px(3) -- 4032
			), -- 4032
			STAND -- 4032
		) -- 4032
	end -- 4032
	drawFigure( -- 4034
		draw, -- 4034
		self, -- 4034
		w, -- 4034
		h, -- 4034
		p, -- 4034
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4034
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4034
	) -- 4034
	local q = self.partner -- 4035
	if q.alive then -- 4035
		local childPartner = q.w == CHILD_W -- 4037
		drawFigure( -- 4038
			draw, -- 4038
			self, -- 4038
			w, -- 4038
			h, -- 4038
			q, -- 4038
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4038
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4038
		) -- 4038
	end -- 4038
	local i = 0 -- 4040
	do -- 4040
		i = 0 -- 4041
		while i < #self.enemies do -- 4041
			local e = self.enemies[i + 1] -- 4042
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4043
			local enemyY = e.y + (e.depth or 0) -- 4044
			self:drawBox( -- 4045
				draw, -- 4045
				w, -- 4045
				h, -- 4045
				e.x - e.w / 2, -- 4045
				e.x + e.w / 2, -- 4045
				enemyY, -- 4045
				enemyY + e.h, -- 4045
				col -- 4045
			) -- 4045
			if e.alive then -- 4045
				local ef = p.x >= e.x and 1 or -1 -- 4047
				if e.kind == "shield" then -- 4047
					local sh = (e.shieldHp or 0) > 0 -- 4049
					draw:drawRect( -- 4050
						Rect( -- 4050
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4050
							self:sy(enemyY, h), -- 4050
							self:px(6), -- 4050
							self:px(64) -- 4050
						), -- 4050
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4051
					) -- 4051
				elseif e.kind == "breaker" then -- 4051
					draw:drawSegment( -- 4053
						Vec2( -- 4053
							self:sx(e.x + ef * 12, w), -- 4053
							self:sy(enemyY + 8, h) -- 4053
						), -- 4053
						Vec2( -- 4054
							self:sx(e.x + ef * 22, w), -- 4054
							self:sy(enemyY + 46, h) -- 4054
						), -- 4054
						self:px(3), -- 4054
						Color(0.5, 0.36, 0.22, 1) -- 4054
					) -- 4054
				end -- 4054
			end -- 4054
			if e.alive and e.warnT > 0 then -- 4054
				local gunX = self:sx(e.x, w) -- 4059
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4060
				local aimX = self:sx(p.x, w) -- 4061
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4062
				local seg = 8 -- 4063
				local s = 0 -- 4064
				do -- 4064
					s = 0 -- 4065
					while s < seg do -- 4065
						local t0 = s / seg -- 4066
						local t1 = (s + 1) / seg -- 4067
						draw:drawSegment( -- 4068
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4069
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4070
							self:px(1), -- 4071
							DANGER -- 4071
						) -- 4071
						s = s + 2 -- 4065
					end -- 4065
				end -- 4065
			end -- 4065
			i = i + 1 -- 4041
		end -- 4041
	end -- 4041
	local k = 0 -- 4076
	do -- 4076
		k = 0 -- 4077
		while k < #self.room.marks do -- 4077
			do -- 4077
				local m = self.room.marks[k + 1] -- 4078
				if m.kind ~= 0 then -- 4078
					goto __continue788 -- 4080
				end -- 4080
				local on = self.checkpoint == m.x -- 4082
				local x = self:sx(m.x, w) -- 4083
				local y = self:sy(m.y, h) -- 4084
				draw:drawSegment( -- 4085
					Vec2(x, y), -- 4085
					Vec2( -- 4085
						x, -- 4085
						y + self:px(35) -- 4085
					), -- 4085
					self:px(1), -- 4085
					on and CHECK or INK_DIM -- 4085
				) -- 4085
				draw:drawDot( -- 4086
					Vec2( -- 4086
						x, -- 4086
						y + self:px(35) -- 4086
					), -- 4086
					self:px(2), -- 4086
					on and CHECK or INK_DIM -- 4086
				) -- 4086
			end -- 4086
			::__continue788:: -- 4086
			k = k + 1 -- 4077
		end -- 4077
	end -- 4077
	local j = 0 -- 4090
	do -- 4090
		j = 0 -- 4091
		while j < #self.room.marks do -- 4091
			do -- 4091
				local m = self.room.marks[j + 1] -- 4092
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4092
					goto __continue791 -- 4094
				end -- 4094
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4094
					goto __continue791 -- 4098
				end -- 4098
				local col = STAND -- 4100
				if m.kind == 4 then -- 4100
					col = PASS_LINE -- 4102
				elseif m.kind == 5 then -- 4102
					col = BRICK_LINE -- 4104
				end -- 4104
				local mx = self:sx(m.x, w) -- 4106
				local my = self:sy(m.y, h) -- 4107
				draw:drawSegment( -- 4108
					Vec2(mx, my), -- 4108
					Vec2( -- 4108
						mx, -- 4108
						my + self:px(24) -- 4108
					), -- 4108
					self:px(1), -- 4108
					col -- 4108
				) -- 4108
			end -- 4108
			::__continue791:: -- 4108
			j = j + 1 -- 4091
		end -- 4091
	end -- 4091
	local t = 0 -- 4111
	do -- 4111
		t = 0 -- 4112
		while t < #self.room.marks do -- 4112
			do -- 4112
				local m = self.room.marks[t + 1] -- 4113
				if m.kind ~= 6 then -- 4113
					goto __continue797 -- 4115
				end -- 4115
				local mx = self:sx(m.x, w) -- 4117
				local my = self:sy(m.y, h) -- 4118
				draw:drawSegment( -- 4119
					Vec2(mx, my), -- 4119
					Vec2( -- 4119
						mx, -- 4119
						my + self:px(30) -- 4119
					), -- 4119
					self:px(1), -- 4119
					INK_DIM -- 4119
				) -- 4119
				self:drawBox( -- 4120
					draw, -- 4120
					w, -- 4120
					h, -- 4120
					m.x - 5, -- 4120
					m.x + 5, -- 4120
					m.y + 30, -- 4120
					m.y + 40, -- 4120
					CHECK -- 4120
				) -- 4120
			end -- 4120
			::__continue797:: -- 4120
			t = t + 1 -- 4112
		end -- 4112
	end -- 4112
	if self.room.key == "village" then -- 4112
		self:drawVillage(draw, w, h) -- 4123
	end -- 4123
	if self.room.key == "forest" then -- 4123
		self:drawDog(draw, w, h) -- 4126
	end -- 4126
end -- 4020
function Play.prototype.drawDog(self, draw, w, h) -- 4131
	local x = self.dogX -- 4132
	self:drawBox( -- 4133
		draw, -- 4133
		w, -- 4133
		h, -- 4133
		x - 14, -- 4133
		x + 14, -- 4133
		0, -- 4133
		20, -- 4133
		SCAV_BODY -- 4133
	) -- 4133
	self:drawBox( -- 4134
		draw, -- 4134
		w, -- 4134
		h, -- 4134
		x - 10, -- 4134
		x - 2, -- 4134
		20, -- 4134
		30, -- 4134
		SCAV_BODY -- 4134
	) -- 4134
	self:drawBox( -- 4135
		draw, -- 4135
		w, -- 4135
		h, -- 4135
		x + 2, -- 4135
		x + 10, -- 4135
		20, -- 4135
		30, -- 4135
		SCAV_HEAD -- 4135
	) -- 4135
	if self.dogState == "ear" or self.dogState == "chase" then -- 4135
		draw:drawSegment( -- 4137
			Vec2( -- 4137
				self:sx(x, w), -- 4137
				self:sy(30, h) -- 4137
			), -- 4137
			Vec2( -- 4138
				self:sx(x, w), -- 4138
				self:sy(40, h) -- 4138
			), -- 4138
			self:px(1), -- 4138
			DANGER -- 4138
		) -- 4138
	end -- 4138
end -- 4131
function Play.prototype.drawVillage(self, draw, w, h) -- 4143
	local bottle = self.room.bottle -- 4144
	if bottle ~= nil then -- 4144
		self:drawBox( -- 4146
			draw, -- 4146
			w, -- 4146
			h, -- 4146
			bottle.x - 14, -- 4146
			bottle.x + 14, -- 4146
			0, -- 4146
			64, -- 4146
			SOLID_FILL -- 4146
		) -- 4146
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4146
			self:drawBottle( -- 4148
				draw, -- 4148
				w, -- 4148
				h, -- 4148
				bottle.x, -- 4148
				64 -- 4148
			) -- 4148
		end -- 4148
	end -- 4148
	self:drawBox( -- 4152
		draw, -- 4152
		w, -- 4152
		h, -- 4152
		300, -- 4152
		420, -- 4152
		44, -- 4152
		50, -- 4152
		FLOOR_DECK -- 4152
	) -- 4152
	self:drawBox( -- 4153
		draw, -- 4153
		w, -- 4153
		h, -- 4153
		300, -- 4153
		306, -- 4153
		0, -- 4153
		44, -- 4153
		FLOOR_DECK -- 4153
	) -- 4153
	self:drawBox( -- 4154
		draw, -- 4154
		w, -- 4154
		h, -- 4154
		414, -- 4154
		420, -- 4154
		0, -- 4154
		44, -- 4154
		FLOOR_DECK -- 4154
	) -- 4154
	local s = self.room.scavenger -- 4156
	if s ~= nil then -- 4156
		local sx0 = self.scavX -- 4158
		self:drawBox( -- 4159
			draw, -- 4159
			w, -- 4159
			h, -- 4159
			sx0 - 12, -- 4159
			sx0 + 12, -- 4159
			0, -- 4159
			s.h - 14, -- 4159
			SCAV_BODY -- 4159
		) -- 4159
		self:drawBox( -- 4160
			draw, -- 4160
			w, -- 4160
			h, -- 4160
			sx0 - 7, -- 4160
			sx0 + 7, -- 4160
			s.h - 14, -- 4160
			s.h, -- 4160
			SCAV_HEAD -- 4160
		) -- 4160
		if self.scavState == "turn" then -- 4160
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4162
			draw:drawSegment( -- 4163
				Vec2( -- 4163
					self:sx(sx0, w), -- 4163
					self:sy(s.h - 6, h) -- 4163
				), -- 4163
				Vec2( -- 4163
					self:sx(fx, w), -- 4163
					self:sy(s.h - 6, h) -- 4163
				), -- 4163
				self:px(1), -- 4163
				INK -- 4163
			) -- 4163
		end -- 4163
	end -- 4163
	if self.hasBottle then -- 4163
		local p = self.player -- 4168
		self:drawBottle( -- 4169
			draw, -- 4169
			w, -- 4169
			h, -- 4169
			p.x + p.facing * 10, -- 4169
			p.y + p.h * 0.62 -- 4169
		) -- 4169
	end -- 4169
	if self.bottleFly ~= nil then -- 4169
		self:drawBottle( -- 4172
			draw, -- 4172
			w, -- 4172
			h, -- 4172
			self.bottleFly.x, -- 4172
			self.bottleFly.y -- 4172
		) -- 4172
	end -- 4172
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 4172
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 4175
		draw:drawCircle( -- 4176
			Vec2( -- 4176
				self:sx(self.bottleLandX, w), -- 4176
				self:sy(0, h) -- 4176
			), -- 4176
			self:px(r / ____exports.UNITS_PER_PX), -- 4176
			BRICK_LINE -- 4176
		) -- 4176
	end -- 4176
end -- 4143
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 4180
	self:drawBox( -- 4181
		draw, -- 4181
		w, -- 4181
		h, -- 4181
		x - 3, -- 4181
		x + 3, -- 4181
		y - 10, -- 4181
		y, -- 4181
		BOTTLE -- 4181
	) -- 4181
end -- 4180
function Play.prototype.drawTrace(self, draw, w, h) -- 4184
	local t = self.trace -- 4185
	if t == nil or self.traceT <= 0 then -- 4185
		return -- 4187
	end -- 4187
	draw:drawSegment( -- 4189
		Vec2( -- 4190
			self:sx(t.x0, w), -- 4190
			self:sy(t.y0, h) -- 4190
		), -- 4190
		Vec2( -- 4191
			self:sx(t.x1, w), -- 4191
			self:sy(t.y1, h) -- 4191
		), -- 4191
		self:px(1), -- 4192
		t.hit and AIM_HIT or INK_DIM -- 4192
	) -- 4192
end -- 4184
function Play.prototype.drawAim(self, draw, w, h) -- 4195
	local v = self.view -- 4197
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 4198
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 4199
	local dot = self:px(1) -- 4200
	local arm = self:px(3) -- 4201
	local gap = self:px(1) -- 4202
	draw:drawSegment( -- 4203
		Vec2(gx - arm - gap, gy), -- 4203
		Vec2(gx - gap, gy), -- 4203
		dot / 2, -- 4203
		AIM -- 4203
	) -- 4203
	draw:drawSegment( -- 4204
		Vec2(gx + gap, gy), -- 4204
		Vec2(gx + arm + gap, gy), -- 4204
		dot / 2, -- 4204
		AIM -- 4204
	) -- 4204
	draw:drawSegment( -- 4205
		Vec2(gx, gy - arm - gap), -- 4205
		Vec2(gx, gy - gap), -- 4205
		dot / 2, -- 4205
		AIM -- 4205
	) -- 4205
	draw:drawSegment( -- 4206
		Vec2(gx, gy + gap), -- 4206
		Vec2(gx, gy + arm + gap), -- 4206
		dot / 2, -- 4206
		AIM -- 4206
	) -- 4206
	if self.room.key == "village" and self.hasBottle then -- 4206
		local p = self.player -- 4210
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4212
		local dir = ____end.x >= p.x and 1 or -1 -- 4213
		local x0 = p.x + dir * 10 -- 4214
		local y0 = p.y + p.h * 0.7 -- 4215
		local T = BOTTLE_FLY_TIME -- 4216
		local vx = (____end.x - x0) / T -- 4217
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 4218
		local pxr = x0 -- 4219
		local pyr = y0 -- 4220
		local t = 1 -- 4221
		do -- 4221
			t = 1 -- 4222
			while t <= 12 do -- 4222
				local tt = t / 12 * T -- 4223
				local nx = x0 + vx * tt -- 4224
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 4225
				draw:drawSegment( -- 4226
					Vec2( -- 4226
						self:sx(pxr, w), -- 4226
						self:sy(pyr, h) -- 4226
					), -- 4226
					Vec2( -- 4226
						self:sx(nx, w), -- 4226
						self:sy(ny, h) -- 4226
					), -- 4226
					self:px(1) / 2, -- 4226
					BOTTLE -- 4226
				) -- 4226
				pxr = nx -- 4227
				pyr = ny -- 4228
				t = t + 1 -- 4222
			end -- 4222
		end -- 4222
		draw:drawCircle( -- 4230
			Vec2( -- 4230
				self:sx(____end.x, w), -- 4230
				self:sy(____end.y + 2, h) -- 4230
			), -- 4230
			self:px(2), -- 4230
			BOTTLE -- 4230
		) -- 4230
	end -- 4230
end -- 4195
return ____exports -- 4195