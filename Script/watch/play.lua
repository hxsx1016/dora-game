-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
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
local createRun = ____run.createRun -- 18
local draftRoom = ____run.draftRoom -- 18
local mmss = ____run.mmss -- 18
local talentNames = ____run.talentNames -- 18
local ____clock = require("Script.watch.clock") -- 21
local STEP = ____clock.STEP -- 21
local ____escort = require("Script.watch.escort") -- 22
local CALM_REACH = ____escort.CALM_REACH -- 22
local Escort = ____escort.Escort -- 22
local FEAR_MAX = ____escort.FEAR_MAX -- 22
local safeAnchorX = ____escort.safeAnchorX -- 22
local ____depth = require("Script.watch.depth") -- 23
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 23
local INTERACT_DEPTH_REACH = ____depth.INTERACT_DEPTH_REACH -- 23
local inReachDepth = ____depth.inReachDepth -- 23
local overlapsDepth = ____depth.overlapsDepth -- 23
local ____reload = require("Script.watch.reload") -- 24
local RELOAD_ANSWER_PER_WORLD = ____reload.RELOAD_ANSWER_PER_WORLD -- 25
local RELOAD_ANSWER_TICKS = ____reload.RELOAD_ANSWER_TICKS -- 25
local RELOAD_START = ____reload.RELOAD_START -- 25
local RELOAD_TARGET = ____reload.RELOAD_TARGET -- 25
local reloadAdjacent = ____reload.reloadAdjacent -- 26
local reloadEffectName = ____reload.reloadEffectName -- 26
local reloadEffectOf = ____reload.reloadEffectOf -- 26
local reloadPathValid = ____reload.reloadPathValid -- 26
local ____craft = require("Script.watch.craft") -- 28
local CRAFT_RECIPES = ____craft.CRAFT_RECIPES -- 29
local findRecipe = ____craft.findRecipe -- 29
local missingMaterials = ____craft.missingMaterials -- 29
local payMaterials = ____craft.payMaterials -- 29
local weaponEffectOf = ____craft.weaponEffectOf -- 29
local weaponNameOf = ____craft.weaponNameOf -- 29
function makeActor(room, index) -- 4902
	local sp = room.spawns -- 4903
	if index < 0 or index >= #sp then -- 4903
		return { -- 4905
			x = 0, -- 4905
			y = 0, -- 4905
			depth = 0, -- 4905
			depthSpeed = 0, -- 4905
			vx = 0, -- 4905
			vy = 0, -- 4905
			w = CHILD_W, -- 4905
			h = CHILD_H, -- 4905
			onGround = true, -- 4905
			facing = 1, -- 4905
			crouch = false, -- 4905
			rollT = 0, -- 4905
			covered = false, -- 4905
			alive = false -- 4905
		} -- 4905
	end -- 4905
	local s = sp[index + 1] -- 4907
	local child = s.h <= CHILD_H -- 4908
	local ground = room.depth -- 4909
	local depth = ground == nil and 0 or math.max( -- 4910
		ground.min, -- 4910
		math.min(ground.max, s.depth or 0) -- 4910
	) -- 4910
	return { -- 4911
		x = s.x, -- 4912
		y = s.y, -- 4912
		depth = depth, -- 4912
		depthSpeed = 0, -- 4912
		vx = 0, -- 4912
		vy = 0, -- 4912
		w = child and CHILD_W or SOLDIER_W, -- 4913
		h = child and CHILD_H or SOLDIER_H, -- 4914
		onGround = true, -- 4915
		facing = 1, -- 4915
		crouch = false, -- 4915
		rollT = 0, -- 4915
		covered = false, -- 4915
		alive = true -- 4915
	} -- 4915
end -- 4915
function drawFigure(draw, play, w, h, a, body, head) -- 4919
	if not a.alive then -- 4919
		return -- 4921
	end -- 4921
	local x0 = a.x - a.w / 2 -- 4923
	local x1 = a.x + a.w / 2 -- 4924
	local y0 = a.y + a.depth -- 4925
	local y1 = y0 + a.h -- 4926
	play:drawBox( -- 4927
		draw, -- 4927
		w, -- 4927
		h, -- 4927
		x0, -- 4927
		x1, -- 4927
		y0, -- 4927
		y1 - a.h * 0.26, -- 4927
		body -- 4927
	) -- 4927
	play:drawBox( -- 4928
		draw, -- 4928
		w, -- 4928
		h, -- 4928
		x0 + 2, -- 4928
		x1 - 2, -- 4928
		y1 - a.h * 0.26, -- 4928
		y1, -- 4928
		head -- 4928
	) -- 4928
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 4930
	play:drawBox( -- 4931
		draw, -- 4931
		w, -- 4931
		h, -- 4931
		eyeX, -- 4931
		eyeX + 4, -- 4931
		y1 - a.h * 0.14, -- 4931
		y1 - a.h * 0.08, -- 4931
		INK -- 4931
	) -- 4931
end -- 4931
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 4935
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 4936
end -- 4935
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 4943
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 4944
end -- 4943
function rayInterval(origin, direction, min, max) -- 4951
	if direction == 0 then -- 4951
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4953
	end -- 4953
	local a = (min - origin) / direction -- 4955
	local b = (max - origin) / direction -- 4956
	return { -- 4957
		min = math.min(a, b), -- 4957
		max = math.max(a, b) -- 4957
	} -- 4957
end -- 4957
function hitBox(ray, box) -- 4961
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4962
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4963
	local enter = math.max(0, x.min, y.min) -- 4964
	local leave = math.min(99999, x.max, y.max) -- 4965
	if box.depth ~= nil then -- 4965
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4967
		enter = math.max(enter, depth.min) -- 4968
		leave = math.min(leave, depth.max) -- 4969
	end -- 4969
	return leave >= enter and enter or -1 -- 4971
end -- 4971
function drawCartShape(draw, play, w, h, c, axleX) -- 4974
	local half = c.bodyW / 2 -- 4975
	local x0 = axleX - half -- 4976
	local x1 = axleX + half -- 4977
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4978
	play:drawBox( -- 4979
		draw, -- 4979
		w, -- 4979
		h, -- 4979
		x0, -- 4979
		x1, -- 4979
		axleY, -- 4979
		axleY + c.bodyH, -- 4979
		CART_FILL -- 4979
	) -- 4979
	draw:drawCircle( -- 4980
		Vec2( -- 4980
			play:sx(x0 + c.bodyW * 0.28, w), -- 4980
			play:sy(axleY, h) -- 4980
		), -- 4980
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4980
		Color(52, 50, 48, 255) -- 4980
	) -- 4980
	draw:drawCircle( -- 4981
		Vec2( -- 4981
			play:sx(x1 - c.bodyW * 0.28, w), -- 4981
			play:sy(axleY, h) -- 4981
		), -- 4981
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4981
		Color(52, 50, 48, 255) -- 4981
	) -- 4981
	local cx = c.clothSide < 0 and x0 or x1 -- 4982
	play:drawBox( -- 4983
		draw, -- 4983
		w, -- 4983
		h, -- 4983
		cx - 10, -- 4983
		cx + 10, -- 4983
		axleY + c.bodyH, -- 4983
		axleY + c.bodyH + 18, -- 4983
		CLOTH -- 4983
	) -- 4983
end -- 4983
____exports.STEP = STEP -- 33
____exports.GRAVITY = 1000 -- 34
____exports.GATE_COUNT_END = 1440 -- 35
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 37
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 39
function ____exports.gateCountAtTick(tick) -- 41
	if tick >= ____exports.GATE_COUNT_END then -- 41
		return 20 -- 42
	end -- 42
	if tick >= 1260 then -- 42
		return 19 -- 43
	end -- 43
	if tick >= 1080 then -- 43
		return 18 -- 44
	end -- 44
	if tick >= 480 then -- 44
		return 11 + math.floor((tick - 480) * 7 / 600) -- 45
	end -- 45
	return 1 + math.floor(math.max(0, tick) / 48) -- 46
end -- 41
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 49
CHILD_W = 28 -- 119
CHILD_H = 64 -- 120
local CHILD_CROUCH_H = 36 -- 121
local CHILD_SPEED = 160 -- 122
local CHILD_SLOW = 80 -- 123
local CHILD_JUMP = 320 -- 124
SOLDIER_W = 30 -- 127
SOLDIER_H = 88 -- 128
local SOLDIER_SPEED = 264 -- 129
local ROLL_TIME = 0.35 -- 130
local ROLL_SPEED = 280 -- 131
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 133
local LEDGE_RISE = 60 -- 134
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 137
____exports.LOGIC_H = 180 -- 138
____exports.UNITS_PER_PX = 2 -- 139
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 141
local CAM_FOLLOW = 9 -- 142
local CAM_LOOK_UP = 46 -- 143
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 146
--- 握把触发半径。
____exports.CART_REACH = 70 -- 148
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 150
local CART_CLEAR = 44 -- 151
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 153
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 155
local CONSUMABLE_CAP = 1 -- 156
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 158
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 160
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 162
local FIRE_COOLDOWN = 150 -- 163
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 165
local ENEMY_RANGE = 760 -- 166
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 168
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 170
local DEPTH_SPEED_RATIO = 0.55 -- 171
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 172
INK = Color(232, 232, 228, 255) -- 174
local INK_DIM = Color(150, 152, 150, 255) -- 175
local BG_VOID = Color(8, 9, 10, 255) -- 176
local BG_FAR = Color(24, 26, 28, 255) -- 177
local BG_MID = Color(31, 34, 37, 255) -- 178
local GROUND = Color(112, 114, 112, 255) -- 179
local FLOOR_DECK = Color(66, 70, 72, 255) -- 180
local SOLID_FILL = Color(84, 86, 84, 255) -- 181
local SOLID_EDGE = Color(126, 130, 126, 255) -- 182
CART_FILL = Color(122, 78, 56, 255) -- 183
CLOTH = Color(178, 52, 46, 255) -- 184
local DANGER = Color(150, 54, 48, 46) -- 185
local DANGER_LINE = Color(178, 78, 64, 200) -- 186
local HOLE_FILL = Color(10, 11, 12, 255) -- 187
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 188
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 189
local CHILD_BODY = Color(214, 168, 96, 255) -- 190
local CHILD_HEAD = Color(232, 214, 186, 255) -- 191
local ENEMY_BODY = Color(176, 92, 84, 255) -- 192
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 193
local CHECK = Color(96, 186, 122, 255) -- 194
local STAND = Color(226, 186, 84, 255) -- 195
local AIM = Color(236, 236, 232, 230) -- 196
local AIM_HIT = Color(236, 96, 84, 255) -- 197
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 199
local SOFT_LINE = Color(140, 112, 80, 190) -- 200
local BRICK = Color(126, 118, 110, 70) -- 201
local BRICK_LINE = Color(160, 152, 142, 200) -- 202
local PASS = Color(96, 186, 122, 40) -- 203
local PASS_LINE = Color(96, 186, 122, 200) -- 204
local BOTTLE = Color(120, 186, 160, 255) -- 205
local SCAV_BODY = Color(128, 118, 96, 255) -- 206
local SCAV_HEAD = Color(196, 182, 158, 255) -- 207
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 294
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 295
	if zoom < 1 then -- 295
		zoom = 1 -- 297
	end -- 297
	return { -- 299
		zoom = zoom, -- 300
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 301
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 302
	} -- 302
end -- 294
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 325
	if key == "prologue" then -- 325
		return "prologue-wait" -- 327
	end -- 327
	if key == "street" then -- 327
		return "street-run" -- 330
	end -- 330
	if key == "gate" then -- 330
		return "gate-idle" -- 333
	end -- 333
	if key == "gatepath" then -- 333
		return "gatepath-start" -- 336
	end -- 336
	if key == "forest" then -- 336
		return "forest-run" -- 339
	end -- 339
	if key == "tower" then -- 339
		return "tower-wait" -- 342
	end -- 342
	return "run" -- 344
end -- 325
____exports.Play = __TS__Class() -- 347
local Play = ____exports.Play -- 347
Play.name = "Play" -- 347
function Play.prototype.____constructor(self, room, resume, run) -- 583
	self.enemies = {} -- 352
	self.boxes = {} -- 353
	self.floors = {} -- 354
	self.checkpoint = -1 -- 356
	self.flash = "" -- 358
	self.flashT = 0 -- 359
	self.traceT = 0 -- 362
	self.focusCart = false -- 364
	self.knocks = 0 -- 366
	self.knockT = 0 -- 367
	self.cartAxle = 0 -- 371
	self.cartDocked = false -- 373
	self.gripping = false -- 375
	self.gateOpen = false -- 377
	self.calmConsumed = false -- 379
	self.craftT = 0 -- 381
	self.nextDangerId = 1 -- 383
	self.wantRoom = "" -- 385
	self.carryCartAxle = -1 -- 387
	self.carryCartDocked = false -- 388
	self.checkpointCartAxle = -1 -- 390
	self.hasBottle = false -- 394
	self.bottleLandX = -1 -- 398
	self.bottleTargetX = -1 -- 399
	self.bottleTargetY = 0 -- 400
	self.bottleLandT = 0 -- 401
	self.aimHold = 0 -- 403
	self.scavX = 0 -- 405
	self.scavDir = 1 -- 406
	self.scavState = "patrol" -- 407
	self.scavT = 0 -- 408
	self.scavTargetX = 0 -- 409
	self.passed = false -- 411
	self.childMode = false -- 415
	self.phase = "" -- 417
	self.phaseTick = 0 -- 419
	self.gateTick = 0 -- 421
	self.countTick = 0 -- 423
	self.countArmed = false -- 425
	self.countPrevMove = 0 -- 427
	self.caughtT = 0 -- 429
	self.hp = 3 -- 431
	self.maxHp = 3 -- 432
	self.invulnT = 0 -- 438
	self.partnerStuck = 0 -- 440
	self.partnerLaneIdx = 0 -- 442
	self.partnerLaneHold = 0 -- 443
	self.coveredFlash = 0 -- 445
	self.coverHug = false -- 447
	self.coverNear = false -- 449
	self.coverEntity = "" -- 451
	self.coverBlocking = false -- 453
	self.gateNeedConfirm = false -- 455
	self.gateRestartArmed = true -- 457
	self.bottleAimX = -1 -- 459
	self.bottleAimY = 0 -- 460
	self.bottleSurfaceY = -1 -- 462
	self.bottleLandY = 0 -- 464
	self.events = {} -- 466
	self.eventSeq = 0 -- 468
	self.dogX = 0 -- 470
	self.dogDir = 1 -- 471
	self.dogState = "patrol" -- 472
	self.dogT = 0 -- 473
	self.dogTargetX = 0 -- 474
	self.scavSee = 0 -- 476
	self.scavChase = false -- 477
	self.gateSpawned = 0 -- 479
	self.gateFailCount = 0 -- 481
	self.isCampaign = false -- 485
	self.equippedWeapon = "standard_gun" -- 495
	self.craftBench = { -- 497
		active = false, -- 498
		firstCraftDone = false, -- 499
		justCraftedTimer = 0, -- 500
		inventory = {}, -- 501
		recipes = {}, -- 502
		equippedWeapon = "standard_gun" -- 503
	} -- 503
	self.handledCraftRequests = {} -- 506
	self.benchReach = 48 -- 508
	self.pickups = {} -- 512
	self.reloadT = 0 -- 514
	self.objectiveDone = false -- 518
	self.hint = "" -- 520
	self.roomStartTick = 0 -- 522
	self.cartHitT = 0 -- 524
	self.cartExposed = false -- 525
	self.storyRoute = "" -- 529
	self.storySettled = false -- 531
	self.hpAtGate = -1 -- 533
	self.maxHpAtGate = -1 -- 534
	self.handTicks = 0 -- 536
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 538
	self.handArmed = false -- 540
	self.handDone = false -- 542
	self.lineSaid = false -- 543
	self.tied = false -- 545
	self.pathDone = false -- 547
	self.carryOn = false -- 549
	self.escortDone = false -- 551
	self.reloadOpen = false -- 555
	self.reloadAnswerTicks = 0 -- 557
	self.reloadWorldTicks = 0 -- 559
	self.reloadPath = {RELOAD_START} -- 561
	self.reloadPendingEffect = "" -- 563
	self.reloadTryCount = 0 -- 565
	self.paused = false -- 567
	self.ticks = 0 -- 569
	self.view = {zoom = 1, ox = 0, oy = 0} -- 571
	self.ox = 0 -- 573
	self.aimX = 0 -- 575
	self.aimY = 0 -- 576
	self.viewW = 0 -- 578
	self.viewH = 0 -- 579
	self.ox = room.originX -- 585
	self.room = withOrigin(room) -- 586
	local wr = self.room -- 587
	self.run = run or createRun() -- 588
	self.inventory = self.run.inventory -- 589
	self.archive = self.run.archive -- 590
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 591
	self.isCampaign = wr.campaign ~= nil -- 592
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 593
	self:buildWorld() -- 594
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 597
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 599
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 600
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 602
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 603
	self.player = makeActor(wr, playerIdx) -- 604
	self.partner = makeActor(wr, partnerIdx) -- 605
	self.phase = phaseOf(wr.key) -- 606
	if wr.story ~= nil then -- 606
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 608
	end -- 608
	self.cam.x = self.player.x -- 610
	self.cam.y = self.player.y + CAM_LOOK_UP -- 611
	self.cartAxle = wr.cart.startX -- 612
	self.escort = __TS__New( -- 613
		Escort, -- 613
		safeAnchorX(wr.marks) -- 613
	) -- 613
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 614
	if self.isCampaign then -- 614
		self:setupCampaign() -- 616
	else -- 616
		self:buildEnemies() -- 618
	end -- 618
	if resume ~= nil and resume.checkpoint > 0 then -- 618
		self.checkpoint = resume.checkpoint -- 622
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 622
			self.cartAxle = self.room.cart.endX -- 624
			self.cartDocked = true -- 625
			self.player.x = self.ox + 380 -- 628
			self.player.y = 0 -- 629
			self.player.vy = 0 -- 630
			self.player.onGround = true -- 631
			self.cam.x = self.player.x -- 632
			self.cam.y = self.player.y + CAM_LOOK_UP -- 633
		end -- 633
	end -- 633
	self:restoreStory() -- 636
end -- 583
function Play.prototype.recipeViews(self) -- 649
	local out = {} -- 650
	local i = 0 -- 651
	do -- 651
		i = 0 -- 652
		while i < #CRAFT_RECIPES do -- 652
			local r = CRAFT_RECIPES[i + 1] -- 653
			local cost = {} -- 654
			if r.cost.wood ~= nil then -- 654
				cost.wood = r.cost.wood -- 656
			end -- 656
			if r.cost.bell ~= nil then -- 656
				cost.bell = r.cost.bell -- 659
			end -- 659
			out[#out + 1] = { -- 661
				id = r.id, -- 662
				name = r.name, -- 663
				desc = r.desc, -- 664
				enhancedEffect = r.enhancedEffect, -- 665
				cost = cost, -- 666
				crafted = self.run.story.craftedWeapon == r.id -- 667
			} -- 667
			i = i + 1 -- 652
		end -- 652
	end -- 652
	return out -- 670
end -- 649
function Play.prototype.syncCraftBench(self) -- 674
	local view = self.craftBench -- 675
	local inv = self.run.inventory -- 676
	view.inventory = { -- 677
		wood = inv.wood, -- 677
		bell = inv.bell, -- 677
		scrap = inv.scrap, -- 677
		wedge = inv.wedge, -- 677
		ammo = inv.ammo -- 677
	} -- 677
	view.recipes = self:recipeViews() -- 678
	view.equippedWeapon = self.equippedWeapon -- 679
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 680
	if view.justCraftedTimer > 0 then -- 680
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 682
	end -- 682
end -- 674
function Play.prototype.openCraftBench(self) -- 687
	if self.room.key ~= "escort3" or self.craftBench.active then -- 687
		return -- 689
	end -- 689
	self.craftBench.active = true -- 691
	self.carryOn = false -- 692
	self.run.story.carry = false -- 693
	self.player.vx = 0 -- 694
	self.player.vy = 0 -- 695
	self.craftBench.justCraftedTimer = 0 -- 696
	self:syncCraftBench() -- 697
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 698
	self:log("开工台") -- 699
	self:emit( -- 700
		"benchOpen", -- 700
		{ -- 700
			recipes = __TS__ArrayMap( -- 701
				self.craftBench.recipes, -- 701
				function(____, r) return r.id end -- 701
			), -- 701
			inventory = self.craftBench.inventory, -- 702
			carry = self.carryOn -- 703
		} -- 703
	) -- 703
end -- 687
function Play.prototype.closeCraftBench(self) -- 708
	if not self.craftBench.active then -- 708
		return -- 710
	end -- 710
	self.craftBench.active = false -- 712
	self.craftBench.justCraftedTimer = 0 -- 713
	self.carryOn = true -- 714
	self.run.story.carry = true -- 715
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 716
	self:log("离站背起") -- 717
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 718
end -- 708
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 725
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 725
		return false -- 727
	end -- 727
	local recipe = findRecipe(recipeId) -- 729
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 729
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 731
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 732
		return false -- 733
	end -- 733
	local missing = missingMaterials(self.run.inventory, recipe) -- 735
	if #missing > 0 then -- 735
		self:flashSet( -- 737
			"缺料 · " .. table.concat(missing, " / "), -- 737
			1.6 -- 737
		) -- 737
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 738
		return false -- 739
	end -- 739
	payMaterials(self.run.inventory, recipe) -- 741
	self.handledCraftRequests[requestId] = true -- 742
	self.run.story.craftedWeapon = recipe.id -- 743
	self.equippedWeapon = recipe.id -- 744
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 745
	self.craftBench.firstCraftDone = true -- 746
	self:syncCraftBench() -- 747
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 748
	self:log("改制 " .. recipe.id) -- 749
	self:emit("benchCraft", { -- 750
		recipeId = recipe.id, -- 751
		weapon = recipe.id, -- 752
		effect = recipe.enhancedEffect, -- 753
		wood = self.run.inventory.wood, -- 754
		bell = self.run.inventory.bell -- 755
	}) -- 755
	return true -- 757
end -- 725
function Play.prototype.equipWeapon(self, weaponId) -- 761
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 761
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 763
		return false -- 764
	end -- 764
	self.equippedWeapon = weaponId -- 766
	self:syncCraftBench() -- 767
	self:flashSet( -- 768
		"已装备 " .. weaponNameOf(weaponId), -- 768
		1 -- 768
	) -- 768
	self:emit("benchEquip", {weapon = weaponId}) -- 769
	return true -- 770
end -- 761
function Play.prototype.submitFeIntent(self, intent) -- 777
	local kind = intent == nil and "" or intent.kind -- 778
	if kind == "reloadTapNode" then -- 778
		local node = intent.node -- 780
		if type(node) == "number" then -- 780
			self:reloadTapNode(node) -- 782
			return true -- 783
		end -- 783
		return false -- 785
	end -- 785
	if kind == "reloadPathCommit" then -- 785
		local path = intent.path -- 788
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 788
			local list = path -- 790
			local i = 0 -- 791
			do -- 791
				i = 0 -- 792
				while i < #list do -- 792
					do -- 792
						if i == 0 and list[i + 1] == RELOAD_START then -- 792
							goto __continue46 -- 794
						end -- 794
						self:reloadTapNode(list[i + 1]) -- 796
					end -- 796
					::__continue46:: -- 796
					i = i + 1 -- 792
				end -- 792
			end -- 792
			return true -- 798
		end -- 798
		return false -- 800
	end -- 800
	if kind == "reloadCancel" then -- 800
		self:closeReloadPuzzle() -- 803
		return true -- 804
	end -- 804
	if kind == "craftSubmit" then -- 804
		local recipeId = intent.recipeId -- 807
		local requestId = intent.requestId -- 808
		if type(recipeId) == "string" and type(requestId) == "string" then -- 808
			return self:craftAtBench(recipeId, requestId) -- 810
		end -- 810
		return false -- 812
	end -- 812
	if kind == "craftEquip" then -- 812
		local weaponId = intent.weaponId -- 815
		if type(weaponId) == "string" then -- 815
			return self:equipWeapon(weaponId) -- 817
		end -- 817
		return false -- 819
	end -- 819
	if kind == "craftClose" then -- 819
		self:closeCraftBench() -- 822
		return true -- 823
	end -- 823
	return false -- 825
end -- 777
function Play.prototype.captureCheckpoint(self, id) -- 829
	local inv = self.run.inventory -- 830
	self.checkpointSnap = { -- 831
		id = id, -- 832
		wood = inv.wood, -- 833
		bell = inv.bell, -- 834
		scrap = inv.scrap, -- 835
		wedge = inv.wedge, -- 836
		ammo = inv.ammo, -- 837
		shield = inv.shield, -- 838
		pass = inv.pass, -- 839
		quickbelt = inv.quickbelt, -- 840
		crafted = self.run.story.craftedWeapon, -- 841
		equipped = self.equippedWeapon, -- 842
		carry = self.carryOn -- 843
	} -- 843
	self.run.story.cp = self.checkpointSnap -- 845
end -- 829
function Play.prototype.applyCheckpointSnap(self, id) -- 849
	local snap = self.run.story.cp -- 850
	if snap == nil or snap.id ~= id then -- 850
		return false -- 852
	end -- 852
	self.checkpointSnap = snap -- 854
	local inv = self.run.inventory -- 855
	inv.wood = snap.wood -- 856
	inv.bell = snap.bell -- 857
	inv.scrap = snap.scrap -- 858
	inv.wedge = snap.wedge -- 859
	inv.ammo = snap.ammo -- 860
	inv.shield = snap.shield -- 861
	inv.pass = snap.pass -- 862
	inv.quickbelt = snap.quickbelt -- 863
	self.run.story.craftedWeapon = snap.crafted -- 864
	self.equippedWeapon = snap.equipped -- 865
	self.carryOn = snap.carry -- 866
	self.run.story.carry = snap.carry -- 867
	self.craftBench.active = false -- 868
	self:syncCraftBench() -- 869
	return true -- 870
end -- 849
function Play.prototype.restoreStory(self) -- 873
	if self.isCampaign and self.run.trial ~= nil then -- 873
		return -- 877
	end -- 877
	local story = self.run.story -- 879
	if story == nil then -- 879
		return -- 881
	end -- 881
	if story.maxHp > 0 then -- 881
		self.maxHp = story.maxHp -- 884
		self.hp = math.max( -- 885
			1, -- 885
			math.min(story.hp, story.maxHp) -- 885
		) -- 885
	end -- 885
	self.storyRoute = story.route -- 887
	self.storySettled = story.settled -- 888
	self.hpAtGate = story.hpAtGate -- 889
	self.maxHpAtGate = story.maxHpAtGate -- 890
	self.handDone = story.handDone -- 891
	self.lineSaid = story.lineSaid -- 892
	self.tied = story.handDone -- 893
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 894
	self.escortDone = story.escortDone -- 895
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 896
	self:syncCraftBench() -- 897
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 897
		self:applyCheckpointSnap(self.checkpoint) -- 900
	end -- 900
	if self.room.key == "tower" and story.route == "soldier" then -- 900
		self.carryOn = false -- 904
		self.run.story.carry = false -- 905
	end -- 905
	if self.room.key ~= "gate" then -- 905
		return -- 908
	end -- 908
	local ____temp_0 -- 910
	if self.room.story == nil then -- 910
		____temp_0 = nil -- 910
	else -- 910
		____temp_0 = self.room.story.gate -- 910
	end -- 910
	local g = ____temp_0 -- 910
	if g == nil then -- 910
		return -- 912
	end -- 912
	if story.phase == "gate-send" then -- 912
		self.phase = "gate-send" -- 916
		self.gateTick = g.holdTicks -- 917
		self.gateSpawned = 4 -- 918
		self.enemies = {} -- 919
		self.player.x = self.ox + g.doorX - 40 -- 920
		self.player.y = 0 -- 921
		self.player.depth = 0 -- 922
		self.player.vx = 0 -- 923
		self.player.vy = 0 -- 924
		self.player.onGround = true -- 925
		self.partner.x = self.ox + g.waitX -- 926
		self.partner.y = 0 -- 927
		self.partner.depth = 0 -- 928
		self.partner.alive = true -- 929
		self.cam.x = self.player.x -- 930
		self.handTicks = 0 -- 931
		self.handArmed = false -- 932
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 933
		return -- 934
	end -- 934
	if not story.settled then -- 934
		return -- 937
	end -- 937
	self.gateTick = g.holdTicks -- 940
	self.gateSpawned = 4 -- 941
	self.enemies = {} -- 942
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 942
		self.phase = story.phase -- 944
		self.countTick = math.max(story.countTick, 0) -- 945
		self:swapToChild(g.doorX + 30) -- 946
		self.countPrevMove = 0 -- 947
		self.countArmed = false -- 948
		return -- 949
	end -- 949
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 949
		self.phase = story.phase -- 952
		self.countTick = ____exports.GATE_COUNT_END -- 953
		self.phaseTick = story.phaseTick -- 954
		self:swapToChild(g.doorX + 30) -- 955
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 956
			0, -- 956
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 956
		) -- 956
		self.handArmed = false -- 957
	end -- 957
end -- 873
function Play.prototype.buildWorld(self) -- 962
	local room = self.room -- 963
	self.boxes = {} -- 964
	self.floors = {} -- 965
	local i = 0 -- 966
	do -- 966
		i = 0 -- 967
		while i < #room.floors do -- 967
			local f = room.floors[i + 1] -- 968
			local ____self_floors_1 = self.floors -- 968
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 969
			i = i + 1 -- 967
		end -- 967
	end -- 967
	do -- 967
		i = 0 -- 971
		while i < #room.solids do -- 971
			local s = room.solids[i + 1] -- 972
			if not s.decorative then -- 972
				local ____self_boxes_13 = self.boxes -- 978
				local ____s_x_4 = s.x -- 979
				local ____temp_5 = s.x + s.w -- 979
				local ____s_y_6 = s.y -- 979
				local ____temp_7 = s.y + s.h -- 979
				local ____temp_2 -- 980
				if room.depth == nil then -- 980
					____temp_2 = nil -- 980
				else -- 980
					____temp_2 = s.depth -- 980
				end -- 980
				local ____temp_8 = s.passable == true -- 981
				local ____s_label_9 = s.label -- 981
				local ____s_id_10 = s.id -- 982
				local ____temp_11 = s.soft == true -- 982
				local ____temp_12 = s.hidden == true -- 982
				local ____temp_3 -- 983
				if s.breakable == nil then -- 983
					____temp_3 = nil -- 983
				else -- 983
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 983
				end -- 983
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 978
					x0 = ____s_x_4, -- 979
					x1 = ____temp_5, -- 979
					y0 = ____s_y_6, -- 979
					y1 = ____temp_7, -- 979
					depth = ____temp_2, -- 980
					passable = ____temp_8, -- 981
					label = ____s_label_9, -- 981
					id = ____s_id_10, -- 982
					soft = ____temp_11, -- 982
					hidden = ____temp_12, -- 982
					breakable = ____temp_3, -- 983
					interact = s.interact -- 984
				} -- 984
			end -- 984
			i = i + 1 -- 971
		end -- 971
	end -- 971
	do -- 971
		i = 0 -- 988
		while i < #room.stairs do -- 988
			local st = room.stairs[i + 1] -- 989
			local n = st.steps + 1 -- 990
			local stepW = (st.x1 - st.x0) / n -- 991
			local k = 0 -- 992
			do -- 992
				k = 0 -- 993
				while k < n do -- 993
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 994
					local x0 = st.x0 + stepW * k -- 995
					local ____self_boxes_14 = self.boxes -- 995
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 997
						x0 = x0, -- 997
						x1 = x0 + stepW, -- 997
						y0 = -8, -- 997
						y1 = y, -- 997
						passable = true -- 997
					} -- 997
					k = k + 1 -- 993
				end -- 993
			end -- 993
			i = i + 1 -- 988
		end -- 988
	end -- 988
end -- 962
function Play.prototype.setupCampaign(self) -- 1006
	local wr = self.room -- 1007
	local c = wr.campaign -- 1008
	if c == nil then -- 1008
		return -- 1010
	end -- 1010
	self.roomStartTick = self.run.ticks -- 1012
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1012
		self.run.joined = true -- 1016
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1016
		local ____self_run_16 = self.run -- 1019
		local ____temp_15 -- 1019
		if wr.key == "s2-drygoods" then -- 1019
			____temp_15 = self.run.route ~= "drygoods" -- 1019
		else -- 1019
			____temp_15 = false -- 1019
		end -- 1019
		____self_run_16.joined = ____temp_15 -- 1019
	end -- 1019
	local x = wr.minX + 60 -- 1021
	local y = 0 -- 1022
	local depth = 0 -- 1023
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1023
		x = wr.minX + 210 -- 1025
		depth = -32 -- 1026
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1026
		x = wr.minX + 40 -- 1028
		y = 32 -- 1029
		depth = 32 -- 1030
	end -- 1030
	self.player = { -- 1032
		x = x, -- 1033
		y = y, -- 1033
		depth = depth, -- 1033
		depthSpeed = 0, -- 1033
		vx = 0, -- 1033
		vy = 0, -- 1033
		w = SOLDIER_W, -- 1034
		h = SOLDIER_H, -- 1034
		onGround = y <= 0, -- 1034
		facing = 1, -- 1034
		crouch = false, -- 1034
		rollT = 0, -- 1034
		covered = false, -- 1034
		alive = true -- 1034
	} -- 1034
	self.partner = { -- 1036
		x = x + 60, -- 1037
		y = y, -- 1037
		depth = depth, -- 1037
		depthSpeed = 0, -- 1037
		vx = 0, -- 1037
		vy = 0, -- 1037
		w = CHILD_W, -- 1038
		h = CHILD_H, -- 1038
		onGround = y <= 0, -- 1038
		facing = 1, -- 1038
		crouch = false, -- 1038
		rollT = 0, -- 1038
		covered = false, -- 1038
		alive = true -- 1038
	} -- 1038
	self.cam.x = x -- 1040
	self.cam.y = y + CAM_LOOK_UP -- 1041
	self.phase = "run" -- 1042
	self.hp = self.maxHp -- 1043
	local trial = self.run.trial -- 1044
	if trial ~= nil then -- 1044
		draftRoom(trial, wr.key) -- 1046
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1047
		self.hp = trial.hp -- 1048
	end -- 1048
	self:buildEnemies() -- 1050
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1051
	local i = 0 -- 1052
	do -- 1052
		i = 0 -- 1053
		while i < #self.boxes do -- 1053
			do -- 1053
				local b = self.boxes[i + 1] -- 1054
				if b.id == nil then -- 1054
					goto __continue87 -- 1056
				end -- 1056
				local st = self.run.props[b.id] -- 1058
				if st ~= nil then -- 1058
					b.broken = st.broken -- 1060
					local ____temp_17 -- 1061
					if b.breakable == nil then -- 1061
						____temp_17 = nil -- 1061
					else -- 1061
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1061
					end -- 1061
					b.breakable = ____temp_17 -- 1061
					b.hidden = b.hidden == true and st.revealed ~= true -- 1062
					if b.hidden then -- 1062
						b.broken = true -- 1064
					end -- 1064
				elseif b.hidden == true then -- 1064
					b.broken = true -- 1068
				end -- 1068
			end -- 1068
			::__continue87:: -- 1068
			i = i + 1 -- 1053
		end -- 1053
	end -- 1053
	if wr.cart.bodyW > 0 then -- 1053
		self.cartAxle = wr.cart.startX -- 1072
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1072
			self.cartAxle = wr.cart.endX -- 1074
			self.cartDocked = true -- 1075
		end -- 1075
	end -- 1075
	do -- 1075
		i = 0 -- 1078
		while i < #self.pickups do -- 1078
			local pk = self.pickups[i + 1] -- 1079
			if self.run.taken[pk.id] == true then -- 1079
				pk.id = "" -- 1081
			end -- 1081
			i = i + 1 -- 1078
		end -- 1078
	end -- 1078
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1084
end -- 1006
function Play.prototype.log(self, line) -- 1087
	local ____self_run_log_18 = self.run.log -- 1087
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1088
	if #self.run.log > 120 then -- 1088
		table.remove(self.run.log, 1) -- 1090
	end -- 1090
end -- 1087
function Play.prototype.buildEnemies(self) -- 1094
	self.enemies = {} -- 1095
	if self.isCampaign then -- 1095
		local i = 0 -- 1097
		do -- 1097
			i = 0 -- 1098
			while i < #self.room.spawns do -- 1098
				local sp = self.room.spawns[i + 1] -- 1099
				local kind = sp.kind or "gunner" -- 1100
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1101
				local ____self_enemies_19 = self.enemies -- 1101
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1102
					x = sp.x, -- 1103
					y = sp.y, -- 1103
					depth = sp.depth, -- 1103
					w = 26, -- 1103
					h = sp.h, -- 1103
					alive = true, -- 1103
					hitT = 0, -- 1103
					warnT = 0, -- 1103
					fireCd = 40, -- 1103
					kind = kind, -- 1104
					shieldHp = hp, -- 1104
					shieldHpMax = hp, -- 1104
					drop = sp.drop or "none", -- 1104
					homeX = sp.x, -- 1105
					swingT = 0, -- 1105
					awake = false, -- 1105
					squad = i -- 1105
				} -- 1105
				i = i + 1 -- 1098
			end -- 1098
		end -- 1098
		return -- 1108
	end -- 1108
	if self.room.key == "checkpoint" then -- 1108
		local ____self_enemies_20 = self.enemies -- 1108
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1111
			x = self.ox + 430, -- 1111
			y = 0, -- 1111
			w = 26, -- 1111
			h = 84, -- 1111
			alive = true, -- 1111
			hitT = 0, -- 1111
			warnT = 0, -- 1111
			fireCd = 0 -- 1111
		} -- 1111
		local ____self_enemies_21 = self.enemies -- 1111
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1112
			x = self.ox + 505, -- 1112
			y = 0, -- 1112
			w = 26, -- 1112
			h = 84, -- 1112
			alive = true, -- 1112
			hitT = 0, -- 1112
			warnT = 0, -- 1112
			fireCd = 0 -- 1112
		} -- 1112
		return -- 1113
	end -- 1113
	if self.room.key == "street" then -- 1113
		local ____self_enemies_22 = self.enemies -- 1113
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1117
			x = self.ox + 340, -- 1117
			y = 0, -- 1117
			w = 26, -- 1117
			h = 84, -- 1117
			alive = true, -- 1117
			hitT = 0, -- 1117
			warnT = 0, -- 1117
			fireCd = 0 -- 1117
		} -- 1117
		local ____self_enemies_23 = self.enemies -- 1117
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1118
			x = self.ox + 560, -- 1118
			y = 0, -- 1118
			w = 26, -- 1118
			h = 84, -- 1118
			alive = true, -- 1118
			hitT = 0, -- 1118
			warnT = 0, -- 1118
			fireCd = 0 -- 1118
		} -- 1118
	end -- 1118
end -- 1094
function Play.prototype.emit(self, name, data) -- 1124
	local ____self_events_24 = self.events -- 1124
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1125
	self.eventSeq = self.eventSeq + 1 -- 1126
	if #self.events > 256 then -- 1126
		table.remove(self.events, 1) -- 1128
	end -- 1128
end -- 1124
function Play.prototype.drainEvents(self) -- 1136
	local out = self.events -- 1137
	self.events = {} -- 1138
	return out -- 1139
end -- 1136
function Play.prototype.adoptEvents(self, events) -- 1148
	if #events == 0 then -- 1148
		return -- 1150
	end -- 1150
	local keep = {} -- 1152
	local i = 0 -- 1153
	do -- 1153
		i = 0 -- 1154
		while i < #events do -- 1154
			do -- 1154
				local e = events[i + 1] -- 1155
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1155
					goto __continue111 -- 1157
				end -- 1157
				keep[#keep + 1] = e -- 1159
			end -- 1159
			::__continue111:: -- 1159
			i = i + 1 -- 1154
		end -- 1154
	end -- 1154
	if #keep == 0 then -- 1154
		return -- 1162
	end -- 1162
	self.events = __TS__ArrayConcat(keep, self.events) -- 1164
	do -- 1164
		i = 0 -- 1165
		while i < #self.events do -- 1165
			self.events[i + 1].seq = i -- 1166
			i = i + 1 -- 1165
		end -- 1165
	end -- 1165
	self.eventSeq = #self.events -- 1168
end -- 1148
function Play.prototype.chooseTalent(self, slot) -- 1171
	local trial = self.run.trial -- 1172
	local talent = trial and trial.offers[slot + 1] -- 1173
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1173
		return -- 1174
	end -- 1174
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1174
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1175
	trial.offers = {} -- 1176
	if talent == "vitality" then -- 1176
		self.maxHp = self.maxHp + 1 -- 1178
		self.hp = self.hp + 1 -- 1179
		trial.hp = self.hp -- 1180
	end -- 1180
	self:flashSet(talentNames[talent], 1.2) -- 1182
end -- 1171
function Play.prototype.beginReload(self) -- 1190
	self.reloadT = self:reloadTicks() -- 1191
	local camp = self.room.campaign -- 1192
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1192
		self:openReloadPuzzle() -- 1195
	end -- 1195
end -- 1190
function Play.prototype.openReloadPuzzle(self) -- 1200
	self.reloadOpen = true -- 1201
	self.reloadAnswerTicks = 0 -- 1202
	self.reloadWorldTicks = 0 -- 1203
	self.reloadPath = {RELOAD_START} -- 1204
	self.reloadPendingEffect = "" -- 1205
	self.reloadTryCount = self.reloadTryCount + 1 -- 1206
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1207
end -- 1200
function Play.prototype.closeReloadPuzzle(self) -- 1211
	self.reloadOpen = false -- 1212
	self.reloadAnswerTicks = 0 -- 1213
	self.reloadWorldTicks = 0 -- 1214
	self.reloadPath = {RELOAD_START} -- 1215
	self.reloadPendingEffect = "" -- 1216
end -- 1211
function Play.prototype.reloadTapNode(self, node) -- 1223
	if not self.reloadOpen then -- 1223
		return -- 1225
	end -- 1225
	local path = self.reloadPath -- 1227
	local last = path[#path] -- 1228
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1228
		self.reloadPath = {RELOAD_START} -- 1230
		self:emit("reloadInvalid", {node = node, at = last}) -- 1231
		return -- 1232
	end -- 1232
	path[#path + 1] = node -- 1234
	if node ~= RELOAD_TARGET then -- 1234
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1236
		return -- 1237
	end -- 1237
	if not reloadPathValid(path) then -- 1237
		self.reloadPath = {RELOAD_START} -- 1240
		self:emit("reloadInvalid", {node = node, at = last}) -- 1241
		return -- 1242
	end -- 1242
	self.reloadPendingEffect = reloadEffectOf(path) -- 1244
	self.reloadOpen = false -- 1245
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1246
	self:flashSet( -- 1249
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1249
		1.4 -- 1249
	) -- 1249
end -- 1223
function Play.prototype.consumeReloadEffect(self) -- 1253
	local e = self.reloadPendingEffect -- 1254
	if e ~= "" then -- 1254
		self.reloadPendingEffect = "" -- 1256
	end -- 1256
	return e -- 1258
end -- 1253
function Play.prototype.echoToSource(self, from, count) -- 1265
	if count == nil then -- 1265
		count = 1 -- 1265
	end -- 1265
	local best = -1 -- 1266
	local bestD = 1000000000 -- 1267
	local i = 0 -- 1268
	local woken = {} -- 1269
	local n = 0 -- 1270
	while n < count do -- 1270
		best = -1 -- 1272
		bestD = 1000000000 -- 1273
		do -- 1273
			i = 0 -- 1274
			while i < #self.enemies do -- 1274
				do -- 1274
					if woken[i] == true then -- 1274
						goto __continue133 -- 1276
					end -- 1276
					local e = self.enemies[i + 1] -- 1278
					if not e.alive then -- 1278
						goto __continue133 -- 1280
					end -- 1280
					local d = math.abs(e.x - from.x) -- 1282
					if d < bestD then -- 1282
						bestD = d -- 1284
						best = i -- 1285
					end -- 1285
				end -- 1285
				::__continue133:: -- 1285
				i = i + 1 -- 1274
			end -- 1274
		end -- 1274
		if best < 0 then -- 1274
			break -- 1289
		end -- 1289
		woken[best] = true -- 1291
		local e = self.enemies[best + 1] -- 1292
		e.awake = true -- 1293
		e.warnT = 0 -- 1294
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1295
		n = n + 1 -- 1296
	end -- 1296
	if n == 0 then -- 1296
		return -- 1299
	end -- 1299
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1301
end -- 1265
function Play.prototype.reloadTicks(self) -- 1304
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1305
	local ____opt_29 = self.run.trial -- 1305
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1305
end -- 1304
function Play.prototype.update(self, dt, input) -- 1308
	self:syncCraftBench() -- 1309
	local trial = self.run.trial -- 1310
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1310
		return -- 1311
	end -- 1311
	if input.pause.pressed then -- 1311
		self.paused = not self.paused -- 1313
	end -- 1313
	if self.flashT > 0 then -- 1313
		self.flashT = self.flashT - dt -- 1316
		if self.flashT <= 0 then -- 1316
			self.flash = "" -- 1318
		end -- 1318
	end -- 1318
	if self.traceT > 0 then -- 1318
		self.traceT = self.traceT - dt -- 1322
		if self.traceT <= 0 then -- 1322
			self.trace = nil -- 1324
		end -- 1324
	end -- 1324
	if self.paused then -- 1324
		self:updateCamera(dt) -- 1328
		return -- 1329
	end -- 1329
	if self.craftBench.active then -- 1329
		self:updateCamera(dt) -- 1333
		return -- 1334
	end -- 1334
	if self.reloadOpen then -- 1334
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1340
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1340
			self.reloadOpen = false -- 1342
			self.reloadPendingEffect = "" -- 1343
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1344
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1345
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1345
			self:updateCamera(dt) -- 1347
			return -- 1348
		else -- 1348
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1350
		end -- 1350
	end -- 1350
	self.ticks = self.ticks + 1 -- 1354
	if self.invulnT > 0 then -- 1354
		self.invulnT = self.invulnT - 1 -- 1358
	end -- 1358
	if self.isCampaign then -- 1358
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1358
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1361
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1362
	end -- 1362
	local p = self.player -- 1364
	self:stepPlayer(p, dt, input) -- 1365
	self:refreshCover(p, input) -- 1367
	if self.carryOn then -- 1367
		self:carryPose() -- 1369
	end -- 1369
	if self.isCampaign then -- 1369
		self:stepCampaign(dt, input) -- 1372
		if not self.carryOn then -- 1372
			self:stepCampaignPartner(dt) -- 1374
		end -- 1374
	end -- 1374
	if trial == nil or not self.run.finished then -- 1374
		self:stepEnemies(dt, input) -- 1382
	end -- 1382
	if trial ~= nil then -- 1382
		trial.hp = self.hp -- 1384
	end -- 1384
	if not self.isCampaign then -- 1384
		self:stepStory(dt, input) -- 1386
		self:stepEscort(dt, input) -- 1387
		self:stepVillage(dt, input) -- 1388
		self:stepChase(dt, input) -- 1389
		self:stepInteract(dt, input) -- 1390
	end -- 1390
	self:updateGate() -- 1392
	self:updateCamera(dt) -- 1393
	self:syncStory() -- 1395
end -- 1308
function Play.prototype.underLowArch(self, a) -- 1402
	local arch = self.room.arch -- 1403
	if arch.h <= 0 then -- 1403
		return false -- 1405
	end -- 1405
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1405
		return false -- 1408
	end -- 1408
	local top = arch.y + arch.h -- 1410
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1411
end -- 1402
function Play.prototype.coverAt(self, a) -- 1418
	local best = nil -- 1419
	local bestGap = 24 -- 1420
	local half = a.w / 2 -- 1421
	local i = 0 -- 1422
	do -- 1422
		i = 0 -- 1423
		while i < #self.boxes do -- 1423
			do -- 1423
				local b = self.boxes[i + 1] -- 1424
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1424
					goto __continue166 -- 1426
				end -- 1426
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1426
					goto __continue166 -- 1429
				end -- 1429
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1431
				if gap < bestGap then -- 1431
					bestGap = gap -- 1433
					best = b -- 1434
				end -- 1434
			end -- 1434
			::__continue166:: -- 1434
			i = i + 1 -- 1423
		end -- 1423
	end -- 1423
	return best -- 1437
end -- 1418
function Play.prototype.nearCover(self, a) -- 1440
	return self:coverAt(a) ~= nil -- 1441
end -- 1440
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1445
	if enemy == nil then -- 1445
		return false -- 1447
	end -- 1447
	local fromRight = enemy.x >= a.x -- 1449
	local edge = fromRight and b.x0 or b.x1 -- 1450
	local ____fromRight_34 -- 1451
	if fromRight then -- 1451
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1451
	else -- 1451
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1452
	end -- 1452
	local between = ____fromRight_34 -- 1451
	local separation = enemy.x - a.x -- 1453
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1454
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1455
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1456
end -- 1445
function Play.prototype.nearestEnemy(self, a) -- 1459
	local best -- 1460
	local bestD = 1000000000 -- 1461
	local i = 0 -- 1462
	do -- 1462
		i = 0 -- 1463
		while i < #self.enemies do -- 1463
			do -- 1463
				local e = self.enemies[i + 1] -- 1464
				if not e.alive then -- 1464
					goto __continue175 -- 1466
				end -- 1466
				local d = math.abs(e.x - a.x) -- 1468
				if d < bestD then -- 1468
					bestD = d -- 1470
					best = e -- 1471
				end -- 1471
			end -- 1471
			::__continue175:: -- 1471
			i = i + 1 -- 1463
		end -- 1463
	end -- 1463
	return best -- 1474
end -- 1459
function Play.prototype.refreshCover(self, a, input) -- 1478
	if self.childMode then -- 1478
		self.coverNear = false -- 1480
		self.coverHug = false -- 1481
		self.coverEntity = "" -- 1482
		self.coverBlocking = false -- 1483
		a.covered = false -- 1484
		return -- 1485
	end -- 1485
	local b = self:coverAt(a) -- 1487
	self.coverNear = b ~= nil -- 1488
	a.covered = self.coverNear and input.cover.held -- 1489
	self.coverHug = a.covered -- 1490
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1491
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1492
		b, -- 1492
		a, -- 1492
		self:nearestEnemy(a) -- 1492
	) -- 1492
end -- 1478
function Play.prototype.cartHandleInReach(self, a) -- 1496
	if a == nil then -- 1496
		a = self.player -- 1496
	end -- 1496
	local c = self.room.cart -- 1497
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1497
		return false -- 1499
	end -- 1499
	local handleX = self.cartAxle + c.handleOffset -- 1501
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1502
end -- 1496
function Play.prototype.nearLowLedge(self, a) -- 1507
	local reach = 26 -- 1508
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1509
	local x1 = x0 + reach -- 1510
	local i = 0 -- 1511
	do -- 1511
		i = 0 -- 1512
		while i < #self.boxes do -- 1512
			do -- 1512
				local b = self.boxes[i + 1] -- 1513
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1513
					goto __continue184 -- 1515
				end -- 1515
				local rise = b.y1 - a.y -- 1517
				if rise > 0 and rise <= LEDGE_RISE then -- 1517
					return true -- 1519
				end -- 1519
			end -- 1519
			::__continue184:: -- 1519
			i = i + 1 -- 1512
		end -- 1512
	end -- 1512
	return false -- 1522
end -- 1507
function Play.prototype.stepPlayer(self, a, dt, input) -- 1525
	a.depthSpeed = 0 -- 1526
	if not a.alive then -- 1526
		return -- 1528
	end -- 1528
	local isChild = self.childMode -- 1530
	local lowArch = isChild and self:underLowArch(a) -- 1532
	if self:storyLocked() then -- 1532
		a.vx = 0 -- 1535
		a.crouch = isChild and lowArch -- 1536
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1537
		self:fallY(a, dt) -- 1538
		return -- 1539
	end -- 1539
	if not isChild and self.escort.state == "calming" then -- 1539
		a.crouch = false -- 1543
		a.h = SOLDIER_H -- 1544
		a.vx = 0 -- 1545
		self:fallY(a, dt) -- 1546
		return -- 1547
	end -- 1547
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1549
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1550
	local nearCover = not isChild and self:nearCover(a) -- 1551
	a.covered = nearCover and input.cover.held -- 1552
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1554
	if a.rollT > 0 then -- 1554
		a.rollT = a.rollT - dt -- 1558
		a.vx = a.facing * ROLL_SPEED -- 1559
		self:slideX(a, a.vx * dt) -- 1560
		self:fallY(a, dt) -- 1561
		if a.rollT <= 0 then -- 1561
			self:flashSet("翻滚结束", 0.5) -- 1563
		end -- 1563
		return -- 1565
	end -- 1565
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1565
		if input.moveX ~= 0 then -- 1565
			a.facing = input.moveX > 0 and 1 or -1 -- 1570
		end -- 1570
		if self:nearLowLedge(a) then -- 1570
			a.vy = SOLDIER_JUMP -- 1574
			a.onGround = false -- 1575
			self:flashSet("翻上去", 0.3) -- 1576
			return -- 1577
		end -- 1577
		a.rollT = ROLL_TIME -- 1579
		self:flashSet("翻滚", 0.3) -- 1580
		return -- 1581
	end -- 1581
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1584
	if isChild then -- 1584
		if input.cover.held then -- 1584
			speed = CHILD_SLOW -- 1587
		end -- 1587
		if a.crouch then -- 1587
			speed = CHILD_SLOW -- 1590
		end -- 1590
	elseif a.covered then -- 1590
		speed = SOLDIER_SPEED * 0.45 -- 1593
	end -- 1593
	local handsBusy = self.gripping or gripIntent -- 1597
	local dir = self.gripping and 0 or input.moveX -- 1598
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1599
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1600
	if dir ~= 0 then -- 1600
		a.facing = dir > 0 and 1 or -1 -- 1602
	end -- 1602
	a.vx = dir * speed * diagonal -- 1604
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1604
		a.vy = CHILD_JUMP -- 1608
		a.onGround = false -- 1609
		self:flashSet("跳", 0.25) -- 1610
	end -- 1610
	local previousDepth = a.depth -- 1614
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1615
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1616
	self:slideX(a, a.vx * dt) -- 1617
	self:fallY(a, dt) -- 1618
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1618
		self:shoot(a) -- 1622
	end -- 1622
end -- 1525
function Play.prototype.stepPartner(self, p, dt) -- 1627
	local a = self.partner -- 1628
	if not a.alive then -- 1628
		return -- 1630
	end -- 1630
	a.crouch = false -- 1632
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1633
	a.vx = 0 -- 1634
	a.depthSpeed = 0 -- 1635
	self:fallY(a, dt) -- 1636
end -- 1627
function Play.prototype.stepEscort(self, dt, input) -- 1643
	local a = self.partner -- 1644
	a.depthSpeed = 0 -- 1645
	if not a.alive then -- 1645
		return -- 1647
	end -- 1647
	if self.room.key == "gatepath" then -- 1647
		if self.carryOn then -- 1647
			return -- 1652
		end -- 1652
		local p = self.player -- 1655
		a.depth = p.depth -- 1656
		a.facing = p.facing -- 1657
		a.crouch = false -- 1658
		a.h = CHILD_H -- 1659
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1660
		a.y = p.y -- 1661
		a.vy = 0 -- 1662
		a.vx = p.vx -- 1663
		a.onGround = p.onGround -- 1664
		return -- 1665
	end -- 1665
	if not self:escortOn() then -- 1665
		a.vx = 0 -- 1668
		self:fallY(a, dt) -- 1669
		return -- 1670
	end -- 1670
	local p = self.player -- 1672
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1673
	local hadKnock1 = self.escort.knock1 -- 1674
	local hadKnock2 = self.escort.knock2 -- 1675
	self.calmConsumed = self.escort:update( -- 1676
		input, -- 1676
		p.x, -- 1676
		p.facing, -- 1676
		a.x, -- 1676
		dist -- 1676
	) -- 1676
	if not hadKnock1 and self.escort.knock1 then -- 1676
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1679
	end -- 1679
	if not hadKnock2 and self.escort.knock2 then -- 1679
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1682
	end -- 1682
	a.crouch = self.escort.crouchPose -- 1684
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1685
	if not self.escort.stopped then -- 1685
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1687
		local previousDepth = a.depth -- 1688
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1689
		local distance = math.max( -- 1690
			-travel, -- 1690
			math.min(travel, targetDepth - previousDepth) -- 1690
		) -- 1690
		self:slideDepth(a, distance) -- 1691
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1692
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1692
			a.vy = CHILD_JUMP -- 1694
			a.onGround = false -- 1695
		end -- 1695
	end -- 1695
	local dir = self.escort:moveDir(a.x) -- 1698
	a.vx = dir * CHILD_SPEED -- 1699
	if dir ~= 0 then -- 1699
		a.facing = dir -- 1701
		local before = a.x -- 1702
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1703
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1703
			a.vy = CHILD_JUMP -- 1706
			a.onGround = false -- 1707
		end -- 1707
	end -- 1707
	self:fallY(a, dt) -- 1710
end -- 1643
function Play.prototype.escortOn(self) -- 1714
	if self.room.key == "checkpoint" then -- 1714
		return true -- 1716
	end -- 1716
	if self.room.key == "gatepath" then -- 1716
		return true -- 1719
	end -- 1719
	if self.room.key == "prologue" then -- 1719
		return self.phase == "prologue-follow" -- 1722
	end -- 1722
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1722
		return true -- 1726
	end -- 1726
	return self.room.key == "street" -- 1728
end -- 1714
function Play.prototype.storyLocked(self) -- 1732
	if self.caughtT > 0 then -- 1732
		return true -- 1734
	end -- 1734
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1734
		return true -- 1737
	end -- 1737
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1737
		return true -- 1740
	end -- 1740
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1740
		return true -- 1743
	end -- 1743
	if self.craftBench.active then -- 1743
		return true -- 1747
	end -- 1747
	return false -- 1749
end -- 1732
function Play.prototype.swapToChild(self, x) -- 1753
	local tmp = self.player -- 1754
	self.player = self.partner -- 1755
	self.partner = tmp -- 1756
	self.childMode = true -- 1757
	self.player.alive = true -- 1758
	self.player.x = self.ox + x -- 1759
	self.player.y = 0 -- 1760
	self.player.depth = 0 -- 1761
	self.player.depthSpeed = 0 -- 1762
	self.player.vy = 0 -- 1763
	self.player.vx = 0 -- 1764
	self.player.onGround = true -- 1765
	self.player.crouch = false -- 1766
	self.player.h = CHILD_H -- 1767
	self.player.facing = 1 -- 1768
	self.partner.alive = true -- 1769
	self.cam.x = self.player.x -- 1770
end -- 1753
function Play.prototype.stepStory(self, dt, input) -- 1774
	if self.room.key == "prologue" then -- 1774
		self:stepPrologue(dt, input) -- 1776
	elseif self.room.key == "street" then -- 1776
		self:stepStreet(dt, input) -- 1778
	elseif self.room.key == "gate" then -- 1778
		self:stepGate(dt, input) -- 1780
	elseif self.room.key == "gatepath" then -- 1780
		self:stepGatePath() -- 1782
	elseif self.room.key == "tower" then -- 1782
		self:stepTower(dt, input) -- 1784
	end -- 1784
end -- 1774
function Play.prototype.stepPrologue(self, dt, input) -- 1789
	local child = self.partner -- 1790
	if self.phase == "prologue-wait" then -- 1790
		child.crouch = true -- 1792
		child.h = CHILD_CROUCH_H -- 1793
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1794
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1796
		if near and input.interact.pressed then -- 1796
			self.phase = "prologue-give" -- 1798
			self.phaseTick = 0 -- 1799
			self:flashSet("递出针套", 1) -- 1800
		end -- 1800
		return -- 1802
	end -- 1802
	if self.phase == "prologue-give" then -- 1802
		self.phaseTick = self.phaseTick + 1 -- 1805
		if self.phaseTick == 12 then -- 1805
			self:flashSet("针套递过去", 0.7) -- 1807
		elseif self.phaseTick == 36 then -- 1807
			self:flashSet("纸条塞进针套", 0.9) -- 1809
		elseif self.phaseTick >= 60 then -- 1809
			self.phase = "prologue-follow" -- 1811
			self.phaseTick = 0 -- 1812
			child.crouch = false -- 1813
			child.h = CHILD_H -- 1814
			self:flashSet("她跟上了", 1.2) -- 1815
		end -- 1815
		return -- 1817
	end -- 1817
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1817
		self:requestRoom("street", "序章跟到门口") -- 1821
		self:flashSet("进街道", 1.2) -- 1822
	end -- 1822
end -- 1789
function Play.prototype.stepStreet(self, dt, input) -- 1827
	local p = self.player -- 1828
	local c = self.partner -- 1829
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1829
		self:requestRoom("checkpoint", "两人都到街尾") -- 1831
		self:flashSet("到检查站", 1.2) -- 1832
	end -- 1832
end -- 1827
function Play.prototype.stepGate(self, dt, input) -- 1837
	local ____temp_35 -- 1838
	if self.room.story == nil then -- 1838
		____temp_35 = nil -- 1838
	else -- 1838
		____temp_35 = self.room.story.gate -- 1838
	end -- 1838
	local g = ____temp_35 -- 1838
	if g == nil then -- 1838
		return -- 1840
	end -- 1840
	local p = self.player -- 1842
	if self.phase == "gate-idle" then -- 1842
		local a = self.partner -- 1845
		local gap = g.waitX - a.x -- 1846
		if math.abs(gap) > 3 then -- 1846
			a.facing = gap > 0 and 1 or -1 -- 1848
			a.vx = a.facing * CHILD_SPEED -- 1849
			local beforeX = a.x -- 1850
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1851
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1851
				a.vy = CHILD_JUMP -- 1853
				a.onGround = false -- 1854
			end -- 1854
			self:fallY(a, dt) -- 1856
		else -- 1856
			a.vx = 0 -- 1858
			a.x = g.waitX -- 1859
		end -- 1859
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1862
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1863
		if self.gateNeedConfirm then -- 1863
			if not input.interact.held then -- 1863
				self.gateRestartArmed = true -- 1868
			end -- 1868
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1868
				self.gateNeedConfirm = false -- 1871
				self.gateRestartArmed = true -- 1872
				self.phase = "gate-hold" -- 1873
				self.gateTick = 0 -- 1874
				self.gateSpawned = 0 -- 1875
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1876
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1877
			end -- 1877
			return -- 1879
		end -- 1879
		if atWinch and atWait then -- 1879
			self.phase = "gate-hold" -- 1882
			self.gateTick = 0 -- 1883
			self.gateSpawned = 0 -- 1884
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1885
		end -- 1885
		return -- 1887
	end -- 1887
	if self.phase == "gate-hold" then -- 1887
		self.gateTick = self.gateTick + 1 -- 1890
		local marks = {0, 540, 900, 1500} -- 1892
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1892
			local idx = self.gateSpawned -- 1894
			local ____self_enemies_36 = self.enemies -- 1894
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 1895
				x = self.ox + 620 + idx * 62, -- 1896
				y = 0, -- 1896
				w = 26, -- 1896
				h = 84, -- 1896
				alive = true, -- 1897
				hitT = 0, -- 1897
				warnT = 0, -- 1897
				fireCd = 90 + idx * 45 -- 1897
			} -- 1897
			self.gateSpawned = self.gateSpawned + 1 -- 1899
			self:flashSet( -- 1900
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1900
				0.9 -- 1900
			) -- 1900
		end -- 1900
		if self.gateTick == 900 then -- 1900
			self:flashSet("灯灭了", 1) -- 1903
		elseif self.gateTick == 2100 then -- 1903
			self:flashSet("门底压下来了", 1) -- 1905
		end -- 1905
		if self.gateTick >= g.holdTicks then -- 1905
			self:captureGateBlood() -- 1910
			self.phase = "gate-send" -- 1911
			self.phaseTick = 0 -- 1912
			self.enemies = {} -- 1914
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1915
		end -- 1915
		return -- 1917
	end -- 1917
	if self.phase == "gate-send" then -- 1917
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1920
		if near and input.interact.pressed then -- 1920
			self:commitRoute() -- 1923
			self:swapToChild(g.doorX + 30) -- 1924
			self.phase = "gate-count" -- 1925
			self.countTick = 0 -- 1926
			self.countArmed = false -- 1928
			self.countPrevMove = input.moveX -- 1929
			self:flashSet("门开了 · 送她出去", 1.8) -- 1930
		end -- 1930
		return -- 1932
	end -- 1932
	if self.phase == "gate-count" then -- 1932
		self.countTick = self.countTick + 1 -- 1935
		if self.countTick == 360 then -- 1935
			self:flashSet("门关上", 0.9) -- 1937
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 1937
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 1939
			if self.storyRoute == "soldier" then -- 1939
				self.phase = "gate-wait" -- 1945
				self.phaseTick = 0 -- 1946
				self.knocks = 1 -- 1947
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 1948
				self.handArmed = not input.interact.held -- 1950
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 1951
			else -- 1951
				self:flashSet("数到二十", 2.2) -- 1953
			end -- 1953
		end -- 1953
		local prevMove = self.countPrevMove -- 1958
		self.countPrevMove = input.moveX -- 1959
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 1959
			if prevMove <= 0 and input.moveX > 0 then -- 1959
				self.countArmed = true -- 1962
			end -- 1962
			if self.countArmed and input.moveX > 0 then -- 1962
				self.phase = "gate-walk" -- 1965
				self.phaseTick = 0 -- 1966
				self:flashSet("她迈出第一步", 1.4) -- 1967
				self:emit("storyExit", { -- 1968
					route = "child", -- 1968
					via = "walk", -- 1968
					countTick = self.countTick, -- 1968
					hp = self.hp, -- 1968
					maxHp = self.maxHp -- 1968
				}) -- 1968
			end -- 1968
		end -- 1968
		return -- 1971
	end -- 1971
	if self.phase == "gate-wait" then -- 1971
		self.phaseTick = self.phaseTick + 1 -- 1975
		if self.phaseTick == 12 then -- 1975
			self.knocks = 2 -- 1977
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 1978
			self:flashSet("第二下 · 她抬手了", 1.6) -- 1979
		end -- 1979
		if not input.interact.held then -- 1979
			if self.handTicks > 0 then -- 1979
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1983
			end -- 1983
			self.handTicks = 0 -- 1985
			self.handArmed = true -- 1986
			return -- 1987
		end -- 1987
		if self.handArmed then -- 1987
			self.handTicks = self.handTicks + 1 -- 1990
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 1990
				self.phase = "gate-hand" -- 1992
				self.phaseTick = 0 -- 1993
				self.handDone = true -- 1994
				self.tied = true -- 1995
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1996
				if not self.lineSaid then -- 1996
					self.lineSaid = true -- 1998
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 1999
				end -- 1999
				self:flashSet("我们走吧。", 3) -- 2001
			end -- 2001
		end -- 2001
		return -- 2004
	end -- 2004
	if self.phase == "gate-hand" then -- 2004
		self.phaseTick = self.phaseTick + 1 -- 2008
		if self.phaseTick == 30 then -- 2008
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2010
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2010
			self:emit("storyExit", { -- 2012
				route = "soldier", -- 2012
				via = "hand", -- 2012
				handTicks = self.handTicks, -- 2012
				hp = self.hp, -- 2012
				maxHp = self.maxHp -- 2012
			}) -- 2012
			self:requestRoom("gatepath", "牵手同行") -- 2013
		end -- 2013
		return -- 2015
	end -- 2015
	if self.phase == "gate-walk" then -- 2015
		if self.player.x >= g.exitX then -- 2015
			self:requestRoom("outside", "走出城门") -- 2020
			self:flashSet("出城门 · 城外", 1.4) -- 2021
		end -- 2021
	end -- 2021
end -- 1837
function Play.prototype.captureGateBlood(self) -- 2030
	self.hpAtGate = self.hp -- 2031
	self.maxHpAtGate = self.maxHp -- 2032
end -- 2030
function Play.prototype.commitRoute(self) -- 2039
	if self.storySettled then -- 2039
		return -- 2041
	end -- 2041
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2043
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2044
	self.hpAtGate = hp -- 2045
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2046
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2047
	self.storySettled = true -- 2048
	self:emit("storyRouteLocked", { -- 2049
		route = self.storyRoute, -- 2050
		hp = self.hp, -- 2050
		maxHp = self.maxHp, -- 2050
		hpAtGate = self.hpAtGate, -- 2051
		maxHpAtGate = self.maxHpAtGate -- 2051
	}) -- 2051
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2053
end -- 2039
function Play.prototype.syncStory(self) -- 2057
	if self.isCampaign and self.run.trial ~= nil then -- 2057
		return -- 2059
	end -- 2059
	local s = self.run.story -- 2061
	if s == nil then -- 2061
		return -- 2063
	end -- 2063
	s.hp = self.hp -- 2065
	s.maxHp = self.maxHp -- 2066
	s.route = self.storyRoute -- 2067
	s.settled = self.storySettled -- 2068
	s.hpAtGate = self.hpAtGate -- 2069
	s.maxHpAtGate = self.maxHpAtGate -- 2070
	s.handDone = self.handDone -- 2071
	s.lineSaid = self.lineSaid -- 2072
	s.tied = self.tied -- 2073
	s.carry = self.carryOn -- 2074
	s.escortDone = self.escortDone -- 2075
	s.craftedWeapon = self.run.story.craftedWeapon -- 2076
	s.ending = self.run.story.ending -- 2077
	if self.room.key == "gate" then -- 2077
		s.phase = self.phase -- 2079
		s.countTick = self.countTick -- 2080
		s.phaseTick = self.phaseTick -- 2081
		s.handTicks = self.handTicks -- 2082
	end -- 2082
end -- 2057
function Play.prototype.stepGatePath(self) -- 2087
	local ____temp_37 -- 2088
	if self.room.story == nil then -- 2088
		____temp_37 = nil -- 2088
	else -- 2088
		____temp_37 = self.room.story.gatepath -- 2088
	end -- 2088
	local gp = ____temp_37 -- 2088
	if self.phase == "gatepath-start" then -- 2088
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2088
			self.carryOn = true -- 2091
			self.phase = "gatepath-carry" -- 2092
			self.phaseTick = 0 -- 2093
			self.pathDone = true -- 2094
			self.escortDone = false -- 2095
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2096
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2097
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2098
		end -- 2098
		return -- 2100
	end -- 2100
	if self.phase == "gatepath-carry" then -- 2100
		self.phaseTick = self.phaseTick + 1 -- 2103
		if self.phaseTick == 20 then -- 2103
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2105
		end -- 2105
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2105
			self:requestRoom(gp.next, "背负进首战") -- 2108
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2109
		end -- 2109
	end -- 2109
end -- 2087
function Play.prototype.carryPose(self) -- 2118
	local p = self.player -- 2119
	local a = self.partner -- 2120
	a.alive = true -- 2121
	a.x = p.x - p.facing * 12 -- 2122
	a.y = p.y + 26 -- 2123
	a.depth = p.depth -- 2124
	a.vx = p.vx -- 2125
	a.vy = 0 -- 2126
	a.onGround = true -- 2127
	a.crouch = false -- 2128
	a.h = CHILD_CROUCH_H -- 2129
	a.facing = p.facing -- 2130
end -- 2118
function Play.prototype.stepTower(self, dt, input) -- 2134
	local ____temp_38 -- 2135
	if self.room.story == nil then -- 2135
		____temp_38 = nil -- 2135
	else -- 2135
		____temp_38 = self.room.story.tower -- 2135
	end -- 2135
	local t = ____temp_38 -- 2135
	if t == nil then -- 2135
		return -- 2137
	end -- 2137
	if self.phase == "tower-wait" then -- 2137
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2140
		if near and input.interact.pressed then -- 2140
			self.phase = "tower-knock" -- 2142
			self.phaseTick = 0 -- 2143
			self.knocks = 1 -- 2144
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2145
			self:flashSet("敲一下", 0.6) -- 2146
		end -- 2146
		return -- 2148
	end -- 2148
	if self.phase == "tower-knock" then -- 2148
		self.phaseTick = self.phaseTick + 1 -- 2151
		if self.phaseTick == 12 then -- 2151
			self.knocks = 2 -- 2153
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2154
			self:flashSet("敲两下 · 第二声", 1) -- 2155
		elseif self.phaseTick >= t.knockTicks then -- 2155
			self.phase = "tower-given" -- 2157
			self.phaseTick = 0 -- 2158
			self:flashSet("门开了 · 提灯", 1.4) -- 2159
		end -- 2159
		return -- 2161
	end -- 2161
	if self.phase == "tower-given" then -- 2161
		local soldier = self.storyRoute == "soldier" -- 2166
		self.phaseTick = self.phaseTick + 1 -- 2167
		if self.phaseTick == 60 then -- 2167
			self:flashSet(soldier and "守卒问名 · 第一行 周戍" or "登记簿第一行 · 只有一个人", 1.6) -- 2169
		elseif self.phaseTick == 120 then -- 2169
			self:flashSet(soldier and "第二行 · 小满 · 两人同行" or "西窗留一盏灯 · 等他回来", 2.4) -- 2171
		elseif self.phaseTick >= 180 then -- 2171
			self.phase = "tower-end" -- 2173
			self.phaseTick = 0 -- 2174
			if not self.run.finished then -- 2174
				self.run.finished = true -- 2176
				local ending = soldier and "reunion" or "lamp" -- 2177
				self.run.story.ending = ending -- 2178
				self.run.archive.artifactOwned = true -- 2179
				if soldier then -- 2179
					self.run.archive.soldierCleared = true -- 2181
				else -- 2181
					self.run.archive.childCleared = true -- 2183
				end -- 2183
				self:log("结局 " .. ending) -- 2185
				self:emit("endingReached", { -- 2186
					route = soldier and "soldier" or "child", -- 2187
					ending = ending, -- 2188
					childCleared = self.run.archive.childCleared, -- 2189
					soldierCleared = self.run.archive.soldierCleared, -- 2190
					artifactOwned = true, -- 2191
					equipped = self.equippedWeapon -- 2192
				}) -- 2192
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2194
			end -- 2194
		end -- 2194
		return -- 2197
	end -- 2197
	if input.interact.pressed or input.retry.pressed then -- 2197
		self:requestRoom("prologue", "片尾再玩") -- 2200
		self:flashSet("回到序章", 1.4) -- 2201
	end -- 2201
end -- 2134
function Play.prototype.stepChase(self, dt, input) -- 2206
	if self.caughtT > 0 then -- 2206
		self.caughtT = self.caughtT - dt -- 2208
		if self.caughtT <= 0 then -- 2208
			self:recoverFromCaught() -- 2210
		end -- 2210
		return -- 2212
	end -- 2212
	if self.room.key == "village" then -- 2212
		self:stepScavChase() -- 2215
	elseif self.room.key == "forest" then -- 2215
		self:stepDog(dt) -- 2217
		if self.player.x >= self.ox + 1450 then -- 2217
			self:requestRoom("tower", "到林缘北塔") -- 2220
			self:flashSet("林缘 · 北塔", 1.4) -- 2221
		end -- 2221
	end -- 2221
end -- 2206
function Play.prototype.stepScavChase(self) -- 2227
	local s = self.room.scavenger -- 2228
	if s == nil then -- 2228
		return -- 2230
	end -- 2230
	local p = self.player -- 2232
	if self.passed and p.x > self.ox + 440 then -- 2232
		if self.scavChase then -- 2232
			self.scavChase = false -- 2236
			self.scavState = "back" -- 2237
			self.scavT = 0 -- 2238
		end -- 2238
		return -- 2240
	end -- 2240
	local dx = p.x - self.scavX -- 2242
	local dist = math.abs(dx) -- 2243
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2244
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2245
	if not self.scavChase then -- 2245
		if visible then -- 2245
			self.scavSee = self.scavSee + 1 -- 2248
			if self.scavSee >= 24 then -- 2248
				self.scavChase = true -- 2250
				self.scavState = "chase" -- 2251
				self.scavTargetX = p.x -- 2252
				self:flashSet("他看见你了", 1.2) -- 2253
			end -- 2253
		else -- 2253
			self.scavSee = 0 -- 2256
		end -- 2256
		return -- 2258
	end -- 2258
	local dir = p.x > self.scavX and 1 or -1 -- 2261
	self.scavX = self.scavX + dir * 96 / 60 -- 2262
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2262
		self:caught() -- 2264
		return -- 2265
	end -- 2265
	if hidden then -- 2265
		self.scavSee = 0 -- 2269
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2270
		self.scavT = self.scavT - 1 -- 2271
		if self.scavT <= 0 then -- 2271
			self.scavChase = false -- 2273
			self.scavState = "patrol" -- 2274
			self:flashSet("他失去了目标", 1) -- 2275
		end -- 2275
	end -- 2275
end -- 2227
function Play.prototype.stepDog(self, dt) -- 2281
	local ____temp_39 -- 2282
	if self.room.story == nil then -- 2282
		____temp_39 = nil -- 2282
	else -- 2282
		____temp_39 = self.room.story.dog -- 2282
	end -- 2282
	local dog = ____temp_39 -- 2282
	if dog == nil then -- 2282
		return -- 2284
	end -- 2284
	local p = self.player -- 2286
	local dist = math.abs(p.x - self.dogX) -- 2287
	if self.dogState == "patrol" then -- 2287
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2289
		if self.dogX < dog.x0 then -- 2289
			self.dogX = dog.x0 -- 2291
			self.dogDir = 1 -- 2292
		elseif self.dogX > dog.x1 then -- 2292
			self.dogX = dog.x1 -- 2294
			self.dogDir = -1 -- 2295
		end -- 2295
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2297
		if not p.crouch and moving and dist < dog.range then -- 2297
			self.dogState = "ear" -- 2299
			self.dogT = 18 -- 2300
			self.dogTargetX = p.x -- 2301
			self:flashSet("狗转耳朵", 0.8) -- 2302
		end -- 2302
		return -- 2304
	end -- 2304
	if self.dogState == "ear" then -- 2304
		self.dogT = self.dogT - 1 -- 2307
		if self.dogT <= 0 then -- 2307
			self.dogState = "chase" -- 2309
			self.dogTargetX = p.x -- 2310
			self:flashSet("狗追来了", 1.4) -- 2311
		end -- 2311
		return -- 2313
	end -- 2313
	if self.dogState == "chase" then -- 2313
		local dir = p.x > self.dogX and 1 or -1 -- 2316
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2317
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2317
			self:caught() -- 2319
			self.dogState = "sniff" -- 2320
			self.dogT = 60 -- 2321
		elseif dist > dog.range * 1.5 or p.crouch then -- 2321
			self.dogState = "sniff" -- 2323
			self.dogT = 60 -- 2324
			self:flashSet("狗停下了", 0.9) -- 2325
		end -- 2325
		return -- 2327
	end -- 2327
	if self.dogState == "sniff" then -- 2327
		self.dogT = self.dogT - 1 -- 2330
		if self.dogT <= 0 then -- 2330
			self.dogState = "back" -- 2332
		end -- 2332
		return -- 2334
	end -- 2334
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2337
	self.dogX = self.dogX + dir * dog.speed * dt -- 2338
	if math.abs(self.dogX - dog.x0) < 2 then -- 2338
		self.dogX = dog.x0 -- 2340
		self.dogState = "patrol" -- 2341
	end -- 2341
end -- 2281
function Play.prototype.caught(self) -- 2345
	self.caughtT = 1 -- 2346
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2347
end -- 2345
function Play.prototype.recoverFromCaught(self) -- 2351
	local p = self.player -- 2352
	p.x = self.ox + 140 -- 2353
	p.y = 0 -- 2354
	p.vy = 0 -- 2355
	p.vx = 0 -- 2356
	p.onGround = true -- 2357
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2357
		self.scavX = self.room.scavenger.x0 -- 2359
		self.scavState = "patrol" -- 2360
		self.scavSee = 0 -- 2361
		self.scavChase = false -- 2362
		self.scavT = 0 -- 2363
	end -- 2363
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2363
		self.dogX = self.room.story.dog.x0 -- 2366
		self.dogState = "patrol" -- 2367
		self.dogT = 0 -- 2368
	end -- 2368
	self.cam.x = p.x -- 2370
	self.cam.y = p.y + CAM_LOOK_UP -- 2371
	self:flashSet("回到安全点", 1.2) -- 2372
end -- 2351
function Play.prototype.updateGate(self) -- 2376
	if self.room.key ~= "checkpoint" then -- 2376
		self.gateOpen = false -- 2378
		return -- 2379
	end -- 2379
	local function inZone(x) -- 2381
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2381
	end -- 2381
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2382
end -- 2376
function Play.prototype.addItem(self, kind) -- 2388
	local inv = self.run.inventory -- 2389
	if kind == "shield" then -- 2389
		if inv.shield >= TOOL_CAP then -- 2389
			return false -- 2392
		end -- 2392
		inv.shield = inv.shield + 1 -- 2394
		return true -- 2395
	end -- 2395
	if kind == "wedge" then -- 2395
		if inv.wedge >= CONSUMABLE_CAP then -- 2395
			return false -- 2399
		end -- 2399
		inv.wedge = inv.wedge + 1 -- 2401
		return true -- 2402
	end -- 2402
	if kind == "ammo" then -- 2402
		if inv.ammo >= CONSUMABLE_CAP then -- 2402
			return false -- 2406
		end -- 2406
		inv.ammo = inv.ammo + 1 -- 2408
		return true -- 2409
	end -- 2409
	if kind == "scrap" then -- 2409
		inv.scrap = inv.scrap + 1 -- 2413
		return true -- 2414
	end -- 2414
	if kind == "wood" then -- 2414
		inv.wood = inv.wood + 1 -- 2417
		return true -- 2418
	end -- 2418
	if kind == "bell" then -- 2418
		inv.bell = inv.bell + 1 -- 2421
		return true -- 2422
	end -- 2422
	if kind == "pass" then -- 2422
		inv.pass = inv.pass + 1 -- 2425
		return true -- 2426
	end -- 2426
	if kind == "quickbelt" then -- 2426
		inv.quickbelt = inv.quickbelt + 1 -- 2429
		return true -- 2430
	end -- 2430
	return false -- 2432
end -- 2388
function Play.prototype.findBox(self, id) -- 2435
	local i = 0 -- 2436
	do -- 2436
		i = 0 -- 2437
		while i < #self.boxes do -- 2437
			if self.boxes[i + 1].id == id then -- 2437
				return self.boxes[i + 1] -- 2439
			end -- 2439
			i = i + 1 -- 2437
		end -- 2437
	end -- 2437
	return nil -- 2442
end -- 2435
function Play.prototype.findWedgeTarget(self) -- 2446
	local best = nil -- 2447
	local bestD = 0 -- 2448
	local i = 0 -- 2449
	do -- 2449
		i = 0 -- 2450
		while i < #self.boxes do -- 2450
			do -- 2450
				local b = self.boxes[i + 1] -- 2451
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2451
					goto __continue366 -- 2453
				end -- 2453
				if not self:nearBox(b, 26) then -- 2453
					goto __continue366 -- 2456
				end -- 2456
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2458
				if best == nil or d < bestD then -- 2458
					best = b -- 2460
					bestD = d -- 2461
				end -- 2461
			end -- 2461
			::__continue366:: -- 2461
			i = i + 1 -- 2450
		end -- 2450
	end -- 2450
	return best -- 2464
end -- 2446
function Play.prototype.stepCraft(self, input) -- 2472
	local inv = self.run.inventory -- 2473
	local ____opt_40 = self.run.trial -- 2473
	local required = CRAFT_TICKS - 6 * (____opt_40 and ____opt_40.ranks.craft or 0) -- 2474
	if self.craftT > 0 then -- 2474
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2474
			self.craftT = 0 -- 2478
			self:flashSet("制作中断", 0.8) -- 2479
			return true -- 2480
		end -- 2480
		self.craftT = self.craftT + 1 -- 2482
		if self.craftT >= required then -- 2482
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2482
				inv.scrap = inv.scrap - 1 -- 2485
				inv.wedge = inv.wedge + 1 -- 2486
				self:flashSet("制得木楔", 1.2) -- 2487
				self:log("制木楔") -- 2488
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2489
			end -- 2489
			self.craftT = 0 -- 2491
		end -- 2491
		return true -- 2493
	end -- 2493
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2493
		self.craftT = 1 -- 2496
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2497
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2498
		return true -- 2499
	end -- 2499
	return false -- 2501
end -- 2472
function Play.prototype.nearBox(self, b, reach) -- 2504
	local p = self.player -- 2505
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2506
end -- 2504
function Play.prototype.findInteract(self) -- 2512
	local p = self.player -- 2513
	local best = nil -- 2514
	local bestD = 1000000000 -- 2515
	local i = 0 -- 2516
	do -- 2516
		i = 0 -- 2517
		while i < #self.boxes do -- 2517
			do -- 2517
				local b = self.boxes[i + 1] -- 2518
				if b.interact == nil or b.broken == true then -- 2518
					goto __continue379 -- 2520
				end -- 2520
				if not self:nearBox(b, b.interact.reach or 27) then -- 2520
					goto __continue379 -- 2523
				end -- 2523
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2525
				if d < bestD then -- 2525
					bestD = d -- 2527
					best = b -- 2528
				end -- 2528
			end -- 2528
			::__continue379:: -- 2528
			i = i + 1 -- 2517
		end -- 2517
	end -- 2517
	return best -- 2531
end -- 2512
function Play.prototype.stepCampaign(self, dt, input) -- 2535
	local wr = self.room -- 2536
	local p = self.player -- 2537
	if self.reloadT > 0 then -- 2537
		self.reloadT = self.reloadT - 1 -- 2539
	end -- 2539
	if self.bracedShield ~= nil then -- 2539
		self.bracedShield.x = p.x + p.facing * 26 -- 2543
		self.bracedShield.y = p.y -- 2544
		local shBox = __TS__ArrayFind( -- 2545
			self.boxes, -- 2545
			function(____, b) return b.id == "braced_shield" end -- 2545
		) -- 2545
		if shBox ~= nil then -- 2545
			shBox.x0 = self.bracedShield.x - 15 -- 2547
			shBox.x1 = self.bracedShield.x + 15 -- 2548
			shBox.y0 = self.bracedShield.y -- 2549
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2550
		end -- 2550
	end -- 2550
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2550
		self.run.route = "drygoods" -- 2556
		self.run.joined = false -- 2557
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2558
		self:log("转布行线") -- 2559
	end -- 2559
	if wr.key == "escort3" then -- 2559
		local benchX = wr.minX + 560 -- 2563
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 12 -- 2564
		if self.craftBench.active then -- 2564
			if input.interact.pressed or input.pause.pressed then -- 2564
				self:closeCraftBench() -- 2567
			end -- 2567
		elseif nearBench and input.interact.pressed then -- 2567
			self:openCraftBench() -- 2570
		end -- 2570
	end -- 2570
	local i = 0 -- 2574
	do -- 2574
		i = 0 -- 2575
		while i < #self.pickups do -- 2575
			do -- 2575
				local pk = self.pickups[i + 1] -- 2576
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2576
					goto __continue394 -- 2578
				end -- 2578
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2580
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2581
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2581
					if not self:addItem(pk.kind) then -- 2581
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2585
						self:log("满包拒绝 " .. pk.kind) -- 2586
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2587
						goto __continue394 -- 2588
					end -- 2588
					self.run.taken[pk.id] = true -- 2590
					pk.id = "" -- 2591
					self:flashSet("拾取 " .. pk.label, 1) -- 2592
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2593
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2594
				end -- 2594
			end -- 2594
			::__continue394:: -- 2594
			i = i + 1 -- 2575
		end -- 2575
	end -- 2575
	if not self:stepCraft(input) and input.interact.pressed then -- 2575
		self:campaignInteract() -- 2598
	end -- 2598
	self:stepCampaignCart(dt, input) -- 2600
	self:stepCampaignGoal() -- 2601
	self:campaignCheckpoint() -- 2602
end -- 2535
function Play.prototype.campaignCheckpoint(self) -- 2606
	local i = 0 -- 2607
	do -- 2607
		i = 0 -- 2608
		while i < #self.room.marks do -- 2608
			do -- 2608
				local m = self.room.marks[i + 1] -- 2609
				if m.kind ~= 0 then -- 2609
					goto __continue401 -- 2611
				end -- 2611
				local dx = self.player.x - m.x -- 2613
				local dy = self.player.y - m.y -- 2614
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2614
					self.checkpoint = m.x -- 2616
					self:captureCheckpoint(m.x) -- 2617
					self:flashSet("检查点", 1) -- 2618
				end -- 2618
			end -- 2618
			::__continue401:: -- 2618
			i = i + 1 -- 2608
		end -- 2608
	end -- 2608
end -- 2606
function Play.prototype.campaignInteract(self) -- 2624
	local b = self:findInteract() -- 2625
	if b ~= nil then -- 2625
		self:useInteract(b) -- 2627
		return -- 2628
	end -- 2628
	local inv = self.run.inventory -- 2630
	if inv.wedge > 0 then -- 2630
		local w = self:findWedgeTarget() -- 2632
		if w ~= nil then -- 2632
			if w.breakable ~= nil then -- 2632
				local ____w_breakable_42, ____hp_43 = w.breakable, "hp" -- 2632
				____w_breakable_42[____hp_43] = ____w_breakable_42[____hp_43] + (w.breakable.wedgeHp or 1) -- 2635
			end -- 2635
			inv.wedge = inv.wedge - 1 -- 2637
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2638
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2640
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2641
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2642
			return -- 2643
		end -- 2643
	end -- 2643
	if inv.ammo > 0 and self.reloadT > 0 then -- 2643
		self.reloadT = 0 -- 2648
		self:closeReloadPuzzle() -- 2649
		inv.ammo = inv.ammo - 1 -- 2650
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2651
		self:log("用备用弹包") -- 2652
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2653
		return -- 2654
	end -- 2654
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2654
		local p = self.player -- 2658
		self.bracedShield = { -- 2659
			x = p.x + p.facing * 26, -- 2659
			y = p.y, -- 2659
			w = 30, -- 2659
			h = 64, -- 2659
			hp = 1 -- 2659
		} -- 2659
		local ____self_boxes_44 = self.boxes -- 2659
		____self_boxes_44[#____self_boxes_44 + 1] = { -- 2660
			x0 = self.bracedShield.x - 15, -- 2661
			x1 = self.bracedShield.x + 15, -- 2661
			y0 = p.y, -- 2662
			y1 = p.y + 64, -- 2662
			depth = {min = -46, max = 46}, -- 2662
			label = "架起的残盾", -- 2662
			id = "braced_shield", -- 2662
			soft = true -- 2663
		} -- 2663
		inv.shield = inv.shield - 1 -- 2666
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2667
		self:log("架残盾") -- 2668
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2669
		return -- 2670
	end -- 2670
	if inv.pass > 0 and self.run.joined == false then -- 2670
		inv.pass = inv.pass - 1 -- 2673
		self.run.joined = true -- 2674
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2675
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2676
		return -- 2677
	end -- 2677
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2679
end -- 2624
function Play.prototype.useInteract(self, b) -- 2682
	local kind = b.interact == nil and "" or b.interact.kind -- 2683
	local wr = self.room -- 2684
	if kind == "open_board" then -- 2684
		b.broken = true -- 2686
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2687
		for ____, cover in ipairs(self.boxes) do -- 2688
			if cover.id == "s2_board_cover" then -- 2688
				cover.broken = false -- 2690
				cover.hidden = false -- 2691
			end -- 2691
		end -- 2691
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2694
		self.run.joined = true -- 2695
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2696
		self:log("放下窗板") -- 2697
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2698
		return -- 2699
	end -- 2699
	if kind == "lower_curtain" then -- 2699
		for ____, curtain in ipairs(self.boxes) do -- 2702
			if curtain.id == "c2_curtain" then -- 2702
				curtain.broken = false -- 2704
				curtain.hidden = false -- 2705
			end -- 2705
		end -- 2705
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2708
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2709
		self:log("放下木帘") -- 2710
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2711
		return -- 2712
	end -- 2712
	if kind == "raise_latch" then -- 2712
		if wr.key == "c2-granary" and not self.cartDocked then -- 2712
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2716
			return -- 2717
		end -- 2717
		b.broken = true -- 2719
		self.objectiveDone = true -- 2720
		if wr.key == "c1-yard" then -- 2720
			self.run.c1Latch = true -- 2723
			self.run.joined = true -- 2724
		else -- 2724
			self.run.c2Latch = true -- 2726
			self.run.joined = true -- 2727
		end -- 2727
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2729
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2730
		self:log("抬闩") -- 2731
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2732
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2733
	end -- 2733
end -- 2682
function Play.prototype.stepCampaignCart(self, dt, input) -- 2738
	local wr = self.room -- 2739
	local c = wr.cart -- 2740
	if c.bodyW <= 0 then -- 2740
		return -- 2742
	end -- 2742
	local p = self.player -- 2744
	local handleX = self.cartAxle + c.handleOffset -- 2745
	if not self.gripping then -- 2745
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2745
			self.gripping = true -- 2749
			self:flashSet("握住车柄 · A/D 推", 1) -- 2750
		end -- 2750
		return -- 2752
	end -- 2752
	if input.interact.pressed then -- 2752
		self.gripping = false -- 2755
		self:flashSet("松手", 0.5) -- 2756
		return -- 2757
	end -- 2757
	if not self.cartDocked then -- 2757
		if input.moveX ~= 0 and not self:stuckCart() then -- 2757
			self.cartAxle = math.max( -- 2761
				c.startX, -- 2761
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2761
			) -- 2761
		end -- 2761
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2761
			self.cartExposed = true -- 2766
			local gun = nil -- 2767
			local gi = 0 -- 2768
			do -- 2768
				gi = 0 -- 2769
				while gi < #self.enemies do -- 2769
					local e = self.enemies[gi + 1] -- 2770
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2770
						gun = e -- 2772
						break -- 2773
					end -- 2773
					gi = gi + 1 -- 2769
				end -- 2769
			end -- 2769
			if gun ~= nil then -- 2769
				self:campaignEnemyFire(gun) -- 2777
			end -- 2777
		end -- 2777
		p.x = self.cartAxle + c.handleOffset -- 2780
		p.y = c.baseY + (c.depth or 0) -- 2781
		p.vx = 0 -- 2782
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2782
			self.cartAxle = c.endX -- 2784
			self.cartDocked = true -- 2785
			self.gripping = false -- 2786
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2787
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2788
			self:flashSet("车轮入窝", 1.2) -- 2789
			self:log("车轮入窝") -- 2790
		end -- 2790
	end -- 2790
end -- 2738
function Play.prototype.stuckCart(self) -- 2796
	local i = 0 -- 2797
	do -- 2797
		i = 0 -- 2798
		while i < #self.boxes do -- 2798
			do -- 2798
				local b = self.boxes[i + 1] -- 2799
				if b.broken == true or b.breakable == nil or b.soft == true then -- 2799
					goto __continue440 -- 2801
				end -- 2801
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 2803
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 2803
					return true -- 2805
				end -- 2805
			end -- 2805
			::__continue440:: -- 2805
			i = i + 1 -- 2798
		end -- 2798
	end -- 2798
	return false -- 2808
end -- 2796
function Play.prototype.stepCampaignGoal(self) -- 2812
	local wr = self.room -- 2813
	local c = wr.campaign -- 2814
	if c == nil then -- 2814
		return -- 2816
	end -- 2816
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 2816
		self.objectiveDone = true -- 2819
	end -- 2819
	if c.goal == "reach_exit" then -- 2819
		self.objectiveDone = true -- 2822
	end -- 2822
	if not self.objectiveDone then -- 2822
		return -- 2825
	end -- 2825
	local p = self.player -- 2827
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 2828
	if p.x < c.exitX or not partnerOk then -- 2828
		return -- 2830
	end -- 2830
	if self.run.story.segments[wr.key] ~= true then -- 2830
		self.run.story.segments[wr.key] = true -- 2834
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 2835
	end -- 2835
	if wr.key == "escort5" then -- 2835
		self.escortDone = true -- 2839
		self.run.story.escortDone = true -- 2840
	end -- 2840
	if c.next ~= nil and c.next ~= "" then -- 2840
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 2843
		self:flashSet("过关 · " .. c.next, 1.2) -- 2844
	elseif not self.run.finished then -- 2844
		self.run.finished = true -- 2846
		self:flashSet( -- 2847
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 2847
			2 -- 2847
		) -- 2847
		self:log("C2 灰盒完成") -- 2848
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 2849
	end -- 2849
end -- 2812
function Play.prototype.stepCampaignPartner(self, dt) -- 2854
	local a = self.partner -- 2855
	local wr = self.room -- 2856
	local cp = wr.companion -- 2857
	if not a.alive then -- 2857
		return -- 2859
	end -- 2859
	local p = self.player -- 2861
	if self.craftBench.active then -- 2861
		a.vx = 0 -- 2864
		return -- 2865
	end -- 2865
	local wait = false -- 2867
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 2868
	local targetDepth = p.depth -- 2869
	if self.run.joined == false then -- 2869
		wait = true -- 2871
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2872
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2873
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 2873
		wait = true -- 2875
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2876
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2877
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 2877
		wait = true -- 2879
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2880
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2881
	end -- 2881
	if self.partnerStuck > 0.3 then -- 2881
		a.x = a.x + a.facing * 44 -- 2885
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2886
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2887
		self.partnerLaneHold = 1.1 -- 2888
		self.partnerStuck = 0 -- 2889
	end -- 2889
	if self.partnerLaneHold > 0 then -- 2889
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2892
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2893
	end -- 2893
	local dx = targetX - a.x -- 2895
	if not wait and math.abs(dx) > 74 then -- 2895
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2897
		local before = a.x -- 2898
		a.vx = dx > 0 and speed or -speed -- 2899
		a.facing = dx > 0 and 1 or -1 -- 2900
		self:slideX(a, a.vx * dt) -- 2901
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2901
			a.vy = CHILD_JUMP -- 2904
			a.onGround = false -- 2905
		end -- 2905
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2907
	else -- 2907
		a.vx = 0 -- 2909
		self.partnerStuck = 0 -- 2910
	end -- 2910
	local dz = targetDepth - a.depth -- 2912
	if math.abs(dz) > 6 then -- 2912
		local step = math.max( -- 2914
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2914
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2914
		) -- 2914
		a.depth = a.depth + step -- 2915
	end -- 2915
	a.depthSpeed = 0 -- 2917
	a.h = CHILD_H -- 2918
	a.crouch = false -- 2919
	self:fallY(a, dt) -- 2920
end -- 2854
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2924
	local p = self.player -- 2925
	local i = 0 -- 2926
	do -- 2926
		i = 0 -- 2927
		while i < #self.enemies do -- 2927
			do -- 2927
				local ____opt_45 = self.run.trial -- 2927
				if ____opt_45 and ____opt_45.lost then -- 2927
					return -- 2928
				end -- 2928
				local e = self.enemies[i + 1] -- 2929
				if not e.alive then -- 2929
					goto __continue467 -- 2931
				end -- 2931
				if e.hitT > 0 then -- 2931
					e.hitT = e.hitT - dt -- 2934
				end -- 2934
				if e.kind == "target" then -- 2934
					if not e.alive and e.hitT <= 0 then -- 2934
						e.alive = true -- 2939
					end -- 2939
					goto __continue467 -- 2941
				end -- 2941
				if e.kind == "breaker" then -- 2941
					self:stepBreaker(e, dt) -- 2944
					goto __continue467 -- 2945
				end -- 2945
				if e.kind == "shield" then -- 2945
					self:stepShield(e, dt, input) -- 2948
					goto __continue467 -- 2949
				end -- 2949
				local dx = e.x - p.x -- 2952
				if not e.awake then -- 2952
					if math.abs(dx) > 520 then -- 2952
						goto __continue467 -- 2955
					end -- 2955
					e.awake = true -- 2957
					e.fireCd = 48 -- 2958
					goto __continue467 -- 2959
				end -- 2959
				if math.abs(dx) > ENEMY_RANGE then -- 2959
					goto __continue467 -- 2962
				end -- 2962
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2962
					goto __continue467 -- 2967
				end -- 2967
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2967
					goto __continue467 -- 2970
				end -- 2970
				if self:blockedShot(e, p) then -- 2970
					if e.warnT > 0 then -- 2970
						e.warnT = 0 -- 2976
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2977
					end -- 2977
					goto __continue467 -- 2979
				end -- 2979
				if e.warnT > 0 then -- 2979
					e.warnT = e.warnT - 1 -- 2982
					if e.warnT <= 0 then -- 2982
						self:campaignEnemyFire(e) -- 2984
					end -- 2984
				elseif e.fireCd > 0 then -- 2984
					e.fireCd = e.fireCd - 1 -- 2987
					if e.fireCd <= 0 then -- 2987
						e.warnT = WARN_TICKS -- 2989
					end -- 2989
				else -- 2989
					e.fireCd = 40 -- 2992
				end -- 2992
			end -- 2992
			::__continue467:: -- 2992
			i = i + 1 -- 2927
		end -- 2927
	end -- 2927
end -- 2924
function Play.prototype.blockedShot(self, e, p) -- 2998
	local eDepth = e.depth or 0 -- 2999
	local ex = e.x -- 3000
	local ey = e.y + e.h * 0.62 -- 3002
	local px = p.x -- 3003
	local py = p.y + p.h * 0.55 -- 3004
	local dx = px - ex -- 3005
	local dyScreen = py + p.depth - (ey + eDepth) -- 3006
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3007
	if len < 0.01 then -- 3007
		return false -- 3009
	end -- 3009
	local ray = { -- 3013
		x = ex, -- 3014
		y = ey, -- 3014
		dx = dx / len, -- 3015
		dy = (py - ey) / len, -- 3015
		depth = eDepth, -- 3016
		dDepth = (p.depth - eDepth) / len -- 3016
	} -- 3016
	local best = -1 -- 3018
	local j = 0 -- 3019
	do -- 3019
		j = 0 -- 3020
		while j < #self.boxes do -- 3020
			do -- 3020
				local b = self.boxes[j + 1] -- 3021
				if b.broken == true or b.passable == true or b.hidden == true then -- 3021
					goto __continue490 -- 3023
				end -- 3023
				if b.id == "braced_shield" then -- 3023
					goto __continue490 -- 3028
				end -- 3028
				local t = hitBox(ray, b) -- 3030
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3030
					best = t -- 3034
				end -- 3034
			end -- 3034
			::__continue490:: -- 3034
			j = j + 1 -- 3020
		end -- 3020
	end -- 3020
	return best >= 0 -- 3037
end -- 2998
function Play.prototype.campaignEnemyFire(self, e) -- 3040
	local p = self.player -- 3041
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3042
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3042
		local ____self_bracedShield_47, ____hp_48 = self.bracedShield, "hp" -- 3042
		____self_bracedShield_47[____hp_48] = ____self_bracedShield_47[____hp_48] - 1 -- 3044
		self.boxes = __TS__ArrayFilter( -- 3045
			self.boxes, -- 3045
			function(____, b) return b.id ~= "braced_shield" end -- 3045
		) -- 3045
		self.bracedShield = nil -- 3046
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3047
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3048
		return -- 3049
	end -- 3049
	if self:blockedShot(e, p) then -- 3049
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3052
		return -- 3053
	end -- 3053
	local cover = self:blockedByCover(e, p) -- 3055
	if cover ~= nil and self.coverHug then -- 3055
		self.coveredFlash = 0.5 -- 3057
		self:flashSet("掩体挡下", 0.6) -- 3058
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3059
		return -- 3064
	end -- 3064
	if self.invulnT > 0 then -- 3064
		return -- 3067
	end -- 3067
	local ____opt_49 = self.run.trial -- 3067
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_49 and ____opt_49.ranks.guard or 0) -- 3069
	self.craftT = 0 -- 3070
	self.hp = self.hp - 1 -- 3071
	self:emit("actorHit", { -- 3072
		target = "player", -- 3072
		amount = 1, -- 3072
		hp = self.hp, -- 3072
		maxHp = self.maxHp, -- 3072
		enemyX = e.x -- 3072
	}) -- 3072
	self:flashSet( -- 3073
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3073
		0.8 -- 3073
	) -- 3073
	if self.hp <= 0 then -- 3073
		self:campaignFailed() -- 3075
	end -- 3075
end -- 3040
function Play.prototype.stepShield(self, e, dt, input) -- 3080
	local p = self.player -- 3081
	local dx = p.x - e.x -- 3082
	local adx = math.abs(dx) -- 3083
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3086
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3087
	if adx > 150 then -- 3087
		local before = e.x -- 3089
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3090
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3090
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3093
		end -- 3093
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3093
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3098
		local rollDodges = p.rollT > 0 and fromFront -- 3099
		if not rollDodges and self.invulnT <= 0 then -- 3099
			local ____opt_51 = self.run.trial -- 3099
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_51 and ____opt_51.ranks.guard or 0) -- 3101
			self.craftT = 0 -- 3102
			self.hp = self.hp - 1 -- 3103
			self:emit("actorHit", { -- 3104
				target = "player", -- 3104
				amount = 1, -- 3104
				hp = self.hp, -- 3104
				maxHp = self.maxHp, -- 3104
				enemyX = e.x -- 3104
			}) -- 3104
			self:flashSet( -- 3105
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3105
				0.8 -- 3105
			) -- 3105
			if self.hp <= 0 then -- 3105
				self:campaignFailed() -- 3107
				return -- 3108
			end -- 3108
		end -- 3108
		e.swingT = 70 -- 3111
	end -- 3111
	if (e.swingT or 0) > 0 then -- 3111
		e.swingT = (e.swingT or 0) - 1 -- 3114
	end -- 3114
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3114
		local dd = p.depth - (e.depth or 0) -- 3117
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3118
	end -- 3118
end -- 3080
function Play.prototype.stepBreaker(self, e, dt) -- 3123
	local p = self.player -- 3124
	if e.awake ~= true then -- 3124
		if math.abs(p.x - e.x) < 560 then -- 3124
			e.awake = true -- 3127
		else -- 3127
			return -- 3129
		end -- 3129
	end -- 3129
	local target = nil -- 3132
	local bestD = 1000000000 -- 3133
	local i = 0 -- 3134
	do -- 3134
		i = 0 -- 3135
		while i < #self.boxes do -- 3135
			do -- 3135
				local b = self.boxes[i + 1] -- 3136
				if b.breakable == nil or b.broken == true then -- 3136
					goto __continue514 -- 3138
				end -- 3138
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3140
				if d < bestD then -- 3140
					bestD = d -- 3142
					target = b -- 3143
				end -- 3143
			end -- 3143
			::__continue514:: -- 3143
			i = i + 1 -- 3135
		end -- 3135
	end -- 3135
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3146
	local dx = tx - e.x -- 3147
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3148
	if math.abs(dx) > reach then -- 3148
		local before = e.x -- 3150
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3151
		if math.abs(e.x - before) < 0.3 then -- 3151
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3153
		end -- 3153
	elseif (e.swingT or 0) <= 0 then -- 3153
		e.swingT = 64 -- 3156
		if target ~= nil then -- 3156
			self:damageProp(target, 2) -- 3158
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3158
			local ____opt_53 = self.run.trial -- 3158
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_53 and ____opt_53.ranks.guard or 0) -- 3160
			self.craftT = 0 -- 3161
			self.hp = self.hp - 1 -- 3162
			self:emit("actorHit", { -- 3163
				target = "player", -- 3163
				amount = 1, -- 3163
				hp = self.hp, -- 3163
				maxHp = self.maxHp, -- 3163
				enemyX = e.x -- 3163
			}) -- 3163
			self:flashSet("破障手近身", 0.8) -- 3164
			if self.hp <= 0 then -- 3164
				self:campaignFailed() -- 3166
				return -- 3167
			end -- 3167
		end -- 3167
	end -- 3167
	if (e.swingT or 0) > 0 then -- 3167
		e.swingT = (e.swingT or 0) - 1 -- 3172
	end -- 3172
end -- 3123
function Play.prototype.campaignFailed(self) -- 3176
	if self.run.trial ~= nil then -- 3176
		self.run.trial.lost = true -- 3178
		self.wantRoom = "" -- 3179
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3180
		return -- 3181
	end -- 3181
	local p = self.player -- 3183
	self.hp = self.maxHp -- 3184
	self.invulnT = INVULN_RESPAWN_TICKS -- 3185
	self.reloadT = 0 -- 3186
	self:closeReloadPuzzle() -- 3187
	self.gripping = false -- 3188
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3189
	self:log("被击倒") -- 3190
	p.x = self.room.minX + 90 -- 3191
	p.y = 0 -- 3192
	p.depth = 0 -- 3193
	p.vx = 0 -- 3194
	p.vy = 0 -- 3195
	p.onGround = true -- 3196
	p.rollT = 0 -- 3197
	self.partner.x = p.x - 50 -- 3198
	self.partner.y = 0 -- 3199
	self.partner.depth = 0 -- 3200
	self.cam.x = p.x -- 3201
	local i = 0 -- 3202
	do -- 3202
		i = 0 -- 3203
		while i < #self.enemies do -- 3203
			do -- 3203
				local e = self.enemies[i + 1] -- 3204
				if not e.alive then -- 3204
					goto __continue527 -- 3206
				end -- 3206
				e.x = e.homeX == nil and e.x or e.homeX -- 3208
				e.warnT = 0 -- 3209
				e.fireCd = 40 -- 3210
				e.swingT = 0 -- 3211
				e.awake = false -- 3212
			end -- 3212
			::__continue527:: -- 3212
			i = i + 1 -- 3203
		end -- 3203
	end -- 3203
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3214
end -- 3176
function Play.prototype.stepEnemies(self, dt, input) -- 3217
	local i = 0 -- 3218
	do -- 3218
		i = 0 -- 3219
		while i < #self.enemies do -- 3219
			local e = self.enemies[i + 1] -- 3220
			if e.hitT > 0 then -- 3220
				e.hitT = e.hitT - dt -- 3222
			end -- 3222
			i = i + 1 -- 3219
		end -- 3219
	end -- 3219
	if self.coveredFlash > 0 then -- 3219
		self.coveredFlash = self.coveredFlash - dt -- 3226
	end -- 3226
	if self.isCampaign then -- 3226
		self:stepCampaignEnemies(dt, input) -- 3229
		return -- 3230
	end -- 3230
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3230
		return -- 3234
	end -- 3234
	do -- 3234
		i = 0 -- 3236
		while i < #self.enemies do -- 3236
			do -- 3236
				local e = self.enemies[i + 1] -- 3237
				if not e.alive then -- 3237
					goto __continue537 -- 3239
				end -- 3239
				if e.warnT > 0 then -- 3239
					e.warnT = e.warnT - 1 -- 3242
					if e.warnT <= 0 then -- 3242
						self:enemyFire(e, input) -- 3244
					end -- 3244
					goto __continue537 -- 3246
				end -- 3246
				if e.fireCd > 0 then -- 3246
					e.fireCd = e.fireCd - 1 -- 3249
					if e.fireCd <= 0 then -- 3249
						e.warnT = WARN_TICKS -- 3251
					end -- 3251
				else -- 3251
					e.warnT = WARN_TICKS -- 3255
				end -- 3255
			end -- 3255
			::__continue537:: -- 3255
			i = i + 1 -- 3236
		end -- 3236
	end -- 3236
end -- 3217
function Play.prototype.enemyFire(self, e, input) -- 3261
	local p = self.player -- 3262
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3262
		self:flashSet("枪声响在远处", 0.4) -- 3264
		e.fireCd = FIRE_COOLDOWN -- 3265
		return -- 3266
	end -- 3266
	local cover = self:blockedByCover(e, p) -- 3269
	local hugging = cover ~= nil -- 3270
	self.coverBlocking = hugging -- 3271
	local covered = hugging and input.cover.held -- 3272
	if covered then -- 3272
		self.coveredFlash = 0.5 -- 3274
		self:flashSet("掩体挡下", 0.5) -- 3275
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3276
		e.fireCd = FIRE_COOLDOWN -- 3281
		return -- 3282
	end -- 3282
	self.hp = self.hp - 1 -- 3284
	self:emit("actorHit", { -- 3285
		target = "player", -- 3285
		amount = 1, -- 3285
		hp = self.hp, -- 3285
		maxHp = self.maxHp, -- 3285
		enemyX = e.x -- 3285
	}) -- 3285
	self:flashSet( -- 3286
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3286
		0.7 -- 3286
	) -- 3286
	e.fireCd = FIRE_COOLDOWN -- 3287
	if self.hp <= 0 then -- 3287
		self:gateFailed() -- 3289
	end -- 3289
end -- 3261
function Play.prototype.blockedByCover(self, enemy, p) -- 3294
	local b = self:coverAt(p) -- 3295
	if b == nil then -- 3295
		return nil -- 3297
	end -- 3297
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3299
end -- 3294
function Play.prototype.gateFailed(self) -- 3303
	local ____temp_55 -- 3304
	if self.room.story == nil then -- 3304
		____temp_55 = nil -- 3304
	else -- 3304
		____temp_55 = self.room.story.gate -- 3304
	end -- 3304
	local g = ____temp_55 -- 3304
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3305
	self.hp = self.maxHp -- 3306
	self.gateTick = 0 -- 3307
	self.gateSpawned = 0 -- 3308
	self.enemies = {} -- 3309
	self.gateFailCount = self.gateFailCount + 1 -- 3310
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3312
	self.player.y = 0 -- 3313
	self.player.vy = 0 -- 3314
	self.player.depth = 0 -- 3315
	self.player.depthSpeed = 0 -- 3316
	self.player.onGround = true -- 3317
	self.player.crouch = false -- 3318
	self.player.h = SOLDIER_H -- 3319
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3320
	self.partner.y = 0 -- 3321
	self.partner.vy = 0 -- 3322
	self.partner.depth = 0 -- 3323
	self.partner.depthSpeed = 0 -- 3324
	self.partner.onGround = true -- 3325
	self.cam.x = self.player.x -- 3326
	self.phase = "gate-idle" -- 3327
	self.phaseTick = 0 -- 3328
	self.coverHug = false -- 3329
	self.coverBlocking = false -- 3330
	self.coverEntity = "" -- 3331
	self.gateNeedConfirm = true -- 3332
	self.gateRestartArmed = false -- 3333
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3334
end -- 3303
function Play.prototype.stepInteract(self, dt, input) -- 3337
	local p = self.player -- 3338
	local calmUsed = self.calmConsumed -- 3339
	self.calmConsumed = false -- 3340
	local calming = self.escort.state == "calming" -- 3342
	self.focusCart = false -- 3343
	if self.room.key == "outside" then -- 3343
		local c = self.room.cart -- 3345
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3346
		local dy = p.y - c.baseY -- 3347
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3348
	end -- 3348
	if not calmUsed and not calming then -- 3348
		self:stepCart(dt, input) -- 3352
	end -- 3352
	if calmUsed then -- 3352
		self:flashSet("安抚 · 敲两下", 0.8) -- 3357
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 3357
		if self.knockT > 0 then -- 3357
			self.knocks = self.knocks + 1 -- 3361
		else -- 3361
			self.knocks = 1 -- 3363
		end -- 3363
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3365
		self.knockT = 1.2 -- 3366
		if self.knocks >= 2 then -- 3366
			self:flashSet("敲两下", 0.8) -- 3368
			self.knocks = 0 -- 3369
		else -- 3369
			self:flashSet("敲一下", 0.5) -- 3371
		end -- 3371
	elseif self.knockT > 0 then -- 3371
		self.knockT = self.knockT - dt -- 3374
		if self.knockT <= 0 then -- 3374
			self.knocks = 0 -- 3376
		end -- 3376
	end -- 3376
	local i = 0 -- 3381
	do -- 3381
		i = 0 -- 3382
		while i < #self.room.marks do -- 3382
			do -- 3382
				local m = self.room.marks[i + 1] -- 3383
				if m.kind ~= 0 then -- 3383
					goto __continue563 -- 3385
				end -- 3385
				local subjects = {self.partner, self.player} -- 3387
				local k = 0 -- 3388
				do -- 3388
					k = 0 -- 3389
					while k < #subjects do -- 3389
						do -- 3389
							local s = subjects[k + 1] -- 3390
							if not s.alive then -- 3390
								goto __continue566 -- 3392
							end -- 3392
							local dx = s.x - m.x -- 3394
							local dy = s.y - m.y -- 3395
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3395
								self.checkpoint = m.x -- 3397
								self.checkpointCartAxle = self.cartAxle -- 3398
								if self.isCampaign then -- 3398
									self:captureCheckpoint(m.x) -- 3401
								end -- 3401
								if self.cartDocked then -- 3401
									self:flashSet("检查点 · 车已落窝", 1) -- 3404
								else -- 3404
									self:flashSet("检查点 · 车还没到位", 1) -- 3406
								end -- 3406
							end -- 3406
						end -- 3406
						::__continue566:: -- 3406
						k = k + 1 -- 3389
					end -- 3389
				end -- 3389
			end -- 3389
			::__continue563:: -- 3389
			i = i + 1 -- 3382
		end -- 3382
	end -- 3382
	self:checkCarryGate() -- 3412
end -- 3337
function Play.prototype.stepVillage(self, dt, input) -- 3416
	if self.room.key ~= "village" then -- 3416
		return -- 3418
	end -- 3418
	local p = self.player -- 3420
	local bottle = self.room.bottle -- 3421
	local scav = self.room.scavenger -- 3422
	if not self.hasBottle and bottle ~= nil then -- 3422
		local dx = p.x - bottle.x -- 3426
		local dy = p.y + p.h * 0.5 - bottle.y -- 3427
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3427
			self.hasBottle = true -- 3429
			self:flashSet("拾起瓶子", 0.8) -- 3430
		end -- 3430
	end -- 3430
	if self.hasBottle then -- 3430
		if input.aim.held then -- 3430
			self.aimHold = self.aimHold + dt -- 3437
			if self.aimHold > 1.2 then -- 3437
				self.aimHold = 1.2 -- 3439
			end -- 3439
			local cached = self:bottleEnd() -- 3442
			self.bottleAimX = cached.x -- 3443
			self.bottleAimY = cached.y -- 3444
		elseif input.aim.released then -- 3444
			if self.aimHold < 0.12 then -- 3444
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3448
				self.aimHold = 0 -- 3449
			else -- 3449
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3451
				self:throwBottle(____end.x, ____end.y) -- 3452
				self.aimHold = 0 -- 3453
			end -- 3453
		end -- 3453
	else -- 3453
		self.aimHold = 0 -- 3457
		self.bottleAimX = -1 -- 3458
	end -- 3458
	local fly = self.bottleFly -- 3463
	if fly ~= nil then -- 3463
		fly.t = fly.t + dt -- 3465
		fly.x = fly.x0 + fly.vx * fly.t -- 3466
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3467
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3468
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3468
			self:landBottle(fly) -- 3470
		end -- 3470
	end -- 3470
	if self.bottleLandT > 0 then -- 3470
		self.bottleLandT = self.bottleLandT - dt -- 3474
	end -- 3474
	if scav ~= nil then -- 3474
		self:stepScav(dt, scav) -- 3478
	end -- 3478
	local line = self.room.passLine -- 3481
	if line ~= nil and not self.passed and p.x >= line then -- 3481
		self.passed = true -- 3483
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3484
	end -- 3484
	if self.passed and p.x >= self.ox + 640 then -- 3484
		self:requestRoom("forest", "过第一院出院") -- 3488
		self:flashSet("出院 · 北塔森林", 1.4) -- 3489
	end -- 3489
end -- 3416
function Play.prototype.bottleEnd(self) -- 3494
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3495
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3498
	return {x = aim.x, y = g} -- 3499
end -- 3494
function Play.prototype.throwBottle(self, tx, ty) -- 3503
	local p = self.player -- 3504
	local dir = tx >= p.x and 1 or -1 -- 3506
	p.facing = dir -- 3507
	local x0 = p.x + dir * 10 -- 3508
	local y0 = p.y + p.h * 0.7 -- 3509
	self.bottleTargetX = tx -- 3510
	self.bottleTargetY = ty -- 3511
	self.bottleSurfaceY = ty -- 3512
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3513
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3514
	self.bottleFly = { -- 3515
		x = x0, -- 3515
		y = y0, -- 3515
		x0 = x0, -- 3515
		y0 = y0, -- 3515
		vx = vx, -- 3515
		vy = vy, -- 3515
		t = 0 -- 3515
	} -- 3515
	self.hasBottle = false -- 3516
	self:flashSet("投出", 0.4) -- 3517
	self:emit( -- 3518
		"bottleThrown", -- 3518
		{ -- 3518
			fromX = x0, -- 3519
			fromY = y0, -- 3520
			targetX = tx, -- 3521
			targetY = ty, -- 3522
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3523
		} -- 3523
	) -- 3523
end -- 3503
function Play.prototype.landBottle(self, fly) -- 3528
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3529
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3530
	local s = self.room.scavenger -- 3531
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3532
	self.bottleFly = nil -- 3533
	self.bottleTargetX = -1 -- 3534
	self.bottleTargetY = 0 -- 3535
	self.bottleSurfaceY = -1 -- 3536
	self.bottleLandX = x -- 3537
	self.bottleLandY = y -- 3538
	self.bottleLandT = 0.9 -- 3539
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3540
	self:hearBottle(x) -- 3541
end -- 3528
function Play.prototype.hearBottle(self, x) -- 3545
	local s = self.room.scavenger -- 3546
	if s == nil then -- 3546
		return -- 3548
	end -- 3548
	if math.abs(x - self.scavX) > s.range then -- 3548
		self:flashSet("落地 · 他没听见", 0.6) -- 3551
		return -- 3552
	end -- 3552
	self.scavState = "turn" -- 3554
	self.scavT = s.hearTicks -- 3555
	self.scavTargetX = x -- 3556
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3557
end -- 3545
function Play.prototype.stepScav(self, dt, s) -- 3561
	if self.scavState == "chase" then -- 3561
		return -- 3564
	end -- 3564
	if self.scavState == "turn" then -- 3564
		self.scavT = self.scavT - 1 -- 3567
		if self.scavT <= 0 then -- 3567
			self.scavState = "walk" -- 3569
		end -- 3569
		return -- 3571
	end -- 3571
	if self.scavState == "walk" then -- 3571
		local d = self.scavTargetX - self.scavX -- 3574
		if math.abs(d) < 4 then -- 3574
			self.scavState = "stall" -- 3576
			self.scavT = s.stallTicks -- 3577
			return -- 3578
		end -- 3578
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3580
		return -- 3581
	end -- 3581
	if self.scavState == "stall" then -- 3581
		self.scavT = self.scavT - 1 -- 3584
		if self.scavT <= 0 then -- 3584
			self.scavState = "back" -- 3586
		end -- 3586
		return -- 3588
	end -- 3588
	if self.scavState == "back" then -- 3588
		local home = math.max( -- 3591
			s.x0, -- 3591
			math.min(s.x1, self.scavX) -- 3591
		) -- 3591
		if math.abs(home - self.scavX) < 2 then -- 3591
			self.scavState = "patrol" -- 3593
			return -- 3594
		end -- 3594
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3596
		return -- 3597
	end -- 3597
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3599
	if self.scavX >= s.x1 then -- 3599
		self.scavX = s.x1 -- 3601
		self.scavDir = -1 -- 3602
	elseif self.scavX <= s.x0 then -- 3602
		self.scavX = s.x0 -- 3604
		self.scavDir = 1 -- 3605
	end -- 3605
end -- 3561
function Play.prototype.stepCart(self, dt, input) -- 3613
	local p = self.player -- 3614
	local c = self.room.cart -- 3615
	if self.gripping then -- 3615
		if not input.interact.held then -- 3615
			self.gripping = false -- 3619
			self:flashSet("松开车把", 0.4) -- 3620
			return -- 3621
		end -- 3621
	else -- 3621
		if not input.interact.pressed then -- 3621
			return -- 3625
		end -- 3625
		if not self:cartHandleInReach(p) then -- 3625
			return -- 3628
		end -- 3628
		local track = c.depth or 0 -- 3630
		if self:limitDepth(p, track) ~= track then -- 3630
			return -- 3632
		end -- 3632
		p.depth = track -- 3634
		p.depthSpeed = 0 -- 3635
		self.gripping = true -- 3636
		self:flashSet("握住车把", 0.4) -- 3637
		return -- 3638
	end -- 3638
	if self.cartDocked then -- 3638
		return -- 3642
	end -- 3642
	local dir = input.moveX -- 3644
	if dir == 0 then -- 3644
		return -- 3646
	end -- 3646
	local lo = math.min(c.startX, c.endX) -- 3648
	local hi = math.max(c.startX, c.endX) -- 3649
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3650
	if next < lo then -- 3650
		next = lo -- 3652
	end -- 3652
	if next > hi then -- 3652
		next = hi -- 3655
	end -- 3655
	local delta = next - self.cartAxle -- 3657
	if delta == 0 then -- 3657
		return -- 3659
	end -- 3659
	self.cartAxle = next -- 3661
	p.x = p.x + delta -- 3662
	p.facing = dir > 0 and 1 or -1 -- 3663
	self:slideX(p, 0) -- 3664
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3664
		self.gripping = false -- 3666
		self:flashSet("跟不上了，脱手", 0.6) -- 3667
		return -- 3668
	end -- 3668
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3668
		self.cartDocked = true -- 3671
		self.gripping = false -- 3672
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3673
		self:flashSet("车轮落窝", 1.2) -- 3674
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3674
		self:flashSet("车轮回到起点", 0.5) -- 3676
	end -- 3676
end -- 3613
function Play.prototype.requestRoom(self, key, reason) -- 3684
	if self.wantRoom ~= "" then -- 3684
		return -- 3688
	end -- 3688
	self.wantRoom = key -- 3690
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3691
end -- 3684
function Play.prototype.checkCarryGate(self) -- 3698
	if self.room.key == "checkpoint" then -- 3698
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3698
			self.carryCartAxle = self.cartAxle -- 3701
			self.carryCartDocked = self.cartDocked -- 3702
			self:requestRoom("gate", "检查站出口") -- 3703
			self:flashSet("出检查站 · 城门", 1.2) -- 3704
		end -- 3704
		return -- 3706
	end -- 3706
	if self.room.key == "outside" then -- 3706
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3706
			self.carryCartAxle = self.cartAxle -- 3712
			self.carryCartDocked = self.cartDocked -- 3713
			self:requestRoom("village", "墙根走完") -- 3714
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3715
		end -- 3715
	end -- 3715
end -- 3698
function Play.prototype.aimAt(self, wx, wy) -- 3722
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3723
	self.aimX = s.x -- 3724
	self.aimY = s.y -- 3725
end -- 3722
function Play.prototype.shoot(self, a) -- 3728
	if self.isCampaign and self.reloadT > 0 then -- 3728
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3730
		return -- 3731
	end -- 3731
	local ox = a.x + a.facing * 8 -- 3733
	local muzzleY = a.y + a.h * 0.72 -- 3734
	local oy = muzzleY + a.depth -- 3735
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3737
	local dx = aim.x - ox -- 3740
	local dy = aim.y - oy -- 3741
	local len = math.sqrt(dx * dx + dy * dy) -- 3742
	if len < 0.001 then -- 3742
		dx = a.facing -- 3744
		dy = 0 -- 3745
	else -- 3745
		dx = dx / len -- 3747
		dy = dy / len -- 3748
	end -- 3748
	if dx ~= 0 then -- 3748
		a.facing = dx > 0 and 1 or -1 -- 3751
	end -- 3751
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3754
	local hitEnemy = self:raycastEnemies(ray) -- 3755
	local tEnemy = hitEnemy.t -- 3756
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3757
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3758
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3759
	local tWall = solid.t -- 3760
	local rawEffect = self:consumeReloadEffect() -- 3762
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 3763
	local reloadEffect = rawEffect -- 3764
	if rawEffect == "light" and weaponFx ~= "light" then -- 3764
		reloadEffect = "push" -- 3766
	end -- 3766
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light" and weaponFx == "light") -- 3768
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3769
	self.trace = { -- 3771
		x0 = ox, -- 3771
		y0 = oy, -- 3771
		x1 = ox + dx * t, -- 3771
		y1 = oy + dy * t, -- 3771
		hit = hit -- 3771
	} -- 3771
	self.traceT = 0.12 -- 3772
	self:applyFireDanger(ox) -- 3773
	local killed = false -- 3774
	if hit then -- 3774
		local i = hitEnemy.index -- 3776
		local e = self.enemies[i + 1] -- 3777
		local impactY = oy + dy * tEnemy -- 3778
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3779
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3780
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3780
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3782
			e.hitT = 0.3 -- 3783
			self:flashSet( -- 3784
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3784
				0.8 -- 3784
			) -- 3784
			self:emit("shotResolved", { -- 3785
				hit = true, -- 3786
				enemyIndex = i, -- 3786
				enemyX = e.x, -- 3786
				aimX = aim.x, -- 3786
				aimY = aim.y, -- 3786
				impactX = ox + dx * t, -- 3787
				impactY = oy + dy * t, -- 3787
				shield = true -- 3787
			}) -- 3787
			self:beginReload() -- 3789
			return -- 3790
		end -- 3790
		e.alive = false -- 3792
		e.hitT = 0.4 -- 3793
		killed = true -- 3794
		self:flashSet("命中", 0.6) -- 3795
		self:dropFor(e) -- 3796
		if reloadEffect == "push" then -- 3796
			e.x = e.x + a.facing * 46 -- 3798
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 3799
		elseif reloadEffect == "echo" then -- 3799
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 3801
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 3802
		elseif reloadEffect == "light" then -- 3802
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 3804
		end -- 3804
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3804
		self:damageProp(solid.box, 1) -- 3807
	else -- 3807
		self:flashSet("打空", 0.35) -- 3809
	end -- 3809
	if self.isCampaign then -- 3809
		self:beginReload() -- 3812
	end -- 3812
	self:emit("shotResolved", { -- 3814
		hit = hit, -- 3815
		enemyIndex = hit and hitEnemy.index or -1, -- 3816
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3817
		aimX = aim.x, -- 3818
		aimY = aim.y, -- 3819
		impactX = ox + dx * t, -- 3820
		impactY = oy + dy * t -- 3821
	}) -- 3821
end -- 3728
function Play.prototype.applyFireDanger(self, shotX) -- 3826
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3826
		return -- 3828
	end -- 3828
	local dangerX = shotX -- 3830
	local best = -1 -- 3831
	local bestD = 1000000000 -- 3832
	local i = 0 -- 3833
	do -- 3833
		i = 0 -- 3834
		while i < #self.enemies do -- 3834
			do -- 3834
				local e = self.enemies[i + 1] -- 3835
				if not e.alive then -- 3835
					goto __continue647 -- 3837
				end -- 3837
				local d = math.abs(e.x - self.partner.x) -- 3839
				if d < bestD then -- 3839
					bestD = d -- 3841
					best = i -- 3842
				end -- 3842
			end -- 3842
			::__continue647:: -- 3842
			i = i + 1 -- 3834
		end -- 3834
	end -- 3834
	if best >= 0 then -- 3834
		dangerX = self.enemies[best + 1].x -- 3846
	end -- 3846
	local exposed = self:childExposed(dangerX) -- 3848
	local before = self.escort.fear -- 3849
	local dangerId = self.nextDangerId -- 3850
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 3851
	self.nextDangerId = self.nextDangerId + 1 -- 3852
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 3853
	if after > before then -- 3853
		self:flashSet( -- 3855
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 3855
			1 -- 3855
		) -- 3855
	elseif not exposed then -- 3855
		self:flashSet("枪声没够到她", 0.5) -- 3857
	end -- 3857
end -- 3826
function Play.prototype.childExposed(self, dangerX) -- 3862
	local c = self.partner -- 3863
	if not c.alive then -- 3863
		return false -- 3865
	end -- 3865
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 3865
		self.boxes, -- 3868
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 3868
	) then -- 3868
		return false -- 3869
	end -- 3869
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 3869
		return false -- 3872
	end -- 3872
	local toDanger = dangerX - c.x -- 3874
	local toPlayer = self.player.x - c.x -- 3875
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 3875
		return false -- 3878
	end -- 3878
	return true -- 3880
end -- 3862
function Play.prototype.raycastEnemies(self, ray) -- 3884
	local best = -1 -- 3885
	local bestI = -1 -- 3886
	do -- 3886
		local i = 0 -- 3887
		while i < #self.enemies do -- 3887
			do -- 3887
				local e = self.enemies[i + 1] -- 3888
				if not e.alive then -- 3888
					goto __continue661 -- 3890
				end -- 3890
				local y = e.y + (e.depth or 0) -- 3892
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 3893
				if t >= 0 and (best < 0 or t < best) then -- 3893
					best = t -- 3895
					bestI = i -- 3896
				end -- 3896
			end -- 3896
			::__continue661:: -- 3896
			i = i + 1 -- 3887
		end -- 3887
	end -- 3887
	return {t = best, index = bestI} -- 3899
end -- 3884
function Play.prototype.raycastWorld(self, ray) -- 3902
	return self:raycastSolid(ray).t -- 3903
end -- 3902
function Play.prototype.raycastSolid(self, ray) -- 3907
	local best = -1 -- 3908
	local bestBox = nil -- 3909
	for ____, box in ipairs(self.boxes) do -- 3910
		do -- 3910
			if box.broken == true or box.hidden == true then -- 3910
				goto __continue666 -- 3912
			end -- 3912
			local t = hitBox(ray, box) -- 3917
			if t > 2 and (best < 0 or t < best) then -- 3917
				best = t -- 3920
				bestBox = box -- 3921
			end -- 3921
		end -- 3921
		::__continue666:: -- 3921
	end -- 3921
	if ray.dy < 0 then -- 3921
		local t = -ray.y / ray.dy -- 3925
		if t >= 0 and (best < 0 or t < best) then -- 3925
			best = t -- 3927
			bestBox = nil -- 3928
		end -- 3928
	end -- 3928
	return {t = best, box = bestBox} -- 3931
end -- 3907
function Play.prototype.dropFor(self, e) -- 3935
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 3935
		return -- 3937
	end -- 3937
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 3937
		return -- 3940
	end -- 3940
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 3942
	local ____self_pickups_56 = self.pickups -- 3942
	____self_pickups_56[#____self_pickups_56 + 1] = { -- 3943
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 3944
		kind = e.drop, -- 3944
		x = e.x, -- 3944
		y = e.y, -- 3944
		depth = e.depth, -- 3945
		label = label .. " ×1" -- 3945
	} -- 3945
	self:log("掉落 " .. label) -- 3947
end -- 3935
function Play.prototype.damageProp(self, b, amount) -- 3951
	if b.breakable == nil or b.broken == true then -- 3951
		return -- 3953
	end -- 3953
	local ____b_breakable_57, ____hp_58 = b.breakable, "hp" -- 3953
	____b_breakable_57[____hp_58] = ____b_breakable_57[____hp_58] - amount -- 3955
	if b.breakable.hp > 0 then -- 3955
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3957
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3958
		return -- 3959
	end -- 3959
	b.broken = true -- 3961
	for ____, other in ipairs(self.boxes) do -- 3962
		if other.id ~= nil and other.id == b.id then -- 3962
			other.broken = true -- 3964
		end -- 3964
	end -- 3964
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3967
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3968
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3969
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3970
end -- 3951
function Play.prototype.slideDepth(self, a, distance) -- 3974
	a.depth = self:limitDepth(a, a.depth + distance) -- 3975
end -- 3974
function Play.prototype.limitDepth(self, a, target) -- 3978
	local road = self.room.depth -- 3979
	if road == nil or target == a.depth then -- 3979
		return a.depth -- 3981
	end -- 3981
	local next = math.max( -- 3983
		road.min, -- 3983
		math.min(road.max, target) -- 3983
	) -- 3983
	local half = a.w / 2 -- 3984
	for ____, b in ipairs(self.boxes) do -- 3985
		do -- 3985
			local footprint = b.depth -- 3986
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 3986
				goto __continue684 -- 3991
			end -- 3991
			local front = footprint.min - ACTOR_DEPTH_HALF -- 3993
			local back = footprint.max + ACTOR_DEPTH_HALF -- 3994
			if a.depth <= front and next > front then -- 3994
				next = front -- 3996
			elseif a.depth >= back and next < back then -- 3996
				next = back -- 3998
			end -- 3998
		end -- 3998
		::__continue684:: -- 3998
	end -- 3998
	return next -- 4001
end -- 3978
function Play.prototype.slideX(self, a, dx) -- 4005
	local nx = a.x + dx -- 4006
	local half = a.w / 2 -- 4007
	local room = self.room -- 4008
	nx = math.max( -- 4009
		room.minX + half, -- 4009
		math.min(room.maxX - half, nx) -- 4009
	) -- 4009
	local i = 0 -- 4010
	do -- 4010
		i = 0 -- 4011
		while i < #self.boxes do -- 4011
			do -- 4011
				local b = self.boxes[i + 1] -- 4012
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4012
					goto __continue691 -- 4014
				end -- 4014
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4014
					goto __continue691 -- 4017
				end -- 4017
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4017
					goto __continue691 -- 4020
				end -- 4020
				if nx + half > b.x0 and nx - half < b.x1 then -- 4020
					if a.x <= b.x0 then -- 4020
						nx = b.x0 - half -- 4024
					elseif a.x >= b.x1 then -- 4024
						nx = b.x1 + half -- 4026
					else -- 4026
						nx = a.x -- 4028
					end -- 4028
				end -- 4028
			end -- 4028
			::__continue691:: -- 4028
			i = i + 1 -- 4011
		end -- 4011
	end -- 4011
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4011
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4036
		local bx0 = self.cartAxle - CART_HALF -- 4037
		local bx1 = self.cartAxle + CART_HALF -- 4038
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4038
			if a.x <= bx0 then -- 4038
				nx = bx0 - half -- 4041
			elseif a.x >= bx1 then -- 4041
				nx = bx1 + half -- 4043
			else -- 4043
				nx = a.x -- 4045
			end -- 4045
		end -- 4045
	end -- 4045
	local arch = room.arch -- 4053
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4053
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4055
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4055
			if a.x <= arch.x0 then -- 4055
				nx = arch.x0 - half -- 4058
			elseif a.x >= arch.x1 then -- 4058
				nx = arch.x1 + half -- 4060
			end -- 4060
		end -- 4060
	end -- 4060
	a.x = nx -- 4064
end -- 4005
function Play.prototype.fallY(self, a, dt) -- 4068
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4069
	if a.vy < -900 then -- 4069
		a.vy = -900 -- 4071
	end -- 4071
	local ny = a.y + a.vy * dt -- 4073
	local half = a.w / 2 -- 4074
	if a.vy <= 0 then -- 4074
		local reach = a.onGround and STEP_UP or 0 -- 4077
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4078
		if ny <= ground then -- 4078
			ny = ground -- 4080
			a.vy = 0 -- 4081
			a.onGround = true -- 4082
		else -- 4082
			a.onGround = false -- 4084
		end -- 4084
	else -- 4084
		a.onGround = false -- 4087
		local i = 0 -- 4088
		do -- 4088
			i = 0 -- 4089
			while i < #self.boxes do -- 4089
				do -- 4089
					local b = self.boxes[i + 1] -- 4090
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4090
						goto __continue715 -- 4092
					end -- 4092
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4092
						goto __continue715 -- 4095
					end -- 4095
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4095
						goto __continue715 -- 4098
					end -- 4098
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4098
						ny = b.y0 - a.h -- 4101
						a.vy = 0 -- 4102
					end -- 4102
				end -- 4102
				::__continue715:: -- 4102
				i = i + 1 -- 4089
			end -- 4089
		end -- 4089
	end -- 4089
	a.y = ny -- 4106
end -- 4068
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4110
	if depth == nil then -- 4110
		depth = 0 -- 4110
	end -- 4110
	local g = -9999 -- 4111
	local i = 0 -- 4112
	do -- 4112
		i = 0 -- 4113
		while i < #self.floors do -- 4113
			local f = self.floors[i + 1] -- 4114
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4114
				g = f.y1 -- 4116
			end -- 4116
			i = i + 1 -- 4113
		end -- 4113
	end -- 4113
	do -- 4113
		i = 0 -- 4119
		while i < #self.boxes do -- 4119
			do -- 4119
				local b = self.boxes[i + 1] -- 4120
				if b.broken == true or b.hidden == true or b.soft == true then -- 4120
					goto __continue725 -- 4122
				end -- 4122
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4122
					g = b.y1 -- 4126
				end -- 4126
			end -- 4126
			::__continue725:: -- 4126
			i = i + 1 -- 4119
		end -- 4119
	end -- 4119
	return g -- 4129
end -- 4110
function Play.prototype.updateCamera(self, dt) -- 4132
	local p = self.player -- 4133
	local tx = p.x + p.facing * 30 -- 4134
	local ty = p.y + CAM_LOOK_UP -- 4135
	local k = math.min(1, CAM_FOLLOW * dt) -- 4136
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4137
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4138
end -- 4132
function Play.prototype.clampCamera(self, w, h) -- 4142
	local room = self.room -- 4143
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4144
	local spanX = room.maxX - room.minX -- 4145
	if spanX <= halfW * 2 then -- 4145
		self.cam.x = (room.minX + room.maxX) / 2 -- 4147
	else -- 4147
		self.cam.x = math.max( -- 4149
			room.minX + halfW, -- 4149
			math.min(room.maxX - halfW, self.cam.x) -- 4149
		) -- 4149
	end -- 4149
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4152
	local spanY = room.height -- 4153
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4154
	if spanY <= halfH * 2 then -- 4154
		self.cam.y = camY -- 4156
	else -- 4156
		self.cam.y = math.max( -- 4158
			camY, -- 4158
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4158
		) -- 4158
	end -- 4158
end -- 4142
function Play.prototype.flashSet(self, text, t) -- 4162
	self.flash = text -- 4163
	self.flashT = t -- 4164
end -- 4162
function Play.prototype.statusText(self) -- 4168
	local p = self.player -- 4169
	local parts = {} -- 4170
	local who = self.childMode and "小满" or "周戍" -- 4171
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4172
	if self.room.key == "prologue" then -- 4172
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4175
		if self.phase == "prologue-wait" then -- 4175
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4177
		elseif self.phase == "prologue-give" then -- 4177
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4179
		else -- 4179
			parts[#parts + 1] = "跟随" -- 4181
		end -- 4181
		if self.paused then -- 4181
			parts[#parts + 1] = "已暂停" -- 4184
		end -- 4184
		return table.concat(parts, " · ") -- 4186
	end -- 4186
	if self.room.key == "street" then -- 4186
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4189
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4190
		if self.paused then -- 4190
			parts[#parts + 1] = "已暂停" -- 4192
		end -- 4192
		return table.concat(parts, " · ") -- 4194
	end -- 4194
	if self.room.key == "gate" then -- 4194
		local ____temp_59 -- 4197
		if self.room.story == nil then -- 4197
			____temp_59 = nil -- 4197
		else -- 4197
			____temp_59 = self.room.story.gate -- 4197
		end -- 4197
		local g = ____temp_59 -- 4197
		if g ~= nil then -- 4197
			parts[#parts + 1] = self:gateLabel() -- 4199
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4200
				0, -- 4201
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4201
			))) .. " 秒" -- 4201
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4202
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4203
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4204
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4205
			if self.gateFailCount > 0 then -- 4205
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4207
			end -- 4207
			if self.flash ~= "" then -- 4207
				parts[#parts + 1] = self.flash -- 4210
			end -- 4210
		end -- 4210
		if self.paused then -- 4210
			parts[#parts + 1] = "已暂停" -- 4214
		end -- 4214
		return table.concat(parts, " · ") -- 4216
	end -- 4216
	if self.room.key == "forest" then -- 4216
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4219
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4220
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4221
		if self.caughtT > 0 then -- 4221
			parts[#parts + 1] = "复位中" -- 4223
		end -- 4223
		if self.paused then -- 4223
			parts[#parts + 1] = "已暂停" -- 4226
		end -- 4226
		return table.concat(parts, " · ") -- 4228
	end -- 4228
	if self.room.key == "tower" then -- 4228
		if self.phase == "tower-wait" then -- 4228
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4232
		elseif self.phase == "tower-knock" then -- 4232
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4234
		elseif self.phase == "tower-given" then -- 4234
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4236
		else -- 4236
			parts[#parts + 1] = "片尾" -- 4238
		end -- 4238
		if self.paused then -- 4238
			parts[#parts + 1] = "已暂停" -- 4241
		end -- 4241
		return table.concat(parts, " · ") -- 4243
	end -- 4243
	if self.room.key == "village" then -- 4243
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4246
		if self.hasBottle then -- 4246
			parts[#parts + 1] = "有瓶" -- 4248
		elseif self.bottleFly ~= nil then -- 4248
			parts[#parts + 1] = "瓶在飞" -- 4250
		else -- 4250
			parts[#parts + 1] = "空手" -- 4252
		end -- 4252
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4254
		if self.scavChase then -- 4254
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4256
		end -- 4256
		if self.passed then -- 4256
			parts[#parts + 1] = "已过通行线" -- 4259
		end -- 4259
		if self.paused then -- 4259
			parts[#parts + 1] = "已暂停" -- 4262
		end -- 4262
		return table.concat(parts, " · ") -- 4264
	end -- 4264
	local isChild = self.childMode -- 4267
	if isChild then -- 4267
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4269
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4270
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4271
	else -- 4271
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4273
		if p.rollT > 0 then -- 4273
			parts[#parts + 1] = "翻滚中" -- 4275
		end -- 4275
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4277
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4278
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4279
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4280
	end -- 4280
	if self.checkpoint >= 0 then -- 4280
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4283
	end -- 4283
	if self.paused then -- 4283
		parts[#parts + 1] = "已暂停" -- 4286
	end -- 4286
	return table.concat(parts, " · ") -- 4288
end -- 4168
function Play.prototype.aliveEnemies(self) -- 4292
	local n = 0 -- 4293
	local i = 0 -- 4294
	do -- 4294
		i = 0 -- 4295
		while i < #self.enemies do -- 4295
			if self.enemies[i + 1].alive then -- 4295
				n = n + 1 -- 4297
			end -- 4297
			i = i + 1 -- 4295
		end -- 4295
	end -- 4295
	return n -- 4300
end -- 4292
function Play.prototype.threatened(self) -- 4305
	do -- 4305
		local i = 0 -- 4306
		while i < #self.enemies do -- 4306
			local e = self.enemies[i + 1] -- 4307
			if e.alive and e.warnT > 0 then -- 4307
				return true -- 4309
			end -- 4309
			i = i + 1 -- 4306
		end -- 4306
	end -- 4306
	return false -- 4312
end -- 4305
function Play.prototype.gateSecondsLeft(self) -- 4315
	local ____temp_60 -- 4316
	if self.room.story == nil then -- 4316
		____temp_60 = nil -- 4316
	else -- 4316
		____temp_60 = self.room.story.gate -- 4316
	end -- 4316
	local g = ____temp_60 -- 4316
	if g == nil then -- 4316
		return 0 -- 4318
	end -- 4318
	return math.max( -- 4320
		0, -- 4320
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4320
	) -- 4320
end -- 4315
function Play.prototype.gateLabel(self) -- 4323
	if self.phase == "gate-idle" then -- 4323
		return "待就位" -- 4325
	end -- 4325
	if self.phase == "gate-hold" then -- 4325
		return "守点中" -- 4328
	end -- 4328
	if self.phase == "gate-send" then -- 4328
		return "送别" -- 4331
	end -- 4331
	if self.phase == "gate-count" then -- 4331
		return "数数 " .. tostring(self.countTick) -- 4334
	end -- 4334
	return "她走" -- 4336
end -- 4323
function Play.prototype.dogLabel(self) -- 4340
	if self.dogState == "ear" then -- 4340
		return "转耳" -- 4342
	end -- 4342
	if self.dogState == "chase" then -- 4342
		return "追" -- 4345
	end -- 4345
	if self.dogState == "sniff" then -- 4345
		return "停" -- 4348
	end -- 4348
	if self.dogState == "back" then -- 4348
		return "回线" -- 4351
	end -- 4351
	return "巡逻" -- 4353
end -- 4340
function Play.prototype.doorXOf(self) -- 4356
	local ____temp_61 -- 4357
	if self.room.story == nil then -- 4357
		____temp_61 = nil -- 4357
	else -- 4357
		____temp_61 = self.room.story.tower -- 4357
	end -- 4357
	local t = ____temp_61 -- 4357
	return t == nil and 0 or t.doorX -- 4358
end -- 4356
function Play.prototype.scavLabel(self) -- 4362
	if self.scavState == "chase" then -- 4362
		return "追" -- 4364
	end -- 4364
	if self.scavState == "turn" then -- 4364
		return "转头" -- 4367
	end -- 4367
	if self.scavState == "walk" then -- 4367
		return "赶来" -- 4370
	end -- 4370
	if self.scavState == "stall" then -- 4370
		return "停住" -- 4373
	end -- 4373
	if self.scavState == "back" then -- 4373
		return "回位" -- 4376
	end -- 4376
	return "巡逻" -- 4378
end -- 4362
function Play.prototype.hintText(self) -- 4382
	if self.paused then -- 4382
		return "Esc 继续 · R 重置" -- 4384
	end -- 4384
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4384
		if self:threatened() then -- 4384
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4390
		end -- 4390
		if self.coverHug then -- 4390
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4393
		end -- 4393
		if self.coverNear then -- 4393
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4396
		end -- 4396
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4398
	end -- 4398
	if self.flash ~= "" then -- 4398
		return self.flash -- 4401
	end -- 4401
	if self.room.key == "prologue" then -- 4401
		if self.phase == "prologue-wait" then -- 4401
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4405
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4406
		end -- 4406
		if self.phase == "prologue-give" then -- 4406
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4409
		end -- 4409
		return "她跟着你了 · 两人一起走到门口 680" -- 4411
	end -- 4411
	if self.room.key == "street" then -- 4411
		if self:aliveEnemies() > 0 then -- 4411
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4415
		end -- 4415
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4417
	end -- 4417
	if self.room.key == "gate" then -- 4417
		local ____temp_62 -- 4420
		if self.room.story == nil then -- 4420
			____temp_62 = nil -- 4420
		else -- 4420
			____temp_62 = self.room.story.gate -- 4420
		end -- 4420
		local g = ____temp_62 -- 4420
		if g ~= nil then -- 4420
			if self.phase == "gate-idle" then -- 4420
				if self.gateNeedConfirm then -- 4420
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4424
				end -- 4424
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4426
			end -- 4426
			if self.phase == "gate-hold" then -- 4426
				if self.coveredFlash > 0 then -- 4426
					return "掩体挡下了这一枪 · 别露头" -- 4430
				end -- 4430
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4432
			end -- 4432
			if self.phase == "gate-send" then -- 4432
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4435
			end -- 4435
			if self.phase == "gate-count" then -- 4435
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4435
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4439
				end -- 4439
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4441
			end -- 4441
			return "她自己走 · 跟着出城门 1120" -- 4443
		end -- 4443
	end -- 4443
	if self.room.key == "forest" then -- 4443
		if self.dogState == "chase" then -- 4443
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4448
		end -- 4448
		if self.dogState == "ear" then -- 4448
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4451
		end -- 4451
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4453
	end -- 4453
	if self.room.key == "tower" then -- 4453
		if self.phase == "tower-wait" then -- 4453
			return "走到门前 445 点一次 E 敲两下" -- 4457
		end -- 4457
		if self.phase == "tower-knock" then -- 4457
			return "敲两下 · 等门开" -- 4460
		end -- 4460
		if self.phase == "tower-given" then -- 4460
			return "递交针套和纸条 · 看登记簿最后一行" -- 4463
		end -- 4463
		return "片尾 · 点 E 再玩一次，回到序章" -- 4465
	end -- 4465
	if self.room.key == "village" then -- 4465
		if self.bottleFly ~= nil then -- 4465
			return "等瓶子落地 · 触地才发声" -- 4469
		end -- 4469
		if self.hasBottle then -- 4469
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4472
		end -- 4472
		if self.passed then -- 4472
			return "已过第一院 · R 重置可再来一遍" -- 4475
		end -- 4475
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4477
	end -- 4477
	if self.room.key == "outside" then -- 4477
		if self.focusCart then -- 4477
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4481
		end -- 4481
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4483
	end -- 4483
	if self.escort.state == "frozen" then -- 4483
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4483
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4487
		end -- 4487
		return "小满吓住了 · 走过去，靠近再点 E" -- 4489
	end -- 4489
	if self.escort.state == "calming" then -- 4489
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4492
	end -- 4492
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4494
end -- 4382
function Play.prototype.draw(self, draw, w, h) -- 4499
	self.viewW = w -- 4500
	self.viewH = h -- 4501
	self.view = ____exports.computeViewport(w, h) -- 4502
	self:clampCamera(w, h) -- 4503
	draw:clear() -- 4504
	draw:drawRect( -- 4506
		Rect(0, 0, w, h), -- 4506
		BG_VOID -- 4506
	) -- 4506
	local box = self:canvasRect(w, h) -- 4507
	draw:drawRect(box, BG_FAR) -- 4508
	draw:drawRect( -- 4509
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4509
		BG_MID -- 4509
	) -- 4509
	self:drawFloors(draw, w, h) -- 4511
	self:drawSolids(draw, w, h) -- 4512
	self:drawZones(draw, w, h) -- 4513
	self:drawArch(draw, w, h) -- 4514
	self:drawCart(draw, w, h) -- 4515
	self:drawCampaignProps(draw, w, h) -- 4516
	self:drawActors(draw, w, h) -- 4517
	self:drawTrace(draw, w, h) -- 4518
	self:drawAim(draw, w, h) -- 4519
end -- 4499
function Play.prototype.canvasRect(self, w, h) -- 4523
	local v = self.view -- 4524
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4525
end -- 4523
function Play.prototype.px(self, n) -- 4529
	return n * self.view.zoom -- 4530
end -- 4529
function Play.prototype.sx(self, wx, w) -- 4534
	local v = self.view -- 4535
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4536
	return v.ox + lx * v.zoom -- 4537
end -- 4534
function Play.prototype.sy(self, wy, h) -- 4541
	local v = self.view -- 4542
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4543
	return v.oy + ly * v.zoom -- 4544
end -- 4541
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4547
	local px0 = self:sx(x0, w) -- 4548
	local px1 = self:sx(x1, w) -- 4549
	local py0 = self:sy(y0, h) -- 4550
	local py1 = self:sy(y1, h) -- 4551
	if px1 <= px0 or py1 <= py0 then -- 4551
		return -- 4553
	end -- 4553
	draw:drawRect( -- 4555
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4555
		color -- 4555
	) -- 4555
end -- 4547
function Play.prototype.drawFloors(self, draw, w, h) -- 4558
	local i = 0 -- 4559
	do -- 4559
		i = 0 -- 4560
		while i < #self.room.floors do -- 4560
			local f = self.room.floors[i + 1] -- 4561
			local ____temp_63 -- 4562
			if f.y == 0 then -- 4562
				____temp_63 = self.room.depth -- 4562
			else -- 4562
				____temp_63 = nil -- 4562
			end -- 4562
			local road = ____temp_63 -- 4562
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4563
			local x0 = self:sx(f.x0, w) -- 4564
			local x1 = self:sx(f.x1, w) -- 4565
			local deck = self:px(5) -- 4566
			if road ~= nil then -- 4566
				local back = self:sy(f.y + road.max, h) -- 4568
				draw:drawRect( -- 4569
					Rect(x0, y, x1 - x0, back - y), -- 4569
					FLOOR_DECK, -- 4569
					self:px(1), -- 4569
					SOLID_EDGE -- 4569
				) -- 4569
			end -- 4569
			draw:drawRect( -- 4571
				Rect(x0, y - deck, x1 - x0, deck), -- 4571
				FLOOR_DECK -- 4571
			) -- 4571
			draw:drawSegment( -- 4572
				Vec2(x0, y), -- 4572
				Vec2(x1, y), -- 4572
				self:px(1), -- 4572
				GROUND -- 4572
			) -- 4572
			i = i + 1 -- 4560
		end -- 4560
	end -- 4560
end -- 4558
function Play.prototype.drawSolids(self, draw, w, h) -- 4576
	local i = 0 -- 4577
	do -- 4577
		i = 0 -- 4578
		while i < #self.boxes do -- 4578
			do -- 4578
				local b = self.boxes[i + 1] -- 4579
				if b.id == "braced_shield" or b.hidden == true then -- 4579
					goto __continue846 -- 4581
				end -- 4581
				if b.broken == true then -- 4581
					if b.breakable ~= nil then -- 4581
						local gy = self:sy(b.y0, h) -- 4586
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4587
						local k = 0 -- 4588
						do -- 4588
							k = 0 -- 4589
							while k < 3 do -- 4589
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4590
								draw:drawSegment( -- 4591
									Vec2( -- 4591
										gx - self:px(4), -- 4591
										gy + self:px(k % 2) -- 4591
									), -- 4591
									Vec2( -- 4591
										gx + self:px(5), -- 4591
										gy + self:px(k % 2) -- 4591
									), -- 4591
									self:px(1), -- 4591
									rgb -- 4591
								) -- 4591
								k = k + 1 -- 4589
							end -- 4589
						end -- 4589
					end -- 4589
					goto __continue846 -- 4594
				end -- 4594
				local ____opt_66 = b.depth -- 4594
				local front = ____opt_66 and ____opt_66.min or 0 -- 4596
				local ____opt_68 = b.depth -- 4596
				local back = ____opt_68 and ____opt_68.max or 0 -- 4597
				local fill = SOLID_FILL -- 4598
				local line = SOLID_EDGE -- 4599
				if b.soft == true then -- 4599
					fill = SOFT -- 4601
					line = SOFT_LINE -- 4602
				elseif b.breakable ~= nil then -- 4602
					line = DANGER_LINE -- 4604
					fill = Color(0.3, 0.24, 0.16, 1) -- 4605
				elseif b.interact ~= nil then -- 4605
					line = PASS_LINE -- 4607
				end -- 4607
				self:drawBox( -- 4609
					draw, -- 4609
					w, -- 4609
					h, -- 4609
					b.x0, -- 4609
					b.x1, -- 4609
					b.y0 + front, -- 4609
					b.y1 + back, -- 4609
					fill -- 4609
				) -- 4609
				draw:drawSegment( -- 4610
					Vec2( -- 4610
						self:sx(b.x0, w), -- 4610
						self:sy(b.y1 + front, h) -- 4610
					), -- 4610
					Vec2( -- 4611
						self:sx(b.x1, w), -- 4611
						self:sy(b.y1 + front, h) -- 4611
					), -- 4611
					self:px(1), -- 4611
					line -- 4611
				) -- 4611
				if b.breakable ~= nil then -- 4611
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4614
					local cyp = self:sy(b.y1 + front, h) -- 4615
					draw:drawSegment( -- 4616
						Vec2( -- 4616
							cxp - self:px(4), -- 4616
							cyp + self:px(1) -- 4616
						), -- 4616
						Vec2( -- 4616
							cxp + self:px(3), -- 4616
							cyp + self:px(5) -- 4616
						), -- 4616
						self:px(1), -- 4616
						line -- 4616
					) -- 4616
				end -- 4616
			end -- 4616
			::__continue846:: -- 4616
			i = i + 1 -- 4578
		end -- 4578
	end -- 4578
end -- 4576
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4622
	local i = 0 -- 4623
	do -- 4623
		i = 0 -- 4624
		while i < #self.pickups do -- 4624
			do -- 4624
				local pk = self.pickups[i + 1] -- 4625
				if pk.id == "" then -- 4625
					goto __continue858 -- 4627
				end -- 4627
				local gy = pk.y + (pk.depth or 0) -- 4629
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4630
				draw:drawRect( -- 4631
					Rect( -- 4631
						self:sx(pk.x - 5, w), -- 4631
						self:sy(gy + 12 + bob, h), -- 4631
						self:px(10), -- 4631
						self:px(10) -- 4631
					), -- 4631
					Color(0.84, 0.7, 0.3, 1) -- 4632
				) -- 4632
				draw:drawSegment( -- 4633
					Vec2( -- 4633
						self:sx(pk.x - 5, w), -- 4633
						self:sy(gy + 12 + bob, h) -- 4633
					), -- 4633
					Vec2( -- 4634
						self:sx(pk.x + 5, w), -- 4634
						self:sy(gy + 12 + bob, h) -- 4634
					), -- 4634
					self:px(1), -- 4634
					Color(0.95, 0.86, 0.52, 1) -- 4634
				) -- 4634
			end -- 4634
			::__continue858:: -- 4634
			i = i + 1 -- 4624
		end -- 4624
	end -- 4624
	if self.bracedShield ~= nil then -- 4624
		local sh = self.bracedShield -- 4637
		draw:drawRect( -- 4638
			Rect( -- 4638
				self:sx(sh.x - sh.w / 2, w), -- 4638
				self:sy(sh.y, h), -- 4638
				self:px(sh.w), -- 4638
				self:px(sh.h) -- 4638
			), -- 4638
			Color(0.42, 0.4, 0.34, 1) -- 4639
		) -- 4639
		draw:drawSegment( -- 4640
			Vec2( -- 4640
				self:sx(sh.x - sh.w / 2, w), -- 4640
				self:sy(sh.y + sh.h, h) -- 4640
			), -- 4640
			Vec2( -- 4641
				self:sx(sh.x + sh.w / 2, w), -- 4641
				self:sy(sh.y + sh.h, h) -- 4641
			), -- 4641
			self:px(1), -- 4641
			Color(0.74, 0.72, 0.62, 1) -- 4641
		) -- 4641
	end -- 4641
end -- 4622
function Play.prototype.drawZones(self, draw, w, h) -- 4645
	local i = 0 -- 4646
	do -- 4646
		i = 0 -- 4647
		while i < #self.room.zones do -- 4647
			local z = self.room.zones[i + 1] -- 4648
			local fill = DANGER -- 4649
			local line = DANGER_LINE -- 4650
			if z.tint == 2 then -- 4650
				fill = SOFT -- 4652
				line = SOFT_LINE -- 4653
			elseif z.tint == 3 then -- 4653
				fill = BRICK -- 4655
				line = BRICK_LINE -- 4656
			elseif z.tint == 4 then -- 4656
				fill = PASS -- 4658
				line = PASS_LINE -- 4659
			end -- 4659
			self:drawBox( -- 4661
				draw, -- 4661
				w, -- 4661
				h, -- 4661
				z.x0, -- 4661
				z.x1, -- 4661
				z.y, -- 4661
				z.y + z.h, -- 4661
				fill -- 4661
			) -- 4661
			draw:drawSegment( -- 4662
				Vec2( -- 4662
					self:sx(z.x0, w), -- 4662
					self:sy(z.y, h) -- 4662
				), -- 4662
				Vec2( -- 4662
					self:sx(z.x0, w), -- 4662
					self:sy(z.y + z.h, h) -- 4662
				), -- 4662
				self:px(1), -- 4662
				line -- 4662
			) -- 4662
			draw:drawSegment( -- 4663
				Vec2( -- 4663
					self:sx(z.x1, w), -- 4663
					self:sy(z.y, h) -- 4663
				), -- 4663
				Vec2( -- 4663
					self:sx(z.x1, w), -- 4663
					self:sy(z.y + z.h, h) -- 4663
				), -- 4663
				self:px(1), -- 4663
				line -- 4663
			) -- 4663
			i = i + 1 -- 4647
		end -- 4647
	end -- 4647
end -- 4645
function Play.prototype.drawArch(self, draw, w, h) -- 4667
	local a = self.room.arch -- 4668
	if a.h <= 0 then -- 4668
		return -- 4670
	end -- 4670
	self:drawBox( -- 4672
		draw, -- 4672
		w, -- 4672
		h, -- 4672
		a.x0, -- 4672
		a.x1, -- 4672
		a.y, -- 4672
		a.y + a.h, -- 4672
		HOLE_FILL -- 4672
	) -- 4672
	draw:drawSegment( -- 4673
		Vec2( -- 4673
			self:sx(a.x0, w), -- 4673
			self:sy(a.y + a.h, h) -- 4673
		), -- 4673
		Vec2( -- 4673
			self:sx(a.x1, w), -- 4673
			self:sy(a.y + a.h, h) -- 4673
		), -- 4673
		self:px(1), -- 4673
		SOLID_EDGE -- 4673
	) -- 4673
	draw:drawSegment( -- 4674
		Vec2( -- 4674
			self:sx(a.x0, w), -- 4674
			self:sy(a.y, h) -- 4674
		), -- 4674
		Vec2( -- 4674
			self:sx(a.x0, w), -- 4674
			self:sy(a.y + a.h, h) -- 4674
		), -- 4674
		self:px(1), -- 4674
		SOLID_EDGE -- 4674
	) -- 4674
	draw:drawSegment( -- 4675
		Vec2( -- 4675
			self:sx(a.x1, w), -- 4675
			self:sy(a.y, h) -- 4675
		), -- 4675
		Vec2( -- 4675
			self:sx(a.x1, w), -- 4675
			self:sy(a.y + a.h, h) -- 4675
		), -- 4675
		self:px(1), -- 4675
		SOLID_EDGE -- 4675
	) -- 4675
end -- 4667
function Play.prototype.drawCart(self, draw, w, h) -- 4678
	local c = self.room.cart -- 4679
	if c.bodyW <= 0 then -- 4679
		return -- 4681
	end -- 4681
	drawCartShape( -- 4683
		draw, -- 4683
		self, -- 4683
		w, -- 4683
		h, -- 4683
		c, -- 4683
		self.cartAxle -- 4683
	) -- 4683
	draw:drawRect( -- 4684
		Rect( -- 4684
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4684
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4684
			self:px(2), -- 4684
			self:px(40) -- 4684
		), -- 4684
		STAND -- 4684
	) -- 4684
end -- 4678
function Play.prototype.drawActors(self, draw, w, h) -- 4687
	local p = self.player -- 4688
	local isChild = self.childMode -- 4689
	local footY = p.y + p.depth -- 4690
	if p.covered then -- 4690
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4693
		draw:drawSegment( -- 4694
			Vec2( -- 4694
				self:sx(edge, w), -- 4694
				self:sy(footY + 8, h) -- 4694
			), -- 4694
			Vec2( -- 4694
				self:sx(edge, w), -- 4694
				self:sy(footY + p.h * 0.62, h) -- 4694
			), -- 4694
			self:px(2), -- 4694
			STAND -- 4694
		) -- 4694
		draw:drawSegment( -- 4696
			Vec2( -- 4696
				self:sx(p.x - 8, w), -- 4696
				self:sy(footY + p.h + 3, h) -- 4696
			), -- 4696
			Vec2( -- 4696
				self:sx(p.x + 8, w), -- 4696
				self:sy(footY + p.h + 3, h) -- 4696
			), -- 4696
			self:px(2), -- 4696
			STAND -- 4696
		) -- 4696
	elseif self.coverNear and not isChild then -- 4696
		draw:drawRect( -- 4699
			Rect( -- 4699
				self:sx(p.x - 3, w), -- 4699
				self:sy(footY + 1, h), -- 4699
				self:px(3), -- 4699
				self:px(3) -- 4699
			), -- 4699
			STAND -- 4699
		) -- 4699
	end -- 4699
	drawFigure( -- 4701
		draw, -- 4701
		self, -- 4701
		w, -- 4701
		h, -- 4701
		p, -- 4701
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4701
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4701
	) -- 4701
	local q = self.partner -- 4702
	if q.alive then -- 4702
		local childPartner = q.w == CHILD_W -- 4704
		drawFigure( -- 4705
			draw, -- 4705
			self, -- 4705
			w, -- 4705
			h, -- 4705
			q, -- 4705
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4705
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4705
		) -- 4705
	end -- 4705
	local i = 0 -- 4707
	do -- 4707
		i = 0 -- 4708
		while i < #self.enemies do -- 4708
			local e = self.enemies[i + 1] -- 4709
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4710
			local enemyY = e.y + (e.depth or 0) -- 4711
			self:drawBox( -- 4712
				draw, -- 4712
				w, -- 4712
				h, -- 4712
				e.x - e.w / 2, -- 4712
				e.x + e.w / 2, -- 4712
				enemyY, -- 4712
				enemyY + e.h, -- 4712
				col -- 4712
			) -- 4712
			if e.alive then -- 4712
				local ef = p.x >= e.x and 1 or -1 -- 4714
				if e.kind == "shield" then -- 4714
					local sh = (e.shieldHp or 0) > 0 -- 4716
					draw:drawRect( -- 4717
						Rect( -- 4717
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4717
							self:sy(enemyY, h), -- 4717
							self:px(6), -- 4717
							self:px(64) -- 4717
						), -- 4717
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4718
					) -- 4718
				elseif e.kind == "breaker" then -- 4718
					draw:drawSegment( -- 4720
						Vec2( -- 4720
							self:sx(e.x + ef * 12, w), -- 4720
							self:sy(enemyY + 8, h) -- 4720
						), -- 4720
						Vec2( -- 4721
							self:sx(e.x + ef * 22, w), -- 4721
							self:sy(enemyY + 46, h) -- 4721
						), -- 4721
						self:px(3), -- 4721
						Color(0.5, 0.36, 0.22, 1) -- 4721
					) -- 4721
				end -- 4721
			end -- 4721
			if e.alive and e.warnT > 0 then -- 4721
				local gunX = self:sx(e.x, w) -- 4726
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4727
				local aimX = self:sx(p.x, w) -- 4728
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4729
				local seg = 8 -- 4730
				local s = 0 -- 4731
				do -- 4731
					s = 0 -- 4732
					while s < seg do -- 4732
						local t0 = s / seg -- 4733
						local t1 = (s + 1) / seg -- 4734
						draw:drawSegment( -- 4735
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4736
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4737
							self:px(1), -- 4738
							DANGER -- 4738
						) -- 4738
						s = s + 2 -- 4732
					end -- 4732
				end -- 4732
			end -- 4732
			i = i + 1 -- 4708
		end -- 4708
	end -- 4708
	local k = 0 -- 4743
	do -- 4743
		k = 0 -- 4744
		while k < #self.room.marks do -- 4744
			do -- 4744
				local m = self.room.marks[k + 1] -- 4745
				if m.kind ~= 0 then -- 4745
					goto __continue884 -- 4747
				end -- 4747
				local on = self.checkpoint == m.x -- 4749
				local x = self:sx(m.x, w) -- 4750
				local y = self:sy(m.y, h) -- 4751
				draw:drawSegment( -- 4752
					Vec2(x, y), -- 4752
					Vec2( -- 4752
						x, -- 4752
						y + self:px(35) -- 4752
					), -- 4752
					self:px(1), -- 4752
					on and CHECK or INK_DIM -- 4752
				) -- 4752
				draw:drawDot( -- 4753
					Vec2( -- 4753
						x, -- 4753
						y + self:px(35) -- 4753
					), -- 4753
					self:px(2), -- 4753
					on and CHECK or INK_DIM -- 4753
				) -- 4753
			end -- 4753
			::__continue884:: -- 4753
			k = k + 1 -- 4744
		end -- 4744
	end -- 4744
	local j = 0 -- 4757
	do -- 4757
		j = 0 -- 4758
		while j < #self.room.marks do -- 4758
			do -- 4758
				local m = self.room.marks[j + 1] -- 4759
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4759
					goto __continue887 -- 4761
				end -- 4761
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4761
					goto __continue887 -- 4765
				end -- 4765
				local col = STAND -- 4767
				if m.kind == 4 then -- 4767
					col = PASS_LINE -- 4769
				elseif m.kind == 5 then -- 4769
					col = BRICK_LINE -- 4771
				end -- 4771
				local mx = self:sx(m.x, w) -- 4773
				local my = self:sy(m.y, h) -- 4774
				draw:drawSegment( -- 4775
					Vec2(mx, my), -- 4775
					Vec2( -- 4775
						mx, -- 4775
						my + self:px(24) -- 4775
					), -- 4775
					self:px(1), -- 4775
					col -- 4775
				) -- 4775
			end -- 4775
			::__continue887:: -- 4775
			j = j + 1 -- 4758
		end -- 4758
	end -- 4758
	local t = 0 -- 4778
	do -- 4778
		t = 0 -- 4779
		while t < #self.room.marks do -- 4779
			do -- 4779
				local m = self.room.marks[t + 1] -- 4780
				if m.kind ~= 6 then -- 4780
					goto __continue893 -- 4782
				end -- 4782
				local mx = self:sx(m.x, w) -- 4784
				local my = self:sy(m.y, h) -- 4785
				draw:drawSegment( -- 4786
					Vec2(mx, my), -- 4786
					Vec2( -- 4786
						mx, -- 4786
						my + self:px(30) -- 4786
					), -- 4786
					self:px(1), -- 4786
					INK_DIM -- 4786
				) -- 4786
				self:drawBox( -- 4787
					draw, -- 4787
					w, -- 4787
					h, -- 4787
					m.x - 5, -- 4787
					m.x + 5, -- 4787
					m.y + 30, -- 4787
					m.y + 40, -- 4787
					CHECK -- 4787
				) -- 4787
			end -- 4787
			::__continue893:: -- 4787
			t = t + 1 -- 4779
		end -- 4779
	end -- 4779
	if self.room.key == "village" then -- 4779
		self:drawVillage(draw, w, h) -- 4790
	end -- 4790
	if self.room.key == "forest" then -- 4790
		self:drawDog(draw, w, h) -- 4793
	end -- 4793
end -- 4687
function Play.prototype.drawDog(self, draw, w, h) -- 4798
	local x = self.dogX -- 4799
	self:drawBox( -- 4800
		draw, -- 4800
		w, -- 4800
		h, -- 4800
		x - 14, -- 4800
		x + 14, -- 4800
		0, -- 4800
		20, -- 4800
		SCAV_BODY -- 4800
	) -- 4800
	self:drawBox( -- 4801
		draw, -- 4801
		w, -- 4801
		h, -- 4801
		x - 10, -- 4801
		x - 2, -- 4801
		20, -- 4801
		30, -- 4801
		SCAV_BODY -- 4801
	) -- 4801
	self:drawBox( -- 4802
		draw, -- 4802
		w, -- 4802
		h, -- 4802
		x + 2, -- 4802
		x + 10, -- 4802
		20, -- 4802
		30, -- 4802
		SCAV_HEAD -- 4802
	) -- 4802
	if self.dogState == "ear" or self.dogState == "chase" then -- 4802
		draw:drawSegment( -- 4804
			Vec2( -- 4804
				self:sx(x, w), -- 4804
				self:sy(30, h) -- 4804
			), -- 4804
			Vec2( -- 4805
				self:sx(x, w), -- 4805
				self:sy(40, h) -- 4805
			), -- 4805
			self:px(1), -- 4805
			DANGER -- 4805
		) -- 4805
	end -- 4805
end -- 4798
function Play.prototype.drawVillage(self, draw, w, h) -- 4810
	local bottle = self.room.bottle -- 4811
	if bottle ~= nil then -- 4811
		self:drawBox( -- 4813
			draw, -- 4813
			w, -- 4813
			h, -- 4813
			bottle.x - 14, -- 4813
			bottle.x + 14, -- 4813
			0, -- 4813
			64, -- 4813
			SOLID_FILL -- 4813
		) -- 4813
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4813
			self:drawBottle( -- 4815
				draw, -- 4815
				w, -- 4815
				h, -- 4815
				bottle.x, -- 4815
				64 -- 4815
			) -- 4815
		end -- 4815
	end -- 4815
	self:drawBox( -- 4819
		draw, -- 4819
		w, -- 4819
		h, -- 4819
		300, -- 4819
		420, -- 4819
		44, -- 4819
		50, -- 4819
		FLOOR_DECK -- 4819
	) -- 4819
	self:drawBox( -- 4820
		draw, -- 4820
		w, -- 4820
		h, -- 4820
		300, -- 4820
		306, -- 4820
		0, -- 4820
		44, -- 4820
		FLOOR_DECK -- 4820
	) -- 4820
	self:drawBox( -- 4821
		draw, -- 4821
		w, -- 4821
		h, -- 4821
		414, -- 4821
		420, -- 4821
		0, -- 4821
		44, -- 4821
		FLOOR_DECK -- 4821
	) -- 4821
	local s = self.room.scavenger -- 4823
	if s ~= nil then -- 4823
		local sx0 = self.scavX -- 4825
		self:drawBox( -- 4826
			draw, -- 4826
			w, -- 4826
			h, -- 4826
			sx0 - 12, -- 4826
			sx0 + 12, -- 4826
			0, -- 4826
			s.h - 14, -- 4826
			SCAV_BODY -- 4826
		) -- 4826
		self:drawBox( -- 4827
			draw, -- 4827
			w, -- 4827
			h, -- 4827
			sx0 - 7, -- 4827
			sx0 + 7, -- 4827
			s.h - 14, -- 4827
			s.h, -- 4827
			SCAV_HEAD -- 4827
		) -- 4827
		if self.scavState == "turn" then -- 4827
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4829
			draw:drawSegment( -- 4830
				Vec2( -- 4830
					self:sx(sx0, w), -- 4830
					self:sy(s.h - 6, h) -- 4830
				), -- 4830
				Vec2( -- 4830
					self:sx(fx, w), -- 4830
					self:sy(s.h - 6, h) -- 4830
				), -- 4830
				self:px(1), -- 4830
				INK -- 4830
			) -- 4830
		end -- 4830
	end -- 4830
	if self.hasBottle then -- 4830
		local p = self.player -- 4835
		self:drawBottle( -- 4836
			draw, -- 4836
			w, -- 4836
			h, -- 4836
			p.x + p.facing * 10, -- 4836
			p.y + p.h * 0.62 -- 4836
		) -- 4836
	end -- 4836
	if self.bottleFly ~= nil then -- 4836
		self:drawBottle( -- 4839
			draw, -- 4839
			w, -- 4839
			h, -- 4839
			self.bottleFly.x, -- 4839
			self.bottleFly.y -- 4839
		) -- 4839
	end -- 4839
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 4839
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 4842
		draw:drawCircle( -- 4843
			Vec2( -- 4843
				self:sx(self.bottleLandX, w), -- 4843
				self:sy(0, h) -- 4843
			), -- 4843
			self:px(r / ____exports.UNITS_PER_PX), -- 4843
			BRICK_LINE -- 4843
		) -- 4843
	end -- 4843
end -- 4810
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 4847
	self:drawBox( -- 4848
		draw, -- 4848
		w, -- 4848
		h, -- 4848
		x - 3, -- 4848
		x + 3, -- 4848
		y - 10, -- 4848
		y, -- 4848
		BOTTLE -- 4848
	) -- 4848
end -- 4847
function Play.prototype.drawTrace(self, draw, w, h) -- 4851
	local t = self.trace -- 4852
	if t == nil or self.traceT <= 0 then -- 4852
		return -- 4854
	end -- 4854
	draw:drawSegment( -- 4856
		Vec2( -- 4857
			self:sx(t.x0, w), -- 4857
			self:sy(t.y0, h) -- 4857
		), -- 4857
		Vec2( -- 4858
			self:sx(t.x1, w), -- 4858
			self:sy(t.y1, h) -- 4858
		), -- 4858
		self:px(1), -- 4859
		t.hit and AIM_HIT or INK_DIM -- 4859
	) -- 4859
end -- 4851
function Play.prototype.drawAim(self, draw, w, h) -- 4862
	local v = self.view -- 4864
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 4865
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 4866
	local dot = self:px(1) -- 4867
	local arm = self:px(3) -- 4868
	local gap = self:px(1) -- 4869
	draw:drawSegment( -- 4870
		Vec2(gx - arm - gap, gy), -- 4870
		Vec2(gx - gap, gy), -- 4870
		dot / 2, -- 4870
		AIM -- 4870
	) -- 4870
	draw:drawSegment( -- 4871
		Vec2(gx + gap, gy), -- 4871
		Vec2(gx + arm + gap, gy), -- 4871
		dot / 2, -- 4871
		AIM -- 4871
	) -- 4871
	draw:drawSegment( -- 4872
		Vec2(gx, gy - arm - gap), -- 4872
		Vec2(gx, gy - gap), -- 4872
		dot / 2, -- 4872
		AIM -- 4872
	) -- 4872
	draw:drawSegment( -- 4873
		Vec2(gx, gy + gap), -- 4873
		Vec2(gx, gy + arm + gap), -- 4873
		dot / 2, -- 4873
		AIM -- 4873
	) -- 4873
	if self.room.key == "village" and self.hasBottle then -- 4873
		local p = self.player -- 4877
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4879
		local dir = ____end.x >= p.x and 1 or -1 -- 4880
		local x0 = p.x + dir * 10 -- 4881
		local y0 = p.y + p.h * 0.7 -- 4882
		local T = BOTTLE_FLY_TIME -- 4883
		local vx = (____end.x - x0) / T -- 4884
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 4885
		local pxr = x0 -- 4886
		local pyr = y0 -- 4887
		local t = 1 -- 4888
		do -- 4888
			t = 1 -- 4889
			while t <= 12 do -- 4889
				local tt = t / 12 * T -- 4890
				local nx = x0 + vx * tt -- 4891
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 4892
				draw:drawSegment( -- 4893
					Vec2( -- 4893
						self:sx(pxr, w), -- 4893
						self:sy(pyr, h) -- 4893
					), -- 4893
					Vec2( -- 4893
						self:sx(nx, w), -- 4893
						self:sy(ny, h) -- 4893
					), -- 4893
					self:px(1) / 2, -- 4893
					BOTTLE -- 4893
				) -- 4893
				pxr = nx -- 4894
				pyr = ny -- 4895
				t = t + 1 -- 4889
			end -- 4889
		end -- 4889
		draw:drawCircle( -- 4897
			Vec2( -- 4897
				self:sx(____end.x, w), -- 4897
				self:sy(____end.y + 2, h) -- 4897
			), -- 4897
			self:px(2), -- 4897
			BOTTLE -- 4897
		) -- 4897
	end -- 4897
end -- 4862
return ____exports -- 4862