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
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
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
function makeActor(room, index) -- 5382
	local sp = room.spawns -- 5383
	if index < 0 or index >= #sp then -- 5383
		return { -- 5385
			x = 0, -- 5385
			y = 0, -- 5385
			depth = 0, -- 5385
			depthSpeed = 0, -- 5385
			vx = 0, -- 5385
			vy = 0, -- 5385
			w = CHILD_W, -- 5385
			h = CHILD_H, -- 5385
			onGround = true, -- 5385
			facing = 1, -- 5385
			crouch = false, -- 5385
			rollT = 0, -- 5385
			covered = false, -- 5385
			alive = false -- 5385
		} -- 5385
	end -- 5385
	local s = sp[index + 1] -- 5387
	local child = s.h <= CHILD_H -- 5388
	local ground = room.depth -- 5389
	local depth = ground == nil and 0 or math.max( -- 5390
		ground.min, -- 5390
		math.min(ground.max, s.depth or 0) -- 5390
	) -- 5390
	return { -- 5391
		x = s.x, -- 5392
		y = s.y, -- 5392
		depth = depth, -- 5392
		depthSpeed = 0, -- 5392
		vx = 0, -- 5392
		vy = 0, -- 5392
		w = child and CHILD_W or SOLDIER_W, -- 5393
		h = child and CHILD_H or SOLDIER_H, -- 5394
		onGround = true, -- 5395
		facing = 1, -- 5395
		crouch = false, -- 5395
		rollT = 0, -- 5395
		covered = false, -- 5395
		alive = true -- 5395
	} -- 5395
end -- 5395
function drawFigure(draw, play, w, h, a, body, head) -- 5399
	if not a.alive then -- 5399
		return -- 5401
	end -- 5401
	local x0 = a.x - a.w / 2 -- 5403
	local x1 = a.x + a.w / 2 -- 5404
	local y0 = a.y + a.depth -- 5405
	local y1 = y0 + a.h -- 5406
	play:drawBox( -- 5407
		draw, -- 5407
		w, -- 5407
		h, -- 5407
		x0, -- 5407
		x1, -- 5407
		y0, -- 5407
		y1 - a.h * 0.26, -- 5407
		body -- 5407
	) -- 5407
	play:drawBox( -- 5408
		draw, -- 5408
		w, -- 5408
		h, -- 5408
		x0 + 2, -- 5408
		x1 - 2, -- 5408
		y1 - a.h * 0.26, -- 5408
		y1, -- 5408
		head -- 5408
	) -- 5408
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5410
	play:drawBox( -- 5411
		draw, -- 5411
		w, -- 5411
		h, -- 5411
		eyeX, -- 5411
		eyeX + 4, -- 5411
		y1 - a.h * 0.14, -- 5411
		y1 - a.h * 0.08, -- 5411
		INK -- 5411
	) -- 5411
end -- 5411
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5415
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5416
end -- 5415
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5423
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5424
end -- 5423
function rayInterval(origin, direction, min, max) -- 5431
	if direction == 0 then -- 5431
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5433
	end -- 5433
	local a = (min - origin) / direction -- 5435
	local b = (max - origin) / direction -- 5436
	return { -- 5437
		min = math.min(a, b), -- 5437
		max = math.max(a, b) -- 5437
	} -- 5437
end -- 5437
function hitBox(ray, box) -- 5441
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5442
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5443
	local enter = math.max(0, x.min, y.min) -- 5444
	local leave = math.min(99999, x.max, y.max) -- 5445
	if box.depth ~= nil then -- 5445
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5447
		enter = math.max(enter, depth.min) -- 5448
		leave = math.min(leave, depth.max) -- 5449
	end -- 5449
	return leave >= enter and enter or -1 -- 5451
end -- 5451
function drawCartShape(draw, play, w, h, c, axleX) -- 5454
	local half = c.bodyW / 2 -- 5455
	local x0 = axleX - half -- 5456
	local x1 = axleX + half -- 5457
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5458
	play:drawBox( -- 5459
		draw, -- 5459
		w, -- 5459
		h, -- 5459
		x0, -- 5459
		x1, -- 5459
		axleY, -- 5459
		axleY + c.bodyH, -- 5459
		CART_FILL -- 5459
	) -- 5459
	draw:drawCircle( -- 5460
		Vec2( -- 5460
			play:sx(x0 + c.bodyW * 0.28, w), -- 5460
			play:sy(axleY, h) -- 5460
		), -- 5460
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5460
		Color(52, 50, 48, 255) -- 5460
	) -- 5460
	draw:drawCircle( -- 5461
		Vec2( -- 5461
			play:sx(x1 - c.bodyW * 0.28, w), -- 5461
			play:sy(axleY, h) -- 5461
		), -- 5461
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5461
		Color(52, 50, 48, 255) -- 5461
	) -- 5461
	local cx = c.clothSide < 0 and x0 or x1 -- 5462
	play:drawBox( -- 5463
		draw, -- 5463
		w, -- 5463
		h, -- 5463
		cx - 10, -- 5463
		cx + 10, -- 5463
		axleY + c.bodyH, -- 5463
		axleY + c.bodyH + 18, -- 5463
		CLOTH -- 5463
	) -- 5463
end -- 5463
____exports.STEP = STEP -- 33
____exports.GRAVITY = 1000 -- 34
____exports.GATE_COUNT_END = 1440 -- 35
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 37
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 39
____exports.TOWER_CONFIRM_TICKS = 480 -- 40
local TOWER_REGISTER_TICKS = 180 -- 41
--- P01 黑场听父亲唤「小满」到睁眼落稳：4 秒 = 240 拍。
____exports.PROLOGUE_WAKE_TICKS = 240 -- 45
--- P02 门槛内墙上人影与瓷碗滚到脚边：2 秒 = 120 拍。
____exports.PROLOGUE_SHADOW_TICKS = 120 -- 47
--- 限时逃柜：7.5 秒 = 450 拍；超时退回门口重来，不扣血。
____exports.PROLOGUE_ESCAPE_TICKS = 450 -- 49
--- 入柜后红晕收尽、柜外脚步渐远：0.85 秒 = 51 拍。
____exports.PROLOGUE_HIDE_TICKS = 51 -- 51
--- 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。
____exports.PROLOGUE_CABINET_X = 132 -- 53
function ____exports.gateCountAtTick(tick) -- 55
	if tick >= ____exports.GATE_COUNT_END then -- 55
		return 20 -- 56
	end -- 56
	if tick >= 1260 then -- 56
		return 19 -- 57
	end -- 57
	if tick >= 1080 then -- 57
		return 18 -- 58
	end -- 58
	if tick >= 480 then -- 58
		return 11 + math.floor((tick - 480) * 7 / 600) -- 59
	end -- 59
	return 1 + math.floor(math.max(0, tick) / 48) -- 60
end -- 55
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 63
CHILD_W = 28 -- 137
CHILD_H = 64 -- 138
local CHILD_CROUCH_H = 36 -- 139
local CHILD_SPEED = 160 -- 140
local CHILD_SLOW = 80 -- 141
local CHILD_JUMP = 320 -- 142
SOLDIER_W = 30 -- 145
SOLDIER_H = 88 -- 146
local SOLDIER_SPEED = 264 -- 147
local ROLL_TIME = 0.35 -- 148
local ROLL_SPEED = 280 -- 149
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 151
local LEDGE_RISE = 60 -- 152
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 155
____exports.LOGIC_H = 180 -- 156
____exports.UNITS_PER_PX = 2 -- 157
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 159
local CAM_FOLLOW = 9 -- 160
local CAM_LOOK_UP = 46 -- 161
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 164
--- 握把触发半径。
____exports.CART_REACH = 70 -- 166
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 168
local CART_CLEAR = 44 -- 169
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 171
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 173
local CONSUMABLE_CAP = 1 -- 174
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 176
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 178
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 180
local FIRE_COOLDOWN = 150 -- 181
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 183
local ENEMY_RANGE = 760 -- 184
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 186
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 188
local DEPTH_SPEED_RATIO = 0.55 -- 189
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 190
INK = Color(232, 232, 228, 255) -- 192
local INK_DIM = Color(150, 152, 150, 255) -- 193
local BG_VOID = Color(8, 9, 10, 255) -- 194
local BG_FAR = Color(24, 26, 28, 255) -- 195
local BG_MID = Color(31, 34, 37, 255) -- 196
local GROUND = Color(112, 114, 112, 255) -- 197
local FLOOR_DECK = Color(66, 70, 72, 255) -- 198
local SOLID_FILL = Color(84, 86, 84, 255) -- 199
local SOLID_EDGE = Color(126, 130, 126, 255) -- 200
CART_FILL = Color(122, 78, 56, 255) -- 201
CLOTH = Color(178, 52, 46, 255) -- 202
local DANGER = Color(150, 54, 48, 46) -- 203
local DANGER_LINE = Color(178, 78, 64, 200) -- 204
local HOLE_FILL = Color(10, 11, 12, 255) -- 205
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 206
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 207
local CHILD_BODY = Color(214, 168, 96, 255) -- 208
local CHILD_HEAD = Color(232, 214, 186, 255) -- 209
local ENEMY_BODY = Color(176, 92, 84, 255) -- 210
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 211
local CHECK = Color(96, 186, 122, 255) -- 212
local STAND = Color(226, 186, 84, 255) -- 213
local AIM = Color(236, 236, 232, 230) -- 214
local AIM_HIT = Color(236, 96, 84, 255) -- 215
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 217
local SOFT_LINE = Color(140, 112, 80, 190) -- 218
local BRICK = Color(126, 118, 110, 70) -- 219
local BRICK_LINE = Color(160, 152, 142, 200) -- 220
local PASS = Color(96, 186, 122, 40) -- 221
local PASS_LINE = Color(96, 186, 122, 200) -- 222
local BOTTLE = Color(120, 186, 160, 255) -- 223
local SCAV_BODY = Color(128, 118, 96, 255) -- 224
local SCAV_HEAD = Color(196, 182, 158, 255) -- 225
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 312
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 313
	if zoom < 1 then -- 313
		zoom = 1 -- 315
	end -- 315
	return { -- 317
		zoom = zoom, -- 318
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 319
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 320
	} -- 320
end -- 312
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 343
	if key == "prologue" then -- 343
		return "prologue-wait" -- 347
	end -- 347
	if key == "street" then -- 347
		return "street-run" -- 350
	end -- 350
	if key == "gate" then -- 350
		return "gate-idle" -- 353
	end -- 353
	if key == "gatepath" then -- 353
		return "gatepath-start" -- 356
	end -- 356
	if key == "forest" then -- 356
		return "forest-run" -- 359
	end -- 359
	if key == "tower" then -- 359
		return "tower-wait" -- 362
	end -- 362
	if key == "museum" then -- 362
		return "museum-cabinet" -- 365
	end -- 365
	return "run" -- 367
end -- 343
____exports.Play = __TS__Class() -- 370
local Play = ____exports.Play -- 370
Play.name = "Play" -- 370
function Play.prototype.____constructor(self, room, resume, run) -- 630
	self.enemies = {} -- 375
	self.boxes = {} -- 376
	self.floors = {} -- 377
	self.checkpoint = -1 -- 379
	self.flash = "" -- 381
	self.flashT = 0 -- 382
	self.traceT = 0 -- 385
	self.focusCart = false -- 387
	self.knocks = 0 -- 389
	self.knockT = 0 -- 390
	self.cartAxle = 0 -- 394
	self.cartDocked = false -- 396
	self.gripping = false -- 398
	self.gateOpen = false -- 400
	self.calmConsumed = false -- 402
	self.craftT = 0 -- 404
	self.nextDangerId = 1 -- 406
	self.wantRoom = "" -- 408
	self.carryCartAxle = -1 -- 410
	self.carryCartDocked = false -- 411
	self.checkpointCartAxle = -1 -- 413
	self.hasBottle = false -- 417
	self.bottleLandX = -1 -- 421
	self.bottleTargetX = -1 -- 422
	self.bottleTargetY = 0 -- 423
	self.bottleLandT = 0 -- 424
	self.aimHold = 0 -- 426
	self.scavX = 0 -- 428
	self.scavDir = 1 -- 429
	self.scavState = "patrol" -- 430
	self.scavT = 0 -- 431
	self.scavTargetX = 0 -- 432
	self.passed = false -- 434
	self.childMode = false -- 438
	self.phase = "" -- 440
	self.phaseTick = 0 -- 442
	self.gateTick = 0 -- 444
	self.countTick = 0 -- 446
	self.countArmed = false -- 448
	self.countPrevMove = 0 -- 450
	self.caughtT = 0 -- 452
	self.hp = 3 -- 454
	self.maxHp = 3 -- 455
	self.invulnT = 0 -- 461
	self.partnerStuck = 0 -- 463
	self.partnerLaneIdx = 0 -- 465
	self.partnerLaneHold = 0 -- 466
	self.coveredFlash = 0 -- 468
	self.coverHug = false -- 470
	self.coverNear = false -- 472
	self.coverEntity = "" -- 474
	self.coverBlocking = false -- 476
	self.gateNeedConfirm = false -- 478
	self.gateRestartArmed = true -- 480
	self.bottleAimX = -1 -- 482
	self.bottleAimY = 0 -- 483
	self.bottleSurfaceY = -1 -- 485
	self.bottleLandY = 0 -- 487
	self.events = {} -- 489
	self.eventSeq = 0 -- 491
	self.dogX = 0 -- 493
	self.dogDir = 1 -- 494
	self.dogState = "patrol" -- 495
	self.dogT = 0 -- 496
	self.dogTargetX = 0 -- 497
	self.scavSee = 0 -- 499
	self.scavChase = false -- 500
	self.gateSpawned = 0 -- 502
	self.gateFailCount = 0 -- 504
	self.isCampaign = false -- 508
	self.archiveDirty = false -- 516
	self.restartStory = false -- 518
	self.wellOpen = false -- 520
	self.wellX = 430 -- 522
	self.wellTaken = false -- 524
	self.museumReturn = false -- 526
	self.endingLines = {"", ""} -- 528
	self.equippedWeapon = "standard_gun" -- 532
	self.craftBench = { -- 534
		active = false, -- 535
		firstCraftDone = false, -- 536
		justCraftedTimer = 0, -- 537
		inventory = {}, -- 538
		recipes = {}, -- 539
		equippedWeapon = "standard_gun" -- 540
	} -- 540
	self.handledCraftRequests = {} -- 543
	self.benchReach = 48 -- 545
	self.pickups = {} -- 549
	self.reloadT = 0 -- 551
	self.objectiveDone = false -- 555
	self.hint = "" -- 557
	self.roomStartTick = 0 -- 559
	self.cartHitT = 0 -- 561
	self.cartExposed = false -- 562
	self.storyRoute = "" -- 566
	self.storySettled = false -- 568
	self.hpAtGate = -1 -- 570
	self.maxHpAtGate = -1 -- 571
	self.handTicks = 0 -- 573
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 575
	self.handArmed = false -- 577
	self.handDone = false -- 579
	self.lineSaid = false -- 580
	self.tied = false -- 582
	self.pathDone = false -- 584
	self.carryOn = false -- 586
	self.escortDone = false -- 588
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 592
	self.escapeRemaining = 0 -- 594
	self.escapeRetryCount = 0 -- 596
	self.introTick = 0 -- 598
	self.reloadOpen = false -- 602
	self.reloadAnswerTicks = 0 -- 604
	self.reloadWorldTicks = 0 -- 606
	self.reloadPath = {RELOAD_START} -- 608
	self.reloadPendingEffect = "" -- 610
	self.reloadTryCount = 0 -- 612
	self.paused = false -- 614
	self.ticks = 0 -- 616
	self.view = {zoom = 1, ox = 0, oy = 0} -- 618
	self.ox = 0 -- 620
	self.aimX = 0 -- 622
	self.aimY = 0 -- 623
	self.viewW = 0 -- 625
	self.viewH = 0 -- 626
	self.ox = room.originX -- 632
	self.room = withOrigin(room) -- 633
	local wr = self.room -- 634
	self.run = run or createRun() -- 635
	self.inventory = self.run.inventory -- 636
	self.archive = self.run.archive -- 637
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 638
	self.isCampaign = wr.campaign ~= nil -- 639
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 640
	self:buildWorld() -- 641
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 644
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 646
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 647
	local soloRoom = wr.key == "museum" -- 649
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 650
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 651
	self.player = makeActor(wr, playerIdx) -- 652
	self.partner = makeActor(wr, partnerIdx) -- 653
	self.phase = phaseOf(wr.key) -- 654
	if soloRoom then -- 654
		local mp = self.archive.museumPhase -- 657
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 658
	end -- 658
	if wr.story ~= nil then -- 658
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 664
	end -- 664
	self.cam.x = self.player.x -- 666
	self.cam.y = self.player.y + CAM_LOOK_UP -- 667
	self.cartAxle = wr.cart.startX -- 668
	self.escort = __TS__New( -- 669
		Escort, -- 669
		safeAnchorX(wr.marks) -- 669
	) -- 669
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 670
	if self.isCampaign then -- 670
		self:setupCampaign() -- 672
	else -- 672
		self:buildEnemies() -- 674
	end -- 674
	if resume ~= nil and resume.checkpoint > 0 then -- 674
		self.checkpoint = resume.checkpoint -- 678
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 678
			self.cartAxle = self.room.cart.endX -- 680
			self.cartDocked = true -- 681
			self.player.x = self.ox + 380 -- 684
			self.player.y = 0 -- 685
			self.player.vy = 0 -- 686
			self.player.onGround = true -- 687
			self.cam.x = self.player.x -- 688
			self.cam.y = self.player.y + CAM_LOOK_UP -- 689
		end -- 689
	end -- 689
	self:restoreStory() -- 692
end -- 630
function Play.prototype.recipeViews(self) -- 705
	local out = {} -- 706
	local i = 0 -- 707
	do -- 707
		i = 0 -- 708
		while i < #CRAFT_RECIPES do -- 708
			local r = CRAFT_RECIPES[i + 1] -- 709
			local cost = {} -- 710
			if r.cost.wood ~= nil then -- 710
				cost.wood = r.cost.wood -- 712
			end -- 712
			if r.cost.bell ~= nil then -- 712
				cost.bell = r.cost.bell -- 715
			end -- 715
			out[#out + 1] = { -- 717
				id = r.id, -- 718
				name = r.name, -- 719
				desc = r.desc, -- 720
				enhancedEffect = r.enhancedEffect, -- 721
				cost = cost, -- 722
				crafted = self.run.story.craftedWeapon == r.id -- 723
			} -- 723
			i = i + 1 -- 708
		end -- 708
	end -- 708
	return out -- 726
end -- 705
function Play.prototype.syncCraftBench(self) -- 730
	local view = self.craftBench -- 731
	local inv = self.run.inventory -- 732
	view.inventory = { -- 733
		wood = inv.wood, -- 733
		bell = inv.bell, -- 733
		scrap = inv.scrap, -- 733
		wedge = inv.wedge, -- 733
		ammo = inv.ammo -- 733
	} -- 733
	view.recipes = self:recipeViews() -- 734
	view.equippedWeapon = self.equippedWeapon -- 735
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 736
	if view.justCraftedTimer > 0 then -- 736
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 738
	end -- 738
end -- 730
function Play.prototype.openCraftBench(self) -- 743
	if self.room.key ~= "escort3" or self.craftBench.active then -- 743
		return -- 745
	end -- 745
	self.craftBench.active = true -- 747
	self.carryOn = false -- 748
	self.run.story.carry = false -- 749
	self.player.vx = 0 -- 750
	self.player.vy = 0 -- 751
	self.craftBench.justCraftedTimer = 0 -- 752
	self:syncCraftBench() -- 753
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 754
	self:log("开工台") -- 755
	self:emit( -- 756
		"benchOpen", -- 756
		{ -- 756
			recipes = __TS__ArrayMap( -- 757
				self.craftBench.recipes, -- 757
				function(____, r) return r.id end -- 757
			), -- 757
			inventory = self.craftBench.inventory, -- 758
			carry = self.carryOn -- 759
		} -- 759
	) -- 759
end -- 743
function Play.prototype.closeCraftBench(self) -- 764
	if not self.craftBench.active then -- 764
		return -- 766
	end -- 766
	self.craftBench.active = false -- 768
	self.craftBench.justCraftedTimer = 0 -- 769
	self.carryOn = true -- 770
	self.run.story.carry = true -- 771
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 772
	self:log("离站背起") -- 773
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 774
end -- 764
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 781
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 781
		return false -- 783
	end -- 783
	local recipe = findRecipe(recipeId) -- 785
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 785
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 787
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 788
		return false -- 789
	end -- 789
	local missing = missingMaterials(self.run.inventory, recipe) -- 791
	if #missing > 0 then -- 791
		self:flashSet( -- 793
			"缺料 · " .. table.concat(missing, " / "), -- 793
			1.6 -- 793
		) -- 793
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 794
		return false -- 795
	end -- 795
	payMaterials(self.run.inventory, recipe) -- 797
	self.handledCraftRequests[requestId] = true -- 798
	self.run.story.craftedWeapon = recipe.id -- 799
	self.equippedWeapon = recipe.id -- 800
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 801
	self.craftBench.firstCraftDone = true -- 802
	self:syncCraftBench() -- 803
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 804
	self:log("改制 " .. recipe.id) -- 805
	self:emit("benchCraft", { -- 806
		recipeId = recipe.id, -- 807
		weapon = recipe.id, -- 808
		effect = recipe.enhancedEffect, -- 809
		wood = self.run.inventory.wood, -- 810
		bell = self.run.inventory.bell -- 811
	}) -- 811
	return true -- 813
end -- 781
function Play.prototype.equipWeapon(self, weaponId) -- 817
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 817
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 819
		return false -- 820
	end -- 820
	self.equippedWeapon = weaponId -- 822
	self:syncCraftBench() -- 823
	self:flashSet( -- 824
		"已装备 " .. weaponNameOf(weaponId), -- 824
		1 -- 824
	) -- 824
	self:emit("benchEquip", {weapon = weaponId}) -- 825
	return true -- 826
end -- 817
function Play.prototype.submitFeIntent(self, intent) -- 833
	local kind = intent == nil and "" or intent.kind -- 834
	if kind == "reloadTapNode" then -- 834
		local node = intent.node -- 836
		if type(node) == "number" then -- 836
			self:reloadTapNode(node) -- 838
			return true -- 839
		end -- 839
		return false -- 841
	end -- 841
	if kind == "reloadPathCommit" then -- 841
		local path = intent.path -- 844
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 844
			local list = path -- 846
			local i = 0 -- 847
			do -- 847
				i = 0 -- 848
				while i < #list do -- 848
					do -- 848
						if i == 0 and list[i + 1] == RELOAD_START then -- 848
							goto __continue48 -- 850
						end -- 850
						self:reloadTapNode(list[i + 1]) -- 852
					end -- 852
					::__continue48:: -- 852
					i = i + 1 -- 848
				end -- 848
			end -- 848
			return true -- 854
		end -- 854
		return false -- 856
	end -- 856
	if kind == "reloadCancel" then -- 856
		self:closeReloadPuzzle() -- 859
		return true -- 860
	end -- 860
	if kind == "craftSubmit" then -- 860
		local recipeId = intent.recipeId -- 863
		local requestId = intent.requestId -- 864
		if type(recipeId) == "string" and type(requestId) == "string" then -- 864
			return self:craftAtBench(recipeId, requestId) -- 866
		end -- 866
		return false -- 868
	end -- 868
	if kind == "craftEquip" then -- 868
		local weaponId = intent.weaponId -- 871
		if type(weaponId) == "string" then -- 871
			return self:equipWeapon(weaponId) -- 873
		end -- 873
		return false -- 875
	end -- 875
	if kind == "craftClose" then -- 875
		self:closeCraftBench() -- 878
		return true -- 879
	end -- 879
	if kind == "wellPick" then -- 879
		return self:pickWell() -- 882
	end -- 882
	return false -- 884
end -- 833
function Play.prototype.captureCheckpoint(self, id) -- 888
	local inv = self.run.inventory -- 889
	self.checkpointSnap = { -- 890
		id = id, -- 891
		wood = inv.wood, -- 892
		bell = inv.bell, -- 893
		scrap = inv.scrap, -- 894
		wedge = inv.wedge, -- 895
		ammo = inv.ammo, -- 896
		shield = inv.shield, -- 897
		pass = inv.pass, -- 898
		quickbelt = inv.quickbelt, -- 899
		crafted = self.run.story.craftedWeapon, -- 900
		equipped = self.equippedWeapon, -- 901
		carry = self.carryOn -- 902
	} -- 902
	self.run.story.cp = self.checkpointSnap -- 904
end -- 888
function Play.prototype.applyCheckpointSnap(self, id) -- 908
	local snap = self.run.story.cp -- 909
	if snap == nil or snap.id ~= id then -- 909
		return false -- 911
	end -- 911
	self.checkpointSnap = snap -- 913
	local inv = self.run.inventory -- 914
	inv.wood = snap.wood -- 915
	inv.bell = snap.bell -- 916
	inv.scrap = snap.scrap -- 917
	inv.wedge = snap.wedge -- 918
	inv.ammo = snap.ammo -- 919
	inv.shield = snap.shield -- 920
	inv.pass = snap.pass -- 921
	inv.quickbelt = snap.quickbelt -- 922
	self.run.story.craftedWeapon = snap.crafted -- 923
	self.equippedWeapon = snap.equipped -- 924
	self.carryOn = snap.carry -- 925
	self.run.story.carry = snap.carry -- 926
	self.craftBench.active = false -- 927
	self:syncCraftBench() -- 928
	return true -- 929
end -- 908
function Play.prototype.restoreStory(self) -- 932
	if self.isCampaign and self.run.trial ~= nil then -- 932
		return -- 936
	end -- 936
	local story = self.run.story -- 938
	if story == nil then -- 938
		return -- 940
	end -- 940
	if story.maxHp > 0 then -- 940
		self.maxHp = story.maxHp -- 943
		self.hp = math.max( -- 944
			1, -- 944
			math.min(story.hp, story.maxHp) -- 944
		) -- 944
	end -- 944
	self.storyRoute = story.route -- 946
	self.storySettled = story.settled -- 947
	self.hpAtGate = story.hpAtGate -- 948
	self.maxHpAtGate = story.maxHpAtGate -- 949
	self.handDone = story.handDone -- 950
	self.lineSaid = story.lineSaid -- 951
	self.tied = story.handDone -- 952
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 953
	self.museumReturn = story.museumReturn -- 954
	story.museumReturn = false -- 955
	self.escortDone = story.escortDone -- 956
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 957
	self:syncCraftBench() -- 958
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 958
		self:applyCheckpointSnap(self.checkpoint) -- 961
	end -- 961
	if self.room.key == "tower" and story.route == "soldier" then -- 961
		self.carryOn = false -- 965
		self.run.story.carry = false -- 966
	end -- 966
	if self.room.key == "prologue" then -- 966
		local ph = story.phase -- 970
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 970
			self.phase = ph -- 972
			self.phaseTick = story.phaseTick -- 973
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 974
			self.player.y = 0 -- 975
			self.player.depth = 0 -- 976
			self.player.vx = 0 -- 977
			self.partner.x = self.ox + 300 -- 978
			self.partner.y = 0 -- 979
			self.partner.depth = 0 -- 980
			self.partner.vx = 0 -- 981
			self.partner.alive = true -- 982
			if ph == "prologue-follow" then -- 982
				self.partner.crouch = false -- 984
				self.partner.h = CHILD_H -- 985
			else -- 985
				self.partner.crouch = true -- 987
				self.partner.h = CHILD_CROUCH_H -- 988
			end -- 988
			self.cam.x = self.player.x -- 990
		end -- 990
		return -- 992
	end -- 992
	if self.room.key ~= "gate" then -- 992
		return -- 995
	end -- 995
	local ____temp_0 -- 997
	if self.room.story == nil then -- 997
		____temp_0 = nil -- 997
	else -- 997
		____temp_0 = self.room.story.gate -- 997
	end -- 997
	local g = ____temp_0 -- 997
	if g == nil then -- 997
		return -- 999
	end -- 999
	if story.phase == "gate-send" then -- 999
		self.phase = "gate-send" -- 1003
		self.gateTick = g.holdTicks -- 1004
		self.gateSpawned = 4 -- 1005
		self.enemies = {} -- 1006
		self.player.x = self.ox + g.doorX - 40 -- 1007
		self.player.y = 0 -- 1008
		self.player.depth = 0 -- 1009
		self.player.vx = 0 -- 1010
		self.player.vy = 0 -- 1011
		self.player.onGround = true -- 1012
		self.partner.x = self.ox + g.waitX -- 1013
		self.partner.y = 0 -- 1014
		self.partner.depth = 0 -- 1015
		self.partner.alive = true -- 1016
		self.cam.x = self.player.x -- 1017
		self.handTicks = 0 -- 1018
		self.handArmed = false -- 1019
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1020
		return -- 1021
	end -- 1021
	if not story.settled then -- 1021
		return -- 1024
	end -- 1024
	self.gateTick = g.holdTicks -- 1027
	self.gateSpawned = 4 -- 1028
	self.enemies = {} -- 1029
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1029
		self.phase = story.phase -- 1031
		self.countTick = math.max(story.countTick, 0) -- 1032
		self:swapToChild(g.doorX + 30) -- 1033
		self.countPrevMove = 0 -- 1034
		self.countArmed = false -- 1035
		return -- 1036
	end -- 1036
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1036
		self.phase = story.phase -- 1039
		self.countTick = ____exports.GATE_COUNT_END -- 1040
		self.phaseTick = story.phaseTick -- 1041
		self:swapToChild(g.doorX + 30) -- 1042
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1043
			0, -- 1043
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1043
		) -- 1043
		self.handArmed = false -- 1044
	end -- 1044
end -- 932
function Play.prototype.buildWorld(self) -- 1049
	local room = self.room -- 1050
	self.boxes = {} -- 1051
	self.floors = {} -- 1052
	local i = 0 -- 1053
	do -- 1053
		i = 0 -- 1054
		while i < #room.floors do -- 1054
			local f = room.floors[i + 1] -- 1055
			local ____self_floors_1 = self.floors -- 1055
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1056
			i = i + 1 -- 1054
		end -- 1054
	end -- 1054
	do -- 1054
		i = 0 -- 1058
		while i < #room.solids do -- 1058
			local s = room.solids[i + 1] -- 1059
			if not s.decorative then -- 1059
				local ____self_boxes_13 = self.boxes -- 1065
				local ____s_x_4 = s.x -- 1066
				local ____temp_5 = s.x + s.w -- 1066
				local ____s_y_6 = s.y -- 1066
				local ____temp_7 = s.y + s.h -- 1066
				local ____temp_2 -- 1067
				if room.depth == nil then -- 1067
					____temp_2 = nil -- 1067
				else -- 1067
					____temp_2 = s.depth -- 1067
				end -- 1067
				local ____temp_8 = s.passable == true -- 1068
				local ____s_label_9 = s.label -- 1068
				local ____s_id_10 = s.id -- 1069
				local ____temp_11 = s.soft == true -- 1069
				local ____temp_12 = s.hidden == true -- 1069
				local ____temp_3 -- 1070
				if s.breakable == nil then -- 1070
					____temp_3 = nil -- 1070
				else -- 1070
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1070
				end -- 1070
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1065
					x0 = ____s_x_4, -- 1066
					x1 = ____temp_5, -- 1066
					y0 = ____s_y_6, -- 1066
					y1 = ____temp_7, -- 1066
					depth = ____temp_2, -- 1067
					passable = ____temp_8, -- 1068
					label = ____s_label_9, -- 1068
					id = ____s_id_10, -- 1069
					soft = ____temp_11, -- 1069
					hidden = ____temp_12, -- 1069
					breakable = ____temp_3, -- 1070
					interact = s.interact -- 1071
				} -- 1071
			end -- 1071
			i = i + 1 -- 1058
		end -- 1058
	end -- 1058
	do -- 1058
		i = 0 -- 1075
		while i < #room.stairs do -- 1075
			local st = room.stairs[i + 1] -- 1076
			local n = st.steps + 1 -- 1077
			local stepW = (st.x1 - st.x0) / n -- 1078
			local k = 0 -- 1079
			do -- 1079
				k = 0 -- 1080
				while k < n do -- 1080
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1081
					local x0 = st.x0 + stepW * k -- 1082
					local ____self_boxes_14 = self.boxes -- 1082
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 1084
						x0 = x0, -- 1084
						x1 = x0 + stepW, -- 1084
						y0 = -8, -- 1084
						y1 = y, -- 1084
						passable = true -- 1084
					} -- 1084
					k = k + 1 -- 1080
				end -- 1080
			end -- 1080
			i = i + 1 -- 1075
		end -- 1075
	end -- 1075
end -- 1049
function Play.prototype.setupCampaign(self) -- 1093
	local wr = self.room -- 1094
	local c = wr.campaign -- 1095
	if c == nil then -- 1095
		return -- 1097
	end -- 1097
	self.roomStartTick = self.run.ticks -- 1099
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1099
		self.run.joined = true -- 1103
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1103
		local ____self_run_16 = self.run -- 1106
		local ____temp_15 -- 1106
		if wr.key == "s2-drygoods" then -- 1106
			____temp_15 = self.run.route ~= "drygoods" -- 1106
		else -- 1106
			____temp_15 = false -- 1106
		end -- 1106
		____self_run_16.joined = ____temp_15 -- 1106
	end -- 1106
	local x = wr.minX + 60 -- 1108
	local y = 0 -- 1109
	local depth = 0 -- 1110
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1110
		x = wr.minX + 210 -- 1112
		depth = -32 -- 1113
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1113
		x = wr.minX + 40 -- 1115
		y = 32 -- 1116
		depth = 32 -- 1117
	end -- 1117
	self.player = { -- 1119
		x = x, -- 1120
		y = y, -- 1120
		depth = depth, -- 1120
		depthSpeed = 0, -- 1120
		vx = 0, -- 1120
		vy = 0, -- 1120
		w = SOLDIER_W, -- 1121
		h = SOLDIER_H, -- 1121
		onGround = y <= 0, -- 1121
		facing = 1, -- 1121
		crouch = false, -- 1121
		rollT = 0, -- 1121
		covered = false, -- 1121
		alive = true -- 1121
	} -- 1121
	self.partner = { -- 1123
		x = x + 60, -- 1124
		y = y, -- 1124
		depth = depth, -- 1124
		depthSpeed = 0, -- 1124
		vx = 0, -- 1124
		vy = 0, -- 1124
		w = CHILD_W, -- 1125
		h = CHILD_H, -- 1125
		onGround = y <= 0, -- 1125
		facing = 1, -- 1125
		crouch = false, -- 1125
		rollT = 0, -- 1125
		covered = false, -- 1125
		alive = true -- 1125
	} -- 1125
	self.cam.x = x -- 1127
	self.cam.y = y + CAM_LOOK_UP -- 1128
	self.phase = "run" -- 1129
	self.hp = self.maxHp -- 1130
	local trial = self.run.trial -- 1131
	if trial ~= nil then -- 1131
		draftRoom(trial, wr.key) -- 1133
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1134
		self.hp = trial.hp -- 1135
	end -- 1135
	self:buildEnemies() -- 1137
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1138
	local i = 0 -- 1139
	do -- 1139
		i = 0 -- 1140
		while i < #self.boxes do -- 1140
			do -- 1140
				local b = self.boxes[i + 1] -- 1141
				if b.id == nil then -- 1141
					goto __continue94 -- 1143
				end -- 1143
				local st = self.run.props[b.id] -- 1145
				if st ~= nil then -- 1145
					b.broken = st.broken -- 1147
					local ____temp_17 -- 1148
					if b.breakable == nil then -- 1148
						____temp_17 = nil -- 1148
					else -- 1148
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1148
					end -- 1148
					b.breakable = ____temp_17 -- 1148
					b.hidden = b.hidden == true and st.revealed ~= true -- 1149
					if b.hidden then -- 1149
						b.broken = true -- 1151
					end -- 1151
				elseif b.hidden == true then -- 1151
					b.broken = true -- 1155
				end -- 1155
			end -- 1155
			::__continue94:: -- 1155
			i = i + 1 -- 1140
		end -- 1140
	end -- 1140
	if wr.cart.bodyW > 0 then -- 1140
		self.cartAxle = wr.cart.startX -- 1159
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1159
			self.cartAxle = wr.cart.endX -- 1161
			self.cartDocked = true -- 1162
		end -- 1162
	end -- 1162
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1165
end -- 1093
function Play.prototype.log(self, line) -- 1168
	local ____self_run_log_18 = self.run.log -- 1168
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1169
	if #self.run.log > 120 then -- 1169
		table.remove(self.run.log, 1) -- 1171
	end -- 1171
end -- 1168
function Play.prototype.buildEnemies(self) -- 1175
	self.enemies = {} -- 1176
	if self.isCampaign then -- 1176
		local i = 0 -- 1178
		do -- 1178
			i = 0 -- 1179
			while i < #self.room.spawns do -- 1179
				local sp = self.room.spawns[i + 1] -- 1180
				local kind = sp.kind or "gunner" -- 1181
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1182
				local ____self_enemies_19 = self.enemies -- 1182
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1183
					x = sp.x, -- 1184
					y = sp.y, -- 1184
					depth = sp.depth, -- 1184
					w = 26, -- 1184
					h = sp.h, -- 1184
					alive = true, -- 1184
					hitT = 0, -- 1184
					warnT = 0, -- 1184
					fireCd = 40, -- 1184
					kind = kind, -- 1185
					shieldHp = hp, -- 1185
					shieldHpMax = hp, -- 1185
					drop = sp.drop or "none", -- 1185
					homeX = sp.x, -- 1186
					swingT = 0, -- 1186
					awake = false, -- 1186
					squad = i -- 1186
				} -- 1186
				i = i + 1 -- 1179
			end -- 1179
		end -- 1179
		return -- 1189
	end -- 1189
	if self.room.key == "checkpoint" then -- 1189
		local ____self_enemies_20 = self.enemies -- 1189
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1192
			x = self.ox + 430, -- 1192
			y = 0, -- 1192
			w = 26, -- 1192
			h = 84, -- 1192
			alive = true, -- 1192
			hitT = 0, -- 1192
			warnT = 0, -- 1192
			fireCd = 0 -- 1192
		} -- 1192
		local ____self_enemies_21 = self.enemies -- 1192
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1193
			x = self.ox + 505, -- 1193
			y = 0, -- 1193
			w = 26, -- 1193
			h = 84, -- 1193
			alive = true, -- 1193
			hitT = 0, -- 1193
			warnT = 0, -- 1193
			fireCd = 0 -- 1193
		} -- 1193
		return -- 1194
	end -- 1194
	if self.room.key == "street" then -- 1194
		local ____self_enemies_22 = self.enemies -- 1194
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1198
			x = self.ox + 340, -- 1198
			y = 0, -- 1198
			w = 26, -- 1198
			h = 84, -- 1198
			alive = true, -- 1198
			hitT = 0, -- 1198
			warnT = 0, -- 1198
			fireCd = 0 -- 1198
		} -- 1198
		local ____self_enemies_23 = self.enemies -- 1198
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1199
			x = self.ox + 560, -- 1199
			y = 0, -- 1199
			w = 26, -- 1199
			h = 84, -- 1199
			alive = true, -- 1199
			hitT = 0, -- 1199
			warnT = 0, -- 1199
			fireCd = 0 -- 1199
		} -- 1199
	end -- 1199
end -- 1175
function Play.prototype.emit(self, name, data) -- 1205
	local ____self_events_24 = self.events -- 1205
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1206
	self.eventSeq = self.eventSeq + 1 -- 1207
	if #self.events > 256 then -- 1207
		table.remove(self.events, 1) -- 1209
	end -- 1209
end -- 1205
function Play.prototype.drainEvents(self) -- 1217
	local out = self.events -- 1218
	self.events = {} -- 1219
	return out -- 1220
end -- 1217
function Play.prototype.adoptEvents(self, events) -- 1229
	if #events == 0 then -- 1229
		return -- 1231
	end -- 1231
	local keep = {} -- 1233
	local i = 0 -- 1234
	do -- 1234
		i = 0 -- 1235
		while i < #events do -- 1235
			do -- 1235
				local e = events[i + 1] -- 1236
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1236
					goto __continue115 -- 1238
				end -- 1238
				keep[#keep + 1] = e -- 1240
			end -- 1240
			::__continue115:: -- 1240
			i = i + 1 -- 1235
		end -- 1235
	end -- 1235
	if #keep == 0 then -- 1235
		return -- 1243
	end -- 1243
	self.events = __TS__ArrayConcat(keep, self.events) -- 1245
	do -- 1245
		i = 0 -- 1246
		while i < #self.events do -- 1246
			self.events[i + 1].seq = i -- 1247
			i = i + 1 -- 1246
		end -- 1246
	end -- 1246
	self.eventSeq = #self.events -- 1249
end -- 1229
function Play.prototype.chooseTalent(self, slot) -- 1252
	local trial = self.run.trial -- 1253
	local talent = trial and trial.offers[slot + 1] -- 1254
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1254
		return -- 1255
	end -- 1255
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1255
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1256
	trial.offers = {} -- 1257
	if talent == "vitality" then -- 1257
		self.maxHp = self.maxHp + 1 -- 1259
		self.hp = self.hp + 1 -- 1260
		trial.hp = self.hp -- 1261
	end -- 1261
	self:flashSet(talentNames[talent], 1.2) -- 1263
end -- 1252
function Play.prototype.beginReload(self) -- 1271
	self.reloadT = self:reloadTicks() -- 1272
	local camp = self.room.campaign -- 1273
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1273
		self:openReloadPuzzle() -- 1276
	end -- 1276
end -- 1271
function Play.prototype.openReloadPuzzle(self) -- 1281
	self.reloadOpen = true -- 1282
	self.reloadAnswerTicks = 0 -- 1283
	self.reloadWorldTicks = 0 -- 1284
	self.reloadPath = {RELOAD_START} -- 1285
	self.reloadPendingEffect = "" -- 1286
	self.reloadTryCount = self.reloadTryCount + 1 -- 1287
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1288
end -- 1281
function Play.prototype.closeReloadPuzzle(self) -- 1292
	self.reloadOpen = false -- 1293
	self.reloadAnswerTicks = 0 -- 1294
	self.reloadWorldTicks = 0 -- 1295
	self.reloadPath = {RELOAD_START} -- 1296
	self.reloadPendingEffect = "" -- 1297
end -- 1292
function Play.prototype.reloadTapNode(self, node) -- 1304
	if not self.reloadOpen then -- 1304
		return -- 1306
	end -- 1306
	local path = self.reloadPath -- 1308
	local last = path[#path] -- 1309
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1309
		self.reloadPath = {RELOAD_START} -- 1311
		self:emit("reloadInvalid", {node = node, at = last}) -- 1312
		return -- 1313
	end -- 1313
	path[#path + 1] = node -- 1315
	if node ~= RELOAD_TARGET then -- 1315
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1317
		return -- 1318
	end -- 1318
	if not reloadPathValid(path) then -- 1318
		self.reloadPath = {RELOAD_START} -- 1321
		self:emit("reloadInvalid", {node = node, at = last}) -- 1322
		return -- 1323
	end -- 1323
	self.reloadPendingEffect = reloadEffectOf(path) -- 1325
	self.reloadOpen = false -- 1326
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1327
	self:flashSet( -- 1330
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1330
		1.4 -- 1330
	) -- 1330
end -- 1304
function Play.prototype.consumeReloadEffect(self) -- 1334
	local e = self.reloadPendingEffect -- 1335
	if e ~= "" then -- 1335
		self.reloadPendingEffect = "" -- 1337
	end -- 1337
	return e -- 1339
end -- 1334
function Play.prototype.echoToSource(self, from, count) -- 1346
	if count == nil then -- 1346
		count = 1 -- 1346
	end -- 1346
	local best = -1 -- 1347
	local bestD = 1000000000 -- 1348
	local i = 0 -- 1349
	local woken = {} -- 1350
	local n = 0 -- 1351
	while n < count do -- 1351
		best = -1 -- 1353
		bestD = 1000000000 -- 1354
		do -- 1354
			i = 0 -- 1355
			while i < #self.enemies do -- 1355
				do -- 1355
					if woken[i] == true then -- 1355
						goto __continue137 -- 1357
					end -- 1357
					local e = self.enemies[i + 1] -- 1359
					if not e.alive then -- 1359
						goto __continue137 -- 1361
					end -- 1361
					local d = math.abs(e.x - from.x) -- 1363
					if d < bestD then -- 1363
						bestD = d -- 1365
						best = i -- 1366
					end -- 1366
				end -- 1366
				::__continue137:: -- 1366
				i = i + 1 -- 1355
			end -- 1355
		end -- 1355
		if best < 0 then -- 1355
			break -- 1370
		end -- 1370
		woken[best] = true -- 1372
		local e = self.enemies[best + 1] -- 1373
		e.awake = true -- 1374
		e.warnT = 0 -- 1375
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1376
		n = n + 1 -- 1377
	end -- 1377
	if n == 0 then -- 1377
		return -- 1380
	end -- 1380
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1382
end -- 1346
function Play.prototype.reloadTicks(self) -- 1385
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1386
	local ____opt_29 = self.run.trial -- 1386
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1386
end -- 1385
function Play.prototype.update(self, dt, input) -- 1389
	self:syncCraftBench() -- 1390
	local trial = self.run.trial -- 1391
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1391
		return -- 1392
	end -- 1392
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1392
		self:closeCraftBench() -- 1394
		return -- 1395
	end -- 1395
	if input.pause.pressed then -- 1395
		self.paused = not self.paused -- 1398
	end -- 1398
	if self.flashT > 0 then -- 1398
		self.flashT = self.flashT - dt -- 1401
		if self.flashT <= 0 then -- 1401
			self.flash = "" -- 1403
		end -- 1403
	end -- 1403
	if self.traceT > 0 then -- 1403
		self.traceT = self.traceT - dt -- 1407
		if self.traceT <= 0 then -- 1407
			self.trace = nil -- 1409
		end -- 1409
	end -- 1409
	if self.paused then -- 1409
		self:updateCamera(dt) -- 1413
		return -- 1414
	end -- 1414
	if self.craftBench.active then -- 1414
		self:updateCamera(dt) -- 1419
		return -- 1420
	end -- 1420
	if self.reloadOpen then -- 1420
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1426
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1426
			self.reloadOpen = false -- 1428
			self.reloadPendingEffect = "" -- 1429
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1430
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1431
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1431
			self:updateCamera(dt) -- 1433
			return -- 1434
		else -- 1434
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1436
		end -- 1436
	end -- 1436
	self.ticks = self.ticks + 1 -- 1440
	if self.invulnT > 0 then -- 1440
		self.invulnT = self.invulnT - 1 -- 1444
	end -- 1444
	if self.isCampaign then -- 1444
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1444
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1447
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1448
	end -- 1448
	local p = self.player -- 1450
	self:stepPlayer(p, dt, input) -- 1451
	self:refreshCover(p, input) -- 1453
	if self.carryOn then -- 1453
		self:carryPose() -- 1455
	end -- 1455
	if self.isCampaign then -- 1455
		self:stepCampaign(dt, input) -- 1458
		if not self.carryOn then -- 1458
			self:stepCampaignPartner(dt) -- 1460
		end -- 1460
	end -- 1460
	if trial == nil or not self.run.finished then -- 1460
		self:stepEnemies(dt, input) -- 1468
	end -- 1468
	if trial ~= nil then -- 1468
		trial.hp = self.hp -- 1470
	end -- 1470
	if not self.isCampaign then -- 1470
		self:stepStory(dt, input) -- 1472
		self:stepEscort(dt, input) -- 1473
		self:stepVillage(dt, input) -- 1474
		self:stepChase(dt, input) -- 1475
		self:stepInteract(dt, input) -- 1476
	end -- 1476
	self:updateGate() -- 1478
	self:updateCamera(dt) -- 1479
	self:syncStory() -- 1481
end -- 1389
function Play.prototype.underLowArch(self, a) -- 1488
	local arch = self.room.arch -- 1489
	if arch.h <= 0 then -- 1489
		return false -- 1491
	end -- 1491
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1491
		return false -- 1494
	end -- 1494
	local top = arch.y + arch.h -- 1496
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1497
end -- 1488
function Play.prototype.coverAt(self, a) -- 1504
	local best = nil -- 1505
	local bestGap = 24 -- 1506
	local half = a.w / 2 -- 1507
	local i = 0 -- 1508
	do -- 1508
		i = 0 -- 1509
		while i < #self.boxes do -- 1509
			do -- 1509
				local b = self.boxes[i + 1] -- 1510
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1510
					goto __continue171 -- 1512
				end -- 1512
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1512
					goto __continue171 -- 1515
				end -- 1515
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1517
				if gap < bestGap then -- 1517
					bestGap = gap -- 1519
					best = b -- 1520
				end -- 1520
			end -- 1520
			::__continue171:: -- 1520
			i = i + 1 -- 1509
		end -- 1509
	end -- 1509
	return best -- 1523
end -- 1504
function Play.prototype.nearCover(self, a) -- 1526
	return self:coverAt(a) ~= nil -- 1527
end -- 1526
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1531
	if enemy == nil then -- 1531
		return false -- 1533
	end -- 1533
	local fromRight = enemy.x >= a.x -- 1535
	local edge = fromRight and b.x0 or b.x1 -- 1536
	local ____fromRight_34 -- 1537
	if fromRight then -- 1537
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1537
	else -- 1537
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1538
	end -- 1538
	local between = ____fromRight_34 -- 1537
	local separation = enemy.x - a.x -- 1539
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1540
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1541
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1542
end -- 1531
function Play.prototype.nearestEnemy(self, a) -- 1545
	local best -- 1546
	local bestD = 1000000000 -- 1547
	local i = 0 -- 1548
	do -- 1548
		i = 0 -- 1549
		while i < #self.enemies do -- 1549
			do -- 1549
				local e = self.enemies[i + 1] -- 1550
				if not e.alive then -- 1550
					goto __continue180 -- 1552
				end -- 1552
				local d = math.abs(e.x - a.x) -- 1554
				if d < bestD then -- 1554
					bestD = d -- 1556
					best = e -- 1557
				end -- 1557
			end -- 1557
			::__continue180:: -- 1557
			i = i + 1 -- 1549
		end -- 1549
	end -- 1549
	return best -- 1560
end -- 1545
function Play.prototype.refreshCover(self, a, input) -- 1564
	if self.childMode then -- 1564
		self.coverNear = false -- 1566
		self.coverHug = false -- 1567
		self.coverEntity = "" -- 1568
		self.coverBlocking = false -- 1569
		a.covered = false -- 1570
		return -- 1571
	end -- 1571
	local b = self:coverAt(a) -- 1573
	self.coverNear = b ~= nil -- 1574
	a.covered = self.coverNear and input.cover.held -- 1575
	self.coverHug = a.covered -- 1576
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1577
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1578
		b, -- 1578
		a, -- 1578
		self:nearestEnemy(a) -- 1578
	) -- 1578
end -- 1564
function Play.prototype.cartHandleInReach(self, a) -- 1582
	if a == nil then -- 1582
		a = self.player -- 1582
	end -- 1582
	local c = self.room.cart -- 1583
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1583
		return false -- 1585
	end -- 1585
	local handleX = self.cartAxle + c.handleOffset -- 1587
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1588
end -- 1582
function Play.prototype.nearLowLedge(self, a) -- 1593
	local reach = 26 -- 1594
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1595
	local x1 = x0 + reach -- 1596
	local i = 0 -- 1597
	do -- 1597
		i = 0 -- 1598
		while i < #self.boxes do -- 1598
			do -- 1598
				local b = self.boxes[i + 1] -- 1599
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1599
					goto __continue189 -- 1601
				end -- 1601
				local rise = b.y1 - a.y -- 1603
				if rise > 0 and rise <= LEDGE_RISE then -- 1603
					return true -- 1605
				end -- 1605
			end -- 1605
			::__continue189:: -- 1605
			i = i + 1 -- 1598
		end -- 1598
	end -- 1598
	return false -- 1608
end -- 1593
function Play.prototype.stepPlayer(self, a, dt, input) -- 1611
	a.depthSpeed = 0 -- 1612
	if not a.alive then -- 1612
		return -- 1614
	end -- 1614
	local isChild = self.childMode -- 1616
	local lowArch = isChild and self:underLowArch(a) -- 1618
	if self:storyLocked() then -- 1618
		a.vx = 0 -- 1621
		a.crouch = isChild and lowArch -- 1622
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1623
		self:fallY(a, dt) -- 1624
		return -- 1625
	end -- 1625
	if not isChild and self.escort.state == "calming" then -- 1625
		a.crouch = false -- 1629
		a.h = SOLDIER_H -- 1630
		a.vx = 0 -- 1631
		self:fallY(a, dt) -- 1632
		return -- 1633
	end -- 1633
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1635
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1636
	local nearCover = not isChild and self:nearCover(a) -- 1637
	a.covered = nearCover and input.cover.held -- 1638
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1640
	if a.rollT > 0 then -- 1640
		a.rollT = a.rollT - dt -- 1644
		a.vx = a.facing * ROLL_SPEED -- 1645
		self:slideX(a, a.vx * dt) -- 1646
		self:fallY(a, dt) -- 1647
		if a.rollT <= 0 then -- 1647
			self:flashSet("翻滚结束", 0.5) -- 1649
		end -- 1649
		return -- 1651
	end -- 1651
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1651
		if input.moveX ~= 0 then -- 1651
			a.facing = input.moveX > 0 and 1 or -1 -- 1656
		end -- 1656
		if self:nearLowLedge(a) then -- 1656
			a.vy = SOLDIER_JUMP -- 1660
			a.onGround = false -- 1661
			self:flashSet("翻上去", 0.3) -- 1662
			return -- 1663
		end -- 1663
		a.rollT = ROLL_TIME -- 1665
		self:flashSet("翻滚", 0.3) -- 1666
		return -- 1667
	end -- 1667
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1670
	if isChild then -- 1670
		if input.cover.held then -- 1670
			speed = CHILD_SLOW -- 1673
		end -- 1673
		if a.crouch then -- 1673
			speed = CHILD_SLOW -- 1676
		end -- 1676
	elseif a.covered then -- 1676
		speed = SOLDIER_SPEED * 0.45 -- 1679
	end -- 1679
	local handsBusy = self.gripping or gripIntent -- 1683
	local dir = self.gripping and 0 or input.moveX -- 1684
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 1686
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1688
	if dir ~= 0 then -- 1688
		a.facing = dir > 0 and 1 or -1 -- 1690
	end -- 1690
	a.vx = dir * speed * diagonal -- 1692
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1692
		a.vy = CHILD_JUMP -- 1696
		a.onGround = false -- 1697
		self:flashSet("跳", 0.25) -- 1698
	end -- 1698
	local previousDepth = a.depth -- 1702
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1703
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1704
	self:slideX(a, a.vx * dt) -- 1705
	self:fallY(a, dt) -- 1706
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1706
		self:shoot(a) -- 1710
	end -- 1710
end -- 1611
function Play.prototype.stepPartner(self, p, dt) -- 1715
	local a = self.partner -- 1716
	if not a.alive then -- 1716
		return -- 1718
	end -- 1718
	a.crouch = false -- 1720
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1721
	a.vx = 0 -- 1722
	a.depthSpeed = 0 -- 1723
	self:fallY(a, dt) -- 1724
end -- 1715
function Play.prototype.stepEscort(self, dt, input) -- 1731
	local a = self.partner -- 1732
	a.depthSpeed = 0 -- 1733
	if not a.alive then -- 1733
		return -- 1735
	end -- 1735
	if self.room.key == "gatepath" then -- 1735
		if self.carryOn then -- 1735
			return -- 1740
		end -- 1740
		local p = self.player -- 1743
		a.depth = p.depth -- 1744
		a.facing = p.facing -- 1745
		a.crouch = false -- 1746
		a.h = CHILD_H -- 1747
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1748
		a.y = p.y -- 1749
		a.vy = 0 -- 1750
		a.vx = p.vx -- 1751
		a.onGround = p.onGround -- 1752
		return -- 1753
	end -- 1753
	if not self:escortOn() then -- 1753
		a.vx = 0 -- 1756
		self:fallY(a, dt) -- 1757
		return -- 1758
	end -- 1758
	local p = self.player -- 1760
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1761
	local hadKnock1 = self.escort.knock1 -- 1762
	local hadKnock2 = self.escort.knock2 -- 1763
	self.calmConsumed = self.escort:update( -- 1764
		input, -- 1764
		p.x, -- 1764
		p.facing, -- 1764
		a.x, -- 1764
		dist -- 1764
	) -- 1764
	if not hadKnock1 and self.escort.knock1 then -- 1764
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1767
	end -- 1767
	if not hadKnock2 and self.escort.knock2 then -- 1767
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1770
	end -- 1770
	a.crouch = self.escort.crouchPose -- 1772
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1773
	if not self.escort.stopped then -- 1773
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1775
		local previousDepth = a.depth -- 1776
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1777
		local distance = math.max( -- 1778
			-travel, -- 1778
			math.min(travel, targetDepth - previousDepth) -- 1778
		) -- 1778
		self:slideDepth(a, distance) -- 1779
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1780
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1780
			a.vy = CHILD_JUMP -- 1782
			a.onGround = false -- 1783
		end -- 1783
	end -- 1783
	local dir = self.escort:moveDir(a.x) -- 1786
	a.vx = dir * CHILD_SPEED -- 1787
	if dir ~= 0 then -- 1787
		a.facing = dir -- 1789
		local before = a.x -- 1790
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1791
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1791
			a.vy = CHILD_JUMP -- 1794
			a.onGround = false -- 1795
		end -- 1795
	end -- 1795
	self:fallY(a, dt) -- 1798
end -- 1731
function Play.prototype.escortOn(self) -- 1802
	if self.room.key == "checkpoint" then -- 1802
		return true -- 1804
	end -- 1804
	if self.room.key == "gatepath" then -- 1804
		return true -- 1807
	end -- 1807
	if self.room.key == "prologue" then -- 1807
		return self.phase == "prologue-follow" -- 1810
	end -- 1810
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1810
		return true -- 1814
	end -- 1814
	return self.room.key == "street" -- 1816
end -- 1802
function Play.prototype.storyLocked(self) -- 1820
	if self.caughtT > 0 then -- 1820
		return true -- 1822
	end -- 1822
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 1822
		return true -- 1826
	end -- 1826
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1826
		return true -- 1829
	end -- 1829
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1829
		return true -- 1832
	end -- 1832
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1832
		return true -- 1835
	end -- 1835
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1835
		return true -- 1838
	end -- 1838
	if self.craftBench.active then -- 1838
		return true -- 1842
	end -- 1842
	return false -- 1844
end -- 1820
function Play.prototype.swapToChild(self, x) -- 1848
	local tmp = self.player -- 1849
	self.player = self.partner -- 1850
	self.partner = tmp -- 1851
	self.childMode = true -- 1852
	self.player.alive = true -- 1853
	self.player.x = self.ox + x -- 1854
	self.player.y = 0 -- 1855
	self.player.depth = 0 -- 1856
	self.player.depthSpeed = 0 -- 1857
	self.player.vy = 0 -- 1858
	self.player.vx = 0 -- 1859
	self.player.onGround = true -- 1860
	self.player.crouch = false -- 1861
	self.player.h = CHILD_H -- 1862
	self.player.facing = 1 -- 1863
	self.partner.alive = true -- 1864
	self.cam.x = self.player.x -- 1865
end -- 1848
function Play.prototype.swapToSoldier(self, x, childX) -- 1869
	local tmp = self.player -- 1870
	self.player = self.partner -- 1871
	self.partner = tmp -- 1872
	self.childMode = false -- 1873
	self.player.alive = true -- 1874
	self.player.x = self.ox + x -- 1875
	self.player.y = 0 -- 1876
	self.player.depth = 0 -- 1877
	self.player.depthSpeed = 0 -- 1878
	self.player.vy = 0 -- 1879
	self.player.vx = 0 -- 1880
	self.player.onGround = true -- 1881
	self.player.crouch = false -- 1882
	self.player.h = SOLDIER_H -- 1883
	self.player.facing = 1 -- 1884
	self.partner.alive = true -- 1885
	self.partner.x = self.ox + childX -- 1886
	self.partner.y = 0 -- 1887
	self.partner.depth = 0 -- 1888
	self.partner.depthSpeed = 0 -- 1889
	self.partner.vx = 0 -- 1890
	self.partner.vy = 0 -- 1891
	self.partner.onGround = true -- 1892
	self.partner.crouch = true -- 1893
	self.partner.h = CHILD_CROUCH_H -- 1894
	self.cam.x = self.player.x -- 1895
end -- 1869
function Play.prototype.stepStory(self, dt, input) -- 1899
	if self.room.key == "prologue" then -- 1899
		self:stepPrologue(dt, input) -- 1901
	elseif self.room.key == "street" then -- 1901
		self:stepStreet(dt, input) -- 1903
	elseif self.room.key == "gate" then -- 1903
		self:stepGate(dt, input) -- 1905
	elseif self.room.key == "gatepath" then -- 1905
		self:stepGatePath() -- 1907
	elseif self.room.key == "tower" then -- 1907
		self:stepTower(dt, input) -- 1909
	elseif self.room.key == "museum" then -- 1909
		self:stepMuseum(dt, input) -- 1911
	end -- 1911
end -- 1899
function Play.prototype.canPersistProgress(self) -- 1917
	return not self.isCampaign and self.run.source == "official" -- 1918
end -- 1917
function Play.prototype.wellWindow(self) -- 1922
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1923
end -- 1922
function Play.prototype.nearWell(self) -- 1928
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1929
end -- 1928
function Play.prototype.pickWell(self) -- 1937
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1937
		return false -- 1939
	end -- 1939
	self.phase = "prologue-well" -- 1941
	self.phaseTick = 0 -- 1942
	self.wellOpen = false -- 1943
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1944
	self:log("旧井拾取") -- 1945
	return true -- 1946
end -- 1937
function Play.prototype.stepPrologue(self, dt, input) -- 1949
	local child = self.partner -- 1950
	if self.museumReturn then -- 1950
		self.museumReturn = false -- 1953
		self.phase = "prologue-wait" -- 1954
		self.phaseTick = 0 -- 1955
		self.player.x = self.ox + 260 -- 1956
		self.player.y = 0 -- 1957
		self.player.depth = 0 -- 1958
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 1959
	end -- 1959
	if self.phase == "prologue-wake" then -- 1959
		self.introTick = self.introTick + 1 -- 1963
		if self.introTick == 60 then -- 1963
			self:flashSet("门外有人唤 · 小满", 1.2) -- 1965
		end -- 1965
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 1965
			self.phase = "prologue-shadow" -- 1968
			self.introTick = 0 -- 1969
			self:flashSet("门缝里两道影子", 1.2) -- 1970
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 1971
		end -- 1971
		return -- 1973
	end -- 1973
	if self.phase == "prologue-shadow" then -- 1973
		self.introTick = self.introTick + 1 -- 1976
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 1976
			self.phase = "prologue-escape" -- 1979
			self.introTick = 0 -- 1980
			self.escapeRemaining = self.escapeDuration -- 1981
			self.escapeRetryCount = 0 -- 1982
			self:swapToChild(100) -- 1983
			self:flashSet( -- 1984
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 1984
				1.6 -- 1984
			) -- 1984
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 1985
		end -- 1985
		return -- 1989
	end -- 1989
	if self.phase == "prologue-escape" then -- 1989
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 1992
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 1992
			self.phase = "prologue-hide" -- 1995
			self.introTick = 0 -- 1996
			self.player.vx = 0 -- 1997
			self.player.crouch = true -- 1998
			self.player.h = CHILD_CROUCH_H -- 1999
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2000
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2001
			return -- 2005
		end -- 2005
		if self.escapeRemaining <= 0 then -- 2005
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2009
			self.player.x = self.ox + 100 -- 2010
			self.player.y = 0 -- 2011
			self.player.depth = 0 -- 2012
			self.player.vx = 0 -- 2013
			self.player.vy = 0 -- 2014
			self.escapeRemaining = self.escapeDuration -- 2015
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2016
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2017
			return -- 2018
		end -- 2018
		return -- 2020
	end -- 2020
	if self.phase == "prologue-hide" then -- 2020
		self.introTick = self.introTick + 1 -- 2023
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2023
			self.phase = "prologue-wait" -- 2026
			self.phaseTick = 0 -- 2027
			self.introTick = 0 -- 2028
			self:swapToSoldier(260, 300) -- 2029
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2030
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2031
		end -- 2031
		return -- 2033
	end -- 2033
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2036
	if self.phase == "prologue-wait" then -- 2036
		child.crouch = true -- 2038
		child.h = CHILD_CROUCH_H -- 2039
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2039
			self:pickWell() -- 2041
			return -- 2042
		end -- 2042
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2042
			if self:canPersistProgress() then -- 2042
				self.archive.museumPhase = "well_reflect" -- 2048
				self.archiveDirty = true -- 2049
			end -- 2049
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2051
			return -- 2052
		end -- 2052
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2054
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2056
		if near and input.interact.pressed then -- 2056
			self.phase = "prologue-give" -- 2058
			self.phaseTick = 0 -- 2059
			self:flashSet("递出针套", 1) -- 2060
		end -- 2060
		return -- 2062
	end -- 2062
	if self.phase == "prologue-well" then -- 2062
		self.phaseTick = self.phaseTick + 1 -- 2066
		if self.phaseTick == 12 then -- 2066
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2068
		elseif self.phaseTick >= 30 then -- 2068
			self.phase = "prologue-wait" -- 2070
			self.phaseTick = 0 -- 2071
			self.wellTaken = true -- 2072
			self.wellOpen = false -- 2073
			self.run.archive.artifactOwned = true -- 2074
			self.archiveDirty = true -- 2075
			self:emit("artifactFound", { -- 2076
				x = self.ox + self.wellX, -- 2077
				y = 0, -- 2077
				room = "prologue", -- 2077
				once = true, -- 2077
				source = self.run.source -- 2078
			}) -- 2078
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2080
			self:log("井底取到时间穿梭器") -- 2081
		end -- 2081
		return -- 2083
	end -- 2083
	if self.phase == "prologue-give" then -- 2083
		self.phaseTick = self.phaseTick + 1 -- 2086
		if self.phaseTick == 12 then -- 2086
			self:flashSet("针套递过去", 0.7) -- 2088
		elseif self.phaseTick == 36 then -- 2088
			self:flashSet("纸条塞进针套", 0.9) -- 2090
		elseif self.phaseTick >= 60 then -- 2090
			self.phase = "prologue-follow" -- 2092
			self.phaseTick = 0 -- 2093
			child.crouch = false -- 2094
			child.h = CHILD_H -- 2095
			self:flashSet("她跟上了", 1.2) -- 2096
		end -- 2096
		return -- 2098
	end -- 2098
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2098
		self:requestRoom("street", "序章跟到门口") -- 2102
		self:flashSet("进街道", 1.2) -- 2103
	end -- 2103
end -- 1949
function Play.prototype.stepStreet(self, dt, input) -- 2108
	local p = self.player -- 2109
	local c = self.partner -- 2110
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2110
		self:requestRoom("checkpoint", "两人都到街尾") -- 2112
		self:flashSet("到检查站", 1.2) -- 2113
	end -- 2113
end -- 2108
function Play.prototype.stepGate(self, dt, input) -- 2118
	local ____temp_35 -- 2119
	if self.room.story == nil then -- 2119
		____temp_35 = nil -- 2119
	else -- 2119
		____temp_35 = self.room.story.gate -- 2119
	end -- 2119
	local g = ____temp_35 -- 2119
	if g == nil then -- 2119
		return -- 2121
	end -- 2121
	local p = self.player -- 2123
	if self.phase == "gate-idle" then -- 2123
		local a = self.partner -- 2126
		local gap = g.waitX - a.x -- 2127
		if math.abs(gap) > 3 then -- 2127
			a.facing = gap > 0 and 1 or -1 -- 2129
			a.vx = a.facing * CHILD_SPEED -- 2130
			local beforeX = a.x -- 2131
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2132
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2132
				a.vy = CHILD_JUMP -- 2134
				a.onGround = false -- 2135
			end -- 2135
			self:fallY(a, dt) -- 2137
		else -- 2137
			a.vx = 0 -- 2139
			a.x = g.waitX -- 2140
		end -- 2140
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2143
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2144
		if self.gateNeedConfirm then -- 2144
			if not input.interact.held then -- 2144
				self.gateRestartArmed = true -- 2149
			end -- 2149
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2149
				self.gateNeedConfirm = false -- 2152
				self.gateRestartArmed = true -- 2153
				self.phase = "gate-hold" -- 2154
				self.gateTick = 0 -- 2155
				self.gateSpawned = 0 -- 2156
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2157
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2158
			end -- 2158
			return -- 2160
		end -- 2160
		if atWinch and atWait then -- 2160
			self.phase = "gate-hold" -- 2163
			self.gateTick = 0 -- 2164
			self.gateSpawned = 0 -- 2165
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2166
		end -- 2166
		return -- 2168
	end -- 2168
	if self.phase == "gate-hold" then -- 2168
		self.gateTick = self.gateTick + 1 -- 2171
		local marks = {0, 540, 900, 1500} -- 2173
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2173
			local idx = self.gateSpawned -- 2175
			local ____self_enemies_36 = self.enemies -- 2175
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 2176
				x = self.ox + 620 + idx * 62, -- 2177
				y = 0, -- 2177
				w = 26, -- 2177
				h = 84, -- 2177
				alive = true, -- 2178
				hitT = 0, -- 2178
				warnT = 0, -- 2178
				fireCd = 90 + idx * 45 -- 2178
			} -- 2178
			self.gateSpawned = self.gateSpawned + 1 -- 2180
			self:flashSet( -- 2181
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2181
				0.9 -- 2181
			) -- 2181
		end -- 2181
		if self.gateTick == 900 then -- 2181
			self:flashSet("灯灭了", 1) -- 2184
		elseif self.gateTick == 2100 then -- 2184
			self:flashSet("门底压下来了", 1) -- 2186
		end -- 2186
		if self.gateTick >= g.holdTicks then -- 2186
			self:captureGateBlood() -- 2191
			self.phase = "gate-send" -- 2192
			self.phaseTick = 0 -- 2193
			self.enemies = {} -- 2195
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2196
		end -- 2196
		return -- 2198
	end -- 2198
	if self.phase == "gate-send" then -- 2198
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2201
		if near and input.interact.pressed then -- 2201
			self:commitRoute() -- 2204
			self:swapToChild(g.doorX + 30) -- 2205
			self.phase = "gate-count" -- 2206
			self.countTick = 0 -- 2207
			self.countArmed = false -- 2209
			self.countPrevMove = input.moveX -- 2210
			self:flashSet("门开了 · 送她出去", 1.8) -- 2211
		end -- 2211
		return -- 2213
	end -- 2213
	if self.phase == "gate-count" then -- 2213
		self.countTick = self.countTick + 1 -- 2216
		if self.countTick == 360 then -- 2216
			self:flashSet("门关上", 0.9) -- 2218
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2218
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2220
			if self.storyRoute == "soldier" then -- 2220
				self.phase = "gate-wait" -- 2226
				self.phaseTick = 0 -- 2227
				self.knocks = 1 -- 2228
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2229
				self.handArmed = not input.interact.held -- 2231
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2232
			else -- 2232
				self:flashSet("数到二十", 2.2) -- 2234
			end -- 2234
		end -- 2234
		local prevMove = self.countPrevMove -- 2239
		self.countPrevMove = input.moveX -- 2240
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2240
			if prevMove <= 0 and input.moveX > 0 then -- 2240
				self.countArmed = true -- 2243
			end -- 2243
			if self.countArmed and input.moveX > 0 then -- 2243
				self.phase = "gate-walk" -- 2246
				self.phaseTick = 0 -- 2247
				self:flashSet("她迈出第一步", 1.4) -- 2248
				self:emit("storyExit", { -- 2249
					route = "child", -- 2249
					via = "walk", -- 2249
					countTick = self.countTick, -- 2249
					hp = self.hp, -- 2249
					maxHp = self.maxHp -- 2249
				}) -- 2249
			end -- 2249
		end -- 2249
		return -- 2252
	end -- 2252
	if self.phase == "gate-wait" then -- 2252
		self.phaseTick = self.phaseTick + 1 -- 2256
		if self.phaseTick == 12 then -- 2256
			self.knocks = 2 -- 2258
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2259
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2260
		end -- 2260
		if not input.interact.held then -- 2260
			if self.handTicks > 0 then -- 2260
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2264
			end -- 2264
			self.handTicks = 0 -- 2266
			self.handArmed = true -- 2267
			return -- 2268
		end -- 2268
		if self.handArmed then -- 2268
			self.handTicks = self.handTicks + 1 -- 2271
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2271
				self.phase = "gate-hand" -- 2273
				self.phaseTick = 0 -- 2274
				self.handDone = true -- 2275
				self.tied = true -- 2276
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2277
				if not self.lineSaid then -- 2277
					self.lineSaid = true -- 2279
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2280
				end -- 2280
				self:flashSet("我们走吧。", 3) -- 2282
			end -- 2282
		end -- 2282
		return -- 2285
	end -- 2285
	if self.phase == "gate-hand" then -- 2285
		self.phaseTick = self.phaseTick + 1 -- 2289
		if self.phaseTick == 30 then -- 2289
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2291
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2291
			self:emit("storyExit", { -- 2293
				route = "soldier", -- 2293
				via = "hand", -- 2293
				handTicks = self.handTicks, -- 2293
				hp = self.hp, -- 2293
				maxHp = self.maxHp -- 2293
			}) -- 2293
			self:requestRoom("gatepath", "牵手同行") -- 2294
		end -- 2294
		return -- 2296
	end -- 2296
	if self.phase == "gate-walk" then -- 2296
		if self.player.x >= g.exitX then -- 2296
			self:requestRoom("outside", "走出城门") -- 2301
			self:flashSet("出城门 · 城外", 1.4) -- 2302
		end -- 2302
	end -- 2302
end -- 2118
function Play.prototype.captureGateBlood(self) -- 2311
	self.hpAtGate = self.hp -- 2312
	self.maxHpAtGate = self.maxHp -- 2313
end -- 2311
function Play.prototype.commitRoute(self) -- 2320
	if self.storySettled then -- 2320
		return -- 2322
	end -- 2322
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2324
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2325
	self.hpAtGate = hp -- 2326
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2327
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2328
	self.storySettled = true -- 2329
	self:emit("storyRouteLocked", { -- 2330
		route = self.storyRoute, -- 2331
		hp = self.hp, -- 2331
		maxHp = self.maxHp, -- 2331
		hpAtGate = self.hpAtGate, -- 2332
		maxHpAtGate = self.maxHpAtGate -- 2332
	}) -- 2332
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2334
end -- 2320
function Play.prototype.syncStory(self) -- 2338
	if self.isCampaign and self.run.trial ~= nil then -- 2338
		return -- 2340
	end -- 2340
	local s = self.run.story -- 2342
	if s == nil then -- 2342
		return -- 2344
	end -- 2344
	s.hp = self.hp -- 2346
	s.maxHp = self.maxHp -- 2347
	s.route = self.storyRoute -- 2348
	s.settled = self.storySettled -- 2349
	s.hpAtGate = self.hpAtGate -- 2350
	s.maxHpAtGate = self.maxHpAtGate -- 2351
	s.handDone = self.handDone -- 2352
	s.lineSaid = self.lineSaid -- 2353
	s.tied = self.tied -- 2354
	s.carry = self.carryOn -- 2355
	s.museumReturn = self.museumReturn -- 2356
	s.escortDone = self.escortDone -- 2357
	s.craftedWeapon = self.run.story.craftedWeapon -- 2358
	s.ending = self.run.story.ending -- 2359
	if self.room.key == "gate" then -- 2359
		s.phase = self.phase -- 2361
		s.countTick = self.countTick -- 2362
		s.phaseTick = self.phaseTick -- 2363
		s.handTicks = self.handTicks -- 2364
	end -- 2364
	if self.room.key == "prologue" then -- 2364
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2364
			s.phase = self.phase -- 2369
			s.phaseTick = self.phaseTick -- 2370
		end -- 2370
	end -- 2370
end -- 2338
function Play.prototype.stepGatePath(self) -- 2376
	local ____temp_37 -- 2377
	if self.room.story == nil then -- 2377
		____temp_37 = nil -- 2377
	else -- 2377
		____temp_37 = self.room.story.gatepath -- 2377
	end -- 2377
	local gp = ____temp_37 -- 2377
	if self.phase == "gatepath-start" then -- 2377
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2377
			self.carryOn = true -- 2380
			self.phase = "gatepath-carry" -- 2381
			self.phaseTick = 0 -- 2382
			self.pathDone = true -- 2383
			self.escortDone = false -- 2384
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2385
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2386
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2387
		end -- 2387
		return -- 2389
	end -- 2389
	if self.phase == "gatepath-carry" then -- 2389
		self.phaseTick = self.phaseTick + 1 -- 2392
		if self.phaseTick == 20 then -- 2392
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2394
		end -- 2394
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2394
			self:requestRoom(gp.next, "背负进首战") -- 2397
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2398
		end -- 2398
	end -- 2398
end -- 2376
function Play.prototype.carryPose(self) -- 2407
	local p = self.player -- 2408
	local a = self.partner -- 2409
	a.alive = true -- 2410
	a.x = p.x - p.facing * 12 -- 2411
	a.y = p.y + 26 -- 2412
	a.depth = p.depth -- 2413
	a.vx = p.vx -- 2414
	a.vy = 0 -- 2415
	a.onGround = true -- 2416
	a.crouch = false -- 2417
	a.h = CHILD_CROUCH_H -- 2418
	a.facing = p.facing -- 2419
end -- 2407
function Play.prototype.stepMuseum(self, dt, input) -- 2427
	self.partner.alive = false -- 2428
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2429
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2432
	if self.phase == "museum-cabinet" then -- 2432
		if atCase and input.interact.pressed then -- 2432
			self.phase = "museum-hall" -- 2435
			self.phaseTick = 0 -- 2436
			if self:canPersistProgress() then -- 2436
				self.archive.museumPhase = "hall_walk" -- 2438
				self.archiveDirty = true -- 2439
			end -- 2439
			self:emit( -- 2441
				"museumStep", -- 2441
				{ -- 2441
					step = "cabinet", -- 2441
					x = self.ox + mu.cabinetX, -- 2441
					persisted = self:canPersistProgress() -- 2441
				} -- 2441
			) -- 2441
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2442
		end -- 2442
		return -- 2444
	end -- 2444
	if self.phase == "museum-hall" then -- 2444
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2444
			self.phase = "museum-lamp" -- 2448
			self.phaseTick = 0 -- 2449
			if self:canPersistProgress() then -- 2449
				self.archive.museumPhase = "lamp_turn" -- 2451
				self.archiveDirty = true -- 2452
			end -- 2452
			self:emit( -- 2454
				"museumStep", -- 2454
				{ -- 2454
					step = "hall", -- 2454
					x = self.ox + mu.hallX, -- 2454
					persisted = self:canPersistProgress() -- 2454
				} -- 2454
			) -- 2454
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2455
		end -- 2455
		return -- 2457
	end -- 2457
	if self.phase == "museum-lamp" then -- 2457
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2457
			self.phase = "museum-return" -- 2461
			self.phaseTick = 0 -- 2462
			if self:canPersistProgress() then -- 2462
				self.archive.museumPhase = "return_cabinet" -- 2464
				self.archiveDirty = true -- 2465
			end -- 2465
			self:emit( -- 2467
				"museumStep", -- 2467
				{ -- 2467
					step = "lamp", -- 2467
					x = self.ox + mu.lampX, -- 2467
					persisted = self:canPersistProgress() -- 2467
				} -- 2467
			) -- 2467
			self:flashSet("灯 · 转向西窗", 1.8) -- 2468
		end -- 2468
		return -- 2470
	end -- 2470
	if self.phase == "museum-return" then -- 2470
		if atCase and input.interact.pressed then -- 2470
			self.phase = "museum-knock" -- 2474
			self.phaseTick = 0 -- 2475
			self:emit( -- 2476
				"museumStep", -- 2476
				{ -- 2476
					step = "knock", -- 2476
					count = 1, -- 2476
					x = self.ox + mu.cabinetX, -- 2476
					persisted = self:canPersistProgress() -- 2476
				} -- 2476
			) -- 2476
			self:flashSet("回柜边 · 第一下", 0.8) -- 2477
		end -- 2477
		return -- 2479
	end -- 2479
	if self.phase == "museum-knock" then -- 2479
		self.phaseTick = self.phaseTick + 1 -- 2482
		if self.phaseTick == 8 then -- 2482
			self:emit( -- 2484
				"museumStep", -- 2484
				{ -- 2484
					step = "knock", -- 2484
					count = 2, -- 2484
					x = self.ox + mu.cabinetX, -- 2484
					persisted = self:canPersistProgress() -- 2484
				} -- 2484
			) -- 2484
			self:flashSet("回柜边 · 第二下", 0.8) -- 2485
		elseif self.phaseTick >= 36 then -- 2485
			self.phase = "museum-done" -- 2487
			self.phaseTick = 0 -- 2488
			if self:canPersistProgress() then -- 2488
				self.archive.museumSeen = true -- 2490
				self.archive.museumPhase = "done" -- 2491
				self.archiveDirty = true -- 2492
			end -- 2492
			self:emit( -- 2494
				"museumDone", -- 2494
				{ -- 2494
					steps = 4, -- 2494
					museumSeen = self.archive.museumSeen, -- 2494
					persisted = self:canPersistProgress() -- 2494
				} -- 2494
			) -- 2494
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2495
			self:log("博物馆 · 回柜边") -- 2496
		end -- 2496
		return -- 2498
	end -- 2498
	if input.interact.pressed then -- 2498
		self.museumReturn = true -- 2501
		self:requestRoom("prologue", "回柜边") -- 2502
	end -- 2502
end -- 2427
function Play.prototype.stepTower(self, dt, input) -- 2506
	local ____temp_38 -- 2507
	if self.room.story == nil then -- 2507
		____temp_38 = nil -- 2507
	else -- 2507
		____temp_38 = self.room.story.tower -- 2507
	end -- 2507
	local t = ____temp_38 -- 2507
	if t == nil then -- 2507
		return -- 2509
	end -- 2509
	if self.phase == "tower-wait" then -- 2509
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2512
		if near and input.interact.pressed then -- 2512
			self.phase = "tower-knock" -- 2514
			self.phaseTick = 0 -- 2515
			self.knocks = 1 -- 2516
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2517
			self:flashSet("敲一下", 0.6) -- 2518
		end -- 2518
		return -- 2520
	end -- 2520
	if self.phase == "tower-knock" then -- 2520
		self.phaseTick = self.phaseTick + 1 -- 2523
		if self.phaseTick == 12 then -- 2523
			self.knocks = 2 -- 2525
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2526
			self:flashSet("敲两下 · 第二声", 1) -- 2527
		elseif self.phaseTick >= t.knockTicks then -- 2527
			self.phase = "tower-given" -- 2529
			self.phaseTick = 0 -- 2530
			self:flashSet("门开了 · 提灯", 1.4) -- 2531
		end -- 2531
		return -- 2533
	end -- 2533
	if self.phase == "tower-given" then -- 2533
		local soldier = self.storyRoute == "soldier" -- 2538
		self.phaseTick = self.phaseTick + 1 -- 2539
		if self.phaseTick == 60 then -- 2539
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2541
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2542
		elseif self.phaseTick == 120 then -- 2542
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2544
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2544
			self.phase = "tower-end" -- 2546
			self.phaseTick = 0 -- 2547
			if not self.run.finished then -- 2547
				self.run.finished = true -- 2549
				local ending = soldier and "reunion" or "lamp" -- 2550
				self.run.story.ending = ending -- 2551
				local ____soldier_39 -- 2554
				if soldier then -- 2554
					____soldier_39 = self.run.story.segments.escort5 == true -- 2555
				else -- 2555
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2556
				end -- 2556
				local played = ____soldier_39 -- 2554
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2557
				if official then -- 2557
					if soldier then -- 2557
						self.run.archive.soldierCleared = true -- 2561
					else -- 2561
						self.run.archive.childCleared = true -- 2563
					end -- 2563
					self.archiveDirty = true -- 2565
				end -- 2565
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2567
				self:emit("endingReached", { -- 2568
					route = soldier and "soldier" or "child", -- 2569
					ending = ending, -- 2570
					official = official, -- 2571
					source = self.run.source, -- 2572
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2573
					childCleared = self.run.archive.childCleared, -- 2574
					soldierCleared = self.run.archive.soldierCleared, -- 2575
					artifactOwned = self.run.archive.artifactOwned, -- 2576
					equipped = self.equippedWeapon -- 2577
				}) -- 2577
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2579
			end -- 2579
		end -- 2579
		return -- 2582
	end -- 2582
	self.phaseTick = self.phaseTick + 1 -- 2584
	local endingTicks = t.knockTicks + TOWER_REGISTER_TICKS + self.phaseTick -- 2585
	if endingTicks >= ____exports.TOWER_CONFIRM_TICKS and (input.interact.pressed or input.retry.pressed) then -- 2585
		self.restartStory = true -- 2588
		self:requestRoom("prologue", "片尾再玩") -- 2589
		self:flashSet("回到序章", 1.4) -- 2590
	end -- 2590
end -- 2506
function Play.prototype.stepChase(self, dt, input) -- 2595
	if self.caughtT > 0 then -- 2595
		self.caughtT = self.caughtT - dt -- 2597
		if self.caughtT <= 0 then -- 2597
			self:recoverFromCaught() -- 2599
		end -- 2599
		return -- 2601
	end -- 2601
	if self.room.key == "village" then -- 2601
		self:stepScavChase() -- 2604
	elseif self.room.key == "forest" then -- 2604
		self:stepDog(dt) -- 2606
		if self.player.x >= self.ox + 1450 then -- 2606
			self:requestRoom("tower", "到林缘北塔") -- 2609
			self:flashSet("林缘 · 北塔", 1.4) -- 2610
		end -- 2610
	end -- 2610
end -- 2595
function Play.prototype.stepScavChase(self) -- 2616
	local s = self.room.scavenger -- 2617
	if s == nil then -- 2617
		return -- 2619
	end -- 2619
	local p = self.player -- 2621
	if self.passed and p.x > self.ox + 440 then -- 2621
		if self.scavChase then -- 2621
			self.scavChase = false -- 2625
			self.scavState = "back" -- 2626
			self.scavT = 0 -- 2627
		end -- 2627
		return -- 2629
	end -- 2629
	local dx = p.x - self.scavX -- 2631
	local dist = math.abs(dx) -- 2632
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2633
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2634
	if not self.scavChase then -- 2634
		if visible then -- 2634
			self.scavSee = self.scavSee + 1 -- 2637
			if self.scavSee >= 24 then -- 2637
				self.scavChase = true -- 2639
				self.scavState = "chase" -- 2640
				self.scavTargetX = p.x -- 2641
				self:flashSet("他看见你了", 1.2) -- 2642
			end -- 2642
		else -- 2642
			self.scavSee = 0 -- 2645
		end -- 2645
		return -- 2647
	end -- 2647
	local dir = p.x > self.scavX and 1 or -1 -- 2650
	self.scavX = self.scavX + dir * 96 / 60 -- 2651
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2651
		self:caught() -- 2653
		return -- 2654
	end -- 2654
	if hidden then -- 2654
		self.scavSee = 0 -- 2658
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2659
		self.scavT = self.scavT - 1 -- 2660
		if self.scavT <= 0 then -- 2660
			self.scavChase = false -- 2662
			self.scavState = "patrol" -- 2663
			self:flashSet("他失去了目标", 1) -- 2664
		end -- 2664
	end -- 2664
end -- 2616
function Play.prototype.stepDog(self, dt) -- 2670
	local ____temp_40 -- 2671
	if self.room.story == nil then -- 2671
		____temp_40 = nil -- 2671
	else -- 2671
		____temp_40 = self.room.story.dog -- 2671
	end -- 2671
	local dog = ____temp_40 -- 2671
	if dog == nil then -- 2671
		return -- 2673
	end -- 2673
	local p = self.player -- 2675
	local dist = math.abs(p.x - self.dogX) -- 2676
	if self.dogState == "patrol" then -- 2676
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2678
		if self.dogX < dog.x0 then -- 2678
			self.dogX = dog.x0 -- 2680
			self.dogDir = 1 -- 2681
		elseif self.dogX > dog.x1 then -- 2681
			self.dogX = dog.x1 -- 2683
			self.dogDir = -1 -- 2684
		end -- 2684
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2686
		if not p.crouch and moving and dist < dog.range then -- 2686
			self.dogState = "ear" -- 2688
			self.dogT = 18 -- 2689
			self.dogTargetX = p.x -- 2690
			self:flashSet("狗转耳朵", 0.8) -- 2691
		end -- 2691
		return -- 2693
	end -- 2693
	if self.dogState == "ear" then -- 2693
		self.dogT = self.dogT - 1 -- 2696
		if self.dogT <= 0 then -- 2696
			self.dogState = "chase" -- 2698
			self.dogTargetX = p.x -- 2699
			self:flashSet("狗追来了", 1.4) -- 2700
		end -- 2700
		return -- 2702
	end -- 2702
	if self.dogState == "chase" then -- 2702
		local dir = p.x > self.dogX and 1 or -1 -- 2705
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2706
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2706
			self:caught() -- 2708
			self.dogState = "sniff" -- 2709
			self.dogT = 60 -- 2710
		elseif dist > dog.range * 1.5 or p.crouch then -- 2710
			self.dogState = "sniff" -- 2712
			self.dogT = 60 -- 2713
			self:flashSet("狗停下了", 0.9) -- 2714
		end -- 2714
		return -- 2716
	end -- 2716
	if self.dogState == "sniff" then -- 2716
		self.dogT = self.dogT - 1 -- 2719
		if self.dogT <= 0 then -- 2719
			self.dogState = "back" -- 2721
		end -- 2721
		return -- 2723
	end -- 2723
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2726
	self.dogX = self.dogX + dir * dog.speed * dt -- 2727
	if math.abs(self.dogX - dog.x0) < 2 then -- 2727
		self.dogX = dog.x0 -- 2729
		self.dogState = "patrol" -- 2730
	end -- 2730
end -- 2670
function Play.prototype.caught(self) -- 2734
	self.caughtT = 1 -- 2735
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2736
end -- 2734
function Play.prototype.recoverFromCaught(self) -- 2740
	local p = self.player -- 2741
	p.x = self.ox + 140 -- 2742
	p.y = 0 -- 2743
	p.vy = 0 -- 2744
	p.vx = 0 -- 2745
	p.onGround = true -- 2746
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2746
		self.scavX = self.room.scavenger.x0 -- 2748
		self.scavState = "patrol" -- 2749
		self.scavSee = 0 -- 2750
		self.scavChase = false -- 2751
		self.scavT = 0 -- 2752
	end -- 2752
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2752
		self.dogX = self.room.story.dog.x0 -- 2755
		self.dogState = "patrol" -- 2756
		self.dogT = 0 -- 2757
	end -- 2757
	self.cam.x = p.x -- 2759
	self.cam.y = p.y + CAM_LOOK_UP -- 2760
	self:flashSet("回到安全点", 1.2) -- 2761
end -- 2740
function Play.prototype.updateGate(self) -- 2765
	if self.room.key ~= "checkpoint" then -- 2765
		self.gateOpen = false -- 2767
		return -- 2768
	end -- 2768
	local function inZone(x) -- 2770
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2770
	end -- 2770
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2771
end -- 2765
function Play.prototype.addItem(self, kind) -- 2777
	local inv = self.run.inventory -- 2778
	if kind == "shield" then -- 2778
		if inv.shield >= TOOL_CAP then -- 2778
			return false -- 2781
		end -- 2781
		inv.shield = inv.shield + 1 -- 2783
		return true -- 2784
	end -- 2784
	if kind == "wedge" then -- 2784
		if inv.wedge >= CONSUMABLE_CAP then -- 2784
			return false -- 2788
		end -- 2788
		inv.wedge = inv.wedge + 1 -- 2790
		return true -- 2791
	end -- 2791
	if kind == "ammo" then -- 2791
		if inv.ammo >= CONSUMABLE_CAP then -- 2791
			return false -- 2795
		end -- 2795
		inv.ammo = inv.ammo + 1 -- 2797
		return true -- 2798
	end -- 2798
	if kind == "scrap" then -- 2798
		inv.scrap = inv.scrap + 1 -- 2802
		return true -- 2803
	end -- 2803
	if kind == "wood" then -- 2803
		inv.wood = inv.wood + 1 -- 2806
		return true -- 2807
	end -- 2807
	if kind == "bell" then -- 2807
		inv.bell = inv.bell + 1 -- 2810
		return true -- 2811
	end -- 2811
	if kind == "pass" then -- 2811
		inv.pass = inv.pass + 1 -- 2814
		return true -- 2815
	end -- 2815
	if kind == "quickbelt" then -- 2815
		inv.quickbelt = inv.quickbelt + 1 -- 2818
		return true -- 2819
	end -- 2819
	return false -- 2821
end -- 2777
function Play.prototype.findBox(self, id) -- 2824
	local i = 0 -- 2825
	do -- 2825
		i = 0 -- 2826
		while i < #self.boxes do -- 2826
			if self.boxes[i + 1].id == id then -- 2826
				return self.boxes[i + 1] -- 2828
			end -- 2828
			i = i + 1 -- 2826
		end -- 2826
	end -- 2826
	return nil -- 2831
end -- 2824
function Play.prototype.findWedgeTarget(self) -- 2835
	local best = nil -- 2836
	local bestD = 0 -- 2837
	local i = 0 -- 2838
	do -- 2838
		i = 0 -- 2839
		while i < #self.boxes do -- 2839
			do -- 2839
				local b = self.boxes[i + 1] -- 2840
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2840
					goto __continue417 -- 2842
				end -- 2842
				if not self:nearBox(b, 26) then -- 2842
					goto __continue417 -- 2845
				end -- 2845
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2847
				if best == nil or d < bestD then -- 2847
					best = b -- 2849
					bestD = d -- 2850
				end -- 2850
			end -- 2850
			::__continue417:: -- 2850
			i = i + 1 -- 2839
		end -- 2839
	end -- 2839
	return best -- 2853
end -- 2835
function Play.prototype.stepCraft(self, input) -- 2861
	local inv = self.run.inventory -- 2862
	local ____opt_41 = self.run.trial -- 2862
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2863
	if self.craftT > 0 then -- 2863
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2863
			self.craftT = 0 -- 2867
			self:flashSet("制作中断", 0.8) -- 2868
			return true -- 2869
		end -- 2869
		self.craftT = self.craftT + 1 -- 2871
		if self.craftT >= required then -- 2871
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2871
				inv.scrap = inv.scrap - 1 -- 2874
				inv.wedge = inv.wedge + 1 -- 2875
				self:flashSet("制得木楔", 1.2) -- 2876
				self:log("制木楔") -- 2877
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2878
			end -- 2878
			self.craftT = 0 -- 2880
		end -- 2880
		return true -- 2882
	end -- 2882
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2882
		self.craftT = 1 -- 2885
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2886
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2887
		return true -- 2888
	end -- 2888
	return false -- 2890
end -- 2861
function Play.prototype.nearBox(self, b, reach) -- 2893
	local p = self.player -- 2894
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2895
end -- 2893
function Play.prototype.findInteract(self) -- 2901
	local p = self.player -- 2902
	local best = nil -- 2903
	local bestD = 1000000000 -- 2904
	local i = 0 -- 2905
	do -- 2905
		i = 0 -- 2906
		while i < #self.boxes do -- 2906
			do -- 2906
				local b = self.boxes[i + 1] -- 2907
				if b.interact == nil or b.broken == true then -- 2907
					goto __continue430 -- 2909
				end -- 2909
				if not self:nearBox(b, b.interact.reach or 27) then -- 2909
					goto __continue430 -- 2912
				end -- 2912
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2914
				if d < bestD then -- 2914
					bestD = d -- 2916
					best = b -- 2917
				end -- 2917
			end -- 2917
			::__continue430:: -- 2917
			i = i + 1 -- 2906
		end -- 2906
	end -- 2906
	return best -- 2920
end -- 2901
function Play.prototype.stepCampaign(self, dt, input) -- 2924
	local wr = self.room -- 2925
	local p = self.player -- 2926
	if self.reloadT > 0 then -- 2926
		self.reloadT = self.reloadT - 1 -- 2928
	end -- 2928
	if self.bracedShield ~= nil then -- 2928
		self.bracedShield.x = p.x + p.facing * 26 -- 2932
		self.bracedShield.y = p.y -- 2933
		local shBox = __TS__ArrayFind( -- 2934
			self.boxes, -- 2934
			function(____, b) return b.id == "braced_shield" end -- 2934
		) -- 2934
		if shBox ~= nil then -- 2934
			shBox.x0 = self.bracedShield.x - 15 -- 2936
			shBox.x1 = self.bracedShield.x + 15 -- 2937
			shBox.y0 = self.bracedShield.y -- 2938
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2939
		end -- 2939
	end -- 2939
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2939
		self.run.route = "drygoods" -- 2945
		self.run.joined = false -- 2946
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2947
		self:log("转布行线") -- 2948
	end -- 2948
	if wr.key == "escort3" then -- 2948
		local benchX = wr.minX + 560 -- 2952
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 2953
		if nearBench and input.interact.pressed then -- 2953
			self:openCraftBench() -- 2955
		end -- 2955
	end -- 2955
	local i = 0 -- 2959
	do -- 2959
		i = 0 -- 2960
		while i < #self.pickups do -- 2960
			do -- 2960
				local pk = self.pickups[i + 1] -- 2961
				if self.run.taken[pk.id] == true then -- 2961
					goto __continue443 -- 2963
				end -- 2963
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 2965
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 2966
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 2966
					if not self:addItem(pk.kind) then -- 2966
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 2970
						self:log("满包拒绝 " .. pk.kind) -- 2971
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 2972
						goto __continue443 -- 2973
					end -- 2973
					self.run.taken[pk.id] = true -- 2975
					self:flashSet("拾取 " .. pk.label, 1) -- 2976
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 2977
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 2978
				end -- 2978
			end -- 2978
			::__continue443:: -- 2978
			i = i + 1 -- 2960
		end -- 2960
	end -- 2960
	if not self:stepCraft(input) and input.interact.pressed then -- 2960
		self:campaignInteract() -- 2982
	end -- 2982
	self:stepCampaignCart(dt, input) -- 2984
	self:stepCampaignGoal() -- 2985
	self:campaignCheckpoint() -- 2986
end -- 2924
function Play.prototype.campaignCheckpoint(self) -- 2990
	local i = 0 -- 2991
	do -- 2991
		i = 0 -- 2992
		while i < #self.room.marks do -- 2992
			do -- 2992
				local m = self.room.marks[i + 1] -- 2993
				if m.kind ~= 0 then -- 2993
					goto __continue450 -- 2995
				end -- 2995
				local dx = self.player.x - m.x -- 2997
				local dy = self.player.y - m.y -- 2998
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 2998
					self.checkpoint = m.x -- 3000
					self:captureCheckpoint(m.x) -- 3001
					self:flashSet("检查点", 1) -- 3002
				end -- 3002
			end -- 3002
			::__continue450:: -- 3002
			i = i + 1 -- 2992
		end -- 2992
	end -- 2992
end -- 2990
function Play.prototype.campaignInteract(self) -- 3008
	local b = self:findInteract() -- 3009
	if b ~= nil then -- 3009
		self:useInteract(b) -- 3011
		return -- 3012
	end -- 3012
	local inv = self.run.inventory -- 3014
	if inv.wedge > 0 then -- 3014
		local w = self:findWedgeTarget() -- 3016
		if w ~= nil then -- 3016
			if w.breakable ~= nil then -- 3016
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 3016
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 3019
			end -- 3019
			inv.wedge = inv.wedge - 1 -- 3021
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3022
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3024
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3025
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3026
			return -- 3027
		end -- 3027
	end -- 3027
	if inv.ammo > 0 and self.reloadT > 0 then -- 3027
		self.reloadT = 0 -- 3032
		self:closeReloadPuzzle() -- 3033
		inv.ammo = inv.ammo - 1 -- 3034
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3035
		self:log("用备用弹包") -- 3036
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3037
		return -- 3038
	end -- 3038
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3038
		local p = self.player -- 3042
		self.bracedShield = { -- 3043
			x = p.x + p.facing * 26, -- 3043
			y = p.y, -- 3043
			w = 30, -- 3043
			h = 64, -- 3043
			hp = 1 -- 3043
		} -- 3043
		local ____self_boxes_45 = self.boxes -- 3043
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 3044
			x0 = self.bracedShield.x - 15, -- 3045
			x1 = self.bracedShield.x + 15, -- 3045
			y0 = p.y, -- 3046
			y1 = p.y + 64, -- 3046
			depth = {min = -46, max = 46}, -- 3046
			label = "架起的残盾", -- 3046
			id = "braced_shield", -- 3046
			soft = true -- 3047
		} -- 3047
		inv.shield = inv.shield - 1 -- 3050
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3051
		self:log("架残盾") -- 3052
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3053
		return -- 3054
	end -- 3054
	if inv.pass > 0 and self.run.joined == false then -- 3054
		inv.pass = inv.pass - 1 -- 3057
		self.run.joined = true -- 3058
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3059
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3060
		return -- 3061
	end -- 3061
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3063
end -- 3008
function Play.prototype.useInteract(self, b) -- 3066
	local kind = b.interact == nil and "" or b.interact.kind -- 3067
	local wr = self.room -- 3068
	if kind == "open_board" then -- 3068
		b.broken = true -- 3070
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3071
		for ____, cover in ipairs(self.boxes) do -- 3072
			if cover.id == "s2_board_cover" then -- 3072
				cover.broken = false -- 3074
				cover.hidden = false -- 3075
			end -- 3075
		end -- 3075
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3078
		self.run.joined = true -- 3079
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3080
		self:log("放下窗板") -- 3081
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3082
		return -- 3083
	end -- 3083
	if kind == "lower_curtain" then -- 3083
		for ____, curtain in ipairs(self.boxes) do -- 3086
			if curtain.id == "c2_curtain" then -- 3086
				curtain.broken = false -- 3088
				curtain.hidden = false -- 3089
			end -- 3089
		end -- 3089
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3092
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3093
		self:log("放下木帘") -- 3094
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3095
		return -- 3096
	end -- 3096
	if kind == "raise_latch" then -- 3096
		if wr.key == "c2-granary" and not self.cartDocked then -- 3096
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3100
			return -- 3101
		end -- 3101
		b.broken = true -- 3103
		self.objectiveDone = true -- 3104
		if wr.key == "c1-yard" then -- 3104
			self.run.c1Latch = true -- 3107
			self.run.joined = true -- 3108
		else -- 3108
			self.run.c2Latch = true -- 3110
			self.run.joined = true -- 3111
		end -- 3111
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3113
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3114
		self:log("抬闩") -- 3115
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3116
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3117
	end -- 3117
end -- 3066
function Play.prototype.stepCampaignCart(self, dt, input) -- 3122
	local wr = self.room -- 3123
	local c = wr.cart -- 3124
	if c.bodyW <= 0 then -- 3124
		return -- 3126
	end -- 3126
	local p = self.player -- 3128
	local handleX = self.cartAxle + c.handleOffset -- 3129
	if not self.gripping then -- 3129
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 3129
			self.gripping = true -- 3133
			self:flashSet("握住车柄 · A/D 推", 1) -- 3134
		end -- 3134
		return -- 3136
	end -- 3136
	if input.interact.pressed then -- 3136
		self.gripping = false -- 3139
		self:flashSet("松手", 0.5) -- 3140
		return -- 3141
	end -- 3141
	if not self.cartDocked then -- 3141
		if input.moveX ~= 0 and not self:stuckCart() then -- 3141
			self.cartAxle = math.max( -- 3145
				c.startX, -- 3145
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3145
			) -- 3145
		end -- 3145
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3145
			self.cartExposed = true -- 3150
			local gun = nil -- 3151
			local gi = 0 -- 3152
			do -- 3152
				gi = 0 -- 3153
				while gi < #self.enemies do -- 3153
					local e = self.enemies[gi + 1] -- 3154
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3154
						gun = e -- 3156
						break -- 3157
					end -- 3157
					gi = gi + 1 -- 3153
				end -- 3153
			end -- 3153
			if gun ~= nil then -- 3153
				self:campaignEnemyFire(gun) -- 3161
			end -- 3161
		end -- 3161
		p.x = self.cartAxle + c.handleOffset -- 3164
		p.y = c.baseY + (c.depth or 0) -- 3165
		p.vx = 0 -- 3166
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3166
			self.cartAxle = c.endX -- 3168
			self.cartDocked = true -- 3169
			self.gripping = false -- 3170
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3171
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3172
			self:flashSet("车轮入窝", 1.2) -- 3173
			self:log("车轮入窝") -- 3174
		end -- 3174
	end -- 3174
end -- 3122
function Play.prototype.stuckCart(self) -- 3180
	local i = 0 -- 3181
	do -- 3181
		i = 0 -- 3182
		while i < #self.boxes do -- 3182
			do -- 3182
				local b = self.boxes[i + 1] -- 3183
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3183
					goto __continue489 -- 3185
				end -- 3185
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 3187
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3187
					return true -- 3189
				end -- 3189
			end -- 3189
			::__continue489:: -- 3189
			i = i + 1 -- 3182
		end -- 3182
	end -- 3182
	return false -- 3192
end -- 3180
function Play.prototype.stepCampaignGoal(self) -- 3196
	local wr = self.room -- 3197
	local c = wr.campaign -- 3198
	if c == nil then -- 3198
		return -- 3200
	end -- 3200
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3200
		self.objectiveDone = true -- 3203
	end -- 3203
	if c.goal == "reach_exit" then -- 3203
		self.objectiveDone = true -- 3206
	end -- 3206
	if not self.objectiveDone then -- 3206
		return -- 3209
	end -- 3209
	local p = self.player -- 3211
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3212
	if p.x < c.exitX or not partnerOk then -- 3212
		return -- 3214
	end -- 3214
	if self.run.story.segments[wr.key] ~= true then -- 3214
		self.run.story.segments[wr.key] = true -- 3218
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3219
	end -- 3219
	if wr.key == "escort5" then -- 3219
		self.escortDone = true -- 3223
		self.run.story.escortDone = true -- 3224
	end -- 3224
	if c.next ~= nil and c.next ~= "" then -- 3224
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3227
		self:flashSet("过关 · " .. c.next, 1.2) -- 3228
	elseif not self.run.finished then -- 3228
		self.run.finished = true -- 3230
		self:flashSet( -- 3231
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3231
			2 -- 3231
		) -- 3231
		self:log("C2 灰盒完成") -- 3232
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3233
	end -- 3233
end -- 3196
function Play.prototype.stepCampaignPartner(self, dt) -- 3238
	local a = self.partner -- 3239
	local wr = self.room -- 3240
	local cp = wr.companion -- 3241
	if not a.alive then -- 3241
		return -- 3243
	end -- 3243
	local p = self.player -- 3245
	if self.craftBench.active then -- 3245
		a.vx = 0 -- 3248
		return -- 3249
	end -- 3249
	local wait = false -- 3251
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3252
	local targetDepth = p.depth -- 3253
	if self.run.joined == false then -- 3253
		wait = true -- 3255
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3256
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3257
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3257
		wait = true -- 3259
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3260
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3261
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3261
		wait = true -- 3263
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3264
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3265
	end -- 3265
	if self.partnerStuck > 0.3 then -- 3265
		a.x = a.x + a.facing * 44 -- 3269
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3270
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3271
		self.partnerLaneHold = 1.1 -- 3272
		self.partnerStuck = 0 -- 3273
	end -- 3273
	if self.partnerLaneHold > 0 then -- 3273
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3276
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3277
	end -- 3277
	local dx = targetX - a.x -- 3279
	if not wait and math.abs(dx) > 74 then -- 3279
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3281
		local before = a.x -- 3282
		a.vx = dx > 0 and speed or -speed -- 3283
		a.facing = dx > 0 and 1 or -1 -- 3284
		self:slideX(a, a.vx * dt) -- 3285
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3285
			a.vy = CHILD_JUMP -- 3288
			a.onGround = false -- 3289
		end -- 3289
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3291
	else -- 3291
		a.vx = 0 -- 3293
		self.partnerStuck = 0 -- 3294
	end -- 3294
	local dz = targetDepth - a.depth -- 3296
	if math.abs(dz) > 6 then -- 3296
		local step = math.max( -- 3298
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3298
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3298
		) -- 3298
		a.depth = a.depth + step -- 3299
	end -- 3299
	a.depthSpeed = 0 -- 3301
	a.h = CHILD_H -- 3302
	a.crouch = false -- 3303
	self:fallY(a, dt) -- 3304
end -- 3238
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3308
	local p = self.player -- 3309
	local i = 0 -- 3310
	do -- 3310
		i = 0 -- 3311
		while i < #self.enemies do -- 3311
			do -- 3311
				local ____opt_46 = self.run.trial -- 3311
				if ____opt_46 and ____opt_46.lost then -- 3311
					return -- 3312
				end -- 3312
				local e = self.enemies[i + 1] -- 3313
				if not e.alive then -- 3313
					goto __continue516 -- 3315
				end -- 3315
				if e.hitT > 0 then -- 3315
					e.hitT = e.hitT - dt -- 3318
				end -- 3318
				if e.kind == "target" then -- 3318
					if not e.alive and e.hitT <= 0 then -- 3318
						e.alive = true -- 3323
					end -- 3323
					goto __continue516 -- 3325
				end -- 3325
				if e.kind == "breaker" then -- 3325
					self:stepBreaker(e, dt) -- 3328
					goto __continue516 -- 3329
				end -- 3329
				if e.kind == "shield" then -- 3329
					self:stepShield(e, dt, input) -- 3332
					goto __continue516 -- 3333
				end -- 3333
				local dx = e.x - p.x -- 3336
				if not e.awake then -- 3336
					if math.abs(dx) > 520 then -- 3336
						goto __continue516 -- 3339
					end -- 3339
					e.awake = true -- 3341
					e.fireCd = 48 -- 3342
					goto __continue516 -- 3343
				end -- 3343
				if math.abs(dx) > ENEMY_RANGE then -- 3343
					goto __continue516 -- 3346
				end -- 3346
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3346
					goto __continue516 -- 3351
				end -- 3351
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3351
					goto __continue516 -- 3354
				end -- 3354
				if self:blockedShot(e, p) then -- 3354
					if e.warnT > 0 then -- 3354
						e.warnT = 0 -- 3360
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3361
					end -- 3361
					goto __continue516 -- 3363
				end -- 3363
				if e.warnT > 0 then -- 3363
					e.warnT = e.warnT - 1 -- 3366
					if e.warnT <= 0 then -- 3366
						self:campaignEnemyFire(e) -- 3368
					end -- 3368
				elseif e.fireCd > 0 then -- 3368
					e.fireCd = e.fireCd - 1 -- 3371
					if e.fireCd <= 0 then -- 3371
						e.warnT = WARN_TICKS -- 3373
					end -- 3373
				else -- 3373
					e.fireCd = 40 -- 3376
				end -- 3376
			end -- 3376
			::__continue516:: -- 3376
			i = i + 1 -- 3311
		end -- 3311
	end -- 3311
end -- 3308
function Play.prototype.blockedShot(self, e, p) -- 3382
	local eDepth = e.depth or 0 -- 3383
	local ex = e.x -- 3384
	local ey = e.y + e.h * 0.62 -- 3386
	local px = p.x -- 3387
	local py = p.y + p.h * 0.55 -- 3388
	local dx = px - ex -- 3389
	local dyScreen = py + p.depth - (ey + eDepth) -- 3390
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3391
	if len < 0.01 then -- 3391
		return false -- 3393
	end -- 3393
	local ray = { -- 3397
		x = ex, -- 3398
		y = ey, -- 3398
		dx = dx / len, -- 3399
		dy = (py - ey) / len, -- 3399
		depth = eDepth, -- 3400
		dDepth = (p.depth - eDepth) / len -- 3400
	} -- 3400
	local best = -1 -- 3402
	local j = 0 -- 3403
	do -- 3403
		j = 0 -- 3404
		while j < #self.boxes do -- 3404
			do -- 3404
				local b = self.boxes[j + 1] -- 3405
				if b.broken == true or b.passable == true or b.hidden == true then -- 3405
					goto __continue539 -- 3407
				end -- 3407
				if b.id == "braced_shield" then -- 3407
					goto __continue539 -- 3412
				end -- 3412
				local t = hitBox(ray, b) -- 3414
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3414
					best = t -- 3418
				end -- 3418
			end -- 3418
			::__continue539:: -- 3418
			j = j + 1 -- 3404
		end -- 3404
	end -- 3404
	return best >= 0 -- 3421
end -- 3382
function Play.prototype.campaignEnemyFire(self, e) -- 3424
	local p = self.player -- 3425
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3426
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3426
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3426
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3428
		self.boxes = __TS__ArrayFilter( -- 3429
			self.boxes, -- 3429
			function(____, b) return b.id ~= "braced_shield" end -- 3429
		) -- 3429
		self.bracedShield = nil -- 3430
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3431
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3432
		return -- 3433
	end -- 3433
	if self:blockedShot(e, p) then -- 3433
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3436
		return -- 3437
	end -- 3437
	local cover = self:blockedByCover(e, p) -- 3439
	if cover ~= nil and self.coverHug then -- 3439
		self.coveredFlash = 0.5 -- 3441
		self:flashSet("掩体挡下", 0.6) -- 3442
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3443
		return -- 3448
	end -- 3448
	if self.invulnT > 0 then -- 3448
		return -- 3451
	end -- 3451
	local ____opt_50 = self.run.trial -- 3451
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3453
	self.craftT = 0 -- 3454
	self.hp = self.hp - 1 -- 3455
	self:emit("actorHit", { -- 3456
		target = "player", -- 3456
		amount = 1, -- 3456
		hp = self.hp, -- 3456
		maxHp = self.maxHp, -- 3456
		enemyX = e.x -- 3456
	}) -- 3456
	self:flashSet( -- 3457
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3457
		0.8 -- 3457
	) -- 3457
	if self.hp <= 0 then -- 3457
		self:campaignFailed() -- 3459
	end -- 3459
end -- 3424
function Play.prototype.stepShield(self, e, dt, input) -- 3464
	local p = self.player -- 3465
	local dx = p.x - e.x -- 3466
	local adx = math.abs(dx) -- 3467
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3470
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3471
	if adx > 150 then -- 3471
		local before = e.x -- 3473
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3474
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3474
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3477
		end -- 3477
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3477
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3482
		local rollDodges = p.rollT > 0 and fromFront -- 3483
		if not rollDodges and self.invulnT <= 0 then -- 3483
			local ____opt_52 = self.run.trial -- 3483
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3485
			self.craftT = 0 -- 3486
			self.hp = self.hp - 1 -- 3487
			self:emit("actorHit", { -- 3488
				target = "player", -- 3488
				amount = 1, -- 3488
				hp = self.hp, -- 3488
				maxHp = self.maxHp, -- 3488
				enemyX = e.x -- 3488
			}) -- 3488
			self:flashSet( -- 3489
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3489
				0.8 -- 3489
			) -- 3489
			if self.hp <= 0 then -- 3489
				self:campaignFailed() -- 3491
				return -- 3492
			end -- 3492
		end -- 3492
		e.swingT = 70 -- 3495
	end -- 3495
	if (e.swingT or 0) > 0 then -- 3495
		e.swingT = (e.swingT or 0) - 1 -- 3498
	end -- 3498
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3498
		local dd = p.depth - (e.depth or 0) -- 3501
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3502
	end -- 3502
end -- 3464
function Play.prototype.stepBreaker(self, e, dt) -- 3507
	local p = self.player -- 3508
	if e.awake ~= true then -- 3508
		if math.abs(p.x - e.x) < 560 then -- 3508
			e.awake = true -- 3511
		else -- 3511
			return -- 3513
		end -- 3513
	end -- 3513
	local target = nil -- 3516
	local bestD = 1000000000 -- 3517
	local i = 0 -- 3518
	do -- 3518
		i = 0 -- 3519
		while i < #self.boxes do -- 3519
			do -- 3519
				local b = self.boxes[i + 1] -- 3520
				if b.breakable == nil or b.broken == true then -- 3520
					goto __continue563 -- 3522
				end -- 3522
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3524
				if d < bestD then -- 3524
					bestD = d -- 3526
					target = b -- 3527
				end -- 3527
			end -- 3527
			::__continue563:: -- 3527
			i = i + 1 -- 3519
		end -- 3519
	end -- 3519
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3530
	local dx = tx - e.x -- 3531
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3532
	if math.abs(dx) > reach then -- 3532
		local before = e.x -- 3534
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3535
		if math.abs(e.x - before) < 0.3 then -- 3535
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3537
		end -- 3537
	elseif (e.swingT or 0) <= 0 then -- 3537
		e.swingT = 64 -- 3540
		if target ~= nil then -- 3540
			self:damageProp(target, 2) -- 3542
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3542
			local ____opt_54 = self.run.trial -- 3542
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3544
			self.craftT = 0 -- 3545
			self.hp = self.hp - 1 -- 3546
			self:emit("actorHit", { -- 3547
				target = "player", -- 3547
				amount = 1, -- 3547
				hp = self.hp, -- 3547
				maxHp = self.maxHp, -- 3547
				enemyX = e.x -- 3547
			}) -- 3547
			self:flashSet("破障手近身", 0.8) -- 3548
			if self.hp <= 0 then -- 3548
				self:campaignFailed() -- 3550
				return -- 3551
			end -- 3551
		end -- 3551
	end -- 3551
	if (e.swingT or 0) > 0 then -- 3551
		e.swingT = (e.swingT or 0) - 1 -- 3556
	end -- 3556
end -- 3507
function Play.prototype.campaignFailed(self) -- 3560
	if self.run.trial ~= nil then -- 3560
		self.run.trial.lost = true -- 3562
		self.wantRoom = "" -- 3563
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3564
		return -- 3565
	end -- 3565
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3565
		self:restartEscortFromDeath() -- 3570
		return -- 3571
	end -- 3571
	local p = self.player -- 3573
	self.hp = self.maxHp -- 3574
	self.invulnT = INVULN_RESPAWN_TICKS -- 3575
	self.reloadT = 0 -- 3576
	self:closeReloadPuzzle() -- 3577
	self.gripping = false -- 3578
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3579
	self:log("被击倒") -- 3580
	p.x = self.room.minX + 90 -- 3581
	p.y = 0 -- 3582
	p.depth = 0 -- 3583
	p.vx = 0 -- 3584
	p.vy = 0 -- 3585
	p.onGround = true -- 3586
	p.rollT = 0 -- 3587
	self.partner.x = p.x - 50 -- 3588
	self.partner.y = 0 -- 3589
	self.partner.depth = 0 -- 3590
	self.cam.x = p.x -- 3591
	local i = 0 -- 3592
	do -- 3592
		i = 0 -- 3593
		while i < #self.enemies do -- 3593
			do -- 3593
				local e = self.enemies[i + 1] -- 3594
				if not e.alive then -- 3594
					goto __continue577 -- 3596
				end -- 3596
				e.x = e.homeX == nil and e.x or e.homeX -- 3598
				e.warnT = 0 -- 3599
				e.fireCd = 40 -- 3600
				e.swingT = 0 -- 3601
				e.awake = false -- 3602
			end -- 3602
			::__continue577:: -- 3602
			i = i + 1 -- 3593
		end -- 3593
	end -- 3593
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3604
end -- 3560
function Play.prototype.isEscortRoom(self) -- 3608
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3609
end -- 3608
function Play.prototype.restartEscortFromDeath(self) -- 3617
	local story = self.run.story -- 3618
	local inv = self.run.inventory -- 3619
	self.hp = self.maxHp -- 3620
	story.hp = self.maxHp -- 3621
	story.cp = nil -- 3622
	self.checkpointSnap = nil -- 3623
	story.carry = false -- 3624
	self.carryOn = false -- 3625
	story.craftedWeapon = "" -- 3626
	self.equippedWeapon = "standard_gun" -- 3627
	story.escortDone = false -- 3628
	self.escortDone = false -- 3629
	story.segments = {} -- 3630
	inv.wood = 0 -- 3631
	inv.bell = 0 -- 3632
	inv.scrap = 0 -- 3633
	inv.wedge = 0 -- 3634
	inv.ammo = 0 -- 3635
	inv.quickbelt = 0 -- 3636
	inv.shield = 0 -- 3637
	inv.pass = 0 -- 3638
	local taken = self.run.taken -- 3639
	local keys = __TS__ObjectKeys(taken) -- 3640
	local i = 0 -- 3641
	do -- 3641
		i = 0 -- 3642
		while i < #keys do -- 3642
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3642
				__TS__Delete(taken, keys[i + 1]) -- 3644
			end -- 3644
			i = i + 1 -- 3642
		end -- 3642
	end -- 3642
	self.run.joined = true -- 3647
	self.reloadT = 0 -- 3648
	self:closeReloadPuzzle() -- 3649
	self.gripping = false -- 3650
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3651
	self:log("男主线失败 · 回 escort1") -- 3652
	self:emit("campaignFailed", { -- 3653
		room = self.room.key, -- 3654
		hp = 0, -- 3654
		maxHp = self.maxHp, -- 3654
		reset = true, -- 3655
		to = "escort1", -- 3655
		route = self.storyRoute -- 3655
	}) -- 3655
	self:requestRoom("escort1", "男主线失败重开") -- 3657
end -- 3617
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3661
	local i = 0 -- 3662
	do -- 3662
		i = 0 -- 3663
		while i < #self.enemies do -- 3663
			do -- 3663
				if i == skipIndex then -- 3663
					goto __continue586 -- 3665
				end -- 3665
				local e = self.enemies[i + 1] -- 3667
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3667
					goto __continue586 -- 3669
				end -- 3669
				e.fireCd = 150 -- 3671
				e.warnT = 0 -- 3672
			end -- 3672
			::__continue586:: -- 3672
			i = i + 1 -- 3663
		end -- 3663
	end -- 3663
end -- 3661
function Play.prototype.stepEnemies(self, dt, input) -- 3676
	local i = 0 -- 3677
	do -- 3677
		i = 0 -- 3678
		while i < #self.enemies do -- 3678
			local e = self.enemies[i + 1] -- 3679
			if e.hitT > 0 then -- 3679
				e.hitT = e.hitT - dt -- 3681
			end -- 3681
			i = i + 1 -- 3678
		end -- 3678
	end -- 3678
	if self.coveredFlash > 0 then -- 3678
		self.coveredFlash = self.coveredFlash - dt -- 3685
	end -- 3685
	if self.isCampaign then -- 3685
		self:stepCampaignEnemies(dt, input) -- 3688
		return -- 3689
	end -- 3689
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3689
		return -- 3693
	end -- 3693
	do -- 3693
		i = 0 -- 3695
		while i < #self.enemies do -- 3695
			do -- 3695
				local e = self.enemies[i + 1] -- 3696
				if not e.alive then -- 3696
					goto __continue597 -- 3698
				end -- 3698
				if e.warnT > 0 then -- 3698
					e.warnT = e.warnT - 1 -- 3701
					if e.warnT <= 0 then -- 3701
						self:enemyFire(e, input) -- 3703
					end -- 3703
					goto __continue597 -- 3705
				end -- 3705
				if e.fireCd > 0 then -- 3705
					e.fireCd = e.fireCd - 1 -- 3708
					if e.fireCd <= 0 then -- 3708
						e.warnT = WARN_TICKS -- 3710
					end -- 3710
				else -- 3710
					e.warnT = WARN_TICKS -- 3714
				end -- 3714
			end -- 3714
			::__continue597:: -- 3714
			i = i + 1 -- 3695
		end -- 3695
	end -- 3695
end -- 3676
function Play.prototype.enemyFire(self, e, input) -- 3720
	local p = self.player -- 3721
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3721
		self:flashSet("枪声响在远处", 0.4) -- 3723
		e.fireCd = FIRE_COOLDOWN -- 3724
		return -- 3725
	end -- 3725
	local cover = self:blockedByCover(e, p) -- 3728
	local hugging = cover ~= nil -- 3729
	self.coverBlocking = hugging -- 3730
	local covered = hugging and input.cover.held -- 3731
	if covered then -- 3731
		self.coveredFlash = 0.5 -- 3733
		self:flashSet("掩体挡下", 0.5) -- 3734
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3735
		e.fireCd = FIRE_COOLDOWN -- 3740
		return -- 3741
	end -- 3741
	self.hp = self.hp - 1 -- 3743
	self:emit("actorHit", { -- 3744
		target = "player", -- 3744
		amount = 1, -- 3744
		hp = self.hp, -- 3744
		maxHp = self.maxHp, -- 3744
		enemyX = e.x -- 3744
	}) -- 3744
	self:flashSet( -- 3745
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3745
		0.7 -- 3745
	) -- 3745
	e.fireCd = FIRE_COOLDOWN -- 3746
	if self.hp <= 0 then -- 3746
		self:gateFailed() -- 3748
	end -- 3748
end -- 3720
function Play.prototype.blockedByCover(self, enemy, p) -- 3753
	local b = self:coverAt(p) -- 3754
	if b == nil then -- 3754
		return nil -- 3756
	end -- 3756
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3758
end -- 3753
function Play.prototype.gateFailed(self) -- 3762
	local ____temp_56 -- 3763
	if self.room.story == nil then -- 3763
		____temp_56 = nil -- 3763
	else -- 3763
		____temp_56 = self.room.story.gate -- 3763
	end -- 3763
	local g = ____temp_56 -- 3763
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3764
	self.hp = self.maxHp -- 3765
	self.gateTick = 0 -- 3766
	self.gateSpawned = 0 -- 3767
	self.enemies = {} -- 3768
	self.gateFailCount = self.gateFailCount + 1 -- 3769
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3771
	self.player.y = 0 -- 3772
	self.player.vy = 0 -- 3773
	self.player.depth = 0 -- 3774
	self.player.depthSpeed = 0 -- 3775
	self.player.onGround = true -- 3776
	self.player.crouch = false -- 3777
	self.player.h = SOLDIER_H -- 3778
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3779
	self.partner.y = 0 -- 3780
	self.partner.vy = 0 -- 3781
	self.partner.depth = 0 -- 3782
	self.partner.depthSpeed = 0 -- 3783
	self.partner.onGround = true -- 3784
	self.cam.x = self.player.x -- 3785
	self.phase = "gate-idle" -- 3786
	self.phaseTick = 0 -- 3787
	self.coverHug = false -- 3788
	self.coverBlocking = false -- 3789
	self.coverEntity = "" -- 3790
	self.gateNeedConfirm = true -- 3791
	self.gateRestartArmed = false -- 3792
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3793
end -- 3762
function Play.prototype.stepInteract(self, dt, input) -- 3796
	local p = self.player -- 3797
	local calmUsed = self.calmConsumed -- 3798
	self.calmConsumed = false -- 3799
	local calming = self.escort.state == "calming" -- 3801
	self.focusCart = false -- 3802
	if self.room.key == "outside" then -- 3802
		local c = self.room.cart -- 3804
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3805
		local dy = p.y - c.baseY -- 3806
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3807
	end -- 3807
	if not calmUsed and not calming then -- 3807
		self:stepCart(dt, input) -- 3811
	end -- 3811
	if calmUsed then -- 3811
		self:flashSet("安抚 · 敲两下", 0.8) -- 3816
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3816
		if self.knockT > 0 then -- 3816
			self.knocks = self.knocks + 1 -- 3820
		else -- 3820
			self.knocks = 1 -- 3822
		end -- 3822
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3824
		self.knockT = 1.2 -- 3825
		if self.knocks >= 2 then -- 3825
			self:flashSet("敲两下", 0.8) -- 3827
			self.knocks = 0 -- 3828
		else -- 3828
			self:flashSet("敲一下", 0.5) -- 3830
		end -- 3830
	elseif self.knockT > 0 then -- 3830
		self.knockT = self.knockT - dt -- 3833
		if self.knockT <= 0 then -- 3833
			self.knocks = 0 -- 3835
		end -- 3835
	end -- 3835
	local i = 0 -- 3840
	do -- 3840
		i = 0 -- 3841
		while i < #self.room.marks do -- 3841
			do -- 3841
				local m = self.room.marks[i + 1] -- 3842
				if m.kind ~= 0 then -- 3842
					goto __continue623 -- 3844
				end -- 3844
				local subjects = {self.partner, self.player} -- 3846
				local k = 0 -- 3847
				do -- 3847
					k = 0 -- 3848
					while k < #subjects do -- 3848
						do -- 3848
							local s = subjects[k + 1] -- 3849
							if not s.alive then -- 3849
								goto __continue626 -- 3851
							end -- 3851
							local dx = s.x - m.x -- 3853
							local dy = s.y - m.y -- 3854
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3854
								self.checkpoint = m.x -- 3856
								self.checkpointCartAxle = self.cartAxle -- 3857
								if self.isCampaign then -- 3857
									self:captureCheckpoint(m.x) -- 3860
								end -- 3860
								if self.cartDocked then -- 3860
									self:flashSet("检查点 · 车已落窝", 1) -- 3863
								else -- 3863
									self:flashSet("检查点 · 车还没到位", 1) -- 3865
								end -- 3865
							end -- 3865
						end -- 3865
						::__continue626:: -- 3865
						k = k + 1 -- 3848
					end -- 3848
				end -- 3848
			end -- 3848
			::__continue623:: -- 3848
			i = i + 1 -- 3841
		end -- 3841
	end -- 3841
	self:checkCarryGate() -- 3871
end -- 3796
function Play.prototype.stepVillage(self, dt, input) -- 3875
	if self.room.key ~= "village" then -- 3875
		return -- 3877
	end -- 3877
	local p = self.player -- 3879
	local bottle = self.room.bottle -- 3880
	local scav = self.room.scavenger -- 3881
	if not self.hasBottle and bottle ~= nil then -- 3881
		local dx = p.x - bottle.x -- 3885
		local dy = p.y + p.h * 0.5 - bottle.y -- 3886
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3886
			self.hasBottle = true -- 3888
			self:flashSet("拾起瓶子", 0.8) -- 3889
		end -- 3889
	end -- 3889
	if self.hasBottle then -- 3889
		if input.aim.held then -- 3889
			self.aimHold = self.aimHold + dt -- 3896
			if self.aimHold > 1.2 then -- 3896
				self.aimHold = 1.2 -- 3898
			end -- 3898
			local cached = self:bottleEnd() -- 3901
			self.bottleAimX = cached.x -- 3902
			self.bottleAimY = cached.y -- 3903
		elseif input.aim.released then -- 3903
			if self.aimHold < 0.12 then -- 3903
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3907
				self.aimHold = 0 -- 3908
			else -- 3908
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3910
				self:throwBottle(____end.x, ____end.y) -- 3911
				self.aimHold = 0 -- 3912
			end -- 3912
		end -- 3912
	else -- 3912
		self.aimHold = 0 -- 3916
		self.bottleAimX = -1 -- 3917
	end -- 3917
	local fly = self.bottleFly -- 3922
	if fly ~= nil then -- 3922
		fly.t = fly.t + dt -- 3924
		fly.x = fly.x0 + fly.vx * fly.t -- 3925
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 3926
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 3927
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 3927
			self:landBottle(fly) -- 3929
		end -- 3929
	end -- 3929
	if self.bottleLandT > 0 then -- 3929
		self.bottleLandT = self.bottleLandT - dt -- 3933
	end -- 3933
	if scav ~= nil then -- 3933
		self:stepScav(dt, scav) -- 3937
	end -- 3937
	local line = self.room.passLine -- 3940
	if line ~= nil and not self.passed and p.x >= line then -- 3940
		self.passed = true -- 3942
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 3943
	end -- 3943
	if self.passed and p.x >= self.ox + 640 then -- 3943
		self:requestRoom("forest", "过第一院出院") -- 3947
		self:flashSet("出院 · 北塔森林", 1.4) -- 3948
	end -- 3948
end -- 3875
function Play.prototype.bottleEnd(self) -- 3953
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 3954
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 3957
	return {x = aim.x, y = g} -- 3958
end -- 3953
function Play.prototype.throwBottle(self, tx, ty) -- 3962
	local p = self.player -- 3963
	local dir = tx >= p.x and 1 or -1 -- 3965
	p.facing = dir -- 3966
	local x0 = p.x + dir * 10 -- 3967
	local y0 = p.y + p.h * 0.7 -- 3968
	self.bottleTargetX = tx -- 3969
	self.bottleTargetY = ty -- 3970
	self.bottleSurfaceY = ty -- 3971
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 3972
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 3973
	self.bottleFly = { -- 3974
		x = x0, -- 3974
		y = y0, -- 3974
		x0 = x0, -- 3974
		y0 = y0, -- 3974
		vx = vx, -- 3974
		vy = vy, -- 3974
		t = 0 -- 3974
	} -- 3974
	self.hasBottle = false -- 3975
	self:flashSet("投出", 0.4) -- 3976
	self:emit( -- 3977
		"bottleThrown", -- 3977
		{ -- 3977
			fromX = x0, -- 3978
			fromY = y0, -- 3979
			targetX = tx, -- 3980
			targetY = ty, -- 3981
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 3982
		} -- 3982
	) -- 3982
end -- 3962
function Play.prototype.landBottle(self, fly) -- 3987
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 3988
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 3989
	local s = self.room.scavenger -- 3990
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 3991
	self.bottleFly = nil -- 3992
	self.bottleTargetX = -1 -- 3993
	self.bottleTargetY = 0 -- 3994
	self.bottleSurfaceY = -1 -- 3995
	self.bottleLandX = x -- 3996
	self.bottleLandY = y -- 3997
	self.bottleLandT = 0.9 -- 3998
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 3999
	self:hearBottle(x) -- 4000
end -- 3987
function Play.prototype.hearBottle(self, x) -- 4004
	local s = self.room.scavenger -- 4005
	if s == nil then -- 4005
		return -- 4007
	end -- 4007
	if math.abs(x - self.scavX) > s.range then -- 4007
		self:flashSet("落地 · 他没听见", 0.6) -- 4010
		return -- 4011
	end -- 4011
	self.scavState = "turn" -- 4013
	self.scavT = s.hearTicks -- 4014
	self.scavTargetX = x -- 4015
	self:flashSet("砖地一响 · 他转头", 0.9) -- 4016
end -- 4004
function Play.prototype.stepScav(self, dt, s) -- 4020
	if self.scavState == "chase" then -- 4020
		return -- 4023
	end -- 4023
	if self.scavState == "turn" then -- 4023
		self.scavT = self.scavT - 1 -- 4026
		if self.scavT <= 0 then -- 4026
			self.scavState = "walk" -- 4028
		end -- 4028
		return -- 4030
	end -- 4030
	if self.scavState == "walk" then -- 4030
		local d = self.scavTargetX - self.scavX -- 4033
		if math.abs(d) < 4 then -- 4033
			self.scavState = "stall" -- 4035
			self.scavT = s.stallTicks -- 4036
			return -- 4037
		end -- 4037
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4039
		return -- 4040
	end -- 4040
	if self.scavState == "stall" then -- 4040
		self.scavT = self.scavT - 1 -- 4043
		if self.scavT <= 0 then -- 4043
			self.scavState = "back" -- 4045
		end -- 4045
		return -- 4047
	end -- 4047
	if self.scavState == "back" then -- 4047
		local home = math.max( -- 4050
			s.x0, -- 4050
			math.min(s.x1, self.scavX) -- 4050
		) -- 4050
		if math.abs(home - self.scavX) < 2 then -- 4050
			self.scavState = "patrol" -- 4052
			return -- 4053
		end -- 4053
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4055
		return -- 4056
	end -- 4056
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4058
	if self.scavX >= s.x1 then -- 4058
		self.scavX = s.x1 -- 4060
		self.scavDir = -1 -- 4061
	elseif self.scavX <= s.x0 then -- 4061
		self.scavX = s.x0 -- 4063
		self.scavDir = 1 -- 4064
	end -- 4064
end -- 4020
function Play.prototype.stepCart(self, dt, input) -- 4072
	local p = self.player -- 4073
	local c = self.room.cart -- 4074
	if self.gripping then -- 4074
		if not input.interact.held then -- 4074
			self.gripping = false -- 4078
			self:flashSet("松开车把", 0.4) -- 4079
			return -- 4080
		end -- 4080
	else -- 4080
		if not input.interact.pressed then -- 4080
			return -- 4084
		end -- 4084
		if not self:cartHandleInReach(p) then -- 4084
			return -- 4087
		end -- 4087
		local track = c.depth or 0 -- 4089
		if self:limitDepth(p, track) ~= track then -- 4089
			return -- 4091
		end -- 4091
		p.depth = track -- 4093
		p.depthSpeed = 0 -- 4094
		self.gripping = true -- 4095
		self:flashSet("握住车把", 0.4) -- 4096
		return -- 4097
	end -- 4097
	if self.cartDocked then -- 4097
		return -- 4101
	end -- 4101
	local dir = input.moveX -- 4103
	if dir == 0 then -- 4103
		return -- 4105
	end -- 4105
	local lo = math.min(c.startX, c.endX) -- 4107
	local hi = math.max(c.startX, c.endX) -- 4108
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4109
	if next < lo then -- 4109
		next = lo -- 4111
	end -- 4111
	if next > hi then -- 4111
		next = hi -- 4114
	end -- 4114
	local delta = next - self.cartAxle -- 4116
	if delta == 0 then -- 4116
		return -- 4118
	end -- 4118
	self.cartAxle = next -- 4120
	p.x = p.x + delta -- 4121
	p.facing = dir > 0 and 1 or -1 -- 4122
	self:slideX(p, 0) -- 4123
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4123
		self.gripping = false -- 4125
		self:flashSet("跟不上了，脱手", 0.6) -- 4126
		return -- 4127
	end -- 4127
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4127
		self.cartDocked = true -- 4130
		self.gripping = false -- 4131
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4132
		self:flashSet("车轮落窝", 1.2) -- 4133
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4133
		self:flashSet("车轮回到起点", 0.5) -- 4135
	end -- 4135
end -- 4072
function Play.prototype.requestRoom(self, key, reason) -- 4143
	if self.wantRoom ~= "" then -- 4143
		return -- 4147
	end -- 4147
	self.wantRoom = key -- 4149
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4150
end -- 4143
function Play.prototype.checkCarryGate(self) -- 4157
	if self.room.key == "checkpoint" then -- 4157
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4157
			self.carryCartAxle = self.cartAxle -- 4160
			self.carryCartDocked = self.cartDocked -- 4161
			self:requestRoom("gate", "检查站出口") -- 4162
			self:flashSet("出检查站 · 城门", 1.2) -- 4163
		end -- 4163
		return -- 4165
	end -- 4165
	if self.room.key == "outside" then -- 4165
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4165
			self.carryCartAxle = self.cartAxle -- 4171
			self.carryCartDocked = self.cartDocked -- 4172
			self:requestRoom("village", "墙根走完") -- 4173
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4174
		end -- 4174
	end -- 4174
end -- 4157
function Play.prototype.aimAt(self, wx, wy) -- 4181
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4182
	self.aimX = s.x -- 4183
	self.aimY = s.y -- 4184
end -- 4181
function Play.prototype.shoot(self, a) -- 4187
	if self.isCampaign and self.reloadT > 0 then -- 4187
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4189
		return -- 4190
	end -- 4190
	local ox = a.x + a.facing * 8 -- 4192
	local muzzleY = a.y + a.h * 0.72 -- 4193
	local oy = muzzleY + a.depth -- 4194
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4196
	local dx = aim.x - ox -- 4199
	local dy = aim.y - oy -- 4200
	local len = math.sqrt(dx * dx + dy * dy) -- 4201
	if len < 0.001 then -- 4201
		dx = a.facing -- 4203
		dy = 0 -- 4204
	else -- 4204
		dx = dx / len -- 4206
		dy = dy / len -- 4207
	end -- 4207
	if dx ~= 0 then -- 4207
		a.facing = dx > 0 and 1 or -1 -- 4210
	end -- 4210
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4213
	local hitEnemy = self:raycastEnemies(ray) -- 4214
	local tEnemy = hitEnemy.t -- 4215
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4216
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4217
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 4218
	local tWall = solid.t -- 4219
	local rawEffect = self:consumeReloadEffect() -- 4221
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4222
	local reloadEffect = rawEffect -- 4223
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4225
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4226
	self.trace = { -- 4228
		x0 = ox, -- 4228
		y0 = oy, -- 4228
		x1 = ox + dx * t, -- 4228
		y1 = oy + dy * t, -- 4228
		hit = hit -- 4228
	} -- 4228
	self.traceT = 0.12 -- 4229
	self:applyFireDanger(ox) -- 4230
	local killed = false -- 4231
	if hit then -- 4231
		local i = hitEnemy.index -- 4233
		local e = self.enemies[i + 1] -- 4234
		local impactY = oy + dy * tEnemy -- 4235
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4236
		local shieldTop = e.y + (e.depth or 0) + 64 -- 4237
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4237
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4239
			e.hitT = 0.3 -- 4240
			self:flashSet( -- 4241
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4241
				0.8 -- 4241
			) -- 4241
			self:emit("shotResolved", { -- 4242
				hit = true, -- 4243
				enemyIndex = i, -- 4243
				enemyX = e.x, -- 4243
				aimX = aim.x, -- 4243
				aimY = aim.y, -- 4243
				impactX = ox + dx * t, -- 4244
				impactY = oy + dy * t, -- 4244
				shield = true -- 4244
			}) -- 4244
			self:beginReload() -- 4246
			return -- 4247
		end -- 4247
		e.alive = false -- 4249
		e.hitT = 0.4 -- 4250
		killed = true -- 4251
		self:flashSet("命中", 0.6) -- 4252
		self:dropFor(e) -- 4253
		if reloadEffect == "light" and weaponFx == "light" then -- 4253
			self:blindNearby(e, 160, i) -- 4255
		end -- 4255
		if reloadEffect == "push" then -- 4255
			e.x = e.x + a.facing * 46 -- 4258
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4259
		elseif reloadEffect == "echo" then -- 4259
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4261
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4262
		elseif reloadEffect == "light" then -- 4262
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4264
		end -- 4264
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4264
		self:damageProp(solid.box, 1) -- 4267
	else -- 4267
		self:flashSet("打空", 0.35) -- 4269
	end -- 4269
	if self.isCampaign then -- 4269
		self:beginReload() -- 4272
	end -- 4272
	self:emit("shotResolved", { -- 4274
		hit = hit, -- 4275
		enemyIndex = hit and hitEnemy.index or -1, -- 4276
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4277
		aimX = aim.x, -- 4278
		aimY = aim.y, -- 4279
		impactX = ox + dx * t, -- 4280
		impactY = oy + dy * t -- 4281
	}) -- 4281
end -- 4187
function Play.prototype.applyFireDanger(self, shotX) -- 4286
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4286
		return -- 4288
	end -- 4288
	local dangerX = shotX -- 4290
	local best = -1 -- 4291
	local bestD = 1000000000 -- 4292
	local i = 0 -- 4293
	do -- 4293
		i = 0 -- 4294
		while i < #self.enemies do -- 4294
			do -- 4294
				local e = self.enemies[i + 1] -- 4295
				if not e.alive then -- 4295
					goto __continue707 -- 4297
				end -- 4297
				local d = math.abs(e.x - self.partner.x) -- 4299
				if d < bestD then -- 4299
					bestD = d -- 4301
					best = i -- 4302
				end -- 4302
			end -- 4302
			::__continue707:: -- 4302
			i = i + 1 -- 4294
		end -- 4294
	end -- 4294
	if best >= 0 then -- 4294
		dangerX = self.enemies[best + 1].x -- 4306
	end -- 4306
	local exposed = self:childExposed(dangerX) -- 4308
	local before = self.escort.fear -- 4309
	local dangerId = self.nextDangerId -- 4310
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4311
	self.nextDangerId = self.nextDangerId + 1 -- 4312
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4313
	if after > before then -- 4313
		self:flashSet( -- 4315
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4315
			1 -- 4315
		) -- 4315
	elseif not exposed then -- 4315
		self:flashSet("枪声没够到她", 0.5) -- 4317
	end -- 4317
end -- 4286
function Play.prototype.childExposed(self, dangerX) -- 4322
	local c = self.partner -- 4323
	if not c.alive then -- 4323
		return false -- 4325
	end -- 4325
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4325
		self.boxes, -- 4328
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4328
	) then -- 4328
		return false -- 4329
	end -- 4329
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4329
		return false -- 4332
	end -- 4332
	local toDanger = dangerX - c.x -- 4334
	local toPlayer = self.player.x - c.x -- 4335
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4335
		return false -- 4338
	end -- 4338
	return true -- 4340
end -- 4322
function Play.prototype.raycastEnemies(self, ray) -- 4344
	local best = -1 -- 4345
	local bestI = -1 -- 4346
	do -- 4346
		local i = 0 -- 4347
		while i < #self.enemies do -- 4347
			do -- 4347
				local e = self.enemies[i + 1] -- 4348
				if not e.alive then -- 4348
					goto __continue721 -- 4350
				end -- 4350
				local y = e.y + (e.depth or 0) -- 4352
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4353
				if t >= 0 and (best < 0 or t < best) then -- 4353
					best = t -- 4355
					bestI = i -- 4356
				end -- 4356
			end -- 4356
			::__continue721:: -- 4356
			i = i + 1 -- 4347
		end -- 4347
	end -- 4347
	return {t = best, index = bestI} -- 4359
end -- 4344
function Play.prototype.raycastWorld(self, ray) -- 4362
	return self:raycastSolid(ray).t -- 4363
end -- 4362
function Play.prototype.raycastSolid(self, ray) -- 4367
	local best = -1 -- 4368
	local bestBox = nil -- 4369
	for ____, box in ipairs(self.boxes) do -- 4370
		do -- 4370
			if box.broken == true or box.hidden == true then -- 4370
				goto __continue726 -- 4372
			end -- 4372
			local t = hitBox(ray, box) -- 4377
			if t > 2 and (best < 0 or t < best) then -- 4377
				best = t -- 4380
				bestBox = box -- 4381
			end -- 4381
		end -- 4381
		::__continue726:: -- 4381
	end -- 4381
	if ray.dy < 0 then -- 4381
		local t = -ray.y / ray.dy -- 4385
		if t >= 0 and (best < 0 or t < best) then -- 4385
			best = t -- 4387
			bestBox = nil -- 4388
		end -- 4388
	end -- 4388
	return {t = best, box = bestBox} -- 4391
end -- 4367
function Play.prototype.dropFor(self, e) -- 4395
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4395
		return -- 4397
	end -- 4397
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4397
		return -- 4400
	end -- 4400
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4402
	local ____self_pickups_57 = self.pickups -- 4402
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4403
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4404
		kind = e.drop, -- 4404
		x = e.x, -- 4404
		y = e.y, -- 4404
		depth = e.depth, -- 4405
		label = label .. " ×1" -- 4405
	} -- 4405
	self:log("掉落 " .. label) -- 4407
end -- 4395
function Play.prototype.damageProp(self, b, amount) -- 4411
	if b.breakable == nil or b.broken == true then -- 4411
		return -- 4413
	end -- 4413
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4413
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4415
	if b.breakable.hp > 0 then -- 4415
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4417
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4418
		return -- 4419
	end -- 4419
	b.broken = true -- 4421
	for ____, other in ipairs(self.boxes) do -- 4422
		if other.id ~= nil and other.id == b.id then -- 4422
			other.broken = true -- 4424
		end -- 4424
	end -- 4424
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4427
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4428
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4429
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4430
end -- 4411
function Play.prototype.slideDepth(self, a, distance) -- 4434
	a.depth = self:limitDepth(a, a.depth + distance) -- 4435
end -- 4434
function Play.prototype.limitDepth(self, a, target) -- 4438
	local road = self.room.depth -- 4439
	if road == nil or target == a.depth then -- 4439
		return a.depth -- 4441
	end -- 4441
	local next = math.max( -- 4443
		road.min, -- 4443
		math.min(road.max, target) -- 4443
	) -- 4443
	local half = a.w / 2 -- 4444
	for ____, b in ipairs(self.boxes) do -- 4445
		do -- 4445
			local footprint = b.depth -- 4446
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4446
				goto __continue744 -- 4451
			end -- 4451
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4453
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4454
			if a.depth <= front and next > front then -- 4454
				next = front -- 4456
			elseif a.depth >= back and next < back then -- 4456
				next = back -- 4458
			end -- 4458
		end -- 4458
		::__continue744:: -- 4458
	end -- 4458
	return next -- 4461
end -- 4438
function Play.prototype.slideX(self, a, dx) -- 4465
	local nx = a.x + dx -- 4466
	local half = a.w / 2 -- 4467
	local room = self.room -- 4468
	nx = math.max( -- 4469
		room.minX + half, -- 4469
		math.min(room.maxX - half, nx) -- 4469
	) -- 4469
	local i = 0 -- 4470
	do -- 4470
		i = 0 -- 4471
		while i < #self.boxes do -- 4471
			do -- 4471
				local b = self.boxes[i + 1] -- 4472
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4472
					goto __continue751 -- 4474
				end -- 4474
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4474
					goto __continue751 -- 4477
				end -- 4477
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4477
					goto __continue751 -- 4480
				end -- 4480
				if nx + half > b.x0 and nx - half < b.x1 then -- 4480
					if a.x <= b.x0 then -- 4480
						nx = b.x0 - half -- 4484
					elseif a.x >= b.x1 then -- 4484
						nx = b.x1 + half -- 4486
					else -- 4486
						nx = a.x -- 4488
					end -- 4488
				end -- 4488
			end -- 4488
			::__continue751:: -- 4488
			i = i + 1 -- 4471
		end -- 4471
	end -- 4471
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4471
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4496
		local bx0 = self.cartAxle - CART_HALF -- 4497
		local bx1 = self.cartAxle + CART_HALF -- 4498
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4498
			if a.x <= bx0 then -- 4498
				nx = bx0 - half -- 4501
			elseif a.x >= bx1 then -- 4501
				nx = bx1 + half -- 4503
			else -- 4503
				nx = a.x -- 4505
			end -- 4505
		end -- 4505
	end -- 4505
	local arch = room.arch -- 4513
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4513
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4515
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4515
			if a.x <= arch.x0 then -- 4515
				nx = arch.x0 - half -- 4518
			elseif a.x >= arch.x1 then -- 4518
				nx = arch.x1 + half -- 4520
			end -- 4520
		end -- 4520
	end -- 4520
	a.x = nx -- 4524
end -- 4465
function Play.prototype.fallY(self, a, dt) -- 4528
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4529
	if a.vy < -900 then -- 4529
		a.vy = -900 -- 4531
	end -- 4531
	local ny = a.y + a.vy * dt -- 4533
	local half = a.w / 2 -- 4534
	if a.vy <= 0 then -- 4534
		local reach = a.onGround and STEP_UP or 0 -- 4537
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4538
		if ny <= ground then -- 4538
			ny = ground -- 4540
			a.vy = 0 -- 4541
			a.onGround = true -- 4542
		else -- 4542
			a.onGround = false -- 4544
		end -- 4544
	else -- 4544
		a.onGround = false -- 4547
		local i = 0 -- 4548
		do -- 4548
			i = 0 -- 4549
			while i < #self.boxes do -- 4549
				do -- 4549
					local b = self.boxes[i + 1] -- 4550
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4550
						goto __continue775 -- 4552
					end -- 4552
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4552
						goto __continue775 -- 4555
					end -- 4555
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4555
						goto __continue775 -- 4558
					end -- 4558
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4558
						ny = b.y0 - a.h -- 4561
						a.vy = 0 -- 4562
					end -- 4562
				end -- 4562
				::__continue775:: -- 4562
				i = i + 1 -- 4549
			end -- 4549
		end -- 4549
	end -- 4549
	a.y = ny -- 4566
end -- 4528
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4570
	if depth == nil then -- 4570
		depth = 0 -- 4570
	end -- 4570
	local g = -9999 -- 4571
	local i = 0 -- 4572
	do -- 4572
		i = 0 -- 4573
		while i < #self.floors do -- 4573
			local f = self.floors[i + 1] -- 4574
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4574
				g = f.y1 -- 4576
			end -- 4576
			i = i + 1 -- 4573
		end -- 4573
	end -- 4573
	do -- 4573
		i = 0 -- 4579
		while i < #self.boxes do -- 4579
			do -- 4579
				local b = self.boxes[i + 1] -- 4580
				if b.broken == true or b.hidden == true or b.soft == true then -- 4580
					goto __continue785 -- 4582
				end -- 4582
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4582
					g = b.y1 -- 4586
				end -- 4586
			end -- 4586
			::__continue785:: -- 4586
			i = i + 1 -- 4579
		end -- 4579
	end -- 4579
	return g -- 4589
end -- 4570
function Play.prototype.updateCamera(self, dt) -- 4592
	local p = self.player -- 4593
	local tx = p.x + p.facing * 30 -- 4594
	local ty = p.y + CAM_LOOK_UP -- 4595
	local k = math.min(1, CAM_FOLLOW * dt) -- 4596
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4597
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4598
end -- 4592
function Play.prototype.clampCamera(self, w, h) -- 4602
	local room = self.room -- 4603
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4604
	local spanX = room.maxX - room.minX -- 4605
	if spanX <= halfW * 2 then -- 4605
		self.cam.x = (room.minX + room.maxX) / 2 -- 4607
	else -- 4607
		self.cam.x = math.max( -- 4609
			room.minX + halfW, -- 4609
			math.min(room.maxX - halfW, self.cam.x) -- 4609
		) -- 4609
	end -- 4609
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4612
	local spanY = room.height -- 4613
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4614
	if spanY <= halfH * 2 then -- 4614
		self.cam.y = camY -- 4616
	else -- 4616
		self.cam.y = math.max( -- 4618
			camY, -- 4618
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4618
		) -- 4618
	end -- 4618
end -- 4602
function Play.prototype.flashSet(self, text, t) -- 4622
	self.flash = text -- 4623
	self.flashT = t -- 4624
end -- 4622
function Play.prototype.statusText(self) -- 4628
	local p = self.player -- 4629
	local parts = {} -- 4630
	local who = self.childMode and "小满" or "周戍" -- 4631
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4632
	if self.room.key == "prologue" then -- 4632
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4635
		if self.phase == "prologue-wake" then -- 4635
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 4637
		elseif self.phase == "prologue-shadow" then -- 4637
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 4639
		elseif self.phase == "prologue-escape" then -- 4639
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 4641
		elseif self.phase == "prologue-hide" then -- 4641
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 4643
		elseif self.phase == "prologue-wait" then -- 4643
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4645
		elseif self.phase == "prologue-give" then -- 4645
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4647
		else -- 4647
			parts[#parts + 1] = "跟随" -- 4649
		end -- 4649
		if self.paused then -- 4649
			parts[#parts + 1] = "已暂停" -- 4652
		end -- 4652
		return table.concat(parts, " · ") -- 4654
	end -- 4654
	if self.room.key == "street" then -- 4654
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4657
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4658
		if self.paused then -- 4658
			parts[#parts + 1] = "已暂停" -- 4660
		end -- 4660
		return table.concat(parts, " · ") -- 4662
	end -- 4662
	if self.room.key == "gate" then -- 4662
		local ____temp_60 -- 4665
		if self.room.story == nil then -- 4665
			____temp_60 = nil -- 4665
		else -- 4665
			____temp_60 = self.room.story.gate -- 4665
		end -- 4665
		local g = ____temp_60 -- 4665
		if g ~= nil then -- 4665
			parts[#parts + 1] = self:gateLabel() -- 4667
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4668
				0, -- 4669
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4669
			))) .. " 秒" -- 4669
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4670
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4671
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4672
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4673
			if self.gateFailCount > 0 then -- 4673
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4675
			end -- 4675
			if self.flash ~= "" then -- 4675
				parts[#parts + 1] = self.flash -- 4678
			end -- 4678
		end -- 4678
		if self.paused then -- 4678
			parts[#parts + 1] = "已暂停" -- 4682
		end -- 4682
		return table.concat(parts, " · ") -- 4684
	end -- 4684
	if self.room.key == "forest" then -- 4684
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4687
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4688
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4689
		if self.caughtT > 0 then -- 4689
			parts[#parts + 1] = "复位中" -- 4691
		end -- 4691
		if self.paused then -- 4691
			parts[#parts + 1] = "已暂停" -- 4694
		end -- 4694
		return table.concat(parts, " · ") -- 4696
	end -- 4696
	if self.room.key == "tower" then -- 4696
		if self.phase == "tower-wait" then -- 4696
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4700
		elseif self.phase == "tower-knock" then -- 4700
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4702
		elseif self.phase == "tower-given" then -- 4702
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4704
		else -- 4704
			parts[#parts + 1] = "片尾" -- 4706
		end -- 4706
		if self.paused then -- 4706
			parts[#parts + 1] = "已暂停" -- 4709
		end -- 4709
		return table.concat(parts, " · ") -- 4711
	end -- 4711
	if self.room.key == "village" then -- 4711
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4714
		if self.hasBottle then -- 4714
			parts[#parts + 1] = "有瓶" -- 4716
		elseif self.bottleFly ~= nil then -- 4716
			parts[#parts + 1] = "瓶在飞" -- 4718
		else -- 4718
			parts[#parts + 1] = "空手" -- 4720
		end -- 4720
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4722
		if self.scavChase then -- 4722
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4724
		end -- 4724
		if self.passed then -- 4724
			parts[#parts + 1] = "已过通行线" -- 4727
		end -- 4727
		if self.paused then -- 4727
			parts[#parts + 1] = "已暂停" -- 4730
		end -- 4730
		return table.concat(parts, " · ") -- 4732
	end -- 4732
	local isChild = self.childMode -- 4735
	if isChild then -- 4735
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4737
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4738
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4739
	else -- 4739
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4741
		if p.rollT > 0 then -- 4741
			parts[#parts + 1] = "翻滚中" -- 4743
		end -- 4743
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4745
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4746
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4747
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4748
	end -- 4748
	if self.checkpoint >= 0 then -- 4748
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4751
	end -- 4751
	if self.paused then -- 4751
		parts[#parts + 1] = "已暂停" -- 4754
	end -- 4754
	return table.concat(parts, " · ") -- 4756
end -- 4628
function Play.prototype.aliveEnemies(self) -- 4760
	local n = 0 -- 4761
	local i = 0 -- 4762
	do -- 4762
		i = 0 -- 4763
		while i < #self.enemies do -- 4763
			if self.enemies[i + 1].alive then -- 4763
				n = n + 1 -- 4765
			end -- 4765
			i = i + 1 -- 4763
		end -- 4763
	end -- 4763
	return n -- 4768
end -- 4760
function Play.prototype.threatened(self) -- 4773
	do -- 4773
		local i = 0 -- 4774
		while i < #self.enemies do -- 4774
			local e = self.enemies[i + 1] -- 4775
			if e.alive and e.warnT > 0 then -- 4775
				return true -- 4777
			end -- 4777
			i = i + 1 -- 4774
		end -- 4774
	end -- 4774
	return false -- 4780
end -- 4773
function Play.prototype.gateSecondsLeft(self) -- 4783
	local ____temp_61 -- 4784
	if self.room.story == nil then -- 4784
		____temp_61 = nil -- 4784
	else -- 4784
		____temp_61 = self.room.story.gate -- 4784
	end -- 4784
	local g = ____temp_61 -- 4784
	if g == nil then -- 4784
		return 0 -- 4786
	end -- 4786
	return math.max( -- 4788
		0, -- 4788
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4788
	) -- 4788
end -- 4783
function Play.prototype.gateLabel(self) -- 4791
	if self.phase == "gate-idle" then -- 4791
		return "待就位" -- 4793
	end -- 4793
	if self.phase == "gate-hold" then -- 4793
		return "守点中" -- 4796
	end -- 4796
	if self.phase == "gate-send" then -- 4796
		return "送别" -- 4799
	end -- 4799
	if self.phase == "gate-count" then -- 4799
		return "数数 " .. tostring(self.countTick) -- 4802
	end -- 4802
	return "她走" -- 4804
end -- 4791
function Play.prototype.dogLabel(self) -- 4808
	if self.dogState == "ear" then -- 4808
		return "转耳" -- 4810
	end -- 4810
	if self.dogState == "chase" then -- 4810
		return "追" -- 4813
	end -- 4813
	if self.dogState == "sniff" then -- 4813
		return "停" -- 4816
	end -- 4816
	if self.dogState == "back" then -- 4816
		return "回线" -- 4819
	end -- 4819
	return "巡逻" -- 4821
end -- 4808
function Play.prototype.doorXOf(self) -- 4824
	local ____temp_62 -- 4825
	if self.room.story == nil then -- 4825
		____temp_62 = nil -- 4825
	else -- 4825
		____temp_62 = self.room.story.tower -- 4825
	end -- 4825
	local t = ____temp_62 -- 4825
	return t == nil and 0 or t.doorX -- 4826
end -- 4824
function Play.prototype.scavLabel(self) -- 4830
	if self.scavState == "chase" then -- 4830
		return "追" -- 4832
	end -- 4832
	if self.scavState == "turn" then -- 4832
		return "转头" -- 4835
	end -- 4835
	if self.scavState == "walk" then -- 4835
		return "赶来" -- 4838
	end -- 4838
	if self.scavState == "stall" then -- 4838
		return "停住" -- 4841
	end -- 4841
	if self.scavState == "back" then -- 4841
		return "回位" -- 4844
	end -- 4844
	return "巡逻" -- 4846
end -- 4830
function Play.prototype.hintText(self) -- 4850
	if self.paused then -- 4850
		return "Esc 继续 · R 重置" -- 4852
	end -- 4852
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4852
		if self:threatened() then -- 4852
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4858
		end -- 4858
		if self.coverHug then -- 4858
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4861
		end -- 4861
		if self.coverNear then -- 4861
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4864
		end -- 4864
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4866
	end -- 4866
	if self.flash ~= "" then -- 4866
		return self.flash -- 4869
	end -- 4869
	if self.room.key == "prologue" then -- 4869
		if self.phase == "prologue-wake" then -- 4869
			return "父亲在门外唤 · 小满睁眼" -- 4873
		end -- 4873
		if self.phase == "prologue-shadow" then -- 4873
			return "墙上两道人影 · 碗滚到脚边" -- 4876
		end -- 4876
		if self.phase == "prologue-escape" then -- 4876
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 4879
		end -- 4879
		if self.phase == "prologue-hide" then -- 4879
			return "柜门合上 · 屏住呼吸" -- 4882
		end -- 4882
		if self.phase == "prologue-wait" then -- 4882
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4885
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4886
		end -- 4886
		if self.phase == "prologue-give" then -- 4886
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4889
		end -- 4889
		return "她跟着你了 · 两人一起走到门口 680" -- 4891
	end -- 4891
	if self.room.key == "street" then -- 4891
		if self:aliveEnemies() > 0 then -- 4891
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4895
		end -- 4895
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4897
	end -- 4897
	if self.room.key == "gate" then -- 4897
		local ____temp_63 -- 4900
		if self.room.story == nil then -- 4900
			____temp_63 = nil -- 4900
		else -- 4900
			____temp_63 = self.room.story.gate -- 4900
		end -- 4900
		local g = ____temp_63 -- 4900
		if g ~= nil then -- 4900
			if self.phase == "gate-idle" then -- 4900
				if self.gateNeedConfirm then -- 4900
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 4904
				end -- 4904
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 4906
			end -- 4906
			if self.phase == "gate-hold" then -- 4906
				if self.coveredFlash > 0 then -- 4906
					return "掩体挡下了这一枪 · 别露头" -- 4910
				end -- 4910
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 4912
			end -- 4912
			if self.phase == "gate-send" then -- 4912
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 4915
			end -- 4915
			if self.phase == "gate-count" then -- 4915
				if self.countTick >= ____exports.GATE_COUNT_END then -- 4915
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 4919
				end -- 4919
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 4921
			end -- 4921
			return "她自己走 · 跟着出城门 1120" -- 4923
		end -- 4923
	end -- 4923
	if self.room.key == "forest" then -- 4923
		if self.dogState == "chase" then -- 4923
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 4928
		end -- 4928
		if self.dogState == "ear" then -- 4928
			return "狗转耳朵了 · 停下或蹲下别出声" -- 4931
		end -- 4931
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 4933
	end -- 4933
	if self.room.key == "tower" then -- 4933
		if self.phase == "tower-wait" then -- 4933
			return "走到门前 445 点一次 E 敲两下" -- 4937
		end -- 4937
		if self.phase == "tower-knock" then -- 4937
			return "敲两下 · 等门开" -- 4940
		end -- 4940
		if self.phase == "tower-given" then -- 4940
			return "递交针套和纸条 · 看登记簿最后一行" -- 4943
		end -- 4943
		return "片尾 · 点 E 再玩一次，回到序章" -- 4945
	end -- 4945
	if self.room.key == "village" then -- 4945
		if self.bottleFly ~= nil then -- 4945
			return "等瓶子落地 · 触地才发声" -- 4949
		end -- 4949
		if self.hasBottle then -- 4949
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 4952
		end -- 4952
		if self.passed then -- 4952
			return "已过第一院 · R 重置可再来一遍" -- 4955
		end -- 4955
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 4957
	end -- 4957
	if self.room.key == "outside" then -- 4957
		if self.focusCart then -- 4957
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 4961
		end -- 4961
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 4963
	end -- 4963
	if self.escort.state == "frozen" then -- 4963
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 4963
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 4967
		end -- 4967
		return "小满吓住了 · 走过去，靠近再点 E" -- 4969
	end -- 4969
	if self.escort.state == "calming" then -- 4969
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 4972
	end -- 4972
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 4974
end -- 4850
function Play.prototype.draw(self, draw, w, h) -- 4979
	self.viewW = w -- 4980
	self.viewH = h -- 4981
	self.view = ____exports.computeViewport(w, h) -- 4982
	self:clampCamera(w, h) -- 4983
	draw:clear() -- 4984
	draw:drawRect( -- 4986
		Rect(0, 0, w, h), -- 4986
		BG_VOID -- 4986
	) -- 4986
	local box = self:canvasRect(w, h) -- 4987
	draw:drawRect(box, BG_FAR) -- 4988
	draw:drawRect( -- 4989
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 4989
		BG_MID -- 4989
	) -- 4989
	self:drawFloors(draw, w, h) -- 4991
	self:drawSolids(draw, w, h) -- 4992
	self:drawZones(draw, w, h) -- 4993
	self:drawArch(draw, w, h) -- 4994
	self:drawCart(draw, w, h) -- 4995
	self:drawCampaignProps(draw, w, h) -- 4996
	self:drawActors(draw, w, h) -- 4997
	self:drawTrace(draw, w, h) -- 4998
	self:drawAim(draw, w, h) -- 4999
end -- 4979
function Play.prototype.canvasRect(self, w, h) -- 5003
	local v = self.view -- 5004
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5005
end -- 5003
function Play.prototype.px(self, n) -- 5009
	return n * self.view.zoom -- 5010
end -- 5009
function Play.prototype.sx(self, wx, w) -- 5014
	local v = self.view -- 5015
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5016
	return v.ox + lx * v.zoom -- 5017
end -- 5014
function Play.prototype.sy(self, wy, h) -- 5021
	local v = self.view -- 5022
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5023
	return v.oy + ly * v.zoom -- 5024
end -- 5021
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5027
	local px0 = self:sx(x0, w) -- 5028
	local px1 = self:sx(x1, w) -- 5029
	local py0 = self:sy(y0, h) -- 5030
	local py1 = self:sy(y1, h) -- 5031
	if px1 <= px0 or py1 <= py0 then -- 5031
		return -- 5033
	end -- 5033
	draw:drawRect( -- 5035
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5035
		color -- 5035
	) -- 5035
end -- 5027
function Play.prototype.drawFloors(self, draw, w, h) -- 5038
	local i = 0 -- 5039
	do -- 5039
		i = 0 -- 5040
		while i < #self.room.floors do -- 5040
			local f = self.room.floors[i + 1] -- 5041
			local ____temp_64 -- 5042
			if f.y == 0 then -- 5042
				____temp_64 = self.room.depth -- 5042
			else -- 5042
				____temp_64 = nil -- 5042
			end -- 5042
			local road = ____temp_64 -- 5042
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5043
			local x0 = self:sx(f.x0, w) -- 5044
			local x1 = self:sx(f.x1, w) -- 5045
			local deck = self:px(5) -- 5046
			if road ~= nil then -- 5046
				local back = self:sy(f.y + road.max, h) -- 5048
				draw:drawRect( -- 5049
					Rect(x0, y, x1 - x0, back - y), -- 5049
					FLOOR_DECK, -- 5049
					self:px(1), -- 5049
					SOLID_EDGE -- 5049
				) -- 5049
			end -- 5049
			draw:drawRect( -- 5051
				Rect(x0, y - deck, x1 - x0, deck), -- 5051
				FLOOR_DECK -- 5051
			) -- 5051
			draw:drawSegment( -- 5052
				Vec2(x0, y), -- 5052
				Vec2(x1, y), -- 5052
				self:px(1), -- 5052
				GROUND -- 5052
			) -- 5052
			i = i + 1 -- 5040
		end -- 5040
	end -- 5040
end -- 5038
function Play.prototype.drawSolids(self, draw, w, h) -- 5056
	local i = 0 -- 5057
	do -- 5057
		i = 0 -- 5058
		while i < #self.boxes do -- 5058
			do -- 5058
				local b = self.boxes[i + 1] -- 5059
				if b.id == "braced_shield" or b.hidden == true then -- 5059
					goto __continue914 -- 5061
				end -- 5061
				if b.broken == true then -- 5061
					if b.breakable ~= nil then -- 5061
						local gy = self:sy(b.y0, h) -- 5066
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5067
						local k = 0 -- 5068
						do -- 5068
							k = 0 -- 5069
							while k < 3 do -- 5069
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5070
								draw:drawSegment( -- 5071
									Vec2( -- 5071
										gx - self:px(4), -- 5071
										gy + self:px(k % 2) -- 5071
									), -- 5071
									Vec2( -- 5071
										gx + self:px(5), -- 5071
										gy + self:px(k % 2) -- 5071
									), -- 5071
									self:px(1), -- 5071
									rgb -- 5071
								) -- 5071
								k = k + 1 -- 5069
							end -- 5069
						end -- 5069
					end -- 5069
					goto __continue914 -- 5074
				end -- 5074
				local ____opt_67 = b.depth -- 5074
				local front = ____opt_67 and ____opt_67.min or 0 -- 5076
				local ____opt_69 = b.depth -- 5076
				local back = ____opt_69 and ____opt_69.max or 0 -- 5077
				local fill = SOLID_FILL -- 5078
				local line = SOLID_EDGE -- 5079
				if b.soft == true then -- 5079
					fill = SOFT -- 5081
					line = SOFT_LINE -- 5082
				elseif b.breakable ~= nil then -- 5082
					line = DANGER_LINE -- 5084
					fill = Color(0.3, 0.24, 0.16, 1) -- 5085
				elseif b.interact ~= nil then -- 5085
					line = PASS_LINE -- 5087
				end -- 5087
				self:drawBox( -- 5089
					draw, -- 5089
					w, -- 5089
					h, -- 5089
					b.x0, -- 5089
					b.x1, -- 5089
					b.y0 + front, -- 5089
					b.y1 + back, -- 5089
					fill -- 5089
				) -- 5089
				draw:drawSegment( -- 5090
					Vec2( -- 5090
						self:sx(b.x0, w), -- 5090
						self:sy(b.y1 + front, h) -- 5090
					), -- 5090
					Vec2( -- 5091
						self:sx(b.x1, w), -- 5091
						self:sy(b.y1 + front, h) -- 5091
					), -- 5091
					self:px(1), -- 5091
					line -- 5091
				) -- 5091
				if b.breakable ~= nil then -- 5091
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5094
					local cyp = self:sy(b.y1 + front, h) -- 5095
					draw:drawSegment( -- 5096
						Vec2( -- 5096
							cxp - self:px(4), -- 5096
							cyp + self:px(1) -- 5096
						), -- 5096
						Vec2( -- 5096
							cxp + self:px(3), -- 5096
							cyp + self:px(5) -- 5096
						), -- 5096
						self:px(1), -- 5096
						line -- 5096
					) -- 5096
				end -- 5096
			end -- 5096
			::__continue914:: -- 5096
			i = i + 1 -- 5058
		end -- 5058
	end -- 5058
end -- 5056
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5102
	local i = 0 -- 5103
	do -- 5103
		i = 0 -- 5104
		while i < #self.pickups do -- 5104
			do -- 5104
				local pk = self.pickups[i + 1] -- 5105
				if self.run.taken[pk.id] == true then -- 5105
					goto __continue926 -- 5107
				end -- 5107
				local gy = pk.y + (pk.depth or 0) -- 5109
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5110
				draw:drawRect( -- 5111
					Rect( -- 5111
						self:sx(pk.x - 5, w), -- 5111
						self:sy(gy + 12 + bob, h), -- 5111
						self:px(10), -- 5111
						self:px(10) -- 5111
					), -- 5111
					Color(0.84, 0.7, 0.3, 1) -- 5112
				) -- 5112
				draw:drawSegment( -- 5113
					Vec2( -- 5113
						self:sx(pk.x - 5, w), -- 5113
						self:sy(gy + 12 + bob, h) -- 5113
					), -- 5113
					Vec2( -- 5114
						self:sx(pk.x + 5, w), -- 5114
						self:sy(gy + 12 + bob, h) -- 5114
					), -- 5114
					self:px(1), -- 5114
					Color(0.95, 0.86, 0.52, 1) -- 5114
				) -- 5114
			end -- 5114
			::__continue926:: -- 5114
			i = i + 1 -- 5104
		end -- 5104
	end -- 5104
	if self.bracedShield ~= nil then -- 5104
		local sh = self.bracedShield -- 5117
		draw:drawRect( -- 5118
			Rect( -- 5118
				self:sx(sh.x - sh.w / 2, w), -- 5118
				self:sy(sh.y, h), -- 5118
				self:px(sh.w), -- 5118
				self:px(sh.h) -- 5118
			), -- 5118
			Color(0.42, 0.4, 0.34, 1) -- 5119
		) -- 5119
		draw:drawSegment( -- 5120
			Vec2( -- 5120
				self:sx(sh.x - sh.w / 2, w), -- 5120
				self:sy(sh.y + sh.h, h) -- 5120
			), -- 5120
			Vec2( -- 5121
				self:sx(sh.x + sh.w / 2, w), -- 5121
				self:sy(sh.y + sh.h, h) -- 5121
			), -- 5121
			self:px(1), -- 5121
			Color(0.74, 0.72, 0.62, 1) -- 5121
		) -- 5121
	end -- 5121
end -- 5102
function Play.prototype.drawZones(self, draw, w, h) -- 5125
	local i = 0 -- 5126
	do -- 5126
		i = 0 -- 5127
		while i < #self.room.zones do -- 5127
			local z = self.room.zones[i + 1] -- 5128
			local fill = DANGER -- 5129
			local line = DANGER_LINE -- 5130
			if z.tint == 2 then -- 5130
				fill = SOFT -- 5132
				line = SOFT_LINE -- 5133
			elseif z.tint == 3 then -- 5133
				fill = BRICK -- 5135
				line = BRICK_LINE -- 5136
			elseif z.tint == 4 then -- 5136
				fill = PASS -- 5138
				line = PASS_LINE -- 5139
			end -- 5139
			self:drawBox( -- 5141
				draw, -- 5141
				w, -- 5141
				h, -- 5141
				z.x0, -- 5141
				z.x1, -- 5141
				z.y, -- 5141
				z.y + z.h, -- 5141
				fill -- 5141
			) -- 5141
			draw:drawSegment( -- 5142
				Vec2( -- 5142
					self:sx(z.x0, w), -- 5142
					self:sy(z.y, h) -- 5142
				), -- 5142
				Vec2( -- 5142
					self:sx(z.x0, w), -- 5142
					self:sy(z.y + z.h, h) -- 5142
				), -- 5142
				self:px(1), -- 5142
				line -- 5142
			) -- 5142
			draw:drawSegment( -- 5143
				Vec2( -- 5143
					self:sx(z.x1, w), -- 5143
					self:sy(z.y, h) -- 5143
				), -- 5143
				Vec2( -- 5143
					self:sx(z.x1, w), -- 5143
					self:sy(z.y + z.h, h) -- 5143
				), -- 5143
				self:px(1), -- 5143
				line -- 5143
			) -- 5143
			i = i + 1 -- 5127
		end -- 5127
	end -- 5127
end -- 5125
function Play.prototype.drawArch(self, draw, w, h) -- 5147
	local a = self.room.arch -- 5148
	if a.h <= 0 then -- 5148
		return -- 5150
	end -- 5150
	self:drawBox( -- 5152
		draw, -- 5152
		w, -- 5152
		h, -- 5152
		a.x0, -- 5152
		a.x1, -- 5152
		a.y, -- 5152
		a.y + a.h, -- 5152
		HOLE_FILL -- 5152
	) -- 5152
	draw:drawSegment( -- 5153
		Vec2( -- 5153
			self:sx(a.x0, w), -- 5153
			self:sy(a.y + a.h, h) -- 5153
		), -- 5153
		Vec2( -- 5153
			self:sx(a.x1, w), -- 5153
			self:sy(a.y + a.h, h) -- 5153
		), -- 5153
		self:px(1), -- 5153
		SOLID_EDGE -- 5153
	) -- 5153
	draw:drawSegment( -- 5154
		Vec2( -- 5154
			self:sx(a.x0, w), -- 5154
			self:sy(a.y, h) -- 5154
		), -- 5154
		Vec2( -- 5154
			self:sx(a.x0, w), -- 5154
			self:sy(a.y + a.h, h) -- 5154
		), -- 5154
		self:px(1), -- 5154
		SOLID_EDGE -- 5154
	) -- 5154
	draw:drawSegment( -- 5155
		Vec2( -- 5155
			self:sx(a.x1, w), -- 5155
			self:sy(a.y, h) -- 5155
		), -- 5155
		Vec2( -- 5155
			self:sx(a.x1, w), -- 5155
			self:sy(a.y + a.h, h) -- 5155
		), -- 5155
		self:px(1), -- 5155
		SOLID_EDGE -- 5155
	) -- 5155
end -- 5147
function Play.prototype.drawCart(self, draw, w, h) -- 5158
	local c = self.room.cart -- 5159
	if c.bodyW <= 0 then -- 5159
		return -- 5161
	end -- 5161
	drawCartShape( -- 5163
		draw, -- 5163
		self, -- 5163
		w, -- 5163
		h, -- 5163
		c, -- 5163
		self.cartAxle -- 5163
	) -- 5163
	draw:drawRect( -- 5164
		Rect( -- 5164
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5164
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5164
			self:px(2), -- 5164
			self:px(40) -- 5164
		), -- 5164
		STAND -- 5164
	) -- 5164
end -- 5158
function Play.prototype.drawActors(self, draw, w, h) -- 5167
	local p = self.player -- 5168
	local isChild = self.childMode -- 5169
	local footY = p.y + p.depth -- 5170
	if p.covered then -- 5170
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5173
		draw:drawSegment( -- 5174
			Vec2( -- 5174
				self:sx(edge, w), -- 5174
				self:sy(footY + 8, h) -- 5174
			), -- 5174
			Vec2( -- 5174
				self:sx(edge, w), -- 5174
				self:sy(footY + p.h * 0.62, h) -- 5174
			), -- 5174
			self:px(2), -- 5174
			STAND -- 5174
		) -- 5174
		draw:drawSegment( -- 5176
			Vec2( -- 5176
				self:sx(p.x - 8, w), -- 5176
				self:sy(footY + p.h + 3, h) -- 5176
			), -- 5176
			Vec2( -- 5176
				self:sx(p.x + 8, w), -- 5176
				self:sy(footY + p.h + 3, h) -- 5176
			), -- 5176
			self:px(2), -- 5176
			STAND -- 5176
		) -- 5176
	elseif self.coverNear and not isChild then -- 5176
		draw:drawRect( -- 5179
			Rect( -- 5179
				self:sx(p.x - 3, w), -- 5179
				self:sy(footY + 1, h), -- 5179
				self:px(3), -- 5179
				self:px(3) -- 5179
			), -- 5179
			STAND -- 5179
		) -- 5179
	end -- 5179
	drawFigure( -- 5181
		draw, -- 5181
		self, -- 5181
		w, -- 5181
		h, -- 5181
		p, -- 5181
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5181
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5181
	) -- 5181
	local q = self.partner -- 5182
	if q.alive then -- 5182
		local childPartner = q.w == CHILD_W -- 5184
		drawFigure( -- 5185
			draw, -- 5185
			self, -- 5185
			w, -- 5185
			h, -- 5185
			q, -- 5185
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5185
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5185
		) -- 5185
	end -- 5185
	local i = 0 -- 5187
	do -- 5187
		i = 0 -- 5188
		while i < #self.enemies do -- 5188
			local e = self.enemies[i + 1] -- 5189
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5190
			local enemyY = e.y + (e.depth or 0) -- 5191
			self:drawBox( -- 5192
				draw, -- 5192
				w, -- 5192
				h, -- 5192
				e.x - e.w / 2, -- 5192
				e.x + e.w / 2, -- 5192
				enemyY, -- 5192
				enemyY + e.h, -- 5192
				col -- 5192
			) -- 5192
			if e.alive then -- 5192
				local ef = p.x >= e.x and 1 or -1 -- 5194
				if e.kind == "shield" then -- 5194
					local sh = (e.shieldHp or 0) > 0 -- 5196
					draw:drawRect( -- 5197
						Rect( -- 5197
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5197
							self:sy(enemyY, h), -- 5197
							self:px(6), -- 5197
							self:px(64) -- 5197
						), -- 5197
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5198
					) -- 5198
				elseif e.kind == "breaker" then -- 5198
					draw:drawSegment( -- 5200
						Vec2( -- 5200
							self:sx(e.x + ef * 12, w), -- 5200
							self:sy(enemyY + 8, h) -- 5200
						), -- 5200
						Vec2( -- 5201
							self:sx(e.x + ef * 22, w), -- 5201
							self:sy(enemyY + 46, h) -- 5201
						), -- 5201
						self:px(3), -- 5201
						Color(0.5, 0.36, 0.22, 1) -- 5201
					) -- 5201
				end -- 5201
			end -- 5201
			if e.alive and e.warnT > 0 then -- 5201
				local gunX = self:sx(e.x, w) -- 5206
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5207
				local aimX = self:sx(p.x, w) -- 5208
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5209
				local seg = 8 -- 5210
				local s = 0 -- 5211
				do -- 5211
					s = 0 -- 5212
					while s < seg do -- 5212
						local t0 = s / seg -- 5213
						local t1 = (s + 1) / seg -- 5214
						draw:drawSegment( -- 5215
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5216
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5217
							self:px(1), -- 5218
							DANGER -- 5218
						) -- 5218
						s = s + 2 -- 5212
					end -- 5212
				end -- 5212
			end -- 5212
			i = i + 1 -- 5188
		end -- 5188
	end -- 5188
	local k = 0 -- 5223
	do -- 5223
		k = 0 -- 5224
		while k < #self.room.marks do -- 5224
			do -- 5224
				local m = self.room.marks[k + 1] -- 5225
				if m.kind ~= 0 then -- 5225
					goto __continue952 -- 5227
				end -- 5227
				local on = self.checkpoint == m.x -- 5229
				local x = self:sx(m.x, w) -- 5230
				local y = self:sy(m.y, h) -- 5231
				draw:drawSegment( -- 5232
					Vec2(x, y), -- 5232
					Vec2( -- 5232
						x, -- 5232
						y + self:px(35) -- 5232
					), -- 5232
					self:px(1), -- 5232
					on and CHECK or INK_DIM -- 5232
				) -- 5232
				draw:drawDot( -- 5233
					Vec2( -- 5233
						x, -- 5233
						y + self:px(35) -- 5233
					), -- 5233
					self:px(2), -- 5233
					on and CHECK or INK_DIM -- 5233
				) -- 5233
			end -- 5233
			::__continue952:: -- 5233
			k = k + 1 -- 5224
		end -- 5224
	end -- 5224
	local j = 0 -- 5237
	do -- 5237
		j = 0 -- 5238
		while j < #self.room.marks do -- 5238
			do -- 5238
				local m = self.room.marks[j + 1] -- 5239
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5239
					goto __continue955 -- 5241
				end -- 5241
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5241
					goto __continue955 -- 5245
				end -- 5245
				local col = STAND -- 5247
				if m.kind == 4 then -- 5247
					col = PASS_LINE -- 5249
				elseif m.kind == 5 then -- 5249
					col = BRICK_LINE -- 5251
				end -- 5251
				local mx = self:sx(m.x, w) -- 5253
				local my = self:sy(m.y, h) -- 5254
				draw:drawSegment( -- 5255
					Vec2(mx, my), -- 5255
					Vec2( -- 5255
						mx, -- 5255
						my + self:px(24) -- 5255
					), -- 5255
					self:px(1), -- 5255
					col -- 5255
				) -- 5255
			end -- 5255
			::__continue955:: -- 5255
			j = j + 1 -- 5238
		end -- 5238
	end -- 5238
	local t = 0 -- 5258
	do -- 5258
		t = 0 -- 5259
		while t < #self.room.marks do -- 5259
			do -- 5259
				local m = self.room.marks[t + 1] -- 5260
				if m.kind ~= 6 then -- 5260
					goto __continue961 -- 5262
				end -- 5262
				local mx = self:sx(m.x, w) -- 5264
				local my = self:sy(m.y, h) -- 5265
				draw:drawSegment( -- 5266
					Vec2(mx, my), -- 5266
					Vec2( -- 5266
						mx, -- 5266
						my + self:px(30) -- 5266
					), -- 5266
					self:px(1), -- 5266
					INK_DIM -- 5266
				) -- 5266
				self:drawBox( -- 5267
					draw, -- 5267
					w, -- 5267
					h, -- 5267
					m.x - 5, -- 5267
					m.x + 5, -- 5267
					m.y + 30, -- 5267
					m.y + 40, -- 5267
					CHECK -- 5267
				) -- 5267
			end -- 5267
			::__continue961:: -- 5267
			t = t + 1 -- 5259
		end -- 5259
	end -- 5259
	if self.room.key == "village" then -- 5259
		self:drawVillage(draw, w, h) -- 5270
	end -- 5270
	if self.room.key == "forest" then -- 5270
		self:drawDog(draw, w, h) -- 5273
	end -- 5273
end -- 5167
function Play.prototype.drawDog(self, draw, w, h) -- 5278
	local x = self.dogX -- 5279
	self:drawBox( -- 5280
		draw, -- 5280
		w, -- 5280
		h, -- 5280
		x - 14, -- 5280
		x + 14, -- 5280
		0, -- 5280
		20, -- 5280
		SCAV_BODY -- 5280
	) -- 5280
	self:drawBox( -- 5281
		draw, -- 5281
		w, -- 5281
		h, -- 5281
		x - 10, -- 5281
		x - 2, -- 5281
		20, -- 5281
		30, -- 5281
		SCAV_BODY -- 5281
	) -- 5281
	self:drawBox( -- 5282
		draw, -- 5282
		w, -- 5282
		h, -- 5282
		x + 2, -- 5282
		x + 10, -- 5282
		20, -- 5282
		30, -- 5282
		SCAV_HEAD -- 5282
	) -- 5282
	if self.dogState == "ear" or self.dogState == "chase" then -- 5282
		draw:drawSegment( -- 5284
			Vec2( -- 5284
				self:sx(x, w), -- 5284
				self:sy(30, h) -- 5284
			), -- 5284
			Vec2( -- 5285
				self:sx(x, w), -- 5285
				self:sy(40, h) -- 5285
			), -- 5285
			self:px(1), -- 5285
			DANGER -- 5285
		) -- 5285
	end -- 5285
end -- 5278
function Play.prototype.drawVillage(self, draw, w, h) -- 5290
	local bottle = self.room.bottle -- 5291
	if bottle ~= nil then -- 5291
		self:drawBox( -- 5293
			draw, -- 5293
			w, -- 5293
			h, -- 5293
			bottle.x - 14, -- 5293
			bottle.x + 14, -- 5293
			0, -- 5293
			64, -- 5293
			SOLID_FILL -- 5293
		) -- 5293
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5293
			self:drawBottle( -- 5295
				draw, -- 5295
				w, -- 5295
				h, -- 5295
				bottle.x, -- 5295
				64 -- 5295
			) -- 5295
		end -- 5295
	end -- 5295
	self:drawBox( -- 5299
		draw, -- 5299
		w, -- 5299
		h, -- 5299
		300, -- 5299
		420, -- 5299
		44, -- 5299
		50, -- 5299
		FLOOR_DECK -- 5299
	) -- 5299
	self:drawBox( -- 5300
		draw, -- 5300
		w, -- 5300
		h, -- 5300
		300, -- 5300
		306, -- 5300
		0, -- 5300
		44, -- 5300
		FLOOR_DECK -- 5300
	) -- 5300
	self:drawBox( -- 5301
		draw, -- 5301
		w, -- 5301
		h, -- 5301
		414, -- 5301
		420, -- 5301
		0, -- 5301
		44, -- 5301
		FLOOR_DECK -- 5301
	) -- 5301
	local s = self.room.scavenger -- 5303
	if s ~= nil then -- 5303
		local sx0 = self.scavX -- 5305
		self:drawBox( -- 5306
			draw, -- 5306
			w, -- 5306
			h, -- 5306
			sx0 - 12, -- 5306
			sx0 + 12, -- 5306
			0, -- 5306
			s.h - 14, -- 5306
			SCAV_BODY -- 5306
		) -- 5306
		self:drawBox( -- 5307
			draw, -- 5307
			w, -- 5307
			h, -- 5307
			sx0 - 7, -- 5307
			sx0 + 7, -- 5307
			s.h - 14, -- 5307
			s.h, -- 5307
			SCAV_HEAD -- 5307
		) -- 5307
		if self.scavState == "turn" then -- 5307
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5309
			draw:drawSegment( -- 5310
				Vec2( -- 5310
					self:sx(sx0, w), -- 5310
					self:sy(s.h - 6, h) -- 5310
				), -- 5310
				Vec2( -- 5310
					self:sx(fx, w), -- 5310
					self:sy(s.h - 6, h) -- 5310
				), -- 5310
				self:px(1), -- 5310
				INK -- 5310
			) -- 5310
		end -- 5310
	end -- 5310
	if self.hasBottle then -- 5310
		local p = self.player -- 5315
		self:drawBottle( -- 5316
			draw, -- 5316
			w, -- 5316
			h, -- 5316
			p.x + p.facing * 10, -- 5316
			p.y + p.h * 0.62 -- 5316
		) -- 5316
	end -- 5316
	if self.bottleFly ~= nil then -- 5316
		self:drawBottle( -- 5319
			draw, -- 5319
			w, -- 5319
			h, -- 5319
			self.bottleFly.x, -- 5319
			self.bottleFly.y -- 5319
		) -- 5319
	end -- 5319
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5319
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5322
		draw:drawCircle( -- 5323
			Vec2( -- 5323
				self:sx(self.bottleLandX, w), -- 5323
				self:sy(0, h) -- 5323
			), -- 5323
			self:px(r / ____exports.UNITS_PER_PX), -- 5323
			BRICK_LINE -- 5323
		) -- 5323
	end -- 5323
end -- 5290
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5327
	self:drawBox( -- 5328
		draw, -- 5328
		w, -- 5328
		h, -- 5328
		x - 3, -- 5328
		x + 3, -- 5328
		y - 10, -- 5328
		y, -- 5328
		BOTTLE -- 5328
	) -- 5328
end -- 5327
function Play.prototype.drawTrace(self, draw, w, h) -- 5331
	local t = self.trace -- 5332
	if t == nil or self.traceT <= 0 then -- 5332
		return -- 5334
	end -- 5334
	draw:drawSegment( -- 5336
		Vec2( -- 5337
			self:sx(t.x0, w), -- 5337
			self:sy(t.y0, h) -- 5337
		), -- 5337
		Vec2( -- 5338
			self:sx(t.x1, w), -- 5338
			self:sy(t.y1, h) -- 5338
		), -- 5338
		self:px(1), -- 5339
		t.hit and AIM_HIT or INK_DIM -- 5339
	) -- 5339
end -- 5331
function Play.prototype.drawAim(self, draw, w, h) -- 5342
	local v = self.view -- 5344
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5345
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5346
	local dot = self:px(1) -- 5347
	local arm = self:px(3) -- 5348
	local gap = self:px(1) -- 5349
	draw:drawSegment( -- 5350
		Vec2(gx - arm - gap, gy), -- 5350
		Vec2(gx - gap, gy), -- 5350
		dot / 2, -- 5350
		AIM -- 5350
	) -- 5350
	draw:drawSegment( -- 5351
		Vec2(gx + gap, gy), -- 5351
		Vec2(gx + arm + gap, gy), -- 5351
		dot / 2, -- 5351
		AIM -- 5351
	) -- 5351
	draw:drawSegment( -- 5352
		Vec2(gx, gy - arm - gap), -- 5352
		Vec2(gx, gy - gap), -- 5352
		dot / 2, -- 5352
		AIM -- 5352
	) -- 5352
	draw:drawSegment( -- 5353
		Vec2(gx, gy + gap), -- 5353
		Vec2(gx, gy + arm + gap), -- 5353
		dot / 2, -- 5353
		AIM -- 5353
	) -- 5353
	if self.room.key == "village" and self.hasBottle then -- 5353
		local p = self.player -- 5357
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5359
		local dir = ____end.x >= p.x and 1 or -1 -- 5360
		local x0 = p.x + dir * 10 -- 5361
		local y0 = p.y + p.h * 0.7 -- 5362
		local T = BOTTLE_FLY_TIME -- 5363
		local vx = (____end.x - x0) / T -- 5364
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5365
		local pxr = x0 -- 5366
		local pyr = y0 -- 5367
		local t = 1 -- 5368
		do -- 5368
			t = 1 -- 5369
			while t <= 12 do -- 5369
				local tt = t / 12 * T -- 5370
				local nx = x0 + vx * tt -- 5371
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5372
				draw:drawSegment( -- 5373
					Vec2( -- 5373
						self:sx(pxr, w), -- 5373
						self:sy(pyr, h) -- 5373
					), -- 5373
					Vec2( -- 5373
						self:sx(nx, w), -- 5373
						self:sy(ny, h) -- 5373
					), -- 5373
					self:px(1) / 2, -- 5373
					BOTTLE -- 5373
				) -- 5373
				pxr = nx -- 5374
				pyr = ny -- 5375
				t = t + 1 -- 5369
			end -- 5369
		end -- 5369
		draw:drawCircle( -- 5377
			Vec2( -- 5377
				self:sx(____end.x, w), -- 5377
				self:sy(____end.y + 2, h) -- 5377
			), -- 5377
			self:px(2), -- 5377
			BOTTLE -- 5377
		) -- 5377
	end -- 5377
end -- 5342
return ____exports -- 5342