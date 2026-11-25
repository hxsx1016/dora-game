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
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
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
function makeActor(room, index) -- 4992
	local sp = room.spawns -- 4993
	if index < 0 or index >= #sp then -- 4993
		return { -- 4995
			x = 0, -- 4995
			y = 0, -- 4995
			depth = 0, -- 4995
			depthSpeed = 0, -- 4995
			vx = 0, -- 4995
			vy = 0, -- 4995
			w = CHILD_W, -- 4995
			h = CHILD_H, -- 4995
			onGround = true, -- 4995
			facing = 1, -- 4995
			crouch = false, -- 4995
			rollT = 0, -- 4995
			covered = false, -- 4995
			alive = false -- 4995
		} -- 4995
	end -- 4995
	local s = sp[index + 1] -- 4997
	local child = s.h <= CHILD_H -- 4998
	local ground = room.depth -- 4999
	local depth = ground == nil and 0 or math.max( -- 5000
		ground.min, -- 5000
		math.min(ground.max, s.depth or 0) -- 5000
	) -- 5000
	return { -- 5001
		x = s.x, -- 5002
		y = s.y, -- 5002
		depth = depth, -- 5002
		depthSpeed = 0, -- 5002
		vx = 0, -- 5002
		vy = 0, -- 5002
		w = child and CHILD_W or SOLDIER_W, -- 5003
		h = child and CHILD_H or SOLDIER_H, -- 5004
		onGround = true, -- 5005
		facing = 1, -- 5005
		crouch = false, -- 5005
		rollT = 0, -- 5005
		covered = false, -- 5005
		alive = true -- 5005
	} -- 5005
end -- 5005
function drawFigure(draw, play, w, h, a, body, head) -- 5009
	if not a.alive then -- 5009
		return -- 5011
	end -- 5011
	local x0 = a.x - a.w / 2 -- 5013
	local x1 = a.x + a.w / 2 -- 5014
	local y0 = a.y + a.depth -- 5015
	local y1 = y0 + a.h -- 5016
	play:drawBox( -- 5017
		draw, -- 5017
		w, -- 5017
		h, -- 5017
		x0, -- 5017
		x1, -- 5017
		y0, -- 5017
		y1 - a.h * 0.26, -- 5017
		body -- 5017
	) -- 5017
	play:drawBox( -- 5018
		draw, -- 5018
		w, -- 5018
		h, -- 5018
		x0 + 2, -- 5018
		x1 - 2, -- 5018
		y1 - a.h * 0.26, -- 5018
		y1, -- 5018
		head -- 5018
	) -- 5018
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5020
	play:drawBox( -- 5021
		draw, -- 5021
		w, -- 5021
		h, -- 5021
		eyeX, -- 5021
		eyeX + 4, -- 5021
		y1 - a.h * 0.14, -- 5021
		y1 - a.h * 0.08, -- 5021
		INK -- 5021
	) -- 5021
end -- 5021
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5025
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5026
end -- 5025
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5033
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5034
end -- 5033
function rayInterval(origin, direction, min, max) -- 5041
	if direction == 0 then -- 5041
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5043
	end -- 5043
	local a = (min - origin) / direction -- 5045
	local b = (max - origin) / direction -- 5046
	return { -- 5047
		min = math.min(a, b), -- 5047
		max = math.max(a, b) -- 5047
	} -- 5047
end -- 5047
function hitBox(ray, box) -- 5051
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5052
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5053
	local enter = math.max(0, x.min, y.min) -- 5054
	local leave = math.min(99999, x.max, y.max) -- 5055
	if box.depth ~= nil then -- 5055
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5057
		enter = math.max(enter, depth.min) -- 5058
		leave = math.min(leave, depth.max) -- 5059
	end -- 5059
	return leave >= enter and enter or -1 -- 5061
end -- 5061
function drawCartShape(draw, play, w, h, c, axleX) -- 5064
	local half = c.bodyW / 2 -- 5065
	local x0 = axleX - half -- 5066
	local x1 = axleX + half -- 5067
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5068
	play:drawBox( -- 5069
		draw, -- 5069
		w, -- 5069
		h, -- 5069
		x0, -- 5069
		x1, -- 5069
		axleY, -- 5069
		axleY + c.bodyH, -- 5069
		CART_FILL -- 5069
	) -- 5069
	draw:drawCircle( -- 5070
		Vec2( -- 5070
			play:sx(x0 + c.bodyW * 0.28, w), -- 5070
			play:sy(axleY, h) -- 5070
		), -- 5070
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5070
		Color(52, 50, 48, 255) -- 5070
	) -- 5070
	draw:drawCircle( -- 5071
		Vec2( -- 5071
			play:sx(x1 - c.bodyW * 0.28, w), -- 5071
			play:sy(axleY, h) -- 5071
		), -- 5071
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5071
		Color(52, 50, 48, 255) -- 5071
	) -- 5071
	local cx = c.clothSide < 0 and x0 or x1 -- 5072
	play:drawBox( -- 5073
		draw, -- 5073
		w, -- 5073
		h, -- 5073
		cx - 10, -- 5073
		cx + 10, -- 5073
		axleY + c.bodyH, -- 5073
		axleY + c.bodyH + 18, -- 5073
		CLOTH -- 5073
	) -- 5073
end -- 5073
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
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3195
		self:restartEscortFromDeath() -- 3200
		return -- 3201
	end -- 3201
	local p = self.player -- 3203
	self.hp = self.maxHp -- 3204
	self.invulnT = INVULN_RESPAWN_TICKS -- 3205
	self.reloadT = 0 -- 3206
	self:closeReloadPuzzle() -- 3207
	self.gripping = false -- 3208
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3209
	self:log("被击倒") -- 3210
	p.x = self.room.minX + 90 -- 3211
	p.y = 0 -- 3212
	p.depth = 0 -- 3213
	p.vx = 0 -- 3214
	p.vy = 0 -- 3215
	p.onGround = true -- 3216
	p.rollT = 0 -- 3217
	self.partner.x = p.x - 50 -- 3218
	self.partner.y = 0 -- 3219
	self.partner.depth = 0 -- 3220
	self.cam.x = p.x -- 3221
	local i = 0 -- 3222
	do -- 3222
		i = 0 -- 3223
		while i < #self.enemies do -- 3223
			do -- 3223
				local e = self.enemies[i + 1] -- 3224
				if not e.alive then -- 3224
					goto __continue529 -- 3226
				end -- 3226
				e.x = e.homeX == nil and e.x or e.homeX -- 3228
				e.warnT = 0 -- 3229
				e.fireCd = 40 -- 3230
				e.swingT = 0 -- 3231
				e.awake = false -- 3232
			end -- 3232
			::__continue529:: -- 3232
			i = i + 1 -- 3223
		end -- 3223
	end -- 3223
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3234
end -- 3190
function Play.prototype.isEscortRoom(self) -- 3238
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3239
end -- 3238
function Play.prototype.restartEscortFromDeath(self) -- 3247
	local story = self.run.story -- 3248
	local inv = self.run.inventory -- 3249
	self.hp = self.maxHp -- 3250
	story.hp = self.maxHp -- 3251
	story.cp = nil -- 3252
	self.checkpointSnap = nil -- 3253
	story.carry = false -- 3254
	self.carryOn = false -- 3255
	story.craftedWeapon = "" -- 3256
	self.equippedWeapon = "standard_gun" -- 3257
	story.escortDone = false -- 3258
	self.escortDone = false -- 3259
	story.segments = {} -- 3260
	inv.wood = 0 -- 3261
	inv.bell = 0 -- 3262
	inv.scrap = 0 -- 3263
	inv.wedge = 0 -- 3264
	inv.ammo = 0 -- 3265
	inv.quickbelt = 0 -- 3266
	inv.shield = 0 -- 3267
	inv.pass = 0 -- 3268
	local taken = self.run.taken -- 3269
	local keys = __TS__ObjectKeys(taken) -- 3270
	local i = 0 -- 3271
	do -- 3271
		i = 0 -- 3272
		while i < #keys do -- 3272
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3272
				__TS__Delete(taken, keys[i + 1]) -- 3274
			end -- 3274
			i = i + 1 -- 3272
		end -- 3272
	end -- 3272
	self.run.joined = true -- 3277
	self.reloadT = 0 -- 3278
	self:closeReloadPuzzle() -- 3279
	self.gripping = false -- 3280
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3281
	self:log("男主线失败 · 回 escort1") -- 3282
	self:emit("campaignFailed", { -- 3283
		room = self.room.key, -- 3284
		hp = 0, -- 3284
		maxHp = self.maxHp, -- 3284
		reset = true, -- 3285
		to = "escort1", -- 3285
		route = self.storyRoute -- 3285
	}) -- 3285
	self:requestRoom("escort1", "男主线失败重开") -- 3287
end -- 3247
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3291
	local i = 0 -- 3292
	do -- 3292
		i = 0 -- 3293
		while i < #self.enemies do -- 3293
			do -- 3293
				if i == skipIndex then -- 3293
					goto __continue538 -- 3295
				end -- 3295
				local e = self.enemies[i + 1] -- 3297
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3297
					goto __continue538 -- 3299
				end -- 3299
				e.fireCd = 150 -- 3301
				e.warnT = 0 -- 3302
			end -- 3302
			::__continue538:: -- 3302
			i = i + 1 -- 3293
		end -- 3293
	end -- 3293
end -- 3291
function Play.prototype.stepEnemies(self, dt, input) -- 3306
	local i = 0 -- 3307
	do -- 3307
		i = 0 -- 3308
		while i < #self.enemies do -- 3308
			local e = self.enemies[i + 1] -- 3309
			if e.hitT > 0 then -- 3309
				e.hitT = e.hitT - dt -- 3311
			end -- 3311
			i = i + 1 -- 3308
		end -- 3308
	end -- 3308
	if self.coveredFlash > 0 then -- 3308
		self.coveredFlash = self.coveredFlash - dt -- 3315
	end -- 3315
	if self.isCampaign then -- 3315
		self:stepCampaignEnemies(dt, input) -- 3318
		return -- 3319
	end -- 3319
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3319
		return -- 3323
	end -- 3323
	do -- 3323
		i = 0 -- 3325
		while i < #self.enemies do -- 3325
			do -- 3325
				local e = self.enemies[i + 1] -- 3326
				if not e.alive then -- 3326
					goto __continue549 -- 3328
				end -- 3328
				if e.warnT > 0 then -- 3328
					e.warnT = e.warnT - 1 -- 3331
					if e.warnT <= 0 then -- 3331
						self:enemyFire(e, input) -- 3333
					end -- 3333
					goto __continue549 -- 3335
				end -- 3335
				if e.fireCd > 0 then -- 3335
					e.fireCd = e.fireCd - 1 -- 3338
					if e.fireCd <= 0 then -- 3338
						e.warnT = WARN_TICKS -- 3340
					end -- 3340
				else -- 3340
					e.warnT = WARN_TICKS -- 3344
				end -- 3344
			end -- 3344
			::__continue549:: -- 3344
			i = i + 1 -- 3325
		end -- 3325
	end -- 3325
end -- 3306
function Play.prototype.enemyFire(self, e, input) -- 3350
	local p = self.player -- 3351
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3351
		self:flashSet("枪声响在远处", 0.4) -- 3353
		e.fireCd = FIRE_COOLDOWN -- 3354
		return -- 3355
	end -- 3355
	local cover = self:blockedByCover(e, p) -- 3358
	local hugging = cover ~= nil -- 3359
	self.coverBlocking = hugging -- 3360
	local covered = hugging and input.cover.held -- 3361
	if covered then -- 3361
		self.coveredFlash = 0.5 -- 3363
		self:flashSet("掩体挡下", 0.5) -- 3364
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3365
		e.fireCd = FIRE_COOLDOWN -- 3370
		return -- 3371
	end -- 3371
	self.hp = self.hp - 1 -- 3373
	self:emit("actorHit", { -- 3374
		target = "player", -- 3374
		amount = 1, -- 3374
		hp = self.hp, -- 3374
		maxHp = self.maxHp, -- 3374
		enemyX = e.x -- 3374
	}) -- 3374
	self:flashSet( -- 3375
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3375
		0.7 -- 3375
	) -- 3375
	e.fireCd = FIRE_COOLDOWN -- 3376
	if self.hp <= 0 then -- 3376
		self:gateFailed() -- 3378
	end -- 3378
end -- 3350
function Play.prototype.blockedByCover(self, enemy, p) -- 3383
	local b = self:coverAt(p) -- 3384
	if b == nil then -- 3384
		return nil -- 3386
	end -- 3386
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3388
end -- 3383
function Play.prototype.gateFailed(self) -- 3392
	local ____temp_56 -- 3393
	if self.room.story == nil then -- 3393
		____temp_56 = nil -- 3393
	else -- 3393
		____temp_56 = self.room.story.gate -- 3393
	end -- 3393
	local g = ____temp_56 -- 3393
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3394
	self.hp = self.maxHp -- 3395
	self.gateTick = 0 -- 3396
	self.gateSpawned = 0 -- 3397
	self.enemies = {} -- 3398
	self.gateFailCount = self.gateFailCount + 1 -- 3399
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3401
	self.player.y = 0 -- 3402
	self.player.vy = 0 -- 3403
	self.player.depth = 0 -- 3404
	self.player.depthSpeed = 0 -- 3405
	self.player.onGround = true -- 3406
	self.player.crouch = false -- 3407
	self.player.h = SOLDIER_H -- 3408
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3409
	self.partner.y = 0 -- 3410
	self.partner.vy = 0 -- 3411
	self.partner.depth = 0 -- 3412
	self.partner.depthSpeed = 0 -- 3413
	self.partner.onGround = true -- 3414
	self.cam.x = self.player.x -- 3415
	self.phase = "gate-idle" -- 3416
	self.phaseTick = 0 -- 3417
	self.coverHug = false -- 3418
	self.coverBlocking = false -- 3419
	self.coverEntity = "" -- 3420
	self.gateNeedConfirm = true -- 3421
	self.gateRestartArmed = false -- 3422
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3423
end -- 3392
function Play.prototype.stepInteract(self, dt, input) -- 3426
	local p = self.player -- 3427
	local calmUsed = self.calmConsumed -- 3428
	self.calmConsumed = false -- 3429
	local calming = self.escort.state == "calming" -- 3431
	self.focusCart = false -- 3432
	if self.room.key == "outside" then -- 3432
		local c = self.room.cart -- 3434
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3435
		local dy = p.y - c.baseY -- 3436
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3437
	end -- 3437
	if not calmUsed and not calming then -- 3437
		self:stepCart(dt, input) -- 3441
	end -- 3441
	if calmUsed then -- 3441
		self:flashSet("安抚 · 敲两下", 0.8) -- 3446
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 3446
		if self.knockT > 0 then -- 3446
			self.knocks = self.knocks + 1 -- 3450
		else -- 3450
			self.knocks = 1 -- 3452
		end -- 3452
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3454
		self.knockT = 1.2 -- 3455
		if self.knocks >= 2 then -- 3455
			self:flashSet("敲两下", 0.8) -- 3457
			self.knocks = 0 -- 3458
		else -- 3458
			self:flashSet("敲一下", 0.5) -- 3460
		end -- 3460
	elseif self.knockT > 0 then -- 3460
		self.knockT = self.knockT - dt -- 3463
		if self.knockT <= 0 then -- 3463
			self.knocks = 0 -- 3465
		end -- 3465
	end -- 3465
	local i = 0 -- 3470
	do -- 3470
		i = 0 -- 3471
		while i < #self.room.marks do -- 3471
			do -- 3471
				local m = self.room.marks[i + 1] -- 3472
				if m.kind ~= 0 then -- 3472
					goto __continue575 -- 3474
				end -- 3474
				local subjects = {self.partner, self.player} -- 3476
				local k = 0 -- 3477
				do -- 3477
					k = 0 -- 3478
					while k < #subjects do -- 3478
						do -- 3478
							local s = subjects[k + 1] -- 3479
							if not s.alive then -- 3479
								goto __continue578 -- 3481
							end -- 3481
							local dx = s.x - m.x -- 3483
							local dy = s.y - m.y -- 3484
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3484
								self.checkpoint = m.x -- 3486
								self.checkpointCartAxle = self.cartAxle -- 3487
								if self.isCampaign then -- 3487
									self:captureCheckpoint(m.x) -- 3490
								end -- 3490
								if self.cartDocked then -- 3490
									self:flashSet("检查点 · 车已落窝", 1) -- 3493
								else -- 3493
									self:flashSet("检查点 · 车还没到位", 1) -- 3495
								end -- 3495
							end -- 3495
						end -- 3495
						::__continue578:: -- 3495
						k = k + 1 -- 3478
					end -- 3478
				end -- 3478
			end -- 3478
			::__continue575:: -- 3478
			i = i + 1 -- 3471
		end -- 3471
	end -- 3471
	self:checkCarryGate() -- 3501
end -- 3426
function Play.prototype.stepVillage(self, dt, input) -- 3505
	if self.room.key ~= "village" then -- 3505
		return -- 3507
	end -- 3507
	local p = self.player -- 3509
	local bottle = self.room.bottle -- 3510
	local scav = self.room.scavenger -- 3511
	if not self.hasBottle and bottle ~= nil then -- 3511
		local dx = p.x - bottle.x -- 3515
		local dy = p.y + p.h * 0.5 - bottle.y -- 3516
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3516
			self.hasBottle = true -- 3518
			self:flashSet("拾起瓶子", 0.8) -- 3519
		end -- 3519
	end -- 3519
	if self.hasBottle then -- 3519
		if input.aim.held then -- 3519
			self.aimHold = self.aimHold + dt -- 3526
			if self.aimHold > 1.2 then -- 3526
				self.aimHold = 1.2 -- 3528
			end -- 3528
			local cached = self:bottleEnd() -- 3531
			self.bottleAimX = cached.x -- 3532
			self.bottleAimY = cached.y -- 3533
		elseif input.aim.released then -- 3533
			if self.aimHold < 0.12 then -- 3533
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3537
				self.aimHold = 0 -- 3538
			else -- 3538
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3540
				self:throwBottle(____end.x, ____end.y) -- 3541
				self.aimHold = 0 -- 3542
			end -- 3542
		end -- 3542
	else -- 3542
		self.aimHold = 0 -- 3546
		self.bottleAimX = -1 -- 3547
	end -- 3547
	local fly = self.bottleFly -- 3552
	if fly ~= nil then -- 3552
		fly.t = fly.t + dt -- 3554
		fly.x = fly.x0 + fly.vx * fly.t -- 3555
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3556
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3557
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3557
			self:landBottle(fly) -- 3559
		end -- 3559
	end -- 3559
	if self.bottleLandT > 0 then -- 3559
		self.bottleLandT = self.bottleLandT - dt -- 3563
	end -- 3563
	if scav ~= nil then -- 3563
		self:stepScav(dt, scav) -- 3567
	end -- 3567
	local line = self.room.passLine -- 3570
	if line ~= nil and not self.passed and p.x >= line then -- 3570
		self.passed = true -- 3572
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3573
	end -- 3573
	if self.passed and p.x >= self.ox + 640 then -- 3573
		self:requestRoom("forest", "过第一院出院") -- 3577
		self:flashSet("出院 · 北塔森林", 1.4) -- 3578
	end -- 3578
end -- 3505
function Play.prototype.bottleEnd(self) -- 3583
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3584
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3587
	return {x = aim.x, y = g} -- 3588
end -- 3583
function Play.prototype.throwBottle(self, tx, ty) -- 3592
	local p = self.player -- 3593
	local dir = tx >= p.x and 1 or -1 -- 3595
	p.facing = dir -- 3596
	local x0 = p.x + dir * 10 -- 3597
	local y0 = p.y + p.h * 0.7 -- 3598
	self.bottleTargetX = tx -- 3599
	self.bottleTargetY = ty -- 3600
	self.bottleSurfaceY = ty -- 3601
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3602
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3603
	self.bottleFly = { -- 3604
		x = x0, -- 3604
		y = y0, -- 3604
		x0 = x0, -- 3604
		y0 = y0, -- 3604
		vx = vx, -- 3604
		vy = vy, -- 3604
		t = 0 -- 3604
	} -- 3604
	self.hasBottle = false -- 3605
	self:flashSet("投出", 0.4) -- 3606
	self:emit( -- 3607
		"bottleThrown", -- 3607
		{ -- 3607
			fromX = x0, -- 3608
			fromY = y0, -- 3609
			targetX = tx, -- 3610
			targetY = ty, -- 3611
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3612
		} -- 3612
	) -- 3612
end -- 3592
function Play.prototype.landBottle(self, fly) -- 3617
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3618
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3619
	local s = self.room.scavenger -- 3620
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3621
	self.bottleFly = nil -- 3622
	self.bottleTargetX = -1 -- 3623
	self.bottleTargetY = 0 -- 3624
	self.bottleSurfaceY = -1 -- 3625
	self.bottleLandX = x -- 3626
	self.bottleLandY = y -- 3627
	self.bottleLandT = 0.9 -- 3628
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3629
	self:hearBottle(x) -- 3630
end -- 3617
function Play.prototype.hearBottle(self, x) -- 3634
	local s = self.room.scavenger -- 3635
	if s == nil then -- 3635
		return -- 3637
	end -- 3637
	if math.abs(x - self.scavX) > s.range then -- 3637
		self:flashSet("落地 · 他没听见", 0.6) -- 3640
		return -- 3641
	end -- 3641
	self.scavState = "turn" -- 3643
	self.scavT = s.hearTicks -- 3644
	self.scavTargetX = x -- 3645
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3646
end -- 3634
function Play.prototype.stepScav(self, dt, s) -- 3650
	if self.scavState == "chase" then -- 3650
		return -- 3653
	end -- 3653
	if self.scavState == "turn" then -- 3653
		self.scavT = self.scavT - 1 -- 3656
		if self.scavT <= 0 then -- 3656
			self.scavState = "walk" -- 3658
		end -- 3658
		return -- 3660
	end -- 3660
	if self.scavState == "walk" then -- 3660
		local d = self.scavTargetX - self.scavX -- 3663
		if math.abs(d) < 4 then -- 3663
			self.scavState = "stall" -- 3665
			self.scavT = s.stallTicks -- 3666
			return -- 3667
		end -- 3667
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3669
		return -- 3670
	end -- 3670
	if self.scavState == "stall" then -- 3670
		self.scavT = self.scavT - 1 -- 3673
		if self.scavT <= 0 then -- 3673
			self.scavState = "back" -- 3675
		end -- 3675
		return -- 3677
	end -- 3677
	if self.scavState == "back" then -- 3677
		local home = math.max( -- 3680
			s.x0, -- 3680
			math.min(s.x1, self.scavX) -- 3680
		) -- 3680
		if math.abs(home - self.scavX) < 2 then -- 3680
			self.scavState = "patrol" -- 3682
			return -- 3683
		end -- 3683
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3685
		return -- 3686
	end -- 3686
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3688
	if self.scavX >= s.x1 then -- 3688
		self.scavX = s.x1 -- 3690
		self.scavDir = -1 -- 3691
	elseif self.scavX <= s.x0 then -- 3691
		self.scavX = s.x0 -- 3693
		self.scavDir = 1 -- 3694
	end -- 3694
end -- 3650
function Play.prototype.stepCart(self, dt, input) -- 3702
	local p = self.player -- 3703
	local c = self.room.cart -- 3704
	if self.gripping then -- 3704
		if not input.interact.held then -- 3704
			self.gripping = false -- 3708
			self:flashSet("松开车把", 0.4) -- 3709
			return -- 3710
		end -- 3710
	else -- 3710
		if not input.interact.pressed then -- 3710
			return -- 3714
		end -- 3714
		if not self:cartHandleInReach(p) then -- 3714
			return -- 3717
		end -- 3717
		local track = c.depth or 0 -- 3719
		if self:limitDepth(p, track) ~= track then -- 3719
			return -- 3721
		end -- 3721
		p.depth = track -- 3723
		p.depthSpeed = 0 -- 3724
		self.gripping = true -- 3725
		self:flashSet("握住车把", 0.4) -- 3726
		return -- 3727
	end -- 3727
	if self.cartDocked then -- 3727
		return -- 3731
	end -- 3731
	local dir = input.moveX -- 3733
	if dir == 0 then -- 3733
		return -- 3735
	end -- 3735
	local lo = math.min(c.startX, c.endX) -- 3737
	local hi = math.max(c.startX, c.endX) -- 3738
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3739
	if next < lo then -- 3739
		next = lo -- 3741
	end -- 3741
	if next > hi then -- 3741
		next = hi -- 3744
	end -- 3744
	local delta = next - self.cartAxle -- 3746
	if delta == 0 then -- 3746
		return -- 3748
	end -- 3748
	self.cartAxle = next -- 3750
	p.x = p.x + delta -- 3751
	p.facing = dir > 0 and 1 or -1 -- 3752
	self:slideX(p, 0) -- 3753
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3753
		self.gripping = false -- 3755
		self:flashSet("跟不上了，脱手", 0.6) -- 3756
		return -- 3757
	end -- 3757
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3757
		self.cartDocked = true -- 3760
		self.gripping = false -- 3761
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3762
		self:flashSet("车轮落窝", 1.2) -- 3763
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3763
		self:flashSet("车轮回到起点", 0.5) -- 3765
	end -- 3765
end -- 3702
function Play.prototype.requestRoom(self, key, reason) -- 3773
	if self.wantRoom ~= "" then -- 3773
		return -- 3777
	end -- 3777
	self.wantRoom = key -- 3779
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3780
end -- 3773
function Play.prototype.checkCarryGate(self) -- 3787
	if self.room.key == "checkpoint" then -- 3787
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3787
			self.carryCartAxle = self.cartAxle -- 3790
			self.carryCartDocked = self.cartDocked -- 3791
			self:requestRoom("gate", "检查站出口") -- 3792
			self:flashSet("出检查站 · 城门", 1.2) -- 3793
		end -- 3793
		return -- 3795
	end -- 3795
	if self.room.key == "outside" then -- 3795
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3795
			self.carryCartAxle = self.cartAxle -- 3801
			self.carryCartDocked = self.cartDocked -- 3802
			self:requestRoom("village", "墙根走完") -- 3803
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3804
		end -- 3804
	end -- 3804
end -- 3787
function Play.prototype.aimAt(self, wx, wy) -- 3811
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3812
	self.aimX = s.x -- 3813
	self.aimY = s.y -- 3814
end -- 3811
function Play.prototype.shoot(self, a) -- 3817
	if self.isCampaign and self.reloadT > 0 then -- 3817
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3819
		return -- 3820
	end -- 3820
	local ox = a.x + a.facing * 8 -- 3822
	local muzzleY = a.y + a.h * 0.72 -- 3823
	local oy = muzzleY + a.depth -- 3824
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3826
	local dx = aim.x - ox -- 3829
	local dy = aim.y - oy -- 3830
	local len = math.sqrt(dx * dx + dy * dy) -- 3831
	if len < 0.001 then -- 3831
		dx = a.facing -- 3833
		dy = 0 -- 3834
	else -- 3834
		dx = dx / len -- 3836
		dy = dy / len -- 3837
	end -- 3837
	if dx ~= 0 then -- 3837
		a.facing = dx > 0 and 1 or -1 -- 3840
	end -- 3840
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3843
	local hitEnemy = self:raycastEnemies(ray) -- 3844
	local tEnemy = hitEnemy.t -- 3845
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3846
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3847
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3848
	local tWall = solid.t -- 3849
	local rawEffect = self:consumeReloadEffect() -- 3851
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 3852
	local reloadEffect = rawEffect -- 3853
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 3855
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3856
	self.trace = { -- 3858
		x0 = ox, -- 3858
		y0 = oy, -- 3858
		x1 = ox + dx * t, -- 3858
		y1 = oy + dy * t, -- 3858
		hit = hit -- 3858
	} -- 3858
	self.traceT = 0.12 -- 3859
	self:applyFireDanger(ox) -- 3860
	local killed = false -- 3861
	if hit then -- 3861
		local i = hitEnemy.index -- 3863
		local e = self.enemies[i + 1] -- 3864
		local impactY = oy + dy * tEnemy -- 3865
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3866
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3867
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3867
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3869
			e.hitT = 0.3 -- 3870
			self:flashSet( -- 3871
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3871
				0.8 -- 3871
			) -- 3871
			self:emit("shotResolved", { -- 3872
				hit = true, -- 3873
				enemyIndex = i, -- 3873
				enemyX = e.x, -- 3873
				aimX = aim.x, -- 3873
				aimY = aim.y, -- 3873
				impactX = ox + dx * t, -- 3874
				impactY = oy + dy * t, -- 3874
				shield = true -- 3874
			}) -- 3874
			self:beginReload() -- 3876
			return -- 3877
		end -- 3877
		e.alive = false -- 3879
		e.hitT = 0.4 -- 3880
		killed = true -- 3881
		self:flashSet("命中", 0.6) -- 3882
		self:dropFor(e) -- 3883
		if reloadEffect == "light" and weaponFx == "light" then -- 3883
			self:blindNearby(e, 160, i) -- 3885
		end -- 3885
		if reloadEffect == "push" then -- 3885
			e.x = e.x + a.facing * 46 -- 3888
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 3889
		elseif reloadEffect == "echo" then -- 3889
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 3891
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 3892
		elseif reloadEffect == "light" then -- 3892
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 3894
		end -- 3894
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3894
		self:damageProp(solid.box, 1) -- 3897
	else -- 3897
		self:flashSet("打空", 0.35) -- 3899
	end -- 3899
	if self.isCampaign then -- 3899
		self:beginReload() -- 3902
	end -- 3902
	self:emit("shotResolved", { -- 3904
		hit = hit, -- 3905
		enemyIndex = hit and hitEnemy.index or -1, -- 3906
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3907
		aimX = aim.x, -- 3908
		aimY = aim.y, -- 3909
		impactX = ox + dx * t, -- 3910
		impactY = oy + dy * t -- 3911
	}) -- 3911
end -- 3817
function Play.prototype.applyFireDanger(self, shotX) -- 3916
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3916
		return -- 3918
	end -- 3918
	local dangerX = shotX -- 3920
	local best = -1 -- 3921
	local bestD = 1000000000 -- 3922
	local i = 0 -- 3923
	do -- 3923
		i = 0 -- 3924
		while i < #self.enemies do -- 3924
			do -- 3924
				local e = self.enemies[i + 1] -- 3925
				if not e.alive then -- 3925
					goto __continue659 -- 3927
				end -- 3927
				local d = math.abs(e.x - self.partner.x) -- 3929
				if d < bestD then -- 3929
					bestD = d -- 3931
					best = i -- 3932
				end -- 3932
			end -- 3932
			::__continue659:: -- 3932
			i = i + 1 -- 3924
		end -- 3924
	end -- 3924
	if best >= 0 then -- 3924
		dangerX = self.enemies[best + 1].x -- 3936
	end -- 3936
	local exposed = self:childExposed(dangerX) -- 3938
	local before = self.escort.fear -- 3939
	local dangerId = self.nextDangerId -- 3940
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 3941
	self.nextDangerId = self.nextDangerId + 1 -- 3942
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 3943
	if after > before then -- 3943
		self:flashSet( -- 3945
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 3945
			1 -- 3945
		) -- 3945
	elseif not exposed then -- 3945
		self:flashSet("枪声没够到她", 0.5) -- 3947
	end -- 3947
end -- 3916
function Play.prototype.childExposed(self, dangerX) -- 3952
	local c = self.partner -- 3953
	if not c.alive then -- 3953
		return false -- 3955
	end -- 3955
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 3955
		self.boxes, -- 3958
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 3958
	) then -- 3958
		return false -- 3959
	end -- 3959
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 3959
		return false -- 3962
	end -- 3962
	local toDanger = dangerX - c.x -- 3964
	local toPlayer = self.player.x - c.x -- 3965
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 3965
		return false -- 3968
	end -- 3968
	return true -- 3970
end -- 3952
function Play.prototype.raycastEnemies(self, ray) -- 3974
	local best = -1 -- 3975
	local bestI = -1 -- 3976
	do -- 3976
		local i = 0 -- 3977
		while i < #self.enemies do -- 3977
			do -- 3977
				local e = self.enemies[i + 1] -- 3978
				if not e.alive then -- 3978
					goto __continue673 -- 3980
				end -- 3980
				local y = e.y + (e.depth or 0) -- 3982
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 3983
				if t >= 0 and (best < 0 or t < best) then -- 3983
					best = t -- 3985
					bestI = i -- 3986
				end -- 3986
			end -- 3986
			::__continue673:: -- 3986
			i = i + 1 -- 3977
		end -- 3977
	end -- 3977
	return {t = best, index = bestI} -- 3989
end -- 3974
function Play.prototype.raycastWorld(self, ray) -- 3992
	return self:raycastSolid(ray).t -- 3993
end -- 3992
function Play.prototype.raycastSolid(self, ray) -- 3997
	local best = -1 -- 3998
	local bestBox = nil -- 3999
	for ____, box in ipairs(self.boxes) do -- 4000
		do -- 4000
			if box.broken == true or box.hidden == true then -- 4000
				goto __continue678 -- 4002
			end -- 4002
			local t = hitBox(ray, box) -- 4007
			if t > 2 and (best < 0 or t < best) then -- 4007
				best = t -- 4010
				bestBox = box -- 4011
			end -- 4011
		end -- 4011
		::__continue678:: -- 4011
	end -- 4011
	if ray.dy < 0 then -- 4011
		local t = -ray.y / ray.dy -- 4015
		if t >= 0 and (best < 0 or t < best) then -- 4015
			best = t -- 4017
			bestBox = nil -- 4018
		end -- 4018
	end -- 4018
	return {t = best, box = bestBox} -- 4021
end -- 3997
function Play.prototype.dropFor(self, e) -- 4025
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4025
		return -- 4027
	end -- 4027
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4027
		return -- 4030
	end -- 4030
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4032
	local ____self_pickups_57 = self.pickups -- 4032
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4033
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4034
		kind = e.drop, -- 4034
		x = e.x, -- 4034
		y = e.y, -- 4034
		depth = e.depth, -- 4035
		label = label .. " ×1" -- 4035
	} -- 4035
	self:log("掉落 " .. label) -- 4037
end -- 4025
function Play.prototype.damageProp(self, b, amount) -- 4041
	if b.breakable == nil or b.broken == true then -- 4041
		return -- 4043
	end -- 4043
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4043
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4045
	if b.breakable.hp > 0 then -- 4045
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4047
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4048
		return -- 4049
	end -- 4049
	b.broken = true -- 4051
	for ____, other in ipairs(self.boxes) do -- 4052
		if other.id ~= nil and other.id == b.id then -- 4052
			other.broken = true -- 4054
		end -- 4054
	end -- 4054
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4057
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4058
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4059
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4060
end -- 4041
function Play.prototype.slideDepth(self, a, distance) -- 4064
	a.depth = self:limitDepth(a, a.depth + distance) -- 4065
end -- 4064
function Play.prototype.limitDepth(self, a, target) -- 4068
	local road = self.room.depth -- 4069
	if road == nil or target == a.depth then -- 4069
		return a.depth -- 4071
	end -- 4071
	local next = math.max( -- 4073
		road.min, -- 4073
		math.min(road.max, target) -- 4073
	) -- 4073
	local half = a.w / 2 -- 4074
	for ____, b in ipairs(self.boxes) do -- 4075
		do -- 4075
			local footprint = b.depth -- 4076
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4076
				goto __continue696 -- 4081
			end -- 4081
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4083
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4084
			if a.depth <= front and next > front then -- 4084
				next = front -- 4086
			elseif a.depth >= back and next < back then -- 4086
				next = back -- 4088
			end -- 4088
		end -- 4088
		::__continue696:: -- 4088
	end -- 4088
	return next -- 4091
end -- 4068
function Play.prototype.slideX(self, a, dx) -- 4095
	local nx = a.x + dx -- 4096
	local half = a.w / 2 -- 4097
	local room = self.room -- 4098
	nx = math.max( -- 4099
		room.minX + half, -- 4099
		math.min(room.maxX - half, nx) -- 4099
	) -- 4099
	local i = 0 -- 4100
	do -- 4100
		i = 0 -- 4101
		while i < #self.boxes do -- 4101
			do -- 4101
				local b = self.boxes[i + 1] -- 4102
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4102
					goto __continue703 -- 4104
				end -- 4104
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4104
					goto __continue703 -- 4107
				end -- 4107
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4107
					goto __continue703 -- 4110
				end -- 4110
				if nx + half > b.x0 and nx - half < b.x1 then -- 4110
					if a.x <= b.x0 then -- 4110
						nx = b.x0 - half -- 4114
					elseif a.x >= b.x1 then -- 4114
						nx = b.x1 + half -- 4116
					else -- 4116
						nx = a.x -- 4118
					end -- 4118
				end -- 4118
			end -- 4118
			::__continue703:: -- 4118
			i = i + 1 -- 4101
		end -- 4101
	end -- 4101
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4101
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4126
		local bx0 = self.cartAxle - CART_HALF -- 4127
		local bx1 = self.cartAxle + CART_HALF -- 4128
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4128
			if a.x <= bx0 then -- 4128
				nx = bx0 - half -- 4131
			elseif a.x >= bx1 then -- 4131
				nx = bx1 + half -- 4133
			else -- 4133
				nx = a.x -- 4135
			end -- 4135
		end -- 4135
	end -- 4135
	local arch = room.arch -- 4143
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4143
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4145
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4145
			if a.x <= arch.x0 then -- 4145
				nx = arch.x0 - half -- 4148
			elseif a.x >= arch.x1 then -- 4148
				nx = arch.x1 + half -- 4150
			end -- 4150
		end -- 4150
	end -- 4150
	a.x = nx -- 4154
end -- 4095
function Play.prototype.fallY(self, a, dt) -- 4158
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4159
	if a.vy < -900 then -- 4159
		a.vy = -900 -- 4161
	end -- 4161
	local ny = a.y + a.vy * dt -- 4163
	local half = a.w / 2 -- 4164
	if a.vy <= 0 then -- 4164
		local reach = a.onGround and STEP_UP or 0 -- 4167
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4168
		if ny <= ground then -- 4168
			ny = ground -- 4170
			a.vy = 0 -- 4171
			a.onGround = true -- 4172
		else -- 4172
			a.onGround = false -- 4174
		end -- 4174
	else -- 4174
		a.onGround = false -- 4177
		local i = 0 -- 4178
		do -- 4178
			i = 0 -- 4179
			while i < #self.boxes do -- 4179
				do -- 4179
					local b = self.boxes[i + 1] -- 4180
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4180
						goto __continue727 -- 4182
					end -- 4182
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4182
						goto __continue727 -- 4185
					end -- 4185
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4185
						goto __continue727 -- 4188
					end -- 4188
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4188
						ny = b.y0 - a.h -- 4191
						a.vy = 0 -- 4192
					end -- 4192
				end -- 4192
				::__continue727:: -- 4192
				i = i + 1 -- 4179
			end -- 4179
		end -- 4179
	end -- 4179
	a.y = ny -- 4196
end -- 4158
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4200
	if depth == nil then -- 4200
		depth = 0 -- 4200
	end -- 4200
	local g = -9999 -- 4201
	local i = 0 -- 4202
	do -- 4202
		i = 0 -- 4203
		while i < #self.floors do -- 4203
			local f = self.floors[i + 1] -- 4204
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4204
				g = f.y1 -- 4206
			end -- 4206
			i = i + 1 -- 4203
		end -- 4203
	end -- 4203
	do -- 4203
		i = 0 -- 4209
		while i < #self.boxes do -- 4209
			do -- 4209
				local b = self.boxes[i + 1] -- 4210
				if b.broken == true or b.hidden == true or b.soft == true then -- 4210
					goto __continue737 -- 4212
				end -- 4212
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4212
					g = b.y1 -- 4216
				end -- 4216
			end -- 4216
			::__continue737:: -- 4216
			i = i + 1 -- 4209
		end -- 4209
	end -- 4209
	return g -- 4219
end -- 4200
function Play.prototype.updateCamera(self, dt) -- 4222
	local p = self.player -- 4223
	local tx = p.x + p.facing * 30 -- 4224
	local ty = p.y + CAM_LOOK_UP -- 4225
	local k = math.min(1, CAM_FOLLOW * dt) -- 4226
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4227
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4228
end -- 4222
function Play.prototype.clampCamera(self, w, h) -- 4232
	local room = self.room -- 4233
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4234
	local spanX = room.maxX - room.minX -- 4235
	if spanX <= halfW * 2 then -- 4235
		self.cam.x = (room.minX + room.maxX) / 2 -- 4237
	else -- 4237
		self.cam.x = math.max( -- 4239
			room.minX + halfW, -- 4239
			math.min(room.maxX - halfW, self.cam.x) -- 4239
		) -- 4239
	end -- 4239
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4242
	local spanY = room.height -- 4243
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4244
	if spanY <= halfH * 2 then -- 4244
		self.cam.y = camY -- 4246
	else -- 4246
		self.cam.y = math.max( -- 4248
			camY, -- 4248
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4248
		) -- 4248
	end -- 4248
end -- 4232
function Play.prototype.flashSet(self, text, t) -- 4252
	self.flash = text -- 4253
	self.flashT = t -- 4254
end -- 4252
function Play.prototype.statusText(self) -- 4258
	local p = self.player -- 4259
	local parts = {} -- 4260
	local who = self.childMode and "小满" or "周戍" -- 4261
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4262
	if self.room.key == "prologue" then -- 4262
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4265
		if self.phase == "prologue-wait" then -- 4265
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4267
		elseif self.phase == "prologue-give" then -- 4267
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4269
		else -- 4269
			parts[#parts + 1] = "跟随" -- 4271
		end -- 4271
		if self.paused then -- 4271
			parts[#parts + 1] = "已暂停" -- 4274
		end -- 4274
		return table.concat(parts, " · ") -- 4276
	end -- 4276
	if self.room.key == "street" then -- 4276
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4279
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4280
		if self.paused then -- 4280
			parts[#parts + 1] = "已暂停" -- 4282
		end -- 4282
		return table.concat(parts, " · ") -- 4284
	end -- 4284
	if self.room.key == "gate" then -- 4284
		local ____temp_60 -- 4287
		if self.room.story == nil then -- 4287
			____temp_60 = nil -- 4287
		else -- 4287
			____temp_60 = self.room.story.gate -- 4287
		end -- 4287
		local g = ____temp_60 -- 4287
		if g ~= nil then -- 4287
			parts[#parts + 1] = self:gateLabel() -- 4289
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4290
				0, -- 4291
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4291
			))) .. " 秒" -- 4291
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4292
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4293
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4294
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4295
			if self.gateFailCount > 0 then -- 4295
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4297
			end -- 4297
			if self.flash ~= "" then -- 4297
				parts[#parts + 1] = self.flash -- 4300
			end -- 4300
		end -- 4300
		if self.paused then -- 4300
			parts[#parts + 1] = "已暂停" -- 4304
		end -- 4304
		return table.concat(parts, " · ") -- 4306
	end -- 4306
	if self.room.key == "forest" then -- 4306
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4309
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4310
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4311
		if self.caughtT > 0 then -- 4311
			parts[#parts + 1] = "复位中" -- 4313
		end -- 4313
		if self.paused then -- 4313
			parts[#parts + 1] = "已暂停" -- 4316
		end -- 4316
		return table.concat(parts, " · ") -- 4318
	end -- 4318
	if self.room.key == "tower" then -- 4318
		if self.phase == "tower-wait" then -- 4318
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4322
		elseif self.phase == "tower-knock" then -- 4322
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4324
		elseif self.phase == "tower-given" then -- 4324
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4326
		else -- 4326
			parts[#parts + 1] = "片尾" -- 4328
		end -- 4328
		if self.paused then -- 4328
			parts[#parts + 1] = "已暂停" -- 4331
		end -- 4331
		return table.concat(parts, " · ") -- 4333
	end -- 4333
	if self.room.key == "village" then -- 4333
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4336
		if self.hasBottle then -- 4336
			parts[#parts + 1] = "有瓶" -- 4338
		elseif self.bottleFly ~= nil then -- 4338
			parts[#parts + 1] = "瓶在飞" -- 4340
		else -- 4340
			parts[#parts + 1] = "空手" -- 4342
		end -- 4342
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4344
		if self.scavChase then -- 4344
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4346
		end -- 4346
		if self.passed then -- 4346
			parts[#parts + 1] = "已过通行线" -- 4349
		end -- 4349
		if self.paused then -- 4349
			parts[#parts + 1] = "已暂停" -- 4352
		end -- 4352
		return table.concat(parts, " · ") -- 4354
	end -- 4354
	local isChild = self.childMode -- 4357
	if isChild then -- 4357
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4359
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4360
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4361
	else -- 4361
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4363
		if p.rollT > 0 then -- 4363
			parts[#parts + 1] = "翻滚中" -- 4365
		end -- 4365
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4367
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4368
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4369
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4370
	end -- 4370
	if self.checkpoint >= 0 then -- 4370
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4373
	end -- 4373
	if self.paused then -- 4373
		parts[#parts + 1] = "已暂停" -- 4376
	end -- 4376
	return table.concat(parts, " · ") -- 4378
end -- 4258
function Play.prototype.aliveEnemies(self) -- 4382
	local n = 0 -- 4383
	local i = 0 -- 4384
	do -- 4384
		i = 0 -- 4385
		while i < #self.enemies do -- 4385
			if self.enemies[i + 1].alive then -- 4385
				n = n + 1 -- 4387
			end -- 4387
			i = i + 1 -- 4385
		end -- 4385
	end -- 4385
	return n -- 4390
end -- 4382
function Play.prototype.threatened(self) -- 4395
	do -- 4395
		local i = 0 -- 4396
		while i < #self.enemies do -- 4396
			local e = self.enemies[i + 1] -- 4397
			if e.alive and e.warnT > 0 then -- 4397
				return true -- 4399
			end -- 4399
			i = i + 1 -- 4396
		end -- 4396
	end -- 4396
	return false -- 4402
end -- 4395
function Play.prototype.gateSecondsLeft(self) -- 4405
	local ____temp_61 -- 4406
	if self.room.story == nil then -- 4406
		____temp_61 = nil -- 4406
	else -- 4406
		____temp_61 = self.room.story.gate -- 4406
	end -- 4406
	local g = ____temp_61 -- 4406
	if g == nil then -- 4406
		return 0 -- 4408
	end -- 4408
	return math.max( -- 4410
		0, -- 4410
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4410
	) -- 4410
end -- 4405
function Play.prototype.gateLabel(self) -- 4413
	if self.phase == "gate-idle" then -- 4413
		return "待就位" -- 4415
	end -- 4415
	if self.phase == "gate-hold" then -- 4415
		return "守点中" -- 4418
	end -- 4418
	if self.phase == "gate-send" then -- 4418
		return "送别" -- 4421
	end -- 4421
	if self.phase == "gate-count" then -- 4421
		return "数数 " .. tostring(self.countTick) -- 4424
	end -- 4424
	return "她走" -- 4426
end -- 4413
function Play.prototype.dogLabel(self) -- 4430
	if self.dogState == "ear" then -- 4430
		return "转耳" -- 4432
	end -- 4432
	if self.dogState == "chase" then -- 4432
		return "追" -- 4435
	end -- 4435
	if self.dogState == "sniff" then -- 4435
		return "停" -- 4438
	end -- 4438
	if self.dogState == "back" then -- 4438
		return "回线" -- 4441
	end -- 4441
	return "巡逻" -- 4443
end -- 4430
function Play.prototype.doorXOf(self) -- 4446
	local ____temp_62 -- 4447
	if self.room.story == nil then -- 4447
		____temp_62 = nil -- 4447
	else -- 4447
		____temp_62 = self.room.story.tower -- 4447
	end -- 4447
	local t = ____temp_62 -- 4447
	return t == nil and 0 or t.doorX -- 4448
end -- 4446
function Play.prototype.scavLabel(self) -- 4452
	if self.scavState == "chase" then -- 4452
		return "追" -- 4454
	end -- 4454
	if self.scavState == "turn" then -- 4454
		return "转头" -- 4457
	end -- 4457
	if self.scavState == "walk" then -- 4457
		return "赶来" -- 4460
	end -- 4460
	if self.scavState == "stall" then -- 4460
		return "停住" -- 4463
	end -- 4463
	if self.scavState == "back" then -- 4463
		return "回位" -- 4466
	end -- 4466
	return "巡逻" -- 4468
end -- 4452
function Play.prototype.hintText(self) -- 4472
	if self.paused then -- 4472
		return "Esc 继续 · R 重置" -- 4474
	end -- 4474
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4474
		if self:threatened() then -- 4474
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4480
		end -- 4480
		if self.coverHug then -- 4480
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4483
		end -- 4483
		if self.coverNear then -- 4483
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4486
		end -- 4486
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4488
	end -- 4488
	if self.flash ~= "" then -- 4488
		return self.flash -- 4491
	end -- 4491
	if self.room.key == "prologue" then -- 4491
		if self.phase == "prologue-wait" then -- 4491
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4495
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4496
		end -- 4496
		if self.phase == "prologue-give" then -- 4496
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4499
		end -- 4499
		return "她跟着你了 · 两人一起走到门口 680" -- 4501
	end -- 4501
	if self.room.key == "street" then -- 4501
		if self:aliveEnemies() > 0 then -- 4501
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4505
		end -- 4505
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4507
	end -- 4507
	if self.room.key == "gate" then -- 4507
		local ____temp_63 -- 4510
		if self.room.story == nil then -- 4510
			____temp_63 = nil -- 4510
		else -- 4510
			____temp_63 = self.room.story.gate -- 4510
		end -- 4510
		local g = ____temp_63 -- 4510
		if g ~= nil then -- 4510
			if self.phase == "gate-idle" then -- 4510
				if self.gateNeedConfirm then -- 4510
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4514
				end -- 4514
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4516
			end -- 4516
			if self.phase == "gate-hold" then -- 4516
				if self.coveredFlash > 0 then -- 4516
					return "掩体挡下了这一枪 · 别露头" -- 4520
				end -- 4520
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4522
			end -- 4522
			if self.phase == "gate-send" then -- 4522
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4525
			end -- 4525
			if self.phase == "gate-count" then -- 4525
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4525
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4529
				end -- 4529
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4531
			end -- 4531
			return "她自己走 · 跟着出城门 1120" -- 4533
		end -- 4533
	end -- 4533
	if self.room.key == "forest" then -- 4533
		if self.dogState == "chase" then -- 4533
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4538
		end -- 4538
		if self.dogState == "ear" then -- 4538
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4541
		end -- 4541
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4543
	end -- 4543
	if self.room.key == "tower" then -- 4543
		if self.phase == "tower-wait" then -- 4543
			return "走到门前 445 点一次 E 敲两下" -- 4547
		end -- 4547
		if self.phase == "tower-knock" then -- 4547
			return "敲两下 · 等门开" -- 4550
		end -- 4550
		if self.phase == "tower-given" then -- 4550
			return "递交针套和纸条 · 看登记簿最后一行" -- 4553
		end -- 4553
		return "片尾 · 点 E 再玩一次，回到序章" -- 4555
	end -- 4555
	if self.room.key == "village" then -- 4555
		if self.bottleFly ~= nil then -- 4555
			return "等瓶子落地 · 触地才发声" -- 4559
		end -- 4559
		if self.hasBottle then -- 4559
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4562
		end -- 4562
		if self.passed then -- 4562
			return "已过第一院 · R 重置可再来一遍" -- 4565
		end -- 4565
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4567
	end -- 4567
	if self.room.key == "outside" then -- 4567
		if self.focusCart then -- 4567
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4571
		end -- 4571
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4573
	end -- 4573
	if self.escort.state == "frozen" then -- 4573
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4573
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4577
		end -- 4577
		return "小满吓住了 · 走过去，靠近再点 E" -- 4579
	end -- 4579
	if self.escort.state == "calming" then -- 4579
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4582
	end -- 4582
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4584
end -- 4472
function Play.prototype.draw(self, draw, w, h) -- 4589
	self.viewW = w -- 4590
	self.viewH = h -- 4591
	self.view = ____exports.computeViewport(w, h) -- 4592
	self:clampCamera(w, h) -- 4593
	draw:clear() -- 4594
	draw:drawRect( -- 4596
		Rect(0, 0, w, h), -- 4596
		BG_VOID -- 4596
	) -- 4596
	local box = self:canvasRect(w, h) -- 4597
	draw:drawRect(box, BG_FAR) -- 4598
	draw:drawRect( -- 4599
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4599
		BG_MID -- 4599
	) -- 4599
	self:drawFloors(draw, w, h) -- 4601
	self:drawSolids(draw, w, h) -- 4602
	self:drawZones(draw, w, h) -- 4603
	self:drawArch(draw, w, h) -- 4604
	self:drawCart(draw, w, h) -- 4605
	self:drawCampaignProps(draw, w, h) -- 4606
	self:drawActors(draw, w, h) -- 4607
	self:drawTrace(draw, w, h) -- 4608
	self:drawAim(draw, w, h) -- 4609
end -- 4589
function Play.prototype.canvasRect(self, w, h) -- 4613
	local v = self.view -- 4614
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4615
end -- 4613
function Play.prototype.px(self, n) -- 4619
	return n * self.view.zoom -- 4620
end -- 4619
function Play.prototype.sx(self, wx, w) -- 4624
	local v = self.view -- 4625
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4626
	return v.ox + lx * v.zoom -- 4627
end -- 4624
function Play.prototype.sy(self, wy, h) -- 4631
	local v = self.view -- 4632
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4633
	return v.oy + ly * v.zoom -- 4634
end -- 4631
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4637
	local px0 = self:sx(x0, w) -- 4638
	local px1 = self:sx(x1, w) -- 4639
	local py0 = self:sy(y0, h) -- 4640
	local py1 = self:sy(y1, h) -- 4641
	if px1 <= px0 or py1 <= py0 then -- 4641
		return -- 4643
	end -- 4643
	draw:drawRect( -- 4645
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4645
		color -- 4645
	) -- 4645
end -- 4637
function Play.prototype.drawFloors(self, draw, w, h) -- 4648
	local i = 0 -- 4649
	do -- 4649
		i = 0 -- 4650
		while i < #self.room.floors do -- 4650
			local f = self.room.floors[i + 1] -- 4651
			local ____temp_64 -- 4652
			if f.y == 0 then -- 4652
				____temp_64 = self.room.depth -- 4652
			else -- 4652
				____temp_64 = nil -- 4652
			end -- 4652
			local road = ____temp_64 -- 4652
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4653
			local x0 = self:sx(f.x0, w) -- 4654
			local x1 = self:sx(f.x1, w) -- 4655
			local deck = self:px(5) -- 4656
			if road ~= nil then -- 4656
				local back = self:sy(f.y + road.max, h) -- 4658
				draw:drawRect( -- 4659
					Rect(x0, y, x1 - x0, back - y), -- 4659
					FLOOR_DECK, -- 4659
					self:px(1), -- 4659
					SOLID_EDGE -- 4659
				) -- 4659
			end -- 4659
			draw:drawRect( -- 4661
				Rect(x0, y - deck, x1 - x0, deck), -- 4661
				FLOOR_DECK -- 4661
			) -- 4661
			draw:drawSegment( -- 4662
				Vec2(x0, y), -- 4662
				Vec2(x1, y), -- 4662
				self:px(1), -- 4662
				GROUND -- 4662
			) -- 4662
			i = i + 1 -- 4650
		end -- 4650
	end -- 4650
end -- 4648
function Play.prototype.drawSolids(self, draw, w, h) -- 4666
	local i = 0 -- 4667
	do -- 4667
		i = 0 -- 4668
		while i < #self.boxes do -- 4668
			do -- 4668
				local b = self.boxes[i + 1] -- 4669
				if b.id == "braced_shield" or b.hidden == true then -- 4669
					goto __continue858 -- 4671
				end -- 4671
				if b.broken == true then -- 4671
					if b.breakable ~= nil then -- 4671
						local gy = self:sy(b.y0, h) -- 4676
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4677
						local k = 0 -- 4678
						do -- 4678
							k = 0 -- 4679
							while k < 3 do -- 4679
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4680
								draw:drawSegment( -- 4681
									Vec2( -- 4681
										gx - self:px(4), -- 4681
										gy + self:px(k % 2) -- 4681
									), -- 4681
									Vec2( -- 4681
										gx + self:px(5), -- 4681
										gy + self:px(k % 2) -- 4681
									), -- 4681
									self:px(1), -- 4681
									rgb -- 4681
								) -- 4681
								k = k + 1 -- 4679
							end -- 4679
						end -- 4679
					end -- 4679
					goto __continue858 -- 4684
				end -- 4684
				local ____opt_67 = b.depth -- 4684
				local front = ____opt_67 and ____opt_67.min or 0 -- 4686
				local ____opt_69 = b.depth -- 4686
				local back = ____opt_69 and ____opt_69.max or 0 -- 4687
				local fill = SOLID_FILL -- 4688
				local line = SOLID_EDGE -- 4689
				if b.soft == true then -- 4689
					fill = SOFT -- 4691
					line = SOFT_LINE -- 4692
				elseif b.breakable ~= nil then -- 4692
					line = DANGER_LINE -- 4694
					fill = Color(0.3, 0.24, 0.16, 1) -- 4695
				elseif b.interact ~= nil then -- 4695
					line = PASS_LINE -- 4697
				end -- 4697
				self:drawBox( -- 4699
					draw, -- 4699
					w, -- 4699
					h, -- 4699
					b.x0, -- 4699
					b.x1, -- 4699
					b.y0 + front, -- 4699
					b.y1 + back, -- 4699
					fill -- 4699
				) -- 4699
				draw:drawSegment( -- 4700
					Vec2( -- 4700
						self:sx(b.x0, w), -- 4700
						self:sy(b.y1 + front, h) -- 4700
					), -- 4700
					Vec2( -- 4701
						self:sx(b.x1, w), -- 4701
						self:sy(b.y1 + front, h) -- 4701
					), -- 4701
					self:px(1), -- 4701
					line -- 4701
				) -- 4701
				if b.breakable ~= nil then -- 4701
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4704
					local cyp = self:sy(b.y1 + front, h) -- 4705
					draw:drawSegment( -- 4706
						Vec2( -- 4706
							cxp - self:px(4), -- 4706
							cyp + self:px(1) -- 4706
						), -- 4706
						Vec2( -- 4706
							cxp + self:px(3), -- 4706
							cyp + self:px(5) -- 4706
						), -- 4706
						self:px(1), -- 4706
						line -- 4706
					) -- 4706
				end -- 4706
			end -- 4706
			::__continue858:: -- 4706
			i = i + 1 -- 4668
		end -- 4668
	end -- 4668
end -- 4666
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4712
	local i = 0 -- 4713
	do -- 4713
		i = 0 -- 4714
		while i < #self.pickups do -- 4714
			do -- 4714
				local pk = self.pickups[i + 1] -- 4715
				if pk.id == "" then -- 4715
					goto __continue870 -- 4717
				end -- 4717
				local gy = pk.y + (pk.depth or 0) -- 4719
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4720
				draw:drawRect( -- 4721
					Rect( -- 4721
						self:sx(pk.x - 5, w), -- 4721
						self:sy(gy + 12 + bob, h), -- 4721
						self:px(10), -- 4721
						self:px(10) -- 4721
					), -- 4721
					Color(0.84, 0.7, 0.3, 1) -- 4722
				) -- 4722
				draw:drawSegment( -- 4723
					Vec2( -- 4723
						self:sx(pk.x - 5, w), -- 4723
						self:sy(gy + 12 + bob, h) -- 4723
					), -- 4723
					Vec2( -- 4724
						self:sx(pk.x + 5, w), -- 4724
						self:sy(gy + 12 + bob, h) -- 4724
					), -- 4724
					self:px(1), -- 4724
					Color(0.95, 0.86, 0.52, 1) -- 4724
				) -- 4724
			end -- 4724
			::__continue870:: -- 4724
			i = i + 1 -- 4714
		end -- 4714
	end -- 4714
	if self.bracedShield ~= nil then -- 4714
		local sh = self.bracedShield -- 4727
		draw:drawRect( -- 4728
			Rect( -- 4728
				self:sx(sh.x - sh.w / 2, w), -- 4728
				self:sy(sh.y, h), -- 4728
				self:px(sh.w), -- 4728
				self:px(sh.h) -- 4728
			), -- 4728
			Color(0.42, 0.4, 0.34, 1) -- 4729
		) -- 4729
		draw:drawSegment( -- 4730
			Vec2( -- 4730
				self:sx(sh.x - sh.w / 2, w), -- 4730
				self:sy(sh.y + sh.h, h) -- 4730
			), -- 4730
			Vec2( -- 4731
				self:sx(sh.x + sh.w / 2, w), -- 4731
				self:sy(sh.y + sh.h, h) -- 4731
			), -- 4731
			self:px(1), -- 4731
			Color(0.74, 0.72, 0.62, 1) -- 4731
		) -- 4731
	end -- 4731
end -- 4712
function Play.prototype.drawZones(self, draw, w, h) -- 4735
	local i = 0 -- 4736
	do -- 4736
		i = 0 -- 4737
		while i < #self.room.zones do -- 4737
			local z = self.room.zones[i + 1] -- 4738
			local fill = DANGER -- 4739
			local line = DANGER_LINE -- 4740
			if z.tint == 2 then -- 4740
				fill = SOFT -- 4742
				line = SOFT_LINE -- 4743
			elseif z.tint == 3 then -- 4743
				fill = BRICK -- 4745
				line = BRICK_LINE -- 4746
			elseif z.tint == 4 then -- 4746
				fill = PASS -- 4748
				line = PASS_LINE -- 4749
			end -- 4749
			self:drawBox( -- 4751
				draw, -- 4751
				w, -- 4751
				h, -- 4751
				z.x0, -- 4751
				z.x1, -- 4751
				z.y, -- 4751
				z.y + z.h, -- 4751
				fill -- 4751
			) -- 4751
			draw:drawSegment( -- 4752
				Vec2( -- 4752
					self:sx(z.x0, w), -- 4752
					self:sy(z.y, h) -- 4752
				), -- 4752
				Vec2( -- 4752
					self:sx(z.x0, w), -- 4752
					self:sy(z.y + z.h, h) -- 4752
				), -- 4752
				self:px(1), -- 4752
				line -- 4752
			) -- 4752
			draw:drawSegment( -- 4753
				Vec2( -- 4753
					self:sx(z.x1, w), -- 4753
					self:sy(z.y, h) -- 4753
				), -- 4753
				Vec2( -- 4753
					self:sx(z.x1, w), -- 4753
					self:sy(z.y + z.h, h) -- 4753
				), -- 4753
				self:px(1), -- 4753
				line -- 4753
			) -- 4753
			i = i + 1 -- 4737
		end -- 4737
	end -- 4737
end -- 4735
function Play.prototype.drawArch(self, draw, w, h) -- 4757
	local a = self.room.arch -- 4758
	if a.h <= 0 then -- 4758
		return -- 4760
	end -- 4760
	self:drawBox( -- 4762
		draw, -- 4762
		w, -- 4762
		h, -- 4762
		a.x0, -- 4762
		a.x1, -- 4762
		a.y, -- 4762
		a.y + a.h, -- 4762
		HOLE_FILL -- 4762
	) -- 4762
	draw:drawSegment( -- 4763
		Vec2( -- 4763
			self:sx(a.x0, w), -- 4763
			self:sy(a.y + a.h, h) -- 4763
		), -- 4763
		Vec2( -- 4763
			self:sx(a.x1, w), -- 4763
			self:sy(a.y + a.h, h) -- 4763
		), -- 4763
		self:px(1), -- 4763
		SOLID_EDGE -- 4763
	) -- 4763
	draw:drawSegment( -- 4764
		Vec2( -- 4764
			self:sx(a.x0, w), -- 4764
			self:sy(a.y, h) -- 4764
		), -- 4764
		Vec2( -- 4764
			self:sx(a.x0, w), -- 4764
			self:sy(a.y + a.h, h) -- 4764
		), -- 4764
		self:px(1), -- 4764
		SOLID_EDGE -- 4764
	) -- 4764
	draw:drawSegment( -- 4765
		Vec2( -- 4765
			self:sx(a.x1, w), -- 4765
			self:sy(a.y, h) -- 4765
		), -- 4765
		Vec2( -- 4765
			self:sx(a.x1, w), -- 4765
			self:sy(a.y + a.h, h) -- 4765
		), -- 4765
		self:px(1), -- 4765
		SOLID_EDGE -- 4765
	) -- 4765
end -- 4757
function Play.prototype.drawCart(self, draw, w, h) -- 4768
	local c = self.room.cart -- 4769
	if c.bodyW <= 0 then -- 4769
		return -- 4771
	end -- 4771
	drawCartShape( -- 4773
		draw, -- 4773
		self, -- 4773
		w, -- 4773
		h, -- 4773
		c, -- 4773
		self.cartAxle -- 4773
	) -- 4773
	draw:drawRect( -- 4774
		Rect( -- 4774
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4774
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4774
			self:px(2), -- 4774
			self:px(40) -- 4774
		), -- 4774
		STAND -- 4774
	) -- 4774
end -- 4768
function Play.prototype.drawActors(self, draw, w, h) -- 4777
	local p = self.player -- 4778
	local isChild = self.childMode -- 4779
	local footY = p.y + p.depth -- 4780
	if p.covered then -- 4780
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4783
		draw:drawSegment( -- 4784
			Vec2( -- 4784
				self:sx(edge, w), -- 4784
				self:sy(footY + 8, h) -- 4784
			), -- 4784
			Vec2( -- 4784
				self:sx(edge, w), -- 4784
				self:sy(footY + p.h * 0.62, h) -- 4784
			), -- 4784
			self:px(2), -- 4784
			STAND -- 4784
		) -- 4784
		draw:drawSegment( -- 4786
			Vec2( -- 4786
				self:sx(p.x - 8, w), -- 4786
				self:sy(footY + p.h + 3, h) -- 4786
			), -- 4786
			Vec2( -- 4786
				self:sx(p.x + 8, w), -- 4786
				self:sy(footY + p.h + 3, h) -- 4786
			), -- 4786
			self:px(2), -- 4786
			STAND -- 4786
		) -- 4786
	elseif self.coverNear and not isChild then -- 4786
		draw:drawRect( -- 4789
			Rect( -- 4789
				self:sx(p.x - 3, w), -- 4789
				self:sy(footY + 1, h), -- 4789
				self:px(3), -- 4789
				self:px(3) -- 4789
			), -- 4789
			STAND -- 4789
		) -- 4789
	end -- 4789
	drawFigure( -- 4791
		draw, -- 4791
		self, -- 4791
		w, -- 4791
		h, -- 4791
		p, -- 4791
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4791
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4791
	) -- 4791
	local q = self.partner -- 4792
	if q.alive then -- 4792
		local childPartner = q.w == CHILD_W -- 4794
		drawFigure( -- 4795
			draw, -- 4795
			self, -- 4795
			w, -- 4795
			h, -- 4795
			q, -- 4795
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4795
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4795
		) -- 4795
	end -- 4795
	local i = 0 -- 4797
	do -- 4797
		i = 0 -- 4798
		while i < #self.enemies do -- 4798
			local e = self.enemies[i + 1] -- 4799
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4800
			local enemyY = e.y + (e.depth or 0) -- 4801
			self:drawBox( -- 4802
				draw, -- 4802
				w, -- 4802
				h, -- 4802
				e.x - e.w / 2, -- 4802
				e.x + e.w / 2, -- 4802
				enemyY, -- 4802
				enemyY + e.h, -- 4802
				col -- 4802
			) -- 4802
			if e.alive then -- 4802
				local ef = p.x >= e.x and 1 or -1 -- 4804
				if e.kind == "shield" then -- 4804
					local sh = (e.shieldHp or 0) > 0 -- 4806
					draw:drawRect( -- 4807
						Rect( -- 4807
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4807
							self:sy(enemyY, h), -- 4807
							self:px(6), -- 4807
							self:px(64) -- 4807
						), -- 4807
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4808
					) -- 4808
				elseif e.kind == "breaker" then -- 4808
					draw:drawSegment( -- 4810
						Vec2( -- 4810
							self:sx(e.x + ef * 12, w), -- 4810
							self:sy(enemyY + 8, h) -- 4810
						), -- 4810
						Vec2( -- 4811
							self:sx(e.x + ef * 22, w), -- 4811
							self:sy(enemyY + 46, h) -- 4811
						), -- 4811
						self:px(3), -- 4811
						Color(0.5, 0.36, 0.22, 1) -- 4811
					) -- 4811
				end -- 4811
			end -- 4811
			if e.alive and e.warnT > 0 then -- 4811
				local gunX = self:sx(e.x, w) -- 4816
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4817
				local aimX = self:sx(p.x, w) -- 4818
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4819
				local seg = 8 -- 4820
				local s = 0 -- 4821
				do -- 4821
					s = 0 -- 4822
					while s < seg do -- 4822
						local t0 = s / seg -- 4823
						local t1 = (s + 1) / seg -- 4824
						draw:drawSegment( -- 4825
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4826
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4827
							self:px(1), -- 4828
							DANGER -- 4828
						) -- 4828
						s = s + 2 -- 4822
					end -- 4822
				end -- 4822
			end -- 4822
			i = i + 1 -- 4798
		end -- 4798
	end -- 4798
	local k = 0 -- 4833
	do -- 4833
		k = 0 -- 4834
		while k < #self.room.marks do -- 4834
			do -- 4834
				local m = self.room.marks[k + 1] -- 4835
				if m.kind ~= 0 then -- 4835
					goto __continue896 -- 4837
				end -- 4837
				local on = self.checkpoint == m.x -- 4839
				local x = self:sx(m.x, w) -- 4840
				local y = self:sy(m.y, h) -- 4841
				draw:drawSegment( -- 4842
					Vec2(x, y), -- 4842
					Vec2( -- 4842
						x, -- 4842
						y + self:px(35) -- 4842
					), -- 4842
					self:px(1), -- 4842
					on and CHECK or INK_DIM -- 4842
				) -- 4842
				draw:drawDot( -- 4843
					Vec2( -- 4843
						x, -- 4843
						y + self:px(35) -- 4843
					), -- 4843
					self:px(2), -- 4843
					on and CHECK or INK_DIM -- 4843
				) -- 4843
			end -- 4843
			::__continue896:: -- 4843
			k = k + 1 -- 4834
		end -- 4834
	end -- 4834
	local j = 0 -- 4847
	do -- 4847
		j = 0 -- 4848
		while j < #self.room.marks do -- 4848
			do -- 4848
				local m = self.room.marks[j + 1] -- 4849
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4849
					goto __continue899 -- 4851
				end -- 4851
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4851
					goto __continue899 -- 4855
				end -- 4855
				local col = STAND -- 4857
				if m.kind == 4 then -- 4857
					col = PASS_LINE -- 4859
				elseif m.kind == 5 then -- 4859
					col = BRICK_LINE -- 4861
				end -- 4861
				local mx = self:sx(m.x, w) -- 4863
				local my = self:sy(m.y, h) -- 4864
				draw:drawSegment( -- 4865
					Vec2(mx, my), -- 4865
					Vec2( -- 4865
						mx, -- 4865
						my + self:px(24) -- 4865
					), -- 4865
					self:px(1), -- 4865
					col -- 4865
				) -- 4865
			end -- 4865
			::__continue899:: -- 4865
			j = j + 1 -- 4848
		end -- 4848
	end -- 4848
	local t = 0 -- 4868
	do -- 4868
		t = 0 -- 4869
		while t < #self.room.marks do -- 4869
			do -- 4869
				local m = self.room.marks[t + 1] -- 4870
				if m.kind ~= 6 then -- 4870
					goto __continue905 -- 4872
				end -- 4872
				local mx = self:sx(m.x, w) -- 4874
				local my = self:sy(m.y, h) -- 4875
				draw:drawSegment( -- 4876
					Vec2(mx, my), -- 4876
					Vec2( -- 4876
						mx, -- 4876
						my + self:px(30) -- 4876
					), -- 4876
					self:px(1), -- 4876
					INK_DIM -- 4876
				) -- 4876
				self:drawBox( -- 4877
					draw, -- 4877
					w, -- 4877
					h, -- 4877
					m.x - 5, -- 4877
					m.x + 5, -- 4877
					m.y + 30, -- 4877
					m.y + 40, -- 4877
					CHECK -- 4877
				) -- 4877
			end -- 4877
			::__continue905:: -- 4877
			t = t + 1 -- 4869
		end -- 4869
	end -- 4869
	if self.room.key == "village" then -- 4869
		self:drawVillage(draw, w, h) -- 4880
	end -- 4880
	if self.room.key == "forest" then -- 4880
		self:drawDog(draw, w, h) -- 4883
	end -- 4883
end -- 4777
function Play.prototype.drawDog(self, draw, w, h) -- 4888
	local x = self.dogX -- 4889
	self:drawBox( -- 4890
		draw, -- 4890
		w, -- 4890
		h, -- 4890
		x - 14, -- 4890
		x + 14, -- 4890
		0, -- 4890
		20, -- 4890
		SCAV_BODY -- 4890
	) -- 4890
	self:drawBox( -- 4891
		draw, -- 4891
		w, -- 4891
		h, -- 4891
		x - 10, -- 4891
		x - 2, -- 4891
		20, -- 4891
		30, -- 4891
		SCAV_BODY -- 4891
	) -- 4891
	self:drawBox( -- 4892
		draw, -- 4892
		w, -- 4892
		h, -- 4892
		x + 2, -- 4892
		x + 10, -- 4892
		20, -- 4892
		30, -- 4892
		SCAV_HEAD -- 4892
	) -- 4892
	if self.dogState == "ear" or self.dogState == "chase" then -- 4892
		draw:drawSegment( -- 4894
			Vec2( -- 4894
				self:sx(x, w), -- 4894
				self:sy(30, h) -- 4894
			), -- 4894
			Vec2( -- 4895
				self:sx(x, w), -- 4895
				self:sy(40, h) -- 4895
			), -- 4895
			self:px(1), -- 4895
			DANGER -- 4895
		) -- 4895
	end -- 4895
end -- 4888
function Play.prototype.drawVillage(self, draw, w, h) -- 4900
	local bottle = self.room.bottle -- 4901
	if bottle ~= nil then -- 4901
		self:drawBox( -- 4903
			draw, -- 4903
			w, -- 4903
			h, -- 4903
			bottle.x - 14, -- 4903
			bottle.x + 14, -- 4903
			0, -- 4903
			64, -- 4903
			SOLID_FILL -- 4903
		) -- 4903
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4903
			self:drawBottle( -- 4905
				draw, -- 4905
				w, -- 4905
				h, -- 4905
				bottle.x, -- 4905
				64 -- 4905
			) -- 4905
		end -- 4905
	end -- 4905
	self:drawBox( -- 4909
		draw, -- 4909
		w, -- 4909
		h, -- 4909
		300, -- 4909
		420, -- 4909
		44, -- 4909
		50, -- 4909
		FLOOR_DECK -- 4909
	) -- 4909
	self:drawBox( -- 4910
		draw, -- 4910
		w, -- 4910
		h, -- 4910
		300, -- 4910
		306, -- 4910
		0, -- 4910
		44, -- 4910
		FLOOR_DECK -- 4910
	) -- 4910
	self:drawBox( -- 4911
		draw, -- 4911
		w, -- 4911
		h, -- 4911
		414, -- 4911
		420, -- 4911
		0, -- 4911
		44, -- 4911
		FLOOR_DECK -- 4911
	) -- 4911
	local s = self.room.scavenger -- 4913
	if s ~= nil then -- 4913
		local sx0 = self.scavX -- 4915
		self:drawBox( -- 4916
			draw, -- 4916
			w, -- 4916
			h, -- 4916
			sx0 - 12, -- 4916
			sx0 + 12, -- 4916
			0, -- 4916
			s.h - 14, -- 4916
			SCAV_BODY -- 4916
		) -- 4916
		self:drawBox( -- 4917
			draw, -- 4917
			w, -- 4917
			h, -- 4917
			sx0 - 7, -- 4917
			sx0 + 7, -- 4917
			s.h - 14, -- 4917
			s.h, -- 4917
			SCAV_HEAD -- 4917
		) -- 4917
		if self.scavState == "turn" then -- 4917
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4919
			draw:drawSegment( -- 4920
				Vec2( -- 4920
					self:sx(sx0, w), -- 4920
					self:sy(s.h - 6, h) -- 4920
				), -- 4920
				Vec2( -- 4920
					self:sx(fx, w), -- 4920
					self:sy(s.h - 6, h) -- 4920
				), -- 4920
				self:px(1), -- 4920
				INK -- 4920
			) -- 4920
		end -- 4920
	end -- 4920
	if self.hasBottle then -- 4920
		local p = self.player -- 4925
		self:drawBottle( -- 4926
			draw, -- 4926
			w, -- 4926
			h, -- 4926
			p.x + p.facing * 10, -- 4926
			p.y + p.h * 0.62 -- 4926
		) -- 4926
	end -- 4926
	if self.bottleFly ~= nil then -- 4926
		self:drawBottle( -- 4929
			draw, -- 4929
			w, -- 4929
			h, -- 4929
			self.bottleFly.x, -- 4929
			self.bottleFly.y -- 4929
		) -- 4929
	end -- 4929
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 4929
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 4932
		draw:drawCircle( -- 4933
			Vec2( -- 4933
				self:sx(self.bottleLandX, w), -- 4933
				self:sy(0, h) -- 4933
			), -- 4933
			self:px(r / ____exports.UNITS_PER_PX), -- 4933
			BRICK_LINE -- 4933
		) -- 4933
	end -- 4933
end -- 4900
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 4937
	self:drawBox( -- 4938
		draw, -- 4938
		w, -- 4938
		h, -- 4938
		x - 3, -- 4938
		x + 3, -- 4938
		y - 10, -- 4938
		y, -- 4938
		BOTTLE -- 4938
	) -- 4938
end -- 4937
function Play.prototype.drawTrace(self, draw, w, h) -- 4941
	local t = self.trace -- 4942
	if t == nil or self.traceT <= 0 then -- 4942
		return -- 4944
	end -- 4944
	draw:drawSegment( -- 4946
		Vec2( -- 4947
			self:sx(t.x0, w), -- 4947
			self:sy(t.y0, h) -- 4947
		), -- 4947
		Vec2( -- 4948
			self:sx(t.x1, w), -- 4948
			self:sy(t.y1, h) -- 4948
		), -- 4948
		self:px(1), -- 4949
		t.hit and AIM_HIT or INK_DIM -- 4949
	) -- 4949
end -- 4941
function Play.prototype.drawAim(self, draw, w, h) -- 4952
	local v = self.view -- 4954
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 4955
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 4956
	local dot = self:px(1) -- 4957
	local arm = self:px(3) -- 4958
	local gap = self:px(1) -- 4959
	draw:drawSegment( -- 4960
		Vec2(gx - arm - gap, gy), -- 4960
		Vec2(gx - gap, gy), -- 4960
		dot / 2, -- 4960
		AIM -- 4960
	) -- 4960
	draw:drawSegment( -- 4961
		Vec2(gx + gap, gy), -- 4961
		Vec2(gx + arm + gap, gy), -- 4961
		dot / 2, -- 4961
		AIM -- 4961
	) -- 4961
	draw:drawSegment( -- 4962
		Vec2(gx, gy - arm - gap), -- 4962
		Vec2(gx, gy - gap), -- 4962
		dot / 2, -- 4962
		AIM -- 4962
	) -- 4962
	draw:drawSegment( -- 4963
		Vec2(gx, gy + gap), -- 4963
		Vec2(gx, gy + arm + gap), -- 4963
		dot / 2, -- 4963
		AIM -- 4963
	) -- 4963
	if self.room.key == "village" and self.hasBottle then -- 4963
		local p = self.player -- 4967
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4969
		local dir = ____end.x >= p.x and 1 or -1 -- 4970
		local x0 = p.x + dir * 10 -- 4971
		local y0 = p.y + p.h * 0.7 -- 4972
		local T = BOTTLE_FLY_TIME -- 4973
		local vx = (____end.x - x0) / T -- 4974
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 4975
		local pxr = x0 -- 4976
		local pyr = y0 -- 4977
		local t = 1 -- 4978
		do -- 4978
			t = 1 -- 4979
			while t <= 12 do -- 4979
				local tt = t / 12 * T -- 4980
				local nx = x0 + vx * tt -- 4981
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 4982
				draw:drawSegment( -- 4983
					Vec2( -- 4983
						self:sx(pxr, w), -- 4983
						self:sy(pyr, h) -- 4983
					), -- 4983
					Vec2( -- 4983
						self:sx(nx, w), -- 4983
						self:sy(ny, h) -- 4983
					), -- 4983
					self:px(1) / 2, -- 4983
					BOTTLE -- 4983
				) -- 4983
				pxr = nx -- 4984
				pyr = ny -- 4985
				t = t + 1 -- 4979
			end -- 4979
		end -- 4979
		draw:drawCircle( -- 4987
			Vec2( -- 4987
				self:sx(____end.x, w), -- 4987
				self:sy(____end.y + 2, h) -- 4987
			), -- 4987
			self:px(2), -- 4987
			BOTTLE -- 4987
		) -- 4987
	end -- 4987
end -- 4952
return ____exports -- 4952