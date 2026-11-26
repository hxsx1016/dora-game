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
function makeActor(room, index) -- 5484
	local sp = room.spawns -- 5485
	if index < 0 or index >= #sp then -- 5485
		return { -- 5487
			x = 0, -- 5487
			y = 0, -- 5487
			depth = 0, -- 5487
			depthSpeed = 0, -- 5487
			vx = 0, -- 5487
			vy = 0, -- 5487
			w = CHILD_W, -- 5487
			h = CHILD_H, -- 5487
			onGround = true, -- 5487
			facing = 1, -- 5487
			crouch = false, -- 5487
			rollT = 0, -- 5487
			covered = false, -- 5487
			alive = false -- 5487
		} -- 5487
	end -- 5487
	local s = sp[index + 1] -- 5489
	local child = s.h <= CHILD_H -- 5490
	local ground = room.depth -- 5491
	local depth = ground == nil and 0 or math.max( -- 5492
		ground.min, -- 5492
		math.min(ground.max, s.depth or 0) -- 5492
	) -- 5492
	return { -- 5493
		x = s.x, -- 5494
		y = s.y, -- 5494
		depth = depth, -- 5494
		depthSpeed = 0, -- 5494
		vx = 0, -- 5494
		vy = 0, -- 5494
		w = child and CHILD_W or SOLDIER_W, -- 5495
		h = child and CHILD_H or SOLDIER_H, -- 5496
		onGround = true, -- 5497
		facing = 1, -- 5497
		crouch = false, -- 5497
		rollT = 0, -- 5497
		covered = false, -- 5497
		alive = true -- 5497
	} -- 5497
end -- 5497
function drawFigure(draw, play, w, h, a, body, head) -- 5501
	if not a.alive then -- 5501
		return -- 5503
	end -- 5503
	local x0 = a.x - a.w / 2 -- 5505
	local x1 = a.x + a.w / 2 -- 5506
	local y0 = a.y + a.depth -- 5507
	local y1 = y0 + a.h -- 5508
	play:drawBox( -- 5509
		draw, -- 5509
		w, -- 5509
		h, -- 5509
		x0, -- 5509
		x1, -- 5509
		y0, -- 5509
		y1 - a.h * 0.26, -- 5509
		body -- 5509
	) -- 5509
	play:drawBox( -- 5510
		draw, -- 5510
		w, -- 5510
		h, -- 5510
		x0 + 2, -- 5510
		x1 - 2, -- 5510
		y1 - a.h * 0.26, -- 5510
		y1, -- 5510
		head -- 5510
	) -- 5510
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 5512
	play:drawBox( -- 5513
		draw, -- 5513
		w, -- 5513
		h, -- 5513
		eyeX, -- 5513
		eyeX + 4, -- 5513
		y1 - a.h * 0.14, -- 5513
		y1 - a.h * 0.08, -- 5513
		INK -- 5513
	) -- 5513
end -- 5513
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 5517
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 5518
end -- 5517
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 5525
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 5526
end -- 5525
function rayInterval(origin, direction, min, max) -- 5533
	if direction == 0 then -- 5533
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 5535
	end -- 5535
	local a = (min - origin) / direction -- 5537
	local b = (max - origin) / direction -- 5538
	return { -- 5539
		min = math.min(a, b), -- 5539
		max = math.max(a, b) -- 5539
	} -- 5539
end -- 5539
function hitBox(ray, box) -- 5543
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 5544
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 5545
	local enter = math.max(0, x.min, y.min) -- 5546
	local leave = math.min(99999, x.max, y.max) -- 5547
	if box.depth ~= nil then -- 5547
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 5549
		enter = math.max(enter, depth.min) -- 5550
		leave = math.min(leave, depth.max) -- 5551
	end -- 5551
	return leave >= enter and enter or -1 -- 5553
end -- 5553
function drawCartShape(draw, play, w, h, c, axleX) -- 5556
	local half = c.bodyW / 2 -- 5557
	local x0 = axleX - half -- 5558
	local x1 = axleX + half -- 5559
	local axleY = c.baseY + (c.depth or 0) + c.wheelR -- 5560
	play:drawBox( -- 5561
		draw, -- 5561
		w, -- 5561
		h, -- 5561
		x0, -- 5561
		x1, -- 5561
		axleY, -- 5561
		axleY + c.bodyH, -- 5561
		CART_FILL -- 5561
	) -- 5561
	draw:drawCircle( -- 5562
		Vec2( -- 5562
			play:sx(x0 + c.bodyW * 0.28, w), -- 5562
			play:sy(axleY, h) -- 5562
		), -- 5562
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5562
		Color(52, 50, 48, 255) -- 5562
	) -- 5562
	draw:drawCircle( -- 5563
		Vec2( -- 5563
			play:sx(x1 - c.bodyW * 0.28, w), -- 5563
			play:sy(axleY, h) -- 5563
		), -- 5563
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 5563
		Color(52, 50, 48, 255) -- 5563
	) -- 5563
	local cx = c.clothSide < 0 and x0 or x1 -- 5564
	play:drawBox( -- 5565
		draw, -- 5565
		w, -- 5565
		h, -- 5565
		cx - 10, -- 5565
		cx + 10, -- 5565
		axleY + c.bodyH, -- 5565
		axleY + c.bodyH + 18, -- 5565
		CLOTH -- 5565
	) -- 5565
end -- 5565
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
CHILD_W = 28 -- 138
CHILD_H = 64 -- 139
local CHILD_CROUCH_H = 36 -- 140
local CHILD_SPEED = 160 -- 141
local CHILD_SLOW = 80 -- 142
local CHILD_JUMP = 320 -- 143
SOLDIER_W = 30 -- 146
SOLDIER_H = 88 -- 147
local SOLDIER_SPEED = 264 -- 148
local ROLL_TIME = 0.35 -- 149
local ROLL_SPEED = 280 -- 150
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 152
local LEDGE_RISE = 60 -- 153
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 156
____exports.LOGIC_H = 180 -- 157
____exports.UNITS_PER_PX = 2 -- 158
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 160
local CAM_FOLLOW = 9 -- 161
local CAM_LOOK_UP = 46 -- 162
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 165
--- 握把触发半径。
____exports.CART_REACH = 70 -- 167
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 169
local CART_CLEAR = 44 -- 170
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 172
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 174
local CONSUMABLE_CAP = 1 -- 175
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 177
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 179
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 181
local FIRE_COOLDOWN = 150 -- 182
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 184
local ENEMY_RANGE = 760 -- 185
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 187
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 189
local DEPTH_SPEED_RATIO = 0.55 -- 190
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 191
INK = Color(232, 232, 228, 255) -- 193
local INK_DIM = Color(150, 152, 150, 255) -- 194
local BG_VOID = Color(8, 9, 10, 255) -- 195
local BG_FAR = Color(24, 26, 28, 255) -- 196
local BG_MID = Color(31, 34, 37, 255) -- 197
local GROUND = Color(112, 114, 112, 255) -- 198
local FLOOR_DECK = Color(66, 70, 72, 255) -- 199
local SOLID_FILL = Color(84, 86, 84, 255) -- 200
local SOLID_EDGE = Color(126, 130, 126, 255) -- 201
CART_FILL = Color(122, 78, 56, 255) -- 202
CLOTH = Color(178, 52, 46, 255) -- 203
local DANGER = Color(150, 54, 48, 46) -- 204
local DANGER_LINE = Color(178, 78, 64, 200) -- 205
local HOLE_FILL = Color(10, 11, 12, 255) -- 206
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 207
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 208
local CHILD_BODY = Color(214, 168, 96, 255) -- 209
local CHILD_HEAD = Color(232, 214, 186, 255) -- 210
local ENEMY_BODY = Color(176, 92, 84, 255) -- 211
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 212
local CHECK = Color(96, 186, 122, 255) -- 213
local STAND = Color(226, 186, 84, 255) -- 214
local AIM = Color(236, 236, 232, 230) -- 215
local AIM_HIT = Color(236, 96, 84, 255) -- 216
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 218
local SOFT_LINE = Color(140, 112, 80, 190) -- 219
local BRICK = Color(126, 118, 110, 70) -- 220
local BRICK_LINE = Color(160, 152, 142, 200) -- 221
local PASS = Color(96, 186, 122, 40) -- 222
local PASS_LINE = Color(96, 186, 122, 200) -- 223
local BOTTLE = Color(120, 186, 160, 255) -- 224
local SCAV_BODY = Color(128, 118, 96, 255) -- 225
local SCAV_HEAD = Color(196, 182, 158, 255) -- 226
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 313
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 314
	if zoom < 1 then -- 314
		zoom = 1 -- 316
	end -- 316
	return { -- 318
		zoom = zoom, -- 319
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 320
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 321
	} -- 321
end -- 313
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 344
	if key == "prologue" then -- 344
		return "prologue-wait" -- 348
	end -- 348
	if key == "street" then -- 348
		return "street-run" -- 351
	end -- 351
	if key == "gate" then -- 351
		return "gate-idle" -- 354
	end -- 354
	if key == "gatepath" then -- 354
		return "gatepath-start" -- 357
	end -- 357
	if key == "forest" then -- 357
		return "forest-run" -- 360
	end -- 360
	if key == "tower" then -- 360
		return "tower-wait" -- 363
	end -- 363
	if key == "museum" then -- 363
		return "museum-cabinet" -- 366
	end -- 366
	return "run" -- 368
end -- 344
____exports.Play = __TS__Class() -- 371
local Play = ____exports.Play -- 371
Play.name = "Play" -- 371
function Play.prototype.____constructor(self, room, resume, run) -- 641
	self.enemies = {} -- 376
	self.boxes = {} -- 377
	self.floors = {} -- 378
	self.checkpoint = -1 -- 380
	self.flash = "" -- 382
	self.flashT = 0 -- 383
	self.traceT = 0 -- 386
	self.focusCart = false -- 388
	self.knocks = 0 -- 390
	self.knockT = 0 -- 391
	self.cartAxle = 0 -- 395
	self.cartDocked = false -- 397
	self.gripping = false -- 399
	self.gateOpen = false -- 401
	self.calmConsumed = false -- 403
	self.craftT = 0 -- 405
	self.nextDangerId = 1 -- 407
	self.wantRoom = "" -- 409
	self.carryCartAxle = -1 -- 411
	self.carryCartDocked = false -- 412
	self.checkpointCartAxle = -1 -- 414
	self.hasBottle = false -- 418
	self.bottleLandX = -1 -- 422
	self.bottleTargetX = -1 -- 423
	self.bottleTargetY = 0 -- 424
	self.bottleLandT = 0 -- 425
	self.aimHold = 0 -- 427
	self.redCartPulled = false -- 429
	self.footHintT = 0 -- 431
	self.ditchHinted = false -- 433
	self.forestPath = "" -- 435
	self.waterSeen = false -- 437
	self.scavX = 0 -- 439
	self.scavDir = 1 -- 440
	self.scavState = "patrol" -- 441
	self.scavT = 0 -- 442
	self.scavTargetX = 0 -- 443
	self.passed = false -- 445
	self.childMode = false -- 449
	self.phase = "" -- 451
	self.phaseTick = 0 -- 453
	self.gateTick = 0 -- 455
	self.countTick = 0 -- 457
	self.countArmed = false -- 459
	self.countPrevMove = 0 -- 461
	self.caughtT = 0 -- 463
	self.hp = 3 -- 465
	self.maxHp = 3 -- 466
	self.invulnT = 0 -- 472
	self.partnerStuck = 0 -- 474
	self.partnerLaneIdx = 0 -- 476
	self.partnerLaneHold = 0 -- 477
	self.coveredFlash = 0 -- 479
	self.coverHug = false -- 481
	self.coverNear = false -- 483
	self.coverEntity = "" -- 485
	self.coverBlocking = false -- 487
	self.gateNeedConfirm = false -- 489
	self.gateRestartArmed = true -- 491
	self.bottleAimX = -1 -- 493
	self.bottleAimY = 0 -- 494
	self.bottleSurfaceY = -1 -- 496
	self.bottleLandY = 0 -- 498
	self.events = {} -- 500
	self.eventSeq = 0 -- 502
	self.dogX = 0 -- 504
	self.dogDir = 1 -- 505
	self.dogState = "patrol" -- 506
	self.dogT = 0 -- 507
	self.dogTargetX = 0 -- 508
	self.scavSee = 0 -- 510
	self.scavChase = false -- 511
	self.gateSpawned = 0 -- 513
	self.gateFailCount = 0 -- 515
	self.isCampaign = false -- 519
	self.archiveDirty = false -- 527
	self.restartStory = false -- 529
	self.wellOpen = false -- 531
	self.wellX = 430 -- 533
	self.wellTaken = false -- 535
	self.museumReturn = false -- 537
	self.endingLines = {"", ""} -- 539
	self.equippedWeapon = "standard_gun" -- 543
	self.craftBench = { -- 545
		active = false, -- 546
		firstCraftDone = false, -- 547
		justCraftedTimer = 0, -- 548
		inventory = {}, -- 549
		recipes = {}, -- 550
		equippedWeapon = "standard_gun" -- 551
	} -- 551
	self.handledCraftRequests = {} -- 554
	self.benchReach = 48 -- 556
	self.pickups = {} -- 560
	self.reloadT = 0 -- 562
	self.objectiveDone = false -- 566
	self.hint = "" -- 568
	self.roomStartTick = 0 -- 570
	self.cartHitT = 0 -- 572
	self.cartExposed = false -- 573
	self.storyRoute = "" -- 577
	self.storySettled = false -- 579
	self.hpAtGate = -1 -- 581
	self.maxHpAtGate = -1 -- 582
	self.handTicks = 0 -- 584
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 586
	self.handArmed = false -- 588
	self.handDone = false -- 590
	self.lineSaid = false -- 591
	self.tied = false -- 593
	self.pathDone = false -- 595
	self.carryOn = false -- 597
	self.escortDone = false -- 599
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 603
	self.escapeRemaining = 0 -- 605
	self.escapeRetryCount = 0 -- 607
	self.introTick = 0 -- 609
	self.reloadOpen = false -- 613
	self.reloadAnswerTicks = 0 -- 615
	self.reloadWorldTicks = 0 -- 617
	self.reloadPath = {RELOAD_START} -- 619
	self.reloadPendingEffect = "" -- 621
	self.reloadTryCount = 0 -- 623
	self.paused = false -- 625
	self.ticks = 0 -- 627
	self.view = {zoom = 1, ox = 0, oy = 0} -- 629
	self.ox = 0 -- 631
	self.aimX = 0 -- 633
	self.aimY = 0 -- 634
	self.viewW = 0 -- 636
	self.viewH = 0 -- 637
	self.ox = room.originX -- 643
	self.room = withOrigin(room) -- 644
	local wr = self.room -- 645
	self.run = run or createRun() -- 646
	self.inventory = self.run.inventory -- 647
	self.archive = self.run.archive -- 648
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 649
	self.isCampaign = wr.campaign ~= nil -- 650
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 651
	self:buildWorld() -- 652
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 655
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 657
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 658
	local soloRoom = wr.key == "museum" -- 660
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 661
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 662
	self.player = makeActor(wr, playerIdx) -- 663
	self.partner = makeActor(wr, partnerIdx) -- 664
	self.phase = phaseOf(wr.key) -- 665
	if soloRoom then -- 665
		local mp = self.archive.museumPhase -- 668
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 669
	end -- 669
	if wr.story ~= nil then -- 669
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 675
	end -- 675
	self.cam.x = self.player.x -- 677
	self.cam.y = self.player.y + CAM_LOOK_UP -- 678
	self.cartAxle = wr.cart.startX -- 679
	self.escort = __TS__New( -- 680
		Escort, -- 680
		safeAnchorX(wr.marks) -- 680
	) -- 680
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 681
	if self.isCampaign then -- 681
		self:setupCampaign() -- 683
	else -- 683
		self:buildEnemies() -- 685
	end -- 685
	if resume ~= nil and resume.checkpoint > 0 then -- 685
		self.checkpoint = resume.checkpoint -- 689
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 689
			self.cartAxle = self.room.cart.endX -- 691
			self.cartDocked = true -- 692
			self.player.x = self.ox + 380 -- 695
			self.player.y = 0 -- 696
			self.player.vy = 0 -- 697
			self.player.onGround = true -- 698
			self.cam.x = self.player.x -- 699
			self.cam.y = self.player.y + CAM_LOOK_UP -- 700
		end -- 700
	end -- 700
	self:restoreStory() -- 703
end -- 641
function Play.prototype.recipeViews(self) -- 716
	local out = {} -- 717
	local i = 0 -- 718
	do -- 718
		i = 0 -- 719
		while i < #CRAFT_RECIPES do -- 719
			local r = CRAFT_RECIPES[i + 1] -- 720
			local cost = {} -- 721
			if r.cost.wood ~= nil then -- 721
				cost.wood = r.cost.wood -- 723
			end -- 723
			if r.cost.bell ~= nil then -- 723
				cost.bell = r.cost.bell -- 726
			end -- 726
			out[#out + 1] = { -- 728
				id = r.id, -- 729
				name = r.name, -- 730
				desc = r.desc, -- 731
				enhancedEffect = r.enhancedEffect, -- 732
				cost = cost, -- 733
				crafted = self.run.story.craftedWeapon == r.id -- 734
			} -- 734
			i = i + 1 -- 719
		end -- 719
	end -- 719
	return out -- 737
end -- 716
function Play.prototype.syncCraftBench(self) -- 741
	local view = self.craftBench -- 742
	local inv = self.run.inventory -- 743
	view.inventory = { -- 744
		wood = inv.wood, -- 744
		bell = inv.bell, -- 744
		scrap = inv.scrap, -- 744
		wedge = inv.wedge, -- 744
		ammo = inv.ammo -- 744
	} -- 744
	view.recipes = self:recipeViews() -- 745
	view.equippedWeapon = self.equippedWeapon -- 746
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 747
	if view.justCraftedTimer > 0 then -- 747
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 749
	end -- 749
end -- 741
function Play.prototype.openCraftBench(self) -- 754
	if self.room.key ~= "escort3" or self.craftBench.active then -- 754
		return -- 756
	end -- 756
	self.craftBench.active = true -- 758
	self.carryOn = false -- 759
	self.run.story.carry = false -- 760
	self.player.vx = 0 -- 761
	self.player.vy = 0 -- 762
	self.craftBench.justCraftedTimer = 0 -- 763
	self:syncCraftBench() -- 764
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 765
	self:log("开工台") -- 766
	self:emit( -- 767
		"benchOpen", -- 767
		{ -- 767
			recipes = __TS__ArrayMap( -- 768
				self.craftBench.recipes, -- 768
				function(____, r) return r.id end -- 768
			), -- 768
			inventory = self.craftBench.inventory, -- 769
			carry = self.carryOn -- 770
		} -- 770
	) -- 770
end -- 754
function Play.prototype.closeCraftBench(self) -- 775
	if not self.craftBench.active then -- 775
		return -- 777
	end -- 777
	self.craftBench.active = false -- 779
	self.craftBench.justCraftedTimer = 0 -- 780
	self.carryOn = true -- 781
	self.run.story.carry = true -- 782
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 783
	self:log("离站背起") -- 784
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 785
end -- 775
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 792
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 792
		return false -- 794
	end -- 794
	local recipe = findRecipe(recipeId) -- 796
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 796
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 798
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 799
		return false -- 800
	end -- 800
	local missing = missingMaterials(self.run.inventory, recipe) -- 802
	if #missing > 0 then -- 802
		self:flashSet( -- 804
			"缺料 · " .. table.concat(missing, " / "), -- 804
			1.6 -- 804
		) -- 804
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 805
		return false -- 806
	end -- 806
	payMaterials(self.run.inventory, recipe) -- 808
	self.handledCraftRequests[requestId] = true -- 809
	self.run.story.craftedWeapon = recipe.id -- 810
	self.equippedWeapon = recipe.id -- 811
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 812
	self.craftBench.firstCraftDone = true -- 813
	self:syncCraftBench() -- 814
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 815
	self:log("改制 " .. recipe.id) -- 816
	self:emit("benchCraft", { -- 817
		recipeId = recipe.id, -- 818
		weapon = recipe.id, -- 819
		effect = recipe.enhancedEffect, -- 820
		wood = self.run.inventory.wood, -- 821
		bell = self.run.inventory.bell -- 822
	}) -- 822
	return true -- 824
end -- 792
function Play.prototype.equipWeapon(self, weaponId) -- 828
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId then -- 828
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 830
		return false -- 831
	end -- 831
	self.equippedWeapon = weaponId -- 833
	self:syncCraftBench() -- 834
	self:flashSet( -- 835
		"已装备 " .. weaponNameOf(weaponId), -- 835
		1 -- 835
	) -- 835
	self:emit("benchEquip", {weapon = weaponId}) -- 836
	return true -- 837
end -- 828
function Play.prototype.submitFeIntent(self, intent) -- 844
	local kind = intent == nil and "" or intent.kind -- 845
	if kind == "reloadTapNode" then -- 845
		local node = intent.node -- 847
		if type(node) == "number" then -- 847
			self:reloadTapNode(node) -- 849
			return true -- 850
		end -- 850
		return false -- 852
	end -- 852
	if kind == "reloadPathCommit" then -- 852
		local path = intent.path -- 855
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 855
			local list = path -- 857
			local i = 0 -- 858
			do -- 858
				i = 0 -- 859
				while i < #list do -- 859
					do -- 859
						if i == 0 and list[i + 1] == RELOAD_START then -- 859
							goto __continue48 -- 861
						end -- 861
						self:reloadTapNode(list[i + 1]) -- 863
					end -- 863
					::__continue48:: -- 863
					i = i + 1 -- 859
				end -- 859
			end -- 859
			return true -- 865
		end -- 865
		return false -- 867
	end -- 867
	if kind == "reloadCancel" then -- 867
		self:closeReloadPuzzle() -- 870
		return true -- 871
	end -- 871
	if kind == "craftSubmit" then -- 871
		local recipeId = intent.recipeId -- 874
		local requestId = intent.requestId -- 875
		if type(recipeId) == "string" and type(requestId) == "string" then -- 875
			return self:craftAtBench(recipeId, requestId) -- 877
		end -- 877
		return false -- 879
	end -- 879
	if kind == "craftEquip" then -- 879
		local weaponId = intent.weaponId -- 882
		if type(weaponId) == "string" then -- 882
			return self:equipWeapon(weaponId) -- 884
		end -- 884
		return false -- 886
	end -- 886
	if kind == "craftClose" then -- 886
		self:closeCraftBench() -- 889
		return true -- 890
	end -- 890
	if kind == "wellPick" then -- 890
		return self:pickWell() -- 893
	end -- 893
	return false -- 895
end -- 844
function Play.prototype.captureCheckpoint(self, id) -- 899
	local inv = self.run.inventory -- 900
	self.checkpointSnap = { -- 901
		id = id, -- 902
		wood = inv.wood, -- 903
		bell = inv.bell, -- 904
		scrap = inv.scrap, -- 905
		wedge = inv.wedge, -- 906
		ammo = inv.ammo, -- 907
		shield = inv.shield, -- 908
		pass = inv.pass, -- 909
		quickbelt = inv.quickbelt, -- 910
		crafted = self.run.story.craftedWeapon, -- 911
		equipped = self.equippedWeapon, -- 912
		carry = self.carryOn -- 913
	} -- 913
	self.run.story.cp = self.checkpointSnap -- 915
end -- 899
function Play.prototype.applyCheckpointSnap(self, id) -- 919
	local snap = self.run.story.cp -- 920
	if snap == nil or snap.id ~= id then -- 920
		return false -- 922
	end -- 922
	self.checkpointSnap = snap -- 924
	local inv = self.run.inventory -- 925
	inv.wood = snap.wood -- 926
	inv.bell = snap.bell -- 927
	inv.scrap = snap.scrap -- 928
	inv.wedge = snap.wedge -- 929
	inv.ammo = snap.ammo -- 930
	inv.shield = snap.shield -- 931
	inv.pass = snap.pass -- 932
	inv.quickbelt = snap.quickbelt -- 933
	self.run.story.craftedWeapon = snap.crafted -- 934
	self.equippedWeapon = snap.equipped -- 935
	self.carryOn = snap.carry -- 936
	self.run.story.carry = snap.carry -- 937
	self.craftBench.active = false -- 938
	self:syncCraftBench() -- 939
	return true -- 940
end -- 919
function Play.prototype.restoreStory(self) -- 943
	if self.isCampaign and self.run.trial ~= nil then -- 943
		return -- 947
	end -- 947
	local story = self.run.story -- 949
	if story == nil then -- 949
		return -- 951
	end -- 951
	if story.maxHp > 0 then -- 951
		self.maxHp = story.maxHp -- 954
		self.hp = math.max( -- 955
			1, -- 955
			math.min(story.hp, story.maxHp) -- 955
		) -- 955
	end -- 955
	self.storyRoute = story.route -- 957
	self.storySettled = story.settled -- 958
	self.hpAtGate = story.hpAtGate -- 959
	self.maxHpAtGate = story.maxHpAtGate -- 960
	self.handDone = story.handDone -- 961
	self.lineSaid = story.lineSaid -- 962
	self.tied = story.handDone -- 963
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 964
	self.museumReturn = story.museumReturn -- 965
	story.museumReturn = false -- 966
	self.escortDone = story.escortDone -- 967
	self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 968
	self:syncCraftBench() -- 969
	if story.segments.outside_cart == true then -- 969
		self.redCartPulled = true -- 972
		local redBox = __TS__ArrayFind( -- 973
			self.boxes, -- 973
			function(____, b) return b.id == "outside_red_cart" end -- 973
		) -- 973
		if redBox ~= nil then -- 973
			redBox.x0 = 300 -- 975
			redBox.x1 = 344 -- 976
		end -- 976
	end -- 976
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 979
	self.waterSeen = story.segments.water_lantern == true -- 981
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 981
		self:applyCheckpointSnap(self.checkpoint) -- 984
	end -- 984
	if self.room.key == "tower" and story.route == "soldier" then -- 984
		self.carryOn = false -- 988
		self.run.story.carry = false -- 989
	end -- 989
	if self.room.key == "prologue" then -- 989
		local ph = story.phase -- 993
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 993
			self.phase = ph -- 995
			self.phaseTick = story.phaseTick -- 996
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 997
			self.player.y = 0 -- 998
			self.player.depth = 0 -- 999
			self.player.vx = 0 -- 1000
			self.partner.x = self.ox + 300 -- 1001
			self.partner.y = 0 -- 1002
			self.partner.depth = 0 -- 1003
			self.partner.vx = 0 -- 1004
			self.partner.alive = true -- 1005
			if ph == "prologue-follow" then -- 1005
				self.partner.crouch = false -- 1007
				self.partner.h = CHILD_H -- 1008
			else -- 1008
				self.partner.crouch = true -- 1010
				self.partner.h = CHILD_CROUCH_H -- 1011
			end -- 1011
			self.cam.x = self.player.x -- 1013
		end -- 1013
		return -- 1015
	end -- 1015
	if self.room.key ~= "gate" then -- 1015
		return -- 1018
	end -- 1018
	local ____temp_0 -- 1020
	if self.room.story == nil then -- 1020
		____temp_0 = nil -- 1020
	else -- 1020
		____temp_0 = self.room.story.gate -- 1020
	end -- 1020
	local g = ____temp_0 -- 1020
	if g == nil then -- 1020
		return -- 1022
	end -- 1022
	if story.phase == "gate-send" then -- 1022
		self.phase = "gate-send" -- 1026
		self.gateTick = g.holdTicks -- 1027
		self.gateSpawned = 4 -- 1028
		self.enemies = {} -- 1029
		self.player.x = self.ox + g.doorX - 40 -- 1030
		self.player.y = 0 -- 1031
		self.player.depth = 0 -- 1032
		self.player.vx = 0 -- 1033
		self.player.vy = 0 -- 1034
		self.player.onGround = true -- 1035
		self.partner.x = self.ox + g.waitX -- 1036
		self.partner.y = 0 -- 1037
		self.partner.depth = 0 -- 1038
		self.partner.alive = true -- 1039
		self.cam.x = self.player.x -- 1040
		self.handTicks = 0 -- 1041
		self.handArmed = false -- 1042
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1043
		return -- 1044
	end -- 1044
	if not story.settled then -- 1044
		return -- 1047
	end -- 1047
	self.gateTick = g.holdTicks -- 1050
	self.gateSpawned = 4 -- 1051
	self.enemies = {} -- 1052
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1052
		self.phase = story.phase -- 1054
		self.countTick = math.max(story.countTick, 0) -- 1055
		self:swapToChild(g.doorX + 30) -- 1056
		self.countPrevMove = 0 -- 1057
		self.countArmed = false -- 1058
		return -- 1059
	end -- 1059
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1059
		self.phase = story.phase -- 1062
		self.countTick = ____exports.GATE_COUNT_END -- 1063
		self.phaseTick = story.phaseTick -- 1064
		self:swapToChild(g.doorX + 30) -- 1065
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1066
			0, -- 1066
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1066
		) -- 1066
		self.handArmed = false -- 1067
	end -- 1067
end -- 943
function Play.prototype.buildWorld(self) -- 1072
	local room = self.room -- 1073
	self.boxes = {} -- 1074
	self.floors = {} -- 1075
	local i = 0 -- 1076
	do -- 1076
		i = 0 -- 1077
		while i < #room.floors do -- 1077
			local f = room.floors[i + 1] -- 1078
			local ____self_floors_1 = self.floors -- 1078
			____self_floors_1[#____self_floors_1 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1079
			i = i + 1 -- 1077
		end -- 1077
	end -- 1077
	do -- 1077
		i = 0 -- 1081
		while i < #room.solids do -- 1081
			local s = room.solids[i + 1] -- 1082
			if not s.decorative then -- 1082
				local ____self_boxes_13 = self.boxes -- 1088
				local ____s_x_4 = s.x -- 1089
				local ____temp_5 = s.x + s.w -- 1089
				local ____s_y_6 = s.y -- 1089
				local ____temp_7 = s.y + s.h -- 1089
				local ____temp_2 -- 1090
				if room.depth == nil then -- 1090
					____temp_2 = nil -- 1090
				else -- 1090
					____temp_2 = s.depth -- 1090
				end -- 1090
				local ____temp_8 = s.passable == true -- 1091
				local ____s_label_9 = s.label -- 1091
				local ____s_id_10 = s.id -- 1092
				local ____temp_11 = s.soft == true -- 1092
				local ____temp_12 = s.hidden == true -- 1092
				local ____temp_3 -- 1093
				if s.breakable == nil then -- 1093
					____temp_3 = nil -- 1093
				else -- 1093
					____temp_3 = __TS__ObjectAssign({}, s.breakable) -- 1093
				end -- 1093
				____self_boxes_13[#____self_boxes_13 + 1] = { -- 1088
					x0 = ____s_x_4, -- 1089
					x1 = ____temp_5, -- 1089
					y0 = ____s_y_6, -- 1089
					y1 = ____temp_7, -- 1089
					depth = ____temp_2, -- 1090
					passable = ____temp_8, -- 1091
					label = ____s_label_9, -- 1091
					id = ____s_id_10, -- 1092
					soft = ____temp_11, -- 1092
					hidden = ____temp_12, -- 1092
					breakable = ____temp_3, -- 1093
					interact = s.interact -- 1094
				} -- 1094
			end -- 1094
			i = i + 1 -- 1081
		end -- 1081
	end -- 1081
	do -- 1081
		i = 0 -- 1098
		while i < #room.stairs do -- 1098
			local st = room.stairs[i + 1] -- 1099
			local n = st.steps + 1 -- 1100
			local stepW = (st.x1 - st.x0) / n -- 1101
			local k = 0 -- 1102
			do -- 1102
				k = 0 -- 1103
				while k < n do -- 1103
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1104
					local x0 = st.x0 + stepW * k -- 1105
					local ____self_boxes_14 = self.boxes -- 1105
					____self_boxes_14[#____self_boxes_14 + 1] = { -- 1107
						x0 = x0, -- 1107
						x1 = x0 + stepW, -- 1107
						y0 = -8, -- 1107
						y1 = y, -- 1107
						passable = true -- 1107
					} -- 1107
					k = k + 1 -- 1103
				end -- 1103
			end -- 1103
			i = i + 1 -- 1098
		end -- 1098
	end -- 1098
end -- 1072
function Play.prototype.setupCampaign(self) -- 1116
	local wr = self.room -- 1117
	local c = wr.campaign -- 1118
	if c == nil then -- 1118
		return -- 1120
	end -- 1120
	self.roomStartTick = self.run.ticks -- 1122
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1122
		self.run.joined = true -- 1126
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1126
		local ____self_run_16 = self.run -- 1129
		local ____temp_15 -- 1129
		if wr.key == "s2-drygoods" then -- 1129
			____temp_15 = self.run.route ~= "drygoods" -- 1129
		else -- 1129
			____temp_15 = false -- 1129
		end -- 1129
		____self_run_16.joined = ____temp_15 -- 1129
	end -- 1129
	local x = wr.minX + 60 -- 1131
	local y = 0 -- 1132
	local depth = 0 -- 1133
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1133
		x = wr.minX + 210 -- 1135
		depth = -32 -- 1136
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1136
		x = wr.minX + 40 -- 1138
		y = 32 -- 1139
		depth = 32 -- 1140
	end -- 1140
	self.player = { -- 1142
		x = x, -- 1143
		y = y, -- 1143
		depth = depth, -- 1143
		depthSpeed = 0, -- 1143
		vx = 0, -- 1143
		vy = 0, -- 1143
		w = SOLDIER_W, -- 1144
		h = SOLDIER_H, -- 1144
		onGround = y <= 0, -- 1144
		facing = 1, -- 1144
		crouch = false, -- 1144
		rollT = 0, -- 1144
		covered = false, -- 1144
		alive = true -- 1144
	} -- 1144
	self.partner = { -- 1146
		x = x + 60, -- 1147
		y = y, -- 1147
		depth = depth, -- 1147
		depthSpeed = 0, -- 1147
		vx = 0, -- 1147
		vy = 0, -- 1147
		w = CHILD_W, -- 1148
		h = CHILD_H, -- 1148
		onGround = y <= 0, -- 1148
		facing = 1, -- 1148
		crouch = false, -- 1148
		rollT = 0, -- 1148
		covered = false, -- 1148
		alive = true -- 1148
	} -- 1148
	self.cam.x = x -- 1150
	self.cam.y = y + CAM_LOOK_UP -- 1151
	self.phase = "run" -- 1152
	self.hp = self.maxHp -- 1153
	local trial = self.run.trial -- 1154
	if trial ~= nil then -- 1154
		draftRoom(trial, wr.key) -- 1156
		self.maxHp = self.maxHp + trial.ranks.vitality -- 1157
		self.hp = trial.hp -- 1158
	end -- 1158
	self:buildEnemies() -- 1160
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1161
	local i = 0 -- 1162
	do -- 1162
		i = 0 -- 1163
		while i < #self.boxes do -- 1163
			do -- 1163
				local b = self.boxes[i + 1] -- 1164
				if b.id == nil then -- 1164
					goto __continue97 -- 1166
				end -- 1166
				local st = self.run.props[b.id] -- 1168
				if st ~= nil then -- 1168
					b.broken = st.broken -- 1170
					local ____temp_17 -- 1171
					if b.breakable == nil then -- 1171
						____temp_17 = nil -- 1171
					else -- 1171
						____temp_17 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1171
					end -- 1171
					b.breakable = ____temp_17 -- 1171
					b.hidden = b.hidden == true and st.revealed ~= true -- 1172
					if b.hidden then -- 1172
						b.broken = true -- 1174
					end -- 1174
				elseif b.hidden == true then -- 1174
					b.broken = true -- 1178
				end -- 1178
			end -- 1178
			::__continue97:: -- 1178
			i = i + 1 -- 1163
		end -- 1163
	end -- 1163
	if wr.cart.bodyW > 0 then -- 1163
		self.cartAxle = wr.cart.startX -- 1182
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1182
			self.cartAxle = wr.cart.endX -- 1184
			self.cartDocked = true -- 1185
		end -- 1185
	end -- 1185
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1188
end -- 1116
function Play.prototype.log(self, line) -- 1191
	local ____self_run_log_18 = self.run.log -- 1191
	____self_run_log_18[#____self_run_log_18 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1192
	if #self.run.log > 120 then -- 1192
		table.remove(self.run.log, 1) -- 1194
	end -- 1194
end -- 1191
function Play.prototype.buildEnemies(self) -- 1198
	self.enemies = {} -- 1199
	if self.isCampaign then -- 1199
		local i = 0 -- 1201
		do -- 1201
			i = 0 -- 1202
			while i < #self.room.spawns do -- 1202
				local sp = self.room.spawns[i + 1] -- 1203
				local kind = sp.kind or "gunner" -- 1204
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1205
				local ____self_enemies_19 = self.enemies -- 1205
				____self_enemies_19[#____self_enemies_19 + 1] = { -- 1206
					x = sp.x, -- 1207
					y = sp.y, -- 1207
					depth = sp.depth, -- 1207
					w = 26, -- 1207
					h = sp.h, -- 1207
					alive = true, -- 1207
					hitT = 0, -- 1207
					warnT = 0, -- 1207
					fireCd = 40, -- 1207
					kind = kind, -- 1208
					shieldHp = hp, -- 1208
					shieldHpMax = hp, -- 1208
					drop = sp.drop or "none", -- 1208
					homeX = sp.x, -- 1209
					swingT = 0, -- 1209
					awake = false, -- 1209
					squad = i -- 1209
				} -- 1209
				i = i + 1 -- 1202
			end -- 1202
		end -- 1202
		return -- 1212
	end -- 1212
	if self.room.key == "checkpoint" then -- 1212
		local ____self_enemies_20 = self.enemies -- 1212
		____self_enemies_20[#____self_enemies_20 + 1] = { -- 1215
			x = self.ox + 430, -- 1215
			y = 0, -- 1215
			w = 26, -- 1215
			h = 84, -- 1215
			alive = true, -- 1215
			hitT = 0, -- 1215
			warnT = 0, -- 1215
			fireCd = 0 -- 1215
		} -- 1215
		local ____self_enemies_21 = self.enemies -- 1215
		____self_enemies_21[#____self_enemies_21 + 1] = { -- 1216
			x = self.ox + 505, -- 1216
			y = 0, -- 1216
			w = 26, -- 1216
			h = 84, -- 1216
			alive = true, -- 1216
			hitT = 0, -- 1216
			warnT = 0, -- 1216
			fireCd = 0 -- 1216
		} -- 1216
		return -- 1217
	end -- 1217
	if self.room.key == "street" then -- 1217
		local ____self_enemies_22 = self.enemies -- 1217
		____self_enemies_22[#____self_enemies_22 + 1] = { -- 1221
			x = self.ox + 340, -- 1221
			y = 0, -- 1221
			w = 26, -- 1221
			h = 84, -- 1221
			alive = true, -- 1221
			hitT = 0, -- 1221
			warnT = 0, -- 1221
			fireCd = 0 -- 1221
		} -- 1221
		local ____self_enemies_23 = self.enemies -- 1221
		____self_enemies_23[#____self_enemies_23 + 1] = { -- 1222
			x = self.ox + 560, -- 1222
			y = 0, -- 1222
			w = 26, -- 1222
			h = 84, -- 1222
			alive = true, -- 1222
			hitT = 0, -- 1222
			warnT = 0, -- 1222
			fireCd = 0 -- 1222
		} -- 1222
	end -- 1222
end -- 1198
function Play.prototype.emit(self, name, data) -- 1228
	local ____self_events_24 = self.events -- 1228
	____self_events_24[#____self_events_24 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1229
	self.eventSeq = self.eventSeq + 1 -- 1230
	if #self.events > 256 then -- 1230
		table.remove(self.events, 1) -- 1232
	end -- 1232
end -- 1228
function Play.prototype.drainEvents(self) -- 1240
	local out = self.events -- 1241
	self.events = {} -- 1242
	return out -- 1243
end -- 1240
function Play.prototype.adoptEvents(self, events) -- 1252
	if #events == 0 then -- 1252
		return -- 1254
	end -- 1254
	local keep = {} -- 1256
	local i = 0 -- 1257
	do -- 1257
		i = 0 -- 1258
		while i < #events do -- 1258
			do -- 1258
				local e = events[i + 1] -- 1259
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1259
					goto __continue118 -- 1261
				end -- 1261
				keep[#keep + 1] = e -- 1263
			end -- 1263
			::__continue118:: -- 1263
			i = i + 1 -- 1258
		end -- 1258
	end -- 1258
	if #keep == 0 then -- 1258
		return -- 1266
	end -- 1266
	self.events = __TS__ArrayConcat(keep, self.events) -- 1268
	do -- 1268
		i = 0 -- 1269
		while i < #self.events do -- 1269
			self.events[i + 1].seq = i -- 1270
			i = i + 1 -- 1269
		end -- 1269
	end -- 1269
	self.eventSeq = #self.events -- 1272
end -- 1252
function Play.prototype.chooseTalent(self, slot) -- 1275
	local trial = self.run.trial -- 1276
	local talent = trial and trial.offers[slot + 1] -- 1277
	if trial == nil or talent == nil or trial.lost or self.run.finished then -- 1277
		return -- 1278
	end -- 1278
	local ____trial_ranks_27, ____talent_28 = trial.ranks, talent -- 1278
	____trial_ranks_27[____talent_28] = ____trial_ranks_27[____talent_28] + 1 -- 1279
	trial.offers = {} -- 1280
	if talent == "vitality" then -- 1280
		self.maxHp = self.maxHp + 1 -- 1282
		self.hp = self.hp + 1 -- 1283
		trial.hp = self.hp -- 1284
	end -- 1284
	self:flashSet(talentNames[talent], 1.2) -- 1286
end -- 1275
function Play.prototype.beginReload(self) -- 1294
	self.reloadT = self:reloadTicks() -- 1295
	local camp = self.room.campaign -- 1296
	if self.run.trial == nil and camp ~= nil and camp.reloadPuzzle == true then -- 1296
		self:openReloadPuzzle() -- 1299
	end -- 1299
end -- 1294
function Play.prototype.openReloadPuzzle(self) -- 1304
	self.reloadOpen = true -- 1305
	self.reloadAnswerTicks = 0 -- 1306
	self.reloadWorldTicks = 0 -- 1307
	self.reloadPath = {RELOAD_START} -- 1308
	self.reloadPendingEffect = "" -- 1309
	self.reloadTryCount = self.reloadTryCount + 1 -- 1310
	self:emit("reloadOpen", {tryCount = self.reloadTryCount, needTicks = RELOAD_ANSWER_TICKS}) -- 1311
end -- 1304
function Play.prototype.closeReloadPuzzle(self) -- 1315
	self.reloadOpen = false -- 1316
	self.reloadAnswerTicks = 0 -- 1317
	self.reloadWorldTicks = 0 -- 1318
	self.reloadPath = {RELOAD_START} -- 1319
	self.reloadPendingEffect = "" -- 1320
end -- 1315
function Play.prototype.reloadTapNode(self, node) -- 1327
	if not self.reloadOpen then -- 1327
		return -- 1329
	end -- 1329
	local path = self.reloadPath -- 1331
	local last = path[#path] -- 1332
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1332
		self.reloadPath = {RELOAD_START} -- 1334
		self:emit("reloadInvalid", {node = node, at = last}) -- 1335
		return -- 1336
	end -- 1336
	path[#path + 1] = node -- 1338
	if node ~= RELOAD_TARGET then -- 1338
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1340
		return -- 1341
	end -- 1341
	if not reloadPathValid(path) then -- 1341
		self.reloadPath = {RELOAD_START} -- 1344
		self:emit("reloadInvalid", {node = node, at = last}) -- 1345
		return -- 1346
	end -- 1346
	self.reloadPendingEffect = reloadEffectOf(path) -- 1348
	self.reloadOpen = false -- 1349
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1350
	self:flashSet( -- 1353
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1353
		1.4 -- 1353
	) -- 1353
end -- 1327
function Play.prototype.consumeReloadEffect(self) -- 1357
	local e = self.reloadPendingEffect -- 1358
	if e ~= "" then -- 1358
		self.reloadPendingEffect = "" -- 1360
	end -- 1360
	return e -- 1362
end -- 1357
function Play.prototype.echoToSource(self, from, count) -- 1369
	if count == nil then -- 1369
		count = 1 -- 1369
	end -- 1369
	local best = -1 -- 1370
	local bestD = 1000000000 -- 1371
	local i = 0 -- 1372
	local woken = {} -- 1373
	local n = 0 -- 1374
	while n < count do -- 1374
		best = -1 -- 1376
		bestD = 1000000000 -- 1377
		do -- 1377
			i = 0 -- 1378
			while i < #self.enemies do -- 1378
				do -- 1378
					if woken[i] == true then -- 1378
						goto __continue140 -- 1380
					end -- 1380
					local e = self.enemies[i + 1] -- 1382
					if not e.alive then -- 1382
						goto __continue140 -- 1384
					end -- 1384
					local d = math.abs(e.x - from.x) -- 1386
					if d < bestD then -- 1386
						bestD = d -- 1388
						best = i -- 1389
					end -- 1389
				end -- 1389
				::__continue140:: -- 1389
				i = i + 1 -- 1378
			end -- 1378
		end -- 1378
		if best < 0 then -- 1378
			break -- 1393
		end -- 1393
		woken[best] = true -- 1395
		local e = self.enemies[best + 1] -- 1396
		e.awake = true -- 1397
		e.warnT = 0 -- 1398
		e.fireCd = math.max(e.fireCd or 0, 60) -- 1399
		n = n + 1 -- 1400
	end -- 1400
	if n == 0 then -- 1400
		return -- 1403
	end -- 1403
	self:flashSet(n > 1 and "回声引到两处声源 · 他们同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1405
end -- 1369
function Play.prototype.reloadTicks(self) -- 1408
	local ____temp_31 = self.run.inventory.quickbelt > 0 and 36 or 54 -- 1409
	local ____opt_29 = self.run.trial -- 1409
	return math.max(6, ____temp_31 - 6 * (____opt_29 and ____opt_29.ranks.reload or 0)) -- 1409
end -- 1408
function Play.prototype.update(self, dt, input) -- 1412
	self:syncCraftBench() -- 1413
	local trial = self.run.trial -- 1414
	if trial ~= nil and (#trial.offers > 0 or trial.lost or self.run.finished) then -- 1414
		return -- 1415
	end -- 1415
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1415
		self:closeCraftBench() -- 1417
		return -- 1418
	end -- 1418
	if input.pause.pressed then -- 1418
		self.paused = not self.paused -- 1421
	end -- 1421
	if self.flashT > 0 then -- 1421
		self.flashT = self.flashT - dt -- 1424
		if self.flashT <= 0 then -- 1424
			self.flash = "" -- 1426
		end -- 1426
	end -- 1426
	if self.traceT > 0 then -- 1426
		self.traceT = self.traceT - dt -- 1430
		if self.traceT <= 0 then -- 1430
			self.trace = nil -- 1432
		end -- 1432
	end -- 1432
	if self.paused then -- 1432
		self:updateCamera(dt) -- 1436
		return -- 1437
	end -- 1437
	if self.craftBench.active then -- 1437
		self:updateCamera(dt) -- 1442
		return -- 1443
	end -- 1443
	if self.reloadOpen then -- 1443
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1449
		if self.reloadAnswerTicks > RELOAD_ANSWER_TICKS then -- 1449
			self.reloadOpen = false -- 1451
			self.reloadPendingEffect = "" -- 1452
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = RELOAD_ANSWER_TICKS}) -- 1453
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1454
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1454
			self:updateCamera(dt) -- 1456
			return -- 1457
		else -- 1457
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1459
		end -- 1459
	end -- 1459
	self.ticks = self.ticks + 1 -- 1463
	if self.invulnT > 0 then -- 1463
		self.invulnT = self.invulnT - 1 -- 1467
	end -- 1467
	if self.isCampaign then -- 1467
		local ____self_run_32, ____ticks_33 = self.run, "ticks" -- 1467
		____self_run_32[____ticks_33] = ____self_run_32[____ticks_33] + 1 -- 1470
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1471
	end -- 1471
	local p = self.player -- 1473
	self:stepPlayer(p, dt, input) -- 1474
	self:refreshCover(p, input) -- 1476
	if self.carryOn then -- 1476
		self:carryPose() -- 1478
	end -- 1478
	if self.isCampaign then -- 1478
		self:stepCampaign(dt, input) -- 1481
		if not self.carryOn then -- 1481
			self:stepCampaignPartner(dt) -- 1483
		end -- 1483
	end -- 1483
	if trial == nil or not self.run.finished then -- 1483
		self:stepEnemies(dt, input) -- 1491
	end -- 1491
	if trial ~= nil then -- 1491
		trial.hp = self.hp -- 1493
	end -- 1493
	if not self.isCampaign then -- 1493
		self:stepStory(dt, input) -- 1495
		self:stepEscort(dt, input) -- 1496
		self:stepVillage(dt, input) -- 1497
		self:stepChase(dt, input) -- 1498
		self:stepInteract(dt, input) -- 1499
	end -- 1499
	self:updateGate() -- 1501
	self:updateCamera(dt) -- 1502
	self:syncStory() -- 1504
end -- 1412
function Play.prototype.underLowArch(self, a) -- 1511
	local arch = self.room.arch -- 1512
	if arch.h <= 0 then -- 1512
		return false -- 1514
	end -- 1514
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1514
		return false -- 1517
	end -- 1517
	local top = arch.y + arch.h -- 1519
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1520
end -- 1511
function Play.prototype.coverAt(self, a) -- 1527
	local best = nil -- 1528
	local bestGap = 24 -- 1529
	local half = a.w / 2 -- 1530
	local i = 0 -- 1531
	do -- 1531
		i = 0 -- 1532
		while i < #self.boxes do -- 1532
			do -- 1532
				local b = self.boxes[i + 1] -- 1533
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1533
					goto __continue174 -- 1535
				end -- 1535
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1535
					goto __continue174 -- 1538
				end -- 1538
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1540
				if gap < bestGap then -- 1540
					bestGap = gap -- 1542
					best = b -- 1543
				end -- 1543
			end -- 1543
			::__continue174:: -- 1543
			i = i + 1 -- 1532
		end -- 1532
	end -- 1532
	return best -- 1546
end -- 1527
function Play.prototype.nearCover(self, a) -- 1549
	return self:coverAt(a) ~= nil -- 1550
end -- 1549
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1554
	if enemy == nil then -- 1554
		return false -- 1556
	end -- 1556
	local fromRight = enemy.x >= a.x -- 1558
	local edge = fromRight and b.x0 or b.x1 -- 1559
	local ____fromRight_34 -- 1560
	if fromRight then -- 1560
		____fromRight_34 = edge >= a.x - 0.001 and edge <= enemy.x -- 1560
	else -- 1560
		____fromRight_34 = edge <= a.x + 0.001 and edge >= enemy.x -- 1561
	end -- 1561
	local between = ____fromRight_34 -- 1560
	local separation = enemy.x - a.x -- 1562
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1563
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1564
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1565
end -- 1554
function Play.prototype.nearestEnemy(self, a) -- 1568
	local best -- 1569
	local bestD = 1000000000 -- 1570
	local i = 0 -- 1571
	do -- 1571
		i = 0 -- 1572
		while i < #self.enemies do -- 1572
			do -- 1572
				local e = self.enemies[i + 1] -- 1573
				if not e.alive then -- 1573
					goto __continue183 -- 1575
				end -- 1575
				local d = math.abs(e.x - a.x) -- 1577
				if d < bestD then -- 1577
					bestD = d -- 1579
					best = e -- 1580
				end -- 1580
			end -- 1580
			::__continue183:: -- 1580
			i = i + 1 -- 1572
		end -- 1572
	end -- 1572
	return best -- 1583
end -- 1568
function Play.prototype.refreshCover(self, a, input) -- 1587
	if self.childMode then -- 1587
		self.coverNear = false -- 1589
		self.coverHug = false -- 1590
		self.coverEntity = "" -- 1591
		self.coverBlocking = false -- 1592
		a.covered = false -- 1593
		return -- 1594
	end -- 1594
	local b = self:coverAt(a) -- 1596
	self.coverNear = b ~= nil -- 1597
	a.covered = self.coverNear and input.cover.held -- 1598
	self.coverHug = a.covered -- 1599
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 1600
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 1601
		b, -- 1601
		a, -- 1601
		self:nearestEnemy(a) -- 1601
	) -- 1601
end -- 1587
function Play.prototype.cartHandleInReach(self, a) -- 1605
	if a == nil then -- 1605
		a = self.player -- 1605
	end -- 1605
	local c = self.room.cart -- 1606
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 1606
		return false -- 1608
	end -- 1608
	local handleX = self.cartAxle + c.handleOffset -- 1610
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 1611
end -- 1605
function Play.prototype.nearLowLedge(self, a) -- 1616
	local reach = 26 -- 1617
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 1618
	local x1 = x0 + reach -- 1619
	local i = 0 -- 1620
	do -- 1620
		i = 0 -- 1621
		while i < #self.boxes do -- 1621
			do -- 1621
				local b = self.boxes[i + 1] -- 1622
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1622
					goto __continue192 -- 1624
				end -- 1624
				local rise = b.y1 - a.y -- 1626
				if rise > 0 and rise <= LEDGE_RISE then -- 1626
					return true -- 1628
				end -- 1628
			end -- 1628
			::__continue192:: -- 1628
			i = i + 1 -- 1621
		end -- 1621
	end -- 1621
	return false -- 1631
end -- 1616
function Play.prototype.stepPlayer(self, a, dt, input) -- 1634
	a.depthSpeed = 0 -- 1635
	if not a.alive then -- 1635
		return -- 1637
	end -- 1637
	local isChild = self.childMode -- 1639
	local lowArch = isChild and self:underLowArch(a) -- 1641
	if self:storyLocked() then -- 1641
		a.vx = 0 -- 1644
		a.crouch = isChild and lowArch -- 1645
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1646
		self:fallY(a, dt) -- 1647
		return -- 1648
	end -- 1648
	if not isChild and self.escort.state == "calming" then -- 1648
		a.crouch = false -- 1652
		a.h = SOLDIER_H -- 1653
		a.vx = 0 -- 1654
		self:fallY(a, dt) -- 1655
		return -- 1656
	end -- 1656
	a.crouch = isChild and (input.crouch.held or lowArch) and a.onGround -- 1658
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 1659
	local nearCover = not isChild and self:nearCover(a) -- 1660
	a.covered = nearCover and input.cover.held -- 1661
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 1663
	if a.rollT > 0 then -- 1663
		a.rollT = a.rollT - dt -- 1667
		a.vx = a.facing * ROLL_SPEED -- 1668
		self:slideX(a, a.vx * dt) -- 1669
		self:fallY(a, dt) -- 1670
		if a.rollT <= 0 then -- 1670
			self:flashSet("翻滚结束", 0.5) -- 1672
		end -- 1672
		return -- 1674
	end -- 1674
	if not isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 1674
		if input.moveX ~= 0 then -- 1674
			a.facing = input.moveX > 0 and 1 or -1 -- 1679
		end -- 1679
		if self:nearLowLedge(a) then -- 1679
			a.vy = SOLDIER_JUMP -- 1683
			a.onGround = false -- 1684
			self:flashSet("翻上去", 0.3) -- 1685
			return -- 1686
		end -- 1686
		a.rollT = ROLL_TIME -- 1688
		self:flashSet("翻滚", 0.3) -- 1689
		return -- 1690
	end -- 1690
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 1693
	if isChild then -- 1693
		if input.cover.held then -- 1693
			speed = CHILD_SLOW -- 1696
		end -- 1696
		if a.crouch then -- 1696
			speed = CHILD_SLOW -- 1699
		end -- 1699
	elseif a.covered then -- 1699
		speed = SOLDIER_SPEED * 0.45 -- 1702
	end -- 1702
	local handsBusy = self.gripping or gripIntent -- 1706
	local dir = self.gripping and 0 or input.moveX -- 1707
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 1709
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 1711
	if dir ~= 0 then -- 1711
		a.facing = dir > 0 and 1 or -1 -- 1713
	end -- 1713
	a.vx = dir * speed * diagonal -- 1715
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 1715
		a.vy = CHILD_JUMP -- 1719
		a.onGround = false -- 1720
		self:flashSet("跳", 0.25) -- 1721
	end -- 1721
	local previousDepth = a.depth -- 1725
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 1726
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1727
	self:slideX(a, a.vx * dt) -- 1728
	self:fallY(a, dt) -- 1729
	if not isChild and not self.gripping and not gripIntent and input.fire.pressed then -- 1729
		self:shoot(a) -- 1733
	end -- 1733
end -- 1634
function Play.prototype.stepPartner(self, p, dt) -- 1738
	local a = self.partner -- 1739
	if not a.alive then -- 1739
		return -- 1741
	end -- 1741
	a.crouch = false -- 1743
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 1744
	a.vx = 0 -- 1745
	a.depthSpeed = 0 -- 1746
	self:fallY(a, dt) -- 1747
end -- 1738
function Play.prototype.stepEscort(self, dt, input) -- 1754
	local a = self.partner -- 1755
	a.depthSpeed = 0 -- 1756
	if not a.alive then -- 1756
		return -- 1758
	end -- 1758
	if self.room.key == "gatepath" then -- 1758
		if self.carryOn then -- 1758
			return -- 1763
		end -- 1763
		local p = self.player -- 1766
		a.depth = p.depth -- 1767
		a.facing = p.facing -- 1768
		a.crouch = false -- 1769
		a.h = CHILD_H -- 1770
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 1771
		a.y = p.y -- 1772
		a.vy = 0 -- 1773
		a.vx = p.vx -- 1774
		a.onGround = p.onGround -- 1775
		return -- 1776
	end -- 1776
	if not self:escortOn() then -- 1776
		a.vx = 0 -- 1779
		self:fallY(a, dt) -- 1780
		return -- 1781
	end -- 1781
	local p = self.player -- 1783
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 1784
	local hadKnock1 = self.escort.knock1 -- 1785
	local hadKnock2 = self.escort.knock2 -- 1786
	self.calmConsumed = self.escort:update( -- 1787
		input, -- 1787
		p.x, -- 1787
		p.facing, -- 1787
		a.x, -- 1787
		dist -- 1787
	) -- 1787
	if not hadKnock1 and self.escort.knock1 then -- 1787
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 1790
	end -- 1790
	if not hadKnock2 and self.escort.knock2 then -- 1790
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 1793
	end -- 1793
	a.crouch = self.escort.crouchPose -- 1795
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 1796
	if not self.escort.stopped then -- 1796
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 1798
		local previousDepth = a.depth -- 1799
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 1800
		local distance = math.max( -- 1801
			-travel, -- 1801
			math.min(travel, targetDepth - previousDepth) -- 1801
		) -- 1801
		self:slideDepth(a, distance) -- 1802
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 1803
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 1803
			a.vy = CHILD_JUMP -- 1805
			a.onGround = false -- 1806
		end -- 1806
	end -- 1806
	local dir = self.escort:moveDir(a.x) -- 1809
	a.vx = dir * CHILD_SPEED -- 1810
	if dir ~= 0 then -- 1810
		a.facing = dir -- 1812
		local before = a.x -- 1813
		self:slideX(a, dir * CHILD_SPEED * dt) -- 1814
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 1814
			a.vy = CHILD_JUMP -- 1817
			a.onGround = false -- 1818
		end -- 1818
	end -- 1818
	self:fallY(a, dt) -- 1821
end -- 1754
function Play.prototype.escortOn(self) -- 1825
	if self.room.key == "checkpoint" then -- 1825
		return true -- 1827
	end -- 1827
	if self.room.key == "gatepath" then -- 1827
		return true -- 1830
	end -- 1830
	if self.room.key == "prologue" then -- 1830
		return self.phase == "prologue-follow" -- 1833
	end -- 1833
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 1833
		return true -- 1837
	end -- 1837
	return self.room.key == "street" -- 1839
end -- 1825
function Play.prototype.storyLocked(self) -- 1843
	if self.caughtT > 0 then -- 1843
		return true -- 1845
	end -- 1845
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 1845
		return true -- 1849
	end -- 1849
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 1849
		return true -- 1852
	end -- 1852
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 1852
		return true -- 1855
	end -- 1855
	if self.room.key == "tower" and self.phase ~= "tower-wait" then -- 1855
		return true -- 1858
	end -- 1858
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 1858
		return true -- 1861
	end -- 1861
	if self.craftBench.active then -- 1861
		return true -- 1865
	end -- 1865
	return false -- 1867
end -- 1843
function Play.prototype.swapToChild(self, x) -- 1871
	local tmp = self.player -- 1872
	self.player = self.partner -- 1873
	self.partner = tmp -- 1874
	self.childMode = true -- 1875
	self.player.alive = true -- 1876
	self.player.x = self.ox + x -- 1877
	self.player.y = 0 -- 1878
	self.player.depth = 0 -- 1879
	self.player.depthSpeed = 0 -- 1880
	self.player.vy = 0 -- 1881
	self.player.vx = 0 -- 1882
	self.player.onGround = true -- 1883
	self.player.crouch = false -- 1884
	self.player.h = CHILD_H -- 1885
	self.player.facing = 1 -- 1886
	self.partner.alive = true -- 1887
	self.cam.x = self.player.x -- 1888
end -- 1871
function Play.prototype.swapToSoldier(self, x, childX) -- 1892
	local tmp = self.player -- 1893
	self.player = self.partner -- 1894
	self.partner = tmp -- 1895
	self.childMode = false -- 1896
	self.player.alive = true -- 1897
	self.player.x = self.ox + x -- 1898
	self.player.y = 0 -- 1899
	self.player.depth = 0 -- 1900
	self.player.depthSpeed = 0 -- 1901
	self.player.vy = 0 -- 1902
	self.player.vx = 0 -- 1903
	self.player.onGround = true -- 1904
	self.player.crouch = false -- 1905
	self.player.h = SOLDIER_H -- 1906
	self.player.facing = 1 -- 1907
	self.partner.alive = true -- 1908
	self.partner.x = self.ox + childX -- 1909
	self.partner.y = 0 -- 1910
	self.partner.depth = 0 -- 1911
	self.partner.depthSpeed = 0 -- 1912
	self.partner.vx = 0 -- 1913
	self.partner.vy = 0 -- 1914
	self.partner.onGround = true -- 1915
	self.partner.crouch = true -- 1916
	self.partner.h = CHILD_CROUCH_H -- 1917
	self.cam.x = self.player.x -- 1918
end -- 1892
function Play.prototype.stepStory(self, dt, input) -- 1922
	if self.room.key == "prologue" then -- 1922
		self:stepPrologue(dt, input) -- 1924
	elseif self.room.key == "street" then -- 1924
		self:stepStreet(dt, input) -- 1926
	elseif self.room.key == "gate" then -- 1926
		self:stepGate(dt, input) -- 1928
	elseif self.room.key == "gatepath" then -- 1928
		self:stepGatePath() -- 1930
	elseif self.room.key == "tower" then -- 1930
		self:stepTower(dt, input) -- 1932
	elseif self.room.key == "museum" then -- 1932
		self:stepMuseum(dt, input) -- 1934
	end -- 1934
end -- 1922
function Play.prototype.canPersistProgress(self) -- 1940
	return not self.isCampaign and self.run.source == "official" -- 1941
end -- 1940
function Play.prototype.wellWindow(self) -- 1945
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 1946
end -- 1945
function Play.prototype.nearWell(self) -- 1951
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 1952
end -- 1951
function Play.prototype.pickWell(self) -- 1960
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 1960
		return false -- 1962
	end -- 1962
	self.phase = "prologue-well" -- 1964
	self.phaseTick = 0 -- 1965
	self.wellOpen = false -- 1966
	self:flashSet("井沿 · 伸手下去", 1.4) -- 1967
	self:log("旧井拾取") -- 1968
	return true -- 1969
end -- 1960
function Play.prototype.stepPrologue(self, dt, input) -- 1972
	local child = self.partner -- 1973
	if self.museumReturn then -- 1973
		self.museumReturn = false -- 1976
		self.phase = "prologue-wait" -- 1977
		self.phaseTick = 0 -- 1978
		self.player.x = self.ox + 260 -- 1979
		self.player.y = 0 -- 1980
		self.player.depth = 0 -- 1981
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 1982
	end -- 1982
	if self.phase == "prologue-wake" then -- 1982
		self.introTick = self.introTick + 1 -- 1986
		if self.introTick == 60 then -- 1986
			self:flashSet("门外有人唤 · 小满", 1.2) -- 1988
		end -- 1988
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 1988
			self.phase = "prologue-shadow" -- 1991
			self.introTick = 0 -- 1992
			self:flashSet("门缝里两道影子", 1.2) -- 1993
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 1994
		end -- 1994
		return -- 1996
	end -- 1996
	if self.phase == "prologue-shadow" then -- 1996
		self.introTick = self.introTick + 1 -- 1999
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 1999
			self.phase = "prologue-escape" -- 2002
			self.introTick = 0 -- 2003
			self.escapeRemaining = self.escapeDuration -- 2004
			self.escapeRetryCount = 0 -- 2005
			self:swapToChild(100) -- 2006
			self:flashSet( -- 2007
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2007
				1.6 -- 2007
			) -- 2007
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2008
		end -- 2008
		return -- 2012
	end -- 2012
	if self.phase == "prologue-escape" then -- 2012
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2015
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2015
			self.phase = "prologue-hide" -- 2018
			self.introTick = 0 -- 2019
			self.player.vx = 0 -- 2020
			self.player.crouch = true -- 2021
			self.player.h = CHILD_CROUCH_H -- 2022
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2023
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2024
			return -- 2028
		end -- 2028
		if self.escapeRemaining <= 0 then -- 2028
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2032
			self.player.x = self.ox + 100 -- 2033
			self.player.y = 0 -- 2034
			self.player.depth = 0 -- 2035
			self.player.vx = 0 -- 2036
			self.player.vy = 0 -- 2037
			self.escapeRemaining = self.escapeDuration -- 2038
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2039
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2040
			return -- 2041
		end -- 2041
		return -- 2043
	end -- 2043
	if self.phase == "prologue-hide" then -- 2043
		self.introTick = self.introTick + 1 -- 2046
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2046
			self.phase = "prologue-wait" -- 2049
			self.phaseTick = 0 -- 2050
			self.introTick = 0 -- 2051
			self:swapToSoldier(260, 300) -- 2052
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2053
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2054
		end -- 2054
		return -- 2056
	end -- 2056
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2059
	if self.phase == "prologue-wait" then -- 2059
		child.crouch = true -- 2061
		child.h = CHILD_CROUCH_H -- 2062
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2062
			self:pickWell() -- 2064
			return -- 2065
		end -- 2065
		if not self.wellOpen and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2065
			if self:canPersistProgress() then -- 2065
				self.archive.museumPhase = "well_reflect" -- 2071
				self.archiveDirty = true -- 2072
			end -- 2072
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2074
			return -- 2075
		end -- 2075
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2077
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2079
		if near and input.interact.pressed then -- 2079
			self.phase = "prologue-give" -- 2081
			self.phaseTick = 0 -- 2082
			self:flashSet("递出针套", 1) -- 2083
		end -- 2083
		return -- 2085
	end -- 2085
	if self.phase == "prologue-well" then -- 2085
		self.phaseTick = self.phaseTick + 1 -- 2089
		if self.phaseTick == 12 then -- 2089
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2091
		elseif self.phaseTick >= 30 then -- 2091
			self.phase = "prologue-wait" -- 2093
			self.phaseTick = 0 -- 2094
			self.wellTaken = true -- 2095
			self.wellOpen = false -- 2096
			self.run.archive.artifactOwned = true -- 2097
			self.archiveDirty = true -- 2098
			self:emit("artifactFound", { -- 2099
				x = self.ox + self.wellX, -- 2100
				y = 0, -- 2100
				room = "prologue", -- 2100
				once = true, -- 2100
				source = self.run.source -- 2101
			}) -- 2101
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2103
			self:log("井底取到时间穿梭器") -- 2104
		end -- 2104
		return -- 2106
	end -- 2106
	if self.phase == "prologue-give" then -- 2106
		self.phaseTick = self.phaseTick + 1 -- 2109
		if self.phaseTick == 12 then -- 2109
			self:flashSet("针套递过去", 0.7) -- 2111
		elseif self.phaseTick == 36 then -- 2111
			self:flashSet("纸条塞进针套", 0.9) -- 2113
		elseif self.phaseTick >= 60 then -- 2113
			self.phase = "prologue-follow" -- 2115
			self.phaseTick = 0 -- 2116
			child.crouch = false -- 2117
			child.h = CHILD_H -- 2118
			self:flashSet("她跟上了", 1.2) -- 2119
		end -- 2119
		return -- 2121
	end -- 2121
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2121
		self:requestRoom("street", "序章跟到门口") -- 2125
		self:flashSet("进街道", 1.2) -- 2126
	end -- 2126
end -- 1972
function Play.prototype.stepStreet(self, dt, input) -- 2131
	local p = self.player -- 2132
	local c = self.partner -- 2133
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2133
		self:requestRoom("checkpoint", "两人都到街尾") -- 2135
		self:flashSet("到检查站", 1.2) -- 2136
	end -- 2136
end -- 2131
function Play.prototype.stepGate(self, dt, input) -- 2141
	local ____temp_35 -- 2142
	if self.room.story == nil then -- 2142
		____temp_35 = nil -- 2142
	else -- 2142
		____temp_35 = self.room.story.gate -- 2142
	end -- 2142
	local g = ____temp_35 -- 2142
	if g == nil then -- 2142
		return -- 2144
	end -- 2144
	local p = self.player -- 2146
	if self.phase == "gate-idle" then -- 2146
		local a = self.partner -- 2149
		local gap = g.waitX - a.x -- 2150
		if math.abs(gap) > 3 then -- 2150
			a.facing = gap > 0 and 1 or -1 -- 2152
			a.vx = a.facing * CHILD_SPEED -- 2153
			local beforeX = a.x -- 2154
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2155
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2155
				a.vy = CHILD_JUMP -- 2157
				a.onGround = false -- 2158
			end -- 2158
			self:fallY(a, dt) -- 2160
		else -- 2160
			a.vx = 0 -- 2162
			a.x = g.waitX -- 2163
		end -- 2163
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2166
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2167
		if self.gateNeedConfirm then -- 2167
			if not input.interact.held then -- 2167
				self.gateRestartArmed = true -- 2172
			end -- 2172
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2172
				self.gateNeedConfirm = false -- 2175
				self.gateRestartArmed = true -- 2176
				self.phase = "gate-hold" -- 2177
				self.gateTick = 0 -- 2178
				self.gateSpawned = 0 -- 2179
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2180
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2181
			end -- 2181
			return -- 2183
		end -- 2183
		if atWinch and atWait then -- 2183
			self.phase = "gate-hold" -- 2186
			self.gateTick = 0 -- 2187
			self.gateSpawned = 0 -- 2188
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2189
		end -- 2189
		return -- 2191
	end -- 2191
	if self.phase == "gate-hold" then -- 2191
		self.gateTick = self.gateTick + 1 -- 2194
		local marks = {0, 540, 900, 1500} -- 2196
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2196
			local idx = self.gateSpawned -- 2198
			local ____self_enemies_36 = self.enemies -- 2198
			____self_enemies_36[#____self_enemies_36 + 1] = { -- 2199
				x = self.ox + 620 + idx * 62, -- 2200
				y = 0, -- 2200
				w = 26, -- 2200
				h = 84, -- 2200
				alive = true, -- 2201
				hitT = 0, -- 2201
				warnT = 0, -- 2201
				fireCd = 90 + idx * 45 -- 2201
			} -- 2201
			self.gateSpawned = self.gateSpawned + 1 -- 2203
			self:flashSet( -- 2204
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2204
				0.9 -- 2204
			) -- 2204
		end -- 2204
		if self.gateTick == 900 then -- 2204
			self:flashSet("灯灭了", 1) -- 2207
		elseif self.gateTick == 2100 then -- 2207
			self:flashSet("门底压下来了", 1) -- 2209
		end -- 2209
		if self.gateTick >= g.holdTicks then -- 2209
			self:captureGateBlood() -- 2214
			self.phase = "gate-send" -- 2215
			self.phaseTick = 0 -- 2216
			self.enemies = {} -- 2218
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2219
		end -- 2219
		return -- 2221
	end -- 2221
	if self.phase == "gate-send" then -- 2221
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2224
		if near and input.interact.pressed then -- 2224
			self:commitRoute() -- 2227
			self:swapToChild(g.doorX + 30) -- 2228
			self.phase = "gate-count" -- 2229
			self.countTick = 0 -- 2230
			self.countArmed = false -- 2232
			self.countPrevMove = input.moveX -- 2233
			self:flashSet("门开了 · 送她出去", 1.8) -- 2234
		end -- 2234
		return -- 2236
	end -- 2236
	if self.phase == "gate-count" then -- 2236
		self.countTick = self.countTick + 1 -- 2239
		if self.countTick == 360 then -- 2239
			self:flashSet("门关上", 0.9) -- 2241
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2241
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2243
			if self.storyRoute == "soldier" then -- 2243
				self.phase = "gate-wait" -- 2249
				self.phaseTick = 0 -- 2250
				self.knocks = 1 -- 2251
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2252
				self.handArmed = not input.interact.held -- 2254
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2255
			else -- 2255
				self:flashSet("数到二十", 2.2) -- 2257
			end -- 2257
		end -- 2257
		local prevMove = self.countPrevMove -- 2262
		self.countPrevMove = input.moveX -- 2263
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2263
			if prevMove <= 0 and input.moveX > 0 then -- 2263
				self.countArmed = true -- 2266
			end -- 2266
			if self.countArmed and input.moveX > 0 then -- 2266
				self.phase = "gate-walk" -- 2269
				self.phaseTick = 0 -- 2270
				self:flashSet("她迈出第一步", 1.4) -- 2271
				self:emit("storyExit", { -- 2272
					route = "child", -- 2272
					via = "walk", -- 2272
					countTick = self.countTick, -- 2272
					hp = self.hp, -- 2272
					maxHp = self.maxHp -- 2272
				}) -- 2272
			end -- 2272
		end -- 2272
		return -- 2275
	end -- 2275
	if self.phase == "gate-wait" then -- 2275
		self.phaseTick = self.phaseTick + 1 -- 2279
		if self.phaseTick == 12 then -- 2279
			self.knocks = 2 -- 2281
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2282
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2283
		end -- 2283
		if not input.interact.held then -- 2283
			if self.handTicks > 0 then -- 2283
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2287
			end -- 2287
			self.handTicks = 0 -- 2289
			self.handArmed = true -- 2290
			return -- 2291
		end -- 2291
		if self.handArmed then -- 2291
			self.handTicks = self.handTicks + 1 -- 2294
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2294
				self.phase = "gate-hand" -- 2296
				self.phaseTick = 0 -- 2297
				self.handDone = true -- 2298
				self.tied = true -- 2299
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2300
				if not self.lineSaid then -- 2300
					self.lineSaid = true -- 2302
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2303
				end -- 2303
				self:flashSet("我们走吧。", 3) -- 2305
			end -- 2305
		end -- 2305
		return -- 2308
	end -- 2308
	if self.phase == "gate-hand" then -- 2308
		self.phaseTick = self.phaseTick + 1 -- 2312
		if self.phaseTick == 30 then -- 2312
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2314
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2314
			self:emit("storyExit", { -- 2316
				route = "soldier", -- 2316
				via = "hand", -- 2316
				handTicks = self.handTicks, -- 2316
				hp = self.hp, -- 2316
				maxHp = self.maxHp -- 2316
			}) -- 2316
			self:requestRoom("gatepath", "牵手同行") -- 2317
		end -- 2317
		return -- 2319
	end -- 2319
	if self.phase == "gate-walk" then -- 2319
		if self.player.x >= g.exitX then -- 2319
			self:requestRoom("outside", "走出城门") -- 2324
			self:flashSet("出城门 · 城外", 1.4) -- 2325
		end -- 2325
	end -- 2325
end -- 2141
function Play.prototype.captureGateBlood(self) -- 2334
	self.hpAtGate = self.hp -- 2335
	self.maxHpAtGate = self.maxHp -- 2336
end -- 2334
function Play.prototype.commitRoute(self) -- 2343
	if self.storySettled then -- 2343
		return -- 2345
	end -- 2345
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2347
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2348
	self.hpAtGate = hp -- 2349
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2350
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2351
	self.storySettled = true -- 2352
	self:emit("storyRouteLocked", { -- 2353
		route = self.storyRoute, -- 2354
		hp = self.hp, -- 2354
		maxHp = self.maxHp, -- 2354
		hpAtGate = self.hpAtGate, -- 2355
		maxHpAtGate = self.maxHpAtGate -- 2355
	}) -- 2355
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2357
end -- 2343
function Play.prototype.syncStory(self) -- 2361
	if self.isCampaign and self.run.trial ~= nil then -- 2361
		return -- 2363
	end -- 2363
	local s = self.run.story -- 2365
	if s == nil then -- 2365
		return -- 2367
	end -- 2367
	s.hp = self.hp -- 2369
	s.maxHp = self.maxHp -- 2370
	s.route = self.storyRoute -- 2371
	s.settled = self.storySettled -- 2372
	s.hpAtGate = self.hpAtGate -- 2373
	s.maxHpAtGate = self.maxHpAtGate -- 2374
	s.handDone = self.handDone -- 2375
	s.lineSaid = self.lineSaid -- 2376
	s.tied = self.tied -- 2377
	s.carry = self.carryOn -- 2378
	s.museumReturn = self.museumReturn -- 2379
	s.escortDone = self.escortDone -- 2380
	s.craftedWeapon = self.run.story.craftedWeapon -- 2381
	s.ending = self.run.story.ending -- 2382
	if self.room.key == "gate" then -- 2382
		s.phase = self.phase -- 2384
		s.countTick = self.countTick -- 2385
		s.phaseTick = self.phaseTick -- 2386
		s.handTicks = self.handTicks -- 2387
	end -- 2387
	if self.room.key == "prologue" then -- 2387
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2387
			s.phase = self.phase -- 2392
			s.phaseTick = self.phaseTick -- 2393
		end -- 2393
	end -- 2393
end -- 2361
function Play.prototype.stepGatePath(self) -- 2399
	local ____temp_37 -- 2400
	if self.room.story == nil then -- 2400
		____temp_37 = nil -- 2400
	else -- 2400
		____temp_37 = self.room.story.gatepath -- 2400
	end -- 2400
	local gp = ____temp_37 -- 2400
	if self.phase == "gatepath-start" then -- 2400
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2400
			self.carryOn = true -- 2403
			self.phase = "gatepath-carry" -- 2404
			self.phaseTick = 0 -- 2405
			self.pathDone = true -- 2406
			self.escortDone = false -- 2407
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2408
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2409
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2410
		end -- 2410
		return -- 2412
	end -- 2412
	if self.phase == "gatepath-carry" then -- 2412
		self.phaseTick = self.phaseTick + 1 -- 2415
		if self.phaseTick == 20 then -- 2415
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2417
		end -- 2417
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2417
			self:requestRoom(gp.next, "背负进首战") -- 2420
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2421
		end -- 2421
	end -- 2421
end -- 2399
function Play.prototype.carryPose(self) -- 2430
	local p = self.player -- 2431
	local a = self.partner -- 2432
	a.alive = true -- 2433
	a.x = p.x - p.facing * 12 -- 2434
	a.y = p.y + 26 -- 2435
	a.depth = p.depth -- 2436
	a.vx = p.vx -- 2437
	a.vy = 0 -- 2438
	a.onGround = true -- 2439
	a.crouch = false -- 2440
	a.h = CHILD_CROUCH_H -- 2441
	a.facing = p.facing -- 2442
end -- 2430
function Play.prototype.stepMuseum(self, dt, input) -- 2450
	self.partner.alive = false -- 2451
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2452
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2455
	if self.phase == "museum-cabinet" then -- 2455
		if atCase and input.interact.pressed then -- 2455
			self.phase = "museum-hall" -- 2458
			self.phaseTick = 0 -- 2459
			if self:canPersistProgress() then -- 2459
				self.archive.museumPhase = "hall_walk" -- 2461
				self.archiveDirty = true -- 2462
			end -- 2462
			self:emit( -- 2464
				"museumStep", -- 2464
				{ -- 2464
					step = "cabinet", -- 2464
					x = self.ox + mu.cabinetX, -- 2464
					persisted = self:canPersistProgress() -- 2464
				} -- 2464
			) -- 2464
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2465
		end -- 2465
		return -- 2467
	end -- 2467
	if self.phase == "museum-hall" then -- 2467
		if self.player.x >= self.ox + mu.hallX and input.interact.pressed then -- 2467
			self.phase = "museum-lamp" -- 2471
			self.phaseTick = 0 -- 2472
			if self:canPersistProgress() then -- 2472
				self.archive.museumPhase = "lamp_turn" -- 2474
				self.archiveDirty = true -- 2475
			end -- 2475
			self:emit( -- 2477
				"museumStep", -- 2477
				{ -- 2477
					step = "hall", -- 2477
					x = self.ox + mu.hallX, -- 2477
					persisted = self:canPersistProgress() -- 2477
				} -- 2477
			) -- 2477
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2478
		end -- 2478
		return -- 2480
	end -- 2480
	if self.phase == "museum-lamp" then -- 2480
		if self.player.x >= self.ox + mu.lampX and input.interact.pressed then -- 2480
			self.phase = "museum-return" -- 2484
			self.phaseTick = 0 -- 2485
			if self:canPersistProgress() then -- 2485
				self.archive.museumPhase = "return_cabinet" -- 2487
				self.archiveDirty = true -- 2488
			end -- 2488
			self:emit( -- 2490
				"museumStep", -- 2490
				{ -- 2490
					step = "lamp", -- 2490
					x = self.ox + mu.lampX, -- 2490
					persisted = self:canPersistProgress() -- 2490
				} -- 2490
			) -- 2490
			self:flashSet("灯 · 转向西窗", 1.8) -- 2491
		end -- 2491
		return -- 2493
	end -- 2493
	if self.phase == "museum-return" then -- 2493
		if atCase and input.interact.pressed then -- 2493
			self.phase = "museum-knock" -- 2497
			self.phaseTick = 0 -- 2498
			self:emit( -- 2499
				"museumStep", -- 2499
				{ -- 2499
					step = "knock", -- 2499
					count = 1, -- 2499
					x = self.ox + mu.cabinetX, -- 2499
					persisted = self:canPersistProgress() -- 2499
				} -- 2499
			) -- 2499
			self:flashSet("回柜边 · 第一下", 0.8) -- 2500
		end -- 2500
		return -- 2502
	end -- 2502
	if self.phase == "museum-knock" then -- 2502
		self.phaseTick = self.phaseTick + 1 -- 2505
		if self.phaseTick == 8 then -- 2505
			self:emit( -- 2507
				"museumStep", -- 2507
				{ -- 2507
					step = "knock", -- 2507
					count = 2, -- 2507
					x = self.ox + mu.cabinetX, -- 2507
					persisted = self:canPersistProgress() -- 2507
				} -- 2507
			) -- 2507
			self:flashSet("回柜边 · 第二下", 0.8) -- 2508
		elseif self.phaseTick >= 36 then -- 2508
			self.phase = "museum-done" -- 2510
			self.phaseTick = 0 -- 2511
			if self:canPersistProgress() then -- 2511
				self.archive.museumSeen = true -- 2513
				self.archive.museumPhase = "done" -- 2514
				self.archiveDirty = true -- 2515
			end -- 2515
			self:emit( -- 2517
				"museumDone", -- 2517
				{ -- 2517
					steps = 4, -- 2517
					museumSeen = self.archive.museumSeen, -- 2517
					persisted = self:canPersistProgress() -- 2517
				} -- 2517
			) -- 2517
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2518
			self:log("博物馆 · 回柜边") -- 2519
		end -- 2519
		return -- 2521
	end -- 2521
	if input.interact.pressed then -- 2521
		self.museumReturn = true -- 2524
		self:requestRoom("prologue", "回柜边") -- 2525
	end -- 2525
end -- 2450
function Play.prototype.stepTower(self, dt, input) -- 2529
	local ____temp_38 -- 2530
	if self.room.story == nil then -- 2530
		____temp_38 = nil -- 2530
	else -- 2530
		____temp_38 = self.room.story.tower -- 2530
	end -- 2530
	local t = ____temp_38 -- 2530
	if t == nil then -- 2530
		return -- 2532
	end -- 2532
	if self.phase == "tower-wait" then -- 2532
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 2535
		if near and input.interact.pressed then -- 2535
			self.phase = "tower-knock" -- 2537
			self.phaseTick = 0 -- 2538
			self.knocks = 1 -- 2539
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 2540
			self:flashSet("敲一下", 0.6) -- 2541
		end -- 2541
		return -- 2543
	end -- 2543
	if self.phase == "tower-knock" then -- 2543
		self.phaseTick = self.phaseTick + 1 -- 2546
		if self.phaseTick == 12 then -- 2546
			self.knocks = 2 -- 2548
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 2549
			self:flashSet("敲两下 · 第二声", 1) -- 2550
		elseif self.phaseTick >= t.knockTicks then -- 2550
			self.phase = "tower-given" -- 2552
			self.phaseTick = 0 -- 2553
			self:flashSet("门开了 · 提灯", 1.4) -- 2554
		end -- 2554
		return -- 2556
	end -- 2556
	if self.phase == "tower-given" then -- 2556
		local soldier = self.storyRoute == "soldier" -- 2561
		self.phaseTick = self.phaseTick + 1 -- 2562
		if self.phaseTick == 60 then -- 2562
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 2564
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 2565
		elseif self.phaseTick == 120 then -- 2565
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 2567
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 2567
			self.phase = "tower-end" -- 2569
			self.phaseTick = 0 -- 2570
			if not self.run.finished then -- 2570
				self.run.finished = true -- 2572
				local ending = soldier and "reunion" or "lamp" -- 2573
				self.run.story.ending = ending -- 2574
				local ____soldier_39 -- 2577
				if soldier then -- 2577
					____soldier_39 = self.run.story.segments.escort5 == true -- 2578
				else -- 2578
					____soldier_39 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 2579
				end -- 2579
				local played = ____soldier_39 -- 2577
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 2580
				if official then -- 2580
					if soldier then -- 2580
						self.run.archive.soldierCleared = true -- 2584
					else -- 2584
						self.run.archive.childCleared = true -- 2586
					end -- 2586
					self.archiveDirty = true -- 2588
				end -- 2588
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 2590
				self:emit("endingReached", { -- 2591
					route = soldier and "soldier" or "child", -- 2592
					ending = ending, -- 2593
					official = official, -- 2594
					source = self.run.source, -- 2595
					lines = {self.endingLines[1], self.endingLines[2]}, -- 2596
					childCleared = self.run.archive.childCleared, -- 2597
					soldierCleared = self.run.archive.soldierCleared, -- 2598
					artifactOwned = self.run.archive.artifactOwned, -- 2599
					equipped = self.equippedWeapon -- 2600
				}) -- 2600
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 2602
			end -- 2602
		end -- 2602
		return -- 2605
	end -- 2605
	self.phaseTick = self.phaseTick + 1 -- 2607
	local endingTicks = t.knockTicks + TOWER_REGISTER_TICKS + self.phaseTick -- 2608
	if endingTicks >= ____exports.TOWER_CONFIRM_TICKS and (input.interact.pressed or input.retry.pressed) then -- 2608
		self.restartStory = true -- 2611
		self:requestRoom("prologue", "片尾再玩") -- 2612
		self:flashSet("回到序章", 1.4) -- 2613
	end -- 2613
end -- 2529
function Play.prototype.stepChase(self, dt, input) -- 2618
	if self.caughtT > 0 then -- 2618
		self.caughtT = self.caughtT - dt -- 2620
		if self.caughtT <= 0 then -- 2620
			self:recoverFromCaught() -- 2622
		end -- 2622
		return -- 2624
	end -- 2624
	if self.room.key == "village" then -- 2624
		self:stepScavChase() -- 2627
	elseif self.room.key == "forest" then -- 2627
		self:stepForestRoute() -- 2629
		self:stepDog(dt) -- 2630
		if self.player.x >= self.ox + 1450 then -- 2630
			self:requestRoom("tower", "到林缘北塔") -- 2633
			self:flashSet("林缘 · 北塔", 1.4) -- 2634
		end -- 2634
	end -- 2634
end -- 2618
function Play.prototype.stepScavChase(self) -- 2640
	local s = self.room.scavenger -- 2641
	if s == nil then -- 2641
		return -- 2643
	end -- 2643
	local p = self.player -- 2645
	if self.passed and p.x > self.ox + 440 then -- 2645
		if self.scavChase then -- 2645
			self.scavChase = false -- 2649
			self.scavState = "back" -- 2650
			self.scavT = 0 -- 2651
		end -- 2651
		return -- 2653
	end -- 2653
	local dx = p.x - self.scavX -- 2655
	local dist = math.abs(dx) -- 2656
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 2657
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 2658
	if not self.scavChase then -- 2658
		if visible then -- 2658
			self.scavSee = self.scavSee + 1 -- 2661
			if self.scavSee >= 24 then -- 2661
				self.scavChase = true -- 2663
				self.scavState = "chase" -- 2664
				self.scavTargetX = p.x -- 2665
				self:flashSet("他看见你了", 1.2) -- 2666
			end -- 2666
		else -- 2666
			self.scavSee = 0 -- 2669
		end -- 2669
		return -- 2671
	end -- 2671
	local dir = p.x > self.scavX and 1 or -1 -- 2674
	self.scavX = self.scavX + dir * 96 / 60 -- 2675
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 2675
		self:caught() -- 2677
		return -- 2678
	end -- 2678
	if hidden then -- 2678
		self.scavSee = 0 -- 2682
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 2683
		self.scavT = self.scavT - 1 -- 2684
		if self.scavT <= 0 then -- 2684
			self.scavChase = false -- 2686
			self.scavState = "patrol" -- 2687
			self:flashSet("他失去了目标", 1) -- 2688
		end -- 2688
	end -- 2688
end -- 2640
function Play.prototype.stepDog(self, dt) -- 2694
	local ____temp_40 -- 2695
	if self.room.story == nil then -- 2695
		____temp_40 = nil -- 2695
	else -- 2695
		____temp_40 = self.room.story.dog -- 2695
	end -- 2695
	local dog = ____temp_40 -- 2695
	if dog == nil then -- 2695
		return -- 2697
	end -- 2697
	local p = self.player -- 2699
	local dist = math.abs(p.x - self.dogX) -- 2700
	if self.dogState == "patrol" then -- 2700
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 2702
		if self.dogX < dog.x0 then -- 2702
			self.dogX = dog.x0 -- 2704
			self.dogDir = 1 -- 2705
		elseif self.dogX > dog.x1 then -- 2705
			self.dogX = dog.x1 -- 2707
			self.dogDir = -1 -- 2708
		end -- 2708
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 2710
		if not p.crouch and moving and dist < dog.range then -- 2710
			self.dogState = "ear" -- 2712
			self.dogT = 18 -- 2713
			self.dogTargetX = p.x -- 2714
			self:flashSet("狗转耳朵", 0.8) -- 2715
		end -- 2715
		return -- 2717
	end -- 2717
	if self.dogState == "ear" then -- 2717
		self.dogT = self.dogT - 1 -- 2720
		if self.dogT <= 0 then -- 2720
			self.dogState = "chase" -- 2722
			self.dogTargetX = p.x -- 2723
			self:flashSet("狗追来了", 1.4) -- 2724
		end -- 2724
		return -- 2726
	end -- 2726
	if self.dogState == "chase" then -- 2726
		local dir = p.x > self.dogX and 1 or -1 -- 2729
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 2730
		if math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 2730
			self:caught() -- 2732
			self.dogState = "sniff" -- 2733
			self.dogT = 60 -- 2734
		elseif dist > dog.range * 1.5 or p.crouch then -- 2734
			self.dogState = "sniff" -- 2736
			self.dogT = 60 -- 2737
			self:flashSet("狗停下了", 0.9) -- 2738
		end -- 2738
		return -- 2740
	end -- 2740
	if self.dogState == "sniff" then -- 2740
		self.dogT = self.dogT - 1 -- 2743
		if self.dogT <= 0 then -- 2743
			self.dogState = "back" -- 2745
		end -- 2745
		return -- 2747
	end -- 2747
	local dir = dog.x0 > self.dogX and 1 or -1 -- 2750
	self.dogX = self.dogX + dir * dog.speed * dt -- 2751
	if math.abs(self.dogX - dog.x0) < 2 then -- 2751
		self.dogX = dog.x0 -- 2753
		self.dogState = "patrol" -- 2754
	end -- 2754
end -- 2694
function Play.prototype.stepForestRoute(self) -- 2759
	local p = self.player -- 2760
	local ox = self.ox -- 2761
	if self.forestPath == "" then -- 2761
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 2761
			self.forestPath = "burrow" -- 2764
			self.run.story.segments.forest_burrow = true -- 2765
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 2766
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 2767
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 2767
			self.forestPath = "ditch" -- 2769
			self.run.story.segments.forest_ditch = true -- 2770
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 2771
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 2772
		end -- 2772
	end -- 2772
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 2772
		self.waterSeen = true -- 2776
		self.run.story.segments.water_lantern = true -- 2777
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 2778
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 2779
	end -- 2779
end -- 2759
function Play.prototype.caught(self) -- 2783
	self.caughtT = 1 -- 2784
	self:flashSet("被抓 · 回到安全点", 1.6) -- 2785
end -- 2783
function Play.prototype.recoverFromCaught(self) -- 2789
	local p = self.player -- 2790
	p.x = self.ox + 140 -- 2791
	p.y = 0 -- 2792
	p.vy = 0 -- 2793
	p.vx = 0 -- 2794
	p.onGround = true -- 2795
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 2795
		self.scavX = self.room.scavenger.x0 -- 2797
		self.scavState = "patrol" -- 2798
		self.scavSee = 0 -- 2799
		self.scavChase = false -- 2800
		self.scavT = 0 -- 2801
	end -- 2801
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 2801
		self.dogX = self.room.story.dog.x0 -- 2804
		self.dogState = "patrol" -- 2805
		self.dogT = 0 -- 2806
	end -- 2806
	self.cam.x = p.x -- 2808
	self.cam.y = p.y + CAM_LOOK_UP -- 2809
	self:flashSet("回到安全点", 1.2) -- 2810
end -- 2789
function Play.prototype.updateGate(self) -- 2814
	if self.room.key ~= "checkpoint" then -- 2814
		self.gateOpen = false -- 2816
		return -- 2817
	end -- 2817
	local function inZone(x) -- 2819
		return x >= self.ox + 792 and x <= self.ox + 928 -- 2819
	end -- 2819
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 2820
end -- 2814
function Play.prototype.addItem(self, kind) -- 2826
	local inv = self.run.inventory -- 2827
	if kind == "shield" then -- 2827
		if inv.shield >= TOOL_CAP then -- 2827
			return false -- 2830
		end -- 2830
		inv.shield = inv.shield + 1 -- 2832
		return true -- 2833
	end -- 2833
	if kind == "wedge" then -- 2833
		if inv.wedge >= CONSUMABLE_CAP then -- 2833
			return false -- 2837
		end -- 2837
		inv.wedge = inv.wedge + 1 -- 2839
		return true -- 2840
	end -- 2840
	if kind == "ammo" then -- 2840
		if inv.ammo >= CONSUMABLE_CAP then -- 2840
			return false -- 2844
		end -- 2844
		inv.ammo = inv.ammo + 1 -- 2846
		return true -- 2847
	end -- 2847
	if kind == "scrap" then -- 2847
		inv.scrap = inv.scrap + 1 -- 2851
		return true -- 2852
	end -- 2852
	if kind == "wood" then -- 2852
		inv.wood = inv.wood + 1 -- 2855
		return true -- 2856
	end -- 2856
	if kind == "bell" then -- 2856
		inv.bell = inv.bell + 1 -- 2859
		return true -- 2860
	end -- 2860
	if kind == "pass" then -- 2860
		inv.pass = inv.pass + 1 -- 2863
		return true -- 2864
	end -- 2864
	if kind == "quickbelt" then -- 2864
		inv.quickbelt = inv.quickbelt + 1 -- 2867
		return true -- 2868
	end -- 2868
	return false -- 2870
end -- 2826
function Play.prototype.findBox(self, id) -- 2873
	local i = 0 -- 2874
	do -- 2874
		i = 0 -- 2875
		while i < #self.boxes do -- 2875
			if self.boxes[i + 1].id == id then -- 2875
				return self.boxes[i + 1] -- 2877
			end -- 2877
			i = i + 1 -- 2875
		end -- 2875
	end -- 2875
	return nil -- 2880
end -- 2873
function Play.prototype.findWedgeTarget(self) -- 2884
	local best = nil -- 2885
	local bestD = 0 -- 2886
	local i = 0 -- 2887
	do -- 2887
		i = 0 -- 2888
		while i < #self.boxes do -- 2888
			do -- 2888
				local b = self.boxes[i + 1] -- 2889
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 2889
					goto __continue425 -- 2891
				end -- 2891
				if not self:nearBox(b, 26) then -- 2891
					goto __continue425 -- 2894
				end -- 2894
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 2896
				if best == nil or d < bestD then -- 2896
					best = b -- 2898
					bestD = d -- 2899
				end -- 2899
			end -- 2899
			::__continue425:: -- 2899
			i = i + 1 -- 2888
		end -- 2888
	end -- 2888
	return best -- 2902
end -- 2884
function Play.prototype.stepCraft(self, input) -- 2910
	local inv = self.run.inventory -- 2911
	local ____opt_41 = self.run.trial -- 2911
	local required = CRAFT_TICKS - 6 * (____opt_41 and ____opt_41.ranks.craft or 0) -- 2912
	if self.craftT > 0 then -- 2912
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 2912
			self.craftT = 0 -- 2916
			self:flashSet("制作中断", 0.8) -- 2917
			return true -- 2918
		end -- 2918
		self.craftT = self.craftT + 1 -- 2920
		if self.craftT >= required then -- 2920
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 2920
				inv.scrap = inv.scrap - 1 -- 2923
				inv.wedge = inv.wedge + 1 -- 2924
				self:flashSet("制得木楔", 1.2) -- 2925
				self:log("制木楔") -- 2926
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 2927
			end -- 2927
			self.craftT = 0 -- 2929
		end -- 2929
		return true -- 2931
	end -- 2931
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 2931
		self.craftT = 1 -- 2934
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 2935
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 2936
		return true -- 2937
	end -- 2937
	return false -- 2939
end -- 2910
function Play.prototype.nearBox(self, b, reach) -- 2942
	local p = self.player -- 2943
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 2944
end -- 2942
function Play.prototype.findInteract(self) -- 2950
	local p = self.player -- 2951
	local best = nil -- 2952
	local bestD = 1000000000 -- 2953
	local i = 0 -- 2954
	do -- 2954
		i = 0 -- 2955
		while i < #self.boxes do -- 2955
			do -- 2955
				local b = self.boxes[i + 1] -- 2956
				if b.interact == nil or b.broken == true then -- 2956
					goto __continue438 -- 2958
				end -- 2958
				if not self:nearBox(b, b.interact.reach or 27) then -- 2958
					goto __continue438 -- 2961
				end -- 2961
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 2963
				if d < bestD then -- 2963
					bestD = d -- 2965
					best = b -- 2966
				end -- 2966
			end -- 2966
			::__continue438:: -- 2966
			i = i + 1 -- 2955
		end -- 2955
	end -- 2955
	return best -- 2969
end -- 2950
function Play.prototype.stepCampaign(self, dt, input) -- 2973
	local wr = self.room -- 2974
	local p = self.player -- 2975
	if self.reloadT > 0 then -- 2975
		self.reloadT = self.reloadT - 1 -- 2977
	end -- 2977
	if self.bracedShield ~= nil then -- 2977
		self.bracedShield.x = p.x + p.facing * 26 -- 2981
		self.bracedShield.y = p.y -- 2982
		local shBox = __TS__ArrayFind( -- 2983
			self.boxes, -- 2983
			function(____, b) return b.id == "braced_shield" end -- 2983
		) -- 2983
		if shBox ~= nil then -- 2983
			shBox.x0 = self.bracedShield.x - 15 -- 2985
			shBox.x1 = self.bracedShield.x + 15 -- 2986
			shBox.y0 = self.bracedShield.y -- 2987
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 2988
		end -- 2988
	end -- 2988
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 2988
		self.run.route = "drygoods" -- 2994
		self.run.joined = false -- 2995
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 2996
		self:log("转布行线") -- 2997
	end -- 2997
	if wr.key == "escort3" then -- 2997
		local benchX = wr.minX + 560 -- 3001
		local nearBench = math.abs(p.x - benchX) <= self.benchReach + 40 and p.y < 60 -- 3002
		if nearBench and input.interact.pressed then -- 3002
			self:openCraftBench() -- 3004
		end -- 3004
	end -- 3004
	local i = 0 -- 3008
	do -- 3008
		i = 0 -- 3009
		while i < #self.pickups do -- 3009
			do -- 3009
				local pk = self.pickups[i + 1] -- 3010
				if self.run.taken[pk.id] == true then -- 3010
					goto __continue451 -- 3012
				end -- 3012
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3014
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3015
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3015
					if not self:addItem(pk.kind) then -- 3015
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3019
						self:log("满包拒绝 " .. pk.kind) -- 3020
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3021
						goto __continue451 -- 3022
					end -- 3022
					self.run.taken[pk.id] = true -- 3024
					self:flashSet("拾取 " .. pk.label, 1) -- 3025
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3026
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3027
				end -- 3027
			end -- 3027
			::__continue451:: -- 3027
			i = i + 1 -- 3009
		end -- 3009
	end -- 3009
	if not self:stepCraft(input) and input.interact.pressed then -- 3009
		self:campaignInteract() -- 3031
	end -- 3031
	self:stepCampaignCart(dt, input) -- 3033
	self:stepCampaignGoal() -- 3034
	self:campaignCheckpoint() -- 3035
end -- 2973
function Play.prototype.campaignCheckpoint(self) -- 3039
	local i = 0 -- 3040
	do -- 3040
		i = 0 -- 3041
		while i < #self.room.marks do -- 3041
			do -- 3041
				local m = self.room.marks[i + 1] -- 3042
				if m.kind ~= 0 then -- 3042
					goto __continue458 -- 3044
				end -- 3044
				local dx = self.player.x - m.x -- 3046
				local dy = self.player.y - m.y -- 3047
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3047
					self.checkpoint = m.x -- 3049
					self:captureCheckpoint(m.x) -- 3050
					self:flashSet("检查点", 1) -- 3051
				end -- 3051
			end -- 3051
			::__continue458:: -- 3051
			i = i + 1 -- 3041
		end -- 3041
	end -- 3041
end -- 3039
function Play.prototype.campaignInteract(self) -- 3057
	local b = self:findInteract() -- 3058
	if b ~= nil then -- 3058
		self:useInteract(b) -- 3060
		return -- 3061
	end -- 3061
	local inv = self.run.inventory -- 3063
	if inv.wedge > 0 then -- 3063
		local w = self:findWedgeTarget() -- 3065
		if w ~= nil then -- 3065
			if w.breakable ~= nil then -- 3065
				local ____w_breakable_43, ____hp_44 = w.breakable, "hp" -- 3065
				____w_breakable_43[____hp_44] = ____w_breakable_43[____hp_44] + (w.breakable.wedgeHp or 1) -- 3068
			end -- 3068
			inv.wedge = inv.wedge - 1 -- 3070
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3071
			self:flashSet("钉木楔 · 多承一次", 1.2) -- 3073
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3074
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3075
			return -- 3076
		end -- 3076
	end -- 3076
	if inv.ammo > 0 and self.reloadT > 0 then -- 3076
		self.reloadT = 0 -- 3081
		self:closeReloadPuzzle() -- 3082
		inv.ammo = inv.ammo - 1 -- 3083
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3084
		self:log("用备用弹包") -- 3085
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3086
		return -- 3087
	end -- 3087
	if inv.shield > 0 and self.bracedShield == nil and self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 then -- 3087
		local p = self.player -- 3091
		self.bracedShield = { -- 3092
			x = p.x + p.facing * 26, -- 3092
			y = p.y, -- 3092
			w = 30, -- 3092
			h = 64, -- 3092
			hp = 1 -- 3092
		} -- 3092
		local ____self_boxes_45 = self.boxes -- 3092
		____self_boxes_45[#____self_boxes_45 + 1] = { -- 3093
			x0 = self.bracedShield.x - 15, -- 3094
			x1 = self.bracedShield.x + 15, -- 3094
			y0 = p.y, -- 3095
			y1 = p.y + 64, -- 3095
			depth = {min = -46, max = 46}, -- 3095
			label = "架起的残盾", -- 3095
			id = "braced_shield", -- 3095
			soft = true -- 3096
		} -- 3096
		inv.shield = inv.shield - 1 -- 3099
		self:flashSet("架残盾 · 挡一发", 1.2) -- 3100
		self:log("架残盾") -- 3101
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3102
		return -- 3103
	end -- 3103
	if inv.pass > 0 and self.run.joined == false then -- 3103
		inv.pass = inv.pass - 1 -- 3106
		self.run.joined = true -- 3107
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3108
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3109
		return -- 3110
	end -- 3110
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3112
end -- 3057
function Play.prototype.useInteract(self, b) -- 3115
	local kind = b.interact == nil and "" or b.interact.kind -- 3116
	local wr = self.room -- 3117
	if kind == "open_board" then -- 3117
		b.broken = true -- 3119
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3120
		for ____, cover in ipairs(self.boxes) do -- 3121
			if cover.id == "s2_board_cover" then -- 3121
				cover.broken = false -- 3123
				cover.hidden = false -- 3124
			end -- 3124
		end -- 3124
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3127
		self.run.joined = true -- 3128
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3129
		self:log("放下窗板") -- 3130
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3131
		return -- 3132
	end -- 3132
	if kind == "lower_curtain" then -- 3132
		for ____, curtain in ipairs(self.boxes) do -- 3135
			if curtain.id == "c2_curtain" then -- 3135
				curtain.broken = false -- 3137
				curtain.hidden = false -- 3138
			end -- 3138
		end -- 3138
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3141
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3142
		self:log("放下木帘") -- 3143
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3144
		return -- 3145
	end -- 3145
	if kind == "raise_latch" then -- 3145
		if wr.key == "c2-granary" and not self.cartDocked then -- 3145
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3149
			return -- 3150
		end -- 3150
		b.broken = true -- 3152
		self.objectiveDone = true -- 3153
		if wr.key == "c1-yard" then -- 3153
			self.run.c1Latch = true -- 3156
			self.run.joined = true -- 3157
		else -- 3157
			self.run.c2Latch = true -- 3159
			self.run.joined = true -- 3160
		end -- 3160
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3162
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3163
		self:log("抬闩") -- 3164
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3165
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3166
	end -- 3166
end -- 3115
function Play.prototype.stepCampaignCart(self, dt, input) -- 3171
	local wr = self.room -- 3172
	local c = wr.cart -- 3173
	if c.bodyW <= 0 then -- 3173
		return -- 3175
	end -- 3175
	local p = self.player -- 3177
	local handleX = self.cartAxle + c.handleOffset -- 3178
	if not self.gripping then -- 3178
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and p.y <= c.baseY + (c.depth or 0) + 40 and not self.objectiveDone then -- 3178
			self.gripping = true -- 3182
			self:flashSet("握住车柄 · A/D 推", 1) -- 3183
		end -- 3183
		return -- 3185
	end -- 3185
	if input.interact.pressed then -- 3185
		self.gripping = false -- 3188
		self:flashSet("松手", 0.5) -- 3189
		return -- 3190
	end -- 3190
	if not self.cartDocked then -- 3190
		if input.moveX ~= 0 and not self:stuckCart() then -- 3190
			self.cartAxle = math.max( -- 3194
				c.startX, -- 3194
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3194
			) -- 3194
		end -- 3194
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3194
			self.cartExposed = true -- 3199
			local gun = nil -- 3200
			local gi = 0 -- 3201
			do -- 3201
				gi = 0 -- 3202
				while gi < #self.enemies do -- 3202
					local e = self.enemies[gi + 1] -- 3203
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3203
						gun = e -- 3205
						break -- 3206
					end -- 3206
					gi = gi + 1 -- 3202
				end -- 3202
			end -- 3202
			if gun ~= nil then -- 3202
				self:campaignEnemyFire(gun) -- 3210
			end -- 3210
		end -- 3210
		p.x = self.cartAxle + c.handleOffset -- 3213
		p.y = c.baseY + (c.depth or 0) -- 3214
		p.vx = 0 -- 3215
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3215
			self.cartAxle = c.endX -- 3217
			self.cartDocked = true -- 3218
			self.gripping = false -- 3219
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3220
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3221
			self:flashSet("车轮入窝", 1.2) -- 3222
			self:log("车轮入窝") -- 3223
		end -- 3223
	end -- 3223
end -- 3171
function Play.prototype.stuckCart(self) -- 3229
	local i = 0 -- 3230
	do -- 3230
		i = 0 -- 3231
		while i < #self.boxes do -- 3231
			do -- 3231
				local b = self.boxes[i + 1] -- 3232
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3232
					goto __continue497 -- 3234
				end -- 3234
				local front = self.cartAxle + self.room.cart.handleOffset + self.room.cart.bodyW / 2 -- 3236
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3236
					return true -- 3238
				end -- 3238
			end -- 3238
			::__continue497:: -- 3238
			i = i + 1 -- 3231
		end -- 3231
	end -- 3231
	return false -- 3241
end -- 3229
function Play.prototype.stepCampaignGoal(self) -- 3245
	local wr = self.room -- 3246
	local c = wr.campaign -- 3247
	if c == nil then -- 3247
		return -- 3249
	end -- 3249
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3249
		self.objectiveDone = true -- 3252
	end -- 3252
	if c.goal == "reach_exit" then -- 3252
		self.objectiveDone = true -- 3255
	end -- 3255
	if not self.objectiveDone then -- 3255
		return -- 3258
	end -- 3258
	local p = self.player -- 3260
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3261
	if p.x < c.exitX or not partnerOk then -- 3261
		return -- 3263
	end -- 3263
	if self.run.story.segments[wr.key] ~= true then -- 3263
		self.run.story.segments[wr.key] = true -- 3267
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3268
	end -- 3268
	if wr.key == "escort5" then -- 3268
		self.escortDone = true -- 3272
		self.run.story.escortDone = true -- 3273
	end -- 3273
	if c.next ~= nil and c.next ~= "" then -- 3273
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3276
		self:flashSet("过关 · " .. c.next, 1.2) -- 3277
	elseif not self.run.finished then -- 3277
		self.run.finished = true -- 3279
		self:flashSet( -- 3280
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3280
			2 -- 3280
		) -- 3280
		self:log("C2 灰盒完成") -- 3281
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3282
	end -- 3282
end -- 3245
function Play.prototype.stepCampaignPartner(self, dt) -- 3287
	local a = self.partner -- 3288
	local wr = self.room -- 3289
	local cp = wr.companion -- 3290
	if not a.alive then -- 3290
		return -- 3292
	end -- 3292
	local p = self.player -- 3294
	if self.craftBench.active then -- 3294
		a.vx = 0 -- 3297
		return -- 3298
	end -- 3298
	local wait = false -- 3300
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3301
	local targetDepth = p.depth -- 3302
	if self.run.joined == false then -- 3302
		wait = true -- 3304
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3305
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3306
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3306
		wait = true -- 3308
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3309
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3310
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3310
		wait = true -- 3312
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3313
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3314
	end -- 3314
	if self.partnerStuck > 0.3 then -- 3314
		a.x = a.x + a.facing * 44 -- 3318
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3319
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3320
		self.partnerLaneHold = 1.1 -- 3321
		self.partnerStuck = 0 -- 3322
	end -- 3322
	if self.partnerLaneHold > 0 then -- 3322
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3325
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3326
	end -- 3326
	local dx = targetX - a.x -- 3328
	if not wait and math.abs(dx) > 74 then -- 3328
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3330
		local before = a.x -- 3331
		a.vx = dx > 0 and speed or -speed -- 3332
		a.facing = dx > 0 and 1 or -1 -- 3333
		self:slideX(a, a.vx * dt) -- 3334
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3334
			a.vy = CHILD_JUMP -- 3337
			a.onGround = false -- 3338
		end -- 3338
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3340
	else -- 3340
		a.vx = 0 -- 3342
		self.partnerStuck = 0 -- 3343
	end -- 3343
	local dz = targetDepth - a.depth -- 3345
	if math.abs(dz) > 6 then -- 3345
		local step = math.max( -- 3347
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3347
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3347
		) -- 3347
		a.depth = a.depth + step -- 3348
	end -- 3348
	a.depthSpeed = 0 -- 3350
	a.h = CHILD_H -- 3351
	a.crouch = false -- 3352
	self:fallY(a, dt) -- 3353
end -- 3287
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3357
	local p = self.player -- 3358
	local i = 0 -- 3359
	do -- 3359
		i = 0 -- 3360
		while i < #self.enemies do -- 3360
			do -- 3360
				local ____opt_46 = self.run.trial -- 3360
				if ____opt_46 and ____opt_46.lost then -- 3360
					return -- 3361
				end -- 3361
				local e = self.enemies[i + 1] -- 3362
				if not e.alive then -- 3362
					goto __continue524 -- 3364
				end -- 3364
				if e.hitT > 0 then -- 3364
					e.hitT = e.hitT - dt -- 3367
				end -- 3367
				if e.kind == "target" then -- 3367
					if not e.alive and e.hitT <= 0 then -- 3367
						e.alive = true -- 3372
					end -- 3372
					goto __continue524 -- 3374
				end -- 3374
				if e.kind == "breaker" then -- 3374
					self:stepBreaker(e, dt) -- 3377
					goto __continue524 -- 3378
				end -- 3378
				if e.kind == "shield" then -- 3378
					self:stepShield(e, dt, input) -- 3381
					goto __continue524 -- 3382
				end -- 3382
				local dx = e.x - p.x -- 3385
				if not e.awake then -- 3385
					if math.abs(dx) > 520 then -- 3385
						goto __continue524 -- 3388
					end -- 3388
					e.awake = true -- 3390
					e.fireCd = 48 -- 3391
					goto __continue524 -- 3392
				end -- 3392
				if math.abs(dx) > ENEMY_RANGE then -- 3392
					goto __continue524 -- 3395
				end -- 3395
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 3395
					goto __continue524 -- 3400
				end -- 3400
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 3400
					goto __continue524 -- 3403
				end -- 3403
				if self:blockedShot(e, p) then -- 3403
					if e.warnT > 0 then -- 3403
						e.warnT = 0 -- 3409
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3410
					end -- 3410
					goto __continue524 -- 3412
				end -- 3412
				if e.warnT > 0 then -- 3412
					e.warnT = e.warnT - 1 -- 3415
					if e.warnT <= 0 then -- 3415
						self:campaignEnemyFire(e) -- 3417
					end -- 3417
				elseif e.fireCd > 0 then -- 3417
					e.fireCd = e.fireCd - 1 -- 3420
					if e.fireCd <= 0 then -- 3420
						e.warnT = WARN_TICKS -- 3422
					end -- 3422
				else -- 3422
					e.fireCd = 40 -- 3425
				end -- 3425
			end -- 3425
			::__continue524:: -- 3425
			i = i + 1 -- 3360
		end -- 3360
	end -- 3360
end -- 3357
function Play.prototype.blockedShot(self, e, p) -- 3431
	local eDepth = e.depth or 0 -- 3432
	local ex = e.x -- 3433
	local ey = e.y + e.h * 0.62 -- 3435
	local px = p.x -- 3436
	local py = p.y + p.h * 0.55 -- 3437
	local dx = px - ex -- 3438
	local dyScreen = py + p.depth - (ey + eDepth) -- 3439
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 3440
	if len < 0.01 then -- 3440
		return false -- 3442
	end -- 3442
	local ray = { -- 3446
		x = ex, -- 3447
		y = ey, -- 3447
		dx = dx / len, -- 3448
		dy = (py - ey) / len, -- 3448
		depth = eDepth, -- 3449
		dDepth = (p.depth - eDepth) / len -- 3449
	} -- 3449
	local best = -1 -- 3451
	local j = 0 -- 3452
	do -- 3452
		j = 0 -- 3453
		while j < #self.boxes do -- 3453
			do -- 3453
				local b = self.boxes[j + 1] -- 3454
				if b.broken == true or b.passable == true or b.hidden == true then -- 3454
					goto __continue547 -- 3456
				end -- 3456
				if b.id == "braced_shield" then -- 3456
					goto __continue547 -- 3461
				end -- 3461
				local t = hitBox(ray, b) -- 3463
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 3463
					best = t -- 3467
				end -- 3467
			end -- 3467
			::__continue547:: -- 3467
			j = j + 1 -- 3453
		end -- 3453
	end -- 3453
	return best >= 0 -- 3470
end -- 3431
function Play.prototype.campaignEnemyFire(self, e) -- 3473
	local p = self.player -- 3474
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 3475
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 3475
		local ____self_bracedShield_48, ____hp_49 = self.bracedShield, "hp" -- 3475
		____self_bracedShield_48[____hp_49] = ____self_bracedShield_48[____hp_49] - 1 -- 3477
		self.boxes = __TS__ArrayFilter( -- 3478
			self.boxes, -- 3478
			function(____, b) return b.id ~= "braced_shield" end -- 3478
		) -- 3478
		self.bracedShield = nil -- 3479
		self:flashSet("残盾碎 · 挡下一发", 1) -- 3480
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 3481
		return -- 3482
	end -- 3482
	if self:blockedShot(e, p) then -- 3482
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 3485
		return -- 3486
	end -- 3486
	local cover = self:blockedByCover(e, p) -- 3488
	if cover ~= nil and self.coverHug then -- 3488
		self.coveredFlash = 0.5 -- 3490
		self:flashSet("掩体挡下", 0.6) -- 3491
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3492
		return -- 3497
	end -- 3497
	if self.invulnT > 0 then -- 3497
		return -- 3500
	end -- 3500
	local ____opt_50 = self.run.trial -- 3500
	self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_50 and ____opt_50.ranks.guard or 0) -- 3502
	self.craftT = 0 -- 3503
	self.hp = self.hp - 1 -- 3504
	self:emit("actorHit", { -- 3505
		target = "player", -- 3505
		amount = 1, -- 3505
		hp = self.hp, -- 3505
		maxHp = self.maxHp, -- 3505
		enemyX = e.x -- 3505
	}) -- 3505
	self:flashSet( -- 3506
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3506
		0.8 -- 3506
	) -- 3506
	if self.hp <= 0 then -- 3506
		self:campaignFailed() -- 3508
	end -- 3508
end -- 3473
function Play.prototype.stepShield(self, e, dt, input) -- 3513
	local p = self.player -- 3514
	local dx = p.x - e.x -- 3515
	local adx = math.abs(dx) -- 3516
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 3519
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 3520
	if adx > 150 then -- 3520
		local before = e.x -- 3522
		e.x = e.x + (dx > 0 and 1 or -1) * 60 * dt -- 3523
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 3523
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3526
		end -- 3526
	elseif adx < 48 and sameLane and (e.swingT or 0) <= 0 then -- 3526
		local fromFront = (e.x - p.x) * p.facing > 0 -- 3531
		local rollDodges = p.rollT > 0 and fromFront -- 3532
		if not rollDodges and self.invulnT <= 0 then -- 3532
			local ____opt_52 = self.run.trial -- 3532
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_52 and ____opt_52.ranks.guard or 0) -- 3534
			self.craftT = 0 -- 3535
			self.hp = self.hp - 1 -- 3536
			self:emit("actorHit", { -- 3537
				target = "player", -- 3537
				amount = 1, -- 3537
				hp = self.hp, -- 3537
				maxHp = self.maxHp, -- 3537
				enemyX = e.x -- 3537
			}) -- 3537
			self:flashSet( -- 3538
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3538
				0.8 -- 3538
			) -- 3538
			if self.hp <= 0 then -- 3538
				self:campaignFailed() -- 3540
				return -- 3541
			end -- 3541
		end -- 3541
		e.swingT = 70 -- 3544
	end -- 3544
	if (e.swingT or 0) > 0 then -- 3544
		e.swingT = (e.swingT or 0) - 1 -- 3547
	end -- 3547
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 3547
		local dd = p.depth - (e.depth or 0) -- 3550
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 3551
	end -- 3551
end -- 3513
function Play.prototype.stepBreaker(self, e, dt) -- 3556
	local p = self.player -- 3557
	if e.awake ~= true then -- 3557
		if math.abs(p.x - e.x) < 560 then -- 3557
			e.awake = true -- 3560
		else -- 3560
			return -- 3562
		end -- 3562
	end -- 3562
	local target = nil -- 3565
	local bestD = 1000000000 -- 3566
	local i = 0 -- 3567
	do -- 3567
		i = 0 -- 3568
		while i < #self.boxes do -- 3568
			do -- 3568
				local b = self.boxes[i + 1] -- 3569
				if b.breakable == nil or b.broken == true then -- 3569
					goto __continue571 -- 3571
				end -- 3571
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 3573
				if d < bestD then -- 3573
					bestD = d -- 3575
					target = b -- 3576
				end -- 3576
			end -- 3576
			::__continue571:: -- 3576
			i = i + 1 -- 3568
		end -- 3568
	end -- 3568
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 3579
	local dx = tx - e.x -- 3580
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 3581
	if math.abs(dx) > reach then -- 3581
		local before = e.x -- 3583
		e.x = e.x + (dx > 0 and 1 or -1) * 48 * dt -- 3584
		if math.abs(e.x - before) < 0.3 then -- 3584
			e.depth = (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16) -- 3586
		end -- 3586
	elseif (e.swingT or 0) <= 0 then -- 3586
		e.swingT = 64 -- 3589
		if target ~= nil then -- 3589
			self:damageProp(target, 2) -- 3591
		elseif math.abs(p.x - e.x) < 60 and self.invulnT <= 0 then -- 3591
			local ____opt_54 = self.run.trial -- 3591
			self.invulnT = INVULN_HIT_TICKS + 12 * (____opt_54 and ____opt_54.ranks.guard or 0) -- 3593
			self.craftT = 0 -- 3594
			self.hp = self.hp - 1 -- 3595
			self:emit("actorHit", { -- 3596
				target = "player", -- 3596
				amount = 1, -- 3596
				hp = self.hp, -- 3596
				maxHp = self.maxHp, -- 3596
				enemyX = e.x -- 3596
			}) -- 3596
			self:flashSet("破障手近身", 0.8) -- 3597
			if self.hp <= 0 then -- 3597
				self:campaignFailed() -- 3599
				return -- 3600
			end -- 3600
		end -- 3600
	end -- 3600
	if (e.swingT or 0) > 0 then -- 3600
		e.swingT = (e.swingT or 0) - 1 -- 3605
	end -- 3605
end -- 3556
function Play.prototype.campaignFailed(self) -- 3609
	if self.run.trial ~= nil then -- 3609
		self.run.trial.lost = true -- 3611
		self.wantRoom = "" -- 3612
		self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3613
		return -- 3614
	end -- 3614
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 3614
		self:restartEscortFromDeath() -- 3619
		return -- 3620
	end -- 3620
	local p = self.player -- 3622
	self.hp = self.maxHp -- 3623
	self.invulnT = INVULN_RESPAWN_TICKS -- 3624
	self.reloadT = 0 -- 3625
	self:closeReloadPuzzle() -- 3626
	self.gripping = false -- 3627
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 3628
	self:log("被击倒") -- 3629
	p.x = self.room.minX + 90 -- 3630
	p.y = 0 -- 3631
	p.depth = 0 -- 3632
	p.vx = 0 -- 3633
	p.vy = 0 -- 3634
	p.onGround = true -- 3635
	p.rollT = 0 -- 3636
	self.partner.x = p.x - 50 -- 3637
	self.partner.y = 0 -- 3638
	self.partner.depth = 0 -- 3639
	self.cam.x = p.x -- 3640
	local i = 0 -- 3641
	do -- 3641
		i = 0 -- 3642
		while i < #self.enemies do -- 3642
			do -- 3642
				local e = self.enemies[i + 1] -- 3643
				if not e.alive then -- 3643
					goto __continue585 -- 3645
				end -- 3645
				e.x = e.homeX == nil and e.x or e.homeX -- 3647
				e.warnT = 0 -- 3648
				e.fireCd = 40 -- 3649
				e.swingT = 0 -- 3650
				e.awake = false -- 3651
			end -- 3651
			::__continue585:: -- 3651
			i = i + 1 -- 3642
		end -- 3642
	end -- 3642
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 3653
end -- 3609
function Play.prototype.isEscortRoom(self) -- 3657
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 3658
end -- 3657
function Play.prototype.restartEscortFromDeath(self) -- 3666
	local story = self.run.story -- 3667
	local inv = self.run.inventory -- 3668
	self.hp = self.maxHp -- 3669
	story.hp = self.maxHp -- 3670
	story.cp = nil -- 3671
	self.checkpointSnap = nil -- 3672
	story.carry = false -- 3673
	self.carryOn = false -- 3674
	story.craftedWeapon = "" -- 3675
	self.equippedWeapon = "standard_gun" -- 3676
	story.escortDone = false -- 3677
	self.escortDone = false -- 3678
	story.segments = {} -- 3679
	inv.wood = 0 -- 3680
	inv.bell = 0 -- 3681
	inv.scrap = 0 -- 3682
	inv.wedge = 0 -- 3683
	inv.ammo = 0 -- 3684
	inv.quickbelt = 0 -- 3685
	inv.shield = 0 -- 3686
	inv.pass = 0 -- 3687
	local taken = self.run.taken -- 3688
	local keys = __TS__ObjectKeys(taken) -- 3689
	local i = 0 -- 3690
	do -- 3690
		i = 0 -- 3691
		while i < #keys do -- 3691
			if (string.find(keys[i + 1], "e2_", nil, true) or 0) - 1 == 0 or (string.find(keys[i + 1], "e3_", nil, true) or 0) - 1 == 0 then -- 3691
				__TS__Delete(taken, keys[i + 1]) -- 3693
			end -- 3693
			i = i + 1 -- 3691
		end -- 3691
	end -- 3691
	self.run.joined = true -- 3696
	self.reloadT = 0 -- 3697
	self:closeReloadPuzzle() -- 3698
	self.gripping = false -- 3699
	self:flashSet("被击倒 · 回男主入口重开", 2) -- 3700
	self:log("男主线失败 · 回 escort1") -- 3701
	self:emit("campaignFailed", { -- 3702
		room = self.room.key, -- 3703
		hp = 0, -- 3703
		maxHp = self.maxHp, -- 3703
		reset = true, -- 3704
		to = "escort1", -- 3704
		route = self.storyRoute -- 3704
	}) -- 3704
	self:requestRoom("escort1", "男主线失败重开") -- 3706
end -- 3666
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 3710
	local i = 0 -- 3711
	do -- 3711
		i = 0 -- 3712
		while i < #self.enemies do -- 3712
			do -- 3712
				if i == skipIndex then -- 3712
					goto __continue594 -- 3714
				end -- 3714
				local e = self.enemies[i + 1] -- 3716
				if not e.alive or math.abs(e.x - center.x) > radius then -- 3716
					goto __continue594 -- 3718
				end -- 3718
				e.fireCd = 150 -- 3720
				e.warnT = 0 -- 3721
			end -- 3721
			::__continue594:: -- 3721
			i = i + 1 -- 3712
		end -- 3712
	end -- 3712
end -- 3710
function Play.prototype.stepEnemies(self, dt, input) -- 3725
	local i = 0 -- 3726
	do -- 3726
		i = 0 -- 3727
		while i < #self.enemies do -- 3727
			local e = self.enemies[i + 1] -- 3728
			if e.hitT > 0 then -- 3728
				e.hitT = e.hitT - dt -- 3730
			end -- 3730
			i = i + 1 -- 3727
		end -- 3727
	end -- 3727
	if self.coveredFlash > 0 then -- 3727
		self.coveredFlash = self.coveredFlash - dt -- 3734
	end -- 3734
	if self.isCampaign then -- 3734
		self:stepCampaignEnemies(dt, input) -- 3737
		return -- 3738
	end -- 3738
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 3738
		return -- 3742
	end -- 3742
	do -- 3742
		i = 0 -- 3744
		while i < #self.enemies do -- 3744
			do -- 3744
				local e = self.enemies[i + 1] -- 3745
				if not e.alive then -- 3745
					goto __continue605 -- 3747
				end -- 3747
				if e.warnT > 0 then -- 3747
					e.warnT = e.warnT - 1 -- 3750
					if e.warnT <= 0 then -- 3750
						self:enemyFire(e, input) -- 3752
					end -- 3752
					goto __continue605 -- 3754
				end -- 3754
				if e.fireCd > 0 then -- 3754
					e.fireCd = e.fireCd - 1 -- 3757
					if e.fireCd <= 0 then -- 3757
						e.warnT = WARN_TICKS -- 3759
					end -- 3759
				else -- 3759
					e.warnT = WARN_TICKS -- 3763
				end -- 3763
			end -- 3763
			::__continue605:: -- 3763
			i = i + 1 -- 3744
		end -- 3744
	end -- 3744
end -- 3725
function Play.prototype.enemyFire(self, e, input) -- 3769
	local p = self.player -- 3770
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 3770
		self:flashSet("枪声响在远处", 0.4) -- 3772
		e.fireCd = FIRE_COOLDOWN -- 3773
		return -- 3774
	end -- 3774
	local cover = self:blockedByCover(e, p) -- 3777
	local hugging = cover ~= nil -- 3778
	self.coverBlocking = hugging -- 3779
	local covered = hugging and input.cover.held -- 3780
	if covered then -- 3780
		self.coveredFlash = 0.5 -- 3782
		self:flashSet("掩体挡下", 0.5) -- 3783
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 3784
		e.fireCd = FIRE_COOLDOWN -- 3789
		return -- 3790
	end -- 3790
	self.hp = self.hp - 1 -- 3792
	self:emit("actorHit", { -- 3793
		target = "player", -- 3793
		amount = 1, -- 3793
		hp = self.hp, -- 3793
		maxHp = self.maxHp, -- 3793
		enemyX = e.x -- 3793
	}) -- 3793
	self:flashSet( -- 3794
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 3794
		0.7 -- 3794
	) -- 3794
	e.fireCd = FIRE_COOLDOWN -- 3795
	if self.hp <= 0 then -- 3795
		self:gateFailed() -- 3797
	end -- 3797
end -- 3769
function Play.prototype.blockedByCover(self, enemy, p) -- 3802
	local b = self:coverAt(p) -- 3803
	if b == nil then -- 3803
		return nil -- 3805
	end -- 3805
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 3807
end -- 3802
function Play.prototype.gateFailed(self) -- 3811
	local ____temp_56 -- 3812
	if self.room.story == nil then -- 3812
		____temp_56 = nil -- 3812
	else -- 3812
		____temp_56 = self.room.story.gate -- 3812
	end -- 3812
	local g = ____temp_56 -- 3812
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 3813
	self.hp = self.maxHp -- 3814
	self.gateTick = 0 -- 3815
	self.gateSpawned = 0 -- 3816
	self.enemies = {} -- 3817
	self.gateFailCount = self.gateFailCount + 1 -- 3818
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 3820
	self.player.y = 0 -- 3821
	self.player.vy = 0 -- 3822
	self.player.depth = 0 -- 3823
	self.player.depthSpeed = 0 -- 3824
	self.player.onGround = true -- 3825
	self.player.crouch = false -- 3826
	self.player.h = SOLDIER_H -- 3827
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 3828
	self.partner.y = 0 -- 3829
	self.partner.vy = 0 -- 3830
	self.partner.depth = 0 -- 3831
	self.partner.depthSpeed = 0 -- 3832
	self.partner.onGround = true -- 3833
	self.cam.x = self.player.x -- 3834
	self.phase = "gate-idle" -- 3835
	self.phaseTick = 0 -- 3836
	self.coverHug = false -- 3837
	self.coverBlocking = false -- 3838
	self.coverEntity = "" -- 3839
	self.gateNeedConfirm = true -- 3840
	self.gateRestartArmed = false -- 3841
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 3842
end -- 3811
function Play.prototype.stepRedCart(self, input) -- 3846
	if self.room.key ~= "outside" or self.redCartPulled then -- 3846
		return -- 3848
	end -- 3848
	local box = __TS__ArrayFind( -- 3850
		self.boxes, -- 3850
		function(____, b) return b.id == "outside_red_cart" end -- 3850
	) -- 3850
	if box == nil then -- 3850
		self.redCartPulled = true -- 3852
		return -- 3853
	end -- 3853
	local cx = (box.x0 + box.x1) * 0.5 -- 3855
	local p = self.player -- 3856
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 3856
		return -- 3858
	end -- 3858
	if not input.interact.pressed then -- 3858
		return -- 3861
	end -- 3861
	box.x0 = 430 -- 3863
	box.x1 = 474 -- 3864
	self.cartAxle = self.room.cart.endX -- 3866
	self.cartDocked = true -- 3867
	self.redCartPulled = true -- 3868
	if self.run.story ~= nil then -- 3868
		self.run.story.segments.outside_cart = true -- 3870
	end -- 3870
	self:flashSet("拉开红布车 · 石阶口露出来", 1.6) -- 3872
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 3873
end -- 3846
function Play.prototype.stepInteract(self, dt, input) -- 3876
	local p = self.player -- 3877
	self:stepRedCart(input) -- 3878
	local calmUsed = self.calmConsumed -- 3879
	self.calmConsumed = false -- 3880
	local calming = self.escort.state == "calming" -- 3882
	self.focusCart = false -- 3883
	if self.room.key == "outside" then -- 3883
		local c = self.room.cart -- 3885
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 3886
		local dy = p.y - c.baseY -- 3887
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 3888
	end -- 3888
	if not calmUsed and not calming then -- 3888
		self:stepCart(dt, input) -- 3892
	end -- 3892
	if calmUsed then -- 3892
		self:flashSet("安抚 · 敲两下", 0.8) -- 3897
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 3897
		if self.knockT > 0 then -- 3897
			self.knocks = self.knocks + 1 -- 3901
		else -- 3901
			self.knocks = 1 -- 3903
		end -- 3903
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 3905
		self.knockT = 1.2 -- 3906
		if self.knocks >= 2 then -- 3906
			self:flashSet("敲两下", 0.8) -- 3908
			self.knocks = 0 -- 3909
		else -- 3909
			self:flashSet("敲一下", 0.5) -- 3911
		end -- 3911
	elseif self.knockT > 0 then -- 3911
		self.knockT = self.knockT - dt -- 3914
		if self.knockT <= 0 then -- 3914
			self.knocks = 0 -- 3916
		end -- 3916
	end -- 3916
	local i = 0 -- 3921
	do -- 3921
		i = 0 -- 3922
		while i < #self.room.marks do -- 3922
			do -- 3922
				local m = self.room.marks[i + 1] -- 3923
				if m.kind ~= 0 then -- 3923
					goto __continue638 -- 3925
				end -- 3925
				local subjects = {self.partner, self.player} -- 3927
				local k = 0 -- 3928
				do -- 3928
					k = 0 -- 3929
					while k < #subjects do -- 3929
						do -- 3929
							local s = subjects[k + 1] -- 3930
							if not s.alive then -- 3930
								goto __continue641 -- 3932
							end -- 3932
							local dx = s.x - m.x -- 3934
							local dy = s.y - m.y -- 3935
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3935
								self.checkpoint = m.x -- 3937
								self.checkpointCartAxle = self.cartAxle -- 3938
								if self.isCampaign then -- 3938
									self:captureCheckpoint(m.x) -- 3941
								end -- 3941
								if self.cartDocked then -- 3941
									self:flashSet("检查点 · 车已落窝", 1) -- 3944
								else -- 3944
									self:flashSet("检查点 · 车还没到位", 1) -- 3946
								end -- 3946
							end -- 3946
						end -- 3946
						::__continue641:: -- 3946
						k = k + 1 -- 3929
					end -- 3929
				end -- 3929
			end -- 3929
			::__continue638:: -- 3929
			i = i + 1 -- 3922
		end -- 3922
	end -- 3922
	self:checkCarryGate() -- 3952
end -- 3876
function Play.prototype.stepVillage(self, dt, input) -- 3956
	if self.room.key ~= "village" then -- 3956
		return -- 3958
	end -- 3958
	local p = self.player -- 3960
	local bottle = self.room.bottle -- 3961
	local scav = self.room.scavenger -- 3962
	if not self.hasBottle and bottle ~= nil then -- 3962
		local dx = p.x - bottle.x -- 3966
		local dy = p.y + p.h * 0.5 - bottle.y -- 3967
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 3967
			self.hasBottle = true -- 3969
			self:flashSet("拾起瓶子", 0.8) -- 3970
		end -- 3970
	end -- 3970
	if self.hasBottle then -- 3970
		if input.aim.held then -- 3970
			self.aimHold = self.aimHold + dt -- 3977
			if self.aimHold > 1.2 then -- 3977
				self.aimHold = 1.2 -- 3979
			end -- 3979
			local cached = self:bottleEnd() -- 3982
			self.bottleAimX = cached.x -- 3983
			self.bottleAimY = cached.y -- 3984
		elseif input.aim.released then -- 3984
			if self.aimHold < 0.12 then -- 3984
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 3988
				self.aimHold = 0 -- 3989
			else -- 3989
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 3991
				self:throwBottle(____end.x, ____end.y) -- 3992
				self.aimHold = 0 -- 3993
			end -- 3993
		end -- 3993
	else -- 3993
		self.aimHold = 0 -- 3997
		self.bottleAimX = -1 -- 3998
	end -- 3998
	local fly = self.bottleFly -- 4003
	if fly ~= nil then -- 4003
		fly.t = fly.t + dt -- 4005
		fly.x = fly.x0 + fly.vx * fly.t -- 4006
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4007
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4008
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4008
			self:landBottle(fly) -- 4010
		end -- 4010
	end -- 4010
	if self.bottleLandT > 0 then -- 4010
		self.bottleLandT = self.bottleLandT - dt -- 4014
	end -- 4014
	if scav ~= nil then -- 4014
		self:stepScav(dt, scav) -- 4018
	end -- 4018
	local line = self.room.passLine -- 4021
	if line ~= nil and not self.passed and p.x >= line then -- 4021
		self.passed = true -- 4023
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4024
	end -- 4024
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4027
	if underTable then -- 4027
		self.footHintT = self.footHintT - 1 -- 4029
		if self.footHintT <= 0 then -- 4029
			self.footHintT = 90 -- 4031
			local scavX = self.scavX -- 4032
			local near = math.abs(scavX - p.x) < 120 -- 4033
			local heard = near or self.scavState == "walk" or self.scavState == "chase" -- 4034
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4035
			self:emit("storyBeat", {beat = near and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4036
		end -- 4036
	else -- 4036
		self.footHintT = 0 -- 4039
	end -- 4039
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4039
		self.ditchHinted = true -- 4043
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4044
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4045
	end -- 4045
	if self.passed and p.x >= self.ox + 640 then -- 4045
		self:requestRoom("forest", "过第一院出院") -- 4049
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4050
	end -- 4050
end -- 3956
function Play.prototype.bottleEnd(self) -- 4055
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4056
	local g = self:groundAt(aim.x, aim.y + 240, 3) -- 4059
	return {x = aim.x, y = g} -- 4060
end -- 4055
function Play.prototype.throwBottle(self, tx, ty) -- 4064
	local p = self.player -- 4065
	local dir = tx >= p.x and 1 or -1 -- 4067
	p.facing = dir -- 4068
	local x0 = p.x + dir * 10 -- 4069
	local y0 = p.y + p.h * 0.7 -- 4070
	self.bottleTargetX = tx -- 4071
	self.bottleTargetY = ty -- 4072
	self.bottleSurfaceY = ty -- 4073
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4074
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4075
	self.bottleFly = { -- 4076
		x = x0, -- 4076
		y = y0, -- 4076
		x0 = x0, -- 4076
		y0 = y0, -- 4076
		vx = vx, -- 4076
		vy = vy, -- 4076
		t = 0 -- 4076
	} -- 4076
	self.hasBottle = false -- 4077
	self:flashSet("投出", 0.4) -- 4078
	self:emit( -- 4079
		"bottleThrown", -- 4079
		{ -- 4079
			fromX = x0, -- 4080
			fromY = y0, -- 4081
			targetX = tx, -- 4082
			targetY = ty, -- 4083
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4084
		} -- 4084
	) -- 4084
end -- 4064
function Play.prototype.landBottle(self, fly) -- 4089
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4090
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4091
	local s = self.room.scavenger -- 4092
	local heard = s ~= nil and math.abs(x - self.scavX) <= s.range -- 4093
	self.bottleFly = nil -- 4094
	self.bottleTargetX = -1 -- 4095
	self.bottleTargetY = 0 -- 4096
	self.bottleSurfaceY = -1 -- 4097
	self.bottleLandX = x -- 4098
	self.bottleLandY = y -- 4099
	self.bottleLandT = 0.9 -- 4100
	self:emit("bottleLanded", {x = x, y = y, heard = heard, scavState = self.scavState}) -- 4101
	self:hearBottle(x) -- 4102
end -- 4089
function Play.prototype.hearBottle(self, x) -- 4106
	local s = self.room.scavenger -- 4107
	if s == nil then -- 4107
		return -- 4109
	end -- 4109
	if math.abs(x - self.scavX) > s.range then -- 4109
		self:flashSet("落地 · 他没听见", 0.6) -- 4112
		return -- 4113
	end -- 4113
	self.scavState = "turn" -- 4115
	self.scavT = s.hearTicks -- 4116
	self.scavTargetX = x -- 4117
	self:flashSet("砖地一响 · 他转头", 0.9) -- 4118
end -- 4106
function Play.prototype.stepScav(self, dt, s) -- 4122
	if self.scavState == "chase" then -- 4122
		return -- 4125
	end -- 4125
	if self.scavState == "turn" then -- 4125
		self.scavT = self.scavT - 1 -- 4128
		if self.scavT <= 0 then -- 4128
			self.scavState = "walk" -- 4130
		end -- 4130
		return -- 4132
	end -- 4132
	if self.scavState == "walk" then -- 4132
		local d = self.scavTargetX - self.scavX -- 4135
		if math.abs(d) < 4 then -- 4135
			self.scavState = "stall" -- 4137
			self.scavT = s.stallTicks -- 4138
			return -- 4139
		end -- 4139
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4141
		return -- 4142
	end -- 4142
	if self.scavState == "stall" then -- 4142
		self.scavT = self.scavT - 1 -- 4145
		if self.scavT <= 0 then -- 4145
			self.scavState = "back" -- 4147
		end -- 4147
		return -- 4149
	end -- 4149
	if self.scavState == "back" then -- 4149
		local home = math.max( -- 4152
			s.x0, -- 4152
			math.min(s.x1, self.scavX) -- 4152
		) -- 4152
		if math.abs(home - self.scavX) < 2 then -- 4152
			self.scavState = "patrol" -- 4154
			return -- 4155
		end -- 4155
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4157
		return -- 4158
	end -- 4158
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4160
	if self.scavX >= s.x1 then -- 4160
		self.scavX = s.x1 -- 4162
		self.scavDir = -1 -- 4163
	elseif self.scavX <= s.x0 then -- 4163
		self.scavX = s.x0 -- 4165
		self.scavDir = 1 -- 4166
	end -- 4166
end -- 4122
function Play.prototype.stepCart(self, dt, input) -- 4174
	local p = self.player -- 4175
	local c = self.room.cart -- 4176
	if self.gripping then -- 4176
		if not input.interact.held then -- 4176
			self.gripping = false -- 4180
			self:flashSet("松开车把", 0.4) -- 4181
			return -- 4182
		end -- 4182
	else -- 4182
		if not input.interact.pressed then -- 4182
			return -- 4186
		end -- 4186
		if not self:cartHandleInReach(p) then -- 4186
			return -- 4189
		end -- 4189
		local track = c.depth or 0 -- 4191
		if self:limitDepth(p, track) ~= track then -- 4191
			return -- 4193
		end -- 4193
		p.depth = track -- 4195
		p.depthSpeed = 0 -- 4196
		self.gripping = true -- 4197
		self:flashSet("握住车把", 0.4) -- 4198
		return -- 4199
	end -- 4199
	if self.cartDocked then -- 4199
		return -- 4203
	end -- 4203
	local dir = input.moveX -- 4205
	if dir == 0 then -- 4205
		return -- 4207
	end -- 4207
	local lo = math.min(c.startX, c.endX) -- 4209
	local hi = math.max(c.startX, c.endX) -- 4210
	local next = self.cartAxle + dir * CART_SPEED * dt -- 4211
	if next < lo then -- 4211
		next = lo -- 4213
	end -- 4213
	if next > hi then -- 4213
		next = hi -- 4216
	end -- 4216
	local delta = next - self.cartAxle -- 4218
	if delta == 0 then -- 4218
		return -- 4220
	end -- 4220
	self.cartAxle = next -- 4222
	p.x = p.x + delta -- 4223
	p.facing = dir > 0 and 1 or -1 -- 4224
	self:slideX(p, 0) -- 4225
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 4225
		self.gripping = false -- 4227
		self:flashSet("跟不上了，脱手", 0.6) -- 4228
		return -- 4229
	end -- 4229
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 4229
		self.cartDocked = true -- 4232
		self.gripping = false -- 4233
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 4234
		self:flashSet("车轮落窝", 1.2) -- 4235
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 4235
		self:flashSet("车轮回到起点", 0.5) -- 4237
	end -- 4237
end -- 4174
function Play.prototype.requestRoom(self, key, reason) -- 4245
	if self.wantRoom ~= "" then -- 4245
		return -- 4249
	end -- 4249
	self.wantRoom = key -- 4251
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 4252
end -- 4245
function Play.prototype.checkCarryGate(self) -- 4259
	if self.room.key == "checkpoint" then -- 4259
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 4259
			self.carryCartAxle = self.cartAxle -- 4262
			self.carryCartDocked = self.cartDocked -- 4263
			self:requestRoom("gate", "检查站出口") -- 4264
			self:flashSet("出检查站 · 城门", 1.2) -- 4265
		end -- 4265
		return -- 4267
	end -- 4267
	if self.room.key == "outside" then -- 4267
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 4267
			self.carryCartAxle = self.cartAxle -- 4273
			self.carryCartDocked = self.cartDocked -- 4274
			self:requestRoom("village", "墙根走完") -- 4275
			self:flashSet("墙根走完 · 进村口", 1.2) -- 4276
		end -- 4276
	end -- 4276
end -- 4259
function Play.prototype.aimAt(self, wx, wy) -- 4283
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 4284
	self.aimX = s.x -- 4285
	self.aimY = s.y -- 4286
end -- 4283
function Play.prototype.shoot(self, a) -- 4289
	if self.isCampaign and self.reloadT > 0 then -- 4289
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 4291
		return -- 4292
	end -- 4292
	local ox = a.x + a.facing * 8 -- 4294
	local muzzleY = a.y + a.h * 0.72 -- 4295
	local oy = muzzleY + a.depth -- 4296
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4298
	local dx = aim.x - ox -- 4301
	local dy = aim.y - oy -- 4302
	local len = math.sqrt(dx * dx + dy * dy) -- 4303
	if len < 0.001 then -- 4303
		dx = a.facing -- 4305
		dy = 0 -- 4306
	else -- 4306
		dx = dx / len -- 4308
		dy = dy / len -- 4309
	end -- 4309
	if dx ~= 0 then -- 4309
		a.facing = dx > 0 and 1 or -1 -- 4312
	end -- 4312
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 4315
	local hitEnemy = self:raycastEnemies(ray) -- 4316
	local tEnemy = hitEnemy.t -- 4317
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 4318
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 4319
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth, depth = a.depth, dDepth = dDepth})) -- 4320
	local tWall = solid.t -- 4321
	local rawEffect = self:consumeReloadEffect() -- 4323
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 4324
	local reloadEffect = rawEffect -- 4325
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 4327
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 4328
	self.trace = { -- 4330
		x0 = ox, -- 4330
		y0 = oy, -- 4330
		x1 = ox + dx * t, -- 4330
		y1 = oy + dy * t, -- 4330
		hit = hit -- 4330
	} -- 4330
	self.traceT = 0.12 -- 4331
	self:applyFireDanger(ox) -- 4332
	local killed = false -- 4333
	if hit then -- 4333
		local i = hitEnemy.index -- 4335
		local e = self.enemies[i + 1] -- 4336
		local impactY = oy + dy * tEnemy -- 4337
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 4338
		local shieldTop = e.y + (e.depth or 0) + 64 -- 4339
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 4339
			e.shieldHp = (e.shieldHp or 0) - 1 -- 4341
			e.hitT = 0.3 -- 4342
			self:flashSet( -- 4343
				(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 4343
				0.8 -- 4343
			) -- 4343
			self:emit("shotResolved", { -- 4344
				hit = true, -- 4345
				enemyIndex = i, -- 4345
				enemyX = e.x, -- 4345
				aimX = aim.x, -- 4345
				aimY = aim.y, -- 4345
				impactX = ox + dx * t, -- 4346
				impactY = oy + dy * t, -- 4346
				shield = true -- 4346
			}) -- 4346
			self:beginReload() -- 4348
			return -- 4349
		end -- 4349
		e.alive = false -- 4351
		e.hitT = 0.4 -- 4352
		killed = true -- 4353
		self:flashSet("命中", 0.6) -- 4354
		self:dropFor(e) -- 4355
		if reloadEffect == "light" and weaponFx == "light" then -- 4355
			self:blindNearby(e, 160, i) -- 4357
		end -- 4357
		if reloadEffect == "push" then -- 4357
			e.x = e.x + a.facing * 46 -- 4360
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 4361
		elseif reloadEffect == "echo" then -- 4361
			self:echoToSource(a, weaponFx == "echo" and 2 or 1) -- 4363
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 4364
		elseif reloadEffect == "light" then -- 4364
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 4366
		end -- 4366
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 4366
		self:damageProp(solid.box, 1) -- 4369
	else -- 4369
		self:flashSet("打空", 0.35) -- 4371
	end -- 4371
	if self.isCampaign then -- 4371
		self:beginReload() -- 4374
	end -- 4374
	self:emit("shotResolved", { -- 4376
		hit = hit, -- 4377
		enemyIndex = hit and hitEnemy.index or -1, -- 4378
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 4379
		aimX = aim.x, -- 4380
		aimY = aim.y, -- 4381
		impactX = ox + dx * t, -- 4382
		impactY = oy + dy * t -- 4383
	}) -- 4383
end -- 4289
function Play.prototype.applyFireDanger(self, shotX) -- 4388
	if self.room.key ~= "checkpoint" or not self.partner.alive then -- 4388
		return -- 4390
	end -- 4390
	local dangerX = shotX -- 4392
	local best = -1 -- 4393
	local bestD = 1000000000 -- 4394
	local i = 0 -- 4395
	do -- 4395
		i = 0 -- 4396
		while i < #self.enemies do -- 4396
			do -- 4396
				local e = self.enemies[i + 1] -- 4397
				if not e.alive then -- 4397
					goto __continue726 -- 4399
				end -- 4399
				local d = math.abs(e.x - self.partner.x) -- 4401
				if d < bestD then -- 4401
					bestD = d -- 4403
					best = i -- 4404
				end -- 4404
			end -- 4404
			::__continue726:: -- 4404
			i = i + 1 -- 4396
		end -- 4396
	end -- 4396
	if best >= 0 then -- 4396
		dangerX = self.enemies[best + 1].x -- 4408
	end -- 4408
	local exposed = self:childExposed(dangerX) -- 4410
	local before = self.escort.fear -- 4411
	local dangerId = self.nextDangerId -- 4412
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 4413
	self.nextDangerId = self.nextDangerId + 1 -- 4414
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 4415
	if after > before then -- 4415
		self:flashSet( -- 4417
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 4417
			1 -- 4417
		) -- 4417
	elseif not exposed then -- 4417
		self:flashSet("枪声没够到她", 0.5) -- 4419
	end -- 4419
end -- 4388
function Play.prototype.childExposed(self, dangerX) -- 4424
	local c = self.partner -- 4425
	if not c.alive then -- 4425
		return false -- 4427
	end -- 4427
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 4427
		self.boxes, -- 4430
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 4430
	) then -- 4430
		return false -- 4431
	end -- 4431
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 4431
		return false -- 4434
	end -- 4434
	local toDanger = dangerX - c.x -- 4436
	local toPlayer = self.player.x - c.x -- 4437
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 4437
		return false -- 4440
	end -- 4440
	return true -- 4442
end -- 4424
function Play.prototype.raycastEnemies(self, ray) -- 4446
	local best = -1 -- 4447
	local bestI = -1 -- 4448
	do -- 4448
		local i = 0 -- 4449
		while i < #self.enemies do -- 4449
			do -- 4449
				local e = self.enemies[i + 1] -- 4450
				if not e.alive then -- 4450
					goto __continue740 -- 4452
				end -- 4452
				local y = e.y + (e.depth or 0) -- 4454
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 4455
				if t >= 0 and (best < 0 or t < best) then -- 4455
					best = t -- 4457
					bestI = i -- 4458
				end -- 4458
			end -- 4458
			::__continue740:: -- 4458
			i = i + 1 -- 4449
		end -- 4449
	end -- 4449
	return {t = best, index = bestI} -- 4461
end -- 4446
function Play.prototype.raycastWorld(self, ray) -- 4464
	return self:raycastSolid(ray).t -- 4465
end -- 4464
function Play.prototype.raycastSolid(self, ray) -- 4469
	local best = -1 -- 4470
	local bestBox = nil -- 4471
	for ____, box in ipairs(self.boxes) do -- 4472
		do -- 4472
			if box.broken == true or box.hidden == true then -- 4472
				goto __continue745 -- 4474
			end -- 4474
			local t = hitBox(ray, box) -- 4479
			if t > 2 and (best < 0 or t < best) then -- 4479
				best = t -- 4482
				bestBox = box -- 4483
			end -- 4483
		end -- 4483
		::__continue745:: -- 4483
	end -- 4483
	if ray.dy < 0 then -- 4483
		local t = -ray.y / ray.dy -- 4487
		if t >= 0 and (best < 0 or t < best) then -- 4487
			best = t -- 4489
			bestBox = nil -- 4490
		end -- 4490
	end -- 4490
	return {t = best, box = bestBox} -- 4493
end -- 4469
function Play.prototype.dropFor(self, e) -- 4497
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 4497
		return -- 4499
	end -- 4499
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 4499
		return -- 4502
	end -- 4502
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 4504
	local ____self_pickups_57 = self.pickups -- 4504
	____self_pickups_57[#____self_pickups_57 + 1] = { -- 4505
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 4506
		kind = e.drop, -- 4506
		x = e.x, -- 4506
		y = e.y, -- 4506
		depth = e.depth, -- 4507
		label = label .. " ×1" -- 4507
	} -- 4507
	self:log("掉落 " .. label) -- 4509
end -- 4497
function Play.prototype.damageProp(self, b, amount) -- 4513
	if b.breakable == nil or b.broken == true then -- 4513
		return -- 4515
	end -- 4515
	local ____b_breakable_58, ____hp_59 = b.breakable, "hp" -- 4515
	____b_breakable_58[____hp_59] = ____b_breakable_58[____hp_59] - amount -- 4517
	if b.breakable.hp > 0 then -- 4517
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 4519
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 4520
		return -- 4521
	end -- 4521
	b.broken = true -- 4523
	for ____, other in ipairs(self.boxes) do -- 4524
		if other.id ~= nil and other.id == b.id then -- 4524
			other.broken = true -- 4526
		end -- 4526
	end -- 4526
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 4529
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 4530
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 4531
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 4532
end -- 4513
function Play.prototype.slideDepth(self, a, distance) -- 4536
	a.depth = self:limitDepth(a, a.depth + distance) -- 4537
end -- 4536
function Play.prototype.limitDepth(self, a, target) -- 4540
	local road = self.room.depth -- 4541
	if road == nil or target == a.depth then -- 4541
		return a.depth -- 4543
	end -- 4543
	local next = math.max( -- 4545
		road.min, -- 4545
		math.min(road.max, target) -- 4545
	) -- 4545
	local half = a.w / 2 -- 4546
	for ____, b in ipairs(self.boxes) do -- 4547
		do -- 4547
			local footprint = b.depth -- 4548
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4548
				goto __continue763 -- 4553
			end -- 4553
			local front = footprint.min - ACTOR_DEPTH_HALF -- 4555
			local back = footprint.max + ACTOR_DEPTH_HALF -- 4556
			if a.depth <= front and next > front then -- 4556
				next = front -- 4558
			elseif a.depth >= back and next < back then -- 4558
				next = back -- 4560
			end -- 4560
		end -- 4560
		::__continue763:: -- 4560
	end -- 4560
	return next -- 4563
end -- 4540
function Play.prototype.slideX(self, a, dx) -- 4567
	local nx = a.x + dx -- 4568
	local half = a.w / 2 -- 4569
	local room = self.room -- 4570
	nx = math.max( -- 4571
		room.minX + half, -- 4571
		math.min(room.maxX - half, nx) -- 4571
	) -- 4571
	local i = 0 -- 4572
	do -- 4572
		i = 0 -- 4573
		while i < #self.boxes do -- 4573
			do -- 4573
				local b = self.boxes[i + 1] -- 4574
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4574
					goto __continue770 -- 4576
				end -- 4576
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4576
					goto __continue770 -- 4579
				end -- 4579
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 4579
					goto __continue770 -- 4582
				end -- 4582
				if nx + half > b.x0 and nx - half < b.x1 then -- 4582
					if a.x <= b.x0 then -- 4582
						nx = b.x0 - half -- 4586
					elseif a.x >= b.x1 then -- 4586
						nx = b.x1 + half -- 4588
					else -- 4588
						nx = a.x -- 4590
					end -- 4590
				end -- 4590
			end -- 4590
			::__continue770:: -- 4590
			i = i + 1 -- 4573
		end -- 4573
	end -- 4573
	if self.room.key == "outside" and a.y < CART_CLEAR - 0.001 then -- 4573
		local blocked = not self.cartDocked or a.y + a.h > CART_CLEAR + 0.001 -- 4598
		local bx0 = self.cartAxle - CART_HALF -- 4599
		local bx1 = self.cartAxle + CART_HALF -- 4600
		if blocked and nx + half > bx0 and nx - half < bx1 then -- 4600
			if a.x <= bx0 then -- 4600
				nx = bx0 - half -- 4603
			elseif a.x >= bx1 then -- 4603
				nx = bx1 + half -- 4605
			else -- 4605
				nx = a.x -- 4607
			end -- 4607
		end -- 4607
	end -- 4607
	local arch = room.arch -- 4615
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 4615
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 4617
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 4617
			if a.x <= arch.x0 then -- 4617
				nx = arch.x0 - half -- 4620
			elseif a.x >= arch.x1 then -- 4620
				nx = arch.x1 + half -- 4622
			end -- 4622
		end -- 4622
	end -- 4622
	a.x = nx -- 4626
end -- 4567
function Play.prototype.fallY(self, a, dt) -- 4630
	a.vy = a.vy - ____exports.GRAVITY * dt -- 4631
	if a.vy < -900 then -- 4631
		a.vy = -900 -- 4633
	end -- 4633
	local ny = a.y + a.vy * dt -- 4635
	local half = a.w / 2 -- 4636
	if a.vy <= 0 then -- 4636
		local reach = a.onGround and STEP_UP or 0 -- 4639
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 4640
		if ny <= ground then -- 4640
			ny = ground -- 4642
			a.vy = 0 -- 4643
			a.onGround = true -- 4644
		else -- 4644
			a.onGround = false -- 4646
		end -- 4646
	else -- 4646
		a.onGround = false -- 4649
		local i = 0 -- 4650
		do -- 4650
			i = 0 -- 4651
			while i < #self.boxes do -- 4651
				do -- 4651
					local b = self.boxes[i + 1] -- 4652
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 4652
						goto __continue794 -- 4654
					end -- 4654
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 4654
						goto __continue794 -- 4657
					end -- 4657
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 4657
						goto __continue794 -- 4660
					end -- 4660
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 4660
						ny = b.y0 - a.h -- 4663
						a.vy = 0 -- 4664
					end -- 4664
				end -- 4664
				::__continue794:: -- 4664
				i = i + 1 -- 4651
			end -- 4651
		end -- 4651
	end -- 4651
	a.y = ny -- 4668
end -- 4630
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 4672
	if depth == nil then -- 4672
		depth = 0 -- 4672
	end -- 4672
	local g = -9999 -- 4673
	local i = 0 -- 4674
	do -- 4674
		i = 0 -- 4675
		while i < #self.floors do -- 4675
			local f = self.floors[i + 1] -- 4676
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 4676
				g = f.y1 -- 4678
			end -- 4678
			i = i + 1 -- 4675
		end -- 4675
	end -- 4675
	do -- 4675
		i = 0 -- 4681
		while i < #self.boxes do -- 4681
			do -- 4681
				local b = self.boxes[i + 1] -- 4682
				if b.broken == true or b.hidden == true or b.soft == true then -- 4682
					goto __continue804 -- 4684
				end -- 4684
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 4684
					g = b.y1 -- 4688
				end -- 4688
			end -- 4688
			::__continue804:: -- 4688
			i = i + 1 -- 4681
		end -- 4681
	end -- 4681
	return g -- 4691
end -- 4672
function Play.prototype.updateCamera(self, dt) -- 4694
	local p = self.player -- 4695
	local tx = p.x + p.facing * 30 -- 4696
	local ty = p.y + CAM_LOOK_UP -- 4697
	local k = math.min(1, CAM_FOLLOW * dt) -- 4698
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 4699
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 4700
end -- 4694
function Play.prototype.clampCamera(self, w, h) -- 4704
	local room = self.room -- 4705
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 4706
	local spanX = room.maxX - room.minX -- 4707
	if spanX <= halfW * 2 then -- 4707
		self.cam.x = (room.minX + room.maxX) / 2 -- 4709
	else -- 4709
		self.cam.x = math.max( -- 4711
			room.minX + halfW, -- 4711
			math.min(room.maxX - halfW, self.cam.x) -- 4711
		) -- 4711
	end -- 4711
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 4714
	local spanY = room.height -- 4715
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 4716
	if spanY <= halfH * 2 then -- 4716
		self.cam.y = camY -- 4718
	else -- 4718
		self.cam.y = math.max( -- 4720
			camY, -- 4720
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 4720
		) -- 4720
	end -- 4720
end -- 4704
function Play.prototype.flashSet(self, text, t) -- 4724
	self.flash = text -- 4725
	self.flashT = t -- 4726
end -- 4724
function Play.prototype.statusText(self) -- 4730
	local p = self.player -- 4731
	local parts = {} -- 4732
	local who = self.childMode and "小满" or "周戍" -- 4733
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 4734
	if self.room.key == "prologue" then -- 4734
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4737
		if self.phase == "prologue-wake" then -- 4737
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 4739
		elseif self.phase == "prologue-shadow" then -- 4739
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 4741
		elseif self.phase == "prologue-escape" then -- 4741
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 4743
		elseif self.phase == "prologue-hide" then -- 4743
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 4745
		elseif self.phase == "prologue-wait" then -- 4745
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 4747
		elseif self.phase == "prologue-give" then -- 4747
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 4749
		else -- 4749
			parts[#parts + 1] = "跟随" -- 4751
		end -- 4751
		if self.paused then -- 4751
			parts[#parts + 1] = "已暂停" -- 4754
		end -- 4754
		return table.concat(parts, " · ") -- 4756
	end -- 4756
	if self.room.key == "street" then -- 4756
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4759
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4760
		if self.paused then -- 4760
			parts[#parts + 1] = "已暂停" -- 4762
		end -- 4762
		return table.concat(parts, " · ") -- 4764
	end -- 4764
	if self.room.key == "gate" then -- 4764
		local ____temp_60 -- 4767
		if self.room.story == nil then -- 4767
			____temp_60 = nil -- 4767
		else -- 4767
			____temp_60 = self.room.story.gate -- 4767
		end -- 4767
		local g = ____temp_60 -- 4767
		if g ~= nil then -- 4767
			parts[#parts + 1] = self:gateLabel() -- 4769
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 4770
				0, -- 4771
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 4771
			))) .. " 秒" -- 4771
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 4772
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4773
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 4774
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 4775
			if self.gateFailCount > 0 then -- 4775
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 4777
			end -- 4777
			if self.flash ~= "" then -- 4777
				parts[#parts + 1] = self.flash -- 4780
			end -- 4780
		end -- 4780
		if self.paused then -- 4780
			parts[#parts + 1] = "已暂停" -- 4784
		end -- 4784
		return table.concat(parts, " · ") -- 4786
	end -- 4786
	if self.room.key == "forest" then -- 4786
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4789
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 4790
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 4791
		if self.caughtT > 0 then -- 4791
			parts[#parts + 1] = "复位中" -- 4793
		end -- 4793
		if self.paused then -- 4793
			parts[#parts + 1] = "已暂停" -- 4796
		end -- 4796
		return table.concat(parts, " · ") -- 4798
	end -- 4798
	if self.room.key == "tower" then -- 4798
		if self.phase == "tower-wait" then -- 4798
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 4802
		elseif self.phase == "tower-knock" then -- 4802
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 4804
		elseif self.phase == "tower-given" then -- 4804
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 4806
		else -- 4806
			parts[#parts + 1] = "片尾" -- 4808
		end -- 4808
		if self.paused then -- 4808
			parts[#parts + 1] = "已暂停" -- 4811
		end -- 4811
		return table.concat(parts, " · ") -- 4813
	end -- 4813
	if self.room.key == "village" then -- 4813
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4816
		if self.hasBottle then -- 4816
			parts[#parts + 1] = "有瓶" -- 4818
		elseif self.bottleFly ~= nil then -- 4818
			parts[#parts + 1] = "瓶在飞" -- 4820
		else -- 4820
			parts[#parts + 1] = "空手" -- 4822
		end -- 4822
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 4824
		if self.scavChase then -- 4824
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 4826
		end -- 4826
		if self.passed then -- 4826
			parts[#parts + 1] = "已过通行线" -- 4829
		end -- 4829
		if self.paused then -- 4829
			parts[#parts + 1] = "已暂停" -- 4832
		end -- 4832
		return table.concat(parts, " · ") -- 4834
	end -- 4834
	local isChild = self.childMode -- 4837
	if isChild then -- 4837
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 4839
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 4840
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4841
	else -- 4841
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 4843
		if p.rollT > 0 then -- 4843
			parts[#parts + 1] = "翻滚中" -- 4845
		end -- 4845
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 4847
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 4848
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 4849
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 4850
	end -- 4850
	if self.checkpoint >= 0 then -- 4850
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 4853
	end -- 4853
	if self.paused then -- 4853
		parts[#parts + 1] = "已暂停" -- 4856
	end -- 4856
	return table.concat(parts, " · ") -- 4858
end -- 4730
function Play.prototype.aliveEnemies(self) -- 4862
	local n = 0 -- 4863
	local i = 0 -- 4864
	do -- 4864
		i = 0 -- 4865
		while i < #self.enemies do -- 4865
			if self.enemies[i + 1].alive then -- 4865
				n = n + 1 -- 4867
			end -- 4867
			i = i + 1 -- 4865
		end -- 4865
	end -- 4865
	return n -- 4870
end -- 4862
function Play.prototype.threatened(self) -- 4875
	do -- 4875
		local i = 0 -- 4876
		while i < #self.enemies do -- 4876
			local e = self.enemies[i + 1] -- 4877
			if e.alive and e.warnT > 0 then -- 4877
				return true -- 4879
			end -- 4879
			i = i + 1 -- 4876
		end -- 4876
	end -- 4876
	return false -- 4882
end -- 4875
function Play.prototype.gateSecondsLeft(self) -- 4885
	local ____temp_61 -- 4886
	if self.room.story == nil then -- 4886
		____temp_61 = nil -- 4886
	else -- 4886
		____temp_61 = self.room.story.gate -- 4886
	end -- 4886
	local g = ____temp_61 -- 4886
	if g == nil then -- 4886
		return 0 -- 4888
	end -- 4888
	return math.max( -- 4890
		0, -- 4890
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 4890
	) -- 4890
end -- 4885
function Play.prototype.gateLabel(self) -- 4893
	if self.phase == "gate-idle" then -- 4893
		return "待就位" -- 4895
	end -- 4895
	if self.phase == "gate-hold" then -- 4895
		return "守点中" -- 4898
	end -- 4898
	if self.phase == "gate-send" then -- 4898
		return "送别" -- 4901
	end -- 4901
	if self.phase == "gate-count" then -- 4901
		return "数数 " .. tostring(self.countTick) -- 4904
	end -- 4904
	return "她走" -- 4906
end -- 4893
function Play.prototype.dogLabel(self) -- 4910
	if self.dogState == "ear" then -- 4910
		return "转耳" -- 4912
	end -- 4912
	if self.dogState == "chase" then -- 4912
		return "追" -- 4915
	end -- 4915
	if self.dogState == "sniff" then -- 4915
		return "停" -- 4918
	end -- 4918
	if self.dogState == "back" then -- 4918
		return "回线" -- 4921
	end -- 4921
	return "巡逻" -- 4923
end -- 4910
function Play.prototype.doorXOf(self) -- 4926
	local ____temp_62 -- 4927
	if self.room.story == nil then -- 4927
		____temp_62 = nil -- 4927
	else -- 4927
		____temp_62 = self.room.story.tower -- 4927
	end -- 4927
	local t = ____temp_62 -- 4927
	return t == nil and 0 or t.doorX -- 4928
end -- 4926
function Play.prototype.scavLabel(self) -- 4932
	if self.scavState == "chase" then -- 4932
		return "追" -- 4934
	end -- 4934
	if self.scavState == "turn" then -- 4934
		return "转头" -- 4937
	end -- 4937
	if self.scavState == "walk" then -- 4937
		return "赶来" -- 4940
	end -- 4940
	if self.scavState == "stall" then -- 4940
		return "停住" -- 4943
	end -- 4943
	if self.scavState == "back" then -- 4943
		return "回位" -- 4946
	end -- 4946
	return "巡逻" -- 4948
end -- 4932
function Play.prototype.hintText(self) -- 4952
	if self.paused then -- 4952
		return "Esc 继续 · R 重置" -- 4954
	end -- 4954
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 4954
		if self:threatened() then -- 4954
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 4960
		end -- 4960
		if self.coverHug then -- 4960
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 4963
		end -- 4963
		if self.coverNear then -- 4963
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 4966
		end -- 4966
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 4968
	end -- 4968
	if self.flash ~= "" then -- 4968
		return self.flash -- 4971
	end -- 4971
	if self.room.key == "prologue" then -- 4971
		if self.phase == "prologue-wake" then -- 4971
			return "父亲在门外唤 · 小满睁眼" -- 4975
		end -- 4975
		if self.phase == "prologue-shadow" then -- 4975
			return "墙上两道人影 · 碗滚到脚边" -- 4978
		end -- 4978
		if self.phase == "prologue-escape" then -- 4978
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 4981
		end -- 4981
		if self.phase == "prologue-hide" then -- 4981
			return "柜门合上 · 屏住呼吸" -- 4984
		end -- 4984
		if self.phase == "prologue-wait" then -- 4984
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 4987
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 4988
		end -- 4988
		if self.phase == "prologue-give" then -- 4988
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 4991
		end -- 4991
		return "她跟着你了 · 两人一起走到门口 680" -- 4993
	end -- 4993
	if self.room.key == "street" then -- 4993
		if self:aliveEnemies() > 0 then -- 4993
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 4997
		end -- 4997
		return "清完了 · 两人一起走到右边检查站入口 900" -- 4999
	end -- 4999
	if self.room.key == "gate" then -- 4999
		local ____temp_63 -- 5002
		if self.room.story == nil then -- 5002
			____temp_63 = nil -- 5002
		else -- 5002
			____temp_63 = self.room.story.gate -- 5002
		end -- 5002
		local g = ____temp_63 -- 5002
		if g ~= nil then -- 5002
			if self.phase == "gate-idle" then -- 5002
				if self.gateNeedConfirm then -- 5002
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5006
				end -- 5006
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5008
			end -- 5008
			if self.phase == "gate-hold" then -- 5008
				if self.coveredFlash > 0 then -- 5008
					return "掩体挡下了这一枪 · 别露头" -- 5012
				end -- 5012
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5014
			end -- 5014
			if self.phase == "gate-send" then -- 5014
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5017
			end -- 5017
			if self.phase == "gate-count" then -- 5017
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5017
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5021
				end -- 5021
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5023
			end -- 5023
			return "她自己走 · 跟着出城门 1120" -- 5025
		end -- 5025
	end -- 5025
	if self.room.key == "forest" then -- 5025
		if self.dogState == "chase" then -- 5025
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5030
		end -- 5030
		if self.dogState == "ear" then -- 5030
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5033
		end -- 5033
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5035
	end -- 5035
	if self.room.key == "tower" then -- 5035
		if self.phase == "tower-wait" then -- 5035
			return "走到门前 445 点一次 E 敲两下" -- 5039
		end -- 5039
		if self.phase == "tower-knock" then -- 5039
			return "敲两下 · 等门开" -- 5042
		end -- 5042
		if self.phase == "tower-given" then -- 5042
			return "递交针套和纸条 · 看登记簿最后一行" -- 5045
		end -- 5045
		return "片尾 · 点 E 再玩一次，回到序章" -- 5047
	end -- 5047
	if self.room.key == "village" then -- 5047
		if self.bottleFly ~= nil then -- 5047
			return "等瓶子落地 · 触地才发声" -- 5051
		end -- 5051
		if self.hasBottle then -- 5051
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5054
		end -- 5054
		if self.passed then -- 5054
			return "已过第一院 · R 重置可再来一遍" -- 5057
		end -- 5057
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5059
	end -- 5059
	if self.room.key == "outside" then -- 5059
		if self.focusCart then -- 5059
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5063
		end -- 5063
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5065
	end -- 5065
	if self.escort.state == "frozen" then -- 5065
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5065
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5069
		end -- 5069
		return "小满吓住了 · 走过去，靠近再点 E" -- 5071
	end -- 5071
	if self.escort.state == "calming" then -- 5071
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5074
	end -- 5074
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5076
end -- 4952
function Play.prototype.draw(self, draw, w, h) -- 5081
	self.viewW = w -- 5082
	self.viewH = h -- 5083
	self.view = ____exports.computeViewport(w, h) -- 5084
	self:clampCamera(w, h) -- 5085
	draw:clear() -- 5086
	draw:drawRect( -- 5088
		Rect(0, 0, w, h), -- 5088
		BG_VOID -- 5088
	) -- 5088
	local box = self:canvasRect(w, h) -- 5089
	draw:drawRect(box, BG_FAR) -- 5090
	draw:drawRect( -- 5091
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5091
		BG_MID -- 5091
	) -- 5091
	self:drawFloors(draw, w, h) -- 5093
	self:drawSolids(draw, w, h) -- 5094
	self:drawZones(draw, w, h) -- 5095
	self:drawArch(draw, w, h) -- 5096
	self:drawCart(draw, w, h) -- 5097
	self:drawCampaignProps(draw, w, h) -- 5098
	self:drawActors(draw, w, h) -- 5099
	self:drawTrace(draw, w, h) -- 5100
	self:drawAim(draw, w, h) -- 5101
end -- 5081
function Play.prototype.canvasRect(self, w, h) -- 5105
	local v = self.view -- 5106
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5107
end -- 5105
function Play.prototype.px(self, n) -- 5111
	return n * self.view.zoom -- 5112
end -- 5111
function Play.prototype.sx(self, wx, w) -- 5116
	local v = self.view -- 5117
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5118
	return v.ox + lx * v.zoom -- 5119
end -- 5116
function Play.prototype.sy(self, wy, h) -- 5123
	local v = self.view -- 5124
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5125
	return v.oy + ly * v.zoom -- 5126
end -- 5123
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5129
	local px0 = self:sx(x0, w) -- 5130
	local px1 = self:sx(x1, w) -- 5131
	local py0 = self:sy(y0, h) -- 5132
	local py1 = self:sy(y1, h) -- 5133
	if px1 <= px0 or py1 <= py0 then -- 5133
		return -- 5135
	end -- 5135
	draw:drawRect( -- 5137
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5137
		color -- 5137
	) -- 5137
end -- 5129
function Play.prototype.drawFloors(self, draw, w, h) -- 5140
	local i = 0 -- 5141
	do -- 5141
		i = 0 -- 5142
		while i < #self.room.floors do -- 5142
			local f = self.room.floors[i + 1] -- 5143
			local ____temp_64 -- 5144
			if f.y == 0 then -- 5144
				____temp_64 = self.room.depth -- 5144
			else -- 5144
				____temp_64 = nil -- 5144
			end -- 5144
			local road = ____temp_64 -- 5144
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5145
			local x0 = self:sx(f.x0, w) -- 5146
			local x1 = self:sx(f.x1, w) -- 5147
			local deck = self:px(5) -- 5148
			if road ~= nil then -- 5148
				local back = self:sy(f.y + road.max, h) -- 5150
				draw:drawRect( -- 5151
					Rect(x0, y, x1 - x0, back - y), -- 5151
					FLOOR_DECK, -- 5151
					self:px(1), -- 5151
					SOLID_EDGE -- 5151
				) -- 5151
			end -- 5151
			draw:drawRect( -- 5153
				Rect(x0, y - deck, x1 - x0, deck), -- 5153
				FLOOR_DECK -- 5153
			) -- 5153
			draw:drawSegment( -- 5154
				Vec2(x0, y), -- 5154
				Vec2(x1, y), -- 5154
				self:px(1), -- 5154
				GROUND -- 5154
			) -- 5154
			i = i + 1 -- 5142
		end -- 5142
	end -- 5142
end -- 5140
function Play.prototype.drawSolids(self, draw, w, h) -- 5158
	local i = 0 -- 5159
	do -- 5159
		i = 0 -- 5160
		while i < #self.boxes do -- 5160
			do -- 5160
				local b = self.boxes[i + 1] -- 5161
				if b.id == "braced_shield" or b.hidden == true then -- 5161
					goto __continue933 -- 5163
				end -- 5163
				if b.broken == true then -- 5163
					if b.breakable ~= nil then -- 5163
						local gy = self:sy(b.y0, h) -- 5168
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 5169
						local k = 0 -- 5170
						do -- 5170
							k = 0 -- 5171
							while k < 3 do -- 5171
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 5172
								draw:drawSegment( -- 5173
									Vec2( -- 5173
										gx - self:px(4), -- 5173
										gy + self:px(k % 2) -- 5173
									), -- 5173
									Vec2( -- 5173
										gx + self:px(5), -- 5173
										gy + self:px(k % 2) -- 5173
									), -- 5173
									self:px(1), -- 5173
									rgb -- 5173
								) -- 5173
								k = k + 1 -- 5171
							end -- 5171
						end -- 5171
					end -- 5171
					goto __continue933 -- 5176
				end -- 5176
				local ____opt_67 = b.depth -- 5176
				local front = ____opt_67 and ____opt_67.min or 0 -- 5178
				local ____opt_69 = b.depth -- 5178
				local back = ____opt_69 and ____opt_69.max or 0 -- 5179
				local fill = SOLID_FILL -- 5180
				local line = SOLID_EDGE -- 5181
				if b.soft == true then -- 5181
					fill = SOFT -- 5183
					line = SOFT_LINE -- 5184
				elseif b.breakable ~= nil then -- 5184
					line = DANGER_LINE -- 5186
					fill = Color(0.3, 0.24, 0.16, 1) -- 5187
				elseif b.interact ~= nil then -- 5187
					line = PASS_LINE -- 5189
				end -- 5189
				self:drawBox( -- 5191
					draw, -- 5191
					w, -- 5191
					h, -- 5191
					b.x0, -- 5191
					b.x1, -- 5191
					b.y0 + front, -- 5191
					b.y1 + back, -- 5191
					fill -- 5191
				) -- 5191
				draw:drawSegment( -- 5192
					Vec2( -- 5192
						self:sx(b.x0, w), -- 5192
						self:sy(b.y1 + front, h) -- 5192
					), -- 5192
					Vec2( -- 5193
						self:sx(b.x1, w), -- 5193
						self:sy(b.y1 + front, h) -- 5193
					), -- 5193
					self:px(1), -- 5193
					line -- 5193
				) -- 5193
				if b.breakable ~= nil then -- 5193
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 5196
					local cyp = self:sy(b.y1 + front, h) -- 5197
					draw:drawSegment( -- 5198
						Vec2( -- 5198
							cxp - self:px(4), -- 5198
							cyp + self:px(1) -- 5198
						), -- 5198
						Vec2( -- 5198
							cxp + self:px(3), -- 5198
							cyp + self:px(5) -- 5198
						), -- 5198
						self:px(1), -- 5198
						line -- 5198
					) -- 5198
				end -- 5198
			end -- 5198
			::__continue933:: -- 5198
			i = i + 1 -- 5160
		end -- 5160
	end -- 5160
end -- 5158
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 5204
	local i = 0 -- 5205
	do -- 5205
		i = 0 -- 5206
		while i < #self.pickups do -- 5206
			do -- 5206
				local pk = self.pickups[i + 1] -- 5207
				if self.run.taken[pk.id] == true then -- 5207
					goto __continue945 -- 5209
				end -- 5209
				local gy = pk.y + (pk.depth or 0) -- 5211
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 5212
				draw:drawRect( -- 5213
					Rect( -- 5213
						self:sx(pk.x - 5, w), -- 5213
						self:sy(gy + 12 + bob, h), -- 5213
						self:px(10), -- 5213
						self:px(10) -- 5213
					), -- 5213
					Color(0.84, 0.7, 0.3, 1) -- 5214
				) -- 5214
				draw:drawSegment( -- 5215
					Vec2( -- 5215
						self:sx(pk.x - 5, w), -- 5215
						self:sy(gy + 12 + bob, h) -- 5215
					), -- 5215
					Vec2( -- 5216
						self:sx(pk.x + 5, w), -- 5216
						self:sy(gy + 12 + bob, h) -- 5216
					), -- 5216
					self:px(1), -- 5216
					Color(0.95, 0.86, 0.52, 1) -- 5216
				) -- 5216
			end -- 5216
			::__continue945:: -- 5216
			i = i + 1 -- 5206
		end -- 5206
	end -- 5206
	if self.bracedShield ~= nil then -- 5206
		local sh = self.bracedShield -- 5219
		draw:drawRect( -- 5220
			Rect( -- 5220
				self:sx(sh.x - sh.w / 2, w), -- 5220
				self:sy(sh.y, h), -- 5220
				self:px(sh.w), -- 5220
				self:px(sh.h) -- 5220
			), -- 5220
			Color(0.42, 0.4, 0.34, 1) -- 5221
		) -- 5221
		draw:drawSegment( -- 5222
			Vec2( -- 5222
				self:sx(sh.x - sh.w / 2, w), -- 5222
				self:sy(sh.y + sh.h, h) -- 5222
			), -- 5222
			Vec2( -- 5223
				self:sx(sh.x + sh.w / 2, w), -- 5223
				self:sy(sh.y + sh.h, h) -- 5223
			), -- 5223
			self:px(1), -- 5223
			Color(0.74, 0.72, 0.62, 1) -- 5223
		) -- 5223
	end -- 5223
end -- 5204
function Play.prototype.drawZones(self, draw, w, h) -- 5227
	local i = 0 -- 5228
	do -- 5228
		i = 0 -- 5229
		while i < #self.room.zones do -- 5229
			local z = self.room.zones[i + 1] -- 5230
			local fill = DANGER -- 5231
			local line = DANGER_LINE -- 5232
			if z.tint == 2 then -- 5232
				fill = SOFT -- 5234
				line = SOFT_LINE -- 5235
			elseif z.tint == 3 then -- 5235
				fill = BRICK -- 5237
				line = BRICK_LINE -- 5238
			elseif z.tint == 4 then -- 5238
				fill = PASS -- 5240
				line = PASS_LINE -- 5241
			end -- 5241
			self:drawBox( -- 5243
				draw, -- 5243
				w, -- 5243
				h, -- 5243
				z.x0, -- 5243
				z.x1, -- 5243
				z.y, -- 5243
				z.y + z.h, -- 5243
				fill -- 5243
			) -- 5243
			draw:drawSegment( -- 5244
				Vec2( -- 5244
					self:sx(z.x0, w), -- 5244
					self:sy(z.y, h) -- 5244
				), -- 5244
				Vec2( -- 5244
					self:sx(z.x0, w), -- 5244
					self:sy(z.y + z.h, h) -- 5244
				), -- 5244
				self:px(1), -- 5244
				line -- 5244
			) -- 5244
			draw:drawSegment( -- 5245
				Vec2( -- 5245
					self:sx(z.x1, w), -- 5245
					self:sy(z.y, h) -- 5245
				), -- 5245
				Vec2( -- 5245
					self:sx(z.x1, w), -- 5245
					self:sy(z.y + z.h, h) -- 5245
				), -- 5245
				self:px(1), -- 5245
				line -- 5245
			) -- 5245
			i = i + 1 -- 5229
		end -- 5229
	end -- 5229
end -- 5227
function Play.prototype.drawArch(self, draw, w, h) -- 5249
	local a = self.room.arch -- 5250
	if a.h <= 0 then -- 5250
		return -- 5252
	end -- 5252
	self:drawBox( -- 5254
		draw, -- 5254
		w, -- 5254
		h, -- 5254
		a.x0, -- 5254
		a.x1, -- 5254
		a.y, -- 5254
		a.y + a.h, -- 5254
		HOLE_FILL -- 5254
	) -- 5254
	draw:drawSegment( -- 5255
		Vec2( -- 5255
			self:sx(a.x0, w), -- 5255
			self:sy(a.y + a.h, h) -- 5255
		), -- 5255
		Vec2( -- 5255
			self:sx(a.x1, w), -- 5255
			self:sy(a.y + a.h, h) -- 5255
		), -- 5255
		self:px(1), -- 5255
		SOLID_EDGE -- 5255
	) -- 5255
	draw:drawSegment( -- 5256
		Vec2( -- 5256
			self:sx(a.x0, w), -- 5256
			self:sy(a.y, h) -- 5256
		), -- 5256
		Vec2( -- 5256
			self:sx(a.x0, w), -- 5256
			self:sy(a.y + a.h, h) -- 5256
		), -- 5256
		self:px(1), -- 5256
		SOLID_EDGE -- 5256
	) -- 5256
	draw:drawSegment( -- 5257
		Vec2( -- 5257
			self:sx(a.x1, w), -- 5257
			self:sy(a.y, h) -- 5257
		), -- 5257
		Vec2( -- 5257
			self:sx(a.x1, w), -- 5257
			self:sy(a.y + a.h, h) -- 5257
		), -- 5257
		self:px(1), -- 5257
		SOLID_EDGE -- 5257
	) -- 5257
end -- 5249
function Play.prototype.drawCart(self, draw, w, h) -- 5260
	local c = self.room.cart -- 5261
	if c.bodyW <= 0 then -- 5261
		return -- 5263
	end -- 5263
	drawCartShape( -- 5265
		draw, -- 5265
		self, -- 5265
		w, -- 5265
		h, -- 5265
		c, -- 5265
		self.cartAxle -- 5265
	) -- 5265
	draw:drawRect( -- 5266
		Rect( -- 5266
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 5266
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 5266
			self:px(2), -- 5266
			self:px(40) -- 5266
		), -- 5266
		STAND -- 5266
	) -- 5266
end -- 5260
function Play.prototype.drawActors(self, draw, w, h) -- 5269
	local p = self.player -- 5270
	local isChild = self.childMode -- 5271
	local footY = p.y + p.depth -- 5272
	if p.covered then -- 5272
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 5275
		draw:drawSegment( -- 5276
			Vec2( -- 5276
				self:sx(edge, w), -- 5276
				self:sy(footY + 8, h) -- 5276
			), -- 5276
			Vec2( -- 5276
				self:sx(edge, w), -- 5276
				self:sy(footY + p.h * 0.62, h) -- 5276
			), -- 5276
			self:px(2), -- 5276
			STAND -- 5276
		) -- 5276
		draw:drawSegment( -- 5278
			Vec2( -- 5278
				self:sx(p.x - 8, w), -- 5278
				self:sy(footY + p.h + 3, h) -- 5278
			), -- 5278
			Vec2( -- 5278
				self:sx(p.x + 8, w), -- 5278
				self:sy(footY + p.h + 3, h) -- 5278
			), -- 5278
			self:px(2), -- 5278
			STAND -- 5278
		) -- 5278
	elseif self.coverNear and not isChild then -- 5278
		draw:drawRect( -- 5281
			Rect( -- 5281
				self:sx(p.x - 3, w), -- 5281
				self:sy(footY + 1, h), -- 5281
				self:px(3), -- 5281
				self:px(3) -- 5281
			), -- 5281
			STAND -- 5281
		) -- 5281
	end -- 5281
	drawFigure( -- 5283
		draw, -- 5283
		self, -- 5283
		w, -- 5283
		h, -- 5283
		p, -- 5283
		isChild and CHILD_BODY or SOLDIER_BODY, -- 5283
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 5283
	) -- 5283
	local q = self.partner -- 5284
	if q.alive then -- 5284
		local childPartner = q.w == CHILD_W -- 5286
		drawFigure( -- 5287
			draw, -- 5287
			self, -- 5287
			w, -- 5287
			h, -- 5287
			q, -- 5287
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 5287
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 5287
		) -- 5287
	end -- 5287
	local i = 0 -- 5289
	do -- 5289
		i = 0 -- 5290
		while i < #self.enemies do -- 5290
			local e = self.enemies[i + 1] -- 5291
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 5292
			local enemyY = e.y + (e.depth or 0) -- 5293
			self:drawBox( -- 5294
				draw, -- 5294
				w, -- 5294
				h, -- 5294
				e.x - e.w / 2, -- 5294
				e.x + e.w / 2, -- 5294
				enemyY, -- 5294
				enemyY + e.h, -- 5294
				col -- 5294
			) -- 5294
			if e.alive then -- 5294
				local ef = p.x >= e.x and 1 or -1 -- 5296
				if e.kind == "shield" then -- 5296
					local sh = (e.shieldHp or 0) > 0 -- 5298
					draw:drawRect( -- 5299
						Rect( -- 5299
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 5299
							self:sy(enemyY, h), -- 5299
							self:px(6), -- 5299
							self:px(64) -- 5299
						), -- 5299
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 5300
					) -- 5300
				elseif e.kind == "breaker" then -- 5300
					draw:drawSegment( -- 5302
						Vec2( -- 5302
							self:sx(e.x + ef * 12, w), -- 5302
							self:sy(enemyY + 8, h) -- 5302
						), -- 5302
						Vec2( -- 5303
							self:sx(e.x + ef * 22, w), -- 5303
							self:sy(enemyY + 46, h) -- 5303
						), -- 5303
						self:px(3), -- 5303
						Color(0.5, 0.36, 0.22, 1) -- 5303
					) -- 5303
				end -- 5303
			end -- 5303
			if e.alive and e.warnT > 0 then -- 5303
				local gunX = self:sx(e.x, w) -- 5308
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 5309
				local aimX = self:sx(p.x, w) -- 5310
				local aimY = self:sy(footY + p.h * 0.55, h) -- 5311
				local seg = 8 -- 5312
				local s = 0 -- 5313
				do -- 5313
					s = 0 -- 5314
					while s < seg do -- 5314
						local t0 = s / seg -- 5315
						local t1 = (s + 1) / seg -- 5316
						draw:drawSegment( -- 5317
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 5318
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 5319
							self:px(1), -- 5320
							DANGER -- 5320
						) -- 5320
						s = s + 2 -- 5314
					end -- 5314
				end -- 5314
			end -- 5314
			i = i + 1 -- 5290
		end -- 5290
	end -- 5290
	local k = 0 -- 5325
	do -- 5325
		k = 0 -- 5326
		while k < #self.room.marks do -- 5326
			do -- 5326
				local m = self.room.marks[k + 1] -- 5327
				if m.kind ~= 0 then -- 5327
					goto __continue971 -- 5329
				end -- 5329
				local on = self.checkpoint == m.x -- 5331
				local x = self:sx(m.x, w) -- 5332
				local y = self:sy(m.y, h) -- 5333
				draw:drawSegment( -- 5334
					Vec2(x, y), -- 5334
					Vec2( -- 5334
						x, -- 5334
						y + self:px(35) -- 5334
					), -- 5334
					self:px(1), -- 5334
					on and CHECK or INK_DIM -- 5334
				) -- 5334
				draw:drawDot( -- 5335
					Vec2( -- 5335
						x, -- 5335
						y + self:px(35) -- 5335
					), -- 5335
					self:px(2), -- 5335
					on and CHECK or INK_DIM -- 5335
				) -- 5335
			end -- 5335
			::__continue971:: -- 5335
			k = k + 1 -- 5326
		end -- 5326
	end -- 5326
	local j = 0 -- 5339
	do -- 5339
		j = 0 -- 5340
		while j < #self.room.marks do -- 5340
			do -- 5340
				local m = self.room.marks[j + 1] -- 5341
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 5341
					goto __continue974 -- 5343
				end -- 5343
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 5343
					goto __continue974 -- 5347
				end -- 5347
				local col = STAND -- 5349
				if m.kind == 4 then -- 5349
					col = PASS_LINE -- 5351
				elseif m.kind == 5 then -- 5351
					col = BRICK_LINE -- 5353
				end -- 5353
				local mx = self:sx(m.x, w) -- 5355
				local my = self:sy(m.y, h) -- 5356
				draw:drawSegment( -- 5357
					Vec2(mx, my), -- 5357
					Vec2( -- 5357
						mx, -- 5357
						my + self:px(24) -- 5357
					), -- 5357
					self:px(1), -- 5357
					col -- 5357
				) -- 5357
			end -- 5357
			::__continue974:: -- 5357
			j = j + 1 -- 5340
		end -- 5340
	end -- 5340
	local t = 0 -- 5360
	do -- 5360
		t = 0 -- 5361
		while t < #self.room.marks do -- 5361
			do -- 5361
				local m = self.room.marks[t + 1] -- 5362
				if m.kind ~= 6 then -- 5362
					goto __continue980 -- 5364
				end -- 5364
				local mx = self:sx(m.x, w) -- 5366
				local my = self:sy(m.y, h) -- 5367
				draw:drawSegment( -- 5368
					Vec2(mx, my), -- 5368
					Vec2( -- 5368
						mx, -- 5368
						my + self:px(30) -- 5368
					), -- 5368
					self:px(1), -- 5368
					INK_DIM -- 5368
				) -- 5368
				self:drawBox( -- 5369
					draw, -- 5369
					w, -- 5369
					h, -- 5369
					m.x - 5, -- 5369
					m.x + 5, -- 5369
					m.y + 30, -- 5369
					m.y + 40, -- 5369
					CHECK -- 5369
				) -- 5369
			end -- 5369
			::__continue980:: -- 5369
			t = t + 1 -- 5361
		end -- 5361
	end -- 5361
	if self.room.key == "village" then -- 5361
		self:drawVillage(draw, w, h) -- 5372
	end -- 5372
	if self.room.key == "forest" then -- 5372
		self:drawDog(draw, w, h) -- 5375
	end -- 5375
end -- 5269
function Play.prototype.drawDog(self, draw, w, h) -- 5380
	local x = self.dogX -- 5381
	self:drawBox( -- 5382
		draw, -- 5382
		w, -- 5382
		h, -- 5382
		x - 14, -- 5382
		x + 14, -- 5382
		0, -- 5382
		20, -- 5382
		SCAV_BODY -- 5382
	) -- 5382
	self:drawBox( -- 5383
		draw, -- 5383
		w, -- 5383
		h, -- 5383
		x - 10, -- 5383
		x - 2, -- 5383
		20, -- 5383
		30, -- 5383
		SCAV_BODY -- 5383
	) -- 5383
	self:drawBox( -- 5384
		draw, -- 5384
		w, -- 5384
		h, -- 5384
		x + 2, -- 5384
		x + 10, -- 5384
		20, -- 5384
		30, -- 5384
		SCAV_HEAD -- 5384
	) -- 5384
	if self.dogState == "ear" or self.dogState == "chase" then -- 5384
		draw:drawSegment( -- 5386
			Vec2( -- 5386
				self:sx(x, w), -- 5386
				self:sy(30, h) -- 5386
			), -- 5386
			Vec2( -- 5387
				self:sx(x, w), -- 5387
				self:sy(40, h) -- 5387
			), -- 5387
			self:px(1), -- 5387
			DANGER -- 5387
		) -- 5387
	end -- 5387
end -- 5380
function Play.prototype.drawVillage(self, draw, w, h) -- 5392
	local bottle = self.room.bottle -- 5393
	if bottle ~= nil then -- 5393
		self:drawBox( -- 5395
			draw, -- 5395
			w, -- 5395
			h, -- 5395
			bottle.x - 14, -- 5395
			bottle.x + 14, -- 5395
			0, -- 5395
			64, -- 5395
			SOLID_FILL -- 5395
		) -- 5395
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 5395
			self:drawBottle( -- 5397
				draw, -- 5397
				w, -- 5397
				h, -- 5397
				bottle.x, -- 5397
				64 -- 5397
			) -- 5397
		end -- 5397
	end -- 5397
	self:drawBox( -- 5401
		draw, -- 5401
		w, -- 5401
		h, -- 5401
		300, -- 5401
		420, -- 5401
		44, -- 5401
		50, -- 5401
		FLOOR_DECK -- 5401
	) -- 5401
	self:drawBox( -- 5402
		draw, -- 5402
		w, -- 5402
		h, -- 5402
		300, -- 5402
		306, -- 5402
		0, -- 5402
		44, -- 5402
		FLOOR_DECK -- 5402
	) -- 5402
	self:drawBox( -- 5403
		draw, -- 5403
		w, -- 5403
		h, -- 5403
		414, -- 5403
		420, -- 5403
		0, -- 5403
		44, -- 5403
		FLOOR_DECK -- 5403
	) -- 5403
	local s = self.room.scavenger -- 5405
	if s ~= nil then -- 5405
		local sx0 = self.scavX -- 5407
		self:drawBox( -- 5408
			draw, -- 5408
			w, -- 5408
			h, -- 5408
			sx0 - 12, -- 5408
			sx0 + 12, -- 5408
			0, -- 5408
			s.h - 14, -- 5408
			SCAV_BODY -- 5408
		) -- 5408
		self:drawBox( -- 5409
			draw, -- 5409
			w, -- 5409
			h, -- 5409
			sx0 - 7, -- 5409
			sx0 + 7, -- 5409
			s.h - 14, -- 5409
			s.h, -- 5409
			SCAV_HEAD -- 5409
		) -- 5409
		if self.scavState == "turn" then -- 5409
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 5411
			draw:drawSegment( -- 5412
				Vec2( -- 5412
					self:sx(sx0, w), -- 5412
					self:sy(s.h - 6, h) -- 5412
				), -- 5412
				Vec2( -- 5412
					self:sx(fx, w), -- 5412
					self:sy(s.h - 6, h) -- 5412
				), -- 5412
				self:px(1), -- 5412
				INK -- 5412
			) -- 5412
		end -- 5412
	end -- 5412
	if self.hasBottle then -- 5412
		local p = self.player -- 5417
		self:drawBottle( -- 5418
			draw, -- 5418
			w, -- 5418
			h, -- 5418
			p.x + p.facing * 10, -- 5418
			p.y + p.h * 0.62 -- 5418
		) -- 5418
	end -- 5418
	if self.bottleFly ~= nil then -- 5418
		self:drawBottle( -- 5421
			draw, -- 5421
			w, -- 5421
			h, -- 5421
			self.bottleFly.x, -- 5421
			self.bottleFly.y -- 5421
		) -- 5421
	end -- 5421
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 5421
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 5424
		draw:drawCircle( -- 5425
			Vec2( -- 5425
				self:sx(self.bottleLandX, w), -- 5425
				self:sy(0, h) -- 5425
			), -- 5425
			self:px(r / ____exports.UNITS_PER_PX), -- 5425
			BRICK_LINE -- 5425
		) -- 5425
	end -- 5425
end -- 5392
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 5429
	self:drawBox( -- 5430
		draw, -- 5430
		w, -- 5430
		h, -- 5430
		x - 3, -- 5430
		x + 3, -- 5430
		y - 10, -- 5430
		y, -- 5430
		BOTTLE -- 5430
	) -- 5430
end -- 5429
function Play.prototype.drawTrace(self, draw, w, h) -- 5433
	local t = self.trace -- 5434
	if t == nil or self.traceT <= 0 then -- 5434
		return -- 5436
	end -- 5436
	draw:drawSegment( -- 5438
		Vec2( -- 5439
			self:sx(t.x0, w), -- 5439
			self:sy(t.y0, h) -- 5439
		), -- 5439
		Vec2( -- 5440
			self:sx(t.x1, w), -- 5440
			self:sy(t.y1, h) -- 5440
		), -- 5440
		self:px(1), -- 5441
		t.hit and AIM_HIT or INK_DIM -- 5441
	) -- 5441
end -- 5433
function Play.prototype.drawAim(self, draw, w, h) -- 5444
	local v = self.view -- 5446
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 5447
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 5448
	local dot = self:px(1) -- 5449
	local arm = self:px(3) -- 5450
	local gap = self:px(1) -- 5451
	draw:drawSegment( -- 5452
		Vec2(gx - arm - gap, gy), -- 5452
		Vec2(gx - gap, gy), -- 5452
		dot / 2, -- 5452
		AIM -- 5452
	) -- 5452
	draw:drawSegment( -- 5453
		Vec2(gx + gap, gy), -- 5453
		Vec2(gx + arm + gap, gy), -- 5453
		dot / 2, -- 5453
		AIM -- 5453
	) -- 5453
	draw:drawSegment( -- 5454
		Vec2(gx, gy - arm - gap), -- 5454
		Vec2(gx, gy - gap), -- 5454
		dot / 2, -- 5454
		AIM -- 5454
	) -- 5454
	draw:drawSegment( -- 5455
		Vec2(gx, gy + gap), -- 5455
		Vec2(gx, gy + arm + gap), -- 5455
		dot / 2, -- 5455
		AIM -- 5455
	) -- 5455
	if self.room.key == "village" and self.hasBottle then -- 5455
		local p = self.player -- 5459
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 5461
		local dir = ____end.x >= p.x and 1 or -1 -- 5462
		local x0 = p.x + dir * 10 -- 5463
		local y0 = p.y + p.h * 0.7 -- 5464
		local T = BOTTLE_FLY_TIME -- 5465
		local vx = (____end.x - x0) / T -- 5466
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 5467
		local pxr = x0 -- 5468
		local pyr = y0 -- 5469
		local t = 1 -- 5470
		do -- 5470
			t = 1 -- 5471
			while t <= 12 do -- 5471
				local tt = t / 12 * T -- 5472
				local nx = x0 + vx * tt -- 5473
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 5474
				draw:drawSegment( -- 5475
					Vec2( -- 5475
						self:sx(pxr, w), -- 5475
						self:sy(pyr, h) -- 5475
					), -- 5475
					Vec2( -- 5475
						self:sx(nx, w), -- 5475
						self:sy(ny, h) -- 5475
					), -- 5475
					self:px(1) / 2, -- 5475
					BOTTLE -- 5475
				) -- 5475
				pxr = nx -- 5476
				pyr = ny -- 5477
				t = t + 1 -- 5471
			end -- 5471
		end -- 5471
		draw:drawCircle( -- 5479
			Vec2( -- 5479
				self:sx(____end.x, w), -- 5479
				self:sy(____end.y + 2, h) -- 5479
			), -- 5479
			self:px(2), -- 5479
			BOTTLE -- 5479
		) -- 5479
	end -- 5479
end -- 5444
return ____exports -- 5444