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
function makeActor(room, index) -- 5067
	local sp = room.spawns -- 5068
	if index < 0 or index >= #sp then -- 5068
		return { -- 5070
			x = 0, -- 5070
			y = 0, -- 5070
			depth = 0, -- 5070
			depthSpeed = 0, -- 5070
			vx = 0, -- 5070
			vy = 0, -- 5070
			w = CHILD_W, -- 5070
			h = CHILD_H, -- 5070
			onGround = true, -- 5070
			facing = 1, -- 5070
			crouch = false, -- 5070
			rollT = 0, -- 5070
			covered = false, -- 5070
			alive = false -- 5070
		} -- 5070
	end -- 5070
	local s = sp[index + 1] -- 5072
	local child = s.h <= CHILD_H -- 5073
	local ground = room.depth -- 5074
	local depth = ground == nil and 0 or math.max( -- 5075
		ground.min, -- 5075
		math.min(ground.max, s.depth or 0) -- 5075
	) -- 5075
	return { -- 5076
		x = s.x, -- 5077
		y = s.y, -- 5077
		depth = depth, -- 5077
		depthSpeed = 0, -- 5077
		vx = 0, -- 5077
		vy = 0, -- 5077
		w = child and CHILD_W or SOLDIER_W, -- 5078
		h = child and CHILD_H or SOLDIER_H, -- 5079
		onGround = true, -- 5080
		facing = 1, -- 5080
		crouch = false, -- 5080
		rollT = 0, -- 5080
		covered = false, -- 5080
		alive = true -- 5080
	} -- 5080
end -- 5080
function drawFigure(draw, play, w, h, a, body, head) -- 5084
	if not a.alive then -- 5084
		return -- 5086
	end -- 5086
	local x0 = a.x - a.w / 2 -- 5088
	local x1 = a.x + a.w / 2 -- 5089
	local y0 = a.y + a.depth -- 5090
	local y1 = y0 + a.h -- 5091
	play:drawBox( -- 5092
		draw, -- 5092
		w, -- 5092
		h, -- 5092
		x0, -- 5092
		x1, -- 5092
		y0, -- 5092
		y1 - a.h * 0.26, -- 5092
		body -- 5092
	) -- 5092
	play:drawBox( -- 5093
		draw, -- 5093
		w, -- 5093
		h, -- 5093
		x0 + 2, -- 5093
		x1 - 2, -- 5093
		y1 - a.h * 0.26, -- 5093
		y1, -- 5093
		head -- 5093
	) -- 5093
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5095
	play:drawBox( -- 5096
		draw, -- 5096
		w, -- 5096
		h, -- 5096
		eyeX, -- 5096
		eyeX + 4, -- 5096
		y1 - a.h * 0.14, -- 5096
		y1 - a.h * 0.08, -- 5096
		INK -- 5096
	) -- 5096
end -- 5096
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5100
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5101
end -- 5100
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5108
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5109
end -- 5108
function rayInterval(origin, direction, min, max) -- 5116
	if direction == 0 then -- 5116
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5118
	end -- 5118
	local a = (min - origin) / direction -- 5120
	local b = (max - origin) / direction -- 5121
	return { -- 5122
		min = math.min(a, b), -- 5122
		max = math.max(a, b) -- 5122
	} -- 5122
end -- 5122
function hitBox(ray, box) -- 5126
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5127
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5128
	local enter = math.max(0, x.min, y.min) -- 5129
	local leave = math.min(99999, x.max, y.max) -- 5130
	if box.depth ~= nil then -- 5130
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5132
		enter = math.max(enter, depth.min) -- 5133
		leave = math.min(leave, depth.max) -- 5134
	end -- 5134
	return leave >= enter and enter or -1 -- 5136
end -- 5136
function drawCartShape(draw, play, w, h, c, axleX) -- 5139
	local half = c.bodyW / 2 -- 5140
	local x0 = axleX - half -- 5141
	local x1 = axleX + half -- 5142
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5143
	play:drawBox( -- 5144
		draw, -- 5144
		w, -- 5144
		h, -- 5144
		x0, -- 5144
		x1, -- 5144
		axleY, -- 5144
		axleY + c.bodyH, -- 5144
		CART_FILL -- 5144
	) -- 5144
	draw:drawCircle( -- 5145
		Vec2( -- 5145
			play:sx(x0 + c.bodyW * 0.28, w), -- 5145
			play:sy(axleY, h) -- 5145
		), -- 5145
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5145
		Color(52, 50, 48, 255) -- 5145
	) -- 5145
	draw:drawCircle( -- 5146
		Vec2( -- 5146
			play:sx(x1 - c.bodyW * 0.28, w), -- 5146
			play:sy(axleY, h) -- 5146
		), -- 5146
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5146
		Color(52, 50, 48, 255) -- 5146
	) -- 5146
	local cx = c.clothSide < 0 and x0 or x1 -- 5147
	play:drawBox( -- 5148
		draw, -- 5148
		w, -- 5148
		h, -- 5148
		cx - 10, -- 5148
		cx + 10, -- 5148
		axleY + c.bodyH, -- 5148
		axleY + c.bodyH + 18, -- 5148
		CLOTH -- 5148
	) -- 5148
end -- 5148
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
CHILD_W = 28 -- 120
CHILD_H = 64 -- 121
local CHILD_CROUCH_H = 36 -- 122
local CHILD_SPEED = 160 -- 123
local CHILD_SLOW = 80 -- 124
local CHILD_JUMP = 320 -- 125
SOLDIER_W = 30 -- 128
SOLDIER_H = 88 -- 129
local SOLDIER_SPEED = 264 -- 130
local ROLL_TIME = 0.35 -- 131
local ROLL_SPEED = 280 -- 132
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 134
local LEDGE_RISE = 60 -- 135
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 138
____exports.LOGIC_H = 180 -- 139
____exports.UNITS_PER_PX = 2 -- 140
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 142
local CAM_FOLLOW = 9 -- 143
local CAM_LOOK_UP = 46 -- 144
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 147
--- 握把触发半径。
____exports.CART_REACH = 70 -- 149
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 151
local CART_CLEAR = 44 -- 152
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 154
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 156
local CONSUMABLE_CAP = 1 -- 157
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 159
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 161
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 163
local FIRE_COOLDOWN = 150 -- 164
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 166
local ENEMY_RANGE = 760 -- 167
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 169
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 171
local DEPTH_SPEED_RATIO = 0.55 -- 172
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 173
INK = Color(232, 232, 228, 255) -- 175
local INK_DIM = Color(150, 152, 150, 255) -- 176
local BG_VOID = Color(8, 9, 10, 255) -- 177
local BG_FAR = Color(24, 26, 28, 255) -- 178
local BG_MID = Color(31, 34, 37, 255) -- 179
local GROUND = Color(112, 114, 112, 255) -- 180
local FLOOR_DECK = Color(66, 70, 72, 255) -- 181
local SOLID_FILL = Color(84, 86, 84, 255) -- 182
local SOLID_EDGE = Color(126, 130, 126, 255) -- 183
CART_FILL = Color(122, 78, 56, 255) -- 184
CLOTH = Color(178, 52, 46, 255) -- 185
local DANGER = Color(150, 54, 48, 46) -- 186
local DANGER_LINE = Color(178, 78, 64, 200) -- 187
local HOLE_FILL = Color(10, 11, 12, 255) -- 188
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 189
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 190
local CHILD_BODY = Color(214, 168, 96, 255) -- 191
local CHILD_HEAD = Color(232, 214, 186, 255) -- 192
local ENEMY_BODY = Color(176, 92, 84, 255) -- 193
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 194
local CHECK = Color(96, 186, 122, 255) -- 195
local STAND = Color(226, 186, 84, 255) -- 196
local AIM = Color(236, 236, 232, 230) -- 197
local AIM_HIT = Color(236, 96, 84, 255) -- 198
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 200
local SOFT_LINE = Color(140, 112, 80, 190) -- 201
local BRICK = Color(126, 118, 110, 70) -- 202
local BRICK_LINE = Color(160, 152, 142, 200) -- 203
local PASS = Color(96, 186, 122, 40) -- 204
local PASS_LINE = Color(96, 186, 122, 200) -- 205
local BOTTLE = Color(120, 186, 160, 255) -- 206
local SCAV_BODY = Color(128, 118, 96, 255) -- 207
local SCAV_HEAD = Color(196, 182, 158, 255) -- 208
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 295
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 296
	if zoom < 1 then -- 296
		zoom = 1 -- 298
	end -- 298
	return { -- 300
		zoom = zoom, -- 301
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 302
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 303
	} -- 303
end -- 295
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 326
	if key == "prologue" then -- 326
		return "prologue-wait" -- 328
	end -- 328
	if key == "street" then -- 328
		return "street-run" -- 331
	end -- 331
	if key == "gate" then -- 331
		return "gate-idle" -- 334
	end -- 334
	if key == "gatepath" then -- 334
		return "gatepath-start" -- 337
	end -- 337
	if key == "forest" then -- 337
		return "forest-run" -- 340
	end -- 340
	if key == "tower" then -- 340
		return "tower-wait" -- 343
	end -- 343
	return "run" -- 345
end -- 326
____exports.Play = __TS__Class() -- 348
local Play = ____exports.Play -- 348
Play.name = "Play" -- 348
function Play.prototype.____constructor(self, room, resume, run) -- 596
	self.enemies = {} -- 353
	self.boxes = {} -- 354
	self.floors = {} -- 355
	self.checkpoint = -1 -- 357
	self.flash = "" -- 359
	self.flashT = 0 -- 360
	self.traceT = 0 -- 363
	self.focusCart = false -- 365
	self.knocks = 0 -- 367
	self.knockT = 0 -- 368
	self.cartAxle = 0 -- 372
	self.cartDocked = false -- 374
	self.gripping = false -- 376
	self.gateOpen = false -- 378
	self.calmConsumed = false -- 380
	self.craftT = 0 -- 382
	self.nextDangerId = 1 -- 384
	self.wantRoom = "" -- 386
	self.carryCartAxle = -1 -- 388
	self.carryCartDocked = false -- 389
	self.checkpointCartAxle = -1 -- 391
	self.hasBottle = false -- 395
	self.bottleLandX = -1 -- 399
	self.bottleTargetX = -1 -- 400
	self.bottleTargetY = 0 -- 401
	self.bottleLandT = 0 -- 402
	self.aimHold = 0 -- 404
	self.scavX = 0 -- 406
	self.scavDir = 1 -- 407
	self.scavState = "patrol" -- 408
	self.scavT = 0 -- 409
	self.scavTargetX = 0 -- 410
	self.passed = false -- 412
	self.childMode = false -- 416
	self.phase = "" -- 418
	self.phaseTick = 0 -- 420
	self.gateTick = 0 -- 422
	self.countTick = 0 -- 424
	self.countArmed = false -- 426
	self.countPrevMove = 0 -- 428
	self.caughtT = 0 -- 430
	self.hp = 3 -- 432
	self.maxHp = 3 -- 433
	self.invulnT = 0 -- 439
	self.partnerStuck = 0 -- 441
	self.partnerLaneIdx = 0 -- 443
	self.partnerLaneHold = 0 -- 444
	self.coveredFlash = 0 -- 446
	self.coverHug = false -- 448
	self.coverNear = false -- 450
	self.coverEntity = "" -- 452
	self.coverBlocking = false -- 454
	self.gateNeedConfirm = false -- 456
	self.gateRestartArmed = true -- 458
	self.bottleAimX = -1 -- 460
	self.bottleAimY = 0 -- 461
	self.bottleSurfaceY = -1 -- 463
	self.bottleLandY = 0 -- 465
	self.events = {} -- 467
	self.eventSeq = 0 -- 469
	self.dogX = 0 -- 471
	self.dogDir = 1 -- 472
	self.dogState = "patrol" -- 473
	self.dogT = 0 -- 474
	self.dogTargetX = 0 -- 475
	self.scavSee = 0 -- 477
	self.scavChase = false -- 478
	self.gateSpawned = 0 -- 480
	self.gateFailCount = 0 -- 482
	self.isCampaign = false -- 486
	self.archiveDirty = false -- 494
	self.restartStory = false -- 496
	self.wellOpen = false -- 498
	self.wellX = 430 -- 500
	self.wellTaken = false -- 502
	self.endingLines = {"", ""} -- 504
	self.equippedWeapon = "standard_gun" -- 508
	self.craftBench = { -- 510
		active = false, -- 511
		firstCraftDone = false, -- 512
		justCraftedTimer = 0, -- 513
		inventory = {}, -- 514
		recipes = {}, -- 515
		equippedWeapon = "standard_gun" -- 516
	} -- 516
	self.handledCraftRequests = {} -- 519
	self.benchReach = 48 -- 521
	self.pickups = {} -- 525
	self.reloadT = 0 -- 527
	self.objectiveDone = false -- 531
	self.hint = "" -- 533
	self.roomStartTick = 0 -- 535
	self.cartHitT = 0 -- 537
	self.cartExposed = false -- 538
	self.storyRoute = "" -- 542
	self.storySettled = false -- 544
	self.hpAtGate = -1 -- 546
	self.maxHpAtGate = -1 -- 547
	self.handTicks = 0 -- 549
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 551
	self.handArmed = false -- 553
	self.handDone = false -- 555
	self.lineSaid = false -- 556
	self.tied = false -- 558
	self.pathDone = false -- 560
	self.carryOn = false -- 562
	self.escortDone = false -- 564
	self.reloadOpen = false -- 568
	self.reloadAnswerTicks = 0 -- 570
	self.reloadWorldTicks = 0 -- 572
	self.reloadPath = {RELOAD_START} -- 574
	self.reloadPendingEffect = "" -- 576
	self.reloadTryCount = 0 -- 578
	self.paused = false -- 580
	self.ticks = 0 -- 582
	self.view = {zoom = 1, ox = 0, oy = 0} -- 584
	self.ox = 0 -- 586
	self.aimX = 0 -- 588
	self.aimY = 0 -- 589
	self.viewW = 0 -- 591
	self.viewH = 0 -- 592
	self.ox = room.originX -- 598
	self.room = withOrigin(room) -- 599
	local wr = self.room -- 600
	self.run = run or createRun() -- 601
	self.inventory = self.run.inventory -- 602
	self.archive = self.run.archive -- 603
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 604
	self.isCampaign = wr.campaign ~= nil -- 605
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 606
	self:buildWorld() -- 607
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 610
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 612
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 613
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 615
	local partnerIdx = wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1) -- 616
	self.player = makeActor(wr, playerIdx) -- 617
	self.partner = makeActor(wr, partnerIdx) -- 618
	self.phase = phaseOf(wr.key) -- 619
	if wr.story ~= nil then -- 619
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 621
	end -- 621
	self.cam.x = self.player.x -- 623
	self.cam.y = self.player.y + CAM_LOOK_UP -- 624
	self.cartAxle = wr.cart.startX -- 625
	self.escort = __TS__New( -- 626
		Escort, -- 626
		safeAnchorX(wr.marks) -- 626
	) -- 626
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 627
	if self.isCampaign then -- 627
		self:setupCampaign() -- 629
	else -- 629
		self:buildEnemies() -- 631
	end -- 631
	if resume ~= nil and resume.checkpoint > 0 then -- 631
		self.checkpoint = resume.checkpoint -- 635
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 635
			self.cartAxle = self.room.cart.endX -- 637
			self.cartDocked = true -- 638
			self.player.x = self.ox + 380 -- 641
			self.player.y = 0 -- 642
			self.player.vy = 0 -- 643
			self.player.onGround = true -- 644
			self.cam.x = self.player.x -- 645
			self.cam.y = self.player.y + CAM_LOOK_UP -- 646
		end -- 646
	end -- 646
	self:restoreStory() -- 649
end -- 596
function Play.prototype.recipeViews(self) -- 662
	local out = {} -- 663
	local i = 0 -- 664
	do -- 664
		i = 0 -- 665
		while i < #CRAFT_RECIPES do -- 665
			local r = CRAFT_RECIPES[i + 1] -- 666
			local cost = {} -- 667
			if r.cost.wood ~= nil then -- 667
				cost.wood = r.cost.wood -- 669
			end -- 669
			if r.cost.bell ~= nil then -- 669
				cost.bell = r.cost.bell -- 672
			end -- 672
			out[#out + 1] = { -- 674
				id = r.id, -- 675
				name = r.name, -- 676
				desc = r.desc, -- 677
				enhancedEffect = r.enhancedEffect, -- 678
				cost = cost, -- 679
				crafted = self.run.story.craftedWeapon == r.id -- 680
			} -- 680
			i = i + 1 -- 665
		end -- 665
	end -- 665
	return out -- 683
end -- 662
function Play.prototype.syncCraftBench(self) -- 687
	local view = self.craftBench -- 688
	local inv = self.run.inventory -- 689
	view.inventory = { -- 690
		wood = inv.wood, -- 690
		bell = inv.bell, -- 690
		scrap = inv.scrap, -- 690
		wedge = inv.wedge, -- 690
		ammo = inv.ammo -- 690
	} -- 690
	view.recipes = self:recipeViews() -- 691
	view.equippedWeapon = self.equippedWeapon -- 692
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 693
	if view.justCraftedTimer > 0 then -- 693
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 695
	end -- 695
end -- 687
function Play.prototype.openCraftBench(self) -- 700
	if self.room.key ~= "escort3" or self.craftBench.active then -- 700
		return -- 702
	end -- 702
	self.craftBench.active = true -- 704
	self.carryOn = false -- 705
	self.run.story.carry = false -- 706
	self.player.vx = 0 -- 707
	self.player.vy = 0 -- 708
	self.craftBench.justCraftedTimer = 0 -- 709
	self:syncCraftBench() -- 710
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 711
	self:log("开工台") -- 712
	self:emit( -- 713
		"benchOpen", -- 713
		{ -- 713
			recipes = __TS__ArrayMap( -- 714
				self.craftBench.recipes, -- 714
				function(____, r) return r.id end -- 714
			), -- 714
			inventory = self.craftBench.inventory, -- 715
			carry = self.carryOn -- 716
		} -- 716
	) -- 716
end -- 700
function Play.prototype.closeCraftBench(self) -- 721
	if not self.craftBench.active then -- 721
		return -- 723
	end -- 723
	self.craftBench.active = false -- 725
	self.craftBench.justCraftedTimer = 0 -- 726
	self.carryOn = true -- 727
	self.run.story.carry = true -- 728
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 729
	self:log("离站背起") -- 730
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 731
end -- 721
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 738
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 738
		return false -- 740
	end -- 740
	local recipe = findRecipe(recipeId) -- 742
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 742
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 744
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 745
		return false -- 746
	end -- 746
	local missing = missingMaterials(self.run.inventory, recipe) -- 748
	if #missing > 0 then -- 748
		self:flashSet( -- 750
			"缺料 · " .. table.concat(missing, " / "), -- 750
			1.6 -- 750
		) -- 750
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 751
		return false -- 752
	end -- 752
	payMaterials(self.run.inventory, recipe) -- 754
	self.handledCraftRequests[requestId] = true -- 755
	self.run.story.craftedWeapon = recipe.id -- 756
	self.equippedWeapon = recipe.id -- 757
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 758
	self.craftBench.firstCraftDone = true -- 759
	self:syncCraftBench() -- 760
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 761
	self:log("改制 " .. recipe.id) -- 762
	self:emit("benchCraft", { -- 763
		recipeId = recipe.id, -- 764
		weapon = recipe.id, -- 765
		effect = recipe.enhancedEffect, -- 766
		wood = self.run.inventory.wood, -- 767
		bell = self.run.inventory.bell -- 768
	}) -- 768
	return true -- 770
end -- 738
function Play.prototype.equipWeapon(self, weaponId) -- 774
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 774
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 776
		return false -- 777
	end -- 777
	self.equippedWeapon = weaponId -- 779
	self:syncCraftBench() -- 780
	self:flashSet( -- 781
		"已装备 " .. weaponNameOf(weaponId), -- 781
		1 -- 781
	) -- 781
	self:emit("benchEquip", {weapon = weaponId}) -- 782
	return true -- 783
end -- 774
function Play.prototype.submitFeIntent(self, intent) -- 790
	local kind = intent == nil and "" or intent.kind -- 791
	if kind == "reloadTapNode" then -- 791
		local node = intent.node -- 793
		if type(node) == "number" then -- 793
			self:reloadTapNode(node) -- 795
			return true -- 796
		end -- 796
		return false -- 798
	end -- 798
	if kind == "reloadPathCommit" then -- 798
		local path = intent.path -- 801
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 801
			local list = path -- 803
			local i = 0 -- 804
			do -- 804
				i = 0 -- 805
				while i < #list do -- 805
					do -- 805
						if i == 0 and list[i + 1] == RELOAD_START then -- 805
							goto __continue46 -- 807
						end -- 807
						self:reloadTapNode(list[i + 1]) -- 809
					end -- 809
					::__continue46:: -- 809
					i = i + 1 -- 805
				end -- 805
			end -- 805
			return true -- 811
		end -- 811
		return false -- 813
	end -- 813
	if kind == "reloadCancel" then -- 813
		self:closeReloadPuzzle() -- 816
		return true -- 817
	end -- 817
	if kind == "craftSubmit" then -- 817
		local recipeId = intent.recipeId -- 820
		local requestId = intent.requestId -- 821
		if type(recipeId) == "string" and type(requestId) == "string" then -- 821
			return self:craftAtBench(recipeId, requestId) -- 823
		end -- 823
		return false -- 825
	end -- 825
	if kind == "craftEquip" then -- 825
		local weaponId = intent.weaponId -- 828
		if type(weaponId) == "string" then -- 828
			return self:equipWeapon(weaponId) -- 830
		end -- 830
		return false -- 832
	end -- 832
	if kind == "craftClose" then -- 832
		self:closeCraftBench() -- 835
		return true -- 836
	end -- 836
	if kind == "wellPick" then -- 836
		return self:pickWell() -- 839
	end -- 839
	return false -- 841
end -- 790
function Play.prototype.captureCheckpoint(self, id) -- 845
	local inv = self.run.inventory -- 846
	self.checkpointSnap = { -- 847
		id = id, -- 848
		wood = inv.wood, -- 849
		bell = inv.bell, -- 850
		scrap = inv.scrap, -- 851
		wedge = inv.wedge, -- 852
		ammo = inv.ammo, -- 853
		shield = inv.shield, -- 854
		pass = inv.pass, -- 855
		quickbelt = inv.quickbelt, -- 856
		crafted = self.run.story.craftedWeapon, -- 857
		equipped = self.equippedWeapon, -- 858
		carry = self.carryOn -- 859
	} -- 859
	self.run.story.cp = self.checkpointSnap -- 861
end -- 845
function Play.prototype.applyCheckpointSnap(self, id) -- 865
	local snap = self.run.story.cp -- 866
	if snap == nil or snap.id ~= id then -- 866
		return false -- 868
	end -- 868
	self.checkpointSnap = snap -- 870
	local inv = self.run.inventory -- 871
	inv.wood = snap.wood -- 872
	inv.bell = snap.bell -- 873
	inv.scrap = snap.scrap -- 874
	inv.wedge = snap.wedge -- 875
	inv.ammo = snap.ammo -- 876
	inv.shield = snap.shield -- 877
	inv.pass = snap.pass -- 878
	inv.quickbelt = snap.quickbelt -- 879
	self.run.story.craftedWeapon = snap.crafted -- 880
	self.equippedWeapon = snap.equipped -- 881
	self.carryOn = snap.carry -- 882
	self.run.story.carry = snap.carry -- 883
	self.craftBench.active = false -- 884
	self:syncCraftBench() -- 885
	return true -- 886
end -- 865
function Play.prototype.restoreStory(self) -- 889
	if self.isCampaign and self.run.trial ~= nil then -- 889
		return -- 893
	end -- 893
	local story = self.run.story -- 895
	if story == nil then -- 895
		return -- 897
	end -- 897
	if story.maxHp > 0 then -- 897
		self.maxHp = story.maxHp -- 900
		self.hp = math.max( -- 901
			1, -- 901
			math.min(story.hp, story.maxHp) -- 901
		) -- 901
	end -- 901
	self.storyRoute = story.route -- 903
	self.storySettled = story.settled -- 904
	self.hpAtGate = story.hpAtGate -- 905
	self.maxHpAtGate = story.maxHpAtGate -- 906
	self.handDone = story.handDone -- 907
	self.lineSaid = story.lineSaid -- 908
	self.tied = story.handDone -- 909
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 910
	self.escortDone = story.escortDone -- 911
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 912
	self:syncCraftBench() -- 913
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 913
		self:applyCheckpointSnap(self.checkpoint) -- 916
	end -- 916
	if self.room.key == "tower" and story.route == "soldier" then -- 916
		self.carryOn = false -- 920
		self.run.story.carry = false -- 921
	end -- 921
	if self.room.key ~= "gate" then -- 921
		return -- 924
	end -- 924
	local ____temp_0 -- 926
	if self.room.story == nil then -- 926
		____temp_0 = nil -- 926
	else -- 926
		____temp_0 = self.room.story.gate -- 926
	end -- 926
	local g = ____temp_0 -- 926
	if g == nil then -- 926
		return -- 928
	end -- 928
	if story.phase == "gate-send" then -- 928
		self.phase = "gate-send" -- 932
		self.gateTick = g.holdTicks -- 933
		self.gateSpawned = 4 -- 934
		self.enemies = {} -- 935
		self.player.x = self.ox + g.doorX - 40 -- 936
		self.player.y = 0 -- 937
		self.player.depth = 0 -- 938
		self.player.vx = 0 -- 939
		self.player.vy = 0 -- 940
		self.player.onGround = true -- 941
		self.partner.x = self.ox + g.waitX -- 942
		self.partner.y = 0 -- 943
		self.partner.depth = 0 -- 944
		self.partner.alive = true -- 945
		self.cam.x = self.player.x -- 946
		self.handTicks = 0 -- 947
		self.handArmed = false -- 948
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 949
		return -- 950
	end -- 950
	if not story.settled then -- 950
		return -- 953
	end -- 953
	self.gateTick = g.holdTicks -- 956
	self.gateSpawned = 4 -- 957
	self.enemies = {} -- 958
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 958
		self.phase = story.phase -- 960
		self.countTick = math.max(story.countTick, 0) -- 961
		self:swapToChild(g.doorX + 30) -- 962
		self.countPrevMove = 0 -- 963
		self.countArmed = false -- 964
		return -- 965
	end -- 965
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 965
		self.phase = story.phase -- 968
		self.countTick = ____exports.GATE_COUNT_END -- 969
		self.phaseTick = story.phaseTick -- 970
		self:swapToChild(g.doorX + 30) -- 971
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 972
			0, -- 972
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 972
		) -- 972
		self.handArmed = false -- 973
	end -- 973
end -- 889
function Play.prototype.buildWorld(self) -- 978
	local room = self.room -- 979
	self.boxes = {} -- 980
	self.floors = {} -- 981
	local i = 0 -- 982
	do -- 982
		i = 0 -- 983
		while i < #room.floors do -- 983
			local f = room.floors[i + 1] -- 984
			local ____self_floors_1 = self.floors -- 984
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 985
			i = i + 1 -- 983
		end -- 983
	end -- 983
	do -- 983
		i = 0 -- 987
		while i < #room.solids do -- 987
			local s = room.solids[i + 1] -- 988
			if not s.decorative then -- 988
				local ____self_boxes_13 = self.boxes -- 994
				local ____s_x_4 = s.x -- 995
				local ____temp_5 = s.x + s.w -- 995
				local ____s_y_6 = s.y -- 995
				local ____temp_7 = s.y + s.h -- 995
				local ____temp_2 -- 996
				if room.depth == nil then -- 996
					____temp_2 = nil -- 996
				else -- 996
					____temp_2 = s.depth -- 996
				end -- 996
				local ____temp_8 = s.passable == true -- 997
				local ____s_label_9 = s.label -- 997
				local ____s_id_10 = s.id -- 998
				local ____temp_11 = s.soft == true -- 998
				local ____temp_12 = s.hidden == true -- 998
				local ____temp_3 -- 999
				if s.breakable == nil then -- 999
					____temp_3 = nil -- 999
				else -- 999
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 999
				end -- 999
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 994
					x0 = ____s_x_4, -- 995
					x1 = ____temp_5, -- 995
					y0 = ____s_y_6, -- 995
					y1 = ____temp_7, -- 995
					depth = ____temp_2, -- 996
					passable = ____temp_8, -- 997
					label = ____s_label_9, -- 997
					id = ____s_id_10, -- 998
					soft = ____temp_11, -- 998
					hidden = ____temp_12, -- 998
					breakable = ____temp_3, -- 999
					interact = s.interact -- 1000
				} -- 1000
			end -- 1000
			i = i + 1 -- 987
		end -- 987
	end -- 987
	do -- 987
		i = 0 -- 1004
		while i < #room.stairs do -- 1004
			local st = room.stairs[i + 1] -- 1005
			local n = st.steps + 1 -- 1006
			local stepW = (st.x1 - st.x0) / n -- 1007
			local k = 0 -- 1008
			do -- 1008
				k = 0 -- 1009
				while k < n do -- 1009
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1010
					local x0 = st.x0 + stepW * k -- 1011
					local ____self_boxes_14 = self.boxes -- 1011
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 1013
						x0 = x0, -- 1013
						x1 = x0 + stepW, -- 1013
						y0 = -8, -- 1013
						y1 = y, -- 1013
						passable = true -- 1013
					} -- 1013
					k = k + 1 -- 1009
				end -- 1009
			end -- 1009
			i = i + 1 -- 1004
		end -- 1004
	end -- 1004
end -- 978
function Play.prototype.setupCampaign(self) -- 1022
	local wr = self.room -- 1023
	local c = wr.campaign -- 1024
	if c == nil then -- 1024
		return -- 1026
	end -- 1026
	self.roomStartTick = self.run.ticks -- 1028
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1028
		self.run.joined = true -- 1032
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1032
		local ____self_run_16 = self.run -- 1035
		local ____temp_15 -- 1035
		if wr.key == "s2-drygoods" then -- 1035
			____temp_15 = self.run.route ~= "drygoods" -- 1035
		else -- 1035
			____temp_15 = false -- 1035
		end -- 1035
		____self_run_16.joined = ____temp_15 -- 1035
	end -- 1035
	local x = wr.minX + 60 -- 1037
	local y = 0 -- 1038
	local depth = 0 -- 1039
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1039
		x = wr.minX + 210 -- 1041
		depth = -32 -- 1042
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1042
		x = wr.minX + 40 -- 1044
		y = 32 -- 1045
		depth = 32 -- 1046
	end -- 1046
	self.player = { -- 1048
		x = x, -- 1049
		y = y, -- 1049
		depth = depth, -- 1049
		depthSpeed = 0, -- 1049
		vx = 0, -- 1049
		vy = 0, -- 1049
		w = SOLDIER_W, -- 1050
		h = SOLDIER_H, -- 1050
		onGround = y <= 0, -- 1050
		facing = 1, -- 1050
		crouch = false, -- 1050
		rollT = 0, -- 1050
		covered = false, -- 1050
		alive = true -- 1050
	} -- 1050
	self.partner = { -- 1052
		x = x + 60, -- 1053
		y = y, -- 1053
		depth = depth, -- 1053
		depthSpeed = 0, -- 1053
		vx = 0, -- 1053
		vy = 0, -- 1053
		w = CHILD_W, -- 1054
		h = CHILD_H, -- 1054
		onGround = y <= 0, -- 1054
		facing = 1, -- 1054
		crouch = false, -- 1054
		rollT = 0, -- 1054
		covered = false, -- 1054
		alive = true -- 1054
	} -- 1054
	self.cam.x = x -- 1056
	self.cam.y = y + CAM_LOOK_UP -- 1057
	self.phase = "run" -- 1058
	self.hp = self.maxHp -- 1059
	local trial = self.run.trial -- 1060
	if trial ~= nil then -- 1060
		draftRoom(trial, wr.key) -- 1062
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1063
		self.hp = trial.hp -- 1064
	end -- 1064
	self:buildEnemies() -- 1066
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1067
	local i = 0 -- 1068
	do -- 1068
		i = 0 -- 1069
		while i < #self.boxes do -- 1069
			do -- 1069
				local b = self.boxes[i + 1] -- 1070
				if b.id == nil then -- 1070
					goto __continue88 -- 1072
				end -- 1072
				local st = self.run.props[b.id] -- 1074
				if st ~= nil then -- 1074
					b.broken = st.broken -- 1076
					local ____temp_17 -- 1077
					if b.breakable == nil then -- 1077
						____temp_17 = nil -- 1077
					else -- 1077
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1077
					end -- 1077
					b.breakable = ____temp_17 -- 1077
					b.hidden = b.hidden == true and st.revealed ~= true -- 1078
					if b.hidden then -- 1078
						b.broken = true -- 1080
					end -- 1080
				elseif b.hidden == true then -- 1080
					b.broken = true -- 1084
				end -- 1084
			end -- 1084
			::__continue88:: -- 1084
			i = i + 1 -- 1069
		end -- 1069
	end -- 1069
	if wr.cart.bodyW > 0 then -- 1069
		self.cartAxle = wr.cart.startX -- 1088
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1088
			self.cartAxle = wr.cart.endX -- 1090
			self.cartDocked = true -- 1091
		end -- 1091
	end -- 1091
	do -- 1091
		i = 0 -- 1094
		while i < #self.pickups do -- 1094
			local pk = self.pickups[i + 1] -- 1095
			if self.run.taken[pk.id] == true then -- 1095
				pk.id = "" -- 1097
			end -- 1097
			i = i + 1 -- 1094
		end -- 1094
	end -- 1094
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1100
end -- 1022
function Play.prototype.log(self, line) -- 1103
	local ____self_run_log_18 = self.run.log -- 1103
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1104
	if #self.run.log > 120 then -- 1104
		table.remove(self.run.log, 1) -- 1106
	end -- 1106
end -- 1103
function Play.prototype.buildEnemies(self) -- 1110
	self.enemies = {} -- 1111
	if self.isCampaign then -- 1111
		local i = 0 -- 1113
		do -- 1113
			i = 0 -- 1114
			while i < #self.room.spawns do -- 1114
				local sp = self.room.spawns[i + 1] -- 1115
				local kind = sp.kind or "gunner" -- 1116
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1117
				local ____self_enemies_19 = self.enemies -- 1117
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1118
					x = sp.x, -- 1119
					y = sp.y, -- 1119
					depth = sp.depth, -- 1119
					w = 26, -- 1119
					h = sp.h, -- 1119
					alive = true, -- 1119
					hitT = 0, -- 1119
					warnT = 0, -- 1119
					fireCd = 40, -- 1119
					kind = kind, -- 1120
					shieldHp = hp, -- 1120
					shieldHpMax = hp, -- 1120
					drop = sp.drop or "none", -- 1120
					homeX = sp.x, -- 1121
					swingT = 0, -- 1121
					awake = false, -- 1121
					squad = i -- 1121
				} -- 1121
				i = i + 1 -- 1114
			end -- 1114
		end -- 1114
		return -- 1124
	end -- 1124
	if self.room.key == "checkpoint" then -- 1124
		local ____self_enemies_20 = self.enemies -- 1124
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1127
			x = self.ox + 430, -- 1127
			y = 0, -- 1127
			w = 26, -- 1127
			h = 84, -- 1127
			alive = true, -- 1127
			hitT = 0, -- 1127
			warnT = 0, -- 1127
			fireCd = 0 -- 1127
		} -- 1127
		local ____self_enemies_21 = self.enemies -- 1127
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1128
			x = self.ox + 505, -- 1128
			y = 0, -- 1128
			w = 26, -- 1128
			h = 84, -- 1128
			alive = true, -- 1128
			hitT = 0, -- 1128
			warnT = 0, -- 1128
			fireCd = 0 -- 1128
		} -- 1128
		return -- 1129
	end -- 1129
	if self.room.key == "street" then -- 1129
		local ____self_enemies_22 = self.enemies -- 1129
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1133
			x = self.ox + 340, -- 1133
			y = 0, -- 1133
			w = 26, -- 1133
			h = 84, -- 1133
			alive = true, -- 1133
			hitT = 0, -- 1133
			warnT = 0, -- 1133
			fireCd = 0 -- 1133
		} -- 1133
		local ____self_enemies_23 = self.enemies -- 1133
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1134
			x = self.ox + 560, -- 1134
			y = 0, -- 1134
			w = 26, -- 1134
			h = 84, -- 1134
			alive = true, -- 1134
			hitT = 0, -- 1134
			warnT = 0, -- 1134
			fireCd = 0 -- 1134
		} -- 1134
	end -- 1134
end -- 1110
function Play.prototype.emit(self, name, data) -- 1140
	local ____self_events_24 = self.events -- 1140
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1141
	self.eventSeq = self.eventSeq + 1 -- 1142
	if #self.events > 256 then -- 1142
		table.remove(self.events, 1) -- 1144
	end -- 1144
end -- 1140
function Play.prototype.drainEvents(self) -- 1152
	local out = self.events -- 1153
	self.events = {} -- 1154
	return out -- 1155
end -- 1152
function Play.prototype.adoptEvents(self, events) -- 1164
	if #events == 0 then -- 1164
		return -- 1166
	end -- 1166
	local keep = {} -- 1168
	local i = 0 -- 1169
	do -- 1169
		i = 0 -- 1170
		while i < #events do -- 1170
			do -- 1170
				local e = events[i + 1] -- 1171
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1171
					goto __continue112 -- 1173
				end -- 1173
				keep[#keep + 1] = e -- 1175
			end -- 1175
			::__continue112:: -- 1175
			i = i + 1 -- 1170
		end -- 1170
	end -- 1170
	if #keep == 0 then -- 1170
		return -- 1178
	end -- 1178
	self.events = __TS__ArrayConcat(keep, self.events) -- 1180
	do -- 1180
		i = 0 -- 1181
		while i < #self.events do -- 1181
			self.events[i + 1].seq = i -- 1182
			i = i + 1 -- 1181
		end -- 1181
	end -- 1181
	self.eventSeq = #self.events -- 1184
end -- 1164
function Play.prototype.chooseTalent(self, slot) -- 1187
	local trial = self.run.trial -- 1188
	local talent = trial and trial.offers[slot + 1] -- 1189
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1189
		return -- 1190
	end -- 1190
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1190
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1191
	trial.offers = {} -- 1192
	if talent == "vitality" then -- 1192
		self.maxHp = self.maxHp + 1 -- 1194
		self.hp = self.hp + 1 -- 1195
		trial.hp = self.hp -- 1196
	end -- 1196
	self:flashSet(talentNames[talent], 1.2) -- 1198
end -- 1187
function Play.prototype.beginReload(self) -- 1206
	self.reloadT = self:reloadTicks() -- 1207
	local camp = self.room.campaign -- 1208
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1208
		self:openReloadPuzzle() -- 1211
	end -- 1211
end -- 1206
function Play.prototype.openReloadPuzzle(self) -- 1216
	self.reloadOpen = true -- 1217
	self.reloadAnswerTicks = 0 -- 1218
	self.reloadWorldTicks = 0 -- 1219
	self.reloadPath = {RELOAD_START} -- 1220
	self.reloadPendingEffect = "" -- 1221
	self.reloadTryCount = self.reloadTryCount + 1 -- 1222
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1223
end -- 1216
function Play.prototype.closeReloadPuzzle(self) -- 1227
	self.reloadOpen = false -- 1228
	self.reloadAnswerTicks = 0 -- 1229
	self.reloadWorldTicks = 0 -- 1230
	self.reloadPath = {RELOAD_START} -- 1231
	self.reloadPendingEffect = "" -- 1232
end -- 1227
function Play.prototype.reloadTapNode(self, node) -- 1239
	if not self.reloadOpen then -- 1239
		return -- 1241
	end -- 1241
	local path = self.reloadPath -- 1243
	local last = path[#path] -- 1244
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1244
		self.reloadPath = {RELOAD_START} -- 1246
		self:emit("reloadInvalid", {node = node, at = last}) -- 1247
		return -- 1248
	end -- 1248
	path[#path + 1] = node -- 1250
	if node ~= RELOAD_TARGET then -- 1250
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1252
		return -- 1253
	end -- 1253
	if not reloadPathValid(path) then -- 1253
		self.reloadPath = {RELOAD_START} -- 1256
		self:emit("reloadInvalid", {node = node, at = last}) -- 1257
		return -- 1258
	end -- 1258
	self.reloadPendingEffect = reloadEffectOf(path) -- 1260
	self.reloadOpen = false -- 1261
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1262
	self:flashSet( -- 1265
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1265
		1.4 -- 1265
	) -- 1265
end -- 1239
function Play.prototype.consumeReloadEffect(self) -- 1269
	local e = self.reloadPendingEffect -- 1270
	if e ~= "" then -- 1270
		self.reloadPendingEffect = "" -- 1272
	end -- 1272
	return e -- 1274
end -- 1269
function Play.prototype.echoToSource(self, from, count) -- 1281
	if count == nil then -- 1281
		count = 1 -- 1281
	end -- 1281
	local best = -1 -- 1282
	local bestD = 1000000000 -- 1283
	local i = 0 -- 1284
	local woken = {} -- 1285
	local n = 0 -- 1286
	while n < count do -- 1286
		best = -1 -- 1288
		bestD = 1000000000 -- 1289
		do -- 1289
			i = 0 -- 1290
			while i < #self.enemies do -- 1290
				do -- 1290
					if woken[i] == true then -- 1290
						goto __continue134 -- 1292
					end -- 1292
					local e = self.enemies[i + 1] -- 1294
					if not e.alive then -- 1294
						goto __continue134 -- 1296
					end -- 1296
					local d = math.abs(e.x - from.x) -- 1298
					if d < bestD then -- 1298
						bestD = d -- 1300
						best = i -- 1301
					end -- 1301
				end -- 1301
				::__continue134:: -- 1301
				i = i + 1 -- 1290
			end -- 1290
		end -- 1290
		if best < 0 then -- 1290
			break -- 1305
		end -- 1305
		woken[best] = true -- 1307
		local e = self.enemies[best + 1] -- 1308
		e.awake = true -- 1309
		e.warnT = 0 -- 1310
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1311
		n = n + 1 -- 1312
	end -- 1312
	if n == 0 then -- 1312
		return -- 1315
	end -- 1315
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1317
end -- 1281
function Play.prototype.reloadTicks(self) -- 1320
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1321
	local ____opt_29 = self.run.trial -- 1321
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1321
end -- 1320
function Play.prototype.update(self, dt, input) -- 1324
	self:syncCraftBench() -- 1325
	local trial = self.run.trial -- 1326
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1326
		return -- 1327
	end -- 1327
	if input.pause.pressed then -- 1327
		self.paused = not self.paused -- 1329
	end -- 1329
	if self.flashT > 0 then -- 1329
		self.flashT = self.flashT - dt -- 1332
		if self.flashT <= 0 then -- 1332
			self.flash = "" -- 1334
		end -- 1334
	end -- 1334
	if self.traceT > 0 then -- 1334
		self.traceT = self.traceT - dt -- 1338
		if self.traceT <= 0 then -- 1338
			self.trace = nil -- 1340
		end -- 1340
	end -- 1340
	if self.paused then -- 1340
		self:updateCamera(dt) -- 1344
		return -- 1345
	end -- 1345
	if self.craftBench.active then -- 1345
		if input.interact.pressed or input.pause.pressed then -- 1345
			self:closeCraftBench() -- 1351
		end -- 1351
		self:updateCamera(dt) -- 1353
		return -- 1354
	end -- 1354
	if self.reloadOpen then -- 1354
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1360
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1360
			self.reloadOpen = false -- 1362
			self.reloadPendingEffect = "" -- 1363
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1364
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1365
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1365
			self:updateCamera(dt) -- 1367
			return -- 1368
		else -- 1368
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1370
		end -- 1370
	end -- 1370
	self.ticks = self.ticks + 1 -- 1374
	if self.invulnT > 0 then -- 1374
		self.invulnT = self.invulnT - 1 -- 1378
	end -- 1378
	if self.isCampaign then -- 1378
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1378
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1381
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1382
	end -- 1382
	local p = self.player -- 1384
	self:stepPlayer(p, dt, input) -- 1385
	self:refreshCover(p, input) -- 1387
	if self.carryOn then -- 1387
		self:carryPose() -- 1389
	end -- 1389
	if self.isCampaign then -- 1389
		self:stepCampaign(dt, input) -- 1392
		if not self.carryOn then -- 1392
			self:stepCampaignPartner(dt) -- 1394
		end -- 1394
	end -- 1394
	if trial == nil or not self.run.finished then -- 1394
		self:stepEnemies(dt, input) -- 1402
	end -- 1402
	if trial ~= nil then -- 1402
		trial.hp = self.hp -- 1404
	end -- 1404
	if not self.isCampaign then -- 1404
		self:stepStory(dt, input) -- 1406
		self:stepEscort(dt, input) -- 1407
		self:stepVillage(dt, input) -- 1408
		self:stepChase(dt, input) -- 1409
		self:stepInteract(dt, input) -- 1410
	end -- 1410
	self:updateGate() -- 1412
	self:updateCamera(dt) -- 1413
	self:syncStory() -- 1415
end -- 1324
function Play.prototype.underLowArch(self, a) -- 1422
	local arch = self.room.arch -- 1423
	if arch.h <= 0 then -- 1423
		return false -- 1425
	end -- 1425
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1425
		return false -- 1428
	end -- 1428
	local top = arch.y + arch.h -- 1430
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1431
end -- 1422
function Play.prototype.coverAt(self, a) -- 1438
	local best = nil -- 1439
	local bestGap = 24 -- 1440
	local half = a.w / 2 -- 1441
	local i = 0 -- 1442
	do -- 1442
		i = 0 -- 1443
		while i < #self.boxes do -- 1443
			do -- 1443
				local b = self.boxes[i + 1] -- 1444
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1444
					goto __continue168 -- 1446
				end -- 1446
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1446
					goto __continue168 -- 1449
				end -- 1449
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1451
				if gap < bestGap then -- 1451
					bestGap = gap -- 1453
					best = b -- 1454
				end -- 1454
			end -- 1454
			::__continue168:: -- 1454
			i = i + 1 -- 1443
		end -- 1443
	end -- 1443
	return best -- 1457
end -- 1438
function Play.prototype.nearCover(self, a) -- 1460
	return self:coverAt(a) ~= nil -- 1461
end -- 1460
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1465
	if enemy == nil then -- 1465
		return false -- 1467
	end -- 1467
	local fromRight = enemy.x >= a.x -- 1469
	local edge = fromRight and b.x0 or b.x1 -- 1470
	local ____fromRight_34 -- 1471
	if fromRight then -- 1471
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1471
	else -- 1471
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1472
	end -- 1472
	local between = ____fromRight_34 -- 1471
	local separation = enemy.x - a.x -- 1473
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1474
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1475
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1476
end -- 1465
function Play.prototype.nearestEnemy(self, a) -- 1479
	local best -- 1480
	local bestD = 1000000000 -- 1481
	local i = 0 -- 1482
	do -- 1482
		i = 0 -- 1483
		while i < #self.enemies do -- 1483
			do -- 1483
				local e = self.enemies[i + 1] -- 1484
				if not e.alive then -- 1484
					goto __continue177 -- 1486
				end -- 1486
				local d = math.abs(e.x - a.x) -- 1488
				if d < bestD then -- 1488
					bestD = d -- 1490
					best = e -- 1491
				end -- 1491
			end -- 1491
			::__continue177:: -- 1491
			i = i + 1 -- 1483
		end -- 1483
	end -- 1483
	return best -- 1494
end -- 1479
function Play.prototype.refreshCover(self, a, input) -- 1498
	if self.childMode then -- 1498
		self.coverNear = false -- 1500
		self.coverHug = false -- 1501
		self.coverEntity = "" -- 1502
		self.coverBlocking = false -- 1503
		a.covered = false -- 1504
		return -- 1505
	end -- 1505
	local b = self:coverAt(a) -- 1507
	self.coverNear = b ~= nil -- 1508
	a.covered = self.coverNear and input.cover.held -- 1509
	self.coverHug = a.covered -- 1510
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1511
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1512
		b, -- 1512
		a, -- 1512
		self:nearestEnemy(a) -- 1512
	) -- 1512
end -- 1498
function Play.prototype.cartHandleInReach(self, a) -- 1516
	if a == nil then -- 1516
		a = self.player -- 1516
	end -- 1516
	local c = self.room.cart -- 1517
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1517
		return false -- 1519
	end -- 1519
	local handleX = self.cartAxle + c.handleOffset -- 1521
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1522
end -- 1516
function Play.prototype.nearLowLedge(self, a) -- 1527
	local reach = 26 -- 1528
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1529
	local x1 = x0 + reach -- 1530
	local i = 0 -- 1531
	do -- 1531
		i = 0 -- 1532
		while i < #self.boxes do -- 1532
			do -- 1532
				local b = self.boxes[i + 1] -- 1533
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1533
					goto __continue186 -- 1535
				end -- 1535
				local rise = b.y1 - a.y -- 1537
				if rise > 0 and rise <= LEDGE_RISE then -- 1537
					return true -- 1539
				end -- 1539
			end -- 1539
			::__continue186:: -- 1539
			i = i + 1 -- 1532
		end -- 1532
	end -- 1532
	return false -- 1542
end -- 1527
function Play.prototype.stepPlayer(self, a, dt, input) -- 1545
	a.depthSpeed = 0 -- 1546
	if not a.alive then -- 1546
		return -- 1548
	end -- 1548
	local isChild = self.childMode -- 1550
	local lowArch = isChild and self:underLowArch(a) -- 1552
	if self:storyLocked() then -- 1552
		a.vx = 0 -- 1555
		a.crouch = isChild and lowArch -- 1556
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1557
		self:fallY(a, dt) -- 1558
		return -- 1559
	end -- 1559
	if not isChild and self.escort.state == "calming" then -- 1559
		a.crouch = false -- 1563
		a.h = SOLDIER_H -- 1564
		a.vx = 0 -- 1565
		self:fallY(a, dt) -- 1566
		return -- 1567
	end -- 1567
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1569
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1570
	local nearCover = not isChild and self:nearCover(a) -- 1571
	a.covered = nearCover and input.cover.held -- 1572
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1574
	if a.rollT > 0 then -- 1574
		a.rollT = a.rollT - dt -- 1578
		a.vx = a.facing * ROLL_SPEED -- 1579
		self:slideX(a, a.vx * dt) -- 1580
		self:fallY(a, dt) -- 1581
		if a.rollT <= 0 then -- 1581
			self:flashSet("翻滚结束", 0.5) -- 1583
		end -- 1583
		return -- 1585
	end -- 1585
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1585
		if input.moveX ~= 0 then -- 1585
			a.facing = input.moveX > 0 and 1 or -1 -- 1590
		end -- 1590
		if self:nearLowLedge(a) then -- 1590
			a.vy = SOLDIER_JUMP -- 1594
			a.onGround = false -- 1595
			self:flashSet("翻上去", 0.3) -- 1596
			return -- 1597
		end -- 1597
		a.rollT = ROLL_TIME -- 1599
		self:flashSet("翻滚", 0.3) -- 1600
		return -- 1601
	end -- 1601
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1604
	if isChild then -- 1604
		if input.cover.held then -- 1604
			speed = CHILD_SLOW -- 1607
		end -- 1607
		if a.crouch then -- 1607
			speed = CHILD_SLOW -- 1610
		end -- 1610
	elseif a.covered then -- 1610
		speed = SOLDIER_SPEED * 0.45 -- 1613
	end -- 1613
	local handsBusy = self.gripping or gripIntent -- 1617
	local dir = self.gripping and 0 or input.moveX -- 1618
	local depthDir = self.room.depth ~= nil and not isChild and not handsBusy and -input.moveY or 0 -- 1619
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1620
	if dir ~= 0 then -- 1620
		a.facing = dir > 0 and 1 or -1 -- 1622
	end -- 1622
	a.vx = dir * speed * diagonal -- 1624
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1624
		a.vy = CHILD_JUMP -- 1628
		a.onGround = false -- 1629
		self:flashSet("跳", 0.25) -- 1630
	end -- 1630
	local previousDepth = a.depth -- 1634
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1635
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1636
	self:slideX(a, a.vx * dt) -- 1637
	self:fallY(a, dt) -- 1638
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1638
		self:shoot(a) -- 1642
	end -- 1642
end -- 1545
function Play.prototype.stepPartner(self, p, dt) -- 1647
	local a = self.partner -- 1648
	if not a.alive then -- 1648
		return -- 1650
	end -- 1650
	a.crouch = false -- 1652
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1653
	a.vx = 0 -- 1654
	a.depthSpeed = 0 -- 1655
	self:fallY(a, dt) -- 1656
end -- 1647
function Play.prototype.stepEscort(self, dt, input) -- 1663
	local a = self.partner -- 1664
	a.depthSpeed = 0 -- 1665
	if not a.alive then -- 1665
		return -- 1667
	end -- 1667
	if self.room.key == "gatepath" then -- 1667
		if self.carryOn then -- 1667
			return -- 1672
		end -- 1672
		local p = self.player -- 1675
		a.depth = p.depth -- 1676
		a.facing = p.facing -- 1677
		a.crouch = false -- 1678
		a.h = CHILD_H -- 1679
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1680
		a.y = p.y -- 1681
		a.vy = 0 -- 1682
		a.vx = p.vx -- 1683
		a.onGround = p.onGround -- 1684
		return -- 1685
	end -- 1685
	if not self:escortOn() then -- 1685
		a.vx = 0 -- 1688
		self:fallY(a, dt) -- 1689
		return -- 1690
	end -- 1690
	local p = self.player -- 1692
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1693
	local hadKnock1 = self.escort.knock1 -- 1694
	local hadKnock2 = self.escort.knock2 -- 1695
	self.calmConsumed = self.escort:update( -- 1696
		input, -- 1696
		p.x, -- 1696
		p.facing, -- 1696
		a.x, -- 1696
		dist -- 1696
	) -- 1696
	if not hadKnock1 and self.escort.knock1 then -- 1696
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1699
	end -- 1699
	if not hadKnock2 and self.escort.knock2 then -- 1699
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1702
	end -- 1702
	a.crouch = self.escort.crouchPose -- 1704
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1705
	if not self.escort.stopped then -- 1705
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1707
		local previousDepth = a.depth -- 1708
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1709
		local distance = math.max( -- 1710
			-travel, -- 1710
			math.min(travel, targetDepth - previousDepth) -- 1710
		) -- 1710
		self:slideDepth(a, distance) -- 1711
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1712
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1712
			a.vy = CHILD_JUMP -- 1714
			a.onGround = false -- 1715
		end -- 1715
	end -- 1715
	local dir = self.escort:moveDir(a.x) -- 1718
	a.vx = dir * CHILD_SPEED -- 1719
	if dir ~= 0 then -- 1719
		a.facing = dir -- 1721
		local before = a.x -- 1722
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1723
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1723
			a.vy = CHILD_JUMP -- 1726
			a.onGround = false -- 1727
		end -- 1727
	end -- 1727
	self:fallY(a, dt) -- 1730
end -- 1663
function Play.prototype.escortOn(self) -- 1734
	if self.room.key == "checkpoint" then -- 1734
		return true -- 1736
	end -- 1736
	if self.room.key == "gatepath" then -- 1736
		return true -- 1739
	end -- 1739
	if self.room.key == "prologue" then -- 1739
		return self.phase == "prologue-follow" -- 1742
	end -- 1742
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1742
		return true -- 1746
	end -- 1746
	return self.room.key == "street" -- 1748
end -- 1734
function Play.prototype.storyLocked(self) -- 1752
	if self.caughtT > 0 then -- 1752
		return true -- 1754
	end -- 1754
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1754
		return true -- 1757
	end -- 1757
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1757
		return true -- 1760
	end -- 1760
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1760
		return true -- 1763
	end -- 1763
	if self.craftBench.active then -- 1763
		return true -- 1767
	end -- 1767
	return false -- 1769
end -- 1752
function Play.prototype.swapToChild(self, x) -- 1773
	local tmp = self.player -- 1774
	self.player = self.partner -- 1775
	self.partner = tmp -- 1776
	self.childMode = true -- 1777
	self.player.alive = true -- 1778
	self.player.x = self.ox + x -- 1779
	self.player.y = 0 -- 1780
	self.player.depth = 0 -- 1781
	self.player.depthSpeed = 0 -- 1782
	self.player.vy = 0 -- 1783
	self.player.vx = 0 -- 1784
	self.player.onGround = true -- 1785
	self.player.crouch = false -- 1786
	self.player.h = CHILD_H -- 1787
	self.player.facing = 1 -- 1788
	self.partner.alive = true -- 1789
	self.cam.x = self.player.x -- 1790
end -- 1773
function Play.prototype.stepStory(self, dt, input) -- 1794
	if self.room.key == "prologue" then -- 1794
		self:stepPrologue(dt, input) -- 1796
	elseif self.room.key == "street" then -- 1796
		self:stepStreet(dt, input) -- 1798
	elseif self.room.key == "gate" then -- 1798
		self:stepGate(dt, input) -- 1800
	elseif self.room.key == "gatepath" then -- 1800
		self:stepGatePath() -- 1802
	elseif self.room.key == "tower" then -- 1802
		self:stepTower(dt, input) -- 1804
	end -- 1804
end -- 1794
function Play.prototype.wellWindow(self) -- 1810
	return not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1811
end -- 1810
function Play.prototype.nearWell(self) -- 1815
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1816
end -- 1815
function Play.prototype.pickWell(self) -- 1824
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1824
		return false -- 1826
	end -- 1826
	self.phase = "prologue-well" -- 1828
	self.phaseTick = 0 -- 1829
	self.wellOpen = false -- 1830
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1831
	self:log("旧井拾取") -- 1832
	return true -- 1833
end -- 1824
function Play.prototype.stepPrologue(self, dt, input) -- 1836
	local child = self.partner -- 1837
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 1839
	if self.phase == "prologue-wait" then -- 1839
		child.crouch = true -- 1841
		child.h = CHILD_CROUCH_H -- 1842
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 1842
			self:pickWell() -- 1844
			return -- 1845
		end -- 1845
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 1847
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 1849
		if near and input.interact.pressed then -- 1849
			self.phase = "prologue-give" -- 1851
			self.phaseTick = 0 -- 1852
			self:flashSet("递出针套", 1) -- 1853
		end -- 1853
		return -- 1855
	end -- 1855
	if self.phase == "prologue-well" then -- 1855
		self.phaseTick = self.phaseTick + 1 -- 1859
		if self.phaseTick == 12 then -- 1859
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 1861
		elseif self.phaseTick >= 30 then -- 1861
			self.phase = "prologue-wait" -- 1863
			self.phaseTick = 0 -- 1864
			self.wellTaken = true -- 1865
			self.wellOpen = false -- 1866
			self.run.archive.artifactOwned = true -- 1867
			self.archiveDirty = true -- 1868
			self:emit("artifactFound", { -- 1869
				x = self.ox + self.wellX, -- 1870
				y = 0, -- 1870
				room = "prologue", -- 1870
				once = true, -- 1870
				source = self.run.source -- 1871
			}) -- 1871
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 1873
			self:log("井底取到时间穿梭器") -- 1874
		end -- 1874
		return -- 1876
	end -- 1876
	if self.phase == "prologue-give" then -- 1876
		self.phaseTick = self.phaseTick + 1 -- 1879
		if self.phaseTick == 12 then -- 1879
			self:flashSet("针套递过去", 0.7) -- 1881
		elseif self.phaseTick == 36 then -- 1881
			self:flashSet("纸条塞进针套", 0.9) -- 1883
		elseif self.phaseTick >= 60 then -- 1883
			self.phase = "prologue-follow" -- 1885
			self.phaseTick = 0 -- 1886
			child.crouch = false -- 1887
			child.h = CHILD_H -- 1888
			self:flashSet("她跟上了", 1.2) -- 1889
		end -- 1889
		return -- 1891
	end -- 1891
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 1891
		self:requestRoom("street", "序章跟到门口") -- 1895
		self:flashSet("进街道", 1.2) -- 1896
	end -- 1896
end -- 1836
function Play.prototype.stepStreet(self, dt, input) -- 1901
	local p = self.player -- 1902
	local c = self.partner -- 1903
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 1903
		self:requestRoom("checkpoint", "两人都到街尾") -- 1905
		self:flashSet("到检查站", 1.2) -- 1906
	end -- 1906
end -- 1901
function Play.prototype.stepGate(self, dt, input) -- 1911
	local ____temp_35 -- 1912
	if self.room.story == nil then -- 1912
		____temp_35 = nil -- 1912
	else -- 1912
		____temp_35 = self.room.story.gate -- 1912
	end -- 1912
	local g = ____temp_35 -- 1912
	if g == nil then -- 1912
		return -- 1914
	end -- 1914
	local p = self.player -- 1916
	if self.phase == "gate-idle" then -- 1916
		local a = self.partner -- 1919
		local gap = g.waitX - a.x -- 1920
		if math.abs(gap) > 3 then -- 1920
			a.facing = gap > 0 and 1 or -1 -- 1922
			a.vx = a.facing * CHILD_SPEED -- 1923
			local beforeX = a.x -- 1924
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 1925
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 1925
				a.vy = CHILD_JUMP -- 1927
				a.onGround = false -- 1928
			end -- 1928
			self:fallY(a, dt) -- 1930
		else -- 1930
			a.vx = 0 -- 1932
			a.x = g.waitX -- 1933
		end -- 1933
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 1936
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 1937
		if self.gateNeedConfirm then -- 1937
			if not input.interact.held then -- 1937
				self.gateRestartArmed = true -- 1942
			end -- 1942
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 1942
				self.gateNeedConfirm = false -- 1945
				self.gateRestartArmed = true -- 1946
				self.phase = "gate-hold" -- 1947
				self.gateTick = 0 -- 1948
				self.gateSpawned = 0 -- 1949
				self:flashSet("重新就位 · 守点开始", 1.4) -- 1950
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 1951
			end -- 1951
			return -- 1953
		end -- 1953
		if atWinch and atWait then -- 1953
			self.phase = "gate-hold" -- 1956
			self.gateTick = 0 -- 1957
			self.gateSpawned = 0 -- 1958
			self:flashSet("两人就位 · 守点开始", 1.4) -- 1959
		end -- 1959
		return -- 1961
	end -- 1961
	if self.phase == "gate-hold" then -- 1961
		self.gateTick = self.gateTick + 1 -- 1964
		local marks = {0, 540, 900, 1500} -- 1966
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 1966
			local idx = self.gateSpawned -- 1968
			local ____self_enemies_36 = self.enemies -- 1968
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 1969
				x = self.ox + 620 + idx * 62, -- 1970
				y = 0, -- 1970
				w = 26, -- 1970
				h = 84, -- 1970
				alive = true, -- 1971
				hitT = 0, -- 1971
				warnT = 0, -- 1971
				fireCd = 90 + idx * 45 -- 1971
			} -- 1971
			self.gateSpawned = self.gateSpawned + 1 -- 1973
			self:flashSet( -- 1974
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 1974
				0.9 -- 1974
			) -- 1974
		end -- 1974
		if self.gateTick == 900 then -- 1974
			self:flashSet("灯灭了", 1) -- 1977
		elseif self.gateTick == 2100 then -- 1977
			self:flashSet("门底压下来了", 1) -- 1979
		end -- 1979
		if self.gateTick >= g.holdTicks then -- 1979
			self:captureGateBlood() -- 1984
			self.phase = "gate-send" -- 1985
			self.phaseTick = 0 -- 1986
			self.enemies = {} -- 1988
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1989
		end -- 1989
		return -- 1991
	end -- 1991
	if self.phase == "gate-send" then -- 1991
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 1994
		if near and input.interact.pressed then -- 1994
			self:commitRoute() -- 1997
			self:swapToChild(g.doorX + 30) -- 1998
			self.phase = "gate-count" -- 1999
			self.countTick = 0 -- 2000
			self.countArmed = false -- 2002
			self.countPrevMove = input.moveX -- 2003
			self:flashSet("门开了 · 送她出去", 1.8) -- 2004
		end -- 2004
		return -- 2006
	end -- 2006
	if self.phase == "gate-count" then -- 2006
		self.countTick = self.countTick + 1 -- 2009
		if self.countTick == 360 then -- 2009
			self:flashSet("门关上", 0.9) -- 2011
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2011
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2013
			if self.storyRoute == "soldier" then -- 2013
				self.phase = "gate-wait" -- 2019
				self.phaseTick = 0 -- 2020
				self.knocks = 1 -- 2021
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2022
				self.handArmed = not input.interact.held -- 2024
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2025
			else -- 2025
				self:flashSet("数到二十", 2.2) -- 2027
			end -- 2027
		end -- 2027
		local prevMove = self.countPrevMove -- 2032
		self.countPrevMove = input.moveX -- 2033
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2033
			if prevMove <= 0 and input.moveX > 0 then -- 2033
				self.countArmed = true -- 2036
			end -- 2036
			if self.countArmed and input.moveX > 0 then -- 2036
				self.phase = "gate-walk" -- 2039
				self.phaseTick = 0 -- 2040
				self:flashSet("她迈出第一步", 1.4) -- 2041
				self:emit("storyExit", { -- 2042
					route = "child", -- 2042
					via = "walk", -- 2042
					countTick = self.countTick, -- 2042
					hp = self.hp, -- 2042
					maxHp = self.maxHp -- 2042
				}) -- 2042
			end -- 2042
		end -- 2042
		return -- 2045
	end -- 2045
	if self.phase == "gate-wait" then -- 2045
		self.phaseTick = self.phaseTick + 1 -- 2049
		if self.phaseTick == 12 then -- 2049
			self.knocks = 2 -- 2051
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2052
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2053
		end -- 2053
		if not input.interact.held then -- 2053
			if self.handTicks > 0 then -- 2053
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2057
			end -- 2057
			self.handTicks = 0 -- 2059
			self.handArmed = true -- 2060
			return -- 2061
		end -- 2061
		if self.handArmed then -- 2061
			self.handTicks = self.handTicks + 1 -- 2064
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2064
				self.phase = "gate-hand" -- 2066
				self.phaseTick = 0 -- 2067
				self.handDone = true -- 2068
				self.tied = true -- 2069
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2070
				if not self.lineSaid then -- 2070
					self.lineSaid = true -- 2072
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2073
				end -- 2073
				self:flashSet("我们走吧。", 3) -- 2075
			end -- 2075
		end -- 2075
		return -- 2078
	end -- 2078
	if self.phase == "gate-hand" then -- 2078
		self.phaseTick = self.phaseTick + 1 -- 2082
		if self.phaseTick == 30 then -- 2082
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2084
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2084
			self:emit("storyExit", { -- 2086
				route = "soldier", -- 2086
				via = "hand", -- 2086
				handTicks = self.handTicks, -- 2086
				hp = self.hp, -- 2086
				maxHp = self.maxHp -- 2086
			}) -- 2086
			self:requestRoom("gatepath", "牵手同行") -- 2087
		end -- 2087
		return -- 2089
	end -- 2089
	if self.phase == "gate-walk" then -- 2089
		if self.player.x >= g.exitX then -- 2089
			self:requestRoom("outside", "走出城门") -- 2094
			self:flashSet("出城门 · 城外", 1.4) -- 2095
		end -- 2095
	end -- 2095
end -- 1911
function Play.prototype.captureGateBlood(self) -- 2104
	self.hpAtGate = self.hp -- 2105
	self.maxHpAtGate = self.maxHp -- 2106
end -- 2104
function Play.prototype.commitRoute(self) -- 2113
	if self.storySettled then -- 2113
		return -- 2115
	end -- 2115
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2117
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2118
	self.hpAtGate = hp -- 2119
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2120
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2121
	self.storySettled = true -- 2122
	self:emit("storyRouteLocked", { -- 2123
		route = self.storyRoute, -- 2124
		hp = self.hp, -- 2124
		maxHp = self.maxHp, -- 2124
		hpAtGate = self.hpAtGate, -- 2125
		maxHpAtGate = self.maxHpAtGate -- 2125
	}) -- 2125
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2127
end -- 2113
function Play.prototype.syncStory(self) -- 2131
	if self.isCampaign and self.run.trial ~= nil then -- 2131
		return -- 2133
	end -- 2133
	local s = self.run.story -- 2135
	if s == nil then -- 2135
		return -- 2137
	end -- 2137
	s.hp = self.hp -- 2139
	s.maxHp = self.maxHp -- 2140
	s.route = self.storyRoute -- 2141
	s.settled = self.storySettled -- 2142
	s.hpAtGate = self.hpAtGate -- 2143
	s.maxHpAtGate = self.maxHpAtGate -- 2144
	s.handDone = self.handDone -- 2145
	s.lineSaid = self.lineSaid -- 2146
	s.tied = self.tied -- 2147
	s.carry = self.carryOn -- 2148
	s.escortDone = self.escortDone -- 2149
	s.craftedWeapon = self.run.story.craftedWeapon -- 2150
	s.ending = self.run.story.ending -- 2151
	if self.room.key == "gate" then -- 2151
		s.phase = self.phase -- 2153
		s.countTick = self.countTick -- 2154
		s.phaseTick = self.phaseTick -- 2155
		s.handTicks = self.handTicks -- 2156
	end -- 2156
end -- 2131
function Play.prototype.stepGatePath(self) -- 2161
	local ____temp_37 -- 2162
	if self.room.story == nil then -- 2162
		____temp_37 = nil -- 2162
	else -- 2162
		____temp_37 = self.room.story.gatepath -- 2162
	end -- 2162
	local gp = ____temp_37 -- 2162
	if self.phase == "gatepath-start" then -- 2162
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2162
			self.carryOn = true -- 2165
			self.phase = "gatepath-carry" -- 2166
			self.phaseTick = 0 -- 2167
			self.pathDone = true -- 2168
			self.escortDone = false -- 2169
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2170
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2171
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2172
		end -- 2172
		return -- 2174
	end -- 2174
	if self.phase == "gatepath-carry" then -- 2174
		self.phaseTick = self.phaseTick + 1 -- 2177
		if self.phaseTick == 20 then -- 2177
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2179
		end -- 2179
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2179
			self:requestRoom(gp.next, "背负进首战") -- 2182
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2183
		end -- 2183
	end -- 2183
end -- 2161
function Play.prototype.carryPose(self) -- 2192
	local p = self.player -- 2193
	local a = self.partner -- 2194
	a.alive = true -- 2195
	a.x = p.x - p.facing * 12 -- 2196
	a.y = p.y + 26 -- 2197
	a.depth = p.depth -- 2198
	a.vx = p.vx -- 2199
	a.vy = 0 -- 2200
	a.onGround = true -- 2201
	a.crouch = false -- 2202
	a.h = CHILD_CROUCH_H -- 2203
	a.facing = p.facing -- 2204
end -- 2192
function Play.prototype.stepTower(self, dt, input) -- 2208
	local ____temp_38 -- 2209
	if self.room.story == nil then -- 2209
		____temp_38 = nil -- 2209
	else -- 2209
		____temp_38 = self.room.story.tower -- 2209
	end -- 2209
	local t = ____temp_38 -- 2209
	if t == nil then -- 2209
		return -- 2211
	end -- 2211
	if self.phase == "tower-wait" then -- 2211
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2214
		if near and input.interact.pressed then -- 2214
			self.phase = "tower-knock" -- 2216
			self.phaseTick = 0 -- 2217
			self.knocks = 1 -- 2218
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2219
			self:flashSet("敲一下", 0.6) -- 2220
		end -- 2220
		return -- 2222
	end -- 2222
	if self.phase == "tower-knock" then -- 2222
		self.phaseTick = self.phaseTick + 1 -- 2225
		if self.phaseTick == 12 then -- 2225
			self.knocks = 2 -- 2227
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2228
			self:flashSet("敲两下 · 第二声", 1) -- 2229
		elseif self.phaseTick >= t.knockTicks then -- 2229
			self.phase = "tower-given" -- 2231
			self.phaseTick = 0 -- 2232
			self:flashSet("门开了 · 提灯", 1.4) -- 2233
		end -- 2233
		return -- 2235
	end -- 2235
	if self.phase == "tower-given" then -- 2235
		local soldier = self.storyRoute == "soldier" -- 2240
		self.phaseTick = self.phaseTick + 1 -- 2241
		if self.phaseTick == 60 then -- 2241
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2243
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2244
		elseif self.phaseTick == 120 then -- 2244
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2246
		elseif self.phaseTick >= 180 then -- 2246
			self.phase = "tower-end" -- 2248
			self.phaseTick = 0 -- 2249
			if not self.run.finished then -- 2249
				self.run.finished = true -- 2251
				local ending = soldier and "reunion" or "lamp" -- 2252
				self.run.story.ending = ending -- 2253
				local ____soldier_39 -- 2256
				if soldier then -- 2256
					____soldier_39 = self.run.story.segments.escort5 == true -- 2257
				else -- 2257
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2258
				end -- 2258
				local played = ____soldier_39 -- 2256
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2259
				if official then -- 2259
					if soldier then -- 2259
						self.run.archive.soldierCleared = true -- 2263
					else -- 2263
						self.run.archive.childCleared = true -- 2265
					end -- 2265
					self.archiveDirty = true -- 2267
				end -- 2267
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2269
				self:emit("endingReached", { -- 2270
					route = soldier and "soldier" or "child", -- 2271
					ending = ending, -- 2272
					official = official, -- 2273
					source = self.run.source, -- 2274
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2275
					childCleared = self.run.archive.childCleared, -- 2276
					soldierCleared = self.run.archive.soldierCleared, -- 2277
					artifactOwned = self.run.archive.artifactOwned, -- 2278
					equipped = self.equippedWeapon -- 2279
				}) -- 2279
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2281
			end -- 2281
		end -- 2281
		return -- 2284
	end -- 2284
	if input.interact.pressed or input.retry.pressed then -- 2284
		self.restartStory = true -- 2288
		self:requestRoom("prologue", "片尾再玩") -- 2289
		self:flashSet("回到序章", 1.4) -- 2290
	end -- 2290
end -- 2208
function Play.prototype.stepChase(self, dt, input) -- 2295
	if self.caughtT > 0 then -- 2295
		self.caughtT = self.caughtT - dt -- 2297
		if self.caughtT <= 0 then -- 2297
			self:recoverFromCaught() -- 2299
		end -- 2299
		return -- 2301
	end -- 2301
	if self.room.key == "village" then -- 2301
		self:stepScavChase() -- 2304
	elseif self.room.key == "forest" then -- 2304
		self:stepDog(dt) -- 2306
		if self.player.x >= self.ox + 1450 then -- 2306
			self:requestRoom("tower", "到林缘北塔") -- 2309
			self:flashSet("林缘 · 北塔", 1.4) -- 2310
		end -- 2310
	end -- 2310
end -- 2295
function Play.prototype.stepScavChase(self) -- 2316
	local s = self.room.scavenger -- 2317
	if s == nil then -- 2317
		return -- 2319
	end -- 2319
	local p = self.player -- 2321
	if self.passed and p.x > self.ox + 440 then -- 2321
		if self.scavChase then -- 2321
			self.scavChase = false -- 2325
			self.scavState = "back" -- 2326
			self.scavT = 0 -- 2327
		end -- 2327
		return -- 2329
	end -- 2329
	local dx = p.x - self.scavX -- 2331
	local dist = math.abs(dx) -- 2332
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2333
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2334
	if not self.scavChase then -- 2334
		if visible then -- 2334
			self.scavSee = self.scavSee + 1 -- 2337
			if self.scavSee >= 24 then -- 2337
				self.scavChase = true -- 2339
				self.scavState = "chase" -- 2340
				self.scavTargetX = p.x -- 2341
				self:flashSet("他看见你了", 1.2) -- 2342
			end -- 2342
		else -- 2342
			self.scavSee = 0 -- 2345
		end -- 2345
		return -- 2347
	end -- 2347
	local dir = p.x > self.scavX and 1 or -1 -- 2350
	self.scavX = self.scavX + dir * 96 / 60 -- 2351
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2351
		self:caught() -- 2353
		return -- 2354
	end -- 2354
	if hidden then -- 2354
		self.scavSee = 0 -- 2358
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2359
		self.scavT = self.scavT - 1 -- 2360
		if self.scavT <= 0 then -- 2360
			self.scavChase = false -- 2362
			self.scavState = "patrol" -- 2363
			self:flashSet("他失去了目标", 1) -- 2364
		end -- 2364
	end -- 2364
end -- 2316
function Play.prototype.stepDog(self, dt) -- 2370
	local ____temp_40 -- 2371
	if self.room.story == nil then -- 2371
		____temp_40 = nil -- 2371
	else -- 2371
		____temp_40 = self.room.story.dog -- 2371
	end -- 2371
	local dog = ____temp_40 -- 2371
	if dog == nil then -- 2371
		return -- 2373
	end -- 2373
	local p = self.player -- 2375
	local dist = math.abs(p.x - self.dogX) -- 2376
	if self.dogState == "patrol" then -- 2376
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2378
		if self.dogX < dog.x0 then -- 2378
			self.dogX = dog.x0 -- 2380
			self.dogDir = 1 -- 2381
		elseif self.dogX > dog.x1 then -- 2381
			self.dogX = dog.x1 -- 2383
			self.dogDir = -1 -- 2384
		end -- 2384
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2386
		if not p.crouch and moving and dist < dog.range then -- 2386
			self.dogState = "ear" -- 2388
			self.dogT = 18 -- 2389
			self.dogTargetX = p.x -- 2390
			self:flashSet("狗转耳朵", 0.8) -- 2391
		end -- 2391
		return -- 2393
	end -- 2393
	if self.dogState == "ear" then -- 2393
		self.dogT = self.dogT - 1 -- 2396
		if self.dogT <= 0 then -- 2396
			self.dogState = "chase" -- 2398
			self.dogTargetX = p.x -- 2399
			self:flashSet("狗追来了", 1.4) -- 2400
		end -- 2400
		return -- 2402
	end -- 2402
	if self.dogState == "chase" then -- 2402
		local dir = p.x > self.dogX and 1 or -1 -- 2405
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2406
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2406
			self:caught() -- 2408
			self.dogState = "sniff" -- 2409
			self.dogT = 60 -- 2410
		elseif dist > dog.range * 1.5 or p.crouch then -- 2410
			self.dogState = "sniff" -- 2412
			self.dogT = 60 -- 2413
			self:flashSet("狗停下了", 0.9) -- 2414
		end -- 2414
		return -- 2416
	end -- 2416
	if self.dogState == "sniff" then -- 2416
		self.dogT = self.dogT - 1 -- 2419
		if self.dogT <= 0 then -- 2419
			self.dogState = "back" -- 2421
		end -- 2421
		return -- 2423
	end -- 2423
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2426
	self.dogX = self.dogX + dir * dog.speed * dt -- 2427
	if math.abs(self.dogX - dog.x0) < 2 then -- 2427
		self.dogX = dog.x0 -- 2429
		self.dogState = "patrol" -- 2430
	end -- 2430
end -- 2370
function Play.prototype.caught(self) -- 2434
	self.caughtT = 1 -- 2435
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2436
end -- 2434
function Play.prototype.recoverFromCaught(self) -- 2440
	local p = self.player -- 2441
	p.x = self.ox + 140 -- 2442
	p.y = 0 -- 2443
	p.vy = 0 -- 2444
	p.vx = 0 -- 2445
	p.onGround = true -- 2446
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2446
		self.scavX = self.room.scavenger.x0 -- 2448
		self.scavState = "patrol" -- 2449
		self.scavSee = 0 -- 2450
		self.scavChase = false -- 2451
		self.scavT = 0 -- 2452
	end -- 2452
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2452
		self.dogX = self.room.story.dog.x0 -- 2455
		self.dogState = "patrol" -- 2456
		self.dogT = 0 -- 2457
	end -- 2457
	self.cam.x = p.x -- 2459
	self.cam.y = p.y + CAM_LOOK_UP -- 2460
	self:flashSet("回到安全点", 1.2) -- 2461
end -- 2440
function Play.prototype.updateGate(self) -- 2465
	if self.room.key ~= "checkpoint" then -- 2465
		self.gateOpen = false -- 2467
		return -- 2468
	end -- 2468
	local function inZone(x) -- 2470
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2470
	end -- 2470
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2471
end -- 2465
function Play.prototype.addItem(self, kind) -- 2477
	local inv = self.run.inventory -- 2478
	if kind == "shield" then -- 2478
		if inv.shield >= TOOL_CAP then -- 2478
			return false -- 2481
		end -- 2481
		inv.shield = inv.shield + 1 -- 2483
		return true -- 2484
	end -- 2484
	if kind == "wedge" then -- 2484
		if inv.wedge >= CONSUMABLE_CAP then -- 2484
			return false -- 2488
		end -- 2488
		inv.wedge = inv.wedge + 1 -- 2490
		return true -- 2491
	end -- 2491
	if kind == "ammo" then -- 2491
		if inv.ammo >= CONSUMABLE_CAP then -- 2491
			return false -- 2495
		end -- 2495
		inv.ammo = inv.ammo + 1 -- 2497
		return true -- 2498
	end -- 2498
	if kind == "scrap" then -- 2498
		inv.scrap = inv.scrap + 1 -- 2502
		return true -- 2503
	end -- 2503
	if kind == "wood" then -- 2503
		inv.wood = inv.wood + 1 -- 2506
		return true -- 2507
	end -- 2507
	if kind == "bell" then -- 2507
		inv.bell = inv.bell + 1 -- 2510
		return true -- 2511
	end -- 2511
	if kind == "pass" then -- 2511
		inv.pass = inv.pass + 1 -- 2514
		return true -- 2515
	end -- 2515
	if kind == "quickbelt" then -- 2515
		inv.quickbelt = inv.quickbelt + 1 -- 2518
		return true -- 2519
	end -- 2519
	return false -- 2521
end -- 2477
function Play.prototype.findBox(self, id) -- 2524
	local i = 0 -- 2525
	do -- 2525
		i = 0 -- 2526
		while i < #self.boxes do -- 2526
			if self.boxes[i + 1].id == id then -- 2526
				return self.boxes[i + 1] -- 2528
			end -- 2528
			i = i + 1 -- 2526
		end -- 2526
	end -- 2526
	return nil -- 2531
end -- 2524
function Play.prototype.findWedgeTarget(self) -- 2535
	local best = nil -- 2536
	local bestD = 0 -- 2537
	local i = 0 -- 2538
	do -- 2538
		i = 0 -- 2539
		while i < #self.boxes do -- 2539
			do -- 2539
				local b = self.boxes[i + 1] -- 2540
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2540
					goto __continue377 -- 2542
				end -- 2542
				if not self:nearBox(b, 26) then -- 2542
					goto __continue377 -- 2545
				end -- 2545
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2547
				if best == nil or d < bestD then -- 2547
					best = b -- 2549
					bestD = d -- 2550
				end -- 2550
			end -- 2550
			::__continue377:: -- 2550
			i = i + 1 -- 2539
		end -- 2539
	end -- 2539
	return best -- 2553
end -- 2535
function Play.prototype.stepCraft(self, input) -- 2561
	local inv = self.run.inventory -- 2562
	local ____opt_41 = self.run.trial -- 2562
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2563
	if self.craftT > 0 then -- 2563
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2563
			self.craftT = 0 -- 2567
			self:flashSet("制作中断", 0.8) -- 2568
			return true -- 2569
		end -- 2569
		self.craftT = self.craftT + 1 -- 2571
		if self.craftT >= required then -- 2571
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2571
				inv.scrap = inv.scrap - 1 -- 2574
				inv.wedge = inv.wedge + 1 -- 2575
				self:flashSet("制得木楔", 1.2) -- 2576
				self:log("制木楔") -- 2577
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2578
			end -- 2578
			self.craftT = 0 -- 2580
		end -- 2580
		return true -- 2582
	end -- 2582
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2582
		self.craftT = 1 -- 2585
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2586
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2587
		return true -- 2588
	end -- 2588
	return false -- 2590
end -- 2561
function Play.prototype.nearBox(self, b, reach) -- 2593
	local p = self.player -- 2594
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2595
end -- 2593
function Play.prototype.findInteract(self) -- 2601
	local p = self.player -- 2602
	local best = nil -- 2603
	local bestD = 1000000000 -- 2604
	local i = 0 -- 2605
	do -- 2605
		i = 0 -- 2606
		while i < #self.boxes do -- 2606
			do -- 2606
				local b = self.boxes[i + 1] -- 2607
				if b.interact == nil or b.broken == true then -- 2607
					goto __continue390 -- 2609
				end -- 2609
				if not self:nearBox(b, b.interact.reach or 27) then -- 2609
					goto __continue390 -- 2612
				end -- 2612
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2614
				if d < bestD then -- 2614
					bestD = d -- 2616
					best = b -- 2617
				end -- 2617
			end -- 2617
			::__continue390:: -- 2617
			i = i + 1 -- 2606
		end -- 2606
	end -- 2606
	return best -- 2620
end -- 2601
function Play.prototype.stepCampaign(self, dt, input) -- 2624
	local wr = self.room -- 2625
	local p = self.player -- 2626
	if self.reloadT > 0 then -- 2626
		self.reloadT = self.reloadT - 1 -- 2628
	end -- 2628
	if self.bracedShield ~= nil then -- 2628
		self.bracedShield.x = p.x + p.facing * 26 -- 2632
		self.bracedShield.y = p.y -- 2633
		local shBox = __TS__ArrayFind( -- 2634
			self.boxes, -- 2634
			function(____, b) return b.id == "braced_shield" end -- 2634
		) -- 2634
		if shBox ~= nil then -- 2634
			shBox.x0 = self.bracedShield.x - 15 -- 2636
			shBox.x1 = self.bracedShield.x + 15 -- 2637
			shBox.y0 = self.bracedShield.y -- 2638
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2639
		end -- 2639
	end -- 2639
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2639
		self.run.route = "drygoods" -- 2645
		self.run.joined = false -- 2646
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2647
		self:log("转布行线") -- 2648
	end -- 2648
	if wr.key == "escort3" then -- 2648
		local benchX = wr.minX + 560 -- 2652
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2653
		if self.craftBench.active then -- 2653
			if input.interact.pressed or input.pause.pressed then -- 2653
				self:closeCraftBench() -- 2656
			end -- 2656
		elseif nearBench and input.interact.pressed then -- 2656
			self:openCraftBench() -- 2659
		end -- 2659
	end -- 2659
	local i = 0 -- 2663
	do -- 2663
		i = 0 -- 2664
		while i < #self.pickups do -- 2664
			do -- 2664
				local pk = self.pickups[i + 1] -- 2665
				if pk.id == "" or self.run.taken[pk.id] == true then -- 2665
					goto __continue405 -- 2667
				end -- 2667
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2669
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2670
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2670
					if not self:addItem(pk.kind) then -- 2670
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2674
						self:log("满包拒绝 " .. pk.kind) -- 2675
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2676
						goto __continue405 -- 2677
					end -- 2677
					self.run.taken[pk.id] = true -- 2679
					pk.id = "" -- 2680
					self:flashSet("拾取 " .. pk.label, 1) -- 2681
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2682
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2683
				end -- 2683
			end -- 2683
			::__continue405:: -- 2683
			i = i + 1 -- 2664
		end -- 2664
	end -- 2664
	if not self:stepCraft(input) and input.interact.pressed then -- 2664
		self:campaignInteract() -- 2687
	end -- 2687
	self:stepCampaignCart(dt, input) -- 2689
	self:stepCampaignGoal() -- 2690
	self:campaignCheckpoint() -- 2691
end -- 2624
function Play.prototype.campaignCheckpoint(self) -- 2695
	local i = 0 -- 2696
	do -- 2696
		i = 0 -- 2697
		while i < #self.room.marks do -- 2697
			do -- 2697
				local m = self.room.marks[i + 1] -- 2698
				if m.kind ~= 0 then -- 2698
					goto __continue412 -- 2700
				end -- 2700
				local dx = self.player.x - m.x -- 2702
				local dy = self.player.y - m.y -- 2703
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2703
					self.checkpoint = m.x -- 2705
					self:captureCheckpoint(m.x) -- 2706
					self:flashSet("检查点", 1) -- 2707
				end -- 2707
			end -- 2707
			::__continue412:: -- 2707
			i = i + 1 -- 2697
		end -- 2697
	end -- 2697
end -- 2695
function Play.prototype.campaignInteract(self) -- 2713
	local b = self:findInteract() -- 2714
	if b ~= nil then -- 2714
		self:useInteract(b) -- 2716
		return -- 2717
	end -- 2717
	local inv = self.run.inventory -- 2719
	if inv.wedge > 0 then -- 2719
		local w = self:findWedgeTarget() -- 2721
		if w ~= nil then -- 2721
			if w.breakable ~= nil then -- 2721
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 2721
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 2724
			end -- 2724
			inv.wedge = inv.wedge - 1 -- 2726
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 2727
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 2729
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 2730
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 2731
			return -- 2732
		end -- 2732
	end -- 2732
	if inv.ammo > 0 and self.reloadT > 0 then -- 2732
		self.reloadT = 0 -- 2737
		self:closeReloadPuzzle() -- 2738
		inv.ammo = inv.ammo - 1 -- 2739
		self:flashSet("备用弹包 · 膛内补满", 1) -- 2740
		self:log("用备用弹包") -- 2741
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 2742
		return -- 2743
	end -- 2743
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 2743
		local p = self.player -- 2747
		self.bracedShield = { -- 2748
			x = p.x + p.facing * 26, -- 2748
			y = p.y, -- 2748
			w = 30, -- 2748
			h = 64, -- 2748
			hp = 1 -- 2748
		} -- 2748
		local ____self_boxes_45 = self.boxes -- 2748
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 2749
			x0 = self.bracedShield.x - 15, -- 2750
			x1 = self.bracedShield.x + 15, -- 2750
			y0 = p.y, -- 2751
			y1 = p.y + 64, -- 2751
			depth = {min = -46, max = 46}, -- 2751
			label = "架起的残盾", -- 2751
			id = "braced_shield", -- 2751
			soft = true -- 2752
		} -- 2752
		inv.shield = inv.shield - 1 -- 2755
		self:flashSet("架残盾 · 挡一发", 1.2) -- 2756
		self:log("架残盾") -- 2757
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 2758
		return -- 2759
	end -- 2759
	if inv.pass > 0 and self.run.joined == false then -- 2759
		inv.pass = inv.pass - 1 -- 2762
		self.run.joined = true -- 2763
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 2764
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 2765
		return -- 2766
	end -- 2766
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 2768
end -- 2713
function Play.prototype.useInteract(self, b) -- 2771
	local kind = b.interact == nil and "" or b.interact.kind -- 2772
	local wr = self.room -- 2773
	if kind == "open_board" then -- 2773
		b.broken = true -- 2775
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 2776
		for ____, cover in ipairs(self.boxes) do -- 2777
			if cover.id == "s2_board_cover" then -- 2777
				cover.broken = false -- 2779
				cover.hidden = false -- 2780
			end -- 2780
		end -- 2780
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 2783
		self.run.joined = true -- 2784
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 2785
		self:log("放下窗板") -- 2786
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 2787
		return -- 2788
	end -- 2788
	if kind == "lower_curtain" then -- 2788
		for ____, curtain in ipairs(self.boxes) do -- 2791
			if curtain.id == "c2_curtain" then -- 2791
				curtain.broken = false -- 2793
				curtain.hidden = false -- 2794
			end -- 2794
		end -- 2794
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 2797
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 2798
		self:log("放下木帘") -- 2799
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 2800
		return -- 2801
	end -- 2801
	if kind == "raise_latch" then -- 2801
		if wr.key == "c2-granary" and not self.cartDocked then -- 2801
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 2805
			return -- 2806
		end -- 2806
		b.broken = true -- 2808
		self.objectiveDone = true -- 2809
		if wr.key == "c1-yard" then -- 2809
			self.run.c1Latch = true -- 2812
			self.run.joined = true -- 2813
		else -- 2813
			self.run.c2Latch = true -- 2815
			self.run.joined = true -- 2816
		end -- 2816
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 2818
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 2819
		self:log("抬闩") -- 2820
		self:flashSet("抬闩 · 通路打开", 1.4) -- 2821
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 2822
	end -- 2822
end -- 2771
function Play.prototype.stepCampaignCart(self, dt, input) -- 2827
	local wr = self.room -- 2828
	local c = wr.cart -- 2829
	if c.bodyW <= 0 then -- 2829
		return -- 2831
	end -- 2831
	local p = self.player -- 2833
	local handleX = self.cartAxle + c.handleOffset -- 2834
	if not self.gripping then -- 2834
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 2834
			self.gripping = true -- 2838
			self:flashSet("握住车柄 · A/D 推", 1) -- 2839
		end -- 2839
		return -- 2841
	end -- 2841
	if input.interact.pressed then -- 2841
		self.gripping = false -- 2844
		self:flashSet("松手", 0.5) -- 2845
		return -- 2846
	end -- 2846
	if not self.cartDocked then -- 2846
		if input.moveX ~= 0 and not self:stuckCart() then -- 2846
			self.cartAxle = math.max( -- 2850
				c.startX, -- 2850
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 2850
			) -- 2850
		end -- 2850
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 2850
			self.cartExposed = true -- 2855
			local gun = nil -- 2856
			local gi = 0 -- 2857
			do -- 2857
				gi = 0 -- 2858
				while gi < #self.enemies do -- 2858
					local e = self.enemies[gi + 1] -- 2859
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 2859
						gun = e -- 2861
						break -- 2862
					end -- 2862
					gi = gi + 1 -- 2858
				end -- 2858
			end -- 2858
			if gun ~= nil then -- 2858
				self:campaignEnemyFire(gun) -- 2866
			end -- 2866
		end -- 2866
		p.x = self.cartAxle + c.handleOffset -- 2869
		p.y = c.baseY + (c.depth or 0) -- 2870
		p.vx = 0 -- 2871
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 2871
			self.cartAxle = c.endX -- 2873
			self.cartDocked = true -- 2874
			self.gripping = false -- 2875
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 2876
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 2877
			self:flashSet("车轮入窝", 1.2) -- 2878
			self:log("车轮入窝") -- 2879
		end -- 2879
	end -- 2879
end -- 2827
function Play.prototype.stuckCart(self) -- 2885
	local i = 0 -- 2886
	do -- 2886
		i = 0 -- 2887
		while i < #self.boxes do -- 2887
			do -- 2887
				local b = self.boxes[i + 1] -- 2888
				if b.broken == true or b.breakable == nil or b.soft == true then -- 2888
					goto __continue451 -- 2890
				end -- 2890
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 2892
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 2892
					return true -- 2894
				end -- 2894
			end -- 2894
			::__continue451:: -- 2894
			i = i + 1 -- 2887
		end -- 2887
	end -- 2887
	return false -- 2897
end -- 2885
function Play.prototype.stepCampaignGoal(self) -- 2901
	local wr = self.room -- 2902
	local c = wr.campaign -- 2903
	if c == nil then -- 2903
		return -- 2905
	end -- 2905
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 2905
		self.objectiveDone = true -- 2908
	end -- 2908
	if c.goal == "reach_exit" then -- 2908
		self.objectiveDone = true -- 2911
	end -- 2911
	if not self.objectiveDone then -- 2911
		return -- 2914
	end -- 2914
	local p = self.player -- 2916
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 2917
	if p.x < c.exitX or not partnerOk then -- 2917
		return -- 2919
	end -- 2919
	if self.run.story.segments[wr.key] ~= true then -- 2919
		self.run.story.segments[wr.key] = true -- 2923
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 2924
	end -- 2924
	if wr.key == "escort5" then -- 2924
		self.escortDone = true -- 2928
		self.run.story.escortDone = true -- 2929
	end -- 2929
	if c.next ~= nil and c.next ~= "" then -- 2929
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 2932
		self:flashSet("过关 · " .. c.next, 1.2) -- 2933
	elseif not self.run.finished then -- 2933
		self.run.finished = true -- 2935
		self:flashSet( -- 2936
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 2936
			2 -- 2936
		) -- 2936
		self:log("C2 灰盒完成") -- 2937
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 2938
	end -- 2938
end -- 2901
function Play.prototype.stepCampaignPartner(self, dt) -- 2943
	local a = self.partner -- 2944
	local wr = self.room -- 2945
	local cp = wr.companion -- 2946
	if not a.alive then -- 2946
		return -- 2948
	end -- 2948
	local p = self.player -- 2950
	if self.craftBench.active then -- 2950
		a.vx = 0 -- 2953
		return -- 2954
	end -- 2954
	local wait = false -- 2956
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 2957
	local targetDepth = p.depth -- 2958
	if self.run.joined == false then -- 2958
		wait = true -- 2960
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2961
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2962
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 2962
		wait = true -- 2964
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2965
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2966
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 2966
		wait = true -- 2968
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 2969
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 2970
	end -- 2970
	if self.partnerStuck > 0.3 then -- 2970
		a.x = a.x + a.facing * 44 -- 2974
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 2975
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2976
		self.partnerLaneHold = 1.1 -- 2977
		self.partnerStuck = 0 -- 2978
	end -- 2978
	if self.partnerLaneHold > 0 then -- 2978
		self.partnerLaneHold = self.partnerLaneHold - dt -- 2981
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 2982
	end -- 2982
	local dx = targetX - a.x -- 2984
	if not wait and math.abs(dx) > 74 then -- 2984
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 2986
		local before = a.x -- 2987
		a.vx = dx > 0 and speed or -speed -- 2988
		a.facing = dx > 0 and 1 or -1 -- 2989
		self:slideX(a, a.vx * dt) -- 2990
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 2990
			a.vy = CHILD_JUMP -- 2993
			a.onGround = false -- 2994
		end -- 2994
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 2996
	else -- 2996
		a.vx = 0 -- 2998
		self.partnerStuck = 0 -- 2999
	end -- 2999
	local dz = targetDepth - a.depth -- 3001
	if math.abs(dz) > 6 then -- 3001
		local step = math.max( -- 3003
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3003
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3003
		) -- 3003
		a.depth = a.depth + step -- 3004
	end -- 3004
	a.depthSpeed = 0 -- 3006
	a.h = CHILD_H -- 3007
	a.crouch = false -- 3008
	self:fallY(a, dt) -- 3009
end -- 2943
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3013
	local p = self.player -- 3014
	local i = 0 -- 3015
	do -- 3015
		i = 0 -- 3016
		while i < #self.enemies do -- 3016
			do -- 3016
				local ____opt_46 = self.run.trial -- 3016
				if ____opt_46 and ____opt_46.lost then -- 3016
					return -- 3017
				end -- 3017
				local e = self.enemies[i + 1] -- 3018
				if not e.alive then -- 3018
					goto __continue478 -- 3020
				end -- 3020
				if e.hitT > 0 then -- 3020
					e.hitT = e.hitT - dt -- 3023
				end -- 3023
				if e.kind == "target" then -- 3023
					if not e.alive and e.hitT <= 0 then -- 3023
						e.alive = true -- 3028
					end -- 3028
					goto __continue478 -- 3030
				end -- 3030
				if e.kind == "breaker" then -- 3030
					self:stepBreaker(e, dt) -- 3033
					goto __continue478 -- 3034
				end -- 3034
				if e.kind == "shield" then -- 3034
					self:stepShield(e, dt, input) -- 3037
					goto __continue478 -- 3038
				end -- 3038
				local dx = e.x - p.x -- 3041
				if not e.awake then -- 3041
					if math.abs(dx) > 520 then -- 3041
						goto __continue478 -- 3044
					end -- 3044
					e.awake = true -- 3046
					e.fireCd = 48 -- 3047
					goto __continue478 -- 3048
				end -- 3048
				if math.abs(dx) > ENEMY_RANGE then -- 3048
					goto __continue478 -- 3051
				end -- 3051
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3051
					goto __continue478 -- 3056
				end -- 3056
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3056
					goto __continue478 -- 3059
				end -- 3059
				if self:blockedShot(e, p) then -- 3059
					if e.warnT > 0 then -- 3059
						e.warnT = 0 -- 3065
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3066
					end -- 3066
					goto __continue478 -- 3068
				end -- 3068
				if e.warnT > 0 then -- 3068
					e.warnT = e.warnT - 1 -- 3071
					if e.warnT <= 0 then -- 3071
						self:campaignEnemyFire(e) -- 3073
					end -- 3073
				elseif e.fireCd > 0 then -- 3073
					e.fireCd = e.fireCd - 1 -- 3076
					if e.fireCd <= 0 then -- 3076
						e.warnT = WARN_TICKS -- 3078
					end -- 3078
				else -- 3078
					e.fireCd = 40 -- 3081
				end -- 3081
			end -- 3081
			::__continue478:: -- 3081
			i = i + 1 -- 3016
		end -- 3016
	end -- 3016
end -- 3013
function Play.prototype.blockedShot(self, e, p) -- 3087
	local eDepth = e.depth or 0 -- 3088
	local ex = e.x -- 3089
	local ey = e.y + e.h * 0.62 -- 3091
	local px = p.x -- 3092
	local py = p.y + p.h * 0.55 -- 3093
	local dx = px - ex -- 3094
	local dyScreen = py + p.depth - (ey + eDepth) -- 3095
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3096
	if len < 0.01 then -- 3096
		return false -- 3098
	end -- 3098
	local ray = { -- 3102
		x = ex, -- 3103
		y = ey, -- 3103
		dx = dx / len, -- 3104
		dy = (py - ey) / len, -- 3104
		depth = eDepth, -- 3105
		dDepth = (p.depth - eDepth) / len -- 3105
	} -- 3105
	local best = -1 -- 3107
	local j = 0 -- 3108
	do -- 3108
		j = 0 -- 3109
		while j < #self.boxes do -- 3109
			do -- 3109
				local b = self.boxes[j + 1] -- 3110
				if b.broken == true or b.passable == true or b.hidden == true then -- 3110
					goto __continue501 -- 3112
				end -- 3112
				if b.id == "braced_shield" then -- 3112
					goto __continue501 -- 3117
				end -- 3117
				local t = hitBox(ray, b) -- 3119
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3119
					best = t -- 3123
				end -- 3123
			end -- 3123
			::__continue501:: -- 3123
			j = j + 1 -- 3109
		end -- 3109
	end -- 3109
	return best >= 0 -- 3126
end -- 3087
function Play.prototype.campaignEnemyFire(self, e) -- 3129
	local p = self.player -- 3130
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3131
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3131
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3131
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3133
		self.boxes = __TS__ArrayFilter( -- 3134
			self.boxes, -- 3134
			function(____, b) return b.id ~= "braced_shield" end -- 3134
		) -- 3134
		self.bracedShield = nil -- 3135
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3136
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3137
		return -- 3138
	end -- 3138
	if self:blockedShot(e, p) then -- 3138
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3141
		return -- 3142
	end -- 3142
	local cover = self:blockedByCover(e, p) -- 3144
	if cover ~= nil and self.coverHug then -- 3144
		self.coveredFlash = 0.5 -- 3146
		self:flashSet("掩体挡下", 0.6) -- 3147
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3148
		return -- 3153
	end -- 3153
	if self.invulnT > 0 then -- 3153
		return -- 3156
	end -- 3156
	local ____opt_50 = self.run.trial -- 3156
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3158
	self.craftT = 0 -- 3159
	self.hp = self.hp - 1 -- 3160
	self:emit("actorHit", { -- 3161
		target = "player", -- 3161
		amount = 1, -- 3161
		hp = self.hp, -- 3161
		maxHp = self.maxHp, -- 3161
		enemyX = e.x -- 3161
	}) -- 3161
	self:flashSet( -- 3162
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3162
		0.8 -- 3162
	) -- 3162
	if self.hp <= 0 then -- 3162
		self:campaignFailed() -- 3164
	end -- 3164
end -- 3129
function Play.prototype.stepShield(self, e, dt, input) -- 3169
	local p = self.player -- 3170
	local dx = p.x - e.x -- 3171
	local adx = math.abs(dx) -- 3172
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3175
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3176
	if adx > 150 then -- 3176
		local before = e.x -- 3178
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3179
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3179
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3182
		end -- 3182
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3182
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3187
		local rollDodges = p.rollT > 0 and fromFront -- 3188
		if not rollDodges and self.invulnT <= 0 then -- 3188
			local ____opt_52 = self.run.trial -- 3188
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3190
			self.craftT = 0 -- 3191
			self.hp = self.hp - 1 -- 3192
			self:emit("actorHit", { -- 3193
				target = "player", -- 3193
				amount = 1, -- 3193
				hp = self.hp, -- 3193
				maxHp = self.maxHp, -- 3193
				enemyX = e.x -- 3193
			}) -- 3193
			self:flashSet( -- 3194
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3194
				0.8 -- 3194
			) -- 3194
			if self.hp <= 0 then -- 3194
				self:campaignFailed() -- 3196
				return -- 3197
			end -- 3197
		end -- 3197
		e.swingT = 70 -- 3200
	end -- 3200
	if (e.swingT or 0) > 0 then -- 3200
		e.swingT = (e.swingT or 0) - 1 -- 3203
	end -- 3203
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3203
		local dd = p.depth - (e.depth or 0) -- 3206
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3207
	end -- 3207
end -- 3169
function Play.prototype.stepBreaker(self, e, dt) -- 3212
	local p = self.player -- 3213
	if e.awake ~= true then -- 3213
		if math.abs(p.x - e.x) < 560 then -- 3213
			e.awake = true -- 3216
		else -- 3216
			return -- 3218
		end -- 3218
	end -- 3218
	local target = nil -- 3221
	local bestD = 1000000000 -- 3222
	local i = 0 -- 3223
	do -- 3223
		i = 0 -- 3224
		while i < #self.boxes do -- 3224
			do -- 3224
				local b = self.boxes[i + 1] -- 3225
				if b.breakable == nil or b.broken == true then -- 3225
					goto __continue525 -- 3227
				end -- 3227
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3229
				if d < bestD then -- 3229
					bestD = d -- 3231
					target = b -- 3232
				end -- 3232
			end -- 3232
			::__continue525:: -- 3232
			i = i + 1 -- 3224
		end -- 3224
	end -- 3224
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3235
	local dx = tx - e.x -- 3236
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3237
	if math.abs(dx) > reach then -- 3237
		local before = e.x -- 3239
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3240
		if math.abs(e.x - before) < 0.3 then -- 3240
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3242
		end -- 3242
	elseif (e.swingT or 0) <= 0 then -- 3242
		e.swingT = 64 -- 3245
		if target ~= nil then -- 3245
			self:damageProp(target, 2) -- 3247
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3247
			local ____opt_54 = self.run.trial -- 3247
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3249
			self.craftT = 0 -- 3250
			self.hp = self.hp - 1 -- 3251
			self:emit("actorHit", { -- 3252
				target = "player", -- 3252
				amount = 1, -- 3252
				hp = self.hp, -- 3252
				maxHp = self.maxHp, -- 3252
				enemyX = e.x -- 3252
			}) -- 3252
			self:flashSet("破障手近身", 0.8) -- 3253
			if self.hp <= 0 then -- 3253
				self:campaignFailed() -- 3255
				return -- 3256
			end -- 3256
		end -- 3256
	end -- 3256
	if (e.swingT or 0) > 0 then -- 3256
		e.swingT = (e.swingT or 0) - 1 -- 3261
	end -- 3261
end -- 3212
function Play.prototype.campaignFailed(self) -- 3265
	if self.run.trial ~= nil then -- 3265
		self.run.trial.lost = true -- 3267
		self.wantRoom = "" -- 3268
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3269
		return -- 3270
	end -- 3270
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3270
		self:restartEscortFromDeath() -- 3275
		return -- 3276
	end -- 3276
	local p = self.player -- 3278
	self.hp = self.maxHp -- 3279
	self.invulnT = INVULN_RESPAWN_TICKS -- 3280
	self.reloadT = 0 -- 3281
	self:closeReloadPuzzle() -- 3282
	self.gripping = false -- 3283
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3284
	self:log("被击倒") -- 3285
	p.x = self.room.minX + 90 -- 3286
	p.y = 0 -- 3287
	p.depth = 0 -- 3288
	p.vx = 0 -- 3289
	p.vy = 0 -- 3290
	p.onGround = true -- 3291
	p.rollT = 0 -- 3292
	self.partner.x = p.x - 50 -- 3293
	self.partner.y = 0 -- 3294
	self.partner.depth = 0 -- 3295
	self.cam.x = p.x -- 3296
	local i = 0 -- 3297
	do -- 3297
		i = 0 -- 3298
		while i < #self.enemies do -- 3298
			do -- 3298
				local e = self.enemies[i + 1] -- 3299
				if not e.alive then -- 3299
					goto __continue539 -- 3301
				end -- 3301
				e.x = e.homeX == nil and e.x or e.homeX -- 3303
				e.warnT = 0 -- 3304
				e.fireCd = 40 -- 3305
				e.swingT = 0 -- 3306
				e.awake = false -- 3307
			end -- 3307
			::__continue539:: -- 3307
			i = i + 1 -- 3298
		end -- 3298
	end -- 3298
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3309
end -- 3265
function Play.prototype.isEscortRoom(self) -- 3313
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3314
end -- 3313
function Play.prototype.restartEscortFromDeath(self) -- 3322
	local story = self.run.story -- 3323
	local inv = self.run.inventory -- 3324
	self.hp = self.maxHp -- 3325
	story.hp = self.maxHp -- 3326
	story.cp = nil -- 3327
	self.checkpointSnap = nil -- 3328
	story.carry = false -- 3329
	self.carryOn = false -- 3330
	story.craftedWeapon = "" -- 3331
	self.equippedWeapon = "standard_gun" -- 3332
	story.escortDone = false -- 3333
	self.escortDone = false -- 3334
	story.segments = {} -- 3335
	inv.wood = 0 -- 3336
	inv.bell = 0 -- 3337
	inv.scrap = 0 -- 3338
	inv.wedge = 0 -- 3339
	inv.ammo = 0 -- 3340
	inv.quickbelt = 0 -- 3341
	inv.shield = 0 -- 3342
	inv.pass = 0 -- 3343
	local taken = self.run.taken -- 3344
	local keys = __TS__ObjectKeys(taken) -- 3345
	local i = 0 -- 3346
	do -- 3346
		i = 0 -- 3347
		while i < #keys do -- 3347
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3347
				__TS__Delete(taken, keys[i + 1]) -- 3349
			end -- 3349
			i = i + 1 -- 3347
		end -- 3347
	end -- 3347
	self.run.joined = true -- 3352
	self.reloadT = 0 -- 3353
	self:closeReloadPuzzle() -- 3354
	self.gripping = false -- 3355
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3356
	self:log("男主线失败 · 回 escort1") -- 3357
	self:emit("campaignFailed", { -- 3358
		room = self.room.key, -- 3359
		hp = 0, -- 3359
		maxHp = self.maxHp, -- 3359
		reset = true, -- 3360
		to = "escort1", -- 3360
		route = self.storyRoute -- 3360
	}) -- 3360
	self:requestRoom("escort1", "男主线失败重开") -- 3362
end -- 3322
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3366
	local i = 0 -- 3367
	do -- 3367
		i = 0 -- 3368
		while i < #self.enemies do -- 3368
			do -- 3368
				if i == skipIndex then -- 3368
					goto __continue548 -- 3370
				end -- 3370
				local e = self.enemies[i + 1] -- 3372
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3372
					goto __continue548 -- 3374
				end -- 3374
				e.fireCd = 150 -- 3376
				e.warnT = 0 -- 3377
			end -- 3377
			::__continue548:: -- 3377
			i = i + 1 -- 3368
		end -- 3368
	end -- 3368
end -- 3366
function Play.prototype.stepEnemies(self, dt, input) -- 3381
	local i = 0 -- 3382
	do -- 3382
		i = 0 -- 3383
		while i < #self.enemies do -- 3383
			local e = self.enemies[i + 1] -- 3384
			if e.hitT > 0 then -- 3384
				e.hitT = e.hitT - dt -- 3386
			end -- 3386
			i = i + 1 -- 3383
		end -- 3383
	end -- 3383
	if self.coveredFlash > 0 then -- 3383
		self.coveredFlash = self.coveredFlash - dt -- 3390
	end -- 3390
	if self.isCampaign then -- 3390
		self:stepCampaignEnemies(dt, input) -- 3393
		return -- 3394
	end -- 3394
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3394
		return -- 3398
	end -- 3398
	do -- 3398
		i = 0 -- 3400
		while i < #self.enemies do -- 3400
			do -- 3400
				local e = self.enemies[i + 1] -- 3401
				if not e.alive then -- 3401
					goto __continue559 -- 3403
				end -- 3403
				if e.warnT > 0 then -- 3403
					e.warnT = e.warnT - 1 -- 3406
					if e.warnT <= 0 then -- 3406
						self:enemyFire(e, input) -- 3408
					end -- 3408
					goto __continue559 -- 3410
				end -- 3410
				if e.fireCd > 0 then -- 3410
					e.fireCd = e.fireCd - 1 -- 3413
					if e.fireCd <= 0 then -- 3413
						e.warnT = WARN_TICKS -- 3415
					end -- 3415
				else -- 3415
					e.warnT = WARN_TICKS -- 3419
				end -- 3419
			end -- 3419
			::__continue559:: -- 3419
			i = i + 1 -- 3400
		end -- 3400
	end -- 3400
end -- 3381
function Play.prototype.enemyFire(self, e, input) -- 3425
	local p = self.player -- 3426
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3426
		self:flashSet("枪声响在远处", 0.4) -- 3428
		e.fireCd = FIRE_COOLDOWN -- 3429
		return -- 3430
	end -- 3430
	local cover = self:blockedByCover(e, p) -- 3433
	local hugging = cover ~= nil -- 3434
	self.coverBlocking = hugging -- 3435
	local covered = hugging and input.cover.held -- 3436
	if covered then -- 3436
		self.coveredFlash = 0.5 -- 3438
		self:flashSet("掩体挡下", 0.5) -- 3439
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3440
		e.fireCd = FIRE_COOLDOWN -- 3445
		return -- 3446
	end -- 3446
	self.hp = self.hp - 1 -- 3448
	self:emit("actorHit", { -- 3449
		target = "player", -- 3449
		amount = 1, -- 3449
		hp = self.hp, -- 3449
		maxHp = self.maxHp, -- 3449
		enemyX = e.x -- 3449
	}) -- 3449
	self:flashSet( -- 3450
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3450
		0.7 -- 3450
	) -- 3450
	e.fireCd = FIRE_COOLDOWN -- 3451
	if self.hp <= 0 then -- 3451
		self:gateFailed() -- 3453
	end -- 3453
end -- 3425
function Play.prototype.blockedByCover(self, enemy, p) -- 3458
	local b = self:coverAt(p) -- 3459
	if b == nil then -- 3459
		return nil -- 3461
	end -- 3461
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3463
end -- 3458
function Play.prototype.gateFailed(self) -- 3467
	local ____temp_56 -- 3468
	if self.room.story == nil then -- 3468
		____temp_56 = nil -- 3468
	else -- 3468
		____temp_56 = self.room.story.gate -- 3468
	end -- 3468
	local g = ____temp_56 -- 3468
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3469
	self.hp = self.maxHp -- 3470
	self.gateTick = 0 -- 3471
	self.gateSpawned = 0 -- 3472
	self.enemies = {} -- 3473
	self.gateFailCount = self.gateFailCount + 1 -- 3474
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3476
	self.player.y = 0 -- 3477
	self.player.vy = 0 -- 3478
	self.player.depth = 0 -- 3479
	self.player.depthSpeed = 0 -- 3480
	self.player.onGround = true -- 3481
	self.player.crouch = false -- 3482
	self.player.h = SOLDIER_H -- 3483
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3484
	self.partner.y = 0 -- 3485
	self.partner.vy = 0 -- 3486
	self.partner.depth = 0 -- 3487
	self.partner.depthSpeed = 0 -- 3488
	self.partner.onGround = true -- 3489
	self.cam.x = self.player.x -- 3490
	self.phase = "gate-idle" -- 3491
	self.phaseTick = 0 -- 3492
	self.coverHug = false -- 3493
	self.coverBlocking = false -- 3494
	self.coverEntity = "" -- 3495
	self.gateNeedConfirm = true -- 3496
	self.gateRestartArmed = false -- 3497
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3498
end -- 3467
function Play.prototype.stepInteract(self, dt, input) -- 3501
	local p = self.player -- 3502
	local calmUsed = self.calmConsumed -- 3503
	self.calmConsumed = false -- 3504
	local calming = self.escort.state == "calming" -- 3506
	self.focusCart = false -- 3507
	if self.room.key == "outside" then -- 3507
		local c = self.room.cart -- 3509
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3510
		local dy = p.y - c.baseY -- 3511
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3512
	end -- 3512
	if not calmUsed and not calming then -- 3512
		self:stepCart(dt, input) -- 3516
	end -- 3516
	if calmUsed then -- 3516
		self:flashSet("安抚 · 敲两下", 0.8) -- 3521
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" then -- 3521
		if self.knockT > 0 then -- 3521
			self.knocks = self.knocks + 1 -- 3525
		else -- 3525
			self.knocks = 1 -- 3527
		end -- 3527
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3529
		self.knockT = 1.2 -- 3530
		if self.knocks >= 2 then -- 3530
			self:flashSet("敲两下", 0.8) -- 3532
			self.knocks = 0 -- 3533
		else -- 3533
			self:flashSet("敲一下", 0.5) -- 3535
		end -- 3535
	elseif self.knockT > 0 then -- 3535
		self.knockT = self.knockT - dt -- 3538
		if self.knockT <= 0 then -- 3538
			self.knocks = 0 -- 3540
		end -- 3540
	end -- 3540
	local i = 0 -- 3545
	do -- 3545
		i = 0 -- 3546
		while i < #self.room.marks do -- 3546
			do -- 3546
				local m = self.room.marks[i + 1] -- 3547
				if m.kind ~= 0 then -- 3547
					goto __continue585 -- 3549
				end -- 3549
				local subjects = {self.partner, self.player} -- 3551
				local k = 0 -- 3552
				do -- 3552
					k = 0 -- 3553
					while k < #subjects do -- 3553
						do -- 3553
							local s = subjects[k + 1] -- 3554
							if not s.alive then -- 3554
								goto __continue588 -- 3556
							end -- 3556
							local dx = s.x - m.x -- 3558
							local dy = s.y - m.y -- 3559
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3559
								self.checkpoint = m.x -- 3561
								self.checkpointCartAxle = self.cartAxle -- 3562
								if self.isCampaign then -- 3562
									self:captureCheckpoint(m.x) -- 3565
								end -- 3565
								if self.cartDocked then -- 3565
									self:flashSet("检查点 · 车已落窝", 1) -- 3568
								else -- 3568
									self:flashSet("检查点 · 车还没到位", 1) -- 3570
								end -- 3570
							end -- 3570
						end -- 3570
						::__continue588:: -- 3570
						k = k + 1 -- 3553
					end -- 3553
				end -- 3553
			end -- 3553
			::__continue585:: -- 3553
			i = i + 1 -- 3546
		end -- 3546
	end -- 3546
	self:checkCarryGate() -- 3576
end -- 3501
function Play.prototype.stepVillage(self, dt, input) -- 3580
	if self.room.key ~= "village" then -- 3580
		return -- 3582
	end -- 3582
	local p = self.player -- 3584
	local bottle = self.room.bottle -- 3585
	local scav = self.room.scavenger -- 3586
	if not self.hasBottle and bottle ~= nil then -- 3586
		local dx = p.x - bottle.x -- 3590
		local dy = p.y + p.h * 0.5 - bottle.y -- 3591
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3591
			self.hasBottle = true -- 3593
			self:flashSet("拾起瓶子", 0.8) -- 3594
		end -- 3594
	end -- 3594
	if self.hasBottle then -- 3594
		if input.aim.held then -- 3594
			self.aimHold = self.aimHold + dt -- 3601
			if self.aimHold > 1.2 then -- 3601
				self.aimHold = 1.2 -- 3603
			end -- 3603
			local cached = self:bottleEnd() -- 3606
			self.bottleAimX = cached.x -- 3607
			self.bottleAimY = cached.y -- 3608
		elseif input.aim.released then -- 3608
			if self.aimHold < 0.12 then -- 3608
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3612
				self.aimHold = 0 -- 3613
			else -- 3613
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3615
				self:throwBottle(____end.x, ____end.y) -- 3616
				self.aimHold = 0 -- 3617
			end -- 3617
		end -- 3617
	else -- 3617
		self.aimHold = 0 -- 3621
		self.bottleAimX = -1 -- 3622
	end -- 3622
	local fly = self.bottleFly -- 3627
	if fly ~= nil then -- 3627
		fly.t = fly.t + dt -- 3629
		fly.x = fly.x0 + fly.vx * fly.t -- 3630
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3631
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3632
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3632
			self:landBottle(fly) -- 3634
		end -- 3634
	end -- 3634
	if self.bottleLandT > 0 then -- 3634
		self.bottleLandT = self.bottleLandT - dt -- 3638
	end -- 3638
	if scav ~= nil then -- 3638
		self:stepScav(dt, scav) -- 3642
	end -- 3642
	local line = self.room.passLine -- 3645
	if line ~= nil and not self.passed and p.x >= line then -- 3645
		self.passed = true -- 3647
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3648
	end -- 3648
	if self.passed and p.x >= self.ox + 640 then -- 3648
		self:requestRoom("forest", "过第一院出院") -- 3652
		self:flashSet("出院 · 北塔森林", 1.4) -- 3653
	end -- 3653
end -- 3580
function Play.prototype.bottleEnd(self) -- 3658
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3659
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3662
	return {x = aim.x, y = g} -- 3663
end -- 3658
function Play.prototype.throwBottle(self, tx, ty) -- 3667
	local p = self.player -- 3668
	local dir = tx >= p.x and 1 or -1 -- 3670
	p.facing = dir -- 3671
	local x0 = p.x + dir * 10 -- 3672
	local y0 = p.y + p.h * 0.7 -- 3673
	self.bottleTargetX = tx -- 3674
	self.bottleTargetY = ty -- 3675
	self.bottleSurfaceY = ty -- 3676
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3677
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3678
	self.bottleFly = { -- 3679
		x = x0, -- 3679
		y = y0, -- 3679
		x0 = x0, -- 3679
		y0 = y0, -- 3679
		vx = vx, -- 3679
		vy = vy, -- 3679
		t = 0 -- 3679
	} -- 3679
	self.hasBottle = false -- 3680
	self:flashSet("投出", 0.4) -- 3681
	self:emit( -- 3682
		"bottleThrown", -- 3682
		{ -- 3682
			fromX = x0, -- 3683
			fromY = y0, -- 3684
			targetX = tx, -- 3685
			targetY = ty, -- 3686
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3687
		} -- 3687
	) -- 3687
end -- 3667
function Play.prototype.landBottle(self, fly) -- 3692
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3693
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3694
	local s = self.room.scavenger -- 3695
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3696
	self.bottleFly = nil -- 3697
	self.bottleTargetX = -1 -- 3698
	self.bottleTargetY = 0 -- 3699
	self.bottleSurfaceY = -1 -- 3700
	self.bottleLandX = x -- 3701
	self.bottleLandY = y -- 3702
	self.bottleLandT = 0.9 -- 3703
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3704
	self:hearBottle(x) -- 3705
end -- 3692
function Play.prototype.hearBottle(self, x) -- 3709
	local s = self.room.scavenger -- 3710
	if s == nil then -- 3710
		return -- 3712
	end -- 3712
	if math.abs(x - self.scavX) > s.range then -- 3712
		self:flashSet("落地 · 他没听见", 0.6) -- 3715
		return -- 3716
	end -- 3716
	self.scavState = "turn" -- 3718
	self.scavT = s.hearTicks -- 3719
	self.scavTargetX = x -- 3720
	self:flashSet("砖地一响 · 他转头", 0.9) -- 3721
end -- 3709
function Play.prototype.stepScav(self, dt, s) -- 3725
	if self.scavState == "chase" then -- 3725
		return -- 3728
	end -- 3728
	if self.scavState == "turn" then -- 3728
		self.scavT = self.scavT - 1 -- 3731
		if self.scavT <= 0 then -- 3731
			self.scavState = "walk" -- 3733
		end -- 3733
		return -- 3735
	end -- 3735
	if self.scavState == "walk" then -- 3735
		local d = self.scavTargetX - self.scavX -- 3738
		if math.abs(d) < 4 then -- 3738
			self.scavState = "stall" -- 3740
			self.scavT = s.stallTicks -- 3741
			return -- 3742
		end -- 3742
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 3744
		return -- 3745
	end -- 3745
	if self.scavState == "stall" then -- 3745
		self.scavT = self.scavT - 1 -- 3748
		if self.scavT <= 0 then -- 3748
			self.scavState = "back" -- 3750
		end -- 3750
		return -- 3752
	end -- 3752
	if self.scavState == "back" then -- 3752
		local home = math.max( -- 3755
			s.x0, -- 3755
			math.min(s.x1, self.scavX) -- 3755
		) -- 3755
		if math.abs(home - self.scavX) < 2 then -- 3755
			self.scavState = "patrol" -- 3757
			return -- 3758
		end -- 3758
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 3760
		return -- 3761
	end -- 3761
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 3763
	if self.scavX >= s.x1 then -- 3763
		self.scavX = s.x1 -- 3765
		self.scavDir = -1 -- 3766
	elseif self.scavX <= s.x0 then -- 3766
		self.scavX = s.x0 -- 3768
		self.scavDir = 1 -- 3769
	end -- 3769
end -- 3725
function Play.prototype.stepCart(self, dt, input) -- 3777
	local p = self.player -- 3778
	local c = self.room.cart -- 3779
	if self.gripping then -- 3779
		if not input.interact.held then -- 3779
			self.gripping = false -- 3783
			self:flashSet("松开车把", 0.4) -- 3784
			return -- 3785
		end -- 3785
	else -- 3785
		if not input.interact.pressed then -- 3785
			return -- 3789
		end -- 3789
		if not self:cartHandleInReach(p) then -- 3789
			return -- 3792
		end -- 3792
		local track = c.depth or 0 -- 3794
		if self:limitDepth(p, track) ~= track then -- 3794
			return -- 3796
		end -- 3796
		p.depth = track -- 3798
		p.depthSpeed = 0 -- 3799
		self.gripping = true -- 3800
		self:flashSet("握住车把", 0.4) -- 3801
		return -- 3802
	end -- 3802
	if self.cartDocked then -- 3802
		return -- 3806
	end -- 3806
	local dir = input.moveX -- 3808
	if dir == 0 then -- 3808
		return -- 3810
	end -- 3810
	local lo = math.min(c.startX, c.endX) -- 3812
	local hi = math.max(c.startX, c.endX) -- 3813
	local next = self.cartAxle + dir * CART_SPEED * dt -- 3814
	if next < lo then -- 3814
		next = lo -- 3816
	end -- 3816
	if next > hi then -- 3816
		next = hi -- 3819
	end -- 3819
	local delta = next - self.cartAxle -- 3821
	if delta == 0 then -- 3821
		return -- 3823
	end -- 3823
	self.cartAxle = next -- 3825
	p.x = p.x + delta -- 3826
	p.facing = dir > 0 and 1 or -1 -- 3827
	self:slideX(p, 0) -- 3828
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 3828
		self.gripping = false -- 3830
		self:flashSet("跟不上了，脱手", 0.6) -- 3831
		return -- 3832
	end -- 3832
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 3832
		self.cartDocked = true -- 3835
		self.gripping = false -- 3836
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 3837
		self:flashSet("车轮落窝", 1.2) -- 3838
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 3838
		self:flashSet("车轮回到起点", 0.5) -- 3840
	end -- 3840
end -- 3777
function Play.prototype.requestRoom(self, key, reason) -- 3848
	if self.wantRoom ~= "" then -- 3848
		return -- 3852
	end -- 3852
	self.wantRoom = key -- 3854
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 3855
end -- 3848
function Play.prototype.checkCarryGate(self) -- 3862
	if self.room.key == "checkpoint" then -- 3862
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 3862
			self.carryCartAxle = self.cartAxle -- 3865
			self.carryCartDocked = self.cartDocked -- 3866
			self:requestRoom("gate", "检查站出口") -- 3867
			self:flashSet("出检查站 · 城门", 1.2) -- 3868
		end -- 3868
		return -- 3870
	end -- 3870
	if self.room.key == "outside" then -- 3870
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 3870
			self.carryCartAxle = self.cartAxle -- 3876
			self.carryCartDocked = self.cartDocked -- 3877
			self:requestRoom("village", "墙根走完") -- 3878
			self:flashSet("墙根走完 · 进村口", 1.2) -- 3879
		end -- 3879
	end -- 3879
end -- 3862
function Play.prototype.aimAt(self, wx, wy) -- 3886
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 3887
	self.aimX = s.x -- 3888
	self.aimY = s.y -- 3889
end -- 3886
function Play.prototype.shoot(self, a) -- 3892
	if self.isCampaign and self.reloadT > 0 then -- 3892
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 3894
		return -- 3895
	end -- 3895
	local ox = a.x + a.facing * 8 -- 3897
	local muzzleY = a.y + a.h * 0.72 -- 3898
	local oy = muzzleY + a.depth -- 3899
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3901
	local dx = aim.x - ox -- 3904
	local dy = aim.y - oy -- 3905
	local len = math.sqrt(dx * dx + dy * dy) -- 3906
	if len < 0.001 then -- 3906
		dx = a.facing -- 3908
		dy = 0 -- 3909
	else -- 3909
		dx = dx / len -- 3911
		dy = dy / len -- 3912
	end -- 3912
	if dx ~= 0 then -- 3912
		a.facing = dx > 0 and 1 or -1 -- 3915
	end -- 3915
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 3918
	local hitEnemy = self:raycastEnemies(ray) -- 3919
	local tEnemy = hitEnemy.t -- 3920
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 3921
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 3922
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 3923
	local tWall = solid.t -- 3924
	local rawEffect = self:consumeReloadEffect() -- 3926
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 3927
	local reloadEffect = rawEffect -- 3928
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 3930
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 3931
	self.trace = { -- 3933
		x0 = ox, -- 3933
		y0 = oy, -- 3933
		x1 = ox + dx * t, -- 3933
		y1 = oy + dy * t, -- 3933
		hit = hit -- 3933
	} -- 3933
	self.traceT = 0.12 -- 3934
	self:applyFireDanger(ox) -- 3935
	local killed = false -- 3936
	if hit then -- 3936
		local i = hitEnemy.index -- 3938
		local e = self.enemies[i + 1] -- 3939
		local impactY = oy + dy * tEnemy -- 3940
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 3941
		local shieldTop = e.y + (e.depth or 0) + 64 -- 3942
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 3942
			e.shieldHp = (e.shieldHp or 0) - 1 -- 3944
			e.hitT = 0.3 -- 3945
			self:flashSet( -- 3946
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 3946
				0.8 -- 3946
			) -- 3946
			self:emit("shotResolved", { -- 3947
				hit = true, -- 3948
				enemyIndex = i, -- 3948
				enemyX = e.x, -- 3948
				aimX = aim.x, -- 3948
				aimY = aim.y, -- 3948
				impactX = ox + dx * t, -- 3949
				impactY = oy + dy * t, -- 3949
				shield = true -- 3949
			}) -- 3949
			self:beginReload() -- 3951
			return -- 3952
		end -- 3952
		e.alive = false -- 3954
		e.hitT = 0.4 -- 3955
		killed = true -- 3956
		self:flashSet("命中", 0.6) -- 3957
		self:dropFor(e) -- 3958
		if reloadEffect == "light" and weaponFx == "light" then -- 3958
			self:blindNearby(e, 160, i) -- 3960
		end -- 3960
		if reloadEffect == "push" then -- 3960
			e.x = e.x + a.facing * 46 -- 3963
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 3964
		elseif reloadEffect == "echo" then -- 3964
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 3966
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 3967
		elseif reloadEffect == "light" then -- 3967
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 3969
		end -- 3969
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 3969
		self:damageProp(solid.box, 1) -- 3972
	else -- 3972
		self:flashSet("打空", 0.35) -- 3974
	end -- 3974
	if self.isCampaign then -- 3974
		self:beginReload() -- 3977
	end -- 3977
	self:emit("shotResolved", { -- 3979
		hit = hit, -- 3980
		enemyIndex = hit and hitEnemy.index or -1, -- 3981
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 3982
		aimX = aim.x, -- 3983
		aimY = aim.y, -- 3984
		impactX = ox + dx * t, -- 3985
		impactY = oy + dy * t -- 3986
	}) -- 3986
end -- 3892
function Play.prototype.applyFireDanger(self, shotX) -- 3991
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 3991
		return -- 3993
	end -- 3993
	local dangerX = shotX -- 3995
	local best = -1 -- 3996
	local bestD = 1000000000 -- 3997
	local i = 0 -- 3998
	do -- 3998
		i = 0 -- 3999
		while i < #self.enemies do -- 3999
			do -- 3999
				local e = self.enemies[i + 1] -- 4000
				if not e.alive then -- 4000
					goto __continue669 -- 4002
				end -- 4002
				local d = math.abs(e.x - self.partner.x) -- 4004
				if d < bestD then -- 4004
					bestD = d -- 4006
					best = i -- 4007
				end -- 4007
			end -- 4007
			::__continue669:: -- 4007
			i = i + 1 -- 3999
		end -- 3999
	end -- 3999
	if best >= 0 then -- 3999
		dangerX = self.enemies[best + 1].x -- 4011
	end -- 4011
	local exposed = self:childExposed(dangerX) -- 4013
	local before = self.escort.fear -- 4014
	local dangerId = self.nextDangerId -- 4015
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4016
	self.nextDangerId = self.nextDangerId + 1 -- 4017
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4018
	if after > before then -- 4018
		self:flashSet( -- 4020
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4020
			1 -- 4020
		) -- 4020
	elseif not exposed then -- 4020
		self:flashSet("枪声没够到她", 0.5) -- 4022
	end -- 4022
end -- 3991
function Play.prototype.childExposed(self, dangerX) -- 4027
	local c = self.partner -- 4028
	if not c.alive then -- 4028
		return false -- 4030
	end -- 4030
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4030
		self.boxes, -- 4033
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4033
	) then -- 4033
		return false -- 4034
	end -- 4034
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4034
		return false -- 4037
	end -- 4037
	local toDanger = dangerX - c.x -- 4039
	local toPlayer = self.player.x - c.x -- 4040
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4040
		return false -- 4043
	end -- 4043
	return true -- 4045
end -- 4027
function Play.prototype.raycastEnemies(self, ray) -- 4049
	local best = -1 -- 4050
	local bestI = -1 -- 4051
	do -- 4051
		local i = 0 -- 4052
		while i < #self.enemies do -- 4052
			do -- 4052
				local e = self.enemies[i + 1] -- 4053
				if not e.alive then -- 4053
					goto __continue683 -- 4055
				end -- 4055
				local y = e.y + (e.depth or 0) -- 4057
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4058
				if t >= 0 and (best < 0 or t < best) then -- 4058
					best = t -- 4060
					bestI = i -- 4061
				end -- 4061
			end -- 4061
			::__continue683:: -- 4061
			i = i + 1 -- 4052
		end -- 4052
	end -- 4052
	return {t = best, index = bestI} -- 4064
end -- 4049
function Play.prototype.raycastWorld(self, ray) -- 4067
	return self:raycastSolid(ray).t -- 4068
end -- 4067
function Play.prototype.raycastSolid(self, ray) -- 4072
	local best = -1 -- 4073
	local bestBox = nil -- 4074
	for ____, box in ipairs(self.boxes) do -- 4075
		do -- 4075
			if box.broken == true or box.hidden == true then -- 4075
				goto __continue688 -- 4077
			end -- 4077
			local t = hitBox(ray, box) -- 4082
			if t > 2 and (best < 0 or t < best) then -- 4082
				best = t -- 4085
				bestBox = box -- 4086
			end -- 4086
		end -- 4086
		::__continue688:: -- 4086
	end -- 4086
	if ray.dy < 0 then -- 4086
		local t = -ray.y / ray.dy -- 4090
		if t >= 0 and (best < 0 or t < best) then -- 4090
			best = t -- 4092
			bestBox = nil -- 4093
		end -- 4093
	end -- 4093
	return {t = best, box = bestBox} -- 4096
end -- 4072
function Play.prototype.dropFor(self, e) -- 4100
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4100
		return -- 4102
	end -- 4102
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4102
		return -- 4105
	end -- 4105
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4107
	local ____self_pickups_57 = self.pickups -- 4107
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4108
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4109
		kind = e.drop, -- 4109
		x = e.x, -- 4109
		y = e.y, -- 4109
		depth = e.depth, -- 4110
		label = label .. " ×1" -- 4110
	} -- 4110
	self:log("掉落 " .. label) -- 4112
end -- 4100
function Play.prototype.damageProp(self, b, amount) -- 4116
	if b.breakable == nil or b.broken == true then -- 4116
		return -- 4118
	end -- 4118
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4118
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4120
	if b.breakable.hp > 0 then -- 4120
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4122
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4123
		return -- 4124
	end -- 4124
	b.broken = true -- 4126
	for ____, other in ipairs(self.boxes) do -- 4127
		if other.id ~= nil and other.id == b.id then -- 4127
			other.broken = true -- 4129
		end -- 4129
	end -- 4129
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4132
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4133
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4134
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4135
end -- 4116
function Play.prototype.slideDepth(self, a, distance) -- 4139
	a.depth = self:limitDepth(a, a.depth + distance) -- 4140
end -- 4139
function Play.prototype.limitDepth(self, a, target) -- 4143
	local road = self.room.depth -- 4144
	if road == nil or target == a.depth then -- 4144
		return a.depth -- 4146
	end -- 4146
	local next = math.max( -- 4148
		road.min, -- 4148
		math.min(road.max, target) -- 4148
	) -- 4148
	local half = a.w / 2 -- 4149
	for ____, b in ipairs(self.boxes) do -- 4150
		do -- 4150
			local footprint = b.depth -- 4151
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4151
				goto __continue706 -- 4156
			end -- 4156
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4158
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4159
			if a.depth <= front and next > front then -- 4159
				next = front -- 4161
			elseif a.depth >= back and next < back then -- 4161
				next = back -- 4163
			end -- 4163
		end -- 4163
		::__continue706:: -- 4163
	end -- 4163
	return next -- 4166
end -- 4143
function Play.prototype.slideX(self, a, dx) -- 4170
	local nx = a.x + dx -- 4171
	local half = a.w / 2 -- 4172
	local room = self.room -- 4173
	nx = math.max( -- 4174
		room.minX + half, -- 4174
		math.min(room.maxX - half, nx) -- 4174
	) -- 4174
	local i = 0 -- 4175
	do -- 4175
		i = 0 -- 4176
		while i < #self.boxes do -- 4176
			do -- 4176
				local b = self.boxes[i + 1] -- 4177
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4177
					goto __continue713 -- 4179
				end -- 4179
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4179
					goto __continue713 -- 4182
				end -- 4182
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4182
					goto __continue713 -- 4185
				end -- 4185
				if nx + half > b.x0 and nx - half < b.x1 then -- 4185
					if a.x <= b.x0 then -- 4185
						nx = b.x0 - half -- 4189
					elseif a.x >= b.x1 then -- 4189
						nx = b.x1 + half -- 4191
					else -- 4191
						nx = a.x -- 4193
					end -- 4193
				end -- 4193
			end -- 4193
			::__continue713:: -- 4193
			i = i + 1 -- 4176
		end -- 4176
	end -- 4176
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4176
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4201
		local bx0 = self.cartAxle - CART_HALF -- 4202
		local bx1 = self.cartAxle + CART_HALF -- 4203
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4203
			if a.x <= bx0 then -- 4203
				nx = bx0 - half -- 4206
			elseif a.x >= bx1 then -- 4206
				nx = bx1 + half -- 4208
			else -- 4208
				nx = a.x -- 4210
			end -- 4210
		end -- 4210
	end -- 4210
	local arch = room.arch -- 4218
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4218
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4220
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4220
			if a.x <= arch.x0 then -- 4220
				nx = arch.x0 - half -- 4223
			elseif a.x >= arch.x1 then -- 4223
				nx = arch.x1 + half -- 4225
			end -- 4225
		end -- 4225
	end -- 4225
	a.x = nx -- 4229
end -- 4170
function Play.prototype.fallY(self, a, dt) -- 4233
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4234
	if a.vy < -900 then -- 4234
		a.vy = -900 -- 4236
	end -- 4236
	local ny = a.y + a.vy * dt -- 4238
	local half = a.w / 2 -- 4239
	if a.vy <= 0 then -- 4239
		local reach = a.onGround and STEP_UP or 0 -- 4242
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4243
		if ny <= ground then -- 4243
			ny = ground -- 4245
			a.vy = 0 -- 4246
			a.onGround = true -- 4247
		else -- 4247
			a.onGround = false -- 4249
		end -- 4249
	else -- 4249
		a.onGround = false -- 4252
		local i = 0 -- 4253
		do -- 4253
			i = 0 -- 4254
			while i < #self.boxes do -- 4254
				do -- 4254
					local b = self.boxes[i + 1] -- 4255
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4255
						goto __continue737 -- 4257
					end -- 4257
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4257
						goto __continue737 -- 4260
					end -- 4260
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4260
						goto __continue737 -- 4263
					end -- 4263
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4263
						ny = b.y0 - a.h -- 4266
						a.vy = 0 -- 4267
					end -- 4267
				end -- 4267
				::__continue737:: -- 4267
				i = i + 1 -- 4254
			end -- 4254
		end -- 4254
	end -- 4254
	a.y = ny -- 4271
end -- 4233
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4275
	if depth == nil then -- 4275
		depth = 0 -- 4275
	end -- 4275
	local g = -9999 -- 4276
	local i = 0 -- 4277
	do -- 4277
		i = 0 -- 4278
		while i < #self.floors do -- 4278
			local f = self.floors[i + 1] -- 4279
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4279
				g = f.y1 -- 4281
			end -- 4281
			i = i + 1 -- 4278
		end -- 4278
	end -- 4278
	do -- 4278
		i = 0 -- 4284
		while i < #self.boxes do -- 4284
			do -- 4284
				local b = self.boxes[i + 1] -- 4285
				if b.broken == true or b.hidden == true or b.soft == true then -- 4285
					goto __continue747 -- 4287
				end -- 4287
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4287
					g = b.y1 -- 4291
				end -- 4291
			end -- 4291
			::__continue747:: -- 4291
			i = i + 1 -- 4284
		end -- 4284
	end -- 4284
	return g -- 4294
end -- 4275
function Play.prototype.updateCamera(self, dt) -- 4297
	local p = self.player -- 4298
	local tx = p.x + p.facing * 30 -- 4299
	local ty = p.y + CAM_LOOK_UP -- 4300
	local k = math.min(1, CAM_FOLLOW * dt) -- 4301
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4302
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4303
end -- 4297
function Play.prototype.clampCamera(self, w, h) -- 4307
	local room = self.room -- 4308
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4309
	local spanX = room.maxX - room.minX -- 4310
	if spanX <= halfW * 2 then -- 4310
		self.cam.x = (room.minX + room.maxX) / 2 -- 4312
	else -- 4312
		self.cam.x = math.max( -- 4314
			room.minX + halfW, -- 4314
			math.min(room.maxX - halfW, self.cam.x) -- 4314
		) -- 4314
	end -- 4314
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4317
	local spanY = room.height -- 4318
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4319
	if spanY <= halfH * 2 then -- 4319
		self.cam.y = camY -- 4321
	else -- 4321
		self.cam.y = math.max( -- 4323
			camY, -- 4323
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4323
		) -- 4323
	end -- 4323
end -- 4307
function Play.prototype.flashSet(self, text, t) -- 4327
	self.flash = text -- 4328
	self.flashT = t -- 4329
end -- 4327
function Play.prototype.statusText(self) -- 4333
	local p = self.player -- 4334
	local parts = {} -- 4335
	local who = self.childMode and "小满" or "周戍" -- 4336
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4337
	if self.room.key == "prologue" then -- 4337
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4340
		if self.phase == "prologue-wait" then -- 4340
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4342
		elseif self.phase == "prologue-give" then -- 4342
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4344
		else -- 4344
			parts[#parts + 1] = "跟随" -- 4346
		end -- 4346
		if self.paused then -- 4346
			parts[#parts + 1] = "已暂停" -- 4349
		end -- 4349
		return table.concat(parts, " · ") -- 4351
	end -- 4351
	if self.room.key == "street" then -- 4351
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4354
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4355
		if self.paused then -- 4355
			parts[#parts + 1] = "已暂停" -- 4357
		end -- 4357
		return table.concat(parts, " · ") -- 4359
	end -- 4359
	if self.room.key == "gate" then -- 4359
		local ____temp_60 -- 4362
		if self.room.story == nil then -- 4362
			____temp_60 = nil -- 4362
		else -- 4362
			____temp_60 = self.room.story.gate -- 4362
		end -- 4362
		local g = ____temp_60 -- 4362
		if g ~= nil then -- 4362
			parts[#parts + 1] = self:gateLabel() -- 4364
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4365
				0, -- 4366
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4366
			))) .. " 秒" -- 4366
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4367
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4368
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4369
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4370
			if self.gateFailCount > 0 then -- 4370
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4372
			end -- 4372
			if self.flash ~= "" then -- 4372
				parts[#parts + 1] = self.flash -- 4375
			end -- 4375
		end -- 4375
		if self.paused then -- 4375
			parts[#parts + 1] = "已暂停" -- 4379
		end -- 4379
		return table.concat(parts, " · ") -- 4381
	end -- 4381
	if self.room.key == "forest" then -- 4381
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4384
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4385
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4386
		if self.caughtT > 0 then -- 4386
			parts[#parts + 1] = "复位中" -- 4388
		end -- 4388
		if self.paused then -- 4388
			parts[#parts + 1] = "已暂停" -- 4391
		end -- 4391
		return table.concat(parts, " · ") -- 4393
	end -- 4393
	if self.room.key == "tower" then -- 4393
		if self.phase == "tower-wait" then -- 4393
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4397
		elseif self.phase == "tower-knock" then -- 4397
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4399
		elseif self.phase == "tower-given" then -- 4399
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4401
		else -- 4401
			parts[#parts + 1] = "片尾" -- 4403
		end -- 4403
		if self.paused then -- 4403
			parts[#parts + 1] = "已暂停" -- 4406
		end -- 4406
		return table.concat(parts, " · ") -- 4408
	end -- 4408
	if self.room.key == "village" then -- 4408
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4411
		if self.hasBottle then -- 4411
			parts[#parts + 1] = "有瓶" -- 4413
		elseif self.bottleFly ~= nil then -- 4413
			parts[#parts + 1] = "瓶在飞" -- 4415
		else -- 4415
			parts[#parts + 1] = "空手" -- 4417
		end -- 4417
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4419
		if self.scavChase then -- 4419
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4421
		end -- 4421
		if self.passed then -- 4421
			parts[#parts + 1] = "已过通行线" -- 4424
		end -- 4424
		if self.paused then -- 4424
			parts[#parts + 1] = "已暂停" -- 4427
		end -- 4427
		return table.concat(parts, " · ") -- 4429
	end -- 4429
	local isChild = self.childMode -- 4432
	if isChild then -- 4432
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4434
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4435
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4436
	else -- 4436
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4438
		if p.rollT > 0 then -- 4438
			parts[#parts + 1] = "翻滚中" -- 4440
		end -- 4440
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4442
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4443
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4444
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4445
	end -- 4445
	if self.checkpoint >= 0 then -- 4445
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4448
	end -- 4448
	if self.paused then -- 4448
		parts[#parts + 1] = "已暂停" -- 4451
	end -- 4451
	return table.concat(parts, " · ") -- 4453
end -- 4333
function Play.prototype.aliveEnemies(self) -- 4457
	local n = 0 -- 4458
	local i = 0 -- 4459
	do -- 4459
		i = 0 -- 4460
		while i < #self.enemies do -- 4460
			if self.enemies[i + 1].alive then -- 4460
				n = n + 1 -- 4462
			end -- 4462
			i = i + 1 -- 4460
		end -- 4460
	end -- 4460
	return n -- 4465
end -- 4457
function Play.prototype.threatened(self) -- 4470
	do -- 4470
		local i = 0 -- 4471
		while i < #self.enemies do -- 4471
			local e = self.enemies[i + 1] -- 4472
			if e.alive and e.warnT > 0 then -- 4472
				return true -- 4474
			end -- 4474
			i = i + 1 -- 4471
		end -- 4471
	end -- 4471
	return false -- 4477
end -- 4470
function Play.prototype.gateSecondsLeft(self) -- 4480
	local ____temp_61 -- 4481
	if self.room.story == nil then -- 4481
		____temp_61 = nil -- 4481
	else -- 4481
		____temp_61 = self.room.story.gate -- 4481
	end -- 4481
	local g = ____temp_61 -- 4481
	if g == nil then -- 4481
		return 0 -- 4483
	end -- 4483
	return math.max( -- 4485
		0, -- 4485
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4485
	) -- 4485
end -- 4480
function Play.prototype.gateLabel(self) -- 4488
	if self.phase == "gate-idle" then -- 4488
		return "待就位" -- 4490
	end -- 4490
	if self.phase == "gate-hold" then -- 4490
		return "守点中" -- 4493
	end -- 4493
	if self.phase == "gate-send" then -- 4493
		return "送别" -- 4496
	end -- 4496
	if self.phase == "gate-count" then -- 4496
		return "数数 " .. tostring(self.countTick) -- 4499
	end -- 4499
	return "她走" -- 4501
end -- 4488
function Play.prototype.dogLabel(self) -- 4505
	if self.dogState == "ear" then -- 4505
		return "转耳" -- 4507
	end -- 4507
	if self.dogState == "chase" then -- 4507
		return "追" -- 4510
	end -- 4510
	if self.dogState == "sniff" then -- 4510
		return "停" -- 4513
	end -- 4513
	if self.dogState == "back" then -- 4513
		return "回线" -- 4516
	end -- 4516
	return "巡逻" -- 4518
end -- 4505
function Play.prototype.doorXOf(self) -- 4521
	local ____temp_62 -- 4522
	if self.room.story == nil then -- 4522
		____temp_62 = nil -- 4522
	else -- 4522
		____temp_62 = self.room.story.tower -- 4522
	end -- 4522
	local t = ____temp_62 -- 4522
	return t == nil and 0 or t.doorX -- 4523
end -- 4521
function Play.prototype.scavLabel(self) -- 4527
	if self.scavState == "chase" then -- 4527
		return "追" -- 4529
	end -- 4529
	if self.scavState == "turn" then -- 4529
		return "转头" -- 4532
	end -- 4532
	if self.scavState == "walk" then -- 4532
		return "赶来" -- 4535
	end -- 4535
	if self.scavState == "stall" then -- 4535
		return "停住" -- 4538
	end -- 4538
	if self.scavState == "back" then -- 4538
		return "回位" -- 4541
	end -- 4541
	return "巡逻" -- 4543
end -- 4527
function Play.prototype.hintText(self) -- 4547
	if self.paused then -- 4547
		return "Esc 继续 · R 重置" -- 4549
	end -- 4549
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4549
		if self:threatened() then -- 4549
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4555
		end -- 4555
		if self.coverHug then -- 4555
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4558
		end -- 4558
		if self.coverNear then -- 4558
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4561
		end -- 4561
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4563
	end -- 4563
	if self.flash ~= "" then -- 4563
		return self.flash -- 4566
	end -- 4566
	if self.room.key == "prologue" then -- 4566
		if self.phase == "prologue-wait" then -- 4566
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4570
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4571
		end -- 4571
		if self.phase == "prologue-give" then -- 4571
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4574
		end -- 4574
		return "她跟着你了 · 两人一起走到门口 680" -- 4576
	end -- 4576
	if self.room.key == "street" then -- 4576
		if self:aliveEnemies() > 0 then -- 4576
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4580
		end -- 4580
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4582
	end -- 4582
	if self.room.key == "gate" then -- 4582
		local ____temp_63 -- 4585
		if self.room.story == nil then -- 4585
			____temp_63 = nil -- 4585
		else -- 4585
			____temp_63 = self.room.story.gate -- 4585
		end -- 4585
		local g = ____temp_63 -- 4585
		if g ~= nil then -- 4585
			if self.phase == "gate-idle" then -- 4585
				if self.gateNeedConfirm then -- 4585
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4589
				end -- 4589
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4591
			end -- 4591
			if self.phase == "gate-hold" then -- 4591
				if self.coveredFlash > 0 then -- 4591
					return "掩体挡下了这一枪 · 别露头" -- 4595
				end -- 4595
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4597
			end -- 4597
			if self.phase == "gate-send" then -- 4597
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4600
			end -- 4600
			if self.phase == "gate-count" then -- 4600
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4600
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4604
				end -- 4604
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4606
			end -- 4606
			return "她自己走 · 跟着出城门 1120" -- 4608
		end -- 4608
	end -- 4608
	if self.room.key == "forest" then -- 4608
		if self.dogState == "chase" then -- 4608
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4613
		end -- 4613
		if self.dogState == "ear" then -- 4613
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4616
		end -- 4616
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4618
	end -- 4618
	if self.room.key == "tower" then -- 4618
		if self.phase == "tower-wait" then -- 4618
			return "走到门前 445 点一次 E 敲两下" -- 4622
		end -- 4622
		if self.phase == "tower-knock" then -- 4622
			return "敲两下 · 等门开" -- 4625
		end -- 4625
		if self.phase == "tower-given" then -- 4625
			return "递交针套和纸条 · 看登记簿最后一行" -- 4628
		end -- 4628
		return "片尾 · 点 E 再玩一次，回到序章" -- 4630
	end -- 4630
	if self.room.key == "village" then -- 4630
		if self.bottleFly ~= nil then -- 4630
			return "等瓶子落地 · 触地才发声" -- 4634
		end -- 4634
		if self.hasBottle then -- 4634
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4637
		end -- 4637
		if self.passed then -- 4637
			return "已过第一院 · R 重置可再来一遍" -- 4640
		end -- 4640
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4642
	end -- 4642
	if self.room.key == "outside" then -- 4642
		if self.focusCart then -- 4642
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4646
		end -- 4646
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4648
	end -- 4648
	if self.escort.state == "frozen" then -- 4648
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4648
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4652
		end -- 4652
		return "小满吓住了 · 走过去，靠近再点 E" -- 4654
	end -- 4654
	if self.escort.state == "calming" then -- 4654
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4657
	end -- 4657
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4659
end -- 4547
function Play.prototype.draw(self, draw, w, h) -- 4664
	self.viewW = w -- 4665
	self.viewH = h -- 4666
	self.view = ____exports.computeViewport(w, h) -- 4667
	self:clampCamera(w, h) -- 4668
	draw:clear() -- 4669
	draw:drawRect( -- 4671
		Rect(0, 0, w, h), -- 4671
		BG_VOID -- 4671
	) -- 4671
	local box = self:canvasRect(w, h) -- 4672
	draw:drawRect(box, BG_FAR) -- 4673
	draw:drawRect( -- 4674
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4674
		BG_MID -- 4674
	) -- 4674
	self:drawFloors(draw, w, h) -- 4676
	self:drawSolids(draw, w, h) -- 4677
	self:drawZones(draw, w, h) -- 4678
	self:drawArch(draw, w, h) -- 4679
	self:drawCart(draw, w, h) -- 4680
	self:drawCampaignProps(draw, w, h) -- 4681
	self:drawActors(draw, w, h) -- 4682
	self:drawTrace(draw, w, h) -- 4683
	self:drawAim(draw, w, h) -- 4684
end -- 4664
function Play.prototype.canvasRect(self, w, h) -- 4688
	local v = self.view -- 4689
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 4690
end -- 4688
function Play.prototype.px(self, n) -- 4694
	return n * self.view.zoom -- 4695
end -- 4694
function Play.prototype.sx(self, wx, w) -- 4699
	local v = self.view -- 4700
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 4701
	return v.ox + lx * v.zoom -- 4702
end -- 4699
function Play.prototype.sy(self, wy, h) -- 4706
	local v = self.view -- 4707
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 4708
	return v.oy + ly * v.zoom -- 4709
end -- 4706
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 4712
	local px0 = self:sx(x0, w) -- 4713
	local px1 = self:sx(x1, w) -- 4714
	local py0 = self:sy(y0, h) -- 4715
	local py1 = self:sy(y1, h) -- 4716
	if px1 <= px0 or py1 <= py0 then -- 4716
		return -- 4718
	end -- 4718
	draw:drawRect( -- 4720
		Rect(px0, py0, px1 - px0, py1 - py0), -- 4720
		color -- 4720
	) -- 4720
end -- 4712
function Play.prototype.drawFloors(self, draw, w, h) -- 4723
	local i = 0 -- 4724
	do -- 4724
		i = 0 -- 4725
		while i < #self.room.floors do -- 4725
			local f = self.room.floors[i + 1] -- 4726
			local ____temp_64 -- 4727
			if f.y == 0 then -- 4727
				____temp_64 = self.room.depth -- 4727
			else -- 4727
				____temp_64 = nil -- 4727
			end -- 4727
			local road = ____temp_64 -- 4727
			local y = self:sy(f.y + (road and road.min or 0), h) -- 4728
			local x0 = self:sx(f.x0, w) -- 4729
			local x1 = self:sx(f.x1, w) -- 4730
			local deck = self:px(5) -- 4731
			if road ~= nil then -- 4731
				local back = self:sy(f.y + road.max, h) -- 4733
				draw:drawRect( -- 4734
					Rect(x0, y, x1 - x0, back - y), -- 4734
					FLOOR_DECK, -- 4734
					self:px(1), -- 4734
					SOLID_EDGE -- 4734
				) -- 4734
			end -- 4734
			draw:drawRect( -- 4736
				Rect(x0, y - deck, x1 - x0, deck), -- 4736
				FLOOR_DECK -- 4736
			) -- 4736
			draw:drawSegment( -- 4737
				Vec2(x0, y), -- 4737
				Vec2(x1, y), -- 4737
				self:px(1), -- 4737
				GROUND -- 4737
			) -- 4737
			i = i + 1 -- 4725
		end -- 4725
	end -- 4725
end -- 4723
function Play.prototype.drawSolids(self, draw, w, h) -- 4741
	local i = 0 -- 4742
	do -- 4742
		i = 0 -- 4743
		while i < #self.boxes do -- 4743
			do -- 4743
				local b = self.boxes[i + 1] -- 4744
				if b.id == "braced_shield" or b.hidden == true then -- 4744
					goto __continue868 -- 4746
				end -- 4746
				if b.broken == true then -- 4746
					if b.breakable ~= nil then -- 4746
						local gy = self:sy(b.y0, h) -- 4751
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 4752
						local k = 0 -- 4753
						do -- 4753
							k = 0 -- 4754
							while k < 3 do -- 4754
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 4755
								draw:drawSegment( -- 4756
									Vec2( -- 4756
										gx - self:px(4), -- 4756
										gy + self:px(k % 2) -- 4756
									), -- 4756
									Vec2( -- 4756
										gx + self:px(5), -- 4756
										gy + self:px(k % 2) -- 4756
									), -- 4756
									self:px(1), -- 4756
									rgb -- 4756
								) -- 4756
								k = k + 1 -- 4754
							end -- 4754
						end -- 4754
					end -- 4754
					goto __continue868 -- 4759
				end -- 4759
				local ____opt_67 = b.depth -- 4759
				local front = ____opt_67 and ____opt_67.min or 0 -- 4761
				local ____opt_69 = b.depth -- 4761
				local back = ____opt_69 and ____opt_69.max or 0 -- 4762
				local fill = SOLID_FILL -- 4763
				local line = SOLID_EDGE -- 4764
				if b.soft == true then -- 4764
					fill = SOFT -- 4766
					line = SOFT_LINE -- 4767
				elseif b.breakable ~= nil then -- 4767
					line = DANGER_LINE -- 4769
					fill = Color(0.3, 0.24, 0.16, 1) -- 4770
				elseif b.interact ~= nil then -- 4770
					line = PASS_LINE -- 4772
				end -- 4772
				self:drawBox( -- 4774
					draw, -- 4774
					w, -- 4774
					h, -- 4774
					b.x0, -- 4774
					b.x1, -- 4774
					b.y0 + front, -- 4774
					b.y1 + back, -- 4774
					fill -- 4774
				) -- 4774
				draw:drawSegment( -- 4775
					Vec2( -- 4775
						self:sx(b.x0, w), -- 4775
						self:sy(b.y1 + front, h) -- 4775
					), -- 4775
					Vec2( -- 4776
						self:sx(b.x1, w), -- 4776
						self:sy(b.y1 + front, h) -- 4776
					), -- 4776
					self:px(1), -- 4776
					line -- 4776
				) -- 4776
				if b.breakable ~= nil then -- 4776
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 4779
					local cyp = self:sy(b.y1 + front, h) -- 4780
					draw:drawSegment( -- 4781
						Vec2( -- 4781
							cxp - self:px(4), -- 4781
							cyp + self:px(1) -- 4781
						), -- 4781
						Vec2( -- 4781
							cxp + self:px(3), -- 4781
							cyp + self:px(5) -- 4781
						), -- 4781
						self:px(1), -- 4781
						line -- 4781
					) -- 4781
				end -- 4781
			end -- 4781
			::__continue868:: -- 4781
			i = i + 1 -- 4743
		end -- 4743
	end -- 4743
end -- 4741
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 4787
	local i = 0 -- 4788
	do -- 4788
		i = 0 -- 4789
		while i < #self.pickups do -- 4789
			do -- 4789
				local pk = self.pickups[i + 1] -- 4790
				if pk.id == "" then -- 4790
					goto __continue880 -- 4792
				end -- 4792
				local gy = pk.y + (pk.depth or 0) -- 4794
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 4795
				draw:drawRect( -- 4796
					Rect( -- 4796
						self:sx(pk.x - 5, w), -- 4796
						self:sy(gy + 12 + bob, h), -- 4796
						self:px(10), -- 4796
						self:px(10) -- 4796
					), -- 4796
					Color(0.84, 0.7, 0.3, 1) -- 4797
				) -- 4797
				draw:drawSegment( -- 4798
					Vec2( -- 4798
						self:sx(pk.x - 5, w), -- 4798
						self:sy(gy + 12 + bob, h) -- 4798
					), -- 4798
					Vec2( -- 4799
						self:sx(pk.x + 5, w), -- 4799
						self:sy(gy + 12 + bob, h) -- 4799
					), -- 4799
					self:px(1), -- 4799
					Color(0.95, 0.86, 0.52, 1) -- 4799
				) -- 4799
			end -- 4799
			::__continue880:: -- 4799
			i = i + 1 -- 4789
		end -- 4789
	end -- 4789
	if self.bracedShield ~= nil then -- 4789
		local sh = self.bracedShield -- 4802
		draw:drawRect( -- 4803
			Rect( -- 4803
				self:sx(sh.x - sh.w / 2, w), -- 4803
				self:sy(sh.y, h), -- 4803
				self:px(sh.w), -- 4803
				self:px(sh.h) -- 4803
			), -- 4803
			Color(0.42, 0.4, 0.34, 1) -- 4804
		) -- 4804
		draw:drawSegment( -- 4805
			Vec2( -- 4805
				self:sx(sh.x - sh.w / 2, w), -- 4805
				self:sy(sh.y + sh.h, h) -- 4805
			), -- 4805
			Vec2( -- 4806
				self:sx(sh.x + sh.w / 2, w), -- 4806
				self:sy(sh.y + sh.h, h) -- 4806
			), -- 4806
			self:px(1), -- 4806
			Color(0.74, 0.72, 0.62, 1) -- 4806
		) -- 4806
	end -- 4806
end -- 4787
function Play.prototype.drawZones(self, draw, w, h) -- 4810
	local i = 0 -- 4811
	do -- 4811
		i = 0 -- 4812
		while i < #self.room.zones do -- 4812
			local z = self.room.zones[i + 1] -- 4813
			local fill = DANGER -- 4814
			local line = DANGER_LINE -- 4815
			if z.tint == 2 then -- 4815
				fill = SOFT -- 4817
				line = SOFT_LINE -- 4818
			elseif z.tint == 3 then -- 4818
				fill = BRICK -- 4820
				line = BRICK_LINE -- 4821
			elseif z.tint == 4 then -- 4821
				fill = PASS -- 4823
				line = PASS_LINE -- 4824
			end -- 4824
			self:drawBox( -- 4826
				draw, -- 4826
				w, -- 4826
				h, -- 4826
				z.x0, -- 4826
				z.x1, -- 4826
				z.y, -- 4826
				z.y + z.h, -- 4826
				fill -- 4826
			) -- 4826
			draw:drawSegment( -- 4827
				Vec2( -- 4827
					self:sx(z.x0, w), -- 4827
					self:sy(z.y, h) -- 4827
				), -- 4827
				Vec2( -- 4827
					self:sx(z.x0, w), -- 4827
					self:sy(z.y + z.h, h) -- 4827
				), -- 4827
				self:px(1), -- 4827
				line -- 4827
			) -- 4827
			draw:drawSegment( -- 4828
				Vec2( -- 4828
					self:sx(z.x1, w), -- 4828
					self:sy(z.y, h) -- 4828
				), -- 4828
				Vec2( -- 4828
					self:sx(z.x1, w), -- 4828
					self:sy(z.y + z.h, h) -- 4828
				), -- 4828
				self:px(1), -- 4828
				line -- 4828
			) -- 4828
			i = i + 1 -- 4812
		end -- 4812
	end -- 4812
end -- 4810
function Play.prototype.drawArch(self, draw, w, h) -- 4832
	local a = self.room.arch -- 4833
	if a.h <= 0 then -- 4833
		return -- 4835
	end -- 4835
	self:drawBox( -- 4837
		draw, -- 4837
		w, -- 4837
		h, -- 4837
		a.x0, -- 4837
		a.x1, -- 4837
		a.y, -- 4837
		a.y + a.h, -- 4837
		HOLE_FILL -- 4837
	) -- 4837
	draw:drawSegment( -- 4838
		Vec2( -- 4838
			self:sx(a.x0, w), -- 4838
			self:sy(a.y + a.h, h) -- 4838
		), -- 4838
		Vec2( -- 4838
			self:sx(a.x1, w), -- 4838
			self:sy(a.y + a.h, h) -- 4838
		), -- 4838
		self:px(1), -- 4838
		SOLID_EDGE -- 4838
	) -- 4838
	draw:drawSegment( -- 4839
		Vec2( -- 4839
			self:sx(a.x0, w), -- 4839
			self:sy(a.y, h) -- 4839
		), -- 4839
		Vec2( -- 4839
			self:sx(a.x0, w), -- 4839
			self:sy(a.y + a.h, h) -- 4839
		), -- 4839
		self:px(1), -- 4839
		SOLID_EDGE -- 4839
	) -- 4839
	draw:drawSegment( -- 4840
		Vec2( -- 4840
			self:sx(a.x1, w), -- 4840
			self:sy(a.y, h) -- 4840
		), -- 4840
		Vec2( -- 4840
			self:sx(a.x1, w), -- 4840
			self:sy(a.y + a.h, h) -- 4840
		), -- 4840
		self:px(1), -- 4840
		SOLID_EDGE -- 4840
	) -- 4840
end -- 4832
function Play.prototype.drawCart(self, draw, w, h) -- 4843
	local c = self.room.cart -- 4844
	if c.bodyW <= 0 then -- 4844
		return -- 4846
	end -- 4846
	drawCartShape( -- 4848
		draw, -- 4848
		self, -- 4848
		w, -- 4848
		h, -- 4848
		c, -- 4848
		self.cartAxle -- 4848
	) -- 4848
	draw:drawRect( -- 4849
		Rect( -- 4849
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 4849
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 4849
			self:px(2), -- 4849
			self:px(40) -- 4849
		), -- 4849
		STAND -- 4849
	) -- 4849
end -- 4843
function Play.prototype.drawActors(self, draw, w, h) -- 4852
	local p = self.player -- 4853
	local isChild = self.childMode -- 4854
	local footY = p.y + p.depth -- 4855
	if p.covered then -- 4855
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 4858
		draw:drawSegment( -- 4859
			Vec2( -- 4859
				self:sx(edge, w), -- 4859
				self:sy(footY + 8, h) -- 4859
			), -- 4859
			Vec2( -- 4859
				self:sx(edge, w), -- 4859
				self:sy(footY + p.h * 0.62, h) -- 4859
			), -- 4859
			self:px(2), -- 4859
			STAND -- 4859
		) -- 4859
		draw:drawSegment( -- 4861
			Vec2( -- 4861
				self:sx(p.x - 8, w), -- 4861
				self:sy(footY + p.h + 3, h) -- 4861
			), -- 4861
			Vec2( -- 4861
				self:sx(p.x + 8, w), -- 4861
				self:sy(footY + p.h + 3, h) -- 4861
			), -- 4861
			self:px(2), -- 4861
			STAND -- 4861
		) -- 4861
	elseif self.coverNear and not isChild then -- 4861
		draw:drawRect( -- 4864
			Rect( -- 4864
				self:sx(p.x - 3, w), -- 4864
				self:sy(footY + 1, h), -- 4864
				self:px(3), -- 4864
				self:px(3) -- 4864
			), -- 4864
			STAND -- 4864
		) -- 4864
	end -- 4864
	drawFigure( -- 4866
		draw, -- 4866
		self, -- 4866
		w, -- 4866
		h, -- 4866
		p, -- 4866
		isChild and CHILD_BODY or SOLDIER_BODY, -- 4866
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 4866
	) -- 4866
	local q = self.partner -- 4867
	if q.alive then -- 4867
		local childPartner = q.w == CHILD_W -- 4869
		drawFigure( -- 4870
			draw, -- 4870
			self, -- 4870
			w, -- 4870
			h, -- 4870
			q, -- 4870
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 4870
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 4870
		) -- 4870
	end -- 4870
	local i = 0 -- 4872
	do -- 4872
		i = 0 -- 4873
		while i < #self.enemies do -- 4873
			local e = self.enemies[i + 1] -- 4874
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 4875
			local enemyY = e.y + (e.depth or 0) -- 4876
			self:drawBox( -- 4877
				draw, -- 4877
				w, -- 4877
				h, -- 4877
				e.x - e.w / 2, -- 4877
				e.x + e.w / 2, -- 4877
				enemyY, -- 4877
				enemyY + e.h, -- 4877
				col -- 4877
			) -- 4877
			if e.alive then -- 4877
				local ef = p.x >= e.x and 1 or -1 -- 4879
				if e.kind == "shield" then -- 4879
					local sh = (e.shieldHp or 0) > 0 -- 4881
					draw:drawRect( -- 4882
						Rect( -- 4882
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 4882
							self:sy(enemyY, h), -- 4882
							self:px(6), -- 4882
							self:px(64) -- 4882
						), -- 4882
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 4883
					) -- 4883
				elseif e.kind == "breaker" then -- 4883
					draw:drawSegment( -- 4885
						Vec2( -- 4885
							self:sx(e.x + ef * 12, w), -- 4885
							self:sy(enemyY + 8, h) -- 4885
						), -- 4885
						Vec2( -- 4886
							self:sx(e.x + ef * 22, w), -- 4886
							self:sy(enemyY + 46, h) -- 4886
						), -- 4886
						self:px(3), -- 4886
						Color(0.5, 0.36, 0.22, 1) -- 4886
					) -- 4886
				end -- 4886
			end -- 4886
			if e.alive and e.warnT > 0 then -- 4886
				local gunX = self:sx(e.x, w) -- 4891
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 4892
				local aimX = self:sx(p.x, w) -- 4893
				local aimY = self:sy(footY + p.h * 0.55, h) -- 4894
				local seg = 8 -- 4895
				local s = 0 -- 4896
				do -- 4896
					s = 0 -- 4897
					while s < seg do -- 4897
						local t0 = s / seg -- 4898
						local t1 = (s + 1) / seg -- 4899
						draw:drawSegment( -- 4900
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 4901
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 4902
							self:px(1), -- 4903
							DANGER -- 4903
						) -- 4903
						s = s + 2 -- 4897
					end -- 4897
				end -- 4897
			end -- 4897
			i = i + 1 -- 4873
		end -- 4873
	end -- 4873
	local k = 0 -- 4908
	do -- 4908
		k = 0 -- 4909
		while k < #self.room.marks do -- 4909
			do -- 4909
				local m = self.room.marks[k + 1] -- 4910
				if m.kind ~= 0 then -- 4910
					goto __continue906 -- 4912
				end -- 4912
				local on = self.checkpoint == m.x -- 4914
				local x = self:sx(m.x, w) -- 4915
				local y = self:sy(m.y, h) -- 4916
				draw:drawSegment( -- 4917
					Vec2(x, y), -- 4917
					Vec2( -- 4917
						x, -- 4917
						y + self:px(35) -- 4917
					), -- 4917
					self:px(1), -- 4917
					on and CHECK or INK_DIM -- 4917
				) -- 4917
				draw:drawDot( -- 4918
					Vec2( -- 4918
						x, -- 4918
						y + self:px(35) -- 4918
					), -- 4918
					self:px(2), -- 4918
					on and CHECK or INK_DIM -- 4918
				) -- 4918
			end -- 4918
			::__continue906:: -- 4918
			k = k + 1 -- 4909
		end -- 4909
	end -- 4909
	local j = 0 -- 4922
	do -- 4922
		j = 0 -- 4923
		while j < #self.room.marks do -- 4923
			do -- 4923
				local m = self.room.marks[j + 1] -- 4924
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 4924
					goto __continue909 -- 4926
				end -- 4926
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 4926
					goto __continue909 -- 4930
				end -- 4930
				local col = STAND -- 4932
				if m.kind == 4 then -- 4932
					col = PASS_LINE -- 4934
				elseif m.kind == 5 then -- 4934
					col = BRICK_LINE -- 4936
				end -- 4936
				local mx = self:sx(m.x, w) -- 4938
				local my = self:sy(m.y, h) -- 4939
				draw:drawSegment( -- 4940
					Vec2(mx, my), -- 4940
					Vec2( -- 4940
						mx, -- 4940
						my + self:px(24) -- 4940
					), -- 4940
					self:px(1), -- 4940
					col -- 4940
				) -- 4940
			end -- 4940
			::__continue909:: -- 4940
			j = j + 1 -- 4923
		end -- 4923
	end -- 4923
	local t = 0 -- 4943
	do -- 4943
		t = 0 -- 4944
		while t < #self.room.marks do -- 4944
			do -- 4944
				local m = self.room.marks[t + 1] -- 4945
				if m.kind ~= 6 then -- 4945
					goto __continue915 -- 4947
				end -- 4947
				local mx = self:sx(m.x, w) -- 4949
				local my = self:sy(m.y, h) -- 4950
				draw:drawSegment( -- 4951
					Vec2(mx, my), -- 4951
					Vec2( -- 4951
						mx, -- 4951
						my + self:px(30) -- 4951
					), -- 4951
					self:px(1), -- 4951
					INK_DIM -- 4951
				) -- 4951
				self:drawBox( -- 4952
					draw, -- 4952
					w, -- 4952
					h, -- 4952
					m.x - 5, -- 4952
					m.x + 5, -- 4952
					m.y + 30, -- 4952
					m.y + 40, -- 4952
					CHECK -- 4952
				) -- 4952
			end -- 4952
			::__continue915:: -- 4952
			t = t + 1 -- 4944
		end -- 4944
	end -- 4944
	if self.room.key == "village" then -- 4944
		self:drawVillage(draw, w, h) -- 4955
	end -- 4955
	if self.room.key == "forest" then -- 4955
		self:drawDog(draw, w, h) -- 4958
	end -- 4958
end -- 4852
function Play.prototype.drawDog(self, draw, w, h) -- 4963
	local x = self.dogX -- 4964
	self:drawBox( -- 4965
		draw, -- 4965
		w, -- 4965
		h, -- 4965
		x - 14, -- 4965
		x + 14, -- 4965
		0, -- 4965
		20, -- 4965
		SCAV_BODY -- 4965
	) -- 4965
	self:drawBox( -- 4966
		draw, -- 4966
		w, -- 4966
		h, -- 4966
		x - 10, -- 4966
		x - 2, -- 4966
		20, -- 4966
		30, -- 4966
		SCAV_BODY -- 4966
	) -- 4966
	self:drawBox( -- 4967
		draw, -- 4967
		w, -- 4967
		h, -- 4967
		x + 2, -- 4967
		x + 10, -- 4967
		20, -- 4967
		30, -- 4967
		SCAV_HEAD -- 4967
	) -- 4967
	if self.dogState == "ear" or self.dogState == "chase" then -- 4967
		draw:drawSegment( -- 4969
			Vec2( -- 4969
				self:sx(x, w), -- 4969
				self:sy(30, h) -- 4969
			), -- 4969
			Vec2( -- 4970
				self:sx(x, w), -- 4970
				self:sy(40, h) -- 4970
			), -- 4970
			self:px(1), -- 4970
			DANGER -- 4970
		) -- 4970
	end -- 4970
end -- 4963
function Play.prototype.drawVillage(self, draw, w, h) -- 4975
	local bottle = self.room.bottle -- 4976
	if bottle ~= nil then -- 4976
		self:drawBox( -- 4978
			draw, -- 4978
			w, -- 4978
			h, -- 4978
			bottle.x - 14, -- 4978
			bottle.x + 14, -- 4978
			0, -- 4978
			64, -- 4978
			SOLID_FILL -- 4978
		) -- 4978
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 4978
			self:drawBottle( -- 4980
				draw, -- 4980
				w, -- 4980
				h, -- 4980
				bottle.x, -- 4980
				64 -- 4980
			) -- 4980
		end -- 4980
	end -- 4980
	self:drawBox( -- 4984
		draw, -- 4984
		w, -- 4984
		h, -- 4984
		300, -- 4984
		420, -- 4984
		44, -- 4984
		50, -- 4984
		FLOOR_DECK -- 4984
	) -- 4984
	self:drawBox( -- 4985
		draw, -- 4985
		w, -- 4985
		h, -- 4985
		300, -- 4985
		306, -- 4985
		0, -- 4985
		44, -- 4985
		FLOOR_DECK -- 4985
	) -- 4985
	self:drawBox( -- 4986
		draw, -- 4986
		w, -- 4986
		h, -- 4986
		414, -- 4986
		420, -- 4986
		0, -- 4986
		44, -- 4986
		FLOOR_DECK -- 4986
	) -- 4986
	local s = self.room.scavenger -- 4988
	if s ~= nil then -- 4988
		local sx0 = self.scavX -- 4990
		self:drawBox( -- 4991
			draw, -- 4991
			w, -- 4991
			h, -- 4991
			sx0 - 12, -- 4991
			sx0 + 12, -- 4991
			0, -- 4991
			s.h - 14, -- 4991
			SCAV_BODY -- 4991
		) -- 4991
		self:drawBox( -- 4992
			draw, -- 4992
			w, -- 4992
			h, -- 4992
			sx0 - 7, -- 4992
			sx0 + 7, -- 4992
			s.h - 14, -- 4992
			s.h, -- 4992
			SCAV_HEAD -- 4992
		) -- 4992
		if self.scavState == "turn" then -- 4992
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 4994
			draw:drawSegment( -- 4995
				Vec2( -- 4995
					self:sx(sx0, w), -- 4995
					self:sy(s.h - 6, h) -- 4995
				), -- 4995
				Vec2( -- 4995
					self:sx(fx, w), -- 4995
					self:sy(s.h - 6, h) -- 4995
				), -- 4995
				self:px(1), -- 4995
				INK -- 4995
			) -- 4995
		end -- 4995
	end -- 4995
	if self.hasBottle then -- 4995
		local p = self.player -- 5000
		self:drawBottle( -- 5001
			draw, -- 5001
			w, -- 5001
			h, -- 5001
			p.x + p.facing * 10, -- 5001
			p.y + p.h * 0.62 -- 5001
		) -- 5001
	end -- 5001
	if self.bottleFly ~= nil then -- 5001
		self:drawBottle( -- 5004
			draw, -- 5004
			w, -- 5004
			h, -- 5004
			self.bottleFly.x, -- 5004
			self.bottleFly.y -- 5004
		) -- 5004
	end -- 5004
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5004
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5007
		draw:drawCircle( -- 5008
			Vec2( -- 5008
				self:sx(self.bottleLandX, w), -- 5008
				self:sy(0, h) -- 5008
			), -- 5008
			self:px(r / ____exports.UNITS_PER_PX), -- 5008
			BRICK_LINE -- 5008
		) -- 5008
	end -- 5008
end -- 4975
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5012
	self:drawBox( -- 5013
		draw, -- 5013
		w, -- 5013
		h, -- 5013
		x - 3, -- 5013
		x + 3, -- 5013
		y - 10, -- 5013
		y, -- 5013
		BOTTLE -- 5013
	) -- 5013
end -- 5012
function Play.prototype.drawTrace(self, draw, w, h) -- 5016
	local t = self.trace -- 5017
	if t == nil or self.traceT <= 0 then -- 5017
		return -- 5019
	end -- 5019
	draw:drawSegment( -- 5021
		Vec2( -- 5022
			self:sx(t.x0, w), -- 5022
			self:sy(t.y0, h) -- 5022
		), -- 5022
		Vec2( -- 5023
			self:sx(t.x1, w), -- 5023
			self:sy(t.y1, h) -- 5023
		), -- 5023
		self:px(1), -- 5024
		t.hit and AIM_HIT or INK_DIM -- 5024
	) -- 5024
end -- 5016
function Play.prototype.drawAim(self, draw, w, h) -- 5027
	local v = self.view -- 5029
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5030
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5031
	local dot = self:px(1) -- 5032
	local arm = self:px(3) -- 5033
	local gap = self:px(1) -- 5034
	draw:drawSegment( -- 5035
		Vec2(gx - arm - gap, gy), -- 5035
		Vec2(gx - gap, gy), -- 5035
		dot / 2, -- 5035
		AIM -- 5035
	) -- 5035
	draw:drawSegment( -- 5036
		Vec2(gx + gap, gy), -- 5036
		Vec2(gx + arm + gap, gy), -- 5036
		dot / 2, -- 5036
		AIM -- 5036
	) -- 5036
	draw:drawSegment( -- 5037
		Vec2(gx, gy - arm - gap), -- 5037
		Vec2(gx, gy - gap), -- 5037
		dot / 2, -- 5037
		AIM -- 5037
	) -- 5037
	draw:drawSegment( -- 5038
		Vec2(gx, gy + gap), -- 5038
		Vec2(gx, gy + arm + gap), -- 5038
		dot / 2, -- 5038
		AIM -- 5038
	) -- 5038
	if self.room.key == "village" and self.hasBottle then -- 5038
		local p = self.player -- 5042
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5044
		local dir = ____end.x >= p.x and 1 or -1 -- 5045
		local x0 = p.x + dir * 10 -- 5046
		local y0 = p.y + p.h * 0.7 -- 5047
		local T = BOTTLE_FLY_TIME -- 5048
		local vx = (____end.x - x0) / T -- 5049
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5050
		local pxr = x0 -- 5051
		local pyr = y0 -- 5052
		local t = 1 -- 5053
		do -- 5053
			t = 1 -- 5054
			while t <= 12 do -- 5054
				local tt = t / 12 * T -- 5055
				local nx = x0 + vx * tt -- 5056
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5057
				draw:drawSegment( -- 5058
					Vec2( -- 5058
						self:sx(pxr, w), -- 5058
						self:sy(pyr, h) -- 5058
					), -- 5058
					Vec2( -- 5058
						self:sx(nx, w), -- 5058
						self:sy(ny, h) -- 5058
					), -- 5058
					self:px(1) / 2, -- 5058
					BOTTLE -- 5058
				) -- 5058
				pxr = nx -- 5059
				pyr = ny -- 5060
				t = t + 1 -- 5054
			end -- 5054
		end -- 5054
		draw:drawCircle( -- 5062
			Vec2( -- 5062
				self:sx(____end.x, w), -- 5062
				self:sy(____end.y + 2, h) -- 5062
			), -- 5062
			self:px(2), -- 5062
			BOTTLE -- 5062
		) -- 5062
	end -- 5062
end -- 5027
return ____exports -- 5027