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
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 23
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
function makeActor(room, index) -- 5577
	local sp = room.spawns -- 5578
	if index < 0 or index >= #sp then -- 5578
		return { -- 5580
			x = 0, -- 5580
			y = 0, -- 5580
			depth = 0, -- 5580
			depthSpeed = 0, -- 5580
			vx = 0, -- 5580
			vy = 0, -- 5580
			w = CHILD_W, -- 5580
			h = CHILD_H, -- 5580
			onGround = true, -- 5580
			facing = 1, -- 5580
			crouch = false, -- 5580
			rollT = 0, -- 5580
			covered = false, -- 5580
			alive = false -- 5580
		} -- 5580
	end -- 5580
	local s = sp[index + 1] -- 5582
	local child = s.h < SOLDIER_H -- 5583
	local ground = room.depth -- 5584
	local depth = ground == nil and 0 or math.max( -- 5585
		ground.min, -- 5585
		math.min(ground.max, s.depth or 0) -- 5585
	) -- 5585
	return { -- 5586
		x = s.x, -- 5587
		y = s.y, -- 5587
		depth = depth, -- 5587
		depthSpeed = 0, -- 5587
		vx = 0, -- 5587
		vy = 0, -- 5587
		w = child and CHILD_W or SOLDIER_W, -- 5588
		h = child and CHILD_H or SOLDIER_H, -- 5589
		onGround = true, -- 5590
		facing = 1, -- 5590
		crouch = false, -- 5590
		rollT = 0, -- 5590
		covered = false, -- 5590
		alive = true -- 5590
	} -- 5590
end -- 5590
function drawFigure(draw, play, w, h, a, body, head) -- 5594
	if not a.alive then -- 5594
		return -- 5596
	end -- 5596
	local x0 = a.x - a.w / 2 -- 5598
	local x1 = a.x + a.w / 2 -- 5599
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 5600
	local y1 = y0 + a.h -- 5601
	play:drawBox( -- 5602
		draw, -- 5602
		w, -- 5602
		h, -- 5602
		x0, -- 5602
		x1, -- 5602
		y0, -- 5602
		y1 - a.h * 0.26, -- 5602
		body -- 5602
	) -- 5602
	play:drawBox( -- 5603
		draw, -- 5603
		w, -- 5603
		h, -- 5603
		x0 + 2, -- 5603
		x1 - 2, -- 5603
		y1 - a.h * 0.26, -- 5603
		y1, -- 5603
		head -- 5603
	) -- 5603
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5605
	play:drawBox( -- 5606
		draw, -- 5606
		w, -- 5606
		h, -- 5606
		eyeX, -- 5606
		eyeX + 4, -- 5606
		y1 - a.h * 0.14, -- 5606
		y1 - a.h * 0.08, -- 5606
		INK -- 5606
	) -- 5606
end -- 5606
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5610
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5611
end -- 5610
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5618
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5619
end -- 5618
function rayInterval(origin, direction, min, max) -- 5626
	if direction == 0 then -- 5626
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5628
	end -- 5628
	local a = (min - origin) / direction -- 5630
	local b = (max - origin) / direction -- 5631
	return { -- 5632
		min = math.min(a, b), -- 5632
		max = math.max(a, b) -- 5632
	} -- 5632
end -- 5632
function hitBox(ray, box) -- 5636
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5637
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5638
	local enter = math.max(0, x.min, y.min) -- 5639
	local leave = math.min(99999, x.max, y.max) -- 5640
	if box.depth ~= nil then -- 5640
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5642
		enter = math.max(enter, depth.min) -- 5643
		leave = math.min(leave, depth.max) -- 5644
	end -- 5644
	return leave >= enter and enter or -1 -- 5646
end -- 5646
function drawCartShape(draw, play, w, h, c, axleX) -- 5649
	local half = c.bodyW / 2 -- 5650
	local x0 = axleX - half -- 5651
	local x1 = axleX + half -- 5652
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 5653
	play:drawBox( -- 5654
		draw, -- 5654
		w, -- 5654
		h, -- 5654
		x0, -- 5654
		x1, -- 5654
		axleY, -- 5654
		axleY + c.bodyH, -- 5654
		CART_FILL -- 5654
	) -- 5654
	draw:drawCircle( -- 5655
		Vec2( -- 5655
			play:sx(x0 + c.bodyW * 0.28, w), -- 5655
			play:sy(axleY, h) -- 5655
		), -- 5655
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5655
		Color(52, 50, 48, 255) -- 5655
	) -- 5655
	draw:drawCircle( -- 5656
		Vec2( -- 5656
			play:sx(x1 - c.bodyW * 0.28, w), -- 5656
			play:sy(axleY, h) -- 5656
		), -- 5656
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5656
		Color(52, 50, 48, 255) -- 5656
	) -- 5656
	local cx = c.clothSide < 0 and x0 or x1 -- 5657
	play:drawBox( -- 5658
		draw, -- 5658
		w, -- 5658
		h, -- 5658
		cx - 10, -- 5658
		cx + 10, -- 5658
		axleY + c.bodyH, -- 5658
		axleY + c.bodyH + 18, -- 5658
		CLOTH -- 5658
	) -- 5658
end -- 5658
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
CHILD_H = 56 -- 143
local CHILD_CROUCH_H = 34 -- 144
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
					local ____self_boxes_17 = self.boxes -- 1132
					local ____temp_15 = x0 + stepW -- 1133
					local ____temp_16 = -8 -- 1133
					local ____temp_14 -- 1134
					if room.depth == nil then -- 1134
						____temp_14 = nil -- 1134
					else -- 1134
						____temp_14 = st.depth -- 1134
					end -- 1134
					____self_boxes_17[#____self_boxes_17 + 1] = { -- 1132
						x0 = x0, -- 1133
						x1 = ____temp_15, -- 1133
						y0 = ____temp_16, -- 1133
						y1 = y, -- 1133
						depth = ____temp_14, -- 1134
						passable = true -- 1135
					} -- 1135
					k = k + 1 -- 1127
				end -- 1127
			end -- 1127
			i = i + 1 -- 1122
		end -- 1122
	end -- 1122
end -- 1096
function Play.prototype.setupCampaign(self) -- 1145
	local wr = self.room -- 1146
	local c = wr.campaign -- 1147
	if c == nil then -- 1147
		return -- 1149
	end -- 1149
	self.roomStartTick = self.run.ticks -- 1151
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1151
		self.run.joined = true -- 1155
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1155
		local ____self_run_19 = self.run -- 1158
		local ____temp_18 -- 1158
		if wr.key == "s2-drygoods" then -- 1158
			____temp_18 = self.run.route ~= "drygoods" -- 1158
		else -- 1158
			____temp_18 = false -- 1158
		end -- 1158
		____self_run_19.joined = ____temp_18 -- 1158
	end -- 1158
	local x = wr.minX + 60 -- 1160
	local y = 0 -- 1161
	local depth = 0 -- 1162
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1162
		x = wr.minX + 210 -- 1164
		depth = -32 -- 1165
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1165
		x = wr.minX + 40 -- 1167
		y = 32 -- 1168
		depth = 32 -- 1169
	end -- 1169
	self.player = { -- 1171
		x = x, -- 1172
		y = y, -- 1172
		depth = depth, -- 1172
		depthSpeed = 0, -- 1172
		vx = 0, -- 1172
		vy = 0, -- 1172
		w = SOLDIER_W, -- 1173
		h = SOLDIER_H, -- 1173
		onGround = y <= 0, -- 1173
		facing = 1, -- 1173
		crouch = false, -- 1173
		rollT = 0, -- 1173
		covered = false, -- 1173
		alive = true -- 1173
	} -- 1173
	self.partner = { -- 1175
		x = x + 60, -- 1176
		y = y, -- 1176
		depth = depth, -- 1176
		depthSpeed = 0, -- 1176
		vx = 0, -- 1176
		vy = 0, -- 1176
		w = CHILD_W, -- 1177
		h = CHILD_H, -- 1177
		onGround = y <= 0, -- 1177
		facing = 1, -- 1177
		crouch = false, -- 1177
		rollT = 0, -- 1177
		covered = false, -- 1177
		alive = true -- 1177
	} -- 1177
	self.cam.x = x -- 1179
	self.cam.y = y + CAM_LOOK_UP -- 1180
	self.phase = "run" -- 1181
	self.hp = self.maxHp -- 1182
	local trial = self.run.trial -- 1183
	if trial ~= nil then -- 1183
		draftRoom(trial, wr.key) -- 1185
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1186
		self.hp = trial.hp -- 1187
	end -- 1187
	self:buildEnemies() -- 1189
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1190
	local i = 0 -- 1191
	do -- 1191
		i = 0 -- 1192
		while i < #self.boxes do -- 1192
			do -- 1192
				local b = self.boxes[i + 1] -- 1193
				if b.id == nil then -- 1193
					goto __continue101 -- 1195
				end -- 1195
				local st = self.run.props[b.id] -- 1197
				if st ~= nil then -- 1197
					b.broken = st.broken -- 1199
					local ____temp_20 -- 1200
					if b.breakable == nil then -- 1200
						____temp_20 = nil -- 1200
					else -- 1200
						____temp_20 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1200
					end -- 1200
					b.breakable = ____temp_20 -- 1200
					b.hidden = b.hidden == true and st.revealed ~= true -- 1201
					if b.hidden then -- 1201
						b.broken = true -- 1203
					end -- 1203
				elseif b.hidden == true then -- 1203
					b.broken = true -- 1207
				end -- 1207
			end -- 1207
			::__continue101:: -- 1207
			i = i + 1 -- 1192
		end -- 1192
	end -- 1192
	if wr.cart.bodyW > 0 then -- 1192
		self.cartAxle = wr.cart.startX -- 1211
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1211
			self.cartAxle = wr.cart.endX -- 1213
			self.cartDocked = true -- 1214
		end -- 1214
	end -- 1214
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1217
end -- 1145
function Play.prototype.log(self, line) -- 1220
	local ____self_run_log_21 = self.run.log -- 1220
	____self_run_log_21[#____self_run_log_21 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1221
	if #self.run.log > 120 then -- 1221
		table.remove(self.run.log, 1) -- 1223
	end -- 1223
end -- 1220
function Play.prototype.buildEnemies(self) -- 1227
	self.enemies = {} -- 1228
	if self.isCampaign then -- 1228
		local i = 0 -- 1230
		do -- 1230
			i = 0 -- 1231
			while i < #self.room.spawns do -- 1231
				local sp = self.room.spawns[i + 1] -- 1232
				local kind = sp.kind or "gunner" -- 1233
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1234
				local ____self_enemies_22 = self.enemies -- 1234
				____self_enemies_22[#____self_enemies_22 + 1] = { -- 1235
					x = sp.x, -- 1236
					y = sp.y, -- 1236
					depth = sp.depth, -- 1236
					w = 26, -- 1236
					h = sp.h, -- 1236
					alive = true, -- 1236
					hitT = 0, -- 1236
					warnT = 0, -- 1236
					fireCd = 40, -- 1236
					kind = kind, -- 1237
					shieldHp = hp, -- 1237
					shieldHpMax = hp, -- 1237
					drop = sp.drop or "none", -- 1237
					homeX = sp.x, -- 1238
					swingT = 0, -- 1238
					awake = false, -- 1238
					squad = i -- 1238
				} -- 1238
				i = i + 1 -- 1231
			end -- 1231
		end -- 1231
		return -- 1241
	end -- 1241
	if self.room.key == "checkpoint" then -- 1241
		local ____self_enemies_23 = self.enemies -- 1241
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1244
			x = self.ox + 430, -- 1244
			y = 0, -- 1244
			w = 26, -- 1244
			h = 84, -- 1244
			alive = true, -- 1244
			hitT = 0, -- 1244
			warnT = 0, -- 1244
			fireCd = 0 -- 1244
		} -- 1244
		local ____self_enemies_24 = self.enemies -- 1244
		____self_enemies_24[#____self_enemies_24 + 1] = { -- 1245
			x = self.ox + 505, -- 1245
			y = 0, -- 1245
			w = 26, -- 1245
			h = 84, -- 1245
			alive = true, -- 1245
			hitT = 0, -- 1245
			warnT = 0, -- 1245
			fireCd = 0 -- 1245
		} -- 1245
		return -- 1246
	end -- 1246
	if self.room.key == "street" then -- 1246
		local ____self_enemies_25 = self.enemies -- 1246
		____self_enemies_25[#____self_enemies_25 + 1] = { -- 1250
			x = self.ox + 340, -- 1250
			y = 0, -- 1250
			w = 26, -- 1250
			h = 84, -- 1250
			alive = true, -- 1250
			hitT = 0, -- 1250
			warnT = 0, -- 1250
			fireCd = 0 -- 1250
		} -- 1250
		local ____self_enemies_26 = self.enemies -- 1250
		____self_enemies_26[#____self_enemies_26 + 1] = { -- 1251
			x = self.ox + 560, -- 1251
			y = 0, -- 1251
			w = 26, -- 1251
			h = 84, -- 1251
			alive = true, -- 1251
			hitT = 0, -- 1251
			warnT = 0, -- 1251
			fireCd = 0 -- 1251
		} -- 1251
	end -- 1251
end -- 1227
function Play.prototype.emit(self, name, data) -- 1257
	local ____self_events_27 = self.events -- 1257
	____self_events_27[#____self_events_27 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1258
	self.eventSeq = self.eventSeq + 1 -- 1259
	if #self.events > 256 then -- 1259
		table.remove(self.events, 1) -- 1261
	end -- 1261
end -- 1257
function Play.prototype.drainEvents(self) -- 1269
	local out = self.events -- 1270
	self.events = {} -- 1271
	return out -- 1272
end -- 1269
function Play.prototype.adoptEvents(self, events) -- 1281
	if #events == 0 then -- 1281
		return -- 1283
	end -- 1283
	local keep = {} -- 1285
	local i = 0 -- 1286
	do -- 1286
		i = 0 -- 1287
		while i < #events do -- 1287
			do -- 1287
				local e = events[i + 1] -- 1288
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1288
					goto __continue122 -- 1290
				end -- 1290
				keep[#keep + 1] = e -- 1292
			end -- 1292
			::__continue122:: -- 1292
			i = i + 1 -- 1287
		end -- 1287
	end -- 1287
	if #keep == 0 then -- 1287
		return -- 1295
	end -- 1295
	self.events = __TS__ArrayConcat(keep, self.events) -- 1297
	do -- 1297
		i = 0 -- 1298
		while i < #self.events do -- 1298
			self.events[i + 1].seq = i -- 1299
			i = i + 1 -- 1298
		end -- 1298
	end -- 1298
	self.eventSeq = #self.events -- 1301
end -- 1281
function Play.prototype.chooseTalent(self, slot) -- 1304
	local trial = self.run.trial -- 1305
	local talent = trial and trial.offers[slot + 1] -- 1306
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1306
		return -- 1307
	end -- 1307
	local ____trial_ranks_30, ____talent_31 = trial.ranks, talent -- 1307
	____trial_ranks_30[____talent_31] = ____trial_ranks_30[____talent_31] + 1 -- 1308
	trial.offers = {} -- 1309
	if talent == "vitality" then -- 1309
		self.maxHp = self.maxHp + 1 -- 1311
		self.hp = self.hp + 1 -- 1312
		trial.hp = self.hp -- 1313
	end -- 1313
	self:flashSet(talentNames[talent], 1.2) -- 1315
end -- 1304
function Play.prototype.beginReload(self) -- 1323
	self.reloadT = self:reloadTicks() -- 1324
	local camp = self.room.campaign -- 1325
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1325
		self:openReloadPuzzle() -- 1328
	end -- 1328
end -- 1323
function Play.prototype.openReloadPuzzle(self) -- 1333
	self.reloadOpen = true -- 1334
	self.reloadAnswerTicks = 0 -- 1335
	self.reloadWorldTicks = 0 -- 1336
	self.reloadPath = {RELOAD_START} -- 1337
	self.reloadPendingEffect = "" -- 1338
	self.reloadTryCount = self.reloadTryCount + 1 -- 1339
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1340
end -- 1333
function Play.prototype.closeReloadPuzzle(self) -- 1344
	self.reloadOpen = false -- 1345
	self.reloadAnswerTicks = 0 -- 1346
	self.reloadWorldTicks = 0 -- 1347
	self.reloadPath = {RELOAD_START} -- 1348
	self.reloadPendingEffect = "" -- 1349
end -- 1344
function Play.prototype.reloadTapNode(self, node) -- 1356
	if not self.reloadOpen then -- 1356
		return -- 1358
	end -- 1358
	local path = self.reloadPath -- 1360
	local last = path[#path] -- 1361
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1361
		self.reloadPath = {RELOAD_START} -- 1363
		self:emit("reloadInvalid", {node = node, at = last}) -- 1364
		return -- 1365
	end -- 1365
	path[#path + 1] = node -- 1367
	if node ~= RELOAD_TARGET then -- 1367
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1369
		return -- 1370
	end -- 1370
	if not reloadPathValid(path) then -- 1370
		self.reloadPath = {RELOAD_START} -- 1373
		self:emit("reloadInvalid", {node = node, at = last}) -- 1374
		return -- 1375
	end -- 1375
	self.reloadPendingEffect = reloadEffectOf(path) -- 1377
	self.reloadOpen = false -- 1378
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1379
	self:flashSet( -- 1382
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1382
		1.4 -- 1382
	) -- 1382
end -- 1356
function Play.prototype.consumeReloadEffect(self) -- 1386
	local e = self.reloadPendingEffect -- 1387
	if e ~= "" then -- 1387
		self.reloadPendingEffect = "" -- 1389
	end -- 1389
	return e -- 1391
end -- 1386
function Play.prototype.echoToSource(self, from, count) -- 1398
	if count == nil then -- 1398
		count = 1 -- 1398
	end -- 1398
	local best = -1 -- 1399
	local bestD = 1000000000 -- 1400
	local i = 0 -- 1401
	local woken = {} -- 1402
	local n = 0 -- 1403
	while n < count do -- 1403
		best = -1 -- 1405
		bestD = 1000000000 -- 1406
		do -- 1406
			i = 0 -- 1407
			while i < #self.enemies do -- 1407
				do -- 1407
					if woken[i] == true then -- 1407
						goto __continue144 -- 1409
					end -- 1409
					local e = self.enemies[i + 1] -- 1411
					if not e.alive then -- 1411
						goto __continue144 -- 1413
					end -- 1413
					local d = math.abs(e.x - from.x) -- 1415
					if d < bestD then -- 1415
						bestD = d -- 1417
						best = i -- 1418
					end -- 1418
				end -- 1418
				::__continue144:: -- 1418
				i = i + 1 -- 1407
			end -- 1407
		end -- 1407
		if best < 0 then -- 1407
			break -- 1422
		end -- 1422
		woken[best] = true -- 1424
		local e = self.enemies[best + 1] -- 1425
		e.awake = true -- 1426
		e.warnT = 0 -- 1427
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1428
		n = n + 1 -- 1429
	end -- 1429
	if n == 0 then -- 1429
		return -- 1432
	end -- 1432
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1434
end -- 1398
function Play.prototype.reloadTicks(self) -- 1437
	local ____temp_34 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1438
	local ____opt_32 = self.run.trial -- 1438
	return math.max(6, ____temp_34 - 6 * (____opt_32 and ____opt_32.ranks.reload or 0)) -- 1438
end -- 1437
function Play.prototype.update(self, dt, input) -- 1441
	self:syncCraftBench() -- 1442
	local trial = self.run.trial -- 1443
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1443
		return -- 1444
	end -- 1444
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1444
		self:closeCraftBench() -- 1446
		return -- 1447
	end -- 1447
	if input.pause.pressed then -- 1447
		self.paused = not self.paused -- 1450
	end -- 1450
	if self.flashT > 0 then -- 1450
		self.flashT = self.flashT - dt -- 1453
		if self.flashT <= 0 then -- 1453
			self.flash = "" -- 1455
		end -- 1455
	end -- 1455
	if self.traceT > 0 then -- 1455
		self.traceT = self.traceT - dt -- 1459
		if self.traceT <= 0 then -- 1459
			self.trace = nil -- 1461
		end -- 1461
	end -- 1461
	if self.paused then -- 1461
		self:updateCamera(dt) -- 1465
		return -- 1466
	end -- 1466
	if self.craftBench.active then -- 1466
		self:updateCamera(dt) -- 1471
		return -- 1472
	end -- 1472
	if self.reloadOpen then -- 1472
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1478
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1478
			self.reloadOpen = false -- 1480
			self.reloadPendingEffect = "" -- 1481
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1482
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1483
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1483
			self:updateCamera(dt) -- 1485
			return -- 1486
		else -- 1486
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1488
		end -- 1488
	end -- 1488
	self.ticks = self.ticks + 1 -- 1492
	if self.invulnT > 0 then -- 1492
		self.invulnT = self.invulnT - 1 -- 1496
	end -- 1496
	if self.isCampaign then -- 1496
		local ____self_run_35, ____ticks_36 = self.run, "ticks" -- 1496
		____self_run_35[____ticks_36] = ____self_run_35[____ticks_36] + 1 -- 1499
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1500
	end -- 1500
	local p = self.player -- 1502
	self:stepPlayer(p, dt, input) -- 1503
	self:refreshCover(p, input) -- 1505
	if self.carryOn then -- 1505
		self:carryPose() -- 1507
	end -- 1507
	if self.isCampaign then -- 1507
		self:stepCampaign(dt, input) -- 1510
		if not self.carryOn then -- 1510
			self:stepCampaignPartner(dt) -- 1512
		end -- 1512
	end -- 1512
	if trial == nil or not self.run.finished then -- 1512
		self:stepEnemies(dt, input) -- 1520
	end -- 1520
	if trial ~= nil then -- 1520
		trial.hp = self.hp -- 1522
	end -- 1522
	if not self.isCampaign then -- 1522
		self:stepStory(dt, input) -- 1524
		self:stepEscort(dt, input) -- 1525
		self:stepVillage(dt, input) -- 1526
		self:stepChase(dt, input) -- 1527
		self:stepInteract(dt, input) -- 1528
	end -- 1528
	self:updateGate() -- 1530
	self:updateCamera(dt) -- 1531
	self:syncStory() -- 1533
end -- 1441
function Play.prototype.underLowArch(self, a) -- 1540
	local arch = self.room.arch -- 1541
	if arch.h <= 0 then -- 1541
		return false -- 1543
	end -- 1543
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1543
		return false -- 1546
	end -- 1546
	local top = arch.y + arch.h -- 1548
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1549
end -- 1540
function Play.prototype.coverAt(self, a) -- 1556
	local best = nil -- 1557
	local bestGap = 24 -- 1558
	local half = a.w / 2 -- 1559
	local i = 0 -- 1560
	do -- 1560
		i = 0 -- 1561
		while i < #self.boxes do -- 1561
			do -- 1561
				local b = self.boxes[i + 1] -- 1562
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1562
					goto __continue178 -- 1564
				end -- 1564
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1564
					goto __continue178 -- 1567
				end -- 1567
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1569
				if gap < bestGap then -- 1569
					bestGap = gap -- 1571
					best = b -- 1572
				end -- 1572
			end -- 1572
			::__continue178:: -- 1572
			i = i + 1 -- 1561
		end -- 1561
	end -- 1561
	return best -- 1575
end -- 1556
function Play.prototype.nearCover(self, a) -- 1578
	return self:coverAt(a) ~= nil -- 1579
end -- 1578
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1583
	if enemy == nil then -- 1583
		return false -- 1585
	end -- 1585
	local fromRight = enemy.x >= a.x -- 1587
	local edge = fromRight and b.x0 or b.x1 -- 1588
	local ____fromRight_37 -- 1589
	if fromRight then -- 1589
		____fromRight_37 = edge >= a.x - 0.001 and edge <= enemy.x -- 1589
	else -- 1589
		____fromRight_37 = edge <= a.x + 0.001 and edge >= enemy.x -- 1590
	end -- 1590
	local between = ____fromRight_37 -- 1589
	local separation = enemy.x - a.x -- 1591
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1592
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1593
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1594
end -- 1583
function Play.prototype.nearestEnemy(self, a) -- 1597
	local best -- 1598
	local bestD = 1000000000 -- 1599
	local i = 0 -- 1600
	do -- 1600
		i = 0 -- 1601
		while i < #self.enemies do -- 1601
			do -- 1601
				local e = self.enemies[i + 1] -- 1602
				if not e.alive then -- 1602
					goto __continue187 -- 1604
				end -- 1604
				local d = math.abs(e.x - a.x) -- 1606
				if d < bestD then -- 1606
					bestD = d -- 1608
					best = e -- 1609
				end -- 1609
			end -- 1609
			::__continue187:: -- 1609
			i = i + 1 -- 1601
		end -- 1601
	end -- 1601
	return best -- 1612
end -- 1597
function Play.prototype.refreshCover(self, a, input) -- 1616
	if self.childMode then -- 1616
		self.coverNear = false -- 1618
		self.coverHug = false -- 1619
		self.coverEntity = "" -- 1620
		self.coverBlocking = false -- 1621
		a.covered = false -- 1622
		return -- 1623
	end -- 1623
	local b = self:coverAt(a) -- 1625
	self.coverNear = b ~= nil -- 1626
	a.covered = self.coverNear and input.cover.held -- 1627
	self.coverHug = a.covered -- 1628
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1629
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1630
		b, -- 1630
		a, -- 1630
		self:nearestEnemy(a) -- 1630
	) -- 1630
end -- 1616
function Play.prototype.cartHandleInReach(self, a) -- 1634
	if a == nil then -- 1634
		a = self.player -- 1634
	end -- 1634
	local c = self.room.cart -- 1635
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1635
		return false -- 1637
	end -- 1637
	local handleX = self.cartAxle + c.handleOffset -- 1639
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1640
end -- 1634
function Play.prototype.nearLowLedge(self, a) -- 1645
	local reach = 26 -- 1646
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1647
	local x1 = x0 + reach -- 1648
	local i = 0 -- 1649
	do -- 1649
		i = 0 -- 1650
		while i < #self.boxes do -- 1650
			do -- 1650
				local b = self.boxes[i + 1] -- 1651
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1651
					goto __continue196 -- 1653
				end -- 1653
				local rise = b.y1 - a.y -- 1655
				if rise > 0 and rise <= LEDGE_RISE then -- 1655
					return true -- 1657
				end -- 1657
			end -- 1657
			::__continue196:: -- 1657
			i = i + 1 -- 1650
		end -- 1650
	end -- 1650
	return false -- 1660
end -- 1645
function Play.prototype.stepPlayer(self, a, dt, input) -- 1663
	a.depthSpeed = 0 -- 1664
	if not a.alive then -- 1664
		return -- 1666
	end -- 1666
	local isChild = self.childMode -- 1668
	local lowArch = isChild and self:underLowArch(a) -- 1670
	if self:storyLocked() then -- 1670
		a.vx = 0 -- 1673
		a.crouch = isChild and lowArch -- 1674
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1675
		self:fallY(a, dt) -- 1676
		return -- 1677
	end -- 1677
	if not isChild and self.escort.state == "calming" then -- 1677
		a.crouch = false -- 1681
		a.h = SOLDIER_H -- 1682
		a.vx = 0 -- 1683
		self:fallY(a, dt) -- 1684
		return -- 1685
	end -- 1685
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 1687
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 1688
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1689
	local nearCover = not isChild and self:nearCover(a) -- 1690
	a.covered = nearCover and input.cover.held -- 1691
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1693
	if a.rollT > 0 then -- 1693
		a.rollT = a.rollT - dt -- 1697
		a.vx = a.facing * ROLL_SPEED -- 1698
		self:slideX(a, a.vx * dt) -- 1699
		self:fallY(a, dt) -- 1700
		if a.rollT <= 0 then -- 1700
			self:flashSet("翻滚结束", 0.5) -- 1702
		end -- 1702
		return -- 1704
	end -- 1704
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1704
		if input.moveX ~= 0 then -- 1704
			a.facing = input.moveX > 0 and 1 or -1 -- 1709
		end -- 1709
		if self:nearLowLedge(a) then -- 1709
			a.vy = SOLDIER_JUMP -- 1713
			a.onGround = false -- 1714
			self:flashSet("翻上去", 0.3) -- 1715
			return -- 1716
		end -- 1716
		a.rollT = ROLL_TIME -- 1718
		self:flashSet("翻滚", 0.3) -- 1719
		return -- 1720
	end -- 1720
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1723
	if isChild then -- 1723
		if input.cover.held then -- 1723
			speed = CHILD_SLOW -- 1726
		end -- 1726
		if a.crouch then -- 1726
			speed = CHILD_SLOW -- 1729
		end -- 1729
	elseif a.covered then -- 1729
		speed = SOLDIER_SPEED * 0.45 -- 1732
	end -- 1732
	local handsBusy = self.gripping or gripIntent -- 1736
	local dir = self.gripping and 0 or input.moveX -- 1737
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 1739
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1741
	if dir ~= 0 then -- 1741
		a.facing = dir > 0 and 1 or -1 -- 1743
	end -- 1743
	a.vx = dir * speed * diagonal -- 1745
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1745
		a.vy = CHILD_JUMP -- 1749
		a.onGround = false -- 1750
		self:flashSet("跳", 0.25) -- 1751
	end -- 1751
	local previousDepth = a.depth -- 1755
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1756
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1757
	self:slideX(a, a.vx * dt) -- 1758
	self:fallY(a, dt) -- 1759
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1759
		self:shoot(a) -- 1763
	end -- 1763
end -- 1663
function Play.prototype.stepPartner(self, p, dt) -- 1768
	local a = self.partner -- 1769
	if not a.alive then -- 1769
		return -- 1771
	end -- 1771
	a.crouch = false -- 1773
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1774
	a.vx = 0 -- 1775
	a.depthSpeed = 0 -- 1776
	self:fallY(a, dt) -- 1777
end -- 1768
function Play.prototype.stepEscort(self, dt, input) -- 1784
	local a = self.partner -- 1785
	a.depthSpeed = 0 -- 1786
	if not a.alive then -- 1786
		return -- 1788
	end -- 1788
	if self.room.key == "gatepath" then -- 1788
		if self.carryOn then -- 1788
			return -- 1793
		end -- 1793
		local p = self.player -- 1796
		a.depth = p.depth -- 1797
		a.facing = p.facing -- 1798
		a.crouch = false -- 1799
		a.h = CHILD_H -- 1800
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1801
		a.y = p.y -- 1802
		a.vy = 0 -- 1803
		a.vx = p.vx -- 1804
		a.onGround = p.onGround -- 1805
		return -- 1806
	end -- 1806
	if not self:escortOn() then -- 1806
		a.vx = 0 -- 1809
		self:fallY(a, dt) -- 1810
		return -- 1811
	end -- 1811
	local p = self.player -- 1813
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1814
	local hadKnock1 = self.escort.knock1 -- 1815
	local hadKnock2 = self.escort.knock2 -- 1816
	self.calmConsumed = self.escort:update( -- 1817
		input, -- 1817
		p.x, -- 1817
		p.facing, -- 1817
		a.x, -- 1817
		dist -- 1817
	) -- 1817
	if not hadKnock1 and self.escort.knock1 then -- 1817
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1820
	end -- 1820
	if not hadKnock2 and self.escort.knock2 then -- 1820
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1823
	end -- 1823
	a.crouch = self.escort.crouchPose -- 1825
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1826
	if not self.escort.stopped then -- 1826
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1828
		local previousDepth = a.depth -- 1829
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1830
		local distance = math.max( -- 1831
			-travel, -- 1831
			math.min(travel, targetDepth - previousDepth) -- 1831
		) -- 1831
		self:slideDepth(a, distance) -- 1832
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1833
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1833
			a.vy = CHILD_JUMP -- 1835
			a.onGround = false -- 1836
		end -- 1836
	end -- 1836
	local dir = self.escort:moveDir(a.x) -- 1839
	a.vx = dir * CHILD_SPEED -- 1840
	if dir ~= 0 then -- 1840
		a.facing = dir -- 1842
		local before = a.x -- 1843
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1844
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1844
			a.vy = CHILD_JUMP -- 1847
			a.onGround = false -- 1848
		end -- 1848
	end -- 1848
	self:fallY(a, dt) -- 1851
end -- 1784
function Play.prototype.escortOn(self) -- 1855
	if self.room.key == "checkpoint" then -- 1855
		return true -- 1857
	end -- 1857
	if self.room.key == "gatepath" then -- 1857
		return true -- 1860
	end -- 1860
	if self.room.key == "prologue" then -- 1860
		return self.phase == "prologue-follow" -- 1863
	end -- 1863
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1863
		return true -- 1867
	end -- 1867
	return self.room.key == "street" -- 1869
end -- 1855
function Play.prototype.storyLocked(self) -- 1873
	if self.caughtT > 0 then -- 1873
		return true -- 1875
	end -- 1875
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 1875
		return true -- 1879
	end -- 1879
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1879
		return true -- 1882
	end -- 1882
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1882
		return true -- 1885
	end -- 1885
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 1885
		return true -- 1888
	end -- 1888
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1888
		return true -- 1891
	end -- 1891
	if self.craftBench.active then -- 1891
		return true -- 1895
	end -- 1895
	return false -- 1897
end -- 1873
function Play.prototype.swapToChild(self, x) -- 1901
	local tmp = self.player -- 1902
	self.player = self.partner -- 1903
	self.partner = tmp -- 1904
	self.childMode = true -- 1905
	self.player.alive = true -- 1906
	self.player.x = self.ox + x -- 1907
	self.player.y = 0 -- 1908
	self.player.depth = 0 -- 1909
	self.player.depthSpeed = 0 -- 1910
	self.player.vy = 0 -- 1911
	self.player.vx = 0 -- 1912
	self.player.onGround = true -- 1913
	self.player.crouch = false -- 1914
	self.player.h = CHILD_H -- 1915
	self.player.facing = 1 -- 1916
	self.partner.alive = true -- 1917
	self.cam.x = self.player.x -- 1918
end -- 1901
function Play.prototype.swapToSoldier(self, x, childX) -- 1922
	local tmp = self.player -- 1923
	self.player = self.partner -- 1924
	self.partner = tmp -- 1925
	self.childMode = false -- 1926
	self.player.alive = true -- 1927
	self.player.x = self.ox + x -- 1928
	self.player.y = 0 -- 1929
	self.player.depth = 0 -- 1930
	self.player.depthSpeed = 0 -- 1931
	self.player.vy = 0 -- 1932
	self.player.vx = 0 -- 1933
	self.player.onGround = true -- 1934
	self.player.crouch = false -- 1935
	self.player.h = SOLDIER_H -- 1936
	self.player.facing = 1 -- 1937
	self.partner.alive = true -- 1938
	self.partner.x = self.ox + childX -- 1939
	self.partner.y = 0 -- 1940
	self.partner.depth = 0 -- 1941
	self.partner.depthSpeed = 0 -- 1942
	self.partner.vx = 0 -- 1943
	self.partner.vy = 0 -- 1944
	self.partner.onGround = true -- 1945
	self.partner.crouch = true -- 1946
	self.partner.h = CHILD_CROUCH_H -- 1947
	self.cam.x = self.player.x -- 1948
end -- 1922
function Play.prototype.stepStory(self, dt, input) -- 1952
	if self.room.key == "prologue" then -- 1952
		self:stepPrologue(dt, input) -- 1954
	elseif self.room.key == "street" then -- 1954
		self:stepStreet(dt, input) -- 1956
	elseif self.room.key == "gate" then -- 1956
		self:stepGate(dt, input) -- 1958
	elseif self.room.key == "gatepath" then -- 1958
		self:stepGatePath() -- 1960
	elseif self.room.key == "tower" then -- 1960
		self:stepTower(dt, input) -- 1962
	elseif self.room.key == "museum" then -- 1962
		self:stepMuseum(dt, input) -- 1964
	end -- 1964
end -- 1952
function Play.prototype.canPersistProgress(self) -- 1970
	return not self.isCampaign and self.run.source == "official" -- 1971
end -- 1970
function Play.prototype.wellWindow(self) -- 1975
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1976
end -- 1975
function Play.prototype.nearWell(self) -- 1981
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1982
end -- 1981
function Play.prototype.pickWell(self) -- 1990
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1990
		return false -- 1992
	end -- 1992
	self.phase = "prologue-well" -- 1994
	self.phaseTick = 0 -- 1995
	self.wellOpen = false -- 1996
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1997
	self:log("旧井拾取") -- 1998
	return true -- 1999
end -- 1990
function Play.prototype.stepPrologue(self, dt, input) -- 2002
	local child = self.partner -- 2003
	if self.museumReturn then -- 2003
		self.museumReturn = false -- 2006
		self.phase = "prologue-wait" -- 2007
		self.phaseTick = 0 -- 2008
		self.player.x = self.ox + 260 -- 2009
		self.player.y = 0 -- 2010
		self.player.depth = 0 -- 2011
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2012
	end -- 2012
	if self.phase == "prologue-wake" then -- 2012
		self.introTick = self.introTick + 1 -- 2016
		if self.introTick == 60 then -- 2016
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2018
		end -- 2018
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2018
			self.phase = "prologue-shadow" -- 2021
			self.introTick = 0 -- 2022
			self:flashSet("门缝里两道影子", 1.2) -- 2023
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2024
		end -- 2024
		return -- 2026
	end -- 2026
	if self.phase == "prologue-shadow" then -- 2026
		self.introTick = self.introTick + 1 -- 2029
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2029
			self.phase = "prologue-escape" -- 2032
			self.introTick = 0 -- 2033
			self.escapeRemaining = self.escapeDuration -- 2034
			self.escapeRetryCount = 0 -- 2035
			self:swapToChild(100) -- 2036
			self:flashSet( -- 2037
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2037
				1.6 -- 2037
			) -- 2037
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2038
		end -- 2038
		return -- 2042
	end -- 2042
	if self.phase == "prologue-escape" then -- 2042
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2045
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2045
			self.phase = "prologue-hide" -- 2048
			self.introTick = 0 -- 2049
			self.player.vx = 0 -- 2050
			self.player.crouch = true -- 2051
			self.player.h = CHILD_CROUCH_H -- 2052
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2053
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2054
			return -- 2058
		end -- 2058
		if self.escapeRemaining <= 0 then -- 2058
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2062
			self.player.x = self.ox + 100 -- 2063
			self.player.y = 0 -- 2064
			self.player.depth = 0 -- 2065
			self.player.vx = 0 -- 2066
			self.player.vy = 0 -- 2067
			self.escapeRemaining = self.escapeDuration -- 2068
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2069
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2070
			return -- 2071
		end -- 2071
		return -- 2073
	end -- 2073
	if self.phase == "prologue-hide" then -- 2073
		self.introTick = self.introTick + 1 -- 2076
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2076
			self.phase = "prologue-wait" -- 2079
			self.phaseTick = 0 -- 2080
			self.introTick = 0 -- 2081
			self:swapToSoldier(260, 300) -- 2082
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2083
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2084
		end -- 2084
		return -- 2086
	end -- 2086
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2089
	if self.phase == "prologue-wait" then -- 2089
		child.crouch = true -- 2091
		child.h = CHILD_CROUCH_H -- 2092
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2092
			self:pickWell() -- 2094
			return -- 2095
		end -- 2095
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2095
			if self:canPersistProgress() then -- 2095
				self.archive.museumPhase = "well_reflect" -- 2101
				self.archiveDirty = true -- 2102
			end -- 2102
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2104
			return -- 2105
		end -- 2105
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2107
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2109
		if near and input.interact.pressed then -- 2109
			self.phase = "prologue-give" -- 2111
			self.phaseTick = 0 -- 2112
			self:flashSet("递出针套", 1) -- 2113
		end -- 2113
		return -- 2115
	end -- 2115
	if self.phase == "prologue-well" then -- 2115
		self.phaseTick = self.phaseTick + 1 -- 2119
		if self.phaseTick == 12 then -- 2119
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2121
		elseif self.phaseTick >= 30 then -- 2121
			self.phase = "prologue-wait" -- 2123
			self.phaseTick = 0 -- 2124
			self.wellTaken = true -- 2125
			self.wellOpen = false -- 2126
			self.run.archive.artifactOwned = true -- 2127
			self.archiveDirty = true -- 2128
			self:emit("artifactFound", { -- 2129
				x = self.ox + self.wellX, -- 2130
				y = 0, -- 2130
				room = "prologue", -- 2130
				once = true, -- 2130
				source = self.run.source -- 2131
			}) -- 2131
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2133
			self:log("井底取到时间穿梭器") -- 2134
		end -- 2134
		return -- 2136
	end -- 2136
	if self.phase == "prologue-give" then -- 2136
		self.phaseTick = self.phaseTick + 1 -- 2139
		if self.phaseTick == 12 then -- 2139
			self:flashSet("针套递过去", 0.7) -- 2141
		elseif self.phaseTick == 36 then -- 2141
			self:flashSet("纸条塞进针套", 0.9) -- 2143
		elseif self.phaseTick >= 60 then -- 2143
			self.phase = "prologue-follow" -- 2145
			self.phaseTick = 0 -- 2146
			child.crouch = false -- 2147
			child.h = CHILD_H -- 2148
			self:flashSet("她跟上了", 1.2) -- 2149
		end -- 2149
		return -- 2151
	end -- 2151
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2151
		self:requestRoom("street", "序章跟到门口") -- 2155
		self:flashSet("进街道", 1.2) -- 2156
	end -- 2156
end -- 2002
function Play.prototype.stepStreet(self, dt, input) -- 2161
	local p = self.player -- 2162
	local c = self.partner -- 2163
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2163
		self:requestRoom("checkpoint", "两人都到街尾") -- 2165
		self:flashSet("到检查站", 1.2) -- 2166
	end -- 2166
end -- 2161
function Play.prototype.stepGate(self, dt, input) -- 2171
	local ____temp_38 -- 2172
	if self.room.story == nil then -- 2172
		____temp_38 = nil -- 2172
	else -- 2172
		____temp_38 = self.room.story.gate -- 2172
	end -- 2172
	local g = ____temp_38 -- 2172
	if g == nil then -- 2172
		return -- 2174
	end -- 2174
	local p = self.player -- 2176
	if self.phase == "gate-idle" then -- 2176
		local a = self.partner -- 2179
		local gap = g.waitX - a.x -- 2180
		if math.abs(gap) > 3 then -- 2180
			a.facing = gap > 0 and 1 or -1 -- 2182
			a.vx = a.facing * CHILD_SPEED -- 2183
			local beforeX = a.x -- 2184
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2185
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2185
				a.vy = CHILD_JUMP -- 2187
				a.onGround = false -- 2188
			end -- 2188
			self:fallY(a, dt) -- 2190
		else -- 2190
			a.vx = 0 -- 2192
			a.x = g.waitX -- 2193
		end -- 2193
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2196
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2197
		if self.gateNeedConfirm then -- 2197
			if not input.interact.held then -- 2197
				self.gateRestartArmed = true -- 2202
			end -- 2202
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2202
				self.gateNeedConfirm = false -- 2205
				self.gateRestartArmed = true -- 2206
				self.phase = "gate-hold" -- 2207
				self.gateTick = 0 -- 2208
				self.gateSpawned = 0 -- 2209
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2210
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2211
			end -- 2211
			return -- 2213
		end -- 2213
		if atWinch and atWait then -- 2213
			self.phase = "gate-hold" -- 2216
			self.gateTick = 0 -- 2217
			self.gateSpawned = 0 -- 2218
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2219
		end -- 2219
		return -- 2221
	end -- 2221
	if self.phase == "gate-hold" then -- 2221
		self.gateTick = self.gateTick + 1 -- 2224
		local marks = {0, 540, 900, 1500} -- 2226
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2226
			local idx = self.gateSpawned -- 2228
			local ____self_enemies_39 = self.enemies -- 2228
			____self_enemies_39[#____self_enemies_39 + 1] = { -- 2229
				x = self.ox + 620 + idx * 62, -- 2230
				y = 0, -- 2230
				w = 26, -- 2230
				h = 84, -- 2230
				alive = true, -- 2231
				hitT = 0, -- 2231
				warnT = 0, -- 2231
				fireCd = 90 + idx * 45 -- 2231
			} -- 2231
			self.gateSpawned = self.gateSpawned + 1 -- 2233
			self:flashSet( -- 2234
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2234
				0.9 -- 2234
			) -- 2234
		end -- 2234
		if self.gateTick == 900 then -- 2234
			self:flashSet("灯灭了", 1) -- 2237
		elseif self.gateTick == 2100 then -- 2237
			self:flashSet("门底压下来了", 1) -- 2239
		end -- 2239
		if self.gateTick >= g.holdTicks then -- 2239
			self:captureGateBlood() -- 2244
			self.phase = "gate-send" -- 2245
			self.phaseTick = 0 -- 2246
			self.enemies = {} -- 2248
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2249
		end -- 2249
		return -- 2251
	end -- 2251
	if self.phase == "gate-send" then -- 2251
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2254
		if near and input.interact.pressed then -- 2254
			self:commitRoute() -- 2257
			self:swapToChild(g.doorX + 30) -- 2258
			self.phase = "gate-count" -- 2259
			self.countTick = 0 -- 2260
			self.countArmed = false -- 2262
			self.countPrevMove = input.moveX -- 2263
			self:flashSet("门开了 · 送她出去", 1.8) -- 2264
		end -- 2264
		return -- 2266
	end -- 2266
	if self.phase == "gate-count" then -- 2266
		self.countTick = self.countTick + 1 -- 2269
		if self.countTick == 360 then -- 2269
			self:flashSet("门关上", 0.9) -- 2271
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2271
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2273
			if self.storyRoute == "soldier" then -- 2273
				self.phase = "gate-wait" -- 2279
				self.phaseTick = 0 -- 2280
				self.knocks = 1 -- 2281
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2282
				self.handArmed = not input.interact.held -- 2284
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2285
			else -- 2285
				self:flashSet("数到二十", 2.2) -- 2287
			end -- 2287
		end -- 2287
		local prevMove = self.countPrevMove -- 2292
		self.countPrevMove = input.moveX -- 2293
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2293
			if prevMove <= 0 and input.moveX > 0 then -- 2293
				self.countArmed = true -- 2296
			end -- 2296
			if self.countArmed and input.moveX > 0 then -- 2296
				self.phase = "gate-walk" -- 2299
				self.phaseTick = 0 -- 2300
				self:flashSet("她迈出第一步", 1.4) -- 2301
				self:emit("storyExit", { -- 2302
					route = "child", -- 2302
					via = "walk", -- 2302
					countTick = self.countTick, -- 2302
					hp = self.hp, -- 2302
					maxHp = self.maxHp -- 2302
				}) -- 2302
			end -- 2302
		end -- 2302
		return -- 2305
	end -- 2305
	if self.phase == "gate-wait" then -- 2305
		self.phaseTick = self.phaseTick + 1 -- 2309
		if self.phaseTick == 12 then -- 2309
			self.knocks = 2 -- 2311
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2312
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2313
		end -- 2313
		if not input.interact.held then -- 2313
			if self.handTicks > 0 then -- 2313
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2317
			end -- 2317
			self.handTicks = 0 -- 2319
			self.handArmed = true -- 2320
			return -- 2321
		end -- 2321
		if self.handArmed then -- 2321
			self.handTicks = self.handTicks + 1 -- 2324
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2324
				self.phase = "gate-hand" -- 2326
				self.phaseTick = 0 -- 2327
				self.handDone = true -- 2328
				self.tied = true -- 2329
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2330
				if not self.lineSaid then -- 2330
					self.lineSaid = true -- 2332
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2333
				end -- 2333
				self:flashSet("我们走吧。", 3) -- 2335
			end -- 2335
		end -- 2335
		return -- 2338
	end -- 2338
	if self.phase == "gate-hand" then -- 2338
		self.phaseTick = self.phaseTick + 1 -- 2342
		if self.phaseTick == 30 then -- 2342
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2344
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2344
			self:emit("storyExit", { -- 2346
				route = "soldier", -- 2346
				via = "hand", -- 2346
				handTicks = self.handTicks, -- 2346
				hp = self.hp, -- 2346
				maxHp = self.maxHp -- 2346
			}) -- 2346
			self:requestRoom("gatepath", "牵手同行") -- 2347
		end -- 2347
		return -- 2349
	end -- 2349
	if self.phase == "gate-walk" then -- 2349
		if self.player.x >= g.exitX then -- 2349
			self:requestRoom("outside", "走出城门") -- 2354
			self:flashSet("出城门 · 城外", 1.4) -- 2355
		end -- 2355
	end -- 2355
end -- 2171
function Play.prototype.captureGateBlood(self) -- 2364
	self.hpAtGate = self.hp -- 2365
	self.maxHpAtGate = self.maxHp -- 2366
end -- 2364
function Play.prototype.commitRoute(self) -- 2373
	if self.storySettled then -- 2373
		return -- 2375
	end -- 2375
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2377
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2378
	self.hpAtGate = hp -- 2379
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2380
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2381
	self.storySettled = true -- 2382
	self:emit("storyRouteLocked", { -- 2383
		route = self.storyRoute, -- 2384
		hp = self.hp, -- 2384
		maxHp = self.maxHp, -- 2384
		hpAtGate = self.hpAtGate, -- 2385
		maxHpAtGate = self.maxHpAtGate -- 2385
	}) -- 2385
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2387
end -- 2373
function Play.prototype.syncStory(self) -- 2391
	if self.isCampaign and self.run.trial ~= nil then -- 2391
		return -- 2393
	end -- 2393
	local s = self.run.story -- 2395
	if s == nil then -- 2395
		return -- 2397
	end -- 2397
	s.hp = self.hp -- 2399
	s.maxHp = self.maxHp -- 2400
	s.route = self.storyRoute -- 2401
	s.settled = self.storySettled -- 2402
	s.hpAtGate = self.hpAtGate -- 2403
	s.maxHpAtGate = self.maxHpAtGate -- 2404
	s.handDone = self.handDone -- 2405
	s.lineSaid = self.lineSaid -- 2406
	s.tied = self.tied -- 2407
	s.carry = self.carryOn -- 2408
	s.museumReturn = self.museumReturn -- 2409
	s.escortDone = self.escortDone -- 2410
	s.craftedWeapon = self.run.story.craftedWeapon -- 2411
	s.ending = self.run.story.ending -- 2412
	if self.room.key == "gate" then -- 2412
		s.phase = self.phase -- 2414
		s.countTick = self.countTick -- 2415
		s.phaseTick = self.phaseTick -- 2416
		s.handTicks = self.handTicks -- 2417
	end -- 2417
	if self.room.key == "prologue" then -- 2417
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2417
			s.phase = self.phase -- 2422
			s.phaseTick = self.phaseTick -- 2423
		end -- 2423
	end -- 2423
	if self.room.key == "tower" then -- 2423
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2423
			s.phase = self.phase -- 2429
			s.phaseTick = self.phaseTick -- 2430
		end -- 2430
	end -- 2430
end -- 2391
function Play.prototype.stepGatePath(self) -- 2436
	local ____temp_40 -- 2437
	if self.room.story == nil then -- 2437
		____temp_40 = nil -- 2437
	else -- 2437
		____temp_40 = self.room.story.gatepath -- 2437
	end -- 2437
	local gp = ____temp_40 -- 2437
	if self.phase == "gatepath-start" then -- 2437
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2437
			self.carryOn = true -- 2440
			self.phase = "gatepath-carry" -- 2441
			self.phaseTick = 0 -- 2442
			self.pathDone = true -- 2443
			self.escortDone = false -- 2444
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2445
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2446
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2447
		end -- 2447
		return -- 2449
	end -- 2449
	if self.phase == "gatepath-carry" then -- 2449
		self.phaseTick = self.phaseTick + 1 -- 2452
		if self.phaseTick == 20 then -- 2452
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2454
		end -- 2454
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2454
			self:requestRoom(gp.next, "背负进首战") -- 2457
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2458
		end -- 2458
	end -- 2458
end -- 2436
function Play.prototype.carryPose(self) -- 2467
	local p = self.player -- 2468
	local a = self.partner -- 2469
	a.alive = true -- 2470
	a.x = p.x - p.facing * 12 -- 2471
	a.y = p.y + 26 -- 2472
	a.depth = p.depth -- 2473
	a.vx = p.vx -- 2474
	a.vy = 0 -- 2475
	a.onGround = true -- 2476
	a.crouch = false -- 2477
	a.h = CHILD_CROUCH_H -- 2478
	a.facing = p.facing -- 2479
end -- 2467
function Play.prototype.stepMuseum(self, dt, input) -- 2487
	self.partner.alive = false -- 2488
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2489
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2492
	if self.phase == "museum-cabinet" then -- 2492
		if atCase and input.interact.pressed then -- 2492
			self.phase = "museum-hall" -- 2495
			self.phaseTick = 0 -- 2496
			if self:canPersistProgress() then -- 2496
				self.archive.museumPhase = "hall_walk" -- 2498
				self.archiveDirty = true -- 2499
			end -- 2499
			self:emit( -- 2501
				"museumStep", -- 2501
				{ -- 2501
					step = "cabinet", -- 2501
					x = self.ox + mu.cabinetX, -- 2501
					persisted = self:canPersistProgress() -- 2501
				} -- 2501
			) -- 2501
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2502
		end -- 2502
		return -- 2504
	end -- 2504
	if self.phase == "museum-hall" then -- 2504
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2504
			self.phase = "museum-lamp" -- 2508
			self.phaseTick = 0 -- 2509
			if self:canPersistProgress() then -- 2509
				self.archive.museumPhase = "lamp_turn" -- 2511
				self.archiveDirty = true -- 2512
			end -- 2512
			self:emit( -- 2514
				"museumStep", -- 2514
				{ -- 2514
					step = "hall", -- 2514
					x = self.ox + mu.hallX, -- 2514
					persisted = self:canPersistProgress() -- 2514
				} -- 2514
			) -- 2514
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2515
		end -- 2515
		return -- 2517
	end -- 2517
	if self.phase == "museum-lamp" then -- 2517
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2517
			self.phase = "museum-return" -- 2521
			self.phaseTick = 0 -- 2522
			if self:canPersistProgress() then -- 2522
				self.archive.museumPhase = "return_cabinet" -- 2524
				self.archiveDirty = true -- 2525
			end -- 2525
			self:emit( -- 2527
				"museumStep", -- 2527
				{ -- 2527
					step = "lamp", -- 2527
					x = self.ox + mu.lampX, -- 2527
					persisted = self:canPersistProgress() -- 2527
				} -- 2527
			) -- 2527
			self:flashSet("灯 · 转向西窗", 1.8) -- 2528
		end -- 2528
		return -- 2530
	end -- 2530
	if self.phase == "museum-return" then -- 2530
		if atCase and input.interact.pressed then -- 2530
			self.phase = "museum-knock" -- 2534
			self.phaseTick = 0 -- 2535
			self:emit( -- 2536
				"museumStep", -- 2536
				{ -- 2536
					step = "knock", -- 2536
					count = 1, -- 2536
					x = self.ox + mu.cabinetX, -- 2536
					persisted = self:canPersistProgress() -- 2536
				} -- 2536
			) -- 2536
			self:flashSet("回柜边 · 第一下", 0.8) -- 2537
		end -- 2537
		return -- 2539
	end -- 2539
	if self.phase == "museum-knock" then -- 2539
		self.phaseTick = self.phaseTick + 1 -- 2542
		if self.phaseTick == 8 then -- 2542
			self:emit( -- 2544
				"museumStep", -- 2544
				{ -- 2544
					step = "knock", -- 2544
					count = 2, -- 2544
					x = self.ox + mu.cabinetX, -- 2544
					persisted = self:canPersistProgress() -- 2544
				} -- 2544
			) -- 2544
			self:flashSet("回柜边 · 第二下", 0.8) -- 2545
		elseif self.phaseTick >= 36 then -- 2545
			self.phase = "museum-done" -- 2547
			self.phaseTick = 0 -- 2548
			if self:canPersistProgress() then -- 2548
				self.archive.museumSeen = true -- 2550
				self.archive.museumPhase = "done" -- 2551
				self.archiveDirty = true -- 2552
			end -- 2552
			self:emit( -- 2554
				"museumDone", -- 2554
				{ -- 2554
					steps = 4, -- 2554
					museumSeen = self.archive.museumSeen, -- 2554
					persisted = self:canPersistProgress() -- 2554
				} -- 2554
			) -- 2554
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2555
			self:log("博物馆 · 回柜边") -- 2556
		end -- 2556
		return -- 2558
	end -- 2558
	if input.interact.pressed then -- 2558
		self.museumReturn = true -- 2561
		self:requestRoom("prologue", "回柜边") -- 2562
	end -- 2562
end -- 2487
function Play.prototype.openTowerDoor(self) -- 2566
	self.towerDoorOpen = true -- 2567
	do -- 2567
		local i = 0 -- 2568
		while i < #self.boxes do -- 2568
			if self.boxes[i + 1].id == "tower_door" then -- 2568
				self.boxes[i + 1].hidden = true -- 2570
			end -- 2570
			i = i + 1 -- 2568
		end -- 2568
	end -- 2568
	self.run.story.segments.tower_door = true -- 2573
end -- 2566
function Play.prototype.stepTower(self, dt, input) -- 2576
	local ____temp_41 -- 2577
	if self.room.story == nil then -- 2577
		____temp_41 = nil -- 2577
	else -- 2577
		____temp_41 = self.room.story.tower -- 2577
	end -- 2577
	local t = ____temp_41 -- 2577
	if t == nil then -- 2577
		return -- 2579
	end -- 2579
	if self.phase == "tower-wait" then -- 2579
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2582
		if near and input.interact.pressed then -- 2582
			self.phase = "tower-knock" -- 2584
			self.phaseTick = 0 -- 2585
			self.knocks = 1 -- 2586
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2587
			self:flashSet("叩两下 · 第一声", 0.6) -- 2588
		end -- 2588
		return -- 2590
	end -- 2590
	if self.phase == "tower-knock" then -- 2590
		self.phaseTick = self.phaseTick + 1 -- 2593
		if self.phaseTick == 12 then -- 2593
			self.knocks = 2 -- 2595
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2596
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 2597
		elseif self.phaseTick >= t.knockTicks then -- 2597
			self:openTowerDoor() -- 2599
			self.phase = "tower-enter" -- 2600
			self.phaseTick = 0 -- 2601
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 2602
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 2603
		end -- 2603
		return -- 2605
	end -- 2605
	if self.phase == "tower-enter" then -- 2605
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 2605
			self.phase = "tower-desk" -- 2609
			self.phaseTick = 0 -- 2610
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 2611
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 2612
		end -- 2612
		return -- 2614
	end -- 2614
	if self.phase == "tower-desk" then -- 2614
		local deskX = self.ox + 605 -- 2617
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 2618
		if not near or not input.interact.held then -- 2618
			self.deskHold = 0 -- 2620
			return -- 2621
		end -- 2621
		self.deskHold = self.deskHold + 1 -- 2623
		if self.deskHold == 12 then -- 2623
			self:flashSet("针套 · 放在桌上", 1) -- 2625
		elseif self.deskHold == 24 then -- 2625
			self:flashSet("指南针 · 压住纸条", 1) -- 2627
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 2627
			self.towerHanded = true -- 2629
			self.deskHold = 0 -- 2630
			self.run.story.segments.tower_handover = true -- 2631
			self.phase = "tower-given" -- 2632
			self.phaseTick = 0 -- 2633
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 2634
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 2639
		end -- 2639
		return -- 2641
	end -- 2641
	if self.phase == "tower-given" then -- 2641
		local soldier = self.storyRoute == "soldier" -- 2646
		self.phaseTick = self.phaseTick + 1 -- 2647
		if self.phaseTick == 60 then -- 2647
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2649
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2650
		elseif self.phaseTick == 120 then -- 2650
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2652
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2652
			self.phase = "tower-end" -- 2654
			self.phaseTick = 0 -- 2655
			if not self.run.finished then -- 2655
				self.run.finished = true -- 2657
				local ending = soldier and "reunion" or "lamp" -- 2658
				self.run.story.ending = ending -- 2659
				local ____soldier_42 -- 2662
				if soldier then -- 2662
					____soldier_42 = self.run.story.segments.escort5 == true -- 2663
				else -- 2663
					____soldier_42 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2664
				end -- 2664
				local played = ____soldier_42 -- 2662
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2665
				if official then -- 2665
					if soldier then -- 2665
						self.run.archive.soldierCleared = true -- 2669
					else -- 2669
						self.run.archive.childCleared = true -- 2671
					end -- 2671
					self.archiveDirty = true -- 2673
				end -- 2673
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2675
				self:emit("endingReached", { -- 2676
					route = soldier and "soldier" or "child", -- 2677
					ending = ending, -- 2678
					official = official, -- 2679
					source = self.run.source, -- 2680
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2681
					childCleared = self.run.archive.childCleared, -- 2682
					soldierCleared = self.run.archive.soldierCleared, -- 2683
					artifactOwned = self.run.archive.artifactOwned, -- 2684
					equipped = self.equippedWeapon -- 2685
				}) -- 2685
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2687
			end -- 2687
		end -- 2687
		return -- 2690
	end -- 2690
	self.phaseTick = self.phaseTick + 1 -- 2692
	if input.interact.pressed or input.retry.pressed then -- 2692
		self.restartStory = true -- 2695
		self:requestRoom("prologue", "片尾再玩") -- 2696
		self:flashSet("回到序章", 1.4) -- 2697
	end -- 2697
end -- 2576
function Play.prototype.stepChase(self, dt, input) -- 2702
	if self.caughtT > 0 then -- 2702
		self.caughtT = self.caughtT - dt -- 2704
		if self.caughtT <= 0 then -- 2704
			self:recoverFromCaught() -- 2706
		end -- 2706
		return -- 2708
	end -- 2708
	if self.room.key == "village" then -- 2708
		self:stepScavChase() -- 2711
	elseif self.room.key == "forest" then -- 2711
		self:stepForestRoute() -- 2713
		self:stepDog(dt) -- 2714
		if self.player.x >= self.ox + 1450 then -- 2714
			self:requestRoom("tower", "到林缘北塔") -- 2717
			self:flashSet("林缘 · 北塔", 1.4) -- 2718
		end -- 2718
	end -- 2718
end -- 2702
function Play.prototype.stepScavChase(self) -- 2724
	local s = self.room.scavenger -- 2725
	if s == nil then -- 2725
		return -- 2727
	end -- 2727
	local p = self.player -- 2729
	if self.passed and p.x > self.ox + 440 then -- 2729
		if self.scavChase then -- 2729
			self.scavChase = false -- 2733
			self.scavState = "back" -- 2734
			self.scavT = 0 -- 2735
		end -- 2735
		return -- 2737
	end -- 2737
	local dx = p.x - self.scavX -- 2739
	local dist = math.abs(dx) -- 2740
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2741
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2742
	if not self.scavChase then -- 2742
		if visible then -- 2742
			self.scavSee = self.scavSee + 1 -- 2745
			if self.scavSee >= 24 then -- 2745
				self.scavChase = true -- 2747
				self.scavState = "chase" -- 2748
				self.scavTargetX = p.x -- 2749
				self:flashSet("他看见你了", 1.2) -- 2750
			end -- 2750
		else -- 2750
			self.scavSee = 0 -- 2753
		end -- 2753
		return -- 2755
	end -- 2755
	local dir = p.x > self.scavX and 1 or -1 -- 2758
	self.scavX = self.scavX + dir * 96 / 60 -- 2759
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2759
		self:caught() -- 2761
		return -- 2762
	end -- 2762
	if hidden then -- 2762
		self.scavSee = 0 -- 2766
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2767
		self.scavT = self.scavT - 1 -- 2768
		if self.scavT <= 0 then -- 2768
			self.scavChase = false -- 2770
			self.scavState = "patrol" -- 2771
			self:flashSet("他失去了目标", 1) -- 2772
		end -- 2772
	end -- 2772
end -- 2724
function Play.prototype.stepDog(self, dt) -- 2778
	local ____temp_43 -- 2779
	if self.room.story == nil then -- 2779
		____temp_43 = nil -- 2779
	else -- 2779
		____temp_43 = self.room.story.dog -- 2779
	end -- 2779
	local dog = ____temp_43 -- 2779
	if dog == nil then -- 2779
		return -- 2781
	end -- 2781
	local p = self.player -- 2783
	local dist = math.abs(p.x - self.dogX) -- 2784
	if self.dogState == "patrol" then -- 2784
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2786
		if self.dogX < dog.x0 then -- 2786
			self.dogX = dog.x0 -- 2788
			self.dogDir = 1 -- 2789
		elseif self.dogX > dog.x1 then -- 2789
			self.dogX = dog.x1 -- 2791
			self.dogDir = -1 -- 2792
		end -- 2792
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2794
		if not p.crouch and moving and dist < dog.range then -- 2794
			self.dogState = "ear" -- 2796
			self.dogT = 18 -- 2797
			self.dogTargetX = p.x -- 2798
			self:flashSet("狗转耳朵", 0.8) -- 2799
		end -- 2799
		return -- 2801
	end -- 2801
	if self.dogState == "ear" then -- 2801
		self.dogT = self.dogT - 1 -- 2804
		if self.dogT <= 0 then -- 2804
			self.dogState = "chase" -- 2806
			self.dogTargetX = p.x -- 2807
			self:flashSet("狗追来了", 1.4) -- 2808
		end -- 2808
		return -- 2810
	end -- 2810
	if self.dogState == "chase" then -- 2810
		local dir = p.x > self.dogX and 1 or -1 -- 2813
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2814
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2814
			self:caught() -- 2816
			self.dogState = "sniff" -- 2817
			self.dogT = 60 -- 2818
		elseif dist > dog.range * 1.5 or p.crouch then -- 2818
			self.dogState = "sniff" -- 2820
			self.dogT = 60 -- 2821
			self:flashSet("狗停下了", 0.9) -- 2822
		end -- 2822
		return -- 2824
	end -- 2824
	if self.dogState == "sniff" then -- 2824
		self.dogT = self.dogT - 1 -- 2827
		if self.dogT <= 0 then -- 2827
			self.dogState = "back" -- 2829
		end -- 2829
		return -- 2831
	end -- 2831
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2834
	self.dogX = self.dogX + dir * dog.speed * dt -- 2835
	if math.abs(self.dogX - dog.x0) < 2 then -- 2835
		self.dogX = dog.x0 -- 2837
		self.dogState = "patrol" -- 2838
	end -- 2838
end -- 2778
function Play.prototype.stepForestRoute(self) -- 2843
	local p = self.player -- 2844
	local ox = self.ox -- 2845
	if self.forestPath == "" then -- 2845
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 2845
			self.forestPath = "burrow" -- 2848
			self.run.story.segments.forest_burrow = true -- 2849
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 2850
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 2851
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 2851
			self.forestPath = "ditch" -- 2853
			self.run.story.segments.forest_ditch = true -- 2854
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 2855
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 2856
		end -- 2856
	end -- 2856
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 2856
		self.waterSeen = true -- 2860
		self.run.story.segments.water_lantern = true -- 2861
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 2862
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 2863
	end -- 2863
end -- 2843
function Play.prototype.caught(self) -- 2867
	self.caughtT = 1 -- 2868
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2869
end -- 2867
function Play.prototype.recoverFromCaught(self) -- 2873
	local p = self.player -- 2874
	p.x = self.ox + 140 -- 2875
	p.y = 0 -- 2876
	p.vy = 0 -- 2877
	p.vx = 0 -- 2878
	p.onGround = true -- 2879
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2879
		self.scavX = self.room.scavenger.x0 -- 2881
		self.scavState = "patrol" -- 2882
		self.scavSee = 0 -- 2883
		self.scavChase = false -- 2884
		self.scavT = 0 -- 2885
	end -- 2885
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2885
		self.dogX = self.room.story.dog.x0 -- 2888
		self.dogState = "patrol" -- 2889
		self.dogT = 0 -- 2890
	end -- 2890
	self.cam.x = p.x -- 2892
	self.cam.y = p.y + CAM_LOOK_UP -- 2893
	self:flashSet("回到安全点", 1.2) -- 2894
end -- 2873
function Play.prototype.updateGate(self) -- 2898
	if self.room.key ~= "checkpoint" then -- 2898
		self.gateOpen = false -- 2900
		return -- 2901
	end -- 2901
	local function inZone(x) -- 2903
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2903
	end -- 2903
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2904
end -- 2898
function Play.prototype.addItem(self, kind) -- 2910
	local inv = self.run.inventory -- 2911
	if kind == "shield" then -- 2911
		if inv.shield >= TOOL_CAP then -- 2911
			return false -- 2914
		end -- 2914
		inv.shield = inv.shield + 1 -- 2916
		return true -- 2917
	end -- 2917
	if kind == "wedge" then -- 2917
		if inv.wedge >= CONSUMABLE_CAP then -- 2917
			return false -- 2921
		end -- 2921
		inv.wedge = inv.wedge + 1 -- 2923
		return true -- 2924
	end -- 2924
	if kind == "ammo" then -- 2924
		if inv.ammo >= CONSUMABLE_CAP then -- 2924
			return false -- 2928
		end -- 2928
		inv.ammo = inv.ammo + 1 -- 2930
		return true -- 2931
	end -- 2931
	if kind == "scrap" then -- 2931
		inv.scrap = inv.scrap + 1 -- 2935
		return true -- 2936
	end -- 2936
	if kind == "wood" then -- 2936
		inv.wood = inv.wood + 1 -- 2939
		return true -- 2940
	end -- 2940
	if kind == "bell" then -- 2940
		inv.bell = inv.bell + 1 -- 2943
		return true -- 2944
	end -- 2944
	if kind == "pass" then -- 2944
		inv.pass = inv.pass + 1 -- 2947
		return true -- 2948
	end -- 2948
	if kind == "quickbelt" then -- 2948
		inv.quickbelt = inv.quickbelt + 1 -- 2951
		return true -- 2952
	end -- 2952
	return false -- 2954
end -- 2910
function Play.prototype.findBox(self, id) -- 2957
	local i = 0 -- 2958
	do -- 2958
		i = 0 -- 2959
		while i < #self.boxes do -- 2959
			if self.boxes[i + 1].id == id then -- 2959
				return self.boxes[i + 1] -- 2961
			end -- 2961
			i = i + 1 -- 2959
		end -- 2959
	end -- 2959
	return nil -- 2964
end -- 2957
function Play.prototype.findWedgeTarget(self) -- 2968
	local best = nil -- 2969
	local bestD = 0 -- 2970
	local i = 0 -- 2971
	do -- 2971
		i = 0 -- 2972
		while i < #self.boxes do -- 2972
			do -- 2972
				local b = self.boxes[i + 1] -- 2973
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2973
					goto __continue442 -- 2975
				end -- 2975
				if not self:nearBox(b, 26) then -- 2975
					goto __continue442 -- 2978
				end -- 2978
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2980
				if best == nil or d < bestD then -- 2980
					best = b -- 2982
					bestD = d -- 2983
				end -- 2983
			end -- 2983
			::__continue442:: -- 2983
			i = i + 1 -- 2972
		end -- 2972
	end -- 2972
	return best -- 2986
end -- 2968
function Play.prototype.stepCraft(self, input) -- 2994
	local inv = self.run.inventory -- 2995
	local ____opt_44 = self.run.trial -- 2995
	local required = CRAFT_TICKS - 6 * (____opt_44 and ____opt_44.ranks.craft or 0) -- 2996
	if self.craftT > 0 then -- 2996
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2996
			self.craftT = 0 -- 3000
			self:flashSet("制作中断", 0.8) -- 3001
			return true -- 3002
		end -- 3002
		self.craftT = self.craftT + 1 -- 3004
		if self.craftT >= required then -- 3004
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3004
				inv.scrap = inv.scrap - 1 -- 3007
				inv.wedge = inv.wedge + 1 -- 3008
				self:flashSet("制得木楔", 1.2) -- 3009
				self:log("制木楔") -- 3010
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3011
			end -- 3011
			self.craftT = 0 -- 3013
		end -- 3013
		return true -- 3015
	end -- 3015
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3015
		self.craftT = 1 -- 3018
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3019
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3020
		return true -- 3021
	end -- 3021
	return false -- 3023
end -- 2994
function Play.prototype.nearBox(self, b, reach) -- 3026
	local p = self.player -- 3027
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3028
end -- 3026
function Play.prototype.findInteract(self) -- 3034
	local p = self.player -- 3035
	local best = nil -- 3036
	local bestD = 1000000000 -- 3037
	local i = 0 -- 3038
	do -- 3038
		i = 0 -- 3039
		while i < #self.boxes do -- 3039
			do -- 3039
				local b = self.boxes[i + 1] -- 3040
				if b.interact == nil or b.broken == true then -- 3040
					goto __continue455 -- 3042
				end -- 3042
				if not self:nearBox(b, b.interact.reach or 27) then -- 3042
					goto __continue455 -- 3045
				end -- 3045
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3047
				if d < bestD then -- 3047
					bestD = d -- 3049
					best = b -- 3050
				end -- 3050
			end -- 3050
			::__continue455:: -- 3050
			i = i + 1 -- 3039
		end -- 3039
	end -- 3039
	return best -- 3053
end -- 3034
function Play.prototype.stepCampaign(self, dt, input) -- 3057
	local wr = self.room -- 3058
	local p = self.player -- 3059
	if self.reloadT > 0 then -- 3059
		self.reloadT = self.reloadT - 1 -- 3061
	end -- 3061
	if self.bracedShield ~= nil then -- 3061
		self.bracedShield.x = p.x + p.facing * 26 -- 3065
		self.bracedShield.y = p.y -- 3066
		local shBox = __TS__ArrayFind( -- 3067
			self.boxes, -- 3067
			function(____, b) return b.id == "braced_shield" end -- 3067
		) -- 3067
		if shBox ~= nil then -- 3067
			shBox.x0 = self.bracedShield.x - 15 -- 3069
			shBox.x1 = self.bracedShield.x + 15 -- 3070
			shBox.y0 = self.bracedShield.y -- 3071
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3072
		end -- 3072
	end -- 3072
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3072
		self.run.route = "drygoods" -- 3078
		self.run.joined = false -- 3079
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3080
		self:log("转布行线") -- 3081
	end -- 3081
	if wr.key == "escort3" then -- 3081
		local benchX = wr.minX + 560 -- 3085
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3086
		if nearBench and input.interact.pressed then -- 3086
			self:openCraftBench() -- 3088
		end -- 3088
	end -- 3088
	local i = 0 -- 3092
	do -- 3092
		i = 0 -- 3093
		while i < #self.pickups do -- 3093
			do -- 3093
				local pk = self.pickups[i + 1] -- 3094
				if self.run.taken[pk.id] == true then -- 3094
					goto __continue468 -- 3096
				end -- 3096
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3098
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3099
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3099
					if not self:addItem(pk.kind) then -- 3099
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3103
						self:log("满包拒绝 " .. pk.kind) -- 3104
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3105
						goto __continue468 -- 3106
					end -- 3106
					self.run.taken[pk.id] = true -- 3108
					self:flashSet("拾取 " .. pk.label, 1) -- 3109
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3110
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3111
				end -- 3111
			end -- 3111
			::__continue468:: -- 3111
			i = i + 1 -- 3093
		end -- 3093
	end -- 3093
	if not self:stepCraft(input) and input.interact.pressed then -- 3093
		self:campaignInteract() -- 3115
	end -- 3115
	self:stepCampaignCart(dt, input) -- 3117
	self:stepCampaignGoal() -- 3118
	self:campaignCheckpoint() -- 3119
end -- 3057
function Play.prototype.campaignCheckpoint(self) -- 3123
	local i = 0 -- 3124
	do -- 3124
		i = 0 -- 3125
		while i < #self.room.marks do -- 3125
			do -- 3125
				local m = self.room.marks[i + 1] -- 3126
				if m.kind ~= 0 then -- 3126
					goto __continue475 -- 3128
				end -- 3128
				local dx = self.player.x - m.x -- 3130
				local dy = self.player.y - m.y -- 3131
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3131
					self.checkpoint = m.x -- 3133
					self:captureCheckpoint(m.x) -- 3134
					self:flashSet("检查点", 1) -- 3135
				end -- 3135
			end -- 3135
			::__continue475:: -- 3135
			i = i + 1 -- 3125
		end -- 3125
	end -- 3125
end -- 3123
function Play.prototype.campaignInteract(self) -- 3141
	local b = self:findInteract() -- 3142
	if b ~= nil then -- 3142
		self:useInteract(b) -- 3144
		return -- 3145
	end -- 3145
	local inv = self.run.inventory -- 3147
	if inv.wedge > 0 then -- 3147
		local w = self:findWedgeTarget() -- 3149
		if w ~= nil then -- 3149
			if w.breakable ~= nil then -- 3149
				local ____w_breakable_46, ____hp_47 = w.breakable, "hp" -- 3149
				____w_breakable_46[____hp_47] = ____w_breakable_46[____hp_47] + (w.breakable.wedgeHp or 1) -- 3152
			end -- 3152
			inv.wedge = inv.wedge - 1 -- 3154
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3155
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3157
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3158
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3159
			return -- 3160
		end -- 3160
	end -- 3160
	if inv.ammo > 0 and self.reloadT > 0 then -- 3160
		self.reloadT = 0 -- 3165
		self:closeReloadPuzzle() -- 3166
		inv.ammo = inv.ammo - 1 -- 3167
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3168
		self:log("用备用弹包") -- 3169
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3170
		return -- 3171
	end -- 3171
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3171
		local p = self.player -- 3175
		self.bracedShield = { -- 3176
			x = p.x + p.facing * 26, -- 3176
			y = p.y, -- 3176
			w = 30, -- 3176
			h = 64, -- 3176
			hp = 1 -- 3176
		} -- 3176
		local ____self_boxes_48 = self.boxes -- 3176
		____self_boxes_48[#____self_boxes_48 + 1] = { -- 3177
			x0 = self.bracedShield.x - 15, -- 3178
			x1 = self.bracedShield.x + 15, -- 3178
			y0 = p.y, -- 3179
			y1 = p.y + 64, -- 3179
			depth = {min = -46, max = 46}, -- 3179
			label = "架起的残盾", -- 3179
			id = "braced_shield", -- 3179
			soft = true -- 3180
		} -- 3180
		inv.shield = inv.shield - 1 -- 3183
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3184
		self:log("架残盾") -- 3185
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3186
		return -- 3187
	end -- 3187
	if inv.pass > 0 and self.run.joined == false then -- 3187
		inv.pass = inv.pass - 1 -- 3190
		self.run.joined = true -- 3191
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3192
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3193
		return -- 3194
	end -- 3194
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3196
end -- 3141
function Play.prototype.useInteract(self, b) -- 3199
	local kind = b.interact == nil and "" or b.interact.kind -- 3200
	local wr = self.room -- 3201
	if kind == "open_board" then -- 3201
		b.broken = true -- 3203
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3204
		for ____, cover in ipairs(self.boxes) do -- 3205
			if cover.id == "s2_board_cover" then -- 3205
				cover.broken = false -- 3207
				cover.hidden = false -- 3208
			end -- 3208
		end -- 3208
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3211
		self.run.joined = true -- 3212
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3213
		self:log("放下窗板") -- 3214
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3215
		return -- 3216
	end -- 3216
	if kind == "lower_curtain" then -- 3216
		for ____, curtain in ipairs(self.boxes) do -- 3219
			if curtain.id == "c2_curtain" then -- 3219
				curtain.broken = false -- 3221
				curtain.hidden = false -- 3222
			end -- 3222
		end -- 3222
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3225
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3226
		self:log("放下木帘") -- 3227
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3228
		return -- 3229
	end -- 3229
	if kind == "raise_latch" then -- 3229
		if wr.key == "c2-granary" and not self.cartDocked then -- 3229
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3233
			return -- 3234
		end -- 3234
		b.broken = true -- 3236
		self.objectiveDone = true -- 3237
		if wr.key == "c1-yard" then -- 3237
			self.run.c1Latch = true -- 3240
			self.run.joined = true -- 3241
			for ____, door in ipairs(self.boxes) do -- 3242
				if door.id == "c1_door" then -- 3242
					door.broken = true -- 3244
				end -- 3244
			end -- 3244
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3247
		else -- 3247
			self.run.c2Latch = true -- 3249
			self.run.joined = true -- 3250
		end -- 3250
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3252
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3253
		self:log("抬闩") -- 3254
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3255
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3256
	end -- 3256
end -- 3199
function Play.prototype.stepCampaignCart(self, dt, input) -- 3261
	local wr = self.room -- 3262
	local c = wr.cart -- 3263
	if c.bodyW <= 0 then -- 3263
		return -- 3265
	end -- 3265
	local p = self.player -- 3267
	local handleX = self.cartAxle + c.handleOffset -- 3268
	if not self.gripping then -- 3268
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3268
			self.gripping = true -- 3272
			self:flashSet("握住车柄 · A/D 推", 1) -- 3273
		end -- 3273
		return -- 3275
	end -- 3275
	if input.interact.pressed then -- 3275
		self.gripping = false -- 3278
		self:flashSet("松手", 0.5) -- 3279
		return -- 3280
	end -- 3280
	if not self.cartDocked then -- 3280
		if input.moveX ~= 0 and not self:stuckCart() then -- 3280
			self.cartAxle = math.max( -- 3284
				c.startX, -- 3284
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3284
			) -- 3284
		end -- 3284
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3284
			self.cartExposed = true -- 3289
			local gun = nil -- 3290
			local gi = 0 -- 3291
			do -- 3291
				gi = 0 -- 3292
				while gi < #self.enemies do -- 3292
					local e = self.enemies[gi + 1] -- 3293
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3293
						gun = e -- 3295
						break -- 3296
					end -- 3296
					gi = gi + 1 -- 3292
				end -- 3292
			end -- 3292
			if gun ~= nil then -- 3292
				self:campaignEnemyFire(gun) -- 3300
			end -- 3300
		end -- 3300
		p.x = self.cartAxle + c.handleOffset -- 3303
		p.y = c.baseY -- 3304
		p.depth = c.depth or 0 -- 3305
		p.vx = 0 -- 3306
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3306
			self.cartAxle = c.endX -- 3308
			self.cartDocked = true -- 3309
			self.gripping = false -- 3310
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3311
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3312
			self:flashSet("车轮入窝", 1.2) -- 3313
			self:log("车轮入窝") -- 3314
		end -- 3314
	end -- 3314
end -- 3261
function Play.prototype.stuckCart(self) -- 3320
	local i = 0 -- 3321
	do -- 3321
		i = 0 -- 3322
		while i < #self.boxes do -- 3322
			do -- 3322
				local b = self.boxes[i + 1] -- 3323
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3323
					goto __continue517 -- 3325
				end -- 3325
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3327
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3327
					return true -- 3329
				end -- 3329
			end -- 3329
			::__continue517:: -- 3329
			i = i + 1 -- 3322
		end -- 3322
	end -- 3322
	return false -- 3332
end -- 3320
function Play.prototype.stepCampaignGoal(self) -- 3336
	local wr = self.room -- 3337
	local c = wr.campaign -- 3338
	if c == nil then -- 3338
		return -- 3340
	end -- 3340
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3340
		self.objectiveDone = true -- 3343
	end -- 3343
	if c.goal == "reach_exit" then -- 3343
		self.objectiveDone = true -- 3346
	end -- 3346
	if not self.objectiveDone then -- 3346
		return -- 3349
	end -- 3349
	local p = self.player -- 3351
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3352
	if p.x < c.exitX or not partnerOk then -- 3352
		return -- 3354
	end -- 3354
	if self.run.story.segments[wr.key] ~= true then -- 3354
		self.run.story.segments[wr.key] = true -- 3358
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3359
	end -- 3359
	if wr.key == "escort5" then -- 3359
		self.escortDone = true -- 3363
		self.run.story.escortDone = true -- 3364
	end -- 3364
	if c.next ~= nil and c.next ~= "" then -- 3364
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3367
		self:flashSet("过关 · " .. c.next, 1.2) -- 3368
	elseif not self.run.finished then -- 3368
		self.run.finished = true -- 3370
		self:flashSet( -- 3371
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3371
			2 -- 3371
		) -- 3371
		self:log("C2 灰盒完成") -- 3372
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3373
	end -- 3373
end -- 3336
function Play.prototype.stepCampaignPartner(self, dt) -- 3378
	local a = self.partner -- 3379
	local wr = self.room -- 3380
	local cp = wr.companion -- 3381
	if not a.alive then -- 3381
		return -- 3383
	end -- 3383
	local p = self.player -- 3385
	if self.craftBench.active then -- 3385
		a.vx = 0 -- 3388
		return -- 3389
	end -- 3389
	local wait = false -- 3391
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3392
	local targetDepth = p.depth -- 3393
	if self.run.joined == false then -- 3393
		wait = true -- 3395
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3396
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3397
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3397
		wait = true -- 3399
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3400
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3401
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3401
		wait = true -- 3403
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3404
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3405
	end -- 3405
	if self.partnerStuck > 0.3 then -- 3405
		a.x = a.x + a.facing * 44 -- 3409
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3410
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3411
		self.partnerLaneHold = 1.1 -- 3412
		self.partnerStuck = 0 -- 3413
	end -- 3413
	if self.partnerLaneHold > 0 then -- 3413
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3416
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3417
	end -- 3417
	local dx = targetX - a.x -- 3419
	if not wait and math.abs(dx) > 74 then -- 3419
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3421
		local before = a.x -- 3422
		a.vx = dx > 0 and speed or -speed -- 3423
		a.facing = dx > 0 and 1 or -1 -- 3424
		self:slideX(a, a.vx * dt) -- 3425
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3425
			a.vy = CHILD_JUMP -- 3428
			a.onGround = false -- 3429
		end -- 3429
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3431
	else -- 3431
		a.vx = 0 -- 3433
		self.partnerStuck = 0 -- 3434
	end -- 3434
	local dz = targetDepth - a.depth -- 3436
	if math.abs(dz) > 6 then -- 3436
		local step = math.max( -- 3438
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3438
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3438
		) -- 3438
		a.depth = a.depth + step -- 3439
	end -- 3439
	a.depthSpeed = 0 -- 3441
	a.h = CHILD_H -- 3442
	a.crouch = false -- 3443
	self:fallY(a, dt) -- 3444
end -- 3378
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3448
	local p = self.player -- 3449
	local i = 0 -- 3450
	do -- 3450
		i = 0 -- 3451
		while i < #self.enemies do -- 3451
			do -- 3451
				local ____opt_49 = self.run.trial -- 3451
				if ____opt_49 and ____opt_49.lost then -- 3451
					return -- 3452
				end -- 3452
				local e = self.enemies[i + 1] -- 3453
				if not e.alive then -- 3453
					goto __continue544 -- 3455
				end -- 3455
				if e.hitT > 0 then -- 3455
					e.hitT = e.hitT - dt -- 3458
				end -- 3458
				if e.kind == "target" then -- 3458
					if not e.alive and e.hitT <= 0 then -- 3458
						e.alive = true -- 3463
					end -- 3463
					goto __continue544 -- 3465
				end -- 3465
				if e.kind == "breaker" then -- 3465
					self:stepBreaker(e, dt) -- 3468
					goto __continue544 -- 3469
				end -- 3469
				if e.kind == "shield" then -- 3469
					self:stepShield(e, dt, input) -- 3472
					goto __continue544 -- 3473
				end -- 3473
				local dx = e.x - p.x -- 3476
				if not e.awake then -- 3476
					if math.abs(dx) > 520 then -- 3476
						goto __continue544 -- 3479
					end -- 3479
					e.awake = true -- 3481
					e.fireCd = 48 -- 3482
					goto __continue544 -- 3483
				end -- 3483
				if math.abs(dx) > ENEMY_RANGE then -- 3483
					goto __continue544 -- 3486
				end -- 3486
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3486
					goto __continue544 -- 3491
				end -- 3491
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3491
					goto __continue544 -- 3494
				end -- 3494
				if self:blockedShot(e, p) then -- 3494
					if e.warnT > 0 then -- 3494
						e.warnT = 0 -- 3500
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3501
					end -- 3501
					goto __continue544 -- 3503
				end -- 3503
				if e.warnT > 0 then -- 3503
					e.warnT = e.warnT - 1 -- 3506
					if e.warnT <= 0 then -- 3506
						self:campaignEnemyFire(e) -- 3508
					end -- 3508
				elseif e.fireCd > 0 then -- 3508
					e.fireCd = e.fireCd - 1 -- 3511
					if e.fireCd <= 0 then -- 3511
						e.warnT = WARN_TICKS -- 3513
					end -- 3513
				else -- 3513
					e.fireCd = 40 -- 3516
				end -- 3516
			end -- 3516
			::__continue544:: -- 3516
			i = i + 1 -- 3451
		end -- 3451
	end -- 3451
end -- 3448
function Play.prototype.blockedShot(self, e, p) -- 3522
	local eDepth = e.depth or 0 -- 3523
	local ex = e.x -- 3524
	local ey = e.y + e.h * 0.62 -- 3526
	local px = p.x -- 3527
	local py = p.y + p.h * 0.55 -- 3528
	local dx = px - ex -- 3529
	local dyScreen = py + p.depth - (ey + eDepth) -- 3530
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3531
	if len < 0.01 then -- 3531
		return false -- 3533
	end -- 3533
	local ray = { -- 3537
		x = ex, -- 3538
		y = ey, -- 3538
		dx = dx / len, -- 3539
		dy = (py - ey) / len, -- 3539
		depth = eDepth, -- 3540
		dDepth = (p.depth - eDepth) / len -- 3540
	} -- 3540
	local best = -1 -- 3542
	local j = 0 -- 3543
	do -- 3543
		j = 0 -- 3544
		while j < #self.boxes do -- 3544
			do -- 3544
				local b = self.boxes[j + 1] -- 3545
				if b.broken == true or b.passable == true or b.hidden == true then -- 3545
					goto __continue567 -- 3547
				end -- 3547
				if b.id == "braced_shield" then -- 3547
					goto __continue567 -- 3552
				end -- 3552
				local t = hitBox(ray, b) -- 3554
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3554
					best = t -- 3558
				end -- 3558
			end -- 3558
			::__continue567:: -- 3558
			j = j + 1 -- 3544
		end -- 3544
	end -- 3544
	return best >= 0 -- 3561
end -- 3522
function Play.prototype.campaignEnemyFire(self, e) -- 3564
	local p = self.player -- 3565
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3566
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3566
		local ____self_bracedShield_51, ____hp_52 = self.bracedShield, "hp" -- 3566
		____self_bracedShield_51[____hp_52] = ____self_bracedShield_51[____hp_52] - 1 -- 3568
		self.boxes = __TS__ArrayFilter( -- 3569
			self.boxes, -- 3569
			function(____, b) return b.id ~= "braced_shield" end -- 3569
		) -- 3569
		self.bracedShield = nil -- 3570
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3571
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3572
		return -- 3573
	end -- 3573
	if self:blockedShot(e, p) then -- 3573
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3576
		return -- 3577
	end -- 3577
	local cover = self:blockedByCover(e, p) -- 3579
	if cover ~= nil and self.coverHug then -- 3579
		self.coveredFlash = 0.5 -- 3581
		self:flashSet("掩体挡下", 0.6) -- 3582
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3583
		return -- 3588
	end -- 3588
	if self.invulnT > 0 then -- 3588
		return -- 3591
	end -- 3591
	local ____opt_53 = self.run.trial -- 3591
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_53 and ____opt_53.ranks.guard or 0) -- 3593
	self.craftT = 0 -- 3594
	self.hp = self.hp - 1 -- 3595
	self:emit("actorHit", { -- 3596
		target = "player", -- 3596
		amount = 1, -- 3596
		hp = self.hp, -- 3596
		maxHp = self.maxHp, -- 3596
		enemyX = e.x -- 3596
	}) -- 3596
	self:flashSet( -- 3597
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3597
		0.8 -- 3597
	) -- 3597
	if self.hp <= 0 then -- 3597
		self:campaignFailed() -- 3599
	end -- 3599
end -- 3564
function Play.prototype.stepShield(self, e, dt, input) -- 3604
	local p = self.player -- 3605
	local dx = p.x - e.x -- 3606
	local adx = math.abs(dx) -- 3607
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3610
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3611
	if adx > 150 then -- 3611
		local before = e.x -- 3613
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3614
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3614
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3617
		end -- 3617
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3617
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3622
		local rollDodges = p.rollT > 0 and fromFront -- 3623
		if not rollDodges and self.invulnT <= 0 then -- 3623
			local ____opt_55 = self.run.trial -- 3623
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_55 and ____opt_55.ranks.guard or 0) -- 3625
			self.craftT = 0 -- 3626
			self.hp = self.hp - 1 -- 3627
			self:emit("actorHit", { -- 3628
				target = "player", -- 3628
				amount = 1, -- 3628
				hp = self.hp, -- 3628
				maxHp = self.maxHp, -- 3628
				enemyX = e.x -- 3628
			}) -- 3628
			self:flashSet( -- 3629
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3629
				0.8 -- 3629
			) -- 3629
			if self.hp <= 0 then -- 3629
				self:campaignFailed() -- 3631
				return -- 3632
			end -- 3632
		end -- 3632
		e.swingT = 70 -- 3635
	end -- 3635
	if (e.swingT or 0) > 0 then -- 3635
		e.swingT = (e.swingT or 0) - 1 -- 3638
	end -- 3638
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3638
		local dd = p.depth - (e.depth or 0) -- 3641
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3642
	end -- 3642
end -- 3604
function Play.prototype.stepBreaker(self, e, dt) -- 3647
	local p = self.player -- 3648
	if e.awake ~= true then -- 3648
		if math.abs(p.x - e.x) < 560 then -- 3648
			e.awake = true -- 3651
		else -- 3651
			return -- 3653
		end -- 3653
	end -- 3653
	local target = nil -- 3656
	local bestD = 1000000000 -- 3657
	local i = 0 -- 3658
	do -- 3658
		i = 0 -- 3659
		while i < #self.boxes do -- 3659
			do -- 3659
				local b = self.boxes[i + 1] -- 3660
				if b.breakable == nil or b.broken == true then -- 3660
					goto __continue591 -- 3662
				end -- 3662
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3664
				if d < bestD then -- 3664
					bestD = d -- 3666
					target = b -- 3667
				end -- 3667
			end -- 3667
			::__continue591:: -- 3667
			i = i + 1 -- 3659
		end -- 3659
	end -- 3659
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3670
	local dx = tx - e.x -- 3671
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3672
	if math.abs(dx) > reach then -- 3672
		local before = e.x -- 3674
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3675
		if math.abs(e.x - before) < 0.3 then -- 3675
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3677
		end -- 3677
	elseif (e.swingT or 0) <= 0 then -- 3677
		e.swingT = 64 -- 3680
		if target ~= nil then -- 3680
			self:damageProp(target, 2) -- 3682
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3682
			local ____opt_57 = self.run.trial -- 3682
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_57 and ____opt_57.ranks.guard or 0) -- 3684
			self.craftT = 0 -- 3685
			self.hp = self.hp - 1 -- 3686
			self:emit("actorHit", { -- 3687
				target = "player", -- 3687
				amount = 1, -- 3687
				hp = self.hp, -- 3687
				maxHp = self.maxHp, -- 3687
				enemyX = e.x -- 3687
			}) -- 3687
			self:flashSet("破障手近身", 0.8) -- 3688
			if self.hp <= 0 then -- 3688
				self:campaignFailed() -- 3690
				return -- 3691
			end -- 3691
		end -- 3691
	end -- 3691
	if (e.swingT or 0) > 0 then -- 3691
		e.swingT = (e.swingT or 0) - 1 -- 3696
	end -- 3696
end -- 3647
function Play.prototype.campaignFailed(self) -- 3700
	if self.run.trial ~= nil then -- 3700
		self.run.trial.lost = true -- 3702
		self.wantRoom = "" -- 3703
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3704
		return -- 3705
	end -- 3705
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3705
		self:restartEscortFromDeath() -- 3710
		return -- 3711
	end -- 3711
	local p = self.player -- 3713
	self.hp = self.maxHp -- 3714
	self.invulnT = INVULN_RESPAWN_TICKS -- 3715
	self.reloadT = 0 -- 3716
	self:closeReloadPuzzle() -- 3717
	self.gripping = false -- 3718
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3719
	self:log("被击倒") -- 3720
	p.x = self.room.minX + 90 -- 3721
	p.y = 0 -- 3722
	p.depth = 0 -- 3723
	p.vx = 0 -- 3724
	p.vy = 0 -- 3725
	p.onGround = true -- 3726
	p.rollT = 0 -- 3727
	self.partner.x = p.x - 50 -- 3728
	self.partner.y = 0 -- 3729
	self.partner.depth = 0 -- 3730
	self.cam.x = p.x -- 3731
	local i = 0 -- 3732
	do -- 3732
		i = 0 -- 3733
		while i < #self.enemies do -- 3733
			do -- 3733
				local e = self.enemies[i + 1] -- 3734
				if not e.alive then -- 3734
					goto __continue605 -- 3736
				end -- 3736
				e.x = e.homeX == nil and e.x or e.homeX -- 3738
				e.warnT = 0 -- 3739
				e.fireCd = 40 -- 3740
				e.swingT = 0 -- 3741
				e.awake = false -- 3742
			end -- 3742
			::__continue605:: -- 3742
			i = i + 1 -- 3733
		end -- 3733
	end -- 3733
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3744
end -- 3700
function Play.prototype.isEscortRoom(self) -- 3748
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3749
end -- 3748
function Play.prototype.restartEscortFromDeath(self) -- 3757
	local story = self.run.story -- 3758
	local inv = self.run.inventory -- 3759
	self.hp = self.maxHp -- 3760
	story.hp = self.maxHp -- 3761
	story.cp = nil -- 3762
	self.checkpointSnap = nil -- 3763
	story.carry = false -- 3764
	self.carryOn = false -- 3765
	story.craftedWeapon = "" -- 3766
	self.equippedWeapon = "standard_gun" -- 3767
	story.escortDone = false -- 3768
	self.escortDone = false -- 3769
	story.segments = {} -- 3770
	inv.wood = 0 -- 3771
	inv.bell = 0 -- 3772
	inv.scrap = 0 -- 3773
	inv.wedge = 0 -- 3774
	inv.ammo = 0 -- 3775
	inv.quickbelt = 0 -- 3776
	inv.shield = 0 -- 3777
	inv.pass = 0 -- 3778
	local taken = self.run.taken -- 3779
	local keys = __TS__ObjectKeys(taken) -- 3780
	local i = 0 -- 3781
	do -- 3781
		i = 0 -- 3782
		while i < #keys do -- 3782
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3782
				__TS__Delete(taken, keys[i + 1]) -- 3784
			end -- 3784
			i = i + 1 -- 3782
		end -- 3782
	end -- 3782
	self.run.joined = true -- 3787
	self.reloadT = 0 -- 3788
	self:closeReloadPuzzle() -- 3789
	self.gripping = false -- 3790
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3791
	self:log("男主线失败 · 回 escort1") -- 3792
	self:emit("campaignFailed", { -- 3793
		room = self.room.key, -- 3794
		hp = 0, -- 3794
		maxHp = self.maxHp, -- 3794
		reset = true, -- 3795
		to = "escort1", -- 3795
		route = self.storyRoute -- 3795
	}) -- 3795
	self:requestRoom("escort1", "男主线失败重开") -- 3797
end -- 3757
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3801
	local i = 0 -- 3802
	do -- 3802
		i = 0 -- 3803
		while i < #self.enemies do -- 3803
			do -- 3803
				if i == skipIndex then -- 3803
					goto __continue614 -- 3805
				end -- 3805
				local e = self.enemies[i + 1] -- 3807
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3807
					goto __continue614 -- 3809
				end -- 3809
				e.fireCd = 150 -- 3811
				e.warnT = 0 -- 3812
			end -- 3812
			::__continue614:: -- 3812
			i = i + 1 -- 3803
		end -- 3803
	end -- 3803
end -- 3801
function Play.prototype.stepEnemies(self, dt, input) -- 3816
	local i = 0 -- 3817
	do -- 3817
		i = 0 -- 3818
		while i < #self.enemies do -- 3818
			local e = self.enemies[i + 1] -- 3819
			if e.hitT > 0 then -- 3819
				e.hitT = e.hitT - dt -- 3821
			end -- 3821
			i = i + 1 -- 3818
		end -- 3818
	end -- 3818
	if self.coveredFlash > 0 then -- 3818
		self.coveredFlash = self.coveredFlash - dt -- 3825
	end -- 3825
	if self.isCampaign then -- 3825
		self:stepCampaignEnemies(dt, input) -- 3828
		return -- 3829
	end -- 3829
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3829
		return -- 3833
	end -- 3833
	do -- 3833
		i = 0 -- 3835
		while i < #self.enemies do -- 3835
			do -- 3835
				local e = self.enemies[i + 1] -- 3836
				if not e.alive then -- 3836
					goto __continue625 -- 3838
				end -- 3838
				if e.warnT > 0 then -- 3838
					e.warnT = e.warnT - 1 -- 3841
					if e.warnT <= 0 then -- 3841
						self:enemyFire(e, input) -- 3843
					end -- 3843
					goto __continue625 -- 3845
				end -- 3845
				if e.fireCd > 0 then -- 3845
					e.fireCd = e.fireCd - 1 -- 3848
					if e.fireCd <= 0 then -- 3848
						e.warnT = WARN_TICKS -- 3850
					end -- 3850
				else -- 3850
					e.warnT = WARN_TICKS -- 3854
				end -- 3854
			end -- 3854
			::__continue625:: -- 3854
			i = i + 1 -- 3835
		end -- 3835
	end -- 3835
end -- 3816
function Play.prototype.enemyFire(self, e, input) -- 3860
	local p = self.player -- 3861
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3861
		self:flashSet("枪声响在远处", 0.4) -- 3863
		e.fireCd = FIRE_COOLDOWN -- 3864
		return -- 3865
	end -- 3865
	local cover = self:blockedByCover(e, p) -- 3868
	local hugging = cover ~= nil -- 3869
	self.coverBlocking = hugging -- 3870
	local covered = hugging and input.cover.held -- 3871
	if covered then -- 3871
		self.coveredFlash = 0.5 -- 3873
		self:flashSet("掩体挡下", 0.5) -- 3874
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3875
		e.fireCd = FIRE_COOLDOWN -- 3880
		return -- 3881
	end -- 3881
	self.hp = self.hp - 1 -- 3883
	self:emit("actorHit", { -- 3884
		target = "player", -- 3884
		amount = 1, -- 3884
		hp = self.hp, -- 3884
		maxHp = self.maxHp, -- 3884
		enemyX = e.x -- 3884
	}) -- 3884
	self:flashSet( -- 3885
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3885
		0.7 -- 3885
	) -- 3885
	e.fireCd = FIRE_COOLDOWN -- 3886
	if self.hp <= 0 then -- 3886
		self:gateFailed() -- 3888
	end -- 3888
end -- 3860
function Play.prototype.blockedByCover(self, enemy, p) -- 3893
	local b = self:coverAt(p) -- 3894
	if b == nil then -- 3894
		return nil -- 3896
	end -- 3896
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3898
end -- 3893
function Play.prototype.gateFailed(self) -- 3902
	local ____temp_59 -- 3903
	if self.room.story == nil then -- 3903
		____temp_59 = nil -- 3903
	else -- 3903
		____temp_59 = self.room.story.gate -- 3903
	end -- 3903
	local g = ____temp_59 -- 3903
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3904
	self.hp = self.maxHp -- 3905
	self.gateTick = 0 -- 3906
	self.gateSpawned = 0 -- 3907
	self.enemies = {} -- 3908
	self.gateFailCount = self.gateFailCount + 1 -- 3909
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3911
	self.player.y = 0 -- 3912
	self.player.vy = 0 -- 3913
	self.player.depth = 0 -- 3914
	self.player.depthSpeed = 0 -- 3915
	self.player.onGround = true -- 3916
	self.player.crouch = false -- 3917
	self.player.h = SOLDIER_H -- 3918
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3919
	self.partner.y = 0 -- 3920
	self.partner.vy = 0 -- 3921
	self.partner.depth = 0 -- 3922
	self.partner.depthSpeed = 0 -- 3923
	self.partner.onGround = true -- 3924
	self.cam.x = self.player.x -- 3925
	self.phase = "gate-idle" -- 3926
	self.phaseTick = 0 -- 3927
	self.coverHug = false -- 3928
	self.coverBlocking = false -- 3929
	self.coverEntity = "" -- 3930
	self.gateNeedConfirm = true -- 3931
	self.gateRestartArmed = false -- 3932
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3933
end -- 3902
function Play.prototype.stepRedCart(self, input) -- 3937
	if self.room.key ~= "outside" or self.redCartPulled then -- 3937
		return -- 3939
	end -- 3939
	local box = __TS__ArrayFind( -- 3941
		self.boxes, -- 3941
		function(____, b) return b.id == "outside_red_cart" end -- 3941
	) -- 3941
	if box == nil then -- 3941
		self.redCartPulled = true -- 3943
		return -- 3944
	end -- 3944
	local cx = (box.x0 + box.x1) * 0.5 -- 3946
	local p = self.player -- 3947
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 3947
		return -- 3949
	end -- 3949
	if not input.interact.pressed then -- 3949
		return -- 3952
	end -- 3952
	box.x0 = 430 -- 3954
	box.x1 = 474 -- 3955
	self.cartAxle = self.room.cart.endX -- 3957
	self.cartDocked = true -- 3958
	self.redCartPulled = true -- 3959
	if self.run.story ~= nil then -- 3959
		self.run.story.segments.outside_cart = true -- 3961
	end -- 3961
	self:flashSet("拉开红布车 · 石阶口露出来", 1.6) -- 3963
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 3964
end -- 3937
function Play.prototype.stepInteract(self, dt, input) -- 3967
	local p = self.player -- 3968
	self:stepRedCart(input) -- 3969
	local calmUsed = self.calmConsumed -- 3970
	self.calmConsumed = false -- 3971
	local calming = self.escort.state == "calming" -- 3973
	self.focusCart = false -- 3974
	if self.room.key == "outside" then -- 3974
		local c = self.room.cart -- 3976
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3977
		local dy = p.y - c.baseY -- 3978
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3979
	end -- 3979
	if not calmUsed and not calming then -- 3979
		self:stepCart(dt, input) -- 3983
	end -- 3983
	if calmUsed then -- 3983
		self:flashSet("安抚 · 敲两下", 0.8) -- 3988
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3988
		if self.knockT > 0 then -- 3988
			self.knocks = self.knocks + 1 -- 3992
		else -- 3992
			self.knocks = 1 -- 3994
		end -- 3994
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3996
		self.knockT = 1.2 -- 3997
		if self.knocks >= 2 then -- 3997
			self:flashSet("敲两下", 0.8) -- 3999
			self.knocks = 0 -- 4000
		else -- 4000
			self:flashSet("敲一下", 0.5) -- 4002
		end -- 4002
	elseif self.knockT > 0 then -- 4002
		self.knockT = self.knockT - dt -- 4005
		if self.knockT <= 0 then -- 4005
			self.knocks = 0 -- 4007
		end -- 4007
	end -- 4007
	local i = 0 -- 4012
	do -- 4012
		i = 0 -- 4013
		while i < #self.room.marks do -- 4013
			do -- 4013
				local m = self.room.marks[i + 1] -- 4014
				if m.kind ~= 0 then -- 4014
					goto __continue658 -- 4016
				end -- 4016
				local subjects = {self.partner, self.player} -- 4018
				local k = 0 -- 4019
				do -- 4019
					k = 0 -- 4020
					while k < #subjects do -- 4020
						do -- 4020
							local s = subjects[k + 1] -- 4021
							if not s.alive then -- 4021
								goto __continue661 -- 4023
							end -- 4023
							local dx = s.x - m.x -- 4025
							local dy = s.y - m.y -- 4026
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4026
								self.checkpoint = m.x -- 4028
								self.checkpointCartAxle = self.cartAxle -- 4029
								if self.isCampaign then -- 4029
									self:captureCheckpoint(m.x) -- 4032
								end -- 4032
								if self.cartDocked then -- 4032
									self:flashSet("检查点 · 车已落窝", 1) -- 4035
								else -- 4035
									self:flashSet("检查点 · 车还没到位", 1) -- 4037
								end -- 4037
							end -- 4037
						end -- 4037
						::__continue661:: -- 4037
						k = k + 1 -- 4020
					end -- 4020
				end -- 4020
			end -- 4020
			::__continue658:: -- 4020
			i = i + 1 -- 4013
		end -- 4013
	end -- 4013
	self:checkCarryGate() -- 4043
end -- 3967
function Play.prototype.stepVillage(self, dt, input) -- 4047
	if self.room.key ~= "village" then -- 4047
		return -- 4049
	end -- 4049
	local p = self.player -- 4051
	local bottle = self.room.bottle -- 4052
	local scav = self.room.scavenger -- 4053
	if not self.hasBottle and bottle ~= nil then -- 4053
		local dx = p.x - bottle.x -- 4057
		local dy = p.y + p.h * 0.5 - bottle.y -- 4058
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4058
			self.hasBottle = true -- 4060
			self:flashSet("拾起瓶子", 0.8) -- 4061
		end -- 4061
	end -- 4061
	if self.hasBottle then -- 4061
		if input.aim.held then -- 4061
			self.aimHold = self.aimHold + dt -- 4068
			if self.aimHold > 1.2 then -- 4068
				self.aimHold = 1.2 -- 4070
			end -- 4070
			local cached = self:bottleEnd() -- 4073
			self.bottleAimX = cached.x -- 4074
			self.bottleAimY = cached.y -- 4075
		elseif input.aim.released then -- 4075
			if self.aimHold < 0.12 then -- 4075
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4079
				self.aimHold = 0 -- 4080
			else -- 4080
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4082
				self:throwBottle(____end.x, ____end.y) -- 4083
				self.aimHold = 0 -- 4084
			end -- 4084
		end -- 4084
	else -- 4084
		self.aimHold = 0 -- 4088
		self.bottleAimX = -1 -- 4089
	end -- 4089
	local fly = self.bottleFly -- 4094
	if fly ~= nil then -- 4094
		fly.t = fly.t + dt -- 4096
		fly.x = fly.x0 + fly.vx * fly.t -- 4097
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4098
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4099
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4099
			self:landBottle(fly) -- 4101
		end -- 4101
	end -- 4101
	if self.bottleLandT > 0 then -- 4101
		self.bottleLandT = self.bottleLandT - dt -- 4105
	end -- 4105
	if scav ~= nil then -- 4105
		self:stepScav(dt, scav) -- 4109
	end -- 4109
	local line = self.room.passLine -- 4112
	if line ~= nil and not self.passed and p.x >= line then -- 4112
		self.passed = true -- 4114
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4115
	end -- 4115
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4118
	if underTable then -- 4118
		self.footHintT = self.footHintT - 1 -- 4120
		if self.footHintT <= 0 then -- 4120
			self.footHintT = 90 -- 4122
			local scavX = self.scavX -- 4123
			local near = math.abs(scavX - p.x) < 120 -- 4124
			local heard = near or self.scavState == "walk" or self.scavState == "chase" -- 4125
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4126
			self:emit("storyBeat", {beat = near and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4127
		end -- 4127
	else -- 4127
		self.footHintT = 0 -- 4130
	end -- 4130
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4130
		self.ditchHinted = true -- 4134
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4135
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4136
	end -- 4136
	if self.passed and p.x >= self.ox + 640 then -- 4136
		self:requestRoom("forest", "过第一院出院") -- 4140
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4141
	end -- 4141
end -- 4047
function Play.prototype.bottleEnd(self) -- 4146
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4147
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 4150
	return {x = aim.x, y = g} -- 4151
end -- 4146
function Play.prototype.throwBottle(self, tx, ty) -- 4155
	local p = self.player -- 4156
	local dir = tx >= p.x and 1 or -1 -- 4158
	p.facing = dir -- 4159
	local x0 = p.x + dir * 10 -- 4160
	local y0 = p.y + p.h * 0.7 -- 4161
	self.bottleTargetX = tx -- 4162
	self.bottleTargetY = ty -- 4163
	self.bottleSurfaceY = ty -- 4164
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4165
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4166
	self.bottleFly = { -- 4167
		x = x0, -- 4167
		y = y0, -- 4167
		x0 = x0, -- 4167
		y0 = y0, -- 4167
		vx = vx, -- 4167
		vy = vy, -- 4167
		t = 0 -- 4167
	} -- 4167
	self.hasBottle = false -- 4168
	self:flashSet("投出", 0.4) -- 4169
	self:emit( -- 4170
		"bottleThrown", -- 4170
		{ -- 4170
			fromX = x0, -- 4171
			fromY = y0, -- 4172
			targetX = tx, -- 4173
			targetY = ty, -- 4174
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4175
		} -- 4175
	) -- 4175
end -- 4155
function Play.prototype.landBottle(self, fly) -- 4180
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4181
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4182
	local s = self.room.scavenger -- 4183
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 4184
	self.bottleFly = nil -- 4185
	self.bottleTargetX = -1 -- 4186
	self.bottleTargetY = 0 -- 4187
	self.bottleSurfaceY = -1 -- 4188
	self.bottleLandX = x -- 4189
	self.bottleLandY = y -- 4190
	self.bottleLandT = 0.9 -- 4191
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 4192
	self:hearBottle(x) -- 4193
end -- 4180
function Play.prototype.hearBottle(self, x) -- 4197
	local s = self.room.scavenger -- 4198
	if s == nil then -- 4198
		return -- 4200
	end -- 4200
	if math.abs(x - self.scavX) > s.range then -- 4200
		self:flashSet("落地 · 他没听见", 0.6) -- 4203
		return -- 4204
	end -- 4204
	self.scavState = "turn" -- 4206
	self.scavT = s.hearTicks -- 4207
	self.scavTargetX = x -- 4208
	self:flashSet("砖地一响 · 他转头", 0.9) -- 4209
end -- 4197
function Play.prototype.stepScav(self, dt, s) -- 4213
	if self.scavState == "chase" then -- 4213
		return -- 4216
	end -- 4216
	if self.scavState == "turn" then -- 4216
		self.scavT = self.scavT - 1 -- 4219
		if self.scavT <= 0 then -- 4219
			self.scavState = "walk" -- 4221
		end -- 4221
		return -- 4223
	end -- 4223
	if self.scavState == "walk" then -- 4223
		local d = self.scavTargetX - self.scavX -- 4226
		if math.abs(d) < 4 then -- 4226
			self.scavState = "stall" -- 4228
			self.scavT = s.stallTicks -- 4229
			return -- 4230
		end -- 4230
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4232
		return -- 4233
	end -- 4233
	if self.scavState == "stall" then -- 4233
		self.scavT = self.scavT - 1 -- 4236
		if self.scavT <= 0 then -- 4236
			self.scavState = "back" -- 4238
		end -- 4238
		return -- 4240
	end -- 4240
	if self.scavState == "back" then -- 4240
		local home = math.max( -- 4243
			s.x0, -- 4243
			math.min(s.x1, self.scavX) -- 4243
		) -- 4243
		if math.abs(home - self.scavX) < 2 then -- 4243
			self.scavState = "patrol" -- 4245
			return -- 4246
		end -- 4246
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4248
		return -- 4249
	end -- 4249
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4251
	if self.scavX >= s.x1 then -- 4251
		self.scavX = s.x1 -- 4253
		self.scavDir = -1 -- 4254
	elseif self.scavX <= s.x0 then -- 4254
		self.scavX = s.x0 -- 4256
		self.scavDir = 1 -- 4257
	end -- 4257
end -- 4213
function Play.prototype.stepCart(self, dt, input) -- 4265
	local p = self.player -- 4266
	local c = self.room.cart -- 4267
	if self.gripping then -- 4267
		if not input.interact.held then -- 4267
			self.gripping = false -- 4271
			self:flashSet("松开车把", 0.4) -- 4272
			return -- 4273
		end -- 4273
	else -- 4273
		if not input.interact.pressed then -- 4273
			return -- 4277
		end -- 4277
		if not self:cartHandleInReach(p) then -- 4277
			return -- 4280
		end -- 4280
		local track = c.depth or 0 -- 4282
		if self:limitDepth(p, track) ~= track then -- 4282
			return -- 4284
		end -- 4284
		p.depth = track -- 4286
		p.depthSpeed = 0 -- 4287
		self.gripping = true -- 4288
		self:flashSet("握住车把", 0.4) -- 4289
		return -- 4290
	end -- 4290
	if self.cartDocked then -- 4290
		return -- 4294
	end -- 4294
	local dir = input.moveX -- 4296
	if dir == 0 then -- 4296
		return -- 4298
	end -- 4298
	local lo = math.min(c.startX, c.endX) -- 4300
	local hi = math.max(c.startX, c.endX) -- 4301
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4302
	if next < lo then -- 4302
		next = lo -- 4304
	end -- 4304
	if next > hi then -- 4304
		next = hi -- 4307
	end -- 4307
	local delta = next - self.cartAxle -- 4309
	if delta == 0 then -- 4309
		return -- 4311
	end -- 4311
	self.cartAxle = next -- 4313
	p.x = p.x + delta -- 4314
	p.facing = dir > 0 and 1 or -1 -- 4315
	self:slideX(p, 0) -- 4316
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4316
		self.gripping = false -- 4318
		self:flashSet("跟不上了，脱手", 0.6) -- 4319
		return -- 4320
	end -- 4320
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4320
		self.cartDocked = true -- 4323
		self.gripping = false -- 4324
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4325
		self:flashSet("车轮落窝", 1.2) -- 4326
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4326
		self:flashSet("车轮回到起点", 0.5) -- 4328
	end -- 4328
end -- 4265
function Play.prototype.requestRoom(self, key, reason) -- 4336
	if self.wantRoom ~= "" then -- 4336
		return -- 4340
	end -- 4340
	self.wantRoom = key -- 4342
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4343
end -- 4336
function Play.prototype.checkCarryGate(self) -- 4350
	if self.room.key == "checkpoint" then -- 4350
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4350
			self.carryCartAxle = self.cartAxle -- 4353
			self.carryCartDocked = self.cartDocked -- 4354
			self:requestRoom("gate", "检查站出口") -- 4355
			self:flashSet("出检查站 · 城门", 1.2) -- 4356
		end -- 4356
		return -- 4358
	end -- 4358
	if self.room.key == "outside" then -- 4358
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4358
			self.carryCartAxle = self.cartAxle -- 4364
			self.carryCartDocked = self.cartDocked -- 4365
			self:requestRoom("village", "墙根走完") -- 4366
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4367
		end -- 4367
	end -- 4367
end -- 4350
function Play.prototype.aimAt(self, wx, wy) -- 4374
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4375
	self.aimX = s.x -- 4376
	self.aimY = s.y -- 4377
end -- 4374
function Play.prototype.shoot(self, a) -- 4380
	if self.isCampaign and self.reloadT > 0 then -- 4380
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4382
		return -- 4383
	end -- 4383
	local ox = a.x + a.facing * 8 -- 4385
	local muzzleY = a.y + a.h * 0.72 -- 4386
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 4387
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4389
	local dx = aim.x - ox -- 4392
	local dy = aim.y - oy -- 4393
	local len = math.sqrt(dx * dx + dy * dy) -- 4394
	if len < 0.001 then -- 4394
		dx = a.facing -- 4396
		dy = 0 -- 4397
	else -- 4397
		dx = dx / len -- 4399
		dy = dy / len -- 4400
	end -- 4400
	if dx ~= 0 then -- 4400
		a.facing = dx > 0 and 1 or -1 -- 4403
	end -- 4403
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4406
	local hitEnemy = self:raycastEnemies(ray) -- 4407
	local tEnemy = hitEnemy.t -- 4408
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4409
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4410
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 4411
	local tWall = solid.t -- 4412
	local rawEffect = self:consumeReloadEffect() -- 4414
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4415
	local reloadEffect = rawEffect -- 4416
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4418
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4419
	self.trace = { -- 4421
		x0 = ox, -- 4421
		y0 = oy, -- 4421
		x1 = ox + dx * t, -- 4421
		y1 = oy + dy * t, -- 4421
		hit = hit -- 4421
	} -- 4421
	self.traceT = 0.12 -- 4422
	self:applyFireDanger(ox) -- 4423
	local killed = false -- 4424
	if hit then -- 4424
		local i = hitEnemy.index -- 4426
		local e = self.enemies[i + 1] -- 4427
		local impactY = oy + dy * tEnemy -- 4428
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4429
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 4430
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4430
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4432
			e.hitT = 0.3 -- 4433
			self:flashSet( -- 4434
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4434
				0.8 -- 4434
			) -- 4434
			self:emit("shotResolved", { -- 4435
				hit = true, -- 4436
				enemyIndex = i, -- 4436
				enemyX = e.x, -- 4436
				aimX = aim.x, -- 4436
				aimY = aim.y, -- 4436
				impactX = ox + dx * t, -- 4437
				impactY = oy + dy * t, -- 4437
				shield = true -- 4437
			}) -- 4437
			self:beginReload() -- 4439
			return -- 4440
		end -- 4440
		e.alive = false -- 4442
		e.hitT = 0.4 -- 4443
		killed = true -- 4444
		self:flashSet("命中", 0.6) -- 4445
		self:dropFor(e) -- 4446
		if reloadEffect == "light" and weaponFx == "light" then -- 4446
			self:blindNearby(e, 160, i) -- 4448
		end -- 4448
		if reloadEffect == "push" then -- 4448
			e.x = e.x + a.facing * 46 -- 4451
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4452
		elseif reloadEffect == "echo" then -- 4452
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4454
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4455
		elseif reloadEffect == "light" then -- 4455
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4457
		end -- 4457
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4457
		self:damageProp(solid.box, 1) -- 4460
	else -- 4460
		self:flashSet("打空", 0.35) -- 4462
	end -- 4462
	if self.isCampaign then -- 4462
		self:beginReload() -- 4465
	end -- 4465
	self:emit("shotResolved", { -- 4467
		hit = hit, -- 4468
		enemyIndex = hit and hitEnemy.index or -1, -- 4469
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4470
		aimX = aim.x, -- 4471
		aimY = aim.y, -- 4472
		impactX = ox + dx * t, -- 4473
		impactY = oy + dy * t -- 4474
	}) -- 4474
end -- 4380
function Play.prototype.applyFireDanger(self, shotX) -- 4479
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4479
		return -- 4481
	end -- 4481
	local dangerX = shotX -- 4483
	local best = -1 -- 4484
	local bestD = 1000000000 -- 4485
	local i = 0 -- 4486
	do -- 4486
		i = 0 -- 4487
		while i < #self.enemies do -- 4487
			do -- 4487
				local e = self.enemies[i + 1] -- 4488
				if not e.alive then -- 4488
					goto __continue746 -- 4490
				end -- 4490
				local d = math.abs(e.x - self.partner.x) -- 4492
				if d < bestD then -- 4492
					bestD = d -- 4494
					best = i -- 4495
				end -- 4495
			end -- 4495
			::__continue746:: -- 4495
			i = i + 1 -- 4487
		end -- 4487
	end -- 4487
	if best >= 0 then -- 4487
		dangerX = self.enemies[best + 1].x -- 4499
	end -- 4499
	local exposed = self:childExposed(dangerX) -- 4501
	local before = self.escort.fear -- 4502
	local dangerId = self.nextDangerId -- 4503
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4504
	self.nextDangerId = self.nextDangerId + 1 -- 4505
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4506
	if after > before then -- 4506
		self:flashSet( -- 4508
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4508
			1 -- 4508
		) -- 4508
	elseif not exposed then -- 4508
		self:flashSet("枪声没够到她", 0.5) -- 4510
	end -- 4510
end -- 4479
function Play.prototype.childExposed(self, dangerX) -- 4515
	local c = self.partner -- 4516
	if not c.alive then -- 4516
		return false -- 4518
	end -- 4518
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4518
		self.boxes, -- 4521
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4521
	) then -- 4521
		return false -- 4522
	end -- 4522
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4522
		return false -- 4525
	end -- 4525
	local toDanger = dangerX - c.x -- 4527
	local toPlayer = self.player.x - c.x -- 4528
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4528
		return false -- 4531
	end -- 4531
	return true -- 4533
end -- 4515
function Play.prototype.raycastEnemies(self, ray) -- 4537
	local best = -1 -- 4538
	local bestI = -1 -- 4539
	do -- 4539
		local i = 0 -- 4540
		while i < #self.enemies do -- 4540
			do -- 4540
				local e = self.enemies[i + 1] -- 4541
				if not e.alive then -- 4541
					goto __continue760 -- 4543
				end -- 4543
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 4545
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4546
				if t >= 0 and (best < 0 or t < best) then -- 4546
					best = t -- 4548
					bestI = i -- 4549
				end -- 4549
			end -- 4549
			::__continue760:: -- 4549
			i = i + 1 -- 4540
		end -- 4540
	end -- 4540
	return {t = best, index = bestI} -- 4552
end -- 4537
function Play.prototype.raycastWorld(self, ray) -- 4555
	return self:raycastSolid(ray).t -- 4556
end -- 4555
function Play.prototype.raycastSolid(self, ray) -- 4560
	local best = -1 -- 4561
	local bestBox = nil -- 4562
	for ____, box in ipairs(self.boxes) do -- 4563
		do -- 4563
			if box.broken == true or box.hidden == true then -- 4563
				goto __continue765 -- 4565
			end -- 4565
			local t = hitBox(ray, box) -- 4570
			if t > 2 and (best < 0 or t < best) then -- 4570
				best = t -- 4573
				bestBox = box -- 4574
			end -- 4574
		end -- 4574
		::__continue765:: -- 4574
	end -- 4574
	if ray.dy < 0 then -- 4574
		local t = -ray.y / ray.dy -- 4578
		if t >= 0 and (best < 0 or t < best) then -- 4578
			best = t -- 4580
			bestBox = nil -- 4581
		end -- 4581
	end -- 4581
	return {t = best, box = bestBox} -- 4584
end -- 4560
function Play.prototype.dropFor(self, e) -- 4588
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4588
		return -- 4590
	end -- 4590
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4590
		return -- 4593
	end -- 4593
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4595
	local ____self_pickups_60 = self.pickups -- 4595
	____self_pickups_60[#____self_pickups_60 + 1] = { -- 4596
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4597
		kind = e.drop, -- 4597
		x = e.x, -- 4597
		y = e.y, -- 4597
		depth = e.depth, -- 4598
		label = label .. " ×1" -- 4598
	} -- 4598
	self:log("掉落 " .. label) -- 4600
end -- 4588
function Play.prototype.damageProp(self, b, amount) -- 4604
	if b.breakable == nil or b.broken == true then -- 4604
		return -- 4606
	end -- 4606
	local ____b_breakable_61, ____hp_62 = b.breakable, "hp" -- 4606
	____b_breakable_61[____hp_62] = ____b_breakable_61[____hp_62] - amount -- 4608
	if b.breakable.hp > 0 then -- 4608
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4610
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4611
		return -- 4612
	end -- 4612
	b.broken = true -- 4614
	for ____, other in ipairs(self.boxes) do -- 4615
		if other.id ~= nil and other.id == b.id then -- 4615
			other.broken = true -- 4617
		end -- 4617
	end -- 4617
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4620
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4621
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4622
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4623
end -- 4604
function Play.prototype.slideDepth(self, a, distance) -- 4627
	a.depth = self:limitDepth(a, a.depth + distance) -- 4628
end -- 4627
function Play.prototype.limitDepth(self, a, target) -- 4631
	local road = self.room.depth -- 4632
	if road == nil or target == a.depth then -- 4632
		return a.depth -- 4634
	end -- 4634
	local next = math.max( -- 4636
		road.min, -- 4636
		math.min(road.max, target) -- 4636
	) -- 4636
	local half = a.w / 2 -- 4637
	for ____, b in ipairs(self.boxes) do -- 4638
		do -- 4638
			local footprint = b.depth -- 4639
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4639
				goto __continue783 -- 4644
			end -- 4644
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4646
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4647
			if a.depth <= front and next > front then -- 4647
				next = front -- 4649
			elseif a.depth >= back and next < back then -- 4649
				next = back -- 4651
			end -- 4651
		end -- 4651
		::__continue783:: -- 4651
	end -- 4651
	return next -- 4654
end -- 4631
function Play.prototype.slideX(self, a, dx) -- 4658
	local nx = a.x + dx -- 4659
	local half = a.w / 2 -- 4660
	local room = self.room -- 4661
	nx = math.max( -- 4662
		room.minX + half, -- 4662
		math.min(room.maxX - half, nx) -- 4662
	) -- 4662
	local i = 0 -- 4663
	do -- 4663
		i = 0 -- 4664
		while i < #self.boxes do -- 4664
			do -- 4664
				local b = self.boxes[i + 1] -- 4665
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4665
					goto __continue790 -- 4667
				end -- 4667
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4667
					goto __continue790 -- 4670
				end -- 4670
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4670
					goto __continue790 -- 4673
				end -- 4673
				if nx + half > b.x0 and nx - half < b.x1 then -- 4673
					if a.x <= b.x0 then -- 4673
						nx = b.x0 - half -- 4677
					elseif a.x >= b.x1 then -- 4677
						nx = b.x1 + half -- 4679
					else -- 4679
						nx = a.x -- 4681
					end -- 4681
				end -- 4681
			end -- 4681
			::__continue790:: -- 4681
			i = i + 1 -- 4664
		end -- 4664
	end -- 4664
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 4664
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 4688
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 4689
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 4689
			if a.x <= bx0 then -- 4689
				nx = bx0 - half -- 4692
			elseif a.x >= bx1 then -- 4692
				nx = bx1 + half -- 4694
			else -- 4694
				nx = a.x -- 4696
			end -- 4696
		end -- 4696
	end -- 4696
	local arch = room.arch -- 4704
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4704
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4706
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4706
			if a.x <= arch.x0 then -- 4706
				nx = arch.x0 - half -- 4709
			elseif a.x >= arch.x1 then -- 4709
				nx = arch.x1 + half -- 4711
			end -- 4711
		end -- 4711
	end -- 4711
	a.x = nx -- 4715
end -- 4658
function Play.prototype.fallY(self, a, dt) -- 4719
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4720
	if a.vy < -900 then -- 4720
		a.vy = -900 -- 4722
	end -- 4722
	local ny = a.y + a.vy * dt -- 4724
	local half = a.w / 2 -- 4725
	if a.vy <= 0 then -- 4725
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 4728
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4729
		if ny <= ground then -- 4729
			ny = ground -- 4731
			a.vy = 0 -- 4732
			a.onGround = true -- 4733
		else -- 4733
			a.onGround = false -- 4735
		end -- 4735
	else -- 4735
		a.onGround = false -- 4738
		local i = 0 -- 4739
		do -- 4739
			i = 0 -- 4740
			while i < #self.boxes do -- 4740
				do -- 4740
					local b = self.boxes[i + 1] -- 4741
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4741
						goto __continue814 -- 4743
					end -- 4743
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4743
						goto __continue814 -- 4746
					end -- 4746
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4746
						goto __continue814 -- 4749
					end -- 4749
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4749
						ny = b.y0 - a.h -- 4752
						a.vy = 0 -- 4753
					end -- 4753
				end -- 4753
				::__continue814:: -- 4753
				i = i + 1 -- 4740
			end -- 4740
		end -- 4740
	end -- 4740
	a.y = ny -- 4757
end -- 4719
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4761
	if depth == nil then -- 4761
		depth = 0 -- 4761
	end -- 4761
	local g = -9999 -- 4762
	local i = 0 -- 4763
	do -- 4763
		i = 0 -- 4764
		while i < #self.floors do -- 4764
			local f = self.floors[i + 1] -- 4765
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4765
				g = f.y1 -- 4767
			end -- 4767
			i = i + 1 -- 4764
		end -- 4764
	end -- 4764
	do -- 4764
		i = 0 -- 4770
		while i < #self.boxes do -- 4770
			do -- 4770
				local b = self.boxes[i + 1] -- 4771
				if b.broken == true or b.hidden == true or b.soft == true then -- 4771
					goto __continue824 -- 4773
				end -- 4773
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4773
					g = b.y1 -- 4777
				end -- 4777
			end -- 4777
			::__continue824:: -- 4777
			i = i + 1 -- 4770
		end -- 4770
	end -- 4770
	return g -- 4780
end -- 4761
function Play.prototype.updateCamera(self, dt) -- 4783
	local p = self.player -- 4784
	local tx = p.x + p.facing * 30 -- 4785
	local ty = p.y + CAM_LOOK_UP -- 4786
	local k = math.min(1, CAM_FOLLOW * dt) -- 4787
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4788
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4789
end -- 4783
function Play.prototype.clampCamera(self, w, h) -- 4793
	local room = self.room -- 4794
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4795
	local spanX = room.maxX - room.minX -- 4796
	if spanX <= halfW * 2 then -- 4796
		self.cam.x = (room.minX + room.maxX) / 2 -- 4798
	else -- 4798
		self.cam.x = math.max( -- 4800
			room.minX + halfW, -- 4800
			math.min(room.maxX - halfW, self.cam.x) -- 4800
		) -- 4800
	end -- 4800
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4803
	local spanY = room.height -- 4804
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4805
	if spanY <= halfH * 2 then -- 4805
		self.cam.y = camY -- 4807
	else -- 4807
		self.cam.y = math.max( -- 4809
			camY, -- 4809
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4809
		) -- 4809
	end -- 4809
end -- 4793
function Play.prototype.flashSet(self, text, t) -- 4813
	self.flash = text -- 4814
	self.flashT = t -- 4815
end -- 4813
function Play.prototype.statusText(self) -- 4819
	local p = self.player -- 4820
	local parts = {} -- 4821
	local who = self.childMode and "小满" or "周戍" -- 4822
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4823
	if self.room.key == "prologue" then -- 4823
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4826
		if self.phase == "prologue-wake" then -- 4826
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 4828
		elseif self.phase == "prologue-shadow" then -- 4828
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 4830
		elseif self.phase == "prologue-escape" then -- 4830
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 4832
		elseif self.phase == "prologue-hide" then -- 4832
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 4834
		elseif self.phase == "prologue-wait" then -- 4834
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4836
		elseif self.phase == "prologue-give" then -- 4836
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4838
		else -- 4838
			parts[#parts + 1] = "跟随" -- 4840
		end -- 4840
		if self.paused then -- 4840
			parts[#parts + 1] = "已暂停" -- 4843
		end -- 4843
		return table.concat(parts, " · ") -- 4845
	end -- 4845
	if self.room.key == "street" then -- 4845
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4848
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4849
		if self.paused then -- 4849
			parts[#parts + 1] = "已暂停" -- 4851
		end -- 4851
		return table.concat(parts, " · ") -- 4853
	end -- 4853
	if self.room.key == "gate" then -- 4853
		local ____temp_63 -- 4856
		if self.room.story == nil then -- 4856
			____temp_63 = nil -- 4856
		else -- 4856
			____temp_63 = self.room.story.gate -- 4856
		end -- 4856
		local g = ____temp_63 -- 4856
		if g ~= nil then -- 4856
			parts[#parts + 1] = self:gateLabel() -- 4858
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4859
				0, -- 4860
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4860
			))) .. " 秒" -- 4860
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4861
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4862
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4863
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4864
			if self.gateFailCount > 0 then -- 4864
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4866
			end -- 4866
			if self.flash ~= "" then -- 4866
				parts[#parts + 1] = self.flash -- 4869
			end -- 4869
		end -- 4869
		if self.paused then -- 4869
			parts[#parts + 1] = "已暂停" -- 4873
		end -- 4873
		return table.concat(parts, " · ") -- 4875
	end -- 4875
	if self.room.key == "forest" then -- 4875
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4878
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4879
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4880
		if self.caughtT > 0 then -- 4880
			parts[#parts + 1] = "复位中" -- 4882
		end -- 4882
		if self.paused then -- 4882
			parts[#parts + 1] = "已暂停" -- 4885
		end -- 4885
		return table.concat(parts, " · ") -- 4887
	end -- 4887
	if self.room.key == "tower" then -- 4887
		if self.phase == "tower-wait" then -- 4887
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4891
		elseif self.phase == "tower-knock" then -- 4891
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4893
		elseif self.phase == "tower-enter" then -- 4893
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 4895
		elseif self.phase == "tower-desk" then -- 4895
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 4897
		elseif self.phase == "tower-given" then -- 4897
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4899
		else -- 4899
			parts[#parts + 1] = "片尾" -- 4901
		end -- 4901
		if self.paused then -- 4901
			parts[#parts + 1] = "已暂停" -- 4904
		end -- 4904
		return table.concat(parts, " · ") -- 4906
	end -- 4906
	if self.room.key == "village" then -- 4906
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4909
		if self.hasBottle then -- 4909
			parts[#parts + 1] = "有瓶" -- 4911
		elseif self.bottleFly ~= nil then -- 4911
			parts[#parts + 1] = "瓶在飞" -- 4913
		else -- 4913
			parts[#parts + 1] = "空手" -- 4915
		end -- 4915
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4917
		if self.scavChase then -- 4917
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4919
		end -- 4919
		if self.passed then -- 4919
			parts[#parts + 1] = "已过通行线" -- 4922
		end -- 4922
		if self.paused then -- 4922
			parts[#parts + 1] = "已暂停" -- 4925
		end -- 4925
		return table.concat(parts, " · ") -- 4927
	end -- 4927
	local isChild = self.childMode -- 4930
	if isChild then -- 4930
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4932
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4933
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4934
	else -- 4934
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4936
		if p.rollT > 0 then -- 4936
			parts[#parts + 1] = "翻滚中" -- 4938
		end -- 4938
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4940
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4941
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4942
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4943
	end -- 4943
	if self.checkpoint >= 0 then -- 4943
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4946
	end -- 4946
	if self.paused then -- 4946
		parts[#parts + 1] = "已暂停" -- 4949
	end -- 4949
	return table.concat(parts, " · ") -- 4951
end -- 4819
function Play.prototype.aliveEnemies(self) -- 4955
	local n = 0 -- 4956
	local i = 0 -- 4957
	do -- 4957
		i = 0 -- 4958
		while i < #self.enemies do -- 4958
			if self.enemies[i + 1].alive then -- 4958
				n = n + 1 -- 4960
			end -- 4960
			i = i + 1 -- 4958
		end -- 4958
	end -- 4958
	return n -- 4963
end -- 4955
function Play.prototype.threatened(self) -- 4968
	do -- 4968
		local i = 0 -- 4969
		while i < #self.enemies do -- 4969
			local e = self.enemies[i + 1] -- 4970
			if e.alive and e.warnT > 0 then -- 4970
				return true -- 4972
			end -- 4972
			i = i + 1 -- 4969
		end -- 4969
	end -- 4969
	return false -- 4975
end -- 4968
function Play.prototype.gateSecondsLeft(self) -- 4978
	local ____temp_64 -- 4979
	if self.room.story == nil then -- 4979
		____temp_64 = nil -- 4979
	else -- 4979
		____temp_64 = self.room.story.gate -- 4979
	end -- 4979
	local g = ____temp_64 -- 4979
	if g == nil then -- 4979
		return 0 -- 4981
	end -- 4981
	return math.max( -- 4983
		0, -- 4983
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4983
	) -- 4983
end -- 4978
function Play.prototype.gateLabel(self) -- 4986
	if self.phase == "gate-idle" then -- 4986
		return "待就位" -- 4988
	end -- 4988
	if self.phase == "gate-hold" then -- 4988
		return "守点中" -- 4991
	end -- 4991
	if self.phase == "gate-send" then -- 4991
		return "送别" -- 4994
	end -- 4994
	if self.phase == "gate-count" then -- 4994
		return "数数 " .. tostring(self.countTick) -- 4997
	end -- 4997
	return "她走" -- 4999
end -- 4986
function Play.prototype.dogLabel(self) -- 5003
	if self.dogState == "ear" then -- 5003
		return "转耳" -- 5005
	end -- 5005
	if self.dogState == "chase" then -- 5005
		return "追" -- 5008
	end -- 5008
	if self.dogState == "sniff" then -- 5008
		return "停" -- 5011
	end -- 5011
	if self.dogState == "back" then -- 5011
		return "回线" -- 5014
	end -- 5014
	return "巡逻" -- 5016
end -- 5003
function Play.prototype.doorXOf(self) -- 5019
	local ____temp_65 -- 5020
	if self.room.story == nil then -- 5020
		____temp_65 = nil -- 5020
	else -- 5020
		____temp_65 = self.room.story.tower -- 5020
	end -- 5020
	local t = ____temp_65 -- 5020
	return t == nil and 0 or t.doorX -- 5021
end -- 5019
function Play.prototype.scavLabel(self) -- 5025
	if self.scavState == "chase" then -- 5025
		return "追" -- 5027
	end -- 5027
	if self.scavState == "turn" then -- 5027
		return "转头" -- 5030
	end -- 5030
	if self.scavState == "walk" then -- 5030
		return "赶来" -- 5033
	end -- 5033
	if self.scavState == "stall" then -- 5033
		return "停住" -- 5036
	end -- 5036
	if self.scavState == "back" then -- 5036
		return "回位" -- 5039
	end -- 5039
	return "巡逻" -- 5041
end -- 5025
function Play.prototype.hintText(self) -- 5045
	if self.paused then -- 5045
		return "Esc 继续 · R 重置" -- 5047
	end -- 5047
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5047
		if self:threatened() then -- 5047
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5053
		end -- 5053
		if self.coverHug then -- 5053
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5056
		end -- 5056
		if self.coverNear then -- 5056
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5059
		end -- 5059
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5061
	end -- 5061
	if self.flash ~= "" then -- 5061
		return self.flash -- 5064
	end -- 5064
	if self.room.key == "prologue" then -- 5064
		if self.phase == "prologue-wake" then -- 5064
			return "父亲在门外唤 · 小满睁眼" -- 5068
		end -- 5068
		if self.phase == "prologue-shadow" then -- 5068
			return "墙上两道人影 · 碗滚到脚边" -- 5071
		end -- 5071
		if self.phase == "prologue-escape" then -- 5071
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5074
		end -- 5074
		if self.phase == "prologue-hide" then -- 5074
			return "柜门合上 · 屏住呼吸" -- 5077
		end -- 5077
		if self.phase == "prologue-wait" then -- 5077
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5080
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5081
		end -- 5081
		if self.phase == "prologue-give" then -- 5081
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5084
		end -- 5084
		return "她跟着你了 · 两人一起走到门口 680" -- 5086
	end -- 5086
	if self.room.key == "street" then -- 5086
		if self:aliveEnemies() > 0 then -- 5086
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5090
		end -- 5090
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5092
	end -- 5092
	if self.room.key == "gate" then -- 5092
		local ____temp_66 -- 5095
		if self.room.story == nil then -- 5095
			____temp_66 = nil -- 5095
		else -- 5095
			____temp_66 = self.room.story.gate -- 5095
		end -- 5095
		local g = ____temp_66 -- 5095
		if g ~= nil then -- 5095
			if self.phase == "gate-idle" then -- 5095
				if self.gateNeedConfirm then -- 5095
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5099
				end -- 5099
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5101
			end -- 5101
			if self.phase == "gate-hold" then -- 5101
				if self.coveredFlash > 0 then -- 5101
					return "掩体挡下了这一枪 · 别露头" -- 5105
				end -- 5105
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5107
			end -- 5107
			if self.phase == "gate-send" then -- 5107
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5110
			end -- 5110
			if self.phase == "gate-count" then -- 5110
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5110
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5114
				end -- 5114
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5116
			end -- 5116
			return "她自己走 · 跟着出城门 1120" -- 5118
		end -- 5118
	end -- 5118
	if self.room.key == "forest" then -- 5118
		if self.dogState == "chase" then -- 5118
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5123
		end -- 5123
		if self.dogState == "ear" then -- 5123
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5126
		end -- 5126
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5128
	end -- 5128
	if self.room.key == "tower" then -- 5128
		if self.phase == "tower-wait" then -- 5128
			return "走到门前 445 点一次 E 敲两下" -- 5132
		end -- 5132
		if self.phase == "tower-knock" then -- 5132
			return "敲两下 · 等门开" -- 5135
		end -- 5135
		if self.phase == "tower-given" then -- 5135
			return "递交针套和纸条 · 看登记簿最后一行" -- 5138
		end -- 5138
		return "片尾 · 点 E 再玩一次，回到序章" -- 5140
	end -- 5140
	if self.room.key == "village" then -- 5140
		if self.bottleFly ~= nil then -- 5140
			return "等瓶子落地 · 触地才发声" -- 5144
		end -- 5144
		if self.hasBottle then -- 5144
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5147
		end -- 5147
		if self.passed then -- 5147
			return "已过第一院 · R 重置可再来一遍" -- 5150
		end -- 5150
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5152
	end -- 5152
	if self.room.key == "outside" then -- 5152
		if self.focusCart then -- 5152
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5156
		end -- 5156
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5158
	end -- 5158
	if self.escort.state == "frozen" then -- 5158
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5158
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5162
		end -- 5162
		return "小满吓住了 · 走过去，靠近再点 E" -- 5164
	end -- 5164
	if self.escort.state == "calming" then -- 5164
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5167
	end -- 5167
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5169
end -- 5045
function Play.prototype.draw(self, draw, w, h) -- 5174
	self.viewW = w -- 5175
	self.viewH = h -- 5176
	self.view = ____exports.computeViewport(w, h) -- 5177
	self:clampCamera(w, h) -- 5178
	draw:clear() -- 5179
	draw:drawRect( -- 5181
		Rect(0, 0, w, h), -- 5181
		BG_VOID -- 5181
	) -- 5181
	local box = self:canvasRect(w, h) -- 5182
	draw:drawRect(box, BG_FAR) -- 5183
	draw:drawRect( -- 5184
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5184
		BG_MID -- 5184
	) -- 5184
	self:drawFloors(draw, w, h) -- 5186
	self:drawSolids(draw, w, h) -- 5187
	self:drawZones(draw, w, h) -- 5188
	self:drawArch(draw, w, h) -- 5189
	self:drawCart(draw, w, h) -- 5190
	self:drawCampaignProps(draw, w, h) -- 5191
	self:drawActors(draw, w, h) -- 5192
	self:drawTrace(draw, w, h) -- 5193
	self:drawAim(draw, w, h) -- 5194
end -- 5174
function Play.prototype.canvasRect(self, w, h) -- 5198
	local v = self.view -- 5199
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5200
end -- 5198
function Play.prototype.px(self, n) -- 5204
	return n * self.view.zoom -- 5205
end -- 5204
function Play.prototype.sx(self, wx, w) -- 5209
	local v = self.view -- 5210
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5211
	return v.ox + lx * v.zoom -- 5212
end -- 5209
function Play.prototype.sy(self, wy, h) -- 5216
	local v = self.view -- 5217
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5218
	return v.oy + ly * v.zoom -- 5219
end -- 5216
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5222
	local px0 = self:sx(x0, w) -- 5223
	local px1 = self:sx(x1, w) -- 5224
	local py0 = self:sy(y0, h) -- 5225
	local py1 = self:sy(y1, h) -- 5226
	if px1 <= px0 or py1 <= py0 then -- 5226
		return -- 5228
	end -- 5228
	draw:drawRect( -- 5230
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5230
		color -- 5230
	) -- 5230
end -- 5222
function Play.prototype.drawFloors(self, draw, w, h) -- 5233
	local i = 0 -- 5234
	do -- 5234
		i = 0 -- 5235
		while i < #self.room.floors do -- 5235
			local f = self.room.floors[i + 1] -- 5236
			local ____temp_67 -- 5237
			if f.y == 0 then -- 5237
				____temp_67 = self.room.depth -- 5237
			else -- 5237
				____temp_67 = nil -- 5237
			end -- 5237
			local road = ____temp_67 -- 5237
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5238
			local x0 = self:sx(f.x0, w) -- 5239
			local x1 = self:sx(f.x1, w) -- 5240
			local deck = self:px(5) -- 5241
			if road ~= nil then -- 5241
				local back = self:sy(f.y + road.max, h) -- 5243
				draw:drawRect( -- 5244
					Rect(x0, y, x1 - x0, back - y), -- 5244
					FLOOR_DECK, -- 5244
					self:px(1), -- 5244
					SOLID_EDGE -- 5244
				) -- 5244
			end -- 5244
			draw:drawRect( -- 5246
				Rect(x0, y - deck, x1 - x0, deck), -- 5246
				FLOOR_DECK -- 5246
			) -- 5246
			draw:drawSegment( -- 5247
				Vec2(x0, y), -- 5247
				Vec2(x1, y), -- 5247
				self:px(1), -- 5247
				GROUND -- 5247
			) -- 5247
			i = i + 1 -- 5235
		end -- 5235
	end -- 5235
end -- 5233
function Play.prototype.drawSolids(self, draw, w, h) -- 5251
	local i = 0 -- 5252
	do -- 5252
		i = 0 -- 5253
		while i < #self.boxes do -- 5253
			do -- 5253
				local b = self.boxes[i + 1] -- 5254
				if b.id == "braced_shield" or b.hidden == true then -- 5254
					goto __continue955 -- 5256
				end -- 5256
				if b.broken == true then -- 5256
					if b.breakable ~= nil then -- 5256
						local gy = self:sy(b.y0, h) -- 5261
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5262
						local k = 0 -- 5263
						do -- 5263
							k = 0 -- 5264
							while k < 3 do -- 5264
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5265
								draw:drawSegment( -- 5266
									Vec2( -- 5266
										gx - self:px(4), -- 5266
										gy + self:px(k % 2) -- 5266
									), -- 5266
									Vec2( -- 5266
										gx + self:px(5), -- 5266
										gy + self:px(k % 2) -- 5266
									), -- 5266
									self:px(1), -- 5266
									rgb -- 5266
								) -- 5266
								k = k + 1 -- 5264
							end -- 5264
						end -- 5264
					end -- 5264
					goto __continue955 -- 5269
				end -- 5269
				local ____opt_70 = b.depth -- 5269
				local front = ____opt_70 and ____opt_70.min or 0 -- 5271
				local ____opt_72 = b.depth -- 5271
				local back = ____opt_72 and ____opt_72.max or 0 -- 5272
				local fill = SOLID_FILL -- 5273
				local line = SOLID_EDGE -- 5274
				if b.soft == true then -- 5274
					fill = SOFT -- 5276
					line = SOFT_LINE -- 5277
				elseif b.breakable ~= nil then -- 5277
					line = DANGER_LINE -- 5279
					fill = Color(0.3, 0.24, 0.16, 1) -- 5280
				elseif b.interact ~= nil then -- 5280
					line = PASS_LINE -- 5282
				end -- 5282
				self:drawBox( -- 5284
					draw, -- 5284
					w, -- 5284
					h, -- 5284
					b.x0, -- 5284
					b.x1, -- 5284
					b.y0 + front, -- 5284
					b.y1 + back, -- 5284
					fill -- 5284
				) -- 5284
				draw:drawSegment( -- 5285
					Vec2( -- 5285
						self:sx(b.x0, w), -- 5285
						self:sy(b.y1 + front, h) -- 5285
					), -- 5285
					Vec2( -- 5286
						self:sx(b.x1, w), -- 5286
						self:sy(b.y1 + front, h) -- 5286
					), -- 5286
					self:px(1), -- 5286
					line -- 5286
				) -- 5286
				if b.breakable ~= nil then -- 5286
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5289
					local cyp = self:sy(b.y1 + front, h) -- 5290
					draw:drawSegment( -- 5291
						Vec2( -- 5291
							cxp - self:px(4), -- 5291
							cyp + self:px(1) -- 5291
						), -- 5291
						Vec2( -- 5291
							cxp + self:px(3), -- 5291
							cyp + self:px(5) -- 5291
						), -- 5291
						self:px(1), -- 5291
						line -- 5291
					) -- 5291
				end -- 5291
			end -- 5291
			::__continue955:: -- 5291
			i = i + 1 -- 5253
		end -- 5253
	end -- 5253
end -- 5251
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5297
	local i = 0 -- 5298
	do -- 5298
		i = 0 -- 5299
		while i < #self.pickups do -- 5299
			do -- 5299
				local pk = self.pickups[i + 1] -- 5300
				if self.run.taken[pk.id] == true then -- 5300
					goto __continue967 -- 5302
				end -- 5302
				local gy = pk.y + (pk.depth or 0) -- 5304
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5305
				draw:drawRect( -- 5306
					Rect( -- 5306
						self:sx(pk.x - 5, w), -- 5306
						self:sy(gy + 12 + bob, h), -- 5306
						self:px(10), -- 5306
						self:px(10) -- 5306
					), -- 5306
					Color(0.84, 0.7, 0.3, 1) -- 5307
				) -- 5307
				draw:drawSegment( -- 5308
					Vec2( -- 5308
						self:sx(pk.x - 5, w), -- 5308
						self:sy(gy + 12 + bob, h) -- 5308
					), -- 5308
					Vec2( -- 5309
						self:sx(pk.x + 5, w), -- 5309
						self:sy(gy + 12 + bob, h) -- 5309
					), -- 5309
					self:px(1), -- 5309
					Color(0.95, 0.86, 0.52, 1) -- 5309
				) -- 5309
			end -- 5309
			::__continue967:: -- 5309
			i = i + 1 -- 5299
		end -- 5299
	end -- 5299
	if self.bracedShield ~= nil then -- 5299
		local sh = self.bracedShield -- 5312
		draw:drawRect( -- 5313
			Rect( -- 5313
				self:sx(sh.x - sh.w / 2, w), -- 5313
				self:sy(sh.y, h), -- 5313
				self:px(sh.w), -- 5313
				self:px(sh.h) -- 5313
			), -- 5313
			Color(0.42, 0.4, 0.34, 1) -- 5314
		) -- 5314
		draw:drawSegment( -- 5315
			Vec2( -- 5315
				self:sx(sh.x - sh.w / 2, w), -- 5315
				self:sy(sh.y + sh.h, h) -- 5315
			), -- 5315
			Vec2( -- 5316
				self:sx(sh.x + sh.w / 2, w), -- 5316
				self:sy(sh.y + sh.h, h) -- 5316
			), -- 5316
			self:px(1), -- 5316
			Color(0.74, 0.72, 0.62, 1) -- 5316
		) -- 5316
	end -- 5316
end -- 5297
function Play.prototype.drawZones(self, draw, w, h) -- 5320
	local i = 0 -- 5321
	do -- 5321
		i = 0 -- 5322
		while i < #self.room.zones do -- 5322
			local z = self.room.zones[i + 1] -- 5323
			local fill = DANGER -- 5324
			local line = DANGER_LINE -- 5325
			if z.tint == 2 then -- 5325
				fill = SOFT -- 5327
				line = SOFT_LINE -- 5328
			elseif z.tint == 3 then -- 5328
				fill = BRICK -- 5330
				line = BRICK_LINE -- 5331
			elseif z.tint == 4 then -- 5331
				fill = PASS -- 5333
				line = PASS_LINE -- 5334
			end -- 5334
			self:drawBox( -- 5336
				draw, -- 5336
				w, -- 5336
				h, -- 5336
				z.x0, -- 5336
				z.x1, -- 5336
				z.y, -- 5336
				z.y + z.h, -- 5336
				fill -- 5336
			) -- 5336
			draw:drawSegment( -- 5337
				Vec2( -- 5337
					self:sx(z.x0, w), -- 5337
					self:sy(z.y, h) -- 5337
				), -- 5337
				Vec2( -- 5337
					self:sx(z.x0, w), -- 5337
					self:sy(z.y + z.h, h) -- 5337
				), -- 5337
				self:px(1), -- 5337
				line -- 5337
			) -- 5337
			draw:drawSegment( -- 5338
				Vec2( -- 5338
					self:sx(z.x1, w), -- 5338
					self:sy(z.y, h) -- 5338
				), -- 5338
				Vec2( -- 5338
					self:sx(z.x1, w), -- 5338
					self:sy(z.y + z.h, h) -- 5338
				), -- 5338
				self:px(1), -- 5338
				line -- 5338
			) -- 5338
			i = i + 1 -- 5322
		end -- 5322
	end -- 5322
end -- 5320
function Play.prototype.drawArch(self, draw, w, h) -- 5342
	local a = self.room.arch -- 5343
	if a.h <= 0 then -- 5343
		return -- 5345
	end -- 5345
	self:drawBox( -- 5347
		draw, -- 5347
		w, -- 5347
		h, -- 5347
		a.x0, -- 5347
		a.x1, -- 5347
		a.y, -- 5347
		a.y + a.h, -- 5347
		HOLE_FILL -- 5347
	) -- 5347
	draw:drawSegment( -- 5348
		Vec2( -- 5348
			self:sx(a.x0, w), -- 5348
			self:sy(a.y + a.h, h) -- 5348
		), -- 5348
		Vec2( -- 5348
			self:sx(a.x1, w), -- 5348
			self:sy(a.y + a.h, h) -- 5348
		), -- 5348
		self:px(1), -- 5348
		SOLID_EDGE -- 5348
	) -- 5348
	draw:drawSegment( -- 5349
		Vec2( -- 5349
			self:sx(a.x0, w), -- 5349
			self:sy(a.y, h) -- 5349
		), -- 5349
		Vec2( -- 5349
			self:sx(a.x0, w), -- 5349
			self:sy(a.y + a.h, h) -- 5349
		), -- 5349
		self:px(1), -- 5349
		SOLID_EDGE -- 5349
	) -- 5349
	draw:drawSegment( -- 5350
		Vec2( -- 5350
			self:sx(a.x1, w), -- 5350
			self:sy(a.y, h) -- 5350
		), -- 5350
		Vec2( -- 5350
			self:sx(a.x1, w), -- 5350
			self:sy(a.y + a.h, h) -- 5350
		), -- 5350
		self:px(1), -- 5350
		SOLID_EDGE -- 5350
	) -- 5350
end -- 5342
function Play.prototype.drawCart(self, draw, w, h) -- 5353
	local c = self.room.cart -- 5354
	if c.bodyW <= 0 then -- 5354
		return -- 5356
	end -- 5356
	drawCartShape( -- 5358
		draw, -- 5358
		self, -- 5358
		w, -- 5358
		h, -- 5358
		c, -- 5358
		self.cartAxle -- 5358
	) -- 5358
	draw:drawRect( -- 5359
		Rect( -- 5359
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5359
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5359
			self:px(2), -- 5359
			self:px(40) -- 5359
		), -- 5359
		STAND -- 5359
	) -- 5359
end -- 5353
function Play.prototype.drawActors(self, draw, w, h) -- 5362
	local p = self.player -- 5363
	local isChild = self.childMode -- 5364
	local footY = p.y + p.depth -- 5365
	if p.covered then -- 5365
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5368
		draw:drawSegment( -- 5369
			Vec2( -- 5369
				self:sx(edge, w), -- 5369
				self:sy(footY + 8, h) -- 5369
			), -- 5369
			Vec2( -- 5369
				self:sx(edge, w), -- 5369
				self:sy(footY + p.h * 0.62, h) -- 5369
			), -- 5369
			self:px(2), -- 5369
			STAND -- 5369
		) -- 5369
		draw:drawSegment( -- 5371
			Vec2( -- 5371
				self:sx(p.x - 8, w), -- 5371
				self:sy(footY + p.h + 3, h) -- 5371
			), -- 5371
			Vec2( -- 5371
				self:sx(p.x + 8, w), -- 5371
				self:sy(footY + p.h + 3, h) -- 5371
			), -- 5371
			self:px(2), -- 5371
			STAND -- 5371
		) -- 5371
	elseif self.coverNear and not isChild then -- 5371
		draw:drawRect( -- 5374
			Rect( -- 5374
				self:sx(p.x - 3, w), -- 5374
				self:sy(footY + 1, h), -- 5374
				self:px(3), -- 5374
				self:px(3) -- 5374
			), -- 5374
			STAND -- 5374
		) -- 5374
	end -- 5374
	drawFigure( -- 5376
		draw, -- 5376
		self, -- 5376
		w, -- 5376
		h, -- 5376
		p, -- 5376
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5376
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5376
	) -- 5376
	local q = self.partner -- 5377
	if q.alive then -- 5377
		local childPartner = q.w == CHILD_W -- 5379
		drawFigure( -- 5380
			draw, -- 5380
			self, -- 5380
			w, -- 5380
			h, -- 5380
			q, -- 5380
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5380
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5380
		) -- 5380
	end -- 5380
	local i = 0 -- 5382
	do -- 5382
		i = 0 -- 5383
		while i < #self.enemies do -- 5383
			local e = self.enemies[i + 1] -- 5384
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5385
			local enemyY = e.y + (e.depth or 0) -- 5386
			self:drawBox( -- 5387
				draw, -- 5387
				w, -- 5387
				h, -- 5387
				e.x - e.w / 2, -- 5387
				e.x + e.w / 2, -- 5387
				enemyY, -- 5387
				enemyY + e.h, -- 5387
				col -- 5387
			) -- 5387
			if e.alive then -- 5387
				local ef = p.x >= e.x and 1 or -1 -- 5389
				if e.kind == "shield" then -- 5389
					local sh = (e.shieldHp or 0) > 0 -- 5391
					draw:drawRect( -- 5392
						Rect( -- 5392
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5392
							self:sy(enemyY, h), -- 5392
							self:px(6), -- 5392
							self:px(64) -- 5392
						), -- 5392
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5393
					) -- 5393
				elseif e.kind == "breaker" then -- 5393
					draw:drawSegment( -- 5395
						Vec2( -- 5395
							self:sx(e.x + ef * 12, w), -- 5395
							self:sy(enemyY + 8, h) -- 5395
						), -- 5395
						Vec2( -- 5396
							self:sx(e.x + ef * 22, w), -- 5396
							self:sy(enemyY + 46, h) -- 5396
						), -- 5396
						self:px(3), -- 5396
						Color(0.5, 0.36, 0.22, 1) -- 5396
					) -- 5396
				end -- 5396
			end -- 5396
			if e.alive and e.warnT > 0 then -- 5396
				local gunX = self:sx(e.x, w) -- 5401
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5402
				local aimX = self:sx(p.x, w) -- 5403
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5404
				local seg = 8 -- 5405
				local s = 0 -- 5406
				do -- 5406
					s = 0 -- 5407
					while s < seg do -- 5407
						local t0 = s / seg -- 5408
						local t1 = (s + 1) / seg -- 5409
						draw:drawSegment( -- 5410
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5411
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5412
							self:px(1), -- 5413
							DANGER -- 5413
						) -- 5413
						s = s + 2 -- 5407
					end -- 5407
				end -- 5407
			end -- 5407
			i = i + 1 -- 5383
		end -- 5383
	end -- 5383
	local k = 0 -- 5418
	do -- 5418
		k = 0 -- 5419
		while k < #self.room.marks do -- 5419
			do -- 5419
				local m = self.room.marks[k + 1] -- 5420
				if m.kind ~= 0 then -- 5420
					goto __continue993 -- 5422
				end -- 5422
				local on = self.checkpoint == m.x -- 5424
				local x = self:sx(m.x, w) -- 5425
				local y = self:sy(m.y, h) -- 5426
				draw:drawSegment( -- 5427
					Vec2(x, y), -- 5427
					Vec2( -- 5427
						x, -- 5427
						y + self:px(35) -- 5427
					), -- 5427
					self:px(1), -- 5427
					on and CHECK or INK_DIM -- 5427
				) -- 5427
				draw:drawDot( -- 5428
					Vec2( -- 5428
						x, -- 5428
						y + self:px(35) -- 5428
					), -- 5428
					self:px(2), -- 5428
					on and CHECK or INK_DIM -- 5428
				) -- 5428
			end -- 5428
			::__continue993:: -- 5428
			k = k + 1 -- 5419
		end -- 5419
	end -- 5419
	local j = 0 -- 5432
	do -- 5432
		j = 0 -- 5433
		while j < #self.room.marks do -- 5433
			do -- 5433
				local m = self.room.marks[j + 1] -- 5434
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5434
					goto __continue996 -- 5436
				end -- 5436
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5436
					goto __continue996 -- 5440
				end -- 5440
				local col = STAND -- 5442
				if m.kind == 4 then -- 5442
					col = PASS_LINE -- 5444
				elseif m.kind == 5 then -- 5444
					col = BRICK_LINE -- 5446
				end -- 5446
				local mx = self:sx(m.x, w) -- 5448
				local my = self:sy(m.y, h) -- 5449
				draw:drawSegment( -- 5450
					Vec2(mx, my), -- 5450
					Vec2( -- 5450
						mx, -- 5450
						my + self:px(24) -- 5450
					), -- 5450
					self:px(1), -- 5450
					col -- 5450
				) -- 5450
			end -- 5450
			::__continue996:: -- 5450
			j = j + 1 -- 5433
		end -- 5433
	end -- 5433
	local t = 0 -- 5453
	do -- 5453
		t = 0 -- 5454
		while t < #self.room.marks do -- 5454
			do -- 5454
				local m = self.room.marks[t + 1] -- 5455
				if m.kind ~= 6 then -- 5455
					goto __continue1002 -- 5457
				end -- 5457
				local mx = self:sx(m.x, w) -- 5459
				local my = self:sy(m.y, h) -- 5460
				draw:drawSegment( -- 5461
					Vec2(mx, my), -- 5461
					Vec2( -- 5461
						mx, -- 5461
						my + self:px(30) -- 5461
					), -- 5461
					self:px(1), -- 5461
					INK_DIM -- 5461
				) -- 5461
				self:drawBox( -- 5462
					draw, -- 5462
					w, -- 5462
					h, -- 5462
					m.x - 5, -- 5462
					m.x + 5, -- 5462
					m.y + 30, -- 5462
					m.y + 40, -- 5462
					CHECK -- 5462
				) -- 5462
			end -- 5462
			::__continue1002:: -- 5462
			t = t + 1 -- 5454
		end -- 5454
	end -- 5454
	if self.room.key == "village" then -- 5454
		self:drawVillage(draw, w, h) -- 5465
	end -- 5465
	if self.room.key == "forest" then -- 5465
		self:drawDog(draw, w, h) -- 5468
	end -- 5468
end -- 5362
function Play.prototype.drawDog(self, draw, w, h) -- 5473
	local x = self.dogX -- 5474
	self:drawBox( -- 5475
		draw, -- 5475
		w, -- 5475
		h, -- 5475
		x - 14, -- 5475
		x + 14, -- 5475
		0, -- 5475
		20, -- 5475
		SCAV_BODY -- 5475
	) -- 5475
	self:drawBox( -- 5476
		draw, -- 5476
		w, -- 5476
		h, -- 5476
		x - 10, -- 5476
		x - 2, -- 5476
		20, -- 5476
		30, -- 5476
		SCAV_BODY -- 5476
	) -- 5476
	self:drawBox( -- 5477
		draw, -- 5477
		w, -- 5477
		h, -- 5477
		x + 2, -- 5477
		x + 10, -- 5477
		20, -- 5477
		30, -- 5477
		SCAV_HEAD -- 5477
	) -- 5477
	if self.dogState == "ear" or self.dogState == "chase" then -- 5477
		draw:drawSegment( -- 5479
			Vec2( -- 5479
				self:sx(x, w), -- 5479
				self:sy(30, h) -- 5479
			), -- 5479
			Vec2( -- 5480
				self:sx(x, w), -- 5480
				self:sy(40, h) -- 5480
			), -- 5480
			self:px(1), -- 5480
			DANGER -- 5480
		) -- 5480
	end -- 5480
end -- 5473
function Play.prototype.drawVillage(self, draw, w, h) -- 5485
	local bottle = self.room.bottle -- 5486
	if bottle ~= nil then -- 5486
		self:drawBox( -- 5488
			draw, -- 5488
			w, -- 5488
			h, -- 5488
			bottle.x - 14, -- 5488
			bottle.x + 14, -- 5488
			0, -- 5488
			64, -- 5488
			SOLID_FILL -- 5488
		) -- 5488
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5488
			self:drawBottle( -- 5490
				draw, -- 5490
				w, -- 5490
				h, -- 5490
				bottle.x, -- 5490
				64 -- 5490
			) -- 5490
		end -- 5490
	end -- 5490
	self:drawBox( -- 5494
		draw, -- 5494
		w, -- 5494
		h, -- 5494
		300, -- 5494
		420, -- 5494
		44, -- 5494
		50, -- 5494
		FLOOR_DECK -- 5494
	) -- 5494
	self:drawBox( -- 5495
		draw, -- 5495
		w, -- 5495
		h, -- 5495
		300, -- 5495
		306, -- 5495
		0, -- 5495
		44, -- 5495
		FLOOR_DECK -- 5495
	) -- 5495
	self:drawBox( -- 5496
		draw, -- 5496
		w, -- 5496
		h, -- 5496
		414, -- 5496
		420, -- 5496
		0, -- 5496
		44, -- 5496
		FLOOR_DECK -- 5496
	) -- 5496
	local s = self.room.scavenger -- 5498
	if s ~= nil then -- 5498
		local sx0 = self.scavX -- 5500
		self:drawBox( -- 5501
			draw, -- 5501
			w, -- 5501
			h, -- 5501
			sx0 - 12, -- 5501
			sx0 + 12, -- 5501
			0, -- 5501
			s.h - 14, -- 5501
			SCAV_BODY -- 5501
		) -- 5501
		self:drawBox( -- 5502
			draw, -- 5502
			w, -- 5502
			h, -- 5502
			sx0 - 7, -- 5502
			sx0 + 7, -- 5502
			s.h - 14, -- 5502
			s.h, -- 5502
			SCAV_HEAD -- 5502
		) -- 5502
		if self.scavState == "turn" then -- 5502
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5504
			draw:drawSegment( -- 5505
				Vec2( -- 5505
					self:sx(sx0, w), -- 5505
					self:sy(s.h - 6, h) -- 5505
				), -- 5505
				Vec2( -- 5505
					self:sx(fx, w), -- 5505
					self:sy(s.h - 6, h) -- 5505
				), -- 5505
				self:px(1), -- 5505
				INK -- 5505
			) -- 5505
		end -- 5505
	end -- 5505
	if self.hasBottle then -- 5505
		local p = self.player -- 5510
		self:drawBottle( -- 5511
			draw, -- 5511
			w, -- 5511
			h, -- 5511
			p.x + p.facing * 10, -- 5511
			p.y + p.h * 0.62 -- 5511
		) -- 5511
	end -- 5511
	if self.bottleFly ~= nil then -- 5511
		self:drawBottle( -- 5514
			draw, -- 5514
			w, -- 5514
			h, -- 5514
			self.bottleFly.x, -- 5514
			self.bottleFly.y -- 5514
		) -- 5514
	end -- 5514
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5514
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5517
		draw:drawCircle( -- 5518
			Vec2( -- 5518
				self:sx(self.bottleLandX, w), -- 5518
				self:sy(0, h) -- 5518
			), -- 5518
			self:px(r / ____exports.UNITS_PER_PX), -- 5518
			BRICK_LINE -- 5518
		) -- 5518
	end -- 5518
end -- 5485
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5522
	self:drawBox( -- 5523
		draw, -- 5523
		w, -- 5523
		h, -- 5523
		x - 3, -- 5523
		x + 3, -- 5523
		y - 10, -- 5523
		y, -- 5523
		BOTTLE -- 5523
	) -- 5523
end -- 5522
function Play.prototype.drawTrace(self, draw, w, h) -- 5526
	local t = self.trace -- 5527
	if t == nil or self.traceT <= 0 then -- 5527
		return -- 5529
	end -- 5529
	draw:drawSegment( -- 5531
		Vec2( -- 5532
			self:sx(t.x0, w), -- 5532
			self:sy(t.y0, h) -- 5532
		), -- 5532
		Vec2( -- 5533
			self:sx(t.x1, w), -- 5533
			self:sy(t.y1, h) -- 5533
		), -- 5533
		self:px(1), -- 5534
		t.hit and AIM_HIT or INK_DIM -- 5534
	) -- 5534
end -- 5526
function Play.prototype.drawAim(self, draw, w, h) -- 5537
	local v = self.view -- 5539
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5540
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5541
	local dot = self:px(1) -- 5542
	local arm = self:px(3) -- 5543
	local gap = self:px(1) -- 5544
	draw:drawSegment( -- 5545
		Vec2(gx - arm - gap, gy), -- 5545
		Vec2(gx - gap, gy), -- 5545
		dot / 2, -- 5545
		AIM -- 5545
	) -- 5545
	draw:drawSegment( -- 5546
		Vec2(gx + gap, gy), -- 5546
		Vec2(gx + arm + gap, gy), -- 5546
		dot / 2, -- 5546
		AIM -- 5546
	) -- 5546
	draw:drawSegment( -- 5547
		Vec2(gx, gy - arm - gap), -- 5547
		Vec2(gx, gy - gap), -- 5547
		dot / 2, -- 5547
		AIM -- 5547
	) -- 5547
	draw:drawSegment( -- 5548
		Vec2(gx, gy + gap), -- 5548
		Vec2(gx, gy + arm + gap), -- 5548
		dot / 2, -- 5548
		AIM -- 5548
	) -- 5548
	if self.room.key == "village" and self.hasBottle then -- 5548
		local p = self.player -- 5552
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5554
		local dir = ____end.x >= p.x and 1 or -1 -- 5555
		local x0 = p.x + dir * 10 -- 5556
		local y0 = p.y + p.h * 0.7 -- 5557
		local T = BOTTLE_FLY_TIME -- 5558
		local vx = (____end.x - x0) / T -- 5559
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5560
		local pxr = x0 -- 5561
		local pyr = y0 -- 5562
		local t = 1 -- 5563
		do -- 5563
			t = 1 -- 5564
			while t <= 12 do -- 5564
				local tt = t / 12 * T -- 5565
				local nx = x0 + vx * tt -- 5566
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5567
				draw:drawSegment( -- 5568
					Vec2( -- 5568
						self:sx(pxr, w), -- 5568
						self:sy(pyr, h) -- 5568
					), -- 5568
					Vec2( -- 5568
						self:sx(nx, w), -- 5568
						self:sy(ny, h) -- 5568
					), -- 5568
					self:px(1) / 2, -- 5568
					BOTTLE -- 5568
				) -- 5568
				pxr = nx -- 5569
				pyr = ny -- 5570
				t = t + 1 -- 5564
			end -- 5564
		end -- 5564
		draw:drawCircle( -- 5572
			Vec2( -- 5572
				self:sx(____end.x, w), -- 5572
				self:sy(____end.y + 2, h) -- 5572
			), -- 5572
			self:px(2), -- 5572
			BOTTLE -- 5572
		) -- 5572
	end -- 5572
end -- 5537
return ____exports -- 5537