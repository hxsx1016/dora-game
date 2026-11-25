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
function makeActor(room, index) -- 4996
	local sp = room.spawns -- 4997
	if index < 0 or index >= #sp then -- 4997
		return { -- 4999
			x = 0, -- 4999
			y = 0, -- 4999
			depth = 0, -- 4999
			depthSpeed = 0, -- 4999
			vx = 0, -- 4999
			vy = 0, -- 4999
			w = CHILD_W, -- 4999
			h = CHILD_H, -- 4999
			onGround = true, -- 4999
			facing = 1, -- 4999
			crouch = false, -- 4999
			rollT = 0, -- 4999
			covered = false, -- 4999
			alive = false -- 4999
		} -- 4999
	end -- 4999
	local s = sp[index + 1] -- 5001
	local child = s.h <= CHILD_H -- 5002
	local ground = room.depth -- 5003
	local depth = ground == nil and 0 or math.max( -- 5004
		ground.min, -- 5004
		math.min(ground.max, s.depth or 0) -- 5004
	) -- 5004
	return { -- 5005
		x = s.x, -- 5006
		y = s.y, -- 5006
		depth = depth, -- 5006
		depthSpeed = 0, -- 5006
		vx = 0, -- 5006
		vy = 0, -- 5006
		w = child and CHILD_W or SOLDIER_W, -- 5007
		h = child and CHILD_H or SOLDIER_H, -- 5008
		onGround = true, -- 5009
		facing = 1, -- 5009
		crouch = false, -- 5009
		rollT = 0, -- 5009
		covered = false, -- 5009
		alive = true -- 5009
	} -- 5009
end -- 5009
function drawFigure(draw, play, w, h, a, body, head) -- 5013
	if not a.alive then -- 5013
		return -- 5015
	end -- 5015
	local x0 = a.x - a.w / 2 -- 5017
	local x1 = a.x + a.w / 2 -- 5018
	local y0 = a.y + a.depth -- 5019
	local y1 = y0 + a.h -- 5020
	play:drawBox( -- 5021
		draw, -- 5021
		w, -- 5021
		h, -- 5021
		x0, -- 5021
		x1, -- 5021
		y0, -- 5021
		y1 - a.h * 0.26, -- 5021
		body -- 5021
	) -- 5021
	play:drawBox( -- 5022
		draw, -- 5022
		w, -- 5022
		h, -- 5022
		x0 + 2, -- 5022
		x1 - 2, -- 5022
		y1 - a.h * 0.26, -- 5022
		y1, -- 5022
		head -- 5022
	) -- 5022
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5024
	play:drawBox( -- 5025
		draw, -- 5025
		w, -- 5025
		h, -- 5025
		eyeX, -- 5025
		eyeX + 4, -- 5025
		y1 - a.h * 0.14, -- 5025
		y1 - a.h * 0.08, -- 5025
		INK -- 5025
	) -- 5025
end -- 5025
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5029
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5030
end -- 5029
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5037
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5038
end -- 5037
function rayInterval(origin, direction, min, max) -- 5045
	if direction == 0 then -- 5045
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5047
	end -- 5047
	local a = (min - origin) / direction -- 5049
	local b = (max - origin) / direction -- 5050
	return { -- 5051
		min = math.min(a, b), -- 5051
		max = math.max(a, b) -- 5051
	} -- 5051
end -- 5051
function hitBox(ray, box) -- 5055
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5056
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5057
	local enter = math.max(0, x.min, y.min) -- 5058
	local leave = math.min(99999, x.max, y.max) -- 5059
	if box.depth ~= nil then -- 5059
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5061
		enter = math.max(enter, depth.min) -- 5062
		leave = math.min(leave, depth.max) -- 5063
	end -- 5063
	return leave >= enter and enter or -1 -- 5065
end -- 5065
function drawCartShape(draw, play, w, h, c, axleX) -- 5068
	local half = c.bodyW / 2 -- 5069
	local x0 = axleX - half -- 5070
	local x1 = axleX + half -- 5071
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5072
	play:drawBox( -- 5073
		draw, -- 5073
		w, -- 5073
		h, -- 5073
		x0, -- 5073
		x1, -- 5073
		axleY, -- 5073
		axleY + c.bodyH, -- 5073
		CART_FILL -- 5073
	) -- 5073
	draw:drawCircle( -- 5074
		Vec2( -- 5074
			play:sx(x0 + c.bodyW * 0.28, w), -- 5074
			play:sy(axleY, h) -- 5074
		), -- 5074
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5074
		Color(52, 50, 48, 255) -- 5074
	) -- 5074
	draw:drawCircle( -- 5075
		Vec2( -- 5075
			play:sx(x1 - c.bodyW * 0.28, w), -- 5075
			play:sy(axleY, h) -- 5075
		), -- 5075
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5075
		Color(52, 50, 48, 255) -- 5075
	) -- 5075
	local cx = c.clothSide < 0 and x0 or x1 -- 5076
	play:drawBox( -- 5077
		draw, -- 5077
		w, -- 5077
		h, -- 5077
		cx - 10, -- 5077
		cx + 10, -- 5077
		axleY + c.bodyH, -- 5077
		axleY + c.bodyH + 18, -- 5077
		CLOTH -- 5077
	) -- 5077
end -- 5077
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
		if input.interact.pressed or input.pause.pressed then -- 1331
			self:closeCraftBench() -- 1337
		end -- 1337
		self:updateCamera(dt) -- 1339
		return -- 1340
	end -- 1340
	if self.reloadOpen then -- 1340
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1346
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1346
			self.reloadOpen = false -- 1348
			self.reloadPendingEffect = "" -- 1349
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1350
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1351
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1351
			self:updateCamera(dt) -- 1353
			return -- 1354
		else -- 1354
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1356
		end -- 1356
	end -- 1356
	self.ticks = self.ticks + 1 -- 1360
	if self.invulnT > 0 then -- 1360
		self.invulnT = self.invulnT - 1 -- 1364
	end -- 1364
	if self.isCampaign then -- 1364
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1364
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1367
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1368
	end -- 1368
	local p = self.player -- 1370
	self:stepPlayer(p, dt, input) -- 1371
	self:refreshCover(p, input) -- 1373
	if self.carryOn then -- 1373
		self:carryPose() -- 1375
	end -- 1375
	if self.isCampaign then -- 1375
		self:stepCampaign(dt, input) -- 1378
		if not self.carryOn then -- 1378
			self:stepCampaignPartner(dt) -- 1380
		end -- 1380
	end -- 1380
	if trial == nil or not self.run.finished then -- 1380
		self:stepEnemies(dt, input) -- 1388
	end -- 1388
	if trial ~= nil then -- 1388
		trial.hp = self.hp -- 1390
	end -- 1390
	if not self.isCampaign then -- 1390
		self:stepStory(dt, input) -- 1392
		self:stepEscort(dt, input) -- 1393
		self:stepVillage(dt, input) -- 1394
		self:stepChase(dt, input) -- 1395
		self:stepInteract(dt, input) -- 1396
	end -- 1396
	self:updateGate() -- 1398
	self:updateCamera(dt) -- 1399
	self:syncStory() -- 1401
end -- 1310
function Play.prototype.underLowArch(self, a) -- 1408
	local arch = self.room.arch -- 1409
	if arch.h <= 0 then -- 1409
		return false -- 1411
	end -- 1411
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1411
		return false -- 1414
	end -- 1414
	local top = arch.y + arch.h -- 1416
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1417
end -- 1408
function Play.prototype.coverAt(self, a) -- 1424
	local best = nil -- 1425
	local bestGap = 24 -- 1426
	local half = a.w / 2 -- 1427
	local i = 0 -- 1428
	do -- 1428
		i = 0 -- 1429
		while i < #self.boxes do -- 1429
			do -- 1429
				local b = self.boxes[i + 1] -- 1430
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1430
					goto __continue167 -- 1432
				end -- 1432
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1432
					goto __continue167 -- 1435
				end -- 1435
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1437
				if gap < bestGap then -- 1437
					bestGap = gap -- 1439
					best = b -- 1440
				end -- 1440
			end -- 1440
			::__continue167:: -- 1440
			i = i + 1 -- 1429
		end -- 1429
	end -- 1429
	return best -- 1443
end -- 1424
function Play.prototype.nearCover(self, a) -- 1446
	return self:coverAt(a) ~= nil -- 1447
end -- 1446
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1451
	if enemy == nil then -- 1451
		return false -- 1453
	end -- 1453
	local fromRight = enemy.x >= a.x -- 1455
	local edge = fromRight and b.x0 or b.x1 -- 1456
	local ____fromRight_34 -- 1457
	if fromRight then -- 1457
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1457
	else -- 1457
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1458
	end -- 1458
	local between = ____fromRight_34 -- 1457
	local separation = enemy.x - a.x -- 1459
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1460
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1461
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1462
end -- 1451
function Play.prototype.nearestEnemy(self, a) -- 1465
	local best -- 1466
	local bestD = 1000000000 -- 1467
	local i = 0 -- 1468
	do -- 1468
		i = 0 -- 1469
		while i < #self.enemies do -- 1469
			do -- 1469
				local e = self.enemies[i + 1] -- 1470
				if not e.alive then -- 1470
					goto __continue176 -- 1472
				end -- 1472
				local d = math.abs(e.x - a.x) -- 1474
				if d < bestD then -- 1474
					bestD = d -- 1476
					best = e -- 1477
				end -- 1477
			end -- 1477
			::__continue176:: -- 1477
			i = i + 1 -- 1469
		end -- 1469
	end -- 1469
	return best -- 1480
end -- 1465
function Play.prototype.refreshCover(self, a, input) -- 1484
	if self.childMode then -- 1484
		self.coverNear = false -- 1486
		self.coverHug = false -- 1487
		self.coverEntity = "" -- 1488
		self.coverBlocking = false -- 1489
		a.covered = false -- 1490
		return -- 1491
	end -- 1491
	local b = self:coverAt(a) -- 1493
	self.coverNear = b ~= nil -- 1494
	a.covered = self.coverNear and input.cover.held -- 1495
	self.coverHug = a.covered -- 1496
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1497
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1498
		b, -- 1498
		a, -- 1498
		self:nearestEnemy(a) -- 1498
	) -- 1498
end -- 1484
function Play.prototype.cartHandleInReach(self, a) -- 1502
	if a == nil then -- 1502
		a = self.player -- 1502
	end -- 1502
	local c = self.room.cart -- 1503
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1503
		return false -- 1505
	end -- 1505
	local handleX = self.cartAxle + c.handleOffset -- 1507
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1508
end -- 1502
function Play.prototype.nearLowLedge(self, a) -- 1513
	local reach = 26 -- 1514
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1515
	local x1 = x0 + reach -- 1516
	local i = 0 -- 1517
	do -- 1517
		i = 0 -- 1518
		while i < #self.boxes do -- 1518
			do -- 1518
				local b = self.boxes[i + 1] -- 1519
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1519
					goto __continue185 -- 1521
				end -- 1521
				local rise = b.y1 - a.y -- 1523
				if rise > 0 and rise <= LEDGE_RISE then -- 1523
					return true -- 1525
				end -- 1525
			end -- 1525
			::__continue185:: -- 1525
			i = i + 1 -- 1518
		end -- 1518
	end -- 1518
	return false -- 1528
end -- 1513
function Play.prototype.stepPlayer(self, a, dt, input) -- 1531
	a.depthSpeed = 0 -- 1532
	if not a.alive then -- 1532
		return -- 1534
	end -- 1534
	local isChild = self.childMode -- 1536
	local lowArch = isChild and self:underLowArch(a) -- 1538
	if self:storyLocked() then -- 1538
		a.vx = 0 -- 1541
		a.crouch = isChild and lowArch -- 1542
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1543
		self:fallY(a, dt) -- 1544
		return -- 1545
	end -- 1545
	if not isChild and self.escort.state == "calming" then -- 1545
		a.crouch = false -- 1549
		a.h = SOLDIER_H -- 1550
		a.vx = 0 -- 1551
		self:fallY(a, dt) -- 1552
		return -- 1553
	end -- 1553
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1555
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1556
	local nearCover = not isChild and self:nearCover(a) -- 1557
	a.covered = nearCover and input.cover.held -- 1558
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1560
	if a.rollT > 0 then -- 1560
		a.rollT = a.rollT - dt -- 1564
		a.vx = a.facing * ROLL_SPEED -- 1565
		self:slideX(a, a.vx * dt) -- 1566
		self:fallY(a, dt) -- 1567
		if a.rollT <= 0 then -- 1567
			self:flashSet("翻滚结束", 0.5) -- 1569
		end -- 1569
		return -- 1571
	end -- 1571
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1571
		if input.moveX ~= 0 then -- 1571
			a.facing = input.moveX > 0 and 1 or -1 -- 1576
		end -- 1576
		if self:nearLowLedge(a) then -- 1576
			a.vy = SOLDIER_JUMP -- 1580
			a.onGround = false -- 1581
			self:flashSet("翻上去", 0.3) -- 1582
			return -- 1583
		end -- 1583
		a.rollT = ROLL_TIME -- 1585
		self:flashSet("翻滚", 0.3) -- 1586
		return -- 1587
	end -- 1587
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1590
	if isChild then -- 1590
		if input.cover.held then -- 1590
			speed = CHILD_SLOW -- 1593
		end -- 1593
		if a.crouch then -- 1593
			speed = CHILD_SLOW -- 1596
		end -- 1596
	elseif a.covered then -- 1596
		speed = SOLDIER_SPEED * 0.45 -- 1599
	end -- 1599
	local handsBusy = self.gripping or gripIntent -- 1603
	local dir = self.gripping and 0 or input.moveX -- 1604
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1605
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1606
	if dir ~= 0 then -- 1606
		a.facing = dir > 0 and 1 or -1 -- 1608
	end -- 1608
	a.vx = dir * speed * diagonal -- 1610
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1610
		a.vy = CHILD_JUMP -- 1614
		a.onGround = false -- 1615
		self:flashSet("跳", 0.25) -- 1616
	end -- 1616
	local previousDepth = a.depth -- 1620
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1621
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1622
	self:slideX(a, a.vx * dt) -- 1623
	self:fallY(a, dt) -- 1624
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1624
		self:shoot(a) -- 1628
	end -- 1628
end -- 1531
function Play.prototype.stepPartner(self, p, dt) -- 1633
	local a = self.partner -- 1634
	if not a.alive then -- 1634
		return -- 1636
	end -- 1636
	a.crouch = false -- 1638
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1639
	a.vx = 0 -- 1640
	a.depthSpeed = 0 -- 1641
	self:fallY(a, dt) -- 1642
end -- 1633
function Play.prototype.stepEscort(self, dt, input) -- 1649
	local a = self.partner -- 1650
	a.depthSpeed = 0 -- 1651
	if not a.alive then -- 1651
		return -- 1653
	end -- 1653
	if self.room.key == "gatepath" then -- 1653
		if self.carryOn then -- 1653
			return -- 1658
		end -- 1658
		local p = self.player -- 1661
		a.depth = p.depth -- 1662
		a.facing = p.facing -- 1663
		a.crouch = false -- 1664
		a.h = CHILD_H -- 1665
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1666
		a.y = p.y -- 1667
		a.vy = 0 -- 1668
		a.vx = p.vx -- 1669
		a.onGround = p.onGround -- 1670
		return -- 1671
	end -- 1671
	if not self:escortOn() then -- 1671
		a.vx = 0 -- 1674
		self:fallY(a, dt) -- 1675
		return -- 1676
	end -- 1676
	local p = self.player -- 1678
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1679
	local hadKnock1 = self.escort.knock1 -- 1680
	local hadKnock2 = self.escort.knock2 -- 1681
	self.calmConsumed = self.escort:update( -- 1682
		input, -- 1682
		p.x, -- 1682
		p.facing, -- 1682
		a.x, -- 1682
		dist -- 1682
	) -- 1682
	if not hadKnock1 and self.escort.knock1 then -- 1682
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1685
	end -- 1685
	if not hadKnock2 and self.escort.knock2 then -- 1685
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1688
	end -- 1688
	a.crouch = self.escort.crouchPose -- 1690
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1691
	if not self.escort.stopped then -- 1691
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1693
		local previousDepth = a.depth -- 1694
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1695
		local distance = math.max( -- 1696
			-travel, -- 1696
			math.min(travel, targetDepth - previousDepth) -- 1696
		) -- 1696
		self:slideDepth(a, distance) -- 1697
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1698
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1698
			a.vy = CHILD_JUMP -- 1700
			a.onGround = false -- 1701
		end -- 1701
	end -- 1701
	local dir = self.escort:moveDir(a.x) -- 1704
	a.vx = dir * CHILD_SPEED -- 1705
	if dir ~= 0 then -- 1705
		a.facing = dir -- 1707
		local before = a.x -- 1708
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1709
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1709
			a.vy = CHILD_JUMP -- 1712
			a.onGround = false -- 1713
		end -- 1713
	end -- 1713
	self:fallY(a, dt) -- 1716
end -- 1649
function Play.prototype.escortOn(self) -- 1720
	if self.room.key == "checkpoint" then -- 1720
		return true -- 1722
	end -- 1722
	if self.room.key == "gatepath" then -- 1722
		return true -- 1725
	end -- 1725
	if self.room.key == "prologue" then -- 1725
		return self.phase == "prologue-follow" -- 1728
	end -- 1728
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1728
		return true -- 1732
	end -- 1732
	return self.room.key == "street" -- 1734
end -- 1720
function Play.prototype.storyLocked(self) -- 1738
	if self.caughtT > 0 then -- 1738
		return true -- 1740
	end -- 1740
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1740
		return true -- 1743
	end -- 1743
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1743
		return true -- 1746
	end -- 1746
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1746
		return true -- 1749
	end -- 1749
	if self.craftBench.active then -- 1749
		return true -- 1753
	end -- 1753
	return false -- 1755
end -- 1738
function Play.prototype.swapToChild(self, x) -- 1759
	local tmp = self.player -- 1760
	self.player = self.partner -- 1761
	self.partner = tmp -- 1762
	self.childMode = true -- 1763
	self.player.alive = true -- 1764
	self.player.x = self.ox + x -- 1765
	self.player.y = 0 -- 1766
	self.player.depth = 0 -- 1767
	self.player.depthSpeed = 0 -- 1768
	self.player.vy = 0 -- 1769
	self.player.vx = 0 -- 1770
	self.player.onGround = true -- 1771
	self.player.crouch = false -- 1772
	self.player.h = CHILD_H -- 1773
	self.player.facing = 1 -- 1774
	self.partner.alive = true -- 1775
	self.cam.x = self.player.x -- 1776
end -- 1759
function Play.prototype.stepStory(self, dt, input) -- 1780
	if self.room.key == "prologue" then -- 1780
		self:stepPrologue(dt, input) -- 1782
	elseif self.room.key == "street" then -- 1782
		self:stepStreet(dt, input) -- 1784
	elseif self.room.key == "gate" then -- 1784
		self:stepGate(dt, input) -- 1786
	elseif self.room.key == "gatepath" then -- 1786
		self:stepGatePath() -- 1788
	elseif self.room.key == "tower" then -- 1788
		self:stepTower(dt, input) -- 1790
	end -- 1790
end -- 1780
function Play.prototype.stepPrologue(self, dt, input) -- 1795
	local child = self.partner -- 1796
	if self.phase == "prologue-wait" then -- 1796
		child.crouch = true -- 1798
		child.h = CHILD_CROUCH_H -- 1799
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1800
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1802
		if near and input.interact.pressed then -- 1802
			self.phase = "prologue-give" -- 1804
			self.phaseTick = 0 -- 1805
			self:flashSet("递出针套", 1) -- 1806
		end -- 1806
		return -- 1808
	end -- 1808
	if self.phase == "prologue-give" then -- 1808
		self.phaseTick = self.phaseTick + 1 -- 1811
		if self.phaseTick == 12 then -- 1811
			self:flashSet("针套递过去", 0.7) -- 1813
		elseif self.phaseTick == 36 then -- 1813
			self:flashSet("纸条塞进针套", 0.9) -- 1815
		elseif self.phaseTick >= 60 then -- 1815
			self.phase = "prologue-follow" -- 1817
			self.phaseTick = 0 -- 1818
			child.crouch = false -- 1819
			child.h = CHILD_H -- 1820
			self:flashSet("她跟上了", 1.2) -- 1821
		end -- 1821
		return -- 1823
	end -- 1823
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1823
		self:requestRoom("street", "序章跟到门口") -- 1827
		self:flashSet("进街道", 1.2) -- 1828
	end -- 1828
end -- 1795
function Play.prototype.stepStreet(self, dt, input) -- 1833
	local p = self.player -- 1834
	local c = self.partner -- 1835
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1835
		self:requestRoom("checkpoint", "两人都到街尾") -- 1837
		self:flashSet("到检查站", 1.2) -- 1838
	end -- 1838
end -- 1833
function Play.prototype.stepGate(self, dt, input) -- 1843
	local ____temp_35 -- 1844
	if self.room.story == nil then -- 1844
		____temp_35 = nil -- 1844
	else -- 1844
		____temp_35 = self.room.story.gate -- 1844
	end -- 1844
	local g = ____temp_35 -- 1844
	if g == nil then -- 1844
		return -- 1846
	end -- 1846
	local p = self.player -- 1848
	if self.phase == "gate-idle" then -- 1848
		local a = self.partner -- 1851
		local gap = g.waitX - a.x -- 1852
		if math.abs(gap) > 3 then -- 1852
			a.facing = gap > 0 and 1 or -1 -- 1854
			a.vx = a.facing * CHILD_SPEED -- 1855
			local beforeX = a.x -- 1856
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1857
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1857
				a.vy = CHILD_JUMP -- 1859
				a.onGround = false -- 1860
			end -- 1860
			self:fallY(a, dt) -- 1862
		else -- 1862
			a.vx = 0 -- 1864
			a.x = g.waitX -- 1865
		end -- 1865
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1868
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1869
		if self.gateNeedConfirm then -- 1869
			if not input.interact.held then -- 1869
				self.gateRestartArmed = true -- 1874
			end -- 1874
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1874
				self.gateNeedConfirm = false -- 1877
				self.gateRestartArmed = true -- 1878
				self.phase = "gate-hold" -- 1879
				self.gateTick = 0 -- 1880
				self.gateSpawned = 0 -- 1881
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1882
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1883
			end -- 1883
			return -- 1885
		end -- 1885
		if atWinch and atWait then -- 1885
			self.phase = "gate-hold" -- 1888
			self.gateTick = 0 -- 1889
			self.gateSpawned = 0 -- 1890
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1891
		end -- 1891
		return -- 1893
	end -- 1893
	if self.phase == "gate-hold" then -- 1893
		self.gateTick = self.gateTick + 1 -- 1896
		local marks = {0, 540, 900, 1500} -- 1898
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1898
			local idx = self.gateSpawned -- 1900
			local ____self_enemies_36 = self.enemies -- 1900
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 1901
				x = self.ox + 620 + idx * 62, -- 1902
				y = 0, -- 1902
				w = 26, -- 1902
				h = 84, -- 1902
				alive = true, -- 1903
				hitT = 0, -- 1903
				warnT = 0, -- 1903
				fireCd = 90 + idx * 45 -- 1903
			} -- 1903
			self.gateSpawned = self.gateSpawned + 1 -- 1905
			self:flashSet( -- 1906
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1906
				0.9 -- 1906
			) -- 1906
		end -- 1906
		if self.gateTick == 900 then -- 1906
			self:flashSet("灯灭了", 1) -- 1909
		elseif self.gateTick == 2100 then -- 1909
			self:flashSet("门底压下来了", 1) -- 1911
		end -- 1911
		if self.gateTick >= g.holdTicks then -- 1911
			self:captureGateBlood() -- 1916
			self.phase = "gate-send" -- 1917
			self.phaseTick = 0 -- 1918
			self.enemies = {} -- 1920
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1921
		end -- 1921
		return -- 1923
	end -- 1923
	if self.phase == "gate-send" then -- 1923
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1926
		if near and input.interact.pressed then -- 1926
			self:commitRoute() -- 1929
			self:swapToChild(g.doorX + 30) -- 1930
			self.phase = "gate-count" -- 1931
			self.countTick = 0 -- 1932
			self.countArmed = false -- 1934
			self.countPrevMove = input.moveX -- 1935
			self:flashSet("门开了 · 送她出去", 1.8) -- 1936
		end -- 1936
		return -- 1938
	end -- 1938
	if self.phase == "gate-count" then -- 1938
		self.countTick = self.countTick + 1 -- 1941
		if self.countTick == 360 then -- 1941
			self:flashSet("门关上", 0.9) -- 1943
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 1943
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 1945
			if self.storyRoute == "soldier" then -- 1945
				self.phase = "gate-wait" -- 1951
				self.phaseTick = 0 -- 1952
				self.knocks = 1 -- 1953
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 1954
				self.handArmed = not input.interact.held -- 1956
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 1957
			else -- 1957
				self:flashSet("数到二十", 2.2) -- 1959
			end -- 1959
		end -- 1959
		local prevMove = self.countPrevMove -- 1964
		self.countPrevMove = input.moveX -- 1965
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 1965
			if prevMove <= 0 and input.moveX > 0 then -- 1965
				self.countArmed = true -- 1968
			end -- 1968
			if self.countArmed and input.moveX > 0 then -- 1968
				self.phase = "gate-walk" -- 1971
				self.phaseTick = 0 -- 1972
				self:flashSet("她迈出第一步", 1.4) -- 1973
				self:emit("storyExit", { -- 1974
					route = "child", -- 1974
					via = "walk", -- 1974
					countTick = self.countTick, -- 1974
					hp = self.hp, -- 1974
					maxHp = self.maxHp -- 1974
				}) -- 1974
			end -- 1974
		end -- 1974
		return -- 1977
	end -- 1977
	if self.phase == "gate-wait" then -- 1977
		self.phaseTick = self.phaseTick + 1 -- 1981
		if self.phaseTick == 12 then -- 1981
			self.knocks = 2 -- 1983
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 1984
			self:flashSet("第二下 · 她抬手了", 1.6) -- 1985
		end -- 1985
		if not input.interact.held then -- 1985
			if self.handTicks > 0 then -- 1985
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1989
			end -- 1989
			self.handTicks = 0 -- 1991
			self.handArmed = true -- 1992
			return -- 1993
		end -- 1993
		if self.handArmed then -- 1993
			self.handTicks = self.handTicks + 1 -- 1996
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 1996
				self.phase = "gate-hand" -- 1998
				self.phaseTick = 0 -- 1999
				self.handDone = true -- 2000
				self.tied = true -- 2001
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2002
				if not self.lineSaid then -- 2002
					self.lineSaid = true -- 2004
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2005
				end -- 2005
				self:flashSet("我们走吧。", 3) -- 2007
			end -- 2007
		end -- 2007
		return -- 2010
	end -- 2010
	if self.phase == "gate-hand" then -- 2010
		self.phaseTick = self.phaseTick + 1 -- 2014
		if self.phaseTick == 30 then -- 2014
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2016
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2016
			self:emit("storyExit", { -- 2018
				route = "soldier", -- 2018
				via = "hand", -- 2018
				handTicks = self.handTicks, -- 2018
				hp = self.hp, -- 2018
				maxHp = self.maxHp -- 2018
			}) -- 2018
			self:requestRoom("gatepath", "牵手同行") -- 2019
		end -- 2019
		return -- 2021
	end -- 2021
	if self.phase == "gate-walk" then -- 2021
		if self.player.x >= g.exitX then -- 2021
			self:requestRoom("outside", "走出城门") -- 2026
			self:flashSet("出城门 · 城外", 1.4) -- 2027
		end -- 2027
	end -- 2027
end -- 1843
function Play.prototype.captureGateBlood(self) -- 2036
	self.hpAtGate = self.hp -- 2037
	self.maxHpAtGate = self.maxHp -- 2038
end -- 2036
function Play.prototype.commitRoute(self) -- 2045
	if self.storySettled then -- 2045
		return -- 2047
	end -- 2047
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2049
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2050
	self.hpAtGate = hp -- 2051
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2052
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2053
	self.storySettled = true -- 2054
	self:emit("storyRouteLocked", { -- 2055
		route = self.storyRoute, -- 2056
		hp = self.hp, -- 2056
		maxHp = self.maxHp, -- 2056
		hpAtGate = self.hpAtGate, -- 2057
		maxHpAtGate = self.maxHpAtGate -- 2057
	}) -- 2057
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2059
end -- 2045
function Play.prototype.syncStory(self) -- 2063
	if self.isCampaign and self.run.trial ~= nil then -- 2063
		return -- 2065
	end -- 2065
	local s = self.run.story -- 2067
	if s == nil then -- 2067
		return -- 2069
	end -- 2069
	s.hp = self.hp -- 2071
	s.maxHp = self.maxHp -- 2072
	s.route = self.storyRoute -- 2073
	s.settled = self.storySettled -- 2074
	s.hpAtGate = self.hpAtGate -- 2075
	s.maxHpAtGate = self.maxHpAtGate -- 2076
	s.handDone = self.handDone -- 2077
	s.lineSaid = self.lineSaid -- 2078
	s.tied = self.tied -- 2079
	s.carry = self.carryOn -- 2080
	s.escortDone = self.escortDone -- 2081
	s.craftedWeapon = self.run.story.craftedWeapon -- 2082
	s.ending = self.run.story.ending -- 2083
	if self.room.key == "gate" then -- 2083
		s.phase = self.phase -- 2085
		s.countTick = self.countTick -- 2086
		s.phaseTick = self.phaseTick -- 2087
		s.handTicks = self.handTicks -- 2088
	end -- 2088
end -- 2063
function Play.prototype.stepGatePath(self) -- 2093
	local ____temp_37 -- 2094
	if self.room.story == nil then -- 2094
		____temp_37 = nil -- 2094
	else -- 2094
		____temp_37 = self.room.story.gatepath -- 2094
	end -- 2094
	local gp = ____temp_37 -- 2094
	if self.phase == "gatepath-start" then -- 2094
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2094
			self.carryOn = true -- 2097
			self.phase = "gatepath-carry" -- 2098
			self.phaseTick = 0 -- 2099
			self.pathDone = true -- 2100
			self.escortDone = false -- 2101
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2102
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2103
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2104
		end -- 2104
		return -- 2106
	end -- 2106
	if self.phase == "gatepath-carry" then -- 2106
		self.phaseTick = self.phaseTick + 1 -- 2109
		if self.phaseTick == 20 then -- 2109
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2111
		end -- 2111
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2111
			self:requestRoom(gp.next, "背负进首战") -- 2114
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2115
		end -- 2115
	end -- 2115
end -- 2093
function Play.prototype.carryPose(self) -- 2124
	local p = self.player -- 2125
	local a = self.partner -- 2126
	a.alive = true -- 2127
	a.x = p.x - p.facing * 12 -- 2128
	a.y = p.y + 26 -- 2129
	a.depth = p.depth -- 2130
	a.vx = p.vx -- 2131
	a.vy = 0 -- 2132
	a.onGround = true -- 2133
	a.crouch = false -- 2134
	a.h = CHILD_CROUCH_H -- 2135
	a.facing = p.facing -- 2136
end -- 2124
function Play.prototype.stepTower(self, dt, input) -- 2140
	local ____temp_38 -- 2141
	if self.room.story == nil then -- 2141
		____temp_38 = nil -- 2141
	else -- 2141
		____temp_38 = self.room.story.tower -- 2141
	end -- 2141
	local t = ____temp_38 -- 2141
	if t == nil then -- 2141
		return -- 2143
	end -- 2143
	if self.phase == "tower-wait" then -- 2143
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2146
		if near and input.interact.pressed then -- 2146
			self.phase = "tower-knock" -- 2148
			self.phaseTick = 0 -- 2149
			self.knocks = 1 -- 2150
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2151
			self:flashSet("敲一下", 0.6) -- 2152
		end -- 2152
		return -- 2154
	end -- 2154
	if self.phase == "tower-knock" then -- 2154
		self.phaseTick = self.phaseTick + 1 -- 2157
		if self.phaseTick == 12 then -- 2157
			self.knocks = 2 -- 2159
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2160
			self:flashSet("敲两下 · 第二声", 1) -- 2161
		elseif self.phaseTick >= t.knockTicks then -- 2161
			self.phase = "tower-given" -- 2163
			self.phaseTick = 0 -- 2164
			self:flashSet("门开了 · 提灯", 1.4) -- 2165
		end -- 2165
		return -- 2167
	end -- 2167
	if self.phase == "tower-given" then -- 2167
		local soldier = self.storyRoute == "soldier" -- 2172
		self.phaseTick = self.phaseTick + 1 -- 2173
		if self.phaseTick == 60 then -- 2173
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2175
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2176
		elseif self.phaseTick == 120 then -- 2176
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2178
		elseif self.phaseTick >= 180 then -- 2178
			self.phase = "tower-end" -- 2180
			self.phaseTick = 0 -- 2181
			if not self.run.finished then -- 2181
				self.run.finished = true -- 2183
				local ending = soldier and "reunion" or "lamp" -- 2184
				self.run.story.ending = ending -- 2185
				local ____soldier_39 -- 2188
				if soldier then -- 2188
					____soldier_39 = self.run.story.segments.escort5 == true -- 2189
				else -- 2189
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2190
				end -- 2190
				local played = ____soldier_39 -- 2188
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2191
				if official then -- 2191
					if soldier then -- 2191
						self.run.archive.soldierCleared = true -- 2195
					else -- 2195
						self.run.archive.childCleared = true -- 2197
					end -- 2197
				end -- 2197
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2200
				self:emit("endingReached", { -- 2201
					route = soldier and "soldier" or "child", -- 2202
					ending = ending, -- 2203
					official = official, -- 2204
					source = self.run.source, -- 2205
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2206
					childCleared = self.run.archive.childCleared, -- 2207
					soldierCleared = self.run.archive.soldierCleared, -- 2208
					artifactOwned = self.run.archive.artifactOwned, -- 2209
					equipped = self.equippedWeapon -- 2210
				}) -- 2210
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2212
			end -- 2212
		end -- 2212
		return -- 2215
	end -- 2215
	if input.interact.pressed or input.retry.pressed then -- 2215
		self:requestRoom("prologue", "片尾再玩") -- 2218
		self:flashSet("回到序章", 1.4) -- 2219
	end -- 2219
end -- 2140
function Play.prototype.stepChase(self, dt, input) -- 2224
	if self.caughtT > 0 then -- 2224
		self.caughtT = self.caughtT - dt -- 2226
		if self.caughtT <= 0 then -- 2226
			self:recoverFromCaught() -- 2228
		end -- 2228
		return -- 2230
	end -- 2230
	if self.room.key == "village" then -- 2230
		self:stepScavChase() -- 2233
	elseif self.room.key == "forest" then -- 2233
		self:stepDog(dt) -- 2235
		if self.player.x >= self.ox + 1450 then -- 2235
			self:requestRoom("tower", "到林缘北塔") -- 2238
			self:flashSet("林缘 · 北塔", 1.4) -- 2239
		end -- 2239
	end -- 2239
end -- 2224
function Play.prototype.stepScavChase(self) -- 2245
	local s = self.room.scavenger -- 2246
	if s == nil then -- 2246
		return -- 2248
	end -- 2248
	local p = self.player -- 2250
	if self.passed and p.x > self.ox + 440 then -- 2250
		if self.scavChase then -- 2250
			self.scavChase = false -- 2254
			self.scavState = "back" -- 2255
			self.scavT = 0 -- 2256
		end -- 2256
		return -- 2258
	end -- 2258
	local dx = p.x - self.scavX -- 2260
	local dist = math.abs(dx) -- 2261
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2262
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2263
	if not self.scavChase then -- 2263
		if visible then -- 2263
			self.scavSee = self.scavSee + 1 -- 2266
			if self.scavSee >= 24 then -- 2266
				self.scavChase = true -- 2268
				self.scavState = "chase" -- 2269
				self.scavTargetX = p.x -- 2270
				self:flashSet("他看见你了", 1.2) -- 2271
			end -- 2271
		else -- 2271
			self.scavSee = 0 -- 2274
		end -- 2274
		return -- 2276
	end -- 2276
	local dir = p.x > self.scavX and 1 or -1 -- 2279
	self.scavX = self.scavX + dir * 96 / 60 -- 2280
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2280
		self:caught() -- 2282
		return -- 2283
	end -- 2283
	if hidden then -- 2283
		self.scavSee = 0 -- 2287
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2288
		self.scavT = self.scavT - 1 -- 2289
		if self.scavT <= 0 then -- 2289
			self.scavChase = false -- 2291
			self.scavState = "patrol" -- 2292
			self:flashSet("他失去了目标", 1) -- 2293
		end -- 2293
	end -- 2293
end -- 2245
function Play.prototype.stepDog(self, dt) -- 2299
	local ____temp_40 -- 2300
	if self.room.story == nil then -- 2300
		____temp_40 = nil -- 2300
	else -- 2300
		____temp_40 = self.room.story.dog -- 2300
	end -- 2300
	local dog = ____temp_40 -- 2300
	if dog == nil then -- 2300
		return -- 2302
	end -- 2302
	local p = self.player -- 2304
	local dist = math.abs(p.x - self.dogX) -- 2305
	if self.dogState == "patrol" then -- 2305
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2307
		if self.dogX < dog.x0 then -- 2307
			self.dogX = dog.x0 -- 2309
			self.dogDir = 1 -- 2310
		elseif self.dogX > dog.x1 then -- 2310
			self.dogX = dog.x1 -- 2312
			self.dogDir = -1 -- 2313
		end -- 2313
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2315
		if not p.crouch and moving and dist < dog.range then -- 2315
			self.dogState = "ear" -- 2317
			self.dogT = 18 -- 2318
			self.dogTargetX = p.x -- 2319
			self:flashSet("狗转耳朵", 0.8) -- 2320
		end -- 2320
		return -- 2322
	end -- 2322
	if self.dogState == "ear" then -- 2322
		self.dogT = self.dogT - 1 -- 2325
		if self.dogT <= 0 then -- 2325
			self.dogState = "chase" -- 2327
			self.dogTargetX = p.x -- 2328
			self:flashSet("狗追来了", 1.4) -- 2329
		end -- 2329
		return -- 2331
	end -- 2331
	if self.dogState == "chase" then -- 2331
		local dir = p.x > self.dogX and 1 or -1 -- 2334
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2335
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2335
			self:caught() -- 2337
			self.dogState = "sniff" -- 2338
			self.dogT = 60 -- 2339
		elseif dist > dog.range * 1.5 or p.crouch then -- 2339
			self.dogState = "sniff" -- 2341
			self.dogT = 60 -- 2342
			self:flashSet("狗停下了", 0.9) -- 2343
		end -- 2343
		return -- 2345
	end -- 2345
	if self.dogState == "sniff" then -- 2345
		self.dogT = self.dogT - 1 -- 2348
		if self.dogT <= 0 then -- 2348
			self.dogState = "back" -- 2350
		end -- 2350
		return -- 2352
	end -- 2352
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2355
	self.dogX = self.dogX + dir * dog.speed * dt -- 2356
	if math.abs(self.dogX - dog.x0) < 2 then -- 2356
		self.dogX = dog.x0 -- 2358
		self.dogState = "patrol" -- 2359
	end -- 2359
end -- 2299
function Play.prototype.caught(self) -- 2363
	self.caughtT = 1 -- 2364
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2365
end -- 2363
function Play.prototype.recoverFromCaught(self) -- 2369
	local p = self.player -- 2370
	p.x = self.ox + 140 -- 2371
	p.y = 0 -- 2372
	p.vy = 0 -- 2373
	p.vx = 0 -- 2374
	p.onGround = true -- 2375
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2375
		self.scavX = self.room.scavenger.x0 -- 2377
		self.scavState = "patrol" -- 2378
		self.scavSee = 0 -- 2379
		self.scavChase = false -- 2380
		self.scavT = 0 -- 2381
	end -- 2381
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2381
		self.dogX = self.room.story.dog.x0 -- 2384
		self.dogState = "patrol" -- 2385
		self.dogT = 0 -- 2386
	end -- 2386
	self.cam.x = p.x -- 2388
	self.cam.y = p.y + CAM_LOOK_UP -- 2389
	self:flashSet("回到安全点", 1.2) -- 2390
end -- 2369
function Play.prototype.updateGate(self) -- 2394
	if self.room.key ~= "checkpoint" then -- 2394
		self.gateOpen = false -- 2396
		return -- 2397
	end -- 2397
	local function inZone(x) -- 2399
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2399
	end -- 2399
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2400
end -- 2394
function Play.prototype.addItem(self, kind) -- 2406
	local inv = self.run.inventory -- 2407
	if kind == "shield" then -- 2407
		if inv.shield >= TOOL_CAP then -- 2407
			return false -- 2410
		end -- 2410
		inv.shield = inv.shield + 1 -- 2412
		return true -- 2413
	end -- 2413
	if kind == "wedge" then -- 2413
		if inv.wedge >= CONSUMABLE_CAP then -- 2413
			return false -- 2417
		end -- 2417
		inv.wedge = inv.wedge + 1 -- 2419
		return true -- 2420
	end -- 2420
	if kind == "ammo" then -- 2420
		if inv.ammo >= CONSUMABLE_CAP then -- 2420
			return false -- 2424
		end -- 2424
		inv.ammo = inv.ammo + 1 -- 2426
		return true -- 2427
	end -- 2427
	if kind == "scrap" then -- 2427
		inv.scrap = inv.scrap + 1 -- 2431
		return true -- 2432
	end -- 2432
	if kind == "wood" then -- 2432
		inv.wood = inv.wood + 1 -- 2435
		return true -- 2436
	end -- 2436
	if kind == "bell" then -- 2436
		inv.bell = inv.bell + 1 -- 2439
		return true -- 2440
	end -- 2440
	if kind == "pass" then -- 2440
		inv.pass = inv.pass + 1 -- 2443
		return true -- 2444
	end -- 2444
	if kind == "quickbelt" then -- 2444
		inv.quickbelt = inv.quickbelt + 1 -- 2447
		return true -- 2448
	end -- 2448
	return false -- 2450
end -- 2406
function Play.prototype.findBox(self, id) -- 2453
	local i = 0 -- 2454
	do -- 2454
		i = 0 -- 2455
		while i < #self.boxes do -- 2455
			if self.boxes[i + 1].id == id then -- 2455
				return self.boxes[i + 1] -- 2457
			end -- 2457
			i = i + 1 -- 2455
		end -- 2455
	end -- 2455
	return nil -- 2460
end -- 2453
function Play.prototype.findWedgeTarget(self) -- 2464
	local best = nil -- 2465
	local bestD = 0 -- 2466
	local i = 0 -- 2467
	do -- 2467
		i = 0 -- 2468
		while i < #self.boxes do -- 2468
			do -- 2468
				local b = self.boxes[i + 1] -- 2469
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2469
					goto __continue368 -- 2471
				end -- 2471
				if not self:nearBox(b, 26) then -- 2471
					goto __continue368 -- 2474
				end -- 2474
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2476
				if best == nil or d < bestD then -- 2476
					best = b -- 2478
					bestD = d -- 2479
				end -- 2479
			end -- 2479
			::__continue368:: -- 2479
			i = i + 1 -- 2468
		end -- 2468
	end -- 2468
	return best -- 2482
end -- 2464
function Play.prototype.stepCraft(self, input) -- 2490
	local inv = self.run.inventory -- 2491
	local ____opt_41 = self.run.trial -- 2491
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2492
	if self.craftT > 0 then -- 2492
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2492
			self.craftT = 0 -- 2496
			self:flashSet("制作中断", 0.8) -- 2497
			return true -- 2498
		end -- 2498
		self.craftT = self.craftT + 1 -- 2500
		if self.craftT >= required then -- 2500
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2500
				inv.scrap = inv.scrap - 1 -- 2503
				inv.wedge = inv.wedge + 1 -- 2504
				self:flashSet("制得木楔", 1.2) -- 2505
				self:log("制木楔") -- 2506
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2507
			end -- 2507
			self.craftT = 0 -- 2509
		end -- 2509
		return true -- 2511
	end -- 2511
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2511
		self.craftT = 1 -- 2514
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2515
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2516
		return true -- 2517
	end -- 2517
	return false -- 2519
end -- 2490
function Play.prototype.nearBox(self, b, reach) -- 2522
	local p = self.player -- 2523
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2524
end -- 2522
function Play.prototype.findInteract(self) -- 2530
	local p = self.player -- 2531
	local best = nil -- 2532
	local bestD = 1000000000 -- 2533
	local i = 0 -- 2534
	do -- 2534
		i = 0 -- 2535
		while i < #self.boxes do -- 2535
			do -- 2535
				local b = self.boxes[i + 1] -- 2536
				if b.interact == nil or b.broken == true then -- 2536
					goto __continue381 -- 2538
				end -- 2538
				if not self:nearBox(b, b.interact.reach or 27) then -- 2538
					goto __continue381 -- 2541
				end -- 2541
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2543
				if d < bestD then -- 2543
					bestD = d -- 2545
					best = b -- 2546
				end -- 2546
			end -- 2546
			::__continue381:: -- 2546
			i = i + 1 -- 2535
		end -- 2535
	end -- 2535
	return best -- 2549
end -- 2530
function Play.prototype.stepCampaign(self, dt, input) -- 2553
	local wr = self.room -- 2554
	local p = self.player -- 2555
	if self.reloadT > 0 then -- 2555
		self.reloadT = self.reloadT - 1 -- 2557
	end -- 2557
	if self.bracedShield ~= nil then -- 2557
		self.bracedShield.x = p.x + p.facing * 26 -- 2561
		self.bracedShield.y = p.y -- 2562
		local shBox = __TS__ArrayFind( -- 2563
			self.boxes, -- 2563
			function(____, b) return b.id == "braced_shield" end -- 2563
		) -- 2563
		if shBox ~= nil then -- 2563
			shBox.x0 = self.bracedShield.x - 15 -- 2565
			shBox.x1 = self.bracedShield.x + 15 -- 2566
			shBox.y0 = self.bracedShield.y -- 2567
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2568
		end -- 2568
	end -- 2568
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2568
		self.run.route = "drygoods" -- 2574
		self.run.joined = false -- 2575
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2576
		self:log("转布行线") -- 2577
	end -- 2577
	if wr.key == "escort3" then -- 2577
		local benchX = wr.minX + 560 -- 2581
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2582
		if self.craftBench.active then -- 2582
			if input.interact.pressed or input.pause.pressed then -- 2582
				self:closeCraftBench() -- 2585
			end -- 2585
		elseif nearBench and input.interact.pressed then -- 2585
			self:openCraftBench() -- 2588
		end -- 2588
	end -- 2588
	local i = 0 -- 2592
	do -- 2592
		i = 0 -- 2593
		while i < #self.pickups do -- 2593
			do -- 2593
				local pk = self.pickups[i + 1] -- 2594
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2594
					goto __continue396 -- 2596
				end -- 2596
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2598
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2599
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2599
					if not self:addItem(pk.kind) then -- 2599
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2603
						self:log("满包拒绝 " .. pk.kind) -- 2604
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2605
						goto __continue396 -- 2606
					end -- 2606
					self.run.taken[pk.id] = true -- 2608
					pk.id = "" -- 2609
					self:flashSet("拾取 " .. pk.label, 1) -- 2610
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2611
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2612
				end -- 2612
			end -- 2612
			::__continue396:: -- 2612
			i = i + 1 -- 2593
		end -- 2593
	end -- 2593
	if not self:stepCraft(input) and input.interact.pressed then -- 2593
		self:campaignInteract() -- 2616
	end -- 2616
	self:stepCampaignCart(dt, input) -- 2618
	self:stepCampaignGoal() -- 2619
	self:campaignCheckpoint() -- 2620
end -- 2553
function Play.prototype.campaignCheckpoint(self) -- 2624
	local i = 0 -- 2625
	do -- 2625
		i = 0 -- 2626
		while i < #self.room.marks do -- 2626
			do -- 2626
				local m = self.room.marks[i + 1] -- 2627
				if m.kind ~= 0 then -- 2627
					goto __continue403 -- 2629
				end -- 2629
				local dx = self.player.x - m.x -- 2631
				local dy = self.player.y - m.y -- 2632
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2632
					self.checkpoint = m.x -- 2634
					self:captureCheckpoint(m.x) -- 2635
					self:flashSet("检查点", 1) -- 2636
				end -- 2636
			end -- 2636
			::__continue403:: -- 2636
			i = i + 1 -- 2626
		end -- 2626
	end -- 2626
end -- 2624
function Play.prototype.campaignInteract(self) -- 2642
	local b = self:findInteract() -- 2643
	if b ~= nil then -- 2643
		self:useInteract(b) -- 2645
		return -- 2646
	end -- 2646
	local inv = self.run.inventory -- 2648
	if inv.wedge > 0 then -- 2648
		local w = self:findWedgeTarget() -- 2650
		if w ~= nil then -- 2650
			if w.breakable ~= nil then -- 2650
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 2650
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 2653
			end -- 2653
			inv.wedge = inv.wedge - 1 -- 2655
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2656
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2658
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2659
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2660
			return -- 2661
		end -- 2661
	end -- 2661
	if inv.ammo > 0 and self.reloadT > 0 then -- 2661
		self.reloadT = 0 -- 2666
		self:closeReloadPuzzle() -- 2667
		inv.ammo = inv.ammo - 1 -- 2668
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2669
		self:log("用备用弹包") -- 2670
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2671
		return -- 2672
	end -- 2672
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2672
		local p = self.player -- 2676
		self.bracedShield = { -- 2677
			x = p.x + p.facing * 26, -- 2677
			y = p.y, -- 2677
			w = 30, -- 2677
			h = 64, -- 2677
			hp = 1 -- 2677
		} -- 2677
		local ____self_boxes_45 = self.boxes -- 2677
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 2678
			x0 = self.bracedShield.x - 15, -- 2679
			x1 = self.bracedShield.x + 15, -- 2679
			y0 = p.y, -- 2680
			y1 = p.y + 64, -- 2680
			depth = {min = -46, max = 46}, -- 2680
			label = "架起的残盾", -- 2680
			id = "braced_shield", -- 2680
			soft = true -- 2681
		} -- 2681
		inv.shield = inv.shield - 1 -- 2684
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2685
		self:log("架残盾") -- 2686
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2687
		return -- 2688
	end -- 2688
	if inv.pass > 0 and self.run.joined == false then -- 2688
		inv.pass = inv.pass - 1 -- 2691
		self.run.joined = true -- 2692
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2693
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2694
		return -- 2695
	end -- 2695
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2697
end -- 2642
function Play.prototype.useInteract(self, b) -- 2700
	local kind = b.interact == nil and "" or b.interact.kind -- 2701
	local wr = self.room -- 2702
	if kind == "open_board" then -- 2702
		b.broken = true -- 2704
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2705
		for ____, cover in ipairs(self.boxes) do -- 2706
			if cover.id == "s2_board_cover" then -- 2706
				cover.broken = false -- 2708
				cover.hidden = false -- 2709
			end -- 2709
		end -- 2709
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2712
		self.run.joined = true -- 2713
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2714
		self:log("放下窗板") -- 2715
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2716
		return -- 2717
	end -- 2717
	if kind == "lower_curtain" then -- 2717
		for ____, curtain in ipairs(self.boxes) do -- 2720
			if curtain.id == "c2_curtain" then -- 2720
				curtain.broken = false -- 2722
				curtain.hidden = false -- 2723
			end -- 2723
		end -- 2723
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2726
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2727
		self:log("放下木帘") -- 2728
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2729
		return -- 2730
	end -- 2730
	if kind == "raise_latch" then -- 2730
		if wr.key == "c2-granary" and not self.cartDocked then -- 2730
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2734
			return -- 2735
		end -- 2735
		b.broken = true -- 2737
		self.objectiveDone = true -- 2738
		if wr.key == "c1-yard" then -- 2738
			self.run.c1Latch = true -- 2741
			self.run.joined = true -- 2742
		else -- 2742
			self.run.c2Latch = true -- 2744
			self.run.joined = true -- 2745
		end -- 2745
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2747
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2748
		self:log("抬闩") -- 2749
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2750
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2751
	end -- 2751
end -- 2700
function Play.prototype.stepCampaignCart(self, dt, input) -- 2756
	local wr = self.room -- 2757
	local c = wr.cart -- 2758
	if c.bodyW <= 0 then -- 2758
		return -- 2760
	end -- 2760
	local p = self.player -- 2762
	local handleX = self.cartAxle + c.handleOffset -- 2763
	if not self.gripping then -- 2763
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2763
			self.gripping = true -- 2767
			self:flashSet("握住车柄 · A/D 推", 1) -- 2768
		end -- 2768
		return -- 2770
	end -- 2770
	if input.interact.pressed then -- 2770
		self.gripping = false -- 2773
		self:flashSet("松手", 0.5) -- 2774
		return -- 2775
	end -- 2775
	if not self.cartDocked then -- 2775
		if input.moveX ~= 0 and not self:stuckCart() then -- 2775
			self.cartAxle = math.max( -- 2779
				c.startX, -- 2779
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2779
			) -- 2779
		end -- 2779
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2779
			self.cartExposed = true -- 2784
			local gun = nil -- 2785
			local gi = 0 -- 2786
			do -- 2786
				gi = 0 -- 2787
				while gi < #self.enemies do -- 2787
					local e = self.enemies[gi + 1] -- 2788
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2788
						gun = e -- 2790
						break -- 2791
					end -- 2791
					gi = gi + 1 -- 2787
				end -- 2787
			end -- 2787
			if gun ~= nil then -- 2787
				self:campaignEnemyFire(gun) -- 2795
			end -- 2795
		end -- 2795
		p.x = self.cartAxle + c.handleOffset -- 2798
		p.y = c.baseY + (c.depth or 0) -- 2799
		p.vx = 0 -- 2800
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2800
			self.cartAxle = c.endX -- 2802
			self.cartDocked = true -- 2803
			self.gripping = false -- 2804
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2805
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2806
			self:flashSet("车轮入窝", 1.2) -- 2807
			self:log("车轮入窝") -- 2808
		end -- 2808
	end -- 2808
end -- 2756
function Play.prototype.stuckCart(self) -- 2814
	local i = 0 -- 2815
	do -- 2815
		i = 0 -- 2816
		while i < #self.boxes do -- 2816
			do -- 2816
				local b = self.boxes[i + 1] -- 2817
				if b.broken == true or b.breakable == nil or b.soft == true then -- 2817
					goto __continue442 -- 2819
				end -- 2819
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 2821
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 2821
					return true -- 2823
				end -- 2823
			end -- 2823
			::__continue442:: -- 2823
			i = i + 1 -- 2816
		end -- 2816
	end -- 2816
	return false -- 2826
end -- 2814
function Play.prototype.stepCampaignGoal(self) -- 2830
	local wr = self.room -- 2831
	local c = wr.campaign -- 2832
	if c == nil then -- 2832
		return -- 2834
	end -- 2834
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 2834
		self.objectiveDone = true -- 2837
	end -- 2837
	if c.goal == "reach_exit" then -- 2837
		self.objectiveDone = true -- 2840
	end -- 2840
	if not self.objectiveDone then -- 2840
		return -- 2843
	end -- 2843
	local p = self.player -- 2845
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 2846
	if p.x < c.exitX or not partnerOk then -- 2846
		return -- 2848
	end -- 2848
	if self.run.story.segments[wr.key] ~= true then -- 2848
		self.run.story.segments[wr.key] = true -- 2852
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 2853
	end -- 2853
	if wr.key == "escort5" then -- 2853
		self.escortDone = true -- 2857
		self.run.story.escortDone = true -- 2858
	end -- 2858
	if c.next ~= nil and c.next ~= "" then -- 2858
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 2861
		self:flashSet("过关 · " .. c.next, 1.2) -- 2862
	elseif not self.run.finished then -- 2862
		self.run.finished = true -- 2864
		self:flashSet( -- 2865
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 2865
			2 -- 2865
		) -- 2865
		self:log("C2 灰盒完成") -- 2866
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 2867
	end -- 2867
end -- 2830
function Play.prototype.stepCampaignPartner(self, dt) -- 2872
	local a = self.partner -- 2873
	local wr = self.room -- 2874
	local cp = wr.companion -- 2875
	if not a.alive then -- 2875
		return -- 2877
	end -- 2877
	local p = self.player -- 2879
	if self.craftBench.active then -- 2879
		a.vx = 0 -- 2882
		return -- 2883
	end -- 2883
	local wait = false -- 2885
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 2886
	local targetDepth = p.depth -- 2887
	if self.run.joined == false then -- 2887
		wait = true -- 2889
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2890
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2891
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 2891
		wait = true -- 2893
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2894
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2895
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 2895
		wait = true -- 2897
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2898
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2899
	end -- 2899
	if self.partnerStuck > 0.3 then -- 2899
		a.x = a.x + a.facing * 44 -- 2903
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2904
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2905
		self.partnerLaneHold = 1.1 -- 2906
		self.partnerStuck = 0 -- 2907
	end -- 2907
	if self.partnerLaneHold > 0 then -- 2907
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2910
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2911
	end -- 2911
	local dx = targetX - a.x -- 2913
	if not wait and math.abs(dx) > 74 then -- 2913
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2915
		local before = a.x -- 2916
		a.vx = dx > 0 and speed or -speed -- 2917
		a.facing = dx > 0 and 1 or -1 -- 2918
		self:slideX(a, a.vx * dt) -- 2919
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2919
			a.vy = CHILD_JUMP -- 2922
			a.onGround = false -- 2923
		end -- 2923
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2925
	else -- 2925
		a.vx = 0 -- 2927
		self.partnerStuck = 0 -- 2928
	end -- 2928
	local dz = targetDepth - a.depth -- 2930
	if math.abs(dz) > 6 then -- 2930
		local step = math.max( -- 2932
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 2932
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 2932
		) -- 2932
		a.depth = a.depth + step -- 2933
	end -- 2933
	a.depthSpeed = 0 -- 2935
	a.h = CHILD_H -- 2936
	a.crouch = false -- 2937
	self:fallY(a, dt) -- 2938
end -- 2872
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 2942
	local p = self.player -- 2943
	local i = 0 -- 2944
	do -- 2944
		i = 0 -- 2945
		while i < #self.enemies do -- 2945
			do -- 2945
				local ____opt_46 = self.run.trial -- 2945
				if ____opt_46 and ____opt_46.lost then -- 2945
					return -- 2946
				end -- 2946
				local e = self.enemies[i + 1] -- 2947
				if not e.alive then -- 2947
					goto __continue469 -- 2949
				end -- 2949
				if e.hitT > 0 then -- 2949
					e.hitT = e.hitT - dt -- 2952
				end -- 2952
				if e.kind == "target" then -- 2952
					if not e.alive and e.hitT <= 0 then -- 2952
						e.alive = true -- 2957
					end -- 2957
					goto __continue469 -- 2959
				end -- 2959
				if e.kind == "breaker" then -- 2959
					self:stepBreaker(e, dt) -- 2962
					goto __continue469 -- 2963
				end -- 2963
				if e.kind == "shield" then -- 2963
					self:stepShield(e, dt, input) -- 2966
					goto __continue469 -- 2967
				end -- 2967
				local dx = e.x - p.x -- 2970
				if not e.awake then -- 2970
					if math.abs(dx) > 520 then -- 2970
						goto __continue469 -- 2973
					end -- 2973
					e.awake = true -- 2975
					e.fireCd = 48 -- 2976
					goto __continue469 -- 2977
				end -- 2977
				if math.abs(dx) > ENEMY_RANGE then -- 2977
					goto __continue469 -- 2980
				end -- 2980
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 2980
					goto __continue469 -- 2985
				end -- 2985
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 2985
					goto __continue469 -- 2988
				end -- 2988
				if self:blockedShot(e, p) then -- 2988
					if e.warnT > 0 then -- 2988
						e.warnT = 0 -- 2994
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 2995
					end -- 2995
					goto __continue469 -- 2997
				end -- 2997
				if e.warnT > 0 then -- 2997
					e.warnT = e.warnT - 1 -- 3000
					if e.warnT <= 0 then -- 3000
						self:campaignEnemyFire(e) -- 3002
					end -- 3002
				elseif e.fireCd > 0 then -- 3002
					e.fireCd = e.fireCd - 1 -- 3005
					if e.fireCd <= 0 then -- 3005
						e.warnT = WARN_TICKS -- 3007
					end -- 3007
				else -- 3007
					e.fireCd = 40 -- 3010
				end -- 3010
			end -- 3010
			::__continue469:: -- 3010
			i = i + 1 -- 2945
		end -- 2945
	end -- 2945
end -- 2942
function Play.prototype.blockedShot(self, e, p) -- 3016
	local eDepth = e.depth or 0 -- 3017
	local ex = e.x -- 3018
	local ey = e.y + e.h * 0.62 -- 3020
	local px = p.x -- 3021
	local py = p.y + p.h * 0.55 -- 3022
	local dx = px - ex -- 3023
	local dyScreen = py + p.depth - (ey + eDepth) -- 3024
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3025
	if len < 0.01 then -- 3025
		return false -- 3027
	end -- 3027
	local ray = { -- 3031
		x = ex, -- 3032
		y = ey, -- 3032
		dx = dx / len, -- 3033
		dy = (py - ey) / len, -- 3033
		depth = eDepth, -- 3034
		dDepth = (p.depth - eDepth) / len -- 3034
	} -- 3034
	local best = -1 -- 3036
	local j = 0 -- 3037
	do -- 3037
		j = 0 -- 3038
		while j < #self.boxes do -- 3038
			do -- 3038
				local b = self.boxes[j + 1] -- 3039
				if b.broken == true or b.passable == true or b.hidden == true then -- 3039
					goto __continue492 -- 3041
				end -- 3041
				if b.id == "braced_shield" then -- 3041
					goto __continue492 -- 3046
				end -- 3046
				local t = hitBox(ray, b) -- 3048
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3048
					best = t -- 3052
				end -- 3052
			end -- 3052
			::__continue492:: -- 3052
			j = j + 1 -- 3038
		end -- 3038
	end -- 3038
	return best >= 0 -- 3055
end -- 3016
function Play.prototype.campaignEnemyFire(self, e) -- 3058
	local p = self.player -- 3059
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3060
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3060
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3060
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3062
		self.boxes = __TS__ArrayFilter( -- 3063
			self.boxes, -- 3063
			function(____, b) return b.id ~= "braced_shield" end -- 3063
		) -- 3063
		self.bracedShield = nil -- 3064
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3065
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3066
		return -- 3067
	end -- 3067
	if self:blockedShot(e, p) then -- 3067
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3070
		return -- 3071
	end -- 3071
	local cover = self:blockedByCover(e, p) -- 3073
	if cover ~= nil and self.coverHug then -- 3073
		self.coveredFlash = 0.5 -- 3075
		self:flashSet("掩体挡下", 0.6) -- 3076
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3077
		return -- 3082
	end -- 3082
	if self.invulnT > 0 then -- 3082
		return -- 3085
	end -- 3085
	local ____opt_50 = self.run.trial -- 3085
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3087
	self.craftT = 0 -- 3088
	self.hp = self.hp - 1 -- 3089
	self:emit("actorHit", { -- 3090
		target = "player", -- 3090
		amount = 1, -- 3090
		hp = self.hp, -- 3090
		maxHp = self.maxHp, -- 3090
		enemyX = e.x -- 3090
	}) -- 3090
	self:flashSet( -- 3091
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3091
		0.8 -- 3091
	) -- 3091
	if self.hp <= 0 then -- 3091
		self:campaignFailed() -- 3093
	end -- 3093
end -- 3058
function Play.prototype.stepShield(self, e, dt, input) -- 3098
	local p = self.player -- 3099
	local dx = p.x - e.x -- 3100
	local adx = math.abs(dx) -- 3101
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3104
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3105
	if adx > 150 then -- 3105
		local before = e.x -- 3107
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3108
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3108
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3111
		end -- 3111
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3111
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3116
		local rollDodges = p.rollT > 0 and fromFront -- 3117
		if not rollDodges and self.invulnT <= 0 then -- 3117
			local ____opt_52 = self.run.trial -- 3117
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3119
			self.craftT = 0 -- 3120
			self.hp = self.hp - 1 -- 3121
			self:emit("actorHit", { -- 3122
				target = "player", -- 3122
				amount = 1, -- 3122
				hp = self.hp, -- 3122
				maxHp = self.maxHp, -- 3122
				enemyX = e.x -- 3122
			}) -- 3122
			self:flashSet( -- 3123
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3123
				0.8 -- 3123
			) -- 3123
			if self.hp <= 0 then -- 3123
				self:campaignFailed() -- 3125
				return -- 3126
			end -- 3126
		end -- 3126
		e.swingT = 70 -- 3129
	end -- 3129
	if (e.swingT or 0) > 0 then -- 3129
		e.swingT = (e.swingT or 0) - 1 -- 3132
	end -- 3132
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3132
		local dd = p.depth - (e.depth or 0) -- 3135
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3136
	end -- 3136
end -- 3098
function Play.prototype.stepBreaker(self, e, dt) -- 3141
	local p = self.player -- 3142
	if e.awake ~= true then -- 3142
		if math.abs(p.x - e.x) < 560 then -- 3142
			e.awake = true -- 3145
		else -- 3145
			return -- 3147
		end -- 3147
	end -- 3147
	local target = nil -- 3150
	local bestD = 1000000000 -- 3151
	local i = 0 -- 3152
	do -- 3152
		i = 0 -- 3153
		while i < #self.boxes do -- 3153
			do -- 3153
				local b = self.boxes[i + 1] -- 3154
				if b.breakable == nil or b.broken == true then -- 3154
					goto __continue516 -- 3156
				end -- 3156
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3158
				if d < bestD then -- 3158
					bestD = d -- 3160
					target = b -- 3161
				end -- 3161
			end -- 3161
			::__continue516:: -- 3161
			i = i + 1 -- 3153
		end -- 3153
	end -- 3153
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3164
	local dx = tx - e.x -- 3165
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3166
	if math.abs(dx) > reach then -- 3166
		local before = e.x -- 3168
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3169
		if math.abs(e.x - before) < 0.3 then -- 3169
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3171
		end -- 3171
	elseif (e.swingT or 0) <= 0 then -- 3171
		e.swingT = 64 -- 3174
		if target ~= nil then -- 3174
			self:damageProp(target, 2) -- 3176
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3176
			local ____opt_54 = self.run.trial -- 3176
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3178
			self.craftT = 0 -- 3179
			self.hp = self.hp - 1 -- 3180
			self:emit("actorHit", { -- 3181
				target = "player", -- 3181
				amount = 1, -- 3181
				hp = self.hp, -- 3181
				maxHp = self.maxHp, -- 3181
				enemyX = e.x -- 3181
			}) -- 3181
			self:flashSet("破障手近身", 0.8) -- 3182
			if self.hp <= 0 then -- 3182
				self:campaignFailed() -- 3184
				return -- 3185
			end -- 3185
		end -- 3185
	end -- 3185
	if (e.swingT or 0) > 0 then -- 3185
		e.swingT = (e.swingT or 0) - 1 -- 3190
	end -- 3190
end -- 3141
function Play.prototype.campaignFailed(self) -- 3194
	if self.run.trial ~= nil then -- 3194
		self.run.trial.lost = true -- 3196
		self.wantRoom = "" -- 3197
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3198
		return -- 3199
	end -- 3199
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3199
		self:restartEscortFromDeath() -- 3204
		return -- 3205
	end -- 3205
	local p = self.player -- 3207
	self.hp = self.maxHp -- 3208
	self.invulnT = INVULN_RESPAWN_TICKS -- 3209
	self.reloadT = 0 -- 3210
	self:closeReloadPuzzle() -- 3211
	self.gripping = false -- 3212
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3213
	self:log("被击倒") -- 3214
	p.x = self.room.minX + 90 -- 3215
	p.y = 0 -- 3216
	p.depth = 0 -- 3217
	p.vx = 0 -- 3218
	p.vy = 0 -- 3219
	p.onGround = true -- 3220
	p.rollT = 0 -- 3221
	self.partner.x = p.x - 50 -- 3222
	self.partner.y = 0 -- 3223
	self.partner.depth = 0 -- 3224
	self.cam.x = p.x -- 3225
	local i = 0 -- 3226
	do -- 3226
		i = 0 -- 3227
		while i < #self.enemies do -- 3227
			do -- 3227
				local e = self.enemies[i + 1] -- 3228
				if not e.alive then -- 3228
					goto __continue530 -- 3230
				end -- 3230
				e.x = e.homeX == nil and e.x or e.homeX -- 3232
				e.warnT = 0 -- 3233
				e.fireCd = 40 -- 3234
				e.swingT = 0 -- 3235
				e.awake = false -- 3236
			end -- 3236
			::__continue530:: -- 3236
			i = i + 1 -- 3227
		end -- 3227
	end -- 3227
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3238
end -- 3194
function Play.prototype.isEscortRoom(self) -- 3242
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3243
end -- 3242
function Play.prototype.restartEscortFromDeath(self) -- 3251
	local story = self.run.story -- 3252
	local inv = self.run.inventory -- 3253
	self.hp = self.maxHp -- 3254
	story.hp = self.maxHp -- 3255
	story.cp = nil -- 3256
	self.checkpointSnap = nil -- 3257
	story.carry = false -- 3258
	self.carryOn = false -- 3259
	story.craftedWeapon = "" -- 3260
	self.equippedWeapon = "standard_gun" -- 3261
	story.escortDone = false -- 3262
	self.escortDone = false -- 3263
	story.segments = {} -- 3264
	inv.wood = 0 -- 3265
	inv.bell = 0 -- 3266
	inv.scrap = 0 -- 3267
	inv.wedge = 0 -- 3268
	inv.ammo = 0 -- 3269
	inv.quickbelt = 0 -- 3270
	inv.shield = 0 -- 3271
	inv.pass = 0 -- 3272
	local taken = self.run.taken -- 3273
	local keys = __TS__ObjectKeys(taken) -- 3274
	local i = 0 -- 3275
	do -- 3275
		i = 0 -- 3276
		while i < #keys do -- 3276
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3276
				__TS__Delete(taken, keys[i + 1]) -- 3278
			end -- 3278
			i = i + 1 -- 3276
		end -- 3276
	end -- 3276
	self.run.joined = true -- 3281
	self.reloadT = 0 -- 3282
	self:closeReloadPuzzle() -- 3283
	self.gripping = false -- 3284
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3285
	self:log("男主线失败 · 回 escort1") -- 3286
	self:emit("campaignFailed", { -- 3287
		room = self.room.key, -- 3288
		hp = 0, -- 3288
		maxHp = self.maxHp, -- 3288
		reset = true, -- 3289
		to = "escort1", -- 3289
		route = self.storyRoute -- 3289
	}) -- 3289
	self:requestRoom("escort1", "男主线失败重开") -- 3291
end -- 3251
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3295
	local i = 0 -- 3296
	do -- 3296
		i = 0 -- 3297
		while i < #self.enemies do -- 3297
			do -- 3297
				if i == skipIndex then -- 3297
					goto __continue539 -- 3299
				end -- 3299
				local e = self.enemies[i + 1] -- 3301
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3301
					goto __continue539 -- 3303
				end -- 3303
				e.fireCd = 150 -- 3305
				e.warnT = 0 -- 3306
			end -- 3306
			::__continue539:: -- 3306
			i = i + 1 -- 3297
		end -- 3297
	end -- 3297
end -- 3295
function Play.prototype.stepEnemies(self, dt, input) -- 3310
	local i = 0 -- 3311
	do -- 3311
		i = 0 -- 3312
		while i < #self.enemies do -- 3312
			local e = self.enemies[i + 1] -- 3313
			if e.hitT > 0 then -- 3313
				e.hitT = e.hitT - dt -- 3315
			end -- 3315
			i = i + 1 -- 3312
		end -- 3312
	end -- 3312
	if self.coveredFlash > 0 then -- 3312
		self.coveredFlash = self.coveredFlash - dt -- 3319
	end -- 3319
	if self.isCampaign then -- 3319
		self:stepCampaignEnemies(dt, input) -- 3322
		return -- 3323
	end -- 3323
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3323
		return -- 3327
	end -- 3327
	do -- 3327
		i = 0 -- 3329
		while i < #self.enemies do -- 3329
			do -- 3329
				local e = self.enemies[i + 1] -- 3330
				if not e.alive then -- 3330
					goto __continue550 -- 3332
				end -- 3332
				if e.warnT > 0 then -- 3332
					e.warnT = e.warnT - 1 -- 3335
					if e.warnT <= 0 then -- 3335
						self:enemyFire(e, input) -- 3337
					end -- 3337
					goto __continue550 -- 3339
				end -- 3339
				if e.fireCd > 0 then -- 3339
					e.fireCd = e.fireCd - 1 -- 3342
					if e.fireCd <= 0 then -- 3342
						e.warnT = WARN_TICKS -- 3344
					end -- 3344
				else -- 3344
					e.warnT = WARN_TICKS -- 3348
				end -- 3348
			end -- 3348
			::__continue550:: -- 3348
			i = i + 1 -- 3329
		end -- 3329
	end -- 3329
end -- 3310
function Play.prototype.enemyFire(self, e, input) -- 3354
	local p = self.player -- 3355
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3355
		self:flashSet("枪声响在远处", 0.4) -- 3357
		e.fireCd = FIRE_COOLDOWN -- 3358
		return -- 3359
	end -- 3359
	local cover = self:blockedByCover(e, p) -- 3362
	local hugging = cover ~= nil -- 3363
	self.coverBlocking = hugging -- 3364
	local covered = hugging and input.cover.held -- 3365
	if covered then -- 3365
		self.coveredFlash = 0.5 -- 3367
		self:flashSet("掩体挡下", 0.5) -- 3368
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3369
		e.fireCd = FIRE_COOLDOWN -- 3374
		return -- 3375
	end -- 3375
	self.hp = self.hp - 1 -- 3377
	self:emit("actorHit", { -- 3378
		target = "player", -- 3378
		amount = 1, -- 3378
		hp = self.hp, -- 3378
		maxHp = self.maxHp, -- 3378
		enemyX = e.x -- 3378
	}) -- 3378
	self:flashSet( -- 3379
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3379
		0.7 -- 3379
	) -- 3379
	e.fireCd = FIRE_COOLDOWN -- 3380
	if self.hp <= 0 then -- 3380
		self:gateFailed() -- 3382
	end -- 3382
end -- 3354
function Play.prototype.blockedByCover(self, enemy, p) -- 3387
	local b = self:coverAt(p) -- 3388
	if b == nil then -- 3388
		return nil -- 3390
	end -- 3390
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3392
end -- 3387
function Play.prototype.gateFailed(self) -- 3396
	local ____temp_56 -- 3397
	if self.room.story == nil then -- 3397
		____temp_56 = nil -- 3397
	else -- 3397
		____temp_56 = self.room.story.gate -- 3397
	end -- 3397
	local g = ____temp_56 -- 3397
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3398
	self.hp = self.maxHp -- 3399
	self.gateTick = 0 -- 3400
	self.gateSpawned = 0 -- 3401
	self.enemies = {} -- 3402
	self.gateFailCount = self.gateFailCount + 1 -- 3403
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3405
	self.player.y = 0 -- 3406
	self.player.vy = 0 -- 3407
	self.player.depth = 0 -- 3408
	self.player.depthSpeed = 0 -- 3409
	self.player.onGround = true -- 3410
	self.player.crouch = false -- 3411
	self.player.h = SOLDIER_H -- 3412
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3413
	self.partner.y = 0 -- 3414
	self.partner.vy = 0 -- 3415
	self.partner.depth = 0 -- 3416
	self.partner.depthSpeed = 0 -- 3417
	self.partner.onGround = true -- 3418
	self.cam.x = self.player.x -- 3419
	self.phase = "gate-idle" -- 3420
	self.phaseTick = 0 -- 3421
	self.coverHug = false -- 3422
	self.coverBlocking = false -- 3423
	self.coverEntity = "" -- 3424
	self.gateNeedConfirm = true -- 3425
	self.gateRestartArmed = false -- 3426
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3427
end -- 3396
function Play.prototype.stepInteract(self, dt, input) -- 3430
	local p = self.player -- 3431
	local calmUsed = self.calmConsumed -- 3432
	self.calmConsumed = false -- 3433
	local calming = self.escort.state == "calming" -- 3435
	self.focusCart = false -- 3436
	if self.room.key == "outside" then -- 3436
		local c = self.room.cart -- 3438
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3439
		local dy = p.y - c.baseY -- 3440
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3441
	end -- 3441
	if not calmUsed and not calming then -- 3441
		self:stepCart(dt, input) -- 3445
	end -- 3445
	if calmUsed then -- 3445
		self:flashSet("安抚 · 敲两下", 0.8) -- 3450
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 3450
		if self.knockT > 0 then -- 3450
			self.knocks = self.knocks + 1 -- 3454
		else -- 3454
			self.knocks = 1 -- 3456
		end -- 3456
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3458
		self.knockT = 1.2 -- 3459
		if self.knocks >= 2 then -- 3459
			self:flashSet("敲两下", 0.8) -- 3461
			self.knocks = 0 -- 3462
		else -- 3462
			self:flashSet("敲一下", 0.5) -- 3464
		end -- 3464
	elseif self.knockT > 0 then -- 3464
		self.knockT = self.knockT - dt -- 3467
		if self.knockT <= 0 then -- 3467
			self.knocks = 0 -- 3469
		end -- 3469
	end -- 3469
	local i = 0 -- 3474
	do -- 3474
		i = 0 -- 3475
		while i < #self.room.marks do -- 3475
			do -- 3475
				local m = self.room.marks[i + 1] -- 3476
				if m.kind ~= 0 then -- 3476
					goto __continue576 -- 3478
				end -- 3478
				local subjects = {self.partner, self.player} -- 3480
				local k = 0 -- 3481
				do -- 3481
					k = 0 -- 3482
					while k < #subjects do -- 3482
						do -- 3482
							local s = subjects[k + 1] -- 3483
							if not s.alive then -- 3483
								goto __continue579 -- 3485
							end -- 3485
							local dx = s.x - m.x -- 3487
							local dy = s.y - m.y -- 3488
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3488
								self.checkpoint = m.x -- 3490
								self.checkpointCartAxle = self.cartAxle -- 3491
								if self.isCampaign then -- 3491
									self:captureCheckpoint(m.x) -- 3494
								end -- 3494
								if self.cartDocked then -- 3494
									self:flashSet("检查点 · 车已落窝", 1) -- 3497
								else -- 3497
									self:flashSet("检查点 · 车还没到位", 1) -- 3499
								end -- 3499
							end -- 3499
						end -- 3499
						::__continue579:: -- 3499
						k = k + 1 -- 3482
					end -- 3482
				end -- 3482
			end -- 3482
			::__continue576:: -- 3482
			i = i + 1 -- 3475
		end -- 3475
	end -- 3475
	self:checkCarryGate() -- 3505
end -- 3430
function Play.prototype.stepVillage(self, dt, input) -- 3509
	if self.room.key ~= "village" then -- 3509
		return -- 3511
	end -- 3511
	local p = self.player -- 3513
	local bottle = self.room.bottle -- 3514
	local scav = self.room.scavenger -- 3515
	if not self.hasBottle and bottle ~= nil then -- 3515
		local dx = p.x - bottle.x -- 3519
		local dy = p.y + p.h * 0.5 - bottle.y -- 3520
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3520
			self.hasBottle = true -- 3522
			self:flashSet("拾起瓶子", 0.8) -- 3523
		end -- 3523
	end -- 3523
	if self.hasBottle then -- 3523
		if input.aim.held then -- 3523
			self.aimHold = self.aimHold + dt -- 3530
			if self.aimHold > 1.2 then -- 3530
				self.aimHold = 1.2 -- 3532
			end -- 3532
			local cached = self:bottleEnd() -- 3535
			self.bottleAimX = cached.x -- 3536
			self.bottleAimY = cached.y -- 3537
		elseif input.aim.released then -- 3537
			if self.aimHold < 0.12 then -- 3537
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3541
				self.aimHold = 0 -- 3542
			else -- 3542
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3544
				self:throwBottle(____end.x, ____end.y) -- 3545
				self.aimHold = 0 -- 3546
			end -- 3546
		end -- 3546
	else -- 3546
		self.aimHold = 0 -- 3550
		self.bottleAimX = -1 -- 3551
	end -- 3551
	local fly = self.bottleFly -- 3556
	if fly ~= nil then -- 3556
		fly.t = fly.t + dt -- 3558
		fly.x = fly.x0 + fly.vx * fly.t -- 3559
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3560
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3561
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3561
			self:landBottle(fly) -- 3563
		end -- 3563
	end -- 3563
	if self.bottleLandT > 0 then -- 3563
		self.bottleLandT = self.bottleLandT - dt -- 3567
	end -- 3567
	if scav ~= nil then -- 3567
		self:stepScav(dt, scav) -- 3571
	end -- 3571
	local line = self.room.passLine -- 3574
	if line ~= nil and not self.passed and p.x >= line then -- 3574
		self.passed = true -- 3576
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3577
	end -- 3577
	if self.passed and p.x >= self.ox + 640 then -- 3577
		self:requestRoom("forest", "过第一院出院") -- 3581
		self:flashSet("出院 · 北塔森林", 1.4) -- 3582
	end -- 3582
end -- 3509
function Play.prototype.bottleEnd(self) -- 3587
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3588
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3591
	return {x = aim.x, y = g} -- 3592
end -- 3587
function Play.prototype.throwBottle(self, tx, ty) -- 3596
	local p = self.player -- 3597
	local dir = tx >= p.x and 1 or -1 -- 3599
	p.facing = dir -- 3600
	local x0 = p.x + dir * 10 -- 3601
	local y0 = p.y + p.h * 0.7 -- 3602
	self.bottleTargetX = tx -- 3603
	self.bottleTargetY = ty -- 3604
	self.bottleSurfaceY = ty -- 3605
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3606
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3607
	self.bottleFly = { -- 3608
		x = x0, -- 3608
		y = y0, -- 3608
		x0 = x0, -- 3608
		y0 = y0, -- 3608
		vx = vx, -- 3608
		vy = vy, -- 3608
		t = 0 -- 3608
	} -- 3608
	self.hasBottle = false -- 3609
	self:flashSet("投出", 0.4) -- 3610
	self:emit( -- 3611
		"bottleThrown", -- 3611
		{ -- 3611
			fromX = x0, -- 3612
			fromY = y0, -- 3613
			targetX = tx, -- 3614
			targetY = ty, -- 3615
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3616
		} -- 3616
	) -- 3616
end -- 3596
function Play.prototype.landBottle(self, fly) -- 3621
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3622
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3623
	local s = self.room.scavenger -- 3624
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3625
	self.bottleFly = nil -- 3626
	self.bottleTargetX = -1 -- 3627
	self.bottleTargetY = 0 -- 3628
	self.bottleSurfaceY = -1 -- 3629
	self.bottleLandX = x -- 3630
	self.bottleLandY = y -- 3631
	self.bottleLandT = 0.9 -- 3632
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3633
	self:hearBottle(x) -- 3634
end -- 3621
function Play.prototype.hearBottle(self, x) -- 3638
	local s = self.room.scavenger -- 3639
	if s == nil then -- 3639
		return -- 3641
	end -- 3641
	if math.abs(x - self.scavX) > s.range then -- 3641
		self:flashSet("落地 · 他没听见", 0.6) -- 3644
		return -- 3645
	end -- 3645
	self.scavState = "turn" -- 3647
	self.scavT = s.hearTicks -- 3648
	self.scavTargetX = x -- 3649
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3650
end -- 3638
function Play.prototype.stepScav(self, dt, s) -- 3654
	if self.scavState == "chase" then -- 3654
		return -- 3657
	end -- 3657
	if self.scavState == "turn" then -- 3657
		self.scavT = self.scavT - 1 -- 3660
		if self.scavT <= 0 then -- 3660
			self.scavState = "walk" -- 3662
		end -- 3662
		return -- 3664
	end -- 3664
	if self.scavState == "walk" then -- 3664
		local d = self.scavTargetX - self.scavX -- 3667
		if math.abs(d) < 4 then -- 3667
			self.scavState = "stall" -- 3669
			self.scavT = s.stallTicks -- 3670
			return -- 3671
		end -- 3671
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3673
		return -- 3674
	end -- 3674
	if self.scavState == "stall" then -- 3674
		self.scavT = self.scavT - 1 -- 3677
		if self.scavT <= 0 then -- 3677
			self.scavState = "back" -- 3679
		end -- 3679
		return -- 3681
	end -- 3681
	if self.scavState == "back" then -- 3681
		local home = math.max( -- 3684
			s.x0, -- 3684
			math.min(s.x1, self.scavX) -- 3684
		) -- 3684
		if math.abs(home - self.scavX) < 2 then -- 3684
			self.scavState = "patrol" -- 3686
			return -- 3687
		end -- 3687
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3689
		return -- 3690
	end -- 3690
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3692
	if self.scavX >= s.x1 then -- 3692
		self.scavX = s.x1 -- 3694
		self.scavDir = -1 -- 3695
	elseif self.scavX <= s.x0 then -- 3695
		self.scavX = s.x0 -- 3697
		self.scavDir = 1 -- 3698
	end -- 3698
end -- 3654
function Play.prototype.stepCart(self, dt, input) -- 3706
	local p = self.player -- 3707
	local c = self.room.cart -- 3708
	if self.gripping then -- 3708
		if not input.interact.held then -- 3708
			self.gripping = false -- 3712
			self:flashSet("松开车把", 0.4) -- 3713
			return -- 3714
		end -- 3714
	else -- 3714
		if not input.interact.pressed then -- 3714
			return -- 3718
		end -- 3718
		if not self:cartHandleInReach(p) then -- 3718
			return -- 3721
		end -- 3721
		local track = c.depth or 0 -- 3723
		if self:limitDepth(p, track) ~= track then -- 3723
			return -- 3725
		end -- 3725
		p.depth = track -- 3727
		p.depthSpeed = 0 -- 3728
		self.gripping = true -- 3729
		self:flashSet("握住车把", 0.4) -- 3730
		return -- 3731
	end -- 3731
	if self.cartDocked then -- 3731
		return -- 3735
	end -- 3735
	local dir = input.moveX -- 3737
	if dir == 0 then -- 3737
		return -- 3739
	end -- 3739
	local lo = math.min(c.startX, c.endX) -- 3741
	local hi = math.max(c.startX, c.endX) -- 3742
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3743
	if next < lo then -- 3743
		next = lo -- 3745
	end -- 3745
	if next > hi then -- 3745
		next = hi -- 3748
	end -- 3748
	local delta = next - self.cartAxle -- 3750
	if delta == 0 then -- 3750
		return -- 3752
	end -- 3752
	self.cartAxle = next -- 3754
	p.x = p.x + delta -- 3755
	p.facing = dir > 0 and 1 or -1 -- 3756
	self:slideX(p, 0) -- 3757
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3757
		self.gripping = false -- 3759
		self:flashSet("跟不上了，脱手", 0.6) -- 3760
		return -- 3761
	end -- 3761
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3761
		self.cartDocked = true -- 3764
		self.gripping = false -- 3765
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3766
		self:flashSet("车轮落窝", 1.2) -- 3767
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3767
		self:flashSet("车轮回到起点", 0.5) -- 3769
	end -- 3769
end -- 3706
function Play.prototype.requestRoom(self, key, reason) -- 3777
	if self.wantRoom ~= "" then -- 3777
		return -- 3781
	end -- 3781
	self.wantRoom = key -- 3783
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3784
end -- 3777
function Play.prototype.checkCarryGate(self) -- 3791
	if self.room.key == "checkpoint" then -- 3791
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3791
			self.carryCartAxle = self.cartAxle -- 3794
			self.carryCartDocked = self.cartDocked -- 3795
			self:requestRoom("gate", "检查站出口") -- 3796
			self:flashSet("出检查站 · 城门", 1.2) -- 3797
		end -- 3797
		return -- 3799
	end -- 3799
	if self.room.key == "outside" then -- 3799
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3799
			self.carryCartAxle = self.cartAxle -- 3805
			self.carryCartDocked = self.cartDocked -- 3806
			self:requestRoom("village", "墙根走完") -- 3807
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3808
		end -- 3808
	end -- 3808
end -- 3791
function Play.prototype.aimAt(self, wx, wy) -- 3815
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3816
	self.aimX = s.x -- 3817
	self.aimY = s.y -- 3818
end -- 3815
function Play.prototype.shoot(self, a) -- 3821
	if self.isCampaign and self.reloadT > 0 then -- 3821
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3823
		return -- 3824
	end -- 3824
	local ox = a.x + a.facing * 8 -- 3826
	local muzzleY = a.y + a.h * 0.72 -- 3827
	local oy = muzzleY + a.depth -- 3828
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3830
	local dx = aim.x - ox -- 3833
	local dy = aim.y - oy -- 3834
	local len = math.sqrt(dx * dx + dy * dy) -- 3835
	if len < 0.001 then -- 3835
		dx = a.facing -- 3837
		dy = 0 -- 3838
	else -- 3838
		dx = dx / len -- 3840
		dy = dy / len -- 3841
	end -- 3841
	if dx ~= 0 then -- 3841
		a.facing = dx > 0 and 1 or -1 -- 3844
	end -- 3844
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3847
	local hitEnemy = self:raycastEnemies(ray) -- 3848
	local tEnemy = hitEnemy.t -- 3849
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3850
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3851
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3852
	local tWall = solid.t -- 3853
	local rawEffect = self:consumeReloadEffect() -- 3855
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 3856
	local reloadEffect = rawEffect -- 3857
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 3859
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3860
	self.trace = { -- 3862
		x0 = ox, -- 3862
		y0 = oy, -- 3862
		x1 = ox + dx * t, -- 3862
		y1 = oy + dy * t, -- 3862
		hit = hit -- 3862
	} -- 3862
	self.traceT = 0.12 -- 3863
	self:applyFireDanger(ox) -- 3864
	local killed = false -- 3865
	if hit then -- 3865
		local i = hitEnemy.index -- 3867
		local e = self.enemies[i + 1] -- 3868
		local impactY = oy + dy * tEnemy -- 3869
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3870
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3871
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3871
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3873
			e.hitT = 0.3 -- 3874
			self:flashSet( -- 3875
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3875
				0.8 -- 3875
			) -- 3875
			self:emit("shotResolved", { -- 3876
				hit = true, -- 3877
				enemyIndex = i, -- 3877
				enemyX = e.x, -- 3877
				aimX = aim.x, -- 3877
				aimY = aim.y, -- 3877
				impactX = ox + dx * t, -- 3878
				impactY = oy + dy * t, -- 3878
				shield = true -- 3878
			}) -- 3878
			self:beginReload() -- 3880
			return -- 3881
		end -- 3881
		e.alive = false -- 3883
		e.hitT = 0.4 -- 3884
		killed = true -- 3885
		self:flashSet("命中", 0.6) -- 3886
		self:dropFor(e) -- 3887
		if reloadEffect == "light" and weaponFx == "light" then -- 3887
			self:blindNearby(e, 160, i) -- 3889
		end -- 3889
		if reloadEffect == "push" then -- 3889
			e.x = e.x + a.facing * 46 -- 3892
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 3893
		elseif reloadEffect == "echo" then -- 3893
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 3895
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 3896
		elseif reloadEffect == "light" then -- 3896
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 3898
		end -- 3898
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3898
		self:damageProp(solid.box, 1) -- 3901
	else -- 3901
		self:flashSet("打空", 0.35) -- 3903
	end -- 3903
	if self.isCampaign then -- 3903
		self:beginReload() -- 3906
	end -- 3906
	self:emit("shotResolved", { -- 3908
		hit = hit, -- 3909
		enemyIndex = hit and hitEnemy.index or -1, -- 3910
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3911
		aimX = aim.x, -- 3912
		aimY = aim.y, -- 3913
		impactX = ox + dx * t, -- 3914
		impactY = oy + dy * t -- 3915
	}) -- 3915
end -- 3821
function Play.prototype.applyFireDanger(self, shotX) -- 3920
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3920
		return -- 3922
	end -- 3922
	local dangerX = shotX -- 3924
	local best = -1 -- 3925
	local bestD = 1000000000 -- 3926
	local i = 0 -- 3927
	do -- 3927
		i = 0 -- 3928
		while i < #self.enemies do -- 3928
			do -- 3928
				local e = self.enemies[i + 1] -- 3929
				if not e.alive then -- 3929
					goto __continue660 -- 3931
				end -- 3931
				local d = math.abs(e.x - self.partner.x) -- 3933
				if d < bestD then -- 3933
					bestD = d -- 3935
					best = i -- 3936
				end -- 3936
			end -- 3936
			::__continue660:: -- 3936
			i = i + 1 -- 3928
		end -- 3928
	end -- 3928
	if best >= 0 then -- 3928
		dangerX = self.enemies[best + 1].x -- 3940
	end -- 3940
	local exposed = self:childExposed(dangerX) -- 3942
	local before = self.escort.fear -- 3943
	local dangerId = self.nextDangerId -- 3944
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 3945
	self.nextDangerId = self.nextDangerId + 1 -- 3946
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 3947
	if after > before then -- 3947
		self:flashSet( -- 3949
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 3949
			1 -- 3949
		) -- 3949
	elseif not exposed then -- 3949
		self:flashSet("枪声没够到她", 0.5) -- 3951
	end -- 3951
end -- 3920
function Play.prototype.childExposed(self, dangerX) -- 3956
	local c = self.partner -- 3957
	if not c.alive then -- 3957
		return false -- 3959
	end -- 3959
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 3959
		self.boxes, -- 3962
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 3962
	) then -- 3962
		return false -- 3963
	end -- 3963
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 3963
		return false -- 3966
	end -- 3966
	local toDanger = dangerX - c.x -- 3968
	local toPlayer = self.player.x - c.x -- 3969
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 3969
		return false -- 3972
	end -- 3972
	return true -- 3974
end -- 3956
function Play.prototype.raycastEnemies(self, ray) -- 3978
	local best = -1 -- 3979
	local bestI = -1 -- 3980
	do -- 3980
		local i = 0 -- 3981
		while i < #self.enemies do -- 3981
			do -- 3981
				local e = self.enemies[i + 1] -- 3982
				if not e.alive then -- 3982
					goto __continue674 -- 3984
				end -- 3984
				local y = e.y + (e.depth or 0) -- 3986
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 3987
				if t >= 0 and (best < 0 or t < best) then -- 3987
					best = t -- 3989
					bestI = i -- 3990
				end -- 3990
			end -- 3990
			::__continue674:: -- 3990
			i = i + 1 -- 3981
		end -- 3981
	end -- 3981
	return {t = best, index = bestI} -- 3993
end -- 3978
function Play.prototype.raycastWorld(self, ray) -- 3996
	return self:raycastSolid(ray).t -- 3997
end -- 3996
function Play.prototype.raycastSolid(self, ray) -- 4001
	local best = -1 -- 4002
	local bestBox = nil -- 4003
	for ____, box in ipairs(self.boxes) do -- 4004
		do -- 4004
			if box.broken == true or box.hidden == true then -- 4004
				goto __continue679 -- 4006
			end -- 4006
			local t = hitBox(ray, box) -- 4011
			if t > 2 and (best < 0 or t < best) then -- 4011
				best = t -- 4014
				bestBox = box -- 4015
			end -- 4015
		end -- 4015
		::__continue679:: -- 4015
	end -- 4015
	if ray.dy < 0 then -- 4015
		local t = -ray.y / ray.dy -- 4019
		if t >= 0 and (best < 0 or t < best) then -- 4019
			best = t -- 4021
			bestBox = nil -- 4022
		end -- 4022
	end -- 4022
	return {t = best, box = bestBox} -- 4025
end -- 4001
function Play.prototype.dropFor(self, e) -- 4029
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4029
		return -- 4031
	end -- 4031
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4031
		return -- 4034
	end -- 4034
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4036
	local ____self_pickups_57 = self.pickups -- 4036
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4037
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4038
		kind = e.drop, -- 4038
		x = e.x, -- 4038
		y = e.y, -- 4038
		depth = e.depth, -- 4039
		label = label .. " ×1" -- 4039
	} -- 4039
	self:log("掉落 " .. label) -- 4041
end -- 4029
function Play.prototype.damageProp(self, b, amount) -- 4045
	if b.breakable == nil or b.broken == true then -- 4045
		return -- 4047
	end -- 4047
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4047
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4049
	if b.breakable.hp > 0 then -- 4049
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4051
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4052
		return -- 4053
	end -- 4053
	b.broken = true -- 4055
	for ____, other in ipairs(self.boxes) do -- 4056
		if other.id ~= nil and other.id == b.id then -- 4056
			other.broken = true -- 4058
		end -- 4058
	end -- 4058
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4061
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4062
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4063
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4064
end -- 4045
function Play.prototype.slideDepth(self, a, distance) -- 4068
	a.depth = self:limitDepth(a, a.depth + distance) -- 4069
end -- 4068
function Play.prototype.limitDepth(self, a, target) -- 4072
	local road = self.room.depth -- 4073
	if road == nil or target == a.depth then -- 4073
		return a.depth -- 4075
	end -- 4075
	local next = math.max( -- 4077
		road.min, -- 4077
		math.min(road.max, target) -- 4077
	) -- 4077
	local half = a.w / 2 -- 4078
	for ____, b in ipairs(self.boxes) do -- 4079
		do -- 4079
			local footprint = b.depth -- 4080
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4080
				goto __continue697 -- 4085
			end -- 4085
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4087
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4088
			if a.depth <= front and next > front then -- 4088
				next = front -- 4090
			elseif a.depth >= back and next < back then -- 4090
				next = back -- 4092
			end -- 4092
		end -- 4092
		::__continue697:: -- 4092
	end -- 4092
	return next -- 4095
end -- 4072
function Play.prototype.slideX(self, a, dx) -- 4099
	local nx = a.x + dx -- 4100
	local half = a.w / 2 -- 4101
	local room = self.room -- 4102
	nx = math.max( -- 4103
		room.minX + half, -- 4103
		math.min(room.maxX - half, nx) -- 4103
	) -- 4103
	local i = 0 -- 4104
	do -- 4104
		i = 0 -- 4105
		while i < #self.boxes do -- 4105
			do -- 4105
				local b = self.boxes[i + 1] -- 4106
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4106
					goto __continue704 -- 4108
				end -- 4108
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4108
					goto __continue704 -- 4111
				end -- 4111
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4111
					goto __continue704 -- 4114
				end -- 4114
				if nx + half > b.x0 and nx - half < b.x1 then -- 4114
					if a.x <= b.x0 then -- 4114
						nx = b.x0 - half -- 4118
					elseif a.x >= b.x1 then -- 4118
						nx = b.x1 + half -- 4120
					else -- 4120
						nx = a.x -- 4122
					end -- 4122
				end -- 4122
			end -- 4122
			::__continue704:: -- 4122
			i = i + 1 -- 4105
		end -- 4105
	end -- 4105
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4105
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4130
		local bx0 = self.cartAxle - CART_HALF -- 4131
		local bx1 = self.cartAxle + CART_HALF -- 4132
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4132
			if a.x <= bx0 then -- 4132
				nx = bx0 - half -- 4135
			elseif a.x >= bx1 then -- 4135
				nx = bx1 + half -- 4137
			else -- 4137
				nx = a.x -- 4139
			end -- 4139
		end -- 4139
	end -- 4139
	local arch = room.arch -- 4147
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4147
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4149
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4149
			if a.x <= arch.x0 then -- 4149
				nx = arch.x0 - half -- 4152
			elseif a.x >= arch.x1 then -- 4152
				nx = arch.x1 + half -- 4154
			end -- 4154
		end -- 4154
	end -- 4154
	a.x = nx -- 4158
end -- 4099
function Play.prototype.fallY(self, a, dt) -- 4162
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4163
	if a.vy < -900 then -- 4163
		a.vy = -900 -- 4165
	end -- 4165
	local ny = a.y + a.vy * dt -- 4167
	local half = a.w / 2 -- 4168
	if a.vy <= 0 then -- 4168
		local reach = a.onGround and STEP_UP or 0 -- 4171
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4172
		if ny <= ground then -- 4172
			ny = ground -- 4174
			a.vy = 0 -- 4175
			a.onGround = true -- 4176
		else -- 4176
			a.onGround = false -- 4178
		end -- 4178
	else -- 4178
		a.onGround = false -- 4181
		local i = 0 -- 4182
		do -- 4182
			i = 0 -- 4183
			while i < #self.boxes do -- 4183
				do -- 4183
					local b = self.boxes[i + 1] -- 4184
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4184
						goto __continue728 -- 4186
					end -- 4186
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4186
						goto __continue728 -- 4189
					end -- 4189
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4189
						goto __continue728 -- 4192
					end -- 4192
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4192
						ny = b.y0 - a.h -- 4195
						a.vy = 0 -- 4196
					end -- 4196
				end -- 4196
				::__continue728:: -- 4196
				i = i + 1 -- 4183
			end -- 4183
		end -- 4183
	end -- 4183
	a.y = ny -- 4200
end -- 4162
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4204
	if depth == nil then -- 4204
		depth = 0 -- 4204
	end -- 4204
	local g = -9999 -- 4205
	local i = 0 -- 4206
	do -- 4206
		i = 0 -- 4207
		while i < #self.floors do -- 4207
			local f = self.floors[i + 1] -- 4208
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4208
				g = f.y1 -- 4210
			end -- 4210
			i = i + 1 -- 4207
		end -- 4207
	end -- 4207
	do -- 4207
		i = 0 -- 4213
		while i < #self.boxes do -- 4213
			do -- 4213
				local b = self.boxes[i + 1] -- 4214
				if b.broken == true or b.hidden == true or b.soft == true then -- 4214
					goto __continue738 -- 4216
				end -- 4216
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4216
					g = b.y1 -- 4220
				end -- 4220
			end -- 4220
			::__continue738:: -- 4220
			i = i + 1 -- 4213
		end -- 4213
	end -- 4213
	return g -- 4223
end -- 4204
function Play.prototype.updateCamera(self, dt) -- 4226
	local p = self.player -- 4227
	local tx = p.x + p.facing * 30 -- 4228
	local ty = p.y + CAM_LOOK_UP -- 4229
	local k = math.min(1, CAM_FOLLOW * dt) -- 4230
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4231
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4232
end -- 4226
function Play.prototype.clampCamera(self, w, h) -- 4236
	local room = self.room -- 4237
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4238
	local spanX = room.maxX - room.minX -- 4239
	if spanX <= halfW * 2 then -- 4239
		self.cam.x = (room.minX + room.maxX) / 2 -- 4241
	else -- 4241
		self.cam.x = math.max( -- 4243
			room.minX + halfW, -- 4243
			math.min(room.maxX - halfW, self.cam.x) -- 4243
		) -- 4243
	end -- 4243
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4246
	local spanY = room.height -- 4247
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4248
	if spanY <= halfH * 2 then -- 4248
		self.cam.y = camY -- 4250
	else -- 4250
		self.cam.y = math.max( -- 4252
			camY, -- 4252
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4252
		) -- 4252
	end -- 4252
end -- 4236
function Play.prototype.flashSet(self, text, t) -- 4256
	self.flash = text -- 4257
	self.flashT = t -- 4258
end -- 4256
function Play.prototype.statusText(self) -- 4262
	local p = self.player -- 4263
	local parts = {} -- 4264
	local who = self.childMode and "小满" or "周戍" -- 4265
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4266
	if self.room.key == "prologue" then -- 4266
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4269
		if self.phase == "prologue-wait" then -- 4269
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4271
		elseif self.phase == "prologue-give" then -- 4271
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4273
		else -- 4273
			parts[#parts + 1] = "跟随" -- 4275
		end -- 4275
		if self.paused then -- 4275
			parts[#parts + 1] = "已暂停" -- 4278
		end -- 4278
		return table.concat(parts, " · ") -- 4280
	end -- 4280
	if self.room.key == "street" then -- 4280
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4283
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4284
		if self.paused then -- 4284
			parts[#parts + 1] = "已暂停" -- 4286
		end -- 4286
		return table.concat(parts, " · ") -- 4288
	end -- 4288
	if self.room.key == "gate" then -- 4288
		local ____temp_60 -- 4291
		if self.room.story == nil then -- 4291
			____temp_60 = nil -- 4291
		else -- 4291
			____temp_60 = self.room.story.gate -- 4291
		end -- 4291
		local g = ____temp_60 -- 4291
		if g ~= nil then -- 4291
			parts[#parts + 1] = self:gateLabel() -- 4293
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4294
				0, -- 4295
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4295
			))) .. " 秒" -- 4295
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4296
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4297
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4298
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4299
			if self.gateFailCount > 0 then -- 4299
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4301
			end -- 4301
			if self.flash ~= "" then -- 4301
				parts[#parts + 1] = self.flash -- 4304
			end -- 4304
		end -- 4304
		if self.paused then -- 4304
			parts[#parts + 1] = "已暂停" -- 4308
		end -- 4308
		return table.concat(parts, " · ") -- 4310
	end -- 4310
	if self.room.key == "forest" then -- 4310
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4313
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4314
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4315
		if self.caughtT > 0 then -- 4315
			parts[#parts + 1] = "复位中" -- 4317
		end -- 4317
		if self.paused then -- 4317
			parts[#parts + 1] = "已暂停" -- 4320
		end -- 4320
		return table.concat(parts, " · ") -- 4322
	end -- 4322
	if self.room.key == "tower" then -- 4322
		if self.phase == "tower-wait" then -- 4322
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4326
		elseif self.phase == "tower-knock" then -- 4326
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4328
		elseif self.phase == "tower-given" then -- 4328
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4330
		else -- 4330
			parts[#parts + 1] = "片尾" -- 4332
		end -- 4332
		if self.paused then -- 4332
			parts[#parts + 1] = "已暂停" -- 4335
		end -- 4335
		return table.concat(parts, " · ") -- 4337
	end -- 4337
	if self.room.key == "village" then -- 4337
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4340
		if self.hasBottle then -- 4340
			parts[#parts + 1] = "有瓶" -- 4342
		elseif self.bottleFly ~= nil then -- 4342
			parts[#parts + 1] = "瓶在飞" -- 4344
		else -- 4344
			parts[#parts + 1] = "空手" -- 4346
		end -- 4346
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4348
		if self.scavChase then -- 4348
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4350
		end -- 4350
		if self.passed then -- 4350
			parts[#parts + 1] = "已过通行线" -- 4353
		end -- 4353
		if self.paused then -- 4353
			parts[#parts + 1] = "已暂停" -- 4356
		end -- 4356
		return table.concat(parts, " · ") -- 4358
	end -- 4358
	local isChild = self.childMode -- 4361
	if isChild then -- 4361
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4363
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4364
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4365
	else -- 4365
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4367
		if p.rollT > 0 then -- 4367
			parts[#parts + 1] = "翻滚中" -- 4369
		end -- 4369
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4371
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4372
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4373
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4374
	end -- 4374
	if self.checkpoint >= 0 then -- 4374
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4377
	end -- 4377
	if self.paused then -- 4377
		parts[#parts + 1] = "已暂停" -- 4380
	end -- 4380
	return table.concat(parts, " · ") -- 4382
end -- 4262
function Play.prototype.aliveEnemies(self) -- 4386
	local n = 0 -- 4387
	local i = 0 -- 4388
	do -- 4388
		i = 0 -- 4389
		while i < #self.enemies do -- 4389
			if self.enemies[i + 1].alive then -- 4389
				n = n + 1 -- 4391
			end -- 4391
			i = i + 1 -- 4389
		end -- 4389
	end -- 4389
	return n -- 4394
end -- 4386
function Play.prototype.threatened(self) -- 4399
	do -- 4399
		local i = 0 -- 4400
		while i < #self.enemies do -- 4400
			local e = self.enemies[i + 1] -- 4401
			if e.alive and e.warnT > 0 then -- 4401
				return true -- 4403
			end -- 4403
			i = i + 1 -- 4400
		end -- 4400
	end -- 4400
	return false -- 4406
end -- 4399
function Play.prototype.gateSecondsLeft(self) -- 4409
	local ____temp_61 -- 4410
	if self.room.story == nil then -- 4410
		____temp_61 = nil -- 4410
	else -- 4410
		____temp_61 = self.room.story.gate -- 4410
	end -- 4410
	local g = ____temp_61 -- 4410
	if g == nil then -- 4410
		return 0 -- 4412
	end -- 4412
	return math.max( -- 4414
		0, -- 4414
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4414
	) -- 4414
end -- 4409
function Play.prototype.gateLabel(self) -- 4417
	if self.phase == "gate-idle" then -- 4417
		return "待就位" -- 4419
	end -- 4419
	if self.phase == "gate-hold" then -- 4419
		return "守点中" -- 4422
	end -- 4422
	if self.phase == "gate-send" then -- 4422
		return "送别" -- 4425
	end -- 4425
	if self.phase == "gate-count" then -- 4425
		return "数数 " .. tostring(self.countTick) -- 4428
	end -- 4428
	return "她走" -- 4430
end -- 4417
function Play.prototype.dogLabel(self) -- 4434
	if self.dogState == "ear" then -- 4434
		return "转耳" -- 4436
	end -- 4436
	if self.dogState == "chase" then -- 4436
		return "追" -- 4439
	end -- 4439
	if self.dogState == "sniff" then -- 4439
		return "停" -- 4442
	end -- 4442
	if self.dogState == "back" then -- 4442
		return "回线" -- 4445
	end -- 4445
	return "巡逻" -- 4447
end -- 4434
function Play.prototype.doorXOf(self) -- 4450
	local ____temp_62 -- 4451
	if self.room.story == nil then -- 4451
		____temp_62 = nil -- 4451
	else -- 4451
		____temp_62 = self.room.story.tower -- 4451
	end -- 4451
	local t = ____temp_62 -- 4451
	return t == nil and 0 or t.doorX -- 4452
end -- 4450
function Play.prototype.scavLabel(self) -- 4456
	if self.scavState == "chase" then -- 4456
		return "追" -- 4458
	end -- 4458
	if self.scavState == "turn" then -- 4458
		return "转头" -- 4461
	end -- 4461
	if self.scavState == "walk" then -- 4461
		return "赶来" -- 4464
	end -- 4464
	if self.scavState == "stall" then -- 4464
		return "停住" -- 4467
	end -- 4467
	if self.scavState == "back" then -- 4467
		return "回位" -- 4470
	end -- 4470
	return "巡逻" -- 4472
end -- 4456
function Play.prototype.hintText(self) -- 4476
	if self.paused then -- 4476
		return "Esc 继续 · R 重置" -- 4478
	end -- 4478
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4478
		if self:threatened() then -- 4478
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4484
		end -- 4484
		if self.coverHug then -- 4484
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4487
		end -- 4487
		if self.coverNear then -- 4487
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4490
		end -- 4490
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4492
	end -- 4492
	if self.flash ~= "" then -- 4492
		return self.flash -- 4495
	end -- 4495
	if self.room.key == "prologue" then -- 4495
		if self.phase == "prologue-wait" then -- 4495
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4499
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4500
		end -- 4500
		if self.phase == "prologue-give" then -- 4500
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4503
		end -- 4503
		return "她跟着你了 · 两人一起走到门口 680" -- 4505
	end -- 4505
	if self.room.key == "street" then -- 4505
		if self:aliveEnemies() > 0 then -- 4505
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4509
		end -- 4509
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4511
	end -- 4511
	if self.room.key == "gate" then -- 4511
		local ____temp_63 -- 4514
		if self.room.story == nil then -- 4514
			____temp_63 = nil -- 4514
		else -- 4514
			____temp_63 = self.room.story.gate -- 4514
		end -- 4514
		local g = ____temp_63 -- 4514
		if g ~= nil then -- 4514
			if self.phase == "gate-idle" then -- 4514
				if self.gateNeedConfirm then -- 4514
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4518
				end -- 4518
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4520
			end -- 4520
			if self.phase == "gate-hold" then -- 4520
				if self.coveredFlash > 0 then -- 4520
					return "掩体挡下了这一枪 · 别露头" -- 4524
				end -- 4524
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4526
			end -- 4526
			if self.phase == "gate-send" then -- 4526
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4529
			end -- 4529
			if self.phase == "gate-count" then -- 4529
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4529
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4533
				end -- 4533
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4535
			end -- 4535
			return "她自己走 · 跟着出城门 1120" -- 4537
		end -- 4537
	end -- 4537
	if self.room.key == "forest" then -- 4537
		if self.dogState == "chase" then -- 4537
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4542
		end -- 4542
		if self.dogState == "ear" then -- 4542
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4545
		end -- 4545
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4547
	end -- 4547
	if self.room.key == "tower" then -- 4547
		if self.phase == "tower-wait" then -- 4547
			return "走到门前 445 点一次 E 敲两下" -- 4551
		end -- 4551
		if self.phase == "tower-knock" then -- 4551
			return "敲两下 · 等门开" -- 4554
		end -- 4554
		if self.phase == "tower-given" then -- 4554
			return "递交针套和纸条 · 看登记簿最后一行" -- 4557
		end -- 4557
		return "片尾 · 点 E 再玩一次，回到序章" -- 4559
	end -- 4559
	if self.room.key == "village" then -- 4559
		if self.bottleFly ~= nil then -- 4559
			return "等瓶子落地 · 触地才发声" -- 4563
		end -- 4563
		if self.hasBottle then -- 4563
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4566
		end -- 4566
		if self.passed then -- 4566
			return "已过第一院 · R 重置可再来一遍" -- 4569
		end -- 4569
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4571
	end -- 4571
	if self.room.key == "outside" then -- 4571
		if self.focusCart then -- 4571
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4575
		end -- 4575
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4577
	end -- 4577
	if self.escort.state == "frozen" then -- 4577
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4577
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4581
		end -- 4581
		return "小满吓住了 · 走过去，靠近再点 E" -- 4583
	end -- 4583
	if self.escort.state == "calming" then -- 4583
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4586
	end -- 4586
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4588
end -- 4476
function Play.prototype.draw(self, draw, w, h) -- 4593
	self.viewW = w -- 4594
	self.viewH = h -- 4595
	self.view = ____exports.computeViewport(w, h) -- 4596
	self:clampCamera(w, h) -- 4597
	draw:clear() -- 4598
	draw:drawRect( -- 4600
		Rect(0, 0, w, h), -- 4600
		BG_VOID -- 4600
	) -- 4600
	local box = self:canvasRect(w, h) -- 4601
	draw:drawRect(box, BG_FAR) -- 4602
	draw:drawRect( -- 4603
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4603
		BG_MID -- 4603
	) -- 4603
	self:drawFloors(draw, w, h) -- 4605
	self:drawSolids(draw, w, h) -- 4606
	self:drawZones(draw, w, h) -- 4607
	self:drawArch(draw, w, h) -- 4608
	self:drawCart(draw, w, h) -- 4609
	self:drawCampaignProps(draw, w, h) -- 4610
	self:drawActors(draw, w, h) -- 4611
	self:drawTrace(draw, w, h) -- 4612
	self:drawAim(draw, w, h) -- 4613
end -- 4593
function Play.prototype.canvasRect(self, w, h) -- 4617
	local v = self.view -- 4618
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4619
end -- 4617
function Play.prototype.px(self, n) -- 4623
	return n * self.view.zoom -- 4624
end -- 4623
function Play.prototype.sx(self, wx, w) -- 4628
	local v = self.view -- 4629
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4630
	return v.ox + lx * v.zoom -- 4631
end -- 4628
function Play.prototype.sy(self, wy, h) -- 4635
	local v = self.view -- 4636
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4637
	return v.oy + ly * v.zoom -- 4638
end -- 4635
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4641
	local px0 = self:sx(x0, w) -- 4642
	local px1 = self:sx(x1, w) -- 4643
	local py0 = self:sy(y0, h) -- 4644
	local py1 = self:sy(y1, h) -- 4645
	if px1 <= px0 or py1 <= py0 then -- 4645
		return -- 4647
	end -- 4647
	draw:drawRect( -- 4649
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4649
		color -- 4649
	) -- 4649
end -- 4641
function Play.prototype.drawFloors(self, draw, w, h) -- 4652
	local i = 0 -- 4653
	do -- 4653
		i = 0 -- 4654
		while i < #self.room.floors do -- 4654
			local f = self.room.floors[i + 1] -- 4655
			local ____temp_64 -- 4656
			if f.y == 0 then -- 4656
				____temp_64 = self.room.depth -- 4656
			else -- 4656
				____temp_64 = nil -- 4656
			end -- 4656
			local road = ____temp_64 -- 4656
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4657
			local x0 = self:sx(f.x0, w) -- 4658
			local x1 = self:sx(f.x1, w) -- 4659
			local deck = self:px(5) -- 4660
			if road ~= nil then -- 4660
				local back = self:sy(f.y + road.max, h) -- 4662
				draw:drawRect( -- 4663
					Rect(x0, y, x1 - x0, back - y), -- 4663
					FLOOR_DECK, -- 4663
					self:px(1), -- 4663
					SOLID_EDGE -- 4663
				) -- 4663
			end -- 4663
			draw:drawRect( -- 4665
				Rect(x0, y - deck, x1 - x0, deck), -- 4665
				FLOOR_DECK -- 4665
			) -- 4665
			draw:drawSegment( -- 4666
				Vec2(x0, y), -- 4666
				Vec2(x1, y), -- 4666
				self:px(1), -- 4666
				GROUND -- 4666
			) -- 4666
			i = i + 1 -- 4654
		end -- 4654
	end -- 4654
end -- 4652
function Play.prototype.drawSolids(self, draw, w, h) -- 4670
	local i = 0 -- 4671
	do -- 4671
		i = 0 -- 4672
		while i < #self.boxes do -- 4672
			do -- 4672
				local b = self.boxes[i + 1] -- 4673
				if b.id == "braced_shield" or b.hidden == true then -- 4673
					goto __continue859 -- 4675
				end -- 4675
				if b.broken == true then -- 4675
					if b.breakable ~= nil then -- 4675
						local gy = self:sy(b.y0, h) -- 4680
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4681
						local k = 0 -- 4682
						do -- 4682
							k = 0 -- 4683
							while k < 3 do -- 4683
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4684
								draw:drawSegment( -- 4685
									Vec2( -- 4685
										gx - self:px(4), -- 4685
										gy + self:px(k % 2) -- 4685
									), -- 4685
									Vec2( -- 4685
										gx + self:px(5), -- 4685
										gy + self:px(k % 2) -- 4685
									), -- 4685
									self:px(1), -- 4685
									rgb -- 4685
								) -- 4685
								k = k + 1 -- 4683
							end -- 4683
						end -- 4683
					end -- 4683
					goto __continue859 -- 4688
				end -- 4688
				local ____opt_67 = b.depth -- 4688
				local front = ____opt_67 and ____opt_67.min or 0 -- 4690
				local ____opt_69 = b.depth -- 4690
				local back = ____opt_69 and ____opt_69.max or 0 -- 4691
				local fill = SOLID_FILL -- 4692
				local line = SOLID_EDGE -- 4693
				if b.soft == true then -- 4693
					fill = SOFT -- 4695
					line = SOFT_LINE -- 4696
				elseif b.breakable ~= nil then -- 4696
					line = DANGER_LINE -- 4698
					fill = Color(0.3, 0.24, 0.16, 1) -- 4699
				elseif b.interact ~= nil then -- 4699
					line = PASS_LINE -- 4701
				end -- 4701
				self:drawBox( -- 4703
					draw, -- 4703
					w, -- 4703
					h, -- 4703
					b.x0, -- 4703
					b.x1, -- 4703
					b.y0 + front, -- 4703
					b.y1 + back, -- 4703
					fill -- 4703
				) -- 4703
				draw:drawSegment( -- 4704
					Vec2( -- 4704
						self:sx(b.x0, w), -- 4704
						self:sy(b.y1 + front, h) -- 4704
					), -- 4704
					Vec2( -- 4705
						self:sx(b.x1, w), -- 4705
						self:sy(b.y1 + front, h) -- 4705
					), -- 4705
					self:px(1), -- 4705
					line -- 4705
				) -- 4705
				if b.breakable ~= nil then -- 4705
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4708
					local cyp = self:sy(b.y1 + front, h) -- 4709
					draw:drawSegment( -- 4710
						Vec2( -- 4710
							cxp - self:px(4), -- 4710
							cyp + self:px(1) -- 4710
						), -- 4710
						Vec2( -- 4710
							cxp + self:px(3), -- 4710
							cyp + self:px(5) -- 4710
						), -- 4710
						self:px(1), -- 4710
						line -- 4710
					) -- 4710
				end -- 4710
			end -- 4710
			::__continue859:: -- 4710
			i = i + 1 -- 4672
		end -- 4672
	end -- 4672
end -- 4670
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4716
	local i = 0 -- 4717
	do -- 4717
		i = 0 -- 4718
		while i < #self.pickups do -- 4718
			do -- 4718
				local pk = self.pickups[i + 1] -- 4719
				if pk.id == "" then -- 4719
					goto __continue871 -- 4721
				end -- 4721
				local gy = pk.y + (pk.depth or 0) -- 4723
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4724
				draw:drawRect( -- 4725
					Rect( -- 4725
						self:sx(pk.x - 5, w), -- 4725
						self:sy(gy + 12 + bob, h), -- 4725
						self:px(10), -- 4725
						self:px(10) -- 4725
					), -- 4725
					Color(0.84, 0.7, 0.3, 1) -- 4726
				) -- 4726
				draw:drawSegment( -- 4727
					Vec2( -- 4727
						self:sx(pk.x - 5, w), -- 4727
						self:sy(gy + 12 + bob, h) -- 4727
					), -- 4727
					Vec2( -- 4728
						self:sx(pk.x + 5, w), -- 4728
						self:sy(gy + 12 + bob, h) -- 4728
					), -- 4728
					self:px(1), -- 4728
					Color(0.95, 0.86, 0.52, 1) -- 4728
				) -- 4728
			end -- 4728
			::__continue871:: -- 4728
			i = i + 1 -- 4718
		end -- 4718
	end -- 4718
	if self.bracedShield ~= nil then -- 4718
		local sh = self.bracedShield -- 4731
		draw:drawRect( -- 4732
			Rect( -- 4732
				self:sx(sh.x - sh.w / 2, w), -- 4732
				self:sy(sh.y, h), -- 4732
				self:px(sh.w), -- 4732
				self:px(sh.h) -- 4732
			), -- 4732
			Color(0.42, 0.4, 0.34, 1) -- 4733
		) -- 4733
		draw:drawSegment( -- 4734
			Vec2( -- 4734
				self:sx(sh.x - sh.w / 2, w), -- 4734
				self:sy(sh.y + sh.h, h) -- 4734
			), -- 4734
			Vec2( -- 4735
				self:sx(sh.x + sh.w / 2, w), -- 4735
				self:sy(sh.y + sh.h, h) -- 4735
			), -- 4735
			self:px(1), -- 4735
			Color(0.74, 0.72, 0.62, 1) -- 4735
		) -- 4735
	end -- 4735
end -- 4716
function Play.prototype.drawZones(self, draw, w, h) -- 4739
	local i = 0 -- 4740
	do -- 4740
		i = 0 -- 4741
		while i < #self.room.zones do -- 4741
			local z = self.room.zones[i + 1] -- 4742
			local fill = DANGER -- 4743
			local line = DANGER_LINE -- 4744
			if z.tint == 2 then -- 4744
				fill = SOFT -- 4746
				line = SOFT_LINE -- 4747
			elseif z.tint == 3 then -- 4747
				fill = BRICK -- 4749
				line = BRICK_LINE -- 4750
			elseif z.tint == 4 then -- 4750
				fill = PASS -- 4752
				line = PASS_LINE -- 4753
			end -- 4753
			self:drawBox( -- 4755
				draw, -- 4755
				w, -- 4755
				h, -- 4755
				z.x0, -- 4755
				z.x1, -- 4755
				z.y, -- 4755
				z.y + z.h, -- 4755
				fill -- 4755
			) -- 4755
			draw:drawSegment( -- 4756
				Vec2( -- 4756
					self:sx(z.x0, w), -- 4756
					self:sy(z.y, h) -- 4756
				), -- 4756
				Vec2( -- 4756
					self:sx(z.x0, w), -- 4756
					self:sy(z.y + z.h, h) -- 4756
				), -- 4756
				self:px(1), -- 4756
				line -- 4756
			) -- 4756
			draw:drawSegment( -- 4757
				Vec2( -- 4757
					self:sx(z.x1, w), -- 4757
					self:sy(z.y, h) -- 4757
				), -- 4757
				Vec2( -- 4757
					self:sx(z.x1, w), -- 4757
					self:sy(z.y + z.h, h) -- 4757
				), -- 4757
				self:px(1), -- 4757
				line -- 4757
			) -- 4757
			i = i + 1 -- 4741
		end -- 4741
	end -- 4741
end -- 4739
function Play.prototype.drawArch(self, draw, w, h) -- 4761
	local a = self.room.arch -- 4762
	if a.h <= 0 then -- 4762
		return -- 4764
	end -- 4764
	self:drawBox( -- 4766
		draw, -- 4766
		w, -- 4766
		h, -- 4766
		a.x0, -- 4766
		a.x1, -- 4766
		a.y, -- 4766
		a.y + a.h, -- 4766
		HOLE_FILL -- 4766
	) -- 4766
	draw:drawSegment( -- 4767
		Vec2( -- 4767
			self:sx(a.x0, w), -- 4767
			self:sy(a.y + a.h, h) -- 4767
		), -- 4767
		Vec2( -- 4767
			self:sx(a.x1, w), -- 4767
			self:sy(a.y + a.h, h) -- 4767
		), -- 4767
		self:px(1), -- 4767
		SOLID_EDGE -- 4767
	) -- 4767
	draw:drawSegment( -- 4768
		Vec2( -- 4768
			self:sx(a.x0, w), -- 4768
			self:sy(a.y, h) -- 4768
		), -- 4768
		Vec2( -- 4768
			self:sx(a.x0, w), -- 4768
			self:sy(a.y + a.h, h) -- 4768
		), -- 4768
		self:px(1), -- 4768
		SOLID_EDGE -- 4768
	) -- 4768
	draw:drawSegment( -- 4769
		Vec2( -- 4769
			self:sx(a.x1, w), -- 4769
			self:sy(a.y, h) -- 4769
		), -- 4769
		Vec2( -- 4769
			self:sx(a.x1, w), -- 4769
			self:sy(a.y + a.h, h) -- 4769
		), -- 4769
		self:px(1), -- 4769
		SOLID_EDGE -- 4769
	) -- 4769
end -- 4761
function Play.prototype.drawCart(self, draw, w, h) -- 4772
	local c = self.room.cart -- 4773
	if c.bodyW <= 0 then -- 4773
		return -- 4775
	end -- 4775
	drawCartShape( -- 4777
		draw, -- 4777
		self, -- 4777
		w, -- 4777
		h, -- 4777
		c, -- 4777
		self.cartAxle -- 4777
	) -- 4777
	draw:drawRect( -- 4778
		Rect( -- 4778
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4778
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4778
			self:px(2), -- 4778
			self:px(40) -- 4778
		), -- 4778
		STAND -- 4778
	) -- 4778
end -- 4772
function Play.prototype.drawActors(self, draw, w, h) -- 4781
	local p = self.player -- 4782
	local isChild = self.childMode -- 4783
	local footY = p.y + p.depth -- 4784
	if p.covered then -- 4784
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4787
		draw:drawSegment( -- 4788
			Vec2( -- 4788
				self:sx(edge, w), -- 4788
				self:sy(footY + 8, h) -- 4788
			), -- 4788
			Vec2( -- 4788
				self:sx(edge, w), -- 4788
				self:sy(footY + p.h * 0.62, h) -- 4788
			), -- 4788
			self:px(2), -- 4788
			STAND -- 4788
		) -- 4788
		draw:drawSegment( -- 4790
			Vec2( -- 4790
				self:sx(p.x - 8, w), -- 4790
				self:sy(footY + p.h + 3, h) -- 4790
			), -- 4790
			Vec2( -- 4790
				self:sx(p.x + 8, w), -- 4790
				self:sy(footY + p.h + 3, h) -- 4790
			), -- 4790
			self:px(2), -- 4790
			STAND -- 4790
		) -- 4790
	elseif self.coverNear and not isChild then -- 4790
		draw:drawRect( -- 4793
			Rect( -- 4793
				self:sx(p.x - 3, w), -- 4793
				self:sy(footY + 1, h), -- 4793
				self:px(3), -- 4793
				self:px(3) -- 4793
			), -- 4793
			STAND -- 4793
		) -- 4793
	end -- 4793
	drawFigure( -- 4795
		draw, -- 4795
		self, -- 4795
		w, -- 4795
		h, -- 4795
		p, -- 4795
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4795
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4795
	) -- 4795
	local q = self.partner -- 4796
	if q.alive then -- 4796
		local childPartner = q.w == CHILD_W -- 4798
		drawFigure( -- 4799
			draw, -- 4799
			self, -- 4799
			w, -- 4799
			h, -- 4799
			q, -- 4799
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4799
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4799
		) -- 4799
	end -- 4799
	local i = 0 -- 4801
	do -- 4801
		i = 0 -- 4802
		while i < #self.enemies do -- 4802
			local e = self.enemies[i + 1] -- 4803
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4804
			local enemyY = e.y + (e.depth or 0) -- 4805
			self:drawBox( -- 4806
				draw, -- 4806
				w, -- 4806
				h, -- 4806
				e.x - e.w / 2, -- 4806
				e.x + e.w / 2, -- 4806
				enemyY, -- 4806
				enemyY + e.h, -- 4806
				col -- 4806
			) -- 4806
			if e.alive then -- 4806
				local ef = p.x >= e.x and 1 or -1 -- 4808
				if e.kind == "shield" then -- 4808
					local sh = (e.shieldHp or 0) > 0 -- 4810
					draw:drawRect( -- 4811
						Rect( -- 4811
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4811
							self:sy(enemyY, h), -- 4811
							self:px(6), -- 4811
							self:px(64) -- 4811
						), -- 4811
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4812
					) -- 4812
				elseif e.kind == "breaker" then -- 4812
					draw:drawSegment( -- 4814
						Vec2( -- 4814
							self:sx(e.x + ef * 12, w), -- 4814
							self:sy(enemyY + 8, h) -- 4814
						), -- 4814
						Vec2( -- 4815
							self:sx(e.x + ef * 22, w), -- 4815
							self:sy(enemyY + 46, h) -- 4815
						), -- 4815
						self:px(3), -- 4815
						Color(0.5, 0.36, 0.22, 1) -- 4815
					) -- 4815
				end -- 4815
			end -- 4815
			if e.alive and e.warnT > 0 then -- 4815
				local gunX = self:sx(e.x, w) -- 4820
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4821
				local aimX = self:sx(p.x, w) -- 4822
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4823
				local seg = 8 -- 4824
				local s = 0 -- 4825
				do -- 4825
					s = 0 -- 4826
					while s < seg do -- 4826
						local t0 = s / seg -- 4827
						local t1 = (s + 1) / seg -- 4828
						draw:drawSegment( -- 4829
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4830
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4831
							self:px(1), -- 4832
							DANGER -- 4832
						) -- 4832
						s = s + 2 -- 4826
					end -- 4826
				end -- 4826
			end -- 4826
			i = i + 1 -- 4802
		end -- 4802
	end -- 4802
	local k = 0 -- 4837
	do -- 4837
		k = 0 -- 4838
		while k < #self.room.marks do -- 4838
			do -- 4838
				local m = self.room.marks[k + 1] -- 4839
				if m.kind ~= 0 then -- 4839
					goto __continue897 -- 4841
				end -- 4841
				local on = self.checkpoint == m.x -- 4843
				local x = self:sx(m.x, w) -- 4844
				local y = self:sy(m.y, h) -- 4845
				draw:drawSegment( -- 4846
					Vec2(x, y), -- 4846
					Vec2( -- 4846
						x, -- 4846
						y + self:px(35) -- 4846
					), -- 4846
					self:px(1), -- 4846
					on and CHECK or INK_DIM -- 4846
				) -- 4846
				draw:drawDot( -- 4847
					Vec2( -- 4847
						x, -- 4847
						y + self:px(35) -- 4847
					), -- 4847
					self:px(2), -- 4847
					on and CHECK or INK_DIM -- 4847
				) -- 4847
			end -- 4847
			::__continue897:: -- 4847
			k = k + 1 -- 4838
		end -- 4838
	end -- 4838
	local j = 0 -- 4851
	do -- 4851
		j = 0 -- 4852
		while j < #self.room.marks do -- 4852
			do -- 4852
				local m = self.room.marks[j + 1] -- 4853
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4853
					goto __continue900 -- 4855
				end -- 4855
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4855
					goto __continue900 -- 4859
				end -- 4859
				local col = STAND -- 4861
				if m.kind == 4 then -- 4861
					col = PASS_LINE -- 4863
				elseif m.kind == 5 then -- 4863
					col = BRICK_LINE -- 4865
				end -- 4865
				local mx = self:sx(m.x, w) -- 4867
				local my = self:sy(m.y, h) -- 4868
				draw:drawSegment( -- 4869
					Vec2(mx, my), -- 4869
					Vec2( -- 4869
						mx, -- 4869
						my + self:px(24) -- 4869
					), -- 4869
					self:px(1), -- 4869
					col -- 4869
				) -- 4869
			end -- 4869
			::__continue900:: -- 4869
			j = j + 1 -- 4852
		end -- 4852
	end -- 4852
	local t = 0 -- 4872
	do -- 4872
		t = 0 -- 4873
		while t < #self.room.marks do -- 4873
			do -- 4873
				local m = self.room.marks[t + 1] -- 4874
				if m.kind ~= 6 then -- 4874
					goto __continue906 -- 4876
				end -- 4876
				local mx = self:sx(m.x, w) -- 4878
				local my = self:sy(m.y, h) -- 4879
				draw:drawSegment( -- 4880
					Vec2(mx, my), -- 4880
					Vec2( -- 4880
						mx, -- 4880
						my + self:px(30) -- 4880
					), -- 4880
					self:px(1), -- 4880
					INK_DIM -- 4880
				) -- 4880
				self:drawBox( -- 4881
					draw, -- 4881
					w, -- 4881
					h, -- 4881
					m.x - 5, -- 4881
					m.x + 5, -- 4881
					m.y + 30, -- 4881
					m.y + 40, -- 4881
					CHECK -- 4881
				) -- 4881
			end -- 4881
			::__continue906:: -- 4881
			t = t + 1 -- 4873
		end -- 4873
	end -- 4873
	if self.room.key == "village" then -- 4873
		self:drawVillage(draw, w, h) -- 4884
	end -- 4884
	if self.room.key == "forest" then -- 4884
		self:drawDog(draw, w, h) -- 4887
	end -- 4887
end -- 4781
function Play.prototype.drawDog(self, draw, w, h) -- 4892
	local x = self.dogX -- 4893
	self:drawBox( -- 4894
		draw, -- 4894
		w, -- 4894
		h, -- 4894
		x - 14, -- 4894
		x + 14, -- 4894
		0, -- 4894
		20, -- 4894
		SCAV_BODY -- 4894
	) -- 4894
	self:drawBox( -- 4895
		draw, -- 4895
		w, -- 4895
		h, -- 4895
		x - 10, -- 4895
		x - 2, -- 4895
		20, -- 4895
		30, -- 4895
		SCAV_BODY -- 4895
	) -- 4895
	self:drawBox( -- 4896
		draw, -- 4896
		w, -- 4896
		h, -- 4896
		x + 2, -- 4896
		x + 10, -- 4896
		20, -- 4896
		30, -- 4896
		SCAV_HEAD -- 4896
	) -- 4896
	if self.dogState == "ear" or self.dogState == "chase" then -- 4896
		draw:drawSegment( -- 4898
			Vec2( -- 4898
				self:sx(x, w), -- 4898
				self:sy(30, h) -- 4898
			), -- 4898
			Vec2( -- 4899
				self:sx(x, w), -- 4899
				self:sy(40, h) -- 4899
			), -- 4899
			self:px(1), -- 4899
			DANGER -- 4899
		) -- 4899
	end -- 4899
end -- 4892
function Play.prototype.drawVillage(self, draw, w, h) -- 4904
	local bottle = self.room.bottle -- 4905
	if bottle ~= nil then -- 4905
		self:drawBox( -- 4907
			draw, -- 4907
			w, -- 4907
			h, -- 4907
			bottle.x - 14, -- 4907
			bottle.x + 14, -- 4907
			0, -- 4907
			64, -- 4907
			SOLID_FILL -- 4907
		) -- 4907
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4907
			self:drawBottle( -- 4909
				draw, -- 4909
				w, -- 4909
				h, -- 4909
				bottle.x, -- 4909
				64 -- 4909
			) -- 4909
		end -- 4909
	end -- 4909
	self:drawBox( -- 4913
		draw, -- 4913
		w, -- 4913
		h, -- 4913
		300, -- 4913
		420, -- 4913
		44, -- 4913
		50, -- 4913
		FLOOR_DECK -- 4913
	) -- 4913
	self:drawBox( -- 4914
		draw, -- 4914
		w, -- 4914
		h, -- 4914
		300, -- 4914
		306, -- 4914
		0, -- 4914
		44, -- 4914
		FLOOR_DECK -- 4914
	) -- 4914
	self:drawBox( -- 4915
		draw, -- 4915
		w, -- 4915
		h, -- 4915
		414, -- 4915
		420, -- 4915
		0, -- 4915
		44, -- 4915
		FLOOR_DECK -- 4915
	) -- 4915
	local s = self.room.scavenger -- 4917
	if s ~= nil then -- 4917
		local sx0 = self.scavX -- 4919
		self:drawBox( -- 4920
			draw, -- 4920
			w, -- 4920
			h, -- 4920
			sx0 - 12, -- 4920
			sx0 + 12, -- 4920
			0, -- 4920
			s.h - 14, -- 4920
			SCAV_BODY -- 4920
		) -- 4920
		self:drawBox( -- 4921
			draw, -- 4921
			w, -- 4921
			h, -- 4921
			sx0 - 7, -- 4921
			sx0 + 7, -- 4921
			s.h - 14, -- 4921
			s.h, -- 4921
			SCAV_HEAD -- 4921
		) -- 4921
		if self.scavState == "turn" then -- 4921
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4923
			draw:drawSegment( -- 4924
				Vec2( -- 4924
					self:sx(sx0, w), -- 4924
					self:sy(s.h - 6, h) -- 4924
				), -- 4924
				Vec2( -- 4924
					self:sx(fx, w), -- 4924
					self:sy(s.h - 6, h) -- 4924
				), -- 4924
				self:px(1), -- 4924
				INK -- 4924
			) -- 4924
		end -- 4924
	end -- 4924
	if self.hasBottle then -- 4924
		local p = self.player -- 4929
		self:drawBottle( -- 4930
			draw, -- 4930
			w, -- 4930
			h, -- 4930
			p.x + p.facing * 10, -- 4930
			p.y + p.h * 0.62 -- 4930
		) -- 4930
	end -- 4930
	if self.bottleFly ~= nil then -- 4930
		self:drawBottle( -- 4933
			draw, -- 4933
			w, -- 4933
			h, -- 4933
			self.bottleFly.x, -- 4933
			self.bottleFly.y -- 4933
		) -- 4933
	end -- 4933
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 4933
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 4936
		draw:drawCircle( -- 4937
			Vec2( -- 4937
				self:sx(self.bottleLandX, w), -- 4937
				self:sy(0, h) -- 4937
			), -- 4937
			self:px(r / ____exports.UNITS_PER_PX), -- 4937
			BRICK_LINE -- 4937
		) -- 4937
	end -- 4937
end -- 4904
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 4941
	self:drawBox( -- 4942
		draw, -- 4942
		w, -- 4942
		h, -- 4942
		x - 3, -- 4942
		x + 3, -- 4942
		y - 10, -- 4942
		y, -- 4942
		BOTTLE -- 4942
	) -- 4942
end -- 4941
function Play.prototype.drawTrace(self, draw, w, h) -- 4945
	local t = self.trace -- 4946
	if t == nil or self.traceT <= 0 then -- 4946
		return -- 4948
	end -- 4948
	draw:drawSegment( -- 4950
		Vec2( -- 4951
			self:sx(t.x0, w), -- 4951
			self:sy(t.y0, h) -- 4951
		), -- 4951
		Vec2( -- 4952
			self:sx(t.x1, w), -- 4952
			self:sy(t.y1, h) -- 4952
		), -- 4952
		self:px(1), -- 4953
		t.hit and AIM_HIT or INK_DIM -- 4953
	) -- 4953
end -- 4945
function Play.prototype.drawAim(self, draw, w, h) -- 4956
	local v = self.view -- 4958
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 4959
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 4960
	local dot = self:px(1) -- 4961
	local arm = self:px(3) -- 4962
	local gap = self:px(1) -- 4963
	draw:drawSegment( -- 4964
		Vec2(gx - arm - gap, gy), -- 4964
		Vec2(gx - gap, gy), -- 4964
		dot / 2, -- 4964
		AIM -- 4964
	) -- 4964
	draw:drawSegment( -- 4965
		Vec2(gx + gap, gy), -- 4965
		Vec2(gx + arm + gap, gy), -- 4965
		dot / 2, -- 4965
		AIM -- 4965
	) -- 4965
	draw:drawSegment( -- 4966
		Vec2(gx, gy - arm - gap), -- 4966
		Vec2(gx, gy - gap), -- 4966
		dot / 2, -- 4966
		AIM -- 4966
	) -- 4966
	draw:drawSegment( -- 4967
		Vec2(gx, gy + gap), -- 4967
		Vec2(gx, gy + arm + gap), -- 4967
		dot / 2, -- 4967
		AIM -- 4967
	) -- 4967
	if self.room.key == "village" and self.hasBottle then -- 4967
		local p = self.player -- 4971
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4973
		local dir = ____end.x >= p.x and 1 or -1 -- 4974
		local x0 = p.x + dir * 10 -- 4975
		local y0 = p.y + p.h * 0.7 -- 4976
		local T = BOTTLE_FLY_TIME -- 4977
		local vx = (____end.x - x0) / T -- 4978
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 4979
		local pxr = x0 -- 4980
		local pyr = y0 -- 4981
		local t = 1 -- 4982
		do -- 4982
			t = 1 -- 4983
			while t <= 12 do -- 4983
				local tt = t / 12 * T -- 4984
				local nx = x0 + vx * tt -- 4985
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 4986
				draw:drawSegment( -- 4987
					Vec2( -- 4987
						self:sx(pxr, w), -- 4987
						self:sy(pyr, h) -- 4987
					), -- 4987
					Vec2( -- 4987
						self:sx(nx, w), -- 4987
						self:sy(ny, h) -- 4987
					), -- 4987
					self:px(1) / 2, -- 4987
					BOTTLE -- 4987
				) -- 4987
				pxr = nx -- 4988
				pyr = ny -- 4989
				t = t + 1 -- 4983
			end -- 4983
		end -- 4983
		draw:drawCircle( -- 4991
			Vec2( -- 4991
				self:sx(____end.x, w), -- 4991
				self:sy(____end.y + 2, h) -- 4991
			), -- 4991
			self:px(2), -- 4991
			BOTTLE -- 4991
		) -- 4991
	end -- 4991
end -- 4956
return ____exports -- 4956