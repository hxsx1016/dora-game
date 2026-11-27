-- [ts]: play.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 6329
local ____Dora = require("Dora") -- 12
local Color = ____Dora.Color -- 12
local Rect = ____Dora.Rect -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____rooms = require("Script.watch.rooms") -- 13
local ESCORT_VARIANTS = ____rooms.ESCORT_VARIANTS -- 14
local withOrigin = ____rooms.withOrigin -- 15
local ____run = require("Script.watch.run") -- 17
local ALL_TALENTS = ____run.ALL_TALENTS -- 18
local createRun = ____run.createRun -- 18
local createStoryTalents = ____run.createStoryTalents -- 18
local draftTalentOffers = ____run.draftTalentOffers -- 18
local mmss = ____run.mmss -- 19
local pickEscortVariant = ____run.pickEscortVariant -- 19
local talentNames = ____run.talentNames -- 19
local ____clock = require("Script.watch.clock") -- 22
local STEP = ____clock.STEP -- 22
local ____escort = require("Script.watch.escort") -- 23
local CALM_REACH = ____escort.CALM_REACH -- 23
local Escort = ____escort.Escort -- 23
local FEAR_MAX = ____escort.FEAR_MAX -- 23
local safeAnchorX = ____escort.safeAnchorX -- 23
local ____depth = require("Script.watch.depth") -- 24
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 24
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 24
local INTERACT_DEPTH_REACH = ____depth.INTERACT_DEPTH_REACH -- 24
local inReachDepth = ____depth.inReachDepth -- 24
local overlapsDepth = ____depth.overlapsDepth -- 24
local ____reload = require("Script.watch.reload") -- 25
local RELOAD_ANSWER_PER_WORLD = ____reload.RELOAD_ANSWER_PER_WORLD -- 26
local RELOAD_ANSWER_TICKS = ____reload.RELOAD_ANSWER_TICKS -- 26
local RELOAD_START = ____reload.RELOAD_START -- 26
local RELOAD_TARGET = ____reload.RELOAD_TARGET -- 26
local reloadAdjacent = ____reload.reloadAdjacent -- 27
local reloadEffectName = ____reload.reloadEffectName -- 27
local reloadEffectOf = ____reload.reloadEffectOf -- 27
local reloadPathValid = ____reload.reloadPathValid -- 27
local ____craft = require("Script.watch.craft") -- 29
local ARTIFACT_WEAPON_ID = ____craft.ARTIFACT_WEAPON_ID -- 30
local CRAFT_RECIPES = ____craft.CRAFT_RECIPES -- 30
local findRecipe = ____craft.findRecipe -- 30
local missingMaterials = ____craft.missingMaterials -- 30
local payMaterials = ____craft.payMaterials -- 30
local weaponEffectOf = ____craft.weaponEffectOf -- 30
local weaponNameOf = ____craft.weaponNameOf -- 30
function makeActor(room, index) -- 6329
	local sp = room.spawns -- 6330
	if index < 0 or index >= #sp then -- 6331
		return { -- 6332
			x = 0, -- 6332
			y = 0, -- 6332
			depth = 0, -- 6332
			depthSpeed = 0, -- 6332
			vx = 0, -- 6332
			vy = 0, -- 6332
			w = CHILD_W, -- 6332
			h = CHILD_H, -- 6332
			onGround = true, -- 6332
			facing = 1, -- 6332
			crouch = false, -- 6332
			rollT = 0, -- 6332
			covered = false, -- 6332
			alive = false -- 6332
		} -- 6332
	end -- 6332
	local s = sp[index + 1] -- 6334
	local child = s.h < SOLDIER_H -- 6335
	local ground = room.depth -- 6336
	local depth = ground == nil and 0 or math.max( -- 6337
		ground.min, -- 6337
		math.min(ground.max, s.depth or 0) -- 6337
	) -- 6337
	return { -- 6338
		x = s.x, -- 6339
		y = s.y, -- 6339
		depth = depth, -- 6339
		depthSpeed = 0, -- 6339
		vx = 0, -- 6339
		vy = 0, -- 6339
		w = child and CHILD_W or SOLDIER_W, -- 6340
		h = child and CHILD_H or SOLDIER_H, -- 6341
		onGround = true, -- 6342
		facing = 1, -- 6342
		crouch = false, -- 6342
		rollT = 0, -- 6342
		covered = false, -- 6342
		alive = true -- 6342
	} -- 6342
end -- 6342
function drawFigure(draw, play, w, h, a, body, head) -- 6346
	if not a.alive then -- 6347
		return -- 6348
	end -- 6348
	local x0 = a.x - a.w / 2 -- 6350
	local x1 = a.x + a.w / 2 -- 6351
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6352
	local y1 = y0 + a.h -- 6353
	play:drawBox( -- 6354
		draw, -- 6354
		w, -- 6354
		h, -- 6354
		x0, -- 6354
		x1, -- 6354
		y0, -- 6354
		y1 - a.h * 0.26, -- 6354
		body -- 6354
	) -- 6354
	play:drawBox( -- 6355
		draw, -- 6355
		w, -- 6355
		h, -- 6355
		x0 + 2, -- 6355
		x1 - 2, -- 6355
		y1 - a.h * 0.26, -- 6355
		y1, -- 6355
		head -- 6355
	) -- 6355
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6357
	play:drawBox( -- 6358
		draw, -- 6358
		w, -- 6358
		h, -- 6358
		eyeX, -- 6358
		eyeX + 4, -- 6358
		y1 - a.h * 0.14, -- 6358
		y1 - a.h * 0.08, -- 6358
		INK -- 6358
	) -- 6358
end -- 6358
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6362
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6363
end -- 6362
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6370
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6371
end -- 6370
function rayInterval(origin, direction, min, max) -- 6378
	if direction == 0 then -- 6379
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6380
	end -- 6380
	local a = (min - origin) / direction -- 6382
	local b = (max - origin) / direction -- 6383
	return { -- 6384
		min = math.min(a, b), -- 6384
		max = math.max(a, b) -- 6384
	} -- 6384
end -- 6384
function hitBox(ray, box) -- 6388
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6389
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6390
	local enter = math.max(0, x.min, y.min) -- 6391
	local leave = math.min(99999, x.max, y.max) -- 6392
	if box.depth ~= nil then -- 6393
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6394
		enter = math.max(enter, depth.min) -- 6395
		leave = math.min(leave, depth.max) -- 6396
	end -- 6396
	return leave >= enter and enter or -1 -- 6398
end -- 6398
function drawCartShape(draw, play, w, h, c, axleX) -- 6401
	local half = c.bodyW / 2 -- 6402
	local x0 = axleX - half -- 6403
	local x1 = axleX + half -- 6404
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6405
	play:drawBox( -- 6406
		draw, -- 6406
		w, -- 6406
		h, -- 6406
		x0, -- 6406
		x1, -- 6406
		axleY, -- 6406
		axleY + c.bodyH, -- 6406
		CART_FILL -- 6406
	) -- 6406
	draw:drawCircle( -- 6407
		Vec2( -- 6407
			play:sx(x0 + c.bodyW * 0.28, w), -- 6407
			play:sy(axleY, h) -- 6407
		), -- 6407
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6407
		Color(52, 50, 48, 255) -- 6407
	) -- 6407
	draw:drawCircle( -- 6408
		Vec2( -- 6408
			play:sx(x1 - c.bodyW * 0.28, w), -- 6408
			play:sy(axleY, h) -- 6408
		), -- 6408
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6408
		Color(52, 50, 48, 255) -- 6408
	) -- 6408
	local cx = c.clothSide < 0 and x0 or x1 -- 6409
	play:drawBox( -- 6410
		draw, -- 6410
		w, -- 6410
		h, -- 6410
		cx - 10, -- 6410
		cx + 10, -- 6410
		axleY + c.bodyH, -- 6410
		axleY + c.bodyH + 18, -- 6410
		CLOTH -- 6410
	) -- 6410
end -- 6410
____exports.STEP = STEP -- 35
____exports.GRAVITY = 1000 -- 36
____exports.GATE_COUNT_END = 1440 -- 37
--- 牵手：按住 E 的有效拍数，60 拍/秒 → 0.6 秒。
____exports.GATE_HAND_TICKS = 36 -- 39
--- 80% 门槛：100*hpAtGate >= 80*maxHpAtGate 走男主线。
____exports.GATE_ROUTE_PERCENT = 80 -- 41
____exports.TOWER_CONFIRM_TICKS = 480 -- 42
local TOWER_REGISTER_TICKS = 180 -- 43
--- 值夜室桌前长按 E 的生效拍数（0.6 秒，与城门牵手同节奏）。
local TOWER_HANDOVER_TICKS = 36 -- 45
--- 跨过门槛的段内 x（门廊 400–490、值夜室 490–700）。
local TOWER_THRESHOLD_X = 500 -- 47
--- P01 黑场听父亲唤「小满」到睁眼落稳：4 秒 = 240 拍。
____exports.PROLOGUE_WAKE_TICKS = 240 -- 51
--- P02 门槛内墙上人影与瓷碗滚到脚边：2 秒 = 120 拍。
____exports.PROLOGUE_SHADOW_TICKS = 120 -- 53
--- 限时逃柜：7.5 秒 = 450 拍；超时退回门口重来，不扣血。
____exports.PROLOGUE_ESCAPE_TICKS = 450 -- 55
--- 入柜后红晕收尽、柜外脚步渐远：0.85 秒 = 51 拍。
____exports.PROLOGUE_HIDE_TICKS = 51 -- 57
--- 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。
____exports.PROLOGUE_CABINET_X = 132 -- 59
function ____exports.gateCountAtTick(tick) -- 61
	if tick >= ____exports.GATE_COUNT_END then -- 62
		return 20 -- 62
	end -- 62
	if tick >= 1260 then -- 63
		return 19 -- 63
	end -- 63
	if tick >= 1080 then -- 64
		return 18 -- 64
	end -- 64
	if tick >= 480 then -- 65
		return 11 + math.floor((tick - 480) * 7 / 600) -- 65
	end -- 65
	return 1 + math.floor(math.max(0, tick) / 48) -- 66
end -- 61
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 69
CHILD_W = 28 -- 144
CHILD_H = 56 -- 145
local CHILD_CROUCH_H = 34 -- 146
local CHILD_SPEED = 160 -- 147
local CHILD_SLOW = 80 -- 148
local CHILD_JUMP = 320 -- 149
SOLDIER_W = 30 -- 152
SOLDIER_H = 88 -- 153
local SOLDIER_SPEED = 264 -- 154
local ROLL_TIME = 0.35 -- 155
local ROLL_SPEED = 280 -- 156
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 158
local LEDGE_RISE = 60 -- 159
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 162
____exports.LOGIC_H = 180 -- 163
____exports.UNITS_PER_PX = 2 -- 164
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 166
local CAM_FOLLOW = 9 -- 167
local CAM_LOOK_UP = 46 -- 168
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 171
--- 握把触发半径。
____exports.CART_REACH = 70 -- 173
--- 车身半宽与下缘净高（城外下层阻挡）。
local CART_HALF = 24 -- 175
local CART_CLEAR = 44 -- 176
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 178
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 180
local CONSUMABLE_CAP = 1 -- 181
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 183
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 185
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 187
local FIRE_COOLDOWN = 150 -- 188
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 190
local ENEMY_RANGE = 760 -- 191
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 193
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 195
local DEPTH_SPEED_RATIO = 0.55 -- 196
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 197
INK = Color(232, 232, 228, 255) -- 199
local INK_DIM = Color(150, 152, 150, 255) -- 200
local BG_VOID = Color(8, 9, 10, 255) -- 201
local BG_FAR = Color(24, 26, 28, 255) -- 202
local BG_MID = Color(31, 34, 37, 255) -- 203
local GROUND = Color(112, 114, 112, 255) -- 204
local FLOOR_DECK = Color(66, 70, 72, 255) -- 205
local SOLID_FILL = Color(84, 86, 84, 255) -- 206
local SOLID_EDGE = Color(126, 130, 126, 255) -- 207
CART_FILL = Color(122, 78, 56, 255) -- 208
CLOTH = Color(178, 52, 46, 255) -- 209
local DANGER = Color(150, 54, 48, 46) -- 210
local DANGER_LINE = Color(178, 78, 64, 200) -- 211
local HOLE_FILL = Color(10, 11, 12, 255) -- 212
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 213
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 214
local CHILD_BODY = Color(214, 168, 96, 255) -- 215
local CHILD_HEAD = Color(232, 214, 186, 255) -- 216
local ENEMY_BODY = Color(176, 92, 84, 255) -- 217
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 218
local CHECK = Color(96, 186, 122, 255) -- 219
local STAND = Color(226, 186, 84, 255) -- 220
local AIM = Color(236, 236, 232, 230) -- 221
local AIM_HIT = Color(236, 96, 84, 255) -- 222
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 224
local SOFT_LINE = Color(140, 112, 80, 190) -- 225
local BRICK = Color(126, 118, 110, 70) -- 226
local BRICK_LINE = Color(160, 152, 142, 200) -- 227
local PASS = Color(96, 186, 122, 40) -- 228
local PASS_LINE = Color(96, 186, 122, 200) -- 229
local BOTTLE = Color(120, 186, 160, 255) -- 230
local SCAV_BODY = Color(128, 118, 96, 255) -- 231
local SCAV_HEAD = Color(196, 182, 158, 255) -- 232
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 319
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 320
	if zoom < 1 then -- 321
		zoom = 1 -- 322
	end -- 322
	return { -- 324
		zoom = zoom, -- 325
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 326
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 327
	} -- 327
end -- 319
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 350
	if key == "prologue" then -- 351
		return "prologue-wait" -- 354
	end -- 354
	if key == "street" then -- 356
		return "street-run" -- 357
	end -- 357
	if key == "gate" then -- 359
		return "gate-idle" -- 360
	end -- 360
	if key == "gatepath" then -- 362
		return "gatepath-start" -- 363
	end -- 363
	if key == "forest" then -- 365
		return "forest-run" -- 366
	end -- 366
	if key == "tower" then -- 368
		return "tower-wait" -- 369
	end -- 369
	if key == "museum" then -- 371
		return "museum-cabinet" -- 372
	end -- 372
	return "run" -- 374
end -- 350
____exports.Play = __TS__Class() -- 377
local Play = ____exports.Play -- 377
Play.name = "Play" -- 377
function Play.prototype.____constructor(self, room, resume, run) -- 687
	self.enemies = {} -- 382
	self.boxes = {} -- 383
	self.floors = {} -- 384
	self.checkpoint = -1 -- 386
	self.flash = "" -- 388
	self.flashT = 0 -- 389
	self.traceT = 0 -- 392
	self.focusCart = false -- 394
	self.knocks = 0 -- 396
	self.knockT = 0 -- 397
	self.cartAxle = 0 -- 401
	self.cartDocked = false -- 403
	self.gripping = false -- 405
	self.gateOpen = false -- 407
	self.calmConsumed = false -- 409
	self.craftT = 0 -- 411
	self.nextDangerId = 1 -- 413
	self.wantRoom = "" -- 415
	self.carryCartAxle = -1 -- 417
	self.carryCartDocked = false -- 418
	self.checkpointCartAxle = -1 -- 420
	self.hasBottle = false -- 424
	self.bottleLandX = -1 -- 428
	self.bottleTargetX = -1 -- 429
	self.bottleTargetY = 0 -- 430
	self.bottleLandT = 0 -- 431
	self.aimHold = 0 -- 433
	self.redCartPulled = false -- 435
	self.redCartMemoryT = 0 -- 437
	self.footHintT = 0 -- 439
	self.ditchHinted = false -- 441
	self.forestPath = "" -- 443
	self.waterSeen = false -- 445
	self.scavStallBonus = 0 -- 447
	self.intentGateReunionHold = false -- 449
	self.pendingMuseumIntentTarget = "" -- 451
	self.scavX = 0 -- 453
	self.scavDir = 1 -- 454
	self.scavState = "patrol" -- 455
	self.scavT = 0 -- 456
	self.scavTargetX = 0 -- 457
	self.passed = false -- 459
	self.childMode = false -- 463
	self.phase = "" -- 465
	self.phaseTick = 0 -- 467
	self.gateTick = 0 -- 469
	self.countTick = 0 -- 471
	self.countArmed = false -- 473
	self.countPrevMove = 0 -- 475
	self.caughtT = 0 -- 477
	self.hp = 3 -- 479
	self.maxHp = 3 -- 480
	self.invulnT = 0 -- 486
	self.partnerStuck = 0 -- 488
	self.partnerLaneIdx = 0 -- 490
	self.partnerLaneHold = 0 -- 491
	self.coveredFlash = 0 -- 493
	self.coverHug = false -- 495
	self.coverNear = false -- 497
	self.coverEntity = "" -- 499
	self.coverBlocking = false -- 501
	self.gateNeedConfirm = false -- 503
	self.gateRestartArmed = true -- 505
	self.bottleAimX = -1 -- 507
	self.bottleAimY = 0 -- 508
	self.bottleSurfaceY = -1 -- 510
	self.bottleLandY = 0 -- 512
	self.events = {} -- 514
	self.eventSeq = 0 -- 516
	self.dogX = 0 -- 518
	self.dogDir = 1 -- 519
	self.dogState = "patrol" -- 520
	self.dogT = 0 -- 521
	self.dogTargetX = 0 -- 522
	self.scavSee = 0 -- 524
	self.scavChase = false -- 525
	self.gateSpawned = 0 -- 527
	self.gateFailCount = 0 -- 529
	self.isCampaign = false -- 533
	self.archiveDirty = false -- 541
	self.sessionDirty = false -- 543
	self.restartStory = false -- 545
	self.wellOpen = false -- 547
	self.wellX = 430 -- 549
	self.wellTaken = false -- 551
	self.museumReturn = false -- 553
	self.endingLines = {"", ""} -- 555
	self.towerDoorOpen = false -- 557
	self.towerHanded = false -- 558
	self.deskHold = 0 -- 559
	self.towerEndMustRelease = false -- 561
	self.equippedWeapon = "standard_gun" -- 574
	self.craftBench = { -- 576
		active = false, -- 577
		firstCraftDone = false, -- 578
		justCraftedTimer = 0, -- 579
		inventory = {}, -- 580
		recipes = {}, -- 581
		equippedWeapon = "standard_gun" -- 582
	} -- 582
	self.handledCraftRequests = {} -- 585
	self.benchReach = 48 -- 587
	self.pickups = {} -- 591
	self.reloadT = 0 -- 593
	self.objectiveDone = false -- 597
	self.hint = "" -- 599
	self.roomStartTick = 0 -- 601
	self.cartHitT = 0 -- 603
	self.cartExposed = false -- 604
	self.storyRoute = "" -- 608
	self.storySettled = false -- 610
	self.hpAtGate = -1 -- 612
	self.maxHpAtGate = -1 -- 613
	self.handTicks = 0 -- 615
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 617
	self.handArmed = false -- 619
	self.handDone = false -- 621
	self.lineSaid = false -- 622
	self.tied = false -- 624
	self.pathDone = false -- 626
	self.carryOn = false -- 628
	self.escortDone = false -- 630
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 634
	self.escapeRemaining = 0 -- 636
	self.escapeRetryCount = 0 -- 638
	self.introTick = 0 -- 640
	self.reloadOpen = false -- 644
	self.reloadAnswerTicks = 0 -- 646
	self.reloadWorldTicks = 0 -- 648
	self.reloadPath = {RELOAD_START} -- 650
	self.reloadPendingEffect = "" -- 652
	self.reloadTryCount = 0 -- 654
	self.talentModalActive = false -- 657
	self.useEscortDeathSummary = false -- 658
	self.escortFailed = false -- 659
	self.escortFailedTicks = 0 -- 660
	self.escortSummary = nil -- 661
	self.fieldWedgeSeq = 0 -- 669
	self.paused = false -- 671
	self.ticks = 0 -- 673
	self.view = {zoom = 1, ox = 0, oy = 0} -- 675
	self.ox = 0 -- 677
	self.aimX = 0 -- 679
	self.aimY = 0 -- 680
	self.viewW = 0 -- 682
	self.viewH = 0 -- 683
	self.ox = room.originX -- 689
	self.room = withOrigin(room) -- 690
	local wr = self.room -- 691
	self.run = run or createRun() -- 692
	self.inventory = self.run.inventory -- 693
	self.archive = self.run.archive -- 694
	self.equippedWeapon = self.run.story.craftedWeapon == "" and "standard_gun" or self.run.story.craftedWeapon -- 695
	self.isCampaign = wr.campaign ~= nil -- 696
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 697
	self:buildWorld() -- 698
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 701
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 703
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 704
	local soloRoom = wr.key == "museum" -- 706
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 707
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 708
	self.player = makeActor(wr, playerIdx) -- 709
	self.partner = makeActor(wr, partnerIdx) -- 710
	self.phase = phaseOf(wr.key) -- 711
	if soloRoom then -- 712
		local mp = self.archive.museumPhase -- 714
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 715
	end -- 715
	if wr.story ~= nil then -- 720
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 721
	end -- 721
	self.cam.x = self.player.x -- 723
	self.cam.y = self.player.y + CAM_LOOK_UP -- 724
	self.cartAxle = wr.cart.startX -- 725
	self.escort = __TS__New( -- 726
		Escort, -- 726
		safeAnchorX(wr.marks) -- 726
	) -- 726
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 727
	if self.isCampaign then -- 728
		self:setupCampaign() -- 729
	else -- 729
		self:buildEnemies() -- 731
	end -- 731
	if resume ~= nil and resume.checkpoint > 0 then -- 734
		self.checkpoint = resume.checkpoint -- 735
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 736
			self.cartAxle = self.room.cart.endX -- 737
			self.cartDocked = true -- 738
			self.player.x = self.ox + 380 -- 741
			self.player.y = 0 -- 742
			self.player.vy = 0 -- 743
			self.player.onGround = true -- 744
			self.cam.x = self.player.x -- 745
			self.cam.y = self.player.y + CAM_LOOK_UP -- 746
		end -- 746
	end -- 746
	self:restoreStory() -- 749
end -- 687
function Play.prototype.towerEndReady(self) -- 564
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 565
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 566
end -- 564
function Play.prototype.recipeViews(self) -- 762
	local out = {} -- 763
	local i = 0 -- 764
	do -- 764
		i = 0 -- 765
		while i < #CRAFT_RECIPES do -- 765
			local r = CRAFT_RECIPES[i + 1] -- 766
			local cost = {} -- 767
			if r.cost.wood ~= nil then -- 768
				cost.wood = r.cost.wood -- 769
			end -- 769
			if r.cost.bell ~= nil then -- 771
				cost.bell = r.cost.bell -- 772
			end -- 772
			out[#out + 1] = { -- 774
				id = r.id, -- 775
				name = r.name, -- 776
				desc = r.desc, -- 777
				enhancedEffect = r.enhancedEffect, -- 778
				cost = cost, -- 779
				crafted = self.run.story.craftedWeapon == r.id -- 780
			} -- 780
			i = i + 1 -- 765
		end -- 765
	end -- 765
	if self.archive.artifactOwned then -- 784
		out[#out + 1] = { -- 785
			id = ARTIFACT_WEAPON_ID, -- 786
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 787
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 788
			enhancedEffect = "light", -- 789
			cost = {}, -- 790
			crafted = true -- 791
		} -- 791
	end -- 791
	return out -- 794
end -- 762
function Play.prototype.syncCraftBench(self) -- 798
	local view = self.craftBench -- 799
	local inv = self.run.inventory -- 800
	view.inventory = { -- 801
		wood = inv.wood, -- 801
		bell = inv.bell, -- 801
		scrap = inv.scrap, -- 801
		wedge = inv.wedge, -- 801
		ammo = inv.ammo -- 801
	} -- 801
	view.recipes = self:recipeViews() -- 802
	view.equippedWeapon = self.equippedWeapon -- 803
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 804
	if view.justCraftedTimer > 0 then -- 805
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 806
	end -- 806
end -- 798
function Play.prototype.openCraftBench(self) -- 811
	if self.room.key ~= "escort3" or self.craftBench.active then -- 812
		return -- 813
	end -- 813
	self.craftBench.active = true -- 815
	self.carryOn = false -- 816
	self.run.story.carry = false -- 817
	self.player.vx = 0 -- 818
	self.player.vy = 0 -- 819
	self.craftBench.justCraftedTimer = 0 -- 820
	self:syncCraftBench() -- 821
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 822
	self:log("开工台") -- 823
	self:emit( -- 824
		"benchOpen", -- 824
		{ -- 824
			recipes = __TS__ArrayMap( -- 825
				self.craftBench.recipes, -- 825
				function(____, r) return r.id end -- 825
			), -- 825
			inventory = self.craftBench.inventory, -- 826
			carry = self.carryOn -- 827
		} -- 827
	) -- 827
end -- 811
function Play.prototype.closeCraftBench(self) -- 832
	if not self.craftBench.active then -- 833
		return -- 834
	end -- 834
	self.craftBench.active = false -- 836
	self.craftBench.justCraftedTimer = 0 -- 837
	self.carryOn = true -- 838
	self.run.story.carry = true -- 839
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 840
	self:log("离站背起") -- 841
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 842
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 843
		self:triggerDeferredEscort3Draft() -- 844
	end -- 844
end -- 832
function Play.prototype.triggerDeferredEscort3Draft(self) -- 849
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 850
		return false -- 851
	end -- 851
	if self.run.story.talents == nil then -- 853
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 854
	end -- 854
	local st = self.run.story.talents -- 856
	if not st.deferred and st.room == "escort3" then -- 857
		return false -- 858
	end -- 858
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 860
	if self.useEscortDeathSummary and #st.offers > 0 then -- 861
		self.talentModalActive = true -- 862
	end -- 862
	self.sessionDirty = true -- 864
	return #st.offers > 0 -- 865
end -- 849
function Play.prototype.openTalentDraft(self) -- 869
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 870
		self.talentModalActive = true -- 871
	end -- 871
end -- 869
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 879
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 880
		return false -- 881
	end -- 881
	local recipe = findRecipe(recipeId) -- 883
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 884
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 885
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 886
		return false -- 887
	end -- 887
	local missing = missingMaterials(self.run.inventory, recipe) -- 889
	if #missing > 0 then -- 890
		self:flashSet( -- 891
			"缺料 · " .. table.concat(missing, " / "), -- 891
			1.6 -- 891
		) -- 891
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 892
		return false -- 893
	end -- 893
	payMaterials(self.run.inventory, recipe) -- 895
	self.handledCraftRequests[requestId] = true -- 896
	self.run.story.craftedWeapon = recipe.id -- 897
	self.run.story.equippedWeapon = recipe.id -- 898
	self.equippedWeapon = recipe.id -- 899
	self.sessionDirty = true -- 900
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 901
	self.craftBench.firstCraftDone = true -- 902
	self:syncCraftBench() -- 903
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 904
	self:log("改制 " .. recipe.id) -- 905
	self:emit("benchCraft", { -- 906
		recipeId = recipe.id, -- 907
		weapon = recipe.id, -- 908
		effect = recipe.enhancedEffect, -- 909
		wood = self.run.inventory.wood, -- 910
		bell = self.run.inventory.bell -- 911
	}) -- 911
	return true -- 913
end -- 879
function Play.prototype.equipWeapon(self, weaponId) -- 917
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 918
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 919
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 920
		return false -- 921
	end -- 921
	self.equippedWeapon = weaponId -- 923
	self.run.story.equippedWeapon = weaponId -- 924
	self.sessionDirty = true -- 925
	self:syncCraftBench() -- 926
	self:flashSet( -- 927
		"已装备 " .. weaponNameOf(weaponId), -- 927
		1 -- 927
	) -- 927
	self:emit("benchEquip", {weapon = weaponId}) -- 928
	return true -- 929
end -- 917
function Play.prototype.toggleArtifactWeapon(self) -- 933
	if not self.archive.artifactOwned or self.childMode then -- 934
		return false -- 935
	end -- 935
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 937
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 938
		return self:equipWeapon(fallback) -- 939
	end -- 939
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 941
end -- 933
function Play.prototype.exportSession(self) -- 945
	self:syncStory() -- 946
	local story = self.run.story -- 947
	local inv = self.run.inventory -- 948
	local taken = {} -- 949
	for k in pairs(self.run.taken) do -- 950
		if self.run.taken[k] == true then -- 951
			taken[#taken + 1] = k -- 952
		end -- 952
	end -- 952
	local segments = {} -- 955
	for k in pairs(story.segments) do -- 956
		if story.segments[k] == true then -- 957
			segments[#segments + 1] = k -- 958
		end -- 958
	end -- 958
	local props = {} -- 961
	for k in pairs(self.run.props) do -- 962
		local st = self.run.props[k] -- 963
		if st ~= nil then -- 964
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 965
		end -- 965
	end -- 965
	local talentRanks = {} -- 974
	if story.talents ~= nil then -- 975
		local ti = 0 -- 976
		do -- 976
			ti = 0 -- 977
			while ti < #ALL_TALENTS do -- 977
				local tid = ALL_TALENTS[ti + 1] -- 978
				local rk = story.talents.ranks[tid] or 0 -- 979
				if rk > 0 then -- 980
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 981
				end -- 981
				ti = ti + 1 -- 977
			end -- 977
		end -- 977
	end -- 977
	local ____self_room_key_1 = self.room.key -- 986
	local ____self_checkpoint_2 = self.checkpoint -- 987
	local ____self_run_seed_3 = self.run.seed -- 988
	local ____story_route_4 = story.route -- 989
	local ____story_hp_5 = story.hp -- 990
	local ____story_maxHp_6 = story.maxHp -- 991
	local ____story_hpAtGate_7 = story.hpAtGate -- 992
	local ____story_maxHpAtGate_8 = story.maxHpAtGate -- 993
	local ____story_settled_9 = story.settled -- 994
	local ____self_phase_10 = self.phase -- 995
	local ____story_countTick_11 = story.countTick -- 996
	local ____story_phaseTick_12 = story.phaseTick -- 997
	local ____story_handTicks_13 = story.handTicks -- 998
	local ____story_handDone_14 = story.handDone -- 999
	local ____story_lineSaid_15 = story.lineSaid -- 1000
	local ____story_tied_16 = story.tied -- 1001
	local ____story_carry_17 = story.carry -- 1002
	local ____story_escortDone_18 = story.escortDone -- 1003
	local ____story_craftedWeapon_19 = story.craftedWeapon -- 1004
	local ____self_equippedWeapon_20 = self.equippedWeapon -- 1005
	local ____inv_wood_21 = inv.wood -- 1006
	local ____inv_bell_22 = inv.bell -- 1007
	local ____inv_scrap_23 = inv.scrap -- 1008
	local ____inv_wedge_24 = inv.wedge -- 1009
	local ____inv_ammo_25 = inv.ammo -- 1010
	local ____inv_shield_26 = inv.shield -- 1011
	local ____inv_pass_27 = inv.pass -- 1012
	local ____inv_quickbelt_28 = inv.quickbelt -- 1013
	local ____taken_29 = taken -- 1014
	local ____segments_30 = segments -- 1015
	local ____self_cartAxle_31 = self.cartAxle -- 1016
	local ____self_cartDocked_32 = self.cartDocked -- 1017
	local ____self_run_route_33 = self.run.route -- 1018
	local ____self_run_joined_34 = self.run.joined -- 1019
	local ____self_run_c1Latch_35 = self.run.c1Latch -- 1020
	local ____self_run_c2Latch_36 = self.run.c2Latch -- 1021
	local ____temp_37 = story.talents ~= nil and story.talents.randomState or 0 -- 1022
	local ____temp_38 = story.talents ~= nil and story.talents.room or "" -- 1023
	local ____temp_39 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1024
	local ____talentRanks_40 = talentRanks -- 1025
	local ____temp_41 = story.talents ~= nil and story.talents.attempt or 1 -- 1026
	local ____temp_42 = story.talents ~= nil and story.talents.variant or 0 -- 1027
	local ____temp_0 -- 1028
	if story.talents ~= nil then -- 1028
		____temp_0 = story.talents.deferred -- 1028
	else -- 1028
		____temp_0 = false -- 1028
	end -- 1028
	return { -- 985
		roomKey = ____self_room_key_1, -- 986
		checkpoint = ____self_checkpoint_2, -- 987
		seed = ____self_run_seed_3, -- 988
		route = ____story_route_4, -- 989
		hp = ____story_hp_5, -- 990
		maxHp = ____story_maxHp_6, -- 991
		hpAtGate = ____story_hpAtGate_7, -- 992
		maxHpAtGate = ____story_maxHpAtGate_8, -- 993
		settled = ____story_settled_9, -- 994
		phase = ____self_phase_10, -- 995
		countTick = ____story_countTick_11, -- 996
		phaseTick = ____story_phaseTick_12, -- 997
		handTicks = ____story_handTicks_13, -- 998
		handDone = ____story_handDone_14, -- 999
		lineSaid = ____story_lineSaid_15, -- 1000
		tied = ____story_tied_16, -- 1001
		carry = ____story_carry_17, -- 1002
		escortDone = ____story_escortDone_18, -- 1003
		craftedWeapon = ____story_craftedWeapon_19, -- 1004
		equippedWeapon = ____self_equippedWeapon_20, -- 1005
		wood = ____inv_wood_21, -- 1006
		bell = ____inv_bell_22, -- 1007
		scrap = ____inv_scrap_23, -- 1008
		wedge = ____inv_wedge_24, -- 1009
		ammo = ____inv_ammo_25, -- 1010
		shield = ____inv_shield_26, -- 1011
		pass = ____inv_pass_27, -- 1012
		quickbelt = ____inv_quickbelt_28, -- 1013
		taken = ____taken_29, -- 1014
		segments = ____segments_30, -- 1015
		cartAxle = ____self_cartAxle_31, -- 1016
		cartDocked = ____self_cartDocked_32, -- 1017
		campaignRoute = ____self_run_route_33, -- 1018
		joined = ____self_run_joined_34, -- 1019
		c1Latch = ____self_run_c1Latch_35, -- 1020
		c2Latch = ____self_run_c2Latch_36, -- 1021
		talentSeed = ____temp_37, -- 1022
		talentRoom = ____temp_38, -- 1023
		talentOffers = ____temp_39, -- 1024
		talentRanks = ____talentRanks_40, -- 1025
		escortAttempt = ____temp_41, -- 1026
		escortVariant = ____temp_42, -- 1027
		talentDeferred = ____temp_0, -- 1028
		talentVitality = story.talents ~= nil and story.talents.ranks.vitality or 0, -- 1029
		talentReload = story.talents ~= nil and story.talents.ranks.focus or 0, -- 1030
		talentGuard = story.talents ~= nil and story.talents.ranks.guard or 0, -- 1031
		talentCraft = story.talents ~= nil and story.talents.ranks.salvage or 0, -- 1032
		props = props, -- 1033
		playerX = self.player.x, -- 1034
		playerY = self.player.y, -- 1035
		playerDepth = self.player.depth, -- 1036
		gateTick = self.gateTick, -- 1037
		hasBottle = self.hasBottle, -- 1038
		villagePassed = self.passed -- 1039
	} -- 1039
end -- 945
function Play.prototype.submitFeIntent(self, intent) -- 1047
	local kind = intent == nil and "" or intent.kind -- 1048
	if kind == "gateReunionHold" then -- 1049
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1050
			return false -- 1051
		end -- 1051
		local holding = intent.holding == true -- 1053
		self.intentGateReunionHold = holding -- 1054
		if not holding and self.phase == "gate-wait" then -- 1055
			if self.handTicks > 0 then -- 1056
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1057
			end -- 1057
			self.handTicks = 0 -- 1059
			self.handArmed = true -- 1060
		end -- 1060
		return true -- 1062
	end -- 1062
	if kind == "reloadOpen" then -- 1064
		local camp = self.room.campaign -- 1065
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1066
			return false -- 1067
		end -- 1067
		self:beginReload() -- 1069
		return self.reloadOpen -- 1070
	end -- 1070
	if kind == "reloadPathPreview" then -- 1072
		local path = intent.path -- 1073
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1074
	end -- 1074
	if kind == "reloadTapNode" then -- 1076
		local node = intent.node -- 1077
		if type(node) == "number" then -- 1078
			self:reloadTapNode(node) -- 1079
			return true -- 1080
		end -- 1080
		return false -- 1082
	end -- 1082
	if kind == "reloadPathCommit" then -- 1084
		local path = intent.path -- 1085
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1086
			local list = path -- 1087
			local i = 0 -- 1088
			do -- 1088
				i = 0 -- 1089
				while i < #list do -- 1089
					do -- 1089
						if i == 0 and list[i + 1] == RELOAD_START then -- 1090
							goto __continue82 -- 1091
						end -- 1091
						self:reloadTapNode(list[i + 1]) -- 1093
					end -- 1093
					::__continue82:: -- 1093
					i = i + 1 -- 1089
				end -- 1089
			end -- 1089
			return true -- 1095
		end -- 1095
		return false -- 1097
	end -- 1097
	if kind == "reloadCancel" then -- 1099
		self:closeReloadPuzzle() -- 1100
		return true -- 1101
	end -- 1101
	if kind == "craftSubmit" then -- 1103
		local recipeId = intent.recipeId -- 1104
		local requestId = intent.requestId -- 1105
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1106
			return self:craftAtBench(recipeId, requestId) -- 1107
		end -- 1107
		return false -- 1109
	end -- 1109
	if kind == "craftEquip" then -- 1111
		local weaponId = intent.weaponId -- 1112
		if type(weaponId) == "string" then -- 1113
			return self:equipWeapon(weaponId) -- 1114
		end -- 1114
		return false -- 1116
	end -- 1116
	if kind == "craftClose" then -- 1118
		self:closeCraftBench() -- 1119
		return true -- 1120
	end -- 1120
	if kind == "chooseTalent" then -- 1122
		local slot = intent.slot -- 1123
		if type(slot) == "number" then -- 1124
			return self:chooseTalent(slot) -- 1125
		end -- 1125
		return false -- 1127
	end -- 1127
	if kind == "wellPick" then -- 1129
		return self:pickWell() -- 1130
	end -- 1130
	if kind == "museumInteract" then -- 1132
		local target = type(intent.target) == "string" and intent.target or "" -- 1133
		if target == "well_pickup" or target == "well" then -- 1134
			return self:pickWell() -- 1135
		end -- 1135
		if self.room.key ~= "museum" then -- 1137
			return false -- 1138
		end -- 1138
		return self:triggerMuseumIntent(target) -- 1140
	end -- 1140
	return false -- 1142
end -- 1047
function Play.prototype.triggerMuseumIntent(self, target) -- 1146
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1147
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1150
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1151
	if self.phase == "museum-cabinet" then -- 1152
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1153
			self.pendingMuseumIntentTarget = "cabinet" -- 1154
			return true -- 1155
		end -- 1155
	end -- 1155
	if self.phase == "museum-hall" then -- 1158
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1159
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1160
			return true -- 1161
		end -- 1161
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1163
			self.pendingMuseumIntentTarget = "hall" -- 1164
			return true -- 1165
		end -- 1165
	end -- 1165
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1168
		self.pendingMuseumIntentTarget = "lamp" -- 1171
		return true -- 1172
	end -- 1172
	if self.phase == "museum-return" then -- 1174
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1175
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1177
			return true -- 1178
		end -- 1178
	end -- 1178
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1181
		self.pendingMuseumIntentTarget = "done" -- 1182
		return true -- 1183
	end -- 1183
	return false -- 1185
end -- 1146
function Play.prototype.captureCheckpoint(self, id) -- 1189
	local inv = self.run.inventory -- 1190
	self.checkpointSnap = { -- 1191
		id = id, -- 1192
		wood = inv.wood, -- 1193
		bell = inv.bell, -- 1194
		scrap = inv.scrap, -- 1195
		wedge = inv.wedge, -- 1196
		ammo = inv.ammo, -- 1197
		shield = inv.shield, -- 1198
		pass = inv.pass, -- 1199
		quickbelt = inv.quickbelt, -- 1200
		crafted = self.run.story.craftedWeapon, -- 1201
		equipped = self.equippedWeapon, -- 1202
		carry = self.carryOn -- 1203
	} -- 1203
	self.run.story.cp = self.checkpointSnap -- 1205
end -- 1189
function Play.prototype.applyCheckpointSnap(self, id) -- 1209
	local snap = self.run.story.cp -- 1210
	if snap == nil or snap.id ~= id then -- 1211
		return false -- 1212
	end -- 1212
	self.checkpointSnap = snap -- 1214
	local inv = self.run.inventory -- 1215
	inv.wood = snap.wood -- 1216
	inv.bell = snap.bell -- 1217
	inv.scrap = snap.scrap -- 1218
	inv.wedge = snap.wedge -- 1219
	inv.ammo = snap.ammo -- 1220
	inv.shield = snap.shield -- 1221
	inv.pass = snap.pass -- 1222
	inv.quickbelt = snap.quickbelt -- 1223
	self.run.story.craftedWeapon = snap.crafted -- 1224
	self.equippedWeapon = snap.equipped -- 1225
	self.run.story.equippedWeapon = snap.equipped -- 1226
	self.carryOn = snap.carry -- 1227
	self.run.story.carry = snap.carry -- 1228
	self.craftBench.active = false -- 1229
	self:syncCraftBench() -- 1230
	return true -- 1231
end -- 1209
function Play.prototype.restoreStory(self) -- 1234
	local story = self.run.story -- 1235
	if story == nil then -- 1236
		return -- 1237
	end -- 1237
	if story.maxHp > 0 then -- 1239
		self.maxHp = story.maxHp -- 1240
		self.hp = math.max( -- 1241
			1, -- 1241
			math.min(story.hp, story.maxHp) -- 1241
		) -- 1241
	end -- 1241
	self.storyRoute = story.route -- 1243
	self.storySettled = story.settled -- 1244
	self.hpAtGate = story.hpAtGate -- 1245
	self.maxHpAtGate = story.maxHpAtGate -- 1246
	self.handDone = story.handDone -- 1247
	self.lineSaid = story.lineSaid -- 1248
	self.tied = story.handDone -- 1249
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 1250
	self.museumReturn = story.museumReturn -- 1251
	story.museumReturn = false -- 1252
	self.escortDone = story.escortDone -- 1253
	local savedEq = story.equippedWeapon -- 1254
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 1255
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 1256
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 1257
		self.equippedWeapon = savedEq -- 1258
	else -- 1258
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 1260
	end -- 1260
	self:syncCraftBench() -- 1262
	if story.segments.outside_cart == true then -- 1264
		self.redCartPulled = true -- 1265
		local redBox = __TS__ArrayFind( -- 1266
			self.boxes, -- 1266
			function(____, b) return b.id == "outside_red_cart" end -- 1266
		) -- 1266
		if redBox ~= nil then -- 1267
			redBox.x0 = 430 -- 1268
			redBox.x1 = 474 -- 1269
		end -- 1269
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1271
			self.cartAxle = self.room.cart.endX -- 1272
			self.cartDocked = true -- 1273
		end -- 1273
	end -- 1273
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1276
	self.waterSeen = story.segments.water_lantern == true -- 1278
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1280
		self:applyCheckpointSnap(self.checkpoint) -- 1281
	end -- 1281
	if self.room.key == "tower" and story.route == "soldier" then -- 1284
		self.carryOn = false -- 1285
		self.run.story.carry = false -- 1286
		self.player.w = SOLDIER_W -- 1287
		self.player.h = SOLDIER_H -- 1288
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1289
		self.partner = { -- 1290
			x = math.max(self.ox + 408, self.player.x - 24), -- 1291
			y = 0, -- 1292
			depth = 0, -- 1293
			depthSpeed = 0, -- 1294
			vx = 0, -- 1295
			vy = 0, -- 1296
			w = CHILD_W, -- 1297
			h = CHILD_H, -- 1298
			onGround = true, -- 1299
			facing = 1, -- 1300
			crouch = false, -- 1301
			rollT = 0, -- 1302
			covered = false, -- 1303
			alive = true -- 1304
		} -- 1304
	end -- 1304
	if self.room.key == "tower" then -- 1308
		if story.segments.tower_door == true then -- 1309
			self:openTowerDoor() -- 1310
		end -- 1310
		self.towerHanded = story.segments.tower_handover == true -- 1312
		self.deskHold = 0 -- 1313
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1314
			self.phase = story.phase -- 1315
			self.phaseTick = 0 -- 1316
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1317
				self.player.x = self.ox + 605 -- 1318
				self.player.y = 0 -- 1319
				if story.route == "soldier" and self.partner.alive then -- 1320
					self.partner.x = self.ox + 568 -- 1321
					self.partner.y = 0 -- 1322
					self.partner.facing = 1 -- 1323
				end -- 1323
			end -- 1323
		end -- 1323
	end -- 1323
	if self.room.key == "prologue" then -- 1329
		local ph = story.phase -- 1330
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1331
			self.phase = ph -- 1332
			self.phaseTick = story.phaseTick -- 1333
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1334
			self.player.y = 0 -- 1335
			self.player.depth = 0 -- 1336
			self.player.vx = 0 -- 1337
			self.partner.x = self.ox + 300 -- 1338
			self.partner.y = 0 -- 1339
			self.partner.depth = 0 -- 1340
			self.partner.vx = 0 -- 1341
			self.partner.alive = true -- 1342
			if ph == "prologue-follow" then -- 1343
				self.partner.crouch = false -- 1344
				self.partner.h = CHILD_H -- 1345
			else -- 1345
				self.partner.crouch = true -- 1347
				self.partner.h = CHILD_CROUCH_H -- 1348
			end -- 1348
			self.cam.x = self.player.x -- 1350
		end -- 1350
		return -- 1352
	end -- 1352
	if self.room.key ~= "gate" then -- 1354
		return -- 1355
	end -- 1355
	local ____temp_43 -- 1357
	if self.room.story == nil then -- 1357
		____temp_43 = nil -- 1357
	else -- 1357
		____temp_43 = self.room.story.gate -- 1357
	end -- 1357
	local g = ____temp_43 -- 1357
	if g == nil then -- 1358
		return -- 1359
	end -- 1359
	if story.phase == "gate-send" then -- 1362
		self.phase = "gate-send" -- 1363
		self.gateTick = g.holdTicks -- 1364
		self.gateSpawned = 4 -- 1365
		self.enemies = {} -- 1366
		self.player.x = self.ox + g.doorX - 40 -- 1367
		self.player.y = 0 -- 1368
		self.player.depth = 0 -- 1369
		self.player.vx = 0 -- 1370
		self.player.vy = 0 -- 1371
		self.player.onGround = true -- 1372
		self.partner.x = self.ox + g.waitX -- 1373
		self.partner.y = 0 -- 1374
		self.partner.depth = 0 -- 1375
		self.partner.alive = true -- 1376
		self.cam.x = self.player.x -- 1377
		self.handTicks = 0 -- 1378
		self.handArmed = false -- 1379
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1380
		return -- 1381
	end -- 1381
	if not story.settled then -- 1383
		return -- 1384
	end -- 1384
	self.gateTick = g.holdTicks -- 1387
	self.gateSpawned = 4 -- 1388
	self.enemies = {} -- 1389
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1390
		self.phase = story.phase -- 1391
		self.countTick = math.max(story.countTick, 0) -- 1392
		self:swapToChild(g.doorX + 30) -- 1393
		self.countPrevMove = 0 -- 1394
		self.countArmed = false -- 1395
		return -- 1396
	end -- 1396
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1398
		self.phase = story.phase -- 1399
		self.countTick = ____exports.GATE_COUNT_END -- 1400
		self.phaseTick = story.phaseTick -- 1401
		self:swapToChild(g.doorX + 30) -- 1402
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1403
			0, -- 1403
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1403
		) -- 1403
		self.handArmed = false -- 1404
	end -- 1404
end -- 1234
function Play.prototype.buildWorld(self) -- 1409
	local room = self.room -- 1410
	self.boxes = {} -- 1411
	self.floors = {} -- 1412
	local i = 0 -- 1413
	do -- 1413
		i = 0 -- 1414
		while i < #room.floors do -- 1414
			local f = room.floors[i + 1] -- 1415
			local ____self_floors_44 = self.floors -- 1416
			____self_floors_44[#____self_floors_44 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1416
			i = i + 1 -- 1414
		end -- 1414
	end -- 1414
	do -- 1414
		i = 0 -- 1418
		while i < #room.solids do -- 1418
			local s = room.solids[i + 1] -- 1419
			if not s.decorative then -- 1420
				local ____self_boxes_56 = self.boxes -- 1425
				local ____s_x_47 = s.x -- 1426
				local ____temp_48 = s.x + s.w -- 1426
				local ____s_y_49 = s.y -- 1426
				local ____temp_50 = s.y + s.h -- 1426
				local ____temp_45 -- 1427
				if room.depth == nil then -- 1427
					____temp_45 = nil -- 1427
				else -- 1427
					____temp_45 = s.depth -- 1427
				end -- 1427
				local ____temp_51 = s.passable == true -- 1428
				local ____s_label_52 = s.label -- 1428
				local ____s_id_53 = s.id -- 1429
				local ____temp_54 = s.soft == true -- 1429
				local ____temp_55 = s.hidden == true -- 1429
				local ____temp_46 -- 1430
				if s.breakable == nil then -- 1430
					____temp_46 = nil -- 1430
				else -- 1430
					____temp_46 = __TS__ObjectAssign({}, s.breakable) -- 1430
				end -- 1430
				____self_boxes_56[#____self_boxes_56 + 1] = { -- 1425
					x0 = ____s_x_47, -- 1426
					x1 = ____temp_48, -- 1426
					y0 = ____s_y_49, -- 1426
					y1 = ____temp_50, -- 1426
					depth = ____temp_45, -- 1427
					passable = ____temp_51, -- 1428
					label = ____s_label_52, -- 1428
					id = ____s_id_53, -- 1429
					soft = ____temp_54, -- 1429
					hidden = ____temp_55, -- 1429
					breakable = ____temp_46, -- 1430
					interact = s.interact -- 1431
				} -- 1431
			end -- 1431
			i = i + 1 -- 1418
		end -- 1418
	end -- 1418
	do -- 1418
		i = 0 -- 1435
		while i < #room.stairs do -- 1435
			local st = room.stairs[i + 1] -- 1436
			local n = st.steps + 1 -- 1437
			local stepW = (st.x1 - st.x0) / n -- 1438
			local k = 0 -- 1439
			do -- 1439
				k = 0 -- 1440
				while k < n do -- 1440
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1441
					local x0 = st.x0 + stepW * k -- 1442
					local ____self_boxes_60 = self.boxes -- 1445
					local ____temp_58 = x0 + stepW -- 1446
					local ____temp_59 = -8 -- 1446
					local ____temp_57 -- 1447
					if room.depth == nil then -- 1447
						____temp_57 = nil -- 1447
					else -- 1447
						____temp_57 = st.depth -- 1447
					end -- 1447
					____self_boxes_60[#____self_boxes_60 + 1] = { -- 1445
						x0 = x0, -- 1446
						x1 = ____temp_58, -- 1446
						y0 = ____temp_59, -- 1446
						y1 = y, -- 1446
						depth = ____temp_57, -- 1447
						passable = true -- 1448
					} -- 1448
					k = k + 1 -- 1440
				end -- 1440
			end -- 1440
			i = i + 1 -- 1435
		end -- 1435
	end -- 1435
end -- 1409
function Play.prototype.setupCampaign(self) -- 1458
	local wr = self.room -- 1459
	local c = wr.campaign -- 1460
	if c == nil then -- 1461
		return -- 1462
	end -- 1462
	self.roomStartTick = self.run.ticks -- 1464
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1466
		self.run.joined = true -- 1468
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1469
		local ____self_run_65 = self.run -- 1471
		local ____temp_64 -- 1471
		if wr.key == "s2-drygoods" then -- 1471
			local ____temp_63 = self.run.route ~= "drygoods" -- 1472
			if not ____temp_63 then -- 1472
				local ____opt_61 = self.run.props.s2_board -- 1472
				____temp_63 = (____opt_61 and ____opt_61.broken) == true -- 1472
			end -- 1472
			____temp_64 = ____temp_63 -- 1472
		else -- 1472
			____temp_64 = wr.key == "c1-yard" and self.run.c1Latch -- 1473
		end -- 1473
		____self_run_65.joined = ____temp_64 -- 1471
	end -- 1471
	local x = wr.minX + 60 -- 1475
	local y = 0 -- 1476
	local depth = 0 -- 1477
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1478
		x = wr.minX + 210 -- 1479
		depth = -32 -- 1480
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1481
		x = wr.minX + 40 -- 1482
		y = 32 -- 1483
		depth = 32 -- 1484
	end -- 1484
	self.player = { -- 1486
		x = x, -- 1487
		y = y, -- 1487
		depth = depth, -- 1487
		depthSpeed = 0, -- 1487
		vx = 0, -- 1487
		vy = 0, -- 1487
		w = SOLDIER_W, -- 1488
		h = SOLDIER_H, -- 1488
		onGround = y <= 0, -- 1488
		facing = 1, -- 1488
		crouch = false, -- 1488
		rollT = 0, -- 1488
		covered = false, -- 1488
		alive = true -- 1488
	} -- 1488
	self.partner = { -- 1490
		x = x + 60, -- 1491
		y = y, -- 1491
		depth = depth, -- 1491
		depthSpeed = 0, -- 1491
		vx = 0, -- 1491
		vy = 0, -- 1491
		w = CHILD_W, -- 1492
		h = CHILD_H, -- 1492
		onGround = y <= 0, -- 1492
		facing = 1, -- 1492
		crouch = false, -- 1492
		rollT = 0, -- 1492
		covered = false, -- 1492
		alive = true -- 1492
	} -- 1492
	self.cam.x = x -- 1494
	self.cam.y = y + CAM_LOOK_UP -- 1495
	self.phase = "run" -- 1496
	self.hp = self.maxHp -- 1497
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1498
		if self.run.story.talents == nil then -- 1499
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1500
		end -- 1500
		local st = self.run.story.talents -- 1502
		local variants = ESCORT_VARIANTS[wr.key] -- 1503
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1504
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1505
		else -- 1505
			st.variant = 0 -- 1507
		end -- 1507
		if wr.key == "escort3" then -- 1511
			if st.room ~= "escort3" then -- 1512
				st.room = "escort3" -- 1513
				st.deferred = true -- 1514
				st.offers = {} -- 1515
			end -- 1515
		else -- 1515
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1518
		end -- 1518
	end -- 1518
	self:buildEnemies() -- 1521
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1522
	local i = 0 -- 1523
	do -- 1523
		i = 0 -- 1524
		while i < #self.boxes do -- 1524
			do -- 1524
				local b = self.boxes[i + 1] -- 1525
				if b.id == nil then -- 1526
					goto __continue160 -- 1527
				end -- 1527
				local st = self.run.props[b.id] -- 1529
				if st ~= nil then -- 1530
					b.broken = st.broken -- 1531
					local ____temp_66 -- 1532
					if b.breakable == nil then -- 1532
						____temp_66 = nil -- 1532
					else -- 1532
						____temp_66 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1532
					end -- 1532
					b.breakable = ____temp_66 -- 1532
					b.hidden = b.hidden == true and st.revealed ~= true -- 1533
					if b.hidden then -- 1534
						b.broken = true -- 1535
					end -- 1535
				elseif b.hidden == true then -- 1537
					b.broken = true -- 1539
				end -- 1539
			end -- 1539
			::__continue160:: -- 1539
			i = i + 1 -- 1524
		end -- 1524
	end -- 1524
	if wr.cart.bodyW > 0 then -- 1542
		self.cartAxle = wr.cart.startX -- 1543
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1544
			self.cartAxle = wr.cart.endX -- 1545
			self.cartDocked = true -- 1546
		end -- 1546
	end -- 1546
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1549
end -- 1458
function Play.prototype.log(self, line) -- 1552
	local ____self_run_log_67 = self.run.log -- 1553
	____self_run_log_67[#____self_run_log_67 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1553
	if #self.run.log > 120 then -- 1554
		table.remove(self.run.log, 1) -- 1555
	end -- 1555
end -- 1552
function Play.prototype.buildEnemies(self) -- 1559
	self.enemies = {} -- 1560
	if self.isCampaign then -- 1561
		local variants = ESCORT_VARIANTS[self.room.key] -- 1562
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1563
		local ____useVariant_71 -- 1568
		if useVariant then -- 1568
			local ____temp_70 = #variants - 1 -- 1569
			local ____opt_68 = self.run.story.talents -- 1569
			____useVariant_71 = math.max( -- 1569
				0, -- 1569
				math.min(____temp_70, ____opt_68 and ____opt_68.variant or 0) -- 1569
			) -- 1569
		else -- 1569
			____useVariant_71 = 0 -- 1570
		end -- 1570
		local vIdx = ____useVariant_71 -- 1568
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1571
		local i = 0 -- 1572
		do -- 1572
			i = 0 -- 1573
			while i < #spawnList do -- 1573
				local sp = spawnList[i + 1] -- 1574
				local kind = sp.kind or "gunner" -- 1575
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1576
				local sx = useVariant and self.ox + sp.x or sp.x -- 1577
				local ____self_enemies_72 = self.enemies -- 1578
				____self_enemies_72[#____self_enemies_72 + 1] = { -- 1578
					x = sx, -- 1579
					y = sp.y, -- 1579
					depth = sp.depth, -- 1579
					w = 26, -- 1579
					h = sp.h, -- 1579
					alive = true, -- 1579
					hitT = 0, -- 1579
					warnT = 0, -- 1579
					fireCd = 40, -- 1579
					kind = kind, -- 1580
					shieldHp = hp, -- 1580
					shieldHpMax = hp, -- 1580
					drop = sp.drop or "none", -- 1580
					homeX = sx, -- 1581
					swingT = 0, -- 1581
					awake = false, -- 1581
					squad = i -- 1581
				} -- 1581
				i = i + 1 -- 1573
			end -- 1573
		end -- 1573
		return -- 1584
	end -- 1584
	if self.room.key == "checkpoint" then -- 1586
		local ____self_enemies_73 = self.enemies -- 1587
		____self_enemies_73[#____self_enemies_73 + 1] = { -- 1587
			x = self.ox + 430, -- 1587
			y = 0, -- 1587
			w = 26, -- 1587
			h = 84, -- 1587
			alive = true, -- 1587
			hitT = 0, -- 1587
			warnT = 0, -- 1587
			fireCd = 0 -- 1587
		} -- 1587
		local ____self_enemies_74 = self.enemies -- 1588
		____self_enemies_74[#____self_enemies_74 + 1] = { -- 1588
			x = self.ox + 505, -- 1588
			y = 0, -- 1588
			w = 26, -- 1588
			h = 84, -- 1588
			alive = true, -- 1588
			hitT = 0, -- 1588
			warnT = 0, -- 1588
			fireCd = 0 -- 1588
		} -- 1588
		return -- 1589
	end -- 1589
	if self.room.key == "street" then -- 1591
		local ____self_enemies_75 = self.enemies -- 1593
		____self_enemies_75[#____self_enemies_75 + 1] = { -- 1593
			x = self.ox + 340, -- 1593
			y = 0, -- 1593
			w = 26, -- 1593
			h = 84, -- 1593
			alive = true, -- 1593
			hitT = 0, -- 1593
			warnT = 0, -- 1593
			fireCd = 0 -- 1593
		} -- 1593
		local ____self_enemies_76 = self.enemies -- 1594
		____self_enemies_76[#____self_enemies_76 + 1] = { -- 1594
			x = self.ox + 560, -- 1594
			y = 0, -- 1594
			w = 26, -- 1594
			h = 84, -- 1594
			alive = true, -- 1594
			hitT = 0, -- 1594
			warnT = 0, -- 1594
			fireCd = 0 -- 1594
		} -- 1594
	end -- 1594
end -- 1559
function Play.prototype.emit(self, name, data) -- 1600
	local ____self_events_77 = self.events -- 1601
	____self_events_77[#____self_events_77 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1601
	self.eventSeq = self.eventSeq + 1 -- 1602
	if #self.events > 256 then -- 1603
		table.remove(self.events, 1) -- 1604
	end -- 1604
end -- 1600
function Play.prototype.drainEvents(self) -- 1612
	local out = self.events -- 1613
	self.events = {} -- 1614
	return out -- 1615
end -- 1612
function Play.prototype.adoptEvents(self, events) -- 1624
	if #events == 0 then -- 1625
		return -- 1626
	end -- 1626
	local keep = {} -- 1628
	local i = 0 -- 1629
	do -- 1629
		i = 0 -- 1630
		while i < #events do -- 1630
			do -- 1630
				local e = events[i + 1] -- 1631
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1632
					goto __continue181 -- 1633
				end -- 1633
				keep[#keep + 1] = e -- 1635
			end -- 1635
			::__continue181:: -- 1635
			i = i + 1 -- 1630
		end -- 1630
	end -- 1630
	if #keep == 0 then -- 1637
		return -- 1638
	end -- 1638
	self.events = __TS__ArrayConcat(keep, self.events) -- 1640
	do -- 1640
		i = 0 -- 1641
		while i < #self.events do -- 1641
			self.events[i + 1].seq = i -- 1642
			i = i + 1 -- 1641
		end -- 1641
	end -- 1641
	self.eventSeq = #self.events -- 1644
end -- 1624
function Play.prototype.talentRank(self, talent) -- 1647
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1648
		return self.run.story.talents.ranks[talent] or 0 -- 1649
	end -- 1649
	return 0 -- 1651
end -- 1647
function Play.prototype.reloadNeedTicks(self) -- 1655
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1656
end -- 1655
function Play.prototype.getStoryTalentOffers(self) -- 1660
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1661
		return {} -- 1662
	end -- 1662
	local st = self.run.story.talents -- 1664
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1665
end -- 1660
function Play.prototype.getStoryTalentRanks(self) -- 1669
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1670
		return nil -- 1671
	end -- 1671
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1673
end -- 1669
function Play.prototype.getEscortAttempt(self) -- 1677
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1678
end -- 1677
function Play.prototype.chooseTalent(self, slot) -- 1681
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1682
		return false -- 1683
	end -- 1683
	local st = self.run.story.talents -- 1685
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1686
	if st == nil or talent == nil then -- 1687
		return false -- 1688
	end -- 1688
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1690
	st.offers = {} -- 1691
	self.talentModalActive = false -- 1692
	local extraMsg = "" -- 1693
	if talent == "vitality" then -- 1694
		self.maxHp = self.maxHp + 1 -- 1695
		self.hp = self.hp + 1 -- 1696
		self.run.story.maxHp = self.maxHp -- 1697
		self.run.story.hp = self.hp -- 1698
	elseif talent == "salvage" then -- 1699
		local inv = self.run.inventory -- 1700
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1701
			inv.wood = inv.wood + 1 -- 1702
			extraMsg = " · 得木纹筹×1" -- 1703
		else -- 1703
			inv.bell = inv.bell + 1 -- 1705
			extraMsg = " · 得铃纹筹×1" -- 1706
		end -- 1706
		self:syncCraftBench() -- 1708
	end -- 1708
	self.sessionDirty = true -- 1710
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1711
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1712
	return true -- 1713
end -- 1681
function Play.prototype.beginReload(self) -- 1720
	self.reloadT = self:reloadTicks() -- 1721
	local camp = self.room.campaign -- 1722
	if camp ~= nil and camp.reloadPuzzle == true then -- 1723
		self:openReloadPuzzle() -- 1724
	end -- 1724
end -- 1720
function Play.prototype.openReloadPuzzle(self) -- 1729
	self.reloadOpen = true -- 1730
	self.reloadAnswerTicks = 0 -- 1731
	self.reloadWorldTicks = 0 -- 1732
	self.reloadPath = {RELOAD_START} -- 1733
	self.reloadPendingEffect = "" -- 1734
	self.reloadTryCount = self.reloadTryCount + 1 -- 1735
	self:emit( -- 1736
		"reloadOpen", -- 1736
		{ -- 1736
			tryCount = self.reloadTryCount, -- 1736
			needTicks = self:reloadNeedTicks() -- 1736
		} -- 1736
	) -- 1736
end -- 1729
function Play.prototype.closeReloadPuzzle(self) -- 1740
	self.reloadOpen = false -- 1741
	self.reloadAnswerTicks = 0 -- 1742
	self.reloadWorldTicks = 0 -- 1743
	self.reloadPath = {RELOAD_START} -- 1744
	self.reloadPendingEffect = "" -- 1745
end -- 1740
function Play.prototype.reloadTapNode(self, node) -- 1752
	if not self.reloadOpen then -- 1753
		return -- 1754
	end -- 1754
	local path = self.reloadPath -- 1756
	local last = path[#path] -- 1757
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1758
		self.reloadPath = {RELOAD_START} -- 1759
		self:emit("reloadInvalid", {node = node, at = last}) -- 1760
		return -- 1761
	end -- 1761
	path[#path + 1] = node -- 1763
	if node ~= RELOAD_TARGET then -- 1764
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1765
		return -- 1766
	end -- 1766
	if not reloadPathValid(path) then -- 1768
		self.reloadPath = {RELOAD_START} -- 1769
		self:emit("reloadInvalid", {node = node, at = last}) -- 1770
		return -- 1771
	end -- 1771
	self.reloadPendingEffect = reloadEffectOf(path) -- 1773
	self.reloadOpen = false -- 1774
	self.reloadT = 0 -- 1775
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1776
	self:flashSet( -- 1779
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1779
		1.4 -- 1779
	) -- 1779
end -- 1752
function Play.prototype.consumeReloadEffect(self) -- 1783
	local e = self.reloadPendingEffect -- 1784
	if e ~= "" then -- 1785
		self.reloadPendingEffect = "" -- 1786
	end -- 1786
	return e -- 1788
end -- 1783
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1795
	if count == nil then -- 1795
		count = 1 -- 1795
	end -- 1795
	if delayTicks == nil then -- 1795
		delayTicks = 60 -- 1795
	end -- 1795
	local best = -1 -- 1796
	local bestD = 1000000000 -- 1797
	local i = 0 -- 1798
	local woken = {} -- 1799
	local n = 0 -- 1800
	while n < count do -- 1801
		best = -1 -- 1802
		bestD = 1000000000 -- 1803
		do -- 1803
			i = 0 -- 1804
			while i < #self.enemies do -- 1804
				do -- 1804
					if woken[i] == true then -- 1805
						goto __continue215 -- 1806
					end -- 1806
					local e = self.enemies[i + 1] -- 1808
					if not e.alive then -- 1809
						goto __continue215 -- 1810
					end -- 1810
					local d = math.abs(e.x - from.x) -- 1812
					if d < bestD then -- 1813
						bestD = d -- 1814
						best = i -- 1815
					end -- 1815
				end -- 1815
				::__continue215:: -- 1815
				i = i + 1 -- 1804
			end -- 1804
		end -- 1804
		if best < 0 then -- 1818
			break -- 1819
		end -- 1819
		woken[best] = true -- 1821
		local e = self.enemies[best + 1] -- 1822
		e.awake = true -- 1823
		e.warnT = 0 -- 1824
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1825
		n = n + 1 -- 1826
	end -- 1826
	if n == 0 then -- 1828
		return -- 1829
	end -- 1829
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1831
end -- 1795
function Play.prototype.reloadTicks(self) -- 1834
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1835
end -- 1834
function Play.prototype.update(self, dt, input) -- 1838
	self:syncCraftBench() -- 1839
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1840
		self:closeCraftBench() -- 1841
		return -- 1842
	end -- 1842
	if input.pause.pressed then -- 1844
		self.paused = not self.paused -- 1845
	end -- 1845
	if self.flashT > 0 then -- 1847
		self.flashT = self.flashT - dt -- 1848
		if self.flashT <= 0 then -- 1849
			self.flash = "" -- 1850
		end -- 1850
	end -- 1850
	if self.traceT > 0 then -- 1853
		self.traceT = self.traceT - dt -- 1854
		if self.traceT <= 0 then -- 1855
			self.trace = nil -- 1856
		end -- 1856
	end -- 1856
	if self.paused then -- 1859
		self:updateCamera(dt) -- 1860
		return -- 1861
	end -- 1861
	if self.escortFailed then -- 1864
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1865
		self:updateCamera(dt) -- 1866
		return -- 1867
	end -- 1867
	if self.craftBench.active then -- 1871
		self:updateCamera(dt) -- 1872
		return -- 1873
	end -- 1873
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1876
		self:updateCamera(dt) -- 1877
		return -- 1878
	end -- 1878
	if self.reloadOpen then -- 1883
		local needTicks = self:reloadNeedTicks() -- 1884
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1885
		if self.reloadAnswerTicks > needTicks then -- 1886
			self.reloadOpen = false -- 1887
			self.reloadPendingEffect = "" -- 1888
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1889
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1890
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1891
			self:updateCamera(dt) -- 1892
			return -- 1893
		else -- 1893
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1895
		end -- 1895
	end -- 1895
	self.ticks = self.ticks + 1 -- 1899
	if self.invulnT > 0 then -- 1902
		self.invulnT = self.invulnT - 1 -- 1903
	end -- 1903
	if self.isCampaign then -- 1905
		local ____self_run_78, ____ticks_79 = self.run, "ticks" -- 1906
		____self_run_78[____ticks_79] = ____self_run_78[____ticks_79] + 1 -- 1906
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1907
	end -- 1907
	local p = self.player -- 1909
	self:stepPlayer(p, dt, input) -- 1910
	self:refreshCover(p, input) -- 1912
	if self.carryOn then -- 1913
		self:carryPose() -- 1914
	end -- 1914
	if self.isCampaign then -- 1916
		self:stepCampaign(dt, input) -- 1917
		if not self.carryOn then -- 1918
			self:stepCampaignPartner(dt) -- 1919
		end -- 1919
	end -- 1919
	self:stepEnemies(dt, input) -- 1924
	if not self.isCampaign then -- 1925
		self:stepStory(dt, input) -- 1926
		self:stepEscort(dt, input) -- 1927
		self:stepVillage(dt, input) -- 1928
		self:stepChase(dt, input) -- 1929
		self:stepInteract(dt, input) -- 1930
	end -- 1930
	self:updateGate() -- 1932
	self:updateCamera(dt) -- 1933
	self:syncStory() -- 1935
end -- 1838
function Play.prototype.underLowArch(self, a) -- 1942
	local arch = self.room.arch -- 1943
	if arch.h <= 0 then -- 1944
		return false -- 1945
	end -- 1945
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1947
		return false -- 1948
	end -- 1948
	local top = arch.y + arch.h -- 1950
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1951
end -- 1942
function Play.prototype.coverAt(self, a) -- 1958
	local best = nil -- 1959
	local bestGap = 24 -- 1960
	local half = a.w / 2 -- 1961
	local i = 0 -- 1962
	do -- 1962
		i = 0 -- 1963
		while i < #self.boxes do -- 1963
			do -- 1963
				local b = self.boxes[i + 1] -- 1964
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1965
					goto __continue248 -- 1966
				end -- 1966
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1968
					goto __continue248 -- 1969
				end -- 1969
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1971
				if gap < bestGap then -- 1972
					bestGap = gap -- 1973
					best = b -- 1974
				end -- 1974
			end -- 1974
			::__continue248:: -- 1974
			i = i + 1 -- 1963
		end -- 1963
	end -- 1963
	return best -- 1977
end -- 1958
function Play.prototype.nearCover(self, a) -- 1980
	return self:coverAt(a) ~= nil -- 1981
end -- 1980
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1985
	if enemy == nil then -- 1986
		return false -- 1987
	end -- 1987
	local fromRight = enemy.x >= a.x -- 1989
	local edge = fromRight and b.x0 or b.x1 -- 1990
	local ____fromRight_80 -- 1991
	if fromRight then -- 1991
		____fromRight_80 = edge >= a.x - 0.001 and edge <= enemy.x -- 1991
	else -- 1991
		____fromRight_80 = edge <= a.x + 0.001 and edge >= enemy.x -- 1992
	end -- 1992
	local between = ____fromRight_80 -- 1991
	local separation = enemy.x - a.x -- 1993
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1994
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1995
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1996
end -- 1985
function Play.prototype.nearestEnemy(self, a) -- 1999
	local best -- 2000
	local bestD = 1000000000 -- 2001
	local i = 0 -- 2002
	do -- 2002
		i = 0 -- 2003
		while i < #self.enemies do -- 2003
			do -- 2003
				local e = self.enemies[i + 1] -- 2004
				if not e.alive then -- 2005
					goto __continue257 -- 2006
				end -- 2006
				local d = math.abs(e.x - a.x) -- 2008
				if d < bestD then -- 2009
					bestD = d -- 2010
					best = e -- 2011
				end -- 2011
			end -- 2011
			::__continue257:: -- 2011
			i = i + 1 -- 2003
		end -- 2003
	end -- 2003
	return best -- 2014
end -- 1999
function Play.prototype.refreshCover(self, a, input) -- 2018
	if self.childMode then -- 2019
		self.coverNear = false -- 2020
		self.coverHug = false -- 2021
		self.coverEntity = "" -- 2022
		self.coverBlocking = false -- 2023
		a.covered = false -- 2024
		return -- 2025
	end -- 2025
	local b = self:coverAt(a) -- 2027
	self.coverNear = b ~= nil -- 2028
	a.covered = self.coverNear and input.cover.held -- 2029
	self.coverHug = a.covered -- 2030
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 2031
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2032
		b, -- 2032
		a, -- 2032
		self:nearestEnemy(a) -- 2032
	) -- 2032
end -- 2018
function Play.prototype.cartHandleInReach(self, a) -- 2036
	if a == nil then -- 2036
		a = self.player -- 2036
	end -- 2036
	local c = self.room.cart -- 2037
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2038
		return false -- 2039
	end -- 2039
	local handleX = self.cartAxle + c.handleOffset -- 2041
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 2042
end -- 2036
function Play.prototype.nearLowLedge(self, a) -- 2047
	local reach = 26 -- 2048
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2049
	local x1 = x0 + reach -- 2050
	local i = 0 -- 2051
	do -- 2051
		i = 0 -- 2052
		while i < #self.boxes do -- 2052
			do -- 2052
				local b = self.boxes[i + 1] -- 2053
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2054
					goto __continue266 -- 2055
				end -- 2055
				local rise = b.y1 - a.y -- 2057
				if rise > 0 and rise <= LEDGE_RISE then -- 2058
					return true -- 2059
				end -- 2059
			end -- 2059
			::__continue266:: -- 2059
			i = i + 1 -- 2052
		end -- 2052
	end -- 2052
	return false -- 2062
end -- 2047
function Play.prototype.stepPlayer(self, a, dt, input) -- 2065
	a.depthSpeed = 0 -- 2066
	if not a.alive then -- 2067
		return -- 2068
	end -- 2068
	local isChild = self.childMode -- 2070
	local lowArch = isChild and self:underLowArch(a) -- 2072
	if self:storyLocked() then -- 2074
		a.vx = 0 -- 2075
		a.crouch = isChild and lowArch -- 2076
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2077
		self:fallY(a, dt) -- 2078
		return -- 2079
	end -- 2079
	if not isChild and self.escort.state == "calming" then -- 2082
		a.crouch = false -- 2083
		a.h = SOLDIER_H -- 2084
		a.vx = 0 -- 2085
		self:fallY(a, dt) -- 2086
		return -- 2087
	end -- 2087
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2089
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2090
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2091
	local nearCover = not isChild and self:nearCover(a) -- 2092
	a.covered = nearCover and input.cover.held -- 2093
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2095
	if a.rollT > 0 then -- 2098
		a.rollT = a.rollT - dt -- 2099
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2100
		a.vx = a.facing * rollSpd -- 2101
		self:slideX(a, a.vx * dt) -- 2102
		self:fallY(a, dt) -- 2103
		if a.rollT <= 0 then -- 2104
			self:flashSet("翻滚结束", 0.5) -- 2105
		end -- 2105
		return -- 2107
	end -- 2107
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2110
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2111
		if input.moveX ~= 0 then -- 2112
			a.facing = input.moveX > 0 and 1 or -1 -- 2113
		end -- 2113
		if self:nearLowLedge(a) then -- 2116
			a.vy = SOLDIER_JUMP -- 2117
			a.onGround = false -- 2118
			self:flashSet("翻上去", 0.3) -- 2119
			return -- 2120
		end -- 2120
		a.rollT = ROLL_TIME -- 2122
		self:flashSet("翻滚", 0.3) -- 2123
		return -- 2124
	end -- 2124
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2127
	if isChild then -- 2128
		if input.cover.held then -- 2129
			speed = CHILD_SLOW -- 2130
		end -- 2130
		if a.crouch then -- 2132
			speed = CHILD_SLOW -- 2133
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2134
			speed = CHILD_SPEED * 1.22 -- 2137
		end -- 2137
	else -- 2137
		if self:isEscortRoom() then -- 2140
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2141
		end -- 2141
		if a.covered then -- 2143
			speed = speed * 0.45 -- 2144
		end -- 2144
	end -- 2144
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2149
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2150
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2152
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2154
	if dir ~= 0 then -- 2155
		a.facing = dir > 0 and 1 or -1 -- 2156
	end -- 2156
	a.vx = dir * speed * diagonal -- 2158
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2161
		a.vy = CHILD_JUMP -- 2162
		a.onGround = false -- 2163
		self:flashSet("跳", 0.25) -- 2164
	end -- 2164
	local previousDepth = a.depth -- 2168
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2169
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2170
	self:slideX(a, a.vx * dt) -- 2171
	self:fallY(a, dt) -- 2172
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2175
		self:shoot(a) -- 2176
	end -- 2176
	local ____temp_83 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2179
	if ____temp_83 then -- 2179
		local ____opt_81 = self.room.campaign -- 2180
		____temp_83 = (____opt_81 and ____opt_81.reloadPuzzle) == true -- 2179
	end -- 2179
	if ____temp_83 and input.flare.pressed then -- 2179
		self:beginReload() -- 2181
	end -- 2181
end -- 2065
function Play.prototype.stepPartner(self, p, dt) -- 2186
	local a = self.partner -- 2187
	if not a.alive then -- 2188
		return -- 2189
	end -- 2189
	a.crouch = false -- 2191
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2192
	a.vx = 0 -- 2193
	a.depthSpeed = 0 -- 2194
	self:fallY(a, dt) -- 2195
end -- 2186
function Play.prototype.stepEscort(self, dt, input) -- 2202
	local a = self.partner -- 2203
	a.depthSpeed = 0 -- 2204
	if not a.alive then -- 2205
		return -- 2206
	end -- 2206
	if self.room.key == "gatepath" then -- 2208
		if self.carryOn then -- 2210
			return -- 2211
		end -- 2211
		local p = self.player -- 2214
		a.depth = p.depth -- 2215
		a.facing = p.facing -- 2216
		a.crouch = false -- 2217
		a.h = CHILD_H -- 2218
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2219
		a.y = p.y -- 2220
		a.vy = 0 -- 2221
		a.vx = p.vx -- 2222
		a.onGround = p.onGround -- 2223
		return -- 2224
	end -- 2224
	if not self:escortOn() then -- 2226
		a.vx = 0 -- 2227
		self:fallY(a, dt) -- 2228
		return -- 2229
	end -- 2229
	local p = self.player -- 2231
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2232
	local hadKnock1 = self.escort.knock1 -- 2233
	local hadKnock2 = self.escort.knock2 -- 2234
	self.calmConsumed = self.escort:update( -- 2235
		input, -- 2235
		p.x, -- 2235
		p.facing, -- 2235
		a.x, -- 2235
		dist -- 2235
	) -- 2235
	if not hadKnock1 and self.escort.knock1 then -- 2237
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2238
	end -- 2238
	if not hadKnock2 and self.escort.knock2 then -- 2240
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2241
	end -- 2241
	a.crouch = self.escort.crouchPose -- 2243
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2244
	if not self.escort.stopped then -- 2245
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2246
		local previousDepth = a.depth -- 2247
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2248
		local distance = math.max( -- 2249
			-travel, -- 2249
			math.min(travel, targetDepth - previousDepth) -- 2249
		) -- 2249
		self:slideDepth(a, distance) -- 2250
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2251
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2252
			a.vy = CHILD_JUMP -- 2253
			a.onGround = false -- 2254
		end -- 2254
	end -- 2254
	local dir = self.escort:moveDir(a.x) -- 2257
	a.vx = dir * CHILD_SPEED -- 2258
	if dir ~= 0 then -- 2259
		a.facing = dir -- 2260
		local before = a.x -- 2261
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2262
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2264
			a.vy = CHILD_JUMP -- 2265
			a.onGround = false -- 2266
		end -- 2266
	end -- 2266
	self:fallY(a, dt) -- 2269
end -- 2202
function Play.prototype.escortOn(self) -- 2273
	if self.room.key == "checkpoint" then -- 2274
		return true -- 2275
	end -- 2275
	if self.room.key == "gatepath" then -- 2277
		return true -- 2278
	end -- 2278
	if self.room.key == "prologue" then -- 2280
		return self.phase == "prologue-follow" -- 2281
	end -- 2281
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2283
		return true -- 2285
	end -- 2285
	return self.room.key == "street" -- 2287
end -- 2273
function Play.prototype.storyLocked(self) -- 2291
	if self.caughtT > 0 then -- 2292
		return true -- 2293
	end -- 2293
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2295
		return true -- 2297
	end -- 2297
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2299
		return true -- 2300
	end -- 2300
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2302
		return true -- 2303
	end -- 2303
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2305
		return true -- 2306
	end -- 2306
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2308
		return true -- 2309
	end -- 2309
	if self.craftBench.active then -- 2312
		return true -- 2313
	end -- 2313
	return false -- 2315
end -- 2291
function Play.prototype.swapToChild(self, x) -- 2319
	local tmp = self.player -- 2320
	self.player = self.partner -- 2321
	self.partner = tmp -- 2322
	self.childMode = true -- 2323
	self.player.alive = true -- 2324
	self.player.x = self.ox + x -- 2325
	self.player.y = 0 -- 2326
	self.player.depth = 0 -- 2327
	self.player.depthSpeed = 0 -- 2328
	self.player.vy = 0 -- 2329
	self.player.vx = 0 -- 2330
	self.player.onGround = true -- 2331
	self.player.crouch = false -- 2332
	self.player.h = CHILD_H -- 2333
	self.player.facing = 1 -- 2334
	self.partner.alive = true -- 2335
	self.cam.x = self.player.x -- 2336
end -- 2319
function Play.prototype.swapToSoldier(self, x, childX) -- 2340
	local tmp = self.player -- 2341
	self.player = self.partner -- 2342
	self.partner = tmp -- 2343
	self.childMode = false -- 2344
	self.player.alive = true -- 2345
	self.player.x = self.ox + x -- 2346
	self.player.y = 0 -- 2347
	self.player.depth = 0 -- 2348
	self.player.depthSpeed = 0 -- 2349
	self.player.vy = 0 -- 2350
	self.player.vx = 0 -- 2351
	self.player.onGround = true -- 2352
	self.player.crouch = false -- 2353
	self.player.h = SOLDIER_H -- 2354
	self.player.facing = 1 -- 2355
	self.partner.alive = true -- 2356
	self.partner.x = self.ox + childX -- 2357
	self.partner.y = 0 -- 2358
	self.partner.depth = 0 -- 2359
	self.partner.depthSpeed = 0 -- 2360
	self.partner.vx = 0 -- 2361
	self.partner.vy = 0 -- 2362
	self.partner.onGround = true -- 2363
	self.partner.crouch = true -- 2364
	self.partner.h = CHILD_CROUCH_H -- 2365
	self.cam.x = self.player.x -- 2366
end -- 2340
function Play.prototype.stepStory(self, dt, input) -- 2370
	if self.room.key == "prologue" then -- 2371
		self:stepPrologue(dt, input) -- 2372
	elseif self.room.key == "street" then -- 2373
		self:stepStreet(dt, input) -- 2374
	elseif self.room.key == "gate" then -- 2375
		self:stepGate(dt, input) -- 2376
	elseif self.room.key == "gatepath" then -- 2377
		self:stepGatePath() -- 2378
	elseif self.room.key == "tower" then -- 2379
		self:stepTower(dt, input) -- 2380
	elseif self.room.key == "museum" then -- 2381
		self:stepMuseum(dt, input) -- 2382
	end -- 2382
end -- 2370
function Play.prototype.canPersistProgress(self) -- 2388
	return not self.isCampaign and self.run.source == "official" -- 2389
end -- 2388
function Play.prototype.wellWindow(self) -- 2393
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2394
end -- 2393
function Play.prototype.nearWell(self) -- 2399
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2400
end -- 2399
function Play.prototype.pickWell(self) -- 2408
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2409
		return false -- 2410
	end -- 2410
	self.phase = "prologue-well" -- 2412
	self.phaseTick = 0 -- 2413
	self.wellOpen = false -- 2414
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2415
	self:log("旧井拾取") -- 2416
	return true -- 2417
end -- 2408
function Play.prototype.stepPrologue(self, dt, input) -- 2420
	local child = self.partner -- 2421
	if self.museumReturn then -- 2422
		self.museumReturn = false -- 2424
		self.phase = "prologue-wait" -- 2425
		self.phaseTick = 0 -- 2426
		self.player.x = self.ox + 260 -- 2427
		self.player.y = 0 -- 2428
		self.player.depth = 0 -- 2429
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2430
	end -- 2430
	if self.phase == "prologue-wake" then -- 2433
		self.introTick = self.introTick + 1 -- 2434
		if self.introTick == 60 then -- 2435
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2436
		end -- 2436
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2438
			self.phase = "prologue-shadow" -- 2439
			self.introTick = 0 -- 2440
			self:flashSet("门缝里两道影子", 1.2) -- 2441
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2442
		end -- 2442
		return -- 2444
	end -- 2444
	if self.phase == "prologue-shadow" then -- 2446
		self.introTick = self.introTick + 1 -- 2447
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2448
			self.phase = "prologue-escape" -- 2450
			self.introTick = 0 -- 2451
			self.escapeRemaining = self.escapeDuration -- 2452
			self.escapeRetryCount = 0 -- 2453
			self:swapToChild(100) -- 2454
			self:flashSet( -- 2455
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2455
				1.6 -- 2455
			) -- 2455
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2456
		end -- 2456
		return -- 2460
	end -- 2460
	if self.phase == "prologue-escape" then -- 2462
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2463
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2464
			self.phase = "prologue-hide" -- 2466
			self.introTick = 0 -- 2467
			self.player.vx = 0 -- 2468
			self.player.crouch = true -- 2469
			self.player.h = CHILD_CROUCH_H -- 2470
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2471
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2472
			return -- 2476
		end -- 2476
		if self.escapeRemaining <= 0 then -- 2478
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2480
			self.player.x = self.ox + 100 -- 2481
			self.player.y = 0 -- 2482
			self.player.depth = 0 -- 2483
			self.player.vx = 0 -- 2484
			self.player.vy = 0 -- 2485
			self.escapeRemaining = self.escapeDuration -- 2486
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2487
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2488
			return -- 2489
		end -- 2489
		return -- 2491
	end -- 2491
	if self.phase == "prologue-hide" then -- 2493
		self.introTick = self.introTick + 1 -- 2494
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2495
			self.phase = "prologue-wait" -- 2497
			self.phaseTick = 0 -- 2498
			self.introTick = 0 -- 2499
			self:swapToSoldier(260, 300) -- 2500
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2501
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2502
		end -- 2502
		return -- 2504
	end -- 2504
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2507
	if self.phase == "prologue-wait" then -- 2508
		child.crouch = true -- 2509
		child.h = CHILD_CROUCH_H -- 2510
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2511
			self:pickWell() -- 2512
			return -- 2513
		end -- 2513
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2516
			self.archive.museumPhase = "well_reflect" -- 2518
			self.archiveDirty = true -- 2519
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2520
			return -- 2521
		end -- 2521
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2523
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2525
		if near and input.interact.pressed then -- 2526
			self.phase = "prologue-give" -- 2527
			self.phaseTick = 0 -- 2528
			self:flashSet("递出针套", 1) -- 2529
		end -- 2529
		return -- 2531
	end -- 2531
	if self.phase == "prologue-well" then -- 2533
		self.phaseTick = self.phaseTick + 1 -- 2535
		if self.phaseTick == 12 then -- 2536
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2537
		elseif self.phaseTick >= 30 then -- 2538
			self.phase = "prologue-wait" -- 2539
			self.phaseTick = 0 -- 2540
			self.wellTaken = true -- 2541
			self.wellOpen = false -- 2542
			self.run.archive.artifactOwned = true -- 2543
			self.archiveDirty = true -- 2544
			self:emit("artifactFound", { -- 2545
				x = self.ox + self.wellX, -- 2546
				y = 0, -- 2546
				room = "prologue", -- 2546
				once = true, -- 2546
				source = self.run.source -- 2547
			}) -- 2547
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2549
			self:log("井底取到时间穿梭器") -- 2550
		end -- 2550
		return -- 2552
	end -- 2552
	if self.phase == "prologue-give" then -- 2554
		self.phaseTick = self.phaseTick + 1 -- 2555
		if self.phaseTick == 12 then -- 2556
			self:flashSet("针套递过去", 0.7) -- 2557
		elseif self.phaseTick == 36 then -- 2558
			self:flashSet("纸条塞进针套", 0.9) -- 2559
		elseif self.phaseTick >= 60 then -- 2560
			self.phase = "prologue-follow" -- 2561
			self.phaseTick = 0 -- 2562
			child.crouch = false -- 2563
			child.h = CHILD_H -- 2564
			self:flashSet("她跟上了", 1.2) -- 2565
		end -- 2565
		return -- 2567
	end -- 2567
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2570
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2571
		self:requestRoom(next, "序章跟到门口") -- 2572
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2573
	end -- 2573
end -- 2420
function Play.prototype.stepStreet(self, dt, input) -- 2578
	local p = self.player -- 2579
	local c = self.partner -- 2580
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2581
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2582
		self:requestRoom(next, "两人都到街尾") -- 2583
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2584
	end -- 2584
end -- 2578
function Play.prototype.stepGate(self, dt, input) -- 2589
	local ____temp_84 -- 2590
	if self.room.story == nil then -- 2590
		____temp_84 = nil -- 2590
	else -- 2590
		____temp_84 = self.room.story.gate -- 2590
	end -- 2590
	local g = ____temp_84 -- 2590
	if g == nil then -- 2591
		return -- 2592
	end -- 2592
	local p = self.player -- 2594
	if self.phase == "gate-idle" then -- 2595
		local a = self.partner -- 2597
		local gap = g.waitX - a.x -- 2598
		if math.abs(gap) > 3 then -- 2599
			a.facing = gap > 0 and 1 or -1 -- 2600
			a.vx = a.facing * CHILD_SPEED -- 2601
			local beforeX = a.x -- 2602
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2603
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2604
				a.vy = CHILD_JUMP -- 2605
				a.onGround = false -- 2606
			end -- 2606
			self:fallY(a, dt) -- 2608
		else -- 2608
			a.vx = 0 -- 2610
			a.x = g.waitX -- 2611
		end -- 2611
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2614
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2615
		if self.gateNeedConfirm then -- 2616
			if not input.interact.held then -- 2619
				self.gateRestartArmed = true -- 2620
			end -- 2620
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2622
				self.gateNeedConfirm = false -- 2623
				self.gateRestartArmed = true -- 2624
				self.phase = "gate-hold" -- 2625
				self.gateTick = 0 -- 2626
				self.gateSpawned = 0 -- 2627
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2628
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2629
			end -- 2629
			return -- 2631
		end -- 2631
		if atWinch and atWait then -- 2633
			self.phase = "gate-hold" -- 2634
			self.gateTick = 0 -- 2635
			self.gateSpawned = 0 -- 2636
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2637
		end -- 2637
		return -- 2639
	end -- 2639
	if self.phase == "gate-hold" then -- 2641
		self.gateTick = self.gateTick + 1 -- 2642
		local marks = {0, 540, 900, 1500} -- 2644
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2645
			local idx = self.gateSpawned -- 2646
			local ____self_enemies_85 = self.enemies -- 2647
			____self_enemies_85[#____self_enemies_85 + 1] = { -- 2647
				x = self.ox + 620 + idx * 62, -- 2648
				y = 0, -- 2648
				w = 26, -- 2648
				h = 84, -- 2648
				alive = true, -- 2649
				hitT = 0, -- 2649
				warnT = 0, -- 2649
				fireCd = 90 + idx * 45 -- 2649
			} -- 2649
			self.gateSpawned = self.gateSpawned + 1 -- 2651
			self:flashSet( -- 2652
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2652
				0.9 -- 2652
			) -- 2652
		end -- 2652
		if self.gateTick == 900 then -- 2654
			self:flashSet("棚布落下", 1) -- 2655
		elseif self.gateTick == 2100 then -- 2656
			self:flashSet("门底透进冷光了", 1) -- 2657
		end -- 2657
		if self.gateTick >= g.holdTicks then -- 2659
			self:captureGateBlood() -- 2662
			self.phase = "gate-send" -- 2663
			self.phaseTick = 0 -- 2664
			self.enemies = {} -- 2666
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2667
		end -- 2667
		return -- 2669
	end -- 2669
	if self.phase == "gate-send" then -- 2671
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2672
		if near and input.interact.pressed then -- 2673
			self:commitRoute() -- 2675
			self:swapToChild(g.doorX + 30) -- 2676
			self.phase = "gate-count" -- 2677
			self.countTick = 0 -- 2678
			self.countArmed = false -- 2680
			self.countPrevMove = input.moveX -- 2681
			self:flashSet("门开了 · 送她出去", 1.8) -- 2682
		end -- 2682
		return -- 2684
	end -- 2684
	if self.phase == "gate-count" then -- 2686
		self.countTick = self.countTick + 1 -- 2687
		if self.countTick == 360 then -- 2688
			self:flashSet("门关上", 0.9) -- 2689
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2690
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2691
			if self.storyRoute == "soldier" then -- 2695
				self.phase = "gate-wait" -- 2697
				self.phaseTick = 0 -- 2698
				self.knocks = 1 -- 2699
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2700
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2702
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2703
			else -- 2703
				self:flashSet("数到二十", 2.2) -- 2705
			end -- 2705
		end -- 2705
		local prevMove = self.countPrevMove -- 2710
		self.countPrevMove = input.moveX -- 2711
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2712
			if prevMove <= 0 and input.moveX > 0 then -- 2713
				self.countArmed = true -- 2714
			end -- 2714
			if self.countArmed and input.moveX > 0 then -- 2716
				self.phase = "gate-walk" -- 2717
				self.phaseTick = 0 -- 2718
				self:flashSet("她迈出第一步", 1.4) -- 2719
				self:emit("storyExit", { -- 2720
					route = "child", -- 2720
					via = "walk", -- 2720
					countTick = self.countTick, -- 2720
					hp = self.hp, -- 2720
					maxHp = self.maxHp -- 2720
				}) -- 2720
			end -- 2720
		end -- 2720
		return -- 2723
	end -- 2723
	if self.phase == "gate-wait" then -- 2725
		self.phaseTick = self.phaseTick + 1 -- 2727
		if self.phaseTick == 12 then -- 2728
			self.knocks = 2 -- 2729
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2730
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2731
		end -- 2731
		local held = input.interact.held or self.intentGateReunionHold -- 2733
		if not held then -- 2734
			if self.handTicks > 0 then -- 2735
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2736
			end -- 2736
			self.handTicks = 0 -- 2738
			self.handArmed = true -- 2739
			return -- 2740
		end -- 2740
		if self.handArmed then -- 2742
			self.handTicks = self.handTicks + 1 -- 2743
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2744
				self.intentGateReunionHold = false -- 2745
				self.phase = "gate-hand" -- 2746
				self.phaseTick = 0 -- 2747
				self.handDone = true -- 2748
				self.tied = true -- 2749
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2750
				if not self.lineSaid then -- 2751
					self.lineSaid = true -- 2752
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2753
				end -- 2753
				self:flashSet("我们走吧。", 3) -- 2755
			end -- 2755
		end -- 2755
		return -- 2758
	end -- 2758
	if self.phase == "gate-hand" then -- 2760
		self.phaseTick = self.phaseTick + 1 -- 2762
		if self.phaseTick == 30 then -- 2763
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2764
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2765
			self:emit("storyExit", { -- 2766
				route = "soldier", -- 2766
				via = "hand", -- 2766
				handTicks = self.handTicks, -- 2766
				hp = self.hp, -- 2766
				maxHp = self.maxHp -- 2766
			}) -- 2766
			self:requestRoom("gatepath", "牵手同行") -- 2767
		end -- 2767
		return -- 2769
	end -- 2769
	if self.phase == "gate-walk" then -- 2772
		if self.player.x >= g.exitX then -- 2773
			self:requestRoom("outside", "走出城门") -- 2774
			self:flashSet("出城门 · 城外", 1.4) -- 2775
		end -- 2775
	end -- 2775
end -- 2589
function Play.prototype.captureGateBlood(self) -- 2784
	self.hpAtGate = self.hp -- 2785
	self.maxHpAtGate = self.maxHp -- 2786
end -- 2784
function Play.prototype.commitRoute(self) -- 2793
	if self.storySettled then -- 2794
		return -- 2795
	end -- 2795
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2797
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2798
	self.hpAtGate = hp -- 2799
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2800
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2801
	self.storySettled = true -- 2802
	self.sessionDirty = true -- 2803
	self:emit("storyRouteLocked", { -- 2804
		route = self.storyRoute, -- 2805
		hp = self.hp, -- 2805
		maxHp = self.maxHp, -- 2805
		hpAtGate = self.hpAtGate, -- 2806
		maxHpAtGate = self.maxHpAtGate -- 2806
	}) -- 2806
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2808
end -- 2793
function Play.prototype.syncStory(self) -- 2812
	local s = self.run.story -- 2813
	if s == nil then -- 2814
		return -- 2815
	end -- 2815
	s.hp = self.hp -- 2817
	s.maxHp = self.maxHp -- 2818
	s.route = self.storyRoute -- 2819
	s.settled = self.storySettled -- 2820
	s.hpAtGate = self.hpAtGate -- 2821
	s.maxHpAtGate = self.maxHpAtGate -- 2822
	s.handDone = self.handDone -- 2823
	s.lineSaid = self.lineSaid -- 2824
	s.tied = self.tied -- 2825
	s.carry = self.carryOn -- 2826
	s.museumReturn = self.museumReturn -- 2827
	s.escortDone = self.escortDone -- 2828
	s.craftedWeapon = self.run.story.craftedWeapon -- 2829
	s.equippedWeapon = self.equippedWeapon -- 2830
	s.ending = self.run.story.ending -- 2831
	if self.room.key == "gate" then -- 2832
		s.phase = self.phase -- 2833
		s.countTick = self.countTick -- 2834
		s.phaseTick = self.phaseTick -- 2835
		s.handTicks = self.handTicks -- 2836
	end -- 2836
	if self.room.key == "prologue" then -- 2838
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2840
			s.phase = self.phase -- 2841
			s.phaseTick = self.phaseTick -- 2842
		end -- 2842
	end -- 2842
	if self.room.key == "tower" then -- 2845
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2847
			s.phase = self.phase -- 2848
			s.phaseTick = self.phaseTick -- 2849
		end -- 2849
	end -- 2849
end -- 2812
function Play.prototype.stepGatePath(self) -- 2855
	local ____temp_86 -- 2856
	if self.room.story == nil then -- 2856
		____temp_86 = nil -- 2856
	else -- 2856
		____temp_86 = self.room.story.gatepath -- 2856
	end -- 2856
	local gp = ____temp_86 -- 2856
	if self.phase == "gatepath-start" then -- 2857
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2858
			self.carryOn = true -- 2859
			self.phase = "gatepath-carry" -- 2860
			self.phaseTick = 0 -- 2861
			self.pathDone = true -- 2862
			self.escortDone = false -- 2863
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2864
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2865
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2866
		end -- 2866
		return -- 2868
	end -- 2868
	if self.phase == "gatepath-carry" then -- 2870
		self.phaseTick = self.phaseTick + 1 -- 2871
		if self.phaseTick == 20 then -- 2872
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2873
		end -- 2873
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2875
			self:requestRoom(gp.next, "背负进首战") -- 2876
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2877
		end -- 2877
	end -- 2877
end -- 2855
function Play.prototype.carryPose(self) -- 2886
	local p = self.player -- 2887
	local a = self.partner -- 2888
	a.alive = true -- 2889
	a.x = p.x - p.facing * 12 -- 2890
	a.y = p.y + 26 -- 2891
	a.depth = p.depth -- 2892
	a.vx = p.vx -- 2893
	a.vy = 0 -- 2894
	a.onGround = true -- 2895
	a.crouch = false -- 2896
	a.h = CHILD_CROUCH_H -- 2897
	a.facing = p.facing -- 2898
end -- 2886
function Play.prototype.stepMuseum(self, dt, input) -- 2906
	self.partner.alive = false -- 2907
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2908
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2911
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2912
	local intentTarget = self.pendingMuseumIntentTarget -- 2913
	self.pendingMuseumIntentTarget = "" -- 2914
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2915
	if self.phase == "museum-cabinet" then -- 2916
		if atCase and interactHit or intentTarget == "cabinet" then -- 2917
			self.phase = "museum-hall" -- 2918
			self.phaseTick = 0 -- 2919
			if self:canPersistProgress() then -- 2920
				self.archive.museumPhase = "hall_walk" -- 2921
				self.archiveDirty = true -- 2922
			end -- 2922
			self:emit( -- 2924
				"museumStep", -- 2924
				{ -- 2924
					step = "cabinet", -- 2924
					x = self.ox + mu.cabinetX, -- 2924
					persisted = self:canPersistProgress() -- 2924
				} -- 2924
			) -- 2924
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2925
		end -- 2925
		return -- 2927
	end -- 2927
	if self.phase == "museum-hall" then -- 2929
		if intentTarget == "lamp_direct" and nearLamp then -- 2930
			self:emit( -- 2931
				"museumStep", -- 2931
				{ -- 2931
					step = "hall", -- 2931
					x = self.ox + mu.hallX, -- 2931
					persisted = self:canPersistProgress() -- 2931
				} -- 2931
			) -- 2931
			self.phase = "museum-return" -- 2932
			self.phaseTick = 0 -- 2933
			if self:canPersistProgress() then -- 2934
				self.archive.museumPhase = "return_cabinet" -- 2935
				self.archiveDirty = true -- 2936
			end -- 2936
			self:emit( -- 2938
				"museumStep", -- 2938
				{ -- 2938
					step = "lamp", -- 2938
					x = self.ox + mu.lampX, -- 2938
					persisted = self:canPersistProgress() -- 2938
				} -- 2938
			) -- 2938
			self:flashSet("灯 · 转向西窗", 1.8) -- 2939
			return -- 2940
		end -- 2940
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2942
			self.phase = "museum-lamp" -- 2943
			self.phaseTick = 0 -- 2944
			if self:canPersistProgress() then -- 2945
				self.archive.museumPhase = "lamp_turn" -- 2946
				self.archiveDirty = true -- 2947
			end -- 2947
			self:emit( -- 2949
				"museumStep", -- 2949
				{ -- 2949
					step = "hall", -- 2949
					x = self.ox + mu.hallX, -- 2949
					persisted = self:canPersistProgress() -- 2949
				} -- 2949
			) -- 2949
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2950
		end -- 2950
		return -- 2952
	end -- 2952
	if self.phase == "museum-lamp" then -- 2954
		if nearLamp and interactHit then -- 2955
			self.phase = "museum-return" -- 2956
			self.phaseTick = 0 -- 2957
			if self:canPersistProgress() then -- 2958
				self.archive.museumPhase = "return_cabinet" -- 2959
				self.archiveDirty = true -- 2960
			end -- 2960
			self:emit( -- 2962
				"museumStep", -- 2962
				{ -- 2962
					step = "lamp", -- 2962
					x = self.ox + mu.lampX, -- 2962
					persisted = self:canPersistProgress() -- 2962
				} -- 2962
			) -- 2962
			self:flashSet("灯 · 转向西窗", 1.8) -- 2963
		end -- 2963
		return -- 2965
	end -- 2965
	if self.phase == "museum-return" then -- 2967
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2968
			self.phase = "museum-knock" -- 2969
			self.phaseTick = 0 -- 2970
			self:emit( -- 2971
				"museumStep", -- 2971
				{ -- 2971
					step = "knock", -- 2971
					count = 1, -- 2971
					x = self.ox + mu.cabinetX, -- 2971
					persisted = self:canPersistProgress() -- 2971
				} -- 2971
			) -- 2971
			self:flashSet("回柜边 · 第一下", 0.8) -- 2972
		end -- 2972
		return -- 2974
	end -- 2974
	if self.phase == "museum-knock" then -- 2976
		self.phaseTick = self.phaseTick + 1 -- 2977
		if self.phaseTick == 8 then -- 2978
			self:emit( -- 2979
				"museumStep", -- 2979
				{ -- 2979
					step = "knock", -- 2979
					count = 2, -- 2979
					x = self.ox + mu.cabinetX, -- 2979
					persisted = self:canPersistProgress() -- 2979
				} -- 2979
			) -- 2979
			self:flashSet("回柜边 · 第二下", 0.8) -- 2980
		elseif self.phaseTick >= 36 then -- 2981
			self.phase = "museum-done" -- 2982
			self.phaseTick = 0 -- 2983
			if self:canPersistProgress() then -- 2984
				self.archive.museumSeen = true -- 2985
				self.archive.museumPhase = "done" -- 2986
				self.archiveDirty = true -- 2987
			end -- 2987
			self:emit( -- 2989
				"museumDone", -- 2989
				{ -- 2989
					steps = 4, -- 2989
					museumSeen = self.archive.museumSeen, -- 2989
					persisted = self:canPersistProgress() -- 2989
				} -- 2989
			) -- 2989
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2990
			self:log("博物馆 · 回柜边") -- 2991
		end -- 2991
		return -- 2993
	end -- 2993
	if interactHit then -- 2995
		self.museumReturn = true -- 2996
		self:requestRoom("prologue", "回柜边") -- 2997
	end -- 2997
end -- 2906
function Play.prototype.openTowerDoor(self) -- 3001
	self.towerDoorOpen = true -- 3002
	do -- 3002
		local i = 0 -- 3003
		while i < #self.boxes do -- 3003
			if self.boxes[i + 1].id == "tower_door" then -- 3004
				self.boxes[i + 1].hidden = true -- 3005
			end -- 3005
			i = i + 1 -- 3003
		end -- 3003
	end -- 3003
	self.run.story.segments.tower_door = true -- 3008
end -- 3001
function Play.prototype.stepTower(self, dt, input) -- 3011
	local ____temp_87 -- 3012
	if self.room.story == nil then -- 3012
		____temp_87 = nil -- 3012
	else -- 3012
		____temp_87 = self.room.story.tower -- 3012
	end -- 3012
	local t = ____temp_87 -- 3012
	if t == nil then -- 3013
		return -- 3014
	end -- 3014
	if self.storyRoute == "soldier" and self.partner.alive then -- 3017
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3018
		local gap = targetX - self.partner.x -- 3019
		if math.abs(gap) > 2 then -- 3020
			local dir = gap > 0 and 1 or -1 -- 3021
			local stepDist = math.min( -- 3022
				math.abs(gap), -- 3022
				SOLDIER_SPEED * dt -- 3022
			) -- 3022
			self.partner.facing = dir -- 3023
			self.partner.vx = dir * SOLDIER_SPEED -- 3024
			local ____self_partner_88, ____x_89 = self.partner, "x" -- 3025
			____self_partner_88[____x_89] = ____self_partner_88[____x_89] + dir * stepDist -- 3025
		else -- 3025
			self.partner.vx = 0 -- 3027
			self.partner.facing = 1 -- 3028
		end -- 3028
	end -- 3028
	if self.phase == "tower-wait" then -- 3031
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3032
		if near and input.interact.pressed then -- 3033
			self.phase = "tower-knock" -- 3034
			self.phaseTick = 0 -- 3035
			self.knocks = 1 -- 3036
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3037
			self:flashSet("叩两下 · 第一声", 0.6) -- 3038
		end -- 3038
		return -- 3040
	end -- 3040
	if self.phase == "tower-knock" then -- 3042
		self.phaseTick = self.phaseTick + 1 -- 3043
		if self.phaseTick == 12 then -- 3044
			self.knocks = 2 -- 3045
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3046
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3047
		elseif self.phaseTick >= t.knockTicks then -- 3048
			self:openTowerDoor() -- 3049
			self.phase = "tower-enter" -- 3050
			self.phaseTick = 0 -- 3051
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3052
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3053
		end -- 3053
		return -- 3055
	end -- 3055
	if self.phase == "tower-enter" then -- 3057
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3058
			self.phase = "tower-desk" -- 3059
			self.phaseTick = 0 -- 3060
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3061
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3062
		end -- 3062
		return -- 3064
	end -- 3064
	if self.phase == "tower-desk" then -- 3066
		local deskX = self.ox + 605 -- 3067
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3068
		if not near or not input.interact.held then -- 3069
			self.deskHold = 0 -- 3070
			return -- 3071
		end -- 3071
		self.deskHold = self.deskHold + 1 -- 3073
		if self.deskHold == 12 then -- 3074
			self:flashSet("针套 · 放在桌上", 1) -- 3075
		elseif self.deskHold == 24 then -- 3076
			self:flashSet("指南针 · 压住纸条", 1) -- 3077
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3078
			self.towerHanded = true -- 3079
			self.deskHold = 0 -- 3080
			self.run.story.segments.tower_handover = true -- 3081
			self.phase = "tower-given" -- 3082
			self.phaseTick = 0 -- 3083
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3084
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3089
		end -- 3089
		return -- 3091
	end -- 3091
	if self.phase == "tower-given" then -- 3093
		local soldier = self.storyRoute == "soldier" -- 3096
		self.phaseTick = self.phaseTick + 1 -- 3097
		if self.phaseTick == 60 then -- 3098
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3099
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3100
		elseif self.phaseTick == 120 then -- 3101
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3102
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3103
			self.phase = "tower-end" -- 3104
			self.phaseTick = 0 -- 3105
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3106
			if not self.run.finished then -- 3107
				self.run.finished = true -- 3108
				local ending = soldier and "reunion" or "lamp" -- 3109
				self.run.story.ending = ending -- 3110
				local ____soldier_90 -- 3113
				if soldier then -- 3113
					____soldier_90 = self.run.story.segments.escort5 == true -- 3114
				else -- 3114
					____soldier_90 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3115
				end -- 3115
				local played = ____soldier_90 -- 3113
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3116
				if official then -- 3118
					if soldier then -- 3119
						self.run.archive.soldierCleared = true -- 3120
					else -- 3120
						self.run.archive.childCleared = true -- 3122
					end -- 3122
					self.archiveDirty = true -- 3124
				end -- 3124
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3126
				self:emit("endingReached", { -- 3127
					route = soldier and "soldier" or "child", -- 3128
					ending = ending, -- 3129
					official = official, -- 3130
					source = self.run.source, -- 3131
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3132
					childCleared = self.run.archive.childCleared, -- 3133
					soldierCleared = self.run.archive.soldierCleared, -- 3134
					artifactOwned = self.run.archive.artifactOwned, -- 3135
					equipped = self.equippedWeapon -- 3136
				}) -- 3136
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3138
			end -- 3138
		end -- 3138
		return -- 3141
	end -- 3141
	self.phaseTick = self.phaseTick + 1 -- 3143
	local held = input.interact.held or input.retry.held -- 3144
	if self.towerEndMustRelease then -- 3145
		if not held then -- 3146
			self.towerEndMustRelease = false -- 3147
		end -- 3147
		return -- 3149
	end -- 3149
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3151
	if self.phaseTick < waitTicks then -- 3152
		if input.interact.pressed or input.retry.pressed then -- 3153
			self.towerEndMustRelease = held -- 3154
		end -- 3154
		return -- 3156
	end -- 3156
	if input.interact.pressed or input.retry.pressed then -- 3158
		self.restartStory = true -- 3160
		self:requestRoom("prologue", "片尾再玩") -- 3161
		self:flashSet("回到序章", 1.4) -- 3162
	end -- 3162
end -- 3011
function Play.prototype.stepChase(self, dt, input) -- 3167
	if self.caughtT > 0 then -- 3168
		self.caughtT = self.caughtT - dt -- 3169
		if self.caughtT <= 0 then -- 3170
			self:recoverFromCaught() -- 3171
		end -- 3171
		return -- 3173
	end -- 3173
	if self.room.key == "village" then -- 3175
		self:stepScavChase() -- 3176
	elseif self.room.key == "forest" then -- 3177
		self:stepForestRoute() -- 3178
		self:stepDog(dt) -- 3179
		if self.player.x >= self.ox + 1450 then -- 3181
			self:requestRoom("tower", "到林缘北塔") -- 3182
			self:flashSet("林缘 · 北塔", 1.4) -- 3183
		end -- 3183
	end -- 3183
end -- 3167
function Play.prototype.stepScavChase(self) -- 3189
	local s = self.room.scavenger -- 3190
	if s == nil then -- 3191
		return -- 3192
	end -- 3192
	local p = self.player -- 3194
	if self.passed and p.x > self.ox + 440 then -- 3196
		if self.scavChase then -- 3197
			self.scavChase = false -- 3198
			self.scavState = "back" -- 3199
			self.scavT = 0 -- 3200
		end -- 3200
		return -- 3202
	end -- 3202
	local dx = p.x - self.scavX -- 3204
	local dist = math.abs(dx) -- 3205
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3206
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3207
	if not self.scavChase then -- 3208
		if visible then -- 3209
			self.scavSee = self.scavSee + 1 -- 3210
			if self.scavSee >= 24 then -- 3211
				self.scavChase = true -- 3212
				self.scavState = "chase" -- 3213
				self.scavTargetX = p.x -- 3214
				self:flashSet("他看见你了", 1.2) -- 3215
			end -- 3215
		else -- 3215
			self.scavSee = 0 -- 3218
		end -- 3218
		return -- 3220
	end -- 3220
	if hidden then -- 3223
		self.scavSee = 0 -- 3224
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3225
		self.scavT = self.scavT - 1 -- 3226
		if self.scavT <= 0 then -- 3227
			self.scavChase = false -- 3228
			self.scavState = "patrol" -- 3229
			self:flashSet("他失去了目标", 1) -- 3230
		end -- 3230
		return -- 3232
	end -- 3232
	local dir = p.x > self.scavX and 1 or -1 -- 3235
	self.scavX = self.scavX + dir * 96 / 60 -- 3236
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3237
		self:caught() -- 3238
		return -- 3239
	end -- 3239
end -- 3189
function Play.prototype.stepDog(self, dt) -- 3244
	local ____temp_91 -- 3245
	if self.room.story == nil then -- 3245
		____temp_91 = nil -- 3245
	else -- 3245
		____temp_91 = self.room.story.dog -- 3245
	end -- 3245
	local dog = ____temp_91 -- 3245
	if dog == nil then -- 3246
		return -- 3247
	end -- 3247
	local p = self.player -- 3249
	local ox = self.ox -- 3250
	local dist = math.abs(p.x - self.dogX) -- 3251
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3252
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3253
	local sheltered = inBurrowCover or inBrushCover -- 3257
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3258
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3259
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3260
	if self.dogState == "patrol" then -- 3261
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3262
		if self.dogX < dog.x0 then -- 3263
			self.dogX = dog.x0 -- 3264
			self.dogDir = 1 -- 3265
		elseif self.dogX > dog.x1 then -- 3266
			self.dogX = dog.x1 -- 3267
			self.dogDir = -1 -- 3268
		end -- 3268
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3270
		local twigOffsets = {235, 455, 865, 1115} -- 3271
		local nearTwig = false -- 3272
		local ti = 0 -- 3273
		do -- 3273
			ti = 0 -- 3274
			while ti < #twigOffsets do -- 3274
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3275
					nearTwig = true -- 3276
					break -- 3277
				end -- 3277
				ti = ti + 1 -- 3274
			end -- 3274
		end -- 3274
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3280
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3281
			self.dogState = "ear" -- 3282
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3283
			self.dogTargetX = p.x -- 3284
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3285
		end -- 3285
		return -- 3287
	end -- 3287
	if self.dogState == "ear" then -- 3289
		if sheltered then -- 3290
			self.dogState = "sniff" -- 3291
			self.dogT = 45 -- 3292
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3293
			return -- 3294
		end -- 3294
		self.dogT = self.dogT - 1 -- 3296
		if self.dogT <= 0 then -- 3297
			self.dogState = "chase" -- 3298
			self.dogTargetX = p.x -- 3299
			self:flashSet("狗追来了", 1.4) -- 3300
		end -- 3300
		return -- 3302
	end -- 3302
	if self.dogState == "chase" then -- 3304
		local dir = p.x > self.dogX and 1 or -1 -- 3305
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3306
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3307
			self:caught() -- 3308
			self.dogState = "sniff" -- 3309
			self.dogT = 60 -- 3310
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3311
			self.dogState = "sniff" -- 3312
			self.dogT = 60 -- 3313
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3314
		end -- 3314
		return -- 3316
	end -- 3316
	if self.dogState == "sniff" then -- 3318
		self.dogT = self.dogT - 1 -- 3319
		if self.dogT <= 0 then -- 3320
			self.dogState = "back" -- 3321
		end -- 3321
		return -- 3323
	end -- 3323
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3326
	self.dogX = self.dogX + dir * dog.speed * dt -- 3327
	if math.abs(self.dogX - dog.x0) < 2 then -- 3328
		self.dogX = dog.x0 -- 3329
		self.dogState = "patrol" -- 3330
	end -- 3330
end -- 3244
function Play.prototype.stepForestRoute(self) -- 3335
	local p = self.player -- 3336
	local ox = self.ox -- 3337
	if self.forestPath == "" then -- 3338
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3339
			self.forestPath = "burrow" -- 3340
			self.run.story.segments.forest_burrow = true -- 3341
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3342
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3343
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3344
			self.forestPath = "ditch" -- 3345
			self.run.story.segments.forest_ditch = true -- 3346
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3347
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3348
		end -- 3348
	end -- 3348
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3351
		self.waterSeen = true -- 3352
		self.run.story.segments.water_lantern = true -- 3353
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3354
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3355
	end -- 3355
end -- 3335
function Play.prototype.caught(self) -- 3359
	self.caughtT = 1 -- 3360
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3361
end -- 3359
function Play.prototype.recoverFromCaught(self) -- 3365
	local p = self.player -- 3366
	p.x = self.ox + 140 -- 3367
	p.y = 0 -- 3368
	p.vy = 0 -- 3369
	p.vx = 0 -- 3370
	p.onGround = true -- 3371
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3372
		self.scavX = self.room.scavenger.x0 -- 3373
		self.scavState = "patrol" -- 3374
		self.scavSee = 0 -- 3375
		self.scavChase = false -- 3376
		self.scavT = 0 -- 3377
	end -- 3377
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3379
		self.dogX = self.room.story.dog.x0 -- 3380
		self.dogState = "patrol" -- 3381
		self.dogT = 0 -- 3382
	end -- 3382
	self.cam.x = p.x -- 3384
	self.cam.y = p.y + CAM_LOOK_UP -- 3385
	self:flashSet("回到安全点", 1.2) -- 3386
end -- 3365
function Play.prototype.updateGate(self) -- 3390
	if self.room.key ~= "checkpoint" then -- 3391
		self.gateOpen = false -- 3392
		return -- 3393
	end -- 3393
	local function inZone(x) -- 3395
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3395
	end -- 3395
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3396
end -- 3390
function Play.prototype.addItem(self, kind) -- 3402
	local inv = self.run.inventory -- 3403
	if kind == "shield" then -- 3404
		if inv.shield >= TOOL_CAP then -- 3405
			return false -- 3406
		end -- 3406
		inv.shield = inv.shield + 1 -- 3408
		return true -- 3409
	end -- 3409
	if kind == "wedge" then -- 3411
		if inv.wedge >= CONSUMABLE_CAP then -- 3412
			return false -- 3413
		end -- 3413
		inv.wedge = inv.wedge + 1 -- 3415
		return true -- 3416
	end -- 3416
	if kind == "ammo" then -- 3418
		if inv.ammo >= CONSUMABLE_CAP then -- 3419
			return false -- 3420
		end -- 3420
		inv.ammo = inv.ammo + 1 -- 3422
		return true -- 3423
	end -- 3423
	if kind == "scrap" then -- 3425
		inv.scrap = inv.scrap + 1 -- 3427
		return true -- 3428
	end -- 3428
	if kind == "wood" then -- 3430
		inv.wood = inv.wood + 1 -- 3431
		return true -- 3432
	end -- 3432
	if kind == "bell" then -- 3434
		inv.bell = inv.bell + 1 -- 3435
		return true -- 3436
	end -- 3436
	if kind == "pass" then -- 3438
		inv.pass = inv.pass + 1 -- 3439
		return true -- 3440
	end -- 3440
	if kind == "quickbelt" then -- 3442
		inv.quickbelt = inv.quickbelt + 1 -- 3443
		return true -- 3444
	end -- 3444
	return false -- 3446
end -- 3402
function Play.prototype.findBox(self, id) -- 3449
	local i = 0 -- 3450
	do -- 3450
		i = 0 -- 3451
		while i < #self.boxes do -- 3451
			if self.boxes[i + 1].id == id then -- 3452
				return self.boxes[i + 1] -- 3453
			end -- 3453
			i = i + 1 -- 3451
		end -- 3451
	end -- 3451
	return nil -- 3456
end -- 3449
function Play.prototype.findWedgeTarget(self) -- 3460
	local best = nil -- 3461
	local bestD = 0 -- 3462
	local i = 0 -- 3463
	do -- 3463
		i = 0 -- 3464
		while i < #self.boxes do -- 3464
			do -- 3464
				local b = self.boxes[i + 1] -- 3465
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3466
					goto __continue527 -- 3467
				end -- 3467
				if not self:nearBox(b, 26) then -- 3469
					goto __continue527 -- 3470
				end -- 3470
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3472
				if best == nil or d < bestD then -- 3473
					best = b -- 3474
					bestD = d -- 3475
				end -- 3475
			end -- 3475
			::__continue527:: -- 3475
			i = i + 1 -- 3464
		end -- 3464
	end -- 3464
	return best -- 3478
end -- 3460
function Play.prototype.stepCraft(self, input) -- 3486
	local inv = self.run.inventory -- 3487
	local required = math.max( -- 3488
		6, -- 3488
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3488
	) -- 3488
	if self.craftT > 0 then -- 3489
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3490
			self.craftT = 0 -- 3492
			self:flashSet("制作中断", 0.8) -- 3493
			return true -- 3494
		end -- 3494
		self.craftT = self.craftT + 1 -- 3496
		if self.craftT >= required then -- 3497
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3498
				inv.scrap = inv.scrap - 1 -- 3499
				inv.wedge = inv.wedge + 1 -- 3500
				self:flashSet("制得木楔", 1.2) -- 3501
				self:log("制木楔") -- 3502
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3503
			end -- 3503
			self.craftT = 0 -- 3505
		end -- 3505
		return true -- 3507
	end -- 3507
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3509
		self.craftT = 1 -- 3510
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3511
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3512
		return true -- 3513
	end -- 3513
	return false -- 3515
end -- 3486
function Play.prototype.nearBox(self, b, reach) -- 3518
	local p = self.player -- 3519
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3520
end -- 3518
function Play.prototype.findInteract(self) -- 3526
	local p = self.player -- 3527
	local best = nil -- 3528
	local bestD = 1000000000 -- 3529
	local i = 0 -- 3530
	do -- 3530
		i = 0 -- 3531
		while i < #self.boxes do -- 3531
			do -- 3531
				local b = self.boxes[i + 1] -- 3532
				if b.interact == nil or b.broken == true then -- 3533
					goto __continue540 -- 3534
				end -- 3534
				if not self:nearBox(b, b.interact.reach or 27) then -- 3536
					goto __continue540 -- 3537
				end -- 3537
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3539
				if d < bestD then -- 3540
					bestD = d -- 3541
					best = b -- 3542
				end -- 3542
			end -- 3542
			::__continue540:: -- 3542
			i = i + 1 -- 3531
		end -- 3531
	end -- 3531
	return best -- 3545
end -- 3526
function Play.prototype.stepCampaign(self, dt, input) -- 3549
	local wr = self.room -- 3550
	local p = self.player -- 3551
	if self.reloadT > 0 then -- 3552
		self.reloadT = self.reloadT - 1 -- 3553
	end -- 3553
	if self.bracedShield ~= nil then -- 3556
		self.bracedShield.x = p.x + p.facing * 26 -- 3557
		self.bracedShield.y = p.y -- 3558
		local shBox = __TS__ArrayFind( -- 3559
			self.boxes, -- 3559
			function(____, b) return b.id == "braced_shield" end -- 3559
		) -- 3559
		if shBox ~= nil then -- 3560
			shBox.x0 = self.bracedShield.x - 15 -- 3561
			shBox.x1 = self.bracedShield.x + 15 -- 3562
			shBox.y0 = self.bracedShield.y -- 3563
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3564
		end -- 3564
	end -- 3564
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3568
		self.run.route = "drygoods" -- 3570
		self.run.joined = false -- 3571
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3572
		self:log("转布行线") -- 3573
	end -- 3573
	if wr.key == "escort3" then -- 3577
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3578
		if nearBench and input.interact.pressed then -- 3579
			self:openCraftBench() -- 3580
			return -- 3581
		end -- 3581
		local ____temp_94 = self.storyRoute == "soldier" -- 3583
		if ____temp_94 then -- 3583
			local ____opt_92 = self.run.story.talents -- 3583
			____temp_94 = (____opt_92 and ____opt_92.deferred) == true -- 3583
		end -- 3583
		if ____temp_94 and p.x >= wr.minX + 940 then -- 3583
			self:triggerDeferredEscort3Draft() -- 3584
		end -- 3584
	end -- 3584
	local i = 0 -- 3588
	do -- 3588
		i = 0 -- 3589
		while i < #self.pickups do -- 3589
			do -- 3589
				local pk = self.pickups[i + 1] -- 3590
				if self.run.taken[pk.id] == true then -- 3591
					goto __continue554 -- 3592
				end -- 3592
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3594
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3595
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3596
					if not self:addItem(pk.kind) then -- 3597
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3599
						self:log("满包拒绝 " .. pk.kind) -- 3600
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3601
						goto __continue554 -- 3602
					end -- 3602
					self.run.taken[pk.id] = true -- 3604
					self:flashSet("拾取 " .. pk.label, 1) -- 3605
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3606
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3607
				end -- 3607
			end -- 3607
			::__continue554:: -- 3607
			i = i + 1 -- 3589
		end -- 3589
	end -- 3589
	self.calmConsumed = false -- 3611
	local ____temp_100 = self.partner.alive and self.run.joined -- 3612
	if ____temp_100 then -- 3612
		local ____opt_95 = self.room.campaign -- 3613
		local ____temp_99 = (____opt_95 and ____opt_95.chapter) == "S" -- 3613
		if not ____temp_99 then -- 3613
			local ____opt_97 = self.room.campaign -- 3613
			____temp_99 = (____opt_97 and ____opt_97.chapter) == "C" -- 3613
		end -- 3613
		____temp_100 = ____temp_99 -- 3612
	end -- 3612
	if ____temp_100 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3612
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3615
		local hadK1 = self.escort.knock1 -- 3616
		local hadK2 = self.escort.knock2 -- 3617
		self.calmConsumed = self.escort:update( -- 3618
			input, -- 3618
			p.x, -- 3618
			p.facing, -- 3618
			self.partner.x, -- 3618
			dist -- 3618
		) -- 3618
		if not hadK1 and self.escort.knock1 then -- 3619
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3620
		end -- 3620
		if not hadK2 and self.escort.knock2 then -- 3622
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3623
		end -- 3623
		self.partner.crouch = self.escort.crouchPose -- 3625
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3626
	end -- 3626
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3628
		self:campaignInteract() -- 3629
	end -- 3629
	self:stepCampaignCart(dt, input) -- 3631
	self:stepCampaignGoal() -- 3632
	self:campaignCheckpoint() -- 3633
end -- 3549
function Play.prototype.campaignCheckpoint(self) -- 3637
	local i = 0 -- 3638
	do -- 3638
		i = 0 -- 3639
		while i < #self.room.marks do -- 3639
			do -- 3639
				local m = self.room.marks[i + 1] -- 3640
				if m.kind ~= 0 then -- 3641
					goto __continue564 -- 3642
				end -- 3642
				local dx = self.player.x - m.x -- 3644
				local dy = self.player.y - m.y -- 3645
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3646
					self.checkpoint = m.x -- 3647
					self:captureCheckpoint(m.x) -- 3648
					self:flashSet("检查点", 1) -- 3649
				end -- 3649
			end -- 3649
			::__continue564:: -- 3649
			i = i + 1 -- 3639
		end -- 3639
	end -- 3639
end -- 3637
function Play.prototype.campaignInteract(self) -- 3655
	local b = self:findInteract() -- 3656
	if b ~= nil then -- 3657
		self:useInteract(b) -- 3658
		return -- 3659
	end -- 3659
	local inv = self.run.inventory -- 3661
	if inv.wedge > 0 then -- 3662
		local w = self:findWedgeTarget() -- 3663
		if w ~= nil then -- 3664
			local ____opt_101 = w.breakable -- 3665
			local extraHp = (____opt_101 and ____opt_101.wedgeHp or 1) + self:talentRank("salvage") -- 3665
			if w.breakable ~= nil then -- 3666
				local ____w_breakable_103, ____hp_104 = w.breakable, "hp" -- 3667
				____w_breakable_103[____hp_104] = ____w_breakable_103[____hp_104] + extraHp -- 3667
			end -- 3667
			inv.wedge = inv.wedge - 1 -- 3669
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3670
			self:flashSet( -- 3672
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3672
				1.2 -- 3672
			) -- 3672
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3673
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3674
			return -- 3675
		end -- 3675
		if self:isEscortRoom() then -- 3677
			local p = self.player -- 3678
			local wx = math.max( -- 3679
				self.room.minX + 64, -- 3679
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3679
			) -- 3679
			local hp = 1 + self:talentRank("salvage") -- 3680
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3681
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3682
			local ____self_boxes_105 = self.boxes -- 3683
			____self_boxes_105[#____self_boxes_105 + 1] = { -- 3683
				x0 = wx - 12, -- 3684
				x1 = wx + 12, -- 3685
				y0 = p.y, -- 3686
				y1 = p.y + 48, -- 3687
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3688
				label = "立起的木楔掩体", -- 3689
				id = wid, -- 3690
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3691
			} -- 3691
			inv.wedge = inv.wedge - 1 -- 3693
			self:flashSet( -- 3694
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3694
				1.2 -- 3694
			) -- 3694
			self:log("立木楔掩体") -- 3695
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3696
			return -- 3697
		end -- 3697
	end -- 3697
	if inv.ammo > 0 and self.reloadT > 0 then -- 3700
		self.reloadT = 0 -- 3702
		self:closeReloadPuzzle() -- 3703
		inv.ammo = inv.ammo - 1 -- 3704
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3705
		self:log("用备用弹包") -- 3706
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3707
		return -- 3708
	end -- 3708
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3710
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3713
		local p = self.player -- 3714
		local shHp = 1 + self:talentRank("salvage") -- 3715
		self.bracedShield = { -- 3716
			x = p.x + p.facing * 26, -- 3716
			y = p.y, -- 3716
			w = 30, -- 3716
			h = 64, -- 3716
			hp = shHp -- 3716
		} -- 3716
		local ____self_boxes_106 = self.boxes -- 3717
		____self_boxes_106[#____self_boxes_106 + 1] = { -- 3717
			x0 = self.bracedShield.x - 15, -- 3718
			x1 = self.bracedShield.x + 15, -- 3718
			y0 = p.y, -- 3719
			y1 = p.y + 64, -- 3719
			depth = {min = -46, max = 46}, -- 3719
			label = "架起的残盾", -- 3719
			id = "braced_shield", -- 3719
			soft = true -- 3720
		} -- 3720
		inv.shield = inv.shield - 1 -- 3722
		self:flashSet( -- 3723
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3723
			1.2 -- 3723
		) -- 3723
		self:log("架残盾") -- 3724
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3725
		return -- 3726
	end -- 3726
	if inv.pass > 0 and self.run.joined == false then -- 3728
		inv.pass = inv.pass - 1 -- 3729
		self.run.joined = true -- 3730
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3731
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3732
		return -- 3733
	end -- 3733
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3735
end -- 3655
function Play.prototype.useInteract(self, b) -- 3738
	local kind = b.interact == nil and "" or b.interact.kind -- 3739
	local wr = self.room -- 3740
	if kind == "open_board" then -- 3741
		b.broken = true -- 3742
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3743
		for ____, cover in ipairs(self.boxes) do -- 3744
			if cover.id == "s2_board_cover" then -- 3745
				cover.broken = false -- 3746
				cover.hidden = false -- 3747
			end -- 3747
		end -- 3747
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3750
		self.run.joined = true -- 3751
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3752
		self:log("放下窗板") -- 3753
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3754
		return -- 3755
	end -- 3755
	if kind == "lower_curtain" then -- 3757
		for ____, curtain in ipairs(self.boxes) do -- 3758
			if curtain.id == "c2_curtain" then -- 3759
				curtain.broken = false -- 3760
				curtain.hidden = false -- 3761
			end -- 3761
		end -- 3761
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3764
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3765
		self:log("放下木帘") -- 3766
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3767
		return -- 3768
	end -- 3768
	if kind == "raise_latch" then -- 3770
		if wr.key == "c2-granary" and not self.cartDocked then -- 3771
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3772
			return -- 3773
		end -- 3773
		b.broken = true -- 3775
		self.objectiveDone = true -- 3776
		if wr.key == "c1-yard" then -- 3778
			self.run.c1Latch = true -- 3779
			self.run.joined = true -- 3780
			for ____, door in ipairs(self.boxes) do -- 3781
				if door.id == "c1_door" then -- 3782
					door.broken = true -- 3783
				end -- 3783
			end -- 3783
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3786
		else -- 3786
			self.run.c2Latch = true -- 3788
			self.run.joined = true -- 3789
		end -- 3789
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3791
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3792
		self:log("抬闩") -- 3793
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3794
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3795
	end -- 3795
end -- 3738
function Play.prototype.stepCampaignCart(self, dt, input) -- 3800
	local wr = self.room -- 3801
	local c = wr.cart -- 3802
	if c.bodyW <= 0 then -- 3803
		return -- 3804
	end -- 3804
	local p = self.player -- 3806
	local handleX = self.cartAxle + c.handleOffset -- 3807
	if not self.gripping then -- 3808
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3809
			self.gripping = true -- 3811
			self:flashSet("握住车柄 · A/D 推", 1) -- 3812
		end -- 3812
		return -- 3814
	end -- 3814
	if input.interact.pressed then -- 3816
		self.gripping = false -- 3817
		self:flashSet("松手", 0.5) -- 3818
		return -- 3819
	end -- 3819
	if not self.cartDocked then -- 3821
		if input.moveX ~= 0 and not self:stuckCart() then -- 3822
			self.cartAxle = math.max( -- 3823
				c.startX, -- 3823
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3823
			) -- 3823
		end -- 3823
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3827
			self.cartExposed = true -- 3828
			local gun = nil -- 3829
			local gi = 0 -- 3830
			do -- 3830
				gi = 0 -- 3831
				while gi < #self.enemies do -- 3831
					local e = self.enemies[gi + 1] -- 3832
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3833
						gun = e -- 3834
						break -- 3835
					end -- 3835
					gi = gi + 1 -- 3831
				end -- 3831
			end -- 3831
			if gun ~= nil then -- 3838
				self:campaignEnemyFire(gun) -- 3839
			end -- 3839
		end -- 3839
		p.x = self.cartAxle + c.handleOffset -- 3842
		p.y = c.baseY -- 3843
		p.depth = c.depth or 0 -- 3844
		p.vx = 0 -- 3845
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3846
			self.cartAxle = c.endX -- 3847
			self.cartDocked = true -- 3848
			self.gripping = false -- 3849
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3850
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3851
			self:flashSet("车轮入窝", 1.2) -- 3852
			self:log("车轮入窝") -- 3853
		end -- 3853
	end -- 3853
end -- 3800
function Play.prototype.stuckCart(self) -- 3859
	local i = 0 -- 3860
	do -- 3860
		i = 0 -- 3861
		while i < #self.boxes do -- 3861
			do -- 3861
				local b = self.boxes[i + 1] -- 3862
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3863
					goto __continue607 -- 3864
				end -- 3864
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3866
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3867
					return true -- 3868
				end -- 3868
			end -- 3868
			::__continue607:: -- 3868
			i = i + 1 -- 3861
		end -- 3861
	end -- 3861
	return false -- 3871
end -- 3859
function Play.prototype.stepCampaignGoal(self) -- 3875
	local wr = self.room -- 3876
	local c = wr.campaign -- 3877
	if c == nil then -- 3878
		return -- 3879
	end -- 3879
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3881
		self.objectiveDone = true -- 3882
	end -- 3882
	if c.goal == "reach_exit" then -- 3884
		self.objectiveDone = true -- 3885
	end -- 3885
	if not self.objectiveDone then -- 3887
		return -- 3888
	end -- 3888
	local p = self.player -- 3890
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3891
	if p.x < c.exitX or not partnerOk then -- 3892
		return -- 3893
	end -- 3893
	if self.run.story.segments[wr.key] ~= true then -- 3896
		self.run.story.segments[wr.key] = true -- 3897
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3898
	end -- 3898
	if wr.key == "escort5" then -- 3901
		self.escortDone = true -- 3902
		self.run.story.escortDone = true -- 3903
	end -- 3903
	if c.next ~= nil and c.next ~= "" then -- 3905
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3906
		self:flashSet("过关 · " .. c.next, 1.2) -- 3907
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3908
		self:requestRoom("gate", "军粮棚出口") -- 3910
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3911
	elseif not self.run.finished then -- 3912
		self.run.finished = true -- 3913
		self:flashSet( -- 3914
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3914
			2 -- 3914
		) -- 3914
		self:log("C2 灰盒完成") -- 3915
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3916
	end -- 3916
end -- 3875
function Play.prototype.stepCampaignPartner(self, dt) -- 3921
	local a = self.partner -- 3922
	local wr = self.room -- 3923
	local cp = wr.companion -- 3924
	if not a.alive then -- 3925
		return -- 3926
	end -- 3926
	local p = self.player -- 3928
	if self.craftBench.active then -- 3930
		a.vx = 0 -- 3931
		return -- 3932
	end -- 3932
	local wait = false -- 3934
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3935
	local targetDepth = p.depth -- 3936
	if self.run.joined == false then -- 3937
		wait = true -- 3938
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3939
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3940
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3941
		wait = true -- 3942
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3943
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3944
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3945
		wait = true -- 3946
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3947
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3948
	end -- 3948
	if self.partnerStuck > 0.3 then -- 3950
		a.x = a.x + a.facing * 44 -- 3952
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3953
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3954
		self.partnerLaneHold = 1.1 -- 3955
		self.partnerStuck = 0 -- 3956
	end -- 3956
	if self.partnerLaneHold > 0 then -- 3958
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3959
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3960
	end -- 3960
	local dx = targetX - a.x -- 3962
	local stopTol = wait and 18 or 74 -- 3963
	if math.abs(dx) > stopTol then -- 3964
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3965
		local before = a.x -- 3966
		a.vx = dx > 0 and speed or -speed -- 3967
		a.facing = dx > 0 and 1 or -1 -- 3968
		self:slideX(a, a.vx * dt) -- 3969
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3971
			a.vy = CHILD_JUMP -- 3972
			a.onGround = false -- 3973
		end -- 3973
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3975
	else -- 3975
		a.vx = 0 -- 3977
		self.partnerStuck = 0 -- 3978
	end -- 3978
	local dz = targetDepth - a.depth -- 3980
	if math.abs(dz) > 6 then -- 3981
		local step = math.max( -- 3982
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3982
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3982
		) -- 3982
		a.depth = a.depth + step -- 3983
	end -- 3983
	a.depthSpeed = 0 -- 3985
	a.h = CHILD_H -- 3986
	a.crouch = false -- 3987
	self:fallY(a, dt) -- 3988
end -- 3921
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3992
	local p = self.player -- 3993
	local i = 0 -- 3994
	do -- 3994
		i = 0 -- 3995
		while i < #self.enemies do -- 3995
			do -- 3995
				local e = self.enemies[i + 1] -- 3996
				if e.kind == "target" then -- 3997
					if not e.alive then -- 3999
						if e.hitT > 0 then -- 4000
							e.hitT = e.hitT - dt -- 4001
						end -- 4001
						if e.hitT <= 0 then -- 4003
							e.alive = true -- 4004
							e.hitT = 0 -- 4005
						end -- 4005
					end -- 4005
					goto __continue635 -- 4008
				end -- 4008
				if not e.alive then -- 4010
					goto __continue635 -- 4011
				end -- 4011
				if e.kind == "breaker" then -- 4013
					self:stepBreaker(e, dt) -- 4014
					goto __continue635 -- 4015
				end -- 4015
				if e.kind == "shield" then -- 4017
					self:stepShield(e, dt, input) -- 4018
					goto __continue635 -- 4019
				end -- 4019
				local dx = e.x - p.x -- 4022
				if not e.awake then -- 4023
					if math.abs(dx) > 520 then -- 4024
						goto __continue635 -- 4025
					end -- 4025
					e.awake = true -- 4027
					e.fireCd = 48 -- 4028
					goto __continue635 -- 4029
				end -- 4029
				if math.abs(dx) > ENEMY_RANGE then -- 4031
					goto __continue635 -- 4032
				end -- 4032
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4036
					goto __continue635 -- 4037
				end -- 4037
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4039
					goto __continue635 -- 4040
				end -- 4040
				if self:blockedShot(e, p) then -- 4042
					if e.warnT > 0 then -- 4045
						e.warnT = 0 -- 4046
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4047
					end -- 4047
					goto __continue635 -- 4049
				end -- 4049
				if e.warnT > 0 then -- 4051
					e.warnT = e.warnT - 1 -- 4052
					if e.warnT <= 0 then -- 4053
						self:campaignEnemyFire(e) -- 4054
					end -- 4054
				elseif e.fireCd > 0 then -- 4056
					e.fireCd = e.fireCd - 1 -- 4057
					if e.fireCd <= 0 then -- 4058
						e.warnT = WARN_TICKS -- 4059
					end -- 4059
				else -- 4059
					e.fireCd = 40 -- 4062
				end -- 4062
			end -- 4062
			::__continue635:: -- 4062
			i = i + 1 -- 3995
		end -- 3995
	end -- 3995
end -- 3992
function Play.prototype.blockedShot(self, e, p) -- 4068
	local eDepth = e.depth or 0 -- 4069
	local ex = e.x -- 4070
	local ey = e.y + e.h * 0.62 -- 4072
	local px = p.x -- 4073
	local py = p.y + p.h * 0.55 -- 4074
	local dx = px - ex -- 4075
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4076
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4077
	if len < 0.01 then -- 4078
		return false -- 4079
	end -- 4079
	local ray = { -- 4083
		x = ex, -- 4084
		y = ey, -- 4084
		dx = dx / len, -- 4085
		dy = (py - ey) / len, -- 4085
		depth = eDepth, -- 4086
		dDepth = (p.depth - eDepth) / len -- 4086
	} -- 4086
	local best = -1 -- 4088
	local j = 0 -- 4089
	do -- 4089
		j = 0 -- 4090
		while j < #self.boxes do -- 4090
			do -- 4090
				local b = self.boxes[j + 1] -- 4091
				if b.broken == true or b.passable == true or b.hidden == true then -- 4092
					goto __continue658 -- 4093
				end -- 4093
				if b.id == "braced_shield" then -- 4097
					goto __continue658 -- 4098
				end -- 4098
				local t = hitBox(ray, b) -- 4100
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4103
					best = t -- 4104
				end -- 4104
			end -- 4104
			::__continue658:: -- 4104
			j = j + 1 -- 4090
		end -- 4090
	end -- 4090
	return best >= 0 -- 4107
end -- 4068
function Play.prototype.campaignEnemyFire(self, e) -- 4110
	local p = self.player -- 4111
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4112
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4113
		local ____self_bracedShield_107, ____hp_108 = self.bracedShield, "hp" -- 4114
		____self_bracedShield_107[____hp_108] = ____self_bracedShield_107[____hp_108] - 1 -- 4114
		if self.bracedShield.hp <= 0 then -- 4115
			self.boxes = __TS__ArrayFilter( -- 4116
				self.boxes, -- 4116
				function(____, b) return b.id ~= "braced_shield" end -- 4116
			) -- 4116
			self.bracedShield = nil -- 4117
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4118
		else -- 4118
			self:flashSet( -- 4120
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4120
				1 -- 4120
			) -- 4120
		end -- 4120
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4122
		return -- 4123
	end -- 4123
	if self:blockedShot(e, p) then -- 4125
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4126
		return -- 4127
	end -- 4127
	local cover = self:blockedByCover(e, p) -- 4129
	if cover ~= nil and self.coverHug then -- 4130
		self.coveredFlash = 0.5 -- 4131
		self:flashSet("掩体挡下", 0.6) -- 4132
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4133
		return -- 4138
	end -- 4138
	if self.invulnT > 0 then -- 4140
		return -- 4141
	end -- 4141
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4143
	self.craftT = 0 -- 4144
	self.hp = self.hp - 1 -- 4145
	self:emit("actorHit", { -- 4146
		target = "player", -- 4146
		amount = 1, -- 4146
		hp = self.hp, -- 4146
		maxHp = self.maxHp, -- 4146
		enemyX = e.x -- 4146
	}) -- 4146
	self:flashSet( -- 4147
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4147
		0.8 -- 4147
	) -- 4147
	if self.hp <= 0 then -- 4148
		self:campaignFailed() -- 4149
	end -- 4149
end -- 4110
function Play.prototype.stepShield(self, e, dt, input) -- 4154
	local p = self.player -- 4155
	local dx = p.x - e.x -- 4156
	local adx = math.abs(dx) -- 4157
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4160
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4161
	if adx > 44 then -- 4162
		local before = e.x -- 4163
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4164
		local nextX = math.max( -- 4165
			self.room.minX + 16, -- 4165
			math.min(self.room.maxX - 16, e.x + stepX) -- 4165
		) -- 4165
		if not self:enemyBlockedAtX(e, nextX) then -- 4166
			e.x = nextX -- 4167
		end -- 4167
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4169
			e.depth = math.max( -- 4171
				-32, -- 4171
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4171
			) -- 4171
		end -- 4171
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4173
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4176
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4177
		if not rollDodges and self.invulnT <= 0 then -- 4178
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4179
			self.craftT = 0 -- 4180
			self.hp = self.hp - 1 -- 4181
			self:emit("actorHit", { -- 4182
				target = "player", -- 4182
				amount = 1, -- 4182
				hp = self.hp, -- 4182
				maxHp = self.maxHp, -- 4182
				enemyX = e.x -- 4182
			}) -- 4182
			self:flashSet( -- 4183
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4183
				0.8 -- 4183
			) -- 4183
			if self.hp <= 0 then -- 4184
				self:campaignFailed() -- 4185
				return -- 4186
			end -- 4186
		end -- 4186
		e.swingT = 70 -- 4189
	end -- 4189
	if (e.swingT or 0) > 0 then -- 4191
		e.swingT = (e.swingT or 0) - 1 -- 4192
	end -- 4192
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4194
		local dd = p.depth - (e.depth or 0) -- 4195
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4196
	end -- 4196
end -- 4154
function Play.prototype.stepBreaker(self, e, dt) -- 4201
	local p = self.player -- 4202
	if e.awake ~= true then -- 4203
		if math.abs(p.x - e.x) < 560 then -- 4204
			e.awake = true -- 4205
		else -- 4205
			return -- 4207
		end -- 4207
	end -- 4207
	local target = nil -- 4210
	local bestD = 1000000000 -- 4211
	local i = 0 -- 4212
	do -- 4212
		i = 0 -- 4213
		while i < #self.boxes do -- 4213
			do -- 4213
				local b = self.boxes[i + 1] -- 4214
				if b.breakable == nil or b.broken == true then -- 4215
					goto __continue685 -- 4216
				end -- 4216
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4218
				if d < bestD then -- 4219
					bestD = d -- 4220
					target = b -- 4221
				end -- 4221
			end -- 4221
			::__continue685:: -- 4221
			i = i + 1 -- 4213
		end -- 4213
	end -- 4213
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4224
	local dx = tx - e.x -- 4225
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4226
	if math.abs(dx) > reach then -- 4227
		local before = e.x -- 4228
		local nextX = math.max( -- 4229
			self.room.minX + 16, -- 4229
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4229
		) -- 4229
		if not self:enemyBlockedAtX(e, nextX) then -- 4230
			e.x = nextX -- 4231
		end -- 4231
		if math.abs(e.x - before) < 0.3 then -- 4233
			e.depth = math.max( -- 4234
				-32, -- 4234
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4234
			) -- 4234
		end -- 4234
	elseif (e.swingT or 0) <= 0 then -- 4236
		e.swingT = 64 -- 4237
		if target ~= nil then -- 4238
			self:damageProp(target, 2) -- 4239
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4240
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4242
			self.craftT = 0 -- 4243
			self.hp = self.hp - 1 -- 4244
			self:emit("actorHit", { -- 4245
				target = "player", -- 4245
				amount = 1, -- 4245
				hp = self.hp, -- 4245
				maxHp = self.maxHp, -- 4245
				enemyX = e.x -- 4245
			}) -- 4245
			self:flashSet("破障手近身", 0.8) -- 4246
			if self.hp <= 0 then -- 4247
				self:campaignFailed() -- 4248
				return -- 4249
			end -- 4249
		end -- 4249
	end -- 4249
	if (e.swingT or 0) > 0 then -- 4253
		e.swingT = (e.swingT or 0) - 1 -- 4254
	end -- 4254
end -- 4201
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4259
	local half = e.w * 0.5 -- 4260
	local d = e.depth or 0 -- 4261
	local i = 0 -- 4262
	do -- 4262
		i = 0 -- 4263
		while i < #self.boxes do -- 4263
			do -- 4263
				local b = self.boxes[i + 1] -- 4264
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4265
					goto __continue698 -- 4266
				end -- 4266
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4268
					goto __continue698 -- 4269
				end -- 4269
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4271
					return true -- 4272
				end -- 4272
			end -- 4272
			::__continue698:: -- 4272
			i = i + 1 -- 4263
		end -- 4263
	end -- 4263
	return false -- 4275
end -- 4259
function Play.prototype.campaignFailed(self) -- 4278
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4282
		if self.useEscortDeathSummary and not self.escortFailed then -- 4283
			local story = self.run.story -- 4284
			local st = story.talents -- 4285
			local ranksCopy = { -- 4286
				vitality = st and st.ranks.vitality or 0, -- 4287
				guard = st and st.ranks.guard or 0, -- 4288
				stride = st and st.ranks.stride or 0, -- 4289
				focus = st and st.ranks.focus or 0, -- 4290
				push_force = st and st.ranks.push_force or 0, -- 4291
				echo_wide = st and st.ranks.echo_wide or 0, -- 4292
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4293
				salvage = st and st.ranks.salvage or 0 -- 4294
			} -- 4294
			local cleared = 0 -- 4296
			local segKeys = { -- 4297
				"escort1", -- 4297
				"escort2", -- 4297
				"escort3", -- 4297
				"escort4", -- 4297
				"escort5" -- 4297
			} -- 4297
			local si = 0 -- 4298
			do -- 4298
				si = 0 -- 4299
				while si < #segKeys do -- 4299
					if story.segments[segKeys[si + 1]] == true then -- 4300
						cleared = cleared + 1 -- 4301
					end -- 4301
					si = si + 1 -- 4299
				end -- 4299
			end -- 4299
			self.escortFailed = true -- 4304
			self.escortFailedTicks = 0 -- 4305
			self.talentModalActive = false -- 4306
			self.craftBench.active = false -- 4307
			self.reloadT = 0 -- 4308
			self:closeReloadPuzzle() -- 4309
			self.gripping = false -- 4310
			self.escortSummary = { -- 4311
				roomKey = self.room.key, -- 4312
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4313
				seed = st ~= nil and st.randomState or self.run.seed, -- 4314
				equippedWeapon = self.equippedWeapon, -- 4315
				segmentsCleared = cleared, -- 4316
				ranks = ranksCopy -- 4317
			} -- 4317
			self:flashSet("折返山道 · 重整再赴", 2) -- 4319
			self:log("男主线折返 · 展示小结") -- 4320
			self:emit("campaignFailed", { -- 4321
				room = self.room.key, -- 4322
				hp = 0, -- 4322
				maxHp = self.maxHp, -- 4322
				reset = true, -- 4323
				to = "escort1", -- 4323
				route = self.storyRoute, -- 4323
				summary = true -- 4323
			}) -- 4323
			return -- 4325
		end -- 4325
		self:restartEscortFromDeath() -- 4327
		return -- 4328
	end -- 4328
	local p = self.player -- 4330
	self.hp = self.maxHp -- 4331
	self.invulnT = INVULN_RESPAWN_TICKS -- 4332
	self.reloadT = 0 -- 4333
	self:closeReloadPuzzle() -- 4334
	self.gripping = false -- 4335
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4336
	self:log("被击倒") -- 4337
	p.x = self.room.minX + 90 -- 4338
	p.y = 0 -- 4339
	p.depth = 0 -- 4340
	p.vx = 0 -- 4341
	p.vy = 0 -- 4342
	p.onGround = true -- 4343
	p.rollT = 0 -- 4344
	self.partner.x = p.x - 50 -- 4345
	self.partner.y = 0 -- 4346
	self.partner.depth = 0 -- 4347
	self.cam.x = p.x -- 4348
	local i = 0 -- 4349
	do -- 4349
		i = 0 -- 4350
		while i < #self.enemies do -- 4350
			do -- 4350
				local e = self.enemies[i + 1] -- 4351
				if not e.alive then -- 4352
					goto __continue709 -- 4353
				end -- 4353
				e.x = e.homeX == nil and e.x or e.homeX -- 4355
				e.warnT = 0 -- 4356
				e.fireCd = 40 -- 4357
				e.swingT = 0 -- 4358
				e.awake = false -- 4359
			end -- 4359
			::__continue709:: -- 4359
			i = i + 1 -- 4350
		end -- 4350
	end -- 4350
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4361
end -- 4278
function Play.prototype.isEscortRoom(self) -- 4365
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4366
end -- 4365
function Play.prototype.confirmEscortRestart(self) -- 4370
	if not self.escortFailed then -- 4371
		return false -- 4372
	end -- 4372
	self:restartEscortFromDeath() -- 4374
	return true -- 4375
end -- 4370
function Play.prototype.restartEscortRun(self) -- 4379
	self:restartEscortFromDeath() -- 4380
end -- 4379
function Play.prototype.restartEscortFromDeath(self) -- 4388
	local story = self.run.story -- 4389
	local inv = self.run.inventory -- 4390
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4391
	local nextAttempt = prevAttempt + 1 -- 4392
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4393
	if vitBonus > 0 then -- 4394
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4395
		story.maxHp = self.maxHp -- 4396
	end -- 4396
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4398
	self.hp = self.maxHp -- 4399
	story.hp = self.maxHp -- 4400
	story.cp = nil -- 4401
	self.checkpointSnap = nil -- 4402
	story.carry = false -- 4403
	self.carryOn = false -- 4404
	story.craftedWeapon = "" -- 4405
	self.equippedWeapon = "standard_gun" -- 4406
	story.equippedWeapon = "standard_gun" -- 4407
	story.escortDone = false -- 4408
	self.escortDone = false -- 4409
	story.segments = {} -- 4410
	inv.wood = 0 -- 4411
	inv.bell = 0 -- 4412
	inv.scrap = 0 -- 4413
	inv.wedge = 0 -- 4414
	inv.ammo = 0 -- 4415
	inv.quickbelt = 0 -- 4416
	inv.shield = 0 -- 4417
	inv.pass = 0 -- 4418
	local taken = self.run.taken -- 4419
	local keys = __TS__ObjectKeys(taken) -- 4420
	local i = 0 -- 4421
	do -- 4421
		i = 0 -- 4422
		while i < #keys do -- 4422
			local k = keys[i + 1] -- 4423
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4424
				__TS__Delete(taken, k) -- 4425
			end -- 4425
			i = i + 1 -- 4422
		end -- 4422
	end -- 4422
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4428
	do -- 4428
		i = 0 -- 4429
		while i < #propKeys do -- 4429
			local pk = propKeys[i + 1] -- 4430
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4431
				__TS__Delete(self.run.props, pk) -- 4433
			end -- 4433
			i = i + 1 -- 4429
		end -- 4429
	end -- 4429
	self.bracedShield = nil -- 4436
	self.escortFailed = false -- 4437
	self.escortFailedTicks = 0 -- 4438
	self.escortSummary = nil -- 4439
	self.talentModalActive = false -- 4440
	self.run.joined = true -- 4441
	self.reloadT = 0 -- 4442
	self:closeReloadPuzzle() -- 4443
	self.gripping = false -- 4444
	self.sessionDirty = true -- 4445
	self:flashSet( -- 4446
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4446
		2 -- 4446
	) -- 4446
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4447
	if not self.useEscortDeathSummary then -- 4448
		self:emit("campaignFailed", { -- 4449
			room = self.room.key, -- 4450
			hp = 0, -- 4450
			maxHp = self.maxHp, -- 4450
			reset = true, -- 4451
			to = "escort1", -- 4451
			route = self.storyRoute, -- 4451
			attempt = nextAttempt -- 4451
		}) -- 4451
	end -- 4451
	self:requestRoom("escort1", "男主线失败重开") -- 4454
end -- 4388
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4458
	local i = 0 -- 4459
	do -- 4459
		i = 0 -- 4460
		while i < #self.enemies do -- 4460
			do -- 4460
				if i == skipIndex then -- 4461
					goto __continue726 -- 4462
				end -- 4462
				local e = self.enemies[i + 1] -- 4464
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4465
					goto __continue726 -- 4466
				end -- 4466
				e.awake = true -- 4468
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4469
				e.warnT = 0 -- 4470
			end -- 4470
			::__continue726:: -- 4470
			i = i + 1 -- 4460
		end -- 4460
	end -- 4460
end -- 4458
function Play.prototype.stepEnemies(self, dt, input) -- 4474
	local i = 0 -- 4475
	do -- 4475
		i = 0 -- 4476
		while i < #self.enemies do -- 4476
			local e = self.enemies[i + 1] -- 4477
			if e.hitT > 0 then -- 4478
				e.hitT = e.hitT - dt -- 4479
			end -- 4479
			i = i + 1 -- 4476
		end -- 4476
	end -- 4476
	if self.coveredFlash > 0 then -- 4482
		self.coveredFlash = self.coveredFlash - dt -- 4483
	end -- 4483
	if self.isCampaign then -- 4485
		self:stepCampaignEnemies(dt, input) -- 4486
		return -- 4487
	end -- 4487
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4490
		return -- 4491
	end -- 4491
	do -- 4491
		i = 0 -- 4493
		while i < #self.enemies do -- 4493
			do -- 4493
				local e = self.enemies[i + 1] -- 4494
				if not e.alive then -- 4495
					goto __continue737 -- 4496
				end -- 4496
				if e.warnT > 0 then -- 4498
					e.warnT = e.warnT - 1 -- 4499
					if e.warnT <= 0 then -- 4500
						self:enemyFire(e, input) -- 4501
					end -- 4501
					goto __continue737 -- 4503
				end -- 4503
				if e.fireCd > 0 then -- 4505
					e.fireCd = e.fireCd - 1 -- 4506
					if e.fireCd <= 0 then -- 4507
						e.warnT = WARN_TICKS -- 4508
					end -- 4508
				else -- 4508
					e.warnT = WARN_TICKS -- 4512
				end -- 4512
			end -- 4512
			::__continue737:: -- 4512
			i = i + 1 -- 4493
		end -- 4493
	end -- 4493
end -- 4474
function Play.prototype.enemyFire(self, e, input) -- 4518
	local p = self.player -- 4519
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4520
		self:flashSet("枪声响在远处", 0.4) -- 4521
		e.fireCd = FIRE_COOLDOWN -- 4522
		return -- 4523
	end -- 4523
	if self:blockedShot(e, p) then -- 4525
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4526
		e.fireCd = FIRE_COOLDOWN -- 4527
		return -- 4528
	end -- 4528
	local cover = self:blockedByCover(e, p) -- 4531
	local hugging = cover ~= nil -- 4532
	self.coverBlocking = hugging -- 4533
	local covered = hugging and input.cover.held -- 4534
	if covered then -- 4535
		self.coveredFlash = 0.5 -- 4536
		self:flashSet("掩体挡下", 0.5) -- 4537
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4538
		e.fireCd = FIRE_COOLDOWN -- 4543
		return -- 4544
	end -- 4544
	if self.invulnT > 0 then -- 4546
		e.fireCd = FIRE_COOLDOWN -- 4547
		return -- 4548
	end -- 4548
	self.invulnT = INVULN_HIT_TICKS -- 4550
	self.hp = self.hp - 1 -- 4551
	self:emit("actorHit", { -- 4552
		target = "player", -- 4552
		amount = 1, -- 4552
		hp = self.hp, -- 4552
		maxHp = self.maxHp, -- 4552
		enemyX = e.x -- 4552
	}) -- 4552
	self:flashSet( -- 4553
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4553
		0.7 -- 4553
	) -- 4553
	e.fireCd = FIRE_COOLDOWN -- 4554
	if self.hp <= 0 then -- 4555
		self:gateFailed() -- 4556
	end -- 4556
end -- 4518
function Play.prototype.blockedByCover(self, enemy, p) -- 4561
	local b = self:coverAt(p) -- 4562
	if b == nil then -- 4563
		return nil -- 4564
	end -- 4564
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4566
end -- 4561
function Play.prototype.gateFailed(self) -- 4570
	local ____temp_125 -- 4571
	if self.room.story == nil then -- 4571
		____temp_125 = nil -- 4571
	else -- 4571
		____temp_125 = self.room.story.gate -- 4571
	end -- 4571
	local g = ____temp_125 -- 4571
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4572
	self.hp = self.maxHp -- 4573
	self.gateTick = 0 -- 4574
	self.gateSpawned = 0 -- 4575
	self.enemies = {} -- 4576
	self.gateFailCount = self.gateFailCount + 1 -- 4577
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4579
	self.player.y = 0 -- 4580
	self.player.vy = 0 -- 4581
	self.player.depth = 0 -- 4582
	self.player.depthSpeed = 0 -- 4583
	self.player.onGround = true -- 4584
	self.player.crouch = false -- 4585
	self.player.h = SOLDIER_H -- 4586
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4587
	self.partner.y = 0 -- 4588
	self.partner.vy = 0 -- 4589
	self.partner.depth = 0 -- 4590
	self.partner.depthSpeed = 0 -- 4591
	self.partner.onGround = true -- 4592
	self.cam.x = self.player.x -- 4593
	self.phase = "gate-idle" -- 4594
	self.phaseTick = 0 -- 4595
	self.coverHug = false -- 4596
	self.coverBlocking = false -- 4597
	self.coverEntity = "" -- 4598
	self.gateNeedConfirm = true -- 4599
	self.gateRestartArmed = false -- 4600
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4601
end -- 4570
function Play.prototype.stepRedCart(self, input) -- 4605
	if self.redCartMemoryT > 0 then -- 4606
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4607
	end -- 4607
	if self.room.key ~= "outside" or self.redCartPulled then -- 4609
		return -- 4610
	end -- 4610
	local box = __TS__ArrayFind( -- 4612
		self.boxes, -- 4612
		function(____, b) return b.id == "outside_red_cart" end -- 4612
	) -- 4612
	if box == nil then -- 4613
		self.redCartPulled = true -- 4614
		return -- 4615
	end -- 4615
	local cx = (box.x0 + box.x1) * 0.5 -- 4617
	local p = self.player -- 4618
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4619
		return -- 4620
	end -- 4620
	if not input.interact.pressed then -- 4622
		return -- 4623
	end -- 4623
	box.x0 = 430 -- 4625
	box.x1 = 474 -- 4626
	self.cartAxle = self.room.cart.endX -- 4628
	self.cartDocked = true -- 4629
	self.redCartPulled = true -- 4630
	self.redCartMemoryT = 30 -- 4631
	if self.run.story ~= nil then -- 4632
		self.run.story.segments.outside_cart = true -- 4633
		self.run.story.segments.outside_memory = true -- 4634
	end -- 4634
	self.sessionDirty = true -- 4636
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4637
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4638
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4639
end -- 4605
function Play.prototype.stepInteract(self, dt, input) -- 4642
	local p = self.player -- 4643
	self:stepRedCart(input) -- 4644
	local calmUsed = self.calmConsumed -- 4645
	self.calmConsumed = false -- 4646
	local calming = self.escort.state == "calming" -- 4648
	self.focusCart = false -- 4649
	if self.room.key == "outside" then -- 4650
		local c = self.room.cart -- 4651
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4652
		local dy = p.y - c.baseY -- 4653
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4654
	end -- 4654
	if not calmUsed and not calming then -- 4657
		self:stepCart(dt, input) -- 4658
	end -- 4658
	if calmUsed then -- 4662
		self:flashSet("安抚 · 敲两下", 0.8) -- 4663
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4664
		if self.knockT > 0 then -- 4666
			self.knocks = self.knocks + 1 -- 4667
		else -- 4667
			self.knocks = 1 -- 4669
		end -- 4669
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4671
		self.knockT = 1.2 -- 4672
		if self.knocks >= 2 then -- 4673
			self:flashSet("敲两下", 0.8) -- 4674
			self.knocks = 0 -- 4675
		else -- 4675
			self:flashSet("敲一下", 0.5) -- 4677
		end -- 4677
	elseif self.knockT > 0 then -- 4679
		self.knockT = self.knockT - dt -- 4680
		if self.knockT <= 0 then -- 4681
			self.knocks = 0 -- 4682
		end -- 4682
	end -- 4682
	local i = 0 -- 4687
	do -- 4687
		i = 0 -- 4688
		while i < #self.room.marks do -- 4688
			do -- 4688
				local m = self.room.marks[i + 1] -- 4689
				if m.kind ~= 0 then -- 4690
					goto __continue773 -- 4691
				end -- 4691
				local subjects = {self.partner, self.player} -- 4693
				local k = 0 -- 4694
				do -- 4694
					k = 0 -- 4695
					while k < #subjects do -- 4695
						do -- 4695
							local s = subjects[k + 1] -- 4696
							if not s.alive then -- 4697
								goto __continue776 -- 4698
							end -- 4698
							local dx = s.x - m.x -- 4700
							local dy = s.y - m.y -- 4701
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4702
								self.checkpoint = m.x -- 4703
								self.checkpointCartAxle = self.cartAxle -- 4704
								if self.isCampaign then -- 4706
									self:captureCheckpoint(m.x) -- 4707
								end -- 4707
								if self.cartDocked then -- 4709
									self:flashSet("检查点 · 车已落窝", 1) -- 4710
								else -- 4710
									self:flashSet("检查点 · 车还没到位", 1) -- 4712
								end -- 4712
							end -- 4712
						end -- 4712
						::__continue776:: -- 4712
						k = k + 1 -- 4695
					end -- 4695
				end -- 4695
			end -- 4695
			::__continue773:: -- 4695
			i = i + 1 -- 4688
		end -- 4688
	end -- 4688
	self:checkCarryGate() -- 4718
end -- 4642
function Play.prototype.stepVillage(self, dt, input) -- 4722
	if self.room.key ~= "village" then -- 4723
		return -- 4724
	end -- 4724
	local p = self.player -- 4726
	local bottle = self.room.bottle -- 4727
	local scav = self.room.scavenger -- 4728
	if not self.hasBottle and bottle ~= nil then -- 4731
		local dx = p.x - bottle.x -- 4732
		local dy = p.y + p.h * 0.5 - bottle.y -- 4733
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4734
			self.hasBottle = true -- 4735
			self:flashSet("拾起瓶子", 0.8) -- 4736
		end -- 4736
	end -- 4736
	if self.hasBottle then -- 4741
		if input.bottleCanceled then -- 4742
			self.aimHold = 0 -- 4743
			self.bottleAimX = -1 -- 4744
		elseif input.aim.held then -- 4745
			self.aimHold = self.aimHold + dt -- 4746
			if self.aimHold > 1.2 then -- 4747
				self.aimHold = 1.2 -- 4748
			end -- 4748
			local cached = self:bottleEnd() -- 4751
			self.bottleAimX = cached.x -- 4752
			self.bottleAimY = cached.y -- 4753
		elseif input.aim.released then -- 4754
			if self.aimHold < 0.12 then -- 4755
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4757
				self.aimHold = 0 -- 4758
			else -- 4758
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4760
				self:throwBottle(____end.x, ____end.y) -- 4761
				self.aimHold = 0 -- 4762
			end -- 4762
		end -- 4762
	else -- 4762
		self.aimHold = 0 -- 4766
		self.bottleAimX = -1 -- 4767
	end -- 4767
	local fly = self.bottleFly -- 4772
	if fly ~= nil then -- 4773
		fly.t = fly.t + dt -- 4774
		fly.x = fly.x0 + fly.vx * fly.t -- 4775
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4776
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4777
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4778
			self:landBottle(fly) -- 4779
		end -- 4779
	end -- 4779
	if self.bottleLandT > 0 then -- 4782
		self.bottleLandT = self.bottleLandT - dt -- 4783
	end -- 4783
	if scav ~= nil then -- 4786
		self:stepScav(dt, scav) -- 4787
	end -- 4787
	local line = self.room.passLine -- 4790
	if line ~= nil and not self.passed and p.x >= line then -- 4791
		self.passed = true -- 4792
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4793
	end -- 4793
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4796
	if underTable then -- 4797
		self.footHintT = self.footHintT - 1 -- 4798
		if self.footHintT <= 0 then -- 4799
			self.footHintT = 90 -- 4800
			local scavX = self.scavX -- 4801
			local near = math.abs(scavX - p.x) < 120 -- 4802
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4803
			local heard = self.scavState == "chase" or near and not walkingAway -- 4804
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4805
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4806
		end -- 4806
	else -- 4806
		self.footHintT = 0 -- 4809
	end -- 4809
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4812
		self.ditchHinted = true -- 4813
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4814
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4815
	end -- 4815
	if self.passed and p.x >= self.ox + 640 then -- 4818
		self:requestRoom("forest", "过第一院出院") -- 4819
		self:flashSet("钻出暗渠 · 北塔森林", 1.4) -- 4820
	end -- 4820
end -- 4722
function Play.prototype.bottleEnd(self) -- 4825
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4826
	local clampedX = math.max( -- 4829
		self.room.minX + 12, -- 4829
		math.min(self.room.maxX - 12, aim.x) -- 4829
	) -- 4829
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4830
	return {x = clampedX, y = g} -- 4831
end -- 4825
function Play.prototype.throwBottle(self, tx, ty) -- 4835
	local p = self.player -- 4836
	local dir = tx >= p.x and 1 or -1 -- 4838
	p.facing = dir -- 4839
	local x0 = p.x + dir * 10 -- 4840
	local y0 = p.y + p.h * 0.7 -- 4841
	self.bottleTargetX = tx -- 4842
	self.bottleTargetY = ty -- 4843
	self.bottleSurfaceY = ty -- 4844
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4845
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4846
	self.bottleFly = { -- 4847
		x = x0, -- 4847
		y = y0, -- 4847
		x0 = x0, -- 4847
		y0 = y0, -- 4847
		vx = vx, -- 4847
		vy = vy, -- 4847
		t = 0 -- 4847
	} -- 4847
	self.hasBottle = false -- 4848
	self:flashSet("投出", 0.4) -- 4849
	self:emit( -- 4850
		"bottleThrown", -- 4850
		{ -- 4850
			fromX = x0, -- 4851
			fromY = y0, -- 4852
			targetX = tx, -- 4853
			targetY = ty, -- 4854
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4855
		} -- 4855
	) -- 4855
end -- 4835
function Play.prototype.bottleSurfaceAt(self, x) -- 4860
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4861
		return "soft" -- 4862
	end -- 4862
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4864
		return "iron" -- 4865
	end -- 4865
	return "brick" -- 4867
end -- 4860
function Play.prototype.landBottle(self, fly) -- 4871
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4872
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4873
	local s = self.room.scavenger -- 4874
	local surface = self:bottleSurfaceAt(x) -- 4875
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4876
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4877
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4878
	self.bottleFly = nil -- 4879
	self.bottleTargetX = -1 -- 4880
	self.bottleTargetY = 0 -- 4881
	self.bottleSurfaceY = -1 -- 4882
	self.bottleLandX = x -- 4883
	self.bottleLandY = y -- 4884
	self.bottleLandT = 0.9 -- 4885
	self:emit("bottleLanded", { -- 4886
		x = x, -- 4887
		y = y, -- 4888
		surface = surface, -- 4889
		heard = heard, -- 4890
		resonance = surface == "iron", -- 4891
		stallTicks = heard and stallTicks or 0, -- 4892
		scavState = self.scavState -- 4893
	}) -- 4893
	self:hearBottle(x, surface) -- 4895
end -- 4871
function Play.prototype.hearBottle(self, x, surface) -- 4899
	if surface == nil then -- 4899
		surface = "brick" -- 4899
	end -- 4899
	local s = self.room.scavenger -- 4900
	if s == nil then -- 4901
		return -- 4902
	end -- 4902
	if surface == "soft" then -- 4904
		self:flashSet("落在软土 · 没出声", 0.8) -- 4905
		return -- 4906
	end -- 4906
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4908
	if math.abs(x - self.scavX) > effRange then -- 4909
		self:flashSet("落地 · 他没听见", 0.6) -- 4910
		return -- 4911
	end -- 4911
	self.scavState = "turn" -- 4913
	self.scavT = s.hearTicks -- 4914
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4915
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4916
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4917
end -- 4899
function Play.prototype.stepScav(self, dt, s) -- 4921
	if self.scavState == "chase" then -- 4923
		return -- 4924
	end -- 4924
	if self.scavState == "turn" then -- 4926
		self.scavT = self.scavT - 1 -- 4927
		if self.scavT <= 0 then -- 4928
			self.scavState = "walk" -- 4929
		end -- 4929
		return -- 4931
	end -- 4931
	if self.scavState == "walk" then -- 4933
		local d = self.scavTargetX - self.scavX -- 4934
		if math.abs(d) < 4 then -- 4935
			self.scavState = "stall" -- 4936
			self.scavT = s.stallTicks + self.scavStallBonus -- 4937
			self.scavStallBonus = 0 -- 4938
			return -- 4939
		end -- 4939
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4941
		return -- 4942
	end -- 4942
	if self.scavState == "stall" then -- 4944
		self.scavT = self.scavT - 1 -- 4945
		if self.scavT <= 0 then -- 4946
			self.scavState = "back" -- 4947
		end -- 4947
		return -- 4949
	end -- 4949
	if self.scavState == "back" then -- 4951
		local home = math.max( -- 4952
			s.x0, -- 4952
			math.min(s.x1, self.scavX) -- 4952
		) -- 4952
		if math.abs(home - self.scavX) < 2 then -- 4953
			self.scavState = "patrol" -- 4954
			return -- 4955
		end -- 4955
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4957
		return -- 4958
	end -- 4958
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4960
	if self.scavX >= s.x1 then -- 4961
		self.scavX = s.x1 -- 4962
		self.scavDir = -1 -- 4963
	elseif self.scavX <= s.x0 then -- 4964
		self.scavX = s.x0 -- 4965
		self.scavDir = 1 -- 4966
	end -- 4966
end -- 4921
function Play.prototype.stepCart(self, dt, input) -- 4974
	local p = self.player -- 4975
	local c = self.room.cart -- 4976
	if self.gripping then -- 4978
		if not input.interact.held then -- 4979
			self.gripping = false -- 4980
			self:flashSet("松开车把", 0.4) -- 4981
			return -- 4982
		end -- 4982
	else -- 4982
		if not input.interact.pressed then -- 4985
			return -- 4986
		end -- 4986
		if not self:cartHandleInReach(p) then -- 4988
			return -- 4989
		end -- 4989
		local track = c.depth or 0 -- 4991
		if self:limitDepth(p, track) ~= track then -- 4992
			return -- 4993
		end -- 4993
		p.depth = track -- 4995
		p.depthSpeed = 0 -- 4996
		self.gripping = true -- 4997
		self:flashSet("握住车把", 0.4) -- 4998
		return -- 4999
	end -- 4999
	if self.cartDocked then -- 5002
		return -- 5003
	end -- 5003
	local dir = input.moveX -- 5005
	if dir == 0 then -- 5006
		return -- 5007
	end -- 5007
	local lo = math.min(c.startX, c.endX) -- 5009
	local hi = math.max(c.startX, c.endX) -- 5010
	local next = self.cartAxle + dir * CART_SPEED * dt -- 5011
	if next < lo then -- 5012
		next = lo -- 5013
	end -- 5013
	if next > hi then -- 5015
		next = hi -- 5016
	end -- 5016
	local delta = next - self.cartAxle -- 5018
	if delta == 0 then -- 5019
		return -- 5020
	end -- 5020
	self.cartAxle = next -- 5022
	p.x = p.x + delta -- 5023
	p.facing = dir > 0 and 1 or -1 -- 5024
	self:slideX(p, 0) -- 5025
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5026
		self.gripping = false -- 5027
		self:flashSet("跟不上了，脱手", 0.6) -- 5028
		return -- 5029
	end -- 5029
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5031
		self.cartDocked = true -- 5032
		self.gripping = false -- 5033
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5034
		self:flashSet("车轮落窝", 1.2) -- 5035
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5036
		self:flashSet("车轮回到起点", 0.5) -- 5037
	end -- 5037
end -- 4974
function Play.prototype.requestRoom(self, key, reason) -- 5045
	if self.wantRoom ~= "" then -- 5048
		return -- 5049
	end -- 5049
	self.wantRoom = key -- 5051
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5052
end -- 5045
function Play.prototype.checkCarryGate(self) -- 5059
	if self.room.key == "checkpoint" then -- 5060
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5061
			self.carryCartAxle = self.cartAxle -- 5062
			self.carryCartDocked = self.cartDocked -- 5063
			self:requestRoom("gate", "检查站出口") -- 5064
			self:flashSet("出检查站 · 城门", 1.2) -- 5065
		end -- 5065
		return -- 5067
	end -- 5067
	if self.room.key == "outside" then -- 5069
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5072
			self.carryCartAxle = self.cartAxle -- 5073
			self.carryCartDocked = self.cartDocked -- 5074
			self:requestRoom("village", "墙根走完") -- 5075
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5076
		end -- 5076
	end -- 5076
end -- 5059
function Play.prototype.aimAt(self, wx, wy) -- 5083
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5084
	self.aimX = s.x -- 5085
	self.aimY = s.y -- 5086
end -- 5083
function Play.prototype.shoot(self, a) -- 5089
	if self.isCampaign and self.reloadT > 0 then -- 5090
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5091
		return -- 5092
	end -- 5092
	local ox = a.x + a.facing * 8 -- 5094
	local muzzleY = a.y + a.h * 0.72 -- 5095
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5096
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5098
	local dx = aim.x - ox -- 5101
	local dy = aim.y - oy -- 5102
	local len = math.sqrt(dx * dx + dy * dy) -- 5103
	if len < 0.001 then -- 5104
		dx = a.facing -- 5105
		dy = 0 -- 5106
	else -- 5106
		dx = dx / len -- 5108
		dy = dy / len -- 5109
	end -- 5109
	if dx ~= 0 then -- 5111
		a.facing = dx > 0 and 1 or -1 -- 5112
	end -- 5112
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5115
	local hitEnemy = self:raycastEnemies(ray) -- 5116
	local tEnemy = hitEnemy.t -- 5117
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5118
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5119
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5120
	local tWall = solid.t -- 5121
	local rawEffect = self:consumeReloadEffect() -- 5123
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5124
	local reloadEffect = rawEffect -- 5125
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5127
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5128
	self.trace = { -- 5130
		x0 = ox, -- 5130
		y0 = oy, -- 5130
		x1 = ox + dx * t, -- 5130
		y1 = oy + dy * t, -- 5130
		hit = hit -- 5130
	} -- 5130
	self.traceT = 0.12 -- 5131
	self:applyFireDanger(ox) -- 5132
	local killed = false -- 5133
	if hit then -- 5134
		local i = hitEnemy.index -- 5135
		local e = self.enemies[i + 1] -- 5136
		local impactY = oy + dy * tEnemy -- 5137
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5138
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5139
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5140
			local pushRank = self:talentRank("push_force") -- 5141
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5142
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5143
			e.hitT = 0.3 -- 5144
			if reloadEffect == "push" then -- 5145
				local kb = 46 + 24 * pushRank -- 5146
				e.x = math.max( -- 5147
					self.room.minX + 20, -- 5147
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5147
				) -- 5147
				if pushRank > 0 then -- 5148
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5149
				end -- 5149
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5151
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5152
			else -- 5152
				self:flashSet( -- 5154
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5154
					0.8 -- 5154
				) -- 5154
			end -- 5154
			self:emit("shotResolved", { -- 5156
				hit = true, -- 5157
				enemyIndex = i, -- 5157
				enemyX = e.x, -- 5157
				aimX = aim.x, -- 5157
				aimY = aim.y, -- 5157
				impactX = ox + dx * t, -- 5158
				impactY = oy + dy * t, -- 5158
				shield = true -- 5158
			}) -- 5158
			self:beginReload() -- 5160
			return -- 5161
		end -- 5161
		e.alive = false -- 5163
		e.hitT = 0.4 -- 5164
		killed = true -- 5165
		self:flashSet("命中", 0.6) -- 5166
		self:dropFor(e) -- 5167
		local lpRank = self:talentRank("lantern_pierce") -- 5168
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5169
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5170
			self:blindNearby(e, blindRadius, i) -- 5171
		end -- 5171
		if reloadEffect == "push" then -- 5173
			local pushRank = self:talentRank("push_force") -- 5174
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5175
			if pushRank > 0 then -- 5176
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5177
			end -- 5177
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5179
		elseif reloadEffect == "echo" then -- 5180
			local echoRank = self:talentRank("echo_wide") -- 5181
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5182
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5183
		elseif reloadEffect == "light" then -- 5184
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5185
		end -- 5185
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5187
		self:damageProp(solid.box, 1) -- 5188
	else -- 5188
		self:flashSet("打空", 0.35) -- 5190
	end -- 5190
	if self.isCampaign then -- 5192
		self:beginReload() -- 5193
	end -- 5193
	self:emit("shotResolved", { -- 5195
		hit = hit, -- 5196
		enemyIndex = hit and hitEnemy.index or -1, -- 5197
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5198
		aimX = aim.x, -- 5199
		aimY = aim.y, -- 5200
		impactX = ox + dx * t, -- 5201
		impactY = oy + dy * t -- 5202
	}) -- 5202
end -- 5089
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5207
	local i = 0 -- 5208
	do -- 5208
		i = 0 -- 5209
		while i < #self.enemies do -- 5209
			do -- 5209
				if i == skipIndex then -- 5210
					goto __continue869 -- 5211
				end -- 5211
				local e = self.enemies[i + 1] -- 5213
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5214
					goto __continue869 -- 5215
				end -- 5215
				e.warnT = 0 -- 5217
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5218
				local pushDir = e.x >= center.x and 1 or -1 -- 5219
				e.x = math.max( -- 5220
					self.room.minX + 20, -- 5220
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5220
				) -- 5220
			end -- 5220
			::__continue869:: -- 5220
			i = i + 1 -- 5209
		end -- 5209
	end -- 5209
end -- 5207
function Play.prototype.applyFireDanger(self, shotX) -- 5225
	local ____temp_131 = self.isCampaign and self.run.joined -- 5226
	if ____temp_131 then -- 5226
		local ____opt_126 = self.room.campaign -- 5227
		local ____temp_130 = (____opt_126 and ____opt_126.chapter) == "S" -- 5227
		if not ____temp_130 then -- 5227
			local ____opt_128 = self.room.campaign -- 5227
			____temp_130 = (____opt_128 and ____opt_128.chapter) == "C" -- 5227
		end -- 5227
		____temp_131 = ____temp_130 -- 5226
	end -- 5226
	local isStorySc = ____temp_131 -- 5226
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5228
		return -- 5229
	end -- 5229
	local dangerX = shotX -- 5231
	local best = -1 -- 5232
	local bestD = 1000000000 -- 5233
	local i = 0 -- 5234
	do -- 5234
		i = 0 -- 5235
		while i < #self.enemies do -- 5235
			do -- 5235
				local e = self.enemies[i + 1] -- 5236
				if not e.alive then -- 5237
					goto __continue875 -- 5238
				end -- 5238
				local d = math.abs(e.x - self.partner.x) -- 5240
				if d < bestD then -- 5241
					bestD = d -- 5242
					best = i -- 5243
				end -- 5243
			end -- 5243
			::__continue875:: -- 5243
			i = i + 1 -- 5235
		end -- 5235
	end -- 5235
	if best >= 0 then -- 5246
		dangerX = self.enemies[best + 1].x -- 5247
	end -- 5247
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5250
		return -- 5251
	end -- 5251
	local exposed = self:childExposed(dangerX) -- 5253
	local before = self.escort.fear -- 5254
	local dangerId = self.nextDangerId -- 5255
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5256
	self.nextDangerId = self.nextDangerId + 1 -- 5257
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5258
	if after > before then -- 5259
		self:flashSet( -- 5260
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5260
			1 -- 5260
		) -- 5260
	elseif not exposed then -- 5261
		self:flashSet("枪声没够到她", 0.5) -- 5262
	end -- 5262
end -- 5225
function Play.prototype.childExposed(self, dangerX) -- 5267
	local c = self.partner -- 5268
	if not c.alive then -- 5269
		return false -- 5270
	end -- 5270
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5272
		self.boxes, -- 5273
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5273
	) then -- 5273
		return false -- 5274
	end -- 5274
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5276
		return false -- 5277
	end -- 5277
	local toDanger = dangerX - c.x -- 5279
	local toPlayer = self.player.x - c.x -- 5280
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5281
		return false -- 5283
	end -- 5283
	return true -- 5285
end -- 5267
function Play.prototype.raycastEnemies(self, ray) -- 5289
	local best = -1 -- 5290
	local bestI = -1 -- 5291
	do -- 5291
		local i = 0 -- 5292
		while i < #self.enemies do -- 5292
			do -- 5292
				local e = self.enemies[i + 1] -- 5293
				if not e.alive then -- 5294
					goto __continue890 -- 5295
				end -- 5295
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5297
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5298
				if t >= 0 and (best < 0 or t < best) then -- 5299
					best = t -- 5300
					bestI = i -- 5301
				end -- 5301
			end -- 5301
			::__continue890:: -- 5301
			i = i + 1 -- 5292
		end -- 5292
	end -- 5292
	return {t = best, index = bestI} -- 5304
end -- 5289
function Play.prototype.raycastWorld(self, ray) -- 5307
	return self:raycastSolid(ray).t -- 5308
end -- 5307
function Play.prototype.raycastSolid(self, ray) -- 5312
	local best = -1 -- 5313
	local bestBox = nil -- 5314
	for ____, box in ipairs(self.boxes) do -- 5315
		do -- 5315
			if box.broken == true or box.hidden == true then -- 5316
				goto __continue895 -- 5317
			end -- 5317
			local t = hitBox(ray, box) -- 5322
			if t > 2 and (best < 0 or t < best) then -- 5324
				best = t -- 5325
				bestBox = box -- 5326
			end -- 5326
		end -- 5326
		::__continue895:: -- 5326
	end -- 5326
	if ray.dy < 0 then -- 5329
		local t = -ray.y / ray.dy -- 5330
		if t >= 0 and (best < 0 or t < best) then -- 5331
			best = t -- 5332
			bestBox = nil -- 5333
		end -- 5333
	end -- 5333
	return {t = best, box = bestBox} -- 5336
end -- 5312
function Play.prototype.dropFor(self, e) -- 5340
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5341
		return -- 5342
	end -- 5342
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5344
		return -- 5345
	end -- 5345
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5347
	local ____self_pickups_132 = self.pickups -- 5348
	____self_pickups_132[#____self_pickups_132 + 1] = { -- 5348
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5349
		kind = e.drop, -- 5349
		x = e.x, -- 5349
		y = e.y, -- 5349
		depth = e.depth, -- 5350
		label = label .. " ×1" -- 5350
	} -- 5350
	self:log("掉落 " .. label) -- 5352
end -- 5340
function Play.prototype.damageProp(self, b, amount) -- 5356
	if b.breakable == nil or b.broken == true then -- 5357
		return -- 5358
	end -- 5358
	local ____b_breakable_133, ____hp_134 = b.breakable, "hp" -- 5360
	____b_breakable_133[____hp_134] = ____b_breakable_133[____hp_134] - amount -- 5360
	if b.breakable.hp > 0 then -- 5361
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5362
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5363
		return -- 5364
	end -- 5364
	b.broken = true -- 5366
	for ____, other in ipairs(self.boxes) do -- 5367
		if other.id ~= nil and other.id == b.id then -- 5368
			other.broken = true -- 5369
		end -- 5369
	end -- 5369
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5372
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5373
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5374
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5375
end -- 5356
function Play.prototype.slideDepth(self, a, distance) -- 5379
	a.depth = self:limitDepth(a, a.depth + distance) -- 5380
end -- 5379
function Play.prototype.limitDepth(self, a, target) -- 5383
	local road = self.room.depth -- 5384
	if road == nil or target == a.depth then -- 5385
		return a.depth -- 5386
	end -- 5386
	local next = math.max( -- 5388
		road.min, -- 5388
		math.min(road.max, target) -- 5388
	) -- 5388
	local half = a.w / 2 -- 5389
	for ____, b in ipairs(self.boxes) do -- 5390
		do -- 5390
			local footprint = b.depth -- 5391
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5392
				goto __continue913 -- 5396
			end -- 5396
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5398
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5399
			if a.depth <= front and next > front then -- 5400
				next = front -- 5401
			elseif a.depth >= back and next < back then -- 5402
				next = back -- 5403
			end -- 5403
		end -- 5403
		::__continue913:: -- 5403
	end -- 5403
	return next -- 5406
end -- 5383
function Play.prototype.slideX(self, a, dx) -- 5410
	local nx = a.x + dx -- 5411
	local half = a.w / 2 -- 5412
	local room = self.room -- 5413
	nx = math.max( -- 5414
		room.minX + half, -- 5414
		math.min(room.maxX - half, nx) -- 5414
	) -- 5414
	local i = 0 -- 5415
	do -- 5415
		i = 0 -- 5416
		while i < #self.boxes do -- 5416
			do -- 5416
				local b = self.boxes[i + 1] -- 5417
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5418
					goto __continue920 -- 5419
				end -- 5419
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5421
					goto __continue920 -- 5422
				end -- 5422
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5424
					goto __continue920 -- 5425
				end -- 5425
				if nx + half > b.x0 and nx - half < b.x1 then -- 5427
					if a.x <= b.x0 then -- 5428
						nx = b.x0 - half -- 5429
					elseif a.x >= b.x1 then -- 5430
						nx = b.x1 + half -- 5431
					else -- 5431
						nx = a.x -- 5433
					end -- 5433
				end -- 5433
			end -- 5433
			::__continue920:: -- 5433
			i = i + 1 -- 5416
		end -- 5416
	end -- 5416
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5439
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5440
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5441
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5442
			if a.x <= bx0 then -- 5443
				nx = bx0 - half -- 5444
			elseif a.x >= bx1 then -- 5445
				nx = bx1 + half -- 5446
			else -- 5446
				nx = a.x -- 5448
			end -- 5448
		end -- 5448
	end -- 5448
	local arch = room.arch -- 5456
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5457
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5458
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5459
			if a.x <= arch.x0 then -- 5460
				nx = arch.x0 - half -- 5461
			elseif a.x >= arch.x1 then -- 5462
				nx = arch.x1 + half -- 5463
			end -- 5463
		end -- 5463
	end -- 5463
	a.x = nx -- 5467
end -- 5410
function Play.prototype.fallY(self, a, dt) -- 5471
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5472
	if a.vy < -900 then -- 5473
		a.vy = -900 -- 5474
	end -- 5474
	local ny = a.y + a.vy * dt -- 5476
	local half = a.w / 2 -- 5477
	if a.vy <= 0 then -- 5478
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5480
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5481
		if ny <= ground then -- 5482
			ny = ground -- 5483
			a.vy = 0 -- 5484
			a.onGround = true -- 5485
		else -- 5485
			a.onGround = false -- 5487
		end -- 5487
	else -- 5487
		a.onGround = false -- 5490
		local i = 0 -- 5491
		do -- 5491
			i = 0 -- 5492
			while i < #self.boxes do -- 5492
				do -- 5492
					local b = self.boxes[i + 1] -- 5493
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5494
						goto __continue944 -- 5495
					end -- 5495
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5497
						goto __continue944 -- 5498
					end -- 5498
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5500
						goto __continue944 -- 5501
					end -- 5501
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5503
						ny = b.y0 - a.h -- 5504
						a.vy = 0 -- 5505
					end -- 5505
				end -- 5505
				::__continue944:: -- 5505
				i = i + 1 -- 5492
			end -- 5492
		end -- 5492
	end -- 5492
	a.y = ny -- 5509
end -- 5471
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5513
	if depth == nil then -- 5513
		depth = 0 -- 5513
	end -- 5513
	local g = -9999 -- 5514
	local i = 0 -- 5515
	do -- 5515
		i = 0 -- 5516
		while i < #self.floors do -- 5516
			local f = self.floors[i + 1] -- 5517
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5518
				g = f.y1 -- 5519
			end -- 5519
			i = i + 1 -- 5516
		end -- 5516
	end -- 5516
	do -- 5516
		i = 0 -- 5522
		while i < #self.boxes do -- 5522
			do -- 5522
				local b = self.boxes[i + 1] -- 5523
				if b.broken == true or b.hidden == true or b.soft == true then -- 5524
					goto __continue954 -- 5525
				end -- 5525
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5527
					g = b.y1 -- 5529
				end -- 5529
			end -- 5529
			::__continue954:: -- 5529
			i = i + 1 -- 5522
		end -- 5522
	end -- 5522
	return g -- 5532
end -- 5513
function Play.prototype.updateCamera(self, dt) -- 5535
	local p = self.player -- 5536
	local tx = p.x + p.facing * 30 -- 5537
	local ty = p.y + CAM_LOOK_UP -- 5538
	local k = math.min(1, CAM_FOLLOW * dt) -- 5539
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5540
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5541
end -- 5535
function Play.prototype.clampCamera(self, w, h) -- 5545
	local room = self.room -- 5546
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5547
	local spanX = room.maxX - room.minX -- 5548
	if spanX <= halfW * 2 then -- 5549
		self.cam.x = (room.minX + room.maxX) / 2 -- 5550
	else -- 5550
		self.cam.x = math.max( -- 5552
			room.minX + halfW, -- 5552
			math.min(room.maxX - halfW, self.cam.x) -- 5552
		) -- 5552
	end -- 5552
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5555
	local spanY = room.height -- 5556
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5557
	if spanY <= halfH * 2 then -- 5558
		self.cam.y = camY -- 5559
	else -- 5559
		self.cam.y = math.max( -- 5561
			camY, -- 5561
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5561
		) -- 5561
	end -- 5561
end -- 5545
function Play.prototype.flashSet(self, text, t) -- 5565
	self.flash = text -- 5566
	self.flashT = t -- 5567
end -- 5565
function Play.prototype.statusText(self) -- 5571
	local p = self.player -- 5572
	local parts = {} -- 5573
	local who = self.childMode and "小满" or "周戍" -- 5574
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5575
	if self.room.key == "prologue" then -- 5577
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5578
		if self.phase == "prologue-wake" then -- 5579
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5580
		elseif self.phase == "prologue-shadow" then -- 5581
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5582
		elseif self.phase == "prologue-escape" then -- 5583
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5584
		elseif self.phase == "prologue-hide" then -- 5585
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5586
		elseif self.phase == "prologue-wait" then -- 5587
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5588
		elseif self.phase == "prologue-give" then -- 5589
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 5590
		else -- 5590
			parts[#parts + 1] = "跟随" -- 5592
		end -- 5592
		if self.paused then -- 5594
			parts[#parts + 1] = "已暂停" -- 5595
		end -- 5595
		return table.concat(parts, " · ") -- 5597
	end -- 5597
	if self.room.key == "street" then -- 5599
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5600
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5601
		if self.paused then -- 5602
			parts[#parts + 1] = "已暂停" -- 5603
		end -- 5603
		return table.concat(parts, " · ") -- 5605
	end -- 5605
	if self.room.key == "gate" then -- 5607
		local ____temp_135 -- 5608
		if self.room.story == nil then -- 5608
			____temp_135 = nil -- 5608
		else -- 5608
			____temp_135 = self.room.story.gate -- 5608
		end -- 5608
		local g = ____temp_135 -- 5608
		if g ~= nil then -- 5609
			parts[#parts + 1] = self:gateLabel() -- 5610
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5611
				0, -- 5612
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5612
			))) .. " 秒" -- 5612
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5613
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5614
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5615
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5616
			if self.gateFailCount > 0 then -- 5617
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5618
			end -- 5618
			if self.flash ~= "" then -- 5620
				parts[#parts + 1] = self.flash -- 5621
			end -- 5621
		end -- 5621
		if self.paused then -- 5624
			parts[#parts + 1] = "已暂停" -- 5625
		end -- 5625
		return table.concat(parts, " · ") -- 5627
	end -- 5627
	if self.room.key == "forest" then -- 5629
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5630
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5631
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5632
		if self.caughtT > 0 then -- 5633
			parts[#parts + 1] = "复位中" -- 5634
		end -- 5634
		if self.paused then -- 5636
			parts[#parts + 1] = "已暂停" -- 5637
		end -- 5637
		return table.concat(parts, " · ") -- 5639
	end -- 5639
	if self.room.key == "tower" then -- 5641
		if self.phase == "tower-wait" then -- 5642
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5643
		elseif self.phase == "tower-knock" then -- 5644
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5645
		elseif self.phase == "tower-enter" then -- 5646
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5647
		elseif self.phase == "tower-desk" then -- 5648
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5649
		elseif self.phase == "tower-given" then -- 5650
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5651
		else -- 5651
			parts[#parts + 1] = "片尾" -- 5653
		end -- 5653
		if self.paused then -- 5655
			parts[#parts + 1] = "已暂停" -- 5656
		end -- 5656
		return table.concat(parts, " · ") -- 5658
	end -- 5658
	if self.room.key == "village" then -- 5660
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5661
		if self.hasBottle then -- 5662
			parts[#parts + 1] = "有瓶" -- 5663
		elseif self.bottleFly ~= nil then -- 5664
			parts[#parts + 1] = "瓶在飞" -- 5665
		else -- 5665
			parts[#parts + 1] = "空手" -- 5667
		end -- 5667
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5669
		if self.scavChase then -- 5670
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5671
		end -- 5671
		if self.passed then -- 5673
			parts[#parts + 1] = "已过通行线" -- 5674
		end -- 5674
		if self.paused then -- 5676
			parts[#parts + 1] = "已暂停" -- 5677
		end -- 5677
		return table.concat(parts, " · ") -- 5679
	end -- 5679
	local isChild = self.childMode -- 5682
	if isChild then -- 5683
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5684
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5685
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5686
	else -- 5686
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5688
		if p.rollT > 0 then -- 5689
			parts[#parts + 1] = "翻滚中" -- 5690
		end -- 5690
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5692
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5693
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5694
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5695
	end -- 5695
	if self.checkpoint >= 0 then -- 5697
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5698
	end -- 5698
	if self.paused then -- 5700
		parts[#parts + 1] = "已暂停" -- 5701
	end -- 5701
	return table.concat(parts, " · ") -- 5703
end -- 5571
function Play.prototype.aliveEnemies(self) -- 5707
	local n = 0 -- 5708
	local i = 0 -- 5709
	do -- 5709
		i = 0 -- 5710
		while i < #self.enemies do -- 5710
			if self.enemies[i + 1].alive then -- 5711
				n = n + 1 -- 5712
			end -- 5712
			i = i + 1 -- 5710
		end -- 5710
	end -- 5710
	return n -- 5715
end -- 5707
function Play.prototype.threatened(self) -- 5720
	do -- 5720
		local i = 0 -- 5721
		while i < #self.enemies do -- 5721
			local e = self.enemies[i + 1] -- 5722
			if e.alive and e.warnT > 0 then -- 5723
				return true -- 5724
			end -- 5724
			i = i + 1 -- 5721
		end -- 5721
	end -- 5721
	return false -- 5727
end -- 5720
function Play.prototype.gateSecondsLeft(self) -- 5730
	local ____temp_136 -- 5731
	if self.room.story == nil then -- 5731
		____temp_136 = nil -- 5731
	else -- 5731
		____temp_136 = self.room.story.gate -- 5731
	end -- 5731
	local g = ____temp_136 -- 5731
	if g == nil then -- 5732
		return 0 -- 5733
	end -- 5733
	return math.max( -- 5735
		0, -- 5735
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5735
	) -- 5735
end -- 5730
function Play.prototype.gateLabel(self) -- 5738
	if self.phase == "gate-idle" then -- 5739
		return "待就位" -- 5740
	end -- 5740
	if self.phase == "gate-hold" then -- 5742
		return "守点中" -- 5743
	end -- 5743
	if self.phase == "gate-send" then -- 5745
		return "送别" -- 5746
	end -- 5746
	if self.phase == "gate-count" then -- 5748
		return "数数 " .. tostring(self.countTick) -- 5749
	end -- 5749
	return "她走" -- 5751
end -- 5738
function Play.prototype.dogLabel(self) -- 5755
	if self.dogState == "ear" then -- 5756
		return "转耳" -- 5757
	end -- 5757
	if self.dogState == "chase" then -- 5759
		return "追" -- 5760
	end -- 5760
	if self.dogState == "sniff" then -- 5762
		return "停" -- 5763
	end -- 5763
	if self.dogState == "back" then -- 5765
		return "回线" -- 5766
	end -- 5766
	return "巡逻" -- 5768
end -- 5755
function Play.prototype.doorXOf(self) -- 5771
	local ____temp_137 -- 5772
	if self.room.story == nil then -- 5772
		____temp_137 = nil -- 5772
	else -- 5772
		____temp_137 = self.room.story.tower -- 5772
	end -- 5772
	local t = ____temp_137 -- 5772
	return t == nil and 0 or t.doorX -- 5773
end -- 5771
function Play.prototype.scavLabel(self) -- 5777
	if self.scavState == "chase" then -- 5778
		return "追" -- 5779
	end -- 5779
	if self.scavState == "turn" then -- 5781
		return "转头" -- 5782
	end -- 5782
	if self.scavState == "walk" then -- 5784
		return "赶来" -- 5785
	end -- 5785
	if self.scavState == "stall" then -- 5787
		return "停住" -- 5788
	end -- 5788
	if self.scavState == "back" then -- 5790
		return "回位" -- 5791
	end -- 5791
	return "巡逻" -- 5793
end -- 5777
function Play.prototype.hintText(self) -- 5797
	if self.paused then -- 5798
		return "Esc 继续 · R 重置" -- 5799
	end -- 5799
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5803
		if self:threatened() then -- 5804
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5805
		end -- 5805
		if self.coverHug then -- 5807
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5808
		end -- 5808
		if self.coverNear then -- 5810
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5811
		end -- 5811
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5813
	end -- 5813
	if self.flash ~= "" then -- 5815
		return self.flash -- 5816
	end -- 5816
	if self.room.key == "prologue" then -- 5818
		if self.phase == "prologue-wake" then -- 5819
			return "父亲在门外唤 · 小满睁眼" -- 5820
		end -- 5820
		if self.phase == "prologue-shadow" then -- 5822
			return "墙上两道人影 · 碗滚到脚边" -- 5823
		end -- 5823
		if self.phase == "prologue-escape" then -- 5825
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5826
		end -- 5826
		if self.phase == "prologue-hide" then -- 5828
			return "柜门合上 · 屏住呼吸" -- 5829
		end -- 5829
		if self.phase == "prologue-wait" then -- 5831
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5832
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5833
		end -- 5833
		if self.phase == "prologue-give" then -- 5835
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5836
		end -- 5836
		return "她跟着你了 · 两人一起走到门口 680" -- 5838
	end -- 5838
	if self.room.key == "street" then -- 5840
		if self:aliveEnemies() > 0 then -- 5841
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5842
		end -- 5842
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5844
	end -- 5844
	if self.room.key == "gate" then -- 5846
		local ____temp_138 -- 5847
		if self.room.story == nil then -- 5847
			____temp_138 = nil -- 5847
		else -- 5847
			____temp_138 = self.room.story.gate -- 5847
		end -- 5847
		local g = ____temp_138 -- 5847
		if g ~= nil then -- 5848
			if self.phase == "gate-idle" then -- 5849
				if self.gateNeedConfirm then -- 5850
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5851
				end -- 5851
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5853
			end -- 5853
			if self.phase == "gate-hold" then -- 5855
				if self.coveredFlash > 0 then -- 5856
					return "掩体挡下了这一枪 · 别露头" -- 5857
				end -- 5857
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5859
			end -- 5859
			if self.phase == "gate-send" then -- 5861
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5862
			end -- 5862
			if self.phase == "gate-count" then -- 5864
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5865
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5866
				end -- 5866
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5868
			end -- 5868
			return "她自己走 · 跟着出城门 1120" -- 5870
		end -- 5870
	end -- 5870
	if self.room.key == "forest" then -- 5873
		if self.dogState == "chase" then -- 5874
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5875
		end -- 5875
		if self.dogState == "ear" then -- 5877
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5878
		end -- 5878
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5880
	end -- 5880
	if self.room.key == "tower" then -- 5882
		if self.phase == "tower-wait" then -- 5883
			return "走到门前 445 点一次 E 敲两下" -- 5884
		end -- 5884
		if self.phase == "tower-knock" then -- 5886
			return "敲两下 · 等门开" -- 5887
		end -- 5887
		if self.phase == "tower-given" then -- 5889
			return "递交针套和纸条 · 看登记簿最后一行" -- 5890
		end -- 5890
		return "片尾 · 点 E 再玩一次，回到序章" -- 5892
	end -- 5892
	if self.room.key == "village" then -- 5894
		if self.bottleFly ~= nil then -- 5895
			return "等瓶子落地 · 触地才发声" -- 5896
		end -- 5896
		if self.hasBottle then -- 5898
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5899
		end -- 5899
		if self.passed then -- 5901
			return "已过第一院 · R 重置可再来一遍" -- 5902
		end -- 5902
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5904
	end -- 5904
	if self.room.key == "outside" then -- 5906
		if self.focusCart then -- 5907
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5908
		end -- 5908
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5910
	end -- 5910
	if self.escort.state == "frozen" then -- 5912
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5913
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5914
		end -- 5914
		return "小满吓住了 · 走过去，靠近再点 E" -- 5916
	end -- 5916
	if self.escort.state == "calming" then -- 5918
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5919
	end -- 5919
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5921
end -- 5797
function Play.prototype.draw(self, draw, w, h) -- 5926
	self.viewW = w -- 5927
	self.viewH = h -- 5928
	self.view = ____exports.computeViewport(w, h) -- 5929
	self:clampCamera(w, h) -- 5930
	draw:clear() -- 5931
	draw:drawRect( -- 5933
		Rect(0, 0, w, h), -- 5933
		BG_VOID -- 5933
	) -- 5933
	local box = self:canvasRect(w, h) -- 5934
	draw:drawRect(box, BG_FAR) -- 5935
	draw:drawRect( -- 5936
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5936
		BG_MID -- 5936
	) -- 5936
	self:drawFloors(draw, w, h) -- 5938
	self:drawSolids(draw, w, h) -- 5939
	self:drawZones(draw, w, h) -- 5940
	self:drawArch(draw, w, h) -- 5941
	self:drawCart(draw, w, h) -- 5942
	self:drawCampaignProps(draw, w, h) -- 5943
	self:drawActors(draw, w, h) -- 5944
	self:drawTrace(draw, w, h) -- 5945
	self:drawAim(draw, w, h) -- 5946
end -- 5926
function Play.prototype.canvasRect(self, w, h) -- 5950
	local v = self.view -- 5951
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5952
end -- 5950
function Play.prototype.px(self, n) -- 5956
	return n * self.view.zoom -- 5957
end -- 5956
function Play.prototype.sx(self, wx, w) -- 5961
	local v = self.view -- 5962
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5963
	return v.ox + lx * v.zoom -- 5964
end -- 5961
function Play.prototype.sy(self, wy, h) -- 5968
	local v = self.view -- 5969
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 5970
	return v.oy + ly * v.zoom -- 5971
end -- 5968
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 5974
	local px0 = self:sx(x0, w) -- 5975
	local px1 = self:sx(x1, w) -- 5976
	local py0 = self:sy(y0, h) -- 5977
	local py1 = self:sy(y1, h) -- 5978
	if px1 <= px0 or py1 <= py0 then -- 5979
		return -- 5980
	end -- 5980
	draw:drawRect( -- 5982
		Rect(px0, py0, px1 - px0, py1 - py0), -- 5982
		color -- 5982
	) -- 5982
end -- 5974
function Play.prototype.drawFloors(self, draw, w, h) -- 5985
	local i = 0 -- 5986
	do -- 5986
		i = 0 -- 5987
		while i < #self.room.floors do -- 5987
			local f = self.room.floors[i + 1] -- 5988
			local ____temp_139 -- 5989
			if f.y == 0 then -- 5989
				____temp_139 = self.room.depth -- 5989
			else -- 5989
				____temp_139 = nil -- 5989
			end -- 5989
			local road = ____temp_139 -- 5989
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5990
			local x0 = self:sx(f.x0, w) -- 5991
			local x1 = self:sx(f.x1, w) -- 5992
			local deck = self:px(5) -- 5993
			if road ~= nil then -- 5994
				local back = self:sy(f.y + road.max, h) -- 5995
				draw:drawRect( -- 5996
					Rect(x0, y, x1 - x0, back - y), -- 5996
					FLOOR_DECK, -- 5996
					self:px(1), -- 5996
					SOLID_EDGE -- 5996
				) -- 5996
			end -- 5996
			draw:drawRect( -- 5998
				Rect(x0, y - deck, x1 - x0, deck), -- 5998
				FLOOR_DECK -- 5998
			) -- 5998
			draw:drawSegment( -- 5999
				Vec2(x0, y), -- 5999
				Vec2(x1, y), -- 5999
				self:px(1), -- 5999
				GROUND -- 5999
			) -- 5999
			i = i + 1 -- 5987
		end -- 5987
	end -- 5987
end -- 5985
function Play.prototype.drawSolids(self, draw, w, h) -- 6003
	local i = 0 -- 6004
	do -- 6004
		i = 0 -- 6005
		while i < #self.boxes do -- 6005
			do -- 6005
				local b = self.boxes[i + 1] -- 6006
				if b.id == "braced_shield" or b.hidden == true then -- 6007
					goto __continue1085 -- 6008
				end -- 6008
				if b.broken == true then -- 6010
					if b.breakable ~= nil then -- 6012
						local gy = self:sy(b.y0, h) -- 6013
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 6014
						local k = 0 -- 6015
						do -- 6015
							k = 0 -- 6016
							while k < 3 do -- 6016
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 6017
								draw:drawSegment( -- 6018
									Vec2( -- 6018
										gx - self:px(4), -- 6018
										gy + self:px(k % 2) -- 6018
									), -- 6018
									Vec2( -- 6018
										gx + self:px(5), -- 6018
										gy + self:px(k % 2) -- 6018
									), -- 6018
									self:px(1), -- 6018
									rgb -- 6018
								) -- 6018
								k = k + 1 -- 6016
							end -- 6016
						end -- 6016
					end -- 6016
					goto __continue1085 -- 6021
				end -- 6021
				local ____opt_142 = b.depth -- 6023
				local front = ____opt_142 and ____opt_142.min or 0 -- 6023
				local ____opt_144 = b.depth -- 6024
				local back = ____opt_144 and ____opt_144.max or 0 -- 6024
				local fill = SOLID_FILL -- 6025
				local line = SOLID_EDGE -- 6026
				if b.soft == true then -- 6027
					fill = SOFT -- 6028
					line = SOFT_LINE -- 6029
				elseif b.breakable ~= nil then -- 6030
					line = DANGER_LINE -- 6031
					fill = Color(0.3, 0.24, 0.16, 1) -- 6032
				elseif b.interact ~= nil then -- 6033
					line = PASS_LINE -- 6034
				end -- 6034
				self:drawBox( -- 6036
					draw, -- 6036
					w, -- 6036
					h, -- 6036
					b.x0, -- 6036
					b.x1, -- 6036
					b.y0 + front, -- 6036
					b.y1 + back, -- 6036
					fill -- 6036
				) -- 6036
				draw:drawSegment( -- 6037
					Vec2( -- 6037
						self:sx(b.x0, w), -- 6037
						self:sy(b.y1 + front, h) -- 6037
					), -- 6037
					Vec2( -- 6038
						self:sx(b.x1, w), -- 6038
						self:sy(b.y1 + front, h) -- 6038
					), -- 6038
					self:px(1), -- 6038
					line -- 6038
				) -- 6038
				if b.breakable ~= nil then -- 6040
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 6041
					local cyp = self:sy(b.y1 + front, h) -- 6042
					draw:drawSegment( -- 6043
						Vec2( -- 6043
							cxp - self:px(4), -- 6043
							cyp + self:px(1) -- 6043
						), -- 6043
						Vec2( -- 6043
							cxp + self:px(3), -- 6043
							cyp + self:px(5) -- 6043
						), -- 6043
						self:px(1), -- 6043
						line -- 6043
					) -- 6043
				end -- 6043
			end -- 6043
			::__continue1085:: -- 6043
			i = i + 1 -- 6005
		end -- 6005
	end -- 6005
end -- 6003
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 6049
	local i = 0 -- 6050
	do -- 6050
		i = 0 -- 6051
		while i < #self.pickups do -- 6051
			do -- 6051
				local pk = self.pickups[i + 1] -- 6052
				if self.run.taken[pk.id] == true then -- 6053
					goto __continue1097 -- 6054
				end -- 6054
				local gy = pk.y + (pk.depth or 0) -- 6056
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 6057
				draw:drawRect( -- 6058
					Rect( -- 6058
						self:sx(pk.x - 5, w), -- 6058
						self:sy(gy + 12 + bob, h), -- 6058
						self:px(10), -- 6058
						self:px(10) -- 6058
					), -- 6058
					Color(0.84, 0.7, 0.3, 1) -- 6059
				) -- 6059
				draw:drawSegment( -- 6060
					Vec2( -- 6060
						self:sx(pk.x - 5, w), -- 6060
						self:sy(gy + 12 + bob, h) -- 6060
					), -- 6060
					Vec2( -- 6061
						self:sx(pk.x + 5, w), -- 6061
						self:sy(gy + 12 + bob, h) -- 6061
					), -- 6061
					self:px(1), -- 6061
					Color(0.95, 0.86, 0.52, 1) -- 6061
				) -- 6061
			end -- 6061
			::__continue1097:: -- 6061
			i = i + 1 -- 6051
		end -- 6051
	end -- 6051
	if self.bracedShield ~= nil then -- 6063
		local sh = self.bracedShield -- 6064
		draw:drawRect( -- 6065
			Rect( -- 6065
				self:sx(sh.x - sh.w / 2, w), -- 6065
				self:sy(sh.y, h), -- 6065
				self:px(sh.w), -- 6065
				self:px(sh.h) -- 6065
			), -- 6065
			Color(0.42, 0.4, 0.34, 1) -- 6066
		) -- 6066
		draw:drawSegment( -- 6067
			Vec2( -- 6067
				self:sx(sh.x - sh.w / 2, w), -- 6067
				self:sy(sh.y + sh.h, h) -- 6067
			), -- 6067
			Vec2( -- 6068
				self:sx(sh.x + sh.w / 2, w), -- 6068
				self:sy(sh.y + sh.h, h) -- 6068
			), -- 6068
			self:px(1), -- 6068
			Color(0.74, 0.72, 0.62, 1) -- 6068
		) -- 6068
	end -- 6068
end -- 6049
function Play.prototype.drawZones(self, draw, w, h) -- 6072
	local i = 0 -- 6073
	do -- 6073
		i = 0 -- 6074
		while i < #self.room.zones do -- 6074
			local z = self.room.zones[i + 1] -- 6075
			local fill = DANGER -- 6076
			local line = DANGER_LINE -- 6077
			if z.tint == 2 then -- 6078
				fill = SOFT -- 6079
				line = SOFT_LINE -- 6080
			elseif z.tint == 3 then -- 6081
				fill = BRICK -- 6082
				line = BRICK_LINE -- 6083
			elseif z.tint == 4 then -- 6084
				fill = PASS -- 6085
				line = PASS_LINE -- 6086
			end -- 6086
			self:drawBox( -- 6088
				draw, -- 6088
				w, -- 6088
				h, -- 6088
				z.x0, -- 6088
				z.x1, -- 6088
				z.y, -- 6088
				z.y + z.h, -- 6088
				fill -- 6088
			) -- 6088
			draw:drawSegment( -- 6089
				Vec2( -- 6089
					self:sx(z.x0, w), -- 6089
					self:sy(z.y, h) -- 6089
				), -- 6089
				Vec2( -- 6089
					self:sx(z.x0, w), -- 6089
					self:sy(z.y + z.h, h) -- 6089
				), -- 6089
				self:px(1), -- 6089
				line -- 6089
			) -- 6089
			draw:drawSegment( -- 6090
				Vec2( -- 6090
					self:sx(z.x1, w), -- 6090
					self:sy(z.y, h) -- 6090
				), -- 6090
				Vec2( -- 6090
					self:sx(z.x1, w), -- 6090
					self:sy(z.y + z.h, h) -- 6090
				), -- 6090
				self:px(1), -- 6090
				line -- 6090
			) -- 6090
			i = i + 1 -- 6074
		end -- 6074
	end -- 6074
end -- 6072
function Play.prototype.drawArch(self, draw, w, h) -- 6094
	local a = self.room.arch -- 6095
	if a.h <= 0 then -- 6096
		return -- 6097
	end -- 6097
	self:drawBox( -- 6099
		draw, -- 6099
		w, -- 6099
		h, -- 6099
		a.x0, -- 6099
		a.x1, -- 6099
		a.y, -- 6099
		a.y + a.h, -- 6099
		HOLE_FILL -- 6099
	) -- 6099
	draw:drawSegment( -- 6100
		Vec2( -- 6100
			self:sx(a.x0, w), -- 6100
			self:sy(a.y + a.h, h) -- 6100
		), -- 6100
		Vec2( -- 6100
			self:sx(a.x1, w), -- 6100
			self:sy(a.y + a.h, h) -- 6100
		), -- 6100
		self:px(1), -- 6100
		SOLID_EDGE -- 6100
	) -- 6100
	draw:drawSegment( -- 6101
		Vec2( -- 6101
			self:sx(a.x0, w), -- 6101
			self:sy(a.y, h) -- 6101
		), -- 6101
		Vec2( -- 6101
			self:sx(a.x0, w), -- 6101
			self:sy(a.y + a.h, h) -- 6101
		), -- 6101
		self:px(1), -- 6101
		SOLID_EDGE -- 6101
	) -- 6101
	draw:drawSegment( -- 6102
		Vec2( -- 6102
			self:sx(a.x1, w), -- 6102
			self:sy(a.y, h) -- 6102
		), -- 6102
		Vec2( -- 6102
			self:sx(a.x1, w), -- 6102
			self:sy(a.y + a.h, h) -- 6102
		), -- 6102
		self:px(1), -- 6102
		SOLID_EDGE -- 6102
	) -- 6102
end -- 6094
function Play.prototype.drawCart(self, draw, w, h) -- 6105
	local c = self.room.cart -- 6106
	if c.bodyW <= 0 then -- 6107
		return -- 6108
	end -- 6108
	drawCartShape( -- 6110
		draw, -- 6110
		self, -- 6110
		w, -- 6110
		h, -- 6110
		c, -- 6110
		self.cartAxle -- 6110
	) -- 6110
	draw:drawRect( -- 6111
		Rect( -- 6111
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 6111
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 6111
			self:px(2), -- 6111
			self:px(40) -- 6111
		), -- 6111
		STAND -- 6111
	) -- 6111
end -- 6105
function Play.prototype.drawActors(self, draw, w, h) -- 6114
	local p = self.player -- 6115
	local isChild = self.childMode -- 6116
	local footY = p.y + p.depth -- 6117
	if p.covered then -- 6119
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 6120
		draw:drawSegment( -- 6121
			Vec2( -- 6121
				self:sx(edge, w), -- 6121
				self:sy(footY + 8, h) -- 6121
			), -- 6121
			Vec2( -- 6121
				self:sx(edge, w), -- 6121
				self:sy(footY + p.h * 0.62, h) -- 6121
			), -- 6121
			self:px(2), -- 6121
			STAND -- 6121
		) -- 6121
		draw:drawSegment( -- 6123
			Vec2( -- 6123
				self:sx(p.x - 8, w), -- 6123
				self:sy(footY + p.h + 3, h) -- 6123
			), -- 6123
			Vec2( -- 6123
				self:sx(p.x + 8, w), -- 6123
				self:sy(footY + p.h + 3, h) -- 6123
			), -- 6123
			self:px(2), -- 6123
			STAND -- 6123
		) -- 6123
	elseif self.coverNear and not isChild then -- 6124
		draw:drawRect( -- 6126
			Rect( -- 6126
				self:sx(p.x - 3, w), -- 6126
				self:sy(footY + 1, h), -- 6126
				self:px(3), -- 6126
				self:px(3) -- 6126
			), -- 6126
			STAND -- 6126
		) -- 6126
	end -- 6126
	drawFigure( -- 6128
		draw, -- 6128
		self, -- 6128
		w, -- 6128
		h, -- 6128
		p, -- 6128
		isChild and CHILD_BODY or SOLDIER_BODY, -- 6128
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 6128
	) -- 6128
	local q = self.partner -- 6129
	if q.alive then -- 6130
		local childPartner = q.w == CHILD_W -- 6131
		drawFigure( -- 6132
			draw, -- 6132
			self, -- 6132
			w, -- 6132
			h, -- 6132
			q, -- 6132
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 6132
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 6132
		) -- 6132
	end -- 6132
	local i = 0 -- 6134
	do -- 6134
		i = 0 -- 6135
		while i < #self.enemies do -- 6135
			local e = self.enemies[i + 1] -- 6136
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 6137
			local enemyY = e.y + (e.depth or 0) -- 6138
			self:drawBox( -- 6139
				draw, -- 6139
				w, -- 6139
				h, -- 6139
				e.x - e.w / 2, -- 6139
				e.x + e.w / 2, -- 6139
				enemyY, -- 6139
				enemyY + e.h, -- 6139
				col -- 6139
			) -- 6139
			if e.alive then -- 6140
				local ef = p.x >= e.x and 1 or -1 -- 6141
				if e.kind == "shield" then -- 6142
					local sh = (e.shieldHp or 0) > 0 -- 6143
					draw:drawRect( -- 6144
						Rect( -- 6144
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 6144
							self:sy(enemyY, h), -- 6144
							self:px(6), -- 6144
							self:px(64) -- 6144
						), -- 6144
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 6145
					) -- 6145
				elseif e.kind == "breaker" then -- 6146
					draw:drawSegment( -- 6147
						Vec2( -- 6147
							self:sx(e.x + ef * 12, w), -- 6147
							self:sy(enemyY + 8, h) -- 6147
						), -- 6147
						Vec2( -- 6148
							self:sx(e.x + ef * 22, w), -- 6148
							self:sy(enemyY + 46, h) -- 6148
						), -- 6148
						self:px(3), -- 6148
						Color(0.5, 0.36, 0.22, 1) -- 6148
					) -- 6148
				end -- 6148
			end -- 6148
			if e.alive and e.warnT > 0 then -- 6152
				local gunX = self:sx(e.x, w) -- 6153
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 6154
				local aimX = self:sx(p.x, w) -- 6155
				local aimY = self:sy(footY + p.h * 0.55, h) -- 6156
				local seg = 8 -- 6157
				local s = 0 -- 6158
				do -- 6158
					s = 0 -- 6159
					while s < seg do -- 6159
						local t0 = s / seg -- 6160
						local t1 = (s + 1) / seg -- 6161
						draw:drawSegment( -- 6162
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 6163
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 6164
							self:px(1), -- 6165
							DANGER -- 6165
						) -- 6165
						s = s + 2 -- 6159
					end -- 6159
				end -- 6159
			end -- 6159
			i = i + 1 -- 6135
		end -- 6135
	end -- 6135
	local k = 0 -- 6170
	do -- 6170
		k = 0 -- 6171
		while k < #self.room.marks do -- 6171
			do -- 6171
				local m = self.room.marks[k + 1] -- 6172
				if m.kind ~= 0 then -- 6173
					goto __continue1123 -- 6174
				end -- 6174
				local on = self.checkpoint == m.x -- 6176
				local x = self:sx(m.x, w) -- 6177
				local y = self:sy(m.y, h) -- 6178
				draw:drawSegment( -- 6179
					Vec2(x, y), -- 6179
					Vec2( -- 6179
						x, -- 6179
						y + self:px(35) -- 6179
					), -- 6179
					self:px(1), -- 6179
					on and CHECK or INK_DIM -- 6179
				) -- 6179
				draw:drawDot( -- 6180
					Vec2( -- 6180
						x, -- 6180
						y + self:px(35) -- 6180
					), -- 6180
					self:px(2), -- 6180
					on and CHECK or INK_DIM -- 6180
				) -- 6180
			end -- 6180
			::__continue1123:: -- 6180
			k = k + 1 -- 6171
		end -- 6171
	end -- 6171
	local j = 0 -- 6184
	do -- 6184
		j = 0 -- 6185
		while j < #self.room.marks do -- 6185
			do -- 6185
				local m = self.room.marks[j + 1] -- 6186
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 6187
					goto __continue1126 -- 6188
				end -- 6188
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 6190
					goto __continue1126 -- 6192
				end -- 6192
				local col = STAND -- 6194
				if m.kind == 4 then -- 6195
					col = PASS_LINE -- 6196
				elseif m.kind == 5 then -- 6197
					col = BRICK_LINE -- 6198
				end -- 6198
				local mx = self:sx(m.x, w) -- 6200
				local my = self:sy(m.y, h) -- 6201
				draw:drawSegment( -- 6202
					Vec2(mx, my), -- 6202
					Vec2( -- 6202
						mx, -- 6202
						my + self:px(24) -- 6202
					), -- 6202
					self:px(1), -- 6202
					col -- 6202
				) -- 6202
			end -- 6202
			::__continue1126:: -- 6202
			j = j + 1 -- 6185
		end -- 6185
	end -- 6185
	local t = 0 -- 6205
	do -- 6205
		t = 0 -- 6206
		while t < #self.room.marks do -- 6206
			do -- 6206
				local m = self.room.marks[t + 1] -- 6207
				if m.kind ~= 6 then -- 6208
					goto __continue1132 -- 6209
				end -- 6209
				local mx = self:sx(m.x, w) -- 6211
				local my = self:sy(m.y, h) -- 6212
				draw:drawSegment( -- 6213
					Vec2(mx, my), -- 6213
					Vec2( -- 6213
						mx, -- 6213
						my + self:px(30) -- 6213
					), -- 6213
					self:px(1), -- 6213
					INK_DIM -- 6213
				) -- 6213
				self:drawBox( -- 6214
					draw, -- 6214
					w, -- 6214
					h, -- 6214
					m.x - 5, -- 6214
					m.x + 5, -- 6214
					m.y + 30, -- 6214
					m.y + 40, -- 6214
					CHECK -- 6214
				) -- 6214
			end -- 6214
			::__continue1132:: -- 6214
			t = t + 1 -- 6206
		end -- 6206
	end -- 6206
	if self.room.key == "village" then -- 6216
		self:drawVillage(draw, w, h) -- 6217
	end -- 6217
	if self.room.key == "forest" then -- 6219
		self:drawDog(draw, w, h) -- 6220
	end -- 6220
end -- 6114
function Play.prototype.drawDog(self, draw, w, h) -- 6225
	local x = self.dogX -- 6226
	self:drawBox( -- 6227
		draw, -- 6227
		w, -- 6227
		h, -- 6227
		x - 14, -- 6227
		x + 14, -- 6227
		0, -- 6227
		20, -- 6227
		SCAV_BODY -- 6227
	) -- 6227
	self:drawBox( -- 6228
		draw, -- 6228
		w, -- 6228
		h, -- 6228
		x - 10, -- 6228
		x - 2, -- 6228
		20, -- 6228
		30, -- 6228
		SCAV_BODY -- 6228
	) -- 6228
	self:drawBox( -- 6229
		draw, -- 6229
		w, -- 6229
		h, -- 6229
		x + 2, -- 6229
		x + 10, -- 6229
		20, -- 6229
		30, -- 6229
		SCAV_HEAD -- 6229
	) -- 6229
	if self.dogState == "ear" or self.dogState == "chase" then -- 6230
		draw:drawSegment( -- 6231
			Vec2( -- 6231
				self:sx(x, w), -- 6231
				self:sy(30, h) -- 6231
			), -- 6231
			Vec2( -- 6232
				self:sx(x, w), -- 6232
				self:sy(40, h) -- 6232
			), -- 6232
			self:px(1), -- 6232
			DANGER -- 6232
		) -- 6232
	end -- 6232
end -- 6225
function Play.prototype.drawVillage(self, draw, w, h) -- 6237
	local bottle = self.room.bottle -- 6238
	if bottle ~= nil then -- 6239
		self:drawBox( -- 6240
			draw, -- 6240
			w, -- 6240
			h, -- 6240
			bottle.x - 14, -- 6240
			bottle.x + 14, -- 6240
			0, -- 6240
			64, -- 6240
			SOLID_FILL -- 6240
		) -- 6240
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6241
			self:drawBottle( -- 6242
				draw, -- 6242
				w, -- 6242
				h, -- 6242
				bottle.x, -- 6242
				64 -- 6242
			) -- 6242
		end -- 6242
	end -- 6242
	self:drawBox( -- 6246
		draw, -- 6246
		w, -- 6246
		h, -- 6246
		300, -- 6246
		420, -- 6246
		44, -- 6246
		50, -- 6246
		FLOOR_DECK -- 6246
	) -- 6246
	self:drawBox( -- 6247
		draw, -- 6247
		w, -- 6247
		h, -- 6247
		300, -- 6247
		306, -- 6247
		0, -- 6247
		44, -- 6247
		FLOOR_DECK -- 6247
	) -- 6247
	self:drawBox( -- 6248
		draw, -- 6248
		w, -- 6248
		h, -- 6248
		414, -- 6248
		420, -- 6248
		0, -- 6248
		44, -- 6248
		FLOOR_DECK -- 6248
	) -- 6248
	local s = self.room.scavenger -- 6250
	if s ~= nil then -- 6251
		local sx0 = self.scavX -- 6252
		self:drawBox( -- 6253
			draw, -- 6253
			w, -- 6253
			h, -- 6253
			sx0 - 12, -- 6253
			sx0 + 12, -- 6253
			0, -- 6253
			s.h - 14, -- 6253
			SCAV_BODY -- 6253
		) -- 6253
		self:drawBox( -- 6254
			draw, -- 6254
			w, -- 6254
			h, -- 6254
			sx0 - 7, -- 6254
			sx0 + 7, -- 6254
			s.h - 14, -- 6254
			s.h, -- 6254
			SCAV_HEAD -- 6254
		) -- 6254
		if self.scavState == "turn" then -- 6255
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 6256
			draw:drawSegment( -- 6257
				Vec2( -- 6257
					self:sx(sx0, w), -- 6257
					self:sy(s.h - 6, h) -- 6257
				), -- 6257
				Vec2( -- 6257
					self:sx(fx, w), -- 6257
					self:sy(s.h - 6, h) -- 6257
				), -- 6257
				self:px(1), -- 6257
				INK -- 6257
			) -- 6257
		end -- 6257
	end -- 6257
	if self.hasBottle then -- 6261
		local p = self.player -- 6262
		self:drawBottle( -- 6263
			draw, -- 6263
			w, -- 6263
			h, -- 6263
			p.x + p.facing * 10, -- 6263
			p.y + p.h * 0.62 -- 6263
		) -- 6263
	end -- 6263
	if self.bottleFly ~= nil then -- 6265
		self:drawBottle( -- 6266
			draw, -- 6266
			w, -- 6266
			h, -- 6266
			self.bottleFly.x, -- 6266
			self.bottleFly.y -- 6266
		) -- 6266
	end -- 6266
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6268
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 6269
		draw:drawCircle( -- 6270
			Vec2( -- 6270
				self:sx(self.bottleLandX, w), -- 6270
				self:sy(0, h) -- 6270
			), -- 6270
			self:px(r / ____exports.UNITS_PER_PX), -- 6270
			BRICK_LINE -- 6270
		) -- 6270
	end -- 6270
end -- 6237
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6274
	self:drawBox( -- 6275
		draw, -- 6275
		w, -- 6275
		h, -- 6275
		x - 3, -- 6275
		x + 3, -- 6275
		y - 10, -- 6275
		y, -- 6275
		BOTTLE -- 6275
	) -- 6275
end -- 6274
function Play.prototype.drawTrace(self, draw, w, h) -- 6278
	local t = self.trace -- 6279
	if t == nil or self.traceT <= 0 then -- 6280
		return -- 6281
	end -- 6281
	draw:drawSegment( -- 6283
		Vec2( -- 6284
			self:sx(t.x0, w), -- 6284
			self:sy(t.y0, h) -- 6284
		), -- 6284
		Vec2( -- 6285
			self:sx(t.x1, w), -- 6285
			self:sy(t.y1, h) -- 6285
		), -- 6285
		self:px(1), -- 6286
		t.hit and AIM_HIT or INK_DIM -- 6286
	) -- 6286
end -- 6278
function Play.prototype.drawAim(self, draw, w, h) -- 6289
	local v = self.view -- 6291
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6292
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6293
	local dot = self:px(1) -- 6294
	local arm = self:px(3) -- 6295
	local gap = self:px(1) -- 6296
	draw:drawSegment( -- 6297
		Vec2(gx - arm - gap, gy), -- 6297
		Vec2(gx - gap, gy), -- 6297
		dot / 2, -- 6297
		AIM -- 6297
	) -- 6297
	draw:drawSegment( -- 6298
		Vec2(gx + gap, gy), -- 6298
		Vec2(gx + arm + gap, gy), -- 6298
		dot / 2, -- 6298
		AIM -- 6298
	) -- 6298
	draw:drawSegment( -- 6299
		Vec2(gx, gy - arm - gap), -- 6299
		Vec2(gx, gy - gap), -- 6299
		dot / 2, -- 6299
		AIM -- 6299
	) -- 6299
	draw:drawSegment( -- 6300
		Vec2(gx, gy + gap), -- 6300
		Vec2(gx, gy + arm + gap), -- 6300
		dot / 2, -- 6300
		AIM -- 6300
	) -- 6300
	if self.room.key == "village" and self.hasBottle then -- 6303
		local p = self.player -- 6304
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6306
		local dir = ____end.x >= p.x and 1 or -1 -- 6307
		local x0 = p.x + dir * 10 -- 6308
		local y0 = p.y + p.h * 0.7 -- 6309
		local T = BOTTLE_FLY_TIME -- 6310
		local vx = (____end.x - x0) / T -- 6311
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6312
		local pxr = x0 -- 6313
		local pyr = y0 -- 6314
		local t = 1 -- 6315
		do -- 6315
			t = 1 -- 6316
			while t <= 12 do -- 6316
				local tt = t / 12 * T -- 6317
				local nx = x0 + vx * tt -- 6318
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6319
				draw:drawSegment( -- 6320
					Vec2( -- 6320
						self:sx(pxr, w), -- 6320
						self:sy(pyr, h) -- 6320
					), -- 6320
					Vec2( -- 6320
						self:sx(nx, w), -- 6320
						self:sy(ny, h) -- 6320
					), -- 6320
					self:px(1) / 2, -- 6320
					BOTTLE -- 6320
				) -- 6320
				pxr = nx -- 6321
				pyr = ny -- 6322
				t = t + 1 -- 6316
			end -- 6316
		end -- 6316
		draw:drawCircle( -- 6324
			Vec2( -- 6324
				self:sx(____end.x, w), -- 6324
				self:sy(____end.y + 2, h) -- 6324
			), -- 6324
			self:px(2), -- 6324
			BOTTLE -- 6324
		) -- 6324
	end -- 6324
end -- 6289
return ____exports -- 6289
