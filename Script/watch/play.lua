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
function makeActor(room, index) -- 6361
	local sp = room.spawns -- 6362
	if index < 0 or index >= #sp then -- 6362
		return { -- 6364
			x = 0, -- 6364
			y = 0, -- 6364
			depth = 0, -- 6364
			depthSpeed = 0, -- 6364
			vx = 0, -- 6364
			vy = 0, -- 6364
			w = CHILD_W, -- 6364
			h = CHILD_H, -- 6364
			onGround = true, -- 6364
			facing = 1, -- 6364
			crouch = false, -- 6364
			rollT = 0, -- 6364
			covered = false, -- 6364
			alive = false -- 6364
		} -- 6364
	end -- 6364
	local s = sp[index + 1] -- 6366
	local child = s.h < SOLDIER_H -- 6367
	local ground = room.depth -- 6368
	local depth = ground == nil and 0 or math.max( -- 6369
		ground.min, -- 6369
		math.min(ground.max, s.depth or 0) -- 6369
	) -- 6369
	return { -- 6370
		x = s.x, -- 6371
		y = s.y, -- 6371
		depth = depth, -- 6371
		depthSpeed = 0, -- 6371
		vx = 0, -- 6371
		vy = 0, -- 6371
		w = child and CHILD_W or SOLDIER_W, -- 6372
		h = child and CHILD_H or SOLDIER_H, -- 6373
		onGround = true, -- 6374
		facing = 1, -- 6374
		crouch = false, -- 6374
		rollT = 0, -- 6374
		covered = false, -- 6374
		alive = true -- 6374
	} -- 6374
end -- 6374
function drawFigure(draw, play, w, h, a, body, head) -- 6378
	if not a.alive then -- 6378
		return -- 6380
	end -- 6380
	local x0 = a.x - a.w / 2 -- 6382
	local x1 = a.x + a.w / 2 -- 6383
	local y0 = a.y + a.depth * DEPTH_Y_SCALE -- 6384
	local y1 = y0 + a.h -- 6385
	play:drawBox( -- 6386
		draw, -- 6386
		w, -- 6386
		h, -- 6386
		x0, -- 6386
		x1, -- 6386
		y0, -- 6386
		y1 - a.h * 0.26, -- 6386
		body -- 6386
	) -- 6386
	play:drawBox( -- 6387
		draw, -- 6387
		w, -- 6387
		h, -- 6387
		x0 + 2, -- 6387
		x1 - 2, -- 6387
		y1 - a.h * 0.26, -- 6387
		y1, -- 6387
		head -- 6387
	) -- 6387
	local eyeX = a.facing > 0 and a.x + a.w * 0.16 or a.x - a.w * 0.28 -- 6389
	play:drawBox( -- 6390
		draw, -- 6390
		w, -- 6390
		h, -- 6390
		eyeX, -- 6390
		eyeX + 4, -- 6390
		y1 - a.h * 0.14, -- 6390
		y1 - a.h * 0.08, -- 6390
		INK -- 6390
	) -- 6390
end -- 6390
--- 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。
function ____exports.screenToWorld(sx, sy, cam, view) -- 6394
	return {x = cam.x + ((sx - view.ox) / view.zoom - ____exports.LOGIC_W / 2) * ____exports.UNITS_PER_PX, y = cam.y + ((sy - view.oy) / view.zoom - ____exports.LOGIC_H / 2) * ____exports.UNITS_PER_PX} -- 6395
end -- 6394
--- screenToWorld 的反函数：给回放和调试把世界坐标换成准星屏幕坐标。
function ____exports.worldToScreen(wx, wy, cam, view) -- 6402
	return {x = ((wx - cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2) * view.zoom + view.ox, y = ((wy - cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2) * view.zoom + view.oy} -- 6403
end -- 6402
function rayInterval(origin, direction, min, max) -- 6410
	if direction == 0 then -- 6410
		return (origin < min or origin > max) and ({min = 1, max = 0}) or ({min = -math.huge, max = math.huge}) -- 6412
	end -- 6412
	local a = (min - origin) / direction -- 6414
	local b = (max - origin) / direction -- 6415
	return { -- 6416
		min = math.min(a, b), -- 6416
		max = math.max(a, b) -- 6416
	} -- 6416
end -- 6416
function hitBox(ray, box) -- 6420
	local x = rayInterval(ray.x, ray.dx, box.x0, box.x1) -- 6421
	local y = rayInterval(ray.y, ray.dy, box.y0, box.y1) -- 6422
	local enter = math.max(0, x.min, y.min) -- 6423
	local leave = math.min(99999, x.max, y.max) -- 6424
	if box.depth ~= nil then -- 6424
		local depth = rayInterval(ray.depth or 0, ray.dDepth or 0, box.depth.min, box.depth.max) -- 6426
		enter = math.max(enter, depth.min) -- 6427
		leave = math.min(leave, depth.max) -- 6428
	end -- 6428
	return leave >= enter and enter or -1 -- 6430
end -- 6430
function drawCartShape(draw, play, w, h, c, axleX) -- 6433
	local half = c.bodyW / 2 -- 6434
	local x0 = axleX - half -- 6435
	local x1 = axleX + half -- 6436
	local axleY = c.baseY + (c.depth or 0) * DEPTH_Y_SCALE + c.wheelR -- 6437
	play:drawBox( -- 6438
		draw, -- 6438
		w, -- 6438
		h, -- 6438
		x0, -- 6438
		x1, -- 6438
		axleY, -- 6438
		axleY + c.bodyH, -- 6438
		CART_FILL -- 6438
	) -- 6438
	draw:drawCircle( -- 6439
		Vec2( -- 6439
			play:sx(x0 + c.bodyW * 0.28, w), -- 6439
			play:sy(axleY, h) -- 6439
		), -- 6439
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6439
		Color(52, 50, 48, 255) -- 6439
	) -- 6439
	draw:drawCircle( -- 6440
		Vec2( -- 6440
			play:sx(x1 - c.bodyW * 0.28, w), -- 6440
			play:sy(axleY, h) -- 6440
		), -- 6440
		play:px(c.wheelR / ____exports.UNITS_PER_PX), -- 6440
		Color(52, 50, 48, 255) -- 6440
	) -- 6440
	local cx = c.clothSide < 0 and x0 or x1 -- 6441
	play:drawBox( -- 6442
		draw, -- 6442
		w, -- 6442
		h, -- 6442
		cx - 10, -- 6442
		cx + 10, -- 6442
		axleY + c.bodyH, -- 6442
		axleY + c.bodyH + 18, -- 6442
		CLOTH -- 6442
	) -- 6442
end -- 6442
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
--- 序章 P03 柜边递针套特写时长：3.0 秒 = 180 拍（对齐分镜稿与 D01 对白节拍）。
____exports.PROLOGUE_GIVE_TICKS = 180 -- 59
--- 城门 P05 送别嘱咐独立演出时长：约 3.67 秒 = 220 拍（演完再切入 24 秒数到二十，零叠字叠音）。
____exports.GATE_FAREWELL_TICKS = 220 -- 61
--- 小满贴住倒柜左缘（段内 x，柜体从 152 起；玩家半宽 14）即拉门入柜。
____exports.PROLOGUE_CABINET_X = 132 -- 63
function ____exports.gateCountAtTick(tick) -- 65
	if tick >= ____exports.GATE_COUNT_END then -- 65
		return 20 -- 66
	end -- 66
	if tick >= 1260 then -- 66
		return 19 -- 67
	end -- 67
	if tick >= 1080 then -- 67
		return 18 -- 68
	end -- 68
	if tick >= 480 then -- 68
		return 11 + math.floor((tick - 480) * 7 / 600) -- 69
	end -- 69
	return 1 + math.floor(math.max(0, tick) / 48) -- 70
end -- 65
--- 投瓶的固定飞行时长（秒）：触地拍 = 松手拍 + 37 拍。
local BOTTLE_FLY_TIME = 0.62 -- 73
CHILD_W = 28 -- 148
CHILD_H = 56 -- 149
local CHILD_CROUCH_H = 34 -- 150
local CHILD_SPEED = 160 -- 151
local CHILD_SLOW = 80 -- 152
local CHILD_JUMP = 320 -- 153
SOLDIER_W = 30 -- 156
SOLDIER_H = 88 -- 157
local SOLDIER_SPEED = 264 -- 158
local ROLL_TIME = 0.35 -- 159
local ROLL_SPEED = 280 -- 160
--- 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。
local SOLDIER_JUMP = 340 -- 162
local LEDGE_RISE = 60 -- 163
--- 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。
____exports.LOGIC_W = 320 -- 166
____exports.LOGIC_H = 180 -- 167
____exports.UNITS_PER_PX = 2 -- 168
--- 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。
local GROUND_PX = 40 -- 170
local CAM_FOLLOW = 9 -- 171
local CAM_LOOK_UP = 46 -- 172
--- 拉车速度：规划初值 64 单位/秒。
local CART_SPEED = 64 -- 175
--- 握把触发半径。
____exports.CART_REACH = 70 -- 177
--- 城门敌兵：举枪预警 36 拍、开火冷却 150 拍、射程 480。
local WARN_TICKS = 36 -- 180
--- 战具格与消耗品格各只放一件；满包时新东西留在原地，不吞物。
local TOOL_CAP = 1 -- 182
local CONSUMABLE_CAP = 1 -- 183
--- 废木料制木楔要按住 E 的有效拍数。
local CRAFT_TICKS = 45 -- 185
--- 受伤后的保护拍数：t+41 仍在保护，t+42 可以再次扣血。
local INVULN_HIT_TICKS = 42 -- 187
--- 被击倒复活后的保护拍数（1.2 秒）。
local INVULN_RESPAWN_TICKS = 72 -- 189
local FIRE_COOLDOWN = 150 -- 190
--- 新版关卡火器手的装填周期：比基础值长，给握车柄的玩家留出看枪口、停手、再推的窗口。
local CAMPAIGN_FIRE_COOLDOWN = 240 -- 192
local ENEMY_RANGE = 760 -- 193
--- 洞后墙根小路的尽头：走到这里才切村口（D4 扩图后不再是 388）。
local WALL_ROAD_END = 1150 -- 195
--- 走路时能自动抬脚的高度：矮台阶直接走上去，柜台 44 仍要跳。
local STEP_UP = 24 -- 197
local DEPTH_SPEED_RATIO = 0.55 -- 198
local DIAGONAL_SCALE = 1 / math.sqrt(2) -- 199
INK = Color(232, 232, 228, 255) -- 201
local INK_DIM = Color(150, 152, 150, 255) -- 202
local BG_VOID = Color(8, 9, 10, 255) -- 203
local BG_FAR = Color(24, 26, 28, 255) -- 204
local BG_MID = Color(31, 34, 37, 255) -- 205
local GROUND = Color(112, 114, 112, 255) -- 206
local FLOOR_DECK = Color(66, 70, 72, 255) -- 207
local SOLID_FILL = Color(84, 86, 84, 255) -- 208
local SOLID_EDGE = Color(126, 130, 126, 255) -- 209
CART_FILL = Color(122, 78, 56, 255) -- 210
CLOTH = Color(178, 52, 46, 255) -- 211
local DANGER = Color(150, 54, 48, 46) -- 212
local DANGER_LINE = Color(178, 78, 64, 200) -- 213
local HOLE_FILL = Color(10, 11, 12, 255) -- 214
local SOLDIER_BODY = Color(96, 148, 196, 255) -- 215
local SOLDIER_HEAD = Color(206, 214, 220, 255) -- 216
local CHILD_BODY = Color(214, 168, 96, 255) -- 217
local CHILD_HEAD = Color(232, 214, 186, 255) -- 218
local ENEMY_BODY = Color(176, 92, 84, 255) -- 219
local ENEMY_DEAD = Color(86, 74, 74, 255) -- 220
local CHECK = Color(96, 186, 122, 255) -- 221
local STAND = Color(226, 186, 84, 255) -- 222
local AIM = Color(236, 236, 232, 230) -- 223
local AIM_HIT = Color(236, 96, 84, 255) -- 224
--- 村口：软土、砖地、通行线、瓶与拾荒者。
local SOFT = Color(96, 78, 58, 70) -- 226
local SOFT_LINE = Color(140, 112, 80, 190) -- 227
local BRICK = Color(126, 118, 110, 70) -- 228
local BRICK_LINE = Color(160, 152, 142, 200) -- 229
local PASS = Color(96, 186, 122, 40) -- 230
local PASS_LINE = Color(96, 186, 122, 200) -- 231
local BOTTLE = Color(120, 186, 160, 255) -- 232
local SCAV_BODY = Color(128, 118, 96, 255) -- 233
local SCAV_HEAD = Color(196, 182, 158, 255) -- 234
--- 取能容纳 320×180 画布的最大整数倍，并把画布居中。
function ____exports.computeViewport(w, h) -- 321
	local zoom = math.floor(math.min(w / ____exports.LOGIC_W, h / ____exports.LOGIC_H)) -- 322
	if zoom < 1 then -- 322
		zoom = 1 -- 324
	end -- 324
	return { -- 326
		zoom = zoom, -- 327
		ox = math.floor((w - ____exports.LOGIC_W * zoom) / 2), -- 328
		oy = math.floor((h - ____exports.LOGIC_H * zoom) / 2) -- 329
	} -- 329
end -- 321
--- 每个房间进入时的剧情初态。
local function phaseOf(key) -- 352
	if key == "prologue" then -- 352
		return "prologue-wait" -- 356
	end -- 356
	if key == "street" then -- 356
		return "street-run" -- 359
	end -- 359
	if key == "gate" then -- 359
		return "gate-idle" -- 362
	end -- 362
	if key == "gatepath" then -- 362
		return "gatepath-start" -- 365
	end -- 365
	if key == "forest" then -- 365
		return "forest-run" -- 368
	end -- 368
	if key == "tower" then -- 368
		return "tower-wait" -- 371
	end -- 371
	if key == "museum" then -- 371
		return "museum-cabinet" -- 374
	end -- 374
	return "run" -- 376
end -- 352
____exports.Play = __TS__Class() -- 379
local Play = ____exports.Play -- 379
Play.name = "Play" -- 379
function Play.prototype.____constructor(self, room, resume, run) -- 689
	self.enemies = {} -- 384
	self.boxes = {} -- 385
	self.floors = {} -- 386
	self.checkpoint = -1 -- 388
	self.flash = "" -- 390
	self.flashT = 0 -- 391
	self.traceT = 0 -- 394
	self.focusCart = false -- 396
	self.knocks = 0 -- 398
	self.knockT = 0 -- 399
	self.cartAxle = 0 -- 403
	self.cartDocked = false -- 405
	self.gripping = false -- 407
	self.gateOpen = false -- 409
	self.calmConsumed = false -- 411
	self.craftT = 0 -- 413
	self.nextDangerId = 1 -- 415
	self.wantRoom = "" -- 417
	self.carryCartAxle = -1 -- 419
	self.carryCartDocked = false -- 420
	self.checkpointCartAxle = -1 -- 422
	self.hasBottle = false -- 426
	self.bottleLandX = -1 -- 430
	self.bottleTargetX = -1 -- 431
	self.bottleTargetY = 0 -- 432
	self.bottleLandT = 0 -- 433
	self.aimHold = 0 -- 435
	self.redCartPulled = false -- 437
	self.redCartMemoryT = 0 -- 439
	self.footHintT = 0 -- 441
	self.ditchHinted = false -- 443
	self.forestPath = "" -- 445
	self.waterSeen = false -- 447
	self.scavStallBonus = 0 -- 449
	self.intentGateReunionHold = false -- 451
	self.pendingMuseumIntentTarget = "" -- 453
	self.scavX = 0 -- 455
	self.scavDir = 1 -- 456
	self.scavState = "patrol" -- 457
	self.scavT = 0 -- 458
	self.scavTargetX = 0 -- 459
	self.passed = false -- 461
	self.childMode = false -- 465
	self.phase = "" -- 467
	self.phaseTick = 0 -- 469
	self.gateTick = 0 -- 471
	self.countTick = 0 -- 473
	self.countArmed = false -- 475
	self.countPrevMove = 0 -- 477
	self.caughtT = 0 -- 479
	self.hp = 3 -- 481
	self.maxHp = 3 -- 482
	self.invulnT = 0 -- 488
	self.partnerStuck = 0 -- 490
	self.partnerLaneIdx = 0 -- 492
	self.partnerLaneHold = 0 -- 493
	self.coveredFlash = 0 -- 495
	self.coverHug = false -- 497
	self.coverNear = false -- 499
	self.coverEntity = "" -- 501
	self.coverBlocking = false -- 503
	self.gateNeedConfirm = false -- 505
	self.gateRestartArmed = true -- 507
	self.bottleAimX = -1 -- 509
	self.bottleAimY = 0 -- 510
	self.bottleSurfaceY = -1 -- 512
	self.bottleLandY = 0 -- 514
	self.events = {} -- 516
	self.eventSeq = 0 -- 518
	self.dogX = 0 -- 520
	self.dogDir = 1 -- 521
	self.dogState = "patrol" -- 522
	self.dogT = 0 -- 523
	self.dogTargetX = 0 -- 524
	self.scavSee = 0 -- 526
	self.scavChase = false -- 527
	self.gateSpawned = 0 -- 529
	self.gateFailCount = 0 -- 531
	self.isCampaign = false -- 535
	self.archiveDirty = false -- 543
	self.sessionDirty = false -- 545
	self.restartStory = false -- 547
	self.wellOpen = false -- 549
	self.wellX = 430 -- 551
	self.wellTaken = false -- 553
	self.museumReturn = false -- 555
	self.endingLines = {"", ""} -- 557
	self.towerDoorOpen = false -- 559
	self.towerHanded = false -- 560
	self.deskHold = 0 -- 561
	self.towerEndMustRelease = false -- 563
	self.equippedWeapon = "standard_gun" -- 576
	self.craftBench = { -- 578
		active = false, -- 579
		firstCraftDone = false, -- 580
		justCraftedTimer = 0, -- 581
		inventory = {}, -- 582
		recipes = {}, -- 583
		equippedWeapon = "standard_gun" -- 584
	} -- 584
	self.handledCraftRequests = {} -- 587
	self.benchReach = 48 -- 589
	self.pickups = {} -- 593
	self.reloadT = 0 -- 595
	self.objectiveDone = false -- 599
	self.hint = "" -- 601
	self.roomStartTick = 0 -- 603
	self.cartHitT = 0 -- 605
	self.cartExposed = false -- 606
	self.storyRoute = "" -- 610
	self.storySettled = false -- 612
	self.hpAtGate = -1 -- 614
	self.maxHpAtGate = -1 -- 615
	self.handTicks = 0 -- 617
	self.handNeedTicks = ____exports.GATE_HAND_TICKS -- 619
	self.handArmed = false -- 621
	self.handDone = false -- 623
	self.lineSaid = false -- 624
	self.tied = false -- 626
	self.pathDone = false -- 628
	self.carryOn = false -- 630
	self.escortDone = false -- 632
	self.escapeDuration = ____exports.PROLOGUE_ESCAPE_TICKS / 60 -- 636
	self.escapeRemaining = 0 -- 638
	self.escapeRetryCount = 0 -- 640
	self.introTick = 0 -- 642
	self.reloadOpen = false -- 646
	self.reloadAnswerTicks = 0 -- 648
	self.reloadWorldTicks = 0 -- 650
	self.reloadPath = {RELOAD_START} -- 652
	self.reloadPendingEffect = "" -- 654
	self.reloadTryCount = 0 -- 656
	self.talentModalActive = false -- 659
	self.useEscortDeathSummary = false -- 660
	self.escortFailed = false -- 661
	self.escortFailedTicks = 0 -- 662
	self.escortSummary = nil -- 663
	self.fieldWedgeSeq = 0 -- 671
	self.paused = false -- 673
	self.ticks = 0 -- 675
	self.view = {zoom = 1, ox = 0, oy = 0} -- 677
	self.ox = 0 -- 679
	self.aimX = 0 -- 681
	self.aimY = 0 -- 682
	self.viewW = 0 -- 684
	self.viewH = 0 -- 685
	self.ox = room.originX -- 691
	self.room = withOrigin(room) -- 692
	local wr = self.room -- 693
	self.run = run or createRun() -- 694
	self.inventory = self.run.inventory -- 695
	self.archive = self.run.archive -- 696
	local story = self.run.story -- 697
	local savedEq = story.equippedWeapon -- 698
	if savedEq == ARTIFACT_WEAPON_ID and self.archive.artifactOwned then -- 698
		self.equippedWeapon = ARTIFACT_WEAPON_ID -- 700
	elseif savedEq == "standard_gun" or savedEq ~= "" and savedEq == story.craftedWeapon then -- 700
		self.equippedWeapon = savedEq -- 702
	else -- 702
		self.equippedWeapon = story.craftedWeapon == "" and "standard_gun" or story.craftedWeapon -- 704
	end -- 704
	self.isCampaign = wr.campaign ~= nil -- 706
	self.cam = {x = (wr.minX + wr.maxX) / 2, y = wr.height / 2} -- 707
	self:buildWorld() -- 708
	local lockedRoute = self.run.story == nil and "" or self.run.story.route -- 711
	local soldierRoom = (wr.key == "outside" or wr.key == "tower") and lockedRoute == "soldier" -- 713
	self.childMode = not soldierRoom and (wr.key == "outside" or wr.key == "village" or wr.key == "forest" or wr.key == "tower") -- 714
	local soloRoom = wr.key == "museum" -- 716
	local playerIdx = wr.key == "checkpoint" and 1 or 0 -- 717
	local partnerIdx = soloRoom and -1 or (wr.key == "checkpoint" and 0 or (self.childMode and -1 or 1)) -- 718
	self.player = makeActor(wr, playerIdx) -- 719
	self.partner = makeActor(wr, partnerIdx) -- 720
	self.phase = phaseOf(wr.key) -- 721
	if soloRoom then -- 721
		local mp = self.archive.museumPhase -- 724
		self.phase = mp == "hall_walk" and "museum-hall" or (mp == "lamp_turn" and "museum-lamp" or (mp == "return_cabinet" and "museum-return" or (mp == "done" and "museum-done" or "museum-cabinet"))) -- 725
	end -- 725
	if wr.story ~= nil then -- 725
		self.dogX = wr.story.dog == nil and 0 or wr.story.dog.x0 -- 731
	end -- 731
	self.cam.x = self.player.x -- 733
	self.cam.y = self.player.y + CAM_LOOK_UP -- 734
	self.cartAxle = wr.cart.startX -- 735
	self.escort = __TS__New( -- 736
		Escort, -- 736
		safeAnchorX(wr.marks) -- 736
	) -- 736
	self.scavX = wr.scavenger ~= nil and wr.scavenger.x0 or 0 -- 737
	if self.isCampaign then -- 737
		self:setupCampaign() -- 739
	else -- 739
		self:buildEnemies() -- 741
	end -- 741
	if resume ~= nil and resume.checkpoint > 0 then -- 741
		self.checkpoint = resume.checkpoint -- 745
		if self.room.key == "outside" and resume.checkpoint >= 380 then -- 745
			self.cartAxle = self.room.cart.endX -- 747
			self.cartDocked = true -- 748
			self.player.x = self.ox + 380 -- 751
			self.player.y = 0 -- 752
			self.player.vy = 0 -- 753
			self.player.onGround = true -- 754
			self.cam.x = self.player.x -- 755
			self.cam.y = self.player.y + CAM_LOOK_UP -- 756
		end -- 756
	end -- 756
	self:restoreStory() -- 759
end -- 689
function Play.prototype.towerEndReady(self) -- 566
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 567
	return self.room.key == "tower" and self.phase == "tower-end" and self.phaseTick >= waitTicks and not self.towerEndMustRelease -- 568
end -- 566
function Play.prototype.recipeViews(self) -- 772
	local out = {} -- 773
	local i = 0 -- 774
	do -- 774
		i = 0 -- 775
		while i < #CRAFT_RECIPES do -- 775
			local r = CRAFT_RECIPES[i + 1] -- 776
			local cost = {} -- 777
			if r.cost.wood ~= nil then -- 777
				cost.wood = r.cost.wood -- 779
			end -- 779
			if r.cost.bell ~= nil then -- 779
				cost.bell = r.cost.bell -- 782
			end -- 782
			out[#out + 1] = { -- 784
				id = r.id, -- 785
				name = r.name, -- 786
				desc = r.desc, -- 787
				enhancedEffect = r.enhancedEffect, -- 788
				cost = cost, -- 789
				crafted = self.run.story.craftedWeapon == r.id -- 790
			} -- 790
			i = i + 1 -- 775
		end -- 775
	end -- 775
	if self.archive.artifactOwned then -- 775
		out[#out + 1] = { -- 795
			id = ARTIFACT_WEAPON_ID, -- 796
			name = weaponNameOf(ARTIFACT_WEAPON_ID), -- 797
			desc = "井底拾取彩蛋 · 男主线移动留下冷白微金轨迹残影", -- 798
			enhancedEffect = "light", -- 799
			cost = {}, -- 800
			crafted = true -- 801
		} -- 801
	end -- 801
	return out -- 804
end -- 772
function Play.prototype.syncCraftBench(self) -- 808
	local view = self.craftBench -- 809
	local inv = self.run.inventory -- 810
	view.inventory = { -- 811
		wood = inv.wood, -- 811
		bell = inv.bell, -- 811
		scrap = inv.scrap, -- 811
		wedge = inv.wedge, -- 811
		ammo = inv.ammo -- 811
	} -- 811
	view.recipes = self:recipeViews() -- 812
	view.equippedWeapon = self.equippedWeapon -- 813
	view.firstCraftDone = self.run.story.craftedWeapon ~= "" -- 814
	if view.justCraftedTimer > 0 then -- 814
		view.justCraftedTimer = math.max(0, view.justCraftedTimer - STEP) -- 816
	end -- 816
end -- 808
function Play.prototype.openCraftBench(self) -- 821
	if self.room.key ~= "escort3" or self.craftBench.active then -- 821
		return -- 823
	end -- 823
	self.craftBench.active = true -- 825
	self.carryOn = false -- 826
	self.run.story.carry = false -- 827
	self.player.vx = 0 -- 828
	self.player.vy = 0 -- 829
	self.craftBench.justCraftedTimer = 0 -- 830
	self:syncCraftBench() -- 831
	self:flashSet("放下小满 · 工台按 E 选一件改制", 1.6) -- 832
	self:log("开工台") -- 833
	self:emit( -- 834
		"benchOpen", -- 834
		{ -- 834
			recipes = __TS__ArrayMap( -- 835
				self.craftBench.recipes, -- 835
				function(____, r) return r.id end -- 835
			), -- 835
			inventory = self.craftBench.inventory, -- 836
			carry = self.carryOn -- 837
		} -- 837
	) -- 837
end -- 821
function Play.prototype.closeCraftBench(self) -- 842
	if not self.craftBench.active then -- 842
		return -- 844
	end -- 844
	self.craftBench.active = false -- 846
	self.craftBench.justCraftedTimer = 0 -- 847
	self.carryOn = true -- 848
	self.run.story.carry = true -- 849
	self:flashSet("重新背起小满 · 往山道", 1.4) -- 850
	self:log("离站背起") -- 851
	self:emit("benchClose", {equipped = self.equippedWeapon, crafted = self.run.story.craftedWeapon}) -- 852
	if self.room.key == "escort3" and self.storyRoute == "soldier" then -- 852
		self:triggerDeferredEscort3Draft() -- 854
	end -- 854
end -- 842
function Play.prototype.triggerDeferredEscort3Draft(self) -- 859
	if self.room.key ~= "escort3" or self.storyRoute ~= "soldier" or self.run.finished then -- 859
		return false -- 861
	end -- 861
	if self.run.story.talents == nil then -- 861
		self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 864
	end -- 864
	local st = self.run.story.talents -- 866
	if not st.deferred and st.room == "escort3" then -- 866
		return false -- 868
	end -- 868
	draftTalentOffers(st, "escort3", self.equippedWeapon) -- 870
	if self.useEscortDeathSummary and #st.offers > 0 then -- 870
		self.talentModalActive = true -- 872
	end -- 872
	self.sessionDirty = true -- 874
	return #st.offers > 0 -- 875
end -- 859
function Play.prototype.openTalentDraft(self) -- 879
	if #self:getStoryTalentOffers() > 0 and not self.craftBench.active and not self.escortFailed then -- 879
		self.talentModalActive = true -- 881
	end -- 881
end -- 879
function Play.prototype.craftAtBench(self, recipeId, requestId) -- 889
	if not self.craftBench.active or self.handledCraftRequests[requestId] == true then -- 889
		return false -- 891
	end -- 891
	local recipe = findRecipe(recipeId) -- 893
	if recipe == nil or self.run.story.craftedWeapon ~= "" then -- 893
		self:flashSet(self.run.story.craftedWeapon == "" and "没有这件配方" or "这一件已经做了 · 只能二选一", 1.4) -- 895
		self:emit("benchRejected", {recipeId = recipeId, reason = self.run.story.craftedWeapon == "" and "unknown" or "crafted"}) -- 896
		return false -- 897
	end -- 897
	local missing = missingMaterials(self.run.inventory, recipe) -- 899
	if #missing > 0 then -- 899
		self:flashSet( -- 901
			"缺料 · " .. table.concat(missing, " / "), -- 901
			1.6 -- 901
		) -- 901
		self:emit("benchRejected", {recipeId = recipeId, reason = "materials", missing = missing}) -- 902
		return false -- 903
	end -- 903
	payMaterials(self.run.inventory, recipe) -- 905
	self.handledCraftRequests[requestId] = true -- 906
	self.run.story.craftedWeapon = recipe.id -- 907
	self.run.story.equippedWeapon = recipe.id -- 908
	self.equippedWeapon = recipe.id -- 909
	self.sessionDirty = true -- 910
	self.craftBench.justCraftedTimer = self.craftBench.firstCraftDone and 0.45 or 1 -- 911
	self.craftBench.firstCraftDone = true -- 912
	self:syncCraftBench() -- 913
	self:flashSet(("改制完成 · " .. recipe.name) .. " · 已装备", 2) -- 914
	self:log("改制 " .. recipe.id) -- 915
	self:emit("benchCraft", { -- 916
		recipeId = recipe.id, -- 917
		weapon = recipe.id, -- 918
		effect = recipe.enhancedEffect, -- 919
		wood = self.run.inventory.wood, -- 920
		bell = self.run.inventory.bell -- 921
	}) -- 921
	return true -- 923
end -- 889
function Play.prototype.equipWeapon(self, weaponId) -- 927
	local artifactOk = weaponId == ARTIFACT_WEAPON_ID and self.archive.artifactOwned -- 928
	if weaponId ~= "standard_gun" and self.run.story.craftedWeapon ~= weaponId and not artifactOk then -- 928
		self:emit("benchRejected", {recipeId = weaponId, reason = "unknown"}) -- 930
		return false -- 931
	end -- 931
	self.equippedWeapon = weaponId -- 933
	self.run.story.equippedWeapon = weaponId -- 934
	self.sessionDirty = true -- 935
	self:syncCraftBench() -- 936
	self:flashSet( -- 937
		"已装备 " .. weaponNameOf(weaponId), -- 937
		1 -- 937
	) -- 937
	self:emit("benchEquip", {weapon = weaponId}) -- 938
	return true -- 939
end -- 927
function Play.prototype.toggleArtifactWeapon(self) -- 943
	if not self.archive.artifactOwned or self.childMode then -- 943
		return false -- 945
	end -- 945
	if self.equippedWeapon == ARTIFACT_WEAPON_ID then -- 945
		local fallback = self.run.story.craftedWeapon ~= "" and self.run.story.craftedWeapon or "standard_gun" -- 948
		return self:equipWeapon(fallback) -- 949
	end -- 949
	return self:equipWeapon(ARTIFACT_WEAPON_ID) -- 951
end -- 943
function Play.prototype.exportSession(self) -- 955
	self:syncStory() -- 956
	local story = self.run.story -- 957
	local inv = self.run.inventory -- 958
	local taken = {} -- 959
	for k in pairs(self.run.taken) do -- 960
		if self.run.taken[k] == true then -- 960
			taken[#taken + 1] = k -- 962
		end -- 962
	end -- 962
	local segments = {} -- 965
	for k in pairs(story.segments) do -- 966
		if story.segments[k] == true then -- 966
			segments[#segments + 1] = k -- 968
		end -- 968
	end -- 968
	local props = {} -- 971
	for k in pairs(self.run.props) do -- 972
		local st = self.run.props[k] -- 973
		if st ~= nil then -- 973
			props[#props + 1] = (((((((k .. ":") .. (st.broken and "1" or "0")) .. ":") .. tostring(math.floor(st.hp + 0.5))) .. ":") .. (st.wedge and "1" or "0")) .. ":") .. (st.revealed == true and "1" or "0") -- 975
		end -- 975
	end -- 975
	local talentRanks = {} -- 984
	if story.talents ~= nil then -- 984
		local ti = 0 -- 986
		do -- 986
			ti = 0 -- 987
			while ti < #ALL_TALENTS do -- 987
				local tid = ALL_TALENTS[ti + 1] -- 988
				local rk = story.talents.ranks[tid] or 0 -- 989
				if rk > 0 then -- 989
					talentRanks[#talentRanks + 1] = (tid .. ":") .. tostring(rk) -- 991
				end -- 991
				ti = ti + 1 -- 987
			end -- 987
		end -- 987
	end -- 987
	local ____temp_4 = self.escortFailed and "escort1" or self.room.key -- 997
	local ____temp_5 = self.escortFailed and 0 or self.checkpoint -- 998
	local ____self_run_seed_6 = self.run.seed -- 999
	local ____story_route_7 = story.route -- 1000
	local ____story_hp_8 = story.hp -- 1001
	local ____story_maxHp_9 = story.maxHp -- 1002
	local ____story_hpAtGate_10 = story.hpAtGate -- 1003
	local ____story_maxHpAtGate_11 = story.maxHpAtGate -- 1004
	local ____story_settled_12 = story.settled -- 1005
	local ____self_phase_13 = self.phase -- 1006
	local ____story_countTick_14 = story.countTick -- 1007
	local ____story_phaseTick_15 = story.phaseTick -- 1008
	local ____story_handTicks_16 = story.handTicks -- 1009
	local ____story_handDone_17 = story.handDone -- 1010
	local ____story_lineSaid_18 = story.lineSaid -- 1011
	local ____story_tied_19 = story.tied -- 1012
	local ____story_carry_20 = story.carry -- 1013
	local ____story_escortDone_21 = story.escortDone -- 1014
	local ____story_craftedWeapon_22 = story.craftedWeapon -- 1015
	local ____self_equippedWeapon_23 = self.equippedWeapon -- 1016
	local ____inv_wood_24 = inv.wood -- 1017
	local ____inv_bell_25 = inv.bell -- 1018
	local ____inv_scrap_26 = inv.scrap -- 1019
	local ____inv_wedge_27 = inv.wedge -- 1020
	local ____inv_ammo_28 = inv.ammo -- 1021
	local ____inv_shield_29 = inv.shield -- 1022
	local ____inv_pass_30 = inv.pass -- 1023
	local ____inv_quickbelt_31 = inv.quickbelt -- 1024
	local ____taken_32 = taken -- 1025
	local ____segments_33 = segments -- 1026
	local ____self_cartAxle_34 = self.cartAxle -- 1027
	local ____self_cartDocked_35 = self.cartDocked -- 1028
	local ____self_run_route_36 = self.run.route -- 1029
	local ____self_run_joined_37 = self.run.joined -- 1030
	local ____self_run_c1Latch_38 = self.run.c1Latch -- 1031
	local ____self_run_c2Latch_39 = self.run.c2Latch -- 1032
	local ____temp_40 = story.talents ~= nil and story.talents.randomState or 0 -- 1033
	local ____temp_41 = story.talents ~= nil and story.talents.room or "" -- 1034
	local ____temp_42 = story.talents ~= nil and __TS__ArraySlice(story.talents.offers) or ({}) -- 1035
	local ____talentRanks_43 = talentRanks -- 1036
	local ____temp_44 = story.talents ~= nil and story.talents.attempt or 1 -- 1037
	local ____temp_45 = story.talents ~= nil and story.talents.variant or 0 -- 1038
	local ____temp_0 -- 1039
	if story.talents ~= nil then -- 1039
		____temp_0 = story.talents.deferred -- 1039
	else -- 1039
		____temp_0 = false -- 1039
	end -- 1039
	local ____temp_46 = story.talents ~= nil and story.talents.ranks.vitality or 0 -- 1040
	local ____temp_47 = story.talents ~= nil and story.talents.ranks.focus or 0 -- 1041
	local ____temp_48 = story.talents ~= nil and story.talents.ranks.guard or 0 -- 1042
	local ____temp_49 = story.talents ~= nil and story.talents.ranks.salvage or 0 -- 1043
	local ____props_50 = props -- 1044
	local ____table_escortFailed_1 -- 1045
	if self.escortFailed then -- 1045
		____table_escortFailed_1 = nil -- 1045
	else -- 1045
		____table_escortFailed_1 = self.player.x -- 1045
	end -- 1045
	local ____table_escortFailed_2 -- 1046
	if self.escortFailed then -- 1046
		____table_escortFailed_2 = nil -- 1046
	else -- 1046
		____table_escortFailed_2 = self.player.y -- 1046
	end -- 1046
	local ____table_escortFailed_3 -- 1047
	if self.escortFailed then -- 1047
		____table_escortFailed_3 = nil -- 1047
	else -- 1047
		____table_escortFailed_3 = self.player.depth -- 1047
	end -- 1047
	return { -- 995
		roomKey = ____temp_4, -- 997
		checkpoint = ____temp_5, -- 998
		seed = ____self_run_seed_6, -- 999
		route = ____story_route_7, -- 1000
		hp = ____story_hp_8, -- 1001
		maxHp = ____story_maxHp_9, -- 1002
		hpAtGate = ____story_hpAtGate_10, -- 1003
		maxHpAtGate = ____story_maxHpAtGate_11, -- 1004
		settled = ____story_settled_12, -- 1005
		phase = ____self_phase_13, -- 1006
		countTick = ____story_countTick_14, -- 1007
		phaseTick = ____story_phaseTick_15, -- 1008
		handTicks = ____story_handTicks_16, -- 1009
		handDone = ____story_handDone_17, -- 1010
		lineSaid = ____story_lineSaid_18, -- 1011
		tied = ____story_tied_19, -- 1012
		carry = ____story_carry_20, -- 1013
		escortDone = ____story_escortDone_21, -- 1014
		craftedWeapon = ____story_craftedWeapon_22, -- 1015
		equippedWeapon = ____self_equippedWeapon_23, -- 1016
		wood = ____inv_wood_24, -- 1017
		bell = ____inv_bell_25, -- 1018
		scrap = ____inv_scrap_26, -- 1019
		wedge = ____inv_wedge_27, -- 1020
		ammo = ____inv_ammo_28, -- 1021
		shield = ____inv_shield_29, -- 1022
		pass = ____inv_pass_30, -- 1023
		quickbelt = ____inv_quickbelt_31, -- 1024
		taken = ____taken_32, -- 1025
		segments = ____segments_33, -- 1026
		cartAxle = ____self_cartAxle_34, -- 1027
		cartDocked = ____self_cartDocked_35, -- 1028
		campaignRoute = ____self_run_route_36, -- 1029
		joined = ____self_run_joined_37, -- 1030
		c1Latch = ____self_run_c1Latch_38, -- 1031
		c2Latch = ____self_run_c2Latch_39, -- 1032
		talentSeed = ____temp_40, -- 1033
		talentRoom = ____temp_41, -- 1034
		talentOffers = ____temp_42, -- 1035
		talentRanks = ____talentRanks_43, -- 1036
		escortAttempt = ____temp_44, -- 1037
		escortVariant = ____temp_45, -- 1038
		talentDeferred = ____temp_0, -- 1039
		talentVitality = ____temp_46, -- 1040
		talentReload = ____temp_47, -- 1041
		talentGuard = ____temp_48, -- 1042
		talentCraft = ____temp_49, -- 1043
		props = ____props_50, -- 1044
		playerX = ____table_escortFailed_1, -- 1045
		playerY = ____table_escortFailed_2, -- 1046
		playerDepth = ____table_escortFailed_3, -- 1047
		gateTick = self.gateTick, -- 1048
		hasBottle = self.hasBottle, -- 1049
		villagePassed = self.passed -- 1050
	} -- 1050
end -- 955
function Play.prototype.submitFeIntent(self, intent) -- 1058
	local kind = intent == nil and "" or intent.kind -- 1059
	if kind == "gateReunionHold" then -- 1059
		if self.room.key ~= "gate" or self.phase ~= "gate-wait" and self.phase ~= "gate-count" then -- 1059
			return false -- 1062
		end -- 1062
		local holding = intent.holding == true -- 1064
		self.intentGateReunionHold = holding -- 1065
		if not holding and self.phase == "gate-wait" then -- 1065
			if self.handTicks > 0 then -- 1065
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 1068
			end -- 1068
			self.handTicks = 0 -- 1070
			self.handArmed = true -- 1071
		end -- 1071
		return true -- 1073
	end -- 1073
	if kind == "reloadOpen" then -- 1073
		local camp = self.room.campaign -- 1076
		if camp == nil or camp.reloadPuzzle ~= true or self.reloadOpen then -- 1076
			return false -- 1078
		end -- 1078
		self:beginReload() -- 1080
		return self.reloadOpen -- 1081
	end -- 1081
	if kind == "reloadPathPreview" then -- 1081
		local path = intent.path -- 1084
		return type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) -- 1085
	end -- 1085
	if kind == "reloadTapNode" then -- 1085
		local node = intent.node -- 1088
		if type(node) == "number" then -- 1088
			self:reloadTapNode(node) -- 1090
			return true -- 1091
		end -- 1091
		return false -- 1093
	end -- 1093
	if kind == "reloadPathCommit" then -- 1093
		local path = intent.path -- 1096
		if type(path) == "table" and path ~= nil and __TS__ArrayIsArray(path) then -- 1096
			local list = path -- 1098
			local i = 0 -- 1099
			do -- 1099
				i = 0 -- 1100
				while i < #list do -- 1100
					do -- 1100
						if i == 0 and list[i + 1] == RELOAD_START then -- 1100
							goto __continue85 -- 1102
						end -- 1102
						self:reloadTapNode(list[i + 1]) -- 1104
					end -- 1104
					::__continue85:: -- 1104
					i = i + 1 -- 1100
				end -- 1100
			end -- 1100
			return true -- 1106
		end -- 1106
		return false -- 1108
	end -- 1108
	if kind == "reloadCancel" then -- 1108
		self:closeReloadPuzzle() -- 1111
		return true -- 1112
	end -- 1112
	if kind == "craftSubmit" then -- 1112
		local recipeId = intent.recipeId -- 1115
		local requestId = intent.requestId -- 1116
		if type(recipeId) == "string" and type(requestId) == "string" then -- 1116
			return self:craftAtBench(recipeId, requestId) -- 1118
		end -- 1118
		return false -- 1120
	end -- 1120
	if kind == "craftEquip" then -- 1120
		local weaponId = intent.weaponId -- 1123
		if type(weaponId) == "string" then -- 1123
			return self:equipWeapon(weaponId) -- 1125
		end -- 1125
		return false -- 1127
	end -- 1127
	if kind == "craftClose" then -- 1127
		self:closeCraftBench() -- 1130
		return true -- 1131
	end -- 1131
	if kind == "chooseTalent" then -- 1131
		local slot = intent.slot -- 1134
		if type(slot) == "number" then -- 1134
			return self:chooseTalent(slot) -- 1136
		end -- 1136
		return false -- 1138
	end -- 1138
	if kind == "wellPick" then -- 1138
		return self:pickWell() -- 1141
	end -- 1141
	if kind == "museumInteract" then -- 1141
		local target = type(intent.target) == "string" and intent.target or "" -- 1144
		if target == "well_pickup" or target == "well" then -- 1144
			return self:pickWell() -- 1146
		end -- 1146
		if self.room.key ~= "museum" then -- 1146
			return false -- 1149
		end -- 1149
		return self:triggerMuseumIntent(target) -- 1151
	end -- 1151
	return false -- 1153
end -- 1058
function Play.prototype.triggerMuseumIntent(self, target) -- 1157
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 1158
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 1161
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 1162
	if self.phase == "museum-cabinet" then -- 1162
		if target == "enter_hall" or (target == "" or target == "cabinet" or target == "weapon_case") and atCase then -- 1162
			self.pendingMuseumIntentTarget = "cabinet" -- 1165
			return true -- 1166
		end -- 1166
	end -- 1166
	if self.phase == "museum-hall" then -- 1166
		if (target == "lamp_turn" or target == "lamp" or target == "west_lamp") and nearLamp then -- 1166
			self.pendingMuseumIntentTarget = "lamp_direct" -- 1171
			return true -- 1172
		end -- 1172
		if (target == "" or target == "hall" or target == "corridor") and self.player.x >= self.ox + mu.hallX then -- 1172
			self.pendingMuseumIntentTarget = "hall" -- 1175
			return true -- 1176
		end -- 1176
	end -- 1176
	if self.phase == "museum-lamp" and (target == "" or target == "lamp" or target == "west_lamp" or target == "lamp_turn") and nearLamp then -- 1176
		self.pendingMuseumIntentTarget = "lamp" -- 1182
		return true -- 1183
	end -- 1183
	if self.phase == "museum-return" then -- 1183
		if target == "begin_return_cabinet" or (target == "" or target == "return_cabinet" or target == "cabinet" or target == "return") and atCase then -- 1183
			self.pendingMuseumIntentTarget = "return_cabinet" -- 1188
			return true -- 1189
		end -- 1189
	end -- 1189
	if self.phase == "museum-done" and (target == "" or target == "return_cabinet" or target == "return") then -- 1189
		self.pendingMuseumIntentTarget = "done" -- 1193
		return true -- 1194
	end -- 1194
	return false -- 1196
end -- 1157
function Play.prototype.captureCheckpoint(self, id) -- 1200
	local inv = self.run.inventory -- 1201
	self.checkpointSnap = { -- 1202
		id = id, -- 1203
		wood = inv.wood, -- 1204
		bell = inv.bell, -- 1205
		scrap = inv.scrap, -- 1206
		wedge = inv.wedge, -- 1207
		ammo = inv.ammo, -- 1208
		shield = inv.shield, -- 1209
		pass = inv.pass, -- 1210
		quickbelt = inv.quickbelt, -- 1211
		crafted = self.run.story.craftedWeapon, -- 1212
		equipped = self.equippedWeapon, -- 1213
		carry = self.carryOn -- 1214
	} -- 1214
	self.run.story.cp = self.checkpointSnap -- 1216
end -- 1200
function Play.prototype.applyCheckpointSnap(self, id) -- 1220
	local snap = self.run.story.cp -- 1221
	if snap == nil or snap.id ~= id then -- 1221
		return false -- 1223
	end -- 1223
	self.checkpointSnap = snap -- 1225
	local inv = self.run.inventory -- 1226
	inv.wood = snap.wood -- 1227
	inv.bell = snap.bell -- 1228
	inv.scrap = snap.scrap -- 1229
	inv.wedge = snap.wedge -- 1230
	inv.ammo = snap.ammo -- 1231
	inv.shield = snap.shield -- 1232
	inv.pass = snap.pass -- 1233
	inv.quickbelt = snap.quickbelt -- 1234
	self.run.story.craftedWeapon = snap.crafted -- 1235
	self.equippedWeapon = snap.equipped -- 1236
	self.run.story.equippedWeapon = snap.equipped -- 1237
	self.carryOn = snap.carry -- 1238
	self.run.story.carry = snap.carry -- 1239
	self.craftBench.active = false -- 1240
	self:syncCraftBench() -- 1241
	return true -- 1242
end -- 1220
function Play.prototype.restoreStory(self) -- 1245
	local story = self.run.story -- 1246
	if story == nil then -- 1246
		return -- 1248
	end -- 1248
	if story.maxHp > 0 then -- 1248
		self.maxHp = story.maxHp -- 1251
		self.hp = math.max( -- 1252
			1, -- 1252
			math.min(story.hp, story.maxHp) -- 1252
		) -- 1252
	end -- 1252
	self.storyRoute = story.route -- 1254
	self.storySettled = story.settled -- 1255
	self.hpAtGate = story.hpAtGate -- 1256
	self.maxHpAtGate = story.maxHpAtGate -- 1257
	self.handDone = story.handDone -- 1258
	self.lineSaid = story.lineSaid -- 1259
	self.tied = story.handDone -- 1260
	self.carryOn = story.carry or story.route == "soldier" and (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 1261
	self.museumReturn = story.museumReturn -- 1262
	story.museumReturn = false -- 1263
	self.escortDone = story.escortDone -- 1264
	self:syncCraftBench() -- 1265
	if story.segments.outside_cart == true then -- 1265
		self.redCartPulled = true -- 1268
		local redBox = __TS__ArrayFind( -- 1269
			self.boxes, -- 1269
			function(____, b) return b.id == "outside_red_cart" end -- 1269
		) -- 1269
		if redBox ~= nil then -- 1269
			redBox.x0 = 430 -- 1271
			redBox.x1 = 474 -- 1272
		end -- 1272
		if self.room.key == "outside" and self.room.cart.bodyW > 0 then -- 1272
			self.cartAxle = self.room.cart.endX -- 1275
			self.cartDocked = true -- 1276
		end -- 1276
	end -- 1276
	self.forestPath = story.segments.forest_burrow == true and "burrow" or (story.segments.forest_ditch == true and "ditch" or "") -- 1279
	self.waterSeen = story.segments.water_lantern == true -- 1281
	if self.checkpoint > 0 and story.cp ~= nil and story.cp.id == self.checkpoint then -- 1281
		self:applyCheckpointSnap(self.checkpoint) -- 1284
	end -- 1284
	if self.room.key == "tower" and story.route == "soldier" then -- 1284
		self.carryOn = false -- 1288
		self.run.story.carry = false -- 1289
		self.player.w = SOLDIER_W -- 1290
		self.player.h = SOLDIER_H -- 1291
		self.player.x = math.max(self.ox + 422, self.player.x) -- 1292
		self.partner = { -- 1293
			x = math.max(self.ox + 408, self.player.x - 24), -- 1294
			y = 0, -- 1295
			depth = 0, -- 1296
			depthSpeed = 0, -- 1297
			vx = 0, -- 1298
			vy = 0, -- 1299
			w = CHILD_W, -- 1300
			h = CHILD_H, -- 1301
			onGround = true, -- 1302
			facing = 1, -- 1303
			crouch = false, -- 1304
			rollT = 0, -- 1305
			covered = false, -- 1306
			alive = true -- 1307
		} -- 1307
	end -- 1307
	if self.room.key == "tower" then -- 1307
		if story.segments.tower_door == true then -- 1307
			self:openTowerDoor() -- 1313
		end -- 1313
		self.towerHanded = story.segments.tower_handover == true -- 1315
		self.deskHold = 0 -- 1316
		if story.phase == "tower-enter" or story.phase == "tower-desk" or story.phase == "tower-given" then -- 1316
			self.phase = story.phase -- 1318
			self.phaseTick = 0 -- 1319
			if story.phase == "tower-desk" or story.phase == "tower-given" then -- 1319
				self.player.x = self.ox + 605 -- 1321
				self.player.y = 0 -- 1322
				if story.route == "soldier" and self.partner.alive then -- 1322
					self.partner.x = self.ox + 568 -- 1324
					self.partner.y = 0 -- 1325
					self.partner.facing = 1 -- 1326
				end -- 1326
			end -- 1326
		end -- 1326
	end -- 1326
	if self.room.key == "prologue" then -- 1326
		local ph = story.phase -- 1333
		if ph == "prologue-wait" or ph == "prologue-give" or ph == "prologue-follow" then -- 1333
			self.phase = ph -- 1335
			self.phaseTick = story.phaseTick -- 1336
			self.player.x = self.ox + (ph == "prologue-follow" and 620 or 260) -- 1337
			self.player.y = 0 -- 1338
			self.player.depth = 0 -- 1339
			self.player.vx = 0 -- 1340
			self.partner.x = self.ox + 300 -- 1341
			self.partner.y = 0 -- 1342
			self.partner.depth = 0 -- 1343
			self.partner.vx = 0 -- 1344
			self.partner.alive = true -- 1345
			if ph == "prologue-follow" then -- 1345
				self.partner.crouch = false -- 1347
				self.partner.h = CHILD_H -- 1348
			else -- 1348
				self.partner.crouch = true -- 1350
				self.partner.h = CHILD_CROUCH_H -- 1351
			end -- 1351
			self.cam.x = self.player.x -- 1353
		end -- 1353
		return -- 1355
	end -- 1355
	if self.room.key ~= "gate" then -- 1355
		return -- 1358
	end -- 1358
	local ____temp_51 -- 1360
	if self.room.story == nil then -- 1360
		____temp_51 = nil -- 1360
	else -- 1360
		____temp_51 = self.room.story.gate -- 1360
	end -- 1360
	local g = ____temp_51 -- 1360
	if g == nil then -- 1360
		return -- 1362
	end -- 1362
	if story.phase == "gate-send" then -- 1362
		self.phase = "gate-send" -- 1366
		self.gateTick = g.holdTicks -- 1367
		self.gateSpawned = 4 -- 1368
		self.enemies = {} -- 1369
		self.player.x = self.ox + g.doorX - 40 -- 1370
		self.player.y = 0 -- 1371
		self.player.depth = 0 -- 1372
		self.player.vx = 0 -- 1373
		self.player.vy = 0 -- 1374
		self.player.onGround = true -- 1375
		self.partner.x = self.ox + g.waitX -- 1376
		self.partner.y = 0 -- 1377
		self.partner.depth = 0 -- 1378
		self.partner.alive = true -- 1379
		self.cam.x = self.player.x -- 1380
		self.handTicks = 0 -- 1381
		self.handArmed = false -- 1382
		self:flashSet("守满了 · 到门边按 E 送她", 2) -- 1383
		return -- 1384
	end -- 1384
	if not story.settled then -- 1384
		return -- 1387
	end -- 1387
	self.gateTick = g.holdTicks -- 1390
	self.gateSpawned = 4 -- 1391
	self.enemies = {} -- 1392
	if story.phase == "gate-farewell" or story.phase == "gate-count" or story.phase == "gate-walk" then -- 1392
		self.phase = story.phase == "gate-farewell" and "gate-count" or story.phase -- 1394
		self.countTick = story.phase == "gate-farewell" and 0 or math.max(story.countTick, 0) -- 1395
		self:swapToChild(g.doorX + 30) -- 1396
		self.countPrevMove = 0 -- 1397
		self.countArmed = false -- 1398
		return -- 1399
	end -- 1399
	if story.phase == "gate-wait" or story.phase == "gate-hand" then -- 1399
		self.phase = story.phase -- 1402
		self.countTick = ____exports.GATE_COUNT_END -- 1403
		self.phaseTick = story.phaseTick -- 1404
		self:swapToChild(g.doorX + 30) -- 1405
		self.handTicks = story.handDone and ____exports.GATE_HAND_TICKS or math.max( -- 1406
			0, -- 1406
			math.min(____exports.GATE_HAND_TICKS, story.handTicks) -- 1406
		) -- 1406
		self.handArmed = false -- 1407
	end -- 1407
end -- 1245
function Play.prototype.buildWorld(self) -- 1412
	local room = self.room -- 1413
	self.boxes = {} -- 1414
	self.floors = {} -- 1415
	local i = 0 -- 1416
	do -- 1416
		i = 0 -- 1417
		while i < #room.floors do -- 1417
			local f = room.floors[i + 1] -- 1418
			local ____self_floors_52 = self.floors -- 1418
			____self_floors_52[#____self_floors_52 + 1] = {x0 = f.x0, x1 = f.x1, y0 = f.y, y1 = f.y} -- 1419
			i = i + 1 -- 1417
		end -- 1417
	end -- 1417
	do -- 1417
		i = 0 -- 1421
		while i < #room.solids do -- 1421
			local s = room.solids[i + 1] -- 1422
			if not s.decorative then -- 1422
				local ____self_boxes_64 = self.boxes -- 1428
				local ____s_x_55 = s.x -- 1429
				local ____temp_56 = s.x + s.w -- 1429
				local ____s_y_57 = s.y -- 1429
				local ____temp_58 = s.y + s.h -- 1429
				local ____temp_53 -- 1430
				if room.depth == nil then -- 1430
					____temp_53 = nil -- 1430
				else -- 1430
					____temp_53 = s.depth -- 1430
				end -- 1430
				local ____temp_59 = s.passable == true -- 1431
				local ____s_label_60 = s.label -- 1431
				local ____s_id_61 = s.id -- 1432
				local ____temp_62 = s.soft == true -- 1432
				local ____temp_63 = s.hidden == true -- 1432
				local ____temp_54 -- 1433
				if s.breakable == nil then -- 1433
					____temp_54 = nil -- 1433
				else -- 1433
					____temp_54 = __TS__ObjectAssign({}, s.breakable) -- 1433
				end -- 1433
				____self_boxes_64[#____self_boxes_64 + 1] = { -- 1428
					x0 = ____s_x_55, -- 1429
					x1 = ____temp_56, -- 1429
					y0 = ____s_y_57, -- 1429
					y1 = ____temp_58, -- 1429
					depth = ____temp_53, -- 1430
					passable = ____temp_59, -- 1431
					label = ____s_label_60, -- 1431
					id = ____s_id_61, -- 1432
					soft = ____temp_62, -- 1432
					hidden = ____temp_63, -- 1432
					breakable = ____temp_54, -- 1433
					interact = s.interact -- 1434
				} -- 1434
			end -- 1434
			i = i + 1 -- 1421
		end -- 1421
	end -- 1421
	do -- 1421
		i = 0 -- 1438
		while i < #room.stairs do -- 1438
			local st = room.stairs[i + 1] -- 1439
			local n = st.steps + 1 -- 1440
			local stepW = (st.x1 - st.x0) / n -- 1441
			local k = 0 -- 1442
			do -- 1442
				k = 0 -- 1443
				while k < n do -- 1443
					local y = st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 1444
					local x0 = st.x0 + stepW * k -- 1445
					local ____self_boxes_68 = self.boxes -- 1448
					local ____temp_66 = x0 + stepW -- 1449
					local ____temp_67 = -8 -- 1449
					local ____temp_65 -- 1450
					if room.depth == nil then -- 1450
						____temp_65 = nil -- 1450
					else -- 1450
						____temp_65 = st.depth -- 1450
					end -- 1450
					____self_boxes_68[#____self_boxes_68 + 1] = { -- 1448
						x0 = x0, -- 1449
						x1 = ____temp_66, -- 1449
						y0 = ____temp_67, -- 1449
						y1 = y, -- 1449
						depth = ____temp_65, -- 1450
						passable = true -- 1451
					} -- 1451
					k = k + 1 -- 1443
				end -- 1443
			end -- 1443
			i = i + 1 -- 1438
		end -- 1438
	end -- 1438
end -- 1412
function Play.prototype.setupCampaign(self) -- 1461
	local wr = self.room -- 1462
	local c = wr.campaign -- 1463
	if c == nil then -- 1463
		return -- 1465
	end -- 1465
	self.roomStartTick = self.run.ticks -- 1467
	if wr.key == "s1-crossroad" or wr.key == "escort1" or wr.key == "escort2" or wr.key == "escort3" or wr.key == "escort4" or wr.key == "escort5" then -- 1467
		self.run.joined = true -- 1471
	elseif wr.companion ~= nil and wr.companion.followAfter ~= nil then -- 1471
		local ____self_run_73 = self.run -- 1474
		local ____temp_72 -- 1474
		if wr.key == "s2-drygoods" then -- 1474
			local ____temp_71 = self.run.route ~= "drygoods" -- 1475
			if not ____temp_71 then -- 1475
				local ____opt_69 = self.run.props.s2_board -- 1475
				____temp_71 = (____opt_69 and ____opt_69.broken) == true -- 1475
			end -- 1475
			____temp_72 = ____temp_71 -- 1475
		else -- 1475
			____temp_72 = wr.key == "c1-yard" and self.run.c1Latch -- 1476
		end -- 1476
		____self_run_73.joined = ____temp_72 -- 1474
	end -- 1474
	local x = wr.minX + 60 -- 1478
	local y = 0 -- 1479
	local depth = 0 -- 1480
	if wr.key == "s2-drygoods" and self.run.route == "drygoods" then -- 1480
		x = wr.minX + 210 -- 1482
		depth = -32 -- 1483
	elseif wr.key == "s3-archway" and self.run.route == "drygoods" then -- 1483
		x = wr.minX + 40 -- 1485
		y = 32 -- 1486
		depth = 32 -- 1487
	end -- 1487
	self.player = { -- 1489
		x = x, -- 1490
		y = y, -- 1490
		depth = depth, -- 1490
		depthSpeed = 0, -- 1490
		vx = 0, -- 1490
		vy = 0, -- 1490
		w = SOLDIER_W, -- 1491
		h = SOLDIER_H, -- 1491
		onGround = y <= 0, -- 1491
		facing = 1, -- 1491
		crouch = false, -- 1491
		rollT = 0, -- 1491
		covered = false, -- 1491
		alive = true -- 1491
	} -- 1491
	self.partner = { -- 1493
		x = x + 60, -- 1494
		y = y, -- 1494
		depth = depth, -- 1494
		depthSpeed = 0, -- 1494
		vx = 0, -- 1494
		vy = 0, -- 1494
		w = CHILD_W, -- 1495
		h = CHILD_H, -- 1495
		onGround = y <= 0, -- 1495
		facing = 1, -- 1495
		crouch = false, -- 1495
		rollT = 0, -- 1495
		covered = false, -- 1495
		alive = true -- 1495
	} -- 1495
	self.cam.x = x -- 1497
	self.cam.y = y + CAM_LOOK_UP -- 1498
	self.phase = "run" -- 1499
	self.hp = self.maxHp -- 1500
	if self:isEscortRoom() and self.run.story.route == "soldier" then -- 1500
		if self.run.story.talents == nil then -- 1500
			self.run.story.talents = createStoryTalents(self.run.seed, 1) -- 1503
		end -- 1503
		local st = self.run.story.talents -- 1505
		local variants = ESCORT_VARIANTS[wr.key] -- 1506
		if self.run.source ~= "debug" and variants ~= nil and #variants > 0 then -- 1506
			st.variant = pickEscortVariant(self.run.seed, st.attempt, wr.key, #variants) -- 1508
		else -- 1508
			st.variant = 0 -- 1510
		end -- 1510
		if wr.key == "escort3" then -- 1510
			if st.room ~= "escort3" then -- 1510
				st.room = "escort3" -- 1516
				st.deferred = true -- 1517
				st.offers = {} -- 1518
			end -- 1518
		else -- 1518
			draftTalentOffers(st, wr.key, self.equippedWeapon) -- 1521
		end -- 1521
	end -- 1521
	self:buildEnemies() -- 1524
	self.pickups = wr.pickups == nil and ({}) or __TS__ArraySlice(wr.pickups) -- 1525
	local i = 0 -- 1526
	do -- 1526
		i = 0 -- 1527
		while i < #self.boxes do -- 1527
			do -- 1527
				local b = self.boxes[i + 1] -- 1528
				if b.id == nil then -- 1528
					goto __continue160 -- 1530
				end -- 1530
				local st = self.run.props[b.id] -- 1532
				if st ~= nil then -- 1532
					b.broken = st.broken -- 1534
					local ____temp_74 -- 1535
					if b.breakable == nil then -- 1535
						____temp_74 = nil -- 1535
					else -- 1535
						____temp_74 = __TS__ObjectAssign({}, b.breakable, {hp = st.hp}) -- 1535
					end -- 1535
					b.breakable = ____temp_74 -- 1535
					b.hidden = b.hidden == true and st.revealed ~= true -- 1536
					if b.hidden then -- 1536
						b.broken = true -- 1538
					end -- 1538
				elseif b.hidden == true then -- 1538
					b.broken = true -- 1542
				end -- 1542
			end -- 1542
			::__continue160:: -- 1542
			i = i + 1 -- 1527
		end -- 1527
	end -- 1527
	if wr.cart.bodyW > 0 then -- 1527
		self.cartAxle = wr.cart.startX -- 1546
		if self.run.props.c2_cart ~= nil and self.run.props.c2_cart.broken then -- 1546
			self.cartAxle = wr.cart.endX -- 1548
			self.cartDocked = true -- 1549
		end -- 1549
	end -- 1549
	self:log((("进入 " .. wr.name) .. " · ") .. self.run.route) -- 1552
end -- 1461
function Play.prototype.log(self, line) -- 1555
	local ____self_run_log_75 = self.run.log -- 1555
	____self_run_log_75[#____self_run_log_75 + 1] = (("[" .. tostring(self.run.ticks)) .. "] ") .. line -- 1556
	if #self.run.log > 120 then -- 1556
		table.remove(self.run.log, 1) -- 1558
	end -- 1558
end -- 1555
function Play.prototype.buildEnemies(self) -- 1562
	self.enemies = {} -- 1563
	if self.isCampaign then -- 1563
		local variants = ESCORT_VARIANTS[self.room.key] -- 1565
		local useVariant = self:isEscortRoom() and self.run.story.route == "soldier" and self.run.source ~= "debug" and variants ~= nil and #variants > 0 -- 1566
		local ____useVariant_79 -- 1571
		if useVariant then -- 1571
			local ____temp_78 = #variants - 1 -- 1572
			local ____opt_76 = self.run.story.talents -- 1572
			____useVariant_79 = math.max( -- 1572
				0, -- 1572
				math.min(____temp_78, ____opt_76 and ____opt_76.variant or 0) -- 1572
			) -- 1572
		else -- 1572
			____useVariant_79 = 0 -- 1573
		end -- 1573
		local vIdx = ____useVariant_79 -- 1571
		local spawnList = useVariant and variants[vIdx + 1] or self.room.spawns -- 1574
		local i = 0 -- 1575
		do -- 1575
			i = 0 -- 1576
			while i < #spawnList do -- 1576
				local sp = spawnList[i + 1] -- 1577
				local kind = sp.kind or "gunner" -- 1578
				local hp = sp.shieldHp or (kind == "shield" and 2 or 0) -- 1579
				local sx = useVariant and self.ox + sp.x or sp.x -- 1580
				local ____self_enemies_80 = self.enemies -- 1580
				____self_enemies_80[#____self_enemies_80 + 1] = { -- 1581
					x = sx, -- 1582
					y = sp.y, -- 1582
					depth = sp.depth, -- 1582
					w = 26, -- 1582
					h = sp.h, -- 1582
					alive = true, -- 1582
					hitT = 0, -- 1582
					warnT = 0, -- 1582
					fireCd = 40, -- 1582
					kind = kind, -- 1583
					shieldHp = hp, -- 1583
					shieldHpMax = hp, -- 1583
					drop = sp.drop or "none", -- 1583
					homeX = sx, -- 1584
					swingT = 0, -- 1584
					awake = false, -- 1584
					squad = i -- 1584
				} -- 1584
				i = i + 1 -- 1576
			end -- 1576
		end -- 1576
		return -- 1587
	end -- 1587
	if self.room.key == "checkpoint" then -- 1587
		local ____self_enemies_81 = self.enemies -- 1587
		____self_enemies_81[#____self_enemies_81 + 1] = { -- 1590
			x = self.ox + 430, -- 1590
			y = 0, -- 1590
			w = 26, -- 1590
			h = 84, -- 1590
			alive = true, -- 1590
			hitT = 0, -- 1590
			warnT = 0, -- 1590
			fireCd = 0 -- 1590
		} -- 1590
		local ____self_enemies_82 = self.enemies -- 1590
		____self_enemies_82[#____self_enemies_82 + 1] = { -- 1591
			x = self.ox + 505, -- 1591
			y = 0, -- 1591
			w = 26, -- 1591
			h = 84, -- 1591
			alive = true, -- 1591
			hitT = 0, -- 1591
			warnT = 0, -- 1591
			fireCd = 0 -- 1591
		} -- 1591
		return -- 1592
	end -- 1592
	if self.room.key == "street" then -- 1592
		local ____self_enemies_83 = self.enemies -- 1592
		____self_enemies_83[#____self_enemies_83 + 1] = { -- 1596
			x = self.ox + 340, -- 1596
			y = 0, -- 1596
			w = 26, -- 1596
			h = 84, -- 1596
			alive = true, -- 1596
			hitT = 0, -- 1596
			warnT = 0, -- 1596
			fireCd = 0 -- 1596
		} -- 1596
		local ____self_enemies_84 = self.enemies -- 1596
		____self_enemies_84[#____self_enemies_84 + 1] = { -- 1597
			x = self.ox + 560, -- 1597
			y = 0, -- 1597
			w = 26, -- 1597
			h = 84, -- 1597
			alive = true, -- 1597
			hitT = 0, -- 1597
			warnT = 0, -- 1597
			fireCd = 0 -- 1597
		} -- 1597
	end -- 1597
end -- 1562
function Play.prototype.emit(self, name, data) -- 1603
	local ____self_events_85 = self.events -- 1603
	____self_events_85[#____self_events_85 + 1] = {seq = self.eventSeq, tick = self.ticks, name = name, data = data} -- 1604
	self.eventSeq = self.eventSeq + 1 -- 1605
	if #self.events > 256 then -- 1605
		table.remove(self.events, 1) -- 1607
	end -- 1607
end -- 1603
function Play.prototype.drainEvents(self) -- 1615
	local out = self.events -- 1616
	self.events = {} -- 1617
	return out -- 1618
end -- 1615
function Play.prototype.adoptEvents(self, events) -- 1627
	if #events == 0 then -- 1627
		return -- 1629
	end -- 1629
	local keep = {} -- 1631
	local i = 0 -- 1632
	do -- 1632
		i = 0 -- 1633
		while i < #events do -- 1633
			do -- 1633
				local e = events[i + 1] -- 1634
				if e.name == "knock" and e.data.room ~= self.room.key then -- 1634
					goto __continue181 -- 1636
				end -- 1636
				keep[#keep + 1] = e -- 1638
			end -- 1638
			::__continue181:: -- 1638
			i = i + 1 -- 1633
		end -- 1633
	end -- 1633
	if #keep == 0 then -- 1633
		return -- 1641
	end -- 1641
	self.events = __TS__ArrayConcat(keep, self.events) -- 1643
	do -- 1643
		i = 0 -- 1644
		while i < #self.events do -- 1644
			self.events[i + 1].seq = i -- 1645
			i = i + 1 -- 1644
		end -- 1644
	end -- 1644
	self.eventSeq = #self.events -- 1647
end -- 1627
function Play.prototype.talentRank(self, talent) -- 1650
	if self.storyRoute == "soldier" and self:isEscortRoom() and self.run.story.talents ~= nil then -- 1650
		return self.run.story.talents.ranks[talent] or 0 -- 1652
	end -- 1652
	return 0 -- 1654
end -- 1650
function Play.prototype.reloadNeedTicks(self) -- 1658
	return RELOAD_ANSWER_TICKS + 60 * self:talentRank("focus") -- 1659
end -- 1658
function Play.prototype.getStoryTalentOffers(self) -- 1663
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1663
		return {} -- 1665
	end -- 1665
	local st = self.run.story.talents -- 1667
	return st ~= nil and st.room == self.room.key and st.offers or ({}) -- 1668
end -- 1663
function Play.prototype.getStoryTalentRanks(self) -- 1672
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() then -- 1672
		return nil -- 1674
	end -- 1674
	return self.run.story.talents ~= nil and self.run.story.talents.ranks or nil -- 1676
end -- 1672
function Play.prototype.getEscortAttempt(self) -- 1680
	return self.run.story.talents ~= nil and math.max(1, self.run.story.talents.attempt) or 1 -- 1681
end -- 1680
function Play.prototype.chooseTalent(self, slot) -- 1684
	if self.storyRoute ~= "soldier" or not self:isEscortRoom() or self.run.finished then -- 1684
		return false -- 1686
	end -- 1686
	local st = self.run.story.talents -- 1688
	local talent = st ~= nil and st.offers[slot + 1] or nil -- 1689
	if st == nil or talent == nil then -- 1689
		return false -- 1691
	end -- 1691
	st.ranks[talent] = (st.ranks[talent] or 0) + 1 -- 1693
	st.offers = {} -- 1694
	self.talentModalActive = false -- 1695
	local extraMsg = "" -- 1696
	if talent == "vitality" then -- 1696
		self.maxHp = self.maxHp + 1 -- 1698
		self.hp = self.hp + 1 -- 1699
		self.run.story.maxHp = self.maxHp -- 1700
		self.run.story.hp = self.hp -- 1701
	elseif talent == "salvage" then -- 1701
		local inv = self.run.inventory -- 1703
		if inv.wood < 2 and inv.wood <= inv.bell or inv.bell >= 1 and st.ranks.salvage % 2 == 1 then -- 1703
			inv.wood = inv.wood + 1 -- 1705
			extraMsg = " · 得木纹筹×1" -- 1706
		else -- 1706
			inv.bell = inv.bell + 1 -- 1708
			extraMsg = " · 得铃纹筹×1" -- 1709
		end -- 1709
		self:syncCraftBench() -- 1711
	end -- 1711
	self.sessionDirty = true -- 1713
	self:flashSet(("本领 · " .. talentNames[talent]) .. extraMsg, 1.5) -- 1714
	self:emit("storyBeat", {beat = "talent_picked", talent = talent, rank = st.ranks[talent], room = self.room.key}) -- 1715
	return true -- 1716
end -- 1684
function Play.prototype.beginReload(self) -- 1723
	self.reloadT = self:reloadTicks() -- 1724
	local camp = self.room.campaign -- 1725
	if camp ~= nil and camp.reloadPuzzle == true then -- 1725
		self:openReloadPuzzle() -- 1727
	end -- 1727
end -- 1723
function Play.prototype.openReloadPuzzle(self) -- 1732
	self.reloadOpen = true -- 1733
	self.reloadAnswerTicks = 0 -- 1734
	self.reloadWorldTicks = 0 -- 1735
	self.reloadPath = {RELOAD_START} -- 1736
	self.reloadPendingEffect = "" -- 1737
	self.reloadTryCount = self.reloadTryCount + 1 -- 1738
	self:emit( -- 1739
		"reloadOpen", -- 1739
		{ -- 1739
			tryCount = self.reloadTryCount, -- 1739
			needTicks = self:reloadNeedTicks() -- 1739
		} -- 1739
	) -- 1739
end -- 1732
function Play.prototype.closeReloadPuzzle(self) -- 1743
	self.reloadOpen = false -- 1744
	self.reloadAnswerTicks = 0 -- 1745
	self.reloadWorldTicks = 0 -- 1746
	self.reloadPath = {RELOAD_START} -- 1747
	self.reloadPendingEffect = "" -- 1748
end -- 1743
function Play.prototype.reloadTapNode(self, node) -- 1755
	if not self.reloadOpen then -- 1755
		return -- 1757
	end -- 1757
	local path = self.reloadPath -- 1759
	local last = path[#path] -- 1760
	if __TS__ArrayIndexOf(path, node) >= 0 or not reloadAdjacent(last, node) then -- 1760
		self.reloadPath = {RELOAD_START} -- 1762
		self:emit("reloadInvalid", {node = node, at = last}) -- 1763
		return -- 1764
	end -- 1764
	path[#path + 1] = node -- 1766
	if node ~= RELOAD_TARGET then -- 1766
		self:emit("reloadNode", {node = node, pathLength = #path}) -- 1768
		return -- 1769
	end -- 1769
	if not reloadPathValid(path) then -- 1769
		self.reloadPath = {RELOAD_START} -- 1772
		self:emit("reloadInvalid", {node = node, at = last}) -- 1773
		return -- 1774
	end -- 1774
	self.reloadPendingEffect = reloadEffectOf(path) -- 1776
	self.reloadOpen = false -- 1777
	self.reloadT = 0 -- 1778
	self:emit("reloadSolved", {effect = self.reloadPendingEffect, answerTicks = self.reloadAnswerTicks, pathLength = #path}) -- 1779
	self:flashSet( -- 1782
		"枪机复位 · " .. reloadEffectName(self.reloadPendingEffect), -- 1782
		1.4 -- 1782
	) -- 1782
end -- 1755
function Play.prototype.consumeReloadEffect(self) -- 1786
	local e = self.reloadPendingEffect -- 1787
	if e ~= "" then -- 1787
		self.reloadPendingEffect = "" -- 1789
	end -- 1789
	return e -- 1791
end -- 1786
function Play.prototype.echoToSource(self, from, count, delayTicks) -- 1798
	if count == nil then -- 1798
		count = 1 -- 1798
	end -- 1798
	if delayTicks == nil then -- 1798
		delayTicks = 60 -- 1798
	end -- 1798
	local best = -1 -- 1799
	local bestD = 1000000000 -- 1800
	local i = 0 -- 1801
	local woken = {} -- 1802
	local n = 0 -- 1803
	while n < count do -- 1803
		best = -1 -- 1805
		bestD = 1000000000 -- 1806
		do -- 1806
			i = 0 -- 1807
			while i < #self.enemies do -- 1807
				do -- 1807
					if woken[i] == true then -- 1807
						goto __continue215 -- 1809
					end -- 1809
					local e = self.enemies[i + 1] -- 1811
					if not e.alive then -- 1811
						goto __continue215 -- 1813
					end -- 1813
					local d = math.abs(e.x - from.x) -- 1815
					if d < bestD then -- 1815
						bestD = d -- 1817
						best = i -- 1818
					end -- 1818
				end -- 1818
				::__continue215:: -- 1818
				i = i + 1 -- 1807
			end -- 1807
		end -- 1807
		if best < 0 then -- 1807
			break -- 1822
		end -- 1822
		woken[best] = true -- 1824
		local e = self.enemies[best + 1] -- 1825
		e.awake = true -- 1826
		e.warnT = 0 -- 1827
		e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 1828
		n = n + 1 -- 1829
	end -- 1829
	if n == 0 then -- 1829
		return -- 1832
	end -- 1832
	self:flashSet(n > 1 and "回声引到多处声源 · 敌群同时抬枪" or "回声引到声源 · 他先抬枪", 1) -- 1834
end -- 1798
function Play.prototype.reloadTicks(self) -- 1837
	return math.max(6, self.run.inventory.quickbelt > 0 and 36 or 54) -- 1838
end -- 1837
function Play.prototype.update(self, dt, input) -- 1841
	self:syncCraftBench() -- 1842
	if not self.paused and self.craftBench.active and input.pause.pressed then -- 1842
		self:closeCraftBench() -- 1844
		return -- 1845
	end -- 1845
	if input.pause.pressed then -- 1845
		self.paused = not self.paused -- 1848
	end -- 1848
	if self.flashT > 0 then -- 1848
		self.flashT = self.flashT - dt -- 1851
		if self.flashT <= 0 then -- 1851
			self.flash = "" -- 1853
		end -- 1853
	end -- 1853
	if self.traceT > 0 then -- 1853
		self.traceT = self.traceT - dt -- 1857
		if self.traceT <= 0 then -- 1857
			self.trace = nil -- 1859
		end -- 1859
	end -- 1859
	if self.paused then -- 1859
		self:updateCamera(dt) -- 1863
		return -- 1864
	end -- 1864
	if self.escortFailed then -- 1864
		self.escortFailedTicks = self.escortFailedTicks + 1 -- 1868
		self:updateCamera(dt) -- 1869
		return -- 1870
	end -- 1870
	if self.craftBench.active then -- 1870
		self:updateCamera(dt) -- 1875
		return -- 1876
	end -- 1876
	if self.talentModalActive and #self:getStoryTalentOffers() > 0 and not self.reloadOpen then -- 1876
		self:updateCamera(dt) -- 1880
		return -- 1881
	end -- 1881
	if self.reloadOpen then -- 1881
		local needTicks = self:reloadNeedTicks() -- 1887
		self.reloadAnswerTicks = self.reloadAnswerTicks + 1 -- 1888
		if self.reloadAnswerTicks > needTicks then -- 1888
			self.reloadOpen = false -- 1890
			self.reloadPendingEffect = "" -- 1891
			self:emit("reloadTimeout", {answerTicks = self.reloadAnswerTicks, needTicks = needTicks}) -- 1892
			self:flashSet("换弹超时 · 普通装填", 1.2) -- 1893
		elseif self.reloadAnswerTicks % RELOAD_ANSWER_PER_WORLD ~= 0 then -- 1893
			self:updateCamera(dt) -- 1895
			return -- 1896
		else -- 1896
			self.reloadWorldTicks = self.reloadWorldTicks + 1 -- 1898
		end -- 1898
	end -- 1898
	self.ticks = self.ticks + 1 -- 1902
	if self.invulnT > 0 then -- 1902
		self.invulnT = self.invulnT - 1 -- 1906
	end -- 1906
	if self.isCampaign then -- 1906
		local ____self_run_86, ____ticks_87 = self.run, "ticks" -- 1906
		____self_run_86[____ticks_87] = ____self_run_86[____ticks_87] + 1 -- 1909
		self.run.roomTicks[self.room.key] = (self.run.roomTicks[self.room.key] or 0) + 1 -- 1910
	end -- 1910
	local p = self.player -- 1912
	self:stepPlayer(p, dt, input) -- 1913
	self:refreshCover(p, input) -- 1915
	if self.carryOn then -- 1915
		self:carryPose() -- 1917
	end -- 1917
	if self.isCampaign then -- 1917
		self:stepCampaign(dt, input) -- 1920
		if not self.carryOn then -- 1920
			self:stepCampaignPartner(dt) -- 1922
		end -- 1922
	end -- 1922
	self:stepEnemies(dt, input) -- 1927
	if not self.isCampaign then -- 1927
		self:stepStory(dt, input) -- 1929
		self:stepEscort(dt, input) -- 1930
		self:stepVillage(dt, input) -- 1931
		self:stepChase(dt, input) -- 1932
		self:stepInteract(dt, input) -- 1933
	end -- 1933
	self:updateGate() -- 1935
	self:updateCamera(dt) -- 1936
	self:syncStory() -- 1938
end -- 1841
function Play.prototype.underLowArch(self, a) -- 1945
	local arch = self.room.arch -- 1946
	if arch.h <= 0 then -- 1946
		return false -- 1948
	end -- 1948
	if a.x + a.w / 2 <= arch.x0 or a.x - a.w / 2 >= arch.x1 then -- 1948
		return false -- 1951
	end -- 1951
	local top = arch.y + arch.h -- 1953
	return a.y + CHILD_H > top and a.y + CHILD_CROUCH_H <= top -- 1954
end -- 1945
function Play.prototype.coverAt(self, a) -- 1961
	local best = nil -- 1962
	local bestGap = 24 -- 1963
	local half = a.w / 2 -- 1964
	local i = 0 -- 1965
	do -- 1965
		i = 0 -- 1966
		while i < #self.boxes do -- 1966
			do -- 1966
				local b = self.boxes[i + 1] -- 1967
				if b.passable == true or b.y1 - b.y0 < 44 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 1967
					goto __continue248 -- 1969
				end -- 1969
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 1969
					goto __continue248 -- 1972
				end -- 1972
				local gap = math.max(b.x0 - (a.x + half), a.x - half - b.x1, 0) -- 1974
				if gap < bestGap then -- 1974
					bestGap = gap -- 1976
					best = b -- 1977
				end -- 1977
			end -- 1977
			::__continue248:: -- 1977
			i = i + 1 -- 1966
		end -- 1966
	end -- 1966
	return best -- 1980
end -- 1961
function Play.prototype.nearCover(self, a) -- 1983
	return self:coverAt(a) ~= nil -- 1984
end -- 1983
function Play.prototype.coverGuardsFrom(self, b, a, enemy) -- 1988
	if enemy == nil then -- 1988
		return false -- 1990
	end -- 1990
	local fromRight = enemy.x >= a.x -- 1992
	local edge = fromRight and b.x0 or b.x1 -- 1993
	local ____fromRight_88 -- 1994
	if fromRight then -- 1994
		____fromRight_88 = edge >= a.x - 0.001 and edge <= enemy.x -- 1994
	else -- 1994
		____fromRight_88 = edge <= a.x + 0.001 and edge >= enemy.x -- 1995
	end -- 1995
	local between = ____fromRight_88 -- 1994
	local separation = enemy.x - a.x -- 1996
	local fraction = separation == 0 and 0 or (edge - a.x) / separation -- 1997
	local depthAtEdge = a.depth + ((enemy.depth or 0) - a.depth) * fraction -- 1998
	return between and overlapsDepth(depthAtEdge, b.depth, 0) -- 1999
end -- 1988
function Play.prototype.nearestEnemy(self, a) -- 2002
	local best -- 2003
	local bestD = 1000000000 -- 2004
	local i = 0 -- 2005
	do -- 2005
		i = 0 -- 2006
		while i < #self.enemies do -- 2006
			do -- 2006
				local e = self.enemies[i + 1] -- 2007
				if not e.alive then -- 2007
					goto __continue257 -- 2009
				end -- 2009
				local d = math.abs(e.x - a.x) -- 2011
				if d < bestD then -- 2011
					bestD = d -- 2013
					best = e -- 2014
				end -- 2014
			end -- 2014
			::__continue257:: -- 2014
			i = i + 1 -- 2006
		end -- 2006
	end -- 2006
	return best -- 2017
end -- 2002
function Play.prototype.refreshCover(self, a, input) -- 2021
	if self.childMode then -- 2021
		self.coverNear = false -- 2023
		self.coverHug = false -- 2024
		self.coverEntity = "" -- 2025
		self.coverBlocking = false -- 2026
		a.covered = false -- 2027
		return -- 2028
	end -- 2028
	local b = self:coverAt(a) -- 2030
	self.coverNear = b ~= nil -- 2031
	a.covered = self.coverNear and input.cover.held -- 2032
	self.coverHug = a.covered -- 2033
	self.coverEntity = b == nil and "" or (b.label == nil and "一人高实体" or b.label) -- 2034
	self.coverBlocking = b ~= nil and self:coverGuardsFrom( -- 2035
		b, -- 2035
		a, -- 2035
		self:nearestEnemy(a) -- 2035
	) -- 2035
end -- 2021
function Play.prototype.cartHandleInReach(self, a) -- 2039
	if a == nil then -- 2039
		a = self.player -- 2039
	end -- 2039
	local c = self.room.cart -- 2040
	if self.cartDocked or c.bodyW <= 0 or c.endX == c.startX then -- 2040
		return false -- 2042
	end -- 2042
	local handleX = self.cartAxle + c.handleOffset -- 2044
	return math.abs(a.x - handleX) <= ____exports.CART_REACH and math.abs(a.y - c.baseY) <= 40 and inReachDepth(a.depth, c.depth or 0) -- 2045
end -- 2039
function Play.prototype.nearLowLedge(self, a) -- 2050
	local reach = 26 -- 2051
	local x0 = a.facing > 0 and a.x + a.w / 2 or a.x - a.w / 2 - reach -- 2052
	local x1 = x0 + reach -- 2053
	local i = 0 -- 2054
	do -- 2054
		i = 0 -- 2055
		while i < #self.boxes do -- 2055
			do -- 2055
				local b = self.boxes[i + 1] -- 2056
				if b.x1 <= x0 or b.x0 >= x1 or not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 2056
					goto __continue266 -- 2058
				end -- 2058
				local rise = b.y1 - a.y -- 2060
				if rise > 0 and rise <= LEDGE_RISE then -- 2060
					return true -- 2062
				end -- 2062
			end -- 2062
			::__continue266:: -- 2062
			i = i + 1 -- 2055
		end -- 2055
	end -- 2055
	return false -- 2065
end -- 2050
function Play.prototype.stepPlayer(self, a, dt, input) -- 2068
	a.depthSpeed = 0 -- 2069
	if not a.alive then -- 2069
		return -- 2071
	end -- 2071
	local isChild = self.childMode -- 2073
	local lowArch = isChild and self:underLowArch(a) -- 2075
	if self:storyLocked() then -- 2075
		a.vx = 0 -- 2078
		a.crouch = isChild and lowArch -- 2079
		a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2080
		self:fallY(a, dt) -- 2081
		return -- 2082
	end -- 2082
	if not isChild and self.escort.state == "calming" then -- 2082
		a.crouch = false -- 2086
		a.h = SOLDIER_H -- 2087
		a.vx = 0 -- 2088
		self:fallY(a, dt) -- 2089
		return -- 2090
	end -- 2090
	local downCrouch = self.room.depth == nil and input.moveY > 0 -- 2092
	a.crouch = isChild and (input.crouch.held or downCrouch or lowArch) and a.onGround -- 2093
	a.h = a.crouch and CHILD_CROUCH_H or (isChild and CHILD_H or SOLDIER_H) -- 2094
	local nearCover = not isChild and self:nearCover(a) -- 2095
	a.covered = nearCover and input.cover.held -- 2096
	local gripIntent = not self.gripping and input.interact.pressed and self:cartHandleInReach(a) -- 2098
	if a.rollT > 0 then -- 2098
		a.rollT = a.rollT - dt -- 2102
		local rollSpd = self:isEscortRoom() and ROLL_SPEED * (1 + 0.08 * self:talentRank("stride")) or ROLL_SPEED -- 2103
		a.vx = a.facing * rollSpd -- 2104
		self:slideX(a, a.vx * dt) -- 2105
		self:fallY(a, dt) -- 2106
		if a.rollT <= 0 then -- 2106
			self:flashSet("翻滚结束", 0.5) -- 2108
		end -- 2108
		return -- 2110
	end -- 2110
	local peacefulRoom = self.room.key == "museum" or self.room.key == "tower" -- 2113
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and input.jump.pressed and a.onGround then -- 2113
		if input.moveX ~= 0 then -- 2113
			a.facing = input.moveX > 0 and 1 or -1 -- 2116
		end -- 2116
		if self:nearLowLedge(a) then -- 2116
			a.vy = SOLDIER_JUMP -- 2120
			a.onGround = false -- 2121
			self:flashSet("翻上去", 0.3) -- 2122
			return -- 2123
		end -- 2123
		a.rollT = ROLL_TIME -- 2125
		self:flashSet("翻滚", 0.3) -- 2126
		return -- 2127
	end -- 2127
	local speed = isChild and CHILD_SPEED or SOLDIER_SPEED -- 2130
	if isChild then -- 2130
		if input.cover.held then -- 2130
			speed = CHILD_SLOW -- 2133
		end -- 2133
		if a.crouch then -- 2133
			speed = CHILD_SLOW -- 2136
		elseif self.room.key == "forest" and self.forestPath == "ditch" and a.x >= self.ox + 700 and a.x <= self.ox + 1140 then -- 2136
			speed = CHILD_SPEED * 1.22 -- 2140
		end -- 2140
	else -- 2140
		if self:isEscortRoom() then -- 2140
			speed = speed * (1 + 0.1 * self:talentRank("stride")) -- 2144
		end -- 2144
		if a.covered then -- 2144
			speed = speed * 0.45 -- 2147
		end -- 2147
	end -- 2147
	local handsBusy = self.gripping or gripIntent or self.reloadOpen -- 2152
	local dir = (self.gripping or self.reloadOpen) and 0 or input.moveX -- 2153
	local depthDir = self.room.depth ~= nil and not handsBusy and (not isChild or self.phase == "prologue-escape") and -input.moveY or 0 -- 2155
	local diagonal = dir ~= 0 and depthDir ~= 0 and DIAGONAL_SCALE or 1 -- 2157
	if dir ~= 0 then -- 2157
		a.facing = dir > 0 and 1 or -1 -- 2159
	end -- 2159
	a.vx = dir * speed * diagonal -- 2161
	if isChild and not self.gripping and not gripIntent and input.jump.pressed and a.onGround and not a.crouch then -- 2161
		a.vy = CHILD_JUMP -- 2165
		a.onGround = false -- 2166
		self:flashSet("跳", 0.25) -- 2167
	end -- 2167
	local previousDepth = a.depth -- 2171
	self:slideDepth(a, depthDir * speed * DEPTH_SPEED_RATIO * diagonal * dt) -- 2172
	a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2173
	self:slideX(a, a.vx * dt) -- 2174
	self:fallY(a, dt) -- 2175
	if not isChild and not peacefulRoom and not self.gripping and not gripIntent and not self.reloadOpen and input.fire.pressed then -- 2175
		self:shoot(a) -- 2179
	end -- 2179
	local ____temp_91 = not isChild and not peacefulRoom and not self.gripping and not self.reloadOpen and self.reloadPendingEffect == "" -- 2182
	if ____temp_91 then -- 2182
		local ____opt_89 = self.room.campaign -- 2182
		____temp_91 = (____opt_89 and ____opt_89.reloadPuzzle) == true -- 2182
	end -- 2182
	if ____temp_91 and input.flare.pressed then -- 2182
		self:beginReload() -- 2184
	end -- 2184
end -- 2068
function Play.prototype.stepPartner(self, p, dt) -- 2189
	local a = self.partner -- 2190
	if not a.alive then -- 2190
		return -- 2192
	end -- 2192
	a.crouch = false -- 2194
	a.h = a.w == CHILD_W and CHILD_H or SOLDIER_H -- 2195
	a.vx = 0 -- 2196
	a.depthSpeed = 0 -- 2197
	self:fallY(a, dt) -- 2198
end -- 2189
function Play.prototype.stepEscort(self, dt, input) -- 2205
	local a = self.partner -- 2206
	a.depthSpeed = 0 -- 2207
	if not a.alive then -- 2207
		return -- 2209
	end -- 2209
	if self.room.key == "gatepath" then -- 2209
		if self.carryOn then -- 2209
			return -- 2214
		end -- 2214
		local p = self.player -- 2217
		a.depth = p.depth -- 2218
		a.facing = p.facing -- 2219
		a.crouch = false -- 2220
		a.h = CHILD_H -- 2221
		a.x = p.x - p.facing * (CHILD_W / 2 + 8) -- 2222
		a.y = p.y -- 2223
		a.vy = 0 -- 2224
		a.vx = p.vx -- 2225
		a.onGround = p.onGround -- 2226
		return -- 2227
	end -- 2227
	if not self:escortOn() then -- 2227
		a.vx = 0 -- 2230
		self:fallY(a, dt) -- 2231
		return -- 2232
	end -- 2232
	local p = self.player -- 2234
	local dist = inReachDepth(p.depth, a.depth) and math.abs(p.x - a.x) or 1000000000 -- 2235
	local hadKnock1 = self.escort.knock1 -- 2236
	local hadKnock2 = self.escort.knock2 -- 2237
	self.calmConsumed = self.escort:update( -- 2238
		input, -- 2238
		p.x, -- 2238
		p.facing, -- 2238
		a.x, -- 2238
		dist -- 2238
	) -- 2238
	if not hadKnock1 and self.escort.knock1 then -- 2238
		self:emit("knock", {count = 1, x = a.x, room = self.room.key}) -- 2241
	end -- 2241
	if not hadKnock2 and self.escort.knock2 then -- 2241
		self:emit("knock", {count = 2, x = a.x, room = self.room.key}) -- 2244
	end -- 2244
	a.crouch = self.escort.crouchPose -- 2246
	a.h = a.crouch and CHILD_CROUCH_H or CHILD_H -- 2247
	if not self.escort.stopped then -- 2247
		local targetDepth = self.escort.state == "follow" and p.depth or 0 -- 2249
		local previousDepth = a.depth -- 2250
		local travel = CHILD_SPEED * DEPTH_SPEED_RATIO * dt -- 2251
		local distance = math.max( -- 2252
			-travel, -- 2252
			math.min(travel, targetDepth - previousDepth) -- 2252
		) -- 2252
		self:slideDepth(a, distance) -- 2253
		a.depthSpeed = dt > 0 and (a.depth - previousDepth) / dt or 0 -- 2254
		if math.abs(distance) > 0.5 and a.depth == previousDepth and a.onGround then -- 2254
			a.vy = CHILD_JUMP -- 2256
			a.onGround = false -- 2257
		end -- 2257
	end -- 2257
	local dir = self.escort:moveDir(a.x) -- 2260
	a.vx = dir * CHILD_SPEED -- 2261
	if dir ~= 0 then -- 2261
		a.facing = dir -- 2263
		local before = a.x -- 2264
		self:slideX(a, dir * CHILD_SPEED * dt) -- 2265
		if a.onGround and math.abs(a.x - before) < 0.4 then -- 2265
			a.vy = CHILD_JUMP -- 2268
			a.onGround = false -- 2269
		end -- 2269
	end -- 2269
	self:fallY(a, dt) -- 2272
end -- 2205
function Play.prototype.escortOn(self) -- 2276
	if self.room.key == "checkpoint" then -- 2276
		return true -- 2278
	end -- 2278
	if self.room.key == "gatepath" then -- 2278
		return true -- 2281
	end -- 2281
	if self.room.key == "prologue" then -- 2281
		return self.phase == "prologue-follow" -- 2284
	end -- 2284
	if self.room.key == "escort1" or self.room.key == "escort2" or self.room.key == "escort3" or self.room.key == "escort4" or self.room.key == "escort5" then -- 2284
		return true -- 2288
	end -- 2288
	return self.room.key == "street" -- 2290
end -- 2276
function Play.prototype.storyLocked(self) -- 2294
	if self.caughtT > 0 then -- 2294
		return true -- 2296
	end -- 2296
	if self.room.key == "prologue" and (self.phase == "prologue-wake" or self.phase == "prologue-shadow" or self.phase == "prologue-hide") then -- 2296
		return true -- 2300
	end -- 2300
	if self.room.key == "prologue" and self.phase == "prologue-give" then -- 2300
		return true -- 2303
	end -- 2303
	if self.room.key == "gate" and (self.phase == "gate-farewell" or self.phase == "gate-count" or self.phase == "gate-wait" or self.phase == "gate-hand") then -- 2303
		return true -- 2306
	end -- 2306
	if self.room.key == "tower" and (self.phase == "tower-knock" or self.phase == "tower-given") then -- 2306
		return true -- 2309
	end -- 2309
	if self.room.key == "museum" and self.phase == "museum-knock" then -- 2309
		return true -- 2312
	end -- 2312
	if self.craftBench.active then -- 2312
		return true -- 2316
	end -- 2316
	return false -- 2318
end -- 2294
function Play.prototype.swapToChild(self, x) -- 2322
	local tmp = self.player -- 2323
	self.player = self.partner -- 2324
	self.partner = tmp -- 2325
	self.childMode = true -- 2326
	self.player.alive = true -- 2327
	self.player.x = self.ox + x -- 2328
	self.player.y = 0 -- 2329
	self.player.depth = 0 -- 2330
	self.player.depthSpeed = 0 -- 2331
	self.player.vy = 0 -- 2332
	self.player.vx = 0 -- 2333
	self.player.onGround = true -- 2334
	self.player.crouch = false -- 2335
	self.player.h = CHILD_H -- 2336
	self.player.facing = 1 -- 2337
	self.partner.alive = true -- 2338
	self.cam.x = self.player.x -- 2339
end -- 2322
function Play.prototype.swapToSoldier(self, x, childX) -- 2343
	local tmp = self.player -- 2344
	self.player = self.partner -- 2345
	self.partner = tmp -- 2346
	self.childMode = false -- 2347
	self.player.alive = true -- 2348
	self.player.x = self.ox + x -- 2349
	self.player.y = 0 -- 2350
	self.player.depth = 0 -- 2351
	self.player.depthSpeed = 0 -- 2352
	self.player.vy = 0 -- 2353
	self.player.vx = 0 -- 2354
	self.player.onGround = true -- 2355
	self.player.crouch = false -- 2356
	self.player.h = SOLDIER_H -- 2357
	self.player.facing = 1 -- 2358
	self.partner.alive = true -- 2359
	self.partner.x = self.ox + childX -- 2360
	self.partner.y = 0 -- 2361
	self.partner.depth = 0 -- 2362
	self.partner.depthSpeed = 0 -- 2363
	self.partner.vx = 0 -- 2364
	self.partner.vy = 0 -- 2365
	self.partner.onGround = true -- 2366
	self.partner.crouch = true -- 2367
	self.partner.h = CHILD_CROUCH_H -- 2368
	self.cam.x = self.player.x -- 2369
end -- 2343
function Play.prototype.stepStory(self, dt, input) -- 2373
	if self.room.key == "prologue" then -- 2373
		self:stepPrologue(dt, input) -- 2375
	elseif self.room.key == "street" then -- 2375
		self:stepStreet(dt, input) -- 2377
	elseif self.room.key == "gate" then -- 2377
		self:stepGate(dt, input) -- 2379
	elseif self.room.key == "gatepath" then -- 2379
		self:stepGatePath() -- 2381
	elseif self.room.key == "tower" then -- 2381
		self:stepTower(dt, input) -- 2383
	elseif self.room.key == "museum" then -- 2383
		self:stepMuseum(dt, input) -- 2385
	end -- 2385
end -- 2373
function Play.prototype.canPersistProgress(self) -- 2391
	return not self.isCampaign and self.run.source == "official" -- 2392
end -- 2391
function Play.prototype.wellWindow(self) -- 2396
	return self:canPersistProgress() and not self.archive.artifactOwned and self.archive.childCleared and self.archive.soldierCleared -- 2397
end -- 2396
function Play.prototype.nearWell(self) -- 2402
	return math.abs(self.player.x - (self.ox + self.wellX)) <= 44 and self.player.y < 20 and inReachDepth(self.player.depth, 0) -- 2403
end -- 2402
function Play.prototype.pickWell(self) -- 2411
	if not self:wellWindow() or self.wellTaken or self.phase ~= "prologue-wait" or not self:nearWell() then -- 2411
		return false -- 2413
	end -- 2413
	self.phase = "prologue-well" -- 2415
	self.phaseTick = 0 -- 2416
	self.wellOpen = false -- 2417
	self:flashSet("井沿 · 伸手下去", 1.4) -- 2418
	self:log("旧井拾取") -- 2419
	return true -- 2420
end -- 2411
function Play.prototype.stepPrologue(self, dt, input) -- 2423
	local child = self.partner -- 2424
	if self.museumReturn then -- 2424
		self.museumReturn = false -- 2427
		self.phase = "prologue-wait" -- 2428
		self.phaseTick = 0 -- 2429
		self.player.x = self.ox + 260 -- 2430
		self.player.y = 0 -- 2431
		self.player.depth = 0 -- 2432
		self:flashSet("回到柜边 · 小满还在柜后", 1.6) -- 2433
	end -- 2433
	if self.phase == "prologue-wake" then -- 2433
		self.introTick = self.introTick + 1 -- 2437
		if self.introTick == 60 then -- 2437
			self:flashSet("门外有人唤 · 小满", 1.2) -- 2439
		end -- 2439
		if self.introTick >= ____exports.PROLOGUE_WAKE_TICKS then -- 2439
			self.phase = "prologue-shadow" -- 2442
			self.introTick = 0 -- 2443
			self:flashSet("门缝里两道影子", 1.2) -- 2444
			self:emit("prologueBeat", {beat = "wake", ticks = ____exports.PROLOGUE_WAKE_TICKS}) -- 2445
		end -- 2445
		return -- 2447
	end -- 2447
	if self.phase == "prologue-shadow" then -- 2447
		self.introTick = self.introTick + 1 -- 2450
		if self.introTick >= ____exports.PROLOGUE_SHADOW_TICKS then -- 2450
			self.phase = "prologue-escape" -- 2453
			self.introTick = 0 -- 2454
			self.escapeRemaining = self.escapeDuration -- 2455
			self.escapeRetryCount = 0 -- 2456
			self:swapToChild(100) -- 2457
			self:flashSet( -- 2458
				("逃进倒柜 · 限时 " .. __TS__NumberToFixed(self.escapeDuration, 1)) .. " 秒", -- 2458
				1.6 -- 2458
			) -- 2458
			self:emit("prologueBeat", {beat = "escape", ticks = ____exports.PROLOGUE_SHADOW_TICKS, duration = self.escapeDuration}) -- 2459
		end -- 2459
		return -- 2463
	end -- 2463
	if self.phase == "prologue-escape" then -- 2463
		self.escapeRemaining = math.max(0, self.escapeRemaining - STEP) -- 2466
		if self.player.x >= self.ox + ____exports.PROLOGUE_CABINET_X then -- 2466
			self.phase = "prologue-hide" -- 2469
			self.introTick = 0 -- 2470
			self.player.vx = 0 -- 2471
			self.player.crouch = true -- 2472
			self.player.h = CHILD_CROUCH_H -- 2473
			self:flashSet("柜门合上 · 屏住呼吸", 1.4) -- 2474
			self:emit("prologueBeat", {beat = "hide", x = self.player.x, delay = self.escapeDuration - self.escapeRemaining}) -- 2475
			return -- 2479
		end -- 2479
		if self.escapeRemaining <= 0 then -- 2479
			self.escapeRetryCount = self.escapeRetryCount + 1 -- 2483
			self.player.x = self.ox + 100 -- 2484
			self.player.y = 0 -- 2485
			self.player.depth = 0 -- 2486
			self.player.vx = 0 -- 2487
			self.player.vy = 0 -- 2488
			self.escapeRemaining = self.escapeDuration -- 2489
			self:flashSet("再快一点 · 退回门口", 1.4) -- 2490
			self:emit("prologueBeat", {beat = "escapeRetry", attempt = self.escapeRetryCount}) -- 2491
			return -- 2492
		end -- 2492
		return -- 2494
	end -- 2494
	if self.phase == "prologue-hide" then -- 2494
		self.introTick = self.introTick + 1 -- 2497
		if self.introTick >= ____exports.PROLOGUE_HIDE_TICKS then -- 2497
			self.phase = "prologue-wait" -- 2500
			self.phaseTick = 0 -- 2501
			self.introTick = 0 -- 2502
			self:swapToSoldier(260, 300) -- 2503
			self:flashSet("周戍蹲到柜边 · 点 E 递针套", 1.6) -- 2504
			self:emit("prologueBeat", {beat = "wait", ticks = ____exports.PROLOGUE_HIDE_TICKS}) -- 2505
		end -- 2505
		return -- 2507
	end -- 2507
	self.wellOpen = self.phase == "prologue-wait" and self:wellWindow() and not self.wellTaken -- 2510
	if self.phase == "prologue-wait" then -- 2510
		child.crouch = true -- 2512
		child.h = CHILD_CROUCH_H -- 2513
		if self.wellOpen and input.interact.pressed and self:nearWell() then -- 2513
			self:pickWell() -- 2515
			return -- 2516
		end -- 2516
		if not self.wellOpen and self:canPersistProgress() and self.archive.artifactOwned and not self.archive.museumSeen and self:nearWell() and input.interact.pressed then -- 2516
			self.archive.museumPhase = "well_reflect" -- 2521
			self.archiveDirty = true -- 2522
			self:requestRoom("museum", "初次使用 · 时间穿梭器") -- 2523
			return -- 2524
		end -- 2524
		local reach = (self.room.story == nil or self.room.story.prologue == nil) and 46 or self.room.story.prologue.giveReach -- 2526
		local near = math.abs(self.player.x - child.x) <= reach and inReachDepth(self.player.depth, child.depth) -- 2528
		if near and input.interact.pressed then -- 2528
			self.phase = "prologue-give" -- 2530
			self.phaseTick = 0 -- 2531
			self:flashSet("递出针套", 1) -- 2532
		end -- 2532
		return -- 2534
	end -- 2534
	if self.phase == "prologue-well" then -- 2534
		self.phaseTick = self.phaseTick + 1 -- 2538
		if self.phaseTick == 12 then -- 2538
			self:flashSet("井底有光 · 一截铁柄", 1.2) -- 2540
		elseif self.phaseTick >= 30 then -- 2540
			self.phase = "prologue-wait" -- 2542
			self.phaseTick = 0 -- 2543
			self.wellTaken = true -- 2544
			self.wellOpen = false -- 2545
			self.run.archive.artifactOwned = true -- 2546
			self.archiveDirty = true -- 2547
			self:emit("artifactFound", { -- 2548
				x = self.ox + self.wellX, -- 2549
				y = 0, -- 2549
				room = "prologue", -- 2549
				once = true, -- 2549
				source = self.run.source -- 2550
			}) -- 2550
			self:flashSet("时间穿梭器 · 收进袖口", 2) -- 2552
			self:log("井底取到时间穿梭器") -- 2553
		end -- 2553
		return -- 2555
	end -- 2555
	if self.phase == "prologue-give" then -- 2555
		self.phaseTick = self.phaseTick + 1 -- 2558
		if self.phaseTick == 36 then -- 2558
			self:flashSet("针套递过去", 0.9) -- 2560
		elseif self.phaseTick == 108 then -- 2560
			self:flashSet("纸条塞进针套", 1) -- 2562
		elseif self.phaseTick >= ____exports.PROLOGUE_GIVE_TICKS then -- 2562
			self.phase = "prologue-follow" -- 2564
			self.phaseTick = 0 -- 2565
			child.crouch = false -- 2566
			child.h = CHILD_H -- 2567
			self:flashSet("她跟上了", 1.2) -- 2568
		end -- 2568
		return -- 2570
	end -- 2570
	if self.player.x >= self.ox + 660 and child.x >= self.ox + 620 then -- 2570
		local next = self.run.source == "debug" and "street" or "s1-crossroad" -- 2574
		self:requestRoom(next, "序章跟到门口") -- 2575
		self:flashSet(next == "s1-crossroad" and "进十字街" or "进街道", 1.2) -- 2576
	end -- 2576
end -- 2423
function Play.prototype.stepStreet(self, dt, input) -- 2581
	local p = self.player -- 2582
	local c = self.partner -- 2583
	if p.x >= self.ox + 900 and c.x >= self.ox + 860 then -- 2583
		local next = self.run.source == "debug" and "checkpoint" or "s1-crossroad" -- 2585
		self:requestRoom(next, "两人都到街尾") -- 2586
		self:flashSet(next == "s1-crossroad" and "进十字街" or "到检查站", 1.2) -- 2587
	end -- 2587
end -- 2581
function Play.prototype.stepGate(self, dt, input) -- 2592
	local ____temp_92 -- 2593
	if self.room.story == nil then -- 2593
		____temp_92 = nil -- 2593
	else -- 2593
		____temp_92 = self.room.story.gate -- 2593
	end -- 2593
	local g = ____temp_92 -- 2593
	if g == nil then -- 2593
		return -- 2595
	end -- 2595
	local p = self.player -- 2597
	if self.phase == "gate-idle" then -- 2597
		local a = self.partner -- 2600
		local gap = g.waitX - a.x -- 2601
		if math.abs(gap) > 3 then -- 2601
			a.facing = gap > 0 and 1 or -1 -- 2603
			a.vx = a.facing * CHILD_SPEED -- 2604
			local beforeX = a.x -- 2605
			self:slideX(a, a.facing * CHILD_SPEED * dt) -- 2606
			if math.abs(a.x - beforeX) < 0.4 and a.onGround then -- 2606
				a.vy = CHILD_JUMP -- 2608
				a.onGround = false -- 2609
			end -- 2609
			self:fallY(a, dt) -- 2611
		else -- 2611
			a.vx = 0 -- 2613
			a.x = g.waitX -- 2614
		end -- 2614
		local atWinch = math.abs(p.x - g.winchX) <= 24 and p.y < 20 and inReachDepth(p.depth) -- 2617
		local atWait = self.partner.alive and math.abs(self.partner.x - g.waitX) <= 60 -- 2618
		if self.gateNeedConfirm then -- 2618
			if not input.interact.held then -- 2618
				self.gateRestartArmed = true -- 2623
			end -- 2623
			if self.gateRestartArmed and atWinch and atWait and input.interact.pressed then -- 2623
				self.gateNeedConfirm = false -- 2626
				self.gateRestartArmed = true -- 2627
				self.phase = "gate-hold" -- 2628
				self.gateTick = 0 -- 2629
				self.gateSpawned = 0 -- 2630
				self:flashSet("重新就位 · 守点开始", 1.4) -- 2631
				self:emit("gateRestart", {failCount = self.gateFailCount}) -- 2632
			end -- 2632
			return -- 2634
		end -- 2634
		if atWinch and atWait then -- 2634
			self.phase = "gate-hold" -- 2637
			self.gateTick = 0 -- 2638
			self.gateSpawned = 0 -- 2639
			self:flashSet("两人就位 · 守点开始", 1.4) -- 2640
		end -- 2640
		return -- 2642
	end -- 2642
	if self.phase == "gate-hold" then -- 2642
		self.gateTick = self.gateTick + 1 -- 2645
		local marks = {0, 540, 900, 1500} -- 2647
		while self.gateSpawned < #marks and self.gateTick - 1 >= marks[self.gateSpawned + 1] do -- 2647
			local idx = self.gateSpawned -- 2649
			local ____self_enemies_93 = self.enemies -- 2649
			____self_enemies_93[#____self_enemies_93 + 1] = { -- 2650
				x = self.ox + 620 + idx * 62, -- 2651
				y = 0, -- 2651
				w = 26, -- 2651
				h = 84, -- 2651
				alive = true, -- 2652
				hitT = 0, -- 2652
				warnT = 0, -- 2652
				fireCd = 90 + idx * 45 -- 2652
			} -- 2652
			self.gateSpawned = self.gateSpawned + 1 -- 2654
			self:flashSet( -- 2655
				("敌兵出现 · 第 " .. tostring(idx + 1)) .. " 批", -- 2655
				0.9 -- 2655
			) -- 2655
		end -- 2655
		if self.gateTick == 900 then -- 2655
			self:flashSet("棚布落下", 1) -- 2658
		elseif self.gateTick == 2100 then -- 2658
			self:flashSet("门底透进冷光了", 1) -- 2660
		end -- 2660
		if self.gateTick >= g.holdTicks then -- 2660
			self:captureGateBlood() -- 2665
			self.phase = "gate-send" -- 2666
			self.phaseTick = 0 -- 2667
			self.enemies = {} -- 2669
			self:flashSet("守满了 · 到门边按 E 送她", 2) -- 2670
		end -- 2670
		return -- 2672
	end -- 2672
	if self.phase == "gate-send" then -- 2672
		local near = math.abs(p.x - g.doorX) <= 60 and inReachDepth(p.depth) -- 2675
		if near and input.interact.pressed then -- 2675
			self:commitRoute() -- 2679
			self:swapToChild(g.doorX + 30) -- 2680
			self.phase = self.run.source == "debug" and "gate-count" or "gate-farewell" -- 2681
			self.phaseTick = 0 -- 2682
			self.countTick = 0 -- 2683
			self.countArmed = false -- 2685
			self.countPrevMove = input.moveX -- 2686
			self:flashSet("门开了 · 送她出去", 1.8) -- 2687
		end -- 2687
		return -- 2689
	end -- 2689
	if self.phase == "gate-farewell" then -- 2689
		self.phaseTick = self.phaseTick + 1 -- 2692
		self.countPrevMove = input.moveX -- 2693
		if self.phaseTick >= ____exports.GATE_FAREWELL_TICKS then -- 2693
			self.phase = "gate-count" -- 2695
			self.phaseTick = 0 -- 2696
			self.countTick = 0 -- 2697
			self.countArmed = false -- 2698
		end -- 2698
		return -- 2700
	end -- 2700
	if self.phase == "gate-count" then -- 2700
		self.countTick = self.countTick + 1 -- 2703
		if self.countTick == 360 then -- 2703
			self:flashSet("门关上", 0.9) -- 2705
		elseif self.countTick == ____exports.GATE_COUNT_END then -- 2705
			self:emit("gateCountDone", {route = self.storyRoute, countTick = self.countTick, hpAtGate = self.hpAtGate, maxHpAtGate = self.maxHpAtGate}) -- 2707
			if self.storyRoute == "soldier" then -- 2707
				self.phase = "gate-wait" -- 2713
				self.phaseTick = 0 -- 2714
				self.knocks = 1 -- 2715
				self:emit("knock", {count = 1, x = self.ox + g.doorX + 70, room = "gate"}) -- 2716
				self.handArmed = not input.interact.held and not self.intentGateReunionHold -- 2718
				self:flashSet("两下轻叩 · 按住 E 牵起她", 2.4) -- 2719
			else -- 2719
				self:flashSet("数到二十", 2.2) -- 2721
			end -- 2721
		end -- 2721
		local prevMove = self.countPrevMove -- 2726
		self.countPrevMove = input.moveX -- 2727
		if self.countTick >= ____exports.GATE_COUNT_END and self.storyRoute ~= "soldier" then -- 2727
			if prevMove <= 0 and input.moveX > 0 then -- 2727
				self.countArmed = true -- 2730
			end -- 2730
			if self.countArmed and input.moveX > 0 then -- 2730
				self.phase = "gate-walk" -- 2733
				self.phaseTick = 0 -- 2734
				self:flashSet("她迈出第一步", 1.4) -- 2735
				self:emit("storyExit", { -- 2736
					route = "child", -- 2736
					via = "walk", -- 2736
					countTick = self.countTick, -- 2736
					hp = self.hp, -- 2736
					maxHp = self.maxHp -- 2736
				}) -- 2736
			end -- 2736
		end -- 2736
		return -- 2739
	end -- 2739
	if self.phase == "gate-wait" then -- 2739
		self.phaseTick = self.phaseTick + 1 -- 2743
		if self.phaseTick == 12 then -- 2743
			self.knocks = 2 -- 2745
			self:emit("knock", {count = 2, x = self.ox + g.doorX + 70, room = "gate"}) -- 2746
			self:flashSet("第二下 · 她抬手了", 1.6) -- 2747
		end -- 2747
		local held = input.interact.held or self.intentGateReunionHold -- 2749
		if not held then -- 2749
			if self.handTicks > 0 then -- 2749
				self:emit("handRelease", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2752
			end -- 2752
			self.handTicks = 0 -- 2754
			self.handArmed = true -- 2755
			return -- 2756
		end -- 2756
		if self.handArmed then -- 2756
			self.handTicks = self.handTicks + 1 -- 2759
			if self.handTicks >= ____exports.GATE_HAND_TICKS then -- 2759
				self.intentGateReunionHold = false -- 2761
				self.phase = "gate-hand" -- 2762
				self.phaseTick = 0 -- 2763
				self.handDone = true -- 2764
				self.tied = true -- 2765
				self:emit("handHeld", {handTicks = self.handTicks, handNeedTicks = ____exports.GATE_HAND_TICKS}) -- 2766
				if not self.lineSaid then -- 2766
					self.lineSaid = true -- 2768
					self:emit("storyLine", {who = "周戍", text = "我们走吧。"}) -- 2769
				end -- 2769
				self:flashSet("我们走吧。", 3) -- 2771
			end -- 2771
		end -- 2771
		return -- 2774
	end -- 2774
	if self.phase == "gate-hand" then -- 2774
		self.phaseTick = self.phaseTick + 1 -- 2778
		if self.phaseTick == 30 then -- 2778
			self:flashSet("袖口先入画 · 她抓住了", 1.8) -- 2780
		elseif self.phaseTick >= 90 and self.wantRoom == "" then -- 2780
			self:emit("storyExit", { -- 2782
				route = "soldier", -- 2782
				via = "hand", -- 2782
				handTicks = self.handTicks, -- 2782
				hp = self.hp, -- 2782
				maxHp = self.maxHp -- 2782
			}) -- 2782
			self:requestRoom("gatepath", "牵手同行") -- 2783
		end -- 2783
		return -- 2785
	end -- 2785
	if self.phase == "gate-walk" then -- 2785
		if self.player.x >= g.exitX then -- 2785
			self:requestRoom("outside", "走出城门") -- 2790
			self:flashSet("出城门 · 城外", 1.4) -- 2791
		end -- 2791
	end -- 2791
end -- 2592
function Play.prototype.captureGateBlood(self) -- 2800
	self.hpAtGate = self.hp -- 2801
	self.maxHpAtGate = self.maxHp -- 2802
end -- 2800
function Play.prototype.commitRoute(self) -- 2809
	if self.storySettled then -- 2809
		return -- 2811
	end -- 2811
	local maxHp = self.maxHpAtGate > 0 and self.maxHpAtGate or (self.maxHp > 0 and self.maxHp or 1) -- 2813
	local hp = self.hpAtGate >= 0 and self.hpAtGate or self.hp -- 2814
	self.hpAtGate = hp -- 2815
	self.maxHpAtGate = self.maxHpAtGate > 0 and self.maxHpAtGate or self.maxHp -- 2816
	self.storyRoute = 100 * hp >= ____exports.GATE_ROUTE_PERCENT * maxHp and "soldier" or "child" -- 2817
	self.storySettled = true -- 2818
	self.sessionDirty = true -- 2819
	self:emit("storyRouteLocked", { -- 2820
		route = self.storyRoute, -- 2821
		hp = self.hp, -- 2821
		maxHp = self.maxHp, -- 2821
		hpAtGate = self.hpAtGate, -- 2822
		maxHpAtGate = self.maxHpAtGate -- 2822
	}) -- 2822
	self:flashSet(self.storyRoute == "soldier" and "她还够得着你 · 牵手" or "她替你数完 · 出门", 2.4) -- 2824
end -- 2809
function Play.prototype.syncStory(self) -- 2828
	local s = self.run.story -- 2829
	if s == nil then -- 2829
		return -- 2831
	end -- 2831
	s.hp = self.hp -- 2833
	s.maxHp = self.maxHp -- 2834
	s.route = self.storyRoute -- 2835
	s.settled = self.storySettled -- 2836
	s.hpAtGate = self.hpAtGate -- 2837
	s.maxHpAtGate = self.maxHpAtGate -- 2838
	s.handDone = self.handDone -- 2839
	s.lineSaid = self.lineSaid -- 2840
	s.tied = self.tied -- 2841
	s.carry = self.carryOn -- 2842
	s.museumReturn = self.museumReturn -- 2843
	s.escortDone = self.escortDone -- 2844
	s.craftedWeapon = self.run.story.craftedWeapon -- 2845
	s.equippedWeapon = self.equippedWeapon -- 2846
	s.ending = self.run.story.ending -- 2847
	if self.room.key == "gate" then -- 2847
		s.phase = self.phase -- 2849
		s.countTick = self.countTick -- 2850
		s.phaseTick = self.phaseTick -- 2851
		s.handTicks = self.handTicks -- 2852
	end -- 2852
	if self.room.key == "prologue" then -- 2852
		if self.phase == "prologue-wait" or self.phase == "prologue-give" or self.phase == "prologue-follow" then -- 2852
			s.phase = self.phase -- 2857
			s.phaseTick = self.phaseTick -- 2858
		end -- 2858
	end -- 2858
	if self.room.key == "tower" then -- 2858
		if self.phase == "tower-enter" or self.phase == "tower-desk" or self.phase == "tower-given" then -- 2858
			s.phase = self.phase -- 2864
			s.phaseTick = self.phaseTick -- 2865
		end -- 2865
	end -- 2865
end -- 2828
function Play.prototype.stepGatePath(self) -- 2871
	local ____temp_94 -- 2872
	if self.room.story == nil then -- 2872
		____temp_94 = nil -- 2872
	else -- 2872
		____temp_94 = self.room.story.gatepath -- 2872
	end -- 2872
	local gp = ____temp_94 -- 2872
	if self.phase == "gatepath-start" then -- 2872
		if gp ~= nil and self.player.onGround and self.player.x >= gp.carryX and not self.carryOn then -- 2872
			self.carryOn = true -- 2875
			self.phase = "gatepath-carry" -- 2876
			self.phaseTick = 0 -- 2877
			self.pathDone = true -- 2878
			self.escortDone = false -- 2879
			self:emit("gatePathEnd", {x = self.player.x, tied = self.tied, ticks = self.ticks}) -- 2880
			self:emit("carryStart", {x = self.player.x, tied = self.tied, route = self.storyRoute, ticks = self.ticks}) -- 2881
			self:flashSet("蹲下 · 背起小满", 2.6) -- 2882
		end -- 2882
		return -- 2884
	end -- 2884
	if self.phase == "gatepath-carry" then -- 2884
		self.phaseTick = self.phaseTick + 1 -- 2887
		if self.phaseTick == 20 then -- 2887
			self:flashSet("她已经趴稳 · 走慢一点", 2) -- 2889
		end -- 2889
		if gp ~= nil and self.player.x >= gp.exitX and self.player.onGround then -- 2889
			self:requestRoom(gp.next, "背负进首战") -- 2892
			self:flashSet("背上她 · 巷口有脚步", 2) -- 2893
		end -- 2893
	end -- 2893
end -- 2871
function Play.prototype.carryPose(self) -- 2902
	local p = self.player -- 2903
	local a = self.partner -- 2904
	a.alive = true -- 2905
	a.x = p.x - p.facing * 12 -- 2906
	a.y = p.y + 26 -- 2907
	a.depth = p.depth -- 2908
	a.vx = p.vx -- 2909
	a.vy = 0 -- 2910
	a.onGround = true -- 2911
	a.crouch = false -- 2912
	a.h = CHILD_CROUCH_H -- 2913
	a.facing = p.facing -- 2914
end -- 2902
function Play.prototype.stepMuseum(self, dt, input) -- 2922
	self.partner.alive = false -- 2923
	local mu = (self.room.story == nil or self.room.story.museum == nil) and ({cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}) or self.room.story.museum -- 2924
	local atCase = self.player.x <= self.ox + mu.cabinetX + 60 -- 2927
	local nearLamp = self.player.x >= self.ox + mu.lampX - 72 -- 2928
	local intentTarget = self.pendingMuseumIntentTarget -- 2929
	self.pendingMuseumIntentTarget = "" -- 2930
	local interactHit = input.interact.pressed or intentTarget ~= "" -- 2931
	if self.phase == "museum-cabinet" then -- 2931
		if atCase and interactHit or intentTarget == "cabinet" then -- 2931
			self.phase = "museum-hall" -- 2934
			self.phaseTick = 0 -- 2935
			if self:canPersistProgress() then -- 2935
				self.archive.museumPhase = "hall_walk" -- 2937
				self.archiveDirty = true -- 2938
			end -- 2938
			self:emit( -- 2940
				"museumStep", -- 2940
				{ -- 2940
					step = "cabinet", -- 2940
					x = self.ox + mu.cabinetX, -- 2940
					persisted = self:canPersistProgress() -- 2940
				} -- 2940
			) -- 2940
			self:flashSet("玻璃柜前 · 收枪入袖", 1.8) -- 2941
		end -- 2941
		return -- 2943
	end -- 2943
	if self.phase == "museum-hall" then -- 2943
		if intentTarget == "lamp_direct" and nearLamp then -- 2943
			self:emit( -- 2947
				"museumStep", -- 2947
				{ -- 2947
					step = "hall", -- 2947
					x = self.ox + mu.hallX, -- 2947
					persisted = self:canPersistProgress() -- 2947
				} -- 2947
			) -- 2947
			self.phase = "museum-return" -- 2948
			self.phaseTick = 0 -- 2949
			if self:canPersistProgress() then -- 2949
				self.archive.museumPhase = "return_cabinet" -- 2951
				self.archiveDirty = true -- 2952
			end -- 2952
			self:emit( -- 2954
				"museumStep", -- 2954
				{ -- 2954
					step = "lamp", -- 2954
					x = self.ox + mu.lampX, -- 2954
					persisted = self:canPersistProgress() -- 2954
				} -- 2954
			) -- 2954
			self:flashSet("灯 · 转向西窗", 1.8) -- 2955
			return -- 2956
		end -- 2956
		if self.player.x >= self.ox + mu.hallX and interactHit then -- 2956
			self.phase = "museum-lamp" -- 2959
			self.phaseTick = 0 -- 2960
			if self:canPersistProgress() then -- 2960
				self.archive.museumPhase = "lamp_turn" -- 2962
				self.archiveDirty = true -- 2963
			end -- 2963
			self:emit( -- 2965
				"museumStep", -- 2965
				{ -- 2965
					step = "hall", -- 2965
					x = self.ox + mu.hallX, -- 2965
					persisted = self:canPersistProgress() -- 2965
				} -- 2965
			) -- 2965
			self:flashSet("孩子的脚步 · 从西窗那头", 1.8) -- 2966
		end -- 2966
		return -- 2968
	end -- 2968
	if self.phase == "museum-lamp" then -- 2968
		if nearLamp and interactHit then -- 2968
			self.phase = "museum-return" -- 2972
			self.phaseTick = 0 -- 2973
			if self:canPersistProgress() then -- 2973
				self.archive.museumPhase = "return_cabinet" -- 2975
				self.archiveDirty = true -- 2976
			end -- 2976
			self:emit( -- 2978
				"museumStep", -- 2978
				{ -- 2978
					step = "lamp", -- 2978
					x = self.ox + mu.lampX, -- 2978
					persisted = self:canPersistProgress() -- 2978
				} -- 2978
			) -- 2978
			self:flashSet("灯 · 转向西窗", 1.8) -- 2979
		end -- 2979
		return -- 2981
	end -- 2981
	if self.phase == "museum-return" then -- 2981
		if atCase and interactHit or intentTarget == "return_cabinet" then -- 2981
			self.phase = "museum-knock" -- 2985
			self.phaseTick = 0 -- 2986
			self:emit( -- 2987
				"museumStep", -- 2987
				{ -- 2987
					step = "knock", -- 2987
					count = 1, -- 2987
					x = self.ox + mu.cabinetX, -- 2987
					persisted = self:canPersistProgress() -- 2987
				} -- 2987
			) -- 2987
			self:flashSet("回柜边 · 第一下", 0.8) -- 2988
		end -- 2988
		return -- 2990
	end -- 2990
	if self.phase == "museum-knock" then -- 2990
		self.phaseTick = self.phaseTick + 1 -- 2993
		if self.phaseTick == 8 then -- 2993
			self:emit( -- 2995
				"museumStep", -- 2995
				{ -- 2995
					step = "knock", -- 2995
					count = 2, -- 2995
					x = self.ox + mu.cabinetX, -- 2995
					persisted = self:canPersistProgress() -- 2995
				} -- 2995
			) -- 2995
			self:flashSet("回柜边 · 第二下", 0.8) -- 2996
		elseif self.phaseTick >= 36 then -- 2996
			self.phase = "museum-done" -- 2998
			self.phaseTick = 0 -- 2999
			if self:canPersistProgress() then -- 2999
				self.archive.museumSeen = true -- 3001
				self.archive.museumPhase = "done" -- 3002
				self.archiveDirty = true -- 3003
			end -- 3003
			self:emit( -- 3005
				"museumDone", -- 3005
				{ -- 3005
					steps = 4, -- 3005
					museumSeen = self.archive.museumSeen, -- 3005
					persisted = self:canPersistProgress() -- 3005
				} -- 3005
			) -- 3005
			self:flashSet("回柜边 · 灯还亮着", 2) -- 3006
			self:log("博物馆 · 回柜边") -- 3007
		end -- 3007
		return -- 3009
	end -- 3009
	if interactHit then -- 3009
		self.museumReturn = true -- 3012
		self:requestRoom("prologue", "回柜边") -- 3013
	end -- 3013
end -- 2922
function Play.prototype.openTowerDoor(self) -- 3017
	self.towerDoorOpen = true -- 3018
	do -- 3018
		local i = 0 -- 3019
		while i < #self.boxes do -- 3019
			if self.boxes[i + 1].id == "tower_door" then -- 3019
				self.boxes[i + 1].hidden = true -- 3021
			end -- 3021
			i = i + 1 -- 3019
		end -- 3019
	end -- 3019
	self.run.story.segments.tower_door = true -- 3024
end -- 3017
function Play.prototype.stepTower(self, dt, input) -- 3027
	local ____temp_95 -- 3028
	if self.room.story == nil then -- 3028
		____temp_95 = nil -- 3028
	else -- 3028
		____temp_95 = self.room.story.tower -- 3028
	end -- 3028
	local t = ____temp_95 -- 3028
	if t == nil then -- 3028
		return -- 3030
	end -- 3030
	if self.storyRoute == "soldier" and self.partner.alive then -- 3030
		local targetX = math.max(self.ox + 408, self.player.x - 28) -- 3034
		local gap = targetX - self.partner.x -- 3035
		if math.abs(gap) > 2 then -- 3035
			local dir = gap > 0 and 1 or -1 -- 3037
			local stepDist = math.min( -- 3038
				math.abs(gap), -- 3038
				SOLDIER_SPEED * dt -- 3038
			) -- 3038
			self.partner.facing = dir -- 3039
			self.partner.vx = dir * SOLDIER_SPEED -- 3040
			local ____self_partner_96, ____x_97 = self.partner, "x" -- 3040
			____self_partner_96[____x_97] = ____self_partner_96[____x_97] + dir * stepDist -- 3041
		else -- 3041
			self.partner.vx = 0 -- 3043
			self.partner.facing = 1 -- 3044
		end -- 3044
	end -- 3044
	if self.phase == "tower-wait" then -- 3044
		local near = math.abs(self.player.x - t.doorX) <= 50 -- 3048
		if near and input.interact.pressed then -- 3048
			self.phase = "tower-knock" -- 3050
			self.phaseTick = 0 -- 3051
			self.knocks = 1 -- 3052
			self:emit("knock", {count = 1, x = self.player.x, room = "tower"}) -- 3053
			self:flashSet("叩两下 · 第一声", 0.6) -- 3054
		end -- 3054
		return -- 3056
	end -- 3056
	if self.phase == "tower-knock" then -- 3056
		self.phaseTick = self.phaseTick + 1 -- 3059
		if self.phaseTick == 12 then -- 3059
			self.knocks = 2 -- 3061
			self:emit("knock", {count = 2, x = self.player.x, room = "tower"}) -- 3062
			self:flashSet("门里回叩两下 · 守卒应门", 1.2) -- 3063
		elseif self.phaseTick >= t.knockTicks then -- 3063
			self:openTowerDoor() -- 3065
			self.phase = "tower-enter" -- 3066
			self.phaseTick = 0 -- 3067
			self:emit("storyBeat", {beat = "tower_door", x = self.player.x, item = ""}) -- 3068
			self:flashSet("门开了 · 跨过门槛", 1.4) -- 3069
		end -- 3069
		return -- 3071
	end -- 3071
	if self.phase == "tower-enter" then -- 3071
		if self.player.x >= self.ox + TOWER_THRESHOLD_X then -- 3071
			self.phase = "tower-desk" -- 3075
			self.phaseTick = 0 -- 3076
			self:emit("storyBeat", {beat = "tower_threshold", x = self.player.x, item = ""}) -- 3077
			self:flashSet("跨过门槛 · 值夜室", 1.2) -- 3078
		end -- 3078
		return -- 3080
	end -- 3080
	if self.phase == "tower-desk" then -- 3080
		local deskX = self.ox + 605 -- 3083
		local near = math.abs(self.player.x - deskX) <= 80 and self.player.y < 20 -- 3084
		if not near or not input.interact.held then -- 3084
			self.deskHold = 0 -- 3086
			return -- 3087
		end -- 3087
		self.deskHold = self.deskHold + 1 -- 3089
		if self.deskHold == 12 then -- 3089
			self:flashSet("针套 · 放在桌上", 1) -- 3091
		elseif self.deskHold == 24 then -- 3091
			self:flashSet("指南针 · 压住纸条", 1) -- 3093
		elseif self.deskHold >= TOWER_HANDOVER_TICKS then -- 3093
			self.towerHanded = true -- 3095
			self.deskHold = 0 -- 3096
			self.run.story.segments.tower_handover = true -- 3097
			self.phase = "tower-given" -- 3098
			self.phaseTick = 0 -- 3099
			self:emit("storyBeat", {beat = "tower_handover", x = self.player.x, item = "针套、指南针、纸条"}) -- 3100
			self:flashSet("三样都放在桌上 · 看登记簿", 1.6) -- 3105
		end -- 3105
		return -- 3107
	end -- 3107
	if self.phase == "tower-given" then -- 3107
		local soldier = self.storyRoute == "soldier" -- 3112
		self.phaseTick = self.phaseTick + 1 -- 3113
		if self.phaseTick == 60 then -- 3113
			self.endingLines = soldier and ({"小满", "周戍"}) or ({"小满", ""}) -- 3115
			self:flashSet("登记簿 · 第一行 小满", 1.6) -- 3116
		elseif self.phaseTick == 120 then -- 3116
			self:flashSet(soldier and "第二行 · 周戍 · 兄妹同行" or "第二行留白 · 西窗一盏灯", 2.4) -- 3118
		elseif self.phaseTick >= TOWER_REGISTER_TICKS then -- 3118
			self.phase = "tower-end" -- 3120
			self.phaseTick = 0 -- 3121
			self.towerEndMustRelease = input.interact.held or input.retry.held -- 3122
			if not self.run.finished then -- 3122
				self.run.finished = true -- 3124
				local ending = soldier and "reunion" or "lamp" -- 3125
				self.run.story.ending = ending -- 3126
				local ____soldier_98 -- 3129
				if soldier then -- 3129
					____soldier_98 = self.run.story.segments.escort5 == true -- 3130
				else -- 3130
					____soldier_98 = self.countTick >= ____exports.GATE_COUNT_END or self.run.story.countTick >= ____exports.GATE_COUNT_END -- 3131
				end -- 3131
				local played = ____soldier_98 -- 3129
				local official = self.run.source == "official" and self.run.story.settled and self.storyRoute ~= "" and played -- 3132
				if official then -- 3132
					if soldier then -- 3132
						self.run.archive.soldierCleared = true -- 3136
					else -- 3136
						self.run.archive.childCleared = true -- 3138
					end -- 3138
					self.archiveDirty = true -- 3140
				end -- 3140
				self:log(("结局 " .. ending) .. (official and " · 正式" or " · 预览")) -- 3142
				self:emit("endingReached", { -- 3143
					route = soldier and "soldier" or "child", -- 3144
					ending = ending, -- 3145
					official = official, -- 3146
					source = self.run.source, -- 3147
					lines = {self.endingLines[1], self.endingLines[2]}, -- 3148
					childCleared = self.run.archive.childCleared, -- 3149
					soldierCleared = self.run.archive.soldierCleared, -- 3150
					artifactOwned = self.run.archive.artifactOwned, -- 3151
					equipped = self.equippedWeapon -- 3152
				}) -- 3152
				self:flashSet(soldier and "北塔团圆 · 片尾" or "小满留灯 · 片尾", 3) -- 3154
			end -- 3154
		end -- 3154
		return -- 3157
	end -- 3157
	self.phaseTick = self.phaseTick + 1 -- 3159
	local held = input.interact.held or input.retry.held -- 3160
	if self.towerEndMustRelease then -- 3160
		if not held then -- 3160
			self.towerEndMustRelease = false -- 3163
		end -- 3163
		return -- 3165
	end -- 3165
	local waitTicks = math.max(0, ____exports.TOWER_CONFIRM_TICKS - TOWER_REGISTER_TICKS) -- 3167
	if self.phaseTick < waitTicks then -- 3167
		if input.interact.pressed or input.retry.pressed then -- 3167
			self.towerEndMustRelease = held -- 3170
		end -- 3170
		return -- 3172
	end -- 3172
	if input.interact.pressed or input.retry.pressed then -- 3172
		self.restartStory = true -- 3176
		self:requestRoom("prologue", "片尾再玩") -- 3177
		self:flashSet("回到序章", 1.4) -- 3178
	end -- 3178
end -- 3027
function Play.prototype.stepChase(self, dt, input) -- 3183
	if self.caughtT > 0 then -- 3183
		self.caughtT = self.caughtT - dt -- 3185
		if self.caughtT <= 0 then -- 3185
			self:recoverFromCaught() -- 3187
		end -- 3187
		return -- 3189
	end -- 3189
	if self.room.key == "village" then -- 3189
		self:stepScavChase() -- 3192
	elseif self.room.key == "forest" then -- 3192
		self:stepForestRoute() -- 3194
		self:stepDog(dt) -- 3195
		if self.player.x >= self.ox + 1450 then -- 3195
			self:requestRoom("tower", "到林缘北塔") -- 3198
			self:flashSet("林缘 · 北塔", 1.4) -- 3199
		end -- 3199
	end -- 3199
end -- 3183
function Play.prototype.stepScavChase(self) -- 3205
	local s = self.room.scavenger -- 3206
	if s == nil then -- 3206
		return -- 3208
	end -- 3208
	local p = self.player -- 3210
	if self.passed and p.x > self.ox + 440 then -- 3210
		if self.scavChase then -- 3210
			self.scavChase = false -- 3214
			self.scavState = "back" -- 3215
			self.scavT = 0 -- 3216
		end -- 3216
		return -- 3218
	end -- 3218
	local dx = p.x - self.scavX -- 3220
	local dist = math.abs(dx) -- 3221
	local hidden = p.crouch or self.room.arch.h > 0 and p.x > self.room.arch.x0 and p.x < self.room.arch.x1 -- 3222
	local visible = not hidden and dist < 240 and math.abs(p.y - s.y) < 40 -- 3223
	if not self.scavChase then -- 3223
		if visible then -- 3223
			self.scavSee = self.scavSee + 1 -- 3226
			if self.scavSee >= 24 then -- 3226
				self.scavChase = true -- 3228
				self.scavState = "chase" -- 3229
				self.scavTargetX = p.x -- 3230
				self:flashSet("他看见你了", 1.2) -- 3231
			end -- 3231
		else -- 3231
			self.scavSee = 0 -- 3234
		end -- 3234
		return -- 3236
	end -- 3236
	if hidden then -- 3236
		self.scavSee = 0 -- 3240
		self.scavT = self.scavT > 0 and self.scavT or 60 -- 3241
		self.scavT = self.scavT - 1 -- 3242
		if self.scavT <= 0 then -- 3242
			self.scavChase = false -- 3244
			self.scavState = "patrol" -- 3245
			self:flashSet("他失去了目标", 1) -- 3246
		end -- 3246
		return -- 3248
	end -- 3248
	local dir = p.x > self.scavX and 1 or -1 -- 3251
	self.scavX = self.scavX + dir * 96 / 60 -- 3252
	if math.abs(p.x - self.scavX) < 18 and math.abs(p.y - s.y) < 40 then -- 3252
		self:caught() -- 3254
		return -- 3255
	end -- 3255
end -- 3205
function Play.prototype.stepDog(self, dt) -- 3260
	local ____temp_99 -- 3261
	if self.room.story == nil then -- 3261
		____temp_99 = nil -- 3261
	else -- 3261
		____temp_99 = self.room.story.dog -- 3261
	end -- 3261
	local dog = ____temp_99 -- 3261
	if dog == nil then -- 3261
		return -- 3263
	end -- 3263
	local p = self.player -- 3265
	local ox = self.ox -- 3266
	local dist = math.abs(p.x - self.dogX) -- 3267
	local inBurrowCover = p.crouch and p.x >= ox + 300 and p.x <= ox + 460 -- 3268
	local inBrushCover = p.crouch and (p.x >= ox + 700 and p.x <= ox + 790 or p.x >= ox + 1150 and p.x <= ox + 1240) -- 3269
	local sheltered = inBurrowCover or inBrushCover -- 3273
	local inDitchSprint = not p.crouch and self.forestPath == "ditch" and p.x >= ox + 700 and p.x <= ox + 1140 -- 3274
	local effectiveRange = inDitchSprint and dog.range * 1.25 or dog.range -- 3275
	local earNeedTicks = inDitchSprint and 12 or 18 -- 3276
	if self.dogState == "patrol" then -- 3276
		self.dogX = self.dogX + self.dogDir * dog.speed * dt -- 3278
		if self.dogX < dog.x0 then -- 3278
			self.dogX = dog.x0 -- 3280
			self.dogDir = 1 -- 3281
		elseif self.dogX > dog.x1 then -- 3281
			self.dogX = dog.x1 -- 3283
			self.dogDir = -1 -- 3284
		end -- 3284
		local moving = math.abs(p.vx) > 1 or not p.onGround -- 3286
		local twigOffsets = {235, 455, 865, 1115} -- 3287
		local nearTwig = false -- 3288
		local ti = 0 -- 3289
		do -- 3289
			ti = 0 -- 3290
			while ti < #twigOffsets do -- 3290
				if math.abs(p.x - (ox + twigOffsets[ti + 1])) <= 18 and p.y <= 8 then -- 3290
					nearTwig = true -- 3292
					break -- 3293
				end -- 3293
				ti = ti + 1 -- 3290
			end -- 3290
		end -- 3290
		local twigRange = nearTwig and math.max(effectiveRange, 400) or effectiveRange -- 3296
		if not sheltered and not p.crouch and moving and dist < twigRange then -- 3296
			self.dogState = "ear" -- 3298
			self.dogT = nearTwig and math.min(earNeedTicks, 12) or earNeedTicks -- 3299
			self.dogTargetX = p.x -- 3300
			self:flashSet(inDitchSprint and "旧渠枯枝响 · 狗立刻转耳" or (nearTwig and "踩断枯枝 · 狗立刻转耳" or "狗转耳朵"), 0.8) -- 3301
		end -- 3301
		return -- 3303
	end -- 3303
	if self.dogState == "ear" then -- 3303
		if sheltered then -- 3303
			self.dogState = "sniff" -- 3307
			self.dogT = 45 -- 3308
			self:flashSet("钻进遮蔽 · 狗顿住了", 0.9) -- 3309
			return -- 3310
		end -- 3310
		self.dogT = self.dogT - 1 -- 3312
		if self.dogT <= 0 then -- 3312
			self.dogState = "chase" -- 3314
			self.dogTargetX = p.x -- 3315
			self:flashSet("狗追来了", 1.4) -- 3316
		end -- 3316
		return -- 3318
	end -- 3318
	if self.dogState == "chase" then -- 3318
		local dir = p.x > self.dogX and 1 or -1 -- 3321
		self.dogX = self.dogX + dir * dog.speed * 1.4 * dt -- 3322
		if not sheltered and math.abs(p.x - self.dogX) < 18 and math.abs(p.y) < 40 then -- 3322
			self:caught() -- 3324
			self.dogState = "sniff" -- 3325
			self.dogT = 60 -- 3326
		elseif dist > effectiveRange * 1.5 or sheltered then -- 3326
			self.dogState = "sniff" -- 3328
			self.dogT = 60 -- 3329
			self:flashSet(inBurrowCover and "树根窄洞遮住身形 · 狗停下了" or "狗停下了", 0.9) -- 3330
		end -- 3330
		return -- 3332
	end -- 3332
	if self.dogState == "sniff" then -- 3332
		self.dogT = self.dogT - 1 -- 3335
		if self.dogT <= 0 then -- 3335
			self.dogState = "back" -- 3337
		end -- 3337
		return -- 3339
	end -- 3339
	local dir = dog.x0 > self.dogX and 1 or -1 -- 3342
	self.dogX = self.dogX + dir * dog.speed * dt -- 3343
	if math.abs(self.dogX - dog.x0) < 2 then -- 3343
		self.dogX = dog.x0 -- 3345
		self.dogState = "patrol" -- 3346
	end -- 3346
end -- 3260
function Play.prototype.stepForestRoute(self) -- 3351
	local p = self.player -- 3352
	local ox = self.ox -- 3353
	if self.forestPath == "" then -- 3353
		if p.crouch and p.x >= ox + 300 and p.x <= ox + 380 then -- 3353
			self.forestPath = "burrow" -- 3356
			self.run.story.segments.forest_burrow = true -- 3357
			self:flashSet("树根窄洞 · 蹲着钻过去", 1.5) -- 3358
			self:emit("storyBeat", {beat = "path_burrow", x = p.x, room = "forest"}) -- 3359
		elseif not p.crouch and p.x >= ox + 700 and p.x <= ox + 790 then -- 3359
			self.forestPath = "ditch" -- 3361
			self.run.story.segments.forest_ditch = true -- 3362
			self:flashSet("旧渠 · 顺着渠底跑", 1.5) -- 3363
			self:emit("storyBeat", {beat = "path_ditch", x = p.x, room = "forest"}) -- 3364
		end -- 3364
	end -- 3364
	if not self.waterSeen and p.x >= ox + 1180 and p.x <= ox + 1260 then -- 3364
		self.waterSeen = true -- 3368
		self.run.story.segments.water_lantern = true -- 3369
		self:flashSet("溪湾 · 水里那盏灯，和塔上一个方向", 1.8) -- 3370
		self:emit("storyBeat", {beat = "water_lantern", x = p.x, room = "forest"}) -- 3371
	end -- 3371
end -- 3351
function Play.prototype.caught(self) -- 3375
	self.caughtT = 1 -- 3376
	self:flashSet("被抓 · 回到安全点", 1.6) -- 3377
end -- 3375
function Play.prototype.recoverFromCaught(self) -- 3381
	local p = self.player -- 3382
	p.x = self.ox + 140 -- 3383
	p.y = 0 -- 3384
	p.vy = 0 -- 3385
	p.vx = 0 -- 3386
	p.onGround = true -- 3387
	if self.room.key == "village" and self.room.scavenger ~= nil then -- 3387
		self.scavX = self.room.scavenger.x0 -- 3389
		self.scavState = "patrol" -- 3390
		self.scavSee = 0 -- 3391
		self.scavChase = false -- 3392
		self.scavT = 0 -- 3393
	end -- 3393
	if self.room.key == "forest" and self.room.story ~= nil and self.room.story.dog ~= nil then -- 3393
		self.dogX = self.room.story.dog.x0 -- 3396
		self.dogState = "patrol" -- 3397
		self.dogT = 0 -- 3398
	end -- 3398
	self.cam.x = p.x -- 3400
	self.cam.y = p.y + CAM_LOOK_UP -- 3401
	self:flashSet("回到安全点", 1.2) -- 3402
end -- 3381
function Play.prototype.updateGate(self) -- 3406
	if self.room.key ~= "checkpoint" then -- 3406
		self.gateOpen = false -- 3408
		return -- 3409
	end -- 3409
	local function inZone(x) -- 3411
		return x >= self.ox + 792 and x <= self.ox + 928 -- 3411
	end -- 3411
	self.gateOpen = self.cartDocked and inZone(self.player.x) and inZone(self.partner.x) -- 3412
end -- 3406
function Play.prototype.addItem(self, kind) -- 3418
	local inv = self.run.inventory -- 3419
	if kind == "shield" then -- 3419
		if inv.shield >= TOOL_CAP then -- 3419
			return false -- 3422
		end -- 3422
		inv.shield = inv.shield + 1 -- 3424
		return true -- 3425
	end -- 3425
	if kind == "wedge" then -- 3425
		if inv.wedge >= CONSUMABLE_CAP then -- 3425
			return false -- 3429
		end -- 3429
		inv.wedge = inv.wedge + 1 -- 3431
		return true -- 3432
	end -- 3432
	if kind == "ammo" then -- 3432
		if inv.ammo >= CONSUMABLE_CAP then -- 3432
			return false -- 3436
		end -- 3436
		inv.ammo = inv.ammo + 1 -- 3438
		return true -- 3439
	end -- 3439
	if kind == "scrap" then -- 3439
		inv.scrap = inv.scrap + 1 -- 3443
		return true -- 3444
	end -- 3444
	if kind == "wood" then -- 3444
		inv.wood = inv.wood + 1 -- 3447
		return true -- 3448
	end -- 3448
	if kind == "bell" then -- 3448
		inv.bell = inv.bell + 1 -- 3451
		return true -- 3452
	end -- 3452
	if kind == "pass" then -- 3452
		inv.pass = inv.pass + 1 -- 3455
		return true -- 3456
	end -- 3456
	if kind == "quickbelt" then -- 3456
		inv.quickbelt = inv.quickbelt + 1 -- 3459
		return true -- 3460
	end -- 3460
	return false -- 3462
end -- 3418
function Play.prototype.findBox(self, id) -- 3465
	local i = 0 -- 3466
	do -- 3466
		i = 0 -- 3467
		while i < #self.boxes do -- 3467
			if self.boxes[i + 1].id == id then -- 3467
				return self.boxes[i + 1] -- 3469
			end -- 3469
			i = i + 1 -- 3467
		end -- 3467
	end -- 3467
	return nil -- 3472
end -- 3465
function Play.prototype.findWedgeTarget(self) -- 3476
	local best = nil -- 3477
	local bestD = 0 -- 3478
	local i = 0 -- 3479
	do -- 3479
		i = 0 -- 3480
		while i < #self.boxes do -- 3480
			do -- 3480
				local b = self.boxes[i + 1] -- 3481
				if b.breakable == nil or b.broken == true or b.breakable.wedgeable == false then -- 3481
					goto __continue529 -- 3483
				end -- 3483
				if not self:nearBox(b, 26) then -- 3483
					goto __continue529 -- 3486
				end -- 3486
				local d = math.abs(b.x0 - self.player.x) + math.abs(b.x1 - self.player.x) -- 3488
				if best == nil or d < bestD then -- 3488
					best = b -- 3490
					bestD = d -- 3491
				end -- 3491
			end -- 3491
			::__continue529:: -- 3491
			i = i + 1 -- 3480
		end -- 3480
	end -- 3480
	return best -- 3494
end -- 3476
function Play.prototype.stepCraft(self, input) -- 3502
	local inv = self.run.inventory -- 3503
	local required = math.max( -- 3504
		6, -- 3504
		CRAFT_TICKS - 6 * self:talentRank("salvage") -- 3504
	) -- 3504
	if self.craftT > 0 then -- 3504
		if not input.interact.held or self.gripping or self.player.rollT > 0 or self.escort.state == "calming" or self.paused then -- 3504
			self.craftT = 0 -- 3508
			self:flashSet("制作中断", 0.8) -- 3509
			return true -- 3510
		end -- 3510
		self.craftT = self.craftT + 1 -- 3512
		if self.craftT >= required then -- 3512
			if inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP then -- 3512
				inv.scrap = inv.scrap - 1 -- 3515
				inv.wedge = inv.wedge + 1 -- 3516
				self:flashSet("制得木楔", 1.2) -- 3517
				self:log("制木楔") -- 3518
				self:emit("craftDone", {item = "wedge", ticks = required}) -- 3519
			end -- 3519
			self.craftT = 0 -- 3521
		end -- 3521
		return true -- 3523
	end -- 3523
	if input.interact.pressed and inv.scrap > 0 and inv.wedge < CONSUMABLE_CAP and self:findInteract() == nil then -- 3523
		self.craftT = 1 -- 3526
		self:flashSet("握住废木料 · 按住 E 削木楔", 1) -- 3527
		self:emit("craftStart", {item = "wedge", ticks = required}) -- 3528
		return true -- 3529
	end -- 3529
	return false -- 3531
end -- 3502
function Play.prototype.nearBox(self, b, reach) -- 3534
	local p = self.player -- 3535
	return p.x + p.w / 2 >= b.x0 - reach and p.x - p.w / 2 <= b.x1 + reach and p.y <= b.y1 + 12 and p.y + p.h >= b.y0 - 12 and overlapsDepth(p.depth, b.depth, INTERACT_DEPTH_REACH) -- 3536
end -- 3534
function Play.prototype.findInteract(self) -- 3542
	local p = self.player -- 3543
	local best = nil -- 3544
	local bestD = 1000000000 -- 3545
	local i = 0 -- 3546
	do -- 3546
		i = 0 -- 3547
		while i < #self.boxes do -- 3547
			do -- 3547
				local b = self.boxes[i + 1] -- 3548
				if b.interact == nil or b.broken == true then -- 3548
					goto __continue542 -- 3550
				end -- 3550
				if not self:nearBox(b, b.interact.reach or 27) then -- 3550
					goto __continue542 -- 3553
				end -- 3553
				local d = math.abs(p.x - (b.x0 + b.x1) / 2) -- 3555
				if d < bestD then -- 3555
					bestD = d -- 3557
					best = b -- 3558
				end -- 3558
			end -- 3558
			::__continue542:: -- 3558
			i = i + 1 -- 3547
		end -- 3547
	end -- 3547
	return best -- 3561
end -- 3542
function Play.prototype.stepCampaign(self, dt, input) -- 3565
	local wr = self.room -- 3566
	local p = self.player -- 3567
	if self.reloadT > 0 then -- 3567
		self.reloadT = self.reloadT - 1 -- 3569
	end -- 3569
	if self.bracedShield ~= nil then -- 3569
		self.bracedShield.x = p.x + p.facing * 26 -- 3573
		self.bracedShield.y = p.y -- 3574
		local shBox = __TS__ArrayFind( -- 3575
			self.boxes, -- 3575
			function(____, b) return b.id == "braced_shield" end -- 3575
		) -- 3575
		if shBox ~= nil then -- 3575
			shBox.x0 = self.bracedShield.x - 15 -- 3577
			shBox.x1 = self.bracedShield.x + 15 -- 3578
			shBox.y0 = self.bracedShield.y -- 3579
			shBox.y1 = self.bracedShield.y + self.bracedShield.h -- 3580
		end -- 3580
	end -- 3580
	if wr.key == "s2-drygoods" and self.run.route ~= "drygoods" and p.x < wr.minX + 330 and p.depth <= -16 then -- 3580
		self.run.route = "drygoods" -- 3586
		self.run.joined = false -- 3587
		self:flashSet("转布行线 · 小满到窗板后等", 1.3) -- 3588
		self:log("转布行线") -- 3589
	end -- 3589
	if wr.key == "escort3" then -- 3589
		local nearBench = p.x >= wr.minX + 472 and p.x <= wr.minX + 710 and p.y < 60 -- 3594
		if nearBench and input.interact.pressed then -- 3594
			self:openCraftBench() -- 3596
			return -- 3597
		end -- 3597
		local ____temp_102 = self.storyRoute == "soldier" -- 3599
		if ____temp_102 then -- 3599
			local ____opt_100 = self.run.story.talents -- 3599
			____temp_102 = (____opt_100 and ____opt_100.deferred) == true -- 3599
		end -- 3599
		if ____temp_102 and p.x >= wr.minX + 940 then -- 3599
			self:triggerDeferredEscort3Draft() -- 3600
		end -- 3600
	end -- 3600
	local i = 0 -- 3604
	do -- 3604
		i = 0 -- 3605
		while i < #self.pickups do -- 3605
			do -- 3605
				local pk = self.pickups[i + 1] -- 3606
				if self.run.taken[pk.id] == true then -- 3606
					goto __continue556 -- 3608
				end -- 3608
				local sameDepth = overlapsDepth(p.depth, {min = (pk.depth or 0) - 10, max = (pk.depth or 0) + 10}, 10) -- 3610
				local dy = math.abs(pk.y + (pk.depth or 0) - (p.y + p.depth)) -- 3611
				if math.abs(pk.x - p.x) < 44 and dy < 60 and sameDepth then -- 3611
					if not self:addItem(pk.kind) then -- 3611
						self:flashSet(("背包满了 · " .. pk.label) .. " 留在原地", 1) -- 3615
						self:log("满包拒绝 " .. pk.kind) -- 3616
						self:emit("pickupRejected", {kind = pk.kind, x = pk.x, y = pk.y}) -- 3617
						goto __continue556 -- 3618
					end -- 3618
					self.run.taken[pk.id] = true -- 3620
					self:flashSet("拾取 " .. pk.label, 1) -- 3621
					self:log((("拾取 " .. pk.kind) .. " ") .. pk.label) -- 3622
					self:emit("pickup", {kind = pk.kind, x = pk.x, y = pk.y, label = pk.label}) -- 3623
				end -- 3623
			end -- 3623
			::__continue556:: -- 3623
			i = i + 1 -- 3605
		end -- 3605
	end -- 3605
	self.calmConsumed = false -- 3627
	local ____temp_108 = self.partner.alive and self.run.joined -- 3628
	if ____temp_108 then -- 3628
		local ____opt_103 = self.room.campaign -- 3628
		local ____temp_107 = (____opt_103 and ____opt_103.chapter) == "S" -- 3629
		if not ____temp_107 then -- 3629
			local ____opt_105 = self.room.campaign -- 3629
			____temp_107 = (____opt_105 and ____opt_105.chapter) == "C" -- 3629
		end -- 3629
		____temp_108 = ____temp_107 -- 3628
	end -- 3628
	if ____temp_108 and (self.escort.fear > 0 or self.escort.state == "frozen" or self.escort.state == "calming") then -- 3628
		local dist = inReachDepth(p.depth, self.partner.depth) and math.abs(p.x - self.partner.x) or 1000000000 -- 3631
		local hadK1 = self.escort.knock1 -- 3632
		local hadK2 = self.escort.knock2 -- 3633
		self.calmConsumed = self.escort:update( -- 3634
			input, -- 3634
			p.x, -- 3634
			p.facing, -- 3634
			self.partner.x, -- 3634
			dist -- 3634
		) -- 3634
		if not hadK1 and self.escort.knock1 then -- 3634
			self:emit("knock", {count = 1, x = self.partner.x, room = self.room.key}) -- 3636
		end -- 3636
		if not hadK2 and self.escort.knock2 then -- 3636
			self:emit("knock", {count = 2, x = self.partner.x, room = self.room.key}) -- 3639
		end -- 3639
		self.partner.crouch = self.escort.crouchPose -- 3641
		self.partner.h = self.partner.crouch and CHILD_CROUCH_H or CHILD_H -- 3642
	end -- 3642
	if not self.calmConsumed and not self:stepCraft(input) and input.interact.pressed then -- 3642
		self:campaignInteract() -- 3645
	end -- 3645
	self:stepCampaignCart(dt, input) -- 3647
	self:stepCampaignGoal() -- 3648
	self:campaignCheckpoint() -- 3649
end -- 3565
function Play.prototype.campaignCheckpoint(self) -- 3653
	local i = 0 -- 3654
	do -- 3654
		i = 0 -- 3655
		while i < #self.room.marks do -- 3655
			do -- 3655
				local m = self.room.marks[i + 1] -- 3656
				if m.kind ~= 0 then -- 3656
					goto __continue566 -- 3658
				end -- 3658
				local dx = self.player.x - m.x -- 3660
				local dy = self.player.y - m.y -- 3661
				if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 3661
					self.checkpoint = m.x -- 3663
					self:captureCheckpoint(m.x) -- 3664
					self:flashSet("检查点", 1) -- 3665
				end -- 3665
			end -- 3665
			::__continue566:: -- 3665
			i = i + 1 -- 3655
		end -- 3655
	end -- 3655
end -- 3653
function Play.prototype.campaignInteract(self) -- 3671
	local b = self:findInteract() -- 3672
	if b ~= nil then -- 3672
		self:useInteract(b) -- 3674
		return -- 3675
	end -- 3675
	local inv = self.run.inventory -- 3677
	if inv.wedge > 0 then -- 3677
		local w = self:findWedgeTarget() -- 3679
		if w ~= nil then -- 3679
			local ____opt_109 = w.breakable -- 3679
			local extraHp = (____opt_109 and ____opt_109.wedgeHp or 1) + self:talentRank("salvage") -- 3681
			if w.breakable ~= nil then -- 3681
				local ____w_breakable_111, ____hp_112 = w.breakable, "hp" -- 3681
				____w_breakable_111[____hp_112] = ____w_breakable_111[____hp_112] + extraHp -- 3683
			end -- 3683
			inv.wedge = inv.wedge - 1 -- 3685
			self.run.props[w.id == nil and "wedge" or w.id] = {broken = w.broken == true, hp = w.breakable == nil and 0 or w.breakable.hp, wedge = true} -- 3686
			self:flashSet( -- 3688
				extraHp > 1 and ("钉木楔 · 多承" .. tostring(extraHp)) .. "次" or "钉木楔 · 多承一次", -- 3688
				1.2 -- 3688
			) -- 3688
			self:log("加固 " .. (w.label == nil and "木件" or w.label)) -- 3689
			self:emit("interactUsed", {kind = "wedge", x = w.x0}) -- 3690
			return -- 3691
		end -- 3691
		if self:isEscortRoom() then -- 3691
			local p = self.player -- 3694
			local wx = math.max( -- 3695
				self.room.minX + 64, -- 3695
				math.min(self.room.maxX - 64, p.x + p.facing * 32) -- 3695
			) -- 3695
			local hp = 1 + self:talentRank("salvage") -- 3696
			self.fieldWedgeSeq = self.fieldWedgeSeq + 1 -- 3697
			local wid = "field_wedge_" .. tostring(self.fieldWedgeSeq) -- 3698
			local ____self_boxes_113 = self.boxes -- 3698
			____self_boxes_113[#____self_boxes_113 + 1] = { -- 3699
				x0 = wx - 12, -- 3700
				x1 = wx + 12, -- 3701
				y0 = p.y, -- 3702
				y1 = p.y + 48, -- 3703
				depth = {min = p.depth - 20, max = p.depth + 20}, -- 3704
				label = "立起的木楔掩体", -- 3705
				id = wid, -- 3706
				breakable = {hp = hp, kind = "thin_wood", wedgeable = true} -- 3707
			} -- 3707
			inv.wedge = inv.wedge - 1 -- 3709
			self:flashSet( -- 3710
				"立木楔 · 临时挡弹" .. (hp > 1 and ("(" .. tostring(hp)) .. "击)" or ""), -- 3710
				1.2 -- 3710
			) -- 3710
			self:log("立木楔掩体") -- 3711
			self:emit("interactUsed", {kind = "wedge", x = wx}) -- 3712
			return -- 3713
		end -- 3713
	end -- 3713
	if inv.ammo > 0 and self.reloadT > 0 then -- 3713
		self.reloadT = 0 -- 3718
		self:closeReloadPuzzle() -- 3719
		inv.ammo = inv.ammo - 1 -- 3720
		self:flashSet("备用弹包 · 膛内补满", 1) -- 3721
		self:log("用备用弹包") -- 3722
		self:emit("interactUsed", {kind = "ammo", x = self.player.x}) -- 3723
		return -- 3724
	end -- 3724
	local canBraceHere = self.room.key == "c2-granary" and self.player.x >= self.room.minX + 960 and self.player.x <= self.room.minX + 1320 or self:isEscortRoom() -- 3726
	if inv.shield > 0 and self.bracedShield == nil and canBraceHere then -- 3726
		local p = self.player -- 3730
		local shHp = 1 + self:talentRank("salvage") -- 3731
		self.bracedShield = { -- 3732
			x = p.x + p.facing * 26, -- 3732
			y = p.y, -- 3732
			w = 30, -- 3732
			h = 64, -- 3732
			hp = shHp -- 3732
		} -- 3732
		local ____self_boxes_114 = self.boxes -- 3732
		____self_boxes_114[#____self_boxes_114 + 1] = { -- 3733
			x0 = self.bracedShield.x - 15, -- 3734
			x1 = self.bracedShield.x + 15, -- 3734
			y0 = p.y, -- 3735
			y1 = p.y + 64, -- 3735
			depth = {min = -46, max = 46}, -- 3735
			label = "架起的残盾", -- 3735
			id = "braced_shield", -- 3735
			soft = true -- 3736
		} -- 3736
		inv.shield = inv.shield - 1 -- 3738
		self:flashSet( -- 3739
			shHp > 1 and ("架残盾 · 可挡" .. tostring(shHp)) .. "发" or "架残盾 · 挡一发", -- 3739
			1.2 -- 3739
		) -- 3739
		self:log("架残盾") -- 3740
		self:emit("interactUsed", {kind = "shield", x = p.x}) -- 3741
		return -- 3742
	end -- 3742
	if inv.pass > 0 and self.run.joined == false then -- 3742
		inv.pass = inv.pass - 1 -- 3745
		self.run.joined = true -- 3746
		self:flashSet("护送号牌 · 小满跟上", 1.2) -- 3747
		self:emit("interactUsed", {kind = "pass", x = self.player.x}) -- 3748
		return -- 3749
	end -- 3749
	self:flashSet(self.hint == "" and "这里没有可用的机关" or self.hint, 0.8) -- 3751
end -- 3671
function Play.prototype.useInteract(self, b) -- 3754
	local kind = b.interact == nil and "" or b.interact.kind -- 3755
	local wr = self.room -- 3756
	if kind == "open_board" then -- 3756
		b.broken = true -- 3758
		self.run.props.s2_board = {broken = true, hp = 0, wedge = false} -- 3759
		for ____, cover in ipairs(self.boxes) do -- 3760
			if cover.id == "s2_board_cover" then -- 3760
				cover.broken = false -- 3762
				cover.hidden = false -- 3763
			end -- 3763
		end -- 3763
		self.run.props.s2_board_cover = {broken = false, hp = 0, wedge = false, revealed = true} -- 3766
		self.run.joined = true -- 3767
		self:flashSet("放下窗板 · 小满跟上", 1.4) -- 3768
		self:log("放下窗板") -- 3769
		self:emit("interactUsed", {kind = "open_board", x = b.x0}) -- 3770
		return -- 3771
	end -- 3771
	if kind == "lower_curtain" then -- 3771
		for ____, curtain in ipairs(self.boxes) do -- 3774
			if curtain.id == "c2_curtain" then -- 3774
				curtain.broken = false -- 3776
				curtain.hidden = false -- 3777
			end -- 3777
		end -- 3777
		self.run.props.c2_curtain = {broken = false, hp = 0, wedge = false, revealed = true} -- 3780
		self:flashSet("放下木帘 · 暴露轨段有遮挡", 1.4) -- 3781
		self:log("放下木帘") -- 3782
		self:emit("interactUsed", {kind = "lower_curtain", x = b.x0}) -- 3783
		return -- 3784
	end -- 3784
	if kind == "raise_latch" then -- 3784
		if wr.key == "c2-granary" and not self.cartDocked then -- 3784
			self:flashSet("车轮还没入窝 · 先把车推到底", 1) -- 3788
			return -- 3789
		end -- 3789
		b.broken = true -- 3791
		self.objectiveDone = true -- 3792
		if wr.key == "c1-yard" then -- 3792
			self.run.c1Latch = true -- 3795
			self.run.joined = true -- 3796
			for ____, door in ipairs(self.boxes) do -- 3797
				if door.id == "c1_door" then -- 3797
					door.broken = true -- 3799
				end -- 3799
			end -- 3799
			self.run.props.c1_door = {broken = true, hp = 0, wedge = false} -- 3802
		else -- 3802
			self.run.c2Latch = true -- 3804
			self.run.joined = true -- 3805
		end -- 3805
		self.run.props[b.id or "latch"] = {broken = true, hp = 0, wedge = false} -- 3807
		self:emit("objectiveDone", {goal = "raise_latch", room = wr.key}) -- 3808
		self:log("抬闩") -- 3809
		self:flashSet("抬闩 · 通路打开", 1.4) -- 3810
		self:emit("interactUsed", {kind = "raise_latch", x = b.x0}) -- 3811
	end -- 3811
end -- 3754
function Play.prototype.stepCampaignCart(self, dt, input) -- 3816
	local wr = self.room -- 3817
	local c = wr.cart -- 3818
	if c.bodyW <= 0 then -- 3818
		return -- 3820
	end -- 3820
	local p = self.player -- 3822
	local handleX = self.cartAxle + c.handleOffset -- 3823
	if not self.gripping then -- 3823
		if input.interact.pressed and not self.cartDocked and math.abs(p.x - handleX) <= ____exports.CART_REACH and math.abs(p.y - c.baseY) <= 40 and inReachDepth(p.depth, c.depth or 0) and not self.objectiveDone then -- 3823
			self.gripping = true -- 3827
			self:flashSet("握住车柄 · A/D 推", 1) -- 3828
		end -- 3828
		return -- 3830
	end -- 3830
	if input.interact.pressed then -- 3830
		self.gripping = false -- 3833
		self:flashSet("松手", 0.5) -- 3834
		return -- 3835
	end -- 3835
	if not self.cartDocked then -- 3835
		if input.moveX ~= 0 and not self:stuckCart() then -- 3835
			self.cartAxle = math.max( -- 3839
				c.startX, -- 3839
				math.min(c.endX, self.cartAxle + input.moveX * CART_SPEED * dt) -- 3839
			) -- 3839
		end -- 3839
		if not self.cartExposed and self.cartAxle >= wr.minX + 1240 and self.cartAxle <= wr.minX + 1360 then -- 3839
			self.cartExposed = true -- 3844
			local gun = nil -- 3845
			local gi = 0 -- 3846
			do -- 3846
				gi = 0 -- 3847
				while gi < #self.enemies do -- 3847
					local e = self.enemies[gi + 1] -- 3848
					if e.alive and e.kind == "gunner" and math.abs((e.depth or 0) - p.depth) <= 44 then -- 3848
						gun = e -- 3850
						break -- 3851
					end -- 3851
					gi = gi + 1 -- 3847
				end -- 3847
			end -- 3847
			if gun ~= nil then -- 3847
				self:campaignEnemyFire(gun) -- 3855
			end -- 3855
		end -- 3855
		p.x = self.cartAxle + c.handleOffset -- 3858
		p.y = c.baseY -- 3859
		p.depth = c.depth or 0 -- 3860
		p.vx = 0 -- 3861
		if math.abs(self.cartAxle - c.endX) < 0.5 then -- 3861
			self.cartAxle = c.endX -- 3863
			self.cartDocked = true -- 3864
			self.gripping = false -- 3865
			self.run.props.c2_cart = {broken = true, hp = 0, wedge = false} -- 3866
			self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = wr.key}) -- 3867
			self:flashSet("车轮入窝", 1.2) -- 3868
			self:log("车轮入窝") -- 3869
		end -- 3869
	end -- 3869
end -- 3816
function Play.prototype.stuckCart(self) -- 3875
	local i = 0 -- 3876
	do -- 3876
		i = 0 -- 3877
		while i < #self.boxes do -- 3877
			do -- 3877
				local b = self.boxes[i + 1] -- 3878
				if b.broken == true or b.breakable == nil or b.soft == true then -- 3878
					goto __continue609 -- 3880
				end -- 3880
				local front = self.cartAxle + self.room.cart.bodyW / 2 -- 3882
				if b.y0 < 40 and b.x0 < front + 10 and b.x1 > front - 10 then -- 3882
					return true -- 3884
				end -- 3884
			end -- 3884
			::__continue609:: -- 3884
			i = i + 1 -- 3877
		end -- 3877
	end -- 3877
	return false -- 3887
end -- 3875
function Play.prototype.stepCampaignGoal(self) -- 3891
	local wr = self.room -- 3892
	local c = wr.campaign -- 3893
	if c == nil then -- 3893
		return -- 3895
	end -- 3895
	if wr.key == "c2-granary" and self.cartDocked and self.run.c2Latch == true then -- 3895
		self.objectiveDone = true -- 3898
	end -- 3898
	if c.goal == "reach_exit" then -- 3898
		self.objectiveDone = true -- 3901
	end -- 3901
	if not self.objectiveDone then -- 3901
		return -- 3904
	end -- 3904
	local p = self.player -- 3906
	local partnerOk = self.run.joined and self.partner.x >= c.exitX - 220 -- 3907
	if p.x < c.exitX or not partnerOk then -- 3907
		return -- 3909
	end -- 3909
	if self.run.story.segments[wr.key] ~= true then -- 3909
		self.run.story.segments[wr.key] = true -- 3913
		self:emit("segmentDone", {room = wr.key, act = c.act, next = c.next or "", ticks = self.ticks}) -- 3914
	end -- 3914
	if wr.key == "escort5" then -- 3914
		self.escortDone = true -- 3918
		self.run.story.escortDone = true -- 3919
	end -- 3919
	if c.next ~= nil and c.next ~= "" then -- 3919
		self:requestRoom(c.next, "段出口 " .. wr.key) -- 3922
		self:flashSet("过关 · " .. c.next, 1.2) -- 3923
	elseif wr.key == "c2-granary" and (self.run.source == "official" or self.run.source == "chapter") then -- 3923
		self:requestRoom("gate", "军粮棚出口") -- 3926
		self:flashSet("出军粮棚 · 城门", 1.4) -- 3927
	elseif not self.run.finished then -- 3927
		self.run.finished = true -- 3929
		self:flashSet( -- 3930
			"军粮棚清完 · 回城门 · " .. mmss(self.run.roomTicks[wr.key] or 0), -- 3930
			2 -- 3930
		) -- 3930
		self:log("军粮棚清完 · 回城门") -- 3931
		self:emit("objectiveDone", {goal = "dock_cart", room = wr.key}) -- 3932
	end -- 3932
end -- 3891
function Play.prototype.stepCampaignPartner(self, dt) -- 3937
	local a = self.partner -- 3938
	local wr = self.room -- 3939
	local cp = wr.companion -- 3940
	if not a.alive then -- 3940
		return -- 3942
	end -- 3942
	local p = self.player -- 3944
	if self.craftBench.active then -- 3944
		a.vx = 0 -- 3947
		return -- 3948
	end -- 3948
	local wait = false -- 3950
	local targetX = cp == nil and p.x - 70 or p.x - (p.facing > 0 and 70 or -70) -- 3951
	local targetDepth = p.depth -- 3952
	if self.run.joined == false then -- 3952
		wait = true -- 3954
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3955
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3956
	elseif wr.key == "c1-yard" and not self.run.c1Latch then -- 3956
		wait = true -- 3958
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3959
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3960
	elseif wr.key == "c2-granary" and not self.cartDocked then -- 3960
		wait = true -- 3962
		targetX = cp == nil and a.x or (cp.waitX or a.x) -- 3963
		targetDepth = cp == nil and a.depth or (cp.waitDepth or 0) -- 3964
	end -- 3964
	if self.partnerStuck > 0.3 then -- 3964
		a.x = a.x + a.facing * 44 -- 3968
		self.partnerLaneIdx = (self.partnerLaneIdx + 1) % 3 -- 3969
		a.depth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3970
		self.partnerLaneHold = 1.1 -- 3971
		self.partnerStuck = 0 -- 3972
	end -- 3972
	if self.partnerLaneHold > 0 then -- 3972
		self.partnerLaneHold = self.partnerLaneHold - dt -- 3975
		targetDepth = self.partnerLaneIdx == 0 and 0 or (self.partnerLaneIdx == 1 and 32 or -32) -- 3976
	end -- 3976
	local dx = targetX - a.x -- 3978
	local stopTol = wait and 18 or 74 -- 3979
	if math.abs(dx) > stopTol then -- 3979
		local speed = math.abs(dx) > 260 and CHILD_SPEED * 1.4 or CHILD_SPEED -- 3981
		local before = a.x -- 3982
		a.vx = dx > 0 and speed or -speed -- 3983
		a.facing = dx > 0 and 1 or -1 -- 3984
		self:slideX(a, a.vx * dt) -- 3985
		if a.onGround and math.abs(a.x - before) < 0.5 then -- 3985
			a.vy = CHILD_JUMP -- 3988
			a.onGround = false -- 3989
		end -- 3989
		self.partnerStuck = math.abs(a.x - before) < 0.5 and self.partnerStuck + dt or 0 -- 3991
	else -- 3991
		a.vx = 0 -- 3993
		self.partnerStuck = 0 -- 3994
	end -- 3994
	local dz = targetDepth - a.depth -- 3996
	if math.abs(dz) > 6 then -- 3996
		local step = math.max( -- 3998
			-CHILD_SPEED * DEPTH_SPEED_RATIO * dt, -- 3998
			math.min(CHILD_SPEED * DEPTH_SPEED_RATIO * dt, dz) -- 3998
		) -- 3998
		a.depth = a.depth + step -- 3999
	end -- 3999
	a.depthSpeed = 0 -- 4001
	a.h = CHILD_H -- 4002
	a.crouch = false -- 4003
	self:fallY(a, dt) -- 4004
end -- 3937
function Play.prototype.stepCampaignEnemies(self, dt, input) -- 4008
	local p = self.player -- 4009
	local i = 0 -- 4010
	do -- 4010
		i = 0 -- 4011
		while i < #self.enemies and not self.escortFailed do -- 4011
			do -- 4011
				local e = self.enemies[i + 1] -- 4012
				if e.kind == "target" then -- 4012
					if not e.alive then -- 4012
						if e.hitT > 0 then -- 4012
							e.hitT = e.hitT - dt -- 4017
						end -- 4017
						if e.hitT <= 0 then -- 4017
							e.alive = true -- 4020
							e.hitT = 0 -- 4021
						end -- 4021
					end -- 4021
					goto __continue637 -- 4024
				end -- 4024
				if not e.alive then -- 4024
					goto __continue637 -- 4027
				end -- 4027
				if e.kind == "breaker" then -- 4027
					self:stepBreaker(e, dt) -- 4030
					goto __continue637 -- 4031
				end -- 4031
				if e.kind == "shield" then -- 4031
					self:stepShield(e, dt, input) -- 4034
					goto __continue637 -- 4035
				end -- 4035
				local dx = e.x - p.x -- 4038
				if not e.awake then -- 4038
					if math.abs(dx) > 520 then -- 4038
						goto __continue637 -- 4041
					end -- 4041
					e.awake = true -- 4043
					e.fireCd = 48 -- 4044
					goto __continue637 -- 4045
				end -- 4045
				if math.abs(dx) > ENEMY_RANGE then -- 4045
					goto __continue637 -- 4048
				end -- 4048
				if self.room.key == "c2-granary" and p.x > self.room.minX + 1450 then -- 4048
					goto __continue637 -- 4053
				end -- 4053
				if math.abs((e.depth or 0) - p.depth) > 44 then -- 4053
					goto __continue637 -- 4056
				end -- 4056
				if self:blockedShot(e, p) then -- 4056
					if e.warnT > 0 then -- 4056
						e.warnT = 0 -- 4062
						e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4063
					end -- 4063
					goto __continue637 -- 4065
				end -- 4065
				if e.warnT > 0 then -- 4065
					e.warnT = e.warnT - 1 -- 4068
					if e.warnT <= 0 then -- 4068
						self:campaignEnemyFire(e) -- 4070
					end -- 4070
				elseif e.fireCd > 0 then -- 4070
					e.fireCd = e.fireCd - 1 -- 4073
					if e.fireCd <= 0 then -- 4073
						e.warnT = WARN_TICKS -- 4075
					end -- 4075
				else -- 4075
					e.fireCd = 40 -- 4078
				end -- 4078
			end -- 4078
			::__continue637:: -- 4078
			i = i + 1 -- 4011
		end -- 4011
	end -- 4011
end -- 4008
function Play.prototype.blockedShot(self, e, p) -- 4084
	local eDepth = e.depth or 0 -- 4085
	local ex = e.x -- 4086
	local ey = e.y + e.h * 0.62 -- 4088
	local px = p.x -- 4089
	local py = p.y + p.h * 0.55 -- 4090
	local dx = px - ex -- 4091
	local dyScreen = py + p.depth * DEPTH_Y_SCALE - (ey + eDepth * DEPTH_Y_SCALE) -- 4092
	local len = math.sqrt(dx * dx + dyScreen * dyScreen) -- 4093
	if len < 0.01 then -- 4093
		return false -- 4095
	end -- 4095
	local ray = { -- 4099
		x = ex, -- 4100
		y = ey, -- 4100
		dx = dx / len, -- 4101
		dy = (py - ey) / len, -- 4101
		depth = eDepth, -- 4102
		dDepth = (p.depth - eDepth) / len -- 4102
	} -- 4102
	local best = -1 -- 4104
	local j = 0 -- 4105
	do -- 4105
		j = 0 -- 4106
		while j < #self.boxes do -- 4106
			do -- 4106
				local b = self.boxes[j + 1] -- 4107
				if b.broken == true or b.passable == true or b.hidden == true then -- 4107
					goto __continue660 -- 4109
				end -- 4109
				if b.id == "braced_shield" then -- 4109
					goto __continue660 -- 4114
				end -- 4114
				local t = hitBox(ray, b) -- 4116
				if t > 2 and t < len - 2 and (best < 0 or t < best) then -- 4116
					best = t -- 4120
				end -- 4120
			end -- 4120
			::__continue660:: -- 4120
			j = j + 1 -- 4106
		end -- 4106
	end -- 4106
	return best >= 0 -- 4123
end -- 4084
function Play.prototype.campaignEnemyFire(self, e) -- 4126
	local p = self.player -- 4127
	e.fireCd = CAMPAIGN_FIRE_COOLDOWN -- 4128
	if self.bracedShield ~= nil and math.abs(self.bracedShield.x - p.x) < 50 then -- 4128
		local ____self_bracedShield_115, ____hp_116 = self.bracedShield, "hp" -- 4128
		____self_bracedShield_115[____hp_116] = ____self_bracedShield_115[____hp_116] - 1 -- 4130
		if self.bracedShield.hp <= 0 then -- 4130
			self.boxes = __TS__ArrayFilter( -- 4132
				self.boxes, -- 4132
				function(____, b) return b.id ~= "braced_shield" end -- 4132
			) -- 4132
			self.bracedShield = nil -- 4133
			self:flashSet("残盾碎 · 挡下一发", 1) -- 4134
		else -- 4134
			self:flashSet( -- 4136
				"残盾挡下一发 · 余" .. tostring(self.bracedShield.hp), -- 4136
				1 -- 4136
			) -- 4136
		end -- 4136
		self:emit("coverBlocked", {entity = "残盾", enemyX = e.x, hp = self.hp}) -- 4138
		return -- 4139
	end -- 4139
	if self:blockedShot(e, p) then -- 4139
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4142
		return -- 4143
	end -- 4143
	local cover = self:blockedByCover(e, p) -- 4145
	if cover ~= nil and self.coverHug then -- 4145
		self.coveredFlash = 0.5 -- 4147
		self:flashSet("掩体挡下", 0.6) -- 4148
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4149
		return -- 4154
	end -- 4154
	if self.invulnT > 0 then -- 4154
		return -- 4157
	end -- 4157
	self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4159
	self.craftT = 0 -- 4160
	self.hp = self.hp - 1 -- 4161
	self:emit("actorHit", { -- 4162
		target = "player", -- 4162
		amount = 1, -- 4162
		hp = self.hp, -- 4162
		maxHp = self.maxHp, -- 4162
		enemyX = e.x -- 4162
	}) -- 4162
	self:flashSet( -- 4163
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4163
		0.8 -- 4163
	) -- 4163
	if self.hp <= 0 then -- 4163
		self:campaignFailed() -- 4165
	end -- 4165
end -- 4126
function Play.prototype.stepShield(self, e, dt, input) -- 4170
	local p = self.player -- 4171
	local dx = p.x - e.x -- 4172
	local adx = math.abs(dx) -- 4173
	local guardLane = self.room.key == "c2-granary" and (e.depth or 0) >= 20 -- 4176
	local sameLane = math.abs((e.depth or 0) - p.depth) <= 20 -- 4177
	if adx > 44 then -- 4177
		local before = e.x -- 4179
		local stepX = (dx > 0 and 1 or -1) * 60 * dt -- 4180
		local nextX = math.max( -- 4181
			self.room.minX + 16, -- 4181
			math.min(self.room.maxX - 16, e.x + stepX) -- 4181
		) -- 4181
		if not self:enemyBlockedAtX(e, nextX) then -- 4181
			e.x = nextX -- 4183
		end -- 4183
		if not guardLane and math.abs(e.x - before) < 0.3 then -- 4183
			e.depth = math.max( -- 4187
				-32, -- 4187
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4187
			) -- 4187
		end -- 4187
	elseif adx <= 48 and sameLane and (e.swingT or 0) <= 0 then -- 4187
		local fromFront = (e.x - p.x) * p.facing > 0 -- 4192
		local rollDodges = p.rollT > 0 and (fromFront or self:talentRank("guard") > 0) -- 4193
		if not rollDodges and self.invulnT <= 0 then -- 4193
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4195
			self.craftT = 0 -- 4196
			self.hp = self.hp - 1 -- 4197
			self:emit("actorHit", { -- 4198
				target = "player", -- 4198
				amount = 1, -- 4198
				hp = self.hp, -- 4198
				maxHp = self.maxHp, -- 4198
				enemyX = e.x -- 4198
			}) -- 4198
			self:flashSet( -- 4199
				(("盾手近身 · " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4199
				0.8 -- 4199
			) -- 4199
			if self.hp <= 0 then -- 4199
				self:campaignFailed() -- 4201
				return -- 4202
			end -- 4202
		end -- 4202
		e.swingT = 70 -- 4205
	end -- 4205
	if (e.swingT or 0) > 0 then -- 4205
		e.swingT = (e.swingT or 0) - 1 -- 4208
	end -- 4208
	if not guardLane and math.abs((e.depth or 0) - p.depth) > 20 then -- 4208
		local dd = p.depth - (e.depth or 0) -- 4211
		e.depth = (e.depth or 0) + (dd > 0 and 1 or -1) * 30 * dt -- 4212
	end -- 4212
end -- 4170
function Play.prototype.stepBreaker(self, e, dt) -- 4217
	local p = self.player -- 4218
	if e.awake ~= true then -- 4218
		if math.abs(p.x - e.x) < 560 then -- 4218
			e.awake = true -- 4221
		else -- 4221
			return -- 4223
		end -- 4223
	end -- 4223
	local target = nil -- 4226
	local bestD = 1000000000 -- 4227
	local i = 0 -- 4228
	do -- 4228
		i = 0 -- 4229
		while i < #self.boxes do -- 4229
			do -- 4229
				local b = self.boxes[i + 1] -- 4230
				if b.breakable == nil or b.broken == true then -- 4230
					goto __continue687 -- 4232
				end -- 4232
				local d = math.abs((b.x0 + b.x1) / 2 - e.x) -- 4234
				if d < bestD then -- 4234
					bestD = d -- 4236
					target = b -- 4237
				end -- 4237
			end -- 4237
			::__continue687:: -- 4237
			i = i + 1 -- 4229
		end -- 4229
	end -- 4229
	local tx = target == nil and p.x or (target.x0 + target.x1) / 2 -- 4240
	local dx = tx - e.x -- 4241
	local reach = target == nil and 46 or (target.x1 - target.x0) / 2 + 40 -- 4242
	if math.abs(dx) > reach then -- 4242
		local before = e.x -- 4244
		local nextX = math.max( -- 4245
			self.room.minX + 16, -- 4245
			math.min(self.room.maxX - 16, e.x + (dx > 0 and 1 or -1) * 48 * dt) -- 4245
		) -- 4245
		if not self:enemyBlockedAtX(e, nextX) then -- 4245
			e.x = nextX -- 4247
		end -- 4247
		if math.abs(e.x - before) < 0.3 then -- 4247
			e.depth = math.max( -- 4250
				-32, -- 4250
				math.min(32, (e.depth or 0) + (p.depth >= (e.depth or 0) and 16 or -16)) -- 4250
			) -- 4250
		end -- 4250
	elseif (e.swingT or 0) <= 0 then -- 4250
		e.swingT = 64 -- 4253
		if target ~= nil then -- 4253
			self:damageProp(target, 2) -- 4255
		elseif math.abs(p.x - e.x) < 60 and math.abs((e.depth or 0) - p.depth) <= 26 and not (p.rollT > 0 and self:talentRank("guard") > 0) and self.invulnT <= 0 then -- 4255
			self.invulnT = INVULN_HIT_TICKS + 15 * self:talentRank("guard") -- 4258
			self.craftT = 0 -- 4259
			self.hp = self.hp - 1 -- 4260
			self:emit("actorHit", { -- 4261
				target = "player", -- 4261
				amount = 1, -- 4261
				hp = self.hp, -- 4261
				maxHp = self.maxHp, -- 4261
				enemyX = e.x -- 4261
			}) -- 4261
			self:flashSet("破障手近身", 0.8) -- 4262
			if self.hp <= 0 then -- 4262
				self:campaignFailed() -- 4264
				return -- 4265
			end -- 4265
		end -- 4265
	end -- 4265
	if (e.swingT or 0) > 0 then -- 4265
		e.swingT = (e.swingT or 0) - 1 -- 4270
	end -- 4270
end -- 4217
function Play.prototype.enemyBlockedAtX(self, e, nextX) -- 4275
	local half = e.w * 0.5 -- 4276
	local d = e.depth or 0 -- 4277
	local i = 0 -- 4278
	do -- 4278
		i = 0 -- 4279
		while i < #self.boxes do -- 4279
			do -- 4279
				local b = self.boxes[i + 1] -- 4280
				if b.broken == true or b.passable == true or b.soft == true or b.hidden == true or b.y0 >= e.y + e.h or b.y1 <= e.y + 4 then -- 4280
					goto __continue700 -- 4282
				end -- 4282
				if b.depth ~= nil and (d < b.depth.min - 8 or d > b.depth.max + 8) then -- 4282
					goto __continue700 -- 4285
				end -- 4285
				if nextX + half > b.x0 and nextX - half < b.x1 then -- 4285
					return true -- 4288
				end -- 4288
			end -- 4288
			::__continue700:: -- 4288
			i = i + 1 -- 4279
		end -- 4279
	end -- 4279
	return false -- 4291
end -- 4275
function Play.prototype.campaignFailed(self) -- 4294
	if self.isCampaign and self.storyRoute == "soldier" and self:isEscortRoom() then -- 4294
		if self.escortFailed then -- 4294
			return -- 4299
		end -- 4299
		if self.useEscortDeathSummary then -- 4299
			local story = self.run.story -- 4301
			local st = story.talents -- 4302
			local ranksCopy = { -- 4303
				vitality = st and st.ranks.vitality or 0, -- 4304
				guard = st and st.ranks.guard or 0, -- 4305
				stride = st and st.ranks.stride or 0, -- 4306
				focus = st and st.ranks.focus or 0, -- 4307
				push_force = st and st.ranks.push_force or 0, -- 4308
				echo_wide = st and st.ranks.echo_wide or 0, -- 4309
				lantern_pierce = st and st.ranks.lantern_pierce or 0, -- 4310
				salvage = st and st.ranks.salvage or 0 -- 4311
			} -- 4311
			local cleared = 0 -- 4313
			local segKeys = { -- 4314
				"escort1", -- 4314
				"escort2", -- 4314
				"escort3", -- 4314
				"escort4", -- 4314
				"escort5" -- 4314
			} -- 4314
			local si = 0 -- 4315
			do -- 4315
				si = 0 -- 4316
				while si < #segKeys do -- 4316
					if story.segments[segKeys[si + 1]] == true then -- 4316
						cleared = cleared + 1 -- 4318
					end -- 4318
					si = si + 1 -- 4316
				end -- 4316
			end -- 4316
			self.escortFailed = true -- 4321
			self.escortFailedTicks = 0 -- 4322
			self.talentModalActive = false -- 4323
			self.craftBench.active = false -- 4324
			self.reloadT = 0 -- 4325
			self:closeReloadPuzzle() -- 4326
			self.gripping = false -- 4327
			self.escortSummary = { -- 4328
				roomKey = self.room.key, -- 4329
				attempt = st ~= nil and math.max(1, st.attempt) or 1, -- 4330
				seed = st ~= nil and st.randomState or self.run.seed, -- 4331
				equippedWeapon = self.equippedWeapon, -- 4332
				segmentsCleared = cleared, -- 4333
				ranks = ranksCopy -- 4334
			} -- 4334
			self:resetEscortAttempt() -- 4336
			self:flashSet("折返山道 · 重整再赴", 2) -- 4337
			self:log("男主线折返 · 展示小结") -- 4338
			self:emit("campaignFailed", { -- 4339
				room = self.room.key, -- 4340
				hp = 0, -- 4340
				maxHp = self.maxHp, -- 4340
				reset = true, -- 4341
				to = "escort1", -- 4341
				route = self.storyRoute, -- 4341
				summary = true -- 4341
			}) -- 4341
			return -- 4343
		end -- 4343
		self:restartEscortRun() -- 4345
		return -- 4346
	end -- 4346
	local p = self.player -- 4348
	self.hp = self.maxHp -- 4349
	self.invulnT = INVULN_RESPAWN_TICKS -- 4350
	self.reloadT = 0 -- 4351
	self:closeReloadPuzzle() -- 4352
	self.gripping = false -- 4353
	self:flashSet("被击倒 · 回到本段起点，破坏与拾取保留", 2) -- 4354
	self:log("被击倒") -- 4355
	p.x = self.room.minX + 90 -- 4356
	p.y = 0 -- 4357
	p.depth = 0 -- 4358
	p.vx = 0 -- 4359
	p.vy = 0 -- 4360
	p.onGround = true -- 4361
	p.rollT = 0 -- 4362
	self.partner.x = p.x - 50 -- 4363
	self.partner.y = 0 -- 4364
	self.partner.depth = 0 -- 4365
	self.cam.x = p.x -- 4366
	local i = 0 -- 4367
	do -- 4367
		i = 0 -- 4368
		while i < #self.enemies do -- 4368
			do -- 4368
				local e = self.enemies[i + 1] -- 4369
				if not e.alive then -- 4369
					goto __continue712 -- 4371
				end -- 4371
				e.x = e.homeX == nil and e.x or e.homeX -- 4373
				e.warnT = 0 -- 4374
				e.fireCd = 40 -- 4375
				e.swingT = 0 -- 4376
				e.awake = false -- 4377
			end -- 4377
			::__continue712:: -- 4377
			i = i + 1 -- 4368
		end -- 4368
	end -- 4368
	self:emit("campaignFailed", {room = self.room.key, hp = 0, maxHp = self.maxHp}) -- 4379
end -- 4294
function Play.prototype.isEscortRoom(self) -- 4383
	return (string.find(self.room.key, "escort", nil, true) or 0) - 1 == 0 -- 4384
end -- 4383
function Play.prototype.confirmEscortRestart(self) -- 4388
	if not self.escortFailed then -- 4388
		return false -- 4390
	end -- 4390
	self:requestRoom("escort1", "男主线失败重开") -- 4392
	return true -- 4393
end -- 4388
function Play.prototype.restartEscortRun(self) -- 4397
	self:resetEscortAttempt() -- 4398
	self:requestRoom("escort1", "男主线失败重开") -- 4399
end -- 4397
function Play.prototype.resetEscortAttempt(self) -- 4407
	local story = self.run.story -- 4408
	local inv = self.run.inventory -- 4409
	local prevAttempt = story.talents ~= nil and math.max(1, story.talents.attempt) or 1 -- 4410
	local nextAttempt = prevAttempt + 1 -- 4411
	local vitBonus = story.talents ~= nil and (story.talents.ranks.vitality or 0) or 0 -- 4412
	if vitBonus > 0 then -- 4412
		self.maxHp = math.max(3, self.maxHp - vitBonus) -- 4414
		story.maxHp = self.maxHp -- 4415
	end -- 4415
	story.talents = createStoryTalents(self.run.seed, nextAttempt) -- 4417
	self.hp = self.maxHp -- 4418
	story.hp = self.maxHp -- 4419
	story.cp = nil -- 4420
	self.checkpointSnap = nil -- 4421
	story.carry = false -- 4422
	self.carryOn = false -- 4423
	story.craftedWeapon = "" -- 4424
	self.equippedWeapon = "standard_gun" -- 4425
	story.equippedWeapon = "standard_gun" -- 4426
	story.escortDone = false -- 4427
	self.escortDone = false -- 4428
	story.segments = {} -- 4429
	inv.wood = 0 -- 4430
	inv.bell = 0 -- 4431
	inv.scrap = 0 -- 4432
	inv.wedge = 0 -- 4433
	inv.ammo = 0 -- 4434
	inv.quickbelt = 0 -- 4435
	inv.shield = 0 -- 4436
	inv.pass = 0 -- 4437
	local taken = self.run.taken -- 4438
	local keys = __TS__ObjectKeys(taken) -- 4439
	local i = 0 -- 4440
	do -- 4440
		i = 0 -- 4441
		while i < #keys do -- 4441
			local k = keys[i + 1] -- 4442
			if (string.find(k, "e2_", nil, true) or 0) - 1 == 0 or (string.find(k, "e3_", nil, true) or 0) - 1 == 0 or (string.find(k, "escort", nil, true) or 0) - 1 == 0 then -- 4442
				__TS__Delete(taken, k) -- 4444
			end -- 4444
			i = i + 1 -- 4441
		end -- 4441
	end -- 4441
	local propKeys = __TS__ObjectKeys(self.run.props) -- 4447
	do -- 4447
		i = 0 -- 4448
		while i < #propKeys do -- 4448
			local pk = propKeys[i + 1] -- 4449
			if (string.find(pk, "e1_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e2_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e3_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e4_", nil, true) or 0) - 1 == 0 or (string.find(pk, "e5_", nil, true) or 0) - 1 == 0 or (string.find(pk, "field_wedge_", nil, true) or 0) - 1 == 0 then -- 4449
				__TS__Delete(self.run.props, pk) -- 4452
			end -- 4452
			i = i + 1 -- 4448
		end -- 4448
	end -- 4448
	self.bracedShield = nil -- 4455
	self.talentModalActive = false -- 4456
	self.run.joined = true -- 4457
	self.reloadT = 0 -- 4458
	self:closeReloadPuzzle() -- 4459
	self.gripping = false -- 4460
	self.sessionDirty = true -- 4461
	self:flashSet( -- 4462
		("重整启程 · 第" .. tostring(nextAttempt)) .. "轮护送", -- 4462
		2 -- 4462
	) -- 4462
	self:log(("男主线重开 · 第" .. tostring(nextAttempt)) .. "轮回 escort1") -- 4463
	if not self.useEscortDeathSummary then -- 4463
		self:emit("campaignFailed", { -- 4465
			room = self.room.key, -- 4466
			hp = 0, -- 4466
			maxHp = self.maxHp, -- 4466
			reset = true, -- 4467
			to = "escort1", -- 4467
			route = self.storyRoute, -- 4467
			attempt = nextAttempt -- 4467
		}) -- 4467
	end -- 4467
end -- 4407
function Play.prototype.blindNearby(self, center, radius, skipIndex) -- 4473
	local i = 0 -- 4474
	do -- 4474
		i = 0 -- 4475
		while i < #self.enemies do -- 4475
			do -- 4475
				if i == skipIndex then -- 4475
					goto __continue729 -- 4477
				end -- 4477
				local e = self.enemies[i + 1] -- 4479
				if not e.alive or math.abs(e.x - center.x) > radius then -- 4479
					goto __continue729 -- 4481
				end -- 4481
				e.awake = true -- 4483
				e.fireCd = math.max(e.fireCd or 0, 150) -- 4484
				e.warnT = 0 -- 4485
			end -- 4485
			::__continue729:: -- 4485
			i = i + 1 -- 4475
		end -- 4475
	end -- 4475
end -- 4473
function Play.prototype.stepEnemies(self, dt, input) -- 4489
	local i = 0 -- 4490
	do -- 4490
		i = 0 -- 4491
		while i < #self.enemies do -- 4491
			local e = self.enemies[i + 1] -- 4492
			if e.hitT > 0 then -- 4492
				e.hitT = e.hitT - dt -- 4494
			end -- 4494
			i = i + 1 -- 4491
		end -- 4491
	end -- 4491
	if self.coveredFlash > 0 then -- 4491
		self.coveredFlash = self.coveredFlash - dt -- 4498
	end -- 4498
	if self.isCampaign then -- 4498
		self:stepCampaignEnemies(dt, input) -- 4501
		return -- 4502
	end -- 4502
	if self.room.key ~= "gate" or self.phase ~= "gate-hold" then -- 4502
		return -- 4506
	end -- 4506
	do -- 4506
		i = 0 -- 4508
		while i < #self.enemies do -- 4508
			do -- 4508
				local e = self.enemies[i + 1] -- 4509
				if not e.alive then -- 4509
					goto __continue740 -- 4511
				end -- 4511
				if e.warnT > 0 then -- 4511
					e.warnT = e.warnT - 1 -- 4514
					if e.warnT <= 0 then -- 4514
						self:enemyFire(e, input) -- 4516
					end -- 4516
					goto __continue740 -- 4518
				end -- 4518
				if e.fireCd > 0 then -- 4518
					e.fireCd = e.fireCd - 1 -- 4521
					if e.fireCd <= 0 then -- 4521
						e.warnT = WARN_TICKS -- 4523
					end -- 4523
				else -- 4523
					e.warnT = WARN_TICKS -- 4527
				end -- 4527
			end -- 4527
			::__continue740:: -- 4527
			i = i + 1 -- 4508
		end -- 4508
	end -- 4508
end -- 4489
function Play.prototype.enemyFire(self, e, input) -- 4533
	local p = self.player -- 4534
	if math.abs(e.x - p.x) > ENEMY_RANGE then -- 4534
		self:flashSet("枪声响在远处", 0.4) -- 4536
		e.fireCd = FIRE_COOLDOWN -- 4537
		return -- 4538
	end -- 4538
	if self:blockedShot(e, p) then -- 4538
		self:emit("coverBlocked", {entity = "实体遮挡", enemyX = e.x, hp = self.hp}) -- 4541
		e.fireCd = FIRE_COOLDOWN -- 4542
		return -- 4543
	end -- 4543
	local cover = self:blockedByCover(e, p) -- 4546
	local hugging = cover ~= nil -- 4547
	self.coverBlocking = hugging -- 4548
	local covered = hugging and input.cover.held -- 4549
	if covered then -- 4549
		self.coveredFlash = 0.5 -- 4551
		self:flashSet("掩体挡下", 0.5) -- 4552
		self:emit("coverBlocked", {entity = cover.label == nil and "一人高实体" or cover.label, enemyX = e.x, hp = self.hp}) -- 4553
		e.fireCd = FIRE_COOLDOWN -- 4558
		return -- 4559
	end -- 4559
	if self.invulnT > 0 then -- 4559
		e.fireCd = FIRE_COOLDOWN -- 4562
		return -- 4563
	end -- 4563
	self.invulnT = INVULN_HIT_TICKS -- 4565
	self.hp = self.hp - 1 -- 4566
	self:emit("actorHit", { -- 4567
		target = "player", -- 4567
		amount = 1, -- 4567
		hp = self.hp, -- 4567
		maxHp = self.maxHp, -- 4567
		enemyX = e.x -- 4567
	}) -- 4567
	self:flashSet( -- 4568
		(("中弹 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp), -- 4568
		0.7 -- 4568
	) -- 4568
	e.fireCd = FIRE_COOLDOWN -- 4569
	if self.hp <= 0 then -- 4569
		self:gateFailed() -- 4571
	end -- 4571
end -- 4533
function Play.prototype.blockedByCover(self, enemy, p) -- 4576
	local b = self:coverAt(p) -- 4577
	if b == nil then -- 4577
		return nil -- 4579
	end -- 4579
	return self:coverGuardsFrom(b, p, enemy) and b or nil -- 4581
end -- 4576
function Play.prototype.gateFailed(self) -- 4585
	local ____temp_133 -- 4586
	if self.room.story == nil then -- 4586
		____temp_133 = nil -- 4586
	else -- 4586
		____temp_133 = self.room.story.gate -- 4586
	end -- 4586
	local g = ____temp_133 -- 4586
	self:flashSet("被击倒 · 回绞盘 118，重新就位再守", 2) -- 4587
	self.hp = self.maxHp -- 4588
	self.gateTick = 0 -- 4589
	self.gateSpawned = 0 -- 4590
	self.enemies = {} -- 4591
	self.gateFailCount = self.gateFailCount + 1 -- 4592
	self.player.x = self.ox + (g == nil and 118 or g.winchX) -- 4594
	self.player.y = 0 -- 4595
	self.player.vy = 0 -- 4596
	self.player.depth = 0 -- 4597
	self.player.depthSpeed = 0 -- 4598
	self.player.onGround = true -- 4599
	self.player.crouch = false -- 4600
	self.player.h = SOLDIER_H -- 4601
	self.partner.x = self.ox + (g == nil and 900 or g.waitX) -- 4602
	self.partner.y = 0 -- 4603
	self.partner.vy = 0 -- 4604
	self.partner.depth = 0 -- 4605
	self.partner.depthSpeed = 0 -- 4606
	self.partner.onGround = true -- 4607
	self.cam.x = self.player.x -- 4608
	self.phase = "gate-idle" -- 4609
	self.phaseTick = 0 -- 4610
	self.coverHug = false -- 4611
	self.coverBlocking = false -- 4612
	self.coverEntity = "" -- 4613
	self.gateNeedConfirm = true -- 4614
	self.gateRestartArmed = false -- 4615
	self:emit("gateFailed", {failCount = self.gateFailCount, hp = 0, maxHp = self.maxHp}) -- 4616
end -- 4585
function Play.prototype.stepRedCart(self, input) -- 4620
	if self.redCartMemoryT > 0 then -- 4620
		self.redCartMemoryT = self.redCartMemoryT - 1 -- 4622
	end -- 4622
	if self.room.key ~= "outside" or self.redCartPulled then -- 4622
		return -- 4625
	end -- 4625
	local box = __TS__ArrayFind( -- 4627
		self.boxes, -- 4627
		function(____, b) return b.id == "outside_red_cart" end -- 4627
	) -- 4627
	if box == nil then -- 4627
		self.redCartPulled = true -- 4629
		return -- 4630
	end -- 4630
	local cx = (box.x0 + box.x1) * 0.5 -- 4632
	local p = self.player -- 4633
	if math.abs(p.x - cx) > 70 or math.abs(p.y - 96) > 26 then -- 4633
		return -- 4635
	end -- 4635
	if not input.interact.pressed then -- 4635
		return -- 4638
	end -- 4638
	box.x0 = 430 -- 4640
	box.x1 = 474 -- 4641
	self.cartAxle = self.room.cart.endX -- 4643
	self.cartDocked = true -- 4644
	self.redCartPulled = true -- 4645
	self.redCartMemoryT = 30 -- 4646
	if self.run.story ~= nil then -- 4646
		self.run.story.segments.outside_cart = true -- 4648
		self.run.story.segments.outside_memory = true -- 4649
	end -- 4649
	self.sessionDirty = true -- 4651
	self:flashSet("红布补丁 · 想起家里那一针 · 石阶口露出来", 1.8) -- 4652
	self:emit("storyBeat", {beat = "red_cart", x = p.x, room = "outside"}) -- 4653
	self:emit("storyBeat", {beat = "red_cart_memory", x = p.x, room = "outside", durationTicks = 30}) -- 4654
end -- 4620
function Play.prototype.stepInteract(self, dt, input) -- 4657
	local p = self.player -- 4658
	self:stepRedCart(input) -- 4659
	local calmUsed = self.calmConsumed -- 4660
	self.calmConsumed = false -- 4661
	local calming = self.escort.state == "calming" -- 4663
	self.focusCart = false -- 4664
	if self.room.key == "outside" then -- 4664
		local c = self.room.cart -- 4666
		local dx = p.x - (self.cartAxle + c.handleOffset) -- 4667
		local dy = p.y - c.baseY -- 4668
		self.focusCart = not calmUsed and not calming and dx * dx + dy * dy < ____exports.CART_REACH * ____exports.CART_REACH -- 4669
	end -- 4669
	if not calmUsed and not calming then -- 4669
		self:stepCart(dt, input) -- 4673
	end -- 4673
	if calmUsed then -- 4673
		self:flashSet("安抚 · 敲两下", 0.8) -- 4678
	elseif not calming and input.interact.pressed and not self.gripping and self.room.key ~= "village" and self.room.key ~= "tower" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "museum" then -- 4678
		if self.knockT > 0 then -- 4678
			self.knocks = self.knocks + 1 -- 4682
		else -- 4682
			self.knocks = 1 -- 4684
		end -- 4684
		self:emit("knock", {count = self.knocks, x = p.x, room = self.room.key}) -- 4686
		self.knockT = 1.2 -- 4687
		if self.knocks >= 2 then -- 4687
			self:flashSet("敲两下", 0.8) -- 4689
			self.knocks = 0 -- 4690
		else -- 4690
			self:flashSet("敲一下", 0.5) -- 4692
		end -- 4692
	elseif self.knockT > 0 then -- 4692
		self.knockT = self.knockT - dt -- 4695
		if self.knockT <= 0 then -- 4695
			self.knocks = 0 -- 4697
		end -- 4697
	end -- 4697
	local i = 0 -- 4702
	do -- 4702
		i = 0 -- 4703
		while i < #self.room.marks do -- 4703
			do -- 4703
				local m = self.room.marks[i + 1] -- 4704
				if m.kind ~= 0 then -- 4704
					goto __continue776 -- 4706
				end -- 4706
				local subjects = {self.partner, self.player} -- 4708
				local k = 0 -- 4709
				do -- 4709
					k = 0 -- 4710
					while k < #subjects do -- 4710
						do -- 4710
							local s = subjects[k + 1] -- 4711
							if not s.alive then -- 4711
								goto __continue779 -- 4713
							end -- 4713
							local dx = s.x - m.x -- 4715
							local dy = s.y - m.y -- 4716
							if dx * dx + dy * dy < 26 * 26 and self.checkpoint ~= m.x then -- 4716
								self.checkpoint = m.x -- 4718
								self.checkpointCartAxle = self.cartAxle -- 4719
								if self.isCampaign then -- 4719
									self:captureCheckpoint(m.x) -- 4722
								end -- 4722
								if self.room.cart.bodyW > 0 then -- 4722
									if self.cartDocked then -- 4722
										self:flashSet("检查点 · 车已落窝", 1) -- 4726
									else -- 4726
										self:flashSet("检查点 · 车还没到位", 1) -- 4728
									end -- 4728
								else -- 4728
									self:flashSet("检查点", 1) -- 4731
								end -- 4731
							end -- 4731
						end -- 4731
						::__continue779:: -- 4731
						k = k + 1 -- 4710
					end -- 4710
				end -- 4710
			end -- 4710
			::__continue776:: -- 4710
			i = i + 1 -- 4703
		end -- 4703
	end -- 4703
	self:checkCarryGate() -- 4737
end -- 4657
function Play.prototype.stepVillage(self, dt, input) -- 4741
	if self.room.key ~= "village" then -- 4741
		return -- 4743
	end -- 4743
	local p = self.player -- 4745
	local bottle = self.room.bottle -- 4746
	local scav = self.room.scavenger -- 4747
	if not self.hasBottle and bottle ~= nil then -- 4747
		local dx = p.x - bottle.x -- 4751
		local dy = p.y + p.h * 0.5 - bottle.y -- 4752
		if dx * dx + dy * dy < 56 * 56 and input.interact.pressed then -- 4752
			self.hasBottle = true -- 4754
			self:flashSet("拾起瓶子", 0.8) -- 4755
		end -- 4755
	end -- 4755
	if self.hasBottle then -- 4755
		if input.bottleCanceled then -- 4755
			self.aimHold = 0 -- 4762
			self.bottleAimX = -1 -- 4763
		elseif input.aim.held then -- 4763
			self.aimHold = self.aimHold + dt -- 4765
			if self.aimHold > 1.2 then -- 4765
				self.aimHold = 1.2 -- 4767
			end -- 4767
			local cached = self:bottleEnd() -- 4770
			self.bottleAimX = cached.x -- 4771
			self.bottleAimY = cached.y -- 4772
		elseif input.aim.released then -- 4772
			if self.aimHold < 0.12 then -- 4772
				self:flashSet("按住 F 瞄一下再松手", 0.9) -- 4776
				self.aimHold = 0 -- 4777
			else -- 4777
				local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 4779
				self:throwBottle(____end.x, ____end.y) -- 4780
				self.aimHold = 0 -- 4781
			end -- 4781
		end -- 4781
	else -- 4781
		self.aimHold = 0 -- 4785
		self.bottleAimX = -1 -- 4786
	end -- 4786
	local fly = self.bottleFly -- 4791
	if fly ~= nil then -- 4791
		fly.t = fly.t + dt -- 4793
		fly.x = fly.x0 + fly.vx * fly.t -- 4794
		fly.y = fly.y0 + fly.vy * fly.t - 0.5 * ____exports.GRAVITY * fly.t * fly.t -- 4795
		local falling = fly.vy - ____exports.GRAVITY * fly.t <= 0 -- 4796
		if fly.t >= BOTTLE_FLY_TIME and falling then -- 4796
			self:landBottle(fly) -- 4798
		end -- 4798
	end -- 4798
	if self.bottleLandT > 0 then -- 4798
		self.bottleLandT = self.bottleLandT - dt -- 4802
	end -- 4802
	if scav ~= nil then -- 4802
		self:stepScav(dt, scav) -- 4806
	end -- 4806
	local line = self.room.passLine -- 4809
	if line ~= nil and not self.passed and p.x >= line then -- 4809
		self.passed = true -- 4811
		self:flashSet("过了第一院 · 通行线 440", 1.4) -- 4812
	end -- 4812
	local underTable = p.crouch and p.x >= self.ox + 304 and p.x <= self.ox + 416 -- 4815
	if underTable then -- 4815
		self.footHintT = self.footHintT - 1 -- 4817
		if self.footHintT <= 0 then -- 4817
			self.footHintT = 90 -- 4819
			local scavX = self.scavX -- 4820
			local near = math.abs(scavX - p.x) < 120 -- 4821
			local walkingAway = self.scavState == "walk" and math.abs(self.scavTargetX - p.x) >= 120 -- 4822
			local heard = self.scavState == "chase" or near and not walkingAway -- 4823
			self:flashSet(heard and "桌下 · 脚步近了，别出声" or "桌下 · 脚步远了，趁现在钻", 1.2) -- 4824
			self:emit("storyBeat", {beat = heard and "footstep_near" or "footstep_far", x = p.x, room = "village"}) -- 4825
		end -- 4825
	else -- 4825
		self.footHintT = 0 -- 4828
	end -- 4828
	if self.passed and not self.ditchHinted and p.x >= self.ox + 560 then -- 4828
		self.ditchHinted = true -- 4832
		self:flashSet("暗渠口 · 蹲下钻过去", 1.4) -- 4833
		self:emit("storyBeat", {beat = "ditch", x = p.x, room = "village"}) -- 4834
	end -- 4834
	local inCulvert = p.x >= self.ox + 560 and p.x <= self.ox + 640 -- 4837
	if self.passed and inCulvert and p.crouch and self.wantRoom == "" then -- 4837
		self:requestRoom("forest", "蹲下钻过暗渠") -- 4839
		self:flashSet("钻进暗渠 · 北塔森林", 1.4) -- 4840
	end -- 4840
end -- 4741
function Play.prototype.bottleEnd(self) -- 4845
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 4846
	local clampedX = math.max( -- 4849
		self.room.minX + 12, -- 4849
		math.min(self.room.maxX - 12, aim.x) -- 4849
	) -- 4849
	local g = self:groundAt(clampedX, aim.y + 240, 3) -- 4850
	return {x = clampedX, y = g} -- 4851
end -- 4845
function Play.prototype.throwBottle(self, tx, ty) -- 4855
	local p = self.player -- 4856
	local dir = tx >= p.x and 1 or -1 -- 4858
	p.facing = dir -- 4859
	local x0 = p.x + dir * 10 -- 4860
	local y0 = p.y + p.h * 0.7 -- 4861
	self.bottleTargetX = tx -- 4862
	self.bottleTargetY = ty -- 4863
	self.bottleSurfaceY = ty -- 4864
	local vx = (tx - x0) / BOTTLE_FLY_TIME -- 4865
	local vy = (ty - y0 + 0.5 * ____exports.GRAVITY * BOTTLE_FLY_TIME * BOTTLE_FLY_TIME) / BOTTLE_FLY_TIME -- 4866
	self.bottleFly = { -- 4867
		x = x0, -- 4867
		y = y0, -- 4867
		x0 = x0, -- 4867
		y0 = y0, -- 4867
		vx = vx, -- 4867
		vy = vy, -- 4867
		t = 0 -- 4867
	} -- 4867
	self.hasBottle = false -- 4868
	self:flashSet("投出", 0.4) -- 4869
	self:emit( -- 4870
		"bottleThrown", -- 4870
		{ -- 4870
			fromX = x0, -- 4871
			fromY = y0, -- 4872
			targetX = tx, -- 4873
			targetY = ty, -- 4874
			flightTicks = math.floor(BOTTLE_FLY_TIME * 60 + 0.5) -- 4875
		} -- 4875
	) -- 4875
end -- 4855
function Play.prototype.bottleSurfaceAt(self, x) -- 4880
	if self.room.softX ~= nil and math.abs(x - self.room.softX) <= 34 then -- 4880
		return "soft" -- 4882
	end -- 4882
	if self.room.basinX ~= nil and math.abs(x - self.room.basinX) <= 24 then -- 4882
		return "iron" -- 4885
	end -- 4885
	return "brick" -- 4887
end -- 4880
function Play.prototype.landBottle(self, fly) -- 4891
	local x = self.bottleTargetX >= 0 and self.bottleTargetX or fly.x -- 4892
	local y = self.bottleSurfaceY >= 0 and self.bottleSurfaceY or fly.y -- 4893
	local s = self.room.scavenger -- 4894
	local surface = self:bottleSurfaceAt(x) -- 4895
	local effRange = s == nil and 0 or (surface == "iron" and s.range * 1.25 or s.range) -- 4896
	local heard = surface ~= "soft" and s ~= nil and math.abs(x - self.scavX) <= effRange -- 4897
	local stallTicks = s == nil and 0 or (surface == "iron" and s.stallTicks + 90 or s.stallTicks) -- 4898
	self.bottleFly = nil -- 4899
	self.bottleTargetX = -1 -- 4900
	self.bottleTargetY = 0 -- 4901
	self.bottleSurfaceY = -1 -- 4902
	self.bottleLandX = x -- 4903
	self.bottleLandY = y -- 4904
	self.bottleLandT = 0.9 -- 4905
	self:emit("bottleLanded", { -- 4906
		x = x, -- 4907
		y = y, -- 4908
		surface = surface, -- 4909
		heard = heard, -- 4910
		resonance = surface == "iron", -- 4911
		stallTicks = heard and stallTicks or 0, -- 4912
		scavState = self.scavState -- 4913
	}) -- 4913
	self:hearBottle(x, surface) -- 4915
end -- 4891
function Play.prototype.hearBottle(self, x, surface) -- 4919
	if surface == nil then -- 4919
		surface = "brick" -- 4919
	end -- 4919
	local s = self.room.scavenger -- 4920
	if s == nil then -- 4920
		return -- 4922
	end -- 4922
	if surface == "soft" then -- 4922
		self:flashSet("落在软土 · 没出声", 0.8) -- 4925
		return -- 4926
	end -- 4926
	local effRange = surface == "iron" and s.range * 1.25 or s.range -- 4928
	if math.abs(x - self.scavX) > effRange then -- 4928
		self:flashSet("落地 · 他没听见", 0.6) -- 4930
		return -- 4931
	end -- 4931
	self.scavState = "turn" -- 4933
	self.scavT = s.hearTicks -- 4934
	self.scavTargetX = surface == "iron" and self.room.basinX ~= nil and self.room.basinX or x -- 4935
	self.scavStallBonus = surface == "iron" and 90 or 0 -- 4936
	self:flashSet(surface == "iron" and "铁盆余振两响 · 他停下来细听" or "砖地一响 · 他转头", 1.1) -- 4937
end -- 4919
function Play.prototype.stepScav(self, dt, s) -- 4941
	if self.scavState == "chase" then -- 4941
		return -- 4944
	end -- 4944
	if self.scavState == "turn" then -- 4944
		self.scavT = self.scavT - 1 -- 4947
		if self.scavT <= 0 then -- 4947
			self.scavState = "walk" -- 4949
		end -- 4949
		return -- 4951
	end -- 4951
	if self.scavState == "walk" then -- 4951
		local d = self.scavTargetX - self.scavX -- 4954
		if math.abs(d) < 4 then -- 4954
			self.scavState = "stall" -- 4956
			self.scavT = s.stallTicks + self.scavStallBonus -- 4957
			self.scavStallBonus = 0 -- 4958
			return -- 4959
		end -- 4959
		self.scavX = self.scavX + (d > 0 and 1 or -1) * s.approachSpeed * dt -- 4961
		return -- 4962
	end -- 4962
	if self.scavState == "stall" then -- 4962
		self.scavT = self.scavT - 1 -- 4965
		if self.scavT <= 0 then -- 4965
			self.scavState = "back" -- 4967
		end -- 4967
		return -- 4969
	end -- 4969
	if self.scavState == "back" then -- 4969
		local home = math.max( -- 4972
			s.x0, -- 4972
			math.min(s.x1, self.scavX) -- 4972
		) -- 4972
		if math.abs(home - self.scavX) < 2 then -- 4972
			self.scavState = "patrol" -- 4974
			return -- 4975
		end -- 4975
		self.scavX = self.scavX + (home > self.scavX and 1 or -1) * s.approachSpeed * dt -- 4977
		return -- 4978
	end -- 4978
	self.scavX = self.scavX + self.scavDir * s.patrolSpeed * dt -- 4980
	if self.scavX >= s.x1 then -- 4980
		self.scavX = s.x1 -- 4982
		self.scavDir = -1 -- 4983
	elseif self.scavX <= s.x0 then -- 4983
		self.scavX = s.x0 -- 4985
		self.scavDir = 1 -- 4986
	end -- 4986
end -- 4941
function Play.prototype.stepCart(self, dt, input) -- 4994
	local p = self.player -- 4995
	local c = self.room.cart -- 4996
	if self.gripping then -- 4996
		if not input.interact.held then -- 4996
			self.gripping = false -- 5000
			self:flashSet("松开车把", 0.4) -- 5001
			return -- 5002
		end -- 5002
	else -- 5002
		if not input.interact.pressed then -- 5002
			return -- 5006
		end -- 5006
		if not self:cartHandleInReach(p) then -- 5006
			return -- 5009
		end -- 5009
		local track = c.depth or 0 -- 5011
		if self:limitDepth(p, track) ~= track then -- 5011
			return -- 5013
		end -- 5013
		p.depth = track -- 5015
		p.depthSpeed = 0 -- 5016
		self.gripping = true -- 5017
		self:flashSet("握住车把", 0.4) -- 5018
		return -- 5019
	end -- 5019
	if self.cartDocked then -- 5019
		return -- 5023
	end -- 5023
	local dir = input.moveX -- 5025
	if dir == 0 then -- 5025
		return -- 5027
	end -- 5027
	local lo = math.min(c.startX, c.endX) -- 5029
	local hi = math.max(c.startX, c.endX) -- 5030
	local next = self.cartAxle + dir * CART_SPEED * dt -- 5031
	if next < lo then -- 5031
		next = lo -- 5033
	end -- 5033
	if next > hi then -- 5033
		next = hi -- 5036
	end -- 5036
	local delta = next - self.cartAxle -- 5038
	if delta == 0 then -- 5038
		return -- 5040
	end -- 5040
	self.cartAxle = next -- 5042
	p.x = p.x + delta -- 5043
	p.facing = dir > 0 and 1 or -1 -- 5044
	self:slideX(p, 0) -- 5045
	if math.abs(p.x - (self.cartAxle + c.handleOffset)) > ____exports.CART_REACH then -- 5045
		self.gripping = false -- 5047
		self:flashSet("跟不上了，脱手", 0.6) -- 5048
		return -- 5049
	end -- 5049
	if math.abs(self.cartAxle - c.endX) < 0.01 then -- 5049
		self.cartDocked = true -- 5052
		self.gripping = false -- 5053
		self:emit("cartDocked", {axle = self.cartAxle, playerX = p.x, room = self.room.key}) -- 5054
		self:flashSet("车轮落窝", 1.2) -- 5055
	elseif math.abs(self.cartAxle - c.startX) < 0.01 then -- 5055
		self:flashSet("车轮回到起点", 0.5) -- 5057
	end -- 5057
end -- 4994
function Play.prototype.requestRoom(self, key, reason) -- 5065
	if self.wantRoom ~= "" then -- 5065
		return -- 5069
	end -- 5069
	self.wantRoom = key -- 5071
	self:emit("roomChange", {from = self.room.key, to = key, reason = reason}) -- 5072
end -- 5065
function Play.prototype.checkCarryGate(self) -- 5079
	if self.room.key == "checkpoint" then -- 5079
		if self.gateOpen and self.player.x >= self.ox + 900 then -- 5079
			self.carryCartAxle = self.cartAxle -- 5082
			self.carryCartDocked = self.cartDocked -- 5083
			self:requestRoom("gate", "检查站出口") -- 5084
			self:flashSet("出检查站 · 城门", 1.2) -- 5085
		end -- 5085
		return -- 5087
	end -- 5087
	if self.room.key == "outside" then -- 5087
		if self.checkpoint >= 380 and self.player.x >= WALL_ROAD_END then -- 5087
			self.carryCartAxle = self.cartAxle -- 5093
			self.carryCartDocked = self.cartDocked -- 5094
			self:requestRoom("village", "墙根走完") -- 5095
			self:flashSet("墙根走完 · 进村口", 1.2) -- 5096
		end -- 5096
	end -- 5096
end -- 5079
function Play.prototype.aimAt(self, wx, wy) -- 5103
	local s = ____exports.worldToScreen(wx, wy, self.cam, self.view) -- 5104
	self.aimX = s.x -- 5105
	self.aimY = s.y -- 5106
end -- 5103
function Play.prototype.shoot(self, a) -- 5109
	if self.isCampaign and self.reloadT > 0 then -- 5109
		self:flashSet("装填中 · 等枪机复位", 0.35) -- 5111
		return -- 5112
	end -- 5112
	local ox = a.x + a.facing * 8 -- 5114
	local muzzleY = a.y + a.h * 0.72 -- 5115
	local oy = muzzleY + a.depth * DEPTH_Y_SCALE -- 5116
	local aim = self.worldMapper ~= nil and self.worldMapper(self.aimX, self.aimY) or ____exports.screenToWorld(self.aimX, self.aimY, self.cam, self.view) -- 5118
	local dx = aim.x - ox -- 5121
	local dy = aim.y - oy -- 5122
	local len = math.sqrt(dx * dx + dy * dy) -- 5123
	if len < 0.001 then -- 5123
		dx = a.facing -- 5125
		dy = 0 -- 5126
	else -- 5126
		dx = dx / len -- 5128
		dy = dy / len -- 5129
	end -- 5129
	if dx ~= 0 then -- 5129
		a.facing = dx > 0 and 1 or -1 -- 5132
	end -- 5132
	local ray = {x = ox, y = oy, dx = dx, dy = dy} -- 5135
	local hitEnemy = self:raycastEnemies(ray) -- 5136
	local tEnemy = hitEnemy.t -- 5137
	local targetDepth = tEnemy > 0.001 and (self.enemies[hitEnemy.index + 1].depth or 0) or a.depth -- 5138
	local dDepth = tEnemy > 0.001 and (targetDepth - a.depth) / tEnemy or 0 -- 5139
	local solid = self:raycastSolid(__TS__ObjectAssign({}, ray, {y = muzzleY, dy = dy - dDepth * DEPTH_Y_SCALE, depth = a.depth, dDepth = dDepth})) -- 5140
	local tWall = solid.t -- 5141
	local rawEffect = self:consumeReloadEffect() -- 5143
	local weaponFx = weaponEffectOf(self.equippedWeapon) -- 5144
	local reloadEffect = rawEffect -- 5145
	local hit = tEnemy >= 0 and (tWall < 0 or tEnemy <= tWall or reloadEffect == "light") -- 5147
	local t = hit and tEnemy or (tWall >= 0 and tWall or 700) -- 5148
	self.trace = { -- 5150
		x0 = ox, -- 5150
		y0 = oy, -- 5150
		x1 = ox + dx * t, -- 5150
		y1 = oy + dy * t, -- 5150
		hit = hit -- 5150
	} -- 5150
	self.traceT = 0.12 -- 5151
	self:applyFireDanger(ox) -- 5152
	local killed = false -- 5153
	if hit then -- 5153
		local i = hitEnemy.index -- 5155
		local e = self.enemies[i + 1] -- 5156
		local impactY = oy + dy * tEnemy -- 5157
		local fromFront = a.x < e.x and dx > 0 or a.x > e.x and dx < 0 -- 5158
		local shieldTop = e.y + (e.depth or 0) * DEPTH_Y_SCALE + 64 -- 5159
		if e.kind == "shield" and (e.shieldHp or 0) > 0 and fromFront and impactY <= shieldTop then -- 5159
			local pushRank = self:talentRank("push_force") -- 5161
			local dmg = reloadEffect == "push" and 2 + pushRank or 1 -- 5162
			e.shieldHp = math.max(0, (e.shieldHp or 0) - dmg) -- 5163
			e.hitT = 0.3 -- 5164
			if reloadEffect == "push" then -- 5164
				local kb = 46 + 24 * pushRank -- 5166
				e.x = math.max( -- 5167
					self.room.minX + 20, -- 5167
					math.min(self.room.maxX - 20, e.x + a.facing * kb) -- 5167
				) -- 5167
				if pushRank > 0 then -- 5167
					self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5169
				end -- 5169
				self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5171
				self:flashSet(e.shieldHp <= 0 and "推退破盾！" or "推退震退持盾手", 0.9) -- 5172
			else -- 5172
				self:flashSet( -- 5174
					(("盾面挡下 · 盾 " .. tostring(e.shieldHp)) .. "/") .. tostring(e.shieldHpMax or 2), -- 5174
					0.8 -- 5174
				) -- 5174
			end -- 5174
			self:emit("shotResolved", { -- 5176
				hit = true, -- 5177
				enemyIndex = i, -- 5177
				enemyX = e.x, -- 5177
				aimX = aim.x, -- 5177
				aimY = aim.y, -- 5177
				impactX = ox + dx * t, -- 5178
				impactY = oy + dy * t, -- 5178
				shield = true -- 5178
			}) -- 5178
			self:beginReload() -- 5180
			return -- 5181
		end -- 5181
		e.alive = false -- 5183
		e.hitT = 0.4 -- 5184
		killed = true -- 5185
		self:flashSet("命中", 0.6) -- 5186
		self:dropFor(e) -- 5187
		local lpRank = self:talentRank("lantern_pierce") -- 5188
		if reloadEffect == "light" and (weaponFx == "light" or lpRank > 0) then -- 5188
			local blindRadius = (weaponFx == "light" and 160 or 110) + 50 * lpRank -- 5190
			self:blindNearby(e, blindRadius, i) -- 5191
		end -- 5191
		if reloadEffect == "push" then -- 5191
			local pushRank = self:talentRank("push_force") -- 5194
			e.x = e.x + a.facing * (46 + 24 * pushRank) -- 5195
			if pushRank > 0 then -- 5195
				self:staggerNearby(e, 140 + 30 * pushRank, 90 + 30 * pushRank, i) -- 5197
			end -- 5197
			self:emit("reloadApplied", {effect = "push", weapon = self.equippedWeapon, enemyX = e.x}) -- 5199
		elseif reloadEffect == "echo" then -- 5199
			local echoRank = self:talentRank("echo_wide") -- 5201
			self:echoToSource(a, (weaponFx == "echo" and 2 or 1) + echoRank, 60 + 30 * echoRank) -- 5202
			self:emit("reloadApplied", {effect = "echo", weapon = self.equippedWeapon, enemyX = e.x}) -- 5203
		elseif reloadEffect == "light" then -- 5203
			self:emit("reloadApplied", {effect = "light", weapon = self.equippedWeapon, enemyX = e.x}) -- 5205
		end -- 5205
	elseif solid.box ~= nil and solid.box.breakable ~= nil then -- 5205
		self:damageProp(solid.box, 1) -- 5208
	else -- 5208
		self:flashSet("打空", 0.35) -- 5210
	end -- 5210
	if self.isCampaign then -- 5210
		self:beginReload() -- 5213
	end -- 5213
	self:emit("shotResolved", { -- 5215
		hit = hit, -- 5216
		enemyIndex = hit and hitEnemy.index or -1, -- 5217
		enemyX = hit and self.enemies[hitEnemy.index + 1].x or -1, -- 5218
		aimX = aim.x, -- 5219
		aimY = aim.y, -- 5220
		impactX = ox + dx * t, -- 5221
		impactY = oy + dy * t -- 5222
	}) -- 5222
end -- 5109
function Play.prototype.staggerNearby(self, center, radius, delayTicks, skipIndex) -- 5227
	local i = 0 -- 5228
	do -- 5228
		i = 0 -- 5229
		while i < #self.enemies do -- 5229
			do -- 5229
				if i == skipIndex then -- 5229
					goto __continue874 -- 5231
				end -- 5231
				local e = self.enemies[i + 1] -- 5233
				if not e.alive or math.abs(e.x - center.x) > radius then -- 5233
					goto __continue874 -- 5235
				end -- 5235
				e.warnT = 0 -- 5237
				e.fireCd = math.max(e.fireCd or 0, delayTicks) -- 5238
				local pushDir = e.x >= center.x and 1 or -1 -- 5239
				e.x = math.max( -- 5240
					self.room.minX + 20, -- 5240
					math.min(self.room.maxX - 20, e.x + pushDir * 22) -- 5240
				) -- 5240
			end -- 5240
			::__continue874:: -- 5240
			i = i + 1 -- 5229
		end -- 5229
	end -- 5229
end -- 5227
function Play.prototype.applyFireDanger(self, shotX) -- 5245
	local ____temp_139 = self.isCampaign and self.run.joined -- 5246
	if ____temp_139 then -- 5246
		local ____opt_134 = self.room.campaign -- 5246
		local ____temp_138 = (____opt_134 and ____opt_134.chapter) == "S" -- 5247
		if not ____temp_138 then -- 5247
			local ____opt_136 = self.room.campaign -- 5247
			____temp_138 = (____opt_136 and ____opt_136.chapter) == "C" -- 5247
		end -- 5247
		____temp_139 = ____temp_138 -- 5246
	end -- 5246
	local isStorySc = ____temp_139 -- 5246
	if self.room.key ~= "checkpoint" and not isStorySc or not self.partner.alive then -- 5246
		return -- 5249
	end -- 5249
	local dangerX = shotX -- 5251
	local best = -1 -- 5252
	local bestD = 1000000000 -- 5253
	local i = 0 -- 5254
	do -- 5254
		i = 0 -- 5255
		while i < #self.enemies do -- 5255
			do -- 5255
				local e = self.enemies[i + 1] -- 5256
				if not e.alive then -- 5256
					goto __continue880 -- 5258
				end -- 5258
				local d = math.abs(e.x - self.partner.x) -- 5260
				if d < bestD then -- 5260
					bestD = d -- 5262
					best = i -- 5263
				end -- 5263
			end -- 5263
			::__continue880:: -- 5263
			i = i + 1 -- 5255
		end -- 5255
	end -- 5255
	if best >= 0 then -- 5255
		dangerX = self.enemies[best + 1].x -- 5267
	end -- 5267
	if isStorySc and math.abs(dangerX - self.partner.x) > 260 then -- 5267
		return -- 5271
	end -- 5271
	local exposed = self:childExposed(dangerX) -- 5273
	local before = self.escort.fear -- 5274
	local dangerId = self.nextDangerId -- 5275
	local after = self.escort:applyDanger(dangerId, exposed, self.partner.x) -- 5276
	self.nextDangerId = self.nextDangerId + 1 -- 5277
	self:emit("fearChanged", {fear = after, max = FEAR_MAX, exposed = exposed, dangerId = dangerId}) -- 5278
	if after > before then -- 5278
		self:flashSet( -- 5280
			(("小满受惊 " .. tostring(after)) .. "/") .. tostring(FEAR_MAX), -- 5280
			1 -- 5280
		) -- 5280
	elseif not exposed then -- 5280
		self:flashSet("枪声没够到她", 0.5) -- 5282
	end -- 5282
end -- 5245
function Play.prototype.childExposed(self, dangerX) -- 5287
	local c = self.partner -- 5288
	if not c.alive then -- 5288
		return false -- 5290
	end -- 5290
	if c.x > self.ox + 240 and c.x < self.ox + 340 and __TS__ArraySome( -- 5290
		self.boxes, -- 5293
		function(____, b) return b.x0 == self.ox + 240 and overlapsDepth(c.depth, b.depth, ACTOR_DEPTH_HALF) end -- 5293
	) then -- 5293
		return false -- 5294
	end -- 5294
	if c.x < self.ox + 380 or c.x > self.ox + 560 then -- 5294
		return false -- 5297
	end -- 5297
	local toDanger = dangerX - c.x -- 5299
	local toPlayer = self.player.x - c.x -- 5300
	if toDanger * toPlayer > 0 and math.abs(toPlayer) < math.abs(toDanger) and inReachDepth(self.player.depth, c.depth) then -- 5300
		return false -- 5303
	end -- 5303
	return true -- 5305
end -- 5287
function Play.prototype.raycastEnemies(self, ray) -- 5309
	local best = -1 -- 5310
	local bestI = -1 -- 5311
	do -- 5311
		local i = 0 -- 5312
		while i < #self.enemies do -- 5312
			do -- 5312
				local e = self.enemies[i + 1] -- 5313
				if not e.alive then -- 5313
					goto __continue895 -- 5315
				end -- 5315
				local y = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 5317
				local t = hitBox(ray, {x0 = e.x - e.w / 2, x1 = e.x + e.w / 2, y0 = y, y1 = y + e.h}) -- 5318
				if t >= 0 and (best < 0 or t < best) then -- 5318
					best = t -- 5320
					bestI = i -- 5321
				end -- 5321
			end -- 5321
			::__continue895:: -- 5321
			i = i + 1 -- 5312
		end -- 5312
	end -- 5312
	return {t = best, index = bestI} -- 5324
end -- 5309
function Play.prototype.raycastWorld(self, ray) -- 5327
	return self:raycastSolid(ray).t -- 5328
end -- 5327
function Play.prototype.raycastSolid(self, ray) -- 5332
	local best = -1 -- 5333
	local bestBox = nil -- 5334
	for ____, box in ipairs(self.boxes) do -- 5335
		do -- 5335
			if box.broken == true or box.hidden == true then -- 5335
				goto __continue900 -- 5337
			end -- 5337
			local t = hitBox(ray, box) -- 5342
			if t > 2 and (best < 0 or t < best) then -- 5342
				best = t -- 5345
				bestBox = box -- 5346
			end -- 5346
		end -- 5346
		::__continue900:: -- 5346
	end -- 5346
	if ray.dy < 0 then -- 5346
		local t = -ray.y / ray.dy -- 5350
		if t >= 0 and (best < 0 or t < best) then -- 5350
			best = t -- 5352
			bestBox = nil -- 5353
		end -- 5353
	end -- 5353
	return {t = best, box = bestBox} -- 5356
end -- 5332
function Play.prototype.dropFor(self, e) -- 5360
	if not self.isCampaign or e.drop == nil or e.drop == "none" then -- 5360
		return -- 5362
	end -- 5362
	if e.drop == "shield" and (e.shieldHp or 0) <= 0 then -- 5362
		return -- 5365
	end -- 5365
	local label = e.drop == "shield" and "残盾" or (e.drop == "wedge" and "木楔" or (e.drop == "ammo" and "备用弹包" or e.drop)) -- 5367
	local ____self_pickups_140 = self.pickups -- 5367
	____self_pickups_140[#____self_pickups_140 + 1] = { -- 5368
		id = (self.room.key .. "_drop_") .. tostring(e.squad or 0), -- 5369
		kind = e.drop, -- 5369
		x = e.x, -- 5369
		y = e.y, -- 5369
		depth = e.depth, -- 5370
		label = label .. " ×1" -- 5370
	} -- 5370
	self:log("掉落 " .. label) -- 5372
end -- 5360
function Play.prototype.damageProp(self, b, amount) -- 5376
	if b.breakable == nil or b.broken == true then -- 5376
		return -- 5378
	end -- 5378
	local ____b_breakable_141, ____hp_142 = b.breakable, "hp" -- 5378
	____b_breakable_141[____hp_142] = ____b_breakable_141[____hp_142] - amount -- 5380
	if b.breakable.hp > 0 then -- 5380
		self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡裂开 · 再一下" or "围挡松了 · 再一下", 0.9) -- 5382
		self:emit("propBroken", {id = b.id or "", phase = "crack", hp = b.breakable.hp, x = b.x0}) -- 5383
		return -- 5384
	end -- 5384
	b.broken = true -- 5386
	for ____, other in ipairs(self.boxes) do -- 5387
		if other.id ~= nil and other.id == b.id then -- 5387
			other.broken = true -- 5389
		end -- 5389
	end -- 5389
	self.run.props[b.id or ""] = {broken = true, hp = 0, wedge = false} -- 5392
	self:flashSet(b.breakable.kind == "thin_wood" and "薄木挡碎了 · 通路打开" or "空筐散了 · 短口打开", 1.2) -- 5393
	self:log((("破坏 " .. (b.id or "")) .. " ") .. b.breakable.kind) -- 5394
	self:emit("propBroken", {id = b.id or "", phase = "broken", hp = 0, x = b.x0}) -- 5395
end -- 5376
function Play.prototype.slideDepth(self, a, distance) -- 5399
	a.depth = self:limitDepth(a, a.depth + distance) -- 5400
end -- 5399
function Play.prototype.limitDepth(self, a, target) -- 5403
	local road = self.room.depth -- 5404
	if road == nil or target == a.depth then -- 5404
		return a.depth -- 5406
	end -- 5406
	local next = math.max( -- 5408
		road.min, -- 5408
		math.min(road.max, target) -- 5408
	) -- 5408
	local half = a.w / 2 -- 5409
	for ____, b in ipairs(self.boxes) do -- 5410
		do -- 5410
			local footprint = b.depth -- 5411
			if footprint == nil or b.passable == true or b.broken == true or b.hidden == true or b.soft == true or a.x + half <= b.x0 or a.x - half >= b.x1 or a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5411
				goto __continue918 -- 5416
			end -- 5416
			local front = footprint.min - ACTOR_DEPTH_HALF -- 5418
			local back = footprint.max + ACTOR_DEPTH_HALF -- 5419
			if a.depth <= front and next > front then -- 5419
				next = front -- 5421
			elseif a.depth >= back and next < back then -- 5421
				next = back -- 5423
			end -- 5423
		end -- 5423
		::__continue918:: -- 5423
	end -- 5423
	return next -- 5426
end -- 5403
function Play.prototype.cartLatchBounds(self) -- 5430
	if self.room.key ~= "outside" or self.cartDocked then -- 5430
		return nil -- 5431
	end -- 5431
	local arch = self.room.arch -- 5432
	local halfWidth = self.room.cart.bodyW / 2 -- 5433
	local left = math.max(arch.x0, self.cartAxle - halfWidth) -- 5434
	local right = math.min(arch.x1, self.cartAxle + halfWidth) -- 5435
	return right > left and Rect(left, arch.y, right - left, arch.h) or nil -- 5436
end -- 5430
function Play.prototype.slideX(self, a, dx) -- 5440
	local nx = a.x + dx -- 5441
	local half = a.w / 2 -- 5442
	local room = self.room -- 5443
	nx = math.max( -- 5444
		room.minX + half, -- 5444
		math.min(room.maxX - half, nx) -- 5444
	) -- 5444
	local i = 0 -- 5445
	do -- 5445
		i = 0 -- 5446
		while i < #self.boxes do -- 5446
			do -- 5446
				local b = self.boxes[i + 1] -- 5447
				if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5447
					goto __continue927 -- 5449
				end -- 5449
				if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5449
					goto __continue927 -- 5452
				end -- 5452
				if a.y + a.h <= b.y0 + 0.001 or a.y >= b.y1 - 0.001 then -- 5452
					goto __continue927 -- 5455
				end -- 5455
				if nx + half > b.x0 and nx - half < b.x1 then -- 5455
					if a.x <= b.x0 then -- 5455
						nx = b.x0 - half -- 5459
					elseif a.x >= b.x1 then -- 5459
						nx = b.x1 + half -- 5461
					else -- 5461
						nx = a.x -- 5463
					end -- 5463
				end -- 5463
			end -- 5463
			::__continue927:: -- 5463
			i = i + 1 -- 5446
		end -- 5446
	end -- 5446
	local latch = self:cartLatchBounds() -- 5467
	if latch ~= nil and a.y < latch.y + latch.height - 0.001 and nx + half > latch.x and nx - half < latch.x + latch.width then -- 5467
		if a.x <= latch.x then -- 5467
			nx = latch.x - half -- 5471
		elseif a.x >= latch.x + latch.width then -- 5471
			nx = latch.x + latch.width + half -- 5473
		else -- 5473
			nx = a.x -- 5475
		end -- 5475
	end -- 5475
	local arch = room.arch -- 5482
	if arch.h > 0 and a.y < arch.y + arch.h - 0.001 and a.y + a.h > arch.y + arch.h + 0.001 then -- 5482
		local insideNow = a.x > arch.x0 and a.x < arch.x1 -- 5484
		if not insideNow and nx + half > arch.x0 and nx - half < arch.x1 then -- 5484
			if a.x <= arch.x0 then -- 5484
				nx = arch.x0 - half -- 5487
			elseif a.x >= arch.x1 then -- 5487
				nx = arch.x1 + half -- 5489
			end -- 5489
		end -- 5489
	end -- 5489
	a.x = nx -- 5493
end -- 5440
function Play.prototype.fallY(self, a, dt) -- 5497
	a.vy = a.vy - ____exports.GRAVITY * dt -- 5498
	if a.vy < -900 then -- 5498
		a.vy = -900 -- 5500
	end -- 5500
	local ny = a.y + a.vy * dt -- 5502
	local half = a.w / 2 -- 5503
	if a.vy <= 0 then -- 5503
		local reach = a.onGround and not a.crouch and STEP_UP or 0 -- 5506
		local ground = self:groundAt(a.x, a.y + 0.5 + reach, half, a.depth) -- 5507
		if ny <= ground then -- 5507
			ny = ground -- 5509
			a.vy = 0 -- 5510
			a.onGround = true -- 5511
		else -- 5511
			a.onGround = false -- 5513
		end -- 5513
	else -- 5513
		a.onGround = false -- 5516
		local i = 0 -- 5517
		do -- 5517
			i = 0 -- 5518
			while i < #self.boxes do -- 5518
				do -- 5518
					local b = self.boxes[i + 1] -- 5519
					if b.passable == true or b.broken == true or b.hidden == true or b.soft == true then -- 5519
						goto __continue950 -- 5521
					end -- 5521
					if not overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF) then -- 5521
						goto __continue950 -- 5524
					end -- 5524
					if a.x + half <= b.x0 or a.x - half >= b.x1 then -- 5524
						goto __continue950 -- 5527
					end -- 5527
					if b.y0 >= a.y + a.h - 0.5 and ny + a.h > b.y0 then -- 5527
						ny = b.y0 - a.h -- 5530
						a.vy = 0 -- 5531
					end -- 5531
				end -- 5531
				::__continue950:: -- 5531
				i = i + 1 -- 5518
			end -- 5518
		end -- 5518
	end -- 5518
	a.y = ny -- 5535
end -- 5497
function Play.prototype.groundAt(self, x, ceiling, half, depth) -- 5539
	if depth == nil then -- 5539
		depth = 0 -- 5539
	end -- 5539
	local g = -9999 -- 5540
	local i = 0 -- 5541
	do -- 5541
		i = 0 -- 5542
		while i < #self.floors do -- 5542
			local f = self.floors[i + 1] -- 5543
			if x + half > f.x0 and x - half < f.x1 and f.y1 <= ceiling and f.y1 > g then -- 5543
				g = f.y1 -- 5545
			end -- 5545
			i = i + 1 -- 5542
		end -- 5542
	end -- 5542
	do -- 5542
		i = 0 -- 5548
		while i < #self.boxes do -- 5548
			do -- 5548
				local b = self.boxes[i + 1] -- 5549
				if b.broken == true or b.hidden == true or b.soft == true then -- 5549
					goto __continue960 -- 5551
				end -- 5551
				if x + half > b.x0 and x - half < b.x1 and b.y1 <= ceiling and b.y1 > g and overlapsDepth(depth, b.depth, ACTOR_DEPTH_HALF) then -- 5551
					g = b.y1 -- 5555
				end -- 5555
			end -- 5555
			::__continue960:: -- 5555
			i = i + 1 -- 5548
		end -- 5548
	end -- 5548
	return g -- 5558
end -- 5539
function Play.prototype.updateCamera(self, dt) -- 5561
	local p = self.player -- 5562
	local tx = p.x + p.facing * 30 -- 5563
	local ty = p.y + CAM_LOOK_UP -- 5564
	local k = math.min(1, CAM_FOLLOW * dt) -- 5565
	self.cam.x = self.cam.x + (tx - self.cam.x) * k -- 5566
	self.cam.y = self.cam.y + (ty - self.cam.y) * k -- 5567
end -- 5561
function Play.prototype.clampCamera(self, w, h) -- 5571
	local room = self.room -- 5572
	local halfW = ____exports.LOGIC_W * ____exports.UNITS_PER_PX / 2 -- 5573
	local spanX = room.maxX - room.minX -- 5574
	if spanX <= halfW * 2 then -- 5574
		self.cam.x = (room.minX + room.maxX) / 2 -- 5576
	else -- 5576
		self.cam.x = math.max( -- 5578
			room.minX + halfW, -- 5578
			math.min(room.maxX - halfW, self.cam.x) -- 5578
		) -- 5578
	end -- 5578
	local camY = (____exports.LOGIC_H / 2 - GROUND_PX) * ____exports.UNITS_PER_PX -- 5581
	local spanY = room.height -- 5582
	local halfH = ____exports.LOGIC_H * ____exports.UNITS_PER_PX / 2 -- 5583
	if spanY <= halfH * 2 then -- 5583
		self.cam.y = camY -- 5585
	else -- 5585
		self.cam.y = math.max( -- 5587
			camY, -- 5587
			math.min(camY + (spanY - halfH * 2), self.cam.y) -- 5587
		) -- 5587
	end -- 5587
end -- 5571
function Play.prototype.flashSet(self, text, t) -- 5591
	self.flash = text -- 5592
	self.flashT = t -- 5593
end -- 5591
function Play.prototype.statusText(self) -- 5597
	local p = self.player -- 5598
	local parts = {} -- 5599
	local who = self.childMode and "小满" or "周戍" -- 5600
	parts[#parts + 1] = (((who .. " x=") .. tostring(math.floor(p.x + 0.5))) .. " y=") .. tostring(math.floor(p.y + 0.5)) -- 5601
	if self.room.key == "prologue" then -- 5601
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5604
		if self.phase == "prologue-wake" then -- 5604
			parts[#parts + 1] = (("叫醒 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_WAKE_TICKS) -- 5606
		elseif self.phase == "prologue-shadow" then -- 5606
			parts[#parts + 1] = (("墙影 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_SHADOW_TICKS) -- 5608
		elseif self.phase == "prologue-escape" then -- 5608
			parts[#parts + 1] = ("逃柜 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. "s" -- 5610
		elseif self.phase == "prologue-hide" then -- 5610
			parts[#parts + 1] = (("入柜 " .. tostring(self.introTick)) .. "/") .. tostring(____exports.PROLOGUE_HIDE_TICKS) -- 5612
		elseif self.phase == "prologue-wait" then -- 5612
			parts[#parts + 1] = "待递 " .. tostring(math.floor(math.abs(p.x - self.partner.x) + 0.5)) -- 5614
		elseif self.phase == "prologue-give" then -- 5614
			parts[#parts + 1] = (("递物 " .. tostring(self.phaseTick)) .. "/") .. tostring(____exports.PROLOGUE_GIVE_TICKS) -- 5616
		else -- 5616
			parts[#parts + 1] = "跟随" -- 5618
		end -- 5618
		if self.paused then -- 5618
			parts[#parts + 1] = "已暂停" -- 5621
		end -- 5621
		return table.concat(parts, " · ") -- 5623
	end -- 5623
	if self.room.key == "street" then -- 5623
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5626
		parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5627
		if self.paused then -- 5627
			parts[#parts + 1] = "已暂停" -- 5629
		end -- 5629
		return table.concat(parts, " · ") -- 5631
	end -- 5631
	if self.room.key == "gate" then -- 5631
		local ____temp_143 -- 5634
		if self.room.story == nil then -- 5634
			____temp_143 = nil -- 5634
		else -- 5634
			____temp_143 = self.room.story.gate -- 5634
		end -- 5634
		local g = ____temp_143 -- 5634
		if g ~= nil then -- 5634
			parts[#parts + 1] = self:gateLabel() -- 5636
			parts[#parts + 1] = ((((("守点 " .. tostring(self.gateTick)) .. "/") .. tostring(g.holdTicks)) .. " · 剩 ") .. tostring(math.max( -- 5637
				0, -- 5638
				math.ceil((g.holdTicks - self.gateTick) / 60) -- 5638
			))) .. " 秒" -- 5638
			parts[#parts + 1] = "小满 " .. tostring(math.floor(self.partner.x + 0.5)) -- 5639
			parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5640
			parts[#parts + 1] = (("血 " .. tostring(math.max(0, self.hp))) .. "/") .. tostring(self.maxHp) -- 5641
			parts[#parts + 1] = self.coverHug and "掩体 已贴住" or (self.coverNear and "掩体 可贴·按 Shift" or "掩体 无") -- 5642
			if self.gateFailCount > 0 then -- 5642
				parts[#parts + 1] = "倒 " .. tostring(self.gateFailCount) -- 5644
			end -- 5644
			if self.flash ~= "" then -- 5644
				parts[#parts + 1] = self.flash -- 5647
			end -- 5647
		end -- 5647
		if self.paused then -- 5647
			parts[#parts + 1] = "已暂停" -- 5651
		end -- 5651
		return table.concat(parts, " · ") -- 5653
	end -- 5653
	if self.room.key == "forest" then -- 5653
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5656
		parts[#parts + 1] = (("狗 " .. self:dogLabel()) .. " @") .. tostring(math.floor(self.dogX + 0.5)) -- 5657
		parts[#parts + 1] = "距 " .. tostring(math.floor(math.abs(p.x - self.dogX) + 0.5)) -- 5658
		if self.caughtT > 0 then -- 5658
			parts[#parts + 1] = "复位中" -- 5660
		end -- 5660
		if self.paused then -- 5660
			parts[#parts + 1] = "已暂停" -- 5663
		end -- 5663
		return table.concat(parts, " · ") -- 5665
	end -- 5665
	if self.room.key == "tower" then -- 5665
		if self.phase == "tower-wait" then -- 5665
			parts[#parts + 1] = "门前 " .. tostring(math.floor(math.abs(p.x - self:doorXOf()) + 0.5)) -- 5669
		elseif self.phase == "tower-knock" then -- 5669
			parts[#parts + 1] = ("敲 " .. tostring(self.phaseTick)) .. " 拍" -- 5671
		elseif self.phase == "tower-enter" then -- 5671
			parts[#parts + 1] = "跨门槛 " .. tostring(math.floor(p.x - (self.ox + TOWER_THRESHOLD_X) + 0.5)) -- 5673
		elseif self.phase == "tower-desk" then -- 5673
			parts[#parts + 1] = (("交物 " .. tostring(self.deskHold)) .. "/") .. tostring(TOWER_HANDOVER_TICKS) -- 5675
		elseif self.phase == "tower-given" then -- 5675
			parts[#parts + 1] = "递交 " .. tostring(self.phaseTick) -- 5677
		else -- 5677
			parts[#parts + 1] = "片尾" -- 5679
		end -- 5679
		if self.paused then -- 5679
			parts[#parts + 1] = "已暂停" -- 5682
		end -- 5682
		return table.concat(parts, " · ") -- 5684
	end -- 5684
	if self.room.key == "village" then -- 5684
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5687
		if self.hasBottle then -- 5687
			parts[#parts + 1] = "有瓶" -- 5689
		elseif self.bottleFly ~= nil then -- 5689
			parts[#parts + 1] = "瓶在飞" -- 5691
		else -- 5691
			parts[#parts + 1] = "空手" -- 5693
		end -- 5693
		parts[#parts + 1] = (("拾荒者 " .. self:scavLabel()) .. " @") .. tostring(math.floor(self.scavX + 0.5)) -- 5695
		if self.scavChase then -- 5695
			parts[#parts + 1] = "追 " .. tostring(self.scavSee) -- 5697
		end -- 5697
		if self.passed then -- 5697
			parts[#parts + 1] = "已过通行线" -- 5700
		end -- 5700
		if self.paused then -- 5700
			parts[#parts + 1] = "已暂停" -- 5703
		end -- 5703
		return table.concat(parts, " · ") -- 5705
	end -- 5705
	local isChild = self.childMode -- 5708
	if isChild then -- 5708
		parts[#parts + 1] = p.crouch and "蹲" or "站" -- 5710
		parts[#parts + 1] = "高 " .. tostring(math.floor(p.h + 0.5)) -- 5711
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5712
	else -- 5712
		parts[#parts + 1] = p.covered and "贴掩体" or "无掩体" -- 5714
		if p.rollT > 0 then -- 5714
			parts[#parts + 1] = "翻滚中" -- 5716
		end -- 5716
		parts[#parts + 1] = (("敌 " .. tostring(self:aliveEnemies())) .. "/") .. tostring(#self.enemies) -- 5718
		parts[#parts + 1] = "车轴 " .. tostring(math.floor(self.cartAxle + 0.5)) -- 5719
		parts[#parts + 1] = self.gateOpen and "出口开" or "出口关" -- 5720
		parts[#parts + 1] = (("恐惧 " .. tostring(self.escort.fear)) .. "/") .. tostring(FEAR_MAX) -- 5721
	end -- 5721
	if self.checkpoint >= 0 then -- 5721
		parts[#parts + 1] = "检查点 " .. tostring(math.floor(self.checkpoint + 0.5)) -- 5724
	end -- 5724
	if self.paused then -- 5724
		parts[#parts + 1] = "已暂停" -- 5727
	end -- 5727
	return table.concat(parts, " · ") -- 5729
end -- 5597
function Play.prototype.aliveEnemies(self) -- 5733
	local n = 0 -- 5734
	local i = 0 -- 5735
	do -- 5735
		i = 0 -- 5736
		while i < #self.enemies do -- 5736
			if self.enemies[i + 1].alive then -- 5736
				n = n + 1 -- 5738
			end -- 5738
			i = i + 1 -- 5736
		end -- 5736
	end -- 5736
	return n -- 5741
end -- 5733
function Play.prototype.threatened(self) -- 5746
	do -- 5746
		local i = 0 -- 5747
		while i < #self.enemies do -- 5747
			local e = self.enemies[i + 1] -- 5748
			if e.alive and e.warnT > 0 then -- 5748
				return true -- 5750
			end -- 5750
			i = i + 1 -- 5747
		end -- 5747
	end -- 5747
	return false -- 5753
end -- 5746
function Play.prototype.gateSecondsLeft(self) -- 5756
	local ____temp_144 -- 5757
	if self.room.story == nil then -- 5757
		____temp_144 = nil -- 5757
	else -- 5757
		____temp_144 = self.room.story.gate -- 5757
	end -- 5757
	local g = ____temp_144 -- 5757
	if g == nil then -- 5757
		return 0 -- 5759
	end -- 5759
	return math.max( -- 5761
		0, -- 5761
		math.ceil((g.holdTicks - self.gateTick) / 60) -- 5761
	) -- 5761
end -- 5756
function Play.prototype.gateLabel(self) -- 5764
	if self.phase == "gate-idle" then -- 5764
		return "待就位" -- 5766
	end -- 5766
	if self.phase == "gate-hold" then -- 5766
		return "守点中" -- 5769
	end -- 5769
	if self.phase == "gate-send" then -- 5769
		return "送别" -- 5772
	end -- 5772
	if self.phase == "gate-farewell" then -- 5772
		return "嘱咐 " .. tostring(self.phaseTick) -- 5775
	end -- 5775
	if self.phase == "gate-count" then -- 5775
		return "数数 " .. tostring(self.countTick) -- 5778
	end -- 5778
	return "她走" -- 5780
end -- 5764
function Play.prototype.dogLabel(self) -- 5784
	if self.dogState == "ear" then -- 5784
		return "转耳" -- 5786
	end -- 5786
	if self.dogState == "chase" then -- 5786
		return "追" -- 5789
	end -- 5789
	if self.dogState == "sniff" then -- 5789
		return "停" -- 5792
	end -- 5792
	if self.dogState == "back" then -- 5792
		return "回线" -- 5795
	end -- 5795
	return "巡逻" -- 5797
end -- 5784
function Play.prototype.doorXOf(self) -- 5800
	local ____temp_145 -- 5801
	if self.room.story == nil then -- 5801
		____temp_145 = nil -- 5801
	else -- 5801
		____temp_145 = self.room.story.tower -- 5801
	end -- 5801
	local t = ____temp_145 -- 5801
	return t == nil and 0 or t.doorX -- 5802
end -- 5800
function Play.prototype.scavLabel(self) -- 5806
	if self.scavState == "chase" then -- 5806
		return "追" -- 5808
	end -- 5808
	if self.scavState == "turn" then -- 5808
		return "转头" -- 5811
	end -- 5811
	if self.scavState == "walk" then -- 5811
		return "赶来" -- 5814
	end -- 5814
	if self.scavState == "stall" then -- 5814
		return "停住" -- 5817
	end -- 5817
	if self.scavState == "back" then -- 5817
		return "回位" -- 5820
	end -- 5820
	return "巡逻" -- 5822
end -- 5806
function Play.prototype.hintText(self) -- 5826
	if self.paused then -- 5826
		return "Esc 继续 · R 重置" -- 5828
	end -- 5828
	if self.room.key == "gate" and self.phase == "gate-hold" and not self.paused then -- 5828
		if self:threatened() then -- 5828
			return "敌兵举枪（红线）· 贴住街垒 520 按 Shift，或 F 打掉他" -- 5834
		end -- 5834
		if self.coverHug then -- 5834
			return ("掩体中 · F 射击 · 守点剩 " .. tostring(self:gateSecondsLeft())) .. " 秒" -- 5837
		end -- 5837
		if self.coverNear then -- 5837
			return "贴住了，按住 Shift 才挡枪 · F 射击" -- 5840
		end -- 5840
		return "到街垒左侧 505 贴住（空地挡不住）· F 射击 · 守满 45 秒" -- 5842
	end -- 5842
	if self.flash ~= "" then -- 5842
		return self.flash -- 5845
	end -- 5845
	if self.room.key == "prologue" then -- 5845
		if self.phase == "prologue-wake" then -- 5845
			return "父亲在门外唤 · 小满睁眼" -- 5849
		end -- 5849
		if self.phase == "prologue-shadow" then -- 5849
			return "墙上两道人影 · 碗滚到脚边" -- 5852
		end -- 5852
		if self.phase == "prologue-escape" then -- 5852
			return ("按 ↑ 贴里道、再按 D 跑向倒柜 · 剩 " .. __TS__NumberToFixed(self.escapeRemaining, 1)) .. " 秒" -- 5855
		end -- 5855
		if self.phase == "prologue-hide" then -- 5855
			return "柜门合上 · 屏住呼吸" -- 5858
		end -- 5858
		if self.phase == "prologue-wait" then -- 5858
			local near = math.abs(self.player.x - self.partner.x) <= 46 -- 5861
			return near and "点 E 递出针套 · 纸条一起塞进去" or "走到倒柜后的小满身边（x≈214）再点 E" -- 5862
		end -- 5862
		if self.phase == "prologue-give" then -- 5862
			return ((("递物 " .. tostring(self.phaseTick)) .. " / ") .. tostring(____exports.PROLOGUE_GIVE_TICKS)) .. " 拍 · 站着别动" -- 5865
		end -- 5865
		return "她跟着你了 · 两人一起走到门口 680" -- 5867
	end -- 5867
	if self.room.key == "street" then -- 5867
		if self:aliveEnemies() > 0 then -- 5867
			return "左键点射清街心敌兵 · A / D 走，空格贴柜台翻上去" -- 5871
		end -- 5871
		return "清完了 · 两人一起走到右边检查站入口 900" -- 5873
	end -- 5873
	if self.room.key == "gate" then -- 5873
		local ____temp_146 -- 5876
		if self.room.story == nil then -- 5876
			____temp_146 = nil -- 5876
		else -- 5876
			____temp_146 = self.room.story.gate -- 5876
		end -- 5876
		local g = ____temp_146 -- 5876
		if g ~= nil then -- 5876
			if self.phase == "gate-idle" then -- 5876
				if self.gateNeedConfirm then -- 5876
					return "回到绞盘 118 按 E 重新就位 · 这一轮从 0 秒重算" -- 5880
				end -- 5880
				return "小满到门洞 960、周戍贴住绞盘 118，两人就位才开始守点" -- 5882
			end -- 5882
			if self.phase == "gate-hold" then -- 5882
				if self.coveredFlash > 0 then -- 5882
					return "掩体挡下了这一枪 · 别露头" -- 5886
				end -- 5886
				return "红灯是预警 · 贴住街垒/柜台再按 Shift 才挡枪 · F 射击 · 守满去门边 860 按 E" -- 5888
			end -- 5888
			if self.phase == "gate-send" then -- 5888
				return "去门边 860 按 E 送别 · 她已经站在门口" -- 5891
			end -- 5891
			if self.phase == "gate-farewell" then -- 5891
				return "城门送别 · 嘱咐她慢慢数到二十" -- 5894
			end -- 5894
			if self.phase == "gate-count" then -- 5894
				if self.countTick >= ____exports.GATE_COUNT_END then -- 5894
					return self.countPrevMove > 0 and "先松开方向键，再按 D" or "按 D · 让她迈出第一步" -- 5898
				end -- 5898
				return ("数到二十 " .. tostring(self.countTick)) .. " / 1440 拍 · 门正在关" -- 5900
			end -- 5900
			return "她自己走 · 跟着出城门 1120" -- 5902
		end -- 5902
	end -- 5902
	if self.room.key == "forest" then -- 5902
		if self.dogState == "chase" then -- 5902
			return "狗在追 · 蹲下或拉开距离，等它停下" -- 5907
		end -- 5907
		if self.dogState == "ear" then -- 5907
			return "狗转耳朵了 · 停下或蹲下别出声" -- 5910
		end -- 5910
		return "草后等、Shift 慢走、Ctrl 蹲 · 林缘 1450 走到灯下" -- 5912
	end -- 5912
	if self.room.key == "tower" then -- 5912
		if self.phase == "tower-wait" then -- 5912
			return "走到门前 445 点一次 E 敲两下" -- 5916
		end -- 5916
		if self.phase == "tower-knock" then -- 5916
			return "敲两下 · 等门开" -- 5919
		end -- 5919
		if self.phase == "tower-given" then -- 5919
			return "递交针套和纸条 · 看登记簿最后一行" -- 5922
		end -- 5922
		return "片尾 · 点 E 再玩一次，回到序章" -- 5924
	end -- 5924
	if self.room.key == "village" then -- 5924
		if self.bottleFly ~= nil then -- 5924
			return "等瓶子落地 · 触地才发声" -- 5928
		end -- 5928
		if self.hasBottle then -- 5928
			return "按住 F 瞄，准星圈就是落点，松手投 · 往右投到砖地 608" -- 5931
		end -- 5931
		if self.passed then -- 5931
			return "已过第一院 · R 重置可再来一遍" -- 5934
		end -- 5934
		return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44" -- 5936
	end -- 5936
	if self.room.key == "outside" then -- 5936
		if self.focusCart then -- 5936
			return "按住 E 抓住车把 · A / D 推拉 · 松手就停" -- 5940
		end -- 5940
		return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞" -- 5942
	end -- 5942
	if self.escort.state == "frozen" then -- 5942
		if math.abs(self.player.x - self.partner.x) <= CALM_REACH then -- 5942
			return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身" -- 5946
		end -- 5946
		return "小满吓住了 · 走过去，靠近再点 E" -- 5948
	end -- 5948
	if self.escort.state == "calming" then -- 5948
		return ("安抚中 " .. tostring(self.escort.calmTick)) .. " / 60 拍 · 别动" -- 5951
	end -- 5951
	return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门" -- 5953
end -- 5826
function Play.prototype.draw(self, draw, w, h) -- 5958
	self.viewW = w -- 5959
	self.viewH = h -- 5960
	self.view = ____exports.computeViewport(w, h) -- 5961
	self:clampCamera(w, h) -- 5962
	draw:clear() -- 5963
	draw:drawRect( -- 5965
		Rect(0, 0, w, h), -- 5965
		BG_VOID -- 5965
	) -- 5965
	local box = self:canvasRect(w, h) -- 5966
	draw:drawRect(box, BG_FAR) -- 5967
	draw:drawRect( -- 5968
		Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), -- 5968
		BG_MID -- 5968
	) -- 5968
	self:drawFloors(draw, w, h) -- 5970
	self:drawSolids(draw, w, h) -- 5971
	self:drawZones(draw, w, h) -- 5972
	self:drawArch(draw, w, h) -- 5973
	self:drawCart(draw, w, h) -- 5974
	self:drawCampaignProps(draw, w, h) -- 5975
	self:drawActors(draw, w, h) -- 5976
	self:drawTrace(draw, w, h) -- 5977
	self:drawAim(draw, w, h) -- 5978
end -- 5958
function Play.prototype.canvasRect(self, w, h) -- 5982
	local v = self.view -- 5983
	return Rect(v.ox, v.oy, ____exports.LOGIC_W * v.zoom, ____exports.LOGIC_H * v.zoom) -- 5984
end -- 5982
function Play.prototype.px(self, n) -- 5988
	return n * self.view.zoom -- 5989
end -- 5988
function Play.prototype.sx(self, wx, w) -- 5993
	local v = self.view -- 5994
	local lx = math.floor((wx - self.cam.x) / ____exports.UNITS_PER_PX + ____exports.LOGIC_W / 2 + 0.5) -- 5995
	return v.ox + lx * v.zoom -- 5996
end -- 5993
function Play.prototype.sy(self, wy, h) -- 6000
	local v = self.view -- 6001
	local ly = math.floor((wy - self.cam.y) / ____exports.UNITS_PER_PX + ____exports.LOGIC_H / 2 + 0.5) -- 6002
	return v.oy + ly * v.zoom -- 6003
end -- 6000
function Play.prototype.drawBox(self, draw, w, h, x0, x1, y0, y1, color) -- 6006
	local px0 = self:sx(x0, w) -- 6007
	local px1 = self:sx(x1, w) -- 6008
	local py0 = self:sy(y0, h) -- 6009
	local py1 = self:sy(y1, h) -- 6010
	if px1 <= px0 or py1 <= py0 then -- 6010
		return -- 6012
	end -- 6012
	draw:drawRect( -- 6014
		Rect(px0, py0, px1 - px0, py1 - py0), -- 6014
		color -- 6014
	) -- 6014
end -- 6006
function Play.prototype.drawFloors(self, draw, w, h) -- 6017
	local i = 0 -- 6018
	do -- 6018
		i = 0 -- 6019
		while i < #self.room.floors do -- 6019
			local f = self.room.floors[i + 1] -- 6020
			local ____temp_147 -- 6021
			if f.y == 0 then -- 6021
				____temp_147 = self.room.depth -- 6021
			else -- 6021
				____temp_147 = nil -- 6021
			end -- 6021
			local road = ____temp_147 -- 6021
			local y = self:sy(f.y + (road and road.min or 0), h) -- 6022
			local x0 = self:sx(f.x0, w) -- 6023
			local x1 = self:sx(f.x1, w) -- 6024
			local deck = self:px(5) -- 6025
			if road ~= nil then -- 6025
				local back = self:sy(f.y + road.max, h) -- 6027
				draw:drawRect( -- 6028
					Rect(x0, y, x1 - x0, back - y), -- 6028
					FLOOR_DECK, -- 6028
					self:px(1), -- 6028
					SOLID_EDGE -- 6028
				) -- 6028
			end -- 6028
			draw:drawRect( -- 6030
				Rect(x0, y - deck, x1 - x0, deck), -- 6030
				FLOOR_DECK -- 6030
			) -- 6030
			draw:drawSegment( -- 6031
				Vec2(x0, y), -- 6031
				Vec2(x1, y), -- 6031
				self:px(1), -- 6031
				GROUND -- 6031
			) -- 6031
			i = i + 1 -- 6019
		end -- 6019
	end -- 6019
end -- 6017
function Play.prototype.drawSolids(self, draw, w, h) -- 6035
	local i = 0 -- 6036
	do -- 6036
		i = 0 -- 6037
		while i < #self.boxes do -- 6037
			do -- 6037
				local b = self.boxes[i + 1] -- 6038
				if b.id == "braced_shield" or b.hidden == true then -- 6038
					goto __continue1093 -- 6040
				end -- 6040
				if b.broken == true then -- 6040
					if b.breakable ~= nil then -- 6040
						local gy = self:sy(b.y0, h) -- 6045
						local rgb = b.breakable.kind == "basket_wall" and Color(0.52, 0.42, 0.28, 1) or Color(0.46, 0.34, 0.22, 1) -- 6046
						local k = 0 -- 6047
						do -- 6047
							k = 0 -- 6048
							while k < 3 do -- 6048
								local gx = self:sx(b.x0 + (b.x1 - b.x0) * (0.2 + k * 0.3), w) -- 6049
								draw:drawSegment( -- 6050
									Vec2( -- 6050
										gx - self:px(4), -- 6050
										gy + self:px(k % 2) -- 6050
									), -- 6050
									Vec2( -- 6050
										gx + self:px(5), -- 6050
										gy + self:px(k % 2) -- 6050
									), -- 6050
									self:px(1), -- 6050
									rgb -- 6050
								) -- 6050
								k = k + 1 -- 6048
							end -- 6048
						end -- 6048
					end -- 6048
					goto __continue1093 -- 6053
				end -- 6053
				local ____opt_150 = b.depth -- 6053
				local front = ____opt_150 and ____opt_150.min or 0 -- 6055
				local ____opt_152 = b.depth -- 6055
				local back = ____opt_152 and ____opt_152.max or 0 -- 6056
				local fill = SOLID_FILL -- 6057
				local line = SOLID_EDGE -- 6058
				if b.soft == true then -- 6058
					fill = SOFT -- 6060
					line = SOFT_LINE -- 6061
				elseif b.breakable ~= nil then -- 6061
					line = DANGER_LINE -- 6063
					fill = Color(0.3, 0.24, 0.16, 1) -- 6064
				elseif b.interact ~= nil then -- 6064
					line = PASS_LINE -- 6066
				end -- 6066
				self:drawBox( -- 6068
					draw, -- 6068
					w, -- 6068
					h, -- 6068
					b.x0, -- 6068
					b.x1, -- 6068
					b.y0 + front, -- 6068
					b.y1 + back, -- 6068
					fill -- 6068
				) -- 6068
				draw:drawSegment( -- 6069
					Vec2( -- 6069
						self:sx(b.x0, w), -- 6069
						self:sy(b.y1 + front, h) -- 6069
					), -- 6069
					Vec2( -- 6070
						self:sx(b.x1, w), -- 6070
						self:sy(b.y1 + front, h) -- 6070
					), -- 6070
					self:px(1), -- 6070
					line -- 6070
				) -- 6070
				if b.breakable ~= nil then -- 6070
					local cxp = self:sx((b.x0 + b.x1) / 2, w) -- 6073
					local cyp = self:sy(b.y1 + front, h) -- 6074
					draw:drawSegment( -- 6075
						Vec2( -- 6075
							cxp - self:px(4), -- 6075
							cyp + self:px(1) -- 6075
						), -- 6075
						Vec2( -- 6075
							cxp + self:px(3), -- 6075
							cyp + self:px(5) -- 6075
						), -- 6075
						self:px(1), -- 6075
						line -- 6075
					) -- 6075
				end -- 6075
			end -- 6075
			::__continue1093:: -- 6075
			i = i + 1 -- 6037
		end -- 6037
	end -- 6037
end -- 6035
function Play.prototype.drawCampaignProps(self, draw, w, h) -- 6081
	local i = 0 -- 6082
	do -- 6082
		i = 0 -- 6083
		while i < #self.pickups do -- 6083
			do -- 6083
				local pk = self.pickups[i + 1] -- 6084
				if self.run.taken[pk.id] == true then -- 6084
					goto __continue1105 -- 6086
				end -- 6086
				local gy = pk.y + (pk.depth or 0) -- 6088
				local bob = math.sin((self.run.ticks + pk.x) * 0.12) * 2 -- 6089
				draw:drawRect( -- 6090
					Rect( -- 6090
						self:sx(pk.x - 5, w), -- 6090
						self:sy(gy + 12 + bob, h), -- 6090
						self:px(10), -- 6090
						self:px(10) -- 6090
					), -- 6090
					Color(0.84, 0.7, 0.3, 1) -- 6091
				) -- 6091
				draw:drawSegment( -- 6092
					Vec2( -- 6092
						self:sx(pk.x - 5, w), -- 6092
						self:sy(gy + 12 + bob, h) -- 6092
					), -- 6092
					Vec2( -- 6093
						self:sx(pk.x + 5, w), -- 6093
						self:sy(gy + 12 + bob, h) -- 6093
					), -- 6093
					self:px(1), -- 6093
					Color(0.95, 0.86, 0.52, 1) -- 6093
				) -- 6093
			end -- 6093
			::__continue1105:: -- 6093
			i = i + 1 -- 6083
		end -- 6083
	end -- 6083
	if self.bracedShield ~= nil then -- 6083
		local sh = self.bracedShield -- 6096
		draw:drawRect( -- 6097
			Rect( -- 6097
				self:sx(sh.x - sh.w / 2, w), -- 6097
				self:sy(sh.y, h), -- 6097
				self:px(sh.w), -- 6097
				self:px(sh.h) -- 6097
			), -- 6097
			Color(0.42, 0.4, 0.34, 1) -- 6098
		) -- 6098
		draw:drawSegment( -- 6099
			Vec2( -- 6099
				self:sx(sh.x - sh.w / 2, w), -- 6099
				self:sy(sh.y + sh.h, h) -- 6099
			), -- 6099
			Vec2( -- 6100
				self:sx(sh.x + sh.w / 2, w), -- 6100
				self:sy(sh.y + sh.h, h) -- 6100
			), -- 6100
			self:px(1), -- 6100
			Color(0.74, 0.72, 0.62, 1) -- 6100
		) -- 6100
	end -- 6100
end -- 6081
function Play.prototype.drawZones(self, draw, w, h) -- 6104
	local i = 0 -- 6105
	do -- 6105
		i = 0 -- 6106
		while i < #self.room.zones do -- 6106
			local z = self.room.zones[i + 1] -- 6107
			local fill = DANGER -- 6108
			local line = DANGER_LINE -- 6109
			if z.tint == 2 then -- 6109
				fill = SOFT -- 6111
				line = SOFT_LINE -- 6112
			elseif z.tint == 3 then -- 6112
				fill = BRICK -- 6114
				line = BRICK_LINE -- 6115
			elseif z.tint == 4 then -- 6115
				fill = PASS -- 6117
				line = PASS_LINE -- 6118
			end -- 6118
			self:drawBox( -- 6120
				draw, -- 6120
				w, -- 6120
				h, -- 6120
				z.x0, -- 6120
				z.x1, -- 6120
				z.y, -- 6120
				z.y + z.h, -- 6120
				fill -- 6120
			) -- 6120
			draw:drawSegment( -- 6121
				Vec2( -- 6121
					self:sx(z.x0, w), -- 6121
					self:sy(z.y, h) -- 6121
				), -- 6121
				Vec2( -- 6121
					self:sx(z.x0, w), -- 6121
					self:sy(z.y + z.h, h) -- 6121
				), -- 6121
				self:px(1), -- 6121
				line -- 6121
			) -- 6121
			draw:drawSegment( -- 6122
				Vec2( -- 6122
					self:sx(z.x1, w), -- 6122
					self:sy(z.y, h) -- 6122
				), -- 6122
				Vec2( -- 6122
					self:sx(z.x1, w), -- 6122
					self:sy(z.y + z.h, h) -- 6122
				), -- 6122
				self:px(1), -- 6122
				line -- 6122
			) -- 6122
			i = i + 1 -- 6106
		end -- 6106
	end -- 6106
end -- 6104
function Play.prototype.drawArch(self, draw, w, h) -- 6126
	local a = self.room.arch -- 6127
	if a.h <= 0 then -- 6127
		return -- 6129
	end -- 6129
	self:drawBox( -- 6131
		draw, -- 6131
		w, -- 6131
		h, -- 6131
		a.x0, -- 6131
		a.x1, -- 6131
		a.y, -- 6131
		a.y + a.h, -- 6131
		HOLE_FILL -- 6131
	) -- 6131
	draw:drawSegment( -- 6132
		Vec2( -- 6132
			self:sx(a.x0, w), -- 6132
			self:sy(a.y + a.h, h) -- 6132
		), -- 6132
		Vec2( -- 6132
			self:sx(a.x1, w), -- 6132
			self:sy(a.y + a.h, h) -- 6132
		), -- 6132
		self:px(1), -- 6132
		SOLID_EDGE -- 6132
	) -- 6132
	draw:drawSegment( -- 6133
		Vec2( -- 6133
			self:sx(a.x0, w), -- 6133
			self:sy(a.y, h) -- 6133
		), -- 6133
		Vec2( -- 6133
			self:sx(a.x0, w), -- 6133
			self:sy(a.y + a.h, h) -- 6133
		), -- 6133
		self:px(1), -- 6133
		SOLID_EDGE -- 6133
	) -- 6133
	draw:drawSegment( -- 6134
		Vec2( -- 6134
			self:sx(a.x1, w), -- 6134
			self:sy(a.y, h) -- 6134
		), -- 6134
		Vec2( -- 6134
			self:sx(a.x1, w), -- 6134
			self:sy(a.y + a.h, h) -- 6134
		), -- 6134
		self:px(1), -- 6134
		SOLID_EDGE -- 6134
	) -- 6134
end -- 6126
function Play.prototype.drawCart(self, draw, w, h) -- 6137
	local c = self.room.cart -- 6138
	if c.bodyW <= 0 then -- 6138
		return -- 6140
	end -- 6140
	drawCartShape( -- 6142
		draw, -- 6142
		self, -- 6142
		w, -- 6142
		h, -- 6142
		c, -- 6142
		self.cartAxle -- 6142
	) -- 6142
	draw:drawRect( -- 6143
		Rect( -- 6143
			self:sx(self.cartAxle + c.handleOffset, w) - self:px(1), -- 6143
			self:sy(c.baseY + (c.depth or 0) + 40, h), -- 6143
			self:px(2), -- 6143
			self:px(40) -- 6143
		), -- 6143
		STAND -- 6143
	) -- 6143
end -- 6137
function Play.prototype.drawActors(self, draw, w, h) -- 6146
	local p = self.player -- 6147
	local isChild = self.childMode -- 6148
	local footY = p.y + p.depth * DEPTH_Y_SCALE -- 6149
	if p.covered then -- 6149
		local edge = p.x + p.facing * (p.w / 2 + 2) -- 6152
		draw:drawSegment( -- 6153
			Vec2( -- 6153
				self:sx(edge, w), -- 6153
				self:sy(footY + 8, h) -- 6153
			), -- 6153
			Vec2( -- 6153
				self:sx(edge, w), -- 6153
				self:sy(footY + p.h * 0.62, h) -- 6153
			), -- 6153
			self:px(2), -- 6153
			STAND -- 6153
		) -- 6153
		draw:drawSegment( -- 6155
			Vec2( -- 6155
				self:sx(p.x - 8, w), -- 6155
				self:sy(footY + p.h + 3, h) -- 6155
			), -- 6155
			Vec2( -- 6155
				self:sx(p.x + 8, w), -- 6155
				self:sy(footY + p.h + 3, h) -- 6155
			), -- 6155
			self:px(2), -- 6155
			STAND -- 6155
		) -- 6155
	elseif self.coverNear and not isChild then -- 6155
		draw:drawRect( -- 6158
			Rect( -- 6158
				self:sx(p.x - 3, w), -- 6158
				self:sy(footY + 1, h), -- 6158
				self:px(3), -- 6158
				self:px(3) -- 6158
			), -- 6158
			STAND -- 6158
		) -- 6158
	end -- 6158
	drawFigure( -- 6160
		draw, -- 6160
		self, -- 6160
		w, -- 6160
		h, -- 6160
		p, -- 6160
		isChild and CHILD_BODY or SOLDIER_BODY, -- 6160
		isChild and CHILD_HEAD or SOLDIER_HEAD -- 6160
	) -- 6160
	local q = self.partner -- 6161
	if q.alive then -- 6161
		local childPartner = q.w == CHILD_W -- 6163
		drawFigure( -- 6164
			draw, -- 6164
			self, -- 6164
			w, -- 6164
			h, -- 6164
			q, -- 6164
			childPartner and CHILD_BODY or SOLDIER_BODY, -- 6164
			childPartner and CHILD_HEAD or SOLDIER_HEAD -- 6164
		) -- 6164
	end -- 6164
	local i = 0 -- 6166
	do -- 6166
		i = 0 -- 6167
		while i < #self.enemies do -- 6167
			local e = self.enemies[i + 1] -- 6168
			local col = e.alive and ENEMY_BODY or ENEMY_DEAD -- 6169
			local enemyY = e.y + (e.depth or 0) * DEPTH_Y_SCALE -- 6170
			self:drawBox( -- 6171
				draw, -- 6171
				w, -- 6171
				h, -- 6171
				e.x - e.w / 2, -- 6171
				e.x + e.w / 2, -- 6171
				enemyY, -- 6171
				enemyY + e.h, -- 6171
				col -- 6171
			) -- 6171
			if e.alive then -- 6171
				local ef = p.x >= e.x and 1 or -1 -- 6173
				if e.kind == "shield" then -- 6173
					local sh = (e.shieldHp or 0) > 0 -- 6175
					draw:drawRect( -- 6176
						Rect( -- 6176
							self:sx(e.x + ef * (e.w / 2 + 2) - 3, w), -- 6176
							self:sy(enemyY, h), -- 6176
							self:px(6), -- 6176
							self:px(64) -- 6176
						), -- 6176
						sh and Color(0.46, 0.44, 0.38, 1) or Color(0.28, 0.26, 0.22, 1) -- 6177
					) -- 6177
				elseif e.kind == "breaker" then -- 6177
					draw:drawSegment( -- 6179
						Vec2( -- 6179
							self:sx(e.x + ef * 12, w), -- 6179
							self:sy(enemyY + 8, h) -- 6179
						), -- 6179
						Vec2( -- 6180
							self:sx(e.x + ef * 22, w), -- 6180
							self:sy(enemyY + 46, h) -- 6180
						), -- 6180
						self:px(3), -- 6180
						Color(0.5, 0.36, 0.22, 1) -- 6180
					) -- 6180
				end -- 6180
			end -- 6180
			if e.alive and e.warnT > 0 then -- 6180
				local gunX = self:sx(e.x, w) -- 6185
				local gunY = self:sy(enemyY + e.h * 0.72, h) -- 6186
				local aimX = self:sx(p.x, w) -- 6187
				local aimY = self:sy(footY + p.h * 0.55, h) -- 6188
				local seg = 8 -- 6189
				local s = 0 -- 6190
				do -- 6190
					s = 0 -- 6191
					while s < seg do -- 6191
						local t0 = s / seg -- 6192
						local t1 = (s + 1) / seg -- 6193
						draw:drawSegment( -- 6194
							Vec2(gunX + (aimX - gunX) * t0, gunY + (aimY - gunY) * t0), -- 6195
							Vec2(gunX + (aimX - gunX) * t1, gunY + (aimY - gunY) * t1), -- 6196
							self:px(1), -- 6197
							DANGER -- 6197
						) -- 6197
						s = s + 2 -- 6191
					end -- 6191
				end -- 6191
			end -- 6191
			i = i + 1 -- 6167
		end -- 6167
	end -- 6167
	local k = 0 -- 6202
	do -- 6202
		k = 0 -- 6203
		while k < #self.room.marks do -- 6203
			do -- 6203
				local m = self.room.marks[k + 1] -- 6204
				if m.kind ~= 0 then -- 6204
					goto __continue1131 -- 6206
				end -- 6206
				local on = self.checkpoint == m.x -- 6208
				local x = self:sx(m.x, w) -- 6209
				local y = self:sy(m.y, h) -- 6210
				draw:drawSegment( -- 6211
					Vec2(x, y), -- 6211
					Vec2( -- 6211
						x, -- 6211
						y + self:px(35) -- 6211
					), -- 6211
					self:px(1), -- 6211
					on and CHECK or INK_DIM -- 6211
				) -- 6211
				draw:drawDot( -- 6212
					Vec2( -- 6212
						x, -- 6212
						y + self:px(35) -- 6212
					), -- 6212
					self:px(2), -- 6212
					on and CHECK or INK_DIM -- 6212
				) -- 6212
			end -- 6212
			::__continue1131:: -- 6212
			k = k + 1 -- 6203
		end -- 6203
	end -- 6203
	local j = 0 -- 6216
	do -- 6216
		j = 0 -- 6217
		while j < #self.room.marks do -- 6217
			do -- 6217
				local m = self.room.marks[j + 1] -- 6218
				if m.kind ~= 1 and m.kind ~= 4 and m.kind ~= 5 then -- 6218
					goto __continue1134 -- 6220
				end -- 6220
				if m.kind == 1 and self.room.key ~= "checkpoint" and self.room.key ~= "prologue" and self.room.key ~= "gate" and self.room.key ~= "tower" then -- 6220
					goto __continue1134 -- 6224
				end -- 6224
				local col = STAND -- 6226
				if m.kind == 4 then -- 6226
					col = PASS_LINE -- 6228
				elseif m.kind == 5 then -- 6228
					col = BRICK_LINE -- 6230
				end -- 6230
				local mx = self:sx(m.x, w) -- 6232
				local my = self:sy(m.y, h) -- 6233
				draw:drawSegment( -- 6234
					Vec2(mx, my), -- 6234
					Vec2( -- 6234
						mx, -- 6234
						my + self:px(24) -- 6234
					), -- 6234
					self:px(1), -- 6234
					col -- 6234
				) -- 6234
			end -- 6234
			::__continue1134:: -- 6234
			j = j + 1 -- 6217
		end -- 6217
	end -- 6217
	local t = 0 -- 6237
	do -- 6237
		t = 0 -- 6238
		while t < #self.room.marks do -- 6238
			do -- 6238
				local m = self.room.marks[t + 1] -- 6239
				if m.kind ~= 6 then -- 6239
					goto __continue1140 -- 6241
				end -- 6241
				local mx = self:sx(m.x, w) -- 6243
				local my = self:sy(m.y, h) -- 6244
				draw:drawSegment( -- 6245
					Vec2(mx, my), -- 6245
					Vec2( -- 6245
						mx, -- 6245
						my + self:px(30) -- 6245
					), -- 6245
					self:px(1), -- 6245
					INK_DIM -- 6245
				) -- 6245
				self:drawBox( -- 6246
					draw, -- 6246
					w, -- 6246
					h, -- 6246
					m.x - 5, -- 6246
					m.x + 5, -- 6246
					m.y + 30, -- 6246
					m.y + 40, -- 6246
					CHECK -- 6246
				) -- 6246
			end -- 6246
			::__continue1140:: -- 6246
			t = t + 1 -- 6238
		end -- 6238
	end -- 6238
	if self.room.key == "village" then -- 6238
		self:drawVillage(draw, w, h) -- 6249
	end -- 6249
	if self.room.key == "forest" then -- 6249
		self:drawDog(draw, w, h) -- 6252
	end -- 6252
end -- 6146
function Play.prototype.drawDog(self, draw, w, h) -- 6257
	local x = self.dogX -- 6258
	self:drawBox( -- 6259
		draw, -- 6259
		w, -- 6259
		h, -- 6259
		x - 14, -- 6259
		x + 14, -- 6259
		0, -- 6259
		20, -- 6259
		SCAV_BODY -- 6259
	) -- 6259
	self:drawBox( -- 6260
		draw, -- 6260
		w, -- 6260
		h, -- 6260
		x - 10, -- 6260
		x - 2, -- 6260
		20, -- 6260
		30, -- 6260
		SCAV_BODY -- 6260
	) -- 6260
	self:drawBox( -- 6261
		draw, -- 6261
		w, -- 6261
		h, -- 6261
		x + 2, -- 6261
		x + 10, -- 6261
		20, -- 6261
		30, -- 6261
		SCAV_HEAD -- 6261
	) -- 6261
	if self.dogState == "ear" or self.dogState == "chase" then -- 6261
		draw:drawSegment( -- 6263
			Vec2( -- 6263
				self:sx(x, w), -- 6263
				self:sy(30, h) -- 6263
			), -- 6263
			Vec2( -- 6264
				self:sx(x, w), -- 6264
				self:sy(40, h) -- 6264
			), -- 6264
			self:px(1), -- 6264
			DANGER -- 6264
		) -- 6264
	end -- 6264
end -- 6257
function Play.prototype.drawVillage(self, draw, w, h) -- 6269
	local bottle = self.room.bottle -- 6270
	if bottle ~= nil then -- 6270
		self:drawBox( -- 6272
			draw, -- 6272
			w, -- 6272
			h, -- 6272
			bottle.x - 14, -- 6272
			bottle.x + 14, -- 6272
			0, -- 6272
			64, -- 6272
			SOLID_FILL -- 6272
		) -- 6272
		if not self.hasBottle and self.bottleFly == nil and self.bottleLandT <= 0 then -- 6272
			self:drawBottle( -- 6274
				draw, -- 6274
				w, -- 6274
				h, -- 6274
				bottle.x, -- 6274
				64 -- 6274
			) -- 6274
		end -- 6274
	end -- 6274
	self:drawBox( -- 6278
		draw, -- 6278
		w, -- 6278
		h, -- 6278
		300, -- 6278
		420, -- 6278
		44, -- 6278
		50, -- 6278
		FLOOR_DECK -- 6278
	) -- 6278
	self:drawBox( -- 6279
		draw, -- 6279
		w, -- 6279
		h, -- 6279
		300, -- 6279
		306, -- 6279
		0, -- 6279
		44, -- 6279
		FLOOR_DECK -- 6279
	) -- 6279
	self:drawBox( -- 6280
		draw, -- 6280
		w, -- 6280
		h, -- 6280
		414, -- 6280
		420, -- 6280
		0, -- 6280
		44, -- 6280
		FLOOR_DECK -- 6280
	) -- 6280
	local s = self.room.scavenger -- 6282
	if s ~= nil then -- 6282
		local sx0 = self.scavX -- 6284
		self:drawBox( -- 6285
			draw, -- 6285
			w, -- 6285
			h, -- 6285
			sx0 - 12, -- 6285
			sx0 + 12, -- 6285
			0, -- 6285
			s.h - 14, -- 6285
			SCAV_BODY -- 6285
		) -- 6285
		self:drawBox( -- 6286
			draw, -- 6286
			w, -- 6286
			h, -- 6286
			sx0 - 7, -- 6286
			sx0 + 7, -- 6286
			s.h - 14, -- 6286
			s.h, -- 6286
			SCAV_HEAD -- 6286
		) -- 6286
		if self.scavState == "turn" then -- 6286
			local fx = sx0 + (self.scavDir > 0 and 12 or -12) -- 6288
			draw:drawSegment( -- 6289
				Vec2( -- 6289
					self:sx(sx0, w), -- 6289
					self:sy(s.h - 6, h) -- 6289
				), -- 6289
				Vec2( -- 6289
					self:sx(fx, w), -- 6289
					self:sy(s.h - 6, h) -- 6289
				), -- 6289
				self:px(1), -- 6289
				INK -- 6289
			) -- 6289
		end -- 6289
	end -- 6289
	if self.hasBottle then -- 6289
		local p = self.player -- 6294
		self:drawBottle( -- 6295
			draw, -- 6295
			w, -- 6295
			h, -- 6295
			p.x + p.facing * 10, -- 6295
			p.y + p.h * 0.62 -- 6295
		) -- 6295
	end -- 6295
	if self.bottleFly ~= nil then -- 6295
		self:drawBottle( -- 6298
			draw, -- 6298
			w, -- 6298
			h, -- 6298
			self.bottleFly.x, -- 6298
			self.bottleFly.y -- 6298
		) -- 6298
	end -- 6298
	if self.bottleLandT > 0 and self.bottleLandX >= 0 then -- 6298
		local r = (1 - self.bottleLandT / 0.9) * 28 -- 6301
		draw:drawCircle( -- 6302
			Vec2( -- 6302
				self:sx(self.bottleLandX, w), -- 6302
				self:sy(0, h) -- 6302
			), -- 6302
			self:px(r / ____exports.UNITS_PER_PX), -- 6302
			BRICK_LINE -- 6302
		) -- 6302
	end -- 6302
end -- 6269
function Play.prototype.drawBottle(self, draw, w, h, x, y) -- 6306
	self:drawBox( -- 6307
		draw, -- 6307
		w, -- 6307
		h, -- 6307
		x - 3, -- 6307
		x + 3, -- 6307
		y - 10, -- 6307
		y, -- 6307
		BOTTLE -- 6307
	) -- 6307
end -- 6306
function Play.prototype.drawTrace(self, draw, w, h) -- 6310
	local t = self.trace -- 6311
	if t == nil or self.traceT <= 0 then -- 6311
		return -- 6313
	end -- 6313
	draw:drawSegment( -- 6315
		Vec2( -- 6316
			self:sx(t.x0, w), -- 6316
			self:sy(t.y0, h) -- 6316
		), -- 6316
		Vec2( -- 6317
			self:sx(t.x1, w), -- 6317
			self:sy(t.y1, h) -- 6317
		), -- 6317
		self:px(1), -- 6318
		t.hit and AIM_HIT or INK_DIM -- 6318
	) -- 6318
end -- 6310
function Play.prototype.drawAim(self, draw, w, h) -- 6321
	local v = self.view -- 6323
	local gx = v.ox + math.floor((self.aimX - v.ox) / v.zoom + 0.5) * v.zoom -- 6324
	local gy = v.oy + math.floor((self.aimY - v.oy) / v.zoom + 0.5) * v.zoom -- 6325
	local dot = self:px(1) -- 6326
	local arm = self:px(3) -- 6327
	local gap = self:px(1) -- 6328
	draw:drawSegment( -- 6329
		Vec2(gx - arm - gap, gy), -- 6329
		Vec2(gx - gap, gy), -- 6329
		dot / 2, -- 6329
		AIM -- 6329
	) -- 6329
	draw:drawSegment( -- 6330
		Vec2(gx + gap, gy), -- 6330
		Vec2(gx + arm + gap, gy), -- 6330
		dot / 2, -- 6330
		AIM -- 6330
	) -- 6330
	draw:drawSegment( -- 6331
		Vec2(gx, gy - arm - gap), -- 6331
		Vec2(gx, gy - gap), -- 6331
		dot / 2, -- 6331
		AIM -- 6331
	) -- 6331
	draw:drawSegment( -- 6332
		Vec2(gx, gy + gap), -- 6332
		Vec2(gx, gy + arm + gap), -- 6332
		dot / 2, -- 6332
		AIM -- 6332
	) -- 6332
	if self.room.key == "village" and self.hasBottle then -- 6332
		local p = self.player -- 6336
		local ____end = self.bottleAimX >= 0 and ({x = self.bottleAimX, y = self.bottleAimY}) or self:bottleEnd() -- 6338
		local dir = ____end.x >= p.x and 1 or -1 -- 6339
		local x0 = p.x + dir * 10 -- 6340
		local y0 = p.y + p.h * 0.7 -- 6341
		local T = BOTTLE_FLY_TIME -- 6342
		local vx = (____end.x - x0) / T -- 6343
		local vy = (____end.y - y0 + 0.5 * ____exports.GRAVITY * T * T) / T -- 6344
		local pxr = x0 -- 6345
		local pyr = y0 -- 6346
		local t = 1 -- 6347
		do -- 6347
			t = 1 -- 6348
			while t <= 12 do -- 6348
				local tt = t / 12 * T -- 6349
				local nx = x0 + vx * tt -- 6350
				local ny = y0 + vy * tt - 0.5 * ____exports.GRAVITY * tt * tt -- 6351
				draw:drawSegment( -- 6352
					Vec2( -- 6352
						self:sx(pxr, w), -- 6352
						self:sy(pyr, h) -- 6352
					), -- 6352
					Vec2( -- 6352
						self:sx(nx, w), -- 6352
						self:sy(ny, h) -- 6352
					), -- 6352
					self:px(1) / 2, -- 6352
					BOTTLE -- 6352
				) -- 6352
				pxr = nx -- 6353
				pyr = ny -- 6354
				t = t + 1 -- 6348
			end -- 6348
		end -- 6348
		draw:drawCircle( -- 6356
			Vec2( -- 6356
				self:sx(____end.x, w), -- 6356
				self:sy(____end.y + 2, h) -- 6356
			), -- 6356
			self:px(2), -- 6356
			BOTTLE -- 6356
		) -- 6356
	end -- 6356
end -- 6321
return ____exports -- 6321