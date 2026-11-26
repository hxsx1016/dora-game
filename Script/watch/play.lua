-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
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
function makeActor(room, index) -- 5566
	local sp = room.spawns -- 5567
	if index < 0 or index >= #sp then -- 5567
		return { -- 5569
			x = 0, -- 5569
			y = 0, -- 5569
			depth = 0, -- 5569
			depthSpeed = 0, -- 5569
			vx = 0, -- 5569
			vy = 0, -- 5569
			w = CHILD_W, -- 5569
			h = CHILD_H, -- 5569
			onGround = true, -- 5569
			facing = 1, -- 5569
			crouch = false, -- 5569
			rollT = 0, -- 5569
			covered = false, -- 5569
			alive = false -- 5569
		} -- 5569
	end -- 5569
	local s = sp[index + 1] -- 5571
	local child = s.h <= CHILD_H -- 5572
	local ground = room.depth -- 5573
	local depth = ground == nil and 0 or math.max( -- 5574
		ground.min, -- 5574
		math.min(ground.max, s.depth or 0) -- 5574
	) -- 5574
	return { -- 5575
		x = s.x, -- 5576
		y = s.y, -- 5576
		depth = depth, -- 5576
		depthSpeed = 0, -- 5576
		vx = 0, -- 5576
		vy = 0, -- 5576
		w = child and CHILD_W or SOLDIER_W, -- 5577
		h = child and CHILD_H or SOLDIER_H, -- 5578
		onGround = true, -- 5579
		facing = 1, -- 5579
		crouch = false, -- 5579
		rollT = 0, -- 5579
		covered = false, -- 5579
		alive = true -- 5579
	} -- 5579
end -- 5579
function drawFigure(draw, play, w, h, a, body, head) -- 5583
	if not a.alive then -- 5583
		return -- 5585
	end -- 5585
	local x0 = a.x - a.w / 2 -- 5587
	local x1 = a.x + a.w / 2 -- 5588
	local y0 = a.y + a.depth -- 5589
	local y1 = y0 + a.h -- 5590
	play:drawBox( -- 5591
		draw, -- 5591
		w, -- 5591
		h, -- 5591
		x0, -- 5591
		x1, -- 5591
		y0, -- 5591
		y1 - a.h * 0.26, -- 5591
		body -- 5591
	) -- 5591
	play:drawBox( -- 5592
		draw, -- 5592
		w, -- 5592
		h, -- 5592
		x0 + 2, -- 5592
		x1 - 2, -- 5592
		y1 - a.h * 0.26, -- 5592
		y1, -- 5592
		head -- 5592
	) -- 5592
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5594
	play:drawBox( -- 5595
		draw, -- 5595
		w, -- 5595
		h, -- 5595
		eyeX, -- 5595
		eyeX + 4, -- 5595
		y1 - a.h * 0.14, -- 5595
		y1 - a.h * 0.08, -- 5595
		INK -- 5595
	) -- 5595
end -- 5595
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5599
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5600
end -- 5599
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5607
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5608
end -- 5607
function rayInterval(origin, direction, min, max) -- 5615
	if direction == 0 then -- 5615
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5617
	end -- 5617
	local a = (min - origin) / direction -- 5619
	local b = (max - origin) / direction -- 5620
	return { -- 5621
		min = math.min(a, b), -- 5621
		max = math.max(a, b) -- 5621
	} -- 5621
end -- 5621
function hitBox(ray, box) -- 5625
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5626
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5627
	local enter = math.max(0, x.min, y.min) -- 5628
	local leave = math.min(99999, x.max, y.max) -- 5629
	if box.depth ~= nil then -- 5629
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5631
		enter = math.max(enter, depth.min) -- 5632
		leave = math.min(leave, depth.max) -- 5633
	end -- 5633
	return leave >= enter and enter or -1 -- 5635
end -- 5635
function drawCartShape(draw, play, w, h, c, axleX) -- 5638
	local half = c.bodyW / 2 -- 5639
	local x0 = axleX - half -- 5640
	local x1 = axleX + half -- 5641
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5642
	play:drawBox( -- 5643
		draw, -- 5643
		w, -- 5643
		h, -- 5643
		x0, -- 5643
		x1, -- 5643
		axleY, -- 5643
		axleY + c.bodyH, -- 5643
		CART_FILL -- 5643
	) -- 5643
	draw:drawCircle( -- 5644
		Vec2( -- 5644
			play:sx(x0 + c.bodyW * 0.28, w), -- 5644
			play:sy(axleY, h) -- 5644
		), -- 5644
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5644
		Color(52, 50, 48, 255) -- 5644
	) -- 5644
	draw:drawCircle( -- 5645
		Vec2( -- 5645
			play:sx(x1 - c.bodyW * 0.28, w), -- 5645
			play:sy(axleY, h) -- 5645
		), -- 5645
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5645
		Color(52, 50, 48, 255) -- 5645
	) -- 5645
	local cx = c.clothSide < 0 and x0 or x1 -- 5646
	play:drawBox( -- 5647
		draw, -- 5647
		w, -- 5647
		h, -- 5647
		cx - 10, -- 5647
		cx + 10, -- 5647
		axleY + c.bodyH, -- 5647
		axleY + c.bodyH + 18, -- 5647
		CLOTH -- 5647
	) -- 5647
end -- 5647
____exports.STEP = STEP -- 33
____exports.GRAVITY = 1000 -- 34
____exports.GATE_COUNT_END = 1440 -- 35
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 37
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 39
____exports.TOWER_CONFIRM_TICKS = 480 -- 40
local TOWER_REGISTER_TICKS = 180 -- 41
--- 值夜室桌前长按 E 的生效拍数（0.6 秒，与城门牵手同节奏）。
local TOWER_HANDOVER_TICKS = 36 -- 43
--- 跨过门槛的段内 x（门廊 400–490、值夜室 490–700）。
local TOWER_THRESHOLD_X = 500 -- 45
--- P01 黑场听父亲唤「小满」到睁眼落稳：4 秒 = 240 拍。
____exports.PROLOGUE_WAKE_TICKS = 240 -- 49
--- P02 门槛内墙上人影与瓷碗滚到脚边：2 秒 = 120 拍。
____exports.PROLOGUE_SHADOW_TICKS = 120 -- 51
--- 限时逃柜：7.5 秒 = 450 拍；超时退回门口重来，不扣血。
____exports.PROLOGUE_ESCAPE_TICKS = 450 -- 53
--- 入柜后红晕收尽、柜外脚步渐远：0.85 秒 = 51 拍。
____exports.PROLOGUE_HIDE_TICKS = 51 -- 55
--- 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。
____exports.PROLOGUE_CABINET_X = 132 -- 57
function ____exports.gateCountAtTick(tick) -- 59
	if tick >= ____exports.GATE_COUNT_END then -- 59
		return 20 -- 60
	end -- 60
	if tick >= 1260 then -- 60
		return 19 -- 61
	end -- 61
	if tick >= 1080 then -- 61
		return 18 -- 62
	end -- 62
	if tick >= 480 then -- 62
		return 11 + math.floor((tick - 480) * 7 / 600) -- 63
	end -- 63
	return 1 + math.floor(math.max(0, tick) / 48) -- 64
end -- 59
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 67
CHILD_W = 28 -- 142
CHILD_H = 64 -- 143
local CHILD_CROUCH_H = 36 -- 144
local CHILD_SPEED = 160 -- 145
local CHILD_SLOW = 80 -- 146
local CHILD_JUMP = 320 -- 147
SOLDIER_W = 30 -- 150
SOLDIER_H = 88 -- 151
local SOLDIER_SPEED = 264 -- 152
local ROLL_TIME = 0.35 -- 153
local ROLL_SPEED = 280 -- 154
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 156
local LEDGE_RISE = 60 -- 157
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 160
____exports.LOGIC_H = 180 -- 161
____exports.UNITS_PER_PX = 2 -- 162
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 164
local CAM_FOLLOW = 9 -- 165
local CAM_LOOK_UP = 46 -- 166
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 169
--- 握把触发半径。
____exports.CART_REACH = 70 -- 171
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 173
local CART_CLEAR = 44 -- 174
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 176
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 178
local CONSUMABLE_CAP = 1 -- 179
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 181
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 183
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 185
local FIRE_COOLDOWN = 150 -- 186
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 188
local ENEMY_RANGE = 760 -- 189
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 191
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 193
local DEPTH_SPEED_RATIO = 0.55 -- 194
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 195
INK = Color(232, 232, 228, 255) -- 197
local INK_DIM = Color(150, 152, 150, 255) -- 198
local BG_VOID = Color(8, 9, 10, 255) -- 199
local BG_FAR = Color(24, 26, 28, 255) -- 200
local BG_MID = Color(31, 34, 37, 255) -- 201
local GROUND = Color(112, 114, 112, 255) -- 202
local FLOOR_DECK = Color(66, 70, 72, 255) -- 203
local SOLID_FILL = Color(84, 86, 84, 255) -- 204
local SOLID_EDGE = Color(126, 130, 126, 255) -- 205
CART_FILL = Color(122, 78, 56, 255) -- 206
CLOTH = Color(178, 52, 46, 255) -- 207
local DANGER = Color(150, 54, 48, 46) -- 208
local DANGER_LINE = Color(178, 78, 64, 200) -- 209
local HOLE_FILL = Color(10, 11, 12, 255) -- 210
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 211
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 212
local CHILD_BODY = Color(214, 168, 96, 255) -- 213
local CHILD_HEAD = Color(232, 214, 186, 255) -- 214
local ENEMY_BODY = Color(176, 92, 84, 255) -- 215
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 216
local CHECK = Color(96, 186, 122, 255) -- 217
local STAND = Color(226, 186, 84, 255) -- 218
local AIM = Color(236, 236, 232, 230) -- 219
local AIM_HIT = Color(236, 96, 84, 255) -- 220
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 222
local SOFT_LINE = Color(140, 112, 80, 190) -- 223
local BRICK = Color(126, 118, 110, 70) -- 224
local BRICK_LINE = Color(160, 152, 142, 200) -- 225
local PASS = Color(96, 186, 122, 40) -- 226
local PASS_LINE = Color(96, 186, 122, 200) -- 227
local BOTTLE = Color(120, 186, 160, 255) -- 228
local SCAV_BODY = Color(128, 118, 96, 255) -- 229
local SCAV_HEAD = Color(196, 182, 158, 255) -- 230
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 317
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 318
	if zoom < 1 then -- 318
		zoom = 1 -- 320
	end -- 320
	return { -- 322
		zoom = zoom, -- 323
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 324
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 325
	} -- 325
end -- 317
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 348
	if key == "prologue" then -- 348
		return "prologue-wait" -- 352
	end -- 352
	if key == "street" then -- 352
		return "street-run" -- 355
	end -- 355
	if key == "gate" then -- 355
		return "gate-idle" -- 358
	end -- 358
	if key == "gatepath" then -- 358
		return "gatepath-start" -- 361
	end -- 361
	if key == "forest" then -- 361
		return "forest-run" -- 364
	end -- 364
	if key == "tower" then -- 364
		return "tower-wait" -- 367
	end -- 367
	if key == "museum" then -- 367
		return "museum-cabinet" -- 370
	end -- 370
	return "run" -- 372
end -- 348
____exports.Play = __TS__Class() -- 375
local Play = ____exports.Play -- 375
Play.name = "Play" -- 375
function Play.prototype.____constructor(self, room, resume, run) -- 649
	self.enemies = {} -- 380
	self.boxes = {} -- 381
	self.floors = {} -- 382
	self.checkpoint = -1 -- 384
	self.flash = "" -- 386
	self.flashT = 0 -- 387
	self.traceT = 0 -- 390
	self.focusCart = false -- 392
	self.knocks = 0 -- 394
	self.knockT = 0 -- 395
	self.cartAxle = 0 -- 399
	self.cartDocked = false -- 401
	self.gripping = false -- 403
	self.gateOpen = false -- 405
	self.calmConsumed = false -- 407
	self.craftT = 0 -- 409
	self.nextDangerId = 1 -- 411
	self.wantRoom = "" -- 413
	self.carryCartAxle = -1 -- 415
	self.carryCartDocked = false -- 416
	self.checkpointCartAxle = -1 -- 418
	self.hasBottle = false -- 422
	self.bottleLandX = -1 -- 426
	self.bottleTargetX = -1 -- 427
	self.bottleTargetY = 0 -- 428
	self.bottleLandT = 0 -- 429
	self.aimHold = 0 -- 431
	self.redCartPulled = false -- 433
	self.footHintT = 0 -- 435
	self.ditchHinted = false -- 437
	self.forestPath = "" -- 439
	self.waterSeen = false -- 441
	self.scavX = 0 -- 443
	self.scavDir = 1 -- 444
	self.scavState = "patrol" -- 445
	self.scavT = 0 -- 446
	self.scavTargetX = 0 -- 447
	self.passed = false -- 449
	self.childMode = false -- 453
	self.phase = "" -- 455
	self.phaseTick = 0 -- 457
	self.gateTick = 0 -- 459
	self.countTick = 0 -- 461
	self.countArmed = false -- 463
	self.countPrevMove = 0 -- 465
	self.caughtT = 0 -- 467
	self.hp = 3 -- 469
	self.maxHp = 3 -- 470
	self.invulnT = 0 -- 476
	self.partnerStuck = 0 -- 478
	self.partnerLaneIdx = 0 -- 480
	self.partnerLaneHold = 0 -- 481
	self.coveredFlash = 0 -- 483
	self.coverHug = false -- 485
	self.coverNear = false -- 487
	self.coverEntity = "" -- 489
	self.coverBlocking = false -- 491
	self.gateNeedConfirm = false -- 493
	self.gateRestartArmed = true -- 495
	self.bottleAimX = -1 -- 497
	self.bottleAimY = 0 -- 498
	self.bottleSurfaceY = -1 -- 500
	self.bottleLandY = 0 -- 502
	self.events = {} -- 504
	self.eventSeq = 0 -- 506
	self.dogX = 0 -- 508
	self.dogDir = 1 -- 509
	self.dogState = "patrol" -- 510
	self.dogT = 0 -- 511
	self.dogTargetX = 0 -- 512
	self.scavSee = 0 -- 514
	self.scavChase = false -- 515
	self.gateSpawned = 0 -- 517
	self.gateFailCount = 0 -- 519
	self.isCampaign = false -- 523
	self.archiveDirty = false -- 531
	self.restartStory = false -- 533
	self.wellOpen = false -- 535
	self.wellX = 430 -- 537
	self.wellTaken = false -- 539
	self.museumReturn = false -- 541
	self.endingLines = {"", ""} -- 543
	self.towerDoorOpen = false -- 545
	self.towerHanded = false -- 546
	self.deskHold = 0 -- 547
	self.equippedWeapon = "standard_gun" -- 551
	self.craftBench = { -- 553
		active = false, -- 554
		firstCraftDone = false, -- 555
		justCraftedTimer = 0, -- 556
		inventory = {}, -- 557
		recipes = {}, -- 558
		equippedWeapon = "standard_gun" -- 559
	} -- 559
	self.handledCraftRequests = {} -- 562
	self.benchReach = 48 -- 564
	self.pickups = {} -- 568
	self.reloadT = 0 -- 570
	self.objectiveDone = false -- 574
	self.hint = "" -- 576
	self.roomStartTick = 0 -- 578
	self.cartHitT = 0 -- 580
	self.cartExposed = false -- 581
	self.storyRoute = "" -- 585
	self.storySettled = false -- 587
	self.hpAtGate = -1 -- 589
	self.maxHpAtGate = -1 -- 590
	self.handTicks = 0 -- 592
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 594
	self.handArmed = false -- 596
	self.handDone = false -- 598
	self.lineSaid = false -- 599
	self.tied = false -- 601
	self.pathDone = false -- 603
	self.carryOn = false -- 605
	self.escortDone = false -- 607
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 611
	self.escapeRemaining = 0 -- 613
	self.escapeRetryCount = 0 -- 615
	self.introTick = 0 -- 617
	self.reloadOpen = false -- 621
	self.reloadAnswerTicks = 0 -- 623
	self.reloadWorldTicks = 0 -- 625
	self.reloadPath = {RELOAD_START} -- 627
	self.reloadPendingEffect = "" -- 629
	self.reloadTryCount = 0 -- 631
	self.paused = false -- 633
	self.ticks = 0 -- 635
	self.view = {zoom = 1, ox = 0, oy = 0} -- 637
	self.ox = 0 -- 639
	self.aimX = 0 -- 641
	self.aimY = 0 -- 642
	self.viewW = 0 -- 644
	self.viewH = 0 -- 645
	self.ox = room.originX -- 651
	self.room = withOrigin(room) -- 652
	local wr = self.room -- 653
	self.run = run or createRun() -- 654
	self.inventory = self.run.inventory -- 655
	self.archive = self.run.archive -- 656
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 657
	self.isCampaign = wr.campaign ~= nil -- 658
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 659
	self:buildWorld() -- 660
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 663
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 665
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 666
	local soloRoom = wr.key == "museum" -- 668
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 669
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 670
	self.player = makeActor(wr, playerIdx) -- 671
	self.partner = makeActor(wr, partnerIdx) -- 672
	self.phase = phaseOf(wr.key) -- 673
	if soloRoom then -- 673
		local mp = self.archive.museumPhase -- 676
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 677
	end -- 677
	if wr.story ~= nil then -- 677
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 683
	end -- 683
	self.cam.x = self.player.x -- 685
	self.cam.y = self.player.y + CAM_LOOK_UP -- 686
	self.cartAxle = wr.cart.startX -- 687
	self.escort = __TS__New( -- 688
		Escort, -- 688
		safeAnchorX(wr.marks) -- 688
	) -- 688
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 689
	if self.isCampaign then -- 689
		self:setupCampaign() -- 691
	else -- 691
		self:buildEnemies() -- 693
	end -- 693
	if resume ~= nil and resume.checkpoint > 0 then -- 693
		self.checkpoint = resume.checkpoint -- 697
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 697
			self.cartAxle = self.room.cart.endX -- 699
			self.cartDocked = true -- 700
			self.player.x = self.ox + 380 -- 703
			self.player.y = 0 -- 704
			self.player.vy = 0 -- 705
			self.player.onGround = true -- 706
			self.cam.x = self.player.x -- 707
			self.cam.y = self.player.y + CAM_LOOK_UP -- 708
		end -- 708
	end -- 708
	self:restoreStory() -- 711
end -- 649
function Play.prototype.recipeViews(self) -- 724
	local out = {} -- 725
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #CRAFT_RECIPES do -- 727
			local r = CRAFT_RECIPES[i + 1] -- 728
			local cost = {} -- 729
			if r.cost.wood ~= nil then -- 729
				cost.wood = r.cost.wood -- 731
			end -- 731
			if r.cost.bell ~= nil then -- 731
				cost.bell = r.cost.bell -- 734
			end -- 734
			out[#out + 1] = { -- 736
				id = r.id, -- 737
				name = r.name, -- 738
				desc = r.desc, -- 739
				enhancedEffect = r.enhancedEffect, -- 740
				cost = cost, -- 741
				crafted = self.run.story.craftedWeapon == r.id -- 742
			} -- 742
			i = i + 1 -- 727
		end -- 727
	end -- 727
	return out -- 745
end -- 724
function Play.prototype.syncCraftBench(self) -- 749
	local view = self.craftBench -- 750
	local inv = self.run.inventory -- 751
	view.inventory = { -- 752
		wood = inv.wood, -- 752
		bell = inv.bell, -- 752
		scrap = inv.scrap, -- 752
		wedge = inv.wedge, -- 752
		ammo = inv.ammo -- 752
	} -- 752
	view.recipes = self:recipeViews() -- 753
	view.equippedWeapon = self.equippedWeapon -- 754
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 755
	if view.justCraftedTimer > 0 then -- 755
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 757
	end -- 757
end -- 749
function Play.prototype.openCraftBench(self) -- 762
	if self.room.key ~= "escort3" or self.craftBench.active then -- 762
		return -- 764
	end -- 764
	self.craftBench.active = true -- 766
	self.carryOn = false -- 767
	self.run.story.carry = false -- 768
	self.player.vx = 0 -- 769
	self.player.vy = 0 -- 770
	self.craftBench.justCraftedTimer = 0 -- 771
	self:syncCraftBench() -- 772
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 773
	self:log("开工台") -- 774
	self:emit( -- 775
		"benchOpen", -- 775
		{ -- 775
			recipes = __TS__ArrayMap( -- 776
				self.craftBench.recipes, -- 776
				function(____, r) return r.id end -- 776
			), -- 776
			inventory = self.craftBench.inventory, -- 777
			carry = self.carryOn -- 778
		} -- 778
	) -- 778
end -- 762
function Play.prototype.closeCraftBench(self) -- 783
	if not self.craftBench.active then -- 783
		return -- 785
	end -- 785
	self.craftBench.active = false -- 787
	self.craftBench.justCraftedTimer = 0 -- 788
	self.carryOn = true -- 789
	self.run.story.carry = true -- 790
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 791
	self:log("离站背起") -- 792
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 793
end -- 783
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 800
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 800
		return false -- 802
	end -- 802
	local recipe = findRecipe(recipeId) -- 804
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 804
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 806
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 807
		return false -- 808
	end -- 808
	local missing = missingMaterials(self.run.inventory, recipe) -- 810
	if #missing > 0 then -- 810
		self:flashSet( -- 812
			"缺料 · " .. table.concat(missing, " / "), -- 812
			1.6 -- 812
		) -- 812
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 813
		return false -- 814
	end -- 814
	payMaterials(self.run.inventory, recipe) -- 816
	self.handledCraftRequests[requestId] = true -- 817
	self.run.story.craftedWeapon = recipe.id -- 818
	self.equippedWeapon = recipe.id -- 819
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 820
	self.craftBench.firstCraftDone = true -- 821
	self:syncCraftBench() -- 822
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 823
	self:log("改制 " .. recipe.id) -- 824
	self:emit("benchCraft", { -- 825
		recipeId = recipe.id, -- 826
		weapon = recipe.id, -- 827
		effect = recipe.enhancedEffect, -- 828
		wood = self.run.inventory.wood, -- 829
		bell = self.run.inventory.bell -- 830
	}) -- 830
	return true -- 832
end -- 800
function Play.prototype.equipWeapon(self, weaponId) -- 836
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 836
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 838
		return false -- 839
	end -- 839
	self.equippedWeapon = weaponId -- 841
	self:syncCraftBench() -- 842
	self:flashSet( -- 843
		"已装备 " .. weaponNameOf(weaponId), -- 843
		1 -- 843
	) -- 843
	self:emit("benchEquip", {weapon = weaponId}) -- 844
	return true -- 845
end -- 836
function Play.prototype.submitFeIntent(self, intent) -- 852
	local kind = intent == nil and "" or intent.kind -- 853
	if kind == "reloadTapNode" then -- 853
		local node = intent.node -- 855
		if type(node) == "number" then -- 855
			self:reloadTapNode(node) -- 857
			return true -- 858
		end -- 858
		return false -- 860
	end -- 860
	if kind == "reloadPathCommit" then -- 860
		local path = intent.path -- 863
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 863
			local list = path -- 865
			local i = 0 -- 866
			do -- 866
				i = 0 -- 867
				while i < #list do -- 867
					do -- 867
						if i == 0 and list[i + 1] == RELOAD_START then -- 867
							goto __continue48 -- 869
						end -- 869
						self:reloadTapNode(list[i + 1]) -- 871
					end -- 871
					::__continue48:: -- 871
					i = i + 1 -- 867
				end -- 867
			end -- 867
			return true -- 873
		end -- 873
		return false -- 875
	end -- 875
	if kind == "reloadCancel" then -- 875
		self:closeReloadPuzzle() -- 878
		return true -- 879
	end -- 879
	if kind == "craftSubmit" then -- 879
		local recipeId = intent.recipeId -- 882
		local requestId = intent.requestId -- 883
		if type(recipeId) == "string" and type(requestId) == "string" then -- 883
			return self:craftAtBench(recipeId, requestId) -- 885
		end -- 885
		return false -- 887
	end -- 887
	if kind == "craftEquip" then -- 887
		local weaponId = intent.weaponId -- 890
		if type(weaponId) == "string" then -- 890
			return self:equipWeapon(weaponId) -- 892
		end -- 892
		return false -- 894
	end -- 894
	if kind == "craftClose" then -- 894
		self:closeCraftBench() -- 897
		return true -- 898
	end -- 898
	if kind == "wellPick" then -- 898
		return self:pickWell() -- 901
	end -- 901
	return false -- 903
end -- 852
function Play.prototype.captureCheckpoint(self, id) -- 907
	local inv = self.run.inventory -- 908
	self.checkpointSnap = { -- 909
		id = id, -- 910
		wood = inv.wood, -- 911
		bell = inv.bell, -- 912
		scrap = inv.scrap, -- 913
		wedge = inv.wedge, -- 914
		ammo = inv.ammo, -- 915
		shield = inv.shield, -- 916
		pass = inv.pass, -- 917
		quickbelt = inv.quickbelt, -- 918
		crafted = self.run.story.craftedWeapon, -- 919
		equipped = self.equippedWeapon, -- 920
		carry = self.carryOn -- 921
	} -- 921
	self.run.story.cp = self.checkpointSnap -- 923
end -- 907
function Play.prototype.applyCheckpointSnap(self, id) -- 927
	local snap = self.run.story.cp -- 928
	if snap == nil or snap.id ~= id then -- 928
		return false -- 930
	end -- 930
	self.checkpointSnap = snap -- 932
	local inv = self.run.inventory -- 933
	inv.wood = snap.wood -- 934
	inv.bell = snap.bell -- 935
	inv.scrap = snap.scrap -- 936
	inv.wedge = snap.wedge -- 937
	inv.ammo = snap.ammo -- 938
	inv.shield = snap.shield -- 939
	inv.pass = snap.pass -- 940
	inv.quickbelt = snap.quickbelt -- 941
	self.run.story.craftedWeapon = snap.crafted -- 942
	self.equippedWeapon = snap.equipped -- 943
	self.carryOn = snap.carry -- 944
	self.run.story.carry = snap.carry -- 945
	self.craftBench.active = false -- 946
	self:syncCraftBench() -- 947
	return true -- 948
end -- 927
function Play.prototype.restoreStory(self) -- 951
	if self.isCampaign and self.run.trial ~= nil then -- 951
		return -- 955
	end -- 955
	local story = self.run.story -- 957
	if story == nil then -- 957
		return -- 959
	end -- 959
	if story.maxHp > 0 then -- 959
		self.maxHp = story.maxHp -- 962
		self.hp = math.max( -- 963
			1, -- 963
			math.min(story.hp, story.maxHp) -- 963
		) -- 963
	end -- 963
	self.storyRoute = story.route -- 965
	self.storySettled = story.settled -- 966
	self.hpAtGate = story.hpAtGate -- 967
	self.maxHpAtGate = story.maxHpAtGate -- 968
	self.handDone = story.handDone -- 969
	self.lineSaid = story.lineSaid -- 970
	self.tied = story.handDone -- 971
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 972
	self.museumReturn = story.museumReturn -- 973
	story.museumReturn = false -- 974
	self.escortDone = story.escortDone -- 975
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 976
	self:syncCraftBench() -- 977
	if story.segments.outside_cart == true then -- 977
		self.redCartPulled = true -- 980
		local redBox = __TS__ArrayFind( -- 981
			self.boxes, -- 981
			function(____, b) return b.id == "outside_red_cart" end -- 981
		) -- 981
		if redBox ~= nil then -- 981
			redBox.x0 = 300 -- 983
			redBox.x1 = 344 -- 984
		end -- 984
	end -- 984
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 987
	self.waterSeen = story.segments.water_lantern == true -- 989
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 989
		self:applyCheckpointSnap(self.checkpoint) -- 992
	end -- 992
	if self.room.key == "tower" and story.route == "soldier" then -- 992
		self.carryOn = false -- 996
		self.run.story.carry = false -- 997
	end -- 997
	if self.room.key == "tower" then -- 997
		if story.segments.tower_door == true then -- 997
			self:openTowerDoor() -- 1002
		end -- 1002
		self.towerHanded = story.segments.tower_handover == true -- 1004
		self.deskHold = 0 -- 1005
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1005
			self.phase = story.phase -- 1007
			self.phaseTick = 0 -- 1008
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1008
				self.player.x = self.ox + 605 -- 1010
				self.player.y = 0 -- 1011
			end -- 1011
		end -- 1011
	end -- 1011
	if self.room.key == "prologue" then -- 1011
		local ph = story.phase -- 1017
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1017
			self.phase = ph -- 1019
			self.phaseTick = story.phaseTick -- 1020
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1021
			self.player.y = 0 -- 1022
			self.player.depth = 0 -- 1023
			self.player.vx = 0 -- 1024
			self.partner.x = self.ox + 300 -- 1025
			self.partner.y = 0 -- 1026
			self.partner.depth = 0 -- 1027
			self.partner.vx = 0 -- 1028
			self.partner.alive = true -- 1029
			if ph == "prologue-follow" then -- 1029
				self.partner.crouch = false -- 1031
				self.partner.h = CHILD_H -- 1032
			else -- 1032
				self.partner.crouch = true -- 1034
				self.partner.h = CHILD_CROUCH_H -- 1035
			end -- 1035
			self.cam.x = self.player.x -- 1037
		end -- 1037
		return -- 1039
	end -- 1039
	if self.room.key ~= "gate" then -- 1039
		return -- 1042
	end -- 1042
	local ____temp_0 -- 1044
	if self.room.story == nil then -- 1044
		____temp_0 = nil -- 1044
	else -- 1044
		____temp_0 = self.room.story.gate -- 1044
	end -- 1044
	local g = ____temp_0 -- 1044
	if g == nil then -- 1044
		return -- 1046
	end -- 1046
	if story.phase == "gate-send" then -- 1046
		self.phase = "gate-send" -- 1050
		self.gateTick = g.holdTicks -- 1051
		self.gateSpawned = 4 -- 1052
		self.enemies = {} -- 1053
		self.player.x = self.ox + g.doorX - 40 -- 1054
		self.player.y = 0 -- 1055
		self.player.depth = 0 -- 1056
		self.player.vx = 0 -- 1057
		self.player.vy = 0 -- 1058
		self.player.onGround = true -- 1059
		self.partner.x = self.ox + g.waitX -- 1060
		self.partner.y = 0 -- 1061
		self.partner.depth = 0 -- 1062
		self.partner.alive = true -- 1063
		self.cam.x = self.player.x -- 1064
		self.handTicks = 0 -- 1065
		self.handArmed = false -- 1066
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1067
		return -- 1068
	end -- 1068
	if not story.settled then -- 1068
		return -- 1071
	end -- 1071
	self.gateTick = g.holdTicks -- 1074
	self.gateSpawned = 4 -- 1075
	self.enemies = {} -- 1076
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1076
		self.phase = story.phase -- 1078
		self.countTick = math.max(story.countTick, 0) -- 1079
		self:swapToChild(g.doorX + 30) -- 1080
		self.countPrevMove = 0 -- 1081
		self.countArmed = false -- 1082
		return -- 1083
	end -- 1083
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1083
		self.phase = story.phase -- 1086
		self.countTick = ____exports.GATE_COUNT_END -- 1087
		self.phaseTick = story.phaseTick -- 1088
		self:swapToChild(g.doorX + 30) -- 1089
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1090
			0, -- 1090
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1090
		) -- 1090
		self.handArmed = false -- 1091
	end -- 1091
end -- 951
function Play.prototype.buildWorld(self) -- 1096
	local room = self.room -- 1097
	self.boxes = {} -- 1098
	self.floors = {} -- 1099
	local i = 0 -- 1100
	do -- 1100
		i = 0 -- 1101
		while i < #room.floors do -- 1101
			local f = room.floors[i + 1] -- 1102
			local ____self_floors_1 = self.floors -- 1102
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1103
			i = i + 1 -- 1101
		end -- 1101
	end -- 1101
	do -- 1101
		i = 0 -- 1105
		while i < #room.solids do -- 1105
			local s = room.solids[i + 1] -- 1106
			if not s.decorative then -- 1106
				local ____self_boxes_13 = self.boxes -- 1112
				local ____s_x_4 = s.x -- 1113
				local ____temp_5 = s.x + s.w -- 1113
				local ____s_y_6 = s.y -- 1113
				local ____temp_7 = s.y + s.h -- 1113
				local ____temp_2 -- 1114
				if room.depth == nil then -- 1114
					____temp_2 = nil -- 1114
				else -- 1114
					____temp_2 = s.depth -- 1114
				end -- 1114
				local ____temp_8 = s.passable == true -- 1115
				local ____s_label_9 = s.label -- 1115
				local ____s_id_10 = s.id -- 1116
				local ____temp_11 = s.soft == true -- 1116
				local ____temp_12 = s.hidden == true -- 1116
				local ____temp_3 -- 1117
				if s.breakable == nil then -- 1117
					____temp_3 = nil -- 1117
				else -- 1117
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1117
				end -- 1117
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1112
					x0 = ____s_x_4, -- 1113
					x1 = ____temp_5, -- 1113
					y0 = ____s_y_6, -- 1113
					y1 = ____temp_7, -- 1113
					depth = ____temp_2, -- 1114
					passable = ____temp_8, -- 1115
					label = ____s_label_9, -- 1115
					id = ____s_id_10, -- 1116
					soft = ____temp_11, -- 1116
					hidden = ____temp_12, -- 1116
					breakable = ____temp_3, -- 1117
					interact = s.interact -- 1118
				} -- 1118
			end -- 1118
			i = i + 1 -- 1105
		end -- 1105
	end -- 1105
	do -- 1105
		i = 0 -- 1122
		while i < #room.stairs do -- 1122
			local st = room.stairs[i + 1] -- 1123
			local n = st.steps + 1 -- 1124
			local stepW = (st.x1 - st.x0) / n -- 1125
			local k = 0 -- 1126
			do -- 1126
				k = 0 -- 1127
				while k < n do -- 1127
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1128
					local x0 = st.x0 + stepW * k -- 1129
					local ____self_boxes_14 = self.boxes -- 1129
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 1131
						x0 = x0, -- 1131
						x1 = x0 + stepW, -- 1131
						y0 = -8, -- 1131
						y1 = y, -- 1131
						passable = true -- 1131
					} -- 1131
					k = k + 1 -- 1127
				end -- 1127
			end -- 1127
			i = i + 1 -- 1122
		end -- 1122
	end -- 1122
end -- 1096
function Play.prototype.setupCampaign(self) -- 1140
	local wr = self.room -- 1141
	local c = wr.campaign -- 1142
	if c == nil then -- 1142
		return -- 1144
	end -- 1144
	self.roomStartTick = self.run.ticks -- 1146
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1146
		self.run.joined = true -- 1150
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1150
		local ____self_run_16 = self.run -- 1153
		local ____temp_15 -- 1153
		if wr.key == "s2-drygoods" then -- 1153
			____temp_15 = self.run.route ~= "drygoods" -- 1153
		else -- 1153
			____temp_15 = false -- 1153
		end -- 1153
		____self_run_16.joined = ____temp_15 -- 1153
	end -- 1153
	local x = wr.minX + 60 -- 1155
	local y = 0 -- 1156
	local depth = 0 -- 1157
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1157
		x = wr.minX + 210 -- 1159
		depth = -32 -- 1160
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1160
		x = wr.minX + 40 -- 1162
		y = 32 -- 1163
		depth = 32 -- 1164
	end -- 1164
	self.player = { -- 1166
		x = x, -- 1167
		y = y, -- 1167
		depth = depth, -- 1167
		depthSpeed = 0, -- 1167
		vx = 0, -- 1167
		vy = 0, -- 1167
		w = SOLDIER_W, -- 1168
		h = SOLDIER_H, -- 1168
		onGround = y <= 0, -- 1168
		facing = 1, -- 1168
		crouch = false, -- 1168
		rollT = 0, -- 1168
		covered = false, -- 1168
		alive = true -- 1168
	} -- 1168
	self.partner = { -- 1170
		x = x + 60, -- 1171
		y = y, -- 1171
		depth = depth, -- 1171
		depthSpeed = 0, -- 1171
		vx = 0, -- 1171
		vy = 0, -- 1171
		w = CHILD_W, -- 1172
		h = CHILD_H, -- 1172
		onGround = y <= 0, -- 1172
		facing = 1, -- 1172
		crouch = false, -- 1172
		rollT = 0, -- 1172
		covered = false, -- 1172
		alive = true -- 1172
	} -- 1172
	self.cam.x = x -- 1174
	self.cam.y = y + CAM_LOOK_UP -- 1175
	self.phase = "run" -- 1176
	self.hp = self.maxHp -- 1177
	local trial = self.run.trial -- 1178
	if trial ~= nil then -- 1178
		draftRoom(trial, wr.key) -- 1180
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1181
		self.hp = trial.hp -- 1182
	end -- 1182
	self:buildEnemies() -- 1184
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1185
	local i = 0 -- 1186
	do -- 1186
		i = 0 -- 1187
		while i < #self.boxes do -- 1187
			do -- 1187
				local b = self.boxes[i + 1] -- 1188
				if b.id == nil then -- 1188
					goto __continue101 -- 1190
				end -- 1190
				local st = self.run.props[b.id] -- 1192
				if st ~= nil then -- 1192
					b.broken = st.broken -- 1194
					local ____temp_17 -- 1195
					if b.breakable == nil then -- 1195
						____temp_17 = nil -- 1195
					else -- 1195
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1195
					end -- 1195
					b.breakable = ____temp_17 -- 1195
					b.hidden = b.hidden == true and st.revealed ~= true -- 1196
					if b.hidden then -- 1196
						b.broken = true -- 1198
					end -- 1198
				elseif b.hidden == true then -- 1198
					b.broken = true -- 1202
				end -- 1202
			end -- 1202
			::__continue101:: -- 1202
			i = i + 1 -- 1187
		end -- 1187
	end -- 1187
	if wr.cart.bodyW > 0 then -- 1187
		self.cartAxle = wr.cart.startX -- 1206
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1206
			self.cartAxle = wr.cart.endX -- 1208
			self.cartDocked = true -- 1209
		end -- 1209
	end -- 1209
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1212
end -- 1140
function Play.prototype.log(self, line) -- 1215
	local ____self_run_log_18 = self.run.log -- 1215
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1216
	if #self.run.log > 120 then -- 1216
		table.remove(self.run.log, 1) -- 1218
	end -- 1218
end -- 1215
function Play.prototype.buildEnemies(self) -- 1222
	self.enemies = {} -- 1223
	if self.isCampaign then -- 1223
		local i = 0 -- 1225
		do -- 1225
			i = 0 -- 1226
			while i < #self.room.spawns do -- 1226
				local sp = self.room.spawns[i + 1] -- 1227
				local kind = sp.kind or "gunner" -- 1228
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1229
				local ____self_enemies_19 = self.enemies -- 1229
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1230
					x = sp.x, -- 1231
					y = sp.y, -- 1231
					depth = sp.depth, -- 1231
					w = 26, -- 1231
					h = sp.h, -- 1231
					alive = true, -- 1231
					hitT = 0, -- 1231
					warnT = 0, -- 1231
					fireCd = 40, -- 1231
					kind = kind, -- 1232
					shieldHp = hp, -- 1232
					shieldHpMax = hp, -- 1232
					drop = sp.drop or "none", -- 1232
					homeX = sp.x, -- 1233
					swingT = 0, -- 1233
					awake = false, -- 1233
					squad = i -- 1233
				} -- 1233
				i = i + 1 -- 1226
			end -- 1226
		end -- 1226
		return -- 1236
	end -- 1236
	if self.room.key == "checkpoint" then -- 1236
		local ____self_enemies_20 = self.enemies -- 1236
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1239
			x = self.ox + 430, -- 1239
			y = 0, -- 1239
			w = 26, -- 1239
			h = 84, -- 1239
			alive = true, -- 1239
			hitT = 0, -- 1239
			warnT = 0, -- 1239
			fireCd = 0 -- 1239
		} -- 1239
		local ____self_enemies_21 = self.enemies -- 1239
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1240
			x = self.ox + 505, -- 1240
			y = 0, -- 1240
			w = 26, -- 1240
			h = 84, -- 1240
			alive = true, -- 1240
			hitT = 0, -- 1240
			warnT = 0, -- 1240
			fireCd = 0 -- 1240
		} -- 1240
		return -- 1241
	end -- 1241
	if self.room.key == "street" then -- 1241
		local ____self_enemies_22 = self.enemies -- 1241
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1245
			x = self.ox + 340, -- 1245
			y = 0, -- 1245
			w = 26, -- 1245
			h = 84, -- 1245
			alive = true, -- 1245
			hitT = 0, -- 1245
			warnT = 0, -- 1245
			fireCd = 0 -- 1245
		} -- 1245
		local ____self_enemies_23 = self.enemies -- 1245
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1246
			x = self.ox + 560, -- 1246
			y = 0, -- 1246
			w = 26, -- 1246
			h = 84, -- 1246
			alive = true, -- 1246
			hitT = 0, -- 1246
			warnT = 0, -- 1246
			fireCd = 0 -- 1246
		} -- 1246
	end -- 1246
end -- 1222
function Play.prototype.emit(self, name, data) -- 1252
	local ____self_events_24 = self.events -- 1252
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1253
	self.eventSeq = self.eventSeq + 1 -- 1254
	if #self.events > 256 then -- 1254
		table.remove(self.events, 1) -- 1256
	end -- 1256
end -- 1252
function Play.prototype.drainEvents(self) -- 1264
	local out = self.events -- 1265
	self.events = {} -- 1266
	return out -- 1267
end -- 1264
function Play.prototype.adoptEvents(self, events) -- 1276
	if #events == 0 then -- 1276
		return -- 1278
	end -- 1278
	local keep = {} -- 1280
	local i = 0 -- 1281
	do -- 1281
		i = 0 -- 1282
		while i < #events do -- 1282
			do -- 1282
				local e = events[i + 1] -- 1283
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1283
					goto __continue122 -- 1285
				end -- 1285
				keep[#keep + 1] = e -- 1287
			end -- 1287
			::__continue122:: -- 1287
			i = i + 1 -- 1282
		end -- 1282
	end -- 1282
	if #keep == 0 then -- 1282
		return -- 1290
	end -- 1290
	self.events = __TS__ArrayConcat(keep, self.events) -- 1292
	do -- 1292
		i = 0 -- 1293
		while i < #self.events do -- 1293
			self.events[i + 1].seq = i -- 1294
			i = i + 1 -- 1293
		end -- 1293
	end -- 1293
	self.eventSeq = #self.events -- 1296
end -- 1276
function Play.prototype.chooseTalent(self, slot) -- 1299
	local trial = self.run.trial -- 1300
	local talent = trial and trial.offers[slot + 1] -- 1301
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1301
		return -- 1302
	end -- 1302
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1302
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1303
	trial.offers = {} -- 1304
	if talent == "vitality" then -- 1304
		self.maxHp = self.maxHp + 1 -- 1306
		self.hp = self.hp + 1 -- 1307
		trial.hp = self.hp -- 1308
	end -- 1308
	self:flashSet(talentNames[talent], 1.2) -- 1310
end -- 1299
function Play.prototype.beginReload(self) -- 1318
	self.reloadT = self:reloadTicks() -- 1319
	local camp = self.room.campaign -- 1320
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1320
		self:openReloadPuzzle() -- 1323
	end -- 1323
end -- 1318
function Play.prototype.openReloadPuzzle(self) -- 1328
	self.reloadOpen = true -- 1329
	self.reloadAnswerTicks = 0 -- 1330
	self.reloadWorldTicks = 0 -- 1331
	self.reloadPath = {RELOAD_START} -- 1332
	self.reloadPendingEffect = "" -- 1333
	self.reloadTryCount = self.reloadTryCount + 1 -- 1334
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1335
end -- 1328
function Play.prototype.closeReloadPuzzle(self) -- 1339
	self.reloadOpen = false -- 1340
	self.reloadAnswerTicks = 0 -- 1341
	self.reloadWorldTicks = 0 -- 1342
	self.reloadPath = {RELOAD_START} -- 1343
	self.reloadPendingEffect = "" -- 1344
end -- 1339
function Play.prototype.reloadTapNode(self, node) -- 1351
	if not self.reloadOpen then -- 1351
		return -- 1353
	end -- 1353
	local path = self.reloadPath -- 1355
	local last = path[#path] -- 1356
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1356
		self.reloadPath = {RELOAD_START} -- 1358
		self:emit("reloadInvalid", {node = node, at = last}) -- 1359
		return -- 1360
	end -- 1360
	path[#path + 1] = node -- 1362
	if node ~= RELOAD_TARGET then -- 1362
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1364
		return -- 1365
	end -- 1365
	if not reloadPathValid(path) then -- 1365
		self.reloadPath = {RELOAD_START} -- 1368
		self:emit("reloadInvalid", {node = node, at = last}) -- 1369
		return -- 1370
	end -- 1370
	self.reloadPendingEffect = reloadEffectOf(path) -- 1372
	self.reloadOpen = false -- 1373
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1374
	self:flashSet( -- 1377
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1377
		1.4 -- 1377
	) -- 1377
end -- 1351
function Play.prototype.consumeReloadEffect(self) -- 1381
	local e = self.reloadPendingEffect -- 1382
	if e ~= "" then -- 1382
		self.reloadPendingEffect = "" -- 1384
	end -- 1384
	return e -- 1386
end -- 1381
function Play.prototype.echoToSource(self, from, count) -- 1393
	if count == nil then -- 1393
		count = 1 -- 1393
	end -- 1393
	local best = -1 -- 1394
	local bestD = 1000000000 -- 1395
	local i = 0 -- 1396
	local woken = {} -- 1397
	local n = 0 -- 1398
	while n < count do -- 1398
		best = -1 -- 1400
		bestD = 1000000000 -- 1401
		do -- 1401
			i = 0 -- 1402
			while i < #self.enemies do -- 1402
				do -- 1402
					if woken[i] == true then -- 1402
						goto __continue144 -- 1404
					end -- 1404
					local e = self.enemies[i + 1] -- 1406
					if not e.alive then -- 1406
						goto __continue144 -- 1408
					end -- 1408
					local d = math.abs(e.x - from.x) -- 1410
					if d < bestD then -- 1410
						bestD = d -- 1412
						best = i -- 1413
					end -- 1413
				end -- 1413
				::__continue144:: -- 1413
				i = i + 1 -- 1402
			end -- 1402
		end -- 1402
		if best < 0 then -- 1402
			break -- 1417
		end -- 1417
		woken[best] = true -- 1419
		local e = self.enemies[best + 1] -- 1420
		e.awake = true -- 1421
		e.warnT = 0 -- 1422
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1423
		n = n + 1 -- 1424
	end -- 1424
	if n == 0 then -- 1424
		return -- 1427
	end -- 1427
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1429
end -- 1393
function Play.prototype.reloadTicks(self) -- 1432
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1433
	local ____opt_29 = self.run.trial -- 1433
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1433
end -- 1432
function Play.prototype.update(self, dt, input) -- 1436
	self:syncCraftBench() -- 1437
	local trial = self.run.trial -- 1438
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1438
		return -- 1439
	end -- 1439
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1439
		self:closeCraftBench() -- 1441
		return -- 1442
	end -- 1442
	if input.pause.pressed then -- 1442
		self.paused = not self.paused -- 1445
	end -- 1445
	if self.flashT > 0 then -- 1445
		self.flashT = self.flashT - dt -- 1448
		if self.flashT <= 0 then -- 1448
			self.flash = "" -- 1450
		end -- 1450
	end -- 1450
	if self.traceT > 0 then -- 1450
		self.traceT = self.traceT - dt -- 1454
		if self.traceT <= 0 then -- 1454
			self.trace = nil -- 1456
		end -- 1456
	end -- 1456
	if self.paused then -- 1456
		self:updateCamera(dt) -- 1460
		return -- 1461
	end -- 1461
	if self.craftBench.active then -- 1461
		self:updateCamera(dt) -- 1466
		return -- 1467
	end -- 1467
	if self.reloadOpen then -- 1467
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1473
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1473
			self.reloadOpen = false -- 1475
			self.reloadPendingEffect = "" -- 1476
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1477
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1478
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1478
			self:updateCamera(dt) -- 1480
			return -- 1481
		else -- 1481
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1483
		end -- 1483
	end -- 1483
	self.ticks = self.ticks + 1 -- 1487
	if self.invulnT > 0 then -- 1487
		self.invulnT = self.invulnT - 1 -- 1491
	end -- 1491
	if self.isCampaign then -- 1491
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1491
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1494
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1495
	end -- 1495
	local p = self.player -- 1497
	self:stepPlayer(p, dt, input) -- 1498
	self:refreshCover(p, input) -- 1500
	if self.carryOn then -- 1500
		self:carryPose() -- 1502
	end -- 1502
	if self.isCampaign then -- 1502
		self:stepCampaign(dt, input) -- 1505
		if not self.carryOn then -- 1505
			self:stepCampaignPartner(dt) -- 1507
		end -- 1507
	end -- 1507
	if trial == nil or not self.run.finished then -- 1507
		self:stepEnemies(dt, input) -- 1515
	end -- 1515
	if trial ~= nil then -- 1515
		trial.hp = self.hp -- 1517
	end -- 1517
	if not self.isCampaign then -- 1517
		self:stepStory(dt, input) -- 1519
		self:stepEscort(dt, input) -- 1520
		self:stepVillage(dt, input) -- 1521
		self:stepChase(dt, input) -- 1522
		self:stepInteract(dt, input) -- 1523
	end -- 1523
	self:updateGate() -- 1525
	self:updateCamera(dt) -- 1526
	self:syncStory() -- 1528
end -- 1436
function Play.prototype.underLowArch(self, a) -- 1535
	local arch = self.room.arch -- 1536
	if arch.h <= 0 then -- 1536
		return false -- 1538
	end -- 1538
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1538
		return false -- 1541
	end -- 1541
	local top = arch.y + arch.h -- 1543
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1544
end -- 1535
function Play.prototype.coverAt(self, a) -- 1551
	local best = nil -- 1552
	local bestGap = 24 -- 1553
	local half = a.w / 2 -- 1554
	local i = 0 -- 1555
	do -- 1555
		i = 0 -- 1556
		while i < #self.boxes do -- 1556
			do -- 1556
				local b = self.boxes[i + 1] -- 1557
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1557
					goto __continue178 -- 1559
				end -- 1559
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1559
					goto __continue178 -- 1562
				end -- 1562
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1564
				if gap < bestGap then -- 1564
					bestGap = gap -- 1566
					best = b -- 1567
				end -- 1567
			end -- 1567
			::__continue178:: -- 1567
			i = i + 1 -- 1556
		end -- 1556
	end -- 1556
	return best -- 1570
end -- 1551
function Play.prototype.nearCover(self, a) -- 1573
	return self:coverAt(a) ~= nil -- 1574
end -- 1573
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1578
	if enemy == nil then -- 1578
		return false -- 1580
	end -- 1580
	local fromRight = enemy.x >= a.x -- 1582
	local edge = fromRight and b.x0 or b.x1 -- 1583
	local ____fromRight_34 -- 1584
	if fromRight then -- 1584
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1584
	else -- 1584
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1585
	end -- 1585
	local between = ____fromRight_34 -- 1584
	local separation = enemy.x - a.x -- 1586
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1587
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1588
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1589
end -- 1578
function Play.prototype.nearestEnemy(self, a) -- 1592
	local best -- 1593
	local bestD = 1000000000 -- 1594
	local i = 0 -- 1595
	do -- 1595
		i = 0 -- 1596
		while i < #self.enemies do -- 1596
			do -- 1596
				local e = self.enemies[i + 1] -- 1597
				if not e.alive then -- 1597
					goto __continue187 -- 1599
				end -- 1599
				local d = math.abs(e.x - a.x) -- 1601
				if d < bestD then -- 1601
					bestD = d -- 1603
					best = e -- 1604
				end -- 1604
			end -- 1604
			::__continue187:: -- 1604
			i = i + 1 -- 1596
		end -- 1596
	end -- 1596
	return best -- 1607
end -- 1592
function Play.prototype.refreshCover(self, a, input) -- 1611
	if self.childMode then -- 1611
		self.coverNear = false -- 1613
		self.coverHug = false -- 1614
		self.coverEntity = "" -- 1615
		self.coverBlocking = false -- 1616
		a.covered = false -- 1617
		return -- 1618
	end -- 1618
	local b = self:coverAt(a) -- 1620
	self.coverNear = b ~= nil -- 1621
	a.covered = self.coverNear and input.cover.held -- 1622
	self.coverHug = a.covered -- 1623
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1624
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1625
		b, -- 1625
		a, -- 1625
		self:nearestEnemy(a) -- 1625
	) -- 1625
end -- 1611
function Play.prototype.cartHandleInReach(self, a) -- 1629
	if a == nil then -- 1629
		a = self.player -- 1629
	end -- 1629
	local c = self.room.cart -- 1630
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1630
		return false -- 1632
	end -- 1632
	local handleX = self.cartAxle + c.handleOffset -- 1634
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1635
end -- 1629
function Play.prototype.nearLowLedge(self, a) -- 1640
	local reach = 26 -- 1641
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1642
	local x1 = x0 + reach -- 1643
	local i = 0 -- 1644
	do -- 1644
		i = 0 -- 1645
		while i < #self.boxes do -- 1645
			do -- 1645
				local b = self.boxes[i + 1] -- 1646
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1646
					goto __continue196 -- 1648
				end -- 1648
				local rise = b.y1 - a.y -- 1650
				if rise > 0 and rise <= LEDGE_RISE then -- 1650
					return true -- 1652
				end -- 1652
			end -- 1652
			::__continue196:: -- 1652
			i = i + 1 -- 1645
		end -- 1645
	end -- 1645
	return false -- 1655
end -- 1640
function Play.prototype.stepPlayer(self, a, dt, input) -- 1658
	a.depthSpeed = 0 -- 1659
	if not a.alive then -- 1659
		return -- 1661
	end -- 1661
	local isChild = self.childMode -- 1663
	local lowArch = isChild and self:underLowArch(a) -- 1665
	if self:storyLocked() then -- 1665
		a.vx = 0 -- 1668
		a.crouch = isChild and lowArch -- 1669
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1670
		self:fallY(a, dt) -- 1671
		return -- 1672
	end -- 1672
	if not isChild and self.escort.state == "calming" then -- 1672
		a.crouch = false -- 1676
		a.h = SOLDIER_H -- 1677
		a.vx = 0 -- 1678
		self:fallY(a, dt) -- 1679
		return -- 1680
	end -- 1680
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1682
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1683
	local nearCover = not isChild and self:nearCover(a) -- 1684
	a.covered = nearCover and input.cover.held -- 1685
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1687
	if a.rollT > 0 then -- 1687
		a.rollT = a.rollT - dt -- 1691
		a.vx = a.facing * ROLL_SPEED -- 1692
		self:slideX(a, a.vx * dt) -- 1693
		self:fallY(a, dt) -- 1694
		if a.rollT <= 0 then -- 1694
			self:flashSet("翻滚结束", 0.5) -- 1696
		end -- 1696
		return -- 1698
	end -- 1698
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1698
		if input.moveX ~= 0 then -- 1698
			a.facing = input.moveX > 0 and 1 or -1 -- 1703
		end -- 1703
		if self:nearLowLedge(a) then -- 1703
			a.vy = SOLDIER_JUMP -- 1707
			a.onGround = false -- 1708
			self:flashSet("翻上去", 0.3) -- 1709
			return -- 1710
		end -- 1710
		a.rollT = ROLL_TIME -- 1712
		self:flashSet("翻滚", 0.3) -- 1713
		return -- 1714
	end -- 1714
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1717
	if isChild then -- 1717
		if input.cover.held then -- 1717
			speed = CHILD_SLOW -- 1720
		end -- 1720
		if a.crouch then -- 1720
			speed = CHILD_SLOW -- 1723
		end -- 1723
	elseif a.covered then -- 1723
		speed = SOLDIER_SPEED * 0.45 -- 1726
	end -- 1726
	local handsBusy = self.gripping or gripIntent -- 1730
	local dir = self.gripping and 0 or input.moveX -- 1731
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 1733
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1735
	if dir ~= 0 then -- 1735
		a.facing = dir > 0 and 1 or -1 -- 1737
	end -- 1737
	a.vx = dir * speed * diagonal -- 1739
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1739
		a.vy = CHILD_JUMP -- 1743
		a.onGround = false -- 1744
		self:flashSet("跳", 0.25) -- 1745
	end -- 1745
	local previousDepth = a.depth -- 1749
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1750
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1751
	self:slideX(a, a.vx * dt) -- 1752
	self:fallY(a, dt) -- 1753
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1753
		self:shoot(a) -- 1757
	end -- 1757
end -- 1658
function Play.prototype.stepPartner(self, p, dt) -- 1762
	local a = self.partner -- 1763
	if not a.alive then -- 1763
		return -- 1765
	end -- 1765
	a.crouch = false -- 1767
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1768
	a.vx = 0 -- 1769
	a.depthSpeed = 0 -- 1770
	self:fallY(a, dt) -- 1771
end -- 1762
function Play.prototype.stepEscort(self, dt, input) -- 1778
	local a = self.partner -- 1779
	a.depthSpeed = 0 -- 1780
	if not a.alive then -- 1780
		return -- 1782
	end -- 1782
	if self.room.key == "gatepath" then -- 1782
		if self.carryOn then -- 1782
			return -- 1787
		end -- 1787
		local p = self.player -- 1790
		a.depth = p.depth -- 1791
		a.facing = p.facing -- 1792
		a.crouch = false -- 1793
		a.h = CHILD_H -- 1794
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1795
		a.y = p.y -- 1796
		a.vy = 0 -- 1797
		a.vx = p.vx -- 1798
		a.onGround = p.onGround -- 1799
		return -- 1800
	end -- 1800
	if not self:escortOn() then -- 1800
		a.vx = 0 -- 1803
		self:fallY(a, dt) -- 1804
		return -- 1805
	end -- 1805
	local p = self.player -- 1807
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1808
	local hadKnock1 = self.escort.knock1 -- 1809
	local hadKnock2 = self.escort.knock2 -- 1810
	self.calmConsumed = self.escort:update( -- 1811
		input, -- 1811
		p.x, -- 1811
		p.facing, -- 1811
		a.x, -- 1811
		dist -- 1811
	) -- 1811
	if not hadKnock1 and self.escort.knock1 then -- 1811
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1814
	end -- 1814
	if not hadKnock2 and self.escort.knock2 then -- 1814
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1817
	end -- 1817
	a.crouch = self.escort.crouchPose -- 1819
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1820
	if not self.escort.stopped then -- 1820
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1822
		local previousDepth = a.depth -- 1823
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1824
		local distance = math.max( -- 1825
			-travel, -- 1825
			math.min(travel, targetDepth - previousDepth) -- 1825
		) -- 1825
		self:slideDepth(a, distance) -- 1826
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1827
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1827
			a.vy = CHILD_JUMP -- 1829
			a.onGround = false -- 1830
		end -- 1830
	end -- 1830
	local dir = self.escort:moveDir(a.x) -- 1833
	a.vx = dir * CHILD_SPEED -- 1834
	if dir ~= 0 then -- 1834
		a.facing = dir -- 1836
		local before = a.x -- 1837
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1838
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1838
			a.vy = CHILD_JUMP -- 1841
			a.onGround = false -- 1842
		end -- 1842
	end -- 1842
	self:fallY(a, dt) -- 1845
end -- 1778
function Play.prototype.escortOn(self) -- 1849
	if self.room.key == "checkpoint" then -- 1849
		return true -- 1851
	end -- 1851
	if self.room.key == "gatepath" then -- 1851
		return true -- 1854
	end -- 1854
	if self.room.key == "prologue" then -- 1854
		return self.phase == "prologue-follow" -- 1857
	end -- 1857
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1857
		return true -- 1861
	end -- 1861
	return self.room.key == "street" -- 1863
end -- 1849
function Play.prototype.storyLocked(self) -- 1867
	if self.caughtT > 0 then -- 1867
		return true -- 1869
	end -- 1869
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 1869
		return true -- 1873
	end -- 1873
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1873
		return true -- 1876
	end -- 1876
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1876
		return true -- 1879
	end -- 1879
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 1879
		return true -- 1882
	end -- 1882
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1882
		return true -- 1885
	end -- 1885
	if self.craftBench.active then -- 1885
		return true -- 1889
	end -- 1889
	return false -- 1891
end -- 1867
function Play.prototype.swapToChild(self, x) -- 1895
	local tmp = self.player -- 1896
	self.player = self.partner -- 1897
	self.partner = tmp -- 1898
	self.childMode = true -- 1899
	self.player.alive = true -- 1900
	self.player.x = self.ox + x -- 1901
	self.player.y = 0 -- 1902
	self.player.depth = 0 -- 1903
	self.player.depthSpeed = 0 -- 1904
	self.player.vy = 0 -- 1905
	self.player.vx = 0 -- 1906
	self.player.onGround = true -- 1907
	self.player.crouch = false -- 1908
	self.player.h = CHILD_H -- 1909
	self.player.facing = 1 -- 1910
	self.partner.alive = true -- 1911
	self.cam.x = self.player.x -- 1912
end -- 1895
function Play.prototype.swapToSoldier(self, x, childX) -- 1916
	local tmp = self.player -- 1917
	self.player = self.partner -- 1918
	self.partner = tmp -- 1919
	self.childMode = false -- 1920
	self.player.alive = true -- 1921
	self.player.x = self.ox + x -- 1922
	self.player.y = 0 -- 1923
	self.player.depth = 0 -- 1924
	self.player.depthSpeed = 0 -- 1925
	self.player.vy = 0 -- 1926
	self.player.vx = 0 -- 1927
	self.player.onGround = true -- 1928
	self.player.crouch = false -- 1929
	self.player.h = SOLDIER_H -- 1930
	self.player.facing = 1 -- 1931
	self.partner.alive = true -- 1932
	self.partner.x = self.ox + childX -- 1933
	self.partner.y = 0 -- 1934
	self.partner.depth = 0 -- 1935
	self.partner.depthSpeed = 0 -- 1936
	self.partner.vx = 0 -- 1937
	self.partner.vy = 0 -- 1938
	self.partner.onGround = true -- 1939
	self.partner.crouch = true -- 1940
	self.partner.h = CHILD_CROUCH_H -- 1941
	self.cam.x = self.player.x -- 1942
end -- 1916
function Play.prototype.stepStory(self, dt, input) -- 1946
	if self.room.key == "prologue" then -- 1946
		self:stepPrologue(dt, input) -- 1948
	elseif self.room.key == "street" then -- 1948
		self:stepStreet(dt, input) -- 1950
	elseif self.room.key == "gate" then -- 1950
		self:stepGate(dt, input) -- 1952
	elseif self.room.key == "gatepath" then -- 1952
		self:stepGatePath() -- 1954
	elseif self.room.key == "tower" then -- 1954
		self:stepTower(dt, input) -- 1956
	elseif self.room.key == "museum" then -- 1956
		self:stepMuseum(dt, input) -- 1958
	end -- 1958
end -- 1946
function Play.prototype.canPersistProgress(self) -- 1964
	return not self.isCampaign and self.run.source == "official" -- 1965
end -- 1964
function Play.prototype.wellWindow(self) -- 1969
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1970
end -- 1969
function Play.prototype.nearWell(self) -- 1975
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1976
end -- 1975
function Play.prototype.pickWell(self) -- 1984
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1984
		return false -- 1986
	end -- 1986
	self.phase = "prologue-well" -- 1988
	self.phaseTick = 0 -- 1989
	self.wellOpen = false -- 1990
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1991
	self:log("旧井拾取") -- 1992
	return true -- 1993
end -- 1984
function Play.prototype.stepPrologue(self, dt, input) -- 1996
	local child = self.partner -- 1997
	if self.museumReturn then -- 1997
		self.museumReturn = false -- 2000
		self.phase = "prologue-wait" -- 2001
		self.phaseTick = 0 -- 2002
		self.player.x = self.ox + 260 -- 2003
		self.player.y = 0 -- 2004
		self.player.depth = 0 -- 2005
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2006
	end -- 2006
	if self.phase == "prologue-wake" then -- 2006
		self.introTick = self.introTick + 1 -- 2010
		if self.introTick == 60 then -- 2010
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2012
		end -- 2012
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2012
			self.phase = "prologue-shadow" -- 2015
			self.introTick = 0 -- 2016
			self:flashSet("门缝里两道影子", 1.2) -- 2017
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2018
		end -- 2018
		return -- 2020
	end -- 2020
	if self.phase == "prologue-shadow" then -- 2020
		self.introTick = self.introTick + 1 -- 2023
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2023
			self.phase = "prologue-escape" -- 2026
			self.introTick = 0 -- 2027
			self.escapeRemaining = self.escapeDuration -- 2028
			self.escapeRetryCount = 0 -- 2029
			self:swapToChild(100) -- 2030
			self:flashSet( -- 2031
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2031
				1.6 -- 2031
			) -- 2031
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2032
		end -- 2032
		return -- 2036
	end -- 2036
	if self.phase == "prologue-escape" then -- 2036
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2039
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2039
			self.phase = "prologue-hide" -- 2042
			self.introTick = 0 -- 2043
			self.player.vx = 0 -- 2044
			self.player.crouch = true -- 2045
			self.player.h = CHILD_CROUCH_H -- 2046
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2047
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2048
			return -- 2052
		end -- 2052
		if self.escapeRemaining <= 0 then -- 2052
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2056
			self.player.x = self.ox + 100 -- 2057
			self.player.y = 0 -- 2058
			self.player.depth = 0 -- 2059
			self.player.vx = 0 -- 2060
			self.player.vy = 0 -- 2061
			self.escapeRemaining = self.escapeDuration -- 2062
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2063
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2064
			return -- 2065
		end -- 2065
		return -- 2067
	end -- 2067
	if self.phase == "prologue-hide" then -- 2067
		self.introTick = self.introTick + 1 -- 2070
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2070
			self.phase = "prologue-wait" -- 2073
			self.phaseTick = 0 -- 2074
			self.introTick = 0 -- 2075
			self:swapToSoldier(260, 300) -- 2076
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2077
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2078
		end -- 2078
		return -- 2080
	end -- 2080
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2083
	if self.phase == "prologue-wait" then -- 2083
		child.crouch = true -- 2085
		child.h = CHILD_CROUCH_H -- 2086
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2086
			self:pickWell() -- 2088
			return -- 2089
		end -- 2089
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2089
			if self:canPersistProgress() then -- 2089
				self.archive.museumPhase = "well_reflect" -- 2095
				self.archiveDirty = true -- 2096
			end -- 2096
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2098
			return -- 2099
		end -- 2099
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2101
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2103
		if near and input.interact.pressed then -- 2103
			self.phase = "prologue-give" -- 2105
			self.phaseTick = 0 -- 2106
			self:flashSet("递出针套", 1) -- 2107
		end -- 2107
		return -- 2109
	end -- 2109
	if self.phase == "prologue-well" then -- 2109
		self.phaseTick = self.phaseTick + 1 -- 2113
		if self.phaseTick == 12 then -- 2113
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2115
		elseif self.phaseTick >= 30 then -- 2115
			self.phase = "prologue-wait" -- 2117
			self.phaseTick = 0 -- 2118
			self.wellTaken = true -- 2119
			self.wellOpen = false -- 2120
			self.run.archive.artifactOwned = true -- 2121
			self.archiveDirty = true -- 2122
			self:emit("artifactFound", { -- 2123
				x = self.ox + self.wellX, -- 2124
				y = 0, -- 2124
				room = "prologue", -- 2124
				once = true, -- 2124
				source = self.run.source -- 2125
			}) -- 2125
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2127
			self:log("井底取到时间穿梭器") -- 2128
		end -- 2128
		return -- 2130
	end -- 2130
	if self.phase == "prologue-give" then -- 2130
		self.phaseTick = self.phaseTick + 1 -- 2133
		if self.phaseTick == 12 then -- 2133
			self:flashSet("针套递过去", 0.7) -- 2135
		elseif self.phaseTick == 36 then -- 2135
			self:flashSet("纸条塞进针套", 0.9) -- 2137
		elseif self.phaseTick >= 60 then -- 2137
			self.phase = "prologue-follow" -- 2139
			self.phaseTick = 0 -- 2140
			child.crouch = false -- 2141
			child.h = CHILD_H -- 2142
			self:flashSet("她跟上了", 1.2) -- 2143
		end -- 2143
		return -- 2145
	end -- 2145
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2145
		self:requestRoom("street", "序章跟到门口") -- 2149
		self:flashSet("进街道", 1.2) -- 2150
	end -- 2150
end -- 1996
function Play.prototype.stepStreet(self, dt, input) -- 2155
	local p = self.player -- 2156
	local c = self.partner -- 2157
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2157
		self:requestRoom("checkpoint", "两人都到街尾") -- 2159
		self:flashSet("到检查站", 1.2) -- 2160
	end -- 2160
end -- 2155
function Play.prototype.stepGate(self, dt, input) -- 2165
	local ____temp_35 -- 2166
	if self.room.story == nil then -- 2166
		____temp_35 = nil -- 2166
	else -- 2166
		____temp_35 = self.room.story.gate -- 2166
	end -- 2166
	local g = ____temp_35 -- 2166
	if g == nil then -- 2166
		return -- 2168
	end -- 2168
	local p = self.player -- 2170
	if self.phase == "gate-idle" then -- 2170
		local a = self.partner -- 2173
		local gap = g.waitX - a.x -- 2174
		if math.abs(gap) > 3 then -- 2174
			a.facing = gap > 0 and 1 or -1 -- 2176
			a.vx = a.facing * CHILD_SPEED -- 2177
			local beforeX = a.x -- 2178
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2179
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2179
				a.vy = CHILD_JUMP -- 2181
				a.onGround = false -- 2182
			end -- 2182
			self:fallY(a, dt) -- 2184
		else -- 2184
			a.vx = 0 -- 2186
			a.x = g.waitX -- 2187
		end -- 2187
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2190
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2191
		if self.gateNeedConfirm then -- 2191
			if not input.interact.held then -- 2191
				self.gateRestartArmed = true -- 2196
			end -- 2196
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2196
				self.gateNeedConfirm = false -- 2199
				self.gateRestartArmed = true -- 2200
				self.phase = "gate-hold" -- 2201
				self.gateTick = 0 -- 2202
				self.gateSpawned = 0 -- 2203
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2204
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2205
			end -- 2205
			return -- 2207
		end -- 2207
		if atWinch and atWait then -- 2207
			self.phase = "gate-hold" -- 2210
			self.gateTick = 0 -- 2211
			self.gateSpawned = 0 -- 2212
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2213
		end -- 2213
		return -- 2215
	end -- 2215
	if self.phase == "gate-hold" then -- 2215
		self.gateTick = self.gateTick + 1 -- 2218
		local marks = {0, 540, 900, 1500} -- 2220
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2220
			local idx = self.gateSpawned -- 2222
			local ____self_enemies_36 = self.enemies -- 2222
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 2223
				x = self.ox + 620 + idx * 62, -- 2224
				y = 0, -- 2224
				w = 26, -- 2224
				h = 84, -- 2224
				alive = true, -- 2225
				hitT = 0, -- 2225
				warnT = 0, -- 2225
				fireCd = 90 + idx * 45 -- 2225
			} -- 2225
			self.gateSpawned = self.gateSpawned + 1 -- 2227
			self:flashSet( -- 2228
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2228
				0.9 -- 2228
			) -- 2228
		end -- 2228
		if self.gateTick == 900 then -- 2228
			self:flashSet("灯灭了", 1) -- 2231
		elseif self.gateTick == 2100 then -- 2231
			self:flashSet("门底压下来了", 1) -- 2233
		end -- 2233
		if self.gateTick >= g.holdTicks then -- 2233
			self:captureGateBlood() -- 2238
			self.phase = "gate-send" -- 2239
			self.phaseTick = 0 -- 2240
			self.enemies = {} -- 2242
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2243
		end -- 2243
		return -- 2245
	end -- 2245
	if self.phase == "gate-send" then -- 2245
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2248
		if near and input.interact.pressed then -- 2248
			self:commitRoute() -- 2251
			self:swapToChild(g.doorX + 30) -- 2252
			self.phase = "gate-count" -- 2253
			self.countTick = 0 -- 2254
			self.countArmed = false -- 2256
			self.countPrevMove = input.moveX -- 2257
			self:flashSet("门开了 · 送她出去", 1.8) -- 2258
		end -- 2258
		return -- 2260
	end -- 2260
	if self.phase == "gate-count" then -- 2260
		self.countTick = self.countTick + 1 -- 2263
		if self.countTick == 360 then -- 2263
			self:flashSet("门关上", 0.9) -- 2265
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2265
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2267
			if self.storyRoute == "soldier" then -- 2267
				self.phase = "gate-wait" -- 2273
				self.phaseTick = 0 -- 2274
				self.knocks = 1 -- 2275
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2276
				self.handArmed = not input.interact.held -- 2278
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2279
			else -- 2279
				self:flashSet("数到二十", 2.2) -- 2281
			end -- 2281
		end -- 2281
		local prevMove = self.countPrevMove -- 2286
		self.countPrevMove = input.moveX -- 2287
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2287
			if prevMove <= 0 and input.moveX > 0 then -- 2287
				self.countArmed = true -- 2290
			end -- 2290
			if self.countArmed and input.moveX > 0 then -- 2290
				self.phase = "gate-walk" -- 2293
				self.phaseTick = 0 -- 2294
				self:flashSet("她迈出第一步", 1.4) -- 2295
				self:emit("storyExit", { -- 2296
					route = "child", -- 2296
					via = "walk", -- 2296
					countTick = self.countTick, -- 2296
					hp = self.hp, -- 2296
					maxHp = self.maxHp -- 2296
				}) -- 2296
			end -- 2296
		end -- 2296
		return -- 2299
	end -- 2299
	if self.phase == "gate-wait" then -- 2299
		self.phaseTick = self.phaseTick + 1 -- 2303
		if self.phaseTick == 12 then -- 2303
			self.knocks = 2 -- 2305
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2306
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2307
		end -- 2307
		if not input.interact.held then -- 2307
			if self.handTicks > 0 then -- 2307
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2311
			end -- 2311
			self.handTicks = 0 -- 2313
			self.handArmed = true -- 2314
			return -- 2315
		end -- 2315
		if self.handArmed then -- 2315
			self.handTicks = self.handTicks + 1 -- 2318
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2318
				self.phase = "gate-hand" -- 2320
				self.phaseTick = 0 -- 2321
				self.handDone = true -- 2322
				self.tied = true -- 2323
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2324
				if not self.lineSaid then -- 2324
					self.lineSaid = true -- 2326
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2327
				end -- 2327
				self:flashSet("我们走吧。", 3) -- 2329
			end -- 2329
		end -- 2329
		return -- 2332
	end -- 2332
	if self.phase == "gate-hand" then -- 2332
		self.phaseTick = self.phaseTick + 1 -- 2336
		if self.phaseTick == 30 then -- 2336
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2338
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2338
			self:emit("storyExit", { -- 2340
				route = "soldier", -- 2340
				via = "hand", -- 2340
				handTicks = self.handTicks, -- 2340
				hp = self.hp, -- 2340
				maxHp = self.maxHp -- 2340
			}) -- 2340
			self:requestRoom("gatepath", "牵手同行") -- 2341
		end -- 2341
		return -- 2343
	end -- 2343
	if self.phase == "gate-walk" then -- 2343
		if self.player.x >= g.exitX then -- 2343
			self:requestRoom("outside", "走出城门") -- 2348
			self:flashSet("出城门 · 城外", 1.4) -- 2349
		end -- 2349
	end -- 2349
end -- 2165
function Play.prototype.captureGateBlood(self) -- 2358
	self.hpAtGate = self.hp -- 2359
	self.maxHpAtGate = self.maxHp -- 2360
end -- 2358
function Play.prototype.commitRoute(self) -- 2367
	if self.storySettled then -- 2367
		return -- 2369
	end -- 2369
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2371
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2372
	self.hpAtGate = hp -- 2373
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2374
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2375
	self.storySettled = true -- 2376
	self:emit("storyRouteLocked", { -- 2377
		route = self.storyRoute, -- 2378
		hp = self.hp, -- 2378
		maxHp = self.maxHp, -- 2378
		hpAtGate = self.hpAtGate, -- 2379
		maxHpAtGate = self.maxHpAtGate -- 2379
	}) -- 2379
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2381
end -- 2367
function Play.prototype.syncStory(self) -- 2385
	if self.isCampaign and self.run.trial ~= nil then -- 2385
		return -- 2387
	end -- 2387
	local s = self.run.story -- 2389
	if s == nil then -- 2389
		return -- 2391
	end -- 2391
	s.hp = self.hp -- 2393
	s.maxHp = self.maxHp -- 2394
	s.route = self.storyRoute -- 2395
	s.settled = self.storySettled -- 2396
	s.hpAtGate = self.hpAtGate -- 2397
	s.maxHpAtGate = self.maxHpAtGate -- 2398
	s.handDone = self.handDone -- 2399
	s.lineSaid = self.lineSaid -- 2400
	s.tied = self.tied -- 2401
	s.carry = self.carryOn -- 2402
	s.museumReturn = self.museumReturn -- 2403
	s.escortDone = self.escortDone -- 2404
	s.craftedWeapon = self.run.story.craftedWeapon -- 2405
	s.ending = self.run.story.ending -- 2406
	if self.room.key == "gate" then -- 2406
		s.phase = self.phase -- 2408
		s.countTick = self.countTick -- 2409
		s.phaseTick = self.phaseTick -- 2410
		s.handTicks = self.handTicks -- 2411
	end -- 2411
	if self.room.key == "prologue" then -- 2411
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2411
			s.phase = self.phase -- 2416
			s.phaseTick = self.phaseTick -- 2417
		end -- 2417
	end -- 2417
	if self.room.key == "tower" then -- 2417
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2417
			s.phase = self.phase -- 2423
			s.phaseTick = self.phaseTick -- 2424
		end -- 2424
	end -- 2424
end -- 2385
function Play.prototype.stepGatePath(self) -- 2430
	local ____temp_37 -- 2431
	if self.room.story == nil then -- 2431
		____temp_37 = nil -- 2431
	else -- 2431
		____temp_37 = self.room.story.gatepath -- 2431
	end -- 2431
	local gp = ____temp_37 -- 2431
	if self.phase == "gatepath-start" then -- 2431
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2431
			self.carryOn = true -- 2434
			self.phase = "gatepath-carry" -- 2435
			self.phaseTick = 0 -- 2436
			self.pathDone = true -- 2437
			self.escortDone = false -- 2438
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2439
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2440
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2441
		end -- 2441
		return -- 2443
	end -- 2443
	if self.phase == "gatepath-carry" then -- 2443
		self.phaseTick = self.phaseTick + 1 -- 2446
		if self.phaseTick == 20 then -- 2446
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2448
		end -- 2448
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2448
			self:requestRoom(gp.next, "背负进首战") -- 2451
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2452
		end -- 2452
	end -- 2452
end -- 2430
function Play.prototype.carryPose(self) -- 2461
	local p = self.player -- 2462
	local a = self.partner -- 2463
	a.alive = true -- 2464
	a.x = p.x - p.facing * 12 -- 2465
	a.y = p.y + 26 -- 2466
	a.depth = p.depth -- 2467
	a.vx = p.vx -- 2468
	a.vy = 0 -- 2469
	a.onGround = true -- 2470
	a.crouch = false -- 2471
	a.h = CHILD_CROUCH_H -- 2472
	a.facing = p.facing -- 2473
end -- 2461
function Play.prototype.stepMuseum(self, dt, input) -- 2481
	self.partner.alive = false -- 2482
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2483
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2486
	if self.phase == "museum-cabinet" then -- 2486
		if atCase and input.interact.pressed then -- 2486
			self.phase = "museum-hall" -- 2489
			self.phaseTick = 0 -- 2490
			if self:canPersistProgress() then -- 2490
				self.archive.museumPhase = "hall_walk" -- 2492
				self.archiveDirty = true -- 2493
			end -- 2493
			self:emit( -- 2495
				"museumStep", -- 2495
				{ -- 2495
					step = "cabinet", -- 2495
					x = self.ox + mu.cabinetX, -- 2495
					persisted = self:canPersistProgress() -- 2495
				} -- 2495
			) -- 2495
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2496
		end -- 2496
		return -- 2498
	end -- 2498
	if self.phase == "museum-hall" then -- 2498
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2498
			self.phase = "museum-lamp" -- 2502
			self.phaseTick = 0 -- 2503
			if self:canPersistProgress() then -- 2503
				self.archive.museumPhase = "lamp_turn" -- 2505
				self.archiveDirty = true -- 2506
			end -- 2506
			self:emit( -- 2508
				"museumStep", -- 2508
				{ -- 2508
					step = "hall", -- 2508
					x = self.ox + mu.hallX, -- 2508
					persisted = self:canPersistProgress() -- 2508
				} -- 2508
			) -- 2508
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2509
		end -- 2509
		return -- 2511
	end -- 2511
	if self.phase == "museum-lamp" then -- 2511
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2511
			self.phase = "museum-return" -- 2515
			self.phaseTick = 0 -- 2516
			if self:canPersistProgress() then -- 2516
				self.archive.museumPhase = "return_cabinet" -- 2518
				self.archiveDirty = true -- 2519
			end -- 2519
			self:emit( -- 2521
				"museumStep", -- 2521
				{ -- 2521
					step = "lamp", -- 2521
					x = self.ox + mu.lampX, -- 2521
					persisted = self:canPersistProgress() -- 2521
				} -- 2521
			) -- 2521
			self:flashSet("灯 · 转向西窗", 1.8) -- 2522
		end -- 2522
		return -- 2524
	end -- 2524
	if self.phase == "museum-return" then -- 2524
		if atCase and input.interact.pressed then -- 2524
			self.phase = "museum-knock" -- 2528
			self.phaseTick = 0 -- 2529
			self:emit( -- 2530
				"museumStep", -- 2530
				{ -- 2530
					step = "knock", -- 2530
					count = 1, -- 2530
					x = self.ox + mu.cabinetX, -- 2530
					persisted = self:canPersistProgress() -- 2530
				} -- 2530
			) -- 2530
			self:flashSet("回柜边 · 第一下", 0.8) -- 2531
		end -- 2531
		return -- 2533
	end -- 2533
	if self.phase == "museum-knock" then -- 2533
		self.phaseTick = self.phaseTick + 1 -- 2536
		if self.phaseTick == 8 then -- 2536
			self:emit( -- 2538
				"museumStep", -- 2538
				{ -- 2538
					step = "knock", -- 2538
					count = 2, -- 2538
					x = self.ox + mu.cabinetX, -- 2538
					persisted = self:canPersistProgress() -- 2538
				} -- 2538
			) -- 2538
			self:flashSet("回柜边 · 第二下", 0.8) -- 2539
		elseif self.phaseTick >= 36 then -- 2539
			self.phase = "museum-done" -- 2541
			self.phaseTick = 0 -- 2542
			if self:canPersistProgress() then -- 2542
				self.archive.museumSeen = true -- 2544
				self.archive.museumPhase = "done" -- 2545
				self.archiveDirty = true -- 2546
			end -- 2546
			self:emit( -- 2548
				"museumDone", -- 2548
				{ -- 2548
					steps = 4, -- 2548
					museumSeen = self.archive.museumSeen, -- 2548
					persisted = self:canPersistProgress() -- 2548
				} -- 2548
			) -- 2548
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2549
			self:log("博物馆 · 回柜边") -- 2550
		end -- 2550
		return -- 2552
	end -- 2552
	if input.interact.pressed then -- 2552
		self.museumReturn = true -- 2555
		self:requestRoom("prologue", "回柜边") -- 2556
	end -- 2556
end -- 2481
function Play.prototype.openTowerDoor(self) -- 2560
	self.towerDoorOpen = true -- 2561
	do -- 2561
		local i = 0 -- 2562
		while i < #self.boxes do -- 2562
			if self.boxes[i + 1].id == "tower_door" then -- 2562
				self.boxes[i + 1].hidden = true -- 2564
			end -- 2564
			i = i + 1 -- 2562
		end -- 2562
	end -- 2562
	self.run.story.segments.tower_door = true -- 2567
end -- 2560
function Play.prototype.stepTower(self, dt, input) -- 2570
	local ____temp_38 -- 2571
	if self.room.story == nil then -- 2571
		____temp_38 = nil -- 2571
	else -- 2571
		____temp_38 = self.room.story.tower -- 2571
	end -- 2571
	local t = ____temp_38 -- 2571
	if t == nil then -- 2571
		return -- 2573
	end -- 2573
	if self.phase == "tower-wait" then -- 2573
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2576
		if near and input.interact.pressed then -- 2576
			self.phase = "tower-knock" -- 2578
			self.phaseTick = 0 -- 2579
			self.knocks = 1 -- 2580
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2581
			self:flashSet("叩两下 · 第一声", 0.6) -- 2582
		end -- 2582
		return -- 2584
	end -- 2584
	if self.phase == "tower-knock" then -- 2584
		self.phaseTick = self.phaseTick + 1 -- 2587
		if self.phaseTick == 12 then -- 2587
			self.knocks = 2 -- 2589
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2590
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2591
		elseif self.phaseTick >= t.knockTicks then -- 2591
			self:openTowerDoor() -- 2593
			self.phase = "tower-enter" -- 2594
			self.phaseTick = 0 -- 2595
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2596
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2597
		end -- 2597
		return -- 2599
	end -- 2599
	if self.phase == "tower-enter" then -- 2599
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2599
			self.phase = "tower-desk" -- 2603
			self.phaseTick = 0 -- 2604
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2605
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2606
		end -- 2606
		return -- 2608
	end -- 2608
	if self.phase == "tower-desk" then -- 2608
		local deskX = self.ox + 605 -- 2611
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2612
		if not near or not input.interact.held then -- 2612
			self.deskHold = 0 -- 2614
			return -- 2615
		end -- 2615
		self.deskHold = self.deskHold + 1 -- 2617
		if self.deskHold == 12 then -- 2617
			self:flashSet("针套 · 放在桌上", 1) -- 2619
		elseif self.deskHold == 24 then -- 2619
			self:flashSet("指南针 · 压住纸条", 1) -- 2621
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2621
			self.towerHanded = true -- 2623
			self.deskHold = 0 -- 2624
			self.run.story.segments.tower_handover = true -- 2625
			self.phase = "tower-given" -- 2626
			self.phaseTick = 0 -- 2627
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2628
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 2633
		end -- 2633
		return -- 2635
	end -- 2635
	if self.phase == "tower-given" then -- 2635
		local soldier = self.storyRoute == "soldier" -- 2640
		self.phaseTick = self.phaseTick + 1 -- 2641
		if self.phaseTick == 60 then -- 2641
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2643
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2644
		elseif self.phaseTick == 120 then -- 2644
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2646
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2646
			self.phase = "tower-end" -- 2648
			self.phaseTick = 0 -- 2649
			if not self.run.finished then -- 2649
				self.run.finished = true -- 2651
				local ending = soldier and "reunion" or "lamp" -- 2652
				self.run.story.ending = ending -- 2653
				local ____soldier_39 -- 2656
				if soldier then -- 2656
					____soldier_39 = self.run.story.segments.escort5 == true -- 2657
				else -- 2657
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2658
				end -- 2658
				local played = ____soldier_39 -- 2656
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2659
				if official then -- 2659
					if soldier then -- 2659
						self.run.archive.soldierCleared = true -- 2663
					else -- 2663
						self.run.archive.childCleared = true -- 2665
					end -- 2665
					self.archiveDirty = true -- 2667
				end -- 2667
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2669
				self:emit("endingReached", { -- 2670
					route = soldier and "soldier" or "child", -- 2671
					ending = ending, -- 2672
					official = official, -- 2673
					source = self.run.source, -- 2674
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2675
					childCleared = self.run.archive.childCleared, -- 2676
					soldierCleared = self.run.archive.soldierCleared, -- 2677
					artifactOwned = self.run.archive.artifactOwned, -- 2678
					equipped = self.equippedWeapon -- 2679
				}) -- 2679
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2681
			end -- 2681
		end -- 2681
		return -- 2684
	end -- 2684
	self.phaseTick = self.phaseTick + 1 -- 2686
	if input.interact.pressed or input.retry.pressed then -- 2686
		self.restartStory = true -- 2689
		self:requestRoom("prologue", "片尾再玩") -- 2690
		self:flashSet("回到序章", 1.4) -- 2691
	end -- 2691
end -- 2570
function Play.prototype.stepChase(self, dt, input) -- 2696
	if self.caughtT > 0 then -- 2696
		self.caughtT = self.caughtT - dt -- 2698
		if self.caughtT <= 0 then -- 2698
			self:recoverFromCaught() -- 2700
		end -- 2700
		return -- 2702
	end -- 2702
	if self.room.key == "village" then -- 2702
		self:stepScavChase() -- 2705
	elseif self.room.key == "forest" then -- 2705
		self:stepForestRoute() -- 2707
		self:stepDog(dt) -- 2708
		if self.player.x >= self.ox + 1450 then -- 2708
			self:requestRoom("tower", "到林缘北塔") -- 2711
			self:flashSet("林缘 · 北塔", 1.4) -- 2712
		end -- 2712
	end -- 2712
end -- 2696
function Play.prototype.stepScavChase(self) -- 2718
	local s = self.room.scavenger -- 2719
	if s == nil then -- 2719
		return -- 2721
	end -- 2721
	local p = self.player -- 2723
	if self.passed and p.x > self.ox + 440 then -- 2723
		if self.scavChase then -- 2723
			self.scavChase = false -- 2727
			self.scavState = "back" -- 2728
			self.scavT = 0 -- 2729
		end -- 2729
		return -- 2731
	end -- 2731
	local dx = p.x - self.scavX -- 2733
	local dist = math.abs(dx) -- 2734
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2735
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2736
	if not self.scavChase then -- 2736
		if visible then -- 2736
			self.scavSee = self.scavSee + 1 -- 2739
			if self.scavSee >= 24 then -- 2739
				self.scavChase = true -- 2741
				self.scavState = "chase" -- 2742
				self.scavTargetX = p.x -- 2743
				self:flashSet("他看见你了", 1.2) -- 2744
			end -- 2744
		else -- 2744
			self.scavSee = 0 -- 2747
		end -- 2747
		return -- 2749
	end -- 2749
	local dir = p.x > self.scavX and 1 or -1 -- 2752
	self.scavX = self.scavX + dir * 96 / 60 -- 2753
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2753
		self:caught() -- 2755
		return -- 2756
	end -- 2756
	if hidden then -- 2756
		self.scavSee = 0 -- 2760
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2761
		self.scavT = self.scavT - 1 -- 2762
		if self.scavT <= 0 then -- 2762
			self.scavChase = false -- 2764
			self.scavState = "patrol" -- 2765
			self:flashSet("他失去了目标", 1) -- 2766
		end -- 2766
	end -- 2766
end -- 2718
function Play.prototype.stepDog(self, dt) -- 2772
	local ____temp_40 -- 2773
	if self.room.story == nil then -- 2773
		____temp_40 = nil -- 2773
	else -- 2773
		____temp_40 = self.room.story.dog -- 2773
	end -- 2773
	local dog = ____temp_40 -- 2773
	if dog == nil then -- 2773
		return -- 2775
	end -- 2775
	local p = self.player -- 2777
	local dist = math.abs(p.x - self.dogX) -- 2778
	if self.dogState == "patrol" then -- 2778
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2780
		if self.dogX < dog.x0 then -- 2780
			self.dogX = dog.x0 -- 2782
			self.dogDir = 1 -- 2783
		elseif self.dogX > dog.x1 then -- 2783
			self.dogX = dog.x1 -- 2785
			self.dogDir = -1 -- 2786
		end -- 2786
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2788
		if not p.crouch and moving and dist < dog.range then -- 2788
			self.dogState = "ear" -- 2790
			self.dogT = 18 -- 2791
			self.dogTargetX = p.x -- 2792
			self:flashSet("狗转耳朵", 0.8) -- 2793
		end -- 2793
		return -- 2795
	end -- 2795
	if self.dogState == "ear" then -- 2795
		self.dogT = self.dogT - 1 -- 2798
		if self.dogT <= 0 then -- 2798
			self.dogState = "chase" -- 2800
			self.dogTargetX = p.x -- 2801
			self:flashSet("狗追来了", 1.4) -- 2802
		end -- 2802
		return -- 2804
	end -- 2804
	if self.dogState == "chase" then -- 2804
		local dir = p.x > self.dogX and 1 or -1 -- 2807
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2808
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2808
			self:caught() -- 2810
			self.dogState = "sniff" -- 2811
			self.dogT = 60 -- 2812
		elseif dist > dog.range * 1.5 or p.crouch then -- 2812
			self.dogState = "sniff" -- 2814
			self.dogT = 60 -- 2815
			self:flashSet("狗停下了", 0.9) -- 2816
		end -- 2816
		return -- 2818
	end -- 2818
	if self.dogState == "sniff" then -- 2818
		self.dogT = self.dogT - 1 -- 2821
		if self.dogT <= 0 then -- 2821
			self.dogState = "back" -- 2823
		end -- 2823
		return -- 2825
	end -- 2825
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2828
	self.dogX = self.dogX + dir * dog.speed * dt -- 2829
	if math.abs(self.dogX - dog.x0) < 2 then -- 2829
		self.dogX = dog.x0 -- 2831
		self.dogState = "patrol" -- 2832
	end -- 2832
end -- 2772
function Play.prototype.stepForestRoute(self) -- 2837
	local p = self.player -- 2838
	local ox = self.ox -- 2839
	if self.forestPath == "" then -- 2839
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 2839
			self.forestPath = "burrow" -- 2842
			self.run.story.segments.forest_burrow = true -- 2843
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 2844
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 2845
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 2845
			self.forestPath = "ditch" -- 2847
			self.run.story.segments.forest_ditch = true -- 2848
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 2849
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 2850
		end -- 2850
	end -- 2850
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 2850
		self.waterSeen = true -- 2854
		self.run.story.segments.water_lantern = true -- 2855
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 2856
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 2857
	end -- 2857
end -- 2837
function Play.prototype.caught(self) -- 2861
	self.caughtT = 1 -- 2862
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2863
end -- 2861
function Play.prototype.recoverFromCaught(self) -- 2867
	local p = self.player -- 2868
	p.x = self.ox + 140 -- 2869
	p.y = 0 -- 2870
	p.vy = 0 -- 2871
	p.vx = 0 -- 2872
	p.onGround = true -- 2873
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2873
		self.scavX = self.room.scavenger.x0 -- 2875
		self.scavState = "patrol" -- 2876
		self.scavSee = 0 -- 2877
		self.scavChase = false -- 2878
		self.scavT = 0 -- 2879
	end -- 2879
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2879
		self.dogX = self.room.story.dog.x0 -- 2882
		self.dogState = "patrol" -- 2883
		self.dogT = 0 -- 2884
	end -- 2884
	self.cam.x = p.x -- 2886
	self.cam.y = p.y + CAM_LOOK_UP -- 2887
	self:flashSet("回到安全点", 1.2) -- 2888
end -- 2867
function Play.prototype.updateGate(self) -- 2892
	if self.room.key ~= "checkpoint" then -- 2892
		self.gateOpen = false -- 2894
		return -- 2895
	end -- 2895
	local function inZone(x) -- 2897
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2897
	end -- 2897
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2898
end -- 2892
function Play.prototype.addItem(self, kind) -- 2904
	local inv = self.run.inventory -- 2905
	if kind == "shield" then -- 2905
		if inv.shield >= TOOL_CAP then -- 2905
			return false -- 2908
		end -- 2908
		inv.shield = inv.shield + 1 -- 2910
		return true -- 2911
	end -- 2911
	if kind == "wedge" then -- 2911
		if inv.wedge >= CONSUMABLE_CAP then -- 2911
			return false -- 2915
		end -- 2915
		inv.wedge = inv.wedge + 1 -- 2917
		return true -- 2918
	end -- 2918
	if kind == "ammo" then -- 2918
		if inv.ammo >= CONSUMABLE_CAP then -- 2918
			return false -- 2922
		end -- 2922
		inv.ammo = inv.ammo + 1 -- 2924
		return true -- 2925
	end -- 2925
	if kind == "scrap" then -- 2925
		inv.scrap = inv.scrap + 1 -- 2929
		return true -- 2930
	end -- 2930
	if kind == "wood" then -- 2930
		inv.wood = inv.wood + 1 -- 2933
		return true -- 2934
	end -- 2934
	if kind == "bell" then -- 2934
		inv.bell = inv.bell + 1 -- 2937
		return true -- 2938
	end -- 2938
	if kind == "pass" then -- 2938
		inv.pass = inv.pass + 1 -- 2941
		return true -- 2942
	end -- 2942
	if kind == "quickbelt" then -- 2942
		inv.quickbelt = inv.quickbelt + 1 -- 2945
		return true -- 2946
	end -- 2946
	return false -- 2948
end -- 2904
function Play.prototype.findBox(self, id) -- 2951
	local i = 0 -- 2952
	do -- 2952
		i = 0 -- 2953
		while i < #self.boxes do -- 2953
			if self.boxes[i + 1].id == id then -- 2953
				return self.boxes[i + 1] -- 2955
			end -- 2955
			i = i + 1 -- 2953
		end -- 2953
	end -- 2953
	return nil -- 2958
end -- 2951
function Play.prototype.findWedgeTarget(self) -- 2962
	local best = nil -- 2963
	local bestD = 0 -- 2964
	local i = 0 -- 2965
	do -- 2965
		i = 0 -- 2966
		while i < #self.boxes do -- 2966
			do -- 2966
				local b = self.boxes[i + 1] -- 2967
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2967
					goto __continue442 -- 2969
				end -- 2969
				if not self:nearBox(b, 26) then -- 2969
					goto __continue442 -- 2972
				end -- 2972
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2974
				if best == nil or d < bestD then -- 2974
					best = b -- 2976
					bestD = d -- 2977
				end -- 2977
			end -- 2977
			::__continue442:: -- 2977
			i = i + 1 -- 2966
		end -- 2966
	end -- 2966
	return best -- 2980
end -- 2962
function Play.prototype.stepCraft(self, input) -- 2988
	local inv = self.run.inventory -- 2989
	local ____opt_41 = self.run.trial -- 2989
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2990
	if self.craftT > 0 then -- 2990
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2990
			self.craftT = 0 -- 2994
			self:flashSet("制作中断", 0.8) -- 2995
			return true -- 2996
		end -- 2996
		self.craftT = self.craftT + 1 -- 2998
		if self.craftT >= required then -- 2998
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2998
				inv.scrap = inv.scrap - 1 -- 3001
				inv.wedge = inv.wedge + 1 -- 3002
				self:flashSet("制得木楔", 1.2) -- 3003
				self:log("制木楔") -- 3004
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3005
			end -- 3005
			self.craftT = 0 -- 3007
		end -- 3007
		return true -- 3009
	end -- 3009
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3009
		self.craftT = 1 -- 3012
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3013
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3014
		return true -- 3015
	end -- 3015
	return false -- 3017
end -- 2988
function Play.prototype.nearBox(self, b, reach) -- 3020
	local p = self.player -- 3021
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3022
end -- 3020
function Play.prototype.findInteract(self) -- 3028
	local p = self.player -- 3029
	local best = nil -- 3030
	local bestD = 1000000000 -- 3031
	local i = 0 -- 3032
	do -- 3032
		i = 0 -- 3033
		while i < #self.boxes do -- 3033
			do -- 3033
				local b = self.boxes[i + 1] -- 3034
				if b.interact == nil or b.broken == true then -- 3034
					goto __continue455 -- 3036
				end -- 3036
				if not self:nearBox(b, b.interact.reach or 27) then -- 3036
					goto __continue455 -- 3039
				end -- 3039
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3041
				if d < bestD then -- 3041
					bestD = d -- 3043
					best = b -- 3044
				end -- 3044
			end -- 3044
			::__continue455:: -- 3044
			i = i + 1 -- 3033
		end -- 3033
	end -- 3033
	return best -- 3047
end -- 3028
function Play.prototype.stepCampaign(self, dt, input) -- 3051
	local wr = self.room -- 3052
	local p = self.player -- 3053
	if self.reloadT > 0 then -- 3053
		self.reloadT = self.reloadT - 1 -- 3055
	end -- 3055
	if self.bracedShield ~= nil then -- 3055
		self.bracedShield.x = p.x + p.facing * 26 -- 3059
		self.bracedShield.y = p.y -- 3060
		local shBox = __TS__ArrayFind( -- 3061
			self.boxes, -- 3061
			function(____, b) return b.id == "braced_shield" end -- 3061
		) -- 3061
		if shBox ~= nil then -- 3061
			shBox.x0 = self.bracedShield.x - 15 -- 3063
			shBox.x1 = self.bracedShield.x + 15 -- 3064
			shBox.y0 = self.bracedShield.y -- 3065
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3066
		end -- 3066
	end -- 3066
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3066
		self.run.route = "drygoods" -- 3072
		self.run.joined = false -- 3073
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3074
		self:log("转布行线") -- 3075
	end -- 3075
	if wr.key == "escort3" then -- 3075
		local benchX = wr.minX + 560 -- 3079
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3080
		if nearBench and input.interact.pressed then -- 3080
			self:openCraftBench() -- 3082
		end -- 3082
	end -- 3082
	local i = 0 -- 3086
	do -- 3086
		i = 0 -- 3087
		while i < #self.pickups do -- 3087
			do -- 3087
				local pk = self.pickups[i + 1] -- 3088
				if self.run.taken[pk.id] == true then -- 3088
					goto __continue468 -- 3090
				end -- 3090
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3092
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3093
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3093
					if not self:addItem(pk.kind) then -- 3093
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3097
						self:log("满包拒绝 " .. pk.kind) -- 3098
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3099
						goto __continue468 -- 3100
					end -- 3100
					self.run.taken[pk.id] = true -- 3102
					self:flashSet("拾取 " .. pk.label, 1) -- 3103
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3104
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3105
				end -- 3105
			end -- 3105
			::__continue468:: -- 3105
			i = i + 1 -- 3087
		end -- 3087
	end -- 3087
	if not self:stepCraft(input) and input.interact.pressed then -- 3087
		self:campaignInteract() -- 3109
	end -- 3109
	self:stepCampaignCart(dt, input) -- 3111
	self:stepCampaignGoal() -- 3112
	self:campaignCheckpoint() -- 3113
end -- 3051
function Play.prototype.campaignCheckpoint(self) -- 3117
	local i = 0 -- 3118
	do -- 3118
		i = 0 -- 3119
		while i < #self.room.marks do -- 3119
			do -- 3119
				local m = self.room.marks[i + 1] -- 3120
				if m.kind ~= 0 then -- 3120
					goto __continue475 -- 3122
				end -- 3122
				local dx = self.player.x - m.x -- 3124
				local dy = self.player.y - m.y -- 3125
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3125
					self.checkpoint = m.x -- 3127
					self:captureCheckpoint(m.x) -- 3128
					self:flashSet("检查点", 1) -- 3129
				end -- 3129
			end -- 3129
			::__continue475:: -- 3129
			i = i + 1 -- 3119
		end -- 3119
	end -- 3119
end -- 3117
function Play.prototype.campaignInteract(self) -- 3135
	local b = self:findInteract() -- 3136
	if b ~= nil then -- 3136
		self:useInteract(b) -- 3138
		return -- 3139
	end -- 3139
	local inv = self.run.inventory -- 3141
	if inv.wedge > 0 then -- 3141
		local w = self:findWedgeTarget() -- 3143
		if w ~= nil then -- 3143
			if w.breakable ~= nil then -- 3143
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 3143
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 3146
			end -- 3146
			inv.wedge = inv.wedge - 1 -- 3148
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3149
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3151
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3152
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3153
			return -- 3154
		end -- 3154
	end -- 3154
	if inv.ammo > 0 and self.reloadT > 0 then -- 3154
		self.reloadT = 0 -- 3159
		self:closeReloadPuzzle() -- 3160
		inv.ammo = inv.ammo - 1 -- 3161
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3162
		self:log("用备用弹包") -- 3163
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3164
		return -- 3165
	end -- 3165
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3165
		local p = self.player -- 3169
		self.bracedShield = { -- 3170
			x = p.x + p.facing * 26, -- 3170
			y = p.y, -- 3170
			w = 30, -- 3170
			h = 64, -- 3170
			hp = 1 -- 3170
		} -- 3170
		local ____self_boxes_45 = self.boxes -- 3170
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 3171
			x0 = self.bracedShield.x - 15, -- 3172
			x1 = self.bracedShield.x + 15, -- 3172
			y0 = p.y, -- 3173
			y1 = p.y + 64, -- 3173
			depth = {min = -46, max = 46}, -- 3173
			label = "架起的残盾", -- 3173
			id = "braced_shield", -- 3173
			soft = true -- 3174
		} -- 3174
		inv.shield = inv.shield - 1 -- 3177
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3178
		self:log("架残盾") -- 3179
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3180
		return -- 3181
	end -- 3181
	if inv.pass > 0 and self.run.joined == false then -- 3181
		inv.pass = inv.pass - 1 -- 3184
		self.run.joined = true -- 3185
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3186
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3187
		return -- 3188
	end -- 3188
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3190
end -- 3135
function Play.prototype.useInteract(self, b) -- 3193
	local kind = b.interact == nil and "" or b.interact.kind -- 3194
	local wr = self.room -- 3195
	if kind == "open_board" then -- 3195
		b.broken = true -- 3197
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3198
		for ____, cover in ipairs(self.boxes) do -- 3199
			if cover.id == "s2_board_cover" then -- 3199
				cover.broken = false -- 3201
				cover.hidden = false -- 3202
			end -- 3202
		end -- 3202
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3205
		self.run.joined = true -- 3206
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3207
		self:log("放下窗板") -- 3208
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3209
		return -- 3210
	end -- 3210
	if kind == "lower_curtain" then -- 3210
		for ____, curtain in ipairs(self.boxes) do -- 3213
			if curtain.id == "c2_curtain" then -- 3213
				curtain.broken = false -- 3215
				curtain.hidden = false -- 3216
			end -- 3216
		end -- 3216
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3219
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3220
		self:log("放下木帘") -- 3221
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3222
		return -- 3223
	end -- 3223
	if kind == "raise_latch" then -- 3223
		if wr.key == "c2-granary" and not self.cartDocked then -- 3223
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3227
			return -- 3228
		end -- 3228
		b.broken = true -- 3230
		self.objectiveDone = true -- 3231
		if wr.key == "c1-yard" then -- 3231
			self.run.c1Latch = true -- 3234
			self.run.joined = true -- 3235
		else -- 3235
			self.run.c2Latch = true -- 3237
			self.run.joined = true -- 3238
		end -- 3238
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3240
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3241
		self:log("抬闩") -- 3242
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3243
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3244
	end -- 3244
end -- 3193
function Play.prototype.stepCampaignCart(self, dt, input) -- 3249
	local wr = self.room -- 3250
	local c = wr.cart -- 3251
	if c.bodyW <= 0 then -- 3251
		return -- 3253
	end -- 3253
	local p = self.player -- 3255
	local handleX = self.cartAxle + c.handleOffset -- 3256
	if not self.gripping then -- 3256
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 3256
			self.gripping = true -- 3260
			self:flashSet("握住车柄 · A/D 推", 1) -- 3261
		end -- 3261
		return -- 3263
	end -- 3263
	if input.interact.pressed then -- 3263
		self.gripping = false -- 3266
		self:flashSet("松手", 0.5) -- 3267
		return -- 3268
	end -- 3268
	if not self.cartDocked then -- 3268
		if input.moveX ~= 0 and not self:stuckCart() then -- 3268
			self.cartAxle = math.max( -- 3272
				c.startX, -- 3272
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3272
			) -- 3272
		end -- 3272
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3272
			self.cartExposed = true -- 3277
			local gun = nil -- 3278
			local gi = 0 -- 3279
			do -- 3279
				gi = 0 -- 3280
				while gi < #self.enemies do -- 3280
					local e = self.enemies[gi + 1] -- 3281
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3281
						gun = e -- 3283
						break -- 3284
					end -- 3284
					gi = gi + 1 -- 3280
				end -- 3280
			end -- 3280
			if gun ~= nil then -- 3280
				self:campaignEnemyFire(gun) -- 3288
			end -- 3288
		end -- 3288
		p.x = self.cartAxle + c.handleOffset -- 3291
		p.y = c.baseY + (c.depth or 0) -- 3292
		p.vx = 0 -- 3293
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3293
			self.cartAxle = c.endX -- 3295
			self.cartDocked = true -- 3296
			self.gripping = false -- 3297
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3298
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3299
			self:flashSet("车轮入窝", 1.2) -- 3300
			self:log("车轮入窝") -- 3301
		end -- 3301
	end -- 3301
end -- 3249
function Play.prototype.stuckCart(self) -- 3307
	local i = 0 -- 3308
	do -- 3308
		i = 0 -- 3309
		while i < #self.boxes do -- 3309
			do -- 3309
				local b = self.boxes[i + 1] -- 3310
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3310
					goto __continue514 -- 3312
				end -- 3312
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 3314
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3314
					return true -- 3316
				end -- 3316
			end -- 3316
			::__continue514:: -- 3316
			i = i + 1 -- 3309
		end -- 3309
	end -- 3309
	return false -- 3319
end -- 3307
function Play.prototype.stepCampaignGoal(self) -- 3323
	local wr = self.room -- 3324
	local c = wr.campaign -- 3325
	if c == nil then -- 3325
		return -- 3327
	end -- 3327
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3327
		self.objectiveDone = true -- 3330
	end -- 3330
	if c.goal == "reach_exit" then -- 3330
		self.objectiveDone = true -- 3333
	end -- 3333
	if not self.objectiveDone then -- 3333
		return -- 3336
	end -- 3336
	local p = self.player -- 3338
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3339
	if p.x < c.exitX or not partnerOk then -- 3339
		return -- 3341
	end -- 3341
	if self.run.story.segments[wr.key] ~= true then -- 3341
		self.run.story.segments[wr.key] = true -- 3345
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3346
	end -- 3346
	if wr.key == "escort5" then -- 3346
		self.escortDone = true -- 3350
		self.run.story.escortDone = true -- 3351
	end -- 3351
	if c.next ~= nil and c.next ~= "" then -- 3351
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3354
		self:flashSet("过关 · " .. c.next, 1.2) -- 3355
	elseif not self.run.finished then -- 3355
		self.run.finished = true -- 3357
		self:flashSet( -- 3358
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3358
			2 -- 3358
		) -- 3358
		self:log("C2 灰盒完成") -- 3359
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3360
	end -- 3360
end -- 3323
function Play.prototype.stepCampaignPartner(self, dt) -- 3365
	local a = self.partner -- 3366
	local wr = self.room -- 3367
	local cp = wr.companion -- 3368
	if not a.alive then -- 3368
		return -- 3370
	end -- 3370
	local p = self.player -- 3372
	if self.craftBench.active then -- 3372
		a.vx = 0 -- 3375
		return -- 3376
	end -- 3376
	local wait = false -- 3378
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3379
	local targetDepth = p.depth -- 3380
	if self.run.joined == false then -- 3380
		wait = true -- 3382
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3383
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3384
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3384
		wait = true -- 3386
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3387
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3388
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3388
		wait = true -- 3390
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3391
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3392
	end -- 3392
	if self.partnerStuck > 0.3 then -- 3392
		a.x = a.x + a.facing * 44 -- 3396
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3397
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3398
		self.partnerLaneHold = 1.1 -- 3399
		self.partnerStuck = 0 -- 3400
	end -- 3400
	if self.partnerLaneHold > 0 then -- 3400
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3403
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3404
	end -- 3404
	local dx = targetX - a.x -- 3406
	if not wait and math.abs(dx) > 74 then -- 3406
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3408
		local before = a.x -- 3409
		a.vx = dx > 0 and speed or -speed -- 3410
		a.facing = dx > 0 and 1 or -1 -- 3411
		self:slideX(a, a.vx * dt) -- 3412
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3412
			a.vy = CHILD_JUMP -- 3415
			a.onGround = false -- 3416
		end -- 3416
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3418
	else -- 3418
		a.vx = 0 -- 3420
		self.partnerStuck = 0 -- 3421
	end -- 3421
	local dz = targetDepth - a.depth -- 3423
	if math.abs(dz) > 6 then -- 3423
		local step = math.max( -- 3425
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3425
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3425
		) -- 3425
		a.depth = a.depth + step -- 3426
	end -- 3426
	a.depthSpeed = 0 -- 3428
	a.h = CHILD_H -- 3429
	a.crouch = false -- 3430
	self:fallY(a, dt) -- 3431
end -- 3365
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3435
	local p = self.player -- 3436
	local i = 0 -- 3437
	do -- 3437
		i = 0 -- 3438
		while i < #self.enemies do -- 3438
			do -- 3438
				local ____opt_46 = self.run.trial -- 3438
				if ____opt_46 and ____opt_46.lost then -- 3438
					return -- 3439
				end -- 3439
				local e = self.enemies[i + 1] -- 3440
				if not e.alive then -- 3440
					goto __continue541 -- 3442
				end -- 3442
				if e.hitT > 0 then -- 3442
					e.hitT = e.hitT - dt -- 3445
				end -- 3445
				if e.kind == "target" then -- 3445
					if not e.alive and e.hitT <= 0 then -- 3445
						e.alive = true -- 3450
					end -- 3450
					goto __continue541 -- 3452
				end -- 3452
				if e.kind == "breaker" then -- 3452
					self:stepBreaker(e, dt) -- 3455
					goto __continue541 -- 3456
				end -- 3456
				if e.kind == "shield" then -- 3456
					self:stepShield(e, dt, input) -- 3459
					goto __continue541 -- 3460
				end -- 3460
				local dx = e.x - p.x -- 3463
				if not e.awake then -- 3463
					if math.abs(dx) > 520 then -- 3463
						goto __continue541 -- 3466
					end -- 3466
					e.awake = true -- 3468
					e.fireCd = 48 -- 3469
					goto __continue541 -- 3470
				end -- 3470
				if math.abs(dx) > ENEMY_RANGE then -- 3470
					goto __continue541 -- 3473
				end -- 3473
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3473
					goto __continue541 -- 3478
				end -- 3478
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3478
					goto __continue541 -- 3481
				end -- 3481
				if self:blockedShot(e, p) then -- 3481
					if e.warnT > 0 then -- 3481
						e.warnT = 0 -- 3487
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3488
					end -- 3488
					goto __continue541 -- 3490
				end -- 3490
				if e.warnT > 0 then -- 3490
					e.warnT = e.warnT - 1 -- 3493
					if e.warnT <= 0 then -- 3493
						self:campaignEnemyFire(e) -- 3495
					end -- 3495
				elseif e.fireCd > 0 then -- 3495
					e.fireCd = e.fireCd - 1 -- 3498
					if e.fireCd <= 0 then -- 3498
						e.warnT = WARN_TICKS -- 3500
					end -- 3500
				else -- 3500
					e.fireCd = 40 -- 3503
				end -- 3503
			end -- 3503
			::__continue541:: -- 3503
			i = i + 1 -- 3438
		end -- 3438
	end -- 3438
end -- 3435
function Play.prototype.blockedShot(self, e, p) -- 3509
	local eDepth = e.depth or 0 -- 3510
	local ex = e.x -- 3511
	local ey = e.y + e.h * 0.62 -- 3513
	local px = p.x -- 3514
	local py = p.y + p.h * 0.55 -- 3515
	local dx = px - ex -- 3516
	local dyScreen = py + p.depth - (ey + eDepth) -- 3517
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3518
	if len < 0.01 then -- 3518
		return false -- 3520
	end -- 3520
	local ray = { -- 3524
		x = ex, -- 3525
		y = ey, -- 3525
		dx = dx / len, -- 3526
		dy = (py - ey) / len, -- 3526
		depth = eDepth, -- 3527
		dDepth = (p.depth - eDepth) / len -- 3527
	} -- 3527
	local best = -1 -- 3529
	local j = 0 -- 3530
	do -- 3530
		j = 0 -- 3531
		while j < #self.boxes do -- 3531
			do -- 3531
				local b = self.boxes[j + 1] -- 3532
				if b.broken == true or b.passable == true or b.hidden == true then -- 3532
					goto __continue564 -- 3534
				end -- 3534
				if b.id == "braced_shield" then -- 3534
					goto __continue564 -- 3539
				end -- 3539
				local t = hitBox(ray, b) -- 3541
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3541
					best = t -- 3545
				end -- 3545
			end -- 3545
			::__continue564:: -- 3545
			j = j + 1 -- 3531
		end -- 3531
	end -- 3531
	return best >= 0 -- 3548
end -- 3509
function Play.prototype.campaignEnemyFire(self, e) -- 3551
	local p = self.player -- 3552
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3553
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3553
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3553
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3555
		self.boxes = __TS__ArrayFilter( -- 3556
			self.boxes, -- 3556
			function(____, b) return b.id ~= "braced_shield" end -- 3556
		) -- 3556
		self.bracedShield = nil -- 3557
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3558
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3559
		return -- 3560
	end -- 3560
	if self:blockedShot(e, p) then -- 3560
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3563
		return -- 3564
	end -- 3564
	local cover = self:blockedByCover(e, p) -- 3566
	if cover ~= nil and self.coverHug then -- 3566
		self.coveredFlash = 0.5 -- 3568
		self:flashSet("掩体挡下", 0.6) -- 3569
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3570
		return -- 3575
	end -- 3575
	if self.invulnT > 0 then -- 3575
		return -- 3578
	end -- 3578
	local ____opt_50 = self.run.trial -- 3578
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3580
	self.craftT = 0 -- 3581
	self.hp = self.hp - 1 -- 3582
	self:emit("actorHit", { -- 3583
		target = "player", -- 3583
		amount = 1, -- 3583
		hp = self.hp, -- 3583
		maxHp = self.maxHp, -- 3583
		enemyX = e.x -- 3583
	}) -- 3583
	self:flashSet( -- 3584
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3584
		0.8 -- 3584
	) -- 3584
	if self.hp <= 0 then -- 3584
		self:campaignFailed() -- 3586
	end -- 3586
end -- 3551
function Play.prototype.stepShield(self, e, dt, input) -- 3591
	local p = self.player -- 3592
	local dx = p.x - e.x -- 3593
	local adx = math.abs(dx) -- 3594
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3597
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3598
	if adx > 150 then -- 3598
		local before = e.x -- 3600
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3601
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3601
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3604
		end -- 3604
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3604
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3609
		local rollDodges = p.rollT > 0 and fromFront -- 3610
		if not rollDodges and self.invulnT <= 0 then -- 3610
			local ____opt_52 = self.run.trial -- 3610
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3612
			self.craftT = 0 -- 3613
			self.hp = self.hp - 1 -- 3614
			self:emit("actorHit", { -- 3615
				target = "player", -- 3615
				amount = 1, -- 3615
				hp = self.hp, -- 3615
				maxHp = self.maxHp, -- 3615
				enemyX = e.x -- 3615
			}) -- 3615
			self:flashSet( -- 3616
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3616
				0.8 -- 3616
			) -- 3616
			if self.hp <= 0 then -- 3616
				self:campaignFailed() -- 3618
				return -- 3619
			end -- 3619
		end -- 3619
		e.swingT = 70 -- 3622
	end -- 3622
	if (e.swingT or 0) > 0 then -- 3622
		e.swingT = (e.swingT or 0) - 1 -- 3625
	end -- 3625
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3625
		local dd = p.depth - (e.depth or 0) -- 3628
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3629
	end -- 3629
end -- 3591
function Play.prototype.stepBreaker(self, e, dt) -- 3634
	local p = self.player -- 3635
	if e.awake ~= true then -- 3635
		if math.abs(p.x - e.x) < 560 then -- 3635
			e.awake = true -- 3638
		else -- 3638
			return -- 3640
		end -- 3640
	end -- 3640
	local target = nil -- 3643
	local bestD = 1000000000 -- 3644
	local i = 0 -- 3645
	do -- 3645
		i = 0 -- 3646
		while i < #self.boxes do -- 3646
			do -- 3646
				local b = self.boxes[i + 1] -- 3647
				if b.breakable == nil or b.broken == true then -- 3647
					goto __continue588 -- 3649
				end -- 3649
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3651
				if d < bestD then -- 3651
					bestD = d -- 3653
					target = b -- 3654
				end -- 3654
			end -- 3654
			::__continue588:: -- 3654
			i = i + 1 -- 3646
		end -- 3646
	end -- 3646
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3657
	local dx = tx - e.x -- 3658
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3659
	if math.abs(dx) > reach then -- 3659
		local before = e.x -- 3661
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3662
		if math.abs(e.x - before) < 0.3 then -- 3662
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3664
		end -- 3664
	elseif (e.swingT or 0) <= 0 then -- 3664
		e.swingT = 64 -- 3667
		if target ~= nil then -- 3667
			self:damageProp(target, 2) -- 3669
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3669
			local ____opt_54 = self.run.trial -- 3669
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3671
			self.craftT = 0 -- 3672
			self.hp = self.hp - 1 -- 3673
			self:emit("actorHit", { -- 3674
				target = "player", -- 3674
				amount = 1, -- 3674
				hp = self.hp, -- 3674
				maxHp = self.maxHp, -- 3674
				enemyX = e.x -- 3674
			}) -- 3674
			self:flashSet("破障手近身", 0.8) -- 3675
			if self.hp <= 0 then -- 3675
				self:campaignFailed() -- 3677
				return -- 3678
			end -- 3678
		end -- 3678
	end -- 3678
	if (e.swingT or 0) > 0 then -- 3678
		e.swingT = (e.swingT or 0) - 1 -- 3683
	end -- 3683
end -- 3634
function Play.prototype.campaignFailed(self) -- 3687
	if self.run.trial ~= nil then -- 3687
		self.run.trial.lost = true -- 3689
		self.wantRoom = "" -- 3690
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3691
		return -- 3692
	end -- 3692
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3692
		self:restartEscortFromDeath() -- 3697
		return -- 3698
	end -- 3698
	local p = self.player -- 3700
	self.hp = self.maxHp -- 3701
	self.invulnT = INVULN_RESPAWN_TICKS -- 3702
	self.reloadT = 0 -- 3703
	self:closeReloadPuzzle() -- 3704
	self.gripping = false -- 3705
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3706
	self:log("被击倒") -- 3707
	p.x = self.room.minX + 90 -- 3708
	p.y = 0 -- 3709
	p.depth = 0 -- 3710
	p.vx = 0 -- 3711
	p.vy = 0 -- 3712
	p.onGround = true -- 3713
	p.rollT = 0 -- 3714
	self.partner.x = p.x - 50 -- 3715
	self.partner.y = 0 -- 3716
	self.partner.depth = 0 -- 3717
	self.cam.x = p.x -- 3718
	local i = 0 -- 3719
	do -- 3719
		i = 0 -- 3720
		while i < #self.enemies do -- 3720
			do -- 3720
				local e = self.enemies[i + 1] -- 3721
				if not e.alive then -- 3721
					goto __continue602 -- 3723
				end -- 3723
				e.x = e.homeX == nil and e.x or e.homeX -- 3725
				e.warnT = 0 -- 3726
				e.fireCd = 40 -- 3727
				e.swingT = 0 -- 3728
				e.awake = false -- 3729
			end -- 3729
			::__continue602:: -- 3729
			i = i + 1 -- 3720
		end -- 3720
	end -- 3720
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3731
end -- 3687
function Play.prototype.isEscortRoom(self) -- 3735
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3736
end -- 3735
function Play.prototype.restartEscortFromDeath(self) -- 3744
	local story = self.run.story -- 3745
	local inv = self.run.inventory -- 3746
	self.hp = self.maxHp -- 3747
	story.hp = self.maxHp -- 3748
	story.cp = nil -- 3749
	self.checkpointSnap = nil -- 3750
	story.carry = false -- 3751
	self.carryOn = false -- 3752
	story.craftedWeapon = "" -- 3753
	self.equippedWeapon = "standard_gun" -- 3754
	story.escortDone = false -- 3755
	self.escortDone = false -- 3756
	story.segments = {} -- 3757
	inv.wood = 0 -- 3758
	inv.bell = 0 -- 3759
	inv.scrap = 0 -- 3760
	inv.wedge = 0 -- 3761
	inv.ammo = 0 -- 3762
	inv.quickbelt = 0 -- 3763
	inv.shield = 0 -- 3764
	inv.pass = 0 -- 3765
	local taken = self.run.taken -- 3766
	local keys = __TS__ObjectKeys(taken) -- 3767
	local i = 0 -- 3768
	do -- 3768
		i = 0 -- 3769
		while i < #keys do -- 3769
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3769
				__TS__Delete(taken, keys[i + 1]) -- 3771
			end -- 3771
			i = i + 1 -- 3769
		end -- 3769
	end -- 3769
	self.run.joined = true -- 3774
	self.reloadT = 0 -- 3775
	self:closeReloadPuzzle() -- 3776
	self.gripping = false -- 3777
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3778
	self:log("男主线失败 · 回 escort1") -- 3779
	self:emit("campaignFailed", { -- 3780
		room = self.room.key, -- 3781
		hp = 0, -- 3781
		maxHp = self.maxHp, -- 3781
		reset = true, -- 3782
		to = "escort1", -- 3782
		route = self.storyRoute -- 3782
	}) -- 3782
	self:requestRoom("escort1", "男主线失败重开") -- 3784
end -- 3744
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3788
	local i = 0 -- 3789
	do -- 3789
		i = 0 -- 3790
		while i < #self.enemies do -- 3790
			do -- 3790
				if i == skipIndex then -- 3790
					goto __continue611 -- 3792
				end -- 3792
				local e = self.enemies[i + 1] -- 3794
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3794
					goto __continue611 -- 3796
				end -- 3796
				e.fireCd = 150 -- 3798
				e.warnT = 0 -- 3799
			end -- 3799
			::__continue611:: -- 3799
			i = i + 1 -- 3790
		end -- 3790
	end -- 3790
end -- 3788
function Play.prototype.stepEnemies(self, dt, input) -- 3803
	local i = 0 -- 3804
	do -- 3804
		i = 0 -- 3805
		while i < #self.enemies do -- 3805
			local e = self.enemies[i + 1] -- 3806
			if e.hitT > 0 then -- 3806
				e.hitT = e.hitT - dt -- 3808
			end -- 3808
			i = i + 1 -- 3805
		end -- 3805
	end -- 3805
	if self.coveredFlash > 0 then -- 3805
		self.coveredFlash = self.coveredFlash - dt -- 3812
	end -- 3812
	if self.isCampaign then -- 3812
		self:stepCampaignEnemies(dt, input) -- 3815
		return -- 3816
	end -- 3816
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3816
		return -- 3820
	end -- 3820
	do -- 3820
		i = 0 -- 3822
		while i < #self.enemies do -- 3822
			do -- 3822
				local e = self.enemies[i + 1] -- 3823
				if not e.alive then -- 3823
					goto __continue622 -- 3825
				end -- 3825
				if e.warnT > 0 then -- 3825
					e.warnT = e.warnT - 1 -- 3828
					if e.warnT <= 0 then -- 3828
						self:enemyFire(e, input) -- 3830
					end -- 3830
					goto __continue622 -- 3832
				end -- 3832
				if e.fireCd > 0 then -- 3832
					e.fireCd = e.fireCd - 1 -- 3835
					if e.fireCd <= 0 then -- 3835
						e.warnT = WARN_TICKS -- 3837
					end -- 3837
				else -- 3837
					e.warnT = WARN_TICKS -- 3841
				end -- 3841
			end -- 3841
			::__continue622:: -- 3841
			i = i + 1 -- 3822
		end -- 3822
	end -- 3822
end -- 3803
function Play.prototype.enemyFire(self, e, input) -- 3847
	local p = self.player -- 3848
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3848
		self:flashSet("枪声响在远处", 0.4) -- 3850
		e.fireCd = FIRE_COOLDOWN -- 3851
		return -- 3852
	end -- 3852
	local cover = self:blockedByCover(e, p) -- 3855
	local hugging = cover ~= nil -- 3856
	self.coverBlocking = hugging -- 3857
	local covered = hugging and input.cover.held -- 3858
	if covered then -- 3858
		self.coveredFlash = 0.5 -- 3860
		self:flashSet("掩体挡下", 0.5) -- 3861
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3862
		e.fireCd = FIRE_COOLDOWN -- 3867
		return -- 3868
	end -- 3868
	self.hp = self.hp - 1 -- 3870
	self:emit("actorHit", { -- 3871
		target = "player", -- 3871
		amount = 1, -- 3871
		hp = self.hp, -- 3871
		maxHp = self.maxHp, -- 3871
		enemyX = e.x -- 3871
	}) -- 3871
	self:flashSet( -- 3872
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3872
		0.7 -- 3872
	) -- 3872
	e.fireCd = FIRE_COOLDOWN -- 3873
	if self.hp <= 0 then -- 3873
		self:gateFailed() -- 3875
	end -- 3875
end -- 3847
function Play.prototype.blockedByCover(self, enemy, p) -- 3880
	local b = self:coverAt(p) -- 3881
	if b == nil then -- 3881
		return nil -- 3883
	end -- 3883
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3885
end -- 3880
function Play.prototype.gateFailed(self) -- 3889
	local ____temp_56 -- 3890
	if self.room.story == nil then -- 3890
		____temp_56 = nil -- 3890
	else -- 3890
		____temp_56 = self.room.story.gate -- 3890
	end -- 3890
	local g = ____temp_56 -- 3890
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3891
	self.hp = self.maxHp -- 3892
	self.gateTick = 0 -- 3893
	self.gateSpawned = 0 -- 3894
	self.enemies = {} -- 3895
	self.gateFailCount = self.gateFailCount + 1 -- 3896
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3898
	self.player.y = 0 -- 3899
	self.player.vy = 0 -- 3900
	self.player.depth = 0 -- 3901
	self.player.depthSpeed = 0 -- 3902
	self.player.onGround = true -- 3903
	self.player.crouch = false -- 3904
	self.player.h = SOLDIER_H -- 3905
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3906
	self.partner.y = 0 -- 3907
	self.partner.vy = 0 -- 3908
	self.partner.depth = 0 -- 3909
	self.partner.depthSpeed = 0 -- 3910
	self.partner.onGround = true -- 3911
	self.cam.x = self.player.x -- 3912
	self.phase = "gate-idle" -- 3913
	self.phaseTick = 0 -- 3914
	self.coverHug = false -- 3915
	self.coverBlocking = false -- 3916
	self.coverEntity = "" -- 3917
	self.gateNeedConfirm = true -- 3918
	self.gateRestartArmed = false -- 3919
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3920
end -- 3889
function Play.prototype.stepRedCart(self, input) -- 3924
	if self.room.key ~= "outside" or self.redCartPulled then -- 3924
		return -- 3926
	end -- 3926
	local box = __TS__ArrayFind( -- 3928
		self.boxes, -- 3928
		function(____, b) return b.id == "outside_red_cart" end -- 3928
	) -- 3928
	if box == nil then -- 3928
		self.redCartPulled = true -- 3930
		return -- 3931
	end -- 3931
	local cx = (box.x0 + box.x1) * 0.5 -- 3933
	local p = self.player -- 3934
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 3934
		return -- 3936
	end -- 3936
	if not input.interact.pressed then -- 3936
		return -- 3939
	end -- 3939
	box.x0 = 430 -- 3941
	box.x1 = 474 -- 3942
	self.cartAxle = self.room.cart.endX -- 3944
	self.cartDocked = true -- 3945
	self.redCartPulled = true -- 3946
	if self.run.story ~= nil then -- 3946
		self.run.story.segments.outside_cart = true -- 3948
	end -- 3948
	self:flashSet("拉开红布车 · 石阶口露出来", 1.6) -- 3950
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 3951
end -- 3924
function Play.prototype.stepInteract(self, dt, input) -- 3954
	local p = self.player -- 3955
	self:stepRedCart(input) -- 3956
	local calmUsed = self.calmConsumed -- 3957
	self.calmConsumed = false -- 3958
	local calming = self.escort.state == "calming" -- 3960
	self.focusCart = false -- 3961
	if self.room.key == "outside" then -- 3961
		local c = self.room.cart -- 3963
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3964
		local dy = p.y - c.baseY -- 3965
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3966
	end -- 3966
	if not calmUsed and not calming then -- 3966
		self:stepCart(dt, input) -- 3970
	end -- 3970
	if calmUsed then -- 3970
		self:flashSet("安抚 · 敲两下", 0.8) -- 3975
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3975
		if self.knockT > 0 then -- 3975
			self.knocks = self.knocks + 1 -- 3979
		else -- 3979
			self.knocks = 1 -- 3981
		end -- 3981
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3983
		self.knockT = 1.2 -- 3984
		if self.knocks >= 2 then -- 3984
			self:flashSet("敲两下", 0.8) -- 3986
			self.knocks = 0 -- 3987
		else -- 3987
			self:flashSet("敲一下", 0.5) -- 3989
		end -- 3989
	elseif self.knockT > 0 then -- 3989
		self.knockT = self.knockT - dt -- 3992
		if self.knockT <= 0 then -- 3992
			self.knocks = 0 -- 3994
		end -- 3994
	end -- 3994
	local i = 0 -- 3999
	do -- 3999
		i = 0 -- 4000
		while i < #self.room.marks do -- 4000
			do -- 4000
				local m = self.room.marks[i + 1] -- 4001
				if m.kind ~= 0 then -- 4001
					goto __continue655 -- 4003
				end -- 4003
				local subjects = {self.partner, self.player} -- 4005
				local k = 0 -- 4006
				do -- 4006
					k = 0 -- 4007
					while k < #subjects do -- 4007
						do -- 4007
							local s = subjects[k + 1] -- 4008
							if not s.alive then -- 4008
								goto __continue658 -- 4010
							end -- 4010
							local dx = s.x - m.x -- 4012
							local dy = s.y - m.y -- 4013
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4013
								self.checkpoint = m.x -- 4015
								self.checkpointCartAxle = self.cartAxle -- 4016
								if self.isCampaign then -- 4016
									self:captureCheckpoint(m.x) -- 4019
								end -- 4019
								if self.cartDocked then -- 4019
									self:flashSet("检查点 · 车已落窝", 1) -- 4022
								else -- 4022
									self:flashSet("检查点 · 车还没到位", 1) -- 4024
								end -- 4024
							end -- 4024
						end -- 4024
						::__continue658:: -- 4024
						k = k + 1 -- 4007
					end -- 4007
				end -- 4007
			end -- 4007
			::__continue655:: -- 4007
			i = i + 1 -- 4000
		end -- 4000
	end -- 4000
	self:checkCarryGate() -- 4030
end -- 3954
function Play.prototype.stepVillage(self, dt, input) -- 4034
	if self.room.key ~= "village" then -- 4034
		return -- 4036
	end -- 4036
	local p = self.player -- 4038
	local bottle = self.room.bottle -- 4039
	local scav = self.room.scavenger -- 4040
	if not self.hasBottle and bottle ~= nil then -- 4040
		local dx = p.x - bottle.x -- 4044
		local dy = p.y + p.h * 0.5 - bottle.y -- 4045
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4045
			self.hasBottle = true -- 4047
			self:flashSet("拾起瓶子", 0.8) -- 4048
		end -- 4048
	end -- 4048
	if self.hasBottle then -- 4048
		if input.aim.held then -- 4048
			self.aimHold = self.aimHold + dt -- 4055
			if self.aimHold > 1.2 then -- 4055
				self.aimHold = 1.2 -- 4057
			end -- 4057
			local cached = self:bottleEnd() -- 4060
			self.bottleAimX = cached.x -- 4061
			self.bottleAimY = cached.y -- 4062
		elseif input.aim.released then -- 4062
			if self.aimHold < 0.12 then -- 4062
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4066
				self.aimHold = 0 -- 4067
			else -- 4067
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4069
				self:throwBottle(____end.x, ____end.y) -- 4070
				self.aimHold = 0 -- 4071
			end -- 4071
		end -- 4071
	else -- 4071
		self.aimHold = 0 -- 4075
		self.bottleAimX = -1 -- 4076
	end -- 4076
	local fly = self.bottleFly -- 4081
	if fly ~= nil then -- 4081
		fly.t = fly.t + dt -- 4083
		fly.x = fly.x0 + fly.vx * fly.t -- 4084
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4085
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4086
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4086
			self:landBottle(fly) -- 4088
		end -- 4088
	end -- 4088
	if self.bottleLandT > 0 then -- 4088
		self.bottleLandT = self.bottleLandT - dt -- 4092
	end -- 4092
	if scav ~= nil then -- 4092
		self:stepScav(dt, scav) -- 4096
	end -- 4096
	local line = self.room.passLine -- 4099
	if line ~= nil and not self.passed and p.x >= line then -- 4099
		self.passed = true -- 4101
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4102
	end -- 4102
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4105
	if underTable then -- 4105
		self.footHintT = self.footHintT - 1 -- 4107
		if self.footHintT <= 0 then -- 4107
			self.footHintT = 90 -- 4109
			local scavX = self.scavX -- 4110
			local near = math.abs(scavX - p.x) < 120 -- 4111
			local heard = near or self.scavState == "walk" or self.scavState == "chase" -- 4112
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4113
			self:emit("storyBeat", {beat = near and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4114
		end -- 4114
	else -- 4114
		self.footHintT = 0 -- 4117
	end -- 4117
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4117
		self.ditchHinted = true -- 4121
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4122
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4123
	end -- 4123
	if self.passed and p.x >= self.ox + 640 then -- 4123
		self:requestRoom("forest", "过第一院出院") -- 4127
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4128
	end -- 4128
end -- 4034
function Play.prototype.bottleEnd(self) -- 4133
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4134
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 4137
	return {x = aim.x, y = g} -- 4138
end -- 4133
function Play.prototype.throwBottle(self, tx, ty) -- 4142
	local p = self.player -- 4143
	local dir = tx >= p.x and 1 or -1 -- 4145
	p.facing = dir -- 4146
	local x0 = p.x + dir * 10 -- 4147
	local y0 = p.y + p.h * 0.7 -- 4148
	self.bottleTargetX = tx -- 4149
	self.bottleTargetY = ty -- 4150
	self.bottleSurfaceY = ty -- 4151
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4152
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4153
	self.bottleFly = { -- 4154
		x = x0, -- 4154
		y = y0, -- 4154
		x0 = x0, -- 4154
		y0 = y0, -- 4154
		vx = vx, -- 4154
		vy = vy, -- 4154
		t = 0 -- 4154
	} -- 4154
	self.hasBottle = false -- 4155
	self:flashSet("投出", 0.4) -- 4156
	self:emit( -- 4157
		"bottleThrown", -- 4157
		{ -- 4157
			fromX = x0, -- 4158
			fromY = y0, -- 4159
			targetX = tx, -- 4160
			targetY = ty, -- 4161
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4162
		} -- 4162
	) -- 4162
end -- 4142
function Play.prototype.landBottle(self, fly) -- 4167
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4168
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4169
	local s = self.room.scavenger -- 4170
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 4171
	self.bottleFly = nil -- 4172
	self.bottleTargetX = -1 -- 4173
	self.bottleTargetY = 0 -- 4174
	self.bottleSurfaceY = -1 -- 4175
	self.bottleLandX = x -- 4176
	self.bottleLandY = y -- 4177
	self.bottleLandT = 0.9 -- 4178
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 4179
	self:hearBottle(x) -- 4180
end -- 4167
function Play.prototype.hearBottle(self, x) -- 4184
	local s = self.room.scavenger -- 4185
	if s == nil then -- 4185
		return -- 4187
	end -- 4187
	if math.abs(x - self.scavX) > s.range then -- 4187
		self:flashSet("落地 · 他没听见", 0.6) -- 4190
		return -- 4191
	end -- 4191
	self.scavState = "turn" -- 4193
	self.scavT = s.hearTicks -- 4194
	self.scavTargetX = x -- 4195
	self:flashSet("砖地一响 · 他转头", 0.9) -- 4196
end -- 4184
function Play.prototype.stepScav(self, dt, s) -- 4200
	if self.scavState == "chase" then -- 4200
		return -- 4203
	end -- 4203
	if self.scavState == "turn" then -- 4203
		self.scavT = self.scavT - 1 -- 4206
		if self.scavT <= 0 then -- 4206
			self.scavState = "walk" -- 4208
		end -- 4208
		return -- 4210
	end -- 4210
	if self.scavState == "walk" then -- 4210
		local d = self.scavTargetX - self.scavX -- 4213
		if math.abs(d) < 4 then -- 4213
			self.scavState = "stall" -- 4215
			self.scavT = s.stallTicks -- 4216
			return -- 4217
		end -- 4217
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4219
		return -- 4220
	end -- 4220
	if self.scavState == "stall" then -- 4220
		self.scavT = self.scavT - 1 -- 4223
		if self.scavT <= 0 then -- 4223
			self.scavState = "back" -- 4225
		end -- 4225
		return -- 4227
	end -- 4227
	if self.scavState == "back" then -- 4227
		local home = math.max( -- 4230
			s.x0, -- 4230
			math.min(s.x1, self.scavX) -- 4230
		) -- 4230
		if math.abs(home - self.scavX) < 2 then -- 4230
			self.scavState = "patrol" -- 4232
			return -- 4233
		end -- 4233
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4235
		return -- 4236
	end -- 4236
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4238
	if self.scavX >= s.x1 then -- 4238
		self.scavX = s.x1 -- 4240
		self.scavDir = -1 -- 4241
	elseif self.scavX <= s.x0 then -- 4241
		self.scavX = s.x0 -- 4243
		self.scavDir = 1 -- 4244
	end -- 4244
end -- 4200
function Play.prototype.stepCart(self, dt, input) -- 4252
	local p = self.player -- 4253
	local c = self.room.cart -- 4254
	if self.gripping then -- 4254
		if not input.interact.held then -- 4254
			self.gripping = false -- 4258
			self:flashSet("松开车把", 0.4) -- 4259
			return -- 4260
		end -- 4260
	else -- 4260
		if not input.interact.pressed then -- 4260
			return -- 4264
		end -- 4264
		if not self:cartHandleInReach(p) then -- 4264
			return -- 4267
		end -- 4267
		local track = c.depth or 0 -- 4269
		if self:limitDepth(p, track) ~= track then -- 4269
			return -- 4271
		end -- 4271
		p.depth = track -- 4273
		p.depthSpeed = 0 -- 4274
		self.gripping = true -- 4275
		self:flashSet("握住车把", 0.4) -- 4276
		return -- 4277
	end -- 4277
	if self.cartDocked then -- 4277
		return -- 4281
	end -- 4281
	local dir = input.moveX -- 4283
	if dir == 0 then -- 4283
		return -- 4285
	end -- 4285
	local lo = math.min(c.startX, c.endX) -- 4287
	local hi = math.max(c.startX, c.endX) -- 4288
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4289
	if next < lo then -- 4289
		next = lo -- 4291
	end -- 4291
	if next > hi then -- 4291
		next = hi -- 4294
	end -- 4294
	local delta = next - self.cartAxle -- 4296
	if delta == 0 then -- 4296
		return -- 4298
	end -- 4298
	self.cartAxle = next -- 4300
	p.x = p.x + delta -- 4301
	p.facing = dir > 0 and 1 or -1 -- 4302
	self:slideX(p, 0) -- 4303
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4303
		self.gripping = false -- 4305
		self:flashSet("跟不上了，脱手", 0.6) -- 4306
		return -- 4307
	end -- 4307
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4307
		self.cartDocked = true -- 4310
		self.gripping = false -- 4311
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4312
		self:flashSet("车轮落窝", 1.2) -- 4313
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4313
		self:flashSet("车轮回到起点", 0.5) -- 4315
	end -- 4315
end -- 4252
function Play.prototype.requestRoom(self, key, reason) -- 4323
	if self.wantRoom ~= "" then -- 4323
		return -- 4327
	end -- 4327
	self.wantRoom = key -- 4329
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4330
end -- 4323
function Play.prototype.checkCarryGate(self) -- 4337
	if self.room.key == "checkpoint" then -- 4337
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4337
			self.carryCartAxle = self.cartAxle -- 4340
			self.carryCartDocked = self.cartDocked -- 4341
			self:requestRoom("gate", "检查站出口") -- 4342
			self:flashSet("出检查站 · 城门", 1.2) -- 4343
		end -- 4343
		return -- 4345
	end -- 4345
	if self.room.key == "outside" then -- 4345
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4345
			self.carryCartAxle = self.cartAxle -- 4351
			self.carryCartDocked = self.cartDocked -- 4352
			self:requestRoom("village", "墙根走完") -- 4353
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4354
		end -- 4354
	end -- 4354
end -- 4337
function Play.prototype.aimAt(self, wx, wy) -- 4361
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4362
	self.aimX = s.x -- 4363
	self.aimY = s.y -- 4364
end -- 4361
function Play.prototype.shoot(self, a) -- 4367
	if self.isCampaign and self.reloadT > 0 then -- 4367
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4369
		return -- 4370
	end -- 4370
	local ox = a.x + a.facing * 8 -- 4372
	local muzzleY = a.y + a.h * 0.72 -- 4373
	local oy = muzzleY + a.depth -- 4374
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4376
	local dx = aim.x - ox -- 4379
	local dy = aim.y - oy -- 4380
	local len = math.sqrt(dx * dx + dy * dy) -- 4381
	if len < 0.001 then -- 4381
		dx = a.facing -- 4383
		dy = 0 -- 4384
	else -- 4384
		dx = dx / len -- 4386
		dy = dy / len -- 4387
	end -- 4387
	if dx ~= 0 then -- 4387
		a.facing = dx > 0 and 1 or -1 -- 4390
	end -- 4390
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4393
	local hitEnemy = self:raycastEnemies(ray) -- 4394
	local tEnemy = hitEnemy.t -- 4395
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4396
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4397
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 4398
	local tWall = solid.t -- 4399
	local rawEffect = self:consumeReloadEffect() -- 4401
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4402
	local reloadEffect = rawEffect -- 4403
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4405
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4406
	self.trace = { -- 4408
		x0 = ox, -- 4408
		y0 = oy, -- 4408
		x1 = ox + dx * t, -- 4408
		y1 = oy + dy * t, -- 4408
		hit = hit -- 4408
	} -- 4408
	self.traceT = 0.12 -- 4409
	self:applyFireDanger(ox) -- 4410
	local killed = false -- 4411
	if hit then -- 4411
		local i = hitEnemy.index -- 4413
		local e = self.enemies[i + 1] -- 4414
		local impactY = oy + dy * tEnemy -- 4415
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4416
		local shieldTop = e.y + (e.depth or 0) + 64 -- 4417
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4417
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4419
			e.hitT = 0.3 -- 4420
			self:flashSet( -- 4421
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4421
				0.8 -- 4421
			) -- 4421
			self:emit("shotResolved", { -- 4422
				hit = true, -- 4423
				enemyIndex = i, -- 4423
				enemyX = e.x, -- 4423
				aimX = aim.x, -- 4423
				aimY = aim.y, -- 4423
				impactX = ox + dx * t, -- 4424
				impactY = oy + dy * t, -- 4424
				shield = true -- 4424
			}) -- 4424
			self:beginReload() -- 4426
			return -- 4427
		end -- 4427
		e.alive = false -- 4429
		e.hitT = 0.4 -- 4430
		killed = true -- 4431
		self:flashSet("命中", 0.6) -- 4432
		self:dropFor(e) -- 4433
		if reloadEffect == "light" and weaponFx == "light" then -- 4433
			self:blindNearby(e, 160, i) -- 4435
		end -- 4435
		if reloadEffect == "push" then -- 4435
			e.x = e.x + a.facing * 46 -- 4438
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4439
		elseif reloadEffect == "echo" then -- 4439
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4441
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4442
		elseif reloadEffect == "light" then -- 4442
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4444
		end -- 4444
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4444
		self:damageProp(solid.box, 1) -- 4447
	else -- 4447
		self:flashSet("打空", 0.35) -- 4449
	end -- 4449
	if self.isCampaign then -- 4449
		self:beginReload() -- 4452
	end -- 4452
	self:emit("shotResolved", { -- 4454
		hit = hit, -- 4455
		enemyIndex = hit and hitEnemy.index or -1, -- 4456
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4457
		aimX = aim.x, -- 4458
		aimY = aim.y, -- 4459
		impactX = ox + dx * t, -- 4460
		impactY = oy + dy * t -- 4461
	}) -- 4461
end -- 4367
function Play.prototype.applyFireDanger(self, shotX) -- 4466
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4466
		return -- 4468
	end -- 4468
	local dangerX = shotX -- 4470
	local best = -1 -- 4471
	local bestD = 1000000000 -- 4472
	local i = 0 -- 4473
	do -- 4473
		i = 0 -- 4474
		while i < #self.enemies do -- 4474
			do -- 4474
				local e = self.enemies[i + 1] -- 4475
				if not e.alive then -- 4475
					goto __continue743 -- 4477
				end -- 4477
				local d = math.abs(e.x - self.partner.x) -- 4479
				if d < bestD then -- 4479
					bestD = d -- 4481
					best = i -- 4482
				end -- 4482
			end -- 4482
			::__continue743:: -- 4482
			i = i + 1 -- 4474
		end -- 4474
	end -- 4474
	if best >= 0 then -- 4474
		dangerX = self.enemies[best + 1].x -- 4486
	end -- 4486
	local exposed = self:childExposed(dangerX) -- 4488
	local before = self.escort.fear -- 4489
	local dangerId = self.nextDangerId -- 4490
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4491
	self.nextDangerId = self.nextDangerId + 1 -- 4492
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4493
	if after > before then -- 4493
		self:flashSet( -- 4495
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4495
			1 -- 4495
		) -- 4495
	elseif not exposed then -- 4495
		self:flashSet("枪声没够到她", 0.5) -- 4497
	end -- 4497
end -- 4466
function Play.prototype.childExposed(self, dangerX) -- 4502
	local c = self.partner -- 4503
	if not c.alive then -- 4503
		return false -- 4505
	end -- 4505
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4505
		self.boxes, -- 4508
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4508
	) then -- 4508
		return false -- 4509
	end -- 4509
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4509
		return false -- 4512
	end -- 4512
	local toDanger = dangerX - c.x -- 4514
	local toPlayer = self.player.x - c.x -- 4515
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4515
		return false -- 4518
	end -- 4518
	return true -- 4520
end -- 4502
function Play.prototype.raycastEnemies(self, ray) -- 4524
	local best = -1 -- 4525
	local bestI = -1 -- 4526
	do -- 4526
		local i = 0 -- 4527
		while i < #self.enemies do -- 4527
			do -- 4527
				local e = self.enemies[i + 1] -- 4528
				if not e.alive then -- 4528
					goto __continue757 -- 4530
				end -- 4530
				local y = e.y + (e.depth or 0) -- 4532
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4533
				if t >= 0 and (best < 0 or t < best) then -- 4533
					best = t -- 4535
					bestI = i -- 4536
				end -- 4536
			end -- 4536
			::__continue757:: -- 4536
			i = i + 1 -- 4527
		end -- 4527
	end -- 4527
	return {t = best, index = bestI} -- 4539
end -- 4524
function Play.prototype.raycastWorld(self, ray) -- 4542
	return self:raycastSolid(ray).t -- 4543
end -- 4542
function Play.prototype.raycastSolid(self, ray) -- 4547
	local best = -1 -- 4548
	local bestBox = nil -- 4549
	for ____, box in ipairs(self.boxes) do -- 4550
		do -- 4550
			if box.broken == true or box.hidden == true then -- 4550
				goto __continue762 -- 4552
			end -- 4552
			local t = hitBox(ray, box) -- 4557
			if t > 2 and (best < 0 or t < best) then -- 4557
				best = t -- 4560
				bestBox = box -- 4561
			end -- 4561
		end -- 4561
		::__continue762:: -- 4561
	end -- 4561
	if ray.dy < 0 then -- 4561
		local t = -ray.y / ray.dy -- 4565
		if t >= 0 and (best < 0 or t < best) then -- 4565
			best = t -- 4567
			bestBox = nil -- 4568
		end -- 4568
	end -- 4568
	return {t = best, box = bestBox} -- 4571
end -- 4547
function Play.prototype.dropFor(self, e) -- 4575
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4575
		return -- 4577
	end -- 4577
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4577
		return -- 4580
	end -- 4580
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4582
	local ____self_pickups_57 = self.pickups -- 4582
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4583
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4584
		kind = e.drop, -- 4584
		x = e.x, -- 4584
		y = e.y, -- 4584
		depth = e.depth, -- 4585
		label = label .. " ×1" -- 4585
	} -- 4585
	self:log("掉落 " .. label) -- 4587
end -- 4575
function Play.prototype.damageProp(self, b, amount) -- 4591
	if b.breakable == nil or b.broken == true then -- 4591
		return -- 4593
	end -- 4593
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4593
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4595
	if b.breakable.hp > 0 then -- 4595
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4597
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4598
		return -- 4599
	end -- 4599
	b.broken = true -- 4601
	for ____, other in ipairs(self.boxes) do -- 4602
		if other.id ~= nil and other.id == b.id then -- 4602
			other.broken = true -- 4604
		end -- 4604
	end -- 4604
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4607
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4608
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4609
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4610
end -- 4591
function Play.prototype.slideDepth(self, a, distance) -- 4614
	a.depth = self:limitDepth(a, a.depth + distance) -- 4615
end -- 4614
function Play.prototype.limitDepth(self, a, target) -- 4618
	local road = self.room.depth -- 4619
	if road == nil or target == a.depth then -- 4619
		return a.depth -- 4621
	end -- 4621
	local next = math.max( -- 4623
		road.min, -- 4623
		math.min(road.max, target) -- 4623
	) -- 4623
	local half = a.w / 2 -- 4624
	for ____, b in ipairs(self.boxes) do -- 4625
		do -- 4625
			local footprint = b.depth -- 4626
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4626
				goto __continue780 -- 4631
			end -- 4631
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4633
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4634
			if a.depth <= front and next > front then -- 4634
				next = front -- 4636
			elseif a.depth >= back and next < back then -- 4636
				next = back -- 4638
			end -- 4638
		end -- 4638
		::__continue780:: -- 4638
	end -- 4638
	return next -- 4641
end -- 4618
function Play.prototype.slideX(self, a, dx) -- 4645
	local nx = a.x + dx -- 4646
	local half = a.w / 2 -- 4647
	local room = self.room -- 4648
	nx = math.max( -- 4649
		room.minX + half, -- 4649
		math.min(room.maxX - half, nx) -- 4649
	) -- 4649
	local i = 0 -- 4650
	do -- 4650
		i = 0 -- 4651
		while i < #self.boxes do -- 4651
			do -- 4651
				local b = self.boxes[i + 1] -- 4652
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4652
					goto __continue787 -- 4654
				end -- 4654
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4654
					goto __continue787 -- 4657
				end -- 4657
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4657
					goto __continue787 -- 4660
				end -- 4660
				if nx + half > b.x0 and nx - half < b.x1 then -- 4660
					if a.x <= b.x0 then -- 4660
						nx = b.x0 - half -- 4664
					elseif a.x >= b.x1 then -- 4664
						nx = b.x1 + half -- 4666
					else -- 4666
						nx = a.x -- 4668
					end -- 4668
				end -- 4668
			end -- 4668
			::__continue787:: -- 4668
			i = i + 1 -- 4651
		end -- 4651
	end -- 4651
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4651
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4676
		local bx0 = self.cartAxle - CART_HALF -- 4677
		local bx1 = self.cartAxle + CART_HALF -- 4678
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4678
			if a.x <= bx0 then -- 4678
				nx = bx0 - half -- 4681
			elseif a.x >= bx1 then -- 4681
				nx = bx1 + half -- 4683
			else -- 4683
				nx = a.x -- 4685
			end -- 4685
		end -- 4685
	end -- 4685
	local arch = room.arch -- 4693
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4693
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4695
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4695
			if a.x <= arch.x0 then -- 4695
				nx = arch.x0 - half -- 4698
			elseif a.x >= arch.x1 then -- 4698
				nx = arch.x1 + half -- 4700
			end -- 4700
		end -- 4700
	end -- 4700
	a.x = nx -- 4704
end -- 4645
function Play.prototype.fallY(self, a, dt) -- 4708
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4709
	if a.vy < -900 then -- 4709
		a.vy = -900 -- 4711
	end -- 4711
	local ny = a.y + a.vy * dt -- 4713
	local half = a.w / 2 -- 4714
	if a.vy <= 0 then -- 4714
		local reach = a.onGround and STEP_UP or 0 -- 4717
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4718
		if ny <= ground then -- 4718
			ny = ground -- 4720
			a.vy = 0 -- 4721
			a.onGround = true -- 4722
		else -- 4722
			a.onGround = false -- 4724
		end -- 4724
	else -- 4724
		a.onGround = false -- 4727
		local i = 0 -- 4728
		do -- 4728
			i = 0 -- 4729
			while i < #self.boxes do -- 4729
				do -- 4729
					local b = self.boxes[i + 1] -- 4730
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4730
						goto __continue811 -- 4732
					end -- 4732
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4732
						goto __continue811 -- 4735
					end -- 4735
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4735
						goto __continue811 -- 4738
					end -- 4738
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4738
						ny = b.y0 - a.h -- 4741
						a.vy = 0 -- 4742
					end -- 4742
				end -- 4742
				::__continue811:: -- 4742
				i = i + 1 -- 4729
			end -- 4729
		end -- 4729
	end -- 4729
	a.y = ny -- 4746
end -- 4708
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4750
	if depth == nil then -- 4750
		depth = 0 -- 4750
	end -- 4750
	local g = -9999 -- 4751
	local i = 0 -- 4752
	do -- 4752
		i = 0 -- 4753
		while i < #self.floors do -- 4753
			local f = self.floors[i + 1] -- 4754
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4754
				g = f.y1 -- 4756
			end -- 4756
			i = i + 1 -- 4753
		end -- 4753
	end -- 4753
	do -- 4753
		i = 0 -- 4759
		while i < #self.boxes do -- 4759
			do -- 4759
				local b = self.boxes[i + 1] -- 4760
				if b.broken == true or b.hidden == true or b.soft == true then -- 4760
					goto __continue821 -- 4762
				end -- 4762
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4762
					g = b.y1 -- 4766
				end -- 4766
			end -- 4766
			::__continue821:: -- 4766
			i = i + 1 -- 4759
		end -- 4759
	end -- 4759
	return g -- 4769
end -- 4750
function Play.prototype.updateCamera(self, dt) -- 4772
	local p = self.player -- 4773
	local tx = p.x + p.facing * 30 -- 4774
	local ty = p.y + CAM_LOOK_UP -- 4775
	local k = math.min(1, CAM_FOLLOW * dt) -- 4776
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4777
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4778
end -- 4772
function Play.prototype.clampCamera(self, w, h) -- 4782
	local room = self.room -- 4783
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4784
	local spanX = room.maxX - room.minX -- 4785
	if spanX <= halfW * 2 then -- 4785
		self.cam.x = (room.minX + room.maxX) / 2 -- 4787
	else -- 4787
		self.cam.x = math.max( -- 4789
			room.minX + halfW, -- 4789
			math.min(room.maxX - halfW, self.cam.x) -- 4789
		) -- 4789
	end -- 4789
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4792
	local spanY = room.height -- 4793
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4794
	if spanY <= halfH * 2 then -- 4794
		self.cam.y = camY -- 4796
	else -- 4796
		self.cam.y = math.max( -- 4798
			camY, -- 4798
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4798
		) -- 4798
	end -- 4798
end -- 4782
function Play.prototype.flashSet(self, text, t) -- 4802
	self.flash = text -- 4803
	self.flashT = t -- 4804
end -- 4802
function Play.prototype.statusText(self) -- 4808
	local p = self.player -- 4809
	local parts = {} -- 4810
	local who = self.childMode and "小满" or "周戍" -- 4811
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4812
	if self.room.key == "prologue" then -- 4812
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4815
		if self.phase == "prologue-wake" then -- 4815
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 4817
		elseif self.phase == "prologue-shadow" then -- 4817
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 4819
		elseif self.phase == "prologue-escape" then -- 4819
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 4821
		elseif self.phase == "prologue-hide" then -- 4821
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 4823
		elseif self.phase == "prologue-wait" then -- 4823
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4825
		elseif self.phase == "prologue-give" then -- 4825
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4827
		else -- 4827
			parts[#parts + 1] = "跟随" -- 4829
		end -- 4829
		if self.paused then -- 4829
			parts[#parts + 1] = "已暂停" -- 4832
		end -- 4832
		return table.concat(parts, " · ") -- 4834
	end -- 4834
	if self.room.key == "street" then -- 4834
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4837
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4838
		if self.paused then -- 4838
			parts[#parts + 1] = "已暂停" -- 4840
		end -- 4840
		return table.concat(parts, " · ") -- 4842
	end -- 4842
	if self.room.key == "gate" then -- 4842
		local ____temp_60 -- 4845
		if self.room.story == nil then -- 4845
			____temp_60 = nil -- 4845
		else -- 4845
			____temp_60 = self.room.story.gate -- 4845
		end -- 4845
		local g = ____temp_60 -- 4845
		if g ~= nil then -- 4845
			parts[#parts + 1] = self:gateLabel() -- 4847
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4848
				0, -- 4849
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4849
			))) .. " 秒" -- 4849
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4850
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4851
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4852
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4853
			if self.gateFailCount > 0 then -- 4853
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4855
			end -- 4855
			if self.flash ~= "" then -- 4855
				parts[#parts + 1] = self.flash -- 4858
			end -- 4858
		end -- 4858
		if self.paused then -- 4858
			parts[#parts + 1] = "已暂停" -- 4862
		end -- 4862
		return table.concat(parts, " · ") -- 4864
	end -- 4864
	if self.room.key == "forest" then -- 4864
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4867
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4868
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4869
		if self.caughtT > 0 then -- 4869
			parts[#parts + 1] = "复位中" -- 4871
		end -- 4871
		if self.paused then -- 4871
			parts[#parts + 1] = "已暂停" -- 4874
		end -- 4874
		return table.concat(parts, " · ") -- 4876
	end -- 4876
	if self.room.key == "tower" then -- 4876
		if self.phase == "tower-wait" then -- 4876
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4880
		elseif self.phase == "tower-knock" then -- 4880
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4882
		elseif self.phase == "tower-enter" then -- 4882
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 4884
		elseif self.phase == "tower-desk" then -- 4884
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 4886
		elseif self.phase == "tower-given" then -- 4886
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4888
		else -- 4888
			parts[#parts + 1] = "片尾" -- 4890
		end -- 4890
		if self.paused then -- 4890
			parts[#parts + 1] = "已暂停" -- 4893
		end -- 4893
		return table.concat(parts, " · ") -- 4895
	end -- 4895
	if self.room.key == "village" then -- 4895
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4898
		if self.hasBottle then -- 4898
			parts[#parts + 1] = "有瓶" -- 4900
		elseif self.bottleFly ~= nil then -- 4900
			parts[#parts + 1] = "瓶在飞" -- 4902
		else -- 4902
			parts[#parts + 1] = "空手" -- 4904
		end -- 4904
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4906
		if self.scavChase then -- 4906
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4908
		end -- 4908
		if self.passed then -- 4908
			parts[#parts + 1] = "已过通行线" -- 4911
		end -- 4911
		if self.paused then -- 4911
			parts[#parts + 1] = "已暂停" -- 4914
		end -- 4914
		return table.concat(parts, " · ") -- 4916
	end -- 4916
	local isChild = self.childMode -- 4919
	if isChild then -- 4919
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4921
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4922
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4923
	else -- 4923
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4925
		if p.rollT > 0 then -- 4925
			parts[#parts + 1] = "翻滚中" -- 4927
		end -- 4927
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4929
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4930
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4931
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4932
	end -- 4932
	if self.checkpoint >= 0 then -- 4932
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4935
	end -- 4935
	if self.paused then -- 4935
		parts[#parts + 1] = "已暂停" -- 4938
	end -- 4938
	return table.concat(parts, " · ") -- 4940
end -- 4808
function Play.prototype.aliveEnemies(self) -- 4944
	local n = 0 -- 4945
	local i = 0 -- 4946
	do -- 4946
		i = 0 -- 4947
		while i < #self.enemies do -- 4947
			if self.enemies[i + 1].alive then -- 4947
				n = n + 1 -- 4949
			end -- 4949
			i = i + 1 -- 4947
		end -- 4947
	end -- 4947
	return n -- 4952
end -- 4944
function Play.prototype.threatened(self) -- 4957
	do -- 4957
		local i = 0 -- 4958
		while i < #self.enemies do -- 4958
			local e = self.enemies[i + 1] -- 4959
			if e.alive and e.warnT > 0 then -- 4959
				return true -- 4961
			end -- 4961
			i = i + 1 -- 4958
		end -- 4958
	end -- 4958
	return false -- 4964
end -- 4957
function Play.prototype.gateSecondsLeft(self) -- 4967
	local ____temp_61 -- 4968
	if self.room.story == nil then -- 4968
		____temp_61 = nil -- 4968
	else -- 4968
		____temp_61 = self.room.story.gate -- 4968
	end -- 4968
	local g = ____temp_61 -- 4968
	if g == nil then -- 4968
		return 0 -- 4970
	end -- 4970
	return math.max( -- 4972
		0, -- 4972
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4972
	) -- 4972
end -- 4967
function Play.prototype.gateLabel(self) -- 4975
	if self.phase == "gate-idle" then -- 4975
		return "待就位" -- 4977
	end -- 4977
	if self.phase == "gate-hold" then -- 4977
		return "守点中" -- 4980
	end -- 4980
	if self.phase == "gate-send" then -- 4980
		return "送别" -- 4983
	end -- 4983
	if self.phase == "gate-count" then -- 4983
		return "数数 " .. tostring(self.countTick) -- 4986
	end -- 4986
	return "她走" -- 4988
end -- 4975
function Play.prototype.dogLabel(self) -- 4992
	if self.dogState == "ear" then -- 4992
		return "转耳" -- 4994
	end -- 4994
	if self.dogState == "chase" then -- 4994
		return "追" -- 4997
	end -- 4997
	if self.dogState == "sniff" then -- 4997
		return "停" -- 5000
	end -- 5000
	if self.dogState == "back" then -- 5000
		return "回线" -- 5003
	end -- 5003
	return "巡逻" -- 5005
end -- 4992
function Play.prototype.doorXOf(self) -- 5008
	local ____temp_62 -- 5009
	if self.room.story == nil then -- 5009
		____temp_62 = nil -- 5009
	else -- 5009
		____temp_62 = self.room.story.tower -- 5009
	end -- 5009
	local t = ____temp_62 -- 5009
	return t == nil and 0 or t.doorX -- 5010
end -- 5008
function Play.prototype.scavLabel(self) -- 5014
	if self.scavState == "chase" then -- 5014
		return "追" -- 5016
	end -- 5016
	if self.scavState == "turn" then -- 5016
		return "转头" -- 5019
	end -- 5019
	if self.scavState == "walk" then -- 5019
		return "赶来" -- 5022
	end -- 5022
	if self.scavState == "stall" then -- 5022
		return "停住" -- 5025
	end -- 5025
	if self.scavState == "back" then -- 5025
		return "回位" -- 5028
	end -- 5028
	return "巡逻" -- 5030
end -- 5014
function Play.prototype.hintText(self) -- 5034
	if self.paused then -- 5034
		return "Esc 继续 · R 重置" -- 5036
	end -- 5036
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5036
		if self:threatened() then -- 5036
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5042
		end -- 5042
		if self.coverHug then -- 5042
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5045
		end -- 5045
		if self.coverNear then -- 5045
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5048
		end -- 5048
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5050
	end -- 5050
	if self.flash ~= "" then -- 5050
		return self.flash -- 5053
	end -- 5053
	if self.room.key == "prologue" then -- 5053
		if self.phase == "prologue-wake" then -- 5053
			return "父亲在门外唤 · 小满睁眼" -- 5057
		end -- 5057
		if self.phase == "prologue-shadow" then -- 5057
			return "墙上两道人影 · 碗滚到脚边" -- 5060
		end -- 5060
		if self.phase == "prologue-escape" then -- 5060
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5063
		end -- 5063
		if self.phase == "prologue-hide" then -- 5063
			return "柜门合上 · 屏住呼吸" -- 5066
		end -- 5066
		if self.phase == "prologue-wait" then -- 5066
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5069
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5070
		end -- 5070
		if self.phase == "prologue-give" then -- 5070
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5073
		end -- 5073
		return "她跟着你了 · 两人一起走到门口 680" -- 5075
	end -- 5075
	if self.room.key == "street" then -- 5075
		if self:aliveEnemies() > 0 then -- 5075
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5079
		end -- 5079
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5081
	end -- 5081
	if self.room.key == "gate" then -- 5081
		local ____temp_63 -- 5084
		if self.room.story == nil then -- 5084
			____temp_63 = nil -- 5084
		else -- 5084
			____temp_63 = self.room.story.gate -- 5084
		end -- 5084
		local g = ____temp_63 -- 5084
		if g ~= nil then -- 5084
			if self.phase == "gate-idle" then -- 5084
				if self.gateNeedConfirm then -- 5084
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5088
				end -- 5088
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5090
			end -- 5090
			if self.phase == "gate-hold" then -- 5090
				if self.coveredFlash > 0 then -- 5090
					return "掩体挡下了这一枪 · 别露头" -- 5094
				end -- 5094
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5096
			end -- 5096
			if self.phase == "gate-send" then -- 5096
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5099
			end -- 5099
			if self.phase == "gate-count" then -- 5099
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5099
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5103
				end -- 5103
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5105
			end -- 5105
			return "她自己走 · 跟着出城门 1120" -- 5107
		end -- 5107
	end -- 5107
	if self.room.key == "forest" then -- 5107
		if self.dogState == "chase" then -- 5107
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5112
		end -- 5112
		if self.dogState == "ear" then -- 5112
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5115
		end -- 5115
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5117
	end -- 5117
	if self.room.key == "tower" then -- 5117
		if self.phase == "tower-wait" then -- 5117
			return "走到门前 445 点一次 E 敲两下" -- 5121
		end -- 5121
		if self.phase == "tower-knock" then -- 5121
			return "敲两下 · 等门开" -- 5124
		end -- 5124
		if self.phase == "tower-given" then -- 5124
			return "递交针套和纸条 · 看登记簿最后一行" -- 5127
		end -- 5127
		return "片尾 · 点 E 再玩一次，回到序章" -- 5129
	end -- 5129
	if self.room.key == "village" then -- 5129
		if self.bottleFly ~= nil then -- 5129
			return "等瓶子落地 · 触地才发声" -- 5133
		end -- 5133
		if self.hasBottle then -- 5133
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5136
		end -- 5136
		if self.passed then -- 5136
			return "已过第一院 · R 重置可再来一遍" -- 5139
		end -- 5139
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5141
	end -- 5141
	if self.room.key == "outside" then -- 5141
		if self.focusCart then -- 5141
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5145
		end -- 5145
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5147
	end -- 5147
	if self.escort.state == "frozen" then -- 5147
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5147
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5151
		end -- 5151
		return "小满吓住了 · 走过去，靠近再点 E" -- 5153
	end -- 5153
	if self.escort.state == "calming" then -- 5153
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5156
	end -- 5156
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5158
end -- 5034
function Play.prototype.draw(self, draw, w, h) -- 5163
	self.viewW = w -- 5164
	self.viewH = h -- 5165
	self.view = ____exports.computeViewport(w, h) -- 5166
	self:clampCamera(w, h) -- 5167
	draw:clear() -- 5168
	draw:drawRect( -- 5170
		Rect(0, 0, w, h), -- 5170
		BG_VOID -- 5170
	) -- 5170
	local box = self:canvasRect(w, h) -- 5171
	draw:drawRect(box, BG_FAR) -- 5172
	draw:drawRect( -- 5173
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5173
		BG_MID -- 5173
	) -- 5173
	self:drawFloors(draw, w, h) -- 5175
	self:drawSolids(draw, w, h) -- 5176
	self:drawZones(draw, w, h) -- 5177
	self:drawArch(draw, w, h) -- 5178
	self:drawCart(draw, w, h) -- 5179
	self:drawCampaignProps(draw, w, h) -- 5180
	self:drawActors(draw, w, h) -- 5181
	self:drawTrace(draw, w, h) -- 5182
	self:drawAim(draw, w, h) -- 5183
end -- 5163
function Play.prototype.canvasRect(self, w, h) -- 5187
	local v = self.view -- 5188
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5189
end -- 5187
function Play.prototype.px(self, n) -- 5193
	return n * self.view.zoom -- 5194
end -- 5193
function Play.prototype.sx(self, wx, w) -- 5198
	local v = self.view -- 5199
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5200
	return v.ox + lx * v.zoom -- 5201
end -- 5198
function Play.prototype.sy(self, wy, h) -- 5205
	local v = self.view -- 5206
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5207
	return v.oy + ly * v.zoom -- 5208
end -- 5205
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5211
	local px0 = self:sx(x0, w) -- 5212
	local px1 = self:sx(x1, w) -- 5213
	local py0 = self:sy(y0, h) -- 5214
	local py1 = self:sy(y1, h) -- 5215
	if px1 <= px0 or py1 <= py0 then -- 5215
		return -- 5217
	end -- 5217
	draw:drawRect( -- 5219
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5219
		color -- 5219
	) -- 5219
end -- 5211
function Play.prototype.drawFloors(self, draw, w, h) -- 5222
	local i = 0 -- 5223
	do -- 5223
		i = 0 -- 5224
		while i < #self.room.floors do -- 5224
			local f = self.room.floors[i + 1] -- 5225
			local ____temp_64 -- 5226
			if f.y == 0 then -- 5226
				____temp_64 = self.room.depth -- 5226
			else -- 5226
				____temp_64 = nil -- 5226
			end -- 5226
			local road = ____temp_64 -- 5226
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5227
			local x0 = self:sx(f.x0, w) -- 5228
			local x1 = self:sx(f.x1, w) -- 5229
			local deck = self:px(5) -- 5230
			if road ~= nil then -- 5230
				local back = self:sy(f.y + road.max, h) -- 5232
				draw:drawRect( -- 5233
					Rect(x0, y, x1 - x0, back - y), -- 5233
					FLOOR_DECK, -- 5233
					self:px(1), -- 5233
					SOLID_EDGE -- 5233
				) -- 5233
			end -- 5233
			draw:drawRect( -- 5235
				Rect(x0, y - deck, x1 - x0, deck), -- 5235
				FLOOR_DECK -- 5235
			) -- 5235
			draw:drawSegment( -- 5236
				Vec2(x0, y), -- 5236
				Vec2(x1, y), -- 5236
				self:px(1), -- 5236
				GROUND -- 5236
			) -- 5236
			i = i + 1 -- 5224
		end -- 5224
	end -- 5224
end -- 5222
function Play.prototype.drawSolids(self, draw, w, h) -- 5240
	local i = 0 -- 5241
	do -- 5241
		i = 0 -- 5242
		while i < #self.boxes do -- 5242
			do -- 5242
				local b = self.boxes[i + 1] -- 5243
				if b.id == "braced_shield" or b.hidden == true then -- 5243
					goto __continue952 -- 5245
				end -- 5245
				if b.broken == true then -- 5245
					if b.breakable ~= nil then -- 5245
						local gy = self:sy(b.y0, h) -- 5250
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5251
						local k = 0 -- 5252
						do -- 5252
							k = 0 -- 5253
							while k < 3 do -- 5253
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5254
								draw:drawSegment( -- 5255
									Vec2( -- 5255
										gx - self:px(4), -- 5255
										gy + self:px(k % 2) -- 5255
									), -- 5255
									Vec2( -- 5255
										gx + self:px(5), -- 5255
										gy + self:px(k % 2) -- 5255
									), -- 5255
									self:px(1), -- 5255
									rgb -- 5255
								) -- 5255
								k = k + 1 -- 5253
							end -- 5253
						end -- 5253
					end -- 5253
					goto __continue952 -- 5258
				end -- 5258
				local ____opt_67 = b.depth -- 5258
				local front = ____opt_67 and ____opt_67.min or 0 -- 5260
				local ____opt_69 = b.depth -- 5260
				local back = ____opt_69 and ____opt_69.max or 0 -- 5261
				local fill = SOLID_FILL -- 5262
				local line = SOLID_EDGE -- 5263
				if b.soft == true then -- 5263
					fill = SOFT -- 5265
					line = SOFT_LINE -- 5266
				elseif b.breakable ~= nil then -- 5266
					line = DANGER_LINE -- 5268
					fill = Color(0.3, 0.24, 0.16, 1) -- 5269
				elseif b.interact ~= nil then -- 5269
					line = PASS_LINE -- 5271
				end -- 5271
				self:drawBox( -- 5273
					draw, -- 5273
					w, -- 5273
					h, -- 5273
					b.x0, -- 5273
					b.x1, -- 5273
					b.y0 + front, -- 5273
					b.y1 + back, -- 5273
					fill -- 5273
				) -- 5273
				draw:drawSegment( -- 5274
					Vec2( -- 5274
						self:sx(b.x0, w), -- 5274
						self:sy(b.y1 + front, h) -- 5274
					), -- 5274
					Vec2( -- 5275
						self:sx(b.x1, w), -- 5275
						self:sy(b.y1 + front, h) -- 5275
					), -- 5275
					self:px(1), -- 5275
					line -- 5275
				) -- 5275
				if b.breakable ~= nil then -- 5275
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5278
					local cyp = self:sy(b.y1 + front, h) -- 5279
					draw:drawSegment( -- 5280
						Vec2( -- 5280
							cxp - self:px(4), -- 5280
							cyp + self:px(1) -- 5280
						), -- 5280
						Vec2( -- 5280
							cxp + self:px(3), -- 5280
							cyp + self:px(5) -- 5280
						), -- 5280
						self:px(1), -- 5280
						line -- 5280
					) -- 5280
				end -- 5280
			end -- 5280
			::__continue952:: -- 5280
			i = i + 1 -- 5242
		end -- 5242
	end -- 5242
end -- 5240
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5286
	local i = 0 -- 5287
	do -- 5287
		i = 0 -- 5288
		while i < #self.pickups do -- 5288
			do -- 5288
				local pk = self.pickups[i + 1] -- 5289
				if self.run.taken[pk.id] == true then -- 5289
					goto __continue964 -- 5291
				end -- 5291
				local gy = pk.y + (pk.depth or 0) -- 5293
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5294
				draw:drawRect( -- 5295
					Rect( -- 5295
						self:sx(pk.x - 5, w), -- 5295
						self:sy(gy + 12 + bob, h), -- 5295
						self:px(10), -- 5295
						self:px(10) -- 5295
					), -- 5295
					Color(0.84, 0.7, 0.3, 1) -- 5296
				) -- 5296
				draw:drawSegment( -- 5297
					Vec2( -- 5297
						self:sx(pk.x - 5, w), -- 5297
						self:sy(gy + 12 + bob, h) -- 5297
					), -- 5297
					Vec2( -- 5298
						self:sx(pk.x + 5, w), -- 5298
						self:sy(gy + 12 + bob, h) -- 5298
					), -- 5298
					self:px(1), -- 5298
					Color(0.95, 0.86, 0.52, 1) -- 5298
				) -- 5298
			end -- 5298
			::__continue964:: -- 5298
			i = i + 1 -- 5288
		end -- 5288
	end -- 5288
	if self.bracedShield ~= nil then -- 5288
		local sh = self.bracedShield -- 5301
		draw:drawRect( -- 5302
			Rect( -- 5302
				self:sx(sh.x - sh.w / 2, w), -- 5302
				self:sy(sh.y, h), -- 5302
				self:px(sh.w), -- 5302
				self:px(sh.h) -- 5302
			), -- 5302
			Color(0.42, 0.4, 0.34, 1) -- 5303
		) -- 5303
		draw:drawSegment( -- 5304
			Vec2( -- 5304
				self:sx(sh.x - sh.w / 2, w), -- 5304
				self:sy(sh.y + sh.h, h) -- 5304
			), -- 5304
			Vec2( -- 5305
				self:sx(sh.x + sh.w / 2, w), -- 5305
				self:sy(sh.y + sh.h, h) -- 5305
			), -- 5305
			self:px(1), -- 5305
			Color(0.74, 0.72, 0.62, 1) -- 5305
		) -- 5305
	end -- 5305
end -- 5286
function Play.prototype.drawZones(self, draw, w, h) -- 5309
	local i = 0 -- 5310
	do -- 5310
		i = 0 -- 5311
		while i < #self.room.zones do -- 5311
			local z = self.room.zones[i + 1] -- 5312
			local fill = DANGER -- 5313
			local line = DANGER_LINE -- 5314
			if z.tint == 2 then -- 5314
				fill = SOFT -- 5316
				line = SOFT_LINE -- 5317
			elseif z.tint == 3 then -- 5317
				fill = BRICK -- 5319
				line = BRICK_LINE -- 5320
			elseif z.tint == 4 then -- 5320
				fill = PASS -- 5322
				line = PASS_LINE -- 5323
			end -- 5323
			self:drawBox( -- 5325
				draw, -- 5325
				w, -- 5325
				h, -- 5325
				z.x0, -- 5325
				z.x1, -- 5325
				z.y, -- 5325
				z.y + z.h, -- 5325
				fill -- 5325
			) -- 5325
			draw:drawSegment( -- 5326
				Vec2( -- 5326
					self:sx(z.x0, w), -- 5326
					self:sy(z.y, h) -- 5326
				), -- 5326
				Vec2( -- 5326
					self:sx(z.x0, w), -- 5326
					self:sy(z.y + z.h, h) -- 5326
				), -- 5326
				self:px(1), -- 5326
				line -- 5326
			) -- 5326
			draw:drawSegment( -- 5327
				Vec2( -- 5327
					self:sx(z.x1, w), -- 5327
					self:sy(z.y, h) -- 5327
				), -- 5327
				Vec2( -- 5327
					self:sx(z.x1, w), -- 5327
					self:sy(z.y + z.h, h) -- 5327
				), -- 5327
				self:px(1), -- 5327
				line -- 5327
			) -- 5327
			i = i + 1 -- 5311
		end -- 5311
	end -- 5311
end -- 5309
function Play.prototype.drawArch(self, draw, w, h) -- 5331
	local a = self.room.arch -- 5332
	if a.h <= 0 then -- 5332
		return -- 5334
	end -- 5334
	self:drawBox( -- 5336
		draw, -- 5336
		w, -- 5336
		h, -- 5336
		a.x0, -- 5336
		a.x1, -- 5336
		a.y, -- 5336
		a.y + a.h, -- 5336
		HOLE_FILL -- 5336
	) -- 5336
	draw:drawSegment( -- 5337
		Vec2( -- 5337
			self:sx(a.x0, w), -- 5337
			self:sy(a.y + a.h, h) -- 5337
		), -- 5337
		Vec2( -- 5337
			self:sx(a.x1, w), -- 5337
			self:sy(a.y + a.h, h) -- 5337
		), -- 5337
		self:px(1), -- 5337
		SOLID_EDGE -- 5337
	) -- 5337
	draw:drawSegment( -- 5338
		Vec2( -- 5338
			self:sx(a.x0, w), -- 5338
			self:sy(a.y, h) -- 5338
		), -- 5338
		Vec2( -- 5338
			self:sx(a.x0, w), -- 5338
			self:sy(a.y + a.h, h) -- 5338
		), -- 5338
		self:px(1), -- 5338
		SOLID_EDGE -- 5338
	) -- 5338
	draw:drawSegment( -- 5339
		Vec2( -- 5339
			self:sx(a.x1, w), -- 5339
			self:sy(a.y, h) -- 5339
		), -- 5339
		Vec2( -- 5339
			self:sx(a.x1, w), -- 5339
			self:sy(a.y + a.h, h) -- 5339
		), -- 5339
		self:px(1), -- 5339
		SOLID_EDGE -- 5339
	) -- 5339
end -- 5331
function Play.prototype.drawCart(self, draw, w, h) -- 5342
	local c = self.room.cart -- 5343
	if c.bodyW <= 0 then -- 5343
		return -- 5345
	end -- 5345
	drawCartShape( -- 5347
		draw, -- 5347
		self, -- 5347
		w, -- 5347
		h, -- 5347
		c, -- 5347
		self.cartAxle -- 5347
	) -- 5347
	draw:drawRect( -- 5348
		Rect( -- 5348
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5348
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5348
			self:px(2), -- 5348
			self:px(40) -- 5348
		), -- 5348
		STAND -- 5348
	) -- 5348
end -- 5342
function Play.prototype.drawActors(self, draw, w, h) -- 5351
	local p = self.player -- 5352
	local isChild = self.childMode -- 5353
	local footY = p.y + p.depth -- 5354
	if p.covered then -- 5354
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5357
		draw:drawSegment( -- 5358
			Vec2( -- 5358
				self:sx(edge, w), -- 5358
				self:sy(footY + 8, h) -- 5358
			), -- 5358
			Vec2( -- 5358
				self:sx(edge, w), -- 5358
				self:sy(footY + p.h * 0.62, h) -- 5358
			), -- 5358
			self:px(2), -- 5358
			STAND -- 5358
		) -- 5358
		draw:drawSegment( -- 5360
			Vec2( -- 5360
				self:sx(p.x - 8, w), -- 5360
				self:sy(footY + p.h + 3, h) -- 5360
			), -- 5360
			Vec2( -- 5360
				self:sx(p.x + 8, w), -- 5360
				self:sy(footY + p.h + 3, h) -- 5360
			), -- 5360
			self:px(2), -- 5360
			STAND -- 5360
		) -- 5360
	elseif self.coverNear and not isChild then -- 5360
		draw:drawRect( -- 5363
			Rect( -- 5363
				self:sx(p.x - 3, w), -- 5363
				self:sy(footY + 1, h), -- 5363
				self:px(3), -- 5363
				self:px(3) -- 5363
			), -- 5363
			STAND -- 5363
		) -- 5363
	end -- 5363
	drawFigure( -- 5365
		draw, -- 5365
		self, -- 5365
		w, -- 5365
		h, -- 5365
		p, -- 5365
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5365
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5365
	) -- 5365
	local q = self.partner -- 5366
	if q.alive then -- 5366
		local childPartner = q.w == CHILD_W -- 5368
		drawFigure( -- 5369
			draw, -- 5369
			self, -- 5369
			w, -- 5369
			h, -- 5369
			q, -- 5369
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5369
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5369
		) -- 5369
	end -- 5369
	local i = 0 -- 5371
	do -- 5371
		i = 0 -- 5372
		while i < #self.enemies do -- 5372
			local e = self.enemies[i + 1] -- 5373
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5374
			local enemyY = e.y + (e.depth or 0) -- 5375
			self:drawBox( -- 5376
				draw, -- 5376
				w, -- 5376
				h, -- 5376
				e.x - e.w / 2, -- 5376
				e.x + e.w / 2, -- 5376
				enemyY, -- 5376
				enemyY + e.h, -- 5376
				col -- 5376
			) -- 5376
			if e.alive then -- 5376
				local ef = p.x >= e.x and 1 or -1 -- 5378
				if e.kind == "shield" then -- 5378
					local sh = (e.shieldHp or 0) > 0 -- 5380
					draw:drawRect( -- 5381
						Rect( -- 5381
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5381
							self:sy(enemyY, h), -- 5381
							self:px(6), -- 5381
							self:px(64) -- 5381
						), -- 5381
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5382
					) -- 5382
				elseif e.kind == "breaker" then -- 5382
					draw:drawSegment( -- 5384
						Vec2( -- 5384
							self:sx(e.x + ef * 12, w), -- 5384
							self:sy(enemyY + 8, h) -- 5384
						), -- 5384
						Vec2( -- 5385
							self:sx(e.x + ef * 22, w), -- 5385
							self:sy(enemyY + 46, h) -- 5385
						), -- 5385
						self:px(3), -- 5385
						Color(0.5, 0.36, 0.22, 1) -- 5385
					) -- 5385
				end -- 5385
			end -- 5385
			if e.alive and e.warnT > 0 then -- 5385
				local gunX = self:sx(e.x, w) -- 5390
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5391
				local aimX = self:sx(p.x, w) -- 5392
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5393
				local seg = 8 -- 5394
				local s = 0 -- 5395
				do -- 5395
					s = 0 -- 5396
					while s < seg do -- 5396
						local t0 = s / seg -- 5397
						local t1 = (s + 1) / seg -- 5398
						draw:drawSegment( -- 5399
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5400
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5401
							self:px(1), -- 5402
							DANGER -- 5402
						) -- 5402
						s = s + 2 -- 5396
					end -- 5396
				end -- 5396
			end -- 5396
			i = i + 1 -- 5372
		end -- 5372
	end -- 5372
	local k = 0 -- 5407
	do -- 5407
		k = 0 -- 5408
		while k < #self.room.marks do -- 5408
			do -- 5408
				local m = self.room.marks[k + 1] -- 5409
				if m.kind ~= 0 then -- 5409
					goto __continue990 -- 5411
				end -- 5411
				local on = self.checkpoint == m.x -- 5413
				local x = self:sx(m.x, w) -- 5414
				local y = self:sy(m.y, h) -- 5415
				draw:drawSegment( -- 5416
					Vec2(x, y), -- 5416
					Vec2( -- 5416
						x, -- 5416
						y + self:px(35) -- 5416
					), -- 5416
					self:px(1), -- 5416
					on and CHECK or INK_DIM -- 5416
				) -- 5416
				draw:drawDot( -- 5417
					Vec2( -- 5417
						x, -- 5417
						y + self:px(35) -- 5417
					), -- 5417
					self:px(2), -- 5417
					on and CHECK or INK_DIM -- 5417
				) -- 5417
			end -- 5417
			::__continue990:: -- 5417
			k = k + 1 -- 5408
		end -- 5408
	end -- 5408
	local j = 0 -- 5421
	do -- 5421
		j = 0 -- 5422
		while j < #self.room.marks do -- 5422
			do -- 5422
				local m = self.room.marks[j + 1] -- 5423
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5423
					goto __continue993 -- 5425
				end -- 5425
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5425
					goto __continue993 -- 5429
				end -- 5429
				local col = STAND -- 5431
				if m.kind == 4 then -- 5431
					col = PASS_LINE -- 5433
				elseif m.kind == 5 then -- 5433
					col = BRICK_LINE -- 5435
				end -- 5435
				local mx = self:sx(m.x, w) -- 5437
				local my = self:sy(m.y, h) -- 5438
				draw:drawSegment( -- 5439
					Vec2(mx, my), -- 5439
					Vec2( -- 5439
						mx, -- 5439
						my + self:px(24) -- 5439
					), -- 5439
					self:px(1), -- 5439
					col -- 5439
				) -- 5439
			end -- 5439
			::__continue993:: -- 5439
			j = j + 1 -- 5422
		end -- 5422
	end -- 5422
	local t = 0 -- 5442
	do -- 5442
		t = 0 -- 5443
		while t < #self.room.marks do -- 5443
			do -- 5443
				local m = self.room.marks[t + 1] -- 5444
				if m.kind ~= 6 then -- 5444
					goto __continue999 -- 5446
				end -- 5446
				local mx = self:sx(m.x, w) -- 5448
				local my = self:sy(m.y, h) -- 5449
				draw:drawSegment( -- 5450
					Vec2(mx, my), -- 5450
					Vec2( -- 5450
						mx, -- 5450
						my + self:px(30) -- 5450
					), -- 5450
					self:px(1), -- 5450
					INK_DIM -- 5450
				) -- 5450
				self:drawBox( -- 5451
					draw, -- 5451
					w, -- 5451
					h, -- 5451
					m.x - 5, -- 5451
					m.x + 5, -- 5451
					m.y + 30, -- 5451
					m.y + 40, -- 5451
					CHECK -- 5451
				) -- 5451
			end -- 5451
			::__continue999:: -- 5451
			t = t + 1 -- 5443
		end -- 5443
	end -- 5443
	if self.room.key == "village" then -- 5443
		self:drawVillage(draw, w, h) -- 5454
	end -- 5454
	if self.room.key == "forest" then -- 5454
		self:drawDog(draw, w, h) -- 5457
	end -- 5457
end -- 5351
function Play.prototype.drawDog(self, draw, w, h) -- 5462
	local x = self.dogX -- 5463
	self:drawBox( -- 5464
		draw, -- 5464
		w, -- 5464
		h, -- 5464
		x - 14, -- 5464
		x + 14, -- 5464
		0, -- 5464
		20, -- 5464
		SCAV_BODY -- 5464
	) -- 5464
	self:drawBox( -- 5465
		draw, -- 5465
		w, -- 5465
		h, -- 5465
		x - 10, -- 5465
		x - 2, -- 5465
		20, -- 5465
		30, -- 5465
		SCAV_BODY -- 5465
	) -- 5465
	self:drawBox( -- 5466
		draw, -- 5466
		w, -- 5466
		h, -- 5466
		x + 2, -- 5466
		x + 10, -- 5466
		20, -- 5466
		30, -- 5466
		SCAV_HEAD -- 5466
	) -- 5466
	if self.dogState == "ear" or self.dogState == "chase" then -- 5466
		draw:drawSegment( -- 5468
			Vec2( -- 5468
				self:sx(x, w), -- 5468
				self:sy(30, h) -- 5468
			), -- 5468
			Vec2( -- 5469
				self:sx(x, w), -- 5469
				self:sy(40, h) -- 5469
			), -- 5469
			self:px(1), -- 5469
			DANGER -- 5469
		) -- 5469
	end -- 5469
end -- 5462
function Play.prototype.drawVillage(self, draw, w, h) -- 5474
	local bottle = self.room.bottle -- 5475
	if bottle ~= nil then -- 5475
		self:drawBox( -- 5477
			draw, -- 5477
			w, -- 5477
			h, -- 5477
			bottle.x - 14, -- 5477
			bottle.x + 14, -- 5477
			0, -- 5477
			64, -- 5477
			SOLID_FILL -- 5477
		) -- 5477
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5477
			self:drawBottle( -- 5479
				draw, -- 5479
				w, -- 5479
				h, -- 5479
				bottle.x, -- 5479
				64 -- 5479
			) -- 5479
		end -- 5479
	end -- 5479
	self:drawBox( -- 5483
		draw, -- 5483
		w, -- 5483
		h, -- 5483
		300, -- 5483
		420, -- 5483
		44, -- 5483
		50, -- 5483
		FLOOR_DECK -- 5483
	) -- 5483
	self:drawBox( -- 5484
		draw, -- 5484
		w, -- 5484
		h, -- 5484
		300, -- 5484
		306, -- 5484
		0, -- 5484
		44, -- 5484
		FLOOR_DECK -- 5484
	) -- 5484
	self:drawBox( -- 5485
		draw, -- 5485
		w, -- 5485
		h, -- 5485
		414, -- 5485
		420, -- 5485
		0, -- 5485
		44, -- 5485
		FLOOR_DECK -- 5485
	) -- 5485
	local s = self.room.scavenger -- 5487
	if s ~= nil then -- 5487
		local sx0 = self.scavX -- 5489
		self:drawBox( -- 5490
			draw, -- 5490
			w, -- 5490
			h, -- 5490
			sx0 - 12, -- 5490
			sx0 + 12, -- 5490
			0, -- 5490
			s.h - 14, -- 5490
			SCAV_BODY -- 5490
		) -- 5490
		self:drawBox( -- 5491
			draw, -- 5491
			w, -- 5491
			h, -- 5491
			sx0 - 7, -- 5491
			sx0 + 7, -- 5491
			s.h - 14, -- 5491
			s.h, -- 5491
			SCAV_HEAD -- 5491
		) -- 5491
		if self.scavState == "turn" then -- 5491
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5493
			draw:drawSegment( -- 5494
				Vec2( -- 5494
					self:sx(sx0, w), -- 5494
					self:sy(s.h - 6, h) -- 5494
				), -- 5494
				Vec2( -- 5494
					self:sx(fx, w), -- 5494
					self:sy(s.h - 6, h) -- 5494
				), -- 5494
				self:px(1), -- 5494
				INK -- 5494
			) -- 5494
		end -- 5494
	end -- 5494
	if self.hasBottle then -- 5494
		local p = self.player -- 5499
		self:drawBottle( -- 5500
			draw, -- 5500
			w, -- 5500
			h, -- 5500
			p.x + p.facing * 10, -- 5500
			p.y + p.h * 0.62 -- 5500
		) -- 5500
	end -- 5500
	if self.bottleFly ~= nil then -- 5500
		self:drawBottle( -- 5503
			draw, -- 5503
			w, -- 5503
			h, -- 5503
			self.bottleFly.x, -- 5503
			self.bottleFly.y -- 5503
		) -- 5503
	end -- 5503
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5503
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5506
		draw:drawCircle( -- 5507
			Vec2( -- 5507
				self:sx(self.bottleLandX, w), -- 5507
				self:sy(0, h) -- 5507
			), -- 5507
			self:px(r / ____exports.UNITS_PER_PX), -- 5507
			BRICK_LINE -- 5507
		) -- 5507
	end -- 5507
end -- 5474
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5511
	self:drawBox( -- 5512
		draw, -- 5512
		w, -- 5512
		h, -- 5512
		x - 3, -- 5512
		x + 3, -- 5512
		y - 10, -- 5512
		y, -- 5512
		BOTTLE -- 5512
	) -- 5512
end -- 5511
function Play.prototype.drawTrace(self, draw, w, h) -- 5515
	local t = self.trace -- 5516
	if t == nil or self.traceT <= 0 then -- 5516
		return -- 5518
	end -- 5518
	draw:drawSegment( -- 5520
		Vec2( -- 5521
			self:sx(t.x0, w), -- 5521
			self:sy(t.y0, h) -- 5521
		), -- 5521
		Vec2( -- 5522
			self:sx(t.x1, w), -- 5522
			self:sy(t.y1, h) -- 5522
		), -- 5522
		self:px(1), -- 5523
		t.hit and AIM_HIT or INK_DIM -- 5523
	) -- 5523
end -- 5515
function Play.prototype.drawAim(self, draw, w, h) -- 5526
	local v = self.view -- 5528
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5529
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5530
	local dot = self:px(1) -- 5531
	local arm = self:px(3) -- 5532
	local gap = self:px(1) -- 5533
	draw:drawSegment( -- 5534
		Vec2(gx - arm - gap, gy), -- 5534
		Vec2(gx - gap, gy), -- 5534
		dot / 2, -- 5534
		AIM -- 5534
	) -- 5534
	draw:drawSegment( -- 5535
		Vec2(gx + gap, gy), -- 5535
		Vec2(gx + arm + gap, gy), -- 5535
		dot / 2, -- 5535
		AIM -- 5535
	) -- 5535
	draw:drawSegment( -- 5536
		Vec2(gx, gy - arm - gap), -- 5536
		Vec2(gx, gy - gap), -- 5536
		dot / 2, -- 5536
		AIM -- 5536
	) -- 5536
	draw:drawSegment( -- 5537
		Vec2(gx, gy + gap), -- 5537
		Vec2(gx, gy + arm + gap), -- 5537
		dot / 2, -- 5537
		AIM -- 5537
	) -- 5537
	if self.room.key == "village" and self.hasBottle then -- 5537
		local p = self.player -- 5541
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5543
		local dir = ____end.x >= p.x and 1 or -1 -- 5544
		local x0 = p.x + dir * 10 -- 5545
		local y0 = p.y + p.h * 0.7 -- 5546
		local T = BOTTLE_FLY_TIME -- 5547
		local vx = (____end.x - x0) / T -- 5548
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5549
		local pxr = x0 -- 5550
		local pyr = y0 -- 5551
		local t = 1 -- 5552
		do -- 5552
			t = 1 -- 5553
			while t <= 12 do -- 5553
				local tt = t / 12 * T -- 5554
				local nx = x0 + vx * tt -- 5555
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5556
				draw:drawSegment( -- 5557
					Vec2( -- 5557
						self:sx(pxr, w), -- 5557
						self:sy(pyr, h) -- 5557
					), -- 5557
					Vec2( -- 5557
						self:sx(nx, w), -- 5557
						self:sy(ny, h) -- 5557
					), -- 5557
					self:px(1) / 2, -- 5557
					BOTTLE -- 5557
				) -- 5557
				pxr = nx -- 5558
				pyr = ny -- 5559
				t = t + 1 -- 5553
			end -- 5553
		end -- 5553
		draw:drawCircle( -- 5561
			Vec2( -- 5561
				self:sx(____end.x, w), -- 5561
				self:sy(____end.y + 2, h) -- 5561
			), -- 5561
			self:px(2), -- 5561
			BOTTLE -- 5561
		) -- 5561
	end -- 5561
end -- 5526
return ____exports -- 5526