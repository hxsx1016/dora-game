-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
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
local ____reload = require("Script.watch.reload") -- 22
local RELOAD_ANSWER_PER_WORLD = ____reload.RELOAD_ANSWER_PER_WORLD -- 23
local RELOAD_ANSWER_TICKS = ____reload.RELOAD_ANSWER_TICKS -- 23
local RELOAD_START = ____reload.RELOAD_START -- 23
local RELOAD_TARGET = ____reload.RELOAD_TARGET -- 23
local reloadAdjacent = ____reload.reloadAdjacent -- 24
local reloadEffectName = ____reload.reloadEffectName -- 24
local reloadEffectOf = ____reload.reloadEffectOf -- 24
local reloadPathValid = ____reload.reloadPathValid -- 24
function makeActor(room, index) -- 4486
	local sp = room.spawns -- 4487
	if index < 0 or index >= #sp then -- 4487
		return { -- 4489
			x = 0, -- 4489
			y = 0, -- 4489
			depth = 0, -- 4489
			depthSpeed = 0, -- 4489
			vx = 0, -- 4489
			vy = 0, -- 4489
			w = CHILD_W, -- 4489
			h = CHILD_H, -- 4489
			onGround = true, -- 4489
			facing = 1, -- 4489
			crouch = false, -- 4489
			rollT = 0, -- 4489
			covered = false, -- 4489
			alive = false -- 4489
		} -- 4489
	end -- 4489
	local s = sp[index + 1] -- 4491
	local child = s.h <= CHILD_H -- 4492
	local ground = room.depth -- 4493
	local depth = ground == nil and 0 or math.max( -- 4494
		ground.min, -- 4494
		math.min(ground.max, s.depth or 0) -- 4494
	) -- 4494
	return { -- 4495
		x = s.x, -- 4496
		y = s.y, -- 4496
		depth = depth, -- 4496
		depthSpeed = 0, -- 4496
		vx = 0, -- 4496
		vy = 0, -- 4496
		w = child and CHILD_W or SOLDIER_W, -- 4497
		h = child and CHILD_H or SOLDIER_H, -- 4498
		onGround = true, -- 4499
		facing = 1, -- 4499
		crouch = false, -- 4499
		rollT = 0, -- 4499
		covered = false, -- 4499
		alive = true -- 4499
	} -- 4499
end -- 4499
function drawFigure(draw, play, w, h, a, body, head) -- 4503
	if not a.alive then -- 4503
		return -- 4505
	end -- 4505
	local x0 = a.x - a.w / 2 -- 4507
	local x1 = a.x + a.w / 2 -- 4508
	local y0 = a.y + a.depth -- 4509
	local y1 = y0 + a.h -- 4510
	play:drawBox( -- 4511
		draw, -- 4511
		w, -- 4511
		h, -- 4511
		x0, -- 4511
		x1, -- 4511
		y0, -- 4511
		y1 - a.h * 0.26, -- 4511
		body -- 4511
	) -- 4511
	play:drawBox( -- 4512
		draw, -- 4512
		w, -- 4512
		h, -- 4512
		x0 + 2, -- 4512
		x1 - 2, -- 4512
		y1 - a.h * 0.26, -- 4512
		y1, -- 4512
		head -- 4512
	) -- 4512
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 4514
	play:drawBox( -- 4515
		draw, -- 4515
		w, -- 4515
		h, -- 4515
		eyeX, -- 4515
		eyeX + 4, -- 4515
		y1 - a.h * 0.14, -- 4515
		y1 - a.h * 0.08, -- 4515
		INK -- 4515
	) -- 4515
end -- 4515
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 4519
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 4520
end -- 4519
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 4527
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 4528
end -- 4527
function rayInterval(origin, direction, min, max) -- 4535
	if direction == 0 then -- 4535
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4537
	end -- 4537
	local a = (min - origin) / direction -- 4539
	local b = (max - origin) / direction -- 4540
	return { -- 4541
		min = math.min(a, b), -- 4541
		max = math.max(a, b) -- 4541
	} -- 4541
end -- 4541
function hitBox(ray, box) -- 4545
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4546
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4547
	local enter = math.max(0, x.min, y.min) -- 4548
	local leave = math.min(99999, x.max, y.max) -- 4549
	if box.depth ~= nil then -- 4549
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4551
		enter = math.max(enter, depth.min) -- 4552
		leave = math.min(leave, depth.max) -- 4553
	end -- 4553
	return leave >= enter and enter or -1 -- 4555
end -- 4555
function drawCartShape(draw, play, w, h, c, axleX) -- 4558
	local half = c.bodyW / 2 -- 4559
	local x0 = axleX - half -- 4560
	local x1 = axleX + half -- 4561
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4562
	play:drawBox( -- 4563
		draw, -- 4563
		w, -- 4563
		h, -- 4563
		x0, -- 4563
		x1, -- 4563
		axleY, -- 4563
		axleY + c.bodyH, -- 4563
		CART_FILL -- 4563
	) -- 4563
	draw:drawCircle( -- 4564
		Vec2( -- 4564
			play:sx(x0 + c.bodyW * 0.28, w), -- 4564
			play:sy(axleY, h) -- 4564
		), -- 4564
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4564
		Color(52, 50, 48, 255) -- 4564
	) -- 4564
	draw:drawCircle( -- 4565
		Vec2( -- 4565
			play:sx(x1 - c.bodyW * 0.28, w), -- 4565
			play:sy(axleY, h) -- 4565
		), -- 4565
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4565
		Color(52, 50, 48, 255) -- 4565
	) -- 4565
	local cx = c.clothSide < 0 and x0 or x1 -- 4566
	play:drawBox( -- 4567
		draw, -- 4567
		w, -- 4567
		h, -- 4567
		cx - 10, -- 4567
		cx + 10, -- 4567
		axleY + c.bodyH, -- 4567
		axleY + c.bodyH + 18, -- 4567
		CLOTH -- 4567
	) -- 4567
end -- 4567
____exports.STEP = STEP -- 28
____exports.GRAVITY = 1000 -- 29
____exports.GATE_COUNT_END = 1440 -- 30
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 32
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 34
function ____exports.gateCountAtTick(tick) -- 36
	if tick >= ____exports.GATE_COUNT_END then -- 36
		return 20 -- 37
	end -- 37
	if tick >= 1260 then -- 37
		return 19 -- 38
	end -- 38
	if tick >= 1080 then -- 38
		return 18 -- 39
	end -- 39
	if tick >= 480 then -- 39
		return 11 + math.floor((tick - 480) * 7 / 600) -- 40
	end -- 40
	return 1 + math.floor(math.max(0, tick) / 48) -- 41
end -- 36
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 44
CHILD_W = 28 -- 96
CHILD_H = 64 -- 97
local CHILD_CROUCH_H = 36 -- 98
local CHILD_SPEED = 160 -- 99
local CHILD_SLOW = 80 -- 100
local CHILD_JUMP = 320 -- 101
SOLDIER_W = 30 -- 104
SOLDIER_H = 88 -- 105
local SOLDIER_SPEED = 264 -- 106
local ROLL_TIME = 0.35 -- 107
local ROLL_SPEED = 280 -- 108
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 110
local LEDGE_RISE = 60 -- 111
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 114
____exports.LOGIC_H = 180 -- 115
____exports.UNITS_PER_PX = 2 -- 116
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 118
local CAM_FOLLOW = 9 -- 119
local CAM_LOOK_UP = 46 -- 120
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 123
--- 握把触发半径。
____exports.CART_REACH = 70 -- 125
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 127
local CART_CLEAR = 44 -- 128
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 130
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 132
local CONSUMABLE_CAP = 1 -- 133
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 135
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 137
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 139
local FIRE_COOLDOWN = 150 -- 140
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 142
local ENEMY_RANGE = 760 -- 143
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 145
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 147
local DEPTH_SPEED_RATIO = 0.55 -- 148
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 149
INK = Color(232, 232, 228, 255) -- 151
local INK_DIM = Color(150, 152, 150, 255) -- 152
local BG_VOID = Color(8, 9, 10, 255) -- 153
local BG_FAR = Color(24, 26, 28, 255) -- 154
local BG_MID = Color(31, 34, 37, 255) -- 155
local GROUND = Color(112, 114, 112, 255) -- 156
local FLOOR_DECK = Color(66, 70, 72, 255) -- 157
local SOLID_FILL = Color(84, 86, 84, 255) -- 158
local SOLID_EDGE = Color(126, 130, 126, 255) -- 159
CART_FILL = Color(122, 78, 56, 255) -- 160
CLOTH = Color(178, 52, 46, 255) -- 161
local DANGER = Color(150, 54, 48, 46) -- 162
local DANGER_LINE = Color(178, 78, 64, 200) -- 163
local HOLE_FILL = Color(10, 11, 12, 255) -- 164
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 165
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 166
local CHILD_BODY = Color(214, 168, 96, 255) -- 167
local CHILD_HEAD = Color(232, 214, 186, 255) -- 168
local ENEMY_BODY = Color(176, 92, 84, 255) -- 169
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 170
local CHECK = Color(96, 186, 122, 255) -- 171
local STAND = Color(226, 186, 84, 255) -- 172
local AIM = Color(236, 236, 232, 230) -- 173
local AIM_HIT = Color(236, 96, 84, 255) -- 174
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 176
local SOFT_LINE = Color(140, 112, 80, 190) -- 177
local BRICK = Color(126, 118, 110, 70) -- 178
local BRICK_LINE = Color(160, 152, 142, 200) -- 179
local PASS = Color(96, 186, 122, 40) -- 180
local PASS_LINE = Color(96, 186, 122, 200) -- 181
local BOTTLE = Color(120, 186, 160, 255) -- 182
local SCAV_BODY = Color(128, 118, 96, 255) -- 183
local SCAV_HEAD = Color(196, 182, 158, 255) -- 184
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 271
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 272
	if zoom < 1 then -- 272
		zoom = 1 -- 274
	end -- 274
	return { -- 276
		zoom = zoom, -- 277
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 278
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 279
	} -- 279
end -- 271
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 302
	if key == "prologue" then -- 302
		return "prologue-wait" -- 304
	end -- 304
	if key == "street" then -- 304
		return "street-run" -- 307
	end -- 307
	if key == "gate" then -- 307
		return "gate-idle" -- 310
	end -- 310
	if key == "gatepath" then -- 310
		return "gatepath-start" -- 313
	end -- 313
	if key == "forest" then -- 313
		return "forest-run" -- 316
	end -- 316
	if key == "tower" then -- 316
		return "tower-wait" -- 319
	end -- 319
	return "run" -- 321
end -- 302
____exports.Play = __TS__Class() -- 324
local Play = ____exports.Play -- 324
Play.name = "Play" -- 324
function Play.prototype.____constructor(self, room, resume, run) -- 537
	self.enemies = {} -- 329
	self.boxes = {} -- 330
	self.floors = {} -- 331
	self.checkpoint = -1 -- 333
	self.flash = "" -- 335
	self.flashT = 0 -- 336
	self.traceT = 0 -- 339
	self.focusCart = false -- 341
	self.knocks = 0 -- 343
	self.knockT = 0 -- 344
	self.cartAxle = 0 -- 348
	self.cartDocked = false -- 350
	self.gripping = false -- 352
	self.gateOpen = false -- 354
	self.calmConsumed = false -- 356
	self.craftT = 0 -- 358
	self.nextDangerId = 1 -- 360
	self.wantRoom = "" -- 362
	self.carryCartAxle = -1 -- 364
	self.carryCartDocked = false -- 365
	self.checkpointCartAxle = -1 -- 367
	self.hasBottle = false -- 371
	self.bottleLandX = -1 -- 375
	self.bottleTargetX = -1 -- 376
	self.bottleTargetY = 0 -- 377
	self.bottleLandT = 0 -- 378
	self.aimHold = 0 -- 380
	self.scavX = 0 -- 382
	self.scavDir = 1 -- 383
	self.scavState = "patrol" -- 384
	self.scavT = 0 -- 385
	self.scavTargetX = 0 -- 386
	self.passed = false -- 388
	self.childMode = false -- 392
	self.phase = "" -- 394
	self.phaseTick = 0 -- 396
	self.gateTick = 0 -- 398
	self.countTick = 0 -- 400
	self.countArmed = false -- 402
	self.countPrevMove = 0 -- 404
	self.caughtT = 0 -- 406
	self.hp = 3 -- 408
	self.maxHp = 3 -- 409
	self.invulnT = 0 -- 415
	self.partnerStuck = 0 -- 417
	self.partnerLaneIdx = 0 -- 419
	self.partnerLaneHold = 0 -- 420
	self.coveredFlash = 0 -- 422
	self.coverHug = false -- 424
	self.coverNear = false -- 426
	self.coverEntity = "" -- 428
	self.coverBlocking = false -- 430
	self.gateNeedConfirm = false -- 432
	self.gateRestartArmed = true -- 434
	self.bottleAimX = -1 -- 436
	self.bottleAimY = 0 -- 437
	self.bottleSurfaceY = -1 -- 439
	self.bottleLandY = 0 -- 441
	self.events = {} -- 443
	self.eventSeq = 0 -- 445
	self.dogX = 0 -- 447
	self.dogDir = 1 -- 448
	self.dogState = "patrol" -- 449
	self.dogT = 0 -- 450
	self.dogTargetX = 0 -- 451
	self.scavSee = 0 -- 453
	self.scavChase = false -- 454
	self.gateSpawned = 0 -- 456
	self.gateFailCount = 0 -- 458
	self.isCampaign = false -- 462
	self.pickups = {} -- 466
	self.reloadT = 0 -- 468
	self.objectiveDone = false -- 472
	self.hint = "" -- 474
	self.roomStartTick = 0 -- 476
	self.cartHitT = 0 -- 478
	self.cartExposed = false -- 479
	self.storyRoute = "" -- 483
	self.storySettled = false -- 485
	self.hpAtGate = -1 -- 487
	self.maxHpAtGate = -1 -- 488
	self.handTicks = 0 -- 490
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 492
	self.handArmed = false -- 494
	self.handDone = false -- 496
	self.lineSaid = false -- 497
	self.tied = false -- 499
	self.pathDone = false -- 501
	self.carryOn = false -- 503
	self.escortDone = false -- 505
	self.reloadOpen = false -- 509
	self.reloadAnswerTicks = 0 -- 511
	self.reloadWorldTicks = 0 -- 513
	self.reloadPath = {RELOAD_START} -- 515
	self.reloadPendingEffect = "" -- 517
	self.reloadTryCount = 0 -- 519
	self.paused = false -- 521
	self.ticks = 0 -- 523
	self.view = {zoom = 1, ox = 0, oy = 0} -- 525
	self.ox = 0 -- 527
	self.aimX = 0 -- 529
	self.aimY = 0 -- 530
	self.viewW = 0 -- 532
	self.viewH = 0 -- 533
	self.ox = room.originX -- 539
	self.room = withOrigin(room) -- 540
	local wr = self.room -- 541
	self.run = run or createRun() -- 542
	self.isCampaign = wr.campaign ~= nil -- 543
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 544
	self:buildWorld() -- 545
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 548
	local soldierOutside = wr.key == "outside" and lockedRoute == "soldier" -- 549
	self.childMode = not soldierOutside and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 550
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 552
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 553
	self.player = makeActor(wr, playerIdx) -- 554
	self.partner = makeActor(wr, partnerIdx) -- 555
	self.phase = phaseOf(wr.key) -- 556
	if wr.story ~= nil then -- 556
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 558
	end -- 558
	self.cam.x = self.player.x -- 560
	self.cam.y = self.player.y + CAM_LOOK_UP -- 561
	self.cartAxle = wr.cart.startX -- 562
	self.escort = __TS__New( -- 563
		Escort, -- 563
		safeAnchorX(wr.marks) -- 563
	) -- 563
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 564
	if self.isCampaign then -- 564
		self:setupCampaign() -- 566
	else -- 566
		self:buildEnemies() -- 568
	end -- 568
	if resume ~= nil and resume.checkpoint > 0 then -- 568
		self.checkpoint = resume.checkpoint -- 572
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 572
			self.cartAxle = self.room.cart.endX -- 574
			self.cartDocked = true -- 575
			self.player.x = self.ox + 380 -- 578
			self.player.y = 0 -- 579
			self.player.vy = 0 -- 580
			self.player.onGround = true -- 581
			self.cam.x = self.player.x -- 582
			self.cam.y = self.player.y + CAM_LOOK_UP -- 583
		end -- 583
	end -- 583
	self:restoreStory() -- 586
end -- 537
function Play.prototype.restoreStory(self) -- 596
	if self.isCampaign and self.run.trial ~= nil then -- 596
		return -- 600
	end -- 600
	local story = self.run.story -- 602
	if story == nil then -- 602
		return -- 604
	end -- 604
	if story.maxHp > 0 then -- 604
		self.maxHp = story.maxHp -- 607
		self.hp = math.max( -- 608
			1, -- 608
			math.min(story.hp, story.maxHp) -- 608
		) -- 608
	end -- 608
	self.storyRoute = story.route -- 610
	self.storySettled = story.settled -- 611
	self.hpAtGate = story.hpAtGate -- 612
	self.maxHpAtGate = story.maxHpAtGate -- 613
	self.handDone = story.handDone -- 614
	self.lineSaid = story.lineSaid -- 615
	self.tied = story.handDone -- 616
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 617
	self.escortDone = story.escortDone -- 618
	if self.room.key ~= "gate" then -- 618
		return -- 620
	end -- 620
	local ____temp_0 -- 622
	if self.room.story == nil then -- 622
		____temp_0 = nil -- 622
	else -- 622
		____temp_0 = self.room.story.gate -- 622
	end -- 622
	local g = ____temp_0 -- 622
	if g == nil then -- 622
		return -- 624
	end -- 624
	if story.phase == "gate-send" then -- 624
		self.phase = "gate-send" -- 628
		self.gateTick = g.holdTicks -- 629
		self.gateSpawned = 4 -- 630
		self.enemies = {} -- 631
		self.player.x = self.ox + g.doorX - 40 -- 632
		self.player.y = 0 -- 633
		self.player.depth = 0 -- 634
		self.player.vx = 0 -- 635
		self.player.vy = 0 -- 636
		self.player.onGround = true -- 637
		self.partner.x = self.ox + g.waitX -- 638
		self.partner.y = 0 -- 639
		self.partner.depth = 0 -- 640
		self.partner.alive = true -- 641
		self.cam.x = self.player.x -- 642
		self.handTicks = 0 -- 643
		self.handArmed = false -- 644
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 645
		return -- 646
	end -- 646
	if not story.settled then -- 646
		return -- 649
	end -- 649
	self.gateTick = g.holdTicks -- 652
	self.gateSpawned = 4 -- 653
	self.enemies = {} -- 654
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 654
		self.phase = story.phase -- 656
		self.countTick = math.max(story.countTick, 0) -- 657
		self:swapToChild(g.doorX + 30) -- 658
		self.countPrevMove = 0 -- 659
		self.countArmed = false -- 660
		return -- 661
	end -- 661
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 661
		self.phase = story.phase -- 664
		self.countTick = ____exports.GATE_COUNT_END -- 665
		self.phaseTick = story.phaseTick -- 666
		self:swapToChild(g.doorX + 30) -- 667
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 668
			0, -- 668
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 668
		) -- 668
		self.handArmed = false -- 669
	end -- 669
end -- 596
function Play.prototype.buildWorld(self) -- 674
	local room = self.room -- 675
	self.boxes = {} -- 676
	self.floors = {} -- 677
	local i = 0 -- 678
	do -- 678
		i = 0 -- 679
		while i < #room.floors do -- 679
			local f = room.floors[i + 1] -- 680
			local ____self_floors_1 = self.floors -- 680
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 681
			i = i + 1 -- 679
		end -- 679
	end -- 679
	do -- 679
		i = 0 -- 683
		while i < #room.solids do -- 683
			local s = room.solids[i + 1] -- 684
			if not s.decorative then -- 684
				local ____self_boxes_13 = self.boxes -- 690
				local ____s_x_4 = s.x -- 691
				local ____temp_5 = s.x + s.w -- 691
				local ____s_y_6 = s.y -- 691
				local ____temp_7 = s.y + s.h -- 691
				local ____temp_2 -- 692
				if room.depth == nil then -- 692
					____temp_2 = nil -- 692
				else -- 692
					____temp_2 = s.depth -- 692
				end -- 692
				local ____temp_8 = s.passable == true -- 693
				local ____s_label_9 = s.label -- 693
				local ____s_id_10 = s.id -- 694
				local ____temp_11 = s.soft == true -- 694
				local ____temp_12 = s.hidden == true -- 694
				local ____temp_3 -- 695
				if s.breakable == nil then -- 695
					____temp_3 = nil -- 695
				else -- 695
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 695
				end -- 695
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 690
					x0 = ____s_x_4, -- 691
					x1 = ____temp_5, -- 691
					y0 = ____s_y_6, -- 691
					y1 = ____temp_7, -- 691
					depth = ____temp_2, -- 692
					passable = ____temp_8, -- 693
					label = ____s_label_9, -- 693
					id = ____s_id_10, -- 694
					soft = ____temp_11, -- 694
					hidden = ____temp_12, -- 694
					breakable = ____temp_3, -- 695
					interact = s.interact -- 696
				} -- 696
			end -- 696
			i = i + 1 -- 683
		end -- 683
	end -- 683
	do -- 683
		i = 0 -- 700
		while i < #room.stairs do -- 700
			local st = room.stairs[i + 1] -- 701
			local n = st.steps + 1 -- 702
			local stepW = (st.x1 - st.x0) / n -- 703
			local k = 0 -- 704
			do -- 704
				k = 0 -- 705
				while k < n do -- 705
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 706
					local x0 = st.x0 + stepW * k -- 707
					local ____self_boxes_14 = self.boxes -- 707
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 709
						x0 = x0, -- 709
						x1 = x0 + stepW, -- 709
						y0 = -8, -- 709
						y1 = y, -- 709
						passable = true -- 709
					} -- 709
					k = k + 1 -- 705
				end -- 705
			end -- 705
			i = i + 1 -- 700
		end -- 700
	end -- 700
end -- 674
function Play.prototype.setupCampaign(self) -- 718
	local wr = self.room -- 719
	local c = wr.campaign -- 720
	if c == nil then -- 720
		return -- 722
	end -- 722
	self.roomStartTick = self.run.ticks -- 724
	if wr.key == "s1-crossroad" or wr.key == "escort1" then -- 724
		self.run.joined = true -- 727
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 727
		local ____self_run_16 = self.run -- 730
		local ____temp_15 -- 730
		if wr.key == "s2-drygoods" then -- 730
			____temp_15 = self.run.route ~= "drygoods" -- 730
		else -- 730
			____temp_15 = false -- 730
		end -- 730
		____self_run_16.joined = ____temp_15 -- 730
	end -- 730
	local x = wr.minX + 60 -- 732
	local y = 0 -- 733
	local depth = 0 -- 734
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 734
		x = wr.minX + 210 -- 736
		depth = -32 -- 737
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 737
		x = wr.minX + 40 -- 739
		y = 32 -- 740
		depth = 32 -- 741
	end -- 741
	self.player = { -- 743
		x = x, -- 744
		y = y, -- 744
		depth = depth, -- 744
		depthSpeed = 0, -- 744
		vx = 0, -- 744
		vy = 0, -- 744
		w = SOLDIER_W, -- 745
		h = SOLDIER_H, -- 745
		onGround = y <= 0, -- 745
		facing = 1, -- 745
		crouch = false, -- 745
		rollT = 0, -- 745
		covered = false, -- 745
		alive = true -- 745
	} -- 745
	self.partner = { -- 747
		x = x + 60, -- 748
		y = y, -- 748
		depth = depth, -- 748
		depthSpeed = 0, -- 748
		vx = 0, -- 748
		vy = 0, -- 748
		w = CHILD_W, -- 749
		h = CHILD_H, -- 749
		onGround = y <= 0, -- 749
		facing = 1, -- 749
		crouch = false, -- 749
		rollT = 0, -- 749
		covered = false, -- 749
		alive = true -- 749
	} -- 749
	self.cam.x = x -- 751
	self.cam.y = y + CAM_LOOK_UP -- 752
	self.phase = "run" -- 753
	self.hp = self.maxHp -- 754
	local trial = self.run.trial -- 755
	if trial ~= nil then -- 755
		draftRoom(trial, wr.key) -- 757
		self.maxHp = self.maxHp + trial.ranks.vitality -- 758
		self.hp = trial.hp -- 759
	end -- 759
	self:buildEnemies() -- 761
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 762
	local i = 0 -- 763
	do -- 763
		i = 0 -- 764
		while i < #self.boxes do -- 764
			do -- 764
				local b = self.boxes[i + 1] -- 765
				if b.id == nil then -- 765
					goto __continue50 -- 767
				end -- 767
				local st = self.run.props[b.id] -- 769
				if st ~= nil then -- 769
					b.broken = st.broken -- 771
					local ____temp_17 -- 772
					if b.breakable == nil then -- 772
						____temp_17 = nil -- 772
					else -- 772
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 772
					end -- 772
					b.breakable = ____temp_17 -- 772
					b.hidden = b.hidden == true and st.revealed ~= true -- 773
					if b.hidden then -- 773
						b.broken = true -- 775
					end -- 775
				elseif b.hidden == true then -- 775
					b.broken = true -- 779
				end -- 779
			end -- 779
			::__continue50:: -- 779
			i = i + 1 -- 764
		end -- 764
	end -- 764
	if wr.cart.bodyW > 0 then -- 764
		self.cartAxle = wr.cart.startX -- 783
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 783
			self.cartAxle = wr.cart.endX -- 785
			self.cartDocked = true -- 786
		end -- 786
	end -- 786
	do -- 786
		i = 0 -- 789
		while i < #self.pickups do -- 789
			local pk = self.pickups[i + 1] -- 790
			if self.run.taken[pk.id] == true then -- 790
				pk.id = "" -- 792
			end -- 792
			i = i + 1 -- 789
		end -- 789
	end -- 789
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 795
end -- 718
function Play.prototype.log(self, line) -- 798
	local ____self_run_log_18 = self.run.log -- 798
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 799
	if #self.run.log > 120 then -- 799
		table.remove(self.run.log, 1) -- 801
	end -- 801
end -- 798
function Play.prototype.buildEnemies(self) -- 805
	self.enemies = {} -- 806
	if self.isCampaign then -- 806
		local i = 0 -- 808
		do -- 808
			i = 0 -- 809
			while i < #self.room.spawns do -- 809
				local sp = self.room.spawns[i + 1] -- 810
				local kind = sp.kind or "gunner" -- 811
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 812
				local ____self_enemies_19 = self.enemies -- 812
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 813
					x = sp.x, -- 814
					y = sp.y, -- 814
					depth = sp.depth, -- 814
					w = 26, -- 814
					h = sp.h, -- 814
					alive = true, -- 814
					hitT = 0, -- 814
					warnT = 0, -- 814
					fireCd = 40, -- 814
					kind = kind, -- 815
					shieldHp = hp, -- 815
					shieldHpMax = hp, -- 815
					drop = sp.drop or "none", -- 815
					homeX = sp.x, -- 816
					swingT = 0, -- 816
					awake = false, -- 816
					squad = i -- 816
				} -- 816
				i = i + 1 -- 809
			end -- 809
		end -- 809
		return -- 819
	end -- 819
	if self.room.key == "checkpoint" then -- 819
		local ____self_enemies_20 = self.enemies -- 819
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 822
			x = self.ox + 430, -- 822
			y = 0, -- 822
			w = 26, -- 822
			h = 84, -- 822
			alive = true, -- 822
			hitT = 0, -- 822
			warnT = 0, -- 822
			fireCd = 0 -- 822
		} -- 822
		local ____self_enemies_21 = self.enemies -- 822
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 823
			x = self.ox + 505, -- 823
			y = 0, -- 823
			w = 26, -- 823
			h = 84, -- 823
			alive = true, -- 823
			hitT = 0, -- 823
			warnT = 0, -- 823
			fireCd = 0 -- 823
		} -- 823
		return -- 824
	end -- 824
	if self.room.key == "street" then -- 824
		local ____self_enemies_22 = self.enemies -- 824
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 828
			x = self.ox + 340, -- 828
			y = 0, -- 828
			w = 26, -- 828
			h = 84, -- 828
			alive = true, -- 828
			hitT = 0, -- 828
			warnT = 0, -- 828
			fireCd = 0 -- 828
		} -- 828
		local ____self_enemies_23 = self.enemies -- 828
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 829
			x = self.ox + 560, -- 829
			y = 0, -- 829
			w = 26, -- 829
			h = 84, -- 829
			alive = true, -- 829
			hitT = 0, -- 829
			warnT = 0, -- 829
			fireCd = 0 -- 829
		} -- 829
	end -- 829
end -- 805
function Play.prototype.emit(self, name, data) -- 835
	local ____self_events_24 = self.events -- 835
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 836
	self.eventSeq = self.eventSeq + 1 -- 837
	if #self.events > 256 then -- 837
		table.remove(self.events, 1) -- 839
	end -- 839
end -- 835
function Play.prototype.drainEvents(self) -- 847
	local out = self.events -- 848
	self.events = {} -- 849
	return out -- 850
end -- 847
function Play.prototype.adoptEvents(self, events) -- 859
	if #events == 0 then -- 859
		return -- 861
	end -- 861
	local keep = {} -- 863
	local i = 0 -- 864
	do -- 864
		i = 0 -- 865
		while i < #events do -- 865
			do -- 865
				local e = events[i + 1] -- 866
				if e.name == "knock" and e.data.room ~= self.room.key then -- 866
					goto __continue74 -- 868
				end -- 868
				keep[#keep + 1] = e -- 870
			end -- 870
			::__continue74:: -- 870
			i = i + 1 -- 865
		end -- 865
	end -- 865
	if #keep == 0 then -- 865
		return -- 873
	end -- 873
	self.events = __TS__ArrayConcat(keep, self.events) -- 875
	do -- 875
		i = 0 -- 876
		while i < #self.events do -- 876
			self.events[i + 1].seq = i -- 877
			i = i + 1 -- 876
		end -- 876
	end -- 876
	self.eventSeq = #self.events -- 879
end -- 859
function Play.prototype.chooseTalent(self, slot) -- 882
	local trial = self.run.trial -- 883
	local talent = trial and trial.offers[slot + 1] -- 884
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 884
		return -- 885
	end -- 885
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 885
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 886
	trial.offers = {} -- 887
	if talent == "vitality" then -- 887
		self.maxHp = self.maxHp + 1 -- 889
		self.hp = self.hp + 1 -- 890
		trial.hp = self.hp -- 891
	end -- 891
	self:flashSet(talentNames[talent], 1.2) -- 893
end -- 882
function Play.prototype.beginReload(self) -- 901
	self.reloadT = self:reloadTicks() -- 902
	if self.run.trial == nil and self.room.key == "escort1" then -- 902
		self:openReloadPuzzle() -- 904
	end -- 904
end -- 901
function Play.prototype.openReloadPuzzle(self) -- 909
	self.reloadOpen = true -- 910
	self.reloadAnswerTicks = 0 -- 911
	self.reloadWorldTicks = 0 -- 912
	self.reloadPath = {RELOAD_START} -- 913
	self.reloadPendingEffect = "" -- 914
	self.reloadTryCount = self.reloadTryCount + 1 -- 915
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 916
end -- 909
function Play.prototype.closeReloadPuzzle(self) -- 920
	self.reloadOpen = false -- 921
	self.reloadAnswerTicks = 0 -- 922
	self.reloadWorldTicks = 0 -- 923
	self.reloadPath = {RELOAD_START} -- 924
	self.reloadPendingEffect = "" -- 925
end -- 920
function Play.prototype.reloadTapNode(self, node) -- 932
	if not self.reloadOpen then -- 932
		return -- 934
	end -- 934
	local path = self.reloadPath -- 936
	local last = path[#path] -- 937
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 937
		self.reloadPath = {RELOAD_START} -- 939
		self:emit("reloadInvalid", {node = node, at = last}) -- 940
		return -- 941
	end -- 941
	path[#path + 1] = node -- 943
	if node ~= RELOAD_TARGET then -- 943
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 945
		return -- 946
	end -- 946
	if not reloadPathValid(path) then -- 946
		self.reloadPath = {RELOAD_START} -- 949
		self:emit("reloadInvalid", {node = node, at = last}) -- 950
		return -- 951
	end -- 951
	self.reloadPendingEffect = reloadEffectOf(path) -- 953
	self.reloadOpen = false -- 954
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 955
	self:flashSet( -- 958
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 958
		1.4 -- 958
	) -- 958
end -- 932
function Play.prototype.consumeReloadEffect(self) -- 962
	local e = self.reloadPendingEffect -- 963
	if e ~= "" then -- 963
		self.reloadPendingEffect = "" -- 965
	end -- 965
	return e -- 967
end -- 962
function Play.prototype.echoToSource(self, from) -- 974
	local best = -1 -- 975
	local bestD = 1000000000 -- 976
	local i = 0 -- 977
	do -- 977
		i = 0 -- 978
		while i < #self.enemies do -- 978
			do -- 978
				local e = self.enemies[i + 1] -- 979
				if not e.alive then -- 979
					goto __continue95 -- 981
				end -- 981
				local d = math.abs(e.x - from.x) -- 983
				if d < bestD then -- 983
					bestD = d -- 985
					best = i -- 986
				end -- 986
			end -- 986
			::__continue95:: -- 986
			i = i + 1 -- 978
		end -- 978
	end -- 978
	if best < 0 then -- 978
		return -- 990
	end -- 990
	local e = self.enemies[best + 1] -- 992
	e.awake = true -- 993
	e.warnT = 0 -- 994
	e.fireCd = math.max(e.fireCd or 0, 60) -- 995
	self:flashSet("回声引到声源 · 他先抬枪", 1) -- 996
end -- 974
function Play.prototype.reloadTicks(self) -- 999
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1000
	local ____opt_29 = self.run.trial -- 1000
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1000
end -- 999
function Play.prototype.update(self, dt, input) -- 1003
	local trial = self.run.trial -- 1004
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1004
		return -- 1005
	end -- 1005
	if input.pause.pressed then -- 1005
		self.paused = not self.paused -- 1007
	end -- 1007
	if self.flashT > 0 then -- 1007
		self.flashT = self.flashT - dt -- 1010
		if self.flashT <= 0 then -- 1010
			self.flash = "" -- 1012
		end -- 1012
	end -- 1012
	if self.traceT > 0 then -- 1012
		self.traceT = self.traceT - dt -- 1016
		if self.traceT <= 0 then -- 1016
			self.trace = nil -- 1018
		end -- 1018
	end -- 1018
	if self.paused then -- 1018
		self:updateCamera(dt) -- 1022
		return -- 1023
	end -- 1023
	if self.reloadOpen then -- 1023
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1029
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1029
			self.reloadOpen = false -- 1031
			self.reloadPendingEffect = "" -- 1032
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1033
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1034
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1034
			self:updateCamera(dt) -- 1036
			return -- 1037
		else -- 1037
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1039
		end -- 1039
	end -- 1039
	self.ticks = self.ticks + 1 -- 1043
	if self.invulnT > 0 then -- 1043
		self.invulnT = self.invulnT - 1 -- 1047
	end -- 1047
	if self.isCampaign then -- 1047
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1047
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1050
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1051
	end -- 1051
	local p = self.player -- 1053
	self:stepPlayer(p, dt, input) -- 1054
	self:refreshCover(p, input) -- 1056
	if self.carryOn then -- 1056
		self:carryPose() -- 1058
	end -- 1058
	if self.isCampaign then -- 1058
		self:stepCampaign(dt, input) -- 1061
		if not self.carryOn then -- 1061
			self:stepCampaignPartner(dt) -- 1063
		end -- 1063
	end -- 1063
	local legacyEnemies = not self.isCampaign or trial ~= nil -- 1069
	if legacyEnemies and (trial == nil or not self.run.finished) then -- 1069
		self:stepEnemies(dt, input) -- 1070
	end -- 1070
	if trial ~= nil then -- 1070
		trial.hp = self.hp -- 1071
	end -- 1071
	if not self.isCampaign then -- 1071
		self:stepStory(dt, input) -- 1073
		self:stepEscort(dt, input) -- 1074
		self:stepVillage(dt, input) -- 1075
		self:stepChase(dt, input) -- 1076
		self:stepInteract(dt, input) -- 1077
	end -- 1077
	self:updateGate() -- 1079
	self:updateCamera(dt) -- 1080
	self:syncStory() -- 1082
end -- 1003
function Play.prototype.underLowArch(self, a) -- 1089
	local arch = self.room.arch -- 1090
	if arch.h <= 0 then -- 1090
		return false -- 1092
	end -- 1092
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1092
		return false -- 1095
	end -- 1095
	local top = arch.y + arch.h -- 1097
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1098
end -- 1089
function Play.prototype.coverAt(self, a) -- 1105
	local best = nil -- 1106
	local bestGap = 24 -- 1107
	local half = a.w / 2 -- 1108
	local i = 0 -- 1109
	do -- 1109
		i = 0 -- 1110
		while i < #self.boxes do -- 1110
			do -- 1110
				local b = self.boxes[i + 1] -- 1111
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1111
					goto __continue125 -- 1113
				end -- 1113
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1113
					goto __continue125 -- 1116
				end -- 1116
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1118
				if gap < bestGap then -- 1118
					bestGap = gap -- 1120
					best = b -- 1121
				end -- 1121
			end -- 1121
			::__continue125:: -- 1121
			i = i + 1 -- 1110
		end -- 1110
	end -- 1110
	return best -- 1124
end -- 1105
function Play.prototype.nearCover(self, a) -- 1127
	return self:coverAt(a) ~= nil -- 1128
end -- 1127
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1132
	if enemy == nil then -- 1132
		return false -- 1134
	end -- 1134
	local fromRight = enemy.x >= a.x -- 1136
	local edge = fromRight and b.x0 or b.x1 -- 1137
	local ____fromRight_34 -- 1138
	if fromRight then -- 1138
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1138
	else -- 1138
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1139
	end -- 1139
	local between = ____fromRight_34 -- 1138
	local separation = enemy.x - a.x -- 1140
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1141
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1142
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1143
end -- 1132
function Play.prototype.nearestEnemy(self, a) -- 1146
	local best -- 1147
	local bestD = 1000000000 -- 1148
	local i = 0 -- 1149
	do -- 1149
		i = 0 -- 1150
		while i < #self.enemies do -- 1150
			do -- 1150
				local e = self.enemies[i + 1] -- 1151
				if not e.alive then -- 1151
					goto __continue134 -- 1153
				end -- 1153
				local d = math.abs(e.x - a.x) -- 1155
				if d < bestD then -- 1155
					bestD = d -- 1157
					best = e -- 1158
				end -- 1158
			end -- 1158
			::__continue134:: -- 1158
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
	return best -- 1161
end -- 1146
function Play.prototype.refreshCover(self, a, input) -- 1165
	if self.childMode then -- 1165
		self.coverNear = false -- 1167
		self.coverHug = false -- 1168
		self.coverEntity = "" -- 1169
		self.coverBlocking = false -- 1170
		a.covered = false -- 1171
		return -- 1172
	end -- 1172
	local b = self:coverAt(a) -- 1174
	self.coverNear = b ~= nil -- 1175
	a.covered = self.coverNear and input.cover.held -- 1176
	self.coverHug = a.covered -- 1177
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1178
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1179
		b, -- 1179
		a, -- 1179
		self:nearestEnemy(a) -- 1179
	) -- 1179
end -- 1165
function Play.prototype.cartHandleInReach(self, a) -- 1183
	if a == nil then -- 1183
		a = self.player -- 1183
	end -- 1183
	local c = self.room.cart -- 1184
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1184
		return false -- 1186
	end -- 1186
	local handleX = self.cartAxle + c.handleOffset -- 1188
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1189
end -- 1183
function Play.prototype.nearLowLedge(self, a) -- 1194
	local reach = 26 -- 1195
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1196
	local x1 = x0 + reach -- 1197
	local i = 0 -- 1198
	do -- 1198
		i = 0 -- 1199
		while i < #self.boxes do -- 1199
			do -- 1199
				local b = self.boxes[i + 1] -- 1200
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1200
					goto __continue143 -- 1202
				end -- 1202
				local rise = b.y1 - a.y -- 1204
				if rise > 0 and rise <= LEDGE_RISE then -- 1204
					return true -- 1206
				end -- 1206
			end -- 1206
			::__continue143:: -- 1206
			i = i + 1 -- 1199
		end -- 1199
	end -- 1199
	return false -- 1209
end -- 1194
function Play.prototype.stepPlayer(self, a, dt, input) -- 1212
	a.depthSpeed = 0 -- 1213
	if not a.alive then -- 1213
		return -- 1215
	end -- 1215
	local isChild = self.childMode -- 1217
	local lowArch = isChild and self:underLowArch(a) -- 1219
	if self:storyLocked() then -- 1219
		a.vx = 0 -- 1222
		a.crouch = isChild and lowArch -- 1223
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1224
		self:fallY(a, dt) -- 1225
		return -- 1226
	end -- 1226
	if not isChild and self.escort.state == "calming" then -- 1226
		a.crouch = false -- 1230
		a.h = SOLDIER_H -- 1231
		a.vx = 0 -- 1232
		self:fallY(a, dt) -- 1233
		return -- 1234
	end -- 1234
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1236
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1237
	local nearCover = not isChild and self:nearCover(a) -- 1238
	a.covered = nearCover and input.cover.held -- 1239
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1241
	if a.rollT > 0 then -- 1241
		a.rollT = a.rollT - dt -- 1245
		a.vx = a.facing * ROLL_SPEED -- 1246
		self:slideX(a, a.vx * dt) -- 1247
		self:fallY(a, dt) -- 1248
		if a.rollT <= 0 then -- 1248
			self:flashSet("翻滚结束", 0.5) -- 1250
		end -- 1250
		return -- 1252
	end -- 1252
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1252
		if input.moveX ~= 0 then -- 1252
			a.facing = input.moveX > 0 and 1 or -1 -- 1257
		end -- 1257
		if self:nearLowLedge(a) then -- 1257
			a.vy = SOLDIER_JUMP -- 1261
			a.onGround = false -- 1262
			self:flashSet("翻上去", 0.3) -- 1263
			return -- 1264
		end -- 1264
		a.rollT = ROLL_TIME -- 1266
		self:flashSet("翻滚", 0.3) -- 1267
		return -- 1268
	end -- 1268
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1271
	if isChild then -- 1271
		if input.cover.held then -- 1271
			speed = CHILD_SLOW -- 1274
		end -- 1274
		if a.crouch then -- 1274
			speed = CHILD_SLOW -- 1277
		end -- 1277
	elseif a.covered then -- 1277
		speed = SOLDIER_SPEED * 0.45 -- 1280
	end -- 1280
	local handsBusy = self.gripping or gripIntent -- 1284
	local dir = self.gripping and 0 or input.moveX -- 1285
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1286
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1287
	if dir ~= 0 then -- 1287
		a.facing = dir > 0 and 1 or -1 -- 1289
	end -- 1289
	a.vx = dir * speed * diagonal -- 1291
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1291
		a.vy = CHILD_JUMP -- 1295
		a.onGround = false -- 1296
		self:flashSet("跳", 0.25) -- 1297
	end -- 1297
	local previousDepth = a.depth -- 1301
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1302
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1303
	self:slideX(a, a.vx * dt) -- 1304
	self:fallY(a, dt) -- 1305
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1305
		self:shoot(a) -- 1309
	end -- 1309
end -- 1212
function Play.prototype.stepPartner(self, p, dt) -- 1314
	local a = self.partner -- 1315
	if not a.alive then -- 1315
		return -- 1317
	end -- 1317
	a.crouch = false -- 1319
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1320
	a.vx = 0 -- 1321
	a.depthSpeed = 0 -- 1322
	self:fallY(a, dt) -- 1323
end -- 1314
function Play.prototype.stepEscort(self, dt, input) -- 1330
	local a = self.partner -- 1331
	a.depthSpeed = 0 -- 1332
	if not a.alive then -- 1332
		return -- 1334
	end -- 1334
	if self.room.key == "gatepath" then -- 1334
		if self.carryOn then -- 1334
			return -- 1339
		end -- 1339
		local p = self.player -- 1342
		a.depth = p.depth -- 1343
		a.facing = p.facing -- 1344
		a.crouch = false -- 1345
		a.h = CHILD_H -- 1346
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1347
		a.y = p.y -- 1348
		a.vy = 0 -- 1349
		a.vx = p.vx -- 1350
		a.onGround = p.onGround -- 1351
		return -- 1352
	end -- 1352
	if not self:escortOn() then -- 1352
		a.vx = 0 -- 1355
		self:fallY(a, dt) -- 1356
		return -- 1357
	end -- 1357
	local p = self.player -- 1359
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1360
	local hadKnock1 = self.escort.knock1 -- 1361
	local hadKnock2 = self.escort.knock2 -- 1362
	self.calmConsumed = self.escort:update( -- 1363
		input, -- 1363
		p.x, -- 1363
		p.facing, -- 1363
		a.x, -- 1363
		dist -- 1363
	) -- 1363
	if not hadKnock1 and self.escort.knock1 then -- 1363
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1366
	end -- 1366
	if not hadKnock2 and self.escort.knock2 then -- 1366
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1369
	end -- 1369
	a.crouch = self.escort.crouchPose -- 1371
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1372
	if not self.escort.stopped then -- 1372
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1374
		local previousDepth = a.depth -- 1375
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1376
		local distance = math.max( -- 1377
			-travel, -- 1377
			math.min(travel, targetDepth - previousDepth) -- 1377
		) -- 1377
		self:slideDepth(a, distance) -- 1378
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1379
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1379
			a.vy = CHILD_JUMP -- 1381
			a.onGround = false -- 1382
		end -- 1382
	end -- 1382
	local dir = self.escort:moveDir(a.x) -- 1385
	a.vx = dir * CHILD_SPEED -- 1386
	if dir ~= 0 then -- 1386
		a.facing = dir -- 1388
		local before = a.x -- 1389
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1390
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1390
			a.vy = CHILD_JUMP -- 1393
			a.onGround = false -- 1394
		end -- 1394
	end -- 1394
	self:fallY(a, dt) -- 1397
end -- 1330
function Play.prototype.escortOn(self) -- 1401
	if self.room.key == "checkpoint" then -- 1401
		return true -- 1403
	end -- 1403
	if self.room.key == "gatepath" then -- 1403
		return true -- 1406
	end -- 1406
	if self.room.key == "prologue" then -- 1406
		return self.phase == "prologue-follow" -- 1409
	end -- 1409
	return self.room.key == "street" -- 1411
end -- 1401
function Play.prototype.storyLocked(self) -- 1415
	if self.caughtT > 0 then -- 1415
		return true -- 1417
	end -- 1417
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1417
		return true -- 1420
	end -- 1420
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1420
		return true -- 1423
	end -- 1423
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1423
		return true -- 1426
	end -- 1426
	return false -- 1428
end -- 1415
function Play.prototype.swapToChild(self, x) -- 1432
	local tmp = self.player -- 1433
	self.player = self.partner -- 1434
	self.partner = tmp -- 1435
	self.childMode = true -- 1436
	self.player.alive = true -- 1437
	self.player.x = self.ox + x -- 1438
	self.player.y = 0 -- 1439
	self.player.depth = 0 -- 1440
	self.player.depthSpeed = 0 -- 1441
	self.player.vy = 0 -- 1442
	self.player.vx = 0 -- 1443
	self.player.onGround = true -- 1444
	self.player.crouch = false -- 1445
	self.player.h = CHILD_H -- 1446
	self.player.facing = 1 -- 1447
	self.partner.alive = true -- 1448
	self.cam.x = self.player.x -- 1449
end -- 1432
function Play.prototype.stepStory(self, dt, input) -- 1453
	if self.room.key == "prologue" then -- 1453
		self:stepPrologue(dt, input) -- 1455
	elseif self.room.key == "street" then -- 1455
		self:stepStreet(dt, input) -- 1457
	elseif self.room.key == "gate" then -- 1457
		self:stepGate(dt, input) -- 1459
	elseif self.room.key == "gatepath" then -- 1459
		self:stepGatePath() -- 1461
	elseif self.room.key == "tower" then -- 1461
		self:stepTower(dt, input) -- 1463
	end -- 1463
end -- 1453
function Play.prototype.stepPrologue(self, dt, input) -- 1468
	local child = self.partner -- 1469
	if self.phase == "prologue-wait" then -- 1469
		child.crouch = true -- 1471
		child.h = CHILD_CROUCH_H -- 1472
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1473
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1475
		if near and input.interact.pressed then -- 1475
			self.phase = "prologue-give" -- 1477
			self.phaseTick = 0 -- 1478
			self:flashSet("递出针套", 1) -- 1479
		end -- 1479
		return -- 1481
	end -- 1481
	if self.phase == "prologue-give" then -- 1481
		self.phaseTick = self.phaseTick + 1 -- 1484
		if self.phaseTick == 12 then -- 1484
			self:flashSet("针套递过去", 0.7) -- 1486
		elseif self.phaseTick == 36 then -- 1486
			self:flashSet("纸条塞进针套", 0.9) -- 1488
		elseif self.phaseTick >= 60 then -- 1488
			self.phase = "prologue-follow" -- 1490
			self.phaseTick = 0 -- 1491
			child.crouch = false -- 1492
			child.h = CHILD_H -- 1493
			self:flashSet("她跟上了", 1.2) -- 1494
		end -- 1494
		return -- 1496
	end -- 1496
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1496
		self:requestRoom("street", "序章跟到门口") -- 1500
		self:flashSet("进街道", 1.2) -- 1501
	end -- 1501
end -- 1468
function Play.prototype.stepStreet(self, dt, input) -- 1506
	local p = self.player -- 1507
	local c = self.partner -- 1508
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1508
		self:requestRoom("checkpoint", "两人都到街尾") -- 1510
		self:flashSet("到检查站", 1.2) -- 1511
	end -- 1511
end -- 1506
function Play.prototype.stepGate(self, dt, input) -- 1516
	local ____temp_35 -- 1517
	if self.room.story == nil then -- 1517
		____temp_35 = nil -- 1517
	else -- 1517
		____temp_35 = self.room.story.gate -- 1517
	end -- 1517
	local g = ____temp_35 -- 1517
	if g == nil then -- 1517
		return -- 1519
	end -- 1519
	local p = self.player -- 1521
	if self.phase == "gate-idle" then -- 1521
		local a = self.partner -- 1524
		local gap = g.waitX - a.x -- 1525
		if math.abs(gap) > 3 then -- 1525
			a.facing = gap > 0 and 1 or -1 -- 1527
			a.vx = a.facing * CHILD_SPEED -- 1528
			local beforeX = a.x -- 1529
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1530
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1530
				a.vy = CHILD_JUMP -- 1532
				a.onGround = false -- 1533
			end -- 1533
			self:fallY(a, dt) -- 1535
		else -- 1535
			a.vx = 0 -- 1537
			a.x = g.waitX -- 1538
		end -- 1538
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1541
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1542
		if self.gateNeedConfirm then -- 1542
			if not input.interact.held then -- 1542
				self.gateRestartArmed = true -- 1547
			end -- 1547
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1547
				self.gateNeedConfirm = false -- 1550
				self.gateRestartArmed = true -- 1551
				self.phase = "gate-hold" -- 1552
				self.gateTick = 0 -- 1553
				self.gateSpawned = 0 -- 1554
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1555
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1556
			end -- 1556
			return -- 1558
		end -- 1558
		if atWinch and atWait then -- 1558
			self.phase = "gate-hold" -- 1561
			self.gateTick = 0 -- 1562
			self.gateSpawned = 0 -- 1563
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1564
		end -- 1564
		return -- 1566
	end -- 1566
	if self.phase == "gate-hold" then -- 1566
		self.gateTick = self.gateTick + 1 -- 1569
		local marks = {0, 540, 900, 1500} -- 1571
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1571
			local idx = self.gateSpawned -- 1573
			local ____self_enemies_36 = self.enemies -- 1573
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 1574
				x = self.ox + 620 + idx * 62, -- 1575
				y = 0, -- 1575
				w = 26, -- 1575
				h = 84, -- 1575
				alive = true, -- 1576
				hitT = 0, -- 1576
				warnT = 0, -- 1576
				fireCd = 90 + idx * 45 -- 1576
			} -- 1576
			self.gateSpawned = self.gateSpawned + 1 -- 1578
			self:flashSet( -- 1579
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1579
				0.9 -- 1579
			) -- 1579
		end -- 1579
		if self.gateTick == 900 then -- 1579
			self:flashSet("灯灭了", 1) -- 1582
		elseif self.gateTick == 2100 then -- 1582
			self:flashSet("门底压下来了", 1) -- 1584
		end -- 1584
		if self.gateTick >= g.holdTicks then -- 1584
			self:captureGateBlood() -- 1589
			self.phase = "gate-send" -- 1590
			self.phaseTick = 0 -- 1591
			self.enemies = {} -- 1593
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1594
		end -- 1594
		return -- 1596
	end -- 1596
	if self.phase == "gate-send" then -- 1596
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1599
		if near and input.interact.pressed then -- 1599
			self:commitRoute() -- 1602
			self:swapToChild(g.doorX + 30) -- 1603
			self.phase = "gate-count" -- 1604
			self.countTick = 0 -- 1605
			self.countArmed = false -- 1607
			self.countPrevMove = input.moveX -- 1608
			self:flashSet("门开了 · 送她出去", 1.8) -- 1609
		end -- 1609
		return -- 1611
	end -- 1611
	if self.phase == "gate-count" then -- 1611
		self.countTick = self.countTick + 1 -- 1614
		if self.countTick == 360 then -- 1614
			self:flashSet("门关上", 0.9) -- 1616
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 1616
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 1618
			if self.storyRoute == "soldier" then -- 1618
				self.phase = "gate-wait" -- 1624
				self.phaseTick = 0 -- 1625
				self.knocks = 1 -- 1626
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 1627
				self.handArmed = not input.interact.held -- 1629
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 1630
			else -- 1630
				self:flashSet("数到二十", 2.2) -- 1632
			end -- 1632
		end -- 1632
		local prevMove = self.countPrevMove -- 1637
		self.countPrevMove = input.moveX -- 1638
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 1638
			if prevMove <= 0 and input.moveX > 0 then -- 1638
				self.countArmed = true -- 1641
			end -- 1641
			if self.countArmed and input.moveX > 0 then -- 1641
				self.phase = "gate-walk" -- 1644
				self.phaseTick = 0 -- 1645
				self:flashSet("她迈出第一步", 1.4) -- 1646
				self:emit("storyExit", { -- 1647
					route = "child", -- 1647
					via = "walk", -- 1647
					countTick = self.countTick, -- 1647
					hp = self.hp, -- 1647
					maxHp = self.maxHp -- 1647
				}) -- 1647
			end -- 1647
		end -- 1647
		return -- 1650
	end -- 1650
	if self.phase == "gate-wait" then -- 1650
		self.phaseTick = self.phaseTick + 1 -- 1654
		if self.phaseTick == 12 then -- 1654
			self.knocks = 2 -- 1656
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 1657
			self:flashSet("第二下 · 她抬手了", 1.6) -- 1658
		end -- 1658
		if not input.interact.held then -- 1658
			if self.handTicks > 0 then -- 1658
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1662
			end -- 1662
			self.handTicks = 0 -- 1664
			self.handArmed = true -- 1665
			return -- 1666
		end -- 1666
		if self.handArmed then -- 1666
			self.handTicks = self.handTicks + 1 -- 1669
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 1669
				self.phase = "gate-hand" -- 1671
				self.phaseTick = 0 -- 1672
				self.handDone = true -- 1673
				self.tied = true -- 1674
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1675
				if not self.lineSaid then -- 1675
					self.lineSaid = true -- 1677
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 1678
				end -- 1678
				self:flashSet("我们走吧。", 3) -- 1680
			end -- 1680
		end -- 1680
		return -- 1683
	end -- 1683
	if self.phase == "gate-hand" then -- 1683
		self.phaseTick = self.phaseTick + 1 -- 1687
		if self.phaseTick == 30 then -- 1687
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 1689
		elseif self.phaseTick >= 90 then -- 1689
			self:emit("storyExit", { -- 1691
				route = "soldier", -- 1691
				via = "hand", -- 1691
				handTicks = self.handTicks, -- 1691
				hp = self.hp, -- 1691
				maxHp = self.maxHp -- 1691
			}) -- 1691
			self:requestRoom("gatepath", "牵手同行") -- 1692
		end -- 1692
		return -- 1694
	end -- 1694
	if self.phase == "gate-walk" then -- 1694
		if self.player.x >= g.exitX then -- 1694
			self:requestRoom("outside", "走出城门") -- 1699
			self:flashSet("出城门 · 城外", 1.4) -- 1700
		end -- 1700
	end -- 1700
end -- 1516
function Play.prototype.captureGateBlood(self) -- 1709
	self.hpAtGate = self.hp -- 1710
	self.maxHpAtGate = self.maxHp -- 1711
end -- 1709
function Play.prototype.commitRoute(self) -- 1718
	if self.storySettled then -- 1718
		return -- 1720
	end -- 1720
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 1722
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 1723
	self.hpAtGate = hp -- 1724
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 1725
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 1726
	self.storySettled = true -- 1727
	self:emit("storyRouteLocked", { -- 1728
		route = self.storyRoute, -- 1729
		hp = self.hp, -- 1729
		maxHp = self.maxHp, -- 1729
		hpAtGate = self.hpAtGate, -- 1730
		maxHpAtGate = self.maxHpAtGate -- 1730
	}) -- 1730
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 1732
end -- 1718
function Play.prototype.syncStory(self) -- 1736
	if self.isCampaign and self.run.trial ~= nil then -- 1736
		return -- 1738
	end -- 1738
	local s = self.run.story -- 1740
	if s == nil then -- 1740
		return -- 1742
	end -- 1742
	s.hp = self.hp -- 1744
	s.maxHp = self.maxHp -- 1745
	s.route = self.storyRoute -- 1746
	s.settled = self.storySettled -- 1747
	s.hpAtGate = self.hpAtGate -- 1748
	s.maxHpAtGate = self.maxHpAtGate -- 1749
	s.handDone = self.handDone -- 1750
	s.lineSaid = self.lineSaid -- 1751
	s.tied = self.tied -- 1752
	s.carry = self.carryOn -- 1753
	s.escortDone = self.escortDone -- 1754
	if self.room.key == "gate" then -- 1754
		s.phase = self.phase -- 1756
		s.countTick = self.countTick -- 1757
		s.phaseTick = self.phaseTick -- 1758
		s.handTicks = self.handTicks -- 1759
	end -- 1759
end -- 1736
function Play.prototype.stepGatePath(self) -- 1764
	local ____temp_37 -- 1765
	if self.room.story == nil then -- 1765
		____temp_37 = nil -- 1765
	else -- 1765
		____temp_37 = self.room.story.gatepath -- 1765
	end -- 1765
	local gp = ____temp_37 -- 1765
	if self.phase == "gatepath-start" then -- 1765
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 1765
			self.carryOn = true -- 1768
			self.phase = "gatepath-carry" -- 1769
			self.phaseTick = 0 -- 1770
			self.pathDone = true -- 1771
			self.escortDone = false -- 1772
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 1773
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 1774
			self:flashSet("蹲下 · 背起小满", 2.6) -- 1775
		end -- 1775
		return -- 1777
	end -- 1777
	if self.phase == "gatepath-carry" then -- 1777
		self.phaseTick = self.phaseTick + 1 -- 1780
		if self.phaseTick == 20 then -- 1780
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 1782
		end -- 1782
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 1782
			self:requestRoom(gp.next, "背负进首战") -- 1785
			self:flashSet("背上她 · 巷口有脚步", 2) -- 1786
		end -- 1786
	end -- 1786
end -- 1764
function Play.prototype.carryPose(self) -- 1795
	local p = self.player -- 1796
	local a = self.partner -- 1797
	a.alive = true -- 1798
	a.x = p.x - p.facing * 12 -- 1799
	a.y = p.y + 26 -- 1800
	a.depth = p.depth -- 1801
	a.vx = p.vx -- 1802
	a.vy = 0 -- 1803
	a.onGround = true -- 1804
	a.crouch = false -- 1805
	a.h = CHILD_CROUCH_H -- 1806
	a.facing = p.facing -- 1807
end -- 1795
function Play.prototype.stepTower(self, dt, input) -- 1811
	local ____temp_38 -- 1812
	if self.room.story == nil then -- 1812
		____temp_38 = nil -- 1812
	else -- 1812
		____temp_38 = self.room.story.tower -- 1812
	end -- 1812
	local t = ____temp_38 -- 1812
	if t == nil then -- 1812
		return -- 1814
	end -- 1814
	if self.phase == "tower-wait" then -- 1814
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 1817
		if near and input.interact.pressed then -- 1817
			self.phase = "tower-knock" -- 1819
			self.phaseTick = 0 -- 1820
			self.knocks = 1 -- 1821
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 1822
			self:flashSet("敲一下", 0.6) -- 1823
		end -- 1823
		return -- 1825
	end -- 1825
	if self.phase == "tower-knock" then -- 1825
		self.phaseTick = self.phaseTick + 1 -- 1828
		if self.phaseTick == 12 then -- 1828
			self.knocks = 2 -- 1830
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 1831
			self:flashSet("敲两下 · 第二声", 1) -- 1832
		elseif self.phaseTick >= t.knockTicks then -- 1832
			self.phase = "tower-given" -- 1834
			self.phaseTick = 0 -- 1835
			self:flashSet("门开了 · 提灯", 1.4) -- 1836
		end -- 1836
		return -- 1838
	end -- 1838
	if self.phase == "tower-given" then -- 1838
		self.phaseTick = self.phaseTick + 1 -- 1841
		if self.phaseTick == 60 then -- 1841
			self:flashSet("她递出针套和纸条", 1.6) -- 1843
		elseif self.phaseTick == 120 then -- 1843
			self:flashSet("登记簿最后一页 · 空行留着", 2.4) -- 1845
		elseif self.phaseTick >= 180 then -- 1845
			self.phase = "tower-end" -- 1847
			self.phaseTick = 0 -- 1848
			self:flashSet("片尾 · E 再玩一次", 3) -- 1849
		end -- 1849
		return -- 1851
	end -- 1851
	if input.interact.pressed or input.retry.pressed then -- 1851
		self:requestRoom("prologue", "片尾再玩") -- 1854
		self:flashSet("回到序章", 1.4) -- 1855
	end -- 1855
end -- 1811
function Play.prototype.stepChase(self, dt, input) -- 1860
	if self.caughtT > 0 then -- 1860
		self.caughtT = self.caughtT - dt -- 1862
		if self.caughtT <= 0 then -- 1862
			self:recoverFromCaught() -- 1864
		end -- 1864
		return -- 1866
	end -- 1866
	if self.room.key == "village" then -- 1866
		self:stepScavChase() -- 1869
	elseif self.room.key == "forest" then -- 1869
		self:stepDog(dt) -- 1871
		if self.player.x >= self.ox + 1450 then -- 1871
			self:requestRoom("tower", "到林缘北塔") -- 1874
			self:flashSet("林缘 · 北塔", 1.4) -- 1875
		end -- 1875
	end -- 1875
end -- 1860
function Play.prototype.stepScavChase(self) -- 1881
	local s = self.room.scavenger -- 1882
	if s == nil then -- 1882
		return -- 1884
	end -- 1884
	local p = self.player -- 1886
	if self.passed and p.x > self.ox + 440 then -- 1886
		if self.scavChase then -- 1886
			self.scavChase = false -- 1890
			self.scavState = "back" -- 1891
			self.scavT = 0 -- 1892
		end -- 1892
		return -- 1894
	end -- 1894
	local dx = p.x - self.scavX -- 1896
	local dist = math.abs(dx) -- 1897
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 1898
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 1899
	if not self.scavChase then -- 1899
		if visible then -- 1899
			self.scavSee = self.scavSee + 1 -- 1902
			if self.scavSee >= 24 then -- 1902
				self.scavChase = true -- 1904
				self.scavState = "chase" -- 1905
				self.scavTargetX = p.x -- 1906
				self:flashSet("他看见你了", 1.2) -- 1907
			end -- 1907
		else -- 1907
			self.scavSee = 0 -- 1910
		end -- 1910
		return -- 1912
	end -- 1912
	local dir = p.x > self.scavX and 1 or -1 -- 1915
	self.scavX = self.scavX + dir * 96 / 60 -- 1916
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 1916
		self:caught() -- 1918
		return -- 1919
	end -- 1919
	if hidden then -- 1919
		self.scavSee = 0 -- 1923
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 1924
		self.scavT = self.scavT - 1 -- 1925
		if self.scavT <= 0 then -- 1925
			self.scavChase = false -- 1927
			self.scavState = "patrol" -- 1928
			self:flashSet("他失去了目标", 1) -- 1929
		end -- 1929
	end -- 1929
end -- 1881
function Play.prototype.stepDog(self, dt) -- 1935
	local ____temp_39 -- 1936
	if self.room.story == nil then -- 1936
		____temp_39 = nil -- 1936
	else -- 1936
		____temp_39 = self.room.story.dog -- 1936
	end -- 1936
	local dog = ____temp_39 -- 1936
	if dog == nil then -- 1936
		return -- 1938
	end -- 1938
	local p = self.player -- 1940
	local dist = math.abs(p.x - self.dogX) -- 1941
	if self.dogState == "patrol" then -- 1941
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 1943
		if self.dogX < dog.x0 then -- 1943
			self.dogX = dog.x0 -- 1945
			self.dogDir = 1 -- 1946
		elseif self.dogX > dog.x1 then -- 1946
			self.dogX = dog.x1 -- 1948
			self.dogDir = -1 -- 1949
		end -- 1949
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 1951
		if not p.crouch and moving and dist < dog.range then -- 1951
			self.dogState = "ear" -- 1953
			self.dogT = 18 -- 1954
			self.dogTargetX = p.x -- 1955
			self:flashSet("狗转耳朵", 0.8) -- 1956
		end -- 1956
		return -- 1958
	end -- 1958
	if self.dogState == "ear" then -- 1958
		self.dogT = self.dogT - 1 -- 1961
		if self.dogT <= 0 then -- 1961
			self.dogState = "chase" -- 1963
			self.dogTargetX = p.x -- 1964
			self:flashSet("狗追来了", 1.4) -- 1965
		end -- 1965
		return -- 1967
	end -- 1967
	if self.dogState == "chase" then -- 1967
		local dir = p.x > self.dogX and 1 or -1 -- 1970
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 1971
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 1971
			self:caught() -- 1973
			self.dogState = "sniff" -- 1974
			self.dogT = 60 -- 1975
		elseif dist > dog.range * 1.5 or p.crouch then -- 1975
			self.dogState = "sniff" -- 1977
			self.dogT = 60 -- 1978
			self:flashSet("狗停下了", 0.9) -- 1979
		end -- 1979
		return -- 1981
	end -- 1981
	if self.dogState == "sniff" then -- 1981
		self.dogT = self.dogT - 1 -- 1984
		if self.dogT <= 0 then -- 1984
			self.dogState = "back" -- 1986
		end -- 1986
		return -- 1988
	end -- 1988
	local dir = dog.x0 > self.dogX and 1 or -1 -- 1991
	self.dogX = self.dogX + dir * dog.speed * dt -- 1992
	if math.abs(self.dogX - dog.x0) < 2 then -- 1992
		self.dogX = dog.x0 -- 1994
		self.dogState = "patrol" -- 1995
	end -- 1995
end -- 1935
function Play.prototype.caught(self) -- 1999
	self.caughtT = 1 -- 2000
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2001
end -- 1999
function Play.prototype.recoverFromCaught(self) -- 2005
	local p = self.player -- 2006
	p.x = self.ox + 140 -- 2007
	p.y = 0 -- 2008
	p.vy = 0 -- 2009
	p.vx = 0 -- 2010
	p.onGround = true -- 2011
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2011
		self.scavX = self.room.scavenger.x0 -- 2013
		self.scavState = "patrol" -- 2014
		self.scavSee = 0 -- 2015
		self.scavChase = false -- 2016
		self.scavT = 0 -- 2017
	end -- 2017
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2017
		self.dogX = self.room.story.dog.x0 -- 2020
		self.dogState = "patrol" -- 2021
		self.dogT = 0 -- 2022
	end -- 2022
	self.cam.x = p.x -- 2024
	self.cam.y = p.y + CAM_LOOK_UP -- 2025
	self:flashSet("回到安全点", 1.2) -- 2026
end -- 2005
function Play.prototype.updateGate(self) -- 2030
	if self.room.key ~= "checkpoint" then -- 2030
		self.gateOpen = false -- 2032
		return -- 2033
	end -- 2033
	local function inZone(x) -- 2035
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2035
	end -- 2035
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2036
end -- 2030
function Play.prototype.addItem(self, kind) -- 2042
	local inv = self.run.inventory -- 2043
	if kind == "shield" then -- 2043
		if inv.shield >= TOOL_CAP then -- 2043
			return false -- 2046
		end -- 2046
		inv.shield = inv.shield + 1 -- 2048
		return true -- 2049
	end -- 2049
	if kind == "wedge" then -- 2049
		if inv.wedge >= CONSUMABLE_CAP then -- 2049
			return false -- 2053
		end -- 2053
		inv.wedge = inv.wedge + 1 -- 2055
		return true -- 2056
	end -- 2056
	if kind == "ammo" then -- 2056
		if inv.ammo >= CONSUMABLE_CAP then -- 2056
			return false -- 2060
		end -- 2060
		inv.ammo = inv.ammo + 1 -- 2062
		return true -- 2063
	end -- 2063
	if kind == "scrap" then -- 2063
		inv.scrap = inv.scrap + 1 -- 2067
		return true -- 2068
	end -- 2068
	if kind == "pass" then -- 2068
		inv.pass = inv.pass + 1 -- 2071
		return true -- 2072
	end -- 2072
	if kind == "quickbelt" then -- 2072
		inv.quickbelt = inv.quickbelt + 1 -- 2075
		return true -- 2076
	end -- 2076
	return false -- 2078
end -- 2042
function Play.prototype.findBox(self, id) -- 2081
	local i = 0 -- 2082
	do -- 2082
		i = 0 -- 2083
		while i < #self.boxes do -- 2083
			if self.boxes[i + 1].id == id then -- 2083
				return self.boxes[i + 1] -- 2085
			end -- 2085
			i = i + 1 -- 2083
		end -- 2083
	end -- 2083
	return nil -- 2088
end -- 2081
function Play.prototype.findWedgeTarget(self) -- 2092
	local best = nil -- 2093
	local bestD = 0 -- 2094
	local i = 0 -- 2095
	do -- 2095
		i = 0 -- 2096
		while i < #self.boxes do -- 2096
			do -- 2096
				local b = self.boxes[i + 1] -- 2097
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2097
					goto __continue318 -- 2099
				end -- 2099
				if not self:nearBox(b, 26) then -- 2099
					goto __continue318 -- 2102
				end -- 2102
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2104
				if best == nil or d < bestD then -- 2104
					best = b -- 2106
					bestD = d -- 2107
				end -- 2107
			end -- 2107
			::__continue318:: -- 2107
			i = i + 1 -- 2096
		end -- 2096
	end -- 2096
	return best -- 2110
end -- 2092
function Play.prototype.stepCraft(self, input) -- 2118
	local inv = self.run.inventory -- 2119
	local ____opt_40 = self.run.trial -- 2119
	local required = CRAFT_TICKS - 6 * (____opt_40 and ____opt_40.ranks.craft or 0) -- 2120
	if self.craftT > 0 then -- 2120
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2120
			self.craftT = 0 -- 2124
			self:flashSet("制作中断", 0.8) -- 2125
			return true -- 2126
		end -- 2126
		self.craftT = self.craftT + 1 -- 2128
		if self.craftT >= required then -- 2128
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2128
				inv.scrap = inv.scrap - 1 -- 2131
				inv.wedge = inv.wedge + 1 -- 2132
				self:flashSet("制得木楔", 1.2) -- 2133
				self:log("制木楔") -- 2134
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2135
			end -- 2135
			self.craftT = 0 -- 2137
		end -- 2137
		return true -- 2139
	end -- 2139
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2139
		self.craftT = 1 -- 2142
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2143
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2144
		return true -- 2145
	end -- 2145
	return false -- 2147
end -- 2118
function Play.prototype.nearBox(self, b, reach) -- 2150
	local p = self.player -- 2151
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2152
end -- 2150
function Play.prototype.findInteract(self) -- 2158
	local p = self.player -- 2159
	local best = nil -- 2160
	local bestD = 1000000000 -- 2161
	local i = 0 -- 2162
	do -- 2162
		i = 0 -- 2163
		while i < #self.boxes do -- 2163
			do -- 2163
				local b = self.boxes[i + 1] -- 2164
				if b.interact == nil or b.broken == true then -- 2164
					goto __continue331 -- 2166
				end -- 2166
				if not self:nearBox(b, b.interact.reach or 27) then -- 2166
					goto __continue331 -- 2169
				end -- 2169
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2171
				if d < bestD then -- 2171
					bestD = d -- 2173
					best = b -- 2174
				end -- 2174
			end -- 2174
			::__continue331:: -- 2174
			i = i + 1 -- 2163
		end -- 2163
	end -- 2163
	return best -- 2177
end -- 2158
function Play.prototype.stepCampaign(self, dt, input) -- 2181
	local wr = self.room -- 2182
	local p = self.player -- 2183
	if self.reloadT > 0 then -- 2183
		self.reloadT = self.reloadT - 1 -- 2185
	end -- 2185
	if self.bracedShield ~= nil then -- 2185
		self.bracedShield.x = p.x + p.facing * 26 -- 2189
		self.bracedShield.y = p.y -- 2190
		local shBox = __TS__ArrayFind( -- 2191
			self.boxes, -- 2191
			function(____, b) return b.id == "braced_shield" end -- 2191
		) -- 2191
		if shBox ~= nil then -- 2191
			shBox.x0 = self.bracedShield.x - 15 -- 2193
			shBox.x1 = self.bracedShield.x + 15 -- 2194
			shBox.y0 = self.bracedShield.y -- 2195
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2196
		end -- 2196
	end -- 2196
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2196
		self.run.route = "drygoods" -- 2202
		self.run.joined = false -- 2203
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2204
		self:log("转布行线") -- 2205
	end -- 2205
	local i = 0 -- 2208
	do -- 2208
		i = 0 -- 2209
		while i < #self.pickups do -- 2209
			do -- 2209
				local pk = self.pickups[i + 1] -- 2210
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2210
					goto __continue342 -- 2212
				end -- 2212
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2214
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2215
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2215
					if not self:addItem(pk.kind) then -- 2215
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2219
						self:log("满包拒绝 " .. pk.kind) -- 2220
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2221
						goto __continue342 -- 2222
					end -- 2222
					self.run.taken[pk.id] = true -- 2224
					pk.id = "" -- 2225
					self:flashSet("拾取 " .. pk.label, 1) -- 2226
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2227
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2228
				end -- 2228
			end -- 2228
			::__continue342:: -- 2228
			i = i + 1 -- 2209
		end -- 2209
	end -- 2209
	if not self:stepCraft(input) and input.interact.pressed then -- 2209
		self:campaignInteract() -- 2232
	end -- 2232
	self:stepCampaignCart(dt, input) -- 2234
	self:stepCampaignGoal() -- 2235
end -- 2181
function Play.prototype.campaignInteract(self) -- 2239
	local b = self:findInteract() -- 2240
	if b ~= nil then -- 2240
		self:useInteract(b) -- 2242
		return -- 2243
	end -- 2243
	local inv = self.run.inventory -- 2245
	if inv.wedge > 0 then -- 2245
		local w = self:findWedgeTarget() -- 2247
		if w ~= nil then -- 2247
			if w.breakable ~= nil then -- 2247
				local ____w_breakable_42, ____hp_43 = w.breakable, "hp" -- 2247
				____w_breakable_42[____hp_43] = ____w_breakable_42[____hp_43] + (w.breakable.wedgeHp or 1) -- 2250
			end -- 2250
			inv.wedge = inv.wedge - 1 -- 2252
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2253
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2255
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2256
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2257
			return -- 2258
		end -- 2258
	end -- 2258
	if inv.ammo > 0 and self.reloadT > 0 then -- 2258
		self.reloadT = 0 -- 2263
		self:closeReloadPuzzle() -- 2264
		inv.ammo = inv.ammo - 1 -- 2265
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2266
		self:log("用备用弹包") -- 2267
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2268
		return -- 2269
	end -- 2269
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2269
		local p = self.player -- 2273
		self.bracedShield = { -- 2274
			x = p.x + p.facing * 26, -- 2274
			y = p.y, -- 2274
			w = 30, -- 2274
			h = 64, -- 2274
			hp = 1 -- 2274
		} -- 2274
		local ____self_boxes_44 = self.boxes -- 2274
		____self_boxes_44[#____self_boxes_44 + 1] = { -- 2275
			x0 = self.bracedShield.x - 15, -- 2276
			x1 = self.bracedShield.x + 15, -- 2276
			y0 = p.y, -- 2277
			y1 = p.y + 64, -- 2277
			depth = {min = -46, max = 46}, -- 2277
			label = "架起的残盾", -- 2277
			id = "braced_shield", -- 2277
			soft = true -- 2278
		} -- 2278
		inv.shield = inv.shield - 1 -- 2281
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2282
		self:log("架残盾") -- 2283
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2284
		return -- 2285
	end -- 2285
	if inv.pass > 0 and self.run.joined == false then -- 2285
		inv.pass = inv.pass - 1 -- 2288
		self.run.joined = true -- 2289
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2290
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2291
		return -- 2292
	end -- 2292
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2294
end -- 2239
function Play.prototype.useInteract(self, b) -- 2297
	local kind = b.interact == nil and "" or b.interact.kind -- 2298
	local wr = self.room -- 2299
	if kind == "open_board" then -- 2299
		b.broken = true -- 2301
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2302
		for ____, cover in ipairs(self.boxes) do -- 2303
			if cover.id == "s2_board_cover" then -- 2303
				cover.broken = false -- 2305
				cover.hidden = false -- 2306
			end -- 2306
		end -- 2306
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2309
		self.run.joined = true -- 2310
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2311
		self:log("放下窗板") -- 2312
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2313
		return -- 2314
	end -- 2314
	if kind == "lower_curtain" then -- 2314
		for ____, curtain in ipairs(self.boxes) do -- 2317
			if curtain.id == "c2_curtain" then -- 2317
				curtain.broken = false -- 2319
				curtain.hidden = false -- 2320
			end -- 2320
		end -- 2320
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2323
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2324
		self:log("放下木帘") -- 2325
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2326
		return -- 2327
	end -- 2327
	if kind == "raise_latch" then -- 2327
		if wr.key == "c2-granary" and not self.cartDocked then -- 2327
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2331
			return -- 2332
		end -- 2332
		b.broken = true -- 2334
		self.objectiveDone = true -- 2335
		if wr.key == "c1-yard" then -- 2335
			self.run.c1Latch = true -- 2338
			self.run.joined = true -- 2339
		else -- 2339
			self.run.c2Latch = true -- 2341
			self.run.joined = true -- 2342
		end -- 2342
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2344
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2345
		self:log("抬闩") -- 2346
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2347
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2348
	end -- 2348
end -- 2297
function Play.prototype.stepCampaignCart(self, dt, input) -- 2353
	local wr = self.room -- 2354
	local c = wr.cart -- 2355
	if c.bodyW <= 0 then -- 2355
		return -- 2357
	end -- 2357
	local p = self.player -- 2359
	local handleX = self.cartAxle + c.handleOffset -- 2360
	if not self.gripping then -- 2360
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2360
			self.gripping = true -- 2364
			self:flashSet("握住车柄 · A/D 推", 1) -- 2365
		end -- 2365
		return -- 2367
	end -- 2367
	if input.interact.pressed then -- 2367
		self.gripping = false -- 2370
		self:flashSet("松手", 0.5) -- 2371
		return -- 2372
	end -- 2372
	if not self.cartDocked then -- 2372
		if input.moveX ~= 0 and not self:stuckCart() then -- 2372
			self.cartAxle = math.max( -- 2376
				c.startX, -- 2376
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2376
			) -- 2376
		end -- 2376
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2376
			self.cartExposed = true -- 2381
			local gun = nil -- 2382
			local gi = 0 -- 2383
			do -- 2383
				gi = 0 -- 2384
				while gi < #self.enemies do -- 2384
					local e = self.enemies[gi + 1] -- 2385
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2385
						gun = e -- 2387
						break -- 2388
					end -- 2388
					gi = gi + 1 -- 2384
				end -- 2384
			end -- 2384
			if gun ~= nil then -- 2384
				self:campaignEnemyFire(gun) -- 2392
			end -- 2392
		end -- 2392
		p.x = self.cartAxle + c.handleOffset -- 2395
		p.y = c.baseY + (c.depth or 0) -- 2396
		p.vx = 0 -- 2397
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2397
			self.cartAxle = c.endX -- 2399
			self.cartDocked = true -- 2400
			self.gripping = false -- 2401
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2402
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2403
			self:flashSet("车轮入窝", 1.2) -- 2404
			self:log("车轮入窝") -- 2405
		end -- 2405
	end -- 2405
end -- 2353
function Play.prototype.stuckCart(self) -- 2411
	local i = 0 -- 2412
	do -- 2412
		i = 0 -- 2413
		while i < #self.boxes do -- 2413
			do -- 2413
				local b = self.boxes[i + 1] -- 2414
				if b.broken == true or b.breakable == nil or b.soft == true then -- 2414
					goto __continue383 -- 2416
				end -- 2416
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 2418
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 2418
					return true -- 2420
				end -- 2420
			end -- 2420
			::__continue383:: -- 2420
			i = i + 1 -- 2413
		end -- 2413
	end -- 2413
	return false -- 2423
end -- 2411
function Play.prototype.stepCampaignGoal(self) -- 2427
	local wr = self.room -- 2428
	local c = wr.campaign -- 2429
	if c == nil then -- 2429
		return -- 2431
	end -- 2431
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 2431
		self.objectiveDone = true -- 2434
	end -- 2434
	if c.goal == "reach_exit" then -- 2434
		self.objectiveDone = true -- 2437
	end -- 2437
	if not self.objectiveDone then -- 2437
		return -- 2440
	end -- 2440
	local p = self.player -- 2442
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 2443
	if p.x < c.exitX or not partnerOk then -- 2443
		return -- 2445
	end -- 2445
	if c.next ~= nil and c.next ~= "" then -- 2445
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 2448
		self:flashSet("过关 · " .. c.next, 1.2) -- 2449
	elseif not self.run.finished then -- 2449
		self.run.finished = true -- 2451
		self:flashSet( -- 2452
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 2452
			2 -- 2452
		) -- 2452
		self:log("C2 灰盒完成") -- 2453
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 2454
	end -- 2454
end -- 2427
function Play.prototype.stepCampaignPartner(self, dt) -- 2459
	local a = self.partner -- 2460
	local wr = self.room -- 2461
	local cp = wr.companion -- 2462
	if not a.alive then -- 2462
		return -- 2464
	end -- 2464
	local p = self.player -- 2466
	local wait = false -- 2467
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 2468
	local targetDepth = p.depth -- 2469
	if self.run.joined == false then -- 2469
		wait = true -- 2471
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2472
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2473
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 2473
		wait = true -- 2475
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2476
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2477
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 2477
		wait = true -- 2479
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2480
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2481
	end -- 2481
	if self.partnerStuck > 0.3 then -- 2481
		a.x = a.x + a.facing * 44 -- 2485
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2486
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2487
		self.partnerLaneHold = 1.1 -- 2488
		self.partnerStuck = 0 -- 2489
	end -- 2489
	if self.partnerLaneHold > 0 then -- 2489
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2492
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2493
	end -- 2493
	local dx = targetX - a.x -- 2495
	if not wait and math.abs(dx) > 74 then -- 2495
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2497
		local before = a.x -- 2498
		a.vx = dx > 0 and speed or -speed -- 2499
		a.facing = dx > 0 and 1 or -1 -- 2500
		self:slideX(a, a.vx * dt) -- 2501
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2501
			a.vy = CHILD_JUMP -- 2504
			a.onGround = false -- 2505
		end -- 2505
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2507
	else -- 2507
		a.vx = 0 -- 2509
		self.partnerStuck = 0 -- 2510
	end -- 2510
	local dz = targetDepth - a.depth -- 2512
	if math.abs(dz) > 6 then -- 2512
		local step = math.max( -- 2514
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2514
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2514
		) -- 2514
		a.depth = a.depth + step -- 2515
	end -- 2515
	a.depthSpeed = 0 -- 2517
	a.h = CHILD_H -- 2518
	a.crouch = false -- 2519
	self:fallY(a, dt) -- 2520
end -- 2459
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2524
	local p = self.player -- 2525
	local i = 0 -- 2526
	do -- 2526
		i = 0 -- 2527
		while i < #self.enemies do -- 2527
			do -- 2527
				local ____opt_45 = self.run.trial -- 2527
				if ____opt_45 and ____opt_45.lost then -- 2527
					return -- 2528
				end -- 2528
				local e = self.enemies[i + 1] -- 2529
				if not e.alive then -- 2529
					goto __continue407 -- 2531
				end -- 2531
				if e.hitT > 0 then -- 2531
					e.hitT = e.hitT - dt -- 2534
				end -- 2534
				if e.kind == "breaker" then -- 2534
					self:stepBreaker(e, dt) -- 2537
					goto __continue407 -- 2538
				end -- 2538
				if e.kind == "shield" then -- 2538
					self:stepShield(e, dt, input) -- 2541
					goto __continue407 -- 2542
				end -- 2542
				local dx = e.x - p.x -- 2545
				if not e.awake then -- 2545
					if math.abs(dx) > 520 then -- 2545
						goto __continue407 -- 2548
					end -- 2548
					e.awake = true -- 2550
					e.fireCd = 48 -- 2551
					goto __continue407 -- 2552
				end -- 2552
				if math.abs(dx) > ENEMY_RANGE then -- 2552
					goto __continue407 -- 2555
				end -- 2555
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2555
					goto __continue407 -- 2560
				end -- 2560
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2560
					goto __continue407 -- 2563
				end -- 2563
				if self:blockedShot(e, p) then -- 2563
					if e.warnT > 0 then -- 2563
						e.warnT = 0 -- 2569
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2570
					end -- 2570
					goto __continue407 -- 2572
				end -- 2572
				if e.warnT > 0 then -- 2572
					e.warnT = e.warnT - 1 -- 2575
					if e.warnT <= 0 then -- 2575
						self:campaignEnemyFire(e) -- 2577
					end -- 2577
				elseif e.fireCd > 0 then -- 2577
					e.fireCd = e.fireCd - 1 -- 2580
					if e.fireCd <= 0 then -- 2580
						e.warnT = WARN_TICKS -- 2582
					end -- 2582
				else -- 2582
					e.fireCd = 40 -- 2585
				end -- 2585
			end -- 2585
			::__continue407:: -- 2585
			i = i + 1 -- 2527
		end -- 2527
	end -- 2527
end -- 2524
function Play.prototype.blockedShot(self, e, p) -- 2591
	local eDepth = e.depth or 0 -- 2592
	local ex = e.x -- 2593
	local ey = e.y + e.h * 0.62 -- 2595
	local px = p.x -- 2596
	local py = p.y + p.h * 0.55 -- 2597
	local dx = px - ex -- 2598
	local dyScreen = py + p.depth - (ey + eDepth) -- 2599
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 2600
	if len < 0.01 then -- 2600
		return false -- 2602
	end -- 2602
	local ray = { -- 2606
		x = ex, -- 2607
		y = ey, -- 2607
		dx = dx / len, -- 2608
		dy = (py - ey) / len, -- 2608
		depth = eDepth, -- 2609
		dDepth = (p.depth - eDepth) / len -- 2609
	} -- 2609
	local best = -1 -- 2611
	local j = 0 -- 2612
	do -- 2612
		j = 0 -- 2613
		while j < #self.boxes do -- 2613
			do -- 2613
				local b = self.boxes[j + 1] -- 2614
				if b.broken == true or b.passable == true or b.hidden == true then -- 2614
					goto __continue428 -- 2616
				end -- 2616
				if b.id == "braced_shield" then -- 2616
					goto __continue428 -- 2621
				end -- 2621
				local t = hitBox(ray, b) -- 2623
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 2623
					best = t -- 2627
				end -- 2627
			end -- 2627
			::__continue428:: -- 2627
			j = j + 1 -- 2613
		end -- 2613
	end -- 2613
	return best >= 0 -- 2630
end -- 2591
function Play.prototype.campaignEnemyFire(self, e) -- 2633
	local p = self.player -- 2634
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2635
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 2635
		local ____self_bracedShield_47, ____hp_48 = self.bracedShield, "hp" -- 2635
		____self_bracedShield_47[____hp_48] = ____self_bracedShield_47[____hp_48] - 1 -- 2637
		self.boxes = __TS__ArrayFilter( -- 2638
			self.boxes, -- 2638
			function(____, b) return b.id ~= "braced_shield" end -- 2638
		) -- 2638
		self.bracedShield = nil -- 2639
		self:flashSet("残盾碎 · 挡下一发", 1) -- 2640
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 2641
		return -- 2642
	end -- 2642
	if self:blockedShot(e, p) then -- 2642
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 2645
		return -- 2646
	end -- 2646
	local cover = self:blockedByCover(e, p) -- 2648
	if cover ~= nil and self.coverHug then -- 2648
		self.coveredFlash = 0.5 -- 2650
		self:flashSet("掩体挡下", 0.6) -- 2651
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2652
		return -- 2657
	end -- 2657
	if self.invulnT > 0 then -- 2657
		return -- 2660
	end -- 2660
	local ____opt_49 = self.run.trial -- 2660
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_49 and ____opt_49.ranks.guard or 0) -- 2662
	self.craftT = 0 -- 2663
	self.hp = self.hp - 1 -- 2664
	self:emit("actorHit", { -- 2665
		target = "player", -- 2665
		amount = 1, -- 2665
		hp = self.hp, -- 2665
		maxHp = self.maxHp, -- 2665
		enemyX = e.x -- 2665
	}) -- 2665
	self:flashSet( -- 2666
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2666
		0.8 -- 2666
	) -- 2666
	if self.hp <= 0 then -- 2666
		self:campaignFailed() -- 2668
	end -- 2668
end -- 2633
function Play.prototype.stepShield(self, e, dt, input) -- 2673
	local p = self.player -- 2674
	local dx = p.x - e.x -- 2675
	local adx = math.abs(dx) -- 2676
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 2679
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 2680
	if adx > 150 then -- 2680
		local before = e.x -- 2682
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 2683
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 2683
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2686
		end -- 2686
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 2686
		local fromFront = (e.x - p.x) * p.facing > 0 -- 2691
		local rollDodges = p.rollT > 0 and fromFront -- 2692
		if not rollDodges and self.invulnT <= 0 then -- 2692
			local ____opt_51 = self.run.trial -- 2692
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_51 and ____opt_51.ranks.guard or 0) -- 2694
			self.craftT = 0 -- 2695
			self.hp = self.hp - 1 -- 2696
			self:emit("actorHit", { -- 2697
				target = "player", -- 2697
				amount = 1, -- 2697
				hp = self.hp, -- 2697
				maxHp = self.maxHp, -- 2697
				enemyX = e.x -- 2697
			}) -- 2697
			self:flashSet( -- 2698
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2698
				0.8 -- 2698
			) -- 2698
			if self.hp <= 0 then -- 2698
				self:campaignFailed() -- 2700
				return -- 2701
			end -- 2701
		end -- 2701
		e.swingT = 70 -- 2704
	end -- 2704
	if (e.swingT or 0) > 0 then -- 2704
		e.swingT = (e.swingT or 0) - 1 -- 2707
	end -- 2707
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 2707
		local dd = p.depth - (e.depth or 0) -- 2710
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 2711
	end -- 2711
end -- 2673
function Play.prototype.stepBreaker(self, e, dt) -- 2716
	local p = self.player -- 2717
	if e.awake ~= true then -- 2717
		if math.abs(p.x - e.x) < 560 then -- 2717
			e.awake = true -- 2720
		else -- 2720
			return -- 2722
		end -- 2722
	end -- 2722
	local target = nil -- 2725
	local bestD = 1000000000 -- 2726
	local i = 0 -- 2727
	do -- 2727
		i = 0 -- 2728
		while i < #self.boxes do -- 2728
			do -- 2728
				local b = self.boxes[i + 1] -- 2729
				if b.breakable == nil or b.broken == true then -- 2729
					goto __continue452 -- 2731
				end -- 2731
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 2733
				if d < bestD then -- 2733
					bestD = d -- 2735
					target = b -- 2736
				end -- 2736
			end -- 2736
			::__continue452:: -- 2736
			i = i + 1 -- 2728
		end -- 2728
	end -- 2728
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 2739
	local dx = tx - e.x -- 2740
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 2741
	if math.abs(dx) > reach then -- 2741
		local before = e.x -- 2743
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 2744
		if math.abs(e.x - before) < 0.3 then -- 2744
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 2746
		end -- 2746
	elseif (e.swingT or 0) <= 0 then -- 2746
		e.swingT = 64 -- 2749
		if target ~= nil then -- 2749
			self:damageProp(target, 2) -- 2751
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 2751
			local ____opt_53 = self.run.trial -- 2751
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_53 and ____opt_53.ranks.guard or 0) -- 2753
			self.craftT = 0 -- 2754
			self.hp = self.hp - 1 -- 2755
			self:emit("actorHit", { -- 2756
				target = "player", -- 2756
				amount = 1, -- 2756
				hp = self.hp, -- 2756
				maxHp = self.maxHp, -- 2756
				enemyX = e.x -- 2756
			}) -- 2756
			self:flashSet("破障手近身", 0.8) -- 2757
			if self.hp <= 0 then -- 2757
				self:campaignFailed() -- 2759
				return -- 2760
			end -- 2760
		end -- 2760
	end -- 2760
	if (e.swingT or 0) > 0 then -- 2760
		e.swingT = (e.swingT or 0) - 1 -- 2765
	end -- 2765
end -- 2716
function Play.prototype.campaignFailed(self) -- 2769
	if self.run.trial ~= nil then -- 2769
		self.run.trial.lost = true -- 2771
		self.wantRoom = "" -- 2772
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2773
		return -- 2774
	end -- 2774
	local p = self.player -- 2776
	self.hp = self.maxHp -- 2777
	self.invulnT = INVULN_RESPAWN_TICKS -- 2778
	self.reloadT = 0 -- 2779
	self:closeReloadPuzzle() -- 2780
	self.gripping = false -- 2781
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 2782
	self:log("被击倒") -- 2783
	p.x = self.room.minX + 90 -- 2784
	p.y = 0 -- 2785
	p.depth = 0 -- 2786
	p.vx = 0 -- 2787
	p.vy = 0 -- 2788
	p.onGround = true -- 2789
	p.rollT = 0 -- 2790
	self.partner.x = p.x - 50 -- 2791
	self.partner.y = 0 -- 2792
	self.partner.depth = 0 -- 2793
	self.cam.x = p.x -- 2794
	local i = 0 -- 2795
	do -- 2795
		i = 0 -- 2796
		while i < #self.enemies do -- 2796
			do -- 2796
				local e = self.enemies[i + 1] -- 2797
				if not e.alive then -- 2797
					goto __continue465 -- 2799
				end -- 2799
				e.x = e.homeX == nil and e.x or e.homeX -- 2801
				e.warnT = 0 -- 2802
				e.fireCd = 40 -- 2803
				e.swingT = 0 -- 2804
				e.awake = false -- 2805
			end -- 2805
			::__continue465:: -- 2805
			i = i + 1 -- 2796
		end -- 2796
	end -- 2796
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 2807
end -- 2769
function Play.prototype.stepEnemies(self, dt, input) -- 2810
	local i = 0 -- 2811
	do -- 2811
		i = 0 -- 2812
		while i < #self.enemies do -- 2812
			local e = self.enemies[i + 1] -- 2813
			if e.hitT > 0 then -- 2813
				e.hitT = e.hitT - dt -- 2815
			end -- 2815
			i = i + 1 -- 2812
		end -- 2812
	end -- 2812
	if self.coveredFlash > 0 then -- 2812
		self.coveredFlash = self.coveredFlash - dt -- 2819
	end -- 2819
	if self.isCampaign then -- 2819
		self:stepCampaignEnemies(dt, input) -- 2822
		return -- 2823
	end -- 2823
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 2823
		return -- 2827
	end -- 2827
	do -- 2827
		i = 0 -- 2829
		while i < #self.enemies do -- 2829
			do -- 2829
				local e = self.enemies[i + 1] -- 2830
				if not e.alive then -- 2830
					goto __continue475 -- 2832
				end -- 2832
				if e.warnT > 0 then -- 2832
					e.warnT = e.warnT - 1 -- 2835
					if e.warnT <= 0 then -- 2835
						self:enemyFire(e, input) -- 2837
					end -- 2837
					goto __continue475 -- 2839
				end -- 2839
				if e.fireCd > 0 then -- 2839
					e.fireCd = e.fireCd - 1 -- 2842
					if e.fireCd <= 0 then -- 2842
						e.warnT = WARN_TICKS -- 2844
					end -- 2844
				else -- 2844
					e.warnT = WARN_TICKS -- 2848
				end -- 2848
			end -- 2848
			::__continue475:: -- 2848
			i = i + 1 -- 2829
		end -- 2829
	end -- 2829
end -- 2810
function Play.prototype.enemyFire(self, e, input) -- 2854
	local p = self.player -- 2855
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 2855
		self:flashSet("枪声响在远处", 0.4) -- 2857
		e.fireCd = FIRE_COOLDOWN -- 2858
		return -- 2859
	end -- 2859
	local cover = self:blockedByCover(e, p) -- 2862
	local hugging = cover ~= nil -- 2863
	self.coverBlocking = hugging -- 2864
	local covered = hugging and input.cover.held -- 2865
	if covered then -- 2865
		self.coveredFlash = 0.5 -- 2867
		self:flashSet("掩体挡下", 0.5) -- 2868
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 2869
		e.fireCd = FIRE_COOLDOWN -- 2874
		return -- 2875
	end -- 2875
	self.hp = self.hp - 1 -- 2877
	self:emit("actorHit", { -- 2878
		target = "player", -- 2878
		amount = 1, -- 2878
		hp = self.hp, -- 2878
		maxHp = self.maxHp, -- 2878
		enemyX = e.x -- 2878
	}) -- 2878
	self:flashSet( -- 2879
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 2879
		0.7 -- 2879
	) -- 2879
	e.fireCd = FIRE_COOLDOWN -- 2880
	if self.hp <= 0 then -- 2880
		self:gateFailed() -- 2882
	end -- 2882
end -- 2854
function Play.prototype.blockedByCover(self, enemy, p) -- 2887
	local b = self:coverAt(p) -- 2888
	if b == nil then -- 2888
		return nil -- 2890
	end -- 2890
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 2892
end -- 2887
function Play.prototype.gateFailed(self) -- 2896
	local ____temp_55 -- 2897
	if self.room.story == nil then -- 2897
		____temp_55 = nil -- 2897
	else -- 2897
		____temp_55 = self.room.story.gate -- 2897
	end -- 2897
	local g = ____temp_55 -- 2897
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 2898
	self.hp = self.maxHp -- 2899
	self.gateTick = 0 -- 2900
	self.gateSpawned = 0 -- 2901
	self.enemies = {} -- 2902
	self.gateFailCount = self.gateFailCount + 1 -- 2903
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 2905
	self.player.y = 0 -- 2906
	self.player.vy = 0 -- 2907
	self.player.depth = 0 -- 2908
	self.player.depthSpeed = 0 -- 2909
	self.player.onGround = true -- 2910
	self.player.crouch = false -- 2911
	self.player.h = SOLDIER_H -- 2912
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 2913
	self.partner.y = 0 -- 2914
	self.partner.vy = 0 -- 2915
	self.partner.depth = 0 -- 2916
	self.partner.depthSpeed = 0 -- 2917
	self.partner.onGround = true -- 2918
	self.cam.x = self.player.x -- 2919
	self.phase = "gate-idle" -- 2920
	self.phaseTick = 0 -- 2921
	self.coverHug = false -- 2922
	self.coverBlocking = false -- 2923
	self.coverEntity = "" -- 2924
	self.gateNeedConfirm = true -- 2925
	self.gateRestartArmed = false -- 2926
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 2927
end -- 2896
function Play.prototype.stepInteract(self, dt, input) -- 2930
	local p = self.player -- 2931
	local calmUsed = self.calmConsumed -- 2932
	self.calmConsumed = false -- 2933
	local calming = self.escort.state == "calming" -- 2935
	self.focusCart = false -- 2936
	if self.room.key == "outside" then -- 2936
		local c = self.room.cart -- 2938
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 2939
		local dy = p.y - c.baseY -- 2940
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 2941
	end -- 2941
	if not calmUsed and not calming then -- 2941
		self:stepCart(dt, input) -- 2945
	end -- 2945
	if calmUsed then -- 2945
		self:flashSet("安抚 · 敲两下", 0.8) -- 2950
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 2950
		if self.knockT > 0 then -- 2950
			self.knocks = self.knocks + 1 -- 2954
		else -- 2954
			self.knocks = 1 -- 2956
		end -- 2956
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 2958
		self.knockT = 1.2 -- 2959
		if self.knocks >= 2 then -- 2959
			self:flashSet("敲两下", 0.8) -- 2961
			self.knocks = 0 -- 2962
		else -- 2962
			self:flashSet("敲一下", 0.5) -- 2964
		end -- 2964
	elseif self.knockT > 0 then -- 2964
		self.knockT = self.knockT - dt -- 2967
		if self.knockT <= 0 then -- 2967
			self.knocks = 0 -- 2969
		end -- 2969
	end -- 2969
	local i = 0 -- 2974
	do -- 2974
		i = 0 -- 2975
		while i < #self.room.marks do -- 2975
			do -- 2975
				local m = self.room.marks[i + 1] -- 2976
				if m.kind ~= 0 then -- 2976
					goto __continue501 -- 2978
				end -- 2978
				local subjects = {self.partner, self.player} -- 2980
				local k = 0 -- 2981
				do -- 2981
					k = 0 -- 2982
					while k < #subjects do -- 2982
						do -- 2982
							local s = subjects[k + 1] -- 2983
							if not s.alive then -- 2983
								goto __continue504 -- 2985
							end -- 2985
							local dx = s.x - m.x -- 2987
							local dy = s.y - m.y -- 2988
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2988
								self.checkpoint = m.x -- 2990
								self.checkpointCartAxle = self.cartAxle -- 2991
								if self.cartDocked then -- 2991
									self:flashSet("检查点 · 车已落窝", 1) -- 2993
								else -- 2993
									self:flashSet("检查点 · 车还没到位", 1) -- 2995
								end -- 2995
							end -- 2995
						end -- 2995
						::__continue504:: -- 2995
						k = k + 1 -- 2982
					end -- 2982
				end -- 2982
			end -- 2982
			::__continue501:: -- 2982
			i = i + 1 -- 2975
		end -- 2975
	end -- 2975
	self:checkCarryGate() -- 3001
end -- 2930
function Play.prototype.stepVillage(self, dt, input) -- 3005
	if self.room.key ~= "village" then -- 3005
		return -- 3007
	end -- 3007
	local p = self.player -- 3009
	local bottle = self.room.bottle -- 3010
	local scav = self.room.scavenger -- 3011
	if not self.hasBottle and bottle ~= nil then -- 3011
		local dx = p.x - bottle.x -- 3015
		local dy = p.y + p.h * 0.5 - bottle.y -- 3016
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3016
			self.hasBottle = true -- 3018
			self:flashSet("拾起瓶子", 0.8) -- 3019
		end -- 3019
	end -- 3019
	if self.hasBottle then -- 3019
		if input.aim.held then -- 3019
			self.aimHold = self.aimHold + dt -- 3026
			if self.aimHold > 1.2 then -- 3026
				self.aimHold = 1.2 -- 3028
			end -- 3028
			local cached = self:bottleEnd() -- 3031
			self.bottleAimX = cached.x -- 3032
			self.bottleAimY = cached.y -- 3033
		elseif input.aim.released then -- 3033
			if self.aimHold < 0.12 then -- 3033
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3037
				self.aimHold = 0 -- 3038
			else -- 3038
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3040
				self:throwBottle(____end.x, ____end.y) -- 3041
				self.aimHold = 0 -- 3042
			end -- 3042
		end -- 3042
	else -- 3042
		self.aimHold = 0 -- 3046
		self.bottleAimX = -1 -- 3047
	end -- 3047
	local fly = self.bottleFly -- 3052
	if fly ~= nil then -- 3052
		fly.t = fly.t + dt -- 3054
		fly.x = fly.x0 + fly.vx * fly.t -- 3055
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3056
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3057
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3057
			self:landBottle(fly) -- 3059
		end -- 3059
	end -- 3059
	if self.bottleLandT > 0 then -- 3059
		self.bottleLandT = self.bottleLandT - dt -- 3063
	end -- 3063
	if scav ~= nil then -- 3063
		self:stepScav(dt, scav) -- 3067
	end -- 3067
	local line = self.room.passLine -- 3070
	if line ~= nil and not self.passed and p.x >= line then -- 3070
		self.passed = true -- 3072
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3073
	end -- 3073
	if self.passed and p.x >= self.ox + 640 then -- 3073
		self:requestRoom("forest", "过第一院出院") -- 3077
		self:flashSet("出院 · 北塔森林", 1.4) -- 3078
	end -- 3078
end -- 3005
function Play.prototype.bottleEnd(self) -- 3083
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3084
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3087
	return {x = aim.x, y = g} -- 3088
end -- 3083
function Play.prototype.throwBottle(self, tx, ty) -- 3092
	local p = self.player -- 3093
	local dir = tx >= p.x and 1 or -1 -- 3095
	p.facing = dir -- 3096
	local x0 = p.x + dir * 10 -- 3097
	local y0 = p.y + p.h * 0.7 -- 3098
	self.bottleTargetX = tx -- 3099
	self.bottleTargetY = ty -- 3100
	self.bottleSurfaceY = ty -- 3101
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3102
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3103
	self.bottleFly = { -- 3104
		x = x0, -- 3104
		y = y0, -- 3104
		x0 = x0, -- 3104
		y0 = y0, -- 3104
		vx = vx, -- 3104
		vy = vy, -- 3104
		t = 0 -- 3104
	} -- 3104
	self.hasBottle = false -- 3105
	self:flashSet("投出", 0.4) -- 3106
	self:emit( -- 3107
		"bottleThrown", -- 3107
		{ -- 3107
			fromX = x0, -- 3108
			fromY = y0, -- 3109
			targetX = tx, -- 3110
			targetY = ty, -- 3111
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3112
		} -- 3112
	) -- 3112
end -- 3092
function Play.prototype.landBottle(self, fly) -- 3117
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3118
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3119
	local s = self.room.scavenger -- 3120
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3121
	self.bottleFly = nil -- 3122
	self.bottleTargetX = -1 -- 3123
	self.bottleTargetY = 0 -- 3124
	self.bottleSurfaceY = -1 -- 3125
	self.bottleLandX = x -- 3126
	self.bottleLandY = y -- 3127
	self.bottleLandT = 0.9 -- 3128
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3129
	self:hearBottle(x) -- 3130
end -- 3117
function Play.prototype.hearBottle(self, x) -- 3134
	local s = self.room.scavenger -- 3135
	if s == nil then -- 3135
		return -- 3137
	end -- 3137
	if math.abs(x - self.scavX) > s.range then -- 3137
		self:flashSet("落地 · 他没听见", 0.6) -- 3140
		return -- 3141
	end -- 3141
	self.scavState = "turn" -- 3143
	self.scavT = s.hearTicks -- 3144
	self.scavTargetX = x -- 3145
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3146
end -- 3134
function Play.prototype.stepScav(self, dt, s) -- 3150
	if self.scavState == "chase" then -- 3150
		return -- 3153
	end -- 3153
	if self.scavState == "turn" then -- 3153
		self.scavT = self.scavT - 1 -- 3156
		if self.scavT <= 0 then -- 3156
			self.scavState = "walk" -- 3158
		end -- 3158
		return -- 3160
	end -- 3160
	if self.scavState == "walk" then -- 3160
		local d = self.scavTargetX - self.scavX -- 3163
		if math.abs(d) < 4 then -- 3163
			self.scavState = "stall" -- 3165
			self.scavT = s.stallTicks -- 3166
			return -- 3167
		end -- 3167
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3169
		return -- 3170
	end -- 3170
	if self.scavState == "stall" then -- 3170
		self.scavT = self.scavT - 1 -- 3173
		if self.scavT <= 0 then -- 3173
			self.scavState = "back" -- 3175
		end -- 3175
		return -- 3177
	end -- 3177
	if self.scavState == "back" then -- 3177
		local home = math.max( -- 3180
			s.x0, -- 3180
			math.min(s.x1, self.scavX) -- 3180
		) -- 3180
		if math.abs(home - self.scavX) < 2 then -- 3180
			self.scavState = "patrol" -- 3182
			return -- 3183
		end -- 3183
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3185
		return -- 3186
	end -- 3186
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3188
	if self.scavX >= s.x1 then -- 3188
		self.scavX = s.x1 -- 3190
		self.scavDir = -1 -- 3191
	elseif self.scavX <= s.x0 then -- 3191
		self.scavX = s.x0 -- 3193
		self.scavDir = 1 -- 3194
	end -- 3194
end -- 3150
function Play.prototype.stepCart(self, dt, input) -- 3202
	local p = self.player -- 3203
	local c = self.room.cart -- 3204
	if self.gripping then -- 3204
		if not input.interact.held then -- 3204
			self.gripping = false -- 3208
			self:flashSet("松开车把", 0.4) -- 3209
			return -- 3210
		end -- 3210
	else -- 3210
		if not input.interact.pressed then -- 3210
			return -- 3214
		end -- 3214
		if not self:cartHandleInReach(p) then -- 3214
			return -- 3217
		end -- 3217
		local track = c.depth or 0 -- 3219
		if self:limitDepth(p, track) ~= track then -- 3219
			return -- 3221
		end -- 3221
		p.depth = track -- 3223
		p.depthSpeed = 0 -- 3224
		self.gripping = true -- 3225
		self:flashSet("握住车把", 0.4) -- 3226
		return -- 3227
	end -- 3227
	if self.cartDocked then -- 3227
		return -- 3231
	end -- 3231
	local dir = input.moveX -- 3233
	if dir == 0 then -- 3233
		return -- 3235
	end -- 3235
	local lo = math.min(c.startX, c.endX) -- 3237
	local hi = math.max(c.startX, c.endX) -- 3238
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3239
	if next < lo then -- 3239
		next = lo -- 3241
	end -- 3241
	if next > hi then -- 3241
		next = hi -- 3244
	end -- 3244
	local delta = next - self.cartAxle -- 3246
	if delta == 0 then -- 3246
		return -- 3248
	end -- 3248
	self.cartAxle = next -- 3250
	p.x = p.x + delta -- 3251
	p.facing = dir > 0 and 1 or -1 -- 3252
	self:slideX(p, 0) -- 3253
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3253
		self.gripping = false -- 3255
		self:flashSet("跟不上了，脱手", 0.6) -- 3256
		return -- 3257
	end -- 3257
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3257
		self.cartDocked = true -- 3260
		self.gripping = false -- 3261
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3262
		self:flashSet("车轮落窝", 1.2) -- 3263
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3263
		self:flashSet("车轮回到起点", 0.5) -- 3265
	end -- 3265
end -- 3202
function Play.prototype.requestRoom(self, key, reason) -- 3273
	if self.wantRoom ~= "" then -- 3273
		return -- 3277
	end -- 3277
	self.wantRoom = key -- 3279
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3280
end -- 3273
function Play.prototype.checkCarryGate(self) -- 3287
	if self.room.key == "checkpoint" then -- 3287
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3287
			self.carryCartAxle = self.cartAxle -- 3290
			self.carryCartDocked = self.cartDocked -- 3291
			self:requestRoom("gate", "检查站出口") -- 3292
			self:flashSet("出检查站 · 城门", 1.2) -- 3293
		end -- 3293
		return -- 3295
	end -- 3295
	if self.room.key == "outside" then -- 3295
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3295
			self.carryCartAxle = self.cartAxle -- 3301
			self.carryCartDocked = self.cartDocked -- 3302
			self:requestRoom("village", "墙根走完") -- 3303
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3304
		end -- 3304
	end -- 3304
end -- 3287
function Play.prototype.aimAt(self, wx, wy) -- 3311
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3312
	self.aimX = s.x -- 3313
	self.aimY = s.y -- 3314
end -- 3311
function Play.prototype.shoot(self, a) -- 3317
	if self.isCampaign and self.reloadT > 0 then -- 3317
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3319
		return -- 3320
	end -- 3320
	local ox = a.x + a.facing * 8 -- 3322
	local muzzleY = a.y + a.h * 0.72 -- 3323
	local oy = muzzleY + a.depth -- 3324
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3326
	local dx = aim.x - ox -- 3329
	local dy = aim.y - oy -- 3330
	local len = math.sqrt(dx * dx + dy * dy) -- 3331
	if len < 0.001 then -- 3331
		dx = a.facing -- 3333
		dy = 0 -- 3334
	else -- 3334
		dx = dx / len -- 3336
		dy = dy / len -- 3337
	end -- 3337
	if dx ~= 0 then -- 3337
		a.facing = dx > 0 and 1 or -1 -- 3340
	end -- 3340
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3343
	local hitEnemy = self:raycastEnemies(ray) -- 3344
	local tEnemy = hitEnemy.t -- 3345
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3346
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3347
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3348
	local tWall = solid.t -- 3349
	local reloadEffect = self:consumeReloadEffect() -- 3351
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 3352
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3353
	self.trace = { -- 3355
		x0 = ox, -- 3355
		y0 = oy, -- 3355
		x1 = ox + dx * t, -- 3355
		y1 = oy + dy * t, -- 3355
		hit = hit -- 3355
	} -- 3355
	self.traceT = 0.12 -- 3356
	self:applyFireDanger(ox) -- 3357
	local killed = false -- 3358
	if hit then -- 3358
		local i = hitEnemy.index -- 3360
		local e = self.enemies[i + 1] -- 3361
		local impactY = oy + dy * tEnemy -- 3362
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3363
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3364
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3364
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3366
			e.hitT = 0.3 -- 3367
			self:flashSet( -- 3368
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3368
				0.8 -- 3368
			) -- 3368
			self:emit("shotResolved", { -- 3369
				hit = true, -- 3370
				enemyIndex = i, -- 3370
				enemyX = e.x, -- 3370
				aimX = aim.x, -- 3370
				aimY = aim.y, -- 3370
				impactX = ox + dx * t, -- 3371
				impactY = oy + dy * t, -- 3371
				shield = true -- 3371
			}) -- 3371
			self:beginReload() -- 3373
			return -- 3374
		end -- 3374
		e.alive = false -- 3376
		e.hitT = 0.4 -- 3377
		killed = true -- 3378
		self:flashSet("命中", 0.6) -- 3379
		self:dropFor(e) -- 3380
		if reloadEffect == "push" then -- 3380
			e.x = e.x + a.facing * 46 -- 3382
			self:emit("reloadApplied", {effect = "push", enemyX = e.x}) -- 3383
		elseif reloadEffect == "echo" then -- 3383
			self:echoToSource(a) -- 3385
			self:emit("reloadApplied", {effect = "echo", enemyX = e.x}) -- 3386
		elseif reloadEffect == "light" then -- 3386
			self:emit("reloadApplied", {effect = "light", enemyX = e.x}) -- 3388
		end -- 3388
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3388
		self:damageProp(solid.box, 1) -- 3391
	else -- 3391
		self:flashSet("打空", 0.35) -- 3393
	end -- 3393
	if self.isCampaign then -- 3393
		self:beginReload() -- 3396
	end -- 3396
	self:emit("shotResolved", { -- 3398
		hit = hit, -- 3399
		enemyIndex = hit and hitEnemy.index or -1, -- 3400
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3401
		aimX = aim.x, -- 3402
		aimY = aim.y, -- 3403
		impactX = ox + dx * t, -- 3404
		impactY = oy + dy * t -- 3405
	}) -- 3405
end -- 3317
function Play.prototype.applyFireDanger(self, shotX) -- 3410
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3410
		return -- 3412
	end -- 3412
	local dangerX = shotX -- 3414
	local best = -1 -- 3415
	local bestD = 1000000000 -- 3416
	local i = 0 -- 3417
	do -- 3417
		i = 0 -- 3418
		while i < #self.enemies do -- 3418
			do -- 3418
				local e = self.enemies[i + 1] -- 3419
				if not e.alive then -- 3419
					goto __continue583 -- 3421
				end -- 3421
				local d = math.abs(e.x - self.partner.x) -- 3423
				if d < bestD then -- 3423
					bestD = d -- 3425
					best = i -- 3426
				end -- 3426
			end -- 3426
			::__continue583:: -- 3426
			i = i + 1 -- 3418
		end -- 3418
	end -- 3418
	if best >= 0 then -- 3418
		dangerX = self.enemies[best + 1].x -- 3430
	end -- 3430
	local exposed = self:childExposed(dangerX) -- 3432
	local before = self.escort.fear -- 3433
	local dangerId = self.nextDangerId -- 3434
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 3435
	self.nextDangerId = self.nextDangerId + 1 -- 3436
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 3437
	if after > before then -- 3437
		self:flashSet( -- 3439
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 3439
			1 -- 3439
		) -- 3439
	elseif not exposed then -- 3439
		self:flashSet("枪声没够到她", 0.5) -- 3441
	end -- 3441
end -- 3410
function Play.prototype.childExposed(self, dangerX) -- 3446
	local c = self.partner -- 3447
	if not c.alive then -- 3447
		return false -- 3449
	end -- 3449
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 3449
		self.boxes, -- 3452
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 3452
	) then -- 3452
		return false -- 3453
	end -- 3453
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 3453
		return false -- 3456
	end -- 3456
	local toDanger = dangerX - c.x -- 3458
	local toPlayer = self.player.x - c.x -- 3459
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 3459
		return false -- 3462
	end -- 3462
	return true -- 3464
end -- 3446
function Play.prototype.raycastEnemies(self, ray) -- 3468
	local best = -1 -- 3469
	local bestI = -1 -- 3470
	do -- 3470
		local i = 0 -- 3471
		while i < #self.enemies do -- 3471
			do -- 3471
				local e = self.enemies[i + 1] -- 3472
				if not e.alive then -- 3472
					goto __continue597 -- 3474
				end -- 3474
				local y = e.y + (e.depth or 0) -- 3476
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 3477
				if t >= 0 and (best < 0 or t < best) then -- 3477
					best = t -- 3479
					bestI = i -- 3480
				end -- 3480
			end -- 3480
			::__continue597:: -- 3480
			i = i + 1 -- 3471
		end -- 3471
	end -- 3471
	return {t = best, index = bestI} -- 3483
end -- 3468
function Play.prototype.raycastWorld(self, ray) -- 3486
	return self:raycastSolid(ray).t -- 3487
end -- 3486
function Play.prototype.raycastSolid(self, ray) -- 3491
	local best = -1 -- 3492
	local bestBox = nil -- 3493
	for ____, box in ipairs(self.boxes) do -- 3494
		do -- 3494
			if box.broken == true or box.hidden == true then -- 3494
				goto __continue602 -- 3496
			end -- 3496
			local t = hitBox(ray, box) -- 3501
			if t > 2 and (best < 0 or t < best) then -- 3501
				best = t -- 3504
				bestBox = box -- 3505
			end -- 3505
		end -- 3505
		::__continue602:: -- 3505
	end -- 3505
	if ray.dy < 0 then -- 3505
		local t = -ray.y / ray.dy -- 3509
		if t >= 0 and (best < 0 or t < best) then -- 3509
			best = t -- 3511
			bestBox = nil -- 3512
		end -- 3512
	end -- 3512
	return {t = best, box = bestBox} -- 3515
end -- 3491
function Play.prototype.dropFor(self, e) -- 3519
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 3519
		return -- 3521
	end -- 3521
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 3521
		return -- 3524
	end -- 3524
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 3526
	local ____self_pickups_56 = self.pickups -- 3526
	____self_pickups_56[#____self_pickups_56 + 1] = { -- 3527
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 3528
		kind = e.drop, -- 3528
		x = e.x, -- 3528
		y = e.y, -- 3528
		depth = e.depth, -- 3529
		label = label .. " ×1" -- 3529
	} -- 3529
	self:log("掉落 " .. label) -- 3531
end -- 3519
function Play.prototype.damageProp(self, b, amount) -- 3535
	if b.breakable == nil or b.broken == true then -- 3535
		return -- 3537
	end -- 3537
	local ____b_breakable_57, ____hp_58 = b.breakable, "hp" -- 3537
	____b_breakable_57[____hp_58] = ____b_breakable_57[____hp_58] - amount -- 3539
	if b.breakable.hp > 0 then -- 3539
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3541
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3542
		return -- 3543
	end -- 3543
	b.broken = true -- 3545
	for ____, other in ipairs(self.boxes) do -- 3546
		if other.id ~= nil and other.id == b.id then -- 3546
			other.broken = true -- 3548
		end -- 3548
	end -- 3548
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3551
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3552
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3553
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3554
end -- 3535
function Play.prototype.slideDepth(self, a, distance) -- 3558
	a.depth = self:limitDepth(a, a.depth + distance) -- 3559
end -- 3558
function Play.prototype.limitDepth(self, a, target) -- 3562
	local road = self.room.depth -- 3563
	if road == nil or target == a.depth then -- 3563
		return a.depth -- 3565
	end -- 3565
	local next = math.max( -- 3567
		road.min, -- 3567
		math.min(road.max, target) -- 3567
	) -- 3567
	local half = a.w / 2 -- 3568
	for ____, b in ipairs(self.boxes) do -- 3569
		do -- 3569
			local footprint = b.depth -- 3570
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3570
				goto __continue620 -- 3575
			end -- 3575
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3577
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3578
			if a.depth <= front and next > front then -- 3578
				next = front -- 3580
			elseif a.depth >= back and next < back then -- 3580
				next = back -- 3582
			end -- 3582
		end -- 3582
		::__continue620:: -- 3582
	end -- 3582
	return next -- 3585
end -- 3562
function Play.prototype.slideX(self, a, dx) -- 3589
	local nx = a.x + dx -- 3590
	local half = a.w / 2 -- 3591
	local room = self.room -- 3592
	nx = math.max( -- 3593
		room.minX + half, -- 3593
		math.min(room.maxX - half, nx) -- 3593
	) -- 3593
	local i = 0 -- 3594
	do -- 3594
		i = 0 -- 3595
		while i < #self.boxes do -- 3595
			do -- 3595
				local b = self.boxes[i + 1] -- 3596
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3596
					goto __continue627 -- 3598
				end -- 3598
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3598
					goto __continue627 -- 3601
				end -- 3601
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3601
					goto __continue627 -- 3604
				end -- 3604
				if nx + half > b.x0 and nx - half < b.x1 then -- 3604
					if a.x <= b.x0 then -- 3604
						nx = b.x0 - half -- 3608
					elseif a.x >= b.x1 then -- 3608
						nx = b.x1 + half -- 3610
					else -- 3610
						nx = a.x -- 3612
					end -- 3612
				end -- 3612
			end -- 3612
			::__continue627:: -- 3612
			i = i + 1 -- 3595
		end -- 3595
	end -- 3595
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 3595
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 3620
		local bx0 = self.cartAxle - CART_HALF -- 3621
		local bx1 = self.cartAxle + CART_HALF -- 3622
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 3622
			if a.x <= bx0 then -- 3622
				nx = bx0 - half -- 3625
			elseif a.x >= bx1 then -- 3625
				nx = bx1 + half -- 3627
			else -- 3627
				nx = a.x -- 3629
			end -- 3629
		end -- 3629
	end -- 3629
	local arch = room.arch -- 3637
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 3637
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 3639
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 3639
			if a.x <= arch.x0 then -- 3639
				nx = arch.x0 - half -- 3642
			elseif a.x >= arch.x1 then -- 3642
				nx = arch.x1 + half -- 3644
			end -- 3644
		end -- 3644
	end -- 3644
	a.x = nx -- 3648
end -- 3589
function Play.prototype.fallY(self, a, dt) -- 3652
	a.vy = a.vy - ____exports.GRAVITY * dt -- 3653
	if a.vy < -900 then -- 3653
		a.vy = -900 -- 3655
	end -- 3655
	local ny = a.y + a.vy * dt -- 3657
	local half = a.w / 2 -- 3658
	if a.vy <= 0 then -- 3658
		local reach = a.onGround and STEP_UP or 0 -- 3661
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 3662
		if ny <= ground then -- 3662
			ny = ground -- 3664
			a.vy = 0 -- 3665
			a.onGround = true -- 3666
		else -- 3666
			a.onGround = false -- 3668
		end -- 3668
	else -- 3668
		a.onGround = false -- 3671
		local i = 0 -- 3672
		do -- 3672
			i = 0 -- 3673
			while i < #self.boxes do -- 3673
				do -- 3673
					local b = self.boxes[i + 1] -- 3674
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 3674
						goto __continue651 -- 3676
					end -- 3676
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 3676
						goto __continue651 -- 3679
					end -- 3679
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 3679
						goto __continue651 -- 3682
					end -- 3682
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 3682
						ny = b.y0 - a.h -- 3685
						a.vy = 0 -- 3686
					end -- 3686
				end -- 3686
				::__continue651:: -- 3686
				i = i + 1 -- 3673
			end -- 3673
		end -- 3673
	end -- 3673
	a.y = ny -- 3690
end -- 3652
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 3694
	if depth == nil then -- 3694
		depth = 0 -- 3694
	end -- 3694
	local g = -9999 -- 3695
	local i = 0 -- 3696
	do -- 3696
		i = 0 -- 3697
		while i < #self.floors do -- 3697
			local f = self.floors[i + 1] -- 3698
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 3698
				g = f.y1 -- 3700
			end -- 3700
			i = i + 1 -- 3697
		end -- 3697
	end -- 3697
	do -- 3697
		i = 0 -- 3703
		while i < #self.boxes do -- 3703
			do -- 3703
				local b = self.boxes[i + 1] -- 3704
				if b.broken == true or b.hidden == true or b.soft == true then -- 3704
					goto __continue661 -- 3706
				end -- 3706
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 3706
					g = b.y1 -- 3710
				end -- 3710
			end -- 3710
			::__continue661:: -- 3710
			i = i + 1 -- 3703
		end -- 3703
	end -- 3703
	return g -- 3713
end -- 3694
function Play.prototype.updateCamera(self, dt) -- 3716
	local p = self.player -- 3717
	local tx = p.x + p.facing * 30 -- 3718
	local ty = p.y + CAM_LOOK_UP -- 3719
	local k = math.min(1, CAM_FOLLOW * dt) -- 3720
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 3721
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 3722
end -- 3716
function Play.prototype.clampCamera(self, w, h) -- 3726
	local room = self.room -- 3727
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 3728
	local spanX = room.maxX - room.minX -- 3729
	if spanX <= halfW * 2 then -- 3729
		self.cam.x = (room.minX + room.maxX) / 2 -- 3731
	else -- 3731
		self.cam.x = math.max( -- 3733
			room.minX + halfW, -- 3733
			math.min(room.maxX - halfW, self.cam.x) -- 3733
		) -- 3733
	end -- 3733
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 3736
	local spanY = room.height -- 3737
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 3738
	if spanY <= halfH * 2 then -- 3738
		self.cam.y = camY -- 3740
	else -- 3740
		self.cam.y = math.max( -- 3742
			camY, -- 3742
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 3742
		) -- 3742
	end -- 3742
end -- 3726
function Play.prototype.flashSet(self, text, t) -- 3746
	self.flash = text -- 3747
	self.flashT = t -- 3748
end -- 3746
function Play.prototype.statusText(self) -- 3752
	local p = self.player -- 3753
	local parts = {} -- 3754
	local who = self.childMode and "小满" or "周戍" -- 3755
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 3756
	if self.room.key == "prologue" then -- 3756
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3759
		if self.phase == "prologue-wait" then -- 3759
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 3761
		elseif self.phase == "prologue-give" then -- 3761
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 3763
		else -- 3763
			parts[#parts + 1] = "跟随" -- 3765
		end -- 3765
		if self.paused then -- 3765
			parts[#parts + 1] = "已暂停" -- 3768
		end -- 3768
		return table.concat(parts, " · ") -- 3770
	end -- 3770
	if self.room.key == "street" then -- 3770
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3773
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3774
		if self.paused then -- 3774
			parts[#parts + 1] = "已暂停" -- 3776
		end -- 3776
		return table.concat(parts, " · ") -- 3778
	end -- 3778
	if self.room.key == "gate" then -- 3778
		local ____temp_59 -- 3781
		if self.room.story == nil then -- 3781
			____temp_59 = nil -- 3781
		else -- 3781
			____temp_59 = self.room.story.gate -- 3781
		end -- 3781
		local g = ____temp_59 -- 3781
		if g ~= nil then -- 3781
			parts[#parts + 1] = self:gateLabel() -- 3783
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 3784
				0, -- 3785
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 3785
			))) .. " 秒" -- 3785
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 3786
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3787
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 3788
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 3789
			if self.gateFailCount > 0 then -- 3789
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 3791
			end -- 3791
			if self.flash ~= "" then -- 3791
				parts[#parts + 1] = self.flash -- 3794
			end -- 3794
		end -- 3794
		if self.paused then -- 3794
			parts[#parts + 1] = "已暂停" -- 3798
		end -- 3798
		return table.concat(parts, " · ") -- 3800
	end -- 3800
	if self.room.key == "forest" then -- 3800
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3803
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 3804
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 3805
		if self.caughtT > 0 then -- 3805
			parts[#parts + 1] = "复位中" -- 3807
		end -- 3807
		if self.paused then -- 3807
			parts[#parts + 1] = "已暂停" -- 3810
		end -- 3810
		return table.concat(parts, " · ") -- 3812
	end -- 3812
	if self.room.key == "tower" then -- 3812
		if self.phase == "tower-wait" then -- 3812
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 3816
		elseif self.phase == "tower-knock" then -- 3816
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 3818
		elseif self.phase == "tower-given" then -- 3818
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 3820
		else -- 3820
			parts[#parts + 1] = "片尾" -- 3822
		end -- 3822
		if self.paused then -- 3822
			parts[#parts + 1] = "已暂停" -- 3825
		end -- 3825
		return table.concat(parts, " · ") -- 3827
	end -- 3827
	if self.room.key == "village" then -- 3827
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3830
		if self.hasBottle then -- 3830
			parts[#parts + 1] = "有瓶" -- 3832
		elseif self.bottleFly ~= nil then -- 3832
			parts[#parts + 1] = "瓶在飞" -- 3834
		else -- 3834
			parts[#parts + 1] = "空手" -- 3836
		end -- 3836
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 3838
		if self.scavChase then -- 3838
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 3840
		end -- 3840
		if self.passed then -- 3840
			parts[#parts + 1] = "已过通行线" -- 3843
		end -- 3843
		if self.paused then -- 3843
			parts[#parts + 1] = "已暂停" -- 3846
		end -- 3846
		return table.concat(parts, " · ") -- 3848
	end -- 3848
	local isChild = self.childMode -- 3851
	if isChild then -- 3851
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 3853
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 3854
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3855
	else -- 3855
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 3857
		if p.rollT > 0 then -- 3857
			parts[#parts + 1] = "翻滚中" -- 3859
		end -- 3859
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 3861
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 3862
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 3863
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 3864
	end -- 3864
	if self.checkpoint >= 0 then -- 3864
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 3867
	end -- 3867
	if self.paused then -- 3867
		parts[#parts + 1] = "已暂停" -- 3870
	end -- 3870
	return table.concat(parts, " · ") -- 3872
end -- 3752
function Play.prototype.aliveEnemies(self) -- 3876
	local n = 0 -- 3877
	local i = 0 -- 3878
	do -- 3878
		i = 0 -- 3879
		while i < #self.enemies do -- 3879
			if self.enemies[i + 1].alive then -- 3879
				n = n + 1 -- 3881
			end -- 3881
			i = i + 1 -- 3879
		end -- 3879
	end -- 3879
	return n -- 3884
end -- 3876
function Play.prototype.threatened(self) -- 3889
	do -- 3889
		local i = 0 -- 3890
		while i < #self.enemies do -- 3890
			local e = self.enemies[i + 1] -- 3891
			if e.alive and e.warnT > 0 then -- 3891
				return true -- 3893
			end -- 3893
			i = i + 1 -- 3890
		end -- 3890
	end -- 3890
	return false -- 3896
end -- 3889
function Play.prototype.gateSecondsLeft(self) -- 3899
	local ____temp_60 -- 3900
	if self.room.story == nil then -- 3900
		____temp_60 = nil -- 3900
	else -- 3900
		____temp_60 = self.room.story.gate -- 3900
	end -- 3900
	local g = ____temp_60 -- 3900
	if g == nil then -- 3900
		return 0 -- 3902
	end -- 3902
	return math.max( -- 3904
		0, -- 3904
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 3904
	) -- 3904
end -- 3899
function Play.prototype.gateLabel(self) -- 3907
	if self.phase == "gate-idle" then -- 3907
		return "待就位" -- 3909
	end -- 3909
	if self.phase == "gate-hold" then -- 3909
		return "守点中" -- 3912
	end -- 3912
	if self.phase == "gate-send" then -- 3912
		return "送别" -- 3915
	end -- 3915
	if self.phase == "gate-count" then -- 3915
		return "数数 " .. tostring(self.countTick) -- 3918
	end -- 3918
	return "她走" -- 3920
end -- 3907
function Play.prototype.dogLabel(self) -- 3924
	if self.dogState == "ear" then -- 3924
		return "转耳" -- 3926
	end -- 3926
	if self.dogState == "chase" then -- 3926
		return "追" -- 3929
	end -- 3929
	if self.dogState == "sniff" then -- 3929
		return "停" -- 3932
	end -- 3932
	if self.dogState == "back" then -- 3932
		return "回线" -- 3935
	end -- 3935
	return "巡逻" -- 3937
end -- 3924
function Play.prototype.doorXOf(self) -- 3940
	local ____temp_61 -- 3941
	if self.room.story == nil then -- 3941
		____temp_61 = nil -- 3941
	else -- 3941
		____temp_61 = self.room.story.tower -- 3941
	end -- 3941
	local t = ____temp_61 -- 3941
	return t == nil and 0 or t.doorX -- 3942
end -- 3940
function Play.prototype.scavLabel(self) -- 3946
	if self.scavState == "chase" then -- 3946
		return "追" -- 3948
	end -- 3948
	if self.scavState == "turn" then -- 3948
		return "转头" -- 3951
	end -- 3951
	if self.scavState == "walk" then -- 3951
		return "赶来" -- 3954
	end -- 3954
	if self.scavState == "stall" then -- 3954
		return "停住" -- 3957
	end -- 3957
	if self.scavState == "back" then -- 3957
		return "回位" -- 3960
	end -- 3960
	return "巡逻" -- 3962
end -- 3946
function Play.prototype.hintText(self) -- 3966
	if self.paused then -- 3966
		return "Esc 继续 · R 重置" -- 3968
	end -- 3968
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 3968
		if self:threatened() then -- 3968
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 3974
		end -- 3974
		if self.coverHug then -- 3974
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 3977
		end -- 3977
		if self.coverNear then -- 3977
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 3980
		end -- 3980
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 3982
	end -- 3982
	if self.flash ~= "" then -- 3982
		return self.flash -- 3985
	end -- 3985
	if self.room.key == "prologue" then -- 3985
		if self.phase == "prologue-wait" then -- 3985
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 3989
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 3990
		end -- 3990
		if self.phase == "prologue-give" then -- 3990
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 3993
		end -- 3993
		return "她跟着你了 · 两人一起走到门口 680" -- 3995
	end -- 3995
	if self.room.key == "street" then -- 3995
		if self:aliveEnemies() > 0 then -- 3995
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 3999
		end -- 3999
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4001
	end -- 4001
	if self.room.key == "gate" then -- 4001
		local ____temp_62 -- 4004
		if self.room.story == nil then -- 4004
			____temp_62 = nil -- 4004
		else -- 4004
			____temp_62 = self.room.story.gate -- 4004
		end -- 4004
		local g = ____temp_62 -- 4004
		if g ~= nil then -- 4004
			if self.phase == "gate-idle" then -- 4004
				if self.gateNeedConfirm then -- 4004
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4008
				end -- 4008
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4010
			end -- 4010
			if self.phase == "gate-hold" then -- 4010
				if self.coveredFlash > 0 then -- 4010
					return "掩体挡下了这一枪 · 别露头" -- 4014
				end -- 4014
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4016
			end -- 4016
			if self.phase == "gate-send" then -- 4016
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4019
			end -- 4019
			if self.phase == "gate-count" then -- 4019
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4019
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4023
				end -- 4023
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4025
			end -- 4025
			return "她自己走 · 跟着出城门 1120" -- 4027
		end -- 4027
	end -- 4027
	if self.room.key == "forest" then -- 4027
		if self.dogState == "chase" then -- 4027
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4032
		end -- 4032
		if self.dogState == "ear" then -- 4032
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4035
		end -- 4035
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4037
	end -- 4037
	if self.room.key == "tower" then -- 4037
		if self.phase == "tower-wait" then -- 4037
			return "走到门前 445 点一次 E 敲两下" -- 4041
		end -- 4041
		if self.phase == "tower-knock" then -- 4041
			return "敲两下 · 等门开" -- 4044
		end -- 4044
		if self.phase == "tower-given" then -- 4044
			return "递交针套和纸条 · 看登记簿最后一行" -- 4047
		end -- 4047
		return "片尾 · 点 E 再玩一次，回到序章" -- 4049
	end -- 4049
	if self.room.key == "village" then -- 4049
		if self.bottleFly ~= nil then -- 4049
			return "等瓶子落地 · 触地才发声" -- 4053
		end -- 4053
		if self.hasBottle then -- 4053
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4056
		end -- 4056
		if self.passed then -- 4056
			return "已过第一院 · R 重置可再来一遍" -- 4059
		end -- 4059
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4061
	end -- 4061
	if self.room.key == "outside" then -- 4061
		if self.focusCart then -- 4061
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4065
		end -- 4065
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4067
	end -- 4067
	if self.escort.state == "frozen" then -- 4067
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4067
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4071
		end -- 4071
		return "小满吓住了 · 走过去，靠近再点 E" -- 4073
	end -- 4073
	if self.escort.state == "calming" then -- 4073
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4076
	end -- 4076
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4078
end -- 3966
function Play.prototype.draw(self, draw, w, h) -- 4083
	self.viewW = w -- 4084
	self.viewH = h -- 4085
	self.view = ____exports.computeViewport(w, h) -- 4086
	self:clampCamera(w, h) -- 4087
	draw:clear() -- 4088
	draw:drawRect( -- 4090
		Rect(0, 0, w, h), -- 4090
		BG_VOID -- 4090
	) -- 4090
	local box = self:canvasRect(w, h) -- 4091
	draw:drawRect(box, BG_FAR) -- 4092
	draw:drawRect( -- 4093
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4093
		BG_MID -- 4093
	) -- 4093
	self:drawFloors(draw, w, h) -- 4095
	self:drawSolids(draw, w, h) -- 4096
	self:drawZones(draw, w, h) -- 4097
	self:drawArch(draw, w, h) -- 4098
	self:drawCart(draw, w, h) -- 4099
	self:drawCampaignProps(draw, w, h) -- 4100
	self:drawActors(draw, w, h) -- 4101
	self:drawTrace(draw, w, h) -- 4102
	self:drawAim(draw, w, h) -- 4103
end -- 4083
function Play.prototype.canvasRect(self, w, h) -- 4107
	local v = self.view -- 4108
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4109
end -- 4107
function Play.prototype.px(self, n) -- 4113
	return n * self.view.zoom -- 4114
end -- 4113
function Play.prototype.sx(self, wx, w) -- 4118
	local v = self.view -- 4119
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4120
	return v.ox + lx * v.zoom -- 4121
end -- 4118
function Play.prototype.sy(self, wy, h) -- 4125
	local v = self.view -- 4126
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4127
	return v.oy + ly * v.zoom -- 4128
end -- 4125
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4131
	local px0 = self:sx(x0, w) -- 4132
	local px1 = self:sx(x1, w) -- 4133
	local py0 = self:sy(y0, h) -- 4134
	local py1 = self:sy(y1, h) -- 4135
	if px1 <= px0 or py1 <= py0 then -- 4135
		return -- 4137
	end -- 4137
	draw:drawRect( -- 4139
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4139
		color -- 4139
	) -- 4139
end -- 4131
function Play.prototype.drawFloors(self, draw, w, h) -- 4142
	local i = 0 -- 4143
	do -- 4143
		i = 0 -- 4144
		while i < #self.room.floors do -- 4144
			local f = self.room.floors[i + 1] -- 4145
			local ____temp_63 -- 4146
			if f.y == 0 then -- 4146
				____temp_63 = self.room.depth -- 4146
			else -- 4146
				____temp_63 = nil -- 4146
			end -- 4146
			local road = ____temp_63 -- 4146
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4147
			local x0 = self:sx(f.x0, w) -- 4148
			local x1 = self:sx(f.x1, w) -- 4149
			local deck = self:px(5) -- 4150
			if road ~= nil then -- 4150
				local back = self:sy(f.y + road.max, h) -- 4152
				draw:drawRect( -- 4153
					Rect(x0, y, x1 - x0, back - y), -- 4153
					FLOOR_DECK, -- 4153
					self:px(1), -- 4153
					SOLID_EDGE -- 4153
				) -- 4153
			end -- 4153
			draw:drawRect( -- 4155
				Rect(x0, y - deck, x1 - x0, deck), -- 4155
				FLOOR_DECK -- 4155
			) -- 4155
			draw:drawSegment( -- 4156
				Vec2(x0, y), -- 4156
				Vec2(x1, y), -- 4156
				self:px(1), -- 4156
				GROUND -- 4156
			) -- 4156
			i = i + 1 -- 4144
		end -- 4144
	end -- 4144
end -- 4142
function Play.prototype.drawSolids(self, draw, w, h) -- 4160
	local i = 0 -- 4161
	do -- 4161
		i = 0 -- 4162
		while i < #self.boxes do -- 4162
			do -- 4162
				local b = self.boxes[i + 1] -- 4163
				if b.id == "braced_shield" or b.hidden == true then -- 4163
					goto __continue782 -- 4165
				end -- 4165
				if b.broken == true then -- 4165
					if b.breakable ~= nil then -- 4165
						local gy = self:sy(b.y0, h) -- 4170
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4171
						local k = 0 -- 4172
						do -- 4172
							k = 0 -- 4173
							while k < 3 do -- 4173
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4174
								draw:drawSegment( -- 4175
									Vec2( -- 4175
										gx - self:px(4), -- 4175
										gy + self:px(k % 2) -- 4175
									), -- 4175
									Vec2( -- 4175
										gx + self:px(5), -- 4175
										gy + self:px(k % 2) -- 4175
									), -- 4175
									self:px(1), -- 4175
									rgb -- 4175
								) -- 4175
								k = k + 1 -- 4173
							end -- 4173
						end -- 4173
					end -- 4173
					goto __continue782 -- 4178
				end -- 4178
				local ____opt_66 = b.depth -- 4178
				local front = ____opt_66 and ____opt_66.min or 0 -- 4180
				local ____opt_68 = b.depth -- 4180
				local back = ____opt_68 and ____opt_68.max or 0 -- 4181
				local fill = SOLID_FILL -- 4182
				local line = SOLID_EDGE -- 4183
				if b.soft == true then -- 4183
					fill = SOFT -- 4185
					line = SOFT_LINE -- 4186
				elseif b.breakable ~= nil then -- 4186
					line = DANGER_LINE -- 4188
					fill = Color(0.3, 0.24, 0.16, 1) -- 4189
				elseif b.interact ~= nil then -- 4189
					line = PASS_LINE -- 4191
				end -- 4191
				self:drawBox( -- 4193
					draw, -- 4193
					w, -- 4193
					h, -- 4193
					b.x0, -- 4193
					b.x1, -- 4193
					b.y0 + front, -- 4193
					b.y1 + back, -- 4193
					fill -- 4193
				) -- 4193
				draw:drawSegment( -- 4194
					Vec2( -- 4194
						self:sx(b.x0, w), -- 4194
						self:sy(b.y1 + front, h) -- 4194
					), -- 4194
					Vec2( -- 4195
						self:sx(b.x1, w), -- 4195
						self:sy(b.y1 + front, h) -- 4195
					), -- 4195
					self:px(1), -- 4195
					line -- 4195
				) -- 4195
				if b.breakable ~= nil then -- 4195
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4198
					local cyp = self:sy(b.y1 + front, h) -- 4199
					draw:drawSegment( -- 4200
						Vec2( -- 4200
							cxp - self:px(4), -- 4200
							cyp + self:px(1) -- 4200
						), -- 4200
						Vec2( -- 4200
							cxp + self:px(3), -- 4200
							cyp + self:px(5) -- 4200
						), -- 4200
						self:px(1), -- 4200
						line -- 4200
					) -- 4200
				end -- 4200
			end -- 4200
			::__continue782:: -- 4200
			i = i + 1 -- 4162
		end -- 4162
	end -- 4162
end -- 4160
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4206
	local i = 0 -- 4207
	do -- 4207
		i = 0 -- 4208
		while i < #self.pickups do -- 4208
			do -- 4208
				local pk = self.pickups[i + 1] -- 4209
				if pk.id == "" then -- 4209
					goto __continue794 -- 4211
				end -- 4211
				local gy = pk.y + (pk.depth or 0) -- 4213
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4214
				draw:drawRect( -- 4215
					Rect( -- 4215
						self:sx(pk.x - 5, w), -- 4215
						self:sy(gy + 12 + bob, h), -- 4215
						self:px(10), -- 4215
						self:px(10) -- 4215
					), -- 4215
					Color(0.84, 0.7, 0.3, 1) -- 4216
				) -- 4216
				draw:drawSegment( -- 4217
					Vec2( -- 4217
						self:sx(pk.x - 5, w), -- 4217
						self:sy(gy + 12 + bob, h) -- 4217
					), -- 4217
					Vec2( -- 4218
						self:sx(pk.x + 5, w), -- 4218
						self:sy(gy + 12 + bob, h) -- 4218
					), -- 4218
					self:px(1), -- 4218
					Color(0.95, 0.86, 0.52, 1) -- 4218
				) -- 4218
			end -- 4218
			::__continue794:: -- 4218
			i = i + 1 -- 4208
		end -- 4208
	end -- 4208
	if self.bracedShield ~= nil then -- 4208
		local sh = self.bracedShield -- 4221
		draw:drawRect( -- 4222
			Rect( -- 4222
				self:sx(sh.x - sh.w / 2, w), -- 4222
				self:sy(sh.y, h), -- 4222
				self:px(sh.w), -- 4222
				self:px(sh.h) -- 4222
			), -- 4222
			Color(0.42, 0.4, 0.34, 1) -- 4223
		) -- 4223
		draw:drawSegment( -- 4224
			Vec2( -- 4224
				self:sx(sh.x - sh.w / 2, w), -- 4224
				self:sy(sh.y + sh.h, h) -- 4224
			), -- 4224
			Vec2( -- 4225
				self:sx(sh.x + sh.w / 2, w), -- 4225
				self:sy(sh.y + sh.h, h) -- 4225
			), -- 4225
			self:px(1), -- 4225
			Color(0.74, 0.72, 0.62, 1) -- 4225
		) -- 4225
	end -- 4225
end -- 4206
function Play.prototype.drawZones(self, draw, w, h) -- 4229
	local i = 0 -- 4230
	do -- 4230
		i = 0 -- 4231
		while i < #self.room.zones do -- 4231
			local z = self.room.zones[i + 1] -- 4232
			local fill = DANGER -- 4233
			local line = DANGER_LINE -- 4234
			if z.tint == 2 then -- 4234
				fill = SOFT -- 4236
				line = SOFT_LINE -- 4237
			elseif z.tint == 3 then -- 4237
				fill = BRICK -- 4239
				line = BRICK_LINE -- 4240
			elseif z.tint == 4 then -- 4240
				fill = PASS -- 4242
				line = PASS_LINE -- 4243
			end -- 4243
			self:drawBox( -- 4245
				draw, -- 4245
				w, -- 4245
				h, -- 4245
				z.x0, -- 4245
				z.x1, -- 4245
				z.y, -- 4245
				z.y + z.h, -- 4245
				fill -- 4245
			) -- 4245
			draw:drawSegment( -- 4246
				Vec2( -- 4246
					self:sx(z.x0, w), -- 4246
					self:sy(z.y, h) -- 4246
				), -- 4246
				Vec2( -- 4246
					self:sx(z.x0, w), -- 4246
					self:sy(z.y + z.h, h) -- 4246
				), -- 4246
				self:px(1), -- 4246
				line -- 4246
			) -- 4246
			draw:drawSegment( -- 4247
				Vec2( -- 4247
					self:sx(z.x1, w), -- 4247
					self:sy(z.y, h) -- 4247
				), -- 4247
				Vec2( -- 4247
					self:sx(z.x1, w), -- 4247
					self:sy(z.y + z.h, h) -- 4247
				), -- 4247
				self:px(1), -- 4247
				line -- 4247
			) -- 4247
			i = i + 1 -- 4231
		end -- 4231
	end -- 4231
end -- 4229
function Play.prototype.drawArch(self, draw, w, h) -- 4251
	local a = self.room.arch -- 4252
	if a.h <= 0 then -- 4252
		return -- 4254
	end -- 4254
	self:drawBox( -- 4256
		draw, -- 4256
		w, -- 4256
		h, -- 4256
		a.x0, -- 4256
		a.x1, -- 4256
		a.y, -- 4256
		a.y + a.h, -- 4256
		HOLE_FILL -- 4256
	) -- 4256
	draw:drawSegment( -- 4257
		Vec2( -- 4257
			self:sx(a.x0, w), -- 4257
			self:sy(a.y + a.h, h) -- 4257
		), -- 4257
		Vec2( -- 4257
			self:sx(a.x1, w), -- 4257
			self:sy(a.y + a.h, h) -- 4257
		), -- 4257
		self:px(1), -- 4257
		SOLID_EDGE -- 4257
	) -- 4257
	draw:drawSegment( -- 4258
		Vec2( -- 4258
			self:sx(a.x0, w), -- 4258
			self:sy(a.y, h) -- 4258
		), -- 4258
		Vec2( -- 4258
			self:sx(a.x0, w), -- 4258
			self:sy(a.y + a.h, h) -- 4258
		), -- 4258
		self:px(1), -- 4258
		SOLID_EDGE -- 4258
	) -- 4258
	draw:drawSegment( -- 4259
		Vec2( -- 4259
			self:sx(a.x1, w), -- 4259
			self:sy(a.y, h) -- 4259
		), -- 4259
		Vec2( -- 4259
			self:sx(a.x1, w), -- 4259
			self:sy(a.y + a.h, h) -- 4259
		), -- 4259
		self:px(1), -- 4259
		SOLID_EDGE -- 4259
	) -- 4259
end -- 4251
function Play.prototype.drawCart(self, draw, w, h) -- 4262
	local c = self.room.cart -- 4263
	if c.bodyW <= 0 then -- 4263
		return -- 4265
	end -- 4265
	drawCartShape( -- 4267
		draw, -- 4267
		self, -- 4267
		w, -- 4267
		h, -- 4267
		c, -- 4267
		self.cartAxle -- 4267
	) -- 4267
	draw:drawRect( -- 4268
		Rect( -- 4268
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4268
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4268
			self:px(2), -- 4268
			self:px(40) -- 4268
		), -- 4268
		STAND -- 4268
	) -- 4268
end -- 4262
function Play.prototype.drawActors(self, draw, w, h) -- 4271
	local p = self.player -- 4272
	local isChild = self.childMode -- 4273
	local footY = p.y + p.depth -- 4274
	if p.covered then -- 4274
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4277
		draw:drawSegment( -- 4278
			Vec2( -- 4278
				self:sx(edge, w), -- 4278
				self:sy(footY + 8, h) -- 4278
			), -- 4278
			Vec2( -- 4278
				self:sx(edge, w), -- 4278
				self:sy(footY + p.h * 0.62, h) -- 4278
			), -- 4278
			self:px(2), -- 4278
			STAND -- 4278
		) -- 4278
		draw:drawSegment( -- 4280
			Vec2( -- 4280
				self:sx(p.x - 8, w), -- 4280
				self:sy(footY + p.h + 3, h) -- 4280
			), -- 4280
			Vec2( -- 4280
				self:sx(p.x + 8, w), -- 4280
				self:sy(footY + p.h + 3, h) -- 4280
			), -- 4280
			self:px(2), -- 4280
			STAND -- 4280
		) -- 4280
	elseif self.coverNear and not isChild then -- 4280
		draw:drawRect( -- 4283
			Rect( -- 4283
				self:sx(p.x - 3, w), -- 4283
				self:sy(footY + 1, h), -- 4283
				self:px(3), -- 4283
				self:px(3) -- 4283
			), -- 4283
			STAND -- 4283
		) -- 4283
	end -- 4283
	drawFigure( -- 4285
		draw, -- 4285
		self, -- 4285
		w, -- 4285
		h, -- 4285
		p, -- 4285
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4285
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4285
	) -- 4285
	local q = self.partner -- 4286
	if q.alive then -- 4286
		local childPartner = q.w == CHILD_W -- 4288
		drawFigure( -- 4289
			draw, -- 4289
			self, -- 4289
			w, -- 4289
			h, -- 4289
			q, -- 4289
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4289
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4289
		) -- 4289
	end -- 4289
	local i = 0 -- 4291
	do -- 4291
		i = 0 -- 4292
		while i < #self.enemies do -- 4292
			local e = self.enemies[i + 1] -- 4293
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4294
			local enemyY = e.y + (e.depth or 0) -- 4295
			self:drawBox( -- 4296
				draw, -- 4296
				w, -- 4296
				h, -- 4296
				e.x - e.w / 2, -- 4296
				e.x + e.w / 2, -- 4296
				enemyY, -- 4296
				enemyY + e.h, -- 4296
				col -- 4296
			) -- 4296
			if e.alive then -- 4296
				local ef = p.x >= e.x and 1 or -1 -- 4298
				if e.kind == "shield" then -- 4298
					local sh = (e.shieldHp or 0) > 0 -- 4300
					draw:drawRect( -- 4301
						Rect( -- 4301
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4301
							self:sy(enemyY, h), -- 4301
							self:px(6), -- 4301
							self:px(64) -- 4301
						), -- 4301
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4302
					) -- 4302
				elseif e.kind == "breaker" then -- 4302
					draw:drawSegment( -- 4304
						Vec2( -- 4304
							self:sx(e.x + ef * 12, w), -- 4304
							self:sy(enemyY + 8, h) -- 4304
						), -- 4304
						Vec2( -- 4305
							self:sx(e.x + ef * 22, w), -- 4305
							self:sy(enemyY + 46, h) -- 4305
						), -- 4305
						self:px(3), -- 4305
						Color(0.5, 0.36, 0.22, 1) -- 4305
					) -- 4305
				end -- 4305
			end -- 4305
			if e.alive and e.warnT > 0 then -- 4305
				local gunX = self:sx(e.x, w) -- 4310
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4311
				local aimX = self:sx(p.x, w) -- 4312
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4313
				local seg = 8 -- 4314
				local s = 0 -- 4315
				do -- 4315
					s = 0 -- 4316
					while s < seg do -- 4316
						local t0 = s / seg -- 4317
						local t1 = (s + 1) / seg -- 4318
						draw:drawSegment( -- 4319
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4320
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4321
							self:px(1), -- 4322
							DANGER -- 4322
						) -- 4322
						s = s + 2 -- 4316
					end -- 4316
				end -- 4316
			end -- 4316
			i = i + 1 -- 4292
		end -- 4292
	end -- 4292
	local k = 0 -- 4327
	do -- 4327
		k = 0 -- 4328
		while k < #self.room.marks do -- 4328
			do -- 4328
				local m = self.room.marks[k + 1] -- 4329
				if m.kind ~= 0 then -- 4329
					goto __continue820 -- 4331
				end -- 4331
				local on = self.checkpoint == m.x -- 4333
				local x = self:sx(m.x, w) -- 4334
				local y = self:sy(m.y, h) -- 4335
				draw:drawSegment( -- 4336
					Vec2(x, y), -- 4336
					Vec2( -- 4336
						x, -- 4336
						y + self:px(35) -- 4336
					), -- 4336
					self:px(1), -- 4336
					on and CHECK or INK_DIM -- 4336
				) -- 4336
				draw:drawDot( -- 4337
					Vec2( -- 4337
						x, -- 4337
						y + self:px(35) -- 4337
					), -- 4337
					self:px(2), -- 4337
					on and CHECK or INK_DIM -- 4337
				) -- 4337
			end -- 4337
			::__continue820:: -- 4337
			k = k + 1 -- 4328
		end -- 4328
	end -- 4328
	local j = 0 -- 4341
	do -- 4341
		j = 0 -- 4342
		while j < #self.room.marks do -- 4342
			do -- 4342
				local m = self.room.marks[j + 1] -- 4343
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4343
					goto __continue823 -- 4345
				end -- 4345
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4345
					goto __continue823 -- 4349
				end -- 4349
				local col = STAND -- 4351
				if m.kind == 4 then -- 4351
					col = PASS_LINE -- 4353
				elseif m.kind == 5 then -- 4353
					col = BRICK_LINE -- 4355
				end -- 4355
				local mx = self:sx(m.x, w) -- 4357
				local my = self:sy(m.y, h) -- 4358
				draw:drawSegment( -- 4359
					Vec2(mx, my), -- 4359
					Vec2( -- 4359
						mx, -- 4359
						my + self:px(24) -- 4359
					), -- 4359
					self:px(1), -- 4359
					col -- 4359
				) -- 4359
			end -- 4359
			::__continue823:: -- 4359
			j = j + 1 -- 4342
		end -- 4342
	end -- 4342
	local t = 0 -- 4362
	do -- 4362
		t = 0 -- 4363
		while t < #self.room.marks do -- 4363
			do -- 4363
				local m = self.room.marks[t + 1] -- 4364
				if m.kind ~= 6 then -- 4364
					goto __continue829 -- 4366
				end -- 4366
				local mx = self:sx(m.x, w) -- 4368
				local my = self:sy(m.y, h) -- 4369
				draw:drawSegment( -- 4370
					Vec2(mx, my), -- 4370
					Vec2( -- 4370
						mx, -- 4370
						my + self:px(30) -- 4370
					), -- 4370
					self:px(1), -- 4370
					INK_DIM -- 4370
				) -- 4370
				self:drawBox( -- 4371
					draw, -- 4371
					w, -- 4371
					h, -- 4371
					m.x - 5, -- 4371
					m.x + 5, -- 4371
					m.y + 30, -- 4371
					m.y + 40, -- 4371
					CHECK -- 4371
				) -- 4371
			end -- 4371
			::__continue829:: -- 4371
			t = t + 1 -- 4363
		end -- 4363
	end -- 4363
	if self.room.key == "village" then -- 4363
		self:drawVillage(draw, w, h) -- 4374
	end -- 4374
	if self.room.key == "forest" then -- 4374
		self:drawDog(draw, w, h) -- 4377
	end -- 4377
end -- 4271
function Play.prototype.drawDog(self, draw, w, h) -- 4382
	local x = self.dogX -- 4383
	self:drawBox( -- 4384
		draw, -- 4384
		w, -- 4384
		h, -- 4384
		x - 14, -- 4384
		x + 14, -- 4384
		0, -- 4384
		20, -- 4384
		SCAV_BODY -- 4384
	) -- 4384
	self:drawBox( -- 4385
		draw, -- 4385
		w, -- 4385
		h, -- 4385
		x - 10, -- 4385
		x - 2, -- 4385
		20, -- 4385
		30, -- 4385
		SCAV_BODY -- 4385
	) -- 4385
	self:drawBox( -- 4386
		draw, -- 4386
		w, -- 4386
		h, -- 4386
		x + 2, -- 4386
		x + 10, -- 4386
		20, -- 4386
		30, -- 4386
		SCAV_HEAD -- 4386
	) -- 4386
	if self.dogState == "ear" or self.dogState == "chase" then -- 4386
		draw:drawSegment( -- 4388
			Vec2( -- 4388
				self:sx(x, w), -- 4388
				self:sy(30, h) -- 4388
			), -- 4388
			Vec2( -- 4389
				self:sx(x, w), -- 4389
				self:sy(40, h) -- 4389
			), -- 4389
			self:px(1), -- 4389
			DANGER -- 4389
		) -- 4389
	end -- 4389
end -- 4382
function Play.prototype.drawVillage(self, draw, w, h) -- 4394
	local bottle = self.room.bottle -- 4395
	if bottle ~= nil then -- 4395
		self:drawBox( -- 4397
			draw, -- 4397
			w, -- 4397
			h, -- 4397
			bottle.x - 14, -- 4397
			bottle.x + 14, -- 4397
			0, -- 4397
			64, -- 4397
			SOLID_FILL -- 4397
		) -- 4397
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4397
			self:drawBottle( -- 4399
				draw, -- 4399
				w, -- 4399
				h, -- 4399
				bottle.x, -- 4399
				64 -- 4399
			) -- 4399
		end -- 4399
	end -- 4399
	self:drawBox( -- 4403
		draw, -- 4403
		w, -- 4403
		h, -- 4403
		300, -- 4403
		420, -- 4403
		44, -- 4403
		50, -- 4403
		FLOOR_DECK -- 4403
	) -- 4403
	self:drawBox( -- 4404
		draw, -- 4404
		w, -- 4404
		h, -- 4404
		300, -- 4404
		306, -- 4404
		0, -- 4404
		44, -- 4404
		FLOOR_DECK -- 4404
	) -- 4404
	self:drawBox( -- 4405
		draw, -- 4405
		w, -- 4405
		h, -- 4405
		414, -- 4405
		420, -- 4405
		0, -- 4405
		44, -- 4405
		FLOOR_DECK -- 4405
	) -- 4405
	local s = self.room.scavenger -- 4407
	if s ~= nil then -- 4407
		local sx0 = self.scavX -- 4409
		self:drawBox( -- 4410
			draw, -- 4410
			w, -- 4410
			h, -- 4410
			sx0 - 12, -- 4410
			sx0 + 12, -- 4410
			0, -- 4410
			s.h - 14, -- 4410
			SCAV_BODY -- 4410
		) -- 4410
		self:drawBox( -- 4411
			draw, -- 4411
			w, -- 4411
			h, -- 4411
			sx0 - 7, -- 4411
			sx0 + 7, -- 4411
			s.h - 14, -- 4411
			s.h, -- 4411
			SCAV_HEAD -- 4411
		) -- 4411
		if self.scavState == "turn" then -- 4411
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4413
			draw:drawSegment( -- 4414
				Vec2( -- 4414
					self:sx(sx0, w), -- 4414
					self:sy(s.h - 6, h) -- 4414
				), -- 4414
				Vec2( -- 4414
					self:sx(fx, w), -- 4414
					self:sy(s.h - 6, h) -- 4414
				), -- 4414
				self:px(1), -- 4414
				INK -- 4414
			) -- 4414
		end -- 4414
	end -- 4414
	if self.hasBottle then -- 4414
		local p = self.player -- 4419
		self:drawBottle( -- 4420
			draw, -- 4420
			w, -- 4420
			h, -- 4420
			p.x + p.facing * 10, -- 4420
			p.y + p.h * 0.62 -- 4420
		) -- 4420
	end -- 4420
	if self.bottleFly ~= nil then -- 4420
		self:drawBottle( -- 4423
			draw, -- 4423
			w, -- 4423
			h, -- 4423
			self.bottleFly.x, -- 4423
			self.bottleFly.y -- 4423
		) -- 4423
	end -- 4423
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 4423
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 4426
		draw:drawCircle( -- 4427
			Vec2( -- 4427
				self:sx(self.bottleLandX, w), -- 4427
				self:sy(0, h) -- 4427
			), -- 4427
			self:px(r / ____exports.UNITS_PER_PX), -- 4427
			BRICK_LINE -- 4427
		) -- 4427
	end -- 4427
end -- 4394
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 4431
	self:drawBox( -- 4432
		draw, -- 4432
		w, -- 4432
		h, -- 4432
		x - 3, -- 4432
		x + 3, -- 4432
		y - 10, -- 4432
		y, -- 4432
		BOTTLE -- 4432
	) -- 4432
end -- 4431
function Play.prototype.drawTrace(self, draw, w, h) -- 4435
	local t = self.trace -- 4436
	if t == nil or self.traceT <= 0 then -- 4436
		return -- 4438
	end -- 4438
	draw:drawSegment( -- 4440
		Vec2( -- 4441
			self:sx(t.x0, w), -- 4441
			self:sy(t.y0, h) -- 4441
		), -- 4441
		Vec2( -- 4442
			self:sx(t.x1, w), -- 4442
			self:sy(t.y1, h) -- 4442
		), -- 4442
		self:px(1), -- 4443
		t.hit and AIM_HIT or INK_DIM -- 4443
	) -- 4443
end -- 4435
function Play.prototype.drawAim(self, draw, w, h) -- 4446
	local v = self.view -- 4448
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 4449
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 4450
	local dot = self:px(1) -- 4451
	local arm = self:px(3) -- 4452
	local gap = self:px(1) -- 4453
	draw:drawSegment( -- 4454
		Vec2(gx - arm - gap, gy), -- 4454
		Vec2(gx - gap, gy), -- 4454
		dot / 2, -- 4454
		AIM -- 4454
	) -- 4454
	draw:drawSegment( -- 4455
		Vec2(gx + gap, gy), -- 4455
		Vec2(gx + arm + gap, gy), -- 4455
		dot / 2, -- 4455
		AIM -- 4455
	) -- 4455
	draw:drawSegment( -- 4456
		Vec2(gx, gy - arm - gap), -- 4456
		Vec2(gx, gy - gap), -- 4456
		dot / 2, -- 4456
		AIM -- 4456
	) -- 4456
	draw:drawSegment( -- 4457
		Vec2(gx, gy + gap), -- 4457
		Vec2(gx, gy + arm + gap), -- 4457
		dot / 2, -- 4457
		AIM -- 4457
	) -- 4457
	if self.room.key == "village" and self.hasBottle then -- 4457
		local p = self.player -- 4461
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4463
		local dir = ____end.x >= p.x and 1 or -1 -- 4464
		local x0 = p.x + dir * 10 -- 4465
		local y0 = p.y + p.h * 0.7 -- 4466
		local T = BOTTLE_FLY_TIME -- 4467
		local vx = (____end.x - x0) / T -- 4468
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 4469
		local pxr = x0 -- 4470
		local pyr = y0 -- 4471
		local t = 1 -- 4472
		do -- 4472
			t = 1 -- 4473
			while t <= 12 do -- 4473
				local tt = t / 12 * T -- 4474
				local nx = x0 + vx * tt -- 4475
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 4476
				draw:drawSegment( -- 4477
					Vec2( -- 4477
						self:sx(pxr, w), -- 4477
						self:sy(pyr, h) -- 4477
					), -- 4477
					Vec2( -- 4477
						self:sx(nx, w), -- 4477
						self:sy(ny, h) -- 4477
					), -- 4477
					self:px(1) / 2, -- 4477
					BOTTLE -- 4477
				) -- 4477
				pxr = nx -- 4478
				pyr = ny -- 4479
				t = t + 1 -- 4473
			end -- 4473
		end -- 4473
		draw:drawCircle( -- 4481
			Vec2( -- 4481
				self:sx(____end.x, w), -- 4481
				self:sy(____end.y + 2, h) -- 4481
			), -- 4481
			self:px(2), -- 4481
			BOTTLE -- 4481
		) -- 4481
	end -- 4481
end -- 4446
return ____exports -- 4446