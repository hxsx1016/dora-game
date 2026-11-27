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
local makeActor, drawFigure, rayInterval, hitBox, drawCartShape, CHILD_W, CHILD_H, SOLDIER_W, SOLDIER_H, INK, CART_FILL, CLOTH -- 1
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
	if index < 0 or index >= #sp then -- 6330
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
	if not a.alive then -- 6346
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
	if direction == 0 then -- 6378
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
	if box.depth ~= nil then -- 6392
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
	if tick >= ____exports.GATE_COUNT_END then -- 61
		return 20 -- 62
	end -- 62
	if tick >= 1260 then -- 62
		return 19 -- 63
	end -- 63
	if tick >= 1080 then -- 63
		return 18 -- 64
	end -- 64
	if tick >= 480 then -- 64
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
	if zoom < 1 then -- 320
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
	if key == "prologue" then -- 350
		return "prologue-wait" -- 354
	end -- 354
	if key == "street" then -- 354
		return "street-run" -- 357
	end -- 357
	if key == "gate" then -- 357
		return "gate-idle" -- 360
	end -- 360
	if key == "gatepath" then -- 360
		return "gatepath-start" -- 363
	end -- 363
	if key == "forest" then -- 363
		return "forest-run" -- 366
	end -- 366
	if key == "tower" then -- 366
		return "tower-wait" -- 369
	end -- 369
	if key == "museum" then -- 369
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
	local story = self.run.story -- 695
	local savedEq = story.equippedWeapon -- 696
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 696
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 698
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 698
		self.equippedWeapon = savedEq -- 700
	else -- 700
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 702
	end -- 702
	self.isCampaign = wr.campaign ~= nil -- 704
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 705
	self:buildWorld() -- 706
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 709
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 711
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 712
	local soloRoom = wr.key == "museum" -- 714
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 715
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 716
	self.player = makeActor(wr, playerIdx) -- 717
	self.partner = makeActor(wr, partnerIdx) -- 718
	self.phase = phaseOf(wr.key) -- 719
	if soloRoom then -- 719
		local mp = self.archive.museumPhase -- 722
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 723
	end -- 723
	if wr.story ~= nil then -- 723
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 729
	end -- 729
	self.cam.x = self.player.x -- 731
	self.cam.y = self.player.y + CAM_LOOK_UP -- 732
	self.cartAxle = wr.cart.startX -- 733
	self.escort = __TS__New( -- 734
		Escort, -- 734
		safeAnchorX(wr.marks) -- 734
	) -- 734
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 735
	if self.isCampaign then -- 735
		self:setupCampaign() -- 737
	else -- 737
		self:buildEnemies() -- 739
	end -- 739
	if resume ~= nil and resume.checkpoint > 0 then -- 739
		self.checkpoint = resume.checkpoint -- 743
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 743
			self.cartAxle = self.room.cart.endX -- 745
			self.cartDocked = true -- 746
			self.player.x = self.ox + 380 -- 749
			self.player.y = 0 -- 750
			self.player.vy = 0 -- 751
			self.player.onGround = true -- 752
			self.cam.x = self.player.x -- 753
			self.cam.y = self.player.y + CAM_LOOK_UP -- 754
		end -- 754
	end -- 754
	self:restoreStory() -- 757
end -- 687
function Play.prototype.towerEndReady(self) -- 564
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 565
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 566
end -- 564
function Play.prototype.recipeViews(self) -- 770
	local out = {} -- 771
	local i = 0 -- 772
	do -- 772
		i = 0 -- 773
		while i < #CRAFT_RECIPES do -- 773
			local r = CRAFT_RECIPES[i + 1] -- 774
			local cost = {} -- 775
			if r.cost.wood ~= nil then -- 775
				cost.wood = r.cost.wood -- 777
			end -- 777
			if r.cost.bell ~= nil then -- 777
				cost.bell = r.cost.bell -- 780
			end -- 780
			out[#out + 1] = { -- 782
				id = r.id, -- 783
				name = r.name, -- 784
				desc = r.desc, -- 785
				enhancedEffect = r.enhancedEffect, -- 786
				cost = cost, -- 787
				crafted = self.run.story.craftedWeapon == r.id -- 788
			} -- 788
			i = i + 1 -- 773
		end -- 773
	end -- 773
	if self.archive.artifactOwned then -- 773
		out[#out + 1] = { -- 793
			id = ARTIFACT_WEAPON_ID, -- 794
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 795
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 796
			enhancedEffect = "light", -- 797
			cost = {}, -- 798
			crafted = true -- 799
		} -- 799
	end -- 799
	return out -- 802
end -- 770
function Play.prototype.syncCraftBench(self) -- 806
	local view = self.craftBench -- 807
	local inv = self.run.inventory -- 808
	view.inventory = { -- 809
		wood = inv.wood, -- 809
		bell = inv.bell, -- 809
		scrap = inv.scrap, -- 809
		wedge = inv.wedge, -- 809
		ammo = inv.ammo -- 809
	} -- 809
	view.recipes = self:recipeViews() -- 810
	view.equippedWeapon = self.equippedWeapon -- 811
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 812
	if view.justCraftedTimer > 0 then -- 812
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 814
	end -- 814
end -- 806
function Play.prototype.openCraftBench(self) -- 819
	if self.room.key ~= "escort3" or self.craftBench.active then -- 819
		return -- 821
	end -- 821
	self.craftBench.active = true -- 823
	self.carryOn = false -- 824
	self.run.story.carry = false -- 825
	self.player.vx = 0 -- 826
	self.player.vy = 0 -- 827
	self.craftBench.justCraftedTimer = 0 -- 828
	self:syncCraftBench() -- 829
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 830
	self:log("开工台") -- 831
	self:emit( -- 832
		"benchOpen", -- 832
		{ -- 832
			recipes = __TS__ArrayMap( -- 833
				self.craftBench.recipes, -- 833
				function(____, r) return r.id end -- 833
			), -- 833
			inventory = self.craftBench.inventory, -- 834
			carry = self.carryOn -- 835
		} -- 835
	) -- 835
end -- 819
function Play.prototype.closeCraftBench(self) -- 840
	if not self.craftBench.active then -- 840
		return -- 842
	end -- 842
	self.craftBench.active = false -- 844
	self.craftBench.justCraftedTimer = 0 -- 845
	self.carryOn = true -- 846
	self.run.story.carry = true -- 847
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 848
	self:log("离站背起") -- 849
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 850
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 850
		self:triggerDeferredEscort3Draft() -- 852
	end -- 852
end -- 840
function Play.prototype.triggerDeferredEscort3Draft(self) -- 857
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 857
		return false -- 859
	end -- 859
	if self.run.story.talents == nil then -- 859
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 862
	end -- 862
	local st = self.run.story.talents -- 864
	if not st.deferred and st.room == "escort3" then -- 864
		return false -- 866
	end -- 866
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 868
	if self.useEscortDeathSummary and #st.offers > 0 then -- 868
		self.talentModalActive = true -- 870
	end -- 870
	self.sessionDirty = true -- 872
	return #st.offers > 0 -- 873
end -- 857
function Play.prototype.openTalentDraft(self) -- 877
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 877
		self.talentModalActive = true -- 879
	end -- 879
end -- 877
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 887
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 887
		return false -- 889
	end -- 889
	local recipe = findRecipe(recipeId) -- 891
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 891
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 893
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 894
		return false -- 895
	end -- 895
	local missing = missingMaterials(self.run.inventory, recipe) -- 897
	if #missing > 0 then -- 897
		self:flashSet( -- 899
			"缺料 · " .. table.concat(missing, " / "), -- 899
			1.6 -- 899
		) -- 899
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 900
		return false -- 901
	end -- 901
	payMaterials(self.run.inventory, recipe) -- 903
	self.handledCraftRequests[requestId] = true -- 904
	self.run.story.craftedWeapon = recipe.id -- 905
	self.run.story.equippedWeapon = recipe.id -- 906
	self.equippedWeapon = recipe.id -- 907
	self.sessionDirty = true -- 908
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 909
	self.craftBench.firstCraftDone = true -- 910
	self:syncCraftBench() -- 911
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 912
	self:log("改制 " .. recipe.id) -- 913
	self:emit("benchCraft", { -- 914
		recipeId = recipe.id, -- 915
		weapon = recipe.id, -- 916
		effect = recipe.enhancedEffect, -- 917
		wood = self.run.inventory.wood, -- 918
		bell = self.run.inventory.bell -- 919
	}) -- 919
	return true -- 921
end -- 887
function Play.prototype.equipWeapon(self, weaponId) -- 925
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 926
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 926
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 928
		return false -- 929
	end -- 929
	self.equippedWeapon = weaponId -- 931
	self.run.story.equippedWeapon = weaponId -- 932
	self.sessionDirty = true -- 933
	self:syncCraftBench() -- 934
	self:flashSet( -- 935
		"已装备 " .. weaponNameOf(weaponId), -- 935
		1 -- 935
	) -- 935
	self:emit("benchEquip", {weapon = weaponId}) -- 936
	return true -- 937
end -- 925
function Play.prototype.toggleArtifactWeapon(self) -- 941
	if not self.archive.artifactOwned or self.childMode then -- 941
		return false -- 943
	end -- 943
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 943
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 946
		return self:equipWeapon(fallback) -- 947
	end -- 947
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 949
end -- 941
function Play.prototype.exportSession(self) -- 953
	self:syncStory() -- 954
	local story = self.run.story -- 955
	local inv = self.run.inventory -- 956
	local taken = {} -- 957
	for k in pairs(self.run.taken) do -- 958
		if self.run.taken[k] == true then -- 958
			taken[#taken + 1] = k -- 960
		end -- 960
	end -- 960
	local segments = {} -- 963
	for k in pairs(story.segments) do -- 964
		if story.segments[k] == true then -- 964
			segments[#segments + 1] = k -- 966
		end -- 966
	end -- 966
	local props = {} -- 969
	for k in pairs(self.run.props) do -- 970
		local st = self.run.props[k] -- 971
		if st ~= nil then -- 971
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 973
		end -- 973
	end -- 973
	local talentRanks = {} -- 982
	if story.talents ~= nil then -- 982
		local ti = 0 -- 984
		do -- 984
			ti = 0 -- 985
			while ti < #ALL_TALENTS do -- 985
				local tid = ALL_TALENTS[ti + 1] -- 986
				local rk = story.talents.ranks[tid] or 0 -- 987
				if rk > 0 then -- 987
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 989
				end -- 989
				ti = ti + 1 -- 985
			end -- 985
		end -- 985
	end -- 985
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 995
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 996
	local ____self_run_seed_6 = self.run.seed -- 997
	local ____story_route_7 = story.route -- 998
	local ____story_hp_8 = story.hp -- 999
	local ____story_maxHp_9 = story.maxHp -- 1000
	local ____story_hpAtGate_10 = story.hpAtGate -- 1001
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 1002
	local ____story_settled_12 = story.settled -- 1003
	local ____self_phase_13 = self.phase -- 1004
	local ____story_countTick_14 = story.countTick -- 1005
	local ____story_phaseTick_15 = story.phaseTick -- 1006
	local ____story_handTicks_16 = story.handTicks -- 1007
	local ____story_handDone_17 = story.handDone -- 1008
	local ____story_lineSaid_18 = story.lineSaid -- 1009
	local ____story_tied_19 = story.tied -- 1010
	local ____story_carry_20 = story.carry -- 1011
	local ____story_escortDone_21 = story.escortDone -- 1012
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 1013
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 1014
	local ____inv_wood_24 = inv.wood -- 1015
	local ____inv_bell_25 = inv.bell -- 1016
	local ____inv_scrap_26 = inv.scrap -- 1017
	local ____inv_wedge_27 = inv.wedge -- 1018
	local ____inv_ammo_28 = inv.ammo -- 1019
	local ____inv_shield_29 = inv.shield -- 1020
	local ____inv_pass_30 = inv.pass -- 1021
	local ____inv_quickbelt_31 = inv.quickbelt -- 1022
	local ____taken_32 = taken -- 1023
	local ____segments_33 = segments -- 1024
	local ____self_cartAxle_34 = self.cartAxle -- 1025
	local ____self_cartDocked_35 = self.cartDocked -- 1026
	local ____self_run_route_36 = self.run.route -- 1027
	local ____self_run_joined_37 = self.run.joined -- 1028
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 1029
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 1030
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 1031
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 1032
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1033
	local ____talentRanks_43 = talentRanks -- 1034
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1035
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1036
	local ____temp_0 -- 1037
	if story.talents ~= nil then -- 1037
		____temp_0 = story.talents.deferred -- 1037
	else -- 1037
		____temp_0 = false -- 1037
	end -- 1037
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1038
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1039
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1040
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1041
	local ____props_50 = props -- 1042
	local ____table_escortFailed_1 -- 1043
	if self.escortFailed then -- 1043
		____table_escortFailed_1 = nil -- 1043
	else -- 1043
		____table_escortFailed_1 = self.player.x -- 1043
	end -- 1043
	local ____table_escortFailed_2 -- 1044
	if self.escortFailed then -- 1044
		____table_escortFailed_2 = nil -- 1044
	else -- 1044
		____table_escortFailed_2 = self.player.y -- 1044
	end -- 1044
	local ____table_escortFailed_3 -- 1045
	if self.escortFailed then -- 1045
		____table_escortFailed_3 = nil -- 1045
	else -- 1045
		____table_escortFailed_3 = self.player.depth -- 1045
	end -- 1045
	return { -- 993
		roomKey = ____temp_4, -- 995
		checkpoint = ____temp_5, -- 996
		seed = ____self_run_seed_6, -- 997
		route = ____story_route_7, -- 998
		hp = ____story_hp_8, -- 999
		maxHp = ____story_maxHp_9, -- 1000
		hpAtGate = ____story_hpAtGate_10, -- 1001
		maxHpAtGate = ____story_maxHpAtGate_11, -- 1002
		settled = ____story_settled_12, -- 1003
		phase = ____self_phase_13, -- 1004
		countTick = ____story_countTick_14, -- 1005
		phaseTick = ____story_phaseTick_15, -- 1006
		handTicks = ____story_handTicks_16, -- 1007
		handDone = ____story_handDone_17, -- 1008
		lineSaid = ____story_lineSaid_18, -- 1009
		tied = ____story_tied_19, -- 1010
		carry = ____story_carry_20, -- 1011
		escortDone = ____story_escortDone_21, -- 1012
		craftedWeapon = ____story_craftedWeapon_22, -- 1013
		equippedWeapon = ____self_equippedWeapon_23, -- 1014
		wood = ____inv_wood_24, -- 1015
		bell = ____inv_bell_25, -- 1016
		scrap = ____inv_scrap_26, -- 1017
		wedge = ____inv_wedge_27, -- 1018
		ammo = ____inv_ammo_28, -- 1019
		shield = ____inv_shield_29, -- 1020
		pass = ____inv_pass_30, -- 1021
		quickbelt = ____inv_quickbelt_31, -- 1022
		taken = ____taken_32, -- 1023
		segments = ____segments_33, -- 1024
		cartAxle = ____self_cartAxle_34, -- 1025
		cartDocked = ____self_cartDocked_35, -- 1026
		campaignRoute = ____self_run_route_36, -- 1027
		joined = ____self_run_joined_37, -- 1028
		c1Latch = ____self_run_c1Latch_38, -- 1029
		c2Latch = ____self_run_c2Latch_39, -- 1030
		talentSeed = ____temp_40, -- 1031
		talentRoom = ____temp_41, -- 1032
		talentOffers = ____temp_42, -- 1033
		talentRanks = ____talentRanks_43, -- 1034
		escortAttempt = ____temp_44, -- 1035
		escortVariant = ____temp_45, -- 1036
		talentDeferred = ____temp_0, -- 1037
		talentVitality = ____temp_46, -- 1038
		talentReload = ____temp_47, -- 1039
		talentGuard = ____temp_48, -- 1040
		talentCraft = ____temp_49, -- 1041
		props = ____props_50, -- 1042
		playerX = ____table_escortFailed_1, -- 1043
		playerY = ____table_escortFailed_2, -- 1044
		playerDepth = ____table_escortFailed_3, -- 1045
		gateTick = self.gateTick, -- 1046
		hasBottle = self.hasBottle, -- 1047
		villagePassed = self.passed -- 1048
	} -- 1048
end -- 953
function Play.prototype.submitFeIntent(self, intent) -- 1056
	local kind = intent == nil and "" or intent.kind -- 1057
	if kind == "gateReunionHold" then -- 1057
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1057
			return false -- 1060
		end -- 1060
		local holding = intent.holding == true -- 1062
		self.intentGateReunionHold = holding -- 1063
		if not holding and self.phase == "gate-wait" then -- 1063
			if self.handTicks > 0 then -- 1063
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1066
			end -- 1066
			self.handTicks = 0 -- 1068
			self.handArmed = true -- 1069
		end -- 1069
		return true -- 1071
	end -- 1071
	if kind == "reloadOpen" then -- 1071
		local camp = self.room.campaign -- 1074
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1074
			return false -- 1076
		end -- 1076
		self:beginReload() -- 1078
		return self.reloadOpen -- 1079
	end -- 1079
	if kind == "reloadPathPreview" then -- 1079
		local path = intent.path -- 1082
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1083
	end -- 1083
	if kind == "reloadTapNode" then -- 1083
		local node = intent.node -- 1086
		if type(node) == "number" then -- 1086
			self:reloadTapNode(node) -- 1088
			return true -- 1089
		end -- 1089
		return false -- 1091
	end -- 1091
	if kind == "reloadPathCommit" then -- 1091
		local path = intent.path -- 1094
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1094
			local list = path -- 1096
			local i = 0 -- 1097
			do -- 1097
				i = 0 -- 1098
				while i < #list do -- 1098
					do -- 1098
						if i == 0 and list[i + 1] == RELOAD_START then -- 1098
							goto __continue85 -- 1100
						end -- 1100
						self:reloadTapNode(list[i + 1]) -- 1102
					end -- 1102
					::__continue85:: -- 1102
					i = i + 1 -- 1098
				end -- 1098
			end -- 1098
			return true -- 1104
		end -- 1104
		return false -- 1106
	end -- 1106
	if kind == "reloadCancel" then -- 1106
		self:closeReloadPuzzle() -- 1109
		return true -- 1110
	end -- 1110
	if kind == "craftSubmit" then -- 1110
		local recipeId = intent.recipeId -- 1113
		local requestId = intent.requestId -- 1114
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1114
			return self:craftAtBench(recipeId, requestId) -- 1116
		end -- 1116
		return false -- 1118
	end -- 1118
	if kind == "craftEquip" then -- 1118
		local weaponId = intent.weaponId -- 1121
		if type(weaponId) == "string" then -- 1121
			return self:equipWeapon(weaponId) -- 1123
		end -- 1123
		return false -- 1125
	end -- 1125
	if kind == "craftClose" then -- 1125
		self:closeCraftBench() -- 1128
		return true -- 1129
	end -- 1129
	if kind == "chooseTalent" then -- 1129
		local slot = intent.slot -- 1132
		if type(slot) == "number" then -- 1132
			return self:chooseTalent(slot) -- 1134
		end -- 1134
		return false -- 1136
	end -- 1136
	if kind == "wellPick" then -- 1136
		return self:pickWell() -- 1139
	end -- 1139
	if kind == "museumInteract" then -- 1139
		local target = type(intent.target) == "string" and intent.target or "" -- 1142
		if target == "well_pickup" or target == "well" then -- 1142
			return self:pickWell() -- 1144
		end -- 1144
		if self.room.key ~= "museum" then -- 1144
			return false -- 1147
		end -- 1147
		return self:triggerMuseumIntent(target) -- 1149
	end -- 1149
	return false -- 1151
end -- 1056
function Play.prototype.triggerMuseumIntent(self, target) -- 1155
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1156
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1159
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1160
	if self.phase == "museum-cabinet" then -- 1160
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1160
			self.pendingMuseumIntentTarget = "cabinet" -- 1163
			return true -- 1164
		end -- 1164
	end -- 1164
	if self.phase == "museum-hall" then -- 1164
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1164
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1169
			return true -- 1170
		end -- 1170
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1170
			self.pendingMuseumIntentTarget = "hall" -- 1173
			return true -- 1174
		end -- 1174
	end -- 1174
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1174
		self.pendingMuseumIntentTarget = "lamp" -- 1180
		return true -- 1181
	end -- 1181
	if self.phase == "museum-return" then -- 1181
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1181
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1186
			return true -- 1187
		end -- 1187
	end -- 1187
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1187
		self.pendingMuseumIntentTarget = "done" -- 1191
		return true -- 1192
	end -- 1192
	return false -- 1194
end -- 1155
function Play.prototype.captureCheckpoint(self, id) -- 1198
	local inv = self.run.inventory -- 1199
	self.checkpointSnap = { -- 1200
		id = id, -- 1201
		wood = inv.wood, -- 1202
		bell = inv.bell, -- 1203
		scrap = inv.scrap, -- 1204
		wedge = inv.wedge, -- 1205
		ammo = inv.ammo, -- 1206
		shield = inv.shield, -- 1207
		pass = inv.pass, -- 1208
		quickbelt = inv.quickbelt, -- 1209
		crafted = self.run.story.craftedWeapon, -- 1210
		equipped = self.equippedWeapon, -- 1211
		carry = self.carryOn -- 1212
	} -- 1212
	self.run.story.cp = self.checkpointSnap -- 1214
end -- 1198
function Play.prototype.applyCheckpointSnap(self, id) -- 1218
	local snap = self.run.story.cp -- 1219
	if snap == nil or snap.id ~= id then -- 1219
		return false -- 1221
	end -- 1221
	self.checkpointSnap = snap -- 1223
	local inv = self.run.inventory -- 1224
	inv.wood = snap.wood -- 1225
	inv.bell = snap.bell -- 1226
	inv.scrap = snap.scrap -- 1227
	inv.wedge = snap.wedge -- 1228
	inv.ammo = snap.ammo -- 1229
	inv.shield = snap.shield -- 1230
	inv.pass = snap.pass -- 1231
	inv.quickbelt = snap.quickbelt -- 1232
	self.run.story.craftedWeapon = snap.crafted -- 1233
	self.equippedWeapon = snap.equipped -- 1234
	self.run.story.equippedWeapon = snap.equipped -- 1235
	self.carryOn = snap.carry -- 1236
	self.run.story.carry = snap.carry -- 1237
	self.craftBench.active = false -- 1238
	self:syncCraftBench() -- 1239
	return true -- 1240
end -- 1218
function Play.prototype.restoreStory(self) -- 1243
	local story = self.run.story -- 1244
	if story == nil then -- 1244
		return -- 1246
	end -- 1246
	if story.maxHp > 0 then -- 1246
		self.maxHp = story.maxHp -- 1249
		self.hp = math.max( -- 1250
			1, -- 1250
			math.min(story.hp, story.maxHp) -- 1250
		) -- 1250
	end -- 1250
	self.storyRoute = story.route -- 1252
	self.storySettled = story.settled -- 1253
	self.hpAtGate = story.hpAtGate -- 1254
	self.maxHpAtGate = story.maxHpAtGate -- 1255
	self.handDone = story.handDone -- 1256
	self.lineSaid = story.lineSaid -- 1257
	self.tied = story.handDone -- 1258
	self.carryOn = story.carry or story.route == "soldier" and self.room.key == "escort1" -- 1259
	self.museumReturn = story.museumReturn -- 1260
	story.museumReturn = false -- 1261
	self.escortDone = story.escortDone -- 1262
	self:syncCraftBench() -- 1263
	if story.segments.outside_cart == true then -- 1263
		self.redCartPulled = true -- 1266
		local redBox = __TS__ArrayFind( -- 1267
			self.boxes, -- 1267
			function(____, b) return b.id == "outside_red_cart" end -- 1267
		) -- 1267
		if redBox ~= nil then -- 1267
			redBox.x0 = 430 -- 1269
			redBox.x1 = 474 -- 1270
		end -- 1270
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1270
			self.cartAxle = self.room.cart.endX -- 1273
			self.cartDocked = true -- 1274
		end -- 1274
	end -- 1274
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1277
	self.waterSeen = story.segments.water_lantern == true -- 1279
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1279
		self:applyCheckpointSnap(self.checkpoint) -- 1282
	end -- 1282
	if self.room.key == "tower" and story.route == "soldier" then -- 1282
		self.carryOn = false -- 1286
		self.run.story.carry = false -- 1287
		self.player.w = SOLDIER_W -- 1288
		self.player.h = SOLDIER_H -- 1289
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1290
		self.partner = { -- 1291
			x = math.max(self.ox + 408, self.player.x - 24), -- 1292
			y = 0, -- 1293
			depth = 0, -- 1294
			depthSpeed = 0, -- 1295
			vx = 0, -- 1296
			vy = 0, -- 1297
			w = CHILD_W, -- 1298
			h = CHILD_H, -- 1299
			onGround = true, -- 1300
			facing = 1, -- 1301
			crouch = false, -- 1302
			rollT = 0, -- 1303
			covered = false, -- 1304
			alive = true -- 1305
		} -- 1305
	end -- 1305
	if self.room.key == "tower" then -- 1305
		if story.segments.tower_door == true then -- 1305
			self:openTowerDoor() -- 1311
		end -- 1311
		self.towerHanded = story.segments.tower_handover == true -- 1313
		self.deskHold = 0 -- 1314
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1314
			self.phase = story.phase -- 1316
			self.phaseTick = 0 -- 1317
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1317
				self.player.x = self.ox + 605 -- 1319
				self.player.y = 0 -- 1320
				if story.route == "soldier" and self.partner.alive then -- 1320
					self.partner.x = self.ox + 568 -- 1322
					self.partner.y = 0 -- 1323
					self.partner.facing = 1 -- 1324
				end -- 1324
			end -- 1324
		end -- 1324
	end -- 1324
	if self.room.key == "prologue" then -- 1324
		local ph = story.phase -- 1331
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1331
			self.phase = ph -- 1333
			self.phaseTick = story.phaseTick -- 1334
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1335
			self.player.y = 0 -- 1336
			self.player.depth = 0 -- 1337
			self.player.vx = 0 -- 1338
			self.partner.x = self.ox + 300 -- 1339
			self.partner.y = 0 -- 1340
			self.partner.depth = 0 -- 1341
			self.partner.vx = 0 -- 1342
			self.partner.alive = true -- 1343
			if ph == "prologue-follow" then -- 1343
				self.partner.crouch = false -- 1345
				self.partner.h = CHILD_H -- 1346
			else -- 1346
				self.partner.crouch = true -- 1348
				self.partner.h = CHILD_CROUCH_H -- 1349
			end -- 1349
			self.cam.x = self.player.x -- 1351
		end -- 1351
		return -- 1353
	end -- 1353
	if self.room.key ~= "gate" then -- 1353
		return -- 1356
	end -- 1356
	local ____temp_51 -- 1358
	if self.room.story == nil then -- 1358
		____temp_51 = nil -- 1358
	else -- 1358
		____temp_51 = self.room.story.gate -- 1358
	end -- 1358
	local g = ____temp_51 -- 1358
	if g == nil then -- 1358
		return -- 1360
	end -- 1360
	if story.phase == "gate-send" then -- 1360
		self.phase = "gate-send" -- 1364
		self.gateTick = g.holdTicks -- 1365
		self.gateSpawned = 4 -- 1366
		self.enemies = {} -- 1367
		self.player.x = self.ox + g.doorX - 40 -- 1368
		self.player.y = 0 -- 1369
		self.player.depth = 0 -- 1370
		self.player.vx = 0 -- 1371
		self.player.vy = 0 -- 1372
		self.player.onGround = true -- 1373
		self.partner.x = self.ox + g.waitX -- 1374
		self.partner.y = 0 -- 1375
		self.partner.depth = 0 -- 1376
		self.partner.alive = true -- 1377
		self.cam.x = self.player.x -- 1378
		self.handTicks = 0 -- 1379
		self.handArmed = false -- 1380
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1381
		return -- 1382
	end -- 1382
	if not story.settled then -- 1382
		return -- 1385
	end -- 1385
	self.gateTick = g.holdTicks -- 1388
	self.gateSpawned = 4 -- 1389
	self.enemies = {} -- 1390
	if story.phase == "gate-count" or story.phase == "gate-walk" then -- 1390
		self.phase = story.phase -- 1392
		self.countTick = math.max(story.countTick, 0) -- 1393
		self:swapToChild(g.doorX + 30) -- 1394
		self.countPrevMove = 0 -- 1395
		self.countArmed = false -- 1396
		return -- 1397
	end -- 1397
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1397
		self.phase = story.phase -- 1400
		self.countTick = ____exports.GATE_COUNT_END -- 1401
		self.phaseTick = story.phaseTick -- 1402
		self:swapToChild(g.doorX + 30) -- 1403
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1404
			0, -- 1404
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1404
		) -- 1404
		self.handArmed = false -- 1405
	end -- 1405
end -- 1243
function Play.prototype.buildWorld(self) -- 1410
	local room = self.room -- 1411
	self.boxes = {} -- 1412
	self.floors = {} -- 1413
	local i = 0 -- 1414
	do -- 1414
		i = 0 -- 1415
		while i < #room.floors do -- 1415
			local f = room.floors[i + 1] -- 1416
			local ____self_floors_52 = self.floors -- 1416
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1417
			i = i + 1 -- 1415
		end -- 1415
	end -- 1415
	do -- 1415
		i = 0 -- 1419
		while i < #room.solids do -- 1419
			local s = room.solids[i + 1] -- 1420
			if not s.decorative then -- 1420
				local ____self_boxes_64 = self.boxes -- 1426
				local ____s_x_55 = s.x -- 1427
				local ____temp_56 = s.x + s.w -- 1427
				local ____s_y_57 = s.y -- 1427
				local ____temp_58 = s.y + s.h -- 1427
				local ____temp_53 -- 1428
				if room.depth == nil then -- 1428
					____temp_53 = nil -- 1428
				else -- 1428
					____temp_53 = s.depth -- 1428
				end -- 1428
				local ____temp_59 = s.passable == true -- 1429
				local ____s_label_60 = s.label -- 1429
				local ____s_id_61 = s.id -- 1430
				local ____temp_62 = s.soft == true -- 1430
				local ____temp_63 = s.hidden == true -- 1430
				local ____temp_54 -- 1431
				if s.breakable == nil then -- 1431
					____temp_54 = nil -- 1431
				else -- 1431
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1431
				end -- 1431
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1426
					x0 = ____s_x_55, -- 1427
					x1 = ____temp_56, -- 1427
					y0 = ____s_y_57, -- 1427
					y1 = ____temp_58, -- 1427
					depth = ____temp_53, -- 1428
					passable = ____temp_59, -- 1429
					label = ____s_label_60, -- 1429
					id = ____s_id_61, -- 1430
					soft = ____temp_62, -- 1430
					hidden = ____temp_63, -- 1430
					breakable = ____temp_54, -- 1431
					interact = s.interact -- 1432
				} -- 1432
			end -- 1432
			i = i + 1 -- 1419
		end -- 1419
	end -- 1419
	do -- 1419
		i = 0 -- 1436
		while i < #room.stairs do -- 1436
			local st = room.stairs[i + 1] -- 1437
			local n = st.steps + 1 -- 1438
			local stepW = (st.x1 - st.x0) / n -- 1439
			local k = 0 -- 1440
			do -- 1440
				k = 0 -- 1441
				while k < n do -- 1441
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1442
					local x0 = st.x0 + stepW * k -- 1443
					local ____self_boxes_68 = self.boxes -- 1446
					local ____temp_66 = x0 + stepW -- 1447
					local ____temp_67 = -8 -- 1447
					local ____temp_65 -- 1448
					if room.depth == nil then -- 1448
						____temp_65 = nil -- 1448
					else -- 1448
						____temp_65 = st.depth -- 1448
					end -- 1448
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1446
						x0 = x0, -- 1447
						x1 = ____temp_66, -- 1447
						y0 = ____temp_67, -- 1447
						y1 = y, -- 1447
						depth = ____temp_65, -- 1448
						passable = true -- 1449
					} -- 1449
					k = k + 1 -- 1441
				end -- 1441
			end -- 1441
			i = i + 1 -- 1436
		end -- 1436
	end -- 1436
end -- 1410
function Play.prototype.setupCampaign(self) -- 1459
	local wr = self.room -- 1460
	local c = wr.campaign -- 1461
	if c == nil then -- 1461
		return -- 1463
	end -- 1463
	self.roomStartTick = self.run.ticks -- 1465
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1465
		self.run.joined = true -- 1469
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1469
		local ____self_run_73 = self.run -- 1472
		local ____temp_72 -- 1472
		if wr.key == "s2-drygoods" then -- 1472
			local ____temp_71 = self.run.route ~= "drygoods" -- 1473
			if not ____temp_71 then -- 1473
				local ____opt_69 = self.run.props.s2_board -- 1473
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1473
			end -- 1473
			____temp_72 = ____temp_71 -- 1473
		else -- 1473
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1474
		end -- 1474
		____self_run_73.joined = ____temp_72 -- 1472
	end -- 1472
	local x = wr.minX + 60 -- 1476
	local y = 0 -- 1477
	local depth = 0 -- 1478
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1478
		x = wr.minX + 210 -- 1480
		depth = -32 -- 1481
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1481
		x = wr.minX + 40 -- 1483
		y = 32 -- 1484
		depth = 32 -- 1485
	end -- 1485
	self.player = { -- 1487
		x = x, -- 1488
		y = y, -- 1488
		depth = depth, -- 1488
		depthSpeed = 0, -- 1488
		vx = 0, -- 1488
		vy = 0, -- 1488
		w = SOLDIER_W, -- 1489
		h = SOLDIER_H, -- 1489
		onGround = y <= 0, -- 1489
		facing = 1, -- 1489
		crouch = false, -- 1489
		rollT = 0, -- 1489
		covered = false, -- 1489
		alive = true -- 1489
	} -- 1489
	self.partner = { -- 1491
		x = x + 60, -- 1492
		y = y, -- 1492
		depth = depth, -- 1492
		depthSpeed = 0, -- 1492
		vx = 0, -- 1492
		vy = 0, -- 1492
		w = CHILD_W, -- 1493
		h = CHILD_H, -- 1493
		onGround = y <= 0, -- 1493
		facing = 1, -- 1493
		crouch = false, -- 1493
		rollT = 0, -- 1493
		covered = false, -- 1493
		alive = true -- 1493
	} -- 1493
	self.cam.x = x -- 1495
	self.cam.y = y + CAM_LOOK_UP -- 1496
	self.phase = "run" -- 1497
	self.hp = self.maxHp -- 1498
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1498
		if self.run.story.talents == nil then -- 1498
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1501
		end -- 1501
		local st = self.run.story.talents -- 1503
		local variants = ESCORT_VARIANTS[wr.key] -- 1504
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1504
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1506
		else -- 1506
			st.variant = 0 -- 1508
		end -- 1508
		if wr.key == "escort3" then -- 1508
			if st.room ~= "escort3" then -- 1508
				st.room = "escort3" -- 1514
				st.deferred = true -- 1515
				st.offers = {} -- 1516
			end -- 1516
		else -- 1516
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1519
		end -- 1519
	end -- 1519
	self:buildEnemies() -- 1522
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1523
	local i = 0 -- 1524
	do -- 1524
		i = 0 -- 1525
		while i < #self.boxes do -- 1525
			do -- 1525
				local b = self.boxes[i + 1] -- 1526
				if b.id == nil then -- 1526
					goto __continue160 -- 1528
				end -- 1528
				local st = self.run.props[b.id] -- 1530
				if st ~= nil then -- 1530
					b.broken = st.broken -- 1532
					local ____temp_74 -- 1533
					if b.breakable == nil then -- 1533
						____temp_74 = nil -- 1533
					else -- 1533
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1533
					end -- 1533
					b.breakable = ____temp_74 -- 1533
					b.hidden = b.hidden == true and st.revealed ~= true -- 1534
					if b.hidden then -- 1534
						b.broken = true -- 1536
					end -- 1536
				elseif b.hidden == true then -- 1536
					b.broken = true -- 1540
				end -- 1540
			end -- 1540
			::__continue160:: -- 1540
			i = i + 1 -- 1525
		end -- 1525
	end -- 1525
	if wr.cart.bodyW > 0 then -- 1525
		self.cartAxle = wr.cart.startX -- 1544
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1544
			self.cartAxle = wr.cart.endX -- 1546
			self.cartDocked = true -- 1547
		end -- 1547
	end -- 1547
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1550
end -- 1459
function Play.prototype.log(self, line) -- 1553
	local ____self_run_log_75 = self.run.log -- 1553
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1554
	if #self.run.log > 120 then -- 1554
		table.remove(self.run.log, 1) -- 1556
	end -- 1556
end -- 1553
function Play.prototype.buildEnemies(self) -- 1560
	self.enemies = {} -- 1561
	if self.isCampaign then -- 1561
		local variants = ESCORT_VARIANTS[self.room.key] -- 1563
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1564
		local ____useVariant_79 -- 1569
		if useVariant then -- 1569
			local ____temp_78 = #variants - 1 -- 1570
			local ____opt_76 = self.run.story.talents -- 1570
			____useVariant_79 = math.max( -- 1570
				0, -- 1570
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1570
			) -- 1570
		else -- 1570
			____useVariant_79 = 0 -- 1571
		end -- 1571
		local vIdx = ____useVariant_79 -- 1569
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1572
		local i = 0 -- 1573
		do -- 1573
			i = 0 -- 1574
			while i < #spawnList do -- 1574
				local sp = spawnList[i + 1] -- 1575
				local kind = sp.kind or "gunner" -- 1576
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1577
				local sx = useVariant and self.ox + sp.x or sp.x -- 1578
				local ____self_enemies_80 = self.enemies -- 1578
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1579
					x = sx, -- 1580
					y = sp.y, -- 1580
					depth = sp.depth, -- 1580
					w = 26, -- 1580
					h = sp.h, -- 1580
					alive = true, -- 1580
					hitT = 0, -- 1580
					warnT = 0, -- 1580
					fireCd = 40, -- 1580
					kind = kind, -- 1581
					shieldHp = hp, -- 1581
					shieldHpMax = hp, -- 1581
					drop = sp.drop or "none", -- 1581
					homeX = sx, -- 1582
					swingT = 0, -- 1582
					awake = false, -- 1582
					squad = i -- 1582
				} -- 1582
				i = i + 1 -- 1574
			end -- 1574
		end -- 1574
		return -- 1585
	end -- 1585
	if self.room.key == "checkpoint" then -- 1585
		local ____self_enemies_81 = self.enemies -- 1585
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1588
			x = self.ox + 430, -- 1588
			y = 0, -- 1588
			w = 26, -- 1588
			h = 84, -- 1588
			alive = true, -- 1588
			hitT = 0, -- 1588
			warnT = 0, -- 1588
			fireCd = 0 -- 1588
		} -- 1588
		local ____self_enemies_82 = self.enemies -- 1588
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1589
			x = self.ox + 505, -- 1589
			y = 0, -- 1589
			w = 26, -- 1589
			h = 84, -- 1589
			alive = true, -- 1589
			hitT = 0, -- 1589
			warnT = 0, -- 1589
			fireCd = 0 -- 1589
		} -- 1589
		return -- 1590
	end -- 1590
	if self.room.key == "street" then -- 1590
		local ____self_enemies_83 = self.enemies -- 1590
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1594
			x = self.ox + 340, -- 1594
			y = 0, -- 1594
			w = 26, -- 1594
			h = 84, -- 1594
			alive = true, -- 1594
			hitT = 0, -- 1594
			warnT = 0, -- 1594
			fireCd = 0 -- 1594
		} -- 1594
		local ____self_enemies_84 = self.enemies -- 1594
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1595
			x = self.ox + 560, -- 1595
			y = 0, -- 1595
			w = 26, -- 1595
			h = 84, -- 1595
			alive = true, -- 1595
			hitT = 0, -- 1595
			warnT = 0, -- 1595
			fireCd = 0 -- 1595
		} -- 1595
	end -- 1595
end -- 1560
function Play.prototype.emit(self, name, data) -- 1601
	local ____self_events_85 = self.events -- 1601
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1602
	self.eventSeq = self.eventSeq + 1 -- 1603
	if #self.events > 256 then -- 1603
		table.remove(self.events, 1) -- 1605
	end -- 1605
end -- 1601
function Play.prototype.drainEvents(self) -- 1613
	local out = self.events -- 1614
	self.events = {} -- 1615
	return out -- 1616
end -- 1613
function Play.prototype.adoptEvents(self, events) -- 1625
	if #events == 0 then -- 1625
		return -- 1627
	end -- 1627
	local keep = {} -- 1629
	local i = 0 -- 1630
	do -- 1630
		i = 0 -- 1631
		while i < #events do -- 1631
			do -- 1631
				local e = events[i + 1] -- 1632
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1632
					goto __continue181 -- 1634
				end -- 1634
				keep[#keep + 1] = e -- 1636
			end -- 1636
			::__continue181:: -- 1636
			i = i + 1 -- 1631
		end -- 1631
	end -- 1631
	if #keep == 0 then -- 1631
		return -- 1639
	end -- 1639
	self.events = __TS__ArrayConcat(keep, self.events) -- 1641
	do -- 1641
		i = 0 -- 1642
		while i < #self.events do -- 1642
			self.events[i + 1].seq = i -- 1643
			i = i + 1 -- 1642
		end -- 1642
	end -- 1642
	self.eventSeq = #self.events -- 1645
end -- 1625
function Play.prototype.talentRank(self, talent) -- 1648
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1648
		return self.run.story.talents.ranks[talent] or 0 -- 1650
	end -- 1650
	return 0 -- 1652
end -- 1648
function Play.prototype.reloadNeedTicks(self) -- 1656
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1657
end -- 1656
function Play.prototype.getStoryTalentOffers(self) -- 1661
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1661
		return {} -- 1663
	end -- 1663
	local st = self.run.story.talents -- 1665
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1666
end -- 1661
function Play.prototype.getStoryTalentRanks(self) -- 1670
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1670
		return nil -- 1672
	end -- 1672
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1674
end -- 1670
function Play.prototype.getEscortAttempt(self) -- 1678
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1679
end -- 1678
function Play.prototype.chooseTalent(self, slot) -- 1682
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1682
		return false -- 1684
	end -- 1684
	local st = self.run.story.talents -- 1686
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1687
	if st == nil or talent == nil then -- 1687
		return false -- 1689
	end -- 1689
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1691
	st.offers = {} -- 1692
	self.talentModalActive = false -- 1693
	local extraMsg = "" -- 1694
	if talent == "vitality" then -- 1694
		self.maxHp = self.maxHp + 1 -- 1696
		self.hp = self.hp + 1 -- 1697
		self.run.story.maxHp = self.maxHp -- 1698
		self.run.story.hp = self.hp -- 1699
	elseif talent == "salvage" then -- 1699
		local inv = self.run.inventory -- 1701
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1701
			inv.wood = inv.wood + 1 -- 1703
			extraMsg = " · 得木纹筹×1" -- 1704
		else -- 1704
			inv.bell = inv.bell + 1 -- 1706
			extraMsg = " · 得铃纹筹×1" -- 1707
		end -- 1707
		self:syncCraftBench() -- 1709
	end -- 1709
	self.sessionDirty = true -- 1711
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1712
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1713
	return true -- 1714
end -- 1682
function Play.prototype.beginReload(self) -- 1721
	self.reloadT = self:reloadTicks() -- 1722
	local camp = self.room.campaign -- 1723
	if camp ~= nil and camp.reloadPuzzle == true then -- 1723
		self:openReloadPuzzle() -- 1725
	end -- 1725
end -- 1721
function Play.prototype.openReloadPuzzle(self) -- 1730
	self.reloadOpen = true -- 1731
	self.reloadAnswerTicks = 0 -- 1732
	self.reloadWorldTicks = 0 -- 1733
	self.reloadPath = {RELOAD_START} -- 1734
	self.reloadPendingEffect = "" -- 1735
	self.reloadTryCount = self.reloadTryCount + 1 -- 1736
	self:emit( -- 1737
		"reloadOpen", -- 1737
		{ -- 1737
			tryCount = self.reloadTryCount, -- 1737
			needTicks = self:reloadNeedTicks() -- 1737
		} -- 1737
	) -- 1737
end -- 1730
function Play.prototype.closeReloadPuzzle(self) -- 1741
	self.reloadOpen = false -- 1742
	self.reloadAnswerTicks = 0 -- 1743
	self.reloadWorldTicks = 0 -- 1744
	self.reloadPath = {RELOAD_START} -- 1745
	self.reloadPendingEffect = "" -- 1746
end -- 1741
function Play.prototype.reloadTapNode(self, node) -- 1753
	if not self.reloadOpen then -- 1753
		return -- 1755
	end -- 1755
	local path = self.reloadPath -- 1757
	local last = path[#path] -- 1758
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1758
		self.reloadPath = {RELOAD_START} -- 1760
		self:emit("reloadInvalid", {node = node, at = last}) -- 1761
		return -- 1762
	end -- 1762
	path[#path + 1] = node -- 1764
	if node ~= RELOAD_TARGET then -- 1764
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1766
		return -- 1767
	end -- 1767
	if not reloadPathValid(path) then -- 1767
		self.reloadPath = {RELOAD_START} -- 1770
		self:emit("reloadInvalid", {node = node, at = last}) -- 1771
		return -- 1772
	end -- 1772
	self.reloadPendingEffect = reloadEffectOf(path) -- 1774
	self.reloadOpen = false -- 1775
	self.reloadT = 0 -- 1776
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1777
	self:flashSet( -- 1780
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1780
		1.4 -- 1780
	) -- 1780
end -- 1753
function Play.prototype.consumeReloadEffect(self) -- 1784
	local e = self.reloadPendingEffect -- 1785
	if e ~= "" then -- 1785
		self.reloadPendingEffect = "" -- 1787
	end -- 1787
	return e -- 1789
end -- 1784
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1796
	if count == nil then -- 1796
		count = 1 -- 1796
	end -- 1796
	if delayTicks == nil then -- 1796
		delayTicks = 60 -- 1796
	end -- 1796
	local best = -1 -- 1797
	local bestD = 1000000000 -- 1798
	local i = 0 -- 1799
	local woken = {} -- 1800
	local n = 0 -- 1801
	while n < count do -- 1801
		best = -1 -- 1803
		bestD = 1000000000 -- 1804
		do -- 1804
			i = 0 -- 1805
			while i < #self.enemies do -- 1805
				do -- 1805
					if woken[i] == true then -- 1805
						goto __continue215 -- 1807
					end -- 1807
					local e = self.enemies[i + 1] -- 1809
					if not e.alive then -- 1809
						goto __continue215 -- 1811
					end -- 1811
					local d = math.abs(e.x - from.x) -- 1813
					if d < bestD then -- 1813
						bestD = d -- 1815
						best = i -- 1816
					end -- 1816
				end -- 1816
				::__continue215:: -- 1816
				i = i + 1 -- 1805
			end -- 1805
		end -- 1805
		if best < 0 then -- 1805
			break -- 1820
		end -- 1820
		woken[best] = true -- 1822
		local e = self.enemies[best + 1] -- 1823
		e.awake = true -- 1824
		e.warnT = 0 -- 1825
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1826
		n = n + 1 -- 1827
	end -- 1827
	if n == 0 then -- 1827
		return -- 1830
	end -- 1830
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1832
end -- 1796
function Play.prototype.reloadTicks(self) -- 1835
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1836
end -- 1835
function Play.prototype.update(self, dt, input) -- 1839
	self:syncCraftBench() -- 1840
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1840
		self:closeCraftBench() -- 1842
		return -- 1843
	end -- 1843
	if input.pause.pressed then -- 1843
		self.paused = not self.paused -- 1846
	end -- 1846
	if self.flashT > 0 then -- 1846
		self.flashT = self.flashT - dt -- 1849
		if self.flashT <= 0 then -- 1849
			self.flash = "" -- 1851
		end -- 1851
	end -- 1851
	if self.traceT > 0 then -- 1851
		self.traceT = self.traceT - dt -- 1855
		if self.traceT <= 0 then -- 1855
			self.trace = nil -- 1857
		end -- 1857
	end -- 1857
	if self.paused then -- 1857
		self:updateCamera(dt) -- 1861
		return -- 1862
	end -- 1862
	if self.escortFailed then -- 1862
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1866
		self:updateCamera(dt) -- 1867
		return -- 1868
	end -- 1868
	if self.craftBench.active then -- 1868
		self:updateCamera(dt) -- 1873
		return -- 1874
	end -- 1874
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1874
		self:updateCamera(dt) -- 1878
		return -- 1879
	end -- 1879
	if self.reloadOpen then -- 1879
		local needTicks = self:reloadNeedTicks() -- 1885
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1886
		if self.reloadAnswerTicks > needTicks then -- 1886
			self.reloadOpen = false -- 1888
			self.reloadPendingEffect = "" -- 1889
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1890
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1891
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1891
			self:updateCamera(dt) -- 1893
			return -- 1894
		else -- 1894
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1896
		end -- 1896
	end -- 1896
	self.ticks = self.ticks + 1 -- 1900
	if self.invulnT > 0 then -- 1900
		self.invulnT = self.invulnT - 1 -- 1904
	end -- 1904
	if self.isCampaign then -- 1904
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1904
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1907
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1908
	end -- 1908
	local p = self.player -- 1910
	self:stepPlayer(p, dt, input) -- 1911
	self:refreshCover(p, input) -- 1913
	if self.carryOn then -- 1913
		self:carryPose() -- 1915
	end -- 1915
	if self.isCampaign then -- 1915
		self:stepCampaign(dt, input) -- 1918
		if not self.carryOn then -- 1918
			self:stepCampaignPartner(dt) -- 1920
		end -- 1920
	end -- 1920
	self:stepEnemies(dt, input) -- 1925
	if not self.isCampaign then -- 1925
		self:stepStory(dt, input) -- 1927
		self:stepEscort(dt, input) -- 1928
		self:stepVillage(dt, input) -- 1929
		self:stepChase(dt, input) -- 1930
		self:stepInteract(dt, input) -- 1931
	end -- 1931
	self:updateGate() -- 1933
	self:updateCamera(dt) -- 1934
	self:syncStory() -- 1936
end -- 1839
function Play.prototype.underLowArch(self, a) -- 1943
	local arch = self.room.arch -- 1944
	if arch.h <= 0 then -- 1944
		return false -- 1946
	end -- 1946
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1946
		return false -- 1949
	end -- 1949
	local top = arch.y + arch.h -- 1951
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1952
end -- 1943
function Play.prototype.coverAt(self, a) -- 1959
	local best = nil -- 1960
	local bestGap = 24 -- 1961
	local half = a.w / 2 -- 1962
	local i = 0 -- 1963
	do -- 1963
		i = 0 -- 1964
		while i < #self.boxes do -- 1964
			do -- 1964
				local b = self.boxes[i + 1] -- 1965
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1965
					goto __continue248 -- 1967
				end -- 1967
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1967
					goto __continue248 -- 1970
				end -- 1970
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1972
				if gap < bestGap then -- 1972
					bestGap = gap -- 1974
					best = b -- 1975
				end -- 1975
			end -- 1975
			::__continue248:: -- 1975
			i = i + 1 -- 1964
		end -- 1964
	end -- 1964
	return best -- 1978
end -- 1959
function Play.prototype.nearCover(self, a) -- 1981
	return self:coverAt(a) ~= nil -- 1982
end -- 1981
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1986
	if enemy == nil then -- 1986
		return false -- 1988
	end -- 1988
	local fromRight = enemy.x >= a.x -- 1990
	local edge = fromRight and b.x0 or b.x1 -- 1991
	local ____fromRight_88 -- 1992
	if fromRight then -- 1992
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1992
	else -- 1992
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1993
	end -- 1993
	local between = ____fromRight_88 -- 1992
	local separation = enemy.x - a.x -- 1994
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1995
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1996
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1997
end -- 1986
function Play.prototype.nearestEnemy(self, a) -- 2000
	local best -- 2001
	local bestD = 1000000000 -- 2002
	local i = 0 -- 2003
	do -- 2003
		i = 0 -- 2004
		while i < #self.enemies do -- 2004
			do -- 2004
				local e = self.enemies[i + 1] -- 2005
				if not e.alive then -- 2005
					goto __continue257 -- 2007
				end -- 2007
				local d = math.abs(e.x - a.x) -- 2009
				if d < bestD then -- 2009
					bestD = d -- 2011
					best = e -- 2012
				end -- 2012
			end -- 2012
			::__continue257:: -- 2012
			i = i + 1 -- 2004
		end -- 2004
	end -- 2004
	return best -- 2015
end -- 2000
function Play.prototype.refreshCover(self, a, input) -- 2019
	if self.childMode then -- 2019
		self.coverNear = false -- 2021
		self.coverHug = false -- 2022
		self.coverEntity = "" -- 2023
		self.coverBlocking = false -- 2024
		a.covered = false -- 2025
		return -- 2026
	end -- 2026
	local b = self:coverAt(a) -- 2028
	self.coverNear = b ~= nil -- 2029
	a.covered = self.coverNear and input.cover.held -- 2030
	self.coverHug = a.covered -- 2031
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 2032
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2033
		b, -- 2033
		a, -- 2033
		self:nearestEnemy(a) -- 2033
	) -- 2033
end -- 2019
function Play.prototype.cartHandleInReach(self, a) -- 2037
	if a == nil then -- 2037
		a = self.player -- 2037
	end -- 2037
	local c = self.room.cart -- 2038
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2038
		return false -- 2040
	end -- 2040
	local handleX = self.cartAxle + c.handleOffset -- 2042
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 2043
end -- 2037
function Play.prototype.nearLowLedge(self, a) -- 2048
	local reach = 26 -- 2049
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2050
	local x1 = x0 + reach -- 2051
	local i = 0 -- 2052
	do -- 2052
		i = 0 -- 2053
		while i < #self.boxes do -- 2053
			do -- 2053
				local b = self.boxes[i + 1] -- 2054
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2054
					goto __continue266 -- 2056
				end -- 2056
				local rise = b.y1 - a.y -- 2058
				if rise > 0 and rise <= LEDGE_RISE then -- 2058
					return true -- 2060
				end -- 2060
			end -- 2060
			::__continue266:: -- 2060
			i = i + 1 -- 2053
		end -- 2053
	end -- 2053
	return false -- 2063
end -- 2048
function Play.prototype.stepPlayer(self, a, dt, input) -- 2066
	a.depthSpeed = 0 -- 2067
	if not a.alive then -- 2067
		return -- 2069
	end -- 2069
	local isChild = self.childMode -- 2071
	local lowArch = isChild and self:underLowArch(a) -- 2073
	if self:storyLocked() then -- 2073
		a.vx = 0 -- 2076
		a.crouch = isChild and lowArch -- 2077
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2078
		self:fallY(a, dt) -- 2079
		return -- 2080
	end -- 2080
	if not isChild and self.escort.state == "calming" then -- 2080
		a.crouch = false -- 2084
		a.h = SOLDIER_H -- 2085
		a.vx = 0 -- 2086
		self:fallY(a, dt) -- 2087
		return -- 2088
	end -- 2088
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2090
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2091
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2092
	local nearCover = not isChild and self:nearCover(a) -- 2093
	a.covered = nearCover and input.cover.held -- 2094
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2096
	if a.rollT > 0 then -- 2096
		a.rollT = a.rollT - dt -- 2100
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2101
		a.vx = a.facing * rollSpd -- 2102
		self:slideX(a, a.vx * dt) -- 2103
		self:fallY(a, dt) -- 2104
		if a.rollT <= 0 then -- 2104
			self:flashSet("翻滚结束", 0.5) -- 2106
		end -- 2106
		return -- 2108
	end -- 2108
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2111
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2111
		if input.moveX ~= 0 then -- 2111
			a.facing = input.moveX > 0 and 1 or -1 -- 2114
		end -- 2114
		if self:nearLowLedge(a) then -- 2114
			a.vy = SOLDIER_JUMP -- 2118
			a.onGround = false -- 2119
			self:flashSet("翻上去", 0.3) -- 2120
			return -- 2121
		end -- 2121
		a.rollT = ROLL_TIME -- 2123
		self:flashSet("翻滚", 0.3) -- 2124
		return -- 2125
	end -- 2125
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2128
	if isChild then -- 2128
		if input.cover.held then -- 2128
			speed = CHILD_SLOW -- 2131
		end -- 2131
		if a.crouch then -- 2131
			speed = CHILD_SLOW -- 2134
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2134
			speed = CHILD_SPEED * 1.22 -- 2138
		end -- 2138
	else -- 2138
		if self:isEscortRoom() then -- 2138
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2142
		end -- 2142
		if a.covered then -- 2142
			speed = speed * 0.45 -- 2145
		end -- 2145
	end -- 2145
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2150
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2151
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2153
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2155
	if dir ~= 0 then -- 2155
		a.facing = dir > 0 and 1 or -1 -- 2157
	end -- 2157
	a.vx = dir * speed * diagonal -- 2159
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2159
		a.vy = CHILD_JUMP -- 2163
		a.onGround = false -- 2164
		self:flashSet("跳", 0.25) -- 2165
	end -- 2165
	local previousDepth = a.depth -- 2169
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2170
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2171
	self:slideX(a, a.vx * dt) -- 2172
	self:fallY(a, dt) -- 2173
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2173
		self:shoot(a) -- 2177
	end -- 2177
	local ____temp_91 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2180
	if ____temp_91 then -- 2180
		local ____opt_89 = self.room.campaign -- 2180
		____temp_91 = (____opt_89 and ____opt_89.reloadPuzzle) == true -- 2180
	end -- 2180
	if ____temp_91 and input.flare.pressed then -- 2180
		self:beginReload() -- 2182
	end -- 2182
end -- 2066
function Play.prototype.stepPartner(self, p, dt) -- 2187
	local a = self.partner -- 2188
	if not a.alive then -- 2188
		return -- 2190
	end -- 2190
	a.crouch = false -- 2192
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2193
	a.vx = 0 -- 2194
	a.depthSpeed = 0 -- 2195
	self:fallY(a, dt) -- 2196
end -- 2187
function Play.prototype.stepEscort(self, dt, input) -- 2203
	local a = self.partner -- 2204
	a.depthSpeed = 0 -- 2205
	if not a.alive then -- 2205
		return -- 2207
	end -- 2207
	if self.room.key == "gatepath" then -- 2207
		if self.carryOn then -- 2207
			return -- 2212
		end -- 2212
		local p = self.player -- 2215
		a.depth = p.depth -- 2216
		a.facing = p.facing -- 2217
		a.crouch = false -- 2218
		a.h = CHILD_H -- 2219
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2220
		a.y = p.y -- 2221
		a.vy = 0 -- 2222
		a.vx = p.vx -- 2223
		a.onGround = p.onGround -- 2224
		return -- 2225
	end -- 2225
	if not self:escortOn() then -- 2225
		a.vx = 0 -- 2228
		self:fallY(a, dt) -- 2229
		return -- 2230
	end -- 2230
	local p = self.player -- 2232
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2233
	local hadKnock1 = self.escort.knock1 -- 2234
	local hadKnock2 = self.escort.knock2 -- 2235
	self.calmConsumed = self.escort:update( -- 2236
		input, -- 2236
		p.x, -- 2236
		p.facing, -- 2236
		a.x, -- 2236
		dist -- 2236
	) -- 2236
	if not hadKnock1 and self.escort.knock1 then -- 2236
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2239
	end -- 2239
	if not hadKnock2 and self.escort.knock2 then -- 2239
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2242
	end -- 2242
	a.crouch = self.escort.crouchPose -- 2244
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2245
	if not self.escort.stopped then -- 2245
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2247
		local previousDepth = a.depth -- 2248
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2249
		local distance = math.max( -- 2250
			-travel, -- 2250
			math.min(travel, targetDepth - previousDepth) -- 2250
		) -- 2250
		self:slideDepth(a, distance) -- 2251
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2252
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2252
			a.vy = CHILD_JUMP -- 2254
			a.onGround = false -- 2255
		end -- 2255
	end -- 2255
	local dir = self.escort:moveDir(a.x) -- 2258
	a.vx = dir * CHILD_SPEED -- 2259
	if dir ~= 0 then -- 2259
		a.facing = dir -- 2261
		local before = a.x -- 2262
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2263
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2263
			a.vy = CHILD_JUMP -- 2266
			a.onGround = false -- 2267
		end -- 2267
	end -- 2267
	self:fallY(a, dt) -- 2270
end -- 2203
function Play.prototype.escortOn(self) -- 2274
	if self.room.key == "checkpoint" then -- 2274
		return true -- 2276
	end -- 2276
	if self.room.key == "gatepath" then -- 2276
		return true -- 2279
	end -- 2279
	if self.room.key == "prologue" then -- 2279
		return self.phase == "prologue-follow" -- 2282
	end -- 2282
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2282
		return true -- 2286
	end -- 2286
	return self.room.key == "street" -- 2288
end -- 2274
function Play.prototype.storyLocked(self) -- 2292
	if self.caughtT > 0 then -- 2292
		return true -- 2294
	end -- 2294
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2294
		return true -- 2298
	end -- 2298
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2298
		return true -- 2301
	end -- 2301
	if self.room.key == "gate" and (self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2301
		return true -- 2304
	end -- 2304
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2304
		return true -- 2307
	end -- 2307
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2307
		return true -- 2310
	end -- 2310
	if self.craftBench.active then -- 2310
		return true -- 2314
	end -- 2314
	return false -- 2316
end -- 2292
function Play.prototype.swapToChild(self, x) -- 2320
	local tmp = self.player -- 2321
	self.player = self.partner -- 2322
	self.partner = tmp -- 2323
	self.childMode = true -- 2324
	self.player.alive = true -- 2325
	self.player.x = self.ox + x -- 2326
	self.player.y = 0 -- 2327
	self.player.depth = 0 -- 2328
	self.player.depthSpeed = 0 -- 2329
	self.player.vy = 0 -- 2330
	self.player.vx = 0 -- 2331
	self.player.onGround = true -- 2332
	self.player.crouch = false -- 2333
	self.player.h = CHILD_H -- 2334
	self.player.facing = 1 -- 2335
	self.partner.alive = true -- 2336
	self.cam.x = self.player.x -- 2337
end -- 2320
function Play.prototype.swapToSoldier(self, x, childX) -- 2341
	local tmp = self.player -- 2342
	self.player = self.partner -- 2343
	self.partner = tmp -- 2344
	self.childMode = false -- 2345
	self.player.alive = true -- 2346
	self.player.x = self.ox + x -- 2347
	self.player.y = 0 -- 2348
	self.player.depth = 0 -- 2349
	self.player.depthSpeed = 0 -- 2350
	self.player.vy = 0 -- 2351
	self.player.vx = 0 -- 2352
	self.player.onGround = true -- 2353
	self.player.crouch = false -- 2354
	self.player.h = SOLDIER_H -- 2355
	self.player.facing = 1 -- 2356
	self.partner.alive = true -- 2357
	self.partner.x = self.ox + childX -- 2358
	self.partner.y = 0 -- 2359
	self.partner.depth = 0 -- 2360
	self.partner.depthSpeed = 0 -- 2361
	self.partner.vx = 0 -- 2362
	self.partner.vy = 0 -- 2363
	self.partner.onGround = true -- 2364
	self.partner.crouch = true -- 2365
	self.partner.h = CHILD_CROUCH_H -- 2366
	self.cam.x = self.player.x -- 2367
end -- 2341
function Play.prototype.stepStory(self, dt, input) -- 2371
	if self.room.key == "prologue" then -- 2371
		self:stepPrologue(dt, input) -- 2373
	elseif self.room.key == "street" then -- 2373
		self:stepStreet(dt, input) -- 2375
	elseif self.room.key == "gate" then -- 2375
		self:stepGate(dt, input) -- 2377
	elseif self.room.key == "gatepath" then -- 2377
		self:stepGatePath() -- 2379
	elseif self.room.key == "tower" then -- 2379
		self:stepTower(dt, input) -- 2381
	elseif self.room.key == "museum" then -- 2381
		self:stepMuseum(dt, input) -- 2383
	end -- 2383
end -- 2371
function Play.prototype.canPersistProgress(self) -- 2389
	return not self.isCampaign and self.run.source == "official" -- 2390
end -- 2389
function Play.prototype.wellWindow(self) -- 2394
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2395
end -- 2394
function Play.prototype.nearWell(self) -- 2400
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2401
end -- 2400
function Play.prototype.pickWell(self) -- 2409
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2409
		return false -- 2411
	end -- 2411
	self.phase = "prologue-well" -- 2413
	self.phaseTick = 0 -- 2414
	self.wellOpen = false -- 2415
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2416
	self:log("旧井拾取") -- 2417
	return true -- 2418
end -- 2409
function Play.prototype.stepPrologue(self, dt, input) -- 2421
	local child = self.partner -- 2422
	if self.museumReturn then -- 2422
		self.museumReturn = false -- 2425
		self.phase = "prologue-wait" -- 2426
		self.phaseTick = 0 -- 2427
		self.player.x = self.ox + 260 -- 2428
		self.player.y = 0 -- 2429
		self.player.depth = 0 -- 2430
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2431
	end -- 2431
	if self.phase == "prologue-wake" then -- 2431
		self.introTick = self.introTick + 1 -- 2435
		if self.introTick == 60 then -- 2435
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2437
		end -- 2437
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2437
			self.phase = "prologue-shadow" -- 2440
			self.introTick = 0 -- 2441
			self:flashSet("门缝里两道影子", 1.2) -- 2442
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2443
		end -- 2443
		return -- 2445
	end -- 2445
	if self.phase == "prologue-shadow" then -- 2445
		self.introTick = self.introTick + 1 -- 2448
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2448
			self.phase = "prologue-escape" -- 2451
			self.introTick = 0 -- 2452
			self.escapeRemaining = self.escapeDuration -- 2453
			self.escapeRetryCount = 0 -- 2454
			self:swapToChild(100) -- 2455
			self:flashSet( -- 2456
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2456
				1.6 -- 2456
			) -- 2456
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2457
		end -- 2457
		return -- 2461
	end -- 2461
	if self.phase == "prologue-escape" then -- 2461
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2464
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2464
			self.phase = "prologue-hide" -- 2467
			self.introTick = 0 -- 2468
			self.player.vx = 0 -- 2469
			self.player.crouch = true -- 2470
			self.player.h = CHILD_CROUCH_H -- 2471
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2472
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2473
			return -- 2477
		end -- 2477
		if self.escapeRemaining <= 0 then -- 2477
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2481
			self.player.x = self.ox + 100 -- 2482
			self.player.y = 0 -- 2483
			self.player.depth = 0 -- 2484
			self.player.vx = 0 -- 2485
			self.player.vy = 0 -- 2486
			self.escapeRemaining = self.escapeDuration -- 2487
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2488
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2489
			return -- 2490
		end -- 2490
		return -- 2492
	end -- 2492
	if self.phase == "prologue-hide" then -- 2492
		self.introTick = self.introTick + 1 -- 2495
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2495
			self.phase = "prologue-wait" -- 2498
			self.phaseTick = 0 -- 2499
			self.introTick = 0 -- 2500
			self:swapToSoldier(260, 300) -- 2501
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2502
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2503
		end -- 2503
		return -- 2505
	end -- 2505
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2508
	if self.phase == "prologue-wait" then -- 2508
		child.crouch = true -- 2510
		child.h = CHILD_CROUCH_H -- 2511
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2511
			self:pickWell() -- 2513
			return -- 2514
		end -- 2514
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2514
			self.archive.museumPhase = "well_reflect" -- 2519
			self.archiveDirty = true -- 2520
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2521
			return -- 2522
		end -- 2522
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2524
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2526
		if near and input.interact.pressed then -- 2526
			self.phase = "prologue-give" -- 2528
			self.phaseTick = 0 -- 2529
			self:flashSet("递出针套", 1) -- 2530
		end -- 2530
		return -- 2532
	end -- 2532
	if self.phase == "prologue-well" then -- 2532
		self.phaseTick = self.phaseTick + 1 -- 2536
		if self.phaseTick == 12 then -- 2536
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2538
		elseif self.phaseTick >= 30 then -- 2538
			self.phase = "prologue-wait" -- 2540
			self.phaseTick = 0 -- 2541
			self.wellTaken = true -- 2542
			self.wellOpen = false -- 2543
			self.run.archive.artifactOwned = true -- 2544
			self.archiveDirty = true -- 2545
			self:emit("artifactFound", { -- 2546
				x = self.ox + self.wellX, -- 2547
				y = 0, -- 2547
				room = "prologue", -- 2547
				once = true, -- 2547
				source = self.run.source -- 2548
			}) -- 2548
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2550
			self:log("井底取到时间穿梭器") -- 2551
		end -- 2551
		return -- 2553
	end -- 2553
	if self.phase == "prologue-give" then -- 2553
		self.phaseTick = self.phaseTick + 1 -- 2556
		if self.phaseTick == 12 then -- 2556
			self:flashSet("针套递过去", 0.7) -- 2558
		elseif self.phaseTick == 36 then -- 2558
			self:flashSet("纸条塞进针套", 0.9) -- 2560
		elseif self.phaseTick >= 60 then -- 2560
			self.phase = "prologue-follow" -- 2562
			self.phaseTick = 0 -- 2563
			child.crouch = false -- 2564
			child.h = CHILD_H -- 2565
			self:flashSet("她跟上了", 1.2) -- 2566
		end -- 2566
		return -- 2568
	end -- 2568
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2568
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2572
		self:requestRoom(next, "序章跟到门口") -- 2573
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2574
	end -- 2574
end -- 2421
function Play.prototype.stepStreet(self, dt, input) -- 2579
	local p = self.player -- 2580
	local c = self.partner -- 2581
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2581
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2583
		self:requestRoom(next, "两人都到街尾") -- 2584
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2585
	end -- 2585
end -- 2579
function Play.prototype.stepGate(self, dt, input) -- 2590
	local ____temp_92 -- 2591
	if self.room.story == nil then -- 2591
		____temp_92 = nil -- 2591
	else -- 2591
		____temp_92 = self.room.story.gate -- 2591
	end -- 2591
	local g = ____temp_92 -- 2591
	if g == nil then -- 2591
		return -- 2593
	end -- 2593
	local p = self.player -- 2595
	if self.phase == "gate-idle" then -- 2595
		local a = self.partner -- 2598
		local gap = g.waitX - a.x -- 2599
		if math.abs(gap) > 3 then -- 2599
			a.facing = gap > 0 and 1 or -1 -- 2601
			a.vx = a.facing * CHILD_SPEED -- 2602
			local beforeX = a.x -- 2603
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2604
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2604
				a.vy = CHILD_JUMP -- 2606
				a.onGround = false -- 2607
			end -- 2607
			self:fallY(a, dt) -- 2609
		else -- 2609
			a.vx = 0 -- 2611
			a.x = g.waitX -- 2612
		end -- 2612
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2615
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2616
		if self.gateNeedConfirm then -- 2616
			if not input.interact.held then -- 2616
				self.gateRestartArmed = true -- 2621
			end -- 2621
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2621
				self.gateNeedConfirm = false -- 2624
				self.gateRestartArmed = true -- 2625
				self.phase = "gate-hold" -- 2626
				self.gateTick = 0 -- 2627
				self.gateSpawned = 0 -- 2628
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2629
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2630
			end -- 2630
			return -- 2632
		end -- 2632
		if atWinch and atWait then -- 2632
			self.phase = "gate-hold" -- 2635
			self.gateTick = 0 -- 2636
			self.gateSpawned = 0 -- 2637
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2638
		end -- 2638
		return -- 2640
	end -- 2640
	if self.phase == "gate-hold" then -- 2640
		self.gateTick = self.gateTick + 1 -- 2643
		local marks = {0, 540, 900, 1500} -- 2645
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2645
			local idx = self.gateSpawned -- 2647
			local ____self_enemies_93 = self.enemies -- 2647
			____self_enemies_93[#____self_enemies_93 + 1] = { -- 2648
				x = self.ox + 620 + idx * 62, -- 2649
				y = 0, -- 2649
				w = 26, -- 2649
				h = 84, -- 2649
				alive = true, -- 2650
				hitT = 0, -- 2650
				warnT = 0, -- 2650
				fireCd = 90 + idx * 45 -- 2650
			} -- 2650
			self.gateSpawned = self.gateSpawned + 1 -- 2652
			self:flashSet( -- 2653
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2653
				0.9 -- 2653
			) -- 2653
		end -- 2653
		if self.gateTick == 900 then -- 2653
			self:flashSet("棚布落下", 1) -- 2656
		elseif self.gateTick == 2100 then -- 2656
			self:flashSet("门底透进冷光了", 1) -- 2658
		end -- 2658
		if self.gateTick >= g.holdTicks then -- 2658
			self:captureGateBlood() -- 2663
			self.phase = "gate-send" -- 2664
			self.phaseTick = 0 -- 2665
			self.enemies = {} -- 2667
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2668
		end -- 2668
		return -- 2670
	end -- 2670
	if self.phase == "gate-send" then -- 2670
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2673
		if near and input.interact.pressed then -- 2673
			self:commitRoute() -- 2676
			self:swapToChild(g.doorX + 30) -- 2677
			self.phase = "gate-count" -- 2678
			self.countTick = 0 -- 2679
			self.countArmed = false -- 2681
			self.countPrevMove = input.moveX -- 2682
			self:flashSet("门开了 · 送她出去", 1.8) -- 2683
		end -- 2683
		return -- 2685
	end -- 2685
	if self.phase == "gate-count" then -- 2685
		self.countTick = self.countTick + 1 -- 2688
		if self.countTick == 360 then -- 2688
			self:flashSet("门关上", 0.9) -- 2690
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2690
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2692
			if self.storyRoute == "soldier" then -- 2692
				self.phase = "gate-wait" -- 2698
				self.phaseTick = 0 -- 2699
				self.knocks = 1 -- 2700
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2701
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2703
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2704
			else -- 2704
				self:flashSet("数到二十", 2.2) -- 2706
			end -- 2706
		end -- 2706
		local prevMove = self.countPrevMove -- 2711
		self.countPrevMove = input.moveX -- 2712
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2712
			if prevMove <= 0 and input.moveX > 0 then -- 2712
				self.countArmed = true -- 2715
			end -- 2715
			if self.countArmed and input.moveX > 0 then -- 2715
				self.phase = "gate-walk" -- 2718
				self.phaseTick = 0 -- 2719
				self:flashSet("她迈出第一步", 1.4) -- 2720
				self:emit("storyExit", { -- 2721
					route = "child", -- 2721
					via = "walk", -- 2721
					countTick = self.countTick, -- 2721
					hp = self.hp, -- 2721
					maxHp = self.maxHp -- 2721
				}) -- 2721
			end -- 2721
		end -- 2721
		return -- 2724
	end -- 2724
	if self.phase == "gate-wait" then -- 2724
		self.phaseTick = self.phaseTick + 1 -- 2728
		if self.phaseTick == 12 then -- 2728
			self.knocks = 2 -- 2730
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2731
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2732
		end -- 2732
		local held = input.interact.held or self.intentGateReunionHold -- 2734
		if not held then -- 2734
			if self.handTicks > 0 then -- 2734
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2737
			end -- 2737
			self.handTicks = 0 -- 2739
			self.handArmed = true -- 2740
			return -- 2741
		end -- 2741
		if self.handArmed then -- 2741
			self.handTicks = self.handTicks + 1 -- 2744
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2744
				self.intentGateReunionHold = false -- 2746
				self.phase = "gate-hand" -- 2747
				self.phaseTick = 0 -- 2748
				self.handDone = true -- 2749
				self.tied = true -- 2750
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2751
				if not self.lineSaid then -- 2751
					self.lineSaid = true -- 2753
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2754
				end -- 2754
				self:flashSet("我们走吧。", 3) -- 2756
			end -- 2756
		end -- 2756
		return -- 2759
	end -- 2759
	if self.phase == "gate-hand" then -- 2759
		self.phaseTick = self.phaseTick + 1 -- 2763
		if self.phaseTick == 30 then -- 2763
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2765
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2765
			self:emit("storyExit", { -- 2767
				route = "soldier", -- 2767
				via = "hand", -- 2767
				handTicks = self.handTicks, -- 2767
				hp = self.hp, -- 2767
				maxHp = self.maxHp -- 2767
			}) -- 2767
			self:requestRoom("gatepath", "牵手同行") -- 2768
		end -- 2768
		return -- 2770
	end -- 2770
	if self.phase == "gate-walk" then -- 2770
		if self.player.x >= g.exitX then -- 2770
			self:requestRoom("outside", "走出城门") -- 2775
			self:flashSet("出城门 · 城外", 1.4) -- 2776
		end -- 2776
	end -- 2776
end -- 2590
function Play.prototype.captureGateBlood(self) -- 2785
	self.hpAtGate = self.hp -- 2786
	self.maxHpAtGate = self.maxHp -- 2787
end -- 2785
function Play.prototype.commitRoute(self) -- 2794
	if self.storySettled then -- 2794
		return -- 2796
	end -- 2796
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2798
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2799
	self.hpAtGate = hp -- 2800
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2801
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2802
	self.storySettled = true -- 2803
	self.sessionDirty = true -- 2804
	self:emit("storyRouteLocked", { -- 2805
		route = self.storyRoute, -- 2806
		hp = self.hp, -- 2806
		maxHp = self.maxHp, -- 2806
		hpAtGate = self.hpAtGate, -- 2807
		maxHpAtGate = self.maxHpAtGate -- 2807
	}) -- 2807
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2809
end -- 2794
function Play.prototype.syncStory(self) -- 2813
	local s = self.run.story -- 2814
	if s == nil then -- 2814
		return -- 2816
	end -- 2816
	s.hp = self.hp -- 2818
	s.maxHp = self.maxHp -- 2819
	s.route = self.storyRoute -- 2820
	s.settled = self.storySettled -- 2821
	s.hpAtGate = self.hpAtGate -- 2822
	s.maxHpAtGate = self.maxHpAtGate -- 2823
	s.handDone = self.handDone -- 2824
	s.lineSaid = self.lineSaid -- 2825
	s.tied = self.tied -- 2826
	s.carry = self.carryOn -- 2827
	s.museumReturn = self.museumReturn -- 2828
	s.escortDone = self.escortDone -- 2829
	s.craftedWeapon = self.run.story.craftedWeapon -- 2830
	s.equippedWeapon = self.equippedWeapon -- 2831
	s.ending = self.run.story.ending -- 2832
	if self.room.key == "gate" then -- 2832
		s.phase = self.phase -- 2834
		s.countTick = self.countTick -- 2835
		s.phaseTick = self.phaseTick -- 2836
		s.handTicks = self.handTicks -- 2837
	end -- 2837
	if self.room.key == "prologue" then -- 2837
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2837
			s.phase = self.phase -- 2842
			s.phaseTick = self.phaseTick -- 2843
		end -- 2843
	end -- 2843
	if self.room.key == "tower" then -- 2843
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2843
			s.phase = self.phase -- 2849
			s.phaseTick = self.phaseTick -- 2850
		end -- 2850
	end -- 2850
end -- 2813
function Play.prototype.stepGatePath(self) -- 2856
	local ____temp_94 -- 2857
	if self.room.story == nil then -- 2857
		____temp_94 = nil -- 2857
	else -- 2857
		____temp_94 = self.room.story.gatepath -- 2857
	end -- 2857
	local gp = ____temp_94 -- 2857
	if self.phase == "gatepath-start" then -- 2857
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2857
			self.carryOn = true -- 2860
			self.phase = "gatepath-carry" -- 2861
			self.phaseTick = 0 -- 2862
			self.pathDone = true -- 2863
			self.escortDone = false -- 2864
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2865
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2866
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2867
		end -- 2867
		return -- 2869
	end -- 2869
	if self.phase == "gatepath-carry" then -- 2869
		self.phaseTick = self.phaseTick + 1 -- 2872
		if self.phaseTick == 20 then -- 2872
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2874
		end -- 2874
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2874
			self:requestRoom(gp.next, "背负进首战") -- 2877
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2878
		end -- 2878
	end -- 2878
end -- 2856
function Play.prototype.carryPose(self) -- 2887
	local p = self.player -- 2888
	local a = self.partner -- 2889
	a.alive = true -- 2890
	a.x = p.x - p.facing * 12 -- 2891
	a.y = p.y + 26 -- 2892
	a.depth = p.depth -- 2893
	a.vx = p.vx -- 2894
	a.vy = 0 -- 2895
	a.onGround = true -- 2896
	a.crouch = false -- 2897
	a.h = CHILD_CROUCH_H -- 2898
	a.facing = p.facing -- 2899
end -- 2887
function Play.prototype.stepMuseum(self, dt, input) -- 2907
	self.partner.alive = false -- 2908
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2909
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2912
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2913
	local intentTarget = self.pendingMuseumIntentTarget -- 2914
	self.pendingMuseumIntentTarget = "" -- 2915
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2916
	if self.phase == "museum-cabinet" then -- 2916
		if atCase and interactHit or intentTarget == "cabinet" then -- 2916
			self.phase = "museum-hall" -- 2919
			self.phaseTick = 0 -- 2920
			if self:canPersistProgress() then -- 2920
				self.archive.museumPhase = "hall_walk" -- 2922
				self.archiveDirty = true -- 2923
			end -- 2923
			self:emit( -- 2925
				"museumStep", -- 2925
				{ -- 2925
					step = "cabinet", -- 2925
					x = self.ox + mu.cabinetX, -- 2925
					persisted = self:canPersistProgress() -- 2925
				} -- 2925
			) -- 2925
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2926
		end -- 2926
		return -- 2928
	end -- 2928
	if self.phase == "museum-hall" then -- 2928
		if intentTarget == "lamp_direct" and nearLamp then -- 2928
			self:emit( -- 2932
				"museumStep", -- 2932
				{ -- 2932
					step = "hall", -- 2932
					x = self.ox + mu.hallX, -- 2932
					persisted = self:canPersistProgress() -- 2932
				} -- 2932
			) -- 2932
			self.phase = "museum-return" -- 2933
			self.phaseTick = 0 -- 2934
			if self:canPersistProgress() then -- 2934
				self.archive.museumPhase = "return_cabinet" -- 2936
				self.archiveDirty = true -- 2937
			end -- 2937
			self:emit( -- 2939
				"museumStep", -- 2939
				{ -- 2939
					step = "lamp", -- 2939
					x = self.ox + mu.lampX, -- 2939
					persisted = self:canPersistProgress() -- 2939
				} -- 2939
			) -- 2939
			self:flashSet("灯 · 转向西窗", 1.8) -- 2940
			return -- 2941
		end -- 2941
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2941
			self.phase = "museum-lamp" -- 2944
			self.phaseTick = 0 -- 2945
			if self:canPersistProgress() then -- 2945
				self.archive.museumPhase = "lamp_turn" -- 2947
				self.archiveDirty = true -- 2948
			end -- 2948
			self:emit( -- 2950
				"museumStep", -- 2950
				{ -- 2950
					step = "hall", -- 2950
					x = self.ox + mu.hallX, -- 2950
					persisted = self:canPersistProgress() -- 2950
				} -- 2950
			) -- 2950
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2951
		end -- 2951
		return -- 2953
	end -- 2953
	if self.phase == "museum-lamp" then -- 2953
		if nearLamp and interactHit then -- 2953
			self.phase = "museum-return" -- 2957
			self.phaseTick = 0 -- 2958
			if self:canPersistProgress() then -- 2958
				self.archive.museumPhase = "return_cabinet" -- 2960
				self.archiveDirty = true -- 2961
			end -- 2961
			self:emit( -- 2963
				"museumStep", -- 2963
				{ -- 2963
					step = "lamp", -- 2963
					x = self.ox + mu.lampX, -- 2963
					persisted = self:canPersistProgress() -- 2963
				} -- 2963
			) -- 2963
			self:flashSet("灯 · 转向西窗", 1.8) -- 2964
		end -- 2964
		return -- 2966
	end -- 2966
	if self.phase == "museum-return" then -- 2966
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2966
			self.phase = "museum-knock" -- 2970
			self.phaseTick = 0 -- 2971
			self:emit( -- 2972
				"museumStep", -- 2972
				{ -- 2972
					step = "knock", -- 2972
					count = 1, -- 2972
					x = self.ox + mu.cabinetX, -- 2972
					persisted = self:canPersistProgress() -- 2972
				} -- 2972
			) -- 2972
			self:flashSet("回柜边 · 第一下", 0.8) -- 2973
		end -- 2973
		return -- 2975
	end -- 2975
	if self.phase == "museum-knock" then -- 2975
		self.phaseTick = self.phaseTick + 1 -- 2978
		if self.phaseTick == 8 then -- 2978
			self:emit( -- 2980
				"museumStep", -- 2980
				{ -- 2980
					step = "knock", -- 2980
					count = 2, -- 2980
					x = self.ox + mu.cabinetX, -- 2980
					persisted = self:canPersistProgress() -- 2980
				} -- 2980
			) -- 2980
			self:flashSet("回柜边 · 第二下", 0.8) -- 2981
		elseif self.phaseTick >= 36 then -- 2981
			self.phase = "museum-done" -- 2983
			self.phaseTick = 0 -- 2984
			if self:canPersistProgress() then -- 2984
				self.archive.museumSeen = true -- 2986
				self.archive.museumPhase = "done" -- 2987
				self.archiveDirty = true -- 2988
			end -- 2988
			self:emit( -- 2990
				"museumDone", -- 2990
				{ -- 2990
					steps = 4, -- 2990
					museumSeen = self.archive.museumSeen, -- 2990
					persisted = self:canPersistProgress() -- 2990
				} -- 2990
			) -- 2990
			self:flashSet("回柜边 · 灯还亮着", 2) -- 2991
			self:log("博物馆 · 回柜边") -- 2992
		end -- 2992
		return -- 2994
	end -- 2994
	if interactHit then -- 2994
		self.museumReturn = true -- 2997
		self:requestRoom("prologue", "回柜边") -- 2998
	end -- 2998
end -- 2907
function Play.prototype.openTowerDoor(self) -- 3002
	self.towerDoorOpen = true -- 3003
	do -- 3003
		local i = 0 -- 3004
		while i < #self.boxes do -- 3004
			if self.boxes[i + 1].id == "tower_door" then -- 3004
				self.boxes[i + 1].hidden = true -- 3006
			end -- 3006
			i = i + 1 -- 3004
		end -- 3004
	end -- 3004
	self.run.story.segments.tower_door = true -- 3009
end -- 3002
function Play.prototype.stepTower(self, dt, input) -- 3012
	local ____temp_95 -- 3013
	if self.room.story == nil then -- 3013
		____temp_95 = nil -- 3013
	else -- 3013
		____temp_95 = self.room.story.tower -- 3013
	end -- 3013
	local t = ____temp_95 -- 3013
	if t == nil then -- 3013
		return -- 3015
	end -- 3015
	if self.storyRoute == "soldier" and self.partner.alive then -- 3015
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3019
		local gap = targetX - self.partner.x -- 3020
		if math.abs(gap) > 2 then -- 3020
			local dir = gap > 0 and 1 or -1 -- 3022
			local stepDist = math.min( -- 3023
				math.abs(gap), -- 3023
				SOLDIER_SPEED * dt -- 3023
			) -- 3023
			self.partner.facing = dir -- 3024
			self.partner.vx = dir * SOLDIER_SPEED -- 3025
			local ____self_partner_96, ____x_97 = self.partner, "x" -- 3025
			____self_partner_96[____x_97] = ____self_partner_96[____x_97] + dir * stepDist -- 3026
		else -- 3026
			self.partner.vx = 0 -- 3028
			self.partner.facing = 1 -- 3029
		end -- 3029
	end -- 3029
	if self.phase == "tower-wait" then -- 3029
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3033
		if near and input.interact.pressed then -- 3033
			self.phase = "tower-knock" -- 3035
			self.phaseTick = 0 -- 3036
			self.knocks = 1 -- 3037
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3038
			self:flashSet("叩两下 · 第一声", 0.6) -- 3039
		end -- 3039
		return -- 3041
	end -- 3041
	if self.phase == "tower-knock" then -- 3041
		self.phaseTick = self.phaseTick + 1 -- 3044
		if self.phaseTick == 12 then -- 3044
			self.knocks = 2 -- 3046
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3047
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3048
		elseif self.phaseTick >= t.knockTicks then -- 3048
			self:openTowerDoor() -- 3050
			self.phase = "tower-enter" -- 3051
			self.phaseTick = 0 -- 3052
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3053
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3054
		end -- 3054
		return -- 3056
	end -- 3056
	if self.phase == "tower-enter" then -- 3056
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3056
			self.phase = "tower-desk" -- 3060
			self.phaseTick = 0 -- 3061
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3062
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3063
		end -- 3063
		return -- 3065
	end -- 3065
	if self.phase == "tower-desk" then -- 3065
		local deskX = self.ox + 605 -- 3068
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3069
		if not near or not input.interact.held then -- 3069
			self.deskHold = 0 -- 3071
			return -- 3072
		end -- 3072
		self.deskHold = self.deskHold + 1 -- 3074
		if self.deskHold == 12 then -- 3074
			self:flashSet("针套 · 放在桌上", 1) -- 3076
		elseif self.deskHold == 24 then -- 3076
			self:flashSet("指南针 · 压住纸条", 1) -- 3078
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3078
			self.towerHanded = true -- 3080
			self.deskHold = 0 -- 3081
			self.run.story.segments.tower_handover = true -- 3082
			self.phase = "tower-given" -- 3083
			self.phaseTick = 0 -- 3084
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3085
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3090
		end -- 3090
		return -- 3092
	end -- 3092
	if self.phase == "tower-given" then -- 3092
		local soldier = self.storyRoute == "soldier" -- 3097
		self.phaseTick = self.phaseTick + 1 -- 3098
		if self.phaseTick == 60 then -- 3098
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3100
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3101
		elseif self.phaseTick == 120 then -- 3101
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3103
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3103
			self.phase = "tower-end" -- 3105
			self.phaseTick = 0 -- 3106
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3107
			if not self.run.finished then -- 3107
				self.run.finished = true -- 3109
				local ending = soldier and "reunion" or "lamp" -- 3110
				self.run.story.ending = ending -- 3111
				local ____soldier_98 -- 3114
				if soldier then -- 3114
					____soldier_98 = self.run.story.segments.escort5 == true -- 3115
				else -- 3115
					____soldier_98 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3116
				end -- 3116
				local played = ____soldier_98 -- 3114
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3117
				if official then -- 3117
					if soldier then -- 3117
						self.run.archive.soldierCleared = true -- 3121
					else -- 3121
						self.run.archive.childCleared = true -- 3123
					end -- 3123
					self.archiveDirty = true -- 3125
				end -- 3125
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3127
				self:emit("endingReached", { -- 3128
					route = soldier and "soldier" or "child", -- 3129
					ending = ending, -- 3130
					official = official, -- 3131
					source = self.run.source, -- 3132
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3133
					childCleared = self.run.archive.childCleared, -- 3134
					soldierCleared = self.run.archive.soldierCleared, -- 3135
					artifactOwned = self.run.archive.artifactOwned, -- 3136
					equipped = self.equippedWeapon -- 3137
				}) -- 3137
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3139
			end -- 3139
		end -- 3139
		return -- 3142
	end -- 3142
	self.phaseTick = self.phaseTick + 1 -- 3144
	local held = input.interact.held or input.retry.held -- 3145
	if self.towerEndMustRelease then -- 3145
		if not held then -- 3145
			self.towerEndMustRelease = false -- 3148
		end -- 3148
		return -- 3150
	end -- 3150
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3152
	if self.phaseTick < waitTicks then -- 3152
		if input.interact.pressed or input.retry.pressed then -- 3152
			self.towerEndMustRelease = held -- 3155
		end -- 3155
		return -- 3157
	end -- 3157
	if input.interact.pressed or input.retry.pressed then -- 3157
		self.restartStory = true -- 3161
		self:requestRoom("prologue", "片尾再玩") -- 3162
		self:flashSet("回到序章", 1.4) -- 3163
	end -- 3163
end -- 3012
function Play.prototype.stepChase(self, dt, input) -- 3168
	if self.caughtT > 0 then -- 3168
		self.caughtT = self.caughtT - dt -- 3170
		if self.caughtT <= 0 then -- 3170
			self:recoverFromCaught() -- 3172
		end -- 3172
		return -- 3174
	end -- 3174
	if self.room.key == "village" then -- 3174
		self:stepScavChase() -- 3177
	elseif self.room.key == "forest" then -- 3177
		self:stepForestRoute() -- 3179
		self:stepDog(dt) -- 3180
		if self.player.x >= self.ox + 1450 then -- 3180
			self:requestRoom("tower", "到林缘北塔") -- 3183
			self:flashSet("林缘 · 北塔", 1.4) -- 3184
		end -- 3184
	end -- 3184
end -- 3168
function Play.prototype.stepScavChase(self) -- 3190
	local s = self.room.scavenger -- 3191
	if s == nil then -- 3191
		return -- 3193
	end -- 3193
	local p = self.player -- 3195
	if self.passed and p.x > self.ox + 440 then -- 3195
		if self.scavChase then -- 3195
			self.scavChase = false -- 3199
			self.scavState = "back" -- 3200
			self.scavT = 0 -- 3201
		end -- 3201
		return -- 3203
	end -- 3203
	local dx = p.x - self.scavX -- 3205
	local dist = math.abs(dx) -- 3206
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3207
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3208
	if not self.scavChase then -- 3208
		if visible then -- 3208
			self.scavSee = self.scavSee + 1 -- 3211
			if self.scavSee >= 24 then -- 3211
				self.scavChase = true -- 3213
				self.scavState = "chase" -- 3214
				self.scavTargetX = p.x -- 3215
				self:flashSet("他看见你了", 1.2) -- 3216
			end -- 3216
		else -- 3216
			self.scavSee = 0 -- 3219
		end -- 3219
		return -- 3221
	end -- 3221
	if hidden then -- 3221
		self.scavSee = 0 -- 3225
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3226
		self.scavT = self.scavT - 1 -- 3227
		if self.scavT <= 0 then -- 3227
			self.scavChase = false -- 3229
			self.scavState = "patrol" -- 3230
			self:flashSet("他失去了目标", 1) -- 3231
		end -- 3231
		return -- 3233
	end -- 3233
	local dir = p.x > self.scavX and 1 or -1 -- 3236
	self.scavX = self.scavX + dir * 96 / 60 -- 3237
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3237
		self:caught() -- 3239
		return -- 3240
	end -- 3240
end -- 3190
function Play.prototype.stepDog(self, dt) -- 3245
	local ____temp_99 -- 3246
	if self.room.story == nil then -- 3246
		____temp_99 = nil -- 3246
	else -- 3246
		____temp_99 = self.room.story.dog -- 3246
	end -- 3246
	local dog = ____temp_99 -- 3246
	if dog == nil then -- 3246
		return -- 3248
	end -- 3248
	local p = self.player -- 3250
	local ox = self.ox -- 3251
	local dist = math.abs(p.x - self.dogX) -- 3252
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3253
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3254
	local sheltered = inBurrowCover or inBrushCover -- 3258
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3259
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3260
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3261
	if self.dogState == "patrol" then -- 3261
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3263
		if self.dogX < dog.x0 then -- 3263
			self.dogX = dog.x0 -- 3265
			self.dogDir = 1 -- 3266
		elseif self.dogX > dog.x1 then -- 3266
			self.dogX = dog.x1 -- 3268
			self.dogDir = -1 -- 3269
		end -- 3269
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3271
		local twigOffsets = {235, 455, 865, 1115} -- 3272
		local nearTwig = false -- 3273
		local ti = 0 -- 3274
		do -- 3274
			ti = 0 -- 3275
			while ti < #twigOffsets do -- 3275
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3275
					nearTwig = true -- 3277
					break -- 3278
				end -- 3278
				ti = ti + 1 -- 3275
			end -- 3275
		end -- 3275
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3281
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3281
			self.dogState = "ear" -- 3283
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3284
			self.dogTargetX = p.x -- 3285
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3286
		end -- 3286
		return -- 3288
	end -- 3288
	if self.dogState == "ear" then -- 3288
		if sheltered then -- 3288
			self.dogState = "sniff" -- 3292
			self.dogT = 45 -- 3293
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3294
			return -- 3295
		end -- 3295
		self.dogT = self.dogT - 1 -- 3297
		if self.dogT <= 0 then -- 3297
			self.dogState = "chase" -- 3299
			self.dogTargetX = p.x -- 3300
			self:flashSet("狗追来了", 1.4) -- 3301
		end -- 3301
		return -- 3303
	end -- 3303
	if self.dogState == "chase" then -- 3303
		local dir = p.x > self.dogX and 1 or -1 -- 3306
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3307
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3307
			self:caught() -- 3309
			self.dogState = "sniff" -- 3310
			self.dogT = 60 -- 3311
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3311
			self.dogState = "sniff" -- 3313
			self.dogT = 60 -- 3314
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3315
		end -- 3315
		return -- 3317
	end -- 3317
	if self.dogState == "sniff" then -- 3317
		self.dogT = self.dogT - 1 -- 3320
		if self.dogT <= 0 then -- 3320
			self.dogState = "back" -- 3322
		end -- 3322
		return -- 3324
	end -- 3324
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3327
	self.dogX = self.dogX + dir * dog.speed * dt -- 3328
	if math.abs(self.dogX - dog.x0) < 2 then -- 3328
		self.dogX = dog.x0 -- 3330
		self.dogState = "patrol" -- 3331
	end -- 3331
end -- 3245
function Play.prototype.stepForestRoute(self) -- 3336
	local p = self.player -- 3337
	local ox = self.ox -- 3338
	if self.forestPath == "" then -- 3338
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3338
			self.forestPath = "burrow" -- 3341
			self.run.story.segments.forest_burrow = true -- 3342
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3343
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3344
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3344
			self.forestPath = "ditch" -- 3346
			self.run.story.segments.forest_ditch = true -- 3347
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3348
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3349
		end -- 3349
	end -- 3349
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3349
		self.waterSeen = true -- 3353
		self.run.story.segments.water_lantern = true -- 3354
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3355
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3356
	end -- 3356
end -- 3336
function Play.prototype.caught(self) -- 3360
	self.caughtT = 1 -- 3361
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3362
end -- 3360
function Play.prototype.recoverFromCaught(self) -- 3366
	local p = self.player -- 3367
	p.x = self.ox + 140 -- 3368
	p.y = 0 -- 3369
	p.vy = 0 -- 3370
	p.vx = 0 -- 3371
	p.onGround = true -- 3372
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3372
		self.scavX = self.room.scavenger.x0 -- 3374
		self.scavState = "patrol" -- 3375
		self.scavSee = 0 -- 3376
		self.scavChase = false -- 3377
		self.scavT = 0 -- 3378
	end -- 3378
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3378
		self.dogX = self.room.story.dog.x0 -- 3381
		self.dogState = "patrol" -- 3382
		self.dogT = 0 -- 3383
	end -- 3383
	self.cam.x = p.x -- 3385
	self.cam.y = p.y + CAM_LOOK_UP -- 3386
	self:flashSet("回到安全点", 1.2) -- 3387
end -- 3366
function Play.prototype.updateGate(self) -- 3391
	if self.room.key ~= "checkpoint" then -- 3391
		self.gateOpen = false -- 3393
		return -- 3394
	end -- 3394
	local function inZone(x) -- 3396
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3396
	end -- 3396
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3397
end -- 3391
function Play.prototype.addItem(self, kind) -- 3403
	local inv = self.run.inventory -- 3404
	if kind == "shield" then -- 3404
		if inv.shield >= TOOL_CAP then -- 3404
			return false -- 3407
		end -- 3407
		inv.shield = inv.shield + 1 -- 3409
		return true -- 3410
	end -- 3410
	if kind == "wedge" then -- 3410
		if inv.wedge >= CONSUMABLE_CAP then -- 3410
			return false -- 3414
		end -- 3414
		inv.wedge = inv.wedge + 1 -- 3416
		return true -- 3417
	end -- 3417
	if kind == "ammo" then -- 3417
		if inv.ammo >= CONSUMABLE_CAP then -- 3417
			return false -- 3421
		end -- 3421
		inv.ammo = inv.ammo + 1 -- 3423
		return true -- 3424
	end -- 3424
	if kind == "scrap" then -- 3424
		inv.scrap = inv.scrap + 1 -- 3428
		return true -- 3429
	end -- 3429
	if kind == "wood" then -- 3429
		inv.wood = inv.wood + 1 -- 3432
		return true -- 3433
	end -- 3433
	if kind == "bell" then -- 3433
		inv.bell = inv.bell + 1 -- 3436
		return true -- 3437
	end -- 3437
	if kind == "pass" then -- 3437
		inv.pass = inv.pass + 1 -- 3440
		return true -- 3441
	end -- 3441
	if kind == "quickbelt" then -- 3441
		inv.quickbelt = inv.quickbelt + 1 -- 3444
		return true -- 3445
	end -- 3445
	return false -- 3447
end -- 3403
function Play.prototype.findBox(self, id) -- 3450
	local i = 0 -- 3451
	do -- 3451
		i = 0 -- 3452
		while i < #self.boxes do -- 3452
			if self.boxes[i + 1].id == id then -- 3452
				return self.boxes[i + 1] -- 3454
			end -- 3454
			i = i + 1 -- 3452
		end -- 3452
	end -- 3452
	return nil -- 3457
end -- 3450
function Play.prototype.findWedgeTarget(self) -- 3461
	local best = nil -- 3462
	local bestD = 0 -- 3463
	local i = 0 -- 3464
	do -- 3464
		i = 0 -- 3465
		while i < #self.boxes do -- 3465
			do -- 3465
				local b = self.boxes[i + 1] -- 3466
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3466
					goto __continue527 -- 3468
				end -- 3468
				if not self:nearBox(b, 26) then -- 3468
					goto __continue527 -- 3471
				end -- 3471
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3473
				if best == nil or d < bestD then -- 3473
					best = b -- 3475
					bestD = d -- 3476
				end -- 3476
			end -- 3476
			::__continue527:: -- 3476
			i = i + 1 -- 3465
		end -- 3465
	end -- 3465
	return best -- 3479
end -- 3461
function Play.prototype.stepCraft(self, input) -- 3487
	local inv = self.run.inventory -- 3488
	local required = math.max( -- 3489
		6, -- 3489
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3489
	) -- 3489
	if self.craftT > 0 then -- 3489
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3489
			self.craftT = 0 -- 3493
			self:flashSet("制作中断", 0.8) -- 3494
			return true -- 3495
		end -- 3495
		self.craftT = self.craftT + 1 -- 3497
		if self.craftT >= required then -- 3497
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3497
				inv.scrap = inv.scrap - 1 -- 3500
				inv.wedge = inv.wedge + 1 -- 3501
				self:flashSet("制得木楔", 1.2) -- 3502
				self:log("制木楔") -- 3503
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3504
			end -- 3504
			self.craftT = 0 -- 3506
		end -- 3506
		return true -- 3508
	end -- 3508
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3508
		self.craftT = 1 -- 3511
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3512
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3513
		return true -- 3514
	end -- 3514
	return false -- 3516
end -- 3487
function Play.prototype.nearBox(self, b, reach) -- 3519
	local p = self.player -- 3520
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3521
end -- 3519
function Play.prototype.findInteract(self) -- 3527
	local p = self.player -- 3528
	local best = nil -- 3529
	local bestD = 1000000000 -- 3530
	local i = 0 -- 3531
	do -- 3531
		i = 0 -- 3532
		while i < #self.boxes do -- 3532
			do -- 3532
				local b = self.boxes[i + 1] -- 3533
				if b.interact == nil or b.broken == true then -- 3533
					goto __continue540 -- 3535
				end -- 3535
				if not self:nearBox(b, b.interact.reach or 27) then -- 3535
					goto __continue540 -- 3538
				end -- 3538
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3540
				if d < bestD then -- 3540
					bestD = d -- 3542
					best = b -- 3543
				end -- 3543
			end -- 3543
			::__continue540:: -- 3543
			i = i + 1 -- 3532
		end -- 3532
	end -- 3532
	return best -- 3546
end -- 3527
function Play.prototype.stepCampaign(self, dt, input) -- 3550
	local wr = self.room -- 3551
	local p = self.player -- 3552
	if self.reloadT > 0 then -- 3552
		self.reloadT = self.reloadT - 1 -- 3554
	end -- 3554
	if self.bracedShield ~= nil then -- 3554
		self.bracedShield.x = p.x + p.facing * 26 -- 3558
		self.bracedShield.y = p.y -- 3559
		local shBox = __TS__ArrayFind( -- 3560
			self.boxes, -- 3560
			function(____, b) return b.id == "braced_shield" end -- 3560
		) -- 3560
		if shBox ~= nil then -- 3560
			shBox.x0 = self.bracedShield.x - 15 -- 3562
			shBox.x1 = self.bracedShield.x + 15 -- 3563
			shBox.y0 = self.bracedShield.y -- 3564
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3565
		end -- 3565
	end -- 3565
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3565
		self.run.route = "drygoods" -- 3571
		self.run.joined = false -- 3572
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3573
		self:log("转布行线") -- 3574
	end -- 3574
	if wr.key == "escort3" then -- 3574
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3579
		if nearBench and input.interact.pressed then -- 3579
			self:openCraftBench() -- 3581
			return -- 3582
		end -- 3582
		local ____temp_102 = self.storyRoute == "soldier" -- 3584
		if ____temp_102 then -- 3584
			local ____opt_100 = self.run.story.talents -- 3584
			____temp_102 = (____opt_100 and ____opt_100.deferred) == true -- 3584
		end -- 3584
		if ____temp_102 and p.x >= wr.minX + 940 then -- 3584
			self:triggerDeferredEscort3Draft() -- 3585
		end -- 3585
	end -- 3585
	local i = 0 -- 3589
	do -- 3589
		i = 0 -- 3590
		while i < #self.pickups do -- 3590
			do -- 3590
				local pk = self.pickups[i + 1] -- 3591
				if self.run.taken[pk.id] == true then -- 3591
					goto __continue554 -- 3593
				end -- 3593
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3595
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3596
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3596
					if not self:addItem(pk.kind) then -- 3596
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3600
						self:log("满包拒绝 " .. pk.kind) -- 3601
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3602
						goto __continue554 -- 3603
					end -- 3603
					self.run.taken[pk.id] = true -- 3605
					self:flashSet("拾取 " .. pk.label, 1) -- 3606
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3607
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3608
				end -- 3608
			end -- 3608
			::__continue554:: -- 3608
			i = i + 1 -- 3590
		end -- 3590
	end -- 3590
	self.calmConsumed = false -- 3612
	local ____temp_108 = self.partner.alive and self.run.joined -- 3613
	if ____temp_108 then -- 3613
		local ____opt_103 = self.room.campaign -- 3613
		local ____temp_107 = (____opt_103 and ____opt_103.chapter) == "S" -- 3614
		if not ____temp_107 then -- 3614
			local ____opt_105 = self.room.campaign -- 3614
			____temp_107 = (____opt_105 and ____opt_105.chapter) == "C" -- 3614
		end -- 3614
		____temp_108 = ____temp_107 -- 3613
	end -- 3613
	if ____temp_108 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3613
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3616
		local hadK1 = self.escort.knock1 -- 3617
		local hadK2 = self.escort.knock2 -- 3618
		self.calmConsumed = self.escort:update( -- 3619
			input, -- 3619
			p.x, -- 3619
			p.facing, -- 3619
			self.partner.x, -- 3619
			dist -- 3619
		) -- 3619
		if not hadK1 and self.escort.knock1 then -- 3619
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3621
		end -- 3621
		if not hadK2 and self.escort.knock2 then -- 3621
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3624
		end -- 3624
		self.partner.crouch = self.escort.crouchPose -- 3626
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3627
	end -- 3627
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3627
		self:campaignInteract() -- 3630
	end -- 3630
	self:stepCampaignCart(dt, input) -- 3632
	self:stepCampaignGoal() -- 3633
	self:campaignCheckpoint() -- 3634
end -- 3550
function Play.prototype.campaignCheckpoint(self) -- 3638
	local i = 0 -- 3639
	do -- 3639
		i = 0 -- 3640
		while i < #self.room.marks do -- 3640
			do -- 3640
				local m = self.room.marks[i + 1] -- 3641
				if m.kind ~= 0 then -- 3641
					goto __continue564 -- 3643
				end -- 3643
				local dx = self.player.x - m.x -- 3645
				local dy = self.player.y - m.y -- 3646
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3646
					self.checkpoint = m.x -- 3648
					self:captureCheckpoint(m.x) -- 3649
					self:flashSet("检查点", 1) -- 3650
				end -- 3650
			end -- 3650
			::__continue564:: -- 3650
			i = i + 1 -- 3640
		end -- 3640
	end -- 3640
end -- 3638
function Play.prototype.campaignInteract(self) -- 3656
	local b = self:findInteract() -- 3657
	if b ~= nil then -- 3657
		self:useInteract(b) -- 3659
		return -- 3660
	end -- 3660
	local inv = self.run.inventory -- 3662
	if inv.wedge > 0 then -- 3662
		local w = self:findWedgeTarget() -- 3664
		if w ~= nil then -- 3664
			local ____opt_109 = w.breakable -- 3664
			local extraHp = (____opt_109 and ____opt_109.wedgeHp or 1) + self:talentRank("salvage") -- 3666
			if w.breakable ~= nil then -- 3666
				local ____w_breakable_111, ____hp_112 = w.breakable, "hp" -- 3666
				____w_breakable_111[____hp_112] = ____w_breakable_111[____hp_112] + extraHp -- 3668
			end -- 3668
			inv.wedge = inv.wedge - 1 -- 3670
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3671
			self:flashSet( -- 3673
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3673
				1.2 -- 3673
			) -- 3673
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3674
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3675
			return -- 3676
		end -- 3676
		if self:isEscortRoom() then -- 3676
			local p = self.player -- 3679
			local wx = math.max( -- 3680
				self.room.minX + 64, -- 3680
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3680
			) -- 3680
			local hp = 1 + self:talentRank("salvage") -- 3681
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3682
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3683
			local ____self_boxes_113 = self.boxes -- 3683
			____self_boxes_113[#____self_boxes_113 + 1] = { -- 3684
				x0 = wx - 12, -- 3685
				x1 = wx + 12, -- 3686
				y0 = p.y, -- 3687
				y1 = p.y + 48, -- 3688
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3689
				label = "立起的木楔掩体", -- 3690
				id = wid, -- 3691
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3692
			} -- 3692
			inv.wedge = inv.wedge - 1 -- 3694
			self:flashSet( -- 3695
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3695
				1.2 -- 3695
			) -- 3695
			self:log("立木楔掩体") -- 3696
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3697
			return -- 3698
		end -- 3698
	end -- 3698
	if inv.ammo > 0 and self.reloadT > 0 then -- 3698
		self.reloadT = 0 -- 3703
		self:closeReloadPuzzle() -- 3704
		inv.ammo = inv.ammo - 1 -- 3705
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3706
		self:log("用备用弹包") -- 3707
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3708
		return -- 3709
	end -- 3709
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3711
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3711
		local p = self.player -- 3715
		local shHp = 1 + self:talentRank("salvage") -- 3716
		self.bracedShield = { -- 3717
			x = p.x + p.facing * 26, -- 3717
			y = p.y, -- 3717
			w = 30, -- 3717
			h = 64, -- 3717
			hp = shHp -- 3717
		} -- 3717
		local ____self_boxes_114 = self.boxes -- 3717
		____self_boxes_114[#____self_boxes_114 + 1] = { -- 3718
			x0 = self.bracedShield.x - 15, -- 3719
			x1 = self.bracedShield.x + 15, -- 3719
			y0 = p.y, -- 3720
			y1 = p.y + 64, -- 3720
			depth = {min = -46, max = 46}, -- 3720
			label = "架起的残盾", -- 3720
			id = "braced_shield", -- 3720
			soft = true -- 3721
		} -- 3721
		inv.shield = inv.shield - 1 -- 3723
		self:flashSet( -- 3724
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3724
			1.2 -- 3724
		) -- 3724
		self:log("架残盾") -- 3725
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3726
		return -- 3727
	end -- 3727
	if inv.pass > 0 and self.run.joined == false then -- 3727
		inv.pass = inv.pass - 1 -- 3730
		self.run.joined = true -- 3731
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3732
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3733
		return -- 3734
	end -- 3734
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3736
end -- 3656
function Play.prototype.useInteract(self, b) -- 3739
	local kind = b.interact == nil and "" or b.interact.kind -- 3740
	local wr = self.room -- 3741
	if kind == "open_board" then -- 3741
		b.broken = true -- 3743
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3744
		for ____, cover in ipairs(self.boxes) do -- 3745
			if cover.id == "s2_board_cover" then -- 3745
				cover.broken = false -- 3747
				cover.hidden = false -- 3748
			end -- 3748
		end -- 3748
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3751
		self.run.joined = true -- 3752
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3753
		self:log("放下窗板") -- 3754
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3755
		return -- 3756
	end -- 3756
	if kind == "lower_curtain" then -- 3756
		for ____, curtain in ipairs(self.boxes) do -- 3759
			if curtain.id == "c2_curtain" then -- 3759
				curtain.broken = false -- 3761
				curtain.hidden = false -- 3762
			end -- 3762
		end -- 3762
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3765
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3766
		self:log("放下木帘") -- 3767
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3768
		return -- 3769
	end -- 3769
	if kind == "raise_latch" then -- 3769
		if wr.key == "c2-granary" and not self.cartDocked then -- 3769
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3773
			return -- 3774
		end -- 3774
		b.broken = true -- 3776
		self.objectiveDone = true -- 3777
		if wr.key == "c1-yard" then -- 3777
			self.run.c1Latch = true -- 3780
			self.run.joined = true -- 3781
			for ____, door in ipairs(self.boxes) do -- 3782
				if door.id == "c1_door" then -- 3782
					door.broken = true -- 3784
				end -- 3784
			end -- 3784
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3787
		else -- 3787
			self.run.c2Latch = true -- 3789
			self.run.joined = true -- 3790
		end -- 3790
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3792
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3793
		self:log("抬闩") -- 3794
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3795
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3796
	end -- 3796
end -- 3739
function Play.prototype.stepCampaignCart(self, dt, input) -- 3801
	local wr = self.room -- 3802
	local c = wr.cart -- 3803
	if c.bodyW <= 0 then -- 3803
		return -- 3805
	end -- 3805
	local p = self.player -- 3807
	local handleX = self.cartAxle + c.handleOffset -- 3808
	if not self.gripping then -- 3808
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3808
			self.gripping = true -- 3812
			self:flashSet("握住车柄 · A/D 推", 1) -- 3813
		end -- 3813
		return -- 3815
	end -- 3815
	if input.interact.pressed then -- 3815
		self.gripping = false -- 3818
		self:flashSet("松手", 0.5) -- 3819
		return -- 3820
	end -- 3820
	if not self.cartDocked then -- 3820
		if input.moveX ~= 0 and not self:stuckCart() then -- 3820
			self.cartAxle = math.max( -- 3824
				c.startX, -- 3824
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3824
			) -- 3824
		end -- 3824
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3824
			self.cartExposed = true -- 3829
			local gun = nil -- 3830
			local gi = 0 -- 3831
			do -- 3831
				gi = 0 -- 3832
				while gi < #self.enemies do -- 3832
					local e = self.enemies[gi + 1] -- 3833
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3833
						gun = e -- 3835
						break -- 3836
					end -- 3836
					gi = gi + 1 -- 3832
				end -- 3832
			end -- 3832
			if gun ~= nil then -- 3832
				self:campaignEnemyFire(gun) -- 3840
			end -- 3840
		end -- 3840
		p.x = self.cartAxle + c.handleOffset -- 3843
		p.y = c.baseY -- 3844
		p.depth = c.depth or 0 -- 3845
		p.vx = 0 -- 3846
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3846
			self.cartAxle = c.endX -- 3848
			self.cartDocked = true -- 3849
			self.gripping = false -- 3850
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3851
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3852
			self:flashSet("车轮入窝", 1.2) -- 3853
			self:log("车轮入窝") -- 3854
		end -- 3854
	end -- 3854
end -- 3801
function Play.prototype.stuckCart(self) -- 3860
	local i = 0 -- 3861
	do -- 3861
		i = 0 -- 3862
		while i < #self.boxes do -- 3862
			do -- 3862
				local b = self.boxes[i + 1] -- 3863
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3863
					goto __continue607 -- 3865
				end -- 3865
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3867
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3867
					return true -- 3869
				end -- 3869
			end -- 3869
			::__continue607:: -- 3869
			i = i + 1 -- 3862
		end -- 3862
	end -- 3862
	return false -- 3872
end -- 3860
function Play.prototype.stepCampaignGoal(self) -- 3876
	local wr = self.room -- 3877
	local c = wr.campaign -- 3878
	if c == nil then -- 3878
		return -- 3880
	end -- 3880
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3880
		self.objectiveDone = true -- 3883
	end -- 3883
	if c.goal == "reach_exit" then -- 3883
		self.objectiveDone = true -- 3886
	end -- 3886
	if not self.objectiveDone then -- 3886
		return -- 3889
	end -- 3889
	local p = self.player -- 3891
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3892
	if p.x < c.exitX or not partnerOk then -- 3892
		return -- 3894
	end -- 3894
	if self.run.story.segments[wr.key] ~= true then -- 3894
		self.run.story.segments[wr.key] = true -- 3898
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3899
	end -- 3899
	if wr.key == "escort5" then -- 3899
		self.escortDone = true -- 3903
		self.run.story.escortDone = true -- 3904
	end -- 3904
	if c.next ~= nil and c.next ~= "" then -- 3904
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3907
		self:flashSet("过关 · " .. c.next, 1.2) -- 3908
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3908
		self:requestRoom("gate", "军粮棚出口") -- 3911
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3912
	elseif not self.run.finished then -- 3912
		self.run.finished = true -- 3914
		self:flashSet( -- 3915
			"C2 灰盒完成 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3915
			2 -- 3915
		) -- 3915
		self:log("C2 灰盒完成") -- 3916
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3917
	end -- 3917
end -- 3876
function Play.prototype.stepCampaignPartner(self, dt) -- 3922
	local a = self.partner -- 3923
	local wr = self.room -- 3924
	local cp = wr.companion -- 3925
	if not a.alive then -- 3925
		return -- 3927
	end -- 3927
	local p = self.player -- 3929
	if self.craftBench.active then -- 3929
		a.vx = 0 -- 3932
		return -- 3933
	end -- 3933
	local wait = false -- 3935
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3936
	local targetDepth = p.depth -- 3937
	if self.run.joined == false then -- 3937
		wait = true -- 3939
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3940
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3941
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3941
		wait = true -- 3943
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3944
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3945
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3945
		wait = true -- 3947
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3948
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3949
	end -- 3949
	if self.partnerStuck > 0.3 then -- 3949
		a.x = a.x + a.facing * 44 -- 3953
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3954
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3955
		self.partnerLaneHold = 1.1 -- 3956
		self.partnerStuck = 0 -- 3957
	end -- 3957
	if self.partnerLaneHold > 0 then -- 3957
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3960
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3961
	end -- 3961
	local dx = targetX - a.x -- 3963
	local stopTol = wait and 18 or 74 -- 3964
	if math.abs(dx) > stopTol then -- 3964
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3966
		local before = a.x -- 3967
		a.vx = dx > 0 and speed or -speed -- 3968
		a.facing = dx > 0 and 1 or -1 -- 3969
		self:slideX(a, a.vx * dt) -- 3970
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3970
			a.vy = CHILD_JUMP -- 3973
			a.onGround = false -- 3974
		end -- 3974
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3976
	else -- 3976
		a.vx = 0 -- 3978
		self.partnerStuck = 0 -- 3979
	end -- 3979
	local dz = targetDepth - a.depth -- 3981
	if math.abs(dz) > 6 then -- 3981
		local step = math.max( -- 3983
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3983
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3983
		) -- 3983
		a.depth = a.depth + step -- 3984
	end -- 3984
	a.depthSpeed = 0 -- 3986
	a.h = CHILD_H -- 3987
	a.crouch = false -- 3988
	self:fallY(a, dt) -- 3989
end -- 3922
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 3993
	local p = self.player -- 3994
	local i = 0 -- 3995
	do -- 3995
		i = 0 -- 3996
		while i < #self.enemies and not self.escortFailed do -- 3996
			do -- 3996
				local e = self.enemies[i + 1] -- 3997
				if e.kind == "target" then -- 3997
					if not e.alive then -- 3997
						if e.hitT > 0 then -- 3997
							e.hitT = e.hitT - dt -- 4002
						end -- 4002
						if e.hitT <= 0 then -- 4002
							e.alive = true -- 4005
							e.hitT = 0 -- 4006
						end -- 4006
					end -- 4006
					goto __continue635 -- 4009
				end -- 4009
				if not e.alive then -- 4009
					goto __continue635 -- 4012
				end -- 4012
				if e.kind == "breaker" then -- 4012
					self:stepBreaker(e, dt) -- 4015
					goto __continue635 -- 4016
				end -- 4016
				if e.kind == "shield" then -- 4016
					self:stepShield(e, dt, input) -- 4019
					goto __continue635 -- 4020
				end -- 4020
				local dx = e.x - p.x -- 4023
				if not e.awake then -- 4023
					if math.abs(dx) > 520 then -- 4023
						goto __continue635 -- 4026
					end -- 4026
					e.awake = true -- 4028
					e.fireCd = 48 -- 4029
					goto __continue635 -- 4030
				end -- 4030
				if math.abs(dx) > ENEMY_RANGE then -- 4030
					goto __continue635 -- 4033
				end -- 4033
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4033
					goto __continue635 -- 4038
				end -- 4038
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4038
					goto __continue635 -- 4041
				end -- 4041
				if self:blockedShot(e, p) then -- 4041
					if e.warnT > 0 then -- 4041
						e.warnT = 0 -- 4047
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4048
					end -- 4048
					goto __continue635 -- 4050
				end -- 4050
				if e.warnT > 0 then -- 4050
					e.warnT = e.warnT - 1 -- 4053
					if e.warnT <= 0 then -- 4053
						self:campaignEnemyFire(e) -- 4055
					end -- 4055
				elseif e.fireCd > 0 then -- 4055
					e.fireCd = e.fireCd - 1 -- 4058
					if e.fireCd <= 0 then -- 4058
						e.warnT = WARN_TICKS -- 4060
					end -- 4060
				else -- 4060
					e.fireCd = 40 -- 4063
				end -- 4063
			end -- 4063
			::__continue635:: -- 4063
			i = i + 1 -- 3996
		end -- 3996
	end -- 3996
end -- 3993
function Play.prototype.blockedShot(self, e, p) -- 4069
	local eDepth = e.depth or 0 -- 4070
	local ex = e.x -- 4071
	local ey = e.y + e.h * 0.62 -- 4073
	local px = p.x -- 4074
	local py = p.y + p.h * 0.55 -- 4075
	local dx = px - ex -- 4076
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4077
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4078
	if len < 0.01 then -- 4078
		return false -- 4080
	end -- 4080
	local ray = { -- 4084
		x = ex, -- 4085
		y = ey, -- 4085
		dx = dx / len, -- 4086
		dy = (py - ey) / len, -- 4086
		depth = eDepth, -- 4087
		dDepth = (p.depth - eDepth) / len -- 4087
	} -- 4087
	local best = -1 -- 4089
	local j = 0 -- 4090
	do -- 4090
		j = 0 -- 4091
		while j < #self.boxes do -- 4091
			do -- 4091
				local b = self.boxes[j + 1] -- 4092
				if b.broken == true or b.passable == true or b.hidden == true then -- 4092
					goto __continue658 -- 4094
				end -- 4094
				if b.id == "braced_shield" then -- 4094
					goto __continue658 -- 4099
				end -- 4099
				local t = hitBox(ray, b) -- 4101
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4101
					best = t -- 4105
				end -- 4105
			end -- 4105
			::__continue658:: -- 4105
			j = j + 1 -- 4091
		end -- 4091
	end -- 4091
	return best >= 0 -- 4108
end -- 4069
function Play.prototype.campaignEnemyFire(self, e) -- 4111
	local p = self.player -- 4112
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4113
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4113
		local ____self_bracedShield_115, ____hp_116 = self.bracedShield, "hp" -- 4113
		____self_bracedShield_115[____hp_116] = ____self_bracedShield_115[____hp_116] - 1 -- 4115
		if self.bracedShield.hp <= 0 then -- 4115
			self.boxes = __TS__ArrayFilter( -- 4117
				self.boxes, -- 4117
				function(____, b) return b.id ~= "braced_shield" end -- 4117
			) -- 4117
			self.bracedShield = nil -- 4118
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4119
		else -- 4119
			self:flashSet( -- 4121
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4121
				1 -- 4121
			) -- 4121
		end -- 4121
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4123
		return -- 4124
	end -- 4124
	if self:blockedShot(e, p) then -- 4124
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4127
		return -- 4128
	end -- 4128
	local cover = self:blockedByCover(e, p) -- 4130
	if cover ~= nil and self.coverHug then -- 4130
		self.coveredFlash = 0.5 -- 4132
		self:flashSet("掩体挡下", 0.6) -- 4133
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4134
		return -- 4139
	end -- 4139
	if self.invulnT > 0 then -- 4139
		return -- 4142
	end -- 4142
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4144
	self.craftT = 0 -- 4145
	self.hp = self.hp - 1 -- 4146
	self:emit("actorHit", { -- 4147
		target = "player", -- 4147
		amount = 1, -- 4147
		hp = self.hp, -- 4147
		maxHp = self.maxHp, -- 4147
		enemyX = e.x -- 4147
	}) -- 4147
	self:flashSet( -- 4148
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4148
		0.8 -- 4148
	) -- 4148
	if self.hp <= 0 then -- 4148
		self:campaignFailed() -- 4150
	end -- 4150
end -- 4111
function Play.prototype.stepShield(self, e, dt, input) -- 4155
	local p = self.player -- 4156
	local dx = p.x - e.x -- 4157
	local adx = math.abs(dx) -- 4158
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4161
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4162
	if adx > 44 then -- 4162
		local before = e.x -- 4164
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4165
		local nextX = math.max( -- 4166
			self.room.minX + 16, -- 4166
			math.min(self.room.maxX - 16, e.x + stepX) -- 4166
		) -- 4166
		if not self:enemyBlockedAtX(e, nextX) then -- 4166
			e.x = nextX -- 4168
		end -- 4168
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4168
			e.depth = math.max( -- 4172
				-32, -- 4172
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4172
			) -- 4172
		end -- 4172
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4172
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4177
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4178
		if not rollDodges and self.invulnT <= 0 then -- 4178
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4180
			self.craftT = 0 -- 4181
			self.hp = self.hp - 1 -- 4182
			self:emit("actorHit", { -- 4183
				target = "player", -- 4183
				amount = 1, -- 4183
				hp = self.hp, -- 4183
				maxHp = self.maxHp, -- 4183
				enemyX = e.x -- 4183
			}) -- 4183
			self:flashSet( -- 4184
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4184
				0.8 -- 4184
			) -- 4184
			if self.hp <= 0 then -- 4184
				self:campaignFailed() -- 4186
				return -- 4187
			end -- 4187
		end -- 4187
		e.swingT = 70 -- 4190
	end -- 4190
	if (e.swingT or 0) > 0 then -- 4190
		e.swingT = (e.swingT or 0) - 1 -- 4193
	end -- 4193
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4193
		local dd = p.depth - (e.depth or 0) -- 4196
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4197
	end -- 4197
end -- 4155
function Play.prototype.stepBreaker(self, e, dt) -- 4202
	local p = self.player -- 4203
	if e.awake ~= true then -- 4203
		if math.abs(p.x - e.x) < 560 then -- 4203
			e.awake = true -- 4206
		else -- 4206
			return -- 4208
		end -- 4208
	end -- 4208
	local target = nil -- 4211
	local bestD = 1000000000 -- 4212
	local i = 0 -- 4213
	do -- 4213
		i = 0 -- 4214
		while i < #self.boxes do -- 4214
			do -- 4214
				local b = self.boxes[i + 1] -- 4215
				if b.breakable == nil or b.broken == true then -- 4215
					goto __continue685 -- 4217
				end -- 4217
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4219
				if d < bestD then -- 4219
					bestD = d -- 4221
					target = b -- 4222
				end -- 4222
			end -- 4222
			::__continue685:: -- 4222
			i = i + 1 -- 4214
		end -- 4214
	end -- 4214
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4225
	local dx = tx - e.x -- 4226
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4227
	if math.abs(dx) > reach then -- 4227
		local before = e.x -- 4229
		local nextX = math.max( -- 4230
			self.room.minX + 16, -- 4230
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4230
		) -- 4230
		if not self:enemyBlockedAtX(e, nextX) then -- 4230
			e.x = nextX -- 4232
		end -- 4232
		if math.abs(e.x - before) < 0.3 then -- 4232
			e.depth = math.max( -- 4235
				-32, -- 4235
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4235
			) -- 4235
		end -- 4235
	elseif (e.swingT or 0) <= 0 then -- 4235
		e.swingT = 64 -- 4238
		if target ~= nil then -- 4238
			self:damageProp(target, 2) -- 4240
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4240
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4243
			self.craftT = 0 -- 4244
			self.hp = self.hp - 1 -- 4245
			self:emit("actorHit", { -- 4246
				target = "player", -- 4246
				amount = 1, -- 4246
				hp = self.hp, -- 4246
				maxHp = self.maxHp, -- 4246
				enemyX = e.x -- 4246
			}) -- 4246
			self:flashSet("破障手近身", 0.8) -- 4247
			if self.hp <= 0 then -- 4247
				self:campaignFailed() -- 4249
				return -- 4250
			end -- 4250
		end -- 4250
	end -- 4250
	if (e.swingT or 0) > 0 then -- 4250
		e.swingT = (e.swingT or 0) - 1 -- 4255
	end -- 4255
end -- 4202
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4260
	local half = e.w * 0.5 -- 4261
	local d = e.depth or 0 -- 4262
	local i = 0 -- 4263
	do -- 4263
		i = 0 -- 4264
		while i < #self.boxes do -- 4264
			do -- 4264
				local b = self.boxes[i + 1] -- 4265
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4265
					goto __continue698 -- 4267
				end -- 4267
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4267
					goto __continue698 -- 4270
				end -- 4270
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4270
					return true -- 4273
				end -- 4273
			end -- 4273
			::__continue698:: -- 4273
			i = i + 1 -- 4264
		end -- 4264
	end -- 4264
	return false -- 4276
end -- 4260
function Play.prototype.campaignFailed(self) -- 4279
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4279
		if self.escortFailed then -- 4279
			return -- 4284
		end -- 4284
		if self.useEscortDeathSummary then -- 4284
			local story = self.run.story -- 4286
			local st = story.talents -- 4287
			local ranksCopy = { -- 4288
				vitality = st and st.ranks.vitality or 0, -- 4289
				guard = st and st.ranks.guard or 0, -- 4290
				stride = st and st.ranks.stride or 0, -- 4291
				focus = st and st.ranks.focus or 0, -- 4292
				push_force = st and st.ranks.push_force or 0, -- 4293
				echo_wide = st and st.ranks.echo_wide or 0, -- 4294
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4295
				salvage = st and st.ranks.salvage or 0 -- 4296
			} -- 4296
			local cleared = 0 -- 4298
			local segKeys = { -- 4299
				"escort1", -- 4299
				"escort2", -- 4299
				"escort3", -- 4299
				"escort4", -- 4299
				"escort5" -- 4299
			} -- 4299
			local si = 0 -- 4300
			do -- 4300
				si = 0 -- 4301
				while si < #segKeys do -- 4301
					if story.segments[segKeys[si + 1]] == true then -- 4301
						cleared = cleared + 1 -- 4303
					end -- 4303
					si = si + 1 -- 4301
				end -- 4301
			end -- 4301
			self.escortFailed = true -- 4306
			self.escortFailedTicks = 0 -- 4307
			self.talentModalActive = false -- 4308
			self.craftBench.active = false -- 4309
			self.reloadT = 0 -- 4310
			self:closeReloadPuzzle() -- 4311
			self.gripping = false -- 4312
			self.escortSummary = { -- 4313
				roomKey = self.room.key, -- 4314
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4315
				seed = st ~= nil and st.randomState or self.run.seed, -- 4316
				equippedWeapon = self.equippedWeapon, -- 4317
				segmentsCleared = cleared, -- 4318
				ranks = ranksCopy -- 4319
			} -- 4319
			self:resetEscortAttempt() -- 4321
			self:flashSet("折返山道 · 重整再赴", 2) -- 4322
			self:log("男主线折返 · 展示小结") -- 4323
			self:emit("campaignFailed", { -- 4324
				room = self.room.key, -- 4325
				hp = 0, -- 4325
				maxHp = self.maxHp, -- 4325
				reset = true, -- 4326
				to = "escort1", -- 4326
				route = self.storyRoute, -- 4326
				summary = true -- 4326
			}) -- 4326
			return -- 4328
		end -- 4328
		self:restartEscortRun() -- 4330
		return -- 4331
	end -- 4331
	local p = self.player -- 4333
	self.hp = self.maxHp -- 4334
	self.invulnT = INVULN_RESPAWN_TICKS -- 4335
	self.reloadT = 0 -- 4336
	self:closeReloadPuzzle() -- 4337
	self.gripping = false -- 4338
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4339
	self:log("被击倒") -- 4340
	p.x = self.room.minX + 90 -- 4341
	p.y = 0 -- 4342
	p.depth = 0 -- 4343
	p.vx = 0 -- 4344
	p.vy = 0 -- 4345
	p.onGround = true -- 4346
	p.rollT = 0 -- 4347
	self.partner.x = p.x - 50 -- 4348
	self.partner.y = 0 -- 4349
	self.partner.depth = 0 -- 4350
	self.cam.x = p.x -- 4351
	local i = 0 -- 4352
	do -- 4352
		i = 0 -- 4353
		while i < #self.enemies do -- 4353
			do -- 4353
				local e = self.enemies[i + 1] -- 4354
				if not e.alive then -- 4354
					goto __continue710 -- 4356
				end -- 4356
				e.x = e.homeX == nil and e.x or e.homeX -- 4358
				e.warnT = 0 -- 4359
				e.fireCd = 40 -- 4360
				e.swingT = 0 -- 4361
				e.awake = false -- 4362
			end -- 4362
			::__continue710:: -- 4362
			i = i + 1 -- 4353
		end -- 4353
	end -- 4353
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4364
end -- 4279
function Play.prototype.isEscortRoom(self) -- 4368
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4369
end -- 4368
function Play.prototype.confirmEscortRestart(self) -- 4373
	if not self.escortFailed then -- 4373
		return false -- 4375
	end -- 4375
	self:requestRoom("escort1", "男主线失败重开") -- 4377
	return true -- 4378
end -- 4373
function Play.prototype.restartEscortRun(self) -- 4382
	self:resetEscortAttempt() -- 4383
	self:requestRoom("escort1", "男主线失败重开") -- 4384
end -- 4382
function Play.prototype.resetEscortAttempt(self) -- 4392
	local story = self.run.story -- 4393
	local inv = self.run.inventory -- 4394
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4395
	local nextAttempt = prevAttempt + 1 -- 4396
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4397
	if vitBonus > 0 then -- 4397
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4399
		story.maxHp = self.maxHp -- 4400
	end -- 4400
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4402
	self.hp = self.maxHp -- 4403
	story.hp = self.maxHp -- 4404
	story.cp = nil -- 4405
	self.checkpointSnap = nil -- 4406
	story.carry = false -- 4407
	self.carryOn = false -- 4408
	story.craftedWeapon = "" -- 4409
	self.equippedWeapon = "standard_gun" -- 4410
	story.equippedWeapon = "standard_gun" -- 4411
	story.escortDone = false -- 4412
	self.escortDone = false -- 4413
	story.segments = {} -- 4414
	inv.wood = 0 -- 4415
	inv.bell = 0 -- 4416
	inv.scrap = 0 -- 4417
	inv.wedge = 0 -- 4418
	inv.ammo = 0 -- 4419
	inv.quickbelt = 0 -- 4420
	inv.shield = 0 -- 4421
	inv.pass = 0 -- 4422
	local taken = self.run.taken -- 4423
	local keys = __TS__ObjectKeys(taken) -- 4424
	local i = 0 -- 4425
	do -- 4425
		i = 0 -- 4426
		while i < #keys do -- 4426
			local k = keys[i + 1] -- 4427
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4427
				__TS__Delete(taken, k) -- 4429
			end -- 4429
			i = i + 1 -- 4426
		end -- 4426
	end -- 4426
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4432
	do -- 4432
		i = 0 -- 4433
		while i < #propKeys do -- 4433
			local pk = propKeys[i + 1] -- 4434
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4434
				__TS__Delete(self.run.props, pk) -- 4437
			end -- 4437
			i = i + 1 -- 4433
		end -- 4433
	end -- 4433
	self.bracedShield = nil -- 4440
	self.talentModalActive = false -- 4441
	self.run.joined = true -- 4442
	self.reloadT = 0 -- 4443
	self:closeReloadPuzzle() -- 4444
	self.gripping = false -- 4445
	self.sessionDirty = true -- 4446
	self:flashSet( -- 4447
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4447
		2 -- 4447
	) -- 4447
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4448
	if not self.useEscortDeathSummary then -- 4448
		self:emit("campaignFailed", { -- 4450
			room = self.room.key, -- 4451
			hp = 0, -- 4451
			maxHp = self.maxHp, -- 4451
			reset = true, -- 4452
			to = "escort1", -- 4452
			route = self.storyRoute, -- 4452
			attempt = nextAttempt -- 4452
		}) -- 4452
	end -- 4452
end -- 4392
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4458
	local i = 0 -- 4459
	do -- 4459
		i = 0 -- 4460
		while i < #self.enemies do -- 4460
			do -- 4460
				if i == skipIndex then -- 4460
					goto __continue727 -- 4462
				end -- 4462
				local e = self.enemies[i + 1] -- 4464
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4464
					goto __continue727 -- 4466
				end -- 4466
				e.awake = true -- 4468
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4469
				e.warnT = 0 -- 4470
			end -- 4470
			::__continue727:: -- 4470
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
			if e.hitT > 0 then -- 4477
				e.hitT = e.hitT - dt -- 4479
			end -- 4479
			i = i + 1 -- 4476
		end -- 4476
	end -- 4476
	if self.coveredFlash > 0 then -- 4476
		self.coveredFlash = self.coveredFlash - dt -- 4483
	end -- 4483
	if self.isCampaign then -- 4483
		self:stepCampaignEnemies(dt, input) -- 4486
		return -- 4487
	end -- 4487
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4487
		return -- 4491
	end -- 4491
	do -- 4491
		i = 0 -- 4493
		while i < #self.enemies do -- 4493
			do -- 4493
				local e = self.enemies[i + 1] -- 4494
				if not e.alive then -- 4494
					goto __continue738 -- 4496
				end -- 4496
				if e.warnT > 0 then -- 4496
					e.warnT = e.warnT - 1 -- 4499
					if e.warnT <= 0 then -- 4499
						self:enemyFire(e, input) -- 4501
					end -- 4501
					goto __continue738 -- 4503
				end -- 4503
				if e.fireCd > 0 then -- 4503
					e.fireCd = e.fireCd - 1 -- 4506
					if e.fireCd <= 0 then -- 4506
						e.warnT = WARN_TICKS -- 4508
					end -- 4508
				else -- 4508
					e.warnT = WARN_TICKS -- 4512
				end -- 4512
			end -- 4512
			::__continue738:: -- 4512
			i = i + 1 -- 4493
		end -- 4493
	end -- 4493
end -- 4474
function Play.prototype.enemyFire(self, e, input) -- 4518
	local p = self.player -- 4519
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4519
		self:flashSet("枪声响在远处", 0.4) -- 4521
		e.fireCd = FIRE_COOLDOWN -- 4522
		return -- 4523
	end -- 4523
	if self:blockedShot(e, p) then -- 4523
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4526
		e.fireCd = FIRE_COOLDOWN -- 4527
		return -- 4528
	end -- 4528
	local cover = self:blockedByCover(e, p) -- 4531
	local hugging = cover ~= nil -- 4532
	self.coverBlocking = hugging -- 4533
	local covered = hugging and input.cover.held -- 4534
	if covered then -- 4534
		self.coveredFlash = 0.5 -- 4536
		self:flashSet("掩体挡下", 0.5) -- 4537
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4538
		e.fireCd = FIRE_COOLDOWN -- 4543
		return -- 4544
	end -- 4544
	if self.invulnT > 0 then -- 4544
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
	if self.hp <= 0 then -- 4554
		self:gateFailed() -- 4556
	end -- 4556
end -- 4518
function Play.prototype.blockedByCover(self, enemy, p) -- 4561
	local b = self:coverAt(p) -- 4562
	if b == nil then -- 4562
		return nil -- 4564
	end -- 4564
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4566
end -- 4561
function Play.prototype.gateFailed(self) -- 4570
	local ____temp_133 -- 4571
	if self.room.story == nil then -- 4571
		____temp_133 = nil -- 4571
	else -- 4571
		____temp_133 = self.room.story.gate -- 4571
	end -- 4571
	local g = ____temp_133 -- 4571
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
	if self.redCartMemoryT > 0 then -- 4605
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4607
	end -- 4607
	if self.room.key ~= "outside" or self.redCartPulled then -- 4607
		return -- 4610
	end -- 4610
	local box = __TS__ArrayFind( -- 4612
		self.boxes, -- 4612
		function(____, b) return b.id == "outside_red_cart" end -- 4612
	) -- 4612
	if box == nil then -- 4612
		self.redCartPulled = true -- 4614
		return -- 4615
	end -- 4615
	local cx = (box.x0 + box.x1) * 0.5 -- 4617
	local p = self.player -- 4618
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4618
		return -- 4620
	end -- 4620
	if not input.interact.pressed then -- 4620
		return -- 4623
	end -- 4623
	box.x0 = 430 -- 4625
	box.x1 = 474 -- 4626
	self.cartAxle = self.room.cart.endX -- 4628
	self.cartDocked = true -- 4629
	self.redCartPulled = true -- 4630
	self.redCartMemoryT = 30 -- 4631
	if self.run.story ~= nil then -- 4631
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
	if self.room.key == "outside" then -- 4649
		local c = self.room.cart -- 4651
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4652
		local dy = p.y - c.baseY -- 4653
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4654
	end -- 4654
	if not calmUsed and not calming then -- 4654
		self:stepCart(dt, input) -- 4658
	end -- 4658
	if calmUsed then -- 4658
		self:flashSet("安抚 · 敲两下", 0.8) -- 4663
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4663
		if self.knockT > 0 then -- 4663
			self.knocks = self.knocks + 1 -- 4667
		else -- 4667
			self.knocks = 1 -- 4669
		end -- 4669
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4671
		self.knockT = 1.2 -- 4672
		if self.knocks >= 2 then -- 4672
			self:flashSet("敲两下", 0.8) -- 4674
			self.knocks = 0 -- 4675
		else -- 4675
			self:flashSet("敲一下", 0.5) -- 4677
		end -- 4677
	elseif self.knockT > 0 then -- 4677
		self.knockT = self.knockT - dt -- 4680
		if self.knockT <= 0 then -- 4680
			self.knocks = 0 -- 4682
		end -- 4682
	end -- 4682
	local i = 0 -- 4687
	do -- 4687
		i = 0 -- 4688
		while i < #self.room.marks do -- 4688
			do -- 4688
				local m = self.room.marks[i + 1] -- 4689
				if m.kind ~= 0 then -- 4689
					goto __continue774 -- 4691
				end -- 4691
				local subjects = {self.partner, self.player} -- 4693
				local k = 0 -- 4694
				do -- 4694
					k = 0 -- 4695
					while k < #subjects do -- 4695
						do -- 4695
							local s = subjects[k + 1] -- 4696
							if not s.alive then -- 4696
								goto __continue777 -- 4698
							end -- 4698
							local dx = s.x - m.x -- 4700
							local dy = s.y - m.y -- 4701
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4701
								self.checkpoint = m.x -- 4703
								self.checkpointCartAxle = self.cartAxle -- 4704
								if self.isCampaign then -- 4704
									self:captureCheckpoint(m.x) -- 4707
								end -- 4707
								if self.cartDocked then -- 4707
									self:flashSet("检查点 · 车已落窝", 1) -- 4710
								else -- 4710
									self:flashSet("检查点 · 车还没到位", 1) -- 4712
								end -- 4712
							end -- 4712
						end -- 4712
						::__continue777:: -- 4712
						k = k + 1 -- 4695
					end -- 4695
				end -- 4695
			end -- 4695
			::__continue774:: -- 4695
			i = i + 1 -- 4688
		end -- 4688
	end -- 4688
	self:checkCarryGate() -- 4718
end -- 4642
function Play.prototype.stepVillage(self, dt, input) -- 4722
	if self.room.key ~= "village" then -- 4722
		return -- 4724
	end -- 4724
	local p = self.player -- 4726
	local bottle = self.room.bottle -- 4727
	local scav = self.room.scavenger -- 4728
	if not self.hasBottle and bottle ~= nil then -- 4728
		local dx = p.x - bottle.x -- 4732
		local dy = p.y + p.h * 0.5 - bottle.y -- 4733
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4733
			self.hasBottle = true -- 4735
			self:flashSet("拾起瓶子", 0.8) -- 4736
		end -- 4736
	end -- 4736
	if self.hasBottle then -- 4736
		if input.bottleCanceled then -- 4736
			self.aimHold = 0 -- 4743
			self.bottleAimX = -1 -- 4744
		elseif input.aim.held then -- 4744
			self.aimHold = self.aimHold + dt -- 4746
			if self.aimHold > 1.2 then -- 4746
				self.aimHold = 1.2 -- 4748
			end -- 4748
			local cached = self:bottleEnd() -- 4751
			self.bottleAimX = cached.x -- 4752
			self.bottleAimY = cached.y -- 4753
		elseif input.aim.released then -- 4753
			if self.aimHold < 0.12 then -- 4753
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
	if fly ~= nil then -- 4772
		fly.t = fly.t + dt -- 4774
		fly.x = fly.x0 + fly.vx * fly.t -- 4775
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4776
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4777
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4777
			self:landBottle(fly) -- 4779
		end -- 4779
	end -- 4779
	if self.bottleLandT > 0 then -- 4779
		self.bottleLandT = self.bottleLandT - dt -- 4783
	end -- 4783
	if scav ~= nil then -- 4783
		self:stepScav(dt, scav) -- 4787
	end -- 4787
	local line = self.room.passLine -- 4790
	if line ~= nil and not self.passed and p.x >= line then -- 4790
		self.passed = true -- 4792
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4793
	end -- 4793
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4796
	if underTable then -- 4796
		self.footHintT = self.footHintT - 1 -- 4798
		if self.footHintT <= 0 then -- 4798
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
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4809
		self.ditchHinted = true -- 4813
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4814
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4815
	end -- 4815
	if self.passed and p.x >= self.ox + 640 then -- 4815
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
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4860
		return "soft" -- 4862
	end -- 4862
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4862
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
	if s == nil then -- 4900
		return -- 4902
	end -- 4902
	if surface == "soft" then -- 4902
		self:flashSet("落在软土 · 没出声", 0.8) -- 4905
		return -- 4906
	end -- 4906
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4908
	if math.abs(x - self.scavX) > effRange then -- 4908
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
	if self.scavState == "chase" then -- 4921
		return -- 4924
	end -- 4924
	if self.scavState == "turn" then -- 4924
		self.scavT = self.scavT - 1 -- 4927
		if self.scavT <= 0 then -- 4927
			self.scavState = "walk" -- 4929
		end -- 4929
		return -- 4931
	end -- 4931
	if self.scavState == "walk" then -- 4931
		local d = self.scavTargetX - self.scavX -- 4934
		if math.abs(d) < 4 then -- 4934
			self.scavState = "stall" -- 4936
			self.scavT = s.stallTicks + self.scavStallBonus -- 4937
			self.scavStallBonus = 0 -- 4938
			return -- 4939
		end -- 4939
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4941
		return -- 4942
	end -- 4942
	if self.scavState == "stall" then -- 4942
		self.scavT = self.scavT - 1 -- 4945
		if self.scavT <= 0 then -- 4945
			self.scavState = "back" -- 4947
		end -- 4947
		return -- 4949
	end -- 4949
	if self.scavState == "back" then -- 4949
		local home = math.max( -- 4952
			s.x0, -- 4952
			math.min(s.x1, self.scavX) -- 4952
		) -- 4952
		if math.abs(home - self.scavX) < 2 then -- 4952
			self.scavState = "patrol" -- 4954
			return -- 4955
		end -- 4955
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4957
		return -- 4958
	end -- 4958
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4960
	if self.scavX >= s.x1 then -- 4960
		self.scavX = s.x1 -- 4962
		self.scavDir = -1 -- 4963
	elseif self.scavX <= s.x0 then -- 4963
		self.scavX = s.x0 -- 4965
		self.scavDir = 1 -- 4966
	end -- 4966
end -- 4921
function Play.prototype.stepCart(self, dt, input) -- 4974
	local p = self.player -- 4975
	local c = self.room.cart -- 4976
	if self.gripping then -- 4976
		if not input.interact.held then -- 4976
			self.gripping = false -- 4980
			self:flashSet("松开车把", 0.4) -- 4981
			return -- 4982
		end -- 4982
	else -- 4982
		if not input.interact.pressed then -- 4982
			return -- 4986
		end -- 4986
		if not self:cartHandleInReach(p) then -- 4986
			return -- 4989
		end -- 4989
		local track = c.depth or 0 -- 4991
		if self:limitDepth(p, track) ~= track then -- 4991
			return -- 4993
		end -- 4993
		p.depth = track -- 4995
		p.depthSpeed = 0 -- 4996
		self.gripping = true -- 4997
		self:flashSet("握住车把", 0.4) -- 4998
		return -- 4999
	end -- 4999
	if self.cartDocked then -- 4999
		return -- 5003
	end -- 5003
	local dir = input.moveX -- 5005
	if dir == 0 then -- 5005
		return -- 5007
	end -- 5007
	local lo = math.min(c.startX, c.endX) -- 5009
	local hi = math.max(c.startX, c.endX) -- 5010
	local next = self.cartAxle + dir * CART_SPEED * dt -- 5011
	if next < lo then -- 5011
		next = lo -- 5013
	end -- 5013
	if next > hi then -- 5013
		next = hi -- 5016
	end -- 5016
	local delta = next - self.cartAxle -- 5018
	if delta == 0 then -- 5018
		return -- 5020
	end -- 5020
	self.cartAxle = next -- 5022
	p.x = p.x + delta -- 5023
	p.facing = dir > 0 and 1 or -1 -- 5024
	self:slideX(p, 0) -- 5025
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5025
		self.gripping = false -- 5027
		self:flashSet("跟不上了，脱手", 0.6) -- 5028
		return -- 5029
	end -- 5029
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5029
		self.cartDocked = true -- 5032
		self.gripping = false -- 5033
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5034
		self:flashSet("车轮落窝", 1.2) -- 5035
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5035
		self:flashSet("车轮回到起点", 0.5) -- 5037
	end -- 5037
end -- 4974
function Play.prototype.requestRoom(self, key, reason) -- 5045
	if self.wantRoom ~= "" then -- 5045
		return -- 5049
	end -- 5049
	self.wantRoom = key -- 5051
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5052
end -- 5045
function Play.prototype.checkCarryGate(self) -- 5059
	if self.room.key == "checkpoint" then -- 5059
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5059
			self.carryCartAxle = self.cartAxle -- 5062
			self.carryCartDocked = self.cartDocked -- 5063
			self:requestRoom("gate", "检查站出口") -- 5064
			self:flashSet("出检查站 · 城门", 1.2) -- 5065
		end -- 5065
		return -- 5067
	end -- 5067
	if self.room.key == "outside" then -- 5067
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5067
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
	if self.isCampaign and self.reloadT > 0 then -- 5089
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
	if len < 0.001 then -- 5103
		dx = a.facing -- 5105
		dy = 0 -- 5106
	else -- 5106
		dx = dx / len -- 5108
		dy = dy / len -- 5109
	end -- 5109
	if dx ~= 0 then -- 5109
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
	if hit then -- 5133
		local i = hitEnemy.index -- 5135
		local e = self.enemies[i + 1] -- 5136
		local impactY = oy + dy * tEnemy -- 5137
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5138
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5139
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5139
			local pushRank = self:talentRank("push_force") -- 5141
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5142
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5143
			e.hitT = 0.3 -- 5144
			if reloadEffect == "push" then -- 5144
				local kb = 46 + 24 * pushRank -- 5146
				e.x = math.max( -- 5147
					self.room.minX + 20, -- 5147
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5147
				) -- 5147
				if pushRank > 0 then -- 5147
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
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5168
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5170
			self:blindNearby(e, blindRadius, i) -- 5171
		end -- 5171
		if reloadEffect == "push" then -- 5171
			local pushRank = self:talentRank("push_force") -- 5174
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5175
			if pushRank > 0 then -- 5175
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5177
			end -- 5177
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5179
		elseif reloadEffect == "echo" then -- 5179
			local echoRank = self:talentRank("echo_wide") -- 5181
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5182
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5183
		elseif reloadEffect == "light" then -- 5183
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5185
		end -- 5185
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5185
		self:damageProp(solid.box, 1) -- 5188
	else -- 5188
		self:flashSet("打空", 0.35) -- 5190
	end -- 5190
	if self.isCampaign then -- 5190
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
				if i == skipIndex then -- 5209
					goto __continue870 -- 5211
				end -- 5211
				local e = self.enemies[i + 1] -- 5213
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5213
					goto __continue870 -- 5215
				end -- 5215
				e.warnT = 0 -- 5217
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5218
				local pushDir = e.x >= center.x and 1 or -1 -- 5219
				e.x = math.max( -- 5220
					self.room.minX + 20, -- 5220
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5220
				) -- 5220
			end -- 5220
			::__continue870:: -- 5220
			i = i + 1 -- 5209
		end -- 5209
	end -- 5209
end -- 5207
function Play.prototype.applyFireDanger(self, shotX) -- 5225
	local ____temp_139 = self.isCampaign and self.run.joined -- 5226
	if ____temp_139 then -- 5226
		local ____opt_134 = self.room.campaign -- 5226
		local ____temp_138 = (____opt_134 and ____opt_134.chapter) == "S" -- 5227
		if not ____temp_138 then -- 5227
			local ____opt_136 = self.room.campaign -- 5227
			____temp_138 = (____opt_136 and ____opt_136.chapter) == "C" -- 5227
		end -- 5227
		____temp_139 = ____temp_138 -- 5226
	end -- 5226
	local isStorySc = ____temp_139 -- 5226
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5226
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
				if not e.alive then -- 5236
					goto __continue876 -- 5238
				end -- 5238
				local d = math.abs(e.x - self.partner.x) -- 5240
				if d < bestD then -- 5240
					bestD = d -- 5242
					best = i -- 5243
				end -- 5243
			end -- 5243
			::__continue876:: -- 5243
			i = i + 1 -- 5235
		end -- 5235
	end -- 5235
	if best >= 0 then -- 5235
		dangerX = self.enemies[best + 1].x -- 5247
	end -- 5247
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5247
		return -- 5251
	end -- 5251
	local exposed = self:childExposed(dangerX) -- 5253
	local before = self.escort.fear -- 5254
	local dangerId = self.nextDangerId -- 5255
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5256
	self.nextDangerId = self.nextDangerId + 1 -- 5257
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5258
	if after > before then -- 5258
		self:flashSet( -- 5260
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5260
			1 -- 5260
		) -- 5260
	elseif not exposed then -- 5260
		self:flashSet("枪声没够到她", 0.5) -- 5262
	end -- 5262
end -- 5225
function Play.prototype.childExposed(self, dangerX) -- 5267
	local c = self.partner -- 5268
	if not c.alive then -- 5268
		return false -- 5270
	end -- 5270
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5270
		self.boxes, -- 5273
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5273
	) then -- 5273
		return false -- 5274
	end -- 5274
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5274
		return false -- 5277
	end -- 5277
	local toDanger = dangerX - c.x -- 5279
	local toPlayer = self.player.x - c.x -- 5280
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5280
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
				if not e.alive then -- 5293
					goto __continue891 -- 5295
				end -- 5295
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5297
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5298
				if t >= 0 and (best < 0 or t < best) then -- 5298
					best = t -- 5300
					bestI = i -- 5301
				end -- 5301
			end -- 5301
			::__continue891:: -- 5301
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
			if box.broken == true or box.hidden == true then -- 5315
				goto __continue896 -- 5317
			end -- 5317
			local t = hitBox(ray, box) -- 5322
			if t > 2 and (best < 0 or t < best) then -- 5322
				best = t -- 5325
				bestBox = box -- 5326
			end -- 5326
		end -- 5326
		::__continue896:: -- 5326
	end -- 5326
	if ray.dy < 0 then -- 5326
		local t = -ray.y / ray.dy -- 5330
		if t >= 0 and (best < 0 or t < best) then -- 5330
			best = t -- 5332
			bestBox = nil -- 5333
		end -- 5333
	end -- 5333
	return {t = best, box = bestBox} -- 5336
end -- 5312
function Play.prototype.dropFor(self, e) -- 5340
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5340
		return -- 5342
	end -- 5342
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5342
		return -- 5345
	end -- 5345
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5347
	local ____self_pickups_140 = self.pickups -- 5347
	____self_pickups_140[#____self_pickups_140 + 1] = { -- 5348
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
	if b.breakable == nil or b.broken == true then -- 5356
		return -- 5358
	end -- 5358
	local ____b_breakable_141, ____hp_142 = b.breakable, "hp" -- 5358
	____b_breakable_141[____hp_142] = ____b_breakable_141[____hp_142] - amount -- 5360
	if b.breakable.hp > 0 then -- 5360
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5362
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5363
		return -- 5364
	end -- 5364
	b.broken = true -- 5366
	for ____, other in ipairs(self.boxes) do -- 5367
		if other.id ~= nil and other.id == b.id then -- 5367
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
	if road == nil or target == a.depth then -- 5384
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
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5391
				goto __continue914 -- 5396
			end -- 5396
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5398
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5399
			if a.depth <= front and next > front then -- 5399
				next = front -- 5401
			elseif a.depth >= back and next < back then -- 5401
				next = back -- 5403
			end -- 5403
		end -- 5403
		::__continue914:: -- 5403
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
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5417
					goto __continue921 -- 5419
				end -- 5419
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5419
					goto __continue921 -- 5422
				end -- 5422
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5422
					goto __continue921 -- 5425
				end -- 5425
				if nx + half > b.x0 and nx - half < b.x1 then -- 5425
					if a.x <= b.x0 then -- 5425
						nx = b.x0 - half -- 5429
					elseif a.x >= b.x1 then -- 5429
						nx = b.x1 + half -- 5431
					else -- 5431
						nx = a.x -- 5433
					end -- 5433
				end -- 5433
			end -- 5433
			::__continue921:: -- 5433
			i = i + 1 -- 5416
		end -- 5416
	end -- 5416
	if self.room.key == "outside" and not self.cartDocked and a.y < CART_CLEAR - 0.001 then -- 5416
		local bx0 = math.max(room.arch.x0, self.cartAxle - CART_HALF) -- 5440
		local bx1 = math.min(room.arch.x1, self.cartAxle + CART_HALF) -- 5441
		if bx1 > bx0 and nx + half > bx0 and nx - half < bx1 then -- 5441
			if a.x <= bx0 then -- 5441
				nx = bx0 - half -- 5444
			elseif a.x >= bx1 then -- 5444
				nx = bx1 + half -- 5446
			else -- 5446
				nx = a.x -- 5448
			end -- 5448
		end -- 5448
	end -- 5448
	local arch = room.arch -- 5456
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5456
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5458
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5458
			if a.x <= arch.x0 then -- 5458
				nx = arch.x0 - half -- 5461
			elseif a.x >= arch.x1 then -- 5461
				nx = arch.x1 + half -- 5463
			end -- 5463
		end -- 5463
	end -- 5463
	a.x = nx -- 5467
end -- 5410
function Play.prototype.fallY(self, a, dt) -- 5471
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5472
	if a.vy < -900 then -- 5472
		a.vy = -900 -- 5474
	end -- 5474
	local ny = a.y + a.vy * dt -- 5476
	local half = a.w / 2 -- 5477
	if a.vy <= 0 then -- 5477
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5480
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5481
		if ny <= ground then -- 5481
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
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5493
						goto __continue945 -- 5495
					end -- 5495
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5495
						goto __continue945 -- 5498
					end -- 5498
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5498
						goto __continue945 -- 5501
					end -- 5501
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5501
						ny = b.y0 - a.h -- 5504
						a.vy = 0 -- 5505
					end -- 5505
				end -- 5505
				::__continue945:: -- 5505
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
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5517
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
				if b.broken == true or b.hidden == true or b.soft == true then -- 5523
					goto __continue955 -- 5525
				end -- 5525
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5525
					g = b.y1 -- 5529
				end -- 5529
			end -- 5529
			::__continue955:: -- 5529
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
	if spanX <= halfW * 2 then -- 5548
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
	if spanY <= halfH * 2 then -- 5557
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
	if self.room.key == "prologue" then -- 5575
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5578
		if self.phase == "prologue-wake" then -- 5578
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5580
		elseif self.phase == "prologue-shadow" then -- 5580
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5582
		elseif self.phase == "prologue-escape" then -- 5582
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5584
		elseif self.phase == "prologue-hide" then -- 5584
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5586
		elseif self.phase == "prologue-wait" then -- 5586
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5588
		elseif self.phase == "prologue-give" then -- 5588
			parts[#parts + 1] = ("递物 " .. tostring(self.phaseTick)) .. "/60" -- 5590
		else -- 5590
			parts[#parts + 1] = "跟随" -- 5592
		end -- 5592
		if self.paused then -- 5592
			parts[#parts + 1] = "已暂停" -- 5595
		end -- 5595
		return table.concat(parts, " · ") -- 5597
	end -- 5597
	if self.room.key == "street" then -- 5597
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5600
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5601
		if self.paused then -- 5601
			parts[#parts + 1] = "已暂停" -- 5603
		end -- 5603
		return table.concat(parts, " · ") -- 5605
	end -- 5605
	if self.room.key == "gate" then -- 5605
		local ____temp_143 -- 5608
		if self.room.story == nil then -- 5608
			____temp_143 = nil -- 5608
		else -- 5608
			____temp_143 = self.room.story.gate -- 5608
		end -- 5608
		local g = ____temp_143 -- 5608
		if g ~= nil then -- 5608
			parts[#parts + 1] = self:gateLabel() -- 5610
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5611
				0, -- 5612
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5612
			))) .. " 秒" -- 5612
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5613
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5614
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5615
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5616
			if self.gateFailCount > 0 then -- 5616
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5618
			end -- 5618
			if self.flash ~= "" then -- 5618
				parts[#parts + 1] = self.flash -- 5621
			end -- 5621
		end -- 5621
		if self.paused then -- 5621
			parts[#parts + 1] = "已暂停" -- 5625
		end -- 5625
		return table.concat(parts, " · ") -- 5627
	end -- 5627
	if self.room.key == "forest" then -- 5627
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5630
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5631
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5632
		if self.caughtT > 0 then -- 5632
			parts[#parts + 1] = "复位中" -- 5634
		end -- 5634
		if self.paused then -- 5634
			parts[#parts + 1] = "已暂停" -- 5637
		end -- 5637
		return table.concat(parts, " · ") -- 5639
	end -- 5639
	if self.room.key == "tower" then -- 5639
		if self.phase == "tower-wait" then -- 5639
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5643
		elseif self.phase == "tower-knock" then -- 5643
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5645
		elseif self.phase == "tower-enter" then -- 5645
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5647
		elseif self.phase == "tower-desk" then -- 5647
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5649
		elseif self.phase == "tower-given" then -- 5649
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5651
		else -- 5651
			parts[#parts + 1] = "片尾" -- 5653
		end -- 5653
		if self.paused then -- 5653
			parts[#parts + 1] = "已暂停" -- 5656
		end -- 5656
		return table.concat(parts, " · ") -- 5658
	end -- 5658
	if self.room.key == "village" then -- 5658
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5661
		if self.hasBottle then -- 5661
			parts[#parts + 1] = "有瓶" -- 5663
		elseif self.bottleFly ~= nil then -- 5663
			parts[#parts + 1] = "瓶在飞" -- 5665
		else -- 5665
			parts[#parts + 1] = "空手" -- 5667
		end -- 5667
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5669
		if self.scavChase then -- 5669
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5671
		end -- 5671
		if self.passed then -- 5671
			parts[#parts + 1] = "已过通行线" -- 5674
		end -- 5674
		if self.paused then -- 5674
			parts[#parts + 1] = "已暂停" -- 5677
		end -- 5677
		return table.concat(parts, " · ") -- 5679
	end -- 5679
	local isChild = self.childMode -- 5682
	if isChild then -- 5682
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5684
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5685
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5686
	else -- 5686
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5688
		if p.rollT > 0 then -- 5688
			parts[#parts + 1] = "翻滚中" -- 5690
		end -- 5690
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5692
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5693
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5694
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5695
	end -- 5695
	if self.checkpoint >= 0 then -- 5695
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5698
	end -- 5698
	if self.paused then -- 5698
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
			if self.enemies[i + 1].alive then -- 5710
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
			if e.alive and e.warnT > 0 then -- 5722
				return true -- 5724
			end -- 5724
			i = i + 1 -- 5721
		end -- 5721
	end -- 5721
	return false -- 5727
end -- 5720
function Play.prototype.gateSecondsLeft(self) -- 5730
	local ____temp_144 -- 5731
	if self.room.story == nil then -- 5731
		____temp_144 = nil -- 5731
	else -- 5731
		____temp_144 = self.room.story.gate -- 5731
	end -- 5731
	local g = ____temp_144 -- 5731
	if g == nil then -- 5731
		return 0 -- 5733
	end -- 5733
	return math.max( -- 5735
		0, -- 5735
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5735
	) -- 5735
end -- 5730
function Play.prototype.gateLabel(self) -- 5738
	if self.phase == "gate-idle" then -- 5738
		return "待就位" -- 5740
	end -- 5740
	if self.phase == "gate-hold" then -- 5740
		return "守点中" -- 5743
	end -- 5743
	if self.phase == "gate-send" then -- 5743
		return "送别" -- 5746
	end -- 5746
	if self.phase == "gate-count" then -- 5746
		return "数数 " .. tostring(self.countTick) -- 5749
	end -- 5749
	return "她走" -- 5751
end -- 5738
function Play.prototype.dogLabel(self) -- 5755
	if self.dogState == "ear" then -- 5755
		return "转耳" -- 5757
	end -- 5757
	if self.dogState == "chase" then -- 5757
		return "追" -- 5760
	end -- 5760
	if self.dogState == "sniff" then -- 5760
		return "停" -- 5763
	end -- 5763
	if self.dogState == "back" then -- 5763
		return "回线" -- 5766
	end -- 5766
	return "巡逻" -- 5768
end -- 5755
function Play.prototype.doorXOf(self) -- 5771
	local ____temp_145 -- 5772
	if self.room.story == nil then -- 5772
		____temp_145 = nil -- 5772
	else -- 5772
		____temp_145 = self.room.story.tower -- 5772
	end -- 5772
	local t = ____temp_145 -- 5772
	return t == nil and 0 or t.doorX -- 5773
end -- 5771
function Play.prototype.scavLabel(self) -- 5777
	if self.scavState == "chase" then -- 5777
		return "追" -- 5779
	end -- 5779
	if self.scavState == "turn" then -- 5779
		return "转头" -- 5782
	end -- 5782
	if self.scavState == "walk" then -- 5782
		return "赶来" -- 5785
	end -- 5785
	if self.scavState == "stall" then -- 5785
		return "停住" -- 5788
	end -- 5788
	if self.scavState == "back" then -- 5788
		return "回位" -- 5791
	end -- 5791
	return "巡逻" -- 5793
end -- 5777
function Play.prototype.hintText(self) -- 5797
	if self.paused then -- 5797
		return "Esc 继续 · R 重置" -- 5799
	end -- 5799
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5799
		if self:threatened() then -- 5799
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5805
		end -- 5805
		if self.coverHug then -- 5805
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5808
		end -- 5808
		if self.coverNear then -- 5808
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5811
		end -- 5811
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5813
	end -- 5813
	if self.flash ~= "" then -- 5813
		return self.flash -- 5816
	end -- 5816
	if self.room.key == "prologue" then -- 5816
		if self.phase == "prologue-wake" then -- 5816
			return "父亲在门外唤 · 小满睁眼" -- 5820
		end -- 5820
		if self.phase == "prologue-shadow" then -- 5820
			return "墙上两道人影 · 碗滚到脚边" -- 5823
		end -- 5823
		if self.phase == "prologue-escape" then -- 5823
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5826
		end -- 5826
		if self.phase == "prologue-hide" then -- 5826
			return "柜门合上 · 屏住呼吸" -- 5829
		end -- 5829
		if self.phase == "prologue-wait" then -- 5829
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5832
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5833
		end -- 5833
		if self.phase == "prologue-give" then -- 5833
			return ("递物 " .. tostring(self.phaseTick)) .. " / 60 拍 · 站着别动" -- 5836
		end -- 5836
		return "她跟着你了 · 两人一起走到门口 680" -- 5838
	end -- 5838
	if self.room.key == "street" then -- 5838
		if self:aliveEnemies() > 0 then -- 5838
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5842
		end -- 5842
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5844
	end -- 5844
	if self.room.key == "gate" then -- 5844
		local ____temp_146 -- 5847
		if self.room.story == nil then -- 5847
			____temp_146 = nil -- 5847
		else -- 5847
			____temp_146 = self.room.story.gate -- 5847
		end -- 5847
		local g = ____temp_146 -- 5847
		if g ~= nil then -- 5847
			if self.phase == "gate-idle" then -- 5847
				if self.gateNeedConfirm then -- 5847
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5851
				end -- 5851
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5853
			end -- 5853
			if self.phase == "gate-hold" then -- 5853
				if self.coveredFlash > 0 then -- 5853
					return "掩体挡下了这一枪 · 别露头" -- 5857
				end -- 5857
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5859
			end -- 5859
			if self.phase == "gate-send" then -- 5859
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5862
			end -- 5862
			if self.phase == "gate-count" then -- 5862
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5862
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5866
				end -- 5866
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5868
			end -- 5868
			return "她自己走 · 跟着出城门 1120" -- 5870
		end -- 5870
	end -- 5870
	if self.room.key == "forest" then -- 5870
		if self.dogState == "chase" then -- 5870
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5875
		end -- 5875
		if self.dogState == "ear" then -- 5875
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5878
		end -- 5878
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5880
	end -- 5880
	if self.room.key == "tower" then -- 5880
		if self.phase == "tower-wait" then -- 5880
			return "走到门前 445 点一次 E 敲两下" -- 5884
		end -- 5884
		if self.phase == "tower-knock" then -- 5884
			return "敲两下 · 等门开" -- 5887
		end -- 5887
		if self.phase == "tower-given" then -- 5887
			return "递交针套和纸条 · 看登记簿最后一行" -- 5890
		end -- 5890
		return "片尾 · 点 E 再玩一次，回到序章" -- 5892
	end -- 5892
	if self.room.key == "village" then -- 5892
		if self.bottleFly ~= nil then -- 5892
			return "等瓶子落地 · 触地才发声" -- 5896
		end -- 5896
		if self.hasBottle then -- 5896
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5899
		end -- 5899
		if self.passed then -- 5899
			return "已过第一院 · R 重置可再来一遍" -- 5902
		end -- 5902
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5904
	end -- 5904
	if self.room.key == "outside" then -- 5904
		if self.focusCart then -- 5904
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5908
		end -- 5908
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5910
	end -- 5910
	if self.escort.state == "frozen" then -- 5910
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5910
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5914
		end -- 5914
		return "小满吓住了 · 走过去，靠近再点 E" -- 5916
	end -- 5916
	if self.escort.state == "calming" then -- 5916
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
	if px1 <= px0 or py1 <= py0 then -- 5978
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
			local ____temp_147 -- 5989
			if f.y == 0 then -- 5989
				____temp_147 = self.room.depth -- 5989
			else -- 5989
				____temp_147 = nil -- 5989
			end -- 5989
			local road = ____temp_147 -- 5989
			local y = self:sy(f.y + (road and road.min or 0), h) -- 5990
			local x0 = self:sx(f.x0, w) -- 5991
			local x1 = self:sx(f.x1, w) -- 5992
			local deck = self:px(5) -- 5993
			if road ~= nil then -- 5993
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
				if b.id == "braced_shield" or b.hidden == true then -- 6006
					goto __continue1086 -- 6008
				end -- 6008
				if b.broken == true then -- 6008
					if b.breakable ~= nil then -- 6008
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
					goto __continue1086 -- 6021
				end -- 6021
				local ____opt_150 = b.depth -- 6021
				local front = ____opt_150 and ____opt_150.min or 0 -- 6023
				local ____opt_152 = b.depth -- 6023
				local back = ____opt_152 and ____opt_152.max or 0 -- 6024
				local fill = SOLID_FILL -- 6025
				local line = SOLID_EDGE -- 6026
				if b.soft == true then -- 6026
					fill = SOFT -- 6028
					line = SOFT_LINE -- 6029
				elseif b.breakable ~= nil then -- 6029
					line = DANGER_LINE -- 6031
					fill = Color(0.3, 0.24, 0.16, 1) -- 6032
				elseif b.interact ~= nil then -- 6032
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
				if b.breakable ~= nil then -- 6038
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
			::__continue1086:: -- 6043
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
				if self.run.taken[pk.id] == true then -- 6052
					goto __continue1098 -- 6054
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
			::__continue1098:: -- 6061
			i = i + 1 -- 6051
		end -- 6051
	end -- 6051
	if self.bracedShield ~= nil then -- 6051
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
			if z.tint == 2 then -- 6077
				fill = SOFT -- 6079
				line = SOFT_LINE -- 6080
			elseif z.tint == 3 then -- 6080
				fill = BRICK -- 6082
				line = BRICK_LINE -- 6083
			elseif z.tint == 4 then -- 6083
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
	if a.h <= 0 then -- 6095
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
	if c.bodyW <= 0 then -- 6106
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
	if p.covered then -- 6117
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
	elseif self.coverNear and not isChild then -- 6123
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
	if q.alive then -- 6129
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
			if e.alive then -- 6139
				local ef = p.x >= e.x and 1 or -1 -- 6141
				if e.kind == "shield" then -- 6141
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
				elseif e.kind == "breaker" then -- 6145
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
			if e.alive and e.warnT > 0 then -- 6148
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
				if m.kind ~= 0 then -- 6172
					goto __continue1124 -- 6174
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
			::__continue1124:: -- 6180
			k = k + 1 -- 6171
		end -- 6171
	end -- 6171
	local j = 0 -- 6184
	do -- 6184
		j = 0 -- 6185
		while j < #self.room.marks do -- 6185
			do -- 6185
				local m = self.room.marks[j + 1] -- 6186
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 6186
					goto __continue1127 -- 6188
				end -- 6188
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 6188
					goto __continue1127 -- 6192
				end -- 6192
				local col = STAND -- 6194
				if m.kind == 4 then -- 6194
					col = PASS_LINE -- 6196
				elseif m.kind == 5 then -- 6196
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
			::__continue1127:: -- 6202
			j = j + 1 -- 6185
		end -- 6185
	end -- 6185
	local t = 0 -- 6205
	do -- 6205
		t = 0 -- 6206
		while t < #self.room.marks do -- 6206
			do -- 6206
				local m = self.room.marks[t + 1] -- 6207
				if m.kind ~= 6 then -- 6207
					goto __continue1133 -- 6209
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
			::__continue1133:: -- 6214
			t = t + 1 -- 6206
		end -- 6206
	end -- 6206
	if self.room.key == "village" then -- 6206
		self:drawVillage(draw, w, h) -- 6217
	end -- 6217
	if self.room.key == "forest" then -- 6217
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
	if self.dogState == "ear" or self.dogState == "chase" then -- 6229
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
	if bottle ~= nil then -- 6238
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
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6240
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
	if s ~= nil then -- 6250
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
		if self.scavState == "turn" then -- 6254
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
	if self.hasBottle then -- 6257
		local p = self.player -- 6262
		self:drawBottle( -- 6263
			draw, -- 6263
			w, -- 6263
			h, -- 6263
			p.x + p.facing * 10, -- 6263
			p.y + p.h * 0.62 -- 6263
		) -- 6263
	end -- 6263
	if self.bottleFly ~= nil then -- 6263
		self:drawBottle( -- 6266
			draw, -- 6266
			w, -- 6266
			h, -- 6266
			self.bottleFly.x, -- 6266
			self.bottleFly.y -- 6266
		) -- 6266
	end -- 6266
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6266
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
	if t == nil or self.traceT <= 0 then -- 6279
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
	if self.room.key == "village" and self.hasBottle then -- 6300
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