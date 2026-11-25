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
function makeActor(room, index) -- 4916
	local sp = room.spawns -- 4917
	if index < 0 or index >= #sp then -- 4917
		return { -- 4919
			x = 0, -- 4919
			y = 0, -- 4919
			depth = 0, -- 4919
			depthSpeed = 0, -- 4919
			vx = 0, -- 4919
			vy = 0, -- 4919
			w = CHILD_W, -- 4919
			h = CHILD_H, -- 4919
			onGround = true, -- 4919
			facing = 1, -- 4919
			crouch = false, -- 4919
			rollT = 0, -- 4919
			covered = false, -- 4919
			alive = false -- 4919
		} -- 4919
	end -- 4919
	local s = sp[index + 1] -- 4921
	local child = s.h <= CHILD_H -- 4922
	local ground = room.depth -- 4923
	local depth = ground == nil and 0 or math.max( -- 4924
		ground.min, -- 4924
		math.min(ground.max, s.depth or 0) -- 4924
	) -- 4924
	return { -- 4925
		x = s.x, -- 4926
		y = s.y, -- 4926
		depth = depth, -- 4926
		depthSpeed = 0, -- 4926
		vx = 0, -- 4926
		vy = 0, -- 4926
		w = child and CHILD_W or SOLDIER_W, -- 4927
		h = child and CHILD_H or SOLDIER_H, -- 4928
		onGround = true, -- 4929
		facing = 1, -- 4929
		crouch = false, -- 4929
		rollT = 0, -- 4929
		covered = false, -- 4929
		alive = true -- 4929
	} -- 4929
end -- 4929
function drawFigure(draw, play, w, h, a, body, head) -- 4933
	if not a.alive then -- 4933
		return -- 4935
	end -- 4935
	local x0 = a.x - a.w / 2 -- 4937
	local x1 = a.x + a.w / 2 -- 4938
	local y0 = a.y + a.depth -- 4939
	local y1 = y0 + a.h -- 4940
	play:drawBox( -- 4941
		draw, -- 4941
		w, -- 4941
		h, -- 4941
		x0, -- 4941
		x1, -- 4941
		y0, -- 4941
		y1 - a.h * 0.26, -- 4941
		body -- 4941
	) -- 4941
	play:drawBox( -- 4942
		draw, -- 4942
		w, -- 4942
		h, -- 4942
		x0 + 2, -- 4942
		x1 - 2, -- 4942
		y1 - a.h * 0.26, -- 4942
		y1, -- 4942
		head -- 4942
	) -- 4942
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 4944
	play:drawBox( -- 4945
		draw, -- 4945
		w, -- 4945
		h, -- 4945
		eyeX, -- 4945
		eyeX + 4, -- 4945
		y1 - a.h * 0.14, -- 4945
		y1 - a.h * 0.08, -- 4945
		INK -- 4945
	) -- 4945
end -- 4945
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 4949
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 4950
end -- 4949
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 4957
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 4958
end -- 4957
function rayInterval(origin, direction, min, max) -- 4965
	if direction == 0 then -- 4965
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 4967
	end -- 4967
	local a = (min - origin) / direction -- 4969
	local b = (max - origin) / direction -- 4970
	return { -- 4971
		min = math.min(a, b), -- 4971
		max = math.max(a, b) -- 4971
	} -- 4971
end -- 4971
function hitBox(ray, box) -- 4975
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 4976
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 4977
	local enter = math.max(0, x.min, y.min) -- 4978
	local leave = math.min(99999, x.max, y.max) -- 4979
	if box.depth ~= nil then -- 4979
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 4981
		enter = math.max(enter, depth.min) -- 4982
		leave = math.min(leave, depth.max) -- 4983
	end -- 4983
	return leave >= enter and enter or -1 -- 4985
end -- 4985
function drawCartShape(draw, play, w, h, c, axleX) -- 4988
	local half = c.bodyW / 2 -- 4989
	local x0 = axleX - half -- 4990
	local x1 = axleX + half -- 4991
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 4992
	play:drawBox( -- 4993
		draw, -- 4993
		w, -- 4993
		h, -- 4993
		x0, -- 4993
		x1, -- 4993
		axleY, -- 4993
		axleY + c.bodyH, -- 4993
		CART_FILL -- 4993
	) -- 4993
	draw:drawCircle( -- 4994
		Vec2( -- 4994
			play:sx(x0 + c.bodyW * 0.28, w), -- 4994
			play:sy(axleY, h) -- 4994
		), -- 4994
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4994
		Color(52, 50, 48, 255) -- 4994
	) -- 4994
	draw:drawCircle( -- 4995
		Vec2( -- 4995
			play:sx(x1 - c.bodyW * 0.28, w), -- 4995
			play:sy(axleY, h) -- 4995
		), -- 4995
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 4995
		Color(52, 50, 48, 255) -- 4995
	) -- 4995
	local cx = c.clothSide < 0 and x0 or x1 -- 4996
	play:drawBox( -- 4997
		draw, -- 4997
		w, -- 4997
		h, -- 4997
		cx - 10, -- 4997
		cx + 10, -- 4997
		axleY + c.bodyH, -- 4997
		axleY + c.bodyH + 18, -- 4997
		CLOTH -- 4997
	) -- 4997
end -- 4997
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
function Play.prototype.____constructor(self, room, resume, run) -- 585
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
	self.endingLines = {"", ""} -- 493
	self.equippedWeapon = "standard_gun" -- 497
	self.craftBench = { -- 499
		active = false, -- 500
		firstCraftDone = false, -- 501
		justCraftedTimer = 0, -- 502
		inventory = {}, -- 503
		recipes = {}, -- 504
		equippedWeapon = "standard_gun" -- 505
	} -- 505
	self.handledCraftRequests = {} -- 508
	self.benchReach = 48 -- 510
	self.pickups = {} -- 514
	self.reloadT = 0 -- 516
	self.objectiveDone = false -- 520
	self.hint = "" -- 522
	self.roomStartTick = 0 -- 524
	self.cartHitT = 0 -- 526
	self.cartExposed = false -- 527
	self.storyRoute = "" -- 531
	self.storySettled = false -- 533
	self.hpAtGate = -1 -- 535
	self.maxHpAtGate = -1 -- 536
	self.handTicks = 0 -- 538
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 540
	self.handArmed = false -- 542
	self.handDone = false -- 544
	self.lineSaid = false -- 545
	self.tied = false -- 547
	self.pathDone = false -- 549
	self.carryOn = false -- 551
	self.escortDone = false -- 553
	self.reloadOpen = false -- 557
	self.reloadAnswerTicks = 0 -- 559
	self.reloadWorldTicks = 0 -- 561
	self.reloadPath = {RELOAD_START} -- 563
	self.reloadPendingEffect = "" -- 565
	self.reloadTryCount = 0 -- 567
	self.paused = false -- 569
	self.ticks = 0 -- 571
	self.view = {zoom = 1, ox = 0, oy = 0} -- 573
	self.ox = 0 -- 575
	self.aimX = 0 -- 577
	self.aimY = 0 -- 578
	self.viewW = 0 -- 580
	self.viewH = 0 -- 581
	self.ox = room.originX -- 587
	self.room = withOrigin(room) -- 588
	local wr = self.room -- 589
	self.run = run or createRun() -- 590
	self.inventory = self.run.inventory -- 591
	self.archive = self.run.archive -- 592
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 593
	self.isCampaign = wr.campaign ~= nil -- 594
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 595
	self:buildWorld() -- 596
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 599
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 601
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 602
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 604
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 605
	self.player = makeActor(wr, playerIdx) -- 606
	self.partner = makeActor(wr, partnerIdx) -- 607
	self.phase = phaseOf(wr.key) -- 608
	if wr.story ~= nil then -- 608
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 610
	end -- 610
	self.cam.x = self.player.x -- 612
	self.cam.y = self.player.y + CAM_LOOK_UP -- 613
	self.cartAxle = wr.cart.startX -- 614
	self.escort = __TS__New( -- 615
		Escort, -- 615
		safeAnchorX(wr.marks) -- 615
	) -- 615
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 616
	if self.isCampaign then -- 616
		self:setupCampaign() -- 618
	else -- 618
		self:buildEnemies() -- 620
	end -- 620
	if resume ~= nil and resume.checkpoint > 0 then -- 620
		self.checkpoint = resume.checkpoint -- 624
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 624
			self.cartAxle = self.room.cart.endX -- 626
			self.cartDocked = true -- 627
			self.player.x = self.ox + 380 -- 630
			self.player.y = 0 -- 631
			self.player.vy = 0 -- 632
			self.player.onGround = true -- 633
			self.cam.x = self.player.x -- 634
			self.cam.y = self.player.y + CAM_LOOK_UP -- 635
		end -- 635
	end -- 635
	self:restoreStory() -- 638
end -- 585
function Play.prototype.recipeViews(self) -- 651
	local out = {} -- 652
	local i = 0 -- 653
	do -- 653
		i = 0 -- 654
		while i < #CRAFT_RECIPES do -- 654
			local r = CRAFT_RECIPES[i + 1] -- 655
			local cost = {} -- 656
			if r.cost.wood ~= nil then -- 656
				cost.wood = r.cost.wood -- 658
			end -- 658
			if r.cost.bell ~= nil then -- 658
				cost.bell = r.cost.bell -- 661
			end -- 661
			out[#out + 1] = { -- 663
				id = r.id, -- 664
				name = r.name, -- 665
				desc = r.desc, -- 666
				enhancedEffect = r.enhancedEffect, -- 667
				cost = cost, -- 668
				crafted = self.run.story.craftedWeapon == r.id -- 669
			} -- 669
			i = i + 1 -- 654
		end -- 654
	end -- 654
	return out -- 672
end -- 651
function Play.prototype.syncCraftBench(self) -- 676
	local view = self.craftBench -- 677
	local inv = self.run.inventory -- 678
	view.inventory = { -- 679
		wood = inv.wood, -- 679
		bell = inv.bell, -- 679
		scrap = inv.scrap, -- 679
		wedge = inv.wedge, -- 679
		ammo = inv.ammo -- 679
	} -- 679
	view.recipes = self:recipeViews() -- 680
	view.equippedWeapon = self.equippedWeapon -- 681
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 682
	if view.justCraftedTimer > 0 then -- 682
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 684
	end -- 684
end -- 676
function Play.prototype.openCraftBench(self) -- 689
	if self.room.key ~= "escort3" or self.craftBench.active then -- 689
		return -- 691
	end -- 691
	self.craftBench.active = true -- 693
	self.carryOn = false -- 694
	self.run.story.carry = false -- 695
	self.player.vx = 0 -- 696
	self.player.vy = 0 -- 697
	self.craftBench.justCraftedTimer = 0 -- 698
	self:syncCraftBench() -- 699
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 700
	self:log("开工台") -- 701
	self:emit( -- 702
		"benchOpen", -- 702
		{ -- 702
			recipes = __TS__ArrayMap( -- 703
				self.craftBench.recipes, -- 703
				function(____, r) return r.id end -- 703
			), -- 703
			inventory = self.craftBench.inventory, -- 704
			carry = self.carryOn -- 705
		} -- 705
	) -- 705
end -- 689
function Play.prototype.closeCraftBench(self) -- 710
	if not self.craftBench.active then -- 710
		return -- 712
	end -- 712
	self.craftBench.active = false -- 714
	self.craftBench.justCraftedTimer = 0 -- 715
	self.carryOn = true -- 716
	self.run.story.carry = true -- 717
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 718
	self:log("离站背起") -- 719
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 720
end -- 710
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 727
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 727
		return false -- 729
	end -- 729
	local recipe = findRecipe(recipeId) -- 731
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 731
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 733
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 734
		return false -- 735
	end -- 735
	local missing = missingMaterials(self.run.inventory, recipe) -- 737
	if #missing > 0 then -- 737
		self:flashSet( -- 739
			"缺料 · " .. table.concat(missing, " / "), -- 739
			1.6 -- 739
		) -- 739
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 740
		return false -- 741
	end -- 741
	payMaterials(self.run.inventory, recipe) -- 743
	self.handledCraftRequests[requestId] = true -- 744
	self.run.story.craftedWeapon = recipe.id -- 745
	self.equippedWeapon = recipe.id -- 746
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 747
	self.craftBench.firstCraftDone = true -- 748
	self:syncCraftBench() -- 749
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 750
	self:log("改制 " .. recipe.id) -- 751
	self:emit("benchCraft", { -- 752
		recipeId = recipe.id, -- 753
		weapon = recipe.id, -- 754
		effect = recipe.enhancedEffect, -- 755
		wood = self.run.inventory.wood, -- 756
		bell = self.run.inventory.bell -- 757
	}) -- 757
	return true -- 759
end -- 727
function Play.prototype.equipWeapon(self, weaponId) -- 763
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 763
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 765
		return false -- 766
	end -- 766
	self.equippedWeapon = weaponId -- 768
	self:syncCraftBench() -- 769
	self:flashSet( -- 770
		"已装备 " .. weaponNameOf(weaponId), -- 770
		1 -- 770
	) -- 770
	self:emit("benchEquip", {weapon = weaponId}) -- 771
	return true -- 772
end -- 763
function Play.prototype.submitFeIntent(self, intent) -- 779
	local kind = intent == nil and "" or intent.kind -- 780
	if kind == "reloadTapNode" then -- 780
		local node = intent.node -- 782
		if type(node) == "number" then -- 782
			self:reloadTapNode(node) -- 784
			return true -- 785
		end -- 785
		return false -- 787
	end -- 787
	if kind == "reloadPathCommit" then -- 787
		local path = intent.path -- 790
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 790
			local list = path -- 792
			local i = 0 -- 793
			do -- 793
				i = 0 -- 794
				while i < #list do -- 794
					do -- 794
						if i == 0 and list[i + 1] == RELOAD_START then -- 794
							goto __continue46 -- 796
						end -- 796
						self:reloadTapNode(list[i + 1]) -- 798
					end -- 798
					::__continue46:: -- 798
					i = i + 1 -- 794
				end -- 794
			end -- 794
			return true -- 800
		end -- 800
		return false -- 802
	end -- 802
	if kind == "reloadCancel" then -- 802
		self:closeReloadPuzzle() -- 805
		return true -- 806
	end -- 806
	if kind == "craftSubmit" then -- 806
		local recipeId = intent.recipeId -- 809
		local requestId = intent.requestId -- 810
		if type(recipeId) == "string" and type(requestId) == "string" then -- 810
			return self:craftAtBench(recipeId, requestId) -- 812
		end -- 812
		return false -- 814
	end -- 814
	if kind == "craftEquip" then -- 814
		local weaponId = intent.weaponId -- 817
		if type(weaponId) == "string" then -- 817
			return self:equipWeapon(weaponId) -- 819
		end -- 819
		return false -- 821
	end -- 821
	if kind == "craftClose" then -- 821
		self:closeCraftBench() -- 824
		return true -- 825
	end -- 825
	return false -- 827
end -- 779
function Play.prototype.captureCheckpoint(self, id) -- 831
	local inv = self.run.inventory -- 832
	self.checkpointSnap = { -- 833
		id = id, -- 834
		wood = inv.wood, -- 835
		bell = inv.bell, -- 836
		scrap = inv.scrap, -- 837
		wedge = inv.wedge, -- 838
		ammo = inv.ammo, -- 839
		shield = inv.shield, -- 840
		pass = inv.pass, -- 841
		quickbelt = inv.quickbelt, -- 842
		crafted = self.run.story.craftedWeapon, -- 843
		equipped = self.equippedWeapon, -- 844
		carry = self.carryOn -- 845
	} -- 845
	self.run.story.cp = self.checkpointSnap -- 847
end -- 831
function Play.prototype.applyCheckpointSnap(self, id) -- 851
	local snap = self.run.story.cp -- 852
	if snap == nil or snap.id ~= id then -- 852
		return false -- 854
	end -- 854
	self.checkpointSnap = snap -- 856
	local inv = self.run.inventory -- 857
	inv.wood = snap.wood -- 858
	inv.bell = snap.bell -- 859
	inv.scrap = snap.scrap -- 860
	inv.wedge = snap.wedge -- 861
	inv.ammo = snap.ammo -- 862
	inv.shield = snap.shield -- 863
	inv.pass = snap.pass -- 864
	inv.quickbelt = snap.quickbelt -- 865
	self.run.story.craftedWeapon = snap.crafted -- 866
	self.equippedWeapon = snap.equipped -- 867
	self.carryOn = snap.carry -- 868
	self.run.story.carry = snap.carry -- 869
	self.craftBench.active = false -- 870
	self:syncCraftBench() -- 871
	return true -- 872
end -- 851
function Play.prototype.restoreStory(self) -- 875
	if self.isCampaign and self.run.trial ~= nil then -- 875
		return -- 879
	end -- 879
	local story = self.run.story -- 881
	if story == nil then -- 881
		return -- 883
	end -- 883
	if story.maxHp > 0 then -- 883
		self.maxHp = story.maxHp -- 886
		self.hp = math.max( -- 887
			1, -- 887
			math.min(story.hp, story.maxHp) -- 887
		) -- 887
	end -- 887
	self.storyRoute = story.route -- 889
	self.storySettled = story.settled -- 890
	self.hpAtGate = story.hpAtGate -- 891
	self.maxHpAtGate = story.maxHpAtGate -- 892
	self.handDone = story.handDone -- 893
	self.lineSaid = story.lineSaid -- 894
	self.tied = story.handDone -- 895
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 896
	self.escortDone = story.escortDone -- 897
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 898
	self:syncCraftBench() -- 899
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 899
		self:applyCheckpointSnap(self.checkpoint) -- 902
	end -- 902
	if self.room.key == "tower" and story.route == "soldier" then -- 902
		self.carryOn = false -- 906
		self.run.story.carry = false -- 907
	end -- 907
	if self.room.key ~= "gate" then -- 907
		return -- 910
	end -- 910
	local ____temp_0 -- 912
	if self.room.story == nil then -- 912
		____temp_0 = nil -- 912
	else -- 912
		____temp_0 = self.room.story.gate -- 912
	end -- 912
	local g = ____temp_0 -- 912
	if g == nil then -- 912
		return -- 914
	end -- 914
	if story.phase == "gate-send" then -- 914
		self.phase = "gate-send" -- 918
		self.gateTick = g.holdTicks -- 919
		self.gateSpawned = 4 -- 920
		self.enemies = {} -- 921
		self.player.x = self.ox + g.doorX - 40 -- 922
		self.player.y = 0 -- 923
		self.player.depth = 0 -- 924
		self.player.vx = 0 -- 925
		self.player.vy = 0 -- 926
		self.player.onGround = true -- 927
		self.partner.x = self.ox + g.waitX -- 928
		self.partner.y = 0 -- 929
		self.partner.depth = 0 -- 930
		self.partner.alive = true -- 931
		self.cam.x = self.player.x -- 932
		self.handTicks = 0 -- 933
		self.handArmed = false -- 934
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 935
		return -- 936
	end -- 936
	if not story.settled then -- 936
		return -- 939
	end -- 939
	self.gateTick = g.holdTicks -- 942
	self.gateSpawned = 4 -- 943
	self.enemies = {} -- 944
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 944
		self.phase = story.phase -- 946
		self.countTick = math.max(story.countTick, 0) -- 947
		self:swapToChild(g.doorX + 30) -- 948
		self.countPrevMove = 0 -- 949
		self.countArmed = false -- 950
		return -- 951
	end -- 951
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 951
		self.phase = story.phase -- 954
		self.countTick = ____exports.GATE_COUNT_END -- 955
		self.phaseTick = story.phaseTick -- 956
		self:swapToChild(g.doorX + 30) -- 957
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 958
			0, -- 958
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 958
		) -- 958
		self.handArmed = false -- 959
	end -- 959
end -- 875
function Play.prototype.buildWorld(self) -- 964
	local room = self.room -- 965
	self.boxes = {} -- 966
	self.floors = {} -- 967
	local i = 0 -- 968
	do -- 968
		i = 0 -- 969
		while i < #room.floors do -- 969
			local f = room.floors[i + 1] -- 970
			local ____self_floors_1 = self.floors -- 970
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 971
			i = i + 1 -- 969
		end -- 969
	end -- 969
	do -- 969
		i = 0 -- 973
		while i < #room.solids do -- 973
			local s = room.solids[i + 1] -- 974
			if not s.decorative then -- 974
				local ____self_boxes_13 = self.boxes -- 980
				local ____s_x_4 = s.x -- 981
				local ____temp_5 = s.x + s.w -- 981
				local ____s_y_6 = s.y -- 981
				local ____temp_7 = s.y + s.h -- 981
				local ____temp_2 -- 982
				if room.depth == nil then -- 982
					____temp_2 = nil -- 982
				else -- 982
					____temp_2 = s.depth -- 982
				end -- 982
				local ____temp_8 = s.passable == true -- 983
				local ____s_label_9 = s.label -- 983
				local ____s_id_10 = s.id -- 984
				local ____temp_11 = s.soft == true -- 984
				local ____temp_12 = s.hidden == true -- 984
				local ____temp_3 -- 985
				if s.breakable == nil then -- 985
					____temp_3 = nil -- 985
				else -- 985
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 985
				end -- 985
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 980
					x0 = ____s_x_4, -- 981
					x1 = ____temp_5, -- 981
					y0 = ____s_y_6, -- 981
					y1 = ____temp_7, -- 981
					depth = ____temp_2, -- 982
					passable = ____temp_8, -- 983
					label = ____s_label_9, -- 983
					id = ____s_id_10, -- 984
					soft = ____temp_11, -- 984
					hidden = ____temp_12, -- 984
					breakable = ____temp_3, -- 985
					interact = s.interact -- 986
				} -- 986
			end -- 986
			i = i + 1 -- 973
		end -- 973
	end -- 973
	do -- 973
		i = 0 -- 990
		while i < #room.stairs do -- 990
			local st = room.stairs[i + 1] -- 991
			local n = st.steps + 1 -- 992
			local stepW = (st.x1 - st.x0) / n -- 993
			local k = 0 -- 994
			do -- 994
				k = 0 -- 995
				while k < n do -- 995
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 996
					local x0 = st.x0 + stepW * k -- 997
					local ____self_boxes_14 = self.boxes -- 997
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 999
						x0 = x0, -- 999
						x1 = x0 + stepW, -- 999
						y0 = -8, -- 999
						y1 = y, -- 999
						passable = true -- 999
					} -- 999
					k = k + 1 -- 995
				end -- 995
			end -- 995
			i = i + 1 -- 990
		end -- 990
	end -- 990
end -- 964
function Play.prototype.setupCampaign(self) -- 1008
	local wr = self.room -- 1009
	local c = wr.campaign -- 1010
	if c == nil then -- 1010
		return -- 1012
	end -- 1012
	self.roomStartTick = self.run.ticks -- 1014
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1014
		self.run.joined = true -- 1018
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1018
		local ____self_run_16 = self.run -- 1021
		local ____temp_15 -- 1021
		if wr.key == "s2-drygoods" then -- 1021
			____temp_15 = self.run.route ~= "drygoods" -- 1021
		else -- 1021
			____temp_15 = false -- 1021
		end -- 1021
		____self_run_16.joined = ____temp_15 -- 1021
	end -- 1021
	local x = wr.minX + 60 -- 1023
	local y = 0 -- 1024
	local depth = 0 -- 1025
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1025
		x = wr.minX + 210 -- 1027
		depth = -32 -- 1028
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1028
		x = wr.minX + 40 -- 1030
		y = 32 -- 1031
		depth = 32 -- 1032
	end -- 1032
	self.player = { -- 1034
		x = x, -- 1035
		y = y, -- 1035
		depth = depth, -- 1035
		depthSpeed = 0, -- 1035
		vx = 0, -- 1035
		vy = 0, -- 1035
		w = SOLDIER_W, -- 1036
		h = SOLDIER_H, -- 1036
		onGround = y <= 0, -- 1036
		facing = 1, -- 1036
		crouch = false, -- 1036
		rollT = 0, -- 1036
		covered = false, -- 1036
		alive = true -- 1036
	} -- 1036
	self.partner = { -- 1038
		x = x + 60, -- 1039
		y = y, -- 1039
		depth = depth, -- 1039
		depthSpeed = 0, -- 1039
		vx = 0, -- 1039
		vy = 0, -- 1039
		w = CHILD_W, -- 1040
		h = CHILD_H, -- 1040
		onGround = y <= 0, -- 1040
		facing = 1, -- 1040
		crouch = false, -- 1040
		rollT = 0, -- 1040
		covered = false, -- 1040
		alive = true -- 1040
	} -- 1040
	self.cam.x = x -- 1042
	self.cam.y = y + CAM_LOOK_UP -- 1043
	self.phase = "run" -- 1044
	self.hp = self.maxHp -- 1045
	local trial = self.run.trial -- 1046
	if trial ~= nil then -- 1046
		draftRoom(trial, wr.key) -- 1048
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1049
		self.hp = trial.hp -- 1050
	end -- 1050
	self:buildEnemies() -- 1052
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1053
	local i = 0 -- 1054
	do -- 1054
		i = 0 -- 1055
		while i < #self.boxes do -- 1055
			do -- 1055
				local b = self.boxes[i + 1] -- 1056
				if b.id == nil then -- 1056
					goto __continue87 -- 1058
				end -- 1058
				local st = self.run.props[b.id] -- 1060
				if st ~= nil then -- 1060
					b.broken = st.broken -- 1062
					local ____temp_17 -- 1063
					if b.breakable == nil then -- 1063
						____temp_17 = nil -- 1063
					else -- 1063
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1063
					end -- 1063
					b.breakable = ____temp_17 -- 1063
					b.hidden = b.hidden == true and st.revealed ~= true -- 1064
					if b.hidden then -- 1064
						b.broken = true -- 1066
					end -- 1066
				elseif b.hidden == true then -- 1066
					b.broken = true -- 1070
				end -- 1070
			end -- 1070
			::__continue87:: -- 1070
			i = i + 1 -- 1055
		end -- 1055
	end -- 1055
	if wr.cart.bodyW > 0 then -- 1055
		self.cartAxle = wr.cart.startX -- 1074
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1074
			self.cartAxle = wr.cart.endX -- 1076
			self.cartDocked = true -- 1077
		end -- 1077
	end -- 1077
	do -- 1077
		i = 0 -- 1080
		while i < #self.pickups do -- 1080
			local pk = self.pickups[i + 1] -- 1081
			if self.run.taken[pk.id] == true then -- 1081
				pk.id = "" -- 1083
			end -- 1083
			i = i + 1 -- 1080
		end -- 1080
	end -- 1080
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1086
end -- 1008
function Play.prototype.log(self, line) -- 1089
	local ____self_run_log_18 = self.run.log -- 1089
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1090
	if #self.run.log > 120 then -- 1090
		table.remove(self.run.log, 1) -- 1092
	end -- 1092
end -- 1089
function Play.prototype.buildEnemies(self) -- 1096
	self.enemies = {} -- 1097
	if self.isCampaign then -- 1097
		local i = 0 -- 1099
		do -- 1099
			i = 0 -- 1100
			while i < #self.room.spawns do -- 1100
				local sp = self.room.spawns[i + 1] -- 1101
				local kind = sp.kind or "gunner" -- 1102
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1103
				local ____self_enemies_19 = self.enemies -- 1103
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1104
					x = sp.x, -- 1105
					y = sp.y, -- 1105
					depth = sp.depth, -- 1105
					w = 26, -- 1105
					h = sp.h, -- 1105
					alive = true, -- 1105
					hitT = 0, -- 1105
					warnT = 0, -- 1105
					fireCd = 40, -- 1105
					kind = kind, -- 1106
					shieldHp = hp, -- 1106
					shieldHpMax = hp, -- 1106
					drop = sp.drop or "none", -- 1106
					homeX = sp.x, -- 1107
					swingT = 0, -- 1107
					awake = false, -- 1107
					squad = i -- 1107
				} -- 1107
				i = i + 1 -- 1100
			end -- 1100
		end -- 1100
		return -- 1110
	end -- 1110
	if self.room.key == "checkpoint" then -- 1110
		local ____self_enemies_20 = self.enemies -- 1110
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1113
			x = self.ox + 430, -- 1113
			y = 0, -- 1113
			w = 26, -- 1113
			h = 84, -- 1113
			alive = true, -- 1113
			hitT = 0, -- 1113
			warnT = 0, -- 1113
			fireCd = 0 -- 1113
		} -- 1113
		local ____self_enemies_21 = self.enemies -- 1113
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1114
			x = self.ox + 505, -- 1114
			y = 0, -- 1114
			w = 26, -- 1114
			h = 84, -- 1114
			alive = true, -- 1114
			hitT = 0, -- 1114
			warnT = 0, -- 1114
			fireCd = 0 -- 1114
		} -- 1114
		return -- 1115
	end -- 1115
	if self.room.key == "street" then -- 1115
		local ____self_enemies_22 = self.enemies -- 1115
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1119
			x = self.ox + 340, -- 1119
			y = 0, -- 1119
			w = 26, -- 1119
			h = 84, -- 1119
			alive = true, -- 1119
			hitT = 0, -- 1119
			warnT = 0, -- 1119
			fireCd = 0 -- 1119
		} -- 1119
		local ____self_enemies_23 = self.enemies -- 1119
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1120
			x = self.ox + 560, -- 1120
			y = 0, -- 1120
			w = 26, -- 1120
			h = 84, -- 1120
			alive = true, -- 1120
			hitT = 0, -- 1120
			warnT = 0, -- 1120
			fireCd = 0 -- 1120
		} -- 1120
	end -- 1120
end -- 1096
function Play.prototype.emit(self, name, data) -- 1126
	local ____self_events_24 = self.events -- 1126
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1127
	self.eventSeq = self.eventSeq + 1 -- 1128
	if #self.events > 256 then -- 1128
		table.remove(self.events, 1) -- 1130
	end -- 1130
end -- 1126
function Play.prototype.drainEvents(self) -- 1138
	local out = self.events -- 1139
	self.events = {} -- 1140
	return out -- 1141
end -- 1138
function Play.prototype.adoptEvents(self, events) -- 1150
	if #events == 0 then -- 1150
		return -- 1152
	end -- 1152
	local keep = {} -- 1154
	local i = 0 -- 1155
	do -- 1155
		i = 0 -- 1156
		while i < #events do -- 1156
			do -- 1156
				local e = events[i + 1] -- 1157
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1157
					goto __continue111 -- 1159
				end -- 1159
				keep[#keep + 1] = e -- 1161
			end -- 1161
			::__continue111:: -- 1161
			i = i + 1 -- 1156
		end -- 1156
	end -- 1156
	if #keep == 0 then -- 1156
		return -- 1164
	end -- 1164
	self.events = __TS__ArrayConcat(keep, self.events) -- 1166
	do -- 1166
		i = 0 -- 1167
		while i < #self.events do -- 1167
			self.events[i + 1].seq = i -- 1168
			i = i + 1 -- 1167
		end -- 1167
	end -- 1167
	self.eventSeq = #self.events -- 1170
end -- 1150
function Play.prototype.chooseTalent(self, slot) -- 1173
	local trial = self.run.trial -- 1174
	local talent = trial and trial.offers[slot + 1] -- 1175
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1175
		return -- 1176
	end -- 1176
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1176
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1177
	trial.offers = {} -- 1178
	if talent == "vitality" then -- 1178
		self.maxHp = self.maxHp + 1 -- 1180
		self.hp = self.hp + 1 -- 1181
		trial.hp = self.hp -- 1182
	end -- 1182
	self:flashSet(talentNames[talent], 1.2) -- 1184
end -- 1173
function Play.prototype.beginReload(self) -- 1192
	self.reloadT = self:reloadTicks() -- 1193
	local camp = self.room.campaign -- 1194
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1194
		self:openReloadPuzzle() -- 1197
	end -- 1197
end -- 1192
function Play.prototype.openReloadPuzzle(self) -- 1202
	self.reloadOpen = true -- 1203
	self.reloadAnswerTicks = 0 -- 1204
	self.reloadWorldTicks = 0 -- 1205
	self.reloadPath = {RELOAD_START} -- 1206
	self.reloadPendingEffect = "" -- 1207
	self.reloadTryCount = self.reloadTryCount + 1 -- 1208
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1209
end -- 1202
function Play.prototype.closeReloadPuzzle(self) -- 1213
	self.reloadOpen = false -- 1214
	self.reloadAnswerTicks = 0 -- 1215
	self.reloadWorldTicks = 0 -- 1216
	self.reloadPath = {RELOAD_START} -- 1217
	self.reloadPendingEffect = "" -- 1218
end -- 1213
function Play.prototype.reloadTapNode(self, node) -- 1225
	if not self.reloadOpen then -- 1225
		return -- 1227
	end -- 1227
	local path = self.reloadPath -- 1229
	local last = path[#path] -- 1230
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1230
		self.reloadPath = {RELOAD_START} -- 1232
		self:emit("reloadInvalid", {node = node, at = last}) -- 1233
		return -- 1234
	end -- 1234
	path[#path + 1] = node -- 1236
	if node ~= RELOAD_TARGET then -- 1236
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1238
		return -- 1239
	end -- 1239
	if not reloadPathValid(path) then -- 1239
		self.reloadPath = {RELOAD_START} -- 1242
		self:emit("reloadInvalid", {node = node, at = last}) -- 1243
		return -- 1244
	end -- 1244
	self.reloadPendingEffect = reloadEffectOf(path) -- 1246
	self.reloadOpen = false -- 1247
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1248
	self:flashSet( -- 1251
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1251
		1.4 -- 1251
	) -- 1251
end -- 1225
function Play.prototype.consumeReloadEffect(self) -- 1255
	local e = self.reloadPendingEffect -- 1256
	if e ~= "" then -- 1256
		self.reloadPendingEffect = "" -- 1258
	end -- 1258
	return e -- 1260
end -- 1255
function Play.prototype.echoToSource(self, from, count) -- 1267
	if count == nil then -- 1267
		count = 1 -- 1267
	end -- 1267
	local best = -1 -- 1268
	local bestD = 1000000000 -- 1269
	local i = 0 -- 1270
	local woken = {} -- 1271
	local n = 0 -- 1272
	while n < count do -- 1272
		best = -1 -- 1274
		bestD = 1000000000 -- 1275
		do -- 1275
			i = 0 -- 1276
			while i < #self.enemies do -- 1276
				do -- 1276
					if woken[i] == true then -- 1276
						goto __continue133 -- 1278
					end -- 1278
					local e = self.enemies[i + 1] -- 1280
					if not e.alive then -- 1280
						goto __continue133 -- 1282
					end -- 1282
					local d = math.abs(e.x - from.x) -- 1284
					if d < bestD then -- 1284
						bestD = d -- 1286
						best = i -- 1287
					end -- 1287
				end -- 1287
				::__continue133:: -- 1287
				i = i + 1 -- 1276
			end -- 1276
		end -- 1276
		if best < 0 then -- 1276
			break -- 1291
		end -- 1291
		woken[best] = true -- 1293
		local e = self.enemies[best + 1] -- 1294
		e.awake = true -- 1295
		e.warnT = 0 -- 1296
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1297
		n = n + 1 -- 1298
	end -- 1298
	if n == 0 then -- 1298
		return -- 1301
	end -- 1301
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1303
end -- 1267
function Play.prototype.reloadTicks(self) -- 1306
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1307
	local ____opt_29 = self.run.trial -- 1307
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1307
end -- 1306
function Play.prototype.update(self, dt, input) -- 1310
	self:syncCraftBench() -- 1311
	local trial = self.run.trial -- 1312
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1312
		return -- 1313
	end -- 1313
	if input.pause.pressed then -- 1313
		self.paused = not self.paused -- 1315
	end -- 1315
	if self.flashT > 0 then -- 1315
		self.flashT = self.flashT - dt -- 1318
		if self.flashT <= 0 then -- 1318
			self.flash = "" -- 1320
		end -- 1320
	end -- 1320
	if self.traceT > 0 then -- 1320
		self.traceT = self.traceT - dt -- 1324
		if self.traceT <= 0 then -- 1324
			self.trace = nil -- 1326
		end -- 1326
	end -- 1326
	if self.paused then -- 1326
		self:updateCamera(dt) -- 1330
		return -- 1331
	end -- 1331
	if self.craftBench.active then -- 1331
		self:updateCamera(dt) -- 1335
		return -- 1336
	end -- 1336
	if self.reloadOpen then -- 1336
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1342
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1342
			self.reloadOpen = false -- 1344
			self.reloadPendingEffect = "" -- 1345
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1346
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1347
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1347
			self:updateCamera(dt) -- 1349
			return -- 1350
		else -- 1350
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1352
		end -- 1352
	end -- 1352
	self.ticks = self.ticks + 1 -- 1356
	if self.invulnT > 0 then -- 1356
		self.invulnT = self.invulnT - 1 -- 1360
	end -- 1360
	if self.isCampaign then -- 1360
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1360
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1363
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1364
	end -- 1364
	local p = self.player -- 1366
	self:stepPlayer(p, dt, input) -- 1367
	self:refreshCover(p, input) -- 1369
	if self.carryOn then -- 1369
		self:carryPose() -- 1371
	end -- 1371
	if self.isCampaign then -- 1371
		self:stepCampaign(dt, input) -- 1374
		if not self.carryOn then -- 1374
			self:stepCampaignPartner(dt) -- 1376
		end -- 1376
	end -- 1376
	if trial == nil or not self.run.finished then -- 1376
		self:stepEnemies(dt, input) -- 1384
	end -- 1384
	if trial ~= nil then -- 1384
		trial.hp = self.hp -- 1386
	end -- 1386
	if not self.isCampaign then -- 1386
		self:stepStory(dt, input) -- 1388
		self:stepEscort(dt, input) -- 1389
		self:stepVillage(dt, input) -- 1390
		self:stepChase(dt, input) -- 1391
		self:stepInteract(dt, input) -- 1392
	end -- 1392
	self:updateGate() -- 1394
	self:updateCamera(dt) -- 1395
	self:syncStory() -- 1397
end -- 1310
function Play.prototype.underLowArch(self, a) -- 1404
	local arch = self.room.arch -- 1405
	if arch.h <= 0 then -- 1405
		return false -- 1407
	end -- 1407
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1407
		return false -- 1410
	end -- 1410
	local top = arch.y + arch.h -- 1412
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1413
end -- 1404
function Play.prototype.coverAt(self, a) -- 1420
	local best = nil -- 1421
	local bestGap = 24 -- 1422
	local half = a.w / 2 -- 1423
	local i = 0 -- 1424
	do -- 1424
		i = 0 -- 1425
		while i < #self.boxes do -- 1425
			do -- 1425
				local b = self.boxes[i + 1] -- 1426
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1426
					goto __continue166 -- 1428
				end -- 1428
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1428
					goto __continue166 -- 1431
				end -- 1431
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1433
				if gap < bestGap then -- 1433
					bestGap = gap -- 1435
					best = b -- 1436
				end -- 1436
			end -- 1436
			::__continue166:: -- 1436
			i = i + 1 -- 1425
		end -- 1425
	end -- 1425
	return best -- 1439
end -- 1420
function Play.prototype.nearCover(self, a) -- 1442
	return self:coverAt(a) ~= nil -- 1443
end -- 1442
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1447
	if enemy == nil then -- 1447
		return false -- 1449
	end -- 1449
	local fromRight = enemy.x >= a.x -- 1451
	local edge = fromRight and b.x0 or b.x1 -- 1452
	local ____fromRight_34 -- 1453
	if fromRight then -- 1453
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1453
	else -- 1453
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1454
	end -- 1454
	local between = ____fromRight_34 -- 1453
	local separation = enemy.x - a.x -- 1455
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1456
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1457
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1458
end -- 1447
function Play.prototype.nearestEnemy(self, a) -- 1461
	local best -- 1462
	local bestD = 1000000000 -- 1463
	local i = 0 -- 1464
	do -- 1464
		i = 0 -- 1465
		while i < #self.enemies do -- 1465
			do -- 1465
				local e = self.enemies[i + 1] -- 1466
				if not e.alive then -- 1466
					goto __continue175 -- 1468
				end -- 1468
				local d = math.abs(e.x - a.x) -- 1470
				if d < bestD then -- 1470
					bestD = d -- 1472
					best = e -- 1473
				end -- 1473
			end -- 1473
			::__continue175:: -- 1473
			i = i + 1 -- 1465
		end -- 1465
	end -- 1465
	return best -- 1476
end -- 1461
function Play.prototype.refreshCover(self, a, input) -- 1480
	if self.childMode then -- 1480
		self.coverNear = false -- 1482
		self.coverHug = false -- 1483
		self.coverEntity = "" -- 1484
		self.coverBlocking = false -- 1485
		a.covered = false -- 1486
		return -- 1487
	end -- 1487
	local b = self:coverAt(a) -- 1489
	self.coverNear = b ~= nil -- 1490
	a.covered = self.coverNear and input.cover.held -- 1491
	self.coverHug = a.covered -- 1492
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1493
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1494
		b, -- 1494
		a, -- 1494
		self:nearestEnemy(a) -- 1494
	) -- 1494
end -- 1480
function Play.prototype.cartHandleInReach(self, a) -- 1498
	if a == nil then -- 1498
		a = self.player -- 1498
	end -- 1498
	local c = self.room.cart -- 1499
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1499
		return false -- 1501
	end -- 1501
	local handleX = self.cartAxle + c.handleOffset -- 1503
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1504
end -- 1498
function Play.prototype.nearLowLedge(self, a) -- 1509
	local reach = 26 -- 1510
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1511
	local x1 = x0 + reach -- 1512
	local i = 0 -- 1513
	do -- 1513
		i = 0 -- 1514
		while i < #self.boxes do -- 1514
			do -- 1514
				local b = self.boxes[i + 1] -- 1515
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1515
					goto __continue184 -- 1517
				end -- 1517
				local rise = b.y1 - a.y -- 1519
				if rise > 0 and rise <= LEDGE_RISE then -- 1519
					return true -- 1521
				end -- 1521
			end -- 1521
			::__continue184:: -- 1521
			i = i + 1 -- 1514
		end -- 1514
	end -- 1514
	return false -- 1524
end -- 1509
function Play.prototype.stepPlayer(self, a, dt, input) -- 1527
	a.depthSpeed = 0 -- 1528
	if not a.alive then -- 1528
		return -- 1530
	end -- 1530
	local isChild = self.childMode -- 1532
	local lowArch = isChild and self:underLowArch(a) -- 1534
	if self:storyLocked() then -- 1534
		a.vx = 0 -- 1537
		a.crouch = isChild and lowArch -- 1538
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1539
		self:fallY(a, dt) -- 1540
		return -- 1541
	end -- 1541
	if not isChild and self.escort.state == "calming" then -- 1541
		a.crouch = false -- 1545
		a.h = SOLDIER_H -- 1546
		a.vx = 0 -- 1547
		self:fallY(a, dt) -- 1548
		return -- 1549
	end -- 1549
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1551
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1552
	local nearCover = not isChild and self:nearCover(a) -- 1553
	a.covered = nearCover and input.cover.held -- 1554
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1556
	if a.rollT > 0 then -- 1556
		a.rollT = a.rollT - dt -- 1560
		a.vx = a.facing * ROLL_SPEED -- 1561
		self:slideX(a, a.vx * dt) -- 1562
		self:fallY(a, dt) -- 1563
		if a.rollT <= 0 then -- 1563
			self:flashSet("翻滚结束", 0.5) -- 1565
		end -- 1565
		return -- 1567
	end -- 1567
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1567
		if input.moveX ~= 0 then -- 1567
			a.facing = input.moveX > 0 and 1 or -1 -- 1572
		end -- 1572
		if self:nearLowLedge(a) then -- 1572
			a.vy = SOLDIER_JUMP -- 1576
			a.onGround = false -- 1577
			self:flashSet("翻上去", 0.3) -- 1578
			return -- 1579
		end -- 1579
		a.rollT = ROLL_TIME -- 1581
		self:flashSet("翻滚", 0.3) -- 1582
		return -- 1583
	end -- 1583
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1586
	if isChild then -- 1586
		if input.cover.held then -- 1586
			speed = CHILD_SLOW -- 1589
		end -- 1589
		if a.crouch then -- 1589
			speed = CHILD_SLOW -- 1592
		end -- 1592
	elseif a.covered then -- 1592
		speed = SOLDIER_SPEED * 0.45 -- 1595
	end -- 1595
	local handsBusy = self.gripping or gripIntent -- 1599
	local dir = self.gripping and 0 or input.moveX -- 1600
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1601
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1602
	if dir ~= 0 then -- 1602
		a.facing = dir > 0 and 1 or -1 -- 1604
	end -- 1604
	a.vx = dir * speed * diagonal -- 1606
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1606
		a.vy = CHILD_JUMP -- 1610
		a.onGround = false -- 1611
		self:flashSet("跳", 0.25) -- 1612
	end -- 1612
	local previousDepth = a.depth -- 1616
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1617
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1618
	self:slideX(a, a.vx * dt) -- 1619
	self:fallY(a, dt) -- 1620
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1620
		self:shoot(a) -- 1624
	end -- 1624
end -- 1527
function Play.prototype.stepPartner(self, p, dt) -- 1629
	local a = self.partner -- 1630
	if not a.alive then -- 1630
		return -- 1632
	end -- 1632
	a.crouch = false -- 1634
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1635
	a.vx = 0 -- 1636
	a.depthSpeed = 0 -- 1637
	self:fallY(a, dt) -- 1638
end -- 1629
function Play.prototype.stepEscort(self, dt, input) -- 1645
	local a = self.partner -- 1646
	a.depthSpeed = 0 -- 1647
	if not a.alive then -- 1647
		return -- 1649
	end -- 1649
	if self.room.key == "gatepath" then -- 1649
		if self.carryOn then -- 1649
			return -- 1654
		end -- 1654
		local p = self.player -- 1657
		a.depth = p.depth -- 1658
		a.facing = p.facing -- 1659
		a.crouch = false -- 1660
		a.h = CHILD_H -- 1661
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1662
		a.y = p.y -- 1663
		a.vy = 0 -- 1664
		a.vx = p.vx -- 1665
		a.onGround = p.onGround -- 1666
		return -- 1667
	end -- 1667
	if not self:escortOn() then -- 1667
		a.vx = 0 -- 1670
		self:fallY(a, dt) -- 1671
		return -- 1672
	end -- 1672
	local p = self.player -- 1674
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1675
	local hadKnock1 = self.escort.knock1 -- 1676
	local hadKnock2 = self.escort.knock2 -- 1677
	self.calmConsumed = self.escort:update( -- 1678
		input, -- 1678
		p.x, -- 1678
		p.facing, -- 1678
		a.x, -- 1678
		dist -- 1678
	) -- 1678
	if not hadKnock1 and self.escort.knock1 then -- 1678
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1681
	end -- 1681
	if not hadKnock2 and self.escort.knock2 then -- 1681
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1684
	end -- 1684
	a.crouch = self.escort.crouchPose -- 1686
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1687
	if not self.escort.stopped then -- 1687
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1689
		local previousDepth = a.depth -- 1690
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1691
		local distance = math.max( -- 1692
			-travel, -- 1692
			math.min(travel, targetDepth - previousDepth) -- 1692
		) -- 1692
		self:slideDepth(a, distance) -- 1693
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1694
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1694
			a.vy = CHILD_JUMP -- 1696
			a.onGround = false -- 1697
		end -- 1697
	end -- 1697
	local dir = self.escort:moveDir(a.x) -- 1700
	a.vx = dir * CHILD_SPEED -- 1701
	if dir ~= 0 then -- 1701
		a.facing = dir -- 1703
		local before = a.x -- 1704
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1705
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1705
			a.vy = CHILD_JUMP -- 1708
			a.onGround = false -- 1709
		end -- 1709
	end -- 1709
	self:fallY(a, dt) -- 1712
end -- 1645
function Play.prototype.escortOn(self) -- 1716
	if self.room.key == "checkpoint" then -- 1716
		return true -- 1718
	end -- 1718
	if self.room.key == "gatepath" then -- 1718
		return true -- 1721
	end -- 1721
	if self.room.key == "prologue" then -- 1721
		return self.phase == "prologue-follow" -- 1724
	end -- 1724
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1724
		return true -- 1728
	end -- 1728
	return self.room.key == "street" -- 1730
end -- 1716
function Play.prototype.storyLocked(self) -- 1734
	if self.caughtT > 0 then -- 1734
		return true -- 1736
	end -- 1736
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1736
		return true -- 1739
	end -- 1739
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1739
		return true -- 1742
	end -- 1742
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1742
		return true -- 1745
	end -- 1745
	if self.craftBench.active then -- 1745
		return true -- 1749
	end -- 1749
	return false -- 1751
end -- 1734
function Play.prototype.swapToChild(self, x) -- 1755
	local tmp = self.player -- 1756
	self.player = self.partner -- 1757
	self.partner = tmp -- 1758
	self.childMode = true -- 1759
	self.player.alive = true -- 1760
	self.player.x = self.ox + x -- 1761
	self.player.y = 0 -- 1762
	self.player.depth = 0 -- 1763
	self.player.depthSpeed = 0 -- 1764
	self.player.vy = 0 -- 1765
	self.player.vx = 0 -- 1766
	self.player.onGround = true -- 1767
	self.player.crouch = false -- 1768
	self.player.h = CHILD_H -- 1769
	self.player.facing = 1 -- 1770
	self.partner.alive = true -- 1771
	self.cam.x = self.player.x -- 1772
end -- 1755
function Play.prototype.stepStory(self, dt, input) -- 1776
	if self.room.key == "prologue" then -- 1776
		self:stepPrologue(dt, input) -- 1778
	elseif self.room.key == "street" then -- 1778
		self:stepStreet(dt, input) -- 1780
	elseif self.room.key == "gate" then -- 1780
		self:stepGate(dt, input) -- 1782
	elseif self.room.key == "gatepath" then -- 1782
		self:stepGatePath() -- 1784
	elseif self.room.key == "tower" then -- 1784
		self:stepTower(dt, input) -- 1786
	end -- 1786
end -- 1776
function Play.prototype.stepPrologue(self, dt, input) -- 1791
	local child = self.partner -- 1792
	if self.phase == "prologue-wait" then -- 1792
		child.crouch = true -- 1794
		child.h = CHILD_CROUCH_H -- 1795
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1796
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1798
		if near and input.interact.pressed then -- 1798
			self.phase = "prologue-give" -- 1800
			self.phaseTick = 0 -- 1801
			self:flashSet("递出针套", 1) -- 1802
		end -- 1802
		return -- 1804
	end -- 1804
	if self.phase == "prologue-give" then -- 1804
		self.phaseTick = self.phaseTick + 1 -- 1807
		if self.phaseTick == 12 then -- 1807
			self:flashSet("针套递过去", 0.7) -- 1809
		elseif self.phaseTick == 36 then -- 1809
			self:flashSet("纸条塞进针套", 0.9) -- 1811
		elseif self.phaseTick >= 60 then -- 1811
			self.phase = "prologue-follow" -- 1813
			self.phaseTick = 0 -- 1814
			child.crouch = false -- 1815
			child.h = CHILD_H -- 1816
			self:flashSet("她跟上了", 1.2) -- 1817
		end -- 1817
		return -- 1819
	end -- 1819
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1819
		self:requestRoom("street", "序章跟到门口") -- 1823
		self:flashSet("进街道", 1.2) -- 1824
	end -- 1824
end -- 1791
function Play.prototype.stepStreet(self, dt, input) -- 1829
	local p = self.player -- 1830
	local c = self.partner -- 1831
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1831
		self:requestRoom("checkpoint", "两人都到街尾") -- 1833
		self:flashSet("到检查站", 1.2) -- 1834
	end -- 1834
end -- 1829
function Play.prototype.stepGate(self, dt, input) -- 1839
	local ____temp_35 -- 1840
	if self.room.story == nil then -- 1840
		____temp_35 = nil -- 1840
	else -- 1840
		____temp_35 = self.room.story.gate -- 1840
	end -- 1840
	local g = ____temp_35 -- 1840
	if g == nil then -- 1840
		return -- 1842
	end -- 1842
	local p = self.player -- 1844
	if self.phase == "gate-idle" then -- 1844
		local a = self.partner -- 1847
		local gap = g.waitX - a.x -- 1848
		if math.abs(gap) > 3 then -- 1848
			a.facing = gap > 0 and 1 or -1 -- 1850
			a.vx = a.facing * CHILD_SPEED -- 1851
			local beforeX = a.x -- 1852
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1853
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1853
				a.vy = CHILD_JUMP -- 1855
				a.onGround = false -- 1856
			end -- 1856
			self:fallY(a, dt) -- 1858
		else -- 1858
			a.vx = 0 -- 1860
			a.x = g.waitX -- 1861
		end -- 1861
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1864
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1865
		if self.gateNeedConfirm then -- 1865
			if not input.interact.held then -- 1865
				self.gateRestartArmed = true -- 1870
			end -- 1870
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1870
				self.gateNeedConfirm = false -- 1873
				self.gateRestartArmed = true -- 1874
				self.phase = "gate-hold" -- 1875
				self.gateTick = 0 -- 1876
				self.gateSpawned = 0 -- 1877
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1878
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1879
			end -- 1879
			return -- 1881
		end -- 1881
		if atWinch and atWait then -- 1881
			self.phase = "gate-hold" -- 1884
			self.gateTick = 0 -- 1885
			self.gateSpawned = 0 -- 1886
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1887
		end -- 1887
		return -- 1889
	end -- 1889
	if self.phase == "gate-hold" then -- 1889
		self.gateTick = self.gateTick + 1 -- 1892
		local marks = {0, 540, 900, 1500} -- 1894
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1894
			local idx = self.gateSpawned -- 1896
			local ____self_enemies_36 = self.enemies -- 1896
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 1897
				x = self.ox + 620 + idx * 62, -- 1898
				y = 0, -- 1898
				w = 26, -- 1898
				h = 84, -- 1898
				alive = true, -- 1899
				hitT = 0, -- 1899
				warnT = 0, -- 1899
				fireCd = 90 + idx * 45 -- 1899
			} -- 1899
			self.gateSpawned = self.gateSpawned + 1 -- 1901
			self:flashSet( -- 1902
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1902
				0.9 -- 1902
			) -- 1902
		end -- 1902
		if self.gateTick == 900 then -- 1902
			self:flashSet("灯灭了", 1) -- 1905
		elseif self.gateTick == 2100 then -- 1905
			self:flashSet("门底压下来了", 1) -- 1907
		end -- 1907
		if self.gateTick >= g.holdTicks then -- 1907
			self:captureGateBlood() -- 1912
			self.phase = "gate-send" -- 1913
			self.phaseTick = 0 -- 1914
			self.enemies = {} -- 1916
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1917
		end -- 1917
		return -- 1919
	end -- 1919
	if self.phase == "gate-send" then -- 1919
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1922
		if near and input.interact.pressed then -- 1922
			self:commitRoute() -- 1925
			self:swapToChild(g.doorX + 30) -- 1926
			self.phase = "gate-count" -- 1927
			self.countTick = 0 -- 1928
			self.countArmed = false -- 1930
			self.countPrevMove = input.moveX -- 1931
			self:flashSet("门开了 · 送她出去", 1.8) -- 1932
		end -- 1932
		return -- 1934
	end -- 1934
	if self.phase == "gate-count" then -- 1934
		self.countTick = self.countTick + 1 -- 1937
		if self.countTick == 360 then -- 1937
			self:flashSet("门关上", 0.9) -- 1939
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 1939
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 1941
			if self.storyRoute == "soldier" then -- 1941
				self.phase = "gate-wait" -- 1947
				self.phaseTick = 0 -- 1948
				self.knocks = 1 -- 1949
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 1950
				self.handArmed = not input.interact.held -- 1952
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 1953
			else -- 1953
				self:flashSet("数到二十", 2.2) -- 1955
			end -- 1955
		end -- 1955
		local prevMove = self.countPrevMove -- 1960
		self.countPrevMove = input.moveX -- 1961
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 1961
			if prevMove <= 0 and input.moveX > 0 then -- 1961
				self.countArmed = true -- 1964
			end -- 1964
			if self.countArmed and input.moveX > 0 then -- 1964
				self.phase = "gate-walk" -- 1967
				self.phaseTick = 0 -- 1968
				self:flashSet("她迈出第一步", 1.4) -- 1969
				self:emit("storyExit", { -- 1970
					route = "child", -- 1970
					via = "walk", -- 1970
					countTick = self.countTick, -- 1970
					hp = self.hp, -- 1970
					maxHp = self.maxHp -- 1970
				}) -- 1970
			end -- 1970
		end -- 1970
		return -- 1973
	end -- 1973
	if self.phase == "gate-wait" then -- 1973
		self.phaseTick = self.phaseTick + 1 -- 1977
		if self.phaseTick == 12 then -- 1977
			self.knocks = 2 -- 1979
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 1980
			self:flashSet("第二下 · 她抬手了", 1.6) -- 1981
		end -- 1981
		if not input.interact.held then -- 1981
			if self.handTicks > 0 then -- 1981
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1985
			end -- 1985
			self.handTicks = 0 -- 1987
			self.handArmed = true -- 1988
			return -- 1989
		end -- 1989
		if self.handArmed then -- 1989
			self.handTicks = self.handTicks + 1 -- 1992
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 1992
				self.phase = "gate-hand" -- 1994
				self.phaseTick = 0 -- 1995
				self.handDone = true -- 1996
				self.tied = true -- 1997
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1998
				if not self.lineSaid then -- 1998
					self.lineSaid = true -- 2000
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2001
				end -- 2001
				self:flashSet("我们走吧。", 3) -- 2003
			end -- 2003
		end -- 2003
		return -- 2006
	end -- 2006
	if self.phase == "gate-hand" then -- 2006
		self.phaseTick = self.phaseTick + 1 -- 2010
		if self.phaseTick == 30 then -- 2010
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2012
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2012
			self:emit("storyExit", { -- 2014
				route = "soldier", -- 2014
				via = "hand", -- 2014
				handTicks = self.handTicks, -- 2014
				hp = self.hp, -- 2014
				maxHp = self.maxHp -- 2014
			}) -- 2014
			self:requestRoom("gatepath", "牵手同行") -- 2015
		end -- 2015
		return -- 2017
	end -- 2017
	if self.phase == "gate-walk" then -- 2017
		if self.player.x >= g.exitX then -- 2017
			self:requestRoom("outside", "走出城门") -- 2022
			self:flashSet("出城门 · 城外", 1.4) -- 2023
		end -- 2023
	end -- 2023
end -- 1839
function Play.prototype.captureGateBlood(self) -- 2032
	self.hpAtGate = self.hp -- 2033
	self.maxHpAtGate = self.maxHp -- 2034
end -- 2032
function Play.prototype.commitRoute(self) -- 2041
	if self.storySettled then -- 2041
		return -- 2043
	end -- 2043
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2045
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2046
	self.hpAtGate = hp -- 2047
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2048
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2049
	self.storySettled = true -- 2050
	self:emit("storyRouteLocked", { -- 2051
		route = self.storyRoute, -- 2052
		hp = self.hp, -- 2052
		maxHp = self.maxHp, -- 2052
		hpAtGate = self.hpAtGate, -- 2053
		maxHpAtGate = self.maxHpAtGate -- 2053
	}) -- 2053
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2055
end -- 2041
function Play.prototype.syncStory(self) -- 2059
	if self.isCampaign and self.run.trial ~= nil then -- 2059
		return -- 2061
	end -- 2061
	local s = self.run.story -- 2063
	if s == nil then -- 2063
		return -- 2065
	end -- 2065
	s.hp = self.hp -- 2067
	s.maxHp = self.maxHp -- 2068
	s.route = self.storyRoute -- 2069
	s.settled = self.storySettled -- 2070
	s.hpAtGate = self.hpAtGate -- 2071
	s.maxHpAtGate = self.maxHpAtGate -- 2072
	s.handDone = self.handDone -- 2073
	s.lineSaid = self.lineSaid -- 2074
	s.tied = self.tied -- 2075
	s.carry = self.carryOn -- 2076
	s.escortDone = self.escortDone -- 2077
	s.craftedWeapon = self.run.story.craftedWeapon -- 2078
	s.ending = self.run.story.ending -- 2079
	if self.room.key == "gate" then -- 2079
		s.phase = self.phase -- 2081
		s.countTick = self.countTick -- 2082
		s.phaseTick = self.phaseTick -- 2083
		s.handTicks = self.handTicks -- 2084
	end -- 2084
end -- 2059
function Play.prototype.stepGatePath(self) -- 2089
	local ____temp_37 -- 2090
	if self.room.story == nil then -- 2090
		____temp_37 = nil -- 2090
	else -- 2090
		____temp_37 = self.room.story.gatepath -- 2090
	end -- 2090
	local gp = ____temp_37 -- 2090
	if self.phase == "gatepath-start" then -- 2090
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2090
			self.carryOn = true -- 2093
			self.phase = "gatepath-carry" -- 2094
			self.phaseTick = 0 -- 2095
			self.pathDone = true -- 2096
			self.escortDone = false -- 2097
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2098
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2099
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2100
		end -- 2100
		return -- 2102
	end -- 2102
	if self.phase == "gatepath-carry" then -- 2102
		self.phaseTick = self.phaseTick + 1 -- 2105
		if self.phaseTick == 20 then -- 2105
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2107
		end -- 2107
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2107
			self:requestRoom(gp.next, "背负进首战") -- 2110
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2111
		end -- 2111
	end -- 2111
end -- 2089
function Play.prototype.carryPose(self) -- 2120
	local p = self.player -- 2121
	local a = self.partner -- 2122
	a.alive = true -- 2123
	a.x = p.x - p.facing * 12 -- 2124
	a.y = p.y + 26 -- 2125
	a.depth = p.depth -- 2126
	a.vx = p.vx -- 2127
	a.vy = 0 -- 2128
	a.onGround = true -- 2129
	a.crouch = false -- 2130
	a.h = CHILD_CROUCH_H -- 2131
	a.facing = p.facing -- 2132
end -- 2120
function Play.prototype.stepTower(self, dt, input) -- 2136
	local ____temp_38 -- 2137
	if self.room.story == nil then -- 2137
		____temp_38 = nil -- 2137
	else -- 2137
		____temp_38 = self.room.story.tower -- 2137
	end -- 2137
	local t = ____temp_38 -- 2137
	if t == nil then -- 2137
		return -- 2139
	end -- 2139
	if self.phase == "tower-wait" then -- 2139
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2142
		if near and input.interact.pressed then -- 2142
			self.phase = "tower-knock" -- 2144
			self.phaseTick = 0 -- 2145
			self.knocks = 1 -- 2146
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2147
			self:flashSet("敲一下", 0.6) -- 2148
		end -- 2148
		return -- 2150
	end -- 2150
	if self.phase == "tower-knock" then -- 2150
		self.phaseTick = self.phaseTick + 1 -- 2153
		if self.phaseTick == 12 then -- 2153
			self.knocks = 2 -- 2155
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2156
			self:flashSet("敲两下 · 第二声", 1) -- 2157
		elseif self.phaseTick >= t.knockTicks then -- 2157
			self.phase = "tower-given" -- 2159
			self.phaseTick = 0 -- 2160
			self:flashSet("门开了 · 提灯", 1.4) -- 2161
		end -- 2161
		return -- 2163
	end -- 2163
	if self.phase == "tower-given" then -- 2163
		local soldier = self.storyRoute == "soldier" -- 2168
		self.phaseTick = self.phaseTick + 1 -- 2169
		if self.phaseTick == 60 then -- 2169
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2171
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2172
		elseif self.phaseTick == 120 then -- 2172
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2174
		elseif self.phaseTick >= 180 then -- 2174
			self.phase = "tower-end" -- 2176
			self.phaseTick = 0 -- 2177
			if not self.run.finished then -- 2177
				self.run.finished = true -- 2179
				local ending = soldier and "reunion" or "lamp" -- 2180
				self.run.story.ending = ending -- 2181
				local ____soldier_39 -- 2184
				if soldier then -- 2184
					____soldier_39 = self.run.story.segments.escort5 == true -- 2185
				else -- 2185
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2186
				end -- 2186
				local played = ____soldier_39 -- 2184
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2187
				if official then -- 2187
					if soldier then -- 2187
						self.run.archive.soldierCleared = true -- 2191
					else -- 2191
						self.run.archive.childCleared = true -- 2193
					end -- 2193
				end -- 2193
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2196
				self:emit("endingReached", { -- 2197
					route = soldier and "soldier" or "child", -- 2198
					ending = ending, -- 2199
					official = official, -- 2200
					source = self.run.source, -- 2201
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2202
					childCleared = self.run.archive.childCleared, -- 2203
					soldierCleared = self.run.archive.soldierCleared, -- 2204
					artifactOwned = self.run.archive.artifactOwned, -- 2205
					equipped = self.equippedWeapon -- 2206
				}) -- 2206
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2208
			end -- 2208
		end -- 2208
		return -- 2211
	end -- 2211
	if input.interact.pressed or input.retry.pressed then -- 2211
		self:requestRoom("prologue", "片尾再玩") -- 2214
		self:flashSet("回到序章", 1.4) -- 2215
	end -- 2215
end -- 2136
function Play.prototype.stepChase(self, dt, input) -- 2220
	if self.caughtT > 0 then -- 2220
		self.caughtT = self.caughtT - dt -- 2222
		if self.caughtT <= 0 then -- 2222
			self:recoverFromCaught() -- 2224
		end -- 2224
		return -- 2226
	end -- 2226
	if self.room.key == "village" then -- 2226
		self:stepScavChase() -- 2229
	elseif self.room.key == "forest" then -- 2229
		self:stepDog(dt) -- 2231
		if self.player.x >= self.ox + 1450 then -- 2231
			self:requestRoom("tower", "到林缘北塔") -- 2234
			self:flashSet("林缘 · 北塔", 1.4) -- 2235
		end -- 2235
	end -- 2235
end -- 2220
function Play.prototype.stepScavChase(self) -- 2241
	local s = self.room.scavenger -- 2242
	if s == nil then -- 2242
		return -- 2244
	end -- 2244
	local p = self.player -- 2246
	if self.passed and p.x > self.ox + 440 then -- 2246
		if self.scavChase then -- 2246
			self.scavChase = false -- 2250
			self.scavState = "back" -- 2251
			self.scavT = 0 -- 2252
		end -- 2252
		return -- 2254
	end -- 2254
	local dx = p.x - self.scavX -- 2256
	local dist = math.abs(dx) -- 2257
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2258
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2259
	if not self.scavChase then -- 2259
		if visible then -- 2259
			self.scavSee = self.scavSee + 1 -- 2262
			if self.scavSee >= 24 then -- 2262
				self.scavChase = true -- 2264
				self.scavState = "chase" -- 2265
				self.scavTargetX = p.x -- 2266
				self:flashSet("他看见你了", 1.2) -- 2267
			end -- 2267
		else -- 2267
			self.scavSee = 0 -- 2270
		end -- 2270
		return -- 2272
	end -- 2272
	local dir = p.x > self.scavX and 1 or -1 -- 2275
	self.scavX = self.scavX + dir * 96 / 60 -- 2276
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2276
		self:caught() -- 2278
		return -- 2279
	end -- 2279
	if hidden then -- 2279
		self.scavSee = 0 -- 2283
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2284
		self.scavT = self.scavT - 1 -- 2285
		if self.scavT <= 0 then -- 2285
			self.scavChase = false -- 2287
			self.scavState = "patrol" -- 2288
			self:flashSet("他失去了目标", 1) -- 2289
		end -- 2289
	end -- 2289
end -- 2241
function Play.prototype.stepDog(self, dt) -- 2295
	local ____temp_40 -- 2296
	if self.room.story == nil then -- 2296
		____temp_40 = nil -- 2296
	else -- 2296
		____temp_40 = self.room.story.dog -- 2296
	end -- 2296
	local dog = ____temp_40 -- 2296
	if dog == nil then -- 2296
		return -- 2298
	end -- 2298
	local p = self.player -- 2300
	local dist = math.abs(p.x - self.dogX) -- 2301
	if self.dogState == "patrol" then -- 2301
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2303
		if self.dogX < dog.x0 then -- 2303
			self.dogX = dog.x0 -- 2305
			self.dogDir = 1 -- 2306
		elseif self.dogX > dog.x1 then -- 2306
			self.dogX = dog.x1 -- 2308
			self.dogDir = -1 -- 2309
		end -- 2309
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2311
		if not p.crouch and moving and dist < dog.range then -- 2311
			self.dogState = "ear" -- 2313
			self.dogT = 18 -- 2314
			self.dogTargetX = p.x -- 2315
			self:flashSet("狗转耳朵", 0.8) -- 2316
		end -- 2316
		return -- 2318
	end -- 2318
	if self.dogState == "ear" then -- 2318
		self.dogT = self.dogT - 1 -- 2321
		if self.dogT <= 0 then -- 2321
			self.dogState = "chase" -- 2323
			self.dogTargetX = p.x -- 2324
			self:flashSet("狗追来了", 1.4) -- 2325
		end -- 2325
		return -- 2327
	end -- 2327
	if self.dogState == "chase" then -- 2327
		local dir = p.x > self.dogX and 1 or -1 -- 2330
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2331
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2331
			self:caught() -- 2333
			self.dogState = "sniff" -- 2334
			self.dogT = 60 -- 2335
		elseif dist > dog.range * 1.5 or p.crouch then -- 2335
			self.dogState = "sniff" -- 2337
			self.dogT = 60 -- 2338
			self:flashSet("狗停下了", 0.9) -- 2339
		end -- 2339
		return -- 2341
	end -- 2341
	if self.dogState == "sniff" then -- 2341
		self.dogT = self.dogT - 1 -- 2344
		if self.dogT <= 0 then -- 2344
			self.dogState = "back" -- 2346
		end -- 2346
		return -- 2348
	end -- 2348
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2351
	self.dogX = self.dogX + dir * dog.speed * dt -- 2352
	if math.abs(self.dogX - dog.x0) < 2 then -- 2352
		self.dogX = dog.x0 -- 2354
		self.dogState = "patrol" -- 2355
	end -- 2355
end -- 2295
function Play.prototype.caught(self) -- 2359
	self.caughtT = 1 -- 2360
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2361
end -- 2359
function Play.prototype.recoverFromCaught(self) -- 2365
	local p = self.player -- 2366
	p.x = self.ox + 140 -- 2367
	p.y = 0 -- 2368
	p.vy = 0 -- 2369
	p.vx = 0 -- 2370
	p.onGround = true -- 2371
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2371
		self.scavX = self.room.scavenger.x0 -- 2373
		self.scavState = "patrol" -- 2374
		self.scavSee = 0 -- 2375
		self.scavChase = false -- 2376
		self.scavT = 0 -- 2377
	end -- 2377
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2377
		self.dogX = self.room.story.dog.x0 -- 2380
		self.dogState = "patrol" -- 2381
		self.dogT = 0 -- 2382
	end -- 2382
	self.cam.x = p.x -- 2384
	self.cam.y = p.y + CAM_LOOK_UP -- 2385
	self:flashSet("回到安全点", 1.2) -- 2386
end -- 2365
function Play.prototype.updateGate(self) -- 2390
	if self.room.key ~= "checkpoint" then -- 2390
		self.gateOpen = false -- 2392
		return -- 2393
	end -- 2393
	local function inZone(x) -- 2395
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2395
	end -- 2395
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2396
end -- 2390
function Play.prototype.addItem(self, kind) -- 2402
	local inv = self.run.inventory -- 2403
	if kind == "shield" then -- 2403
		if inv.shield >= TOOL_CAP then -- 2403
			return false -- 2406
		end -- 2406
		inv.shield = inv.shield + 1 -- 2408
		return true -- 2409
	end -- 2409
	if kind == "wedge" then -- 2409
		if inv.wedge >= CONSUMABLE_CAP then -- 2409
			return false -- 2413
		end -- 2413
		inv.wedge = inv.wedge + 1 -- 2415
		return true -- 2416
	end -- 2416
	if kind == "ammo" then -- 2416
		if inv.ammo >= CONSUMABLE_CAP then -- 2416
			return false -- 2420
		end -- 2420
		inv.ammo = inv.ammo + 1 -- 2422
		return true -- 2423
	end -- 2423
	if kind == "scrap" then -- 2423
		inv.scrap = inv.scrap + 1 -- 2427
		return true -- 2428
	end -- 2428
	if kind == "wood" then -- 2428
		inv.wood = inv.wood + 1 -- 2431
		return true -- 2432
	end -- 2432
	if kind == "bell" then -- 2432
		inv.bell = inv.bell + 1 -- 2435
		return true -- 2436
	end -- 2436
	if kind == "pass" then -- 2436
		inv.pass = inv.pass + 1 -- 2439
		return true -- 2440
	end -- 2440
	if kind == "quickbelt" then -- 2440
		inv.quickbelt = inv.quickbelt + 1 -- 2443
		return true -- 2444
	end -- 2444
	return false -- 2446
end -- 2402
function Play.prototype.findBox(self, id) -- 2449
	local i = 0 -- 2450
	do -- 2450
		i = 0 -- 2451
		while i < #self.boxes do -- 2451
			if self.boxes[i + 1].id == id then -- 2451
				return self.boxes[i + 1] -- 2453
			end -- 2453
			i = i + 1 -- 2451
		end -- 2451
	end -- 2451
	return nil -- 2456
end -- 2449
function Play.prototype.findWedgeTarget(self) -- 2460
	local best = nil -- 2461
	local bestD = 0 -- 2462
	local i = 0 -- 2463
	do -- 2463
		i = 0 -- 2464
		while i < #self.boxes do -- 2464
			do -- 2464
				local b = self.boxes[i + 1] -- 2465
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2465
					goto __continue367 -- 2467
				end -- 2467
				if not self:nearBox(b, 26) then -- 2467
					goto __continue367 -- 2470
				end -- 2470
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2472
				if best == nil or d < bestD then -- 2472
					best = b -- 2474
					bestD = d -- 2475
				end -- 2475
			end -- 2475
			::__continue367:: -- 2475
			i = i + 1 -- 2464
		end -- 2464
	end -- 2464
	return best -- 2478
end -- 2460
function Play.prototype.stepCraft(self, input) -- 2486
	local inv = self.run.inventory -- 2487
	local ____opt_41 = self.run.trial -- 2487
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2488
	if self.craftT > 0 then -- 2488
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2488
			self.craftT = 0 -- 2492
			self:flashSet("制作中断", 0.8) -- 2493
			return true -- 2494
		end -- 2494
		self.craftT = self.craftT + 1 -- 2496
		if self.craftT >= required then -- 2496
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2496
				inv.scrap = inv.scrap - 1 -- 2499
				inv.wedge = inv.wedge + 1 -- 2500
				self:flashSet("制得木楔", 1.2) -- 2501
				self:log("制木楔") -- 2502
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2503
			end -- 2503
			self.craftT = 0 -- 2505
		end -- 2505
		return true -- 2507
	end -- 2507
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2507
		self.craftT = 1 -- 2510
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2511
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2512
		return true -- 2513
	end -- 2513
	return false -- 2515
end -- 2486
function Play.prototype.nearBox(self, b, reach) -- 2518
	local p = self.player -- 2519
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2520
end -- 2518
function Play.prototype.findInteract(self) -- 2526
	local p = self.player -- 2527
	local best = nil -- 2528
	local bestD = 1000000000 -- 2529
	local i = 0 -- 2530
	do -- 2530
		i = 0 -- 2531
		while i < #self.boxes do -- 2531
			do -- 2531
				local b = self.boxes[i + 1] -- 2532
				if b.interact == nil or b.broken == true then -- 2532
					goto __continue380 -- 2534
				end -- 2534
				if not self:nearBox(b, b.interact.reach or 27) then -- 2534
					goto __continue380 -- 2537
				end -- 2537
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2539
				if d < bestD then -- 2539
					bestD = d -- 2541
					best = b -- 2542
				end -- 2542
			end -- 2542
			::__continue380:: -- 2542
			i = i + 1 -- 2531
		end -- 2531
	end -- 2531
	return best -- 2545
end -- 2526
function Play.prototype.stepCampaign(self, dt, input) -- 2549
	local wr = self.room -- 2550
	local p = self.player -- 2551
	if self.reloadT > 0 then -- 2551
		self.reloadT = self.reloadT - 1 -- 2553
	end -- 2553
	if self.bracedShield ~= nil then -- 2553
		self.bracedShield.x = p.x + p.facing * 26 -- 2557
		self.bracedShield.y = p.y -- 2558
		local shBox = __TS__ArrayFind( -- 2559
			self.boxes, -- 2559
			function(____, b) return b.id == "braced_shield" end -- 2559
		) -- 2559
		if shBox ~= nil then -- 2559
			shBox.x0 = self.bracedShield.x - 15 -- 2561
			shBox.x1 = self.bracedShield.x + 15 -- 2562
			shBox.y0 = self.bracedShield.y -- 2563
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2564
		end -- 2564
	end -- 2564
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2564
		self.run.route = "drygoods" -- 2570
		self.run.joined = false -- 2571
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2572
		self:log("转布行线") -- 2573
	end -- 2573
	if wr.key == "escort3" then -- 2573
		local benchX = wr.minX + 560 -- 2577
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 12 -- 2578
		if self.craftBench.active then -- 2578
			if input.interact.pressed or input.pause.pressed then -- 2578
				self:closeCraftBench() -- 2581
			end -- 2581
		elseif nearBench and input.interact.pressed then -- 2581
			self:openCraftBench() -- 2584
		end -- 2584
	end -- 2584
	local i = 0 -- 2588
	do -- 2588
		i = 0 -- 2589
		while i < #self.pickups do -- 2589
			do -- 2589
				local pk = self.pickups[i + 1] -- 2590
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2590
					goto __continue395 -- 2592
				end -- 2592
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2594
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2595
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2595
					if not self:addItem(pk.kind) then -- 2595
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2599
						self:log("满包拒绝 " .. pk.kind) -- 2600
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2601
						goto __continue395 -- 2602
					end -- 2602
					self.run.taken[pk.id] = true -- 2604
					pk.id = "" -- 2605
					self:flashSet("拾取 " .. pk.label, 1) -- 2606
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2607
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2608
				end -- 2608
			end -- 2608
			::__continue395:: -- 2608
			i = i + 1 -- 2589
		end -- 2589
	end -- 2589
	if not self:stepCraft(input) and input.interact.pressed then -- 2589
		self:campaignInteract() -- 2612
	end -- 2612
	self:stepCampaignCart(dt, input) -- 2614
	self:stepCampaignGoal() -- 2615
	self:campaignCheckpoint() -- 2616
end -- 2549
function Play.prototype.campaignCheckpoint(self) -- 2620
	local i = 0 -- 2621
	do -- 2621
		i = 0 -- 2622
		while i < #self.room.marks do -- 2622
			do -- 2622
				local m = self.room.marks[i + 1] -- 2623
				if m.kind ~= 0 then -- 2623
					goto __continue402 -- 2625
				end -- 2625
				local dx = self.player.x - m.x -- 2627
				local dy = self.player.y - m.y -- 2628
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2628
					self.checkpoint = m.x -- 2630
					self:captureCheckpoint(m.x) -- 2631
					self:flashSet("检查点", 1) -- 2632
				end -- 2632
			end -- 2632
			::__continue402:: -- 2632
			i = i + 1 -- 2622
		end -- 2622
	end -- 2622
end -- 2620
function Play.prototype.campaignInteract(self) -- 2638
	local b = self:findInteract() -- 2639
	if b ~= nil then -- 2639
		self:useInteract(b) -- 2641
		return -- 2642
	end -- 2642
	local inv = self.run.inventory -- 2644
	if inv.wedge > 0 then -- 2644
		local w = self:findWedgeTarget() -- 2646
		if w ~= nil then -- 2646
			if w.breakable ~= nil then -- 2646
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 2646
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 2649
			end -- 2649
			inv.wedge = inv.wedge - 1 -- 2651
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2652
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2654
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2655
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2656
			return -- 2657
		end -- 2657
	end -- 2657
	if inv.ammo > 0 and self.reloadT > 0 then -- 2657
		self.reloadT = 0 -- 2662
		self:closeReloadPuzzle() -- 2663
		inv.ammo = inv.ammo - 1 -- 2664
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2665
		self:log("用备用弹包") -- 2666
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2667
		return -- 2668
	end -- 2668
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2668
		local p = self.player -- 2672
		self.bracedShield = { -- 2673
			x = p.x + p.facing * 26, -- 2673
			y = p.y, -- 2673
			w = 30, -- 2673
			h = 64, -- 2673
			hp = 1 -- 2673
		} -- 2673
		local ____self_boxes_45 = self.boxes -- 2673
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 2674
			x0 = self.bracedShield.x - 15, -- 2675
			x1 = self.bracedShield.x + 15, -- 2675
			y0 = p.y, -- 2676
			y1 = p.y + 64, -- 2676
			depth = {min = -46, max = 46}, -- 2676
			label = "架起的残盾", -- 2676
			id = "braced_shield", -- 2676
			soft = true -- 2677
		} -- 2677
		inv.shield = inv.shield - 1 -- 2680
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2681
		self:log("架残盾") -- 2682
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2683
		return -- 2684
	end -- 2684
	if inv.pass > 0 and self.run.joined == false then -- 2684
		inv.pass = inv.pass - 1 -- 2687
		self.run.joined = true -- 2688
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2689
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2690
		return -- 2691
	end -- 2691
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2693
end -- 2638
function Play.prototype.useInteract(self, b) -- 2696
	local kind = b.interact == nil and "" or b.interact.kind -- 2697
	local wr = self.room -- 2698
	if kind == "open_board" then -- 2698
		b.broken = true -- 2700
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2701
		for ____, cover in ipairs(self.boxes) do -- 2702
			if cover.id == "s2_board_cover" then -- 2702
				cover.broken = false -- 2704
				cover.hidden = false -- 2705
			end -- 2705
		end -- 2705
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2708
		self.run.joined = true -- 2709
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2710
		self:log("放下窗板") -- 2711
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2712
		return -- 2713
	end -- 2713
	if kind == "lower_curtain" then -- 2713
		for ____, curtain in ipairs(self.boxes) do -- 2716
			if curtain.id == "c2_curtain" then -- 2716
				curtain.broken = false -- 2718
				curtain.hidden = false -- 2719
			end -- 2719
		end -- 2719
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2722
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2723
		self:log("放下木帘") -- 2724
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2725
		return -- 2726
	end -- 2726
	if kind == "raise_latch" then -- 2726
		if wr.key == "c2-granary" and not self.cartDocked then -- 2726
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2730
			return -- 2731
		end -- 2731
		b.broken = true -- 2733
		self.objectiveDone = true -- 2734
		if wr.key == "c1-yard" then -- 2734
			self.run.c1Latch = true -- 2737
			self.run.joined = true -- 2738
		else -- 2738
			self.run.c2Latch = true -- 2740
			self.run.joined = true -- 2741
		end -- 2741
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2743
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2744
		self:log("抬闩") -- 2745
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2746
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2747
	end -- 2747
end -- 2696
function Play.prototype.stepCampaignCart(self, dt, input) -- 2752
	local wr = self.room -- 2753
	local c = wr.cart -- 2754
	if c.bodyW <= 0 then -- 2754
		return -- 2756
	end -- 2756
	local p = self.player -- 2758
	local handleX = self.cartAxle + c.handleOffset -- 2759
	if not self.gripping then -- 2759
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2759
			self.gripping = true -- 2763
			self:flashSet("握住车柄 · A/D 推", 1) -- 2764
		end -- 2764
		return -- 2766
	end -- 2766
	if input.interact.pressed then -- 2766
		self.gripping = false -- 2769
		self:flashSet("松手", 0.5) -- 2770
		return -- 2771
	end -- 2771
	if not self.cartDocked then -- 2771
		if input.moveX ~= 0 and not self:stuckCart() then -- 2771
			self.cartAxle = math.max( -- 2775
				c.startX, -- 2775
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2775
			) -- 2775
		end -- 2775
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2775
			self.cartExposed = true -- 2780
			local gun = nil -- 2781
			local gi = 0 -- 2782
			do -- 2782
				gi = 0 -- 2783
				while gi < #self.enemies do -- 2783
					local e = self.enemies[gi + 1] -- 2784
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2784
						gun = e -- 2786
						break -- 2787
					end -- 2787
					gi = gi + 1 -- 2783
				end -- 2783
			end -- 2783
			if gun ~= nil then -- 2783
				self:campaignEnemyFire(gun) -- 2791
			end -- 2791
		end -- 2791
		p.x = self.cartAxle + c.handleOffset -- 2794
		p.y = c.baseY + (c.depth or 0) -- 2795
		p.vx = 0 -- 2796
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2796
			self.cartAxle = c.endX -- 2798
			self.cartDocked = true -- 2799
			self.gripping = false -- 2800
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2801
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2802
			self:flashSet("车轮入窝", 1.2) -- 2803
			self:log("车轮入窝") -- 2804
		end -- 2804
	end -- 2804
end -- 2752
function Play.prototype.stuckCart(self) -- 2810
	local i = 0 -- 2811
	do -- 2811
		i = 0 -- 2812
		while i < #self.boxes do -- 2812
			do -- 2812
				local b = self.boxes[i + 1] -- 2813
				if b.broken == true or b.breakable == nil or b.soft == true then -- 2813
					goto __continue441 -- 2815
				end -- 2815
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 2817
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 2817
					return true -- 2819
				end -- 2819
			end -- 2819
			::__continue441:: -- 2819
			i = i + 1 -- 2812
		end -- 2812
	end -- 2812
	return false -- 2822
end -- 2810
function Play.prototype.stepCampaignGoal(self) -- 2826
	local wr = self.room -- 2827
	local c = wr.campaign -- 2828
	if c == nil then -- 2828
		return -- 2830
	end -- 2830
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 2830
		self.objectiveDone = true -- 2833
	end -- 2833
	if c.goal == "reach_exit" then -- 2833
		self.objectiveDone = true -- 2836
	end -- 2836
	if not self.objectiveDone then -- 2836
		return -- 2839
	end -- 2839
	local p = self.player -- 2841
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 2842
	if p.x < c.exitX or not partnerOk then -- 2842
		return -- 2844
	end -- 2844
	if self.run.story.segments[wr.key] ~= true then -- 2844
		self.run.story.segments[wr.key] = true -- 2848
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 2849
	end -- 2849
	if wr.key == "escort5" then -- 2849
		self.escortDone = true -- 2853
		self.run.story.escortDone = true -- 2854
	end -- 2854
	if c.next ~= nil and c.next ~= "" then -- 2854
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 2857
		self:flashSet("过关 · " .. c.next, 1.2) -- 2858
	elseif not self.run.finished then -- 2858
		self.run.finished = true -- 2860
		self:flashSet( -- 2861
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 2861
			2 -- 2861
		) -- 2861
		self:log("C2 灰盒完成") -- 2862
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 2863
	end -- 2863
end -- 2826
function Play.prototype.stepCampaignPartner(self, dt) -- 2868
	local a = self.partner -- 2869
	local wr = self.room -- 2870
	local cp = wr.companion -- 2871
	if not a.alive then -- 2871
		return -- 2873
	end -- 2873
	local p = self.player -- 2875
	if self.craftBench.active then -- 2875
		a.vx = 0 -- 2878
		return -- 2879
	end -- 2879
	local wait = false -- 2881
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 2882
	local targetDepth = p.depth -- 2883
	if self.run.joined == false then -- 2883
		wait = true -- 2885
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2886
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2887
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 2887
		wait = true -- 2889
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2890
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2891
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 2891
		wait = true -- 2893
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2894
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2895
	end -- 2895
	if self.partnerStuck > 0.3 then -- 2895
		a.x = a.x + a.facing * 44 -- 2899
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2900
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2901
		self.partnerLaneHold = 1.1 -- 2902
		self.partnerStuck = 0 -- 2903
	end -- 2903
	if self.partnerLaneHold > 0 then -- 2903
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2906
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2907
	end -- 2907
	local dx = targetX - a.x -- 2909
	if not wait and math.abs(dx) > 74 then -- 2909
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2911
		local before = a.x -- 2912
		a.vx = dx > 0 and speed or -speed -- 2913
		a.facing = dx > 0 and 1 or -1 -- 2914
		self:slideX(a, a.vx * dt) -- 2915
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2915
			a.vy = CHILD_JUMP -- 2918
			a.onGround = false -- 2919
		end -- 2919
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2921
	else -- 2921
		a.vx = 0 -- 2923
		self.partnerStuck = 0 -- 2924
	end -- 2924
	local dz = targetDepth - a.depth -- 2926
	if math.abs(dz) > 6 then -- 2926
		local step = math.max( -- 2928
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2928
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2928
		) -- 2928
		a.depth = a.depth + step -- 2929
	end -- 2929
	a.depthSpeed = 0 -- 2931
	a.h = CHILD_H -- 2932
	a.crouch = false -- 2933
	self:fallY(a, dt) -- 2934
end -- 2868
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2938
	local p = self.player -- 2939
	local i = 0 -- 2940
	do -- 2940
		i = 0 -- 2941
		while i < #self.enemies do -- 2941
			do -- 2941
				local ____opt_46 = self.run.trial -- 2941
				if ____opt_46 and ____opt_46.lost then -- 2941
					return -- 2942
				end -- 2942
				local e = self.enemies[i + 1] -- 2943
				if not e.alive then -- 2943
					goto __continue468 -- 2945
				end -- 2945
				if e.hitT > 0 then -- 2945
					e.hitT = e.hitT - dt -- 2948
				end -- 2948
				if e.kind == "target" then -- 2948
					if not e.alive and e.hitT <= 0 then -- 2948
						e.alive = true -- 2953
					end -- 2953
					goto __continue468 -- 2955
				end -- 2955
				if e.kind == "breaker" then -- 2955
					self:stepBreaker(e, dt) -- 2958
					goto __continue468 -- 2959
				end -- 2959
				if e.kind == "shield" then -- 2959
					self:stepShield(e, dt, input) -- 2962
					goto __continue468 -- 2963
				end -- 2963
				local dx = e.x - p.x -- 2966
				if not e.awake then -- 2966
					if math.abs(dx) > 520 then -- 2966
						goto __continue468 -- 2969
					end -- 2969
					e.awake = true -- 2971
					e.fireCd = 48 -- 2972
					goto __continue468 -- 2973
				end -- 2973
				if math.abs(dx) > ENEMY_RANGE then -- 2973
					goto __continue468 -- 2976
				end -- 2976
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2976
					goto __continue468 -- 2981
				end -- 2981
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2981
					goto __continue468 -- 2984
				end -- 2984
				if self:blockedShot(e, p) then -- 2984
					if e.warnT > 0 then -- 2984
						e.warnT = 0 -- 2990
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2991
					end -- 2991
					goto __continue468 -- 2993
				end -- 2993
				if e.warnT > 0 then -- 2993
					e.warnT = e.warnT - 1 -- 2996
					if e.warnT <= 0 then -- 2996
						self:campaignEnemyFire(e) -- 2998
					end -- 2998
				elseif e.fireCd > 0 then -- 2998
					e.fireCd = e.fireCd - 1 -- 3001
					if e.fireCd <= 0 then -- 3001
						e.warnT = WARN_TICKS -- 3003
					end -- 3003
				else -- 3003
					e.fireCd = 40 -- 3006
				end -- 3006
			end -- 3006
			::__continue468:: -- 3006
			i = i + 1 -- 2941
		end -- 2941
	end -- 2941
end -- 2938
function Play.prototype.blockedShot(self, e, p) -- 3012
	local eDepth = e.depth or 0 -- 3013
	local ex = e.x -- 3014
	local ey = e.y + e.h * 0.62 -- 3016
	local px = p.x -- 3017
	local py = p.y + p.h * 0.55 -- 3018
	local dx = px - ex -- 3019
	local dyScreen = py + p.depth - (ey + eDepth) -- 3020
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3021
	if len < 0.01 then -- 3021
		return false -- 3023
	end -- 3023
	local ray = { -- 3027
		x = ex, -- 3028
		y = ey, -- 3028
		dx = dx / len, -- 3029
		dy = (py - ey) / len, -- 3029
		depth = eDepth, -- 3030
		dDepth = (p.depth - eDepth) / len -- 3030
	} -- 3030
	local best = -1 -- 3032
	local j = 0 -- 3033
	do -- 3033
		j = 0 -- 3034
		while j < #self.boxes do -- 3034
			do -- 3034
				local b = self.boxes[j + 1] -- 3035
				if b.broken == true or b.passable == true or b.hidden == true then -- 3035
					goto __continue491 -- 3037
				end -- 3037
				if b.id == "braced_shield" then -- 3037
					goto __continue491 -- 3042
				end -- 3042
				local t = hitBox(ray, b) -- 3044
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3044
					best = t -- 3048
				end -- 3048
			end -- 3048
			::__continue491:: -- 3048
			j = j + 1 -- 3034
		end -- 3034
	end -- 3034
	return best >= 0 -- 3051
end -- 3012
function Play.prototype.campaignEnemyFire(self, e) -- 3054
	local p = self.player -- 3055
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3056
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3056
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3056
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3058
		self.boxes = __TS__ArrayFilter( -- 3059
			self.boxes, -- 3059
			function(____, b) return b.id ~= "braced_shield" end -- 3059
		) -- 3059
		self.bracedShield = nil -- 3060
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3061
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3062
		return -- 3063
	end -- 3063
	if self:blockedShot(e, p) then -- 3063
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3066
		return -- 3067
	end -- 3067
	local cover = self:blockedByCover(e, p) -- 3069
	if cover ~= nil and self.coverHug then -- 3069
		self.coveredFlash = 0.5 -- 3071
		self:flashSet("掩体挡下", 0.6) -- 3072
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3073
		return -- 3078
	end -- 3078
	if self.invulnT > 0 then -- 3078
		return -- 3081
	end -- 3081
	local ____opt_50 = self.run.trial -- 3081
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3083
	self.craftT = 0 -- 3084
	self.hp = self.hp - 1 -- 3085
	self:emit("actorHit", { -- 3086
		target = "player", -- 3086
		amount = 1, -- 3086
		hp = self.hp, -- 3086
		maxHp = self.maxHp, -- 3086
		enemyX = e.x -- 3086
	}) -- 3086
	self:flashSet( -- 3087
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3087
		0.8 -- 3087
	) -- 3087
	if self.hp <= 0 then -- 3087
		self:campaignFailed() -- 3089
	end -- 3089
end -- 3054
function Play.prototype.stepShield(self, e, dt, input) -- 3094
	local p = self.player -- 3095
	local dx = p.x - e.x -- 3096
	local adx = math.abs(dx) -- 3097
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3100
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3101
	if adx > 150 then -- 3101
		local before = e.x -- 3103
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3104
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3104
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3107
		end -- 3107
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3107
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3112
		local rollDodges = p.rollT > 0 and fromFront -- 3113
		if not rollDodges and self.invulnT <= 0 then -- 3113
			local ____opt_52 = self.run.trial -- 3113
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3115
			self.craftT = 0 -- 3116
			self.hp = self.hp - 1 -- 3117
			self:emit("actorHit", { -- 3118
				target = "player", -- 3118
				amount = 1, -- 3118
				hp = self.hp, -- 3118
				maxHp = self.maxHp, -- 3118
				enemyX = e.x -- 3118
			}) -- 3118
			self:flashSet( -- 3119
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3119
				0.8 -- 3119
			) -- 3119
			if self.hp <= 0 then -- 3119
				self:campaignFailed() -- 3121
				return -- 3122
			end -- 3122
		end -- 3122
		e.swingT = 70 -- 3125
	end -- 3125
	if (e.swingT or 0) > 0 then -- 3125
		e.swingT = (e.swingT or 0) - 1 -- 3128
	end -- 3128
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3128
		local dd = p.depth - (e.depth or 0) -- 3131
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3132
	end -- 3132
end -- 3094
function Play.prototype.stepBreaker(self, e, dt) -- 3137
	local p = self.player -- 3138
	if e.awake ~= true then -- 3138
		if math.abs(p.x - e.x) < 560 then -- 3138
			e.awake = true -- 3141
		else -- 3141
			return -- 3143
		end -- 3143
	end -- 3143
	local target = nil -- 3146
	local bestD = 1000000000 -- 3147
	local i = 0 -- 3148
	do -- 3148
		i = 0 -- 3149
		while i < #self.boxes do -- 3149
			do -- 3149
				local b = self.boxes[i + 1] -- 3150
				if b.breakable == nil or b.broken == true then -- 3150
					goto __continue515 -- 3152
				end -- 3152
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3154
				if d < bestD then -- 3154
					bestD = d -- 3156
					target = b -- 3157
				end -- 3157
			end -- 3157
			::__continue515:: -- 3157
			i = i + 1 -- 3149
		end -- 3149
	end -- 3149
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3160
	local dx = tx - e.x -- 3161
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3162
	if math.abs(dx) > reach then -- 3162
		local before = e.x -- 3164
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3165
		if math.abs(e.x - before) < 0.3 then -- 3165
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3167
		end -- 3167
	elseif (e.swingT or 0) <= 0 then -- 3167
		e.swingT = 64 -- 3170
		if target ~= nil then -- 3170
			self:damageProp(target, 2) -- 3172
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3172
			local ____opt_54 = self.run.trial -- 3172
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3174
			self.craftT = 0 -- 3175
			self.hp = self.hp - 1 -- 3176
			self:emit("actorHit", { -- 3177
				target = "player", -- 3177
				amount = 1, -- 3177
				hp = self.hp, -- 3177
				maxHp = self.maxHp, -- 3177
				enemyX = e.x -- 3177
			}) -- 3177
			self:flashSet("破障手近身", 0.8) -- 3178
			if self.hp <= 0 then -- 3178
				self:campaignFailed() -- 3180
				return -- 3181
			end -- 3181
		end -- 3181
	end -- 3181
	if (e.swingT or 0) > 0 then -- 3181
		e.swingT = (e.swingT or 0) - 1 -- 3186
	end -- 3186
end -- 3137
function Play.prototype.campaignFailed(self) -- 3190
	if self.run.trial ~= nil then -- 3190
		self.run.trial.lost = true -- 3192
		self.wantRoom = "" -- 3193
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3194
		return -- 3195
	end -- 3195
	local p = self.player -- 3197
	self.hp = self.maxHp -- 3198
	self.invulnT = INVULN_RESPAWN_TICKS -- 3199
	self.reloadT = 0 -- 3200
	self:closeReloadPuzzle() -- 3201
	self.gripping = false -- 3202
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3203
	self:log("被击倒") -- 3204
	p.x = self.room.minX + 90 -- 3205
	p.y = 0 -- 3206
	p.depth = 0 -- 3207
	p.vx = 0 -- 3208
	p.vy = 0 -- 3209
	p.onGround = true -- 3210
	p.rollT = 0 -- 3211
	self.partner.x = p.x - 50 -- 3212
	self.partner.y = 0 -- 3213
	self.partner.depth = 0 -- 3214
	self.cam.x = p.x -- 3215
	local i = 0 -- 3216
	do -- 3216
		i = 0 -- 3217
		while i < #self.enemies do -- 3217
			do -- 3217
				local e = self.enemies[i + 1] -- 3218
				if not e.alive then -- 3218
					goto __continue528 -- 3220
				end -- 3220
				e.x = e.homeX == nil and e.x or e.homeX -- 3222
				e.warnT = 0 -- 3223
				e.fireCd = 40 -- 3224
				e.swingT = 0 -- 3225
				e.awake = false -- 3226
			end -- 3226
			::__continue528:: -- 3226
			i = i + 1 -- 3217
		end -- 3217
	end -- 3217
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3228
end -- 3190
function Play.prototype.stepEnemies(self, dt, input) -- 3231
	local i = 0 -- 3232
	do -- 3232
		i = 0 -- 3233
		while i < #self.enemies do -- 3233
			local e = self.enemies[i + 1] -- 3234
			if e.hitT > 0 then -- 3234
				e.hitT = e.hitT - dt -- 3236
			end -- 3236
			i = i + 1 -- 3233
		end -- 3233
	end -- 3233
	if self.coveredFlash > 0 then -- 3233
		self.coveredFlash = self.coveredFlash - dt -- 3240
	end -- 3240
	if self.isCampaign then -- 3240
		self:stepCampaignEnemies(dt, input) -- 3243
		return -- 3244
	end -- 3244
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3244
		return -- 3248
	end -- 3248
	do -- 3248
		i = 0 -- 3250
		while i < #self.enemies do -- 3250
			do -- 3250
				local e = self.enemies[i + 1] -- 3251
				if not e.alive then -- 3251
					goto __continue538 -- 3253
				end -- 3253
				if e.warnT > 0 then -- 3253
					e.warnT = e.warnT - 1 -- 3256
					if e.warnT <= 0 then -- 3256
						self:enemyFire(e, input) -- 3258
					end -- 3258
					goto __continue538 -- 3260
				end -- 3260
				if e.fireCd > 0 then -- 3260
					e.fireCd = e.fireCd - 1 -- 3263
					if e.fireCd <= 0 then -- 3263
						e.warnT = WARN_TICKS -- 3265
					end -- 3265
				else -- 3265
					e.warnT = WARN_TICKS -- 3269
				end -- 3269
			end -- 3269
			::__continue538:: -- 3269
			i = i + 1 -- 3250
		end -- 3250
	end -- 3250
end -- 3231
function Play.prototype.enemyFire(self, e, input) -- 3275
	local p = self.player -- 3276
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3276
		self:flashSet("枪声响在远处", 0.4) -- 3278
		e.fireCd = FIRE_COOLDOWN -- 3279
		return -- 3280
	end -- 3280
	local cover = self:blockedByCover(e, p) -- 3283
	local hugging = cover ~= nil -- 3284
	self.coverBlocking = hugging -- 3285
	local covered = hugging and input.cover.held -- 3286
	if covered then -- 3286
		self.coveredFlash = 0.5 -- 3288
		self:flashSet("掩体挡下", 0.5) -- 3289
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3290
		e.fireCd = FIRE_COOLDOWN -- 3295
		return -- 3296
	end -- 3296
	self.hp = self.hp - 1 -- 3298
	self:emit("actorHit", { -- 3299
		target = "player", -- 3299
		amount = 1, -- 3299
		hp = self.hp, -- 3299
		maxHp = self.maxHp, -- 3299
		enemyX = e.x -- 3299
	}) -- 3299
	self:flashSet( -- 3300
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3300
		0.7 -- 3300
	) -- 3300
	e.fireCd = FIRE_COOLDOWN -- 3301
	if self.hp <= 0 then -- 3301
		self:gateFailed() -- 3303
	end -- 3303
end -- 3275
function Play.prototype.blockedByCover(self, enemy, p) -- 3308
	local b = self:coverAt(p) -- 3309
	if b == nil then -- 3309
		return nil -- 3311
	end -- 3311
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3313
end -- 3308
function Play.prototype.gateFailed(self) -- 3317
	local ____temp_56 -- 3318
	if self.room.story == nil then -- 3318
		____temp_56 = nil -- 3318
	else -- 3318
		____temp_56 = self.room.story.gate -- 3318
	end -- 3318
	local g = ____temp_56 -- 3318
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3319
	self.hp = self.maxHp -- 3320
	self.gateTick = 0 -- 3321
	self.gateSpawned = 0 -- 3322
	self.enemies = {} -- 3323
	self.gateFailCount = self.gateFailCount + 1 -- 3324
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3326
	self.player.y = 0 -- 3327
	self.player.vy = 0 -- 3328
	self.player.depth = 0 -- 3329
	self.player.depthSpeed = 0 -- 3330
	self.player.onGround = true -- 3331
	self.player.crouch = false -- 3332
	self.player.h = SOLDIER_H -- 3333
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3334
	self.partner.y = 0 -- 3335
	self.partner.vy = 0 -- 3336
	self.partner.depth = 0 -- 3337
	self.partner.depthSpeed = 0 -- 3338
	self.partner.onGround = true -- 3339
	self.cam.x = self.player.x -- 3340
	self.phase = "gate-idle" -- 3341
	self.phaseTick = 0 -- 3342
	self.coverHug = false -- 3343
	self.coverBlocking = false -- 3344
	self.coverEntity = "" -- 3345
	self.gateNeedConfirm = true -- 3346
	self.gateRestartArmed = false -- 3347
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3348
end -- 3317
function Play.prototype.stepInteract(self, dt, input) -- 3351
	local p = self.player -- 3352
	local calmUsed = self.calmConsumed -- 3353
	self.calmConsumed = false -- 3354
	local calming = self.escort.state == "calming" -- 3356
	self.focusCart = false -- 3357
	if self.room.key == "outside" then -- 3357
		local c = self.room.cart -- 3359
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3360
		local dy = p.y - c.baseY -- 3361
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3362
	end -- 3362
	if not calmUsed and not calming then -- 3362
		self:stepCart(dt, input) -- 3366
	end -- 3366
	if calmUsed then -- 3366
		self:flashSet("安抚 · 敲两下", 0.8) -- 3371
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 3371
		if self.knockT > 0 then -- 3371
			self.knocks = self.knocks + 1 -- 3375
		else -- 3375
			self.knocks = 1 -- 3377
		end -- 3377
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3379
		self.knockT = 1.2 -- 3380
		if self.knocks >= 2 then -- 3380
			self:flashSet("敲两下", 0.8) -- 3382
			self.knocks = 0 -- 3383
		else -- 3383
			self:flashSet("敲一下", 0.5) -- 3385
		end -- 3385
	elseif self.knockT > 0 then -- 3385
		self.knockT = self.knockT - dt -- 3388
		if self.knockT <= 0 then -- 3388
			self.knocks = 0 -- 3390
		end -- 3390
	end -- 3390
	local i = 0 -- 3395
	do -- 3395
		i = 0 -- 3396
		while i < #self.room.marks do -- 3396
			do -- 3396
				local m = self.room.marks[i + 1] -- 3397
				if m.kind ~= 0 then -- 3397
					goto __continue564 -- 3399
				end -- 3399
				local subjects = {self.partner, self.player} -- 3401
				local k = 0 -- 3402
				do -- 3402
					k = 0 -- 3403
					while k < #subjects do -- 3403
						do -- 3403
							local s = subjects[k + 1] -- 3404
							if not s.alive then -- 3404
								goto __continue567 -- 3406
							end -- 3406
							local dx = s.x - m.x -- 3408
							local dy = s.y - m.y -- 3409
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3409
								self.checkpoint = m.x -- 3411
								self.checkpointCartAxle = self.cartAxle -- 3412
								if self.isCampaign then -- 3412
									self:captureCheckpoint(m.x) -- 3415
								end -- 3415
								if self.cartDocked then -- 3415
									self:flashSet("检查点 · 车已落窝", 1) -- 3418
								else -- 3418
									self:flashSet("检查点 · 车还没到位", 1) -- 3420
								end -- 3420
							end -- 3420
						end -- 3420
						::__continue567:: -- 3420
						k = k + 1 -- 3403
					end -- 3403
				end -- 3403
			end -- 3403
			::__continue564:: -- 3403
			i = i + 1 -- 3396
		end -- 3396
	end -- 3396
	self:checkCarryGate() -- 3426
end -- 3351
function Play.prototype.stepVillage(self, dt, input) -- 3430
	if self.room.key ~= "village" then -- 3430
		return -- 3432
	end -- 3432
	local p = self.player -- 3434
	local bottle = self.room.bottle -- 3435
	local scav = self.room.scavenger -- 3436
	if not self.hasBottle and bottle ~= nil then -- 3436
		local dx = p.x - bottle.x -- 3440
		local dy = p.y + p.h * 0.5 - bottle.y -- 3441
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3441
			self.hasBottle = true -- 3443
			self:flashSet("拾起瓶子", 0.8) -- 3444
		end -- 3444
	end -- 3444
	if self.hasBottle then -- 3444
		if input.aim.held then -- 3444
			self.aimHold = self.aimHold + dt -- 3451
			if self.aimHold > 1.2 then -- 3451
				self.aimHold = 1.2 -- 3453
			end -- 3453
			local cached = self:bottleEnd() -- 3456
			self.bottleAimX = cached.x -- 3457
			self.bottleAimY = cached.y -- 3458
		elseif input.aim.released then -- 3458
			if self.aimHold < 0.12 then -- 3458
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3462
				self.aimHold = 0 -- 3463
			else -- 3463
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3465
				self:throwBottle(____end.x, ____end.y) -- 3466
				self.aimHold = 0 -- 3467
			end -- 3467
		end -- 3467
	else -- 3467
		self.aimHold = 0 -- 3471
		self.bottleAimX = -1 -- 3472
	end -- 3472
	local fly = self.bottleFly -- 3477
	if fly ~= nil then -- 3477
		fly.t = fly.t + dt -- 3479
		fly.x = fly.x0 + fly.vx * fly.t -- 3480
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3481
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3482
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3482
			self:landBottle(fly) -- 3484
		end -- 3484
	end -- 3484
	if self.bottleLandT > 0 then -- 3484
		self.bottleLandT = self.bottleLandT - dt -- 3488
	end -- 3488
	if scav ~= nil then -- 3488
		self:stepScav(dt, scav) -- 3492
	end -- 3492
	local line = self.room.passLine -- 3495
	if line ~= nil and not self.passed and p.x >= line then -- 3495
		self.passed = true -- 3497
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3498
	end -- 3498
	if self.passed and p.x >= self.ox + 640 then -- 3498
		self:requestRoom("forest", "过第一院出院") -- 3502
		self:flashSet("出院 · 北塔森林", 1.4) -- 3503
	end -- 3503
end -- 3430
function Play.prototype.bottleEnd(self) -- 3508
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3509
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3512
	return {x = aim.x, y = g} -- 3513
end -- 3508
function Play.prototype.throwBottle(self, tx, ty) -- 3517
	local p = self.player -- 3518
	local dir = tx >= p.x and 1 or -1 -- 3520
	p.facing = dir -- 3521
	local x0 = p.x + dir * 10 -- 3522
	local y0 = p.y + p.h * 0.7 -- 3523
	self.bottleTargetX = tx -- 3524
	self.bottleTargetY = ty -- 3525
	self.bottleSurfaceY = ty -- 3526
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3527
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3528
	self.bottleFly = { -- 3529
		x = x0, -- 3529
		y = y0, -- 3529
		x0 = x0, -- 3529
		y0 = y0, -- 3529
		vx = vx, -- 3529
		vy = vy, -- 3529
		t = 0 -- 3529
	} -- 3529
	self.hasBottle = false -- 3530
	self:flashSet("投出", 0.4) -- 3531
	self:emit( -- 3532
		"bottleThrown", -- 3532
		{ -- 3532
			fromX = x0, -- 3533
			fromY = y0, -- 3534
			targetX = tx, -- 3535
			targetY = ty, -- 3536
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3537
		} -- 3537
	) -- 3537
end -- 3517
function Play.prototype.landBottle(self, fly) -- 3542
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3543
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3544
	local s = self.room.scavenger -- 3545
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3546
	self.bottleFly = nil -- 3547
	self.bottleTargetX = -1 -- 3548
	self.bottleTargetY = 0 -- 3549
	self.bottleSurfaceY = -1 -- 3550
	self.bottleLandX = x -- 3551
	self.bottleLandY = y -- 3552
	self.bottleLandT = 0.9 -- 3553
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3554
	self:hearBottle(x) -- 3555
end -- 3542
function Play.prototype.hearBottle(self, x) -- 3559
	local s = self.room.scavenger -- 3560
	if s == nil then -- 3560
		return -- 3562
	end -- 3562
	if math.abs(x - self.scavX) > s.range then -- 3562
		self:flashSet("落地 · 他没听见", 0.6) -- 3565
		return -- 3566
	end -- 3566
	self.scavState = "turn" -- 3568
	self.scavT = s.hearTicks -- 3569
	self.scavTargetX = x -- 3570
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3571
end -- 3559
function Play.prototype.stepScav(self, dt, s) -- 3575
	if self.scavState == "chase" then -- 3575
		return -- 3578
	end -- 3578
	if self.scavState == "turn" then -- 3578
		self.scavT = self.scavT - 1 -- 3581
		if self.scavT <= 0 then -- 3581
			self.scavState = "walk" -- 3583
		end -- 3583
		return -- 3585
	end -- 3585
	if self.scavState == "walk" then -- 3585
		local d = self.scavTargetX - self.scavX -- 3588
		if math.abs(d) < 4 then -- 3588
			self.scavState = "stall" -- 3590
			self.scavT = s.stallTicks -- 3591
			return -- 3592
		end -- 3592
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3594
		return -- 3595
	end -- 3595
	if self.scavState == "stall" then -- 3595
		self.scavT = self.scavT - 1 -- 3598
		if self.scavT <= 0 then -- 3598
			self.scavState = "back" -- 3600
		end -- 3600
		return -- 3602
	end -- 3602
	if self.scavState == "back" then -- 3602
		local home = math.max( -- 3605
			s.x0, -- 3605
			math.min(s.x1, self.scavX) -- 3605
		) -- 3605
		if math.abs(home - self.scavX) < 2 then -- 3605
			self.scavState = "patrol" -- 3607
			return -- 3608
		end -- 3608
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3610
		return -- 3611
	end -- 3611
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3613
	if self.scavX >= s.x1 then -- 3613
		self.scavX = s.x1 -- 3615
		self.scavDir = -1 -- 3616
	elseif self.scavX <= s.x0 then -- 3616
		self.scavX = s.x0 -- 3618
		self.scavDir = 1 -- 3619
	end -- 3619
end -- 3575
function Play.prototype.stepCart(self, dt, input) -- 3627
	local p = self.player -- 3628
	local c = self.room.cart -- 3629
	if self.gripping then -- 3629
		if not input.interact.held then -- 3629
			self.gripping = false -- 3633
			self:flashSet("松开车把", 0.4) -- 3634
			return -- 3635
		end -- 3635
	else -- 3635
		if not input.interact.pressed then -- 3635
			return -- 3639
		end -- 3639
		if not self:cartHandleInReach(p) then -- 3639
			return -- 3642
		end -- 3642
		local track = c.depth or 0 -- 3644
		if self:limitDepth(p, track) ~= track then -- 3644
			return -- 3646
		end -- 3646
		p.depth = track -- 3648
		p.depthSpeed = 0 -- 3649
		self.gripping = true -- 3650
		self:flashSet("握住车把", 0.4) -- 3651
		return -- 3652
	end -- 3652
	if self.cartDocked then -- 3652
		return -- 3656
	end -- 3656
	local dir = input.moveX -- 3658
	if dir == 0 then -- 3658
		return -- 3660
	end -- 3660
	local lo = math.min(c.startX, c.endX) -- 3662
	local hi = math.max(c.startX, c.endX) -- 3663
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3664
	if next < lo then -- 3664
		next = lo -- 3666
	end -- 3666
	if next > hi then -- 3666
		next = hi -- 3669
	end -- 3669
	local delta = next - self.cartAxle -- 3671
	if delta == 0 then -- 3671
		return -- 3673
	end -- 3673
	self.cartAxle = next -- 3675
	p.x = p.x + delta -- 3676
	p.facing = dir > 0 and 1 or -1 -- 3677
	self:slideX(p, 0) -- 3678
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3678
		self.gripping = false -- 3680
		self:flashSet("跟不上了，脱手", 0.6) -- 3681
		return -- 3682
	end -- 3682
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3682
		self.cartDocked = true -- 3685
		self.gripping = false -- 3686
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3687
		self:flashSet("车轮落窝", 1.2) -- 3688
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3688
		self:flashSet("车轮回到起点", 0.5) -- 3690
	end -- 3690
end -- 3627
function Play.prototype.requestRoom(self, key, reason) -- 3698
	if self.wantRoom ~= "" then -- 3698
		return -- 3702
	end -- 3702
	self.wantRoom = key -- 3704
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3705
end -- 3698
function Play.prototype.checkCarryGate(self) -- 3712
	if self.room.key == "checkpoint" then -- 3712
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3712
			self.carryCartAxle = self.cartAxle -- 3715
			self.carryCartDocked = self.cartDocked -- 3716
			self:requestRoom("gate", "检查站出口") -- 3717
			self:flashSet("出检查站 · 城门", 1.2) -- 3718
		end -- 3718
		return -- 3720
	end -- 3720
	if self.room.key == "outside" then -- 3720
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3720
			self.carryCartAxle = self.cartAxle -- 3726
			self.carryCartDocked = self.cartDocked -- 3727
			self:requestRoom("village", "墙根走完") -- 3728
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3729
		end -- 3729
	end -- 3729
end -- 3712
function Play.prototype.aimAt(self, wx, wy) -- 3736
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3737
	self.aimX = s.x -- 3738
	self.aimY = s.y -- 3739
end -- 3736
function Play.prototype.shoot(self, a) -- 3742
	if self.isCampaign and self.reloadT > 0 then -- 3742
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3744
		return -- 3745
	end -- 3745
	local ox = a.x + a.facing * 8 -- 3747
	local muzzleY = a.y + a.h * 0.72 -- 3748
	local oy = muzzleY + a.depth -- 3749
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3751
	local dx = aim.x - ox -- 3754
	local dy = aim.y - oy -- 3755
	local len = math.sqrt(dx * dx + dy * dy) -- 3756
	if len < 0.001 then -- 3756
		dx = a.facing -- 3758
		dy = 0 -- 3759
	else -- 3759
		dx = dx / len -- 3761
		dy = dy / len -- 3762
	end -- 3762
	if dx ~= 0 then -- 3762
		a.facing = dx > 0 and 1 or -1 -- 3765
	end -- 3765
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3768
	local hitEnemy = self:raycastEnemies(ray) -- 3769
	local tEnemy = hitEnemy.t -- 3770
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3771
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3772
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3773
	local tWall = solid.t -- 3774
	local rawEffect = self:consumeReloadEffect() -- 3776
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 3777
	local reloadEffect = rawEffect -- 3778
	if rawEffect == "light" and weaponFx ~= "light" then -- 3778
		reloadEffect = "push" -- 3780
	end -- 3780
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light" and weaponFx == "light") -- 3782
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3783
	self.trace = { -- 3785
		x0 = ox, -- 3785
		y0 = oy, -- 3785
		x1 = ox + dx * t, -- 3785
		y1 = oy + dy * t, -- 3785
		hit = hit -- 3785
	} -- 3785
	self.traceT = 0.12 -- 3786
	self:applyFireDanger(ox) -- 3787
	local killed = false -- 3788
	if hit then -- 3788
		local i = hitEnemy.index -- 3790
		local e = self.enemies[i + 1] -- 3791
		local impactY = oy + dy * tEnemy -- 3792
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3793
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3794
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3794
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3796
			e.hitT = 0.3 -- 3797
			self:flashSet( -- 3798
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3798
				0.8 -- 3798
			) -- 3798
			self:emit("shotResolved", { -- 3799
				hit = true, -- 3800
				enemyIndex = i, -- 3800
				enemyX = e.x, -- 3800
				aimX = aim.x, -- 3800
				aimY = aim.y, -- 3800
				impactX = ox + dx * t, -- 3801
				impactY = oy + dy * t, -- 3801
				shield = true -- 3801
			}) -- 3801
			self:beginReload() -- 3803
			return -- 3804
		end -- 3804
		e.alive = false -- 3806
		e.hitT = 0.4 -- 3807
		killed = true -- 3808
		self:flashSet("命中", 0.6) -- 3809
		self:dropFor(e) -- 3810
		if reloadEffect == "push" then -- 3810
			e.x = e.x + a.facing * 46 -- 3812
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 3813
		elseif reloadEffect == "echo" then -- 3813
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 3815
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 3816
		elseif reloadEffect == "light" then -- 3816
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 3818
		end -- 3818
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3818
		self:damageProp(solid.box, 1) -- 3821
	else -- 3821
		self:flashSet("打空", 0.35) -- 3823
	end -- 3823
	if self.isCampaign then -- 3823
		self:beginReload() -- 3826
	end -- 3826
	self:emit("shotResolved", { -- 3828
		hit = hit, -- 3829
		enemyIndex = hit and hitEnemy.index or -1, -- 3830
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3831
		aimX = aim.x, -- 3832
		aimY = aim.y, -- 3833
		impactX = ox + dx * t, -- 3834
		impactY = oy + dy * t -- 3835
	}) -- 3835
end -- 3742
function Play.prototype.applyFireDanger(self, shotX) -- 3840
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3840
		return -- 3842
	end -- 3842
	local dangerX = shotX -- 3844
	local best = -1 -- 3845
	local bestD = 1000000000 -- 3846
	local i = 0 -- 3847
	do -- 3847
		i = 0 -- 3848
		while i < #self.enemies do -- 3848
			do -- 3848
				local e = self.enemies[i + 1] -- 3849
				if not e.alive then -- 3849
					goto __continue648 -- 3851
				end -- 3851
				local d = math.abs(e.x - self.partner.x) -- 3853
				if d < bestD then -- 3853
					bestD = d -- 3855
					best = i -- 3856
				end -- 3856
			end -- 3856
			::__continue648:: -- 3856
			i = i + 1 -- 3848
		end -- 3848
	end -- 3848
	if best >= 0 then -- 3848
		dangerX = self.enemies[best + 1].x -- 3860
	end -- 3860
	local exposed = self:childExposed(dangerX) -- 3862
	local before = self.escort.fear -- 3863
	local dangerId = self.nextDangerId -- 3864
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 3865
	self.nextDangerId = self.nextDangerId + 1 -- 3866
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 3867
	if after > before then -- 3867
		self:flashSet( -- 3869
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 3869
			1 -- 3869
		) -- 3869
	elseif not exposed then -- 3869
		self:flashSet("枪声没够到她", 0.5) -- 3871
	end -- 3871
end -- 3840
function Play.prototype.childExposed(self, dangerX) -- 3876
	local c = self.partner -- 3877
	if not c.alive then -- 3877
		return false -- 3879
	end -- 3879
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 3879
		self.boxes, -- 3882
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 3882
	) then -- 3882
		return false -- 3883
	end -- 3883
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 3883
		return false -- 3886
	end -- 3886
	local toDanger = dangerX - c.x -- 3888
	local toPlayer = self.player.x - c.x -- 3889
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 3889
		return false -- 3892
	end -- 3892
	return true -- 3894
end -- 3876
function Play.prototype.raycastEnemies(self, ray) -- 3898
	local best = -1 -- 3899
	local bestI = -1 -- 3900
	do -- 3900
		local i = 0 -- 3901
		while i < #self.enemies do -- 3901
			do -- 3901
				local e = self.enemies[i + 1] -- 3902
				if not e.alive then -- 3902
					goto __continue662 -- 3904
				end -- 3904
				local y = e.y + (e.depth or 0) -- 3906
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 3907
				if t >= 0 and (best < 0 or t < best) then -- 3907
					best = t -- 3909
					bestI = i -- 3910
				end -- 3910
			end -- 3910
			::__continue662:: -- 3910
			i = i + 1 -- 3901
		end -- 3901
	end -- 3901
	return {t = best, index = bestI} -- 3913
end -- 3898
function Play.prototype.raycastWorld(self, ray) -- 3916
	return self:raycastSolid(ray).t -- 3917
end -- 3916
function Play.prototype.raycastSolid(self, ray) -- 3921
	local best = -1 -- 3922
	local bestBox = nil -- 3923
	for ____, box in ipairs(self.boxes) do -- 3924
		do -- 3924
			if box.broken == true or box.hidden == true then -- 3924
				goto __continue667 -- 3926
			end -- 3926
			local t = hitBox(ray, box) -- 3931
			if t > 2 and (best < 0 or t < best) then -- 3931
				best = t -- 3934
				bestBox = box -- 3935
			end -- 3935
		end -- 3935
		::__continue667:: -- 3935
	end -- 3935
	if ray.dy < 0 then -- 3935
		local t = -ray.y / ray.dy -- 3939
		if t >= 0 and (best < 0 or t < best) then -- 3939
			best = t -- 3941
			bestBox = nil -- 3942
		end -- 3942
	end -- 3942
	return {t = best, box = bestBox} -- 3945
end -- 3921
function Play.prototype.dropFor(self, e) -- 3949
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 3949
		return -- 3951
	end -- 3951
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 3951
		return -- 3954
	end -- 3954
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 3956
	local ____self_pickups_57 = self.pickups -- 3956
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 3957
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 3958
		kind = e.drop, -- 3958
		x = e.x, -- 3958
		y = e.y, -- 3958
		depth = e.depth, -- 3959
		label = label .. " ×1" -- 3959
	} -- 3959
	self:log("掉落 " .. label) -- 3961
end -- 3949
function Play.prototype.damageProp(self, b, amount) -- 3965
	if b.breakable == nil or b.broken == true then -- 3965
		return -- 3967
	end -- 3967
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 3967
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 3969
	if b.breakable.hp > 0 then -- 3969
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 3971
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 3972
		return -- 3973
	end -- 3973
	b.broken = true -- 3975
	for ____, other in ipairs(self.boxes) do -- 3976
		if other.id ~= nil and other.id == b.id then -- 3976
			other.broken = true -- 3978
		end -- 3978
	end -- 3978
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 3981
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 3982
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 3983
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 3984
end -- 3965
function Play.prototype.slideDepth(self, a, distance) -- 3988
	a.depth = self:limitDepth(a, a.depth + distance) -- 3989
end -- 3988
function Play.prototype.limitDepth(self, a, target) -- 3992
	local road = self.room.depth -- 3993
	if road == nil or target == a.depth then -- 3993
		return a.depth -- 3995
	end -- 3995
	local next = math.max( -- 3997
		road.min, -- 3997
		math.min(road.max, target) -- 3997
	) -- 3997
	local half = a.w / 2 -- 3998
	for ____, b in ipairs(self.boxes) do -- 3999
		do -- 3999
			local footprint = b.depth -- 4000
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4000
				goto __continue685 -- 4005
			end -- 4005
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4007
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4008
			if a.depth <= front and next > front then -- 4008
				next = front -- 4010
			elseif a.depth >= back and next < back then -- 4010
				next = back -- 4012
			end -- 4012
		end -- 4012
		::__continue685:: -- 4012
	end -- 4012
	return next -- 4015
end -- 3992
function Play.prototype.slideX(self, a, dx) -- 4019
	local nx = a.x + dx -- 4020
	local half = a.w / 2 -- 4021
	local room = self.room -- 4022
	nx = math.max( -- 4023
		room.minX + half, -- 4023
		math.min(room.maxX - half, nx) -- 4023
	) -- 4023
	local i = 0 -- 4024
	do -- 4024
		i = 0 -- 4025
		while i < #self.boxes do -- 4025
			do -- 4025
				local b = self.boxes[i + 1] -- 4026
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4026
					goto __continue692 -- 4028
				end -- 4028
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4028
					goto __continue692 -- 4031
				end -- 4031
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4031
					goto __continue692 -- 4034
				end -- 4034
				if nx + half > b.x0 and nx - half < b.x1 then -- 4034
					if a.x <= b.x0 then -- 4034
						nx = b.x0 - half -- 4038
					elseif a.x >= b.x1 then -- 4038
						nx = b.x1 + half -- 4040
					else -- 4040
						nx = a.x -- 4042
					end -- 4042
				end -- 4042
			end -- 4042
			::__continue692:: -- 4042
			i = i + 1 -- 4025
		end -- 4025
	end -- 4025
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4025
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4050
		local bx0 = self.cartAxle - CART_HALF -- 4051
		local bx1 = self.cartAxle + CART_HALF -- 4052
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4052
			if a.x <= bx0 then -- 4052
				nx = bx0 - half -- 4055
			elseif a.x >= bx1 then -- 4055
				nx = bx1 + half -- 4057
			else -- 4057
				nx = a.x -- 4059
			end -- 4059
		end -- 4059
	end -- 4059
	local arch = room.arch -- 4067
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4067
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4069
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4069
			if a.x <= arch.x0 then -- 4069
				nx = arch.x0 - half -- 4072
			elseif a.x >= arch.x1 then -- 4072
				nx = arch.x1 + half -- 4074
			end -- 4074
		end -- 4074
	end -- 4074
	a.x = nx -- 4078
end -- 4019
function Play.prototype.fallY(self, a, dt) -- 4082
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4083
	if a.vy < -900 then -- 4083
		a.vy = -900 -- 4085
	end -- 4085
	local ny = a.y + a.vy * dt -- 4087
	local half = a.w / 2 -- 4088
	if a.vy <= 0 then -- 4088
		local reach = a.onGround and STEP_UP or 0 -- 4091
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4092
		if ny <= ground then -- 4092
			ny = ground -- 4094
			a.vy = 0 -- 4095
			a.onGround = true -- 4096
		else -- 4096
			a.onGround = false -- 4098
		end -- 4098
	else -- 4098
		a.onGround = false -- 4101
		local i = 0 -- 4102
		do -- 4102
			i = 0 -- 4103
			while i < #self.boxes do -- 4103
				do -- 4103
					local b = self.boxes[i + 1] -- 4104
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4104
						goto __continue716 -- 4106
					end -- 4106
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4106
						goto __continue716 -- 4109
					end -- 4109
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4109
						goto __continue716 -- 4112
					end -- 4112
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4112
						ny = b.y0 - a.h -- 4115
						a.vy = 0 -- 4116
					end -- 4116
				end -- 4116
				::__continue716:: -- 4116
				i = i + 1 -- 4103
			end -- 4103
		end -- 4103
	end -- 4103
	a.y = ny -- 4120
end -- 4082
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4124
	if depth == nil then -- 4124
		depth = 0 -- 4124
	end -- 4124
	local g = -9999 -- 4125
	local i = 0 -- 4126
	do -- 4126
		i = 0 -- 4127
		while i < #self.floors do -- 4127
			local f = self.floors[i + 1] -- 4128
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4128
				g = f.y1 -- 4130
			end -- 4130
			i = i + 1 -- 4127
		end -- 4127
	end -- 4127
	do -- 4127
		i = 0 -- 4133
		while i < #self.boxes do -- 4133
			do -- 4133
				local b = self.boxes[i + 1] -- 4134
				if b.broken == true or b.hidden == true or b.soft == true then -- 4134
					goto __continue726 -- 4136
				end -- 4136
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4136
					g = b.y1 -- 4140
				end -- 4140
			end -- 4140
			::__continue726:: -- 4140
			i = i + 1 -- 4133
		end -- 4133
	end -- 4133
	return g -- 4143
end -- 4124
function Play.prototype.updateCamera(self, dt) -- 4146
	local p = self.player -- 4147
	local tx = p.x + p.facing * 30 -- 4148
	local ty = p.y + CAM_LOOK_UP -- 4149
	local k = math.min(1, CAM_FOLLOW * dt) -- 4150
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4151
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4152
end -- 4146
function Play.prototype.clampCamera(self, w, h) -- 4156
	local room = self.room -- 4157
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4158
	local spanX = room.maxX - room.minX -- 4159
	if spanX <= halfW * 2 then -- 4159
		self.cam.x = (room.minX + room.maxX) / 2 -- 4161
	else -- 4161
		self.cam.x = math.max( -- 4163
			room.minX + halfW, -- 4163
			math.min(room.maxX - halfW, self.cam.x) -- 4163
		) -- 4163
	end -- 4163
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4166
	local spanY = room.height -- 4167
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4168
	if spanY <= halfH * 2 then -- 4168
		self.cam.y = camY -- 4170
	else -- 4170
		self.cam.y = math.max( -- 4172
			camY, -- 4172
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4172
		) -- 4172
	end -- 4172
end -- 4156
function Play.prototype.flashSet(self, text, t) -- 4176
	self.flash = text -- 4177
	self.flashT = t -- 4178
end -- 4176
function Play.prototype.statusText(self) -- 4182
	local p = self.player -- 4183
	local parts = {} -- 4184
	local who = self.childMode and "小满" or "周戍" -- 4185
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4186
	if self.room.key == "prologue" then -- 4186
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4189
		if self.phase == "prologue-wait" then -- 4189
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4191
		elseif self.phase == "prologue-give" then -- 4191
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4193
		else -- 4193
			parts[#parts + 1] = "跟随" -- 4195
		end -- 4195
		if self.paused then -- 4195
			parts[#parts + 1] = "已暂停" -- 4198
		end -- 4198
		return table.concat(parts, " · ") -- 4200
	end -- 4200
	if self.room.key == "street" then -- 4200
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4203
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4204
		if self.paused then -- 4204
			parts[#parts + 1] = "已暂停" -- 4206
		end -- 4206
		return table.concat(parts, " · ") -- 4208
	end -- 4208
	if self.room.key == "gate" then -- 4208
		local ____temp_60 -- 4211
		if self.room.story == nil then -- 4211
			____temp_60 = nil -- 4211
		else -- 4211
			____temp_60 = self.room.story.gate -- 4211
		end -- 4211
		local g = ____temp_60 -- 4211
		if g ~= nil then -- 4211
			parts[#parts + 1] = self:gateLabel() -- 4213
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4214
				0, -- 4215
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4215
			))) .. " 秒" -- 4215
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4216
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4217
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4218
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4219
			if self.gateFailCount > 0 then -- 4219
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4221
			end -- 4221
			if self.flash ~= "" then -- 4221
				parts[#parts + 1] = self.flash -- 4224
			end -- 4224
		end -- 4224
		if self.paused then -- 4224
			parts[#parts + 1] = "已暂停" -- 4228
		end -- 4228
		return table.concat(parts, " · ") -- 4230
	end -- 4230
	if self.room.key == "forest" then -- 4230
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4233
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4234
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4235
		if self.caughtT > 0 then -- 4235
			parts[#parts + 1] = "复位中" -- 4237
		end -- 4237
		if self.paused then -- 4237
			parts[#parts + 1] = "已暂停" -- 4240
		end -- 4240
		return table.concat(parts, " · ") -- 4242
	end -- 4242
	if self.room.key == "tower" then -- 4242
		if self.phase == "tower-wait" then -- 4242
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4246
		elseif self.phase == "tower-knock" then -- 4246
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4248
		elseif self.phase == "tower-given" then -- 4248
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4250
		else -- 4250
			parts[#parts + 1] = "片尾" -- 4252
		end -- 4252
		if self.paused then -- 4252
			parts[#parts + 1] = "已暂停" -- 4255
		end -- 4255
		return table.concat(parts, " · ") -- 4257
	end -- 4257
	if self.room.key == "village" then -- 4257
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4260
		if self.hasBottle then -- 4260
			parts[#parts + 1] = "有瓶" -- 4262
		elseif self.bottleFly ~= nil then -- 4262
			parts[#parts + 1] = "瓶在飞" -- 4264
		else -- 4264
			parts[#parts + 1] = "空手" -- 4266
		end -- 4266
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4268
		if self.scavChase then -- 4268
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4270
		end -- 4270
		if self.passed then -- 4270
			parts[#parts + 1] = "已过通行线" -- 4273
		end -- 4273
		if self.paused then -- 4273
			parts[#parts + 1] = "已暂停" -- 4276
		end -- 4276
		return table.concat(parts, " · ") -- 4278
	end -- 4278
	local isChild = self.childMode -- 4281
	if isChild then -- 4281
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4283
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4284
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4285
	else -- 4285
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4287
		if p.rollT > 0 then -- 4287
			parts[#parts + 1] = "翻滚中" -- 4289
		end -- 4289
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4291
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4292
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4293
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4294
	end -- 4294
	if self.checkpoint >= 0 then -- 4294
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4297
	end -- 4297
	if self.paused then -- 4297
		parts[#parts + 1] = "已暂停" -- 4300
	end -- 4300
	return table.concat(parts, " · ") -- 4302
end -- 4182
function Play.prototype.aliveEnemies(self) -- 4306
	local n = 0 -- 4307
	local i = 0 -- 4308
	do -- 4308
		i = 0 -- 4309
		while i < #self.enemies do -- 4309
			if self.enemies[i + 1].alive then -- 4309
				n = n + 1 -- 4311
			end -- 4311
			i = i + 1 -- 4309
		end -- 4309
	end -- 4309
	return n -- 4314
end -- 4306
function Play.prototype.threatened(self) -- 4319
	do -- 4319
		local i = 0 -- 4320
		while i < #self.enemies do -- 4320
			local e = self.enemies[i + 1] -- 4321
			if e.alive and e.warnT > 0 then -- 4321
				return true -- 4323
			end -- 4323
			i = i + 1 -- 4320
		end -- 4320
	end -- 4320
	return false -- 4326
end -- 4319
function Play.prototype.gateSecondsLeft(self) -- 4329
	local ____temp_61 -- 4330
	if self.room.story == nil then -- 4330
		____temp_61 = nil -- 4330
	else -- 4330
		____temp_61 = self.room.story.gate -- 4330
	end -- 4330
	local g = ____temp_61 -- 4330
	if g == nil then -- 4330
		return 0 -- 4332
	end -- 4332
	return math.max( -- 4334
		0, -- 4334
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4334
	) -- 4334
end -- 4329
function Play.prototype.gateLabel(self) -- 4337
	if self.phase == "gate-idle" then -- 4337
		return "待就位" -- 4339
	end -- 4339
	if self.phase == "gate-hold" then -- 4339
		return "守点中" -- 4342
	end -- 4342
	if self.phase == "gate-send" then -- 4342
		return "送别" -- 4345
	end -- 4345
	if self.phase == "gate-count" then -- 4345
		return "数数 " .. tostring(self.countTick) -- 4348
	end -- 4348
	return "她走" -- 4350
end -- 4337
function Play.prototype.dogLabel(self) -- 4354
	if self.dogState == "ear" then -- 4354
		return "转耳" -- 4356
	end -- 4356
	if self.dogState == "chase" then -- 4356
		return "追" -- 4359
	end -- 4359
	if self.dogState == "sniff" then -- 4359
		return "停" -- 4362
	end -- 4362
	if self.dogState == "back" then -- 4362
		return "回线" -- 4365
	end -- 4365
	return "巡逻" -- 4367
end -- 4354
function Play.prototype.doorXOf(self) -- 4370
	local ____temp_62 -- 4371
	if self.room.story == nil then -- 4371
		____temp_62 = nil -- 4371
	else -- 4371
		____temp_62 = self.room.story.tower -- 4371
	end -- 4371
	local t = ____temp_62 -- 4371
	return t == nil and 0 or t.doorX -- 4372
end -- 4370
function Play.prototype.scavLabel(self) -- 4376
	if self.scavState == "chase" then -- 4376
		return "追" -- 4378
	end -- 4378
	if self.scavState == "turn" then -- 4378
		return "转头" -- 4381
	end -- 4381
	if self.scavState == "walk" then -- 4381
		return "赶来" -- 4384
	end -- 4384
	if self.scavState == "stall" then -- 4384
		return "停住" -- 4387
	end -- 4387
	if self.scavState == "back" then -- 4387
		return "回位" -- 4390
	end -- 4390
	return "巡逻" -- 4392
end -- 4376
function Play.prototype.hintText(self) -- 4396
	if self.paused then -- 4396
		return "Esc 继续 · R 重置" -- 4398
	end -- 4398
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4398
		if self:threatened() then -- 4398
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4404
		end -- 4404
		if self.coverHug then -- 4404
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4407
		end -- 4407
		if self.coverNear then -- 4407
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4410
		end -- 4410
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4412
	end -- 4412
	if self.flash ~= "" then -- 4412
		return self.flash -- 4415
	end -- 4415
	if self.room.key == "prologue" then -- 4415
		if self.phase == "prologue-wait" then -- 4415
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4419
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4420
		end -- 4420
		if self.phase == "prologue-give" then -- 4420
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4423
		end -- 4423
		return "她跟着你了 · 两人一起走到门口 680" -- 4425
	end -- 4425
	if self.room.key == "street" then -- 4425
		if self:aliveEnemies() > 0 then -- 4425
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4429
		end -- 4429
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4431
	end -- 4431
	if self.room.key == "gate" then -- 4431
		local ____temp_63 -- 4434
		if self.room.story == nil then -- 4434
			____temp_63 = nil -- 4434
		else -- 4434
			____temp_63 = self.room.story.gate -- 4434
		end -- 4434
		local g = ____temp_63 -- 4434
		if g ~= nil then -- 4434
			if self.phase == "gate-idle" then -- 4434
				if self.gateNeedConfirm then -- 4434
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4438
				end -- 4438
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4440
			end -- 4440
			if self.phase == "gate-hold" then -- 4440
				if self.coveredFlash > 0 then -- 4440
					return "掩体挡下了这一枪 · 别露头" -- 4444
				end -- 4444
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4446
			end -- 4446
			if self.phase == "gate-send" then -- 4446
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4449
			end -- 4449
			if self.phase == "gate-count" then -- 4449
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4449
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4453
				end -- 4453
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4455
			end -- 4455
			return "她自己走 · 跟着出城门 1120" -- 4457
		end -- 4457
	end -- 4457
	if self.room.key == "forest" then -- 4457
		if self.dogState == "chase" then -- 4457
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4462
		end -- 4462
		if self.dogState == "ear" then -- 4462
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4465
		end -- 4465
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4467
	end -- 4467
	if self.room.key == "tower" then -- 4467
		if self.phase == "tower-wait" then -- 4467
			return "走到门前 445 点一次 E 敲两下" -- 4471
		end -- 4471
		if self.phase == "tower-knock" then -- 4471
			return "敲两下 · 等门开" -- 4474
		end -- 4474
		if self.phase == "tower-given" then -- 4474
			return "递交针套和纸条 · 看登记簿最后一行" -- 4477
		end -- 4477
		return "片尾 · 点 E 再玩一次，回到序章" -- 4479
	end -- 4479
	if self.room.key == "village" then -- 4479
		if self.bottleFly ~= nil then -- 4479
			return "等瓶子落地 · 触地才发声" -- 4483
		end -- 4483
		if self.hasBottle then -- 4483
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4486
		end -- 4486
		if self.passed then -- 4486
			return "已过第一院 · R 重置可再来一遍" -- 4489
		end -- 4489
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4491
	end -- 4491
	if self.room.key == "outside" then -- 4491
		if self.focusCart then -- 4491
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4495
		end -- 4495
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4497
	end -- 4497
	if self.escort.state == "frozen" then -- 4497
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4497
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4501
		end -- 4501
		return "小满吓住了 · 走过去，靠近再点 E" -- 4503
	end -- 4503
	if self.escort.state == "calming" then -- 4503
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4506
	end -- 4506
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4508
end -- 4396
function Play.prototype.draw(self, draw, w, h) -- 4513
	self.viewW = w -- 4514
	self.viewH = h -- 4515
	self.view = ____exports.computeViewport(w, h) -- 4516
	self:clampCamera(w, h) -- 4517
	draw:clear() -- 4518
	draw:drawRect( -- 4520
		Rect(0, 0, w, h), -- 4520
		BG_VOID -- 4520
	) -- 4520
	local box = self:canvasRect(w, h) -- 4521
	draw:drawRect(box, BG_FAR) -- 4522
	draw:drawRect( -- 4523
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4523
		BG_MID -- 4523
	) -- 4523
	self:drawFloors(draw, w, h) -- 4525
	self:drawSolids(draw, w, h) -- 4526
	self:drawZones(draw, w, h) -- 4527
	self:drawArch(draw, w, h) -- 4528
	self:drawCart(draw, w, h) -- 4529
	self:drawCampaignProps(draw, w, h) -- 4530
	self:drawActors(draw, w, h) -- 4531
	self:drawTrace(draw, w, h) -- 4532
	self:drawAim(draw, w, h) -- 4533
end -- 4513
function Play.prototype.canvasRect(self, w, h) -- 4537
	local v = self.view -- 4538
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4539
end -- 4537
function Play.prototype.px(self, n) -- 4543
	return n * self.view.zoom -- 4544
end -- 4543
function Play.prototype.sx(self, wx, w) -- 4548
	local v = self.view -- 4549
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4550
	return v.ox + lx * v.zoom -- 4551
end -- 4548
function Play.prototype.sy(self, wy, h) -- 4555
	local v = self.view -- 4556
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4557
	return v.oy + ly * v.zoom -- 4558
end -- 4555
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4561
	local px0 = self:sx(x0, w) -- 4562
	local px1 = self:sx(x1, w) -- 4563
	local py0 = self:sy(y0, h) -- 4564
	local py1 = self:sy(y1, h) -- 4565
	if px1 <= px0 or py1 <= py0 then -- 4565
		return -- 4567
	end -- 4567
	draw:drawRect( -- 4569
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4569
		color -- 4569
	) -- 4569
end -- 4561
function Play.prototype.drawFloors(self, draw, w, h) -- 4572
	local i = 0 -- 4573
	do -- 4573
		i = 0 -- 4574
		while i < #self.room.floors do -- 4574
			local f = self.room.floors[i + 1] -- 4575
			local ____temp_64 -- 4576
			if f.y == 0 then -- 4576
				____temp_64 = self.room.depth -- 4576
			else -- 4576
				____temp_64 = nil -- 4576
			end -- 4576
			local road = ____temp_64 -- 4576
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4577
			local x0 = self:sx(f.x0, w) -- 4578
			local x1 = self:sx(f.x1, w) -- 4579
			local deck = self:px(5) -- 4580
			if road ~= nil then -- 4580
				local back = self:sy(f.y + road.max, h) -- 4582
				draw:drawRect( -- 4583
					Rect(x0, y, x1 - x0, back - y), -- 4583
					FLOOR_DECK, -- 4583
					self:px(1), -- 4583
					SOLID_EDGE -- 4583
				) -- 4583
			end -- 4583
			draw:drawRect( -- 4585
				Rect(x0, y - deck, x1 - x0, deck), -- 4585
				FLOOR_DECK -- 4585
			) -- 4585
			draw:drawSegment( -- 4586
				Vec2(x0, y), -- 4586
				Vec2(x1, y), -- 4586
				self:px(1), -- 4586
				GROUND -- 4586
			) -- 4586
			i = i + 1 -- 4574
		end -- 4574
	end -- 4574
end -- 4572
function Play.prototype.drawSolids(self, draw, w, h) -- 4590
	local i = 0 -- 4591
	do -- 4591
		i = 0 -- 4592
		while i < #self.boxes do -- 4592
			do -- 4592
				local b = self.boxes[i + 1] -- 4593
				if b.id == "braced_shield" or b.hidden == true then -- 4593
					goto __continue847 -- 4595
				end -- 4595
				if b.broken == true then -- 4595
					if b.breakable ~= nil then -- 4595
						local gy = self:sy(b.y0, h) -- 4600
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4601
						local k = 0 -- 4602
						do -- 4602
							k = 0 -- 4603
							while k < 3 do -- 4603
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4604
								draw:drawSegment( -- 4605
									Vec2( -- 4605
										gx - self:px(4), -- 4605
										gy + self:px(k % 2) -- 4605
									), -- 4605
									Vec2( -- 4605
										gx + self:px(5), -- 4605
										gy + self:px(k % 2) -- 4605
									), -- 4605
									self:px(1), -- 4605
									rgb -- 4605
								) -- 4605
								k = k + 1 -- 4603
							end -- 4603
						end -- 4603
					end -- 4603
					goto __continue847 -- 4608
				end -- 4608
				local ____opt_67 = b.depth -- 4608
				local front = ____opt_67 and ____opt_67.min or 0 -- 4610
				local ____opt_69 = b.depth -- 4610
				local back = ____opt_69 and ____opt_69.max or 0 -- 4611
				local fill = SOLID_FILL -- 4612
				local line = SOLID_EDGE -- 4613
				if b.soft == true then -- 4613
					fill = SOFT -- 4615
					line = SOFT_LINE -- 4616
				elseif b.breakable ~= nil then -- 4616
					line = DANGER_LINE -- 4618
					fill = Color(0.3, 0.24, 0.16, 1) -- 4619
				elseif b.interact ~= nil then -- 4619
					line = PASS_LINE -- 4621
				end -- 4621
				self:drawBox( -- 4623
					draw, -- 4623
					w, -- 4623
					h, -- 4623
					b.x0, -- 4623
					b.x1, -- 4623
					b.y0 + front, -- 4623
					b.y1 + back, -- 4623
					fill -- 4623
				) -- 4623
				draw:drawSegment( -- 4624
					Vec2( -- 4624
						self:sx(b.x0, w), -- 4624
						self:sy(b.y1 + front, h) -- 4624
					), -- 4624
					Vec2( -- 4625
						self:sx(b.x1, w), -- 4625
						self:sy(b.y1 + front, h) -- 4625
					), -- 4625
					self:px(1), -- 4625
					line -- 4625
				) -- 4625
				if b.breakable ~= nil then -- 4625
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4628
					local cyp = self:sy(b.y1 + front, h) -- 4629
					draw:drawSegment( -- 4630
						Vec2( -- 4630
							cxp - self:px(4), -- 4630
							cyp + self:px(1) -- 4630
						), -- 4630
						Vec2( -- 4630
							cxp + self:px(3), -- 4630
							cyp + self:px(5) -- 4630
						), -- 4630
						self:px(1), -- 4630
						line -- 4630
					) -- 4630
				end -- 4630
			end -- 4630
			::__continue847:: -- 4630
			i = i + 1 -- 4592
		end -- 4592
	end -- 4592
end -- 4590
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4636
	local i = 0 -- 4637
	do -- 4637
		i = 0 -- 4638
		while i < #self.pickups do -- 4638
			do -- 4638
				local pk = self.pickups[i + 1] -- 4639
				if pk.id == "" then -- 4639
					goto __continue859 -- 4641
				end -- 4641
				local gy = pk.y + (pk.depth or 0) -- 4643
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4644
				draw:drawRect( -- 4645
					Rect( -- 4645
						self:sx(pk.x - 5, w), -- 4645
						self:sy(gy + 12 + bob, h), -- 4645
						self:px(10), -- 4645
						self:px(10) -- 4645
					), -- 4645
					Color(0.84, 0.7, 0.3, 1) -- 4646
				) -- 4646
				draw:drawSegment( -- 4647
					Vec2( -- 4647
						self:sx(pk.x - 5, w), -- 4647
						self:sy(gy + 12 + bob, h) -- 4647
					), -- 4647
					Vec2( -- 4648
						self:sx(pk.x + 5, w), -- 4648
						self:sy(gy + 12 + bob, h) -- 4648
					), -- 4648
					self:px(1), -- 4648
					Color(0.95, 0.86, 0.52, 1) -- 4648
				) -- 4648
			end -- 4648
			::__continue859:: -- 4648
			i = i + 1 -- 4638
		end -- 4638
	end -- 4638
	if self.bracedShield ~= nil then -- 4638
		local sh = self.bracedShield -- 4651
		draw:drawRect( -- 4652
			Rect( -- 4652
				self:sx(sh.x - sh.w / 2, w), -- 4652
				self:sy(sh.y, h), -- 4652
				self:px(sh.w), -- 4652
				self:px(sh.h) -- 4652
			), -- 4652
			Color(0.42, 0.4, 0.34, 1) -- 4653
		) -- 4653
		draw:drawSegment( -- 4654
			Vec2( -- 4654
				self:sx(sh.x - sh.w / 2, w), -- 4654
				self:sy(sh.y + sh.h, h) -- 4654
			), -- 4654
			Vec2( -- 4655
				self:sx(sh.x + sh.w / 2, w), -- 4655
				self:sy(sh.y + sh.h, h) -- 4655
			), -- 4655
			self:px(1), -- 4655
			Color(0.74, 0.72, 0.62, 1) -- 4655
		) -- 4655
	end -- 4655
end -- 4636
function Play.prototype.drawZones(self, draw, w, h) -- 4659
	local i = 0 -- 4660
	do -- 4660
		i = 0 -- 4661
		while i < #self.room.zones do -- 4661
			local z = self.room.zones[i + 1] -- 4662
			local fill = DANGER -- 4663
			local line = DANGER_LINE -- 4664
			if z.tint == 2 then -- 4664
				fill = SOFT -- 4666
				line = SOFT_LINE -- 4667
			elseif z.tint == 3 then -- 4667
				fill = BRICK -- 4669
				line = BRICK_LINE -- 4670
			elseif z.tint == 4 then -- 4670
				fill = PASS -- 4672
				line = PASS_LINE -- 4673
			end -- 4673
			self:drawBox( -- 4675
				draw, -- 4675
				w, -- 4675
				h, -- 4675
				z.x0, -- 4675
				z.x1, -- 4675
				z.y, -- 4675
				z.y + z.h, -- 4675
				fill -- 4675
			) -- 4675
			draw:drawSegment( -- 4676
				Vec2( -- 4676
					self:sx(z.x0, w), -- 4676
					self:sy(z.y, h) -- 4676
				), -- 4676
				Vec2( -- 4676
					self:sx(z.x0, w), -- 4676
					self:sy(z.y + z.h, h) -- 4676
				), -- 4676
				self:px(1), -- 4676
				line -- 4676
			) -- 4676
			draw:drawSegment( -- 4677
				Vec2( -- 4677
					self:sx(z.x1, w), -- 4677
					self:sy(z.y, h) -- 4677
				), -- 4677
				Vec2( -- 4677
					self:sx(z.x1, w), -- 4677
					self:sy(z.y + z.h, h) -- 4677
				), -- 4677
				self:px(1), -- 4677
				line -- 4677
			) -- 4677
			i = i + 1 -- 4661
		end -- 4661
	end -- 4661
end -- 4659
function Play.prototype.drawArch(self, draw, w, h) -- 4681
	local a = self.room.arch -- 4682
	if a.h <= 0 then -- 4682
		return -- 4684
	end -- 4684
	self:drawBox( -- 4686
		draw, -- 4686
		w, -- 4686
		h, -- 4686
		a.x0, -- 4686
		a.x1, -- 4686
		a.y, -- 4686
		a.y + a.h, -- 4686
		HOLE_FILL -- 4686
	) -- 4686
	draw:drawSegment( -- 4687
		Vec2( -- 4687
			self:sx(a.x0, w), -- 4687
			self:sy(a.y + a.h, h) -- 4687
		), -- 4687
		Vec2( -- 4687
			self:sx(a.x1, w), -- 4687
			self:sy(a.y + a.h, h) -- 4687
		), -- 4687
		self:px(1), -- 4687
		SOLID_EDGE -- 4687
	) -- 4687
	draw:drawSegment( -- 4688
		Vec2( -- 4688
			self:sx(a.x0, w), -- 4688
			self:sy(a.y, h) -- 4688
		), -- 4688
		Vec2( -- 4688
			self:sx(a.x0, w), -- 4688
			self:sy(a.y + a.h, h) -- 4688
		), -- 4688
		self:px(1), -- 4688
		SOLID_EDGE -- 4688
	) -- 4688
	draw:drawSegment( -- 4689
		Vec2( -- 4689
			self:sx(a.x1, w), -- 4689
			self:sy(a.y, h) -- 4689
		), -- 4689
		Vec2( -- 4689
			self:sx(a.x1, w), -- 4689
			self:sy(a.y + a.h, h) -- 4689
		), -- 4689
		self:px(1), -- 4689
		SOLID_EDGE -- 4689
	) -- 4689
end -- 4681
function Play.prototype.drawCart(self, draw, w, h) -- 4692
	local c = self.room.cart -- 4693
	if c.bodyW <= 0 then -- 4693
		return -- 4695
	end -- 4695
	drawCartShape( -- 4697
		draw, -- 4697
		self, -- 4697
		w, -- 4697
		h, -- 4697
		c, -- 4697
		self.cartAxle -- 4697
	) -- 4697
	draw:drawRect( -- 4698
		Rect( -- 4698
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4698
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4698
			self:px(2), -- 4698
			self:px(40) -- 4698
		), -- 4698
		STAND -- 4698
	) -- 4698
end -- 4692
function Play.prototype.drawActors(self, draw, w, h) -- 4701
	local p = self.player -- 4702
	local isChild = self.childMode -- 4703
	local footY = p.y + p.depth -- 4704
	if p.covered then -- 4704
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4707
		draw:drawSegment( -- 4708
			Vec2( -- 4708
				self:sx(edge, w), -- 4708
				self:sy(footY + 8, h) -- 4708
			), -- 4708
			Vec2( -- 4708
				self:sx(edge, w), -- 4708
				self:sy(footY + p.h * 0.62, h) -- 4708
			), -- 4708
			self:px(2), -- 4708
			STAND -- 4708
		) -- 4708
		draw:drawSegment( -- 4710
			Vec2( -- 4710
				self:sx(p.x - 8, w), -- 4710
				self:sy(footY + p.h + 3, h) -- 4710
			), -- 4710
			Vec2( -- 4710
				self:sx(p.x + 8, w), -- 4710
				self:sy(footY + p.h + 3, h) -- 4710
			), -- 4710
			self:px(2), -- 4710
			STAND -- 4710
		) -- 4710
	elseif self.coverNear and not isChild then -- 4710
		draw:drawRect( -- 4713
			Rect( -- 4713
				self:sx(p.x - 3, w), -- 4713
				self:sy(footY + 1, h), -- 4713
				self:px(3), -- 4713
				self:px(3) -- 4713
			), -- 4713
			STAND -- 4713
		) -- 4713
	end -- 4713
	drawFigure( -- 4715
		draw, -- 4715
		self, -- 4715
		w, -- 4715
		h, -- 4715
		p, -- 4715
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4715
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4715
	) -- 4715
	local q = self.partner -- 4716
	if q.alive then -- 4716
		local childPartner = q.w == CHILD_W -- 4718
		drawFigure( -- 4719
			draw, -- 4719
			self, -- 4719
			w, -- 4719
			h, -- 4719
			q, -- 4719
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4719
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4719
		) -- 4719
	end -- 4719
	local i = 0 -- 4721
	do -- 4721
		i = 0 -- 4722
		while i < #self.enemies do -- 4722
			local e = self.enemies[i + 1] -- 4723
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4724
			local enemyY = e.y + (e.depth or 0) -- 4725
			self:drawBox( -- 4726
				draw, -- 4726
				w, -- 4726
				h, -- 4726
				e.x - e.w / 2, -- 4726
				e.x + e.w / 2, -- 4726
				enemyY, -- 4726
				enemyY + e.h, -- 4726
				col -- 4726
			) -- 4726
			if e.alive then -- 4726
				local ef = p.x >= e.x and 1 or -1 -- 4728
				if e.kind == "shield" then -- 4728
					local sh = (e.shieldHp or 0) > 0 -- 4730
					draw:drawRect( -- 4731
						Rect( -- 4731
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4731
							self:sy(enemyY, h), -- 4731
							self:px(6), -- 4731
							self:px(64) -- 4731
						), -- 4731
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4732
					) -- 4732
				elseif e.kind == "breaker" then -- 4732
					draw:drawSegment( -- 4734
						Vec2( -- 4734
							self:sx(e.x + ef * 12, w), -- 4734
							self:sy(enemyY + 8, h) -- 4734
						), -- 4734
						Vec2( -- 4735
							self:sx(e.x + ef * 22, w), -- 4735
							self:sy(enemyY + 46, h) -- 4735
						), -- 4735
						self:px(3), -- 4735
						Color(0.5, 0.36, 0.22, 1) -- 4735
					) -- 4735
				end -- 4735
			end -- 4735
			if e.alive and e.warnT > 0 then -- 4735
				local gunX = self:sx(e.x, w) -- 4740
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4741
				local aimX = self:sx(p.x, w) -- 4742
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4743
				local seg = 8 -- 4744
				local s = 0 -- 4745
				do -- 4745
					s = 0 -- 4746
					while s < seg do -- 4746
						local t0 = s / seg -- 4747
						local t1 = (s + 1) / seg -- 4748
						draw:drawSegment( -- 4749
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4750
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4751
							self:px(1), -- 4752
							DANGER -- 4752
						) -- 4752
						s = s + 2 -- 4746
					end -- 4746
				end -- 4746
			end -- 4746
			i = i + 1 -- 4722
		end -- 4722
	end -- 4722
	local k = 0 -- 4757
	do -- 4757
		k = 0 -- 4758
		while k < #self.room.marks do -- 4758
			do -- 4758
				local m = self.room.marks[k + 1] -- 4759
				if m.kind ~= 0 then -- 4759
					goto __continue885 -- 4761
				end -- 4761
				local on = self.checkpoint == m.x -- 4763
				local x = self:sx(m.x, w) -- 4764
				local y = self:sy(m.y, h) -- 4765
				draw:drawSegment( -- 4766
					Vec2(x, y), -- 4766
					Vec2( -- 4766
						x, -- 4766
						y + self:px(35) -- 4766
					), -- 4766
					self:px(1), -- 4766
					on and CHECK or INK_DIM -- 4766
				) -- 4766
				draw:drawDot( -- 4767
					Vec2( -- 4767
						x, -- 4767
						y + self:px(35) -- 4767
					), -- 4767
					self:px(2), -- 4767
					on and CHECK or INK_DIM -- 4767
				) -- 4767
			end -- 4767
			::__continue885:: -- 4767
			k = k + 1 -- 4758
		end -- 4758
	end -- 4758
	local j = 0 -- 4771
	do -- 4771
		j = 0 -- 4772
		while j < #self.room.marks do -- 4772
			do -- 4772
				local m = self.room.marks[j + 1] -- 4773
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4773
					goto __continue888 -- 4775
				end -- 4775
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4775
					goto __continue888 -- 4779
				end -- 4779
				local col = STAND -- 4781
				if m.kind == 4 then -- 4781
					col = PASS_LINE -- 4783
				elseif m.kind == 5 then -- 4783
					col = BRICK_LINE -- 4785
				end -- 4785
				local mx = self:sx(m.x, w) -- 4787
				local my = self:sy(m.y, h) -- 4788
				draw:drawSegment( -- 4789
					Vec2(mx, my), -- 4789
					Vec2( -- 4789
						mx, -- 4789
						my + self:px(24) -- 4789
					), -- 4789
					self:px(1), -- 4789
					col -- 4789
				) -- 4789
			end -- 4789
			::__continue888:: -- 4789
			j = j + 1 -- 4772
		end -- 4772
	end -- 4772
	local t = 0 -- 4792
	do -- 4792
		t = 0 -- 4793
		while t < #self.room.marks do -- 4793
			do -- 4793
				local m = self.room.marks[t + 1] -- 4794
				if m.kind ~= 6 then -- 4794
					goto __continue894 -- 4796
				end -- 4796
				local mx = self:sx(m.x, w) -- 4798
				local my = self:sy(m.y, h) -- 4799
				draw:drawSegment( -- 4800
					Vec2(mx, my), -- 4800
					Vec2( -- 4800
						mx, -- 4800
						my + self:px(30) -- 4800
					), -- 4800
					self:px(1), -- 4800
					INK_DIM -- 4800
				) -- 4800
				self:drawBox( -- 4801
					draw, -- 4801
					w, -- 4801
					h, -- 4801
					m.x - 5, -- 4801
					m.x + 5, -- 4801
					m.y + 30, -- 4801
					m.y + 40, -- 4801
					CHECK -- 4801
				) -- 4801
			end -- 4801
			::__continue894:: -- 4801
			t = t + 1 -- 4793
		end -- 4793
	end -- 4793
	if self.room.key == "village" then -- 4793
		self:drawVillage(draw, w, h) -- 4804
	end -- 4804
	if self.room.key == "forest" then -- 4804
		self:drawDog(draw, w, h) -- 4807
	end -- 4807
end -- 4701
function Play.prototype.drawDog(self, draw, w, h) -- 4812
	local x = self.dogX -- 4813
	self:drawBox( -- 4814
		draw, -- 4814
		w, -- 4814
		h, -- 4814
		x - 14, -- 4814
		x + 14, -- 4814
		0, -- 4814
		20, -- 4814
		SCAV_BODY -- 4814
	) -- 4814
	self:drawBox( -- 4815
		draw, -- 4815
		w, -- 4815
		h, -- 4815
		x - 10, -- 4815
		x - 2, -- 4815
		20, -- 4815
		30, -- 4815
		SCAV_BODY -- 4815
	) -- 4815
	self:drawBox( -- 4816
		draw, -- 4816
		w, -- 4816
		h, -- 4816
		x + 2, -- 4816
		x + 10, -- 4816
		20, -- 4816
		30, -- 4816
		SCAV_HEAD -- 4816
	) -- 4816
	if self.dogState == "ear" or self.dogState == "chase" then -- 4816
		draw:drawSegment( -- 4818
			Vec2( -- 4818
				self:sx(x, w), -- 4818
				self:sy(30, h) -- 4818
			), -- 4818
			Vec2( -- 4819
				self:sx(x, w), -- 4819
				self:sy(40, h) -- 4819
			), -- 4819
			self:px(1), -- 4819
			DANGER -- 4819
		) -- 4819
	end -- 4819
end -- 4812
function Play.prototype.drawVillage(self, draw, w, h) -- 4824
	local bottle = self.room.bottle -- 4825
	if bottle ~= nil then -- 4825
		self:drawBox( -- 4827
			draw, -- 4827
			w, -- 4827
			h, -- 4827
			bottle.x - 14, -- 4827
			bottle.x + 14, -- 4827
			0, -- 4827
			64, -- 4827
			SOLID_FILL -- 4827
		) -- 4827
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4827
			self:drawBottle( -- 4829
				draw, -- 4829
				w, -- 4829
				h, -- 4829
				bottle.x, -- 4829
				64 -- 4829
			) -- 4829
		end -- 4829
	end -- 4829
	self:drawBox( -- 4833
		draw, -- 4833
		w, -- 4833
		h, -- 4833
		300, -- 4833
		420, -- 4833
		44, -- 4833
		50, -- 4833
		FLOOR_DECK -- 4833
	) -- 4833
	self:drawBox( -- 4834
		draw, -- 4834
		w, -- 4834
		h, -- 4834
		300, -- 4834
		306, -- 4834
		0, -- 4834
		44, -- 4834
		FLOOR_DECK -- 4834
	) -- 4834
	self:drawBox( -- 4835
		draw, -- 4835
		w, -- 4835
		h, -- 4835
		414, -- 4835
		420, -- 4835
		0, -- 4835
		44, -- 4835
		FLOOR_DECK -- 4835
	) -- 4835
	local s = self.room.scavenger -- 4837
	if s ~= nil then -- 4837
		local sx0 = self.scavX -- 4839
		self:drawBox( -- 4840
			draw, -- 4840
			w, -- 4840
			h, -- 4840
			sx0 - 12, -- 4840
			sx0 + 12, -- 4840
			0, -- 4840
			s.h - 14, -- 4840
			SCAV_BODY -- 4840
		) -- 4840
		self:drawBox( -- 4841
			draw, -- 4841
			w, -- 4841
			h, -- 4841
			sx0 - 7, -- 4841
			sx0 + 7, -- 4841
			s.h - 14, -- 4841
			s.h, -- 4841
			SCAV_HEAD -- 4841
		) -- 4841
		if self.scavState == "turn" then -- 4841
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4843
			draw:drawSegment( -- 4844
				Vec2( -- 4844
					self:sx(sx0, w), -- 4844
					self:sy(s.h - 6, h) -- 4844
				), -- 4844
				Vec2( -- 4844
					self:sx(fx, w), -- 4844
					self:sy(s.h - 6, h) -- 4844
				), -- 4844
				self:px(1), -- 4844
				INK -- 4844
			) -- 4844
		end -- 4844
	end -- 4844
	if self.hasBottle then -- 4844
		local p = self.player -- 4849
		self:drawBottle( -- 4850
			draw, -- 4850
			w, -- 4850
			h, -- 4850
			p.x + p.facing * 10, -- 4850
			p.y + p.h * 0.62 -- 4850
		) -- 4850
	end -- 4850
	if self.bottleFly ~= nil then -- 4850
		self:drawBottle( -- 4853
			draw, -- 4853
			w, -- 4853
			h, -- 4853
			self.bottleFly.x, -- 4853
			self.bottleFly.y -- 4853
		) -- 4853
	end -- 4853
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 4853
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 4856
		draw:drawCircle( -- 4857
			Vec2( -- 4857
				self:sx(self.bottleLandX, w), -- 4857
				self:sy(0, h) -- 4857
			), -- 4857
			self:px(r / ____exports.UNITS_PER_PX), -- 4857
			BRICK_LINE -- 4857
		) -- 4857
	end -- 4857
end -- 4824
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 4861
	self:drawBox( -- 4862
		draw, -- 4862
		w, -- 4862
		h, -- 4862
		x - 3, -- 4862
		x + 3, -- 4862
		y - 10, -- 4862
		y, -- 4862
		BOTTLE -- 4862
	) -- 4862
end -- 4861
function Play.prototype.drawTrace(self, draw, w, h) -- 4865
	local t = self.trace -- 4866
	if t == nil or self.traceT <= 0 then -- 4866
		return -- 4868
	end -- 4868
	draw:drawSegment( -- 4870
		Vec2( -- 4871
			self:sx(t.x0, w), -- 4871
			self:sy(t.y0, h) -- 4871
		), -- 4871
		Vec2( -- 4872
			self:sx(t.x1, w), -- 4872
			self:sy(t.y1, h) -- 4872
		), -- 4872
		self:px(1), -- 4873
		t.hit and AIM_HIT or INK_DIM -- 4873
	) -- 4873
end -- 4865
function Play.prototype.drawAim(self, draw, w, h) -- 4876
	local v = self.view -- 4878
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 4879
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 4880
	local dot = self:px(1) -- 4881
	local arm = self:px(3) -- 4882
	local gap = self:px(1) -- 4883
	draw:drawSegment( -- 4884
		Vec2(gx - arm - gap, gy), -- 4884
		Vec2(gx - gap, gy), -- 4884
		dot / 2, -- 4884
		AIM -- 4884
	) -- 4884
	draw:drawSegment( -- 4885
		Vec2(gx + gap, gy), -- 4885
		Vec2(gx + arm + gap, gy), -- 4885
		dot / 2, -- 4885
		AIM -- 4885
	) -- 4885
	draw:drawSegment( -- 4886
		Vec2(gx, gy - arm - gap), -- 4886
		Vec2(gx, gy - gap), -- 4886
		dot / 2, -- 4886
		AIM -- 4886
	) -- 4886
	draw:drawSegment( -- 4887
		Vec2(gx, gy + gap), -- 4887
		Vec2(gx, gy + arm + gap), -- 4887
		dot / 2, -- 4887
		AIM -- 4887
	) -- 4887
	if self.room.key == "village" and self.hasBottle then -- 4887
		local p = self.player -- 4891
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4893
		local dir = ____end.x >= p.x and 1 or -1 -- 4894
		local x0 = p.x + dir * 10 -- 4895
		local y0 = p.y + p.h * 0.7 -- 4896
		local T = BOTTLE_FLY_TIME -- 4897
		local vx = (____end.x - x0) / T -- 4898
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 4899
		local pxr = x0 -- 4900
		local pyr = y0 -- 4901
		local t = 1 -- 4902
		do -- 4902
			t = 1 -- 4903
			while t <= 12 do -- 4903
				local tt = t / 12 * T -- 4904
				local nx = x0 + vx * tt -- 4905
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 4906
				draw:drawSegment( -- 4907
					Vec2( -- 4907
						self:sx(pxr, w), -- 4907
						self:sy(pyr, h) -- 4907
					), -- 4907
					Vec2( -- 4907
						self:sx(nx, w), -- 4907
						self:sy(ny, h) -- 4907
					), -- 4907
					self:px(1) / 2, -- 4907
					BOTTLE -- 4907
				) -- 4907
				pxr = nx -- 4908
				pyr = ny -- 4909
				t = t + 1 -- 4903
			end -- 4903
		end -- 4903
		draw:drawCircle( -- 4911
			Vec2( -- 4911
				self:sx(____end.x, w), -- 4911
				self:sy(____end.y + 2, h) -- 4911
			), -- 4911
			self:px(2), -- 4911
			BOTTLE -- 4911
		) -- 4911
	end -- 4911
end -- 4876
return ____exports -- 4876